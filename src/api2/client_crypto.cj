package ignite.api2

import ignite.binary.{base64UrlEncode, base64UrlDecode, cloneBytes}
import jinguissl.live.{
    ContractAeadAlgorithm,
    ContractErrorCode,
    ContractException,
    contractDecryptEnvelopeJsonCompatV1UInt8,
    contractEncryptEnvelopeJsonV1UInt8,
    contractRandomUInt8Bytes
}
import std.collection.{HashMap, ArrayList}

public enum ClientCryptoProviderKind <: Equatable<ClientCryptoProviderKind> & ToString {
    | jinguiSSL
    | StdxFallback

    public operator func ==(right: ClientCryptoProviderKind): Bool {
        ordinalValue() == right.ordinalValue()
    }

    public operator func !=(right: ClientCryptoProviderKind): Bool {
        !(this == right)
    }

    public func ordinalValue(): Int64 {
        match (this) {
            case jinguiSSL => 0
            case StdxFallback => 1
        }
    }

    public func toString(): String {
        match (this) {
            case jinguiSSL => "jinguiSSL"
            case StdxFallback => "stdx-fallback"
        }
    }
}

public enum ClientCryptoErrorCode <: Equatable<ClientCryptoErrorCode> & ToString {
    | BadEnvelope
    | KeyNotFound
    | DecryptFailed
    | CryptoUnavailable

    public operator func ==(right: ClientCryptoErrorCode): Bool {
        ordinalValue() == right.ordinalValue()
    }

    public operator func !=(right: ClientCryptoErrorCode): Bool {
        !(this == right)
    }

    public func ordinalValue(): Int64 {
        match (this) {
            case BadEnvelope => 0
            case KeyNotFound => 1
            case DecryptFailed => 2
            case CryptoUnavailable => 3
        }
    }

    public func toString(): String {
        match (this) {
            case BadEnvelope => "BAD_ENVELOPE"
            case KeyNotFound => "KEY_NOT_FOUND"
            case DecryptFailed => "DECRYPT_FAILED"
            case CryptoUnavailable => "CRYPTO_UNAVAILABLE"
        }
    }
}

public class ClientCryptoException <: Exception {
    public let code: ClientCryptoErrorCode

    public init(code: ClientCryptoErrorCode, message: String) {
        super(message)
        this.code = code
    }
}

public interface ClientCryptoProvider {
    func randomBytes(size: Int64): Array<UInt8>

    func aeadEncrypt(
        key: Array<UInt8>,
        plaintext: Array<UInt8>,
        aad: Array<UInt8>
    ): (Array<UInt8>, Array<UInt8>, Array<UInt8>)

    func aeadDecrypt(
        key: Array<UInt8>,
        nonce: Array<UInt8>,
        ciphertext: Array<UInt8>,
        tag: Array<UInt8>,
        aad: Array<UInt8>
    ): Array<UInt8>
}

public class ClientCryptoConfig {
    public var providerKind: ClientCryptoProviderKind
    public var activeKid: String
    public var keyRing: HashMap<String, Array<UInt8>>
    public var aeadAlgorithm: String

    public init(
        providerKind!: ClientCryptoProviderKind = jinguiSSL,
        activeKid!: String = "k1",
        keyRing!: HashMap<String, Array<UInt8>> = HashMap<String, Array<UInt8>>(),
        aeadAlgorithm!: String = "AES-256-GCM"
    ) {
        this.providerKind = providerKind
        this.activeKid = activeKid
        this.keyRing = HashMap<String, Array<UInt8>>()
        this.aeadAlgorithm = normalizeAlg(aeadAlgorithm)
        for ((kid, key) in keyRing) {
            this.keyRing.add(kid, cloneBytes(key))
        }
    }

    public func addKey(kid: String, key: Array<UInt8>): ClientCryptoConfig {
        keyRing.add(kid, cloneBytes(key))
        this
    }

    public func activeKey(): Array<UInt8> {
        match (keyRing.get(activeKid)) {
            case Some(key) => cloneBytes(key)
            case None =>
                throw ClientCryptoException(
                    ClientCryptoErrorCode.KeyNotFound,
                    "active key id not found: ${activeKid}"
                )
        }
    }
}

public class EnvelopeV1 {
    public let v: Int64
    public let alg: String
    public let kid: String
    public let nonce: String
    public let ct: String
    public let tag: String

    public init(v: Int64, alg: String, kid: String, nonce: String, ct: String, tag: String) {
        if (v != 1) {
            throw ClientCryptoException(BadEnvelope, "envelope version must be 1")
        }
        if (alg.size == 0 || kid.size == 0 || nonce.size == 0 || ct.size == 0 || tag.size == 0) {
            throw ClientCryptoException(BadEnvelope, "envelope fields must not be empty")
        }
        requireToken(alg, "alg")
        requireToken(kid, "kid")
        this.v = v
        this.alg = alg
        this.kid = kid
        this.nonce = nonce
        this.ct = ct
        this.tag = tag
    }

    public func toJsonString(): String {
        "{\"v\":1,\"alg\":\"${alg}\",\"kid\":\"${kid}\",\"nonce\":\"${nonce}\",\"ct\":\"${ct}\",\"tag\":\"${tag}\"}"
    }

    public static func parse(json: String): EnvelopeV1 {
        let compact = removeAsciiSpaces(json)
        if (compact.size == 0) {
            throw ClientCryptoException(BadEnvelope, "envelope is empty")
        }

        let contractShape = indexOfString(compact, "\"ver\":") >= 0
        let version = extractIntField(compact, if (contractShape) { "ver" } else { "v" })
        let alg = extractStringField(compact, "alg")
        let kid = extractStringField(compact, "kid")
        let nonce = extractStringField(compact, "nonce")
        let ct = extractStringField(compact, if (contractShape) { "ciphertext" } else { "ct" })
        let tag = extractStringField(compact, "tag")
        EnvelopeV1(version, alg, kid, nonce, ct, tag)
    }
}

class jinguiSSLClientCryptoProvider <: ClientCryptoProvider {
    public override func randomBytes(size: Int64): Array<UInt8> {
        if (size <= 0) {
            throw ClientCryptoException(BadEnvelope, "random size must be > 0")
        }
        try {
            contractRandomUInt8Bytes(size)
        } catch (e: ContractException) {
            throw mapContractCryptoError(e)
        }
    }

    public override func aeadEncrypt(
        key: Array<UInt8>,
        plaintext: Array<UInt8>,
        aad: Array<UInt8>
    ): (Array<UInt8>, Array<UInt8>, Array<UInt8>) {
        requireAes256Key(key)
        try {
            let envelopeJson = contractEncryptEnvelopeJsonV1UInt8(
                ContractAeadAlgorithm.Aes256Gcm,
                "ignite-provider",
                key,
                plaintext,
                aad: aad
            )
            (
                decodeEnvelopeSegmentOrThrow(extractStringField(envelopeJson, "nonce")),
                decodeEnvelopeSegmentOrThrow(extractStringField(envelopeJson, "ciphertext")),
                decodeEnvelopeSegmentOrThrow(extractStringField(envelopeJson, "tag"))
            )
        } catch (e: ContractException) {
            throw mapContractCryptoError(e)
        }
    }

    public override func aeadDecrypt(
        key: Array<UInt8>,
        nonce: Array<UInt8>,
        ciphertext: Array<UInt8>,
        tag: Array<UInt8>,
        aad: Array<UInt8>
    ): Array<UInt8> {
        requireAes256Key(key)
        let keyRing = HashMap<String, Array<UInt8>>()
        keyRing.add("ignite-provider", cloneBytes(key))
        let envelopeJson = EnvelopeV1(
            1,
            "AES-256-GCM",
            "ignite-provider",
            base64UrlEncode(nonce),
            base64UrlEncode(ciphertext),
            base64UrlEncode(tag)
        ).toJsonString()
        try {
            contractDecryptEnvelopeJsonCompatV1UInt8(
                envelopeJson,
                keyRing,
                aadOverride: Some(cloneBytes(aad))
            )
        } catch (e: ContractException) {
            throw mapContractCryptoError(e)
        }
    }
}

/// Retained only for explicit reads of deprecated insecure envelopes.
class StdxFallbackClientCryptoProvider <: ClientCryptoProvider {
    public override func randomBytes(size: Int64): Array<UInt8> {
        let _ = size
        throw ClientCryptoException(
            ClientCryptoErrorCode.CryptoUnavailable,
            "stdx-fallback is a legacy read-only provider and cannot generate entropy"
        )
    }

    public override func aeadEncrypt(
        key: Array<UInt8>,
        plaintext: Array<UInt8>,
        aad: Array<UInt8>
    ): (Array<UInt8>, Array<UInt8>, Array<UInt8>) {
        let _ = key
        let _ = plaintext
        let _ = aad
        throw ClientCryptoException(
            ClientCryptoErrorCode.CryptoUnavailable,
            "stdx-fallback is a legacy read-only provider and cannot encrypt"
        )
    }

    public override func aeadDecrypt(
        key: Array<UInt8>,
        nonce: Array<UInt8>,
        ciphertext: Array<UInt8>,
        tag: Array<UInt8>,
        aad: Array<UInt8>
    ): Array<UInt8> {
        if (key.size == 0) {
            throw ClientCryptoException(ClientCryptoErrorCode.CryptoUnavailable, "fallback key must not be empty")
        }
        let expected = legacyFallbackTag(key, nonce, ciphertext, aad)
        if (!constantTimeEquals(expected, tag)) {
            throw ClientCryptoException(DecryptFailed, "legacy fallback tag mismatch")
        }
        let stream = legacyDeriveStream(key, nonce, ciphertext.size)
        legacyXorWithStream(ciphertext, stream)
    }
}

public func clientCryptoProvider(kind: ClientCryptoProviderKind): ClientCryptoProvider {
    match (kind) {
        case jinguiSSL => jinguiSSLClientCryptoProvider()
        case StdxFallback => StdxFallbackClientCryptoProvider()
    }
}

public func encryptEnvelopeV1(
    config: ClientCryptoConfig,
    plaintext: Array<UInt8>,
    aad!: Array<UInt8> = []
): String {
    requireAeadAlgorithm(config.aeadAlgorithm)
    let provider = clientCryptoProvider(config.providerKind)
    let key = config.activeKey()
    let (nonceRaw, ctRaw, tagRaw) = provider.aeadEncrypt(key, plaintext, aad)
    let envelope = EnvelopeV1(
        1,
        config.aeadAlgorithm,
        config.activeKid,
        base64UrlEncode(nonceRaw),
        base64UrlEncode(ctRaw),
        base64UrlEncode(tagRaw)
    )
    envelope.toJsonString()
}

public func encryptJsonToEnvelopeV1(
    config: ClientCryptoConfig,
    jsonPayload: String,
    aadText!: String = ""
): String {
    encryptEnvelopeV1(config, jsonPayload.toArray(), aad: aadText.toArray())
}

public func decryptEnvelopeV1(
    config: ClientCryptoConfig,
    envelopeJson: String,
    aad!: Array<UInt8> = []
): Array<UInt8> {
    let envelope = EnvelopeV1.parse(envelopeJson)
    requireAeadAlgorithm(envelope.alg)

    match (config.keyRing.get(envelope.kid)) {
        case Some(key) =>
            let provider = clientCryptoProvider(config.providerKind)
            let nonce = decodeEnvelopeSegmentOrThrow(envelope.nonce)
            let ct = decodeEnvelopeSegmentOrThrow(envelope.ct)
            let tag = decodeEnvelopeSegmentOrThrow(envelope.tag)
            provider.aeadDecrypt(key, nonce, ct, tag, aad)
        case None =>
            throw ClientCryptoException(ClientCryptoErrorCode.KeyNotFound, "key id not found: ${envelope.kid}")
    }
}

public func decryptEnvelopeV1ToJson(
    config: ClientCryptoConfig,
    envelopeJson: String,
    aadText!: String = ""
): String {
    String.fromUtf8(decryptEnvelopeV1(config, envelopeJson, aad: aadText.toArray()))
}

public func clientCryptoRandomHex(length: Int64): String {
    if (length <= 0) {
        throw ClientCryptoException(BadEnvelope, "hex length must be > 0")
    }
    let bytesNeeded = (length + 1) / 2
    let entropy = clientCryptoProvider(jinguiSSL).randomBytes(bytesNeeded)

    let chars = "0123456789abcdef".toRuneArray()
    var out = ""
    for (b in entropy) {
        let n = Int64(b)
        out += chars[(n >> 4) & 0x0F].toString()
        out += chars[n & 0x0F].toString()
    }
    if (out.size > length) {
        takePrefix(out, length)
    } else {
        out
    }
}

func requireAeadAlgorithm(algRaw: String): Unit {
    let alg = normalizeAlg(algRaw)
    if (alg != "AES-256-GCM") {
        throw ClientCryptoException(BadEnvelope, "unsupported AEAD algorithm: ${algRaw}")
    }
}

func requireAes256Key(key: Array<UInt8>): Unit {
    if (key.size != 32) {
        throw ClientCryptoException(ClientCryptoErrorCode.CryptoUnavailable, "AES-256-GCM requires 32-byte key")
    }
}

func requireToken(value: String, fieldName: String): Unit {
    let runes = value.toRuneArray()
    if (runes.size == 0) {
        throw ClientCryptoException(BadEnvelope, "${fieldName} must not be empty")
    }
    for (ch in runes) {
        let ok =
            (ch >= r'a' && ch <= r'z') ||
            (ch >= r'A' && ch <= r'Z') ||
            (ch >= r'0' && ch <= r'9') ||
            ch == r'-' || ch == r'_' || ch == r'.'
        if (!ok) {
            throw ClientCryptoException(BadEnvelope, "${fieldName} contains invalid token chars")
        }
    }
}

func normalizeAlg(raw: String): String {
    raw.trimAscii().toAsciiUpper()
}

func decodeEnvelopeSegmentOrThrow(segment: String): Array<UInt8> {
    try {
        base64UrlDecode(segment)
    } catch (_: Exception) {
        throw ClientCryptoException(BadEnvelope, "invalid base64url field in envelope")
    }
}

func legacyDeriveStream(key: Array<UInt8>, nonce: Array<UInt8>, size: Int64): Array<UInt8> {
    let stream = Array<UInt8>(size, repeat: 0)
    var state: UInt64 = 0x9E3779B97F4A7C15

    for (b in key) {
        state = (state << 5) ^ (state >> 2) ^ UInt64(b)
    }
    for (b in nonce) {
        state = (state << 7) ^ (state >> 3) ^ UInt64(b)
    }

    var i = 0
    while (i < size) {
        state = state ^ (state << 13)
        state = state ^ (state >> 7)
        state = state ^ (state << 17)
        stream[i] = UInt8(state & 0xFF)
        i += 1
    }
    stream
}

func legacyXorWithStream(input: Array<UInt8>, stream: Array<UInt8>): Array<UInt8> {
    if (input.size != stream.size) {
        throw ClientCryptoException(BadEnvelope, "stream length mismatch")
    }
    let out = Array<UInt8>(input.size, repeat: 0)
    var i = 0
    while (i < input.size) {
        out[i] = input[i] ^ stream[i]
        i += 1
    }
    out
}

func legacyFallbackTag(
    key: Array<UInt8>,
    nonce: Array<UInt8>,
    ciphertext: Array<UInt8>,
    aad: Array<UInt8>
): Array<UInt8> {
    let acc = Array<UInt8>(16, repeat: 0)
    foldTag(acc, key)
    foldTag(acc, nonce)
    foldTag(acc, aad)
    foldTag(acc, ciphertext)
    acc
}

func mapContractCryptoError(e: ContractException): ClientCryptoException {
    let code = match (e.code) {
        case ContractErrorCode.BadInput => ClientCryptoErrorCode.BadEnvelope
        case ContractErrorCode.KeyNotFound => ClientCryptoErrorCode.KeyNotFound
        case ContractErrorCode.VerifyFailed => ClientCryptoErrorCode.DecryptFailed
        case _ => ClientCryptoErrorCode.CryptoUnavailable
    }
    ClientCryptoException(code, e.message)
}

func foldTag(acc: Array<UInt8>, data: Array<UInt8>): Unit {
    var i = 0
    while (i < data.size) {
        let idx = i % 16
        let rot = (idx * 13 + 7) & 0xFF
        let mixed = (Int64(acc[idx]) ^ Int64(data[i]))
        acc[idx] = UInt8((mixed + rot) & 0xFF)
        i += 1
    }
}

func constantTimeEquals(left: Array<UInt8>, right: Array<UInt8>): Bool {
    if (left.size != right.size) {
        return false
    }
    var diff: UInt8 = 0
    var i = 0
    while (i < left.size) {
        diff = diff | (left[i] ^ right[i])
        i += 1
    }
    diff == 0
}


func removeAsciiSpaces(s: String): String {
    let chars = s.toRuneArray()
    var out = ""
    for (ch in chars) {
        if (ch == r' ' || ch == r'\n' || ch == r'\r' || ch == r'\t') {
            continue
        }
        out += ch.toString()
    }
    out
}

func extractStringField(json: String, key: String): String {
    let pattern = "\"${key}\":\""
    let start = indexOfString(json, pattern)
    if (start < 0) {
        throw ClientCryptoException(BadEnvelope, "missing envelope field: ${key}")
    }
    let valueStart = start + pattern.size
    let valueEnd = indexOfRuneFrom(json, r'\"', valueStart)
    if (valueEnd < 0) {
        throw ClientCryptoException(BadEnvelope, "invalid envelope string field: ${key}")
    }
    substringRange(json, valueStart, valueEnd)
}

func extractIntField(json: String, key: String): Int64 {
    let pattern = "\"${key}\":"
    let start = indexOfString(json, pattern)
    if (start < 0) {
        throw ClientCryptoException(BadEnvelope, "missing envelope field: ${key}")
    }
    var i = start + pattern.size
    let runes = json.toRuneArray()
    var out = ""
    while (i < runes.size) {
        let ch = runes[i]
        if (ch >= r'0' && ch <= r'9') {
            out += ch.toString()
            i += 1
            continue
        }
        break
    }
    if (out.size == 0) {
        throw ClientCryptoException(BadEnvelope, "invalid envelope integer field: ${key}")
    }
    parseInt64Ascii(out)
}

func parseInt64Ascii(raw: String): Int64 {
    var out: Int64 = 0
    let runes = raw.toRuneArray()
    for (ch in runes) {
        out = out * 10 + digitOfRune(ch)
    }
    out
}

func indexOfString(s: String, needle: String): Int64 {
    let h = s.toRuneArray()
    let n = needle.toRuneArray()
    if (n.size == 0) { return 0 }
    if (h.size < n.size) { return -1 }

    var i = 0
    while (i <= h.size - n.size) {
        var ok = true
        var j = 0
        while (j < n.size) {
            if (h[i + j] != n[j]) {
                ok = false
                break
            }
            j += 1
        }
        if (ok) { return i }
        i += 1
    }
    -1
}

func indexOfRuneFrom(s: String, target: Rune, from: Int64): Int64 {
    let chars = s.toRuneArray()
    var i = from
    while (i < chars.size) {
        if (chars[i] == target) {
            return i
        }
        i += 1
    }
    -1
}

func takePrefix(s: String, count: Int64): String {
    let runes = s.toRuneArray()
    let limit = if (count < runes.size) { count } else { runes.size }
    var out = ""
    var i = 0
    while (i < limit) {
        out += runes[i].toString()
        i += 1
    }
    out
}

func substringRange(s: String, start: Int64, endExclusive: Int64): String {
    let runes = s.toRuneArray()
    if (start < 0 || endExclusive < start || endExclusive > runes.size) {
        throw ClientCryptoException(BadEnvelope, "invalid envelope string range")
    }
    var out = ""
    var i = start
    while (i < endExclusive) {
        out += runes[i].toString()
        i += 1
    }
    out
}

func digitOfRune(ch: Rune): Int64 {
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
        case _ => throw ClientCryptoException(BadEnvelope, "invalid numeric rune")
    }
}
