package ignite.tests

import ignite.*
import ignite.client.RestClient
import ignite.middleware.*
import std.collection.ArrayList
import std.fs.{File, OpenMode}
import std.time.DateTime

@Test
public class ProxyMiddlewareTestSuite {
    @TestCase
    public func testProxyMiddlewareStreamsLargeUploadAndPreservesQuery(): Unit {
        let upstreamPort = choosePort(1801)
        let proxyPort = choosePort(1807)
        let fixturePath = "/tmp/ignite_proxy_upload_fixture.txt"
        let payload = buildLargeAsciiPayload() + buildLargeAsciiPayload()

        let upstream = App(config: Config(bodyLimit: 8 * 1024 * 1024))
        upstream.post("/up/upload", { ctx =>
            let saved = ctx.saveBodyToFile(fixturePath)
            let token = ctx.queryFromUrl("token") ?? ""
            let contentType = ctx.header("content-type") ?? ""
            let forwardedHost = ctx.header("x-forwarded-host") ?? ""
            _ = ctx.status(201).sendString(
                "saved=${saved};token=${token};content-type=${contentType};forwarded-host=${forwardedHost}"
            )
        })

        let proxy = App(config: Config(bodyLimit: 8 * 1024 * 1024))
        proxy.use(proxyMiddleware(
            ProxyConfig(
                "http://127.0.0.1:${upstreamPort}",
                pathRewrite: [("/proxy", "/up")]
            )
        ))

        let upstreamFuture = spawn {
            upstream.listen("127.0.0.1", upstreamPort)
        }
        let proxyFuture = spawn {
            proxy.listen("127.0.0.1", proxyPort)
        }

        try {
            let resp = sendRequestWithRetry(
                "POST",
                "http://127.0.0.1:${proxyPort}/proxy/upload?token=abc123",
                body: payload,
                headers: [("content-type", "text/plain; charset=utf-8")]
            )
            @Assert(resp.status, UInt16(201))
            @Assert(contains(resp.bodyText, "saved=${payload.size}"), true)
            @Assert(contains(resp.bodyText, "token=abc123"), true)
            @Assert(contains(resp.bodyText, "content-type=text/plain; charset=utf-8"), true)
            @Assert(contains(resp.bodyText, "forwarded-host=127.0.0.1:${proxyPort}"), true)
            @Assert(readTextFile(fixturePath), payload)
        } finally {
            shutdownApp(upstream, upstreamFuture)
            shutdownApp(proxy, proxyFuture)
        }
    }

    @TestCase
    public func testProxyMiddlewareRelaysLargeFileResponseAndHeaders(): Unit {
        let upstreamPort = choosePort(1813)
        let proxyPort = choosePort(1819)
        let fixturePath = "/tmp/ignite_proxy_response_fixture.txt"
        let payload = buildLargeAsciiPayload()
        writeTextFile(fixturePath, payload)

        let upstream = App(config: Config())
        upstream.get("/up/file", { ctx =>
            _ = ctx.setHeader("x-upstream", "ok")
            _ = ctx.sendFile(fixturePath)
        })

        let proxy = App(config: Config())
        proxy.use(proxyMiddleware(
            ProxyConfig(
                "http://127.0.0.1:${upstreamPort}",
                pathRewrite: [("/proxy", "/up")]
            )
        ))

        let upstreamFuture = spawn {
            upstream.listen("127.0.0.1", upstreamPort)
        }
        let proxyFuture = spawn {
            proxy.listen("127.0.0.1", proxyPort)
        }

        try {
            let resp = sendRequestWithRetry(
                "GET",
                "http://127.0.0.1:${proxyPort}/proxy/file?download=1"
            )
            @Assert(resp.status, UInt16(200))
            @Assert(resp.bodyText, payload)
            @Assert(resp.contentType, "text/plain; charset=utf-8")
            @Assert(resp.contentLength, payload.size.toString())
            @Assert(resp.acceptRanges, "bytes")
            @Assert(resp.xUpstream, "ok")
        } finally {
            shutdownApp(upstream, upstreamFuture)
            shutdownApp(proxy, proxyFuture)
        }
    }

    func sendRequestWithRetry(
        method: String,
        url: String,
        body!: String = "",
        headers!: Array<(String, String)> = []
    ): ProxyResponseSnapshot {
        let client = RestClient(
            readTimeout: Duration.second * 2,
            writeTimeout: Duration.second * 2,
            poolSize: 2
        )
        var attempt: Int64 = 0
        try {
            while (attempt < 20) {
                try {
                    let request = client.request()
                        .method(method)
                        .url(url)
                    for ((key, value) in headers) {
                        request.header(key, value)
                    }
                    if (body.size > 0) {
                        request.body(body)
                    }
                    let resp = request.send()
                    let payload = resp.bodyBytes()
                    return ProxyResponseSnapshot(
                        resp.status,
                        String.fromUtf8(payload),
                        resp.header("content-type") ?? "",
                        resp.header("content-length") ?? "",
                        resp.header("accept-ranges") ?? "",
                        resp.header("x-upstream") ?? ""
                    )
                } catch (_: Exception) {
                    if (attempt == 19) {
                        throw Exception("failed to connect test server: ${url}")
                    }
                    sleep(Duration.millisecond * 50)
                    attempt += 1
                }
            }
        } finally {
            client.close()
        }
        throw Exception("failed to connect test server: ${url}")
    }

    func shutdownApp(app: App, future: Future<Unit>): Unit {
        app.shutdown()
        try {
            let _ = future.get(Duration.second * 1)
        } catch (_: Exception) {
            future.cancel()
        }
    }

    func choosePort(offset: Int64): UInt16 {
        let nowMs = DateTime.now().toUnixTimeStamp().toMilliseconds()
        let raw = 43000 + ((nowMs + offset) % 10000)
        UInt16(raw)
    }

    func buildLargeAsciiPayload(): String {
        let line = "ignite-proxy-streaming-regression-0123456789-ABCDEFGHIJKLMNOPQRSTUVWXYZ\n"
        var out = ""
        var i: Int64 = 0
        while (i < 4096) {
            out += line
            i += 1
        }
        out
    }

    func writeTextFile(path: String, body: String): Unit {
        let file = File(path, OpenMode.Write)
        file.write(body.toArray())
        file.close()
    }

    func readTextFile(path: String): String {
        let file = File(path, OpenMode.Read)
        let buf = ArrayList<UInt8>()
        let tmp = Array<UInt8>(4096, repeat: 0)
        while (true) {
            let n = file.read(tmp)
            if (n <= 0) {
                break
            }
            for (i in 0..n) {
                buf.add(tmp[i])
            }
        }
        file.close()
        String.fromUtf8(buf.toArray())
    }

    func contains(text: String, sub: String): Bool {
        let t = text.toRuneArray()
        let p = sub.toRuneArray()
        if (p.size == 0) { return true }
        if (t.size < p.size) { return false }
        var i: Int64 = 0
        while (i <= t.size - p.size) {
            var ok = true
            var j: Int64 = 0
            while (j < p.size) {
                if (t[i + j] != p[j]) {
                    ok = false
                    break
                }
                j += 1
            }
            if (ok) { return true }
            i += 1
        }
        false
    }
}

class ProxyResponseSnapshot {
    let status: UInt16
    let bodyText: String
    let contentType: String
    let contentLength: String
    let acceptRanges: String
    let xUpstream: String

    init(
        status: UInt16,
        bodyText: String,
        contentType: String,
        contentLength: String,
        acceptRanges: String,
        xUpstream: String
    ) {
        this.status = status
        this.bodyText = bodyText
        this.contentType = contentType
        this.contentLength = contentLength
        this.acceptRanges = acceptRanges
        this.xUpstream = xUpstream
    }
}
