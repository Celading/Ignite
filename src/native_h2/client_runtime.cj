package ignite.native_h2

import std.collection.{ArrayList, HashMap}
import std.convert.*
import std.net.TcpSocket

let NATIVE_H2_CLIENT_CONNECTION_REFILL_THRESHOLD: Int64 = 32767
let NATIVE_H2_CLIENT_STREAM_REFILL_THRESHOLD: Int64 = 65535

public class NativeH2ClientRequest {
    public let method: String
    public let scheme: String
    public let authority: String
    public let path: String
    public let body: Array<UInt8>

    public init(
        method: String,
        scheme: String,
        authority: String,
        path: String,
        body!: Array<UInt8> = Array<UInt8>()
    ) {
        this.method = method.trimAscii().toAsciiUpper()
        this.scheme = scheme.trimAscii().toAsciiLower()
        this.authority = authority
        this.path = path
        this.body = nativeH2Clone(body)
    }
}

public class NativeH2ClientResponse {
    public let status: UInt16
    public let headers: Array<NativeH2Header>
    public let body: Array<UInt8>

    public init(status: UInt16, headers: Array<NativeH2Header>, body: Array<UInt8>) {
        this.status = status
        this.headers = nativeH2CloneHeaders(headers)
        this.body = nativeH2Clone(body)
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

class NativeH2DecodedResponseHead {
    let status: UInt16
    let headers: Array<NativeH2Header>

    init(status: UInt16, headers: Array<NativeH2Header>) {
        this.status = status
        this.headers = nativeH2CloneHeaders(headers)
    }
}

class NativeH2ClientResponseStream {
    let streamId: Int64
    var head: ?NativeH2DecodedResponseHead = None
    let body = ArrayList<UInt8>()
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
        NativeH2ClientResponse(decoded.status, decoded.headers, body.toArray())
    }
}

class NativeH2ClientConnectionState {
    let streams = HashMap<Int64, NativeH2ClientResponseStream>()
    let orderedStreamIds = ArrayList<Int64>()
    var nextStreamId: Int64 = 1
    var completedStreams: Int64 = 0
    var consumedConnectionFlowCredit: Int64 = 0

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
    if (requests.size == 0) {
        return Array<NativeH2ClientResponse>()
    }
    if (requests.size > NATIVE_H2_MAX_CONCURRENT_STREAMS) {
        throw Exception("native H2 client request batch exceeds concurrent stream limit")
    }
    var requestBodyBytes: Int64 = 0
    for (request in requests) {
        if (request.body.size > NATIVE_H2_INITIAL_FLOW_WINDOW) {
            throw Exception("native H2 first client request body exceeds initial flow window")
        }
        requestBodyBytes += request.body.size
    }
    if (requestBodyBytes > NATIVE_H2_INITIAL_FLOW_WINDOW) {
        throw Exception("native H2 first client request batch exceeds connection flow window")
    }

    socket.write(NATIVE_H2_PREFACE)
    nativeH2WriteFrame(socket, NativeH2Frame(UInt8(0x4), UInt8(0), 0, Array<UInt8>()))
    nativeH2ClientCompleteSettingsHandshake(socket)

    let connection = NativeH2ClientConnectionState()
    for (request in requests) {
        let stream = connection.openStream()
        nativeH2ClientWriteRequest(socket, stream.streamId, request)
    }

    while (connection.completedStreams < requests.size) {
        let frame = nativeH2ReadFrame(socket)
        if (frame.frameType == UInt8(0x4)) {
            if (frame.streamId != 0) {
                throw Exception("native H2 client received SETTINGS on a stream")
            }
            if ((frame.flags & UInt8(0x1)) == UInt8(0)) {
                nativeH2WriteFrame(
                    socket,
                    NativeH2Frame(UInt8(0x4), UInt8(0x1), 0, Array<UInt8>())
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
            throw Exception("native H2 client received GOAWAY before response completion")
        }
        if (frame.frameType == UInt8(0x1)) {
            let stream = connection.streams.get(frame.streamId) ??
                throw Exception("native H2 client received HEADERS for an unknown stream")
            if ((frame.flags & UInt8(0x4)) == UInt8(0)) {
                throw Exception("native H2 client requires END_HEADERS response")
            }
            if (stream.head.isSome()) {
                throw Exception("native H2 client received duplicate response HEADERS")
            }
            stream.head = Some(nativeH2DecodeClientResponseHead(frame.payload))
            if ((frame.flags & UInt8(0x1)) != UInt8(0)) {
                stream.ended = true
                connection.completedStreams += 1
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
            throw Exception("native H2 client response stream was reset")
        }
        // Unknown extension and irrelevant control frames are ignored in this bounded turn.
    }

    let responses = ArrayList<NativeH2ClientResponse>()
    for (streamId in connection.orderedStreamIds) {
        let stream = connection.streams.get(streamId) ??
            throw Exception("native H2 client response stream disappeared")
        responses.add(stream.response())
    }
    responses.toArray()
}

func nativeH2ClientWriteRequest(
    socket: TcpSocket,
    streamId: Int64,
    request: NativeH2ClientRequest
): Unit {
    let requestHead = nativeH2EncodeClientRequestHead(request)
    let headFlags = if (request.body.size == 0) { UInt8(0x5) } else { UInt8(0x4) }
    nativeH2WriteFrame(socket, NativeH2Frame(UInt8(0x1), headFlags, streamId, requestHead))
    var offset: Int64 = 0
    while (offset < request.body.size) {
        let end = min(offset + NATIVE_H2_DEFAULT_MAX_FRAME_PAYLOAD, request.body.size)
        let flags = if (end == request.body.size) { UInt8(0x1) } else { UInt8(0) }
        nativeH2WriteFrame(
            socket,
            NativeH2Frame(
                UInt8(0x0), flags, streamId, nativeH2Slice(request.body, offset, end)
            )
        )
        offset = end
    }
}

func nativeH2ClientCompleteSettingsHandshake(socket: TcpSocket): Unit {
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
            if (frame.payload.size % 6 != 0) {
                throw Exception("native H2 client SETTINGS payload must use six-byte entries")
            }
            receivedServerSettings = true
            nativeH2WriteFrame(
                socket,
                NativeH2Frame(UInt8(0x4), UInt8(0x1), 0, Array<UInt8>())
            )
        }
    }
}

func nativeH2EncodeClientRequestHead(request: NativeH2ClientRequest): Array<UInt8> {
    if (request.method != "GET" && request.method != "POST") {
        throw Exception("native H2 first client slice supports GET and POST only")
    }
    if (request.scheme != "http" && request.scheme != "https") {
        throw Exception("native H2 client scheme must be http or https")
    }
    if (request.authority.size == 0 || request.authority.size >= 127 ||
        request.path.size == 0 || request.path.size >= 127) {
        throw Exception("native H2 client authority/path exceeds single-byte HPACK limits")
    }
    let out = ArrayList<UInt8>()
    out.add(if (request.method == "GET") { UInt8(0x82) } else { UInt8(0x83) })
    out.add(if (request.scheme == "http") { UInt8(0x86) } else { UInt8(0x87) })
    out.add(UInt8(0x01))
    out.add(UInt8(request.authority.size))
    nativeH2AppendBytes(out, request.authority.toArray())
    if (request.path == "/") {
        out.add(UInt8(0x84))
    } else {
        out.add(UInt8(0x04))
        out.add(UInt8(request.path.size))
        nativeH2AppendBytes(out, request.path.toArray())
    }
    out.toArray()
}

func nativeH2DecodeClientResponseHead(payload: Array<UInt8>): NativeH2DecodedResponseHead {
    if (payload.size == 0) {
        throw Exception("native H2 client response HEADERS payload is empty")
    }
    var cursor: Int64 = 0
    var status: UInt16 = 0
    let headers = ArrayList<NativeH2Header>()
    let first = payload[cursor]
    cursor += 1
    if ((first & UInt8(0x80)) != UInt8(0)) {
        status = match (Int64(first & UInt8(0x7f))) {
            case 8 => 200
            case 9 => 204
            case 10 => 206
            case 11 => 304
            case 12 => 400
            case 13 => 404
            case 14 => 500
            case _ => throw Exception("native H2 client received unsupported indexed status")
        }
    } else {
        if (first != UInt8(0x08) || cursor >= payload.size) {
            throw Exception("native H2 client received unsupported status encoding")
        }
        let length = Int64(payload[cursor])
        cursor += 1
        if (length != 3 || cursor + length > payload.size) {
            throw Exception("native H2 client status literal must contain three digits")
        }
        let value = String.fromUtf8(nativeH2Slice(payload, cursor, cursor + length))
        cursor += length
        status = UInt16.parse(value)
    }
    while (cursor < payload.size) {
        if (payload[cursor] != UInt8(0)) {
            throw Exception("native H2 client supports literal response headers only")
        }
        cursor += 1
        if (cursor >= payload.size) {
            throw Exception("native H2 client response header name length is missing")
        }
        let nameLength = Int64(payload[cursor])
        cursor += 1
        if (nameLength == 0 || cursor + nameLength > payload.size) {
            throw Exception("native H2 client response header name is truncated")
        }
        let name = String.fromUtf8(nativeH2Slice(payload, cursor, cursor + nameLength))
        cursor += nameLength
        if (cursor >= payload.size) {
            throw Exception("native H2 client response header value length is missing")
        }
        let valueLength = Int64(payload[cursor])
        cursor += 1
        if (cursor + valueLength > payload.size) {
            throw Exception("native H2 client response header value is truncated")
        }
        let value = String.fromUtf8(nativeH2Slice(payload, cursor, cursor + valueLength))
        cursor += valueLength
        headers.add(NativeH2Header(name, value))
    }
    NativeH2DecodedResponseHead(status, headers.toArray())
}

func nativeH2ClientWindowUpdate(streamId: Int64, increment: Int64): NativeH2Frame {
    let payload = Array<UInt8>(4, repeat: 0)
    payload[0] = UInt8((increment >> 24) & 0x7f)
    payload[1] = UInt8((increment >> 16) & 0xff)
    payload[2] = UInt8((increment >> 8) & 0xff)
    payload[3] = UInt8(increment & 0xff)
    NativeH2Frame(UInt8(0x8), UInt8(0), streamId, payload)
}
