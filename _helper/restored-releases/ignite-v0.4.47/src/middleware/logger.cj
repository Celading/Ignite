package ignite.middleware

import ignite.{Handler, Ctx}
import std.time.MonoTime

/// Logger 接口：可由用户自定义实现并注入到 LoggerConfig，实现可覆写。
public interface Logger {
    func log(message: String): Unit
}

/// 默认 Logger 实现，可覆写 output 或子类覆写 log 以自定义输出。
public class DefaultLogger <: Logger {
    public var output: (String) -> Unit = { msg => println(msg) }

    public init(output!: (String) -> Unit = { msg => println(msg) }) {
        this.output = output
    }

    public override func log(message: String): Unit {
        output(message)
    }
}

/// 实体日志条目，用于 enableEntityLog 时的结构化记录。
public struct LogEntry {
    public let method: String
    public let path: String
    public let latencyMs: Int64

    public init(method: String, path: String, latencyMs: Int64) {
        this.method = method
        this.path = path
        this.latencyMs = latencyMs
    }
}

public class LoggerConfig {
    public var format: String = "[method] path - status latency"
    public var timeFormat: String = "ms"
    /// 使用接口 Logger，默认 DefaultLogger；可注入自定义实现。
    public var logger: Logger = DefaultLogger()
    /// 为 true 时以实体形式记录（method=GET path=/ latencyMs=...），否则为单行 [method] path latencyMs。
    public var enableEntityLog: Bool = false

    public init(logger!: Logger = DefaultLogger(), enableEntityLog!: Bool = false) {
        this.logger = logger
        this.enableEntityLog = enableEntityLog
    }

    /// 兼容旧用法：仅传 output 时使用 DefaultLogger(output)。
    public init(output!: (String) -> Unit, enableEntityLog!: Bool = false) {
        this.logger = DefaultLogger(output: output)
        this.enableEntityLog = enableEntityLog
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

        if (config.enableEntityLog) {
            let msg = "method=${method} path=${path} latencyMs=${latencyMs}"
            config.logger.log(msg)
        } else {
            let msg = "[${method}] ${path} ${latencyMs}ms"
            config.logger.log(msg)
        }
    }
}
