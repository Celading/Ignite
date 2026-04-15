# Ignite Sample: h2wire

最小 H2 on-wire smoke 样例，专门用来验证两件事：

- `ctx.writer()` 在 TLS + ALPN 的 H2 路径下可以多次写出响应体
- `sendFile(...)` 的大文件返回在 H2 路径下不依赖 `Transfer-Encoding`

## 运行服务

在仓库根目录执行：

```bash
./manual/samples/h2wire/run.sh
```

如果你本地正好就是当前 Ignite 工作区，并且 `_helper/testdata/tls/server-cert-a.pem` / `server-key-a.pem` 存在，样例会默认使用它们。
否则请先设置：

```bash
export IGNITE_SAMPLE_TLS_CERT=/path/to/server-cert.pem
export IGNITE_SAMPLE_TLS_KEY=/path/to/server-key.pem
```

启动后可手动验证：

```bash
curl -k --http2 -i https://127.0.0.1:18444/health
curl -k --http2 -N https://127.0.0.1:18444/stream
curl -k --http2 -D - -o /tmp/ignite_h2_wire.out https://127.0.0.1:18444/file
```

## 一键 probe

如果你想直接跑本地 smoke：

```bash
./manual/samples/h2wire/probe.sh
```

这个 probe 会：

1. 编译当前仓的 Ignite 与样例程序
2. 先用一个隔离的 TLS guard 进程探测 `precheck -> stdx TLS config build` 这条路径
   这条 guard 现在会继续拆成四段顺序探测：
   - `precheck`
   - `cert decode`
   - `key decode`
   - `stdx build`
3. 如果 guard 通过，再启动一个本地 TLS 服务
4. 用 Node 内建 `http2` 客户端验证：
   - ALPN 结果确实是 `h2`
   - `/stream` 没有 `Transfer-Encoding`
   - `/stream` 是多次 data event 到达，而不是单次整包
   - `/file` 没有 `Transfer-Encoding`
   - `/file` 的大响应体大小与 `content-length` 一致

如果 guard 阶段就失败，并且 log 里出现 `stdx.crypto.keys` / `decodeFromPem` / `SIGABRT`，那不是 probe 写错了，而是当前工作区已知的 `stdx` TLS 构造阻塞又被稳定复现了。
这条 probe 现在会把失败收束到一个明确阶段，而不是只给一个笼统的 “TLS build failed”，更不会直接把正式样例服务进程炸掉。
在当前工作区，这条 smoke 已经把已知崩溃进一步缩到 `key decode` 阶段，也就是 `GeneralPrivateKey.decodeFromPem(...)` 的 native abort。
这条 smoke 路线当前保留下来的价值，正是把“本地 H2 on-wire 没闭”从口头判断变成可重复失败证据。

## 环境变量（仅在自动探测失败时）

- `IGNITE_STDX_STATIC=/path/to/cj_stdx_*_llvm/static`
- `IGNITE_CJ_RUNTIME_LIB_DIR=/path/to/cangjie/runtime/lib/<platform>`
- `IGNITE_SAMPLE_TLS_CERT=/path/to/server-cert.pem`
- `IGNITE_SAMPLE_TLS_KEY=/path/to/server-key.pem`
- `IGNITE_H2_TLS_GUARD_STAGES=precheck,cert_decode,key_decode,stdx_build`
  默认按这个顺序跑；也可以只传 `key_decode`
- `IGNITE_H2_TLS_GUARD_ONLY=1`
  只跑 guard，不启动主服务；适合定点排查某个证书或私钥输入
