package ignite

import std.fs.{File, OpenMode}
import std.collection.ArrayList
import std.io.InputStream
import std.net.TcpSocket
import stdx.net.http.{ServerBuilder, Server, HttpRequestDistributor, HttpRequestHandler, HttpContext, HttpHeaders, WebSocket}
import ignite.api2
import jinguissl.live.{
    ContractAcceptedTransportDescriptor,
    ContractHttpServerAttachPlan,
    ContractHttpServerAttachResult,
    ContractHttpServerAcceptedTransportSession,
    ContractTls13IncrementalServerReadyRuntime,
    ContractHttpServerAcceptedTransportTls13X25519Request,
    ContractHttpServerLibraryStartupRequest,
    ContractTlsRecordContentType,
    ContractHttpServerTlsConfigRequest,
    ContractTlsHttpNegotiationPolicy,
    contractAttachAcceptedTransportTls13X25519,
    contractAttachAcceptedTransportTls13X25519Request,
    contractCloseAcceptedTransportSession,
    contractPlanHttpServerAttachRequest
}

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
    public let jinguiAttachResultSnapshot: ?ServerJinguiHttpServerAttachResultSnapshot
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
        jinguiAttachResultSnapshot!: ?ServerJinguiHttpServerAttachResultSnapshot = None,
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
        this.jinguiAttachResultSnapshot = jinguiAttachResultSnapshot
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
        let jinguiAttachJson = if (
            let Some(snapshot) <- jinguiAttachResultSnapshot
        ) {
            snapshot.toJson()
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
        #","jinguiAttachResultSnapshot":"# + jinguiAttachJson +
        #"}"#
    }
}

public type ServerStartupObserveHook = (ServerStartupObserveEvent) -> Unit
public type ServerPreparedTlsMaterialLoader = () -> api2.PreparedHttpServerTlsMaterial
public type ServerJinguiAcceptedTransportSessionHook =
    (ServerJinguiAcceptedTransportSessionSnapshot) -> Unit
public type ServerJinguiAcceptedTransportAttachedSessionReadyHook =
    (ContractHttpServerAcceptedTransportSession) -> Unit
public type ServerNativeTlsH2RuntimeHook =
    (TcpSocket, ContractTls13IncrementalServerReadyRuntime, App, String) -> Unit
public type ServerJinguiAcceptedTransportAttachedSessionEncodedRequestRecordsBuilder =
    (ContractHttpServerAcceptedTransportSession) -> Array<Array<Byte>>
public type ServerJinguiAcceptedTransportAttachedSessionEncodedRequestWireFragmentsBuilder =
    (ContractHttpServerAcceptedTransportSession) -> Array<Array<Byte>>

public class ServerJinguiHttpServerAttachResultSnapshot {
    public let tlsVersion: String
    public let cipherSuite: String
    public let negotiatedAlpn: String
    public let requestedServerName: String
    public let acknowledgedServerName: Bool
    public let secureSessionReady: Bool
    public let attachSurface: String

    public init(
        tlsVersion: String,
        cipherSuite: String,
        negotiatedAlpn: String,
        requestedServerName: String,
        acknowledgedServerName: Bool,
        secureSessionReady: Bool,
        attachSurface: String
    ) {
        this.tlsVersion = tlsVersion
        this.cipherSuite = cipherSuite
        this.negotiatedAlpn = negotiatedAlpn
        this.requestedServerName = requestedServerName
        this.acknowledgedServerName = acknowledgedServerName
        this.secureSessionReady = secureSessionReady
        this.attachSurface = attachSurface
    }

    public func toJson(): String {
        #"{"tlsVersion":"# + "\"" + serverEscapeJson(tlsVersion) + "\"" +
        #","cipherSuite":"# + "\"" + serverEscapeJson(cipherSuite) + "\"" +
        #","negotiatedAlpn":"# + "\"" + serverEscapeJson(negotiatedAlpn) + "\"" +
        #","requestedServerName":"# + "\"" + serverEscapeJson(requestedServerName) + "\"" +
        #","acknowledgedServerName":"# + serverBoolToJson(acknowledgedServerName) +
        #","secureSessionReady":"# + serverBoolToJson(secureSessionReady) +
        #","attachSurface":"# + "\"" + serverEscapeJson(attachSurface) + "\"" +
        #"}"#
    }
}

public func buildServerJinguiHttpServerAttachResultSnapshot(
    attachResult: ContractHttpServerAttachResult
): ServerJinguiHttpServerAttachResultSnapshot {
    ServerJinguiHttpServerAttachResultSnapshot(
        attachResult.tlsVersion.toString(),
        attachResult.cipherSuite,
        attachResult.negotiatedAlpn,
        attachResult.requestedServerName,
        attachResult.acknowledgedServerName,
        attachResult.secureSessionReady,
        attachResult.attachSurface
    )
}

public class ServerJinguiAcceptedTransportDescriptorSnapshot {
    public let transportId: String
    public let transportKind: String
    public let localEndpoint: String
    public let remoteEndpoint: String

    public init(
        transportId: String,
        transportKind: String,
        localEndpoint: String,
        remoteEndpoint: String
    ) {
        this.transportId = transportId
        this.transportKind = transportKind
        this.localEndpoint = localEndpoint
        this.remoteEndpoint = remoteEndpoint
    }

    public func toJson(): String {
        #"{"transportId":"# + "\"" + serverEscapeJson(transportId) + "\"" +
        #","transportKind":"# + "\"" + serverEscapeJson(transportKind) + "\"" +
        #","localEndpoint":"# + "\"" + serverEscapeJson(localEndpoint) + "\"" +
        #","remoteEndpoint":"# + "\"" + serverEscapeJson(remoteEndpoint) + "\"" +
        #"}"#
    }
}

public func buildServerJinguiAcceptedTransportDescriptorSnapshot(
    transport: ContractAcceptedTransportDescriptor
): ServerJinguiAcceptedTransportDescriptorSnapshot {
    ServerJinguiAcceptedTransportDescriptorSnapshot(
        transport.transportId,
        transport.transportKind,
        transport.localEndpoint,
        transport.remoteEndpoint
    )
}

public class ServerJinguiAcceptedTransportSessionSnapshot {
    public let transport: ServerJinguiAcceptedTransportDescriptorSnapshot
    public let status: String
    public let jinguiAttachResultSnapshot: ServerJinguiHttpServerAttachResultSnapshot
    public let secureSessionReady: Bool
    public let recordChannelVersion: String
    public let closeReason: String

    public init(
        transport: ServerJinguiAcceptedTransportDescriptorSnapshot,
        status: String,
        jinguiAttachResultSnapshot: ServerJinguiHttpServerAttachResultSnapshot,
        secureSessionReady: Bool,
        recordChannelVersion: String,
        closeReason: String
    ) {
        this.transport = transport
        this.status = status
        this.jinguiAttachResultSnapshot = jinguiAttachResultSnapshot
        this.secureSessionReady = secureSessionReady
        this.recordChannelVersion = recordChannelVersion
        this.closeReason = closeReason
    }

    public func toJson(): String {
        #"{"transport":"# + transport.toJson() +
        #","status":"# + "\"" + serverEscapeJson(status) + "\"" +
        #","jinguiAttachResultSnapshot":"# + jinguiAttachResultSnapshot.toJson() +
        #","secureSessionReady":"# + serverBoolToJson(secureSessionReady) +
        #","recordChannelVersion":"# + "\"" + serverEscapeJson(recordChannelVersion) + "\"" +
        #","closeReason":"# + "\"" + serverEscapeJson(closeReason) + "\"" +
        #"}"#
    }
}

public func buildServerJinguiAcceptedTransportSessionSnapshot(
    session: ContractHttpServerAcceptedTransportSession
): ServerJinguiAcceptedTransportSessionSnapshot {
    ServerJinguiAcceptedTransportSessionSnapshot(
        buildServerJinguiAcceptedTransportDescriptorSnapshot(session.transport),
        session.status.toString(),
        buildServerJinguiHttpServerAttachResultSnapshot(session.result),
        session.secureSessionReady,
        session.recordChannel.version.toString(),
        session.closeReason
    )
}

func serverJinguiAcceptedTransportLogicalRequestPathOnly(target: String): String {
    if (let Some(queryIndex) <- target.indexOf("?")) {
        return target[..queryIndex]
    }
    target
}

func serverJinguiAcceptedTransportLogicalRequestQueryString(
    target: String
): String {
    if (let Some(queryIndex) <- target.indexOf("?")) {
        if (queryIndex + 1 >= target.size) {
            return ""
        }
        return target[queryIndex + 1..target.size]
    }
    ""
}

func serverJinguiAcceptedTransportReadQueryValue(
    queryString: String,
    key: String
): ?String {
    readDecodedUrlQueryValue(queryString, key)
}

func buildServerJinguiAcceptedTransportLogicalRequestHeadersWithAuthority(
    authority: String,
    headers: ?HttpHeaders
): HttpHeaders {
    let out = if (let Some(value) <- headers) {
        cloneServerEngineHeaders(value)
    } else {
        HttpHeaders()
    }
    if (authority.size > 0) {
        let existingHost = out.getFirst("host") ?? ""
        if (existingHost.size == 0) {
            out.add("host", authority)
        }
    }
    out
}

public class ServerJinguiAcceptedTransportH2PseudoHeaders {
    public let method: String
    public let path: String
    public let authority: String

    public init(
        method: String,
        path: String,
        authority!: String = ""
    ) {
        this.method = method
        this.path = path
        this.authority = authority
    }
}

public class ServerJinguiAcceptedTransportLogicalRequest {
    public let method: String
    public let path: String
    public let urlString: String
    public let versionString: String
    public let headers: HttpHeaders
    public let trailers: HttpHeaders
    public let bodyBytes: Array<UInt8>
    public let queryString: String
    public let streamId: Int64
    public let peerWindowUpdateFrames:
        Array<JinguiAcceptedTransportH2FrameWireSnapshot>

    public init(
        method: String,
        path: String,
        urlString!: String = "",
        versionString!: String = "h2",
        headers!: ?HttpHeaders = None,
        trailers!: ?HttpHeaders = None,
        bodyBytes!: Array<UInt8> = [],
        streamId!: Int64 = 1,
        peerWindowUpdateFrames!:
            Array<JinguiAcceptedTransportH2FrameWireSnapshot> = []
    ) {
        if (streamId <= 0) {
            throw Exception(
                "accepted transport logical request requires positive H2 streamId, got ${streamId}"
            )
        }
        let resolvedUrlString = if (urlString.size > 0) {
            urlString
        } else {
            path
        }
        let resolvedPathTarget = if (path.size > 0) {
            path
        } else {
            resolvedUrlString
        }
        this.method = method
        this.path =
            serverJinguiAcceptedTransportLogicalRequestPathOnly(
                resolvedPathTarget
            )
        this.urlString = resolvedUrlString
        this.versionString = if (versionString.size > 0) {
            versionString
        } else {
            "h2"
        }
        this.headers = if (let Some(value) <- headers) {
            cloneServerEngineHeaders(value)
        } else {
            HttpHeaders()
        }
        this.trailers = if (let Some(value) <- trailers) {
            cloneServerEngineHeaders(value)
        } else {
            HttpHeaders()
        }
        this.bodyBytes = cloneServerEngineUInt8Array(bodyBytes)
        this.queryString =
            serverJinguiAcceptedTransportLogicalRequestQueryString(
                resolvedUrlString
            )
        this.streamId = streamId
        this.peerWindowUpdateFrames =
            cloneJinguiAcceptedTransportH2FrameWireSnapshots(
                peerWindowUpdateFrames
            )
    }
}

public func buildServerJinguiAcceptedTransportLogicalRequestFromH2PseudoHeaders(
    pseudoHeaders: ServerJinguiAcceptedTransportH2PseudoHeaders,
    headers!: ?HttpHeaders = None,
    trailers!: ?HttpHeaders = None,
    bodyBytes!: Array<UInt8> = [],
    streamId!: Int64 = 1,
    peerWindowUpdateFrames!:
        Array<JinguiAcceptedTransportH2FrameWireSnapshot> = []
): ServerJinguiAcceptedTransportLogicalRequest {
    let projectedHeaders =
        buildServerJinguiAcceptedTransportLogicalRequestHeadersWithAuthority(
            pseudoHeaders.authority,
            headers
        )
    ServerJinguiAcceptedTransportLogicalRequest(
        pseudoHeaders.method,
        pseudoHeaders.path,
        urlString: pseudoHeaders.path,
        versionString: "h2",
        headers: Some(projectedHeaders),
        trailers: trailers,
        bodyBytes: bodyBytes,
        streamId: streamId,
        peerWindowUpdateFrames: peerWindowUpdateFrames
    )
}

func serverJinguiAcceptedTransportH2FieldNameIsPseudo(name: String): Bool {
    let runes = name.toRuneArray()
    runes.size > 0 && runes[0] == r':'
}

public func buildServerJinguiAcceptedTransportH2PseudoHeadersFromDecodedHeaderFields(
    headerFields: Array<JinguiAcceptedTransportH2DecodedHeaderField>
): ServerJinguiAcceptedTransportH2PseudoHeaders {
    var method = ""
    var path = ""
    var authority = ""
    for (field in headerFields) {
        if (field.name == ":method") {
            method = field.value
            continue
        }
        if (field.name == ":path") {
            path = field.value
            continue
        }
        if (field.name == ":authority") {
            authority = field.value
            continue
        }
        if (field.name == ":scheme") {
            continue
        }
        if (serverJinguiAcceptedTransportH2FieldNameIsPseudo(field.name)) {
            throw Exception(
                "H2 decoded header-field projection does not support pseudo header `${field.name}` in this bounded seam"
            )
        }
    }
    if (method.size == 0) {
        throw Exception(
            "H2 decoded header-field projection requires `:method` in this bounded seam"
        )
    }
    if (path.size == 0) {
        throw Exception(
            "H2 decoded header-field projection requires `:path` in this bounded seam"
        )
    }
    ServerJinguiAcceptedTransportH2PseudoHeaders(
        method,
        path,
        authority: authority
    )
}

public func buildServerJinguiAcceptedTransportLogicalRequestFromDecodedH2HeaderFields(
    headerFields: Array<JinguiAcceptedTransportH2DecodedHeaderField>,
    trailers!: ?HttpHeaders = None,
    bodyBytes!: Array<UInt8> = [],
    streamId!: Int64 = 1,
    peerWindowUpdateFrames!:
        Array<JinguiAcceptedTransportH2FrameWireSnapshot> = []
): ServerJinguiAcceptedTransportLogicalRequest {
    let pseudoHeaders =
        buildServerJinguiAcceptedTransportH2PseudoHeadersFromDecodedHeaderFields(
            headerFields
        )
    let headers = HttpHeaders()
    for (field in headerFields) {
        if (
            field.name == ":method" ||
            field.name == ":path" ||
            field.name == ":authority" ||
            field.name == ":scheme"
        ) {
            continue
        }
        if (serverJinguiAcceptedTransportH2FieldNameIsPseudo(field.name)) {
            throw Exception(
                "H2 decoded header-field logical-request projection does not support pseudo header `${field.name}` in this bounded seam"
            )
        }
        let normalizedName = field.name.trimAscii().toAsciiLower()
        if (shouldSkipJinguiAcceptedTransportH2RequestHeader(normalizedName)) {
            continue
        }
        headers.add(normalizedName, field.value)
    }
    buildServerJinguiAcceptedTransportLogicalRequestFromH2PseudoHeaders(
        pseudoHeaders,
        headers: Some(headers),
        trailers: trailers,
        bodyBytes: bodyBytes,
        streamId: streamId,
        peerWindowUpdateFrames: peerWindowUpdateFrames
    )
}

public func buildServerJinguiAcceptedTransportRequestTrailersFromDecodedH2HeaderFields(
    headerFields: Array<JinguiAcceptedTransportH2DecodedHeaderField>
): HttpHeaders {
    let trailers = HttpHeaders()
    for (field in headerFields) {
        if (serverJinguiAcceptedTransportH2FieldNameIsPseudo(field.name)) {
            throw Exception(
                "H2 request trailer projection does not support pseudo header `${field.name}` in this bounded seam"
            )
        }
        let normalizedName = field.name.trimAscii().toAsciiLower()
        if (shouldSkipJinguiAcceptedTransportH2RequestHeader(normalizedName)) {
            continue
        }
        trailers.add(normalizedName, field.value)
    }
    trailers
}

func shouldSkipJinguiAcceptedTransportH2RequestHeader(name: String): Bool {
    name == "" ||
    serverJinguiAcceptedTransportH2FieldNameIsPseudo(name) ||
    name == "connection" ||
    name == "keep-alive" ||
    name == "proxy-connection" ||
    name == "te" ||
    name == "transfer-encoding" ||
    name == "upgrade"
}

public func buildServerJinguiAcceptedTransportH2PseudoHeadersFromHeaderBlock(
    headerBlock: JinguiAcceptedTransportH2HeaderBlockSnapshot
): ServerJinguiAcceptedTransportH2PseudoHeaders {
    buildServerJinguiAcceptedTransportH2PseudoHeadersFromDecodedHeaderFields(
        parseJinguiAcceptedTransportH2HeaderFields(headerBlock)
    )
}

public func buildServerJinguiAcceptedTransportLogicalRequestFromH2HeaderBlock(
    headerBlock: JinguiAcceptedTransportH2HeaderBlockSnapshot,
    trailers!: ?HttpHeaders = None,
    bodyBytes!: Array<UInt8> = [],
    peerWindowUpdateFrames!:
        Array<JinguiAcceptedTransportH2FrameWireSnapshot> = []
): ServerJinguiAcceptedTransportLogicalRequest {
    buildServerJinguiAcceptedTransportLogicalRequestFromDecodedH2HeaderFields(
        parseJinguiAcceptedTransportH2HeaderFields(headerBlock),
        trailers: trailers,
        bodyBytes: bodyBytes,
        streamId: headerBlock.streamId,
        peerWindowUpdateFrames: peerWindowUpdateFrames
    )
}

public func buildServerJinguiAcceptedTransportLogicalRequestFromH2HeaderBlockWithRequestTrailers(
    headerBlock: JinguiAcceptedTransportH2HeaderBlockSnapshot,
    trailerHeaderBlock: JinguiAcceptedTransportH2HeaderBlockSnapshot,
    bodyBytes!: Array<UInt8> = [],
    peerWindowUpdateFrames!:
        Array<JinguiAcceptedTransportH2FrameWireSnapshot> = []
): ServerJinguiAcceptedTransportLogicalRequest {
    if (headerBlock.streamId != trailerHeaderBlock.streamId) {
        throw Exception(
            "H2 request trailer projection stream id mismatch: request stream ${headerBlock.streamId}, trailer stream ${trailerHeaderBlock.streamId}"
        )
    }
    let trailers =
        buildServerJinguiAcceptedTransportRequestTrailersFromDecodedH2HeaderFields(
            parseJinguiAcceptedTransportH2HeaderFields(trailerHeaderBlock)
        )
    buildServerJinguiAcceptedTransportLogicalRequestFromH2HeaderBlock(
        headerBlock,
        trailers: Some(trailers),
        bodyBytes: bodyBytes,
        peerWindowUpdateFrames: peerWindowUpdateFrames
    )
}

public func buildServerJinguiAcceptedTransportLogicalRequestFromH2HeaderBlockWithHpackDecoderState(
    headerBlock: JinguiAcceptedTransportH2HeaderBlockSnapshot,
    hpackDecoderState: ServerJinguiAcceptedTransportH2HpackDecoderState,
    bodyBytes!: Array<UInt8> = [],
    peerWindowUpdateFrames!:
        Array<JinguiAcceptedTransportH2FrameWireSnapshot> = []
): ServerJinguiAcceptedTransportLogicalRequest {
    buildServerJinguiAcceptedTransportLogicalRequestFromDecodedH2HeaderFields(
        hpackDecoderState.parseHeaderFields(headerBlock),
        bodyBytes: bodyBytes,
        streamId: headerBlock.streamId,
        peerWindowUpdateFrames: peerWindowUpdateFrames
    )
}

public class ServerJinguiAcceptedTransportTls13ClientHelloCapture {
    public let encodedClientHello: Array<Byte>
    public let consumedRecordCount: Int64
    public let consumedRecordWireByteCount: Int64

    public init(
        encodedClientHello: Array<Byte>,
        consumedRecordCount: Int64,
        consumedRecordWireByteCount: Int64
    ) {
        if (
            encodedClientHello.size == 0 ||
            consumedRecordCount <= 0 ||
            consumedRecordWireByteCount <= 0
        ) {
            throw Exception(
                "accepted-socket TLS client-hello capture fields are invalid"
            )
        }
        this.encodedClientHello = cloneServerEngineByteWindow(
            encodedClientHello,
            0,
            encodedClientHello.size
        )
        this.consumedRecordCount = consumedRecordCount
        this.consumedRecordWireByteCount = consumedRecordWireByteCount
    }
}

public class ServerJinguiAcceptedTransportSocketAttachedSessionResult {
    public let capture: ServerJinguiAcceptedTransportTls13ClientHelloCapture
    public let session: ContractHttpServerAcceptedTransportSession
    public let readySnapshot: ServerJinguiAcceptedTransportSessionSnapshot

    public init(
        capture: ServerJinguiAcceptedTransportTls13ClientHelloCapture,
        session: ContractHttpServerAcceptedTransportSession,
        readySnapshot: ServerJinguiAcceptedTransportSessionSnapshot
    ) {
        this.capture = capture
        this.session = session
        this.readySnapshot = readySnapshot
    }
}

public class ServerJinguiAcceptedTransportSocketResponseTurnResult {
    public let session: ContractHttpServerAcceptedTransportSession
    public let readySnapshot: ServerJinguiAcceptedTransportSessionSnapshot
    public let responseStatus: UInt16
    public let responseHeaders: HttpHeaders
    public let socketWriteCount: Int64
    public let totalEncodedSocketBytes: Int64

    public init(
        session: ContractHttpServerAcceptedTransportSession,
        readySnapshot: ServerJinguiAcceptedTransportSessionSnapshot,
        responseStatus: UInt16,
        responseHeaders: HttpHeaders,
        socketWriteCount: Int64,
        totalEncodedSocketBytes: Int64
    ) {
        this.session = session
        this.readySnapshot = readySnapshot
        this.responseStatus = responseStatus
        this.responseHeaders = responseHeaders
        this.socketWriteCount = socketWriteCount
        this.totalEncodedSocketBytes = totalEncodedSocketBytes
    }
}

public class ServerJinguiAcceptedTransportResponseHeaderField {
    public let name: String
    public let value: String

    public init(name: String, value: String) {
        this.name = name
        this.value = value
    }
}

class ServerJinguiAcceptedTransportEmptyInputStream <: InputStream {
    public override func read(outBuf: Array<Byte>): Int64 {
        let _ = outBuf
        0
    }

    public func close(): Unit {}
}

class ServerJinguiAcceptedTransportBytesInputStream <: InputStream {
    let bytes: Array<UInt8>
    var offset: Int64 = 0

    init(bytes: Array<UInt8>) {
        this.bytes = bytes
    }

    public override func read(outBuf: Array<Byte>): Int64 {
        if (offset >= bytes.size || outBuf.size == 0) {
            return 0
        }
        let remaining = bytes.size - offset
        let limit = if (outBuf.size < remaining) { outBuf.size } else { remaining }
        var i: Int64 = 0
        while (i < limit) {
            outBuf[i] = bytes[offset + i]
            i += 1
        }
        offset += limit
        limit
    }
}

public class ServerJinguiAcceptedTransportSocketResponseWriterLifecycle {
    let _sink: ResponseTransportWriteSink
    public var socketWriteCount: Int64 = 0
    public var totalEncodedSocketBytes: Int64 = 0
    public var closed: Bool = false
    public var closeReason: String = ""

    public init(sink: ResponseTransportWriteSink) {
        this._sink = sink
    }

    public func closeResponseWriterLifecycle(
        reason!: String = "response-writer-closed"
    ): Unit {
        closed = true
        closeReason = reason
    }

    public func writeSocketResponseBytes(bytes: Array<UInt8>): Unit {
        if (closed) {
            throw Exception(
                "accepted transport socket response writer lifecycle is closed: ${closeReason}"
            )
        }
        _sink(bytes)
        socketWriteCount += 1
        totalEncodedSocketBytes += bytes.size
    }

    public func openResponseTransportWriter(): ResponseTransportWriter {
        if (closed) {
            throw Exception(
                "accepted transport socket response writer lifecycle is closed: ${closeReason}"
            )
        }
        openSinkBackedResponseTransportWriter({ bytes =>
            writeSocketResponseBytes(bytes)
        })
    }
}

class ServerJinguiAcceptedTransportSocketResponseCarrier <: CurrentRequestCarrier & ResponseCommitStateCarrier {
    let logicalRequest: ServerJinguiAcceptedTransportLogicalRequest
    let socket: TcpSocket
    let requestBodyStreamValue: InputStream
    let responseWriterLifecycle: ServerJinguiAcceptedTransportSocketResponseWriterLifecycle
    let capturedResponseHeaderFields = ArrayList<ServerJinguiAcceptedTransportResponseHeaderField>()
    public let responseHeaders = HttpHeaders()
    public var responseStatus: UInt16 = 200

    init(
        logicalRequest: ServerJinguiAcceptedTransportLogicalRequest,
        socket: TcpSocket
    ) {
        this.logicalRequest = logicalRequest
        this.socket = socket
        this.responseWriterLifecycle =
            ServerJinguiAcceptedTransportSocketResponseWriterLifecycle(
                { bytes => socket.write(bytes) }
            )
        this.requestBodyStreamValue = if (logicalRequest.bodyBytes.size > 0) {
            ServerJinguiAcceptedTransportBytesInputStream(logicalRequest.bodyBytes)
        } else {
            ServerJinguiAcceptedTransportEmptyInputStream()
        }
    }

    func writeSocketResponseBytes(bytes: Array<UInt8>): Unit {
        responseWriterLifecycle.writeSocketResponseBytes(bytes)
    }

    public override func rawHttpContext(): HttpContext {
        throw Exception("raw HttpContext should not be required for accepted transport socket response carrier")
    }

    public override func upgradeWebSocketRaw(): WebSocket {
        throw Exception("websocket upgrade should not run for accepted transport socket response carrier")
    }

    public override func openResponseTransportWriterRaw(): ResponseTransportWriter {
        responseWriterLifecycle.openResponseTransportWriter()
    }

    public override func responseCommitted(): Bool {
        responseWriterLifecycle.socketWriteCount > 0
    }

    public override func requestMethod(): String {
        logicalRequest.method
    }

    public override func requestPath(): String {
        logicalRequest.path
    }

    public override func requestUrlString(): String {
        logicalRequest.urlString
    }

    public override func requestVersionString(): String {
        logicalRequest.versionString
    }

    public override func requestRemoteAddr(): String {
        socket.remoteAddress.toString()
    }

    public override func requestQueryValue(key: String): ?String {
        serverJinguiAcceptedTransportReadQueryValue(
            logicalRequest.queryString,
            key
        )
    }

    public override func requestFormValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestHeaderValue(key: String): ?String {
        logicalRequest.headers.getFirst(key)
    }

    public override func requestHeaderFields(): Array<(String, String)> {
        let fields = ArrayList<(String, String)>()
        for ((name, values) in logicalRequest.headers) {
            for (value in values) {
                fields.add((name, value))
            }
        }
        fields.toArray()
    }

    public override func requestTrailerValue(key: String): ?String {
        logicalRequest.trailers.getFirst(key)
    }

    public override func requestTrailerFields(): Array<(String, String)> {
        let fields = ArrayList<(String, String)>()
        for ((name, values) in logicalRequest.trailers) {
            for (value in values) {
                fields.add((name, value))
            }
        }
        fields.toArray()
    }

    public override func requestBodyStream(): InputStream {
        requestBodyStreamValue
    }

    public override func requestBodySize(): ?Int64 {
        Some(logicalRequest.bodyBytes.size)
    }

    public override func setResponseStatus(code: UInt16): Unit {
        responseStatus = code
    }

    public override func setResponseHeader(key: String, value: String): Unit {
        let normalizedName = key.trimAscii().toAsciiLower()
        if (serverJinguiAcceptedTransportH2FieldNameIsPseudo(normalizedName)) {
            return
        }
        responseHeaders.add(normalizedName, value)
        capturedResponseHeaderFields.add(
            ServerJinguiAcceptedTransportResponseHeaderField(
                normalizedName,
                value
            )
        )
    }

    public override func addResponseHeader(key: String, value: String): Unit {
        setResponseHeader(key, value)
    }

    public override func setResponseString(body: String): Unit {
        let _ = body
        throw Exception(
            "response string should be intercepted by accepted transport socket response carrier wrapper"
        )
    }

    public override func setResponseBytes(data: Array<UInt8>): Unit {
        let _ = data
        throw Exception(
            "response bytes should be intercepted by accepted transport socket response carrier wrapper"
        )
    }

    public override func attachResponseBodyStream(stream: InputStream): Unit {
        let _ = stream
        throw Exception(
            "response stream should be intercepted by accepted transport socket response carrier wrapper"
        )
    }

    public func responseHeaderFieldsForH2(): Array<ServerJinguiAcceptedTransportResponseHeaderField> {
        capturedResponseHeaderFields.toArray()
    }
}

/// Incrementally accumulates accepted-session TLS record wire until one or more
/// complete encoded records are available.
///
/// This helper is intentionally bounded: it only restores complete record
/// boundaries from fragmented bytes and does not claim live socket ownership,
/// backpressure, or generic incremental TLS parser semantics.
public class JinguiAcceptedTransportRecordWireAccumulator {
    var _buffer = ArrayList<Byte>()
    var _readCursor: Int64 = 0

    public init() {}

    public func append(fragment: Array<Byte>): Unit {
        if (fragment.size == 0) {
            return
        }
        for (b in fragment) {
            _buffer.add(b)
        }
    }

    public func drainCompleteRecords(): Array<Array<Byte>> {
        let out = ArrayList<Array<Byte>>()
        while (true) {
            let remaining = bufferedByteCount()
            if (remaining < 5) {
                break
            }
            let payloadLen =
                (Int64(UInt8(_buffer[_readCursor + 3])) << 8) +
                Int64(UInt8(_buffer[_readCursor + 4]))
            let recordSize = Int64(5) + payloadLen
            if (remaining < recordSize) {
                break
            }
            out.add(
                cloneServerEngineByteListWindow(
                    _buffer,
                    _readCursor,
                    recordSize
                )
            )
            _readCursor += recordSize
        }
        compactBuffer()
        out.toArray()
    }

    public func drainOneCompleteRecord(): Array<Array<Byte>> {
        let out = ArrayList<Array<Byte>>()
        let remaining = bufferedByteCount()
        if (remaining < 5) {
            return out.toArray()
        }
        let payloadLen =
            (Int64(UInt8(_buffer[_readCursor + 3])) << 8) +
            Int64(UInt8(_buffer[_readCursor + 4]))
        let recordSize = Int64(5) + payloadLen
        if (remaining < recordSize) {
            return out.toArray()
        }
        out.add(
            cloneServerEngineByteListWindow(
                _buffer,
                _readCursor,
                recordSize
            )
        )
        _readCursor += recordSize
        compactBuffer()
        out.toArray()
    }

    public func bufferedByteCount(): Int64 {
        _buffer.size - _readCursor
    }

    func compactBuffer(): Unit {
        if (_readCursor <= 0) {
            return
        }
        if (_readCursor >= _buffer.size) {
            _buffer = ArrayList<Byte>()
            _readCursor = 0
            return
        }
        let next = ArrayList<Byte>()
        var i = _readCursor
        while (i < _buffer.size) {
            next.add(_buffer[i])
            i += 1
        }
        _buffer = next
        _readCursor = 0
    }
}

class JinguiAcceptedTransportTls13ClientHelloAccumulator {
    var _buffer = ArrayList<Byte>()

    public init() {}

    public func appendHandshakeRecord(
        encodedRecord: Array<Byte>
    ): ?Array<Byte> {
        if (encodedRecord.size < 5) {
            throw Exception(
                "accepted-socket TLS client-hello capture expected one complete TLS record header"
            )
        }
        if (UInt8(encodedRecord[0]) != UInt8(0x16)) {
            throw Exception(
                "accepted-socket TLS client-hello capture expected handshake record contentType=22, got=${Int64(UInt8(encodedRecord[0]))}"
            )
        }
        let payloadLen =
            (Int64(UInt8(encodedRecord[3])) << 8) +
            Int64(UInt8(encodedRecord[4]))
        if (encodedRecord.size != Int64(5) + payloadLen) {
            throw Exception(
                "accepted-socket TLS client-hello capture record payload length mismatch, recordBytes=${encodedRecord.size}, payloadLen=${payloadLen}"
            )
        }
        var i: Int64 = 5
        while (i < encodedRecord.size) {
            _buffer.add(encodedRecord[i])
            i += 1
        }
        if (_buffer.size < 4) {
            return None
        }
        if (UInt8(_buffer[0]) != UInt8(0x1)) {
            throw Exception(
                "accepted-socket TLS client-hello capture expected handshakeType=1, got=${Int64(UInt8(_buffer[0]))}"
            )
        }
        let clientHelloLen =
            (Int64(UInt8(_buffer[1])) << 16) +
            (Int64(UInt8(_buffer[2])) << 8) +
            Int64(UInt8(_buffer[3]))
        let totalClientHelloBytes = Int64(4) + clientHelloLen
        if (_buffer.size < totalClientHelloBytes) {
            return None
        }
        if (_buffer.size > totalClientHelloBytes) {
            throw Exception(
                "accepted-socket TLS client-hello capture first cut does not support trailing handshake bytes beyond one ClientHello, bufferedHandshakeBytes=${_buffer.size}, expectedClientHelloBytes=${totalClientHelloBytes}"
            )
        }
        Some(
            cloneServerEngineByteListWindow(
                _buffer,
                0,
                totalClientHelloBytes
            )
        )
    }

    public func bufferedHandshakeByteCount(): Int64 {
        _buffer.size
    }
}

func captureJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloCore(
    acceptedSocket: TcpSocket,
    readChunkSize!: Int64 = 4096
): ServerJinguiAcceptedTransportTls13ClientHelloCapture {
    let recordAccumulator = JinguiAcceptedTransportRecordWireAccumulator()
    let clientHelloAccumulator =
        JinguiAcceptedTransportTls13ClientHelloAccumulator()
    let chunkSize = if (readChunkSize > 0) {
        readChunkSize
    } else {
        4096
    }
    let buf = Array<UInt8>(chunkSize, repeat: 0)
    var consumedRecordCount: Int64 = 0
    var consumedRecordWireByteCount: Int64 = 0
    while (true) {
        let n = acceptedSocket.read(buf)
        if (n <= 0) {
            break
        }
        recordAccumulator.append(serverEngineUInt8ToByteArray(buf[..n]))
        let readyRecords = recordAccumulator.drainCompleteRecords()
        var i: Int64 = 0
        while (i < readyRecords.size) {
            let record = readyRecords[i]
            consumedRecordCount += 1
            consumedRecordWireByteCount += record.size
            if (
                let Some(encodedClientHello) <-
                    clientHelloAccumulator.appendHandshakeRecord(record)
            ) {
                if (
                    i + 1 < readyRecords.size ||
                    recordAccumulator.bufferedByteCount() != 0
                ) {
                    throw Exception(
                        "accepted-socket TLS client-hello capture first cut does not support trailing TLS record wire beyond one ClientHello, trailingReadyRecords=${readyRecords.size - (i + 1)}, trailingBufferedRecordWireBytes=${recordAccumulator.bufferedByteCount()}"
                    )
                }
                return ServerJinguiAcceptedTransportTls13ClientHelloCapture(
                    encodedClientHello,
                    consumedRecordCount,
                    consumedRecordWireByteCount
                )
            }
            i += 1
        }
    }
    throw Exception(
        "accepted-socket TLS client-hello capture expected one complete ClientHello before socket read ended, consumedRecordCount=${consumedRecordCount}, consumedRecordWireBytes=${consumedRecordWireByteCount}, bufferedRecordWireBytes=${recordAccumulator.bufferedByteCount()}, bufferedHandshakeBytes=${clientHelloAccumulator.bufferedHandshakeByteCount()}"
    )
}

/// Splits one complete concatenated TLS record wire into encoded record slices.
///
/// This helper only works on already-buffered complete wire bytes. It does not
/// claim incremental stream parsing or accepted-socket runtime ownership.
public func splitJinguiAcceptedTransportRecordWire(
    encodedWire: Array<Byte>
): Array<Array<Byte>> {
    let out = ArrayList<Array<Byte>>()
    var cursor: Int64 = 0
    while (cursor < encodedWire.size) {
        let remaining = encodedWire.size - cursor
        if (remaining < 5) {
            throw Exception(
                "TLS record wire truncated before full header at offset=${cursor}, remaining=${remaining}"
            )
        }
        let payloadLen =
            (Int64(UInt8(encodedWire[cursor + 3])) << 8) +
            Int64(UInt8(encodedWire[cursor + 4]))
        let recordSize = Int64(5) + payloadLen
        if (remaining < recordSize) {
            throw Exception(
                "TLS record wire truncated before full payload at offset=${cursor}, recordSize=${recordSize}, remaining=${remaining}"
            )
        }
        out.add(
            cloneServerEngineByteWindow(
                encodedWire,
                cursor,
                recordSize
            )
        )
        cursor += recordSize
    }
    out.toArray()
}

/// Snapshot of one complete H2 frame wire.
///
/// This helper is intentionally bounded to already-buffered complete frame
/// bytes. It restores only header fields plus payload and does not claim HPACK
/// ownership, stream lifecycle semantics, flow-control, or accepted-socket
/// runtime ownership.
public class JinguiAcceptedTransportH2FrameWireSnapshot {
    public let payloadLength: Int64
    public let frameType: UInt8
    public let flags: UInt8
    public let streamId: Int64
    public let payload: Array<Byte>

    public init(
        payloadLength: Int64,
        frameType: UInt8,
        flags: UInt8,
        streamId: Int64,
        payload: Array<Byte>
    ) {
        this.payloadLength = payloadLength
        this.frameType = frameType
        this.flags = flags
        this.streamId = streamId
        this.payload = cloneServerEngineByteWindow(payload, 0, payload.size)
    }
}

func cloneJinguiAcceptedTransportH2FrameWireSnapshots(
    input: Array<JinguiAcceptedTransportH2FrameWireSnapshot>
): Array<JinguiAcceptedTransportH2FrameWireSnapshot> {
    let out =
        Array<JinguiAcceptedTransportH2FrameWireSnapshot>(input.size, repeat:
            JinguiAcceptedTransportH2FrameWireSnapshot(
                0,
                UInt8(0),
                UInt8(0),
                0,
                []
            )
        )
    var i: Int64 = 0
    while (i < input.size) {
        let frame = input[i]
        out[i] =
            JinguiAcceptedTransportH2FrameWireSnapshot(
                frame.payloadLength,
                frame.frameType,
                frame.flags,
                frame.streamId,
                frame.payload
            )
        i += 1
    }
    out
}

/// Parses one complete H2 frame wire into a bounded header + payload snapshot.
///
/// This helper requires exactly one complete frame and does not claim
/// concatenated-wire ownership or higher-level H2 semantics.
public func parseJinguiAcceptedTransportH2FrameWire(
    encodedWire: Array<Byte>
): JinguiAcceptedTransportH2FrameWireSnapshot {
    if (encodedWire.size < 9) {
        throw Exception(
            "H2 frame wire truncated before full header, remaining=${encodedWire.size}"
        )
    }
    let payloadLen =
        (Int64(UInt8(encodedWire[0])) << 16) +
        (Int64(UInt8(encodedWire[1])) << 8) +
        Int64(UInt8(encodedWire[2]))
    let frameSize = Int64(9) + payloadLen
    if (encodedWire.size < frameSize) {
        throw Exception(
            "H2 frame wire truncated before full payload, frameSize=${frameSize}, remaining=${encodedWire.size}"
        )
    }
    if (encodedWire.size > frameSize) {
        throw Exception(
            "H2 frame wire contains trailing bytes after one complete frame, frameSize=${frameSize}, total=${encodedWire.size}"
        )
    }
    let streamId =
        ((Int64(UInt8(encodedWire[5])) & 0x7f) << 24) +
        (Int64(UInt8(encodedWire[6])) << 16) +
        (Int64(UInt8(encodedWire[7])) << 8) +
        Int64(UInt8(encodedWire[8]))
    JinguiAcceptedTransportH2FrameWireSnapshot(
        payloadLen,
        UInt8(encodedWire[3]),
        UInt8(encodedWire[4]),
        streamId,
        cloneServerEngineByteWindow(encodedWire, 9, payloadLen)
    )
}

/// Splits complete concatenated H2 frame wire into individual frame slices.
///
/// This helper only restores complete frame boundaries from already-buffered
/// bytes. It does not claim incremental parser ownership or runtime ownership.
public func splitJinguiAcceptedTransportH2FrameWire(
    encodedWire: Array<Byte>
): Array<Array<Byte>> {
    let out = ArrayList<Array<Byte>>()
    var cursor: Int64 = 0
    while (cursor < encodedWire.size) {
        let remaining = encodedWire.size - cursor
        if (remaining < 9) {
            throw Exception(
                "H2 frame wire truncated before full header at offset=${cursor}, remaining=${remaining}"
            )
        }
        let payloadLen =
            (Int64(UInt8(encodedWire[cursor])) << 16) +
            (Int64(UInt8(encodedWire[cursor + 1])) << 8) +
            Int64(UInt8(encodedWire[cursor + 2]))
        let frameSize = Int64(9) + payloadLen
        if (remaining < frameSize) {
            throw Exception(
                "H2 frame wire truncated before full payload at offset=${cursor}, frameSize=${frameSize}, remaining=${remaining}"
            )
        }
        out.add(
            cloneServerEngineByteWindow(
                encodedWire,
                cursor,
                frameSize
            )
        )
        cursor += frameSize
    }
    out.toArray()
}

/// Incrementally accumulates fragmented H2 frame wire until one or more
/// complete frames are available.
///
/// This helper restores only complete frame boundaries from fragmented bytes
/// and does not claim live socket ownership, flow-control, or generic H2
/// incremental parser semantics.
public class JinguiAcceptedTransportH2FrameWireAccumulator {
    var _buffer = ArrayList<Byte>()
    var _readCursor: Int64 = 0

    public init() {}

    public func append(fragment: Array<Byte>): Unit {
        if (fragment.size == 0) {
            return
        }
        for (b in fragment) {
            _buffer.add(b)
        }
    }

    public func drainCompleteFrames(): Array<Array<Byte>> {
        let out = ArrayList<Array<Byte>>()
        while (true) {
            let remaining = bufferedByteCount()
            if (remaining < 9) {
                break
            }
            let payloadLen =
                (Int64(UInt8(_buffer[_readCursor])) << 16) +
                (Int64(UInt8(_buffer[_readCursor + 1])) << 8) +
                Int64(UInt8(_buffer[_readCursor + 2]))
            let frameSize = Int64(9) + payloadLen
            if (remaining < frameSize) {
                break
            }
            out.add(
                cloneServerEngineByteListWindow(
                    _buffer,
                    _readCursor,
                    frameSize
                )
            )
            _readCursor += frameSize
        }
        compactBuffer()
        out.toArray()
    }

    public func drainOneCompleteFrame(): Array<Array<Byte>> {
        let out = ArrayList<Array<Byte>>()
        let remaining = bufferedByteCount()
        if (remaining < 9) {
            return out.toArray()
        }
        let payloadLen =
            (Int64(UInt8(_buffer[_readCursor])) << 16) +
            (Int64(UInt8(_buffer[_readCursor + 1])) << 8) +
            Int64(UInt8(_buffer[_readCursor + 2]))
        let frameSize = Int64(9) + payloadLen
        if (remaining < frameSize) {
            return out.toArray()
        }
        out.add(
            cloneServerEngineByteListWindow(
                _buffer,
                _readCursor,
                frameSize
            )
        )
        _readCursor += frameSize
        compactBuffer()
        out.toArray()
    }

    public func bufferedByteCount(): Int64 {
        _buffer.size - _readCursor
    }

    func compactBuffer(): Unit {
        if (_readCursor <= 0) {
            return
        }
        if (_readCursor >= _buffer.size) {
            _buffer = ArrayList<Byte>()
            _readCursor = 0
            return
        }
        let next = ArrayList<Byte>()
        var i = _readCursor
        while (i < _buffer.size) {
            next.add(_buffer[i])
            i += 1
        }
        _buffer = next
        _readCursor = 0
    }
}

public class JinguiAcceptedTransportH2HeaderBlockFragmentSnapshot {
    public let frameType: UInt8
    public let streamId: Int64
    public let endHeaders: Bool
    public let endStream: Bool
    public let padded: Bool
    public let padLength: Int64
    public let priorityPresented: Bool
    public let exclusiveDependency: Bool
    public let streamDependency: Int64
    public let weight: Int64
    public let headerBlockFragment: Array<Byte>

    public init(
        frameType: UInt8,
        streamId: Int64,
        endHeaders: Bool,
        endStream: Bool,
        padded: Bool,
        padLength: Int64,
        priorityPresented: Bool,
        exclusiveDependency: Bool,
        streamDependency: Int64,
        weight: Int64,
        headerBlockFragment: Array<Byte>
    ) {
        this.frameType = frameType
        this.streamId = streamId
        this.endHeaders = endHeaders
        this.endStream = endStream
        this.padded = padded
        this.padLength = padLength
        this.priorityPresented = priorityPresented
        this.exclusiveDependency = exclusiveDependency
        this.streamDependency = streamDependency
        this.weight = weight
        this.headerBlockFragment =
            cloneServerEngineByteWindow(
                headerBlockFragment,
                0,
                headerBlockFragment.size
            )
    }
}

public class JinguiAcceptedTransportH2HeaderBlockSnapshot {
    public let streamId: Int64
    public let endStream: Bool
    public let padded: Bool
    public let priorityPresented: Bool
    public let exclusiveDependency: Bool
    public let streamDependency: Int64
    public let weight: Int64
    public let headerBlockFragment: Array<Byte>

    public init(
        streamId: Int64,
        endStream: Bool,
        padded: Bool,
        priorityPresented: Bool,
        exclusiveDependency: Bool,
        streamDependency: Int64,
        weight: Int64,
        headerBlockFragment: Array<Byte>
    ) {
        this.streamId = streamId
        this.endStream = endStream
        this.padded = padded
        this.priorityPresented = priorityPresented
        this.exclusiveDependency = exclusiveDependency
        this.streamDependency = streamDependency
        this.weight = weight
        this.headerBlockFragment =
            cloneServerEngineByteWindow(
                headerBlockFragment,
                0,
                headerBlockFragment.size
            )
    }
}

func serverJinguiAcceptedTransportH2HasFlag(
    flags: UInt8,
    mask: UInt8
): Bool {
    (Int64(flags) & Int64(mask)) != 0
}

public func parseJinguiAcceptedTransportH2HeaderBlockFragment(
    frame: JinguiAcceptedTransportH2FrameWireSnapshot
): JinguiAcceptedTransportH2HeaderBlockFragmentSnapshot {
    let isHeaders = frame.frameType == UInt8(0x1)
    let isContinuation = frame.frameType == UInt8(0x9)
    if (!isHeaders && !isContinuation) {
        throw Exception(
            "H2 header-block fragment requires HEADERS or CONTINUATION frame, got type=${Int64(frame.frameType)}"
        )
    }

    let endHeaders =
        serverJinguiAcceptedTransportH2HasFlag(
            frame.flags,
            UInt8(0x4)
        )
    let endStream = isHeaders &&
        serverJinguiAcceptedTransportH2HasFlag(
            frame.flags,
            UInt8(0x1)
        )
    let padded = isHeaders &&
        serverJinguiAcceptedTransportH2HasFlag(
            frame.flags,
            UInt8(0x8)
        )
    let priorityPresented = isHeaders &&
        serverJinguiAcceptedTransportH2HasFlag(
            frame.flags,
            UInt8(0x20)
        )

    var cursor: Int64 = 0
    var padLength: Int64 = 0
    if (padded) {
        if (frame.payload.size < 1) {
            throw Exception(
                "H2 HEADERS payload truncated before pad length, streamId=${frame.streamId}"
            )
        }
        padLength = Int64(UInt8(frame.payload[0]))
        cursor += 1
    }

    var exclusiveDependency = false
    var streamDependency: Int64 = 0
    var weight: Int64 = 0
    if (priorityPresented) {
        if (frame.payload.size - cursor < 5) {
            throw Exception(
                "H2 HEADERS payload truncated before priority fields, streamId=${frame.streamId}"
            )
        }
        exclusiveDependency =
            (Int64(UInt8(frame.payload[cursor])) & 0x80) != 0
        streamDependency =
            ((Int64(UInt8(frame.payload[cursor])) & 0x7f) << 24) +
            (Int64(UInt8(frame.payload[cursor + 1])) << 16) +
            (Int64(UInt8(frame.payload[cursor + 2])) << 8) +
            Int64(UInt8(frame.payload[cursor + 3]))
        weight = Int64(UInt8(frame.payload[cursor + 4]))
        cursor += 5
    }

    let remaining = frame.payload.size - cursor
    if (remaining < padLength) {
        throw Exception(
            "H2 header-block payload padding exceeds remaining bytes, streamId=${frame.streamId}, remaining=${remaining}, padLength=${padLength}"
        )
    }
    let fragmentSize = remaining - padLength

    JinguiAcceptedTransportH2HeaderBlockFragmentSnapshot(
        frame.frameType,
        frame.streamId,
        endHeaders,
        endStream,
        padded,
        padLength,
        priorityPresented,
        exclusiveDependency,
        streamDependency,
        weight,
        cloneServerEngineByteWindow(
            frame.payload,
            cursor,
            fragmentSize
        )
    )
}

public class JinguiAcceptedTransportH2HeaderBlockAccumulator {
    let _ready = ArrayList<JinguiAcceptedTransportH2HeaderBlockSnapshot>()
    var _open: Bool = false
    var _openStreamId: Int64 = 0
    var _openEndStream: Bool = false
    var _openPadded: Bool = false
    var _openPriorityPresented: Bool = false
    var _openExclusiveDependency: Bool = false
    var _openStreamDependency: Int64 = 0
    var _openWeight: Int64 = 0
    var _openHeaderBlock = ArrayList<Byte>()

    public init() {}

    public func append(
        frame: JinguiAcceptedTransportH2FrameWireSnapshot
    ): Unit {
        if (!_open) {
            if (frame.frameType != UInt8(0x1)) {
                throw Exception(
                    "H2 header-block accumulator expects HEADERS frame first, got type=${Int64(frame.frameType)}"
                )
            }
        } else {
            if (frame.frameType != UInt8(0x9)) {
                throw Exception(
                    "H2 header-block accumulator expects CONTINUATION while one header block is open, got type=${Int64(frame.frameType)}"
                )
            }
            if (frame.streamId != _openStreamId) {
                throw Exception(
                    "H2 CONTINUATION streamId must match open header block streamId=${_openStreamId}, got=${frame.streamId}"
                )
            }
        }
        let fragment = parseJinguiAcceptedTransportH2HeaderBlockFragment(frame)
        if (!_open) {
            _open = true
            _openStreamId = fragment.streamId
            _openEndStream = fragment.endStream
            _openPadded = fragment.padded
            _openPriorityPresented = fragment.priorityPresented
            _openExclusiveDependency = fragment.exclusiveDependency
            _openStreamDependency = fragment.streamDependency
            _openWeight = fragment.weight
            _openHeaderBlock = ArrayList<Byte>()
            appendJinguiAcceptedTransportH2HeaderBlockBytes(
                _openHeaderBlock,
                fragment.headerBlockFragment
            )
            if (fragment.endHeaders) {
                sealOpenHeaderBlock()
            }
            return
        }
        appendJinguiAcceptedTransportH2HeaderBlockBytes(
            _openHeaderBlock,
            fragment.headerBlockFragment
        )
        if (fragment.endHeaders) {
            sealOpenHeaderBlock()
        }
    }

    public func drainCompleteHeaderBlocks(
    ): Array<JinguiAcceptedTransportH2HeaderBlockSnapshot> {
        let out = _ready.toArray()
        _ready.clear()
        out
    }

    public func hasOpenHeaderBlock(): Bool {
        _open
    }

    public func bufferedHeaderBlockByteCount(): Int64 {
        _openHeaderBlock.size
    }

    func sealOpenHeaderBlock(): Unit {
        _ready.add(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                _openStreamId,
                _openEndStream,
                _openPadded,
                _openPriorityPresented,
                _openExclusiveDependency,
                _openStreamDependency,
                _openWeight,
                _openHeaderBlock.toArray()
            )
        )
        _open = false
        _openStreamId = 0
        _openEndStream = false
        _openPadded = false
        _openPriorityPresented = false
        _openExclusiveDependency = false
        _openStreamDependency = 0
        _openWeight = 0
        _openHeaderBlock = ArrayList<Byte>()
    }
}

/// Chains fragmented live H2 wire into assembled HEADERS/CONTINUATION-only
/// header blocks.
///
/// This helper intentionally stays narrow: it reuses the existing frame-wire
/// accumulator plus header-block accumulator, and it does not claim DATA/body
/// frame ownership, generic frame dispatch, or runtime lifecycle ownership.
public class JinguiAcceptedTransportH2HeaderBlockIngressAccumulator {
    let _frameAccumulator = JinguiAcceptedTransportH2FrameWireAccumulator()
    let _headerBlockAccumulator = JinguiAcceptedTransportH2HeaderBlockAccumulator()

    public init() {}

    public func append(fragment: Array<Byte>): Unit {
        _frameAccumulator.append(fragment)
        for (frameWire in _frameAccumulator.drainCompleteFrames()) {
            _headerBlockAccumulator.append(
                parseJinguiAcceptedTransportH2FrameWire(frameWire)
            )
        }
    }

    public func drainCompleteHeaderBlocks(
    ): Array<JinguiAcceptedTransportH2HeaderBlockSnapshot> {
        _headerBlockAccumulator.drainCompleteHeaderBlocks()
    }

    public func bufferedByteCount(): Int64 {
        _frameAccumulator.bufferedByteCount()
    }

    public func hasOpenHeaderBlock(): Bool {
        _headerBlockAccumulator.hasOpenHeaderBlock()
    }

    public func bufferedHeaderBlockByteCount(): Int64 {
        _headerBlockAccumulator.bufferedHeaderBlockByteCount()
    }
}

/// Incrementally accumulates fragmented accepted-session TLS record wire,
/// opens complete application-data records, and drains assembled H2 header
/// blocks.
///
/// This helper intentionally stays bounded: it restores complete TLS record
/// boundaries, reuses the existing plaintext H2 header-block ingress
/// accumulator, and does not claim socket-read ownership, DATA/body frame
/// ownership, generic H2 multiplexing, flow-control, stream lifecycle, or
/// runtime closure.
public class JinguiAcceptedTransportApplicationDataH2HeaderBlockIngressAccumulator {
    let _session: ContractHttpServerAcceptedTransportSession
    let _recordAccumulator = JinguiAcceptedTransportRecordWireAccumulator()
    let _headerBlockIngressAccumulator =
        JinguiAcceptedTransportH2HeaderBlockIngressAccumulator()

    public init(session: ContractHttpServerAcceptedTransportSession) {
        ensureServerJinguiAcceptedTransportSessionCodecReady(session)
        _session = session
    }

    public func append(fragment: Array<Byte>): Unit {
        ensureServerJinguiAcceptedTransportSessionCodecReady(_session)
        _recordAccumulator.append(fragment)
        for (encodedRecord in _recordAccumulator.drainCompleteRecords()) {
            _headerBlockIngressAccumulator.append(
                _session.recordChannel.openApplicationData(encodedRecord)
            )
        }
    }

    public func drainCompleteHeaderBlocks(
    ): Array<JinguiAcceptedTransportH2HeaderBlockSnapshot> {
        _headerBlockIngressAccumulator.drainCompleteHeaderBlocks()
    }

    public func bufferedRecordWireByteCount(): Int64 {
        _recordAccumulator.bufferedByteCount()
    }

    public func bufferedH2FrameWireByteCount(): Int64 {
        _headerBlockIngressAccumulator.bufferedByteCount()
    }

    public func hasOpenHeaderBlock(): Bool {
        _headerBlockIngressAccumulator.hasOpenHeaderBlock()
    }

    public func bufferedHeaderBlockByteCount(): Int64 {
        _headerBlockIngressAccumulator.bufferedHeaderBlockByteCount()
    }
}

/// Incrementally accumulates fragmented accepted-session TLS record wire and
/// drains at most one logical request from one complete H2 header block.
///
/// This helper intentionally stays one-request-bounded: it reuses the
/// accepted-session fragmented-record-wire header-block ingress seam plus the
/// existing header-block logical-request projection, and it does not claim
/// socket-read ownership, DATA/body frame ownership, generic H2 multiplexing,
/// flow-control, stream lifecycle, or runtime closure.
public class JinguiAcceptedTransportApplicationDataH2HeaderBlockLogicalRequestAccumulator {
    let _headerBlockIngressAccumulator:
        JinguiAcceptedTransportApplicationDataH2HeaderBlockIngressAccumulator
    let _bodyBytes: Array<UInt8>
    let _ready = ArrayList<ServerJinguiAcceptedTransportLogicalRequest>()
    var _sealedLogicalRequest = false

    public init(
        session: ContractHttpServerAcceptedTransportSession,
        bodyBytes!: Array<UInt8> = []
    ) {
        _headerBlockIngressAccumulator =
            JinguiAcceptedTransportApplicationDataH2HeaderBlockIngressAccumulator(
                session
            )
        _bodyBytes = cloneServerEngineUInt8Array(bodyBytes)
    }

    public func append(fragment: Array<Byte>): Unit {
        _headerBlockIngressAccumulator.append(fragment)
        let completedHeaderBlocks =
            _headerBlockIngressAccumulator.drainCompleteHeaderBlocks()
        if (completedHeaderBlocks.size == 0) {
            return
        }
        let projectedCount = completedHeaderBlocks.size + if (_sealedLogicalRequest) {
            1
        } else {
            0
        }
        if (projectedCount > 1) {
            throw Exception(
                "accepted-session fragmented-record-wire logical-request projection expects exactly one complete H2 header block while the packet stays one-request-bounded, got count=${projectedCount}"
            )
        }
        _ready.add(
            buildServerJinguiAcceptedTransportLogicalRequestFromH2HeaderBlock(
                completedHeaderBlocks[0],
                bodyBytes: _bodyBytes
            )
        )
        _sealedLogicalRequest = true
    }

    public func drainCompleteLogicalRequests(
    ): Array<ServerJinguiAcceptedTransportLogicalRequest> {
        if (_ready.size == 0) {
            return []
        }
        let out = _ready.toArray()
        _ready.clear()
        out
    }

    public func bufferedRecordWireByteCount(): Int64 {
        _headerBlockIngressAccumulator.bufferedRecordWireByteCount()
    }

    public func bufferedH2FrameWireByteCount(): Int64 {
        _headerBlockIngressAccumulator.bufferedH2FrameWireByteCount()
    }

    public func hasOpenHeaderBlock(): Bool {
        _headerBlockIngressAccumulator.hasOpenHeaderBlock()
    }

    public func bufferedHeaderBlockByteCount(): Int64 {
        _headerBlockIngressAccumulator.bufferedHeaderBlockByteCount()
    }
}

/// Incrementally accumulates fragmented accepted-session TLS record wire and
/// drains at most one logical request from one complete H2 header block plus
/// same-stream DATA frames terminated by END_STREAM.
///
/// This helper intentionally stays one-request-bounded: it restores complete
/// TLS record boundaries, reuses the existing H2 frame wire accumulator plus
/// header-block accumulator plus request projection seam, and it does not
/// claim socket-read ownership, generic H2 multiplexing, flow-control, stream
/// lifecycle, or runtime closure.
public class JinguiAcceptedTransportApplicationDataH2HeadersPlusDataLogicalRequestAccumulator {
    let _session: ContractHttpServerAcceptedTransportSession
    let _recordAccumulator = JinguiAcceptedTransportRecordWireAccumulator()
    let _frameAccumulator = JinguiAcceptedTransportH2FrameWireAccumulator()
    let _headerBlockAccumulator = JinguiAcceptedTransportH2HeaderBlockAccumulator()
    let _hpackDecoderState: ServerJinguiAcceptedTransportH2HpackDecoderState
    let _ready = ArrayList<ServerJinguiAcceptedTransportLogicalRequest>()
    let _peerWindowUpdateFrames =
        ArrayList<JinguiAcceptedTransportH2FrameWireSnapshot>()
    var _sealedLogicalRequest = false
    var _completedHeaderBlock: ?JinguiAcceptedTransportH2HeaderBlockSnapshot = None
    var _bodyBytes = ArrayList<Byte>()

    public init(
        session: ContractHttpServerAcceptedTransportSession,
        hpackDecoderState!: ?ServerJinguiAcceptedTransportH2HpackDecoderState = None
    ) {
        ensureServerJinguiAcceptedTransportSessionCodecReady(session)
        _session = session
        match (hpackDecoderState) {
            case Some(state) =>
                _hpackDecoderState = state
            case None =>
                _hpackDecoderState =
                    ServerJinguiAcceptedTransportH2HpackDecoderState()
        }
    }

    public func append(fragment: Array<Byte>): Unit {
        ensureServerJinguiAcceptedTransportSessionCodecReady(_session)
        if (fragment.size > 0) {
            _recordAccumulator.append(fragment)
        }
        drainBufferedUntilOneLogicalRequest()
    }

    func drainBufferedUntilOneLogicalRequest(): Unit {
        while (_ready.size == 0 && !_sealedLogicalRequest) {
            let frameWireItems = _frameAccumulator.drainOneCompleteFrame()
            if (frameWireItems.size > 0) {
                appendParsedFrame(
                    parseJinguiAcceptedTransportH2FrameWire(frameWireItems[0])
                )
                continue
            }
            let encodedRecords = _recordAccumulator.drainOneCompleteRecord()
            if (encodedRecords.size == 0) {
                break
            }
            _frameAccumulator.append(
                _session.recordChannel.openApplicationData(encodedRecords[0])
            )
        }
    }

    public func drainCompleteLogicalRequests(
    ): Array<ServerJinguiAcceptedTransportLogicalRequest> {
        if (_ready.size == 0) {
            return []
        }
        let out = _ready.toArray()
        _ready.clear()
        _sealedLogicalRequest = false
        out
    }

    public func bufferedRecordWireByteCount(): Int64 {
        _recordAccumulator.bufferedByteCount()
    }

    public func bufferedH2FrameWireByteCount(): Int64 {
        _frameAccumulator.bufferedByteCount()
    }

    public func hasOpenHeaderBlock(): Bool {
        _headerBlockAccumulator.hasOpenHeaderBlock()
    }

    public func bufferedHeaderBlockByteCount(): Int64 {
        _headerBlockAccumulator.bufferedHeaderBlockByteCount()
    }

    public func bufferedBodyByteCount(): Int64 {
        _bodyBytes.size
    }

    func appendParsedFrame(frame: JinguiAcceptedTransportH2FrameWireSnapshot): Unit {
        if (_sealedLogicalRequest) {
            throw Exception(
                "accepted-session fragmented-record-wire headers-plus-data logical-request projection stays one-request-bounded and rejects additional H2 frames after one logical request, got type=${Int64(frame.frameType)}, streamId=${frame.streamId}"
            )
        }
        match (_completedHeaderBlock) {
            case None =>
                _headerBlockAccumulator.append(frame)
            case Some(headerBlock) =>
                appendBodyFrame(
                    headerBlock,
                    frame
                )
        }
        let completedHeaderBlocks =
            _headerBlockAccumulator.drainCompleteHeaderBlocks()
        if (completedHeaderBlocks.size == 0) {
            return
        }
        let projectedCount = completedHeaderBlocks.size + match (_completedHeaderBlock) {
            case Some(_) => 1
            case None => 0
        }
        if (projectedCount > 1) {
            throw Exception(
                "accepted-session fragmented-record-wire headers-plus-data logical-request projection expects exactly one complete H2 header block before DATA accumulation while the packet stays one-request-bounded, got count=${projectedCount}"
            )
        }
        let headerBlock = completedHeaderBlocks[0]
        if (headerBlock.endStream) {
            throw Exception(
                "accepted-session fragmented-record-wire headers-plus-data logical-request projection expects at least one same-stream H2 DATA frame after one complete H2 header block"
            )
        }
        _completedHeaderBlock = Some(headerBlock)
    }

    func appendBodyFrame(
        headerBlock: JinguiAcceptedTransportH2HeaderBlockSnapshot,
        frame: JinguiAcceptedTransportH2FrameWireSnapshot
    ): Unit {
        if (frame.frameType == UInt8(0x1) || frame.frameType == UInt8(0x9)) {
            appendTrailingHeaderFrame(headerBlock, frame)
            return
        }
        if (frame.frameType == UInt8(0x8)) {
            appendPeerWindowUpdateFrame(headerBlock, frame)
            return
        }
        if (frame.frameType != UInt8(0x0)) {
            throw Exception(
                "accepted-session fragmented-record-wire headers-plus-data logical-request projection stays inside one request boundary and only accepts same-stream DATA after one complete H2 header block, got type=${Int64(frame.frameType)}, streamId=${frame.streamId}"
            )
        }
        let dataFrame =
            parseJinguiAcceptedTransportH2DataFrame(frame)
        if (dataFrame.streamId != headerBlock.streamId) {
            throw Exception(
                "accepted-session fragmented-record-wire headers-plus-data logical-request projection requires same-stream DATA, headerStreamId=${headerBlock.streamId}, dataStreamId=${dataFrame.streamId}"
            )
        }
        for (b in dataFrame.dataBytes) {
            _bodyBytes.add(b)
        }
        if (!dataFrame.endStream) {
            return
        }
        if (_bodyBytes.size == 0) {
            throw Exception(
                "accepted-session fragmented-record-wire headers-plus-data logical-request projection expects at least one same-stream H2 DATA frame after one complete H2 header block"
            )
        }
        _ready.add(
            buildServerJinguiAcceptedTransportLogicalRequestFromH2HeaderBlockWithHpackDecoderState(
                headerBlock,
                _hpackDecoderState,
                bodyBytes: serverEngineByteToUInt8Array(_bodyBytes.toArray()),
                peerWindowUpdateFrames: _peerWindowUpdateFrames.toArray()
            )
        )
        _sealedLogicalRequest = true
        _completedHeaderBlock = None
        _bodyBytes = ArrayList<Byte>()
        _peerWindowUpdateFrames.clear()
    }

    func appendPeerWindowUpdateFrame(
        headerBlock: JinguiAcceptedTransportH2HeaderBlockSnapshot,
        frame: JinguiAcceptedTransportH2FrameWireSnapshot
    ): Unit {
        let windowUpdate =
            parseJinguiAcceptedTransportH2WindowUpdateFrame(frame)
        if (
            !windowUpdate.connectionScoped &&
            windowUpdate.streamId != headerBlock.streamId
        ) {
            throw Exception(
                "accepted-session fragmented-record-wire headers-plus-data logical-request projection rejects cross-stream WINDOW_UPDATE in one-request boundary, requestStreamId=${headerBlock.streamId}, windowUpdateStreamId=${windowUpdate.streamId}"
            )
        }
        _peerWindowUpdateFrames.add(frame)
    }

    func appendTrailingHeaderFrame(
        headerBlock: JinguiAcceptedTransportH2HeaderBlockSnapshot,
        frame: JinguiAcceptedTransportH2FrameWireSnapshot
    ): Unit {
        if (_bodyBytes.size == 0) {
            throw Exception(
                "accepted-session fragmented-record-wire headers-plus-data logical-request projection expects at least one same-stream H2 DATA frame before trailing HEADERS"
            )
        }
        _headerBlockAccumulator.append(frame)
        let completedTrailerBlocks =
            _headerBlockAccumulator.drainCompleteHeaderBlocks()
        if (completedTrailerBlocks.size == 0) {
            return
        }
        if (completedTrailerBlocks.size != 1) {
            throw Exception(
                "accepted-session fragmented-record-wire headers-plus-data logical-request projection expects exactly one trailing HEADERS block, got count=${completedTrailerBlocks.size}"
            )
        }
        let trailerBlock = completedTrailerBlocks[0]
        if (!trailerBlock.endStream) {
            throw Exception(
                "accepted-session fragmented-record-wire headers-plus-data logical-request projection expects trailing HEADERS to carry END_STREAM, streamId=${trailerBlock.streamId}"
            )
        }
        _ready.add(
            buildServerJinguiAcceptedTransportLogicalRequestFromH2HeaderBlockWithRequestTrailers(
                headerBlock,
                trailerBlock,
                bodyBytes: serverEngineByteToUInt8Array(_bodyBytes.toArray()),
                peerWindowUpdateFrames: _peerWindowUpdateFrames.toArray()
            )
        )
        _sealedLogicalRequest = true
        _completedHeaderBlock = None
        _bodyBytes = ArrayList<Byte>()
        _peerWindowUpdateFrames.clear()
    }
}

public class JinguiAcceptedTransportH2DataFrameSnapshot {
    public let streamId: Int64
    public let endStream: Bool
    public let padded: Bool
    public let padLength: Int64
    public let dataBytes: Array<Byte>

    public init(
        streamId: Int64,
        endStream: Bool,
        padded: Bool,
        padLength: Int64,
        dataBytes: Array<Byte>
    ) {
        this.streamId = streamId
        this.endStream = endStream
        this.padded = padded
        this.padLength = padLength
        this.dataBytes =
            cloneServerEngineByteWindow(
                dataBytes,
                0,
                dataBytes.size
            )
    }
}

public func parseJinguiAcceptedTransportH2DataFrame(
    frame: JinguiAcceptedTransportH2FrameWireSnapshot
): JinguiAcceptedTransportH2DataFrameSnapshot {
    if (frame.frameType != UInt8(0x0)) {
        throw Exception(
            "H2 DATA frame parse requires DATA frame type=0, got type=${Int64(frame.frameType)}"
        )
    }
    let endStream =
        serverJinguiAcceptedTransportH2HasFlag(
            frame.flags,
            UInt8(0x1)
        )
    let padded =
        serverJinguiAcceptedTransportH2HasFlag(
            frame.flags,
            UInt8(0x8)
        )
    var cursor: Int64 = 0
    var padLength: Int64 = 0
    if (padded) {
        if (frame.payload.size < 1) {
            throw Exception(
                "H2 DATA payload truncated before pad length, streamId=${frame.streamId}"
            )
        }
        padLength = Int64(UInt8(frame.payload[0]))
        cursor += 1
    }
    let remaining = frame.payload.size - cursor
    if (remaining < padLength) {
        throw Exception(
            "H2 DATA payload padding exceeds remaining bytes, streamId=${frame.streamId}, remaining=${remaining}, padLength=${padLength}"
        )
    }
    let dataSize = remaining - padLength
    JinguiAcceptedTransportH2DataFrameSnapshot(
        frame.streamId,
        endStream,
        padded,
        padLength,
        cloneServerEngineByteWindow(
            frame.payload,
            cursor,
            dataSize
        )
    )
}

public enum JinguiAcceptedTransportH2StreamLifecycleState <: Equatable<JinguiAcceptedTransportH2StreamLifecycleState> & ToString {
    | Opened
    | HalfClosedLocal
    | HalfClosedRemote
    | Reset
    | Closed

    public operator func ==(right: JinguiAcceptedTransportH2StreamLifecycleState): Bool {
        ordinalValue() == right.ordinalValue()
    }

    public operator func !=(right: JinguiAcceptedTransportH2StreamLifecycleState): Bool {
        !(this == right)
    }

    public func ordinalValue(): Int64 {
        match (this) {
            case Opened => 0
            case HalfClosedLocal => 1
            case HalfClosedRemote => 2
            case Reset => 3
            case Closed => 4
        }
    }

    public func toString(): String {
        match (this) {
            case Opened => "opened"
            case HalfClosedLocal => "half-closed-local"
            case HalfClosedRemote => "half-closed-remote"
            case Reset => "reset"
            case Closed => "closed"
        }
    }
}

public class JinguiAcceptedTransportH2StreamLifecycleSnapshot {
    public let streamId: Int64
    public let state: JinguiAcceptedTransportH2StreamLifecycleState
    public let stateName: String
    public let headersSeen: Bool
    public let remoteEndStreamSeen: Bool
    public let responseFinished: Bool
    public let resetSeen: Bool

    public init(
        streamId: Int64,
        state: JinguiAcceptedTransportH2StreamLifecycleState,
        headersSeen: Bool,
        remoteEndStreamSeen: Bool,
        responseFinished: Bool,
        resetSeen: Bool
    ) {
        this.streamId = streamId
        this.state = state
        this.stateName = state.toString()
        this.headersSeen = headersSeen
        this.remoteEndStreamSeen = remoteEndStreamSeen
        this.responseFinished = responseFinished
        this.resetSeen = resetSeen
    }
}

class JinguiAcceptedTransportH2StreamLifecycleEntry {
    let streamId: Int64
    var state: JinguiAcceptedTransportH2StreamLifecycleState
    var headersSeen: Bool = false
    var remoteEndStreamSeen: Bool = false
    var responseFinished: Bool = false
    var resetSeen: Bool = false

    init(streamId: Int64) {
        this.streamId = streamId
        this.state = JinguiAcceptedTransportH2StreamLifecycleState.Opened
    }

    func snapshot(): JinguiAcceptedTransportH2StreamLifecycleSnapshot {
        JinguiAcceptedTransportH2StreamLifecycleSnapshot(
            streamId,
            state,
            headersSeen,
            remoteEndStreamSeen,
            responseFinished,
            resetSeen
        )
    }
}

/// Minimal H2 stream lifecycle registry.
///
/// This model records per-stream lifecycle transitions only. It is intentionally
/// not a scheduler, priority tree, flow-control budget, browser replay harness,
/// or full multiplexing claim.
public class JinguiAcceptedTransportH2StreamLifecycleRegistry {
    let _streams = ArrayList<JinguiAcceptedTransportH2StreamLifecycleEntry>()

    public init() {}

    public func observeHeaders(
        headerBlock: JinguiAcceptedTransportH2HeaderBlockSnapshot
    ): Unit {
        let entry = ensureEntry(headerBlock.streamId)
        ensureTransitionAllowed(entry, "HEADERS")
        entry.headersSeen = true
        if (headerBlock.endStream) {
            markRemoteEnd(entry)
            return
        }
        refreshOpenState(entry)
    }

    public func observeData(
        dataFrame: JinguiAcceptedTransportH2DataFrameSnapshot
    ): Unit {
        let entry = findRequiredEntry(dataFrame.streamId, "DATA")
        ensureTransitionAllowed(entry, "DATA")
        if (!entry.headersSeen) {
            throw Exception(
                "H2 stream lifecycle registry requires HEADERS before DATA, streamId=${dataFrame.streamId}"
            )
        }
        if (dataFrame.endStream) {
            markRemoteEnd(entry)
            return
        }
        refreshOpenState(entry)
    }

    public func observeRstStreamFrame(
        frame: JinguiAcceptedTransportH2FrameWireSnapshot
    ): Unit {
        if (frame.frameType != UInt8(0x3)) {
            throw Exception(
                "H2 stream lifecycle registry requires RST_STREAM frame type=3, got type=${Int64(frame.frameType)}"
            )
        }
        let entry = ensureEntry(frame.streamId)
        entry.resetSeen = true
        entry.state = JinguiAcceptedTransportH2StreamLifecycleState.Reset
    }

    public func finishResponse(streamId: Int64): Unit {
        let entry = findRequiredEntry(streamId, "response-finish")
        if (entry.state == JinguiAcceptedTransportH2StreamLifecycleState.Reset) {
            return
        }
        entry.responseFinished = true
        if (entry.remoteEndStreamSeen) {
            entry.state = JinguiAcceptedTransportH2StreamLifecycleState.Closed
            return
        }
        entry.state = JinguiAcceptedTransportH2StreamLifecycleState.HalfClosedLocal
    }

    public func streamCount(): Int64 {
        _streams.size
    }

    public func hasStream(streamId: Int64): Bool {
        match (findEntry(streamId)) {
            case Some(_) => true
            case None => false
        }
    }

    public func snapshotOf(
        streamId: Int64
    ): JinguiAcceptedTransportH2StreamLifecycleSnapshot {
        findRequiredEntry(streamId, "snapshot").snapshot()
    }

    public func stateOf(
        streamId: Int64
    ): JinguiAcceptedTransportH2StreamLifecycleState {
        snapshotOf(streamId).state
    }

    public func snapshots(
    ): Array<JinguiAcceptedTransportH2StreamLifecycleSnapshot> {
        let out = ArrayList<JinguiAcceptedTransportH2StreamLifecycleSnapshot>()
        for (entry in _streams) {
            out.add(entry.snapshot())
        }
        out.toArray()
    }

    func ensureEntry(
        streamId: Int64
    ): JinguiAcceptedTransportH2StreamLifecycleEntry {
        ensureStreamId(streamId)
        match (findEntry(streamId)) {
            case Some(entry) => entry
            case None =>
                let entry = JinguiAcceptedTransportH2StreamLifecycleEntry(
                    streamId
                )
                _streams.add(entry)
                entry
        }
    }

    func findRequiredEntry(
        streamId: Int64,
        transition: String
    ): JinguiAcceptedTransportH2StreamLifecycleEntry {
        ensureStreamId(streamId)
        match (findEntry(streamId)) {
            case Some(entry) => entry
            case None =>
                throw Exception(
                    "H2 stream lifecycle registry requires stream to be opened before ${transition}, streamId=${streamId}"
                )
        }
    }

    func findEntry(
        streamId: Int64
    ): ?JinguiAcceptedTransportH2StreamLifecycleEntry {
        for (entry in _streams) {
            if (entry.streamId == streamId) {
                return Some(entry)
            }
        }
        None
    }

    func ensureStreamId(streamId: Int64): Unit {
        if (streamId <= 0) {
            throw Exception(
                "H2 stream lifecycle registry requires non-zero streamId, got ${streamId}"
            )
        }
    }

    func ensureTransitionAllowed(
        entry: JinguiAcceptedTransportH2StreamLifecycleEntry,
        transition: String
    ): Unit {
        if (
            entry.state == JinguiAcceptedTransportH2StreamLifecycleState.Reset ||
            entry.state == JinguiAcceptedTransportH2StreamLifecycleState.Closed
        ) {
            throw Exception(
                "H2 stream lifecycle registry cannot apply ${transition} to streamId=${entry.streamId} in state=${entry.state.toString()}"
            )
        }
    }

    func markRemoteEnd(
        entry: JinguiAcceptedTransportH2StreamLifecycleEntry
    ): Unit {
        entry.remoteEndStreamSeen = true
        if (entry.responseFinished) {
            entry.state = JinguiAcceptedTransportH2StreamLifecycleState.Closed
            return
        }
        entry.state = JinguiAcceptedTransportH2StreamLifecycleState.HalfClosedRemote
    }

    func refreshOpenState(
        entry: JinguiAcceptedTransportH2StreamLifecycleEntry
    ): Unit {
        if (entry.responseFinished) {
            entry.state = JinguiAcceptedTransportH2StreamLifecycleState.HalfClosedLocal
            return
        }
        entry.state = JinguiAcceptedTransportH2StreamLifecycleState.Opened
    }
}

public enum JinguiAcceptedTransportH2FlowBudgetDecisionStatus <: Equatable<JinguiAcceptedTransportH2FlowBudgetDecisionStatus> & ToString {
    | Sent
    | WaitingForWindowUpdate
    | TimedOutWaitingForWindowUpdate
    | StreamClosed
    | ConnectionClosed
    | NotFlowBudgetStall

    public operator func ==(right: JinguiAcceptedTransportH2FlowBudgetDecisionStatus): Bool {
        ordinalValue() == right.ordinalValue()
    }

    public operator func !=(right: JinguiAcceptedTransportH2FlowBudgetDecisionStatus): Bool {
        !(this == right)
    }

    public func ordinalValue(): Int64 {
        match (this) {
            case Sent => 0
            case WaitingForWindowUpdate => 1
            case TimedOutWaitingForWindowUpdate => 2
            case StreamClosed => 3
            case ConnectionClosed => 4
            case NotFlowBudgetStall => 5
        }
    }

    public func toString(): String {
        match (this) {
            case Sent => "sent"
            case WaitingForWindowUpdate => "waiting-for-window-update"
            case TimedOutWaitingForWindowUpdate => "timed-out-waiting-for-window-update"
            case StreamClosed => "stream-closed"
            case ConnectionClosed => "connection-closed"
            case NotFlowBudgetStall => "not-flow-budget-stall"
        }
    }
}

public class JinguiAcceptedTransportH2FlowBudgetDecisionSnapshot {
    public let streamId: Int64
    public let byteCount: Int64
    public let status: JinguiAcceptedTransportH2FlowBudgetDecisionStatus
    public let statusName: String
    public let canWrite: Bool
    public let waitingForWindowUpdate: Bool
    public let protocolError: Bool
    public let connectionSendBudget: Int64
    public let streamSendBudget: Int64
    public let lifecycleStateName: String

    public init(
        streamId: Int64,
        byteCount: Int64,
        status: JinguiAcceptedTransportH2FlowBudgetDecisionStatus,
        canWrite: Bool,
        waitingForWindowUpdate: Bool,
        protocolError: Bool,
        connectionSendBudget: Int64,
        streamSendBudget: Int64,
        lifecycleStateName: String
    ) {
        this.streamId = streamId
        this.byteCount = byteCount
        this.status = status
        this.statusName = status.toString()
        this.canWrite = canWrite
        this.waitingForWindowUpdate = waitingForWindowUpdate
        this.protocolError = protocolError
        this.connectionSendBudget = connectionSendBudget
        this.streamSendBudget = streamSendBudget
        this.lifecycleStateName = lifecycleStateName
    }
}

public class JinguiAcceptedTransportH2WindowUpdateSnapshot {
    public let streamId: Int64
    public let increment: Int64
    public let connectionScoped: Bool

    public init(
        streamId: Int64,
        increment: Int64,
        connectionScoped: Bool
    ) {
        this.streamId = streamId
        this.increment = increment
        this.connectionScoped = connectionScoped
    }
}

public func parseJinguiAcceptedTransportH2WindowUpdateFrame(
    frame: JinguiAcceptedTransportH2FrameWireSnapshot
): JinguiAcceptedTransportH2WindowUpdateSnapshot {
    if (frame.frameType != UInt8(0x8)) {
        throw Exception(
            "H2 WINDOW_UPDATE parse requires frame type=8, got type=${Int64(frame.frameType)}"
        )
    }
    if (frame.payload.size != 4) {
        throw Exception(
            "H2 WINDOW_UPDATE payload requires 4 bytes, got size=${frame.payload.size}, streamId=${frame.streamId}"
        )
    }
    let rawIncrement =
        (Int64(UInt8(frame.payload[0])) << 24) +
        (Int64(UInt8(frame.payload[1])) << 16) +
        (Int64(UInt8(frame.payload[2])) << 8) +
        Int64(UInt8(frame.payload[3]))
    let increment = rawIncrement & Int64(0x7fffffff)
    if (increment <= 0) {
        throw Exception(
            "H2 WINDOW_UPDATE increment must be positive, streamId=${frame.streamId}"
        )
    }
    JinguiAcceptedTransportH2WindowUpdateSnapshot(
        frame.streamId,
        increment,
        frame.streamId == 0
    )
}

class JinguiAcceptedTransportH2FlowBudgetStreamEntry {
    let streamId: Int64
    var sendBudget: Int64

    init(
        streamId: Int64,
        sendBudget: Int64
    ) {
        this.streamId = streamId
        this.sendBudget = sendBudget
    }
}

/// Minimal H2 send-window budget model.
///
/// This is a model proof, not a live socket writer or scheduler. It keeps
/// connection and stream send budgets separate so WINDOW_UPDATE can be proven
/// as a recovery path before browser replay or priority scheduling exists.
public class JinguiAcceptedTransportH2FlowBudgetModel {
    let _lifecycleRegistry = JinguiAcceptedTransportH2StreamLifecycleRegistry()
    let _streamBudgets = ArrayList<JinguiAcceptedTransportH2FlowBudgetStreamEntry>()
    let _defaultInitialStreamSendBudget: Int64
    var _connectionSendBudget: Int64
    var _connectionClosed: Bool = false
    var _connectionCloseReason: String = ""

    public init(
        connectionSendBudget: Int64,
        defaultInitialStreamSendBudget: Int64
    ) {
        if (connectionSendBudget < 0) {
            throw Exception(
                "H2 flow budget model requires non-negative connection budget, got ${connectionSendBudget}"
            )
        }
        if (defaultInitialStreamSendBudget < 0) {
            throw Exception(
                "H2 flow budget model requires non-negative stream budget, got ${defaultInitialStreamSendBudget}"
            )
        }
        this._connectionSendBudget = connectionSendBudget
        this._defaultInitialStreamSendBudget = defaultInitialStreamSendBudget
    }

    public func observeHeaders(
        headerBlock: JinguiAcceptedTransportH2HeaderBlockSnapshot
    ): Unit {
        _lifecycleRegistry.observeHeaders(headerBlock)
        ensureBudgetEntry(headerBlock.streamId)
    }

    public func observeData(
        dataFrame: JinguiAcceptedTransportH2DataFrameSnapshot
    ): Unit {
        _lifecycleRegistry.observeData(dataFrame)
        ensureBudgetEntry(dataFrame.streamId)
    }

    public func observeRstStreamFrame(
        frame: JinguiAcceptedTransportH2FrameWireSnapshot
    ): Unit {
        _lifecycleRegistry.observeRstStreamFrame(frame)
        ensureBudgetEntry(frame.streamId)
    }

    public func observeGoawayFrame(
        frame: JinguiAcceptedTransportH2FrameWireSnapshot
    ): Unit {
        if (frame.frameType != UInt8(0x7)) {
            throw Exception(
                "H2 flow budget model requires GOAWAY frame type=7, got type=${Int64(frame.frameType)}"
            )
        }
        _connectionClosed = true
        _connectionCloseReason = "goaway"
    }

    public func finishResponse(streamId: Int64): Unit {
        _lifecycleRegistry.finishResponse(streamId)
    }

    public func observeWindowUpdateFrame(
        frame: JinguiAcceptedTransportH2FrameWireSnapshot
    ): JinguiAcceptedTransportH2WindowUpdateSnapshot {
        let windowUpdate = parseJinguiAcceptedTransportH2WindowUpdateFrame(frame)
        if (windowUpdate.connectionScoped) {
            _connectionSendBudget += windowUpdate.increment
            return windowUpdate
        }
        ensureLifecycleCanReceiveWindowUpdate(windowUpdate.streamId)
        let entry = ensureBudgetEntry(windowUpdate.streamId)
        entry.sendBudget += windowUpdate.increment
        windowUpdate
    }

    public func trySpendData(
        streamId: Int64,
        byteCount: Int64
    ): JinguiAcceptedTransportH2FlowBudgetDecisionSnapshot {
        ensureNonNegativeBudget(byteCount, "byte-count")
        let entry = ensureBudgetEntry(streamId)
        if (_connectionClosed) {
            return snapshot(
                streamId,
                byteCount,
                JinguiAcceptedTransportH2FlowBudgetDecisionStatus.ConnectionClosed,
                false,
                false
            )
        }
        if (!streamSendSideOpen(streamId)) {
            return snapshot(
                streamId,
                byteCount,
                JinguiAcceptedTransportH2FlowBudgetDecisionStatus.StreamClosed,
                false,
                false
            )
        }
        if (byteCount > _connectionSendBudget || byteCount > entry.sendBudget) {
            return snapshot(
                streamId,
                byteCount,
                JinguiAcceptedTransportH2FlowBudgetDecisionStatus.WaitingForWindowUpdate,
                false,
                true
            )
        }
        _connectionSendBudget -= byteCount
        entry.sendBudget -= byteCount
        snapshot(
            streamId,
            byteCount,
            JinguiAcceptedTransportH2FlowBudgetDecisionStatus.Sent,
            true,
            false
        )
    }

    public func classifyTimeout(
        streamId: Int64
    ): JinguiAcceptedTransportH2FlowBudgetDecisionSnapshot {
        let entry = ensureBudgetEntry(streamId)
        if (_connectionClosed) {
            return snapshot(
                streamId,
                0,
                JinguiAcceptedTransportH2FlowBudgetDecisionStatus.ConnectionClosed,
                false,
                false
            )
        }
        if (!streamSendSideOpen(streamId)) {
            return snapshot(
                streamId,
                0,
                JinguiAcceptedTransportH2FlowBudgetDecisionStatus.StreamClosed,
                false,
                false
            )
        }
        if (_connectionSendBudget <= 0 || entry.sendBudget <= 0) {
            return snapshot(
                streamId,
                0,
                JinguiAcceptedTransportH2FlowBudgetDecisionStatus.TimedOutWaitingForWindowUpdate,
                false,
                true
            )
        }
        snapshot(
            streamId,
            0,
            JinguiAcceptedTransportH2FlowBudgetDecisionStatus.NotFlowBudgetStall,
            false,
            false
        )
    }

    public func connectionSendBudget(): Int64 {
        _connectionSendBudget
    }

    public func streamSendBudget(streamId: Int64): Int64 {
        ensureBudgetEntry(streamId).sendBudget
    }

    public func lifecycleStateName(streamId: Int64): String {
        lifecycleStateNameOrUnopened(streamId)
    }

    func snapshot(
        streamId: Int64,
        byteCount: Int64,
        status: JinguiAcceptedTransportH2FlowBudgetDecisionStatus,
        canWrite: Bool,
        waitingForWindowUpdate: Bool
    ): JinguiAcceptedTransportH2FlowBudgetDecisionSnapshot {
        JinguiAcceptedTransportH2FlowBudgetDecisionSnapshot(
            streamId,
            byteCount,
            status,
            canWrite,
            waitingForWindowUpdate,
            false,
            _connectionSendBudget,
            streamSendBudget(streamId),
            lifecycleStateNameOrUnopened(streamId)
        )
    }

    func ensureBudgetEntry(
        streamId: Int64
    ): JinguiAcceptedTransportH2FlowBudgetStreamEntry {
        if (streamId <= 0) {
            throw Exception(
                "H2 flow budget model requires non-zero streamId, got ${streamId}"
            )
        }
        match (findBudgetEntry(streamId)) {
            case Some(entry) => entry
            case None =>
                if (!_lifecycleRegistry.hasStream(streamId)) {
                    throw Exception(
                        "H2 flow budget model requires stream lifecycle before stream budget, streamId=${streamId}"
                    )
                }
                let entry = JinguiAcceptedTransportH2FlowBudgetStreamEntry(
                    streamId,
                    _defaultInitialStreamSendBudget
                )
                _streamBudgets.add(entry)
                entry
        }
    }

    func findBudgetEntry(
        streamId: Int64
    ): ?JinguiAcceptedTransportH2FlowBudgetStreamEntry {
        for (entry in _streamBudgets) {
            if (entry.streamId == streamId) {
                return Some(entry)
            }
        }
        None
    }

    func ensureLifecycleCanReceiveWindowUpdate(streamId: Int64): Unit {
        if (!_lifecycleRegistry.hasStream(streamId)) {
            throw Exception(
                "H2 flow budget model requires stream lifecycle before WINDOW_UPDATE, streamId=${streamId}"
            )
        }
        let state = _lifecycleRegistry.stateOf(streamId)
        if (
            state == JinguiAcceptedTransportH2StreamLifecycleState.Reset ||
            state == JinguiAcceptedTransportH2StreamLifecycleState.Closed
        ) {
            throw Exception(
                "H2 flow budget model cannot apply WINDOW_UPDATE to streamId=${streamId} in state=${state.toString()}"
            )
        }
    }

    func streamSendSideOpen(streamId: Int64): Bool {
        if (!_lifecycleRegistry.hasStream(streamId)) {
            return false
        }
        let state = _lifecycleRegistry.stateOf(streamId)
        !(
            state == JinguiAcceptedTransportH2StreamLifecycleState.HalfClosedLocal ||
            state == JinguiAcceptedTransportH2StreamLifecycleState.Reset ||
            state == JinguiAcceptedTransportH2StreamLifecycleState.Closed
        )
    }

    func lifecycleStateNameOrUnopened(streamId: Int64): String {
        if (_lifecycleRegistry.hasStream(streamId)) {
            return _lifecycleRegistry.stateOf(streamId).toString()
        }
        "unopened"
    }

    func ensureNonNegativeBudget(
        value: Int64,
        label: String
    ): Unit {
        if (value < 0) {
            throw Exception(
                "H2 flow budget model requires non-negative ${label} budget, got ${value}"
            )
        }
    }
}

/// Writer-facing gate for H2 DATA send-window claims.
///
/// Future H2 writers should depend on this seam instead of reaching into the
/// flow-budget model. A failed claim is non-lossy; only `Sent` spends budget.
public class JinguiAcceptedTransportH2WriterFlowGate {
    let _model: JinguiAcceptedTransportH2FlowBudgetModel

    public init(
        model: JinguiAcceptedTransportH2FlowBudgetModel
    ) {
        this._model = model
    }

    public func tryClaimDataWrite(
        streamId: Int64,
        byteCount: Int64
    ): JinguiAcceptedTransportH2FlowBudgetDecisionSnapshot {
        _model.trySpendData(streamId, byteCount)
    }

    public func classifyWriteTimeout(
        streamId: Int64
    ): JinguiAcceptedTransportH2FlowBudgetDecisionSnapshot {
        _model.classifyTimeout(streamId)
    }
}

class JinguiAcceptedTransportH2WriterFlowQueueEntry {
    let streamId: Int64
    let endStreamWhenDrained: Bool
    var remainingByteCount: Int64

    init(
        streamId: Int64,
        byteCount: Int64,
        endStreamWhenDrained: Bool
    ) {
        this.streamId = streamId
        this.endStreamWhenDrained = endStreamWhenDrained
        this.remainingByteCount = byteCount
    }
}

public class JinguiAcceptedTransportH2WriterFlowQueueDrainSnapshot {
    public let drained: Bool
    public let endStream: Bool
    public let waitingForWindowUpdate: Bool
    public let streamId: Int64
    public let byteCount: Int64
    public let remainingByteCount: Int64
    public let pendingCount: Int64
    public let decision: JinguiAcceptedTransportH2FlowBudgetDecisionSnapshot

    public init(
        drained: Bool,
        endStream: Bool,
        waitingForWindowUpdate: Bool,
        streamId: Int64,
        byteCount: Int64,
        remainingByteCount: Int64,
        pendingCount: Int64,
        decision: JinguiAcceptedTransportH2FlowBudgetDecisionSnapshot
    ) {
        this.drained = drained
        this.endStream = endStream
        this.waitingForWindowUpdate = waitingForWindowUpdate
        this.streamId = streamId
        this.byteCount = byteCount
        this.remainingByteCount = remainingByteCount
        this.pendingCount = pendingCount
        this.decision = decision
    }
}

/// Minimal non-lossy queue attachment for H2 writer DATA budget claims.
///
/// This queue does not write to a socket. It only proves that a writer-owned
/// DATA entry remains pending when the flow gate asks for WINDOW_UPDATE.
public class JinguiAcceptedTransportH2WriterFlowQueue {
    let _gate: JinguiAcceptedTransportH2WriterFlowGate
    let _entries = ArrayList<JinguiAcceptedTransportH2WriterFlowQueueEntry>()

    public init(
        gate: JinguiAcceptedTransportH2WriterFlowGate
    ) {
        this._gate = gate
    }

    public func enqueueDataLength(
        streamId: Int64,
        byteCount: Int64
    ): Int64 {
        enqueueDataLengthWithEndStream(streamId, byteCount, false)
    }

    public func enqueueDataLengthWithEndStream(
        streamId: Int64,
        byteCount: Int64,
        endStreamWhenDrained: Bool
    ): Int64 {
        if (streamId <= 0) {
            throw Exception(
                "H2 writer flow queue requires non-zero streamId, got ${streamId}"
            )
        }
        if (byteCount <= 0) {
            throw Exception(
                "H2 writer flow queue requires positive byteCount, got ${byteCount}"
            )
        }
        _entries.add(
            JinguiAcceptedTransportH2WriterFlowQueueEntry(
                streamId,
                byteCount,
                endStreamWhenDrained
            )
        )
        _entries.size
    }

    public func pendingCount(): Int64 {
        _entries.size
    }

    public func headRemainingByteCount(): Int64 {
        if (_entries.size == 0) {
            throw Exception("H2 writer flow queue cannot inspect empty queue")
        }
        _entries[0].remainingByteCount
    }

    public func tryDrainHead(
    ): JinguiAcceptedTransportH2WriterFlowQueueDrainSnapshot {
        if (_entries.size == 0) {
            throw Exception("H2 writer flow queue cannot drain empty queue")
        }
        tryDrainHeadChunk(_entries[0].remainingByteCount)
    }

    public func tryDrainHeadChunk(
        maxFrameByteCount: Int64
    ): JinguiAcceptedTransportH2WriterFlowQueueDrainSnapshot {
        if (_entries.size == 0) {
            throw Exception("H2 writer flow queue cannot drain empty queue")
        }
        if (maxFrameByteCount <= 0) {
            throw Exception(
                "H2 writer flow queue requires positive maxFrameByteCount, got ${maxFrameByteCount}"
            )
        }
        let entry = _entries[0]
        let claimByteCount = claimByteCountFor(
            entry.remainingByteCount,
            maxFrameByteCount
        )
        let decision =
            _gate.tryClaimDataWrite(entry.streamId, claimByteCount)
        if (decision.canWrite) {
            entry.remainingByteCount -= claimByteCount
            let remainingAfterDrain = entry.remainingByteCount
            if (entry.remainingByteCount <= 0) {
                let _ = _entries.remove(at: Int64(0))
            }
            return JinguiAcceptedTransportH2WriterFlowQueueDrainSnapshot(
                true,
                remainingAfterDrain <= 0 && entry.endStreamWhenDrained,
                false,
                entry.streamId,
                claimByteCount,
                remainingAfterDrain,
                _entries.size,
                decision
            )
        }
        JinguiAcceptedTransportH2WriterFlowQueueDrainSnapshot(
            false,
            false,
            decision.waitingForWindowUpdate,
            entry.streamId,
            claimByteCount,
            entry.remainingByteCount,
            _entries.size,
            decision
        )
    }

    func claimByteCountFor(
        remainingByteCount: Int64,
        maxFrameByteCount: Int64
    ): Int64 {
        if (remainingByteCount < maxFrameByteCount) {
            return remainingByteCount
        }
        maxFrameByteCount
    }
}

public func buildJinguiAcceptedTransportH2WriterDataFrameWireSnapshot(
    drain: JinguiAcceptedTransportH2WriterFlowQueueDrainSnapshot,
    payload: Array<Byte>
): JinguiAcceptedTransportH2FrameWireSnapshot {
    if (!drain.drained) {
        throw Exception(
            "H2 writer DATA frame snapshot requires a drained writer chunk, streamId=${drain.streamId}"
        )
    }
    if (payload.size != drain.byteCount) {
        throw Exception(
            "H2 writer DATA frame payload length mismatch, expected=${drain.byteCount}, actual=${payload.size}, streamId=${drain.streamId}"
        )
    }
    let flags = if (drain.endStream) {
        UInt8(0x1)
    } else {
        UInt8(0x0)
    }
    JinguiAcceptedTransportH2FrameWireSnapshot(
        drain.byteCount,
        UInt8(0x0),
        flags,
        drain.streamId,
        payload
    )
}

public func encodeJinguiAcceptedTransportH2DataFrameWireSnapshot(
    frame: JinguiAcceptedTransportH2FrameWireSnapshot
): Array<Byte> {
    if (frame.frameType != UInt8(0x0)) {
        throw Exception(
            "H2 DATA frame encoder requires DATA frame type=0, got type=${Int64(frame.frameType)}"
        )
    }
    if (frame.streamId <= 0) {
        throw Exception(
            "H2 DATA frame encoder requires non-zero streamId, got ${frame.streamId}"
        )
    }
    encodeJinguiAcceptedTransportH2FrameWireSnapshot(frame)
}

public type JinguiAcceptedTransportH2PeerControlFramePoller =
    () -> Array<JinguiAcceptedTransportH2FrameWireSnapshot>

public class JinguiAcceptedTransportH2ResponseRetryWindowUpdateFrameResolution {
    public let frames: Array<JinguiAcceptedTransportH2FrameWireSnapshot>
    public let requestFrameCount: Int64
    public let explicitFrameCount: Int64
    public let polledFrameCount: Int64
    public let pollerAttemptCount: Int64

    public init(
        frames: Array<JinguiAcceptedTransportH2FrameWireSnapshot>,
        requestFrameCount: Int64,
        explicitFrameCount: Int64,
        polledFrameCount: Int64,
        pollerAttemptCount: Int64
    ) {
        this.frames = frames
        this.requestFrameCount = requestFrameCount
        this.explicitFrameCount = explicitFrameCount
        this.polledFrameCount = polledFrameCount
        this.pollerAttemptCount = pollerAttemptCount
    }
}

public class JinguiAcceptedTransportH2ResponseTurnSchedulerTraceSnapshot {
    public let schedulerOwner: String
    public let responseWriterOwner: String
    public let peerControlReadOwner: String
    public let streamId: Int64
    public let queuedBodyWriteCount: Int64
    public let queuedBodyByteCount: Int64
    public let writeAttemptCount: Int64
    public let peerControlPollRoundCount: Int64
    public let observedWindowUpdateFrameCount: Int64
    public let recoveryRoundCount: Int64
    public let requestWindowUpdateFrameCount: Int64
    public let explicitWindowUpdateFrameCount: Int64
    public let polledWindowUpdateFrameCount: Int64
    public let pollerAttemptCount: Int64
    public let committedBodyWriteCount: Int64
    public let committedBodyByteCount: Int64
    public let committedDataFrameCount: Int64
    public let remainingBodyByteCount: Int64
    public let completed: Bool
    public let closeReason: String

    public init(
        schedulerOwner: String,
        responseWriterOwner: String,
        peerControlReadOwner: String,
        streamId: Int64,
        queuedBodyWriteCount: Int64,
        queuedBodyByteCount: Int64,
        writeAttemptCount: Int64,
        peerControlPollRoundCount: Int64,
        observedWindowUpdateFrameCount: Int64,
        recoveryRoundCount: Int64,
        requestWindowUpdateFrameCount: Int64,
        explicitWindowUpdateFrameCount: Int64,
        polledWindowUpdateFrameCount: Int64,
        pollerAttemptCount: Int64,
        committedBodyWriteCount: Int64,
        committedBodyByteCount: Int64,
        committedDataFrameCount: Int64,
        remainingBodyByteCount: Int64,
        completed: Bool,
        closeReason: String
    ) {
        this.schedulerOwner = schedulerOwner
        this.responseWriterOwner = responseWriterOwner
        this.peerControlReadOwner = peerControlReadOwner
        this.streamId = streamId
        this.queuedBodyWriteCount = queuedBodyWriteCount
        this.queuedBodyByteCount = queuedBodyByteCount
        this.writeAttemptCount = writeAttemptCount
        this.peerControlPollRoundCount = peerControlPollRoundCount
        this.observedWindowUpdateFrameCount = observedWindowUpdateFrameCount
        this.recoveryRoundCount = recoveryRoundCount
        this.requestWindowUpdateFrameCount = requestWindowUpdateFrameCount
        this.explicitWindowUpdateFrameCount = explicitWindowUpdateFrameCount
        this.polledWindowUpdateFrameCount = polledWindowUpdateFrameCount
        this.pollerAttemptCount = pollerAttemptCount
        this.committedBodyWriteCount = committedBodyWriteCount
        this.committedBodyByteCount = committedBodyByteCount
        this.committedDataFrameCount = committedDataFrameCount
        this.remainingBodyByteCount = remainingBodyByteCount
        this.completed = completed
        this.closeReason = closeReason
    }
}

public class JinguiAcceptedTransportH2RuntimeProgressReadout {
    public let responseTurnProgressAccepted: Bool
    public let h2RuntimeProofContinuationAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
    public let status: String
    public let decision: String
    public let streamId: Int64
    public let committedDataFrameCount: Int64
    public let recoveryRoundCount: Int64
    public let polledWindowUpdateFrameCount: Int64
    public let remainingBodyByteCount: Int64
    public let closeReason: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        responseTurnProgressAccepted: Bool,
        h2RuntimeProofContinuationAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
        status: String,
        decision: String,
        streamId: Int64,
        committedDataFrameCount: Int64,
        recoveryRoundCount: Int64,
        polledWindowUpdateFrameCount: Int64,
        remainingBodyByteCount: Int64,
        closeReason: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.responseTurnProgressAccepted = responseTurnProgressAccepted
        this.h2RuntimeProofContinuationAllowed =
            h2RuntimeProofContinuationAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.status = status
        this.decision = decision
        this.streamId = streamId
        this.committedDataFrameCount = committedDataFrameCount
        this.recoveryRoundCount = recoveryRoundCount
        this.polledWindowUpdateFrameCount = polledWindowUpdateFrameCount
        this.remainingBodyByteCount = remainingBodyByteCount
        this.closeReason = closeReason
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2RuntimeProgressReadout(
    snapshot: JinguiAcceptedTransportH2ResponseTurnSchedulerTraceSnapshot
): JinguiAcceptedTransportH2RuntimeProgressReadout {
    let blockers =
        jinguiAcceptedTransportH2RuntimeProgressReadoutBlockers(snapshot)
    let nonClaims = jinguiAcceptedTransportH2RuntimeProgressReadoutNonClaims()
    if (blockers.size == 0) {
        return JinguiAcceptedTransportH2RuntimeProgressReadout(
            true,
            true,
            false,
            "ready-for-bounded-h2-runtime-proof-continuation",
            "consume-response-turn-progress-without-closure-claim",
            snapshot.streamId,
            snapshot.committedDataFrameCount,
            snapshot.recoveryRoundCount,
            snapshot.polledWindowUpdateFrameCount,
            snapshot.remainingBodyByteCount,
            snapshot.closeReason,
            [],
            nonClaims,
            "open the next bounded H2 runtime packet; closure still needs browser, h2spec, scheduler fairness, and release-grade proof",
            "QUIC can reuse this response-turn progress readout before claiming stream runtime closure"
        )
    }
    JinguiAcceptedTransportH2RuntimeProgressReadout(
        false,
        false,
        false,
        "blocked-h2-response-turn-progress",
        "repair-response-turn-progress-before-runtime-continuation",
        snapshot.streamId,
        snapshot.committedDataFrameCount,
        snapshot.recoveryRoundCount,
        snapshot.polledWindowUpdateFrameCount,
        snapshot.remainingBodyByteCount,
        snapshot.closeReason,
        blockers,
        nonClaims,
        "keep the packet in response-turn repair mode until the scheduler trace completes without close reason",
        "QUIC should treat incomplete response-turn progress as stream writer repair evidence, not runtime closure evidence"
    )
}

func jinguiAcceptedTransportH2RuntimeProgressReadoutBlockers(
    snapshot: JinguiAcceptedTransportH2ResponseTurnSchedulerTraceSnapshot
): Array<String> {
    let blockers = ArrayList<String>()
    if (!snapshot.completed) {
        blockers.add("RESPONSE_TURN_NOT_COMPLETED")
    }
    if (snapshot.closeReason.size > 0) {
        blockers.add("CLOSE_REASON:${snapshot.closeReason}")
    }
    if (snapshot.queuedBodyWriteCount > snapshot.committedBodyWriteCount) {
        blockers.add("BODY_WRITE_NOT_FULLY_COMMITTED")
    }
    if (snapshot.remainingBodyByteCount > 0) {
        blockers.add("BODY_BYTES_REMAINING:${snapshot.remainingBodyByteCount}")
    }
    if (snapshot.committedDataFrameCount <= 0) {
        blockers.add("NO_DATA_FRAME_COMMITTED")
    }
    let acceptedRecoveryFrameCount =
        snapshot.requestWindowUpdateFrameCount +
        snapshot.explicitWindowUpdateFrameCount +
        snapshot.polledWindowUpdateFrameCount
    if (
        snapshot.recoveryRoundCount > 0 &&
        acceptedRecoveryFrameCount <= 0
    ) {
        blockers.add("NO_ACCEPTED_RECOVERY_WINDOW_UPDATE")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeProgressReadoutNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_BROWSER_REPLAY_CLAIM",
        "NO_H2SPEC_CLAIM",
        "NO_SCHEDULER_FAIRNESS_CLAIM",
        "NO_RELEASE_CLAIM",
    ]
}

public class JinguiAcceptedTransportH2ResponseTurnSchedulerTrace {
    let _streamId: Int64
    public var queuedBodyWriteCount: Int64 = 0
    public var queuedBodyByteCount: Int64 = 0
    public var writeAttemptCount: Int64 = 0
    public var peerControlPollRoundCount: Int64 = 0
    public var observedWindowUpdateFrameCount: Int64 = 0
    public var recoveryRoundCount: Int64 = 0
    public var requestWindowUpdateFrameCount: Int64 = 0
    public var explicitWindowUpdateFrameCount: Int64 = 0
    public var polledWindowUpdateFrameCount: Int64 = 0
    public var pollerAttemptCount: Int64 = 0
    public var committedBodyWriteCount: Int64 = 0
    public var committedBodyByteCount: Int64 = 0
    public var committedDataFrameCount: Int64 = 0
    public var completed: Bool = false
    public var closeReason: String = ""

    public init(streamId: Int64) {
        this._streamId = streamId
    }

    public func recordQueuedBodyWrite(byteCount!: Int64 = 0): Unit {
        queuedBodyWriteCount += 1
        queuedBodyByteCount += byteCount
    }

    public func recordWriteAttempt(): Unit {
        writeAttemptCount += 1
    }

    public func recordPeerControlPollRound(
        frames: Array<JinguiAcceptedTransportH2FrameWireSnapshot>
    ): Unit {
        peerControlPollRoundCount += 1
        observedWindowUpdateFrameCount += frames.size
    }

    public func recordWindowUpdateFrameResolution(
        resolution: JinguiAcceptedTransportH2ResponseRetryWindowUpdateFrameResolution
    ): Unit {
        recoveryRoundCount += 1
        requestWindowUpdateFrameCount += resolution.requestFrameCount
        explicitWindowUpdateFrameCount += resolution.explicitFrameCount
        polledWindowUpdateFrameCount += resolution.polledFrameCount
        pollerAttemptCount += resolution.pollerAttemptCount
    }

    public func recordCommittedBodyWrite(byteCount!: Int64 = 0): Unit {
        committedBodyWriteCount += 1
        committedBodyByteCount += byteCount
    }

    public func recordCommittedBodyBytes(byteCount: Int64): Unit {
        committedBodyByteCount += byteCount
    }

    public func recordCommittedDataFrame(): Unit {
        committedDataFrameCount += 1
    }

    public func recordClose(reason: String): Unit {
        closeReason = reason
    }

    public func markCompleted(): Unit {
        completed = true
    }

    public func remainingBodyByteCount(): Int64 {
        let remaining = queuedBodyByteCount - committedBodyByteCount
        if (remaining > 0) {
            return remaining
        }
        0
    }

    public func snapshot(
    ): JinguiAcceptedTransportH2ResponseTurnSchedulerTraceSnapshot {
        JinguiAcceptedTransportH2ResponseTurnSchedulerTraceSnapshot(
            "accepted-socket-h2-response-turn-scheduler",
            "accepted-socket-response-writer-handoff",
            "response-window-update-poller",
            _streamId,
            queuedBodyWriteCount,
            queuedBodyByteCount,
            writeAttemptCount,
            peerControlPollRoundCount,
            observedWindowUpdateFrameCount,
            recoveryRoundCount,
            requestWindowUpdateFrameCount,
            explicitWindowUpdateFrameCount,
            polledWindowUpdateFrameCount,
            pollerAttemptCount,
            committedBodyWriteCount,
            committedBodyByteCount,
            committedDataFrameCount,
            remainingBodyByteCount(),
            completed,
            closeReason
        )
    }
}

public func encodeJinguiAcceptedTransportH2FrameWireSnapshot(
    frame: JinguiAcceptedTransportH2FrameWireSnapshot
): Array<Byte> {
    if (frame.streamId <= 0) {
        throw Exception(
            "H2 frame encoder requires non-zero streamId, got ${frame.streamId}"
        )
    }
    if (frame.payloadLength != frame.payload.size) {
        throw Exception(
            "H2 frame encoder payload length mismatch, expected=${frame.payloadLength}, actual=${frame.payload.size}, streamId=${frame.streamId}"
        )
    }
    if (frame.payloadLength < 0 || frame.payloadLength > 0xffffff) {
        throw Exception(
            "H2 frame encoder payload length exceeds 24-bit frame header, got ${frame.payloadLength}"
        )
    }
    let out = ArrayList<Byte>()
    let payloadLen = frame.payloadLength
    out.add(UInt8((payloadLen >> 16) & 0xff))
    out.add(UInt8((payloadLen >> 8) & 0xff))
    out.add(UInt8(payloadLen & 0xff))
    out.add(frame.frameType)
    out.add(frame.flags)
    out.add(UInt8((frame.streamId >> 24) & 0x7f))
    out.add(UInt8((frame.streamId >> 16) & 0xff))
    out.add(UInt8((frame.streamId >> 8) & 0xff))
    out.add(UInt8(frame.streamId & 0xff))
    for (b in frame.payload) {
        out.add(b)
    }
    out.toArray()
}

public func buildJinguiAcceptedTransportH2ResponseHeadersFrameWireSnapshot(
    streamId: Int64,
    status: UInt16,
    headers: Array<ServerJinguiAcceptedTransportResponseHeaderField>,
    endStream!: Bool = false
): JinguiAcceptedTransportH2FrameWireSnapshot {
    if (streamId <= 0) {
        throw Exception(
            "H2 response HEADERS frame snapshot requires non-zero streamId, got ${streamId}"
        )
    }
    let payload = buildJinguiAcceptedTransportH2ResponseHeaderBlockFragment(
        status,
        headers
    )
    let flags = if (endStream) {
        UInt8(0x5)
    } else {
        UInt8(0x4)
    }
    JinguiAcceptedTransportH2FrameWireSnapshot(
        payload.size,
        UInt8(0x1),
        flags,
        streamId,
        payload
    )
}

func buildJinguiAcceptedTransportH2ResponseHeaderBlockFragment(
    status: UInt16,
    headers: Array<ServerJinguiAcceptedTransportResponseHeaderField>
): Array<Byte> {
    let out = ArrayList<Byte>()
    let statusStaticIndex =
        serverJinguiAcceptedTransportH2ResponseStatusStaticIndex(status)
    if (statusStaticIndex > 0) {
        appendJinguiAcceptedTransportH2HpackIndexedHeaderField(
            out,
            statusStaticIndex
        )
    } else {
        appendJinguiAcceptedTransportH2HpackLiteralWithoutIndexingIndexedName(
            out,
            8,
            "${status}"
        )
    }
    appendJinguiAcceptedTransportH2CapturedResponseHeaders(out, headers)
    out.toArray()
}

func serverJinguiAcceptedTransportH2ResponseStatusStaticIndex(
    status: UInt16
): Int64 {
    if (status == UInt16(200)) {
        return 8
    }
    if (status == UInt16(204)) {
        return 9
    }
    if (status == UInt16(206)) {
        return 10
    }
    if (status == UInt16(304)) {
        return 11
    }
    if (status == UInt16(400)) {
        return 12
    }
    if (status == UInt16(404)) {
        return 13
    }
    if (status == UInt16(500)) {
        return 14
    }
    0
}

func appendJinguiAcceptedTransportH2CapturedResponseHeaders(
    out: ArrayList<Byte>,
    headers: Array<ServerJinguiAcceptedTransportResponseHeaderField>
): Unit {
    for (header in headers) {
        appendJinguiAcceptedTransportH2ResponseHeaderField(
            out,
            header.name,
            header.value
        )
    }
}

func appendJinguiAcceptedTransportH2ResponseHeaderField(
    out: ArrayList<Byte>,
    name: String,
    value: String
): Unit {
    let normalizedName = name.trimAscii().toAsciiLower()
    if (shouldSkipJinguiAcceptedTransportH2ResponseHeader(normalizedName)) {
        return
    }
    let staticNameIndex =
        serverJinguiAcceptedTransportH2ResponseHeaderStaticNameIndex(
            normalizedName
        )
    if (staticNameIndex > 0) {
        appendJinguiAcceptedTransportH2HpackLiteralWithoutIndexingIndexedName(
            out,
            staticNameIndex,
            value
        )
        return
    }
    appendJinguiAcceptedTransportH2HpackLiteralWithoutIndexingNewName(
        out,
        normalizedName,
        value
    )
}

func serverJinguiAcceptedTransportH2ResponseHeaderStaticNameIndex(
    name: String
): Int64 {
    if (name == "cache-control") {
        return 24
    }
    if (name == "content-length") {
        return 28
    }
    if (name == "content-type") {
        return 31
    }
    if (name == "server") {
        return 54
    }
    0
}

func shouldSkipJinguiAcceptedTransportH2ResponseHeader(name: String): Bool {
    name == "" ||
    serverJinguiAcceptedTransportH2FieldNameIsPseudo(name) ||
    name == "connection" ||
    name == "keep-alive" ||
    name == "proxy-connection" ||
    name == "te" ||
    name == "transfer-encoding" ||
    name == "upgrade"
}

func appendJinguiAcceptedTransportH2HpackLiteralWithoutIndexingIndexedName(
    out: ArrayList<Byte>,
    nameStaticIndex: Int64,
    value: String
): Unit {
    if (nameStaticIndex <= 0) {
        throw Exception(
            "bounded H2 response HPACK indexed-name literal requires positive static index, got ${nameStaticIndex}"
        )
    }
    appendJinguiAcceptedTransportH2HpackIntegerWithPrefix(
        out,
        4,
        UInt8(0),
        nameStaticIndex
    )
    appendJinguiAcceptedTransportH2HpackBoundedAsciiString(out, value)
}

func appendJinguiAcceptedTransportH2HpackIndexedHeaderField(
    out: ArrayList<Byte>,
    staticIndex: Int64
): Unit {
    if (staticIndex <= 0) {
        throw Exception(
            "bounded H2 response HPACK indexed field requires positive static index, got ${staticIndex}"
        )
    }
    appendJinguiAcceptedTransportH2HpackIntegerWithPrefix(
        out,
        7,
        UInt8(0x80),
        staticIndex
    )
}

func appendJinguiAcceptedTransportH2HpackIntegerWithPrefix(
    out: ArrayList<Byte>,
    prefixBits: Int64,
    prefixBase: UInt8,
    value: Int64
): Unit {
    let prefixMask =
        serverJinguiAcceptedTransportH2HpackPrefixMask(prefixBits)
    if (value < prefixMask) {
        out.add(prefixBase | UInt8(value & prefixMask))
        return
    }
    out.add(prefixBase | UInt8(prefixMask))
    var rest = value - prefixMask
    while (rest >= 128) {
        out.add(UInt8((rest & 0x7f) | 0x80))
        rest = rest >> 7
    }
    out.add(UInt8(rest & 0x7f))
}

func appendJinguiAcceptedTransportH2HpackLiteralWithoutIndexingNewName(
    out: ArrayList<Byte>,
    name: String,
    value: String
): Unit {
    out.add(UInt8(0))
    appendJinguiAcceptedTransportH2HpackBoundedAsciiString(out, name)
    appendJinguiAcceptedTransportH2HpackBoundedAsciiString(out, value)
}

func appendJinguiAcceptedTransportH2HpackBoundedAsciiString(
    out: ArrayList<Byte>,
    text: String
): Unit {
    let bytes = serverEngineUInt8ToByteArray(text.toArray())
    if (bytes.size > 127) {
        throw Exception(
            "bounded H2 response HPACK string exceeds one-octet non-Huffman length, size=${bytes.size}"
        )
    }
    out.add(UInt8(bytes.size & 0x7f))
    for (b in bytes) {
        out.add(b)
    }
}

public interface JinguiAcceptedTransportH2FrameWireWriterSink {
    func writeFrameWire(frameWire: Array<Byte>): Int64
}

public class JinguiAcceptedTransportH2FrameWireBufferSink <: JinguiAcceptedTransportH2FrameWireWriterSink {
    let _frames = ArrayList<Array<Byte>>()

    public init() {}

    public override func writeFrameWire(frameWire: Array<Byte>): Int64 {
        _frames.add(cloneServerEngineByteWindow(frameWire, 0, frameWire.size))
        frameWire.size
    }

    public func frameCount(): Int64 {
        _frames.size
    }

    public func frameWireAt(index: Int64): Array<Byte> {
        if (index < 0 || index >= _frames.size) {
            throw Exception(
                "H2 frame wire buffer sink index out of range, index=${index}, size=${_frames.size}"
            )
        }
        cloneServerEngineByteWindow(_frames[index], 0, _frames[index].size)
    }

    public func lastFrameWire(): Array<Byte> {
        if (_frames.size == 0) {
            throw Exception("H2 frame wire buffer sink is empty")
        }
        frameWireAt(_frames.size - 1)
    }
}

public class JinguiAcceptedTransportH2FrameWireFunctionSink <: JinguiAcceptedTransportH2FrameWireWriterSink {
    let _write: (Array<Byte>) -> Int64

    public init(write: (Array<Byte>) -> Int64) {
        this._write = write
    }

    public override func writeFrameWire(frameWire: Array<Byte>): Int64 {
        _write(cloneServerEngineByteWindow(frameWire, 0, frameWire.size))
    }
}

public class JinguiAcceptedTransportH2SocketWriteDryRunResult {
    public let statusName: String
    public let attempted: Bool
    public let completed: Bool
    public let byteCount: Int64
    public let writtenByteCount: Int64
    public let failureReason: String

    public init(
        statusName: String,
        attempted: Bool,
        completed: Bool,
        byteCount: Int64,
        writtenByteCount: Int64,
        failureReason: String
    ) {
        this.statusName = statusName
        this.attempted = attempted
        this.completed = completed
        this.byteCount = byteCount
        this.writtenByteCount = writtenByteCount
        this.failureReason = failureReason
    }
}

public class JinguiAcceptedTransportH2FrameWireSocketDryRunSink <: JinguiAcceptedTransportH2FrameWireWriterSink {
    let _write: (Array<Byte>) -> Int64
    var _writeCalls: Int64 = 0
    var _lastResult = JinguiAcceptedTransportH2SocketWriteDryRunResult(
        "not-run",
        false,
        false,
        0,
        0,
        "socket dry-run has not attempted a write"
    )

    public init(write: (Array<Byte>) -> Int64) {
        this._write = write
    }

    public override func writeFrameWire(frameWire: Array<Byte>): Int64 {
        let frozen = cloneServerEngineByteWindow(frameWire, 0, frameWire.size)
        _writeCalls += 1
        let written = _write(frozen)
        if (written != frozen.size) {
            _lastResult = JinguiAcceptedTransportH2SocketWriteDryRunResult(
                "incomplete-write",
                true,
                false,
                frozen.size,
                written,
                "socket dry-run expected complete frame write"
            )
            throw Exception(
                "H2 frame wire socket dry-run incomplete write, expected=${frozen.size}, actual=${written}"
            )
        }
        _lastResult = JinguiAcceptedTransportH2SocketWriteDryRunResult(
            "complete-write",
            true,
            true,
            frozen.size,
            written,
            ""
        )
        written
    }

    public func writeCalls(): Int64 {
        _writeCalls
    }

    public func lastResult(): JinguiAcceptedTransportH2SocketWriteDryRunResult {
        _lastResult
    }
}

public class JinguiAcceptedTransportH2AcceptedTransportWriterAttachDryRunResult {
    public let transportId: String
    public let transportKind: String
    public let statusName: String
    public let attempted: Bool
    public let completed: Bool
    public let byteCount: Int64
    public let writtenByteCount: Int64
    public let writeCalls: Int64
    public let failureReason: String

    public init(
        transportId: String,
        transportKind: String,
        statusName: String,
        attempted: Bool,
        completed: Bool,
        byteCount: Int64,
        writtenByteCount: Int64,
        writeCalls: Int64,
        failureReason: String
    ) {
        this.transportId = transportId
        this.transportKind = transportKind
        this.statusName = statusName
        this.attempted = attempted
        this.completed = completed
        this.byteCount = byteCount
        this.writtenByteCount = writtenByteCount
        this.writeCalls = writeCalls
        this.failureReason = failureReason
    }
}

func buildJinguiAcceptedTransportH2AcceptedTransportWriterAttachDryRunResult(
    transport: ServerJinguiAcceptedTransportDescriptorSnapshot,
    socketResult: JinguiAcceptedTransportH2SocketWriteDryRunResult,
    writeCalls: Int64
): JinguiAcceptedTransportH2AcceptedTransportWriterAttachDryRunResult {
    let statusName = if (socketResult.completed) {
        "attached-complete-write"
    } else {
        "attached-incomplete-write"
    }
    JinguiAcceptedTransportH2AcceptedTransportWriterAttachDryRunResult(
        transport.transportId,
        transport.transportKind,
        statusName,
        socketResult.attempted,
        socketResult.completed,
        socketResult.byteCount,
        socketResult.writtenByteCount,
        writeCalls,
        socketResult.failureReason
    )
}

public func attachJinguiAcceptedTransportH2DataFrameWriterDryRun(
    transport: ServerJinguiAcceptedTransportDescriptorSnapshot,
    frame: JinguiAcceptedTransportH2FrameWireSnapshot,
    write: (Array<Byte>) -> Int64
): JinguiAcceptedTransportH2AcceptedTransportWriterAttachDryRunResult {
    let sink = JinguiAcceptedTransportH2FrameWireSocketDryRunSink(write)
    try {
        let _ = writeJinguiAcceptedTransportH2DataFrameWireSnapshotToSink(
            frame,
            sink
        )
    } catch (e: Exception) {
        let socketResult = sink.lastResult()
        if (!socketResult.attempted) {
            throw e
        }
        return buildJinguiAcceptedTransportH2AcceptedTransportWriterAttachDryRunResult(
            transport,
            socketResult,
            sink.writeCalls()
        )
    }
    buildJinguiAcceptedTransportH2AcceptedTransportWriterAttachDryRunResult(
        transport,
        sink.lastResult(),
        sink.writeCalls()
    )
}

public class JinguiAcceptedTransportH2ApplicationDataWriterDryRunResult {
    public let responseWriterSurface: String
    public let transportId: String
    public let transportKind: String
    public let attachStatusName: String
    public let statusName: String
    public let attempted: Bool
    public let completed: Bool
    public let byteCount: Int64
    public let writtenByteCount: Int64
    public let writeCalls: Int64
    public let failureReason: String

    public init(
        responseWriterSurface: String,
        transportId: String,
        transportKind: String,
        attachStatusName: String,
        statusName: String,
        attempted: Bool,
        completed: Bool,
        byteCount: Int64,
        writtenByteCount: Int64,
        writeCalls: Int64,
        failureReason: String
    ) {
        this.responseWriterSurface = responseWriterSurface
        this.transportId = transportId
        this.transportKind = transportKind
        this.attachStatusName = attachStatusName
        this.statusName = statusName
        this.attempted = attempted
        this.completed = completed
        this.byteCount = byteCount
        this.writtenByteCount = writtenByteCount
        this.writeCalls = writeCalls
        this.failureReason = failureReason
    }
}

public func dryRunJinguiAcceptedTransportH2ApplicationDataResponseWriter(
    responseWriterSurface: String,
    transport: ServerJinguiAcceptedTransportDescriptorSnapshot,
    frame: JinguiAcceptedTransportH2FrameWireSnapshot,
    write: (Array<Byte>) -> Int64
): JinguiAcceptedTransportH2ApplicationDataWriterDryRunResult {
    let attach =
        attachJinguiAcceptedTransportH2DataFrameWriterDryRun(
            transport,
            frame,
            write
        )
    let statusName = if (attach.completed) {
        "application-data-writer-complete"
    } else {
        "application-data-writer-incomplete"
    }
    JinguiAcceptedTransportH2ApplicationDataWriterDryRunResult(
        responseWriterSurface,
        attach.transportId,
        attach.transportKind,
        attach.statusName,
        statusName,
        attach.attempted,
        attach.completed,
        attach.byteCount,
        attach.writtenByteCount,
        attach.writeCalls,
        attach.failureReason
    )
}

public class JinguiAcceptedTransportH2ResponseTransportWriterAdapterDryRunResult {
    public let responseWriterSurface: String
    public let transportId: String
    public let transportKind: String
    public let statusName: String
    public let attempted: Bool
    public let completed: Bool
    public let byteCount: Int64
    public let writeCalls: Int64
    public let failureReason: String

    public init(
        responseWriterSurface: String,
        transportId: String,
        transportKind: String,
        statusName: String,
        attempted: Bool,
        completed: Bool,
        byteCount: Int64,
        writeCalls: Int64,
        failureReason: String
    ) {
        this.responseWriterSurface = responseWriterSurface
        this.transportId = transportId
        this.transportKind = transportKind
        this.statusName = statusName
        this.attempted = attempted
        this.completed = completed
        this.byteCount = byteCount
        this.writeCalls = writeCalls
        this.failureReason = failureReason
    }
}

public func dryRunJinguiAcceptedTransportH2ResponseTransportWriterAdapter(
    responseWriterSurface: String,
    transport: ServerJinguiAcceptedTransportDescriptorSnapshot,
    frame: JinguiAcceptedTransportH2FrameWireSnapshot,
    writer: ResponseTransportWriter
): JinguiAcceptedTransportH2ResponseTransportWriterAdapterDryRunResult {
    let frameWire = encodeJinguiAcceptedTransportH2DataFrameWireSnapshot(frame)
    let responseBytes =
        cloneJinguiAcceptedTransportH2FrameWireAsResponseBytes(frameWire)
    writer.write(responseBytes)
    JinguiAcceptedTransportH2ResponseTransportWriterAdapterDryRunResult(
        responseWriterSurface,
        transport.transportId,
        transport.transportKind,
        "response-transport-writer-complete",
        true,
        true,
        frameWire.size,
        1,
        ""
    )
}

public class JinguiAcceptedTransportH2NativeResponseCommitAdapterGateDryRunResult {
    public let responseWriterSurface: String
    public let transportId: String
    public let transportKind: String
    public let adapterStatusName: String
    public let statusName: String
    public let attempted: Bool
    public let completed: Bool
    public let streamId: Int64
    public let endStream: Bool
    public let byteCount: Int64
    public let writeCalls: Int64
    public let failureReason: String

    public init(
        responseWriterSurface: String,
        transportId: String,
        transportKind: String,
        adapterStatusName: String,
        statusName: String,
        attempted: Bool,
        completed: Bool,
        streamId: Int64,
        endStream: Bool,
        byteCount: Int64,
        writeCalls: Int64,
        failureReason: String
    ) {
        this.responseWriterSurface = responseWriterSurface
        this.transportId = transportId
        this.transportKind = transportKind
        this.adapterStatusName = adapterStatusName
        this.statusName = statusName
        this.attempted = attempted
        this.completed = completed
        this.streamId = streamId
        this.endStream = endStream
        this.byteCount = byteCount
        this.writeCalls = writeCalls
        this.failureReason = failureReason
    }
}

public func dryRunJinguiAcceptedTransportH2NativeResponseCommitAdapterGate(
    responseWriterSurface: String,
    transport: ServerJinguiAcceptedTransportDescriptorSnapshot,
    drain: JinguiAcceptedTransportH2WriterFlowQueueDrainSnapshot,
    payload: Array<Byte>,
    writer: ResponseTransportWriter
): JinguiAcceptedTransportH2NativeResponseCommitAdapterGateDryRunResult {
    let frame =
        buildJinguiAcceptedTransportH2WriterDataFrameWireSnapshot(
            drain,
            payload
        )
    let adapter =
        dryRunJinguiAcceptedTransportH2ResponseTransportWriterAdapter(
            responseWriterSurface,
            transport,
            frame,
            writer
        )
    let statusName = if (adapter.completed) {
        "native-response-commit-adapter-complete"
    } else {
        "native-response-commit-adapter-incomplete"
    }
    JinguiAcceptedTransportH2NativeResponseCommitAdapterGateDryRunResult(
        adapter.responseWriterSurface,
        adapter.transportId,
        adapter.transportKind,
        adapter.statusName,
        statusName,
        adapter.attempted,
        adapter.completed,
        frame.streamId,
        frame.flags == UInt8(0x1),
        adapter.byteCount,
        adapter.writeCalls,
        adapter.failureReason
    )
}

public class JinguiAcceptedTransportH2LiveResponseWriterAcquisitionGateDryRunResult {
    public let responseWriterSurface: String
    public let transportId: String
    public let transportKind: String
    public let acquisitionStatusName: String
    public let commitStatusName: String
    public let statusName: String
    public let attempted: Bool
    public let completed: Bool
    public let streamId: Int64
    public let endStream: Bool
    public let byteCount: Int64
    public let writeCalls: Int64
    public let failureReason: String

    public init(
        responseWriterSurface: String,
        transportId: String,
        transportKind: String,
        acquisitionStatusName: String,
        commitStatusName: String,
        statusName: String,
        attempted: Bool,
        completed: Bool,
        streamId: Int64,
        endStream: Bool,
        byteCount: Int64,
        writeCalls: Int64,
        failureReason: String
    ) {
        this.responseWriterSurface = responseWriterSurface
        this.transportId = transportId
        this.transportKind = transportKind
        this.acquisitionStatusName = acquisitionStatusName
        this.commitStatusName = commitStatusName
        this.statusName = statusName
        this.attempted = attempted
        this.completed = completed
        this.streamId = streamId
        this.endStream = endStream
        this.byteCount = byteCount
        this.writeCalls = writeCalls
        this.failureReason = failureReason
    }
}

public func dryRunJinguiAcceptedTransportH2LiveResponseWriterAcquisitionGate(
    responseWriterSurface: String,
    transport: ServerJinguiAcceptedTransportDescriptorSnapshot,
    drain: JinguiAcceptedTransportH2WriterFlowQueueDrainSnapshot,
    payload: Array<Byte>,
    currentRequestCarrier: CurrentRequestCarrier
): JinguiAcceptedTransportH2LiveResponseWriterAcquisitionGateDryRunResult {
    let _ = buildJinguiAcceptedTransportH2WriterDataFrameWireSnapshot(
        drain,
        payload
    )
    let writer = openResponseTransportWriter(currentRequestCarrier)
    let commit =
        dryRunJinguiAcceptedTransportH2NativeResponseCommitAdapterGate(
            responseWriterSurface,
            transport,
            drain,
            payload,
            writer
        )
    let statusName = if (commit.completed) {
        "live-response-writer-acquisition-gate-complete"
    } else {
        "live-response-writer-acquisition-gate-incomplete"
    }
    JinguiAcceptedTransportH2LiveResponseWriterAcquisitionGateDryRunResult(
        commit.responseWriterSurface,
        commit.transportId,
        commit.transportKind,
        "response-transport-writer-acquired",
        commit.statusName,
        statusName,
        commit.attempted,
        commit.completed,
        commit.streamId,
        commit.endStream,
        commit.byteCount,
        commit.writeCalls,
        commit.failureReason
    )
}

public class JinguiAcceptedTransportH2LiveResponseWriterLeaseGate {
    let _currentRequestCarrier: CurrentRequestCarrier
    var _writer: ?ResponseTransportWriter = None
    var _acquisitionCount: Int64 = 0

    public init(currentRequestCarrier: CurrentRequestCarrier) {
        this._currentRequestCarrier = currentRequestCarrier
    }

    public func acquisitionCount(): Int64 {
        _acquisitionCount
    }

    func ensureWriter(): ResponseTransportWriter {
        match (_writer) {
            case Some(writer) => writer
            case None =>
                let writer = openResponseTransportWriter(_currentRequestCarrier)
                _writer = Some(writer)
                _acquisitionCount += 1
                writer
        }
    }

    public func commitDataFrame(
        responseWriterSurface: String,
        transport: ServerJinguiAcceptedTransportDescriptorSnapshot,
        drain: JinguiAcceptedTransportH2WriterFlowQueueDrainSnapshot,
        payload: Array<Byte>
    ): JinguiAcceptedTransportH2LiveResponseWriterAcquisitionGateDryRunResult {
        let _ = buildJinguiAcceptedTransportH2WriterDataFrameWireSnapshot(
            drain,
            payload
        )
        let acquisitionStatusName = match (_writer) {
            case Some(_) => "response-transport-writer-reused"
            case None => "response-transport-writer-acquired"
        }
        let writer = ensureWriter()
        let commit =
            dryRunJinguiAcceptedTransportH2NativeResponseCommitAdapterGate(
                responseWriterSurface,
                transport,
                drain,
                payload,
                writer
            )
        let statusName = if (commit.completed) {
            "live-response-writer-lease-gate-complete"
        } else {
            "live-response-writer-lease-gate-incomplete"
        }
        JinguiAcceptedTransportH2LiveResponseWriterAcquisitionGateDryRunResult(
            commit.responseWriterSurface,
            commit.transportId,
            commit.transportKind,
            acquisitionStatusName,
            commit.statusName,
            statusName,
            commit.attempted,
            commit.completed,
            commit.streamId,
            commit.endStream,
            commit.byteCount,
            commit.writeCalls,
            commit.failureReason
        )
    }

    public func commitFrameWireSnapshot(
        responseWriterSurface: String,
        transport: ServerJinguiAcceptedTransportDescriptorSnapshot,
        frame: JinguiAcceptedTransportH2FrameWireSnapshot
    ): JinguiAcceptedTransportH2LiveResponseWriterAcquisitionGateDryRunResult {
        let acquisitionStatusName = match (_writer) {
            case Some(_) => "response-transport-writer-reused"
            case None => "response-transport-writer-acquired"
        }
        let writer = ensureWriter()
        let frameWire = encodeJinguiAcceptedTransportH2FrameWireSnapshot(frame)
        let responseBytes =
            cloneJinguiAcceptedTransportH2FrameWireAsResponseBytes(frameWire)
        writer.write(responseBytes)
        JinguiAcceptedTransportH2LiveResponseWriterAcquisitionGateDryRunResult(
            responseWriterSurface,
            transport.transportId,
            transport.transportKind,
            acquisitionStatusName,
            "native-response-frame-commit-complete",
            "live-response-writer-lease-gate-complete",
            true,
            true,
            frame.streamId,
            serverJinguiAcceptedTransportH2HasFlag(frame.flags, UInt8(0x1)),
            frameWire.size,
            1,
            ""
        )
    }
}

public class JinguiAcceptedTransportH2AcceptedSocketResponseWriterHandoffGate {
    let _transport: ServerJinguiAcceptedTransportDescriptorSnapshot
    let _leaseGate: JinguiAcceptedTransportH2LiveResponseWriterLeaseGate

    public init(
        transport: ServerJinguiAcceptedTransportDescriptorSnapshot,
        currentRequestCarrier: CurrentRequestCarrier
    ) {
        this._transport = transport
        this._leaseGate =
            JinguiAcceptedTransportH2LiveResponseWriterLeaseGate(
                currentRequestCarrier
            )
    }

    public func transportId(): String {
        _transport.transportId
    }

    public func transportKind(): String {
        _transport.transportKind
    }

    public func acquisitionCount(): Int64 {
        _leaseGate.acquisitionCount()
    }

    public func commitDataFrame(
        responseWriterSurface: String,
        drain: JinguiAcceptedTransportH2WriterFlowQueueDrainSnapshot,
        payload: Array<Byte>
    ): JinguiAcceptedTransportH2LiveResponseWriterAcquisitionGateDryRunResult {
        _leaseGate.commitDataFrame(
            responseWriterSurface,
            _transport,
            drain,
            payload
        )
    }

    public func commitNextQueuedDataPayload(
        responseWriterSurface: String,
        queue: JinguiAcceptedTransportH2WriterFlowQueue,
        payload: Array<Byte>
    ): JinguiAcceptedTransportH2LiveResponseWriterAcquisitionGateDryRunResult {
        if (payload.size <= 0) {
            throw Exception(
                "H2 accepted-socket queued DATA payload commit requires non-empty payload"
            )
        }
        let remaining = queue.headRemainingByteCount()
        if (payload.size > remaining) {
            throw Exception(
                "H2 accepted-socket queued DATA payload commit payload exceeds queued bytes, payload=${payload.size}, remaining=${remaining}"
            )
        }
        let drain = queue.tryDrainHeadChunk(payload.size)
        if (!drain.drained) {
            throw Exception(
                "H2 accepted-socket queued DATA payload commit is waiting for WINDOW_UPDATE, streamId=${drain.streamId}, pendingCount=${drain.pendingCount}"
            )
        }
        commitDataFrame(
            responseWriterSurface,
            drain,
            payload
        )
    }

    public func commitFrameWireSnapshot(
        responseWriterSurface: String,
        frame: JinguiAcceptedTransportH2FrameWireSnapshot
    ): JinguiAcceptedTransportH2LiveResponseWriterAcquisitionGateDryRunResult {
        _leaseGate.commitFrameWireSnapshot(
            responseWriterSurface,
            _transport,
            frame
        )
    }
}

func cloneJinguiAcceptedTransportH2FrameWireAsResponseBytes(
    frameWire: Array<Byte>
): Array<UInt8> {
    let out = Array<UInt8>(frameWire.size, repeat: 0)
    var i: Int64 = 0
    while (i < frameWire.size) {
        out[i] = UInt8(frameWire[i])
        i += 1
    }
    out
}

public func writeJinguiAcceptedTransportH2DataFrameWireSnapshotToSink(
    frame: JinguiAcceptedTransportH2FrameWireSnapshot,
    sink: JinguiAcceptedTransportH2FrameWireWriterSink
): Int64 {
    let frameWire = encodeJinguiAcceptedTransportH2DataFrameWireSnapshot(frame)
    sink.writeFrameWire(frameWire)
}

func appendJinguiAcceptedTransportH2HeaderBlockBytes(
    out: ArrayList<Byte>,
    bytes: Array<Byte>
): Unit {
    for (b in bytes) {
        out.add(b)
    }
}

public class JinguiAcceptedTransportH2DecodedHeaderField {
    public let name: String
    public let value: String
    public let representationKind: String
    public let staticIndex: Int64
    public let nameStaticIndex: Int64

    public init(
        name: String,
        value: String,
        representationKind: String,
        staticIndex: Int64,
        nameStaticIndex: Int64
    ) {
        this.name = name
        this.value = value
        this.representationKind = representationKind
        this.staticIndex = staticIndex
        this.nameStaticIndex = nameStaticIndex
    }
}

class ServerJinguiAcceptedTransportH2StaticHeaderField {
    let name: String
    let value: String

    init(name: String, value: String) {
        this.name = name
        this.value = value
    }
}

class ServerJinguiAcceptedTransportH2DynamicHeaderTable {
    let _entries = ArrayList<ServerJinguiAcceptedTransportH2StaticHeaderField>()
    let _maxAllowedSize: Int64
    var _maxSize: Int64
    var _currentSize: Int64 = 0

    init(
        maxSize!: Int64 =
            serverJinguiAcceptedTransportH2HpackMaxDynamicTableSizeUpdate()
    ) {
        if (
            maxSize < 0 ||
            maxSize >
                serverJinguiAcceptedTransportH2HpackMaxDynamicTableSizeUpdate()
        ) {
            throw Exception(
                "H2 HPACK dynamic table initial max-size exceeds bounded max, value=${maxSize}, max=${serverJinguiAcceptedTransportH2HpackMaxDynamicTableSizeUpdate()}"
            )
        }
        _maxAllowedSize = maxSize
        _maxSize = maxSize
    }

    func maxSize(): Int64 {
        _maxSize
    }

    func maxAllowedSize(): Int64 {
        _maxAllowedSize
    }

    func currentSize(): Int64 {
        _currentSize
    }

    func entryCount(): Int64 {
        _entries.size
    }

    func updateMaxSize(maxSize: Int64): Unit {
        if (
            maxSize < 0 ||
            maxSize > _maxAllowedSize
        ) {
            throw Exception(
                "H2 HPACK dynamic table size update exceeds configured max, value=${maxSize}, max=${_maxAllowedSize}"
            )
        }
        _maxSize = maxSize
        evictUntilWithinMaxSize()
    }

    func add(name: String, value: String): Unit {
        let entry =
            ServerJinguiAcceptedTransportH2StaticHeaderField(name, value)
        let size = entrySize(entry)
        if (size > _maxSize) {
            _entries.clear()
            _currentSize = 0
            return
        }
        _entries.add(entry)
        _currentSize += size
        evictUntilWithinMaxSize()
    }

    func lookup(
        index: Int64
    ): ServerJinguiAcceptedTransportH2StaticHeaderField {
        let dynamicOffset =
            index - serverJinguiAcceptedTransportH2FirstDynamicTableIndex()
        if (dynamicOffset < 0 || dynamicOffset >= _entries.size) {
            throw Exception(
                "H2 HPACK dynamic table cannot resolve index=${index}, entryCount=${_entries.size}"
            )
        }
        _entries[_entries.size - 1 - dynamicOffset]
    }

    func evictUntilWithinMaxSize(): Unit {
        while (_currentSize > _maxSize && _entries.size > 0) {
            let removed = _entries.remove(at: Int64(0))
            _currentSize -= entrySize(removed)
        }
        if (_currentSize < 0) {
            _currentSize = 0
        }
    }

    func entrySize(
        entry: ServerJinguiAcceptedTransportH2StaticHeaderField
    ): Int64 {
        entry.name.size + entry.value.size + 32
    }
}

class ServerJinguiAcceptedTransportH2HpackIntegerDecodeResult {
    let value: Int64
    let nextCursor: Int64

    init(value: Int64, nextCursor: Int64) {
        this.value = value
        this.nextCursor = nextCursor
    }
}

class ServerJinguiAcceptedTransportH2HpackStringDecodeResult {
    let text: String
    let nextCursor: Int64

    init(text: String, nextCursor: Int64) {
        this.text = text
        this.nextCursor = nextCursor
    }
}

class ServerJinguiAcceptedTransportH2DecodedHeaderFieldParseResult {
    let field: JinguiAcceptedTransportH2DecodedHeaderField
    let nextCursor: Int64

    init(
        field: JinguiAcceptedTransportH2DecodedHeaderField,
        nextCursor: Int64
    ) {
        this.field = field
        this.nextCursor = nextCursor
    }
}

public class ServerJinguiAcceptedTransportH2HpackDecoderState {
    let _dynamicTable: ServerJinguiAcceptedTransportH2DynamicHeaderTable

    public init() {
        this._dynamicTable =
            ServerJinguiAcceptedTransportH2DynamicHeaderTable(
                maxSize:
                    serverJinguiAcceptedTransportH2HpackMaxDynamicTableSizeUpdate()
            )
    }

    public init(maxDynamicTableSize: Int64) {
        this._dynamicTable =
            ServerJinguiAcceptedTransportH2DynamicHeaderTable(
                maxSize: maxDynamicTableSize
            )
    }

    public func parseHeaderFields(
        headerBlock: JinguiAcceptedTransportH2HeaderBlockSnapshot
    ): Array<JinguiAcceptedTransportH2DecodedHeaderField> {
        parseJinguiAcceptedTransportH2HeaderFieldsFromBytesWithDynamicTable(
            headerBlock.headerBlockFragment,
            _dynamicTable
        )
    }

    public func updateMaxDynamicTableSize(maxDynamicTableSize: Int64): Unit {
        _dynamicTable.updateMaxSize(maxDynamicTableSize)
    }

    public func dynamicTableMaxSize(): Int64 {
        _dynamicTable.maxSize()
    }

    public func dynamicEntryCount(): Int64 {
        _dynamicTable.entryCount()
    }

    public func dynamicTableCurrentSize(): Int64 {
        _dynamicTable.currentSize()
    }
}

public func parseJinguiAcceptedTransportH2HeaderFields(
    headerBlock: JinguiAcceptedTransportH2HeaderBlockSnapshot
): Array<JinguiAcceptedTransportH2DecodedHeaderField> {
    parseJinguiAcceptedTransportH2HeaderFieldsFromBytes(
        headerBlock.headerBlockFragment
    )
}

public func parseJinguiAcceptedTransportH2HeaderFieldsWithDynamicTableMaxSize(
    headerBlock: JinguiAcceptedTransportH2HeaderBlockSnapshot,
    maxDynamicTableSize: Int64
): Array<JinguiAcceptedTransportH2DecodedHeaderField> {
    parseJinguiAcceptedTransportH2HeaderFieldsFromBytesWithDynamicTableMaxSize(
        headerBlock.headerBlockFragment,
        maxDynamicTableSize
    )
}

func parseJinguiAcceptedTransportH2HeaderFieldsFromBytes(
    headerBlockFragment: Array<Byte>
): Array<JinguiAcceptedTransportH2DecodedHeaderField> {
    parseJinguiAcceptedTransportH2HeaderFieldsFromBytesWithDynamicTableMaxSize(
        headerBlockFragment,
        serverJinguiAcceptedTransportH2HpackMaxDynamicTableSizeUpdate()
    )
}

func parseJinguiAcceptedTransportH2HeaderFieldsFromBytesWithDynamicTableMaxSize(
    headerBlockFragment: Array<Byte>,
    maxDynamicTableSize: Int64
): Array<JinguiAcceptedTransportH2DecodedHeaderField> {
    let dynamicTable =
        ServerJinguiAcceptedTransportH2DynamicHeaderTable(
            maxSize: maxDynamicTableSize
        )
    parseJinguiAcceptedTransportH2HeaderFieldsFromBytesWithDynamicTable(
        headerBlockFragment,
        dynamicTable
    )
}

func parseJinguiAcceptedTransportH2HeaderFieldsFromBytesWithDynamicTable(
    headerBlockFragment: Array<Byte>,
    dynamicTable: ServerJinguiAcceptedTransportH2DynamicHeaderTable
): Array<JinguiAcceptedTransportH2DecodedHeaderField> {
    let out = ArrayList<JinguiAcceptedTransportH2DecodedHeaderField>()
    var cursor: Int64 = 0
    while (cursor < headerBlockFragment.size) {
        let lead = Int64(UInt8(headerBlockFragment[cursor]))
        if ((lead & 0x80) != 0) {
            let indexed =
                decodeServerJinguiAcceptedTransportH2HpackInteger(
                    headerBlockFragment,
                    cursor,
                    7
                )
            if (indexed.value <= 0) {
                throw Exception(
                    "H2 HPACK indexed header field requires static index >= 1, got index=${indexed.value}"
                )
            }
            let entry =
                serverJinguiAcceptedTransportH2HeaderFieldByIndex(
                    indexed.value,
                    dynamicTable
                )
            let isStatic =
                indexed.value <
                    serverJinguiAcceptedTransportH2FirstDynamicTableIndex()
            let representationKind =
                if (isStatic) {
                    "indexed"
                } else {
                    "indexed-dynamic"
                }
            let staticIndex =
                if (isStatic) {
                    indexed.value
                } else {
                    0
                }
            out.add(
                JinguiAcceptedTransportH2DecodedHeaderField(
                    entry.name,
                    entry.value,
                    representationKind,
                    staticIndex,
                    staticIndex
                )
            )
            cursor = indexed.nextCursor
            continue
        }
        if ((lead & 0x40) != 0) {
            let decoded =
                parseServerJinguiAcceptedTransportH2LiteralHeaderField(
                    headerBlockFragment,
                    cursor,
                    6,
                    "literal-with-indexing",
                    dynamicTable
                )
            out.add(decoded.field)
            dynamicTable.add(decoded.field.name, decoded.field.value)
            cursor = decoded.nextCursor
            continue
        }
        if ((lead & 0x20) != 0) {
            throw Exception(
                "H2 HPACK dynamic table size update is unsupported in this bounded seam at offset=${cursor}"
            )
        }
        let representationKind =
            if ((lead & 0x10) != 0) {
                "literal-never-indexed"
            } else {
                "literal-without-indexing"
            }
        let decoded =
            parseServerJinguiAcceptedTransportH2LiteralHeaderField(
                headerBlockFragment,
                cursor,
                4,
                representationKind,
                dynamicTable
            )
        out.add(decoded.field)
        cursor = decoded.nextCursor
    }
    out.toArray()
}

func parseServerJinguiAcceptedTransportH2LiteralHeaderField(
    headerBlockFragment: Array<Byte>,
    cursor: Int64,
    prefixBits: Int64,
    representationKind: String,
    dynamicTable: ServerJinguiAcceptedTransportH2DynamicHeaderTable
): ServerJinguiAcceptedTransportH2DecodedHeaderFieldParseResult {
    let nameIndex =
        decodeServerJinguiAcceptedTransportH2HpackInteger(
            headerBlockFragment,
            cursor,
            prefixBits
        )
    var nextCursor = nameIndex.nextCursor
    var name = ""
    var nameStaticIndex: Int64 = 0
    if (nameIndex.value == 0) {
        let decodedName =
            decodeServerJinguiAcceptedTransportH2HpackString(
                headerBlockFragment,
                nextCursor
            )
        name = decodedName.text
        nextCursor = decodedName.nextCursor
    } else {
        let entry =
            serverJinguiAcceptedTransportH2HeaderFieldByIndex(
                nameIndex.value,
                dynamicTable
            )
        name = entry.name
        if (
            nameIndex.value <
                serverJinguiAcceptedTransportH2FirstDynamicTableIndex()
        ) {
            nameStaticIndex = nameIndex.value
        }
    }
    let decodedValue =
        decodeServerJinguiAcceptedTransportH2HpackString(
            headerBlockFragment,
            nextCursor
        )
    ServerJinguiAcceptedTransportH2DecodedHeaderFieldParseResult(
        JinguiAcceptedTransportH2DecodedHeaderField(
            name,
            decodedValue.text,
            representationKind,
            0,
            nameStaticIndex
        ),
        decodedValue.nextCursor
    )
}

func decodeServerJinguiAcceptedTransportH2HpackInteger(
    bytes: Array<Byte>,
    cursor: Int64,
    prefixBits: Int64
): ServerJinguiAcceptedTransportH2HpackIntegerDecodeResult {
    if (cursor >= bytes.size) {
        throw Exception(
            "H2 HPACK integer decode cursor is out of range, cursor=${cursor}, size=${bytes.size}"
        )
    }
    let prefixMask =
        serverJinguiAcceptedTransportH2HpackPrefixMask(prefixBits)
    var value =
        Int64(UInt8(bytes[cursor])) & prefixMask
    var nextCursor = cursor + 1
    if (value < prefixMask) {
        return ServerJinguiAcceptedTransportH2HpackIntegerDecodeResult(
            value,
            nextCursor
        )
    }
    var multiplier: Int64 = 0
    while (true) {
        if (nextCursor >= bytes.size) {
            throw Exception(
                "H2 HPACK integer decode truncated after prefix saturation at offset=${cursor}"
            )
        }
        let octet = Int64(UInt8(bytes[nextCursor]))
        value += (octet & 0x7f) << multiplier
        nextCursor += 1
        if ((octet & 0x80) == 0) {
            break
        }
        multiplier += 7
        if (multiplier > 56) {
            throw Exception(
                "H2 HPACK integer decode exceeded bounded Int64 range at offset=${cursor}"
            )
        }
    }
    ServerJinguiAcceptedTransportH2HpackIntegerDecodeResult(
        value,
        nextCursor
    )
}

func decodeServerJinguiAcceptedTransportH2HpackString(
    bytes: Array<Byte>,
    cursor: Int64
): ServerJinguiAcceptedTransportH2HpackStringDecodeResult {
    if (cursor >= bytes.size) {
        throw Exception(
            "H2 HPACK string decode cursor is out of range, cursor=${cursor}, size=${bytes.size}"
        )
    }
    let huffman =
        (Int64(UInt8(bytes[cursor])) & 0x80) != 0
    if (huffman) {
        throw Exception(
            "H2 HPACK Huffman string is unsupported in this bounded seam at offset=${cursor}"
        )
    }
    let lengthResult =
        decodeServerJinguiAcceptedTransportH2HpackInteger(
            bytes,
            cursor,
            7
        )
    let remaining = bytes.size - lengthResult.nextCursor
    if (remaining < lengthResult.value) {
        throw Exception(
            "H2 HPACK string payload truncated, offset=${cursor}, remaining=${remaining}, expected=${lengthResult.value}"
        )
    }
    let raw =
        cloneServerEngineByteWindow(
            bytes,
            lengthResult.nextCursor,
            lengthResult.value
        )
    let utf8 = Array<UInt8>(raw.size, repeat: 0)
    var i: Int64 = 0
    while (i < raw.size) {
        utf8[i] = UInt8(raw[i])
        i += 1
    }
    ServerJinguiAcceptedTransportH2HpackStringDecodeResult(
        String.fromUtf8(utf8),
        lengthResult.nextCursor + lengthResult.value
    )
}

func serverJinguiAcceptedTransportH2HpackPrefixMask(
    prefixBits: Int64
): Int64 {
    if (prefixBits == 4) {
        return 0x0f
    }
    if (prefixBits == 5) {
        return 0x1f
    }
    if (prefixBits == 6) {
        return 0x3f
    }
    if (prefixBits == 7) {
        return 0x7f
    }
    throw Exception(
        "unsupported H2 HPACK prefix bits=${prefixBits}"
    )
}

func serverJinguiAcceptedTransportH2HpackMaxDynamicTableSizeUpdate(): Int64 {
    65536
}

func serverJinguiAcceptedTransportH2FirstDynamicTableIndex(): Int64 {
    62
}

func serverJinguiAcceptedTransportH2HeaderFieldByIndex(
    index: Int64,
    dynamicTable: ServerJinguiAcceptedTransportH2DynamicHeaderTable
): ServerJinguiAcceptedTransportH2StaticHeaderField {
    if (index < serverJinguiAcceptedTransportH2FirstDynamicTableIndex()) {
        return serverJinguiAcceptedTransportH2StaticHeaderFieldByIndex(index)
    }
    dynamicTable.lookup(index)
}

func serverJinguiAcceptedTransportH2StaticHeaderFieldByIndex(
    index: Int64
): ServerJinguiAcceptedTransportH2StaticHeaderField {
    if (index == 1) { return ServerJinguiAcceptedTransportH2StaticHeaderField(":authority", "") }
    if (index == 2) { return ServerJinguiAcceptedTransportH2StaticHeaderField(":method", "GET") }
    if (index == 3) { return ServerJinguiAcceptedTransportH2StaticHeaderField(":method", "POST") }
    if (index == 4) { return ServerJinguiAcceptedTransportH2StaticHeaderField(":path", "/") }
    if (index == 5) { return ServerJinguiAcceptedTransportH2StaticHeaderField(":path", "/index.html") }
    if (index == 6) { return ServerJinguiAcceptedTransportH2StaticHeaderField(":scheme", "http") }
    if (index == 7) { return ServerJinguiAcceptedTransportH2StaticHeaderField(":scheme", "https") }
    if (index == 8) { return ServerJinguiAcceptedTransportH2StaticHeaderField(":status", "200") }
    if (index == 9) { return ServerJinguiAcceptedTransportH2StaticHeaderField(":status", "204") }
    if (index == 10) { return ServerJinguiAcceptedTransportH2StaticHeaderField(":status", "206") }
    if (index == 11) { return ServerJinguiAcceptedTransportH2StaticHeaderField(":status", "304") }
    if (index == 12) { return ServerJinguiAcceptedTransportH2StaticHeaderField(":status", "400") }
    if (index == 13) { return ServerJinguiAcceptedTransportH2StaticHeaderField(":status", "404") }
    if (index == 14) { return ServerJinguiAcceptedTransportH2StaticHeaderField(":status", "500") }
    if (index == 15) { return ServerJinguiAcceptedTransportH2StaticHeaderField("accept-charset", "") }
    if (index == 16) { return ServerJinguiAcceptedTransportH2StaticHeaderField("accept-encoding", "gzip, deflate") }
    if (index == 17) { return ServerJinguiAcceptedTransportH2StaticHeaderField("accept-language", "") }
    if (index == 18) { return ServerJinguiAcceptedTransportH2StaticHeaderField("accept-ranges", "") }
    if (index == 19) { return ServerJinguiAcceptedTransportH2StaticHeaderField("accept", "") }
    if (index == 20) { return ServerJinguiAcceptedTransportH2StaticHeaderField("access-control-allow-origin", "") }
    if (index == 21) { return ServerJinguiAcceptedTransportH2StaticHeaderField("age", "") }
    if (index == 22) { return ServerJinguiAcceptedTransportH2StaticHeaderField("allow", "") }
    if (index == 23) { return ServerJinguiAcceptedTransportH2StaticHeaderField("authorization", "") }
    if (index == 24) { return ServerJinguiAcceptedTransportH2StaticHeaderField("cache-control", "") }
    if (index == 25) { return ServerJinguiAcceptedTransportH2StaticHeaderField("content-disposition", "") }
    if (index == 26) { return ServerJinguiAcceptedTransportH2StaticHeaderField("content-encoding", "") }
    if (index == 27) { return ServerJinguiAcceptedTransportH2StaticHeaderField("content-language", "") }
    if (index == 28) { return ServerJinguiAcceptedTransportH2StaticHeaderField("content-length", "") }
    if (index == 29) { return ServerJinguiAcceptedTransportH2StaticHeaderField("content-location", "") }
    if (index == 30) { return ServerJinguiAcceptedTransportH2StaticHeaderField("content-range", "") }
    if (index == 31) { return ServerJinguiAcceptedTransportH2StaticHeaderField("content-type", "") }
    if (index == 32) { return ServerJinguiAcceptedTransportH2StaticHeaderField("cookie", "") }
    if (index == 33) { return ServerJinguiAcceptedTransportH2StaticHeaderField("date", "") }
    if (index == 34) { return ServerJinguiAcceptedTransportH2StaticHeaderField("etag", "") }
    if (index == 35) { return ServerJinguiAcceptedTransportH2StaticHeaderField("expect", "") }
    if (index == 36) { return ServerJinguiAcceptedTransportH2StaticHeaderField("expires", "") }
    if (index == 37) { return ServerJinguiAcceptedTransportH2StaticHeaderField("from", "") }
    if (index == 38) { return ServerJinguiAcceptedTransportH2StaticHeaderField("host", "") }
    if (index == 39) { return ServerJinguiAcceptedTransportH2StaticHeaderField("if-match", "") }
    if (index == 40) { return ServerJinguiAcceptedTransportH2StaticHeaderField("if-modified-since", "") }
    if (index == 41) { return ServerJinguiAcceptedTransportH2StaticHeaderField("if-none-match", "") }
    if (index == 42) { return ServerJinguiAcceptedTransportH2StaticHeaderField("if-range", "") }
    if (index == 43) { return ServerJinguiAcceptedTransportH2StaticHeaderField("if-unmodified-since", "") }
    if (index == 44) { return ServerJinguiAcceptedTransportH2StaticHeaderField("last-modified", "") }
    if (index == 45) { return ServerJinguiAcceptedTransportH2StaticHeaderField("link", "") }
    if (index == 46) { return ServerJinguiAcceptedTransportH2StaticHeaderField("location", "") }
    if (index == 47) { return ServerJinguiAcceptedTransportH2StaticHeaderField("max-forwards", "") }
    if (index == 48) { return ServerJinguiAcceptedTransportH2StaticHeaderField("proxy-authenticate", "") }
    if (index == 49) { return ServerJinguiAcceptedTransportH2StaticHeaderField("proxy-authorization", "") }
    if (index == 50) { return ServerJinguiAcceptedTransportH2StaticHeaderField("range", "") }
    if (index == 51) { return ServerJinguiAcceptedTransportH2StaticHeaderField("referer", "") }
    if (index == 52) { return ServerJinguiAcceptedTransportH2StaticHeaderField("refresh", "") }
    if (index == 53) { return ServerJinguiAcceptedTransportH2StaticHeaderField("retry-after", "") }
    if (index == 54) { return ServerJinguiAcceptedTransportH2StaticHeaderField("server", "") }
    if (index == 55) { return ServerJinguiAcceptedTransportH2StaticHeaderField("set-cookie", "") }
    if (index == 56) { return ServerJinguiAcceptedTransportH2StaticHeaderField("strict-transport-security", "") }
    if (index == 57) { return ServerJinguiAcceptedTransportH2StaticHeaderField("transfer-encoding", "") }
    if (index == 58) { return ServerJinguiAcceptedTransportH2StaticHeaderField("user-agent", "") }
    if (index == 59) { return ServerJinguiAcceptedTransportH2StaticHeaderField("vary", "") }
    if (index == 60) { return ServerJinguiAcceptedTransportH2StaticHeaderField("via", "") }
    if (index == 61) { return ServerJinguiAcceptedTransportH2StaticHeaderField("www-authenticate", "") }
    throw Exception(
        "H2 HPACK static-only decode cannot resolve index=${index} without dynamic table support"
    )
}
