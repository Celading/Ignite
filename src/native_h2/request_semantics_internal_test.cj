package ignite.native_h2

import std.collection.ArrayList
import std.net.{IPSocketAddress, TcpServerSocket, TcpSocket}

@Test
public class NativeH2RequestSemanticsInternalTestSuite {
    @TestCase
    public func testRejectsForbiddenRequestHeaderSemantics(): Unit {
        assertNativeH2RequestHeaderRejected("X-Upper", "value")
        assertNativeH2RequestHeaderRejected("connection", "close")
        assertNativeH2RequestHeaderRejected("te", "gzip")

        let valid = nativeH2RequestHeadersWith("te", "trailers")
        let decoded = NativeH2HpackDecoderState().decodeRequestHead(valid)
        @Assert(nativeH2RequestHeaderValue(decoded.headers, "te"), "trailers")
    }

    @TestCase
    public func testParsesContentLengthAndRejectsConflicts(): Unit {
        let decoded = NativeH2HpackDecoderState().decodeRequestHead(
            nativeH2RequestHeadersWith("content-length", "5")
        )
        @Assert(decoded.contentLength ?? -1, 5)

        let conflicting = nativeH2ConcatTestBytes(
            nativeH2RequestHeadersWith("content-length", "5"),
            nativeH2TestLiteralHeader("content-length", "6")
        )
        var rejected = false
        try {
            let _ = NativeH2HpackDecoderState().decodeRequestHead(conflicting)
        } catch (_: NativeH2RequestException) {
            rejected = true
        }
        @Assert(rejected, true)
    }

    @TestCase
    public func testRejectsSingleAndMultiDataContentLengthMismatchOnWire(): Unit {
        assertNativeH2ContentLengthMismatch(["abc".toArray()])
        assertNativeH2ContentLengthMismatch(["ab".toArray(), "c".toArray()])
    }
}

func assertNativeH2RequestHeaderRejected(name: String, value: String): Unit {
    var rejected = false
    try {
        let _ = NativeH2HpackDecoderState().decodeRequestHead(
            nativeH2RequestHeadersWith(name, value)
        )
    } catch (_: NativeH2RequestException) {
        rejected = true
    }
    @Assert(rejected, true)
}

func nativeH2RequestHeadersWith(name: String, value: String): Array<UInt8> {
    nativeH2ConcatTestBytes(
        nativeH2TestRequestHeadersForMethod("/semantics", "POST"),
        nativeH2TestLiteralHeader(name, value)
    )
}

func assertNativeH2ContentLengthMismatch(chunks: Array<Array<UInt8>>): Unit {
    let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
    listener.bind()
    let port = (listener.localAddress as IPSocketAddress)?.port ??
        throw Exception("native H2 request semantics test could not reserve loopback port")
    let serverFuture = spawn {
        let accepted = listener.accept()
        try {
            serveNativeH2Connection(
                accepted,
                { _ => NativeH2SingleStreamResponse() },
                maxCompletedStreams: 1
            )
        } finally {
            try { accepted.close() } catch (_: Exception) {}
        }
    }

    let client = TcpSocket("127.0.0.1", port)
    try {
        client.connect(timeout: Some(Duration.second * 2))
        client.readTimeout = Some(Duration.second * 2)
        client.write(NATIVE_H2_PREFACE)
        nativeH2WriteFrame(
            client, NativeH2Frame(UInt8(0x4), UInt8(0), 0, Array<UInt8>())
        )
        nativeH2WriteFrame(
            client,
            NativeH2Frame(
                UInt8(0x1), UInt8(0x4), 1,
                nativeH2RequestHeadersWith("content-length", "5")
            )
        )
        var index: Int64 = 0
        for (chunk in chunks) {
            let isLast = index == chunks.size - 1
            nativeH2WriteFrame(
                client,
                NativeH2Frame(
                    UInt8(0x0),
                    if (isLast) { UInt8(0x1) } else { UInt8(0) },
                    1,
                    chunk
                )
            )
            index += 1
        }

        var resetSeen = false
        var frames: Int64 = 0
        while (!resetSeen && frames < 8) {
            let frame = nativeH2ReadFrame(client)
            if (frame.frameType == UInt8(0x3) && frame.streamId == 1) {
                @Assert(frame.payload[3], UInt8(NATIVE_H2_ERROR_PROTOCOL))
                resetSeen = true
            }
            frames += 1
        }
        @Assert(resetSeen, true)
        let _ = serverFuture.get(Duration.second * 2)
    } finally {
        try { client.close() } catch (_: Exception) {}
        try { listener.close() } catch (_: Exception) {}
    }
}

func nativeH2ConcatTestBytes(
    first: Array<UInt8>,
    second: Array<UInt8>
): Array<UInt8> {
    let out = ArrayList<UInt8>()
    for (value in first) { out.add(value) }
    for (value in second) { out.add(value) }
    out.toArray()
}
