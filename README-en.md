<p align="center">
  <img src="https://img.shields.io/badge/Cangjie-Ignite-ff6b35?style=for-the-badge&labelColor=1a1a2e" alt="Ignite" />
  <img src="https://img.shields.io/badge/version-0.4.27-blue?style=for-the-badge&labelColor=1a1a2e" alt="Version" />
  <img src="https://img.shields.io/badge/license-Apache%202.0-green?style=for-the-badge&labelColor=1a1a2e" alt="License" />
</p>
<div align="center">
<pre style="background:#00000000">
┌───────────────────────────────────────────────────────┐
│                <span style="color:#88C0D0;">Ignite HttpServer v0.4.27</span>              │
│                  <span style="color:#6EB186;">http://127.0.0.1:8080</span>                │
│          <span style="color:#AAAAAA;">(bound on host 0.0.0.0 and port 8080)</span>        │
│                                                       │
│    Handlers <span style="color:#555;">...........</span> 16  Processes <span style="color:#555;">...........</span> 1   │
│    Prefork <span style="color:#555;">......</span> Disabled  PID <span style="color:#555;">.............</span> 67271   │
└───────────────────────────────────────────────────────┘
</pre>
</div>

<h1 align="center">Ignite (叶燧)</h1>

<p align="center">
  <strong>A high-performance web framework for the Cangjie language</strong><br>
  <sub>Minimal API · Trie router · WebSocket · SSE · Swagger · TLS/HTTP2</sub>
</p>

<p align="center">
  <a href="#quick-start">Quick Start</a> ·
  <a href="#core-features">Core Features</a> ·
  <a href="#api-overview">API Overview</a> ·
  <a href="#middleware">Middleware</a> ·
  <a href="#advanced-usage">Advanced Usage</a> ·
  <a href="#showcase">Showcase</a> ·
  <a href="#license">License</a>
</p>

<p align="center">
  <a href="https://atomgit.com/Cinexus/ignite-cangjie">Repository</a> ·
  <a href="https://pkg.cangjie-lang.cn/package/ignite">Package registry</a>
</p>

---

## Why Ignite?

> **"Light the first fire of Cangjie web development."**

Cangjie is a programming language by Huawei. **Ignite** is a web framework built for the Cangjie ecosystem—inspired by Go [Fiber](https://gofiber.io/)'s minimal design, bringing its core ideas into Cangjie's type system so you can build high-performance HTTP services with minimal code.

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

## Quick Start

### Requirements

- Cangjie compiler (`cjc`) v1.1.0+
- Cangjie standard extension library (`stdx`)
- Platforms: macOS (arm64/x86_64), Linux (arm64/x86_64), Windows (x86_64)

> **Note:** If you use a private or authenticated package registry, copy `cangjie-repo.toml.example` to `cangjie-repo.toml` and configure it locally. **Do not commit `cangjie-repo.toml`** to the repo (it is in .gitignore).

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

Just **6 lines of code** to spin up an HTTP server.

## Core Features

| Feature | Description |
|:---|:---|
| **Trie router** | Efficient prefix-tree routing with path params `:id` and wildcard `*` |
| **Chained API** | Fluent chaining: `app.get(...).post(...).use(...)` |
| **Middleware** | Global + route-group middleware; `ctx.next()` controls flow |
| **Route groups** | `app.group("/api")` with nested groups and auto-prefix |
| **WebSocket** | One-line WebSocket upgrade |
| **SSE** | Built-in Server-Sent Events |
| **Streaming** | Chunked Transfer Encoding |
| **Swagger** | OpenAPI 3.0 + Swagger UI with cache (`enableSwaggerCache`), `?refresh=1` to force refresh |
| **TLS/HTTP2** | Native TLS with HTTP/2 ALPN |
| **HTTP client** | Built-in `RestClient` with builder-style API |
| **JSON** | `ctx.jsonSerialize` / `ctx.jsonEncode`, optional `Config.jsonEncoder`; `ignite.serializeJson` / `deserializeJson` |
| **Files & Range** | `ctx.sendFile`, `ctx.download` (attachment name), `ctx.sendFileRange` (HTTP Range 206/416) |
| **static / staticSpa** | `app.static(prefix, root)` for static only; `app.staticSpa(prefix, root, indexFile)` for static-first + SPA fallback to index |
| **Graceful shutdown** | `onShutdown` hook for cleanup |

## API Overview

### Route registration

```cangjie
let app = App()

// Basic routes
app.get("/users", listUsers)
app.post("/users", createUser)
app.put("/users/:id", updateUser)
app.delete("/users/:id", deleteUser)

// All HTTP methods
app.all("/health", healthCheck)
```

### Path & query params

```cangjie
app.get("/users/:id", { ctx =>
    let userId = ctx.params("id")
    let fields = ctx.queryDefault("fields", "all")
    ctx.json(#"{"id": "${userId}", "fields": "${fields}"}"#)
})
```

### Request context (Ctx)

`Ctx` is the core object for the request lifecycle:

```cangjie
app.post("/upload", { ctx =>
    // Request info
    let method   = ctx.method       // "POST"
    let path     = ctx.path         // "/upload"
    let clientIp = ctx.ip           // "127.0.0.1"
    let token    = ctx.header("Authorization")

    // Body
    let body = ctx.bodyString()

    // Response
    ctx.status(201).json(#"{"status": "created"}"#)
})
```

**Response helpers:**

```cangjie
ctx.json(body)                   // application/json
ctx.jsonSerialize(obj)           // Serialize when T implements StdxJsonSerializable
ctx.jsonEncode(obj)              // JsonEncodable or Config.jsonEncoder
ctx.sendString(body)             // text/plain
ctx.html(body)                   // text/html
ctx.send(byteArray)              // raw bytes
ctx.sendStatus(404)               // status + default message
ctx.redirect("/login")           // 302 redirect
ctx.noContent()                  // 204 No Content
ctx.sendFile(path)               // send file by path
ctx.download(path, filename)     // attachment (optional filename)
ctx.sendFileRange(path)          // HTTP Range → 206/416
ctx.setCookie("token", value,    // Set-Cookie
    maxAge: 3600,
    httpOnly: true,
    secure: true
)
```

### Route groups

```cangjie
let api = app.group("/api/v1")

api.use(authMiddleware)

api.get("/users", listUsers)
api.post("/users", createUser)

// Nested group
let admin = api.group("/admin")
admin.use(adminOnlyMiddleware)
admin.get("/stats", getStats)
// Path: GET /api/v1/admin/stats
```

### Config

```cangjie
let app = App(config: Config(
    appName:             "MyService",
    appVersion:          "1.0.0",   // optional; shown in banner title; empty = framework version
    serverHeader:        "Ignite/0.4",
    bodyLimit:           10 * 1024 * 1024,   // 10MB
    readTimeout:         std.time.Duration.second * 30,
    writeTimeout:        std.time.Duration.second * 30,
    enableSwagger:       true,
    enableSwaggerCache:  true,   // Cache Swagger JSON/UI; ?refresh=1 to refresh
    enablePrintRoutes:   false,  // when true, print route table at startup; banner always shown
    jsonEncoder:         None   // Optional custom JsonEncodable encoder
))
```

## Middleware

### Built-in middleware

Import with `import ignite.middleware.*`:

| Category | Middleware | Description |
|------|--------|------|
| **Security** | `securityMiddleware` | X-Content-Type-Options, X-Frame-Options, HSTS, CSP, etc. |
| | `corsMiddleware` | CORS |
| | `csrfMiddleware` | CSRF double-submit cookie |
| | `basicAuthMiddleware` | HTTP Basic auth |
| | `keyAuthMiddleware` | API Key (Header/Query/Cookie) |
| | `encryptCookieMiddleware` | Cookie encrypt/decrypt (XOR + Base64) |
| **Logging** | `loggerMiddleware` | Method, path, duration |
| | `accessLogMiddleware` | IP, latency, User-Agent |
| | `requestIdMiddleware` | X-Request-ID |
| | `recoverMiddleware` | Panic recovery |
| **Flow** | `rateLimitMiddleware` | Rate limit by IP or custom key |
| | `bodyLimitMiddleware` | Request body size limit |
| | `timeoutMiddleware` | Request timeout |
| **Cache** | `cacheMiddleware` | In-memory GET response cache |
| | `etagMiddleware` | ETag + If-None-Match 304 |
| **Session** | `sessionMiddleware` | Session ID cookie + SessionStore |
| **Other** | `redirectMiddleware` | URL redirect rules |
| | `rewriteMiddleware` | URL rewrite (ctx locals) |
| | `staticFileMiddleware` | Static files |
| | `faviconMiddleware` | favicon.ico |
| | `healthCheckMiddleware` | Health check endpoint |
| | `idempotencyMiddleware` | X-Idempotency-Key |
| | `proxyMiddleware` | Reverse proxy |

Example:

```cangjie
import ignite.middleware.*

app.use(loggerMiddleware())
app.use(recoverMiddleware())

app.use(corsMiddleware(config: CorsConfig(
    allowOrigins: "https://example.com",
    allowCredentials: true,
    maxAge: 86400
)))

app.use(securityMiddleware(config: SecurityConfig(hstsMaxAge: 31536000)))
app.use(requestIdMiddleware())
```

### Custom middleware

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

Middleware runs in onion order; `ctx.next()` passes control:

```
Request ──► Logger ──► CORS ──► Auth ──► Handler
                                          │
Response ◄── Logger ◄── CORS ◄── Auth ◄───┘
```

## Advanced Usage

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

### Streaming response

```cangjie
app.get("/stream", { ctx =>
    let writer = ctx.writer()
    writer.writeString("chunk 1\n")
    writer.writeString("chunk 2\n")
    writer.writeString("chunk 3\n")
})
```

### Static files & SPA fallback (static / staticSpa)

**Static directory only:** `app.static(prefix, root)` maps URL path to files under `root`; only responds when the file exists, otherwise the request is passed to later routes or 404.

**Static-first + SPA fallback:** For Next.js static export, Vite/React, or other SPAs, you often want “serve file if present, otherwise return index.html for client-side routing.” Use `app.staticSpa(prefix, root, indexFile)`:

```cangjie
// Under /: try file under frontend/out first; if missing, return frontend/out/index.html
app.staticSpa("/", "frontend/out", "index.html")
```

- `prefix`: URL prefix (e.g. `"/"`); root path registers both GET/HEAD `/` and `/*`.
- `root`: Static file root (e.g. Next.js `out`, Vite `dist`).
- `indexFile`: Fallback file when no file matches; default `"index.html"`.
- Path safety: Requests containing `..` are rejected and fall back to the index file.

Register API routes first, then `staticSpa` last, so APIs are not shadowed by the catch-all.

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
    .withSummary("Get user")
    .withDescription("Get user by ID")
    .withTags(["Users"])
    .withParams([ParamSpec(
        name: "id",
        location: ParamLocation.Path,
        required: true,
        description: "User ID"
    )])
    .withResponses([
        ResponseSpec(status: 200, description: "Success"),
        ResponseSpec(status: 404, description: "Not found")
    ])
)

// Visit /docs for Swagger UI, /docs/json for OpenAPI JSON
```

### TLS / HTTPS

```cangjie
let app = App(config: Config(
    tlsCertFile: "./cert.pem",
    tlsKeyFile:  "./key.pem"
))

// TLS + HTTP/2 ALPN (h2, http/1.1)
app.listen("0.0.0.0", 443)
```

**HTTP/2**: With TLS, the server negotiates `h2`. Verify with `curl -sI --http2 https://localhost:3443/`.

### Testing HTTP/2 and middleware

The optional test project `IgniteTest` (clone separately or place alongside) verifies middleware and HTTP behavior:

- Without TLS: `http://localhost:3000` (HTTP/1.1).
- With TLS: `https://localhost:3443` (HTTP/2).
- Run tests: in IgniteTest, `./run_tests.sh` (start server with `cjpm run` first).

### HTTP client

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

**Client API:**

| Capability | API |
|------|-----|
| Methods | `get`, `post`, `put`, `patch`, `delete`, `head`, `options` |
| JSON | `postJson(url, json)` |
| Form | `postForm(url, ArrayList<(String,String)>)` |
| Multipart | `postMultipart(url, fields, files)`, `MultipartFile(name, filename, contentType, data)` |
| Builder | `request().method().url().query(k,v).header()/addHeader().basicAuth().bearerToken().form()/multipart().send()` |
| Base URL | `baseUrl("https://api.example.com")` |
| Default headers | `defaultHeader(name, value)` |
| Cookies | `useCookies()` or `useCookies(store)` |
| Response | `status`, `body()`/`bodyBytes()`/`bodyStream()`, `json()`, `header(name)`, `headerValues(name)`, `isOk()`/`isSuccess()`, `discard()` |

### Error handling & graceful shutdown

```cangjie
app.onError({ ctx, err =>
    println("[Error] ${err.message}")
    ctx.status(500).json(#"{"error": "${err.message}"}"#)
})

app.onShutdown({
    println("Releasing resources...")
    // Close DB, clear caches, etc.
})
```

## Project structure

```
ignite/
├── src/
│   ├── app.cj            # App core: create, routes, start/stop
│   ├── config.cj         # Config: timeouts, limits, TLS, Swagger
│   ├── ctx.cj            # Request context: request/response API
│   ├── route.cj          # Route metadata and match result
│   ├── router.cj         # Trie router
│   ├── handler.cj        # Handler / ErrorHandler types
│   ├── group.cj          # Route groups: prefix + group middleware
│   ├── stream.cj         # ResponseWriter / SseWriter
│   ├── websocket.cj      # WebSocket connection
│   ├── swagger.cj        # OpenAPI 3.0 generator
│   ├── middleware/
│   │   ├── logger.cj, cors.cj, recover.cj
│   │   ├── security.cj, csrf.cj, basic_auth.cj, key_auth.cj, encrypt_cookie.cj
│   │   ├── access_log.cj, request_id.cj, rate_limit.cj, body_limit.cj, timeout.cj
│   │   ├── cache.cj, etag.cj, session.cj
│   │   ├── proxy.cj, redirect.cj, rewrite.cj, static_file.cj, favicon.cj
│   │   ├── health_check.cj, idempotency.cj, utils.cj
│   └── client/
│       └── client.cj     # RestClient
└── cjpm.toml
```

## Supported platforms

| Platform | Arch | Status |
|:---|:---|:---:|
| macOS | aarch64 (Apple Silicon) | ✅ |
| macOS | x86_64 (Intel) | ✅ |
| Linux | x86_64 | ✅ |
| Linux | aarch64 | ✅ |

## Showcase

> Trusted by teams that move at the speed of light.

<a href="https://gitcode.com/copur/lanlu">兰鹿 (Lanlu)</a> — Manga archive management system built with Cangjie

## License

Open source under [Apache License 2.0](LICENSE).

---

<p align="center">
  <sub>Build with Cangjie. Ignite the possible.</sub><br>
  <strong>Built with Cangjie. Ignited by passion.</strong>
</p>
