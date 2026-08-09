package ignite.client

import ignite.{App, Config, SocketServerEngineShell}
import ignite.native_h2.{
    NativeH2ClientConnection,
    NativeH2ClientRequest,
    nativeTlsH2RuntimeHook
}
import ignite.native_tls.openNativeTls13ClientTransport
import std.collection.ArrayList
import std.net.{IPSocketAddress, TcpServerSocket, TcpSocket}
import ignite.native_tls.{NativeTls13ClientConfig, NativeTls13ClientTransport}
import ignite.transport.{NativeByteTransport, TcpSocketByteTransport}
import jinguissl.live.*

private let NATIVE_TLS_H2_TEST_HOST = "www." + "example.com"

class NativeTlsH2TestFrame {
    let frameType: UInt8
    let flags: UInt8
    let streamId: Int64
    let payload: Array<UInt8>

    init(frameType: UInt8, flags: UInt8, streamId: Int64, payload: Array<UInt8>) {
        this.frameType = frameType
        this.flags = flags
        this.streamId = streamId
        this.payload = payload
    }
}

@Test
public class NativeTlsH2WireInternalTestSuite {
    @TestCase
    public func testSocketServerEngineShellFeedsAcceptedTlsIntoNativeH2Runtime(): Unit {
        let app = App(config: Config(
            enableNetworkChangeNotice: false,
            tlsCertFile: "testdata/native_tls/policy_leaf.pem",
            tlsKeyFile: "testdata/native_tls/policy_leaf_key_pkcs8.pem",
            enableTlsPrecheck: true
        ))
        app.get("/tls-h2-server-slow", { ctx =>
            sleep(Duration.millisecond * 40)
            let _ = ctx
                .setHeader("x-ignite-native-tls-server", "h2")
                .status(202)
                .send(Array<UInt8>(70000, repeat: UInt8(0x73)))
        })
        app.get("/tls-h2-server-fast", { ctx =>
            let _ = ctx
                .setHeader("x-ignite-native-tls-server", "h2")
                .status(203)
                .send(Array<UInt8>(70000, repeat: UInt8(0x66)))
        })
        app.serverEngine(SocketServerEngineShell(
            selectionLabel: "manual-opt-in-native-tls-h2",
            nativeTlsH2RuntimeHook: nativeTlsH2RuntimeHook()
        ))
        let port = reserveNativeTlsH2ServerMainLoopbackPort()
        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        sleep(Duration.millisecond * 120)

        let socket = TcpSocket("127.0.0.1", port)
        socket.connect(timeout: Some(Duration.second * 3))
        socket.readTimeout = Some(Duration.second * 3)
        socket.writeTimeout = Some(Duration.second * 3)
        let handshake = openNativeTls13ClientTransport(
            TcpSocketByteTransport(socket),
            NativeTls13ClientConfig(
                nativeTlsTestText("policy_root.pem"),
                NATIVE_TLS_H2_TEST_HOST,
                intermediatesPemBundle: nativeTlsTestText("policy_intermediate.pem"),
                alpnProtocols: ["h2"],
                requireTargetHostnameMatch: false
            )
        )
        try {
            @Assert(handshake.negotiatedAlpn, "h2")
            let connection = NativeH2ClientConnection(handshake.transport)
            let responses = connection.sendBatch([
                NativeH2ClientRequest(
                    "GET", "https", NATIVE_TLS_H2_TEST_HOST,
                    "/tls-h2-server-slow"
                ),
                NativeH2ClientRequest(
                    "GET", "https", NATIVE_TLS_H2_TEST_HOST,
                    "/tls-h2-server-fast"
                )
            ])
            @Assert(responses.size, 2)
            @Assert(responses[0].status, UInt16(202))
            @Assert(responses[0].header("x-ignite-native-tls-server") ?? "", "h2")
            @Assert(responses[0].body.size, 70000)
            @Assert(responses[0].body[69999], UInt8(0x73))
            @Assert(responses[1].status, UInt16(203))
            @Assert(responses[1].header("x-ignite-native-tls-server") ?? "", "h2")
            @Assert(responses[1].body.size, 70000)
            @Assert(responses[1].body[69999], UInt8(0x66))
            connection.finish()
        } finally {
            handshake.transport.close()
            app.shutdown()
            let _ = serverFuture.get(Duration.second * 3)
        }
    }

    @TestCase
    public func testRestClientCompletesNativeTlsH2WireTurn(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native TLS H2 test could not reserve loopback port")
        let serverFuture = spawn {
            let accepted = listener.accept()
            accepted.readTimeout = Some(Duration.second * 3)
            accepted.writeTimeout = Some(Duration.second * 3)
            try {
                serveNativeTlsH2Fixture(accepted)
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let client = RestClient(
            readTimeout: Duration.second * 3,
            writeTimeout: Duration.second * 3,
            poolSize: 1
        ).preferTransportBackend(NATIVE_H2_CLIENT_BACKEND)
            .useNativeTls(NativeTls13ClientConfig(
                nativeTlsTestText("policy_root.pem"),
                NATIVE_TLS_H2_TEST_HOST,
                intermediatesPemBundle: nativeTlsTestText("policy_intermediate.pem"),
                alpnProtocols: ["h2"],
                requireTargetHostnameMatch: false
            ))
        try {
            let response = client.get("https://127.0.0.1:${port}/tls-h2")
            @Assert(response.status, UInt16(200))
            @Assert(response.header("x-ignite-native-tls") ?? "", "h2")
            @Assert(response.body(), "native-tls-h2-ok")
            let _ = serverFuture.get(Duration.second * 3)
        } finally {
            client.close()
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testRestClientReusesOneNativeTlsH2SessionAfterCompleteBodies(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native TLS H2 reuse test could not reserve loopback port")
        let serverFuture = spawn {
            let accepted = listener.accept()
            accepted.readTimeout = Some(Duration.second * 3)
            accepted.writeTimeout = Some(Duration.second * 3)
            try {
                serveNativeTlsH2ReuseFixture(accepted)
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let client = RestClient(
            readTimeout: Duration.second * 3,
            writeTimeout: Duration.second * 3,
            poolSize: 1
        ).preferTransportBackend(NATIVE_H2_CLIENT_BACKEND)
            .useNativeTls(NativeTls13ClientConfig(
                nativeTlsTestText("policy_root.pem"),
                NATIVE_TLS_H2_TEST_HOST,
                intermediatesPemBundle: nativeTlsTestText("policy_intermediate.pem"),
                alpnProtocols: ["h2"],
                requireTargetHostnameMatch: false
            ))
        try {
            let first = client.get("https://127.0.0.1:${port}/reuse-1")
            @Assert(first.body(), "reuse-h2-1")
            let second = client.get("https://127.0.0.1:${port}/reuse-2")
            @Assert(second.body(), "reuse-h2-2")
            let snapshot = client.nativeTlsRuntimeSnapshot()
            @Assert(snapshot.h2.openedConnections, Int64(1))
            @Assert(snapshot.h2.reusedConnections, Int64(1))
            @Assert(snapshot.h2.idleConnections, Int64(1))
            let _ = serverFuture.get(Duration.second * 3)
        } finally {
            client.close()
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testRestClientExpiresIdleNativeTlsH2SessionBeforeReuse(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native TLS H2 expiry test could not reserve loopback port")
        let serverFuture = spawn {
            for (turn in 1..3) {
                let accepted = listener.accept()
                accepted.readTimeout = Some(Duration.second * 3)
                accepted.writeTimeout = Some(Duration.second * 3)
                try {
                    serveNativeTlsH2SingleTurnFixture(accepted, turn)
                } finally {
                    try { accepted.close() } catch (_: Exception) {}
                }
            }
        }

        let client = RestClient(
            readTimeout: Duration.second * 3,
            writeTimeout: Duration.second * 3,
            poolSize: 1
        ).preferTransportBackend(NATIVE_H2_CLIENT_BACKEND)
            .nativeTlsIdleTimeout(Duration.millisecond * 10)
            .useNativeTls(NativeTls13ClientConfig(
                nativeTlsTestText("policy_root.pem"),
                NATIVE_TLS_H2_TEST_HOST,
                intermediatesPemBundle: nativeTlsTestText("policy_intermediate.pem"),
                alpnProtocols: ["h2"],
                requireTargetHostnameMatch: false
            ))
        try {
            @Assert(client.get("https://127.0.0.1:${port}/retire-1").body(), "retire-h2-1")
            sleep(Duration.millisecond * 30)
            @Assert(client.get("https://127.0.0.1:${port}/retire-2").body(), "retire-h2-2")
            let snapshot = client.nativeTlsRuntimeSnapshot()
            @Assert(snapshot.maxIdleMs, Int64(10))
            @Assert(snapshot.h2.openedConnections, Int64(2))
            @Assert(snapshot.h2.reusedConnections, Int64(0))
            @Assert(snapshot.h2.expiredConnections, Int64(1))
            @Assert(snapshot.h2.idleConnections, Int64(1))
            let _ = serverFuture.get(Duration.second * 3)
        } finally {
            client.close()
            @Assert(client.nativeTlsRuntimeSnapshot().h2.idleConnections, Int64(0))
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testRestClientClosePreventsInFlightNativeTlsH2ReturnToPool(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native TLS H2 close race test could not reserve loopback port")
        let serverFuture = spawn {
            let accepted = listener.accept()
            accepted.readTimeout = Some(Duration.second * 3)
            accepted.writeTimeout = Some(Duration.second * 3)
            try {
                serveNativeTlsH2SingleTurnFixture(accepted, 1)
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }
        let client = RestClient(
            readTimeout: Duration.second * 3,
            writeTimeout: Duration.second * 3,
            poolSize: 1
        ).preferTransportBackend(NATIVE_H2_CLIENT_BACKEND)
            .useNativeTls(NativeTls13ClientConfig(
                nativeTlsTestText("policy_root.pem"),
                NATIVE_TLS_H2_TEST_HOST,
                intermediatesPemBundle: nativeTlsTestText("policy_intermediate.pem"),
                alpnProtocols: ["h2"],
                requireTargetHostnameMatch: false
            ))
        try {
            let response = client.get("https://127.0.0.1:${port}/retire-1")
            client.close()
            @Assert(response.body(), "retire-h2-1")
            let snapshot = client.nativeTlsRuntimeSnapshot().h2
            @Assert(snapshot.idleConnections, Int64(0))
            @Assert(snapshot.returnedConnections, Int64(0))
            @Assert(snapshot.retiredConnections, Int64(1))
            let _ = serverFuture.get(Duration.second * 3)
        } finally {
            client.close()
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testRestClientRetiresNativeTlsH2SessionAfterPrematureClose(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native TLS H2 retirement test could not reserve loopback port")
        let serverFuture = spawn {
            for (turn in 1..3) {
                let accepted = listener.accept()
                accepted.readTimeout = Some(Duration.second * 3)
                accepted.writeTimeout = Some(Duration.second * 3)
                try {
                    serveNativeTlsH2SingleTurnFixture(accepted, turn)
                } finally {
                    try { accepted.close() } catch (_: Exception) {}
                }
            }
        }

        let client = RestClient(
            readTimeout: Duration.second * 3,
            writeTimeout: Duration.second * 3,
            poolSize: 1
        ).preferTransportBackend(NATIVE_H2_CLIENT_BACKEND)
            .useNativeTls(NativeTls13ClientConfig(
                nativeTlsTestText("policy_root.pem"),
                NATIVE_TLS_H2_TEST_HOST,
                intermediatesPemBundle: nativeTlsTestText("policy_intermediate.pem"),
                alpnProtocols: ["h2"],
                requireTargetHostnameMatch: false
            ))
        try {
            let first = client.get("https://127.0.0.1:${port}/retire-1")
            first.close()
            @Assert(client.nativeTlsRuntimeSnapshot().h2.retiredConnections, Int64(1))
            let second = client.get("https://127.0.0.1:${port}/retire-2")
            @Assert(second.body(), "retire-h2-2")
            let _ = serverFuture.get(Duration.second * 3)
        } finally {
            client.close()
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testNativeTlsH2SessionMultiplexesOutOfOrderResponses(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native TLS H2 multiplex test could not reserve loopback port")
        let serverFuture = spawn {
            let accepted = listener.accept()
            accepted.readTimeout = Some(Duration.second * 3)
            accepted.writeTimeout = Some(Duration.second * 3)
            try {
                serveNativeTlsH2MultiplexFixture(accepted)
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let client = nativeTlsH2SessionTestClient()
        var session: ?NativeTlsH2Session = None
        try {
            let opened = client.openNativeTlsH2Session(
                "https://127.0.0.1:${port}/", maxConcurrentStreams: 2
            )
            session = Some(opened)
            let firstFuture = spawn {
                opened.send(NativeH2BatchRequest("GET", "/first"))
            }
            waitForNativeTlsH2Streams(opened, 1)
            let secondFuture = spawn {
                opened.send(NativeH2BatchRequest("GET", "/second"))
            }
            waitForNativeTlsH2Streams(opened, 2)

            let second = secondFuture.get(Duration.second * 3)
            @Assert(second.body(), "tls-stream-3")
            let first = firstFuture.get(Duration.second * 3)
            @Assert(first.body(), "tls-stream-1")
            @Assert(opened.activeStreams(), Int64(0))
            opened.close()
            session = None

            let reused = client.openNativeTlsH2Session(
                "https://127.0.0.1:${port}/", maxConcurrentStreams: 1
            )
            let reusedResponse = reused.send(NativeH2BatchRequest("GET", "/reused"))
            @Assert(reusedResponse.body(), "tls-stream-5")
            reused.close()

            let snapshot = client.nativeTlsRuntimeSnapshot().h2
            @Assert(snapshot.openedConnections, Int64(1))
            @Assert(snapshot.reusedConnections, Int64(1))
            @Assert(snapshot.returnedConnections, Int64(2))
            @Assert(snapshot.retiredConnections, Int64(0))
            @Assert(snapshot.idleConnections, Int64(1))
            let _ = serverFuture.get(Duration.second * 3)
        } finally {
            match (session) {
                case Some(value) => value.close()
                case None => ()
            }
            client.close()
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testNativeTlsH2SessionWithActiveLeaseRetiresConnection(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native TLS H2 active lease test could not reserve loopback port")
        let serverFuture = spawn {
            let accepted = listener.accept()
            accepted.readTimeout = Some(Duration.second * 3)
            accepted.writeTimeout = Some(Duration.second * 3)
            try {
                serveNativeTlsH2SingleTurnFixture(accepted, 1)
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let client = nativeTlsH2SessionTestClient()
        try {
            let session = client.openNativeTlsH2Session(
                "https://127.0.0.1:${port}/", maxConcurrentStreams: 2
            )
            let response = session.send(NativeH2BatchRequest("GET", "/active"))
            @Assert(session.activeStreams(), Int64(1))
            session.close()
            response.close()
            let snapshot = client.nativeTlsRuntimeSnapshot().h2
            @Assert(snapshot.openedConnections, Int64(1))
            @Assert(snapshot.returnedConnections, Int64(0))
            @Assert(snapshot.retiredConnections, Int64(1))
            @Assert(snapshot.idleConnections, Int64(0))
            let _ = serverFuture.get(Duration.second * 3)
        } finally {
            client.close()
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testNativeTlsH2SessionAdmissionFailsBeforeNetworkUse(): Unit {
        let disabled = RestClient(poolSize: 1)
            .preferTransportBackend(NATIVE_H2_CLIENT_BACKEND)
            .useNativeTls(nativeTlsH2SessionTestConfig())
        let missingTls = RestClient(poolSize: 1)
            .allowExperimentalTransport()
            .preferTransportBackend(NATIVE_H2_CLIENT_BACKEND)
        try {
            assertNativeTlsH2SessionRejected(
                disabled,
                "https://127.0.0.1:1/",
                "allowExperimentalTransport"
            )
            assertNativeTlsH2SessionRejected(
                missingTls,
                "https://127.0.0.1:1/",
                "requires useNativeTls"
            )
            assertNativeTlsH2SessionRejected(
                nativeTlsH2SessionTestClient(),
                "http://127.0.0.1:1/",
                "requires https://"
            )
        } finally {
            disabled.close()
            missingTls.close()
        }
    }
}

func nativeTlsH2SessionTestConfig(): NativeTls13ClientConfig {
    NativeTls13ClientConfig(
        nativeTlsTestText("policy_root.pem"),
        NATIVE_TLS_H2_TEST_HOST,
        intermediatesPemBundle: nativeTlsTestText("policy_intermediate.pem"),
        alpnProtocols: ["h2"],
        requireTargetHostnameMatch: false
    )
}

func nativeTlsH2SessionTestClient(): RestClient {
    RestClient(
        readTimeout: Duration.second * 3,
        writeTimeout: Duration.second * 3,
        poolSize: 1
    )
        .allowExperimentalTransport()
        .preferTransportBackend(NATIVE_H2_CLIENT_BACKEND)
        .useNativeTls(nativeTlsH2SessionTestConfig())
}

func assertNativeTlsH2SessionRejected(
    client: RestClient,
    origin: String,
    expected: String
): Unit {
    var message = ""
    try {
        let session = client.openNativeTlsH2Session(origin)
        session.close()
    } catch (e: Exception) {
        message = e.message
    } finally {
        client.close()
    }
    @Assert(message.contains(expected), true)
}

func waitForNativeTlsH2Streams(session: NativeTlsH2Session, expected: Int64): Unit {
    for (_ in 0..200) {
        if (session.activeStreams() >= expected) {
            return
        }
        sleep(Duration.millisecond * 5)
    }
    throw Exception("native TLS H2 session did not reach ${expected} active streams")
}

func reserveNativeTlsH2ServerMainLoopbackPort(): UInt16 {
    let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
    listener.bind()
    let port = (listener.localAddress as IPSocketAddress)?.port ??
        throw Exception("native TLS H2 server main test could not reserve loopback port")
    listener.close()
    port
}

func serveNativeTlsH2Fixture(socket: TcpSocket): Unit {
    let tls = openNativeTlsH2FixtureSession(socket)
    let head = nativeTlsH2ReadRequestHead(tls)
    if (head.streamId != 1) {
        throw Exception("native TLS H2 fixture expected stream 1")
    }
    nativeTlsH2WriteResponse(tls, 1, "native-tls-h2-ok")
}

func serveNativeTlsH2ReuseFixture(socket: TcpSocket): Unit {
    serveNativeTlsH2ReuseTurnsFixture(socket, 2)
}

func serveNativeTlsH2ReuseTurnsFixture(socket: TcpSocket, turns: Int64): Unit {
    let tls = openNativeTlsH2FixtureSession(socket)
    for (turn in 1..(turns + 1)) {
        let head = nativeTlsH2ReadRequestHead(tls)
        let expectedStreamId = turn * 2 - 1
        if (head.streamId != expectedStreamId) {
            throw Exception("native TLS H2 reuse fixture received unexpected stream")
        }
        nativeTlsH2WriteResponse(tls, expectedStreamId, "reuse-h2-${turn}")
    }
}

func serveNativeTlsH2SingleTurnFixture(socket: TcpSocket, turn: Int64): Unit {
    let tls = openNativeTlsH2FixtureSession(socket)
    let head = nativeTlsH2ReadRequestHead(tls)
    if (head.streamId != 1) {
        throw Exception("native TLS H2 retirement fixture expected stream 1")
    }
    nativeTlsH2WriteResponse(tls, 1, "retire-h2-${turn}")
}

func serveNativeTlsH2MultiplexFixture(socket: TcpSocket): Unit {
    let tls = openNativeTlsH2FixtureSession(socket)
    let first = nativeTlsH2ReadRequestHead(tls)
    let second = nativeTlsH2ReadRequestHead(tls)
    if (first.streamId != 1 || second.streamId != 3) {
        throw Exception("native TLS H2 multiplex fixture expected streams 1 and 3")
    }
    nativeTlsH2WriteResponse(tls, 3, "tls-stream-3")
    nativeTlsH2WriteResponse(tls, 1, "tls-stream-1")
    let reused = nativeTlsH2ReadRequestHead(tls)
    if (reused.streamId != 5) {
        throw Exception("native TLS H2 multiplex fixture expected reused stream 5")
    }
    nativeTlsH2WriteResponse(tls, 5, "tls-stream-5")
}

func openNativeTlsH2FixtureSession(socket: TcpSocket): NativeTls13ClientTransport {
    let raw = TcpSocketByteTransport(socket)
    let clientHelloRecord = nativeTlsH1ReadRecord(raw)
    let certChain = nativeTlsTestText("policy_leaf.pem") + "\n" +
        nativeTlsTestText("policy_intermediate.pem")
    let policy = ContractTlsHttpNegotiationPolicy(
        requireServerName: true,
        allowedServerNames: [NATIVE_TLS_H2_TEST_HOST],
        alpnPreference: ["h2"]
    )
    let plan = contractPlanHttpServerAttachRequest(
        ContractHttpServerLibraryStartupRequest(
            ContractHttpServerTlsConfigRequest(
                certChain,
                nativeTlsTestText("policy_leaf_key_pkcs8.pem"),
                alpnProtocols: ["h2"],
                requireHttp2Alpn: true
            ),
            aesBackendHint: "shim"
        )
    )
    let startOutcome = contractTryTls13StartIncrementalHttpServerHandshake(
        ContractTls13IncrementalServerStartRequest(
            ContractAcceptedTransportDescriptor("ignite-native-tls-h2-fixture"),
            plan,
            nativeTlsH1IncrementalBytes(32, start: 112),
            policy: policy,
            incomingBytes: clientHelloRecord
        )
    )
    let start = match (startOutcome.result) {
        case Some(value) => value
        case None => throw Exception("native TLS H2 fixture start failed: ${startOutcome.message}")
    }
    for (record in start.records) {
        raw.write(record)
    }
    let finishOutcome = contractTryTls13FinishIncrementalHttpServerHandshake(
        ContractTls13IncrementalServerFinishRequest(
            start.continuation,
            start.continuation.pendingBytes,
            nativeTlsH1ReadRecord(raw)
        )
    )
    let session = match (finishOutcome.runtime) {
        case Some(value) => value.session
        case None => throw Exception("native TLS H2 fixture Finished failed: ${finishOutcome.message}")
    }
    let tls = NativeTls13ClientTransport(raw, session.recordChannel)
    let preface = String.fromUtf8(nativeTlsH2ReadExactly(tls, 24))
    if (preface != "PRI * HTTP/2.0\r\n\r\nSM\r\n\r\n") {
        throw Exception("native TLS H2 fixture received invalid connection preface")
    }
    let clientSettings = nativeTlsH2ReadFrame(tls)
    if (clientSettings.frameType != UInt8(0x4) || clientSettings.streamId != 0) {
        throw Exception("native TLS H2 fixture expected client SETTINGS")
    }
    nativeTlsH2WriteFrame(
        tls,
        NativeTlsH2TestFrame(UInt8(0x4), UInt8(0), 0, Array<UInt8>())
    )
    nativeTlsH2WriteFrame(
        tls,
        NativeTlsH2TestFrame(UInt8(0x4), UInt8(0x1), 0, Array<UInt8>())
    )

    tls
}

func nativeTlsH2ReadRequestHead(tls: NativeByteTransport): NativeTlsH2TestFrame {
    var requestHead: ?NativeTlsH2TestFrame = None
    while (requestHead.isNone()) {
        let frame = nativeTlsH2ReadFrame(tls)
        if (frame.frameType == UInt8(0x1)) {
            requestHead = Some(frame)
        }
    }
    requestHead ?? throw Exception("native TLS H2 fixture request head is missing")
}

func nativeTlsH2WriteResponse(tls: NativeByteTransport, streamId: Int64, body: String): Unit {
    nativeTlsH2WriteFrame(
        tls,
        NativeTlsH2TestFrame(
            UInt8(0x1), UInt8(0x4), streamId,
            nativeTlsH2ResponseHeadBlock()
        )
    )
    nativeTlsH2WriteFrame(
        tls,
        NativeTlsH2TestFrame(
            UInt8(0x0), UInt8(0x1), streamId,
            body.toArray()
        )
    )
}

func nativeTlsH2ResponseHeadBlock(): Array<UInt8> {
    let out = ArrayList<UInt8>()
    out.add(UInt8(0x88))
    out.add(UInt8(0x00))
    let name = "x-ignite-native-tls".toArray()
    out.add(UInt8(name.size))
    for (value in name) { out.add(value) }
    let value = "h2".toArray()
    out.add(UInt8(value.size))
    for (item in value) { out.add(item) }
    out.toArray()
}

func nativeTlsH2ReadFrame(transport: NativeByteTransport): NativeTlsH2TestFrame {
    let header = nativeTlsH2ReadExactly(transport, 9)
    let length =
        (Int64(header[0]) << 16) + (Int64(header[1]) << 8) + Int64(header[2])
    let streamId =
        ((Int64(header[5]) & 0x7f) << 24) +
        (Int64(header[6]) << 16) +
        (Int64(header[7]) << 8) +
        Int64(header[8])
    NativeTlsH2TestFrame(
        header[3], header[4], streamId, nativeTlsH2ReadExactly(transport, length)
    )
}

func nativeTlsH2WriteFrame(
    transport: NativeByteTransport,
    frame: NativeTlsH2TestFrame
): Unit {
    let length = frame.payload.size
    let wire = Array<UInt8>(9 + length, repeat: 0)
    wire[0] = UInt8((length >> 16) & 0xff)
    wire[1] = UInt8((length >> 8) & 0xff)
    wire[2] = UInt8(length & 0xff)
    wire[3] = frame.frameType
    wire[4] = frame.flags
    wire[5] = UInt8((frame.streamId >> 24) & 0x7f)
    wire[6] = UInt8((frame.streamId >> 16) & 0xff)
    wire[7] = UInt8((frame.streamId >> 8) & 0xff)
    wire[8] = UInt8(frame.streamId & 0xff)
    var i: Int64 = 0
    while (i < length) {
        wire[9 + i] = frame.payload[i]
        i += 1
    }
    transport.write(wire)
}

func nativeTlsH2ReadExactly(
    transport: NativeByteTransport,
    length: Int64
): Array<UInt8> {
    let out = Array<UInt8>(length, repeat: 0)
    var offset: Int64 = 0
    while (offset < length) {
        let chunk = Array<UInt8>(length - offset, repeat: 0)
        let count = transport.read(chunk)
        if (count <= 0) {
            throw Exception("native TLS H2 fixture peer closed during read")
        }
        var i: Int64 = 0
        while (i < count) {
            out[offset + i] = chunk[i]
            i += 1
        }
        offset += count
    }
    out
}
