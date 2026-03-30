<p align="center">
  <img src="https://img.shields.io/badge/Cangjie-Ignite-ff6b35?style=for-the-badge&labelColor=1a1a2e" alt="Ignite" />
  <img src="https://img.shields.io/badge/version-0.5.21-blue?style=for-the-badge&labelColor=1a1a2e" alt="Version" />
  <img src="https://img.shields.io/badge/license-Apache%202.0-green?style=for-the-badge&labelColor=1a1a2e" alt="License" />
</p>
<div align="center">
<pre style="background:#00000000">
┌───────────────────────────────────────────────────────┐
│               <span style="color:#88C0D0;">Ignite HttpServer v0.5.21</span>              │
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
  <strong>以仓颉语言打造、面向真实服务落地的 Web 框架</strong><br>
  <sub>比直接使用 stdx.httpServer 更省开发成本 · Fiber 风格体验 · Server/Client 一体化演进</sub>
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

<p align="center">
  <a href="https://atomgit.com/Cinexus/ignite-cangjie">开源仓库</a> ·
  <a href="https://pkg.cangjie-lang.cn/package/ignite">中心仓</a>
</p>

---



## 为什么选择 Ignite?

> **"点燃仓颉 Web 开发的第一把火。"**

仓颉（Cangjie）正在进入需要“真正能承载业务”的阶段，而 **Ignite** 的目标不是只做一个 Demo 框架，而是提供一条从首个接口、到安全治理、再到长期维护都更统一的 Web 服务路径。  
与直接使用官方 `stdx.httpServer` 相比，Ignite 更强调 **减少样板代码、统一中间件组织、沉淀默认实践、降低服务重复搭建成本**。  
与 [Fiber](https://gofiber.io/) 这类强调轻量体验的主流框架相比，Ignite 更想回答的是：在仓颉生态里，能不能同样快速上手，同时把审计、安全、Swagger、静态托管、Client 能力一起收进统一框架。

如果你关心的是：

- 首个 API 能否快速跑通
- 中间件、路由、Swagger、静态托管是否够顺手
- 从 PoC 走到生产时，安全、审计、错误收口是否有统一路径
- 相较直接使用 `stdx.httpServer`，能否显著减少重复样板
- 是否能在保持轻量体验的同时，补足生产常用能力

那么 Ignite 现在已经进入值得认真评估和推广的阶段。

### Ignite 的强力点

| 方向 | Ignite 现在的优势 |
|:---|:---|
| **开发体验** | 保留轻量路由与中间件心智，`App / Router / Ctx` 足够直接，适合快速起服务 |
| **相较 stdx.httpServer** | 不需要每个项目再手动拼路由组织、错误收口、常用中间件、安全头、Swagger、静态托管 |
| **生产治理** | 内建 `logger / audit / recover / requestId / kmode / failover`，不是只给基础路由 |
| **安全能力** | Cookie AEAD v1 双读新写、TLS precheck、X509 校验入口、安全指标与错误码 |
| **一体化能力** | 框架内同时提供 `RestClient`，支持 Hook、重试、Cookie v2、加密、X509、观测 |

### 当前状态（0.5.21）

- `0.5.21` 是 `0.5.x` 迭代列车中的正式里程碑，用来标记这一轮可发布的能力收口，不是“突然跨代”的营销编号
- 相较上一阶段，`0.5.21` 补齐了压缩中间件、JWT 中间件、`bindJsonOr400`、`handleForTest`、`urlFor`、IgniteKit 等高频能力
- Server / Client 双线已经形成更完整的默认能力面，减少“服务端一套、客户端再重造一套”的割裂感
- 当前仍处于 `0500` 生产级收尾阶段，重点是把 README、样例、发布前校验与 TLS 边界说明收口到可信状态，而不是在本轮承诺默认替代 Server 栈
- 下一阶段将进入 `0600` 的共享传输抽象与复用验证，但本次版本关键词仍然是 **可用、可信、可上手**

我们相信，好的框架应该像一片叶子轻盈穿梭，又能像燧石碰撞瞬间点燃。  
因此我们取 **“叶”** 之灵动，取 **“燧”** 之开创，命名它为 **叶燧 (Ignite)**。

```
                ┌─────────────────────────────────────────┐
                │            Ignite Architecture          │
                │                                         │
                │   Request ──► Router (Trie) ──► Match   │
                │                                   │     │
                │              Middleware Chain ◄───┘     │
                │              │     │     │              │
                │              ▼     ▼     ▼              │
                │          Logger   CORS   Recover        │
                │            │                            │
                │            ▼                            │
                │       Handler ──► Ctx ──► Response      │
                │                    │                    │
                │           ┌────────┼────────┐           │
                │           ▼        ▼        ▼           │
                │         JSON     SSE    WebSocket       │
                └─────────────────────────────────────────┘
```

### Ignite 适合什么项目

- 需要快速搭建 REST API、后台服务、运维接口、内部平台
- 需要把 Swagger、静态资源、SSE、WebSocket、文件下载统一收进一个仓库
- 希望在仓颉生态里少做一遍“审计、恢复、限流、日志、安全”样板工程
- 希望服务端与客户端能力尽量统一，减少重复封装

### 为什么不直接用 stdx.httpServer

`stdx.httpServer` 当然是可靠的底层能力，但在真实项目里，团队通常还要继续补这些东西：

- 路由组织与分组约定
- 中间件链与统一错误处理
- 安全头、鉴权、日志、审计、限流
- Swagger / OpenAPI、静态托管、SSE / WebSocket
- 测试入口、Client 封装、项目级默认模板

Ignite 的价值不是替代官方底层，而是把这些高频重复劳动收敛成一套更适合业务团队长期维护的默认路径。

## 快速开始

### 环境要求

- 仓颉sdk环境 [`cangjie-sdk`](https://cangjie-lang.cn/download) v1.1.0+
- 仓颉标准扩展库 [`cangjie-stdx`](https://gitcode.com/Cangjie/cangjie_stdx/releases/v1.0.5.1)
  >如需[`仓颉 nightly[含stdx链接]`](https://gitcode.com/Cangjie/nightly_build)
- 支持平台：macOS (arm64/x86_64)、Linux (arm64/x86_64)、Windows(x86_64)、HarmonyOS

### 插入依赖

#### 在 `cangjie.toml` 中添加依赖
``` toml
[package]
..... # 在[package] 最后一行的依赖组添加
[dependencies]
    Ignite = "https://gitcode.com/Cinyu/Ignite-cangjie"
```

#### 当然你也可以考虑使用 `中心仓`
请参考 `cangjie-repo.toml.example` 在本地创建 `cangjie-repo.toml` 并配置
> **注意**：若使用私有/需认证的包仓库，**切勿将 `cangjie-repo.toml` 提交到仓库**（已列入 .gitignore）。

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

### 常见失败 -> 一行修复

如果 Quickstart 或样例没有一次跑通，优先看这几条：

- **找不到 stdx 静态库**  
  修复：设置 `IGNITE_STDX_STATIC=/path/to/cj_stdx_*_llvm/static`
- **运行时库路径缺失**  
  修复：设置 `IGNITE_CJ_RUNTIME_LIB_DIR=/path/to/cangjie/runtime/lib/<platform>`
- **样例脚本在错误目录执行**  
  修复：从包含 `cjpm.toml` 的仓库根执行（当前布局为 `Ignite/`）
- **TLS 启动排障困难**  
  修复：先保留 `enableTlsPrecheck: true` 查看结构化错误；仅在应急排障时临时回退到 `false`

若仍有问题，建议先运行：

```bash
cjpm build
cjpm test
```

再对照本 README、样例 README 与文档站入口，定位问题属于依赖、运行时还是示例路径。

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
| **static / staticSpa** | `app.static(prefix, root)` 纯静态；`app.staticSpa(prefix, root, indexFile)` 静态优先 + SPA 回退 index |
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
    appVersion:          "1.0.0",   // 可选；Banner 标题显示应用版本，空则显示框架版本
    serverHeader:        "Ignite/0.4",
    bodyLimit:           10 * 1024 * 1024,   // 10MB
    readTimeout:         std.time.Duration.second * 30,
    writeTimeout:        std.time.Duration.second * 30,
    enableSwagger:       true,
    enableSwaggerCache:  true,   // Swagger JSON/UI 缓存，?refresh=1 强制刷新
    enablePrintRoutes:   false,  // 为 true 时启动时额外打印路由表；Banner 始终输出且不可关闭
    kmode:               false,  // 为 true 时调试模式：Banner 必打 Ignite 版本，可配合 kmodeMiddleware
    kmodePanicHandler:   None,   // 可选：App 顶层 panic 兜底钩子，返回 true 表示已处理
    enableTlsPrecheck:   true,   // TLS precheck 开关：默认先做 jinguissl 预检，再走当前 stdx TLS 构造路径
    jsonEncoder:         None   // 可选：自定义 JsonEncodable 序列化函数
))
```

#### KeyMode 超级用户
- 暂定为开发者专用的定义组件

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
| | `jwtMiddleware` | JWT 鉴权（当前 HS256；支持 Header/Query/Cookie 提取与 claims 注入） |
| | `encryptCookieMiddleware` | Cookie 加解密（AEAD v1，支持旧 XOR 双读迁移） |
| **日志监控** | `loggerMiddleware` | 请求方法、路径、耗时；支持 Logger 接口 + DefaultLogger，可注入自定义实现；`enableEntityLog` 可开实体日志，`jsonLine` 可输出 JSON 行 |
| | `auditMiddleware` | 统一审计事件（eventId/requestId/actor/ip/action/result/riskLevel + securityEvent/securityCode/securitySource），支持结构化输出与 Linux 风格终端打印 |
| | `accessLogMiddleware` | 访问日志（IP、延迟、User-Agent） |
| | `requestIdMiddleware` | 请求 ID（X-Request-ID） |
| | `recoverMiddleware` | Panic 恢复 |
| **流量控制** | `rateLimitMiddleware` | 按 IP/自定义 key 限流 |
| | `bodyLimitMiddleware` | 请求体大小限制 |
| | `timeoutMiddleware` | 请求超时记录 |
| **缓存优化** | `cacheMiddleware` | 内存缓存 GET 响应 |
| | `compressMiddleware` | 响应压缩（gzip/deflate，按 `Accept-Encoding` 协商，可配置最小体积阈值） |
| | `etagMiddleware` | ETag + If-None-Match 304 |
| **会话** | `sessionMiddleware` | 会话 ID Cookie + SessionStore |
| **其他** | `redirectMiddleware` | URL 重定向规则 |
| | `rewriteMiddleware` | URL 重写（写入 ctx locals） |
| | `staticFileMiddleware` | 静态文件服务 |
| | `faviconMiddleware` | favicon.ico |
| | `healthCheckMiddleware` | 健康检查端点 |
| | `idempotencyMiddleware` | 幂等键（X-Idempotency-Key） |
| | `proxyMiddleware` | 反向代理（支持可选 X509 校验入口） |
| **调试** | `kmodeMiddleware` | 兼容旧模式（Bool）+ 新策略模式（`KModePolicy`：Header Key + IP 白名单 + capability） |

示例：

```cangjie
import ignite.middleware.*

// 调试模式（Config.kmode = true 时启动会打印 Ignite 版本与 Swagger URL）
app.use(kmodeMiddleware(app.config.kmode))

// 启用日志系统
app.use(loggerMiddleware())

// JWT（HS256）
app.use(jwtMiddleware(JwtConfig(
    secret: "replace-me"
)))

// 响应压缩（建议放在 cache/etag 前）
app.use(compressMiddleware())

// 审计系统（结构化事件）
app.use(auditMiddleware())

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

### JWT 鉴权中间件（0.5.21）

```cangjie
import ignite.middleware.*

app.use(jwtMiddleware(JwtConfig(
    secret: "replace-with-strong-secret",
    requiredIssuer: "ignite",
    requiredAudience: "web",
    queryName: "access_token",   // 可选：URL 查询参数读取
    cookieName: "access_token"   // 可选：Cookie 读取
)))
```

- 当前算法支持：`HS256`
- 默认会校验：`exp` / `nbf` / `iat`（可配置 `clockSkewSec`）
- 通过后注入上下文：`jwt_claims`、`jwt_sub`、`jwt_token`
- 安全建议：仅在 HTTPS 下传输、使用短期 token、定期轮换密钥

### kMode 策略模式（0.5.1）

在保留 `kmodeMiddleware(Bool)` 的同时，新增策略版接口：

```cangjie
import ignite.governance.*

let policy = KModePolicy(
    enabled: true,
    headerName: "X-KMode-Key",
    headerKey: "replace-me",
    allowIPs: ["127.0.0.1", "::1"],
    capabilities: [Diag, Read]
)
app.use(kmodeMiddleware(policy))
```

### kMode 应急兜底（Recover + Client 探测）

当 `ig/app` 运行异常被 `recoverMiddleware` 捕获时，可在 `kmode=true` 下触发应急探测：

```cangjie
import ignite.governance.*
import ignite.middleware.*

let failoverOption = KModeFailoverOption(
    enabled: true,
    probeUrl: "http://localhost:8828",
    probeMethod: "POST",
    probePayload: "ignite-emergency",
    expectedResponse: "RESTART",
    probeTimeoutSec: 2,
    maxAttempts: 5,
    intervalMs: 500,
    restartOnMatch: true,
    terminateOnMiss: true
)

app.use(recoverMiddleware(config: RecoverConfig(
    kmodeFailover: Some(failoverOption)
)))
```

- 返回内容命中 `expectedResponse`：默认返回 `503` 并触发 `app.shutdown()`（由外部守护进程拉起重启）
- 未命中且达到阈值：默认返回 `503` 并触发 `app.shutdown()`
- 可通过 `onKModeRestart` / `onKModeTerminate` 自定义重启与终止行为

若未使用 `recoverMiddleware`，可通过 `Config.kmodePanicHandler` 在 App 顶层 catch 中接入同类兜底策略。

### 安全可观测（0.5.04）

`ignite.security` 提供结构化计数器：`decryptFailures`、`signatureFailures`、`certRejects`。

```cangjie
import ignite.security.*

let snap = securityMetricsSnapshot()
println("decrypt=${snap.decryptFailures}, sign=${snap.signatureFailures}, cert=${snap.certRejects}")
```

### Logger 0~9 等级与 kMode 双模式过滤

- 普通模式：默认输出 `0~6`（Emerg~Info）
- kMode 模式：默认输出 `0~9`（含 Debug/Trace/Verbose）
- 保持 `loggerMiddleware(config: LoggerConfig(...))` 调用方式不变

## 高级用法

### 函数覆写

// 日志与恢复（可传入 LoggerConfig：logger 自定义实现、enableEntityLog 实体日志）

``` cangjie
app.use(loggerMiddleware())
app.use(recoverMiddleware())
```
#### 自定义 Logger 实现与注入：
你可以自定义实现 Logger 接口（实现 log(msg: String): Unit 方法），以完全控制日志输出格式、目标（如写入文件、远程上报等）。
通过 LoggerConfig(logger: ...) 注入到 loggerMiddleware。例如：

```cangjie
public class MyLogger: Logger {
    public func log(msg: String) {
        // 自定义输出逻辑
        println("[MyLogger] " + msg)
    }
}
let loggerConfig = LoggerConfig(logger: MyLogger())
app.use(loggerMiddleware(config: loggerConfig))
```

你也可以通过 LoggerConfig 的 output 参数快速自定义输出行为：

```cangjie
app.use(loggerMiddleware(config: LoggerConfig(output: { msg => 
    writeFile("/var/log/myapp.log", msg + "\n", append: true)
})))
```

需要结构化日志接入 ELK/Loki 时，可启用 JSON 行输出：

```cangjie
let cfg = LoggerConfig()
cfg.jsonLine = true
app.use(loggerMiddleware(config: cfg))
```

### 请求绑定与校验（bindJsonOr400）

`Ctx.bindJsonOr400<T>(decoder, validate?)` 可把 JSON 解码与 400 错误响应收敛到一处：

```cangjie
import stdx.encoding.json.{JsonValue, JsonObject}

public class CreateUserReq {
    public let name: String
    public let age: Int64
    public init(name: String, age: Int64) {
        this.name = name
        this.age = age
    }
}

func decodeCreateUserReq(v: JsonValue): CreateUserReq {
    let obj = v.asObject()
    let name = obj.get("name").orThrow().asString()
    let age = obj.get("age").orThrow().asInt64()
    CreateUserReq(name, age)
}

app.post("/users", { ctx =>
    if (let Some(req) <- ctx.bindJsonOr400<CreateUserReq>(
        decodeCreateUserReq,
        validate: { r =>
            if (r.name.trimAscii().size == 0) { return Some("name is required") }
            if (r.age <= 0) { return Some("age must be positive") }
            None
        }
    )) {
        _ = ctx.status(201).sendString("created:${req.name}:${req.age}")
    }
})
```

失败时会自动返回 `400` JSON，`reason` 为：
- `invalid_json`
- `invalid_payload`
- `validation_failed`

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

### 静态文件与 SPA 兜底 (static / staticSpa)

**纯静态目录**：`app.static(prefix, root)` 按 URL 路径映射到 `root` 下文件，仅当存在对应文件时响应，否则由后续路由或 404 处理。

**静态优先 + SPA 回退**：前端为 Next.js 静态导出、Vite/React 等单页应用时，常需「有文件则发文件，否则一律返回 index.html 由前端路由接管」。使用 `app.staticSpa(prefix, root, indexFile)` 即可：

> 根路径下：先尝试 frontend/out 中对应文件，不存在则返回 frontend/out/index.html
```cangjie
app.staticSpa("/", "frontend/out", "index.html")
```

- `prefix`：URL 前缀（如 `"/"`）；根路径会同时注册 GET/HEAD `/` 与 `/*`。
- `root`：静态文件根目录（如 Next.js 的 `out`、Vite 的 `dist`）。
- `indexFile`：未命中文件时的回退文件，默认 `"index.html"`。
- 路径安全：含 `..` 的请求会被拒绝并回退到 index 文件。

适合与 API 路由并存：先注册 API，最后再挂 `staticSpa`，避免 API 被通配吞掉。

### IgniteKit：动态页面/样式的轻量编排

当你不希望把大量 HTML/CSS 拼接逻辑塞进主路由时，可用 `IgniteKit` 把页面资源集中管理，再一键挂到 `App`：

```cangjie
let kit = IgniteKit(prefix: "/web")
_ = kit.css("/app.css", "body{font-family:monospace;}")
_ = kit.html("/index.html", "<h1>{{title}}</h1>", vars: [("title", "IgniteKit")])
_ = kit.dynamicHtml("/hello.html", { ctx =>
    let name = (ctx.queryFromUrl("name") ?? "ignite").trimAscii()
    kit.renderTemplate("<h1>Hello, {{name}}</h1>", vars: [("name", name)])
})
_ = kit.mount(app)
```

常见用途：管理后台小页面、运维诊断页、SSR 前的轻量动态页、样式/模板快速试验。

#### 但是就想要SPA怎么办？

默认 Ignite处理顺序是**由上到下**，因**安全考虑**，如有贪婪匹配需求**请置底**：
``` cangjie
app.static("/app", "frontend/out")
app.static("/", "frontend/out")
app.static("/*", "frontend/out")
```

### 路由命名与 URL 反向生成（urlFor）

可用两种方式命名路由：
- `RouteOption.withOperationId("name")`
- `app.nameRoute(method, path, name)`

```cangjie
app.get(
    "/users/:id/posts/:postId",
    getUserPost,
    option: RouteOption().withOperationId("user.post.detail")
)

let detailUrl = app.urlFor(
    "user.post.detail",
    params: [("id", "42"), ("postId", "7")],
    query: [("include", "meta data")]
) ?? "/fallback"
// /users/42/posts/7?include=meta+data

app.get("/assets/*", getAsset)
let _ = app.nameRoute("GET", "/assets/*", "asset.file")
let assetUrl = app.urlFor("asset.file", params: [("*", "img/logo.png")]) ?? "/assets/default.png"
```

若路由不存在或缺少路径参数，`urlFor` 返回 `None`。

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
    tlsKeyFile:  "./key.pem",
    enableTlsPrecheck: true // 默认启用：先走 jinguissl 预检，再构造当前 stdx TLS 配置
))

// 自动启用 TLS + HTTP/2 ALPN 协商（ALPN: h2, http/1.1）
app.listen("0.0.0.0", 443)
```

**HTTP/2 可用性**：开启 TLS 后，服务端会协商 `h2`，客户端使用 HTTPS 即可走 HTTP/2。可用 `curl -sI --http2 https://localhost:3443/` 验证协议。

`enableTlsPrecheck` 可关闭（`false`）以回退到“仅当前默认 TLS 构造”路径；建议仅在应急排障或兼容窗口期使用。

当前公开主线路径仍以 **Ignite + stdx TLS 构造** 为准；`jinguissl` 目前承担的是预检与并行演进角色，不等同于默认 HTTPS 唯一路径。  
如果后续出现 `jinguissl`、仓颉版本或平台兼容问题，推荐优先通过 `lisi` 兼容层收敛，而不是把兼容分支直接散进 Ignite 主线。

TLS 启动失败排障矩阵（启动日志字段：`tls_stage` / `tls_error_code` / `hint`）：

| `tls_error_code` | 常见原因 | 建议动作 |
|------|------|------|
| `BAD_INPUT` | PEM 为空或 ALPN 配置非法 | 检查证书/私钥内容与 `h2,http/1.1` 协议列表 |
| `VERIFY_FAILED` | 证书链与私钥不匹配 | 重新配对证书与私钥，确认链顺序 |
| `INTERNAL_ERROR` | stdx TLS 构造阶段异常 | 检查运行时依赖、证书解析与文件读取路径 |

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

// X509 校验入口（Client）
client.useX509Verify(X509VerifyOption(
    enabled: true,
    requireHttps: true,
    expectedServerName: "api.example.com",
    pinnedSha256: ["sha256:your-pin"],
    hook: { ctx =>
        // 在此接入你的证书链校验 / pin 比对逻辑
        true
    }
))

client.close()
```

更多组合示例（加密请求 / Retry+Hook+Cookie / 观测字段 / 流式下载）可参考：
`samples/client/README.md`

**客户端能力一览**（对标标准 HTTP 客户端）：

| 能力 | API |
|------|-----|
| 方法 | `get`, `post`, `put`, `patch`, `delete`, `head`, `options` |
| JSON | `postJson(url, json)` |
| 加密 JSON | `useCrypto(config)` + `postEncryptedJson(url, json, aad?)` + `request().encryptedBodyJson(json, aad?, config?)` |
| 表单 | `postForm(url, ArrayList<(String,String)>)` |
| Multipart | `postMultipart(url, fields, files)`，`MultipartFile(name, filename, contentType, data)` |
| 重试/退避 | `useRetry(config)`，默认仅幂等方法自动重试；`request().retry(config)` / `request().disableRetry()` |
| X509 校验入口 | `useX509Verify(option)`；`request().x509Verify(option)` / `request().disableX509Verify()` |
| Hook 管线 | `onRequest`, `onResponse`, `onError`（`RestClient` 与 `RequestBuilder` 均可挂载） |
| 可观测 | 成功响应附加 `x-ignite-observe-duration-ms/retry-count/error-class/fields`；error hook 收到 `[ignite.client.observe] ...` 包装信息 |
| 请求构建 | `request().method().url().query(k,v).header()/addHeader().basicAuth().bearerToken().form()/multipart().send()` |
| BaseURL | `baseUrl("https://api.example.com")`，后续相对路径自动拼接 |
| 默认头 | `defaultHeader(name, value)` |
| Cookie | `useCookies()` 或 `useCookies(store)`；支持 `domain/path/max-age/secure/httpOnly/sameSite` 与多条 `set-cookie` |
| 响应 | `status`, `body()`/`bodyBytes()`/`bodyStream()`, `json()`, `header(name)`, `headerValues(name)`, `isOk()`/`isSuccess()`, `discard()`（大包路径已优化） |

### 进程内测试入口（handleForTest）

`App.handleForTest(...)` 用于不手动 `listen` 的服务回归断言：

```cangjie
let app = App(config: Config())
app.use({ ctx =>
    ctx.next()
    _ = ctx.setHeader("x-mw", "hit")
})
app.get("/ping", { ctx => _ = ctx.sendString("pong") })

let resp = app.handleForTest("GET", "/ping")
@Assert(resp.status, 200)
@Assert(resp.body, "pong")
@Assert(resp.header("x-mw") ?? "", "hit")
```

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
│   │   ├── health_check.cj, idempotency.cj, audit.cj, kmode.cj, utils.cj
│   ├── governance/
│   │   ├── audit.cj        # 审计事件模型与输出
│   │   ├── kmode_policy.cj # kMode 策略（Header Key + IP + capability）
│   │   ├── log_level.cj    # 0~9 日志等级与过滤策略
│   │   └── redaction.cj    # 敏感信息脱敏
│   └── client/
│       ├── client.cj           # 公共类型/工具 (CookieStore/RetryConfig 等)
│       ├── rest_client.cj      # RestClient 入口
│       ├── request_builder.cj  # 请求构建、Hook/Retry/观测链路
│       └── client_response.cj  # 响应封装与大包读取
└── cjpm.toml              # 包管理配置
```

## 支持平台

| 平台 | 架构 | 状态 |
|:---|:---|:---:|
| macOS | aarch64 (Apple Silicon) | ✅ |
| macOS | x86_64 (Intel) | ✅ |
| Linux | x86_64 | ✅ |
| Linux | aarch64 | ✅ |
| Windows | x86_64 | ✅ |

## 叶燧星火
> Trusted by teams that move at the speed of light.

<a href="https://gitcode.com/copur/lanlu">兰鹿</a> - 基于仓颉语言的漫画归档管理系统

### Ignite-Samples

- `samples/hello` - 最简 Server 样例（`GET /` + `GET /health`）
- `samples/api` - Todo CRUD 样例（路径参数 + 查询参数 + `ctx.jsonEncode`）
- `samples/client` - 内置 Client 联调样例（`demo_server.cj` + `demo_client.cj`，含加密 JSON 与 multipart）
- `samples/ignitekit` - `IgniteKit` 动态 HTML/CSS 编排样例（`kit.html` / `kit.css` / `kit.dynamicHtml`）

### 这次版本最值得先试什么

- **5 分钟跑通 hello**：先用 `samples/hello` 验证最小服务是否可起
- **试一个真实 API**：再切到 `samples/api` 看路由、参数、JSON 与中间件组合
- **验证联调体验**：最后用 `samples/client` 看 Server / Client 一体化能力

如果你是第一次接触 Ignite，推荐按 `hello -> api -> client` 的顺序试，不必一上来就读完整路线图。

<a href="https://atomgit.com/cinyu/ignite-benchmark">Ignite-Benchmark</a> - 标准最佳实践

<a href="https://gitcode.com/cinyu/easyTODO-core">easyTODO-core</a> - 纯仓颉+HTML实现的TODO后端

<a href="https://atomgit.com/cinyu/igMessanging">igMessanging</a> - 纯仓颉+HTML实现的聊天室后端

## 文档与入口

当前可优先参考：

- `docs/README.md`：公开文档首页，适合快速找到 Quickstart、样例入口与后续阅读顺序
- `docs/CHANGELOG.md`：用户向版本时间线，只保留使用者能直接感受到的能力变化
- `README` 中的 API / Middleware / Advanced Usage 章节
- `samples/client/README.md` 的 Client 组合示例
- `samples/` 目录中的最小样例与联调脚本

## 参与后续演进

- 本次主叙事仍然是“先用起来”，贡献入口放在次级位置
- 若你想关注后续实验协作与 Server 接线验证，可看 `docs/ignite-0800-engineering-flow-summary.md`
- 若你想直接参与代码或样例完善，建议从 `samples/`、文档修正与低风险回归开始

## 许可证

基于 [Apache License 2.0](LICENSE) 开源。

---

<p align="center">
  <sub>使用仓颉，点燃无限可能。</sub><br>
  <strong>Built with Cangjie. Ignited by passion.</strong>
</p>
