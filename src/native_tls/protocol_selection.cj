package ignite.native_tls

public enum NativeTlsApplicationProtocol <: Equatable<NativeTlsApplicationProtocol> & ToString {
    | H2
    | Http11

    public operator func ==(right: NativeTlsApplicationProtocol): Bool {
        ordinalValue() == right.ordinalValue()
    }

    public operator func !=(right: NativeTlsApplicationProtocol): Bool {
        !(this == right)
    }

    public func ordinalValue(): Int64 {
        match (this) {
            case H2 => 0
            case Http11 => 1
        }
    }

    public func toString(): String {
        match (this) {
            case H2 => "h2"
            case Http11 => "http/1.1"
        }
    }
}

public class NativeTlsProtocolSelectionException <: Exception {
    public let negotiatedAlpn: String

    public init(negotiatedAlpn: String, message: String) {
        super(message)
        this.negotiatedAlpn = negotiatedAlpn
    }
}

public func selectNativeTlsApplicationProtocol(
    negotiatedAlpn: String
): NativeTlsApplicationProtocol {
    let normalized = negotiatedAlpn.trimAscii().toAsciiLower()
    match (normalized) {
        case "h2" => NativeTlsApplicationProtocol.H2
        case "http/1.1" => NativeTlsApplicationProtocol.Http11
        case _ => throw NativeTlsProtocolSelectionException(
            normalized,
            "native TLS requires negotiated ALPN h2 or http/1.1"
        )
    }
}
