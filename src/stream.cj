package ignite

import stdx.net.http.{HttpContext, HttpResponseWriter}

public class ResponseWriter {
    let _writer: HttpResponseWriter

    public init(httpCtx: HttpContext) {
        if (shouldEmitChunkedTransferHeader(httpCtx.request.version.toString())) {
            httpCtx.responseBuilder.header("transfer-encoding", "chunked")
        }
        _writer = HttpResponseWriter(httpCtx)
    }

    public func write(data: Array<UInt8>): Unit {
        _writer.write(data)
    }

    public func writeString(data: String): Unit {
        _writer.write(data.toArray())
    }
}

public class SseWriter {
    let _httpCtx: HttpContext
    var _writer: ?HttpResponseWriter = None

    public init(httpCtx: HttpContext) {
        _httpCtx = httpCtx
        httpCtx.responseBuilder
            .header("content-type", "text/event-stream")
            .header("cache-control", "no-cache")
        let protocol = httpCtx.request.version.toString()
        if (shouldEmitConnectionKeepAliveHeader(protocol)) {
            httpCtx.responseBuilder.header("connection", "keep-alive")
        }
        if (shouldEmitChunkedTransferHeader(protocol)) {
            httpCtx.responseBuilder.header("transfer-encoding", "chunked")
        }
    }

    func ensureWriter(): HttpResponseWriter {
        match (_writer) {
            case Some(w) => w
            case None =>
                let w = HttpResponseWriter(_httpCtx)
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
    containsText(text, "http/2") || containsText(text, "http2")
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
