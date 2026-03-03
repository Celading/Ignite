package ignite.middleware

import ignite.{Handler, Ctx}
import std.collection.concurrent.ConcurrentHashMap
import std.time.MonoTime
import std.sync.Mutex

public class CacheConfig {
    public var expiration: Duration = Duration.second * 60
    public var keyGenerator: ?((Ctx) -> String) = None
    public var cacheControl: String = ""
    public var methods: Array<String> = ["GET"]

    public init(
        expiration!: Duration = Duration.second * 60,
        keyGenerator!: ?((Ctx) -> String) = None,
        cacheControl!: String = "",
        methods!: Array<String> = ["GET"]
    ) {
        this.expiration = expiration
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

public func cacheMiddleware(config!: CacheConfig = CacheConfig()): Handler {
    let store = ConcurrentHashMap<String, CacheEntry>()
    let mtx = Mutex()

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
            if (let Some(entry) <- store.get(key)) {
                let elapsed = MonoTime.now() - entry.createdAt
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
