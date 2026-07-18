# 从 Ignite 0.7.7 升级到 0.8.1 Preview

0800 保留 0700 的应用层使用方式，但默认明文传输、流式 JSON 和低层协议入口发生了变化。建议按下面顺序升级，不要一次打开所有 Preview 选项。

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

0700 的服务端运行时主要继承 stdx。0800 中，明文 `App.listen(...)` 在空 backend hint 下默认选择 native H1。

建议上线前保留回滚配置：

```cangjie
let fallbackConfig = Config(
    serverPreferredBackendHint: "stdx-default"
)
```

先在测试和灰度环境使用默认 native H1；如果业务依赖未覆盖的 hook、平台链接或特殊代理行为，可临时回滚并提交最小复现。

## 3. 检查请求体上限

0800 的统一字段是 `bodyLimit`：

```cangjie
let config = Config(bodyLimit: 16 * 1024 * 1024)
```

旧代码可继续使用兼容构造参数 `maxRequestBodySize`，但它只是把值写入 `bodyLimit`，不是第二套限制。文档、配置中心和运维面建议统一写 `bodyLimit`，并注明它等价于常见框架里的 `maxRequestBodySize`。

流式读取也受这个上限约束。需要上传大文件时，使用 `requestBody()` 或 `saveBodyToFile()`，不要先调用 `bodyBytes()`。

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

迁移后检查中间件：`etag`、cache、idempotency 等如果依赖 `ctx.responseBody`，不会自动理解流式响应。需要在路由级禁用、绕过或增加专门的 streaming contract。

## 5. HTTPS 暂不切换默认实现

0800 不要求生产 HTTPS 改用 native TLS。默认仍是稳定 stdx TLS 路径，并消费 JinguiSSL Contract 做契约和预检。

只有明确进行实验验证时才使用：

```cangjie
let config = Config(
    serverPreferredBackendHint: "native-h1",
    allowExperimentalServerBackend: true
)
```

这不是生产推荐配置，也不等于 native H2 + ALPN 已成为默认 listener。

## 6. H2 只作为显式 Preview 接入

不要把 native H2 Preview 理解成公开 HTTPS listener 或默认 Client。0800 已允许 `RestClient` 显式选择 `ignite-native-h2-client`，但它只处理明文 prior knowledge、buffered/replayable request body 和每连接一个公开 streamed response lease。直接使用 `ignite.native_h2` 低层 API 时，调用方仍要准备 `TcpSocket`，并自行负责 TLS/ALPN、timeout 和 close。

```cangjie
let client = RestClient()
    .allowExperimentalTransport()
    .preferTransportBackend("ignite-native-h2-client")

let response = client.get("http://127.0.0.1:8080/h2")
let body = response.body()
client.close()
```

完整消费 response body 后连接可归池复用；提前关闭 response 会取消 stream
并淘汰连接。不要把当前单 lease 池化行为描述成公开多路并发 API；依赖
`onRequest` / `onRequestHook` 改写 stdx builder 的调用仍应留在稳定路径。

适合的 0800 使用方式：

- 协议实验和 wire fixture。
- 内部受控连接、代理或 transport adapter。
- 验证多 stream、flow-control、response lease、完整消费归池和提前关闭淘汰行为。

暂不适合：

- 对外宣称完整浏览器 H2 兼容。
- 直接替换生产网关。
- 依赖 TLS/ALPN 默认路径、公开 RestClient 多路 lease 或 H2 WebSocket。

## 7. 检查静态压缩部署

`.br` / `.zst` 静态副本仍需要在发布流水线预生成并与原文件一起上传。
动态 gzip/deflate 已改为 Ignite 自有安全仓颉 codec，不再构造 stdx zlib
codec。动态 Zstd baseline 需要显式设置 `zstdEnabled: true`，当前只生成
有界 RAW/RLE block；通用 payload 可能被 `skipIfNoGain` 回退为 identity。
不要因此推导所有 stdx 运行时依赖都可以删除，TLS、兼容 JSON、代理和
平台链接仍需按实际依赖审计。

## 8. 推荐回归清单

- 明文 H1：多连接、keep-alive、chunked、HEAD、Range。
- Client：连接复用、重定向、流式上传、显式 close。
- 请求体：`bodyLimit` 超限和大 body 落盘。
- JSON：小 buffered response 与大 streaming response。
- 长连接：WebSocket 子协议、Ping/Pong/Close、SSE。
- HTTPS：默认路径证书、错误诊断和回滚。
- 如果消费 native H2：SETTINGS、多流、WINDOW_UPDATE、RST、GOAWAY、timeout、完整消费归池、提前关闭淘汰和物理 close。

能力全表见 [`capability-matrix-0800.md`](capability-matrix-0800.md)，新增签名见 [`api-0800.md`](api-0800.md)。
