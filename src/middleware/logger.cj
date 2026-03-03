package ignite.middleware

import ignite.{Handler, Ctx}
import std.time.MonoTime

public class LoggerConfig {
    public var format: String = "[method] path - status latency"
    public var timeFormat: String = "ms"
    public var output: (String) -> Unit = { msg => println(msg) }

    public init(output!: (String) -> Unit = { msg => println(msg) }) {
        this.output = output
    }
}

public func loggerMiddleware(config!: LoggerConfig = LoggerConfig()): Handler {
    { ctx: Ctx =>
        let start = MonoTime.now()
        let method = ctx.method
        let path = ctx.path

        ctx.next()

        let elapsed = MonoTime.now() - start
        let latencyMs = elapsed.toMilliseconds()
        let msg = "[${method}] ${path} ${latencyMs}ms"
        config.output(msg)
    }
}
