import ignite.client.*
import ignite.api2
import std.collection.{ArrayList, HashMap}

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

func printObserve(label: String, resp: ClientResponse): Unit {
    let duration = resp.header("x-ignite-observe-duration-ms") ?? "-"
    let retryCount = resp.header("x-ignite-observe-retry-count") ?? "-"
    let errClass = resp.header("x-ignite-observe-error-class") ?? "-"
    let fields = resp.header("x-ignite-observe-fields") ?? "-"
    println("${label} observe => durationMs=${duration}, retryCount=${retryCount}, errorClass=${errClass}, fields=${fields}")
}

func printRecovery(label: String, resp: ClientResponse): Unit {
    let observe = resp.observeSnapshot()
    let touchpoint = resp.transportTouchpoint()
    let obsStr = match (observe) {
        case Some(s) => "outcome=${s.outcome},responseStatus=${s.responseStatus},backendId=${s.backendId}"
        case None => "no observeSnapshot"
    }
    let tpStr = match (touchpoint) {
        case Some(t) => "selectedBackend=${t.selectedBackend},reason=${t.selectedReason}"
        case None => "no transportTouchpoint"
    }
    println("${label} recovery => observe=[${obsStr}] touchpoint=[${tpStr}]")
}

func printRetainedRecovery(label: String, client: RestClient): Unit {
    let observe = client.lastClientObserveSnapshot()
    let touchpoint = client.lastClientTransportTouchpoint()
    let obsStr = match (observe) {
        case Some(s) => "outcome=${s.outcome},phase=${s.phase},backendId=${s.backendId}"
        case None => "no lastClientObserveSnapshot"
    }
    let tpStr = match (touchpoint) {
        case Some(t) => "selectedBackend=${t.selectedBackend},publicPath=${t.publicPath}"
        case None => "no lastClientTransportTouchpoint"
    }
    println("${label} retained => observe=[${obsStr}] touchpoint=[${tpStr}]")
}

main() {
    let client = RestClient(
            readTimeout: Duration.second * 15,
            writeTimeout: Duration.second * 15,
            poolSize: 10
        )
        .baseUrl("http://127.0.0.1:18080")
        .useCrypto(buildCryptoConfig())
        .useRetry(ClientRetryConfig(
            enabled: true,
            maxAttempts: 3,
            idempotentOnly: true,
            baseDelayMs: 20,
            maxDelayMs: 120,
            jitterMs: 0
        ))
        .onRequest({ req =>
            req.header("x-ignite-log-trace-id", "sample-trace-001")
        })
        .onError({ err =>
            println("[client:error-hook] ${err.message}")
        })

    let pingResp = client.get("/ping")
    println("GET /ping -> ${pingResp.status} ${pingResp.body()}")
    printObserve("GET /ping", pingResp)
    printRecovery("GET /ping", pingResp)
    printRetainedRecovery("GET /ping", client)

    let echoPayload = "{\"name\":\"ignite\",\"count\":2}"
    let echoResp = client.postJson("/echo-json", echoPayload)
    println("POST /echo-json -> ${echoResp.status} ${echoResp.body()}")
    printObserve("POST /echo-json", echoResp)
    printRecovery("POST /echo-json", echoResp)
    printRetainedRecovery("POST /echo-json", client)

    let securePayload = "{\"scope\":\"client-demo\",\"message\":\"hello secure\"}"
    let secureResp = client.postEncryptedJson(
        "/secure-echo",
        securePayload,
        aad: "route:/secure-echo"
    )
    println("POST /secure-echo -> ${secureResp.status} ${secureResp.body()}")
    printObserve("POST /secure-echo", secureResp)
    printRecovery("POST /secure-echo", secureResp)
    printRetainedRecovery("POST /secure-echo", client)

    let fields = ArrayList<(String, String)>()
    fields.add(("meta", "client-upload"))
    let files = ArrayList<MultipartFile>()
    files.add(
        MultipartFile("file", "demo.txt", "text/plain", "ignite-multipart-demo".toArray())
    )
    let uploadResp = client.postMultipart("/upload-multipart", fields, files)
    println("POST /upload-multipart -> ${uploadResp.status} ${uploadResp.body()}")
    printObserve("POST /upload-multipart", uploadResp)
    printRecovery("POST /upload-multipart", uploadResp)
    printRetainedRecovery("POST /upload-multipart", client)

    client.clearRecoverySnapshots()
    println("client retained recovery cleared for next probe wave")

    client.close()
}
