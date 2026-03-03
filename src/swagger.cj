package ignite

import std.collection.{ArrayList, HashMap}
import std.unicode.*

public class RouteOption {
    public var summary: String = ""
    public var description: String = ""
    public var tags: ArrayList<String> = ArrayList<String>()
    public var deprecated: Bool = false
    public var operationId: String = ""
    public var consumes: ArrayList<String> = ArrayList<String>()
    public var produces: ArrayList<String> = ArrayList<String>()
    public var parameters: ArrayList<ParamSpec> = ArrayList<ParamSpec>()
    public var responses: ArrayList<ResponseSpec> = ArrayList<ResponseSpec>()
    public var security: ArrayList<String> = ArrayList<String>()
    public var hidden: Bool = false
    public var paramValidations: HashMap<String, String> = HashMap<String, String>()

    public init() {}

    public func withParamValidation(name: String, pattern: String): RouteOption {
        paramValidations.add(name, pattern)
        this
    }

    public func withSummary(s: String): RouteOption {
        this.summary = s
        this
    }

    public func withDescription(d: String): RouteOption {
        this.description = d
        this
    }

    public func withTag(t: String): RouteOption {
        this.tags.add(t)
        this
    }

    public func withTags(ts: Array<String>): RouteOption {
        for (t in ts) {
            this.tags.add(t)
        }
        this
    }

    public func withDeprecated(d: Bool): RouteOption {
        this.deprecated = d
        this
    }

    public func withOperationId(id: String): RouteOption {
        this.operationId = id
        this
    }

    public func withParam(p: ParamSpec): RouteOption {
        this.parameters.add(p)
        this
    }

    public func withResponse(r: ResponseSpec): RouteOption {
        this.responses.add(r)
        this
    }

    public func withSecurity(s: String): RouteOption {
        this.security.add(s)
        this
    }

    public func asHidden(): RouteOption {
        this.hidden = true
        this
    }
}

public enum ParamLocation {
    | Query
    | Header
    | Path
    | Cookie
}

public class ParamSpec {
    public var name: String
    public var location: ParamLocation
    public var description: String = ""
    public var required: Bool = false
    public var dataType: String = "string"
    public var example: String = ""

    public init(name: String, location: ParamLocation) {
        this.name = name
        this.location = location
    }

    public init(
        name: String,
        location: ParamLocation,
        description!: String = "",
        required!: Bool = false,
        dataType!: String = "string",
        example!: String = ""
    ) {
        this.name = name
        this.location = location
        this.description = description
        this.required = required
        this.dataType = dataType
        this.example = example
    }
}

public class ResponseSpec {
    public var statusCode: UInt16
    public var description: String = ""
    public var contentType: String = ""
    public var schema: String = ""

    public init(statusCode: UInt16) {
        this.statusCode = statusCode
    }

    public init(statusCode: UInt16, description!: String = "", contentType!: String = "", schema!: String = "") {
        this.statusCode = statusCode
        this.description = description
        this.contentType = contentType
        this.schema = schema
    }
}

public class SwaggerInfo {
    public var title: String = "Ignite API"
    public var description: String = ""
    public var version: String = "1.0.0"
    public var host: String = "localhost"
    public var basePath: String = "/"
    public var schemes: ArrayList<String> = ArrayList<String>()

    public init(title!: String = "Ignite API", description!: String = "", version!: String = "1.0.0") {
        this.title = title
        this.description = description
        this.version = version
        this.schemes.add("http")
    }
}

public class SwaggerGenerator {
    let info: SwaggerInfo
    let routes: ArrayList<Route>

    public init(info: SwaggerInfo, routes: ArrayList<Route>) {
        this.info = info
        this.routes = routes
    }

    public func generate(): String {
        var sb = StringBuilder()
        sb.append("{\n")
        sb.append("  \"openapi\": \"3.0.0\",\n")
        sb.append("  \"info\": {\n")
        sb.append("    \"title\": \"${info.title}\",\n")
        sb.append("    \"description\": \"${info.description}\",\n")
        sb.append("    \"version\": \"${info.version}\"\n")
        sb.append("  },\n")
        sb.append("  \"paths\": {\n")

        let pathMap = HashMap<String, ArrayList<Route>>()
        for (route in routes) {
            if (let Some(opt) <- route.option) {
                if (opt.hidden) {
                    continue
                }
            }
            let swaggerPath = convertPath(route.path)
            if (!pathMap.contains(swaggerPath)) {
                pathMap.add(swaggerPath, ArrayList<Route>())
            }
            if (let Some(list) <- pathMap.get(swaggerPath)) {
                list.add(route)
            }
        }

        var pathIdx: Int64 = 0
        let pathCount = pathMap.size
        for ((path, pathRoutes) in pathMap) {
            sb.append("    \"${path}\": {\n")
            var routeIdx: Int64 = 0
            let routeCount = pathRoutes.size
            for (route in pathRoutes) {
                let methodLower = route.method.toLower()
                sb.append("      \"${methodLower}\": {\n")

                if (let Some(opt) <- route.option) {
                    if (opt.summary.size > 0) {
                        sb.append("        \"summary\": \"${opt.summary}\",\n")
                    }
                    if (opt.description.size > 0) {
                        sb.append("        \"description\": \"${opt.description}\",\n")
                    }
                    if (opt.tags.size > 0) {
                        sb.append("        \"tags\": [")
                        for (i in 0..opt.tags.size) {
                            sb.append("\"${opt.tags[i]}\"")
                            if (i < opt.tags.size - 1) {
                                sb.append(", ")
                            }
                        }
                        sb.append("],\n")
                    }
                    if (opt.operationId.size > 0) {
                        sb.append("        \"operationId\": \"${opt.operationId}\",\n")
                    }
                    if (opt.deprecated) {
                        sb.append("        \"deprecated\": true,\n")
                    }
                    if (opt.parameters.size > 0) {
                        sb.append("        \"parameters\": [\n")
                        for (j in 0..opt.parameters.size) {
                            let p = opt.parameters[j]
                            sb.append("          {\n")
                            sb.append("            \"name\": \"${p.name}\",\n")
                            sb.append("            \"in\": \"${paramLocationStr(p.location)}\",\n")
                            sb.append("            \"description\": \"${p.description}\",\n")
                            sb.append("            \"required\": ${p.required},\n")
                            sb.append("            \"schema\": { \"type\": \"${p.dataType}\" }\n")
                            sb.append("          }")
                            if (j < opt.parameters.size - 1) {
                                sb.append(",")
                            }
                            sb.append("\n")
                        }
                        sb.append("        ],\n")
                    }
                    if (opt.responses.size > 0) {
                        sb.append("        \"responses\": {\n")
                        for (k in 0..opt.responses.size) {
                            let r = opt.responses[k]
                            sb.append("          \"${r.statusCode}\": {\n")
                            sb.append("            \"description\": \"${r.description}\"\n")
                            sb.append("          }")
                            if (k < opt.responses.size - 1) {
                                sb.append(",")
                            }
                            sb.append("\n")
                        }
                        sb.append("        }\n")
                    } else {
                        sb.append("        \"responses\": { \"200\": { \"description\": \"OK\" } }\n")
                    }
                } else {
                    sb.append("        \"responses\": { \"200\": { \"description\": \"OK\" } }\n")
                }

                sb.append("      }")
                routeIdx += 1
                if (routeIdx < routeCount) {
                    sb.append(",")
                }
                sb.append("\n")
            }
            sb.append("    }")
            pathIdx += 1
            if (pathIdx < pathCount) {
                sb.append(",")
            }
            sb.append("\n")
        }

        sb.append("  }\n")
        sb.append("}")
        sb.toString()
    }

    func convertPath(path: String): String {
        var result = StringBuilder()
        var i: Int64 = 0
        let chars = path.toRuneArray()
        while (i < chars.size) {
            if (chars[i] == r':') {
                result.append(r'{')
                i += 1
                while (i < chars.size && chars[i] != r'/') {
                    result.append(chars[i])
                    i += 1
                }
                result.append(r'}')
            } else {
                result.append(chars[i])
                i += 1
            }
        }
        result.toString()
    }

    func paramLocationStr(loc: ParamLocation): String {
        match (loc) {
            case Query => "query"
            case Header => "header"
            case Path => "path"
            case Cookie => "cookie"
        }
    }
}

class StringBuilder {
    var data: ArrayList<String> = ArrayList<String>()

    func append(s: String): Unit {
        data.add(s)
    }

    func append(r: Rune): Unit {
        data.add(r.toString())
    }

    func toString(): String {
        var result = ""
        for (s in data) {
            result += s
        }
        result
    }
}
