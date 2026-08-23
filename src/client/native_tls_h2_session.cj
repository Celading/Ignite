package ignite.client

import ignite.native_h2.{
    NativeH2ClientException,
    NativeH2ClientRequest,
    NativeH2MultiplexSession
}
import ignite.native_tls.NativeTls13ClientConfig
import std.collection.{ArrayList, HashMap}
import std.sync.Mutex

class NativeTlsH2SessionTransport {
    let connection: NativeTlsH2PooledConnection
    let protocol: NativeH2MultiplexSession

    init(
        connection: NativeTlsH2PooledConnection,
        protocol: NativeH2MultiplexSession
    ) {
        this.connection = connection
        this.protocol = protocol
    }
}

/// Explicit Preview session for independent H2 stream leases over Native TLS.
///
/// Request streams are consumed once and are never replayed automatically.
public class NativeTlsH2Session {
    let origin: String
    let resolveUrl: (String) -> String
    let defaultHeaders: HashMap<String, String>
    let cookieStore: ?CookieStore
    var protocol: NativeH2MultiplexSession
    var connection: NativeTlsH2PooledConnection
    let pool: NativeTlsH2ConnectionPool
    let reopen: () -> NativeTlsH2SessionTransport
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
        connection: NativeTlsH2PooledConnection,
        pool: NativeTlsH2ConnectionPool,
        reopen: () -> NativeTlsH2SessionTransport,
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

    /// Sends one buffered or streamed request over the retained TLS H2 session.
    /// Multiple callers may use this method concurrently.
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
            if (target.scheme != "https") {
                throw Exception("native TLS H2 session requires https://")
            }
            if (nativeH1PoolOrigin(target) != origin) {
                throw Exception("native TLS H2 session request must retain its opened origin")
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
                    throw Exception("native TLS H2 session is closed")
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
                    "https",
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
            throw Exception("native TLS H2 session cannot replay a one-pass request stream")
        }
        let replayEligible = nativeH2SessionRetryEligible(
            request.method, hasBodyStream, retryConfig
        )
        if (retryConfig.enabled && retryConfig.maxAttempts > 1 && !replayEligible) {
            throw Exception("native TLS H2 session retry requires an idempotent request method")
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
            throw Exception("native TLS H2 session retry loop ended unexpectedly")
        } finally {
            if (reconnectReplayEnabled) {
                endReconnectReplay()
            }
        }
    }

    func beginSend(): Unit {
        synchronized(mtx) {
            if (closed) {
                throw Exception("native TLS H2 session is closed")
            }
            if (reconnectReplayActive) {
                throw Exception("native TLS H2 session reconnect replay is active")
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
                throw Exception("native TLS H2 session is closed")
            }
            if (reconnectReplayActive || activeCalls > 0 ||
                protocol.activeStreams() > 0 || protocol.pendingAdmissions() > 0) {
                throw Exception(
                    "native TLS H2 session reconnect replay requires an idle session"
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
        pool.retire(connection)
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
            pool.retire(replacement.connection)
            throw Exception("native TLS H2 session closed during reconnect replay")
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
                    pool.retire(connection)
                }
            } catch (_: Exception) {
                pool.retire(connection)
            }
        } finally {
            closeHook()
        }
    }
}

func resolveNativeTlsH2SessionUrl(originUrl: String, candidate: String): String {
    let normalized = candidate.trimAscii()
    let lower = normalized.toAsciiLower()
    if (nativeH1StartsWith(lower, "http://") ||
        nativeH1StartsWith(lower, "https://")) {
        return normalized
    }
    if (normalized.size == 0) {
        return originUrl + "/"
    }
    if (normalized.toRuneArray()[0] == r'/') {
        return originUrl + normalized
    }
    originUrl + "/" + normalized
}

func acquireNativeTlsH2SessionTransport(
    origin: String,
    target: NativeH1ClientTarget,
    readTimeout: Duration,
    writeTimeout: Duration,
    config: NativeTls13ClientConfig,
    pool: NativeTlsH2ConnectionPool,
    maxConcurrentStreams: Int64,
    maxPendingRequests: Int64
): NativeTlsH2SessionTransport {
    let connection = match (pool.acquire(origin, config)) {
        case Some(existing) => existing
        case None =>
            let opened = openNativeTlsH2Connection(
                target, readTimeout, writeTimeout, config
            )
            pool.recordOpened()
            opened
    }
    var transferred = false
    try {
        let protocol = connection.protocol.openMultiplexSession(
            maxConcurrentStreams: maxConcurrentStreams,
            maxPendingRequests: maxPendingRequests
        )
        transferred = true
        NativeTlsH2SessionTransport(connection, protocol)
    } finally {
        if (!transferred) {
            pool.retire(connection)
        }
    }
}
