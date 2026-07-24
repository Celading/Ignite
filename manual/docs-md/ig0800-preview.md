# Ignite 0.8.2 Preview

`0.8.2` 延续 Ignite 自研传输预览，在 `0.8.1` 自有 gzip/deflate 与动态 Zstd/Brotli baseline 之上，补齐 Native TLS pool 生命周期、Native H1 backend 可观测性、预期断连收敛、query 单次解码和 WebSocket production-core。它不是“已经完全脱离 stdx”或“全部协议都已 LTS”的宣言，而是把已经经过真实 socket/wire 回归的能力开放出来，并保留明确回滚路径。

配套入口：

- [`capability-matrix-0800.md`](capability-matrix-0800.md)：完整能力状态与 stdx 残留。
- [`api-0800.md`](api-0800.md)：0800 新增 API 签名和调用边界。
- [`migration-0700-to-0800.md`](migration-0700-to-0800.md)：从 0.7.7 升级的回归顺序。

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

这两项托管依赖已经通过全新消费者拉取和 `cjpm build`，不再依赖本机 sibling path。

## 默认运行时

### 明文 HTTP/1.1

明文 `App.listen(...)` 默认选择 Ignite native H1。当前已经覆盖：

- 多连接并行推进与请求体上限
- socket read/write timeout
- Content-Length 与 chunked 请求/响应
- 流式响应、HEAD、静态文件与 Range
- 可显式选择的 native H1 Client：连接复用、流式 body、重定向与错误归一
- WebSocket、SSE 和明确连接关闭语义
- backend 最终选择/降级原因、连接/请求计数和预期 timeout/reset 收敛

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
- 当前仓库 h2spec profile `145 passed / 1 skipped / 0 failed`

当前没有证明：

- Chrome/Firefox/Safari 完整矩阵
- 浏览器、反向代理和长时压力的完整互操作矩阵
- 浏览器/代理互操作、动态 HPACK table 与更多 SETTINGS 边角语义
- TLS + ALPN 下 native H2 成为默认生产路径
- 公开 RestClient 多路并发 response lease
- H2 extended CONNECT WebSocket

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

`0.8.2` 仍在 TLS 默认路径、部分 JSON compatibility、proxy/client compatibility 和部分平台链接面使用 stdx。具体进度应以源码依赖和测试为准，不以“native preview”标题推导为完全替代。

## 推荐验证顺序

1. `./manual/samples/hello/run.sh`
2. `./manual/samples/api/run.sh`
3. `./manual/samples/client/run_demo.sh`
4. `./manual/samples/files/run.sh`
5. `./manual/samples/h2wire/probe.sh`

H1 是 0800 的默认可用路线。H2 sample 是预览和诊断入口，不是生产兼容性证书。
