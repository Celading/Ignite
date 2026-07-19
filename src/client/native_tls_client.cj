package ignite.client

import std.collection.{ArrayList, HashMap}
import std.io.InputStream
import std.net.TcpSocket
import std.sync.Mutex
import ignite.native_tls.{
    NativeTls13ClientConfig,
    NativeTlsApplicationProtocol,
    NativeTls13ClientHandshake,
    NativeTls13ClientTransport,
    openNativeTls13ClientTransport,
    selectNativeTlsApplicationProtocol
}
import ignite.transport.TcpSocketByteTransport
import ignite.native_h2.NativeH2ClientConnection

class NativeTlsH1PooledConnection {
    let transport: NativeTls13ClientTransport
    let config: NativeTls13ClientConfig

    init(transport: NativeTls13ClientTransport, config: NativeTls13ClientConfig) {
        this.transport = transport
        this.config = cloneNativeTlsClientConfig(config)
    }

    func reusable(): Bool {
        !transport.isClosed()
    }
}

class NativeTlsH2PooledConnection {
    let transport: NativeTls13ClientTransport
    let protocol: NativeH2ClientConnection
    let config: NativeTls13ClientConfig

    init(transport: NativeTls13ClientTransport, config: NativeTls13ClientConfig) {
        this.transport = transport
        this.protocol = NativeH2ClientConnection(transport)
        this.config = cloneNativeTlsClientConfig(config)
    }

    func reusable(): Bool {
        !transport.isClosed()
    }
}

class NativeTlsH1ConnectionPool {
    let mtx = Mutex()
    let maxIdlePerOrigin: Int64
    var idle = HashMap<String, ArrayList<NativeTlsH1PooledConnection>>()

    init(maxIdlePerOrigin: Int64) {
        this.maxIdlePerOrigin = if (maxIdlePerOrigin > 0) { maxIdlePerOrigin } else { 0 }
    }

    func enabled(): Bool {
        maxIdlePerOrigin > 0
    }

    func acquire(origin: String, config: NativeTls13ClientConfig): ?NativeTlsH1PooledConnection {
        var selected: ?NativeTlsH1PooledConnection = None
        let stale = ArrayList<NativeTlsH1PooledConnection>()
        synchronized(mtx) {
            if (let Some(connections) <- idle.get(origin)) {
                var index = connections.size - 1
                while (index >= 0) {
                    let connection = connections[index]
                    if (!connection.reusable()) {
                        stale.add(connections.remove(at: index))
                    } else if (nativeTlsConfigsMatch(connection.config, config)) {
                        selected = Some(connections.remove(at: index))
                        break
                    }
                    index -= 1
                }
                if (connections.size == 0) {
                    let _ = idle.remove(origin)
                }
            }
        }
        for (connection in stale) {
            closeNativeTlsH1Connection(connection)
        }
        selected
    }

    func release(origin: String, connection: NativeTlsH1PooledConnection): Unit {
        if (!enabled() || !connection.reusable()) {
            closeNativeTlsH1Connection(connection)
            return
        }
        var retained = false
        synchronized(mtx) {
            let connections = if (let Some(existing) <- idle.get(origin)) {
                existing
            } else {
                let created = ArrayList<NativeTlsH1PooledConnection>()
                idle.add(origin, created)
                created
            }
            if (connections.size < maxIdlePerOrigin) {
                connections.add(connection)
                retained = true
            }
        }
        if (!retained) {
            closeNativeTlsH1Connection(connection)
        }
    }

    func close(): Unit {
        var closing = HashMap<String, ArrayList<NativeTlsH1PooledConnection>>()
        synchronized(mtx) {
            closing = idle
            idle = HashMap<String, ArrayList<NativeTlsH1PooledConnection>>()
        }
        for ((_origin, connections) in closing) {
            for (connection in connections) {
                closeNativeTlsH1Connection(connection)
            }
        }
    }
}

class NativeTlsH2ConnectionPool {
    let mtx = Mutex()
    let maxIdlePerOrigin: Int64
    var idle = HashMap<String, ArrayList<NativeTlsH2PooledConnection>>()

    init(maxIdlePerOrigin: Int64) {
        this.maxIdlePerOrigin = if (maxIdlePerOrigin > 0) { maxIdlePerOrigin } else { 0 }
    }

    func enabled(): Bool {
        maxIdlePerOrigin > 0
    }

    func acquire(origin: String, config: NativeTls13ClientConfig): ?NativeTlsH2PooledConnection {
        var selected: ?NativeTlsH2PooledConnection = None
        let stale = ArrayList<NativeTlsH2PooledConnection>()
        synchronized(mtx) {
            if (let Some(connections) <- idle.get(origin)) {
                var index = connections.size - 1
                while (index >= 0) {
                    let connection = connections[index]
                    if (!connection.reusable()) {
                        stale.add(connections.remove(at: index))
                    } else if (nativeTlsConfigsMatch(connection.config, config)) {
                        selected = Some(connections.remove(at: index))
                        break
                    }
                    index -= 1
                }
                if (connections.size == 0) {
                    let _ = idle.remove(origin)
                }
            }
        }
        for (connection in stale) {
            closeNativeTlsH2Connection(connection)
        }
        selected
    }

    func release(origin: String, connection: NativeTlsH2PooledConnection): Unit {
        if (!enabled() || !connection.reusable()) {
            closeNativeTlsH2Connection(connection)
            return
        }
        var retained = false
        synchronized(mtx) {
            let connections = if (let Some(existing) <- idle.get(origin)) {
                existing
            } else {
                let created = ArrayList<NativeTlsH2PooledConnection>()
                idle.add(origin, created)
                created
            }
            if (connections.size < maxIdlePerOrigin) {
                connections.add(connection)
                retained = true
            }
        }
        if (!retained) {
            closeNativeTlsH2Connection(connection)
        }
    }

    func close(): Unit {
        var closing = HashMap<String, ArrayList<NativeTlsH2PooledConnection>>()
        synchronized(mtx) {
            closing = idle
            idle = HashMap<String, ArrayList<NativeTlsH2PooledConnection>>()
        }
        for ((_origin, connections) in closing) {
            for (connection in connections) {
                closeNativeTlsH2Connection(connection)
            }
        }
    }
}

func sendNativeTlsRequest(
    method: String,
    url: String,
    headers: HashMap<String, String>,
    body: Array<UInt8>,
    bodyStream: ?InputStream,
    bodyStreamLength: Int64,
    readTimeout: Duration,
    writeTimeout: Duration,
    config: NativeTls13ClientConfig,
    expectedAlpn!: String = "http/1.1",
    h1Pool!: ?NativeTlsH1ConnectionPool = None,
    h2Pool!: ?NativeTlsH2ConnectionPool = None
): ClientResponse {
    let target = parseNativeH1Target(url)
    if (target.scheme != "https") {
        throw Exception("native TLS client requires https://")
    }
    if (config.requireTargetHostnameMatch &&
        target.host.toAsciiLower() != config.hostname.trimAscii().toAsciiLower()) {
        throw Exception("native TLS config hostname must match request host")
    }
    let origin = nativeH1PoolOrigin(target)
    if (expectedAlpn == "h2") {
        let pool = match (h2Pool) {
            case Some(value) => value
            case None => NativeTlsH2ConnectionPool(0)
        }
        let connection = match (pool.acquire(origin, config)) {
            case Some(existing) => existing
            case None => openNativeTlsH2Connection(target, readTimeout, writeTimeout, config)
        }
        return sendNativeTlsH2Request(method, url, headers, body, connection, origin, pool)
    }
    let pool = match (h1Pool) {
        case Some(value) => value
        case None => NativeTlsH1ConnectionPool(0)
    }
    let requestReusable = pool.enabled() &&
        !nativeH1HeaderValueContains(headers, "connection", "close")
    var pooled: ?NativeTlsH1PooledConnection = None
    if (requestReusable) {
        pooled = pool.acquire(origin, config)
    }
    let connection = match (pooled) {
        case Some(existing) => existing
        case None => openNativeTlsH1Connection(target, readTimeout, writeTimeout, config)
    }
    var transferred = false
    try {
        let response = sendNativeH1RequestOverTransport(
            method,
            url,
            headers,
            body,
            bodyStream,
            bodyStreamLength,
            connection.transport,
            reusable: requestReusable,
            settleHook: { safe =>
                if (safe) {
                    pool.release(origin, connection)
                } else {
                    closeNativeTlsH1Connection(connection)
                }
            }
        )
        transferred = true
        response
    } finally {
        if (!transferred) {
            closeNativeTlsH1Connection(connection)
        }
    }
}

func openNativeTlsH1Connection(
    target: NativeH1ClientTarget,
    readTimeout: Duration,
    writeTimeout: Duration,
    config: NativeTls13ClientConfig
): NativeTlsH1PooledConnection {
    let handshake = openNativeTlsHandshake(target, readTimeout, writeTimeout, config)
    let selected = selectNativeTlsApplicationProtocol(handshake.negotiatedAlpn)
    if (selected != NativeTlsApplicationProtocol.Http11) {
        handshake.transport.close()
        throw Exception("native HTTPS H1 backend requires negotiated http/1.1 ALPN")
    }
    NativeTlsH1PooledConnection(handshake.transport, config)
}

func openNativeTlsH2Connection(
    target: NativeH1ClientTarget,
    readTimeout: Duration,
    writeTimeout: Duration,
    config: NativeTls13ClientConfig
): NativeTlsH2PooledConnection {
    let handshake = openNativeTlsHandshake(target, readTimeout, writeTimeout, config)
    let selected = selectNativeTlsApplicationProtocol(handshake.negotiatedAlpn)
    if (selected != NativeTlsApplicationProtocol.H2) {
        handshake.transport.close()
        throw Exception("native HTTPS H2 backend requires negotiated h2 ALPN")
    }
    NativeTlsH2PooledConnection(handshake.transport, config)
}

func openNativeTlsHandshake(
    target: NativeH1ClientTarget,
    readTimeout: Duration,
    writeTimeout: Duration,
    config: NativeTls13ClientConfig
): NativeTls13ClientHandshake {
    let socket = TcpSocket(target.host, target.port)
    socket.readTimeout = Some(readTimeout)
    socket.writeTimeout = Some(writeTimeout)
    try {
        socket.connect(timeout: Some(readTimeout))
        openNativeTls13ClientTransport(TcpSocketByteTransport(socket), config)
    } catch (e: Exception) {
        closeNativeH1Socket(socket)
        throw e
    }
}

func sendNativeTlsH2Request(
    method: String,
    url: String,
    headers: HashMap<String, String>,
    body: Array<UInt8>,
    connection: NativeTlsH2PooledConnection,
    origin: String,
    pool: NativeTlsH2ConnectionPool
): ClientResponse {
    var transferred = false
    try {
        let response = sendNativeH2RequestOverPooledTransport(
            method,
            url,
            headers,
            body,
            connection.protocol,
            connection.transport,
            { safe =>
                if (safe) {
                    pool.release(origin, connection)
                } else {
                    closeNativeTlsH2Connection(connection)
                }
            }
        )
        transferred = true
        response
    } finally {
        if (!transferred) {
            closeNativeTlsH2Connection(connection)
        }
    }
}

func nativeTlsConfigsMatch(left: NativeTls13ClientConfig, right: NativeTls13ClientConfig): Bool {
    left.trustAnchorsPemBundle == right.trustAnchorsPemBundle &&
    left.intermediatesPemBundle == right.intermediatesPemBundle &&
    left.hostname == right.hostname &&
    left.validationTime == right.validationTime &&
    left.requireTargetHostnameMatch == right.requireTargetHostnameMatch &&
    nativeTlsStringsMatch(left.alpnProtocols, right.alpnProtocols) &&
    nativeTlsPinsMatch(left.allowedLeafDerSha256, right.allowedLeafDerSha256) &&
    nativeTlsPinsMatch(left.allowedLeafSpkiSha256, right.allowedLeafSpkiSha256)
}

func cloneNativeTlsClientConfig(config: NativeTls13ClientConfig): NativeTls13ClientConfig {
    NativeTls13ClientConfig(
        config.trustAnchorsPemBundle,
        config.hostname,
        intermediatesPemBundle: config.intermediatesPemBundle,
        validationTime: config.validationTime,
        alpnProtocols: config.alpnProtocols,
        requireTargetHostnameMatch: config.requireTargetHostnameMatch,
        allowedLeafDerSha256: config.allowedLeafDerSha256,
        allowedLeafSpkiSha256: config.allowedLeafSpkiSha256
    )
}

func nativeTlsStringsMatch(left: Array<String>, right: Array<String>): Bool {
    if (left.size != right.size) { return false }
    for (i in 0..left.size) {
        if (left[i] != right[i]) { return false }
    }
    true
}

func nativeTlsPinsMatch(left: Array<Array<Byte>>, right: Array<Array<Byte>>): Bool {
    if (left.size != right.size) { return false }
    for (i in 0..left.size) {
        if (left[i].size != right[i].size) { return false }
        for (j in 0..left[i].size) {
            if (left[i][j] != right[i][j]) { return false }
        }
    }
    true
}

func closeNativeTlsH1Connection(connection: NativeTlsH1PooledConnection): Unit {
    try { connection.transport.close() } catch (_: Exception) {}
}

func closeNativeTlsH2Connection(connection: NativeTlsH2PooledConnection): Unit {
    try { connection.protocol.finish() } catch (_: Exception) {}
    try { connection.transport.close() } catch (_: Exception) {}
}
