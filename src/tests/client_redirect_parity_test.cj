package ignite.tests

import ignite.*
import ignite.client.*

@Test
public class ClientRedirectParityTestSuite {
    @TestCase
    public func testStdxDefaultFollowsRelativeRedirect(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let app = App(config: Config(enableNetworkChangeNotice: false))
        app.get("/redirect-start", { ctx =>
            ctx.redirect("/redirect-final", code: 302)
        })
        app.get("/redirect-final", { ctx =>
            ctx.sendString("redirect-final")
        })
        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        let client = RestClient(poolSize: 1)
        try {
            waitForShellReady(app, port)
            let response = client.get("http://127.0.0.1:${port}/redirect-start")
            @Assert(response.status, 200)
            @Assert(response.body(), "redirect-final")
        } finally {
            client.close()
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }

    @TestCase
    public func testNativeH1DefaultFollowsRelativeRedirect(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let app = App(config: Config(enableNetworkChangeNotice: false))
        app.get("/redirect-start", { ctx =>
            ctx.redirect("/redirect-final", code: 302)
        })
        app.get("/redirect-final", { ctx =>
            ctx.sendString("native-redirect-final")
        })
        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        let client = RestClient(poolSize: 1)
            .allowExperimentalTransport()
            .preferTransportBackend("ignite-native-h1-client")
        try {
            waitForShellReady(app, port)
            let response = client.get("http://127.0.0.1:${port}/redirect-start")
            @Assert(response.status, 200)
            @Assert(response.body(), "native-redirect-final")
        } finally {
            client.close()
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }

    @TestCase
    public func testNativeH1PreservesBufferedPostBodyAcross307(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let app = App(config: Config(enableNetworkChangeNotice: false))
        app.post("/redirect-post", { ctx =>
            ctx.redirect("/redirect-post-final", code: 307)
        })
        app.post("/redirect-post-final", { ctx =>
            ctx.sendString(ctx.bodyString())
        })
        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        let client = RestClient(poolSize: 1)
            .allowExperimentalTransport()
            .preferTransportBackend("ignite-native-h1-client")
        try {
            waitForShellReady(app, port)
            let response = client.request()
                .method("POST")
                .url("http://127.0.0.1:${port}/redirect-post")
                .body("preserved")
                .send()
            @Assert(response.status, 200)
            @Assert(response.body(), "preserved")
        } finally {
            client.close()
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }

    @TestCase
    public func testNativeH1RejectsOnePassStreamReplayAcross307(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let app = App(config: Config(enableNetworkChangeNotice: false))
        app.post("/redirect-stream", { ctx =>
            ctx.redirect("/redirect-stream-final", code: 307)
        })
        app.post("/redirect-stream-final", { ctx =>
            ctx.sendString("unexpected")
        })
        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        let client = RestClient(poolSize: 1)
            .allowExperimentalTransport()
            .preferTransportBackend("ignite-native-h1-client")
        let input = NativeH1ClientGeneratedRequestStream(1024)
        try {
            waitForShellReady(app, port)
            var rejected = false
            try {
                let _ = client.request()
                    .method("POST")
                    .url("http://127.0.0.1:${port}/redirect-stream")
                    .bodyStream(input, 1024)
                    .send()
            } catch (e: Exception) {
                rejected = e.message == "native H1 cannot replay a one-pass request stream across redirect"
            }
            @Assert(rejected, true)
            @Assert(input.offset, 1024)
        } finally {
            client.close()
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }
}
