package ignite

import std.fs.{File, OpenMode}
import std.collection.ArrayList
import stdx.net.http.{ServerBuilder, Server, HttpRequestDistributor}
import ignite.api2
import lisi.transport as lisiTransport

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
        this.transportTouchpoint = transportTouchpoint
    }
}

public interface ServerEngine {
    func listen(
        option: ServerEngineListenOption,
        distributor: HttpRequestDistributor,
        onReady: ?(() -> Unit)
    ): Unit

    func shutdown(): Unit
}

public class StdxServerEngine <: ServerEngine {
    var _server: ?Server = None

    public init() {}

    public override func listen(
        option: ServerEngineListenOption,
        distributor: HttpRequestDistributor,
        onReady: ?(() -> Unit)
    ): Unit {
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
            let certPem = readFileStringForEngine(option.tlsCertFile)
            let keyPem = readFileStringForEngine(option.tlsKeyFile)
            let tlsCfg = api2.loadTlsServerConfigForHttp2(
                certPem,
                keyPem,
                enablePrecheck: option.enableTlsPrecheck
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

func readFileStringForEngine(path: String): String {
    let file = File(path, OpenMode.Read)
    let buf = ArrayList<UInt8>()
    let tmp = Array<UInt8>(4096, repeat: 0)
    while (true) {
        let n = file.read(tmp)
        if (n <= 0) { break }
        for (i in 0..n) {
            buf.add(tmp[i])
        }
    }
    file.close()
    String.fromUtf8(buf.toArray())
}

func buildServerTransportTouchpoint(addr: String, port: UInt16, tlsEnabled: Bool): ServerTransportTouchpoint {
    let scheme = if (tlsEnabled) { "https" } else { "http" }
    let request = lisiTransport.BackendSelectionRequest(
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
    let decision = lisiTransport.selectBackend(request)
    let tlsPlan = lisiTransport.buildTlsAttachPlan(
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
