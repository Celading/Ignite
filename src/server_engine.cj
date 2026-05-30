package ignite

import std.fs.{File, OpenMode}
import std.collection.ArrayList
import stdx.net.http.{ServerBuilder, Server, HttpRequestDistributor, HttpRequestHandler, HttpContext}
import ignite.api2

public class ServerTransportTouchpoint {
    public let candidateOrder: String
    public let blockedCandidates: String
    public let selectedBackend: String
    public let selectedReason: String
    public let providerId: String
    public let publicPath: String
    public let riskLevel: String
    public let tlsEnabled: Bool
    public let fallbackReason: String

    public init(
        candidateOrder: String,
        blockedCandidates: String,
        selectedBackend: String,
        selectedReason: String,
        providerId: String,
        publicPath: String,
        riskLevel: String,
        tlsEnabled: Bool,
        fallbackReason: String
    ) {
        this.candidateOrder = candidateOrder
        this.blockedCandidates = blockedCandidates
        this.selectedBackend = selectedBackend
        this.selectedReason = selectedReason
        this.providerId = providerId
        this.publicPath = publicPath
        this.riskLevel = riskLevel
        this.tlsEnabled = tlsEnabled
        this.fallbackReason = fallbackReason
    }

    public func toJson(): String {
        #"{"candidateOrder":"# + "\"" + serverEscapeJson(candidateOrder) + "\"" +
        #","blockedCandidates":"# + "\"" + serverEscapeJson(blockedCandidates) + "\"" +
        #","selectedBackend":"# + "\"" + serverEscapeJson(selectedBackend) + "\"" +
        #","selectedReason":"# + "\"" + serverEscapeJson(selectedReason) + "\"" +
        #","providerId":"# + "\"" + serverEscapeJson(providerId) + "\"" +
        #","publicPath":"# + "\"" + serverEscapeJson(publicPath) + "\"" +
        #","riskLevel":"# + "\"" + serverEscapeJson(riskLevel) + "\"" +
        #","tlsEnabled":"# + serverBoolToJson(tlsEnabled) +
        #","fallbackReason":"# + "\"" + serverEscapeJson(fallbackReason) + "\"" +
        #"}"#
    }
}

public class ServerStartupObserveEvent {
    public let phase: String
    public let addr: String
    public let port: UInt16
    public let scheme: String
    public let tlsEnabled: Bool
    public let transportTouchpoint: ?ServerTransportTouchpoint
    public let failureStage: String
    public let failureCode: String
    public let igniteErrorCode: String
    public let failureSource: String
    public let hint: String
    public let message: String

    public init(
        phase: String,
        addr: String,
        port: UInt16,
        scheme: String,
        tlsEnabled: Bool,
        transportTouchpoint!: ?ServerTransportTouchpoint = None,
        failureStage!: String = "-",
        failureCode!: String = "-",
        igniteErrorCode!: String = "-",
        failureSource!: String = "-",
        hint!: String = "-",
        message!: String = ""
    ) {
        this.phase = phase
        this.addr = addr
        this.port = port
        this.scheme = scheme
        this.tlsEnabled = tlsEnabled
        this.transportTouchpoint = transportTouchpoint
        this.failureStage = failureStage
        this.failureCode = failureCode
        this.igniteErrorCode = igniteErrorCode
        this.failureSource = failureSource
        this.hint = hint
        this.message = message
    }

    public func toJson(): String {
        let touchpointJson = if (let Some(touchpoint) <- transportTouchpoint) {
            touchpoint.toJson()
        } else {
            "null"
        }
        #"{"phase":"# + "\"" + serverEscapeJson(phase) + "\"" +
        #","addr":"# + "\"" + serverEscapeJson(addr) + "\"" +
        #","port":"# + "${port}" +
        #","scheme":"# + "\"" + serverEscapeJson(scheme) + "\"" +
        #","tlsEnabled":"# + serverBoolToJson(tlsEnabled) +
        #","failureStage":"# + "\"" + serverEscapeJson(failureStage) + "\"" +
        #","failureCode":"# + "\"" + serverEscapeJson(failureCode) + "\"" +
        #","igniteErrorCode":"# + "\"" + serverEscapeJson(igniteErrorCode) + "\"" +
        #","failureSource":"# + "\"" + serverEscapeJson(failureSource) + "\"" +
        #","hint":"# + "\"" + serverEscapeJson(hint) + "\"" +
        #","message":"# + "\"" + serverEscapeJson(message) + "\"" +
        #","transportTouchpoint":"# + touchpointJson +
        #"}"#
    }
}

public type ServerStartupObserveHook = (ServerStartupObserveEvent) -> Unit
public type ServerPreparedTlsMaterialLoader = () -> api2.PreparedHttpServerTlsMaterial

public class ServerEngineListenOption {
    public let addr: String
    public let port: UInt16
    public let readTimeout: Duration
    public let writeTimeout: Duration
    public let readHeaderTimeout: Duration
    public let maxRequestBodySize: Int64
    public let tlsCertFile: String
    public let tlsKeyFile: String
    public let enableTlsPrecheck: Bool
    public let preparedTlsMaterialLoader: ?ServerPreparedTlsMaterialLoader
    public let transportTouchpoint: ?ServerTransportTouchpoint

    public init(
        addr: String,
        port: UInt16,
        readTimeout: Duration,
        writeTimeout: Duration,
        readHeaderTimeout: Duration,
        maxRequestBodySize: Int64,
        tlsCertFile: String,
        tlsKeyFile: String,
        enableTlsPrecheck: Bool,
        preparedTlsMaterialLoader!: ?ServerPreparedTlsMaterialLoader = None,
        transportTouchpoint!: ?ServerTransportTouchpoint = None
    ) {
        this.addr = addr
        this.port = port
        this.readTimeout = readTimeout
        this.writeTimeout = writeTimeout
        this.readHeaderTimeout = readHeaderTimeout
        this.maxRequestBodySize = maxRequestBodySize
        this.tlsCertFile = tlsCertFile
        this.tlsKeyFile = tlsKeyFile
        this.enableTlsPrecheck = enableTlsPrecheck
        this.preparedTlsMaterialLoader = preparedTlsMaterialLoader
        this.transportTouchpoint = transportTouchpoint
    }

    public func loadPreparedTlsMaterial(): api2.PreparedHttpServerTlsMaterial {
        if (let Some(loader) <- preparedTlsMaterialLoader) {
            return loader()
        }
        throw Exception("prepared TLS material loader is unavailable")
    }
}

public interface ServerEngine {
    func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?(() -> Unit)
    ): Unit

    func shutdown(): Unit
}

public interface ServerEngineTransportTouchpointOverride {
    func overrideTransportTouchpoint(
        addr: String,
        port: UInt16,
        tlsEnabled: Bool,
        baseTouchpoint: ServerTransportTouchpoint
    ): ServerTransportTouchpoint
}

public class SocketServerEngineShellException <: Exception {
    public init(message: String) {
        super(message)
    }
}

public class SocketServerEngineShell <: ServerEngine & ServerEngineTransportTouchpointOverride {
    public init() {}

    public override func overrideTransportTouchpoint(
        addr: String,
        port: UInt16,
        tlsEnabled: Bool,
        baseTouchpoint: ServerTransportTouchpoint
    ): ServerTransportTouchpoint {
        let _ = addr
        let _ = port
        let _ = tlsEnabled
        buildServerEngineOverrideTouchpoint(
            baseTouchpoint,
            "ignite-socket-server-shell",
            "opt_in_engine_shell_selected",
            "opt-in-engine-shell",
            "experimental",
            "cleartext_h1_first_runnable"
        )
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?(() -> Unit)
    ): Unit {
        runSocketServerEngineShellListen(option, app, onReady)
    }

    public override func shutdown(): Unit {}
}

public class StdxServerEngine <: ServerEngine {
    var _server: ?Server = None

    public init() {}

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?(() -> Unit)
    ): Unit {
        let distributor = StdxServerEngineDistributor(app)
        let builder = ServerBuilder()
            .addr(option.addr)
            .port(option.port)
            .distributor(distributor)
            .readTimeout(option.readTimeout)
            .writeTimeout(option.writeTimeout)
            .readHeaderTimeout(option.readHeaderTimeout)
            .maxRequestBodySize(option.maxRequestBodySize)

        let hasTls = option.tlsCertFile.size > 0 && option.tlsKeyFile.size > 0
        if (hasTls) {
            let preparedMaterial = option.loadPreparedTlsMaterial()
            let tlsCfg = api2.buildStdxTlsServerConfigFromPreparedMaterial(
                preparedMaterial
            )
            let _ = builder.tlsConfig(tlsCfg)
        }

        let server = builder
            .afterBind({ =>
                if (let Some(cb) <- onReady) {
                    cb()
                }
            })
            .build()

        _server = server
        server.serve()
    }

    public override func shutdown(): Unit {
        if (let Some(s) <- _server) {
            s.closeGracefully()
            _server = None
        }
    }
}

class StdxServerEngineLambdaHandler <: HttpRequestHandler {
    let fn: (HttpContext) -> Unit

    init(fn: (HttpContext) -> Unit) {
        this.fn = fn
    }

    public func handle(ctx: HttpContext): Unit {
        fn(ctx)
    }
}

class StdxServerEngineAppMainHandler <: HttpRequestHandler {
    let app: App

    init(app: App) {
        this.app = app
    }

    public func handle(ctx: HttpContext): Unit {
        app.handleRequest(wrapCurrentRequestCarrier(ctx))
    }
}

class StdxServerEngineDistributor <: HttpRequestDistributor {
    let mainHandler: StdxServerEngineAppMainHandler

    init(app: App) {
        this.mainHandler = StdxServerEngineAppMainHandler(app)
    }

    private func usePathForLint(path: String): Unit {
        if (path.size >= 0) { }
    }

    private func useHandlerForLint(handler: HttpRequestHandler): Unit {
        let _ = handler
    }

    public func register(path: String, handler: HttpRequestHandler): Unit {
        usePathForLint(path)
        useHandlerForLint(handler)
    }

    public func registerRoute(path: String, handler: (HttpContext) -> Unit): Unit {
        usePathForLint(path)
        useHandlerForLint(StdxServerEngineLambdaHandler(handler))
    }

    public func distribute(path: String): HttpRequestHandler {
        usePathForLint(path)
        mainHandler
    }
}

func buildServerTransportTouchpoint(addr: String, port: UInt16, tlsEnabled: Bool): ServerTransportTouchpoint {
    let scheme = if (tlsEnabled) { "https" } else { "http" }
    let request = api2.BackendSelectionRequest(
        "server",
        scheme,
        false,
        false,
        false,
        "",
        false,
        0,
        "sni=" + normalizeServerTouchpointHost(addr, port)
    )
    let decision = api2.selectBackend(request)
    let tlsPlan = api2.buildTlsAttachPlan(
        request,
        decision,
        normalizeServerTouchpointHost(addr, port)
    )
    ServerTransportTouchpoint(
        joinServerTouchpointFields(decision.candidateOrder),
        joinServerTouchpointFields(decision.blockedCandidates),
        normalizeServerBackendId(decision.selectedBackend),
        decision.selectedReason,
        normalizeServerProviderId(tlsPlan.providerId, tlsEnabled),
        decision.publicPath,
        decision.riskLevel,
        tlsPlan.tlsEnabled,
        tlsPlan.fallbackReason
    )
}

func resolveServerTransportTouchpoint(
    engine: ServerEngine,
    addr: String,
    port: UInt16,
    tlsEnabled: Bool
): ServerTransportTouchpoint {
    let baseTouchpoint = buildServerTransportTouchpoint(addr, port, tlsEnabled)
    if (let Some(provider) <- (engine as ServerEngineTransportTouchpointOverride)) {
        return provider.overrideTransportTouchpoint(
            addr,
            port,
            tlsEnabled,
            baseTouchpoint
        )
    }
    baseTouchpoint
}

func buildServerEngineOverrideTouchpoint(
    baseTouchpoint: ServerTransportTouchpoint,
    selectedBackend: String,
    selectedReason: String,
    publicPath: String,
    riskLevel: String,
    fallbackReason: String
): ServerTransportTouchpoint {
    let candidateOrder = prependServerTouchpointCandidate(
        baseTouchpoint.candidateOrder,
        selectedBackend
    )
    ServerTransportTouchpoint(
        candidateOrder,
        baseTouchpoint.blockedCandidates,
        selectedBackend,
        selectedReason,
        baseTouchpoint.providerId,
        publicPath,
        riskLevel,
        baseTouchpoint.tlsEnabled,
        fallbackReason
    )
}

func normalizeServerTouchpointHost(addr: String, port: UInt16): String {
    let trimmed = addr.trimAscii()
    if (trimmed == "0.0.0.0" || trimmed == "::" || trimmed == "[::]") {
        return "127.0.0.1:${port}"
    }
    "${trimmed}:${port}"
}

func joinServerTouchpointFields(values: Array<String>): String {
    if (values.size == 0) {
        return "-"
    }
    var out = ""
    var first = true
    for (value in values) {
        if (!first) {
            out += ","
        }
        first = false
        out += value
    }
    out
}

func prependServerTouchpointCandidate(existing: String, candidate: String): String {
    if (candidate.size == 0) {
        return existing
    }
    if (existing.size == 0 || existing == "-") {
        return candidate
    }
    candidate + "," + existing
}

func normalizeServerBackendId(raw: String): String {
    if (raw == "stdx-default") {
        return "stdx-http-server"
    }
    if (raw.size == 0) {
        return "-"
    }
    raw
}

func normalizeServerProviderId(raw: String, tlsEnabled: Bool): String {
    if (!tlsEnabled || raw.size == 0) {
        return "-"
    }
    if (raw == "stdx") {
        return "tls:stdx-default"
    }
    if (raw == "jinguissl") {
        return "tls:jinguissl"
    }
    "tls:" + raw
}

func serverBoolToJson(value: Bool): String {
    if (value) { "true" } else { "false" }
}

func serverEscapeJson(value: String): String {
    escapeJsonText(value)
}
