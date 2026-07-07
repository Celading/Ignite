package ignite.tests

import ignite.*
import std.collection.ArrayList
import std.env.{removeVariable, setVariable}
import std.fs.exists
import std.io.InputStream
import std.net.{IPSocketAddress, TcpServerSocket, TcpSocket}
import stdx.net.http.{HttpContext, HttpHeaders, WebSocket}
import stdx.encoding.json.stream.JsonWriter as StdxJsonWriter
import jinguissl.contract.ContractErrorCode
import jinguissl.live.{
    ContractAcceptedTransportDescriptor,
    ContractTlsRecordChannel,
    ContractTlsRecordContentType,
    contractTls13CreateClientRecordChannel,
    contractTls13BuildHttpClientHelloX25519
}

let ENGINE_TLS_CERT_A = "_helper/testdata/tls/server-cert-a.pem"
let ENGINE_TLS_KEY_A = "_helper/testdata/tls/server-key-a.pem"

@Test
public class ServerEngineAbstractionTestSuite {
    @TestCase
    public func testDefaultConfigSelectsNativeH1ServerEngineForCleartext(): Unit {
        let app = App(config: Config(enableNetworkChangeNotice: false))
        app.get("/engine-default", { ctx =>
            _ = ctx.sendString("native-default-ok")
        })

        let response = app.handleForTest("GET", "/engine-default")

        @Assert(response.status, UInt16(200))
        @Assert(response.body, "native-default-ok")
        match (app.lastServerTransportTouchpoint()) {
            case Some(touchpoint) =>
                @Assert(touchpoint.selectedBackend, "ignite-socket-server-shell")
                @Assert(touchpoint.publicPath, "native-h1-default")
                @Assert(touchpoint.riskLevel, "default")
                @Assert(touchpoint.fallbackReason, "cleartext_h1_default_native")
            case None => @Fail("expected default native H1 transport touchpoint")
        }
    }

    @TestCase
    public func testConfigOptInSelectsNativeH1ServerEngineForCleartext(): Unit {
        let app = App(config: Config(
            enableNetworkChangeNotice: false,
            serverPreferredBackendHint: "native-h1",
            allowExperimentalServerBackend: true
        ))
        app.get("/engine-native", { ctx =>
            _ = ctx.sendString("native-opt-in-ok")
        })

        let response = app.handleForTest("GET", "/engine-native")

        @Assert(response.status, UInt16(200))
        @Assert(response.body, "native-opt-in-ok")
        match (app.lastServerTransportTouchpoint()) {
            case Some(touchpoint) =>
                @Assert(touchpoint.selectedBackend, "ignite-socket-server-shell")
                @Assert(touchpoint.publicPath, "opt-in-engine-shell")
                @Assert(touchpoint.riskLevel, "experimental")
                @Assert(touchpoint.fallbackReason, "cleartext_h1_first_runnable")
            case None => @Fail("expected native H1 transport touchpoint")
        }
    }

    @TestCase
    public func testStdxBackendHintKeepsRollbackServerEngineSelection(): Unit {
        let app = App(config: Config(
            enableNetworkChangeNotice: false,
            serverPreferredBackendHint: "stdx-default",
            allowExperimentalServerBackend: false
        ))
        app.get("/engine-stdx-rollback", { ctx =>
            _ = ctx.sendString("stdx-rollback-ok")
        })

        let response = app.handleForTest("GET", "/engine-stdx-rollback")

        @Assert(response.status, UInt16(200))
        @Assert(response.body, "stdx-rollback-ok")
        match (app.lastServerTransportTouchpoint()) {
            case Some(touchpoint) =>
                @Assert(touchpoint.selectedBackend, "stdx-http-server")
                @Assert(touchpoint.publicPath, "stable-default")
            case None => @Fail("expected stdx transport touchpoint when rollback hint is set")
        }
    }

    @TestCase
    public func testConfigOptInDoesNotSelectNativeH1ServerEngineWhenTlsConfigured(): Unit {
        let app = App(config: Config(
            enableNetworkChangeNotice: false,
            tlsCertFile: "missing-native-h1-cert.pem",
            tlsKeyFile: "missing-native-h1-key.pem",
            serverPreferredBackendHint: "native-h1",
            allowExperimentalServerBackend: true
        ))

        app.listen("127.0.0.1", UInt16(38123))

        match (app.lastServerTransportTouchpoint()) {
            case Some(touchpoint) =>
                @Assert(touchpoint.selectedBackend, "stdx-http-server")
                @Assert(touchpoint.publicPath, "stable-default")
            case None => @Fail("expected TLS fallback stdx transport touchpoint")
        }
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "failed")
                @Assert(event.tlsEnabled, true)
            case None => @Fail("expected TLS startup failure observe event")
        }
    }

    @TestCase
    public func testSocketServerEngineShellDirectTlsListenServesAcceptedTransportH2Fixture(): Unit {
        let clientChannelProbe = NativeTlsLiveIngressClientChannelProbe()
        let routeProbe = NativeTlsLiveIngressRouteProbe()
        let app = App(config: Config(
            enableNetworkChangeNotice: false,
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.get("/native-tls-live-ingress", { ctx =>
            routeProbe.invoked = true
            let _ = ctx
                .setHeader("x-native-tls-live-ingress", "1")
                .sendString("native-tls-live-ingress-ok")
        })
        app.serverEngine(SocketServerEngineShell(
            selectionLabel: "manual-opt-in",
            tlsAcceptedSessionReadyHook: { session =>
                clientChannelProbe.channel = Some(
                    contractTls13CreateClientRecordChannel(
                        session.keyMaterial,
                        algorithm: session.recordChannel.algorithm
                    )
                )
            }
        ))
        let port = reserveServerEngineAbstractionLoopbackPort()
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 3264))
        )
        let clientHelloWire =
            buildServerEngineAbstractionTestTlsRecordWire(
                clientHello.encodedClientHello
            )

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)
        let responseWire =
            runAcceptedTransportTlsHandshakeRequestResponseFirstRecordSocketSinkClient(
                "127.0.0.1",
                port,
                [
                    cloneServerEngineByteWindow(clientHelloWire, 0, 6),
                    cloneServerEngineByteWindow(
                        clientHelloWire,
                        6,
                        clientHelloWire.size - 6
                    )
                ],
                "native shell TLS live ingress request",
                { =>
                    match (clientChannelProbe.channel) {
                        case Some(channel) =>
                            let headerBlockFragment =
                                concatServerEngineAbstractionTestByteArrays([
                                    serverEngineAbstractionTestByteArray([UInt8(0x82)]),
                                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x18)]),
                                    serverEngineAbstractionTestByteArray(
                                        "/native-tls-live-ingress".toArray()
                                    )
                                ])
                            Some(
                                channel.sealFragments(
                                    ContractTlsRecordContentType.ApplicationData,
                                    concatServerEngineAbstractionTestByteArrays([
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            buildServerEngineAbstractionTestH2HeadersPayload(
                                                headerBlockFragment
                                            ),
                                            frameType: UInt8(0x1),
                                            flags: UInt8(0x4),
                                            streamId: 61
                                        ),
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            serverEngineAbstractionTestByteArray(
                                                "live-body".toArray()
                                            ),
                                            frameType: UInt8(0x0),
                                            flags: UInt8(0x1),
                                            streamId: 61
                                        )
                                    ]),
                                    maxFragmentLen: 7
                                )
                            )
                        case None => None
                    }
                },
                writePauseMillis: 20
            )
        let _ = serverFuture.get(Duration.second * 5)

        match (app.lastServerTransportTouchpoint()) {
            case Some(touchpoint) =>
                @Assert(touchpoint.selectedBackend, "ignite-socket-server-shell")
                @Assert(touchpoint.tlsEnabled, true)
            case None => @Fail("expected native shell TLS touchpoint")
        }
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "ready")
                @Assert(event.tlsEnabled, true)
                @Assert(event.scheme, "https")
            case None => @Fail("expected native shell TLS startup ready observe event")
        }
        match (clientChannelProbe.channel) {
            case Some(channel) =>
                let decoded = String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(responseWire)
                        )
                    )
                )
                @Assert(routeProbe.invoked, true)
                @Assert(contains(decoded, "native-tls-live-ingress-ok"), true)
            case None => @Fail("expected native shell TLS session hook")
        }
    }

    @TestCase
    public func testSocketServerEngineShellDirectTlsListenServesSequentialH2TurnsWithSharedHpackState(): Unit {
        let clientChannelProbe = NativeTlsLiveIngressClientChannelProbe()
        let routeProbe = NativeTlsLiveIngressSequentialRouteProbe()
        let app = App(config: Config(
            enableNetworkChangeNotice: false,
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.get("/native-tls-live-ingress-one", { ctx =>
            routeProbe.firstInvoked = true
            routeProbe.firstDynHeader = ctx.header("x-dyn") ?? ""
            let _ = ctx.sendString("first:${routeProbe.firstDynHeader}")
        })
        app.get("/native-tls-live-ingress-two", { ctx =>
            routeProbe.secondInvoked = true
            routeProbe.secondDynHeader = ctx.header("x-dyn") ?? ""
            let _ = ctx.sendString("second:${routeProbe.secondDynHeader}")
        })
        app.serverEngine(SocketServerEngineShell(
            selectionLabel: "manual-opt-in",
            tlsAcceptedSessionReadyHook: { session =>
                clientChannelProbe.channel = Some(
                    contractTls13CreateClientRecordChannel(
                        session.keyMaterial,
                        algorithm: session.recordChannel.algorithm
                    )
                )
            }
        ))
        let port = reserveServerEngineAbstractionLoopbackPort()
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 3296))
        )
        let clientHelloWire =
            buildServerEngineAbstractionTestTlsRecordWire(
                clientHello.encodedClientHello
            )

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        var firstDecoded = ""
        var secondDecoded = ""
        let socket = TcpSocket(IPSocketAddress.parse("127.0.0.1:${port}"))
        socket.connect()
        try {
            writeAcceptedTransportSocketWireFragments(
                socket,
                [
                    cloneServerEngineByteWindow(clientHelloWire, 0, 6),
                    cloneServerEngineByteWindow(
                        clientHelloWire,
                        6,
                        clientHelloWire.size - 6
                    )
                ],
                writePauseMillis: 20
            )
            let channel =
                waitForNativeTlsLiveIngressClientChannel(
                    "native shell TLS live ingress sequential H2 channel",
                    clientChannelProbe
                )
            let firstHeaderBlock =
                concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x82)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x04), UInt8(0x1c)]),
                    serverEngineAbstractionTestByteArray(
                        "/native-tls-live-ingress-one".toArray()
                    ),
                    serverEngineAbstractionTestByteArray([UInt8(0x40), UInt8(0x05)]),
                    serverEngineAbstractionTestByteArray("x-dyn".toArray()),
                    serverEngineAbstractionTestByteArray([UInt8(0x03)]),
                    serverEngineAbstractionTestByteArray("one".toArray())
                ])
            writeAcceptedTransportSocketWireFragments(
                socket,
                buildAcceptedTransportTlsH2HeadersPlusDataRequestRecords(
                    channel,
                    firstHeaderBlock,
                    101,
                    "first-body"
                ),
                writePauseMillis: 20
            )
            let firstRecord =
                readAcceptedTransportResponseSocketFirstCompleteRecord(
                    socket,
                    readChunkSize: 3
                )
            firstDecoded =
                String.fromUtf8(channel.openAndReassemble([firstRecord]))

            let secondHeaderBlock =
                concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x82)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x04), UInt8(0x1c)]),
                    serverEngineAbstractionTestByteArray(
                        "/native-tls-live-ingress-two".toArray()
                    ),
                    serverEngineAbstractionTestByteArray([UInt8(0xbe)])
                ])
            writeAcceptedTransportSocketWireFragments(
                socket,
                buildAcceptedTransportTlsH2HeadersPlusDataRequestRecords(
                    channel,
                    secondHeaderBlock,
                    103,
                    "second-body"
                ),
                writePauseMillis: 20
            )
            let secondRecord =
                readAcceptedTransportResponseSocketFirstCompleteRecord(
                    socket,
                    readChunkSize: 3
                )
            secondDecoded =
                String.fromUtf8(channel.openAndReassemble([secondRecord]))
        } finally {
            if (!socket.isClosed()) {
                socket.close()
            }
        }
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(routeProbe.firstInvoked, true)
        @Assert(routeProbe.secondInvoked, true)
        @Assert(routeProbe.firstDynHeader, "one")
        @Assert(routeProbe.secondDynHeader, "one")
        @Assert(firstDecoded, "first:one")
        @Assert(secondDecoded, "second:one")
    }

    @TestCase
    public func testSocketServerEngineShellDirectTlsListenServesBufferedSecondH2TurnFromCarryover(): Unit {
        let clientChannelProbe = NativeTlsLiveIngressClientChannelProbe()
        let routeProbe = NativeTlsLiveIngressSequentialRouteProbe()
        let app = App(config: Config(
            enableNetworkChangeNotice: false,
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.get("/native-tls-live-ingress-one", { ctx =>
            routeProbe.firstInvoked = true
            routeProbe.firstDynHeader = ctx.header("x-dyn") ?? ""
            let _ = ctx.sendString("first:${routeProbe.firstDynHeader}")
        })
        app.get("/native-tls-live-ingress-two", { ctx =>
            routeProbe.secondInvoked = true
            routeProbe.secondDynHeader = ctx.header("x-dyn") ?? ""
            let _ = ctx.sendString("second:${routeProbe.secondDynHeader}")
        })
        app.serverEngine(SocketServerEngineShell(
            selectionLabel: "manual-opt-in",
            tlsAcceptedSessionReadyHook: { session =>
                clientChannelProbe.channel = Some(
                    contractTls13CreateClientRecordChannel(
                        session.keyMaterial,
                        algorithm: session.recordChannel.algorithm
                    )
                )
            }
        ))
        let port = reserveServerEngineAbstractionLoopbackPort()
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 3328))
        )
        let clientHelloWire =
            buildServerEngineAbstractionTestTlsRecordWire(
                clientHello.encodedClientHello
            )

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        var firstDecoded = ""
        var secondDecoded = ""
        let socket = TcpSocket(IPSocketAddress.parse("127.0.0.1:${port}"))
        socket.connect()
        try {
            writeAcceptedTransportSocketWireFragments(
                socket,
                [
                    cloneServerEngineByteWindow(clientHelloWire, 0, 6),
                    cloneServerEngineByteWindow(
                        clientHelloWire,
                        6,
                        clientHelloWire.size - 6
                    )
                ],
                writePauseMillis: 20
            )
            let channel =
                waitForNativeTlsLiveIngressClientChannel(
                    "native shell TLS live ingress buffered carryover H2 channel",
                    clientChannelProbe
                )
            let firstHeaderBlock =
                concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x82)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x04), UInt8(0x1c)]),
                    serverEngineAbstractionTestByteArray(
                        "/native-tls-live-ingress-one".toArray()
                    ),
                    serverEngineAbstractionTestByteArray([UInt8(0x40), UInt8(0x05)]),
                    serverEngineAbstractionTestByteArray("x-dyn".toArray()),
                    serverEngineAbstractionTestByteArray([UInt8(0x03)]),
                    serverEngineAbstractionTestByteArray("one".toArray())
                ])
            let secondHeaderBlock =
                concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x82)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x04), UInt8(0x1c)]),
                    serverEngineAbstractionTestByteArray(
                        "/native-tls-live-ingress-two".toArray()
                    ),
                    serverEngineAbstractionTestByteArray([UInt8(0xbe)])
                ])
            writeAcceptedTransportSocketWireFragments(
                socket,
                buildAcceptedTransportTlsH2TwoHeadersPlusDataRequestRecords(
                    channel,
                    firstHeaderBlock,
                    111,
                    "first-body",
                    secondHeaderBlock,
                    113,
                    "second-body"
                ),
                writePauseMillis: 0
            )
            let firstRecord =
                readAcceptedTransportResponseSocketFirstCompleteRecord(
                    socket,
                    readChunkSize: 3
                )
            firstDecoded =
                String.fromUtf8(channel.openAndReassemble([firstRecord]))
            let secondRecord =
                readAcceptedTransportResponseSocketFirstCompleteRecord(
                    socket,
                    readChunkSize: 3
                )
            secondDecoded =
                String.fromUtf8(channel.openAndReassemble([secondRecord]))
        } finally {
            if (!socket.isClosed()) {
                socket.close()
            }
        }
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(routeProbe.firstInvoked, true)
        @Assert(routeProbe.secondInvoked, true)
        @Assert(routeProbe.firstDynHeader, "one")
        @Assert(routeProbe.secondDynHeader, "one")
        @Assert(firstDecoded, "first:one")
        @Assert(secondDecoded, "second:one")
    }

    @TestCase
    public func testSocketServerEngineShellStableTlsH2ConnectionEndClassifierDistinguishesCloseFromProtocolErrors(): Unit {
        let eofAfterSuccessMessage =
            "accepted-session accepted-socket fragmented-record-wire headers-plus-data request-turn expected one logical request before socket read ended, bufferedRecordWireBytes=0, bufferedH2FrameWireBytes=0, hasOpenHeaderBlock=false, bufferedHeaderBlockBytes=0, bufferedBodyBytes=0"

        @Assert(
            isSocketServerEngineShellStableTlsH2ConnectionEndError(
                eofAfterSuccessMessage
            ),
            true
        )
        @Assert(
            isSocketServerEngineShellStableTlsH2ConnectionEndError(
                "ConnectionException: Socket is closed."
            ),
            true
        )
        @Assert(
            isSocketServerEngineShellStableTlsH2ConnectionEndError(
                "accepted-session H2 request-turn requires same-stream DATA"
            ),
            false
        )
        @Assert(
            isSocketServerEngineShellStableTlsH2ConnectionEndError(
                "accepted-session H2 request-turn got type=9 streamId=1"
            ),
            false
        )
    }

    @TestCase
    public func testSocketServerEngineShellDirectTlsListenKeepsMalformedSecondH2TurnLoud(): Unit {
        let clientChannelProbe = NativeTlsLiveIngressClientChannelProbe()
        let routeProbe = NativeTlsLiveIngressSequentialRouteProbe()
        let app = App(config: Config(
            enableNetworkChangeNotice: false,
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.get("/native-tls-live-ingress-one", { ctx =>
            routeProbe.firstInvoked = true
            routeProbe.firstDynHeader = ctx.header("x-dyn") ?? ""
            let _ = ctx.sendString("first:${routeProbe.firstDynHeader}")
        })
        app.serverEngine(SocketServerEngineShell(
            selectionLabel: "manual-opt-in",
            tlsAcceptedSessionReadyHook: { session =>
                clientChannelProbe.channel = Some(
                    contractTls13CreateClientRecordChannel(
                        session.keyMaterial,
                        algorithm: session.recordChannel.algorithm
                    )
                )
            }
        ))
        let port = reserveServerEngineAbstractionLoopbackPort()
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 3360))
        )
        let clientHelloWire =
            buildServerEngineAbstractionTestTlsRecordWire(
                clientHello.encodedClientHello
            )

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        var firstDecoded = ""
        var observedServerError = ""
        let socket = TcpSocket(IPSocketAddress.parse("127.0.0.1:${port}"))
        socket.connect()
        try {
            writeAcceptedTransportSocketWireFragments(
                socket,
                [
                    cloneServerEngineByteWindow(clientHelloWire, 0, 6),
                    cloneServerEngineByteWindow(
                        clientHelloWire,
                        6,
                        clientHelloWire.size - 6
                    )
                ],
                writePauseMillis: 20
            )
            let channel =
                waitForNativeTlsLiveIngressClientChannel(
                    "native shell TLS live ingress malformed second H2 channel",
                    clientChannelProbe
                )
            let firstHeaderBlock =
                concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x82)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x04), UInt8(0x1c)]),
                    serverEngineAbstractionTestByteArray(
                        "/native-tls-live-ingress-one".toArray()
                    ),
                    serverEngineAbstractionTestByteArray([UInt8(0x40), UInt8(0x05)]),
                    serverEngineAbstractionTestByteArray("x-dyn".toArray()),
                    serverEngineAbstractionTestByteArray([UInt8(0x03)]),
                    serverEngineAbstractionTestByteArray("one".toArray())
                ])
            writeAcceptedTransportSocketWireFragments(
                socket,
                buildAcceptedTransportTlsH2HeadersPlusDataRequestRecords(
                    channel,
                    firstHeaderBlock,
                    121,
                    "first-body"
                ),
                writePauseMillis: 20
            )
            let firstRecord =
                readAcceptedTransportResponseSocketFirstCompleteRecord(
                    socket,
                    readChunkSize: 3
                )
            firstDecoded =
                String.fromUtf8(channel.openAndReassemble([firstRecord]))

            let malformedSecondHeaderBlock =
                concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x82)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x04), UInt8(0x1c)]),
                    serverEngineAbstractionTestByteArray(
                        "/native-tls-live-ingress-two".toArray()
                    )
                ])
            let malformedSecondRecords = channel.sealFragments(
                ContractTlsRecordContentType.ApplicationData,
                concatServerEngineAbstractionTestByteArrays([
                    buildServerEngineAbstractionTestH2FrameWire(
                        buildServerEngineAbstractionTestH2HeadersPayload(
                            malformedSecondHeaderBlock
                        ),
                        frameType: UInt8(0x1),
                        flags: UInt8(0x4),
                        streamId: 123
                    ),
                    buildServerEngineAbstractionTestH2FrameWire(
                        serverEngineAbstractionTestByteArray(
                            "blocked".toArray()
                        ),
                        frameType: UInt8(0x0),
                        flags: UInt8(0x1),
                        streamId: 125
                    )
                ]),
                maxFragmentLen: 7
            )
            writeAcceptedTransportSocketWireFragments(
                socket,
                malformedSecondRecords,
                writePauseMillis: 20
            )
            try {
                let _ = serverFuture.get(Duration.second * 5)
            } catch (e: Exception) {
                observedServerError = e.message
            }
            if (observedServerError == "") {
                match (app.lastServerStartupObserveEvent()) {
                    case Some(event) =>
                        observedServerError = event.message
                    case None => ()
                }
            }
        } finally {
            if (!socket.isClosed()) {
                socket.close()
            }
        }

        @Assert(routeProbe.firstInvoked, true)
        @Assert(routeProbe.firstDynHeader, "one")
        @Assert(firstDecoded, "first:one")
        @Assert(contains(observedServerError, "requires same-stream DATA"), true)
    }

    @TestCase
    public func testInjectedServerEngineReceivesListenAndShutdown(): Unit {
        let app = App(config: Config(enableTlsPrecheck: false))
        let engine = SpyServerEngine()
        app.serverEngine(engine)

        @Assert(
            serverEngineAbstractionTestKeepJinguiContractLinkAnchor(),
            "BAD_INPUT"
        )
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
    public func testInjectedServerEngineCanConsumeJinguiAcceptedTransportSessionAdapter(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let engine = JinguiAcceptedTransportSessionProbeEngine()
        let observedStatuses = ArrayList<String>()
        let observedCloseReasons = ArrayList<String>()
        app.onJinguiAcceptedTransportSession({ snapshot =>
            observedStatuses.add(snapshot.status)
            observedCloseReasons.add(snapshot.closeReason)
        })
        app.serverEngine(engine)

        app.listen("127.0.0.1", UInt16(38124))

        @Assert(engine.builtRequestAttachSurface, "accepted-socket")
        match (engine.readySnapshot) {
            case Some(snapshot) =>
                @Assert(snapshot.status, "READY")
                @Assert(snapshot.secureSessionReady, true)
                @Assert(snapshot.transport.transportId, "test-accepted-transport")
                @Assert(snapshot.transport.transportKind, "accepted-transport")
                @Assert(snapshot.transport.localEndpoint, "127.0.0.1:443")
                @Assert(snapshot.transport.remoteEndpoint, "127.0.0.1:55443")
                @Assert(snapshot.jinguiAttachResultSnapshot.negotiatedAlpn, "h2")
                @Assert(snapshot.jinguiAttachResultSnapshot.requestedServerName, "www.example.com")
                @Assert(snapshot.jinguiAttachResultSnapshot.secureSessionReady, true)
                @Assert(snapshot.jinguiAttachResultSnapshot.attachSurface, "accepted-transport-session")
                @Assert(snapshot.recordChannelVersion, "TLS1.3")
                @Assert(snapshot.closeReason, "")
            case None => @Fail("expected ready accepted transport/session snapshot")
        }
        match (engine.closedSnapshot) {
            case Some(snapshot) =>
                @Assert(snapshot.status, "CLOSED")
                @Assert(snapshot.secureSessionReady, false)
                @Assert(snapshot.jinguiAttachResultSnapshot.secureSessionReady, false)
                @Assert(snapshot.jinguiAttachResultSnapshot.negotiatedAlpn, "h2")
                @Assert(snapshot.jinguiAttachResultSnapshot.attachSurface, "accepted-transport-session")
                @Assert(snapshot.recordChannelVersion, "TLS1.3")
                @Assert(snapshot.closeReason, "test-close")
            case None => @Fail("expected closed accepted transport/session snapshot")
        }
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "ready")
                @Assert(event.scheme, "https")
                @Assert(event.tlsEnabled, true)
            case None => @Fail("expected startup observe ready event")
        }
        @Assert(observedStatuses.size, 2)
        @Assert(observedStatuses[0], "READY")
        @Assert(observedStatuses[1], "CLOSED")
        @Assert(observedCloseReasons[0], "")
        @Assert(observedCloseReasons[1], "test-close")
        match (app.lastJinguiAcceptedTransportSessionSnapshot()) {
            case Some(snapshot) =>
                @Assert(snapshot.status, "CLOSED")
                @Assert(snapshot.closeReason, "test-close")
                @Assert(snapshot.jinguiAttachResultSnapshot.negotiatedAlpn, "h2")
            case None => @Fail("expected app-side accepted transport/session snapshot")
        }
    }

    @TestCase
    public func testInjectedServerEngineCanConsumeJinguiAcceptedTransportApplicationDataCodec(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let engine = JinguiAcceptedTransportSessionCodecProbeEngine()
        app.serverEngine(engine)

        app.listen("127.0.0.1", UInt16(38126))

        @Assert(engine.clientDecodedText, "server-h2-frame")
        @Assert(engine.serverDecodedText, "client-h2-frame")
        @Assert(engine.clientFragmentCount > 1, true)
        @Assert(engine.serverFragmentCount > 1, true)
        @Assert(
            engine.clientReassembledText,
            "server-fragment-payload-abcdefgh"
        )
        @Assert(
            engine.serverReassembledText,
            "client-fragment-payload-xyz012345"
        )
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "ready")
                @Assert(event.scheme, "https")
            case None => @Fail("expected startup observe ready event")
        }
    }

    @TestCase
    public func testInjectedServerEngineCanBridgeAcceptedTransportApplicationDataIntoH2HeaderBlockIngress(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let engine =
            JinguiAcceptedTransportApplicationDataH2HeaderBlockIngressProbeEngine()
        app.serverEngine(engine)

        app.listen("127.0.0.1", UInt16(38140))

        @Assert(engine.completedHeaderBlockCount, 1)
        @Assert(engine.completedHeaderBlockStreamId, 31)
        @Assert(engine.completedHeaderBlockEndStream, true)
        @Assert(engine.completedHeaderBlockText, "abcdef")
    }

    @TestCase
    public func testInjectedServerEngineRejectsInvalidAcceptedTransportApplicationDataH2HeaderBlockIngress(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let engine =
            JinguiAcceptedTransportApplicationDataH2HeaderBlockIngressRejectProbeEngine()
        app.serverEngine(engine)

        app.listen("127.0.0.1", UInt16(38141))

        @Assert(
            contains(
                engine.observedError,
                "expects CONTINUATION while one header block is open"
            ),
            true
        )
    }

    @TestCase
    public func testInjectedServerEngineCanProjectAcceptedTransportApplicationDataIntoLogicalRequest(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let engine =
            JinguiAcceptedTransportApplicationDataLogicalRequestProjectionProbeEngine()
        app.serverEngine(engine)

        app.listen("127.0.0.1", UInt16(38142))

        @Assert(engine.requestMethod, "GET")
        @Assert(engine.requestPath, "/appdata")
        @Assert(engine.requestUrl, "/appdata?turn=ok")
        @Assert(engine.requestQuery, "turn=ok")
        @Assert(engine.requestVersion, "h2")
        @Assert(engine.requestHost, "api.example.com:9443")
        @Assert(engine.requestMode, "bridge")
        @Assert(engine.requestBody, "payload")
    }

    @TestCase
    public func testInjectedServerEngineRejectsMultipleAcceptedTransportApplicationDataHeaderBlocksForLogicalRequestProjection(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let engine =
            JinguiAcceptedTransportApplicationDataLogicalRequestProjectionRejectProbeEngine()
        app.serverEngine(engine)

        app.listen("127.0.0.1", UInt16(38143))

        @Assert(
            contains(
                engine.observedError,
                "expects exactly one complete H2 header block, got count=2"
            ),
            true
        )
    }

    @TestCase
    public func testInjectedServerEngineCanServeAcceptedTransportApplicationDataBodylessRequestTurn(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.get("/carrier-appdata-turn", { ctx =>
            let turn = ctx.queryFromUrl("turn") ?? ""
            let mode = ctx.header("x-mode") ?? ""
            let _ = ctx
                .setHeader("x-carrier-appdata-turn", "1")
                .sendString(
                    "${ctx.method}|${ctx.path}|${ctx.originalUrl}|${turn}|${mode}"
                )
        })
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportApplicationDataBodylessRequestTurnProbeEngine()
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let responseWire =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(engine.readyStatus, "READY")
        @Assert(
            engine.openResponseSocketWire(responseWire),
            "GET|/carrier-appdata-turn|/carrier-appdata-turn?turn=from-appdata|from-appdata|bridge"
        )
        @Assert(engine.responseStatus, UInt16(200))
        @Assert(
            engine.contentType,
            "text/plain; charset=utf-8"
        )
        @Assert(engine.transferEncoding, "")
        @Assert(engine.socketWriteCount >= 1, true)
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "ready")
                @Assert(event.scheme, "https")
            case None => @Fail("expected startup observe ready event")
        }
    }

    @TestCase
    public func testInjectedServerEngineCanServeAcceptedTransportSocketApplicationDataBodylessRequestTurn(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.get("/carrier-appdata-turn", { ctx =>
            let turn = ctx.queryFromUrl("turn") ?? ""
            let mode = ctx.header("x-mode") ?? ""
            let _ = ctx
                .setHeader("x-socket-bodyless-turn", "1")
                .sendString(
                    "${ctx.method}|${ctx.path}|${ctx.originalUrl}|${turn}|${mode}"
                )
        })
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportSocketApplicationDataBodylessRequestTurnProbeEngine()
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let responseWire =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(engine.readyStatus, "READY")
        @Assert(
            engine.openResponseSocketWire(responseWire),
            "GET|/carrier-appdata-turn|/carrier-appdata-turn?turn=from-appdata|from-appdata|bridge"
        )
        @Assert(engine.responseStatus, UInt16(200))
        @Assert(
            engine.contentType,
            "text/plain; charset=utf-8"
        )
        @Assert(engine.transferEncoding, "")
        @Assert(engine.socketWriteCount >= 1, true)
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "ready")
                @Assert(event.scheme, "https")
            case None => @Fail("expected startup observe ready event")
        }
    }

    @TestCase
    public func testInjectedServerEngineRejectsMultipleAcceptedTransportSocketApplicationDataHeaderBlocksForBodylessRequestTurn(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportSocketApplicationDataBodylessRequestTurnRejectProbeEngine()
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let _ =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(
            contains(
                engine.observedError,
                "expects exactly one complete H2 header block, got count=2"
            ),
            true
        )
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "ready")
                @Assert(event.scheme, "https")
            case None => @Fail("expected startup observe ready event")
        }
    }

    @TestCase
    public func testInjectedServerEngineRejectsMultipleAcceptedTransportApplicationDataHeaderBlocksForBodylessRequestTurn(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportApplicationDataBodylessRequestTurnRejectProbeEngine()
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let _ =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(
            contains(
                engine.observedError,
                "expects exactly one complete H2 header block, got count=2"
            ),
            true
        )
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "ready")
                @Assert(event.scheme, "https")
            case None => @Fail("expected startup observe ready event")
        }
    }

    @TestCase
    public func testInjectedServerEngineCanServeAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataBodylessRequestTurn(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.get("/carrier-captured-bodyless-turn", { ctx =>
            let turn = ctx.queryFromUrl("turn") ?? ""
            let mode = ctx.header("x-mode") ?? ""
            let _ = ctx
                .setHeader("x-captured-bodyless-turn", "1")
                .sendString(
                    "${ctx.method}|${ctx.path}|${ctx.originalUrl}|${turn}|${mode}"
                )
        })
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataBodylessRequestTurnProbeEngine()
        app.serverEngine(engine)

        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 2688))
        )
        let clientHelloWire =
            buildServerEngineAbstractionTestTlsRecordWire(
                clientHello.encodedClientHello
            )

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let responseWire =
            runAcceptedTransportTlsHandshakeRequestResponseSocketSinkClient(
                "127.0.0.1",
                port,
                [
                    cloneServerEngineByteWindow(clientHelloWire, 0, 6),
                    cloneServerEngineByteWindow(clientHelloWire, 6, 10),
                    cloneServerEngineByteWindow(
                        clientHelloWire,
                        16,
                        clientHelloWire.size - 16
                    )
                ],
                "captured-clienthello bodyless request",
                { => Some([]) },
                writePauseMillis: 20
            )
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(engine.readyStatus, "READY")
        @Assert(engine.negotiatedAlpn, "h2")
        @Assert(engine.requestedServerName, "www.example.com")
        @Assert(engine.attachSurface, "accepted-transport-session")
        @Assert(
            engine.openResponseSocketWire(responseWire),
            "GET|/carrier-captured-bodyless-turn|/carrier-captured-bodyless-turn?turn=from-captured|from-captured|bridge"
        )
        @Assert(engine.responseStatus, UInt16(200))
        @Assert(
            engine.contentType,
            "text/plain; charset=utf-8"
        )
        @Assert(engine.transferEncoding, "")
        @Assert(engine.socketWriteCount >= 1, true)
        @Assert(
            engine.transportId,
            "captured-clienthello-bodyless-turn-transport"
        )
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "ready")
                @Assert(event.scheme, "https")
            case None => @Fail("expected startup observe ready event")
        }
    }

    @TestCase
    public func testInjectedServerEngineRejectsAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataBodylessRequestTurnWhenTlsHandshakeDoesNotStartWithClientHelloRecord(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataBodylessRequestTurnRejectProbeEngine()
        app.serverEngine(engine)

        let wrongRecordWire = buildServerEngineAbstractionTestTlsRecordWire(
            serverEngineAbstractionTestByteArray("oops".toArray()),
            contentType: UInt8(0x17)
        )

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        runAcceptedTransportOneWaySocketClient(
            "127.0.0.1",
            port,
            [
                cloneServerEngineByteWindow(
                    wrongRecordWire,
                    0,
                    wrongRecordWire.size
                )
            ]
        )
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(
            contains(
                engine.observedError,
                "expected handshake record contentType=22"
            ),
            true
        )
    }

    @TestCase
    public func testInjectedServerEngineCanEncodeJsonWriterOutputThroughJinguiAcceptedTransportResponseTransportWriter(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let engine = JinguiAcceptedTransportResponseTransportWriterProbeEngine()
        app.serverEngine(engine)

        app.listen("127.0.0.1", UInt16(38127))

        @Assert(engine.encodedRecordCount > 1, true)
        @Assert(engine.totalEncodedBytes > 0, true)
        @Assert(
            engine.clientDecodedJson,
            "{\"kind\":\"response\",\"ok\":true,\"count\":2}"
        )
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "ready")
                @Assert(event.scheme, "https")
            case None => @Fail("expected startup observe ready event")
        }
    }

    @TestCase
    public func testInjectedServerEngineCanSealH2DataFramesThroughAcceptedSocketLifecycleApplicationDataWriter(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let engine =
            JinguiAcceptedTransportH2LifecycleApplicationDataWriterProbeEngine()
        app.serverEngine(engine)

        app.listen("127.0.0.1", reserveServerEngineAbstractionLoopbackPort())

        @Assert(engine.successWriterOpenCalls, 1)
        @Assert(engine.successHandoffAcquisitionCount, 1)
        @Assert(engine.successSocketWriteCount, 2)
        @Assert(engine.successEncodedRecordCount, 2)
        @Assert(engine.successDecodedFrameCount, 2)
        @Assert(engine.successFirstFrameType, UInt8(0x0))
        @Assert(engine.successFirstFrameFlags, UInt8(0x0))
        @Assert(engine.successSecondFrameType, UInt8(0x0))
        @Assert(engine.successSecondFrameFlags, UInt8(0x1))
        @Assert(
            serverEngineAbstractionTestByteArraysEqual(
                engine.successFirstPayload,
                serverEngineAbstractionTestTextBytes("part")
            ),
            true
        )
        @Assert(
            serverEngineAbstractionTestByteArraysEqual(
                engine.successSecondPayload,
                serverEngineAbstractionTestTextBytes("done")
            ),
            true
        )
        @Assert(engine.blockedRejected, true)
        @Assert(engine.blockedWriterOpenCalls, 0)
        @Assert(engine.blockedEncodedRecordCount, 0)
    }

    @TestCase
    public func testInjectedServerEnginePropagatesH2ApplicationDataWriterFailureAndCloseGuard(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let engine =
            JinguiAcceptedTransportH2ApplicationDataFailureCloseGuardProbeEngine()
        app.serverEngine(engine)

        app.listen("127.0.0.1", reserveServerEngineAbstractionLoopbackPort())

        @Assert(engine.failureRejected, true)
        @Assert(
            contains(
                engine.failureMessage,
                "sr107 tls application-data downstream write failed"
            ),
            true
        )
        @Assert(engine.failureWriterOpenCalls, 1)
        @Assert(engine.failureHandoffAcquisitionCount, 1)
        @Assert(engine.failureSocketWriteCount, 1)
        @Assert(engine.failureSinkAttempts, 1)
        @Assert(engine.failureAttemptedEncodedBytes > 0, true)
        @Assert(engine.failureLifecycleClosed, false)

        @Assert(engine.closeGuardFirstCompleted, true)
        @Assert(engine.closeGuardRejected, true)
        @Assert(
            contains(
                engine.closeGuardMessage,
                "accepted transport socket response writer lifecycle is closed: sr107-close"
            ),
            true
        )
        @Assert(engine.closeGuardWriterOpenCalls, 1)
        @Assert(engine.closeGuardHandoffAcquisitionCount, 1)
        @Assert(engine.closeGuardSocketWriteCount, 1)
        @Assert(engine.closeGuardEncodedRecordCount, 1)
        @Assert(engine.closeGuardLifecycleClosed, true)
        @Assert(engine.closeGuardCloseReason, "sr107-close")
    }

    @TestCase
    public func testInjectedServerEngineCanEmitH2DataFramesFromAcceptedSocketApplicationDataResponseWriterTurn(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.get("/h2-appdata-response-turn", { ctx =>
            let mode = ctx.queryFromUrl("mode") ?? ""
            let _ = ctx
                .status(203)
                .setHeader("x-h2-turn", "sr108")
                .sendString("sr108:${ctx.method}:${ctx.path}:${mode}")
        })
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportH2ApplicationDataResponseWriterTurnProbeEngine()
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let responseWire =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let _ = serverFuture.get(Duration.second * 5)
        engine.decodeTurnSocketWire(responseWire)

        @Assert(engine.turnReadyStatus, "READY")
        @Assert(engine.turnResponseStatus, UInt16(203))
        @Assert(engine.turnContentType, "text/plain; charset=utf-8")
        @Assert(engine.turnCustomHeader, "sr108")
        @Assert(engine.turnSocketWriteCount >= 1, true)
        @Assert(engine.turnDecodedFrameCount, 2)
        @Assert(engine.turnHeadersFrameType, UInt8(0x1))
        @Assert(engine.turnHeadersEndHeaders, true)
        @Assert(engine.turnHeadersEndStream, false)
        @Assert(engine.turnHeadersFrameStreamId, 83)
        @Assert(engine.turnHeadersStatus, "203")
        @Assert(engine.turnHeadersCustomHeader, "sr108")
        @Assert(engine.turnFrameType, UInt8(0x0))
        @Assert(engine.turnFrameEndStream, true)
        @Assert(engine.turnFrameStreamId, 83)
        @Assert(
            serverEngineAbstractionTestByteArraysEqual(
                engine.turnFramePayload,
                serverEngineAbstractionTestTextBytes(
                    "sr108:GET:/h2-appdata-response-turn:data"
                )
            ),
            true
        )
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "ready")
                @Assert(event.scheme, "https")
            case None => @Fail("expected startup observe ready event")
        }
    }

    @TestCase
    public func testInjectedServerEngineCanEmitH2ResponseHeadersBeforeDataFromAcceptedSocketApplicationDataResponseWriterTurn(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.get("/h2-appdata-response-turn", { ctx =>
            let mode = ctx.queryFromUrl("mode") ?? ""
            let _ = ctx
                .status(207)
                .setHeader("x-h2-turn", "sr109")
                .sendString("sr109:${ctx.method}:${ctx.path}:${mode}")
        })
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportH2ApplicationDataResponseWriterTurnProbeEngine()
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let responseWire =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let _ = serverFuture.get(Duration.second * 5)
        engine.decodeTurnSocketWire(responseWire)

        @Assert(engine.turnReadyStatus, "READY")
        @Assert(engine.turnResponseStatus, UInt16(207))
        @Assert(engine.turnContentType, "text/plain; charset=utf-8")
        @Assert(engine.turnCustomHeader, "sr109")
        @Assert(engine.turnDecodedFrameCount, 2)
        @Assert(engine.turnHeadersFrameType, UInt8(0x1))
        @Assert(engine.turnHeadersEndHeaders, true)
        @Assert(engine.turnHeadersEndStream, false)
        @Assert(engine.turnHeadersFrameStreamId, 83)
        @Assert(engine.turnHeadersStatus, "207")
        @Assert(engine.turnHeadersCustomHeader, "sr109")
        @Assert(engine.turnFrameType, UInt8(0x0))
        @Assert(engine.turnFrameEndStream, true)
        @Assert(engine.turnFrameStreamId, 83)
        @Assert(
            serverEngineAbstractionTestByteArraysEqual(
                engine.turnFramePayload,
                serverEngineAbstractionTestTextBytes(
                    "sr109:GET:/h2-appdata-response-turn:data"
                )
            ),
            true
        )
    }

    @TestCase
    public func testInjectedServerEngineCanEmitH2EmptyBodyResponseHeadersEndStreamFromAcceptedSocketApplicationDataResponseWriterTurn(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.get("/h2-empty-response-turn", { ctx =>
            let _ = ctx
                .status(204)
                .setHeader("x-h2-turn", "sr110")
        })
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportH2ApplicationDataResponseWriterTurnProbeEngine(
                turnRequestUrl: "/h2-empty-response-turn?mode=empty",
                streamId: 91
            )
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let responseWire =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let _ = serverFuture.get(Duration.second * 5)
        engine.decodeTurnSocketWire(responseWire)

        @Assert(engine.turnReadyStatus, "READY")
        @Assert(engine.turnResponseStatus, UInt16(204))
        @Assert(engine.turnCustomHeader, "sr110")
        @Assert(engine.turnDecodedFrameCount, 1)
        @Assert(engine.turnHeadersFrameType, UInt8(0x1))
        @Assert(engine.turnHeadersEndHeaders, true)
        @Assert(engine.turnHeadersEndStream, true)
        @Assert(engine.turnHeadersFrameStreamId, 91)
        @Assert(engine.turnHeadersStatus, "204")
        @Assert(engine.turnHeadersCustomHeader, "sr110")
        @Assert(engine.turnDataFrameSeen, false)
        @Assert(engine.turnFramePayload.size, 0)
    }

    @TestCase
    public func testInjectedServerEngineCanForwardCapturedH2ResponseHeadersFromAcceptedSocketApplicationDataResponseWriterTurn(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.get("/h2-response-header-forwarding-turn", { ctx =>
            let mode = ctx.queryFromUrl("mode") ?? ""
            let _ = ctx
                .status(208)
                .setHeader("x-h2-turn", "sr111")
                .setHeader("x-h2-extra", "captured")
                .setHeader("connection", "close")
                .sendString("sr111:${ctx.method}:${ctx.path}:${mode}")
        })
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportH2ApplicationDataResponseWriterTurnProbeEngine(
                turnRequestUrl: "/h2-response-header-forwarding-turn?mode=headers",
                streamId: 93
            )
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let responseWire =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let _ = serverFuture.get(Duration.second * 5)
        engine.decodeTurnSocketWire(responseWire)

        @Assert(engine.turnReadyStatus, "READY")
        @Assert(engine.turnResponseStatus, UInt16(208))
        @Assert(engine.turnCustomHeader, "sr111")
        @Assert(engine.turnExtraHeader, "captured")
        @Assert(engine.turnDecodedFrameCount, 2)
        @Assert(engine.turnHeadersFrameType, UInt8(0x1))
        @Assert(engine.turnHeadersEndHeaders, true)
        @Assert(engine.turnHeadersEndStream, false)
        @Assert(engine.turnHeadersFrameStreamId, 93)
        @Assert(engine.turnHeadersStatus, "208")
        @Assert(engine.turnHeadersCustomHeader, "sr111")
        @Assert(engine.turnHeadersExtraHeader, "captured")
        @Assert(engine.turnHeadersConnectionHeaderSeen, false)
        @Assert(engine.turnFrameType, UInt8(0x0))
        @Assert(engine.turnFrameEndStream, true)
        @Assert(engine.turnFrameStreamId, 93)
        @Assert(
            serverEngineAbstractionTestByteArraysEqual(
                engine.turnFramePayload,
                serverEngineAbstractionTestTextBytes(
                    "sr111:GET:/h2-response-header-forwarding-turn:headers"
                )
            ),
            true
        )
    }

    @TestCase
    public func testInjectedServerEngineCanEmitStaticNameLiteralForH2ResponseContentTypeFromAcceptedSocketApplicationDataResponseWriterTurn(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.get("/h2-response-static-name-turn", { ctx =>
            let mode = ctx.queryFromUrl("mode") ?? ""
            let _ = ctx
                .status(209)
                .setHeader("x-h2-turn", "sr112")
                .setHeader("x-h2-extra", "new-name")
                .sendString("sr112:${ctx.method}:${ctx.path}:${mode}")
        })
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportH2ApplicationDataResponseWriterTurnProbeEngine(
                turnRequestUrl: "/h2-response-static-name-turn?mode=static",
                streamId: 95
            )
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let responseWire =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let _ = serverFuture.get(Duration.second * 5)
        engine.decodeTurnSocketWire(responseWire)

        @Assert(engine.turnReadyStatus, "READY")
        @Assert(engine.turnResponseStatus, UInt16(209))
        @Assert(engine.turnContentType, "text/plain; charset=utf-8")
        @Assert(engine.turnCustomHeader, "sr112")
        @Assert(engine.turnExtraHeader, "new-name")
        @Assert(engine.turnDecodedFrameCount, 2)
        @Assert(engine.turnHeadersFrameType, UInt8(0x1))
        @Assert(engine.turnHeadersEndHeaders, true)
        @Assert(engine.turnHeadersEndStream, false)
        @Assert(engine.turnHeadersFrameStreamId, 95)
        @Assert(engine.turnHeadersStatus, "209")
        @Assert(engine.turnHeadersContentType, "text/plain; charset=utf-8")
        @Assert(engine.turnHeadersContentTypeNameStaticIndex, 31)
        @Assert(engine.turnHeadersExtraHeader, "new-name")
        @Assert(engine.turnHeadersExtraHeaderNameStaticIndex, 0)
        @Assert(engine.turnFrameType, UInt8(0x0))
        @Assert(engine.turnFrameEndStream, true)
        @Assert(engine.turnFrameStreamId, 95)
        @Assert(
            serverEngineAbstractionTestByteArraysEqual(
                engine.turnFramePayload,
                serverEngineAbstractionTestTextBytes(
                    "sr112:GET:/h2-response-static-name-turn:static"
                )
            ),
            true
        )
    }

    @TestCase
    public func testInjectedServerEngineCanPreserveDuplicateH2ResponseHeadersFromAcceptedSocketApplicationDataResponseWriterTurn(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.get("/h2-response-duplicate-header-turn", { ctx =>
            let mode = ctx.queryFromUrl("mode") ?? ""
            let _ = ctx
                .status(210)
                .setHeader("x-h2-turn", "sr113")
                .setHeader("x-h2-repeat", "one")
                .setHeader("x-h2-repeat", "two")
                .sendString("sr113:${ctx.method}:${ctx.path}:${mode}")
        })
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportH2ApplicationDataResponseWriterTurnProbeEngine(
                turnRequestUrl: "/h2-response-duplicate-header-turn?mode=repeat",
                streamId: 97
            )
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let responseWire =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let _ = serverFuture.get(Duration.second * 5)
        engine.decodeTurnSocketWire(responseWire)

        @Assert(engine.turnReadyStatus, "READY")
        @Assert(engine.turnResponseStatus, UInt16(210))
        @Assert(engine.turnCustomHeader, "sr113")
        @Assert(engine.turnDecodedFrameCount, 2)
        @Assert(engine.turnHeadersFrameType, UInt8(0x1))
        @Assert(engine.turnHeadersEndHeaders, true)
        @Assert(engine.turnHeadersEndStream, false)
        @Assert(engine.turnHeadersFrameStreamId, 97)
        @Assert(engine.turnHeadersStatus, "210")
        @Assert(engine.turnHeadersCustomHeader, "sr113")
        @Assert(engine.turnHeadersRepeatHeaderCount, 2)
        @Assert(engine.turnHeadersRepeatHeaderFirst, "one")
        @Assert(engine.turnHeadersRepeatHeaderSecond, "two")
        @Assert(engine.turnFrameType, UInt8(0x0))
        @Assert(engine.turnFrameEndStream, true)
        @Assert(engine.turnFrameStreamId, 97)
        @Assert(
            serverEngineAbstractionTestByteArraysEqual(
                engine.turnFramePayload,
                serverEngineAbstractionTestTextBytes(
                    "sr113:GET:/h2-response-duplicate-header-turn:repeat"
                )
            ),
            true
        )
    }

    @TestCase
    public func testInjectedServerEngineCanEmitStaticNameLiteralMatrixForH2ResponseHeadersFromAcceptedSocketApplicationDataResponseWriterTurn(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.get("/h2-response-static-name-matrix-turn", { ctx =>
            let _ = ctx
                .status(211)
                .setHeader("x-h2-turn", "sr114")
                .setHeader("cache-control", "no-store")
                .setHeader("content-length", "12")
                .sendString("sr114-static")
        })
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportH2ApplicationDataResponseWriterTurnProbeEngine(
                turnRequestUrl: "/h2-response-static-name-matrix-turn?mode=matrix",
                streamId: 99
            )
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let responseWire =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let _ = serverFuture.get(Duration.second * 5)
        engine.decodeTurnSocketWire(responseWire)

        @Assert(engine.turnReadyStatus, "READY")
        @Assert(engine.turnResponseStatus, UInt16(211))
        @Assert(engine.turnCustomHeader, "sr114")
        @Assert(engine.turnDecodedFrameCount, 2)
        @Assert(engine.turnHeadersFrameType, UInt8(0x1))
        @Assert(engine.turnHeadersEndHeaders, true)
        @Assert(engine.turnHeadersEndStream, false)
        @Assert(engine.turnHeadersFrameStreamId, 99)
        @Assert(engine.turnHeadersStatus, "211")
        @Assert(engine.turnHeadersCustomHeader, "sr114")
        @Assert(engine.turnHeadersCacheControl, "no-store")
        @Assert(engine.turnHeadersCacheControlNameStaticIndex, 24)
        @Assert(engine.turnHeadersContentLength, "12")
        @Assert(engine.turnHeadersContentLengthNameStaticIndex, 28)
        @Assert(engine.turnHeadersContentType, "text/plain; charset=utf-8")
        @Assert(engine.turnHeadersContentTypeNameStaticIndex, 31)
        @Assert(engine.turnHeadersServer, "Ignite")
        @Assert(engine.turnHeadersServerNameStaticIndex, 54)
        @Assert(engine.turnFrameType, UInt8(0x0))
        @Assert(engine.turnFrameEndStream, true)
        @Assert(engine.turnFrameStreamId, 99)
        @Assert(
            serverEngineAbstractionTestByteArraysEqual(
                engine.turnFramePayload,
                serverEngineAbstractionTestTextBytes("sr114-static")
            ),
            true
        )
    }

    @TestCase
    public func testInjectedServerEngineCanEmitIndexedStaticStatusForCommonH2ResponseStatusesFromAcceptedSocketApplicationDataResponseWriterTurn(): Unit {
        assertAcceptedSocketH2ResponseStatusStaticIndex(
            "/h2-response-status-index-200",
            UInt16(200),
            "200",
            8,
            "sr115-200",
            101,
            true
        )
        assertAcceptedSocketH2ResponseStatusStaticIndex(
            "/h2-response-status-index-204",
            UInt16(204),
            "204",
            9,
            "sr115-204",
            103,
            false
        )
        assertAcceptedSocketH2ResponseStatusStaticIndex(
            "/h2-response-status-index-404",
            UInt16(404),
            "404",
            13,
            "sr115-404",
            105,
            true
        )
    }

    @TestCase
    public func testInjectedServerEngineCanEmitRemainingIndexedStaticStatusMatrixFromAcceptedSocketApplicationDataResponseWriterTurn(): Unit {
        assertAcceptedSocketH2ResponseStatusStaticIndex(
            "/h2-response-status-index-206",
            UInt16(206),
            "206",
            10,
            "sr116-206",
            107,
            true
        )
        assertAcceptedSocketH2ResponseStatusStaticIndex(
            "/h2-response-status-index-304",
            UInt16(304),
            "304",
            11,
            "sr116-304",
            109,
            false
        )
        assertAcceptedSocketH2ResponseStatusStaticIndex(
            "/h2-response-status-index-400",
            UInt16(400),
            "400",
            12,
            "sr116-400",
            111,
            true
        )
        assertAcceptedSocketH2ResponseStatusStaticIndex(
            "/h2-response-status-index-500",
            UInt16(500),
            "500",
            14,
            "sr116-500",
            113,
            true
        )
    }

    @TestCase
    public func testInjectedServerEngineSkipsAppSetPseudoHeadersAndKeepsFrameworkStatusFirstFromAcceptedSocketApplicationDataResponseWriterTurn(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.get("/h2-response-pseudo-header-skip-turn", { ctx =>
            let _ = ctx
                .status(UInt16(206))
                .setHeader(":status", "500")
                .setHeader(":path", "/should-not-leak")
                .setHeader(":method", "POST")
                .setHeader(":scheme", "https")
                .setHeader(":authority", "example.invalid")
                .setHeader("x-h2-turn", "sr117")
                .sendString("sr117-body")
        })
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportH2ApplicationDataResponseWriterTurnProbeEngine(
                turnRequestUrl:
                    "/h2-response-pseudo-header-skip-turn?mode=pseudo",
                streamId: 115
            )
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let responseWire =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let _ = serverFuture.get(Duration.second * 5)
        engine.decodeTurnSocketWire(responseWire)

        @Assert(engine.turnReadyStatus, "READY")
        @Assert(engine.turnResponseStatus, UInt16(206))
        @Assert(engine.turnHeadersFirstName, ":status")
        @Assert(engine.turnHeadersStatus, "206")
        @Assert(engine.turnHeadersStatusStaticIndex, 10)
        @Assert(engine.turnHeadersPseudoFieldCount, 1)
        @Assert(engine.turnHeadersUnexpectedPseudoFieldSeen, false)
        @Assert(engine.turnHeadersCustomHeader, "sr117")
        @Assert(engine.turnDecodedFrameCount, 2)
        @Assert(engine.turnHeadersEndStream, false)
        @Assert(engine.turnFrameType, UInt8(0x0))
        @Assert(engine.turnFrameEndStream, true)
        @Assert(engine.turnFrameStreamId, 115)
        @Assert(
            serverEngineAbstractionTestByteArraysEqual(
                engine.turnFramePayload,
                serverEngineAbstractionTestTextBytes("sr117-body")
            ),
            true
        )
    }

    @TestCase
    public func testInjectedServerEngineSkipsForbiddenRegularHeadersFromAcceptedSocketApplicationDataResponseWriterTurn(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.get("/h2-response-regular-header-skip-turn", { ctx =>
            let _ = ctx
                .status(UInt16(206))
                .setHeader("connection", "close")
                .setHeader("keep-alive", "timeout=5")
                .setHeader("proxy-connection", "keep-alive")
                .setHeader("transfer-encoding", "chunked")
                .setHeader("upgrade", "websocket")
                .setHeader("te", "gzip")
                .setHeader("x-h2-turn", "sr118")
                .sendString("sr118-body")
        })
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportH2ApplicationDataResponseWriterTurnProbeEngine(
                turnRequestUrl:
                    "/h2-response-regular-header-skip-turn?mode=regular",
                streamId: 117
            )
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let responseWire =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let _ = serverFuture.get(Duration.second * 5)
        engine.decodeTurnSocketWire(responseWire)

        @Assert(engine.turnReadyStatus, "READY")
        @Assert(engine.turnResponseStatus, UInt16(206))
        @Assert(engine.turnHeadersFirstName, ":status")
        @Assert(engine.turnHeadersStatus, "206")
        @Assert(engine.turnHeadersStatusStaticIndex, 10)
        @Assert(engine.turnHeadersPseudoFieldCount, 1)
        @Assert(engine.turnHeadersConnectionHeaderSeen, false)
        @Assert(engine.turnHeadersKeepAliveHeaderSeen, false)
        @Assert(engine.turnHeadersProxyConnectionHeaderSeen, false)
        @Assert(engine.turnHeadersTransferEncodingHeaderSeen, false)
        @Assert(engine.turnHeadersUpgradeHeaderSeen, false)
        @Assert(engine.turnHeadersTeHeaderSeen, false)
        @Assert(engine.turnHeadersCustomHeader, "sr118")
        @Assert(engine.turnDecodedFrameCount, 2)
        @Assert(engine.turnHeadersEndStream, false)
        @Assert(engine.turnFrameType, UInt8(0x0))
        @Assert(engine.turnFrameEndStream, true)
        @Assert(engine.turnFrameStreamId, 117)
        @Assert(
            serverEngineAbstractionTestByteArraysEqual(
                engine.turnFramePayload,
                serverEngineAbstractionTestTextBytes("sr118-body")
            ),
            true
        )
    }

    func assertAcceptedSocketH2ResponseStatusStaticIndex(
        routePath: String,
        status: UInt16,
        expectedStatusValue: String,
        expectedStaticIndex: Int64,
        label: String,
        streamId: Int64,
        withBody: Bool
    ): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let responseBody = "${label}:body"
        app.get(routePath, { ctx =>
            if (withBody) {
                let _ = ctx
                    .status(status)
                    .setHeader("x-h2-turn", label)
                    .sendString(responseBody)
            } else {
                let _ = ctx
                    .status(status)
                    .setHeader("x-h2-turn", label)
            }
        })
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportH2ApplicationDataResponseWriterTurnProbeEngine(
                turnRequestUrl: "${routePath}?mode=status-index",
                streamId: streamId
            )
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let responseWire =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let _ = serverFuture.get(Duration.second * 5)
        engine.decodeTurnSocketWire(responseWire)

        @Assert(engine.turnReadyStatus, "READY")
        @Assert(engine.turnResponseStatus, status)
        @Assert(engine.turnCustomHeader, label)
        @Assert(engine.turnHeadersFrameType, UInt8(0x1))
        @Assert(engine.turnHeadersEndHeaders, true)
        @Assert(engine.turnHeadersFrameStreamId, streamId)
        @Assert(engine.turnHeadersStatus, expectedStatusValue)
        @Assert(engine.turnHeadersStatusStaticIndex, expectedStaticIndex)
        @Assert(engine.turnHeadersCustomHeader, label)
        if (withBody) {
            @Assert(engine.turnDecodedFrameCount, 2)
            @Assert(engine.turnHeadersEndStream, false)
            @Assert(engine.turnFrameType, UInt8(0x0))
            @Assert(engine.turnFrameEndStream, true)
            @Assert(engine.turnFrameStreamId, streamId)
            @Assert(
                serverEngineAbstractionTestByteArraysEqual(
                    engine.turnFramePayload,
                    serverEngineAbstractionTestTextBytes(responseBody)
                ),
                true
            )
        } else {
            @Assert(engine.turnDecodedFrameCount, 1)
            @Assert(engine.turnHeadersEndStream, true)
            @Assert(engine.turnDataFrameSeen, false)
            @Assert(engine.turnFramePayload.size, 0)
        }
    }

    @TestCase
    public func testInjectedServerEngineCanServeAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataProvidedBodyRequestTurn(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.post("/carrier-captured-appdata-body-string", { ctx =>
            let body = ctx.bodyString()
            let _ = ctx
                .setHeader("x-captured-appdata-body", "1")
                .sendString("body:${body}")
        })
        app.post("/carrier-captured-appdata-body-json", { ctx =>
            let reader = ctx.requestJsonReader()
            reader.startObject()
            let firstName = reader.readName()
            let firstValue = reader.readValue<String>()
            let secondName = reader.readName()
            let secondValue = reader.readValue<Int64>()
            reader.endObject()
            let _ = ctx
                .setHeader("x-captured-appdata-body-json", "1")
                .sendString("${firstName}:${firstValue}:${secondName}:${secondValue}")
        })
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataProvidedBodyRequestTurnProbeEngine()
        app.serverEngine(engine)

        let bodyStringHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 3072))
        )
        let bodyJsonHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 3136))
        )
        let bodyStringHelloWire =
            buildServerEngineAbstractionTestTlsRecordWire(
                bodyStringHello.encodedClientHello
            )
        let bodyJsonHelloWire =
            buildServerEngineAbstractionTestTlsRecordWire(
                bodyJsonHello.encodedClientHello
            )

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let bodyStringWire =
            runAcceptedTransportTlsHandshakeRequestResponseSocketSinkClient(
                "127.0.0.1",
                port,
                [
                    cloneServerEngineByteWindow(bodyStringHelloWire, 0, 6),
                    cloneServerEngineByteWindow(bodyStringHelloWire, 6, 10),
                    cloneServerEngineByteWindow(
                        bodyStringHelloWire,
                        16,
                        bodyStringHelloWire.size - 16
                    )
                ],
                "captured-clienthello provided-body bodyString request",
                { => Some([]) },
                writePauseMillis: 20
            )
        let bodyJsonWire =
            runAcceptedTransportTlsHandshakeRequestResponseSocketSinkClient(
                "127.0.0.1",
                port,
                [
                    cloneServerEngineByteWindow(bodyJsonHelloWire, 0, 8),
                    cloneServerEngineByteWindow(bodyJsonHelloWire, 8, 9),
                    cloneServerEngineByteWindow(
                        bodyJsonHelloWire,
                        17,
                        bodyJsonHelloWire.size - 17
                    )
                ],
                "captured-clienthello provided-body bodyJson request",
                { => Some([]) },
                writePauseMillis: 20
            )
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(engine.bodyStringReadyStatus, "READY")
        @Assert(engine.bodyJsonReadyStatus, "READY")
        @Assert(engine.bodyStringNegotiatedAlpn, "h2")
        @Assert(engine.bodyJsonNegotiatedAlpn, "h2")
        @Assert(engine.bodyStringRequestedServerName, "www.example.com")
        @Assert(engine.bodyJsonRequestedServerName, "www.example.com")
        @Assert(engine.bodyStringAttachSurface, "accepted-transport-session")
        @Assert(engine.bodyJsonAttachSurface, "accepted-transport-session")
        @Assert(
            engine.openBodyStringSocketWire(bodyStringWire),
            "body:accepted-appdata-body"
        )
        @Assert(
            engine.openBodyJsonSocketWire(bodyJsonWire),
            "name:ignite:val:23"
        )
        @Assert(engine.bodyStringResponseStatus, UInt16(200))
        @Assert(engine.bodyJsonResponseStatus, UInt16(200))
        @Assert(
            engine.bodyStringContentType,
            "text/plain; charset=utf-8"
        )
        @Assert(
            engine.bodyJsonContentType,
            "text/plain; charset=utf-8"
        )
        @Assert(engine.bodyStringTransferEncoding, "")
        @Assert(engine.bodyJsonTransferEncoding, "")
        @Assert(engine.bodyStringSocketWriteCount >= 1, true)
        @Assert(engine.bodyJsonSocketWriteCount >= 1, true)
        @Assert(
            engine.bodyStringTransportId,
            "captured-clienthello-provided-body-string-transport"
        )
        @Assert(
            engine.bodyJsonTransportId,
            "captured-clienthello-provided-body-json-transport"
        )
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "ready")
                @Assert(event.scheme, "https")
            case None => @Fail("expected startup observe ready event")
        }
    }

    @TestCase
    public func testInjectedServerEngineRejectsMultipleAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataHeaderBlocksForProvidedBodyRequestTurn(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataProvidedBodyRequestTurnRejectProbeEngine()
        app.serverEngine(engine)

        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 3200))
        )
        let clientHelloWire =
            buildServerEngineAbstractionTestTlsRecordWire(
                clientHello.encodedClientHello
            )

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let _ =
            runAcceptedTransportTlsHandshakeRequestResponseSocketSinkClient(
                "127.0.0.1",
                port,
                [
                    cloneServerEngineByteWindow(clientHelloWire, 0, 7),
                    cloneServerEngineByteWindow(clientHelloWire, 7, 11),
                    cloneServerEngineByteWindow(
                        clientHelloWire,
                        18,
                        clientHelloWire.size - 18
                    )
                ],
                "captured-clienthello provided-body reject request",
                { => Some([]) },
                writePauseMillis: 20
            )
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(
            contains(
                engine.observedError,
                "expects exactly one complete H2 header block, got count=2"
            ),
            true
        )
    }

    @TestCase
    public func testInjectedServerEngineCanRouteCtxJsonWriteAndJsonStreamThroughJinguiAcceptedTransportResponseCarrier(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.get("/carrier-json-write", { ctx =>
            _ = ctx.jsonWrite({ jw =>
                jw.startObject()
                jw.writeName("kind")
                jw.writeValue("carrier-json-write")
                jw.writeName("ok")
                jw.writeValue(true)
                jw.writeName("count")
                jw.writeValue(3)
                jw.endObject()
            })
        })
        app.get("/carrier-json-stream", { ctx =>
            _ = ctx.jsonStream({ jw =>
                jw.startArray()
                jw.writeValue("carrier")
                jw.writeValue("json-stream")
                jw.writeValue(5)
                jw.endArray()
            })
        })
        let engine = JinguiAcceptedTransportResponseCarrierProbeEngine()
        app.serverEngine(engine)

        app.listen("127.0.0.1", UInt16(38128))

        @Assert(engine.jsonWriteEncodedRecordCount > 1, true)
        @Assert(
            engine.jsonWriteDecodedJson,
            "{\"kind\":\"carrier-json-write\",\"ok\":true,\"count\":3}"
        )
        @Assert(engine.jsonWriteResponseStatus, UInt16(200))
        @Assert(
            engine.jsonWriteContentType,
            "application/json; charset=utf-8"
        )
        @Assert(engine.jsonWriteTransferEncoding, "")
        @Assert(engine.jsonStreamEncodedRecordCount > 1, true)
        @Assert(engine.jsonStreamDecodedJson, "[\"carrier\",\"json-stream\",5]")
        @Assert(engine.jsonStreamResponseStatus, UInt16(200))
        @Assert(
            engine.jsonStreamContentType,
            "application/json; charset=utf-8"
        )
        @Assert(engine.jsonStreamTransferEncoding, "")
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "ready")
                @Assert(event.scheme, "https")
            case None => @Fail("expected startup observe ready event")
        }
    }

    @TestCase
    public func testInjectedServerEngineCanRouteCtxJsonThroughJinguiAcceptedTransportResponseSocketWriteSink(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.get("/carrier-json-socket-sink", { ctx =>
            let _ = ctx
                .status(201)
                .setHeader("x-carrier-sink", "1")
                .json(#"{"kind":"socket-sink","ok":true}"#)
        })
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine = JinguiAcceptedTransportResponseSocketSinkProbeEngine()
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let encodedRecord =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(engine.responseSocketWriteCount, 1)
        @Assert(engine.totalEncodedSocketBytes > 0, true)
        @Assert(engine.totalEncodedSocketBytes, encodedRecord.size)
        @Assert(
            engine.openClientSocketRecordWire(encodedRecord),
            "{\"kind\":\"socket-sink\",\"ok\":true}"
        )
        @Assert(engine.responseStatus, UInt16(201))
        @Assert(
            engine.responseContentType,
            "application/json; charset=utf-8"
        )
        @Assert(engine.responseTransferEncoding, "")
        @Assert(engine.responseCustomHeader, "1")
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "ready")
                @Assert(event.scheme, "https")
            case None => @Fail("expected startup observe ready event")
        }
    }

    @TestCase
    public func testInjectedServerEngineCanRouteCtxJsonWriteAndJsonStreamThroughJinguiAcceptedTransportResponseSocketWireReassembly(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.get("/carrier-json-write-socket-wire", { ctx =>
            _ = ctx.jsonWrite({ jw =>
                jw.startObject()
                jw.writeName("kind")
                jw.writeValue("carrier-json-write-socket-wire")
                jw.writeName("ok")
                jw.writeValue(true)
                jw.writeName("count")
                jw.writeValue(7)
                jw.endObject()
            })
        })
        app.get("/carrier-json-stream-socket-wire", { ctx =>
            _ = ctx.jsonStream({ jw =>
                jw.startArray()
                jw.writeValue("carrier")
                jw.writeValue("json-stream-socket-wire")
                jw.writeValue(9)
                jw.endArray()
            })
        })
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine = JinguiAcceptedTransportResponseSocketWireProbeEngine()
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let jsonWriteWire =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let jsonStreamWire =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(engine.jsonWriteSocketWriteCount > 1, true)
        @Assert(engine.jsonStreamSocketWriteCount > 1, true)
        @Assert(engine.jsonWriteReadyStatus, "READY")
        @Assert(engine.jsonStreamReadyStatus, "READY")
        @Assert(
            engine.openJsonWriteSocketWire(jsonWriteWire),
            "{\"kind\":\"carrier-json-write-socket-wire\",\"ok\":true,\"count\":7}"
        )
        @Assert(
            engine.openJsonStreamSocketWire(jsonStreamWire),
            "[\"carrier\",\"json-stream-socket-wire\",9]"
        )
        @Assert(engine.jsonWriteResponseStatus, UInt16(200))
        @Assert(engine.jsonStreamResponseStatus, UInt16(200))
        @Assert(
            engine.jsonWriteContentType,
            "application/json; charset=utf-8"
        )
        @Assert(
            engine.jsonStreamContentType,
            "application/json; charset=utf-8"
        )
        @Assert(engine.jsonWriteTransferEncoding, "")
        @Assert(engine.jsonStreamTransferEncoding, "")
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "ready")
                @Assert(event.scheme, "https")
            case None => @Fail("expected startup observe ready event")
        }
    }

    @TestCase
    public func testInjectedServerEngineCanRouteCtxJsonWriteAndJsonStreamThroughJinguiAcceptedTransportResponseSocketFragmentedWireAccumulator(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.get("/carrier-json-write-socket-wire", { ctx =>
            _ = ctx.jsonWrite({ jw =>
                jw.startObject()
                jw.writeName("kind")
                jw.writeValue("carrier-json-write-socket-wire")
                jw.writeName("ok")
                jw.writeValue(true)
                jw.writeName("count")
                jw.writeValue(7)
                jw.endObject()
            })
        })
        app.get("/carrier-json-stream-socket-wire", { ctx =>
            _ = ctx.jsonStream({ jw =>
                jw.startArray()
                jw.writeValue("carrier")
                jw.writeValue("json-stream-socket-wire")
                jw.writeValue(9)
                jw.endArray()
            })
        })
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine = JinguiAcceptedTransportResponseSocketWireProbeEngine()
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let jsonWriteRecords = runAcceptedTransportResponseSocketFragmentedClient(
            "127.0.0.1",
            port,
            readChunkSize: 3
        )
        let jsonStreamRecords = runAcceptedTransportResponseSocketFragmentedClient(
            "127.0.0.1",
            port,
            readChunkSize: 5
        )
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(engine.jsonWriteSocketWriteCount > 1, true)
        @Assert(engine.jsonStreamSocketWriteCount > 1, true)
        @Assert(jsonWriteRecords.size > 1, true)
        @Assert(jsonStreamRecords.size > 1, true)
        @Assert(engine.jsonWriteReadyStatus, "READY")
        @Assert(engine.jsonStreamReadyStatus, "READY")
        @Assert(
            engine.openJsonWriteSocketRecords(jsonWriteRecords),
            "{\"kind\":\"carrier-json-write-socket-wire\",\"ok\":true,\"count\":7}"
        )
        @Assert(
            engine.openJsonStreamSocketRecords(jsonStreamRecords),
            "[\"carrier\",\"json-stream-socket-wire\",9]"
        )
        @Assert(engine.jsonWriteResponseStatus, UInt16(200))
        @Assert(engine.jsonStreamResponseStatus, UInt16(200))
        @Assert(
            engine.jsonWriteContentType,
            "application/json; charset=utf-8"
        )
        @Assert(
            engine.jsonStreamContentType,
            "application/json; charset=utf-8"
        )
        @Assert(engine.jsonWriteTransferEncoding, "")
        @Assert(engine.jsonStreamTransferEncoding, "")
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "ready")
                @Assert(event.scheme, "https")
            case None => @Fail("expected startup observe ready event")
        }
    }

    @TestCase
    public func testInjectedServerEngineCanConsumeAcceptedSocketLogicalRequestBodyBytesThroughJinguiHelper(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.post("/carrier-body-string", { ctx =>
            let body = ctx.bodyString()
            let _ = ctx
                .setHeader("x-carrier-body", "1")
                .sendString("body:${body}")
        })
        app.post("/carrier-body-json", { ctx =>
            let reader = ctx.requestJsonReader()
            reader.startObject()
            let firstName = reader.readName()
            let firstValue = reader.readValue<String>()
            let secondName = reader.readName()
            let secondValue = reader.readValue<Int64>()
            reader.endObject()
            let _ = ctx
                .setHeader("x-carrier-body-json", "1")
                .sendString("${firstName}:${firstValue}:${secondName}:${secondValue}")
        })
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine = JinguiAcceptedTransportLogicalRequestBodyProbeEngine()
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let bodyStringWire =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let bodyJsonWire =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(engine.bodyStringReadyStatus, "READY")
        @Assert(engine.bodyJsonReadyStatus, "READY")
        @Assert(
            engine.openBodyStringSocketWire(bodyStringWire),
            "body:accepted-body"
        )
        @Assert(
            engine.openBodyJsonSocketWire(bodyJsonWire),
            "name:ignite:val:23"
        )
        @Assert(engine.bodyStringResponseStatus, UInt16(200))
        @Assert(engine.bodyJsonResponseStatus, UInt16(200))
        @Assert(
            engine.bodyStringContentType,
            "text/plain; charset=utf-8"
        )
        @Assert(
            engine.bodyJsonContentType,
            "text/plain; charset=utf-8"
        )
        @Assert(engine.bodyStringTransferEncoding, "")
        @Assert(engine.bodyJsonTransferEncoding, "")
        @Assert(engine.bodyStringSocketWriteCount >= 1, true)
        @Assert(engine.bodyJsonSocketWriteCount >= 1, true)
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "ready")
                @Assert(event.scheme, "https")
            case None => @Fail("expected startup observe ready event")
        }
    }

    @TestCase
    public func testInjectedServerEngineCanProjectAcceptedSocketLogicalRequestTargetQueryThroughJinguiHelper(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.get("/carrier-query", { ctx =>
            let turn = ctx.queryFromUrl("turn") ?? ""
            let mode = ctx.query("mode") ?? ""
            let _ = ctx
                .setHeader("x-carrier-query", "1")
                .sendString("${ctx.path}|${ctx.originalUrl}|${turn}|${mode}")
        })
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine = JinguiAcceptedTransportLogicalRequestTargetQueryProbeEngine()
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let queryWire =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(engine.queryReadyStatus, "READY")
        @Assert(
            engine.openQuerySocketWire(queryWire),
            "/carrier-query|/carrier-query?turn=from-path&mode=route|from-path|route"
        )
        @Assert(engine.queryResponseStatus, UInt16(200))
        @Assert(
            engine.queryContentType,
            "text/plain; charset=utf-8"
        )
        @Assert(engine.queryTransferEncoding, "")
        @Assert(engine.querySocketWriteCount >= 1, true)
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "ready")
                @Assert(event.scheme, "https")
            case None => @Fail("expected startup observe ready event")
        }
    }

    @TestCase
    public func testInjectedServerEngineCanProjectAcceptedSocketH2PseudoHeadersThroughJinguiHelper(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.post("/carrier-h2-pseudo", { ctx =>
            let host = ctx.header("host") ?? ""
            let mode = ctx.header("x-carrier-mode") ?? ""
            let turn = ctx.queryFromUrl("turn") ?? ""
            let body = ctx.bodyString()
            let _ = ctx
                .setHeader("x-carrier-h2-pseudo", "1")
                .sendString(
                    "${ctx.method}|${ctx.path}|${ctx.originalUrl}|${ctx.protocol}|${host}|${mode}|${turn}|${body}"
                )
        })
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine = JinguiAcceptedTransportH2PseudoHeadersProbeEngine()
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let pseudoWire =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(engine.pseudoReadyStatus, "READY")
        @Assert(
            engine.openPseudoSocketWire(pseudoWire),
            "POST|/carrier-h2-pseudo|/carrier-h2-pseudo?turn=from-pseudo|h2|api.example.com:9443|pseudo|from-pseudo|pseudo-body"
        )
        @Assert(engine.pseudoResponseStatus, UInt16(200))
        @Assert(
            engine.pseudoContentType,
            "text/plain; charset=utf-8"
        )
        @Assert(engine.pseudoTransferEncoding, "")
        @Assert(engine.pseudoSocketWriteCount >= 1, true)
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "ready")
                @Assert(event.scheme, "https")
            case None => @Fail("expected startup observe ready event")
        }
    }

    @TestCase
    public func testJinguiAcceptedTransportH2FrameWireParseCanDecodeSingleCompleteFrame(): Unit {
        let headersFrame = buildServerEngineAbstractionTestH2FrameWire(
            serverEngineAbstractionTestByteArray("hdr".toArray()),
            frameType: UInt8(0x1),
            flags: UInt8(0x5),
            streamId: 1
        )
        let snapshot = parseJinguiAcceptedTransportH2FrameWire(headersFrame)

        @Assert(snapshot.payloadLength, 3)
        @Assert(snapshot.frameType, UInt8(0x1))
        @Assert(snapshot.flags, UInt8(0x5))
        @Assert(snapshot.streamId, 1)
        @Assert(serverEngineAbstractionTestByteText(snapshot.payload), "hdr")
    }

    @TestCase
    public func testJinguiAcceptedTransportH2FrameWireSplitCanDecodeConcatenatedFrames(): Unit {
        let headersFrame = buildServerEngineAbstractionTestH2FrameWire(
            serverEngineAbstractionTestByteArray("hdr".toArray()),
            frameType: UInt8(0x1),
            flags: UInt8(0x4),
            streamId: 1
        )
        let dataFrame = buildServerEngineAbstractionTestH2FrameWire(
            serverEngineAbstractionTestByteArray("payload".toArray()),
            frameType: UInt8(0x0),
            flags: UInt8(0x1),
            streamId: 3
        )
        let split =
            splitJinguiAcceptedTransportH2FrameWire(
                concatServerEngineAbstractionTestByteArrays(
                    [headersFrame, dataFrame]
                )
            )
        let headersSnapshot =
            parseJinguiAcceptedTransportH2FrameWire(split[0])
        let dataSnapshot =
            parseJinguiAcceptedTransportH2FrameWire(split[1])

        @Assert(split.size, 2)
        @Assert(headersSnapshot.frameType, UInt8(0x1))
        @Assert(headersSnapshot.flags, UInt8(0x4))
        @Assert(headersSnapshot.streamId, 1)
        @Assert(serverEngineAbstractionTestByteText(headersSnapshot.payload), "hdr")
        @Assert(dataSnapshot.frameType, UInt8(0x0))
        @Assert(dataSnapshot.flags, UInt8(0x1))
        @Assert(dataSnapshot.streamId, 3)
        @Assert(serverEngineAbstractionTestByteText(dataSnapshot.payload), "payload")
    }

    @TestCase
    public func testJinguiAcceptedTransportH2FrameWireAccumulatorDrainsOnlyCompleteFrames(): Unit {
        let headersFrame = buildServerEngineAbstractionTestH2FrameWire(
            serverEngineAbstractionTestByteArray("hdr".toArray()),
            frameType: UInt8(0x1),
            flags: UInt8(0x4),
            streamId: 1
        )
        let dataFrame = buildServerEngineAbstractionTestH2FrameWire(
            serverEngineAbstractionTestByteArray("payload".toArray()),
            frameType: UInt8(0x0),
            flags: UInt8(0x1),
            streamId: 5
        )
        let wire =
            concatServerEngineAbstractionTestByteArrays(
                [headersFrame, dataFrame]
            )
        let accumulator = JinguiAcceptedTransportH2FrameWireAccumulator()

        accumulator.append(
            cloneServerEngineAbstractionTestByteWindow(wire, 0, 5)
        )
        @Assert(accumulator.drainCompleteFrames().size, 0)
        @Assert(accumulator.bufferedByteCount(), 5)

        accumulator.append(
            cloneServerEngineAbstractionTestByteWindow(
                wire,
                5,
                headersFrame.size - 5
            )
        )
        let firstDrain = accumulator.drainCompleteFrames()
        @Assert(firstDrain.size, 1)
        @Assert(
            serverEngineAbstractionTestByteText(
                parseJinguiAcceptedTransportH2FrameWire(firstDrain[0]).payload
            ),
            "hdr"
        )

        accumulator.append(
            cloneServerEngineAbstractionTestByteWindow(
                wire,
                headersFrame.size,
                4
            )
        )
        @Assert(accumulator.drainCompleteFrames().size, 0)

        accumulator.append(
            cloneServerEngineAbstractionTestByteWindow(
                wire,
                headersFrame.size + 4,
                wire.size - headersFrame.size - 4
            )
        )
        let secondDrain = accumulator.drainCompleteFrames()
        @Assert(secondDrain.size, 1)
        @Assert(
            serverEngineAbstractionTestByteText(
                parseJinguiAcceptedTransportH2FrameWire(secondDrain[0]).payload
            ),
            "payload"
        )
        @Assert(
            parseJinguiAcceptedTransportH2FrameWire(secondDrain[0]).streamId,
            5
        )
        @Assert(accumulator.bufferedByteCount(), 0)
    }

    @TestCase
    public func testJinguiAcceptedTransportH2StreamLifecycleRegistryTracksTwoStreamsIndependently(): Unit {
        let registry = JinguiAcceptedTransportH2StreamLifecycleRegistry()

        registry.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                serverEngineAbstractionTestByteArray("s1".toArray())
            )
        )
        registry.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                3,
                true,
                false,
                false,
                false,
                0,
                0,
                serverEngineAbstractionTestByteArray("s3".toArray())
            )
        )

        @Assert(registry.streamCount(), 2)
        @Assert(registry.hasStream(1), true)
        @Assert(registry.hasStream(3), true)
        @Assert(registry.stateOf(1).toString(), "opened")
        @Assert(registry.stateOf(3).toString(), "half-closed-remote")

        registry.finishResponse(3)
        @Assert(registry.stateOf(3).toString(), "closed")
        @Assert(registry.snapshotOf(3).responseFinished, true)
        @Assert(registry.snapshotOf(3).remoteEndStreamSeen, true)

        let firstData =
            parseJinguiAcceptedTransportH2DataFrame(
                parseJinguiAcceptedTransportH2FrameWire(
                    buildServerEngineAbstractionTestH2FrameWire(
                        serverEngineAbstractionTestByteArray("part".toArray()),
                        frameType: UInt8(0x0),
                        flags: UInt8(0x0),
                        streamId: 1
                    )
                )
            )
        registry.observeData(firstData)
        @Assert(registry.stateOf(1).toString(), "opened")

        registry.finishResponse(1)
        @Assert(registry.stateOf(1).toString(), "half-closed-local")
        @Assert(registry.stateOf(3).toString(), "closed")

        let lastData =
            parseJinguiAcceptedTransportH2DataFrame(
                parseJinguiAcceptedTransportH2FrameWire(
                    buildServerEngineAbstractionTestH2FrameWire(
                        serverEngineAbstractionTestByteArray("done".toArray()),
                        frameType: UInt8(0x0),
                        flags: UInt8(0x1),
                        streamId: 1
                    )
                )
            )
        registry.observeData(lastData)
        @Assert(registry.stateOf(1).toString(), "closed")

        registry.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                5,
                false,
                false,
                false,
                false,
                0,
                0,
                serverEngineAbstractionTestByteArray("s5".toArray())
            )
        )
        registry.observeRstStreamFrame(
            parseJinguiAcceptedTransportH2FrameWire(
                buildServerEngineAbstractionTestH2FrameWire(
                    serverEngineAbstractionTestByteArray([UInt8(0), UInt8(0), UInt8(0), UInt8(0)]),
                    frameType: UInt8(0x3),
                    flags: UInt8(0x0),
                    streamId: 5
                )
            )
        )
        @Assert(registry.streamCount(), 3)
        @Assert(registry.stateOf(5).toString(), "reset")
        @Assert(registry.snapshotOf(5).resetSeen, true)
    }

    @TestCase
    public func testJinguiAcceptedTransportH2FlowBudgetModelReplenishesWindowWithoutProtocolError(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(8, 4)

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                serverEngineAbstractionTestByteArray("s1".toArray())
            )
        )

        let blockedByStreamWindow = model.trySpendData(1, 5)
        @Assert(blockedByStreamWindow.statusName, "waiting-for-window-update")
        @Assert(blockedByStreamWindow.canWrite, false)
        @Assert(blockedByStreamWindow.waitingForWindowUpdate, true)
        @Assert(blockedByStreamWindow.protocolError, false)
        @Assert(blockedByStreamWindow.connectionSendBudget, 8)
        @Assert(blockedByStreamWindow.streamSendBudget, 4)
        @Assert(blockedByStreamWindow.lifecycleStateName, "opened")

        let streamWindowUpdate =
            model.observeWindowUpdateFrame(
                parseJinguiAcceptedTransportH2FrameWire(
                    buildServerEngineAbstractionTestH2FrameWire(
                        serverEngineAbstractionTestByteArray([UInt8(0), UInt8(0), UInt8(0), UInt8(4)]),
                        frameType: UInt8(0x8),
                        flags: UInt8(0x0),
                        streamId: 1
                    )
                )
            )
        @Assert(streamWindowUpdate.connectionScoped, false)
        @Assert(streamWindowUpdate.increment, 4)
        @Assert(model.connectionSendBudget(), 8)
        @Assert(model.streamSendBudget(1), 8)

        let sentAfterStreamWindowUpdate = model.trySpendData(1, 5)
        @Assert(sentAfterStreamWindowUpdate.statusName, "sent")
        @Assert(sentAfterStreamWindowUpdate.canWrite, true)
        @Assert(sentAfterStreamWindowUpdate.waitingForWindowUpdate, false)
        @Assert(sentAfterStreamWindowUpdate.protocolError, false)
        @Assert(sentAfterStreamWindowUpdate.connectionSendBudget, 3)
        @Assert(sentAfterStreamWindowUpdate.streamSendBudget, 3)

        let blockedByBothWindows = model.trySpendData(1, 4)
        @Assert(blockedByBothWindows.statusName, "waiting-for-window-update")
        @Assert(blockedByBothWindows.protocolError, false)
        @Assert(blockedByBothWindows.connectionSendBudget, 3)
        @Assert(blockedByBothWindows.streamSendBudget, 3)

        let connectionWindowUpdate =
            model.observeWindowUpdateFrame(
                parseJinguiAcceptedTransportH2FrameWire(
                    buildServerEngineAbstractionTestH2FrameWire(
                        serverEngineAbstractionTestByteArray([UInt8(0), UInt8(0), UInt8(0), UInt8(8)]),
                        frameType: UInt8(0x8),
                        flags: UInt8(0x0),
                        streamId: 0
                    )
                )
            )
        @Assert(connectionWindowUpdate.connectionScoped, true)
        @Assert(connectionWindowUpdate.increment, 8)

        model.observeWindowUpdateFrame(
            parseJinguiAcceptedTransportH2FrameWire(
                buildServerEngineAbstractionTestH2FrameWire(
                    serverEngineAbstractionTestByteArray([UInt8(0), UInt8(0), UInt8(0), UInt8(2)]),
                    frameType: UInt8(0x8),
                    flags: UInt8(0x0),
                    streamId: 1
                )
            )
        )

        let sentAfterBothWindowUpdates = model.trySpendData(1, 4)
        @Assert(sentAfterBothWindowUpdates.statusName, "sent")
        @Assert(sentAfterBothWindowUpdates.protocolError, false)
        @Assert(sentAfterBothWindowUpdates.connectionSendBudget, 7)
        @Assert(sentAfterBothWindowUpdates.streamSendBudget, 1)
    }

    @TestCase
    public func testH2FlowBudgetDoesNotSpendStreamBudgetWhenOnlyConnectionWindowIsShort(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(3, 8)

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                serverEngineAbstractionTestByteArray("s1".toArray())
            )
        )

        let blockedByConnectionWindow = model.trySpendData(1, 4)
        @Assert(blockedByConnectionWindow.statusName, "waiting-for-window-update")
        @Assert(blockedByConnectionWindow.canWrite, false)
        @Assert(blockedByConnectionWindow.waitingForWindowUpdate, true)
        @Assert(blockedByConnectionWindow.protocolError, false)
        @Assert(blockedByConnectionWindow.connectionSendBudget, 3)
        @Assert(blockedByConnectionWindow.streamSendBudget, 8)

        let connectionWindowUpdate =
            model.observeWindowUpdateFrame(
                parseJinguiAcceptedTransportH2FrameWire(
                    buildServerEngineAbstractionTestH2FrameWire(
                        serverEngineAbstractionTestByteArray([
                            UInt8(0), UInt8(0), UInt8(0), UInt8(2)
                        ]),
                        frameType: UInt8(0x8),
                        flags: UInt8(0x0),
                        streamId: 0
                    )
                )
            )
        @Assert(connectionWindowUpdate.connectionScoped, true)

        let sentAfterConnectionWindowUpdate = model.trySpendData(1, 4)
        @Assert(sentAfterConnectionWindowUpdate.statusName, "sent")
        @Assert(sentAfterConnectionWindowUpdate.connectionSendBudget, 1)
        @Assert(sentAfterConnectionWindowUpdate.streamSendBudget, 4)
    }

    @TestCase
    public func testJinguiAcceptedTransportH2FlowBudgetModelClassifiesTimeoutRstAndGoawayAgainstLifecycle(): Unit {
        let timeoutModel = JinguiAcceptedTransportH2FlowBudgetModel(0, 0)
        timeoutModel.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                serverEngineAbstractionTestByteArray("s1".toArray())
            )
        )

        let timeoutDecision = timeoutModel.classifyTimeout(1)
        @Assert(timeoutDecision.statusName, "timed-out-waiting-for-window-update")
        @Assert(timeoutDecision.waitingForWindowUpdate, true)
        @Assert(timeoutDecision.protocolError, false)
        @Assert(timeoutDecision.lifecycleStateName, "opened")

        timeoutModel.observeRstStreamFrame(
            parseJinguiAcceptedTransportH2FrameWire(
                buildServerEngineAbstractionTestH2FrameWire(
                    serverEngineAbstractionTestByteArray([UInt8(0), UInt8(0), UInt8(0), UInt8(0)]),
                    frameType: UInt8(0x3),
                    flags: UInt8(0x0),
                    streamId: 1
                )
            )
        )
        let resetDecision = timeoutModel.trySpendData(1, 1)
        @Assert(resetDecision.statusName, "stream-closed")
        @Assert(resetDecision.protocolError, false)
        @Assert(resetDecision.lifecycleStateName, "reset")

        let goawayModel = JinguiAcceptedTransportH2FlowBudgetModel(8, 8)
        goawayModel.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                3,
                false,
                false,
                false,
                false,
                0,
                0,
                serverEngineAbstractionTestByteArray("s3".toArray())
            )
        )
        goawayModel.observeGoawayFrame(
            parseJinguiAcceptedTransportH2FrameWire(
                buildServerEngineAbstractionTestH2FrameWire(
                    serverEngineAbstractionTestByteArray([
                        UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                        UInt8(0), UInt8(0), UInt8(0), UInt8(0)
                    ]),
                    frameType: UInt8(0x7),
                    flags: UInt8(0x0),
                    streamId: 0
                )
            )
        )
        let goawayDecision = goawayModel.trySpendData(3, 1)
        @Assert(goawayDecision.statusName, "connection-closed")
        @Assert(goawayDecision.protocolError, false)
        @Assert(goawayDecision.lifecycleStateName, "opened")
    }

    @TestCase
    public func testJinguiAcceptedTransportH2HeaderBlockFragmentParseCanDecodePaddedPriorityHeadersPayload(): Unit {
        let headersFrame = parseJinguiAcceptedTransportH2FrameWire(
            buildServerEngineAbstractionTestH2FrameWire(
                buildServerEngineAbstractionTestH2HeadersPayload(
                    serverEngineAbstractionTestByteArray("abc".toArray()),
                    padded: true,
                    padLength: 2,
                    priorityPresented: true,
                    exclusiveDependency: true,
                    streamDependency: 3,
                    weight: 15
                ),
                frameType: UInt8(0x1),
                flags: UInt8(0x2c),
                streamId: 7
            )
        )
        let fragment =
            parseJinguiAcceptedTransportH2HeaderBlockFragment(headersFrame)

        @Assert(fragment.frameType, UInt8(0x1))
        @Assert(fragment.streamId, 7)
        @Assert(fragment.endHeaders, true)
        @Assert(fragment.endStream, false)
        @Assert(fragment.padded, true)
        @Assert(fragment.padLength, 2)
        @Assert(fragment.priorityPresented, true)
        @Assert(fragment.exclusiveDependency, true)
        @Assert(fragment.streamDependency, 3)
        @Assert(fragment.weight, 15)
        @Assert(
            serverEngineAbstractionTestByteText(
                fragment.headerBlockFragment
            ),
            "abc"
        )
    }

    @TestCase
    public func testJinguiAcceptedTransportH2HeaderBlockAccumulatorCanAssembleHeadersAndContinuationFrames(): Unit {
        let headersFrame = parseJinguiAcceptedTransportH2FrameWire(
            buildServerEngineAbstractionTestH2FrameWire(
                buildServerEngineAbstractionTestH2HeadersPayload(
                    serverEngineAbstractionTestByteArray("abc".toArray())
                ),
                frameType: UInt8(0x1),
                flags: UInt8(0x1),
                streamId: 11
            )
        )
        let continuationFrame = parseJinguiAcceptedTransportH2FrameWire(
            buildServerEngineAbstractionTestH2FrameWire(
                serverEngineAbstractionTestByteArray("def".toArray()),
                frameType: UInt8(0x9),
                flags: UInt8(0x4),
                streamId: 11
            )
        )
        let accumulator = JinguiAcceptedTransportH2HeaderBlockAccumulator()

        accumulator.append(headersFrame)
        @Assert(accumulator.hasOpenHeaderBlock(), true)
        @Assert(accumulator.bufferedHeaderBlockByteCount(), 3)
        @Assert(accumulator.drainCompleteHeaderBlocks().size, 0)

        accumulator.append(continuationFrame)
        let completed = accumulator.drainCompleteHeaderBlocks()
        let snapshot = completed[0]

        @Assert(completed.size, 1)
        @Assert(snapshot.streamId, 11)
        @Assert(snapshot.endStream, true)
        @Assert(snapshot.padded, false)
        @Assert(snapshot.priorityPresented, false)
        @Assert(snapshot.exclusiveDependency, false)
        @Assert(snapshot.streamDependency, 0)
        @Assert(snapshot.weight, 0)
        @Assert(
            serverEngineAbstractionTestByteText(
                snapshot.headerBlockFragment
            ),
            "abcdef"
        )
        @Assert(accumulator.hasOpenHeaderBlock(), false)
        @Assert(accumulator.bufferedHeaderBlockByteCount(), 0)
    }

    @TestCase
    public func testJinguiAcceptedTransportH2HeaderBlockIngressAccumulatorCanDrainFragmentedLiveWireIntoHeaderBlock(): Unit {
        let headersWire = buildServerEngineAbstractionTestH2FrameWire(
            buildServerEngineAbstractionTestH2HeadersPayload(
                serverEngineAbstractionTestByteArray("abc".toArray())
            ),
            frameType: UInt8(0x1),
            flags: UInt8(0x1),
            streamId: 23
        )
        let continuationWire = buildServerEngineAbstractionTestH2FrameWire(
            serverEngineAbstractionTestByteArray("def".toArray()),
            frameType: UInt8(0x9),
            flags: UInt8(0x4),
            streamId: 23
        )
        let ingress = JinguiAcceptedTransportH2HeaderBlockIngressAccumulator()

        ingress.append(cloneServerEngineByteWindow(headersWire, 0, 5))
        @Assert(ingress.bufferedByteCount(), 5)
        @Assert(ingress.hasOpenHeaderBlock(), false)
        @Assert(ingress.drainCompleteHeaderBlocks().size, 0)

        ingress.append(
            concatServerEngineAbstractionTestByteArrays([
                cloneServerEngineByteWindow(
                    headersWire,
                    5,
                    headersWire.size - 5
                ),
                cloneServerEngineByteWindow(continuationWire, 0, 4)
            ])
        )
        @Assert(ingress.bufferedByteCount(), 4)
        @Assert(ingress.hasOpenHeaderBlock(), true)
        @Assert(ingress.bufferedHeaderBlockByteCount(), 3)
        @Assert(ingress.drainCompleteHeaderBlocks().size, 0)

        ingress.append(
            cloneServerEngineByteWindow(
                continuationWire,
                4,
                continuationWire.size - 4
            )
        )
        let completed = ingress.drainCompleteHeaderBlocks()
        let snapshot = completed[0]

        @Assert(completed.size, 1)
        @Assert(ingress.bufferedByteCount(), 0)
        @Assert(ingress.hasOpenHeaderBlock(), false)
        @Assert(snapshot.streamId, 23)
        @Assert(snapshot.endStream, true)
        @Assert(
            serverEngineAbstractionTestByteText(
                snapshot.headerBlockFragment
            ),
            "abcdef"
        )
    }

    @TestCase
    public func testJinguiAcceptedTransportH2HeaderBlockIngressAccumulatorRejectsInterleavedNonContinuationFrame(): Unit {
        let headersWire = buildServerEngineAbstractionTestH2FrameWire(
            buildServerEngineAbstractionTestH2HeadersPayload(
                serverEngineAbstractionTestByteArray("abc".toArray())
            ),
            frameType: UInt8(0x1),
            flags: UInt8(0x1),
            streamId: 29
        )
        let dataWire = buildServerEngineAbstractionTestH2FrameWire(
            serverEngineAbstractionTestByteArray("body".toArray()),
            frameType: UInt8(0x0),
            flags: UInt8(0x0),
            streamId: 29
        )
        let ingress = JinguiAcceptedTransportH2HeaderBlockIngressAccumulator()

        try {
            ingress.append(
                concatServerEngineAbstractionTestByteArrays([
                    headersWire,
                    dataWire
                ])
            )
            @Fail("expected open header-block non-continuation rejection")
        } catch (e: Exception) {
            @Assert(
                contains(
                    e.message,
                    "expects CONTINUATION while one header block is open"
                ),
                true
            )
        }
    }

    @TestCase
    public func testInjectedServerEngineCanDrainAcceptedTransportApplicationDataFragmentedRecordWireIntoHeaderBlock(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let engine =
            JinguiAcceptedTransportApplicationDataH2HeaderBlockIngressAccumulatorProbeEngine()
        app.serverEngine(engine)

        app.listen("127.0.0.1", UInt16(38152))

        @Assert(engine.firstBufferedRecordWireByteCount, 4)
        @Assert(engine.firstCompletedHeaderBlockCount, 0)
        @Assert(engine.midBufferedRecordWireByteCount > 0, true)
        @Assert(engine.midHasOpenHeaderBlock, true)
        @Assert(engine.midBufferedHeaderBlockByteCount, 3)
        @Assert(engine.midCompletedHeaderBlockCount, 0)
        @Assert(engine.completedHeaderBlockCount, 1)
        @Assert(engine.completedHeaderBlockStreamId, 41)
        @Assert(engine.completedHeaderBlockEndStream, true)
        @Assert(engine.completedHeaderBlockText, "abcdef")
        @Assert(engine.finalBufferedRecordWireByteCount, 0)
        @Assert(engine.finalBufferedH2FrameWireByteCount, 0)
        @Assert(engine.finalHasOpenHeaderBlock, false)
    }

    @TestCase
    public func testInjectedServerEngineRejectsAcceptedTransportApplicationDataFragmentedRecordWireWithInterleavedNonContinuationFrame(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let engine =
            JinguiAcceptedTransportApplicationDataH2HeaderBlockIngressAccumulatorRejectProbeEngine()
        app.serverEngine(engine)

        app.listen("127.0.0.1", UInt16(38153))

        @Assert(
            contains(
                engine.observedError,
                "expects CONTINUATION while one header block is open"
            ),
            true
        )
    }

    @TestCase
    public func testInjectedServerEngineCanDrainAcceptedTransportApplicationDataFragmentedRecordWireIntoLogicalRequest(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let engine =
            JinguiAcceptedTransportApplicationDataLogicalRequestAccumulatorProbeEngine()
        app.serverEngine(engine)

        app.listen("127.0.0.1", UInt16(38154))

        @Assert(engine.firstCompletedLogicalRequestCount, 0)
        @Assert(engine.midCompletedLogicalRequestCount, 0)
        @Assert(engine.midHasOpenHeaderBlock, true)
        @Assert(engine.midBufferedHeaderBlockByteCount > 0, true)
        @Assert(engine.completedLogicalRequestCount, 1)
        @Assert(engine.requestMethod, "GET")
        @Assert(engine.requestPath, "/appdata")
        @Assert(engine.requestUrl, "/appdata?turn=ok")
        @Assert(engine.requestQuery, "turn=ok")
        @Assert(engine.requestVersion, "h2")
        @Assert(engine.requestHost, "api.example.com:9443")
        @Assert(engine.requestMode, "bridge")
        @Assert(engine.requestBody, "payload")
        @Assert(engine.finalBufferedRecordWireByteCount, 0)
        @Assert(engine.finalBufferedH2FrameWireByteCount, 0)
        @Assert(engine.finalHasOpenHeaderBlock, false)
    }

    @TestCase
    public func testInjectedServerEngineRejectsAcceptedTransportApplicationDataFragmentedRecordWireMultipleHeaderBlocksForLogicalRequestProjection(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let engine =
            JinguiAcceptedTransportApplicationDataLogicalRequestAccumulatorRejectProbeEngine()
        app.serverEngine(engine)

        app.listen("127.0.0.1", UInt16(38155))

        @Assert(
            contains(
                engine.observedError,
                "logical-request projection expects exactly one complete H2 header block"
            ),
            true
        )
    }

    @TestCase
    public func testInjectedServerEngineCanDrainAcceptedTransportApplicationDataFragmentedRecordWireIntoHeadersPlusDataLogicalRequest(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let engine =
            JinguiAcceptedTransportApplicationDataHeadersPlusDataLogicalRequestAccumulatorProbeEngine()
        app.serverEngine(engine)

        app.listen("127.0.0.1", UInt16(38156))

        @Assert(engine.firstCompletedLogicalRequestCount, 0)
        @Assert(engine.midCompletedLogicalRequestCount, 0)
        @Assert(engine.midHasOpenHeaderBlock, false)
        @Assert(engine.midBufferedHeaderBlockByteCount, 0)
        @Assert(engine.midBufferedBodyByteCount > 0, true)
        @Assert(engine.completedLogicalRequestCount, 1)
        @Assert(engine.requestMethod, "POST")
        @Assert(engine.requestPath, "/appdata-data")
        @Assert(engine.requestUrl, "/appdata-data?turn=ok")
        @Assert(engine.requestQuery, "turn=ok")
        @Assert(engine.requestVersion, "h2")
        @Assert(engine.requestHost, "api.example.com:9443")
        @Assert(engine.requestMode, "bridge-data")
        @Assert(engine.requestBody, "accepted-appdata-body")
        @Assert(engine.finalBufferedRecordWireByteCount, 0)
        @Assert(engine.finalBufferedH2FrameWireByteCount, 0)
        @Assert(engine.finalHasOpenHeaderBlock, false)
        @Assert(engine.finalBufferedBodyByteCount, 0)
    }

    @TestCase
    public func testInjectedServerEngineRejectsWrongStreamAcceptedTransportApplicationDataFragmentedRecordWireDataForLogicalRequest(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let engine =
            JinguiAcceptedTransportApplicationDataHeadersPlusDataLogicalRequestAccumulatorRejectProbeEngine()
        app.serverEngine(engine)

        app.listen("127.0.0.1", UInt16(38157))

        @Assert(
            contains(
                engine.observedError,
                "requires same-stream DATA"
            ),
            true
        )
    }

    @TestCase
    public func testInjectedServerEngineCanServeAcceptedTransportApplicationDataFragmentedRecordWireHeadersPlusDataRequestTurn(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.post("/carrier-appdata-data-turn-body-string", { ctx =>
            let body = ctx.bodyString()
            let _ = ctx
                .setHeader("x-carrier-appdata-data-turn-body", "1")
                .sendString("body:${body}")
        })
        app.post("/carrier-appdata-data-turn-body-json", { ctx =>
            let reader = ctx.requestJsonReader()
            reader.startObject()
            let firstName = reader.readName()
            let firstValue = reader.readValue<String>()
            let secondName = reader.readName()
            let secondValue = reader.readValue<Int64>()
            reader.endObject()
            let _ = ctx
                .setHeader("x-carrier-appdata-data-turn-body-json", "1")
                .sendString("${firstName}:${firstValue}:${secondName}:${secondValue}")
        })
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportApplicationDataFragmentedRecordWireHeadersPlusDataRequestTurnProbeEngine()
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let bodyStringWire =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let bodyJsonWire =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(engine.bodyStringReadyStatus, "READY")
        @Assert(engine.bodyJsonReadyStatus, "READY")
        @Assert(
            engine.openBodyStringSocketWire(bodyStringWire),
            "body:accepted-appdata-body"
        )
        @Assert(
            engine.openBodyJsonSocketWire(bodyJsonWire),
            "name:ignite:val:23"
        )
        @Assert(engine.bodyStringResponseStatus, UInt16(200))
        @Assert(engine.bodyJsonResponseStatus, UInt16(200))
        @Assert(
            engine.bodyStringContentType,
            "text/plain; charset=utf-8"
        )
        @Assert(
            engine.bodyJsonContentType,
            "text/plain; charset=utf-8"
        )
        @Assert(engine.bodyStringTransferEncoding, "")
        @Assert(engine.bodyJsonTransferEncoding, "")
        @Assert(engine.bodyStringSocketWriteCount >= 1, true)
        @Assert(engine.bodyJsonSocketWriteCount >= 1, true)
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "ready")
                @Assert(event.scheme, "https")
            case None => @Fail("expected startup observe ready event")
        }
    }

    @TestCase
    public func testInjectedServerEngineRejectsWrongStreamAcceptedTransportApplicationDataFragmentedRecordWireDataForRequestTurn(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportApplicationDataFragmentedRecordWireHeadersPlusDataRequestTurnRejectProbeEngine()
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let _ =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(
            contains(
                engine.observedError,
                "requires same-stream DATA"
            ),
            true
        )
    }

    @TestCase
    public func testInjectedServerEngineCanServeAcceptedTransportSessionAcceptedSocketApplicationDataFragmentedRecordWireHeadersPlusDataRequestTurn(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.post("/carrier-appdata-data-turn-body-string", { ctx =>
            let body = ctx.bodyString()
            let _ = ctx
                .setHeader("x-carrier-appdata-data-turn-body", "1")
                .sendString("body:${body}")
        })
        app.post("/carrier-appdata-data-turn-body-json", { ctx =>
            let reader = ctx.requestJsonReader()
            reader.startObject()
            let firstName = reader.readName()
            let firstValue = reader.readValue<String>()
            let secondName = reader.readName()
            let secondValue = reader.readValue<Int64>()
            reader.endObject()
            let _ = ctx
                .setHeader("x-carrier-appdata-data-turn-body-json", "1")
                .sendString("${firstName}:${firstValue}:${secondName}:${secondValue}")
        })
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportAcceptedSocketApplicationDataFragmentedRecordWireHeadersPlusDataRequestTurnProbeEngine()
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let bodyStringWire =
            runAcceptedTransportRequestResponseSocketSinkClient(
                "127.0.0.1",
                port,
                "accepted-socket fragmented headers-plus-data bodyString request",
                { => engine.bodyStringRequestWireFragments },
                writePauseMillis: 20
            )
        let bodyJsonWire =
            runAcceptedTransportRequestResponseSocketSinkClient(
                "127.0.0.1",
                port,
                "accepted-socket fragmented headers-plus-data bodyJson request",
                { => engine.bodyJsonRequestWireFragments },
                writePauseMillis: 20
            )
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(engine.bodyStringReadyStatus, "READY")
        @Assert(engine.bodyJsonReadyStatus, "READY")
        @Assert(
            engine.openBodyStringSocketWire(bodyStringWire),
            "body:accepted-appdata-body"
        )
        @Assert(
            engine.openBodyJsonSocketWire(bodyJsonWire),
            "name:ignite:val:23"
        )
        @Assert(engine.bodyStringResponseStatus, UInt16(200))
        @Assert(engine.bodyJsonResponseStatus, UInt16(200))
        @Assert(
            engine.bodyStringContentType,
            "text/plain; charset=utf-8"
        )
        @Assert(
            engine.bodyJsonContentType,
            "text/plain; charset=utf-8"
        )
        @Assert(engine.bodyStringTransferEncoding, "")
        @Assert(engine.bodyJsonTransferEncoding, "")
        @Assert(engine.bodyStringSocketWriteCount >= 1, true)
        @Assert(engine.bodyJsonSocketWriteCount >= 1, true)
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "ready")
                @Assert(event.scheme, "https")
            case None => @Fail("expected startup observe ready event")
        }
    }

    @TestCase
    public func testInjectedServerEngineCanReadAcceptedSocketApplicationDataTrailingHeadersAsRequestTrailers(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.post("/trailers", { ctx =>
            let body = ctx.bodyString()
            let trailer = ctx.trailer("x-request-trailer") ?? ""
            let _ = ctx
                .setHeader("x-accepted-socket-trailer", trailer)
                .sendString("body:${body};trailer:${trailer}")
        })
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportAcceptedSocketApplicationDataFragmentedRecordWireTrailingHeadersRequestTurnProbeEngine()
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let responseWire =
            runAcceptedTransportRequestResponseSocketSinkClient(
                "127.0.0.1",
                port,
                "accepted-socket fragmented headers-plus-data trailing headers request",
                { => engine.requestWireFragments },
                writePauseMillis: 20
            )
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(engine.readyStatus, "READY")
        @Assert(engine.responseStatus, UInt16(200))
        @Assert(engine.responseTrailerHeader, "tail")
        @Assert(
            engine.openSocketWire(responseWire),
            "body:accepted-body;trailer:tail"
        )
        @Assert(engine.contentType, "text/plain; charset=utf-8")
        @Assert(engine.transferEncoding, "")
        @Assert(engine.socketWriteCount >= 1, true)
    }

    @TestCase
    public func testInjectedServerEngineCanReadAcceptedSocketApplicationDataTrailingContinuationAsRequestTrailers(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.post("/trailers", { ctx =>
            let body = ctx.bodyString()
            let trailer = ctx.trailer("x-request-trailer") ?? ""
            let _ = ctx
                .setHeader("x-accepted-socket-trailer", trailer)
                .sendString("body:${body};trailer:${trailer}")
        })
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportAcceptedSocketApplicationDataFragmentedRecordWireTrailingHeadersRequestTurnProbeEngine(
                splitTrailingHeaderBlock: true
            )
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let responseWire =
            runAcceptedTransportRequestResponseSocketSinkClient(
                "127.0.0.1",
                port,
                "accepted-socket fragmented headers-plus-data trailing continuation request",
                { => engine.requestWireFragments },
                writePauseMillis: 20
            )
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(engine.readyStatus, "READY")
        @Assert(engine.responseStatus, UInt16(200))
        @Assert(engine.responseTrailerHeader, "tail")
        @Assert(
            engine.openSocketWire(responseWire),
            "body:accepted-body;trailer:tail"
        )
        @Assert(engine.contentType, "text/plain; charset=utf-8")
        @Assert(engine.transferEncoding, "")
        @Assert(engine.socketWriteCount >= 1, true)
    }

    @TestCase
    public func testInjectedServerEngineRejectsWrongStreamAcceptedTransportSessionAcceptedSocketApplicationDataFragmentedRecordWireDataForRequestTurn(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportAcceptedSocketApplicationDataFragmentedRecordWireHeadersPlusDataRequestTurnRejectProbeEngine()
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let _ =
            runAcceptedTransportRequestResponseSocketSinkClient(
                "127.0.0.1",
                port,
                "accepted-socket fragmented headers-plus-data reject request",
                { => engine.requestWireFragments },
                writePauseMillis: 20
            )
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(
            contains(
                engine.observedError,
                "requires same-stream DATA"
            ),
            true
        )
    }

    @TestCase
    public func testInjectedServerEngineRejectsAcceptedSocketTrailingHeadersWithoutEndStream(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportAcceptedSocketApplicationDataFragmentedRecordWireHeadersPlusDataRequestTurnRejectProbeEngine(
                rejectMode: "trailing-headers-without-end-stream"
            )
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let _ =
            runAcceptedTransportRequestResponseSocketSinkClient(
                "127.0.0.1",
                port,
                "accepted-socket fragmented trailing headers without end-stream reject request",
                { => engine.requestWireFragments },
                writePauseMillis: 20
            )
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(
            contains(
                engine.observedError,
                "expects trailing HEADERS to carry END_STREAM"
            ),
            true
        )
    }

    @TestCase
    public func testInjectedServerEngineRejectsAcceptedSocketTrailingHeadersBeforeData(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportAcceptedSocketApplicationDataFragmentedRecordWireHeadersPlusDataRequestTurnRejectProbeEngine(
                rejectMode: "trailing-headers-before-data"
            )
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let _ =
            runAcceptedTransportRequestResponseSocketSinkClient(
                "127.0.0.1",
                port,
                "accepted-socket fragmented trailing headers before data reject request",
                { => engine.requestWireFragments },
                writePauseMillis: 20
            )
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(
            contains(
                engine.observedError,
                "expects at least one same-stream H2 DATA frame before trailing HEADERS"
            ),
            true
        )
    }

    @TestCase
    public func testInjectedServerEngineRejectsAcceptedSocketTrailingContinuationStreamIdMismatch(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportAcceptedSocketApplicationDataFragmentedRecordWireHeadersPlusDataRequestTurnRejectProbeEngine(
                rejectMode: "trailing-continuation-stream-mismatch"
            )
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let _ =
            runAcceptedTransportRequestResponseSocketSinkClient(
                "127.0.0.1",
                port,
                "accepted-socket fragmented trailing continuation stream mismatch reject request",
                { => engine.requestWireFragments },
                writePauseMillis: 20
            )
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(
            contains(
                engine.observedError,
                "H2 CONTINUATION streamId must match open header block"
            ),
            true
        )
    }

    @TestCase
    public func testInjectedServerEngineRejectsAcceptedSocketOrphanTrailingContinuation(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportAcceptedSocketApplicationDataFragmentedRecordWireHeadersPlusDataRequestTurnRejectProbeEngine(
                rejectMode: "orphan-trailing-continuation"
            )
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let _ =
            runAcceptedTransportRequestResponseSocketSinkClient(
                "127.0.0.1",
                port,
                "accepted-socket fragmented orphan trailing continuation reject request",
                { => engine.requestWireFragments },
                writePauseMillis: 20
            )
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(
            contains(
                engine.observedError,
                "H2 header-block accumulator expects HEADERS frame first"
            ),
            true
        )
    }

    @TestCase
    public func testInjectedServerEngineRejectsAcceptedSocketDataAfterTrailingHeaders(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportAcceptedSocketApplicationDataFragmentedRecordWireHeadersPlusDataRequestTurnRejectProbeEngine(
                rejectMode: "data-after-trailing-headers"
            )
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        var clientError: String = ""
        try {
            let _ =
                runAcceptedTransportRequestResponseSocketSinkClient(
                    "127.0.0.1",
                    port,
                    "accepted-socket fragmented data after trailing headers reject request",
                    { => engine.requestWireFragments },
                    writePauseMillis: 0
                )
        } catch (e: Exception) {
            clientError = e.message
        }
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(
            contains(
                engine.observedError,
                "expects fully drained ingress after one logical request"
            ),
            true
        )
        @Assert(
            clientError == "" ||
                contains(clientError, "Connection reset") ||
                contains(clientError, "Broken pipe"),
            true
        )
    }

    @TestCase
    public func testInjectedServerEngineCanCaptureAcceptedTransportSocketFragmentedTlsHandshakeClientHello(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloCaptureProbeEngine()
        app.serverEngine(engine)

        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 2240))
        )
        let clientHelloWire =
            buildServerEngineAbstractionTestTlsRecordWire(
                clientHello.encodedClientHello
            )
        let clientHelloFragments = [
            cloneServerEngineByteWindow(clientHelloWire, 0, 7),
            cloneServerEngineByteWindow(clientHelloWire, 7, 11),
            cloneServerEngineByteWindow(
                clientHelloWire,
                18,
                clientHelloWire.size - 18
            )
        ]

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        runAcceptedTransportOneWaySocketClient(
            "127.0.0.1",
            port,
            clientHelloFragments,
            writePauseMillis: 20
        )
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(
            serverEngineAbstractionTestByteArraysEqual(
                engine.capturedClientHello,
                clientHello.encodedClientHello
            ),
            true
        )
        @Assert(engine.capturedRecordCount, 1)
        @Assert(engine.capturedRecordWireByteCount, clientHelloWire.size)
    }

    @TestCase
    public func testInjectedServerEngineRejectsAcceptedTransportSocketNonHandshakeRecordDuringTlsClientHelloCapture(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloCaptureRejectProbeEngine()
        app.serverEngine(engine)

        let wrongRecordWire = buildServerEngineAbstractionTestTlsRecordWire(
            serverEngineAbstractionTestByteArray("oops".toArray()),
            contentType: UInt8(0x17)
        )

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        runAcceptedTransportOneWaySocketClient(
            "127.0.0.1",
            port,
            [
                cloneServerEngineByteWindow(
                    wrongRecordWire,
                    0,
                    wrongRecordWire.size
                )
            ]
        )
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(
            contains(
                engine.observedError,
                "expected handshake record contentType=22"
            ),
            true
        )
    }

    @TestCase
    public func testInjectedServerEngineCanAttachAcceptedTransportSocketFromFragmentedTlsHandshakeClientHello(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloAttachProbeEngine()
        app.serverEngine(engine)

        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 2272))
        )
        let clientHelloWire =
            buildServerEngineAbstractionTestTlsRecordWire(
                clientHello.encodedClientHello
            )

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        runAcceptedTransportOneWaySocketClient(
            "127.0.0.1",
            port,
            [
                cloneServerEngineByteWindow(clientHelloWire, 0, 9),
                cloneServerEngineByteWindow(clientHelloWire, 9, 13),
                cloneServerEngineByteWindow(
                    clientHelloWire,
                    22,
                    clientHelloWire.size - 22
                )
            ],
            writePauseMillis: 20
        )
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(
            serverEngineAbstractionTestByteArraysEqual(
                engine.capturedClientHello,
                clientHello.encodedClientHello
            ),
            true
        )
        @Assert(engine.capturedRecordCount, 1)
        @Assert(engine.capturedRecordWireByteCount, clientHelloWire.size)
        @Assert(engine.readyStatus, "READY")
        @Assert(engine.secureSessionReady, true)
        @Assert(engine.negotiatedAlpn, "h2")
        @Assert(engine.requestedServerName, "www.example.com")
        @Assert(engine.acknowledgedServerName, true)
        @Assert(engine.attachSurface, "accepted-transport-session")
        @Assert(
            engine.transportId,
            "captured-clienthello-attach-transport"
        )
    }

    @TestCase
    public func testInjectedServerEngineRejectsAcceptedTransportSocketAttachWhenTlsHandshakeDoesNotStartWithClientHelloRecord(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloAttachRejectProbeEngine()
        app.serverEngine(engine)

        let wrongRecordWire = buildServerEngineAbstractionTestTlsRecordWire(
            serverEngineAbstractionTestByteArray("oops".toArray()),
            contentType: UInt8(0x17)
        )

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        runAcceptedTransportOneWaySocketClient(
            "127.0.0.1",
            port,
            [
                cloneServerEngineByteWindow(
                    wrongRecordWire,
                    0,
                    wrongRecordWire.size
                )
            ]
        )
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(
            contains(
                engine.observedError,
                "expected handshake record contentType=22"
            ),
            true
        )
    }

    @TestCase
    public func testInjectedServerEngineCanServeAcceptedTransportSocketFragmentedTlsHandshakeClientHelloLogicalRequest(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.post("/carrier-captured-logical-body-string", { ctx =>
            let body = ctx.bodyString()
            let _ = ctx
                .setHeader("x-captured-logical-body", "1")
                .sendString("body:${body}")
        })
        app.post("/carrier-captured-logical-body-json", { ctx =>
            let reader = ctx.requestJsonReader()
            reader.startObject()
            let firstName = reader.readName()
            let firstValue = reader.readValue<String>()
            let secondName = reader.readName()
            let secondValue = reader.readValue<Int64>()
            reader.endObject()
            let _ = ctx
                .setHeader("x-captured-logical-body-json", "1")
                .sendString("${firstName}:${firstValue}:${secondName}:${secondValue}")
        })
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloLogicalRequestProbeEngine()
        app.serverEngine(engine)

        let bodyStringHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 2528))
        )
        let bodyJsonHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 2560))
        )
        let bodyStringHelloWire =
            buildServerEngineAbstractionTestTlsRecordWire(
                bodyStringHello.encodedClientHello
            )
        let bodyJsonHelloWire =
            buildServerEngineAbstractionTestTlsRecordWire(
                bodyJsonHello.encodedClientHello
            )

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let bodyStringWire =
            runAcceptedTransportTlsHandshakeRequestResponseSocketSinkClient(
                "127.0.0.1",
                port,
                [
                    cloneServerEngineByteWindow(bodyStringHelloWire, 0, 6),
                    cloneServerEngineByteWindow(bodyStringHelloWire, 6, 10),
                    cloneServerEngineByteWindow(
                        bodyStringHelloWire,
                        16,
                        bodyStringHelloWire.size - 16
                    )
                ],
                "captured-clienthello logical-request bodyString request",
                { => Some([]) },
                writePauseMillis: 20
            )
        let bodyJsonWire =
            runAcceptedTransportTlsHandshakeRequestResponseSocketSinkClient(
                "127.0.0.1",
                port,
                [
                    cloneServerEngineByteWindow(bodyJsonHelloWire, 0, 8),
                    cloneServerEngineByteWindow(bodyJsonHelloWire, 8, 9),
                    cloneServerEngineByteWindow(
                        bodyJsonHelloWire,
                        17,
                        bodyJsonHelloWire.size - 17
                    )
                ],
                "captured-clienthello logical-request bodyJson request",
                { => Some([]) },
                writePauseMillis: 20
            )
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(engine.bodyStringReadyStatus, "READY")
        @Assert(engine.bodyJsonReadyStatus, "READY")
        @Assert(engine.bodyStringNegotiatedAlpn, "h2")
        @Assert(engine.bodyJsonNegotiatedAlpn, "h2")
        @Assert(engine.bodyStringRequestedServerName, "www.example.com")
        @Assert(engine.bodyJsonRequestedServerName, "www.example.com")
        @Assert(engine.bodyStringAttachSurface, "accepted-transport-session")
        @Assert(engine.bodyJsonAttachSurface, "accepted-transport-session")
        @Assert(
            engine.openBodyStringSocketWire(bodyStringWire),
            "body:accepted-body"
        )
        @Assert(
            engine.openBodyJsonSocketWire(bodyJsonWire),
            "name:ignite:val:23"
        )
        @Assert(engine.bodyStringResponseStatus, UInt16(200))
        @Assert(engine.bodyJsonResponseStatus, UInt16(200))
        @Assert(
            engine.bodyStringContentType,
            "text/plain; charset=utf-8"
        )
        @Assert(
            engine.bodyJsonContentType,
            "text/plain; charset=utf-8"
        )
        @Assert(engine.bodyStringTransferEncoding, "")
        @Assert(engine.bodyJsonTransferEncoding, "")
        @Assert(engine.bodyStringSocketWriteCount >= 1, true)
        @Assert(engine.bodyJsonSocketWriteCount >= 1, true)
        @Assert(
            engine.bodyStringTransportId,
            "captured-clienthello-logical-request-body-string-transport"
        )
        @Assert(
            engine.bodyJsonTransportId,
            "captured-clienthello-logical-request-body-json-transport"
        )
    }

    @TestCase
    public func testInjectedServerEngineRejectsAcceptedTransportSocketFragmentedTlsHandshakeClientHelloLogicalRequestWhenTlsHandshakeDoesNotStartWithClientHelloRecord(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloLogicalRequestRejectProbeEngine()
        app.serverEngine(engine)

        let wrongRecordWire = buildServerEngineAbstractionTestTlsRecordWire(
            serverEngineAbstractionTestByteArray("oops".toArray()),
            contentType: UInt8(0x17)
        )

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        runAcceptedTransportOneWaySocketClient(
            "127.0.0.1",
            port,
            [
                cloneServerEngineByteWindow(
                    wrongRecordWire,
                    0,
                    wrongRecordWire.size
                )
            ]
        )
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(
            contains(
                engine.observedError,
                "expected handshake record contentType=22"
            ),
            true
        )
    }

    @TestCase
    public func testInjectedServerEngineCanServeAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataFragmentedRecordWireHeadersPlusDataRequestTurn(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.post("/carrier-appdata-data-turn-body-string", { ctx =>
            let body = ctx.bodyString()
            let _ = ctx
                .setHeader("x-carrier-appdata-data-turn-body", "1")
                .sendString("body:${body}")
        })
        app.post("/carrier-appdata-data-turn-body-json", { ctx =>
            let reader = ctx.requestJsonReader()
            reader.startObject()
            let firstName = reader.readName()
            let firstValue = reader.readValue<String>()
            let secondName = reader.readName()
            let secondValue = reader.readValue<Int64>()
            reader.endObject()
            let _ = ctx
                .setHeader("x-carrier-appdata-data-turn-body-json", "1")
                .sendString("${firstName}:${firstValue}:${secondName}:${secondValue}")
        })
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloRequestTurnProbeEngine()
        app.serverEngine(engine)

        let bodyStringHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 2368))
        )
        let bodyJsonHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 2400))
        )
        let bodyStringHelloWire =
            buildServerEngineAbstractionTestTlsRecordWire(
                bodyStringHello.encodedClientHello
            )
        let bodyJsonHelloWire =
            buildServerEngineAbstractionTestTlsRecordWire(
                bodyJsonHello.encodedClientHello
            )

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let bodyStringWire =
            runAcceptedTransportTlsHandshakeRequestResponseSocketSinkClient(
                "127.0.0.1",
                port,
                [
                    cloneServerEngineByteWindow(bodyStringHelloWire, 0, 6),
                    cloneServerEngineByteWindow(bodyStringHelloWire, 6, 10),
                    cloneServerEngineByteWindow(
                        bodyStringHelloWire,
                        16,
                        bodyStringHelloWire.size - 16
                    )
                ],
                "captured-clienthello fragmented headers-plus-data bodyString request",
                { => engine.bodyStringRequestWireFragments },
                writePauseMillis: 20
            )
        let bodyJsonWire =
            runAcceptedTransportTlsHandshakeRequestResponseSocketSinkClient(
                "127.0.0.1",
                port,
                [
                    cloneServerEngineByteWindow(bodyJsonHelloWire, 0, 8),
                    cloneServerEngineByteWindow(bodyJsonHelloWire, 8, 9),
                    cloneServerEngineByteWindow(
                        bodyJsonHelloWire,
                        17,
                        bodyJsonHelloWire.size - 17
                    )
                ],
                "captured-clienthello fragmented headers-plus-data bodyJson request",
                { => engine.bodyJsonRequestWireFragments },
                writePauseMillis: 20
            )
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(engine.bodyStringReadyStatus, "READY")
        @Assert(engine.bodyJsonReadyStatus, "READY")
        @Assert(engine.bodyStringNegotiatedAlpn, "h2")
        @Assert(engine.bodyJsonNegotiatedAlpn, "h2")
        @Assert(engine.bodyStringRequestedServerName, "www.example.com")
        @Assert(engine.bodyJsonRequestedServerName, "www.example.com")
        @Assert(engine.bodyStringAttachSurface, "accepted-transport-session")
        @Assert(engine.bodyJsonAttachSurface, "accepted-transport-session")
        @Assert(
            engine.openBodyStringSocketWire(bodyStringWire),
            "body:accepted-appdata-body"
        )
        @Assert(
            engine.openBodyJsonSocketWire(bodyJsonWire),
            "name:ignite:val:23"
        )
        @Assert(engine.bodyStringResponseStatus, UInt16(200))
        @Assert(engine.bodyJsonResponseStatus, UInt16(200))
        @Assert(
            engine.bodyStringContentType,
            "text/plain; charset=utf-8"
        )
        @Assert(
            engine.bodyJsonContentType,
            "text/plain; charset=utf-8"
        )
        @Assert(engine.bodyStringTransferEncoding, "")
        @Assert(engine.bodyJsonTransferEncoding, "")
        @Assert(engine.bodyStringSocketWriteCount >= 1, true)
        @Assert(engine.bodyJsonSocketWriteCount >= 1, true)
        @Assert(
            engine.bodyStringTransportId,
            "captured-clienthello-fragmented-appdata-data-turn-body-string-transport"
        )
        @Assert(
            engine.bodyJsonTransportId,
            "captured-clienthello-fragmented-appdata-data-turn-body-json-transport"
        )
    }

    @TestCase
    public func testInjectedServerEngineRejectsAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataRequestTurnWhenTlsHandshakeDoesNotStartWithClientHelloRecord(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloRequestTurnRejectProbeEngine()
        app.serverEngine(engine)

        let wrongRecordWire = buildServerEngineAbstractionTestTlsRecordWire(
            serverEngineAbstractionTestByteArray("oops".toArray()),
            contentType: UInt8(0x17)
        )

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        runAcceptedTransportOneWaySocketClient(
            "127.0.0.1",
            port,
            [
                cloneServerEngineByteWindow(
                    wrongRecordWire,
                    0,
                    wrongRecordWire.size
                )
            ]
        )
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(
            contains(
                engine.observedError,
                "expected handshake record contentType=22"
            ),
            true
        )
    }

    @TestCase
    public func testInjectedServerEngineCanServeAcceptedTransportSocketApplicationDataFragmentedRecordWireHeadersPlusDataRequestTurn(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.post("/carrier-appdata-data-turn-body-string", { ctx =>
            let body = ctx.bodyString()
            let _ = ctx
                .setHeader("x-carrier-appdata-data-turn-body", "1")
                .sendString("body:${body}")
        })
        app.post("/carrier-appdata-data-turn-body-json", { ctx =>
            let reader = ctx.requestJsonReader()
            reader.startObject()
            let firstName = reader.readName()
            let firstValue = reader.readValue<String>()
            let secondName = reader.readName()
            let secondValue = reader.readValue<Int64>()
            reader.endObject()
            let _ = ctx
                .setHeader("x-carrier-appdata-data-turn-body-json", "1")
                .sendString("${firstName}:${firstValue}:${secondName}:${secondValue}")
        })
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportSocketApplicationDataFragmentedRecordWireHeadersPlusDataRequestTurnProbeEngine()
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let bodyStringWire =
            runAcceptedTransportRequestResponseSocketSinkClient(
                "127.0.0.1",
                port,
                "attach-taking fragmented headers-plus-data bodyString request",
                { => engine.bodyStringRequestWireFragments },
                writePauseMillis: 20
            )
        let bodyJsonWire =
            runAcceptedTransportRequestResponseSocketSinkClient(
                "127.0.0.1",
                port,
                "attach-taking fragmented headers-plus-data bodyJson request",
                { => engine.bodyJsonRequestWireFragments },
                writePauseMillis: 20
            )
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(engine.bodyStringReadyStatus, "READY")
        @Assert(engine.bodyJsonReadyStatus, "READY")
        @Assert(
            engine.openBodyStringSocketWire(bodyStringWire),
            "body:accepted-appdata-body"
        )
        @Assert(
            engine.openBodyJsonSocketWire(bodyJsonWire),
            "name:ignite:val:23"
        )
        @Assert(engine.bodyStringResponseStatus, UInt16(200))
        @Assert(engine.bodyJsonResponseStatus, UInt16(200))
        @Assert(
            engine.bodyStringContentType,
            "text/plain; charset=utf-8"
        )
        @Assert(
            engine.bodyJsonContentType,
            "text/plain; charset=utf-8"
        )
        @Assert(engine.bodyStringTransferEncoding, "")
        @Assert(engine.bodyJsonTransferEncoding, "")
        @Assert(engine.bodyStringSocketWriteCount >= 1, true)
        @Assert(engine.bodyJsonSocketWriteCount >= 1, true)
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "ready")
                @Assert(event.scheme, "https")
            case None => @Fail("expected startup observe ready event")
        }
    }

    @TestCase
    public func testInjectedServerEngineRejectsWrongStreamAcceptedTransportSocketApplicationDataFragmentedRecordWireDataForRequestTurn(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportSocketApplicationDataFragmentedRecordWireHeadersPlusDataRequestTurnRejectProbeEngine()
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let _ =
            runAcceptedTransportRequestResponseSocketSinkClient(
                "127.0.0.1",
                port,
                "attach-taking fragmented headers-plus-data reject request",
                { => engine.requestWireFragments },
                writePauseMillis: 20
            )
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(
            contains(
                engine.observedError,
                "requires same-stream DATA"
            ),
            true
        )
    }

    @TestCase
    public func testInjectedServerEngineCanServeAcceptedTransportApplicationDataFragmentedRecordWireProvidedBodyRequestTurn(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.post("/carrier-fragmented-appdata-body-string", { ctx =>
            let body = ctx.bodyString()
            let _ = ctx
                .setHeader("x-carrier-fragmented-appdata-body", "1")
                .sendString("body:${body}")
        })
        app.post("/carrier-fragmented-appdata-body-json", { ctx =>
            let reader = ctx.requestJsonReader()
            reader.startObject()
            let firstName = reader.readName()
            let firstValue = reader.readValue<String>()
            let secondName = reader.readName()
            let secondValue = reader.readValue<Int64>()
            reader.endObject()
            let _ = ctx
                .setHeader("x-carrier-fragmented-appdata-body-json", "1")
                .sendString("${firstName}:${firstValue}:${secondName}:${secondValue}")
        })
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportApplicationDataFragmentedRecordWireProvidedBodyRequestTurnProbeEngine()
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let bodyStringWire =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let bodyJsonWire =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(engine.bodyStringReadyStatus, "READY")
        @Assert(engine.bodyJsonReadyStatus, "READY")
        @Assert(
            engine.openBodyStringSocketWire(bodyStringWire),
            "body:accepted-appdata-body"
        )
        @Assert(
            engine.openBodyJsonSocketWire(bodyJsonWire),
            "name:ignite:val:23"
        )
        @Assert(engine.bodyStringResponseStatus, UInt16(200))
        @Assert(engine.bodyJsonResponseStatus, UInt16(200))
        @Assert(
            engine.bodyStringContentType,
            "text/plain; charset=utf-8"
        )
        @Assert(
            engine.bodyJsonContentType,
            "text/plain; charset=utf-8"
        )
        @Assert(engine.bodyStringTransferEncoding, "")
        @Assert(engine.bodyJsonTransferEncoding, "")
        @Assert(engine.bodyStringSocketWriteCount >= 1, true)
        @Assert(engine.bodyJsonSocketWriteCount >= 1, true)
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "ready")
                @Assert(event.scheme, "https")
            case None => @Fail("expected startup observe ready event")
        }
    }

    @TestCase
    public func testInjectedServerEngineRejectsAcceptedTransportApplicationDataFragmentedRecordWireMultipleHeaderBlocksForProvidedBodyRequestTurn(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportApplicationDataFragmentedRecordWireProvidedBodyRequestTurnRejectProbeEngine()
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let _ =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(
            contains(
                engine.observedError,
                "logical-request projection expects exactly one complete H2 header block"
            ),
            true
        )
    }

    @TestCase
    public func testInjectedServerEngineCanServeAcceptedTransportApplicationDataProvidedBodyRequestTurn(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.post("/carrier-appdata-body-string", { ctx =>
            let body = ctx.bodyString()
            let _ = ctx
                .setHeader("x-carrier-appdata-body", "1")
                .sendString("body:${body}")
        })
        app.post("/carrier-appdata-body-json", { ctx =>
            let reader = ctx.requestJsonReader()
            reader.startObject()
            let firstName = reader.readName()
            let firstValue = reader.readValue<String>()
            let secondName = reader.readName()
            let secondValue = reader.readValue<Int64>()
            reader.endObject()
            let _ = ctx
                .setHeader("x-carrier-appdata-body-json", "1")
                .sendString("${firstName}:${firstValue}:${secondName}:${secondValue}")
        })
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportApplicationDataProvidedBodyRequestTurnProbeEngine()
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let bodyStringWire =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let bodyJsonWire =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(engine.bodyStringReadyStatus, "READY")
        @Assert(engine.bodyJsonReadyStatus, "READY")
        @Assert(
            engine.openBodyStringSocketWire(bodyStringWire),
            "body:accepted-appdata-body"
        )
        @Assert(
            engine.openBodyJsonSocketWire(bodyJsonWire),
            "name:ignite:val:23"
        )
        @Assert(engine.bodyStringResponseStatus, UInt16(200))
        @Assert(engine.bodyJsonResponseStatus, UInt16(200))
        @Assert(
            engine.bodyStringContentType,
            "text/plain; charset=utf-8"
        )
        @Assert(
            engine.bodyJsonContentType,
            "text/plain; charset=utf-8"
        )
        @Assert(engine.bodyStringTransferEncoding, "")
        @Assert(engine.bodyJsonTransferEncoding, "")
        @Assert(engine.bodyStringSocketWriteCount >= 1, true)
        @Assert(engine.bodyJsonSocketWriteCount >= 1, true)
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "ready")
                @Assert(event.scheme, "https")
            case None => @Fail("expected startup observe ready event")
        }
    }

    @TestCase
    public func testInjectedServerEngineCanServeAcceptedTransportSocketApplicationDataProvidedBodyRequestTurn(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.post("/carrier-appdata-body-string", { ctx =>
            let body = ctx.bodyString()
            let _ = ctx
                .setHeader("x-carrier-appdata-body", "1")
                .sendString("body:${body}")
        })
        app.post("/carrier-appdata-body-json", { ctx =>
            let reader = ctx.requestJsonReader()
            reader.startObject()
            let firstName = reader.readName()
            let firstValue = reader.readValue<String>()
            let secondName = reader.readName()
            let secondValue = reader.readValue<Int64>()
            reader.endObject()
            let _ = ctx
                .setHeader("x-carrier-appdata-body-json", "1")
                .sendString("${firstName}:${firstValue}:${secondName}:${secondValue}")
        })
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportSocketApplicationDataProvidedBodyRequestTurnProbeEngine()
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let bodyStringWire =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let bodyJsonWire =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(engine.bodyStringReadyStatus, "READY")
        @Assert(engine.bodyJsonReadyStatus, "READY")
        @Assert(
            engine.openBodyStringSocketWire(bodyStringWire),
            "body:accepted-appdata-body"
        )
        @Assert(
            engine.openBodyJsonSocketWire(bodyJsonWire),
            "name:ignite:val:23"
        )
        @Assert(engine.bodyStringResponseStatus, UInt16(200))
        @Assert(engine.bodyJsonResponseStatus, UInt16(200))
        @Assert(
            engine.bodyStringContentType,
            "text/plain; charset=utf-8"
        )
        @Assert(
            engine.bodyJsonContentType,
            "text/plain; charset=utf-8"
        )
        @Assert(engine.bodyStringTransferEncoding, "")
        @Assert(engine.bodyJsonTransferEncoding, "")
        @Assert(engine.bodyStringSocketWriteCount >= 1, true)
        @Assert(engine.bodyJsonSocketWriteCount >= 1, true)
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "ready")
                @Assert(event.scheme, "https")
            case None => @Fail("expected startup observe ready event")
        }
    }

    @TestCase
    public func testInjectedServerEngineRejectsMultipleAcceptedTransportSocketApplicationDataHeaderBlocksForProvidedBodyRequestTurn(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportSocketApplicationDataProvidedBodyRequestTurnRejectProbeEngine()
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let _ =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(
            contains(
                engine.observedError,
                "expects exactly one complete H2 header block, got count=2"
            ),
            true
        )
    }

    @TestCase
    public func testInjectedServerEngineRejectsMultipleAcceptedTransportApplicationDataHeaderBlocksForProvidedBodyRequestTurn(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportApplicationDataProvidedBodyRequestTurnRejectProbeEngine()
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let _ =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(
            contains(
                engine.observedError,
                "expects exactly one complete H2 header block, got count=2"
            ),
            true
        )
    }

    @TestCase
    public func testInjectedServerEngineCanServeAcceptedTransportSocketApplicationDataFragmentedRecordWireProvidedBodyRequestTurn(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.post("/carrier-socket-fragmented-appdata-body-string", { ctx =>
            let body = ctx.bodyString()
            let _ = ctx
                .setHeader("x-socket-fragmented-appdata-body", "1")
                .sendString("body:${body}")
        })
        app.post("/carrier-socket-fragmented-appdata-body-json", { ctx =>
            let reader = ctx.requestJsonReader()
            reader.startObject()
            let firstName = reader.readName()
            let firstValue = reader.readValue<String>()
            let secondName = reader.readName()
            let secondValue = reader.readValue<Int64>()
            reader.endObject()
            let _ = ctx
                .setHeader("x-socket-fragmented-appdata-body-json", "1")
                .sendString("${firstName}:${firstValue}:${secondName}:${secondValue}")
        })
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportSocketApplicationDataFragmentedRecordWireProvidedBodyRequestTurnProbeEngine()
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let bodyStringWire =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let bodyJsonWire =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(engine.bodyStringReadyStatus, "READY")
        @Assert(engine.bodyJsonReadyStatus, "READY")
        @Assert(
            engine.openBodyStringSocketWire(bodyStringWire),
            "body:accepted-fragmented-appdata-body"
        )
        @Assert(
            engine.openBodyJsonSocketWire(bodyJsonWire),
            "name:ignite:val:64"
        )
        @Assert(engine.bodyStringResponseStatus, UInt16(200))
        @Assert(engine.bodyJsonResponseStatus, UInt16(200))
        @Assert(
            engine.bodyStringContentType,
            "text/plain; charset=utf-8"
        )
        @Assert(
            engine.bodyJsonContentType,
            "text/plain; charset=utf-8"
        )
        @Assert(engine.bodyStringTransferEncoding, "")
        @Assert(engine.bodyJsonTransferEncoding, "")
        @Assert(engine.bodyStringSocketWriteCount >= 1, true)
        @Assert(engine.bodyJsonSocketWriteCount >= 1, true)
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "ready")
                @Assert(event.scheme, "https")
            case None => @Fail("expected startup observe ready event")
        }
    }

    @TestCase
    public func testInjectedServerEngineRejectsAcceptedTransportSocketApplicationDataFragmentedRecordWireMultipleHeaderBlocksForProvidedBodyRequestTurn(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportSocketApplicationDataFragmentedRecordWireProvidedBodyRequestTurnRejectProbeEngine()
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let _ =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(
            contains(
                engine.observedError,
                "logical-request projection expects exactly one complete H2 header block"
            ),
            true
        )
    }

    @TestCase
    public func testInjectedServerEngineCanServeAcceptedTransportApplicationDataHeadersPlusDataLogicalRequest(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.post("/carrier-appdata-data-body-string", { ctx =>
            let body = ctx.bodyString()
            let _ = ctx
                .setHeader("x-carrier-appdata-data-body", "1")
                .sendString("body:${body}")
        })
        app.post("/carrier-appdata-data-body-json", { ctx =>
            let reader = ctx.requestJsonReader()
            reader.startObject()
            let firstName = reader.readName()
            let firstValue = reader.readValue<String>()
            let secondName = reader.readName()
            let secondValue = reader.readValue<Int64>()
            reader.endObject()
            let _ = ctx
                .setHeader("x-carrier-appdata-data-body-json", "1")
                .sendString("${firstName}:${firstValue}:${secondName}:${secondValue}")
        })
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportApplicationDataHeadersPlusDataLogicalRequestProbeEngine()
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let bodyStringWire =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let bodyJsonWire =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(engine.bodyStringReadyStatus, "READY")
        @Assert(engine.bodyJsonReadyStatus, "READY")
        @Assert(
            engine.openBodyStringSocketWire(bodyStringWire),
            "body:accepted-appdata-body"
        )
        @Assert(
            engine.openBodyJsonSocketWire(bodyJsonWire),
            "name:ignite:val:23"
        )
        @Assert(engine.bodyStringResponseStatus, UInt16(200))
        @Assert(engine.bodyJsonResponseStatus, UInt16(200))
        @Assert(
            engine.bodyStringContentType,
            "text/plain; charset=utf-8"
        )
        @Assert(
            engine.bodyJsonContentType,
            "text/plain; charset=utf-8"
        )
        @Assert(engine.bodyStringTransferEncoding, "")
        @Assert(engine.bodyJsonTransferEncoding, "")
        @Assert(engine.bodyStringSocketWriteCount >= 1, true)
        @Assert(engine.bodyJsonSocketWriteCount >= 1, true)
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "ready")
                @Assert(event.scheme, "https")
            case None => @Fail("expected startup observe ready event")
        }
    }

    @TestCase
    public func testInjectedServerEngineRejectsWrongStreamAcceptedTransportApplicationDataDataForLogicalRequest(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportApplicationDataHeadersPlusDataLogicalRequestRejectProbeEngine()
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let _ =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(
            contains(
                engine.observedError,
                "requires same-stream DATA"
            ),
            true
        )
    }

    @TestCase
    public func testInjectedServerEngineCanServeAcceptedTransportApplicationDataHeadersPlusDataRequestTurn(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        app.post("/carrier-appdata-data-turn-body-string", { ctx =>
            let body = ctx.bodyString()
            let _ = ctx
                .setHeader("x-carrier-appdata-data-turn-body", "1")
                .sendString("body:${body}")
        })
        app.post("/carrier-appdata-data-turn-body-json", { ctx =>
            let reader = ctx.requestJsonReader()
            reader.startObject()
            let firstName = reader.readName()
            let firstValue = reader.readValue<String>()
            let secondName = reader.readName()
            let secondValue = reader.readValue<Int64>()
            reader.endObject()
            let _ = ctx
                .setHeader("x-carrier-appdata-data-turn-body-json", "1")
                .sendString("${firstName}:${firstValue}:${secondName}:${secondValue}")
        })
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportApplicationDataHeadersPlusDataRequestTurnProbeEngine()
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let bodyStringWire =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let bodyJsonWire =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(engine.bodyStringReadyStatus, "READY")
        @Assert(engine.bodyJsonReadyStatus, "READY")
        @Assert(
            engine.openBodyStringSocketWire(bodyStringWire),
            "body:accepted-appdata-body"
        )
        @Assert(
            engine.openBodyJsonSocketWire(bodyJsonWire),
            "name:ignite:val:23"
        )
        @Assert(engine.bodyStringResponseStatus, UInt16(200))
        @Assert(engine.bodyJsonResponseStatus, UInt16(200))
        @Assert(
            engine.bodyStringContentType,
            "text/plain; charset=utf-8"
        )
        @Assert(
            engine.bodyJsonContentType,
            "text/plain; charset=utf-8"
        )
        @Assert(engine.bodyStringTransferEncoding, "")
        @Assert(engine.bodyJsonTransferEncoding, "")
        @Assert(engine.bodyStringSocketWriteCount >= 1, true)
        @Assert(engine.bodyJsonSocketWriteCount >= 1, true)
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                @Assert(event.phase, "ready")
                @Assert(event.scheme, "https")
            case None => @Fail("expected startup observe ready event")
        }
    }

    @TestCase
    public func testInjectedServerEngineRejectsWrongStreamAcceptedTransportApplicationDataDataForRequestTurn(): Unit {
        let app = App(config: Config(
            tlsCertFile: resolveEngineFixturePath(ENGINE_TLS_CERT_A),
            tlsKeyFile: resolveEngineFixturePath(ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let port = reserveServerEngineAbstractionLoopbackPort()
        let engine =
            JinguiAcceptedTransportApplicationDataHeadersPlusDataRequestTurnRejectProbeEngine()
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForShellReady(app, port)

        let _ =
            runAcceptedTransportResponseSocketSinkClient("127.0.0.1", port)
        let _ = serverFuture.get(Duration.second * 5)

        @Assert(
            contains(
                engine.observedError,
                "requires same-stream DATA"
            ),
            true
        )
    }

    @TestCase
    public func testJinguiAcceptedTransportH2HeaderFieldDecodeCanDecodeIndexedAndLiteralFields(): Unit {
        let snapshot = JinguiAcceptedTransportH2HeaderBlockSnapshot(
            13,
            false,
            false,
            false,
            false,
            0,
            0,
            concatServerEngineAbstractionTestByteArrays([
                serverEngineAbstractionTestByteArray([UInt8(0x82)]),
                serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x05)]),
                serverEngineAbstractionTestByteArray("/demo".toArray()),
                serverEngineAbstractionTestByteArray([UInt8(0x10), UInt8(0x04)]),
                serverEngineAbstractionTestByteArray("x-ig".toArray()),
                serverEngineAbstractionTestByteArray([UInt8(0x02)]),
                serverEngineAbstractionTestByteArray("ok".toArray())
            ])
        )
        let fields =
            parseJinguiAcceptedTransportH2HeaderFields(snapshot)

        @Assert(fields.size, 3)
        @Assert(fields[0].name, ":method")
        @Assert(fields[0].value, "GET")
        @Assert(fields[0].representationKind, "indexed")
        @Assert(fields[0].staticIndex, 2)
        @Assert(fields[0].nameStaticIndex, 2)

        @Assert(fields[1].name, ":path")
        @Assert(fields[1].value, "/demo")
        @Assert(fields[1].representationKind, "literal-with-indexing")
        @Assert(fields[1].staticIndex, 0)
        @Assert(fields[1].nameStaticIndex, 4)

        @Assert(fields[2].name, "x-ig")
        @Assert(fields[2].value, "ok")
        @Assert(fields[2].representationKind, "literal-never-indexed")
        @Assert(fields[2].staticIndex, 0)
        @Assert(fields[2].nameStaticIndex, 0)
    }

    @TestCase
    public func testJinguiAcceptedTransportH2HpackDecoderStateCanReuseDynamicIndexAcrossHeaderBlocks(): Unit {
        let hpackDecoderState =
            ServerJinguiAcceptedTransportH2HpackDecoderState()
        let firstSnapshot = JinguiAcceptedTransportH2HeaderBlockSnapshot(
            31,
            false,
            false,
            false,
            false,
            0,
            0,
            concatServerEngineAbstractionTestByteArrays([
                serverEngineAbstractionTestByteArray([UInt8(0x82)]),
                serverEngineAbstractionTestByteArray([UInt8(0x04), UInt8(0x04)]),
                serverEngineAbstractionTestByteArray("/one".toArray()),
                serverEngineAbstractionTestByteArray([UInt8(0x40), UInt8(0x05)]),
                serverEngineAbstractionTestByteArray("x-dyn".toArray()),
                serverEngineAbstractionTestByteArray([UInt8(0x03)]),
                serverEngineAbstractionTestByteArray("one".toArray())
            ])
        )
        let secondSnapshot = JinguiAcceptedTransportH2HeaderBlockSnapshot(
            33,
            false,
            false,
            false,
            false,
            0,
            0,
            concatServerEngineAbstractionTestByteArrays([
                serverEngineAbstractionTestByteArray([UInt8(0x82)]),
                serverEngineAbstractionTestByteArray([UInt8(0x04), UInt8(0x04)]),
                serverEngineAbstractionTestByteArray("/two".toArray()),
                serverEngineAbstractionTestByteArray([UInt8(0xbe)])
            ])
        )

        let firstFields =
            hpackDecoderState.parseHeaderFields(firstSnapshot)
        @Assert(firstFields.size, 3)
        @Assert(firstFields[2].name, "x-dyn")
        @Assert(firstFields[2].value, "one")
        @Assert(firstFields[2].representationKind, "literal-with-indexing")
        @Assert(hpackDecoderState.dynamicEntryCount(), 1)

        let secondFields =
            hpackDecoderState.parseHeaderFields(secondSnapshot)
        @Assert(secondFields.size, 3)
        @Assert(secondFields[2].name, "x-dyn")
        @Assert(secondFields[2].value, "one")
        @Assert(secondFields[2].representationKind, "indexed-dynamic")
        @Assert(secondFields[2].staticIndex, 0)
    }

    @TestCase
    public func testJinguiAcceptedTransportH2HeaderFieldDecodeRejectsDynamicTableUpdate(): Unit {
        let snapshot = JinguiAcceptedTransportH2HeaderBlockSnapshot(
            13,
            false,
            false,
            false,
            false,
            0,
            0,
            serverEngineAbstractionTestByteArray([UInt8(0x2a)])
        )
        try {
            let _ =
                parseJinguiAcceptedTransportH2HeaderFields(snapshot)
            @Fail("expected dynamic table update rejection")
        } catch (e: Exception) {
            @Assert(
                contains(
                    e.message,
                    "dynamic table size update is unsupported"
                ),
                true
            )
        }
    }

    @TestCase
    public func testJinguiAcceptedTransportH2HeaderFieldDecodeRejectsHuffmanString(): Unit {
        let snapshot = JinguiAcceptedTransportH2HeaderBlockSnapshot(
            13,
            false,
            false,
            false,
            false,
            0,
            0,
            concatServerEngineAbstractionTestByteArrays([
                serverEngineAbstractionTestByteArray([UInt8(0x00), UInt8(0x83)]),
                serverEngineAbstractionTestByteArray("abc".toArray())
            ])
        )
        try {
            let _ =
                parseJinguiAcceptedTransportH2HeaderFields(snapshot)
            @Fail("expected huffman string rejection")
        } catch (e: Exception) {
            @Assert(
                contains(
                    e.message,
                    "Huffman string is unsupported"
                ),
                true
            )
        }
    }

    @TestCase
    public func testJinguiAcceptedTransportH2DecodedHeaderFieldsCanProjectLogicalRequestAndInjectAuthority(): Unit {
        let fields = [
            JinguiAcceptedTransportH2DecodedHeaderField(
                ":method",
                "POST",
                "indexed",
                3,
                3
            ),
            JinguiAcceptedTransportH2DecodedHeaderField(
                ":path",
                "/decoded?turn=from-fields",
                "literal-with-indexing",
                0,
                4
            ),
            JinguiAcceptedTransportH2DecodedHeaderField(
                ":authority",
                "api.example.com:9443",
                "literal-without-indexing",
                0,
                1
            ),
            JinguiAcceptedTransportH2DecodedHeaderField(
                "x-mode",
                "decoded",
                "literal-never-indexed",
                0,
                0
            )
        ]
        let request =
            buildServerJinguiAcceptedTransportLogicalRequestFromDecodedH2HeaderFields(
                fields,
                bodyBytes: "payload".toArray()
            )

        @Assert(request.method, "POST")
        @Assert(request.path, "/decoded")
        @Assert(request.urlString, "/decoded?turn=from-fields")
        @Assert(request.versionString, "h2")
        @Assert(request.queryString, "turn=from-fields")
        @Assert(
            request.headers.getFirst("host") ?? "",
            "api.example.com:9443"
        )
        @Assert(
            request.headers.getFirst("x-mode") ?? "",
            "decoded"
        )
        @Assert(
            serverEngineAbstractionTestByteText(
                serverEngineAbstractionTestByteArray(request.bodyBytes)
            ),
            "payload"
        )
    }

    @TestCase
    public func testJinguiAcceptedTransportH2DecodedHeaderFieldsCanPreserveExplicitHostHeader(): Unit {
        let fields = [
            JinguiAcceptedTransportH2DecodedHeaderField(
                ":method",
                "GET",
                "indexed",
                2,
                2
            ),
            JinguiAcceptedTransportH2DecodedHeaderField(
                ":path",
                "/host-check",
                "literal-with-indexing",
                0,
                4
            ),
            JinguiAcceptedTransportH2DecodedHeaderField(
                ":authority",
                "authority.example.com",
                "literal-without-indexing",
                0,
                1
            ),
            JinguiAcceptedTransportH2DecodedHeaderField(
                "host",
                "manual.example.com",
                "literal-never-indexed",
                0,
                0
            )
        ]
        let request =
            buildServerJinguiAcceptedTransportLogicalRequestFromDecodedH2HeaderFields(
                fields
            )

        @Assert(
            request.headers.getFirst("host") ?? "",
            "manual.example.com"
        )
    }

    @TestCase
    public func testJinguiAcceptedTransportH2DecodedHeaderFieldsSkipForbiddenRegularRequestHeaders(): Unit {
        let fields = [
            JinguiAcceptedTransportH2DecodedHeaderField(
                ":method",
                "GET",
                "indexed",
                2,
                2
            ),
            JinguiAcceptedTransportH2DecodedHeaderField(
                ":path",
                "/request-regular-header-skip",
                "literal-with-indexing",
                0,
                4
            ),
            JinguiAcceptedTransportH2DecodedHeaderField(
                ":authority",
                "api.example.com:9443",
                "literal-without-indexing",
                0,
                1
            ),
            JinguiAcceptedTransportH2DecodedHeaderField(
                "connection",
                "close",
                "literal-never-indexed",
                0,
                0
            ),
            JinguiAcceptedTransportH2DecodedHeaderField(
                "keep-alive",
                "timeout=5",
                "literal-never-indexed",
                0,
                0
            ),
            JinguiAcceptedTransportH2DecodedHeaderField(
                "proxy-connection",
                "keep-alive",
                "literal-never-indexed",
                0,
                0
            ),
            JinguiAcceptedTransportH2DecodedHeaderField(
                "transfer-encoding",
                "chunked",
                "literal-never-indexed",
                0,
                0
            ),
            JinguiAcceptedTransportH2DecodedHeaderField(
                "upgrade",
                "websocket",
                "literal-never-indexed",
                0,
                0
            ),
            JinguiAcceptedTransportH2DecodedHeaderField(
                "te",
                "gzip",
                "literal-never-indexed",
                0,
                0
            ),
            JinguiAcceptedTransportH2DecodedHeaderField(
                "x-mode",
                "decoded",
                "literal-never-indexed",
                0,
                0
            )
        ]
        let request =
            buildServerJinguiAcceptedTransportLogicalRequestFromDecodedH2HeaderFields(
                fields
            )

        @Assert(request.headers.getFirst("host") ?? "", "api.example.com:9443")
        @Assert(request.headers.getFirst("x-mode") ?? "", "decoded")
        @Assert(request.headers.getFirst("connection") ?? "", "")
        @Assert(request.headers.getFirst("keep-alive") ?? "", "")
        @Assert(request.headers.getFirst("proxy-connection") ?? "", "")
        @Assert(request.headers.getFirst("transfer-encoding") ?? "", "")
        @Assert(request.headers.getFirst("upgrade") ?? "", "")
        @Assert(request.headers.getFirst("te") ?? "", "")
    }

    @TestCase
    public func testJinguiAcceptedTransportH2DecodedHeaderFieldsSkipTeTrailersUntilRequestTrailerSupport(): Unit {
        let fields = [
            JinguiAcceptedTransportH2DecodedHeaderField(
                ":method",
                "GET",
                "indexed",
                2,
                2
            ),
            JinguiAcceptedTransportH2DecodedHeaderField(
                ":path",
                "/te-trailers",
                "literal-with-indexing",
                0,
                4
            ),
            JinguiAcceptedTransportH2DecodedHeaderField(
                ":authority",
                "api.example.com:9443",
                "literal-without-indexing",
                0,
                1
            ),
            JinguiAcceptedTransportH2DecodedHeaderField(
                "te",
                "trailers",
                "literal-never-indexed",
                0,
                0
            ),
            JinguiAcceptedTransportH2DecodedHeaderField(
                "x-mode",
                "decoded-te-policy",
                "literal-never-indexed",
                0,
                0
            )
        ]
        let request =
            buildServerJinguiAcceptedTransportLogicalRequestFromDecodedH2HeaderFields(
                fields
            )

        @Assert(request.path, "/te-trailers")
        @Assert(request.headers.getFirst("host") ?? "", "api.example.com:9443")
        @Assert(request.headers.getFirst("x-mode") ?? "", "decoded-te-policy")
        @Assert(request.headers.getFirst("te") ?? "", "")
    }

    @TestCase
    public func testJinguiAcceptedTransportH2DecodedHeaderFieldsRejectMissingMethod(): Unit {
        let fields = [
            JinguiAcceptedTransportH2DecodedHeaderField(
                ":path",
                "/missing-method",
                "literal-with-indexing",
                0,
                4
            )
        ]
        try {
            let _ =
                buildServerJinguiAcceptedTransportLogicalRequestFromDecodedH2HeaderFields(
                    fields
                )
            @Fail("expected missing method rejection")
        } catch (e: Exception) {
            @Assert(
                contains(
                    e.message,
                    "requires `:method`"
                ),
                true
            )
        }
    }

    @TestCase
    public func testJinguiAcceptedTransportH2DecodedHeaderFieldsRejectUnsupportedPseudoHeader(): Unit {
        let fields = [
            JinguiAcceptedTransportH2DecodedHeaderField(
                ":method",
                "GET",
                "indexed",
                2,
                2
            ),
            JinguiAcceptedTransportH2DecodedHeaderField(
                ":path",
                "/unsupported-pseudo",
                "literal-with-indexing",
                0,
                4
            ),
            JinguiAcceptedTransportH2DecodedHeaderField(
                ":status",
                "200",
                "literal-without-indexing",
                0,
                8
            )
        ]
        try {
            let _ =
                buildServerJinguiAcceptedTransportLogicalRequestFromDecodedH2HeaderFields(
                    fields
                )
            @Fail("expected unsupported pseudo header rejection")
        } catch (e: Exception) {
            @Assert(
                contains(
                    e.message,
                    "does not support pseudo header `:status`"
                ),
                true
            )
        }
    }

    @TestCase
    public func testJinguiAcceptedTransportH2HeaderBlockCanProjectPseudoHeaders(): Unit {
        let snapshot = JinguiAcceptedTransportH2HeaderBlockSnapshot(
            17,
            false,
            false,
            false,
            false,
            0,
            0,
            concatServerEngineAbstractionTestByteArrays([
                serverEngineAbstractionTestByteArray([UInt8(0x82)]),
                serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x0b)]),
                serverEngineAbstractionTestByteArray("/hb?turn=ok".toArray()),
                serverEngineAbstractionTestByteArray([UInt8(0x01), UInt8(0x14)]),
                serverEngineAbstractionTestByteArray(
                    "api.example.com:9443".toArray()
                )
            ])
        )
        let pseudoHeaders =
            buildServerJinguiAcceptedTransportH2PseudoHeadersFromHeaderBlock(
                snapshot
            )

        @Assert(pseudoHeaders.method, "GET")
        @Assert(pseudoHeaders.path, "/hb?turn=ok")
        @Assert(pseudoHeaders.authority, "api.example.com:9443")
    }

    @TestCase
    public func testJinguiAcceptedTransportH2HeaderBlockCanProjectLogicalRequest(): Unit {
        let snapshot = JinguiAcceptedTransportH2HeaderBlockSnapshot(
            19,
            false,
            false,
            false,
            false,
            0,
            0,
            concatServerEngineAbstractionTestByteArrays([
                serverEngineAbstractionTestByteArray([UInt8(0x82)]),
                serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x0b)]),
                serverEngineAbstractionTestByteArray("/hb?turn=ok".toArray()),
                serverEngineAbstractionTestByteArray([UInt8(0x01), UInt8(0x14)]),
                serverEngineAbstractionTestByteArray(
                    "api.example.com:9443".toArray()
                ),
                serverEngineAbstractionTestByteArray([UInt8(0x10), UInt8(0x06)]),
                serverEngineAbstractionTestByteArray("x-mode".toArray()),
                serverEngineAbstractionTestByteArray([UInt8(0x06)]),
                serverEngineAbstractionTestByteArray("bridge".toArray())
            ])
        )
        let request =
            buildServerJinguiAcceptedTransportLogicalRequestFromH2HeaderBlock(
                snapshot,
                bodyBytes: "payload".toArray()
            )

        @Assert(request.method, "GET")
        @Assert(request.path, "/hb")
        @Assert(request.urlString, "/hb?turn=ok")
        @Assert(request.queryString, "turn=ok")
        @Assert(request.versionString, "h2")
        @Assert(
            request.headers.getFirst("host") ?? "",
            "api.example.com:9443"
        )
        @Assert(
            request.headers.getFirst("x-mode") ?? "",
            "bridge"
        )
        @Assert(
            serverEngineAbstractionTestByteText(
                serverEngineAbstractionTestByteArray(request.bodyBytes)
            ),
            "payload"
        )
    }

    @TestCase
    public func testJinguiAcceptedTransportH2HeaderBlockSkipsForbiddenRegularRequestHeaders(): Unit {
        let snapshot = JinguiAcceptedTransportH2HeaderBlockSnapshot(
            23,
            false,
            false,
            false,
            false,
            0,
            0,
            concatServerEngineAbstractionTestByteArrays([
                serverEngineAbstractionTestByteArray([UInt8(0x82)]),
                serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x1a)]),
                serverEngineAbstractionTestByteArray(
                    "/request-header-block-skip".toArray()
                ),
                serverEngineAbstractionTestByteArray([UInt8(0x01), UInt8(0x14)]),
                serverEngineAbstractionTestByteArray(
                    "api.example.com:9443".toArray()
                ),
                serverEngineAbstractionTestByteArray([UInt8(0x10), UInt8(0x0a)]),
                serverEngineAbstractionTestByteArray("connection".toArray()),
                serverEngineAbstractionTestByteArray([UInt8(0x05)]),
                serverEngineAbstractionTestByteArray("close".toArray()),
                serverEngineAbstractionTestByteArray([UInt8(0x10), UInt8(0x0a)]),
                serverEngineAbstractionTestByteArray("keep-alive".toArray()),
                serverEngineAbstractionTestByteArray([UInt8(0x09)]),
                serverEngineAbstractionTestByteArray("timeout=5".toArray()),
                serverEngineAbstractionTestByteArray([UInt8(0x10), UInt8(0x10)]),
                serverEngineAbstractionTestByteArray("proxy-connection".toArray()),
                serverEngineAbstractionTestByteArray([UInt8(0x0a)]),
                serverEngineAbstractionTestByteArray("keep-alive".toArray()),
                serverEngineAbstractionTestByteArray([UInt8(0x10), UInt8(0x11)]),
                serverEngineAbstractionTestByteArray("transfer-encoding".toArray()),
                serverEngineAbstractionTestByteArray([UInt8(0x07)]),
                serverEngineAbstractionTestByteArray("chunked".toArray()),
                serverEngineAbstractionTestByteArray([UInt8(0x10), UInt8(0x07)]),
                serverEngineAbstractionTestByteArray("upgrade".toArray()),
                serverEngineAbstractionTestByteArray([UInt8(0x09)]),
                serverEngineAbstractionTestByteArray("websocket".toArray()),
                serverEngineAbstractionTestByteArray([UInt8(0x10), UInt8(0x02)]),
                serverEngineAbstractionTestByteArray("te".toArray()),
                serverEngineAbstractionTestByteArray([UInt8(0x04)]),
                serverEngineAbstractionTestByteArray("gzip".toArray()),
                serverEngineAbstractionTestByteArray([UInt8(0x10), UInt8(0x06)]),
                serverEngineAbstractionTestByteArray("x-mode".toArray()),
                serverEngineAbstractionTestByteArray([UInt8(0x04)]),
                serverEngineAbstractionTestByteArray("wire".toArray())
            ])
        )
        let request =
            buildServerJinguiAcceptedTransportLogicalRequestFromH2HeaderBlock(
                snapshot
            )

        @Assert(request.method, "GET")
        @Assert(request.path, "/request-header-block-skip")
        @Assert(
            request.headers.getFirst("host") ?? "",
            "api.example.com:9443"
        )
        @Assert(request.headers.getFirst("x-mode") ?? "", "wire")
        @Assert(request.headers.getFirst("connection") ?? "", "")
        @Assert(request.headers.getFirst("keep-alive") ?? "", "")
        @Assert(request.headers.getFirst("proxy-connection") ?? "", "")
        @Assert(request.headers.getFirst("transfer-encoding") ?? "", "")
        @Assert(request.headers.getFirst("upgrade") ?? "", "")
        @Assert(request.headers.getFirst("te") ?? "", "")
    }

    @TestCase
    public func testJinguiAcceptedTransportH2HeaderBlockSkipsTeTrailersUntilRequestTrailerSupport(): Unit {
        let snapshot = JinguiAcceptedTransportH2HeaderBlockSnapshot(
            25,
            false,
            false,
            false,
            false,
            0,
            0,
            concatServerEngineAbstractionTestByteArrays([
                serverEngineAbstractionTestByteArray([UInt8(0x82)]),
                serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x0c)]),
                serverEngineAbstractionTestByteArray("/te-trailers".toArray()),
                serverEngineAbstractionTestByteArray([UInt8(0x01), UInt8(0x14)]),
                serverEngineAbstractionTestByteArray(
                    "api.example.com:9443".toArray()
                ),
                serverEngineAbstractionTestByteArray([UInt8(0x10), UInt8(0x02)]),
                serverEngineAbstractionTestByteArray("te".toArray()),
                serverEngineAbstractionTestByteArray([UInt8(0x08)]),
                serverEngineAbstractionTestByteArray("trailers".toArray()),
                serverEngineAbstractionTestByteArray([UInt8(0x10), UInt8(0x06)]),
                serverEngineAbstractionTestByteArray("x-mode".toArray()),
                serverEngineAbstractionTestByteArray([UInt8(0x0e)]),
                serverEngineAbstractionTestByteArray("wire-te-policy".toArray())
            ])
        )
        let request =
            buildServerJinguiAcceptedTransportLogicalRequestFromH2HeaderBlock(
                snapshot
            )

        @Assert(request.method, "GET")
        @Assert(request.path, "/te-trailers")
        @Assert(
            request.headers.getFirst("host") ?? "",
            "api.example.com:9443"
        )
        @Assert(request.headers.getFirst("x-mode") ?? "", "wire-te-policy")
        @Assert(request.headers.getFirst("te") ?? "", "")
    }

    @TestCase
    public func testJinguiAcceptedTransportLogicalRequestSeparatesHeadersAndTrailers(): Unit {
        let headers = HttpHeaders()
        headers.add("x-shared", "header-value")
        headers.add("x-header-only", "head")
        let trailers = HttpHeaders()
        trailers.add("x-shared", "trailer-value")
        trailers.add("x-trailer-only", "tail")

        let request =
            buildServerJinguiAcceptedTransportLogicalRequestFromH2PseudoHeaders(
                ServerJinguiAcceptedTransportH2PseudoHeaders(
                    "POST",
                    "/trailer-model"
                ),
                headers: Some(headers),
                trailers: Some(trailers),
                bodyBytes: "body".toArray(),
                streamId: 31
            )

        headers.add("x-shared", "late-header")
        trailers.add("x-shared", "late-trailer")

        @Assert(request.headers.getFirst("x-shared") ?? "", "header-value")
        @Assert(request.trailers.getFirst("x-shared") ?? "", "trailer-value")
        @Assert(request.headers.getFirst("x-header-only") ?? "", "head")
        @Assert(request.trailers.getFirst("x-trailer-only") ?? "", "tail")
        @Assert(request.headers.getFirst("x-trailer-only") ?? "", "")
        @Assert(request.trailers.getFirst("x-header-only") ?? "", "")
        @Assert(request.streamId, Int64(31))
    }

    @TestCase
    public func testCtxTrailerReadsCarrierTrailersWithoutHeaderFallback(): Unit {
        let trailers = HttpHeaders()
        trailers.add("x-request-trailer", "seen")
        let carrier = AcceptedTransportResponseProbeCarrier(
            "/ctx-trailer",
            requestTrailers: Some(trailers)
        )
        let ctx = Ctx(carrier, App(config: Config(enableNetworkChangeNotice: false)))

        trailers.add("x-request-trailer", "late")

        @Assert(ctx.trailer("x-request-trailer") ?? "", "seen")
        @Assert(ctx.header("x-request-trailer") ?? "", "")
        @Assert(ctx.trailer("x-missing-trailer") ?? "", "")
    }

    @TestCase
    public func testJinguiAcceptedTransportH2TrailingHeaderBlockProjectsRequestTrailersSeparately(): Unit {
        let headerBlock = JinguiAcceptedTransportH2HeaderBlockSnapshot(
            33,
            false,
            false,
            false,
            false,
            0,
            0,
            concatServerEngineAbstractionTestByteArrays([
                serverEngineAbstractionTestByteArray([UInt8(0x82)]),
                serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x0e)]),
                serverEngineAbstractionTestByteArray("/trailer-block".toArray()),
                serverEngineAbstractionTestByteArray([UInt8(0x01), UInt8(0x14)]),
                serverEngineAbstractionTestByteArray(
                    "api.example.com:9443".toArray()
                ),
                serverEngineAbstractionTestByteArray([UInt8(0x10), UInt8(0x06)]),
                serverEngineAbstractionTestByteArray("x-mode".toArray()),
                serverEngineAbstractionTestByteArray([UInt8(0x04)]),
                serverEngineAbstractionTestByteArray("head".toArray())
            ])
        )
        let trailerBlock = JinguiAcceptedTransportH2HeaderBlockSnapshot(
            33,
            false,
            false,
            false,
            true,
            0,
            0,
            concatServerEngineAbstractionTestByteArrays([
                serverEngineAbstractionTestByteArray([UInt8(0x10), UInt8(0x11)]),
                serverEngineAbstractionTestByteArray("x-request-trailer".toArray()),
                serverEngineAbstractionTestByteArray([UInt8(0x04)]),
                serverEngineAbstractionTestByteArray("tail".toArray()),
                serverEngineAbstractionTestByteArray([UInt8(0x10), UInt8(0x06)]),
                serverEngineAbstractionTestByteArray("x-mode".toArray()),
                serverEngineAbstractionTestByteArray([UInt8(0x0e)]),
                serverEngineAbstractionTestByteArray("trailer-shadow".toArray()),
                serverEngineAbstractionTestByteArray([UInt8(0x10), UInt8(0x0a)]),
                serverEngineAbstractionTestByteArray("connection".toArray()),
                serverEngineAbstractionTestByteArray([UInt8(0x05)]),
                serverEngineAbstractionTestByteArray("close".toArray())
            ])
        )

        let request =
            buildServerJinguiAcceptedTransportLogicalRequestFromH2HeaderBlockWithRequestTrailers(
                headerBlock,
                trailerBlock,
                bodyBytes: "payload".toArray()
            )

        @Assert(request.headers.getFirst("host") ?? "", "api.example.com:9443")
        @Assert(request.headers.getFirst("x-mode") ?? "", "head")
        @Assert(request.headers.getFirst("x-request-trailer") ?? "", "")
        @Assert(request.trailers.getFirst("x-request-trailer") ?? "", "tail")
        @Assert(request.trailers.getFirst("x-mode") ?? "", "trailer-shadow")
        @Assert(request.trailers.getFirst("connection") ?? "", "")
        @Assert(request.streamId, Int64(33))
    }

    @TestCase
    public func testJinguiAcceptedTransportH2TrailingHeaderBlockRejectsPseudoHeader(): Unit {
        let trailerBlock = JinguiAcceptedTransportH2HeaderBlockSnapshot(
            35,
            false,
            false,
            false,
            true,
            0,
            0,
            serverEngineAbstractionTestByteArray([UInt8(0x88)])
        )

        try {
            let _ =
                buildServerJinguiAcceptedTransportRequestTrailersFromDecodedH2HeaderFields(
                    parseJinguiAcceptedTransportH2HeaderFields(trailerBlock)
                )
            @Fail("expected pseudo header rejection from request trailers")
        } catch (e: Exception) {
            @Assert(
                contains(
                    e.message,
                    "does not support pseudo header `:status`"
                ),
                true
            )
        }
    }

    @TestCase
    public func testJinguiAcceptedTransportH2TrailingHeaderBlockRejectsStreamIdMismatch(): Unit {
        let headerBlock = JinguiAcceptedTransportH2HeaderBlockSnapshot(
            37,
            false,
            false,
            false,
            false,
            0,
            0,
            serverEngineAbstractionTestByteArray([UInt8(0x82), UInt8(0x84)])
        )
        let trailerBlock = JinguiAcceptedTransportH2HeaderBlockSnapshot(
            39,
            false,
            false,
            false,
            true,
            0,
            0,
            serverEngineAbstractionTestByteArray([UInt8(0x10)])
        )

        try {
            let _ =
                buildServerJinguiAcceptedTransportLogicalRequestFromH2HeaderBlockWithRequestTrailers(
                    headerBlock,
                    trailerBlock
                )
            @Fail("expected stream id mismatch rejection from request trailers")
        } catch (e: Exception) {
            @Assert(
                contains(
                    e.message,
                    "stream id mismatch"
                ),
                true
            )
        }
    }

    @TestCase
    public func testJinguiAcceptedTransportH2HeaderBlockRejectsUnsupportedPseudoHeaderProjection(): Unit {
        let snapshot = JinguiAcceptedTransportH2HeaderBlockSnapshot(
            21,
            false,
            false,
            false,
            false,
            0,
            0,
            concatServerEngineAbstractionTestByteArrays([
                serverEngineAbstractionTestByteArray([UInt8(0x82)]),
                serverEngineAbstractionTestByteArray([UInt8(0x88)]),
                serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                serverEngineAbstractionTestByteArray("/bad".toArray())
            ])
        )
        try {
            let _ =
                buildServerJinguiAcceptedTransportLogicalRequestFromH2HeaderBlock(
                    snapshot
                )
            @Fail("expected unsupported pseudo header rejection")
        } catch (e: Exception) {
            @Assert(
                contains(
                    e.message,
                    "does not support pseudo header `:status`"
                ),
                true
            )
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
    public func testSocketServerEngineShellShutdownStopsLiveAcceptLoopWithoutAcceptLimitExhaustion(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "100")
        try {
            let port = reserveServerEngineAbstractionLoopbackPort()
            let app = App(config: Config(enableTlsPrecheck: false))
            app.serverEngine(SocketServerEngineShell())
            app.get("/shell-shutdown-stop", { ctx =>
                let _ = ctx.sendString("unexpected")
            })

            let serverFuture = spawn {
                app.listen("127.0.0.1", port)
            }
            waitForShellReady(app, port)

            app.shutdown()
            let _ = serverFuture.get(Duration.second * 2)
        } finally {
            removeVariable(acceptLimitEnv)
        }
    }

    @TestCase
    public func testSocketServerEngineShellMatchesStdxForBufferedAndKnownLengthStreamResponse(): Unit {
        let acceptLimitEnv = "IGNITE_SOCKET_SERVER_ENGINE_SHELL_ACCEPT_LIMIT"
        setVariable(acceptLimitEnv, "2")
        try {
            let shellPort = reserveServerEngineAbstractionLoopbackPort()
            let stdxPort = reserveServerEngineAbstractionLoopbackPort()
            let bufferedBody = "native-stdx-buffered-parity"
            let streamBody = "native-stdx-stream-parity"

            let shellApp = App(config: Config(enableTlsPrecheck: false))
            shellApp.serverEngine(SocketServerEngineShell())
            installSocketServerEngineShellParityRoutes(
                shellApp,
                bufferedBody,
                streamBody
            )
            let shellFuture = spawn {
                shellApp.listen("127.0.0.1", shellPort)
            }
            waitForShellReady(shellApp, shellPort)

            let shellBuffered = runSocketServerEngineShellClient(
                "127.0.0.1",
                shellPort,
                "GET /parity-buffered HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let shellStream = runSocketServerEngineShellClient(
                "127.0.0.1",
                shellPort,
                "GET /parity-stream HTTP/1.1\r\nHost: example.com\r\n\r\n"
            )
            let _ = shellFuture.get(Duration.second * 5)

            let stdxApp = App(config: Config(enableTlsPrecheck: false))
            installSocketServerEngineShellParityRoutes(
                stdxApp,
                bufferedBody,
                streamBody
            )
            let stdxFuture = spawn {
                stdxApp.listen("127.0.0.1", stdxPort)
            }
            waitForShellReady(stdxApp, stdxPort)
            try {
                let stdxBuffered = runSocketServerEngineShellClient(
                    "127.0.0.1",
                    stdxPort,
                    "GET /parity-buffered HTTP/1.1\r\nHost: example.com\r\n\r\n"
                )
                let stdxStream = runSocketServerEngineShellClient(
                    "127.0.0.1",
                    stdxPort,
                    "GET /parity-stream HTTP/1.1\r\nHost: example.com\r\n\r\n"
                )

                assertSocketServerEngineShellStdxParityResponse(
                    "shell-buffered",
                    shellBuffered,
                    bufferedBody
                )
                assertSocketServerEngineShellStdxParityResponse(
                    "stdx-buffered",
                    stdxBuffered,
                    bufferedBody
                )
                assertSocketServerEngineShellStdxParityResponse(
                    "shell-stream",
                    shellStream,
                    streamBody
                )
                assertSocketServerEngineShellStdxParityResponse(
                    "stdx-stream",
                    stdxStream,
                    streamBody
                )
            } finally {
                shutdownServerEngineAbstractionApp(stdxApp, stdxFuture)
            }
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
    public func testSocketServerEngineShellProductionCandidateGateBlocksDefaultFlipWhenEvidenceIsThin(): Unit {
        let gate = buildSocketServerEngineShellProductionCandidateGate(
            SocketServerEngineShellProductionCandidateEvidence(
                1,
                false,
                false,
                false,
                false,
                false
            )
        )

        @Assert(gate.productionCandidate, false)
        @Assert(gate.status, "blocked-production-candidate-gap")
        @Assert(gate.defaultFlipDecision, "blocked-before-default-flip")
        @Assert(gate.requiredProofs[0], "ACCEPT_LOOP_MULTI_CONNECTION_PROOF")
        @Assert(gate.missingProofs[0], "ACCEPT_LOOP_MULTI_CONNECTION_PROOF")
        @Assert(gate.missingProofs[1], "SHUTDOWN_STOP_PROOF")
        @Assert(gate.blockers[0], "MISSING:ACCEPT_LOOP_MULTI_CONNECTION_PROOF")
        @Assert(gate.nonClaims[0], "NO_DEFAULT_FLIP")
        @Assert(gate.nonClaims[1], "NO_STDX_REMOVAL_CLAIM")
    }

    @TestCase
    public func testSocketServerEngineShellProductionCandidateGateBlocksTlsUntilProviderSeam(): Unit {
        let gate = buildSocketServerEngineShellProductionCandidateGate(
            SocketServerEngineShellProductionCandidateEvidence(
                2,
                true,
                true,
                true,
                true,
                true
            )
        )

        @Assert(gate.productionCandidate, false)
        @Assert(gate.status, "blocked-production-candidate-gap")
        @Assert(gate.defaultFlipDecision, "blocked-before-default-flip")
        @Assert(gate.missingProofs.size, 0)
        @Assert(gate.blockers[0], "TLS_PROVIDER_SEAM_REQUIRED")
        @Assert(gate.gaps[0], "TLS_PROVIDER_SEAM_REQUIRED")
        @Assert(gate.nonClaims[2], "NO_TLS_CLAIM")
    }

    @TestCase
    public func testSocketServerEngineShellProductionCandidateGateReadyStillDefersDefaultFlip(): Unit {
        let gate = SocketServerEngineShell().productionCandidateGate(
            SocketServerEngineShellProductionCandidateEvidence(
                2,
                false,
                true,
                true,
                true,
                true
            )
        )

        @Assert(gate.productionCandidate, true)
        @Assert(gate.status, "production-candidate-gate-ready")
        @Assert(gate.defaultFlipDecision, "defer-default-flip-to-release-gate")
        @Assert(gate.missingProofs.size, 0)
        @Assert(gate.blockers.size, 0)
        @Assert(gate.nextAction, "open one release/default-flip gate packet only after broader parity and operator acceptance")
        @Assert(gate.quicReuseHook, "long-lived connection, shutdown, soak, and parity checklist can be reused by QUIC")
        @Assert(gate.nonClaims[3], "NO_H2_RUNTIME_CLAIM")
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

class NativeTlsLiveIngressClientChannelProbe {
    public var channel: ?ContractTlsRecordChannel = None
}

class NativeTlsLiveIngressRouteProbe {
    public var invoked: Bool = false
}

class NativeTlsLiveIngressSequentialRouteProbe {
    public var firstInvoked: Bool = false
    public var secondInvoked: Bool = false
    public var firstDynHeader: String = ""
    public var secondDynHeader: String = ""
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
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        listenCalled = true
        lastAddr = option.addr
        lastPort = option.port
        lastEnableTlsPrecheck = option.enableTlsPrecheck
        lastTransportTouchpoint = option.transportTouchpoint
        let _ = app
        receivedApp = true
        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
            readyCalled = true
        }
    }

    public override func shutdown(): Unit {
        shutdownCalled = true
    }
}

class JinguiAcceptedTransportSessionProbeEngine <: ServerEngine {
    public var builtRequestAttachSurface: String = ""
    public var readySnapshot: ?ServerJinguiAcceptedTransportSessionSnapshot = None
    public var closedSnapshot: ?ServerJinguiAcceptedTransportSessionSnapshot = None

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let transport = ContractAcceptedTransportDescriptor(
            "test-accepted-transport",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55443"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 48))
        )
        let request = option.buildJinguiAcceptedTransportTls13X25519Request(
            transport,
            clientHello.encodedClientHello,
            engineIncrementalBytes(32, start: 80)
        )
        builtRequestAttachSurface = request.plan.attachSurface

        let session = option.attachJinguiAcceptedTransportTls13X25519Request(
            request
        )
        readySnapshot = Some(
            option.notifyJinguiAcceptedTransportSession(session)
        )

        let closed = option.closeJinguiAcceptedTransportSession(
            session,
            reason: "test-close"
        )
        closedSnapshot = Some(
            option.notifyJinguiAcceptedTransportSession(closed)
        )

        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSessionCodecProbeEngine <: ServerEngine {
    public var clientDecodedText: String = ""
    public var serverDecodedText: String = ""
    public var clientReassembledText: String = ""
    public var serverReassembledText: String = ""
    public var clientFragmentCount: Int64 = 0
    public var serverFragmentCount: Int64 = 0

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let transport = ContractAcceptedTransportDescriptor(
            "codec-accepted-transport",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55444"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 96))
        )
        let session = option.attachJinguiAcceptedTransportTls13X25519(
            transport,
            clientHello.encodedClientHello,
            engineIncrementalBytes(32, start: 128)
        )
        let clientChannel = contractTls13CreateClientRecordChannel(
            session.keyMaterial,
            algorithm: session.recordChannel.algorithm
        )

        let serverWire = option.sealJinguiAcceptedTransportApplicationData(
            session,
            "server-h2-frame".toArray()
        )
        clientDecodedText = String.fromUtf8(
            clientChannel.openApplicationData(serverWire)
        )

        let clientWire = clientChannel.sealApplicationData(
            "client-h2-frame".toArray()
        )
        serverDecodedText = String.fromUtf8(
            option.openJinguiAcceptedTransportApplicationData(session, clientWire)
        )

        let serverFragments =
            option.sealJinguiAcceptedTransportApplicationDataFragments(
                session,
                "server-fragment-payload-abcdefgh".toArray(),
                maxFragmentLen: 7
            )
        serverFragmentCount = serverFragments.size
        clientReassembledText = String.fromUtf8(
            clientChannel.openAndReassemble(serverFragments)
        )

        let clientFragments = clientChannel.sealFragments(
            ContractTlsRecordContentType.ApplicationData,
            "client-fragment-payload-xyz012345".toArray(),
            maxFragmentLen: 6
        )
        clientFragmentCount = clientFragments.size
        serverReassembledText = String.fromUtf8(
            option.openAndReassembleJinguiAcceptedTransportApplicationData(
                session,
                clientFragments
            )
        )

        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataH2HeaderBlockIngressProbeEngine <: ServerEngine {
    public var completedHeaderBlockCount: Int64 = 0
    public var completedHeaderBlockStreamId: Int64 = 0
    public var completedHeaderBlockEndStream: Bool = false
    public var completedHeaderBlockText: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let transport = ContractAcceptedTransportDescriptor(
            "appdata-h2-ingress-accepted-transport",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55445"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 96))
        )
        let session = option.attachJinguiAcceptedTransportTls13X25519(
            transport,
            clientHello.encodedClientHello,
            engineIncrementalBytes(32, start: 128)
        )
        let clientChannel = contractTls13CreateClientRecordChannel(
            session.keyMaterial,
            algorithm: session.recordChannel.algorithm
        )
        let plaintextWire = concatServerEngineAbstractionTestByteArrays([
            buildServerEngineAbstractionTestH2FrameWire(
                buildServerEngineAbstractionTestH2HeadersPayload(
                    serverEngineAbstractionTestByteArray("abc".toArray())
                ),
                frameType: UInt8(0x1),
                flags: UInt8(0x1),
                streamId: 31
            ),
            buildServerEngineAbstractionTestH2FrameWire(
                serverEngineAbstractionTestByteArray("def".toArray()),
                frameType: UInt8(0x9),
                flags: UInt8(0x4),
                streamId: 31
            )
        ])
        let clientFragments = clientChannel.sealFragments(
            ContractTlsRecordContentType.ApplicationData,
            plaintextWire,
            maxFragmentLen: 7
        )
        let completed =
            option.openAndIngressJinguiAcceptedTransportApplicationDataH2HeaderBlocks(
                session,
                clientFragments
            )
        completedHeaderBlockCount = completed.size
        if (completed.size > 0) {
            completedHeaderBlockStreamId = completed[0].streamId
            completedHeaderBlockEndStream = completed[0].endStream
            completedHeaderBlockText =
                serverEngineAbstractionTestByteText(
                    completed[0].headerBlockFragment
                )
        }

        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataH2HeaderBlockIngressRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let transport = ContractAcceptedTransportDescriptor(
            "appdata-h2-ingress-reject-accepted-transport",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55446"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 96))
        )
        let session = option.attachJinguiAcceptedTransportTls13X25519(
            transport,
            clientHello.encodedClientHello,
            engineIncrementalBytes(32, start: 128)
        )
        let clientChannel = contractTls13CreateClientRecordChannel(
            session.keyMaterial,
            algorithm: session.recordChannel.algorithm
        )
        let plaintextWire = concatServerEngineAbstractionTestByteArrays([
            buildServerEngineAbstractionTestH2FrameWire(
                buildServerEngineAbstractionTestH2HeadersPayload(
                    serverEngineAbstractionTestByteArray("abc".toArray())
                ),
                frameType: UInt8(0x1),
                flags: UInt8(0x1),
                streamId: 37
            ),
            buildServerEngineAbstractionTestH2FrameWire(
                serverEngineAbstractionTestByteArray("body".toArray()),
                frameType: UInt8(0x0),
                flags: UInt8(0x0),
                streamId: 37
            )
        ])
        let clientFragments = clientChannel.sealFragments(
            ContractTlsRecordContentType.ApplicationData,
            plaintextWire,
            maxFragmentLen: 7
        )
        try {
            let _ =
                option.openAndIngressJinguiAcceptedTransportApplicationDataH2HeaderBlocks(
                    session,
                    clientFragments
                )
            @Fail("expected invalid H2 application-data ingress rejection")
        } catch (e: Exception) {
            observedError = e.message
        }

        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataH2HeaderBlockIngressAccumulatorProbeEngine <: ServerEngine {
    public var firstBufferedRecordWireByteCount: Int64 = 0
    public var firstCompletedHeaderBlockCount: Int64 = 0
    public var midBufferedRecordWireByteCount: Int64 = 0
    public var midHasOpenHeaderBlock: Bool = false
    public var midBufferedHeaderBlockByteCount: Int64 = 0
    public var midCompletedHeaderBlockCount: Int64 = 0
    public var completedHeaderBlockCount: Int64 = 0
    public var completedHeaderBlockStreamId: Int64 = 0
    public var completedHeaderBlockEndStream: Bool = false
    public var completedHeaderBlockText: String = ""
    public var finalBufferedRecordWireByteCount: Int64 = 0
    public var finalBufferedH2FrameWireByteCount: Int64 = 0
    public var finalHasOpenHeaderBlock: Bool = false

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let transport = ContractAcceptedTransportDescriptor(
            "appdata-h2-record-wire-ingress-accepted-transport",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55447"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 96))
        )
        let session = option.attachJinguiAcceptedTransportTls13X25519(
            transport,
            clientHello.encodedClientHello,
            engineIncrementalBytes(32, start: 128)
        )
        let clientChannel = contractTls13CreateClientRecordChannel(
            session.keyMaterial,
            algorithm: session.recordChannel.algorithm
        )
        let plaintextWire = concatServerEngineAbstractionTestByteArrays([
            buildServerEngineAbstractionTestH2FrameWire(
                buildServerEngineAbstractionTestH2HeadersPayload(
                    serverEngineAbstractionTestByteArray("abc".toArray())
                ),
                frameType: UInt8(0x1),
                flags: UInt8(0x1),
                streamId: 41
            ),
            buildServerEngineAbstractionTestH2FrameWire(
                serverEngineAbstractionTestByteArray("def".toArray()),
                frameType: UInt8(0x9),
                flags: UInt8(0x4),
                streamId: 41
            )
        ])
        let clientFragments = clientChannel.sealFragments(
            ContractTlsRecordContentType.ApplicationData,
            plaintextWire,
            maxFragmentLen: 7
        )
        let encodedWire =
            concatServerEngineAbstractionTestByteArrays(clientFragments)
        if (encodedWire.size <= 7) {
            throw Exception(
                "expected fragmented accepted-session TLS record wire larger than the staged split"
            )
        }
        let ingress =
            option.buildJinguiAcceptedTransportApplicationDataH2HeaderBlockIngressAccumulator(
                session
            )
        ingress.append(cloneServerEngineByteWindow(encodedWire, 0, 4))
        firstBufferedRecordWireByteCount =
            ingress.bufferedRecordWireByteCount()
        firstCompletedHeaderBlockCount =
            ingress.drainCompleteHeaderBlocks().size

        ingress.append(
            cloneServerEngineByteWindow(
                encodedWire,
                4,
                encodedWire.size - 7
            )
        )
        midBufferedRecordWireByteCount =
            ingress.bufferedRecordWireByteCount()
        midHasOpenHeaderBlock = ingress.hasOpenHeaderBlock()
        midBufferedHeaderBlockByteCount =
            ingress.bufferedHeaderBlockByteCount()
        midCompletedHeaderBlockCount =
            ingress.drainCompleteHeaderBlocks().size

        ingress.append(
            cloneServerEngineByteWindow(
                encodedWire,
                encodedWire.size - 3,
                3
            )
        )
        let completed = ingress.drainCompleteHeaderBlocks()
        completedHeaderBlockCount = completed.size
        if (completed.size > 0) {
            completedHeaderBlockStreamId = completed[0].streamId
            completedHeaderBlockEndStream = completed[0].endStream
            completedHeaderBlockText =
                serverEngineAbstractionTestByteText(
                    completed[0].headerBlockFragment
                )
        }
        finalBufferedRecordWireByteCount =
            ingress.bufferedRecordWireByteCount()
        finalBufferedH2FrameWireByteCount =
            ingress.bufferedH2FrameWireByteCount()
        finalHasOpenHeaderBlock = ingress.hasOpenHeaderBlock()

        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataH2HeaderBlockIngressAccumulatorRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let transport = ContractAcceptedTransportDescriptor(
            "appdata-h2-record-wire-ingress-reject-accepted-transport",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55448"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 96))
        )
        let session = option.attachJinguiAcceptedTransportTls13X25519(
            transport,
            clientHello.encodedClientHello,
            engineIncrementalBytes(32, start: 128)
        )
        let clientChannel = contractTls13CreateClientRecordChannel(
            session.keyMaterial,
            algorithm: session.recordChannel.algorithm
        )
        let plaintextWire = concatServerEngineAbstractionTestByteArrays([
            buildServerEngineAbstractionTestH2FrameWire(
                buildServerEngineAbstractionTestH2HeadersPayload(
                    serverEngineAbstractionTestByteArray("abc".toArray())
                ),
                frameType: UInt8(0x1),
                flags: UInt8(0x1),
                streamId: 43
            ),
            buildServerEngineAbstractionTestH2FrameWire(
                serverEngineAbstractionTestByteArray("body".toArray()),
                frameType: UInt8(0x0),
                flags: UInt8(0x0),
                streamId: 43
            )
        ])
        let clientFragments = clientChannel.sealFragments(
            ContractTlsRecordContentType.ApplicationData,
            plaintextWire,
            maxFragmentLen: 7
        )
        let encodedWire =
            concatServerEngineAbstractionTestByteArrays(clientFragments)
        let ingress =
            option.buildJinguiAcceptedTransportApplicationDataH2HeaderBlockIngressAccumulator(
                session
            )
        try {
            ingress.append(encodedWire)
            @Fail(
                "expected accepted-session fragmented record-wire H2 ingress rejection"
            )
        } catch (e: Exception) {
            observedError = e.message
        }

        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataLogicalRequestAccumulatorProbeEngine <: ServerEngine {
    public var firstCompletedLogicalRequestCount: Int64 = 0
    public var midCompletedLogicalRequestCount: Int64 = 0
    public var midHasOpenHeaderBlock: Bool = false
    public var midBufferedHeaderBlockByteCount: Int64 = 0
    public var completedLogicalRequestCount: Int64 = 0
    public var requestMethod: String = ""
    public var requestPath: String = ""
    public var requestUrl: String = ""
    public var requestQuery: String = ""
    public var requestVersion: String = ""
    public var requestHost: String = ""
    public var requestMode: String = ""
    public var requestBody: String = ""
    public var finalBufferedRecordWireByteCount: Int64 = 0
    public var finalBufferedH2FrameWireByteCount: Int64 = 0
    public var finalHasOpenHeaderBlock: Bool = false

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let transport = ContractAcceptedTransportDescriptor(
            "appdata-logical-request-accumulator-accepted-transport",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55449"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 96))
        )
        let session = option.attachJinguiAcceptedTransportTls13X25519(
            transport,
            clientHello.encodedClientHello,
            engineIncrementalBytes(32, start: 128)
        )
        let clientChannel = contractTls13CreateClientRecordChannel(
            session.keyMaterial,
            algorithm: session.recordChannel.algorithm
        )
        let headerBlockFragment = concatServerEngineAbstractionTestByteArrays([
            serverEngineAbstractionTestByteArray([UInt8(0x82)]),
            serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x10)]),
            serverEngineAbstractionTestByteArray("/appdata?turn=ok".toArray()),
            serverEngineAbstractionTestByteArray([UInt8(0x01), UInt8(0x14)]),
            serverEngineAbstractionTestByteArray(
                "api.example.com:9443".toArray()
            ),
            serverEngineAbstractionTestByteArray([UInt8(0x10), UInt8(0x06)]),
            serverEngineAbstractionTestByteArray("x-mode".toArray()),
            serverEngineAbstractionTestByteArray([UInt8(0x06)]),
            serverEngineAbstractionTestByteArray("bridge".toArray())
        ])
        let splitAt: Int64 = 8
        let plaintextWire = concatServerEngineAbstractionTestByteArrays([
            buildServerEngineAbstractionTestH2FrameWire(
                buildServerEngineAbstractionTestH2HeadersPayload(
                    cloneServerEngineByteWindow(
                        headerBlockFragment,
                        0,
                        splitAt
                    )
                ),
                frameType: UInt8(0x1),
                flags: UInt8(0x1),
                streamId: 47
            ),
            buildServerEngineAbstractionTestH2FrameWire(
                cloneServerEngineByteWindow(
                    headerBlockFragment,
                    splitAt,
                    headerBlockFragment.size - splitAt
                ),
                frameType: UInt8(0x9),
                flags: UInt8(0x4),
                streamId: 47
            )
        ])
        let clientFragments = clientChannel.sealFragments(
            ContractTlsRecordContentType.ApplicationData,
            plaintextWire,
            maxFragmentLen: 7
        )
        let encodedWire =
            concatServerEngineAbstractionTestByteArrays(clientFragments)
        let ingress =
            option.buildJinguiAcceptedTransportApplicationDataH2HeaderBlockLogicalRequestAccumulator(
                session,
                bodyBytes: "payload".toArray()
            )
        ingress.append(cloneServerEngineByteWindow(encodedWire, 0, 4))
        firstCompletedLogicalRequestCount =
            ingress.drainCompleteLogicalRequests().size

        ingress.append(
            cloneServerEngineByteWindow(
                encodedWire,
                4,
                encodedWire.size - 7
            )
        )
        midCompletedLogicalRequestCount =
            ingress.drainCompleteLogicalRequests().size
        midHasOpenHeaderBlock = ingress.hasOpenHeaderBlock()
        midBufferedHeaderBlockByteCount =
            ingress.bufferedHeaderBlockByteCount()

        ingress.append(
            cloneServerEngineByteWindow(
                encodedWire,
                encodedWire.size - 3,
                3
            )
        )
        let completed = ingress.drainCompleteLogicalRequests()
        completedLogicalRequestCount = completed.size
        if (completed.size > 0) {
            let request = completed[0]
            requestMethod = request.method
            requestPath = request.path
            requestUrl = request.urlString
            requestQuery = request.queryString
            requestVersion = request.versionString
            requestHost = request.headers.getFirst("host") ?? ""
            requestMode = request.headers.getFirst("x-mode") ?? ""
            requestBody =
                serverEngineAbstractionTestByteText(
                    serverEngineAbstractionTestByteArray(request.bodyBytes)
                )
        }
        finalBufferedRecordWireByteCount =
            ingress.bufferedRecordWireByteCount()
        finalBufferedH2FrameWireByteCount =
            ingress.bufferedH2FrameWireByteCount()
        finalHasOpenHeaderBlock = ingress.hasOpenHeaderBlock()

        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataLogicalRequestAccumulatorRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let transport = ContractAcceptedTransportDescriptor(
            "appdata-logical-request-accumulator-reject-accepted-transport",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55450"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 96))
        )
        let session = option.attachJinguiAcceptedTransportTls13X25519(
            transport,
            clientHello.encodedClientHello,
            engineIncrementalBytes(32, start: 128)
        )
        let clientChannel = contractTls13CreateClientRecordChannel(
            session.keyMaterial,
            algorithm: session.recordChannel.algorithm
        )
        let firstHeaderBlock = concatServerEngineAbstractionTestByteArrays([
            serverEngineAbstractionTestByteArray([UInt8(0x82)]),
            serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
            serverEngineAbstractionTestByteArray("/one".toArray())
        ])
        let secondHeaderBlock = concatServerEngineAbstractionTestByteArrays([
            serverEngineAbstractionTestByteArray([UInt8(0x82)]),
            serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
            serverEngineAbstractionTestByteArray("/two".toArray())
        ])
        let plaintextWire = concatServerEngineAbstractionTestByteArrays([
            buildServerEngineAbstractionTestH2FrameWire(
                buildServerEngineAbstractionTestH2HeadersPayload(
                    firstHeaderBlock
                ),
                frameType: UInt8(0x1),
                flags: UInt8(0x5),
                streamId: 49
            ),
            buildServerEngineAbstractionTestH2FrameWire(
                buildServerEngineAbstractionTestH2HeadersPayload(
                    secondHeaderBlock
                ),
                frameType: UInt8(0x1),
                flags: UInt8(0x5),
                streamId: 51
            )
        ])
        let clientFragments = clientChannel.sealFragments(
            ContractTlsRecordContentType.ApplicationData,
            plaintextWire,
            maxFragmentLen: 7
        )
        let encodedWire =
            concatServerEngineAbstractionTestByteArrays(clientFragments)
        let ingress =
            option.buildJinguiAcceptedTransportApplicationDataH2HeaderBlockLogicalRequestAccumulator(
                session
            )
        try {
            ingress.append(encodedWire)
            @Fail(
                "expected fragmented-record-wire logical-request multi-header-block rejection"
            )
        } catch (e: Exception) {
            observedError = e.message
        }

        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataHeadersPlusDataLogicalRequestAccumulatorProbeEngine <: ServerEngine {
    public var firstCompletedLogicalRequestCount: Int64 = 0
    public var midCompletedLogicalRequestCount: Int64 = 0
    public var midHasOpenHeaderBlock: Bool = false
    public var midBufferedHeaderBlockByteCount: Int64 = 0
    public var midBufferedBodyByteCount: Int64 = 0
    public var completedLogicalRequestCount: Int64 = 0
    public var requestMethod: String = ""
    public var requestPath: String = ""
    public var requestUrl: String = ""
    public var requestQuery: String = ""
    public var requestVersion: String = ""
    public var requestHost: String = ""
    public var requestMode: String = ""
    public var requestBody: String = ""
    public var finalBufferedRecordWireByteCount: Int64 = 0
    public var finalBufferedH2FrameWireByteCount: Int64 = 0
    public var finalHasOpenHeaderBlock: Bool = false
    public var finalBufferedBodyByteCount: Int64 = 0

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let transport = ContractAcceptedTransportDescriptor(
            "appdata-headers-plus-data-logical-request-accumulator-accepted-transport",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55451"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 96))
        )
        let session = option.attachJinguiAcceptedTransportTls13X25519(
            transport,
            clientHello.encodedClientHello,
            engineIncrementalBytes(32, start: 128)
        )
        let clientChannel = contractTls13CreateClientRecordChannel(
            session.keyMaterial,
            algorithm: session.recordChannel.algorithm
        )
        let headerBlockFragment = concatServerEngineAbstractionTestByteArrays([
            serverEngineAbstractionTestByteArray([UInt8(0x83)]),
            serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x15)]),
            serverEngineAbstractionTestByteArray("/appdata-data?turn=ok".toArray()),
            serverEngineAbstractionTestByteArray([UInt8(0x01), UInt8(0x14)]),
            serverEngineAbstractionTestByteArray(
                "api.example.com:9443".toArray()
            ),
            serverEngineAbstractionTestByteArray([UInt8(0x10), UInt8(0x06)]),
            serverEngineAbstractionTestByteArray("x-mode".toArray()),
            serverEngineAbstractionTestByteArray([UInt8(0x0b)]),
            serverEngineAbstractionTestByteArray("bridge-data".toArray())
        ])
        let plaintextWire = concatServerEngineAbstractionTestByteArrays([
            buildServerEngineAbstractionTestH2FrameWire(
                buildServerEngineAbstractionTestH2HeadersPayload(
                    headerBlockFragment
                ),
                frameType: UInt8(0x1),
                flags: UInt8(0x4),
                streamId: 53
            ),
            buildServerEngineAbstractionTestH2FrameWire(
                serverEngineAbstractionTestByteArray(
                    "accepted-".toArray()
                ),
                frameType: UInt8(0x0),
                flags: UInt8(0x0),
                streamId: 53
            ),
            buildServerEngineAbstractionTestH2FrameWire(
                serverEngineAbstractionTestByteArray(
                    "appdata-body".toArray()
                ),
                frameType: UInt8(0x0),
                flags: UInt8(0x1),
                streamId: 53
            )
        ])
        let clientFragments = clientChannel.sealFragments(
            ContractTlsRecordContentType.ApplicationData,
            plaintextWire,
            maxFragmentLen: 7
        )
        let encodedWire =
            concatServerEngineAbstractionTestByteArrays(clientFragments)
        let ingress =
            option.buildJinguiAcceptedTransportApplicationDataH2HeadersPlusDataLogicalRequestAccumulator(
                session
            )
        ingress.append(cloneServerEngineByteWindow(encodedWire, 0, 4))
        firstCompletedLogicalRequestCount =
            ingress.drainCompleteLogicalRequests().size

        ingress.append(
            cloneServerEngineByteWindow(
                encodedWire,
                4,
                encodedWire.size - 7
            )
        )
        midCompletedLogicalRequestCount =
            ingress.drainCompleteLogicalRequests().size
        midHasOpenHeaderBlock = ingress.hasOpenHeaderBlock()
        midBufferedHeaderBlockByteCount =
            ingress.bufferedHeaderBlockByteCount()
        midBufferedBodyByteCount =
            ingress.bufferedBodyByteCount()

        ingress.append(
            cloneServerEngineByteWindow(
                encodedWire,
                encodedWire.size - 3,
                3
            )
        )
        let completed = ingress.drainCompleteLogicalRequests()
        completedLogicalRequestCount = completed.size
        if (completed.size > 0) {
            let request = completed[0]
            requestMethod = request.method
            requestPath = request.path
            requestUrl = request.urlString
            requestQuery = request.queryString
            requestVersion = request.versionString
            requestHost = request.headers.getFirst("host") ?? ""
            requestMode = request.headers.getFirst("x-mode") ?? ""
            requestBody =
                serverEngineAbstractionTestByteText(
                    serverEngineAbstractionTestByteArray(request.bodyBytes)
                )
        }
        finalBufferedRecordWireByteCount =
            ingress.bufferedRecordWireByteCount()
        finalBufferedH2FrameWireByteCount =
            ingress.bufferedH2FrameWireByteCount()
        finalHasOpenHeaderBlock = ingress.hasOpenHeaderBlock()
        finalBufferedBodyByteCount =
            ingress.bufferedBodyByteCount()

        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataHeadersPlusDataLogicalRequestAccumulatorRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let transport = ContractAcceptedTransportDescriptor(
            "appdata-headers-plus-data-logical-request-accumulator-reject-accepted-transport",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55452"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 96))
        )
        let session = option.attachJinguiAcceptedTransportTls13X25519(
            transport,
            clientHello.encodedClientHello,
            engineIncrementalBytes(32, start: 128)
        )
        let clientChannel = contractTls13CreateClientRecordChannel(
            session.keyMaterial,
            algorithm: session.recordChannel.algorithm
        )
        let headerBlockFragment = concatServerEngineAbstractionTestByteArrays([
            serverEngineAbstractionTestByteArray([UInt8(0x83)]),
            serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
            serverEngineAbstractionTestByteArray("/one".toArray())
        ])
        let plaintextWire = concatServerEngineAbstractionTestByteArrays([
            buildServerEngineAbstractionTestH2FrameWire(
                buildServerEngineAbstractionTestH2HeadersPayload(
                    headerBlockFragment
                ),
                frameType: UInt8(0x1),
                flags: UInt8(0x4),
                streamId: 55
            ),
            buildServerEngineAbstractionTestH2FrameWire(
                serverEngineAbstractionTestByteArray(
                    "blocked".toArray()
                ),
                frameType: UInt8(0x0),
                flags: UInt8(0x1),
                streamId: 57
            )
        ])
        let clientFragments = clientChannel.sealFragments(
            ContractTlsRecordContentType.ApplicationData,
            plaintextWire,
            maxFragmentLen: 7
        )
        let encodedWire =
            concatServerEngineAbstractionTestByteArrays(clientFragments)
        let ingress =
            option.buildJinguiAcceptedTransportApplicationDataH2HeadersPlusDataLogicalRequestAccumulator(
                session
            )
        try {
            ingress.append(encodedWire)
            @Fail(
                "expected fragmented-record-wire headers-plus-data logical-request wrong-stream DATA rejection"
            )
        } catch (e: Exception) {
            observedError = e.message
        }

        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataFragmentedRecordWireProvidedBodyRequestTurnProbeEngine <: ServerEngine {
    public var bodyStringReadyStatus: String = ""
    public var bodyJsonReadyStatus: String = ""
    public var bodyStringResponseStatus: UInt16 = 0
    public var bodyJsonResponseStatus: UInt16 = 0
    public var bodyStringContentType: String = ""
    public var bodyJsonContentType: String = ""
    public var bodyStringTransferEncoding: String = ""
    public var bodyJsonTransferEncoding: String = ""
    public var bodyStringSocketWriteCount: Int64 = 0
    public var bodyJsonSocketWriteCount: Int64 = 0
    var bodyStringClientChannel: ?ContractTlsRecordChannel = None
    var bodyJsonClientChannel: ?ContractTlsRecordChannel = None

    public func openBodyStringSocketWire(wire: Array<UInt8>): String {
        match (bodyStringClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected fragmented appdata bodyString companion client record channel before socket wire open"
                )
        }
    }

    public func openBodyJsonSocketWire(wire: Array<UInt8>): String {
        match (bodyJsonClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected fragmented appdata bodyJson companion client record channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let bodyStringAccepted = listener.accept()
            try {
                let bodyStringHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1152)
                    )
                )
                let bodyStringHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x27)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-fragmented-appdata-body-string".toArray()
                    )
                ])
                let bodyStringTransport = ContractAcceptedTransportDescriptor(
                    "fragmented-appdata-body-string-transport",
                    localEndpoint: bodyStringAccepted.localAddress.toString(),
                    remoteEndpoint: bodyStringAccepted.remoteAddress.toString()
                )
                let bodyStringSession = option.attachJinguiAcceptedTransportTls13X25519(
                    bodyStringTransport,
                    bodyStringHello.encodedClientHello,
                    engineIncrementalBytes(32, start: 1184)
                )
                let bodyStringRequestClientChannel =
                    contractTls13CreateClientRecordChannel(
                        bodyStringSession.keyMaterial,
                        algorithm: bodyStringSession.recordChannel.algorithm
                    )
                let bodyStringRequestRecords =
                    bodyStringRequestClientChannel.sealFragments(
                        ContractTlsRecordContentType.ApplicationData,
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                bodyStringHeaderBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x5),
                            streamId: 65
                        ),
                        maxFragmentLen: 7
                    )
                let bodyStringEncodedWire =
                    concatServerEngineAbstractionTestByteArrays(
                        bodyStringRequestRecords
                    )
                let bodyStringTurn =
                    option.serveJinguiAcceptedTransportSessionApplicationDataFragmentedRecordWireH2ProvidedBodyRequestTurn(
                        bodyStringSession,
                        bodyStringAccepted,
                        app,
                        [
                            cloneServerEngineByteWindow(
                                bodyStringEncodedWire,
                                0,
                                4
                            ),
                            cloneServerEngineByteWindow(
                                bodyStringEncodedWire,
                                4,
                                bodyStringEncodedWire.size - 7
                            ),
                            cloneServerEngineByteWindow(
                                bodyStringEncodedWire,
                                bodyStringEncodedWire.size - 3,
                                3
                            )
                        ],
                        bodyBytes: "accepted-appdata-body".toArray(),
                        maxFragmentLen: 8
                    )
                bodyStringClientChannel = Some(bodyStringRequestClientChannel)
                bodyStringReadyStatus = bodyStringTurn.readySnapshot.status
                bodyStringResponseStatus = bodyStringTurn.responseStatus
                bodyStringContentType =
                    bodyStringTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyStringTransferEncoding =
                    bodyStringTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyStringSocketWriteCount = bodyStringTurn.socketWriteCount
            } finally {
                if (!bodyStringAccepted.isClosed()) {
                    bodyStringAccepted.close()
                }
            }

            let bodyJsonAccepted = listener.accept()
            try {
                let bodyJsonHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1216)
                    )
                )
                let bodyJsonHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x25)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-fragmented-appdata-body-json".toArray()
                    )
                ])
                let bodyJsonTransport = ContractAcceptedTransportDescriptor(
                    "fragmented-appdata-body-json-transport",
                    localEndpoint: bodyJsonAccepted.localAddress.toString(),
                    remoteEndpoint: bodyJsonAccepted.remoteAddress.toString()
                )
                let bodyJsonSession = option.attachJinguiAcceptedTransportTls13X25519(
                    bodyJsonTransport,
                    bodyJsonHello.encodedClientHello,
                    engineIncrementalBytes(32, start: 1248)
                )
                let bodyJsonRequestClientChannel =
                    contractTls13CreateClientRecordChannel(
                        bodyJsonSession.keyMaterial,
                        algorithm: bodyJsonSession.recordChannel.algorithm
                    )
                let bodyJsonRequestRecords =
                    bodyJsonRequestClientChannel.sealFragments(
                        ContractTlsRecordContentType.ApplicationData,
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                bodyJsonHeaderBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x5),
                            streamId: 67
                        ),
                        maxFragmentLen: 7
                    )
                let bodyJsonEncodedWire =
                    concatServerEngineAbstractionTestByteArrays(
                        bodyJsonRequestRecords
                    )
                let bodyJsonTurn =
                    option.serveJinguiAcceptedTransportSessionApplicationDataFragmentedRecordWireH2ProvidedBodyRequestTurn(
                        bodyJsonSession,
                        bodyJsonAccepted,
                        app,
                        [
                            cloneServerEngineByteWindow(
                                bodyJsonEncodedWire,
                                0,
                                4
                            ),
                            cloneServerEngineByteWindow(
                                bodyJsonEncodedWire,
                                4,
                                bodyJsonEncodedWire.size - 7
                            ),
                            cloneServerEngineByteWindow(
                                bodyJsonEncodedWire,
                                bodyJsonEncodedWire.size - 3,
                                3
                            )
                        ],
                        bodyBytes: "{\"name\":\"ignite\",\"val\":23}".toArray(),
                        maxFragmentLen: 8
                    )
                bodyJsonClientChannel = Some(bodyJsonRequestClientChannel)
                bodyJsonReadyStatus = bodyJsonTurn.readySnapshot.status
                bodyJsonResponseStatus = bodyJsonTurn.responseStatus
                bodyJsonContentType =
                    bodyJsonTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyJsonTransferEncoding =
                    bodyJsonTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyJsonSocketWriteCount = bodyJsonTurn.socketWriteCount
            } finally {
                if (!bodyJsonAccepted.isClosed()) {
                    bodyJsonAccepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataFragmentedRecordWireProvidedBodyRequestTurnRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let clientHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1280)
                    )
                )
                let firstHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/one".toArray())
                ])
                let secondHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/two".toArray())
                ])
                let transport = ContractAcceptedTransportDescriptor(
                    "fragmented-appdata-provided-body-reject-transport",
                    localEndpoint: accepted.localAddress.toString(),
                    remoteEndpoint: accepted.remoteAddress.toString()
                )
                let session = option.attachJinguiAcceptedTransportTls13X25519(
                    transport,
                    clientHello.encodedClientHello,
                    engineIncrementalBytes(32, start: 1312)
                )
                let requestClientChannel = contractTls13CreateClientRecordChannel(
                    session.keyMaterial,
                    algorithm: session.recordChannel.algorithm
                )
                let requestRecords = requestClientChannel.sealFragments(
                    ContractTlsRecordContentType.ApplicationData,
                    concatServerEngineAbstractionTestByteArrays([
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                firstHeaderBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x5),
                            streamId: 69
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                secondHeaderBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x5),
                            streamId: 71
                        )
                    ]),
                    maxFragmentLen: 7
                )
                let encodedWire =
                    concatServerEngineAbstractionTestByteArrays(requestRecords)
                try {
                    let _ =
                        option.serveJinguiAcceptedTransportSessionApplicationDataFragmentedRecordWireH2ProvidedBodyRequestTurn(
                            session,
                            accepted,
                            app,
                            [
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    0,
                                    4
                                ),
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    4,
                                    encodedWire.size - 7
                                ),
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    encodedWire.size - 3,
                                    3
                                )
                            ],
                            bodyBytes: "blocked".toArray(),
                            maxFragmentLen: 8
                        )
                    @Fail(
                        "expected fragmented-record-wire provided-body turn rejection"
                    )
                } catch (e: Exception) {
                    observedError = e.message
                }
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataLogicalRequestProjectionProbeEngine <: ServerEngine {
    public var requestMethod: String = ""
    public var requestPath: String = ""
    public var requestUrl: String = ""
    public var requestQuery: String = ""
    public var requestVersion: String = ""
    public var requestHost: String = ""
    public var requestMode: String = ""
    public var requestBody: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let transport = ContractAcceptedTransportDescriptor(
            "appdata-logical-request-accepted-transport",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55447"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 96))
        )
        let session = option.attachJinguiAcceptedTransportTls13X25519(
            transport,
            clientHello.encodedClientHello,
            engineIncrementalBytes(32, start: 128)
        )
        let clientChannel = contractTls13CreateClientRecordChannel(
            session.keyMaterial,
            algorithm: session.recordChannel.algorithm
        )
        let headerBlockFragment = concatServerEngineAbstractionTestByteArrays([
            serverEngineAbstractionTestByteArray([UInt8(0x82)]),
            serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x10)]),
            serverEngineAbstractionTestByteArray("/appdata?turn=ok".toArray()),
            serverEngineAbstractionTestByteArray([UInt8(0x01), UInt8(0x14)]),
            serverEngineAbstractionTestByteArray(
                "api.example.com:9443".toArray()
            ),
            serverEngineAbstractionTestByteArray([UInt8(0x10), UInt8(0x06)]),
            serverEngineAbstractionTestByteArray("x-mode".toArray()),
            serverEngineAbstractionTestByteArray([UInt8(0x06)]),
            serverEngineAbstractionTestByteArray("bridge".toArray())
        ])
        let plaintextWire = buildServerEngineAbstractionTestH2FrameWire(
            buildServerEngineAbstractionTestH2HeadersPayload(
                headerBlockFragment
            ),
            frameType: UInt8(0x1),
            flags: UInt8(0x5),
            streamId: 41
        )
        let clientFragments = clientChannel.sealFragments(
            ContractTlsRecordContentType.ApplicationData,
            plaintextWire,
            maxFragmentLen: 7
        )
        let request =
            option.openAndBuildJinguiAcceptedTransportLogicalRequestFromApplicationDataH2HeaderBlock(
                session,
                clientFragments,
                bodyBytes: "payload".toArray()
            )
        requestMethod = request.method
        requestPath = request.path
        requestUrl = request.urlString
        requestQuery = request.queryString
        requestVersion = request.versionString
        requestHost = request.headers.getFirst("host") ?? ""
        requestMode = request.headers.getFirst("x-mode") ?? ""
        requestBody =
            serverEngineAbstractionTestByteText(
                serverEngineAbstractionTestByteArray(request.bodyBytes)
            )

        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataLogicalRequestProjectionRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let transport = ContractAcceptedTransportDescriptor(
            "appdata-logical-request-reject-accepted-transport",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55448"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 96))
        )
        let session = option.attachJinguiAcceptedTransportTls13X25519(
            transport,
            clientHello.encodedClientHello,
            engineIncrementalBytes(32, start: 128)
        )
        let clientChannel = contractTls13CreateClientRecordChannel(
            session.keyMaterial,
            algorithm: session.recordChannel.algorithm
        )
        let firstHeaderBlock = concatServerEngineAbstractionTestByteArrays([
            serverEngineAbstractionTestByteArray([UInt8(0x82)]),
            serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
            serverEngineAbstractionTestByteArray("/one".toArray())
        ])
        let secondHeaderBlock = concatServerEngineAbstractionTestByteArrays([
            serverEngineAbstractionTestByteArray([UInt8(0x82)]),
            serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
            serverEngineAbstractionTestByteArray("/two".toArray())
        ])
        let plaintextWire = concatServerEngineAbstractionTestByteArrays([
            buildServerEngineAbstractionTestH2FrameWire(
                buildServerEngineAbstractionTestH2HeadersPayload(
                    firstHeaderBlock
                ),
                frameType: UInt8(0x1),
                flags: UInt8(0x5),
                streamId: 43
            ),
            buildServerEngineAbstractionTestH2FrameWire(
                buildServerEngineAbstractionTestH2HeadersPayload(
                    secondHeaderBlock
                ),
                frameType: UInt8(0x1),
                flags: UInt8(0x5),
                streamId: 45
            )
        ])
        let clientFragments = clientChannel.sealFragments(
            ContractTlsRecordContentType.ApplicationData,
            plaintextWire,
            maxFragmentLen: 7
        )
        try {
            let _ =
                option.openAndBuildJinguiAcceptedTransportLogicalRequestFromApplicationDataH2HeaderBlock(
                    session,
                    clientFragments
                )
            @Fail("expected multi-header-block logical-request rejection")
        } catch (e: Exception) {
            observedError = e.message
        }

        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataBodylessRequestTurnProbeEngine <: ServerEngine {
    public var readyStatus: String = ""
    public var responseStatus: UInt16 = 0
    public var contentType: String = ""
    public var transferEncoding: String = ""
    public var socketWriteCount: Int64 = 0
    var clientChannel: ?ContractTlsRecordChannel = None

    public func openResponseSocketWire(wire: Array<UInt8>): String {
        match (clientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected bodyless turn companion client record channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let clientHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 832)
                    )
                )
                let headerBlockFragment = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x82)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x27)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-turn?turn=from-appdata".toArray()
                    ),
                    serverEngineAbstractionTestByteArray([UInt8(0x10), UInt8(0x06)]),
                    serverEngineAbstractionTestByteArray("x-mode".toArray()),
                    serverEngineAbstractionTestByteArray([UInt8(0x06)]),
                    serverEngineAbstractionTestByteArray("bridge".toArray())
                ])
                let serverPrivate = engineIncrementalBytes(32, start: 864)
                let transport = ContractAcceptedTransportDescriptor(
                    "bodyless-turn-transport",
                    localEndpoint: accepted.localAddress.toString(),
                    remoteEndpoint: accepted.remoteAddress.toString()
                )
                let session = option.attachJinguiAcceptedTransportTls13X25519(
                    transport,
                    clientHello.encodedClientHello,
                    serverPrivate
                )
                let requestClientChannel = contractTls13CreateClientRecordChannel(
                    session.keyMaterial,
                    algorithm: session.recordChannel.algorithm
                )
                let requestFragments = requestClientChannel.sealFragments(
                    ContractTlsRecordContentType.ApplicationData,
                    buildServerEngineAbstractionTestH2FrameWire(
                        buildServerEngineAbstractionTestH2HeadersPayload(
                            headerBlockFragment
                        ),
                        frameType: UInt8(0x1),
                        flags: UInt8(0x5),
                        streamId: 51
                    ),
                    maxFragmentLen: 7
                )
                let turn =
                    option.serveJinguiAcceptedTransportSessionApplicationDataH2BodylessRequestTurn(
                        session,
                        accepted,
                        app,
                        requestFragments,
                        maxFragmentLen: 8
                    )
                clientChannel = Some(requestClientChannel)
                readyStatus = turn.readySnapshot.status
                responseStatus = turn.responseStatus
                contentType =
                    turn.responseHeaders.getFirst("content-type") ?? ""
                transferEncoding =
                    turn.responseHeaders.getFirst("transfer-encoding") ?? ""
                socketWriteCount = turn.socketWriteCount
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataBodylessRequestTurnRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let clientHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 896)
                    )
                )
                let firstHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x82)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/one".toArray())
                ])
                let secondHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x82)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/two".toArray())
                ])
                let serverPrivate = engineIncrementalBytes(32, start: 928)
                let transport = ContractAcceptedTransportDescriptor(
                    "bodyless-turn-reject-transport",
                    localEndpoint: accepted.localAddress.toString(),
                    remoteEndpoint: accepted.remoteAddress.toString()
                )
                let session = option.attachJinguiAcceptedTransportTls13X25519(
                    transport,
                    clientHello.encodedClientHello,
                    serverPrivate
                )
                let requestClientChannel = contractTls13CreateClientRecordChannel(
                    session.keyMaterial,
                    algorithm: session.recordChannel.algorithm
                )
                let requestFragments = requestClientChannel.sealFragments(
                    ContractTlsRecordContentType.ApplicationData,
                    concatServerEngineAbstractionTestByteArrays([
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                firstHeaderBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x5),
                            streamId: 53
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                secondHeaderBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x5),
                            streamId: 55
                        )
                    ]),
                    maxFragmentLen: 7
                )
                try {
                    let _ =
                        option.serveJinguiAcceptedTransportSessionApplicationDataH2BodylessRequestTurn(
                            session,
                            accepted,
                            app,
                            requestFragments,
                            maxFragmentLen: 8
                        )
                    @Fail("expected multi-header-block bodyless turn rejection")
                } catch (e: Exception) {
                    observedError = e.message
                }
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketApplicationDataBodylessRequestTurnProbeEngine <: ServerEngine {
    public var readyStatus: String = ""
    public var responseStatus: UInt16 = 0
    public var contentType: String = ""
    public var transferEncoding: String = ""
    public var socketWriteCount: Int64 = 0
    var clientChannel: ?ContractTlsRecordChannel = None

    public func openResponseSocketWire(wire: Array<UInt8>): String {
        match (clientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected socket bodyless turn companion client record channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let clientHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 2944)
                    )
                )
                let headerBlockFragment = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x82)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x27)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-turn?turn=from-appdata".toArray()
                    ),
                    serverEngineAbstractionTestByteArray([UInt8(0x10), UInt8(0x06)]),
                    serverEngineAbstractionTestByteArray("x-mode".toArray()),
                    serverEngineAbstractionTestByteArray([UInt8(0x06)]),
                    serverEngineAbstractionTestByteArray("bridge".toArray())
                ])
                let serverPrivate = engineIncrementalBytes(32, start: 2976)
                let turn =
                    option.serveJinguiAcceptedTransportSocketApplicationDataH2BodylessRequestTurn(
                        accepted,
                        app,
                        { session =>
                            let requestClientChannel =
                                contractTls13CreateClientRecordChannel(
                                    session.keyMaterial,
                                    algorithm: session.recordChannel.algorithm
                                )
                            clientChannel = Some(requestClientChannel)
                            requestClientChannel.sealFragments(
                                ContractTlsRecordContentType.ApplicationData,
                                buildServerEngineAbstractionTestH2FrameWire(
                                    buildServerEngineAbstractionTestH2HeadersPayload(
                                        headerBlockFragment
                                    ),
                                    frameType: UInt8(0x1),
                                    flags: UInt8(0x5),
                                    streamId: 139
                                ),
                                maxFragmentLen: 7
                            )
                        },
                        clientHello.encodedClientHello,
                        serverPrivate,
                        transportId: "socket-bodyless-turn-transport",
                        maxFragmentLen: 8
                    )
                readyStatus = turn.readySnapshot.status
                responseStatus = turn.responseStatus
                contentType =
                    turn.responseHeaders.getFirst("content-type") ?? ""
                transferEncoding =
                    turn.responseHeaders.getFirst("transfer-encoding") ?? ""
                socketWriteCount = turn.socketWriteCount
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketApplicationDataBodylessRequestTurnRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let clientHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 3008)
                    )
                )
                let firstHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x82)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/one".toArray())
                ])
                let secondHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x82)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/two".toArray())
                ])
                let serverPrivate = engineIncrementalBytes(32, start: 3040)
                try {
                    let _ =
                        option.serveJinguiAcceptedTransportSocketApplicationDataH2BodylessRequestTurn(
                            accepted,
                            app,
                            { session =>
                                let requestClientChannel =
                                    contractTls13CreateClientRecordChannel(
                                        session.keyMaterial,
                                        algorithm: session.recordChannel.algorithm
                                    )
                                requestClientChannel.sealFragments(
                                    ContractTlsRecordContentType.ApplicationData,
                                    concatServerEngineAbstractionTestByteArrays([
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            buildServerEngineAbstractionTestH2HeadersPayload(
                                                firstHeaderBlock
                                            ),
                                            frameType: UInt8(0x1),
                                            flags: UInt8(0x5),
                                            streamId: 141
                                        ),
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            buildServerEngineAbstractionTestH2HeadersPayload(
                                                secondHeaderBlock
                                            ),
                                            frameType: UInt8(0x1),
                                            flags: UInt8(0x5),
                                            streamId: 143
                                        )
                                    ]),
                                    maxFragmentLen: 7
                                )
                            },
                            clientHello.encodedClientHello,
                            serverPrivate,
                            transportId: "socket-bodyless-turn-reject-transport",
                            maxFragmentLen: 8
                        )
                    @Fail("expected socket multi-header-block bodyless turn rejection")
                } catch (e: Exception) {
                    observedError = e.message
                }
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataBodylessRequestTurnProbeEngine <: ServerEngine {
    public var readyStatus: String = ""
    public var responseStatus: UInt16 = 0
    public var contentType: String = ""
    public var transferEncoding: String = ""
    public var socketWriteCount: Int64 = 0
    public var negotiatedAlpn: String = ""
    public var requestedServerName: String = ""
    public var attachSurface: String = ""
    public var transportId: String = ""
    var clientChannel: ?ContractTlsRecordChannel = None

    public func openResponseSocketWire(wire: Array<UInt8>): String {
        match (clientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected captured bodyless turn companion client record channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let clientHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 2688)
                    )
                )
                let headerBlockFragment = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x82)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x32)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-captured-bodyless-turn?turn=from-captured".toArray()
                    ),
                    serverEngineAbstractionTestByteArray([UInt8(0x10), UInt8(0x06)]),
                    serverEngineAbstractionTestByteArray("x-mode".toArray()),
                    serverEngineAbstractionTestByteArray([UInt8(0x06)]),
                    serverEngineAbstractionTestByteArray("bridge".toArray())
                ])
                let serverPrivate = engineIncrementalBytes(32, start: 2720)
                let turn =
                    option.serveJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataH2BodylessRequestTurn(
                        accepted,
                        app,
                        { session =>
                            let requestClientChannel =
                                contractTls13CreateClientRecordChannel(
                                    session.keyMaterial,
                                    algorithm: session.recordChannel.algorithm
                                )
                            clientChannel = Some(requestClientChannel)
                            requestClientChannel.sealFragments(
                                ContractTlsRecordContentType.ApplicationData,
                                buildServerEngineAbstractionTestH2FrameWire(
                                    buildServerEngineAbstractionTestH2HeadersPayload(
                                        headerBlockFragment
                                    ),
                                    frameType: UInt8(0x1),
                                    flags: UInt8(0x5),
                                    streamId: 57
                                ),
                                maxFragmentLen: 7
                            )
                        },
                        serverPrivate,
                        transportId: "captured-clienthello-bodyless-turn-transport",
                        readChunkSize: 5,
                        maxFragmentLen: 8
                    )
                readyStatus = turn.readySnapshot.status
                responseStatus = turn.responseStatus
                contentType =
                    turn.responseHeaders.getFirst("content-type") ?? ""
                transferEncoding =
                    turn.responseHeaders.getFirst("transfer-encoding") ?? ""
                socketWriteCount = turn.socketWriteCount
                negotiatedAlpn =
                    turn.readySnapshot.jinguiAttachResultSnapshot.negotiatedAlpn
                requestedServerName =
                    turn.readySnapshot.jinguiAttachResultSnapshot.requestedServerName
                attachSurface =
                    turn.readySnapshot.jinguiAttachResultSnapshot.attachSurface
                transportId = turn.readySnapshot.transport.transportId
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataBodylessRequestTurnRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                try {
                    let _ =
                        option.serveJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataH2BodylessRequestTurn(
                            accepted,
                            app,
                            { session =>
                                let _ = session
                                []
                            },
                            engineIncrementalBytes(32, start: 2752),
                            transportId: "captured-clienthello-bodyless-turn-reject-transport",
                            readChunkSize: 5,
                            maxFragmentLen: 8
                        )
                } catch (e: Exception) {
                    observedError = e.message
                }
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataProvidedBodyRequestTurnProbeEngine <: ServerEngine {
    public var bodyStringReadyStatus: String = ""
    public var bodyJsonReadyStatus: String = ""
    public var bodyStringResponseStatus: UInt16 = 0
    public var bodyJsonResponseStatus: UInt16 = 0
    public var bodyStringContentType: String = ""
    public var bodyJsonContentType: String = ""
    public var bodyStringTransferEncoding: String = ""
    public var bodyJsonTransferEncoding: String = ""
    public var bodyStringSocketWriteCount: Int64 = 0
    public var bodyJsonSocketWriteCount: Int64 = 0
    public var bodyStringNegotiatedAlpn: String = ""
    public var bodyJsonNegotiatedAlpn: String = ""
    public var bodyStringRequestedServerName: String = ""
    public var bodyJsonRequestedServerName: String = ""
    public var bodyStringAttachSurface: String = ""
    public var bodyJsonAttachSurface: String = ""
    public var bodyStringTransportId: String = ""
    public var bodyJsonTransportId: String = ""
    var bodyStringClientChannel: ?ContractTlsRecordChannel = None
    var bodyJsonClientChannel: ?ContractTlsRecordChannel = None

    public func openBodyStringSocketWire(wire: Array<UInt8>): String {
        match (bodyStringClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected captured provided-body bodyString client channel before socket wire open"
                )
        }
    }

    public func openBodyJsonSocketWire(wire: Array<UInt8>): String {
        match (bodyJsonClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected captured provided-body bodyJson client channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let bodyStringAccepted = listener.accept()
            try {
                let bodyStringHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x25)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-captured-appdata-body-string".toArray()
                    )
                ])
                let bodyStringServerPrivate =
                    engineIncrementalBytes(32, start: 3104)
                let bodyStringTurn =
                    option.serveJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataH2ProvidedBodyRequestTurn(
                        bodyStringAccepted,
                        app,
                        { session =>
                            let requestClientChannel =
                                contractTls13CreateClientRecordChannel(
                                    session.keyMaterial,
                                    algorithm: session.recordChannel.algorithm
                                )
                            bodyStringClientChannel = Some(
                                requestClientChannel
                            )
                            requestClientChannel.sealFragments(
                                ContractTlsRecordContentType.ApplicationData,
                                buildServerEngineAbstractionTestH2FrameWire(
                                    buildServerEngineAbstractionTestH2HeadersPayload(
                                        bodyStringHeaderBlock
                                    ),
                                    frameType: UInt8(0x1),
                                    flags: UInt8(0x5),
                                    streamId: 145
                                ),
                                maxFragmentLen: 7
                            )
                        },
                        bodyStringServerPrivate,
                        bodyBytes: "accepted-appdata-body".toArray(),
                        transportId: "captured-clienthello-provided-body-string-transport",
                        readChunkSize: 5,
                        maxFragmentLen: 8
                    )
                bodyStringReadyStatus = bodyStringTurn.readySnapshot.status
                bodyStringResponseStatus = bodyStringTurn.responseStatus
                bodyStringContentType =
                    bodyStringTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyStringTransferEncoding =
                    bodyStringTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyStringSocketWriteCount = bodyStringTurn.socketWriteCount
                bodyStringNegotiatedAlpn =
                    bodyStringTurn.readySnapshot.jinguiAttachResultSnapshot.negotiatedAlpn
                bodyStringRequestedServerName =
                    bodyStringTurn.readySnapshot.jinguiAttachResultSnapshot.requestedServerName
                bodyStringAttachSurface =
                    bodyStringTurn.readySnapshot.jinguiAttachResultSnapshot.attachSurface
                bodyStringTransportId =
                    bodyStringTurn.readySnapshot.transport.transportId
            } finally {
                if (!bodyStringAccepted.isClosed()) {
                    bodyStringAccepted.close()
                }
            }

            let bodyJsonAccepted = listener.accept()
            try {
                let bodyJsonHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x23)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-captured-appdata-body-json".toArray()
                    )
                ])
                let bodyJsonServerPrivate =
                    engineIncrementalBytes(32, start: 3168)
                let bodyJsonTurn =
                    option.serveJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataH2ProvidedBodyRequestTurn(
                        bodyJsonAccepted,
                        app,
                        { session =>
                            let requestClientChannel =
                                contractTls13CreateClientRecordChannel(
                                    session.keyMaterial,
                                    algorithm: session.recordChannel.algorithm
                                )
                            bodyJsonClientChannel = Some(
                                requestClientChannel
                            )
                            requestClientChannel.sealFragments(
                                ContractTlsRecordContentType.ApplicationData,
                                buildServerEngineAbstractionTestH2FrameWire(
                                    buildServerEngineAbstractionTestH2HeadersPayload(
                                        bodyJsonHeaderBlock
                                    ),
                                    frameType: UInt8(0x1),
                                    flags: UInt8(0x5),
                                    streamId: 147
                                ),
                                maxFragmentLen: 7
                            )
                        },
                        bodyJsonServerPrivate,
                        bodyBytes: "{\"name\":\"ignite\",\"val\":23}".toArray(),
                        transportId: "captured-clienthello-provided-body-json-transport",
                        readChunkSize: 5,
                        maxFragmentLen: 8
                    )
                bodyJsonReadyStatus = bodyJsonTurn.readySnapshot.status
                bodyJsonResponseStatus = bodyJsonTurn.responseStatus
                bodyJsonContentType =
                    bodyJsonTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyJsonTransferEncoding =
                    bodyJsonTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyJsonSocketWriteCount = bodyJsonTurn.socketWriteCount
                bodyJsonNegotiatedAlpn =
                    bodyJsonTurn.readySnapshot.jinguiAttachResultSnapshot.negotiatedAlpn
                bodyJsonRequestedServerName =
                    bodyJsonTurn.readySnapshot.jinguiAttachResultSnapshot.requestedServerName
                bodyJsonAttachSurface =
                    bodyJsonTurn.readySnapshot.jinguiAttachResultSnapshot.attachSurface
                bodyJsonTransportId =
                    bodyJsonTurn.readySnapshot.transport.transportId
            } finally {
                if (!bodyJsonAccepted.isClosed()) {
                    bodyJsonAccepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataProvidedBodyRequestTurnRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let firstHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/one".toArray())
                ])
                let secondHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/two".toArray())
                ])
                let serverPrivate = engineIncrementalBytes(32, start: 3232)
                try {
                    let _ =
                        option.serveJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataH2ProvidedBodyRequestTurn(
                            accepted,
                            app,
                            { session =>
                                let requestClientChannel =
                                    contractTls13CreateClientRecordChannel(
                                        session.keyMaterial,
                                        algorithm: session.recordChannel.algorithm
                                    )
                                requestClientChannel.sealFragments(
                                    ContractTlsRecordContentType.ApplicationData,
                                    concatServerEngineAbstractionTestByteArrays([
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            buildServerEngineAbstractionTestH2HeadersPayload(
                                                firstHeaderBlock
                                            ),
                                            frameType: UInt8(0x1),
                                            flags: UInt8(0x5),
                                            streamId: 149
                                        ),
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            buildServerEngineAbstractionTestH2HeadersPayload(
                                                secondHeaderBlock
                                            ),
                                            frameType: UInt8(0x1),
                                            flags: UInt8(0x5),
                                            streamId: 151
                                        )
                                    ]),
                                    maxFragmentLen: 7
                                )
                            },
                            serverPrivate,
                            bodyBytes: "blocked".toArray(),
                            transportId: "captured-clienthello-provided-body-reject-transport",
                            readChunkSize: 5,
                            maxFragmentLen: 8
                        )
                    @Fail("expected captured multi-header-block provided-body turn rejection")
                } catch (e: Exception) {
                    observedError = e.message
                }
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataProvidedBodyRequestTurnProbeEngine <: ServerEngine {
    public var bodyStringReadyStatus: String = ""
    public var bodyJsonReadyStatus: String = ""
    public var bodyStringResponseStatus: UInt16 = 0
    public var bodyJsonResponseStatus: UInt16 = 0
    public var bodyStringContentType: String = ""
    public var bodyJsonContentType: String = ""
    public var bodyStringTransferEncoding: String = ""
    public var bodyJsonTransferEncoding: String = ""
    public var bodyStringSocketWriteCount: Int64 = 0
    public var bodyJsonSocketWriteCount: Int64 = 0
    var bodyStringClientChannel: ?ContractTlsRecordChannel = None
    var bodyJsonClientChannel: ?ContractTlsRecordChannel = None

    public func openBodyStringSocketWire(wire: Array<UInt8>): String {
        match (bodyStringClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected appdata bodyString companion client record channel before socket wire open"
                )
        }
    }

    public func openBodyJsonSocketWire(wire: Array<UInt8>): String {
        match (bodyJsonClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected appdata bodyJson companion client record channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let bodyStringAccepted = listener.accept()
            try {
                let bodyStringHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 960)
                    )
                )
                let bodyStringHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x1c)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-body-string".toArray()
                    )
                ])
                let bodyStringTransport = ContractAcceptedTransportDescriptor(
                    "appdata-body-string-transport",
                    localEndpoint: bodyStringAccepted.localAddress.toString(),
                    remoteEndpoint: bodyStringAccepted.remoteAddress.toString()
                )
                let bodyStringSession = option.attachJinguiAcceptedTransportTls13X25519(
                    bodyStringTransport,
                    bodyStringHello.encodedClientHello,
                    engineIncrementalBytes(32, start: 992)
                )
                let bodyStringRequestClientChannel =
                    contractTls13CreateClientRecordChannel(
                        bodyStringSession.keyMaterial,
                        algorithm: bodyStringSession.recordChannel.algorithm
                    )
                let bodyStringRequestFragments =
                    bodyStringRequestClientChannel.sealFragments(
                        ContractTlsRecordContentType.ApplicationData,
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                bodyStringHeaderBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x5),
                            streamId: 57
                        ),
                        maxFragmentLen: 7
                    )
                let bodyStringTurn =
                    option.serveJinguiAcceptedTransportSessionApplicationDataH2ProvidedBodyRequestTurn(
                        bodyStringSession,
                        bodyStringAccepted,
                        app,
                        bodyStringRequestFragments,
                        bodyBytes: "accepted-appdata-body".toArray(),
                        maxFragmentLen: 8
                    )
                bodyStringClientChannel = Some(bodyStringRequestClientChannel)
                bodyStringReadyStatus = bodyStringTurn.readySnapshot.status
                bodyStringResponseStatus = bodyStringTurn.responseStatus
                bodyStringContentType =
                    bodyStringTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyStringTransferEncoding =
                    bodyStringTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyStringSocketWriteCount = bodyStringTurn.socketWriteCount
            } finally {
                if (!bodyStringAccepted.isClosed()) {
                    bodyStringAccepted.close()
                }
            }

            let bodyJsonAccepted = listener.accept()
            try {
                let bodyJsonHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1024)
                    )
                )
                let bodyJsonHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x1a)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-body-json".toArray()
                    )
                ])
                let bodyJsonTransport = ContractAcceptedTransportDescriptor(
                    "appdata-body-json-transport",
                    localEndpoint: bodyJsonAccepted.localAddress.toString(),
                    remoteEndpoint: bodyJsonAccepted.remoteAddress.toString()
                )
                let bodyJsonSession = option.attachJinguiAcceptedTransportTls13X25519(
                    bodyJsonTransport,
                    bodyJsonHello.encodedClientHello,
                    engineIncrementalBytes(32, start: 1056)
                )
                let bodyJsonRequestClientChannel =
                    contractTls13CreateClientRecordChannel(
                        bodyJsonSession.keyMaterial,
                        algorithm: bodyJsonSession.recordChannel.algorithm
                    )
                let bodyJsonRequestFragments =
                    bodyJsonRequestClientChannel.sealFragments(
                        ContractTlsRecordContentType.ApplicationData,
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                bodyJsonHeaderBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x5),
                            streamId: 59
                        ),
                        maxFragmentLen: 7
                    )
                let bodyJsonTurn =
                    option.serveJinguiAcceptedTransportSessionApplicationDataH2ProvidedBodyRequestTurn(
                        bodyJsonSession,
                        bodyJsonAccepted,
                        app,
                        bodyJsonRequestFragments,
                        bodyBytes: "{\"name\":\"ignite\",\"val\":23}".toArray(),
                        maxFragmentLen: 8
                    )
                bodyJsonClientChannel = Some(bodyJsonRequestClientChannel)
                bodyJsonReadyStatus = bodyJsonTurn.readySnapshot.status
                bodyJsonResponseStatus = bodyJsonTurn.responseStatus
                bodyJsonContentType =
                    bodyJsonTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyJsonTransferEncoding =
                    bodyJsonTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyJsonSocketWriteCount = bodyJsonTurn.socketWriteCount
            } finally {
                if (!bodyJsonAccepted.isClosed()) {
                    bodyJsonAccepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataProvidedBodyRequestTurnRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let clientHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1088)
                    )
                )
                let firstHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/one".toArray())
                ])
                let secondHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/two".toArray())
                ])
                let transport = ContractAcceptedTransportDescriptor(
                    "appdata-provided-body-reject-transport",
                    localEndpoint: accepted.localAddress.toString(),
                    remoteEndpoint: accepted.remoteAddress.toString()
                )
                let session = option.attachJinguiAcceptedTransportTls13X25519(
                    transport,
                    clientHello.encodedClientHello,
                    engineIncrementalBytes(32, start: 1120)
                )
                let requestClientChannel = contractTls13CreateClientRecordChannel(
                    session.keyMaterial,
                    algorithm: session.recordChannel.algorithm
                )
                let requestFragments = requestClientChannel.sealFragments(
                    ContractTlsRecordContentType.ApplicationData,
                    concatServerEngineAbstractionTestByteArrays([
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                firstHeaderBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x5),
                            streamId: 61
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                secondHeaderBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x5),
                            streamId: 63
                        )
                    ]),
                    maxFragmentLen: 7
                )
                try {
                    let _ =
                        option.serveJinguiAcceptedTransportSessionApplicationDataH2ProvidedBodyRequestTurn(
                            session,
                            accepted,
                            app,
                            requestFragments,
                            bodyBytes: "blocked".toArray(),
                            maxFragmentLen: 8
                        )
                    @Fail("expected multi-header-block provided-body turn rejection")
                } catch (e: Exception) {
                    observedError = e.message
                }
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketApplicationDataProvidedBodyRequestTurnProbeEngine <: ServerEngine {
    public var bodyStringReadyStatus: String = ""
    public var bodyJsonReadyStatus: String = ""
    public var bodyStringResponseStatus: UInt16 = 0
    public var bodyJsonResponseStatus: UInt16 = 0
    public var bodyStringContentType: String = ""
    public var bodyJsonContentType: String = ""
    public var bodyStringTransferEncoding: String = ""
    public var bodyJsonTransferEncoding: String = ""
    public var bodyStringSocketWriteCount: Int64 = 0
    public var bodyJsonSocketWriteCount: Int64 = 0
    var bodyStringClientChannel: ?ContractTlsRecordChannel = None
    var bodyJsonClientChannel: ?ContractTlsRecordChannel = None

    public func openBodyStringSocketWire(wire: Array<UInt8>): String {
        match (bodyStringClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected socket appdata bodyString companion client record channel before socket wire open"
                )
        }
    }

    public func openBodyJsonSocketWire(wire: Array<UInt8>): String {
        match (bodyJsonClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected socket appdata bodyJson companion client record channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let bodyStringAccepted = listener.accept()
            try {
                let bodyStringTransportId =
                    "socket-appdata-body-string-transport"
                let bodyStringHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 2752)
                    )
                )
                let bodyStringHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x1c)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-body-string".toArray()
                    )
                ])
                let bodyStringServerPrivate =
                    engineIncrementalBytes(32, start: 2784)
                let bodyStringTurn =
                    option.serveJinguiAcceptedTransportSocketApplicationDataH2ProvidedBodyRequestTurn(
                        bodyStringAccepted,
                        app,
                        { session =>
                            let bodyStringRequestClientChannel =
                                contractTls13CreateClientRecordChannel(
                                    session.keyMaterial,
                                    algorithm: session.recordChannel.algorithm
                                )
                            bodyStringClientChannel = Some(
                                bodyStringRequestClientChannel
                            )
                            bodyStringRequestClientChannel.sealFragments(
                                ContractTlsRecordContentType.ApplicationData,
                                buildServerEngineAbstractionTestH2FrameWire(
                                    buildServerEngineAbstractionTestH2HeadersPayload(
                                        bodyStringHeaderBlock
                                    ),
                                    frameType: UInt8(0x1),
                                    flags: UInt8(0x5),
                                    streamId: 131
                                ),
                                maxFragmentLen: 7
                            )
                        },
                        bodyStringHello.encodedClientHello,
                        bodyStringServerPrivate,
                        bodyBytes: "accepted-appdata-body".toArray(),
                        transportId: bodyStringTransportId,
                        maxFragmentLen: 8
                    )
                bodyStringReadyStatus = bodyStringTurn.readySnapshot.status
                bodyStringResponseStatus = bodyStringTurn.responseStatus
                bodyStringContentType =
                    bodyStringTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyStringTransferEncoding =
                    bodyStringTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyStringSocketWriteCount = bodyStringTurn.socketWriteCount
            } finally {
                if (!bodyStringAccepted.isClosed()) {
                    bodyStringAccepted.close()
                }
            }

            let bodyJsonAccepted = listener.accept()
            try {
                let bodyJsonTransportId =
                    "socket-appdata-body-json-transport"
                let bodyJsonHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 2816)
                    )
                )
                let bodyJsonHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x1a)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-body-json".toArray()
                    )
                ])
                let bodyJsonServerPrivate =
                    engineIncrementalBytes(32, start: 2848)
                let bodyJsonTurn =
                    option.serveJinguiAcceptedTransportSocketApplicationDataH2ProvidedBodyRequestTurn(
                        bodyJsonAccepted,
                        app,
                        { session =>
                            let bodyJsonRequestClientChannel =
                                contractTls13CreateClientRecordChannel(
                                    session.keyMaterial,
                                    algorithm: session.recordChannel.algorithm
                                )
                            bodyJsonClientChannel = Some(
                                bodyJsonRequestClientChannel
                            )
                            bodyJsonRequestClientChannel.sealFragments(
                                ContractTlsRecordContentType.ApplicationData,
                                buildServerEngineAbstractionTestH2FrameWire(
                                    buildServerEngineAbstractionTestH2HeadersPayload(
                                        bodyJsonHeaderBlock
                                    ),
                                    frameType: UInt8(0x1),
                                    flags: UInt8(0x5),
                                    streamId: 133
                                ),
                                maxFragmentLen: 7
                            )
                        },
                        bodyJsonHello.encodedClientHello,
                        bodyJsonServerPrivate,
                        bodyBytes: "{\"name\":\"ignite\",\"val\":23}".toArray(),
                        transportId: bodyJsonTransportId,
                        maxFragmentLen: 8
                    )
                bodyJsonReadyStatus = bodyJsonTurn.readySnapshot.status
                bodyJsonResponseStatus = bodyJsonTurn.responseStatus
                bodyJsonContentType =
                    bodyJsonTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyJsonTransferEncoding =
                    bodyJsonTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyJsonSocketWriteCount = bodyJsonTurn.socketWriteCount
            } finally {
                if (!bodyJsonAccepted.isClosed()) {
                    bodyJsonAccepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketApplicationDataProvidedBodyRequestTurnRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let clientHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 2880)
                    )
                )
                let firstHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/one".toArray())
                ])
                let secondHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/two".toArray())
                ])
                let transportId =
                    "socket-appdata-provided-body-reject-transport"
                let serverPrivate = engineIncrementalBytes(32, start: 2912)
                try {
                    let _ =
                        option.serveJinguiAcceptedTransportSocketApplicationDataH2ProvidedBodyRequestTurn(
                            accepted,
                            app,
                            { session =>
                                let requestClientChannel =
                                    contractTls13CreateClientRecordChannel(
                                        session.keyMaterial,
                                        algorithm: session.recordChannel.algorithm
                                    )
                                requestClientChannel.sealFragments(
                                    ContractTlsRecordContentType.ApplicationData,
                                    concatServerEngineAbstractionTestByteArrays([
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            buildServerEngineAbstractionTestH2HeadersPayload(
                                                firstHeaderBlock
                                            ),
                                            frameType: UInt8(0x1),
                                            flags: UInt8(0x5),
                                            streamId: 135
                                        ),
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            buildServerEngineAbstractionTestH2HeadersPayload(
                                                secondHeaderBlock
                                            ),
                                            frameType: UInt8(0x1),
                                            flags: UInt8(0x5),
                                            streamId: 137
                                        )
                                    ]),
                                    maxFragmentLen: 7
                                )
                            },
                            clientHello.encodedClientHello,
                            serverPrivate,
                            bodyBytes: "blocked".toArray(),
                            transportId: transportId,
                            maxFragmentLen: 8
                        )
                    @Fail("expected socket multi-header-block provided-body turn rejection")
                } catch (e: Exception) {
                    observedError = e.message
                }
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketApplicationDataFragmentedRecordWireProvidedBodyRequestTurnProbeEngine <: ServerEngine {
    public var bodyStringReadyStatus: String = ""
    public var bodyJsonReadyStatus: String = ""
    public var bodyStringResponseStatus: UInt16 = 0
    public var bodyJsonResponseStatus: UInt16 = 0
    public var bodyStringContentType: String = ""
    public var bodyJsonContentType: String = ""
    public var bodyStringTransferEncoding: String = ""
    public var bodyJsonTransferEncoding: String = ""
    public var bodyStringSocketWriteCount: Int64 = 0
    public var bodyJsonSocketWriteCount: Int64 = 0
    var bodyStringClientChannel: ?ContractTlsRecordChannel = None
    var bodyJsonClientChannel: ?ContractTlsRecordChannel = None

    public func openBodyStringSocketWire(wire: Array<UInt8>): String {
        match (bodyStringClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected socket fragmented appdata bodyString companion client record channel before socket wire open"
                )
        }
    }

    public func openBodyJsonSocketWire(wire: Array<UInt8>): String {
        match (bodyJsonClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected socket fragmented appdata bodyJson companion client record channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let bodyStringAccepted = listener.accept()
            try {
                let bodyStringTransportId =
                    "socket-fragmented-appdata-body-string-transport"
                let bodyStringHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1408)
                    )
                )
                let bodyStringHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x2e)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-socket-fragmented-appdata-body-string".toArray()
                    )
                ])
                let bodyStringServerPrivate =
                    engineIncrementalBytes(32, start: 1440)
                let bodyStringTurn =
                    option.serveJinguiAcceptedTransportSocketApplicationDataFragmentedRecordWireH2ProvidedBodyRequestTurn(
                        bodyStringAccepted,
                        app,
                        { session =>
                            let bodyStringRequestClientChannel =
                                contractTls13CreateClientRecordChannel(
                                    session.keyMaterial,
                                    algorithm: session.recordChannel.algorithm
                                )
                            bodyStringClientChannel = Some(
                                bodyStringRequestClientChannel
                            )
                            let bodyStringRequestRecords =
                                bodyStringRequestClientChannel.sealFragments(
                                    ContractTlsRecordContentType.ApplicationData,
                                    buildServerEngineAbstractionTestH2FrameWire(
                                        buildServerEngineAbstractionTestH2HeadersPayload(
                                            bodyStringHeaderBlock
                                        ),
                                        frameType: UInt8(0x1),
                                        flags: UInt8(0x5),
                                        streamId: 73
                                    ),
                                    maxFragmentLen: 7
                                )
                            let bodyStringEncodedWire =
                                concatServerEngineAbstractionTestByteArrays(
                                    bodyStringRequestRecords
                                )
                            [
                                cloneServerEngineByteWindow(
                                    bodyStringEncodedWire,
                                    0,
                                    4
                                ),
                                cloneServerEngineByteWindow(
                                    bodyStringEncodedWire,
                                    4,
                                    bodyStringEncodedWire.size - 7
                                ),
                                cloneServerEngineByteWindow(
                                    bodyStringEncodedWire,
                                    bodyStringEncodedWire.size - 3,
                                    3
                                )
                            ]
                        },
                        bodyStringHello.encodedClientHello,
                        bodyStringServerPrivate,
                        bodyBytes: "accepted-fragmented-appdata-body".toArray(),
                        transportId: bodyStringTransportId,
                        maxFragmentLen: 8
                    )
                bodyStringReadyStatus = bodyStringTurn.readySnapshot.status
                bodyStringResponseStatus = bodyStringTurn.responseStatus
                bodyStringContentType =
                    bodyStringTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyStringTransferEncoding =
                    bodyStringTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyStringSocketWriteCount = bodyStringTurn.socketWriteCount
            } finally {
                if (!bodyStringAccepted.isClosed()) {
                    bodyStringAccepted.close()
                }
            }

            let bodyJsonAccepted = listener.accept()
            try {
                let bodyJsonTransportId =
                    "socket-fragmented-appdata-body-json-transport"
                let bodyJsonHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1472)
                    )
                )
                let bodyJsonHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x2c)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-socket-fragmented-appdata-body-json".toArray()
                    )
                ])
                let bodyJsonServerPrivate =
                    engineIncrementalBytes(32, start: 1504)
                let bodyJsonTurn =
                    option.serveJinguiAcceptedTransportSocketApplicationDataFragmentedRecordWireH2ProvidedBodyRequestTurn(
                        bodyJsonAccepted,
                        app,
                        { session =>
                            let bodyJsonRequestClientChannel =
                                contractTls13CreateClientRecordChannel(
                                    session.keyMaterial,
                                    algorithm: session.recordChannel.algorithm
                                )
                            bodyJsonClientChannel = Some(
                                bodyJsonRequestClientChannel
                            )
                            let bodyJsonRequestRecords =
                                bodyJsonRequestClientChannel.sealFragments(
                                    ContractTlsRecordContentType.ApplicationData,
                                    buildServerEngineAbstractionTestH2FrameWire(
                                        buildServerEngineAbstractionTestH2HeadersPayload(
                                            bodyJsonHeaderBlock
                                        ),
                                        frameType: UInt8(0x1),
                                        flags: UInt8(0x5),
                                        streamId: 75
                                    ),
                                    maxFragmentLen: 7
                                )
                            let bodyJsonEncodedWire =
                                concatServerEngineAbstractionTestByteArrays(
                                    bodyJsonRequestRecords
                                )
                            [
                                cloneServerEngineByteWindow(
                                    bodyJsonEncodedWire,
                                    0,
                                    4
                                ),
                                cloneServerEngineByteWindow(
                                    bodyJsonEncodedWire,
                                    4,
                                    bodyJsonEncodedWire.size - 7
                                ),
                                cloneServerEngineByteWindow(
                                    bodyJsonEncodedWire,
                                    bodyJsonEncodedWire.size - 3,
                                    3
                                )
                            ]
                        },
                        bodyJsonHello.encodedClientHello,
                        bodyJsonServerPrivate,
                        bodyBytes: "{\"name\":\"ignite\",\"val\":64}".toArray(),
                        transportId: bodyJsonTransportId,
                        maxFragmentLen: 8
                    )
                bodyJsonReadyStatus = bodyJsonTurn.readySnapshot.status
                bodyJsonResponseStatus = bodyJsonTurn.responseStatus
                bodyJsonContentType =
                    bodyJsonTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyJsonTransferEncoding =
                    bodyJsonTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyJsonSocketWriteCount = bodyJsonTurn.socketWriteCount
            } finally {
                if (!bodyJsonAccepted.isClosed()) {
                    bodyJsonAccepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketApplicationDataFragmentedRecordWireProvidedBodyRequestTurnRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let clientHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1536)
                    )
                )
                let firstHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/one".toArray())
                ])
                let secondHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/two".toArray())
                ])
                let transportId =
                    "socket-fragmented-appdata-provided-body-reject-transport"
                let serverPrivate = engineIncrementalBytes(32, start: 1568)
                try {
                    let _ =
                        option.serveJinguiAcceptedTransportSocketApplicationDataFragmentedRecordWireH2ProvidedBodyRequestTurn(
                            accepted,
                            app,
                            { session =>
                                let requestClientChannel =
                                    contractTls13CreateClientRecordChannel(
                                        session.keyMaterial,
                                        algorithm: session.recordChannel.algorithm
                                    )
                                let requestRecords =
                                    requestClientChannel.sealFragments(
                                        ContractTlsRecordContentType.ApplicationData,
                                        concatServerEngineAbstractionTestByteArrays([
                                            buildServerEngineAbstractionTestH2FrameWire(
                                                buildServerEngineAbstractionTestH2HeadersPayload(
                                                    firstHeaderBlock
                                                ),
                                                frameType: UInt8(0x1),
                                                flags: UInt8(0x5),
                                                streamId: 77
                                            ),
                                            buildServerEngineAbstractionTestH2FrameWire(
                                                buildServerEngineAbstractionTestH2HeadersPayload(
                                                    secondHeaderBlock
                                                ),
                                                frameType: UInt8(0x1),
                                                flags: UInt8(0x5),
                                                streamId: 79
                                            )
                                        ]),
                                        maxFragmentLen: 7
                                    )
                                let encodedWire =
                                    concatServerEngineAbstractionTestByteArrays(
                                        requestRecords
                                    )
                                [
                                    cloneServerEngineByteWindow(
                                        encodedWire,
                                        0,
                                        4
                                    ),
                                    cloneServerEngineByteWindow(
                                        encodedWire,
                                        4,
                                        encodedWire.size - 7
                                    ),
                                    cloneServerEngineByteWindow(
                                        encodedWire,
                                        encodedWire.size - 3,
                                        3
                                    )
                                ]
                            },
                            clientHello.encodedClientHello,
                            serverPrivate,
                            bodyBytes: "blocked".toArray(),
                            transportId: transportId,
                            maxFragmentLen: 8
                        )
                    @Fail(
                        "expected socket fragmented-record-wire provided-body turn rejection"
                    )
                } catch (e: Exception) {
                    observedError = e.message
                }
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataHeadersPlusDataLogicalRequestProbeEngine <: ServerEngine {
    public var bodyStringReadyStatus: String = ""
    public var bodyJsonReadyStatus: String = ""
    public var bodyStringResponseStatus: UInt16 = 0
    public var bodyJsonResponseStatus: UInt16 = 0
    public var bodyStringContentType: String = ""
    public var bodyJsonContentType: String = ""
    public var bodyStringTransferEncoding: String = ""
    public var bodyJsonTransferEncoding: String = ""
    public var bodyStringSocketWriteCount: Int64 = 0
    public var bodyJsonSocketWriteCount: Int64 = 0
    var bodyStringClientChannel: ?ContractTlsRecordChannel = None
    var bodyJsonClientChannel: ?ContractTlsRecordChannel = None

    public func openBodyStringSocketWire(wire: Array<UInt8>): String {
        match (bodyStringClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected headers-plus-data bodyString companion client record channel before socket wire open"
                )
        }
    }

    public func openBodyJsonSocketWire(wire: Array<UInt8>): String {
        match (bodyJsonClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected headers-plus-data bodyJson companion client record channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let bodyStringAccepted = listener.accept()
            try {
                let bodyStringBuildHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1152)
                    )
                )
                let bodyStringBuildSession =
                    option.attachJinguiAcceptedTransportTls13X25519(
                        ContractAcceptedTransportDescriptor(
                            "appdata-headers-plus-data-body-string-build-transport",
                            localEndpoint: "127.0.0.1:443",
                            remoteEndpoint: "127.0.0.1:55449"
                        ),
                        bodyStringBuildHello.encodedClientHello,
                        engineIncrementalBytes(32, start: 1184)
                    )
                let bodyStringBuildClientChannel =
                    contractTls13CreateClientRecordChannel(
                        bodyStringBuildSession.keyMaterial,
                        algorithm: bodyStringBuildSession.recordChannel.algorithm
                    )
                let bodyStringHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x21)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-data-body-string".toArray()
                    )
                ])
                let bodyStringRequest =
                    option.openAndBuildJinguiAcceptedTransportLogicalRequestFromApplicationDataH2HeadersPlusData(
                        bodyStringBuildSession,
                        bodyStringBuildClientChannel.sealFragments(
                            ContractTlsRecordContentType.ApplicationData,
                            concatServerEngineAbstractionTestByteArrays([
                                buildServerEngineAbstractionTestH2FrameWire(
                                    buildServerEngineAbstractionTestH2HeadersPayload(
                                        bodyStringHeaderBlock
                                    ),
                                    frameType: UInt8(0x1),
                                    flags: UInt8(0x4),
                                    streamId: 65
                                ),
                                buildServerEngineAbstractionTestH2FrameWire(
                                    serverEngineAbstractionTestByteArray(
                                        "accepted-".toArray()
                                    ),
                                    frameType: UInt8(0x0),
                                    flags: UInt8(0x0),
                                    streamId: 65
                                ),
                                buildServerEngineAbstractionTestH2FrameWire(
                                    serverEngineAbstractionTestByteArray(
                                        "appdata-body".toArray()
                                    ),
                                    frameType: UInt8(0x0),
                                    flags: UInt8(0x1),
                                    streamId: 65
                                )
                            ]),
                            maxFragmentLen: 7
                        )
                    )
                let bodyStringResponseHello =
                    contractTls13BuildHttpClientHelloX25519(
                        "www.example.com",
                        alpnProtocols: ["h2", "http/1.1"],
                        clientPrivateKey: Some(
                            engineIncrementalBytes(32, start: 1216)
                        )
                    )
                let bodyStringTurn =
                    option.serveJinguiAcceptedTransportSocketLogicalRequest(
                        bodyStringAccepted,
                        app,
                        bodyStringRequest,
                        bodyStringResponseHello.encodedClientHello,
                        engineIncrementalBytes(32, start: 1248),
                        transportId: "appdata-headers-plus-data-body-string-transport",
                        maxFragmentLen: 8
                    )
                bodyStringClientChannel = Some(
                    contractTls13CreateClientRecordChannel(
                        bodyStringTurn.session.keyMaterial,
                        algorithm: bodyStringTurn.session.recordChannel.algorithm
                    )
                )
                bodyStringReadyStatus = bodyStringTurn.readySnapshot.status
                bodyStringResponseStatus = bodyStringTurn.responseStatus
                bodyStringContentType =
                    bodyStringTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyStringTransferEncoding =
                    bodyStringTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyStringSocketWriteCount =
                    bodyStringTurn.socketWriteCount
            } finally {
                if (!bodyStringAccepted.isClosed()) {
                    bodyStringAccepted.close()
                }
            }

            let bodyJsonAccepted = listener.accept()
            try {
                let bodyJsonBuildHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1280)
                    )
                )
                let bodyJsonBuildSession =
                    option.attachJinguiAcceptedTransportTls13X25519(
                        ContractAcceptedTransportDescriptor(
                            "appdata-headers-plus-data-body-json-build-transport",
                            localEndpoint: "127.0.0.1:443",
                            remoteEndpoint: "127.0.0.1:55450"
                        ),
                        bodyJsonBuildHello.encodedClientHello,
                        engineIncrementalBytes(32, start: 1312)
                    )
                let bodyJsonBuildClientChannel =
                    contractTls13CreateClientRecordChannel(
                        bodyJsonBuildSession.keyMaterial,
                        algorithm: bodyJsonBuildSession.recordChannel.algorithm
                    )
                let bodyJsonHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x1f)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-data-body-json".toArray()
                    )
                ])
                let bodyJsonRequest =
                    option.openAndBuildJinguiAcceptedTransportLogicalRequestFromApplicationDataH2HeadersPlusData(
                        bodyJsonBuildSession,
                        bodyJsonBuildClientChannel.sealFragments(
                            ContractTlsRecordContentType.ApplicationData,
                            concatServerEngineAbstractionTestByteArrays([
                                buildServerEngineAbstractionTestH2FrameWire(
                                    buildServerEngineAbstractionTestH2HeadersPayload(
                                        bodyJsonHeaderBlock
                                    ),
                                    frameType: UInt8(0x1),
                                    flags: UInt8(0x4),
                                    streamId: 67
                                ),
                                buildServerEngineAbstractionTestH2FrameWire(
                                    serverEngineAbstractionTestByteArray(
                                        "{\"name\":\"ignite\",".toArray()
                                    ),
                                    frameType: UInt8(0x0),
                                    flags: UInt8(0x0),
                                    streamId: 67
                                ),
                                buildServerEngineAbstractionTestH2FrameWire(
                                    serverEngineAbstractionTestByteArray(
                                        "\"val\":23}".toArray()
                                    ),
                                    frameType: UInt8(0x0),
                                    flags: UInt8(0x1),
                                    streamId: 67
                                )
                            ]),
                            maxFragmentLen: 7
                        )
                    )
                let bodyJsonResponseHello =
                    contractTls13BuildHttpClientHelloX25519(
                        "www.example.com",
                        alpnProtocols: ["h2", "http/1.1"],
                        clientPrivateKey: Some(
                            engineIncrementalBytes(32, start: 1344)
                        )
                    )
                let bodyJsonTurn =
                    option.serveJinguiAcceptedTransportSocketLogicalRequest(
                        bodyJsonAccepted,
                        app,
                        bodyJsonRequest,
                        bodyJsonResponseHello.encodedClientHello,
                        engineIncrementalBytes(32, start: 1376),
                        transportId: "appdata-headers-plus-data-body-json-transport",
                        maxFragmentLen: 8
                    )
                bodyJsonClientChannel = Some(
                    contractTls13CreateClientRecordChannel(
                        bodyJsonTurn.session.keyMaterial,
                        algorithm: bodyJsonTurn.session.recordChannel.algorithm
                    )
                )
                bodyJsonReadyStatus = bodyJsonTurn.readySnapshot.status
                bodyJsonResponseStatus = bodyJsonTurn.responseStatus
                bodyJsonContentType =
                    bodyJsonTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyJsonTransferEncoding =
                    bodyJsonTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyJsonSocketWriteCount =
                    bodyJsonTurn.socketWriteCount
            } finally {
                if (!bodyJsonAccepted.isClosed()) {
                    bodyJsonAccepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataHeadersPlusDataLogicalRequestRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let buildHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1408)
                    )
                )
                let buildSession =
                    option.attachJinguiAcceptedTransportTls13X25519(
                        ContractAcceptedTransportDescriptor(
                            "appdata-headers-plus-data-reject-build-transport",
                            localEndpoint: "127.0.0.1:443",
                            remoteEndpoint: "127.0.0.1:55451"
                        ),
                        buildHello.encodedClientHello,
                        engineIncrementalBytes(32, start: 1440)
                    )
                let buildClientChannel =
                    contractTls13CreateClientRecordChannel(
                        buildSession.keyMaterial,
                        algorithm: buildSession.recordChannel.algorithm
                    )
                let headerBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/one".toArray())
                ])
                try {
                    let _ =
                        option.openAndBuildJinguiAcceptedTransportLogicalRequestFromApplicationDataH2HeadersPlusData(
                            buildSession,
                            buildClientChannel.sealFragments(
                                ContractTlsRecordContentType.ApplicationData,
                                concatServerEngineAbstractionTestByteArrays([
                                    buildServerEngineAbstractionTestH2FrameWire(
                                        buildServerEngineAbstractionTestH2HeadersPayload(
                                            headerBlock
                                        ),
                                        frameType: UInt8(0x1),
                                        flags: UInt8(0x4),
                                        streamId: 69
                                    ),
                                    buildServerEngineAbstractionTestH2FrameWire(
                                        serverEngineAbstractionTestByteArray(
                                            "blocked".toArray()
                                        ),
                                        frameType: UInt8(0x0),
                                        flags: UInt8(0x1),
                                        streamId: 71
                                    )
                                ]),
                                maxFragmentLen: 7
                            )
                        )
                    @Fail("expected wrong-stream DATA rejection")
                } catch (e: Exception) {
                    observedError = e.message
                }
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataFragmentedRecordWireHeadersPlusDataRequestTurnProbeEngine <: ServerEngine {
    public var bodyStringReadyStatus: String = ""
    public var bodyJsonReadyStatus: String = ""
    public var bodyStringResponseStatus: UInt16 = 0
    public var bodyJsonResponseStatus: UInt16 = 0
    public var bodyStringContentType: String = ""
    public var bodyJsonContentType: String = ""
    public var bodyStringTransferEncoding: String = ""
    public var bodyJsonTransferEncoding: String = ""
    public var bodyStringSocketWriteCount: Int64 = 0
    public var bodyJsonSocketWriteCount: Int64 = 0
    var bodyStringClientChannel: ?ContractTlsRecordChannel = None
    var bodyJsonClientChannel: ?ContractTlsRecordChannel = None

    public func openBodyStringSocketWire(wire: Array<UInt8>): String {
        match (bodyStringClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected fragmented headers-plus-data request-turn bodyString companion client record channel before socket wire open"
                )
        }
    }

    public func openBodyJsonSocketWire(wire: Array<UInt8>): String {
        match (bodyJsonClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected fragmented headers-plus-data request-turn bodyJson companion client record channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let bodyStringAccepted = listener.accept()
            try {
                let bodyStringHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1664)
                    )
                )
                let bodyStringHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x26)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-data-turn-body-string".toArray()
                    )
                ])
                let bodyStringTransport = ContractAcceptedTransportDescriptor(
                    "fragmented-appdata-data-turn-body-string-transport",
                    localEndpoint: bodyStringAccepted.localAddress.toString(),
                    remoteEndpoint: bodyStringAccepted.remoteAddress.toString()
                )
                let bodyStringSession = option.attachJinguiAcceptedTransportTls13X25519(
                    bodyStringTransport,
                    bodyStringHello.encodedClientHello,
                    engineIncrementalBytes(32, start: 1696)
                )
                let bodyStringRequestClientChannel =
                    contractTls13CreateClientRecordChannel(
                        bodyStringSession.keyMaterial,
                        algorithm: bodyStringSession.recordChannel.algorithm
                    )
                let bodyStringRequestRecords =
                    bodyStringRequestClientChannel.sealFragments(
                        ContractTlsRecordContentType.ApplicationData,
                        concatServerEngineAbstractionTestByteArrays([
                            buildServerEngineAbstractionTestH2FrameWire(
                                buildServerEngineAbstractionTestH2HeadersPayload(
                                    bodyStringHeaderBlock
                                ),
                                frameType: UInt8(0x1),
                                flags: UInt8(0x4),
                                streamId: 81
                            ),
                            buildServerEngineAbstractionTestH2FrameWire(
                                serverEngineAbstractionTestByteArray(
                                    "accepted-".toArray()
                                ),
                                frameType: UInt8(0x0),
                                flags: UInt8(0x0),
                                streamId: 81
                            ),
                            buildServerEngineAbstractionTestH2FrameWire(
                                serverEngineAbstractionTestByteArray(
                                    "appdata-body".toArray()
                                ),
                                frameType: UInt8(0x0),
                                flags: UInt8(0x1),
                                streamId: 81
                            )
                        ]),
                        maxFragmentLen: 7
                    )
                let bodyStringEncodedWire =
                    concatServerEngineAbstractionTestByteArrays(
                        bodyStringRequestRecords
                    )
                let bodyStringTurn =
                    option.serveJinguiAcceptedTransportSessionApplicationDataFragmentedRecordWireH2HeadersPlusDataRequestTurn(
                        bodyStringSession,
                        bodyStringAccepted,
                        app,
                        [
                            cloneServerEngineByteWindow(
                                bodyStringEncodedWire,
                                0,
                                4
                            ),
                            cloneServerEngineByteWindow(
                                bodyStringEncodedWire,
                                4,
                                bodyStringEncodedWire.size - 7
                            ),
                            cloneServerEngineByteWindow(
                                bodyStringEncodedWire,
                                bodyStringEncodedWire.size - 3,
                                3
                            )
                        ],
                        maxFragmentLen: 8
                    )
                bodyStringClientChannel = Some(bodyStringRequestClientChannel)
                bodyStringReadyStatus = bodyStringTurn.readySnapshot.status
                bodyStringResponseStatus = bodyStringTurn.responseStatus
                bodyStringContentType =
                    bodyStringTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyStringTransferEncoding =
                    bodyStringTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyStringSocketWriteCount = bodyStringTurn.socketWriteCount
            } finally {
                if (!bodyStringAccepted.isClosed()) {
                    bodyStringAccepted.close()
                }
            }

            let bodyJsonAccepted = listener.accept()
            try {
                let bodyJsonHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1728)
                    )
                )
                let bodyJsonHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x24)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-data-turn-body-json".toArray()
                    )
                ])
                let bodyJsonTransport = ContractAcceptedTransportDescriptor(
                    "fragmented-appdata-data-turn-body-json-transport",
                    localEndpoint: bodyJsonAccepted.localAddress.toString(),
                    remoteEndpoint: bodyJsonAccepted.remoteAddress.toString()
                )
                let bodyJsonSession = option.attachJinguiAcceptedTransportTls13X25519(
                    bodyJsonTransport,
                    bodyJsonHello.encodedClientHello,
                    engineIncrementalBytes(32, start: 1760)
                )
                let bodyJsonRequestClientChannel =
                    contractTls13CreateClientRecordChannel(
                        bodyJsonSession.keyMaterial,
                        algorithm: bodyJsonSession.recordChannel.algorithm
                    )
                let bodyJsonRequestRecords =
                    bodyJsonRequestClientChannel.sealFragments(
                        ContractTlsRecordContentType.ApplicationData,
                        concatServerEngineAbstractionTestByteArrays([
                            buildServerEngineAbstractionTestH2FrameWire(
                                buildServerEngineAbstractionTestH2HeadersPayload(
                                    bodyJsonHeaderBlock
                                ),
                                frameType: UInt8(0x1),
                                flags: UInt8(0x4),
                                streamId: 83
                            ),
                            buildServerEngineAbstractionTestH2FrameWire(
                                serverEngineAbstractionTestByteArray(
                                    "{\"name\":\"ignite\",".toArray()
                                ),
                                frameType: UInt8(0x0),
                                flags: UInt8(0x0),
                                streamId: 83
                            ),
                            buildServerEngineAbstractionTestH2FrameWire(
                                serverEngineAbstractionTestByteArray(
                                    "\"val\":23}".toArray()
                                ),
                                frameType: UInt8(0x0),
                                flags: UInt8(0x1),
                                streamId: 83
                            )
                        ]),
                        maxFragmentLen: 7
                    )
                let bodyJsonEncodedWire =
                    concatServerEngineAbstractionTestByteArrays(
                        bodyJsonRequestRecords
                    )
                let bodyJsonTurn =
                    option.serveJinguiAcceptedTransportSessionApplicationDataFragmentedRecordWireH2HeadersPlusDataRequestTurn(
                        bodyJsonSession,
                        bodyJsonAccepted,
                        app,
                        [
                            cloneServerEngineByteWindow(
                                bodyJsonEncodedWire,
                                0,
                                4
                            ),
                            cloneServerEngineByteWindow(
                                bodyJsonEncodedWire,
                                4,
                                bodyJsonEncodedWire.size - 7
                            ),
                            cloneServerEngineByteWindow(
                                bodyJsonEncodedWire,
                                bodyJsonEncodedWire.size - 3,
                                3
                            )
                        ],
                        maxFragmentLen: 8
                    )
                bodyJsonClientChannel = Some(bodyJsonRequestClientChannel)
                bodyJsonReadyStatus = bodyJsonTurn.readySnapshot.status
                bodyJsonResponseStatus = bodyJsonTurn.responseStatus
                bodyJsonContentType =
                    bodyJsonTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyJsonTransferEncoding =
                    bodyJsonTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyJsonSocketWriteCount = bodyJsonTurn.socketWriteCount
            } finally {
                if (!bodyJsonAccepted.isClosed()) {
                    bodyJsonAccepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataFragmentedRecordWireHeadersPlusDataRequestTurnRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let clientHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1792)
                    )
                )
                let headerBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/one".toArray())
                ])
                let transport = ContractAcceptedTransportDescriptor(
                    "fragmented-appdata-data-turn-reject-transport",
                    localEndpoint: accepted.localAddress.toString(),
                    remoteEndpoint: accepted.remoteAddress.toString()
                )
                let session = option.attachJinguiAcceptedTransportTls13X25519(
                    transport,
                    clientHello.encodedClientHello,
                    engineIncrementalBytes(32, start: 1824)
                )
                let requestClientChannel = contractTls13CreateClientRecordChannel(
                    session.keyMaterial,
                    algorithm: session.recordChannel.algorithm
                )
                let requestRecords = requestClientChannel.sealFragments(
                    ContractTlsRecordContentType.ApplicationData,
                    concatServerEngineAbstractionTestByteArrays([
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                headerBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x4),
                            streamId: 85
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            serverEngineAbstractionTestByteArray(
                                "blocked".toArray()
                            ),
                            frameType: UInt8(0x0),
                            flags: UInt8(0x1),
                            streamId: 87
                        )
                    ]),
                    maxFragmentLen: 7
                )
                let encodedWire =
                    concatServerEngineAbstractionTestByteArrays(requestRecords)
                try {
                    let _ =
                        option.serveJinguiAcceptedTransportSessionApplicationDataFragmentedRecordWireH2HeadersPlusDataRequestTurn(
                            session,
                            accepted,
                            app,
                            [
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    0,
                                    4
                                ),
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    4,
                                    encodedWire.size - 7
                                ),
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    encodedWire.size - 3,
                                    3
                                )
                            ],
                            maxFragmentLen: 8
                        )
                    @Fail(
                        "expected fragmented-record-wire headers-plus-data request-turn rejection"
                    )
                } catch (e: Exception) {
                    observedError = e.message
                }
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportAcceptedSocketApplicationDataFragmentedRecordWireHeadersPlusDataRequestTurnProbeEngine <: ServerEngine {
    public var bodyStringReadyStatus: String = ""
    public var bodyJsonReadyStatus: String = ""
    public var bodyStringResponseStatus: UInt16 = 0
    public var bodyJsonResponseStatus: UInt16 = 0
    public var bodyStringContentType: String = ""
    public var bodyJsonContentType: String = ""
    public var bodyStringTransferEncoding: String = ""
    public var bodyJsonTransferEncoding: String = ""
    public var bodyStringSocketWriteCount: Int64 = 0
    public var bodyJsonSocketWriteCount: Int64 = 0
    public var bodyStringRequestWireFragments: ?Array<Array<Byte>> = None
    public var bodyJsonRequestWireFragments: ?Array<Array<Byte>> = None
    var bodyStringClientChannel: ?ContractTlsRecordChannel = None
    var bodyJsonClientChannel: ?ContractTlsRecordChannel = None

    public func openBodyStringSocketWire(wire: Array<UInt8>): String {
        match (bodyStringClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected accepted-socket fragmented headers-plus-data request-turn bodyString companion client record channel before socket wire open"
                )
        }
    }

    public func openBodyJsonSocketWire(wire: Array<UInt8>): String {
        match (bodyJsonClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected accepted-socket fragmented headers-plus-data request-turn bodyJson companion client record channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let bodyStringAccepted = listener.accept()
            try {
                let bodyStringHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1856)
                    )
                )
                let bodyStringHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x26)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-data-turn-body-string".toArray()
                    )
                ])
                let bodyStringTransport = ContractAcceptedTransportDescriptor(
                    "accepted-socket-fragmented-appdata-data-turn-body-string-transport",
                    localEndpoint: bodyStringAccepted.localAddress.toString(),
                    remoteEndpoint: bodyStringAccepted.remoteAddress.toString()
                )
                let bodyStringSession = option.attachJinguiAcceptedTransportTls13X25519(
                    bodyStringTransport,
                    bodyStringHello.encodedClientHello,
                    engineIncrementalBytes(32, start: 1888)
                )
                let bodyStringRequestClientChannel =
                    contractTls13CreateClientRecordChannel(
                        bodyStringSession.keyMaterial,
                        algorithm: bodyStringSession.recordChannel.algorithm
                    )
                let bodyStringRequestRecords =
                    bodyStringRequestClientChannel.sealFragments(
                        ContractTlsRecordContentType.ApplicationData,
                        concatServerEngineAbstractionTestByteArrays([
                            buildServerEngineAbstractionTestH2FrameWire(
                                buildServerEngineAbstractionTestH2HeadersPayload(
                                    bodyStringHeaderBlock
                                ),
                                frameType: UInt8(0x1),
                                flags: UInt8(0x4),
                                streamId: 89
                            ),
                            buildServerEngineAbstractionTestH2FrameWire(
                                serverEngineAbstractionTestByteArray(
                                    "accepted-".toArray()
                                ),
                                frameType: UInt8(0x0),
                                flags: UInt8(0x0),
                                streamId: 89
                            ),
                            buildServerEngineAbstractionTestH2FrameWire(
                                serverEngineAbstractionTestByteArray(
                                    "appdata-body".toArray()
                                ),
                                frameType: UInt8(0x0),
                                flags: UInt8(0x1),
                                streamId: 89
                            )
                        ]),
                        maxFragmentLen: 7
                    )
                let bodyStringEncodedWire =
                    concatServerEngineAbstractionTestByteArrays(
                        bodyStringRequestRecords
                    )
                bodyStringRequestWireFragments = Some([
                    cloneServerEngineByteWindow(
                        bodyStringEncodedWire,
                        0,
                        4
                    ),
                    cloneServerEngineByteWindow(
                        bodyStringEncodedWire,
                        4,
                        bodyStringEncodedWire.size - 7
                    ),
                    cloneServerEngineByteWindow(
                        bodyStringEncodedWire,
                        bodyStringEncodedWire.size - 3,
                        3
                    )
                ])
                let bodyStringTurn =
                    option.serveJinguiAcceptedTransportSessionAcceptedSocketApplicationDataFragmentedRecordWireH2HeadersPlusDataRequestTurn(
                        bodyStringSession,
                        bodyStringAccepted,
                        app,
                        readChunkSize: 5,
                        maxFragmentLen: 8
                    )
                bodyStringClientChannel = Some(bodyStringRequestClientChannel)
                bodyStringReadyStatus = bodyStringTurn.readySnapshot.status
                bodyStringResponseStatus = bodyStringTurn.responseStatus
                bodyStringContentType =
                    bodyStringTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyStringTransferEncoding =
                    bodyStringTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyStringSocketWriteCount = bodyStringTurn.socketWriteCount
            } finally {
                if (!bodyStringAccepted.isClosed()) {
                    bodyStringAccepted.close()
                }
            }

            let bodyJsonAccepted = listener.accept()
            try {
                let bodyJsonHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1920)
                    )
                )
                let bodyJsonHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x24)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-data-turn-body-json".toArray()
                    )
                ])
                let bodyJsonTransport = ContractAcceptedTransportDescriptor(
                    "accepted-socket-fragmented-appdata-data-turn-body-json-transport",
                    localEndpoint: bodyJsonAccepted.localAddress.toString(),
                    remoteEndpoint: bodyJsonAccepted.remoteAddress.toString()
                )
                let bodyJsonSession = option.attachJinguiAcceptedTransportTls13X25519(
                    bodyJsonTransport,
                    bodyJsonHello.encodedClientHello,
                    engineIncrementalBytes(32, start: 1952)
                )
                let bodyJsonRequestClientChannel =
                    contractTls13CreateClientRecordChannel(
                        bodyJsonSession.keyMaterial,
                        algorithm: bodyJsonSession.recordChannel.algorithm
                    )
                let bodyJsonRequestRecords =
                    bodyJsonRequestClientChannel.sealFragments(
                        ContractTlsRecordContentType.ApplicationData,
                        concatServerEngineAbstractionTestByteArrays([
                            buildServerEngineAbstractionTestH2FrameWire(
                                buildServerEngineAbstractionTestH2HeadersPayload(
                                    bodyJsonHeaderBlock
                                ),
                                frameType: UInt8(0x1),
                                flags: UInt8(0x4),
                                streamId: 91
                            ),
                            buildServerEngineAbstractionTestH2FrameWire(
                                serverEngineAbstractionTestByteArray(
                                    "{\"name\":\"ignite\",".toArray()
                                ),
                                frameType: UInt8(0x0),
                                flags: UInt8(0x0),
                                streamId: 91
                            ),
                            buildServerEngineAbstractionTestH2FrameWire(
                                serverEngineAbstractionTestByteArray(
                                    "\"val\":23}".toArray()
                                ),
                                frameType: UInt8(0x0),
                                flags: UInt8(0x1),
                                streamId: 91
                            )
                        ]),
                        maxFragmentLen: 7
                    )
                let bodyJsonEncodedWire =
                    concatServerEngineAbstractionTestByteArrays(
                        bodyJsonRequestRecords
                    )
                bodyJsonRequestWireFragments = Some([
                    cloneServerEngineByteWindow(
                        bodyJsonEncodedWire,
                        0,
                        4
                    ),
                    cloneServerEngineByteWindow(
                        bodyJsonEncodedWire,
                        4,
                        bodyJsonEncodedWire.size - 7
                    ),
                    cloneServerEngineByteWindow(
                        bodyJsonEncodedWire,
                        bodyJsonEncodedWire.size - 3,
                        3
                    )
                ])
                let bodyJsonTurn =
                    option.serveJinguiAcceptedTransportSessionAcceptedSocketApplicationDataFragmentedRecordWireH2HeadersPlusDataRequestTurn(
                        bodyJsonSession,
                        bodyJsonAccepted,
                        app,
                        readChunkSize: 5,
                        maxFragmentLen: 8
                    )
                bodyJsonClientChannel = Some(bodyJsonRequestClientChannel)
                bodyJsonReadyStatus = bodyJsonTurn.readySnapshot.status
                bodyJsonResponseStatus = bodyJsonTurn.responseStatus
                bodyJsonContentType =
                    bodyJsonTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyJsonTransferEncoding =
                    bodyJsonTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyJsonSocketWriteCount = bodyJsonTurn.socketWriteCount
            } finally {
                if (!bodyJsonAccepted.isClosed()) {
                    bodyJsonAccepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportAcceptedSocketApplicationDataFragmentedRecordWireTrailingHeadersRequestTurnProbeEngine <: ServerEngine {
    public var readyStatus: String = ""
    public var responseStatus: UInt16 = 0
    public var responseTrailerHeader: String = ""
    public var contentType: String = ""
    public var transferEncoding: String = ""
    public var socketWriteCount: Int64 = 0
    public var requestWireFragments: ?Array<Array<Byte>> = None
    let splitTrailingHeaderBlock: Bool
    var clientChannel: ?ContractTlsRecordChannel = None

    public init(splitTrailingHeaderBlock!: Bool = false) {
        this.splitTrailingHeaderBlock = splitTrailingHeaderBlock
    }

    public func openSocketWire(wire: Array<UInt8>): String {
        match (clientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected accepted-socket trailing HEADERS request-turn companion client record channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let clientHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 2240)
                    )
                )
                let headerBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x09)]),
                    serverEngineAbstractionTestByteArray("/trailers".toArray())
                ])
                let trailerBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x10), UInt8(0x11)]),
                    serverEngineAbstractionTestByteArray("x-request-trailer".toArray()),
                    serverEngineAbstractionTestByteArray([UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("tail".toArray())
                ])
                let transport = ContractAcceptedTransportDescriptor(
                    "accepted-socket-fragmented-appdata-trailers-turn-transport",
                    localEndpoint: accepted.localAddress.toString(),
                    remoteEndpoint: accepted.remoteAddress.toString()
                )
                let session = option.attachJinguiAcceptedTransportTls13X25519(
                    transport,
                    clientHello.encodedClientHello,
                    engineIncrementalBytes(32, start: 2272)
                )
                let requestClientChannel =
                    contractTls13CreateClientRecordChannel(
                        session.keyMaterial,
                        algorithm: session.recordChannel.algorithm
                    )
                let requestRecords =
                    requestClientChannel.sealFragments(
                        ContractTlsRecordContentType.ApplicationData,
                        buildAcceptedTransportTrailingHeadersRequestTurnWire(
                            headerBlock,
                            trailerBlock,
                            splitTrailingHeaderBlock
                        ),
                        maxFragmentLen: 7
                    )
                let encodedWire =
                    concatServerEngineAbstractionTestByteArrays(requestRecords)
                requestWireFragments = Some([
                    cloneServerEngineByteWindow(
                        encodedWire,
                        0,
                        4
                    ),
                    cloneServerEngineByteWindow(
                        encodedWire,
                        4,
                        encodedWire.size - 7
                    ),
                    cloneServerEngineByteWindow(
                        encodedWire,
                        encodedWire.size - 3,
                        3
                    )
                ])
                let turn =
                    option.serveJinguiAcceptedTransportSessionAcceptedSocketApplicationDataFragmentedRecordWireH2HeadersPlusDataRequestTurn(
                        session,
                        accepted,
                        app,
                        readChunkSize: 5,
                        maxFragmentLen: 8
                    )
                clientChannel = Some(requestClientChannel)
                readyStatus = turn.readySnapshot.status
                responseStatus = turn.responseStatus
                responseTrailerHeader =
                    turn.responseHeaders.getFirst("x-accepted-socket-trailer") ?? ""
                contentType =
                    turn.responseHeaders.getFirst("content-type") ?? ""
                transferEncoding =
                    turn.responseHeaders.getFirst("transfer-encoding") ?? ""
                socketWriteCount = turn.socketWriteCount
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}

    func buildAcceptedTransportTrailingHeadersRequestTurnWire(
        headerBlock: Array<Byte>,
        trailerBlock: Array<Byte>,
        splitTrailer: Bool
    ): Array<Byte> {
        let frames = ArrayList<Array<Byte>>()
        frames.add(
            buildServerEngineAbstractionTestH2FrameWire(
                buildServerEngineAbstractionTestH2HeadersPayload(
                    headerBlock
                ),
                frameType: UInt8(0x1),
                flags: UInt8(0x4),
                streamId: 105
            )
        )
        frames.add(
            buildServerEngineAbstractionTestH2FrameWire(
                serverEngineAbstractionTestByteArray(
                    "accepted-body".toArray()
                ),
                frameType: UInt8(0x0),
                flags: UInt8(0x0),
                streamId: 105
            )
        )
        if (splitTrailer) {
            let splitAt = trailerBlock.size - 5
            frames.add(
                buildServerEngineAbstractionTestH2FrameWire(
                    buildServerEngineAbstractionTestH2HeadersPayload(
                        cloneServerEngineByteWindow(
                            trailerBlock,
                            0,
                            splitAt
                        )
                    ),
                    frameType: UInt8(0x1),
                    flags: UInt8(0x1),
                    streamId: 105
                )
            )
            frames.add(
                buildServerEngineAbstractionTestH2FrameWire(
                    cloneServerEngineByteWindow(
                        trailerBlock,
                        splitAt,
                        trailerBlock.size - splitAt
                    ),
                    frameType: UInt8(0x9),
                    flags: UInt8(0x4),
                    streamId: 105
                )
            )
        } else {
            frames.add(
                buildServerEngineAbstractionTestH2FrameWire(
                    buildServerEngineAbstractionTestH2HeadersPayload(
                        trailerBlock
                    ),
                    frameType: UInt8(0x1),
                    flags: UInt8(0x5),
                    streamId: 105
                )
            )
        }
        concatServerEngineAbstractionTestByteArrays(frames.toArray())
    }
}

class JinguiAcceptedTransportAcceptedSocketApplicationDataFragmentedRecordWireHeadersPlusDataRequestTurnRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""
    public var requestWireFragments: ?Array<Array<Byte>> = None
    let rejectMode: String

    public init(rejectMode!: String = "wrong-stream-data") {
        this.rejectMode = rejectMode
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let clientHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1984)
                    )
                )
                let headerBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/one".toArray())
                ])
                let trailerBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x10), UInt8(0x11)]),
                    serverEngineAbstractionTestByteArray("x-request-trailer".toArray()),
                    serverEngineAbstractionTestByteArray([UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("tail".toArray())
                ])
                let transport = ContractAcceptedTransportDescriptor(
                    "accepted-socket-fragmented-appdata-data-turn-reject-transport",
                    localEndpoint: accepted.localAddress.toString(),
                    remoteEndpoint: accepted.remoteAddress.toString()
                )
                let session = option.attachJinguiAcceptedTransportTls13X25519(
                    transport,
                    clientHello.encodedClientHello,
                    engineIncrementalBytes(32, start: 2016)
                )
                let requestClientChannel = contractTls13CreateClientRecordChannel(
                    session.keyMaterial,
                    algorithm: session.recordChannel.algorithm
                )
                let requestPayload = if (rejectMode == "trailing-headers-without-end-stream") {
                    concatServerEngineAbstractionTestByteArrays([
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                headerBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x4),
                            streamId: 93
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            serverEngineAbstractionTestByteArray(
                                "blocked".toArray()
                            ),
                            frameType: UInt8(0x0),
                            flags: UInt8(0x0),
                            streamId: 93
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                trailerBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x4),
                            streamId: 93
                        )
                    ])
                } else if (rejectMode == "trailing-headers-before-data") {
                    concatServerEngineAbstractionTestByteArrays([
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                headerBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x4),
                            streamId: 93
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                trailerBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x5),
                            streamId: 93
                        )
                    ])
                } else if (rejectMode == "trailing-continuation-stream-mismatch") {
                    concatServerEngineAbstractionTestByteArrays([
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                headerBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x4),
                            streamId: 93
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            serverEngineAbstractionTestByteArray(
                                "blocked".toArray()
                            ),
                            frameType: UInt8(0x0),
                            flags: UInt8(0x0),
                            streamId: 93
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                cloneServerEngineByteWindow(
                                    trailerBlock,
                                    0,
                                    trailerBlock.size - 5
                                )
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x1),
                            streamId: 93
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            cloneServerEngineByteWindow(
                                trailerBlock,
                                trailerBlock.size - 5,
                                5
                            ),
                            frameType: UInt8(0x9),
                            flags: UInt8(0x4),
                            streamId: 95
                        )
                    ])
                } else if (rejectMode == "orphan-trailing-continuation") {
                    concatServerEngineAbstractionTestByteArrays([
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                headerBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x4),
                            streamId: 93
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            serverEngineAbstractionTestByteArray(
                                "blocked".toArray()
                            ),
                            frameType: UInt8(0x0),
                            flags: UInt8(0x0),
                            streamId: 93
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            cloneServerEngineByteWindow(
                                trailerBlock,
                                trailerBlock.size - 5,
                                5
                            ),
                            frameType: UInt8(0x9),
                            flags: UInt8(0x4),
                            streamId: 93
                        )
                    ])
                } else if (rejectMode == "data-after-trailing-headers") {
                    concatServerEngineAbstractionTestByteArrays([
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                headerBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x4),
                            streamId: 93
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            serverEngineAbstractionTestByteArray(
                                "blocked".toArray()
                            ),
                            frameType: UInt8(0x0),
                            flags: UInt8(0x0),
                            streamId: 93
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                trailerBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x5),
                            streamId: 93
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            serverEngineAbstractionTestByteArray(
                                "too-late".toArray()
                            ),
                            frameType: UInt8(0x0),
                            flags: UInt8(0x1),
                            streamId: 93
                        )
                    ])
                } else {
                    concatServerEngineAbstractionTestByteArrays([
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                headerBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x4),
                            streamId: 93
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            serverEngineAbstractionTestByteArray(
                                "blocked".toArray()
                            ),
                            frameType: UInt8(0x0),
                            flags: UInt8(0x1),
                            streamId: 95
                        )
                    ])
                }
                let requestRecords = requestClientChannel.sealFragments(
                    ContractTlsRecordContentType.ApplicationData,
                    requestPayload,
                    maxFragmentLen: 7
                )
                let encodedWire =
                    concatServerEngineAbstractionTestByteArrays(requestRecords)
                requestWireFragments = Some([
                    cloneServerEngineByteWindow(
                        encodedWire,
                        0,
                        4
                    ),
                    cloneServerEngineByteWindow(
                        encodedWire,
                        4,
                        encodedWire.size - 7
                    ),
                    cloneServerEngineByteWindow(
                        encodedWire,
                        encodedWire.size - 3,
                        3
                    )
                ])
                try {
                    let _ =
                        option.serveJinguiAcceptedTransportSessionAcceptedSocketApplicationDataFragmentedRecordWireH2HeadersPlusDataRequestTurn(
                            session,
                            accepted,
                            app,
                            readChunkSize: 5,
                            maxFragmentLen: 8
                        )
                    @Fail(
                        "expected accepted-socket fragmented-record-wire headers-plus-data request-turn rejection"
                    )
                } catch (e: Exception) {
                    observedError = e.message
                }
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataHeadersPlusDataRequestTurnProbeEngine <: ServerEngine {
    public var bodyStringReadyStatus: String = ""
    public var bodyJsonReadyStatus: String = ""
    public var bodyStringResponseStatus: UInt16 = 0
    public var bodyJsonResponseStatus: UInt16 = 0
    public var bodyStringContentType: String = ""
    public var bodyJsonContentType: String = ""
    public var bodyStringTransferEncoding: String = ""
    public var bodyJsonTransferEncoding: String = ""
    public var bodyStringSocketWriteCount: Int64 = 0
    public var bodyJsonSocketWriteCount: Int64 = 0
    var bodyStringClientChannel: ?ContractTlsRecordChannel = None
    var bodyJsonClientChannel: ?ContractTlsRecordChannel = None

    public func openBodyStringSocketWire(wire: Array<UInt8>): String {
        match (bodyStringClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected headers-plus-data request-turn bodyString companion client record channel before socket wire open"
                )
        }
    }

    public func openBodyJsonSocketWire(wire: Array<UInt8>): String {
        match (bodyJsonClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected headers-plus-data request-turn bodyJson companion client record channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let bodyStringAccepted = listener.accept()
            try {
                let bodyStringHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1472)
                    )
                )
                let bodyStringHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x26)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-data-turn-body-string".toArray()
                    )
                ])
                let bodyStringTransport = ContractAcceptedTransportDescriptor(
                    "appdata-data-turn-body-string-transport",
                    localEndpoint: bodyStringAccepted.localAddress.toString(),
                    remoteEndpoint: bodyStringAccepted.remoteAddress.toString()
                )
                let bodyStringSession = option.attachJinguiAcceptedTransportTls13X25519(
                    bodyStringTransport,
                    bodyStringHello.encodedClientHello,
                    engineIncrementalBytes(32, start: 1504)
                )
                let bodyStringRequestClientChannel =
                    contractTls13CreateClientRecordChannel(
                        bodyStringSession.keyMaterial,
                        algorithm: bodyStringSession.recordChannel.algorithm
                    )
                let bodyStringRequestFragments =
                    bodyStringRequestClientChannel.sealFragments(
                        ContractTlsRecordContentType.ApplicationData,
                        concatServerEngineAbstractionTestByteArrays([
                            buildServerEngineAbstractionTestH2FrameWire(
                                buildServerEngineAbstractionTestH2HeadersPayload(
                                    bodyStringHeaderBlock
                                ),
                                frameType: UInt8(0x1),
                                flags: UInt8(0x4),
                                streamId: 73
                            ),
                            buildServerEngineAbstractionTestH2FrameWire(
                                serverEngineAbstractionTestByteArray(
                                    "accepted-".toArray()
                                ),
                                frameType: UInt8(0x0),
                                flags: UInt8(0x0),
                                streamId: 73
                            ),
                            buildServerEngineAbstractionTestH2FrameWire(
                                serverEngineAbstractionTestByteArray(
                                    "appdata-body".toArray()
                                ),
                                frameType: UInt8(0x0),
                                flags: UInt8(0x1),
                                streamId: 73
                            )
                        ]),
                        maxFragmentLen: 7
                    )
                let bodyStringTurn =
                    option.serveJinguiAcceptedTransportSessionApplicationDataH2HeadersPlusDataRequestTurn(
                        bodyStringSession,
                        bodyStringAccepted,
                        app,
                        bodyStringRequestFragments,
                        maxFragmentLen: 8
                    )
                bodyStringClientChannel = Some(bodyStringRequestClientChannel)
                bodyStringReadyStatus = bodyStringTurn.readySnapshot.status
                bodyStringResponseStatus = bodyStringTurn.responseStatus
                bodyStringContentType =
                    bodyStringTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyStringTransferEncoding =
                    bodyStringTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyStringSocketWriteCount = bodyStringTurn.socketWriteCount
            } finally {
                if (!bodyStringAccepted.isClosed()) {
                    bodyStringAccepted.close()
                }
            }

            let bodyJsonAccepted = listener.accept()
            try {
                let bodyJsonHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1536)
                    )
                )
                let bodyJsonHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x24)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-data-turn-body-json".toArray()
                    )
                ])
                let bodyJsonTransport = ContractAcceptedTransportDescriptor(
                    "appdata-data-turn-body-json-transport",
                    localEndpoint: bodyJsonAccepted.localAddress.toString(),
                    remoteEndpoint: bodyJsonAccepted.remoteAddress.toString()
                )
                let bodyJsonSession = option.attachJinguiAcceptedTransportTls13X25519(
                    bodyJsonTransport,
                    bodyJsonHello.encodedClientHello,
                    engineIncrementalBytes(32, start: 1568)
                )
                let bodyJsonRequestClientChannel =
                    contractTls13CreateClientRecordChannel(
                        bodyJsonSession.keyMaterial,
                        algorithm: bodyJsonSession.recordChannel.algorithm
                    )
                let bodyJsonRequestFragments =
                    bodyJsonRequestClientChannel.sealFragments(
                        ContractTlsRecordContentType.ApplicationData,
                        concatServerEngineAbstractionTestByteArrays([
                            buildServerEngineAbstractionTestH2FrameWire(
                                buildServerEngineAbstractionTestH2HeadersPayload(
                                    bodyJsonHeaderBlock
                                ),
                                frameType: UInt8(0x1),
                                flags: UInt8(0x4),
                                streamId: 75
                            ),
                            buildServerEngineAbstractionTestH2FrameWire(
                                serverEngineAbstractionTestByteArray(
                                    "{\"name\":\"ignite\",".toArray()
                                ),
                                frameType: UInt8(0x0),
                                flags: UInt8(0x0),
                                streamId: 75
                            ),
                            buildServerEngineAbstractionTestH2FrameWire(
                                serverEngineAbstractionTestByteArray(
                                    "\"val\":23}".toArray()
                                ),
                                frameType: UInt8(0x0),
                                flags: UInt8(0x1),
                                streamId: 75
                            )
                        ]),
                        maxFragmentLen: 7
                    )
                let bodyJsonTurn =
                    option.serveJinguiAcceptedTransportSessionApplicationDataH2HeadersPlusDataRequestTurn(
                        bodyJsonSession,
                        bodyJsonAccepted,
                        app,
                        bodyJsonRequestFragments,
                        maxFragmentLen: 8
                    )
                bodyJsonClientChannel = Some(bodyJsonRequestClientChannel)
                bodyJsonReadyStatus = bodyJsonTurn.readySnapshot.status
                bodyJsonResponseStatus = bodyJsonTurn.responseStatus
                bodyJsonContentType =
                    bodyJsonTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyJsonTransferEncoding =
                    bodyJsonTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyJsonSocketWriteCount = bodyJsonTurn.socketWriteCount
            } finally {
                if (!bodyJsonAccepted.isClosed()) {
                    bodyJsonAccepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportApplicationDataHeadersPlusDataRequestTurnRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let clientHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 1600)
                    )
                )
                let headerBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/one".toArray())
                ])
                let transport = ContractAcceptedTransportDescriptor(
                    "appdata-data-turn-reject-transport",
                    localEndpoint: accepted.localAddress.toString(),
                    remoteEndpoint: accepted.remoteAddress.toString()
                )
                let session = option.attachJinguiAcceptedTransportTls13X25519(
                    transport,
                    clientHello.encodedClientHello,
                    engineIncrementalBytes(32, start: 1632)
                )
                let requestClientChannel = contractTls13CreateClientRecordChannel(
                    session.keyMaterial,
                    algorithm: session.recordChannel.algorithm
                )
                let requestFragments = requestClientChannel.sealFragments(
                    ContractTlsRecordContentType.ApplicationData,
                    concatServerEngineAbstractionTestByteArrays([
                        buildServerEngineAbstractionTestH2FrameWire(
                            buildServerEngineAbstractionTestH2HeadersPayload(
                                headerBlock
                            ),
                            frameType: UInt8(0x1),
                            flags: UInt8(0x4),
                            streamId: 77
                        ),
                        buildServerEngineAbstractionTestH2FrameWire(
                            serverEngineAbstractionTestByteArray(
                                "blocked".toArray()
                            ),
                            frameType: UInt8(0x0),
                            flags: UInt8(0x1),
                            streamId: 79
                        )
                    ]),
                    maxFragmentLen: 7
                )
                try {
                    let _ =
                        option.serveJinguiAcceptedTransportSessionApplicationDataH2HeadersPlusDataRequestTurn(
                            session,
                            accepted,
                            app,
                            requestFragments,
                            maxFragmentLen: 8
                        )
                    @Fail("expected wrong-stream DATA request-turn rejection")
                } catch (e: Exception) {
                    observedError = e.message
                }
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloCaptureProbeEngine <: ServerEngine {
    public var capturedClientHello: Array<Byte> = []
    public var capturedRecordCount: Int64 = 0
    public var capturedRecordWireByteCount: Int64 = 0

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let capture =
                    option.captureJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHello(
                        accepted,
                        readChunkSize: 7
                    )
                capturedClientHello = capture.encodedClientHello
                capturedRecordCount = capture.consumedRecordCount
                capturedRecordWireByteCount =
                    capture.consumedRecordWireByteCount
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloCaptureRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                try {
                    let _ =
                        option.captureJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHello(
                            accepted,
                            readChunkSize: 7
                        )
                } catch (e: Exception) {
                    observedError = e.message
                }
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloAttachProbeEngine <: ServerEngine {
    public var capturedClientHello: Array<Byte> = []
    public var capturedRecordCount: Int64 = 0
    public var capturedRecordWireByteCount: Int64 = 0
    public var readyStatus: String = ""
    public var secureSessionReady: Bool = false
    public var negotiatedAlpn: String = ""
    public var requestedServerName: String = ""
    public var acknowledgedServerName: Bool = false
    public var attachSurface: String = ""
    public var transportId: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let result =
                    option.attachJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloX25519(
                        accepted,
                        engineIncrementalBytes(32, start: 2304),
                        transportId: "captured-clienthello-attach-transport",
                        readChunkSize: 9
                    )
                capturedClientHello = result.capture.encodedClientHello
                capturedRecordCount = result.capture.consumedRecordCount
                capturedRecordWireByteCount =
                    result.capture.consumedRecordWireByteCount
                readyStatus = result.readySnapshot.status
                secureSessionReady = result.readySnapshot.secureSessionReady
                negotiatedAlpn =
                    result.readySnapshot
                        .jinguiAttachResultSnapshot
                        .negotiatedAlpn
                requestedServerName =
                    result.readySnapshot
                        .jinguiAttachResultSnapshot
                        .requestedServerName
                acknowledgedServerName =
                    result.readySnapshot
                        .jinguiAttachResultSnapshot
                        .acknowledgedServerName
                attachSurface =
                    result.readySnapshot
                        .jinguiAttachResultSnapshot
                        .attachSurface
                transportId = result.readySnapshot.transport.transportId
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloAttachRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                try {
                    let _ =
                        option.attachJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloX25519(
                            accepted,
                            engineIncrementalBytes(32, start: 2336),
                            transportId: "captured-clienthello-attach-reject-transport",
                            readChunkSize: 9
                        )
                } catch (e: Exception) {
                    observedError = e.message
                }
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloRequestTurnProbeEngine <: ServerEngine {
    public var bodyStringReadyStatus: String = ""
    public var bodyJsonReadyStatus: String = ""
    public var bodyStringResponseStatus: UInt16 = 0
    public var bodyJsonResponseStatus: UInt16 = 0
    public var bodyStringContentType: String = ""
    public var bodyJsonContentType: String = ""
    public var bodyStringTransferEncoding: String = ""
    public var bodyJsonTransferEncoding: String = ""
    public var bodyStringSocketWriteCount: Int64 = 0
    public var bodyJsonSocketWriteCount: Int64 = 0
    public var bodyStringNegotiatedAlpn: String = ""
    public var bodyJsonNegotiatedAlpn: String = ""
    public var bodyStringRequestedServerName: String = ""
    public var bodyJsonRequestedServerName: String = ""
    public var bodyStringAttachSurface: String = ""
    public var bodyJsonAttachSurface: String = ""
    public var bodyStringTransportId: String = ""
    public var bodyJsonTransportId: String = ""
    public var bodyStringRequestWireFragments: ?Array<Array<Byte>> = None
    public var bodyJsonRequestWireFragments: ?Array<Array<Byte>> = None
    var bodyStringClientChannel: ?ContractTlsRecordChannel = None
    var bodyJsonClientChannel: ?ContractTlsRecordChannel = None

    public func openBodyStringSocketWire(wire: Array<UInt8>): String {
        match (bodyStringClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "captured-clienthello fragmented bodyString client channel missing"
                )
        }
    }

    public func openBodyJsonSocketWire(wire: Array<UInt8>): String {
        match (bodyJsonClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "captured-clienthello fragmented bodyJson client channel missing"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let bodyStringAccepted = listener.accept()
            try {
                let bodyStringServerKeyExchangePrivate =
                    engineIncrementalBytes(32, start: 2432)
                let bodyStringProbeTransportId =
                    "captured-clienthello-fragmented-appdata-data-turn-body-string-transport"
                let bodyStringHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x26)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-data-turn-body-string".toArray()
                    )
                ])
                let bodyStringTurn =
                    option.serveJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataFragmentedRecordWireH2HeadersPlusDataRequestTurn(
                        bodyStringAccepted,
                        app,
                        bodyStringServerKeyExchangePrivate,
                        transportId: bodyStringProbeTransportId,
                        readChunkSize: 5,
                        maxFragmentLen: 8,
                        attachedSessionReadyHook: { session =>
                            let requestClientChannel =
                                contractTls13CreateClientRecordChannel(
                                    session.keyMaterial,
                                    algorithm: session.recordChannel.algorithm
                                )
                            let requestRecords =
                                requestClientChannel.sealFragments(
                                    ContractTlsRecordContentType.ApplicationData,
                                    concatServerEngineAbstractionTestByteArrays([
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            buildServerEngineAbstractionTestH2HeadersPayload(
                                                bodyStringHeaderBlock
                                            ),
                                            frameType: UInt8(0x1),
                                            flags: UInt8(0x4),
                                            streamId: 105
                                        ),
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            serverEngineAbstractionTestByteArray(
                                                "accepted-".toArray()
                                            ),
                                            frameType: UInt8(0x0),
                                            flags: UInt8(0x0),
                                            streamId: 105
                                        ),
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            serverEngineAbstractionTestByteArray(
                                                "appdata-body".toArray()
                                            ),
                                            frameType: UInt8(0x0),
                                            flags: UInt8(0x1),
                                            streamId: 105
                                        )
                                    ]),
                                    maxFragmentLen: 7
                                )
                            let encodedWire =
                                concatServerEngineAbstractionTestByteArrays(
                                    requestRecords
                                )
                            bodyStringRequestWireFragments = Some([
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    0,
                                    4
                                ),
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    4,
                                    encodedWire.size - 7
                                ),
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    encodedWire.size - 3,
                                    3
                                )
                            ])
                            bodyStringClientChannel = Some(
                                requestClientChannel
                            )
                        }
                    )
                bodyStringReadyStatus = bodyStringTurn.readySnapshot.status
                bodyStringResponseStatus = bodyStringTurn.responseStatus
                bodyStringContentType =
                    bodyStringTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyStringTransferEncoding =
                    bodyStringTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyStringSocketWriteCount = bodyStringTurn.socketWriteCount
                bodyStringNegotiatedAlpn =
                    bodyStringTurn.readySnapshot.jinguiAttachResultSnapshot.negotiatedAlpn
                bodyStringRequestedServerName =
                    bodyStringTurn.readySnapshot.jinguiAttachResultSnapshot.requestedServerName
                bodyStringAttachSurface =
                    bodyStringTurn.readySnapshot.jinguiAttachResultSnapshot.attachSurface
                bodyStringTransportId =
                    bodyStringTurn.readySnapshot.transport.transportId
            } finally {
                if (!bodyStringAccepted.isClosed()) {
                    bodyStringAccepted.close()
                }
            }

            let bodyJsonAccepted = listener.accept()
            try {
                let bodyJsonServerKeyExchangePrivate =
                    engineIncrementalBytes(32, start: 2464)
                let bodyJsonProbeTransportId =
                    "captured-clienthello-fragmented-appdata-data-turn-body-json-transport"
                let bodyJsonHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x24)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-data-turn-body-json".toArray()
                    )
                ])
                let bodyJsonTurn =
                    option.serveJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataFragmentedRecordWireH2HeadersPlusDataRequestTurn(
                        bodyJsonAccepted,
                        app,
                        bodyJsonServerKeyExchangePrivate,
                        transportId: bodyJsonProbeTransportId,
                        readChunkSize: 5,
                        maxFragmentLen: 8,
                        attachedSessionReadyHook: { session =>
                            let requestClientChannel =
                                contractTls13CreateClientRecordChannel(
                                    session.keyMaterial,
                                    algorithm: session.recordChannel.algorithm
                                )
                            let requestRecords =
                                requestClientChannel.sealFragments(
                                    ContractTlsRecordContentType.ApplicationData,
                                    concatServerEngineAbstractionTestByteArrays([
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            buildServerEngineAbstractionTestH2HeadersPayload(
                                                bodyJsonHeaderBlock
                                            ),
                                            frameType: UInt8(0x1),
                                            flags: UInt8(0x4),
                                            streamId: 107
                                        ),
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            serverEngineAbstractionTestByteArray(
                                                "{\"name\":\"ignite\",".toArray()
                                            ),
                                            frameType: UInt8(0x0),
                                            flags: UInt8(0x0),
                                            streamId: 107
                                        ),
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            serverEngineAbstractionTestByteArray(
                                                "\"val\":23}".toArray()
                                            ),
                                            frameType: UInt8(0x0),
                                            flags: UInt8(0x1),
                                            streamId: 107
                                        )
                                    ]),
                                    maxFragmentLen: 7
                                )
                            let encodedWire =
                                concatServerEngineAbstractionTestByteArrays(
                                    requestRecords
                                )
                            bodyJsonRequestWireFragments = Some([
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    0,
                                    4
                                ),
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    4,
                                    encodedWire.size - 7
                                ),
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    encodedWire.size - 3,
                                    3
                                )
                            ])
                            bodyJsonClientChannel = Some(
                                requestClientChannel
                            )
                        }
                    )
                bodyJsonReadyStatus = bodyJsonTurn.readySnapshot.status
                bodyJsonResponseStatus = bodyJsonTurn.responseStatus
                bodyJsonContentType =
                    bodyJsonTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyJsonTransferEncoding =
                    bodyJsonTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyJsonSocketWriteCount = bodyJsonTurn.socketWriteCount
                bodyJsonNegotiatedAlpn =
                    bodyJsonTurn.readySnapshot.jinguiAttachResultSnapshot.negotiatedAlpn
                bodyJsonRequestedServerName =
                    bodyJsonTurn.readySnapshot.jinguiAttachResultSnapshot.requestedServerName
                bodyJsonAttachSurface =
                    bodyJsonTurn.readySnapshot.jinguiAttachResultSnapshot.attachSurface
                bodyJsonTransportId =
                    bodyJsonTurn.readySnapshot.transport.transportId
            } finally {
                if (!bodyJsonAccepted.isClosed()) {
                    bodyJsonAccepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloRequestTurnRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                try {
                    let _ =
                        option.serveJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloApplicationDataFragmentedRecordWireH2HeadersPlusDataRequestTurn(
                            accepted,
                            app,
                            engineIncrementalBytes(32, start: 2496),
                            transportId: "captured-clienthello-fragmented-appdata-data-turn-reject-transport",
                            readChunkSize: 5,
                            maxFragmentLen: 8
                        )
                } catch (e: Exception) {
                    observedError = e.message
                }
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloLogicalRequestProbeEngine <: ServerEngine {
    public var bodyStringReadyStatus: String = ""
    public var bodyJsonReadyStatus: String = ""
    public var bodyStringResponseStatus: UInt16 = 0
    public var bodyJsonResponseStatus: UInt16 = 0
    public var bodyStringContentType: String = ""
    public var bodyJsonContentType: String = ""
    public var bodyStringTransferEncoding: String = ""
    public var bodyJsonTransferEncoding: String = ""
    public var bodyStringSocketWriteCount: Int64 = 0
    public var bodyJsonSocketWriteCount: Int64 = 0
    public var bodyStringNegotiatedAlpn: String = ""
    public var bodyJsonNegotiatedAlpn: String = ""
    public var bodyStringRequestedServerName: String = ""
    public var bodyJsonRequestedServerName: String = ""
    public var bodyStringAttachSurface: String = ""
    public var bodyJsonAttachSurface: String = ""
    public var bodyStringTransportId: String = ""
    public var bodyJsonTransportId: String = ""
    var bodyStringClientChannel: ?ContractTlsRecordChannel = None
    var bodyJsonClientChannel: ?ContractTlsRecordChannel = None

    public func openBodyStringSocketWire(wire: Array<UInt8>): String {
        match (bodyStringClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "captured-clienthello logical-request bodyString client channel missing"
                )
        }
    }

    public func openBodyJsonSocketWire(wire: Array<UInt8>): String {
        match (bodyJsonClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "captured-clienthello logical-request bodyJson client channel missing"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let bodyStringAccepted = listener.accept()
            try {
                let bodyStringTurn =
                    option.serveJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloLogicalRequest(
                        bodyStringAccepted,
                        app,
                        ServerJinguiAcceptedTransportLogicalRequest(
                            "POST",
                            "/carrier-captured-logical-body-string",
                            bodyBytes: "accepted-body".toArray()
                        ),
                        engineIncrementalBytes(32, start: 2592),
                        transportId: "captured-clienthello-logical-request-body-string-transport",
                        readChunkSize: 5,
                        maxFragmentLen: 8
                    )
                bodyStringClientChannel = Some(
                    contractTls13CreateClientRecordChannel(
                        bodyStringTurn.session.keyMaterial,
                        algorithm: bodyStringTurn.session.recordChannel.algorithm
                    )
                )
                bodyStringReadyStatus = bodyStringTurn.readySnapshot.status
                bodyStringResponseStatus = bodyStringTurn.responseStatus
                bodyStringContentType =
                    bodyStringTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyStringTransferEncoding =
                    bodyStringTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyStringSocketWriteCount = bodyStringTurn.socketWriteCount
                bodyStringNegotiatedAlpn =
                    bodyStringTurn.readySnapshot.jinguiAttachResultSnapshot.negotiatedAlpn
                bodyStringRequestedServerName =
                    bodyStringTurn.readySnapshot.jinguiAttachResultSnapshot.requestedServerName
                bodyStringAttachSurface =
                    bodyStringTurn.readySnapshot.jinguiAttachResultSnapshot.attachSurface
                bodyStringTransportId =
                    bodyStringTurn.readySnapshot.transport.transportId
            } finally {
                if (!bodyStringAccepted.isClosed()) {
                    bodyStringAccepted.close()
                }
            }

            let bodyJsonAccepted = listener.accept()
            try {
                let bodyJsonTurn =
                    option.serveJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloLogicalRequest(
                        bodyJsonAccepted,
                        app,
                        ServerJinguiAcceptedTransportLogicalRequest(
                            "POST",
                            "/carrier-captured-logical-body-json",
                            bodyBytes: #"{"name":"ignite","val":23}"#.toArray()
                        ),
                        engineIncrementalBytes(32, start: 2624),
                        transportId: "captured-clienthello-logical-request-body-json-transport",
                        readChunkSize: 5,
                        maxFragmentLen: 8
                    )
                bodyJsonClientChannel = Some(
                    contractTls13CreateClientRecordChannel(
                        bodyJsonTurn.session.keyMaterial,
                        algorithm: bodyJsonTurn.session.recordChannel.algorithm
                    )
                )
                bodyJsonReadyStatus = bodyJsonTurn.readySnapshot.status
                bodyJsonResponseStatus = bodyJsonTurn.responseStatus
                bodyJsonContentType =
                    bodyJsonTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyJsonTransferEncoding =
                    bodyJsonTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyJsonSocketWriteCount = bodyJsonTurn.socketWriteCount
                bodyJsonNegotiatedAlpn =
                    bodyJsonTurn.readySnapshot.jinguiAttachResultSnapshot.negotiatedAlpn
                bodyJsonRequestedServerName =
                    bodyJsonTurn.readySnapshot.jinguiAttachResultSnapshot.requestedServerName
                bodyJsonAttachSurface =
                    bodyJsonTurn.readySnapshot.jinguiAttachResultSnapshot.attachSurface
                bodyJsonTransportId =
                    bodyJsonTurn.readySnapshot.transport.transportId
            } finally {
                if (!bodyJsonAccepted.isClosed()) {
                    bodyJsonAccepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloLogicalRequestRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                try {
                    let _ =
                        option.serveJinguiAcceptedTransportSocketFragmentedTlsHandshakeClientHelloLogicalRequest(
                            accepted,
                            app,
                            ServerJinguiAcceptedTransportLogicalRequest(
                                "GET",
                                "/captured-clienthello-logical-request-reject"
                            ),
                            engineIncrementalBytes(32, start: 2656),
                            transportId: "captured-clienthello-logical-request-reject-transport",
                            readChunkSize: 5,
                            maxFragmentLen: 8
                        )
                } catch (e: Exception) {
                    observedError = e.message
                }
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketApplicationDataFragmentedRecordWireHeadersPlusDataRequestTurnProbeEngine <: ServerEngine {
    public var bodyStringReadyStatus: String = ""
    public var bodyJsonReadyStatus: String = ""
    public var bodyStringResponseStatus: UInt16 = 0
    public var bodyJsonResponseStatus: UInt16 = 0
    public var bodyStringContentType: String = ""
    public var bodyJsonContentType: String = ""
    public var bodyStringTransferEncoding: String = ""
    public var bodyJsonTransferEncoding: String = ""
    public var bodyStringSocketWriteCount: Int64 = 0
    public var bodyJsonSocketWriteCount: Int64 = 0
    public var bodyStringRequestWireFragments: ?Array<Array<Byte>> = None
    public var bodyJsonRequestWireFragments: ?Array<Array<Byte>> = None
    var bodyStringClientChannel: ?ContractTlsRecordChannel = None
    var bodyJsonClientChannel: ?ContractTlsRecordChannel = None

    public func openBodyStringSocketWire(wire: Array<UInt8>): String {
        match (bodyStringClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected attach-taking fragmented headers-plus-data request-turn bodyString companion client record channel before socket wire open"
                )
        }
    }

    public func openBodyJsonSocketWire(wire: Array<UInt8>): String {
        match (bodyJsonClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected attach-taking fragmented headers-plus-data request-turn bodyJson companion client record channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let bodyStringAccepted = listener.accept()
            try {
                let bodyStringHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 2048)
                    )
                )
                let bodyStringServerKeyExchangePrivate =
                    engineIncrementalBytes(32, start: 2080)
                let bodyStringTransportId =
                    "attach-taking-fragmented-appdata-data-turn-body-string-transport"
                let bodyStringHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x26)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-data-turn-body-string".toArray()
                    )
                ])
                let bodyStringTurn =
                    option.serveJinguiAcceptedTransportSocketApplicationDataFragmentedRecordWireH2HeadersPlusDataRequestTurn(
                        bodyStringAccepted,
                        app,
                        bodyStringHello.encodedClientHello,
                        bodyStringServerKeyExchangePrivate,
                        transportId: bodyStringTransportId,
                        readChunkSize: 5,
                        maxFragmentLen: 8,
                        attachedSessionReadyHook: { session =>
                            let requestClientChannel =
                                contractTls13CreateClientRecordChannel(
                                    session.keyMaterial,
                                    algorithm: session.recordChannel.algorithm
                                )
                            let requestRecords =
                                requestClientChannel.sealFragments(
                                    ContractTlsRecordContentType.ApplicationData,
                                    concatServerEngineAbstractionTestByteArrays([
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            buildServerEngineAbstractionTestH2HeadersPayload(
                                                bodyStringHeaderBlock
                                            ),
                                            frameType: UInt8(0x1),
                                            flags: UInt8(0x4),
                                            streamId: 97
                                        ),
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            serverEngineAbstractionTestByteArray(
                                                "accepted-".toArray()
                                            ),
                                            frameType: UInt8(0x0),
                                            flags: UInt8(0x0),
                                            streamId: 97
                                        ),
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            serverEngineAbstractionTestByteArray(
                                                "appdata-body".toArray()
                                            ),
                                            frameType: UInt8(0x0),
                                            flags: UInt8(0x1),
                                            streamId: 97
                                        )
                                    ]),
                                    maxFragmentLen: 7
                                )
                            let encodedWire =
                                concatServerEngineAbstractionTestByteArrays(
                                    requestRecords
                                )
                            bodyStringRequestWireFragments = Some([
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    0,
                                    4
                                ),
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    4,
                                    encodedWire.size - 7
                                ),
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    encodedWire.size - 3,
                                    3
                                )
                            ])
                            bodyStringClientChannel = Some(
                                requestClientChannel
                            )
                        }
                    )
                bodyStringReadyStatus = bodyStringTurn.readySnapshot.status
                bodyStringResponseStatus = bodyStringTurn.responseStatus
                bodyStringContentType =
                    bodyStringTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyStringTransferEncoding =
                    bodyStringTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyStringSocketWriteCount = bodyStringTurn.socketWriteCount
            } finally {
                if (!bodyStringAccepted.isClosed()) {
                    bodyStringAccepted.close()
                }
            }

            let bodyJsonAccepted = listener.accept()
            try {
                let bodyJsonHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 2112)
                    )
                )
                let bodyJsonServerKeyExchangePrivate =
                    engineIncrementalBytes(32, start: 2144)
                let bodyJsonTransportId =
                    "attach-taking-fragmented-appdata-data-turn-body-json-transport"
                let bodyJsonHeaderBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x24)]),
                    serverEngineAbstractionTestByteArray(
                        "/carrier-appdata-data-turn-body-json".toArray()
                    )
                ])
                let bodyJsonTurn =
                    option.serveJinguiAcceptedTransportSocketApplicationDataFragmentedRecordWireH2HeadersPlusDataRequestTurn(
                        bodyJsonAccepted,
                        app,
                        bodyJsonHello.encodedClientHello,
                        bodyJsonServerKeyExchangePrivate,
                        transportId: bodyJsonTransportId,
                        readChunkSize: 5,
                        maxFragmentLen: 8,
                        attachedSessionReadyHook: { session =>
                            let requestClientChannel =
                                contractTls13CreateClientRecordChannel(
                                    session.keyMaterial,
                                    algorithm: session.recordChannel.algorithm
                                )
                            let requestRecords =
                                requestClientChannel.sealFragments(
                                    ContractTlsRecordContentType.ApplicationData,
                                    concatServerEngineAbstractionTestByteArrays([
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            buildServerEngineAbstractionTestH2HeadersPayload(
                                                bodyJsonHeaderBlock
                                            ),
                                            frameType: UInt8(0x1),
                                            flags: UInt8(0x4),
                                            streamId: 99
                                        ),
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            serverEngineAbstractionTestByteArray(
                                                "{\"name\":\"ignite\",".toArray()
                                            ),
                                            frameType: UInt8(0x0),
                                            flags: UInt8(0x0),
                                            streamId: 99
                                        ),
                                        buildServerEngineAbstractionTestH2FrameWire(
                                            serverEngineAbstractionTestByteArray(
                                                "\"val\":23}".toArray()
                                            ),
                                            frameType: UInt8(0x0),
                                            flags: UInt8(0x1),
                                            streamId: 99
                                        )
                                    ]),
                                    maxFragmentLen: 7
                                )
                            let encodedWire =
                                concatServerEngineAbstractionTestByteArrays(
                                    requestRecords
                                )
                            bodyJsonRequestWireFragments = Some([
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    0,
                                    4
                                ),
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    4,
                                    encodedWire.size - 7
                                ),
                                cloneServerEngineByteWindow(
                                    encodedWire,
                                    encodedWire.size - 3,
                                    3
                                )
                            ])
                            bodyJsonClientChannel = Some(
                                requestClientChannel
                            )
                        }
                    )
                bodyJsonReadyStatus = bodyJsonTurn.readySnapshot.status
                bodyJsonResponseStatus = bodyJsonTurn.responseStatus
                bodyJsonContentType =
                    bodyJsonTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyJsonTransferEncoding =
                    bodyJsonTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyJsonSocketWriteCount = bodyJsonTurn.socketWriteCount
            } finally {
                if (!bodyJsonAccepted.isClosed()) {
                    bodyJsonAccepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportSocketApplicationDataFragmentedRecordWireHeadersPlusDataRequestTurnRejectProbeEngine <: ServerEngine {
    public var observedError: String = ""
    public var requestWireFragments: ?Array<Array<Byte>> = None

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let clientHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 2176)
                    )
                )
                let serverKeyExchangePrivate =
                    engineIncrementalBytes(32, start: 2208)
                let transportId =
                    "attach-taking-fragmented-appdata-data-turn-reject-transport"
                let headerBlock = concatServerEngineAbstractionTestByteArrays([
                    serverEngineAbstractionTestByteArray([UInt8(0x83)]),
                    serverEngineAbstractionTestByteArray([UInt8(0x44), UInt8(0x04)]),
                    serverEngineAbstractionTestByteArray("/one".toArray())
                ])
                try {
                    let _ =
                        option.serveJinguiAcceptedTransportSocketApplicationDataFragmentedRecordWireH2HeadersPlusDataRequestTurn(
                            accepted,
                            app,
                            clientHello.encodedClientHello,
                            serverKeyExchangePrivate,
                            transportId: transportId,
                            readChunkSize: 5,
                            maxFragmentLen: 8,
                            attachedSessionReadyHook: { session =>
                                let requestClientChannel =
                                    contractTls13CreateClientRecordChannel(
                                        session.keyMaterial,
                                        algorithm: session.recordChannel.algorithm
                                    )
                                let requestRecords =
                                    requestClientChannel.sealFragments(
                                        ContractTlsRecordContentType.ApplicationData,
                                        concatServerEngineAbstractionTestByteArrays([
                                            buildServerEngineAbstractionTestH2FrameWire(
                                                buildServerEngineAbstractionTestH2HeadersPayload(
                                                    headerBlock
                                                ),
                                                frameType: UInt8(0x1),
                                                flags: UInt8(0x4),
                                                streamId: 101
                                            ),
                                            buildServerEngineAbstractionTestH2FrameWire(
                                                serverEngineAbstractionTestByteArray(
                                                    "blocked".toArray()
                                                ),
                                                frameType: UInt8(0x0),
                                                flags: UInt8(0x1),
                                                streamId: 103
                                            )
                                        ]),
                                        maxFragmentLen: 7
                                    )
                                let encodedWire =
                                    concatServerEngineAbstractionTestByteArrays(
                                        requestRecords
                                    )
                                requestWireFragments = Some([
                                    cloneServerEngineByteWindow(
                                        encodedWire,
                                        0,
                                        4
                                    ),
                                    cloneServerEngineByteWindow(
                                        encodedWire,
                                        4,
                                        encodedWire.size - 7
                                    ),
                                    cloneServerEngineByteWindow(
                                        encodedWire,
                                        encodedWire.size - 3,
                                        3
                                    )
                                ])
                            }
                        )
                    @Fail(
                        "expected attach-taking fragmented-record-wire headers-plus-data request-turn rejection"
                    )
                } catch (e: Exception) {
                    observedError = e.message
                }
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportResponseTransportWriterProbeEngine <: ServerEngine {
    public var clientDecodedJson: String = ""
    public var encodedRecordCount: Int64 = 0
    public var totalEncodedBytes: Int64 = 0

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let transport = ContractAcceptedTransportDescriptor(
            "writer-accepted-transport",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55445"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 160))
        )
        let session = option.attachJinguiAcceptedTransportTls13X25519(
            transport,
            clientHello.encodedClientHello,
            engineIncrementalBytes(32, start: 192)
        )
        let clientChannel = contractTls13CreateClientRecordChannel(
            session.keyMaterial,
            algorithm: session.recordChannel.algorithm
        )
        let collector = CollectingResponseTransportWriter()
        let writer =
            option.openJinguiAcceptedTransportApplicationDataResponseTransportWriter(
                session,
                collector,
                maxFragmentLen: 8
            )
        let out = ResponseTransportOutputStream(writer)
        let jsonWriter = StdxJsonWriter(out)
        jsonWriter.startObject()
        jsonWriter.writeName("kind")
        jsonWriter.writeValue("response")
        jsonWriter.writeName("ok")
        jsonWriter.writeValue(true)
        jsonWriter.writeName("count")
        jsonWriter.writeValue(2)
        jsonWriter.endObject()
        jsonWriter.flush()

        encodedRecordCount = collector.writes.size
        for (record in collector.writes) {
            totalEncodedBytes += record.size
        }
        clientDecodedJson = String.fromUtf8(
            clientChannel.openAndReassemble(
                serverEngineAbstractionTestByteRecords(collector.writes)
            )
        )

        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportH2LifecycleApplicationDataWriterProbeEngine <: ServerEngine {
    public var successWriterOpenCalls: Int64 = 0
    public var successHandoffAcquisitionCount: Int64 = 0
    public var successSocketWriteCount: Int64 = 0
    public var successEncodedSocketBytes: Int64 = 0
    public var successEncodedRecordCount: Int64 = 0
    public var successDecodedFrameCount: Int64 = 0
    public var successFirstFrameType: UInt8 = 0
    public var successFirstFrameFlags: UInt8 = 0
    public var successSecondFrameType: UInt8 = 0
    public var successSecondFrameFlags: UInt8 = 0
    public var successFirstPayload: Array<Byte> = []
    public var successSecondPayload: Array<Byte> = []
    public var blockedRejected: Bool = false
    public var blockedWriterOpenCalls: Int64 = 0
    public var blockedEncodedRecordCount: Int64 = 0

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        runSuccessProbe(option)
        runBlockedProbe(option)
        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    func runSuccessProbe(option: ServerEngineListenOption): Unit {
        let transport = ContractAcceptedTransportDescriptor(
            "h2-lifecycle-appdata-success",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55448"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 448))
        )
        let session = option.attachJinguiAcceptedTransportTls13X25519(
            transport,
            clientHello.encodedClientHello,
            engineIncrementalBytes(32, start: 480)
        )
        let clientChannel = contractTls13CreateClientRecordChannel(
            session.keyMaterial,
            algorithm: session.recordChannel.algorithm
        )
        let collector = CollectingResponseTransportWriter()
        let lifecycle =
            ServerJinguiAcceptedTransportSocketResponseWriterLifecycle(
                { bytes => collector.write(bytes) }
            )
        let carrier =
            AcceptedTransportH2LifecycleApplicationDataProbeCarrier(
                "/h2-lifecycle-appdata-success",
                lifecycle,
                false
            )
        let wrappedCarrier =
            option.wrapCurrentRequestCarrierWithJinguiAcceptedTransportApplicationDataResponse(
                session,
                carrier,
                maxFragmentLen: 64
            )
        let model = JinguiAcceptedTransportH2FlowBudgetModel(20, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                serverEngineAbstractionTestTextBytes("s1")
            )
        )
        @Assert(queue.enqueueDataLengthWithEndStream(1, 8, true), 1)
        let firstChunk = queue.tryDrainHeadChunk(4)
        let secondChunk = queue.tryDrainHeadChunk(4)
        let handoff =
            JinguiAcceptedTransportH2AcceptedSocketResponseWriterHandoffGate(
                ServerJinguiAcceptedTransportDescriptorSnapshot(
                    "h2-lifecycle-appdata-success",
                    "accepted-socket",
                    "127.0.0.1:443",
                    "127.0.0.1:55448"
                ),
                wrappedCarrier
            )
        let _ =
            handoff.commitDataFrame(
                "accepted-socket-lifecycle-application-data-writer-probe",
                firstChunk,
                serverEngineAbstractionTestTextBytes("part")
            )
        let _ =
            handoff.commitDataFrame(
                "accepted-socket-lifecycle-application-data-writer-probe",
                secondChunk,
                serverEngineAbstractionTestTextBytes("done")
            )

        successWriterOpenCalls = carrier.openCalls
        successHandoffAcquisitionCount = handoff.acquisitionCount()
        successSocketWriteCount = lifecycle.socketWriteCount
        successEncodedSocketBytes = lifecycle.totalEncodedSocketBytes
        successEncodedRecordCount = collector.writes.size
        let decodedWire =
            clientChannel.openAndReassemble(
                serverEngineAbstractionTestByteRecords(collector.writes)
            )
        let frames = splitJinguiAcceptedTransportH2FrameWire(decodedWire)
        successDecodedFrameCount = frames.size
        let firstFrame = parseJinguiAcceptedTransportH2FrameWire(frames[0])
        let secondFrame = parseJinguiAcceptedTransportH2FrameWire(frames[1])
        successFirstFrameType = firstFrame.frameType
        successFirstFrameFlags = firstFrame.flags
        successSecondFrameType = secondFrame.frameType
        successSecondFrameFlags = secondFrame.flags
        successFirstPayload =
            cloneServerEngineAbstractionTestByteWindow(
                firstFrame.payload,
                0,
                firstFrame.payload.size
            )
        successSecondPayload =
            cloneServerEngineAbstractionTestByteWindow(
                secondFrame.payload,
                0,
                secondFrame.payload.size
            )
    }

    func runBlockedProbe(option: ServerEngineListenOption): Unit {
        let transport = ContractAcceptedTransportDescriptor(
            "h2-lifecycle-appdata-blocked",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55449"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 512))
        )
        let session = option.attachJinguiAcceptedTransportTls13X25519(
            transport,
            clientHello.encodedClientHello,
            engineIncrementalBytes(32, start: 544)
        )
        let collector = CollectingResponseTransportWriter()
        let lifecycle =
            ServerJinguiAcceptedTransportSocketResponseWriterLifecycle(
                { bytes => collector.write(bytes) }
            )
        let carrier =
            AcceptedTransportH2LifecycleApplicationDataProbeCarrier(
                "/h2-lifecycle-appdata-blocked",
                lifecycle,
                false
            )
        let wrappedCarrier =
            option.wrapCurrentRequestCarrierWithJinguiAcceptedTransportApplicationDataResponse(
                session,
                carrier,
                maxFragmentLen: 64
            )
        let model = JinguiAcceptedTransportH2FlowBudgetModel(3, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                serverEngineAbstractionTestTextBytes("s1")
            )
        )
        @Assert(queue.enqueueDataLengthWithEndStream(1, 4, true), 1)
        let blocked = queue.tryDrainHeadChunk(4)
        let handoff =
            JinguiAcceptedTransportH2AcceptedSocketResponseWriterHandoffGate(
                ServerJinguiAcceptedTransportDescriptorSnapshot(
                    "h2-lifecycle-appdata-blocked",
                    "accepted-socket",
                    "127.0.0.1:443",
                    "127.0.0.1:55449"
                ),
                wrappedCarrier
            )
        try {
            let _ =
                handoff.commitDataFrame(
                    "accepted-socket-lifecycle-application-data-writer-probe",
                    blocked,
                    serverEngineAbstractionTestTextBytes("wait")
                )
        } catch (_: Exception) {
            blockedRejected = true
        }
        blockedWriterOpenCalls = carrier.openCalls
        blockedEncodedRecordCount = collector.writes.size
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportH2ApplicationDataFailureCloseGuardProbeEngine <: ServerEngine {
    public var failureRejected: Bool = false
    public var failureMessage: String = ""
    public var failureWriterOpenCalls: Int64 = 0
    public var failureHandoffAcquisitionCount: Int64 = 0
    public var failureSocketWriteCount: Int64 = 0
    public var failureSinkAttempts: Int64 = 0
    public var failureAttemptedEncodedBytes: Int64 = 0
    public var failureLifecycleClosed: Bool = true
    public var closeGuardFirstCompleted: Bool = false
    public var closeGuardRejected: Bool = false
    public var closeGuardMessage: String = ""
    public var closeGuardWriterOpenCalls: Int64 = 0
    public var closeGuardHandoffAcquisitionCount: Int64 = 0
    public var closeGuardSocketWriteCount: Int64 = 0
    public var closeGuardEncodedRecordCount: Int64 = 0
    public var closeGuardLifecycleClosed: Bool = false
    public var closeGuardCloseReason: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        runFailureProbe(option)
        runCloseGuardProbe(option)
        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    func runFailureProbe(option: ServerEngineListenOption): Unit {
        let transport = ContractAcceptedTransportDescriptor(
            "h2-appdata-failure-guard",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55450"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 576))
        )
        let session = option.attachJinguiAcceptedTransportTls13X25519(
            transport,
            clientHello.encodedClientHello,
            engineIncrementalBytes(32, start: 608)
        )
        let lifecycle =
            ServerJinguiAcceptedTransportSocketResponseWriterLifecycle(
                { bytes =>
                    failureSinkAttempts += 1
                    failureAttemptedEncodedBytes += bytes.size
                    throw Exception(
                        "sr107 tls application-data downstream write failed"
                    )
                }
            )
        let carrier =
            AcceptedTransportH2LifecycleApplicationDataProbeCarrier(
                "/h2-appdata-failure-guard",
                lifecycle,
                false
            )
        let wrappedCarrier =
            option.wrapCurrentRequestCarrierWithJinguiAcceptedTransportApplicationDataResponse(
                session,
                carrier,
                maxFragmentLen: 64
            )
        let model = JinguiAcceptedTransportH2FlowBudgetModel(16, 16)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                serverEngineAbstractionTestTextBytes("s1")
            )
        )
        @Assert(queue.enqueueDataLengthWithEndStream(1, 4, true), 1)
        let chunk = queue.tryDrainHeadChunk(4)
        let handoff =
            JinguiAcceptedTransportH2AcceptedSocketResponseWriterHandoffGate(
                ServerJinguiAcceptedTransportDescriptorSnapshot(
                    "h2-appdata-failure-guard",
                    "accepted-socket",
                    "127.0.0.1:443",
                    "127.0.0.1:55450"
                ),
                wrappedCarrier
            )
        try {
            let _ =
                handoff.commitDataFrame(
                    "accepted-socket-lifecycle-application-data-sr107",
                    chunk,
                    serverEngineAbstractionTestTextBytes("fail")
                )
        } catch (e: Exception) {
            failureRejected = true
            failureMessage = e.message
        }
        failureWriterOpenCalls = carrier.openCalls
        failureHandoffAcquisitionCount = handoff.acquisitionCount()
        failureSocketWriteCount = lifecycle.socketWriteCount
        failureLifecycleClosed = lifecycle.closed
    }

    func runCloseGuardProbe(option: ServerEngineListenOption): Unit {
        let transport = ContractAcceptedTransportDescriptor(
            "h2-appdata-close-guard",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55451"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 640))
        )
        let session = option.attachJinguiAcceptedTransportTls13X25519(
            transport,
            clientHello.encodedClientHello,
            engineIncrementalBytes(32, start: 672)
        )
        let collector = CollectingResponseTransportWriter()
        let lifecycle =
            ServerJinguiAcceptedTransportSocketResponseWriterLifecycle(
                { bytes => collector.write(bytes) }
            )
        let carrier =
            AcceptedTransportH2LifecycleApplicationDataProbeCarrier(
                "/h2-appdata-close-guard",
                lifecycle,
                false
            )
        let wrappedCarrier =
            option.wrapCurrentRequestCarrierWithJinguiAcceptedTransportApplicationDataResponse(
                session,
                carrier,
                maxFragmentLen: 64
            )
        let model = JinguiAcceptedTransportH2FlowBudgetModel(16, 16)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                serverEngineAbstractionTestTextBytes("s1")
            )
        )
        @Assert(queue.enqueueDataLengthWithEndStream(1, 8, true), 1)
        let firstChunk = queue.tryDrainHeadChunk(4)
        let secondChunk = queue.tryDrainHeadChunk(4)
        let handoff =
            JinguiAcceptedTransportH2AcceptedSocketResponseWriterHandoffGate(
                ServerJinguiAcceptedTransportDescriptorSnapshot(
                    "h2-appdata-close-guard",
                    "accepted-socket",
                    "127.0.0.1:443",
                    "127.0.0.1:55451"
                ),
                wrappedCarrier
            )
        let first =
            handoff.commitDataFrame(
                "accepted-socket-lifecycle-application-data-sr107",
                firstChunk,
                serverEngineAbstractionTestTextBytes("open")
            )
        closeGuardFirstCompleted = first.completed
        lifecycle.closeResponseWriterLifecycle(reason: "sr107-close")
        try {
            let _ =
                handoff.commitDataFrame(
                    "accepted-socket-lifecycle-application-data-sr107",
                    secondChunk,
                    serverEngineAbstractionTestTextBytes("shut")
                )
        } catch (e: Exception) {
            closeGuardRejected = true
            closeGuardMessage = e.message
        }
        closeGuardWriterOpenCalls = carrier.openCalls
        closeGuardHandoffAcquisitionCount = handoff.acquisitionCount()
        closeGuardSocketWriteCount = lifecycle.socketWriteCount
        closeGuardEncodedRecordCount = collector.writes.size
        closeGuardLifecycleClosed = lifecycle.closed
        closeGuardCloseReason = lifecycle.closeReason
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportH2ApplicationDataResponseWriterTurnProbeEngine <: ServerEngine {
    let turnRequestUrl: String
    let turnStreamId: Int64
    public var turnReadyStatus: String = ""
    public var turnResponseStatus: UInt16 = 0
    public var turnContentType: String = ""
    public var turnCustomHeader: String = ""
    public var turnSocketWriteCount: Int64 = 0
    public var turnDecodedFrameCount: Int64 = 0
    public var turnHeadersFrameType: UInt8 = 0
    public var turnHeadersEndHeaders: Bool = false
    public var turnHeadersEndStream: Bool = false
    public var turnHeadersFrameStreamId: Int64 = 0
    public var turnHeadersFirstName: String = ""
    public var turnHeadersStatus: String = ""
    public var turnHeadersStatusStaticIndex: Int64 = 0
    public var turnHeadersPseudoFieldCount: Int64 = 0
    public var turnHeadersUnexpectedPseudoFieldSeen: Bool = false
    public var turnHeadersCacheControl: String = ""
    public var turnHeadersCacheControlNameStaticIndex: Int64 = 0
    public var turnHeadersContentLength: String = ""
    public var turnHeadersContentLengthNameStaticIndex: Int64 = 0
    public var turnHeadersContentType: String = ""
    public var turnHeadersContentTypeNameStaticIndex: Int64 = 0
    public var turnHeadersCustomHeader: String = ""
    public var turnHeadersExtraHeader: String = ""
    public var turnHeadersExtraHeaderNameStaticIndex: Int64 = 0
    public var turnHeadersRepeatHeaderCount: Int64 = 0
    public var turnHeadersRepeatHeaderFirst: String = ""
    public var turnHeadersRepeatHeaderSecond: String = ""
    public var turnHeadersServer: String = ""
    public var turnHeadersServerNameStaticIndex: Int64 = 0
    public var turnHeadersConnectionHeaderSeen: Bool = false
    public var turnHeadersKeepAliveHeaderSeen: Bool = false
    public var turnHeadersProxyConnectionHeaderSeen: Bool = false
    public var turnHeadersTransferEncodingHeaderSeen: Bool = false
    public var turnHeadersUpgradeHeaderSeen: Bool = false
    public var turnHeadersTeHeaderSeen: Bool = false
    public var turnDataFrameSeen: Bool = false
    public var turnFrameType: UInt8 = 0
    public var turnFrameEndStream: Bool = false
    public var turnFrameStreamId: Int64 = 0
    public var turnFramePayload: Array<Byte> = []
    public var turnExtraHeader: String = ""
    var turnClientChannel: ?ContractTlsRecordChannel = None

    public init(
        turnRequestUrl!: String = "/h2-appdata-response-turn?mode=data",
        streamId!: Int64 = 83
    ) {
        this.turnRequestUrl = turnRequestUrl
        this.turnStreamId = streamId
    }

    public func decodeTurnSocketWire(wire: Array<UInt8>): Unit {
        match (turnClientChannel) {
            case Some(channel) =>
                let decodedWire =
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                let frames = splitJinguiAcceptedTransportH2FrameWire(decodedWire)
                turnDecodedFrameCount = frames.size
                let headersFrame =
                    parseJinguiAcceptedTransportH2FrameWire(frames[0])
                let headersFragment =
                    parseJinguiAcceptedTransportH2HeaderBlockFragment(
                        headersFrame
                    )
                let headerBlock =
                    JinguiAcceptedTransportH2HeaderBlockSnapshot(
                        headersFrame.streamId,
                        headersFragment.endStream,
                        headersFragment.padded,
                        headersFragment.priorityPresented,
                        headersFragment.exclusiveDependency,
                        headersFragment.streamDependency,
                        headersFragment.weight,
                        headersFragment.headerBlockFragment
                    )
                let headerFields =
                    parseJinguiAcceptedTransportH2HeaderFields(headerBlock)
                var headerFieldIndex: Int64 = 0
                for (field in headerFields) {
                    if (headerFieldIndex == 0) {
                        turnHeadersFirstName = field.name
                    }
                    if (field.name.startsWith(":")) {
                        turnHeadersPseudoFieldCount += 1
                        if (field.name != ":status") {
                            turnHeadersUnexpectedPseudoFieldSeen = true
                        }
                    }
                    if (field.name == ":status") {
                        turnHeadersStatus = field.value
                        turnHeadersStatusStaticIndex = field.staticIndex
                    }
                    if (field.name == "cache-control") {
                        turnHeadersCacheControl = field.value
                        turnHeadersCacheControlNameStaticIndex =
                            field.nameStaticIndex
                    }
                    if (field.name == "content-length") {
                        turnHeadersContentLength = field.value
                        turnHeadersContentLengthNameStaticIndex =
                            field.nameStaticIndex
                    }
                    if (field.name == "content-type") {
                        turnHeadersContentType = field.value
                        turnHeadersContentTypeNameStaticIndex =
                            field.nameStaticIndex
                    }
                    if (field.name == "x-h2-turn") {
                        turnHeadersCustomHeader = field.value
                    }
                    if (field.name == "x-h2-extra") {
                        turnHeadersExtraHeader = field.value
                        turnHeadersExtraHeaderNameStaticIndex =
                            field.nameStaticIndex
                    }
                    if (field.name == "x-h2-repeat") {
                        turnHeadersRepeatHeaderCount += 1
                        if (turnHeadersRepeatHeaderCount == 1) {
                            turnHeadersRepeatHeaderFirst = field.value
                        } else if (turnHeadersRepeatHeaderCount == 2) {
                            turnHeadersRepeatHeaderSecond = field.value
                        }
                    }
                    if (field.name == "server") {
                        turnHeadersServer = field.value
                        turnHeadersServerNameStaticIndex =
                            field.nameStaticIndex
                    }
                    if (field.name == "connection") {
                        turnHeadersConnectionHeaderSeen = true
                    }
                    if (field.name == "keep-alive") {
                        turnHeadersKeepAliveHeaderSeen = true
                    }
                    if (field.name == "proxy-connection") {
                        turnHeadersProxyConnectionHeaderSeen = true
                    }
                    if (field.name == "transfer-encoding") {
                        turnHeadersTransferEncodingHeaderSeen = true
                    }
                    if (field.name == "upgrade") {
                        turnHeadersUpgradeHeaderSeen = true
                    }
                    if (field.name == "te") {
                        turnHeadersTeHeaderSeen = true
                    }
                    headerFieldIndex += 1
                }
                turnHeadersFrameType = headersFrame.frameType
                turnHeadersEndHeaders = headersFragment.endHeaders
                turnHeadersEndStream = headersFragment.endStream
                turnHeadersFrameStreamId = headersFrame.streamId
                if (frames.size > 1) {
                    let frame =
                        parseJinguiAcceptedTransportH2FrameWire(frames[1])
                    let dataFrame =
                        parseJinguiAcceptedTransportH2DataFrame(frame)
                    turnDataFrameSeen = true
                    turnFrameType = frame.frameType
                    turnFrameEndStream = dataFrame.endStream
                    turnFrameStreamId = frame.streamId
                    turnFramePayload =
                        cloneServerEngineAbstractionTestByteWindow(
                            dataFrame.dataBytes,
                            0,
                            dataFrame.dataBytes.size
                        )
                }
            case None =>
                throw Exception(
                    "expected SR108 turn companion client record channel before socket wire decode"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let accepted = listener.accept()
            try {
                let clientHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 704)
                    )
                )
                let turn =
                    option.serveJinguiAcceptedTransportSocketLogicalRequestH2DataResponseTurn(
                        accepted,
                        app,
                        ServerJinguiAcceptedTransportLogicalRequest(
                            "GET",
                            turnRequestUrl,
                            streamId: turnStreamId
                        ),
                        clientHello.encodedClientHello,
                        engineIncrementalBytes(32, start: 736),
                        transportId: "h2-appdata-response-turn-transport",
                        maxFragmentLen: 8
                    )
                turnClientChannel = Some(
                    contractTls13CreateClientRecordChannel(
                        turn.session.keyMaterial,
                        algorithm: turn.session.recordChannel.algorithm
                    )
                )
                turnReadyStatus = turn.readySnapshot.status
                turnResponseStatus = turn.responseStatus
                turnContentType =
                    turn.responseHeaders.getFirst("content-type") ?? ""
                turnCustomHeader =
                    turn.responseHeaders.getFirst("x-h2-turn") ?? ""
                turnExtraHeader =
                    turn.responseHeaders.getFirst("x-h2-extra") ?? ""
                turnSocketWriteCount = turn.socketWriteCount
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportResponseCarrierProbeEngine <: ServerEngine {
    public var jsonWriteDecodedJson: String = ""
    public var jsonStreamDecodedJson: String = ""
    public var jsonWriteEncodedRecordCount: Int64 = 0
    public var jsonStreamEncodedRecordCount: Int64 = 0
    public var jsonWriteResponseStatus: UInt16 = 0
    public var jsonStreamResponseStatus: UInt16 = 0
    public var jsonWriteContentType: String = ""
    public var jsonStreamContentType: String = ""
    public var jsonWriteTransferEncoding: String = ""
    public var jsonStreamTransferEncoding: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let jsonWriteTransport = ContractAcceptedTransportDescriptor(
            "carrier-json-write-transport",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55446"
        )
        let jsonWriteHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 224))
        )
        let jsonWriteSession = option.attachJinguiAcceptedTransportTls13X25519(
            jsonWriteTransport,
            jsonWriteHello.encodedClientHello,
            engineIncrementalBytes(32, start: 256)
        )
        let jsonWriteClientChannel = contractTls13CreateClientRecordChannel(
            jsonWriteSession.keyMaterial,
            algorithm: jsonWriteSession.recordChannel.algorithm
        )
        let jsonWriteCarrier = AcceptedTransportResponseProbeCarrier(
            "/carrier-json-write"
        )
        let wrappedJsonWriteCarrier =
            option.wrapCurrentRequestCarrierWithJinguiAcceptedTransportApplicationDataResponse(
                jsonWriteSession,
                jsonWriteCarrier,
                maxFragmentLen: 8
            )
        app.handleRequest(wrappedJsonWriteCarrier)
        jsonWriteEncodedRecordCount = jsonWriteCarrier.writer.writes.size
        jsonWriteDecodedJson = String.fromUtf8(
            jsonWriteClientChannel.openAndReassemble(
                serverEngineAbstractionTestByteRecords(
                    jsonWriteCarrier.writer.writes
                )
            )
        )
        jsonWriteResponseStatus = jsonWriteCarrier.responseStatus
        jsonWriteContentType =
            jsonWriteCarrier.responseHeaders.getFirst("content-type") ?? ""
        jsonWriteTransferEncoding =
            jsonWriteCarrier.responseHeaders.getFirst("transfer-encoding") ?? ""

        let jsonStreamTransport = ContractAcceptedTransportDescriptor(
            "carrier-json-stream-transport",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55447"
        )
        let jsonStreamHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(engineIncrementalBytes(32, start: 288))
        )
        let jsonStreamSession =
            option.attachJinguiAcceptedTransportTls13X25519(
                jsonStreamTransport,
                jsonStreamHello.encodedClientHello,
                engineIncrementalBytes(32, start: 320)
            )
        let jsonStreamClientChannel = contractTls13CreateClientRecordChannel(
            jsonStreamSession.keyMaterial,
            algorithm: jsonStreamSession.recordChannel.algorithm
        )
        let jsonStreamCarrier = AcceptedTransportResponseProbeCarrier(
            "/carrier-json-stream"
        )
        let wrappedJsonStreamCarrier =
            option.wrapCurrentRequestCarrierWithJinguiAcceptedTransportApplicationDataResponse(
                jsonStreamSession,
                jsonStreamCarrier,
                maxFragmentLen: 8
            )
        app.handleRequest(wrappedJsonStreamCarrier)
        jsonStreamEncodedRecordCount = jsonStreamCarrier.writer.writes.size
        jsonStreamDecodedJson = String.fromUtf8(
            jsonStreamClientChannel.openAndReassemble(
                serverEngineAbstractionTestByteRecords(
                    jsonStreamCarrier.writer.writes
                )
            )
        )
        jsonStreamResponseStatus = jsonStreamCarrier.responseStatus
        jsonStreamContentType =
            jsonStreamCarrier.responseHeaders.getFirst("content-type") ?? ""
        jsonStreamTransferEncoding =
            jsonStreamCarrier.responseHeaders.getFirst("transfer-encoding") ?? ""

        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportResponseSocketSinkProbeEngine <: ServerEngine {
    public var responseStatus: UInt16 = 0
    public var responseContentType: String = ""
    public var responseTransferEncoding: String = ""
    public var responseCustomHeader: String = ""
    public var responseSocketWriteCount: Int64 = 0
    public var totalEncodedSocketBytes: Int64 = 0
    var clientChannel: ?ContractTlsRecordChannel = None

    public func openClientSocketRecordWire(record: Array<UInt8>): String {
        match (clientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openApplicationData(
                        serverEngineAbstractionTestByteArray(record)
                    )
                )
            case None =>
                throw Exception(
                    "expected client record channel before opening socket write sink response"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }
            let accepted = listener.accept()
            try {
                let transport = ContractAcceptedTransportDescriptor(
                    "carrier-json-socket-sink-transport",
                    localEndpoint: accepted.localAddress.toString(),
                    remoteEndpoint: accepted.remoteAddress.toString()
                )
                let clientHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 352)
                    )
                )
                let session =
                    option.attachJinguiAcceptedTransportTls13X25519(
                        transport,
                        clientHello.encodedClientHello,
                        engineIncrementalBytes(32, start: 384)
                    )
                clientChannel = Some(
                    contractTls13CreateClientRecordChannel(
                        session.keyMaterial,
                        algorithm: session.recordChannel.algorithm
                    )
                )
                let carrier = AcceptedTransportResponseSocketSinkProbeCarrier(
                    "/carrier-json-socket-sink",
                    accepted
                )
                let wrappedCarrier =
                    option.wrapCurrentRequestCarrierWithJinguiAcceptedTransportApplicationDataResponse(
                        session,
                        carrier
                    )
                app.handleRequest(wrappedCarrier)
                responseStatus = carrier.responseStatus
                responseContentType =
                    carrier.responseHeaders.getFirst("content-type") ?? ""
                responseTransferEncoding =
                    carrier.responseHeaders.getFirst("transfer-encoding") ?? ""
                responseCustomHeader =
                    carrier.responseHeaders.getFirst("x-carrier-sink") ?? ""
                responseSocketWriteCount = carrier.socketWriteCount
                totalEncodedSocketBytes = carrier.totalEncodedSocketBytes
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportResponseSocketWireProbeEngine <: ServerEngine {
    public var jsonWriteResponseStatus: UInt16 = 0
    public var jsonStreamResponseStatus: UInt16 = 0
    public var jsonWriteContentType: String = ""
    public var jsonStreamContentType: String = ""
    public var jsonWriteTransferEncoding: String = ""
    public var jsonStreamTransferEncoding: String = ""
    public var jsonWriteSocketWriteCount: Int64 = 0
    public var jsonStreamSocketWriteCount: Int64 = 0
    public var jsonWriteReadyStatus: String = ""
    public var jsonStreamReadyStatus: String = ""
    var jsonWriteClientChannel: ?ContractTlsRecordChannel = None
    var jsonStreamClientChannel: ?ContractTlsRecordChannel = None

    public func openJsonWriteSocketWire(wire: Array<UInt8>): String {
        openJsonWriteSocketRecords(
            splitJinguiAcceptedTransportRecordWire(
                serverEngineAbstractionTestByteArray(wire)
            )
        )
    }

    public func openJsonWriteSocketRecords(records: Array<Array<Byte>>): String {
        match (jsonWriteClientChannel) {
            case Some(channel) =>
                String.fromUtf8(channel.openAndReassemble(records))
            case None =>
                throw Exception(
                    "expected jsonWrite companion client record channel before socket wire open"
                )
        }
    }

    public func openJsonStreamSocketWire(wire: Array<UInt8>): String {
        openJsonStreamSocketRecords(
            splitJinguiAcceptedTransportRecordWire(
                serverEngineAbstractionTestByteArray(wire)
            )
        )
    }

    public func openJsonStreamSocketRecords(records: Array<Array<Byte>>): String {
        match (jsonStreamClientChannel) {
            case Some(channel) =>
                String.fromUtf8(channel.openAndReassemble(records))
            case None =>
                throw Exception(
                    "expected jsonStream companion client record channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let jsonWriteAccepted = listener.accept()
            try {
                let jsonWriteHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 416)
                    )
                )
                let jsonWriteTurn =
                    option.serveJinguiAcceptedTransportSocketLogicalRequest(
                        jsonWriteAccepted,
                        app,
                        ServerJinguiAcceptedTransportLogicalRequest(
                            "GET",
                            "/carrier-json-write-socket-wire"
                        ),
                        jsonWriteHello.encodedClientHello,
                        engineIncrementalBytes(32, start: 448),
                        transportId: "carrier-json-write-socket-wire-transport",
                        maxFragmentLen: 8
                    )
                jsonWriteClientChannel = Some(
                    contractTls13CreateClientRecordChannel(
                        jsonWriteTurn.session.keyMaterial,
                        algorithm: jsonWriteTurn.session.recordChannel.algorithm
                    )
                )
                jsonWriteReadyStatus = jsonWriteTurn.readySnapshot.status
                jsonWriteResponseStatus = jsonWriteTurn.responseStatus
                jsonWriteContentType =
                    jsonWriteTurn.responseHeaders.getFirst("content-type") ?? ""
                jsonWriteTransferEncoding =
                    jsonWriteTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                jsonWriteSocketWriteCount =
                    jsonWriteTurn.socketWriteCount
            } finally {
                if (!jsonWriteAccepted.isClosed()) {
                    jsonWriteAccepted.close()
                }
            }

            let jsonStreamAccepted = listener.accept()
            try {
                let jsonStreamHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 480)
                    )
                )
                let jsonStreamTurn =
                    option.serveJinguiAcceptedTransportSocketLogicalRequest(
                        jsonStreamAccepted,
                        app,
                        ServerJinguiAcceptedTransportLogicalRequest(
                            "GET",
                            "/carrier-json-stream-socket-wire"
                        ),
                        jsonStreamHello.encodedClientHello,
                        engineIncrementalBytes(32, start: 512),
                        transportId: "carrier-json-stream-socket-wire-transport",
                        maxFragmentLen: 8
                    )
                jsonStreamClientChannel = Some(
                    contractTls13CreateClientRecordChannel(
                        jsonStreamTurn.session.keyMaterial,
                        algorithm: jsonStreamTurn.session.recordChannel.algorithm
                    )
                )
                jsonStreamReadyStatus = jsonStreamTurn.readySnapshot.status
                jsonStreamResponseStatus = jsonStreamTurn.responseStatus
                jsonStreamContentType =
                    jsonStreamTurn.responseHeaders.getFirst("content-type") ?? ""
                jsonStreamTransferEncoding =
                    jsonStreamTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                jsonStreamSocketWriteCount =
                    jsonStreamTurn.socketWriteCount
            } finally {
                if (!jsonStreamAccepted.isClosed()) {
                    jsonStreamAccepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportLogicalRequestBodyProbeEngine <: ServerEngine {
    public var bodyStringResponseStatus: UInt16 = 0
    public var bodyJsonResponseStatus: UInt16 = 0
    public var bodyStringContentType: String = ""
    public var bodyJsonContentType: String = ""
    public var bodyStringTransferEncoding: String = ""
    public var bodyJsonTransferEncoding: String = ""
    public var bodyStringSocketWriteCount: Int64 = 0
    public var bodyJsonSocketWriteCount: Int64 = 0
    public var bodyStringReadyStatus: String = ""
    public var bodyJsonReadyStatus: String = ""
    var bodyStringClientChannel: ?ContractTlsRecordChannel = None
    var bodyJsonClientChannel: ?ContractTlsRecordChannel = None

    public func openBodyStringSocketWire(wire: Array<UInt8>): String {
        match (bodyStringClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected bodyString companion client record channel before socket wire open"
                )
        }
    }

    public func openBodyJsonSocketWire(wire: Array<UInt8>): String {
        match (bodyJsonClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected bodyJson companion client record channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let bodyStringAccepted = listener.accept()
            try {
                let bodyStringHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 544)
                    )
                )
                let bodyStringTurn =
                    option.serveJinguiAcceptedTransportSocketLogicalRequest(
                        bodyStringAccepted,
                        app,
                        ServerJinguiAcceptedTransportLogicalRequest(
                            "POST",
                            "/carrier-body-string",
                            bodyBytes: "accepted-body".toArray()
                        ),
                        bodyStringHello.encodedClientHello,
                        engineIncrementalBytes(32, start: 576),
                        transportId: "carrier-body-string-transport",
                        maxFragmentLen: 8
                    )
                bodyStringClientChannel = Some(
                    contractTls13CreateClientRecordChannel(
                        bodyStringTurn.session.keyMaterial,
                        algorithm: bodyStringTurn.session.recordChannel.algorithm
                    )
                )
                bodyStringReadyStatus = bodyStringTurn.readySnapshot.status
                bodyStringResponseStatus = bodyStringTurn.responseStatus
                bodyStringContentType =
                    bodyStringTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyStringTransferEncoding =
                    bodyStringTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyStringSocketWriteCount = bodyStringTurn.socketWriteCount
            } finally {
                if (!bodyStringAccepted.isClosed()) {
                    bodyStringAccepted.close()
                }
            }

            let bodyJsonAccepted = listener.accept()
            try {
                let bodyJsonHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 608)
                    )
                )
                let bodyJsonTurn =
                    option.serveJinguiAcceptedTransportSocketLogicalRequest(
                        bodyJsonAccepted,
                        app,
                        ServerJinguiAcceptedTransportLogicalRequest(
                            "POST",
                            "/carrier-body-json",
                            bodyBytes: #"{"name":"ignite","val":23}"#.toArray()
                        ),
                        bodyJsonHello.encodedClientHello,
                        engineIncrementalBytes(32, start: 640),
                        transportId: "carrier-body-json-transport",
                        maxFragmentLen: 8
                    )
                bodyJsonClientChannel = Some(
                    contractTls13CreateClientRecordChannel(
                        bodyJsonTurn.session.keyMaterial,
                        algorithm: bodyJsonTurn.session.recordChannel.algorithm
                    )
                )
                bodyJsonReadyStatus = bodyJsonTurn.readySnapshot.status
                bodyJsonResponseStatus = bodyJsonTurn.responseStatus
                bodyJsonContentType =
                    bodyJsonTurn.responseHeaders.getFirst("content-type") ?? ""
                bodyJsonTransferEncoding =
                    bodyJsonTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                bodyJsonSocketWriteCount = bodyJsonTurn.socketWriteCount
            } finally {
                if (!bodyJsonAccepted.isClosed()) {
                    bodyJsonAccepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportLogicalRequestTargetQueryProbeEngine <: ServerEngine {
    public var queryResponseStatus: UInt16 = 0
    public var queryContentType: String = ""
    public var queryTransferEncoding: String = ""
    public var querySocketWriteCount: Int64 = 0
    public var queryReadyStatus: String = ""
    var queryClientChannel: ?ContractTlsRecordChannel = None

    public func openQuerySocketWire(wire: Array<UInt8>): String {
        match (queryClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected query companion client record channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let queryAccepted = listener.accept()
            try {
                let queryHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 672)
                    )
                )
                let queryTurn =
                    option.serveJinguiAcceptedTransportSocketLogicalRequest(
                        queryAccepted,
                        app,
                        ServerJinguiAcceptedTransportLogicalRequest(
                            "GET",
                            "/carrier-query?turn=from-path&mode=route"
                        ),
                        queryHello.encodedClientHello,
                        engineIncrementalBytes(32, start: 704),
                        transportId: "carrier-query-transport",
                        maxFragmentLen: 8
                    )
                queryClientChannel = Some(
                    contractTls13CreateClientRecordChannel(
                        queryTurn.session.keyMaterial,
                        algorithm: queryTurn.session.recordChannel.algorithm
                    )
                )
                queryReadyStatus = queryTurn.readySnapshot.status
                queryResponseStatus = queryTurn.responseStatus
                queryContentType =
                    queryTurn.responseHeaders.getFirst("content-type") ?? ""
                queryTransferEncoding =
                    queryTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                querySocketWriteCount = queryTurn.socketWriteCount
            } finally {
                if (!queryAccepted.isClosed()) {
                    queryAccepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class JinguiAcceptedTransportH2PseudoHeadersProbeEngine <: ServerEngine {
    public var pseudoResponseStatus: UInt16 = 0
    public var pseudoContentType: String = ""
    public var pseudoTransferEncoding: String = ""
    public var pseudoSocketWriteCount: Int64 = 0
    public var pseudoReadyStatus: String = ""
    var pseudoClientChannel: ?ContractTlsRecordChannel = None

    public func openPseudoSocketWire(wire: Array<UInt8>): String {
        match (pseudoClientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            serverEngineAbstractionTestByteArray(wire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected pseudo companion client record channel before socket wire open"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }

            let pseudoAccepted = listener.accept()
            try {
                let pseudoHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["h2", "http/1.1"],
                    clientPrivateKey: Some(
                        engineIncrementalBytes(32, start: 736)
                    )
                )
                let pseudoHeaders = HttpHeaders()
                pseudoHeaders.add("x-carrier-mode", "pseudo")
                let pseudoTurn =
                    option.serveJinguiAcceptedTransportSocketLogicalRequest(
                        pseudoAccepted,
                        app,
                        buildServerJinguiAcceptedTransportLogicalRequestFromH2PseudoHeaders(
                            ServerJinguiAcceptedTransportH2PseudoHeaders(
                                "POST",
                                "/carrier-h2-pseudo?turn=from-pseudo",
                                authority: "api.example.com:9443"
                            ),
                            headers: Some(pseudoHeaders),
                            bodyBytes: "pseudo-body".toArray()
                        ),
                        pseudoHello.encodedClientHello,
                        engineIncrementalBytes(32, start: 768),
                        transportId: "carrier-h2-pseudo-transport",
                        maxFragmentLen: 8
                    )
                pseudoClientChannel = Some(
                    contractTls13CreateClientRecordChannel(
                        pseudoTurn.session.keyMaterial,
                        algorithm: pseudoTurn.session.recordChannel.algorithm
                    )
                )
                pseudoReadyStatus = pseudoTurn.readySnapshot.status
                pseudoResponseStatus = pseudoTurn.responseStatus
                pseudoContentType =
                    pseudoTurn.responseHeaders.getFirst("content-type") ?? ""
                pseudoTransferEncoding =
                    pseudoTurn.responseHeaders.getFirst("transfer-encoding") ?? ""
                pseudoSocketWriteCount = pseudoTurn.socketWriteCount
            } finally {
                if (!pseudoAccepted.isClosed()) {
                    pseudoAccepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

func cloneServerEngineAbstractionTestHeaders(headers: HttpHeaders): HttpHeaders {
    let out = HttpHeaders()
    for ((name, values) in headers) {
        for (value in values) {
            out.add(name, value)
        }
    }
    out
}

class AcceptedTransportResponseProbeCarrier <: CurrentRequestCarrier {
    let pathText: String
    let requestTrailersValue: HttpHeaders
    public let responseHeaders = HttpHeaders()
    public let writer = CollectingResponseTransportWriter()
    public var responseStatus: UInt16 = 200

    init(pathText: String, requestTrailers!: ?HttpHeaders = None) {
        this.pathText = pathText
        this.requestTrailersValue = if (let Some(value) <- requestTrailers) {
            cloneServerEngineAbstractionTestHeaders(value)
        } else {
            HttpHeaders()
        }
    }

    public override func rawHttpContext(): HttpContext {
        throw Exception("raw HttpContext should not be required for accepted transport response probe carrier")
    }

    public override func upgradeWebSocketRaw(): WebSocket {
        throw Exception("websocket upgrade should not run for accepted transport response probe carrier")
    }

    public override func openResponseTransportWriterRaw(): ResponseTransportWriter {
        writer
    }

    public override func requestMethod(): String {
        "GET"
    }

    public override func requestPath(): String {
        pathText
    }

    public override func requestUrlString(): String {
        pathText
    }

    public override func requestVersionString(): String {
        "h2"
    }

    public override func requestRemoteAddr(): String {
        "127.0.0.1"
    }

    public override func requestQueryValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestFormValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestHeaderValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestHeaders(): HttpHeaders {
        HttpHeaders()
    }

    public override func requestTrailers(): HttpHeaders {
        requestTrailersValue
    }

    public override func requestBodyStream(): InputStream {
        AcceptedTransportResponseProbeEmptyInputStream()
    }

    public override func requestBodySize(): ?Int64 {
        Some(0)
    }

    public override func setResponseStatus(code: UInt16): Unit {
        responseStatus = code
    }

    public override func setResponseHeader(key: String, value: String): Unit {
        responseHeaders.add(key, value)
    }

    public override func addResponseHeaders(headers: HttpHeaders): Unit {
        let _ = headers
    }

    public override func setResponseString(body: String): Unit {
        let _ = body
        throw Exception(
            "response string should be intercepted by accepted transport response carrier wrapper"
        )
    }

    public override func setResponseBytes(data: Array<UInt8>): Unit {
        let _ = data
        throw Exception(
            "response bytes should be intercepted by accepted transport response carrier wrapper"
        )
    }

    public override func attachResponseBodyStream(stream: InputStream): Unit {
        let _ = stream
        throw Exception(
            "response stream should be intercepted by accepted transport response carrier wrapper"
        )
    }
}

class AcceptedTransportH2LifecycleApplicationDataProbeCarrier <: CurrentRequestCarrier {
    let pathText: String
    let lifecycle: ServerJinguiAcceptedTransportSocketResponseWriterLifecycle
    let failOnOpen: Bool
    public let responseHeaders = HttpHeaders()
    public var responseStatus: UInt16 = 200
    public var openCalls: Int64 = 0

    init(
        pathText: String,
        lifecycle: ServerJinguiAcceptedTransportSocketResponseWriterLifecycle,
        failOnOpen: Bool
    ) {
        this.pathText = pathText
        this.lifecycle = lifecycle
        this.failOnOpen = failOnOpen
    }

    public override func rawHttpContext(): HttpContext {
        throw Exception("raw HttpContext should not be required for accepted transport H2 lifecycle application-data probe carrier")
    }

    public override func upgradeWebSocketRaw(): WebSocket {
        throw Exception("websocket upgrade should not run for accepted transport H2 lifecycle application-data probe carrier")
    }

    public override func openResponseTransportWriterRaw(): ResponseTransportWriter {
        openCalls += 1
        if (failOnOpen) {
            throw Exception(
                "accepted transport H2 lifecycle application-data writer acquisition failed"
            )
        }
        lifecycle.openResponseTransportWriter()
    }

    public override func requestMethod(): String {
        "GET"
    }

    public override func requestPath(): String {
        pathText
    }

    public override func requestUrlString(): String {
        pathText
    }

    public override func requestVersionString(): String {
        "h2"
    }

    public override func requestRemoteAddr(): String {
        "127.0.0.1"
    }

    public override func requestQueryValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestFormValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestHeaderValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestHeaders(): HttpHeaders {
        HttpHeaders()
    }

    public override func requestTrailers(): HttpHeaders {
        HttpHeaders()
    }

    public override func requestBodyStream(): InputStream {
        AcceptedTransportResponseProbeEmptyInputStream()
    }

    public override func requestBodySize(): ?Int64 {
        Some(0)
    }

    public override func setResponseStatus(code: UInt16): Unit {
        responseStatus = code
    }

    public override func setResponseHeader(key: String, value: String): Unit {
        responseHeaders.add(key, value)
    }

    public override func addResponseHeaders(headers: HttpHeaders): Unit {
        let _ = headers
    }

    public override func setResponseString(body: String): Unit {
        let _ = body
        throw Exception(
            "response string should not run in accepted transport H2 lifecycle application-data probe"
        )
    }

    public override func setResponseBytes(data: Array<UInt8>): Unit {
        let _ = data
        throw Exception(
            "response bytes should not run in accepted transport H2 lifecycle application-data probe"
        )
    }

    public override func attachResponseBodyStream(stream: InputStream): Unit {
        let _ = stream
        throw Exception(
            "response stream should not run in accepted transport H2 lifecycle application-data probe"
        )
    }
}

class AcceptedTransportResponseSocketSinkProbeCarrier <: CurrentRequestCarrier {
    let pathText: String
    let socket: TcpSocket
    public let responseHeaders = HttpHeaders()
    public var responseStatus: UInt16 = 200
    public var socketWriteCount: Int64 = 0
    public var totalEncodedSocketBytes: Int64 = 0

    init(pathText: String, socket: TcpSocket) {
        this.pathText = pathText
        this.socket = socket
    }

    func writeSocketResponseBytes(bytes: Array<UInt8>): Unit {
        socketWriteCount += 1
        totalEncodedSocketBytes += bytes.size
        socket.write(bytes)
    }

    public override func rawHttpContext(): HttpContext {
        throw Exception("raw HttpContext should not be required for accepted transport response socket-sink probe carrier")
    }

    public override func upgradeWebSocketRaw(): WebSocket {
        throw Exception("websocket upgrade should not run for accepted transport response socket-sink probe carrier")
    }

    public override func openResponseTransportWriterRaw(): ResponseTransportWriter {
        openSinkBackedResponseTransportWriter({ bytes =>
            writeSocketResponseBytes(bytes)
        })
    }

    public override func requestMethod(): String {
        "GET"
    }

    public override func requestPath(): String {
        pathText
    }

    public override func requestUrlString(): String {
        pathText
    }

    public override func requestVersionString(): String {
        "h2"
    }

    public override func requestRemoteAddr(): String {
        socket.remoteAddress.toString()
    }

    public override func requestQueryValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestFormValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestHeaderValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestHeaders(): HttpHeaders {
        HttpHeaders()
    }

    public override func requestTrailers(): HttpHeaders {
        HttpHeaders()
    }

    public override func requestBodyStream(): InputStream {
        AcceptedTransportResponseProbeEmptyInputStream()
    }

    public override func requestBodySize(): ?Int64 {
        Some(0)
    }

    public override func setResponseStatus(code: UInt16): Unit {
        responseStatus = code
    }

    public override func setResponseHeader(key: String, value: String): Unit {
        responseHeaders.add(key, value)
    }

    public override func addResponseHeaders(headers: HttpHeaders): Unit {
        let _ = headers
    }

    public override func setResponseString(body: String): Unit {
        let _ = body
        throw Exception(
            "response string should be intercepted by accepted transport response socket-sink carrier wrapper"
        )
    }

    public override func setResponseBytes(data: Array<UInt8>): Unit {
        let _ = data
        throw Exception(
            "response bytes should be intercepted by accepted transport response socket-sink carrier wrapper"
        )
    }

    public override func attachResponseBodyStream(stream: InputStream): Unit {
        let _ = stream
        throw Exception(
            "response stream should be intercepted by accepted transport response socket-sink carrier wrapper"
        )
    }
}

class AcceptedTransportResponseProbeEmptyInputStream <: InputStream {
    public override func read(outBuf: Array<Byte>): Int64 {
        let _ = outBuf
        0
    }

    public func close(): Unit {}
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

func reserveServerEngineAbstractionLoopbackPort(): UInt16 {
    let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
    listener.bind()
    try {
        (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception(
                "server engine abstraction test could not reserve loopback port"
            )
    } finally {
        if (!listener.isClosed()) {
            listener.close()
        }
    }
}

func shutdownServerEngineAbstractionApp(app: App, future: Future<Unit>): Unit {
    app.shutdown()
    try {
        let _ = future.get(Duration.second * 1)
    } catch (_: Exception) {
        future.cancel()
    }
}

func installSocketServerEngineShellParityRoutes(
    app: App,
    bufferedBody: String,
    streamBody: String
): Unit {
    app.get("/parity-buffered", { ctx =>
        let _ = ctx.sendString(bufferedBody)
    })
    app.get("/parity-stream", { ctx =>
        let stream = SocketServerEngineShellStreamTrackingInput(streamBody.toArray())
        let _ = ctx.sendStream(
            stream,
            contentType: "text/plain; charset=utf-8",
            contentLength: Some(streamBody.size)
        )
    })
}

func assertSocketServerEngineShellStdxParityResponse(
    label: String,
    responseText: String,
    expectedBody: String
): Unit {
    let lower = responseText.toAsciiLower()
    if (socketServerEngineShellTestIndexOfText(lower, "http/1.1 200 ok") < 0) {
        @Fail("${label} should expose HTTP/1.1 200 OK")
    }
    if (
        socketServerEngineShellTestIndexOfText(
            lower,
            "content-type: text/plain; charset=utf-8"
        ) < 0
    ) {
        @Fail("${label} should preserve text/plain content-type")
    }
    if (
        socketServerEngineShellTestIndexOfText(
            lower,
            "content-length: ${expectedBody.size}"
        ) < 0
    ) {
        @Fail("${label} should preserve known content-length")
    }
    if (
        socketServerEngineShellTestIndexOfText(
            responseText,
            "\r\n\r\n${expectedBody}"
        ) < 0
    ) {
        @Fail("${label} should preserve response body")
    }
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

func runAcceptedTransportResponseSocketSinkClient(
    host: String,
    port: UInt16
): Array<UInt8> {
    let socket = TcpSocket(IPSocketAddress.parse("${host}:${port}"))
    socket.connect()
    try {
        readAcceptedTransportResponseSocketSinkWire(socket)
    } finally {
        if (!socket.isClosed()) {
            socket.close()
        }
    }
}

func runAcceptedTransportResponseSocketFragmentedClient(
    host: String,
    port: UInt16,
    readChunkSize!: Int64 = 3
): Array<Array<Byte>> {
    let socket = TcpSocket(IPSocketAddress.parse("${host}:${port}"))
    socket.connect()
    try {
        readAcceptedTransportResponseSocketFragmentedRecords(
            socket,
            readChunkSize: readChunkSize
        )
    } finally {
        if (!socket.isClosed()) {
            socket.close()
        }
    }
}

type AcceptedTransportRequestWireFragmentsSupplier =
    () -> ?Array<Array<Byte>>

func waitForAcceptedTransportPreparedRequestWireFragments(
    label: String,
    supplier: AcceptedTransportRequestWireFragmentsSupplier
): Array<Array<Byte>> {
    var attempts: Int64 = 0
    while (attempts < 200) {
        match (supplier()) {
            case Some(fragments) => return fragments
            case None => ()
        }
        sleep(Duration.millisecond * 10)
        attempts += 1
    }
    @Fail("timed out waiting for ${label}")
}

func runAcceptedTransportRequestResponseSocketSinkClient(
    host: String,
    port: UInt16,
    label: String,
    supplier: AcceptedTransportRequestWireFragmentsSupplier,
    writePauseMillis!: Int64 = 10
): Array<UInt8> {
    let socket = TcpSocket(IPSocketAddress.parse("${host}:${port}"))
    socket.connect()
    try {
        let requestWireFragments =
            waitForAcceptedTransportPreparedRequestWireFragments(
                label,
                supplier
            )
        var i: Int64 = 0
        while (i < requestWireFragments.size) {
            socket.write(
                serverEngineAbstractionTestUInt8Array(
                    requestWireFragments[i]
                )
            )
            if (
                writePauseMillis > 0 &&
                i + 1 < requestWireFragments.size
            ) {
                sleep(Duration.millisecond * writePauseMillis)
            }
            i += 1
        }
        readAcceptedTransportResponseSocketSinkWire(socket)
    } finally {
        if (!socket.isClosed()) {
            socket.close()
        }
    }
}

func runAcceptedTransportTlsHandshakeRequestResponseSocketSinkClient(
    host: String,
    port: UInt16,
    clientHelloWireFragments: Array<Array<Byte>>,
    label: String,
    supplier: AcceptedTransportRequestWireFragmentsSupplier,
    writePauseMillis!: Int64 = 10
): Array<UInt8> {
    let socket = TcpSocket(IPSocketAddress.parse("${host}:${port}"))
    socket.connect()
    try {
        var i: Int64 = 0
        while (i < clientHelloWireFragments.size) {
            socket.write(
                serverEngineAbstractionTestUInt8Array(
                    clientHelloWireFragments[i]
                )
            )
            if (
                writePauseMillis > 0 &&
                i + 1 < clientHelloWireFragments.size
            ) {
                sleep(Duration.millisecond * writePauseMillis)
            }
            i += 1
        }
        let requestWireFragments =
            waitForAcceptedTransportPreparedRequestWireFragments(
                label,
                supplier
            )
        i = 0
        while (i < requestWireFragments.size) {
            socket.write(
                serverEngineAbstractionTestUInt8Array(
                    requestWireFragments[i]
                )
            )
            if (
                writePauseMillis > 0 &&
                i + 1 < requestWireFragments.size
            ) {
                sleep(Duration.millisecond * writePauseMillis)
            }
            i += 1
        }
        readAcceptedTransportResponseSocketSinkWire(socket)
    } finally {
        if (!socket.isClosed()) {
            socket.close()
        }
    }
}

func runAcceptedTransportTlsHandshakeRequestResponseFirstRecordSocketSinkClient(
    host: String,
    port: UInt16,
    clientHelloWireFragments: Array<Array<Byte>>,
    label: String,
    supplier: AcceptedTransportRequestWireFragmentsSupplier,
    writePauseMillis!: Int64 = 10
): Array<UInt8> {
    let socket = TcpSocket(IPSocketAddress.parse("${host}:${port}"))
    socket.connect()
    try {
        writeAcceptedTransportSocketWireFragments(
            socket,
            clientHelloWireFragments,
            writePauseMillis: writePauseMillis
        )
        let requestWireFragments =
            waitForAcceptedTransportPreparedRequestWireFragments(
                label,
                supplier
            )
        writeAcceptedTransportSocketWireFragments(
            socket,
            requestWireFragments,
            writePauseMillis: writePauseMillis
        )
        serverEngineAbstractionTestUInt8Array(
            readAcceptedTransportResponseSocketFirstCompleteRecord(
                socket,
                readChunkSize: 3
            )
        )
    } finally {
        if (!socket.isClosed()) {
            socket.close()
        }
    }
}

func waitForNativeTlsLiveIngressClientChannel(
    label: String,
    probe: NativeTlsLiveIngressClientChannelProbe
): ContractTlsRecordChannel {
    var attempts: Int64 = 0
    while (attempts < 200) {
        match (probe.channel) {
            case Some(channel) => return channel
            case None => ()
        }
        sleep(Duration.millisecond * 10)
        attempts += 1
    }
    @Fail("timed out waiting for ${label}")
}

func writeAcceptedTransportSocketWireFragments(
    socket: TcpSocket,
    requestWireFragments: Array<Array<Byte>>,
    writePauseMillis!: Int64 = 10
): Unit {
    var i: Int64 = 0
    while (i < requestWireFragments.size) {
        socket.write(
            serverEngineAbstractionTestUInt8Array(
                requestWireFragments[i]
            )
        )
        if (writePauseMillis > 0 && i + 1 < requestWireFragments.size) {
            sleep(Duration.millisecond * writePauseMillis)
        }
        i += 1
    }
}

func readAcceptedTransportResponseSocketFirstCompleteRecord(
    socket: TcpSocket,
    readChunkSize!: Int64 = 3
): Array<Byte> {
    let accumulator = JinguiAcceptedTransportRecordWireAccumulator()
    let chunkSize = if (readChunkSize > 0) {
        readChunkSize
    } else {
        3
    }
    let buf = Array<UInt8>(chunkSize, repeat: 0)
    while (true) {
        let n = socket.read(buf)
        if (n <= 0) {
            throw Exception(
                "accepted transport response socket ended before one complete TLS record"
            )
        }
        accumulator.append(serverEngineAbstractionTestByteArray(buf[..n]))
        let records = accumulator.drainCompleteRecords()
        if (records.size > 0) {
            return records[0]
        }
    }
    throw Exception(
        "accepted transport response socket first complete record read loop ended unexpectedly"
    )
}

func buildAcceptedTransportTlsH2HeadersPlusDataRequestRecords(
    channel: ContractTlsRecordChannel,
    headerBlockFragment: Array<Byte>,
    streamId: Int64,
    bodyText: String
): Array<Array<Byte>> {
    channel.sealFragments(
        ContractTlsRecordContentType.ApplicationData,
        concatServerEngineAbstractionTestByteArrays([
            buildServerEngineAbstractionTestH2FrameWire(
                buildServerEngineAbstractionTestH2HeadersPayload(
                    headerBlockFragment
                ),
                frameType: UInt8(0x1),
                flags: UInt8(0x4),
                streamId: streamId
            ),
            buildServerEngineAbstractionTestH2FrameWire(
                serverEngineAbstractionTestByteArray(bodyText.toArray()),
                frameType: UInt8(0x0),
                flags: UInt8(0x1),
                streamId: streamId
            )
        ]),
        maxFragmentLen: 7
    )
}

func buildAcceptedTransportTlsH2TwoHeadersPlusDataRequestRecords(
    channel: ContractTlsRecordChannel,
    firstHeaderBlockFragment: Array<Byte>,
    firstStreamId: Int64,
    firstBodyText: String,
    secondHeaderBlockFragment: Array<Byte>,
    secondStreamId: Int64,
    secondBodyText: String
): Array<Array<Byte>> {
    channel.sealFragments(
        ContractTlsRecordContentType.ApplicationData,
        concatServerEngineAbstractionTestByteArrays([
            buildServerEngineAbstractionTestH2FrameWire(
                buildServerEngineAbstractionTestH2HeadersPayload(
                    firstHeaderBlockFragment
                ),
                frameType: UInt8(0x1),
                flags: UInt8(0x4),
                streamId: firstStreamId
            ),
            buildServerEngineAbstractionTestH2FrameWire(
                serverEngineAbstractionTestByteArray(firstBodyText.toArray()),
                frameType: UInt8(0x0),
                flags: UInt8(0x1),
                streamId: firstStreamId
            ),
            buildServerEngineAbstractionTestH2FrameWire(
                buildServerEngineAbstractionTestH2HeadersPayload(
                    secondHeaderBlockFragment
                ),
                frameType: UInt8(0x1),
                flags: UInt8(0x4),
                streamId: secondStreamId
            ),
            buildServerEngineAbstractionTestH2FrameWire(
                serverEngineAbstractionTestByteArray(secondBodyText.toArray()),
                frameType: UInt8(0x0),
                flags: UInt8(0x1),
                streamId: secondStreamId
            )
        ]),
        maxFragmentLen: 4096
    )
}

func runAcceptedTransportOneWaySocketClient(
    host: String,
    port: UInt16,
    requestWireFragments: Array<Array<Byte>>,
    writePauseMillis!: Int64 = 10
): Unit {
    let socket = TcpSocket(IPSocketAddress.parse("${host}:${port}"))
    socket.connect()
    try {
        var i: Int64 = 0
        while (i < requestWireFragments.size) {
            socket.write(
                serverEngineAbstractionTestUInt8Array(
                    requestWireFragments[i]
                )
            )
            if (writePauseMillis > 0 && i + 1 < requestWireFragments.size) {
                sleep(Duration.millisecond * writePauseMillis)
            }
            i += 1
        }
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

func readAcceptedTransportResponseSocketSinkWire(
    socket: TcpSocket
): Array<UInt8> {
    let out = ArrayList<UInt8>()
    let buf = Array<UInt8>(4096, repeat: 0)
    while (true) {
        let n = socket.read(buf)
        if (n <= 0) {
            break
        }
        appendAcceptedTransportResponseSocketSinkBytes(out, buf[..n])
    }
    out.toArray()
}

func appendAcceptedTransportResponseSocketSinkBytes(
    out: ArrayList<UInt8>,
    bytes: Array<UInt8>
): Unit {
    for (b in bytes) {
        out.add(b)
    }
}

func readAcceptedTransportResponseSocketFragmentedRecords(
    socket: TcpSocket,
    readChunkSize!: Int64 = 3
): Array<Array<Byte>> {
    let accumulator = JinguiAcceptedTransportRecordWireAccumulator()
    let records = ArrayList<Array<Byte>>()
    let chunkSize = if (readChunkSize > 0) {
        readChunkSize
    } else {
        3
    }
    let buf = Array<UInt8>(chunkSize, repeat: 0)
    while (true) {
        let n = socket.read(buf)
        if (n <= 0) {
            break
        }
        accumulator.append(serverEngineAbstractionTestByteArray(buf[..n]))
        appendAcceptedTransportResponseSocketFragmentedRecordBytes(
            records,
            accumulator.drainCompleteRecords()
        )
    }
    let trailing = accumulator.drainCompleteRecords()
    appendAcceptedTransportResponseSocketFragmentedRecordBytes(
        records,
        trailing
    )
    if (accumulator.bufferedByteCount() != 0) {
        throw Exception(
            "fragmented response socket client ended with incomplete TLS record bytes=${accumulator.bufferedByteCount()}"
        )
    }
    records.toArray()
}

func appendAcceptedTransportResponseSocketFragmentedRecordBytes(
    out: ArrayList<Array<Byte>>,
    records: Array<Array<Byte>>
): Unit {
    for (record in records) {
        out.add(record)
    }
}

func serverEngineAbstractionTestKeepJinguiContractLinkAnchor(): String {
    ContractErrorCode.BadInput.toString()
}

func buildServerEngineAbstractionTestTlsRecordWire(
    payload: Array<Byte>,
    contentType!: UInt8 = UInt8(0x16)
): Array<Byte> {
    if (payload.size > 0xffff) {
        throw Exception(
            "test TLS record payload exceeds single-record first-cut limit"
        )
    }
    let out = ArrayList<Byte>()
    out.add(contentType)
    out.add(UInt8(0x03))
    out.add(UInt8(0x03))
    out.add(UInt8((payload.size >> 8) & 0xff))
    out.add(UInt8(payload.size & 0xff))
    for (b in payload) {
        out.add(b)
    }
    out.toArray()
}

func serverEngineAbstractionTestByteArraysEqual(
    left: Array<Byte>,
    right: Array<Byte>
): Bool {
    if (left.size != right.size) {
        return false
    }
    var i: Int64 = 0
    while (i < left.size) {
        if (left[i] != right[i]) {
            return false
        }
        i += 1
    }
    true
}

func resolveEngineFixturePath(path: String): String {
    if (exists(path)) {
        return path
    }
    let workspacePath = "../" + path
    if (exists(workspacePath)) {
        return workspacePath
    }
    path
}

func engineIncrementalBytes(size: Int64, start!: Int64 = 0): Array<Byte> {
    let out = Array<Byte>(size, repeat: 0)
    var i = 0
    while (i < size) {
        out[i] = UInt8((start + i) & 0xff)
        i += 1
    }
    out
}

func cloneServerEngineAbstractionTestBytes(input: Array<UInt8>): Array<UInt8> {
    let out = Array<UInt8>(input.size, repeat: 0)
    var i: Int64 = 0
    while (i < input.size) {
        out[i] = input[i]
        i += 1
    }
    out
}

func serverEngineAbstractionTestByteArray(input: Array<UInt8>): Array<Byte> {
    let out = Array<Byte>(input.size, repeat: 0)
    var i: Int64 = 0
    while (i < input.size) {
        out[i] = input[i]
        i += 1
    }
    out
}

func serverEngineAbstractionTestTextBytes(text: String): Array<Byte> {
    let input = text.toArray()
    let out = Array<Byte>(input.size, repeat: 0)
    var i: Int64 = 0
    while (i < input.size) {
        out[i] = input[i]
        i += 1
    }
    out
}

func serverEngineAbstractionTestUInt8Array(input: Array<Byte>): Array<UInt8> {
    let out = Array<UInt8>(input.size, repeat: 0)
    var i: Int64 = 0
    while (i < input.size) {
        out[i] = UInt8(input[i])
        i += 1
    }
    out
}

func serverEngineAbstractionTestByteText(input: Array<Byte>): String {
    let out = Array<UInt8>(input.size, repeat: 0)
    var i: Int64 = 0
    while (i < input.size) {
        out[i] = UInt8(input[i])
        i += 1
    }
    String.fromUtf8(out)
}

func cloneServerEngineAbstractionTestByteWindow(
    input: Array<Byte>,
    start: Int64,
    size: Int64
): Array<Byte> {
    let out = Array<Byte>(size, repeat: 0)
    var i: Int64 = 0
    while (i < size) {
        out[i] = input[start + i]
        i += 1
    }
    out
}

func buildServerEngineAbstractionTestH2FrameWire(
    payload: Array<Byte>,
    frameType!: UInt8 = UInt8(0),
    flags!: UInt8 = UInt8(0),
    streamId!: Int64 = 1
): Array<Byte> {
    let out = ArrayList<Byte>()
    let payloadLen = payload.size
    out.add(UInt8((payloadLen >> 16) & 0xff))
    out.add(UInt8((payloadLen >> 8) & 0xff))
    out.add(UInt8(payloadLen & 0xff))
    out.add(frameType)
    out.add(flags)
    out.add(UInt8((streamId >> 24) & 0x7f))
    out.add(UInt8((streamId >> 16) & 0xff))
    out.add(UInt8((streamId >> 8) & 0xff))
    out.add(UInt8(streamId & 0xff))
    for (b in payload) {
        out.add(b)
    }
    out.toArray()
}

func buildServerEngineAbstractionTestH2HeadersPayload(
    headerBlockFragment: Array<Byte>,
    padded!: Bool = false,
    padLength!: Int64 = 0,
    priorityPresented!: Bool = false,
    exclusiveDependency!: Bool = false,
    streamDependency!: Int64 = 0,
    weight!: Int64 = 0
): Array<Byte> {
    let out = ArrayList<Byte>()
    if (padded) {
        out.add(UInt8(padLength & 0xff))
    }
    if (priorityPresented) {
        let exclusiveLead = if (exclusiveDependency) {
            Int64(0x80)
        } else {
            Int64(0)
        }
        out.add(
            UInt8(
                exclusiveLead +
                ((streamDependency >> 24) & 0x7f)
            )
        )
        out.add(UInt8((streamDependency >> 16) & 0xff))
        out.add(UInt8((streamDependency >> 8) & 0xff))
        out.add(UInt8(streamDependency & 0xff))
        out.add(UInt8(weight & 0xff))
    }
    for (b in headerBlockFragment) {
        out.add(b)
    }
    if (padded) {
        var i: Int64 = 0
        while (i < padLength) {
            out.add(UInt8(0))
            i += 1
        }
    }
    out.toArray()
}

func concatServerEngineAbstractionTestByteArrays(
    parts: Array<Array<Byte>>
): Array<Byte> {
    let out = ArrayList<Byte>()
    for (part in parts) {
        for (b in part) {
            out.add(b)
        }
    }
    out.toArray()
}

func serverEngineAbstractionTestByteRecords(
    input: ArrayList<Array<UInt8>>
): Array<Array<Byte>> {
    let out = ArrayList<Array<Byte>>()
    for (record in input) {
        out.add(serverEngineAbstractionTestByteArray(record))
    }
    out.toArray()
}

class CollectingResponseTransportWriter <: ResponseTransportWriter {
    public let writes: ArrayList<Array<UInt8>> = ArrayList<Array<UInt8>>()

    public override func write(data: Array<UInt8>): Unit {
        writes.add(cloneServerEngineAbstractionTestBytes(data))
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
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        lastTransportTouchpoint = option.transportTouchpoint
        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    public override func shutdown(): Unit {}
}
