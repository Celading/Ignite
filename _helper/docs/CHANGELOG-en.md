# Ignite Changelog

All notable feature and behavior changes are documented here. Version numbers follow the project `cjpm.toml` / release tags.

---

## [Unreleased]

### Added

- **Config.appVersion**: Optional application version string for the startup banner title. When empty, the framework version (e.g. 0.4.27) is shown; when set, the app version (e.g. 1.0.0) is shown. Banner is always printed and cannot be disabled.

### Changed

- **Config.enablePrintRoutes**: Clarified—when `true`, the route table is printed at startup; the banner is always shown regardless.
- **printBanner**: Title line uses `Config.appVersion` when non-empty, otherwise the framework version.

---

## [0.4.27] (current)

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
