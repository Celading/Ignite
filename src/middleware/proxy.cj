package ignite.middleware

import ignite.{Handler, Ctx}
import stdx.net.http.{ClientBuilder, HttpRequestBuilder}
import std.collection.ArrayList

public class ProxyConfig {
    public var target: String
    public var pathRewrite: Array<(String, String)> = []
    public var timeout: Duration = Duration.second * 30

    public init(target: String, pathRewrite!: Array<(String, String)> = [],
                timeout!: Duration = Duration.second * 30) {
        this.target = target
        this.pathRewrite = pathRewrite
        this.timeout = timeout
    }
}

public func proxyMiddleware(config: ProxyConfig): Handler {
    let client = ClientBuilder()
        .readTimeout(config.timeout)
        .writeTimeout(config.timeout)
        .build()

    { ctx: Ctx =>
        var targetPath = ctx.path
        for ((from, to) in config.pathRewrite) {
            if (strStartsWith(targetPath, from)) {
                targetPath = to + substringFrom(targetPath, from.size)
            }
        }

        let targetUrl = config.target + targetPath
        try {
            let reqBuilder = HttpRequestBuilder()
                .method(ctx.method)
                .url(targetUrl)
                .header("X-Forwarded-For", ctx.ip)
                .header("X-Forwarded-Host", ctx.header("host") ?? "")

            let body = ctx.bodyString()
            if (body.size > 0) {
                reqBuilder.body(body)
            }

            let resp = client.send(reqBuilder.build())
            ctx.status(resp.status)
            let buf = ArrayList<UInt8>()
            let tmp = Array<UInt8>(4096, repeat: 0)
            while (true) {
                let n = resp.body.read(tmp)
                if (n <= 0) { break }
                for (i in 0..n) {
                    buf.add(tmp[i])
                }
            }
            ctx.send(buf.toArray())
        } catch (e: Exception) {
            ctx.status(502).sendString("Bad Gateway: ${e.message}")
        }
    }
}
