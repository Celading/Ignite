# Native H2 RestClient Interop Probe

这是一条进阶互操作探针，不是入门服务器样例。它启动本地 Node.js HTTP/2
fixture，并让 Ignite `RestClient` 显式选择 `ignite-native-h2-client`，验证：

- 非 GET 方法、请求头与请求体；
- 同一 H2 connection 的复用；
- 503 status retry；
- 提前关闭 response body 后淘汰旧连接并建立新连接。

要求本机安装 Node.js。在仓库根目录运行：

```bash
./manual/samples/native_h2_rest_client_interop/probe.sh
```

默认端口是 `18882`，可通过 `IGNITE_H2_INTEROP_PORT` 覆盖。这条探针不证明
TLS、浏览器、代理、长时 soak 或完整 H2 conformance。
