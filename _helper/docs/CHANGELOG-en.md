# Ignite Changelog

All notable feature and behavior changes are documented here. Version numbers follow the project `cjpm.toml` / release tags.

---

## [0.5.21] (2026-03-24)

> `0.5.21` is a formal milestone in the rolling `0.5.x` train. It marks the current releasable baseline of the `0500` closeout phase, not full `0500` completion and not a sudden version jump.

### Server

- **Release number closure**: bumped `cjpm.toml` package version to `0.5.21`, and synchronized README (CN/EN/RU) version badge/banner text to `0.5.21`.
- **Compression middleware landed (P0-1)**: added `compressMiddleware` / `CompressConfig` with `gzip/deflate`, `Accept-Encoding` negotiation, minimum-size threshold, optional `skipIfNoGain`, and `Vary: Accept-Encoding`.
- **Regression coverage added**: introduced `CompressMiddlewareTestSuite` for `gzip`, `deflate` fallback, small-body skip behavior, and compatibility with `cache + etag`.
- **jinkuiSSL parallel track integrated (P1)**: added `Config.enableTlsPrecheck` (default `true`) with rollback to the original "stdx TLS build only" path; `App.listen` TLS startup logs now include structured fields `tls_stage`, `tls_error_code`, `ignite_error_code`, and `hint`.
- **TLS wiring tests added**: introduced `TlsPrecheckIntegrationTestSuite` for invalid PEM mapping, cert/key mismatch mapping, precheck-disabled fallback behavior, and valid-input precheck success path.
- **Release-gate wiring**: `_helper/scripts/server_release_guard.sh` now requires `CompressMiddlewareTestSuite`; full `release_guard.sh` chain passes (server + client + cjlint).
- **cjlint gate hardening**: added `_helper/scripts/cjlint_error_guard.sh` and `_helper/docs/cjlint-error-baseline-0.5.21.txt`; `release_guard.sh` now fails on newly introduced cjlint errors (baseline-diff mode), preventing false-green outcomes.
- **Server API freeze alignment**: refreshed `_helper/docs/server-api-freeze-0.5.10.txt` and validated with `server_api_freeze_guard.sh`.
- **Docs sync (P0-2)**: README (CN/EN/RU) middleware tables and snippets now include `compressMiddleware`; added `ignite-framework-evaluation.md` as the current capability comparison doc.
- **Bind/validate minimal loop (P1-1)**: added `Ctx.bindJsonOr400<T>(decoder, validate?)` with unified `400` reasons: `invalid_json`, `invalid_payload`, `validation_failed`.
- **In-proc test helper (P1-2)**: added `App.handleForTest(...)` and `AppTestResponse` so route/middleware assertions can run without manual `listen`.
- **Structured logger mode (P1-3)**: added `LoggerConfig.jsonLine` for JSON-line logs (`timestamp/level/requestId/method/path/status/latencyMs/kmode`, etc.).
- **Route naming + URL generation (P2-2)**: added `App.nameRoute(...)`, `App.urlFor(...)`, and `Router.findRouteByName/setRouteName`; `RouteOption.operationId` can now act as route name directly.
- **jinkuiSSL TLS link closure**: `ignite.api2` now keeps an explicit `jinguissl.crypto.tls` type anchor to avoid missing `-ljinguissl.crypto.tls` in test linking when contract ABI references TLS-session symbols.
- **Regression suite expansion**: added `RouteUrlForTestSuite` (operationId naming, explicit naming, missing-param/missing-route semantics) and wired it into `server_release_guard.sh`.
- **First-class JWT middleware (P2-1)**: added `JwtConfig` and `jwtMiddleware` (currently `HS256`) with token extraction from Header/Query/Cookie, `exp/nbf/iat/iss/aud` checks, claims injection (`jwt_claims/jwt_sub/jwt_token`), and `WWW-Authenticate` responses.
- **JWT regression coverage**: added `JwtMiddlewareTestSuite` and wired it into `server_release_guard.sh`.
- **Sample directory expansion (P2-3)**: added `samples/hello` and `samples/api`, plus shared runner script `samples/_shared/run_server_sample.sh`.
- **File download 404 compatibility fix**: `Ctx.sendFile/download/sendFileRange` now includes a leading-slash relative-path fallback (for example, `"/README.md"` can fallback to `"./README.md"`).
- **RESTful + download regression suite**: added `FileDownloadAndRestfulTestSuite` to cover download/range paths and full GET/POST/PATCH/DELETE flow.
- **IgniteKit lightweight composition**: added `IgniteKit` (`kit.html` / `kit.css` / `kit.dynamicHtml` / `kit.mount`) to batch-map dynamically generated HTML/CSS resources into Ignite routes, keeping main API files slimmer.
- **IgniteKit regression and sample**: added `IgniteKitTestSuite` and `samples/ignitekit` (with `run.sh`), and wired both into `server_release_guard.sh`.
- **Server API freeze coverage closure**: `server_api_freeze_guard.sh` now includes `src/ignitekit.cj`, and `_helper/docs/server-api-freeze-0.5.10.txt` baseline was refreshed to prevent missing public API drift.

### Client

- **Gate chain re-validation**: completed and passed both `client_release_guard.sh` and `release_guard.sh` (server + client chained flow).
- **API freeze re-validation**: `client_api_freeze_guard.sh` passes; no public Client signature changes in this iteration, so freeze baseline remains unchanged.
- **Docs sync**: updated `client-0.5.10-usage.md` release-gate snippet to include the full chain with `release_guard.sh`.

### Engineering

- **Nested project-root detection fixed**: added `_helper/scripts/common_paths.sh` and unified root resolution for `release_guard.sh`, `server_release_guard.sh`, `client_release_guard.sh`, both freeze guards, `cjlint_error_guard.sh`, `server_benchmark.sh`, and `gen_version.sh`; the current `IgniteNEXT/Ignite` layout can now be executed directly from the workspace root.
- **TLS fixture path closure**: `TlsPrecheckIntegrationTestSuite` now supports both workspace-root and nested-`Ignite/` layouts, preventing false failures caused by `_helper/testdata/tls` path drift.
- **0500 release workflow fixed in writing**: added `ignite-0500-release-workflow.md` with the command order, execution directory, environment-failure triage, and the rule that release gates must run serially.
- **Gate chain re-validated**: re-verified `server_release_guard.sh`, `client_release_guard.sh`, `release_guard.sh`, both freeze guards, and `cjlint_error_guard.sh` on `2026-03-29`.

---

## [0.5.1]

### Added

- **Client Hook pipeline (0.5.02)**: added `ClientRequestHook` / `ClientResponseHook` / `ClientErrorHook`, available on both `RestClient` and `RequestBuilder`.
- **Client retry/backoff (0.5.03)**: added `ClientRetryConfig`, `RestClient.useRetry/disableRetry`, `RequestBuilder.retry/disableRetry`.
- **CookieJar v2 (0.5.04)**: upgraded cookie parsing/matching with `domain/path/max-age/secure/httpOnly/sameSite` and multi `set-cookie`.
- **Client API naming cleanup (0.5.05)**: added `with*` / `body*` / `on*Hook` aliases and migration notes.
- **Client API freeze (0.5.06)**: added freeze baseline `_helper/docs/client-api-freeze-0.5.06.txt` and guard script `_helper/scripts/client_api_freeze_guard.sh`.
- **Client observability (0.5.07)**: added request observability metadata (duration, retry count, error class, pluggable fields) surfaced in response headers and error hooks.
- **Streaming/large payload path (0.5.08)**: optimized `ClientResponse` large-body reading while keeping chunked `bodyStream()` consumption.
- **Fault injection and concurrency baseline (0.5.09)**: added client-side baseline tests for hook/network failure matrix and concurrent `spawn` workers.
- **ServerEngine groundwork (0.5.06)**: added `ServerEngine` / `StdxServerEngine` and `App.serverEngine(...)` injection entry with default stdx behavior unchanged.
- **Server benchmark script + unified result schema (0.5.07)**: added `_helper/scripts/server_benchmark.py`, `_helper/scripts/server_benchmark.sh`, and `ignite-benchmark-v1` JSON schema (`RPS/P95/P99/RSS`).
- **Docs and examples bundle (0.5.10)**: added `_helper/docs/client-0.5.10-usage.md` covering encrypted request, retry, cookie, hooks, observability, and streaming.
- **Local client round-trip sample (0.5.10+)**: added `samples/client/demo_server.cj`, `samples/client/demo_client.cj`, and `samples/client/run_demo.sh` for GET/POST/encrypted JSON/multipart loopback and observe-header output.
- **Release closure gate (0.5.11)**: added `_helper/scripts/client_release_guard.sh` for unified build/test/freeze checks and required client-suite presence validation.
- **Server security facade (`ignite.security`)**: added `SecurityConfig`, `SecurityProviderKind`, `SecurityException`, and unified helpers `randomHex/encryptEnvelopeV1/decryptEnvelopeV1`.

### Changed

- **Unified send pipeline**: all `RestClient` verb helpers now flow through `RequestBuilder.send()` to keep hooks/cookies/encryption behavior consistent.
- **Encrypted request hooks**: both `postEncryptedJson(...)` and `request().encryptedBodyJson(...)` pass through request/error hooks.
- **Default retry policy**: retries are enabled by default for idempotent methods only (`GET/HEAD/OPTIONS/PUT/DELETE`).
- **Client module split**: `client.cj` was split by responsibility into `client.cj`, `rest_client.cj`, `request_builder.cj`, `client_response.cj`.
- **Cookie I/O path hardening**: URL-based cookie match, expiry cleanup via `max-age`, and `headerValues("set-cookie")` now reads all duplicated header lines.
- **Observe path integration**: `RequestBuilder.send()` injects `x-ignite-observe-*` headers on success and passes observed wrapper text to error hooks.
- **Large-body read optimization**: `ClientResponse.bodyBytes()` now uses chunk aggregation; `discard()` uses larger drain buffers.
- **Release gate wiring**: `_helper/scripts/release_guard.sh` now delegates client checks to `_helper/scripts/client_release_guard.sh`.
- **Release gate cjlint runtime fallback**: `release_guard.sh` now auto-detects and exports the `cjlint` runtime library directory (`tools/lib`) to avoid `libcjlint.dylib` load failures in local environments.
- **Cookie crypto upgrade (dual-read, new-write)**: `encryptCookieMiddleware` now uses AEAD v1 by default; read path prefers v1 envelope and can fallback to legacy XOR when enabled.
- **HTTP semantics**: path-matched but method-mismatched requests now return `405` with `Allow`; `OPTIONS` on matched paths returns `204` with `Allow`.
- **HTTP semantics + middleware compatibility (0.5.08)**: `405/OPTIONS/404` semantic responses now pass through the global middleware tail chain so logger/audit/recover can observe them consistently.
- **Ctx cookie API**: `setCookie(...)` adds `sameSite` and supports middleware-driven auto encryption for outgoing cookie values.
- **Legacy cookie warning switch (0.5.09)**: `EncryptCookieConfig` now includes `legacyDecryptWarn` and `legacyDecryptWarnHook`; default remains dual-read/new-write.
- **Package version**: bumped to **0.5.1**, with new package configuration `ignite.security`.

### Tests

- Added `ClientHookTestSuite` for hook order and encrypted-request hook path.
- Added `ClientRetryTestSuite` for idempotent/default retry semantics and per-request override.
- Added `ClientCookieJarV2TestSuite` for domain/path/secure/max-age/multi-set-cookie behavior.
- Added `ClientApiRenameTestSuite` for new naming aliases and compatibility.
- Added `ClientAliasMatrixTestSuite` for alias API matrix regression (`with*` / `postJsonEncrypted` / builder aliases).
- Added `ClientLegacyCompatTestSuite` for frozen-period regression coverage of legacy client naming APIs.
- Added `ClientObserveTestSuite` for observed error payload (`errorClass/retryCount/durationMs/fields`).
- Added `ClientStreamingTestSuite` for large-body `bodyBytes/bodyStream/discard`.
- Added `ClientMultipartTestSuite` for local round-trip validation of `postMultipart` and `bodyMultipartForm` (field/file parsing).
- Added `ClientFaultBaselineTestSuite` for failure injection matrix and concurrent failure baseline.
- Stabilized `LegacyCookieWarningTestSuite`, `HttpSemanticsMiddlewareCompatTestSuite`, and `MiddlewareChainRegressionTestSuite` by preventing `RestClient` from being closed before response body consumption (`Socket is closed` intermittent failure).

---

## [0.4.61]

### Added

- **Governance subsystem (`ignite.governance`)**: added `log_level.cj`, `audit.cj`, `kmode_policy.cj`, and `redaction.cj` for 0~9 level policy, unified audit event model, kMode policy object, and sensitive-data redaction.
- **`auditMiddleware`**: added a structured audit middleware with fields `eventId/requestId/timestamp/actor/ip/route/action/result/riskLevel/kmode/session`, plus Linux-style terminal output.
- **kMode policy mode**: while keeping `kmodeMiddleware(Bool)`, added `kmodeMiddleware(policy: KModePolicy)` with Header Key + IP allowlist + capability governance.

### Changed

- **Logger 0~9 semantics and dual filtering**: formalized levels (0 Emerg … 9 Verbose); normal mode defaults to 0~6, kMode to 0~9; API usage stays `loggerMiddleware(config: LoggerConfig(...))`.
- **Logger self-check**: added runtime counters (`total/writeFail/dropped/maxLatencyMs`) and periodic health output.
- **Ctx response observability**: added `Ctx.responseStatus` and synchronized status code updates in `status/sendStatus/redirect/noContent/sendFile/sendFileRange` to align logs and audits.

### Engineering & release

- Package version bumped to **0.4.61**.
- Added package config for `ignite.governance` in `cjpm.toml`.
- README updated for governance capabilities (middleware table, kMode policy example, project layout).
- Added release gate script skeleton: `_helper/scripts/release_guard.sh`.
- Added governance baseline doc: `_helper/docs/governance-baseline.md`.

---

## [0.4.51]

### Added

- **api2.GetData (macro read cjpm.toml)**: Macro package `ignite.api2.GetData.cjpmInfo` reads [package] metadata from cjpm.toml at compile time; `GetDataClass.ModuleVer()` / `ModuleOrg()` / `ModuleName()` / `ModuleDesc()` for banner and other use. App startup banner version now uses `GetDataClass.ModuleVer()` aligned with cjpm.toml as single source.
- **api2.getNetworkInfo() IP display order**: When multiple NICs exist, returned `ips` are sorted for display: private (10/172.16–31/192.168) first, then other/public, then link-local (169.254), then loopback. Banner uses `ips[0]` as the recommended address so 169.254 does not appear first.

### Removed

- **version.cj and scripts/gen_version.sh**: Framework version now read from cjpm.toml via GetData macro; script and version.cj removed.

### Fixed

- **api2.getNetworkInfo() (Windows)**: `ipconfig /all` output is often system code page (e.g. GBK), so `String.fromUtf8` could throw. Now uses `tryDecodeUtf8OrLossy`: try UTF-8, then ASCII-only fallback (IPv4 is ASCII); outer try/catch returns empty result so banner shows 0.0.0.0 instead of crashing.

---

## [0.4.41]

### Added

- **Config.kmode**: Debug mode. When `true`, banner always prints current Ignite version; use with `kmodeMiddleware`.
- **kmodeMiddleware(kmode: Bool)**: When `kmode` is true, sets `ctx.setLocal("kmode", "true")` for downstream handlers.
- **Logger interface + DefaultLogger**: `ignite.middleware.Logger` with `log(message: String)`; default impl `DefaultLogger` (override `output` or subclass `log`); custom Logger can be injected via LoggerConfig.
- **LoggerConfig.enableEntityLog**: When true, log as entity (`method=GET path=/ latencyMs=...`); otherwise single line. Backward compat: `LoggerConfig(output: fn)` still supported.
- **ignite.getFrameworkVersion()**: Returns current framework version (aligned with cjpm.toml) for banner and debug.

### Changed

- **Console output**: When `enableSwagger`, print `Swagger UI: ${scheme}://${displayAddr}:${port}${swaggerPath}` using actual bind address (e.g. first IP when bound on 0.0.0.0). When kmode, always print `Ignite v${version} (kmode)`.
- **printBanner**: New params `enableSwagger`, `swaggerPath`, `kmode`; version from `getFrameworkVersion()`.

---

## [0.4.27]

### Changed

- **Startup banner**
  - Wrap `getProcessId()` in try/catch; show PID as `?` on failure to avoid startup crash.
  - When bound on `0.0.0.0`, if `getNetworkInfo().ips` is empty show `0.0.0.0` to avoid empty-array access.

---

## [0.4.07]

### Added

- **Swagger cache**
  - `Config.enableSwaggerCache` (default `true`): cache Swagger JSON and Swagger UI HTML to avoid recomputation.
  - `App.invalidateSwaggerCache()` to clear cache when routes/options change.
  - Query `?refresh=1` on Swagger JSON or UI path forces refresh and repopulates cache.

- **JSON**
  - New module `ignite` (e.g. `src/json.cj`): `JsonEncodable`, `JsonEncoder`, `serializeJson<T>`, `deserializeJson<T>` for stdx stream JSON.
  - `Config.jsonEncoder: ?JsonEncoder`: optional custom encoder for `JsonEncodable` types.
  - `Ctx.jsonSerialize<T>(obj)` where `T <: StdxJsonSerializable`: serialize and respond with JSON.
  - `Ctx.jsonEncode(obj: JsonEncodable)`: use `Config.jsonEncoder` or `obj.toJsonString()`.

- **File serving**
  - `Ctx.download(filePath, filename?)`: send file as attachment with `Content-Disposition: attachment; filename="..."`.
  - `Ctx.sendFileRange(filePath)`: support HTTP `Range` requests (206 Partial Content, 416 Range Not Satisfiable, `Accept-Ranges: bytes`).

### Changed

- Banner version string in `printBanner` updated to `0.4.07`.

---

## [0.4.x] (from merged feature branches)

### Router (feature/router-strict-routes-param-validation)

- **Strict route conflict**: duplicate `(method, path)` throws unless `Config.allowRouteOverwrite = true`.
- **Route removal**: `Router.removeRoute(method, path)`, `App.removeRoute(method, path)`.
- **Trie**: static segment lookup via `TrieNode.staticChildMap` (O(1)); path normalization (collapse slashes, empty path → `/`); skip empty segments in add/match/remove.
- **Path param validation**: `RouteOption.paramValidations` and `withParamValidation(name, pattern)`; patterns: `int`, `uint`, `num`, `alpha`, `alnum`, `uuid`; failed validation returns 404.

### Context (feature/ctx-query-form-fallback)

- **Ctx.query(key)**: now looks up URL query first, then request form (POST body) as fallback.
- **Ctx.queryFromUrl(key)** / **Ctx.queryFromForm(key)**: explicit URL-only or form-only lookup.

### TLS, Swagger UI, Client (feature/tls-swagger-client-api2)

- **api2 TLS**: `ignite.api2.loadTlsServerConfigForHttp2(certPem, keyPem)`; App uses it for TLS with HTTP/2 ALPN.
- **Config**: `swaggerUICssUrl`, `swaggerUIJsUrl` for configurable Swagger UI asset URLs.
- **App**: `LambdaHttpHandler` for `(HttpContext) -> Unit`; distributor `register` / `registerRoute` / `distribute` parameter naming.
- **Client**: URL/form encoding, `buildQueryString`, `buildFormUrlEncoded`; `MultipartFile` and multipart body builder.
- **Middleware**: `basic_auth` inner var renamed to `credentialPart`; session `defaultSessionStore` → `DEFAULT_SESSION_STORE`.

### api2 network (feature/tls-swagger-client-api2)

- **ignite.api2.getNetworkInfo()**: cross-platform (Windows/Linux/macOS) IP list, gateway, DNS.
- **App banner**: when bound on `0.0.0.0`, display first LAN IP via `getNetworkInfo().ips[0]` instead of `127.0.0.1`.

---

## [0.3.x] and earlier

- Middleware suite: security, CORS, CSRF, Basic/Key auth, logger, access log, request ID, recover, rate limit, body limit, timeout, cache, ETag, session, redirect, rewrite, static file, favicon, health check, idempotency, proxy.
- Core: Trie router, Groups, WebSocket, SSE, Swagger (OpenAPI 3.0 + UI), TLS/HTTP2, RestClient, onShutdown.
- Route options and Swagger integration.

---

*This file is maintained in `_helper/docs` for internal and release-note reference.*
