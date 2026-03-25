package ignite.api2

import stdx.net.tls.TlsServerConfig
import stdx.crypto.x509.X509Certificate
import stdx.crypto.keys.GeneralPrivateKey

/// Load TLS server config from PEM strings, enable HTTP/2 + HTTP/1.1 ALPN.
/// Certificate chain and private key use stdx official recommended API (X509Certificate.decodeFromPem, GeneralPrivateKey.decodeFromPem),
/// avoid business layer directly depending on the specific types of stdx.crypto.x509 / stdx.crypto.keys.
///
/// - certPem: Certificate PEM content (can contain multiple certificates, decodeFromPem returns Array)
/// - keyPem: Private key PEM content
/// - return: TlsServerConfig with supportedAlpnProtocols = ["h2", "http/1.1"], can be used directly for ServerBuilder.tlsConfig(...)
public func loadTlsServerConfigForHttp2(certPem: String, keyPem: String): TlsServerConfig {
    let certChain = X509Certificate.decodeFromPem(certPem)
    let certKey = GeneralPrivateKey.decodeFromPem(keyPem)
    var tlsConfig = TlsServerConfig(certChain, certKey)
    tlsConfig.supportedAlpnProtocols = ["h2", "http/1.1"]
    tlsConfig
}