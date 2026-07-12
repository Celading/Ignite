# Ignite 0.8.0 Preview

`0.8.0` 是 Ignite 第一次把自研传输主线作为公开预览交付。它不是“已经完全脱离 stdx”的宣言，而是把已经经过真实 socket/wire 回归的能力开放出来，并保留明确回滚路径。

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

当前 native H1 Client 仅处理 `http://`，不应被理解为 HTTPS Client 已默认切换。

### HTTPS

HTTPS 默认仍走稳定的 stdx TLS 路径。JinguiSSL Contract 已经是 Ignite 的直接契约依赖，但 native TLS listener/client 仍是实验入口，不应在生产环境里无条件开启。

### HTTP/2

native H2 preview 已经具备：

- Server/Client preface 与 SETTINGS 往返
- 受限 HPACK 请求/响应头
- 多 stream 交错与有界 stream 数量
- connection/stream 双层窗口
- DATA park/requeue 与 `WINDOW_UPDATE` 恢复
- RST_STREAM、GOAWAY、timeout、peer-close 和本地主动关闭
- 70,000-byte 双并发响应与重复连接生命周期回归

当前没有证明：

- Chrome/Firefox/Safari 完整矩阵
- 完整 `h2spec` 通过
- 动态 HPACK table 与全部 SETTINGS 语义
- TLS + ALPN 下 native H2 成为默认生产路径
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

- 动态 gzip/deflate 仍依赖当前 stdx zlib provider。
- 静态文件可按 `Accept-Encoding` 选择预生成 `.br` / `.zst` 文件。
- Range 请求不会错误套用预压缩副本。
- 0800 不宣称内置 Brotli/Zstd runtime codec 已完成。

## 仍需保留的 stdx 面

`0.8.0` 仍在 TLS 默认路径、部分 JSON compatibility、动态压缩、proxy/client compatibility 和部分平台链接面使用 stdx。具体进度应以源码依赖和测试为准，不以“native preview”标题推导为完全替代。

## 推荐验证顺序

1. `./manual/samples/hello/run.sh`
2. `./manual/samples/api/run.sh`
3. `./manual/samples/client/run_demo.sh`
4. `./manual/samples/files/run.sh`
5. `./manual/samples/h2wire/probe.sh`

H1 是 0800 的默认可用路线。H2 sample 是预览和诊断入口，不是生产兼容性证书。
