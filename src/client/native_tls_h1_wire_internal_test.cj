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
}

func serveNativeTlsH1Fixture(socket: TcpSocket): Unit {
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
    let tls = NativeTls13ClientTransport(raw, session.recordChannel)
    let requestHead = nativeTlsH1ReadUntil(tls, "\r\n\r\n".toArray(), 65536)
    if (nativeH1IndexOfBytes(requestHead, "GET /tls-h1 HTTP/1.1".toArray(), 0) < 0) {
        throw Exception("native TLS H1 fixture received unexpected request")
    }
    tls.write(
        "HTTP/1.1 200 OK\r\nContent-Length: 16\r\nX-Ignite-Native-Tls: h1\r\nConnection: close\r\n\r\nnative-tls-h1-ok".toArray()
    )
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
