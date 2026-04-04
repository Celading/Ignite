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
    /// 为 true 时启动后打印 Swagger UI 地址；仅影响启动输出，不影响 Swagger 路由是否注册。
    public var enablePrintSwaggerUrl: Bool = true
    /// 为 true 时启动时额外打印路由表；Banner 始终输出，不受此控制。
    public var enablePrintRoutes: Bool = false
    /// 为 true 时在 Banner 右下角打印框架签名；仅影响展示，不影响版本读取逻辑。
    public var enableBannerSignature: Bool = true
    /// kmode（调试模式）：为 true 时启动后启用类似 debug 行为，Banner 中必打当前 Ignite 版本，并可配合 kmodeMiddleware 使用。
    public var kmode: Bool = false
    /// kmode panic hook：用于 App 顶层异常兜底。返回 true 表示异常已处理（例如触发重启/终止流程），将跳过默认 500 处理。
    public var kmodePanicHandler: ?KModePanicHandler = None

    public var tlsCertFile: String = ""
    public var tlsKeyFile: String = ""
    /// 为 true 时启用 jinguiSSL TLS precheck；为 false 时仅使用 stdx TLS 构造路径（保留回退能力）。
    public var enableTlsPrecheck: Bool = true

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
        swaggerPath!: String = "/swagger",
        swaggerUICssUrl!: String = "",
        swaggerUIJsUrl!: String = "",
        enablePrintSwaggerUrl!: Bool = true,
        enablePrintRoutes!: Bool = false,
        enableBannerSignature!: Bool = true,
        kmode!: Bool = false,
        kmodePanicHandler!: ?KModePanicHandler = None,
        tlsCertFile!: String = "",
        tlsKeyFile!: String = "",
        enableTlsPrecheck!: Bool = true,
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
        this.swaggerPath = swaggerPath
        this.swaggerUICssUrl = swaggerUICssUrl
        this.swaggerUIJsUrl = swaggerUIJsUrl
        this.enablePrintSwaggerUrl = enablePrintSwaggerUrl
        this.enablePrintRoutes = enablePrintRoutes
        this.enableBannerSignature = enableBannerSignature
        this.kmode = kmode
        this.kmodePanicHandler = kmodePanicHandler
        this.tlsCertFile = tlsCertFile
        this.tlsKeyFile = tlsKeyFile
        this.enableTlsPrecheck = enableTlsPrecheck
        this.allowRouteOverwrite = allowRouteOverwrite
        this.enableSwaggerCache = enableSwaggerCache
        this.jsonEncoder = jsonEncoder
    }
}
