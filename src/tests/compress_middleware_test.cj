package ignite.tests

import ignite.*
import ignite.client.RestClient
import ignite.middleware.*
import seajson.JsonWriter as SeaJsonNativeWriter
import std.collection.{ArrayList, HashMap}
import std.io.InputStream
import std.net.{TcpSocket, IPSocketAddress}
import std.time.DateTime
import stdx.compress.zlib.{CompressLevel, DecompressInputStream, WrapType}

@Test
public class CompressMiddlewareTestSuite {
    @TestCase
    public func testCompressConfigRetainsCompressLevelSourceCompatibility(): Unit {
        let speed = CompressConfig(level: CompressLevel.BestSpeed)
        let defaultLevel = CompressConfig(level: CompressLevel.DefaultCompression)
        let best = CompressConfig(level: CompressLevel.BestCompression)

        @Assert(speed.minBytes, 1024)
        @Assert(defaultLevel.minBytes, 1024)
        @Assert(best.minBytes, 1024)
    }

    @TestCase
    public func testNativeCodecCompressesBufferedAndStreamsAcrossStoredBlocks(): Unit {
        let raw = Array<UInt8>(70000, repeat: 0x61)
        let expected = String.fromUtf8(raw)

        let buffered = compressResponsePayload(raw, CompressionFormat.Gzip)
        @Assert(buffered.size < raw.size, true)
        @Assert(decompressBody(buffered, "gzip"), expected)

        let source = SendStreamBytesInput(toSendStreamByteArray(raw))
        let stream = CompressionInputStream(
            source,
            CompressionFormat.Deflate,
            chunkSize: 4096
        )
        let streamed = readAllCompressionBytes(stream)
        @Assert(decompressBody(streamed, "deflate"), expected)
    }

    @TestCase
    public func testNativeCodecRoundTripsDeterministicBinaryPayload(): Unit {
        let raw = Array<UInt8>(100000, repeat: 0)
        for (i in 0..raw.size) {
            raw[i] = UInt8((i * 31 + i / 7) & 0xff)
        }

        let gzip = compressResponsePayload(raw, CompressionFormat.Gzip)
        let deflate = compressResponsePayload(raw, CompressionFormat.Deflate)
        let stored = compressResponsePayload(raw, CompressionFormat.Deflate, level: 0)
        @Assert(compressionByteArraysEqual(decompressBytes(gzip, "gzip"), raw), true)
        @Assert(compressionByteArraysEqual(decompressBytes(deflate, "deflate"), raw), true)
        @Assert(compressionByteArraysEqual(decompressBytes(stored, "deflate"), raw), true)
    }

    @TestCase
    public func testZstdBufferedFrameUsesKnownSizeRleAndChecksum(): Unit {
        let raw = Array<UInt8>(200000, repeat: 0x41)
        let encoded = compressZstdResponsePayload(raw)

        @Assert(encoded[0], UInt8(0x28))
        @Assert(encoded[1], UInt8(0xb5))
        @Assert(encoded[2], UInt8(0x2f))
        @Assert(encoded[3], UInt8(0xfd))
        @Assert(encoded[4], UInt8(0x84))
        @Assert(encoded[5], UInt8(0x38))
        @Assert(encoded.size < Int64(32), true)
        @Assert(compressionByteArraysEqual(decodeZstdBaseline(encoded), raw), true)
    }

    @TestCase
    public func testZstdStreamingFrameUsesUnknownSizeAndBoundedBlocks(): Unit {
        let raw = Array<UInt8>(200000, repeat: 0)
        for (i in 0..raw.size) {
            raw[i] = UInt8((i * 37 + i / 11) & 0xff)
        }
        let stream = ZstdCompressionInputStream(
            SendStreamBytesInput(toSendStreamByteArray(raw)),
            chunkSize: 65536
        )
        let encoded = readAllCompressionBytes(stream)

        @Assert(encoded[4], UInt8(0x04))
        @Assert(encoded[5], UInt8(0x38))
        @Assert(compressionByteArraysEqual(decodeZstdBaseline(encoded), raw), true)
    }

    @TestCase
    public func testCompressMiddlewareNegotiatesDynamicZstdOverRealHttp(): Unit {
        let payload = "Z" * 4096
        let app = App(config: Config())
        app.use(compressMiddleware(config: CompressConfig(
            minBytes: 8,
            zstdEnabled: true,
            skipIfNoGain: false
        )))
        app.get("/zstd", { ctx => ctx.sendString(payload) })

        let port = choosePort(329)
        let serverFuture = spawn { app.listen("127.0.0.1", port) }
        try {
            let resp = sendRawBinarySnapshotWithRetry(
                port,
                "/zstd",
                "zstd;q=1, gzip;q=0.5, deflate;q=0"
            )
            @Assert(resp.status, 200)
            @Assert(resp.encoding, "zstd")
            @Assert(contains(resp.vary, "Accept-Encoding"), true)
            @Assert(decompressBody(resp.body, resp.encoding), payload)
            @Assert(resp.body.size < payload.size, true)
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
    public func testCompressMiddlewareSkipsZstdWhenFrameHasNoGain(): Unit {
        let raw = Array<UInt8>(4096, repeat: 0)
        for (i in 0..raw.size) {
            raw[i] = UInt8(32 + ((i * 31 + i / 7) % 95))
        }
        let payload = String.fromUtf8(raw)
        let app = App(config: Config())
        app.use(compressMiddleware(config: CompressConfig(
            minBytes: 8,
            gzipEnabled: false,
            deflateEnabled: false,
            zstdEnabled: true
        )))
        app.get("/zstd-no-gain", { ctx => ctx.send(raw) })

        let port = choosePort(341)
        let serverFuture = spawn { app.listen("127.0.0.1", port) }
        try {
            let resp = sendRawBinarySnapshotWithRetry(port, "/zstd-no-gain", "zstd")
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

    @TestCase
    public func testCompressMiddlewareCanCompressJsonStreamKnownLengthOverRealHttp(): Unit {
        let payload = "{\"msg\":\"stream-gzip\"}"
        let app = App(config: Config())
        app.use(compressMiddleware(config: CompressConfig(minBytes: 0, skipIfNoGain: false)))
        app.get("/json-stream-known", { ctx =>
            _ = ctx.jsonStream({ jw =>
                jw.startObject()
                jw.writeName("msg")
                jw.writeValue("stream-gzip")
                jw.endObject()
            }, contentLength: Some(payload.size))
        })

        let port = choosePort(487)
        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }

        try {
            let resp = sendRawBinarySnapshotWithRetry(
                port,
                "/json-stream-known",
                "gzip, deflate"
            )
            @Assert(resp.status, 200)
            @Assert(resp.encoding, "gzip")
            @Assert(contains(resp.vary, "Accept-Encoding"), true)
            @Assert(resp.transferEncoding, "chunked")
            @Assert(resp.contentLength, "")
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
    public func testCompressMiddlewareCanCompressJsonEncodeStreamKnownLengthOverRealHttp(): Unit {
        let payload = JsonEncodeStreamCompressionValue("encode-stream-gzip")
        let expected = payload.toJsonString()
        let app = App(config: Config())
        app.use(compressMiddleware(config: CompressConfig(minBytes: 0, skipIfNoGain: false)))
        app.get("/json-encode-stream-known", { ctx =>
            _ = ctx.jsonEncodeStream(payload, contentLength: Some(expected.size))
        })

        let port = choosePort(489)
        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }

        try {
            let resp = sendRawBinarySnapshotWithRetry(
                port,
                "/json-encode-stream-known",
                "gzip, deflate"
            )
            @Assert(resp.status, 200)
            @Assert(resp.encoding, "gzip")
            @Assert(contains(resp.vary, "Accept-Encoding"), true)
            @Assert(resp.transferEncoding, "chunked")
            @Assert(resp.contentLength, "")
            @Assert(decompressBody(resp.body, resp.encoding), expected)
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
    public func testCompressMiddlewareCanCompressJsonEncodeStreamUnknownLengthOverRealHttp(): Unit {
        let payload = JsonEncodeStreamCompressionValue("encode-stream-chunked")
        let expected = payload.toJsonString()
        let app = App(config: Config())
        app.use(compressMiddleware(config: CompressConfig(
            minBytes: 0,
            preferGzip: false,
            skipIfNoGain: false
        )))
        app.get("/json-encode-stream-unknown", { ctx =>
            _ = ctx.jsonEncodeStream(payload)
        })

        let port = choosePort(493)
        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }

        try {
            let resp = sendRawBinarySnapshotWithRetry(
                port,
                "/json-encode-stream-unknown",
                "deflate, gzip;q=0"
            )
            @Assert(resp.status, 200)
            @Assert(resp.encoding, "deflate")
            @Assert(contains(resp.vary, "Accept-Encoding"), true)
            @Assert(resp.transferEncoding, "chunked")
            @Assert(resp.contentLength, "")
            @Assert(decompressBody(resp.body, resp.encoding), expected)
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
    public func testCompressMiddlewareCanCompressSendStreamUnknownLengthOverRealHttp(): Unit {
        let payload = "stream-deflate-payload-abcdefghijklmnopqrstuvwxyz-0123456789"
        let app = App(config: Config())
        app.use(compressMiddleware(config: CompressConfig(
            minBytes: 0,
            preferGzip: false,
            skipIfNoGain: false
        )))
        app.get("/stream-unknown", { ctx =>
            let stream = SendStreamBytesInput(toSendStreamByteArray(payload.toArray()))
            _ = ctx.sendStream(stream, contentType: "text/plain; charset=utf-8")
        })

        let port = choosePort(491)
        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }

        try {
            let resp = sendRawBinarySnapshotWithRetry(
                port,
                "/stream-unknown",
                "deflate, gzip;q=0"
            )
            @Assert(resp.status, 200)
            @Assert(resp.encoding, "deflate")
            @Assert(contains(resp.vary, "Accept-Encoding"), true)
            @Assert(resp.transferEncoding, "chunked")
            @Assert(resp.contentLength, "")
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
    public func testCompressMiddlewareMergesAcceptEncodingIntoExistingResponseVaryForJsonStream(): Unit {
        let payload = "{\"msg\":\"vary-gzip\"}"
        let app = App(config: Config())
        app.use(compressMiddleware(config: CompressConfig(minBytes: 0, skipIfNoGain: false)))
        app.get("/json-stream-vary", { ctx =>
            let _ = ctx.setHeader("vary", "Origin")
            _ = ctx.jsonStream({ jw =>
                jw.startObject()
                jw.writeName("msg")
                jw.writeValue("vary-gzip")
                jw.endObject()
            }, contentLength: Some(payload.size))
        })

        let port = choosePort(503)
        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }

        try {
            let resp = sendRawBinarySnapshotWithRetry(
                port,
                "/json-stream-vary",
                "gzip, deflate"
            )
            @Assert(resp.status, 200)
            @Assert(resp.encoding, "gzip")
            @Assert(occurrencesOf(resp.vary, "Origin"), Int64(1))
            @Assert(occurrencesOf(resp.vary, "Accept-Encoding"), Int64(1))
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
    public func testCompressMiddlewareSkipsJsonStreamWhenResponseAlreadyHasContentEncoding(): Unit {
        let payload = "{\"msg\":\"identity\"}"
        let app = App(config: Config())
        app.use(compressMiddleware(config: CompressConfig(minBytes: 0, skipIfNoGain: false)))
        app.get("/json-stream-encoded", { ctx =>
            let _ = ctx.setHeader("content-encoding", "identity")
            _ = ctx.jsonStream({ jw =>
                jw.startObject()
                jw.writeName("msg")
                jw.writeValue("identity")
                jw.endObject()
            }, contentLength: Some(payload.size))
        })

        let port = choosePort(509)
        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }

        try {
            let resp = sendRawBinarySnapshotWithRetry(
                port,
                "/json-stream-encoded",
                "gzip, deflate"
            )
            @Assert(resp.status, 200)
            @Assert(resp.encoding, "identity")
            @Assert(resp.transferEncoding, "")
            @Assert(resp.contentLength, payload.size.toString())
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
    public func testCompressMiddlewareHeadJsonStreamKeepsHeadersWithoutStartingProducer(): Unit {
        let payload = "{\"msg\":\"head-gzip\"}"
        let started = ArrayList<String>()
        let app = App(config: Config())
        app.use(compressMiddleware(config: CompressConfig(minBytes: 0, skipIfNoGain: false)))
        app.head("/json-stream-head-compress", { ctx =>
            _ = ctx.jsonStream({ jw =>
                started.add("started")
                jw.startObject()
                jw.writeName("msg")
                jw.writeValue("head-gzip")
                jw.endObject()
            }, contentLength: Some(payload.size))
        })

        let port = choosePort(521)
        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }

        try {
            let resp = sendRawBinarySnapshotWithRetry(
                port,
                "/json-stream-head-compress",
                "gzip, deflate",
                method: "HEAD"
            )
            @Assert(resp.status, 200)
            @Assert(resp.encoding, "gzip")
            @Assert(contains(resp.vary, "Accept-Encoding"), true)
            @Assert(resp.transferEncoding, "")
            @Assert(resp.contentLength, "0")
            @Assert(resp.body.size, Int64(0))
            @Assert(started.size, Int64(0))
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
    public func testCompressMiddlewareHeadJsonEncodeStreamKeepsHeadersWithoutStartingWriter(): Unit {
        let payload = "{\"head\":true}"
        let started = ArrayList<String>()
        let app = App(config: Config())
        app.use(compressMiddleware(config: CompressConfig(minBytes: 0, skipIfNoGain: false)))
        app.head("/json-encode-stream-head-compress", { ctx =>
            _ = ctx.jsonEncodeStream(
                HeadTrackedJsonEncodeStreamCompressionValue(started),
                contentLength: Some(payload.size)
            )
        })

        let port = choosePort(523)
        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }

        try {
            let resp = sendRawBinarySnapshotWithRetry(
                port,
                "/json-encode-stream-head-compress",
                "gzip, deflate",
                method: "HEAD"
            )
            @Assert(resp.status, 200)
            @Assert(resp.encoding, "gzip")
            @Assert(contains(resp.vary, "Accept-Encoding"), true)
            @Assert(resp.transferEncoding, "")
            @Assert(resp.contentLength, "0")
            @Assert(resp.body.size, Int64(0))
            @Assert(started.size, Int64(0))
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
    public func testCompressMiddlewareCanCompressJsonWriteOverRealHttp(): Unit {
        let payload = "{\"msg\":\"jsonwrite-gzip\"}"
        let app = App(config: Config())
        app.use(compressMiddleware(config: CompressConfig(minBytes: 0, skipIfNoGain: false)))
        app.get("/json-write-compress", { ctx =>
            _ = ctx.jsonWrite({ jw =>
                jw.startObject()
                jw.writeName("msg")
                jw.writeValue("jsonwrite-gzip")
                jw.endObject()
            })
        })

        let port = choosePort(557)
        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }

        try {
            let resp = sendRawBinarySnapshotWithRetry(
                port,
                "/json-write-compress",
                "gzip, deflate"
            )
            @Assert(resp.status, 200)
            @Assert(resp.encoding, "gzip")
            @Assert(contains(resp.vary, "Accept-Encoding"), true)
            @Assert(resp.transferEncoding, "chunked")
            @Assert(resp.contentLength, "")
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
    public func testCompressMiddlewareSkipsJsonWriteWhenNoAcceptEncoding(): Unit {
        let payload = "{\"msg\":\"jsonwrite-raw\"}"
        let app = App(config: Config())
        app.use(compressMiddleware(config: CompressConfig(minBytes: 0, skipIfNoGain: false)))
        app.get("/json-write-raw", { ctx =>
            _ = ctx.jsonWrite({ jw =>
                jw.startObject()
                jw.writeName("msg")
                jw.writeValue("jsonwrite-raw")
                jw.endObject()
            })
        })

        let port = choosePort(559)
        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }

        try {
            let resp = sendRawBinarySnapshotWithRetry(
                port,
                "/json-write-raw",
                "" // no accept-encoding, no compression plan
            )
            @Assert(resp.status, 200)
            @Assert(resp.encoding, "")
            @Assert(contains(resp.vary, "Accept-Encoding"), false)
            @Assert(resp.transferEncoding, "chunked")
            @Assert(resp.contentLength, "")
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
                        resp.header("transfer-encoding") ?? "",
                        resp.header("content-length") ?? "",
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

    func sendRawBinarySnapshotWithRetry(
        port: UInt16,
        target: String,
        acceptEncoding: String,
        method!: String = "GET"
    ): ResponseSnapshot {
        var attempt: Int64 = 0
        while (attempt < 20) {
            try {
                return sendRawBinarySnapshot(port, target, acceptEncoding, method: method)
            } catch (_: Exception) {
                if (attempt == 19) {
                    throw Exception("failed to connect raw binary test server: ${port} ${target}")
                }
                sleep(Duration.millisecond * 50)
                attempt += 1
            }
        }
        throw Exception("failed to connect raw binary test server: ${port} ${target}")
    }

    func sendRawBinarySnapshot(
        port: UInt16,
        target: String,
        acceptEncoding: String,
        method!: String = "GET"
    ): ResponseSnapshot {
        let socket = TcpSocket(IPSocketAddress.parse("127.0.0.1:${port}"))
        socket.connect()
        try {
            var request = "${method} ${target} HTTP/1.1\r\n"
            request += "host: 127.0.0.1:${port}\r\n"
            request += "accept-encoding: ${acceptEncoding}\r\n"
            request += "connection: close\r\n\r\n"
            socket.write(request.toArray())

            let buf = Array<UInt8>(4096, repeat: 0)
            let raw = ArrayList<UInt8>()
            while (true) {
                let n = socket.read(buf)
                if (n <= 0) {
                    break
                }
                for (i in 0..n) {
                    raw.add(buf[i])
                }
            }
            parseRawBinarySnapshot(raw.toArray())
        } finally {
            socket.close()
        }
    }

    func parseRawBinarySnapshot(raw: Array<UInt8>): ResponseSnapshot {
        let splitIdx = indexOfHeaderTerminator(raw)
        let headerBytes = if (splitIdx >= 0) { raw[..splitIdx] } else { raw }
        let rawBody = if (splitIdx >= 0) { raw[splitIdx + 4..raw.size] } else { Array<UInt8>() }
        let lines = String.fromUtf8(headerBytes).split("\r\n")
        if (lines.size == 0) {
            throw Exception("raw binary response missing status line")
        }

        let status = parseBinaryStatusCode(lines[0])
        let headers = HashMap<String, String>()
        var i: Int64 = 1
        while (i < lines.size) {
            let line = lines[i]
            let colonIdx = indexOfBinaryRune(line, r':')
            if (colonIdx > 0) {
                let key = line[..colonIdx].trimAscii().toAsciiLower()
                let value = line[colonIdx + 1..line.size].trimAscii()
                headers.add(key, value)
            }
            i += 1
        }

        let body = if ((headers.get("transfer-encoding") ?? "") == "chunked") {
            decodeChunkedBinaryBody(rawBody)
        } else {
            rawBody
        }
        ResponseSnapshot(
            status,
            headers.get("content-encoding") ?? "",
            headers.get("vary") ?? "",
            headers.get("etag") ?? "",
            headers.get("x-cache") ?? "",
            headers.get("transfer-encoding") ?? "",
            headers.get("content-length") ?? "",
            body
        )
    }

    func indexOfHeaderTerminator(raw: Array<UInt8>): Int64 {
        if (raw.size < 4) {
            return -1
        }
        var i: Int64 = 0
        while (i <= raw.size - 4) {
            if (
                raw[i] == UInt8(13) &&
                raw[i + 1] == UInt8(10) &&
                raw[i + 2] == UInt8(13) &&
                raw[i + 3] == UInt8(10)
            ) {
                return i
            }
            i += 1
        }
        -1
    }

    func parseBinaryStatusCode(statusLine: String): UInt16 {
        let parts = statusLine.split(" ")
        if (parts.size < 2) {
            throw Exception("invalid status line: ${statusLine}")
        }
        let digits = parts[1].trimAscii()
        if (digits.size == 0) {
            throw Exception("invalid status code: ${statusLine}")
        }
        var value: Int64 = 0
        for (ch in digits.toRuneArray()) {
            if (ch < r'0' || ch > r'9') {
                throw Exception("invalid status code: ${statusLine}")
            }
            value = value * 10 + (Int64(UInt32(ch)) - Int64(UInt32(r'0')))
        }
        UInt16(value)
    }

    func indexOfBinaryRune(text: String, target: Rune): Int64 {
        let runes = text.toRuneArray()
        var i: Int64 = 0
        while (i < runes.size) {
            if (runes[i] == target) {
                return i
            }
            i += 1
        }
        -1
    }

    func decodeChunkedBinaryBody(raw: Array<UInt8>): Array<UInt8> {
        var idx: Int64 = 0
        let out = ArrayList<UInt8>()
        while (idx < raw.size) {
            let lineEnd = indexOfBinaryLineTerminator(raw, idx)
            if (lineEnd < 0) {
                throw Exception("invalid chunked binary response: missing chunk header terminator")
            }
            let sizeText = String.fromUtf8(raw[idx..lineEnd]).trimAscii().toAsciiLower()
            let chunkSize = parseBinaryHexInt64(sizeText)
            idx = lineEnd + 2
            if (chunkSize == 0) {
                break
            }
            if (idx + chunkSize > raw.size) {
                throw Exception("invalid chunked binary response: chunk overrun")
            }
            for (byte in raw[idx..idx + chunkSize]) {
                out.add(byte)
            }
            idx += chunkSize
            if (idx + 1 >= raw.size || raw[idx] != UInt8(13) || raw[idx + 1] != UInt8(10)) {
                throw Exception("invalid chunked binary response: missing chunk terminator")
            }
            idx += 2
        }
        out.toArray()
    }

    func indexOfBinaryLineTerminator(raw: Array<UInt8>, start: Int64): Int64 {
        var i = start
        while (i + 1 < raw.size) {
            if (raw[i] == UInt8(13) && raw[i + 1] == UInt8(10)) {
                return i
            }
            i += 1
        }
        -1
    }

    func parseBinaryHexInt64(text: String): Int64 {
        let trimmed = text.trimAscii().toAsciiLower()
        if (trimmed.size == 0) {
            throw Exception("invalid hex integer")
        }
        var value: Int64 = 0
        for (ch in trimmed.toRuneArray()) {
            let digit = if (ch >= r'0' && ch <= r'9') {
                Int64(UInt32(ch) - UInt32(r'0'))
            } else if (ch >= r'a' && ch <= r'f') {
                Int64(UInt32(ch) - UInt32(r'a')) + 10
            } else {
                throw Exception("invalid hex integer")
            }
            value = value * 16 + digit
        }
        value
    }

    func decompressBody(data: Array<UInt8>, encoding: String): String {
        String.fromUtf8(decompressBytes(data, encoding))
    }

    func decompressBytes(data: Array<UInt8>, encoding: String): Array<UInt8> {
        if (encoding.size == 0) {
            return data
        }
        if (encoding == "zstd") {
            return decodeZstdBaseline(data)
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
        toUInt8Array(out.toArray())
    }

    func decodeZstdBaseline(data: Array<UInt8>): Array<UInt8> {
        if (
            data.size < 8 || data[0] != UInt8(0x28) || data[1] != UInt8(0xb5) ||
            data[2] != UInt8(0x2f) || data[3] != UInt8(0xfd)
        ) {
            throw Exception("invalid Zstd frame magic")
        }
        let descriptor = data[4]
        let singleSegment = (descriptor & UInt8(0x20)) != UInt8(0)
        let checksum = (descriptor & UInt8(0x04)) != UInt8(0)
        let dictionaryFlag = Int64(descriptor & UInt8(0x03))
        let contentSizeFlag = Int64((descriptor >> 6) & UInt8(0x03))
        var cursor: Int64 = 5
        if (!singleSegment) {
            cursor += 1
        }
        cursor += match (dictionaryFlag) {
            case 0 => 0
            case 1 => 1
            case 2 => 2
            case _ => 4
        }
        let contentSizeField = match (contentSizeFlag) {
            case 0 => if (singleSegment) { 1 } else { 0 }
            case 1 => 2
            case 2 => 4
            case _ => 8
        }
        var expectedSize: Int64 = -1
        if (contentSizeField > 0) {
            expectedSize = readZstdLittleEndian(data, cursor, contentSizeField)
            if (contentSizeFlag == 1) {
                expectedSize += 256
            }
            cursor += contentSizeField
        }

        let out = ArrayList<UInt8>()
        var last = false
        while (!last) {
            if (cursor + 3 > data.size) {
                throw Exception("truncated Zstd block header")
            }
            let header = Int64(data[cursor]) |
                (Int64(data[cursor + 1]) << 8) |
                (Int64(data[cursor + 2]) << 16)
            cursor += 3
            last = (header & 1) != 0
            let blockType = (header >> 1) & 0x03
            let blockSize = header >> 3
            if (blockType == 0) {
                if (cursor + blockSize > data.size) {
                    throw Exception("truncated Zstd RAW block")
                }
                for (value in data[cursor..cursor + blockSize]) {
                    out.add(value)
                }
                cursor += blockSize
            } else if (blockType == 1) {
                if (cursor >= data.size) {
                    throw Exception("truncated Zstd RLE block")
                }
                let value = data[cursor]
                cursor += 1
                for (_ in 0..blockSize) {
                    out.add(value)
                }
            } else {
                throw Exception("test decoder only accepts Ignite RAW/RLE Zstd blocks")
            }
        }
        if (checksum) {
            cursor += 4
        }
        if (cursor != data.size) {
            throw Exception("unexpected bytes after Zstd frame")
        }
        if (expectedSize >= 0 && expectedSize != out.size) {
            throw Exception("Zstd content size mismatch")
        }
        out.toArray()
    }

    func readZstdLittleEndian(data: Array<UInt8>, offset: Int64, count: Int64): Int64 {
        var value: Int64 = 0
        var i: Int64 = 0
        while (i < count) {
            value = value | (Int64(data[offset + i]) << (i * 8))
            i += 1
        }
        value
    }

    func readAllCompressionBytes(stream: InputStream): Array<UInt8> {
        let out = ArrayList<Byte>()
        let buffer = Array<Byte>(1024, repeat: 0)
        try {
            while (true) {
                let count = stream.read(buffer)
                if (count <= 0) {
                    break
                }
                for (i in 0..count) {
                    out.add(buffer[i])
                }
            }
        } finally {
            match (stream) {
                case closable: Resource => closable.close()
                case _ => ()
            }
        }
        toUInt8Array(out.toArray())
    }

    func compressionByteArraysEqual(left: Array<UInt8>, right: Array<UInt8>): Bool {
        if (left.size != right.size) {
            return false
        }
        for (i in 0..left.size) {
            if (left[i] != right[i]) {
                return false
            }
        }
        true
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

    func occurrencesOf(text: String, target: String): Int64 {
        let t = text.toRuneArray()
        let p = target.toRuneArray()
        if (p.size == 0 || t.size < p.size) {
            return 0
        }
        var count: Int64 = 0
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
                count += 1
                i += p.size
            } else {
                i += 1
            }
        }
        count
    }
}

class ResponseSnapshot {
    let status: UInt16
    let encoding: String
    let vary: String
    let etag: String
    let xCache: String
    let transferEncoding: String
    let contentLength: String
    let body: Array<UInt8>

    init(
        status: UInt16,
        encoding: String,
        vary: String,
        etag: String,
        xCache: String,
        transferEncoding: String,
        contentLength: String,
        body: Array<UInt8>
    ) {
        this.status = status
        this.encoding = encoding
        this.vary = vary
        this.etag = etag
        this.xCache = xCache
        this.transferEncoding = transferEncoding
        this.contentLength = contentLength
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

class JsonEncodeStreamCompressionValue <: JsonEncodable & JsonWriterEncodable {
    let _msg: String

    public init(msg: String) {
        _msg = msg
    }

    public func toJsonString(): String {
        "{\"msg\":\"${_msg}\"}"
    }

    public func writeJson(writer: SeaJsonNativeWriter): Unit {
        writer.beginObject()
            .name("msg").value(_msg)
        .endObject()
    }
}

class HeadTrackedJsonEncodeStreamCompressionValue <: JsonWriterEncodable {
    let _started: ArrayList<String>

    public init(started: ArrayList<String>) {
        _started = started
    }

    public func writeJson(writer: SeaJsonNativeWriter): Unit {
        _started.add("started")
        writer.beginObject()
            .name("head").value(true)
        .endObject()
    }
}
