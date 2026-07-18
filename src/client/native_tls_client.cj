package ignite.client

import std.collection.HashMap
import std.io.InputStream
import std.net.TcpSocket
import ignite.native_tls.{
    NativeTls13ClientConfig,
    NativeTlsApplicationProtocol,
    openNativeTls13ClientTransport,
    selectNativeTlsApplicationProtocol
}
import ignite.transport.TcpSocketByteTransport

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
    expectedAlpn!: String = "http/1.1"
): ClientResponse {
    let target = parseNativeH1Target(url)
    if (target.scheme != "https") {
        throw Exception("native TLS client requires https://")
    }
    if (config.requireTargetHostnameMatch &&
        target.host.toAsciiLower() != config.hostname.trimAscii().toAsciiLower()) {
        throw Exception("native TLS config hostname must match request host")
    }
    let socket = TcpSocket(target.host, target.port)
    socket.readTimeout = Some(readTimeout)
    socket.writeTimeout = Some(writeTimeout)
    try {
        socket.connect(timeout: Some(readTimeout))
        let handshake = openNativeTls13ClientTransport(
            TcpSocketByteTransport(socket),
            config
        )
        let selected = selectNativeTlsApplicationProtocol(handshake.negotiatedAlpn)
        if (expectedAlpn == "h2" && selected != NativeTlsApplicationProtocol.H2) {
            handshake.transport.close()
            throw Exception("native HTTPS H2 backend requires negotiated h2 ALPN")
        }
        if (expectedAlpn == "http/1.1" && selected != NativeTlsApplicationProtocol.Http11) {
            handshake.transport.close()
            throw Exception("native HTTPS H1 backend requires negotiated http/1.1 ALPN")
        }
        match (selected) {
            case NativeTlsApplicationProtocol.Http11 =>
                return sendNativeH1RequestOverTransport(
                    method,
                    url,
                    headers,
                    body,
                    bodyStream,
                    bodyStreamLength,
                    handshake.transport
                )
            case NativeTlsApplicationProtocol.H2 =>
                return sendNativeH2RequestOverTransport(
                    method,
                    url,
                    headers,
                    body,
                    handshake.transport
                )
        }
    } catch (e: Exception) {
        closeNativeH1Socket(socket)
        throw e
    }
}
