# Build Ignite Services With AI Assistants

This guide is written for Codex, OpenCode, Claude Code, and similar repository-aware assistants, but it is really for the maintainers working with them.

## Goal

Use AI to speed up service delivery on top of Ignite without letting the assistant invent platform guarantees, rewrite public positioning, or leak internal-only material.

## Load this context first

Before asking an assistant to build or refactor an Ignite service, point it to:

1. `README.md` or `README-en.md`
2. `manual/README.md`
3. `manual/samples/README.md`
4. `CHANGELOG.MD` or `CHANGELOG-en.MD`

If the task touches a runnable example, also load the closest sample under `manual/samples/`.

## Good tasks for AI

- scaffold a new service from a sample
- add routes, groups, and middleware wiring
- add `bindJsonOr400` request handling
- add `handleForTest(...)` route assertions
- add Swagger metadata and `RouteOption.operationId`
- add `InterfaceSpec` / `TestOption` for first-run verification
- write or refresh sample docs after code changes

## Especially good for small private programs

If the goal is a personal tool or a tiny internal service, AI works best when the scope is intentionally small:

- one real workflow
- one nearest sample
- one request binding path
- one or two tests
- one small doc update

That is usually enough to get a useful first version without turning the task into a fake “big product”. A lot of good services start exactly this way.

## Tasks that still need maintainer judgment

- changing public API shape
- changing roadmap or release language
- changing security guarantees or TLS wording
- making performance claims
- exposing archived helper docs as public docs

## Recommended workflow

1. Start from the closest sample, not a blank prompt.
2. Keep the service shape small first: routes, middleware, error handling, tests.
3. Add docs and sample updates in the same change.
4. Run the local checks before calling the work done.

## Build and verify from the repo root

```bash
cjpm build
cjpm test
bash ../_helper/scripts/server_sample_compile_guard.sh
bash ../_helper/scripts/server_release_guard.sh
```

If you are working from the workspace root instead of `Ignite/`, adjust the script path accordingly.

## Current public boundaries to respect

- Ignite is positioned as a practical Cangjie web framework, not a benchmark-hype project.
- `0500` is still a production closeout stage.
- Public docs should not bind Ignite to a `fasthttp` identity.
- Public docs should not promise `br`, QUIC, `io_uring`, or a default server-stack replacement unless the milestone has explicitly landed.

These boundaries matter because once a helper assistant writes something into public docs or sample copy, people will naturally treat it as current truth.

## Practical service-building guidance

### 1. Begin with the right sample

- Use `manual/samples/hello` for a first server skeleton.
- Use `manual/samples/api` for CRUD-style API work.
- Use `manual/samples/swagger` when interface metadata matters.
- Use `manual/samples/client` when you also need round-trip client flow.

### 2. Prefer framework-native semantics

- Use middleware instead of ad hoc per-handler duplication.
- Use `bindJsonOr400` for request decoding paths.
- Use `handleForTest(...)` for fast in-proc checks.
- Use `nameRoute` / `urlFor` or `RouteOption.operationId` when route naming matters.

### 3. Keep docs honest

- Current compression baseline is `gzip` / `deflate`.
- Current public docs should treat Brotli as not yet supported.
- A single `app.listen(addr, port)` maps to one listener.
- If a deployment needs both HTTP and HTTPS, describe that carefully instead of assuming automatic dual-port orchestration.

### 4. Keep public and internal material separate

- `manual/` is public-facing.
- Archived workspace helper docs may contain historical or internal-only details.
- Do not quote archived/internal material into public README, website copy, or release notes without maintainer review.

If you are giving an AI assistant repo context, be deliberate here. More files does not always mean better output.

### 5. Keep Cangjie work pragmatic

- Prefer explicit code over clever code.
- Check `cjpm.toml` before assuming a compiler or framework bug.
- Treat build/test stability as part of the feature, not as cleanup work.
- If a helper can be extracted cleanly, do that before proposing a deep runtime rewrite.

## Prompt pattern that works well

Use prompts like:

> Build this feature on top of `manual/samples/api`, keep public wording aligned with `manual/README.md`, add `handleForTest` coverage, and update the relevant sample README.

That usually produces better results than:

> Build me a super fast next-gen web framework feature.

## Definition of done

Ask the assistant to finish only when all of these are true:

- code builds
- tests pass
- sample/docs paths are updated
- public wording stays inside the current repository contract
- no internal-only helper material is exposed by accident

## Small-project reminder

For a hobby project or private tool, “done enough to be useful” is a real milestone.

Do not let the assistant turn:

- a private helper
- a local service
- a personal dashboard

into a bloated framework exercise.
