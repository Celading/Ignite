# Ignite Changelog

## Ignite `0600`
> Transport decoupling begins, observability keeps tightening

### v0.6.41 `Ignite Now`
> Route-surface closeout refresh

- `=Fix` The router now lets `"/*"` match the root path `"/"` while still keeping an explicit `"/"` route ahead of the catch-all
- `+Feature` `App` / `Group` `get/post/put/delete/patch/head/options/all` now accept public `Array<Handler>` route chains, so per-route middleware no longer has to hide behind nested wrapper helpers
- `+Feature` `App` now exposes `notFound(...)` and `methodNotAllowed(...)` hooks while preserving the global middleware chain, `Allow` header behavior, and `OPTIONS` semantics
- `+Feature` `Ctx` now exposes `setLocalValue(...)` / `getLocalValue<T>(...)` so typed request locals can coexist with the legacy string-local API
- `=Docs` Synced `manual/docs-md/api.md`, multilingual README wording, internal truth files, and version constants to `0.6.41`

### v0.6.1 `Ignite Now`
> First working baseline of the `0600` line

- `=Docs` Raise the current active baseline from `0.5.31` to `0.6.1` and mark the start of the `0600` iteration line
- `+Feature` Client now exposes structured observe snapshots through `onObserve(...)`, with both `JSON` and `log line` forms
- `+Feature` Client transport touchpoints are retained so the latest transport selection and observe snapshot can be read after a request
- `+Feature` Server startup observability keeps tightening, making startup failure classification, transport touchpoints, and observe snapshots easier to read as one diagnosis surface
- `=Fix` The transport error model now includes internal TLS handshake fallback-candidate semantics, while the public HTTPS default path and fallback promises remain unchanged
- `=Docs` Sync `README.md`, `README-en.md`, `README-ru.md`, Swagger sample metadata, and version constants to `0.6.1`

## Ignite `0500`
> Usable, trustworthy, quick to start

### v0.5.31 `Ignite Now`
> Platform-matrix refinement and README front-page closeout refresh

- `=Docs` Raise the current public baseline from `0.5.27` to `0.5.31`
- `=Docs` Realign the README banner preview width and current-version surface with the actual runtime output
- `=Docs` Refine the support matrix so `OpenHarmony x86_64`, `EulerOS Taishan/x86_64`, and `HarmonyOS arm64` are tracked separately, while reserving room for `LoongArch64`
- `=Docs` Sync manual wording, Swagger sample metadata, and self-check test version strings to `0.5.31`
- `=Chore` Sync the package version and framework version constant to `0.5.31`

### v0.5.27 `Ignite Now`
> Local release-prep refresh

- `=Docs` Raise the current public baseline from `0.5.25` to `0.5.27`
- `=Docs` Sync the current-version display in `README.md`, `README-en.md`, and `README-ru.md` to `0.5.27`
- `+Feature` Close out the default `0500` banner into the new classic style: three-part top section, `Touchpoints` wording, and the small `_Ignite <framework-version>` signature
- `+Feature` Add `Config.enablePrintSwaggerUrl`, so Swagger routes can stay enabled while the startup `Swagger UI: ...` line is hidden
- `=Docs` Sync README / README-en / README-ru / manual / Swagger sample wording for the banner, Swagger print switch, and path semantics
- `=Docs` Clarify that the current HTTPS default remains the stdx TLS path or reverse-proxy TLS termination; `jinguissl` is not documented as the default listener replacement
- `=Chore` Sync package version, Swagger sample metadata, and related tests to `0.5.27`
- `=Chore` Prepare a local `v0.5.27` tag without pushing any remote refs in this step

### v0.5.25 `Ignite Now`
> Public-closeout and multilingual sync refresh for `0500`

- `=Docs` Sync the current public baseline version to `0.5.25`
- `=Docs` Align `README.md`, `README-en.md`, and `README-ru.md` with the current repository layout, dependency syntax, and public entrypoints
- `=Docs` Keep `manual/` as the public documentation surface and continue excluding legacy `docs/` paths and internal archive material from the public view
- `=Docs` Keep first-run guidance on a verifiable path instead of presenting this repository itself as a directly runnable `cjpm run` application
- `=Chore` Sync package version, Swagger sample metadata, and related tests to `0.5.25`

### v0.5.21 `Ignite Now` `Git`
As the current baseline of the `0500` group, `0.5.21` now includes:

- `+Feature` Server / Client capabilities are aligned more tightly, reducing the split between service-side and client-side utility layers
- `+Feature` Compression middleware closeout: `compressMiddleware`, `CompressConfig`, `Accept-Encoding` negotiation, `gzip/deflate`, minimum compression threshold, `skipIfNoGain`
- `+Feature` JWT middleware is now part of the mainline: `JwtConfig`, `jwtMiddleware`, claims injection, standard `WWW-Authenticate` responses
- `+Feature` `bindJsonOr400` unifies request binding failures into `invalid_json`, `invalid_payload`, and `validation_failed`
- `+Feature` `handleForTest` and `AppTestResponse` provide in-proc request assertions without manual `listen`
- `+Feature` `nameRoute` / `urlFor`, with `RouteOption.operationId` support as a direct route name
- `+Feature` `IgniteKit` for lightweight HTML / CSS / dynamic page resource mapping
- `+Feature` Minimum self-check API loop: `RequestBodySpec`, `TestOption`, `InterfaceSpec`, `App.interfaceSpecs()`
- `+Feature` Swagger semantics extended with request body metadata, response examples, and `x-ignite-test`
- `+Feature` `kmode` supports minimal mock / probe self-check responses triggered by `x-ignite-test` or `__ignite_test`, with `IGTEST-0500` marker output
- `+Feature` Sample matrix expanded and tightened: `hello`, `api`, `ignitekit`, `dualport`, `swagger`, `files`, `middleware`
- `=Fix` TLS path keeps closing out: `enableTlsPrecheck`, jinkuiSSL precheck, and stdx TLS construction / fallback paths coexist
- `=Fix` File download and Range flows now cover streaming send, `HEAD` semantics, and large-file regression paths
- `=Docs` README, samples, freeze docs, benchmark notes, and release reports are synced with the current implementation
- `=Chore` Release guard, sample compile guard, `cjlint` baseline, and server/client API freeze are wired end to end

### v0.5.01
> Early placeholder release in the `0500` group. Kept only as a numbered trace.

- `=Chore` Reserved as an early `0500` numbering placeholder
- `=Chore` Android app placeholder experiment

---

## Ignite `0400`
> Security governance integration, stepping toward production

### v0.4.71
> `0400` workspace closeout refresh

- `=Docs` Sync `cjpm.toml` and README / README-en / README-ru current-version surfaces to `0.4.71`
- `=Docs` Refine the support matrix to restore `OpenHarmony x86_64` and `EulerOS Taishan/x86_64`
- `=Docs` Backfill the Swagger `enablePrintSwaggerUrl` and path semantics in the English and Russian README copies

### v0.4.67 `Git` `CangjiePkg`
> Theoretical last release of the `0400` stage

- `=Fix` `api2` / local IP detection issue
- `=Chore` Transitional release heading into `0500` closeout

### v0.4.57 `Git` `CangjiePkg`
> Network event listening

- `+Feature` IP change listening for network interface address changes

### v0.4.47 `Git` `CangjiePkg`
> Compile-time version macro, IP ordering, Windows encoding fixes

- `+Feature` Read framework version from `cjpm.toml` at compile time
- `+Feature` `getNetworkInfo().ips` ordering for startup banner display
- `+Feature` Static SPA support: `staticSpa(prefix, root, indexFile)`
- `+Feature` `api2.getPreferredLocalIP()` helper
- `=Fix` UTF-8 decoding issue in Windows `ipconfig` output
- `=Docs` Added Russian README and refreshed English README
- `=Chore` Continued Windows / Linux compile and link optimization

### v0.4.41 `Git` `CangjiePkg`
> `kmode` and logger abstraction

- `+Feature` `Config.kmode` and `kmodeMiddleware`
- `+Feature` `Logger` interface and `DefaultLogger`, including `enableEntityLog`
- `+Feature` Scripted framework version loading from `cjpm.toml`
- `=Fix` Skip `getPreferredLocalIP` on Windows to avoid false-positive port occupancy issues
- `=Docs` README sync

### v0.4.27 `Git` `CangjiePkg`
> Config and banner system refinement

- `+Feature` `Config.appVersion` for banner-facing custom app versions
- `+Feature` Finer `Config.enablePrintRoutes` switch behavior
- `=Fix` Startup banner robustness improvements
- `=Docs` README / CHANGELOG sync
- `=Chore` Version bumped to `0.4.27`

### v0.4.07 `Git` `CangjiePkg`
> Doc sync and foundational additions

- `+Feature` Swagger UI cache control
- `+Feature` JSON helper and encoding utilities
- `+Feature` File download and Range request support
- `=Docs` Added project links and baseline docs sync
- `=Chore` Version bumped to `0.4.07`

---

## Ignite `0300`
> Service-ready shape, fuller capability surface, steadier DX

### Core capabilities

- `+Feature` **Full middleware family**
  `AccessLog`, `Favicon`, `HealthCheck`, `StaticFile`, `Proxy`,
  `RequestID`, `RateLimit`, `Idempotency`, `Redirect`, `Rewrite`,
  `ETag`, `Cache`, `BodyLimit`, `Timeout`,
  `EncryptCookie`, `Session`,
  `Security Headers + CSRF`,
  `Basic Auth`, `Key Auth`,
  plus shared helpers (`base64`, `HMAC`, random strings)
- `+Feature` **Router upgrades**
  strict route conflict detection, `removeRoute`, param validation, path normalization,
  and the full consecutive-slash fix path
- `+Feature` **Context upgrades**
  `bodyBytes` caching, response body caching,
  multipart form APIs including `FormFile` and `MultipartForm`,
  `Ctx.query()` fallback to form fields, plus `queryFromUrl()` / `queryFromForm()`
- `+Feature` **TLS and Swagger**
  TLS support, configurable Swagger UI static assets,
  and stronger multipart / form support on the HTTP client
- `+Feature` **API2 foundation**
  cross-platform `getNetworkInfo()` for startup banner display when using `0.0.0.0`
- `+Feature` **Streaming and WebSocket**
  continued hardening of the core streaming and WebSocket path
- `+Feature` **Developer experience**
  richer terminal color output and fuller MIME compatibility
- `=Docs` README refresh for middleware list and usage
- `=Chore` Added `cjlintignore.cfg` and corrected package metadata

## Ignite `0200`
> Blueprint settling, shape emerging

- `=Fix` Request context (`ctx`) behavior adjustments
- `=Fix` Foundational handling for consecutive slashes in routes
- `=Chore` Follow-up cleanup
- `=Chore` Prepared initial publish assets
- `=Chore` MIME and terminal color refinements

## Ignite `0100`
> Cangjie core, Express flavor

- Experimental project incubated locally
- `+Feature` Core-layer foundations: streaming, baseline WebSocket support, basic HTTP client capability
- `+Feature` Colored terminal output
- `+Feature` Baseline MIME compatibility
- `+Feature` Minimal request/response handling via `httpServerKit`
- `=Chore` Initial commit
- `=Chore` Project layout initialization and `.gitignore` refinement

# Notes

- `+Feature` / `=Fix` / `=Docs` / `=Chore` are kept as markers for future visualization
- `Git` `CangjiePkg` means the release was synchronized to both Git and the Cangjie package center
- Releases without both markers were not concluded as fully dual-synced releases
- `0100` to `0300` stay as stage summaries and are no longer split into finer public sub-versions
