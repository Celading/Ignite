package ignite.api2

import std.collection.ArrayList
import stdx.net.tls.TlsServerConfig
import stdx.crypto.x509.X509Certificate
import stdx.crypto.keys.GeneralPrivateKey
import jinguissl.contract.{ContractException, contractValidateHttpServerTlsConfigInput}
import jinguissl.crypto.tls.TlsSessionCache

public enum TlsConfigLoadErrorCode <: Equatable<TlsConfigLoadErrorCode> & ToString {
    | BadInput
    | VerifyFailed
    | KeyNotFound
    | CryptoUnavailable
    | ComplianceRejected
    | Unsupported
    | InternalError

    public operator func ==(right: TlsConfigLoadErrorCode): Bool {
        ordinalValue() == right.ordinalValue()
    }

    public operator func !=(right: TlsConfigLoadErrorCode): Bool {
        !(this == right)
    }

    public func ordinalValue(): Int64 {
        match (this) {
            case BadInput => 0
            case VerifyFailed => 1
            case KeyNotFound => 2
            case CryptoUnavailable => 3
            case ComplianceRejected => 4
            case Unsupported => 5
            case InternalError => 6
        }
    }

    public func toString(): String {
        match (this) {
            case BadInput => "BAD_INPUT"
            case VerifyFailed => "VERIFY_FAILED"
            case KeyNotFound => "KEY_NOT_FOUND"
            case CryptoUnavailable => "CRYPTO_UNAVAILABLE"
            case ComplianceRejected => "COMPLIANCE_REJECTED"
            case Unsupported => "UNSUPPORTED"
            case InternalError => "INTERNAL_ERROR"
        }
    }
}

public class TlsConfigLoadException <: Exception {
    public let code: TlsConfigLoadErrorCode
    public let sourceCode: String

    public init(code: TlsConfigLoadErrorCode, sourceCode: String, message: String) {
        super(message)
        this.code = code
        this.sourceCode = sourceCode
    }
}

public func tlsToIgniteErrorCode(code: TlsConfigLoadErrorCode): String {
    "TLS_${code.toString()}"
}

public func tlsMapContractErrorCode(contractCode: String): TlsConfigLoadErrorCode {
    let normalized = contractCode.trimAscii().toAsciiUpper()
    match (normalized) {
        case "BAD_INPUT" => TlsConfigLoadErrorCode.BadInput
        case "VERIFY_FAILED" => TlsConfigLoadErrorCode.VerifyFailed
        case "KEY_NOT_FOUND" => TlsConfigLoadErrorCode.KeyNotFound
        case "CRYPTO_UNAVAILABLE" => TlsConfigLoadErrorCode.CryptoUnavailable
        case "COMPLIANCE_REJECTED" => TlsConfigLoadErrorCode.ComplianceRejected
        case "UNSUPPORTED" => TlsConfigLoadErrorCode.Unsupported
        case "INTERNAL_ERROR" => TlsConfigLoadErrorCode.InternalError
        case _ => TlsConfigLoadErrorCode.InternalError
    }
}

public func tlsWrapContractException(e: ContractException): TlsConfigLoadException {
    let contractCode = e.code.toString()
    let mappedCode = tlsMapContractErrorCode(contractCode)
    TlsConfigLoadException(
        mappedCode,
        contractCode,
        "jinguiSSL TLS precheck failed [${contractCode}]: ${e.message}"
    )
}

public func precheckHttpServerTlsConfigInput(
    certPem: String,
    keyPem: String,
    alpnProtocols!: Array<String> = ["h2", "http/1.1"],
    requireHttp2Alpn!: Bool = true
): Array<String> {
    let precheck = try {
        contractValidateHttpServerTlsConfigInput(
            certPem,
            keyPem,
            alpnProtocols: alpnProtocols,
            requireHttp2Alpn: requireHttp2Alpn
        )
    } catch (e: ContractException) {
        throw tlsWrapContractException(e)
    }
    precheck.normalizedAlpnProtocols
}

/// Load TLS server config from PEM strings, enable HTTP/2 + HTTP/1.1 ALPN.
/// Certificate chain and private key use stdx official recommended API (X509Certificate.decodeFromPem, GeneralPrivateKey.decodeFromPem),
/// avoid business layer directly depending on the specific types of stdx.crypto.x509 / stdx.crypto.keys.
///
/// - certPem: Certificate PEM content (can contain multiple certificates, decodeFromPem returns Array)
/// - keyPem: Private key PEM content
/// - alpnProtocols: ALPN protocol preference list. when empty, defaults to ["h2", "http/1.1"]
/// - requireHttp2Alpn: when true, precheck requires ALPN list contains h2
/// - return: TlsServerConfig with normalized ALPN list, can be used directly for ServerBuilder.tlsConfig(...)
public func loadTlsServerConfigForHttp2(
    certPem: String,
    keyPem: String,
    alpnProtocols!: Array<String> = ["h2", "http/1.1"],
    requireHttp2Alpn!: Bool = true,
    enablePrecheck!: Bool = true
): TlsServerConfig {
    let normalizedAlpn = if (enablePrecheck) {
        precheckHttpServerTlsConfigInput(
            certPem,
            keyPem,
            alpnProtocols: alpnProtocols,
            requireHttp2Alpn: requireHttp2Alpn
        )
    } else {
        normalizeAlpnProtocolsFallback(alpnProtocols)
    }

    try {
        let certChain = X509Certificate.decodeFromPem(certPem)
        let certKey = GeneralPrivateKey.decodeFromPem(keyPem)
        var tlsConfig = TlsServerConfig(certChain, certKey)
        tlsConfig.supportedAlpnProtocols = normalizedAlpn
        tlsConfig
    } catch (e: Exception) {
        throw TlsConfigLoadException(
            TlsConfigLoadErrorCode.InternalError,
            "STDX_TLS_CONFIG_BUILD",
            "stdx TLS config build failed: ${e.message}"
        )
    }
}

func normalizeAlpnProtocolsFallback(alpnProtocols: Array<String>): Array<String> {
    let out = ArrayList<String>()
    for (raw in alpnProtocols) {
        let item = raw.trimAscii().toAsciiLower()
        if (item.size == 0) {
            continue
        }
        var exists = false
        for (v in out) {
            if (v == item) {
                exists = true
                break
            }
        }
        if (!exists) {
            out.add(item)
        }
    }
    if (out.size == 0) {
        return ["h2", "http/1.1"]
    }
    out.toArray()
}

// jinguiSSL contract and TLS-session helpers may expose symbols through public ABI edges.
// Keep explicit type anchors so test linking consistently includes the needed subpackages.
func _useContractExceptionType(value!: ?ContractException = None): Bool {
    if (let Some(_error) <- value) {
        return true
    }
    false
}

func _useTlsSessionCacheType(value!: ?TlsSessionCache = None): Bool {
    if (let Some(_cache) <- value) {
        return true
    }
    false
}
