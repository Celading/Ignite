package ignite

import std.collection.{ArrayList, HashMap}
import std.unicode.*

enum NodeType {
    | Static
    | Param
    | CatchAll
}

class TrieNode {
    var nodeType: NodeType = Static
    var segment: String = ""
    var paramName: String = ""
    var children: ArrayList<TrieNode> = ArrayList<TrieNode>()
    var paramChild: ?TrieNode = None
    var catchAllChild: ?TrieNode = None
    var handlersMap: HashMap<String, ArrayList<Handler>> = HashMap<String, ArrayList<Handler>>()
    var routeMap: HashMap<String, Route> = HashMap<String, Route>()
    var middlewares: ArrayList<Handler> = ArrayList<Handler>()

    init() {}

    init(nodeType: NodeType, segment: String) {
        this.nodeType = nodeType
        this.segment = segment
    }

    func addHandler(method: String, handlers: ArrayList<Handler>, route: Route): Unit {
        handlersMap.add(method, handlers)
        routeMap.add(method, route)
    }

    func getHandler(method: String): ?(ArrayList<Handler>, Route) {
        match (handlersMap.get(method)) {
            case Some(h) =>
                match (routeMap.get(method)) {
                    case Some(r) => Some((h, r))
                    case None => None
                }
            case None => None
        }
    }

    func findStaticChild(seg: String): ?TrieNode {
        for (child in children) {
            if (child.segment == seg) {
                return child
            }
        }
        None
    }
}

public class Router {
    let root: TrieNode = TrieNode()
    let config: Config
    let allRoutes: ArrayList<Route> = ArrayList<Route>()
    let globalMiddlewares: ArrayList<Handler> = ArrayList<Handler>()

    public init(config: Config) {
        this.config = config
    }

    public func addRoute(method: String, path: String, handlers: ArrayList<Handler>, option!: ?RouteOption = None): Route {
        let normalizedPath = normalizePath(path)
        let segments = splitPath(normalizedPath)
        var current = root

        for (seg in segments) {
            if (seg.size > 0 && seg.toRuneArray()[0] == r':') {
                let runes = seg.toRuneArray()
                var paramName = ""
                for (i in 1..runes.size) {
                    paramName += runes[i].toString()
                }
                match (current.paramChild) {
                    case Some(child) => current = child
                    case None =>
                        let child = TrieNode(Param, seg)
                        child.paramName = paramName
                        current.paramChild = child
                        current = child
                }
            } else if (seg == "*") {
                match (current.catchAllChild) {
                    case Some(child) => current = child
                    case None =>
                        let child = TrieNode(CatchAll, seg)
                        child.paramName = "*"
                        current.catchAllChild = child
                        current = child
                }
            } else {
                match (current.findStaticChild(seg)) {
                    case Some(child) => current = child
                    case None =>
                        let child = TrieNode(Static, seg)
                        current.children.add(child)
                        current = child
                }
            }
        }

        let route = Route(method, normalizedPath, handlers)
        if (let Some(opt) <- option) {
            route.option = opt
        }
        current.addHandler(method, handlers, route)
        allRoutes.add(route)
        route
    }

    public func matchRoute(method: String, path: String): MatchResult {
        let normalizedPath = normalizePath(path)
        let segments = splitPath(normalizedPath)
        let params = HashMap<String, String>()
        let result = matchNode(root, segments, 0, method, params)
        result
    }

    func matchNode(
        node: TrieNode,
        segments: ArrayList<String>,
        index: Int64,
        method: String,
        params: HashMap<String, String>
    ): MatchResult {
        if (index >= segments.size) {
            match (node.getHandler(method)) {
                case Some((handlers, route)) =>
                    let allHandlers = buildHandlerChain(handlers)
                    return MatchResult(
                        matched: true,
                        params: params,
                        handlers: allHandlers,
                        route: route
                    )
                case None => return MatchResult.notFound()
            }
        }

        let seg = segments[index]

        for (child in node.children) {
            if (matchSegment(child.segment, seg)) {
                let result = matchNode(child, segments, index + 1, method, params)
                if (result.matched) {
                    return result
                }
            }
        }

        if (let Some(paramChild) <- node.paramChild) {
            params.add(paramChild.paramName, seg)
            let result = matchNode(paramChild, segments, index + 1, method, params)
            if (result.matched) {
                return result
            }
            params.remove(paramChild.paramName)

        }

        if (let Some(catchAllChild) <- node.catchAllChild) {
            var remaining = ""
            for (i in index..segments.size) {
                if (i > index) {
                    remaining += "/"
                }
                remaining += segments[i]
            }
            params.add("*", remaining)
            match (catchAllChild.getHandler(method)) {
                case Some((handlers, route)) =>
                    let allHandlers = buildHandlerChain(handlers)
                    return MatchResult(
                        matched: true,
                        params: params,
                        handlers: allHandlers,
                        route: route
                    )
                case None => return MatchResult.notFound()
            }
        }

        MatchResult.notFound()
    }

    func buildHandlerChain(routeHandlers: ArrayList<Handler>): ArrayList<Handler> {
        let chain = ArrayList<Handler>()
        for (mw in globalMiddlewares) {
            chain.add(mw)
        }
        for (h in routeHandlers) {
            chain.add(h)
        }
        chain
    }

    public func addGlobalMiddleware(handler: Handler): Unit {
        globalMiddlewares.add(handler)
    }

    func matchSegment(pattern: String, actual: String): Bool {
        if (config.caseSensitive) {
            pattern == actual
        } else {
            pattern.toLower() == actual.toLower()
        }
    }

    func normalizePath(path: String): String {
        var p = path
        if (p.size == 0 || p.toRuneArray()[0] != r'/') {
            p = "/" + p
        }
        if (!config.strictRouting && p.size > 1) {
            let runes = p.toRuneArray()
            if (runes[runes.size - 1] == r'/') {
                var result = ""
                for (i in 0..runes.size - 1) {
                    result += runes[i].toString()
                }
                p = result
            }
        }
        p
    }

    func splitPath(path: String): ArrayList<String> {
        let segments = ArrayList<String>()
        let chars = path.toRuneArray()
        var current = ""
        var i: Int64 = 0
        if (chars.size > 0 && chars[0] == r'/') {
            i = 1
        }
        while (i < chars.size) {
            if (chars[i] == r'/') {
                if (current.size > 0) {
                    segments.add(current)
                    current = ""
                }
            } else {
                current += chars[i].toString()
            }
            i += 1
        }
        if (current.size > 0) {
            segments.add(current)
        }
        segments
    }

    public func getRoutes(): ArrayList<Route> {
        allRoutes
    }

    public func printRoutes(): Unit {
        println("┌───────────┬─────────────────────────────────┐")
        println("│  Method   │  Path                           │")
        println("├───────────┼─────────────────────────────────┤")
        for (route in allRoutes) {
            let m = padRight(route.method, 9)
            let p = padRight(route.path, 33)
            println("│ ${m} │ ${p} │")
        }
        println("└───────────┴─────────────────────────────────┘")
    }

    func padRight(s: String, width: Int64): String {
        var result = s
        while (result.size < width) {
            result += " "
        }
        result
    }
}
