# Advanced

## 自定义 Logger

如果默认日志输出不够，你可以自己实现 `Logger` 接口，再通过 `LoggerConfig` 注入到 `loggerMiddleware`。

```cangjie
public class MyLogger: Logger {
    public func log(msg: String) {
        println("[MyLogger] " + msg)
    }
}

let loggerConfig = LoggerConfig(logger: MyLogger())
app.use(loggerMiddleware(config: loggerConfig))
```

如果你需要结构化日志，也可以启用 JSON 行输出，把数据继续送到外部日志系统。

### `Socket is closed` 警告分类

如果日志里出现类似下面的 stdx 输出：

```text
WARN [HttpEngineConn1#readRequest] exception: ConnectionException: Socket is closed.
```

先不要直接把它当成 Ignite handler 失败。`HttpEngineConn1#readRequest` 不是 Ignite 源码符号，这类日志通常来自底层 `stdx.net.http` 读请求阶段。

| 场景 | 判断 | 建议 |
|------|------|------|
| 浏览器刷新、关闭标签页、keep-alive 连接被客户端回收 | 多数是良性噪声 | 只观察是否伴随业务失败 |
| 服务 reload / shutdown 时仍有连接在读 | 可预期竞态 | 和启动/停机时间线一起看 |
| 压测客户端主动 abort 或超时 | 压测侧行为 | 同步看客户端错误率和服务端成功响应数 |
| 同时出现请求丢失、响应中断、固定接口必现 | 可行动传输问题 | 保留完整请求、响应、协议、并发数、超时配置再开复现单 |

这份分类不是 stdx 日志级别修复；IgniteNEXT 当前只提供诊断口径和后续自研传输门禁，不会在框架层静默吞掉未知传输异常。

## WebSocket

Ignite 提供直接的 WebSocket 入口：

```cangjie
app.ws("/chat", { conn =>
    while (true) {
        let msg = conn.readMessage()
        if (msg.isClose) { break }
        if (msg.isText) {
            conn.writeText("Echo: ${msg.text()}")
        }
    }
    conn.close()
})
```

需要更大的入站消息时，显式给出边界：

```cangjie
app.ws(
    "/chat",
    WebSocketOptions(maxIncomingMessageBytes: 4 * 1024 * 1024),
    { conn =>
        let msg = conn.readMessage()
        if (msg.isText) { conn.writeText(msg.text()) }
    }
)
```

默认入站上限是 `1 MiB`。同一连接保持一个活动 `readMessage()`；多个 writer
可以并发调用，Ignite 会按完整帧串行写出。当前 Native 路径适合聊天室、实时
通知、设备控制面等 H1 场景，但不等同于 H2 extended CONNECT、WSS 或
permessage-deflate。

## SSE

如果你只是单向推送事件，SSE 往往比 WebSocket 更轻：

```cangjie
app.get("/events", { ctx =>
    let sse = ctx.sse()
    sse.sendRetry(3000)
    sse.sendHeartbeat("ready")
    sse.sendEvent(#"{"count":1}"#, event: "counter", id: "1")
})
```

当前这条公开面要诚实说明三点：

- Ignite 现在会给 SSE 路径补 `X-Accel-Buffering: no`，并提供最小 heartbeat comment helper，避免常见代理缓冲误导。
- 0800 的 `SseWriter`、`ResponseWriter` 和 `ResponseTransportOutputStream`
  已提供显式 flush 与幂等 response-close；close 后继续写入会失败，但 close
  不会接管或关闭物理连接。
- 在显式 Native H2 ServerEngine 下，公开 SSE 的每次 retry、comment/heartbeat
  与 event 写入都会经 connection/stream 双窗口送到 wire 后才返回；显式
  `close()` 会在 handler 返回前发送该响应的 END_STREAM，但不会关闭物理连接。
  自动 heartbeat 调度、断线重连与 Last-Event-ID 状态仍由应用负责。
- stdx compatibility backend 仍没有更强的公开 flush 原语；不要把上述 Native
  H2 wire 保证外推成所有后端的统一 drain 保证。

## 流式响应

对于边生成边输出的响应，可以直接拿到 writer：

```cangjie
app.get("/stream", { ctx =>
    let writer = ctx.writer()
    writer.writeString("chunk 1\n")
    writer.writeString("chunk 2\n")
    writer.writeString("chunk 3\n")
})
```

这里要把协议语义分清：

- `ctx.writer()` 表示“增量写响应体”，不是“强行给所有协议都套上 chunked”。
- HTTP/1.1 下，这条路径可以继续表现为 chunked 语义。
- HTTP/2 下，不能再发 `Transfer-Encoding`；Ignite 现在只在非 H2 路径补这个头。
- Ignite Native H2 App adapter 的直接 writer 已有 handler-time HEADERS、双窗口
  DATA 与显式 END_STREAM 的真实 wire 回归；
  `transportWriterWithTransform(...)` 的 write/flush/close-tail 也有同一路径
  的线级证明。这不等于 stdx、自定义 carrier 或 TLS server 路径自动获得
  相同证明。

## 静态文件

如果只是做简单静态目录映射，使用 `app.static(prefix, root)` 即可。

它适合：

- 文档附件
- 前端打包产物里的固定资源
- 管理页依赖的小体量静态文件

## `staticSpa`

当你需要“有文件就发文件，没有文件就回退 `index.html`”时，用 `staticSpa`：

```cangjie
app.staticSpa("/", "frontend/out", "index.html")
```

当前公开语义里要特别记住两点：

- 路径匹配顺序仍然遵循 Ignite 正常路由顺序，所以通常应把 `staticSpa` 放在较后面。
- 出于安全考虑，含 `..` 的路径不会被当作普通静态文件放行。

## IgniteKit

`IgniteKit` 适合把轻量 HTML / CSS / 动态页面资源从主业务路由里剥离出来：

```cangjie
let kit = IgniteKit(prefix: "/web")
_ = kit.css("/app.css", "body{font-family:monospace;}")
_ = kit.html("/index.html", "<h1>{{title}}</h1>", vars: [("title", "IgniteKit")])
_ = kit.dynamicHtml("/hello.html", { ctx =>
    let name = (ctx.queryFromUrl("name") ?? "ignite").trimAscii()
    kit.renderTemplate("<h1>Hello, {{name}}</h1>", vars: [("name", name)])
})
_ = kit.mount(app)
```

它适合：

- 运维页
- 管理后台小页面
- 快速验证 SSR 前的轻量页面
- 小体量动态资源映射

当前 `0500` 阶段里，IgniteKit 仍然留在 Ignite 主仓公开能力内，不在这一轮文档里提前展开拆包叙事。

## Swagger / OpenAPI

Swagger 是 `0500` 阶段非常重要的一条公开能力。

```cangjie
let app = App(config: Config(
    enableSwagger: true,
    swaggerPath: "/swagger",
    enablePrintSwaggerUrl: true,
    kmode: true
))
```

三个公开配置点要分清：

- `enableSwagger`：控制 Swagger UI 与 OpenAPI JSON 路由是否存在
- `swaggerPath`：同时控制 UI 路径与 `${swaggerPath}/json`
- `enablePrintSwaggerUrl`：只控制启动时是否打印 `Swagger UI: ...` 这一行

如果你给路由配置了 `RequestBodySpec`、`ResponseSpec`、`TestOption`，这些信息会进入 `InterfaceSpec` 和最终的 OpenAPI 输出。

当前公开边界还要记住：

- `x-ignite-test` 是接口元数据，不是生产自动化开关
- 运行态自检只在 `Config.kmode = true` 时生效
- 自检可通过 Header `x-ignite-test` 或 Query `__ignite_test` / `__igtest` 触发

## TLS / HTTPS

Ignite 现在支持 HTTPS，但公开文档要把边界说清楚。

```cangjie
let app = App(config: Config(
    tlsCertFile: "./cert.pem",
    tlsKeyFile: "./key.pem",
    enableTlsPrecheck: true
))

app.listen("0.0.0.0", 443)
```

当前公开主线是：

- 默认 HTTPS 路径仍以 `stdx` TLS 构造为准
- `enableTlsPrecheck` 默认开启，会先做 `jinguissl` 预检，再进入当前 TLS 构造路径；当前主线会把原始 PEM/DER key 包在一个轻量 `PrivateKey` wrapper 里交给 TLS native 层，避免在已知 runtime lane 上直接落回 `GeneralPrivateKey.describe()` 崩溃点
- `jinguissl` 当前不是默认 HTTPS 监听替代方案
- 如果你要更稳妥的生产接入，仍可优先考虑现有默认路径或在反向代理层完成 TLS 终结

IG0800 preview 中，明文 HTTP/1.1 默认使用 Ignite native H1；如需显式回滚
到 stdx server，新代码可设置 `serverBackendPolicy: ServerBackendPolicy.Stdx`，
旧的 `serverPreferredBackendHint: "stdx-default"` 仍保持兼容。native TLS
仍是实验入口，只有同时设置 `serverBackendPolicy: ServerBackendPolicy.NativeH1` 与
`allowExperimentalServerBackend: true` 才会启用，不能据此宣称浏览器级 TLS/H2
兼容已经完成。

运行中可通过 `app.serverRuntimeSnapshot()` 读取最终 backend、选择/降级原因和
cleartext Native H1 生命周期计数。该快照不会把 stdx、TLS 或 H2 的状态映射成
Native H1 指标；需要每请求 IoDriver 详细事件时再显式开启
`enableIoDriverRequestDiagnostics`，默认热路径只保留选择 backend、公开路径和
transfer shape 三个轻量字段。

显式 Native TLS `RestClient` 另有独立的池生命周期边界：默认 idle 上限为
`30s`，可用 `nativeTlsIdleTimeout(...)` 调整。`nativeTlsRuntimeSnapshot()`
分别给出 H1/H2 的 idle、opened、reused、returned、retired、expired 计数。
这能区分“连接正在复用”“因 idle 过期被淘汰”“调用 `close()` 后仍有 idle
连接”等问题，但不代表 server 侧 TLS/H2 指标、浏览器兼容或公开 H2 多路并发。
本地加固探针见
[`manual/samples/native_tls_pool_hardening`](../samples/native_tls_pool_hardening/README.md)。

部署时还要特别注意：

- 一次 `app.listen(addr, port)` 只对应一条监听器
- 如果你同时需要 HTTP 与 HTTPS，当前更推荐反向代理、两个实例，或参考 [`manual/samples/dualport`](../samples/README.md) 的验证思路，而不是假定框架会自动双端口编排

如果证书链没问题，开启 TLS 后服务端会协商 HTTP/2 ALPN；这属于当前默认路径的一部分，但不代表已经进入更激进的传输演进承诺。

## 优雅关闭与错误收口

Ignite 支持统一错误处理和关闭钩子：

```cangjie
app.onError({ ctx, err =>
    println("[Error] ${err.message}")
    ctx.status(500).json(#"{"error":"${err.message}"}"#)
})

app.onShutdown({
    println("Releasing resources...")
})
```

建议把这些钩子视作服务生命周期的一部分，而不是最后补丁：

- `onError` 负责统一错误语义
- `onShutdown` 负责资源释放与退出前清理
