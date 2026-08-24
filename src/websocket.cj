package ignite

import stdx.net.http.{WebSocket, WebSocketFrame, WebSocketFrameType}
import std.collection.ArrayList
import std.sync.Mutex

public type WsHandler = (WsConn) -> Unit

let DEFAULT_WEBSOCKET_MAX_MESSAGE_BYTES: Int64 = 1024 * 1024

public struct WebSocketOptions {
    public let maxIncomingMessageBytes: Int64

    public init(
        maxIncomingMessageBytes!: Int64 = DEFAULT_WEBSOCKET_MAX_MESSAGE_BYTES
    ) {
        if (maxIncomingMessageBytes <= 0) {
            throw Exception(
                "WebSocket maxIncomingMessageBytes must be greater than zero"
            )
        }
        this.maxIncomingMessageBytes = maxIncomingMessageBytes
    }
}

public enum WsMessageType {
    Text |
    Binary |
    Close
}

class WebSocketIncomingMessageTooLargeException <: Exception {
    init() {
        super("WebSocket message exceeds configured maxIncomingMessageBytes")
    }
}

public interface WebSocketUpgradeCarrier {
    func upgradeWebSocket(
        subProtocols: Array<String>,
        options: WebSocketOptions
    ): WsConn
}

func currentRequestCarrierUpgradeWebSocket(
    carrier: CurrentRequestCarrier,
    subProtocols: Array<String>,
    options: WebSocketOptions
): WsConn {
    if (let Some(upgrader) <- (carrier as WebSocketUpgradeCarrier)) {
        return upgrader.upgradeWebSocket(subProtocols, options)
    }
    throw Exception(
        "current request carrier does not expose WebSocket upgrade capability"
    )
}

public class WsConn {
    let _ws: ?WebSocket
    let _native: ?NativeWebSocketConnection
    let _maxIncomingMessageBytes: Int64
    let _readMutex = Mutex()
    let _writeMutex = Mutex()

    public init(
        ws: WebSocket,
        maxIncomingMessageBytes!: Int64 = DEFAULT_WEBSOCKET_MAX_MESSAGE_BYTES
    ) {
        if (maxIncomingMessageBytes <= 0) {
            throw Exception(
                "WebSocket maxIncomingMessageBytes must be greater than zero"
            )
        }
        _ws = Some(ws)
        _native = None
        _maxIncomingMessageBytes = maxIncomingMessageBytes
    }

    init(native: NativeWebSocketConnection) {
        _ws = None
        _native = Some(native)
        _maxIncomingMessageBytes = native.maxIncomingMessageBytes
    }

    public func readMessage(): WsMessage {
        synchronized(_readMutex) {
            readMessageLocked()
        }
    }

    func readMessageLocked(): WsMessage {
        if (let Some(native) <- _native) {
            return native.readMessage()
        }
        let ws = _ws ?? throw Exception("WebSocket connection backend is unavailable")
        let data = ArrayList<UInt8>()
        var msgType = WsMessageType.Text
        try {
            while (true) {
                let frame = ws.read()
                match (frame.frameType) {
                    case TextWebFrame | BinaryWebFrame =>
                        msgType = if (frame.frameType == WebSocketFrameType.TextWebFrame) {
                            WsMessageType.Text
                        } else {
                            WsMessageType.Binary
                        }
                        appendBoundedWebSocketPayload(
                            data,
                            frame.payload,
                            _maxIncomingMessageBytes
                        )
                        if (frame.fin) { break }
                    case ContinuationWebFrame =>
                        appendBoundedWebSocketPayload(
                            data,
                            frame.payload,
                            _maxIncomingMessageBytes
                        )
                        if (frame.fin) { break }
                    case CloseWebFrame =>
                        return WsMessage(messageType: WsMessageType.Close, data: frame.payload)
                    case PingWebFrame =>
                        synchronized(_writeMutex) { ws.writePongFrame(frame.payload) }
                    case _ => ()
                }
            }
        } catch (e: WebSocketIncomingMessageTooLargeException) {
            synchronized(_writeMutex) {
                try {
                    ws.writeCloseFrame(status: 1009, reason: "message too large")
                } catch (_: Exception) {}
                ws.closeConn()
            }
            throw e
        }
        WsMessage(messageType: msgType, data: data.toArray())
    }

    public func writeText(text: String): Unit {
        synchronized(_writeMutex) {
            if (let Some(native) <- _native) {
                native.writeText(text)
                return
            }
            (_ws ?? throw Exception("WebSocket connection backend is unavailable"))
                .write(WebSocketFrameType.TextWebFrame, text.toArray())
        }
    }

    public func writeBinary(data: Array<UInt8>): Unit {
        synchronized(_writeMutex) {
            if (let Some(native) <- _native) {
                native.writeBinary(data)
                return
            }
            (_ws ?? throw Exception("WebSocket connection backend is unavailable"))
                .write(WebSocketFrameType.BinaryWebFrame, data)
        }
    }

    public func close(status!: UInt16 = 1000, reason!: String = ""): Unit {
        synchronized(_writeMutex) {
            if (let Some(native) <- _native) {
                native.close(status, reason)
                return
            }
            let ws = _ws ?? throw Exception("WebSocket connection backend is unavailable")
            ws.writeCloseFrame(status: status, reason: reason)
            ws.closeConn()
        }
    }

    public func ping(data!: Array<UInt8> = Array<UInt8>(0, repeat: 0)): Unit {
        synchronized(_writeMutex) {
            if (let Some(native) <- _native) {
                native.ping(data)
                return
            }
            (_ws ?? throw Exception("WebSocket connection backend is unavailable"))
                .writePingFrame(data)
        }
    }

    public prop subProtocol: String {
        get() {
            if (let Some(native) <- _native) {
                return native.subProtocol
            }
            (_ws ?? throw Exception("WebSocket connection backend is unavailable")).subProtocol
        }
    }
}

func appendBoundedWebSocketPayload(
    out: ArrayList<UInt8>,
    payload: Array<UInt8>,
    maxIncomingMessageBytes: Int64
): Unit {
    if (out.size + payload.size > maxIncomingMessageBytes) {
        throw WebSocketIncomingMessageTooLargeException()
    }
    for (b in payload) { out.add(b) }
}

public struct WsMessage {
    public let messageType: WsMessageType
    public let data: Array<UInt8>

    public init(messageType!: WsMessageType, data!: Array<UInt8>) {
        this.messageType = messageType
        this.data = data
    }

    public init(messageType!: WebSocketFrameType, data!: Array<UInt8>) {
        this.messageType = match (messageType) {
            case TextWebFrame => WsMessageType.Text
            case BinaryWebFrame => WsMessageType.Binary
            case CloseWebFrame => WsMessageType.Close
            case _ => WsMessageType.Binary
        }
        this.data = data
    }

    public func text(): String {
        String.fromUtf8(data)
    }

    public prop isClose: Bool {
        get() {
            match (messageType) {
                case Close => true
                case _ => false
            }
        }
    }

    public prop isText: Bool {
        get() {
            match (messageType) {
                case Text => true
                case _ => false
            }
        }
    }

    public prop isBinary: Bool {
        get() {
            match (messageType) {
                case Binary => true
                case _ => false
            }
        }
    }
}
