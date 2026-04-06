# Ignite Skills

这个目录解释在 Ignite 仓库里什么叫“skill”，以及如何让 Codex、OpenCode、Claude Code 这类 AI 助手在公开边界内协作，而不是越界改写项目定位。

它不只是写给 AI 看，也写给维护者看。一个好的 skill，本质上是在助手开工前，先把边界、样例、检查项和“这轮不要做什么”讲清楚。

在让 AI 助手真正开始动手前，建议至少先加载：

1. [`../../README.md`](../../README.md)
2. [`../docs-md/README.md`](../docs-md/README.md)
3. [`../samples/README.md`](../samples/README.md)
4. [`../../CHANGELOG.MD`](../../CHANGELOG.MD) / [`../../CHANGELOG-en.MD`](../../CHANGELOG-en.MD)

## 什么是 skill

在这个仓库里，skill 可以理解成一份“可复用的协作上下文包”。它可以服务于：

- 人类维护者
- Codex
- OpenCode
- Claude Code
- 其他带仓库上下文的 AI 助手

一个好的 skill，应该在助手写代码前先把边界讲清楚：

- Ignite 当前公开支持什么
- 哪些样例是参考路径
- 哪些能力只是内部规划，不能写进公开文档
- 改动完成前应该做哪些检查

## 当前公开边界

- Ignite 是面向真实服务落地的仓颉 Web 框架，不是榜单叙事项目。
- `0500` 仍是生产级收尾阶段。
- 公开文档不应把 Brotli、QUIC、`io_uring`、默认 Server 栈替换写成已经完成的承诺。
- `manual/` 是公开面，归档和内部材料不应直接抄进来。

## 从哪里开始

- [`ignite-service-build-with-ai.md`](ignite-service-build-with-ai.md)

这份说明更具体地写了：

- 什么任务适合交给 AI
- 哪些任务仍然需要维护者判断
- 在仓库根目录该跑哪些检查
- 怎样给 AI 一个更不容易跑偏的提示词

- [`build-small-private-programs-with-ai.md`](build-small-private-programs-with-ai.md)

这份说明更适合：

- 想做自己的私人程序
- 想用 Ignite 起一个低成本小服务
- 还不想一上来就背大产品心态
- 想让 AI 帮自己跨过空白页，但又不想把方向判断外包出去
