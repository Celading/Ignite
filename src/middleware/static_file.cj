package ignite.middleware

import ignite.{Handler, Ctx, resolveStaticAssetPath, selectPrecompressedStaticAssetPath}

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
            var selected: ?(String, String) = None
            if (config.precompressed) {
                selected = selectPrecompressedStaticAssetPath(
                    ctx.header("accept-encoding") ?? "",
                    ctx.header("range") ?? "",
                    filePath,
                    brotliSuffix: config.brotliSuffix,
                    zstdSuffix: config.zstdSuffix
                )
            }
            match (selected) {
                case Some((encodedPath, encoding)) =>
                    ctx.sendPrecompressedFile(encodedPath, filePath, encoding)
                case None => ctx.sendFile(filePath)
            }
        } catch (_: Exception) {
            ctx.next()
        }
    }
}
