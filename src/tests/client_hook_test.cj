package ignite.tests

import ignite.*
import std.collection.{ArrayList, HashMap}
import ignite.client.*
import ignite.api2
import std.time.DateTime

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

    @TestCase
    public func testResponseHookSeesObserveHeadersAfterSuccess(): Unit {
        let app = App(config: Config())
        app.get("/response-hook", { ctx =>
            ctx.sendString("ok")
        })

        let port = choosePort(719)
        let url = "http://127.0.0.1:${port}/response-hook"
        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }

        let probeClient = RestClient(
            readTimeout: Duration.second * 1,
            writeTimeout: Duration.second * 1,
            poolSize: 1
        )
        let marks = ArrayList<String>()
        let retryCounts = ArrayList<String>()
        let fieldValues = ArrayList<String>()
        let durationValues = ArrayList<String>()
        let client = RestClient(
            readTimeout: Duration.second * 1,
            writeTimeout: Duration.second * 1,
            poolSize: 2
        )
            .onResponse({ resp =>
                marks.add("global")
                if (let Some(retryCount) <- resp.header("x-ignite-observe-retry-count")) {
                    retryCounts.add(retryCount)
                } else {
                    retryCounts.add("missing")
                }
            })

        try {
            waitForSuccessfulGet(probeClient, url)

            let resp = client.request()
                .method("GET")
                .url(url)
                .header("x-ignite-log-case", "response-hook")
                .onResponse({ localResp =>
                    marks.add("local")
                    if (let Some(fields) <- localResp.header("x-ignite-observe-fields")) {
                        fieldValues.add(fields)
                    } else {
                        fieldValues.add("missing")
                    }
                    if (let Some(duration) <- localResp.header("x-ignite-observe-duration-ms")) {
                        durationValues.add(duration)
                    } else {
                        durationValues.add("")
                    }
                })
                .send()

            @Assert(resp.status, 200)
            @Assert(resp.body(), "ok")
            @Assert(marks.size, 2)
            @Assert(marks[0], "global")
            @Assert(marks[1], "local")
            @Assert(retryCounts.size, 1)
            @Assert(retryCounts[0], "0")
            @Assert(fieldValues.size, 1)
            @Assert(fieldValues[0], "case=response-hook")
            @Assert(durationValues.size, 1)
            @Assert(durationValues[0].size > 0, true)
        } finally {
            probeClient.close()
            client.close()
            app.shutdown()
            try {
                let _ = serverFuture.get(Duration.second * 1)
            } catch (_: Exception) {
                serverFuture.cancel()
            }
        }
    }
}

func waitForSuccessfulGet(client: RestClient, url: String): Unit {
    var attempt: Int64 = 0
    while (attempt < 20) {
        try {
            let resp = client.request()
                .method("GET")
                .url(url)
                .send()
            if (resp.status == 200) {
                let _ = resp.body()
                return
            }
        } catch (_: Exception) {}
        if (attempt == 19) {
            throw Exception("failed to connect test server: ${url}")
        }
        sleep(Duration.millisecond * 50)
        attempt += 1
    }
    throw Exception("failed to connect test server: ${url}")
}

func choosePort(offset: Int64): UInt16 {
    let nowMs = DateTime.now().toUnixTimeStamp().toMilliseconds()
    let raw = 45000 + ((nowMs + offset) % 7000)
    UInt16(raw)
}
