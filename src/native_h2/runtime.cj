package ignite.native_h2

import std.collection.{ArrayList, HashMap}
import std.net.TcpSocket

let NATIVE_H2_PREFACE = "PRI * HTTP/2.0\r\n\r\nSM\r\n\r\n".toArray()
let NATIVE_H2_MAX_FIRST_SLICE_BODY: Int64 = 1024 * 1024
let NATIVE_H2_DEFAULT_MAX_FRAME_PAYLOAD: Int64 = 16384
let NATIVE_H2_MAX_CONCURRENT_STREAMS: Int64 = 100
let NATIVE_H2_INITIAL_FLOW_WINDOW: Int64 = 65535
let NATIVE_H2_MAX_FLOW_WINDOW: Int64 = 2147483647

public class NativeH2SingleStreamRequest {
    public let streamId: Int64
    public let method: String
    public let scheme: String
    public let authority: String
    public let path: String
    public let body: Array<UInt8>

    public init(
        streamId: Int64,
        method: String,
        scheme: String,
        authority: String,
        path: String,
        body: Array<UInt8>
    ) {
        this.streamId = streamId
        this.method = method
        this.scheme = scheme
        this.authority = authority
        this.path = path
        this.body = nativeH2Clone(body)
    }
}

public class NativeH2SingleStreamResponse {
    public let status: UInt16
    public let headers: Array<NativeH2Header>
    public let body: Array<UInt8>

    public init(
        status!: UInt16 = 200,
        headers!: Array<NativeH2Header> = Array<NativeH2Header>(),
        body!: Array<UInt8> = Array<UInt8>()
    ) {
        this.status = status
        this.headers = nativeH2CloneHeaders(headers)
        this.body = nativeH2Clone(body)
    }
}

public class NativeH2Header {
    public let name: String
    public let value: String

    public init(name: String, value: String) {
        this.name = name.trimAscii().toAsciiLower()
        this.value = value.trimAscii()
    }
}

public type NativeH2SingleStreamHandler =
    (NativeH2SingleStreamRequest) -> NativeH2SingleStreamResponse

class NativeH2Frame {
    let frameType: UInt8
    let flags: UInt8
    let streamId: Int64
    let payload: Array<UInt8>

    init(frameType: UInt8, flags: UInt8, streamId: Int64, payload: Array<UInt8>) {
        this.frameType = frameType
        this.flags = flags
        this.streamId = streamId
        this.payload = nativeH2Clone(payload)
    }
}

class NativeH2DecodedRequestHead {
    let method: String
    let scheme: String
    let authority: String
    let path: String

    init(method: String, scheme: String, authority: String, path: String) {
        this.method = method
        this.scheme = scheme
        this.authority = authority
        this.path = path
    }
}

class NativeH2InboundStream {
    let streamId: Int64
    let head: NativeH2DecodedRequestHead
    let body = ArrayList<UInt8>()

    init(streamId: Int64, head: NativeH2DecodedRequestHead) {
        this.streamId = streamId
        this.head = head
    }

    func appendData(payload: Array<UInt8>): Unit {
        if (body.size + payload.size > NATIVE_H2_MAX_FIRST_SLICE_BODY) {
            throw Exception("native H2 request body exceeds 1 MiB")
        }
        for (value in payload) {
            body.add(value)
        }
    }

    func request(): NativeH2SingleStreamRequest {
        NativeH2SingleStreamRequest(
            streamId,
            head.method,
            head.scheme,
            head.authority,
            head.path,
            body.toArray()
        )
    }
}

class NativeH2OutboundStream {
    let streamId: Int64
    let body: Array<UInt8>
    var offset: Int64 = 0
    var sendWindow: Int64 = NATIVE_H2_INITIAL_FLOW_WINDOW

    init(streamId: Int64, body: Array<UInt8>) {
        this.streamId = streamId
        this.body = nativeH2Clone(body)
    }

    func remaining(): Int64 {
        body.size - offset
    }
}

/// Serves one bounded HTTP/2 stream on an already accepted cleartext socket.
///
/// This first AP2 slice owns the real preface/SETTINGS/frame lifecycle but
/// intentionally does not claim multiplexing, flow control, TLS, CONTINUATION,
/// dynamic-table HPACK, or Huffman decoding.
public func serveNativeH2SingleStream(
    socket: TcpSocket,
    handler: NativeH2SingleStreamHandler
): Unit {
    serveNativeH2Connection(socket, handler, maxCompletedStreams: 1)
}

/// Serves a bounded or socket-lifetime HTTP/2 connection.
///
/// A positive `maxCompletedStreams` is useful for bounded embedding and wire
/// fixtures. Zero keeps reading until the peer closes or a protocol error is
/// raised. Flow-control accounting is added by the next AP3 stage.
public func serveNativeH2Connection(
    socket: TcpSocket,
    handler: NativeH2SingleStreamHandler,
    maxCompletedStreams!: Int64 = 0
): Unit {
    if (maxCompletedStreams < 0) {
        throw Exception("native H2 maxCompletedStreams cannot be negative")
    }
    let preface = nativeH2ReadExactly(socket, NATIVE_H2_PREFACE.size)
    if (!nativeH2BytesEqual(preface, NATIVE_H2_PREFACE)) {
        throw Exception("native H2 client preface is invalid")
    }

    let clientSettings = nativeH2ReadFrame(socket)
    if (clientSettings.frameType != UInt8(0x4) || clientSettings.streamId != 0 ||
        (clientSettings.flags & UInt8(0x1)) != UInt8(0)) {
        throw Exception("native H2 expected initial non-ACK SETTINGS on stream 0")
    }
    if (clientSettings.payload.size % 6 != 0) {
        throw Exception("native H2 SETTINGS payload must contain 6-byte entries")
    }
    nativeH2WriteFrame(
        socket,
        NativeH2Frame(UInt8(0x4), UInt8(0), 0, nativeH2ServerSettingsPayload())
    )
    nativeH2WriteFrame(socket, NativeH2Frame(UInt8(0x4), UInt8(0x1), 0, Array<UInt8>()))

    let streams = HashMap<Int64, NativeH2InboundStream>()
    let outbound = HashMap<Int64, NativeH2OutboundStream>()
    var lastOpenedStreamId: Int64 = 0
    var completedStreams: Int64 = 0
    var connectionSendWindow: Int64 = NATIVE_H2_INITIAL_FLOW_WINDOW
    while (maxCompletedStreams == 0 || completedStreams < maxCompletedStreams || outbound.size > 0) {
        let frame = nativeH2ReadFrame(socket)
        if (frame.frameType == UInt8(0x4)) {
            nativeH2HandleSettingsFrame(socket, frame)
            continue
        }
        if (frame.frameType == UInt8(0x1)) {
            if (frame.streamId <= 0 || frame.streamId % 2 != 1 ||
                frame.streamId <= lastOpenedStreamId ||
                (frame.flags & UInt8(0x4)) == UInt8(0)) {
                throw Exception("native H2 requires increasing client-initiated END_HEADERS streams")
            }
            if ((frame.flags & UInt8(0x8)) != UInt8(0) ||
                (frame.flags & UInt8(0x20)) != UInt8(0)) {
                throw Exception("native H2 does not support PADDED or PRIORITY HEADERS")
            }
            if (streams.size >= NATIVE_H2_MAX_CONCURRENT_STREAMS) {
                throw Exception("native H2 concurrent stream limit exceeded")
            }
            let stream = NativeH2InboundStream(frame.streamId, nativeH2DecodeRequestHead(frame.payload))
            streams.add(frame.streamId, stream)
            lastOpenedStreamId = frame.streamId
            if ((frame.flags & UInt8(0x1)) != UInt8(0)) {
                nativeH2DispatchCompletedStream(socket, streams, outbound, stream, handler)
                completedStreams += 1
                connectionSendWindow = nativeH2FlushOutbound(
                    socket, outbound, connectionSendWindow
                )
            }
            continue
        }
        if (frame.frameType == UInt8(0x0)) {
            if ((frame.flags & UInt8(0x8)) != UInt8(0)) {
                throw Exception("native H2 does not support PADDED DATA")
            }
            let stream = streams.get(frame.streamId) ??
                throw Exception("native H2 DATA references an unknown stream")
            stream.appendData(frame.payload)
            if ((frame.flags & UInt8(0x1)) != UInt8(0)) {
                nativeH2DispatchCompletedStream(socket, streams, outbound, stream, handler)
                completedStreams += 1
                connectionSendWindow = nativeH2FlushOutbound(
                    socket, outbound, connectionSendWindow
                )
            }
            continue
        }
        if (frame.frameType == UInt8(0x8)) {
            let increment = nativeH2DecodeWindowUpdate(frame)
            if (frame.streamId == 0) {
                connectionSendWindow = nativeH2IncreaseFlowWindow(
                    connectionSendWindow, increment, "connection"
                )
            } else if (let Some(stream) <- outbound.get(frame.streamId)) {
                stream.sendWindow = nativeH2IncreaseFlowWindow(
                    stream.sendWindow, increment, "stream"
                )
            } else {
                throw Exception("native H2 WINDOW_UPDATE references an unknown response stream")
            }
            connectionSendWindow = nativeH2FlushOutbound(
                socket, outbound, connectionSendWindow
            )
            continue
        }
        throw Exception("native H2 connection received an unsupported frame type")
    }
}

func nativeH2ServerSettingsPayload(): Array<UInt8> {
    [
        UInt8(0), UInt8(0x3),
        UInt8(0), UInt8(0), UInt8(0), UInt8(NATIVE_H2_MAX_CONCURRENT_STREAMS)
    ]
}

func nativeH2DispatchCompletedStream(
    socket: TcpSocket,
    streams: HashMap<Int64, NativeH2InboundStream>,
    outbound: HashMap<Int64, NativeH2OutboundStream>,
    stream: NativeH2InboundStream,
    handler: NativeH2SingleStreamHandler
): Unit {
    let response = handler(stream.request())
    nativeH2WriteFrame(
        socket,
        NativeH2Frame(
            UInt8(0x1),
            UInt8(0x4),
            stream.streamId,
            nativeH2EncodeResponseHead(response.status, response.headers)
        )
    )
    if (response.body.size > NATIVE_H2_MAX_FIRST_SLICE_BODY) {
        throw Exception("native H2 response body exceeds 1 MiB")
    }
    outbound.add(stream.streamId, NativeH2OutboundStream(stream.streamId, response.body))
    let _ = streams.remove(stream.streamId)
}

func nativeH2FlushOutbound(
    socket: TcpSocket,
    outbound: HashMap<Int64, NativeH2OutboundStream>,
    initialConnectionWindow: Int64
): Int64 {
    var connectionWindow = initialConnectionWindow
    var progressed = true
    while (progressed && outbound.size > 0) {
        progressed = false
        let completed = ArrayList<Int64>()
        for ((_streamId, stream) in outbound) {
            if (stream.remaining() == 0) {
                nativeH2WriteFrame(
                    socket,
                    NativeH2Frame(UInt8(0x0), UInt8(0x1), stream.streamId, Array<UInt8>())
                )
                completed.add(stream.streamId)
                progressed = true
                continue
            }
            if (stream.sendWindow <= 0 || connectionWindow <= 0) {
                continue
            }
            let count = min(
                min(stream.remaining(), NATIVE_H2_DEFAULT_MAX_FRAME_PAYLOAD),
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
        for (streamId in completed) {
            let _ = outbound.remove(streamId)
        }
    }
    connectionWindow
}

func nativeH2DecodeWindowUpdate(frame: NativeH2Frame): Int64 {
    if (frame.payload.size != 4) {
        throw Exception("native H2 WINDOW_UPDATE payload must be four bytes")
    }
    let increment =
        ((Int64(frame.payload[0]) & 0x7f) << 24) +
        (Int64(frame.payload[1]) << 16) +
        (Int64(frame.payload[2]) << 8) +
        Int64(frame.payload[3])
    if (increment == 0) {
        throw Exception("native H2 WINDOW_UPDATE increment must be non-zero")
    }
    increment
}

func nativeH2IncreaseFlowWindow(current: Int64, increment: Int64, scope: String): Int64 {
    if (current > NATIVE_H2_MAX_FLOW_WINDOW - increment) {
        throw Exception("native H2 ${scope} flow window overflow")
    }
    current + increment
}

func nativeH2HandleSettingsFrame(socket: TcpSocket, frame: NativeH2Frame): Unit {
    if (frame.streamId != 0) {
        throw Exception("native H2 SETTINGS must use stream 0")
    }
    if ((frame.flags & UInt8(0x1)) != UInt8(0)) {
        if (frame.payload.size != 0) {
            throw Exception("native H2 SETTINGS ACK must have an empty payload")
        }
        return
    }
    if (frame.payload.size % 6 != 0) {
        throw Exception("native H2 SETTINGS payload must contain 6-byte entries")
    }
    nativeH2WriteFrame(socket, NativeH2Frame(UInt8(0x4), UInt8(0x1), 0, Array<UInt8>()))
}

func nativeH2ReadFrame(socket: TcpSocket): NativeH2Frame {
    let header = nativeH2ReadExactly(socket, 9)
    let payloadLength =
        (Int64(header[0]) << 16) + (Int64(header[1]) << 8) + Int64(header[2])
    if (payloadLength > NATIVE_H2_DEFAULT_MAX_FRAME_PAYLOAD) {
        throw Exception("native H2 frame payload exceeds the default 16 KiB limit")
    }
    let streamId =
        ((Int64(header[5]) & 0x7f) << 24) +
        (Int64(header[6]) << 16) +
        (Int64(header[7]) << 8) +
        Int64(header[8])
    NativeH2Frame(
        header[3],
        header[4],
        streamId,
        nativeH2ReadExactly(socket, payloadLength)
    )
}

func nativeH2WriteFrame(socket: TcpSocket, frame: NativeH2Frame): Unit {
    let length = frame.payload.size
    if (length > NATIVE_H2_DEFAULT_MAX_FRAME_PAYLOAD) {
        throw Exception("native H2 response frame exceeds the default 16 KiB limit")
    }
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
    socket.write(wire)
}

func nativeH2ReadExactly(socket: TcpSocket, length: Int64): Array<UInt8> {
    let out = Array<UInt8>(length, repeat: 0)
    var offset: Int64 = 0
    while (offset < length) {
        let remaining = length - offset
        let chunk = Array<UInt8>(remaining, repeat: 0)
        let n = socket.read(chunk)
        if (n <= 0) {
            throw Exception("native H2 socket closed before bounded read completed")
        }
        var i: Int64 = 0
        while (i < n) {
            out[offset + i] = chunk[i]
            i += 1
        }
        offset += n
    }
    out
}

func nativeH2DecodeRequestHead(payload: Array<UInt8>): NativeH2DecodedRequestHead {
    var method = ""
    var scheme = ""
    var authority = ""
    var path = ""
    var cursor: Int64 = 0
    while (cursor < payload.size) {
        let first = payload[cursor]
        cursor += 1
        if ((first & UInt8(0x80)) != UInt8(0)) {
            let index = Int64(first & UInt8(0x7f))
            if (index == 0 || index == 127) {
                throw Exception("native H2 first-slice HPACK indexed integer is unsupported")
            }
            if (index > 61) {
                throw Exception("native H2 first-slice HPACK dynamic-table indexes are unsupported")
            }
            if (index == 2) {
                method = "GET"
            } else if (index == 3) {
                method = "POST"
            } else if (index == 4) {
                path = "/"
            } else if (index == 5) {
                path = "/index.html"
            } else if (index == 6) {
                scheme = "http"
            } else if (index == 7) {
                scheme = "https"
            }
            continue
        }
        if ((first & UInt8(0xf0)) != UInt8(0)) {
            throw Exception("native H2 first-slice HPACK only supports indexed or non-indexed literals")
        }
        let nameIndex = Int64(first & UInt8(0x0f))
        if (nameIndex == 15) {
            throw Exception("native H2 first-slice HPACK literal name integer is unsupported")
        }
        if (nameIndex != 1 && nameIndex != 4) {
            throw Exception("native H2 first-slice HPACK literal name is unsupported")
        }
        if (cursor >= payload.size) {
            throw Exception("native H2 HPACK literal is missing value length")
        }
        let valueLengthByte = payload[cursor]
        cursor += 1
        if ((valueLengthByte & UInt8(0x80)) != UInt8(0)) {
            throw Exception("native H2 first-slice HPACK Huffman strings are unsupported")
        }
        let valueLength = Int64(valueLengthByte & UInt8(0x7f))
        if (valueLength == 127) {
            throw Exception("native H2 first-slice HPACK string length integer is unsupported")
        }
        if (cursor + valueLength > payload.size) {
            throw Exception("native H2 HPACK literal value is truncated")
        }
        let value = String.fromUtf8(nativeH2Slice(payload, cursor, cursor + valueLength))
        cursor += valueLength
        if (nameIndex == 4) {
            path = value
        } else if (nameIndex == 1) {
            authority = value
        }
    }
    if (method.size == 0 || scheme.size == 0 || authority.size == 0 || path.size == 0) {
        throw Exception("native H2 first-slice request requires :method, :scheme, :authority, and :path")
    }
    NativeH2DecodedRequestHead(method, scheme, authority, path)
}

func nativeH2EncodeStatus(status: UInt16): Array<UInt8> {
    match (status) {
        case 200 => [UInt8(0x88)]
        case 204 => [UInt8(0x89)]
        case 206 => [UInt8(0x8a)]
        case 304 => [UInt8(0x8b)]
        case 400 => [UInt8(0x8c)]
        case 404 => [UInt8(0x8d)]
        case 500 => [UInt8(0x8e)]
        case _ =>
            let numeric = Int64(status)
            if (numeric < 200 || numeric > 999) {
                throw Exception("native H2 first-slice response status must be between 200 and 999")
            }
            let value = status.toString().toArray()
            [UInt8(0x08), UInt8(value.size), value[0], value[1], value[2]]
    }
}

func nativeH2EncodeResponseHead(
    status: UInt16,
    headers: Array<NativeH2Header>
): Array<UInt8> {
    let out = ArrayList<UInt8>()
    nativeH2AppendBytes(out, nativeH2EncodeStatus(status))
    for (header in headers) {
        let name = header.name
        if (name == "connection" || name == "keep-alive" || name == "proxy-connection" ||
            name == "transfer-encoding" || name == "upgrade" || name == "te") {
            continue
        }
        let nameBytes = name.toArray()
        let valueBytes = header.value.toArray()
        if (nameBytes.size == 0 || nameBytes.size >= 127 || valueBytes.size >= 127) {
            throw Exception("native H2 first-slice response header exceeds single-byte HPACK limits")
        }
        if (nameBytes[0] == UInt8(0x3a)) {
            throw Exception("native H2 application response headers cannot add pseudo-headers")
        }
        out.add(UInt8(0))
        out.add(UInt8(nameBytes.size))
        nativeH2AppendBytes(out, nameBytes)
        out.add(UInt8(valueBytes.size))
        nativeH2AppendBytes(out, valueBytes)
    }
    out.toArray()
}

func nativeH2AppendBytes(out: ArrayList<UInt8>, input: Array<UInt8>): Unit {
    for (value in input) {
        out.add(value)
    }
}

func nativeH2Slice(input: Array<UInt8>, start: Int64, end: Int64): Array<UInt8> {
    let out = Array<UInt8>(end - start, repeat: 0)
    var i: Int64 = 0
    while (start + i < end) {
        out[i] = input[start + i]
        i += 1
    }
    out
}

func nativeH2Clone(input: Array<UInt8>): Array<UInt8> {
    nativeH2Slice(input, 0, input.size)
}

func nativeH2CloneHeaders(input: Array<NativeH2Header>): Array<NativeH2Header> {
    let out = ArrayList<NativeH2Header>()
    for (header in input) {
        out.add(NativeH2Header(header.name, header.value))
    }
    out.toArray()
}

func nativeH2BytesEqual(left: Array<UInt8>, right: Array<UInt8>): Bool {
    if (left.size != right.size) {
        return false
    }
    var i: Int64 = 0
    while (i < left.size) {
        if (left[i] != right[i]) {
            return false
        }
        i += 1
    }
    true
}
