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

func responseTransportLifecycleBytes(input: Array<UInt8>): Array<Byte> {
    let out = Array<Byte>(input.size, repeat: 0)
    var i: Int64 = 0
    while (i < input.size) {
        out[i] = input[i]
        i += 1
    }
    out
}
