package ignite

public class ResponseWriter {
    let _writer: ResponseTransportWriter
    var _closed: Bool = false

    public init(currentRequestCarrier: CurrentRequestCarrier) {
        if (shouldEmitChunkedTransferHeader(currentRequestCarrier.requestVersionString())) {
            currentRequestCarrier.setResponseHeader("transfer-encoding", "chunked")
        }
        _writer = openResponseTransportWriter(currentRequestCarrier)
    }

    init(writer: ResponseTransportWriter) {
        _writer = writer
    }

    public func write(data: Array<UInt8>): Unit {
        ensureResponseTransportWriterOpen(_closed)
        _writer.write(data)
    }

    public func writeString(data: String): Unit {
        ensureResponseTransportWriterOpen(_closed)
        _writer.write(data.toArray())
    }

    public func flush(): Unit {
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
}

public class SseWriter {
    let _currentRequestCarrier: CurrentRequestCarrier
    var _writer: ?ResponseTransportWriter = None
    let _enabled: Bool
    var _closed: Bool = false

    public init(currentRequestCarrier: CurrentRequestCarrier, enabled!: Bool = true) {
        _currentRequestCarrier = currentRequestCarrier
        _enabled = enabled
        if (!enabled) {
            return
        }
        currentRequestCarrier.setResponseStatus(200)
        currentRequestCarrier.setResponseHeader("content-type", "text/event-stream")
        currentRequestCarrier.setResponseHeader("cache-control", "no-cache")
        currentRequestCarrier.setResponseHeader("x-accel-buffering", "no")
        let protocol = currentRequestCarrier.requestVersionString()
        if (shouldEmitConnectionKeepAliveHeader(protocol)) {
            currentRequestCarrier.setResponseHeader("connection", "keep-alive")
        }
        if (shouldEmitChunkedTransferHeader(protocol)) {
            currentRequestCarrier.setResponseHeader("transfer-encoding", "chunked")
        }
    }

    func ensureWriter(): ResponseTransportWriter {
        ensureResponseTransportWriterOpen(_closed)
        if (!_enabled) {
            return openDiscardingResponseTransportWriter()
        }
        match (_writer) {
            case Some(w) => w
            case None =>
                let w = openResponseTransportWriter(_currentRequestCarrier)
                _writer = w
                w
        }
    }

    public func sendEvent(data: String, event!: String = "", id!: String = ""): Unit {
        let w = ensureWriter()
        var msg = ""
        if (id.size > 0) {
            msg += "id: ${id}\n"
        }
        if (event.size > 0) {
            msg += "event: ${event}\n"
        }
        let lines = data.split("\n")
        for (line in lines) {
            msg += "data: ${line}\n"
        }
        msg += "\n"
        w.write(msg.toArray())
    }

    public func sendComment(comment: String): Unit {
        let w = ensureWriter()
        w.write(": ${comment}\n\n".toArray())
    }

    public func sendRetry(millis: Int64): Unit {
        let w = ensureWriter()
        w.write("retry: ${millis}\n\n".toArray())
    }

    /// Minimal heartbeat helper for SSE keepalive comments.
    /// Delivery and flush strength follow the selected response transport.
    public func sendHeartbeat(comment!: String = "ping"): Unit {
        sendComment(comment)
    }

    public func flush(): Unit {
        ensureResponseTransportWriterOpen(_closed)
        if (let Some(writer) <- _writer) {
            flushResponseTransportWriter(writer)
        }
    }

    public func close(): Unit {
        if (_closed) {
            return
        }
        _closed = true
        if (let Some(writer) <- _writer) {
            finalizeResponseTransportWriter(writer)
        }
    }
}

func shouldEmitChunkedTransferHeader(protocol: String): Bool {
    return !isHttp2Protocol(protocol)
}

func shouldEmitConnectionKeepAliveHeader(protocol: String): Bool {
    return !isHttp2Protocol(protocol)
}

func isHttp2Protocol(protocol: String): Bool {
    let text = protocol.trimAscii().toAsciiLower()
    if (text.size == 0) {
        return false
    }
    if (text == "h2" || text == "h2c") {
        return true
    }
    let containsSlashForm = containsText(text, "http/2")
    if (containsSlashForm) {
        return true
    }
    containsText(text, "http2")
}

func containsText(text: String, pattern: String): Bool {
    let a = text.toRuneArray()
    let b = pattern.toRuneArray()
    if (b.size == 0) {
        return true
    }
    if (a.size < b.size) {
        return false
    }
    var i: Int64 = 0
    while (i <= a.size - b.size) {
        var ok = true
        var j: Int64 = 0
        while (j < b.size) {
            if (a[i + j] != b[j]) {
                ok = false
                break
            }
            j += 1
        }
        if (ok) {
            return true
        }
        i += 1
    }
    false
}
