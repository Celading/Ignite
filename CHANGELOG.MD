# Ignite Changelog

## Ignite `0800`
> 原生 H1 默认化、原生 H2 预览、SeaJson 流式 JSON 与托管依赖收口

### v0.8.7 `Ignite Preview`

- `+特性` Native H2 补齐 RFC 7541 HPACK Huffman 256-octet 解码/按收益编码、EOS/padding 校验、敏感 Header never-index 与有界动态表
- `+特性` Native TLS H2 ingress 接入现有 runtime，并补齐 H2 response streaming、graceful drain 和有界 multiplex session
- `+特性` 显式 cleartext/TLS H2 session 支持独立并发 stream lease，以及 buffered、精确长度与 EOF 终止的 unknown-length one-pass request stream
- `+特性` H2 `ctx.jsonWrite(...)` 复用有界 producer 与 flow-controlled DATA 路径，不再在 handler 返回前聚合完整 JSON carrier
- `+特性` 消费 lisi transport contract，覆盖 stream/lifecycle/backpressure 适配边界；压缩路径收紧 identity refusal 与 private precompressed representation trust
- `+验证` 本版由已接受开发检查点 `036383d` 提升；发布分支在提交前重新运行 clean update、build、完整串行测试与公开泄漏审计
- `=边界` 系统 CA、自动重放、逐 stream deadline/priority、H2 WebSocket、完整 Brotli/Zstd entropy coding、最终调度/default flip、tag、Release、main merge 与 LTS 均未声明完成
- `=杂项` 包版本、框架常量、Banner、Benchmark、三语 README、0800 Manual 与双语 changelog 更新到 `0.8.7`

### v0.8.2 `Ignite Preview`

- `+特性` Native TLS H1/H2 Client pool 增加默认 30 秒 idle 上限、同策略连接复用、过期/关闭淘汰与实例级生命周期快照
- `+特性` 明文 Native H1 增加稳定 backend 策略、最终选择/降级原因、连接与请求计数，并在连接任务边界收敛预期 timeout/reset
- `+特性` Native H1、Jingui accepted transport 与 Native H2 统一 query component 单次 form 解码，避免应用层补偿性 double-decode
- `+特性` Native H1 WebSocket 增加入站完整消息上限、严格 RSV/opcode/masking/length/UTF-8/Close 校验、分片、子协议与并发 writer 串行化
- `+验证` WebSocket focused `14/14`、完整 serial `1537/1537`、当前仓库 h2spec profile `145 passed / 1 skipped / 0 failed`；本版发布前重新运行 canonical regression/build
- `=边界` WSS、H2 extended CONNECT、permessage-deflate、客户端 Dialer、系统 CA、TLS1.2/resumption、mTLS、浏览器/代理/长窗口矩阵与 AP9/lisi provider acceptance 仍未完成
- `=杂项` 包版本、框架常量、Banner、Benchmark、三语 README、0800 Manual 与双语 changelog 更新到 `0.8.2`

### v0.8.1 `Ignite Preview`

- `+安全` 默认 Native H1 现在会在等待请求体网络字节前完成 `Expect: 100-continue` 临时响应握手，并在 App dispatch 前用固定无正文 `417 Expectation Failed` 拒绝空、混合或不支持的 expectation
- `=边界` `ClientResponse` 核心存储新增 Ignite 自有扁平响应字段入口；Native H1 的响应解析/分帧和 Native H2 的五条 response adapter 不再构造 stdx `HttpHeaders`，observe 元数据也改走自有 append seam
- `=兼容` 公开 `ClientResponse(HttpResponse)` 与 `headers: HttpHeaders` 继续保留为 stdx 兼容面，并保持重复字段顺序、大小写无关读取及既有 raw-header mutation 可见性；proxy `HttpResponse`、request builder provider 与最终 stdx 删除仍是后续独立工作
- `=边界` `CurrentRequestCarrier` 核心契约不再强制所有后端返回 stdx `WebSocket`；公开 `WebSocketUpgradeCarrier` 以 Ignite `WsConn`、子协议与 `WebSocketOptions` 表达可选升级能力，stdx adapter、Native H1 与透明响应 writer wrapper 通过该能力接入
- `=边界` Native H1 WebSocket 真实 socket 回归保持通过；macOS Cangjie/stdx `1.1.3` 上新增的 stdx-default 真实升级探针在 provider `upgradeFromServer` 后可复现 `SIGABRT` 与 unsafe-libcrypto 警告，因此本次只确认 stdx adapter 编译兼容，不宣称其 live WebSocket 已认证，也不扩张到 WSS/H2WS 或 provider 修复
- `=边界` `CurrentRequestCarrier` 核心契约不再强制所有 native/test carrier 暴露 stdx `HttpContext`；原有 `Ctx.httpContext()` 兼容入口改由可选 `StdxHttpContextCompatibilityCarrier` 能力提供，stdx carrier 与透明响应 writer wrapper 保持可用
- `=边界` 未提供该可选能力的 native H1/H2/accepted-transport carrier 会在请求 raw context 时给出明确拒绝；本次不替换 WebSocket upgrade provider、请求体流、client response，也不移除最终 stdx 依赖
- `=边界` `CurrentRequestCarrier` 的请求头/拖尾读取改用 Ignite 自有的扁平字段序列与单值拖尾契约；代理转发不再从 carrier 获取 stdx `HttpHeaders`，重复请求字段值仍完整保留
- `=边界` 本次不替换 adapter 内部 provider 集合，也不处理 raw `HttpContext`、WebSocket、请求体、client response 或最终 stdx 依赖移除
- `=边界` `CurrentRequestCarrier` 的响应头追加改用 Ignite 自有的单字段契约；流压缩与代理下游不再为 carrier 边界构造或传递 stdx `HttpHeaders`，重复字段仍逐值保留
- `=边界` 本次只收口服务端响应头 mutation seam；请求头集合读取、raw `HttpContext`、WebSocket 与 client response provider 类型仍是后续 IG0900 分层任务
- `=依赖` JWT 中间件的签名后 header/claims DOM 解析改用 Ignite-owned SeaJson 值契约，不再直接导入 stdx JSON；HS256、String/数字时间声明和现有拒绝分类保持兼容
- `+安全` 默认 Native H1 现在会把已检测到的非法 chunk-size、chunk payload 分隔符和 trailer 字段名映射为固定无正文 `400 Bad Request`，随后关闭该连接并保持监听器继续服务
- `=边界` malformed chunked-body 400 不覆盖未完整 EOF、peer abort、超时、chunk/trailer 元数据超限、不支持的 pipelining、完整 chunk-extension 语法或自定义错误体
- `+安全` 默认 Native H1 现在会在 `readHeaderTimeout` 到期而请求头仍不完整，或 `readTimeout` 到期而请求体仍不完整时，返回固定无正文 `408 Request Timeout`，随后关闭该连接并保持监听器继续服务
- `=边界` 固定 408 只覆盖 request-head 与 request-body 各自明确的等待阶段；未完整 EOF、peer abort、malformed body、handler 异常和自定义错误体仍保持独立
- `+安全` 默认 Native H1 现在通过 typed request-head 分类返回固定无正文 `414 URI Too Long`、`431 Request Header Fields Too Large` 或 `505 HTTP Version Not Supported`，随后关闭该连接并保持监听器继续服务
- `=边界` 414 对应请求目标/请求行上限，431 对应请求头字节或字段数上限，505 对应不支持的 HTTP 版本；当前不提供自定义错误体，也不扩展到 body-stage 错误策略
- `+安全` 默认 Native H1 现在会对已完整接收、被请求头/session 或 request-target dispatch seed 明确拒绝的坏请求返回固定无正文 `400 Bad Request`，随后关闭该连接
- `=边界` 固定 400 不覆盖未完整 EOF、header timeout、peer abort、handler 异常或自定义错误页
- `+安全` 默认 Native H1 现在对 Host、absolute-form authority 与 CONNECT authority-form 复用同一结构门，拒绝 userinfo、坏百分号编码、坏括号、多冒号歧义与非十进制端口
- `=边界` 合法 reg-name、括号化 IP-literal 与十进制端口保持兼容；CONNECT 还要求 `1..65535` 的非空端口，本次不宣称完整 DNS/IPv6 语义验证、代理转发或 CONNECT 隧道
- `+安全` 默认 Native H1 接收 absolute-form request-target 时，会在 App 与请求头中间件入口把 request-target authority 作为有效 Host，忽略冲突的接收 Host 值
- `=边界` origin-form 继续使用唯一有效的接收 Host；当前不新增 Host 不一致拒绝、CONNECT 隧道或代理转发
- `+安全` 默认 Native H1 现在会在 App dispatch 前拒绝不使用 authority-form 的 `CONNECT`、非 `CONNECT` 的 authority-form，以及非 `OPTIONS` 的 asterisk-form 请求目标
- `=边界` 合法 `CONNECT authority`、`OPTIONS *`、资源级 `OPTIONS /path` 与普通 origin/absolute-form 路由保持兼容；本次不实现 CONNECT 隧道或代理转发
- `+性能` 可选 buffered 压缩现在默认要求至少 `64` bytes 的净节省；微小收益回退 identity，显著收益仍编码，`minSavingsBytes` 可显式调整
- `=边界` identity 被拒绝时仍优先满足协议要求；该策略不翻转动态 Brotli/Zstd 默认，也不宣称通用熵编码完成
- `+安全` 显式 Native H1 Client 现在只接受 `100..599` 的有效 HTTP 状态码；普通 REST 路径收到 `101 Switching Protocols` 时会在响应体暴露前失败并淘汰该连接
- `=边界` cleartext 与 Native TLS H1 共用该状态/Upgrade 收敛；本次不新增升级后传输所有权、WebSocket API，也不宣称完整 HTTP 互操作认证
- `+安全` 显式 Native H1 Client 现在会校验 chunked 响应 trailer 的字段行、字段名与字段值，并对完整 trailer 区施加 65536-byte 累计上限；失败发生在连接归池之前
- `=边界` cleartext 与 Native TLS H1 共用该 trailer 校验与预算；畸形 trailer 会淘汰当前连接，但本次不新增公开 trailer 访问 API，也不宣称完整 HTTP/代理合规认证
- `+安全` 显式 Native H1 Client 现在只接受 `HTTP/1.1` 响应版本，并在暴露响应体前拒绝缺少冒号的字段行、非法字段名以及字段值中的 NUL、DEL 和其他禁用控制字节
- `=边界` cleartext 与 Native TLS H1 共用该响应头解析器；合法 RFC token 标点和水平制表空白仍可接受，畸形连接会被淘汰，但本次不宣称完整 HTTP 或代理互操作认证
- `+安全` 显式 Native H1 Client 现在会在暴露响应体前拒绝 `Transfer-Encoding + Content-Length`、冲突的重复 `Content-Length` 与不支持的 transfer coding；cleartext 与 Native TLS H1 共用同一判定
- `=边界` 合法的等值重复 `Content-Length` 仍可接受；畸形响应连接会被淘汰且不归池，本次不宣称完整 HTTP 互操作认证
- `+安全` 默认 Native H1 现在要求每个 HTTP/1.1 请求携带且只携带一个非空 Host，并拒绝逗号合并 authority 与请求字段值中的禁用控制字节
- `=边界` 畸形请求会在 App dispatch 前返回固定无正文 400 并关闭当前连接；这不等同于独立代理链合规认证
- `+特性` 显式 cleartext/Native TLS H2 session 的 `sendWithRetry(...)` 可通过 `reconnectOnConnectionFailure: true` 对幂等 buffered 请求执行有界的响应头前断传输重连回放，并继续复用 replacement session
- `=边界` 重连要求 idle session，默认关闭；不迁移 active lease，不重放 one-pass/非幂等请求，也不恢复响应头后的 body 读取失败
- `+特性` 新增 `ResponseTransportTransformFactory`、`Ctx.registerResponseTransportTransform(...)` 与 `responseTransportTransformMiddleware(...)`，普通 `transportWriter()` 可按中间件响应洋葱顺序自动组合 fresh 状态变换
- `=边界` transform 注册在首个 transport writer 打开后冻结；当前不会自动包裹 `writer()`、SSE、sendStream/pull JSON，也不代表现有压缩策略中间件已接入
- `+特性` 动态 gzip/deflate 的缓冲与流式响应改用 Ignite 自有安全仓颉 DEFLATE/GZIP codec，不再在产品路径构造 `stdx.compress.zlib`
- `+特性` 缓冲响应使用固定 Huffman 与有界 LZ77；流式响应使用增量 stored blocks，避免完整响应捕获
- `+特性` Brotli/Zstd 继续通过 `.br` / `.zst` 预压缩静态副本交付，保持 Range、HEAD、Vary 与 MIME 语义
- `=边界` 当前 native codec 优先完成安全与协议正确性；更高压缩比、字典、SIMD 和动态 Brotli/Zstd 留待后续性能/provider 包
- `=杂项` IgniteNEXT 包版本、框架版本常量、Banner fixtures、三语 README 与双语 changelog 更新到 `0.8.1`

### v0.8.0 `Ignite Preview`

- `+特性` 明文服务端默认进入 Ignite native H1，保留 `serverPreferredBackendHint: "stdx-default"` 回滚入口
- `+特性` 原生 H1 Client 已覆盖连接复用、流式请求/响应、超时、重定向和真实 client/server loopback
- `+特性` 原生 H2 Server/Client 已形成受限多路复用、双层流控、非丢帧队列、RST/GOAWAY/timeout/peer-close 生命周期切片
- `+特性` 原生 H1 WebSocket 与 SSE 已进入真实 wire 回归；H2 extended CONNECT 不在本版承诺内
- `+特性` SeaJson `JsonWriterEncodable` 与 `SeaJsonWriter` 支持通过 OutputStream 增量写出，避免所有 JSON API 都被固定为完整字符串缓冲
- `+特性` 静态资源支持预压缩 `.br` / `.zst` 协商，动态 gzip/deflate 仍保留当前 provider 边界
- `=依赖` 发布依赖切换为 GitCode JinguiSSL Contract 与 SeaJson；clean consumer build 已验证
- `=文档` README 三语、manual 0800 preview 专章、H2 sample 说明与独立 0800 Web 入口同步
- `=边界` HTTPS 默认继续走稳定 stdx TLS；JinguiSSL native TLS/ALPN 仍为显式实验入口
- `=边界` 原生 H2 尚不声明浏览器矩阵、完整 h2spec、动态 HPACK、生产 TLS 默认或 release-grade 完成
- `=杂项` 包版本、框架版本常量与 Banner fixtures 统一到 `0.8.0`

## Ignite `0700`
> 资产压缩、协同治理、H1/H2 truth 收口

### v0.7.8 `Ignite Now`
> JinguiSSL hosted 依赖投影修复版

- `=修复` hosted GitCode 依赖键从旧 `JinguiSSL` 收口到当前 provider 包名 `jinguissl`，避免云端消费者按远程依赖构建时解析失败。
- `=修复` release-facing import 统一到 `jinguissl.contract.*` / `jinguissl.live.*`，并改为通过 contract facade 消费 `ContractTlsSessionCache`，不再由 Ignite 直接 import `jinguissl_core` 内部命名空间。
- `=修复` manual sample 运行脚本优先查找新版 `target/release/jinguissl` 产物，同时保留旧 `jinguissl_contract` runtime fallback。
- `=杂项` 包版本、框架版本常量与 README banner 展示同步到 `0.7.8`。

### v0.7.2 `Ignite Now`
> client full consumer surface 官包版

- `+特性` client full consumer story 现在形成一条完整公开路径：`manual/samples/client/**` 可从 setup / quick GET / JSON POST / builder path / hooks / body access / retained recovery / retry override 一路走到 encrypted request 与 cleanup
- `+特性` `Ctx.jsonEncodeStream(obj, contentLength?)` 现在作为 `JsonEncodable` family 的显式流式 twin 进入公开面；`ctx.jsonEncode(...)` 继续保持 full-buffer，并继续只在 full-buffer 路径使用 `Config.jsonEncoder`
- `+测试` `ClientHookTestSuite`、`ClientRetryTestSuite`、`ClientStreamingTestSuite` 与 `ClientResponseRecoveryAcceptanceTestSuite` 继续补齐 focused regressions，并通过当前 accepted serial lane 的 full `294/294`
- `+测试` `JsonEncodeStreamCtxSugarTestSuite`、`JsonEncodeStreamMiddlewareCompatTestSuite` 与 `CompressMiddlewareTestSuite` 已覆盖 `jsonEncodeStream(...)` 的 known-length / unknown-length / HEAD、当前 middleware 边界与 real-HTTP streamed-compress subset
- `+测试` 新增 `ClientHostnameSensitiveTlsProofTestSuite` 作为 runtime-owned hostname/SNI blocker-anchor suite，继续诚实保留 `not currently proven`
- `=文档` `README` 多语言、client sample README、`manual/docs-md/client.md`、`manual/docs-md/api.md` 与 source-local guidance 统一到最新 client / JSON response 口径
- `=杂项` 包版本、框架版本常量与 banner render version fixtures 同步到 `0.7.2`

### v0.7.1 `Ignite Now`
> client retained recovery reset 与 failure-path freshness 刷新版

- `+特性` `RestClient` 新增 `clearRecoverySnapshots()`，允许长生命周期 client 在下一轮 probe / retry / 诊断前显式清空 retained client-side recovery
- `+特性` 当前 `client` recovery 公开面现在明确分成两层：response-side `observeSnapshot()/transportTouchpoint()` 回放，以及 client-side `lastClientObserveSnapshot()/lastClientTransportTouchpoint()` retained 留痕
- `+测试` `ClientResponseRecoveryAcceptanceTestSuite` 新增 reset + fresh failure-path acceptance，证明清空旧状态后，新的 experimental failure 仍能回收当前轮的 observe / touchpoint
- `=文档` README、多语言 README、client sample 与 `manual/docs-md/api.md` 回归到 retained recovery / reset 的最新公开口径
- `=杂项` 包版本、框架版本常量与 banner render version fixtures 同步到 `0.7.1`

### v0.7.0 `Ignite Now`
> `0700` 公开基线版

- `=文档` 将当前公开版本基线从 `0.6.41` 提升到 `0.7.0`
- `=文档` README / README-en / README-ru 的版本展示、状态说明与当前 `H1 ready-now / H2 guarded intake` 口径重新对齐
- `=文档` `manual/docs-md/README.md` 与 `manual/samples/README.md` 回归到当前 `0700` 公开入口，补齐 `H1/H2` 首读路径
- `+特性` 当前 line 已明确把 `transport` accepted-answer proof 与 `client` public recovery proof 收成更易 handoff 的 intake-facing truth
- `+特性` 自研 `server-socket` 已形成更长的 parser/session/body/writer/runtime-experiment proof ladder，但当前仍保持 experiment/runway 口径，不冒充 default public engine
- `=杂项` 包版本与框架版本常量同步到 `0.7.0`

## Ignite `0600`
> 传输解耦起步、观测留痕加固

### v0.6.41 `Ignite Now`
> 路由扩展面收口刷新

- `=修复` router 现在允许 `"/*"` 在根路径 `"/"` 上命中，同时保持显式 `"/"` 路由优先于 catch-all
- `+特性` `App` / `Group` 的 `get/post/put/delete/patch/head/options/all` 现在都支持 `Array<Handler>` 公开写法，减少 route-level middleware 只能靠包装函数嵌套的表达负担
- `+特性` `App` 新增 `notFound(...)` 与 `methodNotAllowed(...)` hook，仍保留全局 middleware 链、`Allow` 头与 `OPTIONS` 语义
- `+特性` `Ctx` 新增 `setLocalValue(...)` / `getLocalValue<T>(...)`，让 typed request locals 可以和原有字符串 locals 并存
- `=文档` 同步 `manual/docs-md/api.md`、README 多语言说明、目标航线表述与版本常量到 `0.6.41`

### v0.6.1 `Ignite Now`
> `0600` 首个工作基线版

- `=文档` 将当前活跃版本基线从 `0.5.31` 提升到 `0.6.1`，标记 `0600` 迭代线开始
- `+特性` Client 新增结构化 observe 快照，可通过 `onObserve(...)` 获取成功 / 失败观测结果，并支持 `JSON / log line` 双输出
- `+特性` Client 补齐 transport touchpoint 留痕，请求结束后可读取最近一次 transport 选择与 observe 快照
- `+特性` Server 启动观察链继续加固，启动失败分类、transport touchpoint 与 observe snapshot 现在更容易形成连续诊断面
- `=修复` transport 错误模型补入 TLS handshake fallback candidate 的内部判定语义，但当前公开 HTTPS 默认路径与 fallback 承诺不变
- `=文档` README / README-en / README-ru / Swagger sample / 版本常量同步到 `0.6.1`

## Ignite `0500`
> 可用、可信、快上手

### v0.5.68 `bugFix`
> `0500` bugfix 收口与 client / swagger 观测修正版

- `=修复` `HTTP/2` 流式响应不再继续带出 `HTTP/1.1` 专属流式头，避免 `transfer-encoding` / `connection` 语义污染 `h2`
- `=修复` `RestClient` 观测错误补齐 `phase / causeCode / retryable`，并阻止 `TLS` / `CRYPTO` 错误被错误重试
- `=修复` `RequestBuilder` 退避等待从忙等改为 `sleep`，减少无意义 CPU 空转
- `=修复` Swagger JSON 输出对 `title / description / version` 做统一 JSON 转义，补齐控制字符回归
- `+测试` 新增 client timeout / TLS transport、response hook observe header 与 Swagger / JSON 转义回归覆盖
- `=文档` 根 README 与 manual 入口正文收口，补齐 `docs-md` 主入口与公开文档分流说明
- `=杂项` 包版本、框架版本常量、Swagger sample 与自检测试版本统一到 `0.5.68`

### v0.5.31 `Ignite Now`
> 平台矩阵细化与 README 首屏收口版

- `=文档` 将当前公开版本基线从 `0.5.27` 提升到 `0.5.31`
- `=文档` README / README-en / README-ru 的版本展示、Banner 预览宽度与当前运行时输出重新对齐
- `=文档` 支持平台矩阵细化，单列 `OpenHarmony x86_64`、`EulerOS Taishan/x86_64`、`HarmonyOS arm64`，并为 `LoongArch64` 预留位置
- `=文档` manual / Swagger sample / 自检测试中的当前版本显示同步到 `0.5.31`
- `=杂项` 包版本与框架版本常量同步到 `0.5.31`

### v0.5.27 `Ignite Now`
> 本地 release 预备版

- `=文档` 将当前公开版本基线从 `0.5.25` 提升到 `0.5.27`
- `=文档` README / README-en / README-ru 的当前版本展示同步到 `0.5.27`
- `+特性` `0500` 默认 Banner 收口到新经典样式：顶部三段式、`Touchpoints` 显示词、右下角小签名 `_Ignite <framework-version>`
- `+特性` 新增 `Config.enablePrintSwaggerUrl`，允许 Swagger 路由存在但不打印启动 `Swagger UI: ...` 行
- `=文档` README / README-en / README-ru / manual / Swagger sample 同步补齐 Banner、Swagger 显示开关与路径说明
- `=文档` 澄清当前 HTTPS 默认路径仍以 `stdx` TLS 或反向代理 TLS 终结为准，`jinguissl` 不作为默认监听链替代承诺
- `=杂项` 包版本、Swagger 示例元数据与相关测试版本同步到 `0.5.27`
- `=杂项` 为本地 `v0.5.27` tag 做准备，本次不推送远端

### v0.5.25
> `0500` 公开收口与多语言同步版

- `=文档` 将当前公开版本基线同步到 `0.5.25`
- `=文档` README / README-en / README-ru 对齐当前仓库布局、依赖写法与公开入口
- `=文档` 明确 `manual/` 为公开文档入口，继续收束公开入口与目录视图
- `=文档` 首跑说明继续以可验证路径为准，不把当前仓库包装成可直接 `cjpm run` 的可执行项目
- `=杂项` 包版本、Swagger 示例元数据与相关测试版本同步到 `0.5.25`

### v0.5.21 `Git`
作为`0500`版本组，目前基线版本`0.5.21`已完成:
- `+特性` Server / Client 双线能力面进一步拉齐，减少“服务端一套、客户端再重造一套”的割裂感
- `+特性` 压缩中间件补齐：`compressMiddleware`、`CompressConfig`、`Accept-Encoding` 协商、`gzip/deflate`、最小压缩阈值、`skipIfNoGain`
- `+特性` JWT 中间件进入主线：`JwtConfig`、`jwtMiddleware`、claims 注入、标准 `WWW-Authenticate` 返回
- `+特性` 新增 `bindJsonOr400`，统一 `invalid_json` / `invalid_payload` / `validation_failed` 的请求绑定错误语义
- `+特性` 新增 `handleForTest` 与 `AppTestResponse`，支持无需手动 `listen` 的服务链路断言
- `+特性` 新增 `nameRoute` / `urlFor`，并支持 `RouteOption.operationId` 直接作为路由名
- `+特性` 新增 `IgniteKit`，用于轻量 HTML / CSS / 动态页面资源映射
- `+特性` 新增自检API模块最小闭环：`RequestBodySpec`、`TestOption`、`InterfaceSpec`、`App.interfaceSpecs()`
- `+特性` Swagger 语义增强：支持 requestBody、response example、`x-ignite-test` 扩展信息
- `+特性` kmode 下支持最小 mock / probe 自检响应，可通过 `x-ignite-test` / `__ignite_test` 触发，并附带 `IGTEST-0500` 标记
- `+特性` 样例矩阵继续补齐：`hello`、`api`、`ignitekit`、`dualport`、`swagger`、`files`、`middleware`
- `=修复` TLS 路径继续收口：`enableTlsPrecheck`、jinkuiSSL precheck 与 stdx TLS 构造 / 回退路径并存
- `=修复` 文件下载与 Range 场景补齐流式发送、`HEAD` 语义与大文件回归
- `=文档` README、样例、Freeze、Benchmark、Release Report 与当前实现对齐
- `=杂项` release guard、sample compile guard、`cjlint` baseline、server/client API freeze 全链打通

### v0.5.01
> `0500` 版本组早期占位版本，不展开，只保留编号痕迹。

- `=杂项` 进行一个安卓 APP 占位的行为
- `=杂项` 作为 `0500` 阶段的早期编号预留版本存在

---

## Ignite `0400`
> 安全治理集成、面向生产级步进

### v0.4.71
> `0400` 工作区收口刷新版

- `=文档` `cjpm.toml`、README / README-en / README-ru 当前版本展示同步到 `0.4.71`
- `=文档` 支持平台矩阵细化，补回 `OpenHarmony x86_64` 与 `EulerOS Taishan/x86_64`
- `=文档` 英文 / 俄文 README 补齐 Swagger `enablePrintSwaggerUrl` 与路径语义说明

### v0.4.67 `Git` `CangjiePkg`
> 理论 `0400` 阶段最后一版

- `=修复` `api2` / 本机 IP 检测问题
- `=杂项` 继续为 `0500` 的可信发布与主线收口做过渡


### v0.4.57 `Git` `CangjiePkg`
> 网络事件监听

- `+特性` IP 变动监听，支持网卡地址变化事件

### v0.4.47 `Git` `CangjiePkg`
> 编译时版本宏、网络 IP 排序与 Windows 编码修复

- `+特性` 编译时从 `cjpm.toml` 读取框架版本
- `+特性` `getNetworkInfo().ips` 排序，用于启动横幅显示
- `+特性` 静态 SPA 支持：`staticSpa(prefix, root, indexFile)`
- `+特性` `api2.getPreferredLocalIP()` 辅助函数
- `=修复` Windows 下 `ipconfig` 输出 UTF-8 解码问题，避免崩溃
- `=文档` 新增俄文 README；同步英文 README（标语、环境、依赖、架构图）
- `=杂项` Windows / Linux 编译与链接选项继续优化

### v0.4.41 `Git` `CangjiePkg`
> kmode 与日志接口抽象

- `+特性` `Config.kmode` 与 `kmodeMiddleware`
- `+特性` `Logger` 接口及 `DefaultLogger` 实现，支持 `enableEntityLog`
- `+特性` 从 `cjpm.toml` 通过脚本读取框架版本
- `=修复` Windows 环境下 `getPreferredLocalIP` 跳过，避免端口占用误报
- `=文档` README 同步更新

### v0.4.27 `Git` `CangjiePkg`
> 配置与横幅系统优化

- `+特性` `Config.appVersion`，支持自定义应用版本并用于横幅标题
- `+特性` `Config.enablePrintRoutes` 开关细化
- `=修复` 启动横幅健壮性增强
- `=文档` README / CHANGELOG 同步
- `=杂项` 版本号升至 `0.4.27`

### v0.4.07 `Git` `CangjiePkg`
> 文档同步与基础特性补充

- `+特性` Swagger UI 缓存控制
- `+特性` JSON Helper 与编码辅助能力
- `+特性` 文件下载与 Range 请求支持
- `=文档` 添加项目链接与基础文档同步
- `=杂项` 版本号更新至 `0.4.07`

---

## Ignite `0300`
> 服务成套、能力成形、体验拉齐

### 核心特性

- `+特性` **中间件全家桶**  
  `AccessLog`, `Favicon`, `HealthCheck`, `StaticFile`, `Proxy`,  
  `RequestID`, `RateLimit`, `Idempotency`, `Redirect`, `Rewrite`,  
  `ETag`, `Cache`, `BodyLimit`, `Timeout`,  
  `EncryptCookie`, `Session`,  
  `Security Headers + CSRF`,  
  `Basic Auth`, `Key Auth`  
  以及共享工具库（base64, HMAC, 随机字符串）

- `+特性` **路由引擎升级**  
  严格路由冲突检测、`removeRoute`、参数校验、路径归一化  
  修复连续斜杠（consecutive paths）问题（完整版）

- `+特性` **上下文增强**  
  `bodyBytes` 缓存、响应体缓存  
  multipart 表单完整 API（含文件上传 `FormFile`, `MultipartForm`）  
  `Ctx.query()` 支持回退到 form 参数，新增 `queryFromUrl()` / `queryFromForm()`

- `+特性` **TLS 与 Swagger**  
  支持 TLS、可配置的 Swagger UI 静态资源  
  HTTP 客户端增强：multipart / 表单编码

- `+特性` **API2 基础能力**  
  跨平台 `getNetworkInfo()`，用于 `0.0.0.0` 启动时横幅显示

- `+特性` **流式传输与 WebSocket**  
  core 层继续加固 Streaming / WebSocket 能力

- `+特性` **开发者体验**  
  彩色终端输出完善、完整 MIME 类型支持

- `=文档` 更新 README（中间件列表与用法）
- `=杂项` 添加 `cjlintignore.cfg`，修正包版本元数据

## Ignite `0200`
> 蓝图内定，开始拓影

- `=修复` 请求上下文（`ctx`）处理逻辑调整
- `=修复` 路由连续斜杠（consecutive paths）问题的基础处理
- `=杂项` 后续代码清理（follow-up cleanup）
- `=杂项` 准备初始发布资源（`prepare initial publish assets`）
- `=杂项` MIME 类型完善与彩色输出细节优化

## Ignite `0100`
> 仓颉胃，Express味

- 实验性项目，本地构建孵化
- `+特性` 基础 core 层：流式传输（Streaming）、WebSocket 基础支持、HTTP 客户端基础能力
- `+特性` 彩色终端输出
- `+特性` MIME 类型基础兼容
- `+特性` 最简单的请求响应处理（基于 `httpServerKit` 引导）
- `=杂项` 初始提交（`Initial commit`）
- `=杂项` 项目结构初始化、`.gitignore` 优化

# 说明
- `+特性` / `=修复` / `=文档` / `=杂项` 用于后续可视化标识
- `Git` `CangjiePkg` 表示该版本已同步 Git 与仓颉中心仓
- 未标记 `Git` `CangjiePkg` 的版本，表示未以“双同步完成”作为该版本状态结论
- `0100`~`0300`仅保留阶段摘要，不再继续细拆子版本
