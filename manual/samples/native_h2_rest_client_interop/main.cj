import ignite.client.*
import std.collection.ArrayList
import std.env.getVariable

let H2_INTEROP_BACKEND = "ignite-native-h2-client"

main() {
    let port = getVariable("IGNITE_H2_INTEROP_PORT") ?? "18882"
    let baseUrl = "http://127.0.0.1:" + port
    let retryStatuses = ArrayList<Int64>()
    retryStatuses.add(503)
    let client = RestClient(
        readTimeout: Duration.second * 2,
        writeTimeout: Duration.second * 2,
        poolSize: 1
    )
        .allowExperimentalTransport()
        .preferTransportBackend(H2_INTEROP_BACKEND)
        .useRetry(ClientRetryConfig(
            enabled: true,
            maxAttempts: 2,
            baseDelayMs: 0,
            maxDelayMs: 0,
            jitterMs: 0,
            retryStatusCodes: retryStatuses
        ))

    try {
        let patch = client.request()
            .method("PATCH")
            .url(baseUrl + "/patch")
            .header("x-client-marker", "rest-client")
            .body("payload")
            .send()
        let patchSession = requireHeader(patch, "x-node-session")
        let patchBackend = requireHeader(patch, "x-ignite-observe-backend-id")
        requireEqual(patch.status.toString(), "202", "PATCH status")
        requireEqual(patch.body(), "node:payload", "PATCH body")
        requireEqual(patchBackend, H2_INTEROP_BACKEND, "selected backend")

        let retry = client.get(baseUrl + "/retry")
        let retrySession = requireHeader(retry, "x-node-session")
        let retryAttempts = requireHeader(retry, "x-ignite-observe-retry-count")
        requireEqual(retry.status.toString(), "200", "retry status")
        requireEqual(retry.body(), "recovered", "retry body")
        requireEqual(retrySession, patchSession, "retry connection reuse")
        requireEqual(retryAttempts, "1", "retry count")

        let cancelled = client.get(baseUrl + "/cancel")
        let cancelSession = requireHeader(cancelled, "x-node-session")
        let firstChunk = Array<UInt8>(5, repeat: 0)
        let firstCount = cancelled.bodyStream().read(firstChunk)
        requireEqual(String.fromUtf8(sliceBytes(firstChunk, firstCount)), "first", "cancel prefix")
        cancelled.close()

        let after = client.get(baseUrl + "/after")
        let afterSession = requireHeader(after, "x-node-session")
        requireEqual(after.body(), "fresh", "post-cancel body")
        if (afterSession == cancelSession) {
            throw Exception("post-cancel request reused the retired H2 connection")
        }

        println(
            "patch=202;patchSession=" + patchSession +
            ";retry=200;retrySession=" + retrySession +
            ";retryCount=" + retryAttempts +
            ";cancelSession=" + cancelSession +
            ";afterSession=" + afterSession +
            ";backend=" + patchBackend +
            ";result=accepted"
        )
    } finally {
        client.close()
    }
}

func requireHeader(response: ClientResponse, name: String): String {
    response.header(name) ?? throw Exception("missing response header: " + name)
}

func requireEqual(actual: String, expected: String, label: String): Unit {
    if (actual != expected) {
        throw Exception(label + " mismatch: expected=" + expected + ", actual=" + actual)
    }
}

func sliceBytes(input: Array<UInt8>, length: Int64): Array<UInt8> {
    let out = Array<UInt8>(length, repeat: 0)
    var i: Int64 = 0
    while (i < length) {
        out[i] = input[i]
        i += 1
    }
    out
}
