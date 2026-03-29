package ignite.tests

import std.collection.{ArrayList, HashMap}
import ignite.client.*
import ignite.api2

@Test
public class ClientHookTestSuite {
    func buildCryptoConfig(): api2.ClientCryptoConfig {
        let ring = HashMap<String, Array<UInt8>>()
        ring.add("k1", "0123456789abcdef0123456789abcdef".toArray())
        api2.ClientCryptoConfig(
            providerKind: api2.ClientCryptoProviderKind.StdxFallback,
            activeKid: "k1",
            keyRing: ring,
            aeadAlgorithm: "AES-256-GCM"
        )
    }

    @TestCase
    public func testHookPipelineOrderForRequestAndError(): Unit {
        let events = ArrayList<String>()
        let client = RestClient(
            readTimeout: Duration.second * 15,
            writeTimeout: Duration.second * 15,
            poolSize: 10
        )
            .onRequest({ _ =>
                events.add("global-request")
            })
            .onError({ _ =>
                events.add("global-error")
            })

        try {
            let _ = client.request()
                .method("POST")
                .url("http://127.0.0.1:1/hook")
                .onRequest({ _ =>
                    events.add("local-request")
                    throw api2.ClientCryptoException(
                        api2.ClientCryptoErrorCode.CryptoUnavailable,
                        "request hook blocked"
                    )
                })
                .onError({ _ =>
                    events.add("local-error")
                })
                .send()
            @Fail("request hook should fail")
        } catch (e: api2.ClientCryptoException) {
            @Assert(e.code, api2.ClientCryptoErrorCode.CryptoUnavailable)
        }

        @Assert(events.size, 4)
        @Assert(events[0], "global-request")
        @Assert(events[1], "local-request")
        @Assert(events[2], "global-error")
        @Assert(events[3], "local-error")
    }

    @TestCase
    public func testEncryptedBodyFlowsThroughRequestHook(): Unit {
        let cfg = buildCryptoConfig()
        let marks = ArrayList<String>()

        let client = RestClient(
            readTimeout: Duration.second * 15,
            writeTimeout: Duration.second * 15,
            poolSize: 10
        )
            .useCrypto(cfg)
            .onRequest({ _ =>
                marks.add("request")
                throw api2.ClientCryptoException(
                    api2.ClientCryptoErrorCode.CryptoUnavailable,
                    "stop before network"
                )
            })
            .onError({ _ =>
                marks.add("error")
            })

        try {
            let _ = client.request()
                .method("POST")
                .url("http://127.0.0.1:1/secure")
                .encryptedBodyJson("{\"hello\":\"world\"}", aad: "route:/secure")
                .send()
            @Fail("encrypted request should be interrupted by hook")
        } catch (e: api2.ClientCryptoException) {
            @Assert(e.code, api2.ClientCryptoErrorCode.CryptoUnavailable)
        }

        @Assert(marks.size, 2)
        @Assert(marks[0], "request")
        @Assert(marks[1], "error")
    }
}
