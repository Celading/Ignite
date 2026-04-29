package ignite

import std.collection.{ArrayList, HashMap}

enum AppDispatchPlanKind {
    | Matched
    | NotFound
    | MethodNotAllowed
}

class AppDispatchPlan {
    let requestMethod: String
    let requestPath: String
    let kind: AppDispatchPlanKind
    let params: HashMap<String, String>
    let handlers: ArrayList<Handler>
    let route: ?Route
    let allowedMethods: ArrayList<String>

    init(
        requestMethod: String,
        requestPath: String,
        kind: AppDispatchPlanKind,
        params!: HashMap<String, String>,
        handlers!: ArrayList<Handler>,
        route!: ?Route,
        allowedMethods!: ArrayList<String>
    ) {
        this.requestMethod = requestMethod
        this.requestPath = requestPath
        this.kind = kind
        this.params = params
        this.handlers = handlers
        this.route = route
        this.allowedMethods = allowedMethods
    }

    func matched(): Bool {
        match (kind) {
            case AppDispatchPlanKind.Matched => true
            case _ => false
        }
    }

    func kindName(): String {
        dispatchPlanKindName(kind)
    }
}

func resolveAppDispatchPlan(app: App, requestMethod: String, requestPath: String): AppDispatchPlan {
    let result = app.router.matchRoute(requestMethod, requestPath)
    if (result.matched) {
        return AppDispatchPlan(
            requestMethod,
            requestPath,
            AppDispatchPlanKind.Matched,
            params: copyDispatchPlanParams(result.params),
            handlers: copyDispatchPlanHandlers(result.handlers),
            route: result.route,
            allowedMethods: copyDispatchPlanMethods(result.allowedMethods)
        )
    }

    let kind = if (result.allowedMethods.size > 0) {
        AppDispatchPlanKind.MethodNotAllowed
    } else {
        AppDispatchPlanKind.NotFound
    }
    let fallback = app.methodSemanticsHandler(requestMethod, requestPath, result.allowedMethods)
    return AppDispatchPlan(
        requestMethod,
        requestPath,
        kind,
        params: HashMap<String, String>(),
        handlers: app.router.buildGlobalMiddlewareChain(fallback),
        route: None,
        allowedMethods: copyDispatchPlanMethods(result.allowedMethods)
    )
}

func copyDispatchPlanParams(params: HashMap<String, String>): HashMap<String, String> {
    let copied = HashMap<String, String>()
    for ((key, value) in params) {
        copied.add(key, value)
    }
    copied
}

func copyDispatchPlanHandlers(handlers: ArrayList<Handler>): ArrayList<Handler> {
    let copied = ArrayList<Handler>()
    for (handler in handlers) {
        copied.add(handler)
    }
    copied
}

func copyDispatchPlanMethods(methods: ArrayList<String>): ArrayList<String> {
    let copied = ArrayList<String>()
    for (method in methods) {
        copied.add(method)
    }
    copied
}

func dispatchPlanKindName(kind: AppDispatchPlanKind): String {
    match (kind) {
        case AppDispatchPlanKind.Matched => "matched"
        case AppDispatchPlanKind.NotFound => "not-found"
        case AppDispatchPlanKind.MethodNotAllowed => "method-not-allowed"
    }
}
