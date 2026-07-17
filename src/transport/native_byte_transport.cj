package ignite.transport

import std.net.TcpSocket

/// Minimal byte transport shared by native HTTP clients.
///
/// Protocol code owns framing while the caller retains connect, timeout, and
/// close policy through the concrete transport.
public interface NativeByteTransport {
    func read(outBuf: Array<Byte>): Int64
    func write(data: Array<Byte>): Unit
    func close(): Unit
    func isClosed(): Bool
}

public class TcpSocketByteTransport <: NativeByteTransport {
    public let socket: TcpSocket

    public init(socket: TcpSocket) {
        this.socket = socket
    }

    public override func read(outBuf: Array<Byte>): Int64 {
        socket.read(outBuf)
    }

    public override func write(data: Array<Byte>): Unit {
        socket.write(data)
    }

    public override func close(): Unit {
        socket.close()
    }

    public override func isClosed(): Bool {
        socket.isClosed()
    }
}
