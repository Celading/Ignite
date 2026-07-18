package ignite.client

import ignite.native_h2.{
    NativeH2ClientConnection,
    NativeH2ClientException,
    NativeH2ClientRequest,
    NativeH2ClientStreamedResponse,
    NativeH2Header
}
import std.collection.{ArrayList, HashMap}
import std.net.TcpSocket
import std.sync.Mutex
import stdx.net.http.HttpHeaders
import ignite.transport.NativeByteTransport

let NATIVE_H2_CLIENT_BACKEND = "ignite-native-h2-client"

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
