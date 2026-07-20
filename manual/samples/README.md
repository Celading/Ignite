# Ignite Samples

这个目录负责“把 Ignite 跑起来”，不是完整手册。

在开始之前，建议先读：

1. [`../../README.md`](../../README.md)
2. [`../docs-md/Guide.md`](../docs-md/Guide.md)

Run commands from the repository root that contains `cjpm.toml`.

## Recommended order

1. `manual/samples/hello`
   - First 5-minute run
   - Minimal `GET /` + `GET /health`
2. `manual/samples/api`
   - Routing, JSON, CRUD, `bindJsonOr400`
3. `manual/samples/swagger`
   - Swagger / OpenAPI
   - `InterfaceSpec`, `TestOption`, `x-ignite-test`, `kmode`
4. `manual/samples/client`
   - Built-in `RestClient`
   - Encrypted JSON, multipart, observe headers
5. `manual/samples/ignitekit`
   - Lightweight HTML / CSS composition with `IgniteKit`
6. `manual/samples/h2wire`
   - 0800 native H2 preview and retained TLS/ALPN compatibility smoke
   - Keeps the legacy/default TLS guard separate from native H2 cleartext wire proofs
7. `manual/samples/handlefortest`
   - Multi-process stress probe for `App.handleForTest(...)`
   - Reuses one shared lease root so cross-process port planning can be exercised from files alone
8. `manual/samples/native_h1_small_heap_hardening`
   - Bounded `256mb` / `512mb` cleartext Native H1 pressure proof
   - Records runtime counters, RSS, FD, socket settlement, and request errors

For repeatable performance sampling after the functional samples pass, use
[`../benchmark`](../benchmark). It is a repository-owned 0800 baseline rather
than a public cross-framework ranking.

## H1 / H2 first route

- If your immediate need is `H1`, prefer:
  - `hello -> api -> client -> files`
- If your immediate need is `H2`, prefer:
  - `h2wire` as a preview and diagnostic path
  - treat guard logs, native fixture results, and blocker wording as separate evidence
  - do not treat the current H2 sample as browser or full h2spec conformance

## Additional samples

- `manual/samples/dualport`
  - Two listeners in one app process for local verification
- `manual/samples/files`
  - `sendFile`, `download`, `sendFileRange`, `sendStream`, `saveBodyToFile`
- `manual/samples/h2wire`
  - H2 on-wire smoke for repeated writer flush and large-file return
- `manual/samples/handlefortest`
  - Multi-process stress probe for file-backed cross-process in-proc port leases
- `manual/samples/middleware`
  - Middleware composition and request flow
- `manual/samples/brotli_interop`
  - Validate that the safe-Cangjie Brotli RAW/RLE Preview is decoded exactly by the system `brotli` tool
- `manual/samples/native_h1_small_heap_hardening`
  - Mixed prepared HTML, polling, reused HTTP/1.1 sessions, and slow-request load
  - A hardening receipt rather than a public cross-framework benchmark

## Typical commands

```bash
./manual/samples/hello/run.sh
./manual/samples/api/run.sh
./manual/samples/swagger/run.sh
./manual/samples/client/run_demo.sh
./manual/samples/files/run.sh
./manual/samples/h2wire/probe.sh
./manual/samples/h2wire/h2spec_smoke.sh
./manual/samples/handlefortest/probe.sh
./manual/samples/native_h1_small_heap_hardening/probe.sh
./manual/benchmark/run.sh
```

## Notes

- The sample runner builds Ignite from the current repository first unless `IGNITE_SAMPLE_SKIP_BUILD=1` is set.
- If stdx or runtime libraries cannot be auto-detected, set:
  - `IGNITE_STDX_STATIC=/path/to/cj_stdx_*_llvm/static`
  - `IGNITE_CJ_RUNTIME_LIB_DIR=/path/to/cangjie/runtime/lib/<platform>`
- These samples are the public runnable path. Archived helper docs may describe older layouts and should not be treated as the public entrypoint.
