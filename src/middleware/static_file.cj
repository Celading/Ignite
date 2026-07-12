package ignite.middleware

import ignite.{Handler, Ctx, resolveStaticAssetPath}
import std.fs.exists

public class StaticFileConfig {
    public var root: String = "./public"
    public var index: String = "index.html"
    public var browse: Bool = false
    public var maxAge: Int64 = 0
    public var precompressed: Bool = true
    public var brotliSuffix: String = ".br"
    public var zstdSuffix: String = ".zst"

    public init(
        root!: String = "./public",
        index!: String = "index.html",
        browse!: Bool = false,
        maxAge!: Int64 = 0,
        precompressed!: Bool = true,
        brotliSuffix!: String = ".br",
        zstdSuffix!: String = ".zst"
    ) {
        this.root = root
        this.index = index
        this.browse = browse
        this.maxAge = maxAge
        this.precompressed = precompressed
        this.brotliSuffix = brotliSuffix
        this.zstdSuffix = zstdSuffix
    }
}

public func staticFileMiddleware(config!: StaticFileConfig = StaticFileConfig()): Handler {
    { ctx: Ctx =>
        if (ctx.method != "GET" && ctx.method != "HEAD") {
            ctx.next()
            return
        }

        let filePathOpt = if (ctx.path == "/" || ctx.path.size == 0) {
            resolveStaticAssetPath(config.root, config.index)
        } else {
            resolveStaticAssetPath(config.root, ctx.path)
        }
        if (let None <- filePathOpt) {
            ctx.next()
            return
        }
        let filePath = match (filePathOpt) {
            case Some(path) => path
            case None => ""
        }

        if (config.maxAge > 0) {
            ctx.setHeader("Cache-Control", "public, max-age=${config.maxAge}")
        }

        try {
            match (selectPrecompressedStaticAsset(ctx, filePath, config)) {
                case Some((encodedPath, encoding)) =>
                    ctx.sendPrecompressedFile(encodedPath, filePath, encoding)
                case None => ctx.sendFile(filePath)
            }
        } catch (_: Exception) {
            ctx.next()
        }
    }
}

func selectPrecompressedStaticAsset(
    ctx: Ctx,
    filePath: String,
    config: StaticFileConfig
): ?(String, String) {
    if (!config.precompressed || (ctx.header("range") ?? "").size > 0) {
        return None
    }
    let accepted = ctx.header("accept-encoding") ?? ""
    let brQuality = staticEncodingQuality(accepted, "br")
    let zstdQuality = staticEncodingQuality(accepted, "zstd")
    let brPath = filePath + config.brotliSuffix
    let zstdPath = filePath + config.zstdSuffix
    if (brQuality >= zstdQuality && brQuality > 0 && exists(brPath)) {
        return Some((brPath, "br"))
    }
    if (zstdQuality > 0 && exists(zstdPath)) {
        return Some((zstdPath, "zstd"))
    }
    if (brQuality > 0 && exists(brPath)) {
        return Some((brPath, "br"))
    }
    None
}

func staticEncodingQuality(raw: String, target: String): Int64 {
    var exact: Int64 = -1
    var wildcard: Int64 = -1
    for (part in raw.trimAscii().toAsciiLower().split(",")) {
        let tokens = part.trimAscii().split(";")
        if (tokens.size == 0) {
            continue
        }
        var quality: Int64 = 1000
        var i: Int64 = 1
        while (i < tokens.size) {
            let kv = tokens[i].trimAscii().split("=", 2)
            if (kv.size == 2 && kv[0].trimAscii() == "q") {
                quality = parseQValue(kv[1])
            }
            i += 1
        }
        let name = tokens[0].trimAscii()
        if (name == target) {
            exact = quality
        } else if (name == "*") {
            wildcard = quality
        }
    }
    if (exact >= 0) { exact } else { wildcard }
}
