package ignite.client

import stdx.net.http.{Client, ClientBuilder}
import std.collection.{ArrayList, HashMap}
import std.sync.Mutex
import std.unicode.*
import ignite.api2
import ignite.security as security
import ignite.native_tls.NativeTls13ClientConfig

// ── RestClient ──

public class RestClient {
    let _client: Client
    var _baseUrl: String = ""
    var _defaultHeaders: HashMap<String, String> = HashMap<String, String>()
    var _cookieStore: ?CookieStore = None
    var _cryptoConfig: ?api2.ClientCryptoConfig = None
    var _x509Verify: ?security.X509VerifyOption = None
    var _retryConfig: ClientRetryConfig = ClientRetryConfig()
    var _preferredTransportBackendHint: String = ""
    var _allowExperimentalTransport: Bool = false
    var _nativeTlsConfig: ?NativeTls13ClientConfig = None
    var _requestHooks: ArrayList<ClientRequestHook> = ArrayList<ClientRequestHook>()
    var _responseHooks: ArrayList<ClientResponseHook> = ArrayList<ClientResponseHook>()
    var _errorHooks: ArrayList<ClientErrorHook> = ArrayList<ClientErrorHook>()
    var _observeHooks: ArrayList<ClientObserveHook> = ArrayList<ClientObserveHook>()
    var _transportTouchpointHooks: ArrayList<ClientTransportTouchpointHook> = ArrayList<ClientTransportTouchpointHook>()
    var _lastClientTransportTouchpoint: ?ClientTransportTouchpoint = None
    var _lastClientObserveSnapshot: ?ClientObserveSnapshot = None
    var _readTimeout: Duration = Duration.second * 15
    var _writeTimeout: Duration = Duration.second * 15
    var _nativeTlsPoolMaxIdleMs: Int64 = 30000
    var _nativeH1Pool = NativeH1ClientConnectionPool(10)
    var _nativeH2Pool = NativeH2ClientConnectionPool(10)
    var _nativeTlsH1Pool = NativeTlsH1ConnectionPool(10)
    var _nativeTlsH2Pool = NativeTlsH2ConnectionPool(10)
    let _nativeH2SessionMutex = Mutex()
    var _nativeH2Sessions = HashMap<Int64, NativeH2Session>()
    var _nativeH2NextSessionId: Int64 = 1

    public init() {
        _client = ClientBuilder().build()
    }

    public init(
        readTimeout!: Duration = Duration.second * 15,
        writeTimeout!: Duration = Duration.second * 15,
        poolSize!: Int64 = 10
    ) {
        _readTimeout = readTimeout
        _writeTimeout = writeTimeout
        _nativeH1Pool = NativeH1ClientConnectionPool(poolSize)
        _nativeH2Pool = NativeH2ClientConnectionPool(poolSize)
        _nativeTlsH1Pool = NativeTlsH1ConnectionPool(
            poolSize, maxIdleMs: _nativeTlsPoolMaxIdleMs
        )
        _nativeTlsH2Pool = NativeTlsH2ConnectionPool(
            poolSize, maxIdleMs: _nativeTlsPoolMaxIdleMs
        )
        _client = ClientBuilder()
            .readTimeout(readTimeout)
            .writeTimeout(writeTimeout)
            .poolSize(poolSize)
            .build()
    }

    public func baseUrl(url: String): RestClient {
        _baseUrl = url
        this
    }

    public func withBaseUrl(url: String): RestClient {
        baseUrl(url)
    }

    public func defaultHeader(name: String, value: String): RestClient {
        _defaultHeaders.add(name, value)
        this
    }

    public func withHeader(name: String, value: String): RestClient {
        defaultHeader(name, value)
    }

    public func useCookies(): RestClient {
        _cookieStore = CookieStore()
        this
    }

    public func enableCookieJar(): RestClient {
        useCookies()
    }

    public func useCookies(store: CookieStore): RestClient {
        _cookieStore = store
        this
    }

    public func withCookieJar(store: CookieStore): RestClient {
        useCookies(store)
    }

    public func useCrypto(config: api2.ClientCryptoConfig): RestClient {
        _cryptoConfig = config
        this
    }

    public func useX509Verify(option: security.X509VerifyOption): RestClient {
        _x509Verify = Some(option.copy())
        this
    }

    public func disableX509Verify(): RestClient {
        _x509Verify = Some(security.X509VerifyOption(enabled: false))
        this
    }

    public func withCrypto(config: api2.ClientCryptoConfig): RestClient {
        useCrypto(config)
    }

    public func useRetry(config: ClientRetryConfig): RestClient {
        _retryConfig = config.copy()
        this
    }

    public func withRetryPolicy(config: ClientRetryConfig): RestClient {
        useRetry(config)
    }

    public func disableRetry(): RestClient {
        _retryConfig = ClientRetryConfig(enabled: false)
        this
    }

    public func preferTransportBackend(backendId: String): RestClient {
        _preferredTransportBackendHint = backendId.trimAscii()
        this
    }

    public func withTransportBackendHint(backendId: String): RestClient {
        preferTransportBackend(backendId)
    }

    public func allowExperimentalTransport(enable!: Bool = true): RestClient {
        _allowExperimentalTransport = enable
        this
    }

    /// Enables the explicit Contract-backed TLS1.3 native client.
    public func useNativeTls(config: NativeTls13ClientConfig): RestClient {
        _nativeTlsConfig = Some(config)
        this
    }

    public func withNativeTls(config: NativeTls13ClientConfig): RestClient {
        useNativeTls(config)
    }

    /// Sets the maximum idle age for explicit Native TLS H1/H2 pooled sessions.
    /// Existing idle sessions are closed before the new policy takes effect.
    public func nativeTlsIdleTimeout(timeout: Duration): RestClient {
        let maxIdleMs = timeout.toMilliseconds()
        if (maxIdleMs <= 0) {
            throw Exception("native TLS idle timeout must be positive")
        }
        _nativeTlsPoolMaxIdleMs = maxIdleMs
        _nativeTlsH1Pool.updateMaxIdleMs(maxIdleMs)
        _nativeTlsH2Pool.updateMaxIdleMs(maxIdleMs)
        this
    }

    /// Returns bounded lifecycle counters for the explicit Native TLS pools.
    public func nativeTlsRuntimeSnapshot(): NativeTlsClientRuntimeSnapshot {
        NativeTlsClientRuntimeSnapshot(
            _nativeTlsPoolMaxIdleMs,
            _nativeTlsH1Pool.snapshot(),
            _nativeTlsH2Pool.snapshot()
        )
    }

    public func onRequest(hook: ClientRequestHook): RestClient {
        _requestHooks.add(hook)
        this
    }

    public func onRequestHook(hook: ClientRequestHook): RestClient {
        onRequest(hook)
    }

    public func onResponse(hook: ClientResponseHook): RestClient {
        _responseHooks.add(hook)
        this
    }

    public func onResponseHook(hook: ClientResponseHook): RestClient {
        onResponse(hook)
    }

    public func onError(hook: ClientErrorHook): RestClient {
        _errorHooks.add(hook)
        this
    }

    public func onErrorHook(hook: ClientErrorHook): RestClient {
        onError(hook)
    }

    public func onObserve(hook: ClientObserveHook): RestClient {
        _observeHooks.add(hook)
        this
    }

    public func onObserveHook(hook: ClientObserveHook): RestClient {
        onObserve(hook)
    }

    public func onTransportTouchpoint(hook: ClientTransportTouchpointHook): RestClient {
        _transportTouchpointHooks.add(hook)
        this
    }

    public func onTransportTouchpointHook(hook: ClientTransportTouchpointHook): RestClient {
        onTransportTouchpoint(hook)
    }

    /// Returns the most recent `ClientTransportTouchpoint` captured by the
    /// last `send()` call on this `RestClient` instance.
    ///
    /// **Latest-send shared slot** — every `send()` call (success or failure)
    /// overwrites this value. Calling `clearRecoverySnapshots()` resets it
    /// to `None`.
    ///
    /// [!] **Not thread-safe.** If multiple requests are in-flight concurrently
    /// on the same `RestClient`, the value may be overwritten by a different
    /// send before you read it. This accessor is intended for sequential
    /// recovery flows, not concurrent history tracking.
    public func lastClientTransportTouchpoint(): ?ClientTransportTouchpoint {
        _lastClientTransportTouchpoint
    }

    /// Returns the most recent `ClientObserveSnapshot` captured by the
    /// last `send()` call on this `RestClient` instance.
    ///
    /// **Latest-send shared slot** — every `send()` call (success or failure)
    /// overwrites this value. Calling `clearRecoverySnapshots()` resets it
    /// to `None`.
    ///
    /// [!] **Not thread-safe.** If multiple requests are in-flight concurrently
    /// on the same `RestClient`, the value may be overwritten by a different
    /// send before you read it. This accessor is intended for sequential
    /// recovery flows, not concurrent history tracking.
    public func lastClientObserveSnapshot(): ?ClientObserveSnapshot {
        _lastClientObserveSnapshot
    }

    /// Resets both retained snapshot slots (`lastClientTransportTouchpoint`
    /// and `lastClientObserveSnapshot`) to `None`.
    ///
    /// Returns `this` for chaining. After calling `clearRecoverySnapshots()`,
    /// the next `send()` call will re-populate both slots with fresh values.
    public func clearRecoverySnapshots(): RestClient {
        _lastClientTransportTouchpoint = None
        _lastClientObserveSnapshot = None
        this
    }

    func requireCryptoConfig(): api2.ClientCryptoConfig {
        match (_cryptoConfig) {
            case Some(cfg) => cfg
            case None =>
                throw api2.ClientCryptoException(
                    api2.ClientCryptoErrorCode.CryptoUnavailable,
                    "crypto config is required; call useCrypto(...) first"
                )
        }
    }

    func resolveUrl(url: String): String {
        if (_baseUrl.size == 0) { return url }
        if (strStartsWith(url, "http://") || strStartsWith(url, "https://")) {
            return url
        }
        let base = _baseUrl
        if (base.toRuneArray()[base.size - 1] == r'/') {
            if (url.size > 0 && url.toRuneArray()[0] == r'/') {
                return base + substringFrom(url, 1)
            }
            return base + url
        }
        if (url.size > 0 && url.toRuneArray()[0] == r'/') {
            return base + url
        }
        base + "/" + url
    }

    func hostFromUrl(url: String): String {
        var start = 0
        if (strStartsWith(url, "https://")) { start = 8 }
        else if (strStartsWith(url, "http://")) { start = 6 }
        let rest = substringFrom(url, start)
        let slash = findChar(rest, r'/')
        if (slash < 0) { rest } else { rest.split("/", 2)[0] }
    }

    func findChar(s: String, ch: Rune): Int64 {
        let runes = s.toRuneArray()
        for (i in 0..runes.size) {
            if (runes[i] == ch) { return i }
        }
        -1
    }

    func strStartsWith(s: String, prefix: String): Bool {
        if (s.size < prefix.size) { return false }
        let sArr = s.toRuneArray()
        let pArr = prefix.toRuneArray()
        for (i in 0..pArr.size) {
            if (sArr[i] != pArr[i]) { return false }
        }
        true
    }

    func substringFrom(s: String, start: Int64): String {
        let runes = s.toRuneArray()
        var result = ""
        for (i in start..runes.size) {
            result += runes[i].toString()
        }
        result
    }

    public func get(url: String): ClientResponse {
        request().method("GET").url(url).send()
    }

    public func post(url: String, body: String): ClientResponse {
        request().method("POST").url(url).body(body).send()
    }

    public func postJson(url: String, json: String): ClientResponse {
        request()
            .method("POST")
            .url(url)
            .header("content-type", "application/json")
            .body(json)
            .send()
    }

    public func postEncryptedJson(url: String, json: String, aad!: String = ""): ClientResponse {
        let cfg = requireCryptoConfig()
        request()
            .method("POST")
            .url(url)
            .encryptedBodyJson(json, aad: aad, config: cfg)
            .send()
    }

    public func postJsonEncrypted(url: String, json: String, aad!: String = ""): ClientResponse {
        postEncryptedJson(url, json, aad: aad)
    }

    public func postForm(url: String, params: ArrayList<(String, String)>): ClientResponse {
        request()
            .method("POST")
            .url(url)
            .form(params)
            .send()
    }

    public func postMultipart(
        url: String,
        fields: ArrayList<(String, String)>,
        files: ArrayList<MultipartFile>
    ): ClientResponse {
        request()
            .method("POST")
            .url(url)
            .multipart(fields, files)
            .send()
    }

    public func put(url: String, body: String): ClientResponse {
        request().method("PUT").url(url).body(body).send()
    }

    public func delete(url: String): ClientResponse {
        request().method("DELETE").url(url).send()
    }

    public func head(url: String): ClientResponse {
        request().method("HEAD").url(url).send()
    }

    public func options(url: String): ClientResponse {
        request().method("OPTIONS").url(url).send()
    }

    public func patch(url: String, body: String): ClientResponse {
        request().method("PATCH").url(url).body(body).send()
    }

    /// Sends one bounded same-origin request batch over a single cleartext H2 connection.
    ///
    /// This Preview API buffers each response and preserves request order. It does not
    /// promise arbitrary concurrent streamed leases, retry/redirect replay, or TLS batch
    /// transport. Request/observe/touchpoint hooks are rejected rather than silently skipped.
    public func sendNativeH2Batch(
        requests: Array<NativeH2BatchRequest>
    ): Array<ClientResponse> {
        try {
            if (!_allowExperimentalTransport) {
                throw Exception(
                    "native H2 RestClient batch requires allowExperimentalTransport()"
                )
            }
            if (_preferredTransportBackendHint.trimAscii() != NATIVE_H2_CLIENT_BACKEND) {
                throw Exception(
                    "native H2 RestClient batch requires preferTransportBackend(\"${NATIVE_H2_CLIENT_BACKEND}\")"
                )
            }
            if (_requestHooks.size > 0 || _observeHooks.size > 0 ||
                _transportTouchpointHooks.size > 0) {
                throw Exception(
                    "native H2 RestClient batch does not yet support request, observe, or transport touchpoint hooks"
                )
            }
            let responses = executeNativeH2Batch(
                requests,
                { value => resolveUrl(value) },
                _defaultHeaders,
                _cookieStore,
                _readTimeout,
                _writeTimeout,
                _nativeH2Pool
            )
            for (response in responses) {
                for (hook in _responseHooks) {
                    hook(response)
                }
            }
            responses
        } catch (e: Exception) {
            for (hook in _errorHooks) {
                hook(e)
            }
            throw e
        }
    }

    /// Opens one explicit cleartext H2 connection for independent response leases.
    ///
    /// The Preview session supports concurrent bodyless requests on one origin.
    /// Request bodies, TLS, retry/redirect replay, and request/observe/touchpoint
    /// hooks remain outside this first session contract.
    public func openNativeH2Session(
        originUrl: String,
        maxConcurrentStreams!: Int64 = NATIVE_H2_REST_BATCH_LIMIT
    ): NativeH2Session {
        try {
            if (!_allowExperimentalTransport) {
                throw Exception(
                    "native H2 session requires allowExperimentalTransport()"
                )
            }
            if (_preferredTransportBackendHint.trimAscii() != NATIVE_H2_CLIENT_BACKEND) {
                throw Exception(
                    "native H2 session requires preferTransportBackend(\"${NATIVE_H2_CLIENT_BACKEND}\")"
                )
            }
            if (_requestHooks.size > 0 || _observeHooks.size > 0 ||
                _transportTouchpointHooks.size > 0) {
                throw Exception(
                    "native H2 session does not yet support request, observe, or transport touchpoint hooks"
                )
            }
            if (maxConcurrentStreams <= 0 ||
                maxConcurrentStreams > NATIVE_H2_REST_BATCH_LIMIT) {
                throw Exception(
                    "native H2 session maxConcurrentStreams must be within 1..${NATIVE_H2_REST_BATCH_LIMIT}"
                )
            }

            let resolvedOrigin = resolveUrl(originUrl)
            let target = parseNativeH1Target(resolvedOrigin)
            if (target.scheme != "http") {
                throw Exception(
                    "native H2 session currently requires cleartext http:// prior knowledge"
                )
            }
            let origin = nativeH1PoolOrigin(target)
            let connection = match (_nativeH2Pool.acquire(origin)) {
                case Some(existing) => existing
                case None => openNativeH2Connection(target, _readTimeout, _writeTimeout)
            }
            connection.socket.readTimeout = Some(_readTimeout)
            connection.socket.writeTimeout = Some(_writeTimeout)

            var transferred = false
            try {
                let protocol = connection.protocol.openMultiplexSession(
                    maxConcurrentStreams: maxConcurrentStreams
                )
                let defaults = cloneNativeH1Headers(_defaultHeaders)
                let responseHooks = ArrayList<ClientResponseHook>()
                for (hook in _responseHooks) {
                    responseHooks.add(hook)
                }
                let errorHooks = ArrayList<ClientErrorHook>()
                for (hook in _errorHooks) {
                    errorHooks.add(hook)
                }
                var sessionId: Int64 = 0
                synchronized(_nativeH2SessionMutex) {
                    sessionId = _nativeH2NextSessionId
                    _nativeH2NextSessionId += 1
                }
                let capturedSessionId = sessionId
                let session = NativeH2Session(
                    origin,
                    { value => resolveUrl(value) },
                    defaults,
                    _cookieStore,
                    protocol,
                    connection,
                    _nativeH2Pool,
                    responseHooks,
                    errorHooks,
                    { => removeNativeH2Session(capturedSessionId) }
                )
                synchronized(_nativeH2SessionMutex) {
                    _nativeH2Sessions.add(sessionId, session)
                }
                transferred = true
                session
            } finally {
                if (!transferred) {
                    closeNativeH2Connection(connection)
                }
            }
        } catch (e: Exception) {
            for (hook in _errorHooks) {
                hook(e)
            }
            throw e
        }
    }

    public func request(): RequestBuilder {
        let builder = RequestBuilder(
            _client,
            _baseUrl,
            _defaultHeaders,
            _cookieStore,
            _cryptoConfig,
            _x509Verify,
            _retryConfig,
            _preferredTransportBackendHint,
            _allowExperimentalTransport,
            _requestHooks,
            _responseHooks,
            _errorHooks,
            _observeHooks,
            _transportTouchpointHooks,
            captureObserveHook: { snapshot =>
                _lastClientObserveSnapshot = Some(snapshot)
            },
            captureTransportTouchpointHook: { touchpoint =>
                _lastClientTransportTouchpoint = Some(touchpoint)
            },
            readTimeout: _readTimeout,
            writeTimeout: _writeTimeout,
            nativeH1Pool: Some(_nativeH1Pool),
            nativeTlsConfig: _nativeTlsConfig
        )
        builder
            .attachNativeH2Pool(_nativeH2Pool)
            .attachNativeTlsPools(_nativeTlsH1Pool, _nativeTlsH2Pool)
    }

    public func close(): Unit {
        let sessions = ArrayList<NativeH2Session>()
        synchronized(_nativeH2SessionMutex) {
            for ((_sessionId, session) in _nativeH2Sessions) {
                sessions.add(session)
            }
            _nativeH2Sessions = HashMap<Int64, NativeH2Session>()
        }
        for (session in sessions) {
            session.close()
        }
        _nativeH1Pool.close()
        _nativeH2Pool.close()
        _nativeTlsH1Pool.close()
        _nativeTlsH2Pool.close()
        _client.close()
    }

    func removeNativeH2Session(sessionId: Int64): Unit {
        synchronized(_nativeH2SessionMutex) {
            let _ = _nativeH2Sessions.remove(sessionId)
        }
    }

    // keep local URL helpers for future client-only extensions
}
