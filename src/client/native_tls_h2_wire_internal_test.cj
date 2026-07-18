package ignite.client

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
}

func serveNativeTlsH2Fixture(socket: TcpSocket): Unit {
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

    var requestHead: ?NativeTlsH2TestFrame = None
    while (requestHead.isNone()) {
        let frame = nativeTlsH2ReadFrame(tls)
        if (frame.frameType == UInt8(0x1)) {
            requestHead = Some(frame)
        }
    }
    let head = requestHead ?? throw Exception("native TLS H2 fixture request head is missing")
    if (head.streamId != 1) {
        throw Exception("native TLS H2 fixture expected stream 1")
    }

    nativeTlsH2WriteFrame(
        tls,
        NativeTlsH2TestFrame(
            UInt8(0x1), UInt8(0x4), 1,
            nativeTlsH2ResponseHeadBlock()
        )
    )
    nativeTlsH2WriteFrame(
        tls,
        NativeTlsH2TestFrame(
            UInt8(0x0), UInt8(0x1), 1,
            "native-tls-h2-ok".toArray()
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
