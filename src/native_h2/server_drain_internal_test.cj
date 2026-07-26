package ignite.native_h2

import ignite.{App, Config}
import std.net.{IPSocketAddress, TcpServerSocket, TcpSocket}
import std.sync.AtomicBool

@Test
public class NativeH2ServerDrainInternalTestSuite {
    @TestCase
    public func testDrainKeepsAcceptedStreamAndRefusesFollowingStream(): Unit {
        let probe = NativeH2ServerStreamingProbeInputStream(70000, UInt8(0x64))
        let control = NativeH2ConnectionControl()
        let (listener, client, serverFuture) = startNativeH2DrainStreamingFixture(
            probe,
            control
        )
        try {
            writeNativeH2DrainHandshakeAndRequest(client, 1, "/drain")
            waitForNativeH2DrainProbe(probe)
            control.requestDrain(timeout: Duration.second * 2)

            var received: Int64 = 0
            var sawGoAway = false
            while (!sawGoAway) {
                let frame = nativeH2ReadFrame(client)
                if (frame.frameType == UInt8(0x0) && frame.streamId == 1) {
                    received += frame.payload.size
                } else if (frame.frameType == UInt8(0x7)) {
                    @Assert(frame.streamId, Int64(0))
                    @Assert(nativeH2DrainGoAwayLastStreamId(frame), Int64(1))
                    sawGoAway = true
                }
            }

            nativeH2WriteFrame(
                client,
                NativeH2Frame(
                    UInt8(0x1), UInt8(0x5), 3,
                    nativeH2TestRequestHeaders("/must-refuse")
                )
            )
            let refused = nativeH2ReadFrame(client)
            @Assert(refused.frameType, UInt8(0x3))
            @Assert(refused.streamId, Int64(3))
            @Assert(
                nativeH2ClientDecode32Bit(refused.payload, 0),
                NATIVE_H2_ERROR_REFUSED_STREAM
            )

            nativeH2WriteFrame(client, nativeH2TestWindowUpdate(0, 70000))
            nativeH2WriteFrame(client, nativeH2TestWindowUpdate(1, 70000))
            var ended = false
            while (!ended) {
                let frame = nativeH2ReadFrame(client)
                if (frame.frameType == UInt8(0x0) && frame.streamId == 1) {
                    received += frame.payload.size
                    ended = (frame.flags & UInt8(0x1)) != UInt8(0)
                }
            }
            @Assert(received, Int64(70000))
            let _ = serverFuture.get(Duration.second * 3)
            @Assert(probe.closed, true)
            @Assert(control.awaitDrained(timeout: Duration.second), true)
            @Assert(control.activeConnectionCount(), Int64(0))
        } finally {
            closeNativeH2DrainFixture(listener, client)
        }
    }

    @TestCase
    public func testDrainDeadlineCancelsPendingHandlerAndSettlesConnection(): Unit {
        let handlerStarted = AtomicBool(false)
        let control = NativeH2ConnectionControl()
        let (listener, client, serverFuture) = startNativeH2DrainDeadlineFixture(
            handlerStarted,
            control
        )
        try {
            writeNativeH2DrainHandshakeAndRequest(client, 1, "/slow-drain")
            var attempts: Int64 = 0
            while (!handlerStarted.load() && attempts < 200) {
                sleep(Duration.millisecond * 5)
                attempts += 1
            }
            @Assert(handlerStarted.load(), true)
            control.requestDrain(timeout: Duration.millisecond * 50)

            let goAway = nativeH2ReadFrame(client)
            @Assert(goAway.frameType, UInt8(0x7))
            @Assert(nativeH2DrainGoAwayLastStreamId(goAway), Int64(1))
            let _ = serverFuture.get(Duration.second * 2)
            @Assert(control.awaitDrained(timeout: Duration.second), true)
            @Assert(control.activeConnectionCount(), Int64(0))
        } finally {
            closeNativeH2DrainFixture(listener, client)
        }
    }
}

func startNativeH2DrainStreamingFixture(
    probe: NativeH2ServerStreamingProbeInputStream,
    control: NativeH2ConnectionControl
): (TcpServerSocket, TcpSocket, Future<Unit>) {
    let listener = nativeH2DrainListener()
    let app = App(config: Config(enableNetworkChangeNotice: false))
    app.get("/drain", { ctx =>
        let _ = ctx.sendStream(
            probe,
            contentType: "application/octet-stream",
            contentLength: Some(probe.totalBytes)
        )
    })
    let serverFuture = nativeH2DrainServerFuture(listener, app, control)
    let client = nativeH2DrainClient(listener)
    (listener, client, serverFuture)
}

func startNativeH2DrainDeadlineFixture(
    handlerStarted: AtomicBool,
    control: NativeH2ConnectionControl
): (TcpServerSocket, TcpSocket, Future<Unit>) {
    let listener = nativeH2DrainListener()
    let app = App(config: Config(enableNetworkChangeNotice: false))
    app.get("/slow-drain", { ctx =>
        handlerStarted.store(true)
        sleep(Duration.millisecond * 500)
        let _ = ctx.sendString("too-late")
    })
    let serverFuture = nativeH2DrainServerFuture(listener, app, control)
    let client = nativeH2DrainClient(listener)
    (listener, client, serverFuture)
}

func nativeH2DrainListener(): TcpServerSocket {
    let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
    listener.bind()
    listener
}

func nativeH2DrainClient(listener: TcpServerSocket): TcpSocket {
    let port = (listener.localAddress as IPSocketAddress)?.port ??
        throw Exception("native H2 drain test could not reserve loopback port")
    let client = TcpSocket("127.0.0.1", port)
    client.connect(timeout: Some(Duration.second * 2))
    client.readTimeout = Some(Duration.second * 3)
    client.writeTimeout = Some(Duration.second * 3)
    client
}

func nativeH2DrainServerFuture(
    listener: TcpServerSocket,
    app: App,
    control: NativeH2ConnectionControl
): Future<Unit> {
    spawn {
        let accepted = listener.accept()
        accepted.readTimeout = Some(Duration.second * 3)
        accepted.writeTimeout = Some(Duration.second * 3)
        try {
            serveNativeH2AppConnection(
                accepted,
                app,
                remoteAddress: "127.0.0.1",
                control: control
            )
        } finally {
            try { accepted.close() } catch (_: Exception) {}
        }
    }
}

func writeNativeH2DrainHandshakeAndRequest(
    client: TcpSocket,
    streamId: Int64,
    path: String
): Unit {
    client.write(NATIVE_H2_PREFACE)
    nativeH2WriteFrame(
        client,
        NativeH2Frame(UInt8(0x4), UInt8(0), 0, Array<UInt8>())
    )
    nativeH2WriteFrame(
        client,
        NativeH2Frame(
            UInt8(0x1), UInt8(0x5), streamId,
            nativeH2TestRequestHeadersForMethod(path, "GET")
        )
    )
    let settings = nativeH2ReadFrame(client)
    let settingsAck = nativeH2ReadFrame(client)
    @Assert(settings.frameType, UInt8(0x4))
    @Assert(settingsAck.frameType, UInt8(0x4))
    @Assert(settingsAck.flags & UInt8(0x1), UInt8(0x1))
}

func waitForNativeH2DrainProbe(probe: NativeH2ServerStreamingProbeInputStream): Unit {
    var attempts: Int64 = 0
    while (probe.readCalls == 0 && attempts < 200) {
        sleep(Duration.millisecond * 5)
        attempts += 1
    }
    @Assert(probe.readCalls > 0, true)
}

func nativeH2DrainGoAwayLastStreamId(frame: NativeH2Frame): Int64 {
    if (frame.payload.size < 8) {
        throw Exception("native H2 drain GOAWAY payload is truncated")
    }
    nativeH2ClientDecode32Bit(frame.payload, 0) & Int64(0x7fffffff)
}

func closeNativeH2DrainFixture(
    listener: TcpServerSocket,
    client: TcpSocket
): Unit {
    try { client.close() } catch (_: Exception) {}
    try { listener.close() } catch (_: Exception) {}
}
