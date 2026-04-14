# Client

## `RestClient` 的定位

Ignite 不只提供服务端入口，也提供内置客户端能力。

`RestClient` 的价值在于：

- 服务端和调用端可以共用一套更一致的语义
- 在业务仓里减少重复造一层 HTTP Client 封装
- 让重试、Hook、Cookie、加密请求、X509 校验这些常见需求有统一落点

如果你正在做：

- 服务端 + 调用端同仓开发
- 本地联调样例
- 首跑验证与快速回归
- 轻量工具服务或内部 SDK

那么这条能力会很顺手。

## 基础请求方法

`RestClient` 支持常见 HTTP 方法：

- `get`
- `post`
- `put`
- `patch`
- `delete`
- `head`
- `options`
- `postJson`
- `postForm`
- `postMultipart`
- `postEncryptedJson`

```cangjie
import ignite.client.*

let client = RestClient()
let resp = client.get("https://api.example.com/users")
println(resp.status)
println(resp.body())
resp.discard()
client.close()
```

## Builder 模式

当你需要比快捷方法更细的控制时，用 `request()` 进入 `RequestBuilder`。

```cangjie
let resp = client.request()
    .method("POST")
    .url("/users")
    .header("content-type", "application/json")
    .bodyJson(#"{"name":"ignite"}"#)
    .send()
```

Builder 模式适合这些场景：

- 需要动态拼查询参数
- 需要手动加多个 Header
- 需要对单次请求覆盖 Retry / X509 配置
- 需要在一条请求上补 Hook

## BaseURL 与默认 Header

如果服务地址相对固定，可以先在 client 上设定公共配置：

```cangjie
let client = RestClient(
        readTimeout: Duration.second * 15,
        writeTimeout: Duration.second * 15,
        poolSize: 10
    )
    .baseUrl("http://127.0.0.1:18080")
    .defaultHeader("x-service", "ignite-demo")
```

之后 `get("/ping")` 这类相对路径会自动拼到 `baseUrl` 上。

## JSON / Form / Multipart

### JSON

```cangjie
let resp = client.postJson("/echo-json", #"{"name":"ignite"}"#)
```

### Form

```cangjie
let fields = ArrayList<(String, String)>()
fields.add(("title", "learn ignite"))
let resp = client.postForm("/form", fields)
```

### Multipart

```cangjie
let fields = ArrayList<(String, String)>()
fields.add(("meta", "client-upload"))

let files = ArrayList<MultipartFile>()
files.add(MultipartFile(
    "file",
    "demo.txt",
    "text/plain",
    "ignite-multipart-demo".toArray()
))

let resp = client.postMultipart("/upload-multipart", fields, files)
```

如果你需要更灵活的写法，也可以用 `request().form(...)` 或 `request().multipart(...)`。

## Retry / Hook / Observe

Ignite 的客户端能力不只是“能发请求”。它还把常见的重试、Hook、观测字段收进了统一语义里。

### Retry

```cangjie
let client = RestClient().useRetry(ClientRetryConfig(
    enabled: true,
    maxAttempts: 3,
    idempotentOnly: true,
    baseDelayMs: 20,
    maxDelayMs: 120,
    jitterMs: 0
))
```

- 默认更适合幂等请求
- 单次请求可用 `request().retry(...)` 覆盖
- 不想重试时可用 `disableRetry()`

### Hook

```cangjie
let client = RestClient()
    .onRequest({ req =>
        req.header("x-trace-id", "sample-trace-001")
    })
    .onError({ err =>
        println("[client:error] ${err.message}")
    })
```

公开能力里支持：

- `onRequest`
- `onResponse`
- `onError`

`RestClient` 和 `RequestBuilder` 都可以挂这三类 Hook。

### Observe

成功响应通常会附带这些头，方便本地联调或诊断：

- `x-ignite-observe-duration-ms`
- `x-ignite-observe-retry-count`
- `x-ignite-observe-error-class`
- `x-ignite-observe-fields`

## Cookie v2

如果你希望让客户端自动管理 Cookie，可以这样启用：

```cangjie
let client = RestClient().useCookies()
```

或者把外部 `CookieStore` 传进去：

```cangjie
let store = CookieStore()
let client = RestClient().useCookies(store)
```

当前公开口径里，Cookie 管理已覆盖这些常见维度：

- `domain`
- `path`
- `max-age`
- `secure`
- `httpOnly`
- `sameSite`
- 多条 `set-cookie`

## 加密请求

Ignite 的客户端支持加密 JSON 请求，但前提是你先提供客户端加密配置。

```cangjie
import ignite.api2
import std.collection.HashMap

func buildCryptoConfig(): api2.ClientCryptoConfig {
    let ring = HashMap<String, Array<UInt8>>()
    ring.add("k1", "0123456789abcdef0123456789abcdef".toArray())
    api2.ClientCryptoConfig(
        providerKind: api2.ClientCryptoProviderKind.StdxFallback,
        activeKid: "k1",
        keyRing: ring,
        aeadAlgorithm: "AES-256-GCM"
    )
}

let client = RestClient().useCrypto(buildCryptoConfig())
let resp = client.postEncryptedJson(
    "/secure-echo",
    #"{"scope":"client-demo"}"#,
    aad: "route:/secure-echo"
)
```

如果没有配置 `useCrypto(...)`，直接走加密请求会抛出明确错误，而不是静默降级。

## X509 校验入口

当前公开语义里，X509 校验是“客户端校验入口”，不是另一套隐藏监听栈。

```cangjie
client.useX509Verify(X509VerifyOption(
    enabled: true,
    requireHttps: true,
    expectedServerName: "api.example.com",
    pinnedSha256: ["sha256:your-pin"],
    hook: { ctx =>
        true
    }
))
```

你也可以在单次请求上覆盖：

- `request().x509Verify(option)`
- `request().disableX509Verify()`

如果目标地址不是 HTTPS，而你要求了 `requireHttps`，客户端会在发起网络请求前就给出失败。

## 响应读取与大包读取

`ClientResponse` 提供这些常见能力：

- `status`
- `body()`
- `bodyBytes()`
- `bodyStream()`
- `json()`
- `header(name)`
- `headerValues(name)`
- `isOk()` / `isSuccess()`
- `discard()`

处理大响应时，记得及时 `discard()` 或走流式读取，不要把所有请求都当成小 JSON。

## 与服务端一体化演进的公开口径

Ignite 在 `0500` 阶段已经明确把 Client 视作公开能力的一部分，但这不等于“服务端和客户端以后永远强绑定”。

当前更准确的说法是：

- 它们正在沿同一套公开语义演进
- 常见联调、样例、首跑、自检场景已经能从这种一体化里受益
- 更深入的传输解耦与共享层工作，会在 `0600` 之后继续推进

如果你要先体验这部分，最好的起点是 [`manual/samples/client/README.md`](../samples/client/README.md)。
