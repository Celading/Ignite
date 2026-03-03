package ignite

public struct Config {
    public var appName: String = "Ignite"
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
    public var enablePrintRoutes: Bool = false

    public var tlsCertFile: String = ""
    public var tlsKeyFile: String = ""

    public var allowRouteOverwrite: Bool = false

    public init(
        appName!: String = "Ignite",
        serverHeader!: String = "Ignite",
        strictRouting!: Bool = false,
        caseSensitive!: Bool = false,
        bodyLimit!: Int64 = 4 * 1024 * 1024,
        readTimeout!: Duration = Duration.second * 30,
        writeTimeout!: Duration = Duration.second * 30,
        concurrency!: Int64 = 256 * 1024,
        enableSwagger!: Bool = false,
        enablePrintRoutes!: Bool = false,
        tlsCertFile!: String = "",
        tlsKeyFile!: String = "",
        allowRouteOverwrite!: Bool = false
    ) {
        this.appName = appName
        this.serverHeader = serverHeader
        this.strictRouting = strictRouting
        this.caseSensitive = caseSensitive
        this.bodyLimit = bodyLimit
        this.readTimeout = readTimeout
        this.writeTimeout = writeTimeout
        this.concurrency = concurrency
        this.enableSwagger = enableSwagger
        this.enablePrintRoutes = enablePrintRoutes
        this.tlsCertFile = tlsCertFile
        this.tlsKeyFile = tlsKeyFile
        this.allowRouteOverwrite = allowRouteOverwrite
    }
}
