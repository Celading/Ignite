package ignite.native_h2

import std.collection.ArrayList
import std.net.TcpSocket

let NATIVE_H2_PREFACE = "PRI * HTTP/2.0\r\n\r\nSM\r\n\r\n".toArray()
let NATIVE_H2_MAX_FIRST_SLICE_BODY: Int64 = 1024 * 1024
let NATIVE_H2_DEFAULT_MAX_FRAME_PAYLOAD: Int64 = 16384

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
    public let body: Array<UInt8>

    public init(status!: UInt16 = 200, body!: Array<UInt8> = Array<UInt8>()) {
        this.status = status
        this.body = nativeH2Clone(body)
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

/// Serves one bounded HTTP/2 stream on an already accepted cleartext socket.
///
/// This first AP2 slice owns the real preface/SETTINGS/frame lifecycle but
/// intentionally does not claim multiplexing, flow control, TLS, CONTINUATION,
/// dynamic-table HPACK, or Huffman decoding.
public func serveNativeH2SingleStream(
    socket: TcpSocket,
    handler: NativeH2SingleStreamHandler
): Unit {
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
    nativeH2WriteFrame(socket, NativeH2Frame(UInt8(0x4), UInt8(0), 0, Array<UInt8>()))
    nativeH2WriteFrame(socket, NativeH2Frame(UInt8(0x4), UInt8(0x1), 0, Array<UInt8>()))

    let headers = nativeH2ReadFrame(socket)
    if (headers.frameType != UInt8(0x1) || headers.streamId <= 0 ||
        headers.streamId % 2 != 1 ||
        (headers.flags & UInt8(0x4)) == UInt8(0)) {
        throw Exception("native H2 first slice requires one client-initiated END_HEADERS HEADERS frame")
    }
    if ((headers.flags & UInt8(0x8)) != UInt8(0) ||
        (headers.flags & UInt8(0x20)) != UInt8(0)) {
        throw Exception("native H2 first slice does not support PADDED or PRIORITY HEADERS")
    }
    let decoded = nativeH2DecodeRequestHead(headers.payload)
    let body = ArrayList<UInt8>()
    var endStream = (headers.flags & UInt8(0x1)) != UInt8(0)
    while (!endStream) {
        let data = nativeH2ReadFrame(socket)
        if (data.frameType != UInt8(0x0) || data.streamId != headers.streamId) {
            throw Exception("native H2 first slice requires same-stream DATA after HEADERS")
        }
        if ((data.flags & UInt8(0x8)) != UInt8(0)) {
            throw Exception("native H2 first slice does not support PADDED DATA")
        }
        if (body.size + data.payload.size > NATIVE_H2_MAX_FIRST_SLICE_BODY) {
            throw Exception("native H2 first-slice request body exceeds 1 MiB")
        }
        for (value in data.payload) {
            body.add(value)
        }
        endStream = (data.flags & UInt8(0x1)) != UInt8(0)
    }

    let response = handler(
        NativeH2SingleStreamRequest(
            headers.streamId,
            decoded.method,
            decoded.scheme,
            decoded.authority,
            decoded.path,
            body.toArray()
        )
    )
    nativeH2WriteFrame(
        socket,
        NativeH2Frame(
            UInt8(0x1),
            UInt8(0x4),
            headers.streamId,
            nativeH2EncodeStatus(response.status)
        )
    )
    nativeH2WriteResponseData(socket, headers.streamId, response.body)
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

func nativeH2WriteResponseData(socket: TcpSocket, streamId: Int64, body: Array<UInt8>): Unit {
    if (body.size > NATIVE_H2_MAX_FIRST_SLICE_BODY) {
        throw Exception("native H2 first-slice response body exceeds 1 MiB")
    }
    if (body.size == 0) {
        nativeH2WriteFrame(
            socket,
            NativeH2Frame(UInt8(0x0), UInt8(0x1), streamId, Array<UInt8>())
        )
        return
    }

    var offset: Int64 = 0
    while (offset < body.size) {
        let end = min(offset + NATIVE_H2_DEFAULT_MAX_FRAME_PAYLOAD, body.size)
        let flags = if (end == body.size) { UInt8(0x1) } else { UInt8(0) }
        nativeH2WriteFrame(
            socket,
            NativeH2Frame(UInt8(0x0), flags, streamId, nativeH2Slice(body, offset, end))
        )
        offset = end
    }
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
        case _ => throw Exception("native H2 first-slice response status is unsupported")
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
