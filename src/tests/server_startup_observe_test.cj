package ignite.tests

import ignite.*
import ignite.api2
import std.collection.ArrayList
import std.net.{IPSocketAddress, TcpServerSocket, TcpSocket}

@Test
public class ServerStartupObserveTestSuite {
    @TestCase
    public func testStartupObserveEmitsReadyEvent(): Unit {
        let app = App(config: Config(enableTlsPrecheck: false))
        let engine = StartupObserveReadyEngine()
        let phases = ArrayList<String>()
        let codes = ArrayList<String>()
        let backends = ArrayList<String>()
        app.serverEngine(engine)
        app.onStartupObserve({ event =>
            phases.add(event.phase)
            codes.add(event.failureCode)
            match (event.transportTouchpoint) {
                case Some(touchpoint) => backends.add(touchpoint.selectedBackend)
                case None => backends.add("-")
            }
        })

        app.listen("127.0.0.1", UInt16(38127))

        @Assert(phases.size, 1)
        @Assert(phases[0], "ready")
        @Assert(codes[0], "-")
        @Assert(backends[0], "stdx-http-server")
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "ready")
                @Assert(event.failureCode, "-")
                @Assert(event.scheme, "http")
                let json = event.toJson()
                @Assert(contains(json, "\"phase\":\"ready\""), true)
                @Assert(contains(json, "\"selectedBackend\":\"stdx-http-server\""), true)
            case None => @Fail("expected startup observe event")
        }
    }

    @TestCase
    public func testStartupObserveEmitsListenFailureEvent(): Unit {
        let app = App(config: Config(enableTlsPrecheck: false))
        let engine = StartupObserveListenFailureEngine()
        let phases = ArrayList<String>()
        let codes = ArrayList<String>()
        let hints = ArrayList<String>()
        app.serverEngine(engine)
        app.onStartupObserve({ event =>
            phases.add(event.phase)
            codes.add(event.failureCode)
            hints.add(event.hint)
        })

        app.listen("127.0.0.1", UInt16(38128))

        @Assert(phases.size, 1)
        @Assert(phases[0], "failed")
        @Assert(codes[0], "ADDRESS_IN_USE")
        @Assert(contains(hints[0], "port is already occupied"), true)
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.failureStage, "listen_startup")
                @Assert(event.igniteErrorCode, "LISTEN_ADDRESS_IN_USE")
                @Assert(event.failureSource, "-")
                let json = event.toJson()
                @Assert(contains(json, "\"failureCode\":\"ADDRESS_IN_USE\""), true)
                @Assert(contains(json, "\"transportTouchpoint\":"), true)
            case None => @Fail("expected listen failure observe event")
        }
    }

    @TestCase
    public func testStartupObserveEmitsTlsFailureEvent(): Unit {
        let app = App(config: Config(
            enableTlsPrecheck: true,
            tlsCertFile: "fake-cert.pem",
            tlsKeyFile: "fake-key.pem"
        ))
        let engine = StartupObserveTlsFailureEngine()
        let phases = ArrayList<String>()
        let codes = ArrayList<String>()
        let sources = ArrayList<String>()
        app.serverEngine(engine)
        app.onStartupObserve({ event =>
            phases.add(event.phase)
            codes.add(event.failureCode)
            sources.add(event.failureSource)
        })

        app.listen("127.0.0.1", UInt16(38129))

        @Assert(phases.size, 1)
        @Assert(phases[0], "failed")
        @Assert(codes[0], "VERIFY_FAILED")
        @Assert(sources[0], "VERIFY_FAILED")
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.scheme, "https")
                @Assert(event.tlsEnabled, true)
                @Assert(event.failureStage, "jinguiSSL_precheck")
                @Assert(event.igniteErrorCode, "TLS_VERIFY_FAILED")
                let json = event.toJson()
                @Assert(contains(json, "\"failureSource\":\"VERIFY_FAILED\""), true)
                @Assert(contains(json, "\"tlsEnabled\":true"), true)
            case None => @Fail("expected tls failure observe event")
        }
    }

    @TestCase
    public func testStartupObserveEmitsSocketServerEngineShellReadyEvent(): Unit {
        let app = App(config: Config(enableTlsPrecheck: false))
        let port = reserveLoopbackPort()
        let phases = ArrayList<String>()
        let codes = ArrayList<String>()
        let backends = ArrayList<String>()
        app.get("/shell-startup-observe", { ctx =>
            let _ = ctx.sendString("shell-startup-observe")
        })
        app.serverEngine(SocketServerEngineShell())
        app.onStartupObserve({ event =>
            phases.add(event.phase)
            codes.add(event.failureCode)
            match (event.transportTouchpoint) {
                case Some(touchpoint) => backends.add(touchpoint.selectedBackend)
                case None => backends.add("-")
            }
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForStartupObserveReadyEvent(app, port)
        let responseText = runStartupObserveShellRequest(
            "127.0.0.1",
            port,
            "GET /shell-startup-observe HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n"
        )
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(phases.size, 1)
        @Assert(phases[0], "ready")
        @Assert(codes[0], "-")
        @Assert(backends[0], "ignite-socket-server-shell")
        @Assert(contains(responseText, "HTTP/1.1 200 OK"), true)
        @Assert(contains(responseText, "shell-startup-observe"), true)
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "ready")
                @Assert(event.failureCode, "-")
                @Assert(event.scheme, "http")
                match (event.transportTouchpoint) {
                    case Some(touchpoint) =>
                        @Assert(touchpoint.selectedBackend, "ignite-socket-server-shell")
                        @Assert(touchpoint.publicPath, "opt-in-engine-shell")
                        @Assert(touchpoint.riskLevel, "experimental")
                        @Assert(touchpoint.fallbackReason, "cleartext_h1_first_runnable")
                    case None => @Fail("expected shell ready transport touchpoint")
                }
                let json = event.toJson()
                @Assert(contains(json, "\"selectedBackend\":\"ignite-socket-server-shell\""), true)
            case None => @Fail("expected socket server engine shell ready event")
        }
    }

    func contains(text: String, target: String): Bool {
        let t = text.toRuneArray()
        let p = target.toRuneArray()
        if (p.size == 0) {
            return true
        }
        if (t.size < p.size) {
            return false
        }
        var i: Int64 = 0
        while (i <= t.size - p.size) {
            var ok = true
            var j: Int64 = 0
            while (j < p.size) {
                if (t[i + j] != p[j]) {
                    ok = false
                    break
                }
                j += 1
            }
            if (ok) {
                return true
            }
            i += 1
        }
        false
    }
}

func waitForStartupObserveReadyEvent(app: App, port: UInt16): Unit {
    var attempts: Int64 = 0
    while (attempts < 100) {
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                if (event.phase == "ready" && event.port == port) {
                    return
                }
            case None => ()
        }
        sleep(Duration.millisecond * 10)
        attempts += 1
    }
    @Fail("timed out waiting for socket server engine shell ready startup observe event")
}

func reserveLoopbackPort(): UInt16 {
    let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
    listener.bind()
    try {
        (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("startup observe test could not reserve loopback port")
    } finally {
        if (!listener.isClosed()) {
            listener.close()
        }
    }
}

func runStartupObserveShellRequest(
    host: String,
    port: UInt16,
    requestWire: String
): String {
    let socket = TcpSocket(IPSocketAddress.parse("${host}:${port}"))
    socket.connect()
    try {
        socket.write(requestWire.toArray())
        readStartupObserveShellResponseWire(socket)
    } finally {
        if (!socket.isClosed()) {
            socket.close()
        }
    }
}

func readStartupObserveShellResponseWire(socket: TcpSocket): String {
    let out = ArrayList<UInt8>()
    let buf = Array<UInt8>(4096, repeat: 0)
    while (true) {
        let n = socket.read(buf)
        if (n <= 0) {
            break
        }
        appendStartupObserveBytes(out, buf[..n])
    }
    String.fromUtf8(out.toArray())
}

func appendStartupObserveBytes(out: ArrayList<UInt8>, bytes: Array<UInt8>): Unit {
    for (b in bytes) {
        out.add(b)
    }
}

class StartupObserveReadyEngine <: ServerEngine {
    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?(() -> Unit)
    ): Unit {
        let _ = option
        let _ = app
        if (let Some(cb) <- onReady) {
            cb()
        }
    }

    public override func shutdown(): Unit {}
}

class StartupObserveListenFailureEngine <: ServerEngine {
    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?(() -> Unit)
    ): Unit {
        let _ = option
        let _ = app
        let _ = onReady
        throw Exception("bind failed: address already in use")
    }

    public override func shutdown(): Unit {}
}

class StartupObserveTlsFailureEngine <: ServerEngine {
    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?(() -> Unit)
    ): Unit {
        let _ = option
        let _ = app
        let _ = onReady
        throw api2.TlsConfigLoadException(
            api2.TlsConfigLoadErrorCode.VerifyFailed,
            "VERIFY_FAILED",
            "tls precheck failed"
        )
    }

    public override func shutdown(): Unit {}
}
