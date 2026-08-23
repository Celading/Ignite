package ignite.native_h2

import ignite.{App, Config, closeResponseTransportWriter, flushResponseTransportWriter}
import std.collection.ArrayList
import std.net.{IPSocketAddress, SocketTimeoutException, TcpServerSocket, TcpSocket}
import std.sync.AtomicBool
import std.time.MonoTime
import stdx.net.http.HttpHeaders

@Test
public class NativeH2RuntimeInternalTestSuite {
    @TestCase
    public func testNativeH2AppResponseWriterLifecycleRejectsWritesAfterClose(): Unit {
        let request = NativeH2SingleStreamRequest(
            1,
            "GET",
            "http",
            "localhost:18880",
            "/writer-lifecycle",
            Array<UInt8>(),
            headers: [],
            trailers: []
        )
        let carrier = NativeH2AppCurrentRequestCarrier(request, "127.0.0.1")
        let writer = carrier.openResponseTransportWriterRaw()

        writer.write("first".toArray())
        flushResponseTransportWriter(writer)
        closeResponseTransportWriter(writer)
        closeResponseTransportWriter(writer)

        var rejected = false
        try {
            writer.write("late".toArray())
        } catch (_: Exception) {
            rejected = true
        }

        let response = carrier.response()
        @Assert(rejected, true)
        @Assert(String.fromUtf8(response.body), "first")
    }

    @TestCase
    public func testAppTransportWriterCommitsHeadersBeforeHandlerReturns(): Unit {
        let handlerObservedCommit = AtomicBool(false)
        let middlewareObservedCommit = AtomicBool(false)
        let handlerReturned = AtomicBool(false)
        let app = App(config: Config(enableNetworkChangeNotice: false))
        app.use({ ctx =>
            ctx.next()
            middlewareObservedCommit.store(ctx.responseCommitted)
        })
        app.post("/early-headers", { ctx =>
            let _ = ctx.status(201).setHeader("x-ignite-live", "headers")
            let writer = ctx.transportWriter()
            writer.write("live-body".toArray())
            handlerObservedCommit.store(ctx.responseCommitted)
            sleep(Duration.millisecond * 120)
            closeResponseTransportWriter(writer)
            handlerReturned.store(true)
        })

        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H2 early HEADERS test could not reserve loopback port")
        let serverFuture = spawn {
            let accepted = listener.accept()
            accepted.readTimeout = Some(Duration.second * 3)
            accepted.writeTimeout = Some(Duration.second * 3)
            try {
                serveNativeH2SingleStreamApp(accepted, app, remoteAddress: "127.0.0.1")
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let client = TcpSocket("127.0.0.1", port)
        try {
            client.connect(timeout: Some(Duration.second * 2))
            client.readTimeout = Some(Duration.second * 3)
            client.writeTimeout = Some(Duration.second * 3)
            client.write(NATIVE_H2_PREFACE)
            nativeH2WriteFrame(
                client,
                NativeH2Frame(UInt8(0x4), UInt8(0), 0, Array<UInt8>())
            )
            nativeH2WriteFrame(
                client,
                NativeH2Frame(
                    UInt8(0x1), UInt8(0x5), 1,
                    nativeH2TestRequestHeaders("/early-headers")
                )
            )

            let serverSettings = nativeH2ReadFrame(client)
            let settingsAck = nativeH2ReadFrame(client)
            let responseHeaders = nativeH2ReadFrame(client)

            @Assert(serverSettings.frameType, UInt8(0x4))
            @Assert(settingsAck.frameType, UInt8(0x4))
            @Assert(settingsAck.flags, UInt8(0x1))
            @Assert(responseHeaders.frameType, UInt8(0x1))
            @Assert(responseHeaders.flags, UInt8(0x4))
            @Assert(responseHeaders.streamId, 1)
            let decoded = NativeH2HpackDecoderState()
                .decodeResponseHead(responseHeaders.payload)
            @Assert(decoded.status, UInt16(201))
            var liveHeader = ""
            for (header in decoded.headers) {
                if (header.name == "x-ignite-live") {
                    liveHeader = header.value
                }
            }
            @Assert(liveHeader, "headers")
            for (_ in 0..100) {
                if (handlerObservedCommit.load()) {
                    break
                }
                sleep(Duration.millisecond)
            }
            @Assert(handlerObservedCommit.load(), true)
            @Assert(handlerReturned.load(), false)

            let responseData = nativeH2ReadFrame(client)
            @Assert(responseData.frameType, UInt8(0x0))
            @Assert(responseData.flags, UInt8(0x1))
            @Assert(responseData.streamId, 1)
            @Assert(String.fromUtf8(responseData.payload), "live-body")
            @Assert(handlerReturned.load(), true)
            @Assert(middlewareObservedCommit.load(), true)
        } finally {
            try { client.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
            let _ = serverFuture.get(Duration.second * 3)
        }
    }

    @TestCase
    public func testResetIdleStreamClassifierPreservesImplicitlyClosedStreams(): Unit {
        @Assert(nativeH2ResetReferencesIdleStream(5, 3), true)
        @Assert(nativeH2ResetReferencesIdleStream(2, 3), true)
        @Assert(nativeH2ResetReferencesIdleStream(3, 3), false)
        @Assert(nativeH2ResetReferencesIdleStream(1, 3), false)
    }

    @TestCase
    public func testPriorityFrameValidationRejectsMalformedAndSelfDependentFrames(): Unit {
        nativeH2ValidatePriorityFrame(
            NativeH2Frame(
                UInt8(0x2), UInt8(0), 5,
                [UInt8(0), UInt8(0), UInt8(0), UInt8(3), UInt8(16)]
            )
        )

        var malformedCode: Int64 = NATIVE_H2_ERROR_NO_ERROR
        try {
            nativeH2ValidatePriorityFrame(
                NativeH2Frame(
                    UInt8(0x2), UInt8(0), 5,
                    [UInt8(0), UInt8(0), UInt8(0), UInt8(3)]
                )
            )
        } catch (e: NativeH2ProtocolException) {
            malformedCode = e.errorCode
        }

        var selfDependentCode: Int64 = NATIVE_H2_ERROR_NO_ERROR
        try {
            nativeH2ValidatePriorityFrame(
                NativeH2Frame(
                    UInt8(0x2), UInt8(0), 5,
                    [UInt8(0), UInt8(0), UInt8(0), UInt8(5), UInt8(16)]
                )
            )
        } catch (e: NativeH2ProtocolException) {
            selfDependentCode = e.errorCode
        }

        @Assert(malformedCode, NATIVE_H2_ERROR_FRAME_SIZE)
        @Assert(selfDependentCode, NATIVE_H2_ERROR_PROTOCOL)
    }

    @TestCase
    public func testPaddedPriorityHeadersExposeOnlyHeaderBlockFragment(): Unit {
        let frame = NativeH2Frame(
            UInt8(0x1), UInt8(0x28), 1,
            [
                UInt8(0x02),
                UInt8(0x00), UInt8(0x00), UInt8(0x00), UInt8(0x03), UInt8(0x0f),
                UInt8(0x82), UInt8(0x86),
                UInt8(0x00), UInt8(0x00)
            ]
        )

        let block = nativeH2RequestHeaderBlockFragment(frame)

        @Assert(block.size, 2)
        @Assert(block[0], UInt8(0x82))
        @Assert(block[1], UInt8(0x86))
    }

    @TestCase
    public func testPaddedDataExposesOnlyApplicationBytes(): Unit {
        let frame = NativeH2Frame(
            UInt8(0x0), UInt8(0x8), 1,
            [
                UInt8(0x02), UInt8(0x70), UInt8(0x61), UInt8(0x79),
                UInt8(0x00), UInt8(0x00)
            ]
        )

        let data = nativeH2RequestDataField(frame)

        @Assert(data.size, 3)
        @Assert(String.fromUtf8(data), "pay")
        @Assert(frame.payload.size, 6)
    }

    @TestCase
    public func testPaddedPayloadRejectsMissingOrOversizedPadding(): Unit {
        var missingDataPadLengthRejected = false
        try {
            let _ = nativeH2RequestDataField(
                NativeH2Frame(UInt8(0x0), UInt8(0x8), 1, Array<UInt8>())
            )
        } catch (e: NativeH2ProtocolException) {
            missingDataPadLengthRejected = e.message.contains("missing pad length")
        }

        var oversizedHeadersPaddingRejected = false
        try {
            let _ = nativeH2RequestHeaderBlockFragment(
                NativeH2Frame(
                    UInt8(0x1), UInt8(0x8), 1,
                    [UInt8(0x03), UInt8(0x82), UInt8(0x00)]
                )
            )
        } catch (e: NativeH2ProtocolException) {
            oversizedHeadersPaddingRejected = e.message.contains("padding exceeds payload")
        }

        @Assert(missingDataPadLengthRejected, true)
        @Assert(oversizedHeadersPaddingRejected, true)
    }

    @TestCase
    public func testPriorityHeadersRejectTruncatedAndSelfDependentPrefix(): Unit {
        var truncatedRejected = false
        try {
            let _ = nativeH2RequestHeaderBlockFragment(
                NativeH2Frame(
                    UInt8(0x1), UInt8(0x20), 1,
                    [UInt8(0x00), UInt8(0x00), UInt8(0x00), UInt8(0x03)]
                )
            )
        } catch (e: NativeH2ProtocolException) {
            truncatedRejected = e.message.contains("prefix is truncated")
        }

        var selfDependentRejected = false
        try {
            let _ = nativeH2RequestHeaderBlockFragment(
                NativeH2Frame(
                    UInt8(0x1), UInt8(0x20), 1,
                    [
                        UInt8(0x00), UInt8(0x00), UInt8(0x00), UInt8(0x01), UInt8(0x0f),
                        UInt8(0x82)
                    ]
                )
            )
        } catch (e: NativeH2ProtocolException) {
            selfDependentRejected = e.message.contains("cannot depend on itself")
        }

        @Assert(truncatedRejected, true)
        @Assert(selfDependentRejected, true)
    }

    @TestCase
    public func testNodeCapturedHeaderBlocksReuseConnectionHpackState(): Unit {
        let firstBlock = [
            UInt8(0x82), UInt8(0x86), UInt8(0x41), UInt8(0x8b), UInt8(0x08), UInt8(0x9d),
            UInt8(0x5c), UInt8(0x0b), UInt8(0x81), UInt8(0x70), UInt8(0xdc), UInt8(0x70),
            UInt8(0x0f), UInt8(0x81), UInt8(0x9f), UInt8(0x04), UInt8(0x85), UInt8(0x62),
            UInt8(0x72), UInt8(0x8e), UInt8(0x84), UInt8(0xcf), UInt8(0x7a), UInt8(0x93),
            UInt8(0x34), UInt8(0xd5), UInt8(0x19), UInt8(0x25), UInt8(0x5a), UInt8(0x7e),
            UInt8(0xc0), UInt8(0x78), UInt8(0x4f), UInt8(0x2d), UInt8(0x51), UInt8(0xe4),
            UInt8(0x2a), UInt8(0xc4), UInt8(0x1d), UInt8(0x69), UInt8(0xb6), UInt8(0xc2),
            UInt8(0xff), UInt8(0x53), UInt8(0x03), UInt8(0x2a), UInt8(0x2f), UInt8(0x2a)
        ]
        let secondBlock = [
            UInt8(0x82), UInt8(0x86), UInt8(0xc0), UInt8(0x04), UInt8(0x87), UInt8(0x62),
            UInt8(0xba), UInt8(0x06), UInt8(0x6a), UInt8(0x92), UInt8(0x5f), UInt8(0x29),
            UInt8(0xbf), UInt8(0xbe)
        ]
        let decoder = NativeH2HpackDecoderState()

        let first = decoder.decodeRequestHead(firstBlock)
        @Assert(first.method, "GET")
        @Assert(first.scheme, "http")
        @Assert(first.path, "/health")
        @Assert(first.authority.size > 0, true)
        @Assert(
            nativeH2RequestHeaderValue(first.headers, "user-agent"),
            "ignite-hq0828-node-capture"
        )
        @Assert(nativeH2RequestHeaderValue(first.headers, "accept"), "*/*")
        @Assert(decoder.dynamicEntryCount(), 3)

        let second = decoder.decodeRequestHead(secondBlock)
        @Assert(second.method, "GET")
        @Assert(second.scheme, "http")
        @Assert(second.authority, first.authority)
        @Assert(second.path, "/plaintext")
        @Assert(
            nativeH2RequestHeaderValue(second.headers, "user-agent"),
            "ignite-hq0828-node-capture"
        )
        @Assert(nativeH2RequestHeaderValue(second.headers, "accept"), "*/*")
        @Assert(decoder.dynamicEntryCount(), 3)
    }

    @TestCase
    public func testNativeH2AppCarrierPreservesRegularAndDuplicateHeaders(): Unit {
        let request = NativeH2SingleStreamRequest(
            1,
            "GET",
            "http",
            "localhost:18880",
            "/headers",
            Array<UInt8>(),
            headers: [
                NativeH2Header("user-agent", "node-probe"),
                NativeH2Header("accept", "*/*"),
                NativeH2Header("x-dup", "one"),
                NativeH2Header("x-dup", "two")
            ],
            trailers: [
                NativeH2Header("x-trailer", "first"),
                NativeH2Header("x-trailer", "second")
            ]
        )
        let carrier = NativeH2AppCurrentRequestCarrier(request, "127.0.0.1")

        @Assert(carrier.requestHeaderValue("host") ?? "", "localhost:18880")
        @Assert(carrier.requestHeaderValue("user-agent") ?? "", "node-probe")
        @Assert(carrier.requestHeaderValue("accept") ?? "", "*/*")
        var duplicateCount: Int64 = 0
        var duplicateJoined = ""
        for ((name, values) in carrier.requestHeaders()) {
            if (name == "x-dup") {
                duplicateCount = values.size
                for (value in values) {
                    if (duplicateJoined.size > 0) { duplicateJoined += "," }
                    duplicateJoined += value
                }
            }
        }
        @Assert(duplicateCount, 2)
        @Assert(duplicateJoined, "one,two")
        var trailerCount: Int64 = 0
        for ((name, values) in carrier.requestTrailers()) {
            if (name == "x-trailer") {
                trailerCount = values.size
            }
        }
        @Assert(carrier.requestTrailers().getFirst("x-trailer") ?? "", "first")
        @Assert(trailerCount, 2)

        let responseHeaders = HttpHeaders()
        responseHeaders.add("set-cookie", "first=one; Path=/")
        responseHeaders.add("set-cookie", "second=two; Path=/")
        carrier.addResponseHeaders(responseHeaders)
        let response = carrier.response()
        var responseCookieCount: Int64 = 0
        var responseCookieJoined = ""
        for (header in response.headers) {
            if (header.name == "set-cookie") {
                responseCookieCount += 1
                if (responseCookieJoined.size > 0) { responseCookieJoined += "," }
                responseCookieJoined += header.value
            }
        }
        @Assert(responseCookieCount, 2)
        @Assert(
            responseCookieJoined,
            "first=one; Path=/,second=two; Path=/"
        )
        @Assert(nativeH2EncodeResponseHead(response.status, response.headers).size > 0, true)
    }

    @TestCase
    public func testNativeH2ResponseHeaderAdmissionRejectsUnsafeMetadata(): Unit {
        assertNativeH2ResponseHeaderFailure(
            "x bad",
            "value"
        )
        assertNativeH2ResponseHeaderFailure(
            "x-safe",
            "value\r\nx-injected: yes"
        )
    }

    @TestCase
    public func testHpackRequestTrailersRejectPseudoHeaders(): Unit {
        let decoder = NativeH2HpackDecoderState()
        var rejected = false
        try {
            let _ = decoder.decodeRequestTrailers([UInt8(0x82)])
        } catch (e: NativeH2ProtocolException) {
            rejected = e.errorCode == NATIVE_H2_ERROR_PROTOCOL &&
                e.message.contains("must not contain pseudo-headers")
        }
        @Assert(rejected, true)
    }

    @TestCase
    public func testHpackHuffmanRejectsInvalidPadding(): Unit {
        let decoder = NativeH2HpackDecoderState()
        let invalid = [
            UInt8(0x82), UInt8(0x86), UInt8(0x01), UInt8(0x09),
            UInt8(0x6c), UInt8(0x6f), UInt8(0x63), UInt8(0x61), UInt8(0x6c),
            UInt8(0x68), UInt8(0x6f), UInt8(0x73), UInt8(0x74), UInt8(0x04),
            UInt8(0x81), UInt8(0x00)
        ]
        var rejected = false
        try {
            let _ = decoder.decodeRequestHead(invalid)
        } catch (e: NativeH2ProtocolException) {
            rejected = e.errorCode == NATIVE_H2_ERROR_COMPRESSION &&
                e.message.contains("invalid padding")
        }
        @Assert(rejected, true)
    }

    @TestCase
    public func testHpackHuffmanRoundTripsUtf8OutsideVisibleAsciiSubset(): Unit {
        let value = "caf\u{00e9}-\u{2713}"
        let payload = nativeH2EncodeResponseHead(200, [
            NativeH2Header("x-unicode", value)
        ])

        let decoded = NativeH2HpackDecoderState().decodeResponseHead(payload)

        @Assert(decoded.status, UInt16(200))
        @Assert(decoded.headers.size, 1)
        @Assert(decoded.headers[0].name, "x-unicode")
        @Assert(decoded.headers[0].value, value)
    }

    @TestCase
    public func testHpackEncoderReusesDynamicEntriesAcrossResponseHeads(): Unit {
        let encoder = NativeH2HpackEncoderState()
        let headers = [
            NativeH2Header("cache-control", "public, max-age=600")
        ]
        let first = nativeH2EncodeResponseHead(200, headers, None, encoder)
        let second = nativeH2EncodeResponseHead(200, headers, None, encoder)
        let decoder = NativeH2HpackDecoderState()

        let firstDecoded = decoder.decodeResponseHead(first)
        let secondDecoded = decoder.decodeResponseHead(second)

        @Assert(firstDecoded.headers[0].value, "public, max-age=600")
        @Assert(secondDecoded.headers[0].value, "public, max-age=600")
        @Assert(encoder.dynamicEntryCount(), Int64(1))
        @Assert(second.size < first.size, true)
    }

    @TestCase
    public func testHpackEncoderNeverIndexesSensitiveHeaders(): Unit {
        let encoder = NativeH2HpackEncoderState()
        let headers = [
            NativeH2Header("authorization", "Bearer secret"),
            NativeH2Header("proxy-authorization", "Basic secret"),
            NativeH2Header("cookie", "session=secret"),
            NativeH2Header("set-cookie", "session=secret; Secure")
        ]
        let first = nativeH2EncodeResponseHead(200, headers, None, encoder)
        let second = nativeH2EncodeResponseHead(200, headers, None, encoder)
        let decoder = NativeH2HpackDecoderState()

        @Assert(decoder.decodeResponseHead(first).headers.size, Int64(4))
        @Assert(decoder.decodeResponseHead(second).headers.size, Int64(4))
        @Assert(encoder.dynamicEntryCount(), Int64(0))
        @Assert(second.size, first.size)
    }

    @TestCase
    public func testHpackEncoderAppliesPeerTableResizeBeforeNextHeaderBlock(): Unit {
        let encoder = NativeH2HpackEncoderState()
        let headers = [NativeH2Header("x-resize", "stable")]
        let first = nativeH2EncodeResponseHead(200, headers, None, encoder)
        encoder.updatePeerMaxSize(0)
        let second = nativeH2EncodeResponseHead(200, headers, None, encoder)
        let decoder = NativeH2HpackDecoderState()

        let _ = decoder.decodeResponseHead(first)
        let decoded = decoder.decodeResponseHead(second)

        @Assert(second[0], UInt8(0x20))
        @Assert(decoded.headers[0].value, "stable")
        @Assert(encoder.dynamicEntryCount(), Int64(0))
    }

    @TestCase
    public func testHpackPlainHuffmanAndIndexedByteProfiles(): Unit {
        let iterations: Int64 = 2048
        let name = "x-ignite-benchmark"
        let value = "repeated-response-metadata-for-hpack-efficiency"
        var plainBytes: Int64 = 0
        var huffmanBytes: Int64 = 0
        var indexedBytes: Int64 = 0

        let plainStarted = MonoTime.now()
        var i: Int64 = 0
        while (i < iterations) {
            plainBytes += nativeH2TestEncodePlainLiteral(name, value).size
            i += 1
        }
        let plainElapsed = MonoTime.now() - plainStarted

        let huffmanEncoder = NativeH2HpackEncoderState(maxDynamicTableSize: 0)
        let huffmanStarted = MonoTime.now()
        i = 0
        while (i < iterations) {
            huffmanBytes += nativeH2EncodeResponseHead(
                200,
                [NativeH2Header(name, value)],
                None,
                huffmanEncoder
            ).size
            i += 1
        }
        let huffmanElapsed = MonoTime.now() - huffmanStarted

        let indexedEncoder = NativeH2HpackEncoderState()
        let indexedStarted = MonoTime.now()
        i = 0
        while (i < iterations) {
            indexedBytes += nativeH2EncodeResponseHead(
                200,
                [NativeH2Header(name, value)],
                None,
                indexedEncoder
            ).size
            i += 1
        }
        let indexedElapsed = MonoTime.now() - indexedStarted

        println(
            "[hpack-benchmark] iterations=${iterations} " +
            "plainBytes=${plainBytes} plainMs=${plainElapsed.toMilliseconds()} " +
            "huffmanBytes=${huffmanBytes} huffmanMs=${huffmanElapsed.toMilliseconds()} " +
            "indexedBytes=${indexedBytes} indexedMs=${indexedElapsed.toMilliseconds()}"
        )
        @Assert(huffmanBytes < plainBytes, true)
        @Assert(indexedBytes < huffmanBytes, true)
    }

    @TestCase
    public func testResponseHeadSupportsVariableLengthHeaderNameAndValue(): Unit {
        let nameBytes = Array<UInt8>(140, repeat: UInt8(0x78))
        let valueBytes = Array<UInt8>(600, repeat: UInt8(0x61))
        let name = String.fromUtf8(nameBytes)
        let value = String.fromUtf8(valueBytes)

        let payload = nativeH2EncodeResponseHead(200, [NativeH2Header(name, value)])
        let decoded = NativeH2HpackDecoderState().decodeResponseHead(payload)

        @Assert(decoded.headers.size, 1)
        @Assert(decoded.headers[0].name, name)
        @Assert(decoded.headers[0].value, value)
        @Assert(payload.size < nameBytes.size + valueBytes.size, true)
    }

    @TestCase
    public func testHpackHeaderListLimitsFailClosedOnDecodeAndEncode(): Unit {
        let payload = nativeH2EncodeResponseHead(200, [
            NativeH2Header("x-limit", "abcdefghijklmnopqrstuvwxyz")
        ])
        var decodeRejected = false
        try {
            let _ = NativeH2HpackDecoderState(4096, 48).decodeResponseHead(payload)
        } catch (e: NativeH2ProtocolException) {
            decodeRejected = e.errorCode == NATIVE_H2_ERROR_COMPRESSION &&
                e.message.contains("header list exceeds")
        }

        var encodeRejected = false
        try {
            let _ = nativeH2EncodeResponseHead(
                200,
                [NativeH2Header("x-limit", "abcdefghijklmnopqrstuvwxyz")],
                Some(Int64(48))
            )
        } catch (e: Exception) {
            encodeRejected = e.message.contains("SETTINGS_MAX_HEADER_LIST_SIZE")
        }

        @Assert(decodeRejected, true)
        @Assert(encodeRejected, true)
    }

    @TestCase
    public func testHpackDecoderRejectsUnavailableIndexLateUpdateAndTruncation(): Unit {
        assertNativeH2HpackCompressionFailure(
            [UInt8(0xbe)],
            "dynamic index is unavailable"
        )
        assertNativeH2HpackCompressionFailure(
            [UInt8(0x82), UInt8(0x20)],
            "dynamic table update must precede"
        )
        assertNativeH2HpackCompressionFailure(
            [UInt8(0x82), UInt8(0x86), UInt8(0x01), UInt8(0x09), UInt8(0x6c)],
            "string payload is truncated"
        )
    }

    @TestCase
    public func testResponseHeadEncodesGenericStatusAndFiltersConnectionHeaders(): Unit {
        let payload = nativeH2EncodeResponseHead(201, [
            NativeH2Header("connection", "close"),
            NativeH2Header("x-native-h2", "accepted")
        ])

        let decoded = NativeH2HpackDecoderState().decodeResponseHead(payload)
        @Assert(decoded.status, UInt16(201))
        @Assert(decoded.headers.size, 1)
        @Assert(decoded.headers[0].name, "x-native-h2")
        @Assert(decoded.headers[0].value, "accepted")
    }

    @TestCase
    public func testSingleStreamRuntimeCompletesRealWireTurn(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H2 test could not reserve loopback port")
        let app = App()
        app.post("/native-h2", { ctx =>
            let prefix = (
                ctx.method + ":" + ctx.path + ":" +
                (ctx.query("mode") ?? "") + ":" + ctx.bodyString()
            ).toArray()
            let responseBody = Array<UInt8>(16385, repeat: UInt8(0x78))
            var responseIndex: Int64 = 0
            while (responseIndex < prefix.size) {
                responseBody[responseIndex] = prefix[responseIndex]
                responseIndex += 1
            }
            let _ = ctx
                .setHeader("content-type", "text/plain; charset=utf-8")
                .send(responseBody)
        })
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                serveNativeH2SingleStreamApp(accepted, app, remoteAddress: "127.0.0.1")
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let client = TcpSocket("127.0.0.1", port)
        try {
            client.connect(timeout: Some(Duration.second * 2))
            client.write(NATIVE_H2_PREFACE)
            nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x4), UInt8(0), 0, Array<UInt8>()))

            let path = "/native-h2?mode=wire"
            let authority = "localhost"
            let headersPayload = Array<UInt8>(6 + authority.size + path.size, repeat: 0)
            headersPayload[0] = UInt8(0x83)
            headersPayload[1] = UInt8(0x86)
            headersPayload[2] = UInt8(0x01)
            headersPayload[3] = UInt8(authority.size)
            var i: Int64 = 0
            let authorityBytes = authority.toArray()
            while (i < authorityBytes.size) {
                headersPayload[4 + i] = authorityBytes[i]
                i += 1
            }
            let pathOffset = 4 + authorityBytes.size
            headersPayload[pathOffset] = UInt8(0x04)
            headersPayload[pathOffset + 1] = UInt8(path.size)
            i = 0
            let pathBytes = path.toArray()
            while (i < pathBytes.size) {
                headersPayload[pathOffset + 2 + i] = pathBytes[i]
                i += 1
            }
            let framedHeaders = Array<UInt8>(headersPayload.size + 8, repeat: 0)
            framedHeaders[0] = UInt8(0x02)
            framedHeaders[4] = UInt8(0x03)
            framedHeaders[5] = UInt8(0x0f)
            i = 0
            while (i < headersPayload.size) {
                framedHeaders[6 + i] = headersPayload[i]
                i += 1
            }
            nativeH2WriteFrame(
                client,
                NativeH2Frame(UInt8(0x1), UInt8(0x2c), 1, framedHeaders)
            )
            nativeH2WriteFrame(
                client,
                NativeH2Frame(
                    UInt8(0x0), UInt8(0x9), 1,
                    [
                        UInt8(0x02), UInt8(0x61), UInt8(0x62), UInt8(0x63),
                        UInt8(0x00), UInt8(0x00)
                    ]
                )
            )

            let serverSettings = nativeH2ReadFrame(client)
            let settingsAck = nativeH2ReadFrame(client)
            let requestConnectionUpdate = nativeH2ReadFrame(client)
            let responseHeaders = nativeH2ReadFrame(client)
            let responseDataFirst = nativeH2ReadFrame(client)
            let responseDataLast = nativeH2ReadFrame(client)

            @Assert(serverSettings.frameType, UInt8(0x4))
            @Assert(serverSettings.flags, UInt8(0))
            @Assert(settingsAck.frameType, UInt8(0x4))
            @Assert(settingsAck.flags, UInt8(0x1))
            @Assert(requestConnectionUpdate.frameType, UInt8(0x8))
            @Assert(requestConnectionUpdate.streamId, 0)
            @Assert(nativeH2DecodeWindowUpdate(requestConnectionUpdate), 6)
            @Assert(responseHeaders.frameType, UInt8(0x1))
            @Assert(responseHeaders.flags, UInt8(0x4))
            @Assert(responseHeaders.streamId, 1)
            @Assert(responseHeaders.payload.size > 1, true)
            @Assert(responseHeaders.payload[0], UInt8(0x88))
            let decodedResponseHead = NativeH2HpackDecoderState()
                .decodeResponseHead(responseHeaders.payload)
            @Assert(decodedResponseHead.status, UInt16(200))
            var responseContentType = ""
            for (header in decodedResponseHead.headers) {
                if (header.name == "content-type") {
                    responseContentType = header.value
                }
            }
            @Assert(responseContentType, "text/plain; charset=utf-8")
            @Assert(responseDataFirst.frameType, UInt8(0x0))
            @Assert(responseDataFirst.flags, UInt8(0))
            @Assert(responseDataFirst.streamId, 1)
            @Assert(responseDataFirst.payload.size, 16384)
            @Assert(
                String.fromUtf8(nativeH2Slice(responseDataFirst.payload, 0, 24)),
                "POST:/native-h2:wire:abc"
            )
            @Assert(responseDataLast.frameType, UInt8(0x0))
            @Assert(responseDataLast.flags, UInt8(0x1))
            @Assert(responseDataLast.streamId, 1)
            @Assert(responseDataLast.payload.size, 1)
            @Assert(responseDataLast.payload[0], UInt8(0x78))
        } finally {
            try { client.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
            let _ = serverFuture.get(Duration.second * 2)
        }
    }

    @TestCase
    public func testContinuationCompletesSplitRequestHead(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H2 continuation test could not reserve loopback port")
        let app = App()
        app.post("/continued", { ctx =>
            let _ = ctx.sendString("continued:" + ctx.path)
        })
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                serveNativeH2AppConnection(accepted, app, maxCompletedStreams: 1)
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let client = TcpSocket("127.0.0.1", port)
        try {
            client.connect(timeout: Some(Duration.second * 2))
            client.readTimeout = Some(Duration.second * 2)
            client.write(NATIVE_H2_PREFACE)
            nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x4), UInt8(0), 0, Array<UInt8>()))
            let headers = nativeH2TestRequestHeaders("/continued")
            nativeH2WriteFrame(
                client,
                NativeH2Frame(UInt8(0x1), UInt8(0x1), 1, nativeH2Slice(headers, 0, 5))
            )
            nativeH2WriteFrame(
                client,
                NativeH2Frame(UInt8(0x9), UInt8(0x4), 1, nativeH2Slice(headers, 5, headers.size))
            )

            let serverSettings = nativeH2ReadFrame(client)
            let settingsAck = nativeH2ReadFrame(client)
            let responseHeaders = nativeH2ReadFrame(client)
            let responseData = nativeH2ReadFrame(client)
            @Assert(serverSettings.frameType, UInt8(0x4))
            @Assert(settingsAck.flags, UInt8(0x1))
            @Assert(responseHeaders.frameType, UInt8(0x1))
            @Assert(responseData.frameType, UInt8(0x0))
            @Assert(String.fromUtf8(responseData.payload), "continued:/continued")
            let _ = serverFuture.get(Duration.second * 2)
        } finally {
            try { client.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testContinuationRejectsInvalidSequencesAndOversizedBlock(): Unit {
        let incomplete = NativeH2Frame(
            UInt8(0x1), UInt8(0x1), 1,
            nativeH2Slice(nativeH2TestRequestHeaders("/continued"), 0, 5)
        )
        assertNativeH2ContinuationProtocolFailure(
            incomplete,
            Some(NativeH2Frame(UInt8(0x0), UInt8(0x1), 1, Array<UInt8>())),
            NATIVE_H2_ERROR_PROTOCOL
        )
        assertNativeH2ContinuationProtocolFailure(
            incomplete,
            Some(NativeH2Frame(UInt8(0x9), UInt8(0x4), 3, Array<UInt8>())),
            NATIVE_H2_ERROR_PROTOCOL
        )
        assertNativeH2ContinuationProtocolFailure(
            NativeH2Frame(UInt8(0x9), UInt8(0x4), 1, Array<UInt8>()),
            None,
            NATIVE_H2_ERROR_PROTOCOL
        )

        let pending = NativeH2PendingRequestHead(
            1, true, Array<UInt8>(NATIVE_H2_MAX_REQUEST_HEADER_BLOCK, repeat: 0)
        )
        var overflowRejected = false
        try {
            pending.append([UInt8(0)])
        } catch (e: NativeH2ProtocolException) {
            overflowRejected = e.errorCode == NATIVE_H2_ERROR_COMPRESSION
        }
        @Assert(overflowRejected, true)
    }

    @TestCase
    public func testRequestTrailersCompleteSplitWireTurn(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H2 request trailer test could not reserve loopback port")
        let app = App()
        app.post("/trailers", { ctx =>
            let trailer = ctx.trailer("x-request-trailer") ?? ""
            let _ = ctx.sendString(ctx.bodyString() + "|" + trailer)
        })
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                serveNativeH2AppConnection(accepted, app, maxCompletedStreams: 1)
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let client = TcpSocket("127.0.0.1", port)
        try {
            client.connect(timeout: Some(Duration.second * 2))
            client.readTimeout = Some(Duration.second * 2)
            client.write(NATIVE_H2_PREFACE)
            nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x4), UInt8(0), 0, Array<UInt8>()))
            nativeH2WriteFrame(
                client,
                NativeH2Frame(UInt8(0x1), UInt8(0x4), 1, nativeH2TestRequestHeaders("/trailers"))
            )
            nativeH2WriteFrame(
                client,
                NativeH2Frame(UInt8(0x0), UInt8(0), 1, "payload".toArray())
            )
            let trailers = nativeH2TestLiteralHeader("x-request-trailer", "seen")
            nativeH2WriteFrame(
                client,
                NativeH2Frame(UInt8(0x1), UInt8(0x1), 1, nativeH2Slice(trailers, 0, 7))
            )
            nativeH2WriteFrame(
                client,
                NativeH2Frame(UInt8(0x9), UInt8(0x4), 1, nativeH2Slice(trailers, 7, trailers.size))
            )

            let _ = nativeH2ReadFrame(client)
            let _ = nativeH2ReadFrame(client)
            let requestConnectionUpdate = nativeH2ReadFrame(client)
            let requestStreamUpdate = nativeH2ReadFrame(client)
            let responseHeaders = nativeH2ReadFrame(client)
            let responseData = nativeH2ReadFrame(client)
            @Assert(requestConnectionUpdate.frameType, UInt8(0x8))
            @Assert(requestConnectionUpdate.streamId, 0)
            @Assert(nativeH2DecodeWindowUpdate(requestConnectionUpdate), 7)
            @Assert(requestStreamUpdate.frameType, UInt8(0x8))
            @Assert(requestStreamUpdate.streamId, 1)
            @Assert(nativeH2DecodeWindowUpdate(requestStreamUpdate), 7)
            @Assert(responseHeaders.frameType, UInt8(0x1))
            @Assert(String.fromUtf8(responseData.payload), "payload|seen")
            let _ = serverFuture.get(Duration.second * 2)
        } finally {
            try { client.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testRequestTrailersRequireTerminalEndStream(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H2 non-terminal trailer test could not reserve loopback port")
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                serveNativeH2Connection(accepted, { _ => NativeH2SingleStreamResponse() })
                NATIVE_H2_ERROR_NO_ERROR
            } catch (e: NativeH2ProtocolException) {
                e.errorCode
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let client = TcpSocket("127.0.0.1", port)
        try {
            client.connect(timeout: Some(Duration.second * 2))
            client.readTimeout = Some(Duration.second * 2)
            client.write(NATIVE_H2_PREFACE)
            nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x4), UInt8(0), 0, Array<UInt8>()))
            nativeH2WriteFrame(
                client,
                NativeH2Frame(UInt8(0x1), UInt8(0x4), 1, nativeH2TestRequestHeaders("/trailers"))
            )
            nativeH2WriteFrame(
                client,
                NativeH2Frame(
                    UInt8(0x1), UInt8(0x4), 1,
                    nativeH2TestLiteralHeader("x-request-trailer", "seen")
                )
            )
            let _ = nativeH2ReadFrame(client)
            let _ = nativeH2ReadFrame(client)
            let goAway = nativeH2ReadFrame(client)
            @Assert(goAway.frameType, UInt8(0x7))
            @Assert(goAway.payload[7], UInt8(NATIVE_H2_ERROR_PROTOCOL))
            @Assert(serverFuture.get(Duration.second * 2), NATIVE_H2_ERROR_PROTOCOL)
        } finally {
            try { client.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testHeadResponseEndsOnHeadersWithoutData(): Unit {
        nativeH2AssertResponseBodySuppressed("HEAD", UInt16(200))
    }

    @TestCase
    public func test204ResponseEndsOnHeadersWithoutData(): Unit {
        nativeH2AssertResponseBodySuppressed("GET", UInt16(204))
    }

    @TestCase
    public func test304ResponseEndsOnHeadersWithoutData(): Unit {
        nativeH2AssertResponseBodySuppressed("GET", UInt16(304))
    }

    @TestCase
    public func testLateWindowUpdateForClosedResponseKeepsConnectionUsable(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H2 late window update test could not reserve loopback port")
        let app = App()
        app.get("/first", { ctx =>
            let _ = ctx.sendString("first")
        })
        app.get("/after-window-update", { ctx =>
            let _ = ctx.sendString("alive")
        })
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                serveNativeH2AppConnection(accepted, app, maxCompletedStreams: 2)
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let client = TcpSocket("127.0.0.1", port)
        try {
            client.connect(timeout: Some(Duration.second * 2))
            client.readTimeout = Some(Duration.second * 2)
            client.write(NATIVE_H2_PREFACE)
            nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x4), UInt8(0), 0, Array<UInt8>()))
            let first = nativeH2TestRequestHeaders("/first")
            first[0] = UInt8(0x82)
            nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x1), UInt8(0x5), 1, first))

            let _ = nativeH2ReadFrame(client)
            let _ = nativeH2ReadFrame(client)
            let firstHeaders = nativeH2ReadFrame(client)
            let firstData = nativeH2ReadFrame(client)
            @Assert(firstHeaders.streamId, 1)
            @Assert(firstData.streamId, 1)
            @Assert(firstData.flags, UInt8(0x1))
            @Assert(String.fromUtf8(firstData.payload), "first")

            nativeH2WriteFrame(client, nativeH2TestWindowUpdate(1, 1024))
            let second = nativeH2TestRequestHeaders("/after-window-update")
            second[0] = UInt8(0x82)
            nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x1), UInt8(0x5), 3, second))

            let secondHeaders = nativeH2ReadFrame(client)
            let secondData = nativeH2ReadFrame(client)
            @Assert(secondHeaders.streamId, 3)
            @Assert(secondData.streamId, 3)
            @Assert(secondData.flags, UInt8(0x1))
            @Assert(String.fromUtf8(secondData.payload), "alive")
            let _ = serverFuture.get(Duration.second * 2)
        } finally {
            try { client.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testFutureStreamWindowUpdateStillFailsConnection(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H2 future window update test could not reserve loopback port")
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                serveNativeH2Connection(accepted, { _ => NativeH2SingleStreamResponse() })
                NATIVE_H2_ERROR_NO_ERROR
            } catch (e: NativeH2ProtocolException) {
                e.errorCode
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let client = TcpSocket("127.0.0.1", port)
        try {
            client.connect(timeout: Some(Duration.second * 2))
            client.readTimeout = Some(Duration.second * 2)
            client.write(NATIVE_H2_PREFACE)
            nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x4), UInt8(0), 0, Array<UInt8>()))
            nativeH2WriteFrame(client, nativeH2TestWindowUpdate(1, 1024))

            let _ = nativeH2ReadFrame(client)
            let _ = nativeH2ReadFrame(client)
            let goAway = nativeH2ReadFrame(client)
            @Assert(goAway.frameType, UInt8(0x7))
            @Assert(goAway.streamId, 0)
            @Assert(goAway.payload[7], UInt8(NATIVE_H2_ERROR_PROTOCOL))
            @Assert(serverFuture.get(Duration.second * 2), NATIVE_H2_ERROR_PROTOCOL)
        } finally {
            try { client.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testLargeRequestBodyAdvancesAfterConsumedWindowUpdates(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H2 request flow test could not reserve loopback port")
        let app = App()
        app.post("/upload", { ctx =>
            let _ = ctx.sendString(ctx.bodyString().size.toString())
        })
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                serveNativeH2AppConnection(accepted, app, maxCompletedStreams: 1)
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let client = TcpSocket("127.0.0.1", port)
        try {
            client.connect(timeout: Some(Duration.second * 2))
            client.readTimeout = Some(Duration.second * 2)
            client.write(NATIVE_H2_PREFACE)
            nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x4), UInt8(0), 0, Array<UInt8>()))
            nativeH2WriteFrame(
                client,
                NativeH2Frame(
                    UInt8(0x1), UInt8(0x4), 1,
                    nativeH2TestRequestHeadersForMethod("/upload", "POST")
                )
            )
            let _ = nativeH2ReadFrame(client)
            let _ = nativeH2ReadFrame(client)

            let initialChunks = [Int64(16384), Int64(16384), Int64(16384), Int64(16383)]
            var replenished: Int64 = 0
            for (count in initialChunks) {
                nativeH2WriteFrame(
                    client,
                    NativeH2Frame(
                        UInt8(0x0), UInt8(0), 1,
                        Array<UInt8>(count, repeat: UInt8(0x78))
                    )
                )
                let connectionUpdate = nativeH2ReadFrame(client)
                let streamUpdate = nativeH2ReadFrame(client)
                @Assert(connectionUpdate.frameType, UInt8(0x8))
                @Assert(connectionUpdate.streamId, 0)
                @Assert(nativeH2DecodeWindowUpdate(connectionUpdate), count)
                @Assert(streamUpdate.frameType, UInt8(0x8))
                @Assert(streamUpdate.streamId, 1)
                @Assert(nativeH2DecodeWindowUpdate(streamUpdate), count)
                replenished += count
            }
            @Assert(replenished, NATIVE_H2_INITIAL_FLOW_WINDOW)

            nativeH2WriteFrame(
                client,
                NativeH2Frame(
                    UInt8(0x0), UInt8(0x1), 1,
                    Array<UInt8>(4465, repeat: UInt8(0x78))
                )
            )
            let finalConnectionUpdate = nativeH2ReadFrame(client)
            @Assert(finalConnectionUpdate.frameType, UInt8(0x8))
            @Assert(finalConnectionUpdate.streamId, 0)
            @Assert(nativeH2DecodeWindowUpdate(finalConnectionUpdate), 4465)

            let responseHeaders = nativeH2ReadFrame(client)
            let responseData = nativeH2ReadFrame(client)
            @Assert(responseHeaders.streamId, 1)
            @Assert(responseData.streamId, 1)
            @Assert(responseData.flags, UInt8(0x1))
            @Assert(String.fromUtf8(responseData.payload), "70000")
            let _ = serverFuture.get(Duration.second * 2)
        } finally {
            try { client.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testConfiguredBodyLimitReturns413AndKeepsConnectionUsable(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H2 body limit test could not reserve loopback port")
        let app = App(config: Config(bodyLimit: 8))
        app.post("/upload", { ctx =>
            let _ = ctx.sendString("unexpected:" + ctx.bodyString())
        })
        app.get("/health", { ctx =>
            let _ = ctx.sendString("alive")
        })
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                serveNativeH2AppConnection(accepted, app, maxCompletedStreams: 2)
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let client = TcpSocket("127.0.0.1", port)
        try {
            client.connect(timeout: Some(Duration.second * 2))
            client.readTimeout = Some(Duration.second * 2)
            client.write(NATIVE_H2_PREFACE)
            nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x4), UInt8(0), 0, Array<UInt8>()))
            nativeH2WriteFrame(
                client,
                NativeH2Frame(
                    UInt8(0x1), UInt8(0x4), 1,
                    nativeH2TestRequestHeadersForMethod("/upload", "POST")
                )
            )
            let _ = nativeH2ReadFrame(client)
            let _ = nativeH2ReadFrame(client)
            nativeH2WriteFrame(
                client,
                NativeH2Frame(
                    UInt8(0x0), UInt8(0), 1,
                    Array<UInt8>(9, repeat: UInt8(0x78))
                )
            )

            let rejectedHeaders = nativeH2ReadFrame(client)
            let rejectedConnectionUpdate = nativeH2ReadFrame(client)
            @Assert(rejectedHeaders.frameType, UInt8(0x1))
            @Assert(rejectedHeaders.flags, UInt8(0x5))
            @Assert(rejectedHeaders.streamId, 1)
            @Assert(rejectedHeaders.payload[0], UInt8(0x08))
            @Assert(rejectedHeaders.payload[1], UInt8(0x03))
            @Assert(String.fromUtf8(nativeH2Slice(rejectedHeaders.payload, 2, 5)), "413")
            @Assert(rejectedConnectionUpdate.frameType, UInt8(0x8))
            @Assert(rejectedConnectionUpdate.streamId, 0)
            @Assert(nativeH2DecodeWindowUpdate(rejectedConnectionUpdate), 9)

            nativeH2WriteFrame(
                client,
                NativeH2Frame(
                    UInt8(0x0), UInt8(0x1), 1,
                    Array<UInt8>(1, repeat: UInt8(0x78))
                )
            )
            let discardedConnectionUpdate = nativeH2ReadFrame(client)
            @Assert(discardedConnectionUpdate.frameType, UInt8(0x8))
            @Assert(discardedConnectionUpdate.streamId, 0)
            @Assert(nativeH2DecodeWindowUpdate(discardedConnectionUpdate), 1)

            nativeH2WriteFrame(
                client,
                NativeH2Frame(
                    UInt8(0x1), UInt8(0x5), 3,
                    nativeH2TestRequestHeadersForMethod("/health", "GET")
                )
            )
            let healthHeaders = nativeH2ReadFrame(client)
            let healthData = nativeH2ReadFrame(client)
            @Assert(healthHeaders.frameType, UInt8(0x1))
            @Assert(healthHeaders.streamId, 3)
            @Assert(healthData.frameType, UInt8(0x0))
            @Assert(healthData.streamId, 3)
            @Assert(healthData.flags, UInt8(0x1))
            @Assert(String.fromUtf8(healthData.payload), "alive")
            let _ = serverFuture.get(Duration.second * 2)
        } finally {
            try { client.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testConnectionKeepsInterleavedStreamsIndependent(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H2 multiplex test could not reserve loopback port")
        let app = App()
        app.post("/mux/one", { ctx =>
            let _ = ctx.sendString("one:" + ctx.bodyString())
        })
        app.post("/mux/two", { ctx =>
            let _ = ctx.sendString("two:" + ctx.bodyString())
        })
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                serveNativeH2AppConnection(
                    accepted,
                    app,
                    remoteAddress: "127.0.0.1",
                    maxCompletedStreams: 2
                )
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let client = TcpSocket("127.0.0.1", port)
        try {
            client.connect(timeout: Some(Duration.second * 2))
            client.write(NATIVE_H2_PREFACE)
            nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x4), UInt8(0), 0, Array<UInt8>()))
            nativeH2WriteFrame(
                client,
                NativeH2Frame(UInt8(0x1), UInt8(0x4), 1, nativeH2TestRequestHeaders("/mux/one"))
            )
            nativeH2WriteFrame(
                client,
                NativeH2Frame(UInt8(0x1), UInt8(0x4), 3, nativeH2TestRequestHeaders("/mux/two"))
            )
            nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x0), UInt8(0x1), 3, "B".toArray()))
            nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x0), UInt8(0x1), 1, "A".toArray()))

            let serverSettings = nativeH2ReadFrame(client)
            let settingsAck = nativeH2ReadFrame(client)
            var streamOneHeaders = false
            var streamThreeHeaders = false
            var streamOneBody = ""
            var streamThreeBody = ""
            var endedStreams: Int64 = 0
            while (endedStreams < 2) {
                let frame = nativeH2ReadFrame(client)
                if (frame.frameType == UInt8(0x1)) {
                    if (frame.streamId == 1) {
                        streamOneHeaders = true
                    } else if (frame.streamId == 3) {
                        streamThreeHeaders = true
                    }
                } else if (frame.frameType == UInt8(0x0)) {
                    if (frame.streamId == 1) {
                        streamOneBody += String.fromUtf8(frame.payload)
                    } else if (frame.streamId == 3) {
                        streamThreeBody += String.fromUtf8(frame.payload)
                    }
                    if ((frame.flags & UInt8(0x1)) != UInt8(0)) {
                        endedStreams += 1
                    }
                }
            }

            @Assert(serverSettings.frameType, UInt8(0x4))
            @Assert(settingsAck.flags, UInt8(0x1))
            @Assert(streamOneHeaders, true)
            @Assert(streamThreeHeaders, true)
            @Assert(streamOneBody, "one:A")
            @Assert(streamThreeBody, "two:B")
        } finally {
            try { client.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
            let _ = serverFuture.get(Duration.second * 2)
        }
    }

    @TestCase
    public func testLargeResponseResumesAfterConnectionAndStreamWindowUpdate(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H2 flow test could not reserve loopback port")
        let app = App()
        app.get("/large", { ctx =>
            let _ = ctx.send(Array<UInt8>(70000, repeat: UInt8(0x7a)))
        })
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                serveNativeH2AppConnection(
                    accepted,
                    app,
                    remoteAddress: "127.0.0.1",
                    maxCompletedStreams: 1
                )
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let client = TcpSocket("127.0.0.1", port)
        try {
            client.connect(timeout: Some(Duration.second * 2))
            client.write(NATIVE_H2_PREFACE)
            nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x4), UInt8(0), 0, Array<UInt8>()))
            let getHeaders = nativeH2TestRequestHeaders("/large")
            getHeaders[0] = UInt8(0x82)
            nativeH2WriteFrame(
                client,
                NativeH2Frame(UInt8(0x1), UInt8(0x5), 1, getHeaders)
            )

            let serverSettings = nativeH2ReadFrame(client)
            let settingsAck = nativeH2ReadFrame(client)
            let responseHeaders = nativeH2ReadFrame(client)
            var receivedBeforeUpdate: Int64 = 0
            var sawEarlyEndStream = false
            var i: Int64 = 0
            while (i < 4) {
                let data = nativeH2ReadFrame(client)
                receivedBeforeUpdate += data.payload.size
                if ((data.flags & UInt8(0x1)) != UInt8(0)) {
                    sawEarlyEndStream = true
                }
                i += 1
            }

            @Assert(serverSettings.frameType, UInt8(0x4))
            @Assert(settingsAck.flags, UInt8(0x1))
            @Assert(responseHeaders.streamId, 1)
            @Assert(receivedBeforeUpdate, NATIVE_H2_INITIAL_FLOW_WINDOW)
            @Assert(sawEarlyEndStream, false)

            nativeH2WriteFrame(client, nativeH2TestWindowUpdate(0, 10000))
            nativeH2WriteFrame(client, nativeH2TestWindowUpdate(1, 10000))
            let finalData = nativeH2ReadFrame(client)
            @Assert(finalData.streamId, 1)
            @Assert(finalData.payload.size, 4465)
            @Assert(finalData.flags, UInt8(0x1))
        } finally {
            try { client.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
            let _ = serverFuture.get(Duration.second * 2)
        }
    }

    @TestCase
    public func testResetDropsOneStreamAndKeepsConnectionUsable(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H2 reset test could not reserve loopback port")
        let app = App()
        app.get("/after-reset", { ctx =>
            let _ = ctx.sendString("alive")
        })
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                serveNativeH2AppConnection(accepted, app, maxCompletedStreams: 1)
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let client = TcpSocket("127.0.0.1", port)
        try {
            client.connect(timeout: Some(Duration.second * 2))
            client.write(NATIVE_H2_PREFACE)
            nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x4), UInt8(0), 0, Array<UInt8>()))
            nativeH2WriteFrame(
                client,
                NativeH2Frame(UInt8(0x1), UInt8(0x4), 1, nativeH2TestRequestHeaders("/abandoned"))
            )
            nativeH2WriteFrame(
                client,
                NativeH2Frame(UInt8(0x3), UInt8(0), 1, Array<UInt8>(4, repeat: 0))
            )
            let afterReset = nativeH2TestRequestHeaders("/after-reset")
            afterReset[0] = UInt8(0x82)
            nativeH2WriteFrame(
                client,
                NativeH2Frame(UInt8(0x1), UInt8(0x5), 3, afterReset)
            )

            let _ = nativeH2ReadFrame(client)
            let _ = nativeH2ReadFrame(client)
            let headers = nativeH2ReadFrame(client)
            let data = nativeH2ReadFrame(client)
            @Assert(headers.streamId, 3)
            @Assert(data.streamId, 3)
            @Assert(String.fromUtf8(data.payload), "alive")
        } finally {
            try { client.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
            let _ = serverFuture.get(Duration.second * 2)
        }
    }

    @TestCase
    public func testPeerCloseEndsUnboundedConnectionWithoutProtocolFailure(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H2 peer-close test could not reserve loopback port")
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                serveNativeH2Connection(accepted, { _ => NativeH2SingleStreamResponse() })
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let client = TcpSocket("127.0.0.1", port)
        client.connect(timeout: Some(Duration.second * 2))
        client.write(NATIVE_H2_PREFACE)
        nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x4), UInt8(0), 0, Array<UInt8>()))
        let _ = nativeH2ReadFrame(client)
        let _ = nativeH2ReadFrame(client)
        client.close()
        try { listener.close() } catch (_: Exception) {}
        let _ = serverFuture.get(Duration.second * 2)
    }

    @TestCase
    public func testResetSettlesWindowBlockedOutboundResponse(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H2 outbound reset test could not reserve loopback port")
        let app = App()
        app.get("/reset-large", { ctx =>
            let _ = ctx.send(Array<UInt8>(70000, repeat: UInt8(0x72)))
        })
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                serveNativeH2AppConnection(accepted, app, maxCompletedStreams: 1)
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let client = TcpSocket("127.0.0.1", port)
        try {
            client.connect(timeout: Some(Duration.second * 2))
            client.write(NATIVE_H2_PREFACE)
            nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x4), UInt8(0), 0, Array<UInt8>()))
            let headers = nativeH2TestRequestHeaders("/reset-large")
            headers[0] = UInt8(0x82)
            nativeH2WriteFrame(
                client,
                NativeH2Frame(UInt8(0x1), UInt8(0x5), 1, headers)
            )

            let _ = nativeH2ReadFrame(client)
            let _ = nativeH2ReadFrame(client)
            let _ = nativeH2ReadFrame(client)
            var received: Int64 = 0
            var i: Int64 = 0
            while (i < 4) {
                received += nativeH2ReadFrame(client).payload.size
                i += 1
            }
            @Assert(received, NATIVE_H2_INITIAL_FLOW_WINDOW)
            nativeH2WriteFrame(
                client,
                NativeH2Frame(UInt8(0x3), UInt8(0), 1, Array<UInt8>(4, repeat: 0))
            )
            let _ = serverFuture.get(Duration.second * 2)
        } finally {
            try { client.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testSlowHandlerDoesNotBlockFastStreamOrPing(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H2 handler isolation test could not reserve loopback port")
        let app = App()
        app.get("/slow", { ctx =>
            sleep(Duration.millisecond * 400)
            let _ = ctx.sendString("slow")
        })
        app.get("/fast", { ctx =>
            let _ = ctx.sendString("fast")
        })
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                serveNativeH2AppConnection(accepted, app, maxCompletedStreams: 2)
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let client = TcpSocket("127.0.0.1", port)
        try {
            client.connect(timeout: Some(Duration.second * 2))
            client.readTimeout = Some(Duration.second * 2)
            client.write(NATIVE_H2_PREFACE)
            nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x4), UInt8(0), 0, Array<UInt8>()))
            let slowHeaders = nativeH2TestRequestHeaders("/slow")
            slowHeaders[0] = UInt8(0x82)
            nativeH2WriteFrame(
                client,
                NativeH2Frame(UInt8(0x1), UInt8(0x5), 1, slowHeaders)
            )
            let fastHeaders = nativeH2TestRequestHeaders("/fast")
            fastHeaders[0] = UInt8(0x82)
            nativeH2WriteFrame(
                client,
                NativeH2Frame(UInt8(0x1), UInt8(0x5), 3, fastHeaders)
            )
            let pingPayload = "pingpong".toArray()
            let pingWire = nativeH2TestFrameWire(
                NativeH2Frame(UInt8(0x6), UInt8(0), 0, pingPayload)
            )
            client.write(nativeH2Slice(pingWire, 0, 4))
            sleep(Duration.millisecond * 30)
            client.write(nativeH2Slice(pingWire, 4, pingWire.size))

            let _ = nativeH2ReadFrame(client)
            let _ = nativeH2ReadFrame(client)
            var sawPingAck = false
            var endedResponses: Int64 = 0
            var fastOrder: Int64 = 0
            var slowOrder: Int64 = 0
            while (!sawPingAck || endedResponses < 2) {
                let frame = nativeH2ReadFrame(client)
                if (frame.frameType == UInt8(0x6)) {
                    @Assert(frame.flags, UInt8(0x1))
                    @Assert(nativeH2BytesEqual(frame.payload, pingPayload), true)
                    sawPingAck = true
                } else if (frame.frameType == UInt8(0x0) &&
                    (frame.flags & UInt8(0x1)) != UInt8(0)) {
                    endedResponses += 1
                    if (frame.streamId == 3) {
                        fastOrder = endedResponses
                        @Assert(String.fromUtf8(frame.payload), "fast")
                    } else if (frame.streamId == 1) {
                        slowOrder = endedResponses
                        @Assert(String.fromUtf8(frame.payload), "slow")
                    }
                }
            }
            @Assert(sawPingAck, true)
            @Assert(fastOrder, 1)
            @Assert(slowOrder, 2)
        } finally {
            try { client.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
            let _ = serverFuture.get(Duration.second * 2)
        }
    }

    @TestCase
    public func testIdleReadTimeoutRemainsCallerOwned(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H2 idle timeout test could not reserve loopback port")
        let control = NativeH2ConnectionControl()
        let serverFuture = spawn {
            let accepted = listener.accept()
            accepted.readTimeout = Some(Duration.millisecond * 80)
            try {
                serveNativeH2Connection(
                    accepted,
                    { _ => NativeH2SingleStreamResponse() },
                    control: control
                )
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let client = TcpSocket("127.0.0.1", port)
        try {
            client.connect(timeout: Some(Duration.second * 2))
            client.write(NATIVE_H2_PREFACE)
            nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x4), UInt8(0), 0, Array<UInt8>()))
            let _ = nativeH2ReadFrame(client)
            let _ = nativeH2ReadFrame(client)
            var timedOut = false
            try {
                let _ = serverFuture.get(Duration.second * 2)
            } catch (_: SocketTimeoutException) {
                timedOut = true
            }
            @Assert(timedOut, true)
        } finally {
            try { client.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testLocalCloseEmitsGoAwayAndSettlesPendingHandler(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H2 local close test could not reserve loopback port")
        let handlerStarted = AtomicBool(false)
        let control = NativeH2ConnectionControl()
        let app = App()
        app.get("/closing", { ctx =>
            handlerStarted.store(true)
            sleep(Duration.millisecond * 400)
            let _ = ctx.sendString("too-late")
        })
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                serveNativeH2AppConnection(accepted, app, control: control)
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let client = TcpSocket("127.0.0.1", port)
        try {
            client.connect(timeout: Some(Duration.second * 2))
            client.readTimeout = Some(Duration.second * 2)
            client.write(NATIVE_H2_PREFACE)
            nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x4), UInt8(0), 0, Array<UInt8>()))
            let headers = nativeH2TestRequestHeaders("/closing")
            headers[0] = UInt8(0x82)
            nativeH2WriteFrame(
                client,
                NativeH2Frame(UInt8(0x1), UInt8(0x5), 1, headers)
            )
            let _ = nativeH2ReadFrame(client)
            let _ = nativeH2ReadFrame(client)
            var attempts: Int64 = 0
            while (!handlerStarted.load() && attempts < 200) {
                sleep(Duration.millisecond * 5)
                attempts += 1
            }
            @Assert(handlerStarted.load(), true)
            control.requestClose()

            let goAway = nativeH2ReadFrame(client)
            @Assert(goAway.frameType, UInt8(0x7))
            @Assert(goAway.streamId, 0)
            @Assert(goAway.payload.size, 8)
            @Assert(goAway.payload[3], UInt8(1))
            @Assert(goAway.payload[4], UInt8(0))
            @Assert(goAway.payload[5], UInt8(0))
            @Assert(goAway.payload[6], UInt8(0))
            @Assert(goAway.payload[7], UInt8(0))
            let _ = serverFuture.get(Duration.second * 2)
        } finally {
            try { client.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testProtocolFailureEmitsExactGoAwayAndSettlesPendingHandler(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H2 protocol GOAWAY test could not reserve loopback port")
        let handlerStarted = AtomicBool(false)
        let app = App()
        app.get("/protocol-failure", { ctx =>
            handlerStarted.store(true)
            sleep(Duration.millisecond * 400)
            let _ = ctx.sendString("too-late")
        })
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                serveNativeH2AppConnection(accepted, app)
                NATIVE_H2_ERROR_NO_ERROR
            } catch (e: NativeH2ProtocolException) {
                e.errorCode
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let client = TcpSocket("127.0.0.1", port)
        try {
            client.connect(timeout: Some(Duration.second * 2))
            client.readTimeout = Some(Duration.second * 2)
            client.write(NATIVE_H2_PREFACE)
            nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x4), UInt8(0), 0, Array<UInt8>()))
            let headers = nativeH2TestRequestHeaders("/protocol-failure")
            headers[0] = UInt8(0x82)
            nativeH2WriteFrame(
                client,
                NativeH2Frame(UInt8(0x1), UInt8(0x5), 1, headers)
            )
            let _ = nativeH2ReadFrame(client)
            let _ = nativeH2ReadFrame(client)
            var attempts: Int64 = 0
            while (!handlerStarted.load() && attempts < 200) {
                sleep(Duration.millisecond * 5)
                attempts += 1
            }
            @Assert(handlerStarted.load(), true)
            nativeH2WriteFrame(
                client,
                NativeH2Frame(UInt8(0x6), UInt8(0), 0, Array<UInt8>(7, repeat: 0))
            )

            let goAway = nativeH2ReadFrame(client)
            @Assert(goAway.frameType, UInt8(0x7))
            @Assert(goAway.streamId, 0)
            @Assert(goAway.payload.size, 8)
            @Assert(goAway.payload[3], UInt8(1))
            @Assert(goAway.payload[7], UInt8(NATIVE_H2_ERROR_FRAME_SIZE))
            @Assert(serverFuture.get(Duration.second * 2), NATIVE_H2_ERROR_FRAME_SIZE)
        } finally {
            try { client.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testUnknownExtensionFrameIsIgnored(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H2 extension frame test could not reserve loopback port")
        let app = App()
        app.get("/after-extension", { ctx =>
            let _ = ctx.sendString("alive")
        })
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                serveNativeH2AppConnection(accepted, app, maxCompletedStreams: 1)
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let client = TcpSocket("127.0.0.1", port)
        try {
            client.connect(timeout: Some(Duration.second * 2))
            client.readTimeout = Some(Duration.second * 2)
            client.write(NATIVE_H2_PREFACE)
            nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x4), UInt8(0), 0, Array<UInt8>()))
            nativeH2WriteFrame(
                client,
                NativeH2Frame(UInt8(0x0a), UInt8(0), 0, "extension".toArray())
            )
            let headers = nativeH2TestRequestHeaders("/after-extension")
            headers[0] = UInt8(0x82)
            nativeH2WriteFrame(
                client,
                NativeH2Frame(UInt8(0x1), UInt8(0x5), 1, headers)
            )

            let _ = nativeH2ReadFrame(client)
            let _ = nativeH2ReadFrame(client)
            let responseHeaders = nativeH2ReadFrame(client)
            let responseData = nativeH2ReadFrame(client)
            @Assert(responseHeaders.streamId, 1)
            @Assert(responseData.streamId, 1)
            @Assert(String.fromUtf8(responseData.payload), "alive")
            let _ = serverFuture.get(Duration.second * 2)
        } finally {
            try { client.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testConcurrentLargeResponsesRecoverAcrossSharedWindow(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H2 concurrent flow test could not reserve loopback port")
        let app = App()
        app.get("/large/a", { ctx =>
            let _ = ctx.send(Array<UInt8>(70000, repeat: UInt8(0x61)))
        })
        app.get("/large/b", { ctx =>
            let _ = ctx.send(Array<UInt8>(70000, repeat: UInt8(0x62)))
        })
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                serveNativeH2AppConnection(accepted, app, maxCompletedStreams: 2)
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let client = TcpSocket("127.0.0.1", port)
        try {
            client.connect(timeout: Some(Duration.second * 2))
            client.readTimeout = Some(Duration.second * 2)
            client.write(NATIVE_H2_PREFACE)
            nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x4), UInt8(0), 0, Array<UInt8>()))
            let first = nativeH2TestRequestHeaders("/large/a")
            first[0] = UInt8(0x82)
            let second = nativeH2TestRequestHeaders("/large/b")
            second[0] = UInt8(0x82)
            nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x1), UInt8(0x5), 1, first))
            nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x1), UInt8(0x5), 3, second))

            let _ = nativeH2ReadFrame(client)
            let _ = nativeH2ReadFrame(client)
            var firstBytes: Int64 = 0
            var secondBytes: Int64 = 0
            var firstEnded = false
            var secondEnded = false
            while (firstBytes + secondBytes < NATIVE_H2_INITIAL_FLOW_WINDOW) {
                let frame = nativeH2ReadFrame(client)
                if (frame.frameType != UInt8(0x0)) {
                    continue
                }
                if (frame.streamId == 1) {
                    firstBytes += frame.payload.size
                    firstEnded = (frame.flags & UInt8(0x1)) != UInt8(0)
                } else if (frame.streamId == 3) {
                    secondBytes += frame.payload.size
                    secondEnded = (frame.flags & UInt8(0x1)) != UInt8(0)
                }
            }
            @Assert(firstBytes + secondBytes, NATIVE_H2_INITIAL_FLOW_WINDOW)
            @Assert(firstEnded, false)
            @Assert(secondEnded, false)

            nativeH2WriteFrame(client, nativeH2TestWindowUpdate(0, 100000))
            nativeH2WriteFrame(client, nativeH2TestWindowUpdate(1, 100000))
            nativeH2WriteFrame(client, nativeH2TestWindowUpdate(3, 100000))
            while (!firstEnded || !secondEnded) {
                let frame = nativeH2ReadFrame(client)
                if (frame.frameType != UInt8(0x0)) {
                    continue
                }
                if (frame.streamId == 1) {
                    firstBytes += frame.payload.size
                    firstEnded = (frame.flags & UInt8(0x1)) != UInt8(0)
                } else if (frame.streamId == 3) {
                    secondBytes += frame.payload.size
                    secondEnded = (frame.flags & UInt8(0x1)) != UInt8(0)
                }
            }
            @Assert(firstBytes, 70000)
            @Assert(secondBytes, 70000)
            let _ = serverFuture.get(Duration.second * 2)
        } finally {
            try { client.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testBufferedResponseAboveLegacyCeilingUsesFramedFlowControl(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H2 buffered response test could not reserve loopback port")
        let responseSize: Int64 = 1280 * 1024
        let app = App()
        app.get("/above-legacy-ceiling", { ctx =>
            let _ = ctx.send(Array<UInt8>(responseSize, repeat: UInt8(0x72)))
        })
        app.get("/health", { ctx =>
            let _ = ctx.sendString("ok")
        })
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                serveNativeH2AppConnection(accepted, app, maxCompletedStreams: 2)
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let client = TcpSocket("127.0.0.1", port)
        try {
            client.connect(timeout: Some(Duration.second * 2))
            client.readTimeout = Some(Duration.second * 4)
            client.write(NATIVE_H2_PREFACE)
            nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x4), UInt8(0), 0, Array<UInt8>()))
            let largeHeaders = nativeH2TestRequestHeaders("/above-legacy-ceiling")
            largeHeaders[0] = UInt8(0x82)
            nativeH2WriteFrame(
                client,
                NativeH2Frame(UInt8(0x1), UInt8(0x5), 1, largeHeaders)
            )

            let serverSettings = nativeH2ReadFrame(client)
            let settingsAck = nativeH2ReadFrame(client)
            let responseHeaders = nativeH2ReadFrame(client)
            @Assert(serverSettings.frameType, UInt8(0x4))
            @Assert(settingsAck.frameType, UInt8(0x4))
            @Assert(settingsAck.flags, UInt8(0x1))
            @Assert(responseHeaders.frameType, UInt8(0x1))
            @Assert(responseHeaders.streamId, 1)

            var received: Int64 = 0
            var ended = false
            while (!ended) {
                let frame = nativeH2ReadFrame(client)
                if (frame.frameType != UInt8(0x0) || frame.streamId != 1) {
                    continue
                }
                received += frame.payload.size
                if (frame.payload.size > 0) {
                    @Assert(frame.payload[0], UInt8(0x72))
                    @Assert(frame.payload[frame.payload.size - 1], UInt8(0x72))
                }
                ended = (frame.flags & UInt8(0x1)) != UInt8(0)
                if (!ended) {
                    nativeH2WriteFrame(
                        client,
                        nativeH2TestWindowUpdate(0, frame.payload.size)
                    )
                    nativeH2WriteFrame(
                        client,
                        nativeH2TestWindowUpdate(1, frame.payload.size)
                    )
                }
            }
            @Assert(received, responseSize)

            let healthHeaders = nativeH2TestRequestHeaders("/health")
            healthHeaders[0] = UInt8(0x82)
            nativeH2WriteFrame(
                client,
                NativeH2Frame(UInt8(0x1), UInt8(0x5), 3, healthHeaders)
            )
            let healthResponseHeaders = nativeH2ReadFrame(client)
            let healthResponseData = nativeH2ReadFrame(client)
            @Assert(healthResponseHeaders.frameType, UInt8(0x1))
            @Assert(healthResponseHeaders.streamId, 3)
            @Assert(healthResponseData.frameType, UInt8(0x0))
            @Assert(healthResponseData.flags, UInt8(0x1))
            @Assert(healthResponseData.streamId, 3)
            @Assert(String.fromUtf8(healthResponseData.payload), "ok")
            let _ = serverFuture.get(Duration.second * 4)
        } finally {
            try { client.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testRepeatedConnectionChurnSettlesEverySocketTurn(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H2 connection churn test could not reserve loopback port")
        let turns: Int64 = 16
        let serverFuture = spawn {
            var turn: Int64 = 0
            while (turn < turns) {
                let accepted = listener.accept()
                try {
                    serveNativeH2SingleStream(accepted, { request =>
                        NativeH2SingleStreamResponse(body: "turn:${request.streamId}".toArray())
                    })
                } finally {
                    try { accepted.close() } catch (_: Exception) {}
                }
                turn += 1
            }
        }

        var turn: Int64 = 0
        try {
            while (turn < turns) {
                let client = TcpSocket("127.0.0.1", port)
                try {
                    client.connect(timeout: Some(Duration.second * 2))
                    client.readTimeout = Some(Duration.second * 2)
                    client.write(NATIVE_H2_PREFACE)
                    nativeH2WriteFrame(
                        client,
                        NativeH2Frame(UInt8(0x4), UInt8(0), 0, Array<UInt8>())
                    )
                    let headers = nativeH2TestRequestHeaders("/churn")
                    headers[0] = UInt8(0x82)
                    nativeH2WriteFrame(
                        client,
                        NativeH2Frame(UInt8(0x1), UInt8(0x5), 1, headers)
                    )
                    let _ = nativeH2ReadFrame(client)
                    let _ = nativeH2ReadFrame(client)
                    let responseHeaders = nativeH2ReadFrame(client)
                    let responseData = nativeH2ReadFrame(client)
                    @Assert(responseHeaders.streamId, 1)
                    @Assert(String.fromUtf8(responseData.payload), "turn:1")
                } finally {
                    try { client.close() } catch (_: Exception) {}
                }
                turn += 1
            }
            let _ = serverFuture.get(Duration.second * 3)
        } finally {
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testGoAwayEndsUnboundedConnectionLoop(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H2 GOAWAY test could not reserve loopback port")
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                serveNativeH2Connection(accepted, { _ => NativeH2SingleStreamResponse() })
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let client = TcpSocket("127.0.0.1", port)
        try {
            client.connect(timeout: Some(Duration.second * 2))
            client.write(NATIVE_H2_PREFACE)
            nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x4), UInt8(0), 0, Array<UInt8>()))
            let _ = nativeH2ReadFrame(client)
            let _ = nativeH2ReadFrame(client)
            nativeH2WriteFrame(
                client,
                NativeH2Frame(UInt8(0x7), UInt8(0), 0, Array<UInt8>(8, repeat: 0))
            )
            let _ = serverFuture.get(Duration.second * 2)
        } finally {
            try { client.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
        }
    }
}

func nativeH2TestEncodePlainLiteral(name: String, value: String): Array<UInt8> {
    let out = ArrayList<UInt8>()
    out.add(UInt8(0x88))
    nativeH2HpackAppendInteger(out, 0, 4, UInt8(0))
    nativeH2HpackAppendString(out, name, false)
    nativeH2HpackAppendString(out, value, false)
    out.toArray()
}

func assertNativeH2HpackCompressionFailure(
    payload: Array<UInt8>,
    expectedMessage: String
): Unit {
    var rejected = false
    try {
        let _ = NativeH2HpackDecoderState().decodeRequestHead(payload)
    } catch (e: NativeH2ProtocolException) {
        rejected = e.errorCode == NATIVE_H2_ERROR_COMPRESSION &&
            e.message.contains(expectedMessage)
    }
    @Assert(rejected, true)
}

func assertNativeH2ResponseHeaderFailure(name: String, value: String): Unit {
    var rejected = false
    try {
        let header = NativeH2Header(name, value)
        let _ = nativeH2EncodeResponseHead(200, [header])
    } catch (_: Exception) {
        rejected = true
    }
    @Assert(rejected, true)
}

func nativeH2RequestHeaderValue(
    headers: Array<NativeH2Header>,
    name: String
): String {
    for (header in headers) {
        if (header.name == name) {
            return header.value
        }
    }
    ""
}

func assertNativeH2ContinuationProtocolFailure(
    firstFrame: NativeH2Frame,
    secondFrame: ?NativeH2Frame,
    expectedError: Int64
): Unit {
    let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
    listener.bind()
    let port = (listener.localAddress as IPSocketAddress)?.port ??
        throw Exception("native H2 continuation failure test could not reserve loopback port")
    let serverFuture = spawn {
        let accepted = listener.accept()
        try {
            serveNativeH2Connection(accepted, { _ => NativeH2SingleStreamResponse() })
            NATIVE_H2_ERROR_NO_ERROR
        } catch (e: NativeH2ProtocolException) {
            e.errorCode
        } finally {
            try { accepted.close() } catch (_: Exception) {}
        }
    }

    let client = TcpSocket("127.0.0.1", port)
    try {
        client.connect(timeout: Some(Duration.second * 2))
        client.readTimeout = Some(Duration.second * 2)
        client.write(NATIVE_H2_PREFACE)
        nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x4), UInt8(0), 0, Array<UInt8>()))
        nativeH2WriteFrame(client, firstFrame)
        if (let Some(frame) <- secondFrame) {
            nativeH2WriteFrame(client, frame)
        }
        let _ = nativeH2ReadFrame(client)
        let _ = nativeH2ReadFrame(client)
        let goAway = nativeH2ReadFrame(client)
        @Assert(goAway.frameType, UInt8(0x7))
        @Assert(goAway.payload[7], UInt8(expectedError))
        @Assert(serverFuture.get(Duration.second * 2), expectedError)
    } finally {
        try { client.close() } catch (_: Exception) {}
        try { listener.close() } catch (_: Exception) {}
    }
}

func nativeH2TestWindowUpdate(streamId: Int64, increment: Int64): NativeH2Frame {
    let payload = Array<UInt8>(4, repeat: 0)
    payload[0] = UInt8((increment >> 24) & 0x7f)
    payload[1] = UInt8((increment >> 16) & 0xff)
    payload[2] = UInt8((increment >> 8) & 0xff)
    payload[3] = UInt8(increment & 0xff)
    NativeH2Frame(UInt8(0x8), UInt8(0), streamId, payload)
}

func nativeH2TestFrameWire(frame: NativeH2Frame): Array<UInt8> {
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
    wire
}

func nativeH2TestRequestHeaders(path: String): Array<UInt8> {
    let authority = "localhost"
    let payload = Array<UInt8>(6 + authority.size + path.size, repeat: 0)
    payload[0] = UInt8(0x83)
    payload[1] = UInt8(0x86)
    payload[2] = UInt8(0x01)
    payload[3] = UInt8(authority.size)
    let authorityBytes = authority.toArray()
    var i: Int64 = 0
    while (i < authorityBytes.size) {
        payload[4 + i] = authorityBytes[i]
        i += 1
    }
    let pathOffset = 4 + authorityBytes.size
    payload[pathOffset] = UInt8(0x04)
    payload[pathOffset + 1] = UInt8(path.size)
    let pathBytes = path.toArray()
    i = 0
    while (i < pathBytes.size) {
        payload[pathOffset + 2 + i] = pathBytes[i]
        i += 1
    }
    payload
}

func nativeH2TestRequestHeadersForMethod(path: String, method: String): Array<UInt8> {
    let authority = "localhost"
    let methodBytes = method.toArray()
    let payload = Array<UInt8>(7 + methodBytes.size + authority.size + path.size, repeat: 0)
    payload[0] = UInt8(0x02)
    payload[1] = UInt8(methodBytes.size)
    var i: Int64 = 0
    while (i < methodBytes.size) {
        payload[2 + i] = methodBytes[i]
        i += 1
    }
    let schemeOffset = 2 + methodBytes.size
    payload[schemeOffset] = UInt8(0x86)
    payload[schemeOffset + 1] = UInt8(0x01)
    payload[schemeOffset + 2] = UInt8(authority.size)
    let authorityBytes = authority.toArray()
    i = 0
    while (i < authorityBytes.size) {
        payload[schemeOffset + 3 + i] = authorityBytes[i]
        i += 1
    }
    let pathOffset = schemeOffset + 3 + authorityBytes.size
    payload[pathOffset] = UInt8(0x04)
    payload[pathOffset + 1] = UInt8(path.size)
    let pathBytes = path.toArray()
    i = 0
    while (i < pathBytes.size) {
        payload[pathOffset + 2 + i] = pathBytes[i]
        i += 1
    }
    payload
}

func nativeH2AssertResponseBodySuppressed(method: String, status: UInt16): Unit {
    let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
    listener.bind()
    let port = (listener.localAddress as IPSocketAddress)?.port ??
        throw Exception("native H2 body suppression test could not reserve loopback port")
    let serverFuture = spawn {
        let accepted = listener.accept()
        try {
            serveNativeH2Connection(
                accepted,
                { _ =>
                    NativeH2SingleStreamResponse(
                        status: status,
                        body: "must-not-reach-wire".toArray()
                    )
                },
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
        nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x4), UInt8(0), 0, Array<UInt8>()))
        nativeH2WriteFrame(
            client,
            NativeH2Frame(
                UInt8(0x1), UInt8(0x5), 1,
                nativeH2TestRequestHeadersForMethod("/body-forbidden", method)
            )
        )

        let serverSettings = nativeH2ReadFrame(client)
        let settingsAck = nativeH2ReadFrame(client)
        let responseHeaders = nativeH2ReadFrame(client)
        @Assert(serverSettings.frameType, UInt8(0x4))
        @Assert(settingsAck.frameType, UInt8(0x4))
        @Assert(settingsAck.flags, UInt8(0x1))
        @Assert(responseHeaders.frameType, UInt8(0x1))
        @Assert(responseHeaders.flags, UInt8(0x5))
        @Assert(responseHeaders.streamId, 1)
        let _ = serverFuture.get(Duration.second * 2)
    } finally {
        try { client.close() } catch (_: Exception) {}
        try { listener.close() } catch (_: Exception) {}
    }
}

func nativeH2TestLiteralHeader(name: String, value: String): Array<UInt8> {
    let nameBytes = name.toArray()
    let valueBytes = value.toArray()
    let payload = Array<UInt8>(3 + nameBytes.size + valueBytes.size, repeat: 0)
    payload[0] = UInt8(0)
    payload[1] = UInt8(nameBytes.size)
    var i: Int64 = 0
    while (i < nameBytes.size) {
        payload[2 + i] = nameBytes[i]
        i += 1
    }
    let valueOffset = 2 + nameBytes.size
    payload[valueOffset] = UInt8(valueBytes.size)
    i = 0
    while (i < valueBytes.size) {
        payload[valueOffset + 1 + i] = valueBytes[i]
        i += 1
    }
    payload
}

func nativeH2ContainsBytes(input: Array<UInt8>, target: Array<UInt8>): Bool {
    if (target.size == 0) {
        return true
    }
    if (input.size < target.size) {
        return false
    }
    var start: Int64 = 0
    while (start <= input.size - target.size) {
        var matched = true
        var i: Int64 = 0
        while (i < target.size) {
            if (input[start + i] != target[i]) {
                matched = false
                break
            }
            i += 1
        }
        if (matched) {
            return true
        }
        start += 1
    }
    false
}
