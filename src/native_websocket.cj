package ignite

import jinguissl.contract.{HashAlgorithm, contractHash}
import std.collection.ArrayList
import std.net.TcpSocket

let NATIVE_WEBSOCKET_GUID = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
let NATIVE_WEBSOCKET_MAX_MESSAGE_BYTES: Int64 = 1024 * 1024

class NativeWebSocketProtocolException <: Exception {
    init(message: String) { super(message) }
}

class NativeWebSocketConnection {
    let socket: TcpSocket
    let selectedSubProtocol: String
    var closed: Bool = false

    init(socket: TcpSocket, selectedSubProtocol!: String = "") {
        this.socket = socket
        this.selectedSubProtocol = selectedSubProtocol
    }

    public prop subProtocol: String {
        get() { selectedSubProtocol }
    }

    func readMessage(): WsMessage {
        let data = ArrayList<UInt8>()
        var messageType = WsMessageType.Text
        var started = false
        try {
            while (true) {
                let frame = readNativeWebSocketFrame(socket)
                match (frame.opcode) {
                    case 0 =>
                        if (!started) {
                            throw NativeWebSocketProtocolException(
                                "native WebSocket continuation arrived before a data frame"
                            )
                        }
                        appendNativeWebSocketPayload(data, frame.payload)
                        if (frame.fin) {
                            return WsMessage(messageType: messageType, data: data.toArray())
                        }
                    case 1 =>
                        if (started) {
                            throw NativeWebSocketProtocolException(
                                "native WebSocket received a new text frame before continuation completed"
                            )
                        }
                        started = true
                        messageType = WsMessageType.Text
                        appendNativeWebSocketPayload(data, frame.payload)
                        if (frame.fin) {
                            return WsMessage(messageType: messageType, data: data.toArray())
                        }
                    case 2 =>
                        if (started) {
                            throw NativeWebSocketProtocolException(
                                "native WebSocket received a new binary frame before continuation completed"
                            )
                        }
                        started = true
                        messageType = WsMessageType.Binary
                        appendNativeWebSocketPayload(data, frame.payload)
                        if (frame.fin) {
                            return WsMessage(messageType: messageType, data: data.toArray())
                        }
                    case 8 =>
                        validateNativeWebSocketClosePayload(frame.payload)
                        echoNativeWebSocketClose(frame.payload)
                        return WsMessage(messageType: WsMessageType.Close, data: frame.payload)
                    case 9 => writeNativeWebSocketFrame(socket, 10, frame.payload)
                    case 10 => ()
                    case _ => throw NativeWebSocketProtocolException(
                        "native WebSocket received unsupported opcode ${frame.opcode}"
                    )
                }
            }
        } catch (e: NativeWebSocketProtocolException) {
            close(1002, "protocol error")
            throw e
        }
        throw Exception("native WebSocket read loop ended unexpectedly")
    }

    func echoNativeWebSocketClose(payload: Array<UInt8>): Unit {
        if (!closed && !socket.isClosed()) {
            writeNativeWebSocketFrame(socket, 8, payload)
        }
        closed = true
        if (!socket.isClosed()) { socket.close() }
    }

    func writeText(text: String): Unit {
        ensureOpen()
        writeNativeWebSocketFrame(socket, 1, text.toArray())
    }

    func writeBinary(data: Array<UInt8>): Unit {
        ensureOpen()
        writeNativeWebSocketFrame(socket, 2, data)
    }

    func ping(data: Array<UInt8>): Unit {
        ensureOpen()
        if (data.size > 125) {
            throw Exception("native WebSocket ping payload exceeds 125 bytes")
        }
        writeNativeWebSocketFrame(socket, 9, data)
    }

    func close(status: UInt16, reason: String): Unit {
        if (closed) { return }
        let reasonBytes = reason.toArray()
        if (reasonBytes.size > 123) {
            throw Exception("native WebSocket close reason exceeds 123 bytes")
        }
        let payload = Array<UInt8>(reasonBytes.size + 2, repeat: 0)
        payload[0] = UInt8((Int64(status) >> 8) & 0xFF)
        payload[1] = UInt8(Int64(status) & 0xFF)
        var i: Int64 = 0
        while (i < reasonBytes.size) {
            payload[i + 2] = reasonBytes[i]
            i += 1
        }
        writeNativeWebSocketFrame(socket, 8, payload)
        closed = true
        if (!socket.isClosed()) { socket.close() }
    }

    func ensureOpen(): Unit {
        if (closed || socket.isClosed()) {
            throw Exception("native WebSocket connection is closed")
        }
    }
}

struct NativeWebSocketFrame {
    let fin: Bool
    let opcode: Int64
    let payload: Array<UInt8>

    init(fin: Bool, opcode: Int64, payload: Array<UInt8>) {
        this.fin = fin
        this.opcode = opcode
        this.payload = payload
    }
}

func openNativeWebSocketConnection(
    socket: TcpSocket,
    method: String,
    requestVersion: String,
    connectionHeader: String,
    upgradeHeader: String,
    websocketVersion: String,
    websocketKey: String
): NativeWebSocketConnection {
    if (method.trimAscii().toAsciiUpper() != "GET") {
        throw Exception("native WebSocket upgrade requires GET")
    }
    if (requestVersion.trimAscii().toAsciiUpper() != "HTTP/1.1") {
        throw Exception("native WebSocket upgrade requires HTTP/1.1")
    }
    if (!nativeWebSocketHeaderHasToken(connectionHeader, "upgrade")) {
        throw Exception("native WebSocket upgrade requires Connection: Upgrade")
    }
    if (upgradeHeader.trimAscii().toAsciiLower() != "websocket") {
        throw Exception("native WebSocket upgrade requires Upgrade: websocket")
    }
    if (websocketVersion.trimAscii() != "13") {
        throw Exception("native WebSocket upgrade requires Sec-WebSocket-Version: 13")
    }
    let key = websocketKey.trimAscii()
    if (decodeNativeWebSocketBase64(key).size != 16) {
        throw Exception("native WebSocket key must decode to 16 bytes")
    }
    let digest = contractHash(HashAlgorithm.SHA1, (key + NATIVE_WEBSOCKET_GUID).toArray())
    let accept = encodeNativeWebSocketBase64(nativeWebSocketUInt8Array(digest))
    socket.write(
        ("HTTP/1.1 101 Switching Protocols\r\n" +
        "Upgrade: websocket\r\n" +
        "Connection: Upgrade\r\n" +
        "Sec-WebSocket-Accept: ${accept}\r\n\r\n").toArray()
    )
    NativeWebSocketConnection(socket)
}

func readNativeWebSocketFrame(socket: TcpSocket): NativeWebSocketFrame {
    let head = readNativeWebSocketExact(socket, 2)
    let fin = (Int64(head[0]) & 0x80) != 0
    let opcode = Int64(head[0]) & 0x0F
    let masked = (Int64(head[1]) & 0x80) != 0
    if (!masked) {
        throw NativeWebSocketProtocolException("native WebSocket client frame must be masked")
    }
    var payloadLength = Int64(head[1]) & 0x7F
    if (payloadLength == 126) {
        let ext = readNativeWebSocketExact(socket, 2)
        payloadLength = (Int64(ext[0]) << 8) | Int64(ext[1])
    } else if (payloadLength == 127) {
        let ext = readNativeWebSocketExact(socket, 8)
        if ((Int64(ext[0]) & 0x80) != 0) {
            throw NativeWebSocketProtocolException(
                "native WebSocket payload length exceeds signed 63-bit range"
            )
        }
        payloadLength = 0
        for (b in ext) { payloadLength = (payloadLength << 8) | Int64(b) }
    }
    if (payloadLength > NATIVE_WEBSOCKET_MAX_MESSAGE_BYTES) {
        throw NativeWebSocketProtocolException("native WebSocket frame exceeds bounded message limit")
    }
    if (opcode >= 8 && (!fin || payloadLength > 125)) {
        throw NativeWebSocketProtocolException(
            "native WebSocket control frame must be final and at most 125 bytes"
        )
    }
    let mask = readNativeWebSocketExact(socket, 4)
    let payload = readNativeWebSocketExact(socket, payloadLength)
    var i: Int64 = 0
    while (i < payload.size) {
        payload[i] = payload[i] ^ mask[i % 4]
        i += 1
    }
    NativeWebSocketFrame(fin, opcode, payload)
}

func validateNativeWebSocketClosePayload(payload: Array<UInt8>): Unit {
    if (payload.size == 1) {
        throw NativeWebSocketProtocolException(
            "native WebSocket close payload cannot contain a one-byte status"
        )
    }
    if (payload.size < 2) { return }
    let status = (Int64(payload[0]) << 8) | Int64(payload[1])
    let standard = status >= 1000 && status <= 1014 &&
        status != 1004 && status != 1005 && status != 1006
    let application = status >= 3000 && status <= 4999
    if (!standard && !application) {
        throw NativeWebSocketProtocolException(
            "native WebSocket close payload contains invalid status ${status}"
        )
    }
    if (payload.size > 2) {
        try {
            let _ = String.fromUtf8(payload[2..payload.size])
        } catch (_: Exception) {
            throw NativeWebSocketProtocolException(
                "native WebSocket close reason is not valid UTF-8"
            )
        }
    }
}

func writeNativeWebSocketFrame(socket: TcpSocket, opcode: Int64, payload: Array<UInt8>): Unit {
    let out = ArrayList<UInt8>()
    out.add(UInt8(0x80 | opcode))
    if (payload.size <= 125) {
        out.add(UInt8(payload.size))
    } else if (payload.size <= 65535) {
        out.add(UInt8(126))
        out.add(UInt8((payload.size >> 8) & 0xFF))
        out.add(UInt8(payload.size & 0xFF))
    } else {
        out.add(UInt8(127))
        var shift: Int64 = 56
        while (shift >= 0) {
            out.add(UInt8((payload.size >> shift) & 0xFF))
            shift -= 8
        }
    }
    appendNativeWebSocketPayload(out, payload)
    socket.write(out.toArray())
}

func readNativeWebSocketExact(socket: TcpSocket, size: Int64): Array<UInt8> {
    let out = Array<UInt8>(size, repeat: 0)
    var offset: Int64 = 0
    while (offset < size) {
        let buf = Array<UInt8>(size - offset, repeat: 0)
        let n = socket.read(buf)
        if (n <= 0) { throw Exception("native WebSocket peer closed during frame read") }
        var i: Int64 = 0
        while (i < n) {
            out[offset + i] = buf[i]
            i += 1
        }
        offset += n
    }
    out
}

func appendNativeWebSocketPayload(out: ArrayList<UInt8>, payload: Array<UInt8>): Unit {
    if (out.size + payload.size > NATIVE_WEBSOCKET_MAX_MESSAGE_BYTES + 16) {
        throw Exception("native WebSocket message exceeds bounded message limit")
    }
    for (b in payload) { out.add(b) }
}

func nativeWebSocketHeaderHasToken(value: String, expected: String): Bool {
    for (part in value.split(",")) {
        if (part.trimAscii().toAsciiLower() == expected) { return true }
    }
    false
}

func encodeNativeWebSocketBase64(data: Array<UInt8>): String {
    let table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".toRuneArray()
    var result = ""
    var i: Int64 = 0
    while (i < data.size) {
        let b0 = Int64(data[i])
        let b1 = if (i + 1 < data.size) { Int64(data[i + 1]) } else { 0 }
        let b2 = if (i + 2 < data.size) { Int64(data[i + 2]) } else { 0 }
        let triple = (b0 << 16) | (b1 << 8) | b2
        result += table[(triple >> 18) & 0x3F].toString()
        result += table[(triple >> 12) & 0x3F].toString()
        result += if (i + 1 < data.size) { table[(triple >> 6) & 0x3F].toString() } else { "=" }
        result += if (i + 2 < data.size) { table[triple & 0x3F].toString() } else { "=" }
        i += 3
    }
    result
}

func decodeNativeWebSocketBase64(input: String): Array<UInt8> {
    let table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".toRuneArray()
    let out = ArrayList<UInt8>()
    var buffer: Int64 = 0
    var bits: Int64 = 0
    for (ch in input.toRuneArray()) {
        if (ch == r'=') { break }
        var index: Int64 = -1
        var i: Int64 = 0
        while (i < table.size) {
            if (table[i] == ch) { index = i; break }
            i += 1
        }
        if (index < 0) { throw Exception("native WebSocket key is not valid base64") }
        buffer = (buffer << 6) | index
        bits += 6
        if (bits >= 8) {
            bits -= 8
            out.add(UInt8((buffer >> bits) & 0xFF))
        }
    }
    out.toArray()
}

func nativeWebSocketUInt8Array(input: Array<Byte>): Array<UInt8> {
    let out = Array<UInt8>(input.size, repeat: 0)
    var i: Int64 = 0
    while (i < input.size) {
        out[i] = UInt8(input[i])
        i += 1
    }
    out
}
