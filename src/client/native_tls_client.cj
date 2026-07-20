package ignite.client

import std.collection.{ArrayList, HashMap}
import std.io.InputStream
import std.net.TcpSocket
import std.sync.Mutex
import std.time.MonoTime
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
    var idleSince: MonoTime = MonoTime.now()
    var retired: Bool = false

    init(transport: NativeTls13ClientTransport, config: NativeTls13ClientConfig) {
        this.transport = transport
        this.config = cloneNativeTlsClientConfig(config)
    }

    func reusable(): Bool {
        !transport.isClosed()
    }

    func markIdle(): Unit {
        idleSince = MonoTime.now()
    }

    func idleExpired(maxIdleMs: Int64): Bool {
        maxIdleMs > 0 && (MonoTime.now() - idleSince).toMilliseconds() >= maxIdleMs
    }
}

class NativeTlsH2PooledConnection {
    let transport: NativeTls13ClientTransport
    let protocol: NativeH2ClientConnection
    let config: NativeTls13ClientConfig
    var idleSince: MonoTime = MonoTime.now()
    var retired: Bool = false

    init(transport: NativeTls13ClientTransport, config: NativeTls13ClientConfig) {
        this.transport = transport
        this.protocol = NativeH2ClientConnection(transport)
        this.config = cloneNativeTlsClientConfig(config)
    }

    func reusable(): Bool {
        !transport.isClosed()
    }

    func markIdle(): Unit {
        idleSince = MonoTime.now()
    }

    func idleExpired(maxIdleMs: Int64): Bool {
        maxIdleMs > 0 && (MonoTime.now() - idleSince).toMilliseconds() >= maxIdleMs
    }
}

class NativeTlsH1ConnectionPool {
    let mtx = Mutex()
    let maxIdlePerOrigin: Int64
    var maxIdleMs: Int64
    var idle = HashMap<String, ArrayList<NativeTlsH1PooledConnection>>()
    var openedConnections: Int64 = 0
    var reusedConnections: Int64 = 0
    var returnedConnections: Int64 = 0
    var retiredConnections: Int64 = 0
    var expiredConnections: Int64 = 0
    var closed: Bool = false

    init(maxIdlePerOrigin: Int64, maxIdleMs!: Int64 = 30000) {
        this.maxIdlePerOrigin = if (maxIdlePerOrigin > 0) { maxIdlePerOrigin } else { 0 }
        this.maxIdleMs = if (maxIdleMs > 0) { maxIdleMs } else { 1 }
    }

    func enabled(): Bool {
        var result = false
        synchronized(mtx) { result = !closed && maxIdlePerOrigin > 0 }
        result
    }

    func acquire(origin: String, config: NativeTls13ClientConfig): ?NativeTlsH1PooledConnection {
        var selected: ?NativeTlsH1PooledConnection = None
        let stale = ArrayList<NativeTlsH1PooledConnection>()
        synchronized(mtx) {
            if (!closed && let Some(connections) <- idle.get(origin)) {
                var index = connections.size - 1
                while (index >= 0) {
                    let connection = connections[index]
                    if (!connection.reusable()) {
                        stale.add(connections.remove(at: index))
                        retiredConnections += 1
                    } else if (connection.idleExpired(maxIdleMs)) {
                        stale.add(connections.remove(at: index))
                        expiredConnections += 1
                        retiredConnections += 1
                    } else if (nativeTlsConfigsMatch(connection.config, config)) {
                        selected = Some(connections.remove(at: index))
                        reusedConnections += 1
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
        if (!connection.reusable()) {
            retire(connection)
            return
        }
        var retained = false
        synchronized(mtx) {
            if (!connection.retired && !closed && maxIdlePerOrigin > 0) {
                let connections = if (let Some(existing) <- idle.get(origin)) {
                    existing
                } else {
                    let created = ArrayList<NativeTlsH1PooledConnection>()
                    idle.add(origin, created)
                    created
                }
                if (connections.size < maxIdlePerOrigin) {
                    connection.markIdle()
                    connections.add(connection)
                    returnedConnections += 1
                    retained = true
                }
            }
        }
        if (!retained) {
            retire(connection)
        }
    }

    func close(): Unit {
        var closing = HashMap<String, ArrayList<NativeTlsH1PooledConnection>>()
        synchronized(mtx) {
            closed = true
            closing = idle
            for ((_origin, connections) in closing) {
                retiredConnections += connections.size
            }
            idle = HashMap<String, ArrayList<NativeTlsH1PooledConnection>>()
        }
        for ((_origin, connections) in closing) {
            for (connection in connections) {
                closeNativeTlsH1Connection(connection)
            }
        }
    }

    func updateMaxIdleMs(value: Int64): Unit {
        var closing = HashMap<String, ArrayList<NativeTlsH1PooledConnection>>()
        synchronized(mtx) {
            maxIdleMs = value
            closing = idle
            for ((_origin, connections) in closing) {
                retiredConnections += connections.size
            }
            idle = HashMap<String, ArrayList<NativeTlsH1PooledConnection>>()
        }
        for ((_origin, connections) in closing) {
            for (connection in connections) {
                closeNativeTlsH1Connection(connection)
            }
        }
    }

    func recordOpened(): Unit {
        synchronized(mtx) { openedConnections += 1 }
    }

    func retire(connection: NativeTlsH1PooledConnection): Unit {
        var shouldClose = false
        synchronized(mtx) {
            if (!connection.retired) {
                connection.retired = true
                retiredConnections += 1
                shouldClose = true
            }
        }
        if (shouldClose) {
            closeNativeTlsH1Connection(connection)
        }
    }

    func snapshot(): NativeTlsPoolProtocolSnapshot {
        var result = NativeTlsPoolProtocolSnapshot()
        synchronized(mtx) {
            var idleCount: Int64 = 0
            for ((_origin, connections) in idle) {
                idleCount += connections.size
            }
            result = NativeTlsPoolProtocolSnapshot(
                idleConnections: idleCount,
                openedConnections: openedConnections,
                reusedConnections: reusedConnections,
                returnedConnections: returnedConnections,
                retiredConnections: retiredConnections,
                expiredConnections: expiredConnections
            )
        }
        result
    }
}

class NativeTlsH2ConnectionPool {
    let mtx = Mutex()
    let maxIdlePerOrigin: Int64
    var maxIdleMs: Int64
    var idle = HashMap<String, ArrayList<NativeTlsH2PooledConnection>>()
    var openedConnections: Int64 = 0
    var reusedConnections: Int64 = 0
    var returnedConnections: Int64 = 0
    var retiredConnections: Int64 = 0
    var expiredConnections: Int64 = 0
    var closed: Bool = false

    init(maxIdlePerOrigin: Int64, maxIdleMs!: Int64 = 30000) {
        this.maxIdlePerOrigin = if (maxIdlePerOrigin > 0) { maxIdlePerOrigin } else { 0 }
        this.maxIdleMs = if (maxIdleMs > 0) { maxIdleMs } else { 1 }
    }

    func enabled(): Bool {
        var result = false
        synchronized(mtx) { result = !closed && maxIdlePerOrigin > 0 }
        result
    }

    func acquire(origin: String, config: NativeTls13ClientConfig): ?NativeTlsH2PooledConnection {
        var selected: ?NativeTlsH2PooledConnection = None
        let stale = ArrayList<NativeTlsH2PooledConnection>()
        synchronized(mtx) {
            if (!closed && let Some(connections) <- idle.get(origin)) {
                var index = connections.size - 1
                while (index >= 0) {
                    let connection = connections[index]
                    if (!connection.reusable()) {
                        stale.add(connections.remove(at: index))
                        retiredConnections += 1
                    } else if (connection.idleExpired(maxIdleMs)) {
                        stale.add(connections.remove(at: index))
                        expiredConnections += 1
                        retiredConnections += 1
                    } else if (nativeTlsConfigsMatch(connection.config, config)) {
                        selected = Some(connections.remove(at: index))
                        reusedConnections += 1
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
        if (!connection.reusable()) {
            retire(connection)
            return
        }
        var retained = false
        synchronized(mtx) {
            if (!connection.retired && !closed && maxIdlePerOrigin > 0) {
                let connections = if (let Some(existing) <- idle.get(origin)) {
                    existing
                } else {
                    let created = ArrayList<NativeTlsH2PooledConnection>()
                    idle.add(origin, created)
                    created
                }
                if (connections.size < maxIdlePerOrigin) {
                    connection.markIdle()
                    connections.add(connection)
                    returnedConnections += 1
                    retained = true
                }
            }
        }
        if (!retained) {
            retire(connection)
        }
    }

    func close(): Unit {
        var closing = HashMap<String, ArrayList<NativeTlsH2PooledConnection>>()
        synchronized(mtx) {
            closed = true
            closing = idle
            for ((_origin, connections) in closing) {
                retiredConnections += connections.size
            }
            idle = HashMap<String, ArrayList<NativeTlsH2PooledConnection>>()
        }
        for ((_origin, connections) in closing) {
            for (connection in connections) {
                closeNativeTlsH2Connection(connection)
            }
        }
    }

    func updateMaxIdleMs(value: Int64): Unit {
        var closing = HashMap<String, ArrayList<NativeTlsH2PooledConnection>>()
        synchronized(mtx) {
            maxIdleMs = value
            closing = idle
            for ((_origin, connections) in closing) {
                retiredConnections += connections.size
            }
            idle = HashMap<String, ArrayList<NativeTlsH2PooledConnection>>()
        }
        for ((_origin, connections) in closing) {
            for (connection in connections) {
                closeNativeTlsH2Connection(connection)
            }
        }
    }

    func recordOpened(): Unit {
        synchronized(mtx) { openedConnections += 1 }
    }

    func retire(connection: NativeTlsH2PooledConnection): Unit {
        var shouldClose = false
        synchronized(mtx) {
            if (!connection.retired) {
                connection.retired = true
                retiredConnections += 1
                shouldClose = true
            }
        }
        if (shouldClose) {
            closeNativeTlsH2Connection(connection)
        }
    }

    func snapshot(): NativeTlsPoolProtocolSnapshot {
        var result = NativeTlsPoolProtocolSnapshot()
        synchronized(mtx) {
            var idleCount: Int64 = 0
            for ((_origin, connections) in idle) {
                idleCount += connections.size
            }
            result = NativeTlsPoolProtocolSnapshot(
                idleConnections: idleCount,
                openedConnections: openedConnections,
                reusedConnections: reusedConnections,
                returnedConnections: returnedConnections,
                retiredConnections: retiredConnections,
                expiredConnections: expiredConnections
            )
        }
        result
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
            case None =>
                let opened = openNativeTlsH2Connection(target, readTimeout, writeTimeout, config)
                pool.recordOpened()
                opened
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
        case None =>
            let opened = openNativeTlsH1Connection(target, readTimeout, writeTimeout, config)
            pool.recordOpened()
            opened
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
                    pool.retire(connection)
                }
            }
        )
        transferred = true
        response
    } finally {
        if (!transferred) {
            pool.retire(connection)
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
                    pool.retire(connection)
                }
            }
        )
        transferred = true
        response
    } finally {
        if (!transferred) {
            pool.retire(connection)
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
