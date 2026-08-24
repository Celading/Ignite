# Ignite Sample: middleware

这个样例展示一条可直接运行的中间件组合：

- request ID、CORS 与访问日志；
- ETag 与 gzip/deflate 压缩；
- 分组路由 `/api/health` 与 `/api/blob`；
- 响应头和压缩协商的真实 HTTP/1.1 观察。

在仓库根目录运行：

```bash
./manual/samples/middleware/run.sh
```

随后可验证：

```bash
curl -i http://127.0.0.1:18813/api/health
curl -i -H 'Accept-Encoding: gzip, deflate' http://127.0.0.1:18813/api/blob
curl -i -X OPTIONS http://127.0.0.1:18813/api/blob
```

它只展示组合方式，不替代每个中间件在
[`../../docs-md/middleware.md`](../../docs-md/middleware.md) 中的配置与安全边界。
