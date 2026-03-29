package ignite.tests

import ignite.client.*
import stdx.net.http.HttpResponseBuilder
import std.time.MonoTime

@Test
public class ClientStreamingTestSuite {
    @TestCase
    public func testBodyBytesHandlesLargePayload(): Unit {
        let payload = makePayload(1024 * 512)
        let response = ClientResponse(
            HttpResponseBuilder()
                .status(200)
                .body(payload)
                .build()
        )

        let start = MonoTime.now()
        let bytes = response.bodyBytes()
        let elapsedMs = (MonoTime.now() - start).toMilliseconds()
        @Assert(bytes.size, payload.size)
        @Assert(bytes[0], payload[0])
        @Assert(bytes[12345], payload[12345])
        @Assert(bytes[payload.size - 1], payload[payload.size - 1])
        @Assert(elapsedMs < 2000, true)

        let cached = response.bodyBytes()
        @Assert(cached.size, payload.size)
        @Assert(cached[12345], payload[12345])
    }

    @TestCase
    public func testBodyStreamSupportsChunkedReadForLargePayload(): Unit {
        let payload = makePayload(1024 * 256)
        let expectedChecksum = checksum(payload)

        let response = ClientResponse(
            HttpResponseBuilder()
                .status(200)
                .body(payload)
                .build()
        )

        let start = MonoTime.now()
        let stream = response.bodyStream()
        let tmp = Array<UInt8>(4096, repeat: 0)
        var totalSize: Int64 = 0
        var sum: Int64 = 0
        while (true) {
            let n = stream.read(tmp)
            if (n <= 0) {
                break
            }
            totalSize += n
            for (i in 0..n) {
                sum += Int64(tmp[i])
            }
        }
        let elapsedMs = (MonoTime.now() - start).toMilliseconds()

        @Assert(totalSize, payload.size)
        @Assert(sum, expectedChecksum)
        @Assert(elapsedMs < 2000, true)
    }

    @TestCase
    public func testDiscardCanDrainLargePayload(): Unit {
        let payload = makePayload(1024 * 256)
        let response = ClientResponse(
            HttpResponseBuilder()
                .status(200)
                .body(payload)
                .build()
        )

        response.discard()
        let after = response.bodyBytes()
        @Assert(after.size, 0)
    }
}

func makePayload(size: Int64): Array<UInt8> {
    let out = Array<UInt8>(size, repeat: 0)
    var i: Int64 = 0
    while (i < size) {
        out[i] = UInt8(i % 251)
        i += 1
    }
    out
}

func checksum(data: Array<UInt8>): Int64 {
    var sum: Int64 = 0
    for (b in data) {
        sum += Int64(b)
    }
    sum
}
