package ignite

import stdx.net.http.{HttpContext, HttpResponseWriter}

public class ResponseWriter {
    let _writer: HttpResponseWriter

    public init(httpCtx: HttpContext) {
        httpCtx.responseBuilder.header("transfer-encoding", "chunked")
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
            .header("connection", "keep-alive")
            .header("transfer-encoding", "chunked")
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
