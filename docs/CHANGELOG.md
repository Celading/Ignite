# Ignite Changelog

> 用户向版本时间线。这里优先记录使用者能直接感受到的能力变化、修复与迁移感受，不展开内部脚本、门禁链路或维护流程细节。

---

## v0.5.21 · 2026-03-24

`0.5.21` 是 `0.5.x` 迭代列车中的正式里程碑，也是 `0500` 收口期当前可发布的公开基线。

### 开发体验

- `bindJsonOr400`：统一 JSON 绑定、校验失败与 `400` 返回语义。
- `handleForTest`：无需手动 `listen` 就能做服务链路断言。
- `urlFor`：支持命名路由与 URL 反向生成，更适合稍大一点的服务项目。
- `samples/hello`、`samples/api`、`samples/client`、`samples/ignitekit`：第一次试用路径更清晰。

### 服务与治理能力

- `compressMiddleware`：补齐常用响应压缩能力。
- `jwtMiddleware`：补齐常见鉴权入口，支持 Header / Query / Cookie 提取与 claims 注入。
- TLS 边界更清楚：默认 HTTPS 路径继续保持稳定，同时把 precheck 能力放在可理解的位置。
- 文件发送与下载能力继续增强，覆盖常见 `Range` / `HEAD` / 大文件路径。

### Client / Server 一体化演进

- `RestClient` 的常用能力继续补齐：重试、Cookie、multipart、观测头、加密 JSON 等联调路径更顺手。
- `IgniteKit` 让轻量 HTML / CSS 资源编排更适合样例、小页面与嵌入式服务入口。
- `ServerEngine` 的演进前置已经开始，但本次版本**不代表默认 Server 栈已经切换**。

### 修复与收口

- `jinguissl` 公开依赖形态已对齐，首次构建更接近真实安装路径。
- 启动 banner 与本地网络地址展示在探测失败时回退更稳，跨环境启动信息更可靠。
- 文档与样例入口重新收拢，公开资料不再依赖仓库内的 `_helper` 路径。

---

## v0.5.1 · 0510 内部迭代汇入后的公开基线

### 你会感受到的变化

- 内置 Client 从“能发请求”推进到“能做更完整的服务联调”。
- Hook、Retry、Cookie、multipart、观测头与流式读取开始形成一套更完整的 Client 使用面。
- `ignite.security` 与加密请求路径打通，为受保护接口和加密载荷提供了更自然的入口。

---

## v0.4.61

### 这代版本的重点

- 审计、kMode 策略与日志分级能力更完整。
- `auditMiddleware`、`kmodeMiddleware(policy)`、结构化日志与响应状态可观测能力更适合真实服务治理。

---

## v0.4.51

### 这代版本的重点

- 框架版本信息开始直接读取 `cjpm.toml`，减少版本来源分散。
- 多网卡场景下的地址展示顺序更合理，Banner 更适合直接拿来给本机调试使用。

---

## v0.4.41

### 这代版本的重点

- `kmode` 与更灵活的日志输出开始成形。
- Swagger 访问提示与版本展示更适合开发期排查。

---

## v0.4.07

### 这代版本的重点

- Swagger 缓存、JSON 编解码与文件下载 / Range 能力成为稳定入口。
- 这是 Ignite 从“基础路由可用”进一步走向“常见 Web 服务能力可用”的一个关键阶段。
