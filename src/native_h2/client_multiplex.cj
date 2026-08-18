package ignite.native_h2

import std.collection.{ArrayList, HashMap}
import std.io.InputStream
import std.sync.Mutex
import std.time.MonoTime
import ignite.transport.NativeReadTimeoutControl

let NATIVE_H2_MULTIPLEX_STREAM_LIMIT: Int64 = 32
let NATIVE_H2_MULTIPLEX_BUFFER_LIMIT: Int64 = 65535
let NATIVE_H2_MULTIPLEX_UPLOAD_BUFFER_LIMIT: Int64 = 32768
let NATIVE_H2_MULTIPLEX_UPLOAD_READ_CHUNK: Int64 = 8192

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
    let openedAt: MonoTime = MonoTime.now()
    let deadlineMs: Int64
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
    var deadlineExpired = false
    var failureMessage = ""

    init(streamId: Int64, deadlineMs: Int64) {
        this.streamId = streamId
        this.deadlineMs = deadlineMs
    }

    func failed(): Bool {
        failureMessage.size > 0
    }

    func deadlineRemainingMs(now: MonoTime): Int64 {
        if (deadlineMs <= 0) {
            return 0
        }
        deadlineMs - (now - openedAt).toMilliseconds()
    }
}

class H2MuxOutboundBody {
    let streamId: Int64
    let bufferedBody: Array<UInt8>
    let source: ?InputStream
    let contentLength: Int64
    let knownLength: Bool
    let priorityHint: Int64
    let chunks = ArrayList<Array<UInt8>>()
    var chunkOffset: Int64 = 0
    var producedBytes: Int64 = 0
    var sentBytes: Int64 = 0
    var queuedBytes: Int64 = 0
    var sendWindow: Int64
    var sourceDone = false
    var cancelled = false
    var endStreamSent = false

    init(
        streamId: Int64,
        body: Array<UInt8>,
        sendWindow: Int64,
        priorityHint: Int64
    ) {
        this.streamId = streamId
        bufferedBody = body
        source = None
        contentLength = body.size
        knownLength = true
        this.priorityHint = priorityHint
        producedBytes = body.size
        sourceDone = true
        this.sendWindow = sendWindow
    }

    init(
        streamId: Int64,
        source: InputStream,
        contentLength: Int64,
        sendWindow: Int64,
        priorityHint: Int64
    ) {
        this.streamId = streamId
        bufferedBody = Array<UInt8>()
        this.source = Some(source)
        this.contentLength = contentLength
        knownLength = true
        this.priorityHint = priorityHint
        this.sendWindow = sendWindow
    }

    init(
        streamId: Int64,
        source: InputStream,
        sendWindow: Int64,
        priorityHint: Int64
    ) {
        this.streamId = streamId
        bufferedBody = Array<UInt8>()
        this.source = Some(source)
        contentLength = 0
        knownLength = false
        this.priorityHint = priorityHint
        this.sendWindow = sendWindow
    }

    func streamed(): Bool {
        source.isSome()
    }

    func remaining(): Int64 {
        if (knownLength) { contentLength - sentBytes } else { 0 }
    }

    func available(): Int64 {
        if (!streamed()) {
            return remaining()
        }
        if (chunks.size == 0) {
            return 0
        }
        chunks[0].size - chunkOffset
    }

    func nextReadSize(): Int64 {
        let bufferRemaining = NATIVE_H2_MULTIPLEX_UPLOAD_BUFFER_LIMIT - queuedBytes
        if (cancelled || sourceDone || bufferRemaining <= 0) {
            return 0
        }
        let bounded = min(bufferRemaining, NATIVE_H2_MULTIPLEX_UPLOAD_READ_CHUNK)
        if (knownLength) {
            min(contentLength - producedBytes, bounded)
        } else {
            bounded
        }
    }

    func appendProduced(chunk: Array<UInt8>): Unit {
        chunks.add(chunk)
        producedBytes += chunk.size
        queuedBytes += chunk.size
        if (knownLength && producedBytes == contentLength) {
            sourceDone = true
        }
    }

    func needsEmptyEnd(): Bool {
        !knownLength && sourceDone && queuedBytes == 0 && !endStreamSent
    }

    func endsWithPayload(): Bool {
        if (knownLength) {
            return sentBytes == contentLength
        }
        sourceDone && queuedBytes == 0
    }

    func takePayload(count: Int64): Array<UInt8> {
        if (!streamed()) {
            let end = sentBytes + count
            let payload = nativeH2Slice(bufferedBody, sentBytes, end)
            sentBytes = end
            return payload
        }
        let chunk = chunks[0]
        let end = chunkOffset + count
        let payload = nativeH2Slice(chunk, chunkOffset, end)
        chunkOffset = end
        sentBytes += count
        queuedBytes -= count
        if (chunkOffset == chunk.size) {
            let _ = chunks.remove(at: 0)
            chunkOffset = 0
        }
        payload
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
    let writeMutex = Mutex()
    let streams = HashMap<Int64, H2MuxStreamState>()
    let cancelledStreams = HashMap<Int64, H2MuxStreamState>()
    let outbound = HashMap<Int64, H2MuxOutboundBody>()
    let outboundOrder = ArrayList<Int64>()
    let localLimit: Int64
    var pendingResponseHead: ?NativeH2PendingResponseHead = None
    var connectionCredit: Int64 = 0
    var outboundCursor: Int64 = 0
    var readerActive = false
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

    public func send(
        request: NativeH2ClientRequest,
        deadlineMs!: Int64 = 0
    ): NativeH2MultiplexResponse {
        let requestHead = nativeH2EncodeClientRequestHead(request)
        let state = reserveAndWriteRequest(
            requestHead,
            request.body,
            None,
            request.body.size,
            false,
            deadlineMs,
            request.priorityHint
        )
        awaitResponse(state)
    }

    public func sendStream(
        request: NativeH2ClientRequest,
        bodyStream: InputStream,
        contentLength: Int64,
        deadlineMs!: Int64 = 0
    ): NativeH2MultiplexResponse {
        if (contentLength < 0) {
            throw IllegalArgumentException("contentLength must be >= 0")
        }
        if (request.body.size > 0) {
            throw IllegalArgumentException(
                "native H2 streamed request cannot also carry a buffered body"
            )
        }
        let requestHead = nativeH2EncodeClientRequestHead(request, contentLength)
        let state = reserveAndWriteRequest(
            requestHead,
            Array<UInt8>(),
            Some(bodyStream),
            contentLength,
            false,
            deadlineMs,
            request.priorityHint
        )
        awaitResponse(state)
    }

    /// Streams one caller-owned request source until its first EOF without
    /// emitting a Content-Length header.
    public func sendStream(
        request: NativeH2ClientRequest,
        bodyStream: InputStream,
        deadlineMs!: Int64 = 0
    ): NativeH2MultiplexResponse {
        if (request.body.size > 0) {
            throw IllegalArgumentException(
                "native H2 streamed request cannot also carry a buffered body"
            )
        }
        for (header in request.headers) {
            if (header.name.trimAscii().toAsciiLower() == "content-length") {
                throw IllegalArgumentException(
                    "native H2 unknown-length streamed request cannot carry content-length"
                )
            }
        }
        let requestHead = nativeH2EncodeClientRequestHead(request)
        let state = reserveAndWriteRequest(
            requestHead,
            Array<UInt8>(),
            Some(bodyStream),
            0,
            true,
            deadlineMs,
            request.priorityHint
        )
        awaitResponse(state)
    }

    func awaitResponse(state: H2MuxStreamState): NativeH2MultiplexResponse {
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
            if (streams.size > 0 || outbound.size > 0) {
                reusable = false
                connection.retiring = true
            }
            for ((streamId, state) in streams) {
                if (!state.remoteEnded || outbound.contains(streamId)) {
                    toCancel.add(streamId)
                }
                state.failureMessage = "native H2 multiplex session closed"
                state.released = true
            }
            streams.clear()
            cancelledStreams.clear()
            outbound.clear()
            outboundOrder.clear()
            outboundCursor = 0
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
            let _ = expireDueDeadlines()
            var count: Int64 = 0
            var refill: Int64 = 0
            var ended = false
            var cancelPendingUpload = false
            var failure = ""
            synchronized(stateMutex) {
                if (state.deadlineExpired) {
                    failure = state.failureMessage
                    releaseState(state)
                } else if (state.chunks.size > 0) {
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
                    if (outbound.contains(state.streamId)) {
                        dropOutboundLocked(state.streamId)
                        state.cancelled = true
                        state.released = true
                        let _ = streams.remove(state.streamId)
                        reusable = false
                        connection.retiring = true
                        cancelPendingUpload = true
                    } else {
                        releaseState(state)
                    }
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
            if (cancelPendingUpload) {
                try {
                    writeReset(state.streamId)
                } catch (e: Exception) {
                    failSession("native H2 multiplex upload cancellation failed: " + e.message)
                    throw e
                }
            }
            if (count > 0) {
                return count
            }
            if (failure.size > 0) {
                if (state.deadlineExpired) {
                    throw NativeH2ClientException(
                        "deadline",
                        state.streamId,
                        NATIVE_H2_ERROR_CANCEL,
                        failure
                    )
                }
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
                if (outbound.contains(state.streamId)) {
                    dropOutboundLocked(state.streamId)
                    state.cancelled = true
                    state.released = true
                    let _ = streams.remove(state.streamId)
                    reusable = false
                    connection.retiring = true
                    cancel = true
                } else {
                    releaseState(state)
                }
            } else {
                let _ = streams.remove(state.streamId)
                dropOutboundLocked(state.streamId)
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

    func reserveAndWriteRequest(
        requestHead: Array<UInt8>,
        body: Array<UInt8>,
        bodyStream: ?InputStream,
        bodyLength: Int64,
        unknownLength: Bool,
        deadlineMs: Int64,
        priorityHint: Int64
    ): H2MuxStreamState {
        var reserved: ?H2MuxStreamState = None
        var streamedOutbound: ?H2MuxOutboundBody = None
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
            if (deadlineMs < 0) {
                throw IllegalArgumentException("native H2 request deadline cannot be negative")
            }
            let state = H2MuxStreamState(connection.nextStreamId, deadlineMs)
            connection.nextStreamId += 2
            streams.add(state.streamId, state)
            if (bodyLength > 0 || unknownLength) {
                let outboundBody = match (bodyStream) {
                    case Some(source) => if (unknownLength) {
                        H2MuxOutboundBody(
                            state.streamId,
                            source,
                            connection.peerSettings.initialStreamWindow,
                            priorityHint
                        )
                    } else {
                        H2MuxOutboundBody(
                            state.streamId,
                            source,
                            bodyLength,
                            connection.peerSettings.initialStreamWindow,
                            priorityHint
                        )
                    }
                    case None => H2MuxOutboundBody(
                        state.streamId,
                        body,
                        connection.peerSettings.initialStreamWindow,
                        priorityHint
                    )
                }
                outbound.add(state.streamId, outboundBody)
                outboundOrder.add(state.streamId)
                if (outboundBody.streamed()) {
                    streamedOutbound = Some(outboundBody)
                }
            }
            try {
                synchronized(writeMutex) {
                    let flags = if (bodyLength == 0 && !unknownLength) {
                        UInt8(0x5)
                    } else {
                        UInt8(0x4)
                    }
                    nativeH2ClientWriteFrame(
                        connection.transport,
                        NativeH2Frame(UInt8(0x1), flags, state.streamId, requestHead)
                    )
                    flushOutboundWithWriterLocked()
                }
            } catch (e: Exception) {
                failSessionLocked(
                    "native H2 multiplex request write failed: " + e.message
                )
                try { connection.transport.close() } catch (_: Exception) {}
                throw e
            }
            reserved = Some(state)
        }
        if (let Some(stream) <- streamedOutbound) {
            startStreamProducer(stream)
        }
        reserved ?? throw Exception("native H2 multiplex request reservation failed")
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

    func flushOutboundLocked(): Unit {
        if (outbound.size == 0) {
            return
        }
        synchronized(writeMutex) {
            flushOutboundWithWriterLocked()
        }
    }

    func flushOutboundWithWriterLocked(): Unit {
        compactOutboundOrderLocked()
        if (outboundOrder.size == 0) {
            return
        }
        let streamIds = ArrayList<Int64>()
        let count = outboundOrder.size
        var offset: Int64 = 0
        while (offset < count) {
            let index = (outboundCursor + offset) % count
            streamIds.add(outboundOrder[index])
            offset += 1
        }
        var connectionWindow = connection.connectionSendWindow
        var progressed = true
        while (progressed && outbound.size > 0) {
            progressed = false
            let completed = ArrayList<Int64>()
            var bestPriority: Int64 = -1
            for (streamId in streamIds) {
                if (let Some(stream) <- outbound.get(streamId)) {
                    let writable = stream.needsEmptyEnd() ||
                        (stream.sendWindow > 0 && connectionWindow > 0 &&
                            stream.available() > 0)
                    if (writable && stream.priorityHint > bestPriority) {
                        bestPriority = stream.priorityHint
                    }
                }
            }
            if (bestPriority < 0) {
                break
            }
            for (streamId in streamIds) {
                if (let Some(stream) <- outbound.get(streamId)) {
                    if (stream.priorityHint != bestPriority) {
                        continue
                    }
                    let available = stream.available()
                    if (stream.needsEmptyEnd()) {
                        nativeH2ClientWriteFrame(
                            connection.transport,
                            NativeH2Frame(
                                UInt8(0x0), UInt8(0x1), stream.streamId,
                                Array<UInt8>()
                            )
                        )
                        stream.endStreamSent = true
                        completed.add(stream.streamId)
                        progressed = true
                        continue
                    }
                    if (stream.sendWindow <= 0 || connectionWindow <= 0 || available <= 0) {
                        continue
                    }
                    let count = min(
                        min(available, connection.peerSettings.maxFramePayload),
                        min(stream.sendWindow, connectionWindow)
                    )
                    let payload = stream.takePayload(count)
                    let flags = if (stream.endsWithPayload()) {
                        UInt8(0x1)
                    } else {
                        UInt8(0)
                    }
                    nativeH2ClientWriteFrame(
                        connection.transport,
                        NativeH2Frame(
                            UInt8(0x0),
                            flags,
                            stream.streamId,
                            payload
                        )
                    )
                    stream.sendWindow -= count
                    connectionWindow -= count
                    progressed = true
                    if ((flags & UInt8(0x1)) != UInt8(0)) {
                        stream.endStreamSent = true
                        completed.add(stream.streamId)
                    }
                }
            }
            for (streamId in completed) {
                let _ = outbound.remove(streamId)
            }
        }
        connection.connectionSendWindow = connectionWindow
        outboundCursor = if (count > 1) {
            (outboundCursor + 1) % count
        } else {
            0
        }
        compactOutboundOrderLocked()
    }

    func startStreamProducer(stream: H2MuxOutboundBody): Unit {
        match (stream.source) {
            case Some(source) =>
                let _ = spawn {
                    while (true) {
                        var wanted: Int64 = 0
                        var stopped = false
                        synchronized(stateMutex) {
                            if (closed || stream.cancelled || !outbound.contains(stream.streamId)) {
                                stopped = true
                            } else if (stream.sourceDone) {
                                stopped = true
                            } else {
                                wanted = stream.nextReadSize()
                            }
                        }
                        if (stopped) {
                            return
                        }
                        if (wanted <= 0) {
                            sleep(Duration.millisecond)
                            continue
                        }
                        let chunk = Array<UInt8>(wanted, repeat: UInt8(0))
                        let count = try {
                            source.read(chunk)
                        } catch (e: Exception) {
                            failStreamProducer(
                                stream.streamId,
                                "native H2 request body stream read failed: " + e.message
                            )
                            return
                        }
                        if (count <= 0) {
                            if (stream.knownLength) {
                                failStreamProducer(
                                    stream.streamId,
                                    "native H2 request body stream ended before Content-Length"
                                )
                                return
                            }
                            synchronized(stateMutex) {
                                if (closed || stream.cancelled ||
                                    !outbound.contains(stream.streamId)) {
                                    return
                                }
                                stream.sourceDone = true
                                flushOutboundLocked()
                            }
                            return
                        }
                        if (count > wanted) {
                            failStreamProducer(
                                stream.streamId,
                                "native H2 request body stream exceeded its bounded read"
                            )
                            return
                        }
                        let produced = if (count == wanted) {
                            chunk
                        } else {
                            nativeH2Slice(chunk, 0, count)
                        }
                        synchronized(stateMutex) {
                            if (closed || stream.cancelled || !outbound.contains(stream.streamId)) {
                                return
                            }
                            stream.appendProduced(produced)
                            flushOutboundLocked()
                        }
                    }
                }
            case None => ()
        }
    }

    func failStreamProducer(streamId: Int64, message: String): Unit {
        var reset = false
        synchronized(stateMutex) {
            if (let Some(stream) <- outbound.get(streamId)) {
                stream.cancelled = true
                dropOutboundLocked(streamId)
                if (let Some(state) <- streams.get(streamId)) {
                    state.failureMessage = message
                    state.cancelled = true
                    state.released = true
                    let _ = streams.remove(streamId)
                    cancelledStreams.add(streamId, state)
                }
                reusable = false
                connection.retiring = true
                reset = true
            }
        }
        if (reset) {
            try {
                writeReset(streamId)
            } catch (e: Exception) {
                failSession("native H2 streamed upload cancellation failed: " + e.message)
            }
        }
    }

    func dropOutboundLocked(streamId: Int64): Unit {
        let _ = outbound.remove(streamId)
        compactOutboundOrderLocked()
    }

    func compactOutboundOrderLocked(): Unit {
        var index: Int64 = 0
        while (index < outboundOrder.size) {
            if (outbound.contains(outboundOrder[index])) {
                index += 1
            } else {
                let _ = outboundOrder.remove(at: index)
            }
        }
        if (outboundOrder.size == 0) {
            outboundCursor = 0
        } else if (outboundCursor >= outboundOrder.size) {
            outboundCursor %= outboundOrder.size
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
            let _ = expireDueDeadlines()
            var head: ?NativeH2ClientResponseHead = None
            var failure = ""
            synchronized(stateMutex) {
                if (state.failed()) {
                    failure = state.failureMessage
                } else if (state.remoteEnded && state.head.isNone()) {
                    failure = "native H2 multiplex response ended before final headers"
                } else {
                    head = state.head
                }
            }
            if (let Some(value) <- head) {
                return value
            }
            if (failure.size > 0) {
                if (state.deadlineExpired) {
                    throw NativeH2ClientException(
                        "deadline",
                        state.streamId,
                        NATIVE_H2_ERROR_CANCEL,
                        failure
                    )
                }
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
        let _ = expireDueDeadlines()
        var shouldRead = false
        var ready = false
        var failure = ""
        synchronized(stateMutex) {
            flushOutboundLocked()
            ready = if (waitingForHead) {
                state.head.isSome() || state.remoteEnded
            } else {
                state.chunks.size > 0 || state.remoteEnded
            }
            if (state.failed()) {
                failure = state.failureMessage
            } else if (!ready && !readerActive) {
                readerActive = true
                shouldRead = true
            }
        }
        if (failure.size > 0) {
            throw Exception(failure)
        }
        if (ready) {
            return
        }
        if (!shouldRead) {
            sleep(Duration.millisecond)
            return
        }
        var timeoutControl: ?NativeReadTimeoutControl = None
        match (connection.transport) {
            case control: NativeReadTimeoutControl => timeoutControl = Some(control)
            case _ => ()
        }
        var previousTimeout: ?Duration = None
        let deadlineTimeout = nearestDeadlineReadTimeout()
        var timeoutChanged = false
        match (timeoutControl) {
            case Some(control) =>
                previousTimeout = control.currentReadTimeout()
                match (deadlineTimeout) {
                    case Some(value) =>
                        let shouldUpdate = match (previousTimeout) {
                            case Some(current) => current.toMilliseconds() > value.toMilliseconds()
                            case None => true
                        }
                        if (shouldUpdate) {
                            control.updateReadTimeout(Some(value))
                            timeoutChanged = true
                        }
                    case None => ()
                }
            case None => ()
        }
        try {
            let frame = nativeH2ClientReadFrame(connection.transport)
            applyFrame(frame)
        } catch (e: NativeH2ClientException) {
            if (e.failureKind == "timeout" && expireDueDeadlines()) {
                return
            }
            failSession("native H2 multiplex read failed: " + e.message)
            throw e
        } catch (e: Exception) {
            failSession("native H2 multiplex read failed: " + e.message)
            throw e
        } finally {
            if (timeoutChanged) {
                match (timeoutControl) {
                    case Some(control) => control.updateReadTimeout(previousTimeout)
                    case None => ()
                }
            }
            synchronized(stateMutex) {
                readerActive = false
            }
        }
    }

    func nearestDeadlineReadTimeout(): ?Duration {
        var nearestMs: Int64 = 0
        synchronized(stateMutex) {
            let now = MonoTime.now()
            for ((_streamId, stream) in streams) {
                if (stream.deadlineMs > 0 && !stream.deadlineExpired &&
                    !stream.remoteEnded) {
                    let remaining = stream.deadlineRemainingMs(now)
                    let bounded = if (remaining > 0) { remaining } else { 1 }
                    if (nearestMs == 0 || bounded < nearestMs) {
                        nearestMs = bounded
                    }
                }
            }
        }
        if (nearestMs > 0) {
            Some(Duration.millisecond * nearestMs)
        } else {
            None
        }
    }

    func expireDueDeadlines(): Bool {
        let expired = ArrayList<H2MuxStreamState>()
        synchronized(stateMutex) {
            let now = MonoTime.now()
            for ((_streamId, stream) in streams) {
                if (stream.deadlineMs > 0 && !stream.deadlineExpired &&
                    !stream.remoteEnded &&
                    stream.deadlineRemainingMs(now) <= 0) {
                    expired.add(stream)
                }
            }
            for (stream in expired) {
                let _ = streams.remove(stream.streamId)
                dropOutboundLocked(stream.streamId)
                stream.cancelled = true
                stream.deadlineExpired = true
                stream.released = true
                stream.failureMessage = "native H2 stream deadline exceeded"
                cancelledStreams.add(stream.streamId, stream)
            }
        }
        for (stream in expired) {
            try {
                writeReset(stream.streamId)
            } catch (e: Exception) {
                failSession("native H2 deadline cancellation failed: " + e.message)
                throw e
            }
        }
        expired.size > 0
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
                    applySettingsWithWriterLocked(frame)
                    flushOutboundWithWriterLocked()
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
                    flushOutboundLocked()
                }
            } else {
                synchronized(stateMutex) {
                    if (let Some(stream) <- outbound.get(frame.streamId)) {
                        stream.sendWindow = nativeH2IncreaseFlowWindow(
                            stream.sendWindow,
                            increment,
                            "client stream send"
                        )
                    } else if (!streams.contains(frame.streamId) &&
                        !cancelledStreams.contains(frame.streamId)) {
                        nativeH2ClientProtocolFailure(
                            frame.streamId,
                            NATIVE_H2_ERROR_PROTOCOL,
                            "native H2 multiplex WINDOW_UPDATE references an unknown stream"
                        )
                    }
                    flushOutboundLocked()
                }
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

    func applySettingsWithWriterLocked(frame: NativeH2Frame): Unit {
        if (frame.streamId != 0) {
            nativeH2ClientProtocolFailure(
                frame.streamId,
                NATIVE_H2_ERROR_PROTOCOL,
                "native H2 multiplex received SETTINGS on a stream"
            )
        }
        if ((frame.flags & UInt8(0x1)) != UInt8(0)) {
            if (frame.payload.size != 0) {
                nativeH2ClientProtocolFailure(
                    0,
                    NATIVE_H2_ERROR_FRAME_SIZE,
                    "native H2 multiplex SETTINGS ACK must be empty"
                )
            }
            return
        }
        let windowDeltas = connection.peerSettings.apply(frame.payload)
        for (delta in windowDeltas) {
            for ((_streamId, stream) in outbound) {
                stream.sendWindow = nativeH2AdjustedSendWindow(stream.sendWindow, delta)
            }
        }
        nativeH2ClientWriteFrame(
            connection.transport,
            NativeH2Frame(UInt8(0x4), UInt8(0x1), 0, Array<UInt8>())
        )
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
                dropOutboundLocked(frame.streamId)
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
        dropOutboundLocked(state.streamId)
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
        outbound.clear()
        outboundOrder.clear()
        outboundCursor = 0
        cancelledStreams.clear()
        for ((_streamId, state) in streams) {
            if (!state.failed()) {
                state.failureMessage = message
            }
        }
    }
}
