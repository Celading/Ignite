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
}
