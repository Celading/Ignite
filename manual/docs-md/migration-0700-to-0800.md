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

`RestClient` 默认仍走稳定 stdx Client。如果要单独验证 native H1 Client，使用 `.preferTransportBackend("ignite-native-h1-client")`，并把范围限制在 `http://`。

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

## 6. H2 只作为低层 Preview 接入

不要把 `ignite.native_h2` 直接替换成现有 `RestClient` 或公开 HTTPS listener。它要求调用方先准备好 `TcpSocket`，并自行负责 TLS/ALPN、timeout 和 close。

适合的 0800 使用方式：

- 协议实验和 wire fixture。
- 内部受控连接、代理或 transport adapter。
- 验证多 stream、flow-control 和生命周期行为。

暂不适合：

- 对外宣称完整浏览器 H2 兼容。
- 直接替换生产网关。
- 依赖动态 HPACK table、完整 h2spec 或 H2 WebSocket。

## 7. 检查静态压缩部署

`.br` / `.zst` 是预生成资产。发布流水线需要同时上传原文件和压缩副本。动态 gzip/deflate 仍使用当前 stdx zlib provider，不要删除相关运行时依赖。

## 8. 推荐回归清单

- 明文 H1：多连接、keep-alive、chunked、HEAD、Range。
- Client：连接复用、重定向、流式上传、显式 close。
- 请求体：`bodyLimit` 超限和大 body 落盘。
- JSON：小 buffered response 与大 streaming response。
- 长连接：WebSocket 子协议、Ping/Pong/Close、SSE。
- HTTPS：默认路径证书、错误诊断和回滚。
- 如果消费 native H2：SETTINGS、多流、WINDOW_UPDATE、RST、GOAWAY、timeout 和物理 close。

能力全表见 [`capability-matrix-0800.md`](capability-matrix-0800.md)，新增签名见 [`api-0800.md`](api-0800.md)。
