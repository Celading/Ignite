package ignite

import std.collection.ArrayList
import std.fs.{File, OpenMode}
import stdx.net.http.{
    ServerBuilder, Server, HttpContext, HttpRequestHandler,
    HttpRequestDistributor
}
import stdx.net.tls.TlsServerConfig
import stdx.crypto.x509.X509Certificate
import stdx.crypto.x509.PrivateKey

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
            var tlsCfg = TlsServerConfig(
                X509Certificate.decodeFromPem(certPem),
                PrivateKey.decodeFromPem(keyPem)
            )
            tlsCfg.supportedAlpnProtocols = ["h2", "http/1.1"]
            let _ = builder.tlsConfig(tlsCfg)
        }

        let scheme = if (hasTls) { "https" } else { "http" }
        let tlsEnabled = hasTls
        let appName = config.appName

        let server = builder
            .afterBind({ =>
                println("[Ignite] ${appName} listening on ${scheme}://${addr}:${port}")
                if (tlsEnabled) {
                    println("[Ignite] TLS enabled with HTTP/2 support")
                }
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
            let htmlContent = swaggerUIHtml(appRef.config.swaggerPath)
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

class IgniteDistributor <: HttpRequestDistributor {
    let app: App
    let mainHandler: IgniteMainHandler

    init(app: App) {
        this.app = app
        this.mainHandler = IgniteMainHandler(app)
    }

    public func register(_path: String, _handler: HttpRequestHandler): Unit {
    }

    public func register(_path: String, _handler: (HttpContext) -> Unit): Unit {
    }

    public func distribute(_path: String): HttpRequestHandler {
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

func swaggerUIHtml(basePath: String): String {
    let jsonUrl = basePath + "/json"
    #"<!DOCTYPE html>
<html>
<head>
<title>Ignite API - Swagger UI</title>
<link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5/swagger-ui.css">
</head>
<body>
<div id="swagger-ui"></div>
<script src="https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js"></script>
<script>
SwaggerUIBundle({ url: '"# + jsonUrl + #"', dom_id: '#swagger-ui' });
</script>
</body>
</html>"#
}
