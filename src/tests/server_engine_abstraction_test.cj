package ignite.tests

import ignite.*
import std.collection.ArrayList
import std.env.{removeVariable, setVariable}
import std.io.InputStream
import std.net.{IPSocketAddress, TcpSocket}

@Test
public class ServerEngineAbstractionTestSuite {
    @TestCase
    public func testInjectedServerEngineReceivesListenAndShutdown(): Unit {
        let app = App(config: Config(enableTlsPrecheck: false))
        let engine = SpyServerEngine()
        app.serverEngine(engine)

        app.listen("127.0.0.1", 38117)
        app.shutdown()

        @Assert(engine.listenCalled, true)
        @Assert(engine.shutdownCalled, true)
        @Assert(engine.lastAddr, "127.0.0.1")
        @Assert(engine.lastPort, UInt16(38117))
        @Assert(engine.lastEnableTlsPrecheck, false)
        @Assert(engine.readyCalled, true)
        @Assert(engine.receivedApp, true)
        match (engine.lastTransportTouchpoint) {
            case Some(touchpoint) =>
                @Assert(touchpoint.selectedBackend, "stdx-http-server")
                @Assert(touchpoint.publicPath, "stable-default")
                @Assert(touchpoint.providerId, "-")
            case None => @Fail("expected server transport touchpoint")
        }
        match (app.lastServerTransportTouchpoint()) {
            case Some(touchpoint) =>
                @Assert(touchpoint.selectedBackend, "stdx-http-server")
                @Assert(touchpoint.publicPath, "stable-default")
                @Assert(touchpoint.providerId, "-")
            case None => @Fail("expected app transport touchpoint snapshot")
        }
    }

    @TestCase
    public func testInjectedServerEngineTracksLatestListenAddressAcrossCalls(): Unit {
        let app = App(config: Config(enableTlsPrecheck: false))
        let engine = SpyServerEngine()
        app.serverEngine(engine)

        app.listen("127.0.0.1", UInt16(38118))
        app.listen("0.0.0.0", UInt16(38119))

        @Assert(engine.listenCalled, true)
        @Assert(engine.lastAddr, "0.0.0.0")
        @Assert(engine.lastPort, UInt16(38119))
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "ready")
                @Assert(event.addr, "0.0.0.0")
                @Assert(event.port, UInt16(38119))
            case None => @Fail("expected latest startup observe event")
        }
    }

    @TestCase
    public func testInjectedServerEngineCanOverrideTransportTouchpointIdentity(): Unit {
        let app = App(config: Config(enableTlsPrecheck: false))
        let engine = TouchpointOverrideServerEngine()
        app.serverEngine(engine)

        app.listen("127.0.0.1", UInt16(38122))

        match (engine.lastTransportTouchpoint) {
            case Some(touchpoint) =>
                @Assert(touchpoint.selectedBackend, "ignite-custom-engine")
                @Assert(touchpoint.publicPath, "opt-in-engine-custom")
                @Assert(touchpoint.riskLevel, "experimental")
                @Assert(touchpoint.fallbackReason, "engine_identity_override")
            case None => @Fail("expected override transport touchpoint")
        }
        match (app.lastServerTransportTouchpoint()) {
            case Some(touchpoint) =>
                @Assert(touchpoint.selectedBackend, "ignite-custom-engine")
                @Assert(touchpoint.publicPath, "opt-in-engine-custom")
                @Assert(touchpoint.riskLevel, "experimental")
                @Assert(touchpoint.fallbackReason, "engine_identity_override")
            case None => @Fail("expected app override transport touchpoint snapshot")
        }
    }

    @TestCase
    public func testSocketServerEngineShellServesOneCleartextH1RequestAndStillAllowsLaterEngineSwap(): Unit {
        let app = App(config: Config(enableTlsPrecheck: false))
        app.serverEngine(SocketServerEngineShell())
        app.get("/shell-health", { ctx =>
            let _ = ctx
                .setHeader("x-shell", "1")
                .sendString("shell-ok")
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", UInt16(38123))
        }
        waitForShellReady(app, UInt16(38123))

        let responseText = runSocketServerEngineShellClient(
            "127.0.0.1",
            UInt16(38123),
            "GET /shell-health HTTP/1.1\r\nHost: example.com\r\n\r\n"
        )
        let _ = serverFuture.get(Duration.second * 5)

        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "ready")
                @Assert(event.addr, "127.0.0.1")
                @Assert(event.port, UInt16(38123))
                @Assert(event.scheme, "http")
                match (event.transportTouchpoint) {
                    case Some(touchpoint) =>
                        @Assert(touchpoint.selectedBackend, "ignite-socket-server-shell")
                        @Assert(touchpoint.publicPath, "opt-in-engine-shell")
                        @Assert(touchpoint.riskLevel, "experimental")
                        @Assert(touchpoint.fallbackReason, "cleartext_h1_first_runnable")
                    case None => @Fail("expected shell transport touchpoint")
                }
            case None => @Fail("expected shell startup observe event")
        }
        match (app.lastServerTransportTouchpoint()) {
            case Some(touchpoint) =>
                @Assert(touchpoint.selectedBackend, "ignite-socket-server-shell")
                @Assert(touchpoint.publicPath, "opt-in-engine-shell")
                @Assert(touchpoint.fallbackReason, "cleartext_h1_first_runnable")
            case None => @Fail("expected app shell transport touchpoint snapshot")
        }
        @Assert(contains(responseText, "HTTP/1.1 200 OK"), true)
        @Assert(contains(responseText, "content-type: text/plain; charset=utf-8"), true)
        @Assert(contains(responseText, "x-shell: 1"), true)
        @Assert(contains(responseText, "content-length: 8"), true)
        @Assert(contains(responseText, "connection: close"), true)
        @Assert(contains(responseText, "shell-ok"), true)

        let engine = SpyServerEngine()
        app.serverEngine(engine)
        app.listen("127.0.0.1", UInt16(38121))
        app.shutdown()

        @Assert(engine.listenCalled, true)
        @Assert(engine.shutdownCalled, true)
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "ready")
                @Assert(event.port, UInt16(38121))
            case None => @Fail("expected ready observe event after engine swap")
        }
    }

    @TestCase
    public func testSocketServerEngineShellCompletesContentLengthBodyStageBeforeDispatch(): Unit {
        let app = App(config: Config(enableTlsPrecheck: false))
        app.serverEngine(SocketServerEngineShell())
        app.post("/shell-body", { ctx =>
            let body = ctx.bodyString()
            let _ = ctx
                .setHeader("x-shell-body", "1")
                .sendString(body)
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", UInt16(38124))
        }
        waitForShellReady(app, UInt16(38124))

        let responseText = runSocketServerEngineShellClientWithSplitBody(
            "127.0.0.1",
            UInt16(38124),
            "POST /shell-body HTTP/1.1\r\nHost: example.com\r\nContent-Length: 3\r\n\r\n",
            "abc"
        )
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(contains(responseText, "HTTP/1.1 200 OK"), true)
        @Assert(contains(responseText, "x-shell-body: 1"), true)
        @Assert(contains(responseText, "content-length: 3"), true)
        @Assert(contains(responseText, "connection: close"), true)
        @Assert(contains(responseText, "\r\n\r\nabc"), true)
    }

    @TestCase
    public func testSocketServerEngineShellDecodesChunkedBodyStageBeforeDispatch(): Unit {
        let app = App(config: Config(enableTlsPrecheck: false))
        app.serverEngine(SocketServerEngineShell())
        app.post("/shell-chunked-body", { ctx =>
            let body = ctx.bodyString()
            let _ = ctx
                .setHeader("x-shell-chunked-body", "1")
                .sendString(body)
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", UInt16(38125))
        }
        waitForShellReady(app, UInt16(38125))

        let responseText = runSocketServerEngineShellClientWithSplitBody(
            "127.0.0.1",
            UInt16(38125),
            "POST /shell-chunked-body HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\n\r\n",
            "3\r\nabc\r\n2\r\nde\r\n0\r\n\r\n"
        )
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(contains(responseText, "HTTP/1.1 200 OK"), true)
        @Assert(contains(responseText, "x-shell-chunked-body: 1"), true)
        @Assert(contains(responseText, "content-length: 5"), true)
        @Assert(contains(responseText, "connection: close"), true)
        @Assert(contains(responseText, "\r\n\r\nabcde"), true)
    }

    @TestCase
    public func testSocketServerEngineShellConsumesChunkedRequestTrailersBeforeDispatch(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-chunked-trailers", { ctx =>
                let body = ctx.bodyString()
                let _ = ctx
                    .setHeader("x-shell-chunked-trailers", "1")
                    .sendString(body)
            })
            app.get("/shell-chunked-trailers", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-chunked-trailers", "1")
                    .sendString("second")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38143))
            }
            waitForShellReady(app, UInt16(38143))

            let firstResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38143),
                "POST /shell-chunked-trailers HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-trailer\r\n\r\n3\r\nabc\r\n2\r\nde\r\n0\r\nx-shell-trailer: seen\r\n\r\n"
            )
            @Assert(contains(firstResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(firstResponseText, "x-shell-chunked-trailers: 1"), true)
            @Assert(contains(firstResponseText, "content-length: 5"), true)
            @Assert(contains(firstResponseText, "\r\n\r\nabcde"), true)

            let secondResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38143),
                "GET /shell-chunked-trailers HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(secondResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(secondResponseText, "x-shell-chunked-trailers: 1"), true)
            @Assert(contains(secondResponseText, "\r\n\r\nsecond"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellKeepsAliveAfterChunkedRequestTrailers(): Unit {
        let app = App(config: Config(enableTlsPrecheck: false))
        app.serverEngine(SocketServerEngineShell())
        app.post("/shell-chunked-trailers-keepalive", { ctx =>
            let turn = ctx.queryFromUrl("turn") ?? ""
            let body = ctx.bodyString()
            let _ = ctx
                .setHeader("x-shell-chunked-trailers-keepalive", "1")
                .sendString("${turn}:${body}")
        })
        app.get("/shell-chunked-trailers-keepalive", { ctx =>
            let turn = ctx.queryFromUrl("turn") ?? ""
            let _ = ctx
                .setHeader("x-shell-chunked-trailers-keepalive", "1")
                .sendString("${turn}:done")
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", UInt16(38144))
        }
        waitForShellReady(app, UInt16(38144))

        let socket = TcpSocket(IPSocketAddress.parse("127.0.0.1:38144"))
        socket.connect()
        try {
            socket.write(
                "POST /shell-chunked-trailers-keepalive?turn=1 HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-trailer\r\nConnection: keep-alive\r\n\r\n".toArray()
            )
            sleep(Duration.millisecond * 50)
            socket.write("3\r\nabc\r\n2\r\nde\r\n0\r\nx-shell-trailer: seen\r\n\r\n".toArray())
            let firstResponse = readSocketServerEngineShellResponseFrame(socket)
            @Assert(contains(firstResponse, "HTTP/1.1 200 OK"), true)
            @Assert(contains(firstResponse, "x-shell-chunked-trailers-keepalive: 1"), true)
            @Assert(contains(firstResponse, "content-length: 7"), true)
            @Assert(contains(firstResponse, "\r\n\r\n1:abcde"), true)
            @Assert(contains(firstResponse, "connection: close"), false)

            socket.write(
                "GET /shell-chunked-trailers-keepalive?turn=2 HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n".toArray()
            )
            let secondResponse = readSocketServerEngineShellResponseWire(socket)
            @Assert(contains(secondResponse, "HTTP/1.1 200 OK"), true)
            @Assert(contains(secondResponse, "x-shell-chunked-trailers-keepalive: 1"), true)
            @Assert(contains(secondResponse, "\r\n\r\n2:done"), true)
            @Assert(contains(secondResponse, "connection: close"), true)
        } finally {
            if (!socket.isClosed()) {
                socket.close()
            }
        }

        let _ = serverFuture.get(Duration.second * 5)
    }

    @TestCase
    public func testSocketServerEngineShellContainsInvalidChunkedTrailerLine(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-invalid-chunked-trailer-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-invalid-chunked-trailer-containment", "1")
                    .sendString("unexpected-ok")
            })
            app.get("/shell-invalid-chunked-trailer-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-invalid-chunked-trailer-containment", "1")
                    .sendString("containment-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38145))
            }
            waitForShellReady(app, UInt16(38145))

            let firstResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38145),
                "POST /shell-invalid-chunked-trailer-containment HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-trailer\r\n\r\n3\r\nabc\r\n0\r\nx-shell-trailer seen\r\n\r\n"
            )
            @Assert(contains(firstResponseText, "HTTP/1.1"), false)
            @Assert(contains(firstResponseText, "unexpected-ok"), false)

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38145),
                "GET /shell-invalid-chunked-trailer-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-invalid-chunked-trailer-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 14"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "containment-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellContainsInvalidChunkedTrailerFieldName(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-invalid-chunked-trailer-field-name-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-invalid-chunked-trailer-field-name-containment", "1")
                    .sendString("unexpected-ok")
            })
            app.get("/shell-invalid-chunked-trailer-field-name-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-invalid-chunked-trailer-field-name-containment", "1")
                    .sendString("containment-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38146))
            }
            waitForShellReady(app, UInt16(38146))

            let firstResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38146),
                "POST /shell-invalid-chunked-trailer-field-name-containment HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-trailer\r\n\r\n3\r\nabc\r\n0\r\nx-shell-trailer seen: value\r\n\r\n"
            )
            @Assert(contains(firstResponseText, "HTTP/1.1"), false)
            @Assert(contains(firstResponseText, "unexpected-ok"), false)

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38146),
                "GET /shell-invalid-chunked-trailer-field-name-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-invalid-chunked-trailer-field-name-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 14"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "containment-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellKeepsAliveAfterChunkedRequestTrailerFieldNamePunctuation(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "1")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-chunked-trailer-field-name-punctuation-keepalive", { ctx =>
                let turn = ctx.queryFromUrl("turn") ?? ""
                let body = ctx.bodyString()
                let _ = ctx
                    .setHeader("x-shell-chunked-trailer-field-name-punctuation-keepalive", "1")
                    .sendString("${turn}:${body}")
            })
            app.get("/shell-chunked-trailer-field-name-punctuation-keepalive", { ctx =>
                let turn = ctx.queryFromUrl("turn") ?? ""
                let _ = ctx
                    .setHeader("x-shell-chunked-trailer-field-name-punctuation-keepalive", "1")
                    .sendString("${turn}:done")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38152))
            }
            waitForShellReady(app, UInt16(38152))

            let socket = TcpSocket(IPSocketAddress.parse("127.0.0.1:38152"))
            socket.connect()
            try {
                socket.write(
                    "POST /shell-chunked-trailer-field-name-punctuation-keepalive?turn=1 HTTP/1.1\r\nHost: example.com\r\nConnection: keep-alive\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-trailer^edge\r\n\r\n5\r\nabcde\r\n0\r\nx-shell-trailer^edge: seen\r\n\r\n".toArray()
                )
                let firstResponse = readSocketServerEngineShellResponseFrame(socket)
                @Assert(contains(firstResponse, "HTTP/1.1 200 OK"), true)
                @Assert(contains(firstResponse, "x-shell-chunked-trailer-field-name-punctuation-keepalive: 1"), true)
                @Assert(contains(firstResponse, "content-length: 7"), true)
                @Assert(contains(firstResponse, "\r\n\r\n1:abcde"), true)
                @Assert(contains(firstResponse, "connection: close"), false)

                socket.write(
                    "GET /shell-chunked-trailer-field-name-punctuation-keepalive?turn=2 HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n".toArray()
                )
                let secondResponse = readSocketServerEngineShellResponseWire(socket)
                @Assert(contains(secondResponse, "HTTP/1.1 200 OK"), true)
                @Assert(contains(secondResponse, "x-shell-chunked-trailer-field-name-punctuation-keepalive: 1"), true)
                @Assert(contains(secondResponse, "\r\n\r\n2:done"), true)
                @Assert(contains(secondResponse, "connection: close"), true)
            } finally {
                if (!socket.isClosed()) {
                    socket.close()
                }
            }

            let _ = serverFuture.get(Duration.second * 5)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellKeepsAliveAfterChunkedRequestMultipleTrailerLines(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "1")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-chunked-multi-trailer-lines-keepalive", { ctx =>
                let turn = ctx.queryFromUrl("turn") ?? ""
                let body = ctx.bodyString()
                let _ = ctx
                    .setHeader("x-shell-chunked-multi-trailer-lines-keepalive", "1")
                    .sendString("${turn}:${body}")
            })
            app.get("/shell-chunked-multi-trailer-lines-keepalive", { ctx =>
                let turn = ctx.queryFromUrl("turn") ?? ""
                let _ = ctx
                    .setHeader("x-shell-chunked-multi-trailer-lines-keepalive", "1")
                    .sendString("${turn}:done")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38153))
            }
            waitForShellReady(app, UInt16(38153))

            let socket = TcpSocket(IPSocketAddress.parse("127.0.0.1:38153"))
            socket.connect()
            try {
                socket.write(
                    "POST /shell-chunked-multi-trailer-lines-keepalive?turn=1 HTTP/1.1\r\nHost: example.com\r\nConnection: keep-alive\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-trailer, x-shell-trailer^edge\r\n\r\n5\r\nabcde\r\n0\r\nx-shell-trailer: seen\r\nx-shell-trailer^edge: again\r\n\r\n".toArray()
                )
                let firstResponse = readSocketServerEngineShellResponseFrame(socket)
                @Assert(contains(firstResponse, "HTTP/1.1 200 OK"), true)
                @Assert(contains(firstResponse, "x-shell-chunked-multi-trailer-lines-keepalive: 1"), true)
                @Assert(contains(firstResponse, "content-length: 7"), true)
                @Assert(contains(firstResponse, "\r\n\r\n1:abcde"), true)
                @Assert(contains(firstResponse, "connection: close"), false)

                socket.write(
                    "GET /shell-chunked-multi-trailer-lines-keepalive?turn=2 HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n".toArray()
                )
                let secondResponse = readSocketServerEngineShellResponseWire(socket)
                @Assert(contains(secondResponse, "HTTP/1.1 200 OK"), true)
                @Assert(contains(secondResponse, "x-shell-chunked-multi-trailer-lines-keepalive: 1"), true)
                @Assert(contains(secondResponse, "\r\n\r\n2:done"), true)
                @Assert(contains(secondResponse, "connection: close"), true)
            } finally {
                if (!socket.isClosed()) {
                    socket.close()
                }
            }

            let _ = serverFuture.get(Duration.second * 5)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellContainsLaterInvalidChunkedTrailerFieldName(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-later-invalid-chunked-trailer-field-name-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-later-invalid-chunked-trailer-field-name-containment", "1")
                    .sendString("unexpected-ok")
            })
            app.get("/shell-later-invalid-chunked-trailer-field-name-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-later-invalid-chunked-trailer-field-name-containment", "1")
                    .sendString("containment-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38154))
            }
            waitForShellReady(app, UInt16(38154))

            let firstResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38154),
                "POST /shell-later-invalid-chunked-trailer-field-name-containment HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-trailer\r\n\r\n3\r\nabc\r\n0\r\nx-shell-trailer: seen\r\nx-shell-trailer seen: value\r\n\r\n"
            )
            @Assert(contains(firstResponseText, "HTTP/1.1"), false)
            @Assert(contains(firstResponseText, "unexpected-ok"), false)

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38154),
                "GET /shell-later-invalid-chunked-trailer-field-name-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-later-invalid-chunked-trailer-field-name-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 14"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "containment-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellContainsLaterInvalidChunkedTrailerLineAfterValidTrailerLine(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-later-invalid-chunked-trailer-line-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-later-invalid-chunked-trailer-line-containment", "1")
                    .sendString("unexpected-ok")
            })
            app.get("/shell-later-invalid-chunked-trailer-line-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-later-invalid-chunked-trailer-line-containment", "1")
                    .sendString("containment-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38155))
            }
            waitForShellReady(app, UInt16(38155))

            let firstResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38155),
                "POST /shell-later-invalid-chunked-trailer-line-containment HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-trailer\r\n\r\n3\r\nabc\r\n0\r\nx-shell-trailer: seen\r\nx-shell-trailer seen\r\n\r\n"
            )
            @Assert(contains(firstResponseText, "HTTP/1.1"), false)
            @Assert(contains(firstResponseText, "unexpected-ok"), false)

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38155),
                "GET /shell-later-invalid-chunked-trailer-line-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-later-invalid-chunked-trailer-line-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 14"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "containment-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellContainsLaterInvalidChunkedTrailerLineAfterPartialMatchValidTrailerLines(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-partial-match-later-invalid-chunked-trailer-line-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-later-invalid-chunked-trailer-line-containment", "1")
                    .sendString("unexpected-ok")
            })
            app.get("/shell-partial-match-later-invalid-chunked-trailer-line-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-later-invalid-chunked-trailer-line-containment", "1")
                    .sendString("containment-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38160))
            }
            waitForShellReady(app, UInt16(38160))

            let firstResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38160),
                "POST /shell-partial-match-later-invalid-chunked-trailer-line-containment HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-shared-trailer, x-shell-declared-extra\r\n\r\n3\r\nabc\r\n0\r\nx-shell-shared-trailer: seen\r\nx-shell-actual-extra: again\r\nx-shell-invalid trailer\r\n\r\n"
            )
            @Assert(contains(firstResponseText, "HTTP/1.1"), false)
            @Assert(contains(firstResponseText, "unexpected-ok"), false)

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38160),
                "GET /shell-partial-match-later-invalid-chunked-trailer-line-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-partial-match-later-invalid-chunked-trailer-line-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 14"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "containment-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellContainsLaterInvalidChunkedTrailerFieldNameAfterPartialMatchValidTrailerLines(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-partial-match-later-invalid-chunked-trailer-field-name-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-later-invalid-chunked-trailer-field-name-containment", "1")
                    .sendString("unexpected-ok")
            })
            app.get("/shell-partial-match-later-invalid-chunked-trailer-field-name-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-later-invalid-chunked-trailer-field-name-containment", "1")
                    .sendString("containment-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38161))
            }
            waitForShellReady(app, UInt16(38161))

            let firstResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38161),
                "POST /shell-partial-match-later-invalid-chunked-trailer-field-name-containment HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-shared-trailer, x-shell-declared-extra\r\n\r\n3\r\nabc\r\n0\r\nx-shell-shared-trailer: seen\r\nx-shell-actual-extra: again\r\nx-shell-invalid trailer: value\r\n\r\n"
            )
            @Assert(contains(firstResponseText, "HTTP/1.1"), false)
            @Assert(contains(firstResponseText, "unexpected-ok"), false)

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38161),
                "GET /shell-partial-match-later-invalid-chunked-trailer-field-name-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-partial-match-later-invalid-chunked-trailer-field-name-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 14"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "containment-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellContainsLaterInvalidChunkedTrailerFieldNameThenLaterInvalidTrailerLineAfterPartialMatchValidTrailerLines(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-partial-match-later-invalid-chunked-trailer-field-name-then-line-ordering-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-later-invalid-chunked-trailer-field-name-then-line-ordering-containment", "1")
                    .sendString("unexpected-ok")
            })
            app.get("/shell-partial-match-later-invalid-chunked-trailer-field-name-then-line-ordering-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-later-invalid-chunked-trailer-field-name-then-line-ordering-containment", "1")
                    .sendString("containment-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38172))
            }
            waitForShellReady(app, UInt16(38172))

            let firstResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38172),
                "POST /shell-partial-match-later-invalid-chunked-trailer-field-name-then-line-ordering-containment HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-shared-trailer, x-shell-declared-extra\r\n\r\n3\r\nabc\r\n0\r\nx-shell-shared-trailer: seen\r\nx-shell-actual-extra: again\r\nx-shell-invalid trailer: value\r\nx-shell-second-invalid-trailer\r\n\r\n"
            )
            @Assert(contains(firstResponseText, "HTTP/1.1"), false)
            @Assert(contains(firstResponseText, "unexpected-ok"), false)

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38172),
                "GET /shell-partial-match-later-invalid-chunked-trailer-field-name-then-line-ordering-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-partial-match-later-invalid-chunked-trailer-field-name-then-line-ordering-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 14"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "containment-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellContainsLaterInvalidChunkedTrailerLineThenLaterInvalidTrailerFieldNameAfterPartialMatchValidTrailerLines(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-partial-match-later-invalid-chunked-trailer-line-then-field-name-ordering-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-later-invalid-chunked-trailer-line-then-field-name-ordering-containment", "1")
                    .sendString("unexpected-ok")
            })
            app.get("/shell-partial-match-later-invalid-chunked-trailer-line-then-field-name-ordering-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-later-invalid-chunked-trailer-line-then-field-name-ordering-containment", "1")
                    .sendString("containment-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38173))
            }
            waitForShellReady(app, UInt16(38173))

            let firstResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38173),
                "POST /shell-partial-match-later-invalid-chunked-trailer-line-then-field-name-ordering-containment HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-shared-trailer, x-shell-declared-extra\r\n\r\n3\r\nabc\r\n0\r\nx-shell-shared-trailer: seen\r\nx-shell-actual-extra: again\r\nx-shell-first-invalid-trailer\r\nx-shell-second-invalid trailer: value\r\n\r\n"
            )
            @Assert(contains(firstResponseText, "HTTP/1.1"), false)
            @Assert(contains(firstResponseText, "unexpected-ok"), false)

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38173),
                "GET /shell-partial-match-later-invalid-chunked-trailer-line-then-field-name-ordering-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-partial-match-later-invalid-chunked-trailer-line-then-field-name-ordering-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 14"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "containment-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellContainsLaterInvalidChunkedTrailerLineThenLaterValidTrailerLineAfterPartialMatchValidTrailerLines(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-partial-match-later-invalid-chunked-trailer-line-then-valid-trailer-line-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-later-invalid-chunked-trailer-line-then-valid-trailer-line-containment", "1")
                    .sendString("unexpected-ok")
            })
            app.get("/shell-partial-match-later-invalid-chunked-trailer-line-then-valid-trailer-line-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-later-invalid-chunked-trailer-line-then-valid-trailer-line-containment", "1")
                    .sendString("containment-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38174))
            }
            waitForShellReady(app, UInt16(38174))

            let firstResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38174),
                "POST /shell-partial-match-later-invalid-chunked-trailer-line-then-valid-trailer-line-containment HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-shared-trailer, x-shell-declared-extra\r\n\r\n3\r\nabc\r\n0\r\nx-shell-shared-trailer: seen\r\nx-shell-actual-extra: again\r\nx-shell-first-invalid-trailer\r\nx-shell-recovery-trailer: ok\r\n\r\n"
            )
            @Assert(contains(firstResponseText, "HTTP/1.1"), false)
            @Assert(contains(firstResponseText, "unexpected-ok"), false)

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38174),
                "GET /shell-partial-match-later-invalid-chunked-trailer-line-then-valid-trailer-line-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-partial-match-later-invalid-chunked-trailer-line-then-valid-trailer-line-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 14"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "containment-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellContainsLaterInvalidChunkedTrailerFieldNameThenLaterValidTrailerLineAfterPartialMatchValidTrailerLines(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-partial-match-later-invalid-chunked-trailer-field-name-then-valid-trailer-line-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-later-invalid-chunked-trailer-field-name-then-valid-trailer-line-containment", "1")
                    .sendString("unexpected-ok")
            })
            app.get("/shell-partial-match-later-invalid-chunked-trailer-field-name-then-valid-trailer-line-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-later-invalid-chunked-trailer-field-name-then-valid-trailer-line-containment", "1")
                    .sendString("containment-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38175))
            }
            waitForShellReady(app, UInt16(38175))

            let firstResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38175),
                "POST /shell-partial-match-later-invalid-chunked-trailer-field-name-then-valid-trailer-line-containment HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-shared-trailer, x-shell-declared-extra\r\n\r\n3\r\nabc\r\n0\r\nx-shell-shared-trailer: seen\r\nx-shell-actual-extra: again\r\nx-shell-invalid trailer: value\r\nx-shell-recovery-trailer: ok\r\n\r\n"
            )
            @Assert(contains(firstResponseText, "HTTP/1.1"), false)
            @Assert(contains(firstResponseText, "unexpected-ok"), false)

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38175),
                "GET /shell-partial-match-later-invalid-chunked-trailer-field-name-then-valid-trailer-line-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-partial-match-later-invalid-chunked-trailer-field-name-then-valid-trailer-line-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 14"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "containment-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellContainsLaterInvalidChunkedTrailerLineThenLaterValidDeclaredTrailerLineAfterPartialMatchValidTrailerLines(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-partial-match-later-invalid-chunked-trailer-line-then-valid-declared-trailer-line-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-later-invalid-chunked-trailer-line-then-valid-declared-trailer-line-containment", "1")
                    .sendString("unexpected-ok")
            })
            app.get("/shell-partial-match-later-invalid-chunked-trailer-line-then-valid-declared-trailer-line-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-later-invalid-chunked-trailer-line-then-valid-declared-trailer-line-containment", "1")
                    .sendString("containment-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38176))
            }
            waitForShellReady(app, UInt16(38176))

            let firstResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38176),
                "POST /shell-partial-match-later-invalid-chunked-trailer-line-then-valid-declared-trailer-line-containment HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-shared-trailer, x-shell-declared-extra\r\n\r\n3\r\nabc\r\n0\r\nx-shell-shared-trailer: seen\r\nx-shell-actual-extra: again\r\nx-shell-first-invalid-trailer\r\nx-shell-declared-extra: recovered\r\n\r\n"
            )
            @Assert(contains(firstResponseText, "HTTP/1.1"), false)
            @Assert(contains(firstResponseText, "unexpected-ok"), false)

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38176),
                "GET /shell-partial-match-later-invalid-chunked-trailer-line-then-valid-declared-trailer-line-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-partial-match-later-invalid-chunked-trailer-line-then-valid-declared-trailer-line-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 14"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "containment-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellContainsLaterInvalidChunkedTrailerFieldNameThenLaterValidDeclaredTrailerLineAfterPartialMatchValidTrailerLines(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-partial-match-later-invalid-chunked-trailer-field-name-then-valid-declared-trailer-line-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-later-invalid-chunked-trailer-field-name-then-valid-declared-trailer-line-containment", "1")
                    .sendString("unexpected-ok")
            })
            app.get("/shell-partial-match-later-invalid-chunked-trailer-field-name-then-valid-declared-trailer-line-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-later-invalid-chunked-trailer-field-name-then-valid-declared-trailer-line-containment", "1")
                    .sendString("containment-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38177))
            }
            waitForShellReady(app, UInt16(38177))

            let firstResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38177),
                "POST /shell-partial-match-later-invalid-chunked-trailer-field-name-then-valid-declared-trailer-line-containment HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-shared-trailer, x-shell-declared-extra\r\n\r\n3\r\nabc\r\n0\r\nx-shell-shared-trailer: seen\r\nx-shell-actual-extra: again\r\nx-shell-invalid trailer: value\r\nx-shell-declared-extra: recovered\r\n\r\n"
            )
            @Assert(contains(firstResponseText, "HTTP/1.1"), false)
            @Assert(contains(firstResponseText, "unexpected-ok"), false)

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38177),
                "GET /shell-partial-match-later-invalid-chunked-trailer-field-name-then-valid-declared-trailer-line-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-partial-match-later-invalid-chunked-trailer-field-name-then-valid-declared-trailer-line-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 14"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "containment-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellContainsLaterInvalidChunkedTrailerLineAfterPartialMatchMultipleValidTrailerLines(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-containment", "1")
                    .sendString("unexpected-ok")
            })
            app.get("/shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-containment", "1")
                    .sendString("containment-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38162))
            }
            waitForShellReady(app, UInt16(38162))

            let firstResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38162),
                "POST /shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-containment HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-shared-trailer, x-shell-declared-extra\r\n\r\n3\r\nabc\r\n0\r\nx-shell-shared-trailer: seen\r\nx-shell-actual-extra: again\r\nx-shell-third-extra: more\r\nx-shell-invalid trailer\r\n\r\n"
            )
            @Assert(contains(firstResponseText, "HTTP/1.1"), false)
            @Assert(contains(firstResponseText, "unexpected-ok"), false)

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38162),
                "GET /shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 14"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "containment-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellContainsLaterInvalidChunkedTrailerFieldNameAfterPartialMatchMultipleValidTrailerLines(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-containment", "1")
                    .sendString("unexpected-ok")
            })
            app.get("/shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-containment", "1")
                    .sendString("containment-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38163))
            }
            waitForShellReady(app, UInt16(38163))

            let firstResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38163),
                "POST /shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-containment HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-shared-trailer, x-shell-declared-extra\r\n\r\n3\r\nabc\r\n0\r\nx-shell-shared-trailer: seen\r\nx-shell-actual-extra: again\r\nx-shell-third-extra: more\r\nx-shell-invalid trailer: value\r\n\r\n"
            )
            @Assert(contains(firstResponseText, "HTTP/1.1"), false)
            @Assert(contains(firstResponseText, "unexpected-ok"), false)

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38163),
                "GET /shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 14"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "containment-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellContainsLaterInvalidChunkedTrailerFieldNameThenLaterInvalidTrailerLineAfterPartialMatchMultipleValidTrailerLines(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-then-line-ordering-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-then-line-ordering-containment", "1")
                    .sendString("unexpected-ok")
            })
            app.get("/shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-then-line-ordering-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-then-line-ordering-containment", "1")
                    .sendString("containment-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38164))
            }
            waitForShellReady(app, UInt16(38164))

            let firstResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38164),
                "POST /shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-then-line-ordering-containment HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-shared-trailer, x-shell-declared-extra\r\n\r\n3\r\nabc\r\n0\r\nx-shell-shared-trailer: seen\r\nx-shell-actual-extra: again\r\nx-shell-third-extra: more\r\nx-shell-invalid trailer: value\r\nx-shell-second-invalid-trailer\r\n\r\n"
            )
            @Assert(contains(firstResponseText, "HTTP/1.1"), false)
            @Assert(contains(firstResponseText, "unexpected-ok"), false)

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38164),
                "GET /shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-then-line-ordering-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-then-line-ordering-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 14"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "containment-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellContainsLaterInvalidChunkedTrailerFieldNameThenLaterSecondInvalidTrailerFieldNameAfterPartialMatchMultipleValidTrailerLines(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-then-second-invalid-trailer-field-name-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-then-second-invalid-trailer-field-name-containment", "1")
                    .sendString("unexpected-ok")
            })
            app.get("/shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-then-second-invalid-trailer-field-name-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-then-second-invalid-trailer-field-name-containment", "1")
                    .sendString("containment-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38171))
            }
            waitForShellReady(app, UInt16(38171))

            let firstResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38171),
                "POST /shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-then-second-invalid-trailer-field-name-containment HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-shared-trailer, x-shell-declared-extra\r\n\r\n3\r\nabc\r\n0\r\nx-shell-shared-trailer: seen\r\nx-shell-actual-extra: again\r\nx-shell-third-extra: more\r\nx-shell-invalid trailer: value\r\nx-shell-second-invalid trailer: again\r\n\r\n"
            )
            @Assert(contains(firstResponseText, "HTTP/1.1"), false)
            @Assert(contains(firstResponseText, "unexpected-ok"), false)

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38171),
                "GET /shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-then-second-invalid-trailer-field-name-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-then-second-invalid-trailer-field-name-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 14"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "containment-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellContainsLaterInvalidChunkedTrailerLineThenLaterInvalidTrailerFieldNameAfterPartialMatchMultipleValidTrailerLines(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-then-field-name-ordering-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-then-field-name-ordering-containment", "1")
                    .sendString("unexpected-ok")
            })
            app.get("/shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-then-field-name-ordering-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-then-field-name-ordering-containment", "1")
                    .sendString("containment-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38165))
            }
            waitForShellReady(app, UInt16(38165))

            let firstResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38165),
                "POST /shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-then-field-name-ordering-containment HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-shared-trailer, x-shell-declared-extra\r\n\r\n3\r\nabc\r\n0\r\nx-shell-shared-trailer: seen\r\nx-shell-actual-extra: again\r\nx-shell-third-extra: more\r\nx-shell-first-invalid-trailer\r\nx-shell-second-invalid trailer: value\r\n\r\n"
            )
            @Assert(contains(firstResponseText, "HTTP/1.1"), false)
            @Assert(contains(firstResponseText, "unexpected-ok"), false)

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38165),
                "GET /shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-then-field-name-ordering-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-then-field-name-ordering-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 14"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "containment-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellContainsLaterInvalidChunkedTrailerLineThenLaterSecondInvalidTrailerLineAfterPartialMatchMultipleValidTrailerLines(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-then-second-invalid-trailer-line-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-then-second-invalid-trailer-line-containment", "1")
                    .sendString("unexpected-ok")
            })
            app.get("/shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-then-second-invalid-trailer-line-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-then-second-invalid-trailer-line-containment", "1")
                    .sendString("containment-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38170))
            }
            waitForShellReady(app, UInt16(38170))

            let firstResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38170),
                "POST /shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-then-second-invalid-trailer-line-containment HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-shared-trailer, x-shell-declared-extra\r\n\r\n3\r\nabc\r\n0\r\nx-shell-shared-trailer: seen\r\nx-shell-actual-extra: again\r\nx-shell-third-extra: more\r\nx-shell-first-invalid-trailer\r\nx-shell-second-invalid-trailer\r\n\r\n"
            )
            @Assert(contains(firstResponseText, "HTTP/1.1"), false)
            @Assert(contains(firstResponseText, "unexpected-ok"), false)

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38170),
                "GET /shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-then-second-invalid-trailer-line-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-then-second-invalid-trailer-line-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 14"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "containment-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellContainsLaterInvalidChunkedTrailerLineThenLaterValidTrailerLineAfterPartialMatchMultipleValidTrailerLines(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-then-valid-trailer-line-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-then-valid-trailer-line-containment", "1")
                    .sendString("unexpected-ok")
            })
            app.get("/shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-then-valid-trailer-line-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-then-valid-trailer-line-containment", "1")
                    .sendString("containment-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38166))
            }
            waitForShellReady(app, UInt16(38166))

            let firstResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38166),
                "POST /shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-then-valid-trailer-line-containment HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-shared-trailer, x-shell-declared-extra\r\n\r\n3\r\nabc\r\n0\r\nx-shell-shared-trailer: seen\r\nx-shell-actual-extra: again\r\nx-shell-third-extra: more\r\nx-shell-first-invalid-trailer\r\nx-shell-recovery-trailer: ok\r\n\r\n"
            )
            @Assert(contains(firstResponseText, "HTTP/1.1"), false)
            @Assert(contains(firstResponseText, "unexpected-ok"), false)

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38166),
                "GET /shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-then-valid-trailer-line-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-then-valid-trailer-line-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 14"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "containment-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellContainsLaterInvalidChunkedTrailerFieldNameThenLaterValidTrailerLineAfterPartialMatchMultipleValidTrailerLines(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-then-valid-trailer-line-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-then-valid-trailer-line-containment", "1")
                    .sendString("unexpected-ok")
            })
            app.get("/shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-then-valid-trailer-line-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-then-valid-trailer-line-containment", "1")
                    .sendString("containment-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38167))
            }
            waitForShellReady(app, UInt16(38167))

            let firstResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38167),
                "POST /shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-then-valid-trailer-line-containment HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-shared-trailer, x-shell-declared-extra\r\n\r\n3\r\nabc\r\n0\r\nx-shell-shared-trailer: seen\r\nx-shell-actual-extra: again\r\nx-shell-third-extra: more\r\nx-shell-invalid trailer: value\r\nx-shell-recovery-trailer: ok\r\n\r\n"
            )
            @Assert(contains(firstResponseText, "HTTP/1.1"), false)
            @Assert(contains(firstResponseText, "unexpected-ok"), false)

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38167),
                "GET /shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-then-valid-trailer-line-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-then-valid-trailer-line-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 14"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "containment-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellContainsLaterInvalidChunkedTrailerLineThenLaterValidDeclaredTrailerLineAfterPartialMatchMultipleValidTrailerLines(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-then-valid-declared-trailer-line-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-then-valid-declared-trailer-line-containment", "1")
                    .sendString("unexpected-ok")
            })
            app.get("/shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-then-valid-declared-trailer-line-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-then-valid-declared-trailer-line-containment", "1")
                    .sendString("containment-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38168))
            }
            waitForShellReady(app, UInt16(38168))

            let firstResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38168),
                "POST /shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-then-valid-declared-trailer-line-containment HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-shared-trailer, x-shell-declared-extra\r\n\r\n3\r\nabc\r\n0\r\nx-shell-shared-trailer: seen\r\nx-shell-actual-extra: again\r\nx-shell-third-extra: more\r\nx-shell-first-invalid-trailer\r\nx-shell-declared-extra: recovered\r\n\r\n"
            )
            @Assert(contains(firstResponseText, "HTTP/1.1"), false)
            @Assert(contains(firstResponseText, "unexpected-ok"), false)

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38168),
                "GET /shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-then-valid-declared-trailer-line-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-line-then-valid-declared-trailer-line-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 14"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "containment-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellContainsLaterInvalidChunkedTrailerFieldNameThenLaterValidDeclaredTrailerLineAfterPartialMatchMultipleValidTrailerLines(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-then-valid-declared-trailer-line-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-then-valid-declared-trailer-line-containment", "1")
                    .sendString("unexpected-ok")
            })
            app.get("/shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-then-valid-declared-trailer-line-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-then-valid-declared-trailer-line-containment", "1")
                    .sendString("containment-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38169))
            }
            waitForShellReady(app, UInt16(38169))

            let firstResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38169),
                "POST /shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-then-valid-declared-trailer-line-containment HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-shared-trailer, x-shell-declared-extra\r\n\r\n3\r\nabc\r\n0\r\nx-shell-shared-trailer: seen\r\nx-shell-actual-extra: again\r\nx-shell-third-extra: more\r\nx-shell-invalid trailer: value\r\nx-shell-declared-extra: recovered\r\n\r\n"
            )
            @Assert(contains(firstResponseText, "HTTP/1.1"), false)
            @Assert(contains(firstResponseText, "unexpected-ok"), false)

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38169),
                "GET /shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-then-valid-declared-trailer-line-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-partial-match-multi-valid-lines-later-invalid-chunked-trailer-field-name-then-valid-declared-trailer-line-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 14"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "containment-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellKeepsAliveAfterChunkedRequestTrailerWithoutDeclaration(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "1")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-chunked-trailer-without-declaration-keepalive", { ctx =>
                let turn = ctx.queryFromUrl("turn") ?? ""
                let body = ctx.bodyString()
                let _ = ctx
                    .setHeader("x-shell-chunked-trailer-without-declaration-keepalive", "1")
                    .sendString("${turn}:${body}")
            })
            app.get("/shell-chunked-trailer-without-declaration-keepalive", { ctx =>
                let turn = ctx.queryFromUrl("turn") ?? ""
                let _ = ctx
                    .setHeader("x-shell-chunked-trailer-without-declaration-keepalive", "1")
                    .sendString("${turn}:done")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38156))
            }
            waitForShellReady(app, UInt16(38156))

            let socket = TcpSocket(IPSocketAddress.parse("127.0.0.1:38156"))
            socket.connect()
            try {
                socket.write(
                    "POST /shell-chunked-trailer-without-declaration-keepalive?turn=1 HTTP/1.1\r\nHost: example.com\r\nConnection: keep-alive\r\nTransfer-Encoding: chunked\r\n\r\n5\r\nabcde\r\n0\r\nx-shell-trailer: seen\r\n\r\n".toArray()
                )
                let firstResponse = readSocketServerEngineShellResponseFrame(socket)
                @Assert(contains(firstResponse, "HTTP/1.1 200 OK"), true)
                @Assert(contains(firstResponse, "x-shell-chunked-trailer-without-declaration-keepalive: 1"), true)
                @Assert(contains(firstResponse, "content-length: 7"), true)
                @Assert(contains(firstResponse, "\r\n\r\n1:abcde"), true)
                @Assert(contains(firstResponse, "connection: close"), false)

                socket.write(
                    "GET /shell-chunked-trailer-without-declaration-keepalive?turn=2 HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n".toArray()
                )
                let secondResponse = readSocketServerEngineShellResponseWire(socket)
                @Assert(contains(secondResponse, "HTTP/1.1 200 OK"), true)
                @Assert(contains(secondResponse, "x-shell-chunked-trailer-without-declaration-keepalive: 1"), true)
                @Assert(contains(secondResponse, "\r\n\r\n2:done"), true)
                @Assert(contains(secondResponse, "connection: close"), true)
            } finally {
                if (!socket.isClosed()) {
                    socket.close()
                }
            }

            let _ = serverFuture.get(Duration.second * 5)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellKeepsAliveAfterChunkedRequestTrailerDeclarationMismatch(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "1")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-chunked-trailer-declaration-mismatch-keepalive", { ctx =>
                let turn = ctx.queryFromUrl("turn") ?? ""
                let body = ctx.bodyString()
                let _ = ctx
                    .setHeader("x-shell-chunked-trailer-declaration-mismatch-keepalive", "1")
                    .sendString("${turn}:${body}")
            })
            app.get("/shell-chunked-trailer-declaration-mismatch-keepalive", { ctx =>
                let turn = ctx.queryFromUrl("turn") ?? ""
                let _ = ctx
                    .setHeader("x-shell-chunked-trailer-declaration-mismatch-keepalive", "1")
                    .sendString("${turn}:done")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38157))
            }
            waitForShellReady(app, UInt16(38157))

            let socket = TcpSocket(IPSocketAddress.parse("127.0.0.1:38157"))
            socket.connect()
            try {
                socket.write(
                    "POST /shell-chunked-trailer-declaration-mismatch-keepalive?turn=1 HTTP/1.1\r\nHost: example.com\r\nConnection: keep-alive\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-declared-trailer\r\n\r\n5\r\nabcde\r\n0\r\nx-shell-actual-trailer: seen\r\n\r\n".toArray()
                )
                let firstResponse = readSocketServerEngineShellResponseFrame(socket)
                @Assert(contains(firstResponse, "HTTP/1.1 200 OK"), true)
                @Assert(contains(firstResponse, "x-shell-chunked-trailer-declaration-mismatch-keepalive: 1"), true)
                @Assert(contains(firstResponse, "content-length: 7"), true)
                @Assert(contains(firstResponse, "\r\n\r\n1:abcde"), true)
                @Assert(contains(firstResponse, "connection: close"), false)

                socket.write(
                    "GET /shell-chunked-trailer-declaration-mismatch-keepalive?turn=2 HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n".toArray()
                )
                let secondResponse = readSocketServerEngineShellResponseWire(socket)
                @Assert(contains(secondResponse, "HTTP/1.1 200 OK"), true)
                @Assert(contains(secondResponse, "x-shell-chunked-trailer-declaration-mismatch-keepalive: 1"), true)
                @Assert(contains(secondResponse, "\r\n\r\n2:done"), true)
                @Assert(contains(secondResponse, "connection: close"), true)
            } finally {
                if (!socket.isClosed()) {
                    socket.close()
                }
            }

            let _ = serverFuture.get(Duration.second * 5)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellContainsLaterInvalidChunkedTrailerLineAfterTrailerDeclarationMismatch(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-declaration-mismatch-later-invalid-chunked-trailer-line-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-declaration-mismatch-later-invalid-chunked-trailer-line-containment", "1")
                    .sendString("unexpected-ok")
            })
            app.get("/shell-declaration-mismatch-later-invalid-chunked-trailer-line-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-declaration-mismatch-later-invalid-chunked-trailer-line-containment", "1")
                    .sendString("containment-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38178))
            }
            waitForShellReady(app, UInt16(38178))

            let firstResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38178),
                "POST /shell-declaration-mismatch-later-invalid-chunked-trailer-line-containment HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-declared-trailer\r\n\r\n3\r\nabc\r\n0\r\nx-shell-actual-trailer: seen\r\nx-shell-invalid-trailer\r\n\r\n"
            )
            @Assert(contains(firstResponseText, "HTTP/1.1"), false)
            @Assert(contains(firstResponseText, "unexpected-ok"), false)

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38178),
                "GET /shell-declaration-mismatch-later-invalid-chunked-trailer-line-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-declaration-mismatch-later-invalid-chunked-trailer-line-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 14"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "containment-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellContainsLaterInvalidChunkedTrailerFieldNameAfterTrailerDeclarationMismatch(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-declaration-mismatch-later-invalid-chunked-trailer-field-name-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-declaration-mismatch-later-invalid-chunked-trailer-field-name-containment", "1")
                    .sendString("unexpected-ok")
            })
            app.get("/shell-declaration-mismatch-later-invalid-chunked-trailer-field-name-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-declaration-mismatch-later-invalid-chunked-trailer-field-name-containment", "1")
                    .sendString("containment-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38179))
            }
            waitForShellReady(app, UInt16(38179))

            let firstResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38179),
                "POST /shell-declaration-mismatch-later-invalid-chunked-trailer-field-name-containment HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-declared-trailer\r\n\r\n3\r\nabc\r\n0\r\nx-shell-actual-trailer: seen\r\nx-shell-invalid trailer: value\r\n\r\n"
            )
            @Assert(contains(firstResponseText, "HTTP/1.1"), false)
            @Assert(contains(firstResponseText, "unexpected-ok"), false)

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38179),
                "GET /shell-declaration-mismatch-later-invalid-chunked-trailer-field-name-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-declaration-mismatch-later-invalid-chunked-trailer-field-name-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 14"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "containment-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellContainsLaterInvalidChunkedTrailerFieldNameThenLaterInvalidTrailerLineAfterTrailerDeclarationMismatch(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-declaration-mismatch-later-invalid-chunked-trailer-field-name-then-line-ordering-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-declaration-mismatch-later-invalid-chunked-trailer-field-name-then-line-ordering-containment", "1")
                    .sendString("unexpected-ok")
            })
            app.get("/shell-declaration-mismatch-later-invalid-chunked-trailer-field-name-then-line-ordering-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-declaration-mismatch-later-invalid-chunked-trailer-field-name-then-line-ordering-containment", "1")
                    .sendString("containment-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38180))
            }
            waitForShellReady(app, UInt16(38180))

            let firstResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38180),
                "POST /shell-declaration-mismatch-later-invalid-chunked-trailer-field-name-then-line-ordering-containment HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-declared-trailer\r\n\r\n3\r\nabc\r\n0\r\nx-shell-actual-trailer: seen\r\nx-shell-invalid trailer: value\r\nx-shell-second-invalid-trailer\r\n\r\n"
            )
            @Assert(contains(firstResponseText, "HTTP/1.1"), false)
            @Assert(contains(firstResponseText, "unexpected-ok"), false)

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38180),
                "GET /shell-declaration-mismatch-later-invalid-chunked-trailer-field-name-then-line-ordering-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-declaration-mismatch-later-invalid-chunked-trailer-field-name-then-line-ordering-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 14"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "containment-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellContainsLaterInvalidChunkedTrailerLineThenLaterInvalidTrailerFieldNameAfterTrailerDeclarationMismatch(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-declaration-mismatch-later-invalid-chunked-trailer-line-then-field-name-ordering-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-declaration-mismatch-later-invalid-chunked-trailer-line-then-field-name-ordering-containment", "1")
                    .sendString("unexpected-ok")
            })
            app.get("/shell-declaration-mismatch-later-invalid-chunked-trailer-line-then-field-name-ordering-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-declaration-mismatch-later-invalid-chunked-trailer-line-then-field-name-ordering-containment", "1")
                    .sendString("containment-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38181))
            }
            waitForShellReady(app, UInt16(38181))

            let firstResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38181),
                "POST /shell-declaration-mismatch-later-invalid-chunked-trailer-line-then-field-name-ordering-containment HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-declared-trailer\r\n\r\n3\r\nabc\r\n0\r\nx-shell-actual-trailer: seen\r\nx-shell-first-invalid-trailer\r\nx-shell-second-invalid trailer: value\r\n\r\n"
            )
            @Assert(contains(firstResponseText, "HTTP/1.1"), false)
            @Assert(contains(firstResponseText, "unexpected-ok"), false)

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38181),
                "GET /shell-declaration-mismatch-later-invalid-chunked-trailer-line-then-field-name-ordering-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-declaration-mismatch-later-invalid-chunked-trailer-line-then-field-name-ordering-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 14"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "containment-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellContainsLaterInvalidChunkedTrailerLineThenLaterValidTrailerLineAfterTrailerDeclarationMismatch(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-declaration-mismatch-later-invalid-chunked-trailer-line-then-later-valid-trailer-line-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-declaration-mismatch-later-invalid-chunked-trailer-line-then-later-valid-trailer-line-containment", "1")
                    .sendString("unexpected-ok")
            })
            app.get("/shell-declaration-mismatch-later-invalid-chunked-trailer-line-then-later-valid-trailer-line-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-declaration-mismatch-later-invalid-chunked-trailer-line-then-later-valid-trailer-line-containment", "1")
                    .sendString("containment-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38182))
            }
            waitForShellReady(app, UInt16(38182))

            let firstResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38182),
                "POST /shell-declaration-mismatch-later-invalid-chunked-trailer-line-then-later-valid-trailer-line-containment HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-declared-trailer\r\n\r\n3\r\nabc\r\n0\r\nx-shell-actual-trailer: seen\r\nx-shell-first-invalid-trailer\r\nx-shell-recovery-trailer: ok\r\n\r\n"
            )
            @Assert(contains(firstResponseText, "HTTP/1.1"), false)
            @Assert(contains(firstResponseText, "unexpected-ok"), false)

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38182),
                "GET /shell-declaration-mismatch-later-invalid-chunked-trailer-line-then-later-valid-trailer-line-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-declaration-mismatch-later-invalid-chunked-trailer-line-then-later-valid-trailer-line-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 14"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "containment-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellContainsLaterInvalidChunkedTrailerFieldNameThenLaterValidTrailerLineAfterTrailerDeclarationMismatch(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-declaration-mismatch-later-invalid-chunked-trailer-field-name-then-later-valid-trailer-line-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-declaration-mismatch-later-invalid-chunked-trailer-field-name-then-later-valid-trailer-line-containment", "1")
                    .sendString("unexpected-ok")
            })
            app.get("/shell-declaration-mismatch-later-invalid-chunked-trailer-field-name-then-later-valid-trailer-line-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-declaration-mismatch-later-invalid-chunked-trailer-field-name-then-later-valid-trailer-line-containment", "1")
                    .sendString("containment-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38183))
            }
            waitForShellReady(app, UInt16(38183))

            let firstResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38183),
                "POST /shell-declaration-mismatch-later-invalid-chunked-trailer-field-name-then-later-valid-trailer-line-containment HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-declared-trailer\r\n\r\n3\r\nabc\r\n0\r\nx-shell-actual-trailer: seen\r\nx-shell-invalid trailer: value\r\nx-shell-recovery-trailer: ok\r\n\r\n"
            )
            @Assert(contains(firstResponseText, "HTTP/1.1"), false)
            @Assert(contains(firstResponseText, "unexpected-ok"), false)

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38183),
                "GET /shell-declaration-mismatch-later-invalid-chunked-trailer-field-name-then-later-valid-trailer-line-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-declaration-mismatch-later-invalid-chunked-trailer-field-name-then-later-valid-trailer-line-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 14"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "containment-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellContainsLaterInvalidChunkedTrailerLineThenLaterValidDeclaredTrailerLineAfterTrailerDeclarationMismatch(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-declaration-mismatch-later-invalid-chunked-trailer-line-then-later-valid-declared-trailer-line-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-declaration-mismatch-later-invalid-chunked-trailer-line-then-later-valid-declared-trailer-line-containment", "1")
                    .sendString("unexpected-ok")
            })
            app.get("/shell-declaration-mismatch-later-invalid-chunked-trailer-line-then-later-valid-declared-trailer-line-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-declaration-mismatch-later-invalid-chunked-trailer-line-then-later-valid-declared-trailer-line-containment", "1")
                    .sendString("containment-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38184))
            }
            waitForShellReady(app, UInt16(38184))

            let firstResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38184),
                "POST /shell-declaration-mismatch-later-invalid-chunked-trailer-line-then-later-valid-declared-trailer-line-containment HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-declared-trailer\r\n\r\n3\r\nabc\r\n0\r\nx-shell-actual-trailer: seen\r\nx-shell-first-invalid-trailer\r\nx-shell-declared-trailer: recovered\r\n\r\n"
            )
            @Assert(contains(firstResponseText, "HTTP/1.1"), false)
            @Assert(contains(firstResponseText, "unexpected-ok"), false)

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38184),
                "GET /shell-declaration-mismatch-later-invalid-chunked-trailer-line-then-later-valid-declared-trailer-line-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-declaration-mismatch-later-invalid-chunked-trailer-line-then-later-valid-declared-trailer-line-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 14"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "containment-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellContainsLaterInvalidChunkedTrailerFieldNameThenLaterValidDeclaredTrailerLineAfterTrailerDeclarationMismatch(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-declaration-mismatch-later-invalid-chunked-trailer-field-name-then-later-valid-declared-trailer-line-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-declaration-mismatch-later-invalid-chunked-trailer-field-name-then-later-valid-declared-trailer-line-containment", "1")
                    .sendString("unexpected-ok")
            })
            app.get("/shell-declaration-mismatch-later-invalid-chunked-trailer-field-name-then-later-valid-declared-trailer-line-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-declaration-mismatch-later-invalid-chunked-trailer-field-name-then-later-valid-declared-trailer-line-containment", "1")
                    .sendString("containment-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38185))
            }
            waitForShellReady(app, UInt16(38185))

            let firstResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38185),
                "POST /shell-declaration-mismatch-later-invalid-chunked-trailer-field-name-then-later-valid-declared-trailer-line-containment HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-declared-trailer\r\n\r\n3\r\nabc\r\n0\r\nx-shell-actual-trailer: seen\r\nx-shell-invalid trailer: value\r\nx-shell-declared-trailer: recovered\r\n\r\n"
            )
            @Assert(contains(firstResponseText, "HTTP/1.1"), false)
            @Assert(contains(firstResponseText, "unexpected-ok"), false)

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38185),
                "GET /shell-declaration-mismatch-later-invalid-chunked-trailer-field-name-then-later-valid-declared-trailer-line-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-declaration-mismatch-later-invalid-chunked-trailer-field-name-then-later-valid-declared-trailer-line-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 14"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "containment-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellKeepsAliveAfterChunkedRequestTrailerDeclarationPartialMatch(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "1")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-chunked-trailer-declaration-partial-match-keepalive", { ctx =>
                let turn = ctx.queryFromUrl("turn") ?? ""
                let body = ctx.bodyString()
                let _ = ctx
                    .setHeader("x-shell-chunked-trailer-declaration-partial-match-keepalive", "1")
                    .sendString("${turn}:${body}")
            })
            app.get("/shell-chunked-trailer-declaration-partial-match-keepalive", { ctx =>
                let turn = ctx.queryFromUrl("turn") ?? ""
                let _ = ctx
                    .setHeader("x-shell-chunked-trailer-declaration-partial-match-keepalive", "1")
                    .sendString("${turn}:done")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38158))
            }
            waitForShellReady(app, UInt16(38158))

            let socket = TcpSocket(IPSocketAddress.parse("127.0.0.1:38158"))
            socket.connect()
            try {
                socket.write(
                    "POST /shell-chunked-trailer-declaration-partial-match-keepalive?turn=1 HTTP/1.1\r\nHost: example.com\r\nConnection: keep-alive\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-shared-trailer, x-shell-declared-extra\r\n\r\n5\r\nabcde\r\n0\r\nx-shell-shared-trailer: seen\r\nx-shell-actual-extra: again\r\n\r\n".toArray()
                )
                let firstResponse = readSocketServerEngineShellResponseFrame(socket)
                @Assert(contains(firstResponse, "HTTP/1.1 200 OK"), true)
                @Assert(contains(firstResponse, "x-shell-chunked-trailer-declaration-partial-match-keepalive: 1"), true)
                @Assert(contains(firstResponse, "content-length: 7"), true)
                @Assert(contains(firstResponse, "\r\n\r\n1:abcde"), true)
                @Assert(contains(firstResponse, "connection: close"), false)

                socket.write(
                    "GET /shell-chunked-trailer-declaration-partial-match-keepalive?turn=2 HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n".toArray()
                )
                let secondResponse = readSocketServerEngineShellResponseWire(socket)
                @Assert(contains(secondResponse, "HTTP/1.1 200 OK"), true)
                @Assert(contains(secondResponse, "x-shell-chunked-trailer-declaration-partial-match-keepalive: 1"), true)
                @Assert(contains(secondResponse, "\r\n\r\n2:done"), true)
                @Assert(contains(secondResponse, "connection: close"), true)
            } finally {
                if (!socket.isClosed()) {
                    socket.close()
                }
            }

            let _ = serverFuture.get(Duration.second * 5)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellKeepsAliveAfterChunkedRequestTrailerDeclarationPartialMatchMultipleTrailerLines(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "1")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.post("/shell-chunked-trailer-declaration-partial-match-multi-trailer-lines-keepalive", { ctx =>
                let turn = ctx.queryFromUrl("turn") ?? ""
                let body = ctx.bodyString()
                let _ = ctx
                    .setHeader("x-shell-chunked-trailer-declaration-partial-match-multi-trailer-lines-keepalive", "1")
                    .sendString("${turn}:${body}")
            })
            app.get("/shell-chunked-trailer-declaration-partial-match-multi-trailer-lines-keepalive", { ctx =>
                let turn = ctx.queryFromUrl("turn") ?? ""
                let _ = ctx
                    .setHeader("x-shell-chunked-trailer-declaration-partial-match-multi-trailer-lines-keepalive", "1")
                    .sendString("${turn}:done")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38159))
            }
            waitForShellReady(app, UInt16(38159))

            let socket = TcpSocket(IPSocketAddress.parse("127.0.0.1:38159"))
            socket.connect()
            try {
                socket.write(
                    "POST /shell-chunked-trailer-declaration-partial-match-multi-trailer-lines-keepalive?turn=1 HTTP/1.1\r\nHost: example.com\r\nConnection: keep-alive\r\nTransfer-Encoding: chunked\r\nTrailer: x-shell-shared-trailer, x-shell-declared-extra\r\n\r\n5\r\nabcde\r\n0\r\nx-shell-shared-trailer: seen\r\nx-shell-actual-extra: again\r\nx-shell-third-extra: more\r\n\r\n".toArray()
                )
                let firstResponse = readSocketServerEngineShellResponseFrame(socket)
                @Assert(contains(firstResponse, "HTTP/1.1 200 OK"), true)
                @Assert(contains(firstResponse, "x-shell-chunked-trailer-declaration-partial-match-multi-trailer-lines-keepalive: 1"), true)
                @Assert(contains(firstResponse, "content-length: 7"), true)
                @Assert(contains(firstResponse, "\r\n\r\n1:abcde"), true)
                @Assert(contains(firstResponse, "connection: close"), false)

                socket.write(
                    "GET /shell-chunked-trailer-declaration-partial-match-multi-trailer-lines-keepalive?turn=2 HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n".toArray()
                )
                let secondResponse = readSocketServerEngineShellResponseWire(socket)
                @Assert(contains(secondResponse, "HTTP/1.1 200 OK"), true)
                @Assert(contains(secondResponse, "x-shell-chunked-trailer-declaration-partial-match-multi-trailer-lines-keepalive: 1"), true)
                @Assert(contains(secondResponse, "\r\n\r\n2:done"), true)
                @Assert(contains(secondResponse, "connection: close"), true)
            } finally {
                if (!socket.isClosed()) {
                    socket.close()
                }
            }

            let _ = serverFuture.get(Duration.second * 5)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellCanServeTwoSequentialConnectionsWhenAcceptLimitIsSet(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.get("/shell-accept-loop", { ctx =>
                let turn = ctx.queryFromUrl("turn") ?? ""
                let _ = ctx
                    .setHeader("x-shell-accept-loop", "1")
                    .sendString(turn)
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38126))
            }
            waitForShellReady(app, UInt16(38126))

            let firstResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38126),
                "GET /shell-accept-loop?turn=1 HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let secondResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38126),
                "GET /shell-accept-loop?turn=2 HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(firstResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(firstResponseText, "x-shell-accept-loop: 1"), true)
            @Assert(contains(firstResponseText, "\r\n\r\n1"), true)
            @Assert(contains(secondResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(secondResponseText, "x-shell-accept-loop: 1"), true)
            @Assert(contains(secondResponseText, "\r\n\r\n2"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellRejectsInvalidAcceptLimitEnvWithStartupFailure(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "not-a-positive-integer")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())

            app.listen("127.0.0.1", UInt16(38127))

            match (app.lastServerStartupObserveEvent()) {
                case Some(event) =>
                    @Assert(event.phase, "failed")
                    @Assert(contains(event.message, acceptLimitEnv), true)
                    @Assert(contains(event.message, "positive decimal integer"), true)
                case None => @Fail("expected invalid accept-limit env to produce startup failure event")
            }
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellBadRequestTurnContainment(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.get("/shell-turn-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-containment", "1")
                    .sendString("containment-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38128))
            }
            waitForShellReady(app, UInt16(38128))

            // first turn: send a malformed request (incomplete HTTP head) then close
            let badSocket = TcpSocket(IPSocketAddress.parse("127.0.0.1:38128"))
            badSocket.connect()
            try {
                badSocket.write("GARBAGE\r\n".toArray())
                // close without sending a complete request head — the server-side
                // readSocketServerEngineShellRequestWire loop returns the partial
                // bytes when read returns 0, and openSocketServerEngineShellRequest
                // throws because they don't form a valid HTTP/1.1 request head
            } finally {
                if (!badSocket.isClosed()) {
                    badSocket.close()
                }
            }

            // second turn: send a valid cleartext H1 request — must succeed
            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38128),
                "GET /shell-turn-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 14"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "containment-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellContainsUnsupportedVersionRequestHead(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.get("/shell-unsupported-version-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-unsupported-version-containment", "1")
                    .sendString("unsupported-version-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38147))
            }
            waitForShellReady(app, UInt16(38147))

            let badSocket = TcpSocket(IPSocketAddress.parse("127.0.0.1:38147"))
            badSocket.connect()
            try {
                badSocket.write("GET /old HTTP/1.0\r\nHost: example.com\r\n\r\n".toArray())
            } finally {
                if (!badSocket.isClosed()) {
                    badSocket.close()
                }
            }

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38147),
                "GET /shell-unsupported-version-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-unsupported-version-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 22"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "unsupported-version-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellContainsRejectedBodyPlanRequestHead(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.get("/shell-body-plan-rejection-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-body-plan-rejection-containment", "1")
                    .sendString("body-plan-rejection-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38148))
            }
            waitForShellReady(app, UInt16(38148))

            let badSocket = TcpSocket(IPSocketAddress.parse("127.0.0.1:38148"))
            badSocket.connect()
            try {
                badSocket.write(
                    (
                        "POST /bad-body-plan HTTP/1.1\r\n" +
                        "Host: example.com\r\n" +
                        "Content-Length: 3\r\n" +
                        "Transfer-Encoding: chunked\r\n\r\n"
                    ).toArray()
                )
            } finally {
                if (!badSocket.isClosed()) {
                    badSocket.close()
                }
            }

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38148),
                "GET /shell-body-plan-rejection-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-body-plan-rejection-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 22"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "body-plan-rejection-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellContainsUnsupportedTransferEncodingRequestHead(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.get("/shell-unsupported-transfer-encoding-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-unsupported-transfer-encoding-containment", "1")
                    .sendString("unsupported-transfer-encoding-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38149))
            }
            waitForShellReady(app, UInt16(38149))

            let badSocket = TcpSocket(IPSocketAddress.parse("127.0.0.1:38149"))
            badSocket.connect()
            try {
                badSocket.write(
                    (
                        "POST /bad-transfer-encoding HTTP/1.1\r\n" +
                        "Host: example.com\r\n" +
                        "Transfer-Encoding: gzip\r\n\r\n"
                    ).toArray()
                )
            } finally {
                if (!badSocket.isClosed()) {
                    badSocket.close()
                }
            }

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38149),
                "GET /shell-unsupported-transfer-encoding-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-unsupported-transfer-encoding-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 32"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "unsupported-transfer-encoding-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellContainsConflictingContentLengthRequestHead(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.get("/shell-conflicting-content-length-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-conflicting-content-length-containment", "1")
                    .sendString("conflicting-content-length-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38150))
            }
            waitForShellReady(app, UInt16(38150))

            let badSocket = TcpSocket(IPSocketAddress.parse("127.0.0.1:38150"))
            badSocket.connect()
            try {
                badSocket.write(
                    (
                        "POST /bad-content-length HTTP/1.1\r\n" +
                        "Host: example.com\r\n" +
                        "Content-Length: 4\r\n" +
                        "Content-Length: 5\r\n\r\n"
                    ).toArray()
                )
            } finally {
                if (!badSocket.isClosed()) {
                    badSocket.close()
                }
            }

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38150),
                "GET /shell-conflicting-content-length-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-conflicting-content-length-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 29"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "conflicting-content-length-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellContainsInvalidContentLengthRequestHead(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.get("/shell-invalid-content-length-containment", { ctx =>
                let _ = ctx
                    .setHeader("x-shell-invalid-content-length-containment", "1")
                    .sendString("invalid-content-length-ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38151))
            }
            waitForShellReady(app, UInt16(38151))

            let badSocket = TcpSocket(IPSocketAddress.parse("127.0.0.1:38151"))
            badSocket.connect()
            try {
                badSocket.write(
                    (
                        "POST /bad-content-length HTTP/1.1\r\n" +
                        "Host: example.com\r\n" +
                        "Content-Length: nope\r\n\r\n"
                    ).toArray()
                )
            } finally {
                if (!badSocket.isClosed()) {
                    badSocket.close()
                }
            }

            let validResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38151),
                "GET /shell-invalid-content-length-containment HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(validResponseText, "HTTP/1.1 200 OK"), true)
            @Assert(contains(validResponseText, "x-shell-invalid-content-length-containment: 1"), true)
            @Assert(contains(validResponseText, "content-length: 25"), true)
            @Assert(contains(validResponseText, "connection: close"), true)
            @Assert(contains(validResponseText, "invalid-content-length-ok"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellSuppressesBodyForHeadResponse(): Unit {
        let app = App(config: Config(enableTlsPrecheck: false))
        app.serverEngine(SocketServerEngineShell())
        app.head("/shell-head", { ctx =>
            let _ = ctx
                .setHeader("x-shell-head", "1")
                .sendString("shell-head-ok")
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", UInt16(38129))
        }
        waitForShellReady(app, UInt16(38129))

        let responseText = runSocketServerEngineShellClient(
            "127.0.0.1",
            UInt16(38129),
            "HEAD /shell-head HTTP/1.1\r\nHost: example.com\r\n\r\n"
        )
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(contains(responseText, "HTTP/1.1 200 OK"), true)
        @Assert(contains(responseText, "content-type: text/plain; charset=utf-8"), true)
        @Assert(contains(responseText, "x-shell-head: 1"), true)
        @Assert(contains(responseText, "content-length: 13"), true)
        @Assert(contains(responseText, "connection: close"), true)
        @Assert(contains(responseText, "shell-head-ok"), false)
        @Assert(httpPayloadSizeAfterHeaderTerminator(responseText), 0)
    }

    @TestCase
    public func testSocketServerEngineShellSuppressesBodyFor204Status(): Unit {
        let app = App(config: Config(enableTlsPrecheck: false))
        app.serverEngine(SocketServerEngineShell())
        app.get("/shell-204", { ctx =>
            let _ = ctx
                .setHeader("x-shell-204", "1")
                .status(204)
                .sendString("should-not-appear")
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", UInt16(38130))
        }
        waitForShellReady(app, UInt16(38130))

        let responseText = runSocketServerEngineShellClient(
            "127.0.0.1",
            UInt16(38130),
            "GET /shell-204 HTTP/1.1\r\nHost: example.com\r\n\r\n"
        )
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(contains(responseText, "HTTP/1.1 204 No Content"), true)
        @Assert(contains(responseText, "x-shell-204: 1"), true)
        @Assert(contains(responseText, "content-length"), false)
        @Assert(contains(responseText, "transfer-encoding"), false)
        @Assert(contains(responseText, "should-not-appear"), false)
        @Assert(httpPayloadSizeAfterHeaderTerminator(responseText), 0)
    }

    @TestCase
    public func testSocketServerEngineShellSuppressesBodyFor304Status(): Unit {
        let app = App(config: Config(enableTlsPrecheck: false))
        app.serverEngine(SocketServerEngineShell())
        app.get("/shell-304", { ctx =>
            let _ = ctx
                .setHeader("x-shell-304", "1")
                .status(304)
                .sendString("should-not-appear")
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", UInt16(38131))
        }
        waitForShellReady(app, UInt16(38131))

        let responseText = runSocketServerEngineShellClient(
            "127.0.0.1",
            UInt16(38131),
            "GET /shell-304 HTTP/1.1\r\nHost: example.com\r\n\r\n"
        )
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(contains(responseText, "HTTP/1.1 304 Not Modified"), true)
        @Assert(contains(responseText, "x-shell-304: 1"), true)
        @Assert(contains(responseText, "content-length"), false)
        @Assert(contains(responseText, "transfer-encoding"), false)
        @Assert(contains(responseText, "should-not-appear"), false)
        @Assert(httpPayloadSizeAfterHeaderTerminator(responseText), 0)
    }

    @TestCase
    public func testSocketServerEngineShellRejectsInformationalFinalResponse(): Unit {
        let app = App(config: Config(enableTlsPrecheck: false))
        app.serverEngine(SocketServerEngineShell())
        app.get("/shell-1xx-final", { ctx =>
            let _ = ctx.status(100).sendString("should-not-appear")
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", UInt16(38145))
        }
        waitForShellReady(app, UInt16(38145))

        let responseText = runSocketServerEngineShellClient(
            "127.0.0.1",
            UInt16(38145),
            "GET /shell-1xx-final HTTP/1.1\r\nHost: example.com\r\n\r\n"
        )
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(contains(responseText, "HTTP/1.1 500 Internal Server Error"), true)
        @Assert(contains(responseText, "should-not-appear"), false)
        @Assert(contains(responseText, "HTTP/1.1 100 Continue"), false)
        @Assert(contains(responseText, "content-length: 21"), true)
        @Assert(contains(responseText, "connection: close"), true)
    }

    @TestCase
    public func testSocketServerEngineShellRejectsInvalidFinalStatusRange(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.get("/shell-invalid-final-low", { ctx =>
                let _ = ctx.status(99).sendString("low-should-not-appear")
            })
            app.get("/shell-invalid-final-high", { ctx =>
                let _ = ctx.status(1000).sendString("high-should-not-appear")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38146))
            }
            waitForShellReady(app, UInt16(38146))

            let lowResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38146),
                "GET /shell-invalid-final-low HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let highResponseText = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38146),
                "GET /shell-invalid-final-high HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(lowResponseText, "HTTP/1.1 500 Internal Server Error"), true)
            @Assert(contains(lowResponseText, "low-should-not-appear"), false)
            @Assert(contains(lowResponseText, "HTTP/1.1 99"), false)
            @Assert(contains(highResponseText, "HTTP/1.1 500 Internal Server Error"), true)
            @Assert(contains(highResponseText, "high-should-not-appear"), false)
            @Assert(contains(highResponseText, "HTTP/1.1 1000"), false)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellSuppressesKnownLengthStreamForHeadResponse(): Unit {
        let tracked = SocketServerEngineShellStreamTrackingInput("stream-head-should-not-appear".toArray())
        let app = App(config: Config(enableTlsPrecheck: false))
        app.serverEngine(SocketServerEngineShell())
        app.head("/shell-head-stream", { ctx =>
            let _ = ctx
                .setHeader("x-shell-head-stream", "1")
                .sendStream(
                    tracked,
                    contentType: "application/octet-stream",
                    contentLength: Some(Int64(29))
                )
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", UInt16(38142))
        }
        waitForShellReady(app, UInt16(38142))

        let responseText = runSocketServerEngineShellClient(
            "127.0.0.1",
            UInt16(38142),
            "HEAD /shell-head-stream HTTP/1.1\r\nHost: example.com\r\n\r\n"
        )
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(contains(responseText, "HTTP/1.1 200 OK"), true)
        @Assert(contains(responseText, "content-type: application/octet-stream"), true)
        @Assert(contains(responseText, "x-shell-head-stream: 1"), true)
        @Assert(contains(responseText, "content-length: 29"), true)
        @Assert(contains(responseText, "transfer-encoding"), false)
        @Assert(contains(responseText, "stream-head-should-not-appear"), false)
        @Assert(httpPayloadSizeAfterHeaderTerminator(responseText), 0)
        @Assert(tracked.closed, true)
        @Assert(tracked.bytesRead(), Int64(0))
    }

    @TestCase
    public func testSocketServerEngineShellSuppressesKnownLengthStreamFor204Status(): Unit {
        let tracked = SocketServerEngineShellStreamTrackingInput("stream-204-should-not-appear".toArray())
        let app = App(config: Config(enableTlsPrecheck: false))
        app.serverEngine(SocketServerEngineShell())
        app.get("/shell-204-stream", { ctx =>
            let _ = ctx
                .setHeader("x-shell-204-stream", "1")
                .status(204)
                .sendStream(
                    tracked,
                    contentType: "application/octet-stream",
                    contentLength: Some(Int64(28))
                )
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", UInt16(38143))
        }
        waitForShellReady(app, UInt16(38143))

        let responseText = runSocketServerEngineShellClient(
            "127.0.0.1",
            UInt16(38143),
            "GET /shell-204-stream HTTP/1.1\r\nHost: example.com\r\n\r\n"
        )
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(contains(responseText, "HTTP/1.1 204 No Content"), true)
        @Assert(contains(responseText, "x-shell-204-stream: 1"), true)
        @Assert(contains(responseText, "content-length"), false)
        @Assert(contains(responseText, "transfer-encoding"), false)
        @Assert(contains(responseText, "stream-204-should-not-appear"), false)
        @Assert(httpPayloadSizeAfterHeaderTerminator(responseText), 0)
        @Assert(tracked.closed, true)
        @Assert(tracked.bytesRead(), Int64(28))
    }

    @TestCase
    public func testSocketServerEngineShellSuppressesChunkedStreamFor304Status(): Unit {
        let tracked = SocketServerEngineShellStreamTrackingInput("stream-304-should-not-appear".toArray())
        let app = App(config: Config(enableTlsPrecheck: false))
        app.serverEngine(SocketServerEngineShell())
        app.get("/shell-304-stream", { ctx =>
            let _ = ctx
                .setHeader("x-shell-304-stream", "1")
                .status(304)
                .sendStream(
                    tracked,
                    contentType: "application/octet-stream"
                )
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", UInt16(38144))
        }
        waitForShellReady(app, UInt16(38144))

        let responseText = runSocketServerEngineShellClient(
            "127.0.0.1",
            UInt16(38144),
            "GET /shell-304-stream HTTP/1.1\r\nHost: example.com\r\n\r\n"
        )
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(contains(responseText, "HTTP/1.1 304 Not Modified"), true)
        @Assert(contains(responseText, "x-shell-304-stream: 1"), true)
        @Assert(contains(responseText, "content-length"), false)
        @Assert(contains(responseText, "transfer-encoding"), false)
        @Assert(contains(responseText, "stream-304-should-not-appear"), false)
        @Assert(httpPayloadSizeAfterHeaderTerminator(responseText), 0)
        @Assert(tracked.closed, true)
        @Assert(tracked.bytesRead(), Int64(28))
    }

    @TestCase
    public func testSocketServerEngineShellServesTwoTurnsOnSameSocketWithExplicitKeepAlive(): Unit {
        let app = App(config: Config(enableTlsPrecheck: false))
        app.serverEngine(SocketServerEngineShell())
        app.get("/shell-keepalive", { ctx =>
            let turn = ctx.queryFromUrl("turn") ?? ""
            let _ = ctx
                .setHeader("x-shell-keepalive", "1")
                .sendString(turn)
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", UInt16(38132))
        }
        waitForShellReady(app, UInt16(38132))

        let socket = TcpSocket(IPSocketAddress.parse("127.0.0.1:38132"))
        socket.connect()
        try {
            // First request: explicit keep-alive
            socket.write(
                "GET /shell-keepalive?turn=1 HTTP/1.1\r\nHost: example.com\r\nConnection: keep-alive\r\n\r\n".toArray()
            )
            let firstResponse = readSocketServerEngineShellResponseFrame(socket)
            @Assert(contains(firstResponse, "HTTP/1.1 200 OK"), true)
            @Assert(contains(firstResponse, "x-shell-keepalive: 1"), true)
            @Assert(contains(firstResponse, "\r\n\r\n1"), true)
            @Assert(contains(firstResponse, "connection: close"), false)

            // Second request: explicit close
            socket.write(
                "GET /shell-keepalive?turn=2 HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n".toArray()
            )
            let secondResponse = readSocketServerEngineShellResponseWire(socket)
            @Assert(contains(secondResponse, "HTTP/1.1 200 OK"), true)
            @Assert(contains(secondResponse, "x-shell-keepalive: 1"), true)
            @Assert(contains(secondResponse, "\r\n\r\n2"), true)
            @Assert(contains(secondResponse, "connection: close"), true)
        } finally {
            if (!socket.isClosed()) {
                socket.close()
            }
        }

        let _ = serverFuture.get(Duration.second * 5)
    }

    @TestCase
    public func testSocketServerEngineShellKeepsAliveWhenKeepAliveIsConnectionToken(): Unit {
        let app = App(config: Config(enableTlsPrecheck: false))
        app.serverEngine(SocketServerEngineShell())
        app.get("/shell-keepalive-token", { ctx =>
            let turn = ctx.queryFromUrl("turn") ?? ""
            let _ = ctx
                .setHeader("x-shell-keepalive-token", "1")
                .sendString(turn)
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", UInt16(38133))
        }
        waitForShellReady(app, UInt16(38133))

        let socket = TcpSocket(IPSocketAddress.parse("127.0.0.1:38133"))
        socket.connect()
        try {
            socket.write(
                "GET /shell-keepalive-token?turn=1 HTTP/1.1\r\nHost: example.com\r\nConnection: upgrade, Keep-Alive\r\n\r\n".toArray()
            )
            let firstResponse = readSocketServerEngineShellResponseFrame(socket)
            @Assert(contains(firstResponse, "HTTP/1.1 200 OK"), true)
            @Assert(contains(firstResponse, "x-shell-keepalive-token: 1"), true)
            @Assert(contains(firstResponse, "\r\n\r\n1"), true)
            @Assert(contains(firstResponse, "connection: close"), false)

            socket.write(
                "GET /shell-keepalive-token?turn=2 HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n".toArray()
            )
            let secondResponse = readSocketServerEngineShellResponseWire(socket)
            @Assert(contains(secondResponse, "HTTP/1.1 200 OK"), true)
            @Assert(contains(secondResponse, "x-shell-keepalive-token: 1"), true)
            @Assert(contains(secondResponse, "\r\n\r\n2"), true)
            @Assert(contains(secondResponse, "connection: close"), true)
        } finally {
            if (!socket.isClosed()) {
                socket.close()
            }
        }

        let _ = serverFuture.get(Duration.second * 5)
    }

    @TestCase
    public func testSocketServerEngineShellClosesWhenConnectionCloseTokenIsPresent(): Unit {
        let app = App(config: Config(enableTlsPrecheck: false))
        app.serverEngine(SocketServerEngineShell())
        app.get("/shell-keepalive-close-token", { ctx =>
            let _ = ctx
                .setHeader("x-shell-keepalive-close-token", "1")
                .sendString("close-wins")
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", UInt16(38134))
        }
        waitForShellReady(app, UInt16(38134))

        let responseText = runSocketServerEngineShellClient(
            "127.0.0.1",
            UInt16(38134),
            "GET /shell-keepalive-close-token HTTP/1.1\r\nHost: example.com\r\nConnection: keep-alive, close\r\n\r\n"
        )
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(contains(responseText, "HTTP/1.1 200 OK"), true)
        @Assert(contains(responseText, "x-shell-keepalive-close-token: 1"), true)
        @Assert(contains(responseText, "close-wins"), true)
        @Assert(contains(responseText, "connection: close"), true)
    }

    @TestCase
    public func testSocketServerEngineShellKeepsAliveAfterContentLengthBodyStage(): Unit {
        let app = App(config: Config(enableTlsPrecheck: false))
        app.serverEngine(SocketServerEngineShell())
        app.post("/shell-keepalive-body", { ctx =>
            let turn = ctx.queryFromUrl("turn") ?? ""
            let body = ctx.bodyString()
            let _ = ctx
                .setHeader("x-shell-keepalive-body", "1")
                .sendString("${turn}:${body}")
        })
        app.get("/shell-keepalive-body", { ctx =>
            let turn = ctx.queryFromUrl("turn") ?? ""
            let _ = ctx
                .setHeader("x-shell-keepalive-body", "1")
                .sendString("${turn}:done")
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", UInt16(38135))
        }
        waitForShellReady(app, UInt16(38135))

        let socket = TcpSocket(IPSocketAddress.parse("127.0.0.1:38135"))
        socket.connect()
        try {
            socket.write(
                "POST /shell-keepalive-body?turn=1 HTTP/1.1\r\nHost: example.com\r\nContent-Length: 3\r\nConnection: keep-alive\r\n\r\n".toArray()
            )
            sleep(Duration.millisecond * 50)
            socket.write("abc".toArray())
            let firstResponse = readSocketServerEngineShellResponseFrame(socket)
            @Assert(contains(firstResponse, "HTTP/1.1 200 OK"), true)
            @Assert(contains(firstResponse, "x-shell-keepalive-body: 1"), true)
            @Assert(contains(firstResponse, "\r\n\r\n1:abc"), true)
            @Assert(contains(firstResponse, "connection: close"), false)

            socket.write(
                "GET /shell-keepalive-body?turn=2 HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n".toArray()
            )
            let secondResponse = readSocketServerEngineShellResponseWire(socket)
            @Assert(contains(secondResponse, "HTTP/1.1 200 OK"), true)
            @Assert(contains(secondResponse, "x-shell-keepalive-body: 1"), true)
            @Assert(contains(secondResponse, "\r\n\r\n2:done"), true)
            @Assert(contains(secondResponse, "connection: close"), true)
        } finally {
            if (!socket.isClosed()) {
                socket.close()
            }
        }

        let _ = serverFuture.get(Duration.second * 5)
    }

    @TestCase
    public func testSocketServerEngineShellKeepsAliveAfterChunkedBodyStage(): Unit {
        let app = App(config: Config(enableTlsPrecheck: false))
        app.serverEngine(SocketServerEngineShell())
        app.post("/shell-keepalive-chunked", { ctx =>
            let turn = ctx.queryFromUrl("turn") ?? ""
            let body = ctx.bodyString()
            let _ = ctx
                .setHeader("x-shell-keepalive-chunked", "1")
                .sendString("${turn}:${body}")
        })
        app.get("/shell-keepalive-chunked", { ctx =>
            let turn = ctx.queryFromUrl("turn") ?? ""
            let _ = ctx
                .setHeader("x-shell-keepalive-chunked", "1")
                .sendString("${turn}:done")
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", UInt16(38136))
        }
        waitForShellReady(app, UInt16(38136))

        let socket = TcpSocket(IPSocketAddress.parse("127.0.0.1:38136"))
        socket.connect()
        try {
            socket.write(
                "POST /shell-keepalive-chunked?turn=1 HTTP/1.1\r\nHost: example.com\r\nTransfer-Encoding: chunked\r\nConnection: keep-alive\r\n\r\n".toArray()
            )
            sleep(Duration.millisecond * 50)
            socket.write("3\r\nabc\r\n2\r\nde\r\n0\r\n\r\n".toArray())
            let firstResponse = readSocketServerEngineShellResponseFrame(socket)
            @Assert(contains(firstResponse, "HTTP/1.1 200 OK"), true)
            @Assert(contains(firstResponse, "x-shell-keepalive-chunked: 1"), true)
            @Assert(contains(firstResponse, "content-length: 7"), true)
            @Assert(contains(firstResponse, "\r\n\r\n1:abcde"), true)
            @Assert(contains(firstResponse, "connection: close"), false)

            socket.write(
                "GET /shell-keepalive-chunked?turn=2 HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n".toArray()
            )
            let secondResponse = readSocketServerEngineShellResponseWire(socket)
            @Assert(contains(secondResponse, "HTTP/1.1 200 OK"), true)
            @Assert(contains(secondResponse, "x-shell-keepalive-chunked: 1"), true)
            @Assert(contains(secondResponse, "\r\n\r\n2:done"), true)
            @Assert(contains(secondResponse, "connection: close"), true)
        } finally {
            if (!socket.isClosed()) {
                socket.close()
            }
        }

        let _ = serverFuture.get(Duration.second * 5)
    }

    @TestCase
    public func testSocketServerEngineShellContainsBadLaterTurnAfterKeepAlive(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.get("/shell-keepalive-containment", { ctx =>
                let turn = ctx.queryFromUrl("turn") ?? ""
                let _ = ctx
                    .setHeader("x-shell-keepalive-containment", "1")
                    .sendString("${turn}:ok")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", UInt16(38137))
            }
            waitForShellReady(app, UInt16(38137))

            let firstSocket = TcpSocket(IPSocketAddress.parse("127.0.0.1:38137"))
            firstSocket.connect()
            try {
                firstSocket.write(
                    "GET /shell-keepalive-containment?turn=1 HTTP/1.1\r\nHost: example.com\r\nConnection: keep-alive\r\n\r\n".toArray()
                )
                let firstResponse = readSocketServerEngineShellResponseFrame(firstSocket)
                @Assert(contains(firstResponse, "HTTP/1.1 200 OK"), true)
                @Assert(contains(firstResponse, "x-shell-keepalive-containment: 1"), true)
                @Assert(contains(firstResponse, "\r\n\r\n1:ok"), true)
                @Assert(contains(firstResponse, "connection: close"), false)

                firstSocket.write("GARBAGE\r\n".toArray())
                sleep(Duration.millisecond * 50)
            } finally {
                if (!firstSocket.isClosed()) {
                    firstSocket.close()
                }
            }

            let secondResponse = runSocketServerEngineShellClient(
                "127.0.0.1",
                UInt16(38137),
                "GET /shell-keepalive-containment?turn=2 HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = serverFuture.get(Duration.second * 5)

            @Assert(contains(secondResponse, "HTTP/1.1 200 OK"), true)
            @Assert(contains(secondResponse, "x-shell-keepalive-containment: 1"), true)
            @Assert(contains(secondResponse, "\r\n\r\n2:ok"), true)
            @Assert(contains(secondResponse, "connection: close"), true)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellKeepsAliveByDefaultForHttp11(): Unit {
        let app = App(config: Config(enableTlsPrecheck: false))
        app.serverEngine(SocketServerEngineShell())
        app.get("/shell-implicit-keepalive", { ctx =>
            let turn = ctx.queryFromUrl("turn") ?? ""
            let _ = ctx
                .setHeader("x-shell-implicit-keepalive", "1")
                .sendString(turn)
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", UInt16(38138))
        }
        waitForShellReady(app, UInt16(38138))

        let socket = TcpSocket(IPSocketAddress.parse("127.0.0.1:38138"))
        socket.connect()
        try {
            socket.write(
                "GET /shell-implicit-keepalive?turn=1 HTTP/1.1\r\nHost: example.com\r\n\r\n".toArray()
            )
            let firstResponse = readSocketServerEngineShellResponseFrame(socket)
            @Assert(contains(firstResponse, "HTTP/1.1 200 OK"), true)
            @Assert(contains(firstResponse, "x-shell-implicit-keepalive: 1"), true)
            @Assert(contains(firstResponse, "\r\n\r\n1"), true)
            @Assert(contains(firstResponse, "connection: close"), false)

            socket.write(
                "GET /shell-implicit-keepalive?turn=2 HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n".toArray()
            )
            let secondResponse = readSocketServerEngineShellResponseWire(socket)
            @Assert(contains(secondResponse, "HTTP/1.1 200 OK"), true)
            @Assert(contains(secondResponse, "x-shell-implicit-keepalive: 1"), true)
            @Assert(contains(secondResponse, "\r\n\r\n2"), true)
            @Assert(contains(secondResponse, "connection: close"), true)
        } finally {
            if (!socket.isClosed()) {
                socket.close()
            }
        }

        let _ = serverFuture.get(Duration.second * 5)
    }

    @TestCase
    public func testSocketServerEngineShellKeepsAliveAfterKnownLengthStreamedResponse(): Unit {
        let app = App(config: Config(enableTlsPrecheck: false))
        app.serverEngine(SocketServerEngineShell())
        let payload = "streamed-shell-response"
        let tracked = SocketServerEngineShellStreamTrackingInput(payload.toArray())
        app.get("/shell-stream-keepalive", { ctx =>
            let turn = ctx.queryFromUrl("turn") ?? ""
            if (turn == "1") {
                _ = ctx
                    .setHeader("x-shell-stream-keepalive", "1")
                    .sendStream(
                        tracked,
                        contentType: "text/plain; charset=utf-8",
                        contentLength: Some(payload.size)
                    )
            } else {
                let _ = ctx
                    .setHeader("x-shell-stream-keepalive", "1")
                    .sendString("${turn}:done")
            }
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", UInt16(38140))
        }
        waitForShellReady(app, UInt16(38140))

        let socket = TcpSocket(IPSocketAddress.parse("127.0.0.1:38140"))
        socket.connect()
        try {
            socket.write(
                "GET /shell-stream-keepalive?turn=1 HTTP/1.1\r\nHost: example.com\r\nConnection: keep-alive\r\n\r\n".toArray()
            )
            let firstResponse = readSocketServerEngineShellResponseFrame(socket)
            @Assert(contains(firstResponse, "HTTP/1.1 200 OK"), true)
            @Assert(contains(firstResponse, "x-shell-stream-keepalive: 1"), true)
            @Assert(contains(firstResponse, "content-type: text/plain; charset=utf-8"), true)
            @Assert(contains(firstResponse, "content-length: 23"), true)
            @Assert(contains(firstResponse, "transfer-encoding"), false)
            @Assert(contains(firstResponse, "\r\n\r\nstreamed-shell-response"), true)
            @Assert(contains(firstResponse, "connection: close"), false)
            @Assert(tracked.closed, true)

            socket.write(
                "GET /shell-stream-keepalive?turn=2 HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n".toArray()
            )
            let secondResponse = readSocketServerEngineShellResponseWire(socket)
            @Assert(contains(secondResponse, "HTTP/1.1 200 OK"), true)
            @Assert(contains(secondResponse, "x-shell-stream-keepalive: 1"), true)
            @Assert(contains(secondResponse, "\r\n\r\n2:done"), true)
            @Assert(contains(secondResponse, "connection: close"), true)
        } finally {
            if (!socket.isClosed()) {
                socket.close()
            }
        }

        let _ = serverFuture.get(Duration.second * 5)
    }

    @TestCase
    public func testSocketServerEngineShellKeepsAliveAfterChunkedStreamedResponse(): Unit {
        let app = App(config: Config(enableTlsPrecheck: false))
        app.serverEngine(SocketServerEngineShell())
        let payload = "chunked-streamed-shell-response"
        let tracked = SocketServerEngineShellStreamTrackingInput(payload.toArray())
        app.get("/shell-stream-chunked-keepalive", { ctx =>
            let turn = ctx.queryFromUrl("turn") ?? ""
            if (turn == "1") {
                _ = ctx
                    .setHeader("x-shell-stream-chunked-keepalive", "1")
                    .sendStream(
                        tracked,
                        contentType: "text/plain; charset=utf-8"
                    )
            } else {
                let _ = ctx
                    .setHeader("x-shell-stream-chunked-keepalive", "1")
                    .sendString("${turn}:done")
            }
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", UInt16(38141))
        }
        waitForShellReady(app, UInt16(38141))

        let socket = TcpSocket(IPSocketAddress.parse("127.0.0.1:38141"))
        socket.connect()
        try {
            socket.write(
                "GET /shell-stream-chunked-keepalive?turn=1 HTTP/1.1\r\nHost: example.com\r\nConnection: keep-alive\r\n\r\n".toArray()
            )
            let firstResponse = readSocketServerEngineShellResponseFrame(socket)
            @Assert(contains(firstResponse, "HTTP/1.1 200 OK"), true)
            @Assert(contains(firstResponse, "x-shell-stream-chunked-keepalive: 1"), true)
            @Assert(contains(firstResponse, "content-type: text/plain; charset=utf-8"), true)
            @Assert(contains(firstResponse, "content-length"), false)
            @Assert(contains(firstResponse, "transfer-encoding: chunked"), true)
            @Assert(decodeSocketServerEngineShellChunkedBody(firstResponse), payload)
            @Assert(contains(firstResponse, "connection: close"), false)
            @Assert(tracked.closed, true)

            socket.write(
                "GET /shell-stream-chunked-keepalive?turn=2 HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n".toArray()
            )
            let secondResponse = readSocketServerEngineShellResponseWire(socket)
            @Assert(contains(secondResponse, "HTTP/1.1 200 OK"), true)
            @Assert(contains(secondResponse, "x-shell-stream-chunked-keepalive: 1"), true)
            @Assert(contains(secondResponse, "\r\n\r\n2:done"), true)
            @Assert(contains(secondResponse, "connection: close"), true)
        } finally {
            if (!socket.isClosed()) {
                socket.close()
            }
        }

        let _ = serverFuture.get(Duration.second * 5)
    }

    @TestCase
    public func testSocketServerEngineShellClosesAfterBufferedPipelinedBytes(): Unit {
        let app = App(config: Config(enableTlsPrecheck: false))
        app.serverEngine(SocketServerEngineShell())
        app.get("/shell-pipeline-refusal", { ctx =>
            let turn = ctx.queryFromUrl("turn") ?? ""
            let _ = ctx
                .setHeader("x-shell-pipeline-refusal", "1")
                .sendString(turn)
        })

        let serverFuture = spawn {
            app.listen("127.0.0.1", UInt16(38139))
        }
        waitForShellReady(app, UInt16(38139))

        let socket = TcpSocket(IPSocketAddress.parse("127.0.0.1:38139"))
        socket.connect()
        try {
            socket.write(
                (
                    "GET /shell-pipeline-refusal?turn=1 HTTP/1.1\r\nHost: example.com\r\n\r\n" +
                    "GET /shell-pipeline-refusal?turn=2 HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n"
                ).toArray()
            )
            let firstResponse = readSocketServerEngineShellResponseFrame(socket)
            @Assert(contains(firstResponse, "HTTP/1.1 200 OK"), true)
            @Assert(contains(firstResponse, "x-shell-pipeline-refusal: 1"), true)
            @Assert(contains(firstResponse, "\r\n\r\n1"), true)
            @Assert(contains(firstResponse, "\r\n\r\n2"), false)
            @Assert(contains(firstResponse, "connection: close"), true)
        } finally {
            if (!socket.isClosed()) {
                socket.close()
            }
        }

        let _ = serverFuture.get(Duration.second * 5)
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

    func httpPayloadSizeAfterHeaderTerminator(text: String): Int64 {
        let splitIdx = indexOfText(text, "\r\n\r\n")
        if (splitIdx < 0) {
            return -1
        }
        text[splitIdx + 4..text.size].size
    }

    func indexOfText(text: String, target: String): Int64 {
        let a = text.toRuneArray()
        let b = target.toRuneArray()
        if (b.size == 0) {
            return 0
        }
        if (a.size < b.size) {
            return -1
        }
        var i: Int64 = 0
        while (i <= a.size - b.size) {
            var ok = true
            var j: Int64 = 0
            while (j < b.size) {
                if (a[i + j] != b[j]) {
                    ok = false
                    break
                }
                j += 1
            }
            if (ok) {
                return i
            }
            i += 1
        }
        -1
    }

    func readSocketServerEngineShellResponseFrame(socket: TcpSocket): String {
        let out = ArrayList<UInt8>()
        let buf = Array<UInt8>(4096, repeat: 0)
        while (true) {
            let n = socket.read(buf)
            if (n <= 0) {
                break
            }
            appendSocketServerEngineShellBytes(out, buf[..n])
            let text = String.fromUtf8(out.toArray())
            let headerEnd = indexOfText(text, "\r\n\r\n")
            if (headerEnd >= 0) {
                let headerSection = text[..headerEnd]
                let contentLength = parseContentLengthValue(headerSection)
                if (contentLength >= 0) {
                    let bodyStart = headerEnd + 4
                    let currentBodySize = text.size - bodyStart
                    if (currentBodySize < contentLength) {
                        let needed = contentLength - currentBodySize
                        let remainingBuf = Array<UInt8>(needed, repeat: 0)
                        var totalRead: Int64 = 0
                        while (totalRead < needed) {
                            let nr = socket.read(remainingBuf)
                            if (nr <= 0) { break }
                            appendSocketServerEngineShellBytes(out, remainingBuf[..nr])
                            totalRead += nr
                        }
                    } else {
                        let frameEnd = bodyStart + contentLength
                        if (text.size > frameEnd) {
                            return text[..frameEnd]
                        }
                    }
                    break
                }
                if (socketServerEngineShellHeaderHasToken(headerSection, "transfer-encoding", "chunked")) {
                    let bodyStart = headerEnd + 4
                    let chunkedBodyEnd = socketServerEngineShellChunkedBodyEnd(text, bodyStart)
                    if (chunkedBodyEnd >= 0) {
                        let frameEnd = bodyStart + chunkedBodyEnd
                        if (text.size > frameEnd) {
                            return text[..frameEnd]
                        }
                        break
                    }
                } else {
                    break
                }
            }
        }
        String.fromUtf8(out.toArray())
    }

    func socketServerEngineShellHeaderHasToken(
        headerSection: String,
        headerName: String,
        targetToken: String
    ): Bool {
        let lines = headerSection.split("\r\n")
        for (line in lines) {
            let colonPos = indexOfText(line, ":")
            if (colonPos >= 0) {
                let name = line[..colonPos].trimAscii().toAsciiLower()
                if (name == headerName) {
                    let value = line[(colonPos + 1)..].trimAscii()
                    for (token in value.split(",")) {
                        if (token.trimAscii().toAsciiLower() == targetToken) {
                            return true
                        }
                    }
                }
            }
        }
        false
    }

    func socketServerEngineShellChunkedBodyEnd(
        text: String,
        bodyStart: Int64
    ): Int64 {
        var cursor = bodyStart
        while (cursor < text.size) {
            let lineEnd = indexOfText(text[cursor..text.size], "\r\n")
            if (lineEnd < 0) {
                return -1
            }
            let sizeLine = text[cursor..cursor + lineEnd].trimAscii().toAsciiLower()
            let semicolonPos = indexOfText(sizeLine, ";")
            let chunkSizeText = if (semicolonPos >= 0) {
                sizeLine[..semicolonPos].trimAscii()
            } else {
                sizeLine
            }
            let chunkSize = parseSocketServerEngineShellHexInt64(chunkSizeText)
            if (chunkSize < 0) {
                return -1
            }
            cursor += lineEnd + 2
            if (chunkSize == 0) {
                while (cursor < text.size) {
                    let trailerLineEnd = indexOfText(text[cursor..text.size], "\r\n")
                    if (trailerLineEnd < 0) {
                        return -1
                    }
                    if (trailerLineEnd == 0) {
                        return cursor + 2 - bodyStart
                    }
                    cursor += trailerLineEnd + 2
                }
                return -1
            }
            if (cursor + chunkSize + 2 > text.size) {
                return -1
            }
            cursor += chunkSize
            if (text[cursor..cursor + 2] != "\r\n") {
                return -1
            }
            cursor += 2
        }
        -1
    }

    func parseSocketServerEngineShellHexInt64(text: String): Int64 {
        if (text.size == 0) {
            return -1
        }
        var value: Int64 = 0
        for (ch in text.toRuneArray()) {
            let digit = if (ch >= r'0' && ch <= r'9') {
                Int64(UInt32(ch)) - Int64(UInt32(r'0'))
            } else if (ch >= r'a' && ch <= r'f') {
                Int64(UInt32(ch)) - Int64(UInt32(r'a')) + 10
            } else if (ch >= r'A' && ch <= r'F') {
                Int64(UInt32(ch)) - Int64(UInt32(r'A')) + 10
            } else {
                return -1
            }
            value = value * 16 + digit
        }
        value
    }

    func decodeSocketServerEngineShellChunkedBody(rawResponse: String): String {
        let headerEnd = indexOfText(rawResponse, "\r\n\r\n")
        if (headerEnd < 0) {
            throw Exception("invalid chunked response: missing response header terminator")
        }
        let body = rawResponse[headerEnd + 4..rawResponse.size]
        var cursor: Int64 = 0
        var out = ""
        while (cursor < body.size) {
            let lineEnd = indexOfText(body[cursor..body.size], "\r\n")
            if (lineEnd < 0) {
                throw Exception("invalid chunked response: missing chunk size line")
            }
            let sizeLine = body[cursor..cursor + lineEnd].trimAscii().toAsciiLower()
            let semicolonPos = indexOfText(sizeLine, ";")
            let chunkSizeText = if (semicolonPos >= 0) {
                sizeLine[..semicolonPos].trimAscii()
            } else {
                sizeLine
            }
            let chunkSize = parseSocketServerEngineShellHexInt64(chunkSizeText)
            if (chunkSize < 0) {
                throw Exception("invalid chunked response: invalid chunk size")
            }
            cursor += lineEnd + 2
            if (chunkSize == 0) {
                return out
            }
            if (cursor + chunkSize + 2 > body.size) {
                throw Exception("invalid chunked response: chunk overruns body")
            }
            out += body[cursor..cursor + chunkSize]
            cursor += chunkSize
            if (body[cursor..cursor + 2] != "\r\n") {
                throw Exception("invalid chunked response: missing chunk terminator")
            }
            cursor += 2
        }
        throw Exception("invalid chunked response: missing terminal chunk")
    }

    func parseContentLengthValue(headerSection: String): Int64 {
        let lines = headerSection.split("\r\n")
        for (line in lines) {
            let colonPos = indexOfText(line, ":")
            if (colonPos >= 0) {
                let name = line[..colonPos].trimAscii().toAsciiLower()
                let value = line[(colonPos + 1)..].trimAscii()
                if (name == "content-length") {
                    var result: Int64 = 0
                    for (ch in value.toRuneArray()) {
                        if (ch < r'0' || ch > r'9') {
                            return -1
                        }
                        result = result * 10 + (Int64(UInt32(ch)) - Int64(UInt32(r'0')))
                    }
                    return result
                }
            }
        }
        -1
    }
}

class SpyServerEngine <: ServerEngine {
    var listenCalled: Bool = false
    var shutdownCalled: Bool = false
    var readyCalled: Bool = false
    var receivedApp: Bool = false
    var lastAddr: String = ""
    var lastPort: UInt16 = 0
    var lastEnableTlsPrecheck: Bool = true
    var lastTransportTouchpoint: ?ServerTransportTouchpoint = None

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?(() -> Unit)
    ): Unit {
        listenCalled = true
        lastAddr = option.addr
        lastPort = option.port
        lastEnableTlsPrecheck = option.enableTlsPrecheck
        lastTransportTouchpoint = option.transportTouchpoint
        let _ = app
        receivedApp = true
        if (let Some(cb) <- onReady) {
            cb()
            readyCalled = true
        }
    }

    public override func shutdown(): Unit {
        shutdownCalled = true
    }
}

class SocketServerEngineShellStreamTrackingInput <: InputStream & Resource {
    let bytes: Array<UInt8>
    var cursor: Int64 = 0
    public var closed: Bool = false

    init(bytes: Array<UInt8>) {
        this.bytes = bytes
    }

    public override func read(outBuf: Array<Byte>): Int64 {
        if (closed || cursor >= bytes.size || outBuf.size == 0) {
            return 0
        }
        let remaining = bytes.size - cursor
        let readLen = if (remaining < outBuf.size) { remaining } else { outBuf.size }
        var i: Int64 = 0
        while (i < readLen) {
            outBuf[i] = bytes[cursor + i]
            i += 1
        }
        cursor += readLen
        readLen
    }

    public func close(): Unit {
        closed = true
    }

    public func isClosed(): Bool {
        closed
    }

    public func bytesRead(): Int64 {
        cursor
    }
}

func waitForShellReady(app: App, port: UInt16): Unit {
    var attempts: Int64 = 0
    while (attempts < 100) {
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                if (event.phase == "ready" && event.port == port) {
                    return
                }
            case None => ()
        }
        sleep(Duration.millisecond * 10)
        attempts += 1
    }
    @Fail("timed out waiting for socket server engine shell startup observe event")
}

func runSocketServerEngineShellClient(
    host: String,
    port: UInt16,
    requestWire: String
): String {
    let socket = TcpSocket(IPSocketAddress.parse("${host}:${port}"))
    socket.connect()
    try {
        socket.write(socketServerEngineShellOneShotRequestWire(requestWire).toArray())
        readSocketServerEngineShellResponseWire(socket)
    } finally {
        if (!socket.isClosed()) {
            socket.close()
        }
    }
}

func runSocketServerEngineShellClientWithSplitBody(
    host: String,
    port: UInt16,
    requestHeadWire: String,
    requestBodyWire: String
): String {
    let socket = TcpSocket(IPSocketAddress.parse("${host}:${port}"))
    socket.connect()
    try {
        socket.write(socketServerEngineShellOneShotRequestWire(requestHeadWire).toArray())
        sleep(Duration.millisecond * 50)
        socket.write(requestBodyWire.toArray())
        readSocketServerEngineShellResponseWire(socket)
    } finally {
        if (!socket.isClosed()) {
            socket.close()
        }
    }
}

func socketServerEngineShellOneShotRequestWire(requestWire: String): String {
    let lower = requestWire.toAsciiLower()
    if (socketServerEngineShellTestIndexOfText(lower, "\r\nconnection:") >= 0) {
        return requestWire
    }
    let headerEnd = socketServerEngineShellTestIndexOfText(requestWire, "\r\n\r\n")
    if (headerEnd < 0) {
        return requestWire
    }
    "${requestWire[..headerEnd]}\r\nConnection: close${requestWire[headerEnd..]}"
}

func socketServerEngineShellTestIndexOfText(text: String, target: String): Int64 {
    let a = text.toRuneArray()
    let b = target.toRuneArray()
    if (b.size == 0) {
        return 0
    }
    if (a.size < b.size) {
        return -1
    }
    var i: Int64 = 0
    while (i <= a.size - b.size) {
        var ok = true
        var j: Int64 = 0
        while (j < b.size) {
            if (a[i + j] != b[j]) {
                ok = false
                break
            }
            j += 1
        }
        if (ok) {
            return i
        }
        i += 1
    }
    -1
}

func readSocketServerEngineShellResponseWire(socket: TcpSocket): String {
    let out = ArrayList<UInt8>()
    let buf = Array<UInt8>(4096, repeat: 0)
    while (true) {
        let n = socket.read(buf)
        if (n <= 0) {
            break
        }
        appendSocketServerEngineShellBytes(out, buf[..n])
    }
    String.fromUtf8(out.toArray())
}

func appendSocketServerEngineShellBytes(out: ArrayList<UInt8>, bytes: Array<UInt8>): Unit {
    for (b in bytes) {
        out.add(b)
    }
}

class TouchpointOverrideServerEngine <: ServerEngine & ServerEngineTransportTouchpointOverride {
    var lastTransportTouchpoint: ?ServerTransportTouchpoint = None

    public override func overrideTransportTouchpoint(
        addr: String,
        port: UInt16,
        tlsEnabled: Bool,
        baseTouchpoint: ServerTransportTouchpoint
    ): ServerTransportTouchpoint {
        let _ = addr
        let _ = port
        let _ = tlsEnabled
        ServerTransportTouchpoint(
            "ignite-custom-engine",
            baseTouchpoint.blockedCandidates,
            "ignite-custom-engine",
            "custom_engine_selected",
            baseTouchpoint.providerId,
            "opt-in-engine-custom",
            "experimental",
            baseTouchpoint.tlsEnabled,
            "engine_identity_override"
        )
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?(() -> Unit)
    ): Unit {
        let _ = app
        lastTransportTouchpoint = option.transportTouchpoint
        if (let Some(cb) <- onReady) {
            cb()
        }
    }

    public override func shutdown(): Unit {}
}
