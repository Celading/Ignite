package ignite.middleware

import ignite.{Handler, Ctx}
import std.collection.ArrayList
import std.collection.concurrent.ConcurrentHashMap
import std.time.MonoTime
import std.sync.Mutex

public class RateLimitConfig {
    public var max: Int64 = 100
    public var windowMs: Int64 = 60000
    public var cleanupEvery: Int64 = 64
    public var keyGenerator: ?((Ctx) -> String) = None
    public var message: String = "Too Many Requests"

    public init(
        max!: Int64 = 100,
        windowMs!: Int64 = 60000,
        cleanupEvery!: Int64 = 64,
        keyGenerator!: ?((Ctx) -> String) = None,
        message!: String = "Too Many Requests"
    ) {
        this.max = max
        this.windowMs = windowMs
        this.cleanupEvery = if (cleanupEvery > 0) { cleanupEvery } else { 64 }
        this.keyGenerator = keyGenerator
        this.message = message
    }
}

class RateLimitEntry {
    var count: Int64 = 0
    var resetAt: MonoTime

    init() {
        this.resetAt = MonoTime.now()
    }
}

class RateLimitSweepState {
    var cleanupTicks: Int64 = 0
}

public func rateLimitMiddleware(config!: RateLimitConfig = RateLimitConfig()): Handler {
    let store = ConcurrentHashMap<String, RateLimitEntry>()
    let mtx = Mutex()
    let sweepState = RateLimitSweepState()

    { ctx: Ctx =>
        let key = if (let Some(gen) <- config.keyGenerator) {
            gen(ctx)
        } else {
            ctx.ip
        }

        var allowed = true
        var remaining: Int64 = config.max
        var resetInMs = config.windowMs

        synchronized(mtx) {
            let now = MonoTime.now()
            sweepState.cleanupTicks += 1
            if (sweepState.cleanupTicks >= config.cleanupEvery) {
                cleanupExpiredRateLimitEntries(store, now, config.windowMs)
                sweepState.cleanupTicks = 0
            }
            let entry = if (let Some(e) <- store.get(key)) {
                let elapsed = (now - e.resetAt).toMilliseconds()
                if (elapsed >= config.windowMs) {
                    e.count = 0
                    e.resetAt = now
                }
                e
            } else {
                let e = RateLimitEntry()
                e.resetAt = now
                store.add(key, e)
                e
            }
            entry.count += 1
            remaining = config.max - entry.count
            if (remaining < 0) { remaining = 0 }
            allowed = entry.count <= config.max
            let elapsedSinceReset = (now - entry.resetAt).toMilliseconds()
            resetInMs = config.windowMs - elapsedSinceReset
            if (resetInMs < 0) {
                resetInMs = 0
            }
        }

        ctx.setHeader("X-RateLimit-Limit", "${config.max}")
        ctx.setHeader("X-RateLimit-Remaining", "${remaining}")
        ctx.setHeader("X-RateLimit-Reset", "${retryAfterSeconds(resetInMs)}")

        if (!allowed) {
            ctx.setHeader("Retry-After", "${retryAfterSeconds(resetInMs)}")
            ctx.status(429).sendString(config.message)
            return
        }
        ctx.next()
    }
}

func cleanupExpiredRateLimitEntries(
    store: ConcurrentHashMap<String, RateLimitEntry>,
    now: MonoTime,
    windowMs: Int64
): Unit {
    let staleKeys = ArrayList<String>()
    for ((entryKey, entry) in store) {
        let elapsed = (now - entry.resetAt).toMilliseconds()
        if (elapsed >= windowMs) {
            staleKeys.add(entryKey)
        }
    }
    for (entryKey in staleKeys) {
        store.remove(entryKey)
    }
}

func retryAfterSeconds(remainingMs: Int64): Int64 {
    if (remainingMs <= 0) {
        return 0
    }
    let whole = remainingMs / 1000
    if ((remainingMs % 1000) == 0) {
        return whole
    }
    whole + 1
}
