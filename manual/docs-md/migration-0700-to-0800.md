# 从 Ignite 0.7.7 升级到 0.8.7 Preview

0800 保留 0700 的应用层使用方式。真正要留意的是四件事：明文传输换了默认引擎、请求体上限统一成 `bodyLimit`、大 JSON 建议改流式、低层协议入口是显式预览。按下面顺序走，一步一步开，不要一次打开所有 Preview 选项。

## 1. 更新依赖并先构建

```toml
[dependencies]
ignite = { git = "https://gitcode.com/cinyu/ignite-cangjie.git" }
```

先执行：

```bash
cjpm update
cjpm build
```

0800 发布投影使用托管 JinguiSSL 和 SeaJson，不依赖本地 sibling path。

## 2. 明确明文 H1 默认变化

0700 的服务端运行时主要继承 stdx。0800 中，明文 `App.listen(...)` 在空 backend hint 下默认选择 native H1——这是本次升级唯一"不动代码也会变"的地方。

建议上线前保留回滚配置：

```cangjie
let fallbackConfig = Config(
    serverPreferredBackendHint: "stdx-default"
)
```

先在测试和灰度环境跑默认 native H1；万一业务依赖了未覆盖的 hook、平台链接或特殊代理行为，一行配置就能回去，不用回版本。遇到这种情况欢迎提交最小复现。

## 3. 检查请求体上限

0800 的统一字段是 `bodyLimit`：

```cangjie
let config = Config(bodyLimit: 16 * 1024 * 1024)
```

旧代码可继续使用兼容构造参数 `maxRequestBodySize`，但它只是把值写入 `bodyLimit`，不是第二套限制。文档、配置中心和运维面建议统一写 `bodyLimit`，并注明它等价于常见框架里的 `maxRequestBodySize`。

流式读取也受这个上限约束。需要上传大文件时，使用 `requestBody()` 或 `saveBodyToFile()`，不要先调用 `bodyBytes()`——那会把整个文件读进内存。

`RestClient` 默认仍走稳定 stdx Client。如果要单独验证 native H1 Client，使用 `.preferTransportBackend("ignite-native-h1-client")`；如果服务端支持明文 HTTP/2 prior knowledge，可显式选择 `ignite-native-h2-client`。两者都应同时开启 `allowExperimentalTransport()`，并把范围限制在 `http://`。

## 4. 把大 JSON 改为流式

保留小响应：

```cangjie
ctx.json(#"{"ok":true}"#)
```

大数组改为：

```cangjie
ctx.jsonSeaStream({ writer =>
    writer.beginArray()
    for (item in items) {
        writer.value(item)
    }
    writer.endArray()
})
```

迁移后检查中间件：`etag`、cache、idempotency 等如果依赖 `ctx.responseBody`，不会自动理解流式响应——流式路径根本没有完整 body 给它们看。逐路由处理：禁用、绕过，或增加专门的 streaming contract。

## 5. HTTPS 暂不切换默认实现

0800 不要求生产 HTTPS 改用 native TLS，默认仍是稳定 stdx TLS 路径，并消费 JinguiSSL Contract 做契约和预检。这是刻意的：系统 CA 和会话恢复还没完成，不到默认切换的时候。

只有明确进行实验验证时才使用：

```cangjie
let config = Config(
    serverPreferredBackendHint: "native-h1",
    allowExperimentalServerBackend: true
)
```

这不是生产推荐配置，也不等于 native H2 + ALPN 已成为默认 listener。

## 6. H2 只作为显式 Preview 接入

不要把 native H2 Preview 理解成公开 HTTPS listener 或默认 Client。0800 已允许 `RestClient` 显式选择 `ignite-native-h2-client`；普通 `request().send()` 处理明文 prior knowledge、buffered/replayable request body 和每连接一个公开 streamed response lease，另有显式 bounded buffered batch API，以及支持 buffered body 与精确长度 one-pass request stream 的 multiplex session。直接使用 `ignite.native_h2` 低层 API 时，调用方仍要准备 `TcpSocket`，并自行负责 TLS/ALPN、timeout 和 close。

```cangjie
let client = RestClient(
    readTimeout: Duration.second * 15,
    writeTimeout: Duration.second * 15,
    poolSize: 4
)
    .allowExperimentalTransport()
    .preferTransportBackend("ignite-native-h2-client")

let response = client.get("http://127.0.0.1:8080/h2")
let body = response.body()
client.close()
```

完整消费 response body 后连接可归池复用；提前关闭 response 会取消 stream
并淘汰连接。需要明确的同源多路批次时，使用
`sendNativeH2Batch([NativeH2BatchRequest(...)])`：每批最多 32 个请求、每响应
最多缓冲 1 MiB、整批完成后才归池。它不是任意异步 streamed lease，且当前
只支持 cleartext `http://`。显式 session 还可用 `bodyStream(input)` 发送 EOF
终止的 unknown-length request stream。依赖 `onRequest` / `onRequestHook` 改写 stdx
builder 的调用仍应留在稳定路径。

需要独立并发 response lease 时，可以显式打开：

```cangjie
let session = client.openNativeH2Session(
    "http://127.0.0.1:8080",
    maxConcurrentStreams: 8
)
try {
    let a = spawn {
        session.send(NativeH2BatchRequest("POST", "/a").bodyString("payload"))
    }
    let b = spawn { session.send(NativeH2BatchRequest("GET", "/b")) }
    let streamed = spawn {
        session.send(
            NativeH2BatchRequest("POST", "/streamed")
                .bodyStream(input, exactLength)
        )
    }
    println(a.get(Duration.second * 5).body())
    println(b.get(Duration.second * 5).body())
    println(streamed.get(Duration.second * 5).body())
} finally {
    session.close()
}
```

该 session 只支持同一 cleartext origin；request body 可以是 buffered bytes/string、
`bodyStream(input, exactLength)` 指定的精确长度 one-pass stream，或
`bodyStream(input)` 指定的 EOF 终止 unknown-length one-pass stream。精确长度模式会
补齐 `content-length`，unknown-length 模式不会发送该头。stream producer
每次最多读取 8 KiB、每 stream 最多预取 32 KiB，并且不会在读取用户 stream 时
持有协议锁。Ignite 不会关闭 source；取消在一次 `read` 返回后生效，因此可能阻塞
的 source 应由调用方提供可取消或有界超时的读取实现。DATA 会服从
connection/stream send window，并由 `WINDOW_UPDATE`
或 SETTINGS 初始窗口变化继续推进。每个 stream 最多保留 65,535 字节未读响应
数据。本地 active stream 上限最多 32，并继续服从 peer SETTINGS。完整消费允许
连接复用；任一 response 提前关闭会发送 CANCEL，已打开兄弟 stream 可继续；若
request body 尚未发完，连接会进入 retiring。它仍不包含 TLS multiplex、自动
RequestBuilder H2 streaming、retry/redirect 重放、priority
或逐 stream deadline。

适合的 0800 使用方式：

- 协议实验和 wire fixture。
- 内部受控连接、代理或 transport adapter。
- 验证多 stream、双层 request send-window、response lease、完整消费归池和提前
  关闭淘汰行为。

暂不适合：

- 对外宣称完整浏览器 H2 兼容。
- 直接替换生产网关。
- 依赖 TLS/ALPN 默认路径、任意生产级 H2 调度或 H2 WebSocket。

## 7. 检查静态压缩部署

`.br` / `.zst` 静态副本仍需要在发布流水线预生成并与原文件一起上传。
动态 gzip/deflate 已改为 Ignite 自有安全仓颉 codec，不再构造 stdx zlib
codec。动态 Zstd baseline 需要显式设置 `zstdEnabled: true`，当前只生成
有界 RAW/RLE block；通用 payload 可能被 `skipIfNoGain` 回退为 identity——
这是子集实现的正常表现。动态 Brotli baseline 同样需要显式设置
`brotliEnabled: true`，当前只生成有界 RAW metablock 与单字节 RLE/LZ77
子集，不应替代完整 Brotli 质量档。也不要因此推导所有 stdx 运行时依赖
都可以删除：TLS、兼容 JSON、代理和平台链接仍需按实际依赖审计。

## 8. 推荐回归清单

- 明文 H1：多连接、keep-alive、chunked、HEAD、Range。
- Client：连接复用、重定向、流式上传、显式 close。
- 请求体：`bodyLimit` 超限和大 body 落盘。
- JSON：小 buffered response 与大 streaming response。
- 长连接：WebSocket 子协议、Ping/Pong/Close、SSE。
- HTTPS：默认路径证书、错误诊断和回滚。
- 如果消费 native H2：SETTINGS、多流、WINDOW_UPDATE、RST、GOAWAY、timeout、完整消费归池、提前关闭淘汰和物理 close。

能力全表见 [`capability-matrix-0800.md`](capability-matrix-0800.md)，新增签名见 [`api-0800.md`](api-0800.md)。
