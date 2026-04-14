package ignite.middleware

import ignite.{Handler, Ctx}
import std.collection.ArrayList
import std.collection.concurrent.ConcurrentHashMap
import std.time.MonoTime
import std.sync.Mutex

public class CacheConfig {
    public var expiration: Duration = Duration.second * 60
    public var cleanupEvery: Int64 = 64
    public var keyGenerator: ?((Ctx) -> String) = None
    public var cacheControl: String = ""
    public var methods: Array<String> = ["GET"]

    public init(
        expiration!: Duration = Duration.second * 60,
        cleanupEvery!: Int64 = 64,
        keyGenerator!: ?((Ctx) -> String) = None,
        cacheControl!: String = "",
        methods!: Array<String> = ["GET"]
    ) {
        this.expiration = expiration
        this.cleanupEvery = if (cleanupEvery > 0) { cleanupEvery } else { 64 }
        this.keyGenerator = keyGenerator
        this.cacheControl = cacheControl
        this.methods = methods
    }
}

class CacheEntry {
    var body: String
    var contentType: String
    var createdAt: MonoTime

    init(body: String, contentType: String) {
        this.body = body
        this.contentType = contentType
        this.createdAt = MonoTime.now()
    }
}

class CacheSweepState {
    var cleanupTicks: Int64 = 0
}

public func cacheMiddleware(config!: CacheConfig = CacheConfig()): Handler {
    let store = ConcurrentHashMap<String, CacheEntry>()
    let mtx = Mutex()
    let sweepState = CacheSweepState()

    { ctx: Ctx =>
        var isCacheable = false
        for (m in config.methods) {
            if (ctx.method == m) {
                isCacheable = true
                break
            }
        }

        if (!isCacheable) {
            ctx.next()
            return
        }

        let key = if (let Some(gen) <- config.keyGenerator) {
            gen(ctx)
        } else {
            ctx.method + ":" + ctx.path
        }

        synchronized(mtx) {
            let now = MonoTime.now()
            sweepState.cleanupTicks += 1
            if (sweepState.cleanupTicks >= config.cleanupEvery) {
                cleanupExpiredCacheEntries(store, now, config.expiration)
                sweepState.cleanupTicks = 0
            }
            if (let Some(entry) <- store.get(key)) {
                let elapsed = now - entry.createdAt
                if (elapsed < config.expiration) {
                    ctx.setHeader("X-Cache", "HIT")
                    if (config.cacheControl.size > 0) {
                        ctx.setHeader("Cache-Control", config.cacheControl)
                    }
                    ctx.setHeader("content-type", entry.contentType)
                    ctx.sendString(entry.body)
                    return
                }
                store.remove(key)
            }
        }

        ctx.setHeader("X-Cache", "MISS")
        ctx.next()

        if (let Some(body) <- ctx.responseBody) {
            let ct = ctx.header("content-type") ?? "text/plain"
            synchronized(mtx) {
                store.add(key, CacheEntry(body, ct))
            }
        }
    }
}

func cleanupExpiredCacheEntries(
    store: ConcurrentHashMap<String, CacheEntry>,
    now: MonoTime,
    expiration: Duration
): Unit {
    let staleKeys = ArrayList<String>()
    for ((entryKey, entry) in store) {
        if ((now - entry.createdAt) >= expiration) {
            staleKeys.add(entryKey)
        }
    }
    for (entryKey in staleKeys) {
        store.remove(entryKey)
    }
}
