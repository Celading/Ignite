# Ignite 0.8.7 Preview

`0.8.7` 将已接受的 `036383d` 开发检查点提升到 0800 发布线。在 `0.8.2` 的 Native TLS 生命周期、Native H1 可观测性、断连收敛、query 单次解码和 WebSocket production-core 之上，本版补齐完整 HPACK Huffman、有界动态表、Native TLS H2 ingress、H2 response streaming/drain、cleartext/TLS multiplex session、精确长度与未知长度 one-pass request stream，以及 H2 `jsonWrite` 有界流式写出；同时消费 lisi transport contract，并收紧压缩 identity refusal 与 private precompressed trust 边界。

一句话概括这条线的原则：**只开放已经在真实 socket/wire 回归里跑通的能力，并且每一项都留着回滚路径。** 它不是"已经完全脱离 stdx"或"全部协议都已 LTS"的宣言。

配套入口：

- [`capability-matrix-0800.md`](capability-matrix-0800.md)：完整能力状态与 stdx 残留。
- [`api-0800.md`](api-0800.md)：0800 新增 API 签名和调用边界。
- [`migration-0700-to-0800.md`](migration-0700-to-0800.md)：从 0.7.7 升级的回归顺序。

几个反复出现的词，先说清楚：

- **backend hint**：`Config` 里选择传输引擎的开关；留空就用当前默认。
- **prior knowledge**：跳过协议协商、直接按 H2 说话的明文接入方式。
- **response lease**：流式响应的"租约"——你拿着流在读，连接就先归你，读完才回池。
- **trust anchor**：你显式提供的信任根证书；原生 TLS 不会替你读系统 CA。
- **Provider hold**：Ignite 已留好消费位置，但要等外部依赖方（如 lisi、JinguiSSL）先交付。

## 依赖接入

中心仓当前提供稳定版 `0.7.7`，不提供 0800 Preview：

```toml
[dependencies]
ignite = "0.7.7"
```

0800 Preview 必须选择一个托管源并固定 `ig0800` 分支：

```toml
# GitCode
[dependencies]
ignite = { git = "https://gitcode.com/cinyu/ignite-cangjie.git", branch = "ig0800" }
```

```toml
# GitHub
[dependencies]
ignite = { git = "https://github.com/Celading/Ignite.git", branch = "ig0800" }
```

包键必须是小写 `ignite`，且一个项目只能选择一个来源。普通消费者不要重复声明传递依赖。发布维护者需要锁定 provider 时，可按下表选择对应托管源：

| 包键 | GitCode | GitHub | 0800 发布消费状态 |
| --- | --- | --- | --- |
| `jinguissl` | `https://gitcode.com/cinyu/jinguiSSL.git` | `https://github.com/Celading/JinguiSSL.git` | 两端可解析。 |
| `seajson` | `https://gitcode.com/CjKu/SeaJson.git` | `https://github.com/Celading/SeaJson.git` | 两端可解析。 |
| `lisi` | `https://gitcode.com/cinyu/lisi.git` | `https://github.com/Celading/lisi.git` | 当前发布固定 GitCode `lio-j002-provider-contract-v1`；GitHub 仓存在但没有可消费 HEAD。 |

完整安装与中心仓配置见 [`Guide.md`](Guide.md)。

## 默认运行时

### 明文 HTTP/1.1

明文 `App.listen(...)` 默认选择 Ignite native H1。当前已经覆盖：

- 多连接并行推进与请求体上限
- socket read/write timeout
- Content-Length 与 chunked 请求/响应
- 流式响应、HEAD、静态文件与 Range
- 可显式选择的 native H1 Client：连接复用、流式 body、重定向与统一错误分类
- WebSocket、SSE 和明确连接关闭语义
- 运行时可观测：backend 最终选中谁、为什么降级、连接/请求计数；预期中的超时/对端断开安静收场，不再刷异常栈

需要回滚时：

```cangjie
let app = App(config: Config(
    serverPreferredBackendHint: "stdx-default"
))
```

`RestClient` 默认仍使用稳定 stdx Client。需要验证 native H1 Client 时显式选择：

```cangjie
let client = RestClient()
    .preferTransportBackend("ignite-native-h1-client")
```

Native H1 Client 也提供显式的 Contract-backed TLS1.3 Preview。调用方必须
提供 trust anchor 与 hostname，并保持 `http/1.1` ALPN；它不会自动读取
系统 CA：

```cangjie
let client = RestClient()
    .preferTransportBackend("ignite-native-h1-client")
    .useNativeTls(NativeTls13ClientConfig(
        trustAnchorsPemBundle,
        "api.example.com",
        alpnProtocols: ["http/1.1"]
    ))
```

不配置 `useNativeTls(...)` 时，HTTPS 仍走默认 stdx Client。Native H1 backend
如果协商到 `h2`，会显式失败而不是静默降级——你选了 H1 就是 H1。

cleartext 与 Native TLS H1 Client 共用同一响应分帧判定：同时出现
`Transfer-Encoding` 与 `Content-Length`、冲突的重复 `Content-Length`，或当前
无法正确解码的 transfer coding 会在响应体暴露前失败，并淘汰当前连接。合法的
等值重复长度仍可接受。该保护有恶意 loopback wire 与连接恢复回归，但不等同于
完整代理矩阵或独立 HTTP 合规认证。

同一个共享解析器只接受 `HTTP/1.1` 响应版本，并拒绝缺少冒号的字段行、包含
非法 token 字符的字段名，以及字段值中的 NUL、DEL 和其他禁用控制字节。合法
RFC token 标点与水平制表空白仍保持兼容；解析失败的连接不会归池，后续同源请求
需要新建连接。该行为已有 cleartext 恶意 wire / 新连接恢复与 Native TLS H1
回归，但不代表完整 HTTP 或代理互操作认证。

chunked 响应的 trailer 也会在 body drain 完成、连接可归池之前复用同一字段
语法校验，并受 65536-byte 累计预算约束。缺少冒号、非法字段名、禁用控制字节
或超预算都会淘汰当前 cleartext / Native TLS H1 连接；当前只做校验与连接收敛，
不新增公开 trailer 访问 API，也不宣称完整代理矩阵或 HTTP 合规认证。

共享响应解析器还会把有效状态范围限制为 `100..599`。普通 REST H1 路径不会
把 `101 Switching Protocols` 伪装成带普通 body 的响应：它会在暴露升级后字节前
失败并淘汰当前 cleartext / Native TLS 连接，后续同源请求必须经过新连接或新
TLS 握手恢复。该收敛不提供升级后传输所有权或 WebSocket API，也不代表完整
HTTP 互操作认证。

如果服务端支持明文 HTTP/2 prior knowledge，也可以显式进入 Native H2
RestClient Preview：

```cangjie
let client = RestClient()
    .allowExperimentalTransport()
    .preferTransportBackend("ignite-native-h2-client")
```

同一 backend 也可显式运行在 Contract-backed TLS1.3 上：

```cangjie
let client = RestClient()
    .allowExperimentalTransport()
    .preferTransportBackend("ignite-native-h2-client")
    .useNativeTls(NativeTls13ClientConfig(
        trustAnchorsPemBundle,
        "api.example.com",
        alpnProtocols: ["h2"]
    ))
```

这个入口的行为和你熟悉的 `RestClient` 一致：同源连接池、timeout、状态码
重试、Cookie 和 observe 生命周期都照常工作。

有四点要留意，每一点都有它的理由：

1. **读完 response body 连接才回池；提前关闭会发 CANCEL 并废弃整条连接。**
   这是刻意的——未读完的帧留在连接上，会污染下一个请求。
2. **TLS 连接只在同源、且信任策略完全一致时才复用。**
   不同信任配置混用同一条加密连接，等于绕过你自己设的校验。
3. **普通池化请求体仍需可重放；显式 cleartext multiplex session 已支持精确长度或 EOF 终止的 unknown-length one-pass stream。**
   stream 不会为 retry/redirect 重放，调用方保持所有权；普通池化请求每条连接同一时刻仍只有一个公开的流式响应 lease。
4. **`HttpRequestBuilder` mutation hook 仍不兼容。**
   依赖 hook 改写 stdx builder 的调用请留在稳定路径。

### HTTPS

HTTPS 默认仍走稳定的 stdx TLS 路径。JinguiSSL Contract 已经是 Ignite 的直接
契约依赖；Native H1/H2 TLS1.3 client 与 native TLS listener 是显式 Preview，
要求调用方提供信任材料。系统 CA、TLS1.2、会话恢复与默认切换仍未完成——
这也是默认路径暂不切换的原因。

### HTTP/2

Native H2 的最短可运行 ServerEngine、RestClient 与 H1/H2 差异见
[`h2-quickstart-0800.md`](h2-quickstart-0800.md)。

native H2 preview 已经具备：

- Server/Client preface 与 SETTINGS 往返
- 完整 HPACK Huffman、敏感 Header never-index 与有界动态表
- 多 stream 交错与有界 stream 数量
- connection/stream 双层窗口
- DATA park/requeue 与 `WINDOW_UPDATE` 恢复
- RST_STREAM、GOAWAY、timeout、peer-close 和本地主动关闭
- 70,000-byte 双并发响应与重复连接生命周期回归
- 显式 `RestClient` 明文 prior-knowledge backend
- streamed response lease、完整消费归池和提前关闭取消/淘汰
- 显式同源 cleartext multiplex session、精确长度和 unknown-length one-pass request stream
- Native TLS H2 ingress、response streaming 与 graceful drain 切片
- 当前仓库 h2spec profile `145 passed / 1 skipped / 0 failed`

还没证明的，也直接列出来：

- Chrome/Firefox/Safari 完整矩阵
- 浏览器、反向代理和长时压力的完整互操作矩阵
- TLS + ALPN 下 native H2 成为默认生产路径
- 系统 CA、自动重放、逐 stream deadline/priority 与最终生产级公平调度
- H2 extended CONNECT WebSocket

## Native H1 请求头安全边界

默认 Native H1 只接受带有一个非空 `Host` 的 HTTP/1.1 请求。缺失、重复、
逗号合并的 Host，以及字段值中的 NUL、DEL 和其他禁用控制字节，都会在进入
App 路由前收到固定无正文 `400 Bad Request`，随后关闭当前连接；普通字段值两侧
的水平制表空白仍按既有规则收敛。相同响应边界也覆盖已完整接收、被 session
分帧或 request-target dispatch seed 明确拒绝的坏请求，以及 body-stage 已经检测
出的非法 chunk-size、chunk payload CRLF 和 trailer 字段名。

request-head 的 typed 状态分类还会把请求目标/请求行超限映射为固定无正文
`414 URI Too Long`，把请求头总字节或字段数超限映射为 `431 Request Header Fields
Too Large`，并把不支持的 HTTP 版本映射为 `505 HTTP Version Not Supported`。
这些响应同样关闭当前连接，但不停止监听器处理后续有效连接。

如果 `readHeaderTimeout` 到期时请求头仍不完整，或 `readTimeout` 到期时请求体仍
不完整，默认 Native H1 会返回固定无正文 `408 Request Timeout`，关闭该连接并
保留监听器继续接收后续连接。

固定 400/408/414/431/505 不把未完整 EOF、peer abort、chunk/trailer 元数据超限、
不支持的 pipelining 或 handler 异常转换为同类响应。malformed chunked-body 400
也不宣称完整 chunk-extension 或 trailer-value 语法覆盖。当前没有自定义错误页 API，
也不把同栈回归表述为独立代理链合规认证；既有请求 body 过大仍沿用 413 路径。

Host、absolute-form authority 与 CONNECT authority-form 还会复用同一个结构
门：userinfo、坏百分号编码、坏括号、多冒号歧义和非十进制端口会被拒绝；
CONNECT 端口必须非空且位于 `1..65535`。合法 reg-name、括号化 IP-literal 与
十进制端口继续兼容；这里不宣称完整 DNS/IPv6 语义验证。

request-target 也按方法收敛：`CONNECT` 必须使用 authority-form，authority-form
只供 `CONNECT` 使用，asterisk-form 只供 `OPTIONS` 使用。合法的
`CONNECT example.com:443`、`OPTIONS *`、资源级 `OPTIONS /path` 与普通
origin/absolute-form 路由不受影响；非法组合会在 App dispatch 前关闭当前连接，
后续连接仍可继续由监听器处理。absolute-form 请求进入 App 与请求头中间件时，
有效 `Host` 来自 request-target authority，冲突的接收 Host 值会被忽略；
origin-form 仍使用唯一有效的接收 Host。这里不包含 CONNECT 隧道、代理转发、
Host 不一致拒绝策略或自定义错误响应体。

## 流式 JSON

传统接口仍然适合小对象：

```cangjie
ctx.json(#"{"ok":true}"#)
```

它接收完整 `String`，调用者已经完成全量缓冲——小对象这样最省事。大数组
或持续生成的数据应使用 SeaJson writer 路径：

```cangjie
ctx.jsonSeaStream({ writer =>
    writer.beginArray()
    for (i in 0..1000) {
        writer.value(i)
    }
    writer.endArray()
})
```

也可以让业务类型实现 `JsonWriterEncodable`，再通过 `ctx.jsonEncodeStream(...)` 写出。该路径最终进入 `JsonWriter -> OutputStream -> response transport`，内存里始终只有正在写的那一段，不需要先构造完整 JSON 字符串。

## 压缩与静态资源

- 动态 gzip/deflate 已使用 Ignite 自有安全仓颉 codec，覆盖缓冲与增量流式响应。
- 动态 Zstd 可通过 `CompressConfig(zstdEnabled: true)` 显式启用，覆盖有界 buffered/stream frame、content size 与 checksum；当前只提供 RAW/RLE block。
- 动态 Brotli 可通过 `CompressConfig(brotliEnabled: true)` 显式启用，覆盖有界 buffered/stream metablock；当前只提供 RAW 与单字节 RLE/LZ77 子集。
- 静态文件可按 `Accept-Encoding` 选择预生成 `.br` / `.zst` 文件——追求高压缩比时这仍是首选路径。
- Range 请求不会错误套用预压缩副本。
- 当前动态 Zstd/Brotli 是"正确、有界"的子集实现；完整 Brotli context/Huffman/dictionary、完整 Zstd sequence/FSE/Huffman、字典和调优策略还没做完，别按完整实现的压缩比预期它。

## 仍需保留的 stdx 面

`0.8.7` 仍在 TLS 默认路径、部分 JSON compatibility、proxy/client compatibility 和部分平台链接面使用 stdx。具体进度以源码依赖和测试为准——"native preview"是标题，不是替代完成的证据。

## 推荐验证顺序

1. `./manual/samples/hello/run.sh`
2. `./manual/samples/api/run.sh`
3. `./manual/samples/client/run_demo.sh`
4. `./manual/samples/files/run.sh`
5. `./manual/samples/h2wire/probe.sh`

H1 是 0800 的默认可用路线。H2 sample 是预览和诊断入口，不是生产兼容性证书。

## 推荐用 HapCLI 接管 stdx 环境诊断

0800 Preview 仍依赖正确的 SDK/stdx 与平台链接布局。安装 HapCLI 后，建议先诊断再用同一 target 构建：

```bash
hap doctor stdx --project . --target aarch64-apple-darwin
hap build --project . --target aarch64-apple-darwin
```

其他常用 target：`x86_64-unknown-linux-gnu`、`aarch64-unknown-linux-gnu`、`x86_64-w64-mingw32`、`aarch64-linux-ohos`。HapCLI 当前是 Preview 工具，入口见 [cli.hap.pub](https://cli.hap.pub)；它负责 stdx 环境诊断与构建编排，不改变本页列出的 stdx 残留事实。
