package ignite.tests

import ignite.*
import ignite.client.*
import std.io.InputStream
import std.net.{IPSocketAddress, TcpServerSocket}
import std.sync.Mutex

class NativeH1ClientTestStream <: InputStream & Resource {
    let body = "chunked-native-client".toArray()
    var offset: Int64 = 0
    var closed: Bool = false

    public override func read(outBuf: Array<Byte>): Int64 {
        if (offset >= body.size || outBuf.size == 0) {
            return 0
        }
        let remaining = body.size - offset
        let count = if (remaining < 5) { remaining } else { 5 }
        var i: Int64 = 0
        while (i < count) {
            outBuf[i] = body[offset + i]
            i += 1
        }
        offset += count
        count
    }

    public func close(): Unit {
        closed = true
    }

    public func isClosed(): Bool {
        closed
    }
}

class NativeH1ClientDelayedStream <: InputStream & Resource {
    let mtx = Mutex()
    var turn: Int64 = 0
    var released: Bool = false
    var closed: Bool = false

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
        var i: Int64 = 0
        while (i < bytes.size) {
            outBuf[i] = bytes[i]
            i += 1
        }
        bytes.size
    }
}

class NativeH1ClientGeneratedRequestStream <: InputStream {
    let totalSize: Int64
    var offset: Int64 = 0
    var readCount: Int64 = 0

    init(totalSize: Int64) {
        this.totalSize = totalSize
    }

    public override func read(outBuf: Array<Byte>): Int64 {
        if (offset >= totalSize || outBuf.size == 0) {
            return 0
        }
        let remaining = totalSize - offset
        let count = if (remaining < outBuf.size) { remaining } else { outBuf.size }
        var i: Int64 = 0
        while (i < count) {
            outBuf[i] = UInt8((offset + i) % 251)
            i += 1
        }
        offset += count
        readCount += 1
        count
    }
}

@Test
public class NativeH1ClientTestSuite {
    @TestCase
    public func testExplicitNativeH1ClientPostsToNativeH1Server(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let app = App(config: Config(enableNetworkChangeNotice: false))
        app.post("/native-client", { ctx =>
            let query = if (let Some(value) <- ctx.query("mode")) { value } else { "missing" }
            let marker = if (let Some(value) <- ctx.header("x-native-marker")) { value } else { "missing" }
            let _ = ctx.status(201).sendString(query + ":" + marker + ":" + ctx.bodyString())
        })
        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        let client = nativeH1TestClient()
        try {
            waitForShellReady(app, port)
            let response = client.request()
                .method("POST")
                .url("http://127.0.0.1:${port}/native-client")
                .query("mode", "wire")
                .header("x-native-marker", "yes")
                .body("payload")
                .send()

            @Assert(response.status, 201)
            @Assert(response.body(), "wire:yes:payload")
            @Assert(nativeH1TestHeader(response, "x-ignite-observe-backend-id"), "ignite-native-h1-client")
            @Assert(nativeH1TestHeader(response, "x-ignite-observe-public-path"), "experimental-only")
        } finally {
            client.close()
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }

    @TestCase
    public func testExplicitNativeH1ClientDecodesChunkedStreamResponse(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let stream = NativeH1ClientTestStream()
        let app = App(config: Config(enableNetworkChangeNotice: false))
        app.get("/native-client-stream", { ctx =>
            let _ = ctx.sendStream(stream, contentType: "text/plain")
        })
        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        let client = nativeH1TestClient()
        try {
            waitForShellReady(app, port)
            let response = client.get("http://127.0.0.1:${port}/native-client-stream")

            @Assert(response.status, 200)
            @Assert(response.body(), "chunked-native-client")
            @Assert(stream.closed, true)
            @Assert(nativeH1TestHeader(response, "transfer-encoding").toAsciiLower(), "chunked")
        } finally {
            client.close()
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }

    @TestCase
    public func testExplicitNativeH1ClientAppliesReadTimeoutAndKeepsServerUsable(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let app = App(config: Config(enableNetworkChangeNotice: false))
        app.get("/native-client-slow", { ctx =>
            sleep(Duration.millisecond * 300)
            let _ = ctx.sendString("late")
        })
        app.get("/native-client-after-timeout", { ctx =>
            let _ = ctx.sendString("alive")
        })
        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        let shortClient = RestClient(
            readTimeout: Duration.millisecond * 80,
            writeTimeout: Duration.second,
            poolSize: 1
        )
            .allowExperimentalTransport()
            .preferTransportBackend("ignite-native-h1-client")
        let followUpClient = nativeH1TestClient()
        try {
            waitForShellReady(app, port)
            var timedOut = false
            try {
                let _ = shortClient.get("http://127.0.0.1:${port}/native-client-slow")
            } catch (_: Exception) {
                timedOut = true
            }
            @Assert(timedOut, true)

            let followUp = followUpClient.get("http://127.0.0.1:${port}/native-client-after-timeout")
            @Assert(followUp.status, 200)
            @Assert(followUp.body(), "alive")
        } finally {
            shortClient.close()
            followUpClient.close()
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }

    @TestCase
    public func testExplicitNativeH1ClientReturnsAfterHeadersBeforeStreamCompletes(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let stream = NativeH1ClientDelayedStream()
        let app = App(config: Config(enableNetworkChangeNotice: false))
        app.get("/native-client-delayed-stream", { ctx =>
            let _ = ctx.sendStream(stream, contentType: "text/plain")
        })
        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        let client = nativeH1TestClient()
        try {
            waitForShellReady(app, port)
            let response = client.get("http://127.0.0.1:${port}/native-client-delayed-stream")
            @Assert(response.status, 200)
            @Assert(stream.closed, false)

            stream.release()
            @Assert(response.body(), "first-second")
            @Assert(stream.closed, true)
        } finally {
            stream.release()
            client.close()
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }

    @TestCase
    public func testExplicitNativeH1ClientResponseCanCloseWithoutDrainingBody(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let stream = NativeH1ClientDelayedStream()
        let app = App(config: Config(enableNetworkChangeNotice: false))
        app.get("/native-client-close", { ctx =>
            let _ = ctx.sendStream(stream, contentType: "text/plain")
        })
        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        let client = nativeH1TestClient()
        try {
            waitForShellReady(app, port)
            let response = client.get("http://127.0.0.1:${port}/native-client-close")
            response.close()
            response.close()
            let buf = Array<UInt8>(16, repeat: 0)
            @Assert(response.bodyStream().read(buf), 0)
        } finally {
            stream.release()
            client.close()
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }

    @TestCase
    public func testExplicitNativeH1ClientReusesFullyConsumedSameOriginConnection(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let app = App(config: Config(enableNetworkChangeNotice: false))
        app.get("/native-client-pool", { ctx =>
            let _ = ctx
                .setHeader("x-native-peer", ctx.ip)
                .sendString("pool-ok")
        })
        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        let client = nativeH1TestClient()
        try {
            waitForShellReady(app, port)
            let url = "http://127.0.0.1:${port}/native-client-pool"
            let first = client.get(url)
            let firstPeer = nativeH1TestHeader(first, "x-native-peer")
            @Assert(first.body(), "pool-ok")

            let second = client.get(url)
            let secondPeer = nativeH1TestHeader(second, "x-native-peer")
            @Assert(second.body(), "pool-ok")
            @Assert(firstPeer == "missing", false)
            @Assert(secondPeer, firstPeer)
        } finally {
            client.close()
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }

    @TestCase
    public func testExplicitNativeH1ClientDoesNotPoolExplicitlyClosedUnreadResponse(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let app = App(config: Config(enableNetworkChangeNotice: false))
        app.get("/native-client-no-pool", { ctx =>
            let _ = ctx
                .setHeader("x-native-peer", ctx.ip)
                .sendString("do-not-reuse-unread")
        })
        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        let client = nativeH1TestClient()
        try {
            waitForShellReady(app, port)
            let url = "http://127.0.0.1:${port}/native-client-no-pool"
            let first = client.get(url)
            let firstPeer = nativeH1TestHeader(first, "x-native-peer")
            first.close()

            let second = client.get(url)
            let secondPeer = nativeH1TestHeader(second, "x-native-peer")
            @Assert(second.body(), "do-not-reuse-unread")
            @Assert(firstPeer == "missing", false)
            @Assert(secondPeer == "missing", false)
            @Assert(secondPeer == firstPeer, false)
        } finally {
            client.close()
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }

    @TestCase
    public func testExplicitNativeH1ClientStreamsKnownLengthRequestBody(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let app = App(config: Config(enableNetworkChangeNotice: false))
        app.post("/native-client-request-stream", { ctx =>
            let _ = ctx.sendString(ctx.bodyBytes().size.toString())
        })
        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        let client = nativeH1TestClient()
        let input = NativeH1ClientGeneratedRequestStream(32768)
        try {
            waitForShellReady(app, port)
            let response = client.request()
                .method("POST")
                .url("http://127.0.0.1:${port}/native-client-request-stream")
                .bodyStream(input, 32768)
                .send()
            @Assert(response.status, 200)
            @Assert(response.body(), "32768")
            @Assert(input.readCount > 1, true)
            @Assert(
                nativeH1TestHeader(response, "x-ignite-observe-backend-id"),
                "ignite-native-h1-client"
            )
        } finally {
            client.close()
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }

    @TestCase
    public func testKnownLengthRequestBodyStreamKeepsStdxDefaultCompatible(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let app = App(config: Config(enableNetworkChangeNotice: false))
        app.post("/stdx-client-request-stream", { ctx =>
            let _ = ctx.sendString(ctx.bodyBytes().size.toString())
        })
        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        let client = RestClient(
            readTimeout: Duration.second * 2,
            writeTimeout: Duration.second * 2,
            poolSize: 1
        )
        let input = NativeH1ClientGeneratedRequestStream(16384)
        try {
            waitForShellReady(app, port)
            let response = client.request()
                .method("POST")
                .url("http://127.0.0.1:${port}/stdx-client-request-stream")
                .bodyStream(input, 16384)
                .send()
            @Assert(response.status, 200)
            @Assert(response.body(), "16384")
            @Assert(
                nativeH1TestHeader(response, "x-ignite-observe-backend-id"),
                "stdx-http-client"
            )
        } finally {
            client.close()
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }

    @TestCase
    public func testExplicitNativeH1ClientConsumesInterimResponsesBeforeFinalResponse(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:${port}"))
        listener.bind()
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                let request = Array<UInt8>(4096, repeat: 0)
                let _ = accepted.read(request)
                accepted.write(
                    ("HTTP/1.1 103 Early Hints\r\nLink: </style.css>; rel=preload\r\n\r\n" +
                    "HTTP/1.1 100 Continue\r\n\r\n" +
                    "HTTP/1.1 200 OK\r\nContent-Length: 5\r\nConnection: close\r\n\r\nfinal").toArray()
                )
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }
        let client = nativeH1TestClient()
        try {
            let response = client.get("http://127.0.0.1:${port}/interim")
            @Assert(response.status, 200)
            @Assert(response.body(), "final")
            @Assert(nativeH1TestHeader(response, "link"), "missing")
        } finally {
            client.close()
            try { listener.close() } catch (_: Exception) {}
            let _ = serverFuture.get(Duration.second * 2)
        }
    }

    @TestCase
    public func testExplicitNativeH1ClientRejectsProtocolSwitchAndUsesFreshConnection(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H1 protocol switch test could not reserve loopback port")
        let serverFuture = spawn {
            let upgraded = listener.accept()
            try {
                let request = Array<UInt8>(4096, repeat: 0)
                let _ = upgraded.read(request)
                upgraded.write(
                    ("HTTP/1.1 101 Switching Protocols\r\n" +
                    "Connection: Upgrade\r\nUpgrade: websocket\r\n\r\n" +
                    "upgraded-wire-bytes").toArray()
                )
            } finally {
                try { upgraded.close() } catch (_: Exception) {}
            }

            let valid = listener.accept()
            try {
                let request = Array<UInt8>(4096, repeat: 0)
                let _ = valid.read(request)
                valid.write(
                    ("HTTP/1.1 200 OK\r\nContent-Length: 5\r\n" +
                    "Connection: close\r\n\r\nclean").toArray()
                )
            } finally {
                try { valid.close() } catch (_: Exception) {}
            }
        }
        let client = nativeH1TestClient()
        try {
            var rejected = false
            try {
                let _ = client.get("http://127.0.0.1:${port}/upgrade")
            } catch (e: Exception) {
                rejected = nativeH1TestContains(
                    e.message,
                    "response protocol switch is unsupported"
                )
            }
            @Assert(rejected, true)

            let recovered = client.get("http://127.0.0.1:${port}/valid-after-upgrade")
            @Assert(recovered.status, 200)
            @Assert(recovered.body(), "clean")
        } finally {
            client.close()
            try { listener.close() } catch (_: Exception) {}
            let _ = serverFuture.get(Duration.second * 2)
        }
    }

    @TestCase
    public func testExplicitNativeH1ClientRejectsAmbiguousResponseAndUsesFreshConnection(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H1 response framing test could not reserve loopback port")
        let serverFuture = spawn {
            let ambiguous = listener.accept()
            try {
                let request = Array<UInt8>(4096, repeat: 0)
                let _ = ambiguous.read(request)
                ambiguous.write(
                    ("HTTP/1.1 200 OK\r\nTransfer-Encoding: chunked\r\n" +
                    "Content-Length: 5\r\nConnection: keep-alive\r\n\r\n" +
                    "5\r\nwrong\r\n0\r\n\r\n").toArray()
                )
            } finally {
                try { ambiguous.close() } catch (_: Exception) {}
            }

            let valid = listener.accept()
            try {
                let request = Array<UInt8>(4096, repeat: 0)
                let _ = valid.read(request)
                valid.write(
                    ("HTTP/1.1 200 OK\r\nContent-Length: 5\r\n" +
                    "Connection: close\r\n\r\nclean").toArray()
                )
            } finally {
                try { valid.close() } catch (_: Exception) {}
            }
        }
        let client = nativeH1TestClient()
        try {
            var rejected = false
            try {
                let _ = client.get("http://127.0.0.1:${port}/ambiguous")
            } catch (e: Exception) {
                rejected = nativeH1TestContains(
                    e.message,
                    "mixes Transfer-Encoding and Content-Length"
                )
            }
            @Assert(rejected, true)

            let recovered = client.get("http://127.0.0.1:${port}/valid")
            @Assert(recovered.status, 200)
            @Assert(recovered.body(), "clean")
        } finally {
            client.close()
            try { listener.close() } catch (_: Exception) {}
            let _ = serverFuture.get(Duration.second * 2)
        }
    }

    @TestCase
    public func testExplicitNativeH1ClientRejectsMalformedResponseHeadAndUsesFreshConnection(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H1 response metadata test could not reserve loopback port")
        let serverFuture = spawn {
            let malformed = listener.accept()
            try {
                let request = Array<UInt8>(4096, repeat: 0)
                let _ = malformed.read(request)
                malformed.write(
                    ("HTTP/1.1 200 OK\r\nMalformed-Field\r\n" +
                    "Content-Length: 5\r\nConnection: keep-alive\r\n\r\nwrong").toArray()
                )
            } finally {
                try { malformed.close() } catch (_: Exception) {}
            }

            let valid = listener.accept()
            try {
                let request = Array<UInt8>(4096, repeat: 0)
                let _ = valid.read(request)
                valid.write(
                    ("HTTP/1.1 200 OK\r\nContent-Length: 5\r\n" +
                    "Connection: close\r\n\r\nclean").toArray()
                )
            } finally {
                try { valid.close() } catch (_: Exception) {}
            }
        }
        let client = nativeH1TestClient()
        try {
            var rejected = false
            try {
                let _ = client.get("http://127.0.0.1:${port}/malformed-head")
            } catch (e: Exception) {
                rejected = nativeH1TestContains(
                    e.message,
                    "response header line is malformed"
                )
            }
            @Assert(rejected, true)

            let recovered = client.get("http://127.0.0.1:${port}/valid-head")
            @Assert(recovered.status, 200)
            @Assert(recovered.body(), "clean")
        } finally {
            client.close()
            try { listener.close() } catch (_: Exception) {}
            let _ = serverFuture.get(Duration.second * 2)
        }
    }

    @TestCase
    public func testExplicitNativeH1ClientRejectsMalformedTrailerAndUsesFreshConnection(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H1 response trailer test could not reserve loopback port")
        let serverFuture = spawn {
            let malformed = listener.accept()
            try {
                let request = Array<UInt8>(4096, repeat: 0)
                let _ = malformed.read(request)
                malformed.write(
                    ("HTTP/1.1 200 OK\r\nTransfer-Encoding: chunked\r\n" +
                    "Connection: keep-alive\r\n\r\n5\r\nwrong\r\n0\r\n" +
                    "Malformed-Trailer\r\n\r\n").toArray()
                )
            } finally {
                try { malformed.close() } catch (_: Exception) {}
            }

            let valid = listener.accept()
            try {
                let request = Array<UInt8>(4096, repeat: 0)
                let _ = valid.read(request)
                valid.write(
                    ("HTTP/1.1 200 OK\r\nTransfer-Encoding: chunked\r\n" +
                    "Connection: close\r\n\r\n5\r\nclean\r\n0\r\n" +
                    "X-Valid-Trailer: yes\r\n\r\n").toArray()
                )
            } finally {
                try { valid.close() } catch (_: Exception) {}
            }
        }
        let client = nativeH1TestClient()
        try {
            var rejected = false
            try {
                let response = client.get("http://127.0.0.1:${port}/malformed-trailer")
                let _ = response.body()
            } catch (e: Exception) {
                rejected = nativeH1TestContains(
                    e.message,
                    "response trailer line is malformed"
                )
            }
            @Assert(rejected, true)

            let recovered = client.get("http://127.0.0.1:${port}/valid-after-trailer")
            @Assert(recovered.status, 200)
            @Assert(recovered.body(), "clean")
        } finally {
            client.close()
            try { listener.close() } catch (_: Exception) {}
            let _ = serverFuture.get(Duration.second * 2)
        }
    }

    @TestCase
    public func testExplicitNativeH1ClientUsesBracketedIpv6AuthorityOnWire(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("[::1]:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H1 IPv6 test could not reserve loopback port")
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                let request = Array<UInt8>(4096, repeat: 0)
                let n = accepted.read(request)
                let requestText = String.fromUtf8(nativeH1TestByteSlice(request, n))
                let expectedHost = "Host: [::1]:${port}\r\n"
                let body = if (nativeH1TestContains(requestText, expectedHost)) { "ipv6-ok" } else { "bad-host" }
                accepted.write(
                    ("HTTP/1.1 200 OK\r\nContent-Length: ${body.size}\r\n" +
                    "Connection: close\r\n\r\n" + body).toArray()
                )
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }
        let client = nativeH1TestClient()
        try {
            let response = client.get("http://[::1]:${port}/ipv6")
            @Assert(response.status, 200)
            @Assert(response.body(), "ipv6-ok")
        } finally {
            client.close()
            try { listener.close() } catch (_: Exception) {}
            let _ = serverFuture.get(Duration.second * 2)
        }
    }

    func nativeH1TestClient(): RestClient {
        RestClient(
            readTimeout: Duration.second * 2,
            writeTimeout: Duration.second * 2,
            poolSize: 1
        )
            .allowExperimentalTransport()
            .preferTransportBackend("ignite-native-h1-client")
    }

    func nativeH1TestHeader(response: ClientResponse, name: String): String {
        if (let Some(value) <- response.header(name)) {
            return value
        }
        "missing"
    }
}

func nativeH1TestByteSlice(input: Array<UInt8>, length: Int64): Array<UInt8> {
    let out = Array<UInt8>(length, repeat: 0)
    var i: Int64 = 0
    while (i < length) {
        out[i] = input[i]
        i += 1
    }
    out
}

func nativeH1TestContains(text: String, target: String): Bool {
    let input = text.toRuneArray()
    let expected = target.toRuneArray()
    if (expected.size == 0) {
        return true
    }
    var i: Int64 = 0
    while (i + expected.size <= input.size) {
        var matched = true
        var j: Int64 = 0
        while (j < expected.size) {
            if (input[i + j] != expected[j]) {
                matched = false
                break
            }
            j += 1
        }
        if (matched) {
            return true
        }
        i += 1
    }
    false
}
