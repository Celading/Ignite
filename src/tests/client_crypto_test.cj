package ignite.tests

import std.collection.HashMap
import ignite.api2

@Test
public class ClientCryptoTestSuite {
    func buildConfig(kind: api2.ClientCryptoProviderKind): api2.ClientCryptoConfig {
        let ring = HashMap<String, Array<UInt8>>()
        ring.add("k1", "0123456789abcdef0123456789abcdef".toArray())
        api2.ClientCryptoConfig(
            providerKind: kind,
            activeKid: "k1",
            keyRing: ring,
            aeadAlgorithm: "AES-256-GCM"
        )
    }

    @TestCase
    public func testEncryptDecryptRoundTripWithJinguiProvider(): Unit {
        let payload = "{\"message\":\"hello\"}"
        let aad = "route:/v1/demo"
        let cfg = buildConfig(api2.ClientCryptoProviderKind.jinguiSSL)
        let envelope = api2.encryptJsonToEnvelopeV1(cfg, payload, aadText: aad)
        let restored = api2.decryptEnvelopeV1ToJson(cfg, envelope, aadText: aad)
        @Assert(restored, payload)
    }

    @TestCase
    public func testLegacyFallbackCannotWriteNewEnvelope(): Unit {
        let cfg = buildConfig(api2.ClientCryptoProviderKind.StdxFallback)
        try {
            let _ = api2.encryptJsonToEnvelopeV1(cfg, "{\"blocked\":true}")
            @Fail("legacy fallback must not write new secure envelopes")
        } catch (e: api2.ClientCryptoException) {
            @Assert(e.code, api2.ClientCryptoErrorCode.CryptoUnavailable)
        }
    }

    @TestCase
    public func testTamperedTagFailsDecrypt(): Unit {
        let cfg = buildConfig(api2.ClientCryptoProviderKind.jinguiSSL)
        let envelopeJson = api2.encryptJsonToEnvelopeV1(cfg, "{\"ok\":true}")
        let env = api2.EnvelopeV1.parse(envelopeJson)

        let tamperedTag = mutateToken(env.tag)
        let tampered = api2.EnvelopeV1(1, env.alg, env.kid, env.nonce, env.ct, tamperedTag).toJsonString()

        try {
            let _ = api2.decryptEnvelopeV1ToJson(cfg, tampered)
            @Fail("tampered tag should fail")
        } catch (e: api2.ClientCryptoException) {
            @Assert(e.code, api2.ClientCryptoErrorCode.DecryptFailed)
        }
    }

    @TestCase
    public func testKeyNotFoundError(): Unit {
        let cfg = buildConfig(api2.ClientCryptoProviderKind.jinguiSSL)
        let envelopeJson = api2.encryptJsonToEnvelopeV1(cfg, "{\"ok\":true}")
        let env = api2.EnvelopeV1.parse(envelopeJson)
        let rewritten = api2.EnvelopeV1(1, env.alg, "k2", env.nonce, env.ct, env.tag).toJsonString()

        try {
            let _ = api2.decryptEnvelopeV1ToJson(cfg, rewritten)
            @Fail("unknown key should fail")
        } catch (e: api2.ClientCryptoException) {
            @Assert(e.code, api2.ClientCryptoErrorCode.KeyNotFound)
        }
    }

    @TestCase
    public func testBadEnvelopeRejects(): Unit {
        let cfg = buildConfig(api2.ClientCryptoProviderKind.StdxFallback)
        let badJson = "{\"v\":2,\"alg\":\"AES-256-GCM\",\"kid\":\"k1\",\"nonce\":\"x\",\"ct\":\"y\",\"tag\":\"z\"}"
        try {
            let _ = api2.decryptEnvelopeV1ToJson(cfg, badJson)
            @Fail("invalid version should fail")
        } catch (e: api2.ClientCryptoException) {
            @Assert(e.code, api2.ClientCryptoErrorCode.BadEnvelope)
        }
    }

    @TestCase
    public func testRandomHexLength(): Unit {
        let hex = api2.clientCryptoRandomHex(32)
        @Assert(hex.size, 32)
    }

    @TestCase
    public func testExternalAes256GcmVectorDecrypts(): Unit {
        let ring = HashMap<String, Array<UInt8>>()
        ring.add("k1", Array<UInt8>(32, repeat: 0))
        let cfg = api2.ClientCryptoConfig(
            providerKind: api2.ClientCryptoProviderKind.jinguiSSL,
            activeKid: "k1",
            keyRing: ring
        )
        let envelope = "{\"v\":1,\"alg\":\"AES-256-GCM\",\"kid\":\"k1\",\"nonce\":\"AAAAAAAAAAAAAAAA\",\"ct\":\"psIsUSI\",\"tag\":\"gpHaSvAXItXfyQKgxMHeVQ\"}"
        let plain = api2.decryptEnvelopeV1ToJson(cfg, envelope, aadText: "route")
        @Assert(plain, "hello")
    }

    @TestCase
    public func testLegacyPseudoEnvelopeRequiresExplicitFallbackRead(): Unit {
        let key = legacyRepeatedKey("migration-key")
        let ring = HashMap<String, Array<UInt8>>()
        ring.add("k1", key)
        let envelope = "{\"v\":1,\"alg\":\"AES-256-GCM\",\"kid\":\"k1\",\"nonce\":\"AAAAAAAAAAAAAAAA\",\"ct\":\"osb5SoiTqhqbMJo2iQ\",\"tag\":\"vZbonRw57MZ8dLoeOh8EDw\"}"

        let secureConfig = api2.ClientCryptoConfig(
            providerKind: api2.ClientCryptoProviderKind.jinguiSSL,
            activeKid: "k1",
            keyRing: ring
        )
        try {
            let _ = api2.decryptEnvelopeV1ToJson(secureConfig, envelope)
            @Fail("secure provider must reject the pre-HQ-0848 pseudo envelope")
        } catch (e: api2.ClientCryptoException) {
            @Assert(e.code, api2.ClientCryptoErrorCode.DecryptFailed)
        }

        let legacyConfig = api2.ClientCryptoConfig(
            providerKind: api2.ClientCryptoProviderKind.StdxFallback,
            activeKid: "k1",
            keyRing: ring
        )
        @Assert(api2.decryptEnvelopeV1ToJson(legacyConfig, envelope), "legacy-pseudo")
    }
}

func legacyRepeatedKey(raw: String): Array<UInt8> {
    let source = raw.toArray()
    let out = Array<UInt8>(32, repeat: 0)
    for (i in 0..out.size) {
        out[i] = source[i % source.size]
    }
    out
}

func mutateToken(token: String): String {
    let runes = token.toRuneArray()
    if (runes.size == 0) {
        return "a"
    }
    var out = ""
    for (i in 0..runes.size) {
        if (i == 0) {
            if (runes[i] == r'a') {
                out += "b"
            } else {
                out += "a"
            }
        } else {
            out += runes[i].toString()
        }
    }
    out
}
