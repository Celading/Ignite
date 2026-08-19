package ignite

import std.io.OutputStream
import stdx.net.http.{HttpContext, HttpResponseWriter}

/// Ignite-owned writer seam for response streaming surfaces.
///
/// The current backend is still stdx-backed, but callers no longer need to
/// construct `HttpResponseWriter` directly. That keeps the replacement point
/// narrow for future self-owned runtime work.
public interface ResponseTransportWriter {
    func write(data: Array<UInt8>): Unit
}

/// Optional lifecycle capability for response writers.
///
/// `close()` finalizes this response-writing surface only. It must not close
/// the physical connection owned by the server or protocol runtime.
public interface ResponseTransportLifecycle {
    func flush(): Unit
    func close(): Unit
}

public type ResponseTransportWriteSink = (Array<UInt8>) -> Unit

public type ResponseTransportFlushSink = () -> Unit

public type ResponseTransportCloseSink = () -> Unit

type ResponseTransportWriteTransform = (Array<UInt8>) -> Array<Array<UInt8>>

class StdxResponseTransportWriter <: ResponseTransportWriter & ResponseTransportLifecycle {
    let _writer: HttpResponseWriter
    var _closed: Bool = false

    public init(httpCtx: HttpContext) {
        _writer = HttpResponseWriter(httpCtx)
    }

    public override func write(data: Array<UInt8>): Unit {
        ensureResponseTransportWriterOpen(_closed)
        _writer.write(data)
    }

    public override func flush(): Unit {
        ensureResponseTransportWriterOpen(_closed)
        // stdx HttpResponseWriter exposes write-through behavior but no
        // stronger public flush primitive.
    }

    public override func close(): Unit {
        _closed = true
    }
}

class TransformingResponseTransportWriter <: ResponseTransportWriter & ResponseTransportLifecycle {
    let _downstream: ResponseTransportWriter
    let _transform: ResponseTransportWriteTransform
    var _closed: Bool = false

    init(
        downstream: ResponseTransportWriter,
        transform: ResponseTransportWriteTransform
    ) {
        _downstream = downstream
        _transform = transform
    }

    public override func write(data: Array<UInt8>): Unit {
        ensureResponseTransportWriterOpen(_closed)
        if (data.size == 0) {
            return
        }
        let transformed = _transform(cloneResponseTransportBytes(data))
        for (chunk in transformed) {
            if (chunk.size > 0) {
                _downstream.write(chunk)
            }
        }
    }

    public override func flush(): Unit {
        ensureResponseTransportWriterOpen(_closed)
        flushResponseTransportWriter(_downstream)
    }

    public override func close(): Unit {
        if (_closed) {
            return
        }
        _closed = true
        closeResponseTransportWriter(_downstream)
    }
}

class SinkBackedResponseTransportWriter <: ResponseTransportWriter & ResponseTransportLifecycle {
    let _sink: ResponseTransportWriteSink
    let _flushSink: ?ResponseTransportFlushSink
    let _closeSink: ?ResponseTransportCloseSink
    var _closed: Bool = false

    init(
        sink: ResponseTransportWriteSink,
        flushSink!: ?ResponseTransportFlushSink = None,
        closeSink!: ?ResponseTransportCloseSink = None
    ) {
        _sink = sink
        _flushSink = flushSink
        _closeSink = closeSink
    }

    public override func write(data: Array<UInt8>): Unit {
        ensureResponseTransportWriterOpen(_closed)
        if (data.size == 0) {
            return
        }
        _sink(cloneResponseTransportBytes(data))
    }

    public override func flush(): Unit {
        ensureResponseTransportWriterOpen(_closed)
        if (let Some(flushSink) <- _flushSink) {
            flushSink()
        }
    }

    public override func close(): Unit {
        if (_closed) {
            return
        }
        _closed = true
        if (let Some(closeSink) <- _closeSink) {
            closeSink()
        }
    }
}

class DiscardingResponseTransportWriter <: ResponseTransportWriter & ResponseTransportLifecycle {
    var _closed: Bool = false

    public override func write(data: Array<UInt8>): Unit {
        ensureResponseTransportWriterOpen(_closed)
        let _ = data
        ()
    }

    public override func flush(): Unit {
        ensureResponseTransportWriterOpen(_closed)
    }

    public override func close(): Unit {
        _closed = true
    }
}

func openResponseTransportWriter(currentRequestCarrier: CurrentRequestCarrier): ResponseTransportWriter {
    currentRequestCarrier.openResponseTransportWriterRaw()
}

func openDiscardingResponseTransportWriter(): ResponseTransportWriter {
    DiscardingResponseTransportWriter()
}

/// Opens a transport writer that forwards each write into an arbitrary sink.
///
/// This keeps product-local sinks such as `TcpSocket.write(...)` behind the
/// same `ResponseTransportWriter` seam without re-exposing `HttpResponseWriter`.
public func openSinkBackedResponseTransportWriter(
    sink: ResponseTransportWriteSink
): ResponseTransportWriter {
    SinkBackedResponseTransportWriter(sink)
}

/// Opens a sink-backed writer with explicit response-stream lifecycle hooks.
///
/// The close hook finalizes the response sink only; it must not take ownership
/// of the physical connection unless the caller's sink contract says so.
public func openLifecycleSinkBackedResponseTransportWriter(
    sink: ResponseTransportWriteSink,
    flushSink: ResponseTransportFlushSink,
    closeSink: ResponseTransportCloseSink
): ResponseTransportWriter {
    SinkBackedResponseTransportWriter(
        sink,
        flushSink: Some(flushSink),
        closeSink: Some(closeSink)
    )
}

/// Flushes a writer when it exposes Ignite's lifecycle capability.
///
/// Existing third-party `ResponseTransportWriter` implementations remain
/// compatible and retain write-through behavior when they do not implement
/// the optional lifecycle surface.
public func flushResponseTransportWriter(writer: ResponseTransportWriter): Unit {
    match (writer) {
        case lifecycle: ResponseTransportLifecycle => lifecycle.flush()
        case _ => ()
    }
}

/// Finalizes a response-writing surface without closing its connection.
public func closeResponseTransportWriter(writer: ResponseTransportWriter): Unit {
    match (writer) {
        case lifecycle: ResponseTransportLifecycle => lifecycle.close()
        case _ => ()
    }
}

func finalizeResponseTransportWriter(writer: ResponseTransportWriter): Unit {
    try {
        flushResponseTransportWriter(writer)
    } finally {
        closeResponseTransportWriter(writer)
    }
}

func wrapResponseTransportWriter(
    writer: ResponseTransportWriter,
    transform: ResponseTransportWriteTransform
): ResponseTransportWriter {
    TransformingResponseTransportWriter(writer, transform)
}

/// Presents a response transport writer as an `std.io.OutputStream`.
public class ResponseTransportOutputStream <: OutputStream & Resource {
    let _writer: ResponseTransportWriter
    var _closed: Bool = false

    public init(writer: ResponseTransportWriter) {
        _writer = writer
    }

    public override func write(data: Array<Byte>): Unit {
        ensureResponseTransportWriterOpen(_closed)
        let out = Array<UInt8>(data.size, repeat: 0)
        var i: Int64 = 0
        while (i < data.size) {
            out[i] = UInt8(data[i])
            i += 1
        }
        _writer.write(out)
    }

    public override func flush(): Unit {
        ensureResponseTransportWriterOpen(_closed)
        flushResponseTransportWriter(_writer)
    }

    public func close(): Unit {
        if (_closed) {
            return
        }
        _closed = true
        finalizeResponseTransportWriter(_writer)
    }

    public func isClosed(): Bool {
        _closed
    }
}

func ensureResponseTransportWriterOpen(closed: Bool): Unit {
    if (closed) {
        throw Exception("response transport writer is closed")
    }
}

func cloneResponseTransportBytes(input: Array<UInt8>): Array<UInt8> {
    let out = Array<UInt8>(input.size, repeat: 0)
    var i: Int64 = 0
    while (i < input.size) {
        out[i] = input[i]
        i += 1
    }
    out
}
