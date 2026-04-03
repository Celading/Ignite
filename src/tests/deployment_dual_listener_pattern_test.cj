package ignite.tests

import ignite.*
import stdx.net.http.HttpRequestDistributor

let DUAL_TLS_CERT_A = "_helper/testdata/tls/server-cert-a.pem"
let DUAL_TLS_KEY_A = "_helper/testdata/tls/server-key-a.pem"

@Test
public class DeploymentDualListenerPatternTestSuite {
    @TestCase
    public func testHttpRedirectAppKeepsRedirectRoutingContract(): Unit {
        let httpApp = buildHttpRedirectApp("127.0.0.1", UInt16(18443))

        let rootResult = httpApp.router.matchRoute("GET", "/")
        let healthResult = httpApp.router.matchRoute("GET", "/health")
        let nestedResult = httpApp.router.matchRoute("GET", "/api/v1/users")

        @Assert(rootResult.matched, true)
        @Assert(healthResult.matched, true)
        @Assert(nestedResult.matched, true)
        @Assert(httpApp.config.tlsCertFile, "")
        @Assert(httpApp.config.tlsKeyFile, "")

        match (rootResult.route) {
            case Some(route) => @Assert(route.path, "/")
            case None => throw Exception("expected root redirect route")
        }
        match (healthResult.route) {
            case Some(route) => @Assert(route.path, "/*")
            case None => throw Exception("expected catch-all redirect route")
        }
        match (nestedResult.route) {
            case Some(route) => @Assert(route.path, "/*")
            case None => throw Exception("expected nested catch-all redirect route")
        }
    }

    @TestCase
    public func testSeparateHttpAndHttpsAppsCarryIndependentListenOptions(): Unit {
        let httpEngine = DeploymentSpyServerEngine()
        let httpsEngine = DeploymentSpyServerEngine()

        let httpApp = buildHttpRedirectApp("127.0.0.1", UInt16(18443))
        let httpsApp = buildHttpsServiceApp(DUAL_TLS_CERT_A, DUAL_TLS_KEY_A)

        httpApp.serverEngine(httpEngine)
        httpsApp.serverEngine(httpsEngine)

        httpApp.listen("127.0.0.1", UInt16(18080))
        httpsApp.listen("127.0.0.1", UInt16(18443))

        @Assert(httpEngine.listenCalled, true)
        @Assert(httpsEngine.listenCalled, true)
        @Assert(httpEngine.lastPort, UInt16(18080))
        @Assert(httpsEngine.lastPort, UInt16(18443))
        @Assert(httpEngine.lastTlsCertFile, "")
        @Assert(httpEngine.lastTlsKeyFile, "")
        @Assert(httpsEngine.lastTlsCertFile, DUAL_TLS_CERT_A)
        @Assert(httpsEngine.lastTlsKeyFile, DUAL_TLS_KEY_A)
        @Assert(httpEngine.readyCalled, true)
        @Assert(httpsEngine.readyCalled, true)
    }
}

func buildHttpRedirectApp(httpsHost: String, httpsPort: UInt16): App {
    let app = App(config: Config(appName: "ignite-http-redirect"))
    app.get("/*", { ctx =>
        let target = "https://${httpsHost}:${httpsPort}${ctx.path}"
        ctx.redirect(target, code: 307)
    })
    app.get("/", { ctx =>
        let target = "https://${httpsHost}:${httpsPort}/"
        ctx.redirect(target, code: 307)
    })
    app
}

func buildHttpsServiceApp(certFile: String, keyFile: String): App {
    let app = App(config: Config(
        appName: "ignite-https-service",
        tlsCertFile: certFile,
        tlsKeyFile: keyFile,
        enableTlsPrecheck: false
    ))
    app.get("/", { ctx =>
        _ = ctx.sendString("dual-listener-ok")
    })
    app.get("/health", { ctx =>
        _ = ctx.json(#"{"ok":true,"scheme":"https"}"#)
    })
    app
}

class DeploymentSpyServerEngine <: ServerEngine {
    var listenCalled: Bool = false
    var readyCalled: Bool = false
    var lastPort: UInt16 = 0
    var lastTlsCertFile: String = ""
    var lastTlsKeyFile: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        distributor: HttpRequestDistributor,
        onReady: ?(() -> Unit)
    ): Unit {
        let _ = distributor
        listenCalled = true
        lastPort = option.port
        lastTlsCertFile = option.tlsCertFile
        lastTlsKeyFile = option.tlsKeyFile
        if (let Some(cb) <- onReady) {
            cb()
            readyCalled = true
        }
    }

    public override func shutdown(): Unit {}
}
