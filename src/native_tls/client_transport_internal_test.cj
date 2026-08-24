package ignite.native_tls

import std.collection.ArrayList
import ignite.transport.{NativeByteTransport, NativeReadTimeoutControl}
import jinguissl.live.{
    ContractTls13ApplicationKeyMaterial,
    ContractTlsRecordContentType,
    contractTls13CreateClientRecordChannel,
    contractTls13CreateServerRecordChannel
}

class NativeTlsTestByteTransport <: NativeByteTransport & NativeReadTimeoutControl {
    let incoming: Array<Byte>
    let maxChunk: Int64
    let written = ArrayList<Byte>()
    var offset: Int64 = 0
    var closed: Bool = false
    var readTimeout: ?Duration = None

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

    public override func currentReadTimeout(): ?Duration {
        readTimeout
    }

    public override func updateReadTimeout(value: ?Duration): Unit {
        readTimeout = value
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

    @TestCase
    public func testWritesH2MaximumFrameAcrossBoundedTlsRecords(): Unit {
        let keyMaterial = ContractTls13ApplicationKeyMaterial(
            Array<Byte>(32, repeat: UInt8(0x11)),
            Array<Byte>(12, repeat: UInt8(0x22)),
            Array<Byte>(32, repeat: UInt8(0x33)),
            Array<Byte>(12, repeat: UInt8(0x44))
        )
        let clientChannel = contractTls13CreateClientRecordChannel(keyMaterial)
        let serverChannel = contractTls13CreateServerRecordChannel(keyMaterial)
        let raw = NativeTlsTestByteTransport([])
        let transport = NativeTls13ClientTransport(raw, clientChannel)
        let payload = Array<Byte>(16393, repeat: UInt8(0x5a))

        transport.write(payload)

        let wire = NativeTlsTestByteTransport(raw.written.toArray(), maxChunk: 257)
        let first = serverChannel.open(nativeTls13ReadRecord(wire))
        let second = serverChannel.open(nativeTls13ReadRecord(wire))
        @Assert(first.contentType, ContractTlsRecordContentType.ApplicationData)
        @Assert(second.contentType, ContractTlsRecordContentType.ApplicationData)
        @Assert(first.fragment.size, Int64(16383))
        @Assert(second.fragment.size, Int64(10))
        @Assert(wire.offset, raw.written.size)
        @Assert(first.fragment[0], UInt8(0x5a))
        @Assert(first.fragment[16382], UInt8(0x5a))
        @Assert(second.fragment[0], UInt8(0x5a))
        @Assert(second.fragment[9], UInt8(0x5a))
    }
}
