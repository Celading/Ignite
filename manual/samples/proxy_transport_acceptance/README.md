# Proxy Transport Acceptance Probe

这是一条维护者验证探针，用于复查 HTTPS unknown-length proxy upload 的当前边界：

- 无 TLS 配置时的临时文件缓冲 fallback；
- 超过 `maxBufferedBodyBytes` 时的本地 413；
- `TlsClientConfig` seam 的接入；
- 未配置 TLS 时保留明确失败路径。

在仓库根目录运行：

```bash
./manual/samples/proxy_transport_acceptance/probe.sh
```

脚本会构建项目并运行 `ProxyMiddlewareTestSuite` 与
`ProxyTransportAcceptanceTestSuite`。它不启动公开代理服务，也不证明外部代理、
证书链或任意 upstream 的生产互操作性。
