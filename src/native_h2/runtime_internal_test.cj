package ignite.native_h2

import ignite.App
import std.net.{IPSocketAddress, TcpServerSocket, TcpSocket}

@Test
public class NativeH2RuntimeInternalTestSuite {
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
