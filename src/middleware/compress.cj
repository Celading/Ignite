package ignite.middleware

import ignite.{
    Handler,
    Ctx,
    CompressionFormat,
    StreamCompressionPlan,
    compressBrotliResponsePayload,
    compressResponsePayload,
    compressZstdResponsePayload,
    registerStreamCompressionPlan
}
import stdx.compress.zlib.CompressLevel

public class CompressConfig {
    /// Minimum response body size (bytes) required before compression is attempted.
    public var minBytes: Int64 = 1024
    /// Preferred algorithm when both are acceptable.
    public var preferGzip: Bool = true
    /// Enable gzip support.
    public var gzipEnabled: Bool = true
    /// Enable deflate support.
    public var deflateEnabled: Bool = true
    /// Enable the Ignite-owned dynamic Zstd Preview baseline.
    public var zstdEnabled: Bool = false
    /// Enable the Ignite-owned dynamic Brotli RAW/RLE Preview baseline.
    public var brotliEnabled: Bool = false
    /// Compression level. The public stdx enum is retained for source
    /// compatibility; Ignite maps it to its native codec internally.
    public var level: CompressLevel = CompressLevel.DefaultCompression
    /// Internal stream buffer size.
    public var bufferSize: Int64 = 2048
    /// Set `Vary: Accept-Encoding` when compression is used.
    public var setVaryHeader: Bool = true
    /// Skip compression when compressed payload is not smaller than original.
    public var skipIfNoGain: Bool = true
    /// Minimum net byte saving required for optional buffered compression.
    public var minSavingsBytes: Int64 = 64

    public init(
        minBytes!: Int64 = 1024,
        preferGzip!: Bool = true,
        gzipEnabled!: Bool = true,
        deflateEnabled!: Bool = true,
        zstdEnabled!: Bool = false,
        brotliEnabled!: Bool = false,
        level!: CompressLevel = CompressLevel.DefaultCompression,
        bufferSize!: Int64 = 2048,
        setVaryHeader!: Bool = true,
        skipIfNoGain!: Bool = true,
        minSavingsBytes!: Int64 = 64
    ) {
        this.minBytes = minBytes
        this.preferGzip = preferGzip
        this.gzipEnabled = gzipEnabled
        this.deflateEnabled = deflateEnabled
        this.zstdEnabled = zstdEnabled
        this.brotliEnabled = brotliEnabled
        this.level = level
        this.bufferSize = bufferSize
        this.setVaryHeader = setVaryHeader
        this.skipIfNoGain = skipIfNoGain
        this.minSavingsBytes = if (minSavingsBytes < 0) { 0 } else { minSavingsBytes }
    }
}

public func compressMiddleware(config!: CompressConfig = CompressConfig()): Handler {
    let minBytes = if (config.minBytes < 0) { 0 } else { config.minBytes }
    let bufferSize = normalizeBufferSize(config.bufferSize)
    let nativeLevel = nativeCompressionLevel(config.level)
    let minSavingsBytes = if (config.minSavingsBytes < 0) { 0 } else { config.minSavingsBytes }

    { ctx: Ctx =>
        let negotiation = negotiateEncoding(ctx.header("accept-encoding") ?? "", config)
        if (negotiation.identityRefused && negotiation.encoding.size == 0) {
            _ = ctx.status(406).sendString("")
            return
        }
        let encoding = negotiation.encoding
        let encodingMandatory = negotiation.identityRefused && encoding.size > 0
        if (encodingMandatory && (ctx.header("range") ?? "").trimAscii().size > 0) {
            _ = ctx.status(406).setHeader("content-length", "0").send(Array<UInt8>(0, repeat: 0))
            return
        }
        if (encoding.size > 0) {
            registerStreamCompressionPlan(
                ctx,
                StreamCompressionPlan(
                    encoding,
                    if (encodingMandatory) { 0 } else { minBytes },
                    config.setVaryHeader,
                    if (encodingMandatory) { false } else { config.skipIfNoGain },
                    nativeLevel,
                    bufferSize,
                    mandatory: encodingMandatory
                )
            )
        }

        ctx.next()

        if (ctx.responseCommitted) {
            ctx.setLocal("__ignite_compress_skip_reason", "response-committed")
            return
        }

        if (ctx.method == "HEAD") { return }
        if (shouldSkipStatus(ctx.responseStatus)) { return }
        if ((ctx.header("range") ?? "").size > 0) { return }
        if ((ctx.getLocal("__ignite_response_kind") ?? "") == "sse") { return }

        if (encoding.size == 0) { return }

        if (let Some(textBody) <- ctx.responseBody) {
            let rawBytes = textBody.toArray()
            if (!encodingMandatory && rawBytes.size < minBytes) {
                return
            }
            let compressed = try {
                if (encoding == "br") {
                    compressBrotliResponsePayload(rawBytes)
                } else if (encoding == "zstd") {
                    compressZstdResponsePayload(rawBytes)
                } else {
                    compressResponsePayload(rawBytes, compressionFormat(encoding), level: nativeLevel)
                }
            } catch (_: Exception) {
                if (encodingMandatory) {
                    _ = ctx.status(500).setHeader("content-length", "0").sendString("")
                }
                return
            }

            if (!encodingMandatory && config.skipIfNoGain &&
                !compressionMeetsMinimumSavings(rawBytes.size, compressed.size, minSavingsBytes)) {
                return
            }

            if (config.setVaryHeader) {
                ctx.setHeader("vary", "Accept-Encoding")
            }
            ctx.setHeader("content-encoding", encoding)
            ctx.setHeader("content-length", "${compressed.size}")
            let _ = ctx.send(compressed)
        }
    }
}

func compressionMeetsMinimumSavings(
    rawSize: Int64,
    compressedSize: Int64,
    minSavingsBytes: Int64
): Bool {
    let savings = rawSize - compressedSize
    savings > 0 && savings >= minSavingsBytes
}

func shouldSkipStatus(status: UInt16): Bool {
    status < 200 || status == 204 || status == 304
}

func normalizeBufferSize(raw: Int64): Int64 {
    if (raw < 256) {
        return 256
    }
    if (raw > 65536) {
        return 65536
    }
    raw
}

class CompressionNegotiation {
    let encoding: String
    let identityRefused: Bool

    init(encoding: String, identityRefused: Bool) {
        this.encoding = encoding
        this.identityRefused = identityRefused
    }
}

func negotiateEncoding(acceptEncodingRaw: String, config: CompressConfig): CompressionNegotiation {
    let acceptEncoding = acceptEncodingRaw.trimAscii().toAsciiLower()
    if (acceptEncoding.size == 0) {
        return CompressionNegotiation("", false)
    }

    var qGzip: Int64 = -1
    var qDeflate: Int64 = -1
    var qZstd: Int64 = -1
    var qBrotli: Int64 = -1
    var qWildcard: Int64 = -1
    var qIdentity: Int64 = -1

    for (part in acceptEncoding.split(",")) {
        let item = part.trimAscii()
        if (item.size == 0) {
            continue
        }
        let tokens = item.split(";")
        let name = tokens[0].trimAscii()
        var quality: Int64 = 1000
        if (tokens.size > 1) {
            var idx: Int64 = 1
            while (idx < tokens.size) {
                let kv = tokens[idx].trimAscii().split("=", 2)
                if (kv.size == 2 && kv[0].trimAscii() == "q") {
                    quality = parseQValue(kv[1])
                }
                idx += 1
            }
        }
        if (quality < 0) {
            continue
        }
        if (name == "gzip") {
            qGzip = quality
        } else if (name == "deflate") {
            qDeflate = quality
        } else if (name == "zstd") {
            qZstd = quality
        } else if (name == "br") {
            qBrotli = quality
        } else if (name == "*") {
            qWildcard = quality
        } else if (name == "identity") {
            qIdentity = quality
        }
    }

    if (config.gzipEnabled && qGzip < 0) {
        qGzip = qWildcard
    }
    if (config.deflateEnabled && qDeflate < 0) {
        qDeflate = qWildcard
    }
    if (config.zstdEnabled && qZstd < 0) {
        qZstd = qWildcard
    }
    if (config.brotliEnabled && qBrotli < 0) {
        qBrotli = qWildcard
    }

    if (!config.gzipEnabled) {
        qGzip = -1
    }
    if (!config.deflateEnabled) {
        qDeflate = -1
    }
    if (!config.zstdEnabled) {
        qZstd = -1
    }
    if (!config.brotliEnabled) {
        qBrotli = -1
    }
    let identityRefused = if (qIdentity >= 0) {
        qIdentity == 0
    } else {
        qWildcard == 0
    }

    if (qGzip <= 0 && qDeflate <= 0 && qZstd <= 0 && qBrotli <= 0) {
        return CompressionNegotiation("", identityRefused)
    }

    if (qBrotli > qGzip && qBrotli > qDeflate && qBrotli > qZstd) {
        return CompressionNegotiation("br", identityRefused)
    }
    if (qZstd > qGzip && qZstd > qDeflate && qZstd > qBrotli) {
        return CompressionNegotiation("zstd", identityRefused)
    }

    if (config.preferGzip) {
        if (qGzip >= qDeflate && qGzip >= qZstd && qGzip >= qBrotli && qGzip > 0) {
            return CompressionNegotiation("gzip", identityRefused)
        }
        if (qDeflate >= qZstd && qDeflate >= qBrotli && qDeflate > 0) {
            return CompressionNegotiation("deflate", identityRefused)
        }
        if (qZstd >= qBrotli && qZstd > 0) { return CompressionNegotiation("zstd", identityRefused) }
        if (qBrotli > 0) { return CompressionNegotiation("br", identityRefused) }
        return CompressionNegotiation("", identityRefused)
    }

    if (qDeflate >= qGzip && qDeflate >= qZstd && qDeflate >= qBrotli && qDeflate > 0) {
        return CompressionNegotiation("deflate", identityRefused)
    }
    if (qGzip >= qZstd && qGzip >= qBrotli && qGzip > 0) {
        return CompressionNegotiation("gzip", identityRefused)
    }
    if (qZstd >= qBrotli && qZstd > 0) { return CompressionNegotiation("zstd", identityRefused) }
    if (qBrotli > 0) { return CompressionNegotiation("br", identityRefused) }
    CompressionNegotiation("", identityRefused)
}

// Parses RFC7231 qvalue in [0,1], returned as int in [0,1000].
func parseQValue(raw: String): Int64 {
    let s = raw.trimAscii()
    if (s.size == 0) {
        return -1
    }
    let parts = s.split(".", 2)
    if (parts.size == 0) {
        return -1
    }
    let whole = parseDigits(parts[0])
    if (whole < 0 || whole > 1) {
        return -1
    }
    var fracScaled: Int64 = 0
    if (parts.size == 2) {
        let frac = parts[1]
        if (frac.size == 0) {
            return -1
        }
        var scale: Int64 = 100
        var count: Int64 = 0
        for (ch in frac.toRuneArray()) {
            if (count >= 3) {
                break
            }
            if (ch < r'0' || ch > r'9') {
                return -1
            }
            fracScaled += digitValue(ch) * scale
            scale /= 10
            count += 1
        }
    }
    if (whole == 1) {
        if (fracScaled > 0) {
            return -1
        }
        return 1000
    }
    fracScaled
}

func parseDigits(raw: String): Int64 {
    if (raw.size == 0) {
        return -1
    }
    var out: Int64 = 0
    for (ch in raw.toRuneArray()) {
        if (ch < r'0' || ch > r'9') {
            return -1
        }
        out = out * 10 + digitValue(ch)
    }
    out
}

func digitValue(ch: Rune): Int64 {
    match (ch) {
        case r'0' => 0
        case r'1' => 1
        case r'2' => 2
        case r'3' => 3
        case r'4' => 4
        case r'5' => 5
        case r'6' => 6
        case r'7' => 7
        case r'8' => 8
        case r'9' => 9
        case _ => -1
    }
}

func compressionFormat(encoding: String): CompressionFormat {
    if (encoding == "deflate") {
        CompressionFormat.Deflate
    } else {
        CompressionFormat.Gzip
    }
}

func nativeCompressionLevel(level: CompressLevel): Int64 {
    match (level) {
        case BestSpeed => 1
        case DefaultCompression => 6
        case BestCompression => 9
    }
}
