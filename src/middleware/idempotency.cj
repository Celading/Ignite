package ignite.middleware

import ignite.{Handler, Ctx}
import std.collection.ArrayList
import std.collection.concurrent.ConcurrentHashMap
import std.time.MonoTime
import std.sync.Mutex

public class IdempotencyConfig {
    public var headerName: String = "X-Idempotency-Key"
    public var lifetime: Duration = Duration.second * 300
    public var methods: Array<String> = ["POST", "PUT", "PATCH"]
    public var cleanupEvery: Int64 = 64

    public init(
        headerName!: String = "X-Idempotency-Key",
        lifetime!: Duration = Duration.second * 300,
        methods!: Array<String> = ["POST", "PUT", "PATCH"],
        cleanupEvery!: Int64 = 64
    ) {
        this.headerName = headerName
        this.lifetime = lifetime
        this.methods = methods
        this.cleanupEvery = if (cleanupEvery > 0) { cleanupEvery } else { 64 }
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

class IdempotencySweepState {
    var cleanupTicks: Int64 = 0
}

public func idempotencyMiddleware(config!: IdempotencyConfig = IdempotencyConfig()): Handler {
    let store = ConcurrentHashMap<String, IdempotencyEntry>()
    let mtx = Mutex()
    let sweepState = IdempotencySweepState()

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
            let now = MonoTime.now()
            sweepState.cleanupTicks += 1
            if (sweepState.cleanupTicks >= config.cleanupEvery) {
                cleanupExpiredIdempotencyEntries(store, now, config.lifetime)
                sweepState.cleanupTicks = 0
            }
            if (let Some(entry) <- store.get(key)) {
                let elapsed = now - entry.createdAt
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

func cleanupExpiredIdempotencyEntries(
    store: ConcurrentHashMap<String, IdempotencyEntry>,
    now: MonoTime,
    lifetime: Duration
): Unit {
    let staleKeys = ArrayList<String>()
    for ((entryKey, entry) in store) {
        if ((now - entry.createdAt) >= lifetime) {
            staleKeys.add(entryKey)
        }
    }
    for (entryKey in staleKeys) {
        store.remove(entryKey)
    }
}
