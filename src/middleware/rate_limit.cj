package ignite.middleware

import ignite.{Handler, Ctx}
import std.collection.concurrent.ConcurrentHashMap
import std.time.MonoTime
import std.sync.Mutex

public class RateLimitConfig {
    public var max: Int64 = 100
    public var windowMs: Int64 = 60000
    public var keyGenerator: ?((Ctx) -> String) = None
    public var message: String = "Too Many Requests"

    public init(
        max!: Int64 = 100,
        windowMs!: Int64 = 60000,
        keyGenerator!: ?((Ctx) -> String) = None,
        message!: String = "Too Many Requests"
    ) {
        this.max = max
        this.windowMs = windowMs
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

public func rateLimitMiddleware(config!: RateLimitConfig = RateLimitConfig()): Handler {
    let store = ConcurrentHashMap<String, RateLimitEntry>()
    let mtx = Mutex()

    { ctx: Ctx =>
        let key = if (let Some(gen) <- config.keyGenerator) {
            gen(ctx)
        } else {
            ctx.ip
        }

        var allowed = true
        var remaining: Int64 = config.max

        synchronized(mtx) {
            let now = MonoTime.now()
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
        }

        ctx.setHeader("X-RateLimit-Limit", "${config.max}")
        ctx.setHeader("X-RateLimit-Remaining", "${remaining}")

        if (!allowed) {
            ctx.status(429).sendString(config.message)
            return
        }
        ctx.next()
    }
}
