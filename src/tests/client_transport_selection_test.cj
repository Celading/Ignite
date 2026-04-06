package ignite.tests

import ignite.*
import ignite.client.*
import std.collection.ArrayList
import std.time.DateTime

@Test
public class ClientTransportSelectionTestSuite {
    @TestCase
    public func testSuccessfulResponseIncludesTransportSelectionObserveHeaders(): Unit {
        let app = App(config: Config())
        app.get("/transport-selection", { ctx =>
            ctx.sendString("selection-ok")
        })

        let port = choosePort(913)
        let url = "http://127.0.0.1:${port}/transport-selection"
        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }

        let probeClient = RestClient(
            readTimeout: Duration.second * 1,
            writeTimeout: Duration.second * 1,
            poolSize: 1
        )
        let backendIds = ArrayList<String>()
        let providerIds = ArrayList<String>()
        let publicPaths = ArrayList<String>()
        let riskLevels = ArrayList<String>()
        let client = RestClient(
            readTimeout: Duration.second * 1,
            writeTimeout: Duration.second * 1,
            poolSize: 1
        )
            .onResponse({ resp =>
                backendIds.add(readHeader(resp, "x-ignite-observe-backend-id"))
                providerIds.add(readHeader(resp, "x-ignite-observe-provider-id"))
                publicPaths.add(readHeader(resp, "x-ignite-observe-public-path"))
                riskLevels.add(readHeader(resp, "x-ignite-observe-risk-level"))
            })

        try {
            waitForReady(probeClient, url)
            let resp = client.request()
                .method("GET")
                .url(url)
                .send()
            @Assert(resp.status, 200)
            @Assert(resp.body(), "selection-ok")
            @Assert(backendIds.size, 1)
            @Assert(backendIds[0], "stdx-http-client")
            @Assert(providerIds.size, 1)
            @Assert(providerIds[0], "-")
            @Assert(publicPaths.size, 1)
            @Assert(publicPaths[0], "stable-default")
            @Assert(riskLevels.size, 1)
            @Assert(riskLevels[0], "low")
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

    func readHeader(resp: ClientResponse, name: String): String {
        if (let Some(value) <- resp.header(name)) {
            return value
        }
        "missing"
    }

    func waitForReady(client: RestClient, url: String): Unit {
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
        let raw = 52000 + ((nowMs + offset) % 4000)
        UInt16(raw)
    }
}
