package ignite

import jinguissl.contract.{HashAlgorithm, contractHash}
import std.collection.ArrayList
import std.net.TcpSocket
import std.sync.Mutex

let NATIVE_WEBSOCKET_GUID = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
let NATIVE_WEBSOCKET_SMALL_FRAME_COALESCE_BYTES: Int64 = 4 * 1024
class NativeWebSocketProtocolException <: Exception {
    let closeStatus: UInt16

    init(message: String, closeStatus!: UInt16 = 1002) {
        super(message)
        this.closeStatus = closeStatus
    }
}

class NativeWebSocketConnection {
    let socket: TcpSocket
    let selectedSubProtocol: String
    let maxIncomingMessageBytes: Int64
    let writeMutex = Mutex()
    var closed: Bool = false

    init(
        socket: TcpSocket,
        selectedSubProtocol!: String = "",
        maxIncomingMessageBytes!: Int64 = DEFAULT_WEBSOCKET_MAX_MESSAGE_BYTES
    ) {
        this.socket = socket
        this.selectedSubProtocol = selectedSubProtocol
        this.maxIncomingMessageBytes = maxIncomingMessageBytes
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
                let frame = readNativeWebSocketFrame(
                    socket,
                    maxIncomingMessageBytes
                )
                match (frame.opcode) {
                    case 0 =>
                        if (!started) {
                            throw NativeWebSocketProtocolException(
                                "native WebSocket continuation arrived before a data frame"
                            )
                        }
                        appendNativeWebSocketPayload(
                            data,
                            frame.payload,
                            maxIncomingMessageBytes
                        )
                        if (frame.fin) {
                            return finishNativeWebSocketMessage(messageType, data)
                        }
                    case 1 =>
                        if (started) {
                            throw NativeWebSocketProtocolException(
                                "native WebSocket received a new text frame before continuation completed"
                            )
                        }
                        started = true
                        messageType = WsMessageType.Text
                        appendNativeWebSocketPayload(
                            data,
                            frame.payload,
                            maxIncomingMessageBytes
                        )
                        if (frame.fin) {
                            return finishNativeWebSocketMessage(messageType, data)
                        }
                    case 2 =>
                        if (started) {
                            throw NativeWebSocketProtocolException(
                                "native WebSocket received a new binary frame before continuation completed"
                            )
                        }
                        started = true
                        messageType = WsMessageType.Binary
                        appendNativeWebSocketPayload(
                            data,
                            frame.payload,
                            maxIncomingMessageBytes
                        )
                        if (frame.fin) {
                            return finishNativeWebSocketMessage(messageType, data)
                        }
                    case 8 =>
                        validateNativeWebSocketClosePayload(frame.payload)
                        echoNativeWebSocketClose(frame.payload)
                        return WsMessage(messageType: WsMessageType.Close, data: frame.payload)
                    case 9 => writeFrame(10, frame.payload)
                    case 10 => ()
                    case _ => throw NativeWebSocketProtocolException(
                        "native WebSocket received unsupported opcode ${frame.opcode}"
                    )
                }
            }
        } catch (e: NativeWebSocketProtocolException) {
            try {
                close(e.closeStatus, nativeWebSocketCloseReason(e.closeStatus))
            } catch (_: Exception) {}
            throw e
        }
        throw Exception("native WebSocket read loop ended unexpectedly")
    }

    func echoNativeWebSocketClose(payload: Array<UInt8>): Unit {
        var shouldClose = false
        synchronized(writeMutex) {
            if (!closed && !socket.isClosed()) {
                writeNativeWebSocketFrame(socket, 8, payload)
            }
            if (!closed) {
                closed = true
                shouldClose = true
            }
        }
        if (shouldClose && !socket.isClosed()) { socket.close() }
    }

    func writeText(text: String): Unit {
        writeFrame(1, text.toArray())
    }

    func writeBinary(data: Array<UInt8>): Unit {
        writeFrame(2, data)
    }

    func ping(data: Array<UInt8>): Unit {
        if (data.size > 125) {
            throw Exception("native WebSocket ping payload exceeds 125 bytes")
        }
        writeFrame(9, data)
    }

    func close(status: UInt16, reason: String): Unit {
        validateNativeWebSocketCloseStatus(Int64(status))
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
        var shouldClose = false
        synchronized(writeMutex) {
            if (!closed) {
                if (!socket.isClosed()) {
                    writeNativeWebSocketFrame(socket, 8, payload)
                }
                closed = true
                shouldClose = true
            }
        }
        if (shouldClose && !socket.isClosed()) { socket.close() }
    }

    func writeFrame(opcode: Int64, payload: Array<UInt8>): Unit {
        synchronized(writeMutex) {
            ensureOpenLocked()
            writeNativeWebSocketFrame(socket, opcode, payload)
        }
    }

    func ensureOpenLocked(): Unit {
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
    websocketKey: String,
    offeredSubProtocols: String,
    allowedSubProtocols: Array<String>,
    options: WebSocketOptions
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
    let selectedSubProtocol = selectNativeWebSocketSubProtocol(
        offeredSubProtocols,
        allowedSubProtocols
    )
    let protocolHeader = if (selectedSubProtocol.size > 0) {
        "Sec-WebSocket-Protocol: ${selectedSubProtocol}\r\n"
    } else {
        ""
    }
    socket.write(
        ("HTTP/1.1 101 Switching Protocols\r\n" +
        "Upgrade: websocket\r\n" +
        "Connection: Upgrade\r\n" +
        "Sec-WebSocket-Accept: ${accept}\r\n" +
        protocolHeader + "\r\n").toArray()
    )
    NativeWebSocketConnection(
        socket,
        selectedSubProtocol: selectedSubProtocol,
        maxIncomingMessageBytes: options.maxIncomingMessageBytes
    )
}

func selectNativeWebSocketSubProtocol(
    offeredRaw: String,
    allowed: Array<String>
): String {
    if (allowed.size == 0) { return "" }
    for (offeredPart in offeredRaw.split(",")) {
        let offered = offeredPart.trimAscii()
        for (candidate in allowed) {
            if (offered == candidate.trimAscii() && offered.size > 0) {
                return offered
            }
        }
    }
    ""
}

func readNativeWebSocketFrame(
    socket: TcpSocket,
    maxIncomingMessageBytes: Int64
): NativeWebSocketFrame {
    let head = readNativeWebSocketExact(socket, 2)
    let firstByte = Int64(head[0])
    let fin = (firstByte & 0x80) != 0
    if ((firstByte & 0x70) != 0) {
        throw NativeWebSocketProtocolException(
            "native WebSocket received RSV bits without a negotiated extension"
        )
    }
    let opcode = firstByte & 0x0F
    if (!nativeWebSocketOpcodeSupported(opcode)) {
        throw NativeWebSocketProtocolException(
            "native WebSocket received unsupported opcode ${opcode}"
        )
    }
    let masked = (Int64(head[1]) & 0x80) != 0
    if (!masked) {
        throw NativeWebSocketProtocolException("native WebSocket client frame must be masked")
    }
    var payloadLength = Int64(head[1]) & 0x7F
    if (payloadLength == 126) {
        let ext = readNativeWebSocketExact(socket, 2)
        payloadLength = (Int64(ext[0]) << 8) | Int64(ext[1])
        if (payloadLength < 126) {
            throw NativeWebSocketProtocolException(
                "native WebSocket payload length used a non-canonical 16-bit encoding"
            )
        }
    } else if (payloadLength == 127) {
        let ext = readNativeWebSocketExact(socket, 8)
        if ((Int64(ext[0]) & 0x80) != 0) {
            throw NativeWebSocketProtocolException(
                "native WebSocket payload length exceeds signed 63-bit range"
            )
        }
        payloadLength = 0
        for (b in ext) { payloadLength = (payloadLength << 8) | Int64(b) }
        if (payloadLength <= 65535) {
            throw NativeWebSocketProtocolException(
                "native WebSocket payload length used a non-canonical 64-bit encoding"
            )
        }
    }
    if (opcode < 8 && payloadLength > maxIncomingMessageBytes) {
        throw NativeWebSocketProtocolException(
            "native WebSocket frame exceeds configured maxIncomingMessageBytes",
            closeStatus: 1009
        )
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
    validateNativeWebSocketCloseStatus(status)
    if (payload.size > 2) {
        try {
            let _ = String.fromUtf8(payload[2..payload.size])
        } catch (_: Exception) {
            throw NativeWebSocketProtocolException(
                "native WebSocket close reason is not valid UTF-8",
                closeStatus: 1007
            )
        }
    }
}

func writeNativeWebSocketFrame(socket: TcpSocket, opcode: Int64, payload: Array<UInt8>): Unit {
    let header = ArrayList<UInt8>()
    header.add(UInt8(0x80 | opcode))
    if (payload.size <= 125) {
        header.add(UInt8(payload.size))
    } else if (payload.size <= 65535) {
        header.add(UInt8(126))
        header.add(UInt8((payload.size >> 8) & 0xFF))
        header.add(UInt8(payload.size & 0xFF))
    } else {
        header.add(UInt8(127))
        var shift: Int64 = 56
        while (shift >= 0) {
            header.add(UInt8((payload.size >> shift) & 0xFF))
            shift -= 8
        }
    }
    let headerBytes = header.toArray()
    if (payload.size <= NATIVE_WEBSOCKET_SMALL_FRAME_COALESCE_BYTES) {
        let frame = Array<UInt8>(headerBytes.size + payload.size, repeat: 0)
        var i: Int64 = 0
        while (i < headerBytes.size) {
            frame[i] = headerBytes[i]
            i += 1
        }
        var payloadOffset: Int64 = 0
        while (payloadOffset < payload.size) {
            frame[headerBytes.size + payloadOffset] = payload[payloadOffset]
            payloadOffset += 1
        }
        socket.write(frame)
        return
    }
    socket.write(headerBytes)
    socket.write(payload)
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

func appendNativeWebSocketPayload(
    out: ArrayList<UInt8>,
    payload: Array<UInt8>,
    maxIncomingMessageBytes: Int64
): Unit {
    if (out.size + payload.size > maxIncomingMessageBytes) {
        throw NativeWebSocketProtocolException(
            "native WebSocket message exceeds configured maxIncomingMessageBytes",
            closeStatus: 1009
        )
    }
    for (b in payload) { out.add(b) }
}

func finishNativeWebSocketMessage(
    messageType: WsMessageType,
    data: ArrayList<UInt8>
): WsMessage {
    let payload = data.toArray()
    match (messageType) {
        case Text =>
            try {
                let _ = String.fromUtf8(payload)
            } catch (_: Exception) {
                throw NativeWebSocketProtocolException(
                    "native WebSocket text message is not valid UTF-8",
                    closeStatus: 1007
                )
            }
        case _ => ()
    }
    WsMessage(messageType: messageType, data: payload)
}

func nativeWebSocketOpcodeSupported(opcode: Int64): Bool {
    opcode == 0 || opcode == 1 || opcode == 2 || opcode == 8 ||
        opcode == 9 || opcode == 10
}

func validateNativeWebSocketCloseStatus(status: Int64): Unit {
    let standard = status >= 1000 && status <= 1014 &&
        status != 1004 && status != 1005 && status != 1006
    let application = status >= 3000 && status <= 4999
    if (!standard && !application) {
        throw NativeWebSocketProtocolException(
            "native WebSocket close payload contains invalid status ${status}"
        )
    }
}

func nativeWebSocketCloseReason(status: UInt16): String {
    match (status) {
        case 1007 => "invalid utf-8"
        case 1009 => "message too large"
        case _ => "protocol error"
    }
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
