# Ignite 0.8.2 Preview

`0.8.2` 是自研传输预览线的第三站。`0.8.1` 把 gzip/deflate 换成了 Ignite 自有仓颉 codec 并加入动态 Zstd/Brotli baseline；`0.8.2` 在这之上补齐五件事：Native TLS 连接池的完整生命周期、Native H1 backend 的可观测性、预期断连的安静收敛（超时/对端重置不再打满错误栈）、query 参数单次解码，以及 WebSocket production-core。

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

```toml
[dependencies]
ignite = { git = "https://gitcode.com/cinyu/ignite-cangjie.git" }
```

Ignite 自身的发布构建消费：

```toml
jinguissl = { git = "https://gitcode.com/cinyu/jinguiSSL.git" }
seajson = { git = "https://gitcode.com/CjKu/SeaJson.git" }
```

这两项托管依赖已经通过全新消费者拉取和 `cjpm build` 验证，不再依赖本机 sibling path。

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
3. **请求体目前要可重放（buffered/replayable），流式上传还没开；
   每条连接同一时刻只有一个公开的流式响应 lease。**
   单 lease 是当前池化模型的边界，不是永久设计。
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
- 受限 HPACK 请求/响应头
- 多 stream 交错与有界 stream 数量
- connection/stream 双层窗口
- DATA park/requeue 与 `WINDOW_UPDATE` 恢复
- RST_STREAM、GOAWAY、timeout、peer-close 和本地主动关闭
- 70,000-byte 双并发响应与重复连接生命周期回归
- 显式 `RestClient` 明文 prior-knowledge backend
- streamed response lease、完整消费归池和提前关闭取消/淘汰
- 当前仓库 h2spec profile `145 passed / 1 skipped / 0 failed`

还没证明的，也直接列出来：

- Chrome/Firefox/Safari 完整矩阵
- 浏览器、反向代理和长时压力的完整互操作矩阵
- 动态 HPACK table 与更多 SETTINGS 边角语义
- TLS + ALPN 下 native H2 成为默认生产路径
- 公开 RestClient 多路并发 response lease
- H2 extended CONNECT WebSocket

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

`0.8.2` 仍在 TLS 默认路径、部分 JSON compatibility、proxy/client compatibility 和部分平台链接面使用 stdx。具体进度以源码依赖和测试为准——"native preview"是标题，不是替代完成的证据。

## 推荐验证顺序

1. `./manual/samples/hello/run.sh`
2. `./manual/samples/api/run.sh`
3. `./manual/samples/client/run_demo.sh`
4. `./manual/samples/files/run.sh`
5. `./manual/samples/h2wire/probe.sh`

H1 是 0800 的默认可用路线。H2 sample 是预览和诊断入口，不是生产兼容性证书。
