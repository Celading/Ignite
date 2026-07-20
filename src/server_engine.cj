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

func serverEngineTextContains(text: String, target: String): Bool {
    if (target.size == 0) {
        return true
    }
    if (text.size < target.size) {
        return false
    }
    (text.indexOf(target)).isSome()
}

func serverEngineTextStartsWith(text: String, prefix: String): Bool {
    if (prefix.size == 0) {
        return true
    }
    if (text.size < prefix.size) {
        return false
    }
    text[..prefix.size] == prefix
}

func buildServerContractHttpServerAttachPlan(
    material: api2.PreparedHttpServerTlsMaterial
): ContractHttpServerAttachPlan {
    let requireHttp2Alpn = containsServerAlpnProtocol(
        material.normalizedAlpnProtocols,
        "h2"
    )
    contractPlanHttpServerAttachRequest(
        ContractHttpServerLibraryStartupRequest(
            ContractHttpServerTlsConfigRequest(
                material.certPem,
                material.keyPem,
                alpnProtocols: material.normalizedAlpnProtocols,
                requireHttp2Alpn: requireHttp2Alpn
            )
        )
    )
}

public class ServerTransportRoutingBundle {
    public let selectionRequest: api2.BackendSelectionRequest
    public let selectionDecision: api2.BackendSelectionDecision
    public let tlsAttachPlan: api2.TlsAttachPlan

    public init(
        selectionRequest: api2.BackendSelectionRequest,
        selectionDecision: api2.BackendSelectionDecision,
        tlsAttachPlan: api2.TlsAttachPlan
    ) {
        this.selectionRequest = selectionRequest
        this.selectionDecision = selectionDecision
        this.tlsAttachPlan = tlsAttachPlan
    }
}

public class ServerTlsIngressContext {
    public let transportRoutingBundle: ServerTransportRoutingBundle
    public let transportTouchpoint: ServerTransportTouchpoint
    public let preparedTlsMaterialLoader: ?ServerPreparedTlsMaterialLoader

    public init(
        transportRoutingBundle: ServerTransportRoutingBundle,
        transportTouchpoint: ServerTransportTouchpoint,
        preparedTlsMaterialLoader!: ?ServerPreparedTlsMaterialLoader = None
    ) {
        this.transportRoutingBundle = transportRoutingBundle
        this.transportTouchpoint = transportTouchpoint
        this.preparedTlsMaterialLoader = preparedTlsMaterialLoader
    }

    public func hasPreparedTlsMaterial(): Bool {
        if (let Some(_) <- preparedTlsMaterialLoader) {
            return true
        }
        false
    }

    public func loadPreparedTlsMaterial(): api2.PreparedHttpServerTlsMaterial {
        if (let Some(loader) <- preparedTlsMaterialLoader) {
            return loader()
        }
        throw Exception("prepared TLS material loader is unavailable")
    }

    public func loadJinguiHttpServerAttachPlanSnapshot(): ServerJinguiHttpServerAttachPlanSnapshot {
        let material = loadPreparedTlsMaterial()
        let plan = buildServerContractHttpServerAttachPlan(material)
        ServerJinguiHttpServerAttachPlanSnapshot(
            plan.planningGate.providerId,
            plan.attachSurface,
            plan.listenerOwned,
            plan.expectedTlsVersion.toString(),
            plan.expectedAlpnProtocols,
            plan.planningGate.status.toString(),
            plan.planningGate.readyNow,
            plan.planningGate.publicPath,
            plan.planningGate.releasePath,
            plan.planningGate.selectedReason,
            plan.planningGate.warnings,
            plan.stableAttachGate.status.toString(),
            plan.stableAttachGate.readyNow,
            plan.stableAttachGate.publicPath,
            plan.stableAttachGate.releasePath,
            plan.stableAttachGate.selectedReason,
            plan.stableAttachGate.blockedCandidates,
            plan.startup.material.validation.keyAlgorithm.toString()
        )
    }

    public func buildJinguiHttpServerAttachResultSnapshot(
        attachResult: ContractHttpServerAttachResult
    ): ServerJinguiHttpServerAttachResultSnapshot {
        buildServerJinguiHttpServerAttachResultSnapshot(attachResult)
    }

    public func buildJinguiAcceptedTransportTls13X25519Request(
        transport: ContractAcceptedTransportDescriptor,
        encodedClientHello: Array<Byte>,
        serverKeyExchangePrivate: Array<Byte>,
        policy!: ContractTlsHttpNegotiationPolicy = ContractTlsHttpNegotiationPolicy()
    ): ContractHttpServerAcceptedTransportTls13X25519Request {
        let plan = buildServerContractHttpServerAttachPlan(loadPreparedTlsMaterial())
        ContractHttpServerAcceptedTransportTls13X25519Request(
            transport,
            plan,
            encodedClientHello,
            serverKeyExchangePrivate,
            policy: policy
        )
    }

    public func attachJinguiAcceptedTransportTls13X25519Request(
        request: ContractHttpServerAcceptedTransportTls13X25519Request
    ): ContractHttpServerAcceptedTransportSession {
        contractAttachAcceptedTransportTls13X25519Request(request)
    }

    public func attachJinguiAcceptedTransportTls13X25519(
        transport: ContractAcceptedTransportDescriptor,
        encodedClientHello: Array<Byte>,
        serverKeyExchangePrivate: Array<Byte>,
        policy!: ContractTlsHttpNegotiationPolicy = ContractTlsHttpNegotiationPolicy()
    ): ContractHttpServerAcceptedTransportSession {
        contractAttachAcceptedTransportTls13X25519(
            transport,
            buildServerContractHttpServerAttachPlan(loadPreparedTlsMaterial()),
            encodedClientHello,
            serverKeyExchangePrivate,
            policy: policy
        )
    }

    public func closeJinguiAcceptedTransportSession(
        session: ContractHttpServerAcceptedTransportSession,
        reason!: String = "close_notify"
    ): ContractHttpServerAcceptedTransportSession {
        contractCloseAcceptedTransportSession(session, reason: reason)
    }

    public func sealJinguiAcceptedTransportApplicationData(
        session: ContractHttpServerAcceptedTransportSession,
        plaintext: Array<Byte>
    ): Array<Byte> {
        ensureServerJinguiAcceptedTransportSessionCodecReady(session)
        session.recordChannel.sealApplicationData(plaintext)
    }

    public func openJinguiAcceptedTransportApplicationData(
        session: ContractHttpServerAcceptedTransportSession,
        encodedRecord: Array<Byte>
    ): Array<Byte> {
        ensureServerJinguiAcceptedTransportSessionCodecReady(session)
        session.recordChannel.openApplicationData(encodedRecord)
    }

    public func sealJinguiAcceptedTransportApplicationDataFragments(
        session: ContractHttpServerAcceptedTransportSession,
        plaintext: Array<Byte>,
        maxFragmentLen!: Int64 = 16384
    ): Array<Array<Byte>> {
        ensureServerJinguiAcceptedTransportSessionCodecReady(session)
        session.recordChannel.sealFragments(
            ContractTlsRecordContentType.ApplicationData,
            plaintext,
            maxFragmentLen: maxFragmentLen
        )
    }

    public func openAndReassembleJinguiAcceptedTransportApplicationData(
        session: ContractHttpServerAcceptedTransportSession,
        encodedRecords: Array<Array<Byte>>
    ): Array<Byte> {
        ensureServerJinguiAcceptedTransportSessionCodecReady(session)
        session.recordChannel.openAndReassemble(encodedRecords)
    }

    public func openAndIngressJinguiAcceptedTransportApplicationDataH2HeaderBlocks(
        session: ContractHttpServerAcceptedTransportSession,
        encodedRecords: Array<Array<Byte>>
    ): Array<JinguiAcceptedTransportH2HeaderBlockSnapshot> {
        let headerAccumulator = JinguiAcceptedTransportH2HeaderBlockAccumulator()
        for (
            frame in
                openAndParseJinguiAcceptedTransportApplicationDataH2FramesCore(
                    session,
                    encodedRecords
                )
        ) {
            headerAccumulator.append(frame)
        }
        headerAccumulator.drainCompleteHeaderBlocks()
    }

    public func buildJinguiAcceptedTransportApplicationDataH2HeaderBlockIngressAccumulator(
        session: ContractHttpServerAcceptedTransportSession
    ): JinguiAcceptedTransportApplicationDataH2HeaderBlockIngressAccumulator {
        JinguiAcceptedTransportApplicationDataH2HeaderBlockIngressAccumulator(
            session
        )
    }

    public func buildJinguiAcceptedTransportApplicationDataH2HeaderBlockLogicalRequestAccumulator(
        session: ContractHttpServerAcceptedTransportSession,
        bodyBytes!: Array<UInt8> = []
    ): JinguiAcceptedTransportApplicationDataH2HeaderBlockLogicalRequestAccumulator {
        JinguiAcceptedTransportApplicationDataH2HeaderBlockLogicalRequestAccumulator(
            session,
            bodyBytes: bodyBytes
        )
    }

    public func buildJinguiAcceptedTransportApplicationDataH2HeadersPlusDataLogicalRequestAccumulator(
        session: ContractHttpServerAcceptedTransportSession,
        hpackDecoderState!: ?ServerJinguiAcceptedTransportH2HpackDecoderState = None
    ): JinguiAcceptedTransportApplicationDataH2HeadersPlusDataLogicalRequestAccumulator {
        JinguiAcceptedTransportApplicationDataH2HeadersPlusDataLogicalRequestAccumulator(
            session,
            hpackDecoderState: hpackDecoderState
        )
    }

    func openAndParseJinguiAcceptedTransportApplicationDataH2FramesCore(
        session: ContractHttpServerAcceptedTransportSession,
        encodedRecords: Array<Array<Byte>>
    ): Array<JinguiAcceptedTransportH2FrameWireSnapshot> {
        let plaintext =
            openAndReassembleJinguiAcceptedTransportApplicationData(
                session,
                encodedRecords
            )
        let frames = ArrayList<JinguiAcceptedTransportH2FrameWireSnapshot>()
        for (frameWire in splitJinguiAcceptedTransportH2FrameWire(plaintext)) {
            frames.add(
                parseJinguiAcceptedTransportH2FrameWire(frameWire)
            )
        }
        frames.toArray()
    }

    func openAndBuildJinguiAcceptedTransportLogicalRequestFromApplicationDataH2LeadingHeaderBlockCore(
        session: ContractHttpServerAcceptedTransportSession,
        encodedRecords: Array<Array<Byte>>,
        missingHeaderBlockMessage: String,
        bodyBytesResolver: (
            JinguiAcceptedTransportH2HeaderBlockSnapshot,
            Array<JinguiAcceptedTransportH2FrameWireSnapshot>
        ) -> Array<UInt8>
    ): ServerJinguiAcceptedTransportLogicalRequest {
        let headerAccumulator = JinguiAcceptedTransportH2HeaderBlockAccumulator()
        var completedHeaderBlock: ?JinguiAcceptedTransportH2HeaderBlockSnapshot =
            None
        let tailFrames = ArrayList<JinguiAcceptedTransportH2FrameWireSnapshot>()
        for (
            frame in
                openAndParseJinguiAcceptedTransportApplicationDataH2FramesCore(
                    session,
                    encodedRecords
                )
        ) {
            if (let Some(_) <- completedHeaderBlock) {
                tailFrames.add(frame)
                continue
            }
            headerAccumulator.append(frame)
            let completed =
                headerAccumulator.drainCompleteHeaderBlocks()
            if (completed.size > 1) {
                throw Exception(
                    "accepted-session application-data logical-request builder core expects at most one leading complete H2 header block while the packet stays one-request-bounded, got count=${completed.size}"
                )
            }
            if (completed.size == 1) {
                completedHeaderBlock = Some(completed[0])
            }
        }
        match (completedHeaderBlock) {
            case Some(headerBlock) =>
                buildServerJinguiAcceptedTransportLogicalRequestFromH2HeaderBlock(
                    headerBlock,
                    bodyBytes: bodyBytesResolver(
                        headerBlock,
                        tailFrames.toArray()
                    )
                )
            case None =>
                throw Exception(missingHeaderBlockMessage)
        }
    }

    func resolveJinguiAcceptedTransportApplicationDataH2HeadersPlusDataLogicalRequestBodyBytes(
        headerBlock: JinguiAcceptedTransportH2HeaderBlockSnapshot,
        tailFrames: Array<JinguiAcceptedTransportH2FrameWireSnapshot>
    ): Array<UInt8> {
        let bodyBytes = ArrayList<Byte>()
        var sawDataFrame = false
        for (frame in tailFrames) {
            if (frame.frameType != UInt8(0x0)) {
                throw Exception(
                    "accepted-session application-data headers-plus-data logical-request projection stays inside one request boundary and only accepts same-stream DATA after one complete H2 header block, got type=${Int64(frame.frameType)}, streamId=${frame.streamId}"
                )
            }
            let dataFrame =
                parseJinguiAcceptedTransportH2DataFrame(frame)
            if (dataFrame.streamId != headerBlock.streamId) {
                throw Exception(
                    "accepted-session application-data headers-plus-data logical-request projection requires same-stream DATA, headerStreamId=${headerBlock.streamId}, dataStreamId=${dataFrame.streamId}"
                )
            }
            for (b in dataFrame.dataBytes) {
                bodyBytes.add(b)
            }
            sawDataFrame = true
        }
        if (!sawDataFrame) {
            throw Exception(
                "accepted-session application-data headers-plus-data logical-request projection expects at least one same-stream H2 DATA frame after one complete H2 header block"
            )
        }
        serverEngineByteToUInt8Array(bodyBytes.toArray())
    }

    func resolveJinguiAcceptedTransportApplicationDataH2HeaderBlockLogicalRequestBodyBytes(
        tailFrames: Array<JinguiAcceptedTransportH2FrameWireSnapshot>,
        bodyBytes: Array<UInt8>
    ): Array<UInt8> {
        if (tailFrames.size == 0) {
            return bodyBytes
        }
        let headerAccumulator = JinguiAcceptedTransportH2HeaderBlockAccumulator()
        for (frame in tailFrames) {
            headerAccumulator.append(frame)
        }
        let completedHeaderBlocks =
            headerAccumulator.drainCompleteHeaderBlocks()
        if (completedHeaderBlocks.size != 0) {
            throw Exception(
                "accepted-session application-data logical-request projection expects exactly one complete H2 header block, got count=${completedHeaderBlocks.size + 1}"
            )
        }
        bodyBytes
    }

    public func openAndBuildJinguiAcceptedTransportLogicalRequestFromApplicationDataH2HeadersPlusData(
        session: ContractHttpServerAcceptedTransportSession,
        encodedRecords: Array<Array<Byte>>
    ): ServerJinguiAcceptedTransportLogicalRequest {
        openAndBuildJinguiAcceptedTransportLogicalRequestFromApplicationDataH2LeadingHeaderBlockCore(
            session,
            encodedRecords,
            "accepted-session application-data headers-plus-data logical-request projection expects exactly one complete H2 header block before DATA accumulation",
            { headerBlock, tailFrames =>
                resolveJinguiAcceptedTransportApplicationDataH2HeadersPlusDataLogicalRequestBodyBytes(
                    headerBlock,
                    tailFrames
                )
            }
        )
    }

    public func openAndBuildJinguiAcceptedTransportLogicalRequestFromApplicationDataH2HeaderBlock(
        session: ContractHttpServerAcceptedTransportSession,
        encodedRecords: Array<Array<Byte>>,
        bodyBytes!: Array<UInt8> = []
    ): ServerJinguiAcceptedTransportLogicalRequest {
        openAndBuildJinguiAcceptedTransportLogicalRequestFromApplicationDataH2LeadingHeaderBlockCore(
            session,
            encodedRecords,
            "accepted-session application-data logical-request projection expects exactly one complete H2 header block, got count=0",
            { _, tailFrames =>
                resolveJinguiAcceptedTransportApplicationDataH2HeaderBlockLogicalRequestBodyBytes(
                    tailFrames,
                    bodyBytes
                )
            }
        )
    }

    public func openJinguiAcceptedTransportApplicationDataResponseTransportWriter(
        session: ContractHttpServerAcceptedTransportSession,
        downstream: ResponseTransportWriter,
        maxFragmentLen!: Int64 = 16384
    ): ResponseTransportWriter {
        ensureServerJinguiAcceptedTransportSessionCodecReady(session)
        wrapResponseTransportWriter(downstream, { plaintext =>
            serverEngineByteRecordChunksToUInt8(
                sealJinguiAcceptedTransportApplicationDataFragments(
                    session,
                    serverEngineUInt8ToByteArray(plaintext),
                    maxFragmentLen: maxFragmentLen
                )
            )
        })
    }

    public func wrapCurrentRequestCarrierWithJinguiAcceptedTransportApplicationDataResponse(
        session: ContractHttpServerAcceptedTransportSession,
        downstream: CurrentRequestCarrier,
        maxFragmentLen!: Int64 = 16384
    ): CurrentRequestCarrier {
        wrapCurrentRequestCarrierResponseWriter(downstream, { =>
            openJinguiAcceptedTransportApplicationDataResponseTransportWriter(
                session,
                downstream.openResponseTransportWriterRaw(),
                maxFragmentLen: maxFragmentLen
            )
        })
    }

    public func buildJinguiAcceptedTransportSessionSnapshot(
        session: ContractHttpServerAcceptedTransportSession
    ): ServerJinguiAcceptedTransportSessionSnapshot {
        buildServerJinguiAcceptedTransportSessionSnapshot(session)
    }
}

public class ServerJinguiHttpServerAttachPlanSnapshot {
    public let providerId: String
    public let attachSurface: String
    public let listenerOwned: Bool
    public let expectedTlsVersion: String
    public let expectedAlpnProtocols: Array<String>
    public let planningStatus: String
    public let planningReady: Bool
    public let planningPublicPath: String
    public let planningReleasePath: String
    public let planningSelectedReason: String
    public let planningWarnings: Array<String>
    public let stableAttachStatus: String
    public let stableAttachReady: Bool
    public let stableAttachPublicPath: String
    public let stableAttachReleasePath: String
    public let stableAttachSelectedReason: String
    public let stableAttachBlockedCandidates: Array<String>
    public let materialKeyAlgorithm: String

    public init(
        providerId: String,
        attachSurface: String,
        listenerOwned: Bool,
        expectedTlsVersion: String,
        expectedAlpnProtocols: Array<String>,
        planningStatus: String,
        planningReady: Bool,
        planningPublicPath: String,
        planningReleasePath: String,
        planningSelectedReason: String,
        planningWarnings: Array<String>,
        stableAttachStatus: String,
        stableAttachReady: Bool,
        stableAttachPublicPath: String,
        stableAttachReleasePath: String,
        stableAttachSelectedReason: String,
        stableAttachBlockedCandidates: Array<String>,
        materialKeyAlgorithm: String
    ) {
        this.providerId = providerId
        this.attachSurface = attachSurface
        this.listenerOwned = listenerOwned
        this.expectedTlsVersion = expectedTlsVersion
        this.expectedAlpnProtocols = expectedAlpnProtocols.clone()
        this.planningStatus = planningStatus
        this.planningReady = planningReady
        this.planningPublicPath = planningPublicPath
        this.planningReleasePath = planningReleasePath
        this.planningSelectedReason = planningSelectedReason
        this.planningWarnings = planningWarnings.clone()
        this.stableAttachStatus = stableAttachStatus
        this.stableAttachReady = stableAttachReady
        this.stableAttachPublicPath = stableAttachPublicPath
        this.stableAttachReleasePath = stableAttachReleasePath
        this.stableAttachSelectedReason = stableAttachSelectedReason
        this.stableAttachBlockedCandidates = stableAttachBlockedCandidates.clone()
        this.materialKeyAlgorithm = materialKeyAlgorithm
    }
}

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
    public let serverPreferredBackendHint: String
    public let allowExperimentalServerBackend: Bool
    public let preparedTlsMaterialLoader: ?ServerPreparedTlsMaterialLoader
    public let transportRoutingBundle: ?ServerTransportRoutingBundle
    public let transportTouchpoint: ?ServerTransportTouchpoint
    public let tlsIngressContext: ?ServerTlsIngressContext
    public let jinguiAcceptedTransportSessionHook:
        ?ServerJinguiAcceptedTransportSessionHook

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
        serverPreferredBackendHint!: String = "",
        allowExperimentalServerBackend!: Bool = false,
        preparedTlsMaterialLoader!: ?ServerPreparedTlsMaterialLoader = None,
        transportRoutingBundle!: ?ServerTransportRoutingBundle = None,
        transportTouchpoint!: ?ServerTransportTouchpoint = None,
        tlsIngressContext!: ?ServerTlsIngressContext = None,
        jinguiAcceptedTransportSessionHook!:
            ?ServerJinguiAcceptedTransportSessionHook = None
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
        this.serverPreferredBackendHint = serverPreferredBackendHint
        this.allowExperimentalServerBackend = allowExperimentalServerBackend
        this.preparedTlsMaterialLoader = preparedTlsMaterialLoader
        this.transportRoutingBundle = transportRoutingBundle
        this.transportTouchpoint = transportTouchpoint
        this.tlsIngressContext = tlsIngressContext
        this.jinguiAcceptedTransportSessionHook =
            jinguiAcceptedTransportSessionHook
    }

    public func loadPreparedTlsMaterial(): api2.PreparedHttpServerTlsMaterial {
        if (let Some(loader) <- preparedTlsMaterialLoader) {
            return loader()
        }
        if (let Some(context) <- tlsIngressContext) {
            return context.loadPreparedTlsMaterial()
        }
        throw Exception("prepared TLS material loader is unavailable")
    }

    public func loadTransportRoutingBundle(): ServerTransportRoutingBundle {
        if (let Some(bundle) <- transportRoutingBundle) {
            return bundle
        }
        if (let Some(context) <- tlsIngressContext) {
            return context.transportRoutingBundle
        }
        throw Exception("server transport routing bundle is unavailable")
    }

    public func loadTlsIngressContext(): ServerTlsIngressContext {
        if (let Some(context) <- tlsIngressContext) {
            return context
        }
        if (let Some(bundle) <- transportRoutingBundle) {
            if (let Some(touchpoint) <- transportTouchpoint) {
                return ServerTlsIngressContext(
                    bundle,
                    touchpoint,
                    preparedTlsMaterialLoader: preparedTlsMaterialLoader
                )
            }
        }
        throw Exception("server TLS ingress context is unavailable")
    }

    public func loadJinguiHttpServerAttachPlanSnapshot(): ServerJinguiHttpServerAttachPlanSnapshot {
        loadTlsIngressContext().loadJinguiHttpServerAttachPlanSnapshot()
    }

    public func buildJinguiHttpServerAttachResultSnapshot(
        attachResult: ContractHttpServerAttachResult
    ): ServerJinguiHttpServerAttachResultSnapshot {
        if (let Some(context) <- tlsIngressContext) {
            return context.buildJinguiHttpServerAttachResultSnapshot(attachResult)
        }
        buildServerJinguiHttpServerAttachResultSnapshot(attachResult)
    }

    public func buildJinguiAcceptedTransportTls13X25519Request(
        transport: ContractAcceptedTransportDescriptor,
        encodedClientHello: Array<Byte>,
        serverKeyExchangePrivate: Array<Byte>,
        policy!: ContractTlsHttpNegotiationPolicy = ContractTlsHttpNegotiationPolicy()
    ): ContractHttpServerAcceptedTransportTls13X25519Request {
        loadTlsIngressContext().buildJinguiAcceptedTransportTls13X25519Request(
            transport,
            encodedClientHello,
            serverKeyExchangePrivate,
            policy: policy
        )
    }

    public func attachJinguiAcceptedTransportTls13X25519Request(
        request: ContractHttpServerAcceptedTransportTls13X25519Request
    ): ContractHttpServerAcceptedTransportSession {
        loadTlsIngressContext().attachJinguiAcceptedTransportTls13X25519Request(
            request
        )
    }

    public func attachJinguiAcceptedTransportTls13X25519(
        transport: ContractAcceptedTransportDescriptor,
        encodedClientHello: Array<Byte>,
        serverKeyExchangePrivate: Array<Byte>,
        policy!: ContractTlsHttpNegotiationPolicy = ContractTlsHttpNegotiationPolicy()
    ): ContractHttpServerAcceptedTransportSession {
        loadTlsIngressContext().attachJinguiAcceptedTransportTls13X25519(
            transport,
            encodedClientHello,
            serverKeyExchangePrivate,
            policy: policy
        )
    }

    public func closeJinguiAcceptedTransportSession(
        session: ContractHttpServerAcceptedTransportSession,
        reason!: String = "close_notify"
    ): ContractHttpServerAcceptedTransportSession {
        loadTlsIngressContext().closeJinguiAcceptedTransportSession(
            session,
            reason: reason
        )
    }

    public func captureJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHello(
        acceptedSocket: TcpSocket,
        readChunkSize!: Int64 = 4096
    ): ServerJinguiAcceptedTransportTls13ClientHelloCapture {
        captureJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloCore(
            acceptedSocket,
            readChunkSize: readChunkSize
        )
    }

    func attachJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloX25519Core(
        acceptedSocket: TcpSocket,
        serverKeyExchangePrivate: Array<Byte>,
        transportId!: String = "accepted-transport",
        readChunkSize!: Int64 = 4096,
        policy!: ContractTlsHttpNegotiationPolicy = ContractTlsHttpNegotiationPolicy(),
        notifyReadySnapshot!: Bool = true
    ): ServerJinguiAcceptedTransportSocketAttachedSessionResult {
        let capture =
            captureJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHello(
                acceptedSocket,
                readChunkSize: readChunkSize
            )
        let transport = buildServerAcceptedTransportDescriptorFromSocket(
            acceptedSocket,
            transportId
        )
        let session = attachJinguiAcceptedTransportTls13X25519(
            transport,
            capture.encodedClientHello,
            serverKeyExchangePrivate,
            policy: policy
        )
        let readySnapshot = if (notifyReadySnapshot) {
            notifyJinguiAcceptedTransportSession(session)
        } else {
            buildJinguiAcceptedTransportSessionSnapshot(session)
        }
        ServerJinguiAcceptedTransportSocketAttachedSessionResult(
            capture,
            session,
            readySnapshot
        )
    }

    public func attachJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloX25519(
        acceptedSocket: TcpSocket,
        serverKeyExchangePrivate: Array<Byte>,
        transportId!: String = "accepted-transport",
        readChunkSize!: Int64 = 4096,
        policy!: ContractTlsHttpNegotiationPolicy = ContractTlsHttpNegotiationPolicy()
    ): ServerJinguiAcceptedTransportSocketAttachedSessionResult {
        attachJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloX25519Core(
            acceptedSocket,
            serverKeyExchangePrivate,
            transportId: transportId,
            readChunkSize: readChunkSize,
            policy: policy,
            notifyReadySnapshot: true
        )
    }

    public func sealJinguiAcceptedTransportApplicationData(
        session: ContractHttpServerAcceptedTransportSession,
        plaintext: Array<Byte>
    ): Array<Byte> {
        loadTlsIngressContext().sealJinguiAcceptedTransportApplicationData(
            session,
            plaintext
        )
    }

    public func openJinguiAcceptedTransportApplicationData(
        session: ContractHttpServerAcceptedTransportSession,
        encodedRecord: Array<Byte>
    ): Array<Byte> {
        loadTlsIngressContext().openJinguiAcceptedTransportApplicationData(
            session,
            encodedRecord
        )
    }

    public func sealJinguiAcceptedTransportApplicationDataFragments(
        session: ContractHttpServerAcceptedTransportSession,
        plaintext: Array<Byte>,
        maxFragmentLen!: Int64 = 16384
    ): Array<Array<Byte>> {
        loadTlsIngressContext()
            .sealJinguiAcceptedTransportApplicationDataFragments(
                session,
                plaintext,
                maxFragmentLen: maxFragmentLen
            )
    }

    public func openAndReassembleJinguiAcceptedTransportApplicationData(
        session: ContractHttpServerAcceptedTransportSession,
        encodedRecords: Array<Array<Byte>>
    ): Array<Byte> {
        loadTlsIngressContext()
            .openAndReassembleJinguiAcceptedTransportApplicationData(
                session,
                encodedRecords
            )
    }

    public func openAndIngressJinguiAcceptedTransportApplicationDataH2HeaderBlocks(
        session: ContractHttpServerAcceptedTransportSession,
        encodedRecords: Array<Array<Byte>>
    ): Array<JinguiAcceptedTransportH2HeaderBlockSnapshot> {
        loadTlsIngressContext()
            .openAndIngressJinguiAcceptedTransportApplicationDataH2HeaderBlocks(
                session,
                encodedRecords
            )
    }

    public func buildJinguiAcceptedTransportApplicationDataH2HeaderBlockIngressAccumulator(
        session: ContractHttpServerAcceptedTransportSession
    ): JinguiAcceptedTransportApplicationDataH2HeaderBlockIngressAccumulator {
        loadTlsIngressContext()
            .buildJinguiAcceptedTransportApplicationDataH2HeaderBlockIngressAccumulator(
                session
            )
    }

    public func buildJinguiAcceptedTransportApplicationDataH2HeaderBlockLogicalRequestAccumulator(
        session: ContractHttpServerAcceptedTransportSession,
        bodyBytes!: Array<UInt8> = []
    ): JinguiAcceptedTransportApplicationDataH2HeaderBlockLogicalRequestAccumulator {
        loadTlsIngressContext()
            .buildJinguiAcceptedTransportApplicationDataH2HeaderBlockLogicalRequestAccumulator(
                session,
                bodyBytes: bodyBytes
            )
    }

    public func buildJinguiAcceptedTransportApplicationDataH2HeadersPlusDataLogicalRequestAccumulator(
        session: ContractHttpServerAcceptedTransportSession,
        hpackDecoderState!: ?ServerJinguiAcceptedTransportH2HpackDecoderState = None
    ): JinguiAcceptedTransportApplicationDataH2HeadersPlusDataLogicalRequestAccumulator {
        loadTlsIngressContext()
            .buildJinguiAcceptedTransportApplicationDataH2HeadersPlusDataLogicalRequestAccumulator(
                session,
                hpackDecoderState: hpackDecoderState
            )
    }

    public func openAndBuildJinguiAcceptedTransportLogicalRequestFromApplicationDataH2HeaderBlock(
        session: ContractHttpServerAcceptedTransportSession,
        encodedRecords: Array<Array<Byte>>,
        bodyBytes!: Array<UInt8> = []
    ): ServerJinguiAcceptedTransportLogicalRequest {
        loadTlsIngressContext()
            .openAndBuildJinguiAcceptedTransportLogicalRequestFromApplicationDataH2HeaderBlock(
                session,
                encodedRecords,
                bodyBytes: bodyBytes
            )
    }

    public func openAndBuildJinguiAcceptedTransportLogicalRequestFromApplicationDataH2HeadersPlusData(
        session: ContractHttpServerAcceptedTransportSession,
        encodedRecords: Array<Array<Byte>>
    ): ServerJinguiAcceptedTransportLogicalRequest {
        loadTlsIngressContext()
            .openAndBuildJinguiAcceptedTransportLogicalRequestFromApplicationDataH2HeadersPlusData(
                session,
                encodedRecords
            )
    }

    public func openJinguiAcceptedTransportApplicationDataResponseTransportWriter(
        session: ContractHttpServerAcceptedTransportSession,
        downstream: ResponseTransportWriter,
        maxFragmentLen!: Int64 = 16384
    ): ResponseTransportWriter {
        loadTlsIngressContext()
            .openJinguiAcceptedTransportApplicationDataResponseTransportWriter(
                session,
                downstream,
                maxFragmentLen: maxFragmentLen
            )
    }

    public func wrapCurrentRequestCarrierWithJinguiAcceptedTransportApplicationDataResponse(
        session: ContractHttpServerAcceptedTransportSession,
        downstream: CurrentRequestCarrier,
        maxFragmentLen!: Int64 = 16384
    ): CurrentRequestCarrier {
        loadTlsIngressContext()
            .wrapCurrentRequestCarrierWithJinguiAcceptedTransportApplicationDataResponse(
                session,
                downstream,
                maxFragmentLen: maxFragmentLen
            )
    }

    public func buildJinguiAcceptedTransportSessionSnapshot(
        session: ContractHttpServerAcceptedTransportSession
    ): ServerJinguiAcceptedTransportSessionSnapshot {
        loadTlsIngressContext().buildJinguiAcceptedTransportSessionSnapshot(
            session
        )
    }

    public func notifyJinguiAcceptedTransportSessionSnapshot(
        snapshot: ServerJinguiAcceptedTransportSessionSnapshot
    ): Unit {
        if (let Some(hook) <- jinguiAcceptedTransportSessionHook) {
            hook(snapshot)
        }
    }

    public func notifyJinguiAcceptedTransportSession(
        session: ContractHttpServerAcceptedTransportSession
    ): ServerJinguiAcceptedTransportSessionSnapshot {
        let snapshot = buildJinguiAcceptedTransportSessionSnapshot(session)
        notifyJinguiAcceptedTransportSessionSnapshot(snapshot)
        snapshot
    }

    func serveJinguiAcceptedTransportSessionLogicalRequestTurnCore(
        session: ContractHttpServerAcceptedTransportSession,
        acceptedSocket: TcpSocket,
        app: App,
        request: ServerJinguiAcceptedTransportLogicalRequest,
        maxFragmentLen!: Int64 = 16384,
        closeSocketAfterTurn!: Bool = true
    ): ServerJinguiAcceptedTransportSocketResponseTurnResult {
        let readySnapshot = notifyJinguiAcceptedTransportSession(session)
        let carrier = ServerJinguiAcceptedTransportSocketResponseCarrier(
            request,
            acceptedSocket
        )
        let wrappedCarrier =
            wrapCurrentRequestCarrierWithJinguiAcceptedTransportApplicationDataResponse(
                session,
                carrier,
                maxFragmentLen: maxFragmentLen
            )
        try {
            app.handleRequest(wrappedCarrier)
            ServerJinguiAcceptedTransportSocketResponseTurnResult(
                session,
                readySnapshot,
                carrier.responseStatus,
                cloneServerEngineHeaders(carrier.responseHeaders),
                carrier.responseWriterLifecycle.socketWriteCount,
                carrier.responseWriterLifecycle.totalEncodedSocketBytes
            )
        } finally {
            if (closeSocketAfterTurn && !acceptedSocket.isClosed()) {
                acceptedSocket.close()
            }
        }
    }

    func serveJinguiAcceptedTransportSessionLogicalRequestH2DataResponseTurnCore(
        session: ContractHttpServerAcceptedTransportSession,
        acceptedSocket: TcpSocket,
        app: App,
        request: ServerJinguiAcceptedTransportLogicalRequest,
        maxFragmentLen!: Int64 = 16384,
        closeSocketAfterTurn!: Bool = true,
        responseInitialConnectionSendBudget!: ?Int64 = None,
        responseInitialStreamSendBudget!: ?Int64 = None,
        responseWindowUpdateFramesBeforeRetry!:
            Array<JinguiAcceptedTransportH2FrameWireSnapshot> = [],
        responseWindowUpdateFramePoller!:
            ?JinguiAcceptedTransportH2PeerControlFramePoller = None,
        responseWindowUpdateMaxPollAttempts!: Int64 = 1,
        responseSchedulerTrace!:
            ?JinguiAcceptedTransportH2ResponseTurnSchedulerTrace = None
    ): ServerJinguiAcceptedTransportSocketResponseTurnResult {
        let readySnapshot = notifyJinguiAcceptedTransportSession(session)
        let carrier = ServerJinguiAcceptedTransportSocketResponseCarrier(
            request,
            acceptedSocket
        )
        let capturedBodyWrites = ArrayList<Array<UInt8>>()
        let captureCarrier =
            wrapCurrentRequestCarrierResponseWriter(carrier, { =>
                openSinkBackedResponseTransportWriter({ bytes =>
                    capturedBodyWrites.add(cloneServerEngineUInt8Array(bytes))
                })
            })
        let wrappedCarrier =
            wrapCurrentRequestCarrierWithJinguiAcceptedTransportApplicationDataResponse(
                session,
                carrier,
                maxFragmentLen: maxFragmentLen
            )
        try {
            app.handleRequest(captureCarrier)
            commitJinguiAcceptedTransportCapturedH2DataResponseBody(
                session,
                request,
                wrappedCarrier,
                carrier.responseStatus,
                carrier.responseHeaderFieldsForH2(),
                capturedBodyWrites,
                responseInitialConnectionSendBudget:
                    responseInitialConnectionSendBudget,
                responseInitialStreamSendBudget:
                    responseInitialStreamSendBudget,
                responseWindowUpdateFramesBeforeRetry:
                    responseWindowUpdateFramesBeforeRetry,
                responseWindowUpdateFramePoller:
                    responseWindowUpdateFramePoller,
                responseWindowUpdateMaxPollAttempts:
                    responseWindowUpdateMaxPollAttempts,
                responseSchedulerTrace: responseSchedulerTrace,
                responseWriterLifecycle: Some(carrier.responseWriterLifecycle)
            )
            ServerJinguiAcceptedTransportSocketResponseTurnResult(
                session,
                readySnapshot,
                carrier.responseStatus,
                cloneServerEngineHeaders(carrier.responseHeaders),
                carrier.responseWriterLifecycle.socketWriteCount,
                carrier.responseWriterLifecycle.totalEncodedSocketBytes
            )
        } finally {
            if (closeSocketAfterTurn && !acceptedSocket.isClosed()) {
                acceptedSocket.close()
            }
        }
    }

    public func serveJinguiAcceptedTransportSessionLogicalRequestH2DataResponseTurn(
        session: ContractHttpServerAcceptedTransportSession,
        acceptedSocket: TcpSocket,
        app: App,
        request: ServerJinguiAcceptedTransportLogicalRequest,
        maxFragmentLen!: Int64 = 16384,
        closeSocketAfterTurn!: Bool = true,
        responseInitialConnectionSendBudget!: ?Int64 = None,
        responseInitialStreamSendBudget!: ?Int64 = None,
        responseWindowUpdateFramesBeforeRetry!:
            Array<JinguiAcceptedTransportH2FrameWireSnapshot> = [],
        responseWindowUpdateFramePoller!:
            ?JinguiAcceptedTransportH2PeerControlFramePoller = None,
        responseWindowUpdateMaxPollAttempts!: Int64 = 1,
        responseSchedulerTrace!:
            ?JinguiAcceptedTransportH2ResponseTurnSchedulerTrace = None
    ): ServerJinguiAcceptedTransportSocketResponseTurnResult {
        serveJinguiAcceptedTransportSessionLogicalRequestH2DataResponseTurnCore(
            session,
            acceptedSocket,
            app,
            request,
            maxFragmentLen: maxFragmentLen,
            closeSocketAfterTurn: closeSocketAfterTurn,
            responseInitialConnectionSendBudget:
                responseInitialConnectionSendBudget,
            responseInitialStreamSendBudget:
                responseInitialStreamSendBudget,
            responseWindowUpdateFramesBeforeRetry:
                responseWindowUpdateFramesBeforeRetry,
            responseWindowUpdateFramePoller:
                responseWindowUpdateFramePoller,
            responseWindowUpdateMaxPollAttempts:
                responseWindowUpdateMaxPollAttempts,
            responseSchedulerTrace: responseSchedulerTrace
        )
    }

    func commitJinguiAcceptedTransportCapturedH2DataResponseBody(
        session: ContractHttpServerAcceptedTransportSession,
        request: ServerJinguiAcceptedTransportLogicalRequest,
        wrappedCarrier: CurrentRequestCarrier,
        responseStatus: UInt16,
        responseHeaders: Array<ServerJinguiAcceptedTransportResponseHeaderField>,
        capturedBodyWrites: ArrayList<Array<UInt8>>,
        responseInitialConnectionSendBudget!: ?Int64 = None,
        responseInitialStreamSendBudget!: ?Int64 = None,
        responseWindowUpdateFramesBeforeRetry!:
            Array<JinguiAcceptedTransportH2FrameWireSnapshot> = [],
        responseWindowUpdateFramePoller!:
            ?JinguiAcceptedTransportH2PeerControlFramePoller = None,
        responseWindowUpdateMaxPollAttempts!: Int64 = 1,
        responseSchedulerTrace!:
            ?JinguiAcceptedTransportH2ResponseTurnSchedulerTrace = None,
        responseWriterLifecycle!:
            ?ServerJinguiAcceptedTransportSocketResponseWriterLifecycle = None
    ): Unit {
        var totalCapturedBytes: Int64 = 0
        for (bodyWrite in capturedBodyWrites) {
            totalCapturedBytes += bodyWrite.size
        }
        let handoff =
            JinguiAcceptedTransportH2AcceptedSocketResponseWriterHandoffGate(
                buildServerJinguiAcceptedTransportDescriptorSnapshot(
                    session.transport
                ),
                wrappedCarrier
            )
        let schedulerTrace =
            match (responseSchedulerTrace) {
                case Some(trace) => trace
                case None =>
                    JinguiAcceptedTransportH2ResponseTurnSchedulerTrace(
                        request.streamId
                    )
            }
        if (totalCapturedBytes <= 0) {
            let _ =
                handoff.commitFrameWireSnapshot(
                    "accepted-socket-application-data-empty-response-headers-turn",
                    buildJinguiAcceptedTransportH2ResponseHeadersFrameWireSnapshot(
                        request.streamId,
                        responseStatus,
                        responseHeaders,
                        endStream: true
                    )
                )
            schedulerTrace.markCompleted()
            return
        }
        let _ =
            handoff.commitFrameWireSnapshot(
                "accepted-socket-application-data-response-headers-turn",
                buildJinguiAcceptedTransportH2ResponseHeadersFrameWireSnapshot(
                    request.streamId,
                    responseStatus,
                    responseHeaders
                )
            )
        let responseBudget = totalCapturedBytes + 16384
        let initialConnectionSendBudget =
            match (responseInitialConnectionSendBudget) {
                case Some(budget) => budget
                case None => responseBudget
            }
        let initialStreamSendBudget =
            match (responseInitialStreamSendBudget) {
                case Some(budget) => budget
                case None => responseBudget
            }
        let model =
            JinguiAcceptedTransportH2FlowBudgetModel(
                initialConnectionSendBudget,
                initialStreamSendBudget
            )
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                request.streamId,
                false,
                false,
                false,
                false,
                0,
                0,
                serverEngineUInt8ToByteArray(request.path.toArray())
            )
        )
        var i: Int64 = 0
        while (i < capturedBodyWrites.size) {
            let bodyWrite = capturedBodyWrites[i]
            if (bodyWrite.size > 0) {
                let endStream = i + 1 == capturedBodyWrites.size
                let payload = serverEngineUInt8ToByteArray(bodyWrite)
                let _ =
                    queue.enqueueDataLengthWithEndStream(
                        request.streamId,
                        payload.size,
                        endStream
                    )
                schedulerTrace.recordQueuedBodyWrite(byteCount: payload.size)
                let staticRetryWindowUpdatesAvailable =
                    request.peerWindowUpdateFrames.size > 0 ||
                    responseWindowUpdateFramesBeforeRetry.size > 0
                let dynamicRetryWindowUpdatePollerAvailable =
                    match (responseWindowUpdateFramePoller) {
                        case Some(_) => true
                        case None => false
                    }
                var staticRetryWindowUpdatesConsumed = false
                var recoveryRound: Int64 = 0
                let recoveryRoundLimit =
                    if (responseWindowUpdateMaxPollAttempts > 0) {
                        responseWindowUpdateMaxPollAttempts
                    } else {
                        1
                    }
                var payloadCommitted = false
                var payloadOffset: Int64 = 0
                while (!payloadCommitted) {
                    schedulerTrace.recordWriteAttempt()
                    try {
                        let chunkByteCount =
                            nextJinguiAcceptedTransportH2ResponseDataChunkByteCount(
                                payload.size,
                                payloadOffset,
                                model,
                                request.streamId
                            )
                        let chunk =
                            cloneServerEngineByteWindow(
                                payload,
                                payloadOffset,
                                chunkByteCount
                            )
                        let _ =
                            handoff.commitNextQueuedDataPayload(
                                "accepted-socket-application-data-response-writer-turn",
                                queue,
                                chunk
                            )
                        payloadOffset += chunkByteCount
                        schedulerTrace.recordCommittedBodyBytes(
                            chunkByteCount
                        )
                        schedulerTrace.recordCommittedDataFrame()
                        payloadCommitted = payloadOffset >= payload.size
                    } catch (e: Exception) {
                        if (
                            !isJinguiAcceptedTransportH2WaitingForWindowUpdateError(
                                e
                            )
                        ) {
                            throw e
                        }
                        if (
                            recoveryRound >= recoveryRoundLimit ||
                            (
                                staticRetryWindowUpdatesAvailable &&
                                staticRetryWindowUpdatesConsumed
                            )
                        ) {
                            schedulerTrace.recordClose(
                                jinguiAcceptedTransportH2ResponseWindowUpdateStallCloseReason()
                            )
                            closeJinguiAcceptedTransportH2ResponseWriterLifecycleAfterWindowUpdateStall(
                                responseWriterLifecycle
                            )
                            throwJinguiAcceptedTransportH2ResponseWindowUpdateStallClosed(
                                e,
                                responseWriterLifecycle
                            )
                        }
                        let retryWindowUpdateResolution =
                            resolveJinguiAcceptedTransportH2ResponseRetryWindowUpdateFrames(
                                request,
                                responseWindowUpdateFramesBeforeRetry,
                                responseWindowUpdateFramePoller:
                                    responseWindowUpdateFramePoller,
                                responseWindowUpdateMaxPollAttempts:
                                    if (
                                        dynamicRetryWindowUpdatePollerAvailable &&
                                        !staticRetryWindowUpdatesAvailable
                                    ) {
                                        1
                                    } else {
                                        responseWindowUpdateMaxPollAttempts
                                    }
                            )
                        let retryWindowUpdateFrames =
                            retryWindowUpdateResolution.frames
                        recoveryRound += 1
                        schedulerTrace.recordWindowUpdateFrameResolution(
                            retryWindowUpdateResolution
                        )
                        if (dynamicRetryWindowUpdatePollerAvailable) {
                            schedulerTrace.recordPeerControlPollRound(
                                retryWindowUpdateFrames
                            )
                        }
                        if (retryWindowUpdateFrames.size == 0) {
                            if (
                                dynamicRetryWindowUpdatePollerAvailable &&
                                !staticRetryWindowUpdatesAvailable &&
                                recoveryRound < recoveryRoundLimit
                            ) {
                                continue
                            }
                            schedulerTrace.recordClose(
                                jinguiAcceptedTransportH2ResponseWindowUpdateStallCloseReason()
                            )
                            closeJinguiAcceptedTransportH2ResponseWriterLifecycleAfterWindowUpdateStall(
                                responseWriterLifecycle
                            )
                            throwJinguiAcceptedTransportH2ResponseWindowUpdateStallClosed(
                                e,
                                responseWriterLifecycle
                            )
                        }
                        for (frame in retryWindowUpdateFrames) {
                            let _ = model.observeWindowUpdateFrame(frame)
                        }
                        if (staticRetryWindowUpdatesAvailable) {
                            staticRetryWindowUpdatesConsumed = true
                        }
                    }
                    if (payloadCommitted) {
                        schedulerTrace.recordCommittedBodyWrite()
                    }
                }
            }
            i += 1
        }
        schedulerTrace.markCompleted()
    }

    func nextJinguiAcceptedTransportH2ResponseDataChunkByteCount(
        payloadSize: Int64,
        payloadOffset: Int64,
        model: JinguiAcceptedTransportH2FlowBudgetModel,
        streamId: Int64
    ): Int64 {
        let remaining = payloadSize - payloadOffset
        if (remaining <= 0) {
            throw Exception(
                "H2 response DATA chunk requires positive remaining payload bytes, remaining=${remaining}"
            )
        }
        var chunkLimit: Int64 = 16384
        if (remaining < chunkLimit) {
            chunkLimit = remaining
        }
        let connectionBudget = model.connectionSendBudget()
        let streamBudget = model.streamSendBudget(streamId)
        if (connectionBudget < chunkLimit) {
            chunkLimit = connectionBudget
        }
        if (streamBudget < chunkLimit) {
            chunkLimit = streamBudget
        }
        if (chunkLimit > 0) {
            return chunkLimit
        }
        1
    }

    func isJinguiAcceptedTransportH2WaitingForWindowUpdateError(
        e: Exception
    ): Bool {
        e.message.contains("waiting for WINDOW_UPDATE")
    }

    func jinguiAcceptedTransportH2ResponseWindowUpdateStallCloseReason(): String {
        "h2-response-data-window-update-stall"
    }

    func closeJinguiAcceptedTransportH2ResponseWriterLifecycleAfterWindowUpdateStall(
        responseWriterLifecycle:
            ?ServerJinguiAcceptedTransportSocketResponseWriterLifecycle
    ): Unit {
        match (responseWriterLifecycle) {
            case Some(lifecycle) =>
                if (!lifecycle.closed) {
                    lifecycle.closeResponseWriterLifecycle(
                        reason:
                            jinguiAcceptedTransportH2ResponseWindowUpdateStallCloseReason()
                    )
                }
            case None => ()
        }
    }

    func jinguiAcceptedTransportH2ResponseWindowUpdateStallLifecycleStatus(
        responseWriterLifecycle:
            ?ServerJinguiAcceptedTransportSocketResponseWriterLifecycle
    ): String {
        match (responseWriterLifecycle) {
            case Some(lifecycle) =>
                let closedStatus = if (lifecycle.closed) { "true" } else { "false" }
                "closed=${closedStatus}; reason=${lifecycle.closeReason}"
            case None => "closed=unknown; reason=no-lifecycle"
        }
    }

    func throwJinguiAcceptedTransportH2ResponseWindowUpdateStallClosed(
        e: Exception,
        responseWriterLifecycle:
            ?ServerJinguiAcceptedTransportSocketResponseWriterLifecycle
    ): Nothing {
        throw Exception(
            "${e.message}; response writer lifecycle closed: ${jinguiAcceptedTransportH2ResponseWindowUpdateStallCloseReason()}; lifecycle ${jinguiAcceptedTransportH2ResponseWindowUpdateStallLifecycleStatus(responseWriterLifecycle)}"
        )
    }

    func resolveJinguiAcceptedTransportH2ResponseRetryWindowUpdateFrames(
        request: ServerJinguiAcceptedTransportLogicalRequest,
        explicitWindowUpdateFrames:
            Array<JinguiAcceptedTransportH2FrameWireSnapshot>,
        responseWindowUpdateFramePoller!:
            ?JinguiAcceptedTransportH2PeerControlFramePoller = None,
        responseWindowUpdateMaxPollAttempts!: Int64 = 1
    ): JinguiAcceptedTransportH2ResponseRetryWindowUpdateFrameResolution {
        if (request.peerWindowUpdateFrames.size > 0) {
            return JinguiAcceptedTransportH2ResponseRetryWindowUpdateFrameResolution(
                request.peerWindowUpdateFrames,
                request.peerWindowUpdateFrames.size,
                0,
                0,
                0
            )
        }
        if (explicitWindowUpdateFrames.size > 0) {
            return JinguiAcceptedTransportH2ResponseRetryWindowUpdateFrameResolution(
                explicitWindowUpdateFrames,
                0,
                explicitWindowUpdateFrames.size,
                0,
                0
            )
        }
        match (responseWindowUpdateFramePoller) {
            case Some(poller) =>
                let pollAttempts = if (responseWindowUpdateMaxPollAttempts > 0) {
                    responseWindowUpdateMaxPollAttempts
                } else {
                    1
                }
                var attempt: Int64 = 0
                var pollerAttemptCount: Int64 = 0
                while (attempt < pollAttempts) {
                    let frames = poller()
                    pollerAttemptCount += 1
                    if (frames.size > 0) {
                        return JinguiAcceptedTransportH2ResponseRetryWindowUpdateFrameResolution(
                            frames,
                            0,
                            0,
                            frames.size,
                            pollerAttemptCount
                        )
                    }
                    attempt += 1
                }
                JinguiAcceptedTransportH2ResponseRetryWindowUpdateFrameResolution(
                    [],
                    0,
                    0,
                    0,
                    pollerAttemptCount
                )
            case None =>
                JinguiAcceptedTransportH2ResponseRetryWindowUpdateFrameResolution(
                    [],
                    0,
                    0,
                    0,
                    0
                )
        }
    }

    public func buildJinguiAcceptedTransportH2SocketPeerWindowUpdateFramePoller(
        session: ContractHttpServerAcceptedTransportSession,
        acceptedSocket: TcpSocket,
        streamId: Int64,
        readChunkSize!: Int64 = 4096,
        maxReadAttempts!: Int64 = 1
    ): JinguiAcceptedTransportH2PeerControlFramePoller {
        let chunkSize = if (readChunkSize > 0) {
            readChunkSize
        } else {
            4096
        }
        let readAttempts = if (maxReadAttempts > 0) {
            maxReadAttempts
        } else {
            1
        }
        let recordAccumulator = JinguiAcceptedTransportRecordWireAccumulator()
        let frameAccumulator = JinguiAcceptedTransportH2FrameWireAccumulator()
        { =>
            let out = ArrayList<JinguiAcceptedTransportH2FrameWireSnapshot>()
            var attempt: Int64 = 0
            while (attempt < readAttempts && out.size == 0) {
                let buf = Array<UInt8>(chunkSize, repeat: 0)
                let n = acceptedSocket.read(buf)
                if (n <= 0) {
                    break
                }
                recordAccumulator.append(
                    serverEngineUInt8ToByteArray(buf[..n])
                )
                let records = recordAccumulator.drainCompleteRecords()
                if (records.size > 0) {
                    frameAccumulator.append(
                        openAndReassembleJinguiAcceptedTransportApplicationData(
                            session,
                            records
                        )
                    )
                }
                let filtered =
                    filterJinguiAcceptedTransportH2SocketPeerWindowUpdateFrames(
                        streamId,
                        frameAccumulator.drainCompleteFrames()
                    )
                for (frame in filtered) {
                    out.add(frame)
                }
                attempt += 1
            }
            out.toArray()
        }
    }

    func filterJinguiAcceptedTransportH2SocketPeerWindowUpdateFrames(
        streamId: Int64,
        frameWires: Array<Array<Byte>>
    ): Array<JinguiAcceptedTransportH2FrameWireSnapshot> {
        let out = ArrayList<JinguiAcceptedTransportH2FrameWireSnapshot>()
        for (frameWire in frameWires) {
            let frame = parseJinguiAcceptedTransportH2FrameWire(frameWire)
            if (frame.frameType != UInt8(0x8)) {
                continue
            }
            let windowUpdate =
                parseJinguiAcceptedTransportH2WindowUpdateFrame(frame)
            if (windowUpdate.connectionScoped || windowUpdate.streamId == streamId) {
                out.add(frame)
            }
        }
        out.toArray()
    }

    func serveJinguiAcceptedTransportSessionApplicationDataLogicalRequestTurnBuildAndServeCore(
        session: ContractHttpServerAcceptedTransportSession,
        acceptedSocket: TcpSocket,
        app: App,
        encodedRequestRecords: Array<Array<Byte>>,
        requestBuilder: (
            ContractHttpServerAcceptedTransportSession,
            Array<Array<Byte>>
        ) -> ServerJinguiAcceptedTransportLogicalRequest,
        maxFragmentLen!: Int64 = 16384,
        closeSocketAfterTurn!: Bool = true
    ): ServerJinguiAcceptedTransportSocketResponseTurnResult {
        let request = requestBuilder(session, encodedRequestRecords)
        serveJinguiAcceptedTransportSessionLogicalRequestTurnCore(
            session,
            acceptedSocket,
            app,
            request,
            maxFragmentLen: maxFragmentLen,
            closeSocketAfterTurn: closeSocketAfterTurn
        )
    }
    func buildJinguiAcceptedTransportLogicalRequestFromApplicationDataFragmentedRecordWireH2HeaderBlockCore(
        session: ContractHttpServerAcceptedTransportSession,
        encodedRequestWireFragments: Array<Array<Byte>>,
        bodyBytes!: Array<UInt8> = []
    ): ServerJinguiAcceptedTransportLogicalRequest {
        let requestAccumulator =
            buildJinguiAcceptedTransportApplicationDataH2HeaderBlockLogicalRequestAccumulator(
                session,
                bodyBytes: bodyBytes
            )
        var request: ?ServerJinguiAcceptedTransportLogicalRequest = None
        var requestCount: Int64 = 0
        for (fragment in encodedRequestWireFragments) {
            requestAccumulator.append(fragment)
            let completed = requestAccumulator.drainCompleteLogicalRequests()
            if (completed.size == 0) {
                continue
            }
            request = Some(completed[0])
            requestCount += Int64(completed.size)
        }
        if (requestCount != 1) {
            throw Exception(
                "accepted-session application-data fragmented-record-wire request-turn expects exactly one logical request, got count=${requestCount}"
            )
        }
        let bufferedRecordWireBytes =
            requestAccumulator.bufferedRecordWireByteCount()
        let bufferedH2FrameWireBytes =
            requestAccumulator.bufferedH2FrameWireByteCount()
        let hasOpenHeaderBlock =
            requestAccumulator.hasOpenHeaderBlock()
        let bufferedHeaderBlockBytes =
            requestAccumulator.bufferedHeaderBlockByteCount()
        if (
            bufferedRecordWireBytes != 0 ||
            bufferedH2FrameWireBytes != 0 ||
            hasOpenHeaderBlock ||
            bufferedHeaderBlockBytes != 0
        ) {
            throw Exception(
                "accepted-session application-data fragmented-record-wire request-turn expects fully drained ingress after one logical request, bufferedRecordWireBytes=${bufferedRecordWireBytes}, bufferedH2FrameWireBytes=${bufferedH2FrameWireBytes}, hasOpenHeaderBlock=${hasOpenHeaderBlock}, bufferedHeaderBlockBytes=${bufferedHeaderBlockBytes}"
            )
        }
        match (request) {
            case Some(logicalRequest) => logicalRequest
            case None =>
                throw Exception(
                    "accepted-session application-data fragmented-record-wire request-turn expected one logical request after count check"
                )
        }
    }

    func buildJinguiAcceptedTransportLogicalRequestFromApplicationDataFragmentedRecordWireH2HeadersPlusDataCore(
        session: ContractHttpServerAcceptedTransportSession,
        encodedRequestWireFragments: Array<Array<Byte>>
    ): ServerJinguiAcceptedTransportLogicalRequest {
        let requestAccumulator =
            buildJinguiAcceptedTransportApplicationDataH2HeadersPlusDataLogicalRequestAccumulator(
                session
            )
        var request: ?ServerJinguiAcceptedTransportLogicalRequest = None
        var requestCount: Int64 = 0
        for (fragment in encodedRequestWireFragments) {
            requestAccumulator.append(fragment)
            let completed = requestAccumulator.drainCompleteLogicalRequests()
            if (completed.size == 0) {
                continue
            }
            request = Some(completed[0])
            requestCount += Int64(completed.size)
        }
        if (requestCount != 1) {
            throw Exception(
                "accepted-session application-data fragmented-record-wire headers-plus-data request-turn expects exactly one logical request, got count=${requestCount}"
            )
        }
        let bufferedRecordWireBytes =
            requestAccumulator.bufferedRecordWireByteCount()
        let bufferedH2FrameWireBytes =
            requestAccumulator.bufferedH2FrameWireByteCount()
        let hasOpenHeaderBlock =
            requestAccumulator.hasOpenHeaderBlock()
        let bufferedHeaderBlockBytes =
            requestAccumulator.bufferedHeaderBlockByteCount()
        let bufferedBodyBytes =
            requestAccumulator.bufferedBodyByteCount()
        if (
            bufferedRecordWireBytes != 0 ||
            bufferedH2FrameWireBytes != 0 ||
            hasOpenHeaderBlock ||
            bufferedHeaderBlockBytes != 0 ||
            bufferedBodyBytes != 0
        ) {
            throw Exception(
                "accepted-session application-data fragmented-record-wire headers-plus-data request-turn expects fully drained ingress after one logical request, bufferedRecordWireBytes=${bufferedRecordWireBytes}, bufferedH2FrameWireBytes=${bufferedH2FrameWireBytes}, hasOpenHeaderBlock=${hasOpenHeaderBlock}, bufferedHeaderBlockBytes=${bufferedHeaderBlockBytes}, bufferedBodyBytes=${bufferedBodyBytes}"
            )
        }
        match (request) {
            case Some(logicalRequest) => logicalRequest
            case None =>
                throw Exception(
                    "accepted-session application-data fragmented-record-wire headers-plus-data request-turn expected one logical request after count check"
                )
        }
    }

    func buildJinguiAcceptedTransportLogicalRequestFromAcceptedSocketApplicationDataFragmentedRecordWireH2HeadersPlusDataCore(
        session: ContractHttpServerAcceptedTransportSession,
        acceptedSocket: TcpSocket,
        readChunkSize!: Int64 = 4096,
        hpackDecoderState!:
            ?ServerJinguiAcceptedTransportH2HpackDecoderState = None,
        requestAccumulator!:
            ?JinguiAcceptedTransportApplicationDataH2HeadersPlusDataLogicalRequestAccumulator = None
    ): ServerJinguiAcceptedTransportLogicalRequest {
        var allowBufferedCarryover = false
        var logicalRequestAccumulator =
            buildJinguiAcceptedTransportApplicationDataH2HeadersPlusDataLogicalRequestAccumulator(
                session,
                hpackDecoderState: hpackDecoderState
            )
        if (let Some(accumulator) <- requestAccumulator) {
            logicalRequestAccumulator = accumulator
            allowBufferedCarryover = true
        }
        let chunkSize = if (readChunkSize > 0) {
            readChunkSize
        } else {
            4096
        }
        let buf = Array<UInt8>(chunkSize, repeat: 0)
        logicalRequestAccumulator.append([])
        let carried = logicalRequestAccumulator.drainCompleteLogicalRequests()
        if (carried.size > 0) {
            if (carried.size != 1) {
                throw Exception(
                    "accepted-session accepted-socket fragmented-record-wire headers-plus-data request-turn expects exactly one buffered carryover logical request, got count=${carried.size}"
                )
            }
            return carried[0]
        }
        while (true) {
            let n = acceptedSocket.read(buf)
            if (n <= 0) {
                break
            }
            logicalRequestAccumulator.append(
                serverEngineUInt8ToByteArray(buf[..n])
            )
            let completed =
                logicalRequestAccumulator.drainCompleteLogicalRequests()
            if (completed.size == 0) {
                continue
            }
            if (completed.size != 1) {
                throw Exception(
                    "accepted-session accepted-socket fragmented-record-wire headers-plus-data request-turn expects exactly one logical request, got count=${completed.size}"
                )
            }
            if (!allowBufferedCarryover) {
                let bufferedRecordWireBytes =
                    logicalRequestAccumulator.bufferedRecordWireByteCount()
                let bufferedH2FrameWireBytes =
                    logicalRequestAccumulator.bufferedH2FrameWireByteCount()
                let hasOpenHeaderBlock =
                    logicalRequestAccumulator.hasOpenHeaderBlock()
                let bufferedHeaderBlockBytes =
                    logicalRequestAccumulator.bufferedHeaderBlockByteCount()
                let bufferedBodyBytes =
                    logicalRequestAccumulator.bufferedBodyByteCount()
                if (
                    bufferedRecordWireBytes != 0 ||
                    bufferedH2FrameWireBytes != 0 ||
                    hasOpenHeaderBlock ||
                    bufferedHeaderBlockBytes != 0 ||
                    bufferedBodyBytes != 0
                ) {
                    throw Exception(
                        "accepted-session accepted-socket fragmented-record-wire headers-plus-data request-turn expects fully drained ingress after one logical request, bufferedRecordWireBytes=${bufferedRecordWireBytes}, bufferedH2FrameWireBytes=${bufferedH2FrameWireBytes}, hasOpenHeaderBlock=${hasOpenHeaderBlock}, bufferedHeaderBlockBytes=${bufferedHeaderBlockBytes}, bufferedBodyBytes=${bufferedBodyBytes}"
                    )
                }
            }
            return completed[0]
        }
        let bufferedRecordWireBytes =
            logicalRequestAccumulator.bufferedRecordWireByteCount()
        let bufferedH2FrameWireBytes =
            logicalRequestAccumulator.bufferedH2FrameWireByteCount()
        let hasOpenHeaderBlock =
            logicalRequestAccumulator.hasOpenHeaderBlock()
        let bufferedHeaderBlockBytes =
            logicalRequestAccumulator.bufferedHeaderBlockByteCount()
        let bufferedBodyBytes =
            logicalRequestAccumulator.bufferedBodyByteCount()
        throw Exception(
            "accepted-session accepted-socket fragmented-record-wire headers-plus-data request-turn expected one logical request before socket read ended, bufferedRecordWireBytes=${bufferedRecordWireBytes}, bufferedH2FrameWireBytes=${bufferedH2FrameWireBytes}, hasOpenHeaderBlock=${hasOpenHeaderBlock}, bufferedHeaderBlockBytes=${bufferedHeaderBlockBytes}, bufferedBodyBytes=${bufferedBodyBytes}"
        )
    }

    func serveJinguiAcceptedTransportSessionApplicationDataFragmentedRecordWireLogicalRequestTurnBuildAndServeCore(
        session: ContractHttpServerAcceptedTransportSession,
        acceptedSocket: TcpSocket,
        app: App,
        encodedRequestWireFragments: Array<Array<Byte>>,
        requestBuilder: (
            ContractHttpServerAcceptedTransportSession,
            Array<Array<Byte>>
        ) -> ServerJinguiAcceptedTransportLogicalRequest,
        maxFragmentLen!: Int64 = 16384,
        closeSocketAfterTurn!: Bool = true
    ): ServerJinguiAcceptedTransportSocketResponseTurnResult {
        let request = requestBuilder(session, encodedRequestWireFragments)
        serveJinguiAcceptedTransportSessionLogicalRequestTurnCore(
            session,
            acceptedSocket,
            app,
            request,
            maxFragmentLen: maxFragmentLen,
            closeSocketAfterTurn: closeSocketAfterTurn
        )
    }

    public func serveJinguiAcceptedTransportSocketLogicalRequest(
        acceptedSocket: TcpSocket,
        app: App,
        request: ServerJinguiAcceptedTransportLogicalRequest,
        encodedClientHello: Array<Byte>,
        serverKeyExchangePrivate: Array<Byte>,
        transportId!: String = "accepted-transport",
        maxFragmentLen!: Int64 = 16384,
        closeSocketAfterTurn!: Bool = true,
        policy!: ContractTlsHttpNegotiationPolicy = ContractTlsHttpNegotiationPolicy()
    ): ServerJinguiAcceptedTransportSocketResponseTurnResult {
        let transport = buildServerAcceptedTransportDescriptorFromSocket(
            acceptedSocket,
            transportId
        )
        let session = attachJinguiAcceptedTransportTls13X25519(
            transport,
            encodedClientHello,
            serverKeyExchangePrivate,
            policy: policy
        )
        serveJinguiAcceptedTransportSessionLogicalRequestTurnCore(
            session,
            acceptedSocket,
            app,
            request,
            maxFragmentLen: maxFragmentLen,
            closeSocketAfterTurn: closeSocketAfterTurn
        )
    }

    public func serveJinguiAcceptedTransportSocketLogicalRequestH2DataResponseTurn(
        acceptedSocket: TcpSocket,
        app: App,
        request: ServerJinguiAcceptedTransportLogicalRequest,
        encodedClientHello: Array<Byte>,
        serverKeyExchangePrivate: Array<Byte>,
        transportId!: String = "accepted-transport",
        maxFragmentLen!: Int64 = 16384,
        closeSocketAfterTurn!: Bool = true,
        policy!: ContractTlsHttpNegotiationPolicy = ContractTlsHttpNegotiationPolicy(),
        responseInitialConnectionSendBudget!: ?Int64 = None,
        responseInitialStreamSendBudget!: ?Int64 = None,
        responseWindowUpdateFramesBeforeRetry!:
            Array<JinguiAcceptedTransportH2FrameWireSnapshot> = [],
        responseWindowUpdateFramePoller!:
            ?JinguiAcceptedTransportH2PeerControlFramePoller = None,
        responseWindowUpdateMaxPollAttempts!: Int64 = 1,
        responseSchedulerTrace!:
            ?JinguiAcceptedTransportH2ResponseTurnSchedulerTrace = None
    ): ServerJinguiAcceptedTransportSocketResponseTurnResult {
        let transport = buildServerAcceptedTransportDescriptorFromSocket(
            acceptedSocket,
            transportId
        )
        let session = attachJinguiAcceptedTransportTls13X25519(
            transport,
            encodedClientHello,
            serverKeyExchangePrivate,
            policy: policy
        )
        serveJinguiAcceptedTransportSessionLogicalRequestH2DataResponseTurnCore(
            session,
            acceptedSocket,
            app,
            request,
            maxFragmentLen: maxFragmentLen,
            closeSocketAfterTurn: closeSocketAfterTurn,
            responseInitialConnectionSendBudget:
                responseInitialConnectionSendBudget,
            responseInitialStreamSendBudget:
                responseInitialStreamSendBudget,
            responseWindowUpdateFramesBeforeRetry:
                responseWindowUpdateFramesBeforeRetry,
            responseWindowUpdateFramePoller:
                responseWindowUpdateFramePoller,
            responseWindowUpdateMaxPollAttempts:
                responseWindowUpdateMaxPollAttempts,
            responseSchedulerTrace: responseSchedulerTrace
        )
    }

    public func serveJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloLogicalRequest(
        acceptedSocket: TcpSocket,
        app: App,
        request: ServerJinguiAcceptedTransportLogicalRequest,
        serverKeyExchangePrivate: Array<Byte>,
        transportId!: String = "accepted-transport",
        readChunkSize!: Int64 = 4096,
        maxFragmentLen!: Int64 = 16384,
        closeSocketAfterTurn!: Bool = true,
        policy!: ContractTlsHttpNegotiationPolicy = ContractTlsHttpNegotiationPolicy()
    ): ServerJinguiAcceptedTransportSocketResponseTurnResult {
        let attached =
            attachJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloX25519Core(
                acceptedSocket,
                serverKeyExchangePrivate,
                transportId: transportId,
                readChunkSize: readChunkSize,
                policy: policy,
                notifyReadySnapshot: false
            )
        serveJinguiAcceptedTransportSessionLogicalRequestTurnCore(
            attached.session,
            acceptedSocket,
            app,
            request,
            maxFragmentLen: maxFragmentLen,
            closeSocketAfterTurn: closeSocketAfterTurn
        )
    }

    public func serveJinguiAcceptedTransportSessionApplicationDataFragmentedRecordWireH2ProvidedBodyRequestTurn(
        session: ContractHttpServerAcceptedTransportSession,
        acceptedSocket: TcpSocket,
        app: App,
        encodedRequestWireFragments: Array<Array<Byte>>,
        bodyBytes!: Array<UInt8> = [],
        maxFragmentLen!: Int64 = 16384,
        closeSocketAfterTurn!: Bool = true
    ): ServerJinguiAcceptedTransportSocketResponseTurnResult {
        serveJinguiAcceptedTransportSessionApplicationDataFragmentedRecordWireLogicalRequestTurnBuildAndServeCore(
            session,
            acceptedSocket,
            app,
            encodedRequestWireFragments,
            { currentSession, currentEncodedRequestWireFragments =>
                buildJinguiAcceptedTransportLogicalRequestFromApplicationDataFragmentedRecordWireH2HeaderBlockCore(
                    currentSession,
                    currentEncodedRequestWireFragments,
                    bodyBytes: bodyBytes
                )
            },
            maxFragmentLen: maxFragmentLen,
            closeSocketAfterTurn: closeSocketAfterTurn
        )
    }

    public func serveJinguiAcceptedTransportSessionApplicationDataFragmentedRecordWireH2HeadersPlusDataRequestTurn(
        session: ContractHttpServerAcceptedTransportSession,
        acceptedSocket: TcpSocket,
        app: App,
        encodedRequestWireFragments: Array<Array<Byte>>,
        maxFragmentLen!: Int64 = 16384,
        closeSocketAfterTurn!: Bool = true
    ): ServerJinguiAcceptedTransportSocketResponseTurnResult {
        serveJinguiAcceptedTransportSessionApplicationDataFragmentedRecordWireLogicalRequestTurnBuildAndServeCore(
            session,
            acceptedSocket,
            app,
            encodedRequestWireFragments,
            { currentSession, currentEncodedRequestWireFragments =>
                buildJinguiAcceptedTransportLogicalRequestFromApplicationDataFragmentedRecordWireH2HeadersPlusDataCore(
                    currentSession,
                    currentEncodedRequestWireFragments
                )
            },
            maxFragmentLen: maxFragmentLen,
            closeSocketAfterTurn: closeSocketAfterTurn
        )
    }

    public func serveJinguiAcceptedTransportSessionAcceptedSocketApplicationDataFragmentedRecordWireH2HeadersPlusDataRequestTurn(
        session: ContractHttpServerAcceptedTransportSession,
        acceptedSocket: TcpSocket,
        app: App,
        readChunkSize!: Int64 = 4096,
        maxFragmentLen!: Int64 = 16384,
        closeSocketAfterTurn!: Bool = true,
        hpackDecoderState!:
            ?ServerJinguiAcceptedTransportH2HpackDecoderState = None,
        requestAccumulator!:
            ?JinguiAcceptedTransportApplicationDataH2HeadersPlusDataLogicalRequestAccumulator = None
    ): ServerJinguiAcceptedTransportSocketResponseTurnResult {
        let request =
            buildJinguiAcceptedTransportLogicalRequestFromAcceptedSocketApplicationDataFragmentedRecordWireH2HeadersPlusDataCore(
                session,
                acceptedSocket,
                readChunkSize: readChunkSize,
                hpackDecoderState: hpackDecoderState,
                requestAccumulator: requestAccumulator
            )
        serveJinguiAcceptedTransportSessionLogicalRequestTurnCore(
            session,
            acceptedSocket,
            app,
            request,
            maxFragmentLen: maxFragmentLen,
            closeSocketAfterTurn: closeSocketAfterTurn
        )
    }

    public func serveJinguiAcceptedTransportSocketApplicationDataFragmentedRecordWireH2ProvidedBodyRequestTurn(
        acceptedSocket: TcpSocket,
        app: App,
        encodedRequestWireFragmentsBuilder:
            ServerJinguiAcceptedTransportAttachedSessionEncodedRequestWireFragmentsBuilder,
        encodedClientHello: Array<Byte>,
        serverKeyExchangePrivate: Array<Byte>,
        bodyBytes!: Array<UInt8> = [],
        transportId!: String = "accepted-transport",
        maxFragmentLen!: Int64 = 16384,
        closeSocketAfterTurn!: Bool = true,
        policy!: ContractTlsHttpNegotiationPolicy = ContractTlsHttpNegotiationPolicy()
    ): ServerJinguiAcceptedTransportSocketResponseTurnResult {
        let transport = buildServerAcceptedTransportDescriptorFromSocket(
            acceptedSocket,
            transportId
        )
        let session = attachJinguiAcceptedTransportTls13X25519(
            transport,
            encodedClientHello,
            serverKeyExchangePrivate,
            policy: policy
        )
        serveJinguiAcceptedTransportSessionApplicationDataFragmentedRecordWireH2ProvidedBodyRequestTurn(
            session,
            acceptedSocket,
            app,
            encodedRequestWireFragmentsBuilder(session),
            bodyBytes: bodyBytes,
            maxFragmentLen: maxFragmentLen,
            closeSocketAfterTurn: closeSocketAfterTurn
        )
    }

    public func serveJinguiAcceptedTransportSocketApplicationDataFragmentedRecordWireH2HeadersPlusDataRequestTurn(
        acceptedSocket: TcpSocket,
        app: App,
        encodedClientHello: Array<Byte>,
        serverKeyExchangePrivate: Array<Byte>,
        transportId!: String = "accepted-transport",
        readChunkSize!: Int64 = 4096,
        maxFragmentLen!: Int64 = 16384,
        closeSocketAfterTurn!: Bool = true,
        policy!: ContractTlsHttpNegotiationPolicy = ContractTlsHttpNegotiationPolicy(),
        hpackDecoderState!:
            ?ServerJinguiAcceptedTransportH2HpackDecoderState = None,
        attachedSessionReadyHook!:
            ?ServerJinguiAcceptedTransportAttachedSessionReadyHook = None
    ): ServerJinguiAcceptedTransportSocketResponseTurnResult {
        let transport = buildServerAcceptedTransportDescriptorFromSocket(
            acceptedSocket,
            transportId
        )
        let session = attachJinguiAcceptedTransportTls13X25519(
            transport,
            encodedClientHello,
            serverKeyExchangePrivate,
            policy: policy
        )
        if (let Some(hook) <- attachedSessionReadyHook) {
            hook(session)
        }
        serveJinguiAcceptedTransportSessionAcceptedSocketApplicationDataFragmentedRecordWireH2HeadersPlusDataRequestTurn(
            session,
            acceptedSocket,
            app,
            readChunkSize: readChunkSize,
            maxFragmentLen: maxFragmentLen,
            closeSocketAfterTurn: closeSocketAfterTurn,
            hpackDecoderState: hpackDecoderState
        )
    }

    public func serveJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataFragmentedRecordWireH2HeadersPlusDataRequestTurn(
        acceptedSocket: TcpSocket,
        app: App,
        serverKeyExchangePrivate: Array<Byte>,
        transportId!: String = "accepted-transport",
        readChunkSize!: Int64 = 4096,
        maxFragmentLen!: Int64 = 16384,
        closeSocketAfterTurn!: Bool = true,
        policy!: ContractTlsHttpNegotiationPolicy = ContractTlsHttpNegotiationPolicy(),
        hpackDecoderState!:
            ?ServerJinguiAcceptedTransportH2HpackDecoderState = None,
        attachedSessionReadyHook!:
            ?ServerJinguiAcceptedTransportAttachedSessionReadyHook = None
    ): ServerJinguiAcceptedTransportSocketResponseTurnResult {
        let attached =
            attachJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloX25519Core(
                acceptedSocket,
                serverKeyExchangePrivate,
                transportId: transportId,
                readChunkSize: readChunkSize,
                policy: policy,
                notifyReadySnapshot: false
            )
        if (let Some(hook) <- attachedSessionReadyHook) {
            hook(attached.session)
        }
        serveJinguiAcceptedTransportSessionAcceptedSocketApplicationDataFragmentedRecordWireH2HeadersPlusDataRequestTurn(
            attached.session,
            acceptedSocket,
            app,
            readChunkSize: readChunkSize,
            maxFragmentLen: maxFragmentLen,
            closeSocketAfterTurn: closeSocketAfterTurn,
            hpackDecoderState: hpackDecoderState
        )
    }

    public func serveJinguiAcceptedTransportSessionApplicationDataH2ProvidedBodyRequestTurn(
        session: ContractHttpServerAcceptedTransportSession,
        acceptedSocket: TcpSocket,
        app: App,
        encodedRequestRecords: Array<Array<Byte>>,
        bodyBytes!: Array<UInt8> = [],
        maxFragmentLen!: Int64 = 16384,
        closeSocketAfterTurn!: Bool = true
    ): ServerJinguiAcceptedTransportSocketResponseTurnResult {
        serveJinguiAcceptedTransportSessionApplicationDataLogicalRequestTurnBuildAndServeCore(
            session,
            acceptedSocket,
            app,
            encodedRequestRecords,
            { currentSession, currentEncodedRequestRecords =>
                openAndBuildJinguiAcceptedTransportLogicalRequestFromApplicationDataH2HeaderBlock(
                    currentSession,
                    currentEncodedRequestRecords,
                    bodyBytes: bodyBytes
                )
            },
            maxFragmentLen: maxFragmentLen,
            closeSocketAfterTurn: closeSocketAfterTurn
        )
    }

    public func serveJinguiAcceptedTransportSessionApplicationDataH2HeadersPlusDataRequestTurn(
        session: ContractHttpServerAcceptedTransportSession,
        acceptedSocket: TcpSocket,
        app: App,
        encodedRequestRecords: Array<Array<Byte>>,
        maxFragmentLen!: Int64 = 16384,
        closeSocketAfterTurn!: Bool = true
    ): ServerJinguiAcceptedTransportSocketResponseTurnResult {
        serveJinguiAcceptedTransportSessionApplicationDataLogicalRequestTurnBuildAndServeCore(
            session,
            acceptedSocket,
            app,
            encodedRequestRecords,
            { currentSession, currentEncodedRequestRecords =>
                openAndBuildJinguiAcceptedTransportLogicalRequestFromApplicationDataH2HeadersPlusData(
                    currentSession,
                    currentEncodedRequestRecords
                )
            },
            maxFragmentLen: maxFragmentLen,
            closeSocketAfterTurn: closeSocketAfterTurn
        )
    }

    public func serveJinguiAcceptedTransportSessionApplicationDataH2BodylessRequestTurn(
        session: ContractHttpServerAcceptedTransportSession,
        acceptedSocket: TcpSocket,
        app: App,
        encodedRequestRecords: Array<Array<Byte>>,
        maxFragmentLen!: Int64 = 16384,
        closeSocketAfterTurn!: Bool = true
    ): ServerJinguiAcceptedTransportSocketResponseTurnResult {
        serveJinguiAcceptedTransportSessionApplicationDataH2ProvidedBodyRequestTurn(
            session,
            acceptedSocket,
            app,
            encodedRequestRecords,
            maxFragmentLen: maxFragmentLen,
            closeSocketAfterTurn: closeSocketAfterTurn
        )
    }

    public func serveJinguiAcceptedTransportSocketApplicationDataH2ProvidedBodyRequestTurn(
        acceptedSocket: TcpSocket,
        app: App,
        encodedRequestRecordsBuilder:
            ServerJinguiAcceptedTransportAttachedSessionEncodedRequestRecordsBuilder,
        encodedClientHello: Array<Byte>,
        serverKeyExchangePrivate: Array<Byte>,
        bodyBytes!: Array<UInt8> = [],
        transportId!: String = "accepted-transport",
        maxFragmentLen!: Int64 = 16384,
        closeSocketAfterTurn!: Bool = true,
        policy!: ContractTlsHttpNegotiationPolicy = ContractTlsHttpNegotiationPolicy()
    ): ServerJinguiAcceptedTransportSocketResponseTurnResult {
        let transport = buildServerAcceptedTransportDescriptorFromSocket(
            acceptedSocket,
            transportId
        )
        let session = attachJinguiAcceptedTransportTls13X25519(
            transport,
            encodedClientHello,
            serverKeyExchangePrivate,
            policy: policy
        )
        serveJinguiAcceptedTransportSessionApplicationDataH2ProvidedBodyRequestTurn(
            session,
            acceptedSocket,
            app,
            encodedRequestRecordsBuilder(session),
            bodyBytes: bodyBytes,
            maxFragmentLen: maxFragmentLen,
            closeSocketAfterTurn: closeSocketAfterTurn
        )
    }

    public func serveJinguiAcceptedTransportSocketApplicationDataH2BodylessRequestTurn(
        acceptedSocket: TcpSocket,
        app: App,
        encodedRequestRecordsBuilder:
            ServerJinguiAcceptedTransportAttachedSessionEncodedRequestRecordsBuilder,
        encodedClientHello: Array<Byte>,
        serverKeyExchangePrivate: Array<Byte>,
        transportId!: String = "accepted-transport",
        maxFragmentLen!: Int64 = 16384,
        closeSocketAfterTurn!: Bool = true,
        policy!: ContractTlsHttpNegotiationPolicy = ContractTlsHttpNegotiationPolicy()
    ): ServerJinguiAcceptedTransportSocketResponseTurnResult {
        let transport = buildServerAcceptedTransportDescriptorFromSocket(
            acceptedSocket,
            transportId
        )
        let session = attachJinguiAcceptedTransportTls13X25519(
            transport,
            encodedClientHello,
            serverKeyExchangePrivate,
            policy: policy
        )
        serveJinguiAcceptedTransportSocketApplicationDataH2ProvidedBodyRequestTurn(
            acceptedSocket,
            app,
            encodedRequestRecordsBuilder,
            encodedClientHello,
            serverKeyExchangePrivate,
            transportId: transportId,
            maxFragmentLen: maxFragmentLen,
            closeSocketAfterTurn: closeSocketAfterTurn,
            policy: policy
        )
    }

    public func serveJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataH2BodylessRequestTurn(
        acceptedSocket: TcpSocket,
        app: App,
        encodedRequestRecordsBuilder:
            ServerJinguiAcceptedTransportAttachedSessionEncodedRequestRecordsBuilder,
        serverKeyExchangePrivate: Array<Byte>,
        transportId!: String = "accepted-transport",
        readChunkSize!: Int64 = 4096,
        maxFragmentLen!: Int64 = 16384,
        closeSocketAfterTurn!: Bool = true,
        policy!: ContractTlsHttpNegotiationPolicy = ContractTlsHttpNegotiationPolicy()
    ): ServerJinguiAcceptedTransportSocketResponseTurnResult {
        let attached =
            attachJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloX25519Core(
                acceptedSocket,
                serverKeyExchangePrivate,
                transportId: transportId,
                readChunkSize: readChunkSize,
                policy: policy,
                notifyReadySnapshot: false
            )
        serveJinguiAcceptedTransportSessionApplicationDataH2BodylessRequestTurn(
            attached.session,
            acceptedSocket,
            app,
            encodedRequestRecordsBuilder(attached.session),
            maxFragmentLen: maxFragmentLen,
            closeSocketAfterTurn: closeSocketAfterTurn
        )
    }

    public func serveJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataH2ProvidedBodyRequestTurn(
        acceptedSocket: TcpSocket,
        app: App,
        encodedRequestRecordsBuilder:
            ServerJinguiAcceptedTransportAttachedSessionEncodedRequestRecordsBuilder,
        serverKeyExchangePrivate: Array<Byte>,
        bodyBytes!: Array<UInt8> = [],
        transportId!: String = "accepted-transport",
        readChunkSize!: Int64 = 4096,
        maxFragmentLen!: Int64 = 16384,
        closeSocketAfterTurn!: Bool = true,
        policy!: ContractTlsHttpNegotiationPolicy = ContractTlsHttpNegotiationPolicy()
    ): ServerJinguiAcceptedTransportSocketResponseTurnResult {
        let attached =
            attachJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloX25519Core(
                acceptedSocket,
                serverKeyExchangePrivate,
                transportId: transportId,
                readChunkSize: readChunkSize,
                policy: policy,
                notifyReadySnapshot: false
            )
        serveJinguiAcceptedTransportSessionApplicationDataH2ProvidedBodyRequestTurn(
            attached.session,
            acceptedSocket,
            app,
            encodedRequestRecordsBuilder(attached.session),
            bodyBytes: bodyBytes,
            maxFragmentLen: maxFragmentLen,
            closeSocketAfterTurn: closeSocketAfterTurn
        )
    }
}

public class ServerEngineReadySignal {
    public let jinguiAttachResultSnapshot: ?ServerJinguiHttpServerAttachResultSnapshot

    public init(
        jinguiAttachResultSnapshot!: ?ServerJinguiHttpServerAttachResultSnapshot = None
    ) {
        this.jinguiAttachResultSnapshot = jinguiAttachResultSnapshot
    }
}

public interface ServerEngine {
    func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
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

public struct SocketServerEngineShellProductionCandidateEvidence {
    public let acceptedConnectionLimit: Int64
    public let tlsEnabled: Bool
    public let shutdownStopProof: Bool
    public let keepAliveSoakProof: Bool
    public let streamFileParityProof: Bool
    public let stdxParityProof: Bool

    public init(
        acceptedConnectionLimit: Int64,
        tlsEnabled: Bool,
        shutdownStopProof: Bool,
        keepAliveSoakProof: Bool,
        streamFileParityProof: Bool,
        stdxParityProof: Bool
    ) {
        this.acceptedConnectionLimit = acceptedConnectionLimit
        this.tlsEnabled = tlsEnabled
        this.shutdownStopProof = shutdownStopProof
        this.keepAliveSoakProof = keepAliveSoakProof
        this.streamFileParityProof = streamFileParityProof
        this.stdxParityProof = stdxParityProof
    }
}

public struct SocketServerEngineShellProductionCandidateGate {
    public let productionCandidate: Bool
    public let status: String
    public let defaultFlipDecision: String
    public let requiredProofs: Array<String>
    public let missingProofs: Array<String>
    public let blockers: Array<String>
    public let gaps: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        productionCandidate: Bool,
        status: String,
        defaultFlipDecision: String,
        requiredProofs: Array<String>,
        missingProofs: Array<String>,
        blockers: Array<String>,
        gaps: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.productionCandidate = productionCandidate
        this.status = status
        this.defaultFlipDecision = defaultFlipDecision
        this.requiredProofs = requiredProofs
        this.missingProofs = missingProofs
        this.blockers = blockers
        this.gaps = gaps
        this.nonClaims = nonClaims
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public struct SocketServerEngineShellDefaultFlipReadinessEvidence {
    public let productionCandidateGate: SocketServerEngineShellProductionCandidateGate
    public let operatorAcceptanceProof: Bool
    public let releaseGuardProof: Bool
    public let rollbackPlanProof: Bool
    public let publicDocsProof: Bool

    public init(
        productionCandidateGate: SocketServerEngineShellProductionCandidateGate,
        operatorAcceptanceProof: Bool,
        releaseGuardProof: Bool,
        rollbackPlanProof: Bool,
        publicDocsProof: Bool
    ) {
        this.productionCandidateGate = productionCandidateGate
        this.operatorAcceptanceProof = operatorAcceptanceProof
        this.releaseGuardProof = releaseGuardProof
        this.rollbackPlanProof = rollbackPlanProof
        this.publicDocsProof = publicDocsProof
    }
}

public struct SocketServerEngineShellDefaultFlipReadinessGate {
    public let defaultFlipReady: Bool
    public let status: String
    public let decision: String
    public let requiredProofs: Array<String>
    public let missingProofs: Array<String>
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        defaultFlipReady: Bool,
        status: String,
        decision: String,
        requiredProofs: Array<String>,
        missingProofs: Array<String>,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.defaultFlipReady = defaultFlipReady
        this.status = status
        this.decision = decision
        this.requiredProofs = requiredProofs
        this.missingProofs = missingProofs
        this.blockers = blockers
        this.nonClaims = nonClaims
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public class SocketServerEngineShellH1DefaultReplacementPreflightEvidence {
    public let preflightId: String
    public let productionCandidateGate: SocketServerEngineShellProductionCandidateGate
    public let defaultFlipReadinessGate: SocketServerEngineShellDefaultFlipReadinessGate
    public let providerReadinessGate: ServerJinguiTlsProviderReadinessGate
    public let stdxClaimBoundaryProof: Bool
    public let defaultEngineConfigUnchangedProof: Bool
    public let hostedDependencyProjectionProof: Bool
    public let separateChangePacketProof: Bool
    public let actualDefaultFlipRequested: Bool
    public let defaultEngineConfigMutationRequested: Bool
    public let runtimeDefaultPathMutationRequested: Bool
    public let stdxRemovalRequested: Bool
    public let h2RuntimeClosureClaimed: Bool
    public let publicReleaseOrHostedPublicationClaimed: Bool

    public init(
        preflightId: String,
        productionCandidateGate: SocketServerEngineShellProductionCandidateGate,
        defaultFlipReadinessGate: SocketServerEngineShellDefaultFlipReadinessGate,
        providerReadinessGate: ServerJinguiTlsProviderReadinessGate,
        stdxClaimBoundaryProof: Bool,
        defaultEngineConfigUnchangedProof: Bool,
        hostedDependencyProjectionProof: Bool,
        separateChangePacketProof: Bool,
        actualDefaultFlipRequested: Bool,
        defaultEngineConfigMutationRequested: Bool,
        runtimeDefaultPathMutationRequested: Bool,
        stdxRemovalRequested: Bool,
        h2RuntimeClosureClaimed: Bool,
        publicReleaseOrHostedPublicationClaimed: Bool
    ) {
        this.preflightId = preflightId
        this.productionCandidateGate = productionCandidateGate
        this.defaultFlipReadinessGate = defaultFlipReadinessGate
        this.providerReadinessGate = providerReadinessGate
        this.stdxClaimBoundaryProof = stdxClaimBoundaryProof
        this.defaultEngineConfigUnchangedProof =
            defaultEngineConfigUnchangedProof
        this.hostedDependencyProjectionProof =
            hostedDependencyProjectionProof
        this.separateChangePacketProof = separateChangePacketProof
        this.actualDefaultFlipRequested = actualDefaultFlipRequested
        this.defaultEngineConfigMutationRequested =
            defaultEngineConfigMutationRequested
        this.runtimeDefaultPathMutationRequested =
            runtimeDefaultPathMutationRequested
        this.stdxRemovalRequested = stdxRemovalRequested
        this.h2RuntimeClosureClaimed = h2RuntimeClosureClaimed
        this.publicReleaseOrHostedPublicationClaimed =
            publicReleaseOrHostedPublicationClaimed
    }
}

public class SocketServerEngineShellH1DefaultReplacementPreflightGate {
    public let h1DefaultReplacementPreflightAccepted: Bool
    public let preflightId: String
    public let status: String
    public let decision: String
    public let requiredProofs: Array<String>
    public let blockers: Array<String>
    public let defaultFlipAllowed: Bool
    public let defaultEngineConfigMutationAllowed: Bool
    public let runtimeDefaultPathMutationAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h2RuntimeClosureAllowed: Bool
    public let publicReleaseOrHostedPublicationAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h1DefaultReplacementPreflightAccepted: Bool,
        preflightId: String,
        status: String,
        decision: String,
        requiredProofs: Array<String>,
        blockers: Array<String>,
        defaultFlipAllowed: Bool,
        defaultEngineConfigMutationAllowed: Bool,
        runtimeDefaultPathMutationAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h2RuntimeClosureAllowed: Bool,
        publicReleaseOrHostedPublicationAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h1DefaultReplacementPreflightAccepted =
            h1DefaultReplacementPreflightAccepted
        this.preflightId = preflightId
        this.status = status
        this.decision = decision
        this.requiredProofs = requiredProofs.clone()
        this.blockers = blockers.clone()
        this.defaultFlipAllowed = defaultFlipAllowed
        this.defaultEngineConfigMutationAllowed =
            defaultEngineConfigMutationAllowed
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h2RuntimeClosureAllowed = h2RuntimeClosureAllowed
        this.publicReleaseOrHostedPublicationAllowed =
            publicReleaseOrHostedPublicationAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public class SocketServerEngineShellH1DefaultEngineControlledSwitchEvidence {
    public let switchId: String
    public let preflightGate: SocketServerEngineShellH1DefaultReplacementPreflightGate
    public let candidateEngine: String
    public let fallbackEngine: String
    public let configHint: String
    public let rollbackPlanProof: Bool
    public let operatorApprovalProof: Bool
    public let releaseGuardProof: Bool
    public let startupObservationProof: Bool
    public let appConstructorDefaultUnchangedProof: Bool
    public let actualDefaultEngineFlipRequested: Bool
    public let appConstructorDefaultMutationRequested: Bool
    public let defaultEngineConfigMutationRequested: Bool
    public let runtimeDefaultPathMutationRequested: Bool
    public let stdxRemovalRequested: Bool
    public let h2RuntimeClosureClaimed: Bool
    public let publicReleaseOrHostedPublicationClaimed: Bool

    public init(
        switchId: String,
        preflightGate: SocketServerEngineShellH1DefaultReplacementPreflightGate,
        candidateEngine: String,
        fallbackEngine: String,
        configHint: String,
        rollbackPlanProof: Bool,
        operatorApprovalProof: Bool,
        releaseGuardProof: Bool,
        startupObservationProof: Bool,
        appConstructorDefaultUnchangedProof: Bool,
        actualDefaultEngineFlipRequested: Bool,
        appConstructorDefaultMutationRequested: Bool,
        defaultEngineConfigMutationRequested: Bool,
        runtimeDefaultPathMutationRequested: Bool,
        stdxRemovalRequested: Bool,
        h2RuntimeClosureClaimed: Bool,
        publicReleaseOrHostedPublicationClaimed: Bool
    ) {
        this.switchId = switchId
        this.preflightGate = preflightGate
        this.candidateEngine = candidateEngine
        this.fallbackEngine = fallbackEngine
        this.configHint = configHint
        this.rollbackPlanProof = rollbackPlanProof
        this.operatorApprovalProof = operatorApprovalProof
        this.releaseGuardProof = releaseGuardProof
        this.startupObservationProof = startupObservationProof
        this.appConstructorDefaultUnchangedProof =
            appConstructorDefaultUnchangedProof
        this.actualDefaultEngineFlipRequested =
            actualDefaultEngineFlipRequested
        this.appConstructorDefaultMutationRequested =
            appConstructorDefaultMutationRequested
        this.defaultEngineConfigMutationRequested =
            defaultEngineConfigMutationRequested
        this.runtimeDefaultPathMutationRequested =
            runtimeDefaultPathMutationRequested
        this.stdxRemovalRequested = stdxRemovalRequested
        this.h2RuntimeClosureClaimed = h2RuntimeClosureClaimed
        this.publicReleaseOrHostedPublicationClaimed =
            publicReleaseOrHostedPublicationClaimed
    }
}

public class SocketServerEngineShellH1DefaultEngineControlledSwitchGate {
    public let controlledSwitchAccepted: Bool
    public let switchId: String
    public let candidateEngine: String
    public let fallbackEngine: String
    public let status: String
    public let decision: String
    public let requiredProofs: Array<String>
    public let blockers: Array<String>
    public let switchPlanReady: Bool
    public let actualDefaultEngineFlipAllowed: Bool
    public let appConstructorDefaultMutationAllowed: Bool
    public let defaultEngineConfigMutationAllowed: Bool
    public let runtimeDefaultPathMutationAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h2RuntimeClosureAllowed: Bool
    public let publicReleaseOrHostedPublicationAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        controlledSwitchAccepted: Bool,
        switchId: String,
        candidateEngine: String,
        fallbackEngine: String,
        status: String,
        decision: String,
        requiredProofs: Array<String>,
        blockers: Array<String>,
        switchPlanReady: Bool,
        actualDefaultEngineFlipAllowed: Bool,
        appConstructorDefaultMutationAllowed: Bool,
        defaultEngineConfigMutationAllowed: Bool,
        runtimeDefaultPathMutationAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h2RuntimeClosureAllowed: Bool,
        publicReleaseOrHostedPublicationAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.controlledSwitchAccepted = controlledSwitchAccepted
        this.switchId = switchId
        this.candidateEngine = candidateEngine
        this.fallbackEngine = fallbackEngine
        this.status = status
        this.decision = decision
        this.requiredProofs = requiredProofs.clone()
        this.blockers = blockers.clone()
        this.switchPlanReady = switchPlanReady
        this.actualDefaultEngineFlipAllowed = actualDefaultEngineFlipAllowed
        this.appConstructorDefaultMutationAllowed =
            appConstructorDefaultMutationAllowed
        this.defaultEngineConfigMutationAllowed =
            defaultEngineConfigMutationAllowed
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h2RuntimeClosureAllowed = h2RuntimeClosureAllowed
        this.publicReleaseOrHostedPublicationAllowed =
            publicReleaseOrHostedPublicationAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public class SocketServerEngineShellH1DefaultMutationReleaseGuardEvidence {
    public let guardId: String
    public let controlledSwitchGate: SocketServerEngineShellH1DefaultEngineControlledSwitchGate
    public let releaseVersionTarget: String
    public let publicBaselineProjection: String
    public let releaseGuardProof: Bool
    public let rollbackVerificationProof: Bool
    public let publicDocsProof: Bool
    public let migrationGuideProof: Bool
    public let hostedDependencyProjectionProof: Bool
    public let hostedDependencyResolutionProof: Bool
    public let publicBaselineProjectionProof: Bool
    public let separateDefaultMutationPacketProof: Bool
    public let actualDefaultEngineFlipRequested: Bool
    public let appConstructorDefaultMutationRequested: Bool
    public let defaultEngineConfigMutationRequested: Bool
    public let runtimeDefaultPathMutationRequested: Bool
    public let stdxRemovalRequested: Bool
    public let h2RuntimeClosureClaimed: Bool
    public let publicReleaseOrHostedPublicationClaimed: Bool

    public init(
        guardId: String,
        controlledSwitchGate: SocketServerEngineShellH1DefaultEngineControlledSwitchGate,
        releaseVersionTarget: String,
        publicBaselineProjection: String,
        releaseGuardProof: Bool,
        rollbackVerificationProof: Bool,
        publicDocsProof: Bool,
        migrationGuideProof: Bool,
        hostedDependencyProjectionProof: Bool,
        hostedDependencyResolutionProof: Bool,
        publicBaselineProjectionProof: Bool,
        separateDefaultMutationPacketProof: Bool,
        actualDefaultEngineFlipRequested: Bool,
        appConstructorDefaultMutationRequested: Bool,
        defaultEngineConfigMutationRequested: Bool,
        runtimeDefaultPathMutationRequested: Bool,
        stdxRemovalRequested: Bool,
        h2RuntimeClosureClaimed: Bool,
        publicReleaseOrHostedPublicationClaimed: Bool
    ) {
        this.guardId = guardId
        this.controlledSwitchGate = controlledSwitchGate
        this.releaseVersionTarget = releaseVersionTarget
        this.publicBaselineProjection = publicBaselineProjection
        this.releaseGuardProof = releaseGuardProof
        this.rollbackVerificationProof = rollbackVerificationProof
        this.publicDocsProof = publicDocsProof
        this.migrationGuideProof = migrationGuideProof
        this.hostedDependencyProjectionProof =
            hostedDependencyProjectionProof
        this.hostedDependencyResolutionProof =
            hostedDependencyResolutionProof
        this.publicBaselineProjectionProof = publicBaselineProjectionProof
        this.separateDefaultMutationPacketProof =
            separateDefaultMutationPacketProof
        this.actualDefaultEngineFlipRequested =
            actualDefaultEngineFlipRequested
        this.appConstructorDefaultMutationRequested =
            appConstructorDefaultMutationRequested
        this.defaultEngineConfigMutationRequested =
            defaultEngineConfigMutationRequested
        this.runtimeDefaultPathMutationRequested =
            runtimeDefaultPathMutationRequested
        this.stdxRemovalRequested = stdxRemovalRequested
        this.h2RuntimeClosureClaimed = h2RuntimeClosureClaimed
        this.publicReleaseOrHostedPublicationClaimed =
            publicReleaseOrHostedPublicationClaimed
    }
}

public class SocketServerEngineShellH1DefaultMutationReleaseGuard {
    public let releaseGuardAccepted: Bool
    public let guardId: String
    public let releaseVersionTarget: String
    public let publicBaselineProjection: String
    public let status: String
    public let decision: String
    public let requiredProofs: Array<String>
    public let blockers: Array<String>
    public let defaultMutationPacketReady: Bool
    public let actualDefaultEngineFlipAllowed: Bool
    public let appConstructorDefaultMutationAllowed: Bool
    public let defaultEngineConfigMutationAllowed: Bool
    public let runtimeDefaultPathMutationAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h2RuntimeClosureAllowed: Bool
    public let publicReleaseOrHostedPublicationAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        releaseGuardAccepted: Bool,
        guardId: String,
        releaseVersionTarget: String,
        publicBaselineProjection: String,
        status: String,
        decision: String,
        requiredProofs: Array<String>,
        blockers: Array<String>,
        defaultMutationPacketReady: Bool,
        actualDefaultEngineFlipAllowed: Bool,
        appConstructorDefaultMutationAllowed: Bool,
        defaultEngineConfigMutationAllowed: Bool,
        runtimeDefaultPathMutationAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h2RuntimeClosureAllowed: Bool,
        publicReleaseOrHostedPublicationAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.releaseGuardAccepted = releaseGuardAccepted
        this.guardId = guardId
        this.releaseVersionTarget = releaseVersionTarget
        this.publicBaselineProjection = publicBaselineProjection
        this.status = status
        this.decision = decision
        this.requiredProofs = requiredProofs.clone()
        this.blockers = blockers.clone()
        this.defaultMutationPacketReady = defaultMutationPacketReady
        this.actualDefaultEngineFlipAllowed = actualDefaultEngineFlipAllowed
        this.appConstructorDefaultMutationAllowed =
            appConstructorDefaultMutationAllowed
        this.defaultEngineConfigMutationAllowed =
            defaultEngineConfigMutationAllowed
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h2RuntimeClosureAllowed = h2RuntimeClosureAllowed
        this.publicReleaseOrHostedPublicationAllowed =
            publicReleaseOrHostedPublicationAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public class SocketServerEngineShellH1CleartextDefaultCloseEvidence {
    public let closeId: String
    public let defaultMutationReleaseGuard:
        SocketServerEngineShellH1DefaultMutationReleaseGuard
    public let defaultNativeSelectionProof: Bool
    public let stdxRollbackHintProof: Bool
    public let tlsFallbackPreservationProof: Bool
    public let focusedRegressionProof: Bool
    public let publicBaselineNonMutationProof: Bool
    public let sourceZeroStdxClaimed: Bool
    public let stdxRemovalRequested: Bool
    public let tlsNativeH1Claimed: Bool
    public let h2RuntimeClosureClaimed: Bool
    public let publicReleaseOrHostedPublicationClaimed: Bool

    public init(
        closeId: String,
        defaultMutationReleaseGuard:
            SocketServerEngineShellH1DefaultMutationReleaseGuard,
        defaultNativeSelectionProof: Bool,
        stdxRollbackHintProof: Bool,
        tlsFallbackPreservationProof: Bool,
        focusedRegressionProof: Bool,
        publicBaselineNonMutationProof: Bool,
        sourceZeroStdxClaimed: Bool,
        stdxRemovalRequested: Bool,
        tlsNativeH1Claimed: Bool,
        h2RuntimeClosureClaimed: Bool,
        publicReleaseOrHostedPublicationClaimed: Bool
    ) {
        this.closeId = closeId
        this.defaultMutationReleaseGuard = defaultMutationReleaseGuard
        this.defaultNativeSelectionProof = defaultNativeSelectionProof
        this.stdxRollbackHintProof = stdxRollbackHintProof
        this.tlsFallbackPreservationProof = tlsFallbackPreservationProof
        this.focusedRegressionProof = focusedRegressionProof
        this.publicBaselineNonMutationProof = publicBaselineNonMutationProof
        this.sourceZeroStdxClaimed = sourceZeroStdxClaimed
        this.stdxRemovalRequested = stdxRemovalRequested
        this.tlsNativeH1Claimed = tlsNativeH1Claimed
        this.h2RuntimeClosureClaimed = h2RuntimeClosureClaimed
        this.publicReleaseOrHostedPublicationClaimed =
            publicReleaseOrHostedPublicationClaimed
    }
}

public class SocketServerEngineShellH1CleartextDefaultCloseGate {
    public let cleartextDefaultCloseAccepted: Bool
    public let closeId: String
    public let status: String
    public let decision: String
    public let requiredProofs: Array<String>
    public let blockers: Array<String>
    public let cleartextDefaultNativeAccepted: Bool
    public let fullH1NativeDefaultReplacementAccepted: Bool
    public let sourceZeroStdxAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let tlsNativeH1Allowed: Bool
    public let h2RuntimeClosureAllowed: Bool
    public let publicReleaseOrHostedPublicationAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        cleartextDefaultCloseAccepted: Bool,
        closeId: String,
        status: String,
        decision: String,
        requiredProofs: Array<String>,
        blockers: Array<String>,
        cleartextDefaultNativeAccepted: Bool,
        fullH1NativeDefaultReplacementAccepted: Bool,
        sourceZeroStdxAllowed: Bool,
        stdxRemovalAllowed: Bool,
        tlsNativeH1Allowed: Bool,
        h2RuntimeClosureAllowed: Bool,
        publicReleaseOrHostedPublicationAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.cleartextDefaultCloseAccepted = cleartextDefaultCloseAccepted
        this.closeId = closeId
        this.status = status
        this.decision = decision
        this.requiredProofs = requiredProofs.clone()
        this.blockers = blockers.clone()
        this.cleartextDefaultNativeAccepted = cleartextDefaultNativeAccepted
        this.fullH1NativeDefaultReplacementAccepted =
            fullH1NativeDefaultReplacementAccepted
        this.sourceZeroStdxAllowed = sourceZeroStdxAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.tlsNativeH1Allowed = tlsNativeH1Allowed
        this.h2RuntimeClosureAllowed = h2RuntimeClosureAllowed
        this.publicReleaseOrHostedPublicationAllowed =
            publicReleaseOrHostedPublicationAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public class SocketServerEngineShellH1TlsNativeSeamCloseGapEvidence {
    public let closeId: String
    public let cleartextDefaultCloseGate:
        SocketServerEngineShellH1CleartextDefaultCloseGate
    public let providerReadinessGate: ServerJinguiTlsProviderReadinessGate
    public let acceptedTransportAttachPassProof: Bool
    public let runtimeSafeHandshakeProof: Bool
    public let liveListenAttachProof: Bool
    public let tlsConfigSelectionProof: Bool
    public let rollbackFallbackProof: Bool
    public let defaultTlsNativeMutationRequested: Bool
    public let sourceZeroStdxClaimed: Bool
    public let stdxRemovalRequested: Bool
    public let fullH1NativeDefaultReplacementClaimed: Bool
    public let h2RuntimeClosureClaimed: Bool
    public let publicReleaseOrHostedPublicationClaimed: Bool

    public init(
        closeId: String,
        cleartextDefaultCloseGate:
            SocketServerEngineShellH1CleartextDefaultCloseGate,
        providerReadinessGate: ServerJinguiTlsProviderReadinessGate,
        acceptedTransportAttachPassProof: Bool,
        runtimeSafeHandshakeProof: Bool,
        liveListenAttachProof: Bool,
        tlsConfigSelectionProof: Bool,
        rollbackFallbackProof: Bool,
        defaultTlsNativeMutationRequested: Bool,
        sourceZeroStdxClaimed: Bool,
        stdxRemovalRequested: Bool,
        fullH1NativeDefaultReplacementClaimed: Bool,
        h2RuntimeClosureClaimed: Bool,
        publicReleaseOrHostedPublicationClaimed: Bool
    ) {
        this.closeId = closeId
        this.cleartextDefaultCloseGate = cleartextDefaultCloseGate
        this.providerReadinessGate = providerReadinessGate
        this.acceptedTransportAttachPassProof =
            acceptedTransportAttachPassProof
        this.runtimeSafeHandshakeProof = runtimeSafeHandshakeProof
        this.liveListenAttachProof = liveListenAttachProof
        this.tlsConfigSelectionProof = tlsConfigSelectionProof
        this.rollbackFallbackProof = rollbackFallbackProof
        this.defaultTlsNativeMutationRequested =
            defaultTlsNativeMutationRequested
        this.sourceZeroStdxClaimed = sourceZeroStdxClaimed
        this.stdxRemovalRequested = stdxRemovalRequested
        this.fullH1NativeDefaultReplacementClaimed =
            fullH1NativeDefaultReplacementClaimed
        this.h2RuntimeClosureClaimed = h2RuntimeClosureClaimed
        this.publicReleaseOrHostedPublicationClaimed =
            publicReleaseOrHostedPublicationClaimed
    }
}

public class SocketServerEngineShellH1TlsNativeSeamCloseGapGate {
    public let h1TlsNativeSeamReady: Bool
    public let closeId: String
    public let status: String
    public let decision: String
    public let requiredProofs: Array<String>
    public let blockers: Array<String>
    public let defaultTlsNativeMutationAllowed: Bool
    public let fullH1NativeDefaultReplacementAccepted: Bool
    public let sourceZeroStdxAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h2RuntimeClosureAllowed: Bool
    public let publicReleaseOrHostedPublicationAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h1TlsNativeSeamReady: Bool,
        closeId: String,
        status: String,
        decision: String,
        requiredProofs: Array<String>,
        blockers: Array<String>,
        defaultTlsNativeMutationAllowed: Bool,
        fullH1NativeDefaultReplacementAccepted: Bool,
        sourceZeroStdxAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h2RuntimeClosureAllowed: Bool,
        publicReleaseOrHostedPublicationAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h1TlsNativeSeamReady = h1TlsNativeSeamReady
        this.closeId = closeId
        this.status = status
        this.decision = decision
        this.requiredProofs = requiredProofs.clone()
        this.blockers = blockers.clone()
        this.defaultTlsNativeMutationAllowed = defaultTlsNativeMutationAllowed
        this.fullH1NativeDefaultReplacementAccepted =
            fullH1NativeDefaultReplacementAccepted
        this.sourceZeroStdxAllowed = sourceZeroStdxAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h2RuntimeClosureAllowed = h2RuntimeClosureAllowed
        this.publicReleaseOrHostedPublicationAllowed =
            publicReleaseOrHostedPublicationAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public class AppTlsDefaultMutationDryRunEvidence {
    public let dryRunId: String
    public let h1TlsNativeSeamGate:
        SocketServerEngineShellH1TlsNativeSeamCloseGapGate
    public let tlsConfigNativeSelectionDryRunProof: Bool
    public let stdxRollbackHintProof: Bool
    public let startupObservationProof: Bool
    public let focusedRegressionProof: Bool
    public let publicBaselineNonMutationProof: Bool
    public let actualAppTlsDefaultMutationRequested: Bool
    public let sourceZeroStdxClaimed: Bool
    public let stdxRemovalRequested: Bool
    public let fullH1NativeDefaultReplacementClaimed: Bool
    public let h2RuntimeClosureClaimed: Bool
    public let publicReleaseOrHostedPublicationClaimed: Bool

    public init(
        dryRunId: String,
        h1TlsNativeSeamGate:
            SocketServerEngineShellH1TlsNativeSeamCloseGapGate,
        tlsConfigNativeSelectionDryRunProof: Bool,
        stdxRollbackHintProof: Bool,
        startupObservationProof: Bool,
        focusedRegressionProof: Bool,
        publicBaselineNonMutationProof: Bool,
        actualAppTlsDefaultMutationRequested: Bool,
        sourceZeroStdxClaimed: Bool,
        stdxRemovalRequested: Bool,
        fullH1NativeDefaultReplacementClaimed: Bool,
        h2RuntimeClosureClaimed: Bool,
        publicReleaseOrHostedPublicationClaimed: Bool
    ) {
        this.dryRunId = dryRunId
        this.h1TlsNativeSeamGate = h1TlsNativeSeamGate
        this.tlsConfigNativeSelectionDryRunProof =
            tlsConfigNativeSelectionDryRunProof
        this.stdxRollbackHintProof = stdxRollbackHintProof
        this.startupObservationProof = startupObservationProof
        this.focusedRegressionProof = focusedRegressionProof
        this.publicBaselineNonMutationProof = publicBaselineNonMutationProof
        this.actualAppTlsDefaultMutationRequested =
            actualAppTlsDefaultMutationRequested
        this.sourceZeroStdxClaimed = sourceZeroStdxClaimed
        this.stdxRemovalRequested = stdxRemovalRequested
        this.fullH1NativeDefaultReplacementClaimed =
            fullH1NativeDefaultReplacementClaimed
        this.h2RuntimeClosureClaimed = h2RuntimeClosureClaimed
        this.publicReleaseOrHostedPublicationClaimed =
            publicReleaseOrHostedPublicationClaimed
    }
}

public class AppTlsDefaultMutationDryRunGate {
    public let dryRunAccepted: Bool
    public let dryRunId: String
    public let status: String
    public let decision: String
    public let requiredProofs: Array<String>
    public let blockers: Array<String>
    public let appTlsDefaultMutationDryRunAccepted: Bool
    public let actualAppTlsDefaultMutationAllowed: Bool
    public let sourceZeroStdxAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let fullH1NativeDefaultReplacementAccepted: Bool
    public let h2RuntimeClosureAllowed: Bool
    public let publicReleaseOrHostedPublicationAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        dryRunAccepted: Bool,
        dryRunId: String,
        status: String,
        decision: String,
        requiredProofs: Array<String>,
        blockers: Array<String>,
        appTlsDefaultMutationDryRunAccepted: Bool,
        actualAppTlsDefaultMutationAllowed: Bool,
        sourceZeroStdxAllowed: Bool,
        stdxRemovalAllowed: Bool,
        fullH1NativeDefaultReplacementAccepted: Bool,
        h2RuntimeClosureAllowed: Bool,
        publicReleaseOrHostedPublicationAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.dryRunAccepted = dryRunAccepted
        this.dryRunId = dryRunId
        this.status = status
        this.decision = decision
        this.requiredProofs = requiredProofs.clone()
        this.blockers = blockers.clone()
        this.appTlsDefaultMutationDryRunAccepted =
            appTlsDefaultMutationDryRunAccepted
        this.actualAppTlsDefaultMutationAllowed =
            actualAppTlsDefaultMutationAllowed
        this.sourceZeroStdxAllowed = sourceZeroStdxAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.fullH1NativeDefaultReplacementAccepted =
            fullH1NativeDefaultReplacementAccepted
        this.h2RuntimeClosureAllowed = h2RuntimeClosureAllowed
        this.publicReleaseOrHostedPublicationAllowed =
            publicReleaseOrHostedPublicationAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public class AppTlsDefaultMutationApplyGateEvidence {
    public let applyId: String
    public let dryRunGate: AppTlsDefaultMutationDryRunGate
    public let nativeSocketTlsListenSupportProof: Bool
    public let acceptedTransportLiveIngressProof: Bool
    public let appPolicyMutationPlanProof: Bool
    public let rollbackVerificationProof: Bool
    public let focusedRegressionProof: Bool
    public let actualAppTlsDefaultMutationRequested: Bool
    public let nativeTlsLiveIngressImplementationRequested: Bool
    public let sourceZeroStdxClaimed: Bool
    public let stdxRemovalRequested: Bool
    public let fullH1NativeDefaultReplacementClaimed: Bool
    public let h2RuntimeClosureClaimed: Bool
    public let publicReleaseOrHostedPublicationClaimed: Bool

    public init(
        applyId: String,
        dryRunGate: AppTlsDefaultMutationDryRunGate,
        nativeSocketTlsListenSupportProof: Bool,
        acceptedTransportLiveIngressProof: Bool,
        appPolicyMutationPlanProof: Bool,
        rollbackVerificationProof: Bool,
        focusedRegressionProof: Bool,
        actualAppTlsDefaultMutationRequested: Bool,
        nativeTlsLiveIngressImplementationRequested: Bool,
        sourceZeroStdxClaimed: Bool,
        stdxRemovalRequested: Bool,
        fullH1NativeDefaultReplacementClaimed: Bool,
        h2RuntimeClosureClaimed: Bool,
        publicReleaseOrHostedPublicationClaimed: Bool
    ) {
        this.applyId = applyId
        this.dryRunGate = dryRunGate
        this.nativeSocketTlsListenSupportProof =
            nativeSocketTlsListenSupportProof
        this.acceptedTransportLiveIngressProof =
            acceptedTransportLiveIngressProof
        this.appPolicyMutationPlanProof = appPolicyMutationPlanProof
        this.rollbackVerificationProof = rollbackVerificationProof
        this.focusedRegressionProof = focusedRegressionProof
        this.actualAppTlsDefaultMutationRequested =
            actualAppTlsDefaultMutationRequested
        this.nativeTlsLiveIngressImplementationRequested =
            nativeTlsLiveIngressImplementationRequested
        this.sourceZeroStdxClaimed = sourceZeroStdxClaimed
        this.stdxRemovalRequested = stdxRemovalRequested
        this.fullH1NativeDefaultReplacementClaimed =
            fullH1NativeDefaultReplacementClaimed
        this.h2RuntimeClosureClaimed = h2RuntimeClosureClaimed
        this.publicReleaseOrHostedPublicationClaimed =
            publicReleaseOrHostedPublicationClaimed
    }
}

public class AppTlsDefaultMutationApplyGate {
    public let applyGateAccepted: Bool
    public let applyId: String
    public let status: String
    public let decision: String
    public let requiredProofs: Array<String>
    public let blockers: Array<String>
    public let nativeSocketTlsListenSupportReady: Bool
    public let acceptedTransportLiveIngressReady: Bool
    public let appPolicyMutationPlanReady: Bool
    public let actualAppTlsDefaultMutationAllowed: Bool
    public let nativeTlsLiveIngressImplementationAllowed: Bool
    public let sourceZeroStdxAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let fullH1NativeDefaultReplacementAccepted: Bool
    public let h2RuntimeClosureAllowed: Bool
    public let publicReleaseOrHostedPublicationAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        applyGateAccepted: Bool,
        applyId: String,
        status: String,
        decision: String,
        requiredProofs: Array<String>,
        blockers: Array<String>,
        nativeSocketTlsListenSupportReady: Bool,
        acceptedTransportLiveIngressReady: Bool,
        appPolicyMutationPlanReady: Bool,
        actualAppTlsDefaultMutationAllowed: Bool,
        nativeTlsLiveIngressImplementationAllowed: Bool,
        sourceZeroStdxAllowed: Bool,
        stdxRemovalAllowed: Bool,
        fullH1NativeDefaultReplacementAccepted: Bool,
        h2RuntimeClosureAllowed: Bool,
        publicReleaseOrHostedPublicationAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.applyGateAccepted = applyGateAccepted
        this.applyId = applyId
        this.status = status
        this.decision = decision
        this.requiredProofs = requiredProofs.clone()
        this.blockers = blockers.clone()
        this.nativeSocketTlsListenSupportReady =
            nativeSocketTlsListenSupportReady
        this.acceptedTransportLiveIngressReady =
            acceptedTransportLiveIngressReady
        this.appPolicyMutationPlanReady = appPolicyMutationPlanReady
        this.actualAppTlsDefaultMutationAllowed =
            actualAppTlsDefaultMutationAllowed
        this.nativeTlsLiveIngressImplementationAllowed =
            nativeTlsLiveIngressImplementationAllowed
        this.sourceZeroStdxAllowed = sourceZeroStdxAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.fullH1NativeDefaultReplacementAccepted =
            fullH1NativeDefaultReplacementAccepted
        this.h2RuntimeClosureAllowed = h2RuntimeClosureAllowed
        this.publicReleaseOrHostedPublicationAllowed =
            publicReleaseOrHostedPublicationAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public class AppTlsLiveIngressConsumptionEvidence {
    public let consumptionId: String
    public let applyGate: AppTlsDefaultMutationApplyGate
    public let nativeTlsLiveIngressFirstCutReceiptProof: Bool
    public let acceptedTransportH2HeadersPlusDataProof: Bool
    public let staleNativeIngressBlockerRebasedProof: Bool
    public let appDefaultMutationPolicySeparateProof: Bool
    public let rollbackVerificationProof: Bool
    public let focusedRegressionProof: Bool
    public let actualAppTlsDefaultMutationRequested: Bool
    public let sourceZeroStdxClaimed: Bool
    public let stdxRemovalRequested: Bool
    public let fullH1NativeDefaultReplacementClaimed: Bool
    public let h2RuntimeClosureClaimed: Bool
    public let publicReleaseOrHostedPublicationClaimed: Bool

    public init(
        consumptionId: String,
        applyGate: AppTlsDefaultMutationApplyGate,
        nativeTlsLiveIngressFirstCutReceiptProof: Bool,
        acceptedTransportH2HeadersPlusDataProof: Bool,
        staleNativeIngressBlockerRebasedProof: Bool,
        appDefaultMutationPolicySeparateProof: Bool,
        rollbackVerificationProof: Bool,
        focusedRegressionProof: Bool,
        actualAppTlsDefaultMutationRequested: Bool,
        sourceZeroStdxClaimed: Bool,
        stdxRemovalRequested: Bool,
        fullH1NativeDefaultReplacementClaimed: Bool,
        h2RuntimeClosureClaimed: Bool,
        publicReleaseOrHostedPublicationClaimed: Bool
    ) {
        this.consumptionId = consumptionId
        this.applyGate = applyGate
        this.nativeTlsLiveIngressFirstCutReceiptProof =
            nativeTlsLiveIngressFirstCutReceiptProof
        this.acceptedTransportH2HeadersPlusDataProof =
            acceptedTransportH2HeadersPlusDataProof
        this.staleNativeIngressBlockerRebasedProof =
            staleNativeIngressBlockerRebasedProof
        this.appDefaultMutationPolicySeparateProof =
            appDefaultMutationPolicySeparateProof
        this.rollbackVerificationProof = rollbackVerificationProof
        this.focusedRegressionProof = focusedRegressionProof
        this.actualAppTlsDefaultMutationRequested =
            actualAppTlsDefaultMutationRequested
        this.sourceZeroStdxClaimed = sourceZeroStdxClaimed
        this.stdxRemovalRequested = stdxRemovalRequested
        this.fullH1NativeDefaultReplacementClaimed =
            fullH1NativeDefaultReplacementClaimed
        this.h2RuntimeClosureClaimed = h2RuntimeClosureClaimed
        this.publicReleaseOrHostedPublicationClaimed =
            publicReleaseOrHostedPublicationClaimed
    }
}

public class AppTlsLiveIngressConsumptionGate {
    public let consumptionGateAccepted: Bool
    public let consumptionId: String
    public let status: String
    public let decision: String
    public let requiredProofs: Array<String>
    public let blockers: Array<String>
    public let nativeTlsLiveIngressFirstCutConsumed: Bool
    public let acceptedTransportH2HeadersPlusDataReady: Bool
    public let staleNativeIngressBlockerRebased: Bool
    public let actualAppTlsDefaultMutationAllowed: Bool
    public let sourceZeroStdxAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let fullH1NativeDefaultReplacementAccepted: Bool
    public let h2RuntimeClosureAllowed: Bool
    public let publicReleaseOrHostedPublicationAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        consumptionGateAccepted: Bool,
        consumptionId: String,
        status: String,
        decision: String,
        requiredProofs: Array<String>,
        blockers: Array<String>,
        nativeTlsLiveIngressFirstCutConsumed: Bool,
        acceptedTransportH2HeadersPlusDataReady: Bool,
        staleNativeIngressBlockerRebased: Bool,
        actualAppTlsDefaultMutationAllowed: Bool,
        sourceZeroStdxAllowed: Bool,
        stdxRemovalAllowed: Bool,
        fullH1NativeDefaultReplacementAccepted: Bool,
        h2RuntimeClosureAllowed: Bool,
        publicReleaseOrHostedPublicationAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.consumptionGateAccepted = consumptionGateAccepted
        this.consumptionId = consumptionId
        this.status = status
        this.decision = decision
        this.requiredProofs = requiredProofs.clone()
        this.blockers = blockers.clone()
        this.nativeTlsLiveIngressFirstCutConsumed =
            nativeTlsLiveIngressFirstCutConsumed
        this.acceptedTransportH2HeadersPlusDataReady =
            acceptedTransportH2HeadersPlusDataReady
        this.staleNativeIngressBlockerRebased =
            staleNativeIngressBlockerRebased
        this.actualAppTlsDefaultMutationAllowed =
            actualAppTlsDefaultMutationAllowed
        this.sourceZeroStdxAllowed = sourceZeroStdxAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.fullH1NativeDefaultReplacementAccepted =
            fullH1NativeDefaultReplacementAccepted
        this.h2RuntimeClosureAllowed = h2RuntimeClosureAllowed
        this.publicReleaseOrHostedPublicationAllowed =
            publicReleaseOrHostedPublicationAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public class AppTlsDefaultSelectionMutationEvidence {
    public let mutationId: String
    public let consumptionGate: AppTlsLiveIngressConsumptionGate
    public let tlsConfigDefaultNativeSelectionProof: Bool
    public let explicitStdxRollbackSelectionProof: Bool
    public let startupObservationProof: Bool
    public let focusedRegressionProof: Bool
    public let publicBaselineNonMutationProof: Bool
    public let sourceZeroStdxClaimed: Bool
    public let stdxRemovalRequested: Bool
    public let fullH1NativeDefaultReplacementClaimed: Bool
    public let h2RuntimeClosureClaimed: Bool
    public let browserGradeTlsH2CompatibilityClaimed: Bool
    public let publicReleaseOrHostedPublicationClaimed: Bool

    public init(
        mutationId: String,
        consumptionGate: AppTlsLiveIngressConsumptionGate,
        tlsConfigDefaultNativeSelectionProof: Bool,
        explicitStdxRollbackSelectionProof: Bool,
        startupObservationProof: Bool,
        focusedRegressionProof: Bool,
        publicBaselineNonMutationProof: Bool,
        sourceZeroStdxClaimed: Bool,
        stdxRemovalRequested: Bool,
        fullH1NativeDefaultReplacementClaimed: Bool,
        h2RuntimeClosureClaimed: Bool,
        browserGradeTlsH2CompatibilityClaimed: Bool,
        publicReleaseOrHostedPublicationClaimed: Bool
    ) {
        this.mutationId = mutationId
        this.consumptionGate = consumptionGate
        this.tlsConfigDefaultNativeSelectionProof =
            tlsConfigDefaultNativeSelectionProof
        this.explicitStdxRollbackSelectionProof =
            explicitStdxRollbackSelectionProof
        this.startupObservationProof = startupObservationProof
        this.focusedRegressionProof = focusedRegressionProof
        this.publicBaselineNonMutationProof = publicBaselineNonMutationProof
        this.sourceZeroStdxClaimed = sourceZeroStdxClaimed
        this.stdxRemovalRequested = stdxRemovalRequested
        this.fullH1NativeDefaultReplacementClaimed =
            fullH1NativeDefaultReplacementClaimed
        this.h2RuntimeClosureClaimed = h2RuntimeClosureClaimed
        this.browserGradeTlsH2CompatibilityClaimed =
            browserGradeTlsH2CompatibilityClaimed
        this.publicReleaseOrHostedPublicationClaimed =
            publicReleaseOrHostedPublicationClaimed
    }
}

public class AppTlsDefaultSelectionMutationGate {
    public let mutationAccepted: Bool
    public let mutationId: String
    public let status: String
    public let decision: String
    public let requiredProofs: Array<String>
    public let blockers: Array<String>
    public let appTlsDefaultSelectionMutated: Bool
    public let tlsConfigDefaultNativeSelected: Bool
    public let explicitStdxRollbackPreserved: Bool
    public let sourceZeroStdxAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let fullH1NativeDefaultReplacementAccepted: Bool
    public let h2RuntimeClosureAllowed: Bool
    public let browserGradeTlsH2CompatibilityAllowed: Bool
    public let publicReleaseOrHostedPublicationAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        mutationAccepted: Bool,
        mutationId: String,
        status: String,
        decision: String,
        requiredProofs: Array<String>,
        blockers: Array<String>,
        appTlsDefaultSelectionMutated: Bool,
        tlsConfigDefaultNativeSelected: Bool,
        explicitStdxRollbackPreserved: Bool,
        sourceZeroStdxAllowed: Bool,
        stdxRemovalAllowed: Bool,
        fullH1NativeDefaultReplacementAccepted: Bool,
        h2RuntimeClosureAllowed: Bool,
        browserGradeTlsH2CompatibilityAllowed: Bool,
        publicReleaseOrHostedPublicationAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.mutationAccepted = mutationAccepted
        this.mutationId = mutationId
        this.status = status
        this.decision = decision
        this.requiredProofs = requiredProofs.clone()
        this.blockers = blockers.clone()
        this.appTlsDefaultSelectionMutated =
            appTlsDefaultSelectionMutated
        this.tlsConfigDefaultNativeSelected =
            tlsConfigDefaultNativeSelected
        this.explicitStdxRollbackPreserved =
            explicitStdxRollbackPreserved
        this.sourceZeroStdxAllowed = sourceZeroStdxAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.fullH1NativeDefaultReplacementAccepted =
            fullH1NativeDefaultReplacementAccepted
        this.h2RuntimeClosureAllowed = h2RuntimeClosureAllowed
        this.browserGradeTlsH2CompatibilityAllowed =
            browserGradeTlsH2CompatibilityAllowed
        this.publicReleaseOrHostedPublicationAllowed =
            publicReleaseOrHostedPublicationAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public class SocketServerEngineShell <: ServerEngine & ServerEngineTransportTouchpointOverride & ServerRuntimeObservabilityProvider {
    let _runtimeControl = SocketServerEngineShellRuntimeControl()
    let _selectionLabel: String
    let _tlsAcceptedSessionReadyHook: ?ServerJinguiAcceptedTransportAttachedSessionReadyHook

    public init(
        selectionLabel!: String = "manual-opt-in",
        tlsAcceptedSessionReadyHook!:
            ?ServerJinguiAcceptedTransportAttachedSessionReadyHook = None
    ) {
        _selectionLabel = selectionLabel
        _tlsAcceptedSessionReadyHook = tlsAcceptedSessionReadyHook
    }

    public func productionCandidateGate(
        evidence: SocketServerEngineShellProductionCandidateEvidence
    ): SocketServerEngineShellProductionCandidateGate {
        buildSocketServerEngineShellProductionCandidateGate(evidence)
    }

    public func defaultFlipReadinessGate(
        evidence: SocketServerEngineShellDefaultFlipReadinessEvidence
    ): SocketServerEngineShellDefaultFlipReadinessGate {
        buildSocketServerEngineShellDefaultFlipReadinessGate(evidence)
    }

    public func productionCandidateGateWithTlsProviderReadiness(
        evidence: SocketServerEngineShellProductionCandidateEvidence,
        providerReadinessGate: ServerJinguiTlsProviderReadinessGate
    ): SocketServerEngineShellProductionCandidateGate {
        buildSocketServerEngineShellProductionCandidateGateWithTlsProviderReadiness(
            evidence,
            providerReadinessGate
        )
    }

    public func h1DefaultReplacementPreflightGate(
        evidence: SocketServerEngineShellH1DefaultReplacementPreflightEvidence
    ): SocketServerEngineShellH1DefaultReplacementPreflightGate {
        buildSocketServerEngineShellH1DefaultReplacementPreflightGate(evidence)
    }

    public func h1DefaultEngineControlledSwitchGate(
        evidence: SocketServerEngineShellH1DefaultEngineControlledSwitchEvidence
    ): SocketServerEngineShellH1DefaultEngineControlledSwitchGate {
        buildSocketServerEngineShellH1DefaultEngineControlledSwitchGate(evidence)
    }

    public func h1DefaultMutationReleaseGuard(
        evidence: SocketServerEngineShellH1DefaultMutationReleaseGuardEvidence
    ): SocketServerEngineShellH1DefaultMutationReleaseGuard {
        buildSocketServerEngineShellH1DefaultMutationReleaseGuard(evidence)
    }

    public func h1CleartextDefaultCloseGate(
        evidence: SocketServerEngineShellH1CleartextDefaultCloseEvidence
    ): SocketServerEngineShellH1CleartextDefaultCloseGate {
        buildSocketServerEngineShellH1CleartextDefaultCloseGate(evidence)
    }

    public func h1TlsNativeSeamCloseGapGate(
        evidence: SocketServerEngineShellH1TlsNativeSeamCloseGapEvidence
    ): SocketServerEngineShellH1TlsNativeSeamCloseGapGate {
        buildSocketServerEngineShellH1TlsNativeSeamCloseGapGate(evidence)
    }

    public func appTlsDefaultMutationDryRunGate(
        evidence: AppTlsDefaultMutationDryRunEvidence
    ): AppTlsDefaultMutationDryRunGate {
        buildAppTlsDefaultMutationDryRunGate(evidence)
    }

    public func appTlsDefaultMutationApplyGate(
        evidence: AppTlsDefaultMutationApplyGateEvidence
    ): AppTlsDefaultMutationApplyGate {
        buildAppTlsDefaultMutationApplyGate(evidence)
    }

    public func appTlsLiveIngressConsumptionGate(
        evidence: AppTlsLiveIngressConsumptionEvidence
    ): AppTlsLiveIngressConsumptionGate {
        buildAppTlsLiveIngressConsumptionGate(evidence)
    }

    public func appTlsDefaultSelectionMutationGate(
        evidence: AppTlsDefaultSelectionMutationEvidence
    ): AppTlsDefaultSelectionMutationGate {
        buildAppTlsDefaultSelectionMutationGate(evidence)
    }

    public override func overrideTransportTouchpoint(
        addr: String,
        port: UInt16,
        tlsEnabled: Bool,
        baseTouchpoint: ServerTransportTouchpoint
    ): ServerTransportTouchpoint {
        let _ = addr
        let _ = port
        let _ = tlsEnabled
        let defaultSelected =
            _selectionLabel == "default-cleartext" ||
            _selectionLabel == "default-tls"
        let tlsDefaultSelected = _selectionLabel == "default-tls"
        let tlsOptInSelected = _selectionLabel == "config-opt-in-tls"
        buildServerEngineOverrideTouchpoint(
            baseTouchpoint,
            "ignite-socket-server-shell",
            if (tlsDefaultSelected) {
                "native_h1_tls_default_selected"
            } else if (tlsOptInSelected) {
                "native_h1_tls_opt_in_selected"
            } else if (defaultSelected) {
                "native_h1_default_selected"
            } else {
                "opt_in_engine_shell_selected"
            },
            if (tlsDefaultSelected) {
                "native-h1-tls-default"
            } else if (tlsOptInSelected) {
                "native-h1-tls-opt-in"
            } else if (defaultSelected) {
                "native-h1-default"
            } else {
                "opt-in-engine-shell"
            },
            if (defaultSelected) {
                "default"
            } else {
                "experimental"
            },
            if (tlsDefaultSelected) {
                "tls_h1_default_native"
            } else if (tlsOptInSelected) {
                "tls_h1_experimental_opt_in"
            } else if (defaultSelected) {
                "cleartext_h1_default_native"
            } else {
                "cleartext_h1_first_runnable"
            }
        )
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        runSocketServerEngineShellListen(
            option,
            app,
            onReady,
            _runtimeControl,
            socketServerEngineShellAcceptedConnectionLimit(_selectionLabel),
            tlsAcceptedSessionReadyHook: _tlsAcceptedSessionReadyHook
        )
    }

    public override func runtimeCounterSnapshot(): ServerRuntimeCounterSnapshot {
        _runtimeControl.runtimeCounterSnapshot()
    }

    public override func shutdown(): Unit {
        _runtimeControl.requestShutdown()
    }
}

public func buildSocketServerEngineShellProductionCandidateGate(
    evidence: SocketServerEngineShellProductionCandidateEvidence
): SocketServerEngineShellProductionCandidateGate {
    let requiredProofs = socketServerEngineShellProductionCandidateRequiredProofs()
    let missingProofs =
        socketServerEngineShellProductionCandidateMissingProofs(evidence)
    let blockers =
        socketServerEngineShellProductionCandidateBlockers(evidence, missingProofs)
    let candidate = missingProofs.size == 0 && blockers.size == 0

    SocketServerEngineShellProductionCandidateGate(
        candidate,
        if (candidate) {
            "production-candidate-gate-ready"
        } else {
            "blocked-production-candidate-gap"
        },
        if (candidate) {
            "defer-default-flip-to-release-gate"
        } else {
            "blocked-before-default-flip"
        },
        requiredProofs,
        missingProofs,
        blockers,
        socketServerEngineShellProductionCandidateGaps(missingProofs, blockers),
        [
            "NO_DEFAULT_FLIP",
            "NO_STDX_REMOVAL_CLAIM",
            "NO_TLS_CLAIM",
            "NO_H2_RUNTIME_CLAIM",
        ],
        if (candidate) {
            "open one release/default-flip gate packet only after broader parity and operator acceptance"
        } else {
            "collect missing H1 shell lifetime, shutdown, soak, parity, or TLS-provider proof before release gate"
        },
        "long-lived connection, shutdown, soak, and parity checklist can be reused by QUIC"
    )
}

public func buildSocketServerEngineShellDefaultFlipReadinessGate(
    evidence: SocketServerEngineShellDefaultFlipReadinessEvidence
): SocketServerEngineShellDefaultFlipReadinessGate {
    let requiredProofs = socketServerEngineShellDefaultFlipRequiredProofs()
    let missingProofs =
        socketServerEngineShellDefaultFlipMissingProofs(evidence)
    let blockers =
        socketServerEngineShellDefaultFlipBlockers(evidence, missingProofs)
    let ready = missingProofs.size == 0 && blockers.size == 0

    SocketServerEngineShellDefaultFlipReadinessGate(
        ready,
        if (ready) {
            "default-flip-readiness-ready"
        } else {
            "blocked-default-flip-readiness-gap"
        },
        if (ready) {
            "ready-for-separate-default-engine-change-packet"
        } else {
            "keep-stdx-default"
        },
        requiredProofs,
        missingProofs,
        blockers,
        [
            "NO_DEFAULT_FLIP_IN_THIS_PACKET",
            "NO_STDX_REMOVAL_CLAIM",
            "NO_TLS_CLAIM",
            "NO_H2_RUNTIME_CLAIM",
        ],
        if (ready) {
            "open an explicit release/default-engine-change packet; do not flip default in this proof packet"
        } else {
            "collect missing production-candidate, operator acceptance, release guard, rollback, or public docs proof before default flip"
        },
        "QUIC and future native transports should split production-candidate readiness from default-selection readiness"
    )
}

public func buildSocketServerEngineShellProductionCandidateGateWithTlsProviderReadiness(
    evidence: SocketServerEngineShellProductionCandidateEvidence,
    providerReadinessGate: ServerJinguiTlsProviderReadinessGate
): SocketServerEngineShellProductionCandidateGate {
    let requiredProofs = socketServerEngineShellProductionCandidateRequiredProofs()
    let missingProofs =
        socketServerEngineShellProductionCandidateMissingProofs(evidence)
    let blockers =
        socketServerEngineShellProductionCandidateBlockersWithTlsProviderReadiness(
            evidence,
            missingProofs,
            providerReadinessGate
        )
    let candidate = missingProofs.size == 0 && blockers.size == 0

    SocketServerEngineShellProductionCandidateGate(
        candidate,
        if (candidate) {
            "production-candidate-gate-ready"
        } else {
            "blocked-production-candidate-gap"
        },
        if (candidate) {
            "defer-default-flip-to-release-gate"
        } else {
            "blocked-before-default-flip"
        },
        requiredProofs,
        missingProofs,
        blockers,
        socketServerEngineShellProductionCandidateGapsWithTlsProviderReadiness(
            missingProofs,
            blockers
        ),
        [
            "NO_DEFAULT_FLIP",
            "NO_STDX_REMOVAL_CLAIM",
            "NO_TLS_RUNTIME_DEFAULT_CLAIM",
            "NO_H2_RUNTIME_CLAIM",
        ],
        if (candidate) {
            "open one release/default-flip gate packet only after broader parity and operator acceptance"
        } else {
            "collect missing H1 shell proofs or SR-030 provider readiness before release gate"
        },
        "long-lived connection, shutdown, parity, and provider-readiness checklist can be reused by QUIC"
    )
}

public func buildSocketServerEngineShellH1DefaultReplacementPreflightGate(
    evidence: SocketServerEngineShellH1DefaultReplacementPreflightEvidence
): SocketServerEngineShellH1DefaultReplacementPreflightGate {
    let requiredProofs =
        socketServerEngineShellH1DefaultReplacementPreflightRequiredProofs()
    let blockers =
        socketServerEngineShellH1DefaultReplacementPreflightBlockers(evidence)
    let accepted = blockers.size == 0

    SocketServerEngineShellH1DefaultReplacementPreflightGate(
        accepted,
        evidence.preflightId,
        if (accepted) {
            "h1-native-default-replacement-preflight-ready"
        } else {
            "blocked-h1-native-default-replacement-preflight-gap"
        },
        if (accepted) {
            "ready-for-separate-default-engine-change-packet"
        } else {
            "keep-stdx-default"
        },
        requiredProofs,
        blockers,
        false,
        false,
        false,
        false,
        false,
        false,
        socketServerEngineShellH1DefaultReplacementPreflightNonClaims(),
        if (accepted) {
            "open one explicit default-engine change packet; do not flip default in this preflight packet"
        } else {
            "complete H1 production, provider, default-readiness, stdx-boundary, hosted projection, and non-mutation proofs first"
        },
        "QUIC can reuse this preflight shape to compose transport readiness, provider readiness, release guard, rollback, and non-mutation proof before a default-path change"
    )
}

public func buildSocketServerEngineShellH1DefaultEngineControlledSwitchGate(
    evidence: SocketServerEngineShellH1DefaultEngineControlledSwitchEvidence
): SocketServerEngineShellH1DefaultEngineControlledSwitchGate {
    let requiredProofs =
        socketServerEngineShellH1DefaultEngineControlledSwitchRequiredProofs()
    let blockers =
        socketServerEngineShellH1DefaultEngineControlledSwitchBlockers(evidence)
    let accepted = blockers.size == 0

    SocketServerEngineShellH1DefaultEngineControlledSwitchGate(
        accepted,
        evidence.switchId,
        evidence.candidateEngine,
        evidence.fallbackEngine,
        if (accepted) {
            "h1-default-engine-controlled-switch-ready"
        } else {
            "blocked-h1-default-engine-controlled-switch-gap"
        },
        if (accepted) {
            "ready-for-separate-runtime-default-mutation-packet"
        } else {
            "keep-stdx-default"
        },
        requiredProofs,
        blockers,
        accepted,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        socketServerEngineShellH1DefaultEngineControlledSwitchNonClaims(),
        if (accepted) {
            "open one explicit runtime default mutation packet; do not mutate App default in this controlled switch packet"
        } else {
            "complete preflight, candidate, fallback, config hint, rollback, operator, release guard, startup observation, and non-mutation proofs first"
        },
        "QUIC can reuse this controlled switch gate before mutating a default transport or stream runtime path"
    )
}

public func buildSocketServerEngineShellH1DefaultMutationReleaseGuard(
    evidence: SocketServerEngineShellH1DefaultMutationReleaseGuardEvidence
): SocketServerEngineShellH1DefaultMutationReleaseGuard {
    let requiredProofs =
        socketServerEngineShellH1DefaultMutationReleaseGuardRequiredProofs()
    let blockers =
        socketServerEngineShellH1DefaultMutationReleaseGuardBlockers(evidence)
    let accepted = blockers.size == 0

    SocketServerEngineShellH1DefaultMutationReleaseGuard(
        accepted,
        evidence.guardId,
        evidence.releaseVersionTarget,
        evidence.publicBaselineProjection,
        if (accepted) {
            "h1-default-mutation-release-guard-ready"
        } else {
            "blocked-h1-default-mutation-release-guard-gap"
        },
        if (accepted) {
            "ready-for-separate-default-mutation-packet"
        } else {
            "keep-stdx-default"
        },
        requiredProofs,
        blockers,
        accepted,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        socketServerEngineShellH1DefaultMutationReleaseGuardNonClaims(),
        if (accepted) {
            "open one explicit default-mutation packet; do not flip default in this release-guard packet"
        } else {
            "complete controlled switch, release, rollback, docs, hosted dependency, baseline, and separate-packet proofs first"
        },
        "QUIC can reuse this release guard shape before defaulting a native transport with hosted dependency and rollback pressure"
    )
}

public func buildSocketServerEngineShellH1CleartextDefaultCloseGate(
    evidence: SocketServerEngineShellH1CleartextDefaultCloseEvidence
): SocketServerEngineShellH1CleartextDefaultCloseGate {
    let requiredProofs =
        socketServerEngineShellH1CleartextDefaultCloseRequiredProofs()
    let blockers =
        socketServerEngineShellH1CleartextDefaultCloseBlockers(evidence)
    let accepted = blockers.size == 0

    SocketServerEngineShellH1CleartextDefaultCloseGate(
        accepted,
        evidence.closeId,
        if (accepted) {
            "h1-cleartext-default-close-accepted"
        } else {
            "blocked-h1-cleartext-default-close-gap"
        },
        if (accepted) {
            "accept-ignitenext-cleartext-default-native-and-advance-with-tls-stdx-fallback"
        } else {
            "keep-sr010-open-before-broader-claim"
        },
        requiredProofs,
        blockers,
        accepted,
        false,
        false,
        false,
        false,
        false,
        false,
        socketServerEngineShellH1CleartextDefaultCloseNonClaims(),
        if (accepted) {
            "move to TLS-native H1 seam, H2 runtime closure, or native client packet; do not publish or remove stdx from this close gate"
        } else {
            "complete default selection, rollback, TLS fallback, focused regression, and public-baseline non-mutation proofs first"
        },
        "QUIC and future transports can reuse this close gate to separate default cleartext acceptance from TLS, source-zero, release, and sibling protocol claims"
    )
}

public func buildSocketServerEngineShellH1TlsNativeSeamCloseGapGate(
    evidence: SocketServerEngineShellH1TlsNativeSeamCloseGapEvidence
): SocketServerEngineShellH1TlsNativeSeamCloseGapGate {
    let requiredProofs =
        socketServerEngineShellH1TlsNativeSeamCloseGapRequiredProofs()
    let blockers =
        socketServerEngineShellH1TlsNativeSeamCloseGapBlockers(evidence)
    let ready = blockers.size == 0

    SocketServerEngineShellH1TlsNativeSeamCloseGapGate(
        ready,
        evidence.closeId,
        if (ready) {
            "h1-tls-native-seam-close-gap-ready"
        } else {
            "blocked-h1-tls-native-seam-close-gap"
        },
        if (ready) {
            "accept-h1-tls-native-seam-and-open-default-tls-mutation-packet"
        } else {
            "keep-h1-tls-native-seam-open-before-default-mutation"
        },
        requiredProofs,
        blockers,
        false,
        false,
        false,
        false,
        false,
        false,
        socketServerEngineShellH1TlsNativeSeamCloseGapNonClaims(),
        if (ready) {
            "open one explicit App TLS default mutation packet; do not mutate TLS default or remove stdx in this seam gate"
        } else {
            "complete provider readiness, accepted-transport attach, runtime-safe handshake, live-listen attach, TLS config selection, and rollback fallback proofs first"
        },
        "QUIC can reuse this seam gate to separate provider readiness from default transport mutation and release claims"
    )
}

public func buildAppTlsDefaultMutationDryRunGate(
    evidence: AppTlsDefaultMutationDryRunEvidence
): AppTlsDefaultMutationDryRunGate {
    let requiredProofs =
        appTlsDefaultMutationDryRunRequiredProofs()
    let blockers = appTlsDefaultMutationDryRunBlockers(evidence)
    let accepted = blockers.size == 0

    AppTlsDefaultMutationDryRunGate(
        accepted,
        evidence.dryRunId,
        if (accepted) {
            "app-tls-default-mutation-dry-run-ready"
        } else {
            "blocked-app-tls-default-mutation-dry-run-gap"
        },
        if (accepted) {
            "accept-app-tls-default-mutation-dry-run-and-open-apply-gate-packet"
        } else {
            "keep-app-tls-default-mutation-blocked-before-apply"
        },
        requiredProofs,
        blockers,
        accepted,
        false,
        false,
        false,
        false,
        false,
        false,
        appTlsDefaultMutationDryRunNonClaims(),
        if (accepted) {
            "open one explicit App TLS default mutation apply gate; do not mutate TLS default or remove stdx in this dry-run packet"
        } else {
            "complete seam readiness, TLS config dry-run, stdx rollback, startup observation, focused regression, and public-baseline non-mutation proofs first"
        },
        "QUIC can reuse this dry-run gate to keep provider/runtime readiness separate from default-path mutation"
    )
}

public func buildAppTlsDefaultMutationApplyGate(
    evidence: AppTlsDefaultMutationApplyGateEvidence
): AppTlsDefaultMutationApplyGate {
    let requiredProofs = appTlsDefaultMutationApplyGateRequiredProofs()
    let blockers = appTlsDefaultMutationApplyGateBlockers(evidence)
    let accepted = blockers.size == 0

    AppTlsDefaultMutationApplyGate(
        accepted,
        evidence.applyId,
        if (accepted) {
            "app-tls-default-mutation-apply-gate-ready"
        } else {
            "blocked-app-tls-default-mutation-apply-gate"
        },
        if (accepted) {
            "accept-apply-gate-and-open-native-tls-ingress-or-mutation-packet"
        } else {
            "keep-app-tls-default-mutation-blocked-before-native-tls-ingress"
        },
        requiredProofs,
        blockers,
        evidence.nativeSocketTlsListenSupportProof,
        evidence.acceptedTransportLiveIngressProof,
        evidence.appPolicyMutationPlanProof,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        appTlsDefaultMutationApplyGateNonClaims(),
        if (accepted) {
            "open one explicit native TLS ingress implementation or App TLS mutation packet; do not mutate TLS default in this apply-gate packet"
        } else {
            "complete dry-run, native socket TLS listen support, accepted-transport live ingress, App policy mutation plan, rollback, and regression proofs first"
        },
        "QUIC can reuse this apply gate to keep live-ingress support distinct from default-path mutation"
    )
}

public func buildAppTlsLiveIngressConsumptionGate(
    evidence: AppTlsLiveIngressConsumptionEvidence
): AppTlsLiveIngressConsumptionGate {
    let requiredProofs = appTlsLiveIngressConsumptionRequiredProofs()
    let blockers = appTlsLiveIngressConsumptionBlockers(evidence)
    let accepted = blockers.size == 0

    AppTlsLiveIngressConsumptionGate(
        accepted,
        evidence.consumptionId,
        if (accepted) {
            "app-tls-live-ingress-consumption-gate-ready"
        } else {
            "blocked-app-tls-live-ingress-consumption-gate"
        },
        if (accepted) {
            "accept-hq0576-live-ingress-consumption-and-open-app-tls-default-selection-mutation-packet"
        } else {
            "keep-app-tls-default-mutation-blocked-before-live-ingress-consumption"
        },
        requiredProofs,
        blockers,
        evidence.nativeTlsLiveIngressFirstCutReceiptProof,
        evidence.acceptedTransportH2HeadersPlusDataProof,
        evidence.staleNativeIngressBlockerRebasedProof,
        false,
        false,
        false,
        false,
        false,
        false,
        appTlsLiveIngressConsumptionNonClaims(),
        if (accepted) {
            "open one explicit App TLS default-selection mutation packet; do not mutate TLS default in this consumption gate"
        } else {
            "complete apply gate, HQ-0576 live-ingress first-cut receipt, accepted-transport H2 HEADERS+DATA proof, stale blocker rebaseline, rollback, and regression proofs first"
        },
        "QUIC can reuse this consumption gate to keep first-cut live ingress separate from default-path mutation"
    )
}

public func buildAppTlsDefaultSelectionMutationGate(
    evidence: AppTlsDefaultSelectionMutationEvidence
): AppTlsDefaultSelectionMutationGate {
    let requiredProofs = appTlsDefaultSelectionMutationRequiredProofs()
    let blockers = appTlsDefaultSelectionMutationBlockers(evidence)
    let accepted = blockers.size == 0

    AppTlsDefaultSelectionMutationGate(
        accepted,
        evidence.mutationId,
        if (accepted) {
            "app-tls-default-selection-mutation-accepted"
        } else {
            "blocked-app-tls-default-selection-mutation"
        },
        if (accepted) {
            "accept-app-tls-default-selection-mutation-and-preserve-stdx-rollback"
        } else {
            "keep-app-tls-default-selection-mutation-blocked"
        },
        requiredProofs,
        blockers,
        accepted,
        evidence.tlsConfigDefaultNativeSelectionProof,
        evidence.explicitStdxRollbackSelectionProof,
        false,
        false,
        false,
        false,
        false,
        false,
        appTlsDefaultSelectionMutationNonClaims(),
        if (accepted) {
            "open H1 full default replacement close gate or H2 runtime packet; do not release or remove stdx in this mutation packet"
        } else {
            "complete HQ-0577 consumption, TLS native selection, explicit stdx rollback, startup observation, focused regression, and public-baseline non-mutation proofs first"
        },
        "QUIC can reuse this mutation gate to split default selection from source-zero, release, and browser-grade protocol closure"
    )
}

func socketServerEngineShellProductionCandidateRequiredProofs(): Array<String> {
    [
        "ACCEPT_LOOP_MULTI_CONNECTION_PROOF",
        "SHUTDOWN_STOP_PROOF",
        "KEEPALIVE_SOAK_PROOF",
        "STREAM_FILE_PARITY_PROOF",
        "STDX_PARITY_PROOF",
    ]
}

func socketServerEngineShellProductionCandidateMissingProofs(
    evidence: SocketServerEngineShellProductionCandidateEvidence
): Array<String> {
    var missing = ArrayList<String>()
    if (evidence.acceptedConnectionLimit < 2) {
        missing.add("ACCEPT_LOOP_MULTI_CONNECTION_PROOF")
    }
    if (!evidence.shutdownStopProof) {
        missing.add("SHUTDOWN_STOP_PROOF")
    }
    if (!evidence.keepAliveSoakProof) {
        missing.add("KEEPALIVE_SOAK_PROOF")
    }
    if (!evidence.streamFileParityProof) {
        missing.add("STREAM_FILE_PARITY_PROOF")
    }
    if (!evidence.stdxParityProof) {
        missing.add("STDX_PARITY_PROOF")
    }
    missing.toArray()
}

func socketServerEngineShellDefaultFlipRequiredProofs(): Array<String> {
    [
        "PRODUCTION_CANDIDATE_GATE_READY",
        "OPERATOR_ACCEPTANCE_PROOF",
        "RELEASE_GUARD_PROOF",
        "ROLLBACK_PLAN_PROOF",
        "PUBLIC_DOCS_PROOF",
    ]
}

func socketServerEngineShellDefaultFlipMissingProofs(
    evidence: SocketServerEngineShellDefaultFlipReadinessEvidence
): Array<String> {
    var missing = ArrayList<String>()
    if (!evidence.productionCandidateGate.productionCandidate) {
        missing.add("PRODUCTION_CANDIDATE_GATE_READY")
    }
    if (!evidence.operatorAcceptanceProof) {
        missing.add("OPERATOR_ACCEPTANCE_PROOF")
    }
    if (!evidence.releaseGuardProof) {
        missing.add("RELEASE_GUARD_PROOF")
    }
    if (!evidence.rollbackPlanProof) {
        missing.add("ROLLBACK_PLAN_PROOF")
    }
    if (!evidence.publicDocsProof) {
        missing.add("PUBLIC_DOCS_PROOF")
    }
    missing.toArray()
}

func socketServerEngineShellDefaultFlipBlockers(
    evidence: SocketServerEngineShellDefaultFlipReadinessEvidence,
    missingProofs: Array<String>
): Array<String> {
    var blockers = ArrayList<String>()
    if (!evidence.productionCandidateGate.productionCandidate) {
        blockers.add("PRODUCTION_CANDIDATE_GATE_NOT_READY")
        for (blocker in evidence.productionCandidateGate.blockers) {
            blockers.add("PRODUCTION_CANDIDATE_BLOCKER:${blocker}")
        }
    }
    for (missing in missingProofs) {
        if (missing != "PRODUCTION_CANDIDATE_GATE_READY") {
            blockers.add("MISSING:${missing}")
        }
    }
    blockers.toArray()
}

func socketServerEngineShellProductionCandidateBlockers(
    evidence: SocketServerEngineShellProductionCandidateEvidence,
    missingProofs: Array<String>
): Array<String> {
    var blockers = ArrayList<String>()
    if (evidence.tlsEnabled) {
        blockers.add("TLS_PROVIDER_SEAM_REQUIRED")
    }
    for (missing in missingProofs) {
        blockers.add("MISSING:${missing}")
    }
    blockers.toArray()
}

func socketServerEngineShellProductionCandidateBlockersWithTlsProviderReadiness(
    evidence: SocketServerEngineShellProductionCandidateEvidence,
    missingProofs: Array<String>,
    providerReadinessGate: ServerJinguiTlsProviderReadinessGate
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        evidence.tlsEnabled &&
        !providerReadinessGate.h1TlsProviderSeamSatisfied
    ) {
        blockers.add("TLS_PROVIDER_SEAM_REQUIRED")
        blockers.add("TLS_PROVIDER_GATE:${providerReadinessGate.status}")
        for (blocker in providerReadinessGate.blockers) {
            blockers.add("TLS_PROVIDER_BLOCKER:${blocker}")
        }
    }
    for (missing in missingProofs) {
        blockers.add("MISSING:${missing}")
    }
    blockers.toArray()
}

func socketServerEngineShellH1DefaultReplacementPreflightRequiredProofs(
): Array<String> {
    [
        "PREFLIGHT_ID",
        "PRODUCTION_CANDIDATE_GATE_READY",
        "DEFAULT_FLIP_READINESS_GATE_READY",
        "JINGUISSL_TLS_PROVIDER_SEAM_SATISFIED",
        "STDX_CLAIM_BOUNDARY_PROOF",
        "DEFAULT_ENGINE_CONFIG_UNCHANGED_PROOF",
        "HOSTED_DEPENDENCY_PROJECTION_PROOF",
        "SEPARATE_CHANGE_PACKET_PROOF",
    ]
}

func socketServerEngineShellH1DefaultReplacementPreflightBlockers(
    evidence: SocketServerEngineShellH1DefaultReplacementPreflightEvidence
): Array<String> {
    var blockers = ArrayList<String>()
    if (evidence.preflightId.size == 0) {
        blockers.add("PREFLIGHT_ID_NOT_CARRIED")
    }
    if (!evidence.productionCandidateGate.productionCandidate) {
        blockers.add("PRODUCTION_CANDIDATE_GATE_NOT_READY")
        for (blocker in evidence.productionCandidateGate.blockers) {
            blockers.add("PRODUCTION_CANDIDATE_BLOCKER:${blocker}")
        }
    }
    if (!evidence.defaultFlipReadinessGate.defaultFlipReady) {
        blockers.add("DEFAULT_FLIP_READINESS_GATE_NOT_READY")
        for (blocker in evidence.defaultFlipReadinessGate.blockers) {
            blockers.add("DEFAULT_FLIP_READINESS_BLOCKER:${blocker}")
        }
    }
    if (!evidence.providerReadinessGate.h1TlsProviderSeamSatisfied) {
        blockers.add("JINGUISSL_TLS_PROVIDER_SEAM_NOT_SATISFIED")
        blockers.add("JINGUISSL_PROVIDER_GATE:${evidence.providerReadinessGate.status}")
        for (blocker in evidence.providerReadinessGate.blockers) {
            blockers.add("JINGUISSL_PROVIDER_BLOCKER:${blocker}")
        }
    }
    if (!evidence.stdxClaimBoundaryProof) {
        blockers.add("STDX_CLAIM_BOUNDARY_PROOF_NOT_CARRIED")
    }
    if (!evidence.defaultEngineConfigUnchangedProof) {
        blockers.add("DEFAULT_ENGINE_CONFIG_UNCHANGED_PROOF_NOT_CARRIED")
    }
    if (!evidence.hostedDependencyProjectionProof) {
        blockers.add("HOSTED_DEPENDENCY_PROJECTION_PROOF_NOT_CARRIED")
    }
    if (!evidence.separateChangePacketProof) {
        blockers.add("SEPARATE_CHANGE_PACKET_PROOF_NOT_CARRIED")
    }
    if (evidence.actualDefaultFlipRequested) {
        blockers.add("ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    }
    if (evidence.defaultEngineConfigMutationRequested) {
        blockers.add("DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    }
    if (evidence.runtimeDefaultPathMutationRequested) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    }
    if (evidence.stdxRemovalRequested) {
        blockers.add("STDX_REMOVAL_REQUESTED")
    }
    if (evidence.h2RuntimeClosureClaimed) {
        blockers.add("H2_RUNTIME_CLOSURE_CLAIMED")
    }
    if (evidence.publicReleaseOrHostedPublicationClaimed) {
        blockers.add("PUBLIC_RELEASE_OR_HOSTED_PUBLICATION_CLAIMED")
    }
    blockers.toArray()
}

func socketServerEngineShellH1DefaultReplacementPreflightNonClaims(
): Array<String> {
    [
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_STDX_REMOVAL",
        "NO_H1_NATIVE_DEFAULT_REPLACEMENT_CLOSEOUT_CLAIM",
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_PUBLIC_RELEASE_OR_HOSTED_PUBLICATION_CLAIM",
    ]
}

func socketServerEngineShellH1DefaultEngineControlledSwitchRequiredProofs(
): Array<String> {
    [
        "SWITCH_ID",
        "H1_DEFAULT_REPLACEMENT_PREFLIGHT_ACCEPTED",
        "CANDIDATE_ENGINE_IGNITE_NATIVE_H1",
        "FALLBACK_ENGINE_STDX_HTTP_SERVER",
        "CONFIG_HINT_NATIVE_H1",
        "ROLLBACK_PLAN_PROOF",
        "OPERATOR_APPROVAL_PROOF",
        "RELEASE_GUARD_PROOF",
        "STARTUP_OBSERVATION_PROOF",
        "APP_CONSTRUCTOR_DEFAULT_UNCHANGED_PROOF",
    ]
}

func socketServerEngineShellH1DefaultEngineControlledSwitchBlockers(
    evidence: SocketServerEngineShellH1DefaultEngineControlledSwitchEvidence
): Array<String> {
    var blockers = ArrayList<String>()
    if (evidence.switchId.size == 0) {
        blockers.add("SWITCH_ID_NOT_CARRIED")
    }
    if (!evidence.preflightGate.h1DefaultReplacementPreflightAccepted) {
        blockers.add("H1_DEFAULT_REPLACEMENT_PREFLIGHT_NOT_ACCEPTED")
        for (blocker in evidence.preflightGate.blockers) {
            blockers.add("PREFLIGHT_BLOCKER:${blocker}")
        }
    }
    if (evidence.candidateEngine != "ignite-native-h1") {
        blockers.add("CANDIDATE_ENGINE_NOT_IGNITE_NATIVE_H1")
    }
    if (evidence.fallbackEngine != "stdx-http-server") {
        blockers.add("FALLBACK_ENGINE_NOT_STDX_HTTP_SERVER")
    }
    if (
        evidence.configHint != "native-h1" &&
        evidence.configHint != "ignite-native-h1"
    ) {
        blockers.add("CONFIG_HINT_NOT_NATIVE_H1")
    }
    if (!evidence.rollbackPlanProof) {
        blockers.add("ROLLBACK_PLAN_PROOF_NOT_CARRIED")
    }
    if (!evidence.operatorApprovalProof) {
        blockers.add("OPERATOR_APPROVAL_PROOF_NOT_CARRIED")
    }
    if (!evidence.releaseGuardProof) {
        blockers.add("RELEASE_GUARD_PROOF_NOT_CARRIED")
    }
    if (!evidence.startupObservationProof) {
        blockers.add("STARTUP_OBSERVATION_PROOF_NOT_CARRIED")
    }
    if (!evidence.appConstructorDefaultUnchangedProof) {
        blockers.add("APP_CONSTRUCTOR_DEFAULT_UNCHANGED_PROOF_NOT_CARRIED")
    }
    if (evidence.actualDefaultEngineFlipRequested) {
        blockers.add("ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    }
    if (evidence.appConstructorDefaultMutationRequested) {
        blockers.add("APP_CONSTRUCTOR_DEFAULT_MUTATION_REQUESTED")
    }
    if (evidence.defaultEngineConfigMutationRequested) {
        blockers.add("DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    }
    if (evidence.runtimeDefaultPathMutationRequested) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    }
    if (evidence.stdxRemovalRequested) {
        blockers.add("STDX_REMOVAL_REQUESTED")
    }
    if (evidence.h2RuntimeClosureClaimed) {
        blockers.add("H2_RUNTIME_CLOSURE_CLAIMED")
    }
    if (evidence.publicReleaseOrHostedPublicationClaimed) {
        blockers.add("PUBLIC_RELEASE_OR_HOSTED_PUBLICATION_CLAIMED")
    }
    blockers.toArray()
}

func socketServerEngineShellH1DefaultEngineControlledSwitchNonClaims(
): Array<String> {
    [
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_APP_CONSTRUCTOR_DEFAULT_MUTATION",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_STDX_REMOVAL",
        "NO_H1_NATIVE_DEFAULT_REPLACEMENT_CLOSEOUT_CLAIM",
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_PUBLIC_RELEASE_OR_HOSTED_PUBLICATION_CLAIM",
    ]
}

func socketServerEngineShellH1DefaultMutationReleaseGuardRequiredProofs(
): Array<String> {
    [
        "GUARD_ID",
        "H1_DEFAULT_ENGINE_CONTROLLED_SWITCH_ACCEPTED",
        "RELEASE_VERSION_TARGET",
        "PUBLIC_BASELINE_PROJECTION",
        "RELEASE_GUARD_PROOF",
        "ROLLBACK_VERIFICATION_PROOF",
        "PUBLIC_DOCS_PROOF",
        "MIGRATION_GUIDE_PROOF",
        "HOSTED_DEPENDENCY_PROJECTION_PROOF",
        "HOSTED_DEPENDENCY_RESOLUTION_PROOF",
        "PUBLIC_BASELINE_PROJECTION_PROOF",
        "SEPARATE_DEFAULT_MUTATION_PACKET_PROOF",
    ]
}

func socketServerEngineShellH1DefaultMutationReleaseGuardBlockers(
    evidence: SocketServerEngineShellH1DefaultMutationReleaseGuardEvidence
): Array<String> {
    var blockers = ArrayList<String>()
    if (evidence.guardId.size == 0) {
        blockers.add("GUARD_ID_NOT_CARRIED")
    }
    if (!evidence.controlledSwitchGate.controlledSwitchAccepted) {
        blockers.add("H1_DEFAULT_ENGINE_CONTROLLED_SWITCH_NOT_ACCEPTED")
        for (blocker in evidence.controlledSwitchGate.blockers) {
            blockers.add("CONTROLLED_SWITCH_BLOCKER:${blocker}")
        }
    }
    if (evidence.releaseVersionTarget.size == 0) {
        blockers.add("RELEASE_VERSION_TARGET_NOT_CARRIED")
    }
    if (evidence.publicBaselineProjection.size == 0) {
        blockers.add("PUBLIC_BASELINE_PROJECTION_NOT_CARRIED")
    }
    if (!evidence.releaseGuardProof) {
        blockers.add("RELEASE_GUARD_PROOF_NOT_CARRIED")
    }
    if (!evidence.rollbackVerificationProof) {
        blockers.add("ROLLBACK_VERIFICATION_PROOF_NOT_CARRIED")
    }
    if (!evidence.publicDocsProof) {
        blockers.add("PUBLIC_DOCS_PROOF_NOT_CARRIED")
    }
    if (!evidence.migrationGuideProof) {
        blockers.add("MIGRATION_GUIDE_PROOF_NOT_CARRIED")
    }
    if (!evidence.hostedDependencyProjectionProof) {
        blockers.add("HOSTED_DEPENDENCY_PROJECTION_PROOF_NOT_CARRIED")
    }
    if (!evidence.hostedDependencyResolutionProof) {
        blockers.add("HOSTED_DEPENDENCY_RESOLUTION_PROOF_NOT_CARRIED")
    }
    if (!evidence.publicBaselineProjectionProof) {
        blockers.add("PUBLIC_BASELINE_PROJECTION_PROOF_NOT_CARRIED")
    }
    if (!evidence.separateDefaultMutationPacketProof) {
        blockers.add("SEPARATE_DEFAULT_MUTATION_PACKET_PROOF_NOT_CARRIED")
    }
    if (evidence.actualDefaultEngineFlipRequested) {
        blockers.add("ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    }
    if (evidence.appConstructorDefaultMutationRequested) {
        blockers.add("APP_CONSTRUCTOR_DEFAULT_MUTATION_REQUESTED")
    }
    if (evidence.defaultEngineConfigMutationRequested) {
        blockers.add("DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    }
    if (evidence.runtimeDefaultPathMutationRequested) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    }
    if (evidence.stdxRemovalRequested) {
        blockers.add("STDX_REMOVAL_REQUESTED")
    }
    if (evidence.h2RuntimeClosureClaimed) {
        blockers.add("H2_RUNTIME_CLOSURE_CLAIMED")
    }
    if (evidence.publicReleaseOrHostedPublicationClaimed) {
        blockers.add("PUBLIC_RELEASE_OR_HOSTED_PUBLICATION_CLAIMED")
    }
    blockers.toArray()
}

func socketServerEngineShellH1DefaultMutationReleaseGuardNonClaims(
): Array<String> {
    [
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_APP_CONSTRUCTOR_DEFAULT_MUTATION",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_STDX_REMOVAL",
        "NO_H1_NATIVE_DEFAULT_REPLACEMENT_CLOSEOUT_CLAIM",
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_PUBLIC_RELEASE_OR_HOSTED_PUBLICATION_CLAIM",
        "NO_RELEASE_TAG_MR_PR_HOSTED_PUBLICATION",
    ]
}

func socketServerEngineShellH1CleartextDefaultCloseRequiredProofs(
): Array<String> {
    [
        "CLOSE_ID",
        "H1_DEFAULT_MUTATION_RELEASE_GUARD_ACCEPTED",
        "DEFAULT_NATIVE_SELECTION_PROOF",
        "STDX_ROLLBACK_HINT_PROOF",
        "TLS_FALLBACK_PRESERVATION_PROOF",
        "FOCUSED_REGRESSION_PROOF",
        "PUBLIC_BASELINE_NON_MUTATION_PROOF",
    ]
}

func socketServerEngineShellH1CleartextDefaultCloseBlockers(
    evidence: SocketServerEngineShellH1CleartextDefaultCloseEvidence
): Array<String> {
    var blockers = ArrayList<String>()
    if (evidence.closeId.size == 0) {
        blockers.add("CLOSE_ID_NOT_CARRIED")
    }
    if (!evidence.defaultMutationReleaseGuard.releaseGuardAccepted) {
        blockers.add("H1_DEFAULT_MUTATION_RELEASE_GUARD_NOT_ACCEPTED")
        for (blocker in evidence.defaultMutationReleaseGuard.blockers) {
            blockers.add("RELEASE_GUARD_BLOCKER:${blocker}")
        }
    }
    if (!evidence.defaultNativeSelectionProof) {
        blockers.add("DEFAULT_NATIVE_SELECTION_PROOF_NOT_CARRIED")
    }
    if (!evidence.stdxRollbackHintProof) {
        blockers.add("STDX_ROLLBACK_HINT_PROOF_NOT_CARRIED")
    }
    if (!evidence.tlsFallbackPreservationProof) {
        blockers.add("TLS_FALLBACK_PRESERVATION_PROOF_NOT_CARRIED")
    }
    if (!evidence.focusedRegressionProof) {
        blockers.add("FOCUSED_REGRESSION_PROOF_NOT_CARRIED")
    }
    if (!evidence.publicBaselineNonMutationProof) {
        blockers.add("PUBLIC_BASELINE_NON_MUTATION_PROOF_NOT_CARRIED")
    }
    if (evidence.sourceZeroStdxClaimed) {
        blockers.add("SOURCE_ZERO_STDX_CLAIMED")
    }
    if (evidence.stdxRemovalRequested) {
        blockers.add("STDX_REMOVAL_REQUESTED")
    }
    if (evidence.tlsNativeH1Claimed) {
        blockers.add("TLS_NATIVE_H1_CLAIMED")
    }
    if (evidence.h2RuntimeClosureClaimed) {
        blockers.add("H2_RUNTIME_CLOSURE_CLAIMED")
    }
    if (evidence.publicReleaseOrHostedPublicationClaimed) {
        blockers.add("PUBLIC_RELEASE_OR_HOSTED_PUBLICATION_CLAIMED")
    }
    blockers.toArray()
}

func socketServerEngineShellH1CleartextDefaultCloseNonClaims(
): Array<String> {
    [
        "NO_IGNITE0700_PUBLIC_BASELINE_MUTATION",
        "NO_SOURCE_ZERO_STDX_CLAIM",
        "NO_STDX_REMOVAL",
        "NO_TLS_NATIVE_H1_CLAIM",
        "NO_FULL_H1_NATIVE_DEFAULT_REPLACEMENT_CLAIM",
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_PUBLIC_RELEASE_OR_HOSTED_PUBLICATION_CLAIM",
    ]
}

func socketServerEngineShellH1TlsNativeSeamCloseGapRequiredProofs(
): Array<String> {
    [
        "CLOSE_ID",
        "H1_CLEARTEXT_DEFAULT_CLOSE_ACCEPTED",
        "JINGUISSL_PROVIDER_READINESS_ACCEPTED",
        "ACCEPTED_TRANSPORT_ATTACH_PASS_PROOF",
        "RUNTIME_SAFE_HANDSHAKE_PROOF",
        "LIVE_LISTEN_ATTACH_PROOF",
        "TLS_CONFIG_SELECTION_PROOF",
        "ROLLBACK_FALLBACK_PROOF",
    ]
}

func socketServerEngineShellH1TlsNativeSeamCloseGapBlockers(
    evidence: SocketServerEngineShellH1TlsNativeSeamCloseGapEvidence
): Array<String> {
    var blockers = ArrayList<String>()
    if (evidence.closeId.size == 0) {
        blockers.add("CLOSE_ID_NOT_CARRIED")
    }
    if (!evidence.cleartextDefaultCloseGate.cleartextDefaultCloseAccepted) {
        blockers.add("H1_CLEARTEXT_DEFAULT_CLOSE_NOT_ACCEPTED")
        for (blocker in evidence.cleartextDefaultCloseGate.blockers) {
            blockers.add("CLEARTEXT_CLOSE_BLOCKER:${blocker}")
        }
    }
    if (!evidence.providerReadinessGate.providerReadinessAccepted) {
        blockers.add("JINGUISSL_PROVIDER_READINESS_NOT_ACCEPTED")
        for (blocker in evidence.providerReadinessGate.blockers) {
            blockers.add("PROVIDER_READINESS_BLOCKER:${blocker}")
        }
    }
    if (!evidence.providerReadinessGate.h1TlsProviderSeamSatisfied) {
        blockers.add("H1_TLS_PROVIDER_SEAM_NOT_SATISFIED")
    }
    if (!evidence.acceptedTransportAttachPassProof) {
        blockers.add("ACCEPTED_TRANSPORT_ATTACH_PASS_PROOF_NOT_CARRIED")
    }
    if (!evidence.runtimeSafeHandshakeProof) {
        blockers.add("RUNTIME_SAFE_HANDSHAKE_PROOF_NOT_CARRIED")
    }
    if (!evidence.liveListenAttachProof) {
        blockers.add("LIVE_LISTEN_ATTACH_PROOF_NOT_CARRIED")
    }
    if (!evidence.tlsConfigSelectionProof) {
        blockers.add("TLS_CONFIG_SELECTION_PROOF_NOT_CARRIED")
    }
    if (!evidence.rollbackFallbackProof) {
        blockers.add("ROLLBACK_FALLBACK_PROOF_NOT_CARRIED")
    }
    if (evidence.defaultTlsNativeMutationRequested) {
        blockers.add("DEFAULT_TLS_NATIVE_MUTATION_REQUESTED")
    }
    if (evidence.sourceZeroStdxClaimed) {
        blockers.add("SOURCE_ZERO_STDX_CLAIMED")
    }
    if (evidence.stdxRemovalRequested) {
        blockers.add("STDX_REMOVAL_REQUESTED")
    }
    if (evidence.fullH1NativeDefaultReplacementClaimed) {
        blockers.add("FULL_H1_NATIVE_DEFAULT_REPLACEMENT_CLAIMED")
    }
    if (evidence.h2RuntimeClosureClaimed) {
        blockers.add("H2_RUNTIME_CLOSURE_CLAIMED")
    }
    if (evidence.publicReleaseOrHostedPublicationClaimed) {
        blockers.add("PUBLIC_RELEASE_OR_HOSTED_PUBLICATION_CLAIMED")
    }
    blockers.toArray()
}

func socketServerEngineShellH1TlsNativeSeamCloseGapNonClaims(
): Array<String> {
    [
        "NO_APP_TLS_DEFAULT_MUTATION",
        "NO_IGNITE0700_PUBLIC_BASELINE_MUTATION",
        "NO_SOURCE_ZERO_STDX_CLAIM",
        "NO_STDX_REMOVAL",
        "NO_FULL_H1_NATIVE_DEFAULT_REPLACEMENT_CLAIM",
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_PUBLIC_RELEASE_OR_HOSTED_PUBLICATION_CLAIM",
    ]
}

func appTlsDefaultMutationDryRunRequiredProofs(
): Array<String> {
    [
        "DRY_RUN_ID",
        "H1_TLS_NATIVE_SEAM_CLOSE_GAP_READY",
        "TLS_CONFIG_NATIVE_SELECTION_DRY_RUN_PROOF",
        "STDX_ROLLBACK_HINT_PROOF",
        "STARTUP_OBSERVATION_PROOF",
        "FOCUSED_REGRESSION_PROOF",
        "PUBLIC_BASELINE_NON_MUTATION_PROOF",
    ]
}

func appTlsDefaultMutationDryRunBlockers(
    evidence: AppTlsDefaultMutationDryRunEvidence
): Array<String> {
    var blockers = ArrayList<String>()
    if (evidence.dryRunId.size == 0) {
        blockers.add("DRY_RUN_ID_NOT_CARRIED")
    }
    if (!evidence.h1TlsNativeSeamGate.h1TlsNativeSeamReady) {
        blockers.add("H1_TLS_NATIVE_SEAM_CLOSE_GAP_NOT_READY")
        for (blocker in evidence.h1TlsNativeSeamGate.blockers) {
            blockers.add("H1_TLS_SEAM_BLOCKER:${blocker}")
        }
    }
    if (!evidence.tlsConfigNativeSelectionDryRunProof) {
        blockers.add("TLS_CONFIG_NATIVE_SELECTION_DRY_RUN_PROOF_NOT_CARRIED")
    }
    if (!evidence.stdxRollbackHintProof) {
        blockers.add("STDX_ROLLBACK_HINT_PROOF_NOT_CARRIED")
    }
    if (!evidence.startupObservationProof) {
        blockers.add("STARTUP_OBSERVATION_PROOF_NOT_CARRIED")
    }
    if (!evidence.focusedRegressionProof) {
        blockers.add("FOCUSED_REGRESSION_PROOF_NOT_CARRIED")
    }
    if (!evidence.publicBaselineNonMutationProof) {
        blockers.add("PUBLIC_BASELINE_NON_MUTATION_PROOF_NOT_CARRIED")
    }
    if (evidence.actualAppTlsDefaultMutationRequested) {
        blockers.add("ACTUAL_APP_TLS_DEFAULT_MUTATION_REQUESTED")
    }
    if (evidence.sourceZeroStdxClaimed) {
        blockers.add("SOURCE_ZERO_STDX_CLAIMED")
    }
    if (evidence.stdxRemovalRequested) {
        blockers.add("STDX_REMOVAL_REQUESTED")
    }
    if (evidence.fullH1NativeDefaultReplacementClaimed) {
        blockers.add("FULL_H1_NATIVE_DEFAULT_REPLACEMENT_CLAIMED")
    }
    if (evidence.h2RuntimeClosureClaimed) {
        blockers.add("H2_RUNTIME_CLOSURE_CLAIMED")
    }
    if (evidence.publicReleaseOrHostedPublicationClaimed) {
        blockers.add("PUBLIC_RELEASE_OR_HOSTED_PUBLICATION_CLAIMED")
    }
    blockers.toArray()
}

func appTlsDefaultMutationDryRunNonClaims(): Array<String> {
    [
        "NO_ACTUAL_APP_TLS_DEFAULT_MUTATION",
        "NO_IGNITE0700_PUBLIC_BASELINE_MUTATION",
        "NO_SOURCE_ZERO_STDX_CLAIM",
        "NO_STDX_REMOVAL",
        "NO_FULL_H1_NATIVE_DEFAULT_REPLACEMENT_CLAIM",
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_PUBLIC_RELEASE_OR_HOSTED_PUBLICATION_CLAIM",
    ]
}

func appTlsDefaultMutationApplyGateRequiredProofs(): Array<String> {
    [
        "APPLY_ID",
        "APP_TLS_DEFAULT_MUTATION_DRY_RUN_ACCEPTED",
        "NATIVE_SOCKET_TLS_LISTEN_SUPPORT_PROOF",
        "ACCEPTED_TRANSPORT_LIVE_INGRESS_PROOF",
        "APP_POLICY_MUTATION_PLAN_PROOF",
        "ROLLBACK_VERIFICATION_PROOF",
        "FOCUSED_REGRESSION_PROOF",
    ]
}

func appTlsDefaultMutationApplyGateBlockers(
    evidence: AppTlsDefaultMutationApplyGateEvidence
): Array<String> {
    var blockers = ArrayList<String>()
    if (evidence.applyId.size == 0) {
        blockers.add("APPLY_ID_NOT_CARRIED")
    }
    if (!evidence.dryRunGate.dryRunAccepted) {
        blockers.add("APP_TLS_DEFAULT_MUTATION_DRY_RUN_NOT_ACCEPTED")
        for (blocker in evidence.dryRunGate.blockers) {
            blockers.add("DRY_RUN_BLOCKER:${blocker}")
        }
    }
    if (!evidence.nativeSocketTlsListenSupportProof) {
        blockers.add("NATIVE_SOCKET_TLS_LISTEN_SUPPORT_PROOF_NOT_CARRIED")
    }
    if (!evidence.acceptedTransportLiveIngressProof) {
        blockers.add("ACCEPTED_TRANSPORT_LIVE_INGRESS_PROOF_NOT_CARRIED")
    }
    if (!evidence.appPolicyMutationPlanProof) {
        blockers.add("APP_POLICY_MUTATION_PLAN_PROOF_NOT_CARRIED")
    }
    if (!evidence.rollbackVerificationProof) {
        blockers.add("ROLLBACK_VERIFICATION_PROOF_NOT_CARRIED")
    }
    if (!evidence.focusedRegressionProof) {
        blockers.add("FOCUSED_REGRESSION_PROOF_NOT_CARRIED")
    }
    if (evidence.actualAppTlsDefaultMutationRequested) {
        blockers.add("ACTUAL_APP_TLS_DEFAULT_MUTATION_REQUESTED")
    }
    if (evidence.nativeTlsLiveIngressImplementationRequested) {
        blockers.add("NATIVE_TLS_LIVE_INGRESS_IMPLEMENTATION_REQUESTED")
    }
    if (evidence.sourceZeroStdxClaimed) {
        blockers.add("SOURCE_ZERO_STDX_CLAIMED")
    }
    if (evidence.stdxRemovalRequested) {
        blockers.add("STDX_REMOVAL_REQUESTED")
    }
    if (evidence.fullH1NativeDefaultReplacementClaimed) {
        blockers.add("FULL_H1_NATIVE_DEFAULT_REPLACEMENT_CLAIMED")
    }
    if (evidence.h2RuntimeClosureClaimed) {
        blockers.add("H2_RUNTIME_CLOSURE_CLAIMED")
    }
    if (evidence.publicReleaseOrHostedPublicationClaimed) {
        blockers.add("PUBLIC_RELEASE_OR_HOSTED_PUBLICATION_CLAIMED")
    }
    blockers.toArray()
}

func appTlsDefaultMutationApplyGateNonClaims(): Array<String> {
    [
        "NO_ACTUAL_APP_TLS_DEFAULT_MUTATION",
        "NO_NATIVE_TLS_LIVE_INGRESS_IMPLEMENTATION",
        "NO_IGNITE0700_PUBLIC_BASELINE_MUTATION",
        "NO_SOURCE_ZERO_STDX_CLAIM",
        "NO_STDX_REMOVAL",
        "NO_FULL_H1_NATIVE_DEFAULT_REPLACEMENT_CLAIM",
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_PUBLIC_RELEASE_OR_HOSTED_PUBLICATION_CLAIM",
    ]
}

func appTlsLiveIngressConsumptionRequiredProofs(): Array<String> {
    [
        "CONSUMPTION_ID",
        "APP_TLS_DEFAULT_MUTATION_APPLY_GATE_ACCEPTED",
        "NATIVE_TLS_LIVE_INGRESS_FIRST_CUT_RECEIPT_PROOF",
        "ACCEPTED_TRANSPORT_H2_HEADERS_PLUS_DATA_PROOF",
        "STALE_NATIVE_INGRESS_BLOCKER_REBASED_PROOF",
        "APP_DEFAULT_MUTATION_POLICY_SEPARATE_PROOF",
        "ROLLBACK_VERIFICATION_PROOF",
        "FOCUSED_REGRESSION_PROOF",
    ]
}

func appTlsLiveIngressConsumptionBlockers(
    evidence: AppTlsLiveIngressConsumptionEvidence
): Array<String> {
    var blockers = ArrayList<String>()
    if (evidence.consumptionId.size == 0) {
        blockers.add("CONSUMPTION_ID_NOT_CARRIED")
    }
    if (!evidence.applyGate.applyGateAccepted) {
        blockers.add("APP_TLS_DEFAULT_MUTATION_APPLY_GATE_NOT_ACCEPTED")
        for (blocker in evidence.applyGate.blockers) {
            blockers.add("APPLY_GATE_BLOCKER:${blocker}")
        }
    }
    if (!evidence.nativeTlsLiveIngressFirstCutReceiptProof) {
        blockers.add("NATIVE_TLS_LIVE_INGRESS_FIRST_CUT_RECEIPT_PROOF_NOT_CARRIED")
    }
    if (!evidence.acceptedTransportH2HeadersPlusDataProof) {
        blockers.add("ACCEPTED_TRANSPORT_H2_HEADERS_PLUS_DATA_PROOF_NOT_CARRIED")
    }
    if (!evidence.staleNativeIngressBlockerRebasedProof) {
        blockers.add("STALE_NATIVE_INGRESS_BLOCKER_REBASED_PROOF_NOT_CARRIED")
    }
    if (!evidence.appDefaultMutationPolicySeparateProof) {
        blockers.add("APP_DEFAULT_MUTATION_POLICY_SEPARATE_PROOF_NOT_CARRIED")
    }
    if (!evidence.rollbackVerificationProof) {
        blockers.add("ROLLBACK_VERIFICATION_PROOF_NOT_CARRIED")
    }
    if (!evidence.focusedRegressionProof) {
        blockers.add("FOCUSED_REGRESSION_PROOF_NOT_CARRIED")
    }
    if (evidence.actualAppTlsDefaultMutationRequested) {
        blockers.add("ACTUAL_APP_TLS_DEFAULT_MUTATION_REQUESTED")
    }
    if (evidence.sourceZeroStdxClaimed) {
        blockers.add("SOURCE_ZERO_STDX_CLAIMED")
    }
    if (evidence.stdxRemovalRequested) {
        blockers.add("STDX_REMOVAL_REQUESTED")
    }
    if (evidence.fullH1NativeDefaultReplacementClaimed) {
        blockers.add("FULL_H1_NATIVE_DEFAULT_REPLACEMENT_CLAIMED")
    }
    if (evidence.h2RuntimeClosureClaimed) {
        blockers.add("H2_RUNTIME_CLOSURE_CLAIMED")
    }
    if (evidence.publicReleaseOrHostedPublicationClaimed) {
        blockers.add("PUBLIC_RELEASE_OR_HOSTED_PUBLICATION_CLAIMED")
    }
    blockers.toArray()
}

func appTlsLiveIngressConsumptionNonClaims(): Array<String> {
    [
        "NO_ACTUAL_APP_TLS_DEFAULT_MUTATION",
        "NO_IGNITE0700_PUBLIC_BASELINE_MUTATION",
        "NO_SOURCE_ZERO_STDX_CLAIM",
        "NO_STDX_REMOVAL",
        "NO_FULL_H1_NATIVE_DEFAULT_REPLACEMENT_CLAIM",
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_BROWSER_GRADE_TLS_H2_COMPATIBILITY_CLAIM",
        "NO_PUBLIC_RELEASE_OR_HOSTED_PUBLICATION_CLAIM",
    ]
}

func appTlsDefaultSelectionMutationRequiredProofs(): Array<String> {
    [
        "MUTATION_ID",
        "APP_TLS_LIVE_INGRESS_CONSUMPTION_ACCEPTED",
        "TLS_CONFIG_DEFAULT_NATIVE_SELECTION_PROOF",
        "EXPLICIT_STDX_ROLLBACK_SELECTION_PROOF",
        "STARTUP_OBSERVATION_PROOF",
        "FOCUSED_REGRESSION_PROOF",
        "PUBLIC_BASELINE_NON_MUTATION_PROOF",
    ]
}

func appTlsDefaultSelectionMutationBlockers(
    evidence: AppTlsDefaultSelectionMutationEvidence
): Array<String> {
    var blockers = ArrayList<String>()
    if (evidence.mutationId.size == 0) {
        blockers.add("MUTATION_ID_NOT_CARRIED")
    }
    if (!evidence.consumptionGate.consumptionGateAccepted) {
        blockers.add("APP_TLS_LIVE_INGRESS_CONSUMPTION_NOT_ACCEPTED")
        for (blocker in evidence.consumptionGate.blockers) {
            blockers.add("CONSUMPTION_GATE_BLOCKER:${blocker}")
        }
    }
    if (!evidence.tlsConfigDefaultNativeSelectionProof) {
        blockers.add("TLS_CONFIG_DEFAULT_NATIVE_SELECTION_PROOF_NOT_CARRIED")
    }
    if (!evidence.explicitStdxRollbackSelectionProof) {
        blockers.add("EXPLICIT_STDX_ROLLBACK_SELECTION_PROOF_NOT_CARRIED")
    }
    if (!evidence.startupObservationProof) {
        blockers.add("STARTUP_OBSERVATION_PROOF_NOT_CARRIED")
    }
    if (!evidence.focusedRegressionProof) {
        blockers.add("FOCUSED_REGRESSION_PROOF_NOT_CARRIED")
    }
    if (!evidence.publicBaselineNonMutationProof) {
        blockers.add("PUBLIC_BASELINE_NON_MUTATION_PROOF_NOT_CARRIED")
    }
    if (evidence.sourceZeroStdxClaimed) {
        blockers.add("SOURCE_ZERO_STDX_CLAIMED")
    }
    if (evidence.stdxRemovalRequested) {
        blockers.add("STDX_REMOVAL_REQUESTED")
    }
    if (evidence.fullH1NativeDefaultReplacementClaimed) {
        blockers.add("FULL_H1_NATIVE_DEFAULT_REPLACEMENT_CLAIMED")
    }
    if (evidence.h2RuntimeClosureClaimed) {
        blockers.add("H2_RUNTIME_CLOSURE_CLAIMED")
    }
    if (evidence.browserGradeTlsH2CompatibilityClaimed) {
        blockers.add("BROWSER_GRADE_TLS_H2_COMPATIBILITY_CLAIMED")
    }
    if (evidence.publicReleaseOrHostedPublicationClaimed) {
        blockers.add("PUBLIC_RELEASE_OR_HOSTED_PUBLICATION_CLAIMED")
    }
    blockers.toArray()
}

func appTlsDefaultSelectionMutationNonClaims(): Array<String> {
    [
        "NO_IGNITE0700_PUBLIC_BASELINE_MUTATION",
        "NO_SOURCE_ZERO_STDX_CLAIM",
        "NO_STDX_REMOVAL",
        "NO_FULL_H1_NATIVE_DEFAULT_REPLACEMENT_CLOSEOUT_CLAIM",
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_BROWSER_GRADE_TLS_H2_COMPATIBILITY_CLAIM",
        "NO_PUBLIC_RELEASE_OR_HOSTED_PUBLICATION_CLAIM",
    ]
}

func socketServerEngineShellProductionCandidateGaps(
    missingProofs: Array<String>,
    blockers: Array<String>
): Array<String> {
    var gaps = ArrayList<String>()
    for (missing in missingProofs) {
        gaps.add(missing)
    }
    for (blocker in blockers) {
        if (blocker == "TLS_PROVIDER_SEAM_REQUIRED") {
            gaps.add("TLS_PROVIDER_SEAM_REQUIRED")
        }
    }
    gaps.toArray()
}

func socketServerEngineShellProductionCandidateGapsWithTlsProviderReadiness(
    missingProofs: Array<String>,
    blockers: Array<String>
): Array<String> {
    var gaps = ArrayList<String>()
    for (missing in missingProofs) {
        gaps.add(missing)
    }
    for (blocker in blockers) {
        if (blocker == "TLS_PROVIDER_SEAM_REQUIRED") {
            gaps.add("TLS_PROVIDER_SEAM_REQUIRED")
        } else if (serverEngineTextStartsWith(blocker, "TLS_PROVIDER_GATE:")) {
            gaps.add(blocker)
        }
    }
    gaps.toArray()
}

public class StdxServerEngine <: ServerEngine {
    var _server: ?Server = None

    public init() {}

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
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
            let ingressContext = option.loadTlsIngressContext()
            let preparedMaterial = ingressContext.loadPreparedTlsMaterial()
            let tlsCfg = api2.buildStdxTlsServerConfigFromPreparedMaterial(
                preparedMaterial
            )
            let _ = builder.tlsConfig(tlsCfg)
        }

        let server = builder
            .afterBind({ =>
                if (let Some(cb) <- onReady) {
                    cb(ServerEngineReadySignal())
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

func buildServerTransportRoutingBundle(
    addr: String,
    port: UInt16,
    tlsEnabled: Bool,
    preferredBackendHint!: String = "",
    allowExperimental!: Bool = false
): ServerTransportRoutingBundle {
    let normalizedHost = normalizeServerTouchpointHost(addr, port)
    let scheme = if (tlsEnabled) { "https" } else { "http" }
    let request = api2.BackendSelectionRequest(
        "server",
        scheme,
        false,
        false,
        false,
        preferredBackendHint,
        allowExperimental,
        0,
        "sni=" + normalizedHost
    )
    let decision = api2.selectBackend(request)
    let tlsPlan = api2.buildTlsAttachPlan(
        request,
        decision,
        normalizedHost
    )
    ServerTransportRoutingBundle(
        request,
        decision,
        tlsPlan
    )
}

func buildServerTransportTouchpoint(
    bundle: ServerTransportRoutingBundle
): ServerTransportTouchpoint {
    let decision = bundle.selectionDecision
    let tlsPlan = bundle.tlsAttachPlan
    ServerTransportTouchpoint(
        joinServerTouchpointFields(decision.candidateOrder),
        joinServerTouchpointFields(decision.blockedCandidates),
        normalizeServerBackendId(decision.selectedBackend),
        decision.selectedReason,
        normalizeServerProviderId(tlsPlan.providerId, tlsPlan.tlsEnabled),
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
    baseTouchpoint: ServerTransportTouchpoint
): ServerTransportTouchpoint {
    let tlsEnabled = baseTouchpoint.tlsEnabled
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

func containsServerAlpnProtocol(values: Array<String>, target: String): Bool {
    let normalizedTarget = target.trimAscii().toAsciiLower()
    for (value in values) {
        if (value.trimAscii().toAsciiLower() == normalizedTarget) {
            return true
        }
    }
    false
}

func serverEngineUInt8ToByteArray(input: Array<UInt8>): Array<Byte> {
    let out = Array<Byte>(input.size, repeat: 0)
    var i: Int64 = 0
    while (i < input.size) {
        out[i] = input[i]
        i += 1
    }
    out
}

func cloneServerEngineUInt8Array(input: Array<UInt8>): Array<UInt8> {
    let out = Array<UInt8>(input.size, repeat: 0)
    var i: Int64 = 0
    while (i < input.size) {
        out[i] = input[i]
        i += 1
    }
    out
}

func cloneServerEngineByteWindow(
    input: Array<Byte>,
    start: Int64,
    size: Int64
): Array<Byte> {
    let out = Array<Byte>(size, repeat: 0)
    var i: Int64 = 0
    while (i < size) {
        out[i] = input[start + i]
        i += 1
    }
    out
}

func cloneServerEngineHeaders(headers: HttpHeaders): HttpHeaders {
    let out = HttpHeaders()
    for ((name, values) in headers) {
        for (value in values) {
            out.add(name, value)
        }
    }
    out
}

func buildServerAcceptedTransportDescriptorFromSocket(
    socket: TcpSocket,
    transportId: String
): ContractAcceptedTransportDescriptor {
    ContractAcceptedTransportDescriptor(
        transportId,
        localEndpoint: socket.localAddress.toString(),
        remoteEndpoint: socket.remoteAddress.toString()
    )
}

func cloneServerEngineByteListWindow(
    input: ArrayList<Byte>,
    start: Int64,
    size: Int64
): Array<Byte> {
    let out = Array<Byte>(size, repeat: 0)
    var i: Int64 = 0
    while (i < size) {
        out[i] = input[start + i]
        i += 1
    }
    out
}

func serverEngineByteToUInt8Array(input: Array<Byte>): Array<UInt8> {
    let out = Array<UInt8>(input.size, repeat: 0)
    var i: Int64 = 0
    while (i < input.size) {
        out[i] = UInt8(input[i])
        i += 1
    }
    out
}

func serverEngineByteRecordChunksToUInt8(
    records: Array<Array<Byte>>
): Array<Array<UInt8>> {
    let out = ArrayList<Array<UInt8>>()
    for (record in records) {
        out.add(serverEngineByteToUInt8Array(record))
    }
    out.toArray()
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
