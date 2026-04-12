package ignite

import std.collection.{ArrayList, HashMap}
import std.io.{InputStream}
import std.fs.{exists, File, FileInfo, OpenMode}
import std.unicode.*
import ignite.security
import stdx.net.http.{HttpContext, HttpResponseWriter, WebSocket}
import stdx.encoding.json.JsonValue
import stdx.encoding.json.stream.{
    JsonSerializable as StdxJsonSerializable
}

public class Ctx {
    let _httpCtx: HttpContext
    let _app: App
    var _params: HashMap<String, String> = HashMap<String, String>()
    var _locals: HashMap<String, String> = HashMap<String, String>()
    var _route: ?Route = None
    var _handlers: ArrayList<Handler> = ArrayList<Handler>()
    var _handlerIndex: Int64 = -1
    var _responded: Bool = false
    var _statusCode: UInt16 = 200
    var _bodyBytesCache: ?Array<UInt8> = None
    var _multipartForm: ?MultipartForm = None
    var _responseBody: ?String = None
    var _pathOverride: ?String = None

    public init(httpCtx: HttpContext, app: App) {
        this._httpCtx = httpCtx
        this._app = app
    }

    // ── Request accessors ──

    public prop method: String {
        get() { _httpCtx.request.method }
    }

    public prop path: String {
        get() {
            match (_pathOverride) {
                case Some(path) => path
                case None => _httpCtx.request.url.path
            }
        }
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
        if (let urlQueryVal <- _httpCtx.request.url.queryForm.get(key)) {
            return urlQueryVal
        }
        if (let formVal <- _httpCtx.request.form.get(key)) {
            return formVal
        }
        None
    }

    public func queryDefault(key: String, defaultVal: String): String {
        query(key) ?? defaultVal
    }

    public func queryFromUrl(key: String): ?String {
        _httpCtx.request.url.queryForm.get(key)
    }

    public func queryFromForm(key: String): ?String {
        _httpCtx.request.form.get(key)
    }

    public func header(key: String): ?String {
        _httpCtx.request.headers.getFirst(key)
    }

    public func requestBody(): InputStream {
        _httpCtx.request.body
    }

    public func saveBodyToFile(destPath: String): Int64 {
        if (let Some(cached) <- _bodyBytesCache) {
            writeBytesToFile(destPath, cached)
            return cached.size
        }
        streamRequestBodyToFile(_httpCtx.request.body, destPath)
    }

    public func cachedBodyBytes(): ?Array<UInt8> {
        _bodyBytesCache
    }

    public func bodyBytes(): Array<UInt8> {
        if (let Some(cached) <- _bodyBytesCache) {
            return cached
        }
        let stream = _httpCtx.request.body
        let buf = ArrayList<UInt8>()
        let tmp = Array<UInt8>(4096, repeat: 0)
        while (true) {
            let n = stream.read(tmp)
            if (n <= 0) { break }
            for (i in 0..n) {
                buf.add(tmp[i])
            }
        }
        let bytes = buf.toArray()
        _bodyBytesCache = bytes
        bytes
    }

    public func bodyString(): String {
        String.fromUtf8(bodyBytes())
    }

    public func cookies(name: String): ?String {
        match (_locals.get("__ignite_cookie_dec_${name}")) {
            case Some(v) => return Some(v)
            case None => ()
        }
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

    // ── Form data (urlencoded + multipart) ──

    public func formValue(key: String): ?String {
        let queryVal = query(key)
        if (let Some(v) <- queryVal) {
            return v
        }
        let ct = header("content-type") ?? ""
        if (containsStr(ct.toLower(), "multipart")) {
            return multipartForm().value(key)
        }
        None
    }

    public func multipartForm(): MultipartForm {
        if (let Some(form) <- _multipartForm) {
            return form
        }
        let contentType = header("content-type") ?? ""
        let bytes = bodyBytes()
        let form = parseMultipartForm(bytes, contentType)
        _multipartForm = form
        form
    }

    public func formFile(name: String): ?FormFile {
        multipartForm().file(name)
    }

    public func formFiles(name: String): ArrayList<FormFile> {
        multipartForm().files(name)
    }

    public func saveFile(file: FormFile, destPath: String): Unit {
        saveFormFile(file, destPath)
    }

    // ── Response methods ──

    public func status(code: UInt16): Ctx {
        _httpCtx.responseBuilder.status(code)
        _statusCode = code
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
        _responseBody = body
        this
    }

    public func sendString(body: String): Ctx {
        _httpCtx.responseBuilder
            .header("content-type", "text/plain; charset=utf-8")
            .body(body)
        _responded = true
        _responseBody = body
        this
    }

    public func html(body: String): Ctx {
        _httpCtx.responseBuilder
            .header("content-type", "text/html; charset=utf-8")
            .body(body)
        _responded = true
        _responseBody = body
        this
    }

    public func send(data: Array<UInt8>): Ctx {
        _httpCtx.responseBuilder.body(data)
        _responded = true
        this
    }

    public func sendStatus(code: UInt16): Ctx {
        let msg = statusMessage(code)
        _httpCtx.responseBuilder.status(code).body(msg)
        _statusCode = code
        _responded = true
        _responseBody = msg
        this
    }

    public func redirect(url: String, code!: UInt16 = 302): Ctx {
        _httpCtx.responseBuilder
            .status(code)
            .header("location", url)
            .body("")
        _statusCode = code
        _responded = true
        this
    }

    public func setCookie(name: String, value: String, maxAge!: Int64 = 0, path!: String = "/",
                          domain!: String = "", httpOnly!: Bool = false, secure!: Bool = false,
                          sameSite!: String = ""): Ctx {
        let cookieValue = tryEncryptCookieValue(name, value)
        var cookieStr = "${name}=${cookieValue}"
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
        let normalizedSameSite = sameSite.trimAscii()
        if (normalizedSameSite.size > 0) {
            cookieStr += "; SameSite=${normalizedSameSite}"
        }
        _httpCtx.responseBuilder.header("set-cookie", cookieStr)
        this
    }

    public func noContent(): Ctx {
        _httpCtx.responseBuilder.status(204)
        _statusCode = 204
        _responded = true
        this
    }

    // ── JSON serialization ──

    public func jsonSerialize<T>(obj: T): Ctx where T <: StdxJsonSerializable {
        let jsonStr = serializeJson<T>(obj)
        json(jsonStr)
    }

    public func jsonEncode(obj: JsonEncodable): Ctx {
        let jsonStr = if (let Some(encoder) <- _app.config.jsonEncoder) {
            encoder(obj)
        } else {
            obj.toJsonString()
        }
        json(jsonStr)
    }

    /// 解析请求 JSON；失败时返回 400，错误体：
    /// {"error":"bad_request","reason":"invalid_json","message":"..."}
    /// decoder 或 validate 抛错时同样返回 400（reason 分别为 invalid_payload / validation_failed）。
    public func bindJsonOr400<T>(
        decoder: (JsonValue) -> T,
        validate!: ?(T) -> ?String = None
    ): ?T {
        let parsed = parseJsonBody()
        if (let None <- parsed) {
            return None
        }
        if (let Some(jsonValue) <- parsed) {
            let decoded = tryDecodeJson<T>(jsonValue, decoder)
            if (let None <- decoded) {
                return None
            }
            if (let Some(value) <- decoded) {
                if (let Some(validateFn) <- validate) {
                    let validation = tryValidateJson<T>(value, validateFn)
                    if (let Some(msg) <- validation) {
                        jsonBadRequest("validation_failed", msg)
                        return None
                    }
                }
                return Some(value)
            }
        }
        None
    }

    // ── File serving ──

    public func sendFile(filePath: String): Ctx {
        if (let Some((resolvedPath, totalSize)) <- resolveExistingFile(filePath)) {
            let contentType = detectMimeType(resolvedPath)
            _httpCtx.responseBuilder
                .header("content-type", contentType)
                .header("content-length", "${totalSize}")
                .header("accept-ranges", "bytes")
            _statusCode = 200
            if (!isHeadRequest(method)) {
                if (totalSize == 0) {
                    _httpCtx.responseBuilder.body(Array<UInt8>(0, repeat: 0))
                } else {
                    streamWholeFile(_httpCtx, resolvedPath)
                }
            }
        } else {
            _httpCtx.responseBuilder
                .status(404)
                .header("content-type", "text/plain; charset=utf-8")
                .body("File not found: ${filePath}")
            _statusCode = 404
        }
        _responded = true
        this
    }

    public func download(filePath: String, filename!: String = ""): Ctx {
        let displayName = if (filename.size > 0) {
            filename
        } else {
            extractFileName(filePath)
        }
        _httpCtx.responseBuilder.header("content-disposition", "attachment; filename=\"${displayName}\"")
        sendFile(filePath)
    }

    public func sendFileRange(filePath: String): Ctx {
        if (let Some((resolvedPath, totalSize)) <- resolveExistingFile(filePath)) {
            let contentType = detectMimeType(resolvedPath)

            let rangeHeader = header("range")
            if (let Some(rangeVal) <- rangeHeader) {
                let parsed = parseRangeHeader(rangeVal, totalSize)
                if (let Some((start, end)) <- parsed) {
                    let length = end - start + 1
                    _httpCtx.responseBuilder
                        .status(206)
                        .header("content-type", contentType)
                        .header("content-range", "bytes ${start}-${end}/${totalSize}")
                        .header("content-length", "${length}")
                        .header("accept-ranges", "bytes")
                    _statusCode = 206
                    if (!isHeadRequest(method)) {
                        if (length == 0) {
                            _httpCtx.responseBuilder.body(Array<UInt8>(0, repeat: 0))
                        } else {
                            streamFileSegment(_httpCtx, resolvedPath, start, length)
                        }
                    }
                } else {
                    _httpCtx.responseBuilder
                        .status(416)
                        .header("content-range", "bytes */${totalSize}")
                    if (!isHeadRequest(method)) {
                        _httpCtx.responseBuilder.body("Range Not Satisfiable")
                    }
                    _statusCode = 416
                }
            } else {
                _httpCtx.responseBuilder
                    .header("content-type", contentType)
                    .header("content-length", "${totalSize}")
                    .header("accept-ranges", "bytes")
                _statusCode = 200
                if (!isHeadRequest(method)) {
                    if (totalSize == 0) {
                        _httpCtx.responseBuilder.body(Array<UInt8>(0, repeat: 0))
                    } else {
                        streamWholeFile(_httpCtx, resolvedPath)
                    }
                }
            }
        } else {
            _httpCtx.responseBuilder
                .status(404)
                .header("content-type", "text/plain; charset=utf-8")
                .body("File not found: ${filePath}")
            _statusCode = 404
        }
        _responded = true
        this
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

    public prop responseBody: ?String {
        get() { _responseBody }
    }

    public prop responseStatus: UInt16 {
        get() { _statusCode }
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

    public func handlerIndex(): Int64 {
        _handlerIndex
    }

    public func setHandlerIndex(index: Int64): Unit {
        this._handlerIndex = index
    }

    public func setRoute(route: Route): Unit {
        this._route = route
    }

    public func overridePath(path: String): Unit {
        this._pathOverride = Some(path)
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

    func tryEncryptCookieValue(name: String, value: String): String {
        let enabled = _locals.get("__ignite_cookie_enc_enabled") ?? "0"
        if (enabled != "1") {
            return value
        }
        let exceptCsv = _locals.get("__ignite_cookie_enc_except") ?? ""
        if (cookieNameInCsv(name, exceptCsv)) {
            return value
        }
        let keyHex = _locals.get("__ignite_cookie_enc_key_hex") ?? ""
        let keyId = _locals.get("__ignite_cookie_enc_kid") ?? "k1"
        let alg = _locals.get("__ignite_cookie_enc_alg") ?? "AES-256-GCM"
        let providerText = _locals.get("__ignite_cookie_enc_provider") ?? "jinguiSSL"
        if (keyHex.size == 0) {
            return value
        }
        try {
            let key = security.hexToBytes(keyHex)
            let keyRing = HashMap<String, Array<UInt8>>()
            keyRing.add(keyId, key)
            let config = security.SecurityConfig(
                providerKind: parseSecurityProviderKind(providerText),
                activeKid: keyId,
                keyRing: keyRing,
                aeadAlgorithm: alg
            )
            security.sealCookieValueV1(config, value, cookieName: name)
        } catch (_: Exception) {
            value
        }
    }

    func parseSecurityProviderKind(raw: String): security.SecurityProviderKind {
        let v = raw.trimAscii().toAsciiLower()
        if (v == "stdx-fallback") {
            return security.SecurityProviderKind.StdxFallback
        }
        security.SecurityProviderKind.jinguiSSL
    }

    func cookieNameInCsv(name: String, csv: String): Bool {
        if (csv.trimAscii().size == 0) {
            return false
        }
        let parts = csv.split(",")
        for (part in parts) {
            if (part.trimAscii() == name) {
                return true
            }
        }
        false
    }

    func parseJsonBody(): ?JsonValue {
        let raw = bodyString()
        try {
            Some(JsonValue.fromStr(raw))
        } catch (_: Exception) {
            jsonBadRequest("invalid_json", "request body is not valid json")
            None
        }
    }

    func tryDecodeJson<T>(jsonValue: JsonValue, decoder: (JsonValue) -> T): ?T {
        try {
            Some(decoder(jsonValue))
        } catch (e: Exception) {
            let msg = if (e.message.trimAscii().size > 0) {
                "failed to decode payload: ${e.message}"
            } else {
                "failed to decode payload"
            }
            jsonBadRequest("invalid_payload", msg)
            None
        }
    }

    func tryValidateJson<T>(value: T, validateFn: (T) -> ?String): ?String {
        try {
            validateFn(value)
        } catch (e: Exception) {
            if (e.message.trimAscii().size > 0) {
                Some("validation exception: ${e.message}")
            } else {
                Some("validation exception")
            }
        }
    }

    func jsonBadRequest(reason: String, message: String): Unit {
        let payload = #"{"error":"bad_request","reason":""# + escapeJson(reason) + #"","message":""# + escapeJson(message) + #""}"#
        _ = status(400).json(payload)
    }

    func escapeJson(input: String): String {
        escapeJsonText(input)
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

let FILE_STREAM_BUFFER_SIZE: Int64 = 64 * 1024

func resolveExistingFile(rawPath: String): ?(String, Int64) {
    let path = rawPath.trimAscii()
    if (path.size == 0) {
        return None
    }

    let candidates = ArrayList<String>()
    candidates.add(path)
    if (startsWithSlash(path)) {
        candidates.add("." + path)
    }

    for (candidate in candidates) {
        if (!exists(candidate)) {
            continue
        }
        try {
            let info = FileInfo(candidate)
            if (!info.isDirectory()) {
                return Some((candidate, info.size))
            }
        } catch (_: Exception) {
            ()
        }
    }
    None
}

func streamWholeFile(httpCtx: HttpContext, path: String): Unit {
    streamFileSegment(httpCtx, path, 0, -1)
}

func streamFileSegment(httpCtx: HttpContext, path: String, start: Int64, length: Int64): Unit {
    let file = File(path, OpenMode.Read)
    try {
        skipFilePrefix(file, start)
        writeInputStreamToResponse(httpCtx, file, length)
    } finally {
        file.close()
    }
}

func writeInputStreamToResponse(httpCtx: HttpContext, stream: InputStream, length: Int64): Unit {
    let writer = HttpResponseWriter(httpCtx)
    let buffer = Array<UInt8>(FILE_STREAM_BUFFER_SIZE, repeat: 0)
    var remaining = length
    while (true) {
        let window = if (remaining < 0) {
            buffer
        } else if (remaining < FILE_STREAM_BUFFER_SIZE) {
            buffer[..remaining]
        } else {
            buffer
        }
        let readLen = stream.read(window)
        if (readLen <= 0) {
            break
        }
        writer.write(window[..readLen])
        if (remaining >= 0) {
            remaining -= readLen
            if (remaining <= 0) {
                break
            }
        }
    }
}

func streamRequestBodyToFile(stream: InputStream, destPath: String): Int64 {
    let file = File(destPath, OpenMode.Write)
    let buffer = Array<UInt8>(FILE_STREAM_BUFFER_SIZE, repeat: 0)
    var total: Int64 = 0
    try {
        while (true) {
            let readLen = stream.read(buffer)
            if (readLen <= 0) {
                break
            }
            let chunk = Array<UInt8>(readLen, repeat: 0)
            var i: Int64 = 0
            while (i < readLen) {
                chunk[i] = buffer[i]
                i += 1
            }
            file.write(chunk)
            total += readLen
        }
    } finally {
        file.close()
    }
    total
}

func writeBytesToFile(destPath: String, bytes: Array<UInt8>): Unit {
    let file = File(destPath, OpenMode.Write)
    try {
        file.write(bytes)
    } finally {
        file.close()
    }
}

func skipFilePrefix(file: File, bytesToSkip: Int64): Unit {
    if (bytesToSkip <= 0) {
        return
    }
    let buffer = Array<UInt8>(FILE_STREAM_BUFFER_SIZE, repeat: 0)
    var remaining = bytesToSkip
    while (remaining > 0) {
        let window = if (remaining < FILE_STREAM_BUFFER_SIZE) {
            buffer[..remaining]
        } else {
            buffer
        }
        let readLen = file.read(window)
        if (readLen <= 0) {
            throw Exception("failed to skip file bytes")
        }
        remaining -= readLen
    }
}

func isHeadRequest(method: String): Bool {
    method.trimAscii().toAsciiUpper() == "HEAD"
}

func startsWithSlash(path: String): Bool {
    let runes = path.toRuneArray()
    if (runes.size == 0) {
        return false
    }
    runes[0] == r'/' || runes[0] == r'\\'
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

func extractFileName(path: String): String {
    let runes = path.toRuneArray()
    var i = runes.size - 1
    while (i >= 0) {
        if (runes[i] == r'/' || runes[i] == r'\\') {
            var name = ""
            for (j in (i + 1)..runes.size) {
                name += runes[j].toString()
            }
            return name
        }
        i -= 1
    }
    path
}

func parseRangeHeader(rangeVal: String, totalSize: Int64): ?(Int64, Int64) {
    let runes = rangeVal.toRuneArray()
    if (runes.size < 6) { return None }
    var prefix = ""
    for (i in 0..6) {
        prefix += runes[i].toString()
    }
    if (prefix.toLower() != "bytes=") { return None }

    var rangeSpec = ""
    for (i in 6..runes.size) {
        rangeSpec += runes[i].toString()
    }
    let parts = rangeSpec.split("-", 2)
    if (parts.size != 2) { return None }

    let startStr = parts[0].trimAscii()
    let endStr = parts[1].trimAscii()

    if (startStr.size == 0 && endStr.size == 0) { return None }

    if (startStr.size == 0) {
        let suffix = parsePositiveInt(endStr)
        if (suffix <= 0) { return None }
        var start = totalSize - suffix
        if (start < 0) { start = 0 }
        return Some((start, totalSize - 1))
    }

    let start = parsePositiveInt(startStr)
    if (start < 0 || start >= totalSize) { return None }

    if (endStr.size == 0) {
        return Some((start, totalSize - 1))
    }

    let end = parsePositiveInt(endStr)
    if (end < start || end >= totalSize) {
        return Some((start, totalSize - 1))
    }
    Some((start, end))
}

func parsePositiveInt(s: String): Int64 {
    let runes = s.toRuneArray()
    if (runes.size == 0) { return -1 }
    var result: Int64 = 0
    for (ch in runes) {
        if (ch < r'0' || ch > r'9') { return -1 }
        let digit = Int64(UInt32(ch)) - Int64(UInt32(r'0'))
        result = result * 10 + digit
    }
    result
}
