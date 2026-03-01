package ignite

import std.collection.ArrayList

public class Group {
    let _app: App
    let _prefix: String
    let _middlewares: ArrayList<Handler> = ArrayList<Handler>()
    let _parent: ?Group

    public init(app: App, prefix: String, parent!: ?Group = None) {
        this._app = app
        this._prefix = prefix
        this._parent = parent
    }

    public prop prefix: String {
        get() { _prefix }
    }

    // ── HTTP method routes ──

    public func get(path: String, handler: Handler, option!: ?RouteOption = None): Group {
        addRoute("GET", path, handler, option)
    }

    public func post(path: String, handler: Handler, option!: ?RouteOption = None): Group {
        addRoute("POST", path, handler, option)
    }

    public func put(path: String, handler: Handler, option!: ?RouteOption = None): Group {
        addRoute("PUT", path, handler, option)
    }

    public func delete(path: String, handler: Handler, option!: ?RouteOption = None): Group {
        addRoute("DELETE", path, handler, option)
    }

    public func patch(path: String, handler: Handler, option!: ?RouteOption = None): Group {
        addRoute("PATCH", path, handler, option)
    }

    public func head(path: String, handler: Handler, option!: ?RouteOption = None): Group {
        addRoute("HEAD", path, handler, option)
    }

    public func options(path: String, handler: Handler, option!: ?RouteOption = None): Group {
        addRoute("OPTIONS", path, handler, option)
    }

    public func all(path: String, handler: Handler, option!: ?RouteOption = None): Group {
        let methods = ["GET", "POST", "PUT", "DELETE", "PATCH", "HEAD", "OPTIONS"]
        for (method in methods) {
            addRoute(method, path, handler, option)
        }
        this
    }

    // ── Middleware ──

    public func use(handler: Handler): Group {
        _middlewares.add(handler)
        this
    }

    public func use(handlers: Array<Handler>): Group {
        for (h in handlers) {
            _middlewares.add(h)
        }
        this
    }

    // ── Sub-groups ──

    public func group(prefix: String): Group {
        let fullPrefix = joinPath(_prefix, prefix)
        let g = Group(_app, fullPrefix, parent: this)
        for (mw in _middlewares) {
            g._middlewares.add(mw)
        }
        g
    }

    // ── Route registration helper ──

    func addRoute(method: String, path: String, handler: Handler, option: ?RouteOption): Group {
        let fullPath = joinPath(_prefix, path)
        let allHandlers = ArrayList<Handler>()
        collectMiddlewares(allHandlers)
        allHandlers.add(handler)
        _app.router.addRoute(method, fullPath, allHandlers, option: option)
        this
    }

    func collectMiddlewares(target: ArrayList<Handler>): Unit {
        if (let Some(p) <- _parent) {
            p.collectMiddlewares(target)
        }
        for (mw in _middlewares) {
            target.add(mw)
        }
    }

    func joinPath(prefix: String, path: String): String {
        if (prefix.size == 0) {
            return path
        }
        if (path.size == 0) {
            return prefix
        }
        let prefixRunes = prefix.toRuneArray()
        let pathRunes = path.toRuneArray()
        let prefixEndsSlash = prefixRunes[prefixRunes.size - 1] == r'/'
        let pathStartsSlash = pathRunes[0] == r'/'

        if (prefixEndsSlash && pathStartsSlash) {
            var result = prefix
            for (i in 1..pathRunes.size) {
                result += pathRunes[i].toString()
            }
            return result
        }
        if (!prefixEndsSlash && !pathStartsSlash) {
            return prefix + "/" + path
        }
        prefix + path
    }
}
