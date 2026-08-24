# Docs Web Content Map

这里定义网站呈现层消费公开正文时的稳定映射，不维护第二套技术承诺。
当前可直接阅读的内容仍位于 `manual/docs-md/`，页面生成器或外部文档站应按
下面的顺序消费：

1. [`../README.md`](../README.md)
2. [`../docs-md/README.md`](../docs-md/README.md)
3. [`../samples/README.md`](../samples/README.md)
4. [`../../CHANGELOG.MD`](../../CHANGELOG.MD)

## Route map

| Web route | Canonical source |
|---|---|
| `/docs/getting-started` | [`../docs-md/Guide.md`](../docs-md/Guide.md) |
| `/docs/0800-preview` | [`../docs-md/ig0800-preview.md`](../docs-md/ig0800-preview.md) |
| `/docs/capabilities` | [`../docs-md/capability-matrix-0800.md`](../docs-md/capability-matrix-0800.md) |
| `/docs/migration` | [`../docs-md/migration-0700-to-0800.md`](../docs-md/migration-0700-to-0800.md) |
| `/api/0800` | [`../docs-md/api-0800.md`](../docs-md/api-0800.md) |
| `/api/core` | [`../docs-md/api.md`](../docs-md/api.md) |
| `/docs/middleware` | [`../docs-md/middleware.md`](../docs-md/middleware.md) |
| `/docs/client` | [`../docs-md/client.md`](../docs-md/client.md) |
| `/docs/advanced` | [`../docs-md/advanced.md`](../docs-md/advanced.md) |
| `/docs/ecosystem` | [`../docs-md/addon.md`](../docs-md/addon.md) |

站点不存在或尚未部署时，这个映射不构成在线网站可用性的声明；仓库内 Markdown
始终是当前可审计的公开正文。
