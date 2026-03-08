# Ignite — Next Steps (Non-Source-Code)

This document lists **actionable, non-code steps** for community, documentation, and operations. Items are grouped by area and can be done in parallel by different roles.

---

## 1. Samples & Demos

| Step | Description | Owner / Notes |
|------|-------------|----------------|
| **Minimal sample** | A single-file `samples/hello` (or repo `ignite-sample-hello`) with only `app.get("/", ...)` and `app.listen(...)`, build/run instructions. | Docs / maintainer |
| **API sample** | `samples/api` or standalone repo: REST CRUD (e.g. in-memory list), use of `ctx.jsonSerialize` / `ctx.jsonEncode`, path params, query. | Docs / maintainer |
| **Swagger sample** | `samples/swagger` or section in api sample: enable Swagger, add a few `RouteOption` (summary, params), show UI and `?refresh=1`. | Docs / maintainer |
| **File & Range sample** | `samples/files`: `sendFile`, `download`, `sendFileRange` with a test file; optional curl examples for Range. | Docs / maintainer |
| **Middleware sample** | `samples/middleware`: 2–3 middlewares (e.g. logger + CORS + static), order and `ctx.next()`. | Docs / maintainer |
| **Client sample** | `samples/client`: RestClient GET/POST, optional multipart upload, against local Ignite server. | Docs / maintainer |

**Deliverables:** One or more sample projects under `samples/` or in separate repos; each with a short README (requirements, build, run).

---

## 2. Official Documentation / Site

| Step | Description | Owner / Notes |
|------|-------------|----------------|
| **Site plan** | Decide: GitHub Pages, GitCode Pages, or static site (e.g. Docusaurus/VitePress) and where the repo lives. | Maintainer |
| **Install & quickstart** | Single “Install” page: cjpm / clone, add dependency, first `App` and `app.listen`. | Docs |
| **API reference** | Option A: hand-written “API reference” sections (App, Ctx, Config, Router, Group, Client). Option B: generate from code comments later. | Docs |
| **Guides** | Short guides: “Routing”, “Middleware”, “Swagger”, “TLS”, “HTTP client”, “File serving & Range”. Can be markdown in repo first, then moved to site. | Docs |
| **Changelog on site** | Expose `_helper/docs/CHANGELOG.md` (or a copy) as “Changelog” / “Releases” on the site. | Docs / maintainer |

**Deliverables:** Documentation site (or doc branch) with install, quickstart, and at least 2–3 guides; link from README.

---

## 3. README & Repo Guidance

| Step | Description | Owner / Notes |
|------|-------------|----------------|
| **README version** | Keep badge and any “current version” text in README in sync with `cjpm.toml` on release (e.g. script or checklist). | Maintainer |
| **README “Contributing”** | Add a short “Contributing” section: how to build, test, and open PRs; link to code of conduct if any. | Maintainer |
| **README “Samples”** | Add a “Samples” section linking to `samples/` or external sample repos. | Maintainer |
| **README “Docs”** | Add a “Documentation” section linking to the official site or to `_helper/docs` for internal/advanced. | Maintainer |
| **Issue/PR templates** | Optional: GitHub/GitCode issue and PR templates (bug report, feature request, doc fix). | Maintainer |

**Deliverables:** Updated README sections; optional issue/PR templates.

---

## 4. Community & Operations

| Step | Description | Owner / Notes |
|------|-------------|----------------|
| **Release checklist** | Markdown checklist: bump version in cjpm.toml and README, update CHANGELOG, tag, publish (cjpm publish), announce. | Maintainer |
| **Announcement channel** | Decide where to announce releases (e.g. Cangjie community, forum, or repo Discussions) and add link in README. | Maintainer |
| **Version support** | Document which Cangjie / stdx versions are supported (e.g. in README or docs). | Maintainer |

**Deliverables:** Release checklist in `_helper/docs` or repo root; README link to announcement channel; version support note.

---

## 5. Suggested Order

1. **Quick wins:** README “Samples” and “Documentation” placeholders; release checklist; keep README version in sync.
2. **Content:** At least one minimal sample (hello or api); 2–3 guides (routing, middleware, Swagger or file).
3. **Site:** Simple static site or Pages with install + quickstart + links to guides and CHANGELOG.
4. **Growth:** More samples (client, files, middleware); optional API reference and PR/issue templates.

---

*File: `_helper/docs/next-steps.md`. Update this list as items are completed or priorities change.*
