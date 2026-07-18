package ignite.native_h2

import ignite.App
import std.collection.ArrayList
import std.net.{IPSocketAddress, TcpServerSocket, TcpSocket}

@Test
public class NativeH2ClientRuntimeInternalTestSuite {
    @TestCase
    public func testResponseHpackStateKeepsIndexedDynamicHeadersAcrossHeads(): Unit {
        let decoder = NativeH2HpackDecoderState()
        let first = decoder.decodeResponseHead([
            UInt8(0x88),
            UInt8(0x61), UInt8(0x01), UInt8(0x78)
        ])
        @Assert(first.status, UInt16(200))
        @Assert(first.headers[0].name, "date")
        @Assert(first.headers[0].value, "x")
        @Assert(decoder.dynamicEntryCount(), 1)

        let second = decoder.decodeResponseHead([UInt8(0x88), UInt8(0xbe)])
        @Assert(second.status, UInt16(200))
        @Assert(second.headers[0].name, "date")
        @Assert(second.headers[0].value, "x")
    }

    @TestCase
    public func testNativeClientCompletesRealWireTurnAgainstNativeServer(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H2 client test could not reserve loopback port")
        let app = App()
        app.post("/client-wire", { ctx =>
            let prefix = (ctx.method + ":" + ctx.path + ":" + ctx.bodyString()).toArray()
            let body = Array<UInt8>(70000, repeat: UInt8(0x63))
            var i: Int64 = 0
            while (i < prefix.size) {
                body[i] = prefix[i]
                i += 1
            }
            let _ = ctx
                .status(201)
                .setHeader("x-native-h2-client", "accepted")
                .send(body)
        })
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                serveNativeH2SingleStreamApp(accepted, app, remoteAddress: "127.0.0.1")
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let socket = TcpSocket("127.0.0.1", port)
        try {
            socket.connect(timeout: Some(Duration.second * 2))
            socket.readTimeout = Some(Duration.second * 2)
            socket.writeTimeout = Some(Duration.second * 2)
            let response = sendNativeH2SingleStreamRequest(
                socket,
                NativeH2ClientRequest(
                    "POST",
                    "http",
                    "localhost",
                    "/client-wire",
                    body: "abc".toArray()
                )
            )

            @Assert(response.status, UInt16(201))
            @Assert(response.header("x-native-h2-client") ?? "", "accepted")
            @Assert(response.body.size, 70000)
            @Assert(
                String.fromUtf8(nativeH2Slice(response.body, 0, 21)),
                "POST:/client-wire:abc"
            )
            let _ = serverFuture.get(Duration.second * 2)
        } finally {
            try { socket.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testNativeClientMultiplexesLargeResponsesAcrossSharedWindow(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H2 client test could not reserve loopback port")
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                serveNativeH2Connection(
                    accepted,
                    { request =>
                        if (request.path == "/slow") {
                            sleep(Duration.millisecond * 80)
                        }
                        let marker = if (request.path == "/slow") {
                            UInt8(0x73)
                        } else {
                            UInt8(0x66)
                        }
                        NativeH2SingleStreamResponse(
                            status: if (request.path == "/slow") { 202 } else { 203 },
                            headers: [NativeH2Header("x-stream-path", request.path)],
                            body: Array<UInt8>(70000, repeat: marker)
                        )
                    },
                    maxCompletedStreams: 2
                )
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let socket = TcpSocket("127.0.0.1", port)
        try {
            socket.connect(timeout: Some(Duration.second * 2))
            socket.readTimeout = Some(Duration.second * 2)
            socket.writeTimeout = Some(Duration.second * 2)
            let responses = sendNativeH2Requests(socket, [
                NativeH2ClientRequest("GET", "http", "localhost", "/slow"),
                NativeH2ClientRequest("GET", "http", "localhost", "/fast")
            ])

            @Assert(responses.size, 2)
            @Assert(responses[0].status, UInt16(202))
            @Assert(responses[0].header("x-stream-path") ?? "", "/slow")
            @Assert(responses[0].body.size, 70000)
            @Assert(responses[0].body[69999], UInt8(0x73))
            @Assert(responses[1].status, UInt16(203))
            @Assert(responses[1].header("x-stream-path") ?? "", "/fast")
            @Assert(responses[1].body.size, 70000)
            @Assert(responses[1].body[69999], UInt8(0x66))
            let _ = serverFuture.get(Duration.second * 2)
        } finally {
            try { socket.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testNativeClientReusesConnectionAcrossSequentialBatches(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H2 client test could not reserve loopback port")
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                serveNativeH2Connection(accepted, { request =>
                    NativeH2SingleStreamResponse(
                        status: 200,
                        headers: [NativeH2Header("x-stream-id", request.streamId.toString())],
                        body: request.path.toArray()
                    )
                })
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let socket = TcpSocket("127.0.0.1", port)
        try {
            socket.connect(timeout: Some(Duration.second * 2))
            socket.readTimeout = Some(Duration.second * 2)
            socket.writeTimeout = Some(Duration.second * 2)
            let connection = NativeH2ClientConnection(socket)
            let first = connection.send(
                NativeH2ClientRequest("GET", "http", "localhost", "/first")
            )
            let second = connection.send(
                NativeH2ClientRequest("GET", "http", "localhost", "/second")
            )
            connection.finish()

            @Assert(first.header("x-stream-id") ?? "", "1")
            @Assert(String.fromUtf8(first.body), "/first")
            @Assert(second.header("x-stream-id") ?? "", "3")
            @Assert(String.fromUtf8(second.body), "/second")
            let _ = serverFuture.get(Duration.second * 2)
        } finally {
            try { socket.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testNativeClientConsumesInformationalContinuationAndTrailers(): Unit {
        let response = nativeH2ClientResponseSequenceFixture({ socket, streamId =>
            nativeH2WriteFrame(
                socket,
                NativeH2Frame(
                    UInt8(0x1), UInt8(0x4), streamId,
                    nativeH2ClientTestEncodeResponseHead(
                        103,
                        [NativeH2Header("link", "</style.css>; rel=preload")]
                    )
                )
            )
            let finalHead = nativeH2ClientTestEncodeResponseHead(
                200,
                [NativeH2Header("x-final", "accepted")]
            )
            let split = finalHead.size / 2
            nativeH2WriteFrame(
                socket,
                NativeH2Frame(
                    UInt8(0x1), UInt8(0), streamId,
                    nativeH2Slice(finalHead, 0, split)
                )
            )
            nativeH2WriteFrame(
                socket,
                NativeH2Frame(
                    UInt8(0x9), UInt8(0x4), streamId,
                    nativeH2Slice(finalHead, split, finalHead.size)
                )
            )
            nativeH2WriteFrame(
                socket,
                NativeH2Frame(UInt8(0x0), UInt8(0), streamId, "body".toArray())
            )
            nativeH2WriteFrame(
                socket,
                NativeH2Frame(
                    UInt8(0x1), UInt8(0x5), streamId,
                    nativeH2ClientTestEncodeHeaders([
                        NativeH2Header("x-trailer", "complete")
                    ])
                )
            )
        })

        @Assert(response.status, UInt16(200))
        @Assert(response.header("x-final") ?? "", "accepted")
        @Assert(String.fromUtf8(response.body), "body")
        @Assert(response.informational.size, 1)
        @Assert(response.informational[0].status, UInt16(103))
        @Assert(response.informational[0].header("link") ?? "", "</style.css>; rel=preload")
        @Assert(response.trailers.size, 1)
        @Assert(response.trailers[0].name, "x-trailer")
        @Assert(response.trailers[0].value, "complete")
    }

    @TestCase
    public func testNativeClientUploadsBeyondInitialWindowAfterPeerUpdates(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H2 client upload test could not reserve loopback port")
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                let preface = nativeH2ReadExactly(accepted, NATIVE_H2_PREFACE.size)
                if (!nativeH2BytesEqual(preface, NATIVE_H2_PREFACE)) {
                    throw Exception("native H2 client upload fixture received invalid preface")
                }
                let clientSettings = nativeH2ReadFrame(accepted)
                @Assert(clientSettings.frameType, UInt8(0x4))
                @Assert(clientSettings.payload, nativeH2ClientSettingsPayload())
                nativeH2WriteFrame(
                    accepted,
                    NativeH2Frame(
                        UInt8(0x4), UInt8(0), 0,
                        [
                            UInt8(0), UInt8(4), UInt8(0), UInt8(0),
                            UInt8(0x80), UInt8(0)
                        ]
                    )
                )
                nativeH2WriteFrame(
                    accepted,
                    NativeH2Frame(UInt8(0x4), UInt8(0x1), 0, Array<UInt8>())
                )
                let clientAck = nativeH2ReadFrame(accepted)
                @Assert(clientAck.frameType, UInt8(0x4))
                @Assert(clientAck.flags & UInt8(0x1), UInt8(0x1))
                let requestHead = nativeH2ReadFrame(accepted)
                @Assert(requestHead.frameType, UInt8(0x1))

                var received: Int64 = 0
                while (received < 32768) {
                    let data = nativeH2ReadFrame(accepted)
                    @Assert(data.frameType, UInt8(0x0))
                    received += data.payload.size
                    @Assert(data.flags & UInt8(0x1), UInt8(0))
                }
                @Assert(received, 32768)
                nativeH2WriteFrame(
                    accepted,
                    NativeH2Frame(
                        UInt8(0x1), UInt8(0x5), requestHead.streamId,
                        nativeH2ClientTestEncodeResponseHead(
                            204,
                            [NativeH2Header("x-upload-size", "70000")]
                        )
                    )
                )
                nativeH2WriteFrame(accepted, nativeH2ClientWindowUpdate(0, 40000))
                nativeH2WriteFrame(accepted, nativeH2ClientWindowUpdate(requestHead.streamId, 40000))

                var ended = false
                while (!ended) {
                    let data = nativeH2ReadFrame(accepted)
                    @Assert(data.frameType, UInt8(0x0))
                    received += data.payload.size
                    ended = (data.flags & UInt8(0x1)) != UInt8(0)
                }
                @Assert(received, 70000)
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let socket = TcpSocket("127.0.0.1", port)
        try {
            socket.connect(timeout: Some(Duration.second * 2))
            socket.readTimeout = Some(Duration.second * 2)
            socket.writeTimeout = Some(Duration.second * 2)
            let response = sendNativeH2SingleStreamRequest(
                socket,
                NativeH2ClientRequest(
                    "POST",
                    "http",
                    "localhost",
                    "/large-upload",
                    body: Array<UInt8>(70000, repeat: UInt8(0x75))
                )
            )
            @Assert(response.status, UInt16(204))
            @Assert(response.header("x-upload-size") ?? "", "70000")
            let _ = serverFuture.get(Duration.second * 2)
        } finally {
            try { socket.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testNativeClientStreamsLargeBodyThenReusesConnection(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H2 streamed client test could not reserve loopback port")
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                serveNativeH2Connection(accepted, { request =>
                    NativeH2SingleStreamResponse(
                        status: 200,
                        headers: [NativeH2Header("x-stream-path", request.path)],
                        body: if (request.path == "/streamed") {
                            Array<UInt8>(70000, repeat: UInt8(0x73))
                        } else {
                            request.path.toArray()
                        }
                    )
                })
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let socket = TcpSocket("127.0.0.1", port)
        try {
            socket.connect(timeout: Some(Duration.second * 2))
            socket.readTimeout = Some(Duration.second * 2)
            socket.writeTimeout = Some(Duration.second * 2)
            let connection = NativeH2ClientConnection(socket)
            let streamed = connection.sendStreamed(
                NativeH2ClientRequest("GET", "http", "localhost", "/streamed")
            )
            var concurrentSendRejected = false
            try {
                let _ = connection.send(
                    NativeH2ClientRequest("GET", "http", "localhost", "/must-wait")
                )
            } catch (_: Exception) {
                concurrentSendRejected = true
            }
            var finishRejected = false
            try {
                connection.finish()
            } catch (_: Exception) {
                finishRejected = true
            }
            @Assert(concurrentSendRejected, true)
            @Assert(finishRejected, true)
            let body = streamed.bodyStream()
            let chunk = Array<UInt8>(4096, repeat: 0)
            var total: Int64 = 0
            while (true) {
                let count = body.read(chunk)
                if (count <= 0) {
                    break
                }
                total += count
                @Assert(chunk[0], UInt8(0x73))
            }
            @Assert(total, 70000)
            @Assert(streamed.trailers().size, 0)

            let following = connection.send(
                NativeH2ClientRequest("GET", "http", "localhost", "/following")
            )
            connection.finish()
            @Assert(String.fromUtf8(following.body), "/following")
            let _ = serverFuture.get(Duration.second * 2)
        } finally {
            try { socket.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testNativeClientCancelsUnreadStreamAndInvalidatesConnection(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H2 cancel test could not reserve loopback port")
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                let streamId = nativeH2ClientTestHandshakeAndReadRequest(accepted)
                nativeH2WriteFrame(
                    accepted,
                    NativeH2Frame(
                        UInt8(0x1), UInt8(0x4), streamId,
                        nativeH2ClientTestEncodeResponseHead(
                            200, [NativeH2Header("x-cancel", "ready")]
                        )
                    )
                )
                nativeH2WriteFrame(
                    accepted,
                    NativeH2Frame(
                        UInt8(0x0), UInt8(0), streamId,
                        Array<UInt8>(4096, repeat: UInt8(0x63))
                    )
                )
                let reset = nativeH2ReadFrame(accepted)
                @Assert(reset.frameType, UInt8(0x3))
                @Assert(reset.streamId, streamId)
                @Assert(nativeH2ClientDecode32Bit(reset.payload, 0), NATIVE_H2_ERROR_CANCEL)
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let socket = TcpSocket("127.0.0.1", port)
        try {
            socket.connect(timeout: Some(Duration.second * 2))
            socket.readTimeout = Some(Duration.second * 2)
            socket.writeTimeout = Some(Duration.second * 2)
            let connection = NativeH2ClientConnection(socket)
            let streamed = connection.sendStreamed(
                NativeH2ClientRequest("GET", "http", "localhost", "/cancel")
            )
            let chunk = Array<UInt8>(64, repeat: 0)
            @Assert(streamed.bodyStream().read(chunk), 64)
            streamed.close()

            var rejected = false
            try {
                let _ = connection.send(
                    NativeH2ClientRequest("GET", "http", "localhost", "/after-cancel")
                )
            } catch (_: Exception) {
                rejected = true
            }
            @Assert(rejected, true)
            let _ = serverFuture.get(Duration.second * 2)
        } finally {
            try { socket.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testNativeClientRejectsInterruptedContinuationSequence(): Unit {
        let failure = nativeH2ClientFailureFixture(
            { socket, streamId =>
                let head = nativeH2ClientTestEncodeResponseHead(200, Array<NativeH2Header>())
                nativeH2WriteFrame(
                    socket,
                    NativeH2Frame(
                        UInt8(0x1), UInt8(0), streamId,
                        nativeH2Slice(head, 0, 1)
                    )
                )
                nativeH2WriteFrame(
                    socket,
                    NativeH2Frame(
                        UInt8(0x6), UInt8(0), 0,
                        Array<UInt8>(8, repeat: UInt8(0))
                    )
                )
            },
            Duration.second * 2
        )
        @Assert(failure.failureKind, "protocol")
        @Assert(failure.streamId, 1)
        @Assert(failure.errorCode, NATIVE_H2_ERROR_PROTOCOL)
    }

    @TestCase
    public func testNativeClientClassifiesResetAndGoAway(): Unit {
        let reset = nativeH2ClientFailureFixture(
            { socket, streamId =>
                let payload = Array<UInt8>(4, repeat: 0)
                payload[3] = UInt8(0x8)
                nativeH2WriteFrame(socket, NativeH2Frame(UInt8(0x3), UInt8(0), streamId, payload))
            },
            Duration.second * 2
        )
        @Assert(reset.failureKind, "reset")
        @Assert(reset.streamId, 1)
        @Assert(reset.errorCode, 8)

        let goAway = nativeH2ClientFailureFixture(
            { socket, streamId =>
                nativeH2WriteFrame(
                    socket,
                    NativeH2Frame(
                        UInt8(0x7), UInt8(0), 0,
                        nativeH2GoAwayPayload(streamId, NATIVE_H2_ERROR_PROTOCOL)
                    )
                )
            },
            Duration.second * 2
        )
        @Assert(goAway.failureKind, "goaway")
        @Assert(goAway.streamId, 1)
        @Assert(goAway.errorCode, NATIVE_H2_ERROR_PROTOCOL)
    }

    @TestCase
    public func testNativeClientClassifiesTimeoutAndPeerClose(): Unit {
        let timeout = nativeH2ClientFailureFixture(
            { _, _ => sleep(Duration.millisecond * 120) },
            Duration.millisecond * 30
        )
        @Assert(timeout.failureKind, "timeout")

        let peerClose = nativeH2ClientFailureFixture(
            { _, _ => },
            Duration.second * 2
        )
        @Assert(peerClose.failureKind, "peer-close")
    }
}

func nativeH2ClientFailureFixture(
    serverAction: (TcpSocket, Int64) -> Unit,
    readTimeout: Duration
): NativeH2ClientException {
    let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
    listener.bind()
    let port = (listener.localAddress as IPSocketAddress)?.port ??
        throw Exception("native H2 client failure test could not reserve loopback port")
    let serverFuture = spawn {
        let accepted = listener.accept()
        try {
            let streamId = nativeH2ClientTestHandshakeAndReadRequest(accepted)
            serverAction(accepted, streamId)
        } finally {
            try { accepted.close() } catch (_: Exception) {}
        }
    }

    let socket = TcpSocket("127.0.0.1", port)
    var observed: ?NativeH2ClientException = None
    try {
        socket.connect(timeout: Some(Duration.second * 2))
        socket.readTimeout = Some(readTimeout)
        socket.writeTimeout = Some(Duration.second * 2)
        try {
            let _ = sendNativeH2SingleStreamRequest(
                socket,
                NativeH2ClientRequest("GET", "http", "localhost", "/failure")
            )
        } catch (e: NativeH2ClientException) {
            observed = Some(e)
        }
        let _ = serverFuture.get(Duration.second * 2)
    } finally {
        try { socket.close() } catch (_: Exception) {}
        try { listener.close() } catch (_: Exception) {}
    }
    observed ?? throw Exception("native H2 client failure fixture did not fail")
}

func nativeH2ClientResponseSequenceFixture(
    serverAction: (TcpSocket, Int64) -> Unit
): NativeH2ClientResponse {
    let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
    listener.bind()
    let port = (listener.localAddress as IPSocketAddress)?.port ??
        throw Exception("native H2 client response fixture could not reserve loopback port")
    let serverFuture = spawn {
        let accepted = listener.accept()
        try {
            let streamId = nativeH2ClientTestHandshakeAndReadRequest(accepted)
            serverAction(accepted, streamId)
        } finally {
            try { accepted.close() } catch (_: Exception) {}
        }
    }

    let socket = TcpSocket("127.0.0.1", port)
    try {
        socket.connect(timeout: Some(Duration.second * 2))
        socket.readTimeout = Some(Duration.second * 2)
        socket.writeTimeout = Some(Duration.second * 2)
        let response = sendNativeH2SingleStreamRequest(
            socket,
            NativeH2ClientRequest("GET", "http", "localhost", "/response-sequence")
        )
        let _ = serverFuture.get(Duration.second * 2)
        response
    } finally {
        try { socket.close() } catch (_: Exception) {}
        try { listener.close() } catch (_: Exception) {}
    }
}

func nativeH2ClientTestEncodeResponseHead(
    status: UInt16,
    headers: Array<NativeH2Header>
): Array<UInt8> {
    let out = ArrayList<UInt8>()
    out.add(UInt8(0x08))
    out.add(UInt8(0x03))
    nativeH2AppendBytes(out, status.toString().toArray())
    nativeH2AppendBytes(out, nativeH2ClientTestEncodeHeaders(headers))
    out.toArray()
}

func nativeH2ClientTestEncodeHeaders(headers: Array<NativeH2Header>): Array<UInt8> {
    let out = ArrayList<UInt8>()
    for (header in headers) {
        let name = header.name.toArray()
        let value = header.value.toArray()
        out.add(UInt8(0))
        out.add(UInt8(name.size))
        nativeH2AppendBytes(out, name)
        out.add(UInt8(value.size))
        nativeH2AppendBytes(out, value)
    }
    out.toArray()
}

func nativeH2ClientTestHandshakeAndReadRequest(socket: TcpSocket): Int64 {
    let preface = nativeH2ReadExactly(socket, NATIVE_H2_PREFACE.size)
    if (!nativeH2BytesEqual(preface, NATIVE_H2_PREFACE)) {
        throw Exception("native H2 client failure fixture received invalid preface")
    }
    let settings = nativeH2ReadFrame(socket)
    if (settings.frameType != UInt8(0x4) || settings.streamId != 0) {
        throw Exception("native H2 client failure fixture expected SETTINGS")
    }
    nativeH2WriteFrame(socket, NativeH2Frame(UInt8(0x4), UInt8(0), 0, Array<UInt8>()))
    nativeH2WriteFrame(socket, NativeH2Frame(UInt8(0x4), UInt8(0x1), 0, Array<UInt8>()))
    let ack = nativeH2ReadFrame(socket)
    if (ack.frameType != UInt8(0x4) || (ack.flags & UInt8(0x1)) == UInt8(0)) {
        throw Exception("native H2 client failure fixture expected SETTINGS ACK")
    }
    let request = nativeH2ReadFrame(socket)
    if (request.frameType != UInt8(0x1)) {
        throw Exception("native H2 client failure fixture expected request HEADERS")
    }
    request.streamId
}
