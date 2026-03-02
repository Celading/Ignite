package ignite.middleware

import ignite.{Handler, Ctx}

public class RewriteConfig {
    public var rules: Array<(String, String)>

    public init(rules: Array<(String, String)>) {
        this.rules = rules
    }
}

public func rewriteMiddleware(config: RewriteConfig): Handler {
    { ctx: Ctx =>
        let path = ctx.path
        for ((from, to) in config.rules) {
            if (path == from) {
                ctx.setLocal("_rewrite_from", path)
                ctx.setLocal("_rewrite_to", to)
                break
            }
            if (strStartsWith(path, from)) {
                let rest = substringFrom(path, from.size)
                let newPath = to + rest
                ctx.setLocal("_rewrite_from", path)
                ctx.setLocal("_rewrite_to", newPath)
                break
            }
        }
        ctx.next()
    }
}
