package ignite.middleware

import ignite.{Handler, Ctx}
import std.collection.concurrent.ConcurrentHashMap
import std.sync.Mutex

public class SessionConfig {
    public var cookieName: String = "ignite_session"
    public var cookiePath: String = "/"
    public var cookieMaxAge: Int64 = 86400
    public var cookieSecure: Bool = false
    public var cookieHttpOnly: Bool = true
    public var idLength: Int64 = 32

    public init(
        cookieName!: String = "ignite_session",
        cookiePath!: String = "/",
        cookieMaxAge!: Int64 = 86400,
        cookieSecure!: Bool = false,
        cookieHttpOnly!: Bool = true,
        idLength!: Int64 = 32
    ) {
        this.cookieName = cookieName
        this.cookiePath = cookiePath
        this.cookieMaxAge = cookieMaxAge
        this.cookieSecure = cookieSecure
        this.cookieHttpOnly = cookieHttpOnly
        this.idLength = idLength
    }
}

public class SessionStore {
    let data = ConcurrentHashMap<String, String>()

    public init() {}

    public func get(sessionId: String, key: String): ?String {
        data.get("${sessionId}:${key}")
    }

    public func set(sessionId: String, key: String, value: String): Unit {
        data.add("${sessionId}:${key}", value)
    }

    public func delete(sessionId: String, key: String): Unit {
        data.remove("${sessionId}:${key}")
    }
}

public let DEFAULT_SESSION_STORE: SessionStore = SessionStore()

public func sessionMiddleware(config!: SessionConfig = SessionConfig(),
                              store!: SessionStore = DEFAULT_SESSION_STORE): Handler {
    { ctx: Ctx =>
        var sessionId = ctx.cookies(config.cookieName) ?? ""

        if (sessionId.size == 0) {
            sessionId = generateRandomHex(config.idLength)
            ctx.setCookie(config.cookieName, sessionId, maxAge: config.cookieMaxAge,
                         path: config.cookiePath, httpOnly: config.cookieHttpOnly,
                         secure: config.cookieSecure)
        }

        ctx.setLocal("session_id", sessionId)
        let _ = store.get(sessionId, "")
        ctx.next()
    }
}
