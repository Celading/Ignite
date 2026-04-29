package ignite.tests

import ignite.*
import stdx.net.http.HttpRequestDistributor

@Test
public class ServerEngineAbstractionTestSuite {
    @TestCase
    public func testInjectedServerEngineReceivesListenAndShutdown(): Unit {
        let app = App(config: Config(enableTlsPrecheck: false))
        let engine = SpyServerEngine()
        app.serverEngine(engine)

        app.listen("127.0.0.1", 38117)
        app.shutdown()

        @Assert(engine.listenCalled, true)
        @Assert(engine.shutdownCalled, true)
        @Assert(engine.lastAddr, "127.0.0.1")
        @Assert(engine.lastPort, UInt16(38117))
        @Assert(engine.lastEnableTlsPrecheck, false)
        @Assert(engine.readyCalled, true)
        @Assert(engine.receivedDistributor, true)
        match (engine.lastTransportTouchpoint) {
            case Some(touchpoint) =>
                @Assert(touchpoint.selectedBackend, "stdx-http-server")
                @Assert(touchpoint.publicPath, "stable-default")
                @Assert(touchpoint.providerId, "-")
            case None => @Fail("expected server transport touchpoint")
        }
        match (app.lastServerTransportTouchpoint()) {
            case Some(touchpoint) =>
                @Assert(touchpoint.selectedBackend, "stdx-http-server")
                @Assert(touchpoint.publicPath, "stable-default")
                @Assert(touchpoint.providerId, "-")
            case None => @Fail("expected app transport touchpoint snapshot")
        }
    }

    @TestCase
    public func testInjectedServerEngineTracksLatestListenAddressAcrossCalls(): Unit {
        let app = App(config: Config(enableTlsPrecheck: false))
        let engine = SpyServerEngine()
        app.serverEngine(engine)

        app.listen("127.0.0.1", UInt16(38118))
        app.listen("0.0.0.0", UInt16(38119))

        @Assert(engine.listenCalled, true)
        @Assert(engine.lastAddr, "0.0.0.0")
        @Assert(engine.lastPort, UInt16(38119))
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "ready")
                @Assert(event.addr, "0.0.0.0")
                @Assert(event.port, UInt16(38119))
            case None => @Fail("expected latest startup observe event")
        }
    }

    @TestCase
    public func testInjectedServerEngineCanOverrideTransportTouchpointIdentity(): Unit {
        let app = App(config: Config(enableTlsPrecheck: false))
        let engine = TouchpointOverrideServerEngine()
        app.serverEngine(engine)

        app.listen("127.0.0.1", UInt16(38122))

        match (engine.lastTransportTouchpoint) {
            case Some(touchpoint) =>
                @Assert(touchpoint.selectedBackend, "ignite-custom-engine")
                @Assert(touchpoint.publicPath, "opt-in-engine-custom")
                @Assert(touchpoint.riskLevel, "experimental")
                @Assert(touchpoint.fallbackReason, "engine_identity_override")
            case None => @Fail("expected override transport touchpoint")
        }
        match (app.lastServerTransportTouchpoint()) {
            case Some(touchpoint) =>
                @Assert(touchpoint.selectedBackend, "ignite-custom-engine")
                @Assert(touchpoint.publicPath, "opt-in-engine-custom")
                @Assert(touchpoint.riskLevel, "experimental")
                @Assert(touchpoint.fallbackReason, "engine_identity_override")
            case None => @Fail("expected app override transport touchpoint snapshot")
        }
    }

    @TestCase
    public func testSocketServerEngineShellFailureDoesNotBlockLaterEngineSwap(): Unit {
        let app = App(config: Config(enableTlsPrecheck: false))
        app.serverEngine(SocketServerEngineShell())

        app.listen("127.0.0.1", UInt16(38120))

        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "failed")
                @Assert(event.failureCode, "INTERNAL_ERROR")
                @Assert(contains(event.message, "socket server engine shell"), true)
                @Assert(contains(event.message, "not implemented yet"), true)
                match (event.transportTouchpoint) {
                    case Some(touchpoint) =>
                        @Assert(touchpoint.selectedBackend, "ignite-socket-server-shell")
                        @Assert(touchpoint.publicPath, "opt-in-engine-shell")
                        @Assert(touchpoint.riskLevel, "experimental")
                        @Assert(touchpoint.fallbackReason, "runtime_not_implemented")
                    case None => @Fail("expected shell transport touchpoint")
                }
            case None => @Fail("expected shell failure startup observe event")
        }
        match (app.lastServerTransportTouchpoint()) {
            case Some(touchpoint) =>
                @Assert(touchpoint.selectedBackend, "ignite-socket-server-shell")
                @Assert(touchpoint.publicPath, "opt-in-engine-shell")
            case None => @Fail("expected app shell transport touchpoint snapshot")
        }

        let engine = SpyServerEngine()
        app.serverEngine(engine)
        app.listen("127.0.0.1", UInt16(38121))
        app.shutdown()

        @Assert(engine.listenCalled, true)
        @Assert(engine.shutdownCalled, true)
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "ready")
                @Assert(event.port, UInt16(38121))
            case None => @Fail("expected ready observe event after engine swap")
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

class SpyServerEngine <: ServerEngine {
    var listenCalled: Bool = false
    var shutdownCalled: Bool = false
    var readyCalled: Bool = false
    var receivedDistributor: Bool = false
    var lastAddr: String = ""
    var lastPort: UInt16 = 0
    var lastEnableTlsPrecheck: Bool = true
    var lastTransportTouchpoint: ?ServerTransportTouchpoint = None

    public override func listen(
        option: ServerEngineListenOption,
        distributor: HttpRequestDistributor,
        onReady: ?(() -> Unit)
    ): Unit {
        listenCalled = true
        lastAddr = option.addr
        lastPort = option.port
        lastEnableTlsPrecheck = option.enableTlsPrecheck
        lastTransportTouchpoint = option.transportTouchpoint
        let _ = distributor
        receivedDistributor = true
        if (let Some(cb) <- onReady) {
            cb()
            readyCalled = true
        }
    }

    public override func shutdown(): Unit {
        shutdownCalled = true
    }
}

class TouchpointOverrideServerEngine <: ServerEngine & ServerEngineTransportTouchpointOverride {
    var lastTransportTouchpoint: ?ServerTransportTouchpoint = None

    public override func overrideTransportTouchpoint(
        addr: String,
        port: UInt16,
        tlsEnabled: Bool,
        baseTouchpoint: ServerTransportTouchpoint
    ): ServerTransportTouchpoint {
        let _ = addr
        let _ = port
        let _ = tlsEnabled
        ServerTransportTouchpoint(
            "ignite-custom-engine",
            baseTouchpoint.blockedCandidates,
            "ignite-custom-engine",
            "custom_engine_selected",
            baseTouchpoint.providerId,
            "opt-in-engine-custom",
            "experimental",
            baseTouchpoint.tlsEnabled,
            "engine_identity_override"
        )
    }

    public override func listen(
        option: ServerEngineListenOption,
        distributor: HttpRequestDistributor,
        onReady: ?(() -> Unit)
    ): Unit {
        let _ = distributor
        lastTransportTouchpoint = option.transportTouchpoint
        if (let Some(cb) <- onReady) {
            cb()
        }
    }

    public override func shutdown(): Unit {}
}
