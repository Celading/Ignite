# Ignite Docs MD

这里是 Ignite `0800 Preview` 的中文正文主入口。

根 `README.md` 负责项目门面，这个目录负责把公开能力讲清楚，后续 `docs-web` 也会直接以这里为内容源稿，而不是再重新发明一套章节结构。

## 阅读顺序

1. [`ig0800-preview.md`](ig0800-preview.md)
   先确认 native H1/H2、TLS 回滚、SeaJson 流式 JSON 与未完成边界。
2. [`capability-matrix-0800.md`](capability-matrix-0800.md)
   用五种状态查看 Server、Client、H2、JSON、压缩与 stdx 残留。
3. [`api-0800.md`](api-0800.md)
   查 0800 新增或行为变化的公开签名与限制。
4. [`migration-0700-to-0800.md`](migration-0700-to-0800.md)
   从 0.7.7 升级时按默认 H1、body limit、流式 JSON、TLS 与 H2 边界逐项回归。
5. [`Guide.md`](Guide.md)
   先理解 Ignite 是什么、适合什么项目、如何接依赖、如何首跑、常见问题怎么排。
6. [`api.md`](api.md)
   再看核心对象、路由注册、配置对象、请求绑定、命名路由与进程内测试。
7. [`middleware.md`](middleware.md)
   接着了解安全、治理、流量控制、缓存压缩与中间件组合方式。
8. [`client.md`](client.md)
   如果你需要服务端和调用端一起协作，这一页解释 `RestClient` 与 Builder 模式。
9. [`advanced.md`](advanced.md)
   放高级能力与部署边界，例如 WebSocket、SSE、静态托管、Swagger、TLS、优雅关闭。
10. [`addon.md`](addon.md)
   最后看项目结构、平台矩阵、生态入口与参与方式。

## 适合哪些读者

- 第一次接触 Ignite，想在仓颉里快速跑起第一个服务的人。
- 正在把样例迁入业务仓，需要一份比根 README 更完整的公开正文的人。
- 希望结合 `manual/samples/` 与 `CHANGELOG*` 来稳定推进服务落地的人。

## 与其他入口的边界

- 根 [`../../README.md`](../../README.md)：项目首页门面，只负责讲方向、竞争力与入口分流。
- [`../samples/README.md`](../samples/README.md)：可运行路径，重点是怎么最快验证能力，而不是解释全部语义；当前 `H1` 推荐路径与 `H2 guarded intake` 路径都优先从这里进入。
- [`../../CHANGELOG.MD`](../../CHANGELOG.MD)：版本时间线与阶段收口，不替代手册正文。
- [`../docs-web/README.md`](../docs-web/README.md)：网站文档占位，后续消费本目录内容。

## docs-web 对应关系

- `Guide.md` -> `overview/getting-started`
- `capability-matrix-0800.md` -> `docs/capabilities`
- `migration-0700-to-0800.md` -> `docs/migration`
- `api-0800.md` -> `api/*`
- `api.md` -> `core/api`
- `middleware.md` -> `middleware/*`
- `client.md` -> `client/*`
- `advanced.md` -> `advanced/*`
- `addon.md` -> `ecosystem/project`
