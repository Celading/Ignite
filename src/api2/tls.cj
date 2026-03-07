package ignite.api2

import stdx.net.tls.TlsServerConfig
import stdx.crypto.x509.X509Certificate
import stdx.crypto.keys.GeneralPrivateKey

/// 从 PEM 字符串加载 TLS 服务端配置，并启用 HTTP/2 + HTTP/1.1 ALPN。
/// 证书链与私钥均使用 stdx 官方推荐 API（X509Certificate.decodeFromPem、GeneralPrivateKey.decodeFromPem），
/// 避免业务层直接依赖 stdx.crypto.x509 / stdx.crypto.keys 的具体类型。
///
/// - certPem: 证书 PEM 内容（可含多张证书，decodeFromPem 返回 Array）
/// - keyPem: 私钥 PEM 内容
/// - 返回: 已设置 supportedAlpnProtocols = ["h2", "http/1.1"] 的 TlsServerConfig，可直接用于 ServerBuilder.tlsConfig(...)
public func loadTlsServerConfigForHttp2(certPem: String, keyPem: String): TlsServerConfig {
    let certChain = X509Certificate.decodeFromPem(certPem)
    let certKey = GeneralPrivateKey.decodeFromPem(keyPem)
    var tlsConfig = TlsServerConfig(certChain, certKey)
    tlsConfig.supportedAlpnProtocols = ["h2", "http/1.1"]
    tlsConfig
}