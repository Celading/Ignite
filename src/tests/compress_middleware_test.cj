package ignite.tests

import ignite.*
import ignite.client.RestClient
import ignite.middleware.*
import std.collection.ArrayList
import std.io.InputStream
import std.time.DateTime
import stdx.compress.zlib.{DecompressInputStream, WrapType}

@Test
public class CompressMiddlewareTestSuite {
    @TestCase
    public func testCompressMiddlewareGzipAndSkipSmallBody(): Unit {
        let largeBody = "Ignite-compress-payload-abcdefghijklmnopqrstuvwxyz-0123456789"
        let app = App(config: Config())
        app.use(compressMiddleware(config: CompressConfig(minBytes: 16, skipIfNoGain: false)))
        app.get("/large", { ctx => ctx.sendString(largeBody) })
        app.get("/small", { ctx => ctx.sendString("tiny") })

        let port = choosePort(301)
        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }

        try {
            let largeResp = sendSnapshotWithRetry(
                "http://127.0.0.1:${port}/large",
                "gzip, deflate"
            )
            @Assert(largeResp.status, 200)
            @Assert(largeResp.encoding, "gzip")
            @Assert(contains(largeResp.vary, "Accept-Encoding"), true)
            @Assert(decompressBody(largeResp.body, largeResp.encoding), largeBody)

            let smallResp = sendSnapshotWithRetry(
                "http://127.0.0.1:${port}/small",
                "gzip, deflate"
            )
            @Assert(smallResp.status, 200)
            @Assert(smallResp.encoding, "")
            @Assert(String.fromUtf8(smallResp.body), "tiny")
        } finally {
            app.shutdown()
            try {
                let _ = serverFuture.get(Duration.second * 1)
            } catch (_: Exception) {
                serverFuture.cancel()
            }
        }
    }

    @TestCase
    public func testCompressMiddlewareDeflateFallback(): Unit {
        let payload = "deflate-fallback-payload-abcdefghijklmnopqrstuvwxyz-0123456789"
        let app = App(config: Config())
        app.use(compressMiddleware(config: CompressConfig(minBytes: 8, skipIfNoGain: false)))
        app.get("/deflate", { ctx => ctx.sendString(payload) })

        let port = choosePort(357)
        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }

        try {
            let resp = sendSnapshotWithRetry(
                "http://127.0.0.1:${port}/deflate",
                "br, gzip;q=0, deflate;q=1"
            )
            @Assert(resp.status, 200)
            @Assert(resp.encoding, "deflate")
            @Assert(decompressBody(resp.body, resp.encoding), payload)
        } finally {
            app.shutdown()
            try {
                let _ = serverFuture.get(Duration.second * 1)
            } catch (_: Exception) {
                serverFuture.cancel()
            }
        }
    }

    @TestCase
    public func testCompressMiddlewareWildcardUsesPreferredEncoding(): Unit {
        let payload = "wildcard-fallback-payload-abcdefghijklmnopqrstuvwxyz-0123456789"
        let app = App(config: Config())
        app.use(compressMiddleware(config: CompressConfig(minBytes: 8, skipIfNoGain: false)))
        app.get("/wildcard", { ctx => ctx.sendString(payload) })

        let port = choosePort(389)
        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }

        try {
            let resp = sendSnapshotWithRetry(
                "http://127.0.0.1:${port}/wildcard",
                "br;q=0, *;q=1"
            )
            @Assert(resp.status, 200)
            @Assert(resp.encoding, "gzip")
            @Assert(decompressBody(resp.body, resp.encoding), payload)
        } finally {
            app.shutdown()
            try {
                let _ = serverFuture.get(Duration.second * 1)
            } catch (_: Exception) {
                serverFuture.cancel()
            }
        }
    }

    @TestCase
    public func testCompressMiddlewareCanPreferDeflate(): Unit {
        let payload = "prefer-deflate-payload-abcdefghijklmnopqrstuvwxyz-0123456789"
        let app = App(config: Config())
        app.use(compressMiddleware(config: CompressConfig(
            minBytes: 8,
            preferGzip: false,
            skipIfNoGain: false
        )))
        app.get("/prefer-deflate", { ctx => ctx.sendString(payload) })

        let port = choosePort(413)
        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }

        try {
            let resp = sendSnapshotWithRetry(
                "http://127.0.0.1:${port}/prefer-deflate",
                "gzip;q=1, deflate;q=1"
            )
            @Assert(resp.status, 200)
            @Assert(resp.encoding, "deflate")
            @Assert(decompressBody(resp.body, resp.encoding), payload)
        } finally {
            app.shutdown()
            try {
                let _ = serverFuture.get(Duration.second * 1)
            } catch (_: Exception) {
                serverFuture.cancel()
            }
        }
    }

    @TestCase
    public func testCompressMiddlewareRespectsZeroQValues(): Unit {
        let payload = "no-compress-q-zero-payload-abcdefghijklmnopqrstuvwxyz-0123456789"
        let app = App(config: Config())
        app.use(compressMiddleware(config: CompressConfig(minBytes: 8, skipIfNoGain: false)))
        app.get("/q-zero", { ctx => ctx.sendString(payload) })

        let port = choosePort(439)
        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }

        try {
            let resp = sendSnapshotWithRetry(
                "http://127.0.0.1:${port}/q-zero",
                "gzip;q=0, deflate;q=0, *;q=0"
            )
            @Assert(resp.status, 200)
            @Assert(resp.encoding, "")
            @Assert(String.fromUtf8(resp.body), payload)
        } finally {
            app.shutdown()
            try {
                let _ = serverFuture.get(Duration.second * 1)
            } catch (_: Exception) {
                serverFuture.cancel()
            }
        }
    }

    @TestCase
    public func testCompressMiddlewareWildcardUsesOnlyEnabledEncoding(): Unit {
        let payload = "wildcard-single-enabled-abcdefghijklmnopqrstuvwxyz-0123456789"
        let app = App(config: Config())
        app.use(compressMiddleware(config: CompressConfig(
            minBytes: 8,
            gzipEnabled: false,
            deflateEnabled: true,
            skipIfNoGain: false
        )))
        app.get("/wildcard-deflate", { ctx => ctx.sendString(payload) })

        let port = choosePort(467)
        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }

        try {
            let resp = sendSnapshotWithRetry(
                "http://127.0.0.1:${port}/wildcard-deflate",
                "br;q=0, *;q=1"
            )
            @Assert(resp.status, 200)
            @Assert(resp.encoding, "deflate")
            @Assert(decompressBody(resp.body, resp.encoding), payload)
        } finally {
            app.shutdown()
            try {
                let _ = serverFuture.get(Duration.second * 1)
            } catch (_: Exception) {
                serverFuture.cancel()
            }
        }
    }

    @TestCase
    public func testCompressMiddlewareWithCacheAndEtagNoRegression(): Unit {
        let payload = "cache-etag-compress-payload-abcdefghijklmnopqrstuvwxyz-0123456789"
        let app = App(config: Config())
        app.use(compressMiddleware(config: CompressConfig(minBytes: 8, skipIfNoGain: false)))
        app.use(cacheMiddleware(config: CacheConfig(expiration: Duration.second * 30)))
        app.use(etagMiddleware())
        app.get("/combo", { ctx => ctx.sendString(payload) })

        let port = choosePort(401)
        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }

        try {
            let first = sendSnapshotWithRetry(
                "http://127.0.0.1:${port}/combo",
                "gzip, deflate"
            )
            @Assert(first.status, 200)
            @Assert(first.encoding, "gzip")
            @Assert(first.xCache, "MISS")
            @Assert(first.etag.size > 0, true)
            @Assert(decompressBody(first.body, first.encoding), payload)

            let second = sendSnapshotWithRetry(
                "http://127.0.0.1:${port}/combo",
                "gzip, deflate"
            )
            @Assert(second.status, 200)
            @Assert(second.encoding, "gzip")
            @Assert(second.xCache, "HIT")
            @Assert(decompressBody(second.body, second.encoding), payload)
        } finally {
            app.shutdown()
            try {
                let _ = serverFuture.get(Duration.second * 1)
            } catch (_: Exception) {
                serverFuture.cancel()
            }
        }
    }

    func sendSnapshotWithRetry(url: String, acceptEncoding: String): ResponseSnapshot {
        let client = RestClient(
            readTimeout: Duration.second * 1,
            writeTimeout: Duration.second * 1,
            poolSize: 2
        )
        var attempt: Int64 = 0
        try {
            while (attempt < 20) {
                try {
                    let req = client.request()
                        .method("GET")
                        .url(url)
                        .header("accept-encoding", acceptEncoding)
                    let resp = req.send()
                    let body = resp.bodyBytes()
                    return ResponseSnapshot(
                        resp.status,
                        resp.header("content-encoding") ?? "",
                        resp.header("vary") ?? "",
                        resp.header("etag") ?? "",
                        resp.header("x-cache") ?? "",
                        body
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

    func decompressBody(data: Array<UInt8>, encoding: String): String {
        if (encoding.size == 0) {
            return String.fromUtf8(data)
        }
        let wrap: WrapType = if (encoding == "deflate") {
            WrapType.DeflateFormat
        } else {
            WrapType.GzipFormat
        }
        let source = BytesInputStream(toByteArray(data))
        let stream = DecompressInputStream(source, wrap: wrap, bufLen: 1024)
        let out = ArrayList<Byte>()
        let tmp = Array<Byte>(1024, repeat: 0)
        try {
            while (true) {
                let n = stream.read(tmp)
                if (n <= 0) {
                    break
                }
                for (i in 0..n) {
                    out.add(tmp[i])
                }
            }
        } finally {
            try {
                stream.close()
            } catch (_: Exception) {}
            try {
                source.close()
            } catch (_: Exception) {}
        }
        String.fromUtf8(toUInt8Array(out.toArray()))
    }

    func choosePort(offset: Int64): UInt16 {
        let nowMs = DateTime.now().toUnixTimeStamp().toMilliseconds()
        let raw = 39000 + ((nowMs + offset) % 10000)
        UInt16(raw)
    }

    func contains(text: String, target: String): Bool {
        let t = text.toRuneArray()
        let p = target.toRuneArray()
        if (p.size == 0) {
            return true
        }
        if (t.size < p.size) {
            return false
        }
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
            if (ok) {
                return true
            }
            i += 1
        }
        false
    }
}

class ResponseSnapshot {
    let status: UInt16
    let encoding: String
    let vary: String
    let etag: String
    let xCache: String
    let body: Array<UInt8>

    init(
        status: UInt16,
        encoding: String,
        vary: String,
        etag: String,
        xCache: String,
        body: Array<UInt8>
    ) {
        this.status = status
        this.encoding = encoding
        this.vary = vary
        this.etag = etag
        this.xCache = xCache
        this.body = body
    }
}

class BytesInputStream <: InputStream {
    let bytes: Array<Byte>
    var cursor: Int64 = 0

    init(bytes: Array<Byte>) {
        this.bytes = bytes
    }

    public override func read(outBuf: Array<Byte>): Int64 {
        if (cursor >= bytes.size || outBuf.size == 0) {
            return 0
        }
        let remaining = bytes.size - cursor
        let readLen = if (remaining < outBuf.size) { remaining } else { outBuf.size }
        for (i in 0..readLen) {
            outBuf[i] = bytes[cursor + i]
        }
        cursor += readLen
        readLen
    }

    public func close(): Unit {}
}

func toByteArray(input: Array<UInt8>): Array<Byte> {
    let out = Array<Byte>(input.size, repeat: 0)
    var i = 0
    while (i < input.size) {
        out[i] = input[i]
        i += 1
    }
    out
}

func toUInt8Array(input: Array<Byte>): Array<UInt8> {
    let out = Array<UInt8>(input.size, repeat: 0)
    var i = 0
    while (i < input.size) {
        out[i] = UInt8(input[i])
        i += 1
    }
    out
}
