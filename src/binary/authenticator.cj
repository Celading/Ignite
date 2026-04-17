package ignite.binary

public enum AuthenticatorDataErrorCode <: Equatable<AuthenticatorDataErrorCode> & ToString {
    | TruncatedInput

    public operator func ==(right: AuthenticatorDataErrorCode): Bool {
        ordinalValue() == right.ordinalValue()
    }

    public operator func !=(right: AuthenticatorDataErrorCode): Bool {
        !(this == right)
    }

    public func ordinalValue(): Int64 {
        match (this) {
            case TruncatedInput => 0
        }
    }

    public func toString(): String {
        match (this) {
            case TruncatedInput => "TRUNCATED_INPUT"
        }
    }
}

public class AuthenticatorDataException <: Exception {
    public let code: AuthenticatorDataErrorCode

    public init(code: AuthenticatorDataErrorCode, message: String) {
        super(message)
        this.code = code
    }
}

public class AuthenticatorDataFlags {
    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        this.rawValue = rawValue
    }

    public func isUserPresent(): Bool {
        hasMask(UInt8(0x01))
    }

    public func isUserVerified(): Bool {
        hasMask(UInt8(0x04))
    }

    public func isBackupEligible(): Bool {
        hasMask(UInt8(0x08))
    }

    public func isBackupState(): Bool {
        hasMask(UInt8(0x10))
    }

    public func hasAttestedCredentialData(): Bool {
        hasMask(UInt8(0x40))
    }

    public func hasExtensions(): Bool {
        hasMask(UInt8(0x80))
    }

    func hasMask(mask: UInt8): Bool {
        (Int64(rawValue) & Int64(mask)) != 0
    }
}

public class AuthenticatorData {
    public static let fixedHeaderLength: Int64 = 37

    public let rpIdHash: Array<UInt8>
    public let flags: AuthenticatorDataFlags
    public let signCount: UInt32
    public let tail: Array<UInt8>

    public init(
        rpIdHash: Array<UInt8>,
        flags: AuthenticatorDataFlags,
        signCount: UInt32,
        tail!: Array<UInt8> = []
    ) {
        if (rpIdHash.size != 32) {
            throw AuthenticatorDataException(
                AuthenticatorDataErrorCode.TruncatedInput,
                "authenticatorData rpIdHash must be 32 bytes"
            )
        }
        this.rpIdHash = cloneBytes(rpIdHash)
        this.flags = AuthenticatorDataFlags(flags.rawValue)
        this.signCount = signCount
        this.tail = cloneBytes(tail)
    }
}

public func decodeAuthenticatorData(input: Array<UInt8>): AuthenticatorData {
    if (input.size < AuthenticatorData.fixedHeaderLength) {
        throw AuthenticatorDataException(
            AuthenticatorDataErrorCode.TruncatedInput,
            "authenticatorData must be at least ${AuthenticatorData.fixedHeaderLength} bytes"
        )
    }

    let rpIdHash = sliceBytes(input, 0, end: 32)
    let flags = AuthenticatorDataFlags(input[32])
    let signCount = readUint32BE(input, 33)
    let tail = sliceBytes(input, AuthenticatorData.fixedHeaderLength)
    AuthenticatorData(rpIdHash, flags, signCount, tail: tail)
}
