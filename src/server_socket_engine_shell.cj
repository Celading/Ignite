package ignite

import ignite.native_tls.{NativeTlsApplicationProtocol, selectNativeTlsApplicationProtocol}
import jinguissl.live.{
    ContractHttpServerAcceptedTransportSession,
    ContractTls13IncrementalServerFinishRequest,
    ContractTls13IncrementalServerStartRequest,
    ContractTlsRecordContentType,
    ContractTlsVersion,
    contractRandomBytes,
    contractTlsEncodePlaintextRecord,
    contractTryTls13FinishIncrementalHttpServerHandshake,
    contractTryTls13StartIncrementalHttpServerHandshake
}
import std.collection.{ArrayList, HashMap}
import std.env.getVariable
import std.io.InputStream
import std.net.{
    IPSocketAddress,
    SocketException,
    SocketTimeoutException,
    TcpServerSocket,
    TcpSocket
}
import std.sync.Mutex
import stdx.net.http.{HttpContext, HttpHeaders, WebSocket}

let SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT_ENV = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"

public class SocketServerEngineShellRuntimeControl {
    let _mtx = Mutex()
    let _runtimeCounters = SocketServerRuntimeCounters()
    var _shutdownRequested: Bool = false
    var _listener: ?TcpServerSocket = None

    public init() {}

    public func attachListener(listener: TcpServerSocket): Unit {
        synchronized(_mtx) {
            _shutdownRequested = false
            _listener = Some(listener)
        }
    }

    public func detachListener(): Unit {
        synchronized(_mtx) {
            _listener = None
        }
    }

    public func requestShutdown(): Unit {
        var listenerToClose: ?TcpServerSocket = None
        synchronized(_mtx) {
            _shutdownRequested = true
            listenerToClose = _listener
        }
        if (let Some(listener) <- listenerToClose) {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public func shutdownRequested(): Bool {
        synchronized(_mtx) {
            _shutdownRequested
        }
    }

    func connectionAccepted(): Unit {
        _runtimeCounters.connectionAccepted()
    }

    func connectionClosed(): Unit {
        _runtimeCounters.connectionClosed()
    }

    func keepAliveWaitStarted(): Unit {
        _runtimeCounters.keepAliveWaitStarted()
    }

    func keepAliveWaitFinished(): Unit {
        _runtimeCounters.keepAliveWaitFinished()
    }

    func requestStarted(): Unit {
        _runtimeCounters.requestStarted()
    }

    func requestCompleted(): Unit {
        _runtimeCounters.requestCompleted()
    }

    func requestRejected(started: Bool): Unit {
        _runtimeCounters.requestRejected(started)
    }

    public func runtimeCounterSnapshot(): ServerRuntimeCounterSnapshot {
        _runtimeCounters.snapshot()
    }
}

func runSocketServerEngineShellListen(
    option: ServerEngineListenOption,
    app: App,
    onReady: ?((ServerEngineReadySignal) -> Unit),
    control: SocketServerEngineShellRuntimeControl,
    acceptedConnectionLimit: Int64,
    tlsAcceptedSessionReadyHook!:
        ?ServerJinguiAcceptedTransportAttachedSessionReadyHook = None
): Unit {
    if (socketServerEngineShellTlsIngressEnabled(option)) {
        runSocketServerEngineShellTlsListen(
            option,
            app,
            onReady,
            control,
            acceptedConnectionLimit,
            tlsAcceptedSessionReadyHook
        )
        return
    }
    let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("${option.addr}:${option.port}"))
    listener.bind()
    control.attachListener(listener)
    try {
        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
        serveSocketServerEngineShellTurns(
            listener,
            option,
            app,
            acceptedConnectionLimit,
            control
        )
    } finally {
        if (!listener.isClosed()) {
            listener.close()
        }
        control.detachListener()
    }
}

func socketServerEngineShellTlsIngressEnabled(
    option: ServerEngineListenOption
): Bool {
    try {
        option.loadTlsIngressContext().hasPreparedTlsMaterial()
    } catch (_: Exception) {
        false
    }
}

func runSocketServerEngineShellTlsListen(
    option: ServerEngineListenOption,
    app: App,
    onReady: ?((ServerEngineReadySignal) -> Unit),
    control: SocketServerEngineShellRuntimeControl,
    acceptedConnectionLimit: Int64,
    tlsAcceptedSessionReadyHook: ?ServerJinguiAcceptedTransportAttachedSessionReadyHook
): Unit {
    let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("${option.addr}:${option.port}"))
    listener.bind()
    control.attachListener(listener)
    try {
        let _ = option.loadTlsIngressContext().loadPreparedTlsMaterial()
        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
        serveSocketServerEngineShellTlsTurns(
            listener,
            option,
            app,
            acceptedConnectionLimit,
            control,
            tlsAcceptedSessionReadyHook
        )
    } finally {
        if (!listener.isClosed()) {
            listener.close()
        }
        control.detachListener()
    }
}

func serveSocketServerEngineShellTlsTurns(
    listener: TcpServerSocket,
    option: ServerEngineListenOption,
    app: App,
    acceptedConnectionLimit: Int64,
    control: SocketServerEngineShellRuntimeControl,
    tlsAcceptedSessionReadyHook: ?ServerJinguiAcceptedTransportAttachedSessionReadyHook
): Unit {
    var acceptedConnectionCount: Int64 = 0
    while (
        socketServerEngineShellAcceptLoopShouldContinue(
            acceptedConnectionCount,
            acceptedConnectionLimit
        ) &&
        !control.shutdownRequested()
    ) {
        try {
            serveSocketServerEngineShellTlsTurn(
                listener,
                option,
                app,
                tlsAcceptedSessionReadyHook
            )
            acceptedConnectionCount += 1
        } catch (e: Exception) {
            if (control.shutdownRequested()) {
                break
            }
            throw e
        }
    }
}

func serveSocketServerEngineShellTlsTurn(
    listener: TcpServerSocket,
    option: ServerEngineListenOption,
    app: App,
    tlsAcceptedSessionReadyHook: ?ServerJinguiAcceptedTransportAttachedSessionReadyHook
): Unit {
    let accepted = listener.accept()
    try {
        serveSocketServerEngineShellStableTlsH2SocketTurns(
            accepted,
            option,
            app,
            tlsAcceptedSessionReadyHook
        )
    } finally {
        if (!accepted.isClosed()) {
            accepted.close()
        }
    }
}

func serveSocketServerEngineShellStableTlsH2SocketTurns(
    accepted: TcpSocket,
    option: ServerEngineListenOption,
    app: App,
    tlsAcceptedSessionReadyHook: ?ServerJinguiAcceptedTransportAttachedSessionReadyHook
): Unit {
    let capture =
        option.captureJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHello(
            accepted,
            readChunkSize: 4096
        )
    let startOutcome = contractTryTls13StartIncrementalHttpServerHandshake(
        ContractTls13IncrementalServerStartRequest(
            buildServerAcceptedTransportDescriptorFromSocket(
                accepted,
                "socket-server-engine-shell-native-tls-live-ingress"
            ),
            buildServerContractHttpServerAttachPlan(option.loadPreparedTlsMaterial()),
            socketServerEngineShellExperimentalServerKeyExchangePrivate(),
            incomingBytes: contractTlsEncodePlaintextRecord(
                ContractTlsVersion.Tls12,
                ContractTlsRecordContentType.Handshake,
                capture.encodedClientHello
            )
        )
    )
    let start = match (startOutcome.result) {
        case Some(value) => value
        case None =>
            writeSocketServerEngineShellTlsAlertIfPresent(accepted, startOutcome.alertBytes)
            throw Exception("native TLS server start failed: ${startOutcome.message}")
    }
    writeSocketServerEngineShellInitialTlsHandshake(accepted, start.records)
    let finishOutcome = contractTryTls13FinishIncrementalHttpServerHandshake(
        ContractTls13IncrementalServerFinishRequest(
            start.continuation,
            start.continuation.pendingBytes,
            readSocketServerEngineShellTlsRecord(accepted)
        )
    )
    let ready = match (finishOutcome.runtime) {
        case Some(value) => value
        case None =>
            writeSocketServerEngineShellTlsAlertIfPresent(accepted, finishOutcome.alertBytes)
            throw Exception("native TLS client Finished verification failed: ${finishOutcome.message}")
    }
    let session = ready.session
    if (let Some(hook) <- tlsAcceptedSessionReadyHook) {
        hook(session)
    }
    let applicationProtocol = selectNativeTlsApplicationProtocol(
        session.result.negotiatedAlpn
    )
    if (applicationProtocol == NativeTlsApplicationProtocol.Http11) {
        serveSocketServerEngineShellStableTlsH1SocketTurn(
            accepted,
            session,
            option,
            app
        )
        return
    }
    let hpackDecoderState =
        ServerJinguiAcceptedTransportH2HpackDecoderState()
    let requestAccumulator =
        option.buildJinguiAcceptedTransportApplicationDataH2HeadersPlusDataLogicalRequestAccumulator(
            session,
            hpackDecoderState: Some(hpackDecoderState)
        )
    var servedTurns: Int64 = 0
    var moreTurns = true
    while (moreTurns && !accepted.isClosed()) {
        try {
            let _ =
                option.serveJinguiAcceptedTransportSessionAcceptedSocketApplicationDataFragmentedRecordWireH2HeadersPlusDataRequestTurn(
                    session,
                    accepted,
                    app,
                    readChunkSize: 4096,
                    maxFragmentLen: 16384,
                    closeSocketAfterTurn: false,
                    hpackDecoderState: Some(hpackDecoderState),
                    requestAccumulator: Some(requestAccumulator)
                )
            servedTurns += 1
        } catch (e: Exception) {
            if (servedTurns == 0) {
                throw e
            }
            if (
                isSocketServerEngineShellStableTlsH2ConnectionEndError(
                    e.message
                )
            ) {
                moreTurns = false
            } else {
                throw e
            }
        }
    }
}

func writeSocketServerEngineShellInitialTlsHandshake(
    socket: TcpSocket,
    records: Array<Array<Byte>>
): Unit {
    for (record in records) {
        socket.write(serverEngineByteToUInt8Array(record))
    }
}

func writeSocketServerEngineShellTlsAlertIfPresent(
    socket: TcpSocket,
    alertBytes: Array<Byte>
): Unit {
    if (alertBytes.size > 0) {
        socket.write(serverEngineByteToUInt8Array(alertBytes))
    }
}

func readSocketServerEngineShellTlsRecord(socket: TcpSocket): Array<Byte> {
    let header = readSocketServerEngineShellExactly(socket, 5)
    let payloadLength = (Int64(header[3]) << 8) + Int64(header[4])
    if (payloadLength > 18432) {
        throw Exception("native TLS record payload exceeds bounded limit")
    }
    let payload = readSocketServerEngineShellExactly(socket, payloadLength)
    let out = ArrayList<Byte>()
    for (value in header) {
        out.add(value)
    }
    for (value in payload) {
        out.add(value)
    }
    out.toArray()
}

func readSocketServerEngineShellExactly(socket: TcpSocket, length: Int64): Array<UInt8> {
    let out = Array<UInt8>(length, repeat: 0)
    var offset: Int64 = 0
    while (offset < length) {
        let chunk = Array<UInt8>(length - offset, repeat: 0)
        let count = socket.read(chunk)
        if (count <= 0) {
            throw Exception("native TLS peer closed before one complete record")
        }
        var i: Int64 = 0
        while (i < count) {
            out[offset + i] = chunk[i]
            i += 1
        }
        offset += count
    }
    out
}

func serveSocketServerEngineShellStableTlsH1SocketTurn(
    accepted: TcpSocket,
    session: ContractHttpServerAcceptedTransportSession,
    option: ServerEngineListenOption,
    app: App
): Unit {
    var turn: Int64 = 0
    while (turn < 16) {
        let requestWire = readSocketServerEngineShellStableTlsH1Request(
            accepted,
            session,
            option.maxRequestBodySize
        )
        let request = openSocketServerEngineShellRequest(requestWire)
        let closeAfterWrite = request.closeAfterResponse || turn + 1 >= 16
        let carrier = dispatchSocketServerEngineShellPlaintextHttp11Turn(
            requestWire,
            app,
            accepted.remoteAddress.toString(),
            option.maxRequestBodySize
        )
        writeSocketServerEngineShellTlsH1Response(
            accepted,
            session,
            request,
            carrier,
            closeAfterWrite
        )
        turn += 1
        if (closeAfterWrite) {
            return
        }
    }
}

func readSocketServerEngineShellStableTlsH1Request(
    accepted: TcpSocket,
    session: ContractHttpServerAcceptedTransportSession,
    maxRequestBodySize: Int64
): Array<UInt8> {
    let accumulator = JinguiAcceptedTransportRecordWireAccumulator()
    let plaintext = ArrayList<UInt8>()
    while (true) {
        let buf = Array<UInt8>(4096, repeat: 0)
        let n = accepted.read(buf)
        if (n <= 0) {
            throw Exception("native TLS H1 peer closed before one complete request")
        }
        accumulator.append(serverEngineUInt8ToByteArray(buf[..n]))
        let records = accumulator.drainCompleteRecords()
        if (records.size == 0) {
            continue
        }
        appendSocketServerEngineShellBytes(
            plaintext,
            session.recordChannel.openAndReassemble(records)
        )
        match (tryOpenSocketServerEngineShellRequest(plaintext.toArray())) {
            case Some(request) =>
                if (
                    request.bodyPlan.declaredBodyBytes > maxRequestBodySize ||
                    request.bodyPlan.prefetchedBodyBytes.size > maxRequestBodySize
                ) {
                    throw Exception("native TLS H1 request body exceeds configured body limit")
                }
                if (request.bodyPlan.framing == SocketHttp11RequestBodyFraming.Chunked) {
                    throw Exception("native TLS H1 first turn does not support chunked request bodies")
                }
                if (!request.bodyPlan.needsMoreNetworkBytes) {
                    return plaintext.toArray()
                }
            case None => ()
        }
    }
    throw Exception("native TLS H1 request read loop ended unexpectedly")
}

func dispatchSocketServerEngineShellPlaintextHttp11Turn(
    requestWire: Array<UInt8>,
    app: App,
    remoteAddress: String,
    maxRequestBodySize: Int64
): SocketServerEngineShellCurrentRequestCarrier {
    let request = openSocketServerEngineShellRequest(requestWire)
    if (request.bodyPlan.needsMoreNetworkBytes) {
        throw Exception("native TLS H1 first turn requires one complete buffered request")
    }
    if (
        request.bodyPlan.declaredBodyBytes > maxRequestBodySize ||
        request.bodyPlan.prefetchedBodyBytes.size > maxRequestBodySize
    ) {
        throw Exception("native TLS H1 request body exceeds configured body limit")
    }
    if (request.bodyPlan.trailingBufferedBytes.size > 0) {
        throw Exception("native TLS H1 first turn does not support pipelined request bytes")
    }
    let seed = buildSocketHttp11DispatchSeed(request)
    let carrier = SocketServerEngineShellCurrentRequestCarrier(
        request,
        seed,
        remoteAddress,
        request.bodyPlan.prefetchedBodyBytes
    )
    app.handleRequest(carrier)
    carrier
}

func writeSocketServerEngineShellTlsH1Response(
    socket: TcpSocket,
    session: ContractHttpServerAcceptedTransportSession,
    request: SocketHttp11SessionRequest,
    carrier: SocketServerEngineShellCurrentRequestCarrier,
    closeAfterWrite: Bool
): Unit {
    match (carrier.takeResponseBodyStream()) {
        case Some(stream) =>
            writeSocketServerEngineShellTlsH1StreamResponse(
                socket,
                session,
                request,
                carrier,
                stream,
                closeAfterWrite
            )
        case None =>
            writeSocketServerEngineShellTlsH1ApplicationData(
                socket,
                session,
                buildSocketServerEngineShellResponseWire(
                    request,
                    carrier,
                    closeAfterWrite
                )
            )
    }
}

func writeSocketServerEngineShellTlsH1StreamResponse(
    socket: TcpSocket,
    session: ContractHttpServerAcceptedTransportSession,
    request: SocketHttp11SessionRequest,
    carrier: SocketServerEngineShellCurrentRequestCarrier,
    stream: InputStream,
    closeAfterWrite: Bool
): Unit {
    try {
        let responseHeaders = carrier.responseHeadersForSocket()
        let responseHasChunkedTransfer = carrier.responseHeader("transfer-encoding") ?? ""
        let responseContentLength = carrier.responseHeader("content-length") ?? ""
        let statusCode = Int64(carrier.responseStatusCode())
        let bodyMode = if (isSocketHttp11ResponseBodyForbiddenStatus(statusCode)) {
            SocketHttp11ResponseBodyMode.Bodyless
        } else if (responseHasChunkedTransfer.toAsciiLower() == "chunked") {
            SocketHttp11ResponseBodyMode.UnknownLength
        } else {
            SocketHttp11ResponseBodyMode.KnownLength
        }
        let declaredBodyBytes = if (bodyMode == SocketHttp11ResponseBodyMode.KnownLength) {
            socketServerEngineShellDeclaredStreamLength(responseContentLength)
        } else {
            0
        }
        let plan = buildSocketHttp11ResponseWritePlan(
            request,
            statusCode,
            responseHeaders,
            bodyMode,
            declaredBodyBytes: declaredBodyBytes,
            option: SocketHttp11ResponseWriteOption(closeAfterWrite: closeAfterWrite)
        )
        let writer = SocketHttp11ResponseWriterLifecycle(plan)
        writeSocketServerEngineShellTlsH1ApplicationData(
            socket,
            session,
            writer.takeHeadBytes()
        )
        if (plan.writesPayloadBody()) {
            let buf = Array<Byte>(4096, repeat: 0)
            while (true) {
                let n = stream.read(buf)
                if (n <= 0) {
                    break
                }
                let chunk = Array<UInt8>(n, repeat: 0)
                var i: Int64 = 0
                while (i < n) {
                    chunk[i] = UInt8(buf[i])
                    i += 1
                }
                writeSocketServerEngineShellTlsH1ApplicationData(
                    socket,
                    session,
                    writer.writeBodyChunk(chunk)
                )
            }
        }
        writeSocketServerEngineShellTlsH1ApplicationData(
            socket,
            session,
            writer.finish()
        )
    } finally {
        match (stream) {
            case closable: Resource => closable.close()
            case _ => ()
        }
    }
}

func writeSocketServerEngineShellTlsH1ApplicationData(
    socket: TcpSocket,
    session: ContractHttpServerAcceptedTransportSession,
    plaintext: Array<UInt8>
): Unit {
    if (plaintext.size > 0) {
        socket.write(session.recordChannel.sealApplicationData(plaintext))
    }
}

public func isSocketServerEngineShellStableTlsH2ConnectionEndError(
    message: String
): Bool {
    if (
        message.contains("Socket is closed") ||
        message.contains("socket is closed")
    ) {
        return true
    }
    message.contains("expected one logical request before socket read ended") &&
        message.contains("bufferedRecordWireBytes=0") &&
        message.contains("bufferedH2FrameWireBytes=0") &&
        message.contains("hasOpenHeaderBlock=false") &&
        message.contains("bufferedHeaderBlockBytes=0") &&
        message.contains("bufferedBodyBytes=0")
}

func socketServerEngineShellExperimentalServerKeyExchangePrivate(): Array<Byte> {
    contractRandomBytes(32)
}

func serveSocketServerEngineShellTurns(
    listener: TcpServerSocket,
    option: ServerEngineListenOption,
    app: App,
    acceptedConnectionLimit: Int64,
    control: SocketServerEngineShellRuntimeControl
): Unit {
    var acceptedConnectionCount: Int64 = 0
    while (
        socketServerEngineShellAcceptLoopShouldContinue(
            acceptedConnectionCount,
            acceptedConnectionLimit
        ) &&
        !control.shutdownRequested()
    ) {
        try {
            let accepted = listener.accept()
            acceptedConnectionCount += 1
            control.connectionAccepted()
            spawn {
                serveSocketServerEngineShellAcceptedConnection(
                    accepted,
                    app,
                    option,
                    control
                )
            }
        } catch (e: Exception) {
            if (control.shutdownRequested()) {
                break
            }
            throw e
        }
    }
}

func socketServerEngineShellAcceptLoopShouldContinue(
    acceptedConnectionCount: Int64,
    acceptedConnectionLimit: Int64
): Bool {
    acceptedConnectionLimit <= 0 ||
        acceptedConnectionCount < acceptedConnectionLimit
}

func socketServerEngineShellAcceptedConnectionLimit(
    selectionLabel: String
): Int64 {
    match (getVariable(SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT_ENV)) {
        case Some(raw) =>
            let parsed = socketServerEngineShellParsePositiveInt64(raw.trimAscii())
            if (let Some(limit) <- parsed) {
                return limit
            }
            throw SocketServerEngineShellException(
                "${SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT_ENV} must be a positive decimal integer"
            )
        case None =>
            if (selectionLabel == "manual-opt-in") {
                1
            } else {
                0
            }
    }
}

func socketServerEngineShellParsePositiveInt64(text: String): ?Int64 {
    if (text.size == 0) {
        return None
    }
    let chars = text.toRuneArray()
    var value: Int64 = 0
    for (ch in chars) {
        if (ch < r'0' || ch > r'9') {
            return None
        }
        value = value * 10 + (Int64(UInt32(ch)) - Int64(UInt32(r'0')))
    }
    if (value <= 0) {
        return None
    }
    Some(value)
}

func serveSocketServerEngineShellAcceptedConnection(
    accepted: TcpSocket,
    app: App,
    option: ServerEngineListenOption,
    control: SocketServerEngineShellRuntimeControl
): Unit {
    try {
        accepted.writeTimeout = Some(option.writeTimeout)
        serveSocketServerEngineShellSocketTurns(
            accepted,
            app,
            option,
            control
        )
    } finally {
        if (!accepted.isClosed()) {
            accepted.close()
        }
        control.connectionClosed()
    }
}

func serveSocketServerEngineShellSocketTurns(
    socket: TcpSocket,
    app: App,
    option: ServerEngineListenOption,
    control: SocketServerEngineShellRuntimeControl
): Unit {
    var moreTurns = true
    var keepAliveWaitActive = false
    let requestHeadReadBuffer = Array<UInt8>(4096, repeat: 0)
    while (moreTurns) {
        if (keepAliveWaitActive) {
            control.keepAliveWaitStarted()
        }
        var requestStarted = false
        try {
            socket.readTimeout = Some(option.readHeaderTimeout)
            let request = readSocketServerEngineShellRequest(socket, requestHeadReadBuffer)
            if (keepAliveWaitActive) {
                control.keepAliveWaitFinished()
                keepAliveWaitActive = false
            }
            control.requestStarted()
            requestStarted = true
            socket.readTimeout = Some(option.readTimeout)
            let keepAliveAfterWrite =
                socketServerEngineShellShouldKeepAliveAfterWrite(request)
            let seed = buildSocketHttp11DispatchSeed(request)
            let requestBodyBytes = try {
                readSocketServerEngineShellRequestBodyBytes(
                    socket,
                    request,
                    option.maxRequestBodySize
                )
            } catch (e: BufferedRequestBodyTooLargeException) {
                writeSocketServerEngineShellPayloadTooLargeResponse(
                    socket,
                    request,
                    seed,
                    socket.remoteAddress.toString()
                )
                control.requestRejected(true)
                requestStarted = false
                moreTurns = false
                continue
            }
            let carrier = SocketServerEngineShellCurrentRequestCarrier(
                request,
                seed,
                socket.remoteAddress.toString(),
                requestBodyBytes,
                nativeWebSocketSocket: Some(socket)
            )
            app.handleRequest(carrier)
            if (carrier.nativeWebSocketUpgraded()) {
                control.requestCompleted()
                requestStarted = false
                moreTurns = false
                continue
            }
            let closeAfterWrite = !keepAliveAfterWrite
            writeSocketServerEngineShellResponse(
                socket,
                request,
                carrier,
                closeAfterWrite
            )
            control.requestCompleted()
            requestStarted = false
            if (keepAliveAfterWrite) {
                keepAliveWaitActive = true
            } else {
                moreTurns = false
            }
        } catch (_: SocketServerEngineShellException) {
            settleSocketServerEngineShellFailedTurn(
                control,
                keepAliveWaitActive,
                requestStarted
            )
            keepAliveWaitActive = false
            requestStarted = false
            // bad-request turn containment: malformed or incomplete request-head
            // or shell-owned body-stage error on this accepted socket — stop
            // the keep-alive loop and let the caller close the socket
            moreTurns = false
        } catch (e: Exception) {
            settleSocketServerEngineShellFailedTurn(
                control,
                keepAliveWaitActive,
                requestStarted
            )
            keepAliveWaitActive = false
            requestStarted = false
            containSocketServerEngineShellExpectedConnectionEnd(e)
            moreTurns = false
        } finally {
            if (requestStarted) {
                control.requestRejected(true)
            }
        }
    }
}

func settleSocketServerEngineShellFailedTurn(
    control: SocketServerEngineShellRuntimeControl,
    keepAliveWaitActive: Bool,
    requestStarted: Bool
): Unit {
    if (keepAliveWaitActive) {
        control.keepAliveWaitFinished()
    }
    if (requestStarted) {
        control.requestRejected(true)
    } else if (!keepAliveWaitActive) {
        control.requestRejected(false)
    }
}

func socketServerEngineShellIsExpectedConnectionEnd(error: Exception): Bool {
    match (error) {
        case _: SocketTimeoutException => true
        case _: SocketException => true
        case _ => false
    }
}

func containSocketServerEngineShellExpectedConnectionEnd(error: Exception): Unit {
    if (!socketServerEngineShellIsExpectedConnectionEnd(error)) {
        throw error
    }
}

func socketServerEngineShellShouldKeepAliveAfterWrite(
    request: SocketHttp11SessionRequest
): Bool {
    if (request.closeAfterResponse) {
        return false
    }
    match (request.head.header("connection")) {
        case Some(val) =>
            if (socketServerEngineShellConnectionHasCloseToken(val)) {
                return false
            }
            socketServerEngineShellConnectionHasKeepAliveToken(val)
        case None => socketServerEngineShellIsHttp11(request)
    }
}

func socketServerEngineShellIsHttp11(
    request: SocketHttp11SessionRequest
): Bool {
    request.head.version.trimAscii().toAsciiUpper() == "HTTP/1.1"
}

func socketServerEngineShellConnectionHasCloseToken(value: String): Bool {
    socketServerEngineShellConnectionHasToken(value, "close")
}

func socketServerEngineShellConnectionHasKeepAliveToken(value: String): Bool {
    socketServerEngineShellConnectionHasToken(value, "keep-alive")
}

func socketServerEngineShellConnectionHasToken(
    value: String,
    target: String
): Bool {
    for (token in value.split(",")) {
        let normalized = token.trimAscii().toAsciiLower()
        if (normalized == target) {
            return true
        }
    }
    false
}

func readSocketServerEngineShellRequest(
    socket: TcpSocket,
    buf: Array<UInt8>
): SocketHttp11SessionRequest {
    let session = SocketHttp11ConnectionSession()
    while (true) {
        let n = socket.read(buf)
        if (n <= 0) {
            break
        }
        session.appendHeadBytes(buf[..n])
        try {
            if (let Some(request) <- session.tryOpenRequest()) {
                return request
            }
        } catch (e: SocketHttp11HeadException) {
            throw SocketServerEngineShellException(
                "socket server engine shell request-head parse failed: ${e.message}"
            )
        } catch (e: SocketHttp11SessionException) {
            throw SocketServerEngineShellException(
                "socket server engine shell request session failed: ${e.message}"
            )
        }
    }
    throw SocketServerEngineShellException(
        "socket server engine shell requires one complete HTTP/1.1 request head before it can dispatch"
    )
}

func readSocketServerEngineShellRequestBodyBytes(
    socket: TcpSocket,
    request: SocketHttp11SessionRequest,
    maxRequestBodySize: Int64
): Array<UInt8> {
    let prefetched = socketServerEngineShellCloneBytes(request.bodyPlan.prefetchedBodyBytes)
    socketServerEngineShellEnsureRequestBodyWithinLimit(
        maxRequestBodySize,
        prefetched.size
    )
    if (!request.bodyPlan.requiresBodyStage) {
        return prefetched
    }
    if (request.bodyPlan.framing == SocketHttp11RequestBodyFraming.ContentLength) {
        if (request.bodyPlan.hasTrailingBufferedBytes()) {
            throw SocketServerEngineShellException(
                "socket server engine shell content-length body-stage first cut does not support pipelined bytes"
            )
        }
        let remaining = request.bodyPlan.remainingNetworkBodyBytes
        socketServerEngineShellEnsureRemainingRequestBodyWithinLimit(
            maxRequestBodySize,
            prefetched.size,
            remaining
        )
        if (remaining <= 0) {
            return prefetched
        }
        let tail = socketServerEngineShellReadExactBytes(socket, remaining)
        if (tail.size != remaining) {
            throw SocketServerEngineShellException(
                "socket server engine shell content-length body-stage first cut did not receive the declared body bytes"
            )
        }
        let out = ArrayList<UInt8>()
        appendSocketServerEngineShellBytes(out, prefetched)
        appendSocketServerEngineShellBytes(out, tail)
        return out.toArray()
    }
    if (request.bodyPlan.framing == SocketHttp11RequestBodyFraming.Chunked) {
        return socketServerEngineShellDecodeChunkedBody(
            socket,
            prefetched,
            maxRequestBodySize
        )
    }
    throw SocketServerEngineShellException(
        "socket server engine shell request body-stage first cut supports only Content-Length and chunked framing"
    )
}

func socketServerEngineShellEnsureRequestBodyWithinLimit(
    maxRequestBodySize: Int64,
    attemptedBytes: Int64
): Unit {
    if (maxRequestBodySize > 0 && attemptedBytes > maxRequestBodySize) {
        throw BufferedRequestBodyTooLargeException(
            maxRequestBodySize,
            attemptedBytes,
            "request body read ${attemptedBytes} bytes which exceeds limit ${maxRequestBodySize}"
        )
    }
}

func socketServerEngineShellEnsureRemainingRequestBodyWithinLimit(
    maxRequestBodySize: Int64,
    prefetchedBytes: Int64,
    remainingBytes: Int64
): Unit {
    if (maxRequestBodySize <= 0 || remainingBytes <= 0) {
        return
    }
    let remainingBudget = maxRequestBodySize - prefetchedBytes
    if (remainingBytes > remainingBudget) {
        let attemptedBytes = if (remainingBytes > maxRequestBodySize) {
            remainingBytes
        } else {
            prefetchedBytes + remainingBytes
        }
        throw BufferedRequestBodyTooLargeException(
            maxRequestBodySize,
            attemptedBytes,
            "request body read ${attemptedBytes} bytes which exceeds limit ${maxRequestBodySize}"
        )
    }
}

func socketServerEngineShellReadExactBytes(socket: TcpSocket, expectedBytes: Int64): Array<UInt8> {
    let out = ArrayList<UInt8>()
    let buf = Array<UInt8>(4096, repeat: 0)
    var remaining = expectedBytes
    while (remaining > 0) {
        let limit = if (remaining < buf.size) { remaining } else { buf.size }
        let chunk = Array<UInt8>(limit, repeat: 0)
        let n = socket.read(chunk)
        if (n <= 0) {
            break
        }
        appendSocketServerEngineShellBytes(out, chunk[..n])
        remaining -= n
    }
    out.toArray()
}

func socketServerEngineShellDecodeChunkedBody(
    socket: TcpSocket,
    prefetched: Array<UInt8>,
    maxRequestBodySize: Int64
): Array<UInt8> {
    let network = ArrayList<UInt8>()
    appendSocketServerEngineShellBytes(network, prefetched)
    let decoded = ArrayList<UInt8>()
    var cursor: Int64 = 0
    while (true) {
        let sizeLineEnd = socketServerEngineShellEnsureCrlfLine(socket, network, cursor)
        let chunkSize = socketServerEngineShellParseChunkSizeLine(network, cursor, sizeLineEnd)
        cursor = sizeLineEnd + 2
        if (chunkSize == 0) {
            cursor = socketServerEngineShellConsumeChunkedTrailers(socket, network, cursor)
            if (cursor < network.size) {
                throw SocketServerEngineShellException(
                    "socket server engine shell chunked body-stage first cut does not support pipelined bytes"
                )
            }
            return decoded.toArray()
        }
        socketServerEngineShellEnsureRemainingRequestBodyWithinLimit(
            maxRequestBodySize,
            decoded.size,
            chunkSize
        )
        socketServerEngineShellEnsureBufferedBytes(socket, network, cursor + chunkSize + 2)
        var i: Int64 = 0
        while (i < chunkSize) {
            decoded.add(network[cursor + i])
            i += 1
        }
        cursor += chunkSize
        if (network[cursor] != UInt8(13) || network[cursor + 1] != UInt8(10)) {
            throw SocketServerEngineShellException(
                "socket server engine shell chunked body-stage first cut requires CRLF after each chunk payload"
            )
        }
        cursor += 2
    }
    throw SocketServerEngineShellException(
        "socket server engine shell chunked body-stage first cut reached an unreachable decoder state"
    )
}

func writeSocketServerEngineShellPayloadTooLargeResponse(
    socket: TcpSocket,
    request: SocketHttp11SessionRequest,
    seed: SocketHttp11DispatchSeed,
    remoteAddress: String
): Unit {
    let carrier = SocketServerEngineShellCurrentRequestCarrier(
        request,
        seed,
        remoteAddress,
        Array<UInt8>(0, repeat: 0)
    )
    carrier.setResponseStatus(413)
    carrier.setResponseHeader("content-type", "text/plain; charset=utf-8")
    carrier.setResponseString("Payload Too Large")
    let responseWire = buildSocketServerEngineShellResponseWire(
        request,
        carrier,
        true
    )
    if (responseWire.size > 0) {
        socket.write(responseWire)
    }
}

func socketServerEngineShellConsumeChunkedTrailers(
    socket: TcpSocket,
    network: ArrayList<UInt8>,
    start: Int64
): Int64 {
    var cursor = start
    while (true) {
        let lineEnd = socketServerEngineShellEnsureCrlfLine(socket, network, cursor)
        if (lineEnd == cursor) {
            return lineEnd + 2
        }
        socketServerEngineShellValidateChunkedTrailerLine(network, cursor, lineEnd)
        cursor = lineEnd + 2
    }
    throw SocketServerEngineShellException(
        "socket server engine shell chunked body-stage first cut reached an unreachable trailer state"
    )
}

func socketServerEngineShellValidateChunkedTrailerLine(
    network: ArrayList<UInt8>,
    start: Int64,
    end: Int64
): Unit {
    let colon = socketServerEngineShellFindByteInRange(network, start, end, UInt8(58))
    if (colon <= start) {
        throw SocketServerEngineShellException(
            "socket server engine shell chunked body-stage first cut received an invalid trailer line"
        )
    }
    var i = start
    while (i < colon) {
        if (!socketServerEngineShellIsHttp11TokenByte(network[i])) {
            throw SocketServerEngineShellException(
                "socket server engine shell chunked body-stage first cut received an invalid trailer line"
            )
        }
        i += 1
    }
}

func socketServerEngineShellEnsureCrlfLine(
    socket: TcpSocket,
    network: ArrayList<UInt8>,
    start: Int64
): Int64 {
    while (true) {
        let found = socketServerEngineShellFindCrlf(network, start)
        if (found >= 0) {
            return found
        }
        if (socketServerEngineShellReadMore(socket, network) <= 0) {
            throw SocketServerEngineShellException(
                "socket server engine shell chunked body-stage first cut received an incomplete chunk line"
            )
        }
    }
    throw SocketServerEngineShellException(
        "socket server engine shell chunked body-stage first cut reached an unreachable line state"
    )
}

func socketServerEngineShellFindCrlf(network: ArrayList<UInt8>, start: Int64): Int64 {
    var i = start
    while (i + 1 < network.size) {
        if (network[i] == UInt8(13) && network[i + 1] == UInt8(10)) {
            return i
        }
        i += 1
    }
    -1
}

func socketServerEngineShellFindByteInRange(
    network: ArrayList<UInt8>,
    start: Int64,
    end: Int64,
    target: UInt8
): Int64 {
    var i = start
    while (i < end) {
        if (network[i] == target) {
            return i
        }
        i += 1
    }
    -1
}

func socketServerEngineShellIsHttp11TokenByte(value: UInt8): Bool {
    if (
        (value >= UInt8(48) && value <= UInt8(57)) ||
        (value >= UInt8(65) && value <= UInt8(90)) ||
        (value >= UInt8(97) && value <= UInt8(122))
    ) {
        return true
    }
    value == UInt8(33) ||
    value == UInt8(35) ||
    value == UInt8(36) ||
    value == UInt8(37) ||
    value == UInt8(38) ||
    value == UInt8(39) ||
    value == UInt8(42) ||
    value == UInt8(43) ||
    value == UInt8(45) ||
    value == UInt8(46) ||
    value == UInt8(94) ||
    value == UInt8(95) ||
    value == UInt8(96) ||
    value == UInt8(124) ||
    value == UInt8(126)
}

func socketServerEngineShellEnsureBufferedBytes(
    socket: TcpSocket,
    network: ArrayList<UInt8>,
    requiredSize: Int64
): Unit {
    while (network.size < requiredSize) {
        if (socketServerEngineShellReadMore(socket, network) <= 0) {
            throw SocketServerEngineShellException(
                "socket server engine shell chunked body-stage first cut received an incomplete chunk payload"
            )
        }
    }
}

func socketServerEngineShellReadMore(socket: TcpSocket, out: ArrayList<UInt8>): Int64 {
    let buf = Array<UInt8>(4096, repeat: 0)
    let n = socket.read(buf)
    if (n > 0) {
        appendSocketServerEngineShellBytes(out, buf[..n])
    }
    n
}

func socketServerEngineShellParseChunkSizeLine(
    network: ArrayList<UInt8>,
    start: Int64,
    end: Int64
): Int64 {
    var i = start
    var seenDigit = false
    var out: Int64 = 0
    while (i < end) {
        let b = network[i]
        if (b == UInt8(59)) {
            break
        }
        let digit = socketServerEngineShellHexDigitValue(b)
        if (digit < 0) {
            throw SocketServerEngineShellException(
                "socket server engine shell chunked body-stage first cut received an invalid chunk size"
            )
        }
        seenDigit = true
        out = out * 16 + digit
        i += 1
    }
    if (!seenDigit) {
        throw SocketServerEngineShellException(
            "socket server engine shell chunked body-stage first cut requires a chunk size"
        )
    }
    out
}

func socketServerEngineShellHexDigitValue(b: UInt8): Int64 {
    if (b >= UInt8(48) && b <= UInt8(57)) {
        return Int64(b) - Int64(UInt8(48))
    }
    if (b >= UInt8(65) && b <= UInt8(70)) {
        return Int64(b) - Int64(UInt8(65)) + 10
    }
    if (b >= UInt8(97) && b <= UInt8(102)) {
        return Int64(b) - Int64(UInt8(97)) + 10
    }
    -1
}

func openSocketServerEngineShellRequest(requestWire: Array<UInt8>): SocketHttp11SessionRequest {
    match (tryOpenSocketServerEngineShellRequest(requestWire)) {
        case Some(request) => request
        case None =>
            throw SocketServerEngineShellException(
                "socket server engine shell requires one complete HTTP/1.1 request head before it can dispatch"
            )
    }
}

func tryOpenSocketServerEngineShellRequest(
    requestWire: Array<UInt8>
): ?SocketHttp11SessionRequest {
    let session = SocketHttp11ConnectionSession()
    session.appendHeadBytes(requestWire)
    try {
        session.tryOpenRequest()
    } catch (e: SocketHttp11HeadException) {
        throw SocketServerEngineShellException(
            "socket server engine shell request-head parse failed: ${e.message}"
        )
    } catch (e: SocketHttp11SessionException) {
        throw SocketServerEngineShellException(
            "socket server engine shell request session failed: ${e.message}"
        )
    }
}

func buildSocketServerEngineShellResponseWire(
    request: SocketHttp11SessionRequest,
    carrier: SocketServerEngineShellCurrentRequestCarrier,
    closeAfterWrite: Bool
): Array<UInt8> {
    let responseBytes = carrier.responseBodyBytes()
    let responseHeaders = carrier.responseHeadersForSocket()
    let responseHasChunkedTransfer = carrier.responseHeader("transfer-encoding") ?? ""
    let responseContentLength = carrier.responseHeader("content-length") ?? ""
    let statusCode = Int64(carrier.responseStatusCode())
    let bodyMode = if (isSocketHttp11ResponseBodyForbiddenStatus(statusCode)) {
        SocketHttp11ResponseBodyMode.Bodyless
    } else if (responseHasChunkedTransfer.toAsciiLower() == "chunked") {
        SocketHttp11ResponseBodyMode.UnknownLength
    } else {
        SocketHttp11ResponseBodyMode.KnownLength
    }
    let declaredBodyBytes = if (bodyMode == SocketHttp11ResponseBodyMode.KnownLength) {
        socketServerEngineShellKnownLengthBytesForResponse(
            request,
            responseBytes.size,
            responseContentLength
        )
    } else {
        0
    }
    let plan = buildSocketHttp11ResponseWritePlan(
        request,
        statusCode,
        responseHeaders,
        bodyMode,
        declaredBodyBytes: declaredBodyBytes,
        option: SocketHttp11ResponseWriteOption(closeAfterWrite: closeAfterWrite)
    )
    let writer = SocketHttp11ResponseWriterLifecycle(plan)
    let out = ArrayList<UInt8>()
    appendSocketServerEngineShellBytes(out, writer.takeHeadBytes())
    if (plan.writesPayloadBody() && responseBytes.size > 0) {
        appendSocketServerEngineShellBytes(out, writer.writeBodyChunk(responseBytes))
    }
    appendSocketServerEngineShellBytes(out, writer.finish())
    out.toArray()
}

func writeSocketServerEngineShellResponse(
    socket: TcpSocket,
    request: SocketHttp11SessionRequest,
    carrier: SocketServerEngineShellCurrentRequestCarrier,
    closeAfterWrite: Bool
): Unit {
    match (carrier.takeResponseBodyStream()) {
        case Some(stream) =>
            writeSocketServerEngineShellStreamResponse(
                socket,
                request,
                carrier,
                stream,
                closeAfterWrite
            )
        case None =>
            writeSocketServerEngineShellBufferedResponse(
                socket,
                request,
                carrier,
                closeAfterWrite
            )
    }
}

func writeSocketServerEngineShellBufferedResponse(
    socket: TcpSocket,
    request: SocketHttp11SessionRequest,
    carrier: SocketServerEngineShellCurrentRequestCarrier,
    closeAfterWrite: Bool
): Unit {
    let responseBytes = carrier.responseBodyBytes()
    let responseHeaders = carrier.responseHeadersForSocket()
    let responseHasChunkedTransfer = carrier.responseHeader("transfer-encoding") ?? ""
    let responseContentLength = carrier.responseHeader("content-length") ?? ""
    let statusCode = Int64(carrier.responseStatusCode())
    let bodyMode = if (isSocketHttp11ResponseBodyForbiddenStatus(statusCode)) {
        SocketHttp11ResponseBodyMode.Bodyless
    } else if (responseHasChunkedTransfer.toAsciiLower() == "chunked") {
        SocketHttp11ResponseBodyMode.UnknownLength
    } else {
        SocketHttp11ResponseBodyMode.KnownLength
    }
    let declaredBodyBytes = if (bodyMode == SocketHttp11ResponseBodyMode.KnownLength) {
        socketServerEngineShellKnownLengthBytesForResponse(
            request,
            responseBytes.size,
            responseContentLength
        )
    } else {
        0
    }
    let plan = buildSocketHttp11ResponseWritePlan(
        request,
        statusCode,
        responseHeaders,
        bodyMode,
        declaredBodyBytes: declaredBodyBytes,
        option: SocketHttp11ResponseWriteOption(closeAfterWrite: closeAfterWrite)
    )
    let writer = SocketHttp11ResponseWriterLifecycle(plan)
    let head = writer.takeHeadBytes()
    if (head.size > 0) {
        socket.write(head)
    }
    if (plan.writesPayloadBody() && responseBytes.size > 0) {
        let bodyWire = writer.writeBodyChunkBorrowedForSocket(responseBytes)
        if (bodyWire.size > 0) {
            socket.write(bodyWire)
        }
    }
    let tail = writer.finish()
    if (tail.size > 0) {
        socket.write(tail)
    }
}

func writeSocketServerEngineShellStreamResponse(
    socket: TcpSocket,
    request: SocketHttp11SessionRequest,
    carrier: SocketServerEngineShellCurrentRequestCarrier,
    stream: InputStream,
    closeAfterWrite: Bool
): Unit {
    try {
        let responseHeaders = carrier.responseHeadersForSocket()
        let responseHasChunkedTransfer =
            carrier.responseHeader("transfer-encoding") ?? ""
        let responseContentLength = carrier.responseHeader("content-length") ?? ""
        let statusCode = Int64(carrier.responseStatusCode())
        let bodyMode = if (isSocketHttp11ResponseBodyForbiddenStatus(statusCode)) {
            SocketHttp11ResponseBodyMode.Bodyless
        } else if (responseHasChunkedTransfer.toAsciiLower() == "chunked") {
            SocketHttp11ResponseBodyMode.UnknownLength
        } else {
            SocketHttp11ResponseBodyMode.KnownLength
        }
        let declaredBodyBytes = if (bodyMode == SocketHttp11ResponseBodyMode.KnownLength) {
            socketServerEngineShellDeclaredStreamLength(responseContentLength)
        } else {
            0
        }
        let plan = buildSocketHttp11ResponseWritePlan(
            request,
            statusCode,
            responseHeaders,
            bodyMode,
            declaredBodyBytes: declaredBodyBytes,
            option: SocketHttp11ResponseWriteOption(closeAfterWrite: closeAfterWrite)
        )
        let writer = SocketHttp11ResponseWriterLifecycle(plan)
        let head = writer.takeHeadBytes()
        if (head.size > 0) {
            socket.write(head)
        }
        if (plan.writesPayloadBody()) {
            let buf = Array<Byte>(4096, repeat: 0)
            while (true) {
                let n = stream.read(buf)
                if (n <= 0) {
                    break
                }
                let chunk = Array<UInt8>(n, repeat: 0)
                var i: Int64 = 0
                while (i < n) {
                    chunk[i] = UInt8(buf[i])
                    i += 1
                }
                let wire = writer.writeBodyChunk(chunk)
                if (wire.size > 0) {
                    socket.write(wire)
                }
            }
        }
        let tail = writer.finish()
        if (tail.size > 0) {
            socket.write(tail)
        }
    } finally {
        match (stream) {
            case closable: Resource => closable.close()
            case _ => ()
        }
    }
}

func socketServerEngineShellDeclaredStreamLength(responseContentLength: String): Int64 {
    let declared = responseContentLength.trimAscii()
    match (socketServerEngineShellParseNonNegativeInt64(declared)) {
        case Some(value) => value
        case None =>
            throw SocketServerEngineShellException(
                "socket server engine shell known-length stream requires a non-negative content-length"
            )
    }
}

func socketServerEngineShellKnownLengthBytesForResponse(
    request: SocketHttp11SessionRequest,
    responseBytesSize: Int64,
    responseContentLength: String
): Int64 {
    if (request.head.method.trimAscii().toAsciiUpper() != "HEAD") {
        return responseBytesSize
    }
    let declared = responseContentLength.trimAscii()
    if (declared.size == 0) {
        return responseBytesSize
    }
    match (socketServerEngineShellParseNonNegativeInt64(declared)) {
        case Some(value) => value
        case None =>
            throw SocketServerEngineShellException(
                "socket server engine shell HEAD response content-length must be a non-negative decimal integer"
            )
    }
}

func socketServerEngineShellParseNonNegativeInt64(text: String): ?Int64 {
    if (text.size == 0) {
        return None
    }
    let chars = text.toRuneArray()
    var value: Int64 = 0
    for (ch in chars) {
        if (ch < r'0' || ch > r'9') {
            return None
        }
        value = value * 10 + (Int64(UInt32(ch)) - Int64(UInt32(r'0')))
    }
    Some(value)
}

func appendSocketServerEngineShellBytes(out: ArrayList<UInt8>, bytes: Array<UInt8>): Unit {
    for (b in bytes) {
        out.add(b)
    }
}

func socketServerEngineShellCloneBytes(bytes: Array<UInt8>): Array<UInt8> {
    if (bytes.size == 0) {
        return Array<UInt8>(0, repeat: 0)
    }
    let out = Array<UInt8>(bytes.size, repeat: 0)
    var i: Int64 = 0
    while (i < bytes.size) {
        out[i] = bytes[i]
        i += 1
    }
    out
}

func socketServerEngineShellReadInputStream(stream: InputStream): Array<UInt8> {
    let out = ArrayList<UInt8>()
    let buf = Array<Byte>(4096, repeat: 0)
    while (true) {
        let n = stream.read(buf)
        if (n <= 0) {
            break
        }
        var i: Int64 = 0
        while (i < n) {
            out.add(UInt8(buf[i]))
            i += 1
        }
    }
    out.toArray()
}

func socketServerEngineShellReadQueryValue(queryString: String, key: String): ?String {
    readDecodedUrlQueryValue(queryString, key)
}

class SocketServerEngineShellBytesInputStream <: InputStream {
    let bytes: Array<UInt8>
    var offset: Int64 = 0

    init(bytes: Array<UInt8>) {
        this.bytes = socketServerEngineShellCloneBytes(bytes)
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

class SocketServerEngineShellResponseTransportWriter <: ResponseTransportWriter {
    let carrier: SocketServerEngineShellCurrentRequestCarrier

    init(carrier: SocketServerEngineShellCurrentRequestCarrier) {
        this.carrier = carrier
    }

    public override func write(data: Array<UInt8>): Unit {
        carrier.appendResponseBodyBytes(data)
    }
}

class SocketServerEngineShellCurrentRequestCarrier <: CurrentRequestCarrier & NativeWebSocketUpgradeCarrier & PreparedResponseBodyCarrier {
    let request: SocketHttp11SessionRequest
    let seed: SocketHttp11DispatchSeed
    let remoteAddress: String
    let requestHeadersValue: HttpHeaders
    let requestBodyBytesValue: Array<UInt8>
    let responseHeadersValue: HashMap<String, String>
    let nativeWebSocketSocket: ?TcpSocket
    var responseBodyBytesValue: Array<UInt8> = Array<UInt8>(0, repeat: 0)
    var responseBodyAppendBufferValue: ?ArrayList<UInt8> = None
    var responseBodyStreamValue: ?InputStream = None
    var responseStatusCodeValue: UInt16 = 200
    var nativeWebSocketUpgradedValue: Bool = false

    init(
        request: SocketHttp11SessionRequest,
        seed: SocketHttp11DispatchSeed,
        remoteAddress: String,
        requestBodyBytes: Array<UInt8>,
        nativeWebSocketSocket!: ?TcpSocket = None
    ) {
        this.request = request
        this.seed = seed
        this.remoteAddress = remoteAddress
        this.requestHeadersValue = buildSocketServerEngineShellRequestHeaders(request)
        this.requestBodyBytesValue = socketServerEngineShellCloneBytes(requestBodyBytes)
        this.responseHeadersValue = HashMap<String, String>()
        this.nativeWebSocketSocket = nativeWebSocketSocket
        this.responseBodyBytesValue = Array<UInt8>(0, repeat: 0)
        this.responseBodyAppendBufferValue = None
    }

    public override func rawHttpContext(): HttpContext {
        throw SocketServerEngineShellException(
            "socket server engine shell does not expose raw HttpContext"
        )
    }

    public override func upgradeWebSocketRaw(): WebSocket {
        throw SocketServerEngineShellException(
            "socket server engine shell cleartext first-runnable path does not support WebSocket upgrade"
        )
    }

    public override func upgradeNativeWebSocket(subProtocols: Array<String>): WsConn {
        let socket = nativeWebSocketSocket ?? throw SocketServerEngineShellException(
            "socket server engine shell request does not own an upgradeable cleartext socket"
        )
        let connection = openNativeWebSocketConnection(
            socket,
            requestMethod(),
            requestVersionString(),
            requestHeaderValue("connection") ?? "",
            requestHeaderValue("upgrade") ?? "",
            requestHeaderValue("sec-websocket-version") ?? "",
            requestHeaderValue("sec-websocket-key") ?? "",
            requestHeaderValue("sec-websocket-protocol") ?? "",
            subProtocols
        )
        nativeWebSocketUpgradedValue = true
        WsConn(connection)
    }

    func nativeWebSocketUpgraded(): Bool {
        nativeWebSocketUpgradedValue
    }

    public override func openResponseTransportWriterRaw(): ResponseTransportWriter {
        SocketServerEngineShellResponseTransportWriter(this)
    }

    public override func requestMethod(): String {
        request.head.method.trimAscii().toAsciiUpper()
    }

    public override func requestPath(): String {
        match (seed.dispatchPath) {
            case Some(path) => path
            case None => seed.rawTarget
        }
    }

    public override func requestUrlString(): String {
        seed.normalizedDispatchTarget()
    }

    public override func requestVersionString(): String {
        request.head.version
    }

    public override func requestRemoteAddr(): String {
        remoteAddress
    }

    public override func requestQueryValue(key: String): ?String {
        socketServerEngineShellReadQueryValue(seed.queryString, key)
    }

    public override func requestFormValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestHeaderValue(key: String): ?String {
        request.head.header(key)
    }

    public override func requestHeaders(): HttpHeaders {
        requestHeadersValue
    }

    public override func requestTrailers(): HttpHeaders {
        HttpHeaders()
    }

    public override func requestBodyStream(): InputStream {
        SocketServerEngineShellBytesInputStream(requestBodyBytesValue)
    }

    public override func requestBodySize(): ?Int64 {
        match (request.bodyPlan.framing) {
            case SocketHttp11RequestBodyFraming.Chunked => None
            case SocketHttp11RequestBodyFraming.ContentLength =>
                Some(request.bodyPlan.declaredBodyBytes)
            case SocketHttp11RequestBodyFraming.Bodyless => Some(0)
        }
    }

    public override func setResponseStatus(code: UInt16): Unit {
        ensureSocketServerEngineShellFinalStatusSupported(code)
        responseStatusCodeValue = code
    }

    public override func setResponseHeader(key: String, value: String): Unit {
        responseHeadersValue.add(key.trimAscii().toAsciiLower(), value.trimAscii())
    }

    public override func addResponseHeaders(headers: HttpHeaders): Unit {
        for ((name, values) in headers) {
            for (value in values) {
                setResponseHeader(name, value)
            }
        }
    }

    public override func setResponseString(body: String): Unit {
        closeResponseBodyStreamIfPresent()
        replaceResponseBodyOwnedBytes(body.toArray())
    }

    public override func setResponseBytes(data: Array<UInt8>): Unit {
        closeResponseBodyStreamIfPresent()
        replaceResponseBodyBytes(data)
    }

    public override func setPreparedResponseBody(body: PreparedResponseBody): Unit {
        closeResponseBodyStreamIfPresent()
        replaceResponseBodyOwnedBytes(body.borrowBytesForTransport())
    }

    public override func attachResponseBodyStream(stream: InputStream): Unit {
        closeResponseBodyStreamIfPresent()
        responseBodyBytesValue = Array<UInt8>(0, repeat: 0)
        responseBodyAppendBufferValue = None
        responseBodyStreamValue = Some(stream)
    }

    public func responseStatusCode(): UInt16 {
        responseStatusCodeValue
    }

    public func responseHeader(name: String): ?String {
        responseHeadersValue.get(name.trimAscii().toAsciiLower())
    }

    public func responseHeadersForSocket(): Array<SocketHttp11Header> {
        let out = ArrayList<SocketHttp11Header>()
        for ((name, value) in responseHeadersValue) {
            let normalized = name.trimAscii().toAsciiLower()
            if (normalized == "content-length" || normalized == "transfer-encoding" || normalized == "connection") {
                continue
            }
            out.add(SocketHttp11Header(normalized, value.trimAscii()))
        }
        out.toArray()
    }

    public func responseBodyBytes(): Array<UInt8> {
        if (let Some(buffer) <- responseBodyAppendBufferValue) {
            return buffer.toArray()
        }
        responseBodyBytesValue
    }

    public func takeResponseBodyStream(): ?InputStream {
        let stream = responseBodyStreamValue
        responseBodyStreamValue = None
        stream
    }

    func appendResponseBodyBytes(bytes: Array<UInt8>): Unit {
        if (let Some(buffer) <- responseBodyAppendBufferValue) {
            for (b in bytes) {
                buffer.add(b)
            }
            return
        }
        let buffer = ArrayList<UInt8>()
        for (b in responseBodyBytesValue) {
            buffer.add(b)
        }
        for (b in bytes) {
            buffer.add(b)
        }
        responseBodyBytesValue = Array<UInt8>(0, repeat: 0)
        responseBodyAppendBufferValue = Some(buffer)
    }

    func replaceResponseBodyBytes(bytes: Array<UInt8>): Unit {
        replaceResponseBodyOwnedBytes(socketServerEngineShellCloneBytes(bytes))
    }

    func replaceResponseBodyOwnedBytes(bytes: Array<UInt8>): Unit {
        responseBodyBytesValue = bytes
        responseBodyAppendBufferValue = None
    }

    func closeResponseBodyStreamIfPresent(): Unit {
        if (let Some(stream) <- responseBodyStreamValue) {
            match (stream) {
                case closable: Resource => closable.close()
                case _ => ()
            }
        }
        responseBodyStreamValue = None
    }
}

func ensureSocketServerEngineShellFinalStatusSupported(code: UInt16): Unit {
    let numeric = Int64(code)
    if (numeric < 100 || numeric > 999) {
        throw SocketServerEngineShellException(
            "socket server engine shell final route response status must be between 100 and 999"
        )
    }
    if (numeric >= 100 && numeric < 200) {
        throw SocketServerEngineShellException(
            "socket server engine shell does not support informational 1xx statuses as final route responses"
        )
    }
}

func buildSocketServerEngineShellRequestHeaders(request: SocketHttp11SessionRequest): HttpHeaders {
    let headers = HttpHeaders()
    for (header in request.head.headers) {
        headers.add(header.name, header.value)
    }
    headers
}
