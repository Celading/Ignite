package ignite.middleware

import ignite.{Handler, Ctx}
import ignite.governance.{
    KModeFailoverOption,
    KModeFailoverDecision,
    KModeFailoverResult,
    runKModeFailover
}

public type RecoverKModeFailoverHook = (Ctx, Exception, KModeFailoverResult) -> Unit

public class RecoverConfig {
    public var enableStackTrace: Bool = false
    public var customHandler: ?((Ctx, Exception) -> Unit) = None
    public var kmodeFailover: ?KModeFailoverOption = None
    public var onKModeRestart: ?RecoverKModeFailoverHook = None
    public var onKModeTerminate: ?RecoverKModeFailoverHook = None

    public init(
        enableStackTrace!: Bool = false,
        customHandler!: ?((Ctx, Exception) -> Unit) = None,
        kmodeFailover!: ?KModeFailoverOption = None,
        onKModeRestart!: ?RecoverKModeFailoverHook = None,
        onKModeTerminate!: ?RecoverKModeFailoverHook = None
    ) {
        this.enableStackTrace = enableStackTrace
        this.customHandler = customHandler
        this.kmodeFailover = kmodeFailover
        this.onKModeRestart = onKModeRestart
        this.onKModeTerminate = onKModeTerminate
    }
}

public func recoverMiddleware(config!: RecoverConfig = RecoverConfig()): Handler {
    { ctx: Ctx =>
        try {
            ctx.next()
        } catch (e: Exception) {
            if (let Some(result) <- runFailoverIfNeeded(ctx, e, config)) {
                if (result.decision == KModeFailoverDecision.Restart) {
                    handleRestartDecision(ctx, e, result, config)
                    return
                }
                if (result.decision == KModeFailoverDecision.Terminate) {
                    handleTerminateDecision(ctx, e, result, config)
                    return
                }
            }

            if (let Some(handler) <- config.customHandler) {
                handler(ctx, e)
            } else {
                println("[Ignite Recovery] Panic recovered: ${e.message}")
                let _ = ctx.status(500).sendString("Internal Server Error")
            }
        }
    }
}

func runFailoverIfNeeded(ctx: Ctx, e: Exception, config: RecoverConfig): ?KModeFailoverResult {
    if (!ctx.app().config.kmode) {
        return None
    }
    if (let Some(option) <- config.kmodeFailover) {
        let reason = "panic:${ctx.method}:${ctx.path}:${e.message}"
        return Some(runKModeFailover(option, reason))
    }
    None
}

func handleRestartDecision(
    ctx: Ctx,
    e: Exception,
    result: KModeFailoverResult,
    config: RecoverConfig
): Unit {
    println("[Ignite Recovery] KMode failover decision=restart attempts=${result.attempts} lastStatus=${result.lastStatus}")
    let _ = ctx.status(503).sendString("Service Restart Requested")
    if (let Some(hook) <- config.onKModeRestart) {
        hook(ctx, e, result)
    } else {
        ctx.app().shutdown()
    }
}

func handleTerminateDecision(
    ctx: Ctx,
    e: Exception,
    result: KModeFailoverResult,
    config: RecoverConfig
): Unit {
    println("[Ignite Recovery] KMode failover decision=terminate attempts=${result.attempts} lastStatus=${result.lastStatus}")
    let _ = ctx.status(503).sendString("Service Terminated by KMode Failover")
    if (let Some(hook) <- config.onKModeTerminate) {
        hook(ctx, e, result)
    } else {
        ctx.app().shutdown()
    }
}
