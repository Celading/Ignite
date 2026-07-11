package ignite.tests

import ignite.*
import std.net.{IPSocketAddress, TcpSocket}
import std.sync.Mutex
import std.time.MonoTime

class SocketH1RuntimeBaselineGate {
    let mtx = Mutex()
    var entered: Bool = false

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
}

@Test
public class ServerSocketH1RuntimeBaselineTestSuite {
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
