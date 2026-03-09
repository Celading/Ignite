# Ignite 更新日志

本文件记录所有重要的功能与行为变更。版本号遵循项目 `cjpm.toml` / 发布标签。

---

## [0.4.27]（当前）

### 变更

- **启动横幅**
  - `getProcessId()` 调用包在 try/catch 中，失败时显示 PID 为 `?`，避免启动崩溃。
  - 绑定 `0.0.0.0` 时，若 `getNetworkInfo().ips` 为空则显示 `0.0.0.0`，避免空数组访问。

---

## [0.4.07]

### 新增

- **Swagger 缓存**
  - `Config.enableSwaggerCache`（默认 `true`）：缓存 Swagger JSON 与 Swagger UI HTML，避免重复计算。
  - `App.invalidateSwaggerCache()`：在路由/选项变更时清除缓存。
  - 在 Swagger JSON 或 UI 路径上使用查询参数 `?refresh=1` 可强制刷新并重新填充缓存。

- **JSON**
  - 新模块 `ignite`（如 `src/json.cj`）：`JsonEncodable`、`JsonEncoder`、`serializeJson<T>`、`deserializeJson<T>`，用于 stdx 流式 JSON。
  - `Config.jsonEncoder: ?JsonEncoder`：为 `JsonEncodable` 类型提供可选的自定义编码器。
  - `Ctx.jsonSerialize<T>(obj)`，其中 `T <: StdxJsonSerializable`：序列化并以 JSON 响应。
  - `Ctx.jsonEncode(obj: JsonEncodable)`：使用 `Config.jsonEncoder` 或 `obj.toJsonString()`。

- **文件服务**
  - `Ctx.download(filePath, filename?)`：以附件形式发送文件，带 `Content-Disposition: attachment; filename="..."`。
  - `Ctx.sendFileRange(filePath)`：支持 HTTP `Range` 请求（206 Partial Content、416 Range Not Satisfiable、`Accept-Ranges: bytes`）。

### 变更

- `printBanner` 中的横幅版本字符串已更新为 `0.4.07`。

---

## [0.4.x]（来自已合并功能分支）

### 路由（feature/router-strict-routes-param-validation）

- **严格路由冲突**：重复的 `(method, path)` 将抛出异常，除非 `Config.allowRouteOverwrite = true`。
- **路由移除**：`Router.removeRoute(method, path)`、`App.removeRoute(method, path)`。
- **Trie**：通过 `TrieNode.staticChildMap` 的静态段查找（O(1)）；路径规范化（合并斜杠、空路径 → `/`）；在 add/match/remove 时跳过空段。
- **路径参数校验**：`RouteOption.paramValidations` 与 `withParamValidation(name, pattern)`；模式：`int`、`uint`、`num`、`alpha`、`alnum`、`uuid`；校验失败返回 404。

### 上下文（feature/ctx-query-form-fallback）

- **Ctx.query(key)**：先查 URL 查询参数，再以请求表单（POST body）为回退。
- **Ctx.queryFromUrl(key)** / **Ctx.queryFromForm(key)**：仅 URL 或仅表单的显式查找。

### TLS、Swagger UI、客户端（feature/tls-swagger-client-api2）

- **api2 TLS**：`ignite.api2.loadTlsServerConfigForHttp2(certPem, keyPem)`；App 将其用于 TLS 与 HTTP/2 ALPN。
- **Config**：`swaggerUICssUrl`、`swaggerUIJsUrl` 用于配置 Swagger UI 资源 URL。
- **App**：`LambdaHttpHandler` 用于 `(HttpContext) -> Unit`；分发器 `register` / `registerRoute` / `distribute` 的参数命名。
- **Client**：URL/表单编码，`buildQueryString`、`buildFormUrlEncoded`；`MultipartFile` 与 multipart body 构建器。
- **Middleware**：`basic_auth` 内部变量重命名为 `credentialPart`；session `defaultSessionStore` → `DEFAULT_SESSION_STORE`。

### api2 网络（feature/tls-swagger-client-api2）

- **ignite.api2.getNetworkInfo()**：跨平台（Windows/Linux/macOS）IP 列表、网关、DNS。
- **App 横幅**：当绑定在 `0.0.0.0` 时，通过 `getNetworkInfo().ips[0]` 显示首个局域网 IP，而非 `127.0.0.1`。

---

## [0.3.x] 及更早

- 中间件套件：安全、CORS、CSRF、Basic/Key 认证、日志、访问日志、请求 ID、恢复、限流、请求体限制、超时、缓存、ETag、会话、重定向、重写、静态文件、favicon、健康检查、幂等、代理。
- 核心：Trie 路由、Groups、WebSocket、SSE、Swagger（OpenAPI 3.0 + UI）、TLS/HTTP2、RestClient、onShutdown。
- 路由选项与 Swagger 集成。

---

*本文件维护于 `_helper/docs`，供内部与发布说明参考。*
