package ignite.tests

import ignite.binary.*

@Test
public class BinaryAuthenticatorDataTestSuite {
    @TestCase
    public func testDecodeAuthenticatorDataFixedHeaderAndTail(): Unit {
        let wire = "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f" +
            "c5" + "0000002a" + "aabbccdd"
        let value = decodeAuthenticatorData(authHexToBytes(wire))

        @Assert(authBytesToHex(value.rpIdHash), "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f")
        @Assert(Int64(value.flags.rawValue), 0xc5)
        @Assert(value.flags.isUserPresent(), true)
        @Assert(value.flags.isUserVerified(), true)
        @Assert(value.flags.isBackupEligible(), false)
        @Assert(value.flags.isBackupState(), false)
        @Assert(value.flags.hasAttestedCredentialData(), true)
        @Assert(value.flags.hasExtensions(), true)
        @Assert(Int64(value.signCount), 42)
        @Assert(authBytesToHex(value.tail), "aabbccdd")
    }

    @TestCase
    public func testDecodeAuthenticatorDataAllowsEmptyTail(): Unit {
        let wire = "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff" +
            "00" + "00000000"
        let value = decodeAuthenticatorData(authHexToBytes(wire))

        @Assert(value.tail.size, 0)
        @Assert(value.flags.isUserPresent(), false)
        @Assert(value.flags.hasAttestedCredentialData(), false)
        @Assert(Int64(value.signCount), 0)
    }

    @TestCase
    public func testDecodeAuthenticatorDataRejectsTruncatedInput(): Unit {
        let wire = "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f" +
            "01" + "000000"
        assertAuthenticatorFailure(
            authHexToBytes(wire),
            AuthenticatorDataErrorCode.TruncatedInput
        )
    }

    @TestCase
    public func testAuthenticatorDataCopiesInputBytes(): Unit {
        let wire = "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f" +
            "85" + "00000001" + "deadbeef"
        let source = authHexToBytes(wire)
        let value = decodeAuthenticatorData(source)
        source[0] = UInt8(0xff)
        source[32] = UInt8(0x00)
        source[37] = UInt8(0x00)

        @Assert(authBytesToHex(value.rpIdHash), "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f")
        @Assert(Int64(value.flags.rawValue), 0x85)
        @Assert(authBytesToHex(value.tail), "deadbeef")
    }
}

func assertAuthenticatorFailure(
    bytes: Array<UInt8>,
    expectedCode: AuthenticatorDataErrorCode
): Unit {
    try {
        let _ = decodeAuthenticatorData(bytes)
        @Fail("authenticatorData decode should have failed")
    } catch (e: AuthenticatorDataException) {
        @Assert(e.code, expectedCode)
    }
}

func authHexToBytes(input: String): Array<UInt8> {
    let text = input.trimAscii().toAsciiLower()
    let runes = text.toRuneArray()
    if (runes.size == 0 || (runes.size % 2) != 0) {
        throw Exception("hex length must be even and non-empty")
    }
    let out = Array<UInt8>(runes.size / 2, repeat: 0)
    var i: Int64 = 0
    while (i < runes.size) {
        let hi = authHexNibble(runes[i])
        let lo = authHexNibble(runes[i + 1])
        if (hi < 0 || lo < 0) {
            throw Exception("invalid hex text")
        }
        out[i / 2] = UInt8((hi << 4) | lo)
        i += 2
    }
    out
}

func authBytesToHex(input: Array<UInt8>): String {
    let chars = "0123456789abcdef".toRuneArray()
    var out = ""
    for (b in input) {
        let n = Int64(b)
        out += chars[(n >> 4) & 0x0F].toString()
        out += chars[n & 0x0F].toString()
    }
    out
}

func authHexNibble(ch: Rune): Int64 {
    match (ch) {
        case r'0' => 0
        case r'1' => 1
        case r'2' => 2
        case r'3' => 3
        case r'4' => 4
        case r'5' => 5
        case r'6' => 6
        case r'7' => 7
        case r'8' => 8
        case r'9' => 9
        case r'a' => 10
        case r'b' => 11
        case r'c' => 12
        case r'd' => 13
        case r'e' => 14
        case r'f' => 15
        case _ => -1
    }
}
