# Ignite Manual

`manual/` is the current public documentation surface for this repository.

If you are evaluating Ignite for the first time, use this order:

1. `README.md` or `README-en.md`
2. `manual/samples/README.md`
3. `CHANGELOG.MD` or `CHANGELOG-en.MD`
4. `manual/skills/README.md`

## Public boundary

- This tree is the public-facing manual for the repository.
- Historical notes, internal execution logs, archived experiments, and maintainer-only process docs are intentionally not linked from here.
- When public wording and internal wording differ, this `manual/` tree and the root README files are the public contract.

## First-run path

Run commands from the repository root that contains `cjpm.toml` (current layout: `Ignite/`).

Recommended first-run order:

1. `manual/samples/hello`
2. `manual/samples/api`
3. `manual/samples/swagger`
4. `manual/samples/client`
5. `manual/samples/ignitekit`

`manual/samples/dualport`, `manual/samples/files`, and `manual/samples/middleware` are additional reference samples once the basics are clear.

## Current docs split

- `manual/samples/README.md`: runnable sample matrix and reading order
- `manual/skills/README.md`: how to use AI assistants and project skills responsibly with Ignite
- `CHANGELOG.MD`: Chinese milestone timeline
- `CHANGELOG-en.MD`: English milestone timeline

## 0.5.31 closeout notes

- The default `0500` startup banner preview is now width-aligned with the runtime output, including the `Touchpoints` label and the small `_Ignite <framework-version>` signature.
- Swagger startup output is now documented as a separate switch: `enableSwagger` controls the routes, while `enablePrintSwaggerUrl` controls only the startup line.
- The current HTTPS default remains the existing stdx TLS path or reverse-proxy TLS termination; `jinguissl` is not documented as a drop-in listener replacement in this public manual.

## Reserved integration points

- `manual/docs-md/`: reserved for the upcoming markdown documentation set
- `manual/docs-web/`: reserved for the upcoming website-oriented docs content

Until those sections are merged, prefer the root README files plus the sample docs in `manual/samples/`.
