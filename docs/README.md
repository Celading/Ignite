# Ignite Docs

> Fiber-style experience for Cangjie web services, with production-minded defaults and a cleaner path from first run to real APIs.

## 当前状态 / Current Status

- `0.5.21` 是 `0.5.x` 迭代列车中的正式里程碑，也是当前 `0500` 收口期的可发布基线。
- 这次版本的关键词是：**可用、可信、可上手**。
- `0500` 还没有被宣告结束；当前重点是把文档、样例、发布前校验与 TLS 边界收口到可信状态。
- 下一阶段会进入 `0600` 的共享传输抽象，但本次版本**不承诺默认替代 Server 栈**。

## 5 分钟跑通 / Quickstart

在仓库根目录执行：

```bash
cjpm build
cjpm test
./samples/hello/run.sh
```

启动后可直接验证：

```bash
curl -i http://127.0.0.1:18808/
curl -i http://127.0.0.1:18808/health
```

说明：首次 `cjpm build` 会按 [cjpm.toml](../cjpm.toml) 中的公开依赖设置拉取 `jinguissl`。

## 这次最值得先试什么

1. [hello](../samples/hello/README.md)
   最小服务样例，适合先确认环境、运行方式与默认输出。
2. [api](../samples/api/README.md)
   用 Todo CRUD 看路由、JSON、参数处理、`bindJsonOr400` 与常见中间件组合。
3. [client](../samples/client/README.md)
   直接体验 `RestClient`、加密 JSON、multipart、观测头以及 Server/Client 联调。

如果你想看轻量 HTML/CSS 资源编排，也可以继续试 [ignitekit](../samples/ignitekit/README.md)。

## 文档入口 / Docs Map

- [版本时间线 / Changelog](CHANGELOG.md)
- [主 README（中文）](../README.md)
- [Main README (English)](../README-en.md)
- [README (Russian)](../README-ru.md)
- [0800 工程流总结](ignite-0800-engineering-flow-summary.md)

## 现在为什么值得试

- 服务端高频能力已经比较齐：路由、JSON、静态文件、Swagger、JWT、压缩与常见治理中间件都有明确入口。
- `bindJsonOr400`、`handleForTest`、`urlFor` 让日常开发和回归验证更顺手。
- `samples/hello`、`samples/api`、`samples/client`、`samples/ignitekit` 把第一次上手路径收拢成了可直接复现的官方入口。
- Client 与 Server 正在按“一体化演进”的思路推进，但这次版本仍然把“先让你跑起来”放在第一位。

## 次级入口 / Next

- 如果你想先用起来，请从 `samples/` 开始。
- 如果你想了解后续实验协作与 `0800` 的治理方式，请阅读 [ignite-0800-engineering-flow-summary.md](ignite-0800-engineering-flow-summary.md)。
