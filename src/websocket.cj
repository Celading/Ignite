package ignite

import stdx.net.http.{HttpContext, WebSocket, WebSocketFrame, WebSocketFrameType}
import std.collection.ArrayList

public type WsHandler = (WsConn) -> Unit

public enum WsMessageType {
    Text |
    Binary |
    Close
}

interface NativeWebSocketUpgradeCarrier {
    func upgradeNativeWebSocket(subProtocols: Array<String>): WsConn
}

func upgradeStdxWebSocketWithSubProtocols(
    carrier: CurrentRequestCarrier,
    subProtocols: Array<String>
): WsConn {
    let allowed = ArrayList<String>()
    for (protocol in subProtocols) { allowed.add(protocol) }
    WsConn(WebSocket.upgradeFromServer(carrier.rawHttpContext(), subProtocols: allowed))
}

public class WsConn {
    let _ws: ?WebSocket
    let _native: ?NativeWebSocketConnection

    public init(ws: WebSocket) {
        _ws = Some(ws)
        _native = None
    }

    init(native: NativeWebSocketConnection) {
        _ws = None
        _native = Some(native)
    }

    public func readMessage(): WsMessage {
        if (let Some(native) <- _native) {
            return native.readMessage()
        }
        let ws = _ws ?? throw Exception("WebSocket connection backend is unavailable")
        let data = ArrayList<UInt8>()
        var msgType = WsMessageType.Text
        while (true) {
            let frame = ws.read()
            match (frame.frameType) {
                case TextWebFrame | BinaryWebFrame =>
                    msgType = if (frame.frameType == WebSocketFrameType.TextWebFrame) {
                        WsMessageType.Text
                    } else {
                        WsMessageType.Binary
                    }
                    for (b in frame.payload) { data.add(b) }
                    if (frame.fin) { break }
                case ContinuationWebFrame =>
                    for (b in frame.payload) { data.add(b) }
                    if (frame.fin) { break }
                case CloseWebFrame =>
                    return WsMessage(messageType: WsMessageType.Close, data: frame.payload)
                case PingWebFrame =>
                    ws.writePongFrame(frame.payload)
                case _ => ()
            }
        }
        WsMessage(messageType: msgType, data: data.toArray())
    }

    public func writeText(text: String): Unit {
        if (let Some(native) <- _native) {
            native.writeText(text)
            return
        }
        (_ws ?? throw Exception("WebSocket connection backend is unavailable"))
            .write(WebSocketFrameType.TextWebFrame, text.toArray())
    }

    public func writeBinary(data: Array<UInt8>): Unit {
        if (let Some(native) <- _native) {
            native.writeBinary(data)
            return
        }
        (_ws ?? throw Exception("WebSocket connection backend is unavailable"))
            .write(WebSocketFrameType.BinaryWebFrame, data)
    }

    public func close(status!: UInt16 = 1000, reason!: String = ""): Unit {
        if (let Some(native) <- _native) {
            native.close(status, reason)
            return
        }
        let ws = _ws ?? throw Exception("WebSocket connection backend is unavailable")
        ws.writeCloseFrame(status: status, reason: reason)
        ws.closeConn()
    }

    public func ping(data!: Array<UInt8> = Array<UInt8>(0, repeat: 0)): Unit {
        if (let Some(native) <- _native) {
            native.ping(data)
            return
        }
        (_ws ?? throw Exception("WebSocket connection backend is unavailable"))
            .writePingFrame(data)
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
