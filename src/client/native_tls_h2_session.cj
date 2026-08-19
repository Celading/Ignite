package ignite.client

import ignite.native_h2.{
    NativeH2ClientException,
    NativeH2ClientRequest,
    NativeH2MultiplexSession
}
import std.collection.{ArrayList, HashMap}
import std.sync.Mutex

/// Explicit Preview session for independent H2 stream leases over Native TLS.
///
/// Request streams are consumed once and are never replayed automatically.
public class NativeTlsH2Session {
    let origin: String
    let resolveUrl: (String) -> String
    let defaultHeaders: HashMap<String, String>
    let cookieStore: ?CookieStore
    let protocol: NativeH2MultiplexSession
    let connection: NativeTlsH2PooledConnection
    let pool: NativeTlsH2ConnectionPool
    let responseHooks: ArrayList<ClientResponseHook>
    let errorHooks: ArrayList<ClientErrorHook>
    let closeHook: () -> Unit
    let mtx = Mutex()
    var closed = false

    init(
        origin: String,
        resolveUrl: (String) -> String,
        defaultHeaders: HashMap<String, String>,
        cookieStore: ?CookieStore,
        protocol: NativeH2MultiplexSession,
        connection: NativeTlsH2PooledConnection,
        pool: NativeTlsH2ConnectionPool,
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
        this.responseHooks = responseHooks
        this.errorHooks = errorHooks
        this.closeHook = closeHook
    }

    /// Sends one buffered or streamed request over the retained TLS H2 session.
    /// Multiple callers may use this method concurrently.
    public func send(request: NativeH2BatchRequest): ClientResponse {
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
    /// One-pass streams and broken sessions are intentionally not replayed.
    /// Response hooks observe every completed attempt, including drained retries.
    public func sendWithRetry(
        request: NativeH2BatchRequest,
        config!: ClientRetryConfig = ClientRetryConfig()
    ): ClientResponse {
        let retryConfig = config.copy()
        let hasBodyStream = request.bodyStreamSnapshot().isSome()
        if (retryConfig.enabled && retryConfig.maxAttempts > 1 && hasBodyStream) {
            throw Exception("native TLS H2 session cannot replay a one-pass request stream")
        }
        if (retryConfig.enabled && retryConfig.maxAttempts > 1 &&
            !nativeH2SessionRetryEligible(request.method, hasBodyStream, retryConfig)) {
            throw Exception("native TLS H2 session retry requires an idempotent request method")
        }
        var attempt: Int64 = 1
        while (true) {
            let response = send(request)
            if (!nativeH2SessionRetryStatus(response.status, retryConfig, attempt)) {
                return response
            }
            response.discard()
            nativeH2SessionRetryBackoff(retryConfig, attempt)
            attempt += 1
        }
        throw Exception("native TLS H2 session retry loop ended unexpectedly")
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
