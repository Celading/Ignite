package ignite.middleware

import ignite.{Handler, Ctx}
import std.time.{MonoTime, DateTime}

public class AccessLogConfig {
    public var output: (String) -> Unit = { msg => println(msg) }
    public var timeFormat: String = "yyyy-MM-dd HH:mm:ss"
    public var enableLatency: Bool = true
    public var enableIP: Bool = true
    public var enableUserAgent: Bool = false

    public init(
        output!: (String) -> Unit = { msg => println(msg) },
        timeFormat!: String = "yyyy-MM-dd HH:mm:ss",
        enableLatency!: Bool = true,
        enableIP!: Bool = true,
        enableUserAgent!: Bool = false
    ) {
        this.output = output
        this.timeFormat = timeFormat
        this.enableLatency = enableLatency
        this.enableIP = enableIP
        this.enableUserAgent = enableUserAgent
    }
}

public func accessLogMiddleware(config!: AccessLogConfig = AccessLogConfig()): Handler {
    { ctx: Ctx =>
        let start = MonoTime.now()
        let method = ctx.method
        let path = ctx.path
        let ip = ctx.ip

        ctx.next()

        let elapsed = MonoTime.now() - start
        let latencyMs = elapsed.toMilliseconds()
        let timestamp = DateTime.now().toString()

        var log = "${timestamp} | ${method} ${path}"
        if (config.enableIP) {
            log = "${timestamp} | ${ip} | ${method} ${path}"
        }
        if (config.enableLatency) {
            log += " | ${latencyMs}ms"
        }
        if (config.enableUserAgent) {
            let ua = ctx.header("user-agent") ?? "-"
            log += " | ${ua}"
        }
        config.output(log)
    }
}
