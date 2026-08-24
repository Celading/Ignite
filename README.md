<p align="center">
  <img src="https://img.shields.io/badge/Cangjie-Ignite-ff6b35?style=for-the-badge&labelColor=1a1a2e" alt="Ignite" />
  <img src="https://img.shields.io/badge/version-0.8.7-orange?style=for-the-badge&labelColor=1a1a2e" alt="Version" />
  <img src="https://img.shields.io/badge/license-Apache%202.0-green?style=for-the-badge&labelColor=1a1a2e" alt="License" />
</p>
<div align="center">
<pre style="background:#00000000">
┌───────────────────────────────────────────────────────┐
│                   <span style="color:#88C0D0;">Ignite v0.8.7</span>                      │
│   <span style="color:#6EB186;">http://127.0.0.1:8080</span><span style="color:#9AA0A6;"> || (bound on 0.0.0.0:8080)</span>    │
│                                                       │
│   Touchpoints .......... 16   Processes .......... 1  │
│   Prefork ......... Disabled   PID .......... 67271   │
│                                       <span style="color:#8A8A8A;"><i>_Ignite 0.8.7</i></span>  │
└───────────────────────────────────────────────────────┘
</pre>
<span style="font-weight:300;font-size:38px">Ignite / 叶燧</span><br/>
<span style="font-weight:100;font-size:26px">以仓颉语言打造、面向真实服务落地的 Web 框架</span>
<p align="center">
  <strong>仓颉胃，Express味</strong><br>
  <sub>富中间件 · 快速起服务 · 生产治理默认在场 · Server/Client 一体化演进</sub>
</p>
</div>
<p align="center">
  <a href="https://gitcode.com/cinyu/ignite-cangjie">GitCode 主仓</a> ·
  <a href="https://github.com/Celading/Ignite">GitHub 镜像</a> ·
  <a href="https://pkg.cangjie-lang.cn/package/ignite">中心仓</a>
</p>

## 为什么选择 Ignite?

> 点燃仓颉 Web 开发的第一把火。

仓颉（Cangjie）正在进入需要“真正能承载业务”的阶段，而 **Ignite** 的目标不是只做一个 Demo 框架，而是提供一条从首个接口、到安全治理、再到长期维护都更统一的 Web 服务路径。

与直接使用官方 `stdx.httpServer` 相比，Ignite 更强调 **减少样板代码、统一中间件组织、沉淀默认实践、降低服务重复搭建成本**。  
与 [Fiber](https://gofiber.io/) 这类强调轻量体验的主流框架相比，Ignite 尽可能的在仓颉生态里，给你近似的体验：能不能快速上手，同时把审计、安全、Swagger、静态托管、Client 能力一起收进统一框架。

我们相信，好的框架应该像一片叶子轻盈穿梭，又能像燧石碰撞瞬间点燃。  
因此我们取 **“叶”** 之灵动，取 **“燧”** 之开创，命名它为 **叶燧 (Ignite)**。

## 当前状态（0.8.7 Preview）

- 明文 HTTP/1.1 默认进入 Ignite native H1，保留 `stdx-default` 显式回滚入口。
- 原生 H1 Client、WebSocket、SSE、流式响应与请求体上限已经进入真实 socket 回归面；普通 `app.ws(...)` 在 Native H1 backend 下就是 Ignite 自研 WebSocket，不需要第二个开关。
- 原生 H2 Server/Client 已具备受限多路复用、完整 HPACK Huffman、有界动态表、流控恢复、cleartext/TLS 并发 stream lease 与 buffered/精确长度/未知长度 request stream；Server 仍需显式安装 cleartext prior-knowledge engine，不是浏览器 HTTPS 默认路径，也不包含 H2 WebSocket。
- HTTPS 默认继续使用稳定的 stdx TLS 路径；JinguiSSL native TLS/ALPN 仍需显式实验开关。
- Native TLS client pool 提供有界 idle 生命周期与 H1/H2 快照；native H1 提供 backend 选择、连接/请求计数和降级原因，并收敛预期 timeout/reset 噪声。
- SeaJson 已提供 `JsonWriterEncodable -> OutputStream` 流式写出路径，Native H2 `jsonWrite` 也进入有界 DATA 流；传统 `ctx.json(String)` 仍是完整字符串响应。
- 动态 gzip/deflate 已切换为 Ignite 自有安全仓颉 codec；Zstd 与 Brotli 提供默认关闭的 RAW/RLE Preview，静态 `.zst/.br` 副本继续保留。

完整的 0800 能力边界、回滚方式与未完成项见 [`ig0800-preview.md`](https://gitcode.com/cinyu/ignite-cangjie/blob/ig0800/manual/docs-md/ig0800-preview.md)。Native H2 的可运行 Server/Client 入口与 H1/H2 差异见 [`h2-quickstart-0800.md`](https://gitcode.com/cinyu/ignite-cangjie/blob/ig0800/manual/docs-md/h2-quickstart-0800.md)。

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

### Ignite 的强力点

- `App / Router / Ctx` 足够直，起服务快，不用先学一堆仪式。
- `logger / audit / recover / requestId / security / swagger` 默认就在主线上，不是让你每个项目再拼一遍。
- `bindJsonOr400`、`handleForTest`、`urlFor`、`InterfaceSpec` 这些高频能力已经成形。
- `RestClient` 跟 Server 一起演进，联调时不必再额外造一层陌生封装。
- OpenHarmony、HarmonyOS、EulerOS、通用 Linux 的平台口径已经分列，后续还有 LoongArch 预留。

## 快速开始

先别读长篇，先把 `hello` 跑起来。

### 环境要求

- 仓颉sdk环境 [`cangjie-sdk`](https://cangjie-lang.cn/download) v1.1.0+
- 仓颉标准扩展库 [`cangjie-stdx`](https://gitcode.com/Cangjie/cangjie_stdx/releases/v1.1.0-beta.24.1)
  >如需[`仓颉 nightly[含stdx链接]`](https://gitcode.com/Cangjie/nightly_build)
- 支持平台：详见下方《支持平台》矩阵（已区分 OpenHarmony、HarmonyOS、EulerOS 与通用 Linux）
- 依赖接入：稳定版可走中心仓，0800 Preview 必须选择 GitCode 或 GitHub 的 `ig0800` 分支；完整说明见 [`manual/docs-md/Guide.md`](manual/docs-md/Guide.md)。

稳定版中心仓：

```toml
[dependencies]
ignite = "0.7.7"
```

0800 Preview 请选择一个托管源，不要同时声明多个来源：

```toml
# GitCode
[dependencies]
ignite = { git = "https://gitcode.com/cinyu/ignite-cangjie.git", branch = "ig0800" }
```

```toml
# GitHub
[dependencies]
ignite = { git = "https://github.com/Celading/Ignite.git", branch = "ig0800" }
```

包键必须写成小写 `ignite`。普通使用者只需声明 Ignite；`jinguissl`、`seajson` 和 `lisi` 由 Ignite 传递解析，不要在业务项目里重复锁定，除非你正在维护 provider 或明确需要源码级版本冻结。

```cangjie
import ignite.*

main() {
    let app = App()

    app.get("/", { ctx =>
        ctx.json(#"{"message":"Hello, Ignite!"}"#)
    })

    app.listen("0.0.0.0", 3000)
}
```

如果你要继续往下走，推荐顺序是 `hello -> api -> swagger -> client`。  
更完整的首跑顺序、样例选择、中心仓配置和常见失败修复，请看 [`Guide.md`](https://gitcode.com/cinyu/ignite-cangjie/blob/ig0800/manual/docs-md/Guide.md) 与 [`samples/README.md`](https://gitcode.com/cinyu/ignite-cangjie/blob/ig0800/manual/samples/README.md)。

### Native H2 Preview 快速启动

普通 `app.listen(...)` 默认是 Native H1。要运行 Native H2 明文
prior-knowledge server，需要显式安装 engine：

```cangjie
import ignite.*
import ignite.native_h2.useExperimentalNativeH2ServerEngine

main() {
    let app = App()
    useExperimentalNativeH2ServerEngine(app)
    app.get("/", { ctx => _ = ctx.sendString("hello from native h2") })
    app.listen("127.0.0.1", 3000)
}
```

验证：`curl --http2-prior-knowledge http://127.0.0.1:3000/`。该入口不接受
TLS 配置，也不提供 H2 WebSocket；完整说明见
[`h2-quickstart-0800.md`](https://gitcode.com/cinyu/ignite-cangjie/blob/ig0800/manual/docs-md/h2-quickstart-0800.md)。

## 特性亮点

- 起手轻：`App / Router / Group / Ctx` 心智干净，适合快速起 REST API、后台服务和内部平台。
- 治理不缺席：安全、审计、日志、请求 ID、限流、压缩、缓存、会话、重写、代理、健康检查都在主线能力面里。
- 接口可解释：Swagger / OpenAPI、`InterfaceSpec`、`TestOption`、`x-ignite-test` 和 `kmode` 让接口不仅能跑，还能讲清楚。
- 错误收得住：`bindJsonOr400` 统一常见请求绑定错误语义，首跑排障少走弯路。
- 路由更像“框架”而不是“脚手架”：命名路由、`RouteOption.operationId`、`urlFor`、组级中间件、route-level handler array、可替换 `404/405` hook 都已经接上。
- 联调不分家：内置 `RestClient`、Builder 模式、Retry / Hook / Observe、Cookie v2、multipart、加密请求与 X509 校验入口，响应侧可直接拿 `observeSnapshot()` / `transportTouchpoint()`，client 侧也保留 `lastClientObserveSnapshot()` / `lastClientTransportTouchpoint()` 并支持 `clearRecoverySnapshots()` 显式切段。
- 大请求体有直落盘路径：`requestBody()` / `saveBodyToFile(...)` 可以避免先把整包 body 全塞进内存。
- 请求体上限可搜得到：`Config.bodyLimit` 是 Ignite 的 canonical 配置名；面向熟悉 `stdx` / 其他框架的用户，`maxRequestBodySize` 作为同义入口，含义就是 `bodyLimit == maxRequestBodySize`。
- 静态和动态都能接：`static`、`staticSpa`、`IgniteKit` 都在公开能力面上。
- 边界说人话：当前 HTTPS 默认路径、压缩支持范围、样例入口都写在公开文档里，不让你靠猜。

## API 基础速览

Ignite 的核心对象不多，但都很像“拿来就能干活”的那种狠角色：

- `App`：负责把服务真正支起来，路由、生命周期、错误处理、Swagger 都从这里起手。
- `Router / Group`：负责把接口按模块排整齐，不用每个项目自己重新发明组织方式。
- `Ctx`：负责拿请求、回响应、读参数、写 Cookie、做流式输出，也是 request locals 的承载面；其中 `writer()` 是增量写接口，H2 路径不依赖 `Transfer-Encoding`；低层 `transportWriter()` 还可通过 fresh transform-factory middleware 按响应洋葱顺序自动组合。
- `Config`：负责把服务名、版本、请求体上限、超时、Swagger、TLS、Banner、kMode 这些运行期口径收在一起；`bodyLimit` 是 canonical 名，`maxRequestBodySize` 是同义搜索/构造入口。
- `RouteOption`：负责把接口的 `summary`、`tag`、`operationId`、请求体、响应和测试元数据挂上去。
- `RestClient`：负责让调用端别再另造一套陌生心智，联调时直接沿用 Ignite 的语义。
- `handleForTest`：负责在不手动 `listen` 的情况下，把请求直接打进 `App` 做回归断言。

具体方法级说明见 [`api.md`](https://gitcode.com/cinyu/ignite-cangjie/blob/ig0800/manual/docs-md/api.md)。

## 中间件
### 集成提供大量中间件
具体方法级说明见 [`middleware.md`](https://gitcode.com/cinyu/ignite-cangjie/blob/ig0800/manual/docs-md/middleware.md)。

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

## 项目结构

```text
ignite/
├── src/                 # Ignite 主体源码
├── manual/docs-md/      # 中文正文文档源稿
├── manual/docs-web/     # 后续网站化呈现层
├── manual/samples/      # 可运行样例与首跑路径
├── CHANGELOG.MD         # 中文版本时间线
└── CHANGELOG-en.MD      # 英文版本时间线
```

## 支持平台

| 系统 / 平台 | 架构 / 机型线 | 状态 | 说明 |
|:---|:---|:---:|:---|
| macOS | aarch64 (Apple Silicon) | ✅ | 默认开发主线之一 |
| macOS | x86_64 (Intel) | ✅ | 已覆盖 |
| Linux | x86_64/aarch64 | ✅ | 通用 GNU/Linux |
| EulerOS | Taishan/x86_64 | ✅ | 与通用 Linux |
| Windows | x86_64 | ✅ | 默认 Windows 兼容线 |
| OpenHarmony | aarch64/x86_64 | ✅ | OHOS 公开适配线 |
| HarmonyOS | arm64 | ✅ | 终端 / 设备侧部署线 |
| LoongArch | LoongArch64 | 规划中 | 后续平台扩展预留 |

## Ignite生态

### 叶燧星火

> Trusted by teams that move at the speed of light.

- [`兰鹿`](https://gitcode.com/copur/lanlu) - 基于仓颉语言的漫画归档管理系统
- [`SoonLink/溯联`](https://gitcode.com/cinyu/SoonLink) - 基于仓颉语言的跨端文件管理系统
- [`Ignite-Benchmark`](https://atomgit.com/cinyu/ignite-benchmark) - 面向 `0400/0500` 标准实践的基准仓
- [`easyTODO-core`](https://gitcode.com/cinyu/easyTODO-core) - 纯仓颉 + HTML 的 TODO 后端
- [`igMessanging`](https://atomgit.com/cinyu/igMessanging) - 纯仓颉 + HTML 的聊天室后端

### 叶燧薪柴

> Fueling the engines of innovation.

- [`brotli_middleware`](https://gitcode.com/copur/brotli_middleware) - 面向 Ignite 生态的 Brotli 中间件扩展

更多 `IgniteKit-*` 扩展与 `Cangku / Cangjie-Cangku` 同级基础设施方向仍在内部整理中，当前公开口径仍以已落地能力为准。

## 文档与入口

- [`manual/docs-md/README.md`](https://gitcode.com/cinyu/ignite-cangjie/blob/ig0800/manual/docs-md/README.md)：中文正文主入口，适合从首页继续往深处看。
- [`manual/benchmark/README.md`](https://gitcode.com/cinyu/ignite-cangjie/blob/ig0800/manual/benchmark/README.md)：0800 仓内可执行 Benchmark 基线；当前用于重复测量，不代表公开竞品排名。
- [`manual/samples/README.md`](https://gitcode.com/cinyu/ignite-cangjie/blob/ig0800/manual/samples/README.md)：最快把 Ignite 跑起来的样例矩阵和顺序。
- [`CHANGELOG.MD`](CHANGELOG.MD)：中文版本时间线与阶段收口记录。
- [`CHANGELOG-en.MD`](CHANGELOG-en.MD)：英文版本时间线。
- [`manual/docs-web/README.md`](https://gitcode.com/cinyu/ignite-cangjie/blob/ig0800/manual/docs-web/README.md)：后续网站文档的入口预留位。

## 参与后续演进

- 如果你是第一次接触 Ignite，建议先跑 `hello -> api -> swagger -> client` 这条样例路径，再判断它是不是你要的框架。
- 如果你已经在业务里用上了，欢迎把 issue、建议、踩坑和改进点带回来，Ignite 很需要真实反馈来继续长大。
- 如果你准备参与贡献，文档修正、样例回归、公开能力补充和低风险问题收口，都是非常好的入口。

## 推荐用 HapCLI 管理 stdx 环境

Ignite 0800 仍有明确的 stdx 运行时与平台链接依赖。安装 HapCLI 后，建议让它先诊断 SDK/stdx 布局，再通过同一 target 发起构建，避免手工拼接不同平台的静态库路径：

```bash
hap doctor stdx --project . --target aarch64-apple-darwin
hap build --project . --target aarch64-apple-darwin
```

Linux、Windows 与 OpenHarmony 可将 target 换为 `x86_64-unknown-linux-gnu`、`aarch64-unknown-linux-gnu`、`x86_64-w64-mingw32` 或 `aarch64-linux-ohos`。HapCLI 当前仍是 Preview 工具，入口见 [cli.hap.pub](https://cli.hap.pub)；它负责环境诊断与构建编排，不表示 Ignite 已经脱离 stdx。

## 许可证

Ignite 基于 [Apache License 2.0](LICENSE) 开源。

---

<p align="center">
  <sub>使用仓颉，点燃无限可能。</sub><br>
  <strong>Built with Cangjie. Ignited by passion.</strong>
</p>
