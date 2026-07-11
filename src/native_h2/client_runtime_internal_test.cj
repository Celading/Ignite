package ignite.native_h2

import ignite.App
import std.net.{IPSocketAddress, TcpServerSocket, TcpSocket}

@Test
public class NativeH2ClientRuntimeInternalTestSuite {
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
