# Ignite 0.8.7 能力矩阵

这张表帮你判断一件事：哪些能力今天就能放心用，哪些还要你自己把关。它回答的是"现在可以怎样使用"，不是未来路线图。

## 状态说明

| 状态 | 含义 |
| --- | --- |
| 稳定继承 | 从 0700 延续，公开接口与常见使用方式保持可用——照旧用就行。 |
| 0800 默认 | 已进入默认主路径，背后有真实构建、测试或 socket/wire 证明，开箱即用。 |
| Preview | API 可调用、有针对性证明，适合评估或受控接入；"当前边界"栏会告诉你差在哪。 |
| 实验 | 必须显式开启。放进生产前，请先想清楚你要验证什么。 |
| Provider hold | Ignite 已留好消费位置，等外部 provider、平台或上游先交付。 |

## Server、Client 与协议

| 能力 | 状态 | 0800 行为 | 当前边界 |
| --- | --- | --- | --- |
| 路由、Group、中间件、Swagger | 稳定继承 | 延续 `App`、`Group`、洋葱中间件和 Swagger 入口。 | 不因 native transport 自动获得新的业务级并发策略。 |
| 明文 HTTP/1.1 Server | 0800 默认 | 空的 `serverPreferredBackendHint` 默认选择 Ignite native H1。 | 可用 `stdx-default` 显式回滚。 |
| HTTP/1.1 Client | Preview | `preferTransportBackend("ignite-native-h1-client")` 可显式进入 native H1，支持连接复用、流式请求体、重定向和统一错误；配合 `useNativeTls(...)` 可走 Contract-backed TLS1.3 HTTPS，并在完整消费后安全复用同源、同信任策略连接。 | `RestClient` 默认仍是稳定 stdx Client；Native HTTPS 要求调用方提供 trust anchor/hostname，部分 request hook 仍不兼容。 |
| HTTPS / TLS | 稳定继承 + Preview | 默认继续使用稳定的 stdx TLS 路径；显式 Native H1/H2 TLS1.3 会完成 ClientHello、server-flight 验证、client Finished、application-data seal/open 与有界顺序连接复用。Native TLS pool 默认 idle 上限为 30s，可通过 `nativeTlsIdleTimeout(...)` 调整，并可由 `nativeTlsRuntimeSnapshot()` 查看 H1/H2 opened/reused/retired/expired/idle 事实。 | Native TLS 当前要求调用方提供 trust anchor/hostname；快照只覆盖显式 Native TLS RestClient 池。系统 CA、TLS1.2、session resumption、0-RTT、mTLS、Native TLS H2 batch/multiplex 与默认切换仍未完成。 |
| native HTTP/2 Server | Preview | `useExperimentalNativeH2ServerEngine(app)` 可让 `App.listen(...)` 运行明文 prior-knowledge H2；低层 API 也可在 caller 提供的 `TcpSocket` 上运行单流或多流连接。 | 非默认 listener，不接受 TLS cert/key；不是浏览器 HTTPS 默认路径。 |
| native HTTP/2 Client | Preview | `RestClient` 显式选择 `ignite-native-h2-client` 后，可通过明文 prior knowledge 使用 native H2；配合 `useNativeTls(...)` 和 `h2` ALPN 可走 Contract-backed TLS1.3。普通请求支持一个公开 streamed-response lease；`sendNativeH2Batch(...)` 另提供最多 32 个同源明文 buffered 请求的单连接多路复用，并保持输入顺序返回；`openNativeH2Session(...)` 提供同源 buffered body、精确长度或 EOF 终止的 unknown-length one-pass request stream，以及独立并发 response lease。 | 必须显式选择实验 backend。普通请求仍是每连接一个公开 streamed lease；session stream 仅限 cleartext、单次消费。batch/session 不支持 TLS multiplex、retry/redirect 重放、逐 stream deadline/priority 或 request/observe/touchpoint hook。默认切换仍未完成。 |
| H2 flow control | Preview | connection/stream 双窗口、请求 DATA 暂存、`WINDOW_UPDATE` 与 SETTINGS 初始窗口恢复、并发 buffered upload、32 KiB 有界 streamed-upload producer、unknown-length EOF 收口、增量 response body 消费与 receive-window refill 已有 wire 回归。 | `RestClient` 在完整消费后才归池；提前关闭或 known-length source 早 EOF 会发送 CANCEL，并在未发完 upload 时让连接进入 retiring。当前不是零拷贝 request streaming 或最终生产级公平调度。 |
| HPACK / Huffman | Preview | Native H2 主实现包含 RFC 7541 Appendix B 的 257 项 code table、EOS/padding 校验、完整 256-octet symbol 覆盖、可变长字符串和有界动态表；outbound 仅在 Huffman 更短时启用，并对敏感 Header 使用 never-index。 | 解码后的公开 `String` 仍要求合法 UTF-8；Jingui accepted-transport compatibility parser 不是同一条完整 HPACK 路径，现有 byte profile 也不代表所有负载的吞吐收益。 |
| Native H1 WebSocket | 0800 默认 | 普通 `app.ws(...)` 在 Native H1 backend 下进入 Ignite 自研 RFC 6455 路径，支持文本、二进制、Ping/Pong、Close、分片、子协议、消息上限和并发 writer 串行化。 | 同一 API 在 `stdx-default` 下使用 compatibility backend；H2 extended CONNECT、Native WSS、permessage-deflate 和客户端 Dialer 未完成。 |
| SSE | Native H1 accepted | `ctx.sse()` 已进入 native H1 长响应主路径。 | Native H2 App adapter 尚未形成等价流式验收；显式 flush/close 的跨后端契约仍需收紧。 |

## 请求、响应与数据

| 能力 | 状态 | 0800 行为 | 当前边界 |
| --- | --- | --- | --- |
| buffered JSON | 稳定继承 | `ctx.json(String)`、`jsonSerialize(...)` 等继续适合小对象。 | 调用方必须先构造完整字符串或完整结果。 |
| streaming JSON | Native H1 accepted | `jsonWrite`、`jsonStream`、`jsonSerializeStream`、`jsonEncodeStream`、`jsonSeaStream` 可在 Native H1 边生成边写出。 | Native H2 App adapter 当前会先聚合完整响应，不能宣称 H2 真流式等价；依赖全量 body 的中间件也不自动兼容。 |
| 请求体流 | 0800 默认 | `requestBody()` 返回受 `Config.bodyLimit` 保护的流，`saveBodyToFile()` 可直接落盘。 | 流先被消费后，不承诺还能完整回放给 buffered API。 |
| 响应传输 writer | Preview | `transportWriter()` / `transportOutputStream()` 提供低层写入 seam。 | 调用方负责状态、响应头和 framing；不自动设置 H1 chunked。 |
| 静态 `.br` / `.zst` | Preview | 可根据 `Accept-Encoding` 选择预压缩副本，追求高压缩比时首选。 | 需要发布流水线预生成文件。 |
| 动态 gzip/deflate | Preview | 压缩中间件通过 Ignite 自有安全仓颉 codec 支持缓冲与增量流式响应。 | 当前优先协议正确性；高级字典、SIMD 与极致压缩比未承诺。 |
| 动态 Zstd baseline | Preview / opt-in | `CompressConfig(zstdEnabled: true)` 可协商缓冲与增量流式 `zstd` 响应；frame、128 KiB window/block、content-size 与 checksum 由安全仓颉实现。 | 当前仅生成 RAW/RLE block；可压缩同值 run，但通用 sequence/FSE/Huffman、字典、level 调优和默认选择仍未完成。 |
| 动态 Brotli baseline | Preview / opt-in | `CompressConfig(brotliEnabled: true)` 可协商缓冲与增量流式 `br` 响应；安全仓颉 encoder 使用有界 RAW metablock，并用单 literal + distance-one copy 压缩同值 run。 | 不是完整 Brotli：通用 LZ 匹配、context modeling、多符号 Huffman、静态字典、quality/window 调优和默认选择仍未完成。 |

## 运行时与依赖边界

| 能力 | 状态 | 0800 行为 | 当前边界 |
| --- | --- | --- | --- |
| server backend 选择 | 0800 默认 | 明文默认 native H1；`ServerBackendPolicy.Auto/NativeH1/Stdx` 提供类型化策略，旧字符串 hint 保持兼容。 | `NativeH1` 配合 `allowExperimentalServerBackend=true` 才允许实验 native TLS 候选。 |
| server runtime 可观测性 | 0800 默认 | `App.serverRuntimeSnapshot()` 提供最终 backend、选择/降级原因和 cleartext Native H1 连接/请求计数。 | 不覆盖 stdx、TLS、自定义 engine 或 H2；当前没有隐藏请求队列，因此 `requestQueueDepth=0`。 |
| Native TLS client pool 可观测性 | Preview | `RestClient.nativeTlsRuntimeSnapshot()` 分别报告 H1/H2 idle、opened、reused、returned、retired、expired 累计计数；`RestClient.close()` 后 idle 必须归零。 | 只描述当前 RestClient 实例的顺序池生命周期，不是 server 指标、吞吐 benchmark、公开 H2 多路 lease 或跨进程监控。 |
| 超时与 body limit | 0800 默认 | native H1 消费 `bodyLimit`、read/write/header/idle timeout。 | `readHeaderTimeout`、`idleTimeout` 当前需在构造后赋值。 |
| IoDriver / lisi | Provider hold | 已有能力描述、策略与 probe 接点；内置 stream/file/proxy 决策在 App/module 边界缓存，默认请求只投影轻量字段。 | `enableIoDriverRequestDiagnostics=true` 才恢复每请求详细事件；底层仍未替换 `std.net.TcpSocket`，不能宣称已获得 io_uring/IOCP/kqueue 的生产收益。 |
| SeaJson | 0800 默认 | `jsonSeaStream` 使用 SeaJson 原生 writer 和有界桥接。 | 兼容 stdx JSON 的入口仍保留，未做到全项目 JSON 零 stdx。 |
| stdx 总体依赖 | Provider hold | native H1/H2、SeaJson 与动态 gzip/deflate/Zstd/Brotli baseline 已缩小核心耦合。 | TLS 默认、部分 JSON/代理/平台链接仍使用 stdx。 |

## 选择建议

怎么选，按场景说：

- **新的明文 H1 服务**：直接用默认配置，留一份 `stdx-default` 回滚配置在手边。Client 想试原生实现，显式选 `ignite-native-h1-client` 或 `ignite-native-h2-client`。
- **大 JSON 数组**：优先 `jsonSeaStream`；需要 stdx `JsonWriter` 兼容时用 `jsonStream`。
- **native H2**：明文 prior knowledge 走显式 `RestClient` backend 没问题；需要 TLS/ALPN、公开多路并发或默认生产路径时，留在受控低层接入或稳定 stdx 路径——那几块还没到位。
- **生产 HTTPS**：继续默认稳定路径。别因为 0800 的标题就打开实验 backend——系统 CA 和会话恢复没完成，切了没有好处。
- **静态 Brotli/Zstd**：在构建或发布阶段预生成 `.br` / `.zst`。
- **动态 Zstd/Brotli**：分别显式设置 `zstdEnabled: true` / `brotliEnabled: true`。注意通用 buffered 数据可能因 `skipIfNoGain` 回退 identity——RAW/RLE 预览的压缩比有限，这是子集实现的正常表现，不是 bug。

更具体的签名见 [`api-0800.md`](api-0800.md)，从 0700 升级见 [`migration-0700-to-0800.md`](migration-0700-to-0800.md)。
