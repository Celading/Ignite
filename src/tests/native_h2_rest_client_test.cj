package ignite.tests

import ignite.*
import ignite.client.*
import ignite.native_h2.useExperimentalNativeH2ServerEngine
import std.collection.ArrayList
import std.sync.{AtomicBool, Mutex}

let NATIVE_H2_REST_CLIENT_BACKEND = "ignite-native-h2-client"

class NativeH2RestClientCounter {
    let mtx = Mutex()
    var value: Int64 = 0

    func next(): Int64 {
        var current: Int64 = 0
        synchronized(mtx) {
            value += 1
            current = value
        }
        current
    }

    func current(): Int64 {
        var currentValue: Int64 = 0
        synchronized(mtx) {
            currentValue = value
        }
        currentValue
    }
}

@Test
public class NativeH2RestClientTestSuite {
    @TestCase
    public func testExplicitBackendCarriesRequestAndObserveSemantics(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let ready = AtomicBool(false)
        let app = nativeH2RestClientApp(ready)
        app.patch("/h2-client", { ctx =>
            let marker = ctx.header("x-h2-client") ?? "missing"
            let _ = ctx.status(202).sendString(marker + ":" + ctx.bodyString())
        })
        let serverFuture = spawn { app.listen("127.0.0.1", port) }
        let client = nativeH2RestClient()
        try {
            waitForNativeH2RestClientReady(ready)
            let response = client.request()
                .method("PATCH")
                .url("http://127.0.0.1:${port}/h2-client")
                .header("x-h2-client", "yes")
                .body("payload")
                .send()
            @Assert(response.status, UInt16(202))
            @Assert(response.body(), "yes:payload")
            @Assert(nativeH2RestHeader(response, "x-ignite-observe-backend-id"), NATIVE_H2_REST_CLIENT_BACKEND)
            @Assert(nativeH2RestHeader(response, "x-ignite-observe-public-path"), "experimental-only")
        } finally {
            client.close()
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }

    @TestCase
    public func testConsumedResponsesReuseSameOriginConnection(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let ready = AtomicBool(false)
        let app = nativeH2RestClientApp(ready)
        app.get("/h2-pool", { ctx =>
            let _ = ctx.setHeader("x-h2-peer", ctx.ip).sendString("pool-ok")
        })
        let serverFuture = spawn { app.listen("127.0.0.1", port) }
        let client = nativeH2RestClient()
        try {
            waitForNativeH2RestClientReady(ready)
            let url = "http://127.0.0.1:${port}/h2-pool"
            let first = client.get(url)
            let firstPeer = nativeH2RestHeader(first, "x-h2-peer")
            @Assert(first.body(), "pool-ok")
            let second = client.get(url)
            let secondPeer = nativeH2RestHeader(second, "x-h2-peer")
            @Assert(second.body(), "pool-ok")
            @Assert(firstPeer == "missing", false)
            @Assert(secondPeer, firstPeer)
        } finally {
            client.close()
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }

    @TestCase
    public func testRetryableStatusUsesNextStreamOnReusableConnection(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let ready = AtomicBool(false)
        let counter = NativeH2RestClientCounter()
        let app = nativeH2RestClientApp(ready)
        app.get("/h2-retry", { ctx =>
            if (counter.next() == 1) {
                let _ = ctx.status(503).sendString("retry")
            } else {
                let _ = ctx.setHeader("x-h2-peer", ctx.ip).sendString("recovered")
            }
        })
        let serverFuture = spawn { app.listen("127.0.0.1", port) }
        let retryStatusCodes = ArrayList<Int64>()
        retryStatusCodes.add(503)
        let client = nativeH2RestClient()
            .useRetry(ClientRetryConfig(
                enabled: true,
                maxAttempts: 2,
                baseDelayMs: 0,
                maxDelayMs: 0,
                jitterMs: 0,
                retryStatusCodes: retryStatusCodes
            ))
        try {
            waitForNativeH2RestClientReady(ready)
            let response = client.get("http://127.0.0.1:${port}/h2-retry")
            @Assert(response.status, UInt16(200))
            @Assert(response.body(), "recovered")
            @Assert(nativeH2RestHeader(response, "x-ignite-observe-retry-count"), "1")
            @Assert(counter.current(), Int64(2))
        } finally {
            client.close()
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }

    @TestCase
    public func testReadTimeoutRetiresConnectionAndPublishesError(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let ready = AtomicBool(false)
        let app = nativeH2RestClientApp(ready)
        app.get("/h2-slow", { ctx =>
            sleep(Duration.millisecond * 250)
            let _ = ctx.sendString("late")
        })
        app.get("/h2-after-timeout", { ctx =>
            let _ = ctx.sendString("alive")
        })
        let serverFuture = spawn { app.listen("127.0.0.1", port) }
        let shortClient = RestClient(
            readTimeout: Duration.millisecond * 60,
            writeTimeout: Duration.second,
            poolSize: 1
        )
            .allowExperimentalTransport()
            .preferTransportBackend(NATIVE_H2_REST_CLIENT_BACKEND)
        let followUp = nativeH2RestClient()
        try {
            waitForNativeH2RestClientReady(ready)
            var message = ""
            try {
                let _ = shortClient.get("http://127.0.0.1:${port}/h2-slow")
            } catch (e: Exception) {
                message = e.message
            }
            @Assert(message.contains("native H2 network read timeout"), true)
            match (shortClient.lastClientObserveSnapshot()) {
                case Some(snapshot) =>
                    @Assert(snapshot.errorClass, "TIMEOUT")
                    @Assert(snapshot.phase, "read")
                case None => @Fail("expected Native H2 timeout observe snapshot")
            }
            let response = followUp.get("http://127.0.0.1:${port}/h2-after-timeout")
            @Assert(response.body(), "alive")
        } finally {
            shortClient.close()
            followUp.close()
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }

    func nativeH2RestClient(): RestClient {
        RestClient(
            readTimeout: Duration.second * 2,
            writeTimeout: Duration.second * 2,
            poolSize: 1
        )
            .allowExperimentalTransport()
            .preferTransportBackend(NATIVE_H2_REST_CLIENT_BACKEND)
    }

    func nativeH2RestClientApp(ready: AtomicBool): App {
        let app = App(config: Config(enableNetworkChangeNotice: false))
        useExperimentalNativeH2ServerEngine(app)
        app.onStartupObserve({ event =>
            if (event.phase == "ready") {
                ready.store(true)
            }
        })
        app
    }

    func waitForNativeH2RestClientReady(ready: AtomicBool): Unit {
        var attempts: Int64 = 0
        while (!ready.load() && attempts < 400) {
            sleep(Duration.millisecond * 5)
            attempts += 1
        }
        if (!ready.load()) {
            throw Exception("Native H2 RestClient fixture did not become ready")
        }
    }

    func nativeH2RestHeader(response: ClientResponse, name: String): String {
        response.header(name) ?? "missing"
    }
}
