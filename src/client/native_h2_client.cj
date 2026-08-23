package ignite.client

import ignite.native_h2.{
    NativeH2ClientConnection,
    NativeH2ClientException,
    NativeH2ClientRequest,
    NativeH2ClientResponse,
    NativeH2MultiplexResponse,
    NativeH2MultiplexSession,
    NativeH2ClientStreamedResponse,
    NativeH2Header,
    NATIVE_H2_DEFAULT_PRIORITY_HINT,
    NATIVE_H2_MAX_PRIORITY_HINT
}
import std.collection.{ArrayList, HashMap}
import std.io.InputStream
import std.net.TcpSocket
import std.sync.Mutex
import stdx.net.http.HttpHeaders
import ignite.transport.NativeByteTransport

let NATIVE_H2_CLIENT_BACKEND = "ignite-native-h2-client"
let NATIVE_H2_REST_BATCH_LIMIT: Int64 = 32

class NativeH2SessionTransport {
    let connection: NativeH2PooledConnection
    let protocol: NativeH2MultiplexSession

    init(
        connection: NativeH2PooledConnection,
        protocol: NativeH2MultiplexSession
    ) {
        this.connection = connection
        this.protocol = protocol
    }
}

/// One buffered request inside an explicit RestClient H2 multiplex turn.
public class NativeH2BatchRequest {
    public let method: String
    public let url: String
    let requestHeaders = HashMap<String, String>()
    var requestBody = Array<UInt8>()
    var requestBodyStream: ?InputStream = None
    var requestBodyStreamLength: Int64 = 0
    var requestBodyStreamHasKnownLength = false
    var responseDeadlineMs: Int64 = 0
    var requestPriorityHint: Int64 = NATIVE_H2_DEFAULT_PRIORITY_HINT

    public init(method: String, url: String) {
        this.method = method
        this.url = url
    }

    public func header(name: String, value: String): NativeH2BatchRequest {
        removeNativeH1Header(requestHeaders, name.trimAscii().toAsciiLower())
        requestHeaders.add(name, value)
        this
    }

    public func bodyBytes(data: Array<UInt8>): NativeH2BatchRequest {
        requestBody = cloneNativeH1Bytes(data)
        requestBodyStream = None
        requestBodyStreamLength = 0
        requestBodyStreamHasKnownLength = false
        this
    }

    public func bodyString(data: String): NativeH2BatchRequest {
        bodyBytes(data.toArray())
    }

    /// Attaches a one-pass request stream with an exact Content-Length.
    ///
    /// The caller retains ownership of the stream. Native H2 consumes it once
    /// and never replays it for retries or redirects.
    public func bodyStream(
        stream: InputStream,
        contentLength: Int64
    ): NativeH2BatchRequest {
        if (contentLength < 0) {
            throw IllegalArgumentException("contentLength must be >= 0")
        }
        requestBody = Array<UInt8>()
        requestBodyStream = Some(stream)
        requestBodyStreamLength = contentLength
        requestBodyStreamHasKnownLength = true
        this
    }

    /// Attaches a one-pass request stream whose length is determined by EOF.
    ///
    /// The caller retains ownership of the stream. Native H2 consumes it once,
    /// does not replay it for retries or redirects, and never closes it.
    public func bodyStream(stream: InputStream): NativeH2BatchRequest {
        requestBody = Array<UInt8>()
        requestBodyStream = Some(stream)
        requestBodyStreamLength = 0
        requestBodyStreamHasKnownLength = false
        this
    }

    /// Bounds stream admission and response lifetime without changing the shared
    /// H2 connection timeout.
    public func deadline(timeout: Duration): NativeH2BatchRequest {
        let milliseconds = timeout.toMilliseconds()
        if (milliseconds <= 0) {
            throw IllegalArgumentException("native H2 request deadline must be positive")
        }
        responseDeadlineMs = milliseconds
        this
    }

    /// Sets a bounded local outbound scheduling hint for multiplexed H2 DATA.
    /// Higher values are preferred; equal values remain fair. This is not
    /// RFC 7540 dependency-tree or browser priority interoperability.
    public func priority(value: Int64): NativeH2BatchRequest {
        if (value < NATIVE_H2_DEFAULT_PRIORITY_HINT ||
            value > NATIVE_H2_MAX_PRIORITY_HINT) {
            throw IllegalArgumentException(
                "native H2 priority hint must be between 0 and ${NATIVE_H2_MAX_PRIORITY_HINT}"
            )
        }
        requestPriorityHint = value
        this
    }

    func headersSnapshot(): HashMap<String, String> {
        cloneNativeH1Headers(requestHeaders)
    }

    func bodySnapshot(): Array<UInt8> {
        cloneNativeH1Bytes(requestBody)
    }

    func bodyStreamSnapshot(): ?InputStream {
        requestBodyStream
    }

    func bodyStreamLengthSnapshot(): Int64 {
        requestBodyStreamLength
    }

    func bodyStreamHasKnownLengthSnapshot(): Bool {
        requestBodyStreamHasKnownLength
    }

    func deadlineMsSnapshot(): Int64 {
        responseDeadlineMs
    }

    func priorityHintSnapshot(): Int64 {
        requestPriorityHint
    }
}

/// Explicit Preview session for independent cleartext H2 request/response leases.
public class NativeH2Session {
    let origin: String
    let resolveUrl: (String) -> String
    let defaultHeaders: HashMap<String, String>
    let cookieStore: ?CookieStore
    var protocol: NativeH2MultiplexSession
    var connection: NativeH2PooledConnection
    let pool: NativeH2ClientConnectionPool
    let reopen: () -> NativeH2SessionTransport
    let responseHooks: ArrayList<ClientResponseHook>
    let errorHooks: ArrayList<ClientErrorHook>
    let closeHook: () -> Unit
    let mtx = Mutex()
    var closed = false
    var activeCalls: Int64 = 0
    var reconnectReplayActive = false

    init(
        origin: String,
        resolveUrl: (String) -> String,
        defaultHeaders: HashMap<String, String>,
        cookieStore: ?CookieStore,
        protocol: NativeH2MultiplexSession,
        connection: NativeH2PooledConnection,
        pool: NativeH2ClientConnectionPool,
        reopen: () -> NativeH2SessionTransport,
        responseHooks: ArrayList<ClientResponseHook>,
        errorHooks: ArrayList<ClientErrorHook>,
        closeHook: () -> Unit
    ) {
        this.origin = origin
        this.resolveUrl = resolveUrl
        this.defaultHeaders = defaultHeaders
        this.cookieStore = cookieStore
        this.protocol = protocol
        this.connection = connection
        this.pool = pool
        this.reopen = reopen
        this.responseHooks = responseHooks
        this.errorHooks = errorHooks
        this.closeHook = closeHook
    }

    /// Submits one buffered or streamed request and returns after its final
    /// response head arrives.
    ///
    /// Multiple callers may invoke this method concurrently. Each returned body is
    /// an independent one-pass lease coordinated by one connection-owned reader.
    public func send(request: NativeH2BatchRequest): ClientResponse {
        beginSend()
        try {
            sendAttempt(request)
        } finally {
            endSend()
        }
    }

    func sendAttempt(request: NativeH2BatchRequest): ClientResponse {
        try {
            let resolvedUrl = resolveUrl(request.url)
            let target = parseNativeH1Target(resolvedUrl)
            if (target.scheme != "http") {
                throw Exception(
                    "native H2 session currently requires cleartext http:// prior knowledge"
                )
            }
            if (nativeH1PoolOrigin(target) != origin) {
                throw Exception("native H2 session request must retain its opened origin")
            }
            let body = request.bodySnapshot()
            let bodyStream = request.bodyStreamSnapshot()
            let bodyStreamHasKnownLength = request.bodyStreamHasKnownLengthSnapshot()
            let bodyLength = if (bodyStream.isSome()) {
                request.bodyStreamLengthSnapshot()
            } else {
                body.size
            }

            let headers = cloneNativeH1Headers(defaultHeaders)
            for ((name, value) in request.headersSnapshot()) {
                removeNativeH1Header(headers, name.trimAscii().toAsciiLower())
                headers.add(name, value)
            }
            synchronized(mtx) {
                if (closed) {
                    throw Exception("native H2 session is closed")
                }
                if (let Some(store) <- cookieStore) {
                    if (!nativeH1HasHeader(headers, "cookie")) {
                        let cookie = store.getCookieHeader(resolvedUrl)
                        if (cookie.size > 0) {
                            headers.add("cookie", cookie)
                        }
                    }
                }
            }
            if (bodyStream.isSome() && !bodyStreamHasKnownLength) {
                removeNativeH1Header(headers, "content-length")
            } else if ((bodyLength > 0 || bodyStream.isSome()) &&
                !nativeH1HasHeader(headers, "content-length")) {
                headers.add("content-length", bodyLength.toString())
            }

            let nativeResponse = try {
                let nativeRequest = NativeH2ClientRequest(
                    request.method,
                    "http",
                    target.hostHeader,
                    target.requestTarget,
                    body: body,
                    headers: nativeH2RequestHeaders(headers),
                    priorityHint: request.priorityHintSnapshot()
                )
                match (bodyStream) {
                    case Some(stream) => if (bodyStreamHasKnownLength) {
                        protocol.sendStream(
                            nativeRequest,
                            stream,
                            bodyLength,
                            deadlineMs: request.deadlineMsSnapshot()
                        )
                    } else {
                        protocol.sendStream(
                            nativeRequest,
                            stream,
                            deadlineMs: request.deadlineMsSnapshot()
                        )
                    }
                    case None => protocol.send(
                        nativeRequest,
                        deadlineMs: request.deadlineMsSnapshot()
                    )
                }
            } catch (e: NativeH2ClientException) {
                throw nativeH2ProtocolTransportException(e)
            }
            let response = adaptNativeH2MultiplexResponse(nativeResponse)
            try {
                synchronized(mtx) {
                    if (let Some(store) <- cookieStore) {
                        store.addFromResponse(resolvedUrl, response)
                    }
                }
                for (hook in responseHooks) {
                    hook(response)
                }
                response
            } catch (e: Exception) {
                response.close()
                throw e
            }
        } catch (e: Exception) {
            for (hook in errorHooks) {
                hook(e)
            }
            throw e
        }
    }

    /// Replays an idempotent buffered request after configured response statuses.
    /// Set `reconnectOnConnectionFailure` to replace a broken transport and
    /// replay a pre-response failure. One-pass streams are never replayed.
    /// Response hooks observe every completed attempt, including drained retries.
    public func sendWithRetry(
        request: NativeH2BatchRequest,
        config!: ClientRetryConfig = ClientRetryConfig(),
        reconnectOnConnectionFailure!: Bool = false
    ): ClientResponse {
        let retryConfig = config.copy()
        let hasBodyStream = request.bodyStreamSnapshot().isSome()
        if (retryConfig.enabled && retryConfig.maxAttempts > 1 && hasBodyStream) {
            throw Exception("native H2 session cannot replay a one-pass request stream")
        }
        let replayEligible = nativeH2SessionRetryEligible(
            request.method, hasBodyStream, retryConfig
        )
        if (retryConfig.enabled && retryConfig.maxAttempts > 1 && !replayEligible) {
            throw Exception("native H2 session retry requires an idempotent request method")
        }
        let reconnectReplayEnabled = reconnectOnConnectionFailure && replayEligible
        if (reconnectReplayEnabled) {
            beginReconnectReplay()
        }
        try {
            var attempt: Int64 = 1
            while (true) {
                let response = try {
                    if (reconnectReplayEnabled) {
                        sendAttempt(request)
                    } else {
                        send(request)
                    }
                } catch (e: Exception) {
                    if (!reconnectReplayEnabled || attempt >= retryConfig.maxAttempts ||
                        transportReusable()) {
                        throw e
                    }
                    replaceBrokenTransport()
                    nativeH2SessionRetryBackoff(retryConfig, attempt)
                    attempt += 1
                    continue
                }
                if (!nativeH2SessionRetryStatus(response.status, retryConfig, attempt)) {
                    return response
                }
                response.discard()
                nativeH2SessionRetryBackoff(retryConfig, attempt)
                attempt += 1
            }
            throw Exception("native H2 session retry loop ended unexpectedly")
        } finally {
            if (reconnectReplayEnabled) {
                endReconnectReplay()
            }
        }
    }

    func beginSend(): Unit {
        synchronized(mtx) {
            if (closed) {
                throw Exception("native H2 session is closed")
            }
            if (reconnectReplayActive) {
                throw Exception("native H2 session reconnect replay is active")
            }
            activeCalls += 1
        }
    }

    func endSend(): Unit {
        synchronized(mtx) {
            if (activeCalls > 0) {
                activeCalls -= 1
            }
        }
    }

    func beginReconnectReplay(): Unit {
        synchronized(mtx) {
            if (closed) {
                throw Exception("native H2 session is closed")
            }
            if (reconnectReplayActive || activeCalls > 0 ||
                protocol.activeStreams() > 0 || protocol.pendingAdmissions() > 0) {
                throw Exception(
                    "native H2 session reconnect replay requires an idle session"
                )
            }
            reconnectReplayActive = true
        }
    }

    func endReconnectReplay(): Unit {
        synchronized(mtx) {
            reconnectReplayActive = false
        }
    }

    func transportReusable(): Bool {
        synchronized(mtx) {
            connection.reusable()
        }
    }

    func replaceBrokenTransport(): Unit {
        closeNativeH2Connection(connection)
        let replacement = reopen()
        var accepted = false
        synchronized(mtx) {
            if (!closed) {
                connection = replacement.connection
                protocol = replacement.protocol
                accepted = true
            }
        }
        if (!accepted) {
            try { let _ = replacement.protocol.close() } catch (_: Exception) {}
            closeNativeH2Connection(replacement.connection)
            throw Exception("native H2 session closed during reconnect replay")
        }
    }

    public func activeStreams(): Int64 {
        protocol.activeStreams()
    }

    public func pendingRequests(): Int64 {
        protocol.pendingAdmissions()
    }

    public func maxConcurrentStreams(): Int64 {
        protocol.maxConcurrentStreams()
    }

    public func close(): Unit {
        var shouldClose = false
        synchronized(mtx) {
            if (!closed) {
                closed = true
                shouldClose = true
            }
        }
        if (!shouldClose) {
            return
        }
        try {
            try {
                if (protocol.close() && connection.reusable()) {
                    pool.release(origin, connection)
                } else {
                    closeNativeH2Connection(connection)
                }
            } catch (_: Exception) {
                closeNativeH2Connection(connection)
            }
        } finally {
            closeHook()
        }
    }
}

class NativeH2PooledConnection {
    let socket: TcpSocket
    let protocol: NativeH2ClientConnection

    init(socket: TcpSocket) {
        this.socket = socket
        protocol = NativeH2ClientConnection(socket)
    }

    func reusable(): Bool {
        !socket.isClosed()
    }
}

class NativeH2ClientConnectionPool {
    let mtx = Mutex()
    let maxIdlePerOrigin: Int64
    var idle = HashMap<String, ArrayList<NativeH2PooledConnection>>()

    init(maxIdlePerOrigin: Int64) {
        this.maxIdlePerOrigin = if (maxIdlePerOrigin > 0) { maxIdlePerOrigin } else { 0 }
    }

    func enabled(): Bool {
        maxIdlePerOrigin > 0
    }

    func acquire(origin: String): ?NativeH2PooledConnection {
        var selected: ?NativeH2PooledConnection = None
        synchronized(mtx) {
            if (let Some(connections) <- idle.get(origin)) {
                while (connections.size > 0) {
                    let connection = connections.remove(at: connections.size - 1)
                    if (connection.reusable()) {
                        selected = Some(connection)
                        break
                    }
                    closeNativeH2Connection(connection)
                }
                if (connections.size == 0) {
                    let _ = idle.remove(origin)
                }
            }
        }
        selected
    }

    func release(origin: String, connection: NativeH2PooledConnection): Unit {
        if (!enabled() || !connection.reusable()) {
            closeNativeH2Connection(connection)
            return
        }
        var retained = false
        synchronized(mtx) {
            let connections = if (let Some(existing) <- idle.get(origin)) {
                existing
            } else {
                let created = ArrayList<NativeH2PooledConnection>()
                idle.add(origin, created)
                created
            }
            if (connections.size < maxIdlePerOrigin) {
                connections.add(connection)
                retained = true
            }
        }
        if (!retained) {
            closeNativeH2Connection(connection)
        }
    }

    func close(): Unit {
        synchronized(mtx) {
            for ((_origin, connections) in idle) {
                for (connection in connections) {
                    closeNativeH2Connection(connection)
                }
            }
            idle = HashMap<String, ArrayList<NativeH2PooledConnection>>()
        }
    }
}

func executeNativeH2Batch(
    requests: Array<NativeH2BatchRequest>,
    resolveUrl: (String) -> String,
    defaultHeaders: HashMap<String, String>,
    cookieStore: ?CookieStore,
    readTimeout: Duration,
    writeTimeout: Duration,
    pool: NativeH2ClientConnectionPool
): Array<ClientResponse> {
    if (requests.size == 0) {
        throw Exception("native H2 RestClient batch cannot be empty")
    }
    if (requests.size > NATIVE_H2_REST_BATCH_LIMIT) {
        throw Exception(
            "native H2 RestClient batch exceeds ${NATIVE_H2_REST_BATCH_LIMIT} requests"
        )
    }

    let resolvedUrls = ArrayList<String>()
    let nativeRequests = ArrayList<NativeH2ClientRequest>()
    var origin = ""
    for (request in requests) {
        let resolvedUrl = resolveUrl(request.url)
        let target = parseNativeH1Target(resolvedUrl)
        if (target.scheme != "http") {
            throw Exception(
                "native H2 RestClient batch currently requires cleartext http:// prior knowledge"
            )
        }
        let currentOrigin = nativeH1PoolOrigin(target)
        if (origin.size == 0) {
            origin = currentOrigin
        } else if (currentOrigin != origin) {
            throw Exception("native H2 RestClient batch requires one resolved origin")
        }

        let headers = cloneNativeH1Headers(defaultHeaders)
        for ((name, value) in request.headersSnapshot()) {
            removeNativeH1Header(headers, name.trimAscii().toAsciiLower())
            headers.add(name, value)
        }
        if (let Some(store) <- cookieStore) {
            if (!nativeH1HasHeader(headers, "cookie")) {
                let cookie = store.getCookieHeader(resolvedUrl)
                if (cookie.size > 0) {
                    headers.add("cookie", cookie)
                }
            }
        }
        let body = request.bodySnapshot()
        if (body.size > 0 && !nativeH1HasHeader(headers, "content-length")) {
            headers.add("content-length", body.size.toString())
        }
        resolvedUrls.add(resolvedUrl)
        nativeRequests.add(
            NativeH2ClientRequest(
                request.method,
                "http",
                target.hostHeader,
                target.requestTarget,
                body: body,
                headers: nativeH2RequestHeaders(headers),
                priorityHint: request.priorityHintSnapshot()
            )
        )
    }

    let firstTarget = parseNativeH1Target(resolvedUrls[0])
    let connection = match (pool.acquire(origin)) {
        case Some(existing) => existing
        case None => openNativeH2Connection(firstTarget, readTimeout, writeTimeout)
    }
    connection.socket.readTimeout = Some(readTimeout)
    connection.socket.writeTimeout = Some(writeTimeout)

    var settled = false
    try {
        let nativeResponses = try {
            connection.protocol.sendBatch(nativeRequests.toArray())
        } catch (e: NativeH2ClientException) {
            throw nativeH2ProtocolTransportException(e)
        }
        let responses = ArrayList<ClientResponse>()
        for (i in 0..nativeResponses.size) {
            let response = adaptNativeH2BufferedResponse(nativeResponses[i])
            if (let Some(store) <- cookieStore) {
                store.addFromResponse(resolvedUrls[i], response)
            }
            responses.add(response)
        }
        pool.release(origin, connection)
        settled = true
        responses.toArray()
    } finally {
        if (!settled) {
            closeNativeH2Connection(connection)
        }
    }
}

func sendNativeH2Request(
    method: String,
    url: String,
    headers: HashMap<String, String>,
    body: Array<UInt8>,
    readTimeout: Duration,
    writeTimeout: Duration,
    pool: NativeH2ClientConnectionPool
): ClientResponse {
    let target = parseNativeH1Target(url)
    let origin = nativeH1PoolOrigin(target)
    let pooled = pool.acquire(origin)
    let connection = match (pooled) {
        case Some(existing) => existing
        case None => openNativeH2Connection(target, readTimeout, writeTimeout)
    }
    connection.socket.readTimeout = Some(readTimeout)
    connection.socket.writeTimeout = Some(writeTimeout)

    var transferred = false
    try {
        let request = NativeH2ClientRequest(
            method,
            "http",
            target.hostHeader,
            target.requestTarget,
            body: body,
            headers: nativeH2RequestHeaders(headers)
        )
        let streamed = try {
            connection.protocol.sendStreamed(request)
        } catch (e: NativeH2ClientException) {
            throw nativeH2ProtocolTransportException(e)
        }
        let response = adaptNativeH2Response(streamed, connection, origin, pool)
        transferred = true
        response
    } finally {
        if (!transferred) {
            closeNativeH2Connection(connection)
        }
    }
}

func sendNativeH2RequestOverTransport(
    method: String,
    url: String,
    headers: HashMap<String, String>,
    body: Array<UInt8>,
    transport: NativeByteTransport
): ClientResponse {
    let target = parseNativeH1Target(url)
    let protocol = NativeH2ClientConnection(transport)
    var transferred = false
    try {
        let request = NativeH2ClientRequest(
            method,
            target.scheme,
            target.hostHeader,
            target.requestTarget,
            body: body,
            headers: nativeH2RequestHeaders(headers)
        )
        let streamed = try {
            protocol.sendStreamed(request)
        } catch (e: NativeH2ClientException) {
            throw nativeH2ProtocolTransportException(e)
        }
        let response = adaptNativeH2TransportResponse(streamed, protocol, transport)
        transferred = true
        response
    } finally {
        if (!transferred) {
            try { transport.close() } catch (_: Exception) {}
        }
    }
}

func sendNativeH2RequestOverPooledTransport(
    method: String,
    url: String,
    headers: HashMap<String, String>,
    body: Array<UInt8>,
    protocol: NativeH2ClientConnection,
    transport: NativeByteTransport,
    settle: (Bool) -> Unit
): ClientResponse {
    let target = parseNativeH1Target(url)
    let request = NativeH2ClientRequest(
        method,
        target.scheme,
        target.hostHeader,
        target.requestTarget,
        body: body,
        headers: nativeH2RequestHeaders(headers)
    )
    let streamed = try {
        protocol.sendStreamed(request)
    } catch (e: NativeH2ClientException) {
        throw nativeH2ProtocolTransportException(e)
    }
    adaptNativeH2PooledTransportResponse(streamed, transport, settle)
}

func openNativeH2Connection(
    target: NativeH1ClientTarget,
    readTimeout: Duration,
    writeTimeout: Duration
): NativeH2PooledConnection {
    let socket = TcpSocket(target.host, target.port)
    socket.readTimeout = Some(readTimeout)
    socket.writeTimeout = Some(writeTimeout)
    try {
        socket.connect(timeout: Some(readTimeout))
        NativeH2PooledConnection(socket)
    } catch (e: Exception) {
        try { socket.close() } catch (_: Exception) {}
        throw Exception("native H2 network connect failed: " + e.message)
    }
}

func acquireNativeH2SessionTransport(
    origin: String,
    target: NativeH1ClientTarget,
    readTimeout: Duration,
    writeTimeout: Duration,
    pool: NativeH2ClientConnectionPool,
    maxConcurrentStreams: Int64,
    maxPendingRequests: Int64
): NativeH2SessionTransport {
    let connection = match (pool.acquire(origin)) {
        case Some(existing) => existing
        case None => openNativeH2Connection(target, readTimeout, writeTimeout)
    }
    connection.socket.readTimeout = Some(readTimeout)
    connection.socket.writeTimeout = Some(writeTimeout)
    var transferred = false
    try {
        let protocol = connection.protocol.openMultiplexSession(
            maxConcurrentStreams: maxConcurrentStreams,
            maxPendingRequests: maxPendingRequests
        )
        transferred = true
        NativeH2SessionTransport(connection, protocol)
    } finally {
        if (!transferred) {
            closeNativeH2Connection(connection)
        }
    }
}

func nativeH2RequestHeaders(input: HashMap<String, String>): Array<NativeH2Header> {
    let out = ArrayList<NativeH2Header>()
    for ((name, value) in input) {
        if (name.trimAscii().toAsciiLower() != "host") {
            out.add(NativeH2Header(name, value))
        }
    }
    out.toArray()
}

func adaptNativeH2Response(
    response: NativeH2ClientStreamedResponse,
    connection: NativeH2PooledConnection,
    origin: String,
    pool: NativeH2ClientConnectionPool
): ClientResponse {
    let headers = HttpHeaders()
    for (header in response.headers) {
        headers.add(header.name, header.value)
    }
    ClientResponse(
        response.status,
        headers,
        response.bodyStream(),
        closeHook: { =>
            response.close()
            if (connection.reusable()) {
                pool.release(origin, connection)
            } else {
                closeNativeH2Connection(connection)
            }
        }
    )
}

func adaptNativeH2BufferedResponse(response: NativeH2ClientResponse): ClientResponse {
    let headers = HttpHeaders()
    for (header in response.headers) {
        headers.add(header.name, header.value)
    }
    ClientResponse(
        response.status,
        headers,
        NativeH1ClientBytesInputStream(response.body)
    )
}

func adaptNativeH2MultiplexResponse(response: NativeH2MultiplexResponse): ClientResponse {
    let headers = HttpHeaders()
    for (header in response.headers) {
        headers.add(header.name, header.value)
    }
    ClientResponse(
        response.status,
        headers,
        response.bodyStream(),
        closeHook: { => response.close() }
    )
}

func adaptNativeH2TransportResponse(
    response: NativeH2ClientStreamedResponse,
    protocol: NativeH2ClientConnection,
    transport: NativeByteTransport
): ClientResponse {
    let headers = HttpHeaders()
    for (header in response.headers) {
        headers.add(header.name, header.value)
    }
    ClientResponse(
        response.status,
        headers,
        response.bodyStream(),
        closeHook: { =>
            response.close()
            try { protocol.finish() } catch (_: Exception) {}
            try { transport.close() } catch (_: Exception) {}
        }
    )
}

func adaptNativeH2PooledTransportResponse(
    response: NativeH2ClientStreamedResponse,
    transport: NativeByteTransport,
    settle: (Bool) -> Unit
): ClientResponse {
    let headers = HttpHeaders()
    for (header in response.headers) {
        headers.add(header.name, header.value)
    }
    let stream = NativeH2PooledResponseInputStream(response, transport, settle)
    ClientResponse(
        response.status,
        headers,
        stream,
        closeHook: { => stream.close() }
    )
}

class NativeH2PooledResponseInputStream <: InputStream & Resource {
    let response: NativeH2ClientStreamedResponse
    let body: InputStream
    let transport: NativeByteTransport
    let settle: (Bool) -> Unit
    var settled = false

    init(
        response: NativeH2ClientStreamedResponse,
        transport: NativeByteTransport,
        settle: (Bool) -> Unit
    ) {
        this.response = response
        this.body = response.bodyStream()
        this.transport = transport
        this.settle = settle
    }

    public override func read(outBuf: Array<Byte>): Int64 {
        if (settled) {
            return 0
        }
        try {
            let count = body.read(outBuf)
            if (count <= 0) {
                finish(!transport.isClosed())
            }
            count
        } catch (e: Exception) {
            response.close()
            finish(false)
            throw e
        }
    }

    public func close(): Unit {
        if (settled) {
            return
        }
        response.close()
        finish(false)
    }

    public func isClosed(): Bool {
        settled
    }

    func finish(reusable: Bool): Unit {
        if (settled) {
            return
        }
        settled = true
        settle(reusable)
    }
}

func nativeH2ProtocolTransportException(origin: NativeH2ClientException): Exception {
    if (origin.failureKind == "timeout") {
        return Exception("native H2 network read timeout: " + origin.message)
    }
    Exception("native H2 network read failed: " + origin.message)
}

func closeNativeH2Connection(connection: NativeH2PooledConnection): Unit {
    try {
        if (!connection.socket.isClosed()) {
            connection.socket.close()
        }
    } catch (_: Exception) {}
}
