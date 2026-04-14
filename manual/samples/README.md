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

## Additional samples

- `manual/samples/dualport`
  - Two listeners in one app process for local verification
- `manual/samples/files`
  - `sendFile`, `download`, `sendFileRange`
- `manual/samples/middleware`
  - Middleware composition and request flow

## Typical commands

```bash
./manual/samples/hello/run.sh
./manual/samples/api/run.sh
./manual/samples/swagger/run.sh
./manual/samples/client/run_demo.sh
```

## Notes

- The sample runner builds Ignite from the current repository first unless `IGNITE_SAMPLE_SKIP_BUILD=1` is set.
- If stdx or runtime libraries cannot be auto-detected, set:
  - `IGNITE_STDX_STATIC=/path/to/cj_stdx_*_llvm/static`
  - `IGNITE_CJ_RUNTIME_LIB_DIR=/path/to/cangjie/runtime/lib/<platform>`
- These samples are the public runnable path. Archived helper docs may describe older layouts and should not be treated as the public entrypoint.
