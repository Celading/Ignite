# Zstd Interop Probe

这条探针生成 Ignite safe-Cangjie Zstd Preview 的 buffered/streamed fixtures，
再用系统 `zstd` 命令校验 checksum 并解码比对。

要求本机安装 `zstd` CLI。在仓库根目录运行：

```bash
./manual/samples/zstd_interop/probe.sh
```

输出默认位于 `/tmp/ignite-zstd-interop`。当前实现只声明 RAW/RLE Preview
baseline，不代表完整 sequence/FSE/Huffman、字典或 level tuning。
