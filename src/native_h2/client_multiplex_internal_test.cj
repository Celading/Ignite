package ignite.native_h2

import std.io.InputStream
import std.net.{IPSocketAddress, TcpServerSocket, TcpSocket}
import std.sync.{AtomicBool, AtomicInt64}

class NativeH2MultiplexChunkedInput <: InputStream {
    let data: Array<UInt8>
    let chunkSize: Int64
    let delayMs: Int64
    let eofGate: ?AtomicBool
    let consumed = AtomicInt64(0)
    let maxRequested = AtomicInt64(0)
    var offset: Int64 = 0

    init(
        data: Array<UInt8>,
        chunkSize!: Int64 = 4096,
        delayMs!: Int64 = 0,
        eofGate!: ?AtomicBool = None
    ) {
        this.data = data
        this.chunkSize = chunkSize
        this.delayMs = delayMs
        this.eofGate = eofGate
    }

    public override func read(outBuf: Array<Byte>): Int64 {
        if (offset >= data.size || outBuf.size == 0) {
            if (outBuf.size > 0) {
                if (let Some(gate) <- eofGate) {
                    while (!gate.load()) {
                        sleep(Duration.millisecond)
                    }
                }
            }
            return 0
        }
        if (outBuf.size > maxRequested.load()) {
            maxRequested.store(outBuf.size)
        }
        if (delayMs > 0) {
            sleep(Duration.millisecond * delayMs)
        }
        let count = min(min(outBuf.size, chunkSize), data.size - offset)
        for (index in 0..count) {
            outBuf[index] = data[offset + index]
        }
        offset += count
        consumed.store(offset)
        count
    }

    func bytesRead(): Int64 {
        consumed.load()
    }

    func largestRequestedRead(): Int64 {
        maxRequested.load()
    }
}

class NativeH2MultiplexBlockedEofInput <: InputStream {
    let entered = AtomicBool(false)
    let released = AtomicBool(false)

    public override func read(outBuf: Array<Byte>): Int64 {
        let _ = outBuf
        entered.store(true)
        while (!released.load()) {
            sleep(Duration.millisecond)
        }
        0
    }

    func readStarted(): Bool {
        entered.load()
    }

    func release(): Unit {
        released.store(true)
    }
}

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

    @TestCase
    public func testBufferedUploadsUseWindowFeedbackWithoutBlockingSiblingAndReuse(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("Native H2 multiplex upload test could not reserve a port")
        let allowLargeUpload = AtomicBool(false)
        let serverStage = AtomicInt64(0)
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                nativeH2MultiplexTestHandshake(accepted)
                serverStage.store(1)
                let largeHead = nativeH2ReadFrame(accepted)
                @Assert(largeHead.frameType, UInt8(0x1))
                @Assert(largeHead.flags, UInt8(0x4))
                @Assert(largeHead.streamId, Int64(1))

                var largeBytes: Int64 = 0
                while (largeBytes < NATIVE_H2_INITIAL_FLOW_WINDOW) {
                    let data = nativeH2ReadFrame(accepted)
                    @Assert(data.frameType, UInt8(0x0))
                    @Assert(data.streamId, Int64(1))
                    @Assert(data.flags & UInt8(0x1), UInt8(0))
                    largeBytes += data.payload.size
                }
                @Assert(largeBytes, NATIVE_H2_INITIAL_FLOW_WINDOW)
                serverStage.store(2)

                let siblingHead = nativeH2ReadFrame(accepted)
                @Assert(siblingHead.frameType, UInt8(0x1))
                @Assert(siblingHead.flags, UInt8(0x4))
                @Assert(siblingHead.streamId, Int64(3))
                serverStage.store(3)
                nativeH2WriteFrame(accepted, nativeH2ClientWindowUpdate(0, 5))
                let siblingData = nativeH2ReadFrame(accepted)
                @Assert(siblingData.frameType, UInt8(0x0))
                @Assert(siblingData.streamId, Int64(3))
                @Assert(siblingData.flags & UInt8(0x1), UInt8(0x1))
                @Assert(String.fromUtf8(siblingData.payload), "small")
                nativeH2MultiplexWriteResponse(accepted, 3, "sibling")
                serverStage.store(4)

                while (!allowLargeUpload.load()) {
                    sleep(Duration.millisecond * 2)
                }
                nativeH2WriteFrame(accepted, nativeH2ClientWindowUpdate(1, 2000))
                nativeH2WriteFrame(accepted, nativeH2ClientWindowUpdate(0, 2000))
                let resumed = nativeH2ReadFrame(accepted)
                @Assert(resumed.frameType, UInt8(0x0))
                @Assert(resumed.streamId, Int64(1))
                @Assert(resumed.payload.size, Int64(2000))
                @Assert(resumed.flags & UInt8(0x1), UInt8(0))
                largeBytes += resumed.payload.size
                serverStage.store(5)

                nativeH2WriteFrame(
                    accepted,
                    NativeH2Frame(
                        UInt8(0x4), UInt8(0), 0,
                        [UInt8(0), UInt8(4), UInt8(0), UInt8(1), UInt8(0x09), UInt8(0xa0)]
                    )
                )
                nativeH2WriteFrame(accepted, nativeH2ClientWindowUpdate(0, 2465))
                let settingsAck = nativeH2ReadFrame(accepted)
                @Assert(settingsAck.frameType, UInt8(0x4))
                @Assert(settingsAck.flags & UInt8(0x1), UInt8(0x1))
                let finalData = nativeH2ReadFrame(accepted)
                @Assert(finalData.frameType, UInt8(0x0))
                @Assert(finalData.streamId, Int64(1))
                @Assert(finalData.payload.size, Int64(2465))
                @Assert(finalData.flags & UInt8(0x1), UInt8(0x1))
                largeBytes += finalData.payload.size
                @Assert(largeBytes, Int64(70000))
                nativeH2MultiplexWriteResponse(accepted, 1, "large")
                serverStage.store(6)

                let reusedHead = nativeH2ReadFrame(accepted)
                @Assert(reusedHead.frameType, UInt8(0x1))
                @Assert(reusedHead.flags, UInt8(0x5))
                @Assert(reusedHead.streamId, Int64(5))
                nativeH2MultiplexWriteResponse(accepted, 5, "reused")
                serverStage.store(7)
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
            let largeFuture = spawn {
                session.send(
                    NativeH2ClientRequest(
                        "POST", "http", "127.0.0.1:${port}", "/large",
                        body: Array<UInt8>(70000, repeat: UInt8(0x75))
                    )
                )
            }
            nativeH2WaitForMultiplexStreams(session, 1)
            let siblingFuture = spawn {
                session.send(
                    NativeH2ClientRequest(
                        "POST", "http", "127.0.0.1:${port}", "/small",
                        body: "small".toArray()
                    )
                )
            }

            let sibling = try {
                siblingFuture.get(Duration.second * 5)
            } catch (e: Exception) {
                throw Exception(
                    "Native H2 multiplex sibling failed at server stage ${serverStage.load()}: " +
                        e.message
                )
            }
            @Assert(sibling.header("x-multiplex-result") ?? "", "sibling")
            sibling.close()
            allowLargeUpload.store(true)

            let large = largeFuture.get(Duration.second * 5)
            @Assert(large.header("x-multiplex-result") ?? "", "large")
            large.close()
            @Assert(session.activeStreams(), Int64(0))
            @Assert(session.outbound.size, Int64(0))
            @Assert(session.outboundOrder.size, Int64(0))
            @Assert(session.outboundCursor, Int64(0))
            @Assert(session.close(), true)

            let reused = connection.openMultiplexSession(maxConcurrentStreams: 2)
            try {
                let response = reused.send(
                    NativeH2ClientRequest(
                        "GET", "http", "127.0.0.1:${port}", "/reused"
                    )
                )
                @Assert(response.header("x-multiplex-result") ?? "", "reused")
                response.close()
                @Assert(reused.close(), true)
            } finally {
                let _ = reused.close()
            }
            let _ = serverFuture.get(Duration.second * 5)
        } finally {
            allowLargeUpload.store(true)
            let _ = session.close()
            try { socket.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testEarlyResponseCancellationSettlesPendingUploadAndRetires(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("Native H2 multiplex cancellation test could not reserve a port")
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                nativeH2MultiplexTestHandshake(accepted)
                let largeHead = nativeH2ReadFrame(accepted)
                @Assert(largeHead.streamId, Int64(1))
                var received: Int64 = 0
                while (received < NATIVE_H2_INITIAL_FLOW_WINDOW) {
                    let data = nativeH2ReadFrame(accepted)
                    @Assert(data.frameType, UInt8(0x0))
                    @Assert(data.streamId, Int64(1))
                    received += data.payload.size
                }
                @Assert(received, NATIVE_H2_INITIAL_FLOW_WINDOW)
                let siblingHead = nativeH2ReadFrame(accepted)
                @Assert(siblingHead.frameType, UInt8(0x1))
                @Assert(siblingHead.flags, UInt8(0x5))
                @Assert(siblingHead.streamId, Int64(3))

                nativeH2MultiplexWriteResponse(accepted, 1, "early")
                nativeH2MultiplexWriteResponse(accepted, 3, "sibling")
                let reset = nativeH2ReadFrame(accepted)
                @Assert(reset.frameType, UInt8(0x3))
                @Assert(reset.streamId, Int64(1))
                @Assert(nativeH2ClientDecode32Bit(reset.payload, 0), NATIVE_H2_ERROR_CANCEL)
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
            let largeFuture = spawn {
                session.send(
                    NativeH2ClientRequest(
                        "POST", "http", "127.0.0.1:${port}", "/cancel",
                        body: Array<UInt8>(70000, repeat: UInt8(0x63))
                    )
                )
            }
            nativeH2WaitForMultiplexStreams(session, 1)
            let siblingFuture = spawn {
                session.send(
                    NativeH2ClientRequest(
                        "GET", "http", "127.0.0.1:${port}", "/sibling"
                    )
                )
            }

            let early = largeFuture.get(Duration.second * 5)
            @Assert(early.header("x-multiplex-result") ?? "", "early")
            early.close()
            let sibling = siblingFuture.get(Duration.second * 5)
            @Assert(sibling.header("x-multiplex-result") ?? "", "sibling")
            sibling.close()

            @Assert(session.outbound.size, Int64(0))
            @Assert(session.outboundOrder.size, Int64(0))
            @Assert(session.outboundCursor, Int64(0))
            @Assert(session.activeStreams(), Int64(0))
            @Assert(connection.retiring, true)
            @Assert(session.close(), false)
            let _ = serverFuture.get(Duration.second * 5)
        } finally {
            let _ = session.close()
            try { socket.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testKnownLengthStreamUsesBoundedProducerAndWindowFeedback(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("Native H2 streamed upload test could not reserve a port")
        let allowRemainder = AtomicBool(false)
        let serverStage = AtomicInt64(0)
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                nativeH2MultiplexTestHandshake(accepted)
                var largeBytes: Int64 = 0
                var siblingHeadSeen = false
                while (largeBytes < NATIVE_H2_INITIAL_FLOW_WINDOW || !siblingHeadSeen) {
                    let frame = nativeH2ReadFrame(accepted)
                    if (frame.frameType == UInt8(0x1) && frame.streamId == 1) {
                        @Assert(frame.flags, UInt8(0x4))
                    } else if (frame.frameType == UInt8(0x1) && frame.streamId == 3) {
                        @Assert(frame.flags, UInt8(0x5))
                        siblingHeadSeen = true
                    } else {
                        @Assert(frame.frameType, UInt8(0x0))
                        @Assert(frame.streamId, Int64(1))
                        @Assert(frame.flags & UInt8(0x1), UInt8(0))
                        for (value in frame.payload) {
                            @Assert(value, UInt8(0x73))
                        }
                        largeBytes += frame.payload.size
                    }
                }
                @Assert(largeBytes, NATIVE_H2_INITIAL_FLOW_WINDOW)
                nativeH2MultiplexWriteResponse(accepted, 3, "sibling")
                serverStage.store(1)

                while (!allowRemainder.load()) {
                    sleep(Duration.millisecond * 2)
                }
                let remaining = Int64(100000) - largeBytes
                nativeH2WriteFrame(accepted, nativeH2ClientWindowUpdate(1, remaining))
                nativeH2WriteFrame(accepted, nativeH2ClientWindowUpdate(0, remaining))
                while (largeBytes < 100000) {
                    let data = nativeH2ReadFrame(accepted)
                    @Assert(data.frameType, UInt8(0x0))
                    @Assert(data.streamId, Int64(1))
                    for (value in data.payload) {
                        @Assert(value, UInt8(0x73))
                    }
                    largeBytes += data.payload.size
                    if (largeBytes < 100000) {
                        @Assert(data.flags & UInt8(0x1), UInt8(0))
                    } else {
                        @Assert(data.flags & UInt8(0x1), UInt8(0x1))
                    }
                }
                nativeH2MultiplexWriteResponse(accepted, 1, "streamed")
                serverStage.store(2)
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let socket = TcpSocket("127.0.0.1", port)
        socket.readTimeout = Some(Duration.second * 3)
        socket.writeTimeout = Some(Duration.second * 3)
        socket.connect(timeout: Some(Duration.second * 2))
        let connection = NativeH2ClientConnection(socket)
        let session = connection.openMultiplexSession(maxConcurrentStreams: 4)
        let source = NativeH2MultiplexChunkedInput(
            Array<UInt8>(100000, repeat: UInt8(0x73)),
            chunkSize: 4096,
            delayMs: 1
        )
        try {
            let largeFuture = spawn {
                session.sendStream(
                    NativeH2ClientRequest(
                        "POST", "http", "127.0.0.1:${port}", "/streamed",
                        headers: [NativeH2Header("content-length", "100000")]
                    ),
                    source,
                    100000
                )
            }
            nativeH2WaitForMultiplexStreams(session, 1)
            let siblingFuture = spawn {
                session.send(
                    NativeH2ClientRequest(
                        "GET", "http", "127.0.0.1:${port}", "/sibling"
                    )
                )
            }
            let sibling = siblingFuture.get(Duration.second * 5)
            @Assert(sibling.header("x-multiplex-result") ?? "", "sibling")
            sibling.close()

            var buffered: Int64 = 0
            synchronized(session.stateMutex) {
                if (let Some(upload) <- session.outbound.get(1)) {
                    buffered = upload.queuedBytes
                }
            }
            @Assert(buffered <= NATIVE_H2_MULTIPLEX_UPLOAD_BUFFER_LIMIT, true)
            @Assert(source.bytesRead() < Int64(100000), true)
            @Assert(
                source.largestRequestedRead() <= NATIVE_H2_MULTIPLEX_UPLOAD_READ_CHUNK,
                true
            )

            allowRemainder.store(true)
            let large = try {
                largeFuture.get(Duration.second * 5)
            } catch (e: Exception) {
                throw Exception(
                    "Native H2 streamed upload failed at server stage ${serverStage.load()}: " +
                        e.message
                )
            }
            @Assert(large.header("x-multiplex-result") ?? "", "streamed")
            large.close()
            @Assert(source.bytesRead(), Int64(100000))
            @Assert(session.outbound.size, Int64(0))
            @Assert(session.outboundOrder.size, Int64(0))
            @Assert(session.activeStreams(), Int64(0))
            @Assert(session.close(), true)
            let _ = serverFuture.get(Duration.second * 5)
        } finally {
            allowRemainder.store(true)
            let _ = session.close()
            try { socket.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testUnknownLengthStreamUsesBoundedProducerAndWindowFeedback(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("Native H2 unknown-length upload test could not reserve a port")
        let allowRemainder = AtomicBool(false)
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                nativeH2MultiplexTestHandshake(accepted)
                var uploaded: Int64 = 0
                var siblingHeadSeen = false
                while (uploaded < NATIVE_H2_INITIAL_FLOW_WINDOW || !siblingHeadSeen) {
                    let frame = nativeH2ReadFrame(accepted)
                    if (frame.frameType == UInt8(0x1) && frame.streamId == 1) {
                        @Assert(frame.flags, UInt8(0x4))
                    } else if (frame.frameType == UInt8(0x1) && frame.streamId == 3) {
                        @Assert(frame.flags, UInt8(0x5))
                        siblingHeadSeen = true
                    } else {
                        @Assert(frame.frameType, UInt8(0x0))
                        @Assert(frame.streamId, Int64(1))
                        @Assert(frame.flags & UInt8(0x1), UInt8(0))
                        for (value in frame.payload) {
                            @Assert(value, UInt8(0x74))
                        }
                        uploaded += frame.payload.size
                    }
                }
                @Assert(uploaded, NATIVE_H2_INITIAL_FLOW_WINDOW)
                nativeH2MultiplexWriteResponse(accepted, 3, "sibling")

                while (!allowRemainder.load()) {
                    sleep(Duration.millisecond * 2)
                }
                let remaining = Int64(100000) - uploaded
                nativeH2WriteFrame(accepted, nativeH2ClientWindowUpdate(1, remaining))
                nativeH2WriteFrame(accepted, nativeH2ClientWindowUpdate(0, remaining))
                var endStreamFrames: Int64 = 0
                while (endStreamFrames == 0) {
                    let data = nativeH2ReadFrame(accepted)
                    @Assert(data.frameType, UInt8(0x0))
                    @Assert(data.streamId, Int64(1))
                    for (value in data.payload) {
                        @Assert(value, UInt8(0x74))
                    }
                    uploaded += data.payload.size
                    if ((data.flags & UInt8(0x1)) != UInt8(0)) {
                        endStreamFrames += 1
                    }
                }
                @Assert(uploaded, Int64(100000))
                @Assert(endStreamFrames, Int64(1))
                nativeH2MultiplexWriteResponse(accepted, 1, "unknown-length")
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let socket = TcpSocket("127.0.0.1", port)
        socket.readTimeout = Some(Duration.second * 3)
        socket.writeTimeout = Some(Duration.second * 3)
        socket.connect(timeout: Some(Duration.second * 2))
        let connection = NativeH2ClientConnection(socket)
        let session = connection.openMultiplexSession(maxConcurrentStreams: 4)
        let source = NativeH2MultiplexChunkedInput(
            Array<UInt8>(100000, repeat: UInt8(0x74)),
            chunkSize: 4096,
            delayMs: 1
        )
        try {
            let uploadFuture = spawn {
                session.sendStream(
                    NativeH2ClientRequest(
                        "POST", "http", "127.0.0.1:${port}", "/unknown-length"
                    ),
                    source
                )
            }
            nativeH2WaitForMultiplexStreams(session, 1)
            let siblingFuture = spawn {
                session.send(
                    NativeH2ClientRequest(
                        "GET", "http", "127.0.0.1:${port}", "/sibling"
                    )
                )
            }
            let sibling = siblingFuture.get(Duration.second * 5)
            @Assert(sibling.header("x-multiplex-result") ?? "", "sibling")
            sibling.close()

            var buffered: Int64 = 0
            synchronized(session.stateMutex) {
                if (let Some(upload) <- session.outbound.get(1)) {
                    buffered = upload.queuedBytes
                }
            }
            @Assert(buffered <= NATIVE_H2_MULTIPLEX_UPLOAD_BUFFER_LIMIT, true)
            @Assert(source.bytesRead() < Int64(100000), true)
            @Assert(
                source.largestRequestedRead() <= NATIVE_H2_MULTIPLEX_UPLOAD_READ_CHUNK,
                true
            )

            allowRemainder.store(true)
            let upload = uploadFuture.get(Duration.second * 5)
            @Assert(upload.header("x-multiplex-result") ?? "", "unknown-length")
            upload.close()
            @Assert(source.bytesRead(), Int64(100000))
            @Assert(session.outbound.size, Int64(0))
            @Assert(session.outboundOrder.size, Int64(0))
            @Assert(session.activeStreams(), Int64(0))
            @Assert(session.close(), true)
            let _ = serverFuture.get(Duration.second * 5)
        } finally {
            allowRemainder.store(true)
            let _ = session.close()
            try { socket.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testUnknownLengthBlockedSourceDoesNotHoldProtocolLock(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("Native H2 blocked-source test could not reserve a port")
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                nativeH2MultiplexTestHandshake(accepted)
                let uploadHead = nativeH2ReadFrame(accepted)
                @Assert(uploadHead.frameType, UInt8(0x1))
                @Assert(uploadHead.streamId, Int64(1))
                @Assert(uploadHead.flags, UInt8(0x4))

                let siblingHead = nativeH2ReadFrame(accepted)
                @Assert(siblingHead.frameType, UInt8(0x1))
                @Assert(siblingHead.streamId, Int64(3))
                @Assert(siblingHead.flags, UInt8(0x5))
                nativeH2MultiplexWriteResponse(accepted, 3, "sibling")
                nativeH2MultiplexWriteResponse(accepted, 1, "blocked-source")

                let reset = nativeH2ReadFrame(accepted)
                @Assert(reset.frameType, UInt8(0x3))
                @Assert(reset.streamId, Int64(1))
                @Assert(
                    nativeH2ClientDecode32Bit(reset.payload, 0),
                    NATIVE_H2_ERROR_CANCEL
                )
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let socket = TcpSocket("127.0.0.1", port)
        socket.readTimeout = Some(Duration.second * 3)
        socket.writeTimeout = Some(Duration.second * 3)
        socket.connect(timeout: Some(Duration.second * 2))
        let connection = NativeH2ClientConnection(socket)
        let session = connection.openMultiplexSession(maxConcurrentStreams: 4)
        let source = NativeH2MultiplexBlockedEofInput()
        try {
            let uploadFuture = spawn {
                session.sendStream(
                    NativeH2ClientRequest(
                        "POST", "http", "127.0.0.1:${port}", "/blocked-source"
                    ),
                    source
                )
            }
            nativeH2WaitForMultiplexStreams(session, 1)
            var attempts: Int64 = 0
            while (!source.readStarted() && attempts < 400) {
                sleep(Duration.millisecond * 5)
                attempts += 1
            }
            if (!source.readStarted()) {
                throw Exception("Native H2 blocked-source test did not begin the source read")
            }

            let siblingFuture = spawn {
                session.send(
                    NativeH2ClientRequest(
                        "GET", "http", "127.0.0.1:${port}", "/sibling"
                    )
                )
            }
            let sibling = siblingFuture.get(Duration.second * 5)
            @Assert(sibling.header("x-multiplex-result") ?? "", "sibling")
            sibling.close()

            let upload = uploadFuture.get(Duration.second * 5)
            @Assert(upload.header("x-multiplex-result") ?? "", "blocked-source")
            upload.close()
            @Assert(session.outbound.size, Int64(0))
            @Assert(session.outboundOrder.size, Int64(0))
            @Assert(session.activeStreams(), Int64(0))
            @Assert(connection.retiring, true)
            @Assert(session.close(), false)
            let _ = serverFuture.get(Duration.second * 5)
        } finally {
            source.release()
            let _ = session.close()
            try { socket.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testUnknownLengthStreamEarlyResponseStopsProducerAndPreservesSibling(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("Native H2 streamed early-response test could not reserve a port")
        let serverStage = AtomicInt64(0)
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                nativeH2MultiplexTestHandshake(accepted)
                var siblingHeadSeen = false
                var streamedBytes: Int64 = 0
                while (!siblingHeadSeen) {
                    let frame = nativeH2ReadFrame(accepted)
                    if (frame.frameType == UInt8(0x1) && frame.streamId == 3) {
                        @Assert(frame.flags, UInt8(0x5))
                        siblingHeadSeen = true
                    } else if (frame.frameType == UInt8(0x1) && frame.streamId == 1) {
                        @Assert(frame.flags, UInt8(0x4))
                    } else {
                        @Assert(frame.frameType, UInt8(0x0))
                        @Assert(frame.streamId, Int64(1))
                        @Assert(frame.flags & UInt8(0x1), UInt8(0))
                        streamedBytes += frame.payload.size
                        serverStage.store(1)
                    }
                }
                @Assert(streamedBytes > 0, true)
                nativeH2MultiplexWriteResponse(accepted, 1, "early-streamed")
                nativeH2MultiplexWriteResponse(accepted, 3, "sibling")

                var resetSeen = false
                while (!resetSeen) {
                    let frame = nativeH2ReadFrame(accepted)
                    if (frame.frameType == UInt8(0x3) && frame.streamId == 1) {
                        @Assert(
                            nativeH2ClientDecode32Bit(frame.payload, 0),
                            NATIVE_H2_ERROR_CANCEL
                        )
                        resetSeen = true
                    } else {
                        @Assert(frame.frameType, UInt8(0x0))
                        @Assert(frame.streamId, Int64(1))
                        @Assert(frame.flags & UInt8(0x1), UInt8(0))
                        streamedBytes += frame.payload.size
                    }
                }
                @Assert(streamedBytes <= NATIVE_H2_INITIAL_FLOW_WINDOW, true)
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let socket = TcpSocket("127.0.0.1", port)
        socket.readTimeout = Some(Duration.second * 3)
        socket.writeTimeout = Some(Duration.second * 3)
        socket.connect(timeout: Some(Duration.second * 2))
        let connection = NativeH2ClientConnection(socket)
        let session = connection.openMultiplexSession(maxConcurrentStreams: 4)
        let source = NativeH2MultiplexChunkedInput(
            Array<UInt8>(100000, repeat: UInt8(0x72)),
            chunkSize: 4096,
            delayMs: 1
        )
        try {
            let streamedFuture = spawn {
                session.sendStream(
                    NativeH2ClientRequest(
                        "POST", "http", "127.0.0.1:${port}", "/early-streamed"
                    ),
                    source
                )
            }
            nativeH2WaitForMultiplexStreams(session, 1)
            var attempts: Int64 = 0
            while (serverStage.load() < 1 && attempts < 400) {
                sleep(Duration.millisecond * 5)
                attempts += 1
            }
            if (serverStage.load() < 1) {
                throw Exception("Native H2 streamed early-response test saw no request DATA")
            }
            let siblingFuture = spawn {
                session.send(
                    NativeH2ClientRequest(
                        "GET", "http", "127.0.0.1:${port}", "/sibling"
                    )
                )
            }

            let early = streamedFuture.get(Duration.second * 5)
            @Assert(early.header("x-multiplex-result") ?? "", "early-streamed")
            early.close()
            let sibling = siblingFuture.get(Duration.second * 5)
            @Assert(sibling.header("x-multiplex-result") ?? "", "sibling")
            sibling.close()

            @Assert(source.bytesRead() < Int64(100000), true)
            @Assert(session.outbound.size, Int64(0))
            @Assert(session.outboundOrder.size, Int64(0))
            @Assert(session.activeStreams(), Int64(0))
            @Assert(connection.retiring, true)
            @Assert(session.close(), false)
            let _ = serverFuture.get(Duration.second * 5)
        } finally {
            let _ = session.close()
            try { socket.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testStreamEarlyEofCancelsOnlyItsStreamAndPreservesSibling(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("Native H2 streamed EOF test could not reserve a port")
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                nativeH2MultiplexTestHandshake(accepted)
                var siblingHeadSeen = false
                var resetSeen = false
                var streamedBytes: Int64 = 0
                while (!siblingHeadSeen || !resetSeen) {
                    let frame = nativeH2ReadFrame(accepted)
                    if (frame.frameType == UInt8(0x1) && frame.streamId == 3) {
                        siblingHeadSeen = true
                    } else if (frame.frameType == UInt8(0x3) && frame.streamId == 1) {
                        @Assert(
                            nativeH2ClientDecode32Bit(frame.payload, 0),
                            NATIVE_H2_ERROR_CANCEL
                        )
                        resetSeen = true
                    } else if (frame.frameType == UInt8(0x0) && frame.streamId == 1) {
                        @Assert(frame.flags & UInt8(0x1), UInt8(0))
                        streamedBytes += frame.payload.size
                    }
                }
                @Assert(streamedBytes, Int64(4000))
                nativeH2MultiplexWriteResponse(accepted, 3, "sibling")
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let socket = TcpSocket("127.0.0.1", port)
        socket.readTimeout = Some(Duration.second * 3)
        socket.writeTimeout = Some(Duration.second * 3)
        socket.connect(timeout: Some(Duration.second * 2))
        let connection = NativeH2ClientConnection(socket)
        let session = connection.openMultiplexSession(maxConcurrentStreams: 4)
        let allowEof = AtomicBool(false)
        let shortSource = NativeH2MultiplexChunkedInput(
            Array<UInt8>(4000, repeat: UInt8(0x65)),
            chunkSize: 1000,
            eofGate: Some(allowEof)
        )
        try {
            let failedFuture = spawn {
                session.sendStream(
                    NativeH2ClientRequest(
                        "POST", "http", "127.0.0.1:${port}", "/short",
                        headers: [NativeH2Header("content-length", "10000")]
                    ),
                    shortSource,
                    10000
                )
            }
            nativeH2WaitForMultiplexStreams(session, 1)
            let siblingFuture = spawn {
                session.send(
                    NativeH2ClientRequest(
                        "GET", "http", "127.0.0.1:${port}", "/sibling"
                    )
                )
            }
            nativeH2WaitForMultiplexStreams(session, 2)
            allowEof.store(true)
            var failure = ""
            try {
                let _ = failedFuture.get(Duration.second * 5)
            } catch (e: Exception) {
                failure = e.message
            }
            @Assert(failure.contains("ended before Content-Length"), true)
            let sibling = siblingFuture.get(Duration.second * 5)
            @Assert(sibling.header("x-multiplex-result") ?? "", "sibling")
            sibling.close()
            @Assert(session.outbound.size, Int64(0))
            @Assert(session.outboundOrder.size, Int64(0))
            @Assert(session.activeStreams(), Int64(0))
            @Assert(connection.retiring, true)
            @Assert(session.close(), false)
            let _ = serverFuture.get(Duration.second * 5)
        } finally {
            allowEof.store(true)
            let _ = session.close()
            try { socket.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
        }
    }
}

func nativeH2MultiplexTestHandshake(socket: TcpSocket): Unit {
    let preface = nativeH2ReadExactly(socket, NATIVE_H2_PREFACE.size)
    @Assert(nativeH2BytesEqual(preface, NATIVE_H2_PREFACE), true)
    let clientSettings = nativeH2ReadFrame(socket)
    @Assert(clientSettings.frameType, UInt8(0x4))
    @Assert(clientSettings.streamId, Int64(0))
    nativeH2WriteFrame(socket, NativeH2Frame(UInt8(0x4), UInt8(0), 0, Array<UInt8>()))
    nativeH2WriteFrame(
        socket,
        NativeH2Frame(UInt8(0x4), UInt8(0x1), 0, Array<UInt8>())
    )
    let clientAck = nativeH2ReadFrame(socket)
    @Assert(clientAck.frameType, UInt8(0x4))
    @Assert(clientAck.flags & UInt8(0x1), UInt8(0x1))
}

func nativeH2MultiplexWriteResponse(
    socket: TcpSocket,
    streamId: Int64,
    marker: String
): Unit {
    nativeH2WriteFrame(
        socket,
        NativeH2Frame(
            UInt8(0x1), UInt8(0x5), streamId,
            nativeH2ClientTestEncodeResponseHead(
                204,
                [NativeH2Header("x-multiplex-result", marker)]
            )
        )
    )
}

func nativeH2WaitForMultiplexStreams(
    session: NativeH2MultiplexSession,
    expected: Int64
): Unit {
    var attempts: Int64 = 0
    while (session.activeStreams() < expected && attempts < 400) {
        sleep(Duration.millisecond * 5)
        attempts += 1
    }
    if (session.activeStreams() < expected) {
        throw Exception("Native H2 multiplex test did not reserve the expected streams")
    }
}
