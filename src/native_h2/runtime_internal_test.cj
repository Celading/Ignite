package ignite.native_h2

import ignite.App
import std.net.{IPSocketAddress, TcpServerSocket, TcpSocket}

@Test
public class NativeH2RuntimeInternalTestSuite {
    @TestCase
    public func testResponseHeadEncodesGenericStatusAndFiltersConnectionHeaders(): Unit {
        let payload = nativeH2EncodeResponseHead(201, [
            NativeH2Header("connection", "close"),
            NativeH2Header("x-native-h2", "accepted")
        ])

        @Assert(payload[0], UInt8(0x08))
        @Assert(payload[1], UInt8(0x03))
        @Assert(String.fromUtf8(nativeH2Slice(payload, 2, 5)), "201")
        @Assert(nativeH2ContainsBytes(payload, "x-native-h2".toArray()), true)
        @Assert(nativeH2ContainsBytes(payload, "accepted".toArray()), true)
        @Assert(nativeH2ContainsBytes(payload, "connection".toArray()), false)
    }

    @TestCase
    public func testSingleStreamRuntimeCompletesRealWireTurn(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H2 test could not reserve loopback port")
        let app = App()
        app.post("/native-h2", { ctx =>
            let prefix = (
                ctx.method + ":" + ctx.path + ":" +
                (ctx.query("mode") ?? "") + ":" + ctx.bodyString()
            ).toArray()
            let responseBody = Array<UInt8>(16385, repeat: UInt8(0x78))
            var responseIndex: Int64 = 0
            while (responseIndex < prefix.size) {
                responseBody[responseIndex] = prefix[responseIndex]
                responseIndex += 1
            }
            let _ = ctx
                .setHeader("content-type", "text/plain; charset=utf-8")
                .send(responseBody)
        })
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                serveNativeH2SingleStreamApp(accepted, app, remoteAddress: "127.0.0.1")
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let client = TcpSocket("127.0.0.1", port)
        try {
            client.connect(timeout: Some(Duration.second * 2))
            client.write(NATIVE_H2_PREFACE)
            nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x4), UInt8(0), 0, Array<UInt8>()))

            let path = "/native-h2?mode=wire"
            let authority = "localhost"
            let headersPayload = Array<UInt8>(6 + authority.size + path.size, repeat: 0)
            headersPayload[0] = UInt8(0x83)
            headersPayload[1] = UInt8(0x86)
            headersPayload[2] = UInt8(0x01)
            headersPayload[3] = UInt8(authority.size)
            var i: Int64 = 0
            let authorityBytes = authority.toArray()
            while (i < authorityBytes.size) {
                headersPayload[4 + i] = authorityBytes[i]
                i += 1
            }
            let pathOffset = 4 + authorityBytes.size
            headersPayload[pathOffset] = UInt8(0x04)
            headersPayload[pathOffset + 1] = UInt8(path.size)
            i = 0
            let pathBytes = path.toArray()
            while (i < pathBytes.size) {
                headersPayload[pathOffset + 2 + i] = pathBytes[i]
                i += 1
            }
            nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x1), UInt8(0x4), 1, headersPayload))
            nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x0), UInt8(0x1), 1, "abc".toArray()))

            let serverSettings = nativeH2ReadFrame(client)
            let settingsAck = nativeH2ReadFrame(client)
            let responseHeaders = nativeH2ReadFrame(client)
            let responseDataFirst = nativeH2ReadFrame(client)
            let responseDataLast = nativeH2ReadFrame(client)

            @Assert(serverSettings.frameType, UInt8(0x4))
            @Assert(serverSettings.flags, UInt8(0))
            @Assert(settingsAck.frameType, UInt8(0x4))
            @Assert(settingsAck.flags, UInt8(0x1))
            @Assert(responseHeaders.frameType, UInt8(0x1))
            @Assert(responseHeaders.flags, UInt8(0x4))
            @Assert(responseHeaders.streamId, 1)
            @Assert(responseHeaders.payload.size > 1, true)
            @Assert(responseHeaders.payload[0], UInt8(0x88))
            @Assert(nativeH2ContainsBytes(responseHeaders.payload, "content-type".toArray()), true)
            @Assert(nativeH2ContainsBytes(responseHeaders.payload, "text/plain; charset=utf-8".toArray()), true)
            @Assert(responseDataFirst.frameType, UInt8(0x0))
            @Assert(responseDataFirst.flags, UInt8(0))
            @Assert(responseDataFirst.streamId, 1)
            @Assert(responseDataFirst.payload.size, 16384)
            @Assert(
                String.fromUtf8(nativeH2Slice(responseDataFirst.payload, 0, 24)),
                "POST:/native-h2:wire:abc"
            )
            @Assert(responseDataLast.frameType, UInt8(0x0))
            @Assert(responseDataLast.flags, UInt8(0x1))
            @Assert(responseDataLast.streamId, 1)
            @Assert(responseDataLast.payload.size, 1)
            @Assert(responseDataLast.payload[0], UInt8(0x78))
        } finally {
            try { client.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
            let _ = serverFuture.get(Duration.second * 2)
        }
    }

    @TestCase
    public func testConnectionKeepsInterleavedStreamsIndependent(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H2 multiplex test could not reserve loopback port")
        let app = App()
        app.post("/mux/one", { ctx =>
            let _ = ctx.sendString("one:" + ctx.bodyString())
        })
        app.post("/mux/two", { ctx =>
            let _ = ctx.sendString("two:" + ctx.bodyString())
        })
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                serveNativeH2AppConnection(
                    accepted,
                    app,
                    remoteAddress: "127.0.0.1",
                    maxCompletedStreams: 2
                )
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let client = TcpSocket("127.0.0.1", port)
        try {
            client.connect(timeout: Some(Duration.second * 2))
            client.write(NATIVE_H2_PREFACE)
            nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x4), UInt8(0), 0, Array<UInt8>()))
            nativeH2WriteFrame(
                client,
                NativeH2Frame(UInt8(0x1), UInt8(0x4), 1, nativeH2TestRequestHeaders("/mux/one"))
            )
            nativeH2WriteFrame(
                client,
                NativeH2Frame(UInt8(0x1), UInt8(0x4), 3, nativeH2TestRequestHeaders("/mux/two"))
            )
            nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x0), UInt8(0x1), 3, "B".toArray()))
            nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x0), UInt8(0x1), 1, "A".toArray()))

            let serverSettings = nativeH2ReadFrame(client)
            let settingsAck = nativeH2ReadFrame(client)
            let streamThreeHeaders = nativeH2ReadFrame(client)
            let streamThreeData = nativeH2ReadFrame(client)
            let streamOneHeaders = nativeH2ReadFrame(client)
            let streamOneData = nativeH2ReadFrame(client)

            @Assert(serverSettings.frameType, UInt8(0x4))
            @Assert(settingsAck.flags, UInt8(0x1))
            @Assert(streamThreeHeaders.streamId, 3)
            @Assert(streamThreeData.streamId, 3)
            @Assert(String.fromUtf8(streamThreeData.payload), "two:B")
            @Assert(streamOneHeaders.streamId, 1)
            @Assert(streamOneData.streamId, 1)
            @Assert(String.fromUtf8(streamOneData.payload), "one:A")
        } finally {
            try { client.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
            let _ = serverFuture.get(Duration.second * 2)
        }
    }

    @TestCase
    public func testLargeResponseResumesAfterConnectionAndStreamWindowUpdate(): Unit {
        let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
        listener.bind()
        let port = (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("native H2 flow test could not reserve loopback port")
        let app = App()
        app.get("/large", { ctx =>
            let _ = ctx.send(Array<UInt8>(70000, repeat: UInt8(0x7a)))
        })
        let serverFuture = spawn {
            let accepted = listener.accept()
            try {
                serveNativeH2AppConnection(
                    accepted,
                    app,
                    remoteAddress: "127.0.0.1",
                    maxCompletedStreams: 1
                )
            } finally {
                try { accepted.close() } catch (_: Exception) {}
            }
        }

        let client = TcpSocket("127.0.0.1", port)
        try {
            client.connect(timeout: Some(Duration.second * 2))
            client.write(NATIVE_H2_PREFACE)
            nativeH2WriteFrame(client, NativeH2Frame(UInt8(0x4), UInt8(0), 0, Array<UInt8>()))
            let getHeaders = nativeH2TestRequestHeaders("/large")
            getHeaders[0] = UInt8(0x82)
            nativeH2WriteFrame(
                client,
                NativeH2Frame(UInt8(0x1), UInt8(0x5), 1, getHeaders)
            )

            let serverSettings = nativeH2ReadFrame(client)
            let settingsAck = nativeH2ReadFrame(client)
            let responseHeaders = nativeH2ReadFrame(client)
            var receivedBeforeUpdate: Int64 = 0
            var sawEarlyEndStream = false
            var i: Int64 = 0
            while (i < 4) {
                let data = nativeH2ReadFrame(client)
                receivedBeforeUpdate += data.payload.size
                if ((data.flags & UInt8(0x1)) != UInt8(0)) {
                    sawEarlyEndStream = true
                }
                i += 1
            }

            @Assert(serverSettings.frameType, UInt8(0x4))
            @Assert(settingsAck.flags, UInt8(0x1))
            @Assert(responseHeaders.streamId, 1)
            @Assert(receivedBeforeUpdate, NATIVE_H2_INITIAL_FLOW_WINDOW)
            @Assert(sawEarlyEndStream, false)

            nativeH2WriteFrame(client, nativeH2TestWindowUpdate(0, 10000))
            nativeH2WriteFrame(client, nativeH2TestWindowUpdate(1, 10000))
            let finalData = nativeH2ReadFrame(client)
            @Assert(finalData.streamId, 1)
            @Assert(finalData.payload.size, 4465)
            @Assert(finalData.flags, UInt8(0x1))
        } finally {
            try { client.close() } catch (_: Exception) {}
            try { listener.close() } catch (_: Exception) {}
            let _ = serverFuture.get(Duration.second * 2)
        }
    }
}

func nativeH2TestWindowUpdate(streamId: Int64, increment: Int64): NativeH2Frame {
    let payload = Array<UInt8>(4, repeat: 0)
    payload[0] = UInt8((increment >> 24) & 0x7f)
    payload[1] = UInt8((increment >> 16) & 0xff)
    payload[2] = UInt8((increment >> 8) & 0xff)
    payload[3] = UInt8(increment & 0xff)
    NativeH2Frame(UInt8(0x8), UInt8(0), streamId, payload)
}

func nativeH2TestRequestHeaders(path: String): Array<UInt8> {
    let authority = "localhost"
    let payload = Array<UInt8>(6 + authority.size + path.size, repeat: 0)
    payload[0] = UInt8(0x83)
    payload[1] = UInt8(0x86)
    payload[2] = UInt8(0x01)
    payload[3] = UInt8(authority.size)
    let authorityBytes = authority.toArray()
    var i: Int64 = 0
    while (i < authorityBytes.size) {
        payload[4 + i] = authorityBytes[i]
        i += 1
    }
    let pathOffset = 4 + authorityBytes.size
    payload[pathOffset] = UInt8(0x04)
    payload[pathOffset + 1] = UInt8(path.size)
    let pathBytes = path.toArray()
    i = 0
    while (i < pathBytes.size) {
        payload[pathOffset + 2 + i] = pathBytes[i]
        i += 1
    }
    payload
}

func nativeH2ContainsBytes(input: Array<UInt8>, target: Array<UInt8>): Bool {
    if (target.size == 0) {
        return true
    }
    if (input.size < target.size) {
        return false
    }
    var start: Int64 = 0
    while (start <= input.size - target.size) {
        var matched = true
        var i: Int64 = 0
        while (i < target.size) {
            if (input[start + i] != target[i]) {
                matched = false
                break
            }
            i += 1
        }
        if (matched) {
            return true
        }
        start += 1
    }
    false
}
