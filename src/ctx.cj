package ignite

import std.collection.{ArrayList, HashMap}
import std.io.{InputStream}
import std.fs.{File, OpenMode, Path}
import std.unicode.*
import stdx.net.http.{HttpContext, WebSocket}

public class Ctx {
    let _httpCtx: HttpContext
    let _app: App
    var _params: HashMap<String, String> = HashMap<String, String>()
    var _locals: HashMap<String, String> = HashMap<String, String>()
    var _route: ?Route = None
    var _handlers: ArrayList<Handler> = ArrayList<Handler>()
    var _handlerIndex: Int64 = -1
    var _responded: Bool = false

    public init(httpCtx: HttpContext, app: App) {
        this._httpCtx = httpCtx
        this._app = app
    }

    // ── Request accessors ──

    public prop method: String {
        get() { _httpCtx.request.method }
    }

    public prop path: String {
        get() { _httpCtx.request.url.path }
    }

    public prop originalUrl: String {
        get() { _httpCtx.request.url.toString() }
    }

    public prop protocol: String {
        get() { _httpCtx.request.version.toString() }
    }

    public prop ip: String {
        get() { _httpCtx.request.remoteAddr }
    }

    public func params(key: String): String {
        _params.get(key) ?? ""
    }

    public func paramsOpt(key: String): ?String {
        _params.get(key)
    }

     public func query(key: String): ?String {
        _httpCtx.request.url.queryForm.get(key)
    }

    public func queryDefault(key: String, defaultVal: String): String {
        query(key) ?? defaultVal
    }

    public func header(key: String): ?String {
        _httpCtx.request.headers.getFirst(key)
    }

    public func requestBody(): InputStream {
        _httpCtx.request.body
    }

    public func bodyString(): String {
        let stream = _httpCtx.request.body
        let buf = ArrayList<UInt8>()
        let tmp = Array<UInt8>(4096, repeat: 0)
        while (true) {
            let n = stream.read(tmp)
            if (n <= 0) {
                break
            }
            for (i in 0..n) {
                buf.add(tmp[i])
            }
        }
        String.fromUtf8(buf.toArray())
    }

    public func cookies(name: String): ?String {
        let cookieHeaderOpt = header("cookie")
        if (let Some(cookieHeader) <- cookieHeaderOpt) {
            let parts = cookieHeader.split(";")
            for (part in parts) {
                let trimmed = part.trimAscii()
                let kv = trimmed.split("=", 2)
                if (kv.size == 2) {
                    let cName = kv[0].trimAscii()
                    let cVal = kv[1].trimAscii()
                    if (cName == name) {
                        return cVal
                    }
                }
            }
        }
        None
    }

    // ── Response methods ──

    public func status(code: UInt16): Ctx {
        _httpCtx.responseBuilder.status(code)
        this
    }

    public func setHeader(key: String, value: String): Ctx {
        _httpCtx.responseBuilder.header(key, value)
        this
    }

    public func json(body: String): Ctx {
        _httpCtx.responseBuilder
            .header("content-type", "application/json; charset=utf-8")
            .body(body)
        _responded = true
        this
    }

    public func sendString(body: String): Ctx {
        _httpCtx.responseBuilder
            .header("content-type", "text/plain; charset=utf-8")
            .body(body)
        _responded = true
        this
    }

    public func html(body: String): Ctx {
        _httpCtx.responseBuilder
            .header("content-type", "text/html; charset=utf-8")
            .body(body)
        _responded = true
        this
    }

    public func send(data: Array<UInt8>): Ctx {
        _httpCtx.responseBuilder.body(data)
        _responded = true
        this
    }

    public func sendStatus(code: UInt16): Ctx {
        _httpCtx.responseBuilder.status(code).body(statusMessage(code))
        _responded = true
        this
    }

    public func redirect(url: String, code!: UInt16 = 302): Ctx {
        _httpCtx.responseBuilder
            .status(code)
            .header("location", url)
            .body("")
        _responded = true
        this
    }

    public func setCookie(name: String, value: String, maxAge!: Int64 = 0, path!: String = "/",
                          domain!: String = "", httpOnly!: Bool = false, secure!: Bool = false): Ctx {
        var cookieStr = "${name}=${value}"
        if (maxAge > 0) {
            cookieStr += "; Max-Age=${maxAge}"
        }
        cookieStr += "; Path=${path}"
        if (domain.size > 0) {
            cookieStr += "; Domain=${domain}"
        }
        if (httpOnly) {
            cookieStr += "; HttpOnly"
        }
        if (secure) {
            cookieStr += "; Secure"
        }
        _httpCtx.responseBuilder.header("set-cookie", cookieStr)
        this
    }

    public func noContent(): Ctx {
        _httpCtx.responseBuilder.status(204)
        _responded = true
        this
    }

    // ── File serving ──

    public func sendFile(filePath: String): Ctx {
        try {
            let file = File(filePath, OpenMode.Read)
            let buf = ArrayList<UInt8>()
            let tmp = Array<UInt8>(8192, repeat: 0)
            while (true) {
                let n = file.read(tmp)
                if (n <= 0) { break }
                for (i in 0..n) {
                    buf.add(tmp[i])
                }
            }
            file.close()
            let contentType = detectMimeType(filePath)
            _httpCtx.responseBuilder
                .header("content-type", contentType)
                .body(buf.toArray())
        } catch (_: Exception) {
            _httpCtx.responseBuilder
                .status(404)
                .header("content-type", "text/plain; charset=utf-8")
                .body("File not found: ${filePath}")
        }
        _responded = true
        this
    }

    public func formValue(key: String): ?String {
        query(key)
    }

    // ── Streaming ──

    public func writer(): ResponseWriter {
        _responded = true
        ResponseWriter(_httpCtx)
    }

    public func sse(): SseWriter {
        _responded = true
        SseWriter(_httpCtx)
    }

    // ── WebSocket ──

    public func upgradeWebSocket(): WsConn {
        _responded = true
        let ws = WebSocket.upgradeFromServer(_httpCtx)
        WsConn(ws)
    }

    // ── Internal HttpContext access ──

    public func httpContext(): HttpContext {
        _httpCtx
    }

    // ── Flow control ──

    public func next(): Unit {
        _handlerIndex += 1
        if (_handlerIndex < _handlers.size) {
            let handler = _handlers[_handlerIndex]
            handler(this)
        }
    }

    // ── Locals (per-request storage) ──

    public func getLocal(key: String): ?String {
        _locals.get(key)
    }

    public func setLocal(key: String, value: String): Unit {
        _locals.add(key, value)
    }

    // ── App reference ──

    public func app(): App {
        _app
    }

    public func route(): ?Route {
        _route
    }

    // ── Internal setup ──

    public func setParams(params: HashMap<String, String>): Unit {
        this._params = params
    }

    public func setHandlers(handlers: ArrayList<Handler>): Unit {
        this._handlers = handlers
        this._handlerIndex = -1
    }

    public func setRoute(route: Route): Unit {
        this._route = route
    }

    func statusMessage(code: UInt16): String {
        match (code) {
            case 200 => "OK"
            case 201 => "Created"
            case 204 => "No Content"
            case 301 => "Moved Permanently"
            case 302 => "Found"
            case 304 => "Not Modified"
            case 400 => "Bad Request"
            case 401 => "Unauthorized"
            case 403 => "Forbidden"
            case 404 => "Not Found"
            case 405 => "Method Not Allowed"
            case 409 => "Conflict"
            case 413 => "Payload Too Large"
            case 422 => "Unprocessable Entity"
            case 429 => "Too Many Requests"
            case 500 => "Internal Server Error"
            case 502 => "Bad Gateway"
            case 503 => "Service Unavailable"
            case _ => "Unknown"
        }
    }
}

func detectMimeType(path: String): String {
    let ext = extractExtension(path.toLower())
    match (ext) {
        case ".html" | ".htm" => "text/html; charset=utf-8"
        case ".css" => "text/css; charset=utf-8"
        case ".js" | ".mjs" => "application/javascript; charset=utf-8"
        case ".json" => "application/json; charset=utf-8"
        case ".png" => "image/png"
        case ".jpg" | ".jpeg" => "image/jpeg"
        case ".gif" => "image/gif"
        case ".svg" => "image/svg+xml"
        case ".ico" => "image/x-icon"
        case ".webp" => "image/webp"
        case ".txt" => "text/plain; charset=utf-8"
        case ".xml" => "application/xml"
        case ".pdf" => "application/pdf"
        case ".zip" => "application/zip"
        case ".gz" => "application/gzip"
        case ".woff" => "font/woff"
        case ".woff2" => "font/woff2"
        case ".ttf" => "font/ttf"
        case ".mp4" => "video/mp4"
        case ".webm" => "video/webm"
        case ".mp3" => "audio/mpeg"
        case ".wav" => "audio/wav"
        case _ => "application/octet-stream"
    }
}

func extractExtension(path: String): String {
    let runes = path.toRuneArray()
    var i = runes.size - 1
    while (i >= 0) {
        if (runes[i] == r'.') {
            var ext = ""
            for (j in i..runes.size) {
                ext += runes[j].toString()
            }
            return ext
        }
        if (runes[i] == r'/' || runes[i] == r'\\') {
            return ""
        }
        i -= 1
    }
    ""
}
