package ignite.tests

import ignite.*
import ignite.client.*
import ignite.native_h2.*
import std.collection.ArrayList
import std.net.{IPSocketAddress, TcpServerSocket}
import std.sync.{AtomicBool, Mutex}

let NATIVE_H2_REST_CLIENT_BACKEND = "ignite-native-h2-client"

class NativeH2RestClientCounter {
    let mtx = Mutex()
    var value: Int64 = 0

    func next(): Int64 {
        var current: Int64 = 0
        synchronized(mtx) {
            value += 1
            current = value
        }
        current
    }

    func current(): Int64 {
        var currentValue: Int64 = 0
        synchronized(mtx) {
            currentValue = value
        }
        currentValue
    }
}

@Test
public class NativeH2RestClientTestSuite {
    @TestCase
    public func testExplicitBackendCarriesRequestAndObserveSemantics(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let ready = AtomicBool(false)
        let app = nativeH2RestClientApp(ready)
        app.patch("/h2-client", { ctx =>
            let marker = ctx.header("x-h2-client") ?? "missing"
            let _ = ctx.status(202).sendString(marker + ":" + ctx.bodyString())
        })
        let serverFuture = spawn { app.listen("127.0.0.1", port) }
        let client = nativeH2RestClient()
        try {
            waitForNativeH2RestClientReady(ready)
            let response = client.request()
                .method("PATCH")
                .url("http://127.0.0.1:${port}/h2-client")
                .header("x-h2-client", "yes")
                .body("payload")
                .send()
            @Assert(response.status, UInt16(202))
            @Assert(response.body(), "yes:payload")
            @Assert(nativeH2RestHeader(response, "x-ignite-observe-backend-id"), NATIVE_H2_REST_CLIENT_BACKEND)
            @Assert(nativeH2RestHeader(response, "x-ignite-observe-public-path"), "experimental-only")
        } finally {
            client.close()
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }

    @TestCase
    public func testConsumedResponsesReuseSameOriginConnection(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let ready = AtomicBool(false)
        let app = nativeH2RestClientApp(ready)
        app.get("/h2-pool", { ctx =>
            let _ = ctx.setHeader("x-h2-peer", ctx.ip).sendString("pool-ok")
        })
        let serverFuture = spawn { app.listen("127.0.0.1", port) }
        let client = nativeH2RestClient()
        try {
            waitForNativeH2RestClientReady(ready)
            let url = "http://127.0.0.1:${port}/h2-pool"
            let first = client.get(url)
            let firstPeer = nativeH2RestHeader(first, "x-h2-peer")
            @Assert(first.body(), "pool-ok")
            let second = client.get(url)
            let secondPeer = nativeH2RestHeader(second, "x-h2-peer")
            @Assert(second.body(), "pool-ok")
            @Assert(firstPeer == "missing", false)
            @Assert(secondPeer, firstPeer)
        } finally {
            client.close()
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }

    @TestCase
    public func testRetryableStatusUsesNextStreamOnReusableConnection(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let ready = AtomicBool(false)
        let counter = NativeH2RestClientCounter()
        let app = nativeH2RestClientApp(ready)
        app.get("/h2-retry", { ctx =>
            if (counter.next() == 1) {
                let _ = ctx.status(503).sendString("retry")
            } else {
                let _ = ctx.setHeader("x-h2-peer", ctx.ip).sendString("recovered")
            }
        })
        let serverFuture = spawn { app.listen("127.0.0.1", port) }
        let retryStatusCodes = ArrayList<Int64>()
        retryStatusCodes.add(503)
        let client = nativeH2RestClient()
            .useRetry(ClientRetryConfig(
                enabled: true,
                maxAttempts: 2,
                baseDelayMs: 0,
                maxDelayMs: 0,
                jitterMs: 0,
                retryStatusCodes: retryStatusCodes
            ))
        try {
            waitForNativeH2RestClientReady(ready)
            let response = client.get("http://127.0.0.1:${port}/h2-retry")
            @Assert(response.status, UInt16(200))
            @Assert(response.body(), "recovered")
            @Assert(nativeH2RestHeader(response, "x-ignite-observe-retry-count"), "1")
            @Assert(counter.current(), Int64(2))
        } finally {
            client.close()
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }

    @TestCase
    public func testReadTimeoutRetiresConnectionAndPublishesError(): Unit {
        let port = reserveServerEngineAbstractionLoopbackPort()
        let ready = AtomicBool(false)
        let app = nativeH2RestClientApp(ready)
        app.get("/h2-slow", { ctx =>
            sleep(Duration.millisecond * 250)
            let _ = ctx.sendString("late")
        })
        app.get("/h2-after-timeout", { ctx =>
            let _ = ctx.sendString("alive")
        })
        let serverFuture = spawn { app.listen("127.0.0.1", port) }
        let shortClient = RestClient(
            readTimeout: Duration.millisecond * 60,
            writeTimeout: Duration.second,
            poolSize: 1
        )
            .allowExperimentalTransport()
            .preferTransportBackend(NATIVE_H2_REST_CLIENT_BACKEND)
        let followUp = nativeH2RestClient()
        try {
            waitForNativeH2RestClientReady(ready)
            var message = ""
            try {
                let _ = shortClient.get("http://127.0.0.1:${port}/h2-slow")
            } catch (e: Exception) {
                message = e.message
            }
            @Assert(message.contains("native H2 network read timeout"), true)
            match (shortClient.lastClientObserveSnapshot()) {
                case Some(snapshot) =>
                    @Assert(snapshot.errorClass, "TIMEOUT")
                    @Assert(snapshot.phase, "read")
                case None => @Fail("expected Native H2 timeout observe snapshot")
            }
            let response = followUp.get("http://127.0.0.1:${port}/h2-after-timeout")
            @Assert(response.body(), "alive")
        } finally {
            shortClient.close()
            followUp.close()
            shutdownServerEngineAbstractionApp(app, serverFuture)
        }
    }

    @TestCase
    public func testPublicBatchMultiplexesAndReusesOneAcceptedConnection(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("Native H2 RestClient batch test could not reserve a port")
        let tracker = NativeH2RestBatchTracker()
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                serveNativeH2Connection(
                    accepted,
                    { request =>
                        tracker.enter(request.streamId)
                        try {
                            let marker = nativeH2RestBatchRequestHeader(request, "x-batch-id")
                            if (marker == "slow") {
                                sleep(Duration.millisecond * 120)
                            } else {
                                sleep(Duration.millisecond * 20)
                            }
                            let cookie = nativeH2RestBatchRequestHeader(request, "cookie")
                            let headers = ArrayList<NativeH2Header>()
                            headers.add(NativeH2Header("x-batch-stream", request.streamId.toString()))
                            headers.add(NativeH2Header(
                                "x-batch-default",
                                nativeH2RestBatchRequestHeader(request, "x-batch-default")
                            ))
                            if (marker == "slow") {
                                headers.add(NativeH2Header(
                                    "set-cookie", "ignite-batch=ready; Path=/"
                                ))
                            }
                            NativeH2SingleStreamResponse(
                                status: 200,
                                headers: headers.toArray(),
                                body: (marker + "|" + cookie).toArray()
                            )
                        } finally {
                            tracker.leave()
                        }
                    },
                    maxCompletedStreams: 6
                )
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let base = "http://127.0.0.1:${port}"
        let client = nativeH2RestClient()
            .baseUrl(base)
            .useCookies()
            .defaultHeader("x-batch-default", "present")
        let responseHooks = NativeH2RestClientCounter()
        client.onResponse({ _ =>
            let _ = responseHooks.next()
        })
        try {
            let first = client.sendNativeH2Batch([
                NativeH2BatchRequest("GET", "/batch").header("x-batch-id", "slow"),
                NativeH2BatchRequest("GET", base + "/batch").header("x-batch-id", "fast-1"),
                NativeH2BatchRequest("GET", "/batch").header("x-batch-id", "fast-2"),
                NativeH2BatchRequest("GET", "/batch").header("x-batch-id", "fast-3")
            ])
            @Assert(first.size, 4)
            @Assert(first[0].body(), "slow|")
            @Assert(first[1].body(), "fast-1|")
            @Assert(first[2].body(), "fast-2|")
            @Assert(first[3].body(), "fast-3|")
            for (response in first) {
                @Assert(response.header("x-batch-default") ?? "", "present")
            }
            @Assert(nativeH2RestHeader(first[0], "x-batch-stream"), "1")
            @Assert(nativeH2RestHeader(first[1], "x-batch-stream"), "3")
            @Assert(nativeH2RestHeader(first[2], "x-batch-stream"), "5")
            @Assert(nativeH2RestHeader(first[3], "x-batch-stream"), "7")

            let second = client.sendNativeH2Batch([
                NativeH2BatchRequest("GET", "/batch")
                    .header("x-batch-id", "after-cookie-1"),
                NativeH2BatchRequest("GET", "/batch")
                    .header("x-batch-id", "after-cookie-2")
            ])
            @Assert(second.size, 2)
            @Assert(second[0].body(), "after-cookie-1|ignite-batch=ready")
            @Assert(second[1].body(), "after-cookie-2|ignite-batch=ready")
            @Assert(nativeH2RestHeader(second[0], "x-batch-stream"), "9")
            @Assert(nativeH2RestHeader(second[1], "x-batch-stream"), "11")
            let _ = serverFuture.get(Duration.second * 5)
            @Assert(tracker.maxConcurrent() >= 2, true)
            @Assert(tracker.seenStreams(), Int64(6))
            @Assert(responseHooks.current(), Int64(6))
        } finally {
            client.close()
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testPublicBatchAdmissionFailsClosedBeforeNetworkUse(): Unit {
        let disabled = RestClient(
            readTimeout: Duration.second,
            writeTimeout: Duration.second,
            poolSize: 1
        )
            .preferTransportBackend(NATIVE_H2_REST_CLIENT_BACKEND)
        let wrongBackend = RestClient(
            readTimeout: Duration.second,
            writeTimeout: Duration.second,
            poolSize: 1
        )
            .allowExperimentalTransport()
        let requestHook = nativeH2RestClient().onRequest({ _ => })
        let observeHook = nativeH2RestClient().onObserve({ _ => })
        let touchpointHook = nativeH2RestClient().onTransportTouchpoint({ _ => })
        let errorHooks = NativeH2RestClientCounter()
        let client = nativeH2RestClient().onError({ _ =>
            let _ = errorHooks.next()
        })
        try {
            assertNativeH2RestBatchRejected(
                disabled,
                [NativeH2BatchRequest("GET", "http://127.0.0.1:1/disabled")],
                "allowExperimentalTransport"
            )
            assertNativeH2RestBatchRejected(
                wrongBackend,
                [NativeH2BatchRequest("GET", "http://127.0.0.1:1/backend")],
                "requires preferTransportBackend"
            )
            assertNativeH2RestBatchRejected(
                requestHook,
                [NativeH2BatchRequest("GET", "http://127.0.0.1:1/request-hook")],
                "does not yet support request, observe, or transport touchpoint hooks"
            )
            assertNativeH2RestBatchRejected(
                observeHook,
                [NativeH2BatchRequest("GET", "http://127.0.0.1:1/observe-hook")],
                "does not yet support request, observe, or transport touchpoint hooks"
            )
            assertNativeH2RestBatchRejected(
                touchpointHook,
                [NativeH2BatchRequest("GET", "http://127.0.0.1:1/touchpoint-hook")],
                "does not yet support request, observe, or transport touchpoint hooks"
            )
            assertNativeH2RestBatchRejected(client, [], "cannot be empty")

            let oversized = ArrayList<NativeH2BatchRequest>()
            for (i in 0..33) {
                oversized.add(
                    NativeH2BatchRequest("GET", "http://127.0.0.1:1/${i}")
                )
            }
            assertNativeH2RestBatchRejected(
                client, oversized.toArray(), "exceeds 32 requests"
            )
            assertNativeH2RestBatchRejected(
                client,
                [
                    NativeH2BatchRequest("GET", "http://127.0.0.1:1/a"),
                    NativeH2BatchRequest("GET", "http://127.0.0.1:2/b")
                ],
                "requires one resolved origin"
            )
            assertNativeH2RestBatchRejected(
                client,
                [NativeH2BatchRequest("GET", "https://127.0.0.1:1/tls")],
                "requires cleartext http:// prior knowledge"
            )
            @Assert(errorHooks.current(), Int64(4))
        } finally {
            disabled.close()
            wrongBackend.close()
            requestHook.close()
            observeHook.close()
            touchpointHook.close()
            client.close()
        }
    }

    @TestCase
    public func testPublicSessionOverlapsIndependentBodiesAndReusesConnection(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("Native H2 session test could not reserve a port")
        let tracker = NativeH2RestBatchTracker()
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                serveNativeH2Connection(
                    accepted,
                    { request =>
                        tracker.enter(request.streamId)
                        try {
                            let marker = nativeH2RestBatchRequestHeader(request, "x-session-id")
                            if (marker == "slow") {
                                sleep(Duration.millisecond * 80)
                            } else {
                                sleep(Duration.millisecond * 10)
                            }
                            let headers = [
                                NativeH2Header("x-session-stream", request.streamId.toString())
                            ]
                            let body = if (marker == "slow") {
                                Array<UInt8>(65535, repeat: UInt8(0x73))
                            } else {
                                marker.toArray()
                            }
                            NativeH2SingleStreamResponse(
                                status: 200,
                                headers: headers,
                                body: body
                            )
                        } finally {
                            tracker.leave()
                        }
                    },
                    maxCompletedStreams: 3
                )
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let base = "http://127.0.0.1:${port}"
        let client = nativeH2RestClient().baseUrl(base)
        let session = client.openNativeH2Session(base, maxConcurrentStreams: 4)
        try {
            let slowFuture = spawn {
                session.send(
                    NativeH2BatchRequest("GET", "/mux")
                        .header("x-session-id", "slow")
                )
            }
            waitForNativeH2RestStreams(tracker, 1)
            let fastFuture = spawn {
                session.send(
                    NativeH2BatchRequest("GET", "/mux")
                        .header("x-session-id", "fast")
                )
            }

            let fast = fastFuture.get(Duration.second * 5)
            @Assert(fast.body(), "fast")
            @Assert(nativeH2RestHeader(fast, "x-session-stream"), "3")

            let slow = slowFuture.get(Duration.second * 5)
            @Assert(nativeH2RestHeader(slow, "x-session-stream"), "1")
            @Assert(slow.bodyBytes().size, Int64(65535))
            @Assert(session.activeStreams(), Int64(0))
            session.close()

            let reused = client.openNativeH2Session(base, maxConcurrentStreams: 2)
            try {
                let response = reused.send(
                    NativeH2BatchRequest("GET", "/mux")
                        .header("x-session-id", "reused")
                )
                @Assert(response.body(), "reused")
                @Assert(nativeH2RestHeader(response, "x-session-stream"), "5")
            } finally {
                reused.close()
            }
            let _ = serverFuture.get(Duration.second * 5)
            @Assert(tracker.maxConcurrent() >= 2, true)
            @Assert(tracker.seenStreams(), Int64(3))
        } finally {
            session.close()
            client.close()
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testPublicSessionUploadsBufferedBodiesConcurrentlyAndReusesConnection(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("Native H2 session upload test could not reserve a port")
        let tracker = NativeH2RestBatchTracker()
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                serveNativeH2Connection(
                    accepted,
                    { request =>
                        tracker.enter(request.streamId)
                        try {
                            let marker = nativeH2RestBatchRequestHeader(
                                request, "x-upload-id"
                            )
                            if (marker == "large") {
                                @Assert(request.body.size, Int64(70000))
                                @Assert(request.body[0], UInt8(0x75))
                                sleep(Duration.millisecond * 80)
                            } else {
                                @Assert(String.fromUtf8(request.body), marker)
                                sleep(Duration.millisecond * 10)
                            }
                            @Assert(
                                nativeH2RestBatchRequestHeader(request, "content-length"),
                                request.body.size.toString()
                            )
                            NativeH2SingleStreamResponse(
                                status: 201,
                                headers: [NativeH2Header(
                                    "x-upload-stream", request.streamId.toString()
                                )],
                                body: (marker + ":" + request.body.size.toString()).toArray()
                            )
                        } finally {
                            tracker.leave()
                        }
                    },
                    maxCompletedStreams: 3
                )
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let base = "http://127.0.0.1:${port}"
        let client = nativeH2RestClient().baseUrl(base)
        let session = client.openNativeH2Session(base, maxConcurrentStreams: 4)
        try {
            let largeFuture = spawn {
                session.send(
                    NativeH2BatchRequest("POST", "/upload")
                        .header("x-upload-id", "large")
                        .bodyBytes(Array<UInt8>(70000, repeat: UInt8(0x75)))
                )
            }
            waitForNativeH2SessionActive(session, 1)
            let smallFuture = spawn {
                session.send(
                    NativeH2BatchRequest("POST", "/upload")
                        .header("x-upload-id", "small")
                        .bodyString("small")
                )
            }

            let small = smallFuture.get(Duration.second * 5)
            @Assert(small.status, UInt16(201))
            @Assert(small.body(), "small:5")
            @Assert(nativeH2RestHeader(small, "x-upload-stream"), "3")

            let large = largeFuture.get(Duration.second * 5)
            @Assert(large.status, UInt16(201))
            @Assert(large.body(), "large:70000")
            @Assert(nativeH2RestHeader(large, "x-upload-stream"), "1")
            @Assert(session.activeStreams(), Int64(0))
            session.close()

            let reused = client.openNativeH2Session(base, maxConcurrentStreams: 2)
            try {
                let response = reused.send(
                    NativeH2BatchRequest("POST", "/upload")
                        .header("x-upload-id", "reused")
                        .bodyString("reused")
                )
                @Assert(response.body(), "reused:6")
                @Assert(nativeH2RestHeader(response, "x-upload-stream"), "5")
            } finally {
                reused.close()
            }
            let _ = serverFuture.get(Duration.second * 5)
            @Assert(tracker.maxConcurrent() >= 2, true)
            @Assert(tracker.seenStreams(), Int64(3))
        } finally {
            session.close()
            client.close()
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testPublicSessionCancelPreservesSiblingAndRetiresConnection(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("Native H2 cancellation test could not reserve a port")
        let accepts = NativeH2RestClientCounter()
        let serverFuture = spawn {
            let first = listener.accept()
            let _ = accepts.next()
            try {
                try {
                    serveNativeH2Connection(
                        first,
                        { request =>
                            let marker = nativeH2RestBatchRequestHeader(
                                request, "x-session-id"
                            )
                            if (marker == "sibling") {
                                sleep(Duration.millisecond * 80)
                            }
                            NativeH2SingleStreamResponse(
                                status: 200,
                                headers: [NativeH2Header(
                                    "x-session-stream", request.streamId.toString()
                                )],
                                body: if (marker == "cancel") {
                                    Array<UInt8>(70000, repeat: UInt8(0x63))
                                } else {
                                    marker.toArray()
                                }
                            )
                        },
                        maxCompletedStreams: 2
                    )
                } catch (_: Exception) {}
            } finally {
                try { first.close() } catch (_: Exception) {}
            }

            let second = listener.accept()
            let _ = accepts.next()
            try {
                try {
                    serveNativeH2Connection(
                        second,
                        { request =>
                            NativeH2SingleStreamResponse(
                                status: 200,
                                headers: [NativeH2Header(
                                    "x-session-stream", request.streamId.toString()
                                )],
                                body: "fresh".toArray()
                            )
                        },
                        maxCompletedStreams: 1
                    )
                } catch (_: Exception) {}
            } finally {
                try { second.close() } catch (_: Exception) {}
            }
        }

        let base = "http://127.0.0.1:${port}"
        let client = nativeH2RestClient().baseUrl(base)
        let session = client.openNativeH2Session(base, maxConcurrentStreams: 4)
        try {
            let cancelFuture = spawn {
                session.send(
                    NativeH2BatchRequest("GET", "/cancel")
                        .header("x-session-id", "cancel")
                )
            }
            sleep(Duration.millisecond * 20)
            let siblingFuture = spawn {
                session.send(
                    NativeH2BatchRequest("GET", "/sibling")
                        .header("x-session-id", "sibling")
                )
            }
            waitForNativeH2SessionActive(session, 2)
            let cancelled = cancelFuture.get(Duration.second * 5)
            @Assert(nativeH2RestHeader(cancelled, "x-session-stream"), "1")
            cancelled.close()

            let sibling = siblingFuture.get(Duration.second * 5)
            @Assert(sibling.body(), "sibling")
            @Assert(nativeH2RestHeader(sibling, "x-session-stream"), "3")
            session.close()

            let freshSession = client.openNativeH2Session(base)
            @Assert(accepts.current(), Int64(2))
            freshSession.close()
            client.close()
            let _ = serverFuture.get(Duration.second * 5)
            @Assert(accepts.current(), Int64(2))
        } finally {
            session.close()
            client.close()
            try { listener.close() } catch (_: Exception) {}
        }
    }

    @TestCase
    public func testRestClientCloseSettlesForgottenNativeH2Session(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("Native H2 session ownership test could not reserve a port")
        let connectionClosed = AtomicBool(false)
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                try {
                    serveNativeH2Connection(
                        accepted,
                        { _ => NativeH2SingleStreamResponse(body: "unused".toArray()) }
                    )
                } catch (_: Exception) {}
            } finally {
                connectionClosed.store(true)
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let base = "http://127.0.0.1:${port}"
        let client = nativeH2RestClient().baseUrl(base)
        let session = client.openNativeH2Session(base)
        try {
            @Assert(session.activeStreams(), Int64(0))
            client.close()
            let _ = serverFuture.get(Duration.second * 5)
            @Assert(connectionClosed.load(), true)
            session.close()
        } finally {
            client.close()
            try { listener.close() } catch (_: Exception) {}
        }
    }

    func nativeH2RestClient(): RestClient {
        RestClient(
            readTimeout: Duration.second * 2,
            writeTimeout: Duration.second * 2,
            poolSize: 1
        )
            .allowExperimentalTransport()
            .preferTransportBackend(NATIVE_H2_REST_CLIENT_BACKEND)
    }

    func nativeH2RestClientApp(ready: AtomicBool): App {
        let app = App(config: Config(enableNetworkChangeNotice: false))
        useExperimentalNativeH2ServerEngine(app)
        app.onStartupObserve({ event =>
            if (event.phase == "ready") {
                ready.store(true)
            }
        })
        app
    }

    func waitForNativeH2RestClientReady(ready: AtomicBool): Unit {
        var attempts: Int64 = 0
        while (!ready.load() && attempts < 400) {
            sleep(Duration.millisecond * 5)
            attempts += 1
        }
        if (!ready.load()) {
            throw Exception("Native H2 RestClient fixture did not become ready")
        }
    }

    func waitForNativeH2RestStreams(
        tracker: NativeH2RestBatchTracker,
        expected: Int64
    ): Unit {
        var attempts: Int64 = 0
        while (tracker.seenStreams() < expected && attempts < 400) {
            sleep(Duration.millisecond * 5)
            attempts += 1
        }
        if (tracker.seenStreams() < expected) {
            throw Exception("Native H2 session fixture did not observe the expected stream")
        }
    }

    func waitForNativeH2SessionActive(
        session: NativeH2Session,
        expected: Int64
    ): Unit {
        var attempts: Int64 = 0
        while (session.activeStreams() < expected && attempts < 400) {
            sleep(Duration.millisecond * 5)
            attempts += 1
        }
        if (session.activeStreams() < expected) {
            throw Exception("Native H2 session did not reserve the expected streams")
        }
    }

    func nativeH2RestHeader(response: ClientResponse, name: String): String {
        response.header(name) ?? "missing"
    }
}

class NativeH2RestBatchTracker {
    let mtx = Mutex()
    var active: Int64 = 0
    var peak: Int64 = 0
    var streams: Int64 = 0

    func enter(streamId: Int64): Unit {
        let _ = streamId
        synchronized(mtx) {
            active += 1
            streams += 1
            if (active > peak) {
                peak = active
            }
        }
    }

    func leave(): Unit {
        synchronized(mtx) {
            active -= 1
        }
    }

    func maxConcurrent(): Int64 {
        var value: Int64 = 0
        synchronized(mtx) { value = peak }
        value
    }

    func seenStreams(): Int64 {
        var value: Int64 = 0
        synchronized(mtx) { value = streams }
        value
    }
}

func nativeH2RestBatchRequestHeader(
    request: NativeH2SingleStreamRequest,
    name: String
): String {
    let normalized = name.trimAscii().toAsciiLower()
    for (header in request.headers) {
        if (header.name == normalized) {
            return header.value
        }
    }
    ""
}

func assertNativeH2RestBatchRejected(
    client: RestClient,
    requests: Array<NativeH2BatchRequest>,
    expected: String
): Unit {
    var message = ""
    try {
        let _ = client.sendNativeH2Batch(requests)
    } catch (e: Exception) {
        message = e.message
    }
    @Assert(message.contains(expected), true)
}
