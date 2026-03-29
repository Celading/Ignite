# Ignite 更新日志

本文件记录所有重要的功能与行为变更。版本号遵循项目 `cjpm.toml` / 发布标签。

---

## [0.5.21]（2026-03-24）

> `0.5.21` 是 `0.5.x` 持续迭代列车中的正式里程碑，代表 `0500` 收口期当前可发布基线，不等于 `0500` 已全部结束，也不是突然跳版。

### Server

- **正式发布号收口**：`cjpm.toml` 版本提升为 `0.5.21`，README（中/英/俄）版本徽章与头图版本同步为 `0.5.21`。
- **压缩中间件补齐（P0-1）**：新增 `compressMiddleware` / `CompressConfig`（`gzip/deflate`、`Accept-Encoding` 协商、最小体积阈值、可选 `skipIfNoGain`、`Vary: Accept-Encoding`）。
- **回归测试补齐**：新增 `CompressMiddlewareTestSuite`，覆盖 `gzip`、`deflate` 回退、小响应跳过、与 `cache + etag` 组合无回归。
- **jinkuiSSL 并行轨道并入（P1）**：新增 `Config.enableTlsPrecheck`（默认 `true`），可回退到“仅 stdx TLS 构造”路径；`App.listen` TLS 失败日志新增结构化字段：`tls_stage`、`tls_error_code`、`ignite_error_code`、`hint`。
- **TLS 接线测试补齐**：新增 `TlsPrecheckIntegrationTestSuite`，覆盖非法 PEM 错误映射、cert/key 不匹配映射、关闭 precheck 的回退行为、合法输入 precheck 成功路径。
- **发布门禁联动**：`_helper/scripts/server_release_guard.sh` 新增 `CompressMiddlewareTestSuite` 必检项；`release_guard.sh` 全链路通过（server + client + cjlint）。
- **cjlint 门禁可信化**：新增 `_helper/scripts/cjlint_error_guard.sh` 与 `_helper/docs/cjlint-error-baseline-0.5.21.txt`；`release_guard.sh` 改为基于“新增 error 失败”的可追踪门禁，不再出现“有 error 仍绿灯”的假阳性。
- **cjlint 零基线收口修复**：修复 `_helper/scripts/cjlint_error_guard.sh` 在 baseline 已清零时因空文件 `grep` 退出码被 `pipefail` 误判失败的问题，`0` error 基线现可稳定通过 `release_guard.sh`。
- **Server API Freeze 对齐**：`_helper/docs/server-api-freeze-0.5.10.txt` 已刷新并通过 `server_api_freeze_guard.sh` 校验。
- **文档同步（P0-2）**：README（中/英/俄）中间件表与示例已加入 `compressMiddleware`；补充 `ignite-framework-evaluation.md` 当前能力对照文档。
- **绑定/校验最小闭环（P1-1）**：新增 `Ctx.bindJsonOr400<T>(decoder, validate?)`，统一 `invalid_json/invalid_payload/validation_failed` 的 `400` 错误语义。
- **测试助手入口（P1-2）**：新增 `App.handleForTest(...)` 与 `AppTestResponse`，支持不手动 `listen` 的服务链路断言。
- **Logger 结构化输出（P1-3）**：`LoggerConfig.jsonLine` 新增 JSON 行日志模式，输出 `timestamp/level/requestId/method/path/status/latencyMs/kmode` 等字段。
- **路由命名与 URL 生成（P2-2）**：新增 `App.nameRoute(...)`、`App.urlFor(...)` 与 `Router.findRouteByName/setRouteName`；`RouteOption.operationId` 可直接作为路由名。
- **jinkuiSSL TLS 链接收口**：`ignite.api2` 显式锚定 `jinguissl.crypto.tls` 类型，修复 `jinguissl.contract` 新 ABI 下测试链接缺失 `-ljinguissl.crypto.tls` 的风险。
- **新增回归套件**：`RouteUrlForTestSuite` 覆盖 `operationId` 命名、显式命名、缺参/缺路由失败语义；并纳入 `server_release_guard.sh` 必检项。
- **JWT 一等中间件（P2-1）**：新增 `JwtConfig` 与 `jwtMiddleware`（当前 `HS256`），支持 Header/Query/Cookie 提取、`exp/nbf/iat/iss/aud` 校验、claims 注入（`jwt_claims/jwt_sub/jwt_token`）与 `WWW-Authenticate` 标准返回。
- **JWT 回归测试补齐**：新增 `JwtMiddlewareTestSuite` 并纳入 `server_release_guard.sh` 必检项。
- **示例目录扩展（P2-3）**：新增 `samples/hello` 与 `samples/api`，并提供 `samples/_shared/run_server_sample.sh` 统一运行脚本。
- **文件下载 404 兼容修复**：`Ctx.sendFile/download/sendFileRange` 新增“前导 `/` 相对路径兜底”（例如 `"/README.md"` 自动回退尝试 `"./README.md"`），降低旧项目路径迁移中的误 404。
- **文件下载流式化修复**：`Ctx.sendFile/sendFileRange` 改为基于 `HttpResponseWriter` 的分块发送，不再整文件缓冲到内存；保留 `Content-Length` / `Content-Range` / `Accept-Ranges`，并补齐 `HEAD` 语义，修复大文件/并发下载下的 OOM 风险。
- **RESTful + 下载回归套件**：新增 `FileDownloadAndRestfulTestSuite`，覆盖下载/Range 与 GET/POST/PATCH/DELETE 端到端流程。
- **下载回归增强**：`FileDownloadAndRestfulTestSuite` 新增跨 chunk 大文件下载、Range 与 `HEAD` 覆盖，锁定流式发送行为。
- **jinguissl 依赖命名收口**：修正 `cjpm.toml` 与相关 import 的包名对齐，避免 `jinkuissl` / `jinguissl` 命名不一致导致 `cjpm build/test` 被依赖解析直接阻断。
- **cjlint 门禁范围收束**：`cjlint_error_guard.sh` 过滤 `_helper/restored-releases/`、`_helper/IgniteDONOTCHANGE/`、`_helper/Ignite-0.4.67/` 等历史归档目录，避免发布门禁被非发布源码假阳性拦截。
- **IgniteKit 轻量编排能力**：新增 `IgniteKit`（`kit.html` / `kit.css` / `kit.dynamicHtml` / `kit.mount`），用于把动态生成 HTML/CSS 资源批量映射到 Ignite 路由，减少主业务路由文件臃肿。
- **IgniteKit 回归与样例**：新增 `IgniteKitTestSuite` 与 `samples/ignitekit`（含 `run.sh`），并纳入 `server_release_guard.sh` 门禁检查。
- **Server API Freeze 覆盖收口**：`server_api_freeze_guard.sh` 纳入 `src/ignitekit.cj`，并刷新 `_helper/docs/server-api-freeze-0.5.10.txt` 基线，避免公开 API 漏检。

### Client

- **门禁联动复验**：已按 0.5.21 Client 剥离清单执行并通过 `client_release_guard.sh` 与 `release_guard.sh`（含 server + client 串联）。
- **API Freeze 复验**：`client_api_freeze_guard.sh` 通过；本轮未触发 Client 对外公开签名变更，freeze 基线保持不变。
- **文档同步**：更新 `client-0.5.10-usage.md` 发布门禁示例，补充“完整发布链路包含 `release_guard.sh`”。

### Engineering

- **嵌套项目根识别修复**：新增 `_helper/scripts/common_paths.sh`，统一 `release_guard.sh`、`server_release_guard.sh`、`client_release_guard.sh`、freeze guard、`cjlint_error_guard.sh`、`server_benchmark.sh` 与 `gen_version.sh` 的项目根识别；当前 `IgniteNEXT/Ignite` 布局下可直接从工作区根执行。
- **TLS 测试数据路径收口**：`TlsPrecheckIntegrationTestSuite` 改为兼容工作区根 / `Ignite/` 子目录双布局，不再因 `_helper/testdata/tls` 定位漂移导致假失败。
- **0500 发布流程固定化**：新增 `ignite-0500-release-workflow.md`，明确命令顺序、执行目录、环境性失败判断与“门禁必须串行执行”的规则。
- **门禁重新复验**：已在 `2026-03-29` 重新验证 `server_release_guard.sh`、`client_release_guard.sh`、`release_guard.sh`、freeze guard 与 `cjlint_error_guard.sh` 全链通过。

---

## [0.5.1]（0510 内部迭代）

### 新增

- **Client Hook 管线（0.5.02 里程碑）**：新增 `ClientRequestHook` / `ClientResponseHook` / `ClientErrorHook`，并提供 `RestClient.onRequest/onResponse/onError` 与 `RequestBuilder.onRequest/onResponse/onError`。
- **Client Retry/Backoff（0.5.03 里程碑）**：新增 `ClientRetryConfig`、`RestClient.useRetry/disableRetry`、`RequestBuilder.retry/disableRetry`。
- **CookieJar v2（0.5.04 里程碑）**：Cookie 解析与匹配升级，支持 `domain/path/max-age/secure/httpOnly/sameSite`，并支持多条 `set-cookie`。
- **Client API 整理（0.5.05 里程碑）**：新增一组统一命名 API（`with*` / `body*` / `on*Hook`），并提供迁移清单。
- **Client API 冻结（0.5.06 里程碑）**：新增冻结基线文件 `_helper/docs/client-api-freeze-0.5.06.txt` 与校验脚本 `_helper/scripts/client_api_freeze_guard.sh`。
- **Client 可观测能力（0.5.07 里程碑）**：新增请求观测元数据（耗时、重试次数、错误分类、可插拔字段），并在响应头/错误 Hook 中统一暴露。
- **流式下载/大包处理（0.5.08 里程碑）**：优化 `ClientResponse` 大包读取路径，保留 `bodyStream()` 分块消费能力，减少逐字节拼装开销。
- **故障注入与并发基线（0.5.09 里程碑）**：新增 Client 侧故障注入基线用例（hook 注入 + 网络失败）与 `spawn` 并发压测基线（固定并发/请求规模）。
- **ServerEngine 抽象地基（0.5.06 里程碑）**：新增 `ServerEngine` / `StdxServerEngine` 与 `App.serverEngine(...)` 注入入口，默认行为保持 stdx 引擎不变。
- **Server 基准脚本与统一结果格式（0.5.07 里程碑）**：新增 `_helper/scripts/server_benchmark.py`、`_helper/scripts/server_benchmark.sh`、`ignite-benchmark-v1` JSON Schema（RPS/P95/P99/RSS）。
- **文档与示例齐套（0.5.10 里程碑）**：新增 `_helper/docs/client-0.5.10-usage.md`，补齐加密请求、重试、Cookie、Hook、观测与流式下载示例。
- **Client 本地联调样例补齐（0.5.10+）**：新增 `samples/client/demo_server.cj`、`samples/client/demo_client.cj` 与 `samples/client/run_demo.sh`，覆盖 GET/POST/加密 JSON/multipart 回环及观测头输出。
- **发布收口门禁（0.5.11 里程碑）**：新增 `_helper/scripts/client_release_guard.sh`，统一执行构建/测试/API 冻结校验，并补齐 Client 关键回归门禁检查。

### 变更

- **请求发送统一走 Builder 管线**：`get/post/postJson/postEncryptedJson/postForm/postMultipart/put/patch/delete/head/options` 全部收敛到 `RequestBuilder.send()`，确保 Hook、Cookie、加密请求走同一执行路径。
- **加密请求接入 Hook**：`postEncryptedJson(...)` 与 `request().encryptedBodyJson(...)` 均会触发 request/error hooks，便于统一审计、签名或埋点。
- **默认重试策略**：默认仅幂等方法（`GET/HEAD/OPTIONS/PUT/DELETE`）启用重试；`POST/PATCH` 等非幂等方法默认不重试，可按请求覆盖。
- **Client 模块拆分**：`client.cj` 按职责拆为 `client.cj`（公共工具/类型）、`rest_client.cj`、`request_builder.cj`、`client_response.cj`，降低单文件复杂度。
- **Cookie 写入/发送链路增强**：`CookieStore` 基于 URL 做域/路径/安全匹配；过期（`max-age`）自动清理；`ClientResponse.headerValues("set-cookie")` 改为读取全部同名 header 值。
- **命名规范统一**：保留原 API 兼容层，同时引入推荐命名：`withBaseUrl/withHeader/withCookieJar/withCrypto/withRetryPolicy`、`bodyJson/bodyEncryptedJson/bodyFormUrlEncoded/bodyMultipartForm`、`onRequestHook/onResponseHook/onErrorHook`。
- **发布门禁增强**：`_helper/scripts/release_guard.sh` 新增 Client API Freeze 校验，`0.5.06` 起公开签名变更需先更新冻结基线并审查兼容性。
- **观测链路接入**：`RequestBuilder.send()` 在成功响应时注入 `x-ignite-observe-*` 头（`duration-ms/retry-count/error-class/fields`）；失败时向 error hook 传递观测包装异常（保留原异常继续抛出）。
- **大包读取性能优化**：`ClientResponse.bodyBytes()` 改为分块聚合复制，`discard()` 提升为大缓冲区快速排空，降低大响应体处理时的循环开销。
- **Client 压测基线固定化**：新增并发故障场景基线，持续验证“多 worker + 高频失败请求”下的稳定性与耗时上限。
- **Release Gate 收敛**：`release_guard.sh` 接入 `client_release_guard.sh`，保证 Client 回归流程（功能 + 兼容 + 性能基线）统一执行。
- **Release Gate cjlint 运行时兜底**：`release_guard.sh` 自动探测并注入 `cjlint` 动态库目录（`tools/lib`），修复本地 `libcjlint.dylib` 解析失败导致的门禁中断。

### 测试

- 新增 `ClientHookTestSuite`，覆盖 Hook 顺序与加密请求场景。
- 新增 `ClientRetryTestSuite`，覆盖幂等方法重试、非幂等默认不重试、单请求重试覆盖。
- 新增 `ClientCookieJarV2TestSuite`，覆盖 hostOnly/domain/path/secure/max-age/多 set-cookie 行为。
- 新增 `ClientApiRenameTestSuite`，覆盖新命名 API 链路与兼容行为。
- 新增 `ClientAliasMatrixTestSuite`，覆盖别名 API 组合路径（`with*` / `postJsonEncrypted` / builder alias）回归。
- 新增 `ClientObserveTestSuite`，覆盖观测错误消息中的 `errorClass/retryCount/durationMs/fields`。
- 新增 `ClientStreamingTestSuite`，覆盖大响应体 `bodyBytes/bodyStream/discard` 行为。
- 新增 `ClientMultipartTestSuite`，覆盖 `postMultipart` 与 `bodyMultipartForm` 的本地回环解析（字段/文件计数与元信息）。
- 新增 `ClientFaultBaselineTestSuite`，覆盖故障注入矩阵与并发失败基线。
- 新增 `ClientLegacyCompatTestSuite`，覆盖冻结期对旧命名 Client API 的兼容回归。
- 发布门禁新增 `client_release_guard.sh`：统一执行构建/测试/冻结校验，并校验关键 Client suite 源文件存在；性能阈值由 `ClientStreamingTestSuite` 与 `ClientFaultBaselineTestSuite` 的断言固化。
- 新增 API 冻结产物：`client-api-freeze-0.5.06.txt`（当前 Client 公开面快照）。
- 修复 `LegacyCookieWarningTestSuite`、`HttpSemanticsMiddlewareCompatTestSuite`、`MiddlewareChainRegressionTestSuite` 偶发不稳定：统一避免在读取响应体前提前关闭 `RestClient`，消除 `Socket is closed` 间歇报错。

---

## [0.5.1-initial]

### 新增

- **Client Crypto 抽象层（ignite.api2）**：新增 `ClientCryptoProvider`、`ClientCryptoConfig`、`EnvelopeV1` 与统一错误码（`BAD_ENVELOPE` / `KEY_NOT_FOUND` / `DECRYPT_FAILED` / `CRYPTO_UNAVAILABLE`）。
- **jinkuiSSL Provider 位 + 兼容 Fallback Provider**：保留 jinkuiSSL Provider 扩展位；当前默认可用实现为兼容 fallback，后续可通过 provider 注入切换。
- **Client 加密发送 API**：`RestClient.useCrypto(...)`、`RestClient.postEncryptedJson(...)`、`RequestBuilder.encryptedBodyJson(...)`。
- **Server Security Facade（ignite.security）**：新增 `SecurityConfig`、`SecurityProviderKind`、`SecurityException` 与统一 `randomHex/encryptEnvelopeV1/decryptEnvelopeV1` 能力。

### 变更

- **multipart boundary 随机源升级**：优先改用 CSPRNG（不可用时自动回退）。
- **Cookie 加密升级（双读新写）**：`encryptCookieMiddleware` 升级到 AEAD v1；读取优先新格式，失败可回退 legacy XOR；写入默认新格式。
- **HTTP 语义增强**：路径命中但方法不匹配返回 `405` 并附 `Allow`；`OPTIONS` 对已注册路径返回 `204` + `Allow`。
- **HTTP 语义与中间件链兼容（0.5.08）**：`405/OPTIONS/404` 语义响应改为走全局中间件链尾处理，确保 logger/audit/recover 等全局链路可观测。
- **Ctx Cookie API 增强**：`setCookie(...)` 新增 `sameSite` 参数；中间件注入模式下支持自动加密写入。
- **Legacy Cookie 告警开关（0.5.09）**：`EncryptCookieConfig` 新增 `legacyDecryptWarn` 与 `legacyDecryptWarnHook`，默认继续“双读新写”，可按需开启迁移告警。
- 包版本升级为 **0.5.1**，并新增子包配置 `ignite.security`。

---

## [0.4.61]

### 新增

- **治理子系统（ignite.governance）**：新增 `log_level.cj`、`audit.cj`、`kmode_policy.cj`、`redaction.cj`，提供 0~9 日志等级策略、统一审计事件模型、kMode 策略对象与敏感信息脱敏能力。
- **auditMiddleware**：新增审计中间件，统一输出结构化事件字段：`eventId/requestId/timestamp/actor/ip/route/action/result/riskLevel/kmode/session`，并支持 Linux 风格终端打印。
- **kMode 策略模式**：在保留 `kmodeMiddleware(Bool)` 的同时，新增 `kmodeMiddleware(policy: KModePolicy)`，支持 Header Key + IP 白名单 + capability 组合治理。

### 变更

- **Logger 十级语义与双模式过滤**：补齐 0~9 等级（0 Emerg … 9 Verbose），普通模式默认输出 0~6，kMode 下输出 0~9；调用方式保持 `loggerMiddleware(config: LoggerConfig(...))` 不变。
- **Logger 自检**：新增运行时统计（total/writeFail/dropped/maxLatencyMs）和周期健康输出。
- **Ctx 响应状态可观测**：新增 `Ctx.responseStatus`，并在 `status/sendStatus/redirect/noContent/sendFile/sendFileRange` 等路径同步状态码，便于日志与审计统一关联。

### 工程与发布

- 包版本升级为 **0.4.61**。
- 新增子包配置：`ignite.governance`（`cjpm.toml`）。
- README 同步治理能力说明（中间件表、kMode 策略示例、项目结构）。
- 新增发布门禁脚本骨架：`_helper/scripts/release_guard.sh`。
- 新增治理文档基线：`_helper/docs/governance-baseline.md`。

---

## [0.4.51]

### 新增

- **api2.GetData（宏读 cjpm.toml）**：通过宏包 `ignite.api2.GetData.cjpmInfo` 在编译时读取 `cjpm.toml` 的 [package] 元数据；`GetDataClass.ModuleVer()` / `ModuleOrg()` / `ModuleName()` / `ModuleDesc()` 供 Banner 等使用。App 启动 Banner 版本改为 `GetDataClass.ModuleVer()`，与 cjpm.toml 单一来源一致。
- **api2.getNetworkInfo() IP 显示顺序**：多网卡时对返回的 `ips` 按「适合展示」排序：私有地址（10/172.16–31/192.168）优先，其次其他/公网，再次链路本地（169.254），最后回环。Banner 取 `ips[0]` 即为推荐展示地址，避免 169.254 排在前面。

### 移除

- **version.cj 与 scripts/gen_version.sh**：框架版本改由 GetData 宏从 cjpm.toml 读取，不再使用生成脚本与 version.cj。

### 修复

- **api2.getNetworkInfo()（Windows）**：`ipconfig /all` 输出多为系统代码页（如 GBK），直接 `String.fromUtf8` 会抛错。现用 `tryDecodeUtf8OrLossy` 先尝试 UTF-8，失败则仅保留 ASCII（IPv4 为 ASCII）再解码；整体 try/catch 返回空结果时 Banner 显示 0.0.0.0，避免启动崩溃。

---

## [0.4.41]

### 新增

- **Config.kmode**：调试模式开关。为 `true` 时启动后启用类似 debug 行为：Banner 必打当前 Ignite 版本；可配合 `kmodeMiddleware` 使用。
- **kmodeMiddleware(kmode: Bool)**：kmode 中间件。当 `kmode` 为 true 时在请求上下文中设置 `ctx.setLocal("kmode", "true")`，便于后续 Handler 识别调试模式。
- **Logger 接口 + DefaultLogger**：`ignite.middleware.Logger` 接口（`log(message: String)`），默认实现 `DefaultLogger`（可覆写 `output` 或子类覆写 `log`）；用户可注入自定义 Logger 实现。
- **LoggerConfig.enableEntityLog**：为 true 时以实体形式记录日志（`method=GET path=/ latencyMs=...`），否则为单行 `[method] path latencyMs`。保留兼容：`LoggerConfig(output: fn)` 仍可用。
- **ignite.getFrameworkVersion()**：返回当前框架版本（与 cjpm.toml 一致），用于 Banner 与 debug 输出。

### 变更

- **控制台输出**：Banner 后当 `enableSwagger` 时打印 `Swagger UI: ${scheme}://${displayAddr}:${port}${swaggerPath}`，以实际绑定地址（如 0.0.0.0 时取首 IP）为主，不再使用 localhost。kmode 时必打 `Ignite v${version} (kmode)`。
- **printBanner**：增加参数 `enableSwagger`、`swaggerPath`、`kmode`；版本统一由 `getFrameworkVersion()` 提供。

---

## [0.4.27]

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
