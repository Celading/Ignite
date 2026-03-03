package ignite.middleware

import ignite.{Handler, Ctx}
public class CorsConfig {
    public var allowOrigins: String = "*"
    public var allowMethods: String = "GET,POST,PUT,DELETE,PATCH,HEAD,OPTIONS"
    public var allowHeaders: String = "Origin,Content-Type,Accept,Authorization"
    public var exposeHeaders: String = ""
    public var allowCredentials: Bool = false
    public var maxAge: Int64 = 0

    public init(
        allowOrigins!: String = "*",
        allowMethods!: String = "GET,POST,PUT,DELETE,PATCH,HEAD,OPTIONS",
        allowHeaders!: String = "Origin,Content-Type,Accept,Authorization",
        exposeHeaders!: String = "",
        allowCredentials!: Bool = false,
        maxAge!: Int64 = 0
    ) {
        this.allowOrigins = allowOrigins
        this.allowMethods = allowMethods
        this.allowHeaders = allowHeaders
        this.exposeHeaders = exposeHeaders
        this.allowCredentials = allowCredentials
        this.maxAge = maxAge
    }
}

public func corsMiddleware(config!: CorsConfig = CorsConfig()): Handler {
    { ctx: Ctx =>
        ctx.setHeader("Access-Control-Allow-Origin", config.allowOrigins)
        ctx.setHeader("Access-Control-Allow-Methods", config.allowMethods)
        ctx.setHeader("Access-Control-Allow-Headers", config.allowHeaders)

        if (config.exposeHeaders.size > 0) {
            ctx.setHeader("Access-Control-Expose-Headers", config.exposeHeaders)
        }
        if (config.allowCredentials) {
            ctx.setHeader("Access-Control-Allow-Credentials", "true")
        }
        if (config.maxAge > 0) {
            ctx.setHeader("Access-Control-Max-Age", "${config.maxAge}")
        }

        if (ctx.method == "OPTIONS") {
            ctx.sendStatus(204)
            return
        }

        ctx.next()
    }
}
