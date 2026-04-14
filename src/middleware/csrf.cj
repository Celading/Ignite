package ignite.middleware

import ignite.{Handler, Ctx}
import std.collection.ArrayList
import std.collection.concurrent.ConcurrentHashMap
import std.time.DateTime

public class CsrfSweepState {
    public var cleanupTicks: Int64 = 0
}

public class CsrfConfig {
    public var cookieName: String = "_csrf"
    public var headerName: String = "X-CSRF-Token"
    public var cookiePath: String = "/"
    public var cookieMaxAge: Int64 = 3600
    public var cookieSecure: Bool = false
    public var cookieHttpOnly: Bool = true
    public var tokenLength: Int64 = 32
    public var cleanupEvery: Int64 = 64

    public init(
        cookieName!: String = "_csrf",
        headerName!: String = "X-CSRF-Token",
        cookiePath!: String = "/",
        cookieMaxAge!: Int64 = 3600,
        cookieSecure!: Bool = false,
        cookieHttpOnly!: Bool = true,
        tokenLength!: Int64 = 32,
        cleanupEvery!: Int64 = 64
    ) {
        this.cookieName = cookieName
        this.headerName = headerName
        this.cookiePath = cookiePath
        this.cookieMaxAge = cookieMaxAge
        this.cookieSecure = cookieSecure
        this.cookieHttpOnly = cookieHttpOnly
        this.tokenLength = tokenLength
        this.cleanupEvery = if (cleanupEvery > 0) { cleanupEvery } else { 64 }
    }
}

public func csrfMiddleware(config!: CsrfConfig = CsrfConfig()): Handler {
    let tokens = ConcurrentHashMap<String, Int64>()
    let sweepState = CsrfSweepState()
    { ctx: Ctx =>
        let nowMs = csrfNowMs()
        sweepState.cleanupTicks += 1
        if (sweepState.cleanupTicks >= config.cleanupEvery) {
            cleanupExpiredCsrfTokens(tokens, nowMs, csrfTokenTtlMs(config))
            sweepState.cleanupTicks = 0
        }

        let method = ctx.method
        if (method == "GET" || method == "HEAD" || method == "OPTIONS" || method == "TRACE") {
            let token = generateRandomHex(config.tokenLength)
            tokens.add(token, nowMs)
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

        if (let Some(issuedAtMs) <- tokens.get(token)) {
            if (csrfTokenExpired(issuedAtMs, nowMs, csrfTokenTtlMs(config))) {
                tokens.remove(token)
                ctx.status(403).sendString("Forbidden - CSRF token invalid")
                return
            }
            tokens.remove(token)
            let newToken = generateRandomHex(config.tokenLength)
            tokens.add(newToken, nowMs)
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

func csrfNowMs(): Int64 {
    DateTime.now().toUnixTimeStamp().toMilliseconds()
}

func csrfTokenTtlMs(config: CsrfConfig): Int64 {
    if (config.cookieMaxAge > 0) {
        return config.cookieMaxAge * 1000
    }
    3600 * 1000
}

func csrfTokenExpired(issuedAtMs: Int64, nowMs: Int64, ttlMs: Int64): Bool {
    if (ttlMs <= 0) {
        return false
    }
    (nowMs - issuedAtMs) >= ttlMs
}

func cleanupExpiredCsrfTokens(
    tokens: ConcurrentHashMap<String, Int64>,
    nowMs: Int64,
    ttlMs: Int64
): Unit {
    if (ttlMs <= 0) {
        return
    }
    let staleTokens = ArrayList<String>()
    for ((token, issuedAtMs) in tokens) {
        if (csrfTokenExpired(issuedAtMs, nowMs, ttlMs)) {
            staleTokens.add(token)
        }
    }
    for (token in staleTokens) {
        tokens.remove(token)
    }
}
