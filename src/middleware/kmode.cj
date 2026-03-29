package ignite.middleware

import ignite.{Handler, Ctx}
import ignite.governance.*
import std.time.DateTime

/// kmode（调试模式）中间件：当 kmode 为 true 时，在请求上下文中设置 local "kmode"="true"，
/// 便于后续 Handler 或中间件识别并做额外调试输出。需配合 Config.kmode 使用；启动后 Banner 等由 Config.kmode 控制。
public func kmodeMiddleware(kmode: Bool): Handler {
    let policy = KModePolicy(
        enabled: kmode,
        legacyOpen: true,
        allowIPs: ["*"],
        capabilities: [Diag, Read, Write, Admin]
    )
    kmodeMiddleware(policy)
}

public func kmodeMiddleware(policy: KModePolicy): Handler {
    let auditCfg = AuditConfig(level: 5)
    { ctx: Ctx =>
        if (!policy.enabled) {
            ctx.next()
            return
        }

        if (policy.legacyOpen) {
            ctx.setLocal("kmode", "true")
            ctx.setLocal("kmode_caps", policy.capabilitiesString())
            ctx.next()
            return
        }

        let attempted = (ctx.header(policy.headerName) ?? "").size > 0
        if (!attempted) {
            ctx.next()
            return
        }

        let authOk = policy.authorize(ctx)
        let event = AuditEvent()
        event.timestamp = DateTime.now().toString()
        event.requestId = ctx.getLocal("request_id") ?? (ctx.header("X-Request-ID") ?? "-")
        event.actor = ctx.header("X-Actor-ID") ?? "anonymous"
        event.ip = ctx.ip
        event.route = ctx.path
        event.action = "KMODE_AUTH"
        event.kmode = authOk
        event.session = ctx.getLocal("session_id") ?? "-"
        if (authOk) {
            event.result = "allow"
            event.detail = "kmode granted"
            event.riskLevel = 4
            ctx.setLocal("kmode", "true")
            ctx.setLocal("kmode_caps", policy.capabilitiesString())
            emitAudit(event, config: auditCfg)
            ctx.next()
        } else {
            event.result = "deny"
            event.detail = "kmode denied: invalid key or source ip"
            event.riskLevel = 2
            emitAudit(event, config: auditCfg)
            ctx.status(403).sendString("Forbidden - Invalid KMode policy")
        }
    }
}
