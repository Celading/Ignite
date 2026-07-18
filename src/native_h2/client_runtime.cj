package ignite.native_h2

import std.collection.{ArrayList, HashMap}
import std.convert.*
import std.net.{SocketTimeoutException, TcpSocket}

let NATIVE_H2_CLIENT_CONNECTION_REFILL_THRESHOLD: Int64 = 32767
let NATIVE_H2_CLIENT_STREAM_REFILL_THRESHOLD: Int64 = 65535

public class NativeH2ClientException <: Exception {
    public let failureKind: String
    public let streamId: Int64
    public let errorCode: Int64

    public init(failureKind: String, streamId: Int64, errorCode: Int64, message: String) {
        super(message)
        this.failureKind = failureKind
        this.streamId = streamId
        this.errorCode = errorCode
    }
}

public class NativeH2ClientRequest {
    public let method: String
    public let scheme: String
    public let authority: String
    public let path: String
    public let body: Array<UInt8>
    public let headers: Array<NativeH2Header>

    public init(
        method: String,
        scheme: String,
        authority: String,
        path: String,
        body!: Array<UInt8> = Array<UInt8>(),
        headers!: Array<NativeH2Header> = Array<NativeH2Header>()
    ) {
        this.method = method.trimAscii().toAsciiUpper()
        this.scheme = scheme.trimAscii().toAsciiLower()
        this.authority = authority
        this.path = path
        this.body = nativeH2Clone(body)
        this.headers = nativeH2CloneHeaders(headers)
    }
}

public class NativeH2ClientResponse {
    public let status: UInt16
    public let headers: Array<NativeH2Header>
    public let body: Array<UInt8>
    public let informational: Array<NativeH2ClientResponseHead>
    public let trailers: Array<NativeH2Header>

    public init(
        status: UInt16,
        headers: Array<NativeH2Header>,
        body: Array<UInt8>,
        informational!: Array<NativeH2ClientResponseHead> = Array<NativeH2ClientResponseHead>(),
        trailers!: Array<NativeH2Header> = Array<NativeH2Header>()
    ) {
        this.status = status
        this.headers = nativeH2CloneHeaders(headers)
        this.body = nativeH2Clone(body)
        this.informational = nativeH2CloneResponseHeads(informational)
        this.trailers = nativeH2CloneHeaders(trailers)
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
}

public class NativeH2ClientResponseHead {
    public let status: UInt16
    public let headers: Array<NativeH2Header>

    public init(status: UInt16, headers: Array<NativeH2Header>) {
        this.status = status
        this.headers = nativeH2CloneHeaders(headers)
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
}

type NativeH2DecodedResponseHead = NativeH2ClientResponseHead

class NativeH2ClientResponseStream {
    let streamId: Int64
    var head: ?NativeH2DecodedResponseHead = None
    let informational = ArrayList<NativeH2ClientResponseHead>()
    let body = ArrayList<UInt8>()
    var trailers = Array<NativeH2Header>()
    var consumedFlowCredit: Int64 = 0
    var ended = false

    init(streamId: Int64) {
        this.streamId = streamId
    }

    func response(): NativeH2ClientResponse {
        let decoded = head ?? throw Exception("native H2 client response head is missing")
        if (!ended) {
            throw Exception("native H2 client response stream is incomplete")
        }
        NativeH2ClientResponse(
            decoded.status,
            decoded.headers,
            body.toArray(),
            informational: informational.toArray(),
            trailers: trailers
        )
    }
}

class NativeH2PendingResponseHead {
    let streamId: Int64
    let endStream: Bool
    let payload = ArrayList<UInt8>()

    init(streamId: Int64, endStream: Bool, firstPayload: Array<UInt8>) {
        this.streamId = streamId
        this.endStream = endStream
        append(firstPayload)
    }

    func append(nextPayload: Array<UInt8>): Unit {
        if (payload.size + nextPayload.size > NATIVE_H2_MAX_REQUEST_HEADER_BLOCK) {
            nativeH2ClientProtocolFailure(
                streamId,
                NATIVE_H2_ERROR_COMPRESSION,
                "native H2 client response header block exceeds 64 KiB"
            )
        }
        for (value in nextPayload) {
            payload.add(value)
        }
    }

    func headerBlock(): Array<UInt8> {
        payload.toArray()
    }
}

class NativeH2ClientConnectionState {
    let streams = HashMap<Int64, NativeH2ClientResponseStream>()
    let outbound = HashMap<Int64, NativeH2ClientOutboundStream>()
    let orderedStreamIds = ArrayList<Int64>()
    var nextStreamId: Int64
    var completedStreams: Int64 = 0
    var consumedConnectionFlowCredit: Int64 = 0
    var connectionSendWindow: Int64
    var pendingResponseHead: ?NativeH2PendingResponseHead = None

    init(nextStreamId: Int64, connectionSendWindow: Int64) {
        this.nextStreamId = nextStreamId
        this.connectionSendWindow = connectionSendWindow
    }

    func openStream(): NativeH2ClientResponseStream {
        if (streams.size >= NATIVE_H2_MAX_CONCURRENT_STREAMS) {
            throw Exception("native H2 client concurrent stream limit exceeded")
        }
        let stream = NativeH2ClientResponseStream(nextStreamId)
        streams.add(stream.streamId, stream)
        orderedStreamIds.add(stream.streamId)
        nextStreamId += 2
        stream
    }
}

class NativeH2ClientOutboundStream {
    let streamId: Int64
    let body: Array<UInt8>
    var offset: Int64 = 0
    var sendWindow: Int64

    init(streamId: Int64, body: Array<UInt8>, sendWindow: Int64) {
        this.streamId = streamId
        this.body = body
        this.sendWindow = sendWindow
    }

    func remaining(): Int64 {
        body.size - offset
    }
}

/// Owns H2 protocol state while the caller continues to own the socket.
public class NativeH2ClientConnection {
    let socket: TcpSocket
    let responseDecoder = NativeH2HpackDecoderState()
    let peerSettings = NativeH2PeerSettings()
    var activeStreamLease: ?NativeH2ClientStreamLease = None
    var initialized = false
    var finished = false
    var nextStreamId: Int64 = 1
    var connectionSendWindow: Int64 = NATIVE_H2_INITIAL_FLOW_WINDOW

    public init(socket: TcpSocket) {
        this.socket = socket
    }

    public func send(request: NativeH2ClientRequest): NativeH2ClientResponse {
        sendBatch([request])[0]
    }

    public func sendBatch(
        requests: Array<NativeH2ClientRequest>
    ): Array<NativeH2ClientResponse> {
        if (finished) {
            throw Exception("native H2 client connection is finished")
        }
        if (activeStreamLease.isSome()) {
            throw Exception("native H2 client connection has an active streamed response")
        }
        let (responses, followingStreamId, followingConnectionSendWindow) =
            nativeH2ClientSendBatch(
            socket,
            requests,
            nextStreamId,
            !initialized,
            responseDecoder,
            peerSettings,
            connectionSendWindow
        )
        initialized = true
        nextStreamId = followingStreamId
        connectionSendWindow = followingConnectionSendWindow
        responses
    }

    /// Opens one response body as a connection-owned incremental stream.
    ///
    /// The Preview implementation intentionally permits one public streamed
    /// response lease at a time so socket reads, HPACK state, and control frames
    /// remain owned by this connection rather than competing body streams.
    public func sendStreamed(
        request: NativeH2ClientRequest
    ): NativeH2ClientStreamedResponse {
        nativeH2ClientOpenStreamedResponse(this, request)
    }

    /// Emits NO_ERROR GOAWAY but leaves physical socket close to the caller.
    public func finish(): Unit {
        if (finished) {
            return
        }
        if (activeStreamLease.isSome()) {
            throw Exception("native H2 client cannot finish with an active streamed response")
        }
        if (initialized) {
            nativeH2WriteFrame(
                socket,
                NativeH2Frame(
                    UInt8(0x7),
                    UInt8(0),
                    0,
                    nativeH2GoAwayPayload(nextStreamId - 2, NATIVE_H2_ERROR_NO_ERROR)
                )
            )
        }
        finished = true
    }
}

/// Completes one HTTP/2 request on an already connected cleartext socket.
///
/// The caller retains socket ownership. TLS/ALPN and connection pooling belong
/// to later AP4/AP5 slices rather than this first real-wire client turn.
public func sendNativeH2SingleStreamRequest(
    socket: TcpSocket,
    request: NativeH2ClientRequest
): NativeH2ClientResponse {
    sendNativeH2Requests(socket, [request])[0]
}

/// Completes a bounded multiplexed request batch on one cleartext H2 connection.
///
/// Requests are emitted on increasing odd stream IDs before the response reader
/// starts, allowing the server to execute handlers independently. The caller
/// retains socket ownership and receives responses in request order.
public func sendNativeH2Requests(
    socket: TcpSocket,
    requests: Array<NativeH2ClientRequest>
): Array<NativeH2ClientResponse> {
    NativeH2ClientConnection(socket).sendBatch(requests)
}

func nativeH2ClientSendBatch(
    socket: TcpSocket,
    requests: Array<NativeH2ClientRequest>,
    initialStreamId: Int64,
    completeHandshake: Bool,
    responseDecoder: NativeH2HpackDecoderState,
    peerSettings: NativeH2PeerSettings,
    initialConnectionSendWindow: Int64
): (Array<NativeH2ClientResponse>, Int64, Int64) {
    if (requests.size == 0) {
        return (
            Array<NativeH2ClientResponse>(),
            initialStreamId,
            initialConnectionSendWindow
        )
    }
    if (requests.size > NATIVE_H2_MAX_CONCURRENT_STREAMS) {
        throw Exception("native H2 client request batch exceeds concurrent stream limit")
    }
    if (completeHandshake) {
        socket.write(NATIVE_H2_PREFACE)
        nativeH2WriteFrame(
            socket,
            NativeH2Frame(UInt8(0x4), UInt8(0), 0, nativeH2ClientSettingsPayload())
        )
        nativeH2ClientCompleteSettingsHandshake(socket, peerSettings)
    }

    let connection = NativeH2ClientConnectionState(
        initialStreamId,
        initialConnectionSendWindow
    )
    for (request in requests) {
        let stream = connection.openStream()
        nativeH2ClientWriteRequestHead(socket, stream.streamId, request)
        if (request.body.size > 0) {
            connection.outbound.add(
                stream.streamId,
                NativeH2ClientOutboundStream(
                    stream.streamId,
                    request.body,
                    peerSettings.initialStreamWindow
                )
            )
        }
    }

    while (connection.completedStreams < requests.size || connection.outbound.size > 0) {
        connection.connectionSendWindow = nativeH2ClientFlushRequestBodies(
            socket,
            connection.outbound,
            connection.orderedStreamIds,
            connection.connectionSendWindow,
            peerSettings.maxFramePayload
        )
        if (connection.completedStreams >= requests.size && connection.outbound.size == 0) {
            break
        }
        let frame = nativeH2ClientReadFrame(socket)
        if (let Some(pending) <- connection.pendingResponseHead) {
            if (frame.frameType != UInt8(0x9)) {
                nativeH2ClientProtocolFailure(
                    pending.streamId,
                    NATIVE_H2_ERROR_PROTOCOL,
                    "native H2 client requires contiguous CONTINUATION frames"
                )
            }
            if (frame.streamId != pending.streamId) {
                nativeH2ClientProtocolFailure(
                    pending.streamId,
                    NATIVE_H2_ERROR_PROTOCOL,
                    "native H2 client CONTINUATION must remain on the opened stream"
                )
            }
            pending.append(frame.payload)
            if ((frame.flags & UInt8(0x4)) != UInt8(0)) {
                let stream = connection.streams.get(pending.streamId) ??
                    nativeH2ClientProtocolFailure(
                        pending.streamId,
                        NATIVE_H2_ERROR_PROTOCOL,
                        "native H2 client CONTINUATION references an unknown stream"
                    )
                nativeH2ClientApplyResponseHeaderBlock(
                    connection,
                    stream,
                    pending.endStream,
                    pending.headerBlock(),
                    responseDecoder
                )
                connection.pendingResponseHead = None
            }
            continue
        }
        if (frame.frameType == UInt8(0x9)) {
            nativeH2ClientProtocolFailure(
                frame.streamId,
                NATIVE_H2_ERROR_PROTOCOL,
                "native H2 client received orphan CONTINUATION"
            )
        }
        if (frame.frameType == UInt8(0x4)) {
            nativeH2ClientApplySettings(socket, frame, peerSettings, connection.outbound)
            continue
        }
        if (frame.frameType == UInt8(0x8)) {
            let increment = nativeH2DecodeWindowUpdate(frame)
            if (frame.streamId == 0) {
                connection.connectionSendWindow = nativeH2IncreaseFlowWindow(
                    connection.connectionSendWindow,
                    increment,
                    "client connection send"
                )
            } else if (let Some(outbound) <- connection.outbound.get(frame.streamId)) {
                outbound.sendWindow = nativeH2IncreaseFlowWindow(
                    outbound.sendWindow,
                    increment,
                    "client stream send"
                )
            } else if (!connection.streams.contains(frame.streamId)) {
                nativeH2ClientProtocolFailure(
                    frame.streamId,
                    NATIVE_H2_ERROR_PROTOCOL,
                    "native H2 client WINDOW_UPDATE references an unknown stream"
                )
            }
            continue
        }
        if (frame.frameType == UInt8(0x6)) {
            if (frame.streamId != 0 || frame.payload.size != 8) {
                throw Exception("native H2 client received invalid PING")
            }
            if ((frame.flags & UInt8(0x1)) == UInt8(0)) {
                nativeH2WriteFrame(
                    socket,
                    NativeH2Frame(UInt8(0x6), UInt8(0x1), 0, frame.payload)
                )
            }
            continue
        }
        if (frame.frameType == UInt8(0x7)) {
            if (frame.streamId != 0 || frame.payload.size < 8) {
                throw NativeH2ClientException(
                    "protocol", 0, NATIVE_H2_ERROR_FRAME_SIZE,
                    "native H2 client received malformed GOAWAY"
                )
            }
            let lastStreamId = nativeH2ClientDecode31Bit(frame.payload, 0)
            let errorCode = nativeH2ClientDecode32Bit(frame.payload, 4)
            throw NativeH2ClientException(
                "goaway", lastStreamId, errorCode,
                "native H2 client received GOAWAY before response completion"
            )
        }
        if (frame.frameType == UInt8(0x1)) {
            let stream = connection.streams.get(frame.streamId) ??
                throw Exception("native H2 client received HEADERS for an unknown stream")
            if (stream.ended) {
                nativeH2ClientProtocolFailure(
                    frame.streamId,
                    NATIVE_H2_ERROR_STREAM_CLOSED,
                    "native H2 client received HEADERS after stream completion"
                )
            }
            let headerBlock = nativeH2ClientHeaderBlockFragment(frame)
            let endStream = (frame.flags & UInt8(0x1)) != UInt8(0)
            if ((frame.flags & UInt8(0x4)) == UInt8(0)) {
                connection.pendingResponseHead = Some(
                    NativeH2PendingResponseHead(frame.streamId, endStream, headerBlock)
                )
            } else {
                nativeH2ClientApplyResponseHeaderBlock(
                    connection, stream, endStream, headerBlock, responseDecoder
                )
            }
            continue
        }
        if (frame.frameType == UInt8(0x0)) {
            let stream = connection.streams.get(frame.streamId) ??
                throw Exception("native H2 client received DATA for an unknown stream")
            if (stream.head.isNone() || stream.ended) {
                throw Exception("native H2 client received DATA before response HEADERS")
            }
            if (stream.body.size + frame.payload.size > NATIVE_H2_MAX_FIRST_SLICE_BODY) {
                throw Exception("native H2 first client response exceeds 1 MiB")
            }
            for (value in frame.payload) {
                stream.body.add(value)
            }
            let ended = (frame.flags & UInt8(0x1)) != UInt8(0)
            stream.consumedFlowCredit += frame.payload.size
            connection.consumedConnectionFlowCredit += frame.payload.size
            if (ended) {
                stream.ended = true
                connection.completedStreams += 1
            }
            if (!ended && stream.consumedFlowCredit >=
                NATIVE_H2_CLIENT_STREAM_REFILL_THRESHOLD) {
                nativeH2WriteFrame(
                    socket,
                    nativeH2ClientWindowUpdate(stream.streamId, stream.consumedFlowCredit)
                )
                stream.consumedFlowCredit = 0
            }
            if (connection.completedStreams < requests.size &&
                connection.consumedConnectionFlowCredit >=
                    NATIVE_H2_CLIENT_CONNECTION_REFILL_THRESHOLD) {
                nativeH2WriteFrame(
                    socket,
                    nativeH2ClientWindowUpdate(0, connection.consumedConnectionFlowCredit)
                )
                connection.consumedConnectionFlowCredit = 0
            }
            continue
        }
        if (frame.frameType == UInt8(0x3) && connection.streams.contains(frame.streamId)) {
            if (frame.payload.size != 4) {
                throw NativeH2ClientException(
                    "protocol", frame.streamId, NATIVE_H2_ERROR_FRAME_SIZE,
                    "native H2 client received malformed RST_STREAM"
                )
            }
            throw NativeH2ClientException(
                "reset", frame.streamId, nativeH2ClientDecode32Bit(frame.payload, 0),
                "native H2 client response stream was reset"
            )
        }
        // Unknown extension and irrelevant control frames are ignored in this bounded turn.
    }

    let responses = ArrayList<NativeH2ClientResponse>()
    for (streamId in connection.orderedStreamIds) {
        let stream = connection.streams.get(streamId) ??
            throw Exception("native H2 client response stream disappeared")
        responses.add(stream.response())
    }
    (responses.toArray(), connection.nextStreamId, connection.connectionSendWindow)
}

func nativeH2ClientFlushRequestBodies(
    socket: TcpSocket,
    outbound: HashMap<Int64, NativeH2ClientOutboundStream>,
    orderedStreamIds: ArrayList<Int64>,
    initialConnectionWindow: Int64,
    maxFramePayload: Int64
): Int64 {
    var connectionWindow = initialConnectionWindow
    var progressed = true
    while (progressed && connectionWindow > 0 && outbound.size > 0) {
        progressed = false
        let completed = ArrayList<Int64>()
        for (streamId in orderedStreamIds) {
            if (let Some(stream) <- outbound.get(streamId)) {
                if (stream.sendWindow <= 0 || stream.remaining() <= 0) {
                    continue
                }
                let count = min(
                    min(stream.remaining(), maxFramePayload),
                    min(stream.sendWindow, connectionWindow)
                )
                let end = stream.offset + count
                let flags = if (end == stream.body.size) { UInt8(0x1) } else { UInt8(0) }
                nativeH2WriteFrame(
                    socket,
                    NativeH2Frame(
                        UInt8(0x0),
                        flags,
                        stream.streamId,
                        nativeH2Slice(stream.body, stream.offset, end)
                    )
                )
                stream.offset = end
                stream.sendWindow -= count
                connectionWindow -= count
                progressed = true
                if (stream.remaining() == 0) {
                    completed.add(stream.streamId)
                }
            }
        }
        for (streamId in completed) {
            let _ = outbound.remove(streamId)
        }
    }
    connectionWindow
}

func nativeH2ClientApplySettings(
    socket: TcpSocket,
    frame: NativeH2Frame,
    peerSettings: NativeH2PeerSettings,
    outbound: HashMap<Int64, NativeH2ClientOutboundStream>
): Unit {
    if (frame.streamId != 0) {
        nativeH2ClientProtocolFailure(
            frame.streamId,
            NATIVE_H2_ERROR_PROTOCOL,
            "native H2 client received SETTINGS on a stream"
        )
    }
    if ((frame.flags & UInt8(0x1)) != UInt8(0)) {
        if (frame.payload.size != 0) {
            nativeH2ClientProtocolFailure(
                0,
                NATIVE_H2_ERROR_FRAME_SIZE,
                "native H2 client SETTINGS ACK must be empty"
            )
        }
        return
    }
    let windowDeltas = peerSettings.apply(frame.payload)
    for (delta in windowDeltas) {
        for ((_streamId, stream) in outbound) {
            stream.sendWindow = nativeH2AdjustedSendWindow(stream.sendWindow, delta)
        }
    }
    nativeH2WriteFrame(socket, NativeH2Frame(UInt8(0x4), UInt8(0x1), 0, Array<UInt8>()))
}

func nativeH2ClientApplyResponseHeaderBlock(
    connection: NativeH2ClientConnectionState,
    stream: NativeH2ClientResponseStream,
    endStream: Bool,
    payload: Array<UInt8>,
    responseDecoder: NativeH2HpackDecoderState
): Unit {
    if (stream.head.isNone()) {
        let decoded = responseDecoder.decodeResponseHead(payload)
        if (decoded.status >= 100 && decoded.status < 200) {
            if (decoded.status == 101) {
                nativeH2ClientProtocolFailure(
                    stream.streamId,
                    NATIVE_H2_ERROR_PROTOCOL,
                    "native H2 client forbids 101 Switching Protocols"
                )
            }
            if (endStream) {
                nativeH2ClientProtocolFailure(
                    stream.streamId,
                    NATIVE_H2_ERROR_PROTOCOL,
                    "native H2 informational response cannot end the stream"
                )
            }
            stream.informational.add(decoded)
            return
        }
        stream.head = Some(decoded)
        if (endStream) {
            nativeH2ClientCompleteResponseStream(connection, stream)
        }
        return
    }

    if (!endStream) {
        nativeH2ClientProtocolFailure(
            stream.streamId,
            NATIVE_H2_ERROR_PROTOCOL,
            "native H2 response trailers must end the stream"
        )
    }
    stream.trailers = responseDecoder.decodeResponseTrailers(payload)
    nativeH2ClientCompleteResponseStream(connection, stream)
}

func nativeH2ClientCompleteResponseStream(
    connection: NativeH2ClientConnectionState,
    stream: NativeH2ClientResponseStream
): Unit {
    if (stream.ended) {
        nativeH2ClientProtocolFailure(
            stream.streamId,
            NATIVE_H2_ERROR_STREAM_CLOSED,
            "native H2 client response stream completed more than once"
        )
    }
    stream.ended = true
    connection.completedStreams += 1
}

func nativeH2ClientProtocolFailure(
    streamId: Int64,
    errorCode: Int64,
    message: String
): Nothing {
    throw NativeH2ClientException("protocol", streamId, errorCode, message)
}

func nativeH2ClientHeaderBlockFragment(frame: NativeH2Frame): Array<UInt8> {
    let padded = (frame.flags & UInt8(0x8)) != UInt8(0)
    let prioritized = (frame.flags & UInt8(0x20)) != UInt8(0)
    if (!padded && !prioritized) {
        return frame.payload
    }

    var cursor: Int64 = 0
    var paddingLength: Int64 = 0
    if (padded) {
        if (frame.payload.size < 1) {
            nativeH2ClientProtocolFailure(
                frame.streamId,
                NATIVE_H2_ERROR_PROTOCOL,
                "native H2 client padded HEADERS is missing pad length"
            )
        }
        paddingLength = Int64(frame.payload[0])
        cursor = 1
    }
    if (prioritized) {
        if (frame.payload.size - cursor < 5) {
            nativeH2ClientProtocolFailure(
                frame.streamId,
                NATIVE_H2_ERROR_FRAME_SIZE,
                "native H2 client priority HEADERS prefix is truncated"
            )
        }
        let dependency =
            ((Int64(frame.payload[cursor]) & 0x7f) << 24) +
            (Int64(frame.payload[cursor + 1]) << 16) +
            (Int64(frame.payload[cursor + 2]) << 8) +
            Int64(frame.payload[cursor + 3])
        if (dependency == frame.streamId) {
            nativeH2ClientProtocolFailure(
                frame.streamId,
                NATIVE_H2_ERROR_PROTOCOL,
                "native H2 client priority HEADERS cannot depend on itself"
            )
        }
        cursor += 5
    }

    let end = frame.payload.size - paddingLength
    if (end < cursor) {
        nativeH2ClientProtocolFailure(
            frame.streamId,
            NATIVE_H2_ERROR_PROTOCOL,
            "native H2 client HEADERS padding exceeds payload"
        )
    }
    nativeH2Slice(frame.payload, cursor, end)
}

func nativeH2CloneResponseHeads(
    input: Array<NativeH2ClientResponseHead>
): Array<NativeH2ClientResponseHead> {
    let out = ArrayList<NativeH2ClientResponseHead>()
    for (head in input) {
        out.add(NativeH2ClientResponseHead(head.status, head.headers))
    }
    out.toArray()
}

func nativeH2ClientReadFrame(socket: TcpSocket): NativeH2Frame {
    try {
        match (nativeH2ReadFrameOrEof(socket)) {
            case Some(frame) => frame
            case None => throw NativeH2ClientException(
                "peer-close", 0, 0,
                "native H2 peer closed before response completion"
            )
        }
    } catch (e: SocketTimeoutException) {
        throw NativeH2ClientException(
            "timeout", 0, 0,
            "native H2 client timed out while waiting for a response frame"
        )
    }
}

func nativeH2ClientDecode31Bit(payload: Array<UInt8>, offset: Int64): Int64 {
    ((Int64(payload[offset]) & 0x7f) << 24) +
        (Int64(payload[offset + 1]) << 16) +
        (Int64(payload[offset + 2]) << 8) +
        Int64(payload[offset + 3])
}

func nativeH2ClientDecode32Bit(payload: Array<UInt8>, offset: Int64): Int64 {
    (Int64(payload[offset]) << 24) +
        (Int64(payload[offset + 1]) << 16) +
        (Int64(payload[offset + 2]) << 8) +
        Int64(payload[offset + 3])
}

func nativeH2ClientWriteRequestHead(
    socket: TcpSocket,
    streamId: Int64,
    request: NativeH2ClientRequest
): Unit {
    let requestHead = nativeH2EncodeClientRequestHead(request)
    let headFlags = if (request.body.size == 0) { UInt8(0x5) } else { UInt8(0x4) }
    nativeH2WriteFrame(socket, NativeH2Frame(UInt8(0x1), headFlags, streamId, requestHead))
}

func nativeH2ClientCompleteSettingsHandshake(
    socket: TcpSocket,
    peerSettings: NativeH2PeerSettings
): Unit {
    var receivedServerSettings = false
    var receivedClientSettingsAck = false
    while (!receivedServerSettings || !receivedClientSettingsAck) {
        let frame = nativeH2ReadFrame(socket)
        if (frame.frameType != UInt8(0x4) || frame.streamId != 0) {
            throw Exception("native H2 client expected SETTINGS handshake frames")
        }
        if ((frame.flags & UInt8(0x1)) != UInt8(0)) {
            if (frame.payload.size != 0) {
                throw Exception("native H2 client SETTINGS ACK must be empty")
            }
            receivedClientSettingsAck = true
        } else {
            let _ = peerSettings.apply(frame.payload)
            receivedServerSettings = true
            nativeH2WriteFrame(
                socket,
                NativeH2Frame(UInt8(0x4), UInt8(0x1), 0, Array<UInt8>())
            )
        }
    }
}

func nativeH2ClientSettingsPayload(): Array<UInt8> {
    [UInt8(0), UInt8(2), UInt8(0), UInt8(0), UInt8(0), UInt8(0)]
}

func nativeH2EncodeClientRequestHead(request: NativeH2ClientRequest): Array<UInt8> {
    nativeH2ClientRequireToken(request.method, "method")
    if (request.scheme != "http" && request.scheme != "https") {
        throw Exception("native H2 client scheme must be http or https")
    }
    if (request.authority.size == 0 || request.path.size == 0) {
        throw Exception("native H2 client authority/path cannot be empty")
    }
    let out = ArrayList<UInt8>()
    if (request.method == "GET") {
        out.add(UInt8(0x82))
    } else if (request.method == "POST") {
        out.add(UInt8(0x83))
    } else {
        nativeH2ClientAppendLiteral(out, ":method", request.method, nameIndex: 2)
    }
    out.add(if (request.scheme == "http") { UInt8(0x86) } else { UInt8(0x87) })
    nativeH2ClientAppendLiteral(out, ":authority", request.authority, nameIndex: 1)
    if (request.path == "/") {
        out.add(UInt8(0x84))
    } else {
        nativeH2ClientAppendLiteral(out, ":path", request.path, nameIndex: 4)
    }

    var contentLength: ?Int64 = None
    for (header in request.headers) {
        nativeH2ClientValidateRequestHeader(header)
        if (header.name == "content-length") {
            let parsed = nativeH2ParseContentLength(header.value)
            if (let Some(previous) <- contentLength) {
                if (previous != parsed) {
                    throw Exception("native H2 client request has conflicting content-length values")
                }
            }
            contentLength = Some(parsed)
        }
        nativeH2ClientAppendLiteral(
            out,
            header.name,
            header.value,
            nameIndex: nativeH2ClientStaticNameIndex(header.name)
        )
    }
    if (let Some(length) <- contentLength) {
        if (length != request.body.size) {
            throw Exception("native H2 client content-length does not match request body")
        }
    }
    if (out.size > NATIVE_H2_MAX_REQUEST_HEADER_BLOCK) {
        throw Exception("native H2 client request header block exceeds 64 KiB")
    }
    out.toArray()
}

func nativeH2ClientValidateRequestHeader(header: NativeH2Header): Unit {
    if (header.name.size == 0 || header.name.startsWith(":")) {
        throw Exception("native H2 client ordinary headers cannot be empty or pseudo-headers")
    }
    nativeH2ClientRequireToken(header.name, "header name")
    nativeH2ValidateRequestHeader(header.name, header.value)
    for (value in header.value.toArray()) {
        if (value == UInt8(0) || value == UInt8(10) || value == UInt8(13)) {
            throw Exception("native H2 client request header value contains a forbidden byte")
        }
    }
}

func nativeH2ClientRequireToken(value: String, fieldName: String): Unit {
    let bytes = value.toArray()
    if (bytes.size == 0) {
        throw Exception("native H2 client ${fieldName} cannot be empty")
    }
    for (byte in bytes) {
        let alphaNumeric = (byte >= UInt8(0x30) && byte <= UInt8(0x39)) ||
            (byte >= UInt8(0x41) && byte <= UInt8(0x5a)) ||
            (byte >= UInt8(0x61) && byte <= UInt8(0x7a))
        let punctuation = byte == UInt8(0x21) || byte == UInt8(0x23) ||
            byte == UInt8(0x24) || byte == UInt8(0x25) || byte == UInt8(0x26) ||
            byte == UInt8(0x27) || byte == UInt8(0x2a) || byte == UInt8(0x2b) ||
            byte == UInt8(0x2d) || byte == UInt8(0x2e) || byte == UInt8(0x5e) ||
            byte == UInt8(0x5f) || byte == UInt8(0x60) || byte == UInt8(0x7c) ||
            byte == UInt8(0x7e)
        if (!alphaNumeric && !punctuation) {
            throw Exception("native H2 client ${fieldName} contains an invalid token byte")
        }
    }
}

func nativeH2ClientAppendLiteral(
    out: ArrayList<UInt8>,
    name: String,
    value: String,
    nameIndex!: Int64 = 0
): Unit {
    nativeH2ClientAppendHpackInteger(out, nameIndex, 4, UInt8(0))
    if (nameIndex == 0) {
        nativeH2ClientAppendHpackString(out, name)
    }
    nativeH2ClientAppendHpackString(out, value)
}

func nativeH2ClientAppendHpackString(out: ArrayList<UInt8>, value: String): Unit {
    let bytes = value.toArray()
    nativeH2ClientAppendHpackInteger(out, bytes.size, 7, UInt8(0))
    nativeH2AppendBytes(out, bytes)
}

func nativeH2ClientAppendHpackInteger(
    out: ArrayList<UInt8>,
    input: Int64,
    prefixBits: Int64,
    prefix: UInt8
): Unit {
    let mask = (Int64(1) << prefixBits) - 1
    if (input < mask) {
        out.add(prefix | UInt8(input))
        return
    }
    out.add(prefix | UInt8(mask))
    var remaining = input - mask
    while (remaining >= 128) {
        out.add(UInt8((remaining % 128) + 128))
        remaining /= 128
    }
    out.add(UInt8(remaining))
}

func nativeH2ClientStaticNameIndex(name: String): Int64 {
    var index: Int64 = 15
    while (index <= 61) {
        if (nativeH2HpackStaticField(index).name == name) {
            return index
        }
        index += 1
    }
    0
}

func nativeH2ClientWindowUpdate(streamId: Int64, increment: Int64): NativeH2Frame {
    let payload = Array<UInt8>(4, repeat: 0)
    payload[0] = UInt8((increment >> 24) & 0x7f)
    payload[1] = UInt8((increment >> 16) & 0xff)
    payload[2] = UInt8((increment >> 8) & 0xff)
    payload[3] = UInt8(increment & 0xff)
    NativeH2Frame(UInt8(0x8), UInt8(0), streamId, payload)
}
