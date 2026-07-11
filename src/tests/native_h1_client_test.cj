package ignite.tests

import ignite.*
import ignite.client.*
import std.io.InputStream

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
