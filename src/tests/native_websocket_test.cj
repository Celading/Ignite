package ignite.tests

import ignite.*
import std.collection.{ArrayList, HashMap}
import std.net.{IPSocketAddress, TcpSocket}
import std.time.DateTime

@Test
public class NativeWebSocketTestSuite {
    @TestCase
    public func testNativeH1WebSocketUpgradeAndTextEchoOnRealSocket(): Unit {
        let port = chooseNativeWebSocketPort(1931)
        let app = App(config: Config(enableNetworkChangeNotice: false))
        app.ws("/native-ws", { conn =>
            let message = conn.readMessage()
            conn.writeText("echo:" + message.text())
            conn.close()
        })
        let serverFuture = spawn { app.listen("127.0.0.1", port) }
        let socket = connectNativeWebSocketWithRetry(port)
        try {
            socket.write(
                ("GET /native-ws HTTP/1.1\r\n" +
                "Host: 127.0.0.1:${port}\r\n" +
                "Upgrade: websocket\r\n" +
                "Connection: keep-alive, Upgrade\r\n" +
                "Sec-WebSocket-Version: 13\r\n" +
                "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\n\r\n").toArray()
            )
            let responseHead = readNativeWebSocketResponseHead(socket)
            @Assert(nativeWebSocketTestContains(responseHead, "HTTP/1.1 101 Switching Protocols\r\n"), true)
            @Assert(nativeWebSocketTestContains(responseHead, "Upgrade: websocket\r\n"), true)
            @Assert(nativeWebSocketTestContains(responseHead, "Connection: Upgrade\r\n"), true)
            @Assert(
                nativeWebSocketTestContains(
                    responseHead,
                    "Sec-WebSocket-Accept: s3pPLMBiTxaQ9kYGzzhZRbK+xOo=\r\n"
                ),
                true
            )

            socket.write(maskedNativeWebSocketTextFrame("hello"))
            let frame = readNativeWebSocketServerFrame(socket)
            @Assert(frame.opcode, Int64(1))
            @Assert(String.fromUtf8(frame.payload), "echo:hello")
        } finally {
            if (!socket.isClosed()) { socket.close() }
            app.shutdown()
            try {
                let _ = serverFuture.get(Duration.second * 1)
            } catch (_: Exception) {
                serverFuture.cancel()
            }
        }
    }
}

struct NativeWebSocketTestFrame {
    let opcode: Int64
    let payload: Array<UInt8>

    init(opcode: Int64, payload: Array<UInt8>) {
        this.opcode = opcode
        this.payload = payload
    }
}

func connectNativeWebSocketWithRetry(port: UInt16): TcpSocket {
    var attempt: Int64 = 0
    while (attempt < 30) {
        try {
            let socket = TcpSocket(IPSocketAddress.parse("127.0.0.1:${port}"))
            socket.connect()
            socket.readTimeout = Some(Duration.second * 2)
            return socket
        } catch (e: Exception) {
            if (attempt + 1 >= 30) {
                throw Exception("failed to connect native WebSocket fixture: ${e.message}")
            }
            sleep(Duration.millisecond * 20)
            attempt += 1
        }
    }
    throw Exception("failed to connect native WebSocket fixture")
}

func readNativeWebSocketResponseHead(socket: TcpSocket): String {
    let bytes = ArrayList<UInt8>()
    while (bytes.size < 8192) {
        let buf = Array<UInt8>(512, repeat: 0)
        let n = socket.read(buf)
        if (n <= 0) { throw Exception("native WebSocket peer closed before upgrade response") }
        var i: Int64 = 0
        while (i < n) { bytes.add(buf[i]); i += 1 }
        let text = String.fromUtf8(bytes.toArray())
        if (nativeWebSocketTestContains(text, "\r\n\r\n")) { return text }
    }
    throw Exception("native WebSocket upgrade response head exceeds 8192 bytes")
}

func maskedNativeWebSocketTextFrame(text: String): Array<UInt8> {
    let payload = text.toArray()
    let mask = [UInt8(0x37), UInt8(0xFA), UInt8(0x21), UInt8(0x3D)]
    let out = Array<UInt8>(payload.size + 6, repeat: 0)
    out[0] = UInt8(0x81)
    out[1] = UInt8(0x80 | payload.size)
    var i: Int64 = 0
    while (i < 4) { out[i + 2] = mask[i]; i += 1 }
    i = 0
    while (i < payload.size) {
        out[i + 6] = payload[i] ^ mask[i % 4]
        i += 1
    }
    out
}

func readNativeWebSocketServerFrame(socket: TcpSocket): NativeWebSocketTestFrame {
    let head = readNativeWebSocketTestExact(socket, 2)
    let opcode = Int64(head[0]) & 0x0F
    var size = Int64(head[1]) & 0x7F
    if (size == 126) {
        let ext = readNativeWebSocketTestExact(socket, 2)
        size = (Int64(ext[0]) << 8) | Int64(ext[1])
    }
    NativeWebSocketTestFrame(opcode, readNativeWebSocketTestExact(socket, size))
}

func readNativeWebSocketTestExact(socket: TcpSocket, size: Int64): Array<UInt8> {
    let out = Array<UInt8>(size, repeat: 0)
    var offset: Int64 = 0
    while (offset < size) {
        let buf = Array<UInt8>(size - offset, repeat: 0)
        let n = socket.read(buf)
        if (n <= 0) { throw Exception("native WebSocket fixture peer closed during frame read") }
        var i: Int64 = 0
        while (i < n) { out[offset + i] = buf[i]; i += 1 }
        offset += n
    }
    out
}

func nativeWebSocketTestContains(text: String, target: String): Bool {
    let chars = text.toRuneArray()
    let pattern = target.toRuneArray()
    if (pattern.size == 0) { return true }
    if (chars.size < pattern.size) { return false }
    var i: Int64 = 0
    while (i <= chars.size - pattern.size) {
        var matched = true
        var j: Int64 = 0
        while (j < pattern.size) {
            if (chars[i + j] != pattern[j]) { matched = false; break }
            j += 1
        }
        if (matched) { return true }
        i += 1
    }
    false
}

func chooseNativeWebSocketPort(offset: Int64): UInt16 {
    let nowMs = DateTime.now().toUnixTimeStamp().toMilliseconds()
    UInt16(44000 + ((nowMs + offset) % 9000))
}
