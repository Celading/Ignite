package ignite.tests

import ignite.*
import ignite.api2
import std.collection.ArrayList
import stdx.net.http.HttpRequestDistributor

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
            case None => @Fail("expected tls failure observe event")
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

class StartupObserveReadyEngine <: ServerEngine {
    public override func listen(
        option: ServerEngineListenOption,
        distributor: HttpRequestDistributor,
        onReady: ?(() -> Unit)
    ): Unit {
        let _ = option
        let _ = distributor
        if (let Some(cb) <- onReady) {
            cb()
        }
    }

    public override func shutdown(): Unit {}
}

class StartupObserveListenFailureEngine <: ServerEngine {
    public override func listen(
        option: ServerEngineListenOption,
        distributor: HttpRequestDistributor,
        onReady: ?(() -> Unit)
    ): Unit {
        let _ = option
        let _ = distributor
        let _ = onReady
        throw Exception("bind failed: address already in use")
    }

    public override func shutdown(): Unit {}
}

class StartupObserveTlsFailureEngine <: ServerEngine {
    public override func listen(
        option: ServerEngineListenOption,
        distributor: HttpRequestDistributor,
        onReady: ?(() -> Unit)
    ): Unit {
        let _ = option
        let _ = distributor
        let _ = onReady
        throw api2.TlsConfigLoadException(
            api2.TlsConfigLoadErrorCode.VerifyFailed,
            "VERIFY_FAILED",
            "tls precheck failed"
        )
    }

    public override func shutdown(): Unit {}
}
