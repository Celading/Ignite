package ignite.middleware

import ignite.{Handler, Ctx}
import std.collection.concurrent.ConcurrentHashMap
import std.time.MonoTime
import std.sync.Mutex

public class IdempotencyConfig {
    public var headerName: String = "X-Idempotency-Key"
    public var lifetime: Duration = Duration.second * 300
    public var methods: Array<String> = ["POST", "PUT", "PATCH"]

    public init(
        headerName!: String = "X-Idempotency-Key",
        lifetime!: Duration = Duration.second * 300,
        methods!: Array<String> = ["POST", "PUT", "PATCH"]
    ) {
        this.headerName = headerName
        this.lifetime = lifetime
        this.methods = methods
    }
}

class IdempotencyEntry {
    var body: String
    var createdAt: MonoTime

    init(body: String) {
        this.body = body
        this.createdAt = MonoTime.now()
    }
}

public func idempotencyMiddleware(config!: IdempotencyConfig = IdempotencyConfig()): Handler {
    let store = ConcurrentHashMap<String, IdempotencyEntry>()
    let mtx = Mutex()

    { ctx: Ctx =>
        var isTarget = false
        for (m in config.methods) {
            if (ctx.method == m) {
                isTarget = true
                break
            }
        }

        if (!isTarget) {
            ctx.next()
            return
        }

        let key = ctx.header(config.headerName) ?? ""
        if (key.size == 0) {
            ctx.next()
            return
        }

        synchronized(mtx) {
            if (let Some(entry) <- store.get(key)) {
                let elapsed = MonoTime.now() - entry.createdAt
                if (elapsed < config.lifetime) {
                    ctx.setHeader("X-Idempotency-Cached", "true")
                    ctx.json(entry.body)
                    return
                }
                store.remove(key)
            }
        }

        ctx.next()

        if (let Some(body) <- ctx.responseBody) {
            synchronized(mtx) {
                store.add(key, IdempotencyEntry(body))
            }
        }
    }
}
