package ignite

import std.collection.ArrayList
import std.env.*
import std.fs.{File, OpenMode}
import stdx.net.http.{
    ServerBuilder, Server, HttpContext, HttpRequestHandler,
    HttpRequestDistributor
}
import ignite.api2

public class App {
    public let config: Config
    public let router: Router
    var _server: ?Server = None
    var _swaggerInfo: SwaggerInfo = SwaggerInfo()
    var _errorHandler: ?ErrorHandler = None
    var _shutdownHooks: ArrayList<() -> Unit> = ArrayList<() -> Unit>()

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

    public func removeRoute(method: String, path: String): Bool {
        return router.removeRoute(method, path)
    }

    // ── Swagger ──

    public func swagger(info: SwaggerInfo): App {
        _swaggerInfo = info
        this
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

    // ── Server lifecycle ──

    public func listen(addr: String, port: UInt16): Unit {
        setupSwaggerRoute()

        if (config.enablePrintRoutes) {
            router.printRoutes()
        }

        let distributor = IgniteDistributor(this)

        let builder = ServerBuilder()
            .addr(addr)
            .port(port)
            .distributor(distributor)
            .readTimeout(config.readTimeout)
            .writeTimeout(config.writeTimeout)
            .readHeaderTimeout(config.readHeaderTimeout)
            .maxRequestBodySize(config.bodyLimit)

        let hasTls = config.tlsCertFile.size > 0 && config.tlsKeyFile.size > 0
        if (hasTls) {
            let certPem = readFileString(config.tlsCertFile)
            let keyPem = readFileString(config.tlsKeyFile)
            let tlsCfg = api2.loadTlsServerConfigForHttp2(certPem, keyPem)
            let _ = builder.tlsConfig(tlsCfg)
        }

        let scheme = if (hasTls) { "https" } else { "http" }
        let tlsEnabled = hasTls
        let appName = config.appName
        let routeCount = router.allRoutes.size
        let currentPid = "${getProcessId()}"

        let server = builder
            .afterBind({ =>
                printBanner(appName, scheme, addr, port, routeCount, currentPid, tlsEnabled)
            })
            .build()

        _server = server
        try {
            server.serve()
        } catch (e: Exception) {
            println("[Ignite] Failed to start server on ${addr}:${port} - ${e.message}")
            println("[Ignite] Hint: port ${port} may already be in use. Try a different port or kill the existing process.")
        }
    }

    public func shutdown(): Unit {
        for (hook in _shutdownHooks) {
            hook()
        }
        if (let Some(s) <- _server) {
            s.closeGracefully()
        }
    }

    // ── Internal ──

    func wrapSingle(handler: Handler): ArrayList<Handler> {
        let list = ArrayList<Handler>()
        list.add(handler)
        list
    }

    func setupSwaggerRoute(): Unit {
        if (!config.enableSwagger) {
            return
        }
        let swaggerPath = config.swaggerPath + "/json"
        let appRef = this
        let infoRef = _swaggerInfo
        router.addRoute("GET", swaggerPath, wrapSingle({ ctx =>
            let gen = SwaggerGenerator(infoRef, appRef.router.getRoutes())
            let jsonStr = gen.generate()
            ctx.json(jsonStr)
        }))

        let uiPath = config.swaggerPath
        router.addRoute("GET", uiPath, wrapSingle({ ctx =>
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
            ctx.html(htmlContent)
        }))
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
            try {
                ctx.next()
            } catch (e: Exception) {
                if (let Some(errorHandler) <- _errorHandler) {
                    errorHandler(ctx, e)
                } else {
                    httpCtx.responseBuilder
                        .status(500)
                        .header("content-type", "text/plain; charset=utf-8")
                        .body("Internal Server Error")
                }
            }
        } else {
            httpCtx.responseBuilder
                .status(404)
                .header("content-type", "text/plain; charset=utf-8")
                .body("Cannot ${requestMethod} ${requestPath}")
        }
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

func readFileString(path: String): String {
    let file = File(path, OpenMode.Read)
    let buf = ArrayList<UInt8>()
    let tmp = Array<UInt8>(4096, repeat: 0)
    while (true) {
        let n = file.read(tmp)
        if (n <= 0) { break }
        for (i in 0..n) {
            buf.add(tmp[i])
        }
    }
    file.close()
    String.fromUtf8(buf.toArray())
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
    scheme: String,
    addr: String,
    port: UInt16,
    handlerCount: Int64,
    pid: String,
    tlsEnabled: Bool
): Unit {
    let version = "0.3.20"
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

    let displayAddr = if (addr == "0.0.0.0") { "127.0.0.1" } else { addr }
    let title = "${appName} v${version}"
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
    println("")
}
