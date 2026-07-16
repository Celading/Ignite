# Ignite 0.8.1 能力矩阵

这张表描述 `IgniteNEXT` 当前 `0.8.1 Preview` 的公开能力状态。它回答的是“现在可以怎样使用”，不是未来路线图。

## 状态说明

| 状态 | 含义 |
| --- | --- |
| 稳定继承 | 从 0700 延续，公开接口与常见使用方式保持可用。 |
| 0800 默认 | 0800 已把该实现放到默认主路径，并有真实构建、测试或 socket/wire 证明。 |
| Preview | 已有可调用 API 和针对性证明，适合评估或受控接入，但仍有明确兼容边界。 |
| 实验 | 必须显式开启，尚不建议作为通用生产默认。 |
| Provider hold | Ignite 已留出消费位置，但完整能力仍受外部 provider、平台或上游实现约束。 |

## Server、Client 与协议

| 能力 | 状态 | 0800 行为 | 当前边界 |
| --- | --- | --- | --- |
| 路由、Group、中间件、Swagger | 稳定继承 | 延续 `App`、`Group`、洋葱中间件和 Swagger 入口。 | 不因 native transport 自动获得新的业务级并发策略。 |
| 明文 HTTP/1.1 Server | 0800 默认 | 空的 `serverPreferredBackendHint` 默认选择 Ignite native H1。 | 可用 `stdx-default` 显式回滚。 |
| HTTP/1.1 Client | Preview | `preferTransportBackend("ignite-native-h1-client")` 可显式进入 native H1，支持连接复用、流式请求体、重定向和统一错误。 | `RestClient` 默认仍是稳定 stdx Client；native H1 当前仅支持 `http://`，部分 request hook 仍不兼容。 |
| HTTPS / TLS | 稳定继承 | 默认继续使用稳定的 stdx TLS 路径；JinguiSSL Contract 用于契约与预检。 | native TLS listener/client 仍是显式实验候选。 |
| native HTTP/2 Server | Preview | `ignite.native_h2` 可在 caller 提供的 `TcpSocket` 上运行单流或多流连接，并可接入 `App`。 | 非默认 listener；未完成完整浏览器矩阵、h2spec、动态 HPACK table。 |
| native HTTP/2 Client | Preview | 可在已连接 socket 上发送单请求、批量复用或复用 `NativeH2ClientConnection`。 | caller 负责 connect、TLS/ALPN、timeout 和物理 close；不是稳定 `RestClient` 替代。 |
| H2 flow control | Preview | connection/stream 双窗口、DATA 暂存与 `WINDOW_UPDATE` 恢复已有 wire 回归。 | 当前响应仍以内存 body 模型为主，未宣称全场景零拷贝。 |
| WebSocket | 0800 默认 | H1 native upgrade 支持文本、二进制、Ping/Pong、Close、分片与子协议选择。 | H2 extended CONNECT 尚未提供。 |
| SSE | 0800 默认 | `ctx.sse()` 进入 native H1 长响应主路径。 | 显式 flush/close 的跨后端一致契约仍需继续收紧。 |

## 请求、响应与数据

| 能力 | 状态 | 0800 行为 | 当前边界 |
| --- | --- | --- | --- |
| buffered JSON | 稳定继承 | `ctx.json(String)`、`jsonSerialize(...)` 等继续适合小对象。 | 调用方必须先构造完整字符串或完整结果。 |
| streaming JSON | 0800 默认 | `jsonWrite`、`jsonStream`、`jsonSerializeStream`、`jsonEncodeStream`、`jsonSeaStream` 可边生成边写出。 | 不设置完整 `ctx.responseBody`；依赖全量 body 的缓存、ETag、幂等等中间件不自动兼容。 |
| 请求体流 | 0800 默认 | `requestBody()` 返回受 `Config.bodyLimit` 保护的流，`saveBodyToFile()` 可直接落盘。 | 流先被消费后，不承诺还能完整回放给 buffered API。 |
| 响应传输 writer | Preview | `transportWriter()` / `transportOutputStream()` 提供低层写入 seam。 | 调用方负责状态、响应头和 framing；不自动设置 H1 chunked。 |
| 静态 `.br` / `.zst` | Preview | 可根据 `Accept-Encoding` 选择预压缩副本。 | 这是静态交付，不代表内置 Brotli/Zstd 动态 codec 已完成。 |
| 动态 gzip/deflate | Preview | 压缩中间件通过 Ignite 自有安全仓颉 codec 支持缓冲与增量流式响应。 | 当前优先协议正确性；高级字典、SIMD 与极致压缩比未承诺。 |

## 运行时与依赖边界

| 能力 | 状态 | 0800 行为 | 当前边界 |
| --- | --- | --- | --- |
| server backend 选择 | 0800 默认 | 明文默认 native H1；`stdx-default` 可回滚。 | `native-h1` 配合 `allowExperimentalServerBackend=true` 才允许实验 native TLS 候选。 |
| 超时与 body limit | 0800 默认 | native H1 消费 `bodyLimit`、read/write/header/idle timeout。 | `readHeaderTimeout`、`idleTimeout` 当前需在构造后赋值。 |
| IoDriver / lisi | Provider hold | 已有能力描述、策略与 probe 接点。 | 未替换底层 `std.net.TcpSocket`，不能宣称已获得 io_uring/IOCP/kqueue 的生产收益。 |
| SeaJson | 0800 默认 | `jsonSeaStream` 使用 SeaJson 原生 writer 和有界桥接。 | 兼容 stdx JSON 的入口仍保留，未做到全项目 JSON 零 stdx。 |
| stdx 总体依赖 | Provider hold | native H1/H2、SeaJson 与动态 gzip/deflate 已缩小核心耦合。 | TLS 默认、部分 JSON/代理/平台链接仍使用 stdx。 |

## 选择建议

- 新的明文 H1 服务可直接使用默认配置，并保留一条 `stdx-default` 回滚配置；Client 需要显式选择 `ignite-native-h1-client` 才进入 Preview。
- 大 JSON 数组优先使用 `jsonSeaStream`；需要 stdx `JsonWriter` 兼容时使用 `jsonStream`。
- native H2 只在能自行管理 socket、超时和 TLS/ALPN 的受控组件中接入。
- HTTPS 生产服务继续使用默认稳定路径，不要仅因为 0800 标题就强制打开实验 backend。
- 静态 Brotli/Zstd 需要在构建或发布阶段生成 `.br` / `.zst` 文件。

更具体的签名见 [`api-0800.md`](api-0800.md)，从 0700 升级见 [`migration-0700-to-0800.md`](migration-0700-to-0800.md)。
