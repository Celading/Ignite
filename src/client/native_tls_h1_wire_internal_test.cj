package ignite.client

import std.collection.ArrayList
import std.fs.File
import std.net.{IPSocketAddress, TcpServerSocket, TcpSocket}
import ignite.native_tls.{NativeTls13ClientConfig, NativeTls13ClientTransport}
import ignite.transport.{NativeByteTransport, TcpSocketByteTransport}
import jinguissl.live.*

private let NATIVE_TLS_H1_TEST_HOST = "www." + "example.com"
private let NATIVE_TLS_TESTDATA_ROOT = "testdata/native_tls/"

@Test
public class NativeTlsH1WireInternalTestSuite {
    @TestCase
    public func testNativeTlsPoolPolicySnapshotDoesNotFollowCallerArrayMutation(): Unit {
        let config = NativeTls13ClientConfig(
            nativeTlsTestText("policy_root.pem"),
            NATIVE_TLS_H1_TEST_HOST,
            intermediatesPemBundle: nativeTlsTestText("policy_intermediate.pem"),
            alpnProtocols: ["http/1.1"],
            requireTargetHostnameMatch: false
        )
        let snapshot = cloneNativeTlsClientConfig(config)

        config.alpnProtocols[0] = "h2"

        @Assert(snapshot.alpnProtocols[0], "http/1.1")
        @Assert(nativeTlsConfigsMatch(snapshot, config), false)
    }

    @TestCase
    public func testRestClientCompletesNativeTlsH1WireTurn(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native TLS H1 test could not reserve loopback port")
        let serverFuture = spawn {
            let accepted = listener.accept()
            accepted.readTimeout = Some(Duration.second * 3)
            accepted.writeTimeout = Some(Duration.second * 3)
            try {
                serveNativeTlsH1Fixture(accepted)
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let client = RestClient(
            readTimeout: Duration.second * 3,
            writeTimeout: Duration.second * 3,
            poolSize: 1
        ).useNativeTls(NativeTls13ClientConfig(
            nativeTlsTestText("policy_root.pem"),
            NATIVE_TLS_H1_TEST_HOST,
            intermediatesPemBundle: nativeTlsTestText("policy_intermediate.pem"),
            alpnProtocols: ["http/1.1"],
            requireTargetHostnameMatch: false
        ))
        try {
            let response = client.get("https://127.0.0.1:${port}/tls-h1")
            @Assert(response.status, UInt16(200))
            @Assert(response.header("x-ignite-native-tls") ?? "", "h1")
            @Assert(response.body(), "native-tls-h1-ok")
            let _ = serverFuture.get(Duration.second * 3)
        } finally {
            client.close()
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testRestClientReusesOneNativeTlsH1SessionAfterCompleteBodies(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native TLS H1 reuse test could not reserve loopback port")
        let serverFuture = spawn {
            let accepted = listener.accept()
            accepted.readTimeout = Some(Duration.second * 3)
            accepted.writeTimeout = Some(Duration.second * 3)
            try {
                serveNativeTlsH1ReuseFixture(accepted)
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let client = RestClient(
            readTimeout: Duration.second * 3,
            writeTimeout: Duration.second * 3,
            poolSize: 1
        ).useNativeTls(NativeTls13ClientConfig(
            nativeTlsTestText("policy_root.pem"),
            NATIVE_TLS_H1_TEST_HOST,
            intermediatesPemBundle: nativeTlsTestText("policy_intermediate.pem"),
            alpnProtocols: ["http/1.1"],
            requireTargetHostnameMatch: false
        ))
        try {
            let first = client.get("https://127.0.0.1:${port}/reuse-1")
            @Assert(first.body(), "reuse-h1-1")
            let second = client.get("https://127.0.0.1:${port}/reuse-2")
            @Assert(second.body(), "reuse-h1-2")
            let snapshot = client.nativeTlsRuntimeSnapshot()
            @Assert(snapshot.h1.openedConnections, Int64(1))
            @Assert(snapshot.h1.reusedConnections, Int64(1))
            @Assert(snapshot.h1.idleConnections, Int64(1))
            let _ = serverFuture.get(Duration.second * 3)
        } finally {
            client.close()
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testRestClientExpiresIdleNativeTlsH1SessionBeforeReuse(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native TLS H1 expiry test could not reserve loopback port")
        let serverFuture = spawn {
            for (turn in 1..3) {
                let accepted = listener.accept()
                accepted.readTimeout = Some(Duration.second * 3)
                accepted.writeTimeout = Some(Duration.second * 3)
                try {
                    serveNativeTlsH1SingleTurnFixture(accepted, turn)
                } finally {
                    try { accepted.close() } catch (_: Exception) {}
                }
            }
        }

        let client = RestClient(
            readTimeout: Duration.second * 3,
            writeTimeout: Duration.second * 3,
            poolSize: 1
        ).nativeTlsIdleTimeout(Duration.millisecond * 10)
            .useNativeTls(NativeTls13ClientConfig(
                nativeTlsTestText("policy_root.pem"),
                NATIVE_TLS_H1_TEST_HOST,
                intermediatesPemBundle: nativeTlsTestText("policy_intermediate.pem"),
                alpnProtocols: ["http/1.1"],
                requireTargetHostnameMatch: false
            ))
        try {
            @Assert(client.get("https://127.0.0.1:${port}/retire-1").body(), "retire-h1-1")
            sleep(Duration.millisecond * 30)
            @Assert(client.get("https://127.0.0.1:${port}/retire-2").body(), "retire-h1-2")
            let snapshot = client.nativeTlsRuntimeSnapshot()
            @Assert(snapshot.maxIdleMs, Int64(10))
            @Assert(snapshot.h1.openedConnections, Int64(2))
            @Assert(snapshot.h1.reusedConnections, Int64(0))
            @Assert(snapshot.h1.expiredConnections, Int64(1))
            @Assert(snapshot.h1.idleConnections, Int64(1))
            @Assert(snapshot.toJson().contains("\"expiredConnections\":1"), true)
            let _ = serverFuture.get(Duration.second * 3)
        } finally {
            client.close()
            @Assert(client.nativeTlsRuntimeSnapshot().h1.idleConnections, Int64(0))
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testNativeTlsIdlePolicyUpdateKeepsInFlightPoolOwner(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native TLS H1 in-flight policy test could not reserve loopback port")
        let serverFuture = spawn {
            for (turn in 1..3) {
                let accepted = listener.accept()
                accepted.readTimeout = Some(Duration.second * 3)
                accepted.writeTimeout = Some(Duration.second * 3)
                try {
                    serveNativeTlsH1SingleTurnFixture(accepted, turn)
                } finally {
                    try { accepted.close() } catch (_: Exception) {}
                }
            }
        }

        let client = RestClient(
            readTimeout: Duration.second * 3,
            writeTimeout: Duration.second * 3,
            poolSize: 1
        ).useNativeTls(NativeTls13ClientConfig(
            nativeTlsTestText("policy_root.pem"),
            NATIVE_TLS_H1_TEST_HOST,
            intermediatesPemBundle: nativeTlsTestText("policy_intermediate.pem"),
            alpnProtocols: ["http/1.1"],
            requireTargetHostnameMatch: false
        ))
        try {
            let first = client.get("https://127.0.0.1:${port}/retire-1")
            let _ = client.nativeTlsIdleTimeout(Duration.millisecond * 10)
            @Assert(first.body(), "retire-h1-1")
            let returned = client.nativeTlsRuntimeSnapshot()
            @Assert(returned.maxIdleMs, Int64(10))
            @Assert(returned.h1.returnedConnections, Int64(1))
            @Assert(returned.h1.idleConnections, Int64(1))

            sleep(Duration.millisecond * 30)
            @Assert(client.get("https://127.0.0.1:${port}/retire-2").body(), "retire-h1-2")
            let expired = client.nativeTlsRuntimeSnapshot().h1
            @Assert(expired.openedConnections, Int64(2))
            @Assert(expired.expiredConnections, Int64(1))
            let _ = serverFuture.get(Duration.second * 3)
        } finally {
            client.close()
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testRestClientClosePreventsInFlightNativeTlsH1ReturnToPool(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native TLS H1 close race test could not reserve loopback port")
        let serverFuture = spawn {
            let accepted = listener.accept()
            accepted.readTimeout = Some(Duration.second * 3)
            accepted.writeTimeout = Some(Duration.second * 3)
            try {
                serveNativeTlsH1SingleTurnFixture(accepted, 1)
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }
        let client = RestClient(
            readTimeout: Duration.second * 3,
            writeTimeout: Duration.second * 3,
            poolSize: 1
        ).useNativeTls(NativeTls13ClientConfig(
            nativeTlsTestText("policy_root.pem"),
            NATIVE_TLS_H1_TEST_HOST,
            intermediatesPemBundle: nativeTlsTestText("policy_intermediate.pem"),
            alpnProtocols: ["http/1.1"],
            requireTargetHostnameMatch: false
        ))
        try {
            let response = client.get("https://127.0.0.1:${port}/retire-1")
            client.close()
            @Assert(response.body(), "retire-h1-1")
            let snapshot = client.nativeTlsRuntimeSnapshot().h1
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
    public func testRestClientRetiresNativeTlsH1SessionAfterPrematureClose(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native TLS H1 retirement test could not reserve loopback port")
        let serverFuture = spawn {
            for (turn in 1..3) {
                let accepted = listener.accept()
                accepted.readTimeout = Some(Duration.second * 3)
                accepted.writeTimeout = Some(Duration.second * 3)
                try {
                    serveNativeTlsH1SingleTurnFixture(accepted, turn)
                } finally {
                    try { accepted.close() } catch (_: Exception) {}
                }
            }
        }

        let client = RestClient(
            readTimeout: Duration.second * 3,
            writeTimeout: Duration.second * 3,
            poolSize: 1
        ).useNativeTls(NativeTls13ClientConfig(
            nativeTlsTestText("policy_root.pem"),
            NATIVE_TLS_H1_TEST_HOST,
            intermediatesPemBundle: nativeTlsTestText("policy_intermediate.pem"),
            alpnProtocols: ["http/1.1"],
            requireTargetHostnameMatch: false
        ))
        try {
            let first = client.get("https://127.0.0.1:${port}/retire-1")
            first.close()
            @Assert(client.nativeTlsRuntimeSnapshot().h1.retiredConnections, Int64(1))
            let second = client.get("https://127.0.0.1:${port}/retire-2")
            @Assert(second.body(), "retire-h1-2")
            let _ = serverFuture.get(Duration.second * 3)
        } finally {
            client.close()
            try { listener.close() } catch (_: Exception) {}
        }
    }
}

func serveNativeTlsH1Fixture(socket: TcpSocket): Unit {
    let tls = openNativeTlsH1FixtureSession(socket)
    let requestHead = nativeTlsH1ReadUntil(tls, "\r\n\r\n".toArray(), 65536)
    if (nativeH1IndexOfBytes(requestHead, "GET /tls-h1 HTTP/1.1".toArray(), 0) < 0) {
        throw Exception("native TLS H1 fixture received unexpected request")
    }
    tls.write(
        "HTTP/1.1 200 OK\r\nContent-Length: 16\r\nX-Ignite-Native-Tls: h1\r\nConnection: close\r\n\r\nnative-tls-h1-ok".toArray()
    )
}

func serveNativeTlsH1ReuseFixture(socket: TcpSocket): Unit {
    serveNativeTlsH1ReuseTurnsFixture(socket, 2)
}

func serveNativeTlsH1ReuseTurnsFixture(socket: TcpSocket, turns: Int64): Unit {
    let tls = openNativeTlsH1FixtureSession(socket)
    for (turn in 1..(turns + 1)) {
        let requestHead = nativeTlsH1ReadUntil(tls, "\r\n\r\n".toArray(), 65536)
        let expected = "GET /reuse-${turn} HTTP/1.1".toArray()
        if (nativeH1IndexOfBytes(requestHead, expected, 0) < 0) {
            throw Exception("native TLS H1 reuse fixture received unexpected request")
        }
        let body = "reuse-h1-${turn}"
        tls.write(
            (
                "HTTP/1.1 200 OK\r\nContent-Length: ${body.toArray().size}\r\n" +
                "Connection: keep-alive\r\n\r\n" + body
            ).toArray()
        )
    }
}

func serveNativeTlsH1SingleTurnFixture(socket: TcpSocket, turn: Int64): Unit {
    let tls = openNativeTlsH1FixtureSession(socket)
    let requestHead = nativeTlsH1ReadUntil(tls, "\r\n\r\n".toArray(), 65536)
    let expected = "GET /retire-${turn} HTTP/1.1".toArray()
    if (nativeH1IndexOfBytes(requestHead, expected, 0) < 0) {
        throw Exception("native TLS H1 retirement fixture received unexpected request")
    }
    tls.write(
        "HTTP/1.1 200 OK\r\nContent-Length: 11\r\nConnection: keep-alive\r\n\r\nretire-h1-${turn}".toArray()
    )
}

func openNativeTlsH1FixtureSession(socket: TcpSocket): NativeTls13ClientTransport {
    let raw = TcpSocketByteTransport(socket)
    let clientHelloRecord = nativeTlsH1ReadRecord(raw)
    let certChain = nativeTlsTestText("policy_leaf.pem") + "\n" +
        nativeTlsTestText("policy_intermediate.pem")
    let policy = ContractTlsHttpNegotiationPolicy(
        requireServerName: true,
        allowedServerNames: [NATIVE_TLS_H1_TEST_HOST],
        alpnPreference: ["http/1.1"]
    )
    let plan = contractPlanHttpServerAttachRequest(
        ContractHttpServerLibraryStartupRequest(
            ContractHttpServerTlsConfigRequest(
                certChain,
                nativeTlsTestText("policy_leaf_key_pkcs8.pem"),
                alpnProtocols: ["http/1.1"],
                requireHttp2Alpn: false
            ),
            aesBackendHint: "shim"
        )
    )
    let startOutcome = contractTryTls13StartIncrementalHttpServerHandshake(
        ContractTls13IncrementalServerStartRequest(
            ContractAcceptedTransportDescriptor("ignite-native-tls-h1-fixture"),
            plan,
            nativeTlsH1IncrementalBytes(32, start: 80),
            policy: policy,
            incomingBytes: clientHelloRecord
        )
    )
    let start = match (startOutcome.result) {
        case Some(value) => value
        case None => throw Exception("native TLS H1 fixture start failed: ${startOutcome.message}")
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
        case None => throw Exception("native TLS H1 fixture Finished failed: ${finishOutcome.message}")
    }
    NativeTls13ClientTransport(raw, session.recordChannel)
}

func nativeTlsTestText(name: String): String {
    String.fromUtf8(File.readFrom(NATIVE_TLS_TESTDATA_ROOT + name))
}

func nativeTlsH1IncrementalBytes(size: Int64, start!: Int64 = 0): Array<Byte> {
    let out = Array<Byte>(size, repeat: 0)
    var i: Int64 = 0
    while (i < size) {
        out[i] = UInt8((start + i) & 0xff)
        i += 1
    }
    out
}

func nativeTlsH1ReadRecord(transport: NativeByteTransport): Array<Byte> {
    let header = nativeTlsH1ReadExactly(transport, 5)
    let payloadLength = (Int64(header[3]) << 8) + Int64(header[4])
    let payload = nativeTlsH1ReadExactly(transport, payloadLength)
    let out = ArrayList<Byte>()
    for (value in header) { out.add(value) }
    for (value in payload) { out.add(value) }
    out.toArray()
}

func nativeTlsH1ReadExactly(transport: NativeByteTransport, length: Int64): Array<Byte> {
    let out = Array<Byte>(length, repeat: 0)
    var offset: Int64 = 0
    while (offset < length) {
        let chunk = Array<Byte>(length - offset, repeat: 0)
        let count = transport.read(chunk)
        if (count <= 0) {
            throw Exception("native TLS H1 fixture peer closed during read")
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

func nativeTlsH1ReadUntil(
    transport: NativeByteTransport,
    delimiter: Array<Byte>,
    limit: Int64
): Array<Byte> {
    let out = ArrayList<Byte>()
    let chunk = Array<Byte>(256, repeat: 0)
    while (out.size <= limit) {
        let count = transport.read(chunk)
        if (count <= 0) {
            throw Exception("native TLS H1 fixture peer closed before request head")
        }
        var i: Int64 = 0
        while (i < count) {
            out.add(chunk[i])
            i += 1
        }
        let bytes = out.toArray()
        if (nativeH1IndexOfBytes(bytes, delimiter, 0) >= 0) {
            return bytes
        }
    }
    throw Exception("native TLS H1 fixture request head exceeds limit")
}
