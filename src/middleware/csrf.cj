package ignite.middleware

import ignite.{Handler, Ctx}
import std.collection.concurrent.ConcurrentHashMap

public class CsrfConfig {
    public var cookieName: String = "_csrf"
    public var headerName: String = "X-CSRF-Token"
    public var cookiePath: String = "/"
    public var cookieMaxAge: Int64 = 3600
    public var cookieSecure: Bool = false
    public var cookieHttpOnly: Bool = true
    public var tokenLength: Int64 = 32

    public init(
        cookieName!: String = "_csrf",
        headerName!: String = "X-CSRF-Token",
        cookiePath!: String = "/",
        cookieMaxAge!: Int64 = 3600,
        cookieSecure!: Bool = false,
        cookieHttpOnly!: Bool = true,
        tokenLength!: Int64 = 32
    ) {
        this.cookieName = cookieName
        this.headerName = headerName
        this.cookiePath = cookiePath
        this.cookieMaxAge = cookieMaxAge
        this.cookieSecure = cookieSecure
        this.cookieHttpOnly = cookieHttpOnly
        this.tokenLength = tokenLength
    }
}

public func csrfMiddleware(config!: CsrfConfig = CsrfConfig()): Handler {
    let tokens = ConcurrentHashMap<String, Int64>()
    { ctx: Ctx =>
        let method = ctx.method
        if (method == "GET" || method == "HEAD" || method == "OPTIONS" || method == "TRACE") {
            let token = generateRandomHex(config.tokenLength)
            tokens.add(token, 1)
            ctx.setCookie(config.cookieName, token, maxAge: config.cookieMaxAge,
                         path: config.cookiePath, httpOnly: config.cookieHttpOnly,
                         secure: config.cookieSecure)
            ctx.setLocal("csrf_token", token)
            ctx.next()
            return
        }

        let headerToken = ctx.header(config.headerName)
        let cookieToken = ctx.cookies(config.cookieName)
        let token = headerToken ?? (cookieToken ?? "")

        if (token.size == 0) {
            ctx.status(403).sendString("Forbidden - CSRF token missing")
            return
        }

        if (let Some(_) <- tokens.get(token)) {
            tokens.remove(token)
            let newToken = generateRandomHex(config.tokenLength)
            tokens.add(newToken, 1)
            ctx.setCookie(config.cookieName, newToken, maxAge: config.cookieMaxAge,
                         path: config.cookiePath, httpOnly: config.cookieHttpOnly,
                         secure: config.cookieSecure)
            ctx.setLocal("csrf_token", newToken)
            ctx.next()
        } else {
            ctx.status(403).sendString("Forbidden - CSRF token invalid")
        }
    }
}
