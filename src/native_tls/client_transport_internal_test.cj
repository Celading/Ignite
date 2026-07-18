package ignite.native_tls

import std.collection.ArrayList
import ignite.transport.NativeByteTransport

class NativeTlsTestByteTransport <: NativeByteTransport {
    let incoming: Array<Byte>
    let maxChunk: Int64
    let written = ArrayList<Byte>()
    var offset: Int64 = 0
    var closed: Bool = false

    init(incoming: Array<Byte>, maxChunk!: Int64 = 2) {
        this.incoming = incoming
        this.maxChunk = maxChunk
    }

    public override func read(outBuf: Array<Byte>): Int64 {
        if (closed || offset >= incoming.size) {
            return 0
        }
        let remaining = incoming.size - offset
        var count = if (remaining < outBuf.size) { remaining } else { outBuf.size }
        if (count > maxChunk) {
            count = maxChunk
        }
        var i: Int64 = 0
        while (i < count) {
            outBuf[i] = incoming[offset + i]
            i += 1
        }
        offset += count
        count
    }

    public override func write(data: Array<Byte>): Unit {
        for (value in data) {
            written.add(value)
        }
    }

    public override func close(): Unit {
        closed = true
    }

    public override func isClosed(): Bool {
        closed
    }
}

@Test
public class NativeTls13ClientTransportInternalTestSuite {
    @TestCase
    public func testDefaultClientAlpnStaysOnSupportedNativeH1Slice(): Unit {
        let config = NativeTls13ClientConfig("test-anchor", "example.com")
        @Assert(config.alpnProtocols.size, Int64(1))
        @Assert(config.alpnProtocols[0], "http/1.1")
    }

    @TestCase
    public func testReadsOneFragmentedTlsRecordWithoutOverread(): Unit {
        let wire: Array<Byte> = [
            UInt8(23), UInt8(3), UInt8(3), UInt8(0), UInt8(3),
            UInt8(1), UInt8(2), UInt8(3),
            UInt8(99)
        ]
        let transport = NativeTlsTestByteTransport(wire, maxChunk: 2)
        let record = nativeTls13ReadRecord(transport)
        @Assert(record.size, Int64(8))
        @Assert(record[0], UInt8(23))
        @Assert(record[7], UInt8(3))
        @Assert(transport.offset, Int64(8))
    }

    @TestCase
    public func testRejectsOversizedTlsRecordBeforePayloadRead(): Unit {
        let wire: Array<Byte> = [
            UInt8(23), UInt8(3), UInt8(3), UInt8(0x48), UInt8(0x01)
        ]
        var rejected = false
        try {
            let _ = nativeTls13ReadRecord(NativeTlsTestByteTransport(wire))
        } catch (e: Exception) {
            rejected = e.message == "native TLS record payload exceeds bounded limit"
        }
        @Assert(rejected, true)
    }
}
