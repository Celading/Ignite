package ignite.native_h2

import std.net.TcpSocket

/// Duplex byte transport required by the native H2 connection runtime.
///
/// Connection ownership remains with the caller. The timeout accessors let
/// the runtime poll handler completion without taking over the caller's final
/// timeout policy.
public interface NativeH2DuplexTransport {
    func read(outBuf: Array<UInt8>): Int64
    func write(data: Array<UInt8>): Unit
    func currentReadTimeout(): ?Duration
    func updateReadTimeout(value: ?Duration): Unit
}

public class NativeH2TcpTransport <: NativeH2DuplexTransport {
    let socket: TcpSocket

    public init(socket: TcpSocket) {
        this.socket = socket
    }

    public override func read(outBuf: Array<UInt8>): Int64 {
        socket.read(outBuf)
    }

    public override func write(data: Array<UInt8>): Unit {
        socket.write(data)
    }

    public override func currentReadTimeout(): ?Duration {
        socket.readTimeout
    }

    public override func updateReadTimeout(value: ?Duration): Unit {
        socket.readTimeout = value
    }
}
