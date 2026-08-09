package ignite.native_h2

import ignite.{App, Config}
import std.collection.ArrayList
import std.io.InputStream
import std.net.{IPSocketAddress, TcpServerSocket, TcpSocket}
import std.sync.AtomicInt64

class NativeH2ServerStreamingProbeInputStream <: InputStream & Resource {
    let totalBytes: Int64
    let marker: Byte
    var offset: Int64 = 0
    var readCalls: Int64 = 0
    var largestReadBuffer: Int64 = 0
    var closed = false

    init(totalBytes: Int64, marker: Byte) {
        this.totalBytes = totalBytes
        this.marker = marker
    }

    public override func read(outBuf: Array<Byte>): Int64 {
        if (closed || offset >= totalBytes || outBuf.size == 0) {
            return 0
        }
        readCalls += 1
        if (outBuf.size > largestReadBuffer) {
            largestReadBuffer = outBuf.size
        }
        let remaining = totalBytes - offset
        let count = if (remaining < outBuf.size) { remaining } else { outBuf.size }
        var i: Int64 = 0
        while (i < count) {
            outBuf[i] = marker
            i += 1
        }
        offset += count
        count
    }

    public func close(): Unit {
        closed = true
    }

    public func isClosed(): Bool {
        closed
    }
}

@Test
public class NativeH2ServerStreamingInternalTestSuite {
    @TestCase
    public func testAppJsonWriteHeadDoesNotStartBoundedProducer(): Unit {
        let producerRuns = AtomicInt64(0)
        let app = App(config: Config(enableNetworkChangeNotice: false))
        app.head("/json-write-head", { ctx =>
            let _ = ctx.jsonWrite({ writer =>
                let _ = producerRuns.fetchAdd(1)
                writer.startObject()
                writer.writeName("unexpected")
                writer.writeValue(true)
                writer.endObject()
            })
        })
        let (listener, client, serverFuture) = startNativeH2AppStreamingFixture(app)
        try {
            let connection = NativeH2ClientConnection(client)
            let response = connection.sendStreamed(
                NativeH2ClientRequest("HEAD", "http", "localhost", "/json-write-head")
            )
            @Assert(response.status, UInt16(200))
            @Assert(
                response.header("content-type") ?? "",
                "application/json; charset=utf-8"
            )
            let body = Array<Byte>(1, repeat: 0)
            @Assert(response.bodyStream().read(body), Int64(0))
            @Assert(producerRuns.load(), Int64(0))
            connection.finish()
            let _ = serverFuture.get(Duration.second * 3)
        } finally {
            closeNativeH2StreamingFixture(listener, client)
        }
    }

    @TestCase
    public func testAppJsonWriteUsesBoundedH2StreamInsteadOfWholeBodyAggregation(): Unit {
        let producedItems = AtomicInt64(0)
        let itemCount: Int64 = 40
        let itemSize: Int64 = 4096
        let itemBytes = Array<UInt8>(itemSize, repeat: UInt8(0x78))
        let item = String.fromUtf8(itemBytes)
        let app = App(config: Config(enableNetworkChangeNotice: false))
        app.get("/json-write", { ctx =>
            let _ = ctx.jsonWrite({ writer =>
                writer.startArray()
                var index: Int64 = 0
                while (index < itemCount) {
                    writer.writeValue(item)
                    let _ = producedItems.fetchAdd(1)
                    index += 1
                }
                writer.endArray()
            })
        })
        let (listener, client, serverFuture) = startNativeH2AppStreamingFixture(app)
        try {
            let connection = NativeH2ClientConnection(client)
            let response = connection.sendStreamed(
                NativeH2ClientRequest("GET", "http", "localhost", "/json-write")
            )
            @Assert(response.status, UInt16(200))
            @Assert(
                response.header("content-type") ?? "",
                "application/json; charset=utf-8"
            )
            @Assert(response.header("transfer-encoding") ?? "", "")
            waitForNativeH2JsonProducer(producedItems)
            @Assert(producedItems.load() < itemCount, true)

            let received = ArrayList<UInt8>()
            let chunk = Array<Byte>(4096, repeat: 0)
            while (true) {
                let count = response.bodyStream().read(chunk)
                if (count <= 0) {
                    break
                }
                var i: Int64 = 0
                while (i < count) {
                    received.add(UInt8(chunk[i]))
                    i += 1
                }
            }
            assertNativeH2RepeatedJsonArray(received.toArray(), itemCount, itemSize)
            @Assert(producedItems.load(), itemCount)
            connection.finish()
            let _ = serverFuture.get(Duration.second * 3)
        } finally {
            closeNativeH2StreamingFixture(listener, client)
        }
    }

    @TestCase
    public func testAppSendStreamAdvancesUnderFlowControlWithoutWholeBodyAggregation(): Unit {
        let probe = NativeH2ServerStreamingProbeInputStream(70000, UInt8(0x73))
        let (listener, client, serverFuture) = startNativeH2StreamingFixture(probe)
        try {
            let connection = NativeH2ClientConnection(client)
            let response = connection.sendStreamed(
                NativeH2ClientRequest("GET", "http", "localhost", "/stream")
            )
            @Assert(response.status, UInt16(200))
            @Assert(response.header("content-length") ?? "", "70000")

            let first = Array<Byte>(1024, repeat: 0)
            let firstCount = response.bodyStream().read(first)
            @Assert(firstCount > 0, true)
            @Assert(probe.offset < probe.totalBytes, true)

            var received = firstCount
            let chunk = Array<Byte>(4096, repeat: 0)
            while (true) {
                let count = response.bodyStream().read(chunk)
                if (count <= 0) {
                    break
                }
                var i: Int64 = 0
                while (i < count) {
                    @Assert(chunk[i], UInt8(0x73))
                    i += 1
                }
                received += count
            }
            @Assert(received, Int64(70000))
            @Assert(probe.readCalls > 1, true)
            @Assert(probe.largestReadBuffer <= 16384, true)
            @Assert(probe.closed, true)
            connection.finish()
            let _ = serverFuture.get(Duration.second * 3)
        } finally {
            closeNativeH2StreamingFixture(listener, client)
        }
    }

    @TestCase
    public func testClientCancellationClosesServerResponseStream(): Unit {
        let probe = NativeH2ServerStreamingProbeInputStream(256 * 1024, UInt8(0x63))
        let (listener, client, serverFuture) = startNativeH2StreamingFixture(probe)
        try {
            let connection = NativeH2ClientConnection(client)
            let response = connection.sendStreamed(
                NativeH2ClientRequest("GET", "http", "localhost", "/stream")
            )
            let first = Array<Byte>(1024, repeat: 0)
            @Assert(response.bodyStream().read(first) > 0, true)
            response.close()
            connection.finish()
            let _ = serverFuture.get(Duration.second * 3)
            @Assert(probe.closed, true)
            @Assert(probe.offset < probe.totalBytes, true)
        } finally {
            closeNativeH2StreamingFixture(listener, client)
        }
    }
}

func startNativeH2AppStreamingFixture(
    app: App
): (TcpServerSocket, TcpSocket, Future<Unit>) {
    let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
    listener.bind()
    let port = (listener.localAddress as IPSocketAddress)?.port ??
        throw Exception("native H2 app streaming test could not reserve loopback port")
    let serverFuture = spawn {
        let accepted = listener.accept()
        accepted.readTimeout = Some(Duration.second * 3)
        accepted.writeTimeout = Some(Duration.second * 3)
        try {
            serveNativeH2AppConnection(
                accepted,
                app,
                remoteAddress: "127.0.0.1"
            )
        } finally {
            try { accepted.close() } catch (_: Exception) {}
        }
    }
    let client = TcpSocket("127.0.0.1", port)
    client.connect(timeout: Some(Duration.second * 2))
    client.readTimeout = Some(Duration.second * 3)
    client.writeTimeout = Some(Duration.second * 3)
    (listener, client, serverFuture)
}

func waitForNativeH2JsonProducer(producedItems: AtomicInt64): Unit {
    for (_ in 0..500) {
        if (producedItems.load() > 0) {
            return
        }
        sleep(Duration.millisecond)
    }
    throw Exception("native H2 jsonWrite producer did not start")
}

func assertNativeH2RepeatedJsonArray(
    body: Array<UInt8>,
    itemCount: Int64,
    itemSize: Int64
): Unit {
    let expectedSize = 2 + itemCount * (itemSize + 2) + (itemCount - 1)
    @Assert(body.size, expectedSize)
    var cursor: Int64 = 0
    @Assert(body[cursor], UInt8(0x5b))
    cursor += 1
    var itemIndex: Int64 = 0
    while (itemIndex < itemCount) {
        @Assert(body[cursor], UInt8(0x22))
        cursor += 1
        var byteIndex: Int64 = 0
        while (byteIndex < itemSize) {
            @Assert(body[cursor], UInt8(0x78))
            cursor += 1
            byteIndex += 1
        }
        @Assert(body[cursor], UInt8(0x22))
        cursor += 1
        if (itemIndex + 1 < itemCount) {
            @Assert(body[cursor], UInt8(0x2c))
            cursor += 1
        }
        itemIndex += 1
    }
    @Assert(body[cursor], UInt8(0x5d))
    @Assert(cursor + 1, body.size)
}

func startNativeH2StreamingFixture(
    probe: NativeH2ServerStreamingProbeInputStream
): (TcpServerSocket, TcpSocket, Future<Unit>) {
    let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
    listener.bind()
    let port = (listener.localAddress as IPSocketAddress)?.port ??
        throw Exception("native H2 streaming test could not reserve loopback port")
    let app = App(config: Config(enableNetworkChangeNotice: false))
    app.get("/stream", { ctx =>
        let _ = ctx.sendStream(
            probe,
            contentType: "application/octet-stream",
            contentLength: Some(probe.totalBytes)
        )
    })
    let serverFuture = spawn {
        let accepted = listener.accept()
        accepted.readTimeout = Some(Duration.second * 3)
        accepted.writeTimeout = Some(Duration.second * 3)
        try {
            serveNativeH2AppConnection(
                accepted,
                app,
                remoteAddress: "127.0.0.1"
            )
        } finally {
            try { accepted.close() } catch (_: Exception) {}
        }
    }
    let client = TcpSocket("127.0.0.1", port)
    client.connect(timeout: Some(Duration.second * 2))
    client.readTimeout = Some(Duration.second * 3)
    client.writeTimeout = Some(Duration.second * 3)
    (listener, client, serverFuture)
}

func closeNativeH2StreamingFixture(
    listener: TcpServerSocket,
    client: TcpSocket
): Unit {
    try { client.close() } catch (_: Exception) {}
    try { listener.close() } catch (_: Exception) {}
}
