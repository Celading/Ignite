package ignite.native_h2

import std.collection.{ArrayList, HashMap}
import std.io.InputStream
import std.sync.Mutex

let NATIVE_H2_MULTIPLEX_STREAM_LIMIT: Int64 = 32
let NATIVE_H2_MULTIPLEX_BUFFER_LIMIT: Int64 = 65535

/// One response carried by an explicit connection-owned multiplex session.
public class NativeH2MultiplexResponse {
    public let status: UInt16
    public let headers: Array<NativeH2Header>
    public let informational: Array<NativeH2ClientResponseHead>
    let stream: H2MuxResponseInputStream

    init(
        head: NativeH2ClientResponseHead,
        informational: Array<NativeH2ClientResponseHead>,
        stream: H2MuxResponseInputStream
    ) {
        status = head.status
        headers = nativeH2CloneHeaders(head.headers)
        this.informational = nativeH2CloneResponseHeads(informational)
        this.stream = stream
    }

    public func header(name: String): ?String {
        let normalized = name.trimAscii().toAsciiLower()
        for (header in headers) {
            if (header.name == normalized) {
                return Some(header.value)
            }
        }
        None
    }

    public func bodyStream(): InputStream {
        stream
    }

    public func trailers(): Array<NativeH2Header> {
        stream.trailers()
    }

    public func close(): Unit {
        stream.close()
    }
}

class H2MuxStreamState {
    let streamId: Int64
    var head: ?NativeH2ClientResponseHead = None
    let informational = ArrayList<NativeH2ClientResponseHead>()
    var trailers = Array<NativeH2Header>()
    let chunks = ArrayList<Array<UInt8>>()
    var chunkOffset: Int64 = 0
    var bufferedBytes: Int64 = 0
    var consumedStreamCredit: Int64 = 0
    var remoteEnded = false
    var released = false
    var cancelled = false
    var failureMessage = ""

    init(streamId: Int64) {
        this.streamId = streamId
    }

    func failed(): Bool {
        failureMessage.size > 0
    }
}

class H2MuxResponseInputStream <: InputStream & Resource {
    let session: NativeH2MultiplexSession
    let state: H2MuxStreamState
    var closed = false

    init(session: NativeH2MultiplexSession, state: H2MuxStreamState) {
        this.session = session
        this.state = state
    }

    public override func read(outBuf: Array<Byte>): Int64 {
        if (closed || outBuf.size == 0) {
            return 0
        }
        let count = session.readStream(state, outBuf)
        if (count <= 0) {
            closed = true
        }
        count
    }

    public func close(): Unit {
        if (closed) {
            return
        }
        closed = true
        session.closeStream(state)
    }

    public func isClosed(): Bool {
        closed
    }

    func trailers(): Array<NativeH2Header> {
        session.streamTrailers(state)
    }
}

/// Coordinates multiple response leases while retaining one reader per connection.
public class NativeH2MultiplexSession {
    let connection: NativeH2ClientConnection
    let stateMutex = Mutex()
    let readMutex = Mutex()
    let writeMutex = Mutex()
    let streams = HashMap<Int64, H2MuxStreamState>()
    let cancelledStreams = HashMap<Int64, H2MuxStreamState>()
    let noOutbound = HashMap<Int64, NativeH2ClientOutboundStream>()
    let localLimit: Int64
    var pendingResponseHead: ?NativeH2PendingResponseHead = None
    var connectionCredit: Int64 = 0
    var closed = false
    var reusable = true

    init(connection: NativeH2ClientConnection, maxConcurrentStreams: Int64) {
        if (maxConcurrentStreams <= 0 ||
            maxConcurrentStreams > NATIVE_H2_MULTIPLEX_STREAM_LIMIT) {
            throw Exception(
                "native H2 multiplex session maxConcurrentStreams must be within 1..${NATIVE_H2_MULTIPLEX_STREAM_LIMIT}"
            )
        }
        if (connection.finished || connection.retiring) {
            throw Exception("native H2 client connection is finished")
        }
        if (connection.activeStreamLease.isSome() || connection.activeMultiplexSession) {
            throw Exception("native H2 client connection already has an active response owner")
        }
        this.connection = connection
        localLimit = maxConcurrentStreams
        if (!connection.initialized) {
            connection.transport.write(NATIVE_H2_PREFACE)
            nativeH2ClientWriteFrame(
                connection.transport,
                NativeH2Frame(UInt8(0x4), UInt8(0), 0, nativeH2ClientSettingsPayload())
            )
            nativeH2ClientCompleteSettingsHandshake(
                connection.transport, connection.peerSettings
            )
            connection.initialized = true
        }
        connection.activeMultiplexSession = true
    }

    public func send(request: NativeH2ClientRequest): NativeH2MultiplexResponse {
        if (request.body.size > 0) {
            throw Exception("native H2 multiplex session does not yet support request bodies")
        }
        let requestHead = nativeH2EncodeClientRequestHead(request)
        let state = reserveAndWriteRequest(requestHead)
        try {
            let head = awaitHead(state)
            NativeH2MultiplexResponse(
                head,
                streamInformationals(state),
                H2MuxResponseInputStream(this, state)
            )
        } catch (e: Exception) {
            failStreamOpen(state, e.message)
            throw e
        }
    }

    public func maxConcurrentStreams(): Int64 {
        synchronized(stateMutex) {
            admissionLimit()
        }
    }

    public func activeStreams(): Int64 {
        synchronized(stateMutex) {
            streams.size
        }
    }

    /// Stops new submissions and returns whether the physical connection is reusable.
    public func close(): Bool {
        let toCancel = ArrayList<Int64>()
        var flushCredit: Int64 = 0
        synchronized(stateMutex) {
            if (closed) {
                return reusable && !connection.finished && !connection.retiring
            }
            closed = true
            if (streams.size > 0 || cancelledStreams.size > 0) {
                reusable = false
                connection.retiring = true
            }
            for ((streamId, state) in streams) {
                if (!state.remoteEnded) {
                    toCancel.add(streamId)
                }
                state.failureMessage = "native H2 multiplex session closed"
                state.released = true
            }
            streams.clear()
            cancelledStreams.clear()
            flushCredit = connectionCredit
            connectionCredit = 0
            connection.activeMultiplexSession = false
        }
        for (streamId in toCancel) {
            try { writeReset(streamId) } catch (_: Exception) { reusable = false }
        }
        if (reusable && flushCredit > 0) {
            try {
                writeFrame(nativeH2ClientWindowUpdate(0, flushCredit))
            } catch (_: Exception) {
                reusable = false
                connection.finished = true
            }
        }
        reusable && !connection.finished && !connection.retiring
    }

    func readStream(state: H2MuxStreamState, outBuf: Array<Byte>): Int64 {
        while (true) {
            var count: Int64 = 0
            var refill: Int64 = 0
            var ended = false
            var failure = ""
            synchronized(stateMutex) {
                if (state.chunks.size > 0) {
                    let chunk = state.chunks[0]
                    let available = chunk.size - state.chunkOffset
                    count = min(outBuf.size, available)
                    for (i in 0..count) {
                        outBuf[i] = chunk[state.chunkOffset + i]
                    }
                    state.chunkOffset += count
                    state.bufferedBytes -= count
                    state.consumedStreamCredit += count
                    if (state.chunkOffset == chunk.size) {
                        let _ = state.chunks.remove(at: 0)
                        state.chunkOffset = 0
                    }
                    if (!state.remoteEnded && state.consumedStreamCredit >=
                        NATIVE_H2_CLIENT_STREAM_REFILL_THRESHOLD) {
                        refill = state.consumedStreamCredit
                        state.consumedStreamCredit = 0
                    }
                } else if (state.failed()) {
                    failure = state.failureMessage
                    releaseState(state)
                } else if (state.remoteEnded) {
                    releaseState(state)
                    ended = true
                }
            }
            if (refill > 0) {
                try {
                    writeFrame(nativeH2ClientWindowUpdate(state.streamId, refill))
                } catch (e: Exception) {
                    failSession("native H2 multiplex flow-control write failed: " + e.message)
                    throw e
                }
            }
            if (count > 0) {
                return count
            }
            if (failure.size > 0) {
                throw Exception(failure)
            }
            if (ended) {
                return 0
            }
            pump(state, false)
        }
        throw Exception("native H2 multiplex response read loop ended unexpectedly")
    }

    func closeStream(state: H2MuxStreamState): Unit {
        var cancel = false
        synchronized(stateMutex) {
            if (state.released) {
                return
            }
            if (state.remoteEnded) {
                state.chunks.clear()
                state.bufferedBytes = 0
                releaseState(state)
            } else {
                let _ = streams.remove(state.streamId)
                state.cancelled = true
                state.released = true
                cancelledStreams.add(state.streamId, state)
                reusable = false
                connection.retiring = true
                cancel = true
            }
        }
        if (cancel) {
            try {
                writeReset(state.streamId)
            } catch (e: Exception) {
                failSession("native H2 multiplex cancellation failed: " + e.message)
            }
        }
    }

    func streamTrailers(state: H2MuxStreamState): Array<NativeH2Header> {
        synchronized(stateMutex) {
            nativeH2CloneHeaders(state.trailers)
        }
    }

    func reserveAndWriteRequest(requestHead: Array<UInt8>): H2MuxStreamState {
        synchronized(stateMutex) {
            if (closed || connection.finished || connection.retiring) {
                throw Exception("native H2 multiplex session is closed or retiring")
            }
            let limit = admissionLimit()
            if (limit <= 0 || streams.size >= limit) {
                throw Exception(
                    "native H2 multiplex session active stream limit ${limit} reached"
                )
            }
            let state = H2MuxStreamState(connection.nextStreamId)
            connection.nextStreamId += 2
            streams.add(state.streamId, state)
            try {
                writeFrame(
                    NativeH2Frame(UInt8(0x1), UInt8(0x5), state.streamId, requestHead)
                )
            } catch (e: Exception) {
                failSessionLocked(
                    "native H2 multiplex request write failed: " + e.message
                )
                try { connection.transport.close() } catch (_: Exception) {}
                throw e
            }
            state
        }
    }

    func admissionLimit(): Int64 {
        if (let Some(peerLimit) <- connection.peerSettings.maxConcurrentStreams) {
            return min(localLimit, peerLimit)
        }
        localLimit
    }

    func writeFrame(frame: NativeH2Frame): Unit {
        synchronized(writeMutex) {
            nativeH2ClientWriteFrame(connection.transport, frame)
        }
    }

    func writeReset(streamId: Int64): Unit {
        writeFrame(
            NativeH2Frame(
                UInt8(0x3), UInt8(0), streamId,
                nativeH2ErrorCodePayload(NATIVE_H2_ERROR_CANCEL)
            )
        )
    }

    func awaitHead(state: H2MuxStreamState): NativeH2ClientResponseHead {
        while (true) {
            var head: ?NativeH2ClientResponseHead = None
            var failure = ""
            synchronized(stateMutex) {
                head = state.head
                if (state.failed()) {
                    failure = state.failureMessage
                } else if (state.remoteEnded && state.head.isNone()) {
                    failure = "native H2 multiplex response ended before final headers"
                }
            }
            if (let Some(value) <- head) {
                return value
            }
            if (failure.size > 0) {
                throw Exception(failure)
            }
            pump(state, true)
        }
        throw Exception("native H2 multiplex response-head loop ended unexpectedly")
    }

    func streamInformationals(state: H2MuxStreamState): Array<NativeH2ClientResponseHead> {
        synchronized(stateMutex) {
            nativeH2CloneResponseHeads(state.informational.toArray())
        }
    }

    func pump(state: H2MuxStreamState, waitingForHead: Bool): Unit {
        readMutex.lock()
        try {
            var ready = false
            var failure = ""
            synchronized(stateMutex) {
                ready = if (waitingForHead) {
                    state.head.isSome() || state.remoteEnded
                } else {
                    state.chunks.size > 0 || state.remoteEnded
                }
                if (state.failed()) {
                    failure = state.failureMessage
                }
            }
            if (failure.size > 0) {
                throw Exception(failure)
            }
            if (ready) {
                return
            }
            let frame = nativeH2ClientReadFrame(connection.transport)
            applyFrame(frame)
        } catch (e: Exception) {
            failSession("native H2 multiplex read failed: " + e.message)
            throw e
        } finally {
            readMutex.unlock()
        }
    }

    func applyFrame(frame: NativeH2Frame): Unit {
        if (let Some(pending) <- pendingResponseHead) {
            if (frame.frameType != UInt8(0x9) || frame.streamId != pending.streamId) {
                nativeH2ClientProtocolFailure(
                    pending.streamId,
                    NATIVE_H2_ERROR_PROTOCOL,
                    "native H2 multiplex response requires contiguous CONTINUATION frames"
                )
            }
            pending.append(frame.payload)
            if ((frame.flags & UInt8(0x4)) != UInt8(0)) {
                pendingResponseHead = None
                applyHeaderBlock(
                    pending.streamId,
                    pending.endStream,
                    pending.headerBlock()
                )
            }
            return
        }
        if (frame.frameType == UInt8(0x9)) {
            nativeH2ClientProtocolFailure(
                frame.streamId,
                NATIVE_H2_ERROR_PROTOCOL,
                "native H2 multiplex response received orphan CONTINUATION"
            )
        }
        if (frame.frameType == UInt8(0x4)) {
            synchronized(stateMutex) {
                synchronized(writeMutex) {
                    nativeH2ClientApplySettings(
                        connection.transport, frame, connection.peerSettings, noOutbound
                    )
                }
            }
            return
        }
        if (frame.frameType == UInt8(0x8)) {
            let increment = nativeH2DecodeWindowUpdate(frame)
            if (frame.streamId == 0) {
                synchronized(stateMutex) {
                    connection.connectionSendWindow = nativeH2IncreaseFlowWindow(
                        connection.connectionSendWindow,
                        increment,
                        "client connection send"
                    )
                }
            } else {
                requireKnownStream(frame.streamId)
            }
            return
        }
        if (frame.frameType == UInt8(0x6)) {
            if (frame.streamId != 0 || frame.payload.size != 8) {
                nativeH2ClientProtocolFailure(
                    frame.streamId,
                    NATIVE_H2_ERROR_FRAME_SIZE,
                    "native H2 multiplex response received invalid PING"
                )
            }
            if ((frame.flags & UInt8(0x1)) == UInt8(0)) {
                writeFrame(NativeH2Frame(UInt8(0x6), UInt8(0x1), 0, frame.payload))
            }
            return
        }
        if (frame.frameType == UInt8(0x7)) {
            if (frame.streamId != 0 || frame.payload.size < 8) {
                throw NativeH2ClientException(
                    "protocol", 0, NATIVE_H2_ERROR_FRAME_SIZE,
                    "native H2 multiplex response received malformed GOAWAY"
                )
            }
            throw NativeH2ClientException(
                "goaway",
                nativeH2ClientDecode31Bit(frame.payload, 0),
                nativeH2ClientDecode32Bit(frame.payload, 4),
                "native H2 multiplex response received GOAWAY"
            )
        }
        if (frame.frameType == UInt8(0x1)) {
            requireKnownStream(frame.streamId)
            let fragment = nativeH2ClientHeaderBlockFragment(frame)
            let endStream = (frame.flags & UInt8(0x1)) != UInt8(0)
            if ((frame.flags & UInt8(0x4)) == UInt8(0)) {
                pendingResponseHead = Some(
                    NativeH2PendingResponseHead(frame.streamId, endStream, fragment)
                )
            } else {
                applyHeaderBlock(frame.streamId, endStream, fragment)
            }
            return
        }
        if (frame.frameType == UInt8(0x0)) {
            applyData(frame)
            return
        }
        if (frame.frameType == UInt8(0x3)) {
            applyReset(frame)
            return
        }
        if (frame.frameType == UInt8(0x5)) {
            nativeH2ClientProtocolFailure(
                frame.streamId,
                NATIVE_H2_ERROR_PROTOCOL,
                "native H2 multiplex session does not accept PUSH_PROMISE"
            )
        }
        // Unknown extension and irrelevant control frames remain ignorable.
    }

    func applyHeaderBlock(streamId: Int64, endStream: Bool, payload: Array<UInt8>): Unit {
        synchronized(stateMutex) {
            let state = streams.get(streamId) ?? cancelledStreams.get(streamId) ??
                nativeH2ClientProtocolFailure(
                    streamId,
                    NATIVE_H2_ERROR_PROTOCOL,
                    "native H2 multiplex HEADERS references an unknown stream"
                )
            if (state.head.isNone()) {
                let decoded = connection.responseDecoder.decodeResponseHead(payload)
                if (decoded.status >= 100 && decoded.status < 200) {
                    if (decoded.status == 101 || endStream) {
                        nativeH2ClientProtocolFailure(
                            streamId,
                            NATIVE_H2_ERROR_PROTOCOL,
                            "native H2 multiplex informational response is invalid"
                        )
                    }
                    state.informational.add(decoded)
                    return
                }
                state.head = Some(decoded)
                state.remoteEnded = endStream
            } else {
                if (!endStream) {
                    nativeH2ClientProtocolFailure(
                        streamId,
                        NATIVE_H2_ERROR_PROTOCOL,
                        "native H2 multiplex trailers must end the stream"
                    )
                }
                state.trailers = connection.responseDecoder.decodeResponseTrailers(payload)
                state.remoteEnded = true
            }
            if (state.cancelled && endStream) {
                let _ = cancelledStreams.remove(streamId)
            }
        }
    }

    func applyData(frame: NativeH2Frame): Unit {
        let data = nativeH2RequestDataField(frame)
        var streamPaddingCredit: Int64 = 0
        var connectionRefill: Int64 = 0
        synchronized(stateMutex) {
            if (let Some(state) <- streams.get(frame.streamId)) {
                if (state.head.isNone() || state.remoteEnded) {
                    nativeH2ClientProtocolFailure(
                        frame.streamId,
                        NATIVE_H2_ERROR_PROTOCOL,
                        "native H2 multiplex DATA arrived outside an open response"
                    )
                }
                if (state.bufferedBytes + data.size > NATIVE_H2_MULTIPLEX_BUFFER_LIMIT) {
                    nativeH2ClientProtocolFailure(
                        frame.streamId,
                        NATIVE_H2_ERROR_FLOW_CONTROL,
                        "native H2 multiplex response exceeded its 64 KiB unread buffer"
                    )
                }
                if (data.size > 0) {
                    state.chunks.add(data)
                    state.bufferedBytes += data.size
                }
                state.remoteEnded = (frame.flags & UInt8(0x1)) != UInt8(0)
                streamPaddingCredit = frame.payload.size - data.size
                if (state.remoteEnded) {
                    streamPaddingCredit = 0
                }
            } else if (let Some(cancelled) <- cancelledStreams.get(frame.streamId)) {
                if ((frame.flags & UInt8(0x1)) != UInt8(0)) {
                    cancelled.remoteEnded = true
                    let _ = cancelledStreams.remove(frame.streamId)
                }
            } else {
                nativeH2ClientProtocolFailure(
                    frame.streamId,
                    NATIVE_H2_ERROR_PROTOCOL,
                    "native H2 multiplex DATA references an unknown stream"
                )
            }
            connectionCredit += frame.payload.size
            if (connectionCredit >= NATIVE_H2_CLIENT_CONNECTION_REFILL_THRESHOLD) {
                connectionRefill = connectionCredit
                connectionCredit = 0
            }
        }
        if (streamPaddingCredit > 0) {
            writeFrame(nativeH2ClientWindowUpdate(frame.streamId, streamPaddingCredit))
        }
        if (connectionRefill > 0) {
            writeFrame(nativeH2ClientWindowUpdate(0, connectionRefill))
        }
    }

    func applyReset(frame: NativeH2Frame): Unit {
        if (frame.payload.size != 4) {
            throw NativeH2ClientException(
                "protocol", frame.streamId, NATIVE_H2_ERROR_FRAME_SIZE,
                "native H2 multiplex response received malformed RST_STREAM"
            )
        }
        let errorCode = nativeH2ClientDecode32Bit(frame.payload, 0)
        synchronized(stateMutex) {
            if (let Some(state) <- streams.get(frame.streamId)) {
                state.failureMessage =
                    "native H2 multiplex response stream was reset with ${errorCode}"
                state.remoteEnded = true
            } else {
                let _ = cancelledStreams.remove(frame.streamId)
            }
        }
    }

    func requireKnownStream(streamId: Int64): Unit {
        synchronized(stateMutex) {
            if (!streams.contains(streamId) && !cancelledStreams.contains(streamId)) {
                nativeH2ClientProtocolFailure(
                    streamId,
                    NATIVE_H2_ERROR_PROTOCOL,
                    "native H2 multiplex frame references an unknown stream"
                )
            }
        }
    }

    func releaseState(state: H2MuxStreamState): Unit {
        if (state.released) {
            return
        }
        state.released = true
        let _ = streams.remove(state.streamId)
    }

    func failStreamOpen(state: H2MuxStreamState, message: String): Unit {
        synchronized(stateMutex) {
            if (!state.released) {
                state.failureMessage = message
                releaseState(state)
            }
        }
    }

    func failSession(message: String): Unit {
        synchronized(stateMutex) {
            failSessionLocked(message)
        }
        try { connection.transport.close() } catch (_: Exception) {}
    }

    func failSessionLocked(message: String): Unit {
        closed = true
        reusable = false
        connection.finished = true
        connection.activeMultiplexSession = false
        for ((_streamId, state) in streams) {
            if (!state.failed()) {
                state.failureMessage = message
            }
        }
    }
}
