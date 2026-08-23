package ignite

import std.collection.ArrayList
import std.net.{
    IPSocketAddress,
    SocketException,
    SocketTimeoutException,
    TcpServerSocket,
    TcpSocket
}

@Test
public class SocketServerEngineShellInternalTestSuite {
    @TestCase
    public func testNativeQueryValuesMatchStdxPercentDecodingContract(): Unit {
        @Assert(
            socketServerEngineShellReadQueryValue(
                "path=%2FMedia%2F%E4%B8%AD%E6%96%87+Name&literal=%252F&plus=%2B",
                "path"
            ) ?? "",
            "/Media/中文 Name"
        )
        @Assert(
            socketServerEngineShellReadQueryValue("literal=%252F", "literal") ?? "",
            "%2F"
        )
        @Assert(
            socketServerEngineShellReadQueryValue("plus=%2B", "plus") ?? "",
            "+"
        )
        @Assert(
            socketServerEngineShellReadQueryValue("na%6De=value", "name") ?? "",
            "value"
        )
        @Assert(
            socketServerEngineShellReadQueryValue("bad=%ZZ%", "bad") ?? "",
            "%ZZ%"
        )
    }

    @TestCase
    public func testNativeH1DispatchExposesDecodedQueryToCtx(): Unit {
        let fixture = SocketServerEngineShellInternalFixture(Duration.second * 2)
        fixture.app.get("/query", { ctx =>
            let _ = ctx.sendString(
                (ctx.queryDefault("path", "missing")) + "|" +
                (ctx.queryDefault("plus", "missing"))
            )
        })
        fixture.start()
        let client = fixture.connect()
        try {
            client.readTimeout = Some(Duration.second)
            client.write(
                (
                    "GET /query?path=%2FMedia%2F%E4%B8%AD%E6%96%87+Name&plus=%2B HTTP/1.1\r\n" +
                    "Host: example.com\r\nConnection: close\r\n\r\n"
                ).toArray()
            )
            let response = readSocketServerEngineShellInternalUntil(
                client,
                "/Media/中文 Name|+"
            )
            @Assert(response.contains("HTTP/1.1 200 OK"), true)
            @Assert(response.contains("/Media/中文 Name|+"), true)
            fixture.awaitConnectionTask()
        } finally {
            fixture.closeClient(client)
            fixture.close()
        }
    }

    @TestCase
    public func testNativeH1PreservesRepeatedSetCookieValuesOnWire(): Unit {
        let fixture = SocketServerEngineShellInternalFixture(Duration.second * 2)
        fixture.app.get("/cookies", { ctx =>
            let _ = ctx
                .setCookie("first", "one", httpOnly: true)
                .setCookie("second", "two", secure: true)
                .sendString("ok")
        })
        fixture.start()
        let client = fixture.connect()
        try {
            client.readTimeout = Some(Duration.second)
            client.write(
                "GET /cookies HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n".toArray()
            )
            let response = readSocketServerEngineShellInternalUntil(client, "\r\n\r\nok")
            @Assert(response.contains("set-cookie: first=one; Path=/; HttpOnly"), true)
            @Assert(response.contains("set-cookie: second=two; Path=/; Secure"), true)
            @Assert(response.split("set-cookie: ").size, 3)
            fixture.awaitConnectionTask()
            assertSocketServerEngineShellInternalSettled(fixture.control, 1, 0)
        } finally {
            fixture.closeClient(client)
            fixture.close()
        }
    }

    @TestCase
    public func testNativeH1ChunkedBodyKeepsAliveAfterBoundedMetadata(): Unit {
        let fixture = SocketServerEngineShellInternalFixture(Duration.second * 2)
        fixture.app.post("/chunk", { ctx =>
            let _ = ctx.sendString(ctx.bodyString())
        })
        fixture.app.get("/next", { ctx =>
            let _ = ctx.sendString("next")
        })
        fixture.start()
        let client = fixture.connect()
        try {
            client.readTimeout = Some(Duration.second)
            client.write(
                (
                    "POST /chunk HTTP/1.1\r\nHost: example.com\r\n" +
                    "Transfer-Encoding: chunked\r\nConnection: keep-alive\r\n\r\n" +
                    "4\r\nWiki\r\n5\r\npedia\r\n0\r\nX-Trace: accepted\r\n\r\n"
                ).toArray()
            )
            let first = readSocketServerEngineShellInternalUntil(client, "\r\n\r\nWikipedia")
            @Assert(first.contains("HTTP/1.1 200 OK"), true)
            client.write(
                "GET /next HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n".toArray()
            )
            let second = readSocketServerEngineShellInternalUntil(client, "\r\n\r\nnext")
            @Assert(second.contains("HTTP/1.1 200 OK"), true)
            fixture.awaitConnectionTask()
            assertSocketServerEngineShellInternalSettled(fixture.control, 2, 0)
        } finally {
            fixture.closeClient(client)
            fixture.close()
        }
    }

    @TestCase
    public func testNativeH1RejectsOversizedChunkAndTrailerMetadata(): Unit {
        let oversizedChunkLine = ArrayList<UInt8>()
        appendSocketServerEngineShellInternalRepeatedByte(
            oversizedChunkLine,
            UInt8(0x61),
            SOCKET_SERVER_ENGINE_SHELL_CHUNK_SIZE_LINE_LIMIT + 1
        )
        appendSocketServerEngineShellInternalText(oversizedChunkLine, "\r\n")
        assertSocketServerEngineShellInternalRejectsChunkMetadata(
            oversizedChunkLine.toArray()
        )

        let oversizedTrailerLine = ArrayList<UInt8>()
        appendSocketServerEngineShellInternalText(oversizedTrailerLine, "0\r\nX:")
        appendSocketServerEngineShellInternalRepeatedByte(
            oversizedTrailerLine,
            UInt8(0x61),
            SOCKET_SERVER_ENGINE_SHELL_TRAILER_LINE_LIMIT
        )
        appendSocketServerEngineShellInternalText(oversizedTrailerLine, "\r\n\r\n")
        assertSocketServerEngineShellInternalRejectsChunkMetadata(
            oversizedTrailerLine.toArray()
        )

        let oversizedTrailerTotal = ArrayList<UInt8>()
        appendSocketServerEngineShellInternalText(oversizedTrailerTotal, "0\r\n")
        for (index in 0..3) {
            appendSocketServerEngineShellInternalText(
                oversizedTrailerTotal,
                "X-${index}:"
            )
            appendSocketServerEngineShellInternalRepeatedByte(
                oversizedTrailerTotal,
                UInt8(0x62),
                6000
            )
            appendSocketServerEngineShellInternalText(oversizedTrailerTotal, "\r\n")
        }
        appendSocketServerEngineShellInternalText(oversizedTrailerTotal, "\r\n")
        assertSocketServerEngineShellInternalRejectsChunkMetadata(
            oversizedTrailerTotal.toArray()
        )

        let tooManyTrailers = ArrayList<UInt8>()
        appendSocketServerEngineShellInternalText(tooManyTrailers, "0\r\n")
        var field: Int64 = 0
        while (field <= SOCKET_SERVER_ENGINE_SHELL_TRAILER_FIELD_LIMIT) {
            appendSocketServerEngineShellInternalText(
                tooManyTrailers,
                "X-${field}: value\r\n"
            )
            field += 1
        }
        appendSocketServerEngineShellInternalText(tooManyTrailers, "\r\n")
        assertSocketServerEngineShellInternalRejectsChunkMetadata(
            tooManyTrailers.toArray()
        )
    }

    @TestCase
    public func testExpectedConnectionEndClassifierIsTyped(): Unit {
        @Assert(
            socketServerEngineShellIsExpectedConnectionEnd(
                SocketTimeoutException("read data timeout")
            ),
            true
        )
        @Assert(
            socketServerEngineShellIsExpectedConnectionEnd(
                SocketException("Connection reset by peer")
            ),
            true
        )
        @Assert(
            socketServerEngineShellIsExpectedConnectionEnd(
                Exception("handler failed")
            ),
            false
        )
        var escaped = false
        try {
            containSocketServerEngineShellExpectedConnectionEnd(
                Exception("programming failure")
            )
        } catch (_: Exception) {
            escaped = true
        }
        @Assert(escaped, true)
    }

    @TestCase
    public func testRequestRejectionClassifierPreservesStatusTaxonomyAndInternalState(): Unit {
        @Assert(
            socketServerEngineShellHeadFailureRejectionKind(
                SocketHttp11HeadException(
                    SocketHttp11HeadErrorCode.MalformedHeader,
                    "malformed header"
                )
            ) ?? SocketServerEngineShellRequestRejectionKind.UriTooLong,
            SocketServerEngineShellRequestRejectionKind.BadRequest
        )
        @Assert(
            socketServerEngineShellHeadFailureRejectionKind(
                SocketHttp11HeadException(
                    SocketHttp11HeadErrorCode.UnsupportedVersion,
                    "unsupported version"
                )
            ) ?? SocketServerEngineShellRequestRejectionKind.BadRequest,
            SocketServerEngineShellRequestRejectionKind.HttpVersionNotSupported
        )
        @Assert(
            socketServerEngineShellHeadFailureRejectionKind(
                SocketHttp11HeadException(
                    SocketHttp11HeadErrorCode.RequestTargetTooLong,
                    "request target limit"
                )
            ) ?? SocketServerEngineShellRequestRejectionKind.BadRequest,
            SocketServerEngineShellRequestRejectionKind.UriTooLong
        )
        @Assert(
            socketServerEngineShellHeadFailureRejectionKind(
                SocketHttp11HeadException(
                    SocketHttp11HeadErrorCode.HeaderFieldsTooLarge,
                    "header field limit"
                )
            ) ?? SocketServerEngineShellRequestRejectionKind.BadRequest,
            SocketServerEngineShellRequestRejectionKind.HeaderFieldsTooLarge
        )
        @Assert(
            socketServerEngineShellHeadFailureRejectionKind(
                SocketHttp11HeadException(
                    SocketHttp11HeadErrorCode.LimitExceeded,
                    "legacy unclassified limit"
                )
            ) == None,
            true
        )
        @Assert(
            socketServerEngineShellSessionFailureRejectionKind(
                SocketHttp11SessionException(
                    SocketHttp11SessionErrorCode.InvalidContentLength,
                    "invalid content length"
                )
            ) ?? SocketServerEngineShellRequestRejectionKind.UriTooLong,
            SocketServerEngineShellRequestRejectionKind.BadRequest
        )
        @Assert(
            socketServerEngineShellSessionFailureRejectionKind(
                SocketHttp11SessionException(
                    SocketHttp11SessionErrorCode.InvalidState,
                    "invalid internal state"
                )
            ) == None,
            true
        )
    }

    @TestCase
    public func testFailedTurnSettlementDistinguishesKeepAliveWaitAndStartedRequest(): Unit {
        let keepAliveControl = SocketServerEngineShellRuntimeControl()
        keepAliveControl.connectionAccepted()
        keepAliveControl.keepAliveWaitStarted()
        settleSocketServerEngineShellFailedTurn(
            keepAliveControl,
            true,
            false
        )
        keepAliveControl.connectionClosed()
        assertSocketServerEngineShellInternalSettled(keepAliveControl, 0, 0)

        let requestControl = SocketServerEngineShellRuntimeControl()
        requestControl.connectionAccepted()
        requestControl.requestStarted()
        settleSocketServerEngineShellFailedTurn(
            requestControl,
            false,
            true
        )
        requestControl.connectionClosed()
        assertSocketServerEngineShellInternalSettled(requestControl, 0, 1)
    }

    @TestCase
    public func testKeepAliveHeaderTimeoutCompletesConnectionTaskAndSettlesCounters(): Unit {
        let fixture = SocketServerEngineShellInternalFixture(
            Duration.millisecond * 100
        )
        fixture.app.get("/ok", { ctx =>
            let _ = ctx.sendString("ok")
        })
        fixture.start()
        let client = fixture.connect()
        try {
            client.readTimeout = Some(Duration.second)
            client.write(
                "GET /ok HTTP/1.1\r\nHost: example.com\r\nConnection: keep-alive\r\n\r\n".toArray()
            )
            let response = readSocketServerEngineShellInternalUntil(
                client,
                "\r\n\r\nok"
            )
            @Assert(response.contains("HTTP/1.1 200 OK"), true)

            fixture.awaitConnectionTask()
            assertSocketServerEngineShellInternalSettled(fixture.control, 1, 0)
        } finally {
            fixture.closeClient(client)
            fixture.close()
        }
    }

    @TestCase
    public func testKeepAlivePeerAbortCompletesConnectionTaskAndSettlesCounters(): Unit {
        let fixture = SocketServerEngineShellInternalFixture(
            Duration.second * 2
        )
        fixture.app.get("/ok", { ctx =>
            let _ = ctx.sendString("ok")
        })
        fixture.start()
        let client = fixture.connect()
        try {
            client.readTimeout = Some(Duration.second)
            client.write(
                "GET /ok HTTP/1.1\r\nHost: example.com\r\nConnection: keep-alive\r\n\r\n".toArray()
            )
            let response = readSocketServerEngineShellInternalUntil(
                client,
                "\r\n\r\nok"
            )
            @Assert(response.contains("HTTP/1.1 200 OK"), true)

            client.linger = Duration.millisecond * 0
            client.close()
            fixture.awaitConnectionTask()
            assertSocketServerEngineShellInternalSettled(fixture.control, 1, 0)
        } finally {
            fixture.closeClient(client)
            fixture.close()
        }
    }
}

class SocketServerEngineShellInternalFixture {
    let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
    let option: ServerEngineListenOption
    let app = App(config: Config(enableNetworkChangeNotice: false))
    let control = SocketServerEngineShellRuntimeControl()
    var connectionTask: ?Future<Unit> = None

    init(readHeaderTimeout: Duration) {
        option = ServerEngineListenOption(
            "127.0.0.1",
            0,
            Duration.second,
            Duration.second,
            readHeaderTimeout,
            1024 * 1024,
            "",
            "",
            false
        )
    }

    func start(): Unit {
        listener.bind()
        connectionTask = Some(spawn {
            let accepted = listener.accept()
            control.connectionAccepted()
            serveSocketServerEngineShellAcceptedConnection(
                accepted,
                app,
                option,
                control
            )
        })
    }

    func connect(): TcpSocket {
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("socket server engine shell internal test has no loopback port")
        let client = TcpSocket("127.0.0.1", port)
        client.connect(timeout: Some(Duration.second))
        client
    }

    func awaitConnectionTask(): Unit {
        match (connectionTask) {
            case Some(task) => task.get(Duration.second * 3)
            case None => throw Exception("socket server engine shell internal task was not started")
        }
    }

    func closeClient(client: TcpSocket): Unit {
        if (!client.isClosed()) {
            try { client.close() } catch (_: Exception) {}
        }
    }

    func close(): Unit {
        if (!listener.isClosed()) {
            try { listener.close() } catch (_: Exception) {}
        }
    }
}

func readSocketServerEngineShellInternalUntil(
    socket: TcpSocket,
    target: String
): String {
    let out = ArrayList<UInt8>()
    let buf = Array<UInt8>(1024, repeat: 0)
    while (true) {
        let n = socket.read(buf)
        if (n <= 0) {
            break
        }
        var index: Int64 = 0
        while (index < n) {
            out.add(buf[index])
            index += 1
        }
        let text = String.fromUtf8(out.toArray())
        if (text.contains(target)) {
            return text
        }
    }
    String.fromUtf8(out.toArray())
}

func assertSocketServerEngineShellInternalSettled(
    control: SocketServerEngineShellRuntimeControl,
    completedRequests: Int64,
    rejectedRequests: Int64
): Unit {
    let snapshot = control.runtimeCounterSnapshot()
    @Assert(snapshot.activeConnections, Int64(0))
    @Assert(snapshot.activeKeepAliveConnections, Int64(0))
    @Assert(snapshot.inFlightRequests, Int64(0))
    @Assert(snapshot.completedRequests, completedRequests)
    @Assert(snapshot.rejectedRequests, rejectedRequests)
}

func assertSocketServerEngineShellInternalRejectsChunkMetadata(metadata: Array<UInt8>): Unit {
    let fixture = SocketServerEngineShellInternalFixture(Duration.second * 2)
    fixture.app.post("/chunk-limit", { ctx =>
        let _ = ctx.sendString(ctx.bodyString())
    })
    fixture.start()
    let client = fixture.connect()
    try {
        client.write(
            (
                "POST /chunk-limit HTTP/1.1\r\nHost: example.com\r\n" +
                "Transfer-Encoding: chunked\r\nConnection: close\r\n\r\n"
            ).toArray()
        )
        client.write(metadata)
        fixture.awaitConnectionTask()
        assertSocketServerEngineShellInternalSettled(fixture.control, 0, 1)
    } finally {
        fixture.closeClient(client)
        fixture.close()
    }
}

func appendSocketServerEngineShellInternalText(
    out: ArrayList<UInt8>,
    value: String
): Unit {
    for (byte in value.toArray()) {
        out.add(byte)
    }
}

func appendSocketServerEngineShellInternalRepeatedByte(
    out: ArrayList<UInt8>,
    value: UInt8,
    count: Int64
): Unit {
    var index: Int64 = 0
    while (index < count) {
        out.add(value)
        index += 1
    }
}
