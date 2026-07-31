# Ignite 0800 Native H2 快速使用与能力边界

Native H2 是显式 Preview，不是普通 `App.listen(...)` 的自动升级结果。先根据
消费场景选择入口：

- 普通明文服务默认是 Native H1。
- Native H2 ServerEngine 需要显式安装，并且只接受明文 prior knowledge。
- 普通浏览器 `https://` 服务当前继续使用稳定的 stdx TLS/ALPN 路径。
- Native H2 RestClient 可以显式走明文 prior knowledge，或配合
  `useNativeTls(...)` 走 Contract-backed TLS1.3 + `h2` ALPN。

## 最短 Native H2 Server

```cangjie
import ignite.*
import ignite.native_h2.useExperimentalNativeH2ServerEngine

main() {
    let app = App()

    useExperimentalNativeH2ServerEngine(app)

    app.get("/", { ctx =>
        _ = ctx.sendString("hello from native h2")
    })

    app.listen("127.0.0.1", 3000)
}
```

这个 listener 是 **cleartext HTTP/2 prior knowledge**，不是 H1 Upgrade，也不是
TLS listener。可以使用支持 HTTP/2 的客户端验证：

```bash
curl --http2-prior-knowledge http://127.0.0.1:3000/
```

如果本机 `curl` 没有编译 HTTP/2 支持，可使用 `nghttp`，或运行仓库内的：

```bash
./manual/benchmark/run_native_h2_smoke.sh
```

## Native H2 RestClient

明文 prior knowledge：

```cangjie
import ignite.client.*

main() {
    let client = RestClient(
        readTimeout: Duration.second * 15,
        writeTimeout: Duration.second * 15,
        poolSize: 4
    )
        .allowExperimentalTransport()
        .preferTransportBackend("ignite-native-h2-client")

    try {
        let response = client.get("http://127.0.0.1:3000/")
        println(String.fromUtf8(response.body()))
    } finally {
        client.close()
    }
}
```

显式 TLS1.3 + `h2` ALPN：

```cangjie
let client = RestClient(poolSize: 4)
    .allowExperimentalTransport()
    .preferTransportBackend("ignite-native-h2-client")
    .useNativeTls(NativeTls13ClientConfig(
        trustAnchorsPemBundle,
        "api.example.com",
        alpnProtocols: ["h2"]
    ))
```

这里的 Native TLS Client 需要调用方提供 trust anchor 与 hostname。系统 CA、
TLS1.2、session resumption、mTLS 和默认切换仍未完成。

### 有界 RestClient batch multiplex

受控明文 H2 服务可以在一个物理连接内显式发送一批请求：

```cangjie
let client = RestClient(
    readTimeout: Duration.second * 15,
    writeTimeout: Duration.second * 15,
    poolSize: 4
)
    .allowExperimentalTransport()
    .preferTransportBackend("ignite-native-h2-client")

try {
    let responses = client.sendNativeH2Batch([
        NativeH2BatchRequest("GET", "http://127.0.0.1:3000/a"),
        NativeH2BatchRequest("GET", "http://127.0.0.1:3000/b")
    ])
    println(responses[0].status)
    println(responses[1].status)
} finally {
    client.close()
}
```

边界如下：

- 每批最多 32 个请求，并遵守服务端声明的并发 stream 上限；
- 所有 URL 必须解析到同一个 cleartext `http://` origin；
- handler 可以并发推进，但返回数组保持请求顺序；
- 每个响应最多缓冲 1 MiB，整批成功后连接才归池；
- 支持 default headers、CookieStore、response hook 和 error hook；
- 不支持 TLS batch、streamed body、retry/redirect 重放、逐请求 cancellation；
- request、observe、transport-touchpoint hook 会 fail closed。

这是一条明确的 buffered batch API，不会把普通 `request().send()` 变成任意
并发 streamed lease。

## WebSocket 到底是不是 Native

公开 API 不区分 `NativeWebSocket` 类型：

```cangjie
app.ws("/chat", { conn =>
    let message = conn.readMessage()
    if (message.isText) {
        conn.writeText(message.text())
    }
})
```

- 当请求由默认明文 Native H1 backend 接收时，`app.ws(...)` 会进入 Ignite
  自研 Native H1 WebSocket。
- 当服务显式回滚到 `stdx-default` 时，同一个 `WsConn` API 使用 stdx
  compatibility backend。
- Native H2 当前不支持 WebSocket upgrade；RFC 8441 extended CONNECT、
  Native WSS、permessage-deflate 和客户端 Dialer 仍是独立缺口。

因此“没有单独的 Native WebSocket 类”不等于没有 Native WebSocket 实现，但
也不能把 Native H1 WebSocket 宣称为 H2 WebSocket。

## HPACK Huffman 边界

当前 Native H2 HPACK 拥有：

- RFC 静态表与有界动态表状态；
- HPACK integer、literal、indexed field 与 table-size update 处理；
- 可见 ASCII header 字符的 Huffman 解码子集；
- 非法 padding 和不支持符号的 fail-closed 拒绝。

当前没有：

- 完整 RFC 7541 Appendix B 的 256 符号 + EOS 解码表；
- outbound HPACK Huffman encoder；
- “所有合法 header octet 都已覆盖”的完整声明。

这里描述的是 `ignite.native_h2` 主实现。另一个 Jingui accepted-transport
compatibility parser 当前仍会拒绝 Huffman string，不能把两条路径混成同一能力。

Native H2 当前发送 literal/non-Huffman 字符串。这个实现足以覆盖现有已验收
profile，但不等于完整 HPACK Huffman 实现。

注意：动态 Zstd/Brotli 文档里的 Huffman 是压缩算法能力，不是 HPACK
Huffman。当前 Zstd/Brotli 仍是 RAW/RLE Preview，也没有完整熵编码能力。

## H1/H2 公开能力差异

| 能力 | Native H1 | Native H2 Preview |
| --- | --- | --- |
| 普通 `App.listen` 默认选择 | 是 | 否，需安装实验 ServerEngine |
| 路由与基础 buffered 响应 | 是 | 是，通过 App adapter |
| `app.ws(...)` | Native RFC 6455 | 否，缺 extended CONNECT |
| SSE 已验收主路径 | 是 | 尚未形成等价验收 |
| `ctx.writer()` / JSON stream | 真正增量 socket 写出 | App adapter 当前会先聚合完整响应 |
| 动态压缩流 | H1 有真实 wire 回归 | 尚不能宣称 App 层真流式等价 |
| server runtime snapshot | 有 Native H1 计数 | 当前不覆盖 H2 |
| RestClient response | H1 支持 streamed response | 单 streamed lease；另有显式 buffered batch multiplex |
| TLS Server | 默认 stdx；Native 候选实验 | Native H2 ServerEngine 不接受 TLS 配置 |
| TLS Client | 显式 Native TLS1.3 | 显式 Native TLS1.3 + `h2` ALPN |

## 选择建议

- 浏览器网站、普通 HTTPS API：继续使用默认稳定路径。
- 受控服务间明文 H2：显式安装 Native H2 ServerEngine，并使用 prior-knowledge
  client。
- 受控 Native TLS H2 Client：显式提供 trust policy 和 `h2` ALPN。
- WebSocket、SSE、流式 JSON/压缩要求成熟时：0800 当前优先使用 Native H1；
  不要假设切换 H2 后自动获得同等能力。
