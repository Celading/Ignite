# Ignite Sample: dualport

这个样例用同一进程中的两个 `App` 展示 HTTP 到 HTTPS 的分离监听：

- `127.0.0.1:18080` 返回 307 重定向；
- `127.0.0.1:18443` 提供 HTTPS 服务；
- 证书和私钥只从环境变量读取，不进入仓库。

先提供本机证书路径，再从仓库根目录运行：

```bash
export IGNITE_SAMPLE_TLS_CERT=/path/to/server-cert.pem
export IGNITE_SAMPLE_TLS_KEY=/path/to/server-key.pem
./manual/samples/dualport/run.sh
```

验证：

```bash
curl -i http://127.0.0.1:18080/health
curl -k -i https://127.0.0.1:18443/health
```

`curl -k` 只适用于本地自签名样例；生产环境必须使用真实信任链并完成主机名校验。
