package ignite.middleware

import ignite.{Handler, Ctx}

/// kmode（调试模式）中间件：当 kmode 为 true 时，在请求上下文中设置 local "kmode"="true"，
/// 便于后续 Handler 或中间件识别并做额外调试输出。需配合 Config.kmode 使用；启动后 Banner 等由 Config.kmode 控制。
public func kmodeMiddleware(kmode: Bool): Handler {
    { ctx: Ctx =>
        if (kmode) {
            ctx.setLocal("kmode", "true")
        }
        ctx.next()
    }
}
