package ignite.middleware

import ignite.{Handler, Ctx}
import std.collection.ArrayList
import std.collection.concurrent.ConcurrentHashMap
import std.time.DateTime
import std.sync.Mutex

public class SessionConfig {
    public var cookieName: String = "ignite_session"
    public var cookiePath: String = "/"
    public var cookieMaxAge: Int64 = 86400
    public var cookieSecure: Bool = false
    public var cookieHttpOnly: Bool = true
    public var idLength: Int64 = 32
    public var cleanupEvery: Int64 = 64

    public init(
        cookieName!: String = "ignite_session",
        cookiePath!: String = "/",
        cookieMaxAge!: Int64 = 86400,
        cookieSecure!: Bool = false,
        cookieHttpOnly!: Bool = true,
        idLength!: Int64 = 32,
        cleanupEvery!: Int64 = 64
    ) {
        this.cookieName = cookieName
        this.cookiePath = cookiePath
        this.cookieMaxAge = cookieMaxAge
        this.cookieSecure = cookieSecure
        this.cookieHttpOnly = cookieHttpOnly
        this.idLength = idLength
        this.cleanupEvery = if (cleanupEvery > 0) { cleanupEvery } else { 64 }
    }
}

public class SessionStore {
    let data = ConcurrentHashMap<String, String>()
    let touchedAt = ConcurrentHashMap<String, Int64>()

    public init() {}

    public func get(sessionId: String, key: String): ?String {
        data.get("${sessionId}:${key}")
    }

    public func set(sessionId: String, key: String, value: String): Unit {
        data.add("${sessionId}:${key}", value)
        touch(sessionId, sessionNowMs())
    }

    public func delete(sessionId: String, key: String): Unit {
        data.remove("${sessionId}:${key}")
    }

    public func touch(sessionId: String, nowMs: Int64): Unit {
        touchedAt.add(sessionId, nowMs)
    }

    public func cleanupExpired(ttlMs: Int64, nowMs: Int64): Unit {
        if (ttlMs <= 0) {
            return
        }
        let staleSessions = ArrayList<String>()
        for ((sessionId, touchedMs) in touchedAt) {
            if ((nowMs - touchedMs) >= ttlMs) {
                staleSessions.add(sessionId)
            }
        }
        for (sessionId in staleSessions) {
            touchedAt.remove(sessionId)
            removeSessionData(sessionId)
        }
    }

    func removeSessionData(sessionId: String): Unit {
        let prefix = "${sessionId}:"
        let staleKeys = ArrayList<String>()
        for ((entryKey, _value) in data) {
            if (entryKey.startsWith(prefix)) {
                staleKeys.add(entryKey)
            }
        }
        for (entryKey in staleKeys) {
            data.remove(entryKey)
        }
    }
}

public let DEFAULT_SESSION_STORE: SessionStore = SessionStore()

class SessionSweepState {
    var cleanupTicks: Int64 = 0
}

public func sessionMiddleware(config!: SessionConfig = SessionConfig(),
                              store!: SessionStore = DEFAULT_SESSION_STORE): Handler {
    let sweepState = SessionSweepState()
    { ctx: Ctx =>
        let nowMs = sessionNowMs()
        sweepState.cleanupTicks += 1
        if (sweepState.cleanupTicks >= config.cleanupEvery) {
            store.cleanupExpired(sessionTtlMs(config), nowMs)
            sweepState.cleanupTicks = 0
        }

        var sessionId = ctx.cookies(config.cookieName) ?? ""

        if (sessionId.size == 0) {
            sessionId = generateRandomHex(config.idLength)
            ctx.setCookie(config.cookieName, sessionId, maxAge: config.cookieMaxAge,
                         path: config.cookiePath, httpOnly: config.cookieHttpOnly,
                         secure: config.cookieSecure)
        }

        store.touch(sessionId, nowMs)
        ctx.setLocal("session_id", sessionId)
        let _ = store.get(sessionId, "")
        ctx.next()
    }
}

func sessionNowMs(): Int64 {
    DateTime.now().toUnixTimeStamp().toMilliseconds()
}

func sessionTtlMs(config: SessionConfig): Int64 {
    if (config.cookieMaxAge > 0) {
        return config.cookieMaxAge * 1000
    }
    86400 * 1000
}
