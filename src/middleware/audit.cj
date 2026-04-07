package ignite.middleware

import ignite.{Handler, Ctx}
import ignite.governance.*
import std.time.MonoTime
import std.time.DateTime

public class AuditMiddlewareConfig {
    public var enabled: Bool = true
    public var actorHeaderName: String = "X-Actor-ID"
    public var requestIdHeaderName: String = "X-Request-ID"
    public var auditConfig: AuditConfig = AuditConfig()

    public init(
        enabled!: Bool = true,
        actorHeaderName!: String = "X-Actor-ID",
        requestIdHeaderName!: String = "X-Request-ID",
        auditConfig!: AuditConfig = AuditConfig()
    ) {
        this.enabled = enabled
        this.actorHeaderName = actorHeaderName
        this.requestIdHeaderName = requestIdHeaderName
        this.auditConfig = auditConfig
    }
}

public func auditMiddleware(config!: AuditMiddlewareConfig = AuditMiddlewareConfig()): Handler {
    { ctx: Ctx =>
        if (!config.enabled) {
            ctx.next()
            return
        }

        let start = MonoTime.now()
        ctx.next()
        let elapsed = MonoTime.now() - start

        let event = AuditEvent()
        event.timestamp = DateTime.now().toString()
        let requestIdLocal = ctx.getLocal("request_id")
        let requestIdHeader = ctx.header(config.requestIdHeaderName) ?? "-"
        event.requestId = requestIdLocal ?? requestIdHeader
        let actorLocal = ctx.getLocal("actor")
        let actorHeader = ctx.header(config.actorHeaderName) ?? "anonymous"
        event.actor = actorLocal ?? actorHeader
        event.ip = ctx.ip
        event.route = ctx.path
        event.action = auditAction(ctx.method, ctx.path)
        event.result = if (ctx.responseStatus >= 400) { "deny" } else { "allow" }
        event.riskLevel = riskByStatus(ctx.responseStatus)
        event.kmode = (ctx.getLocal("kmode") ?? "false") == "true"
        event.session = ctx.getLocal("session_id") ?? "-"
        event.statusCode = ctx.responseStatus
        event.latencyMs = elapsed.toMilliseconds()
        event.guardEvent = ctx.getLocal("__ignite_guard_event") ?? ""
        event.guardExitCause = ctx.getLocal("__ignite_guard_exit_cause") ?? ""
        event.securityEvent = ctx.getLocal("__ignite_sec_event") ?? ""
        event.securityCode = ctx.getLocal("__ignite_sec_code") ?? ""
        event.securitySource = ctx.getLocal("__ignite_sec_source") ?? ""
        if (event.detail.size == 0) {
            event.detail = ctx.getLocal("__ignite_guard_detail") ?? ""
        }
        if (event.detail.size == 0) {
            event.detail = ctx.getLocal("__ignite_sec_detail") ?? ""
        }
        if (event.securityEvent.size > 0 && event.riskLevel > 2) {
            event.riskLevel = 2
        }
        emitAudit(event, config: config.auditConfig)
        ctx.setLocal("audit_event_id", event.eventId)
    }
}
