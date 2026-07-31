package ignite.native_h2

import std.net.{IPSocketAddress, TcpServerSocket, TcpSocket}

@Test
public class NativeH2MultiplexInternalTestSuite {
    @TestCase
    public func testPeerConcurrentLimitRejectsBeforeSecondStreamReservation(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("Native H2 multiplex peer-limit test could not reserve a port")
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                let preface = nativeH2ReadExactly(
                    NativeH2TcpTransport(accepted), NATIVE_H2_PREFACE.size
                )
                @Assert(nativeH2BytesEqual(preface, NATIVE_H2_PREFACE), true)
                let transport = NativeH2TcpTransport(accepted)
                let clientSettings = nativeH2ReadFrame(transport)
                @Assert(clientSettings.frameType, UInt8(0x4))
                nativeH2WriteFrame(
                    transport,
                    NativeH2Frame(
                        UInt8(0x4), UInt8(0), 0,
                        [UInt8(0), UInt8(3), UInt8(0), UInt8(0), UInt8(0), UInt8(1)]
                    )
                )
                nativeH2WriteFrame(
                    transport,
                    NativeH2Frame(UInt8(0x4), UInt8(0x1), 0, Array<UInt8>())
                )
                let clientAck = nativeH2ReadFrame(transport)
                @Assert(clientAck.frameType, UInt8(0x4))
                @Assert(clientAck.flags & UInt8(0x1), UInt8(0x1))

                let request = nativeH2ReadFrame(transport)
                @Assert(request.frameType, UInt8(0x1))
                @Assert(request.streamId, Int64(1))
                nativeH2WriteFrame(
                    transport,
                    NativeH2Frame(
                        UInt8(0x1), UInt8(0x4), 1,
                        nativeH2EncodeResponseHead(200, Array<NativeH2Header>())
                    )
                )
                let reset = nativeH2ReadFrame(transport)
                @Assert(reset.frameType, UInt8(0x3))
                @Assert(reset.streamId, Int64(1))
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let socket = TcpSocket("127.0.0.1", port)
        socket.readTimeout = Some(Duration.second * 2)
        socket.writeTimeout = Some(Duration.second * 2)
        socket.connect(timeout: Some(Duration.second * 2))
        let connection = NativeH2ClientConnection(socket)
        let session = connection.openMultiplexSession(maxConcurrentStreams: 4)
        try {
            let first = session.send(
                NativeH2ClientRequest("GET", "http", "127.0.0.1:${port}", "/one")
            )
            @Assert(session.maxConcurrentStreams(), Int64(1))
            var message = ""
            try {
                let _ = session.send(
                    NativeH2ClientRequest("GET", "http", "127.0.0.1:${port}", "/two")
                )
            } catch (e: Exception) {
                message = e.message
            }
            @Assert(message.contains("active stream limit 1 reached"), true)
            @Assert(connection.nextStreamId, Int64(3))
            first.close()
            @Assert(session.close(), false)
            let _ = serverFuture.get(Duration.second * 5)
        } finally {
            let _ = session.close()
            try { socket.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
        }
    }
}
