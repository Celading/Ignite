package ignite.tests

import ignite.client.*
import ignite.api2
import std.collection.{ArrayList, HashMap}

@Test
public class ClientTransportErrorEnvelopeTestSuite {
    func buildCryptoConfig(kind: api2.ClientCryptoProviderKind): api2.ClientCryptoConfig {
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
    public func testCryptoUnavailableSuggestsFallbackAndDoesNotConsumeConnection(): Unit {
        let observedMessages = ArrayList<String>()
        let cryptoConfig = buildCryptoConfig(api2.ClientCryptoProviderKind.jinguiSSL)
        let client = RestClient(
            readTimeout: Duration.second * 1,
            writeTimeout: Duration.second * 1,
            poolSize: 1
        )
            .useCrypto(cryptoConfig)
            .onError({ e =>
                observedMessages.add(e.message)
            })

        try {
            let _ = client.request()
                .method("GET")
                .url("http://127.0.0.1:1/transport-crypto-fallback")
                .header("x-ignite-log-case", "transport-crypto-unavailable")
                .encryptedBodyJson("{\"ok\":true}", aad: "route:/transport-crypto-fallback")
                .onRequest({ _ =>
                    throw api2.ClientCryptoException(
                        api2.ClientCryptoErrorCode.CryptoUnavailable,
                        "crypto provider unavailable during request prepare"
                    )
                })
                .send()
            @Fail("crypto unavailable should fail before send")
        } catch (e: api2.ClientCryptoException) {
            @Assert(e.code, api2.ClientCryptoErrorCode.CryptoUnavailable)
        } finally {
            client.close()
        }

        @Assert(observedMessages.size, 1)
        @Assert(contains(observedMessages[0], "[ignite.client.observe]"), true)
        @Assert(contains(observedMessages[0], "errorClass=CRYPTO"), true)
        @Assert(contains(observedMessages[0], "phase=request_prepare"), true)
        @Assert(contains(observedMessages[0], "causeCode=crypto_unavailable"), true)
        @Assert(contains(observedMessages[0], "backendId=stdx-http-client"), true)
        @Assert(contains(observedMessages[0], "providerId=-"), true)
        @Assert(contains(observedMessages[0], "cryptoProviderId=crypto:jinguiSSL"), true)
        @Assert(contains(observedMessages[0], "publicPath=stable-default"), true)
        @Assert(contains(observedMessages[0], "transportTags=scene=client,scheme=http,cryptoProvider=crypto:jinguiSSL"), true)
        @Assert(contains(observedMessages[0], "retryable=false"), true)
        @Assert(contains(observedMessages[0], "fallbackSuggested=true"), true)
        @Assert(contains(observedMessages[0], "connectionConsumed=false"), true)
        @Assert(contains(observedMessages[0], "fallbackFrom=stdx-http-client@crypto:jinguiSSL"), true)
        @Assert(contains(observedMessages[0], "fallbackTo=stdx-http-client@crypto:stdx-fallback"), true)
        @Assert(contains(observedMessages[0], "fallbackOutcome=suggested-only"), true)
        @Assert(contains(observedMessages[0], "retryCount=0"), true)
        @Assert(contains(observedMessages[0], "fields=case=transport-crypto-unavailable"), true)
    }

    func contains(text: String, target: String): Bool {
        let t = text.toRuneArray()
        let p = target.toRuneArray()
        if (p.size == 0) {
            return true
        }
        if (t.size < p.size) {
            return false
        }
        var i: Int64 = 0
        while (i <= t.size - p.size) {
            var ok = true
            var j: Int64 = 0
            while (j < p.size) {
                if (t[i + j] != p[j]) {
                    ok = false
                    break
                }
                j += 1
            }
            if (ok) {
                return true
            }
            i += 1
        }
        false
    }
}
