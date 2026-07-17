package ignite.tests

import std.unittest.*
import std.unittest.testmacro.*
import ignite.*
import std.collection.ArrayList
import std.env.{removeVariable, setVariable}
import std.fs.{File, exists}
import std.io.InputStream
import std.net.{IPSocketAddress, TcpServerSocket, TcpSocket}
import stdx.net.http.{HttpContext, HttpHeaders, WebSocket}
import stdx.encoding.json.stream.JsonWriter as StdxJsonWriter
import jinguissl.contract.ContractErrorCode
import jinguissl.live.{
    ContractAcceptedTransportDescriptor,
    ContractHttpClientTlsTrustRequest,
    ContractHttpServerAcceptedTransportSession,
    ContractTls13HttpClientHelloX25519,
    ContractTlsRecordChannel,
    ContractTlsRecordContentType,
    ContractTlsHttpNegotiationPolicy,
    contractTls13CreateClientRecordChannel,
    contractTls13BuildHttpClientHelloX25519,
    contractTls13CollectIncrementalHandshakeRecords,
    contractTryTls13OpenHttpClientRuntimeFromWireDerivedServerFlight
}

class NativeTlsLiveIngressClientChannelProbe {
    public var channel: ?ContractTlsRecordChannel = None
}

class NativeTlsLiveIngressRouteProbe {
    public var invoked: Bool = false
}

class NativeTlsLiveIngressSequentialRouteProbe {
    public var firstInvoked: Bool = false
    public var secondInvoked: Bool = false
    public var firstDynHeader: String = ""
    public var secondDynHeader: String = ""
}

class SpyServerEngine <: ServerEngine {
    var listenCalled: Bool = false
    var shutdownCalled: Bool = false
    var readyCalled: Bool = false
    var receivedApp: Bool = false
    var lastAddr: String = ""
    var lastPort: UInt16 = 0
    var lastEnableTlsPrecheck: Bool = true
    var lastTransportTouchpoint: ?ServerTransportTouchpoint = None

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        listenCalled = true
        lastAddr = option.addr
        lastPort = option.port
        lastEnableTlsPrecheck = option.enableTlsPrecheck
        lastTransportTouchpoint = option.transportTouchpoint
        let _ = app
        receivedApp = true
        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
            readyCalled = true
        }
    }

    public override func shutdown(): Unit {
        shutdownCalled = true
    }
}

class JinguiAcceptedTransportSessionProbeEngine <: ServerEngine {
    public var builtRequestAttachSurface: String = ""
    public var readySnapshot: ?ServerJinguiAcceptedTransportSessionSnapshot = None
    public var closedSnapshot: ?ServerJinguiAcceptedTransportSessionSnapshot = None

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let transport = ContractAcceptedTransportDescriptor(
            "test-accepted-transport",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55443"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 48))
        )
        let request = option.buildJinguiAcceptedTransportTls13X25519Request(
            transport,
            clientHello.encodedClientHello,
            engineIncrementalBytes(32, start: 80)
        )
        builtRequestAttachSurface = request.plan.attachSurface

        let session = option.attachJinguiAcceptedTransportTls13X25519Request(
            request
        )
        readySnapshot = Some(
            option.notifyJinguiAcceptedTransportSession(session)
        )

        let closed = option.closeJinguiAcceptedTransportSession(
            session,
            reason: "test-close"
        )
        closedSnapshot = Some(
            option.notifyJinguiAcceptedTransportSession(closed)
        )

        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSessionCodecProbeEngine <: ServerEngine {
    public var clientDecodedText: String = ""
    public var serverDecodedText: String = ""
    public var clientReassembledText: String = ""
    public var serverReassembledText: String = ""
    public var clientFragmentCount: Int64 = 0
    public var serverFragmentCount: Int64 = 0

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let transport = ContractAcceptedTransportDescriptor(
            "codec-accepted-transport",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55444"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 96))
        )
        let session = option.attachJinguiAcceptedTransportTls13X25519(
            transport,
            clientHello.encodedClientHello,
            engineIncrementalBytes(32, start: 128)
        )
        let clientChannel = contractTls13CreateClientRecordChannel(
            session.keyMaterial,
            algorithm: session.recordChannel.algorithm
        )

        let serverWire = option.sealJinguiAcceptedTransportApplicationData(
            session,
            "server-h2-frame".toArray()
        )
        clientDecodedText = String.fromUtf8(
            clientChannel.openApplicationData(serverWire)
        )

        let clientWire = clientChannel.sealApplicationData(
            "client-h2-frame".toArray()
        )
        serverDecodedText = String.fromUtf8(
            option.openJinguiAcceptedTransportApplicationData(session, clientWire)
        )

        let serverFragments =
            option.sealJinguiAcceptedTransportApplicationDataFragments(
                session,
                "server-fragment-payload-abcdefgh".toArray(),
                maxFragmentLen: 7
            )
        serverFragmentCount = serverFragments.size
        clientReassembledText = String.fromUtf8(
            clientChannel.openAndReassemble(serverFragments)
        )

        let clientFragments = clientChannel.sealFragments(
            ContractTlsRecordContentType.ApplicationData,
            "client-fragment-payload-xyz012345".toArray(),
            maxFragmentLen: 6
        )
        clientFragmentCount = clientFragments.size
        serverReassembledText = String.fromUtf8(
            option.openAndReassembleJinguiAcceptedTransportApplicationData(
                session,
                clientFragments
            )
        )

        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataH2HeaderBlockIngressProbeEngine <: ServerEngine {
    public var completedHeaderBlockCount: Int64 = 0
    public var completedHeaderBlockStreamId: Int64 = 0
    public var completedHeaderBlockEndStream: Bool = false
    public var completedHeaderBlockText: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let transport = ContractAcceptedTransportDescriptor(
            "appdata-h2-ingress-accepted-transport",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55445"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 96))
        )
        let session = option.attachJinguiAcceptedTransportTls13X25519(
            transport,
            clientHello.encodedClientHello,
            engineIncrementalBytes(32, start: 128)
        )
        let clientChannel = contractTls13CreateClientRecordChannel(
            session.keyMaterial,
            algorithm: session.recordChannel.algorithm
        )
        let plaintextWire = concatServerEngineAbstractionTestByteArrays([
            buildServerEngineAbstractionTestH2FrameWire(
                buildServerEngineAbstractionTestH2HeadersPayload(
                    serverEngineAbstractionTestByteArray("abc".toArray())
                ),
                frameType: UInt8(0x1),
                flags: UInt8(0x1),
                streamId: 31
            ),
            buildServerEngineAbstractionTestH2FrameWire(
                serverEngineAbstractionTestByteArray("def".toArray()),
                frameType: UInt8(0x9),
                flags: UInt8(0x4),
                streamId: 31
            )
        ])
        let clientFragments = clientChannel.sealFragments(
            ContractTlsRecordContentType.ApplicationData,
            plaintextWire,
            maxFragmentLen: 7
        )
        let completed =
            option.openAndIngressJinguiAcceptedTransportApplicationDataH2HeaderBlocks(
                session,
                clientFragments
            )
        completedHeaderBlockCount = completed.size
        if (completed.size > 0) {
            completedHeaderBlockStreamId = completed[0].streamId
            completedHeaderBlockEndStream = completed[0].endStream
            completedHeaderBlockText =
                serverEngineAbstractionTestByteText(
                    completed[0].headerBlockFragment
                )
        }

        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataH2HeaderBlockIngressRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let transport = ContractAcceptedTransportDescriptor(
            "appdata-h2-ingress-reject-accepted-transport",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55446"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 96))
        )
        let session = option.attachJinguiAcceptedTransportTls13X25519(
            transport,
            clientHello.encodedClientHello,
            engineIncrementalBytes(32, start: 128)
        )
        let clientChannel = contractTls13CreateClientRecordChannel(
            session.keyMaterial,
            algorithm: session.recordChannel.algorithm
        )
        let plaintextWire = concatServerEngineAbstractionTestByteArrays([
            buildServerEngineAbstractionTestH2FrameWire(
                buildServerEngineAbstractionTestH2HeadersPayload(
                    serverEngineAbstractionTestByteArray("abc".toArray())
                ),
                frameType: UInt8(0x1),
                flags: UInt8(0x1),
                streamId: 37
            ),
            buildServerEngineAbstractionTestH2FrameWire(
                serverEngineAbstractionTestByteArray("body".toArray()),
                frameType: UInt8(0x0),
                flags: UInt8(0x0),
                streamId: 37
            )
        ])
        let clientFragments = clientChannel.sealFragments(
            ContractTlsRecordContentType.ApplicationData,
            plaintextWire,
            maxFragmentLen: 7
        )
        try {
            let _ =
                option.openAndIngressJinguiAcceptedTransportApplicationDataH2HeaderBlocks(
                    session,
                    clientFragments
                )
            @Fail("expected invalid H2 application-data ingress rejection")
        } catch (e: Exception) {
            observedError = e.message
        }

        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataH2HeaderBlockIngressAccumulatorProbeEngine <: ServerEngine {
    public var firstBufferedRecordWireByteCount: Int64 = 0
    public var firstCompletedHeaderBlockCount: Int64 = 0
    public var midBufferedRecordWireByteCount: Int64 = 0
    public var midHasOpenHeaderBlock: Bool = false
    public var midBufferedHeaderBlockByteCount: Int64 = 0
    public var midCompletedHeaderBlockCount: Int64 = 0
    public var completedHeaderBlockCount: Int64 = 0
    public var completedHeaderBlockStreamId: Int64 = 0
    public var completedHeaderBlockEndStream: Bool = false
    public var completedHeaderBlockText: String = ""
    public var finalBufferedRecordWireByteCount: Int64 = 0
    public var finalBufferedH2FrameWireByteCount: Int64 = 0
    public var finalHasOpenHeaderBlock: Bool = false

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let transport = ContractAcceptedTransportDescriptor(
            "appdata-h2-record-wire-ingress-accepted-transport",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55447"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 96))
        )
        let session = option.attachJinguiAcceptedTransportTls13X25519(
            transport,
            clientHello.encodedClientHello,
            engineIncrementalBytes(32, start: 128)
        )
        let clientChannel = contractTls13CreateClientRecordChannel(
            session.keyMaterial,
            algorithm: session.recordChannel.algorithm
        )
        let plaintextWire = concatServerEngineAbstractionTestByteArrays([
            buildServerEngineAbstractionTestH2FrameWire(
                buildServerEngineAbstractionTestH2HeadersPayload(
                    serverEngineAbstractionTestByteArray("abc".toArray())
                ),
                frameType: UInt8(0x1),
                flags: UInt8(0x1),
                streamId: 41
            ),
            buildServerEngineAbstractionTestH2FrameWire(
                serverEngineAbstractionTestByteArray("def".toArray()),
                frameType: UInt8(0x9),
                flags: UInt8(0x4),
                streamId: 41
            )
        ])
        let clientFragments = clientChannel.sealFragments(
            ContractTlsRecordContentType.ApplicationData,
            plaintextWire,
            maxFragmentLen: 7
        )
        let encodedWire =
            concatServerEngineAbstractionTestByteArrays(clientFragments)
        if (encodedWire.size <= 7) {
            throw Exception(
                "expected fragmented accepted-session TLS record wire larger than the staged split"
            )
        }
        let ingress =
            option.buildJinguiAcceptedTransportApplicationDataH2HeaderBlockIngressAccumulator(
                session
            )
        ingress.append(cloneServerEngineByteWindow(encodedWire, 0, 4))
        firstBufferedRecordWireByteCount =
            ingress.bufferedRecordWireByteCount()
        firstCompletedHeaderBlockCount =
            ingress.drainCompleteHeaderBlocks().size

        ingress.append(
            cloneServerEngineByteWindow(
                encodedWire,
                4,
                encodedWire.size - 7
            )
        )
        midBufferedRecordWireByteCount =
            ingress.bufferedRecordWireByteCount()
        midHasOpenHeaderBlock = ingress.hasOpenHeaderBlock()
        midBufferedHeaderBlockByteCount =
            ingress.bufferedHeaderBlockByteCount()
        midCompletedHeaderBlockCount =
            ingress.drainCompleteHeaderBlocks().size

        ingress.append(
            cloneServerEngineByteWindow(
                encodedWire,
                encodedWire.size - 3,
                3
            )
        )
        let completed = ingress.drainCompleteHeaderBlocks()
        completedHeaderBlockCount = completed.size
        if (completed.size > 0) {
            completedHeaderBlockStreamId = completed[0].streamId
            completedHeaderBlockEndStream = completed[0].endStream
            completedHeaderBlockText =
                serverEngineAbstractionTestByteText(
                    completed[0].headerBlockFragment
                )
        }
        finalBufferedRecordWireByteCount =
            ingress.bufferedRecordWireByteCount()
        finalBufferedH2FrameWireByteCount =
            ingress.bufferedH2FrameWireByteCount()
        finalHasOpenHeaderBlock = ingress.hasOpenHeaderBlock()

        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataH2HeaderBlockIngressAccumulatorRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let transport = ContractAcceptedTransportDescriptor(
            "appdata-h2-record-wire-ingress-reject-accepted-transport",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55448"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 96))
        )
        let session = option.attachJinguiAcceptedTransportTls13X25519(
            transport,
            clientHello.encodedClientHello,
            engineIncrementalBytes(32, start: 128)
        )
        let clientChannel = contractTls13CreateClientRecordChannel(
            session.keyMaterial,
            algorithm: session.recordChannel.algorithm
        )
        let plaintextWire = concatServerEngineAbstractionTestByteArrays([
            buildServerEngineAbstractionTestH2FrameWire(
                buildServerEngineAbstractionTestH2HeadersPayload(
                    serverEngineAbstractionTestByteArray("abc".toArray())
                ),
                frameType: UInt8(0x1),
                flags: UInt8(0x1),
                streamId: 43
            ),
            buildServerEngineAbstractionTestH2FrameWire(
                serverEngineAbstractionTestByteArray("body".toArray()),
                frameType: UInt8(0x0),
                flags: UInt8(0x0),
                streamId: 43
            )
        ])
        let clientFragments = clientChannel.sealFragments(
            ContractTlsRecordContentType.ApplicationData,
            plaintextWire,
            maxFragmentLen: 7
        )
        let encodedWire =
            concatServerEngineAbstractionTestByteArrays(clientFragments)
        let ingress =
            option.buildJinguiAcceptedTransportApplicationDataH2HeaderBlockIngressAccumulator(
                session
            )
        try {
            ingress.append(encodedWire)
            @Fail(
                "expected accepted-session fragmented record-wire H2 ingress rejection"
            )
        } catch (e: Exception) {
            observedError = e.message
        }

        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataLogicalRequestAccumulatorProbeEngine <: ServerEngine {
    public var firstCompletedLogicalRequestCount: Int64 = 0
    public var midCompletedLogicalRequestCount: Int64 = 0
    public var midHasOpenHeaderBlock: Bool = false
    public var midBufferedHeaderBlockByteCount: Int64 = 0
    public var completedLogicalRequestCount: Int64 = 0
    public var requestMethod: String = ""
    public var requestPath: String = ""
    public var requestUrl: String = ""
    public var requestQuery: String = ""
    public var requestVersion: String = ""
    public var requestHost: String = ""
    public var requestMode: String = ""
    public var requestBody: String = ""
    public var finalBufferedRecordWireByteCount: Int64 = 0
    public var finalBufferedH2FrameWireByteCount: Int64 = 0
    public var finalHasOpenHeaderBlock: Bool = false

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let transport = ContractAcceptedTransportDescriptor(
            "appdata-logical-request-accumulator-accepted-transport",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55449"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 96))
        )
        let session = option.attachJinguiAcceptedTransportTls13X25519(
            transport,
            clientHello.encodedClientHello,
            engineIncrementalBytes(32, start: 128)
        )
        let clientChannel = contractTls13CreateClientRecordChannel(
            session.keyMaterial,
            algorithm: session.recordChannel.algorithm
        )
        let headerBlockFragment = concatServerEngineAbstractionTestByteArrays([
            serverEngineAbstractionTestByteArray([UInt8(0x82)]),
            serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x10)]),
            serverEngineAbstractionTestByteArray("/appdata?turn=ok".toArray()),
            serverEngineAbstractionTestByteArray([UInt8(0x01), UInt8(0x14)]),
            serverEngineAbstractionTestByteArray(
                "api.example.com:9443".toArray()
            ),
            serverEngineAbstractionTestByteArray([UInt8(0x10), UInt8(0x06)]),
            serverEngineAbstractionTestByteArray("x-mode".toArray()),
            serverEngineAbstractionTestByteArray([UInt8(0x06)]),
            serverEngineAbstractionTestByteArray("bridge".toArray())
        ])
        let splitAt: Int64 = 8
        let plaintextWire = concatServerEngineAbstractionTestByteArrays([
            buildServerEngineAbstractionTestH2FrameWire(
                buildServerEngineAbstractionTestH2HeadersPayload(
                    cloneServerEngineByteWindow(
                        headerBlockFragment,
                        0,
                        splitAt
                    )
                ),
                frameType: UInt8(0x1),
                flags: UInt8(0x1),
                streamId: 47
            ),
            buildServerEngineAbstractionTestH2FrameWire(
                cloneServerEngineByteWindow(
                    headerBlockFragment,
                    splitAt,
                    headerBlockFragment.size - splitAt
                ),
                frameType: UInt8(0x9),
                flags: UInt8(0x4),
                streamId: 47
            )
        ])
        let clientFragments = clientChannel.sealFragments(
            ContractTlsRecordContentType.ApplicationData,
            plaintextWire,
            maxFragmentLen: 7
        )
        let encodedWire =
            concatServerEngineAbstractionTestByteArrays(clientFragments)
        let ingress =
            option.buildJinguiAcceptedTransportApplicationDataH2HeaderBlockLogicalRequestAccumulator(
                session,
                bodyBytes: "payload".toArray()
            )
        ingress.append(cloneServerEngineByteWindow(encodedWire, 0, 4))
        firstCompletedLogicalRequestCount =
            ingress.drainCompleteLogicalRequests().size

        ingress.append(
            cloneServerEngineByteWindow(
                encodedWire,
                4,
                encodedWire.size - 7
            )
        )
        midCompletedLogicalRequestCount =
            ingress.drainCompleteLogicalRequests().size
        midHasOpenHeaderBlock = ingress.hasOpenHeaderBlock()
        midBufferedHeaderBlockByteCount =
            ingress.bufferedHeaderBlockByteCount()

        ingress.append(
            cloneServerEngineByteWindow(
                encodedWire,
                encodedWire.size - 3,
                3
            )
        )
        let completed = ingress.drainCompleteLogicalRequests()
        completedLogicalRequestCount = completed.size
        if (completed.size > 0) {
            let request = completed[0]
            requestMethod = request.method
            requestPath = request.path
            requestUrl = request.urlString
            requestQuery = request.queryString
            requestVersion = request.versionString
            requestHost = request.headers.getFirst("host") ?? ""
            requestMode = request.headers.getFirst("x-mode") ?? ""
            requestBody =
                serverEngineAbstractionTestByteText(
                    serverEngineAbstractionTestByteArray(request.bodyBytes)
                )
        }
        finalBufferedRecordWireByteCount =
            ingress.bufferedRecordWireByteCount()
        finalBufferedH2FrameWireByteCount =
            ingress.bufferedH2FrameWireByteCount()
        finalHasOpenHeaderBlock = ingress.hasOpenHeaderBlock()

        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataLogicalRequestAccumulatorRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let transport = ContractAcceptedTransportDescriptor(
            "appdata-logical-request-accumulator-reject-accepted-transport",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55450"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 96))
        )
        let session = option.attachJinguiAcceptedTransportTls13X25519(
            transport,
            clientHello.encodedClientHello,
            engineIncrementalBytes(32, start: 128)
        )
        let clientChannel = contractTls13CreateClientRecordChannel(
            session.keyMaterial,
            algorithm: session.recordChannel.algorithm
        )
        let firstHeaderBlock = concatServerEngineAbstractionTestByteArrays([
            serverEngineAbstractionTestByteArray([UInt8(0x82)]),
            serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
            serverEngineAbstractionTestByteArray("/one".toArray())
        ])
        let secondHeaderBlock = concatServerEngineAbstractionTestByteArrays([
            serverEngineAbstractionTestByteArray([UInt8(0x82)]),
            serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
            serverEngineAbstractionTestByteArray("/two".toArray())
        ])
        let plaintextWire = concatServerEngineAbstractionTestByteArrays([
            buildServerEngineAbstractionTestH2FrameWire(
                buildServerEngineAbstractionTestH2HeadersPayload(
                    firstHeaderBlock
                ),
                frameType: UInt8(0x1),
                flags: UInt8(0x5),
                streamId: 49
            ),
            buildServerEngineAbstractionTestH2FrameWire(
                buildServerEngineAbstractionTestH2HeadersPayload(
                    secondHeaderBlock
                ),
                frameType: UInt8(0x1),
                flags: UInt8(0x5),
                streamId: 51
            )
        ])
        let clientFragments = clientChannel.sealFragments(
            ContractTlsRecordContentType.ApplicationData,
            plaintextWire,
            maxFragmentLen: 7
        )
        let encodedWire =
            concatServerEngineAbstractionTestByteArrays(clientFragments)
        let ingress =
            option.buildJinguiAcceptedTransportApplicationDataH2HeaderBlockLogicalRequestAccumulator(
                session
            )
        try {
            ingress.append(encodedWire)
            @Fail(
                "expected fragmented-record-wire logical-request multi-header-block rejection"
            )
        } catch (e: Exception) {
            observedError = e.message
        }

        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataHeadersPlusDataLogicalRequestAccumulatorProbeEngine <: ServerEngine {
    public var firstCompletedLogicalRequestCount: Int64 = 0
    public var midCompletedLogicalRequestCount: Int64 = 0
    public var midHasOpenHeaderBlock: Bool = false
    public var midBufferedHeaderBlockByteCount: Int64 = 0
    public var midBufferedBodyByteCount: Int64 = 0
    public var completedLogicalRequestCount: Int64 = 0
    public var requestMethod: String = ""
    public var requestPath: String = ""
    public var requestUrl: String = ""
    public var requestQuery: String = ""
    public var requestVersion: String = ""
    public var requestHost: String = ""
    public var requestMode: String = ""
    public var requestBody: String = ""
    public var requestPeerWindowUpdateFrameCount: Int64 = 0
    public var requestPeerWindowUpdateStreamId: Int64 = 0
    public var requestPeerWindowUpdateIncrement: Int64 = 0
    public var finalBufferedRecordWireByteCount: Int64 = 0
    public var finalBufferedH2FrameWireByteCount: Int64 = 0
    public var finalHasOpenHeaderBlock: Bool = false
    public var finalBufferedBodyByteCount: Int64 = 0

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let transport = ContractAcceptedTransportDescriptor(
            "appdata-headers-plus-data-logical-request-accumulator-accepted-transport",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55451"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 96))
        )
        let session = option.attachJinguiAcceptedTransportTls13X25519(
            transport,
            clientHello.encodedClientHello,
            engineIncrementalBytes(32, start: 128)
        )
        let clientChannel = contractTls13CreateClientRecordChannel(
            session.keyMaterial,
            algorithm: session.recordChannel.algorithm
        )
        let headerBlockFragment = concatServerEngineAbstractionTestByteArrays([
            serverEngineAbstractionTestByteArray([UInt8(0x83)]),
            serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x15)]),
            serverEngineAbstractionTestByteArray("/appdata-data?turn=ok".toArray()),
            serverEngineAbstractionTestByteArray([UInt8(0x01), UInt8(0x14)]),
            serverEngineAbstractionTestByteArray(
                "api.example.com:9443".toArray()
            ),
            serverEngineAbstractionTestByteArray([UInt8(0x10), UInt8(0x06)]),
            serverEngineAbstractionTestByteArray("x-mode".toArray()),
            serverEngineAbstractionTestByteArray([UInt8(0x0b)]),
            serverEngineAbstractionTestByteArray("bridge-data".toArray())
        ])
        let plaintextWire = concatServerEngineAbstractionTestByteArrays([
            buildServerEngineAbstractionTestH2FrameWire(
                buildServerEngineAbstractionTestH2HeadersPayload(
                    headerBlockFragment
                ),
                frameType: UInt8(0x1),
                flags: UInt8(0x4),
                streamId: 53
            ),
            buildServerEngineAbstractionTestH2FrameWire(
                serverEngineAbstractionTestByteArray(
                    "accepted-".toArray()
                ),
                frameType: UInt8(0x0),
                flags: UInt8(0x0),
                streamId: 53
            ),
            encodeJinguiAcceptedTransportH2FrameWireSnapshot(
                buildServerEngineAbstractionTestH2WindowUpdateFrame(
                    53,
                    64
                )
            ),
            buildServerEngineAbstractionTestH2FrameWire(
                serverEngineAbstractionTestByteArray(
                    "appdata-body".toArray()
                ),
                frameType: UInt8(0x0),
                flags: UInt8(0x1),
                streamId: 53
            )
        ])
        let clientFragments = clientChannel.sealFragments(
            ContractTlsRecordContentType.ApplicationData,
            plaintextWire,
            maxFragmentLen: 7
        )
        let encodedWire =
            concatServerEngineAbstractionTestByteArrays(clientFragments)
        let ingress =
            option.buildJinguiAcceptedTransportApplicationDataH2HeadersPlusDataLogicalRequestAccumulator(
                session
            )
        ingress.append(cloneServerEngineByteWindow(encodedWire, 0, 4))
        firstCompletedLogicalRequestCount =
            ingress.drainCompleteLogicalRequests().size

        ingress.append(
            cloneServerEngineByteWindow(
                encodedWire,
                4,
                encodedWire.size - 7
            )
        )
        midCompletedLogicalRequestCount =
            ingress.drainCompleteLogicalRequests().size
        midHasOpenHeaderBlock = ingress.hasOpenHeaderBlock()
        midBufferedHeaderBlockByteCount =
            ingress.bufferedHeaderBlockByteCount()
        midBufferedBodyByteCount =
            ingress.bufferedBodyByteCount()

        ingress.append(
            cloneServerEngineByteWindow(
                encodedWire,
                encodedWire.size - 3,
                3
            )
        )
        let completed = ingress.drainCompleteLogicalRequests()
        completedLogicalRequestCount = completed.size
        if (completed.size > 0) {
            let request = completed[0]
            requestMethod = request.method
            requestPath = request.path
            requestUrl = request.urlString
            requestQuery = request.queryString
            requestVersion = request.versionString
            requestHost = request.headers.getFirst("host") ?? ""
            requestMode = request.headers.getFirst("x-mode") ?? ""
            requestBody =
                serverEngineAbstractionTestByteText(
                    serverEngineAbstractionTestByteArray(request.bodyBytes)
                )
            requestPeerWindowUpdateFrameCount =
                request.peerWindowUpdateFrames.size
            if (request.peerWindowUpdateFrames.size > 0) {
                let windowUpdate =
                    parseJinguiAcceptedTransportH2WindowUpdateFrame(
                        request.peerWindowUpdateFrames[0]
                    )
                requestPeerWindowUpdateStreamId = windowUpdate.streamId
                requestPeerWindowUpdateIncrement = windowUpdate.increment
            }
        }
        finalBufferedRecordWireByteCount =
            ingress.bufferedRecordWireByteCount()
        finalBufferedH2FrameWireByteCount =
            ingress.bufferedH2FrameWireByteCount()
        finalHasOpenHeaderBlock = ingress.hasOpenHeaderBlock()
        finalBufferedBodyByteCount =
            ingress.bufferedBodyByteCount()

        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataHeadersPlusDataLogicalRequestAccumulatorRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let transport = ContractAcceptedTransportDescriptor(
            "appdata-headers-plus-data-logical-request-accumulator-reject-accepted-transport",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55452"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 96))
        )
        let session = option.attachJinguiAcceptedTransportTls13X25519(
            transport,
            clientHello.encodedClientHello,
            engineIncrementalBytes(32, start: 128)
        )
        let clientChannel = contractTls13CreateClientRecordChannel(
            session.keyMaterial,
            algorithm: session.recordChannel.algorithm
        )
        let headerBlockFragment = concatServerEngineAbstractionTestByteArrays([
            serverEngineAbstractionTestByteArray([UInt8(0x83)]),
            serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
            serverEngineAbstractionTestByteArray("/one".toArray())
        ])
        let plaintextWire = concatServerEngineAbstractionTestByteArrays([
            buildServerEngineAbstractionTestH2FrameWire(
                buildServerEngineAbstractionTestH2HeadersPayload(
                    headerBlockFragment
                ),
                frameType: UInt8(0x1),
                flags: UInt8(0x4),
                streamId: 55
            ),
            buildServerEngineAbstractionTestH2FrameWire(
                serverEngineAbstractionTestByteArray(
                    "blocked".toArray()
                ),
                frameType: UInt8(0x0),
                flags: UInt8(0x1),
                streamId: 57
            )
        ])
        let clientFragments = clientChannel.sealFragments(
            ContractTlsRecordContentType.ApplicationData,
            plaintextWire,
            maxFragmentLen: 7
        )
        let encodedWire =
            concatServerEngineAbstractionTestByteArrays(clientFragments)
        let ingress =
            option.buildJinguiAcceptedTransportApplicationDataH2HeadersPlusDataLogicalRequestAccumulator(
                session
            )
        try {
            ingress.append(encodedWire)
            @Fail(
                "expected fragmented-record-wire headers-plus-data logical-request wrong-stream DATA rejection"
            )
        } catch (e: Exception) {
            observedError = e.message
        }

        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataFragmentedRecordWireProvidedBodyRequestTurnProbeEngine <: ServerEngine {
    public var bodyStringReadyStatus: String = ""
    public var bodyJsonReadyStatus: String = ""
    public var bodyStringResponseStatus: UInt16 = 0
    public var bodyJsonResponseStatus: UInt16 = 0
    public var bodyStringContentType: String = ""
    public var bodyJsonContentType: String = ""
    public var bodyStringTransferEncoding: String = ""
    public var bodyJsonTransferEncoding: String = ""
    public var bodyStringSocketWriteCount: Int64 = 0
    public var bodyJsonSocketWriteCount: Int64 = 0
    var bodyStringClientChannel: ?ContractTlsRecordChannel = None
    var bodyJsonClientChannel: ?ContractTlsRecordChannel = None

    public func openBodyStringSocketWire(wire: Array<UInt8>): String {
        match (bodyStringClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected fragmented appdata bodyString companion client record channel before socket wire open"
                )
        }
    }

    public func openBodyJsonSocketWire(wire: Array<UInt8>): String {
        match (bodyJsonClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected fragmented appdata bodyJson companion client record channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let bodyStringAccepted = listener.accept()
            try {
                let bodyStringHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1152)
                    )
                )
                let bodyStringHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x27)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-fragmented-appdata-body-string".toArray()
                    )
                ])
                let bodyStringTransport = ContractAcceptedTransportDescriptor(
                    "fragmented-appdata-body-string-transport",
                    localEndpoint: bodyStringAccepted.localAddress.toString(),
                    remoteEndpoint: bodyStringAccepted.remoteAddress.toString()
                )
                let bodyStringSession = option.attachJinguiAcceptedTransportTls13X25519(
                    bodyStringTransport,
                    bodyStringHello.encodedClientHello,
                    engineIncrementalBytes(32, start: 1184)
                )
                let bodyStringRequestClientChannel =
                    contractTls13CreateClientRecordChannel(
                        bodyStringSession.keyMaterial,
                        algorithm: bodyStringSession.recordChannel.algorithm
                    )
                let bodyStringRequestRecords =
                    bodyStringRequestClientChannel.sealFragments(
                        ContractTlsRecordContentType.ApplicationData,
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                bodyStringHeaderBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x5),
                            streamId: 65
                        ),
                        maxFragmentLen: 7
                    )
                let bodyStringEncodedWire =
                    concatServerEngineAbstractionTestByteArrays(
                        bodyStringRequestRecords
                    )
                let bodyStringTurn =
                    option.serveJinguiAcceptedTransportSessionApplicationDataFragmentedRecordWireH2ProvidedBodyRequestTurn(
                        bodyStringSession,
                        bodyStringAccepted,
                        app,
                        [
                            cloneServerEngineByteWindow(
                                bodyStringEncodedWire,
                                0,
                                4
                            ),
                            cloneServerEngineByteWindow(
                                bodyStringEncodedWire,
                                4,
                                bodyStringEncodedWire.size - 7
                            ),
                            cloneServerEngineByteWindow(
                                bodyStringEncodedWire,
                                bodyStringEncodedWire.size - 3,
                                3
                            )
                        ],
                        bodyBytes: "accepted-appdata-body".toArray(),
                        maxFragmentLen: 8
                    )
                bodyStringClientChannel = Some(bodyStringRequestClientChannel)
                bodyStringReadyStatus = bodyStringTurn.readySnapshot.status
                bodyStringResponseStatus = bodyStringTurn.responseStatus
                bodyStringContentType =
                    bodyStringTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyStringTransferEncoding =
                    bodyStringTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyStringSocketWriteCount = bodyStringTurn.socketWriteCount
            } finally {
                if (!bodyStringAccepted.isClosed()) {
                    bodyStringAccepted.close()
                }
            }

            let bodyJsonAccepted = listener.accept()
            try {
                let bodyJsonHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1216)
                    )
                )
                let bodyJsonHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x25)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-fragmented-appdata-body-json".toArray()
                    )
                ])
                let bodyJsonTransport = ContractAcceptedTransportDescriptor(
                    "fragmented-appdata-body-json-transport",
                    localEndpoint: bodyJsonAccepted.localAddress.toString(),
                    remoteEndpoint: bodyJsonAccepted.remoteAddress.toString()
                )
                let bodyJsonSession = option.attachJinguiAcceptedTransportTls13X25519(
                    bodyJsonTransport,
                    bodyJsonHello.encodedClientHello,
                    engineIncrementalBytes(32, start: 1248)
                )
                let bodyJsonRequestClientChannel =
                    contractTls13CreateClientRecordChannel(
                        bodyJsonSession.keyMaterial,
                        algorithm: bodyJsonSession.recordChannel.algorithm
                    )
                let bodyJsonRequestRecords =
                    bodyJsonRequestClientChannel.sealFragments(
                        ContractTlsRecordContentType.ApplicationData,
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                bodyJsonHeaderBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x5),
                            streamId: 67
                        ),
                        maxFragmentLen: 7
                    )
                let bodyJsonEncodedWire =
                    concatServerEngineAbstractionTestByteArrays(
                        bodyJsonRequestRecords
                    )
                let bodyJsonTurn =
                    option.serveJinguiAcceptedTransportSessionApplicationDataFragmentedRecordWireH2ProvidedBodyRequestTurn(
                        bodyJsonSession,
                        bodyJsonAccepted,
                        app,
                        [
                            cloneServerEngineByteWindow(
                                bodyJsonEncodedWire,
                                0,
                                4
                            ),
                            cloneServerEngineByteWindow(
                                bodyJsonEncodedWire,
                                4,
                                bodyJsonEncodedWire.size - 7
                            ),
                            cloneServerEngineByteWindow(
                                bodyJsonEncodedWire,
                                bodyJsonEncodedWire.size - 3,
                                3
                            )
                        ],
                        bodyBytes: "{\"name\":\"ignite\",\"val\":23}".toArray(),
                        maxFragmentLen: 8
                    )
                bodyJsonClientChannel = Some(bodyJsonRequestClientChannel)
                bodyJsonReadyStatus = bodyJsonTurn.readySnapshot.status
                bodyJsonResponseStatus = bodyJsonTurn.responseStatus
                bodyJsonContentType =
                    bodyJsonTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyJsonTransferEncoding =
                    bodyJsonTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyJsonSocketWriteCount = bodyJsonTurn.socketWriteCount
            } finally {
                if (!bodyJsonAccepted.isClosed()) {
                    bodyJsonAccepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataFragmentedRecordWireProvidedBodyRequestTurnRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let clientHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1280)
                    )
                )
                let firstHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/one".toArray())
                ])
                let secondHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/two".toArray())
                ])
                let transport = ContractAcceptedTransportDescriptor(
                    "fragmented-appdata-provided-body-reject-transport",
                    localEndpoint: accepted.localAddress.toString(),
                    remoteEndpoint: accepted.remoteAddress.toString()
                )
                let session = option.attachJinguiAcceptedTransportTls13X25519(
                    transport,
                    clientHello.encodedClientHello,
                    engineIncrementalBytes(32, start: 1312)
                )
                let requestClientChannel = contractTls13CreateClientRecordChannel(
                    session.keyMaterial,
                    algorithm: session.recordChannel.algorithm
                )
                let requestRecords = requestClientChannel.sealFragments(
                    ContractTlsRecordContentType.ApplicationData,
                    concatServerEngineAbstractionTestByteArrays([
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                firstHeaderBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x5),
                            streamId: 69
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                secondHeaderBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x5),
                            streamId: 71
                        )
                    ]),
                    maxFragmentLen: 7
                )
                let encodedWire =
                    concatServerEngineAbstractionTestByteArrays(requestRecords)
                try {
                    let _ =
                        option.serveJinguiAcceptedTransportSessionApplicationDataFragmentedRecordWireH2ProvidedBodyRequestTurn(
                            session,
                            accepted,
                            app,
                            [
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    0,
                                    4
                                ),
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    4,
                                    encodedWire.size - 7
                                ),
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    encodedWire.size - 3,
                                    3
                                )
                            ],
                            bodyBytes: "blocked".toArray(),
                            maxFragmentLen: 8
                        )
                    @Fail(
                        "expected fragmented-record-wire provided-body turn rejection"
                    )
                } catch (e: Exception) {
                    observedError = e.message
                }
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataLogicalRequestProjectionProbeEngine <: ServerEngine {
    public var requestMethod: String = ""
    public var requestPath: String = ""
    public var requestUrl: String = ""
    public var requestQuery: String = ""
    public var requestVersion: String = ""
    public var requestHost: String = ""
    public var requestMode: String = ""
    public var requestBody: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let transport = ContractAcceptedTransportDescriptor(
            "appdata-logical-request-accepted-transport",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55447"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 96))
        )
        let session = option.attachJinguiAcceptedTransportTls13X25519(
            transport,
            clientHello.encodedClientHello,
            engineIncrementalBytes(32, start: 128)
        )
        let clientChannel = contractTls13CreateClientRecordChannel(
            session.keyMaterial,
            algorithm: session.recordChannel.algorithm
        )
        let headerBlockFragment = concatServerEngineAbstractionTestByteArrays([
            serverEngineAbstractionTestByteArray([UInt8(0x82)]),
            serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x10)]),
            serverEngineAbstractionTestByteArray("/appdata?turn=ok".toArray()),
            serverEngineAbstractionTestByteArray([UInt8(0x01), UInt8(0x14)]),
            serverEngineAbstractionTestByteArray(
                "api.example.com:9443".toArray()
            ),
            serverEngineAbstractionTestByteArray([UInt8(0x10), UInt8(0x06)]),
            serverEngineAbstractionTestByteArray("x-mode".toArray()),
            serverEngineAbstractionTestByteArray([UInt8(0x06)]),
            serverEngineAbstractionTestByteArray("bridge".toArray())
        ])
        let plaintextWire = buildServerEngineAbstractionTestH2FrameWire(
            buildServerEngineAbstractionTestH2HeadersPayload(
                headerBlockFragment
            ),
            frameType: UInt8(0x1),
            flags: UInt8(0x5),
            streamId: 41
        )
        let clientFragments = clientChannel.sealFragments(
            ContractTlsRecordContentType.ApplicationData,
            plaintextWire,
            maxFragmentLen: 7
        )
        let request =
            option.openAndBuildJinguiAcceptedTransportLogicalRequestFromApplicationDataH2HeaderBlock(
                session,
                clientFragments,
                bodyBytes: "payload".toArray()
            )
        requestMethod = request.method
        requestPath = request.path
        requestUrl = request.urlString
        requestQuery = request.queryString
        requestVersion = request.versionString
        requestHost = request.headers.getFirst("host") ?? ""
        requestMode = request.headers.getFirst("x-mode") ?? ""
        requestBody =
            serverEngineAbstractionTestByteText(
                serverEngineAbstractionTestByteArray(request.bodyBytes)
            )

        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataLogicalRequestProjectionRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let transport = ContractAcceptedTransportDescriptor(
            "appdata-logical-request-reject-accepted-transport",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55448"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 96))
        )
        let session = option.attachJinguiAcceptedTransportTls13X25519(
            transport,
            clientHello.encodedClientHello,
            engineIncrementalBytes(32, start: 128)
        )
        let clientChannel = contractTls13CreateClientRecordChannel(
            session.keyMaterial,
            algorithm: session.recordChannel.algorithm
        )
        let firstHeaderBlock = concatServerEngineAbstractionTestByteArrays([
            serverEngineAbstractionTestByteArray([UInt8(0x82)]),
            serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
            serverEngineAbstractionTestByteArray("/one".toArray())
        ])
        let secondHeaderBlock = concatServerEngineAbstractionTestByteArrays([
            serverEngineAbstractionTestByteArray([UInt8(0x82)]),
            serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
            serverEngineAbstractionTestByteArray("/two".toArray())
        ])
        let plaintextWire = concatServerEngineAbstractionTestByteArrays([
            buildServerEngineAbstractionTestH2FrameWire(
                buildServerEngineAbstractionTestH2HeadersPayload(
                    firstHeaderBlock
                ),
                frameType: UInt8(0x1),
                flags: UInt8(0x5),
                streamId: 43
            ),
            buildServerEngineAbstractionTestH2FrameWire(
                buildServerEngineAbstractionTestH2HeadersPayload(
                    secondHeaderBlock
                ),
                frameType: UInt8(0x1),
                flags: UInt8(0x5),
                streamId: 45
            )
        ])
        let clientFragments = clientChannel.sealFragments(
            ContractTlsRecordContentType.ApplicationData,
            plaintextWire,
            maxFragmentLen: 7
        )
        try {
            let _ =
                option.openAndBuildJinguiAcceptedTransportLogicalRequestFromApplicationDataH2HeaderBlock(
                    session,
                    clientFragments
                )
            @Fail("expected multi-header-block logical-request rejection")
        } catch (e: Exception) {
            observedError = e.message
        }

        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataBodylessRequestTurnProbeEngine <: ServerEngine {
    public var readyStatus: String = ""
    public var responseStatus: UInt16 = 0
    public var contentType: String = ""
    public var transferEncoding: String = ""
    public var socketWriteCount: Int64 = 0
    var clientChannel: ?ContractTlsRecordChannel = None

    public func openResponseSocketWire(wire: Array<UInt8>): String {
        match (clientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected bodyless turn companion client record channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let clientHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 832)
                    )
                )
                let headerBlockFragment = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x82)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x27)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-turn?turn=from-appdata".toArray()
                    ),
                    serverEngineAbstractionTestByteArray([UInt8(0x10), UInt8(0x06)]),
                    serverEngineAbstractionTestByteArray("x-mode".toArray()),
                    serverEngineAbstractionTestByteArray([UInt8(0x06)]),
                    serverEngineAbstractionTestByteArray("bridge".toArray())
                ])
                let serverPrivate = engineIncrementalBytes(32, start: 864)
                let transport = ContractAcceptedTransportDescriptor(
                    "bodyless-turn-transport",
                    localEndpoint: accepted.localAddress.toString(),
                    remoteEndpoint: accepted.remoteAddress.toString()
                )
                let session = option.attachJinguiAcceptedTransportTls13X25519(
                    transport,
                    clientHello.encodedClientHello,
                    serverPrivate
                )
                let requestClientChannel = contractTls13CreateClientRecordChannel(
                    session.keyMaterial,
                    algorithm: session.recordChannel.algorithm
                )
                let requestFragments = requestClientChannel.sealFragments(
                    ContractTlsRecordContentType.ApplicationData,
                    buildServerEngineAbstractionTestH2FrameWire(
                        buildServerEngineAbstractionTestH2HeadersPayload(
                            headerBlockFragment
                        ),
                        frameType: UInt8(0x1),
                        flags: UInt8(0x5),
                        streamId: 51
                    ),
                    maxFragmentLen: 7
                )
                let turn =
                    option.serveJinguiAcceptedTransportSessionApplicationDataH2BodylessRequestTurn(
                        session,
                        accepted,
                        app,
                        requestFragments,
                        maxFragmentLen: 8
                    )
                clientChannel = Some(requestClientChannel)
                readyStatus = turn.readySnapshot.status
                responseStatus = turn.responseStatus
                contentType =
                    turn.responseHeaders.getFirst("content-type") ?? ""
                transferEncoding =
                    turn.responseHeaders.getFirst("transfer-encoding") ?? ""
                socketWriteCount = turn.socketWriteCount
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataBodylessRequestTurnRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let clientHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 896)
                    )
                )
                let firstHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x82)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/one".toArray())
                ])
                let secondHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x82)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/two".toArray())
                ])
                let serverPrivate = engineIncrementalBytes(32, start: 928)
                let transport = ContractAcceptedTransportDescriptor(
                    "bodyless-turn-reject-transport",
                    localEndpoint: accepted.localAddress.toString(),
                    remoteEndpoint: accepted.remoteAddress.toString()
                )
                let session = option.attachJinguiAcceptedTransportTls13X25519(
                    transport,
                    clientHello.encodedClientHello,
                    serverPrivate
                )
                let requestClientChannel = contractTls13CreateClientRecordChannel(
                    session.keyMaterial,
                    algorithm: session.recordChannel.algorithm
                )
                let requestFragments = requestClientChannel.sealFragments(
                    ContractTlsRecordContentType.ApplicationData,
                    concatServerEngineAbstractionTestByteArrays([
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                firstHeaderBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x5),
                            streamId: 53
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                secondHeaderBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x5),
                            streamId: 55
                        )
                    ]),
                    maxFragmentLen: 7
                )
                try {
                    let _ =
                        option.serveJinguiAcceptedTransportSessionApplicationDataH2BodylessRequestTurn(
                            session,
                            accepted,
                            app,
                            requestFragments,
                            maxFragmentLen: 8
                        )
                    @Fail("expected multi-header-block bodyless turn rejection")
                } catch (e: Exception) {
                    observedError = e.message
                }
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketApplicationDataBodylessRequestTurnProbeEngine <: ServerEngine {
    public var readyStatus: String = ""
    public var responseStatus: UInt16 = 0
    public var contentType: String = ""
    public var transferEncoding: String = ""
    public var socketWriteCount: Int64 = 0
    var clientChannel: ?ContractTlsRecordChannel = None

    public func openResponseSocketWire(wire: Array<UInt8>): String {
        match (clientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected socket bodyless turn companion client record channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let clientHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 2944)
                    )
                )
                let headerBlockFragment = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x82)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x27)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-turn?turn=from-appdata".toArray()
                    ),
                    serverEngineAbstractionTestByteArray([UInt8(0x10), UInt8(0x06)]),
                    serverEngineAbstractionTestByteArray("x-mode".toArray()),
                    serverEngineAbstractionTestByteArray([UInt8(0x06)]),
                    serverEngineAbstractionTestByteArray("bridge".toArray())
                ])
                let serverPrivate = engineIncrementalBytes(32, start: 2976)
                let turn =
                    option.serveJinguiAcceptedTransportSocketApplicationDataH2BodylessRequestTurn(
                        accepted,
                        app,
                        { session =>
                            let requestClientChannel =
                                contractTls13CreateClientRecordChannel(
                                    session.keyMaterial,
                                    algorithm: session.recordChannel.algorithm
                                )
                            clientChannel = Some(requestClientChannel)
                            requestClientChannel.sealFragments(
                                ContractTlsRecordContentType.ApplicationData,
                                buildServerEngineAbstractionTestH2FrameWire(
                                    buildServerEngineAbstractionTestH2HeadersPayload(
                                        headerBlockFragment
                                    ),
                                    frameType: UInt8(0x1),
                                    flags: UInt8(0x5),
                                    streamId: 139
                                ),
                                maxFragmentLen: 7
                            )
                        },
                        clientHello.encodedClientHello,
                        serverPrivate,
                        transportId: "socket-bodyless-turn-transport",
                        maxFragmentLen: 8
                    )
                readyStatus = turn.readySnapshot.status
                responseStatus = turn.responseStatus
                contentType =
                    turn.responseHeaders.getFirst("content-type") ?? ""
                transferEncoding =
                    turn.responseHeaders.getFirst("transfer-encoding") ?? ""
                socketWriteCount = turn.socketWriteCount
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketApplicationDataBodylessRequestTurnRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let clientHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 3008)
                    )
                )
                let firstHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x82)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/one".toArray())
                ])
                let secondHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x82)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/two".toArray())
                ])
                let serverPrivate = engineIncrementalBytes(32, start: 3040)
                try {
                    let _ =
                        option.serveJinguiAcceptedTransportSocketApplicationDataH2BodylessRequestTurn(
                            accepted,
                            app,
                            { session =>
                                let requestClientChannel =
                                    contractTls13CreateClientRecordChannel(
                                        session.keyMaterial,
                                        algorithm: session.recordChannel.algorithm
                                    )
                                requestClientChannel.sealFragments(
                                    ContractTlsRecordContentType.ApplicationData,
                                    concatServerEngineAbstractionTestByteArrays([
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            buildServerEngineAbstractionTestH2HeadersPayload(
                                                firstHeaderBlock
                                            ),
                                            frameType: UInt8(0x1),
                                            flags: UInt8(0x5),
                                            streamId: 141
                                        ),
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            buildServerEngineAbstractionTestH2HeadersPayload(
                                                secondHeaderBlock
                                            ),
                                            frameType: UInt8(0x1),
                                            flags: UInt8(0x5),
                                            streamId: 143
                                        )
                                    ]),
                                    maxFragmentLen: 7
                                )
                            },
                            clientHello.encodedClientHello,
                            serverPrivate,
                            transportId: "socket-bodyless-turn-reject-transport",
                            maxFragmentLen: 8
                        )
                    @Fail("expected socket multi-header-block bodyless turn rejection")
                } catch (e: Exception) {
                    observedError = e.message
                }
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataBodylessRequestTurnProbeEngine <: ServerEngine {
    public var readyStatus: String = ""
    public var responseStatus: UInt16 = 0
    public var contentType: String = ""
    public var transferEncoding: String = ""
    public var socketWriteCount: Int64 = 0
    public var negotiatedAlpn: String = ""
    public var requestedServerName: String = ""
    public var attachSurface: String = ""
    public var transportId: String = ""
    var clientChannel: ?ContractTlsRecordChannel = None

    public func openResponseSocketWire(wire: Array<UInt8>): String {
        match (clientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected captured bodyless turn companion client record channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let clientHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 2688)
                    )
                )
                let headerBlockFragment = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x82)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x32)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-captured-bodyless-turn?turn=from-captured".toArray()
                    ),
                    serverEngineAbstractionTestByteArray([UInt8(0x10), UInt8(0x06)]),
                    serverEngineAbstractionTestByteArray("x-mode".toArray()),
                    serverEngineAbstractionTestByteArray([UInt8(0x06)]),
                    serverEngineAbstractionTestByteArray("bridge".toArray())
                ])
                let serverPrivate = engineIncrementalBytes(32, start: 2720)
                let turn =
                    option.serveJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataH2BodylessRequestTurn(
                        accepted,
                        app,
                        { session =>
                            let requestClientChannel =
                                contractTls13CreateClientRecordChannel(
                                    session.keyMaterial,
                                    algorithm: session.recordChannel.algorithm
                                )
                            clientChannel = Some(requestClientChannel)
                            requestClientChannel.sealFragments(
                                ContractTlsRecordContentType.ApplicationData,
                                buildServerEngineAbstractionTestH2FrameWire(
                                    buildServerEngineAbstractionTestH2HeadersPayload(
                                        headerBlockFragment
                                    ),
                                    frameType: UInt8(0x1),
                                    flags: UInt8(0x5),
                                    streamId: 57
                                ),
                                maxFragmentLen: 7
                            )
                        },
                        serverPrivate,
                        transportId: "captured-clienthello-bodyless-turn-transport",
                        readChunkSize: 5,
                        maxFragmentLen: 8
                    )
                readyStatus = turn.readySnapshot.status
                responseStatus = turn.responseStatus
                contentType =
                    turn.responseHeaders.getFirst("content-type") ?? ""
                transferEncoding =
                    turn.responseHeaders.getFirst("transfer-encoding") ?? ""
                socketWriteCount = turn.socketWriteCount
                negotiatedAlpn =
                    turn.readySnapshot.jinguiAttachResultSnapshot.negotiatedAlpn
                requestedServerName =
                    turn.readySnapshot.jinguiAttachResultSnapshot.requestedServerName
                attachSurface =
                    turn.readySnapshot.jinguiAttachResultSnapshot.attachSurface
                transportId = turn.readySnapshot.transport.transportId
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataBodylessRequestTurnRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                try {
                    let _ =
                        option.serveJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataH2BodylessRequestTurn(
                            accepted,
                            app,
                            { session =>
                                let _ = session
                                []
                            },
                            engineIncrementalBytes(32, start: 2752),
                            transportId: "captured-clienthello-bodyless-turn-reject-transport",
                            readChunkSize: 5,
                            maxFragmentLen: 8
                        )
                } catch (e: Exception) {
                    observedError = e.message
                }
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataProvidedBodyRequestTurnProbeEngine <: ServerEngine {
    public var bodyStringReadyStatus: String = ""
    public var bodyJsonReadyStatus: String = ""
    public var bodyStringResponseStatus: UInt16 = 0
    public var bodyJsonResponseStatus: UInt16 = 0
    public var bodyStringContentType: String = ""
    public var bodyJsonContentType: String = ""
    public var bodyStringTransferEncoding: String = ""
    public var bodyJsonTransferEncoding: String = ""
    public var bodyStringSocketWriteCount: Int64 = 0
    public var bodyJsonSocketWriteCount: Int64 = 0
    public var bodyStringNegotiatedAlpn: String = ""
    public var bodyJsonNegotiatedAlpn: String = ""
    public var bodyStringRequestedServerName: String = ""
    public var bodyJsonRequestedServerName: String = ""
    public var bodyStringAttachSurface: String = ""
    public var bodyJsonAttachSurface: String = ""
    public var bodyStringTransportId: String = ""
    public var bodyJsonTransportId: String = ""
    var bodyStringClientChannel: ?ContractTlsRecordChannel = None
    var bodyJsonClientChannel: ?ContractTlsRecordChannel = None

    public func openBodyStringSocketWire(wire: Array<UInt8>): String {
        match (bodyStringClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected captured provided-body bodyString client channel before socket wire open"
                )
        }
    }

    public func openBodyJsonSocketWire(wire: Array<UInt8>): String {
        match (bodyJsonClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected captured provided-body bodyJson client channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let bodyStringAccepted = listener.accept()
            try {
                let bodyStringHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x25)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-captured-appdata-body-string".toArray()
                    )
                ])
                let bodyStringServerPrivate =
                    engineIncrementalBytes(32, start: 3104)
                let bodyStringTurn =
                    option.serveJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataH2ProvidedBodyRequestTurn(
                        bodyStringAccepted,
                        app,
                        { session =>
                            let requestClientChannel =
                                contractTls13CreateClientRecordChannel(
                                    session.keyMaterial,
                                    algorithm: session.recordChannel.algorithm
                                )
                            bodyStringClientChannel = Some(
                                requestClientChannel
                            )
                            requestClientChannel.sealFragments(
                                ContractTlsRecordContentType.ApplicationData,
                                buildServerEngineAbstractionTestH2FrameWire(
                                    buildServerEngineAbstractionTestH2HeadersPayload(
                                        bodyStringHeaderBlock
                                    ),
                                    frameType: UInt8(0x1),
                                    flags: UInt8(0x5),
                                    streamId: 145
                                ),
                                maxFragmentLen: 7
                            )
                        },
                        bodyStringServerPrivate,
                        bodyBytes: "accepted-appdata-body".toArray(),
                        transportId: "captured-clienthello-provided-body-string-transport",
                        readChunkSize: 5,
                        maxFragmentLen: 8
                    )
                bodyStringReadyStatus = bodyStringTurn.readySnapshot.status
                bodyStringResponseStatus = bodyStringTurn.responseStatus
                bodyStringContentType =
                    bodyStringTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyStringTransferEncoding =
                    bodyStringTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyStringSocketWriteCount = bodyStringTurn.socketWriteCount
                bodyStringNegotiatedAlpn =
                    bodyStringTurn.readySnapshot.jinguiAttachResultSnapshot.negotiatedAlpn
                bodyStringRequestedServerName =
                    bodyStringTurn.readySnapshot.jinguiAttachResultSnapshot.requestedServerName
                bodyStringAttachSurface =
                    bodyStringTurn.readySnapshot.jinguiAttachResultSnapshot.attachSurface
                bodyStringTransportId =
                    bodyStringTurn.readySnapshot.transport.transportId
            } finally {
                if (!bodyStringAccepted.isClosed()) {
                    bodyStringAccepted.close()
                }
            }

            let bodyJsonAccepted = listener.accept()
            try {
                let bodyJsonHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x23)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-captured-appdata-body-json".toArray()
                    )
                ])
                let bodyJsonServerPrivate =
                    engineIncrementalBytes(32, start: 3168)
                let bodyJsonTurn =
                    option.serveJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataH2ProvidedBodyRequestTurn(
                        bodyJsonAccepted,
                        app,
                        { session =>
                            let requestClientChannel =
                                contractTls13CreateClientRecordChannel(
                                    session.keyMaterial,
                                    algorithm: session.recordChannel.algorithm
                                )
                            bodyJsonClientChannel = Some(
                                requestClientChannel
                            )
                            requestClientChannel.sealFragments(
                                ContractTlsRecordContentType.ApplicationData,
                                buildServerEngineAbstractionTestH2FrameWire(
                                    buildServerEngineAbstractionTestH2HeadersPayload(
                                        bodyJsonHeaderBlock
                                    ),
                                    frameType: UInt8(0x1),
                                    flags: UInt8(0x5),
                                    streamId: 147
                                ),
                                maxFragmentLen: 7
                            )
                        },
                        bodyJsonServerPrivate,
                        bodyBytes: "{\"name\":\"ignite\",\"val\":23}".toArray(),
                        transportId: "captured-clienthello-provided-body-json-transport",
                        readChunkSize: 5,
                        maxFragmentLen: 8
                    )
                bodyJsonReadyStatus = bodyJsonTurn.readySnapshot.status
                bodyJsonResponseStatus = bodyJsonTurn.responseStatus
                bodyJsonContentType =
                    bodyJsonTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyJsonTransferEncoding =
                    bodyJsonTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyJsonSocketWriteCount = bodyJsonTurn.socketWriteCount
                bodyJsonNegotiatedAlpn =
                    bodyJsonTurn.readySnapshot.jinguiAttachResultSnapshot.negotiatedAlpn
                bodyJsonRequestedServerName =
                    bodyJsonTurn.readySnapshot.jinguiAttachResultSnapshot.requestedServerName
                bodyJsonAttachSurface =
                    bodyJsonTurn.readySnapshot.jinguiAttachResultSnapshot.attachSurface
                bodyJsonTransportId =
                    bodyJsonTurn.readySnapshot.transport.transportId
            } finally {
                if (!bodyJsonAccepted.isClosed()) {
                    bodyJsonAccepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataProvidedBodyRequestTurnRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let firstHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/one".toArray())
                ])
                let secondHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/two".toArray())
                ])
                let serverPrivate = engineIncrementalBytes(32, start: 3232)
                try {
                    let _ =
                        option.serveJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataH2ProvidedBodyRequestTurn(
                            accepted,
                            app,
                            { session =>
                                let requestClientChannel =
                                    contractTls13CreateClientRecordChannel(
                                        session.keyMaterial,
                                        algorithm: session.recordChannel.algorithm
                                    )
                                requestClientChannel.sealFragments(
                                    ContractTlsRecordContentType.ApplicationData,
                                    concatServerEngineAbstractionTestByteArrays([
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            buildServerEngineAbstractionTestH2HeadersPayload(
                                                firstHeaderBlock
                                            ),
                                            frameType: UInt8(0x1),
                                            flags: UInt8(0x5),
                                            streamId: 149
                                        ),
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            buildServerEngineAbstractionTestH2HeadersPayload(
                                                secondHeaderBlock
                                            ),
                                            frameType: UInt8(0x1),
                                            flags: UInt8(0x5),
                                            streamId: 151
                                        )
                                    ]),
                                    maxFragmentLen: 7
                                )
                            },
                            serverPrivate,
                            bodyBytes: "blocked".toArray(),
                            transportId: "captured-clienthello-provided-body-reject-transport",
                            readChunkSize: 5,
                            maxFragmentLen: 8
                        )
                    @Fail("expected captured multi-header-block provided-body turn rejection")
                } catch (e: Exception) {
                    observedError = e.message
                }
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataProvidedBodyRequestTurnProbeEngine <: ServerEngine {
    public var bodyStringReadyStatus: String = ""
    public var bodyJsonReadyStatus: String = ""
    public var bodyStringResponseStatus: UInt16 = 0
    public var bodyJsonResponseStatus: UInt16 = 0
    public var bodyStringContentType: String = ""
    public var bodyJsonContentType: String = ""
    public var bodyStringTransferEncoding: String = ""
    public var bodyJsonTransferEncoding: String = ""
    public var bodyStringSocketWriteCount: Int64 = 0
    public var bodyJsonSocketWriteCount: Int64 = 0
    var bodyStringClientChannel: ?ContractTlsRecordChannel = None
    var bodyJsonClientChannel: ?ContractTlsRecordChannel = None

    public func openBodyStringSocketWire(wire: Array<UInt8>): String {
        match (bodyStringClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected appdata bodyString companion client record channel before socket wire open"
                )
        }
    }

    public func openBodyJsonSocketWire(wire: Array<UInt8>): String {
        match (bodyJsonClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected appdata bodyJson companion client record channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let bodyStringAccepted = listener.accept()
            try {
                let bodyStringHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 960)
                    )
                )
                let bodyStringHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x1c)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-body-string".toArray()
                    )
                ])
                let bodyStringTransport = ContractAcceptedTransportDescriptor(
                    "appdata-body-string-transport",
                    localEndpoint: bodyStringAccepted.localAddress.toString(),
                    remoteEndpoint: bodyStringAccepted.remoteAddress.toString()
                )
                let bodyStringSession = option.attachJinguiAcceptedTransportTls13X25519(
                    bodyStringTransport,
                    bodyStringHello.encodedClientHello,
                    engineIncrementalBytes(32, start: 992)
                )
                let bodyStringRequestClientChannel =
                    contractTls13CreateClientRecordChannel(
                        bodyStringSession.keyMaterial,
                        algorithm: bodyStringSession.recordChannel.algorithm
                    )
                let bodyStringRequestFragments =
                    bodyStringRequestClientChannel.sealFragments(
                        ContractTlsRecordContentType.ApplicationData,
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                bodyStringHeaderBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x5),
                            streamId: 57
                        ),
                        maxFragmentLen: 7
                    )
                let bodyStringTurn =
                    option.serveJinguiAcceptedTransportSessionApplicationDataH2ProvidedBodyRequestTurn(
                        bodyStringSession,
                        bodyStringAccepted,
                        app,
                        bodyStringRequestFragments,
                        bodyBytes: "accepted-appdata-body".toArray(),
                        maxFragmentLen: 8
                    )
                bodyStringClientChannel = Some(bodyStringRequestClientChannel)
                bodyStringReadyStatus = bodyStringTurn.readySnapshot.status
                bodyStringResponseStatus = bodyStringTurn.responseStatus
                bodyStringContentType =
                    bodyStringTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyStringTransferEncoding =
                    bodyStringTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyStringSocketWriteCount = bodyStringTurn.socketWriteCount
            } finally {
                if (!bodyStringAccepted.isClosed()) {
                    bodyStringAccepted.close()
                }
            }

            let bodyJsonAccepted = listener.accept()
            try {
                let bodyJsonHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1024)
                    )
                )
                let bodyJsonHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x1a)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-body-json".toArray()
                    )
                ])
                let bodyJsonTransport = ContractAcceptedTransportDescriptor(
                    "appdata-body-json-transport",
                    localEndpoint: bodyJsonAccepted.localAddress.toString(),
                    remoteEndpoint: bodyJsonAccepted.remoteAddress.toString()
                )
                let bodyJsonSession = option.attachJinguiAcceptedTransportTls13X25519(
                    bodyJsonTransport,
                    bodyJsonHello.encodedClientHello,
                    engineIncrementalBytes(32, start: 1056)
                )
                let bodyJsonRequestClientChannel =
                    contractTls13CreateClientRecordChannel(
                        bodyJsonSession.keyMaterial,
                        algorithm: bodyJsonSession.recordChannel.algorithm
                    )
                let bodyJsonRequestFragments =
                    bodyJsonRequestClientChannel.sealFragments(
                        ContractTlsRecordContentType.ApplicationData,
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                bodyJsonHeaderBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x5),
                            streamId: 59
                        ),
                        maxFragmentLen: 7
                    )
                let bodyJsonTurn =
                    option.serveJinguiAcceptedTransportSessionApplicationDataH2ProvidedBodyRequestTurn(
                        bodyJsonSession,
                        bodyJsonAccepted,
                        app,
                        bodyJsonRequestFragments,
                        bodyBytes: "{\"name\":\"ignite\",\"val\":23}".toArray(),
                        maxFragmentLen: 8
                    )
                bodyJsonClientChannel = Some(bodyJsonRequestClientChannel)
                bodyJsonReadyStatus = bodyJsonTurn.readySnapshot.status
                bodyJsonResponseStatus = bodyJsonTurn.responseStatus
                bodyJsonContentType =
                    bodyJsonTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyJsonTransferEncoding =
                    bodyJsonTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyJsonSocketWriteCount = bodyJsonTurn.socketWriteCount
            } finally {
                if (!bodyJsonAccepted.isClosed()) {
                    bodyJsonAccepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataProvidedBodyRequestTurnRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let clientHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1088)
                    )
                )
                let firstHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/one".toArray())
                ])
                let secondHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/two".toArray())
                ])
                let transport = ContractAcceptedTransportDescriptor(
                    "appdata-provided-body-reject-transport",
                    localEndpoint: accepted.localAddress.toString(),
                    remoteEndpoint: accepted.remoteAddress.toString()
                )
                let session = option.attachJinguiAcceptedTransportTls13X25519(
                    transport,
                    clientHello.encodedClientHello,
                    engineIncrementalBytes(32, start: 1120)
                )
                let requestClientChannel = contractTls13CreateClientRecordChannel(
                    session.keyMaterial,
                    algorithm: session.recordChannel.algorithm
                )
                let requestFragments = requestClientChannel.sealFragments(
                    ContractTlsRecordContentType.ApplicationData,
                    concatServerEngineAbstractionTestByteArrays([
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                firstHeaderBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x5),
                            streamId: 61
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                secondHeaderBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x5),
                            streamId: 63
                        )
                    ]),
                    maxFragmentLen: 7
                )
                try {
                    let _ =
                        option.serveJinguiAcceptedTransportSessionApplicationDataH2ProvidedBodyRequestTurn(
                            session,
                            accepted,
                            app,
                            requestFragments,
                            bodyBytes: "blocked".toArray(),
                            maxFragmentLen: 8
                        )
                    @Fail("expected multi-header-block provided-body turn rejection")
                } catch (e: Exception) {
                    observedError = e.message
                }
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketApplicationDataProvidedBodyRequestTurnProbeEngine <: ServerEngine {
    public var bodyStringReadyStatus: String = ""
    public var bodyJsonReadyStatus: String = ""
    public var bodyStringResponseStatus: UInt16 = 0
    public var bodyJsonResponseStatus: UInt16 = 0
    public var bodyStringContentType: String = ""
    public var bodyJsonContentType: String = ""
    public var bodyStringTransferEncoding: String = ""
    public var bodyJsonTransferEncoding: String = ""
    public var bodyStringSocketWriteCount: Int64 = 0
    public var bodyJsonSocketWriteCount: Int64 = 0
    var bodyStringClientChannel: ?ContractTlsRecordChannel = None
    var bodyJsonClientChannel: ?ContractTlsRecordChannel = None

    public func openBodyStringSocketWire(wire: Array<UInt8>): String {
        match (bodyStringClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected socket appdata bodyString companion client record channel before socket wire open"
                )
        }
    }

    public func openBodyJsonSocketWire(wire: Array<UInt8>): String {
        match (bodyJsonClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected socket appdata bodyJson companion client record channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let bodyStringAccepted = listener.accept()
            try {
                let bodyStringTransportId =
                    "socket-appdata-body-string-transport"
                let bodyStringHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 2752)
                    )
                )
                let bodyStringHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x1c)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-body-string".toArray()
                    )
                ])
                let bodyStringServerPrivate =
                    engineIncrementalBytes(32, start: 2784)
                let bodyStringTurn =
                    option.serveJinguiAcceptedTransportSocketApplicationDataH2ProvidedBodyRequestTurn(
                        bodyStringAccepted,
                        app,
                        { session =>
                            let bodyStringRequestClientChannel =
                                contractTls13CreateClientRecordChannel(
                                    session.keyMaterial,
                                    algorithm: session.recordChannel.algorithm
                                )
                            bodyStringClientChannel = Some(
                                bodyStringRequestClientChannel
                            )
                            bodyStringRequestClientChannel.sealFragments(
                                ContractTlsRecordContentType.ApplicationData,
                                buildServerEngineAbstractionTestH2FrameWire(
                                    buildServerEngineAbstractionTestH2HeadersPayload(
                                        bodyStringHeaderBlock
                                    ),
                                    frameType: UInt8(0x1),
                                    flags: UInt8(0x5),
                                    streamId: 131
                                ),
                                maxFragmentLen: 7
                            )
                        },
                        bodyStringHello.encodedClientHello,
                        bodyStringServerPrivate,
                        bodyBytes: "accepted-appdata-body".toArray(),
                        transportId: bodyStringTransportId,
                        maxFragmentLen: 8
                    )
                bodyStringReadyStatus = bodyStringTurn.readySnapshot.status
                bodyStringResponseStatus = bodyStringTurn.responseStatus
                bodyStringContentType =
                    bodyStringTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyStringTransferEncoding =
                    bodyStringTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyStringSocketWriteCount = bodyStringTurn.socketWriteCount
            } finally {
                if (!bodyStringAccepted.isClosed()) {
                    bodyStringAccepted.close()
                }
            }

            let bodyJsonAccepted = listener.accept()
            try {
                let bodyJsonTransportId =
                    "socket-appdata-body-json-transport"
                let bodyJsonHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 2816)
                    )
                )
                let bodyJsonHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x1a)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-body-json".toArray()
                    )
                ])
                let bodyJsonServerPrivate =
                    engineIncrementalBytes(32, start: 2848)
                let bodyJsonTurn =
                    option.serveJinguiAcceptedTransportSocketApplicationDataH2ProvidedBodyRequestTurn(
                        bodyJsonAccepted,
                        app,
                        { session =>
                            let bodyJsonRequestClientChannel =
                                contractTls13CreateClientRecordChannel(
                                    session.keyMaterial,
                                    algorithm: session.recordChannel.algorithm
                                )
                            bodyJsonClientChannel = Some(
                                bodyJsonRequestClientChannel
                            )
                            bodyJsonRequestClientChannel.sealFragments(
                                ContractTlsRecordContentType.ApplicationData,
                                buildServerEngineAbstractionTestH2FrameWire(
                                    buildServerEngineAbstractionTestH2HeadersPayload(
                                        bodyJsonHeaderBlock
                                    ),
                                    frameType: UInt8(0x1),
                                    flags: UInt8(0x5),
                                    streamId: 133
                                ),
                                maxFragmentLen: 7
                            )
                        },
                        bodyJsonHello.encodedClientHello,
                        bodyJsonServerPrivate,
                        bodyBytes: "{\"name\":\"ignite\",\"val\":23}".toArray(),
                        transportId: bodyJsonTransportId,
                        maxFragmentLen: 8
                    )
                bodyJsonReadyStatus = bodyJsonTurn.readySnapshot.status
                bodyJsonResponseStatus = bodyJsonTurn.responseStatus
                bodyJsonContentType =
                    bodyJsonTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyJsonTransferEncoding =
                    bodyJsonTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyJsonSocketWriteCount = bodyJsonTurn.socketWriteCount
            } finally {
                if (!bodyJsonAccepted.isClosed()) {
                    bodyJsonAccepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketApplicationDataProvidedBodyRequestTurnRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let clientHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 2880)
                    )
                )
                let firstHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/one".toArray())
                ])
                let secondHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/two".toArray())
                ])
                let transportId =
                    "socket-appdata-provided-body-reject-transport"
                let serverPrivate = engineIncrementalBytes(32, start: 2912)
                try {
                    let _ =
                        option.serveJinguiAcceptedTransportSocketApplicationDataH2ProvidedBodyRequestTurn(
                            accepted,
                            app,
                            { session =>
                                let requestClientChannel =
                                    contractTls13CreateClientRecordChannel(
                                        session.keyMaterial,
                                        algorithm: session.recordChannel.algorithm
                                    )
                                requestClientChannel.sealFragments(
                                    ContractTlsRecordContentType.ApplicationData,
                                    concatServerEngineAbstractionTestByteArrays([
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            buildServerEngineAbstractionTestH2HeadersPayload(
                                                firstHeaderBlock
                                            ),
                                            frameType: UInt8(0x1),
                                            flags: UInt8(0x5),
                                            streamId: 135
                                        ),
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            buildServerEngineAbstractionTestH2HeadersPayload(
                                                secondHeaderBlock
                                            ),
                                            frameType: UInt8(0x1),
                                            flags: UInt8(0x5),
                                            streamId: 137
                                        )
                                    ]),
                                    maxFragmentLen: 7
                                )
                            },
                            clientHello.encodedClientHello,
                            serverPrivate,
                            bodyBytes: "blocked".toArray(),
                            transportId: transportId,
                            maxFragmentLen: 8
                        )
                    @Fail("expected socket multi-header-block provided-body turn rejection")
                } catch (e: Exception) {
                    observedError = e.message
                }
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketApplicationDataFragmentedRecordWireProvidedBodyRequestTurnProbeEngine <: ServerEngine {
    public var bodyStringReadyStatus: String = ""
    public var bodyJsonReadyStatus: String = ""
    public var bodyStringResponseStatus: UInt16 = 0
    public var bodyJsonResponseStatus: UInt16 = 0
    public var bodyStringContentType: String = ""
    public var bodyJsonContentType: String = ""
    public var bodyStringTransferEncoding: String = ""
    public var bodyJsonTransferEncoding: String = ""
    public var bodyStringSocketWriteCount: Int64 = 0
    public var bodyJsonSocketWriteCount: Int64 = 0
    var bodyStringClientChannel: ?ContractTlsRecordChannel = None
    var bodyJsonClientChannel: ?ContractTlsRecordChannel = None

    public func openBodyStringSocketWire(wire: Array<UInt8>): String {
        match (bodyStringClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected socket fragmented appdata bodyString companion client record channel before socket wire open"
                )
        }
    }

    public func openBodyJsonSocketWire(wire: Array<UInt8>): String {
        match (bodyJsonClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected socket fragmented appdata bodyJson companion client record channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let bodyStringAccepted = listener.accept()
            try {
                let bodyStringTransportId =
                    "socket-fragmented-appdata-body-string-transport"
                let bodyStringHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1408)
                    )
                )
                let bodyStringHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x2e)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-socket-fragmented-appdata-body-string".toArray()
                    )
                ])
                let bodyStringServerPrivate =
                    engineIncrementalBytes(32, start: 1440)
                let bodyStringTurn =
                    option.serveJinguiAcceptedTransportSocketApplicationDataFragmentedRecordWireH2ProvidedBodyRequestTurn(
                        bodyStringAccepted,
                        app,
                        { session =>
                            let bodyStringRequestClientChannel =
                                contractTls13CreateClientRecordChannel(
                                    session.keyMaterial,
                                    algorithm: session.recordChannel.algorithm
                                )
                            bodyStringClientChannel = Some(
                                bodyStringRequestClientChannel
                            )
                            let bodyStringRequestRecords =
                                bodyStringRequestClientChannel.sealFragments(
                                    ContractTlsRecordContentType.ApplicationData,
                                    buildServerEngineAbstractionTestH2FrameWire(
                                        buildServerEngineAbstractionTestH2HeadersPayload(
                                            bodyStringHeaderBlock
                                        ),
                                        frameType: UInt8(0x1),
                                        flags: UInt8(0x5),
                                        streamId: 73
                                    ),
                                    maxFragmentLen: 7
                                )
                            let bodyStringEncodedWire =
                                concatServerEngineAbstractionTestByteArrays(
                                    bodyStringRequestRecords
                                )
                            [
                                cloneServerEngineByteWindow(
                                    bodyStringEncodedWire,
                                    0,
                                    4
                                ),
                                cloneServerEngineByteWindow(
                                    bodyStringEncodedWire,
                                    4,
                                    bodyStringEncodedWire.size - 7
                                ),
                                cloneServerEngineByteWindow(
                                    bodyStringEncodedWire,
                                    bodyStringEncodedWire.size - 3,
                                    3
                                )
                            ]
                        },
                        bodyStringHello.encodedClientHello,
                        bodyStringServerPrivate,
                        bodyBytes: "accepted-fragmented-appdata-body".toArray(),
                        transportId: bodyStringTransportId,
                        maxFragmentLen: 8
                    )
                bodyStringReadyStatus = bodyStringTurn.readySnapshot.status
                bodyStringResponseStatus = bodyStringTurn.responseStatus
                bodyStringContentType =
                    bodyStringTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyStringTransferEncoding =
                    bodyStringTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyStringSocketWriteCount = bodyStringTurn.socketWriteCount
            } finally {
                if (!bodyStringAccepted.isClosed()) {
                    bodyStringAccepted.close()
                }
            }

            let bodyJsonAccepted = listener.accept()
            try {
                let bodyJsonTransportId =
                    "socket-fragmented-appdata-body-json-transport"
                let bodyJsonHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1472)
                    )
                )
                let bodyJsonHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x2c)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-socket-fragmented-appdata-body-json".toArray()
                    )
                ])
                let bodyJsonServerPrivate =
                    engineIncrementalBytes(32, start: 1504)
                let bodyJsonTurn =
                    option.serveJinguiAcceptedTransportSocketApplicationDataFragmentedRecordWireH2ProvidedBodyRequestTurn(
                        bodyJsonAccepted,
                        app,
                        { session =>
                            let bodyJsonRequestClientChannel =
                                contractTls13CreateClientRecordChannel(
                                    session.keyMaterial,
                                    algorithm: session.recordChannel.algorithm
                                )
                            bodyJsonClientChannel = Some(
                                bodyJsonRequestClientChannel
                            )
                            let bodyJsonRequestRecords =
                                bodyJsonRequestClientChannel.sealFragments(
                                    ContractTlsRecordContentType.ApplicationData,
                                    buildServerEngineAbstractionTestH2FrameWire(
                                        buildServerEngineAbstractionTestH2HeadersPayload(
                                            bodyJsonHeaderBlock
                                        ),
                                        frameType: UInt8(0x1),
                                        flags: UInt8(0x5),
                                        streamId: 75
                                    ),
                                    maxFragmentLen: 7
                                )
                            let bodyJsonEncodedWire =
                                concatServerEngineAbstractionTestByteArrays(
                                    bodyJsonRequestRecords
                                )
                            [
                                cloneServerEngineByteWindow(
                                    bodyJsonEncodedWire,
                                    0,
                                    4
                                ),
                                cloneServerEngineByteWindow(
                                    bodyJsonEncodedWire,
                                    4,
                                    bodyJsonEncodedWire.size - 7
                                ),
                                cloneServerEngineByteWindow(
                                    bodyJsonEncodedWire,
                                    bodyJsonEncodedWire.size - 3,
                                    3
                                )
                            ]
                        },
                        bodyJsonHello.encodedClientHello,
                        bodyJsonServerPrivate,
                        bodyBytes: "{\"name\":\"ignite\",\"val\":64}".toArray(),
                        transportId: bodyJsonTransportId,
                        maxFragmentLen: 8
                    )
                bodyJsonReadyStatus = bodyJsonTurn.readySnapshot.status
                bodyJsonResponseStatus = bodyJsonTurn.responseStatus
                bodyJsonContentType =
                    bodyJsonTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyJsonTransferEncoding =
                    bodyJsonTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyJsonSocketWriteCount = bodyJsonTurn.socketWriteCount
            } finally {
                if (!bodyJsonAccepted.isClosed()) {
                    bodyJsonAccepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketApplicationDataFragmentedRecordWireProvidedBodyRequestTurnRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let clientHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1536)
                    )
                )
                let firstHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/one".toArray())
                ])
                let secondHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/two".toArray())
                ])
                let transportId =
                    "socket-fragmented-appdata-provided-body-reject-transport"
                let serverPrivate = engineIncrementalBytes(32, start: 1568)
                try {
                    let _ =
                        option.serveJinguiAcceptedTransportSocketApplicationDataFragmentedRecordWireH2ProvidedBodyRequestTurn(
                            accepted,
                            app,
                            { session =>
                                let requestClientChannel =
                                    contractTls13CreateClientRecordChannel(
                                        session.keyMaterial,
                                        algorithm: session.recordChannel.algorithm
                                    )
                                let requestRecords =
                                    requestClientChannel.sealFragments(
                                        ContractTlsRecordContentType.ApplicationData,
                                        concatServerEngineAbstractionTestByteArrays([
                                            buildServerEngineAbstractionTestH2FrameWire(
                                                buildServerEngineAbstractionTestH2HeadersPayload(
                                                    firstHeaderBlock
                                                ),
                                                frameType: UInt8(0x1),
                                                flags: UInt8(0x5),
                                                streamId: 77
                                            ),
                                            buildServerEngineAbstractionTestH2FrameWire(
                                                buildServerEngineAbstractionTestH2HeadersPayload(
                                                    secondHeaderBlock
                                                ),
                                                frameType: UInt8(0x1),
                                                flags: UInt8(0x5),
                                                streamId: 79
                                            )
                                        ]),
                                        maxFragmentLen: 7
                                    )
                                let encodedWire =
                                    concatServerEngineAbstractionTestByteArrays(
                                        requestRecords
                                    )
                                [
                                    cloneServerEngineByteWindow(
                                        encodedWire,
                                        0,
                                        4
                                    ),
                                    cloneServerEngineByteWindow(
                                        encodedWire,
                                        4,
                                        encodedWire.size - 7
                                    ),
                                    cloneServerEngineByteWindow(
                                        encodedWire,
                                        encodedWire.size - 3,
                                        3
                                    )
                                ]
                            },
                            clientHello.encodedClientHello,
                            serverPrivate,
                            bodyBytes: "blocked".toArray(),
                            transportId: transportId,
                            maxFragmentLen: 8
                        )
                    @Fail(
                        "expected socket fragmented-record-wire provided-body turn rejection"
                    )
                } catch (e: Exception) {
                    observedError = e.message
                }
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataHeadersPlusDataLogicalRequestProbeEngine <: ServerEngine {
    public var bodyStringReadyStatus: String = ""
    public var bodyJsonReadyStatus: String = ""
    public var bodyStringResponseStatus: UInt16 = 0
    public var bodyJsonResponseStatus: UInt16 = 0
    public var bodyStringContentType: String = ""
    public var bodyJsonContentType: String = ""
    public var bodyStringTransferEncoding: String = ""
    public var bodyJsonTransferEncoding: String = ""
    public var bodyStringSocketWriteCount: Int64 = 0
    public var bodyJsonSocketWriteCount: Int64 = 0
    var bodyStringClientChannel: ?ContractTlsRecordChannel = None
    var bodyJsonClientChannel: ?ContractTlsRecordChannel = None

    public func openBodyStringSocketWire(wire: Array<UInt8>): String {
        match (bodyStringClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected headers-plus-data bodyString companion client record channel before socket wire open"
                )
        }
    }

    public func openBodyJsonSocketWire(wire: Array<UInt8>): String {
        match (bodyJsonClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected headers-plus-data bodyJson companion client record channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let bodyStringAccepted = listener.accept()
            try {
                let bodyStringBuildHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1152)
                    )
                )
                let bodyStringBuildSession =
                    option.attachJinguiAcceptedTransportTls13X25519(
                        ContractAcceptedTransportDescriptor(
                            "appdata-headers-plus-data-body-string-build-transport",
                            localEndpoint: "127.0.0.1:443",
                            remoteEndpoint: "127.0.0.1:55449"
                        ),
                        bodyStringBuildHello.encodedClientHello,
                        engineIncrementalBytes(32, start: 1184)
                    )
                let bodyStringBuildClientChannel =
                    contractTls13CreateClientRecordChannel(
                        bodyStringBuildSession.keyMaterial,
                        algorithm: bodyStringBuildSession.recordChannel.algorithm
                    )
                let bodyStringHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x21)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-data-body-string".toArray()
                    )
                ])
                let bodyStringRequest =
                    option.openAndBuildJinguiAcceptedTransportLogicalRequestFromApplicationDataH2HeadersPlusData(
                        bodyStringBuildSession,
                        bodyStringBuildClientChannel.sealFragments(
                            ContractTlsRecordContentType.ApplicationData,
                            concatServerEngineAbstractionTestByteArrays([
                                buildServerEngineAbstractionTestH2FrameWire(
                                    buildServerEngineAbstractionTestH2HeadersPayload(
                                        bodyStringHeaderBlock
                                    ),
                                    frameType: UInt8(0x1),
                                    flags: UInt8(0x4),
                                    streamId: 65
                                ),
                                buildServerEngineAbstractionTestH2FrameWire(
                                    serverEngineAbstractionTestByteArray(
                                        "accepted-".toArray()
                                    ),
                                    frameType: UInt8(0x0),
                                    flags: UInt8(0x0),
                                    streamId: 65
                                ),
                                buildServerEngineAbstractionTestH2FrameWire(
                                    serverEngineAbstractionTestByteArray(
                                        "appdata-body".toArray()
                                    ),
                                    frameType: UInt8(0x0),
                                    flags: UInt8(0x1),
                                    streamId: 65
                                )
                            ]),
                            maxFragmentLen: 7
                        )
                    )
                let bodyStringResponseHello =
                    contractTls13BuildHttpClientHelloX25519(
                        "www.example.com",
                        alpnProtocols: ["h2", "http/1.1"],
                        clientPrivateKey: Some(
                            engineIncrementalBytes(32, start: 1216)
                        )
                    )
                let bodyStringTurn =
                    option.serveJinguiAcceptedTransportSocketLogicalRequest(
                        bodyStringAccepted,
                        app,
                        bodyStringRequest,
                        bodyStringResponseHello.encodedClientHello,
                        engineIncrementalBytes(32, start: 1248),
                        transportId: "appdata-headers-plus-data-body-string-transport",
                        maxFragmentLen: 8
                    )
                bodyStringClientChannel = Some(
                    contractTls13CreateClientRecordChannel(
                        bodyStringTurn.session.keyMaterial,
                        algorithm: bodyStringTurn.session.recordChannel.algorithm
                    )
                )
                bodyStringReadyStatus = bodyStringTurn.readySnapshot.status
                bodyStringResponseStatus = bodyStringTurn.responseStatus
                bodyStringContentType =
                    bodyStringTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyStringTransferEncoding =
                    bodyStringTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyStringSocketWriteCount =
                    bodyStringTurn.socketWriteCount
            } finally {
                if (!bodyStringAccepted.isClosed()) {
                    bodyStringAccepted.close()
                }
            }

            let bodyJsonAccepted = listener.accept()
            try {
                let bodyJsonBuildHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1280)
                    )
                )
                let bodyJsonBuildSession =
                    option.attachJinguiAcceptedTransportTls13X25519(
                        ContractAcceptedTransportDescriptor(
                            "appdata-headers-plus-data-body-json-build-transport",
                            localEndpoint: "127.0.0.1:443",
                            remoteEndpoint: "127.0.0.1:55450"
                        ),
                        bodyJsonBuildHello.encodedClientHello,
                        engineIncrementalBytes(32, start: 1312)
                    )
                let bodyJsonBuildClientChannel =
                    contractTls13CreateClientRecordChannel(
                        bodyJsonBuildSession.keyMaterial,
                        algorithm: bodyJsonBuildSession.recordChannel.algorithm
                    )
                let bodyJsonHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x1f)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-data-body-json".toArray()
                    )
                ])
                let bodyJsonRequest =
                    option.openAndBuildJinguiAcceptedTransportLogicalRequestFromApplicationDataH2HeadersPlusData(
                        bodyJsonBuildSession,
                        bodyJsonBuildClientChannel.sealFragments(
                            ContractTlsRecordContentType.ApplicationData,
                            concatServerEngineAbstractionTestByteArrays([
                                buildServerEngineAbstractionTestH2FrameWire(
                                    buildServerEngineAbstractionTestH2HeadersPayload(
                                        bodyJsonHeaderBlock
                                    ),
                                    frameType: UInt8(0x1),
                                    flags: UInt8(0x4),
                                    streamId: 67
                                ),
                                buildServerEngineAbstractionTestH2FrameWire(
                                    serverEngineAbstractionTestByteArray(
                                        "{\"name\":\"ignite\",".toArray()
                                    ),
                                    frameType: UInt8(0x0),
                                    flags: UInt8(0x0),
                                    streamId: 67
                                ),
                                buildServerEngineAbstractionTestH2FrameWire(
                                    serverEngineAbstractionTestByteArray(
                                        "\"val\":23}".toArray()
                                    ),
                                    frameType: UInt8(0x0),
                                    flags: UInt8(0x1),
                                    streamId: 67
                                )
                            ]),
                            maxFragmentLen: 7
                        )
                    )
                let bodyJsonResponseHello =
                    contractTls13BuildHttpClientHelloX25519(
                        "www.example.com",
                        alpnProtocols: ["h2", "http/1.1"],
                        clientPrivateKey: Some(
                            engineIncrementalBytes(32, start: 1344)
                        )
                    )
                let bodyJsonTurn =
                    option.serveJinguiAcceptedTransportSocketLogicalRequest(
                        bodyJsonAccepted,
                        app,
                        bodyJsonRequest,
                        bodyJsonResponseHello.encodedClientHello,
                        engineIncrementalBytes(32, start: 1376),
                        transportId: "appdata-headers-plus-data-body-json-transport",
                        maxFragmentLen: 8
                    )
                bodyJsonClientChannel = Some(
                    contractTls13CreateClientRecordChannel(
                        bodyJsonTurn.session.keyMaterial,
                        algorithm: bodyJsonTurn.session.recordChannel.algorithm
                    )
                )
                bodyJsonReadyStatus = bodyJsonTurn.readySnapshot.status
                bodyJsonResponseStatus = bodyJsonTurn.responseStatus
                bodyJsonContentType =
                    bodyJsonTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyJsonTransferEncoding =
                    bodyJsonTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyJsonSocketWriteCount =
                    bodyJsonTurn.socketWriteCount
            } finally {
                if (!bodyJsonAccepted.isClosed()) {
                    bodyJsonAccepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataHeadersPlusDataLogicalRequestRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let buildHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1408)
                    )
                )
                let buildSession =
                    option.attachJinguiAcceptedTransportTls13X25519(
                        ContractAcceptedTransportDescriptor(
                            "appdata-headers-plus-data-reject-build-transport",
                            localEndpoint: "127.0.0.1:443",
                            remoteEndpoint: "127.0.0.1:55451"
                        ),
                        buildHello.encodedClientHello,
                        engineIncrementalBytes(32, start: 1440)
                    )
                let buildClientChannel =
                    contractTls13CreateClientRecordChannel(
                        buildSession.keyMaterial,
                        algorithm: buildSession.recordChannel.algorithm
                    )
                let headerBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/one".toArray())
                ])
                try {
                    let _ =
                        option.openAndBuildJinguiAcceptedTransportLogicalRequestFromApplicationDataH2HeadersPlusData(
                            buildSession,
                            buildClientChannel.sealFragments(
                                ContractTlsRecordContentType.ApplicationData,
                                concatServerEngineAbstractionTestByteArrays([
                                    buildServerEngineAbstractionTestH2FrameWire(
                                        buildServerEngineAbstractionTestH2HeadersPayload(
                                            headerBlock
                                        ),
                                        frameType: UInt8(0x1),
                                        flags: UInt8(0x4),
                                        streamId: 69
                                    ),
                                    buildServerEngineAbstractionTestH2FrameWire(
                                        serverEngineAbstractionTestByteArray(
                                            "blocked".toArray()
                                        ),
                                        frameType: UInt8(0x0),
                                        flags: UInt8(0x1),
                                        streamId: 71
                                    )
                                ]),
                                maxFragmentLen: 7
                            )
                        )
                    @Fail("expected wrong-stream DATA rejection")
                } catch (e: Exception) {
                    observedError = e.message
                }
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataFragmentedRecordWireHeadersPlusDataRequestTurnProbeEngine <: ServerEngine {
    public var bodyStringReadyStatus: String = ""
    public var bodyJsonReadyStatus: String = ""
    public var bodyStringResponseStatus: UInt16 = 0
    public var bodyJsonResponseStatus: UInt16 = 0
    public var bodyStringContentType: String = ""
    public var bodyJsonContentType: String = ""
    public var bodyStringTransferEncoding: String = ""
    public var bodyJsonTransferEncoding: String = ""
    public var bodyStringSocketWriteCount: Int64 = 0
    public var bodyJsonSocketWriteCount: Int64 = 0
    var bodyStringClientChannel: ?ContractTlsRecordChannel = None
    var bodyJsonClientChannel: ?ContractTlsRecordChannel = None

    public func openBodyStringSocketWire(wire: Array<UInt8>): String {
        match (bodyStringClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected fragmented headers-plus-data request-turn bodyString companion client record channel before socket wire open"
                )
        }
    }

    public func openBodyJsonSocketWire(wire: Array<UInt8>): String {
        match (bodyJsonClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected fragmented headers-plus-data request-turn bodyJson companion client record channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let bodyStringAccepted = listener.accept()
            try {
                let bodyStringHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1664)
                    )
                )
                let bodyStringHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x26)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-data-turn-body-string".toArray()
                    )
                ])
                let bodyStringTransport = ContractAcceptedTransportDescriptor(
                    "fragmented-appdata-data-turn-body-string-transport",
                    localEndpoint: bodyStringAccepted.localAddress.toString(),
                    remoteEndpoint: bodyStringAccepted.remoteAddress.toString()
                )
                let bodyStringSession = option.attachJinguiAcceptedTransportTls13X25519(
                    bodyStringTransport,
                    bodyStringHello.encodedClientHello,
                    engineIncrementalBytes(32, start: 1696)
                )
                let bodyStringRequestClientChannel =
                    contractTls13CreateClientRecordChannel(
                        bodyStringSession.keyMaterial,
                        algorithm: bodyStringSession.recordChannel.algorithm
                    )
                let bodyStringRequestRecords =
                    bodyStringRequestClientChannel.sealFragments(
                        ContractTlsRecordContentType.ApplicationData,
                        concatServerEngineAbstractionTestByteArrays([
                            buildServerEngineAbstractionTestH2FrameWire(
                                buildServerEngineAbstractionTestH2HeadersPayload(
                                    bodyStringHeaderBlock
                                ),
                                frameType: UInt8(0x1),
                                flags: UInt8(0x4),
                                streamId: 81
                            ),
                            buildServerEngineAbstractionTestH2FrameWire(
                                serverEngineAbstractionTestByteArray(
                                    "accepted-".toArray()
                                ),
                                frameType: UInt8(0x0),
                                flags: UInt8(0x0),
                                streamId: 81
                            ),
                            buildServerEngineAbstractionTestH2FrameWire(
                                serverEngineAbstractionTestByteArray(
                                    "appdata-body".toArray()
                                ),
                                frameType: UInt8(0x0),
                                flags: UInt8(0x1),
                                streamId: 81
                            )
                        ]),
                        maxFragmentLen: 7
                    )
                let bodyStringEncodedWire =
                    concatServerEngineAbstractionTestByteArrays(
                        bodyStringRequestRecords
                    )
                let bodyStringTurn =
                    option.serveJinguiAcceptedTransportSessionApplicationDataFragmentedRecordWireH2HeadersPlusDataRequestTurn(
                        bodyStringSession,
                        bodyStringAccepted,
                        app,
                        [
                            cloneServerEngineByteWindow(
                                bodyStringEncodedWire,
                                0,
                                4
                            ),
                            cloneServerEngineByteWindow(
                                bodyStringEncodedWire,
                                4,
                                bodyStringEncodedWire.size - 7
                            ),
                            cloneServerEngineByteWindow(
                                bodyStringEncodedWire,
                                bodyStringEncodedWire.size - 3,
                                3
                            )
                        ],
                        maxFragmentLen: 8
                    )
                bodyStringClientChannel = Some(bodyStringRequestClientChannel)
                bodyStringReadyStatus = bodyStringTurn.readySnapshot.status
                bodyStringResponseStatus = bodyStringTurn.responseStatus
                bodyStringContentType =
                    bodyStringTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyStringTransferEncoding =
                    bodyStringTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyStringSocketWriteCount = bodyStringTurn.socketWriteCount
            } finally {
                if (!bodyStringAccepted.isClosed()) {
                    bodyStringAccepted.close()
                }
            }

            let bodyJsonAccepted = listener.accept()
            try {
                let bodyJsonHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1728)
                    )
                )
                let bodyJsonHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x24)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-data-turn-body-json".toArray()
                    )
                ])
                let bodyJsonTransport = ContractAcceptedTransportDescriptor(
                    "fragmented-appdata-data-turn-body-json-transport",
                    localEndpoint: bodyJsonAccepted.localAddress.toString(),
                    remoteEndpoint: bodyJsonAccepted.remoteAddress.toString()
                )
                let bodyJsonSession = option.attachJinguiAcceptedTransportTls13X25519(
                    bodyJsonTransport,
                    bodyJsonHello.encodedClientHello,
                    engineIncrementalBytes(32, start: 1760)
                )
                let bodyJsonRequestClientChannel =
                    contractTls13CreateClientRecordChannel(
                        bodyJsonSession.keyMaterial,
                        algorithm: bodyJsonSession.recordChannel.algorithm
                    )
                let bodyJsonRequestRecords =
                    bodyJsonRequestClientChannel.sealFragments(
                        ContractTlsRecordContentType.ApplicationData,
                        concatServerEngineAbstractionTestByteArrays([
                            buildServerEngineAbstractionTestH2FrameWire(
                                buildServerEngineAbstractionTestH2HeadersPayload(
                                    bodyJsonHeaderBlock
                                ),
                                frameType: UInt8(0x1),
                                flags: UInt8(0x4),
                                streamId: 83
                            ),
                            buildServerEngineAbstractionTestH2FrameWire(
                                serverEngineAbstractionTestByteArray(
                                    "{\"name\":\"ignite\",".toArray()
                                ),
                                frameType: UInt8(0x0),
                                flags: UInt8(0x0),
                                streamId: 83
                            ),
                            buildServerEngineAbstractionTestH2FrameWire(
                                serverEngineAbstractionTestByteArray(
                                    "\"val\":23}".toArray()
                                ),
                                frameType: UInt8(0x0),
                                flags: UInt8(0x1),
                                streamId: 83
                            )
                        ]),
                        maxFragmentLen: 7
                    )
                let bodyJsonEncodedWire =
                    concatServerEngineAbstractionTestByteArrays(
                        bodyJsonRequestRecords
                    )
                let bodyJsonTurn =
                    option.serveJinguiAcceptedTransportSessionApplicationDataFragmentedRecordWireH2HeadersPlusDataRequestTurn(
                        bodyJsonSession,
                        bodyJsonAccepted,
                        app,
                        [
                            cloneServerEngineByteWindow(
                                bodyJsonEncodedWire,
                                0,
                                4
                            ),
                            cloneServerEngineByteWindow(
                                bodyJsonEncodedWire,
                                4,
                                bodyJsonEncodedWire.size - 7
                            ),
                            cloneServerEngineByteWindow(
                                bodyJsonEncodedWire,
                                bodyJsonEncodedWire.size - 3,
                                3
                            )
                        ],
                        maxFragmentLen: 8
                    )
                bodyJsonClientChannel = Some(bodyJsonRequestClientChannel)
                bodyJsonReadyStatus = bodyJsonTurn.readySnapshot.status
                bodyJsonResponseStatus = bodyJsonTurn.responseStatus
                bodyJsonContentType =
                    bodyJsonTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyJsonTransferEncoding =
                    bodyJsonTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyJsonSocketWriteCount = bodyJsonTurn.socketWriteCount
            } finally {
                if (!bodyJsonAccepted.isClosed()) {
                    bodyJsonAccepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataFragmentedRecordWireHeadersPlusDataRequestTurnRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let clientHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1792)
                    )
                )
                let headerBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/one".toArray())
                ])
                let transport = ContractAcceptedTransportDescriptor(
                    "fragmented-appdata-data-turn-reject-transport",
                    localEndpoint: accepted.localAddress.toString(),
                    remoteEndpoint: accepted.remoteAddress.toString()
                )
                let session = option.attachJinguiAcceptedTransportTls13X25519(
                    transport,
                    clientHello.encodedClientHello,
                    engineIncrementalBytes(32, start: 1824)
                )
                let requestClientChannel = contractTls13CreateClientRecordChannel(
                    session.keyMaterial,
                    algorithm: session.recordChannel.algorithm
                )
                let requestRecords = requestClientChannel.sealFragments(
                    ContractTlsRecordContentType.ApplicationData,
                    concatServerEngineAbstractionTestByteArrays([
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                headerBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x4),
                            streamId: 85
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            serverEngineAbstractionTestByteArray(
                                "blocked".toArray()
                            ),
                            frameType: UInt8(0x0),
                            flags: UInt8(0x1),
                            streamId: 87
                        )
                    ]),
                    maxFragmentLen: 7
                )
                let encodedWire =
                    concatServerEngineAbstractionTestByteArrays(requestRecords)
                try {
                    let _ =
                        option.serveJinguiAcceptedTransportSessionApplicationDataFragmentedRecordWireH2HeadersPlusDataRequestTurn(
                            session,
                            accepted,
                            app,
                            [
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    0,
                                    4
                                ),
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    4,
                                    encodedWire.size - 7
                                ),
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    encodedWire.size - 3,
                                    3
                                )
                            ],
                            maxFragmentLen: 8
                        )
                    @Fail(
                        "expected fragmented-record-wire headers-plus-data request-turn rejection"
                    )
                } catch (e: Exception) {
                    observedError = e.message
                }
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportAcceptedSocketApplicationDataFragmentedRecordWireHeadersPlusDataRequestTurnProbeEngine <: ServerEngine {
    public var bodyStringReadyStatus: String = ""
    public var bodyJsonReadyStatus: String = ""
    public var bodyStringResponseStatus: UInt16 = 0
    public var bodyJsonResponseStatus: UInt16 = 0
    public var bodyStringContentType: String = ""
    public var bodyJsonContentType: String = ""
    public var bodyStringTransferEncoding: String = ""
    public var bodyJsonTransferEncoding: String = ""
    public var bodyStringSocketWriteCount: Int64 = 0
    public var bodyJsonSocketWriteCount: Int64 = 0
    public var bodyStringRequestWireFragments: ?Array<Array<Byte>> = None
    public var bodyJsonRequestWireFragments: ?Array<Array<Byte>> = None
    var bodyStringClientChannel: ?ContractTlsRecordChannel = None
    var bodyJsonClientChannel: ?ContractTlsRecordChannel = None

    public func openBodyStringSocketWire(wire: Array<UInt8>): String {
        match (bodyStringClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected accepted-socket fragmented headers-plus-data request-turn bodyString companion client record channel before socket wire open"
                )
        }
    }

    public func openBodyJsonSocketWire(wire: Array<UInt8>): String {
        match (bodyJsonClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected accepted-socket fragmented headers-plus-data request-turn bodyJson companion client record channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let bodyStringAccepted = listener.accept()
            try {
                let bodyStringHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1856)
                    )
                )
                let bodyStringHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x26)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-data-turn-body-string".toArray()
                    )
                ])
                let bodyStringTransport = ContractAcceptedTransportDescriptor(
                    "accepted-socket-fragmented-appdata-data-turn-body-string-transport",
                    localEndpoint: bodyStringAccepted.localAddress.toString(),
                    remoteEndpoint: bodyStringAccepted.remoteAddress.toString()
                )
                let bodyStringSession = option.attachJinguiAcceptedTransportTls13X25519(
                    bodyStringTransport,
                    bodyStringHello.encodedClientHello,
                    engineIncrementalBytes(32, start: 1888)
                )
                let bodyStringRequestClientChannel =
                    contractTls13CreateClientRecordChannel(
                        bodyStringSession.keyMaterial,
                        algorithm: bodyStringSession.recordChannel.algorithm
                    )
                let bodyStringRequestRecords =
                    bodyStringRequestClientChannel.sealFragments(
                        ContractTlsRecordContentType.ApplicationData,
                        concatServerEngineAbstractionTestByteArrays([
                            buildServerEngineAbstractionTestH2FrameWire(
                                buildServerEngineAbstractionTestH2HeadersPayload(
                                    bodyStringHeaderBlock
                                ),
                                frameType: UInt8(0x1),
                                flags: UInt8(0x4),
                                streamId: 89
                            ),
                            buildServerEngineAbstractionTestH2FrameWire(
                                serverEngineAbstractionTestByteArray(
                                    "accepted-".toArray()
                                ),
                                frameType: UInt8(0x0),
                                flags: UInt8(0x0),
                                streamId: 89
                            ),
                            buildServerEngineAbstractionTestH2FrameWire(
                                serverEngineAbstractionTestByteArray(
                                    "appdata-body".toArray()
                                ),
                                frameType: UInt8(0x0),
                                flags: UInt8(0x1),
                                streamId: 89
                            )
                        ]),
                        maxFragmentLen: 7
                    )
                let bodyStringEncodedWire =
                    concatServerEngineAbstractionTestByteArrays(
                        bodyStringRequestRecords
                    )
                bodyStringRequestWireFragments = Some([
                    cloneServerEngineByteWindow(
                        bodyStringEncodedWire,
                        0,
                        4
                    ),
                    cloneServerEngineByteWindow(
                        bodyStringEncodedWire,
                        4,
                        bodyStringEncodedWire.size - 7
                    ),
                    cloneServerEngineByteWindow(
                        bodyStringEncodedWire,
                        bodyStringEncodedWire.size - 3,
                        3
                    )
                ])
                let bodyStringTurn =
                    option.serveJinguiAcceptedTransportSessionAcceptedSocketApplicationDataFragmentedRecordWireH2HeadersPlusDataRequestTurn(
                        bodyStringSession,
                        bodyStringAccepted,
                        app,
                        readChunkSize: 5,
                        maxFragmentLen: 8
                    )
                bodyStringClientChannel = Some(bodyStringRequestClientChannel)
                bodyStringReadyStatus = bodyStringTurn.readySnapshot.status
                bodyStringResponseStatus = bodyStringTurn.responseStatus
                bodyStringContentType =
                    bodyStringTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyStringTransferEncoding =
                    bodyStringTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyStringSocketWriteCount = bodyStringTurn.socketWriteCount
            } finally {
                if (!bodyStringAccepted.isClosed()) {
                    bodyStringAccepted.close()
                }
            }

            let bodyJsonAccepted = listener.accept()
            try {
                let bodyJsonHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1920)
                    )
                )
                let bodyJsonHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x24)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-data-turn-body-json".toArray()
                    )
                ])
                let bodyJsonTransport = ContractAcceptedTransportDescriptor(
                    "accepted-socket-fragmented-appdata-data-turn-body-json-transport",
                    localEndpoint: bodyJsonAccepted.localAddress.toString(),
                    remoteEndpoint: bodyJsonAccepted.remoteAddress.toString()
                )
                let bodyJsonSession = option.attachJinguiAcceptedTransportTls13X25519(
                    bodyJsonTransport,
                    bodyJsonHello.encodedClientHello,
                    engineIncrementalBytes(32, start: 1952)
                )
                let bodyJsonRequestClientChannel =
                    contractTls13CreateClientRecordChannel(
                        bodyJsonSession.keyMaterial,
                        algorithm: bodyJsonSession.recordChannel.algorithm
                    )
                let bodyJsonRequestRecords =
                    bodyJsonRequestClientChannel.sealFragments(
                        ContractTlsRecordContentType.ApplicationData,
                        concatServerEngineAbstractionTestByteArrays([
                            buildServerEngineAbstractionTestH2FrameWire(
                                buildServerEngineAbstractionTestH2HeadersPayload(
                                    bodyJsonHeaderBlock
                                ),
                                frameType: UInt8(0x1),
                                flags: UInt8(0x4),
                                streamId: 91
                            ),
                            buildServerEngineAbstractionTestH2FrameWire(
                                serverEngineAbstractionTestByteArray(
                                    "{\"name\":\"ignite\",".toArray()
                                ),
                                frameType: UInt8(0x0),
                                flags: UInt8(0x0),
                                streamId: 91
                            ),
                            buildServerEngineAbstractionTestH2FrameWire(
                                serverEngineAbstractionTestByteArray(
                                    "\"val\":23}".toArray()
                                ),
                                frameType: UInt8(0x0),
                                flags: UInt8(0x1),
                                streamId: 91
                            )
                        ]),
                        maxFragmentLen: 7
                    )
                let bodyJsonEncodedWire =
                    concatServerEngineAbstractionTestByteArrays(
                        bodyJsonRequestRecords
                    )
                bodyJsonRequestWireFragments = Some([
                    cloneServerEngineByteWindow(
                        bodyJsonEncodedWire,
                        0,
                        4
                    ),
                    cloneServerEngineByteWindow(
                        bodyJsonEncodedWire,
                        4,
                        bodyJsonEncodedWire.size - 7
                    ),
                    cloneServerEngineByteWindow(
                        bodyJsonEncodedWire,
                        bodyJsonEncodedWire.size - 3,
                        3
                    )
                ])
                let bodyJsonTurn =
                    option.serveJinguiAcceptedTransportSessionAcceptedSocketApplicationDataFragmentedRecordWireH2HeadersPlusDataRequestTurn(
                        bodyJsonSession,
                        bodyJsonAccepted,
                        app,
                        readChunkSize: 5,
                        maxFragmentLen: 8
                    )
                bodyJsonClientChannel = Some(bodyJsonRequestClientChannel)
                bodyJsonReadyStatus = bodyJsonTurn.readySnapshot.status
                bodyJsonResponseStatus = bodyJsonTurn.responseStatus
                bodyJsonContentType =
                    bodyJsonTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyJsonTransferEncoding =
                    bodyJsonTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyJsonSocketWriteCount = bodyJsonTurn.socketWriteCount
            } finally {
                if (!bodyJsonAccepted.isClosed()) {
                    bodyJsonAccepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportAcceptedSocketApplicationDataFragmentedRecordWireTrailingHeadersRequestTurnProbeEngine <: ServerEngine {
    public var readyStatus: String = ""
    public var responseStatus: UInt16 = 0
    public var responseTrailerHeader: String = ""
    public var contentType: String = ""
    public var transferEncoding: String = ""
    public var socketWriteCount: Int64 = 0
    public var requestWireFragments: ?Array<Array<Byte>> = None
    let splitTrailingHeaderBlock: Bool
    var clientChannel: ?ContractTlsRecordChannel = None

    public init(splitTrailingHeaderBlock!: Bool = false) {
        this.splitTrailingHeaderBlock = splitTrailingHeaderBlock
    }

    public func openSocketWire(wire: Array<UInt8>): String {
        match (clientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected accepted-socket trailing HEADERS request-turn companion client record channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let clientHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 2240)
                    )
                )
                let headerBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x09)]),
                    serverEngineAbstractionTestByteArray("/trailers".toArray())
                ])
                let trailerBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x10), UInt8(0x11)]),
                    serverEngineAbstractionTestByteArray("x-request-trailer".toArray()),
                    serverEngineAbstractionTestByteArray([UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("tail".toArray())
                ])
                let transport = ContractAcceptedTransportDescriptor(
                    "accepted-socket-fragmented-appdata-trailers-turn-transport",
                    localEndpoint: accepted.localAddress.toString(),
                    remoteEndpoint: accepted.remoteAddress.toString()
                )
                let session = option.attachJinguiAcceptedTransportTls13X25519(
                    transport,
                    clientHello.encodedClientHello,
                    engineIncrementalBytes(32, start: 2272)
                )
                let requestClientChannel =
                    contractTls13CreateClientRecordChannel(
                        session.keyMaterial,
                        algorithm: session.recordChannel.algorithm
                    )
                let requestRecords =
                    requestClientChannel.sealFragments(
                        ContractTlsRecordContentType.ApplicationData,
                        buildAcceptedTransportTrailingHeadersRequestTurnWire(
                            headerBlock,
                            trailerBlock,
                            splitTrailingHeaderBlock
                        ),
                        maxFragmentLen: 7
                    )
                let encodedWire =
                    concatServerEngineAbstractionTestByteArrays(requestRecords)
                requestWireFragments = Some([
                    cloneServerEngineByteWindow(
                        encodedWire,
                        0,
                        4
                    ),
                    cloneServerEngineByteWindow(
                        encodedWire,
                        4,
                        encodedWire.size - 7
                    ),
                    cloneServerEngineByteWindow(
                        encodedWire,
                        encodedWire.size - 3,
                        3
                    )
                ])
                let turn =
                    option.serveJinguiAcceptedTransportSessionAcceptedSocketApplicationDataFragmentedRecordWireH2HeadersPlusDataRequestTurn(
                        session,
                        accepted,
                        app,
                        readChunkSize: 5,
                        maxFragmentLen: 8
                    )
                clientChannel = Some(requestClientChannel)
                readyStatus = turn.readySnapshot.status
                responseStatus = turn.responseStatus
                responseTrailerHeader =
                    turn.responseHeaders.getFirst("x-accepted-socket-trailer") ?? ""
                contentType =
                    turn.responseHeaders.getFirst("content-type") ?? ""
                transferEncoding =
                    turn.responseHeaders.getFirst("transfer-encoding") ?? ""
                socketWriteCount = turn.socketWriteCount
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}

    func buildAcceptedTransportTrailingHeadersRequestTurnWire(
        headerBlock: Array<Byte>,
        trailerBlock: Array<Byte>,
        splitTrailer: Bool
    ): Array<Byte> {
        let frames = ArrayList<Array<Byte>>()
        frames.add(
            buildServerEngineAbstractionTestH2FrameWire(
                buildServerEngineAbstractionTestH2HeadersPayload(
                    headerBlock
                ),
                frameType: UInt8(0x1),
                flags: UInt8(0x4),
                streamId: 105
            )
        )
        frames.add(
            buildServerEngineAbstractionTestH2FrameWire(
                serverEngineAbstractionTestByteArray(
                    "accepted-body".toArray()
                ),
                frameType: UInt8(0x0),
                flags: UInt8(0x0),
                streamId: 105
            )
        )
        if (splitTrailer) {
            let splitAt = trailerBlock.size - 5
            frames.add(
                buildServerEngineAbstractionTestH2FrameWire(
                    buildServerEngineAbstractionTestH2HeadersPayload(
                        cloneServerEngineByteWindow(
                            trailerBlock,
                            0,
                            splitAt
                        )
                    ),
                    frameType: UInt8(0x1),
                    flags: UInt8(0x1),
                    streamId: 105
                )
            )
            frames.add(
                buildServerEngineAbstractionTestH2FrameWire(
                    cloneServerEngineByteWindow(
                        trailerBlock,
                        splitAt,
                        trailerBlock.size - splitAt
                    ),
                    frameType: UInt8(0x9),
                    flags: UInt8(0x4),
                    streamId: 105
                )
            )
        } else {
            frames.add(
                buildServerEngineAbstractionTestH2FrameWire(
                    buildServerEngineAbstractionTestH2HeadersPayload(
                        trailerBlock
                    ),
                    frameType: UInt8(0x1),
                    flags: UInt8(0x5),
                    streamId: 105
                )
            )
        }
        concatServerEngineAbstractionTestByteArrays(frames.toArray())
    }
}

class JinguiAcceptedTransportAcceptedSocketApplicationDataFragmentedRecordWireHeadersPlusDataRequestTurnRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""
    public var requestWireFragments: ?Array<Array<Byte>> = None
    let rejectMode: String

    public init(rejectMode!: String = "wrong-stream-data") {
        this.rejectMode = rejectMode
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let clientHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1984)
                    )
                )
                let headerBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/one".toArray())
                ])
                let trailerBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x10), UInt8(0x11)]),
                    serverEngineAbstractionTestByteArray("x-request-trailer".toArray()),
                    serverEngineAbstractionTestByteArray([UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("tail".toArray())
                ])
                let transport = ContractAcceptedTransportDescriptor(
                    "accepted-socket-fragmented-appdata-data-turn-reject-transport",
                    localEndpoint: accepted.localAddress.toString(),
                    remoteEndpoint: accepted.remoteAddress.toString()
                )
                let session = option.attachJinguiAcceptedTransportTls13X25519(
                    transport,
                    clientHello.encodedClientHello,
                    engineIncrementalBytes(32, start: 2016)
                )
                let requestClientChannel = contractTls13CreateClientRecordChannel(
                    session.keyMaterial,
                    algorithm: session.recordChannel.algorithm
                )
                let requestPayload = if (rejectMode == "trailing-headers-without-end-stream") {
                    concatServerEngineAbstractionTestByteArrays([
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                headerBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x4),
                            streamId: 93
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            serverEngineAbstractionTestByteArray(
                                "blocked".toArray()
                            ),
                            frameType: UInt8(0x0),
                            flags: UInt8(0x0),
                            streamId: 93
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                trailerBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x4),
                            streamId: 93
                        )
                    ])
                } else if (rejectMode == "trailing-headers-before-data") {
                    concatServerEngineAbstractionTestByteArrays([
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                headerBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x4),
                            streamId: 93
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                trailerBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x5),
                            streamId: 93
                        )
                    ])
                } else if (rejectMode == "trailing-continuation-stream-mismatch") {
                    concatServerEngineAbstractionTestByteArrays([
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                headerBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x4),
                            streamId: 93
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            serverEngineAbstractionTestByteArray(
                                "blocked".toArray()
                            ),
                            frameType: UInt8(0x0),
                            flags: UInt8(0x0),
                            streamId: 93
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                cloneServerEngineByteWindow(
                                    trailerBlock,
                                    0,
                                    trailerBlock.size - 5
                                )
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x1),
                            streamId: 93
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            cloneServerEngineByteWindow(
                                trailerBlock,
                                trailerBlock.size - 5,
                                5
                            ),
                            frameType: UInt8(0x9),
                            flags: UInt8(0x4),
                            streamId: 95
                        )
                    ])
                } else if (rejectMode == "orphan-trailing-continuation") {
                    concatServerEngineAbstractionTestByteArrays([
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                headerBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x4),
                            streamId: 93
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            serverEngineAbstractionTestByteArray(
                                "blocked".toArray()
                            ),
                            frameType: UInt8(0x0),
                            flags: UInt8(0x0),
                            streamId: 93
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            cloneServerEngineByteWindow(
                                trailerBlock,
                                trailerBlock.size - 5,
                                5
                            ),
                            frameType: UInt8(0x9),
                            flags: UInt8(0x4),
                            streamId: 93
                        )
                    ])
                } else if (rejectMode == "data-after-trailing-headers") {
                    concatServerEngineAbstractionTestByteArrays([
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                headerBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x4),
                            streamId: 93
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            serverEngineAbstractionTestByteArray(
                                "blocked".toArray()
                            ),
                            frameType: UInt8(0x0),
                            flags: UInt8(0x0),
                            streamId: 93
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                trailerBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x5),
                            streamId: 93
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            serverEngineAbstractionTestByteArray(
                                "too-late".toArray()
                            ),
                            frameType: UInt8(0x0),
                            flags: UInt8(0x1),
                            streamId: 93
                        )
                    ])
                } else if (rejectMode == "data-after-body-end-stream") {
                    concatServerEngineAbstractionTestByteArrays([
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                headerBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x4),
                            streamId: 93
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            serverEngineAbstractionTestByteArray(
                                "blocked".toArray()
                            ),
                            frameType: UInt8(0x0),
                            flags: UInt8(0x1),
                            streamId: 93
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            serverEngineAbstractionTestByteArray(
                                "too-late".toArray()
                            ),
                            frameType: UInt8(0x0),
                            flags: UInt8(0x1),
                            streamId: 93
                        )
                    ])
                } else if (rejectMode == "headers-after-body-end-stream") {
                    concatServerEngineAbstractionTestByteArrays([
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                headerBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x4),
                            streamId: 93
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            serverEngineAbstractionTestByteArray(
                                "blocked".toArray()
                            ),
                            frameType: UInt8(0x0),
                            flags: UInt8(0x1),
                            streamId: 93
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                headerBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x5),
                            streamId: 93
                        )
                    ])
                } else if (rejectMode == "headers-after-trailing-headers") {
                    concatServerEngineAbstractionTestByteArrays([
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                headerBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x4),
                            streamId: 93
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            serverEngineAbstractionTestByteArray(
                                "blocked".toArray()
                            ),
                            frameType: UInt8(0x0),
                            flags: UInt8(0x0),
                            streamId: 93
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                trailerBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x5),
                            streamId: 93
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                headerBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x5),
                            streamId: 93
                        )
                    ])
                } else if (rejectMode == "continuation-after-trailing-headers") {
                    concatServerEngineAbstractionTestByteArrays([
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                headerBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x4),
                            streamId: 93
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            serverEngineAbstractionTestByteArray(
                                "blocked".toArray()
                            ),
                            frameType: UInt8(0x0),
                            flags: UInt8(0x0),
                            streamId: 93
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                trailerBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x5),
                            streamId: 93
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            serverEngineAbstractionTestByteArray(
                                "late".toArray()
                            ),
                            frameType: UInt8(0x9),
                            flags: UInt8(0x4),
                            streamId: 93
                        )
                    ])
                } else {
                    concatServerEngineAbstractionTestByteArrays([
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                headerBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x4),
                            streamId: 93
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            serverEngineAbstractionTestByteArray(
                                "blocked".toArray()
                            ),
                            frameType: UInt8(0x0),
                            flags: UInt8(0x1),
                            streamId: 95
                        )
                    ])
                }
                let requestRecords = requestClientChannel.sealFragments(
                    ContractTlsRecordContentType.ApplicationData,
                    requestPayload,
                    maxFragmentLen: 7
                )
                let encodedWire =
                    concatServerEngineAbstractionTestByteArrays(requestRecords)
                requestWireFragments = Some([
                    cloneServerEngineByteWindow(
                        encodedWire,
                        0,
                        4
                    ),
                    cloneServerEngineByteWindow(
                        encodedWire,
                        4,
                        encodedWire.size - 7
                    ),
                    cloneServerEngineByteWindow(
                        encodedWire,
                        encodedWire.size - 3,
                        3
                    )
                ])
                try {
                    let _ =
                        option.serveJinguiAcceptedTransportSessionAcceptedSocketApplicationDataFragmentedRecordWireH2HeadersPlusDataRequestTurn(
                            session,
                            accepted,
                            app,
                            readChunkSize: 5,
                            maxFragmentLen: 8
                        )
                    @Fail(
                        "expected accepted-socket fragmented-record-wire headers-plus-data request-turn rejection"
                    )
                } catch (e: Exception) {
                    observedError = e.message
                }
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataHeadersPlusDataRequestTurnProbeEngine <: ServerEngine {
    public var bodyStringReadyStatus: String = ""
    public var bodyJsonReadyStatus: String = ""
    public var bodyStringResponseStatus: UInt16 = 0
    public var bodyJsonResponseStatus: UInt16 = 0
    public var bodyStringContentType: String = ""
    public var bodyJsonContentType: String = ""
    public var bodyStringTransferEncoding: String = ""
    public var bodyJsonTransferEncoding: String = ""
    public var bodyStringSocketWriteCount: Int64 = 0
    public var bodyJsonSocketWriteCount: Int64 = 0
    var bodyStringClientChannel: ?ContractTlsRecordChannel = None
    var bodyJsonClientChannel: ?ContractTlsRecordChannel = None

    public func openBodyStringSocketWire(wire: Array<UInt8>): String {
        match (bodyStringClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected headers-plus-data request-turn bodyString companion client record channel before socket wire open"
                )
        }
    }

    public func openBodyJsonSocketWire(wire: Array<UInt8>): String {
        match (bodyJsonClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected headers-plus-data request-turn bodyJson companion client record channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let bodyStringAccepted = listener.accept()
            try {
                let bodyStringHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1472)
                    )
                )
                let bodyStringHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x26)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-data-turn-body-string".toArray()
                    )
                ])
                let bodyStringTransport = ContractAcceptedTransportDescriptor(
                    "appdata-data-turn-body-string-transport",
                    localEndpoint: bodyStringAccepted.localAddress.toString(),
                    remoteEndpoint: bodyStringAccepted.remoteAddress.toString()
                )
                let bodyStringSession = option.attachJinguiAcceptedTransportTls13X25519(
                    bodyStringTransport,
                    bodyStringHello.encodedClientHello,
                    engineIncrementalBytes(32, start: 1504)
                )
                let bodyStringRequestClientChannel =
                    contractTls13CreateClientRecordChannel(
                        bodyStringSession.keyMaterial,
                        algorithm: bodyStringSession.recordChannel.algorithm
                    )
                let bodyStringRequestFragments =
                    bodyStringRequestClientChannel.sealFragments(
                        ContractTlsRecordContentType.ApplicationData,
                        concatServerEngineAbstractionTestByteArrays([
                            buildServerEngineAbstractionTestH2FrameWire(
                                buildServerEngineAbstractionTestH2HeadersPayload(
                                    bodyStringHeaderBlock
                                ),
                                frameType: UInt8(0x1),
                                flags: UInt8(0x4),
                                streamId: 73
                            ),
                            buildServerEngineAbstractionTestH2FrameWire(
                                serverEngineAbstractionTestByteArray(
                                    "accepted-".toArray()
                                ),
                                frameType: UInt8(0x0),
                                flags: UInt8(0x0),
                                streamId: 73
                            ),
                            buildServerEngineAbstractionTestH2FrameWire(
                                serverEngineAbstractionTestByteArray(
                                    "appdata-body".toArray()
                                ),
                                frameType: UInt8(0x0),
                                flags: UInt8(0x1),
                                streamId: 73
                            )
                        ]),
                        maxFragmentLen: 7
                    )
                let bodyStringTurn =
                    option.serveJinguiAcceptedTransportSessionApplicationDataH2HeadersPlusDataRequestTurn(
                        bodyStringSession,
                        bodyStringAccepted,
                        app,
                        bodyStringRequestFragments,
                        maxFragmentLen: 8
                    )
                bodyStringClientChannel = Some(bodyStringRequestClientChannel)
                bodyStringReadyStatus = bodyStringTurn.readySnapshot.status
                bodyStringResponseStatus = bodyStringTurn.responseStatus
                bodyStringContentType =
                    bodyStringTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyStringTransferEncoding =
                    bodyStringTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyStringSocketWriteCount = bodyStringTurn.socketWriteCount
            } finally {
                if (!bodyStringAccepted.isClosed()) {
                    bodyStringAccepted.close()
                }
            }

            let bodyJsonAccepted = listener.accept()
            try {
                let bodyJsonHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1536)
                    )
                )
                let bodyJsonHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x24)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-data-turn-body-json".toArray()
                    )
                ])
                let bodyJsonTransport = ContractAcceptedTransportDescriptor(
                    "appdata-data-turn-body-json-transport",
                    localEndpoint: bodyJsonAccepted.localAddress.toString(),
                    remoteEndpoint: bodyJsonAccepted.remoteAddress.toString()
                )
                let bodyJsonSession = option.attachJinguiAcceptedTransportTls13X25519(
                    bodyJsonTransport,
                    bodyJsonHello.encodedClientHello,
                    engineIncrementalBytes(32, start: 1568)
                )
                let bodyJsonRequestClientChannel =
                    contractTls13CreateClientRecordChannel(
                        bodyJsonSession.keyMaterial,
                        algorithm: bodyJsonSession.recordChannel.algorithm
                    )
                let bodyJsonRequestFragments =
                    bodyJsonRequestClientChannel.sealFragments(
                        ContractTlsRecordContentType.ApplicationData,
                        concatServerEngineAbstractionTestByteArrays([
                            buildServerEngineAbstractionTestH2FrameWire(
                                buildServerEngineAbstractionTestH2HeadersPayload(
                                    bodyJsonHeaderBlock
                                ),
                                frameType: UInt8(0x1),
                                flags: UInt8(0x4),
                                streamId: 75
                            ),
                            buildServerEngineAbstractionTestH2FrameWire(
                                serverEngineAbstractionTestByteArray(
                                    "{\"name\":\"ignite\",".toArray()
                                ),
                                frameType: UInt8(0x0),
                                flags: UInt8(0x0),
                                streamId: 75
                            ),
                            buildServerEngineAbstractionTestH2FrameWire(
                                serverEngineAbstractionTestByteArray(
                                    "\"val\":23}".toArray()
                                ),
                                frameType: UInt8(0x0),
                                flags: UInt8(0x1),
                                streamId: 75
                            )
                        ]),
                        maxFragmentLen: 7
                    )
                let bodyJsonTurn =
                    option.serveJinguiAcceptedTransportSessionApplicationDataH2HeadersPlusDataRequestTurn(
                        bodyJsonSession,
                        bodyJsonAccepted,
                        app,
                        bodyJsonRequestFragments,
                        maxFragmentLen: 8
                    )
                bodyJsonClientChannel = Some(bodyJsonRequestClientChannel)
                bodyJsonReadyStatus = bodyJsonTurn.readySnapshot.status
                bodyJsonResponseStatus = bodyJsonTurn.responseStatus
                bodyJsonContentType =
                    bodyJsonTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyJsonTransferEncoding =
                    bodyJsonTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyJsonSocketWriteCount = bodyJsonTurn.socketWriteCount
            } finally {
                if (!bodyJsonAccepted.isClosed()) {
                    bodyJsonAccepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataHeadersPlusDataRequestTurnRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let clientHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1600)
                    )
                )
                let headerBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/one".toArray())
                ])
                let transport = ContractAcceptedTransportDescriptor(
                    "appdata-data-turn-reject-transport",
                    localEndpoint: accepted.localAddress.toString(),
                    remoteEndpoint: accepted.remoteAddress.toString()
                )
                let session = option.attachJinguiAcceptedTransportTls13X25519(
                    transport,
                    clientHello.encodedClientHello,
                    engineIncrementalBytes(32, start: 1632)
                )
                let requestClientChannel = contractTls13CreateClientRecordChannel(
                    session.keyMaterial,
                    algorithm: session.recordChannel.algorithm
                )
                let requestFragments = requestClientChannel.sealFragments(
                    ContractTlsRecordContentType.ApplicationData,
                    concatServerEngineAbstractionTestByteArrays([
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                headerBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x4),
                            streamId: 77
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            serverEngineAbstractionTestByteArray(
                                "blocked".toArray()
                            ),
                            frameType: UInt8(0x0),
                            flags: UInt8(0x1),
                            streamId: 79
                        )
                    ]),
                    maxFragmentLen: 7
                )
                try {
                    let _ =
                        option.serveJinguiAcceptedTransportSessionApplicationDataH2HeadersPlusDataRequestTurn(
                            session,
                            accepted,
                            app,
                            requestFragments,
                            maxFragmentLen: 8
                        )
                    @Fail("expected wrong-stream DATA request-turn rejection")
                } catch (e: Exception) {
                    observedError = e.message
                }
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloCaptureProbeEngine <: ServerEngine {
    public var capturedClientHello: Array<Byte> = []
    public var capturedRecordCount: Int64 = 0
    public var capturedRecordWireByteCount: Int64 = 0

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let capture =
                    option.captureJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHello(
                        accepted,
                        readChunkSize: 7
                    )
                capturedClientHello = capture.encodedClientHello
                capturedRecordCount = capture.consumedRecordCount
                capturedRecordWireByteCount =
                    capture.consumedRecordWireByteCount
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloCaptureRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                try {
                    let _ =
                        option.captureJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHello(
                            accepted,
                            readChunkSize: 7
                        )
                } catch (e: Exception) {
                    observedError = e.message
                }
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloAttachProbeEngine <: ServerEngine {
    public var capturedClientHello: Array<Byte> = []
    public var capturedRecordCount: Int64 = 0
    public var capturedRecordWireByteCount: Int64 = 0
    public var readyStatus: String = ""
    public var secureSessionReady: Bool = false
    public var negotiatedAlpn: String = ""
    public var requestedServerName: String = ""
    public var acknowledgedServerName: Bool = false
    public var attachSurface: String = ""
    public var transportId: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let result =
                    option.attachJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloX25519(
                        accepted,
                        engineIncrementalBytes(32, start: 2304),
                        transportId: "captured-clienthello-attach-transport",
                        readChunkSize: 9
                    )
                capturedClientHello = result.capture.encodedClientHello
                capturedRecordCount = result.capture.consumedRecordCount
                capturedRecordWireByteCount =
                    result.capture.consumedRecordWireByteCount
                readyStatus = result.readySnapshot.status
                secureSessionReady = result.readySnapshot.secureSessionReady
                negotiatedAlpn =
                    result.readySnapshot
                        .jinguiAttachResultSnapshot
                        .negotiatedAlpn
                requestedServerName =
                    result.readySnapshot
                        .jinguiAttachResultSnapshot
                        .requestedServerName
                acknowledgedServerName =
                    result.readySnapshot
                        .jinguiAttachResultSnapshot
                        .acknowledgedServerName
                attachSurface =
                    result.readySnapshot
                        .jinguiAttachResultSnapshot
                        .attachSurface
                transportId = result.readySnapshot.transport.transportId
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloAttachRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                try {
                    let _ =
                        option.attachJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloX25519(
                            accepted,
                            engineIncrementalBytes(32, start: 2336),
                            transportId: "captured-clienthello-attach-reject-transport",
                            readChunkSize: 9
                        )
                } catch (e: Exception) {
                    observedError = e.message
                }
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloRequestTurnProbeEngine <: ServerEngine {
    public var bodyStringReadyStatus: String = ""
    public var bodyJsonReadyStatus: String = ""
    public var bodyStringResponseStatus: UInt16 = 0
    public var bodyJsonResponseStatus: UInt16 = 0
    public var bodyStringContentType: String = ""
    public var bodyJsonContentType: String = ""
    public var bodyStringTransferEncoding: String = ""
    public var bodyJsonTransferEncoding: String = ""
    public var bodyStringSocketWriteCount: Int64 = 0
    public var bodyJsonSocketWriteCount: Int64 = 0
    public var bodyStringNegotiatedAlpn: String = ""
    public var bodyJsonNegotiatedAlpn: String = ""
    public var bodyStringRequestedServerName: String = ""
    public var bodyJsonRequestedServerName: String = ""
    public var bodyStringAttachSurface: String = ""
    public var bodyJsonAttachSurface: String = ""
    public var bodyStringTransportId: String = ""
    public var bodyJsonTransportId: String = ""
    public var bodyStringRequestWireFragments: ?Array<Array<Byte>> = None
    public var bodyJsonRequestWireFragments: ?Array<Array<Byte>> = None
    var bodyStringClientChannel: ?ContractTlsRecordChannel = None
    var bodyJsonClientChannel: ?ContractTlsRecordChannel = None

    public func openBodyStringSocketWire(wire: Array<UInt8>): String {
        match (bodyStringClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "captured-clienthello fragmented bodyString client channel missing"
                )
        }
    }

    public func openBodyJsonSocketWire(wire: Array<UInt8>): String {
        match (bodyJsonClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "captured-clienthello fragmented bodyJson client channel missing"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let bodyStringAccepted = listener.accept()
            try {
                let bodyStringServerKeyExchangePrivate =
                    engineIncrementalBytes(32, start: 2432)
                let bodyStringProbeTransportId =
                    "captured-clienthello-fragmented-appdata-data-turn-body-string-transport"
                let bodyStringHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x26)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-data-turn-body-string".toArray()
                    )
                ])
                let bodyStringTurn =
                    option.serveJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataFragmentedRecordWireH2HeadersPlusDataRequestTurn(
                        bodyStringAccepted,
                        app,
                        bodyStringServerKeyExchangePrivate,
                        transportId: bodyStringProbeTransportId,
                        readChunkSize: 5,
                        maxFragmentLen: 8,
                        attachedSessionReadyHook: { session =>
                            let requestClientChannel =
                                contractTls13CreateClientRecordChannel(
                                    session.keyMaterial,
                                    algorithm: session.recordChannel.algorithm
                                )
                            let requestRecords =
                                requestClientChannel.sealFragments(
                                    ContractTlsRecordContentType.ApplicationData,
                                    concatServerEngineAbstractionTestByteArrays([
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            buildServerEngineAbstractionTestH2HeadersPayload(
                                                bodyStringHeaderBlock
                                            ),
                                            frameType: UInt8(0x1),
                                            flags: UInt8(0x4),
                                            streamId: 105
                                        ),
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            serverEngineAbstractionTestByteArray(
                                                "accepted-".toArray()
                                            ),
                                            frameType: UInt8(0x0),
                                            flags: UInt8(0x0),
                                            streamId: 105
                                        ),
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            serverEngineAbstractionTestByteArray(
                                                "appdata-body".toArray()
                                            ),
                                            frameType: UInt8(0x0),
                                            flags: UInt8(0x1),
                                            streamId: 105
                                        )
                                    ]),
                                    maxFragmentLen: 7
                                )
                            let encodedWire =
                                concatServerEngineAbstractionTestByteArrays(
                                    requestRecords
                                )
                            bodyStringRequestWireFragments = Some([
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    0,
                                    4
                                ),
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    4,
                                    encodedWire.size - 7
                                ),
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    encodedWire.size - 3,
                                    3
                                )
                            ])
                            bodyStringClientChannel = Some(
                                requestClientChannel
                            )
                        }
                    )
                bodyStringReadyStatus = bodyStringTurn.readySnapshot.status
                bodyStringResponseStatus = bodyStringTurn.responseStatus
                bodyStringContentType =
                    bodyStringTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyStringTransferEncoding =
                    bodyStringTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyStringSocketWriteCount = bodyStringTurn.socketWriteCount
                bodyStringNegotiatedAlpn =
                    bodyStringTurn.readySnapshot.jinguiAttachResultSnapshot.negotiatedAlpn
                bodyStringRequestedServerName =
                    bodyStringTurn.readySnapshot.jinguiAttachResultSnapshot.requestedServerName
                bodyStringAttachSurface =
                    bodyStringTurn.readySnapshot.jinguiAttachResultSnapshot.attachSurface
                bodyStringTransportId =
                    bodyStringTurn.readySnapshot.transport.transportId
            } finally {
                if (!bodyStringAccepted.isClosed()) {
                    bodyStringAccepted.close()
                }
            }

            let bodyJsonAccepted = listener.accept()
            try {
                let bodyJsonServerKeyExchangePrivate =
                    engineIncrementalBytes(32, start: 2464)
                let bodyJsonProbeTransportId =
                    "captured-clienthello-fragmented-appdata-data-turn-body-json-transport"
                let bodyJsonHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x24)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-data-turn-body-json".toArray()
                    )
                ])
                let bodyJsonTurn =
                    option.serveJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataFragmentedRecordWireH2HeadersPlusDataRequestTurn(
                        bodyJsonAccepted,
                        app,
                        bodyJsonServerKeyExchangePrivate,
                        transportId: bodyJsonProbeTransportId,
                        readChunkSize: 5,
                        maxFragmentLen: 8,
                        attachedSessionReadyHook: { session =>
                            let requestClientChannel =
                                contractTls13CreateClientRecordChannel(
                                    session.keyMaterial,
                                    algorithm: session.recordChannel.algorithm
                                )
                            let requestRecords =
                                requestClientChannel.sealFragments(
                                    ContractTlsRecordContentType.ApplicationData,
                                    concatServerEngineAbstractionTestByteArrays([
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            buildServerEngineAbstractionTestH2HeadersPayload(
                                                bodyJsonHeaderBlock
                                            ),
                                            frameType: UInt8(0x1),
                                            flags: UInt8(0x4),
                                            streamId: 107
                                        ),
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            serverEngineAbstractionTestByteArray(
                                                "{\"name\":\"ignite\",".toArray()
                                            ),
                                            frameType: UInt8(0x0),
                                            flags: UInt8(0x0),
                                            streamId: 107
                                        ),
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            serverEngineAbstractionTestByteArray(
                                                "\"val\":23}".toArray()
                                            ),
                                            frameType: UInt8(0x0),
                                            flags: UInt8(0x1),
                                            streamId: 107
                                        )
                                    ]),
                                    maxFragmentLen: 7
                                )
                            let encodedWire =
                                concatServerEngineAbstractionTestByteArrays(
                                    requestRecords
                                )
                            bodyJsonRequestWireFragments = Some([
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    0,
                                    4
                                ),
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    4,
                                    encodedWire.size - 7
                                ),
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    encodedWire.size - 3,
                                    3
                                )
                            ])
                            bodyJsonClientChannel = Some(
                                requestClientChannel
                            )
                        }
                    )
                bodyJsonReadyStatus = bodyJsonTurn.readySnapshot.status
                bodyJsonResponseStatus = bodyJsonTurn.responseStatus
                bodyJsonContentType =
                    bodyJsonTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyJsonTransferEncoding =
                    bodyJsonTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyJsonSocketWriteCount = bodyJsonTurn.socketWriteCount
                bodyJsonNegotiatedAlpn =
                    bodyJsonTurn.readySnapshot.jinguiAttachResultSnapshot.negotiatedAlpn
                bodyJsonRequestedServerName =
                    bodyJsonTurn.readySnapshot.jinguiAttachResultSnapshot.requestedServerName
                bodyJsonAttachSurface =
                    bodyJsonTurn.readySnapshot.jinguiAttachResultSnapshot.attachSurface
                bodyJsonTransportId =
                    bodyJsonTurn.readySnapshot.transport.transportId
            } finally {
                if (!bodyJsonAccepted.isClosed()) {
                    bodyJsonAccepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloRequestTurnRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                try {
                    let _ =
                        option.serveJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataFragmentedRecordWireH2HeadersPlusDataRequestTurn(
                            accepted,
                            app,
                            engineIncrementalBytes(32, start: 2496),
                            transportId: "captured-clienthello-fragmented-appdata-data-turn-reject-transport",
                            readChunkSize: 5,
                            maxFragmentLen: 8
                        )
                } catch (e: Exception) {
                    observedError = e.message
                }
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloLogicalRequestProbeEngine <: ServerEngine {
    public var bodyStringReadyStatus: String = ""
    public var bodyJsonReadyStatus: String = ""
    public var bodyStringResponseStatus: UInt16 = 0
    public var bodyJsonResponseStatus: UInt16 = 0
    public var bodyStringContentType: String = ""
    public var bodyJsonContentType: String = ""
    public var bodyStringTransferEncoding: String = ""
    public var bodyJsonTransferEncoding: String = ""
    public var bodyStringSocketWriteCount: Int64 = 0
    public var bodyJsonSocketWriteCount: Int64 = 0
    public var bodyStringNegotiatedAlpn: String = ""
    public var bodyJsonNegotiatedAlpn: String = ""
    public var bodyStringRequestedServerName: String = ""
    public var bodyJsonRequestedServerName: String = ""
    public var bodyStringAttachSurface: String = ""
    public var bodyJsonAttachSurface: String = ""
    public var bodyStringTransportId: String = ""
    public var bodyJsonTransportId: String = ""
    var bodyStringClientChannel: ?ContractTlsRecordChannel = None
    var bodyJsonClientChannel: ?ContractTlsRecordChannel = None

    public func openBodyStringSocketWire(wire: Array<UInt8>): String {
        match (bodyStringClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "captured-clienthello logical-request bodyString client channel missing"
                )
        }
    }

    public func openBodyJsonSocketWire(wire: Array<UInt8>): String {
        match (bodyJsonClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "captured-clienthello logical-request bodyJson client channel missing"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let bodyStringAccepted = listener.accept()
            try {
                let bodyStringTurn =
                    option.serveJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloLogicalRequest(
                        bodyStringAccepted,
                        app,
                        ServerJinguiAcceptedTransportLogicalRequest(
                            "POST",
                            "/carrier-captured-logical-body-string",
                            bodyBytes: "accepted-body".toArray()
                        ),
                        engineIncrementalBytes(32, start: 2592),
                        transportId: "captured-clienthello-logical-request-body-string-transport",
                        readChunkSize: 5,
                        maxFragmentLen: 8
                    )
                bodyStringClientChannel = Some(
                    contractTls13CreateClientRecordChannel(
                        bodyStringTurn.session.keyMaterial,
                        algorithm: bodyStringTurn.session.recordChannel.algorithm
                    )
                )
                bodyStringReadyStatus = bodyStringTurn.readySnapshot.status
                bodyStringResponseStatus = bodyStringTurn.responseStatus
                bodyStringContentType =
                    bodyStringTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyStringTransferEncoding =
                    bodyStringTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyStringSocketWriteCount = bodyStringTurn.socketWriteCount
                bodyStringNegotiatedAlpn =
                    bodyStringTurn.readySnapshot.jinguiAttachResultSnapshot.negotiatedAlpn
                bodyStringRequestedServerName =
                    bodyStringTurn.readySnapshot.jinguiAttachResultSnapshot.requestedServerName
                bodyStringAttachSurface =
                    bodyStringTurn.readySnapshot.jinguiAttachResultSnapshot.attachSurface
                bodyStringTransportId =
                    bodyStringTurn.readySnapshot.transport.transportId
            } finally {
                if (!bodyStringAccepted.isClosed()) {
                    bodyStringAccepted.close()
                }
            }

            let bodyJsonAccepted = listener.accept()
            try {
                let bodyJsonTurn =
                    option.serveJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloLogicalRequest(
                        bodyJsonAccepted,
                        app,
                        ServerJinguiAcceptedTransportLogicalRequest(
                            "POST",
                            "/carrier-captured-logical-body-json",
                            bodyBytes: #"{"name":"ignite","val":23}"#.toArray()
                        ),
                        engineIncrementalBytes(32, start: 2624),
                        transportId: "captured-clienthello-logical-request-body-json-transport",
                        readChunkSize: 5,
                        maxFragmentLen: 8
                    )
                bodyJsonClientChannel = Some(
                    contractTls13CreateClientRecordChannel(
                        bodyJsonTurn.session.keyMaterial,
                        algorithm: bodyJsonTurn.session.recordChannel.algorithm
                    )
                )
                bodyJsonReadyStatus = bodyJsonTurn.readySnapshot.status
                bodyJsonResponseStatus = bodyJsonTurn.responseStatus
                bodyJsonContentType =
                    bodyJsonTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyJsonTransferEncoding =
                    bodyJsonTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyJsonSocketWriteCount = bodyJsonTurn.socketWriteCount
                bodyJsonNegotiatedAlpn =
                    bodyJsonTurn.readySnapshot.jinguiAttachResultSnapshot.negotiatedAlpn
                bodyJsonRequestedServerName =
                    bodyJsonTurn.readySnapshot.jinguiAttachResultSnapshot.requestedServerName
                bodyJsonAttachSurface =
                    bodyJsonTurn.readySnapshot.jinguiAttachResultSnapshot.attachSurface
                bodyJsonTransportId =
                    bodyJsonTurn.readySnapshot.transport.transportId
            } finally {
                if (!bodyJsonAccepted.isClosed()) {
                    bodyJsonAccepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloLogicalRequestRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                try {
                    let _ =
                        option.serveJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloLogicalRequest(
                            accepted,
                            app,
                            ServerJinguiAcceptedTransportLogicalRequest(
                                "GET",
                                "/captured-clienthello-logical-request-reject"
                            ),
                            engineIncrementalBytes(32, start: 2656),
                            transportId: "captured-clienthello-logical-request-reject-transport",
                            readChunkSize: 5,
                            maxFragmentLen: 8
                        )
                } catch (e: Exception) {
                    observedError = e.message
                }
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketApplicationDataFragmentedRecordWireHeadersPlusDataRequestTurnProbeEngine <: ServerEngine {
    public var bodyStringReadyStatus: String = ""
    public var bodyJsonReadyStatus: String = ""
    public var bodyStringResponseStatus: UInt16 = 0
    public var bodyJsonResponseStatus: UInt16 = 0
    public var bodyStringContentType: String = ""
    public var bodyJsonContentType: String = ""
    public var bodyStringTransferEncoding: String = ""
    public var bodyJsonTransferEncoding: String = ""
    public var bodyStringSocketWriteCount: Int64 = 0
    public var bodyJsonSocketWriteCount: Int64 = 0
    public var bodyStringRequestWireFragments: ?Array<Array<Byte>> = None
    public var bodyJsonRequestWireFragments: ?Array<Array<Byte>> = None
    var bodyStringClientChannel: ?ContractTlsRecordChannel = None
    var bodyJsonClientChannel: ?ContractTlsRecordChannel = None

    public func openBodyStringSocketWire(wire: Array<UInt8>): String {
        match (bodyStringClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected attach-taking fragmented headers-plus-data request-turn bodyString companion client record channel before socket wire open"
                )
        }
    }

    public func openBodyJsonSocketWire(wire: Array<UInt8>): String {
        match (bodyJsonClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected attach-taking fragmented headers-plus-data request-turn bodyJson companion client record channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let bodyStringAccepted = listener.accept()
            try {
                let bodyStringHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 2048)
                    )
                )
                let bodyStringServerKeyExchangePrivate =
                    engineIncrementalBytes(32, start: 2080)
                let bodyStringTransportId =
                    "attach-taking-fragmented-appdata-data-turn-body-string-transport"
                let bodyStringHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x26)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-data-turn-body-string".toArray()
                    )
                ])
                let bodyStringTurn =
                    option.serveJinguiAcceptedTransportSocketApplicationDataFragmentedRecordWireH2HeadersPlusDataRequestTurn(
                        bodyStringAccepted,
                        app,
                        bodyStringHello.encodedClientHello,
                        bodyStringServerKeyExchangePrivate,
                        transportId: bodyStringTransportId,
                        readChunkSize: 5,
                        maxFragmentLen: 8,
                        attachedSessionReadyHook: { session =>
                            let requestClientChannel =
                                contractTls13CreateClientRecordChannel(
                                    session.keyMaterial,
                                    algorithm: session.recordChannel.algorithm
                                )
                            let requestRecords =
                                requestClientChannel.sealFragments(
                                    ContractTlsRecordContentType.ApplicationData,
                                    concatServerEngineAbstractionTestByteArrays([
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            buildServerEngineAbstractionTestH2HeadersPayload(
                                                bodyStringHeaderBlock
                                            ),
                                            frameType: UInt8(0x1),
                                            flags: UInt8(0x4),
                                            streamId: 97
                                        ),
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            serverEngineAbstractionTestByteArray(
                                                "accepted-".toArray()
                                            ),
                                            frameType: UInt8(0x0),
                                            flags: UInt8(0x0),
                                            streamId: 97
                                        ),
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            serverEngineAbstractionTestByteArray(
                                                "appdata-body".toArray()
                                            ),
                                            frameType: UInt8(0x0),
                                            flags: UInt8(0x1),
                                            streamId: 97
                                        )
                                    ]),
                                    maxFragmentLen: 7
                                )
                            let encodedWire =
                                concatServerEngineAbstractionTestByteArrays(
                                    requestRecords
                                )
                            bodyStringRequestWireFragments = Some([
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    0,
                                    4
                                ),
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    4,
                                    encodedWire.size - 7
                                ),
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    encodedWire.size - 3,
                                    3
                                )
                            ])
                            bodyStringClientChannel = Some(
                                requestClientChannel
                            )
                        }
                    )
                bodyStringReadyStatus = bodyStringTurn.readySnapshot.status
                bodyStringResponseStatus = bodyStringTurn.responseStatus
                bodyStringContentType =
                    bodyStringTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyStringTransferEncoding =
                    bodyStringTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyStringSocketWriteCount = bodyStringTurn.socketWriteCount
            } finally {
                if (!bodyStringAccepted.isClosed()) {
                    bodyStringAccepted.close()
                }
            }

            let bodyJsonAccepted = listener.accept()
            try {
                let bodyJsonHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 2112)
                    )
                )
                let bodyJsonServerKeyExchangePrivate =
                    engineIncrementalBytes(32, start: 2144)
                let bodyJsonTransportId =
                    "attach-taking-fragmented-appdata-data-turn-body-json-transport"
                let bodyJsonHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x24)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-data-turn-body-json".toArray()
                    )
                ])
                let bodyJsonTurn =
                    option.serveJinguiAcceptedTransportSocketApplicationDataFragmentedRecordWireH2HeadersPlusDataRequestTurn(
                        bodyJsonAccepted,
                        app,
                        bodyJsonHello.encodedClientHello,
                        bodyJsonServerKeyExchangePrivate,
                        transportId: bodyJsonTransportId,
                        readChunkSize: 5,
                        maxFragmentLen: 8,
                        attachedSessionReadyHook: { session =>
                            let requestClientChannel =
                                contractTls13CreateClientRecordChannel(
                                    session.keyMaterial,
                                    algorithm: session.recordChannel.algorithm
                                )
                            let requestRecords =
                                requestClientChannel.sealFragments(
                                    ContractTlsRecordContentType.ApplicationData,
                                    concatServerEngineAbstractionTestByteArrays([
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            buildServerEngineAbstractionTestH2HeadersPayload(
                                                bodyJsonHeaderBlock
                                            ),
                                            frameType: UInt8(0x1),
                                            flags: UInt8(0x4),
                                            streamId: 99
                                        ),
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            serverEngineAbstractionTestByteArray(
                                                "{\"name\":\"ignite\",".toArray()
                                            ),
                                            frameType: UInt8(0x0),
                                            flags: UInt8(0x0),
                                            streamId: 99
                                        ),
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            serverEngineAbstractionTestByteArray(
                                                "\"val\":23}".toArray()
                                            ),
                                            frameType: UInt8(0x0),
                                            flags: UInt8(0x1),
                                            streamId: 99
                                        )
                                    ]),
                                    maxFragmentLen: 7
                                )
                            let encodedWire =
                                concatServerEngineAbstractionTestByteArrays(
                                    requestRecords
                                )
                            bodyJsonRequestWireFragments = Some([
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    0,
                                    4
                                ),
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    4,
                                    encodedWire.size - 7
                                ),
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    encodedWire.size - 3,
                                    3
                                )
                            ])
                            bodyJsonClientChannel = Some(
                                requestClientChannel
                            )
                        }
                    )
                bodyJsonReadyStatus = bodyJsonTurn.readySnapshot.status
                bodyJsonResponseStatus = bodyJsonTurn.responseStatus
                bodyJsonContentType =
                    bodyJsonTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyJsonTransferEncoding =
                    bodyJsonTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyJsonSocketWriteCount = bodyJsonTurn.socketWriteCount
            } finally {
                if (!bodyJsonAccepted.isClosed()) {
                    bodyJsonAccepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketApplicationDataFragmentedRecordWireHeadersPlusDataRequestTurnRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""
    public var requestWireFragments: ?Array<Array<Byte>> = None

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let clientHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 2176)
                    )
                )
                let serverKeyExchangePrivate =
                    engineIncrementalBytes(32, start: 2208)
                let transportId =
                    "attach-taking-fragmented-appdata-data-turn-reject-transport"
                let headerBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/one".toArray())
                ])
                try {
                    let _ =
                        option.serveJinguiAcceptedTransportSocketApplicationDataFragmentedRecordWireH2HeadersPlusDataRequestTurn(
                            accepted,
                            app,
                            clientHello.encodedClientHello,
                            serverKeyExchangePrivate,
                            transportId: transportId,
                            readChunkSize: 5,
                            maxFragmentLen: 8,
                            attachedSessionReadyHook: { session =>
                                let requestClientChannel =
                                    contractTls13CreateClientRecordChannel(
                                        session.keyMaterial,
                                        algorithm: session.recordChannel.algorithm
                                    )
                                let requestRecords =
                                    requestClientChannel.sealFragments(
                                        ContractTlsRecordContentType.ApplicationData,
                                        concatServerEngineAbstractionTestByteArrays([
                                            buildServerEngineAbstractionTestH2FrameWire(
                                                buildServerEngineAbstractionTestH2HeadersPayload(
                                                    headerBlock
                                                ),
                                                frameType: UInt8(0x1),
                                                flags: UInt8(0x4),
                                                streamId: 101
                                            ),
                                            buildServerEngineAbstractionTestH2FrameWire(
                                                serverEngineAbstractionTestByteArray(
                                                    "blocked".toArray()
                                                ),
                                                frameType: UInt8(0x0),
                                                flags: UInt8(0x1),
                                                streamId: 103
                                            )
                                        ]),
                                        maxFragmentLen: 7
                                    )
                                let encodedWire =
                                    concatServerEngineAbstractionTestByteArrays(
                                        requestRecords
                                    )
                                requestWireFragments = Some([
                                    cloneServerEngineByteWindow(
                                        encodedWire,
                                        0,
                                        4
                                    ),
                                    cloneServerEngineByteWindow(
                                        encodedWire,
                                        4,
                                        encodedWire.size - 7
                                    ),
                                    cloneServerEngineByteWindow(
                                        encodedWire,
                                        encodedWire.size - 3,
                                        3
                                    )
                                ])
                            }
                        )
                    @Fail(
                        "expected attach-taking fragmented-record-wire headers-plus-data request-turn rejection"
                    )
                } catch (e: Exception) {
                    observedError = e.message
                }
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportResponseTransportWriterProbeEngine <: ServerEngine {
    public var clientDecodedJson: String = ""
    public var encodedRecordCount: Int64 = 0
    public var totalEncodedBytes: Int64 = 0

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let transport = ContractAcceptedTransportDescriptor(
            "writer-accepted-transport",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55445"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 160))
        )
        let session = option.attachJinguiAcceptedTransportTls13X25519(
            transport,
            clientHello.encodedClientHello,
            engineIncrementalBytes(32, start: 192)
        )
        let clientChannel = contractTls13CreateClientRecordChannel(
            session.keyMaterial,
            algorithm: session.recordChannel.algorithm
        )
        let collector = CollectingResponseTransportWriter()
        let writer =
            option.openJinguiAcceptedTransportApplicationDataResponseTransportWriter(
                session,
                collector,
                maxFragmentLen: 8
            )
        let out = ResponseTransportOutputStream(writer)
        let jsonWriter = StdxJsonWriter(out)
        jsonWriter.startObject()
        jsonWriter.writeName("kind")
        jsonWriter.writeValue("response")
        jsonWriter.writeName("ok")
        jsonWriter.writeValue(true)
        jsonWriter.writeName("count")
        jsonWriter.writeValue(2)
        jsonWriter.endObject()
        jsonWriter.flush()

        encodedRecordCount = collector.writes.size
        for (record in collector.writes) {
            totalEncodedBytes += record.size
        }
        clientDecodedJson = String.fromUtf8(
            clientChannel.openAndReassemble(
                serverEngineAbstractionTestByteRecords(collector.writes)
            )
        )

        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportH2LifecycleApplicationDataWriterProbeEngine <: ServerEngine {
    public var successWriterOpenCalls: Int64 = 0
    public var successHandoffAcquisitionCount: Int64 = 0
    public var successSocketWriteCount: Int64 = 0
    public var successEncodedSocketBytes: Int64 = 0
    public var successEncodedRecordCount: Int64 = 0
    public var successDecodedFrameCount: Int64 = 0
    public var successFirstFrameType: UInt8 = 0
    public var successFirstFrameFlags: UInt8 = 0
    public var successSecondFrameType: UInt8 = 0
    public var successSecondFrameFlags: UInt8 = 0
    public var successFirstPayload: Array<Byte> = []
    public var successSecondPayload: Array<Byte> = []
    public var blockedRejected: Bool = false
    public var blockedWriterOpenCalls: Int64 = 0
    public var blockedEncodedRecordCount: Int64 = 0

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        runSuccessProbe(option)
        runBlockedProbe(option)
        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    func runSuccessProbe(option: ServerEngineListenOption): Unit {
        let transport = ContractAcceptedTransportDescriptor(
            "h2-lifecycle-appdata-success",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55448"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 448))
        )
        let session = option.attachJinguiAcceptedTransportTls13X25519(
            transport,
            clientHello.encodedClientHello,
            engineIncrementalBytes(32, start: 480)
        )
        let clientChannel = contractTls13CreateClientRecordChannel(
            session.keyMaterial,
            algorithm: session.recordChannel.algorithm
        )
        let collector = CollectingResponseTransportWriter()
        let lifecycle =
            ServerJinguiAcceptedTransportSocketResponseWriterLifecycle(
                { bytes => collector.write(bytes) }
            )
        let carrier =
            AcceptedTransportH2LifecycleApplicationDataProbeCarrier(
                "/h2-lifecycle-appdata-success",
                lifecycle,
                false
            )
        let wrappedCarrier =
            option.wrapCurrentRequestCarrierWithJinguiAcceptedTransportApplicationDataResponse(
                session,
                carrier,
                maxFragmentLen: 64
            )
        let model = JinguiAcceptedTransportH2FlowBudgetModel(20, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                serverEngineAbstractionTestTextBytes("s1")
            )
        )
        @Assert(queue.enqueueDataLengthWithEndStream(1, 8, true), 1)
        let firstChunk = queue.tryDrainHeadChunk(4)
        let secondChunk = queue.tryDrainHeadChunk(4)
        let handoff =
            JinguiAcceptedTransportH2AcceptedSocketResponseWriterHandoffGate(
                ServerJinguiAcceptedTransportDescriptorSnapshot(
                    "h2-lifecycle-appdata-success",
                    "accepted-socket",
                    "127.0.0.1:443",
                    "127.0.0.1:55448"
                ),
                wrappedCarrier
            )
        let _ =
            handoff.commitDataFrame(
                "accepted-socket-lifecycle-application-data-writer-probe",
                firstChunk,
                serverEngineAbstractionTestTextBytes("part")
            )
        let _ =
            handoff.commitDataFrame(
                "accepted-socket-lifecycle-application-data-writer-probe",
                secondChunk,
                serverEngineAbstractionTestTextBytes("done")
            )

        successWriterOpenCalls = carrier.openCalls
        successHandoffAcquisitionCount = handoff.acquisitionCount()
        successSocketWriteCount = lifecycle.socketWriteCount
        successEncodedSocketBytes = lifecycle.totalEncodedSocketBytes
        successEncodedRecordCount = collector.writes.size
        let decodedWire =
            clientChannel.openAndReassemble(
                serverEngineAbstractionTestByteRecords(collector.writes)
            )
        let frames = splitJinguiAcceptedTransportH2FrameWire(decodedWire)
        successDecodedFrameCount = frames.size
        let firstFrame = parseJinguiAcceptedTransportH2FrameWire(frames[0])
        let secondFrame = parseJinguiAcceptedTransportH2FrameWire(frames[1])
        successFirstFrameType = firstFrame.frameType
        successFirstFrameFlags = firstFrame.flags
        successSecondFrameType = secondFrame.frameType
        successSecondFrameFlags = secondFrame.flags
        successFirstPayload =
            cloneServerEngineAbstractionTestByteWindow(
                firstFrame.payload,
                0,
                firstFrame.payload.size
            )
        successSecondPayload =
            cloneServerEngineAbstractionTestByteWindow(
                secondFrame.payload,
                0,
                secondFrame.payload.size
            )
    }

    func runBlockedProbe(option: ServerEngineListenOption): Unit {
        let transport = ContractAcceptedTransportDescriptor(
            "h2-lifecycle-appdata-blocked",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55449"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 512))
        )
        let session = option.attachJinguiAcceptedTransportTls13X25519(
            transport,
            clientHello.encodedClientHello,
            engineIncrementalBytes(32, start: 544)
        )
        let collector = CollectingResponseTransportWriter()
        let lifecycle =
            ServerJinguiAcceptedTransportSocketResponseWriterLifecycle(
                { bytes => collector.write(bytes) }
            )
        let carrier =
            AcceptedTransportH2LifecycleApplicationDataProbeCarrier(
                "/h2-lifecycle-appdata-blocked",
                lifecycle,
                false
            )
        let wrappedCarrier =
            option.wrapCurrentRequestCarrierWithJinguiAcceptedTransportApplicationDataResponse(
                session,
                carrier,
                maxFragmentLen: 64
            )
        let model = JinguiAcceptedTransportH2FlowBudgetModel(3, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                serverEngineAbstractionTestTextBytes("s1")
            )
        )
        @Assert(queue.enqueueDataLengthWithEndStream(1, 4, true), 1)
        let blocked = queue.tryDrainHeadChunk(4)
        let handoff =
            JinguiAcceptedTransportH2AcceptedSocketResponseWriterHandoffGate(
                ServerJinguiAcceptedTransportDescriptorSnapshot(
                    "h2-lifecycle-appdata-blocked",
                    "accepted-socket",
                    "127.0.0.1:443",
                    "127.0.0.1:55449"
                ),
                wrappedCarrier
            )
        try {
            let _ =
                handoff.commitDataFrame(
                    "accepted-socket-lifecycle-application-data-writer-probe",
                    blocked,
                    serverEngineAbstractionTestTextBytes("wait")
                )
        } catch (_: Exception) {
            blockedRejected = true
        }
        blockedWriterOpenCalls = carrier.openCalls
        blockedEncodedRecordCount = collector.writes.size
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportH2ApplicationDataFailureCloseGuardProbeEngine <: ServerEngine {
    public var failureRejected: Bool = false
    public var failureMessage: String = ""
    public var failureWriterOpenCalls: Int64 = 0
    public var failureHandoffAcquisitionCount: Int64 = 0
    public var failureSocketWriteCount: Int64 = 0
    public var failureSinkAttempts: Int64 = 0
    public var failureAttemptedEncodedBytes: Int64 = 0
    public var failureLifecycleClosed: Bool = true
    public var closeGuardFirstCompleted: Bool = false
    public var closeGuardRejected: Bool = false
    public var closeGuardMessage: String = ""
    public var closeGuardWriterOpenCalls: Int64 = 0
    public var closeGuardHandoffAcquisitionCount: Int64 = 0
    public var closeGuardSocketWriteCount: Int64 = 0
    public var closeGuardEncodedRecordCount: Int64 = 0
    public var closeGuardLifecycleClosed: Bool = false
    public var closeGuardCloseReason: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        runFailureProbe(option)
        runCloseGuardProbe(option)
        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    func runFailureProbe(option: ServerEngineListenOption): Unit {
        let transport = ContractAcceptedTransportDescriptor(
            "h2-appdata-failure-guard",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55450"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 576))
        )
        let session = option.attachJinguiAcceptedTransportTls13X25519(
            transport,
            clientHello.encodedClientHello,
            engineIncrementalBytes(32, start: 608)
        )
        let lifecycle =
            ServerJinguiAcceptedTransportSocketResponseWriterLifecycle(
                { bytes =>
                    failureSinkAttempts += 1
                    failureAttemptedEncodedBytes += bytes.size
                    throw Exception(
                        "sr107 tls application-data downstream write failed"
                    )
                }
            )
        let carrier =
            AcceptedTransportH2LifecycleApplicationDataProbeCarrier(
                "/h2-appdata-failure-guard",
                lifecycle,
                false
            )
        let wrappedCarrier =
            option.wrapCurrentRequestCarrierWithJinguiAcceptedTransportApplicationDataResponse(
                session,
                carrier,
                maxFragmentLen: 64
            )
        let model = JinguiAcceptedTransportH2FlowBudgetModel(16, 16)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                serverEngineAbstractionTestTextBytes("s1")
            )
        )
        @Assert(queue.enqueueDataLengthWithEndStream(1, 4, true), 1)
        let chunk = queue.tryDrainHeadChunk(4)
        let handoff =
            JinguiAcceptedTransportH2AcceptedSocketResponseWriterHandoffGate(
                ServerJinguiAcceptedTransportDescriptorSnapshot(
                    "h2-appdata-failure-guard",
                    "accepted-socket",
                    "127.0.0.1:443",
                    "127.0.0.1:55450"
                ),
                wrappedCarrier
            )
        try {
            let _ =
                handoff.commitDataFrame(
                    "accepted-socket-lifecycle-application-data-sr107",
                    chunk,
                    serverEngineAbstractionTestTextBytes("fail")
                )
        } catch (e: Exception) {
            failureRejected = true
            failureMessage = e.message
        }
        failureWriterOpenCalls = carrier.openCalls
        failureHandoffAcquisitionCount = handoff.acquisitionCount()
        failureSocketWriteCount = lifecycle.socketWriteCount
        failureLifecycleClosed = lifecycle.closed
    }

    func runCloseGuardProbe(option: ServerEngineListenOption): Unit {
        let transport = ContractAcceptedTransportDescriptor(
            "h2-appdata-close-guard",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55451"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 640))
        )
        let session = option.attachJinguiAcceptedTransportTls13X25519(
            transport,
            clientHello.encodedClientHello,
            engineIncrementalBytes(32, start: 672)
        )
        let collector = CollectingResponseTransportWriter()
        let lifecycle =
            ServerJinguiAcceptedTransportSocketResponseWriterLifecycle(
                { bytes => collector.write(bytes) }
            )
        let carrier =
            AcceptedTransportH2LifecycleApplicationDataProbeCarrier(
                "/h2-appdata-close-guard",
                lifecycle,
                false
            )
        let wrappedCarrier =
            option.wrapCurrentRequestCarrierWithJinguiAcceptedTransportApplicationDataResponse(
                session,
                carrier,
                maxFragmentLen: 64
            )
        let model = JinguiAcceptedTransportH2FlowBudgetModel(16, 16)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                serverEngineAbstractionTestTextBytes("s1")
            )
        )
        @Assert(queue.enqueueDataLengthWithEndStream(1, 8, true), 1)
        let firstChunk = queue.tryDrainHeadChunk(4)
        let secondChunk = queue.tryDrainHeadChunk(4)
        let handoff =
            JinguiAcceptedTransportH2AcceptedSocketResponseWriterHandoffGate(
                ServerJinguiAcceptedTransportDescriptorSnapshot(
                    "h2-appdata-close-guard",
                    "accepted-socket",
                    "127.0.0.1:443",
                    "127.0.0.1:55451"
                ),
                wrappedCarrier
            )
        let first =
            handoff.commitDataFrame(
                "accepted-socket-lifecycle-application-data-sr107",
                firstChunk,
                serverEngineAbstractionTestTextBytes("open")
            )
        closeGuardFirstCompleted = first.completed
        lifecycle.closeResponseWriterLifecycle(reason: "sr107-close")
        try {
            let _ =
                handoff.commitDataFrame(
                    "accepted-socket-lifecycle-application-data-sr107",
                    secondChunk,
                    serverEngineAbstractionTestTextBytes("shut")
                )
        } catch (e: Exception) {
            closeGuardRejected = true
            closeGuardMessage = e.message
        }
        closeGuardWriterOpenCalls = carrier.openCalls
        closeGuardHandoffAcquisitionCount = handoff.acquisitionCount()
        closeGuardSocketWriteCount = lifecycle.socketWriteCount
        closeGuardEncodedRecordCount = collector.writes.size
        closeGuardLifecycleClosed = lifecycle.closed
        closeGuardCloseReason = lifecycle.closeReason
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportH2ApplicationDataResponseWriterTurnProbeEngine <: ServerEngine {
    let turnRequestUrl: String
    let turnStreamId: Int64
    let responseInitialConnectionSendBudget: ?Int64
    let responseInitialStreamSendBudget: ?Int64
    let responseWindowUpdateFramesBeforeRetry:
        Array<JinguiAcceptedTransportH2FrameWireSnapshot>
    let requestPeerWindowUpdateFrames:
        Array<JinguiAcceptedTransportH2FrameWireSnapshot>
    let responseWindowUpdateFramesFromPoll:
        Array<JinguiAcceptedTransportH2FrameWireSnapshot>
    let enableResponseWindowUpdatePoller: Bool
    let enableSocketBackedResponseWindowUpdatePoller: Bool
    let socketBackedResponseWindowUpdateFrames:
        Array<JinguiAcceptedTransportH2FrameWireSnapshot>
    let socketBackedResponseWindowUpdatePollReadChunkSize: Int64
    let socketBackedResponseWindowUpdatePollMaxReadAttempts: Int64
    let responseWindowUpdateMaxPollAttempts: Int64
    public var turnReadyStatus: String = ""
    public var turnResponseStatus: UInt16 = 0
    public var turnContentType: String = ""
    public var turnCustomHeader: String = ""
    public var turnSocketWriteCount: Int64 = 0
    public var turnDecodedFrameCount: Int64 = 0
    public var turnHeadersFrameType: UInt8 = 0
    public var turnHeadersEndHeaders: Bool = false
    public var turnHeadersEndStream: Bool = false
    public var turnHeadersFrameStreamId: Int64 = 0
    public var turnHeadersFirstName: String = ""
    public var turnHeadersStatus: String = ""
    public var turnHeadersStatusStaticIndex: Int64 = 0
    public var turnHeadersPseudoFieldCount: Int64 = 0
    public var turnHeadersUnexpectedPseudoFieldSeen: Bool = false
    public var turnHeadersCacheControl: String = ""
    public var turnHeadersCacheControlNameStaticIndex: Int64 = 0
    public var turnHeadersContentLength: String = ""
    public var turnHeadersContentLengthNameStaticIndex: Int64 = 0
    public var turnHeadersContentType: String = ""
    public var turnHeadersContentTypeNameStaticIndex: Int64 = 0
    public var turnHeadersCustomHeader: String = ""
    public var turnHeadersExtraHeader: String = ""
    public var turnHeadersExtraHeaderNameStaticIndex: Int64 = 0
    public var turnHeadersRepeatHeaderCount: Int64 = 0
    public var turnHeadersRepeatHeaderFirst: String = ""
    public var turnHeadersRepeatHeaderSecond: String = ""
    public var turnHeadersServer: String = ""
    public var turnHeadersServerNameStaticIndex: Int64 = 0
    public var turnHeadersConnectionHeaderSeen: Bool = false
    public var turnHeadersKeepAliveHeaderSeen: Bool = false
    public var turnHeadersProxyConnectionHeaderSeen: Bool = false
    public var turnHeadersTransferEncodingHeaderSeen: Bool = false
    public var turnHeadersUpgradeHeaderSeen: Bool = false
    public var turnHeadersTeHeaderSeen: Bool = false
    public var turnDataFrameSeen: Bool = false
    public var turnDataFrameCount: Int64 = 0
    public var turnFrameType: UInt8 = 0
    public var turnFrameEndStream: Bool = false
    public var turnFrameStreamId: Int64 = 0
    public var turnFramePayload: Array<Byte> = []
    public var turnDataPayload: Array<Byte> = []
    public var turnExtraHeader: String = ""
    public var responseWindowUpdatePollCalls: Int64 = 0
    public var turnSchedulerOwner: String = ""
    public var turnSchedulerResponseWriterOwner: String = ""
    public var turnSchedulerPeerControlReadOwner: String = ""
    public var turnSchedulerStreamId: Int64 = 0
    public var turnSchedulerQueuedBodyWriteCount: Int64 = 0
    public var turnSchedulerQueuedBodyByteCount: Int64 = 0
    public var turnSchedulerWriteAttemptCount: Int64 = 0
    public var turnSchedulerPeerControlPollRoundCount: Int64 = 0
    public var turnSchedulerObservedWindowUpdateFrameCount: Int64 = 0
    public var turnSchedulerRecoveryRoundCount: Int64 = 0
    public var turnSchedulerRequestWindowUpdateFrameCount: Int64 = 0
    public var turnSchedulerExplicitWindowUpdateFrameCount: Int64 = 0
    public var turnSchedulerPolledWindowUpdateFrameCount: Int64 = 0
    public var turnSchedulerPollerAttemptCount: Int64 = 0
    public var turnSchedulerCommittedBodyWriteCount: Int64 = 0
    public var turnSchedulerCommittedBodyByteCount: Int64 = 0
    public var turnSchedulerCommittedDataFrameCount: Int64 = 0
    public var turnSchedulerRemainingBodyByteCount: Int64 = 0
    public var turnSchedulerCompleted: Bool = false
    public var turnSchedulerCloseReason: String = ""
    public var turnRuntimeProgressAccepted: Bool = false
    public var turnRuntimeProofContinuationAllowed: Bool = false
    public var turnRuntimeClosureClaimAllowed: Bool = false
    public var turnRuntimeProgressStatus: String = ""
    public var turnRuntimeProgressDecision: String = ""
    public var turnRuntimeProgressBlockerCount: Int64 = 0
    public var turnRuntimeProgressFirstBlocker: String = ""
    public var turnRuntimeProgressNextAction: String = ""
    public var turnRejected: Bool = false
    public var turnRejectMessage: String = ""
    public var socketBackedWindowUpdateWireFragments:
        ?Array<Array<Byte>> = None
    var turnClientChannel: ?ContractTlsRecordChannel = None

    public init(
        turnRequestUrl!: String = "/h2-appdata-response-turn?mode=data",
        streamId!: Int64 = 83,
        responseInitialConnectionSendBudget!: ?Int64 = None,
        responseInitialStreamSendBudget!: ?Int64 = None,
        responseWindowUpdateFramesBeforeRetry!:
            Array<JinguiAcceptedTransportH2FrameWireSnapshot> = [],
        requestPeerWindowUpdateFrames!:
            Array<JinguiAcceptedTransportH2FrameWireSnapshot> = [],
        responseWindowUpdateFramesFromPoll!:
            Array<JinguiAcceptedTransportH2FrameWireSnapshot> = [],
        enableResponseWindowUpdatePoller!: Bool = true,
        enableSocketBackedResponseWindowUpdatePoller!: Bool = false,
        socketBackedResponseWindowUpdateFrames!:
            Array<JinguiAcceptedTransportH2FrameWireSnapshot> = [],
        socketBackedResponseWindowUpdatePollReadChunkSize!: Int64 = 64,
        socketBackedResponseWindowUpdatePollMaxReadAttempts!: Int64 = 1,
        responseWindowUpdateMaxPollAttempts!: Int64 = 1
    ) {
        this.turnRequestUrl = turnRequestUrl
        this.turnStreamId = streamId
        this.responseInitialConnectionSendBudget =
            responseInitialConnectionSendBudget
        this.responseInitialStreamSendBudget =
            responseInitialStreamSendBudget
        this.responseWindowUpdateFramesBeforeRetry =
            responseWindowUpdateFramesBeforeRetry
        this.requestPeerWindowUpdateFrames =
            requestPeerWindowUpdateFrames
        this.responseWindowUpdateFramesFromPoll =
            responseWindowUpdateFramesFromPoll
        this.enableResponseWindowUpdatePoller =
            enableResponseWindowUpdatePoller
        this.enableSocketBackedResponseWindowUpdatePoller =
            enableSocketBackedResponseWindowUpdatePoller
        this.socketBackedResponseWindowUpdateFrames =
            socketBackedResponseWindowUpdateFrames
        this.socketBackedResponseWindowUpdatePollReadChunkSize =
            socketBackedResponseWindowUpdatePollReadChunkSize
        this.socketBackedResponseWindowUpdatePollMaxReadAttempts =
            socketBackedResponseWindowUpdatePollMaxReadAttempts
        this.responseWindowUpdateMaxPollAttempts =
            responseWindowUpdateMaxPollAttempts
    }

    func recordTurnSchedulerSnapshot(
        trace: JinguiAcceptedTransportH2ResponseTurnSchedulerTrace
    ): Unit {
        let schedulerSnapshot = trace.snapshot()
        turnSchedulerOwner = schedulerSnapshot.schedulerOwner
        turnSchedulerResponseWriterOwner =
            schedulerSnapshot.responseWriterOwner
        turnSchedulerPeerControlReadOwner =
            schedulerSnapshot.peerControlReadOwner
        turnSchedulerStreamId = schedulerSnapshot.streamId
        turnSchedulerQueuedBodyWriteCount =
            schedulerSnapshot.queuedBodyWriteCount
        turnSchedulerQueuedBodyByteCount =
            schedulerSnapshot.queuedBodyByteCount
        turnSchedulerWriteAttemptCount =
            schedulerSnapshot.writeAttemptCount
        turnSchedulerPeerControlPollRoundCount =
            schedulerSnapshot.peerControlPollRoundCount
        turnSchedulerObservedWindowUpdateFrameCount =
            schedulerSnapshot.observedWindowUpdateFrameCount
        turnSchedulerRecoveryRoundCount =
            schedulerSnapshot.recoveryRoundCount
        turnSchedulerRequestWindowUpdateFrameCount =
            schedulerSnapshot.requestWindowUpdateFrameCount
        turnSchedulerExplicitWindowUpdateFrameCount =
            schedulerSnapshot.explicitWindowUpdateFrameCount
        turnSchedulerPolledWindowUpdateFrameCount =
            schedulerSnapshot.polledWindowUpdateFrameCount
        turnSchedulerPollerAttemptCount =
            schedulerSnapshot.pollerAttemptCount
        turnSchedulerCommittedBodyWriteCount =
            schedulerSnapshot.committedBodyWriteCount
        turnSchedulerCommittedBodyByteCount =
            schedulerSnapshot.committedBodyByteCount
        turnSchedulerCommittedDataFrameCount =
            schedulerSnapshot.committedDataFrameCount
        turnSchedulerRemainingBodyByteCount =
            schedulerSnapshot.remainingBodyByteCount
        turnSchedulerCompleted = schedulerSnapshot.completed
        turnSchedulerCloseReason = schedulerSnapshot.closeReason
        let progressReadout =
            buildJinguiAcceptedTransportH2RuntimeProgressReadout(
                schedulerSnapshot
            )
        turnRuntimeProgressAccepted =
            progressReadout.responseTurnProgressAccepted
        turnRuntimeProofContinuationAllowed =
            progressReadout.h2RuntimeProofContinuationAllowed
        turnRuntimeClosureClaimAllowed =
            progressReadout.h2RuntimeClosureClaimAllowed
        turnRuntimeProgressStatus = progressReadout.status
        turnRuntimeProgressDecision = progressReadout.decision
        turnRuntimeProgressBlockerCount = progressReadout.blockers.size
        turnRuntimeProgressFirstBlocker =
            if (progressReadout.blockers.size > 0) {
                progressReadout.blockers[0]
            } else {
                ""
            }
        turnRuntimeProgressNextAction = progressReadout.nextAction
    }

    public func decodeTurnSocketWire(wire: Array<UInt8>): Unit {
        match (turnClientChannel) {
            case Some(channel) =>
                let decodedWire =
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                let frames = splitJinguiAcceptedTransportH2FrameWire(decodedWire)
                turnDecodedFrameCount = frames.size
                let headersFrame =
                    parseJinguiAcceptedTransportH2FrameWire(frames[0])
                let headersFragment =
                    parseJinguiAcceptedTransportH2HeaderBlockFragment(
                        headersFrame
                    )
                let headerBlock =
                    JinguiAcceptedTransportH2HeaderBlockSnapshot(
                        headersFrame.streamId,
                        headersFragment.endStream,
                        headersFragment.padded,
                        headersFragment.priorityPresented,
                        headersFragment.exclusiveDependency,
                        headersFragment.streamDependency,
                        headersFragment.weight,
                        headersFragment.headerBlockFragment
                    )
                let headerFields =
                    parseJinguiAcceptedTransportH2HeaderFields(headerBlock)
                var headerFieldIndex: Int64 = 0
                for (field in headerFields) {
                    if (headerFieldIndex == 0) {
                        turnHeadersFirstName = field.name
                    }
                    if (field.name.startsWith(":")) {
                        turnHeadersPseudoFieldCount += 1
                        if (field.name != ":status") {
                            turnHeadersUnexpectedPseudoFieldSeen = true
                        }
                    }
                    if (field.name == ":status") {
                        turnHeadersStatus = field.value
                        turnHeadersStatusStaticIndex = field.staticIndex
                    }
                    if (field.name == "cache-control") {
                        turnHeadersCacheControl = field.value
                        turnHeadersCacheControlNameStaticIndex =
                            field.nameStaticIndex
                    }
                    if (field.name == "content-length") {
                        turnHeadersContentLength = field.value
                        turnHeadersContentLengthNameStaticIndex =
                            field.nameStaticIndex
                    }
                    if (field.name == "content-type") {
                        turnHeadersContentType = field.value
                        turnHeadersContentTypeNameStaticIndex =
                            field.nameStaticIndex
                    }
                    if (field.name == "x-h2-turn") {
                        turnHeadersCustomHeader = field.value
                    }
                    if (field.name == "x-h2-extra") {
                        turnHeadersExtraHeader = field.value
                        turnHeadersExtraHeaderNameStaticIndex =
                            field.nameStaticIndex
                    }
                    if (field.name == "x-h2-repeat") {
                        turnHeadersRepeatHeaderCount += 1
                        if (turnHeadersRepeatHeaderCount == 1) {
                            turnHeadersRepeatHeaderFirst = field.value
                        } else if (turnHeadersRepeatHeaderCount == 2) {
                            turnHeadersRepeatHeaderSecond = field.value
                        }
                    }
                    if (field.name == "server") {
                        turnHeadersServer = field.value
                        turnHeadersServerNameStaticIndex =
                            field.nameStaticIndex
                    }
                    if (field.name == "connection") {
                        turnHeadersConnectionHeaderSeen = true
                    }
                    if (field.name == "keep-alive") {
                        turnHeadersKeepAliveHeaderSeen = true
                    }
                    if (field.name == "proxy-connection") {
                        turnHeadersProxyConnectionHeaderSeen = true
                    }
                    if (field.name == "transfer-encoding") {
                        turnHeadersTransferEncodingHeaderSeen = true
                    }
                    if (field.name == "upgrade") {
                        turnHeadersUpgradeHeaderSeen = true
                    }
                    if (field.name == "te") {
                        turnHeadersTeHeaderSeen = true
                    }
                    headerFieldIndex += 1
                }
                turnHeadersFrameType = headersFrame.frameType
                turnHeadersEndHeaders = headersFragment.endHeaders
                turnHeadersEndStream = headersFragment.endStream
                turnHeadersFrameStreamId = headersFrame.streamId
                let joinedPayload = ArrayList<Byte>()
                var dataFrameIndex: Int64 = 1
                while (dataFrameIndex < frames.size) {
                    let frame =
                        parseJinguiAcceptedTransportH2FrameWire(
                            frames[dataFrameIndex]
                        )
                    if (frame.frameType == UInt8(0x0)) {
                        let dataFrame =
                            parseJinguiAcceptedTransportH2DataFrame(frame)
                        if (!turnDataFrameSeen) {
                            turnDataFrameSeen = true
                            turnFrameType = frame.frameType
                            turnFramePayload =
                                cloneServerEngineAbstractionTestByteWindow(
                                    dataFrame.dataBytes,
                                    0,
                                    dataFrame.dataBytes.size
                                )
                        }
                        turnDataFrameCount += 1
                        turnFrameEndStream = dataFrame.endStream
                        turnFrameStreamId = frame.streamId
                        for (b in dataFrame.dataBytes) {
                            joinedPayload.add(b)
                        }
                    }
                    dataFrameIndex += 1
                }
                turnDataPayload = joinedPayload.toArray()
            case None =>
                throw Exception(
                    "expected SR108 turn companion client record channel before socket wire decode"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let clientHello = contractTls13BuildHttpClientHelloX25519(
                "www.example.com",
                alpnProtocols: ["h2", "http/1.1"],
                clientPrivateKey: Some(
                    engineIncrementalBytes(32, start: 704)
                )
            )
            let useSocketBackedResponseWindowUpdatePoller =
                enableSocketBackedResponseWindowUpdatePoller ||
                (
                    !enableResponseWindowUpdatePoller &&
                    responseWindowUpdateFramesFromPoll.size > 0
                )
            var socketBackedPreparedSession:
                ?ContractHttpServerAcceptedTransportSession = None
            if (useSocketBackedResponseWindowUpdatePoller) {
                let preTransport = ContractAcceptedTransportDescriptor(
                    "h2-appdata-response-turn-transport-prepared",
                    localEndpoint: "127.0.0.1:443",
                    remoteEndpoint: "127.0.0.1:55470"
                )
                let preSession =
                    option.attachJinguiAcceptedTransportTls13X25519(
                        preTransport,
                        clientHello.encodedClientHello,
                        engineIncrementalBytes(32, start: 736)
                    )
                socketBackedPreparedSession = Some(preSession)
                let preClientChannel =
                    contractTls13CreateClientRecordChannel(
                        preSession.keyMaterial,
                        algorithm: preSession.recordChannel.algorithm
                    )
                turnClientChannel = Some(preClientChannel)
                let preFrameWires = ArrayList<Array<Byte>>()
                let preSocketBackedFrames =
                    if (socketBackedResponseWindowUpdateFrames.size > 0) {
                        socketBackedResponseWindowUpdateFrames
                    } else {
                        responseWindowUpdateFramesFromPoll
                    }
                for (frame in preSocketBackedFrames) {
                    preFrameWires.add(
                        buildServerEngineAbstractionTestH2FrameWire(
                            frame.payload,
                            frameType: frame.frameType,
                            flags: frame.flags,
                            streamId: frame.streamId
                        )
                    )
                }
                socketBackedWindowUpdateWireFragments = Some(
                    preClientChannel.sealFragments(
                        ContractTlsRecordContentType.ApplicationData,
                        concatServerEngineAbstractionTestByteArrays(
                            preFrameWires.toArray()
                        ),
                        maxFragmentLen: 7
                    )
                )
            }

            let accepted = listener.accept()
            var schedulerTraceForTurn:
                ?JinguiAcceptedTransportH2ResponseTurnSchedulerTrace = None
            try {
                var responseWindowUpdateFramePoller:
                    ?JinguiAcceptedTransportH2PeerControlFramePoller = None
                if (
                    !useSocketBackedResponseWindowUpdatePoller &&
                    enableResponseWindowUpdatePoller
                ) {
                    responseWindowUpdateFramePoller = Some({ =>
                        responseWindowUpdatePollCalls += 1
                        responseWindowUpdateFramesFromPoll
                    })
                }
                let logicalRequest =
                    ServerJinguiAcceptedTransportLogicalRequest(
                        "GET",
                        turnRequestUrl,
                        streamId: turnStreamId,
                        peerWindowUpdateFrames:
                            requestPeerWindowUpdateFrames
                    )
                let schedulerTrace =
                    JinguiAcceptedTransportH2ResponseTurnSchedulerTrace(
                        turnStreamId
                    )
                schedulerTraceForTurn = Some(schedulerTrace)
                let turn = if (useSocketBackedResponseWindowUpdatePoller) {
                        let session = match (socketBackedPreparedSession) {
                            case Some(preparedSession) => preparedSession
                            case None =>
                                throw Exception(
                                    "expected prepared socket-backed H2 session"
                                )
                        }
                        let socketBackedPoller =
                            option.buildJinguiAcceptedTransportH2SocketPeerWindowUpdateFramePoller(
                                session,
                                accepted,
                                turnStreamId,
                                readChunkSize:
                                    socketBackedResponseWindowUpdatePollReadChunkSize,
                                maxReadAttempts:
                                    socketBackedResponseWindowUpdatePollMaxReadAttempts
                            )
                        responseWindowUpdateFramePoller = Some({ =>
                            responseWindowUpdatePollCalls += 1
                            socketBackedPoller()
                        })
                        option.serveJinguiAcceptedTransportSessionLogicalRequestH2DataResponseTurn(
                            session,
                            accepted,
                            app,
                            logicalRequest,
                            maxFragmentLen: 8,
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
                            responseSchedulerTrace: Some(schedulerTrace)
                        )
                    } else {
                        option.serveJinguiAcceptedTransportSocketLogicalRequestH2DataResponseTurn(
                            accepted,
                            app,
                            logicalRequest,
                            clientHello.encodedClientHello,
                            engineIncrementalBytes(32, start: 736),
                            transportId: "h2-appdata-response-turn-transport",
                            maxFragmentLen: 8,
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
                            responseSchedulerTrace: Some(schedulerTrace)
                        )
                    }
                recordTurnSchedulerSnapshot(schedulerTrace)
                match (turnClientChannel) {
                    case Some(_) => ()
                    case None =>
                        turnClientChannel = Some(
                            contractTls13CreateClientRecordChannel(
                                turn.session.keyMaterial,
                                algorithm: turn.session.recordChannel.algorithm
                            )
                        )
                }
                turnReadyStatus = turn.readySnapshot.status
                turnResponseStatus = turn.responseStatus
                turnContentType =
                    turn.responseHeaders.getFirst("content-type") ?? ""
                turnCustomHeader =
                    turn.responseHeaders.getFirst("x-h2-turn") ?? ""
                turnExtraHeader =
                    turn.responseHeaders.getFirst("x-h2-extra") ?? ""
                turnSocketWriteCount = turn.socketWriteCount
            } catch (e: Exception) {
                match (schedulerTraceForTurn) {
                    case Some(trace) => recordTurnSchedulerSnapshot(trace)
                    case None => ()
                }
                turnRejected = true
                turnRejectMessage = e.message
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportResponseCarrierProbeEngine <: ServerEngine {
    public var jsonWriteDecodedJson: String = ""
    public var jsonStreamDecodedJson: String = ""
    public var jsonWriteEncodedRecordCount: Int64 = 0
    public var jsonStreamEncodedRecordCount: Int64 = 0
    public var jsonWriteResponseStatus: UInt16 = 0
    public var jsonStreamResponseStatus: UInt16 = 0
    public var jsonWriteContentType: String = ""
    public var jsonStreamContentType: String = ""
    public var jsonWriteTransferEncoding: String = ""
    public var jsonStreamTransferEncoding: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let jsonWriteTransport = ContractAcceptedTransportDescriptor(
            "carrier-json-write-transport",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55446"
        )
        let jsonWriteHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 224))
        )
        let jsonWriteSession = option.attachJinguiAcceptedTransportTls13X25519(
            jsonWriteTransport,
            jsonWriteHello.encodedClientHello,
            engineIncrementalBytes(32, start: 256)
        )
        let jsonWriteClientChannel = contractTls13CreateClientRecordChannel(
            jsonWriteSession.keyMaterial,
            algorithm: jsonWriteSession.recordChannel.algorithm
        )
        let jsonWriteCarrier = AcceptedTransportResponseProbeCarrier(
            "/carrier-json-write"
        )
        let wrappedJsonWriteCarrier =
            option.wrapCurrentRequestCarrierWithJinguiAcceptedTransportApplicationDataResponse(
                jsonWriteSession,
                jsonWriteCarrier,
                maxFragmentLen: 8
            )
        app.handleRequest(wrappedJsonWriteCarrier)
        jsonWriteEncodedRecordCount = jsonWriteCarrier.writer.writes.size
        jsonWriteDecodedJson = String.fromUtf8(
            jsonWriteClientChannel.openAndReassemble(
                serverEngineAbstractionTestByteRecords(
                    jsonWriteCarrier.writer.writes
                )
            )
        )
        jsonWriteResponseStatus = jsonWriteCarrier.responseStatus
        jsonWriteContentType =
            jsonWriteCarrier.responseHeaders.getFirst("content-type") ?? ""
        jsonWriteTransferEncoding =
            jsonWriteCarrier.responseHeaders.getFirst("transfer-encoding") ?? ""

        let jsonStreamTransport = ContractAcceptedTransportDescriptor(
            "carrier-json-stream-transport",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55447"
        )
        let jsonStreamHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 288))
        )
        let jsonStreamSession =
            option.attachJinguiAcceptedTransportTls13X25519(
                jsonStreamTransport,
                jsonStreamHello.encodedClientHello,
                engineIncrementalBytes(32, start: 320)
            )
        let jsonStreamClientChannel = contractTls13CreateClientRecordChannel(
            jsonStreamSession.keyMaterial,
            algorithm: jsonStreamSession.recordChannel.algorithm
        )
        let jsonStreamCarrier = AcceptedTransportResponseProbeCarrier(
            "/carrier-json-stream"
        )
        let wrappedJsonStreamCarrier =
            option.wrapCurrentRequestCarrierWithJinguiAcceptedTransportApplicationDataResponse(
                jsonStreamSession,
                jsonStreamCarrier,
                maxFragmentLen: 8
            )
        app.handleRequest(wrappedJsonStreamCarrier)
        jsonStreamEncodedRecordCount = jsonStreamCarrier.writer.writes.size
        jsonStreamDecodedJson = String.fromUtf8(
            jsonStreamClientChannel.openAndReassemble(
                serverEngineAbstractionTestByteRecords(
                    jsonStreamCarrier.writer.writes
                )
            )
        )
        jsonStreamResponseStatus = jsonStreamCarrier.responseStatus
        jsonStreamContentType =
            jsonStreamCarrier.responseHeaders.getFirst("content-type") ?? ""
        jsonStreamTransferEncoding =
            jsonStreamCarrier.responseHeaders.getFirst("transfer-encoding") ?? ""

        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportResponseSocketSinkProbeEngine <: ServerEngine {
    public var responseStatus: UInt16 = 0
    public var responseContentType: String = ""
    public var responseTransferEncoding: String = ""
    public var responseCustomHeader: String = ""
    public var responseSocketWriteCount: Int64 = 0
    public var totalEncodedSocketBytes: Int64 = 0
    var clientChannel: ?ContractTlsRecordChannel = None

    public func openClientSocketRecordWire(record: Array<UInt8>): String {
        match (clientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openApplicationData(
                        serverEngineAbstractionTestByteArray(record)
                    )
                )
            case None =>
                throw Exception(
                    "expected client record channel before opening socket write sink response"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }
            let accepted = listener.accept()
            try {
                let transport = ContractAcceptedTransportDescriptor(
                    "carrier-json-socket-sink-transport",
                    localEndpoint: accepted.localAddress.toString(),
                    remoteEndpoint: accepted.remoteAddress.toString()
                )
                let clientHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 352)
                    )
                )
                let session =
                    option.attachJinguiAcceptedTransportTls13X25519(
                        transport,
                        clientHello.encodedClientHello,
                        engineIncrementalBytes(32, start: 384)
                    )
                clientChannel = Some(
                    contractTls13CreateClientRecordChannel(
                        session.keyMaterial,
                        algorithm: session.recordChannel.algorithm
                    )
                )
                let carrier = AcceptedTransportResponseSocketSinkProbeCarrier(
                    "/carrier-json-socket-sink",
                    accepted
                )
                let wrappedCarrier =
                    option.wrapCurrentRequestCarrierWithJinguiAcceptedTransportApplicationDataResponse(
                        session,
                        carrier
                    )
                app.handleRequest(wrappedCarrier)
                responseStatus = carrier.responseStatus
                responseContentType =
                    carrier.responseHeaders.getFirst("content-type") ?? ""
                responseTransferEncoding =
                    carrier.responseHeaders.getFirst("transfer-encoding") ?? ""
                responseCustomHeader =
                    carrier.responseHeaders.getFirst("x-carrier-sink") ?? ""
                responseSocketWriteCount = carrier.socketWriteCount
                totalEncodedSocketBytes = carrier.totalEncodedSocketBytes
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportResponseSocketWireProbeEngine <: ServerEngine {
    public var jsonWriteResponseStatus: UInt16 = 0
    public var jsonStreamResponseStatus: UInt16 = 0
    public var jsonWriteContentType: String = ""
    public var jsonStreamContentType: String = ""
    public var jsonWriteTransferEncoding: String = ""
    public var jsonStreamTransferEncoding: String = ""
    public var jsonWriteSocketWriteCount: Int64 = 0
    public var jsonStreamSocketWriteCount: Int64 = 0
    public var jsonWriteReadyStatus: String = ""
    public var jsonStreamReadyStatus: String = ""
    var jsonWriteClientChannel: ?ContractTlsRecordChannel = None
    var jsonStreamClientChannel: ?ContractTlsRecordChannel = None

    public func openJsonWriteSocketWire(wire: Array<UInt8>): String {
        openJsonWriteSocketRecords(
            splitJinguiAcceptedTransportRecordWire(
                serverEngineAbstractionTestByteArray(wire)
            )
        )
    }

    public func openJsonWriteSocketRecords(records: Array<Array<Byte>>): String {
        match (jsonWriteClientChannel) {
            case Some(channel) =>
                String.fromUtf8(channel.openAndReassemble(records))
            case None =>
                throw Exception(
                    "expected jsonWrite companion client record channel before socket wire open"
                )
        }
    }

    public func openJsonStreamSocketWire(wire: Array<UInt8>): String {
        openJsonStreamSocketRecords(
            splitJinguiAcceptedTransportRecordWire(
                serverEngineAbstractionTestByteArray(wire)
            )
        )
    }

    public func openJsonStreamSocketRecords(records: Array<Array<Byte>>): String {
        match (jsonStreamClientChannel) {
            case Some(channel) =>
                String.fromUtf8(channel.openAndReassemble(records))
            case None =>
                throw Exception(
                    "expected jsonStream companion client record channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let jsonWriteAccepted = listener.accept()
            try {
                let jsonWriteHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 416)
                    )
                )
                let jsonWriteTurn =
                    option.serveJinguiAcceptedTransportSocketLogicalRequest(
                        jsonWriteAccepted,
                        app,
                        ServerJinguiAcceptedTransportLogicalRequest(
                            "GET",
                            "/carrier-json-write-socket-wire"
                        ),
                        jsonWriteHello.encodedClientHello,
                        engineIncrementalBytes(32, start: 448),
                        transportId: "carrier-json-write-socket-wire-transport",
                        maxFragmentLen: 8
                    )
                jsonWriteClientChannel = Some(
                    contractTls13CreateClientRecordChannel(
                        jsonWriteTurn.session.keyMaterial,
                        algorithm: jsonWriteTurn.session.recordChannel.algorithm
                    )
                )
                jsonWriteReadyStatus = jsonWriteTurn.readySnapshot.status
                jsonWriteResponseStatus = jsonWriteTurn.responseStatus
                jsonWriteContentType =
                    jsonWriteTurn.responseHeaders.getFirst("content-type") ?? ""
                jsonWriteTransferEncoding =
                    jsonWriteTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                jsonWriteSocketWriteCount =
                    jsonWriteTurn.socketWriteCount
            } finally {
                if (!jsonWriteAccepted.isClosed()) {
                    jsonWriteAccepted.close()
                }
            }

            let jsonStreamAccepted = listener.accept()
            try {
                let jsonStreamHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 480)
                    )
                )
                let jsonStreamTurn =
                    option.serveJinguiAcceptedTransportSocketLogicalRequest(
                        jsonStreamAccepted,
                        app,
                        ServerJinguiAcceptedTransportLogicalRequest(
                            "GET",
                            "/carrier-json-stream-socket-wire"
                        ),
                        jsonStreamHello.encodedClientHello,
                        engineIncrementalBytes(32, start: 512),
                        transportId: "carrier-json-stream-socket-wire-transport",
                        maxFragmentLen: 8
                    )
                jsonStreamClientChannel = Some(
                    contractTls13CreateClientRecordChannel(
                        jsonStreamTurn.session.keyMaterial,
                        algorithm: jsonStreamTurn.session.recordChannel.algorithm
                    )
                )
                jsonStreamReadyStatus = jsonStreamTurn.readySnapshot.status
                jsonStreamResponseStatus = jsonStreamTurn.responseStatus
                jsonStreamContentType =
                    jsonStreamTurn.responseHeaders.getFirst("content-type") ?? ""
                jsonStreamTransferEncoding =
                    jsonStreamTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                jsonStreamSocketWriteCount =
                    jsonStreamTurn.socketWriteCount
            } finally {
                if (!jsonStreamAccepted.isClosed()) {
                    jsonStreamAccepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportLogicalRequestBodyProbeEngine <: ServerEngine {
    public var bodyStringResponseStatus: UInt16 = 0
    public var bodyJsonResponseStatus: UInt16 = 0
    public var bodyStringContentType: String = ""
    public var bodyJsonContentType: String = ""
    public var bodyStringTransferEncoding: String = ""
    public var bodyJsonTransferEncoding: String = ""
    public var bodyStringSocketWriteCount: Int64 = 0
    public var bodyJsonSocketWriteCount: Int64 = 0
    public var bodyStringReadyStatus: String = ""
    public var bodyJsonReadyStatus: String = ""
    var bodyStringClientChannel: ?ContractTlsRecordChannel = None
    var bodyJsonClientChannel: ?ContractTlsRecordChannel = None

    public func openBodyStringSocketWire(wire: Array<UInt8>): String {
        match (bodyStringClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected bodyString companion client record channel before socket wire open"
                )
        }
    }

    public func openBodyJsonSocketWire(wire: Array<UInt8>): String {
        match (bodyJsonClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected bodyJson companion client record channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let bodyStringAccepted = listener.accept()
            try {
                let bodyStringHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 544)
                    )
                )
                let bodyStringTurn =
                    option.serveJinguiAcceptedTransportSocketLogicalRequest(
                        bodyStringAccepted,
                        app,
                        ServerJinguiAcceptedTransportLogicalRequest(
                            "POST",
                            "/carrier-body-string",
                            bodyBytes: "accepted-body".toArray()
                        ),
                        bodyStringHello.encodedClientHello,
                        engineIncrementalBytes(32, start: 576),
                        transportId: "carrier-body-string-transport",
                        maxFragmentLen: 8
                    )
                bodyStringClientChannel = Some(
                    contractTls13CreateClientRecordChannel(
                        bodyStringTurn.session.keyMaterial,
                        algorithm: bodyStringTurn.session.recordChannel.algorithm
                    )
                )
                bodyStringReadyStatus = bodyStringTurn.readySnapshot.status
                bodyStringResponseStatus = bodyStringTurn.responseStatus
                bodyStringContentType =
                    bodyStringTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyStringTransferEncoding =
                    bodyStringTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyStringSocketWriteCount = bodyStringTurn.socketWriteCount
            } finally {
                if (!bodyStringAccepted.isClosed()) {
                    bodyStringAccepted.close()
                }
            }

            let bodyJsonAccepted = listener.accept()
            try {
                let bodyJsonHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 608)
                    )
                )
                let bodyJsonTurn =
                    option.serveJinguiAcceptedTransportSocketLogicalRequest(
                        bodyJsonAccepted,
                        app,
                        ServerJinguiAcceptedTransportLogicalRequest(
                            "POST",
                            "/carrier-body-json",
                            bodyBytes: #"{"name":"ignite","val":23}"#.toArray()
                        ),
                        bodyJsonHello.encodedClientHello,
                        engineIncrementalBytes(32, start: 640),
                        transportId: "carrier-body-json-transport",
                        maxFragmentLen: 8
                    )
                bodyJsonClientChannel = Some(
                    contractTls13CreateClientRecordChannel(
                        bodyJsonTurn.session.keyMaterial,
                        algorithm: bodyJsonTurn.session.recordChannel.algorithm
                    )
                )
                bodyJsonReadyStatus = bodyJsonTurn.readySnapshot.status
                bodyJsonResponseStatus = bodyJsonTurn.responseStatus
                bodyJsonContentType =
                    bodyJsonTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyJsonTransferEncoding =
                    bodyJsonTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyJsonSocketWriteCount = bodyJsonTurn.socketWriteCount
            } finally {
                if (!bodyJsonAccepted.isClosed()) {
                    bodyJsonAccepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportLogicalRequestTargetQueryProbeEngine <: ServerEngine {
    public var queryResponseStatus: UInt16 = 0
    public var queryContentType: String = ""
    public var queryTransferEncoding: String = ""
    public var querySocketWriteCount: Int64 = 0
    public var queryReadyStatus: String = ""
    var queryClientChannel: ?ContractTlsRecordChannel = None

    public func openQuerySocketWire(wire: Array<UInt8>): String {
        match (queryClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected query companion client record channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let queryAccepted = listener.accept()
            try {
                let queryHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 672)
                    )
                )
                let queryTurn =
                    option.serveJinguiAcceptedTransportSocketLogicalRequest(
                        queryAccepted,
                        app,
                        ServerJinguiAcceptedTransportLogicalRequest(
                            "GET",
                            "/carrier-query?turn=from-path&mode=route"
                        ),
                        queryHello.encodedClientHello,
                        engineIncrementalBytes(32, start: 704),
                        transportId: "carrier-query-transport",
                        maxFragmentLen: 8
                    )
                queryClientChannel = Some(
                    contractTls13CreateClientRecordChannel(
                        queryTurn.session.keyMaterial,
                        algorithm: queryTurn.session.recordChannel.algorithm
                    )
                )
                queryReadyStatus = queryTurn.readySnapshot.status
                queryResponseStatus = queryTurn.responseStatus
                queryContentType =
                    queryTurn.responseHeaders.getFirst("content-type") ?? ""
                queryTransferEncoding =
                    queryTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                querySocketWriteCount = queryTurn.socketWriteCount
            } finally {
                if (!queryAccepted.isClosed()) {
                    queryAccepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportH2PseudoHeadersProbeEngine <: ServerEngine {
    public var pseudoResponseStatus: UInt16 = 0
    public var pseudoContentType: String = ""
    public var pseudoTransferEncoding: String = ""
    public var pseudoSocketWriteCount: Int64 = 0
    public var pseudoReadyStatus: String = ""
    var pseudoClientChannel: ?ContractTlsRecordChannel = None

    public func openPseudoSocketWire(wire: Array<UInt8>): String {
        match (pseudoClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected pseudo companion client record channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let pseudoAccepted = listener.accept()
            try {
                let pseudoHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 736)
                    )
                )
                let pseudoHeaders = HttpHeaders()
                pseudoHeaders.add("x-carrier-mode", "pseudo")
                let pseudoTurn =
                    option.serveJinguiAcceptedTransportSocketLogicalRequest(
                        pseudoAccepted,
                        app,
                        buildServerJinguiAcceptedTransportLogicalRequestFromH2PseudoHeaders(
                            ServerJinguiAcceptedTransportH2PseudoHeaders(
                                "POST",
                                "/carrier-h2-pseudo?turn=from-pseudo",
                                authority: "api.example.com:9443"
                            ),
                            headers: Some(pseudoHeaders),
                            bodyBytes: "pseudo-body".toArray()
                        ),
                        pseudoHello.encodedClientHello,
                        engineIncrementalBytes(32, start: 768),
                        transportId: "carrier-h2-pseudo-transport",
                        maxFragmentLen: 8
                    )
                pseudoClientChannel = Some(
                    contractTls13CreateClientRecordChannel(
                        pseudoTurn.session.keyMaterial,
                        algorithm: pseudoTurn.session.recordChannel.algorithm
                    )
                )
                pseudoReadyStatus = pseudoTurn.readySnapshot.status
                pseudoResponseStatus = pseudoTurn.responseStatus
                pseudoContentType =
                    pseudoTurn.responseHeaders.getFirst("content-type") ?? ""
                pseudoTransferEncoding =
                    pseudoTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                pseudoSocketWriteCount = pseudoTurn.socketWriteCount
            } finally {
                if (!pseudoAccepted.isClosed()) {
                    pseudoAccepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

func cloneServerEngineAbstractionTestHeaders(headers: HttpHeaders): HttpHeaders {
    let out = HttpHeaders()
    for ((name, values) in headers) {
        for (value in values) {
            out.add(name, value)
        }
    }
    out
}

class AcceptedTransportResponseProbeCarrier <: CurrentRequestCarrier {
    let pathText: String
    let requestTrailersValue: HttpHeaders
    public let responseHeaders = HttpHeaders()
    public let writer = CollectingResponseTransportWriter()
    public var responseStatus: UInt16 = 200

    init(pathText: String, requestTrailers!: ?HttpHeaders = None) {
        this.pathText = pathText
        this.requestTrailersValue = if (let Some(value) <- requestTrailers) {
            cloneServerEngineAbstractionTestHeaders(value)
        } else {
            HttpHeaders()
        }
    }

    public override func rawHttpContext(): HttpContext {
        throw Exception("raw HttpContext should not be required for accepted transport response probe carrier")
    }

    public override func upgradeWebSocketRaw(): WebSocket {
        throw Exception("websocket upgrade should not run for accepted transport response probe carrier")
    }

    public override func openResponseTransportWriterRaw(): ResponseTransportWriter {
        writer
    }

    public override func requestMethod(): String {
        "GET"
    }

    public override func requestPath(): String {
        pathText
    }

    public override func requestUrlString(): String {
        pathText
    }

    public override func requestVersionString(): String {
        "h2"
    }

    public override func requestRemoteAddr(): String {
        "127.0.0.1"
    }

    public override func requestQueryValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestFormValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestHeaderValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestHeaders(): HttpHeaders {
        HttpHeaders()
    }

    public override func requestTrailers(): HttpHeaders {
        requestTrailersValue
    }

    public override func requestBodyStream(): InputStream {
        AcceptedTransportResponseProbeEmptyInputStream()
    }

    public override func requestBodySize(): ?Int64 {
        Some(0)
    }

    public override func setResponseStatus(code: UInt16): Unit {
        responseStatus = code
    }

    public override func setResponseHeader(key: String, value: String): Unit {
        responseHeaders.add(key, value)
    }

    public override func addResponseHeaders(headers: HttpHeaders): Unit {
        let _ = headers
    }

    public override func setResponseString(body: String): Unit {
        let _ = body
        throw Exception(
            "response string should be intercepted by accepted transport response carrier wrapper"
        )
    }

    public override func setResponseBytes(data: Array<UInt8>): Unit {
        let _ = data
        throw Exception(
            "response bytes should be intercepted by accepted transport response carrier wrapper"
        )
    }

    public override func attachResponseBodyStream(stream: InputStream): Unit {
        let _ = stream
        throw Exception(
            "response stream should be intercepted by accepted transport response carrier wrapper"
        )
    }
}

class AcceptedTransportH2LifecycleApplicationDataProbeCarrier <: CurrentRequestCarrier {
    let pathText: String
    let lifecycle: ServerJinguiAcceptedTransportSocketResponseWriterLifecycle
    let failOnOpen: Bool
    public let responseHeaders = HttpHeaders()
    public var responseStatus: UInt16 = 200
    public var openCalls: Int64 = 0

    init(
        pathText: String,
        lifecycle: ServerJinguiAcceptedTransportSocketResponseWriterLifecycle,
        failOnOpen: Bool
    ) {
        this.pathText = pathText
        this.lifecycle = lifecycle
        this.failOnOpen = failOnOpen
    }

    public override func rawHttpContext(): HttpContext {
        throw Exception("raw HttpContext should not be required for accepted transport H2 lifecycle application-data probe carrier")
    }

    public override func upgradeWebSocketRaw(): WebSocket {
        throw Exception("websocket upgrade should not run for accepted transport H2 lifecycle application-data probe carrier")
    }

    public override func openResponseTransportWriterRaw(): ResponseTransportWriter {
        openCalls += 1
        if (failOnOpen) {
            throw Exception(
                "accepted transport H2 lifecycle application-data writer acquisition failed"
            )
        }
        lifecycle.openResponseTransportWriter()
    }

    public override func requestMethod(): String {
        "GET"
    }

    public override func requestPath(): String {
        pathText
    }

    public override func requestUrlString(): String {
        pathText
    }

    public override func requestVersionString(): String {
        "h2"
    }

    public override func requestRemoteAddr(): String {
        "127.0.0.1"
    }

    public override func requestQueryValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestFormValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestHeaderValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestHeaders(): HttpHeaders {
        HttpHeaders()
    }

    public override func requestTrailers(): HttpHeaders {
        HttpHeaders()
    }

    public override func requestBodyStream(): InputStream {
        AcceptedTransportResponseProbeEmptyInputStream()
    }

    public override func requestBodySize(): ?Int64 {
        Some(0)
    }

    public override func setResponseStatus(code: UInt16): Unit {
        responseStatus = code
    }

    public override func setResponseHeader(key: String, value: String): Unit {
        responseHeaders.add(key, value)
    }

    public override func addResponseHeaders(headers: HttpHeaders): Unit {
        let _ = headers
    }

    public override func setResponseString(body: String): Unit {
        let _ = body
        throw Exception(
            "response string should not run in accepted transport H2 lifecycle application-data probe"
        )
    }

    public override func setResponseBytes(data: Array<UInt8>): Unit {
        let _ = data
        throw Exception(
            "response bytes should not run in accepted transport H2 lifecycle application-data probe"
        )
    }

    public override func attachResponseBodyStream(stream: InputStream): Unit {
        let _ = stream
        throw Exception(
            "response stream should not run in accepted transport H2 lifecycle application-data probe"
        )
    }
}

class AcceptedTransportResponseSocketSinkProbeCarrier <: CurrentRequestCarrier {
    let pathText: String
    let socket: TcpSocket
    public let responseHeaders = HttpHeaders()
    public var responseStatus: UInt16 = 200
    public var socketWriteCount: Int64 = 0
    public var totalEncodedSocketBytes: Int64 = 0

    init(pathText: String, socket: TcpSocket) {
        this.pathText = pathText
        this.socket = socket
    }

    func writeSocketResponseBytes(bytes: Array<UInt8>): Unit {
        socketWriteCount += 1
        totalEncodedSocketBytes += bytes.size
        socket.write(bytes)
    }

    public override func rawHttpContext(): HttpContext {
        throw Exception("raw HttpContext should not be required for accepted transport response socket-sink probe carrier")
    }

    public override func upgradeWebSocketRaw(): WebSocket {
        throw Exception("websocket upgrade should not run for accepted transport response socket-sink probe carrier")
    }

    public override func openResponseTransportWriterRaw(): ResponseTransportWriter {
        openSinkBackedResponseTransportWriter({ bytes =>
            writeSocketResponseBytes(bytes)
        })
    }

    public override func requestMethod(): String {
        "GET"
    }

    public override func requestPath(): String {
        pathText
    }

    public override func requestUrlString(): String {
        pathText
    }

    public override func requestVersionString(): String {
        "h2"
    }

    public override func requestRemoteAddr(): String {
        socket.remoteAddress.toString()
    }

    public override func requestQueryValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestFormValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestHeaderValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestHeaders(): HttpHeaders {
        HttpHeaders()
    }

    public override func requestTrailers(): HttpHeaders {
        HttpHeaders()
    }

    public override func requestBodyStream(): InputStream {
        AcceptedTransportResponseProbeEmptyInputStream()
    }

    public override func requestBodySize(): ?Int64 {
        Some(0)
    }

    public override func setResponseStatus(code: UInt16): Unit {
        responseStatus = code
    }

    public override func setResponseHeader(key: String, value: String): Unit {
        responseHeaders.add(key, value)
    }

    public override func addResponseHeaders(headers: HttpHeaders): Unit {
        let _ = headers
    }

    public override func setResponseString(body: String): Unit {
        let _ = body
        throw Exception(
            "response string should be intercepted by accepted transport response socket-sink carrier wrapper"
        )
    }

    public override func setResponseBytes(data: Array<UInt8>): Unit {
        let _ = data
        throw Exception(
            "response bytes should be intercepted by accepted transport response socket-sink carrier wrapper"
        )
    }

    public override func attachResponseBodyStream(stream: InputStream): Unit {
        let _ = stream
        throw Exception(
            "response stream should be intercepted by accepted transport response socket-sink carrier wrapper"
        )
    }
}

class AcceptedTransportResponseProbeEmptyInputStream <: InputStream {
    public override func read(outBuf: Array<Byte>): Int64 {
        let _ = outBuf
        0
    }

    public func close(): Unit {}
}

class SocketServerEngineShellStreamTrackingInput <: InputStream & Resource {
    let bytes: Array<UInt8>
    var cursor: Int64 = 0
    public var closed: Bool = false

    init(bytes: Array<UInt8>) {
        this.bytes = bytes
    }

    public override func read(outBuf: Array<Byte>): Int64 {
        if (closed || cursor >= bytes.size || outBuf.size == 0) {
            return 0
        }
        let remaining = bytes.size - cursor
        let readLen = if (remaining < outBuf.size) { remaining } else { outBuf.size }
        var i: Int64 = 0
        while (i < readLen) {
            outBuf[i] = bytes[cursor + i]
            i += 1
        }
        cursor += readLen
        readLen
    }

    public func close(): Unit {
        closed = true
    }

    public func isClosed(): Bool {
        closed
    }

    public func bytesRead(): Int64 {
        cursor
    }
}

func waitForShellReady(app: App, port: UInt16): Unit {
    var attempts: Int64 = 0
    while (attempts < 100) {
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                if (event.phase == "ready" && event.port == port) {
                    return
                }
            case None => ()
        }
        sleep(Duration.millisecond * 10)
        attempts += 1
    }
    @Fail("timed out waiting for socket server engine shell startup observe event")
}

func reserveServerEngineAbstractionLoopbackPort(): UInt16 {
    let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
    listener.bind()
    try {
        (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception(
                "server engine abstraction test could not reserve loopback port"
            )
    } finally {
        if (!listener.isClosed()) {
            listener.close()
        }
    }
}

func shutdownServerEngineAbstractionApp(app: App, future: Future<Unit>): Unit {
    app.shutdown()
    try {
        let _ = future.get(Duration.second * 1)
    } catch (_: Exception) {
        future.cancel()
    }
}

func installSocketServerEngineShellParityRoutes(
    app: App,
    bufferedBody: String,
    streamBody: String
): Unit {
    app.get("/parity-buffered", { ctx =>
        let _ = ctx.sendString(bufferedBody)
    })
    app.get("/parity-stream", { ctx =>
        let stream = SocketServerEngineShellStreamTrackingInput(streamBody.toArray())
        let _ = ctx.sendStream(
            stream,
            contentType: "text/plain; charset=utf-8",
            contentLength: Some(streamBody.size)
        )
    })
}

func assertSocketServerEngineShellStdxParityResponse(
    label: String,
    responseText: String,
    expectedBody: String
): Unit {
    let lower = responseText.toAsciiLower()
    if (socketServerEngineShellTestIndexOfText(lower, "http/1.1 200 ok") < 0) {
        @Fail("${label} should expose HTTP/1.1 200 OK")
    }
    if (
        socketServerEngineShellTestIndexOfText(
            lower,
            "content-type: text/plain; charset=utf-8"
        ) < 0
    ) {
        @Fail("${label} should preserve text/plain content-type")
    }
    if (
        socketServerEngineShellTestIndexOfText(
            lower,
            "content-length: ${expectedBody.size}"
        ) < 0
    ) {
        @Fail("${label} should preserve known content-length")
    }
    if (
        socketServerEngineShellTestIndexOfText(
            responseText,
            "\r\n\r\n${expectedBody}"
        ) < 0
    ) {
        @Fail("${label} should preserve response body")
    }
}

func runSocketServerEngineShellClient(
    host: String,
    port: UInt16,
    requestWire: String
): String {
    let socket = TcpSocket(IPSocketAddress.parse("${host}:${port}"))
    socket.connect()
    try {
        socket.write(socketServerEngineShellOneShotRequestWire(requestWire).toArray())
        readSocketServerEngineShellResponseWire(socket)
    } finally {
        if (!socket.isClosed()) {
            socket.close()
        }
    }
}

func runAcceptedTransportResponseSocketSinkClient(
    host: String,
    port: UInt16
): Array<UInt8> {
    let socket = TcpSocket(IPSocketAddress.parse("${host}:${port}"))
    socket.connect()
    try {
        readAcceptedTransportResponseSocketSinkWire(socket)
    } finally {
        if (!socket.isClosed()) {
            socket.close()
        }
    }
}

func runAcceptedTransportResponseSocketFragmentedClient(
    host: String,
    port: UInt16,
    readChunkSize!: Int64 = 3
): Array<Array<Byte>> {
    let socket = TcpSocket(IPSocketAddress.parse("${host}:${port}"))
    socket.connect()
    try {
        readAcceptedTransportResponseSocketFragmentedRecords(
            socket,
            readChunkSize: readChunkSize
        )
    } finally {
        if (!socket.isClosed()) {
            socket.close()
        }
    }
}

type AcceptedTransportRequestWireFragmentsSupplier =
    () -> ?Array<Array<Byte>>

func waitForAcceptedTransportPreparedRequestWireFragments(
    label: String,
    supplier: AcceptedTransportRequestWireFragmentsSupplier
): Array<Array<Byte>> {
    var attempts: Int64 = 0
    while (attempts < 200) {
        match (supplier()) {
            case Some(fragments) => return fragments
            case None => ()
        }
        sleep(Duration.millisecond * 10)
        attempts += 1
    }
    @Fail("timed out waiting for ${label}")
}

func runAcceptedTransportRequestResponseSocketSinkClient(
    host: String,
    port: UInt16,
    label: String,
    supplier: AcceptedTransportRequestWireFragmentsSupplier,
    writePauseMillis!: Int64 = 10
): Array<UInt8> {
    let socket = TcpSocket(IPSocketAddress.parse("${host}:${port}"))
    socket.connect()
    try {
        let requestWireFragments =
            waitForAcceptedTransportPreparedRequestWireFragments(
                label,
                supplier
            )
        var i: Int64 = 0
        while (i < requestWireFragments.size) {
            socket.write(
                serverEngineAbstractionTestUInt8Array(
                    requestWireFragments[i]
                )
            )
            if (
                writePauseMillis > 0 &&
                i + 1 < requestWireFragments.size
            ) {
                sleep(Duration.millisecond * writePauseMillis)
            }
            i += 1
        }
        readAcceptedTransportResponseSocketSinkWire(socket)
    } finally {
        if (!socket.isClosed()) {
            socket.close()
        }
    }
}

func runAcceptedTransportDuplexRequestResponseSocketSinkClient(
    host: String,
    port: UInt16,
    label: String,
    supplier: AcceptedTransportRequestWireFragmentsSupplier,
    writePauseMillis!: Int64 = 10
): Array<UInt8> {
    let socket = TcpSocket(IPSocketAddress.parse("${host}:${port}"))
    socket.connect()
    try {
        let writerFuture = spawn {
            let requestWireFragments =
                waitForAcceptedTransportPreparedRequestWireFragments(
                    label,
                    supplier
                )
            writeAcceptedTransportSocketWireFragments(
                socket,
                requestWireFragments,
                writePauseMillis: writePauseMillis
            )
        }
        let responseWire = readAcceptedTransportResponseSocketSinkWire(socket)
        let _ = writerFuture.get(Duration.second * 5)
        responseWire
    } finally {
        if (!socket.isClosed()) {
            socket.close()
        }
    }
}

func runAcceptedTransportTlsHandshakeRequestResponseSocketSinkClient(
    host: String,
    port: UInt16,
    clientHelloWireFragments: Array<Array<Byte>>,
    label: String,
    supplier: AcceptedTransportRequestWireFragmentsSupplier,
    writePauseMillis!: Int64 = 10,
    serverHandshakeRecordCount!: Int64 = 0,
    wireClientHello!: ?ContractTls13HttpClientHelloX25519 = None
): Array<UInt8> {
    let socket = TcpSocket(IPSocketAddress.parse("${host}:${port}"))
    socket.connect()
    try {
        var i: Int64 = 0
        while (i < clientHelloWireFragments.size) {
            socket.write(
                serverEngineAbstractionTestUInt8Array(
                    clientHelloWireFragments[i]
                )
            )
            if (
                writePauseMillis > 0 &&
                i + 1 < clientHelloWireFragments.size
            ) {
                sleep(Duration.millisecond * writePauseMillis)
            }
            i += 1
        }
        if (serverHandshakeRecordCount > 0) {
            let clientHello = match (wireClientHello) {
                case Some(value) => value
                case None => throw Exception("wire-derived TLS client hello is required")
            }
            let _ = completeAcceptedTransportTls13ClientHandshake(
                socket,
                clientHello,
                serverHandshakeRecordCount
            )
        }
        let requestWireFragments =
            waitForAcceptedTransportPreparedRequestWireFragments(
                label,
                supplier
            )
        i = 0
        while (i < requestWireFragments.size) {
            socket.write(
                serverEngineAbstractionTestUInt8Array(
                    requestWireFragments[i]
                )
            )
            if (
                writePauseMillis > 0 &&
                i + 1 < requestWireFragments.size
            ) {
                sleep(Duration.millisecond * writePauseMillis)
            }
            i += 1
        }
        readAcceptedTransportResponseSocketSinkWire(socket)
    } finally {
        if (!socket.isClosed()) {
            socket.close()
        }
    }
}

func runAcceptedTransportTlsHandshakeRequestResponseFirstRecordSocketSinkClient(
    host: String,
    port: UInt16,
    clientHelloWireFragments: Array<Array<Byte>>,
    label: String,
    supplier: AcceptedTransportRequestWireFragmentsSupplier,
    writePauseMillis!: Int64 = 10,
    serverHandshakeRecordCount!: Int64 = 0,
    wireClientHello!: ?ContractTls13HttpClientHelloX25519 = None
): Array<UInt8> {
    let socket = TcpSocket(IPSocketAddress.parse("${host}:${port}"))
    socket.connect()
    try {
        writeAcceptedTransportSocketWireFragments(
            socket,
            clientHelloWireFragments,
            writePauseMillis: writePauseMillis
        )
        if (serverHandshakeRecordCount > 0) {
            let clientHello = match (wireClientHello) {
                case Some(value) => value
                case None => throw Exception("wire-derived TLS client hello is required")
            }
            let _ = completeAcceptedTransportTls13ClientHandshake(
                socket,
                clientHello,
                serverHandshakeRecordCount
            )
        }
        let requestWireFragments =
            waitForAcceptedTransportPreparedRequestWireFragments(
                label,
                supplier
            )
        writeAcceptedTransportSocketWireFragments(
            socket,
            requestWireFragments,
            writePauseMillis: writePauseMillis
        )
        serverEngineAbstractionTestUInt8Array(
            readAcceptedTransportResponseSocketFirstCompleteRecord(
                socket,
                readChunkSize: 3
            )
        )
    } finally {
        if (!socket.isClosed()) {
            socket.close()
        }
    }
}

func consumeAcceptedTransportInitialHandshakeRecords(
    socket: TcpSocket,
    recordCount: Int64
): Array<Array<Byte>> {
    let accumulator = JinguiAcceptedTransportRecordWireAccumulator()
    let collectedRecords = ArrayList<Array<Byte>>()
    let buf = Array<UInt8>(256, repeat: 0)
    var consumed: Int64 = 0
    while (consumed < recordCount) {
        let n = socket.read(buf)
        if (n <= 0) {
            throw Exception(
                "accepted transport socket ended before initial TLS handshake flight"
            )
        }
        accumulator.append(serverEngineAbstractionTestByteArray(buf[..n]))
        let records = accumulator.drainCompleteRecords()
        for (record in records) {
            @Assert(consumed < recordCount, true)
            @Assert(record.size >= 5, true)
            let expectedOuterType = if (consumed == 0) {
                UInt8(22)
            } else {
                UInt8(23)
            }
            @Assert(UInt8(record[0]), expectedOuterType)
            collectedRecords.add(record)
            consumed += 1
        }
    }
    collectedRecords.toArray()
}

func completeAcceptedTransportTls13ClientHandshake(
    socket: TcpSocket,
    clientHello: ContractTls13HttpClientHelloX25519,
    serverHandshakeRecordCount: Int64
): ContractTlsRecordChannel {
    let records = consumeAcceptedTransportInitialHandshakeRecords(
        socket,
        serverHandshakeRecordCount
    )
    let wire = ArrayList<Byte>()
    for (record in records) {
        for (value in record) {
            wire.add(value)
        }
    }
    let outcome = contractTryTls13OpenHttpClientRuntimeFromWireDerivedServerFlight(
        clientHello,
        ContractHttpClientTlsTrustRequest(
            String.fromUtf8(File.readFrom(resolveEngineFixturePath(
                "_helper/testdata/tls/server-cert-a.pem"
            ))),
            hostname: "localhost",
            policy: ContractTlsHttpNegotiationPolicy(
                requireServerName: true,
                allowedServerNames: ["www.example.com"],
                alpnPreference: ["h2", "http/1.1"]
            )
        ),
        contractTls13CollectIncrementalHandshakeRecords([], wire.toArray())
    )
    let runtime = match (outcome.result) {
        case Some(value) => value
        case None => throw Exception("wire-derived TLS client handshake failed: ${outcome.message}")
    }
    socket.write(serverEngineAbstractionTestUInt8Array(runtime.clientFinished.encodedRecord))
    runtime.runtime.channelSet.clientChannel
}

func writeAcceptedTransportSocketWireFragments(
    socket: TcpSocket,
    requestWireFragments: Array<Array<Byte>>,
    writePauseMillis!: Int64 = 10
): Unit {
    var i: Int64 = 0
    while (i < requestWireFragments.size) {
        socket.write(
            serverEngineAbstractionTestUInt8Array(
                requestWireFragments[i]
            )
        )
        if (writePauseMillis > 0 && i + 1 < requestWireFragments.size) {
            sleep(Duration.millisecond * writePauseMillis)
        }
        i += 1
    }
}

func readAcceptedTransportResponseSocketFirstCompleteRecord(
    socket: TcpSocket,
    readChunkSize!: Int64 = 3
): Array<Byte> {
    let accumulator = JinguiAcceptedTransportRecordWireAccumulator()
    readAcceptedTransportResponseSocketFirstCompleteRecordWithAccumulator(
        socket,
        accumulator,
        readChunkSize: readChunkSize
    )
}

func readAcceptedTransportResponseSocketFirstCompleteRecordWithAccumulator(
    socket: TcpSocket,
    accumulator: JinguiAcceptedTransportRecordWireAccumulator,
    readChunkSize!: Int64 = 3
): Array<Byte> {
    let chunkSize = if (readChunkSize > 0) {
        readChunkSize
    } else {
        3
    }
    let buf = Array<UInt8>(chunkSize, repeat: 0)
    while (true) {
        let bufferedRecords = accumulator.drainOneCompleteRecord()
        if (bufferedRecords.size > 0) {
            return bufferedRecords[0]
        }
        let n = socket.read(buf)
        if (n <= 0) {
            throw Exception(
                "accepted transport response socket ended before one complete TLS record"
            )
        }
        accumulator.append(serverEngineAbstractionTestByteArray(buf[..n]))
    }
    throw Exception(
        "accepted transport response socket first complete record read loop ended unexpectedly"
    )
}

func buildAcceptedTransportTlsH2HeadersPlusDataRequestRecords(
    channel: ContractTlsRecordChannel,
    headerBlockFragment: Array<Byte>,
    streamId: Int64,
    bodyText: String
): Array<Array<Byte>> {
    channel.sealFragments(
        ContractTlsRecordContentType.ApplicationData,
        concatServerEngineAbstractionTestByteArrays([
            buildServerEngineAbstractionTestH2FrameWire(
                buildServerEngineAbstractionTestH2HeadersPayload(
                    headerBlockFragment
                ),
                frameType: UInt8(0x1),
                flags: UInt8(0x4),
                streamId: streamId
            ),
            buildServerEngineAbstractionTestH2FrameWire(
                serverEngineAbstractionTestByteArray(bodyText.toArray()),
                frameType: UInt8(0x0),
                flags: UInt8(0x1),
                streamId: streamId
            )
        ]),
        maxFragmentLen: 7
    )
}

func buildAcceptedTransportTlsH2TwoHeadersPlusDataRequestRecords(
    channel: ContractTlsRecordChannel,
    firstHeaderBlockFragment: Array<Byte>,
    firstStreamId: Int64,
    firstBodyText: String,
    secondHeaderBlockFragment: Array<Byte>,
    secondStreamId: Int64,
    secondBodyText: String
): Array<Array<Byte>> {
    channel.sealFragments(
        ContractTlsRecordContentType.ApplicationData,
        concatServerEngineAbstractionTestByteArrays([
            buildServerEngineAbstractionTestH2FrameWire(
                buildServerEngineAbstractionTestH2HeadersPayload(
                    firstHeaderBlockFragment
                ),
                frameType: UInt8(0x1),
                flags: UInt8(0x4),
                streamId: firstStreamId
            ),
            buildServerEngineAbstractionTestH2FrameWire(
                serverEngineAbstractionTestByteArray(firstBodyText.toArray()),
                frameType: UInt8(0x0),
                flags: UInt8(0x1),
                streamId: firstStreamId
            ),
            buildServerEngineAbstractionTestH2FrameWire(
                buildServerEngineAbstractionTestH2HeadersPayload(
                    secondHeaderBlockFragment
                ),
                frameType: UInt8(0x1),
                flags: UInt8(0x4),
                streamId: secondStreamId
            ),
            buildServerEngineAbstractionTestH2FrameWire(
                serverEngineAbstractionTestByteArray(secondBodyText.toArray()),
                frameType: UInt8(0x0),
                flags: UInt8(0x1),
                streamId: secondStreamId
            )
        ]),
        maxFragmentLen: 4096
    )
}

func runAcceptedTransportOneWaySocketClient(
    host: String,
    port: UInt16,
    requestWireFragments: Array<Array<Byte>>,
    writePauseMillis!: Int64 = 10
): Unit {
    let socket = TcpSocket(IPSocketAddress.parse("${host}:${port}"))
    socket.connect()
    try {
        var i: Int64 = 0
        while (i < requestWireFragments.size) {
            socket.write(
                serverEngineAbstractionTestUInt8Array(
                    requestWireFragments[i]
                )
            )
            if (writePauseMillis > 0 && i + 1 < requestWireFragments.size) {
                sleep(Duration.millisecond * writePauseMillis)
            }
            i += 1
        }
    } finally {
        if (!socket.isClosed()) {
            socket.close()
        }
    }
}

func runSocketServerEngineShellClientWithSplitBody(
    host: String,
    port: UInt16,
    requestHeadWire: String,
    requestBodyWire: String
): String {
    let socket = TcpSocket(IPSocketAddress.parse("${host}:${port}"))
    socket.connect()
    try {
        socket.write(socketServerEngineShellOneShotRequestWire(requestHeadWire).toArray())
        sleep(Duration.millisecond * 50)
        socket.write(requestBodyWire.toArray())
        readSocketServerEngineShellResponseWire(socket)
    } finally {
        if (!socket.isClosed()) {
            socket.close()
        }
    }
}

func socketServerEngineShellOneShotRequestWire(requestWire: String): String {
    let lower = requestWire.toAsciiLower()
    if (socketServerEngineShellTestIndexOfText(lower, "\r\nconnection:") >= 0) {
        return requestWire
    }
    let headerEnd = socketServerEngineShellTestIndexOfText(requestWire, "\r\n\r\n")
    if (headerEnd < 0) {
        return requestWire
    }
    "${requestWire[..headerEnd]}\r\nConnection: close${requestWire[headerEnd..]}"
}

func socketServerEngineShellTestIndexOfText(text: String, target: String): Int64 {
    let a = text.toRuneArray()
    let b = target.toRuneArray()
    if (b.size == 0) {
        return 0
    }
    if (a.size < b.size) {
        return -1
    }
    var i: Int64 = 0
    while (i <= a.size - b.size) {
        var ok = true
        var j: Int64 = 0
        while (j < b.size) {
            if (a[i + j] != b[j]) {
                ok = false
                break
            }
            j += 1
        }
        if (ok) {
            return i
        }
        i += 1
    }
    -1
}

func readSocketServerEngineShellResponseWire(socket: TcpSocket): String {
    let out = ArrayList<UInt8>()
    let buf = Array<UInt8>(4096, repeat: 0)
    while (true) {
        let n = socket.read(buf)
        if (n <= 0) {
            break
        }
        appendServerEngineAbstractionTestBytes(out, buf[..n])
    }
    String.fromUtf8(out.toArray())
}

func appendServerEngineAbstractionTestBytes(out: ArrayList<UInt8>, bytes: Array<UInt8>): Unit {
    for (b in bytes) {
        out.add(b)
    }
}

func readAcceptedTransportResponseSocketSinkWire(
    socket: TcpSocket
): Array<UInt8> {
    let out = ArrayList<UInt8>()
    let buf = Array<UInt8>(4096, repeat: 0)
    while (true) {
        let n = socket.read(buf)
        if (n <= 0) {
            break
        }
        appendAcceptedTransportResponseSocketSinkBytes(out, buf[..n])
    }
    out.toArray()
}

func appendAcceptedTransportResponseSocketSinkBytes(
    out: ArrayList<UInt8>,
    bytes: Array<UInt8>
): Unit {
    for (b in bytes) {
        out.add(b)
    }
}

func readAcceptedTransportResponseSocketFragmentedRecords(
    socket: TcpSocket,
    readChunkSize!: Int64 = 3
): Array<Array<Byte>> {
    let accumulator = JinguiAcceptedTransportRecordWireAccumulator()
    let records = ArrayList<Array<Byte>>()
    let chunkSize = if (readChunkSize > 0) {
        readChunkSize
    } else {
        3
    }
    let buf = Array<UInt8>(chunkSize, repeat: 0)
    while (true) {
        let n = socket.read(buf)
        if (n <= 0) {
            break
        }
        accumulator.append(serverEngineAbstractionTestByteArray(buf[..n]))
        appendAcceptedTransportResponseSocketFragmentedRecordBytes(
            records,
            accumulator.drainCompleteRecords()
        )
    }
    let trailing = accumulator.drainCompleteRecords()
    appendAcceptedTransportResponseSocketFragmentedRecordBytes(
        records,
        trailing
    )
    if (accumulator.bufferedByteCount() != 0) {
        throw Exception(
            "fragmented response socket client ended with incomplete TLS record bytes=${accumulator.bufferedByteCount()}"
        )
    }
    records.toArray()
}

func appendAcceptedTransportResponseSocketFragmentedRecordBytes(
    out: ArrayList<Array<Byte>>,
    records: Array<Array<Byte>>
): Unit {
    for (record in records) {
        out.add(record)
    }
}

func serverEngineAbstractionTestKeepJinguiContractLinkAnchor(): String {
    ContractErrorCode.BadInput.toString()
}

func buildServerEngineAbstractionTestTlsRecordWire(
    payload: Array<Byte>,
    contentType!: UInt8 = UInt8(0x16)
): Array<Byte> {
    if (payload.size > 0xffff) {
        throw Exception(
            "test TLS record payload exceeds single-record first-cut limit"
        )
    }
    let out = ArrayList<Byte>()
    out.add(contentType)
    out.add(UInt8(0x03))
    out.add(UInt8(0x03))
    out.add(UInt8((payload.size >> 8) & 0xff))
    out.add(UInt8(payload.size & 0xff))
    for (b in payload) {
        out.add(b)
    }
    out.toArray()
}

func serverEngineAbstractionTestByteArraysEqual(
    left: Array<Byte>,
    right: Array<Byte>
): Bool {
    if (left.size != right.size) {
        return false
    }
    var i: Int64 = 0
    while (i < left.size) {
        if (left[i] != right[i]) {
            return false
        }
        i += 1
    }
    true
}

func findServerEngineAbstractionTestBytes(
    input: Array<Byte>,
    needle: Array<Byte>
): Int64 {
    if (needle.size == 0) {
        return 0
    }
    var start: Int64 = 0
    while (start + needle.size <= input.size) {
        var matched = true
        var i: Int64 = 0
        while (i < needle.size) {
            if (input[start + i] != needle[i]) {
                matched = false
                break
            }
            i += 1
        }
        if (matched) {
            return start
        }
        start += 1
    }
    -1
}

func resolveEngineFixturePath(path: String): String {
    if (exists(path)) {
        return path
    }
    let workspacePath = "../" + path
    if (exists(workspacePath)) {
        return workspacePath
    }
    path
}

func engineIncrementalBytes(size: Int64, start!: Int64 = 0): Array<Byte> {
    let out = Array<Byte>(size, repeat: 0)
    var i = 0
    while (i < size) {
        out[i] = UInt8((start + i) & 0xff)
        i += 1
    }
    out
}

func cloneServerEngineAbstractionTestBytes(input: Array<UInt8>): Array<UInt8> {
    let out = Array<UInt8>(input.size, repeat: 0)
    var i: Int64 = 0
    while (i < input.size) {
        out[i] = input[i]
        i += 1
    }
    out
}

func serverEngineAbstractionTestByteArray(input: Array<UInt8>): Array<Byte> {
    let out = Array<Byte>(input.size, repeat: 0)
    var i: Int64 = 0
    while (i < input.size) {
        out[i] = input[i]
        i += 1
    }
    out
}

func serverEngineAbstractionTestTextBytes(text: String): Array<Byte> {
    let input = text.toArray()
    let out = Array<Byte>(input.size, repeat: 0)
    var i: Int64 = 0
    while (i < input.size) {
        out[i] = input[i]
        i += 1
    }
    out
}

func serverEngineAbstractionTestUInt8Array(input: Array<Byte>): Array<UInt8> {
    let out = Array<UInt8>(input.size, repeat: 0)
    var i: Int64 = 0
    while (i < input.size) {
        out[i] = UInt8(input[i])
        i += 1
    }
    out
}

func serverEngineAbstractionTestByteText(input: Array<Byte>): String {
    let out = Array<UInt8>(input.size, repeat: 0)
    var i: Int64 = 0
    while (i < input.size) {
        out[i] = UInt8(input[i])
        i += 1
    }
    String.fromUtf8(out)
}

func buildServerEngineAbstractionTestH2WindowUpdateFrame(
    streamId: Int64,
    increment: Int64
): JinguiAcceptedTransportH2FrameWireSnapshot {
    let payload = Array<UInt8>(4, repeat: 0)
    payload[0] = UInt8((increment >> 24) & 0xff)
    payload[1] = UInt8((increment >> 16) & 0xff)
    payload[2] = UInt8((increment >> 8) & 0xff)
    payload[3] = UInt8(increment & 0xff)
    JinguiAcceptedTransportH2FrameWireSnapshot(
        4,
        UInt8(0x8),
        UInt8(0x0),
        streamId,
        serverEngineAbstractionTestByteArray(payload)
    )
}

func cloneServerEngineAbstractionTestByteWindow(
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

func buildServerEngineAbstractionTestH2FrameWire(
    payload: Array<Byte>,
    frameType!: UInt8 = UInt8(0),
    flags!: UInt8 = UInt8(0),
    streamId!: Int64 = 1
): Array<Byte> {
    let out = ArrayList<Byte>()
    let payloadLen = payload.size
    out.add(UInt8((payloadLen >> 16) & 0xff))
    out.add(UInt8((payloadLen >> 8) & 0xff))
    out.add(UInt8(payloadLen & 0xff))
    out.add(frameType)
    out.add(flags)
    out.add(UInt8((streamId >> 24) & 0x7f))
    out.add(UInt8((streamId >> 16) & 0xff))
    out.add(UInt8((streamId >> 8) & 0xff))
    out.add(UInt8(streamId & 0xff))
    for (b in payload) {
        out.add(b)
    }
    out.toArray()
}

func buildServerEngineAbstractionTestH2HeadersPayload(
    headerBlockFragment: Array<Byte>,
    padded!: Bool = false,
    padLength!: Int64 = 0,
    priorityPresented!: Bool = false,
    exclusiveDependency!: Bool = false,
    streamDependency!: Int64 = 0,
    weight!: Int64 = 0
): Array<Byte> {
    let out = ArrayList<Byte>()
    if (padded) {
        out.add(UInt8(padLength & 0xff))
    }
    if (priorityPresented) {
        let exclusiveLead = if (exclusiveDependency) {
            Int64(0x80)
        } else {
            Int64(0)
        }
        out.add(
            UInt8(
                exclusiveLead +
                ((streamDependency >> 24) & 0x7f)
            )
        )
        out.add(UInt8((streamDependency >> 16) & 0xff))
        out.add(UInt8((streamDependency >> 8) & 0xff))
        out.add(UInt8(streamDependency & 0xff))
        out.add(UInt8(weight & 0xff))
    }
    for (b in headerBlockFragment) {
        out.add(b)
    }
    if (padded) {
        var i: Int64 = 0
        while (i < padLength) {
            out.add(UInt8(0))
            i += 1
        }
    }
    out.toArray()
}

func concatServerEngineAbstractionTestByteArrays(
    parts: Array<Array<Byte>>
): Array<Byte> {
    let out = ArrayList<Byte>()
    for (part in parts) {
        for (b in part) {
            out.add(b)
        }
    }
    out.toArray()
}

func serverEngineAbstractionTestByteRecords(
    input: ArrayList<Array<UInt8>>
): Array<Array<Byte>> {
    let out = ArrayList<Array<Byte>>()
    for (record in input) {
        out.add(serverEngineAbstractionTestByteArray(record))
    }
    out.toArray()
}

class CollectingResponseTransportWriter <: ResponseTransportWriter {
    public let writes: ArrayList<Array<UInt8>> = ArrayList<Array<UInt8>>()

    public override func write(data: Array<UInt8>): Unit {
        writes.add(cloneServerEngineAbstractionTestBytes(data))
    }
}

class TouchpointOverrideServerEngine <: ServerEngine & ServerEngineTransportTouchpointOverride {
    var lastTransportTouchpoint: ?ServerTransportTouchpoint = None

    public override func overrideTransportTouchpoint(
        addr: String,
        port: UInt16,
        tlsEnabled: Bool,
        baseTouchpoint: ServerTransportTouchpoint
    ): ServerTransportTouchpoint {
        let _ = addr
        let _ = port
        let _ = tlsEnabled
        ServerTransportTouchpoint(
            "ignite-custom-engine",
            baseTouchpoint.blockedCandidates,
            "ignite-custom-engine",
            "custom_engine_selected",
            baseTouchpoint.providerId,
            "opt-in-engine-custom",
            "experimental",
            baseTouchpoint.tlsEnabled,
            "engine_identity_override"
        )
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        lastTransportTouchpoint = option.transportTouchpoint
        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    public override func shutdown(): Unit {}
}
