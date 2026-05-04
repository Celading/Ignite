# Ignite Client Sample

This sample demonstrates a local round-trip between:

- `demo_server.cj`: a tiny Ignite server with JSON endpoints
- `demo_client.cj`: `RestClient` usage for GET/POST/encrypted JSON/multipart + observe headers + recovery snapshots

Run commands from the repository root containing `cjpm.toml` (current layout: `Ignite/`).

## 1) Run end-to-end demo

```bash
./manual/samples/client/run_demo.sh
```

This script will:

- run `cjpm build`
- compile `demo_server.cj` and `demo_client.cj`
- start server on `127.0.0.1:18080`
- run client round-trip calls and print observe headers
- auto-try `envsetup.sh`, `SDKROOT`, and `CANGJIE_STDX_PATH` on the common local macOS layout

Expected output includes:

- `GET /ping -> 200`
- `POST /echo-json -> 200`
- `POST /secure-echo -> 200`
- `POST /upload-multipart -> 200`
- observe headers (`x-ignite-observe-*`)
- response-side recovery output (`resp.observeSnapshot()` / `resp.transportTouchpoint()`)
- retained client-side recovery output (`lastClientObserveSnapshot()` / `lastClientTransportTouchpoint()`)
- one final reset line proving `clearRecoverySnapshots()` can clear retained state between probe waves

## Notes

- This sample uses `StdxFallback` crypto provider for portability.
- Client and server both use `aad = "route:/secure-echo"` for encrypted endpoint verification.
- If you run multi-step probes with one long-lived `RestClient`, use `clearRecoverySnapshots()` when you want the next success/failure to own a fresh retained recovery window.
- On local macOS setups with multiple Cangjie installs, set `IGNITE_CANGJIE_HOME=/path/to/cangjie` if the script should use a specific toolchain.
- If stdx/runtime path cannot be auto-detected, set:
  - `IGNITE_STDX_STATIC=/path/to/cj_stdx_*_llvm/static`
  - `IGNITE_CJ_RUNTIME_LIB_DIR=/path/to/cangjie/runtime/lib/<platform>`
- It is a standalone sample and does not participate in `cjpm test`.
