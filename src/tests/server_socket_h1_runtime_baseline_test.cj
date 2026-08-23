package ignite.tests

import ignite.*
import ignite.middleware.*
import std.collection.ArrayList
import std.io.InputStream
import std.net.{IPSocketAddress, TcpSocket}
import std.sync.Mutex
import std.time.MonoTime

class SocketH1RuntimeBaselineGate {
    let mtx = Mutex()
    var entered: Bool = false
    var released: Bool = false

    public func markEntered(): Unit {
        synchronized(mtx) {
            entered = true
        }
    }

    public func isEntered(): Bool {
        synchronized(mtx) {
            entered
        }
    }

    public func release(): Unit {
        synchronized(mtx) {
            released = true
        }
    }

    public func isReleased(): Bool {
        synchronized(mtx) {
            released
        }
    }
}

class SocketH1RuntimeBaselineDelayedStream <: InputStream & Resource {
    let mtx = Mutex()
    var turn: Int64 = 0
    var released: Bool = false
    public var closed: Bool = false

    public override func read(outBuf: Array<Byte>): Int64 {
        if (turn == 0) {
            turn = 1
            return writeText(outBuf, "first-")
        }
        if (turn == 1) {
            while (!isReleased()) {
                sleep(Duration.millisecond * 5)
            }
            turn = 2
            return writeText(outBuf, "second")
        }
        0
    }

    public func release(): Unit {
        synchronized(mtx) {
            released = true
        }
    }

    public func isReleased(): Bool {
        synchronized(mtx) {
            released
        }
    }

    public func close(): Unit {
        closed = true
    }

    public func isClosed(): Bool {
        closed
    }

    func writeText(outBuf: Array<Byte>, text: String): Int64 {
        let bytes = text.toArray()
        if (outBuf.size < bytes.size) {
            throw Exception("delayed stream output buffer is too small")
        }
        var i: Int64 = 0
        while (i < bytes.size) {
            outBuf[i] = bytes[i]
            i += 1
        }
        bytes.size
    }
}

class SocketH1RuntimeBaselineResponseCacheStore <: ResponseCacheStore {
    let mtx = Mutex()
    var putCallCount: Int64 = 0

    public override func getFresh(
        key: String,
        now: MonoTime,
        expiration: Duration
    ): ?ResponseCacheValue {
        None
    }

    public override func put(
        key: String,
        body: String,
        contentType: String,
        now: MonoTime
    ): Unit {
        synchronized(mtx) {
            putCallCount += 1
        }
    }

    public override func cleanupExpired(now: MonoTime, expiration: Duration): Unit {}

    public func putCalls(): Int64 {
        synchronized(mtx) {
            putCallCount
        }
    }
}

class SocketH1RuntimeBaselineIdempotencyStore <: IdempotencyStore {
    let mtx = Mutex()
    var putCallCount: Int64 = 0

    public override func getFresh(
        key: String,
        now: MonoTime,
        lifetime: Duration
    ): ?IdempotencyValue {
        None
    }

    public override func put(key: String, body: String, now: MonoTime): Unit {
        synchronized(mtx) {
            putCallCount += 1
        }
    }

    public override func cleanupExpired(now: MonoTime, lifetime: Duration): Unit {}

    public func putCalls(): Int64 {
        synchronized(mtx) {
            putCallCount
        }
    }
}

class SocketH1RuntimeBaselineMiddlewareObservation {
    let mtx = Mutex()
    var handlerRunCount: Int64 = 0
    var observationCount: Int64 = 0
    var compressSkipReason: String = ""
    var etagSkipReason: String = ""
    var cacheSkipReason: String = ""
    var idempotencySkipReason: String = ""

    public func nextLiveBody(): String {
        synchronized(mtx) {
            handlerRunCount += 1
            "live-body-${handlerRunCount}"
        }
    }

    public func record(ctx: Ctx): Unit {
        synchronized(mtx) {
            observationCount += 1
            compressSkipReason = ctx.getLocal("__ignite_compress_skip_reason") ?? ""
            etagSkipReason = ctx.getLocal("__ignite_etag_skip_reason") ?? ""
            cacheSkipReason = ctx.getLocal("__ignite_cache_skip_reason") ?? ""
            idempotencySkipReason = ctx.getLocal("__ignite_idempotency_skip_reason") ?? ""
        }
    }

    public func handlerRuns(): Int64 {
        synchronized(mtx) {
            handlerRunCount
        }
    }

    public func observations(): Int64 {
        synchronized(mtx) {
            observationCount
        }
    }

    public func allSkippedAfterCommit(): Bool {
        synchronized(mtx) {
            compressSkipReason == "response-committed" &&
                etagSkipReason == "response-committed" &&
                cacheSkipReason == "response-committed" &&
                idempotencySkipReason == "response-committed"
        }
    }
}

@Test
public class ServerSocketH1RuntimeBaselineTestSuite {
    @TestCase
    public func testNativeH1ResponseWriterLifecycleRejectsWritesAfterClose(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let app = App(config: Config(enableNetworkChangeNotice: false))
        app.get("/writer-lifecycle", { ctx =>
            let _ = ctx.setHeader("x-writer-path", "live")
            let _ = ctx.setHeader("content-length", "5")
            let writer = ctx.transportWriter()
            writer.write("first".toArray())
            let _ = ctx.setHeader("x-after-commit", "hidden")
            flushResponseTransportWriter(writer)
            closeResponseTransportWriter(writer)
            closeResponseTransportWriter(writer)
            try {
                writer.write("late".toArray())
            } catch (_: Exception) {
                ()
            }
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        try {
            waitForShellReady(app, port)
            let response = runSocketServerEngineShellClient(
                "127.0.0.1",
                port,
                "GET /writer-lifecycle HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            @Assert(socketH1RuntimeBaselineContains(response, "HTTP/1.1 200 OK"), true)
            @Assert(socketH1RuntimeBaselineContains(response, "x-writer-path: live"), true)
            @Assert(socketH1RuntimeBaselineContains(response, "x-after-commit"), false)
            @Assert(socketH1RuntimeBaselineContains(response, "\r\n\r\nfirst"), true)
            @Assert(socketH1RuntimeBaselineContains(response, "late"), false)
        } finally {
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }

    @TestCase
    public func testNativeH1TransportWriterCommitsBeforeHandlerCompletesAndKeepsAlive(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let gate = SocketH1RuntimeBaselineGate()
        let app = App(config: Config(enableNetworkChangeNotice: false))
        app.get("/live-writer", { ctx =>
            gate.markEntered()
            let _ = ctx.setHeader("content-type", "text/plain; charset=utf-8")
            let writer = ctx.transportWriter()
            writer.write("first-".toArray())
            flushResponseTransportWriter(writer)
            while (!gate.isReleased()) {
                sleep(Duration.millisecond * 5)
            }
            writer.write("second".toArray())
            closeResponseTransportWriter(writer)
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        try {
            waitForShellReady(app, port)
            let socket = TcpSocket(IPSocketAddress.parse("127.0.0.1:${port}"))
            socket.connect()
            try {
                socket.readTimeout = Some(Duration.second)
                socket.write(
                    "GET /live-writer HTTP/1.1\r\nHost: example.com\r\n\r\n".toArray()
                )
                let firstWire = readSocketH1RuntimeBaselineUntil(
                    socket,
                    "first-",
                    Duration.second
                )
                @Assert(socketH1RuntimeBaselineContains(firstWire, "HTTP/1.1 200 OK"), true)
                @Assert(socketH1RuntimeBaselineContains(firstWire, "transfer-encoding: chunked"), true)
                @Assert(socketH1RuntimeBaselineContains(firstWire, "first-"), true)
                @Assert(socketH1RuntimeBaselineContains(firstWire, "second"), false)
                @Assert(gate.isEntered(), true)

                gate.release()
                let completedWire = readSocketH1RuntimeBaselineUntil(
                    socket,
                    "second\r\n0\r\n\r\n",
                    Duration.second
                )
                @Assert(socketH1RuntimeBaselineContains(completedWire, "second"), true)

                socket.write(
                    "GET /live-writer HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n".toArray()
                )
                let secondResponse = readSocketH1RuntimeBaselineUntil(
                    socket,
                    "second\r\n0\r\n\r\n",
                    Duration.second
                )
                @Assert(socketH1RuntimeBaselineContains(secondResponse, "HTTP/1.1 200 OK"), true)
                @Assert(socketH1RuntimeBaselineContains(secondResponse, "second"), true)
            } finally {
                gate.release()
                if (!socket.isClosed()) {
                    socket.close()
                }
            }
        } finally {
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }

    @TestCase
    public func testNativeH1TransportWriterFlushCommitsHeadAndHandlerReturnFinishesBody(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let gate = SocketH1RuntimeBaselineGate()
        let app = App(config: Config(enableNetworkChangeNotice: false))
        app.get("/flush-first", { ctx =>
            gate.markEntered()
            let _ = ctx.setHeader("content-type", "text/plain; charset=utf-8")
            let writer = ctx.transportWriter()
            flushResponseTransportWriter(writer)
            while (!gate.isReleased()) {
                sleep(Duration.millisecond * 5)
            }
            writer.write("after-flush".toArray())
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        try {
            waitForShellReady(app, port)
            let socket = TcpSocket(IPSocketAddress.parse("127.0.0.1:${port}"))
            socket.connect()
            try {
                socket.readTimeout = Some(Duration.second)
                socket.write(
                    "GET /flush-first HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n".toArray()
                )
                let headWire = readSocketH1RuntimeBaselineUntil(
                    socket,
                    "\r\n\r\n",
                    Duration.second
                )
                @Assert(socketH1RuntimeBaselineContains(headWire, "HTTP/1.1 200 OK"), true)
                @Assert(socketH1RuntimeBaselineContains(headWire, "transfer-encoding: chunked"), true)
                @Assert(socketH1RuntimeBaselineContains(headWire, "after-flush"), false)
                @Assert(gate.isEntered(), true)

                gate.release()
                let bodyWire = readSocketH1RuntimeBaselineUntil(
                    socket,
                    "after-flush\r\n0\r\n\r\n",
                    Duration.second
                )
                @Assert(socketH1RuntimeBaselineContains(bodyWire, "after-flush"), true)
                @Assert(socketH1RuntimeBaselineContains(bodyWire, "0\r\n\r\n"), true)
            } finally {
                gate.release()
                if (!socket.isClosed()) {
                    socket.close()
                }
            }
        } finally {
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }

    @TestCase
    public func testNativeH1CommittedWriterBypassesBufferedResponseMiddleware(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let cacheStore = SocketH1RuntimeBaselineResponseCacheStore()
        let idempotencyStore = SocketH1RuntimeBaselineIdempotencyStore()
        let observation = SocketH1RuntimeBaselineMiddlewareObservation()
        let app = App(config: Config(enableNetworkChangeNotice: false))
        app.use({ ctx =>
            ctx.next()
            observation.record(ctx)
        })
        app.use(compressMiddleware(config: CompressConfig(minBytes: 0, skipIfNoGain: false)))
        app.use(cacheMiddleware(
            config: CacheConfig(methods: ["POST"]),
            store: Some(cacheStore)
        ))
        app.use(etagMiddleware())
        app.use(idempotencyMiddleware(store: Some(idempotencyStore)))
        app.post("/committed-middleware", { ctx =>
            let body = observation.nextLiveBody()
            let _ = ctx.sendString("buffered-shadow")
            let writer = ctx.transportWriter()
            writer.write(body.toArray())
            closeResponseTransportWriter(writer)
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        try {
            waitForShellReady(app, port)
            let socket = TcpSocket(IPSocketAddress.parse("127.0.0.1:${port}"))
            socket.connect()
            try {
                socket.readTimeout = Some(Duration.second)
                socket.write(
                    "POST /committed-middleware HTTP/1.1\r\nHost: example.com\r\nAccept-Encoding: gzip\r\nX-Idempotency-Key: committed-1\r\nContent-Length: 0\r\nConnection: keep-alive\r\n\r\n".toArray()
                )
                let firstResponse = readSocketH1RuntimeBaselineUntil(
                    socket,
                    "live-body-1\r\n0\r\n\r\n",
                    Duration.second
                )
                @Assert(socketH1RuntimeBaselineContains(firstResponse, "live-body-1"), true)
                @Assert(socketH1RuntimeBaselineContains(firstResponse, "buffered-shadow"), false)
                @Assert(socketH1RuntimeBaselineContains(firstResponse, "content-encoding:"), false)
                @Assert(socketH1RuntimeBaselineContains(firstResponse, "etag:"), false)

                socket.write(
                    "POST /committed-middleware HTTP/1.1\r\nHost: example.com\r\nAccept-Encoding: gzip\r\nX-Idempotency-Key: committed-1\r\nContent-Length: 0\r\nConnection: close\r\n\r\n".toArray()
                )
                let secondResponse = readSocketH1RuntimeBaselineUntil(
                    socket,
                    "live-body-2\r\n0\r\n\r\n",
                    Duration.second
                )
                @Assert(socketH1RuntimeBaselineContains(secondResponse, "live-body-2"), true)
                @Assert(socketH1RuntimeBaselineContains(secondResponse, "buffered-shadow"), false)
                @Assert(socketH1RuntimeBaselineContains(secondResponse, "content-encoding:"), false)
                @Assert(socketH1RuntimeBaselineContains(secondResponse, "etag:"), false)
            } finally {
                if (!socket.isClosed()) {
                    socket.close()
                }
            }

            @Assert(cacheStore.putCalls(), 0)
            @Assert(idempotencyStore.putCalls(), 0)
            @Assert(observation.handlerRuns(), 2)
            @Assert(observation.observations(), 2)
            @Assert(observation.allSkippedAfterCommit(), true)
        } finally {
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }

    @TestCase
    public func testDefaultNativeH1AllowsFastConnectionWhileSlowConnectionIsRunning(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let gate = SocketH1RuntimeBaselineGate()
        let app = App(config: Config(enableNetworkChangeNotice: false))
        app.get("/slow", { ctx =>
            gate.markEntered()
            sleep(Duration.millisecond * 600)
            let _ = ctx.sendString("slow")
        })
        app.get("/fast", { ctx =>
            let _ = ctx.sendString("fast")
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        try {
            waitForShellReady(app, port)
            let slowFuture = spawn {
                runSocketServerEngineShellClient(
                    "127.0.0.1",
                    port,
                    "GET /slow HTTP/1.1\r\nHost: example.com\r\n\r\n"
                )
            }
            waitForSocketH1RuntimeBaselineGate(gate)

            let fastStartedAt = MonoTime.now()
            let fastResponse = runSocketServerEngineShellClient(
                "127.0.0.1",
                port,
                "GET /fast HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let fastElapsedMillis =
                (MonoTime.now() - fastStartedAt).toMilliseconds()
            let slowResponse = slowFuture.get(Duration.second * 3)

            @Assert(socketH1RuntimeBaselineContains(fastResponse, "HTTP/1.1 200 OK"), true)
            @Assert(socketH1RuntimeBaselineContains(fastResponse, "\r\n\r\nfast"), true)
            @Assert(fastElapsedMillis < 400, true)
            @Assert(socketH1RuntimeBaselineContains(slowResponse, "HTTP/1.1 200 OK"), true)
            @Assert(socketH1RuntimeBaselineContains(slowResponse, "\r\n\r\nslow"), true)
        } finally {
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }

    @TestCase
    public func testDefaultNativeH1Returns413AndAcceptsNextContentLengthRequest(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let app = App(config: Config(
            bodyLimit: 4,
            enableNetworkChangeNotice: false
        ))
        app.post("/body-limit", { ctx =>
            let _ = ctx.sendString(ctx.bodyString())
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        try {
            waitForShellReady(app, port)
            let rejected = runSocketServerEngineShellClient(
                "127.0.0.1",
                port,
                "POST /body-limit HTTP/1.1\r\nHost: example.com\r\nContent-Length: 5\r\n\r\nabcde"
            )
            let accepted = runSocketServerEngineShellClient(
                "127.0.0.1",
                port,
                "POST /body-limit HTTP/1.1\r\nHost: example.com\r\nContent-Length: 4\r\n\r\nabcd"
            )

            @Assert(socketH1RuntimeBaselineContains(rejected, "HTTP/1.1 413 Payload Too Large"), true)
            @Assert(socketH1RuntimeBaselineContains(rejected, "\r\n\r\nPayload Too Large"), true)
            @Assert(socketH1RuntimeBaselineContains(accepted, "HTTP/1.1 200 OK"), true)
            @Assert(socketH1RuntimeBaselineContains(accepted, "\r\n\r\nabcd"), true)
        } finally {
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }

    @TestCase
    public func testDefaultNativeH1Returns413ForAccumulatedChunkedBodyAndKeepsServing(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let app = App(config: Config(
            bodyLimit: 4,
            enableNetworkChangeNotice: false
        ))
        app.post("/chunked-limit", { ctx =>
            let _ = ctx.sendString(ctx.bodyString())
        })
        app.get("/after-chunked-limit", { ctx =>
            let _ = ctx.sendString("alive")
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        try {
            waitForShellReady(app, port)
            let rejected = runSocketServerEngineShellClient(
                "127.0.0.1",
                port,
                "POST /chunked-limit HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\n\r\n3\r\nabc\r\n2\r\nde\r\n0\r\n\r\n"
            )
            let accepted = runSocketServerEngineShellClient(
                "127.0.0.1",
                port,
                "GET /after-chunked-limit HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )

            @Assert(socketH1RuntimeBaselineContains(rejected, "HTTP/1.1 413 Payload Too Large"), true)
            @Assert(socketH1RuntimeBaselineContains(accepted, "HTTP/1.1 200 OK"), true)
            @Assert(socketH1RuntimeBaselineContains(accepted, "\r\n\r\nalive"), true)
        } finally {
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }

    @TestCase
    public func testDefaultNativeH1AppliesHeaderTimeoutWithoutStoppingAcceptLoop(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        var config = Config(enableNetworkChangeNotice: false)
        config.readHeaderTimeout = Duration.millisecond * 100
        let app = App(config: config)
        app.get("/after-header-timeout", { ctx =>
            let _ = ctx.sendString("alive")
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        try {
            waitForShellReady(app, port)
            let stalled = TcpSocket(IPSocketAddress.parse("127.0.0.1:${port}"))
            stalled.connect()
            try {
                stalled.readTimeout = Some(Duration.second)
                stalled.write("GET /never-finished HTTP/1.1\r\nHost: example.com".toArray())
                sleep(Duration.millisecond * 250)
                let buf = Array<UInt8>(16, repeat: 0)
                var closedAfterTimeout = false
                try {
                    closedAfterTimeout = stalled.read(buf) <= 0
                } catch (_: Exception) {
                    closedAfterTimeout = true
                }
                @Assert(closedAfterTimeout, true)
            } finally {
                if (!stalled.isClosed()) {
                    stalled.close()
                }
            }

            let accepted = runSocketServerEngineShellClient(
                "127.0.0.1",
                port,
                "GET /after-header-timeout HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            @Assert(socketH1RuntimeBaselineContains(accepted, "HTTP/1.1 200 OK"), true)
            @Assert(socketH1RuntimeBaselineContains(accepted, "\r\n\r\nalive"), true)
        } finally {
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }

    @TestCase
    public func testDefaultNativeH1StreamsFirstChunkBeforeInputCompletes(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let stream = SocketH1RuntimeBaselineDelayedStream()
        let app = App(config: Config(enableNetworkChangeNotice: false))
        app.get("/delayed-stream", { ctx =>
            let _ = ctx.sendStream(
                stream,
                contentType: "text/plain; charset=utf-8"
            )
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        try {
            waitForShellReady(app, port)
            let socket = TcpSocket(IPSocketAddress.parse("127.0.0.1:${port}"))
            socket.connect()
            try {
                socket.readTimeout = Some(Duration.second)
                socket.write(
                    "GET /delayed-stream HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n".toArray()
                )
                let firstWire = readSocketH1RuntimeBaselineUntil(
                    socket,
                    "first-",
                    Duration.second
                )
                @Assert(socketH1RuntimeBaselineContains(firstWire, "HTTP/1.1 200 OK"), true)
                @Assert(socketH1RuntimeBaselineContains(firstWire, "transfer-encoding: chunked"), true)
                @Assert(socketH1RuntimeBaselineContains(firstWire, "first-"), true)
                @Assert(socketH1RuntimeBaselineContains(firstWire, "second"), false)
                @Assert(stream.closed, false)

                stream.release()
                let remainingWire = readSocketServerEngineShellResponseWire(socket)
                @Assert(socketH1RuntimeBaselineContains(remainingWire, "second"), true)
                @Assert(stream.closed, true)
            } finally {
                stream.release()
                if (!socket.isClosed()) {
                    socket.close()
                }
            }
        } finally {
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }

    @TestCase
    public func testDefaultNativeH1WritesExact64KiBBufferedResponse(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let payload = socketH1RuntimeBaselineRepeatedBody("0123456789abcdef", 4096)
        let app = App(config: Config(enableNetworkChangeNotice: false))
        app.get("/buffered-64k", { ctx =>
            let _ = ctx.sendString(payload)
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        try {
            waitForShellReady(app, port)
            let response = runSocketServerEngineShellClient(
                "127.0.0.1",
                port,
                "GET /buffered-64k HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n"
            )

            @Assert(socketH1RuntimeBaselineContains(response, "HTTP/1.1 200 OK"), true)
            @Assert(socketH1RuntimeBaselineContains(response, "content-length: 65536"), true)
            @Assert(response.endsWith(payload), true)
        } finally {
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }

    @TestCase
    public func testDefaultNativeH1ClonesCallerOwnedResponseBytes(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let app = App(config: Config(enableNetworkChangeNotice: false))
        app.get("/caller-owned-bytes", { ctx =>
            let bytes = "safe".toArray()
            let _ = ctx.send(bytes)
            bytes[0] = UInt8(88)
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        try {
            waitForShellReady(app, port)
            let response = runSocketServerEngineShellClient(
                "127.0.0.1",
                port,
                "GET /caller-owned-bytes HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n"
            )

            @Assert(socketH1RuntimeBaselineContains(response, "content-length: 4"), true)
            @Assert(response.endsWith("safe"), true)
        } finally {
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }

    @TestCase
    public func testPreparedResponseBodyOwnsCallerBytes(): Unit {
        let source = "safe".toArray()
        let prepared = PreparedResponseBody(source)
        source[0] = UInt8(88)

        let firstCopy = prepared.copyBytes()
        @Assert(String.fromUtf8(firstCopy), "safe")
        firstCopy[0] = UInt8(89)
        @Assert(String.fromUtf8(prepared.copyBytes()), "safe")
    }

    @TestCase
    public func testDefaultNativeH1ReusesPrepared64KiBBodyAcrossConcurrentConnections(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let payload = socketH1RuntimeBaselineRepeatedBody("0123456789abcdef", 4096)
        let prepared = PreparedResponseBody(payload)
        let app = App(config: Config(enableNetworkChangeNotice: false))
        app.get("/prepared-64k", { ctx =>
            let _ = ctx.sendPrepared(prepared)
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        try {
            waitForShellReady(app, port)
            let clients = ArrayList<Future<String>>()
            for (_ in 0..16) {
                clients.add(spawn {
                    runSocketServerEngineShellClient(
                        "127.0.0.1",
                        port,
                        "GET /prepared-64k HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n"
                    )
                })
            }
            for (client in clients) {
                let response = client.get(Duration.second * 5)
                @Assert(socketH1RuntimeBaselineContains(response, "content-length: 65536"), true)
                @Assert(response.endsWith(payload), true)
            }
        } finally {
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }

    @TestCase
    public func testDefaultNativeH1ContainsAmbiguousHostWithoutStoppingListener(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let observation = SocketH1RuntimeBaselineMiddlewareObservation()
        let app = App(config: Config(enableNetworkChangeNotice: false))
        app.get("/authority-safe", { ctx =>
            let _ = ctx.sendString(observation.nextLiveBody())
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        try {
            waitForShellReady(app, port)
            let missingHostResponse = runSocketServerEngineShellClient(
                "127.0.0.1",
                port,
                "GET /authority-safe HTTP/1.1\r\nConnection: close\r\n\r\n"
            )
            let duplicateHostResponse = runSocketServerEngineShellClient(
                "127.0.0.1",
                port,
                "GET /authority-safe HTTP/1.1\r\nHost: first.example\r\nHost: second.example\r\nConnection: close\r\n\r\n"
            )
            @Assert(
                missingHostResponse,
                "HTTP/1.1 400 Bad Request\r\nContent-Length: 0\r\nConnection: close\r\n\r\n"
            )
            @Assert(
                duplicateHostResponse,
                "HTTP/1.1 400 Bad Request\r\nContent-Length: 0\r\nConnection: close\r\n\r\n"
            )
            @Assert(observation.handlerRuns(), 0)

            let validResponse = runSocketServerEngineShellClient(
                "127.0.0.1",
                port,
                "GET /authority-safe HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n"
            )
            @Assert(socketH1RuntimeBaselineContains(validResponse, "HTTP/1.1 200 OK"), true)
            @Assert(validResponse.endsWith("live-body-1"), true)
            @Assert(observation.handlerRuns(), 1)
        } finally {
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }
}

func socketH1RuntimeBaselineRepeatedBody(part: String, count: Int64): String {
    var out = ""
    for (_ in 0..count) {
        out += part
    }
    out
}

func waitForSocketH1RuntimeBaselineGate(gate: SocketH1RuntimeBaselineGate): Unit {
    var attempts: Int64 = 0
    while (attempts < 100) {
        if (gate.isEntered()) {
            return
        }
        sleep(Duration.millisecond * 10)
        attempts += 1
    }
    @Fail("timed out waiting for slow native H1 handler to start")
}

func socketH1RuntimeBaselineContains(text: String, target: String): Bool {
    let input = text.toRuneArray()
    let expected = target.toRuneArray()
    if (expected.size == 0) {
        return true
    }
    if (input.size < expected.size) {
        return false
    }
    var start: Int64 = 0
    while (start <= input.size - expected.size) {
        var matched = true
        var offset: Int64 = 0
        while (offset < expected.size) {
            if (input[start + offset] != expected[offset]) {
                matched = false
                break
            }
            offset += 1
        }
        if (matched) {
            return true
        }
        start += 1
    }
    false
}

func readSocketH1RuntimeBaselineUntil(
    socket: TcpSocket,
    target: String,
    timeout: Duration
): String {
    let startedAt = MonoTime.now()
    let out = ArrayList<UInt8>()
    let buf = Array<UInt8>(4096, repeat: 0)
    while ((MonoTime.now() - startedAt) < timeout) {
        let n = socket.read(buf)
        if (n <= 0) {
            break
        }
        var i: Int64 = 0
        while (i < n) {
            out.add(buf[i])
            i += 1
        }
        let text = String.fromUtf8(out.toArray())
        if (socketH1RuntimeBaselineContains(text, target)) {
            return text
        }
    }
    String.fromUtf8(out.toArray())
}
