# Brotli Interop Probe

这条探针生成 Ignite safe-Cangjie Brotli Preview 的 buffered/streamed fixtures，
再用系统 `brotli` 命令校验和解码，覆盖短输入、空输入、边界长度与压缩收益。

要求本机安装 `brotli` CLI。在仓库根目录运行：

```bash
./manual/samples/brotli_interop/probe.sh
```

输出默认位于 `/tmp/ignite-brotli-interop`。当前实现是有界 Preview baseline，
不代表完整 Brotli quality/window、字典或通用 entropy tuning。
