package ignite

import std.io.InputStream

let IGNITE_STREAM_COMPRESSION_PLAN_LOCAL_KEY = "__ignite_stream_compression_plan"

/// Minimal non-buffered compression plan for `sendStream(...)`-based responses.
///
/// This plan is registered by middleware before handler execution and consumed
/// by `Ctx.sendStream(...)` right before the response body stream is attached.
public class StreamCompressionPlan {
    public let encoding: String
    public let minBytes: Int64
    public let setVaryHeader: Bool
    public let skipIfNoGain: Bool
    public let level: Int64
    public let bufferSize: Int64
    public let mandatory: Bool

    public init(
        encoding: String,
        minBytes: Int64,
        setVaryHeader: Bool,
        skipIfNoGain: Bool,
        level: Int64,
        bufferSize: Int64,
        mandatory!: Bool = false
    ) {
        this.encoding = encoding.trimAscii().toAsciiLower()
        this.minBytes = if (minBytes < 0) { 0 } else { minBytes }
        this.setVaryHeader = setVaryHeader
        this.skipIfNoGain = skipIfNoGain
        this.level = level
        this.mandatory = mandatory
        this.bufferSize = if (bufferSize < 256) {
            256
        } else if (bufferSize > 65536) {
            65536
        } else {
            bufferSize
        }
    }
}

func currentMandatoryStreamCompressionPlan(ctx: Ctx): ?StreamCompressionPlan {
    if (let Some(plan) <- ctx.getLocalValue<StreamCompressionPlan>(IGNITE_STREAM_COMPRESSION_PLAN_LOCAL_KEY)) {
        if (plan.mandatory && plan.encoding.size > 0) {
            return Some(plan)
        }
    }
    None
}

func registerTrustedPrecompressedEncoding(ctx: Ctx, encoding: String): Unit {
    ctx.registerTrustedPrecompressedEncodingForCurrentResponse(encoding)
}

func isTrustedPrecompressedEncoding(ctx: Ctx, encoding: String, plan: StreamCompressionPlan): Bool {
    ctx.consumeTrustedPrecompressedEncodingForCurrentResponse(encoding, plan.encoding)
}

func compressStreamPlanBytes(data: Array<UInt8>, plan: StreamCompressionPlan): Array<UInt8> {
    if (plan.encoding == "br") {
        return compressBrotliResponsePayload(data)
    }
    if (plan.encoding == "zstd") {
        return compressZstdResponsePayload(data)
    }
    let format = if (plan.encoding == "deflate") {
        CompressionFormat.Deflate
    } else {
        CompressionFormat.Gzip
    }
    compressResponsePayload(data, format, level: plan.level)
}

func registerStreamCompressionPlan(ctx: Ctx, plan: StreamCompressionPlan): Unit {
    ctx.setLocalValue(IGNITE_STREAM_COMPRESSION_PLAN_LOCAL_KEY, plan)
}

func currentStreamCompressionPlan(
    ctx: Ctx,
    contentLength: ?Int64
): ?StreamCompressionPlan {
    if (ctx.responseStatus < 200 || ctx.responseStatus == 204 || ctx.responseStatus == 304) {
        return None
    }
    if ((ctx.responseHeader("content-encoding") ?? "").trimAscii().size > 0) {
        return None
    }
    if ((ctx.header("range") ?? "").trimAscii().size > 0) {
        return None
    }
    if (let Some(plan) <- ctx.getLocalValue<StreamCompressionPlan>(IGNITE_STREAM_COMPRESSION_PLAN_LOCAL_KEY)) {
        if (plan.encoding.size == 0 || plan.skipIfNoGain) {
            return None
        }
        match (contentLength) {
            case Some(size) =>
                if (size <= 0 || size < plan.minBytes) {
                    return None
                }
            case None =>
                if (plan.minBytes > 0) {
                    return None
                }
        }
        return Some(plan)
    }
    None
}

func wrapStreamWithCompressionPlan(
    stream: InputStream,
    plan: StreamCompressionPlan
): InputStream {
    if (plan.encoding == "br") {
        return BrotliCompressionInputStream(
            stream,
            chunkSize: plan.bufferSize
        )
    }
    if (plan.encoding == "zstd") {
        return ZstdCompressionInputStream(
            stream,
            chunkSize: plan.bufferSize
        )
    }
    let format = if (plan.encoding == "deflate") {
        CompressionFormat.Deflate
    } else {
        CompressionFormat.Gzip
    }
    CompressionInputStream(
        stream,
        format,
        chunkSize: plan.bufferSize
    )
}

func mergeVaryAcceptEncoding(existing: String): String {
    let trimmed = existing.trimAscii()
    if (trimmed.size == 0) {
        return "Accept-Encoding"
    }
    for (part in trimmed.split(",")) {
        if (part.trimAscii().toAsciiLower() == "accept-encoding") {
            return trimmed
        }
    }
    trimmed + ", Accept-Encoding"
}
