package ignite.tests

import ignite.*
import std.net.{IPSocketAddress, TcpSocket}

@Test
public class ServerRuntimeObservabilityTestSuite {
    @TestCase
    public func testTypedServerBackendPolicyOverridesLegacyHintCompatibly(): Unit {
        let stdx = buildAppServerEngineSelectionPolicyDecision(
            Config(
                serverPreferredBackendHint: "native-h1",
                allowExperimentalServerBackend: true,
                serverBackendPolicy: ServerBackendPolicy.Stdx
            )
        )
        @Assert(stdx.selectedEngineId, "stdx-http-server")
        @Assert(stdx.selectedReason, "explicit-stdx-backend-hint")

        let native = buildAppServerEngineSelectionPolicyDecision(
            Config(
                serverPreferredBackendHint: "stdx-default",
                serverBackendPolicy: ServerBackendPolicy.NativeH1
            )
        )
        @Assert(native.selectedEngineId, "ignite-native-h1")
        @Assert(native.selectedReason, "explicit-native-h1-backend-hint")

        let auto = App(config: Config(serverBackendPolicy: ServerBackendPolicy.Auto))
            .serverRuntimeSnapshot()
        @Assert(auto.requestedPolicy, "auto")
        @Assert(auto.selectedBackend, "ignite-native-h1")
        @Assert(auto.metricsAvailable, true)
        @Assert(auto.metricsScope, "native-h1-cleartext")
        @Assert(auto.counters.requestQueueDepth, Int64(0))
        @Assert(auto.toJson().contains("\"selectedBackend\":\"ignite-native-h1\""), true)

        let tlsFallback = App(config: Config(
            tlsCertFile: "cert.pem",
            tlsKeyFile: "key.pem",
            serverBackendPolicy: ServerBackendPolicy.NativeH1
        )).serverRuntimeSnapshot()
        @Assert(tlsFallback.requestedPolicy, "native-h1")
        @Assert(tlsFallback.selectedBackend, "stdx-http-server")
        @Assert(tlsFallback.selectedReason, "tls-provider-gap-default-stdx")
        @Assert(tlsFallback.fallbackReason, "tls-provider-gap-default-stdx")
        @Assert(tlsFallback.metricsAvailable, false)
        @Assert(tlsFallback.metricsScope, "unavailable")
    }

    @TestCase
    public func testNativeH1RuntimeCountersTrackKeepAliveCompletionAndRejection(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let app = App(config: Config(
            bodyLimit: 4,
            enableNetworkChangeNotice: false
        ))
        app.get("/runtime-observe", { ctx =>
            let _ = ctx.sendString("one")
        })
        app.post("/runtime-observe", { ctx =>
            let _ = ctx.sendString(ctx.bodyString())
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        try {
            waitForShellReady(app, port)
            let socket = TcpSocket(IPSocketAddress.parse("127.0.0.1:${port}"))
            socket.connect()
            try {
                socket.readTimeout = Some(Duration.second)
                socket.write(
                    "GET /runtime-observe HTTP/1.1\r\nHost: example.com\r\nConnection: keep-alive\r\n\r\n".toArray()
                )
                let first = readSocketH1RuntimeBaselineUntil(
                    socket,
                    "\r\n\r\none",
                    Duration.second
                )
                @Assert(first.contains("HTTP/1.1 200 OK"), true)

                let waiting = waitForServerRuntimeSnapshot(
                    app,
                    1,
                    1,
                    1,
                    0
                )
                @Assert(waiting.selectedBackend, "ignite-native-h1")
                @Assert(waiting.selectedReason, "native_h1_default_selected")
                @Assert(waiting.counters.inFlightRequests, Int64(0))

                socket.write(
                    "GET /runtime-observe HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n".toArray()
                )
                let second = readSocketServerEngineShellResponseWire(socket)
                @Assert(second.contains("HTTP/1.1 200 OK"), true)
            } finally {
                if (!socket.isClosed()) {
                    socket.close()
                }
            }

            let settled = waitForServerRuntimeSnapshot(app, 0, 0, 2, 0)
            @Assert(settled.counters.startedRequests, Int64(2))
            @Assert(settled.counters.completedRequests, Int64(2))

            let rejected = runSocketServerEngineShellClient(
                "127.0.0.1",
                port,
                "POST /runtime-observe HTTP/1.1\r\nHost: example.com\r\nContent-Length: 5\r\nConnection: close\r\n\r\nabcde"
            )
            @Assert(rejected.contains("HTTP/1.1 413 Payload Too Large"), true)

            let finalSnapshot = waitForServerRuntimeSnapshot(app, 0, 0, 2, 1)
            // The readiness probe is allowed to observe the listener without
            // becoming a server-owned accepted connection.
            @Assert(finalSnapshot.counters.acceptedConnections >= 2, true)
            @Assert(finalSnapshot.counters.startedRequests, Int64(3))
            @Assert(finalSnapshot.counters.inFlightRequests, Int64(0))
            @Assert(finalSnapshot.counters.rejectedRequests, Int64(1))
            @Assert(finalSnapshot.counters.requestQueueDepth, Int64(0))
        } finally {
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }
}

func waitForServerRuntimeSnapshot(
    app: App,
    activeConnections: Int64,
    activeKeepAliveConnections: Int64,
    minimumCompletedRequests: Int64,
    minimumRejectedRequests: Int64
): ServerRuntimeSnapshot {
    var attempts: Int64 = 0
    var snapshot = app.serverRuntimeSnapshot()
    while (attempts < 200) {
        snapshot = app.serverRuntimeSnapshot()
        if (
            snapshot.counters.activeConnections == activeConnections &&
            snapshot.counters.activeKeepAliveConnections == activeKeepAliveConnections &&
            snapshot.counters.completedRequests >= minimumCompletedRequests &&
            snapshot.counters.rejectedRequests >= minimumRejectedRequests
        ) {
            return snapshot
        }
        sleep(Duration.millisecond * 5)
        attempts += 1
    }
    snapshot
}
