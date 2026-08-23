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

### 独立 request/response lease multiplex session

如果多个调用方需要在同一个 H2 连接上独立读取 response body，使用显式
session，而不是让多个线程直接争抢 socket。cleartext 入口如下：

```cangjie
let client = RestClient(
    readTimeout: Duration.second * 15,
    writeTimeout: Duration.second * 15,
    poolSize: 4
)
    .allowExperimentalTransport()
    .preferTransportBackend("ignite-native-h2-client")

let session = client.openNativeH2Session(
    "http://127.0.0.1:3000",
    maxConcurrentStreams: 8
)
try {
    let slow = spawn {
        session.send(
            NativeH2BatchRequest("POST", "/slow")
                .header("content-type", "text/plain")
                .bodyString("buffered payload")
                .deadline(Duration.second)
        )
    }
    let fast = spawn {
        session.send(NativeH2BatchRequest("GET", "/fast"))
    }
    let upload = spawn {
        session.send(
            NativeH2BatchRequest("POST", "/upload")
                .bodyStream(input, exactLength)
        )
    }

    println(fast.get(Duration.second * 5).body())
    println(slow.get(Duration.second * 5).body())
    println(upload.get(Duration.second * 5).body())
} finally {
    session.close()
    client.close()
}
```

这条路径的边界是：

- 只支持同一 cleartext `http://` origin；request body 可以是 buffered
  bytes/string、`bodyStream(input, exactLength)` 指定的精确长度 one-pass stream，
  或 `bodyStream(input)` 指定的未知长度 source；精确长度缺少 `content-length` 时
  由 session 自动补齐，未知长度则不发送该 header；
- stream producer 每次最多读取 8 KiB、每 stream 最多预取 32 KiB，读取用户
  `InputStream` 时不持有 session-state 或 writer mutex；调用方继续持有 stream，
  Ignite 不会关闭或为 retry/redirect 重放它；取消在一次 `read` 返回后生效，可能
  阻塞的 source 应由调用方提供可取消或有界超时的读取实现；
- 本地最多 32 个 active stream，并服从 peer concurrent-stream limit；
- 一个 connection-owned reader 分发 frame，调用方不会并发读取 socket；
- request DATA 同时服从 connection 和 stream send window；`WINDOW_UPDATE` 与
  `SETTINGS_INITIAL_WINDOW_SIZE` 会继续推进尚未发完的 upload；
- 每个 stream 的未读 body 上限为 65,535 字节；连接窗口独立补充，慢 stream
  不会阻止窗口内的兄弟 response 完成；
- 完整读到 EOF 后连接可复用；提前关闭一个 response 会取消该 stream、保留
  已打开的兄弟 stream；若 request body 尚未发完，连接同时进入 retiring，避免
  在未知 peer 消费状态下复用；
- 支持精确长度和未知长度 one-pass request stream；可通过
  `NativeH2BatchRequest.deadline(Duration)` 取消单个超时 stream 而保留兄弟 stream；
  不支持自动 RequestBuilder H2 streaming、retry/redirect、priority、
  request/observe/transport-touchpoint hook。

`RestClient.close()` 会关闭尚未显式结束的 session，但消费方仍应优先使用
`try/finally` 明确归还资源。

需要 TLS1.3 + `h2` ALPN 时，配置 Native TLS 后打开对应 session：

```cangjie
let client = RestClient(poolSize: 4)
    .allowExperimentalTransport()
    .preferTransportBackend("ignite-native-h2-client")
    .useNativeTls(NativeTls13ClientConfig(
        trustAnchorsPemBundle,
        "api.example.com",
        alpnProtocols: ["h2"]
    ))

let session = client.openNativeTlsH2Session(
    "https://api.example.com",
    maxConcurrentStreams: 8
)
try {
    let a = spawn { session.send(NativeH2BatchRequest("GET", "/a")) }
    let b = spawn { session.send(NativeH2BatchRequest("GET", "/b")) }
    println(a.get(Duration.second * 5).body())
    println(b.get(Duration.second * 5).body())
} finally {
    session.close()
    client.close()
}
```

该 TLS session 使用同一 multiplex runtime，支持乱序响应归属和一次性 request
stream；完整 settle 才归池，带活跃 lease 关闭会淘汰物理连接。它仍要求调用方
提供 trust anchor/hostname，不代表系统 CA、自动重放或生产默认切换完成。

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
- RFC 7541 Appendix B 的 257 项 code table，包括 EOS；
- 完整 256-octet symbol 的 Huffman 编解码；公开 `String` 恢复要求合法 UTF-8；
- 非法 code、EOS 出现在 payload 中和非法 padding 的 fail-closed 拒绝；
- outbound 仅在 Huffman 结果更短时启用，并对敏感 Header 使用 never-index。

当前边界：

- Jingui accepted-transport compatibility parser 仍不是同一条完整 HPACK 路径；
- 动态表和 Header-list 大小受本地上限与 peer SETTINGS 共同约束；
- 当前 2048-turn byte profile 只证明重复 Header 的编码形态，不外推通用吞吐排名。

这里描述的是 `ignite.native_h2` 主实现。另一个 Jingui accepted-transport
compatibility parser 当前仍会拒绝 Huffman string，不能把两条路径混成同一能力。

Native H2 主实现已经具备完整 HPACK Huffman codec，并在编码更短时选择
Huffman；重复 ordinary Header 还可以进入 connection-owned dynamic table。

注意：动态 Zstd/Brotli 文档里的 Huffman 是压缩算法能力，不是 HPACK
Huffman。当前 Zstd/Brotli 仍是 RAW/RLE Preview，也没有完整熵编码能力。

## H1/H2 公开能力差异

| 能力 | Native H1 | Native H2 Preview |
| --- | --- | --- |
| 普通 `App.listen` 默认选择 | 是 | 否，需安装实验 ServerEngine |
| 路由与基础 buffered 响应 | 是 | 是，通过 App adapter |
| `app.ws(...)` | Native RFC 6455 | 否，缺 extended CONNECT |
| SSE 已验收主路径 | 是 | Preview：公开 retry/heartbeat/event handler-time DATA 与显式 close END_STREAM 已有 wire 验收 |
| `ctx.writer()` / JSON stream | 真正增量 socket 写出 | 直接 writer 已有 handler-time DATA；JSON stream 走独立有界 producer |
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
- WebSocket 或自动动态压缩中间件要求成熟时：0800 当前优先使用 Native H1。
  Native H2 SSE 与显式 `transportWriterWithTransform(...)` 已可受控评估，
  但自动 heartbeat/reconnect/Last-Event-ID、压缩中间件注册和 H2 WebSocket
  仍需应用或后续能力补齐。
