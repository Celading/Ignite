package ignite.middleware

import ignite.{Handler, Ctx}

public class RecoverConfig {
    public var enableStackTrace: Bool = false
    public var customHandler: ?((Ctx, Exception) -> Unit) = None

    public init(enableStackTrace!: Bool = false, customHandler!: ?((Ctx, Exception) -> Unit) = None) {
        this.enableStackTrace = enableStackTrace
        this.customHandler = customHandler
    }
}

public func recoverMiddleware(config!: RecoverConfig = RecoverConfig()): Handler {
    { ctx: Ctx =>
        try {
            ctx.next()
        } catch (e: Exception) {
            if (let Some(handler) <- config.customHandler) {
                handler(ctx, e)
            } else {
                println("[Ignite Recovery] Panic recovered: ${e.message}")
                let _ = ctx.status(500).sendString("Internal Server Error")
            }
        }
    }
}
