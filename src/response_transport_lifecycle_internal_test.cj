package ignite

import std.collection.ArrayList

@Test
public class ResponseTransportLifecycleInternalTestSuite {
    @TestCase
    public func testLifecycleSinkPreservesFlushCloseAndRejectsLaterWrites(): Unit {
        let events = ArrayList<String>()
        let writer = openLifecycleSinkBackedResponseTransportWriter(
            {bytes => events.add("write:${String.fromUtf8(bytes)}")},
            {=> events.add("flush")},
            {=> events.add("close")}
        )

        writer.write("body".toArray())
        flushResponseTransportWriter(writer)
        closeResponseTransportWriter(writer)
        closeResponseTransportWriter(writer)

        var rejected = false
        try {
            writer.write("late".toArray())
        } catch (_: Exception) {
            rejected = true
        }

        @Assert(events.size, Int64(3))
        @Assert(events[0], "write:body")
        @Assert(events[1], "flush")
        @Assert(events[2], "close")
        @Assert(rejected, true)
    }

    @TestCase
    public func testTransformLifecycleForwardsDownstreamInOrder(): Unit {
        let events = ArrayList<String>()
        let downstream = openLifecycleSinkBackedResponseTransportWriter(
            {bytes => events.add("write:${String.fromUtf8(bytes)}")},
            {=> events.add("flush")},
            {=> events.add("close")}
        )
        let transformed = wrapResponseTransportWriter(downstream, {
            bytes => [bytes, "!".toArray()]
        })

        transformed.write("body".toArray())
        flushResponseTransportWriter(transformed)
        closeResponseTransportWriter(transformed)

        @Assert(events.size, Int64(4))
        @Assert(events[0], "write:body")
        @Assert(events[1], "write:!")
        @Assert(events[2], "flush")
        @Assert(events[3], "close")
    }

    @TestCase
    public func testStatefulTransformEmitsFlushAndCloseOutputInOrder(): Unit {
        let events = ArrayList<String>()
        let downstream = openLifecycleSinkBackedResponseTransportWriter(
            {bytes => events.add("write:${String.fromUtf8(bytes)}")},
            {=> events.add("flush")},
            {=> events.add("close")}
        )
        let transformed = openTransformingResponseTransportWriter(
            downstream,
            CountingResponseTransportTransform()
        )

        transformed.write("one".toArray())
        flushResponseTransportWriter(transformed)
        transformed.write("two".toArray())
        closeResponseTransportWriter(transformed)
        closeResponseTransportWriter(transformed)

        var rejected = false
        try {
            transformed.write("late".toArray())
        } catch (_: Exception) {
            rejected = true
        }

        @Assert(events.size, Int64(6))
        @Assert(events[0], "write:w1:one")
        @Assert(events[1], "write:f1")
        @Assert(events[2], "flush")
        @Assert(events[3], "write:w2:two")
        @Assert(events[4], "write:c2")
        @Assert(events[5], "close")
        @Assert(rejected, true)
    }

    @TestCase
    public func testTransformFactoriesComposeInOnionOrderAndStayFresh(): Unit {
        let factoryEvents = ArrayList<String>()
        let factories = ArrayList<ResponseTransportTransformFactory>()
        factories.add({=>
            factoryEvents.add("outer")
            LabelResponseTransportTransform("outer")
        })
        factories.add({=>
            factoryEvents.add("inner")
            LabelResponseTransportTransform("inner")
        })

        for (_ in 0..2) {
            let events = ArrayList<String>()
            let downstream = openLifecycleSinkBackedResponseTransportWriter(
                {bytes => events.add("write:${String.fromUtf8(bytes)}")},
                {=> events.add("flush")},
                {=> events.add("close")}
            )
            let writer = openComposedResponseTransportWriter(downstream, factories)

            writer.write("body".toArray())
            flushResponseTransportWriter(writer)
            closeResponseTransportWriter(writer)

            @Assert(events.size, Int64(7))
            @Assert(events[0], "write:outer[inner[body]]")
            @Assert(events[1], "write:outer[inner-flush]")
            @Assert(events[2], "write:outer-flush")
            @Assert(events[3], "flush")
            @Assert(events[4], "write:outer[inner-close]")
            @Assert(events[5], "write:outer-close")
            @Assert(events[6], "close")
        }

        @Assert(factoryEvents.size, Int64(4))
        @Assert(factoryEvents[0], "outer")
        @Assert(factoryEvents[1], "inner")
        @Assert(factoryEvents[2], "outer")
        @Assert(factoryEvents[3], "inner")
    }

    @TestCase
    public func testTransformCloseStillClosesDownstreamWhenFinalOutputFails(): Unit {
        let events = ArrayList<String>()
        let downstream = openLifecycleSinkBackedResponseTransportWriter(
            {bytes =>
                events.add("write:${String.fromUtf8(bytes)}")
                throw Exception("tail write failed")
            },
            {=> events.add("flush")},
            {=> events.add("close")}
        )
        let transformed = openTransformingResponseTransportWriter(
            downstream,
            CloseOnlyResponseTransportTransform()
        )

        var rejected = false
        try {
            closeResponseTransportWriter(transformed)
        } catch (_: Exception) {
            rejected = true
        }

        @Assert(rejected, true)
        @Assert(events.size, Int64(2))
        @Assert(events[0], "write:tail")
        @Assert(events[1], "close")
    }

    @TestCase
    public func testOutputStreamCloseFlushesOnceAndReportsClosed(): Unit {
        let events = ArrayList<String>()
        let writer = openLifecycleSinkBackedResponseTransportWriter(
            {_ => ()},
            {=> events.add("flush")},
            {=> events.add("close")}
        )
        let output = ResponseTransportOutputStream(writer)
        output.write(responseTransportLifecycleBytes("body".toArray()))
        output.close()
        output.close()

        @Assert(output.isClosed(), true)
        @Assert(events.size, Int64(2))
        @Assert(events[0], "flush")
        @Assert(events[1], "close")
    }

    @TestCase
    public func testOutputStreamCloseStillFinalizesWhenFlushFails(): Unit {
        let events = ArrayList<String>()
        let writer = openLifecycleSinkBackedResponseTransportWriter(
            {_ => ()},
            {=>
                events.add("flush")
                throw Exception("flush failed")
            },
            {=> events.add("close")}
        )
        let output = ResponseTransportOutputStream(writer)

        var rejected = false
        try {
            output.close()
        } catch (_: Exception) {
            rejected = true
        }

        @Assert(rejected, true)
        @Assert(output.isClosed(), true)
        @Assert(events.size, Int64(2))
        @Assert(events[0], "flush")
        @Assert(events[1], "close")
    }

    @TestCase
    public func testDiscardingWriterHasLifecycleAndClosedWriteGuard(): Unit {
        let writer = openDiscardingResponseTransportWriter()
        flushResponseTransportWriter(writer)
        closeResponseTransportWriter(writer)

        var rejected = false
        try {
            writer.write("discarded".toArray())
        } catch (_: Exception) {
            rejected = true
        }
        @Assert(rejected, true)
    }

    @TestCase
    public func testResponseWriterCloseFlushesAndRejectsLaterWrites(): Unit {
        let events = ArrayList<String>()
        let transport = openLifecycleSinkBackedResponseTransportWriter(
            {bytes => events.add("write:${String.fromUtf8(bytes)}")},
            {=> events.add("flush")},
            {=> events.add("close")}
        )
        let writer = ResponseWriter(transport)

        writer.writeString("body")
        writer.close()
        writer.close()

        var rejected = false
        try {
            writer.writeString("late")
        } catch (_: Exception) {
            rejected = true
        }

        @Assert(events.size, Int64(3))
        @Assert(events[0], "write:body")
        @Assert(events[1], "flush")
        @Assert(events[2], "close")
        @Assert(rejected, true)
    }
}

class CountingResponseTransportTransform <: ResponseTransportTransform {
    var writes: Int64 = 0

    public override func transformWrite(data: Array<UInt8>): Array<Array<UInt8>> {
        writes += 1
        [("w${writes}:" + String.fromUtf8(data)).toArray()]
    }

    public override func transformFlush(): Array<Array<UInt8>> {
        [("f${writes}").toArray()]
    }

    public override func transformClose(): Array<Array<UInt8>> {
        [("c${writes}").toArray()]
    }
}

class CloseOnlyResponseTransportTransform <: ResponseTransportTransform {
    public override func transformWrite(data: Array<UInt8>): Array<Array<UInt8>> {
        [data]
    }

    public override func transformFlush(): Array<Array<UInt8>> {
        Array<Array<UInt8>>()
    }

    public override func transformClose(): Array<Array<UInt8>> {
        ["tail".toArray()]
    }
}

class LabelResponseTransportTransform <: ResponseTransportTransform {
    let label: String

    init(label: String) {
        this.label = label
    }

    public override func transformWrite(data: Array<UInt8>): Array<Array<UInt8>> {
        [("${label}[" + String.fromUtf8(data) + "]").toArray()]
    }

    public override func transformFlush(): Array<Array<UInt8>> {
        [("${label}-flush").toArray()]
    }

    public override func transformClose(): Array<Array<UInt8>> {
        [("${label}-close").toArray()]
    }
}

func responseTransportLifecycleBytes(input: Array<UInt8>): Array<Byte> {
    let out = Array<Byte>(input.size, repeat: 0)
    var i: Int64 = 0
    while (i < input.size) {
        out[i] = input[i]
        i += 1
    }
    out
}
