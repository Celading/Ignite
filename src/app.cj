package ignite

import std.collection.ArrayList
import std.env.*
import std.fs.{exists, FileInfo}
import std.io.InputStream
import std.time.DateTime
import stdx.net.http.{
    HttpContext, HttpRequestHandler,
    HttpRequestDistributor, HttpRequestBuilder,
    HttpHeaders, ClientBuilder
}
import ignite.api2
import ignite.api2.GetData

public class AppTestResponse {
    public let status: UInt16
    public let body: String
    public let headers: HttpHeaders

    public init(status: UInt16, body: String, headers: HttpHeaders) {
        this.status = status
        this.body = body
        this.headers = headers
    }

    public func header(name: String): ?String {
        headers.getFirst(name)
    }
}

public class App {
    public let config: Config
    public let router: Router
    var _engine: ServerEngine = StdxServerEngine()
    var _swaggerInfo: SwaggerInfo = SwaggerInfo()
    var _errorHandler: ?ErrorHandler = None
    var _shutdownHooks: ArrayList<() -> Unit> = ArrayList<() -> Unit>()
    var _swaggerJsonCache: ?String = None
    var _swaggerHtmlCache: ?String = None
    var _swaggerRouteInstalled: Bool = false

    public init(config!: Config = Config()) {
        this.config = config
        this.router = Router(config)
    }

    public static func create(config!: Config = Config()): App {
        App(config: config)
    }

    // ── HTTP method routes ──

    public func get(path: String, handler: Handler, option!: ?RouteOption = None): App {
        router.addRoute("GET", path, wrapSingle(handler), option: option)
        this
    }

    public func post(path: String, handler: Handler, option!: ?RouteOption = None): App {
        router.addRoute("POST", path, wrapSingle(handler), option: option)
        this
    }

    public func put(path: String, handler: Handler, option!: ?RouteOption = None): App {
        router.addRoute("PUT", path, wrapSingle(handler), option: option)
        this
    }

    public func delete(path: String, handler: Handler, option!: ?RouteOption = None): App {
        router.addRoute("DELETE", path, wrapSingle(handler), option: option)
        this
    }

    public func patch(path: String, handler: Handler, option!: ?RouteOption = None): App {
        router.addRoute("PATCH", path, wrapSingle(handler), option: option)
        this
    }

    public func head(path: String, handler: Handler, option!: ?RouteOption = None): App {
        router.addRoute("HEAD", path, wrapSingle(handler), option: option)
        this
    }

    public func options(path: String, handler: Handler, option!: ?RouteOption = None): App {
        router.addRoute("OPTIONS", path, wrapSingle(handler), option: option)
        this
    }

    public func all(path: String, handler: Handler, option!: ?RouteOption = None): App {
        let methods = ["GET", "POST", "PUT", "DELETE", "PATCH", "HEAD", "OPTIONS"]
        for (method in methods) {
            router.addRoute(method, path, wrapSingle(handler), option: option)
        }
        this
    }

    // ── Static file serving ──

    public func `static`(prefix: String, root: String): App {
        let rootDir = root
        let catchAllPath = if (prefix.size > 0 && prefix.toRuneArray()[prefix.size - 1] == r'/') {
            prefix + "*"
        } else {
            prefix + "/*"
        }
        router.addRoute("GET", catchAllPath, wrapSingle({ ctx: Ctx =>
            let filePath = ctx.params("*")
            let fullPath = rootDir + "/" + filePath
            ctx.sendFile(fullPath)
        }))
        this
    }

    /// 静态优先 + SPA 回退：先按路径尝试发送静态文件，不存在则发送 indexFile（如 index.html），兜住所有请求转发前端。
    /// 适用于 Next.js 静态导出、Vite/React 等前端；子路径如 login/_xxxxx.txt 会按 root 下相对路径解析。
    /// 路径安全：拒绝含 ".." 的请求，回退到 indexFile。
    public func staticSpa(prefix: String, root: String, indexFile!: String = "index.html"): App {
        let rootDir = root
        let fallbackPath = rootDir + "/" + indexFile
        let serveFallback: Handler = { ctx: Ctx => ctx.sendFile(fallbackPath) }
        let normalizedPrefix = if (prefix.size > 0 && prefix.toRuneArray()[prefix.size - 1] == r'/') {
            let runes = prefix.toRuneArray()
            var s = ""
            for (i in 0..runes.size - 1) { s += runes[i].toString() }
            if (s.size == 0) { "/" } else { s }
        } else {
            prefix
        }
        if (normalizedPrefix == "/" || normalizedPrefix.size == 0) {
            router.addRoute("GET", "/", wrapSingle(serveFallback))
            router.addRoute("HEAD", "/", wrapSingle(serveFallback))
        }
        let catchAllPath = if (normalizedPrefix.size > 0 && normalizedPrefix.toRuneArray()[normalizedPrefix.size - 1] == r'/') {
            normalizedPrefix + "*"
        } else {
            normalizedPrefix + "/*"
        }
        let handler: Handler = { ctx: Ctx =>
            let filePath = ctx.params("*")
            if (filePath.contains("..")) {
                ctx.sendFile(fallbackPath)
                return
            }
            let fullPath = rootDir + "/" + filePath
            let shouldServeStatic = if (exists(fullPath)) {
                let fileInfo = FileInfo(fullPath)
                !fileInfo.isDirectory()
            } else {
                false
            }
            if (shouldServeStatic) {
                ctx.sendFile(fullPath)
            } else {
                ctx.sendFile(fallbackPath)
            }
        }
        router.addRoute("GET", catchAllPath, wrapSingle(handler))
        router.addRoute("HEAD", catchAllPath, wrapSingle(handler))
        this
    }

    // ── WebSocket ──

    public func ws(path: String, handler: WsHandler): App {
        let wsFunc: Handler = { ctx: Ctx =>
            try {
                let conn = ctx.upgradeWebSocket()
                handler(conn)
            } catch (e: Exception) {
                println("[Ignite] WebSocket error: ${e.message}")
            }
        }
        router.addRoute("GET", path, wrapSingle(wsFunc))
        this
    }

    // ── Middleware ──

    public func use(handler: Handler): App {
        router.addGlobalMiddleware(handler)
        this
    }

    public func use(handlers: Array<Handler>): App {
        for (h in handlers) {
            router.addGlobalMiddleware(h)
        }
        this
    }

    // ── Route groups ──

    public func group(prefix: String): Group {
        Group(this, prefix)
    }

    // ── Route management ──

    public func removeRoute(method: String, path: String): Bool {
        router.removeRoute(method, path)
    }

    public func nameRoute(method: String, path: String, name: String): Bool {
        router.setRouteName(method, path, name)
    }

    /// 通过路由名反向生成 URL；优先使用显式 route name，其次使用 RouteOption.operationId。
    /// 若缺少路径参数或路由不存在，返回 None。
    public func urlFor(
        name: String,
        params!: Array<(String, String)> = [],
        query!: Array<(String, String)> = []
    ): ?String {
        match (router.findRouteByName(name)) {
            case Some(route) =>
                if (let Some(path) <- buildPathFromTemplate(route.path, params)) {
                    return Some(appendQueryPairs(path, query))
                }
                None
            case None => None
        }
    }

    // ── Swagger ──

    public func swagger(info: SwaggerInfo): App {
        _swaggerInfo = info
        _swaggerJsonCache = None
        _swaggerHtmlCache = None
        this
    }

    // ── Cache management ──

    public func invalidateSwaggerCache(): Unit {
        _swaggerJsonCache = None
        _swaggerHtmlCache = None
    }

    // ── Error handling ──

    public func onError(handler: ErrorHandler): App {
        _errorHandler = handler
        this
    }

    // ── Shutdown hooks ──

    public func onShutdown(hook: () -> Unit): App {
        _shutdownHooks.add(hook)
        this
    }

    public func serverEngine(engine: ServerEngine): App {
        _engine = engine
        this
    }

    public func withServerEngine(engine: ServerEngine): App {
        serverEngine(engine)
    }

    // ── Server lifecycle ──

    public func listen(addr: String, port: UInt16): Unit {
        setupSwaggerRoute()

        if (config.enablePrintRoutes) {
            router.printRoutes()
        }

        let distributor = IgniteDistributor(this)
        let hasTls = config.tlsCertFile.size > 0 && config.tlsKeyFile.size > 0
        let scheme = if (hasTls) { "https" } else { "http" }
        let tlsEnabled = hasTls
        let appName = config.appName
        let appVersion = config.appVersion
        let routeCount = router.allRoutes.size
        var pidStr = "?"
        try {
            pidStr = "${getProcessId()}"
        } catch (_: Exception) { }
        let currentPid = pidStr

        let option = ServerEngineListenOption(
            addr,
            port,
            config.readTimeout,
            config.writeTimeout,
            config.readHeaderTimeout,
            config.bodyLimit,
            config.tlsCertFile,
            config.tlsKeyFile,
            config.enableTlsPrecheck
        )
        try {
            _engine.listen(
                option,
                distributor,
                {
                    =>
                    printBanner(
                        appName,
                        appVersion,
                        scheme,
                        addr,
                        port,
                        routeCount,
                        currentPid,
                        tlsEnabled,
                        config.enableSwagger,
                        config.swaggerPath,
                        config.kmode
                    )
                }
            )
        } catch (e: api2.TlsConfigLoadException) {
            let tlsStage = tlsStageFromSourceCode(e.sourceCode)
            let tlsCode = e.code.toString()
            let igniteCode = api2.tlsToIgniteErrorCode(e.code)
            let hint = tlsHintForCode(e.code)
            println("[Ignite] Failed to start server on ${addr}:${port} - ${e.message}")
            println("[Ignite][TLS] tls_stage=${tlsStage} tls_error_code=${tlsCode} ignite_error_code=${igniteCode} source=${e.sourceCode}")
            println("[Ignite][TLS] hint=${hint}")
        } catch (e: Exception) {
            println("[Ignite] Failed to start server on ${addr}:${port} - ${e.message}")
            println("[Ignite] Hint: port ${port} may already be in use. Try a different port or kill the existing process.")
        }
    }

    /// 无需 listen 的进程内测试入口：会走完整路由与中间件链，并返回可断言的响应快照。
    public func handleForTest(
        method: String,
        path: String,
        body!: String = "",
        headers!: Array<(String, String)> = []
    ): AppTestResponse {
        setupSwaggerRoute()
        let host = "127.0.0.1"
        let port = chooseInprocTestPort(method, path)
        let serverFuture = spawn {
            this.listen(host, port)
        }

        let client = ClientBuilder()
            .readTimeout(Duration.second * 1)
            .writeTimeout(Duration.second * 1)
            .poolSize(2)
            .build()

        try {
            var attempt: Int64 = 0
            while (attempt < 20) {
                try {
                    let url = normalizeTestUrl(path, host, port)
                    let requestBuilder = HttpRequestBuilder()
                        .method(normalizeHttpMethod(method))
                        .url(url)
                    for ((k, v) in headers) {
                        requestBuilder.header(k, v)
                    }
                    if (body.size > 0) {
                        requestBuilder.body(body)
                    }

                    let response = client.send(requestBuilder.build())
                    let responseBody = readInputStreamUtf8(response.body)
                    return AppTestResponse(response.status, responseBody, response.headers)
                } catch (_: Exception) {
                    if (attempt == 19) {
                        throw Exception("handleForTest failed to connect path=${path}")
                    }
                    sleep(Duration.millisecond * 50)
                    attempt += 1
                }
            }
        } finally {
            try {
                client.close()
            } catch (_: Exception) { }
            _engine.shutdown()
            try {
                let _ = serverFuture.get(Duration.second * 1)
            } catch (_: Exception) {
                serverFuture.cancel()
            }
        }
        throw Exception("handleForTest unreachable")
    }

    public func shutdown(): Unit {
        for (hook in _shutdownHooks) {
            hook()
        }
        _engine.shutdown()
    }

    // ── Internal ──

    func wrapSingle(handler: Handler): ArrayList<Handler> {
        let list = ArrayList<Handler>()
        list.add(handler)
        list
    }

    func setupSwaggerRoute(): Unit {
        if (!config.enableSwagger || _swaggerRouteInstalled) {
            return
        }
        let swaggerPath = config.swaggerPath + "/json"
        let appRef = this
        let infoRef = _swaggerInfo
        router.addRoute("GET", swaggerPath, wrapSingle({ ctx =>
            let forceRefresh = ctx.query("refresh") ?? ""
            if (appRef.config.enableSwaggerCache && forceRefresh != "1") {
                if (let Some(cached) <- appRef._swaggerJsonCache) {
                    ctx.json(cached)
                    return
                }
            }
            let gen = SwaggerGenerator(infoRef, appRef.router.getRoutes())
            let jsonStr = gen.generate()
            if (appRef.config.enableSwaggerCache) {
                appRef._swaggerJsonCache = jsonStr
            }
            ctx.json(jsonStr)
        }))

        let uiPath = config.swaggerPath
        router.addRoute("GET", uiPath, wrapSingle({ ctx =>
            let forceRefresh = ctx.query("refresh") ?? ""
            if (appRef.config.enableSwaggerCache && forceRefresh != "1") {
                if (let Some(cached) <- appRef._swaggerHtmlCache) {
                    ctx.html(cached)
                    return
                }
            }
            let cssUrl = if (appRef.config.swaggerUICssUrl.size > 0) {
                appRef.config.swaggerUICssUrl
            } else {
                defaultSwaggerUICssUrl()
            }
            let jsUrl = if (appRef.config.swaggerUIJsUrl.size > 0) {
                appRef.config.swaggerUIJsUrl
            } else {
                defaultSwaggerUIJsUrl()
            }
            let htmlContent = swaggerUIHtml(appRef.config.swaggerPath, cssUrl, jsUrl)
            if (appRef.config.enableSwaggerCache) {
                appRef._swaggerHtmlCache = htmlContent
            }
            ctx.html(htmlContent)
        }))
        _swaggerRouteInstalled = true
    }

    func handleRequest(httpCtx: HttpContext): Unit {
        let ctx = Ctx(httpCtx, this)
        let requestMethod = httpCtx.request.method
        let requestPath = httpCtx.request.url.path

        if (config.serverHeader.size > 0) {
            httpCtx.responseBuilder.header("server", config.serverHeader)
        }

        let result = router.matchRoute(requestMethod, requestPath)

        if (result.matched) {
            ctx.setParams(result.params)
            ctx.setHandlers(result.handlers)
            if (let Some(route) <- result.route) {
                ctx.setRoute(route)
            }
        } else {
            let fallback = methodSemanticsHandler(
                requestMethod,
                requestPath,
                result.allowedMethods
            )
            ctx.setHandlers(router.buildGlobalMiddlewareChain(fallback))
        }

        try {
            ctx.next()
        } catch (e: Exception) {
            if (config.kmode) {
                if (let Some(kmodePanicHandler) <- config.kmodePanicHandler) {
                    if (kmodePanicHandler(ctx, e)) {
                        return
                    }
                }
            }
            if (let Some(errorHandler) <- _errorHandler) {
                errorHandler(ctx, e)
            } else {
                httpCtx.responseBuilder
                    .status(500)
                    .header("content-type", "text/plain; charset=utf-8")
                    .body("Internal Server Error")
            }
        }
    }

    func methodSemanticsHandler(
        requestMethod: String,
        requestPath: String,
        allowedMethods: ArrayList<String>
    ): Handler {
        { ctx: Ctx =>
            if (allowedMethods.size > 0) {
                let allowHeader = joinAllowHeader(allowedMethods)
                ctx.setHeader("allow", allowHeader)
                if (requestMethod == "OPTIONS") {
                    let _ = ctx.noContent()
                } else {
                    let _ = ctx.status(405).sendString("Method Not Allowed")
                }
            } else {
                let _ = ctx.status(404).sendString("Cannot ${requestMethod} ${requestPath}")
            }
        }
    }

    func joinAllowHeader(methods: ArrayList<String>): String {
        var first = true
        var out = ""
        for (method in methods) {
            if (!first) {
                out += ", "
            }
            first = false
            out += method
        }
        out
    }
}

func normalizeHttpMethod(method: String): String {
    let m = method.trimAscii().toAsciiUpper()
    if (m.size == 0) {
        return "GET"
    }
    m
}

func normalizeTestUrl(path: String, host: String, port: UInt16): String {
    let trimmed = path.trimAscii()
    if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
        return trimmed
    }
    if (trimmed.size == 0) {
        return "http://${host}:${port}/"
    }
    if (trimmed.toRuneArray()[0] == r'/') {
        return "http://${host}:${port}" + trimmed
    }
    "http://${host}:${port}/" + trimmed
}

func buildPathFromTemplate(pathTemplate: String, params: Array<(String, String)>): ?String {
    let chars = pathTemplate.toRuneArray()
    var i: Int64 = 0
    var result = ""
    while (i < chars.size) {
        if (chars[i] == r':') {
            i += 1
            var name = ""
            while (i < chars.size && chars[i] != r'/') {
                name += chars[i].toString()
                i += 1
            }
            if (let Some(value) <- findRouteParam(params, name)) {
                result += value
            } else {
                return None
            }
            continue
        }
        if (chars[i] == r'*') {
            if (let Some(value) <- findRouteParam(params, "*")) {
                result += value
            } else {
                return None
            }
            i += 1
            continue
        }
        result += chars[i].toString()
        i += 1
    }
    Some(result)
}

func findRouteParam(params: Array<(String, String)>, key: String): ?String {
    for ((k, v) in params) {
        if (k == key) {
            return Some(v)
        }
    }
    None
}

func appendQueryPairs(path: String, query: Array<(String, String)>): String {
    if (query.size == 0) {
        return path
    }
    var out = path + "?"
    var first = true
    for ((k, v) in query) {
        if (!first) {
            out += "&"
        }
        first = false
        out += urlEncode(k) + "=" + urlEncode(v)
    }
    out
}

func urlEncode(input: String): String {
    let allowed = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~"
    var out = ""
    for (r in input.toRuneArray()) {
        let c = r.toString()
        if (c == " ") {
            out += "+"
        } else if (strContainsRuneString(allowed, c)) {
            out += c
        } else {
            let bytes = c.toArray()
            for (b in bytes) {
                let n = Int64(b)
                out += "%"
                if (n < 16) {
                    out += "0"
                }
                out += intToHex(n)
            }
        }
    }
    out
}

func strContainsRuneString(haystack: String, needle: String): Bool {
    let h = haystack.toRuneArray()
    let n = needle.toRuneArray()
    if (n.size == 0) {
        return true
    }
    if (h.size < n.size) {
        return false
    }
    for (i in 0..=(h.size - n.size)) {
        var ok = true
        for (j in 0..n.size) {
            if (h[i + j] != n[j]) {
                ok = false
                break
            }
        }
        if (ok) {
            return true
        }
    }
    false
}

func intToHex(n: Int64): String {
    if (n < 10) {
        return "${n}"
    }
    if (n < 16) {
        return String.fromUtf8([UInt8(87 + n)])
    }
    intToHex(n / 16) + intToHex(n % 16)
}

func readInputStreamUtf8(stream: InputStream): String {
    let out = ArrayList<UInt8>()
    let buf = Array<UInt8>(4096, repeat: 0)
    while (true) {
        let n = stream.read(buf)
        if (n <= 0) {
            break
        }
        for (i in 0..n) {
            out.add(buf[i])
        }
    }
    String.fromUtf8(out.toArray())
}

func chooseInprocTestPort(method: String, path: String): UInt16 {
    let nowMs = DateTime.now().toUnixTimeStamp().toMilliseconds()
    let seed = nowMs + method.size + path.size
    let raw = 42000 + (seed % 10000)
    UInt16(raw)
}

func tlsStageFromSourceCode(sourceCode: String): String {
    let normalized = sourceCode.trimAscii().toAsciiUpper()
    if (normalized.startsWith("STDX_")) {
        return "stdx_tls_build"
    }
    "jinguiSSL_precheck"
}

func tlsHintForCode(code: api2.TlsConfigLoadErrorCode): String {
    match (code) {
        case api2.TlsConfigLoadErrorCode.BadInput =>
            "check cert/key pem format and ALPN list (h2,http/1.1)"
        case api2.TlsConfigLoadErrorCode.VerifyFailed =>
            "check certificate chain and private key match"
        case api2.TlsConfigLoadErrorCode.KeyNotFound =>
            "check key source and key id mapping"
        case api2.TlsConfigLoadErrorCode.CryptoUnavailable =>
            "check crypto runtime and dependency availability"
        case api2.TlsConfigLoadErrorCode.ComplianceRejected =>
            "check compliance policy and allowed algorithms"
        case api2.TlsConfigLoadErrorCode.Unsupported =>
            "check unsupported tls option or algorithm setting"
        case api2.TlsConfigLoadErrorCode.InternalError =>
            "check stdx tls build path and runtime exception details"
    }
}

class LambdaHttpHandler <: HttpRequestHandler {
    let fn: (HttpContext) -> Unit

    init(fn: (HttpContext) -> Unit) {
        this.fn = fn
    }

    public func handle(ctx: HttpContext): Unit {
        fn(ctx)
    }
}

class IgniteDistributor <: HttpRequestDistributor {
    let app: App
    let mainHandler: IgniteMainHandler

    init(app: App) {
        this.app = app
        this.mainHandler = IgniteMainHandler(app)
    }

    private func usePathForLint(p: String): Unit {
        if (p.size >= 0) { }
    }

    private func useHandlerForLint(h: HttpRequestHandler): Unit {
        let _ = h
    }

    public func register(path: String, handler: HttpRequestHandler): Unit {
        usePathForLint(path)
        useHandlerForLint(handler)
    }

    public func registerRoute(path: String, handler: (HttpContext) -> Unit): Unit {
        usePathForLint(path)
        useHandlerForLint(LambdaHttpHandler(handler))
    }

    public func distribute(path: String): HttpRequestHandler {
        usePathForLint(path)
        mainHandler
    }
}

class IgniteMainHandler <: HttpRequestHandler {
    let app: App

    init(app: App) {
        this.app = app
    }

    public func handle(ctx: HttpContext): Unit {
        app.handleRequest(ctx)
    }
}

func defaultSwaggerUICssUrl(): String {
    "https" + "://unpkg.com/" + "swagger-ui-dist@5/" + "swagger-ui.css"
}

func defaultSwaggerUIJsUrl(): String {
    "https" + "://unpkg.com/" + "swagger-ui-dist@5/" + "swagger-ui-bundle.js"
}

func swaggerUIHtml(basePath: String, cssUrl: String, jsUrl: String): String {
    let jsonUrl = basePath + "/json"
    #"<!DOCTYPE html>
<html>
<head>
<title>Ignite API - Swagger UI</title>
<link rel="stylesheet" href=""# + cssUrl + #"">
</head>
<body>
<div id="swagger-ui"></div>
<script src=""# + jsUrl + #""></script>
<script>
SwaggerUIBundle({ url: '"# + jsonUrl + #"', dom_id: '#swagger-ui' });
</script>
</body>
</html>"#
}

// ── Startup Banner ──

func bannerCenter(s: String, w: Int64): String {
    if (s.size >= w) { return s }
    let pad = w - s.size
    let left = pad / 2
    let right = pad - left
    var result = ""
    for (_ in 0..left) { result += " " }
    result += s
    for (_ in 0..right) { result += " " }
    result
}

func bannerPadRight(s: String, w: Int64): String {
    var result = s
    while (result.size < w) { result += " " }
    result
}

func bannerDotFill(label: String, value: String, w: Int64): String {
    let dotsNeeded = w - label.size - value.size - 2
    var dots = ""
    if (dotsNeeded > 0) {
        for (_ in 0..dotsNeeded) { dots += "." }
    }
    "${label} ${dots} ${value}"
}

func printBanner(
    appName: String,
    appVersion: String,
    scheme: String,
    addr: String,
    port: UInt16,
    handlerCount: Int64,
    pid: String,
    tlsEnabled: Bool,
    enableSwagger: Bool,
    swaggerPath: String,
    kmode: Bool
): Unit {
    let frameworkVersion = GetData.GetDataClass.ModuleVer()
    let versionDisplay = if (appVersion.size > 0) { appVersion } else { frameworkVersion }
    let innerWidth: Int64 = 53

    let esc = "\u{1B}"
    let R = esc + "[0m"
    let CB = esc + "[1;36m"
    let G = esc + "[92m"
    let D = esc + "[2m"
    let B = esc + "[1m"
    let DOT = esc + "[38;5;240m"   // #555 灰色 (approx)

    func bannerDotFillColor(label: String, value: String, w: Int64): String {
        let dotsNeeded = w - label.size - value.size - 2
        var dots = ""
        if (dotsNeeded > 0) {
            for (_ in 0..dotsNeeded) { dots += "." }
        }
        if (dots.size > 0) {
            "${label} ${DOT}${dots}${R} ${value}"
        } else {
            "${label} ${value}"
        }
    }

    let displayAddr = if (addr == "0.0.0.0") {
        let info = api2.getNetworkInfo()
        if (info.ips.size > 0) { info.ips[0] } else { "0.0.0.0" }
    } else {
        addr
    }
    let title = "${appName} v${versionDisplay}"
    let url = "${scheme}://${displayAddr}:${port}"
    let bound = "(bound on host ${addr} and port ${port})"

    let colW: Int64 = 23
    let col1Line1 = bannerDotFillColor("Handlers", "${handlerCount}", colW)
    let col2Line1 = bannerDotFillColor("Processes", "1", colW)
    let statsLine1 = bannerPadRight(" " + col1Line1 + "  " + col2Line1, innerWidth)

    let left2 = if (tlsEnabled) {
        bannerDotFillColor("TLS", "Enabled", colW)
    } else {
        bannerDotFillColor("Prefork", "Disabled", colW)
    }
    let col2Line2 = bannerDotFillColor("PID", pid, colW)
    let statsLine2 = bannerPadRight(" " + left2 + "  " + col2Line2, innerWidth)

    var border = ""
    for (_ in 0..innerWidth) { border += "─" }

    let emptyInner = bannerCenter("", innerWidth)

    println("")
    println(" ${D}┌${border}┐${R}")
    println(" ${D}│${R}${CB}${bannerCenter(title, innerWidth)}${R}${D}│${R}")
    println(" ${D}│${R}${G}${bannerCenter(url, innerWidth)}${R}${D}│${R}")
    println(" ${D}│${R}${D}${bannerCenter(bound, innerWidth)}${R}${D}│${R}")
    println(" ${D}│${R}${emptyInner}${D}│${R}")
    println(" ${D}│${R}${statsLine1}${D}│${R}")
    println(" ${D}│${R}${statsLine2}${D}│${R}")
    println(" ${D}└${border}┘${R}")
    if (kmode) {
        println(" ${CB}Ignite v${frameworkVersion} (kmode)${R}")
    }
    if (enableSwagger) {
        println(" ${G}Swagger UI: ${scheme}://${displayAddr}:${port}${swaggerPath}${R}")
    }
    println("")
}
