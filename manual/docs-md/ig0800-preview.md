# Ignite 0.8.1 Preview

`0.8.1` 延续 Ignite 自研传输预览，把动态 gzip/deflate codec 收回 Ignite 自有安全仓颉实现，并提供显式 opt-in 的动态 Zstd RAW/RLE baseline。它不是“已经完全脱离 stdx”或“完整高压缩比 Zstd 已完成”的宣言，而是把已经经过真实 socket/wire 回归的能力开放出来，并保留明确回滚路径。

配套入口：

- [`capability-matrix-0800.md`](capability-matrix-0800.md)：完整能力状态与 stdx 残留。
- [`api-0800.md`](api-0800.md)：0800 新增 API 签名和调用边界。
- [`migration-0700-to-0800.md`](migration-0700-to-0800.md)：从 0.7.7 升级的回归顺序。

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
- 可显式选择的 native H1 Client：连接复用、流式 body、重定向与错误归一
- WebSocket、SSE 和明确连接关闭语义

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
如果协商到 `h2`，会显式失败而不是静默降级。

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

这个入口复用现有 `RestClient` 的同源连接池、timeout、状态码重试、Cookie
和 observe 生命周期。完整消费 response body 后连接才会归池；提前关闭会
发送 CANCEL 并淘汰连接。TLS H1/H2 只会在同源且信任策略完全一致时顺序归池；
两条路径都只支持 buffered/replayable request body，且每连接仅允许一个公开
streamed response lease；`HttpRequestBuilder` mutation hook 仍不兼容。

### HTTPS

HTTPS 默认仍走稳定的 stdx TLS 路径。JinguiSSL Contract 已经是 Ignite 的直接
契约依赖；Native H1/H2 TLS1.3 client 与 native TLS listener 是显式 Preview，
要求调用方提供信任材料。系统 CA、TLS1.2、会话恢复与默认切换仍
未完成。

### HTTP/2

Native H2 的最短可运行 ServerEngine、RestClient 与 H1/H2 差异见
[`h2-quickstart-0800.md`](h2-quickstart-0800.md)。

native H2 preview 已经具备：

- Server/Client preface 与 SETTINGS 往返
- 受限 HPACK 请求/响应头
- 多 stream 交错与有界 stream 数量
- connection/stream 双层窗口
- DATA park/requeue 与 `WINDOW_UPDATE` 恢复
- RST_STREAM、GOAWAY、timeout、peer-close 和本地主动关闭
- 70,000-byte 双并发响应与重复连接生命周期回归
- 显式 `RestClient` 明文 prior-knowledge backend
- streamed response lease、完整消费归池和提前关闭取消/淘汰

当前没有证明：

- Chrome/Firefox/Safari 完整矩阵
- 浏览器、反向代理和长时压力的完整互操作矩阵
- HPACK 与 SETTINGS 的全部边角语义
- TLS + ALPN 下 native H2 成为默认生产路径
- 公开 RestClient 多路并发 response lease
- H2 extended CONNECT WebSocket

## Native H1 请求头安全边界

默认 Native H1 只接受带有一个非空 `Host` 的 HTTP/1.1 请求。缺失、重复、
逗号合并的 Host，以及字段值中的 NUL、DEL 和其他禁用控制字节，都会在进入
App 路由前关闭当前连接；普通字段值两侧的水平制表空白仍按既有规则收敛。
当前没有为这类解析拒绝承诺固定的 `400` 响应体，也不把同栈回归表述为独立
代理链合规认证。

## 流式 JSON

传统接口仍然适合小对象：

```cangjie
ctx.json(#"{"ok":true}"#)
```

它接收完整 `String`，因此调用者已经完成全量缓冲。大数组或持续生成的数据应使用 SeaJson writer 路径：

```cangjie
ctx.jsonSeaStream({ writer =>
    writer.beginArray()
    for (i in 0..1000) {
        writer.value(i)
    }
    writer.endArray()
})
```

也可以让业务类型实现 `JsonWriterEncodable`，再通过 `ctx.jsonEncodeStream(...)` 写出。该路径最终进入 `JsonWriter -> OutputStream -> response transport`，避免先构造一个完整 JSON 字符串。

## 压缩与静态资源

- 动态 gzip/deflate 已使用 Ignite 自有安全仓颉 codec，覆盖缓冲与增量流式响应。
- 动态 Zstd 可通过 `CompressConfig(zstdEnabled: true)` 显式启用，覆盖有界 buffered/stream frame、content size 与 checksum；当前只提供 RAW/RLE block。
- 动态 Brotli 可通过 `CompressConfig(brotliEnabled: true)` 显式启用，覆盖有界 buffered/stream metablock；当前只提供 RAW 与单字节 RLE/LZ77 子集。
- 静态文件可按 `Accept-Encoding` 选择预生成 `.br` / `.zst` 文件。
- Range 请求不会错误套用预压缩副本。
- 0800 不宣称完整 Brotli context/Huffman/dictionary 或完整 Zstd sequence/FSE/Huffman、字典和调优策略已完成。

## 仍需保留的 stdx 面

`0.8.1` 仍在 TLS 默认路径、部分 JSON compatibility、proxy/client compatibility 和部分平台链接面使用 stdx。具体进度应以源码依赖和测试为准，不以“native preview”标题推导为完全替代。

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
