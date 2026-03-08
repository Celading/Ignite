<p align="center">
  <img src="https://img.shields.io/badge/Cangjie-Ignite-ff6b35?style=for-the-badge&labelColor=1a1a2e" alt="Ignite" />
  <img src="https://img.shields.io/badge/version-0.4.07-blue?style=for-the-badge&labelColor=1a1a2e" alt="Version" />
  <img src="https://img.shields.io/badge/license-Apache%202.0-green?style=for-the-badge&labelColor=1a1a2e" alt="License" />
</p>
<div align="center">
<pre style="background:#00000000">
┌───────────────────────────────────────────────────────┐
│                <span style="color:#88C0D0;">Ignite HttpServer v0.4.07</span>              │
│                  <span style="color:#6EB186;">http://127.0.0.1:8080</span>                │
│          <span style="color:#AAAAAA;">(bound on host 0.0.0.0 and port 8080)</span>        │
│                                                       │
│    Handlers <span style="color:#555;">...........</span> 16  Processes <span style="color:#555;">...........</span> 1   │
│    Prefork <span style="color:#555;">......</span> Disabled  PID <span style="color:#555;">.............</span> 67271   │
└───────────────────────────────────────────────────────┘
</pre>
</div>

<h1 align="center">Ignite ( 叶燧 )</h1>

<p align="center">
  <strong>为仓颉语言打造的高性能 Web 框架</strong><br>
  <sub>极简 API · Trie 路由 · WebSocket · SSE · Swagger · TLS/HTTP2</sub>
</p>

<p align="center">
  <a href="#快速开始">快速开始</a> ·
  <a href="#核心特性">核心特性</a> ·
  <a href="#api-速览">API 速览</a> ·
  <a href="#中间件">中间件</a> ·
  <a href="#高级用法">高级用法</a> ·
  <a href="#叶燧星火">叶燧星火</a> ·
  <a href="#许可证">许可证</a>
</p>

---



## 为什么选择 Ignite?

> **"点燃仓颉 Web 开发的第一把火。"**

仓颉（Cangjie）是华为推出的自研编程语言，而 **Ignite** 是专为仓颉生态打造的 Web 框架——借鉴了 Go [Fiber](https://gofiber.io/) 的极简哲学，将其核心理念移植到仓颉的类型系统中，让你用最少的代码构建高性能 HTTP 服务。

```
                ┌─────────────────────────────────────────┐
                │             Ignite Architecture          │
                │                                         │
                │   Request ──► Router (Trie) ──► Match   │
                │                                  │      │
                │              Middleware Chain ◄───┘      │
                │              │   │   │                   │
                │              ▼   ▼   ▼                   │
                │           Logger CORS Recover            │
                │              │                           │
                │              ▼                           │
                │           Handler ──► Ctx ──► Response   │
                │                       │                  │
                │              ┌────────┼────────┐         │
                │              ▼        ▼        ▼         │
                │            JSON     SSE    WebSocket     │
                └─────────────────────────────────────────┘
```

## 快速开始

### 环境要求

- 仓颉编译器 (`cjc`) v1.0.0+
- 仓颉标准扩展库 (`stdx`)
- 支持平台：macOS (arm64/x86_64)、Linux (arm64/x86_64)

### Hello, Ignite!

```cangjie
import ignite.*

main() {
    let app = App()

    app.get("/", { ctx =>
        ctx.json(#"{"message": "Hello, Ignite!"}"#)
    })

    app.listen("0.0.0.0", 3000)
}
```

仅需 **6 行代码**，一个 HTTP 服务便拔地而起。

## 核心特性

| 特性 | 描述 |
|:---|:---|
| **Trie 路由** | 基于前缀树的高效路由匹配，支持路径参数 `:id` 和通配符 `*` |
| **链式 API** | 流畅的链式调用设计，`app.get(...).post(...).use(...)` |
| **中间件** | 全局中间件 + 路由组中间件，`ctx.next()` 控制执行流 |
| **路由组** | `app.group("/api")` 嵌套分组，前缀自动拼接 |
| **WebSocket** | 一行代码升级 WebSocket 连接 |
| **SSE** | 内置 Server-Sent Events 支持，实时推送 |
| **流式响应** | Chunked Transfer Encoding，边生成边发送 |
| **Swagger** | 自动生成 OpenAPI 3.0 文档 + 内置 Swagger UI，可缓存（`enableSwaggerCache`），`?refresh=1` 强制刷新 |
| **TLS/HTTP2** | 原生 TLS 支持，自动 ALPN 协商 HTTP/2 |
| **HTTP 客户端** | 内置 `RestClient`，Builder 模式构建请求 |
| **JSON** | `ctx.jsonSerialize` / `ctx.jsonEncode`，可配置 `Config.jsonEncoder`；`ignite.serializeJson` / `deserializeJson` |
| **文件与 Range** | `ctx.sendFile`、`ctx.download`（附件名）、`ctx.sendFileRange`（HTTP Range 206/416） |
| **优雅关闭** | `onShutdown` 钩子，安全释放资源 |

## API 速览

### 路由注册

```cangjie
let app = App()

// 基础路由
app.get("/users", listUsers)
app.post("/users", createUser)
app.put("/users/:id", updateUser)
app.delete("/users/:id", deleteUser)

// 所有 HTTP 方法
app.all("/health", healthCheck)
```

### 路径参数 & 查询参数

```cangjie
app.get("/users/:id", { ctx =>
    let userId = ctx.params("id")
    let fields = ctx.queryDefault("fields", "all")
    ctx.json(#"{"id": "${userId}", "fields": "${fields}"}"#)
})
```

### 请求上下文 (Ctx)

`Ctx` 是贯穿请求生命周期的核心对象，提供丰富的 API：

```cangjie
app.post("/upload", { ctx =>
    // 请求信息
    let method   = ctx.method       // "POST"
    let path     = ctx.path         // "/upload"
    let clientIp = ctx.ip           // "127.0.0.1"
    let token    = ctx.header("Authorization")

    // 请求体
    let body = ctx.bodyString()

    // 响应
    ctx.status(201).json(#"{"status": "created"}"#)
})
```

**响应方法一览：**

```cangjie
ctx.json(body)                   // application/json
ctx.jsonSerialize(obj)           // 类型实现 StdxJsonSerializable 时序列化并返回 JSON
ctx.jsonEncode(obj)              // 实现 JsonEncodable 或使用 Config.jsonEncoder 自定义编码
ctx.sendString(body)             // text/plain
ctx.html(body)                   // text/html
ctx.send(byteArray)              // 原始字节
ctx.sendStatus(404)              // 状态码 + 默认消息
ctx.redirect("/login")           // 302 重定向
ctx.noContent()                  // 204 No Content
ctx.sendFile(path)               // 按路径发送文件
ctx.download(path, filename)     // 附件下载（可选 filename）
ctx.sendFileRange(path)          // 支持 HTTP Range，返回 206/416
ctx.setCookie("token", value,    // Set-Cookie
    maxAge: 3600,
    httpOnly: true,
    secure: true
)
```

### 路由组

```cangjie
let api = app.group("/api/v1")

api.use(authMiddleware)

api.get("/users", listUsers)
api.post("/users", createUser)

// 嵌套分组
let admin = api.group("/admin")
admin.use(adminOnlyMiddleware)
admin.get("/stats", getStats)
// 最终路径：GET /api/v1/admin/stats
```

### 配置

```cangjie
let app = App(config: Config(
    appName:             "MyService",
    serverHeader:        "Ignite/0.4",
    bodyLimit:           10 * 1024 * 1024,   // 10MB
    readTimeout:         std.time.Duration.second * 30,
    writeTimeout:        std.time.Duration.second * 30,
    enableSwagger:       true,
    enableSwaggerCache:  true,   // Swagger JSON/UI 缓存，?refresh=1 强制刷新
    enablePrintRoutes:   true,
    jsonEncoder:         None   // 可选：自定义 JsonEncodable 序列化函数
))
```

## 中间件

### 内置中间件

Ignite 提供以下开箱即用中间件（`import ignite.middleware.*`）：

| 分类 | 中间件 | 说明 |
|------|--------|------|
| **安全** | `securityMiddleware` | 安全头：X-Content-Type-Options、X-Frame-Options、HSTS、CSP 等 |
| | `corsMiddleware` | 跨域 CORS |
| | `csrfMiddleware` | CSRF 双提交 Cookie 校验 |
| | `basicAuthMiddleware` | HTTP Basic 认证 |
| | `keyAuthMiddleware` | API Key 认证（Header/Query/Cookie） |
| | `encryptCookieMiddleware` | Cookie 加解密（XOR + Base64） |
| **日志监控** | `loggerMiddleware` | 请求方法、路径、耗时 |
| | `accessLogMiddleware` | 访问日志（IP、延迟、User-Agent） |
| | `requestIdMiddleware` | 请求 ID（X-Request-ID） |
| | `recoverMiddleware` | Panic 恢复 |
| **流量控制** | `rateLimitMiddleware` | 按 IP/自定义 key 限流 |
| | `bodyLimitMiddleware` | 请求体大小限制 |
| | `timeoutMiddleware` | 请求超时记录 |
| **缓存优化** | `cacheMiddleware` | 内存缓存 GET 响应 |
| | `etagMiddleware` | ETag + If-None-Match 304 |
| **会话** | `sessionMiddleware` | 会话 ID Cookie + SessionStore |
| **其他** | `redirectMiddleware` | URL 重定向规则 |
| | `rewriteMiddleware` | URL 重写（写入 ctx locals） |
| | `staticFileMiddleware` | 静态文件服务 |
| | `faviconMiddleware` | favicon.ico |
| | `healthCheckMiddleware` | 健康检查端点 |
| | `idempotencyMiddleware` | 幂等键（X-Idempotency-Key） |
| | `proxyMiddleware` | 反向代理 |

示例：

```cangjie
import ignite.middleware.*

// 日志与恢复
app.use(loggerMiddleware())
app.use(recoverMiddleware())

// CORS
app.use(corsMiddleware(config: CorsConfig(
    allowOrigins: "https://example.com",
    allowCredentials: true,
    maxAge: 86400
)))

// 安全头
app.use(securityMiddleware(config: SecurityConfig(hstsMaxAge: 31536000)))

// 请求 ID
app.use(requestIdMiddleware())
```

### 自定义中间件

```cangjie
let authMiddleware: Handler = { ctx =>
    let token = ctx.header("Authorization")
    if (let Some(t) <- token) {
        ctx.setLocal("user", "authenticated")
        ctx.next()
    } else {
        ctx.status(401).json(#"{"error": "Unauthorized"}"#)
    }
}

app.use(authMiddleware)
```

中间件执行遵循洋葱模型，通过 `ctx.next()` 传递控制权：

```
Request ──► Logger ──► CORS ──► Auth ──► Handler
                                          │
Response ◄── Logger ◄── CORS ◄── Auth ◄───┘
```

## 高级用法

### WebSocket

```cangjie
app.ws("/chat", { conn =>
    while (true) {
        let msg = conn.readMessage()
        if (msg.isClose) { break }
        if (msg.isText) {
            conn.writeText("Echo: ${msg.text()}")
        }
    }
    conn.close()
})
```

### Server-Sent Events (SSE)

```cangjie
app.get("/events", { ctx =>
    let sse = ctx.sse()
    sse.sendRetry(3000)
    for (i in 0..10) {
        sse.sendEvent(
            #"{"count": ${i}}"#,
            event: "counter",
            id: "${i}"
        )
    }
})
```

### 流式响应

```cangjie
app.get("/stream", { ctx =>
    let writer = ctx.writer()
    writer.writeString("chunk 1\n")
    writer.writeString("chunk 2\n")
    writer.writeString("chunk 3\n")
})
```

### Swagger / OpenAPI

```cangjie
let app = App(config: Config(
    enableSwagger: true,
    swaggerPath: "/docs"
))

app.swagger(SwaggerInfo(
    title: "My API",
    version: "1.0.0",
    description: "Powered by Ignite"
))

app.get("/users/:id", getUser, option: RouteOption()
    .withSummary("获取用户")
    .withDescription("根据 ID 获取用户详细信息")
    .withTags(["Users"])
    .withParams([ParamSpec(
        name: "id",
        location: ParamLocation.Path,
        required: true,
        description: "用户 ID"
    )])
    .withResponses([
        ResponseSpec(status: 200, description: "成功"),
        ResponseSpec(status: 404, description: "用户不存在")
    ])
)

// 访问 /docs 即可查看 Swagger UI
// 访问 /docs/json 获取 OpenAPI JSON
```

### TLS / HTTPS

```cangjie
let app = App(config: Config(
    tlsCertFile: "./cert.pem",
    tlsKeyFile:  "./key.pem"
))

// 自动启用 TLS + HTTP/2 ALPN 协商（ALPN: h2, http/1.1）
app.listen("0.0.0.0", 443)
```

**HTTP/2 可用性**：开启 TLS 后，服务端会协商 `h2`，客户端使用 HTTPS 即可走 HTTP/2。可用 `curl -sI --http2 https://localhost:3443/` 验证协议。

### 测试 HTTP/2 与中间件

仓库内可选测试项目 `IgniteTest`（需在项目外单独克隆或放在同级目录）用于验证所有中间件与 HTTP 行为：

- 无 TLS 时：`http://localhost:3000`，协议为 HTTP/1.1。
- 有 TLS 时：`https://localhost:3443`，可验证 HTTP/2。
- 运行自动化测试：在 IgniteTest 目录下执行 `./run_tests.sh`（需先 `cjpm run` 启动服务）。

### HTTP 客户端

```cangjie
import ignite.client.*

let client = RestClient()

let resp = client.get("https://api.example.com/users")
println(resp.body())
resp.discard()

// POST JSON
let resp2 = client.postJson(
    "https://api.example.com/users",
    #"{"name": "Ignite"}"#
)
println(resp2.status)
resp2.discard()

client.close()
```

**客户端能力一览**（对标标准 HTTP 客户端）：

| 能力 | API |
|------|-----|
| 方法 | `get`, `post`, `put`, `patch`, `delete`, `head`, `options` |
| JSON | `postJson(url, json)` |
| 表单 | `postForm(url, ArrayList<(String,String)>)` |
| Multipart | `postMultipart(url, fields, files)`，`MultipartFile(name, filename, contentType, data)` |
| 请求构建 | `request().method().url().query(k,v).header()/addHeader().basicAuth().bearerToken().form()/multipart().send()` |
| BaseURL | `baseUrl("https://api.example.com")`，后续相对路径自动拼接 |
| 默认头 | `defaultHeader(name, value)` |
| Cookie | `useCookies()` 或 `useCookies(store)`，自动收存 Set-Cookie 并随请求发送 |
| 响应 | `status`, `body()`/`bodyBytes()`/`bodyStream()`, `json()`, `header(name)`, `headerValues(name)`, `isOk()`/`isSuccess()`, `discard()` |

### 错误处理 & 优雅关闭

```cangjie
app.onError({ ctx, err =>
    println("[Error] ${err.message}")
    ctx.status(500).json(#"{"error": "${err.message}"}"#)
})

app.onShutdown({
    println("Releasing resources...")
    // 关闭数据库连接、清理缓存等
})
```

## 项目结构

```
ignite/
├── src/
│   ├── app.cj            # 应用核心：创建、路由注册、服务启停
│   ├── config.cj          # 配置项：超时、限制、TLS、Swagger 等
│   ├── ctx.cj             # 请求上下文：请求/响应 API
│   ├── route.cj           # 路由元数据与匹配结果
│   ├── router.cj          # Trie 路由引擎
│   ├── handler.cj         # Handler / ErrorHandler 类型定义
│   ├── group.cj           # 路由组：前缀分组 + 组级中间件
│   ├── stream.cj          # ResponseWriter / SseWriter
│   ├── websocket.cj       # WebSocket 连接封装
│   ├── swagger.cj         # OpenAPI 3.0 文档生成器
│   ├── middleware/
│   │   ├── logger.cj, cors.cj, recover.cj   # 基础
│   │   ├── security.cj, csrf.cj, basic_auth.cj, key_auth.cj, encrypt_cookie.cj
│   │   ├── access_log.cj, request_id.cj, rate_limit.cj, body_limit.cj, timeout.cj
│   │   ├── cache.cj, etag.cj, session.cj
│   │   ├── proxy.cj, redirect.cj, rewrite.cj, static_file.cj, favicon.cj
│   │   ├── health_check.cj, idempotency.cj, utils.cj
│   └── client/
│       └── client.cj      # HTTP 客户端 (RestClient)
└── cjpm.toml              # 包管理配置
```

## 支持平台

| 平台 | 架构 | 状态 |
|:---|:---|:---:|
| macOS | aarch64 (Apple Silicon) | ✅ |
| macOS | x86_64 (Intel) | ✅ |
| Linux | x86_64 | ✅ |
| Linux | aarch64 | ✅ |

## 叶燧星火
> Trusted by teams that move at the speed of light.

<a href="https://gitcode.com/copur/lanlu">兰鹿</a> - 基于仓颉语言的漫画归档管理系统

## 许可证

基于 [Apache License 2.0](LICENSE) 开源。

---

<p align="center">
  <sub>使用仓颉，点燃无限可能。</sub><br>
  <strong>Built with Cangjie. Ignited by passion.</strong>
</p>
