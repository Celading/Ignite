package ignite.tests

import ignite.*
import ignite.native_h2.*
import std.net.TcpSocket
import std.sync.AtomicBool

@Test
public class NativeH2ServerEngineTestSuite {
    @TestCase
    public func testAppListenServesConcurrentConnectionsAndMultiplexedStreams(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let ready = AtomicBool(false)
        let app = App(config: Config(enableNetworkChangeNotice: false))
        useExperimentalNativeH2ServerEngine(app)
        app.onStartupObserve({ event =>
            if (event.phase == "ready") {
                ready.store(true)
            }
        })
        app.post("/h2/echo", { ctx =>
            let _ = ctx.sendString(ctx.bodyString())
        })
        app.get("/h2/plain", { ctx =>
            let _ = ctx.sendString("plain")
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        try {
            waitForNativeH2ServerEngineReady(ready)
            let first = spawn {
                runNativeH2ServerEngineBatch(port, [
                    NativeH2ClientRequest(
                        "POST", "http", "localhost", "/h2/echo", body: "one".toArray()
                    ),
                    NativeH2ClientRequest(
                        "POST", "http", "localhost", "/h2/echo", body: "two".toArray()
                    )
                ])
            }
            let second = spawn {
                runNativeH2ServerEngineBatch(port, [
                    NativeH2ClientRequest("GET", "http", "localhost", "/h2/plain")
                ])
            }

            let firstResponses = first.get(Duration.second * 4)
            let secondResponses = second.get(Duration.second * 4)
            @Assert(firstResponses.size, 2)
            @Assert(firstResponses[0].status, UInt16(200))
            @Assert(String.fromUtf8(firstResponses[0].body), "one")
            @Assert(firstResponses[1].status, UInt16(200))
            @Assert(String.fromUtf8(firstResponses[1].body), "two")
            @Assert(secondResponses.size, 1)
            @Assert(secondResponses[0].status, UInt16(200))
            @Assert(String.fromUtf8(secondResponses[0].body), "plain")
        } finally {
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }

    @TestCase
    public func testTlsConfigurationIsRejectedBeforeListen(): Unit {
        let app = App(config: Config(
            tlsCertFile: "unused-cert.pem",
            tlsKeyFile: "unused-key.pem",
            enableNetworkChangeNotice: false
        ))
        useExperimentalNativeH2ServerEngine(app)
        app.listen("127.0.0.1", reserveServerEngineAbstractionLoopbackPort())
        let event = app.lastServerStartupObserveEvent() ??
            throw Exception("Native H2 TLS rejection did not publish a startup event")
        @Assert(event.phase, "failed")
        @Assert(event.tlsEnabled, true)
        @Assert(
            event.message.contains("cleartext prior knowledge only"),
            true
        )
        if (let Some(touchpoint) <- event.transportTouchpoint) {
            @Assert(touchpoint.selectedBackend, "ignite-native-h2")
            @Assert(touchpoint.tlsEnabled, true)
        } else {
            throw Exception("Native H2 TLS rejection did not retain its transport touchpoint")
        }
    }
}

func waitForNativeH2ServerEngineReady(ready: AtomicBool): Unit {
    var attempts: Int64 = 0
    while (!ready.load() && attempts < 400) {
        sleep(Duration.millisecond * 5)
        attempts += 1
    }
    if (!ready.load()) {
        throw Exception("Native H2 ServerEngine did not become ready")
    }
}

func runNativeH2ServerEngineBatch(
    port: UInt16,
    requests: Array<NativeH2ClientRequest>
): Array<NativeH2ClientResponse> {
    let socket = TcpSocket("127.0.0.1", port)
    socket.readTimeout = Some(Duration.second * 3)
    socket.writeTimeout = Some(Duration.second * 3)
    try {
        socket.connect(timeout: Some(Duration.second * 2))
        let connection = NativeH2ClientConnection(socket)
        let responses = connection.sendBatch(requests)
        connection.finish()
        responses
    } finally {
        if (!socket.isClosed()) {
            socket.close()
        }
    }
}
