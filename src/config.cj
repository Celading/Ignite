package ignite

public struct Config {
    public var appName: String = "Ignite"
    /// 应用版本，用于启动 Banner 标题；空则显示框架版本。Banner 始终输出，不可关闭。
    public var appVersion: String = ""
    public var serverHeader: String = "Ignite"

    public var strictRouting: Bool = false
    public var caseSensitive: Bool = false
    public var unescapePath: Bool = false

    public var bodyLimit: Int64 = 4 * 1024 * 1024
    public var readTimeout: Duration = Duration.second * 30
    public var writeTimeout: Duration = Duration.second * 30
    public var readHeaderTimeout: Duration = Duration.second * 10
    public var idleTimeout: Duration = Duration.second * 120

    public var concurrency: Int64 = 256 * 1024

    public var enableSwagger: Bool = false
    public var swaggerPath: String = "/swagger"
    public var swaggerUICssUrl: String = ""
    public var swaggerUIJsUrl: String = ""
    /// 为 true 时启动时额外打印路由表；Banner 始终输出，不受此控制。
    public var enablePrintRoutes: Bool = false

    public var tlsCertFile: String = ""
    public var tlsKeyFile: String = ""

    public var allowRouteOverwrite: Bool = false

    public var enableSwaggerCache: Bool = true

    public var jsonEncoder: ?JsonEncoder = None

    public init(
        appName!: String = "Ignite",
        appVersion!: String = "",
        serverHeader!: String = "Ignite",
        strictRouting!: Bool = false,
        caseSensitive!: Bool = false,
        bodyLimit!: Int64 = 4 * 1024 * 1024,
        readTimeout!: Duration = Duration.second * 30,
        writeTimeout!: Duration = Duration.second * 30,
        concurrency!: Int64 = 256 * 1024,
        enableSwagger!: Bool = false,
        swaggerUICssUrl!: String = "",
        swaggerUIJsUrl!: String = "",
        enablePrintRoutes!: Bool = false,
        tlsCertFile!: String = "",
        tlsKeyFile!: String = "",
        allowRouteOverwrite!: Bool = false,
        enableSwaggerCache!: Bool = true,
        jsonEncoder!: ?JsonEncoder = None
    ) {
        this.appName = appName
        this.appVersion = appVersion
        this.serverHeader = serverHeader
        this.strictRouting = strictRouting
        this.caseSensitive = caseSensitive
        this.bodyLimit = bodyLimit
        this.readTimeout = readTimeout
        this.writeTimeout = writeTimeout
        this.concurrency = concurrency
        this.enableSwagger = enableSwagger
        this.swaggerUICssUrl = swaggerUICssUrl
        this.swaggerUIJsUrl = swaggerUIJsUrl
        this.enablePrintRoutes = enablePrintRoutes
        this.tlsCertFile = tlsCertFile
        this.tlsKeyFile = tlsKeyFile
        this.allowRouteOverwrite = allowRouteOverwrite
        this.enableSwaggerCache = enableSwaggerCache
        this.jsonEncoder = jsonEncoder
    }
}
