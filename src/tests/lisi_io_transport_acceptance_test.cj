package ignite.tests

import std.collection.ArrayList
import std.io.InputStream
import ignite.*
import lisi.io.*

@Test
public class LisiIoTransportAcceptanceTestSuite {
    @TestCase
    public func testRealIgniteInputStreamAndResponseWriterConsumeLisiContract(): Unit {
        let output = ArrayList<UInt8>()
        let writer = openSinkBackedResponseTransportWriter({ chunk =>
            for (b in chunk) {
                output.add(b)
            }
        })
        let receipt = pumpIgniteInputStreamToResponseTransport(
            LisiIoChunkedInputStream("abcdefghij".toArray(), 3),
            writer,
            4,
            8,
            3,
            IoOperationContext(false, false)
        )

        @Assert(receipt.providerContractVersion, "1")
        @Assert(receipt.adapterVersion, "ignite-lisi-transport-adapter-v1")
        @Assert(receipt.selectedProvider, "std-fs-blocking")
        @Assert(receipt.selectionClass, "STABLE_EXPLICIT")
        @Assert(receipt.bytesRead, 10)
        @Assert(receipt.bytesWritten, 10)
        @Assert(receipt.maxBufferedBytesObserved <= 4, true)
        @Assert(receipt.flushState, "FLUSHED")
        @Assert(receipt.sourceClose, "CLOSED_NOW")
        @Assert(receipt.sinkClose, "CLOSED_NOW")
        @Assert(String.fromUtf8(output.toArray()), "abcdefghij")
    }

    @TestCase
    public func testGenericPumpSettlesPartialWrites(): Unit {
        let source = LisiIoScriptedSource([2, 2], false)
        let sink = LisiIoPartialSink(1)
        let receipt = pumpLisiIoTransport(
            source,
            sink,
            4,
            8,
            3,
            IoOperationContext(false, false)
        )

        @Assert(receipt.bytesRead, 4)
        @Assert(receipt.bytesWritten, 4)
        @Assert(receipt.writeTurns, 4)
        @Assert(sink.size(), 4)
    }

    @TestCase
    public func testNoProgressBudgetFailsClosed(): Unit {
        var rejected = false
        try {
            let _ = pumpLisiIoTransport(
                LisiIoScriptedSource([], true),
                LisiIoPartialSink(1),
                4,
                8,
                2,
                IoOperationContext(false, false)
            )
        } catch (e: LisiIoTransportException) {
            rejected = e.failure.kind == IoFailureKind.NoProgressLimitExceeded
        }
        @Assert(rejected, true)
    }

    @TestCase
    public func testCancellationWinsBeforeTransportProgress(): Unit {
        var rejected = false
        try {
            let _ = pumpLisiIoTransport(
                LisiIoScriptedSource([1], false),
                LisiIoPartialSink(1),
                4,
                8,
                2,
                IoOperationContext(true, true)
            )
        } catch (e: LisiIoTransportException) {
            rejected = e.failure.kind == IoFailureKind.Cancelled
        }
        @Assert(rejected, true)
    }

    @TestCase
    public func testTimeoutFailsBeforeTransportProgress(): Unit {
        var rejected = false
        try {
            let _ = pumpLisiIoTransport(
                LisiIoScriptedSource([1], false),
                LisiIoPartialSink(1),
                4,
                8,
                2,
                IoOperationContext(false, true)
            )
        } catch (e: LisiIoTransportException) {
            rejected = e.failure.kind == IoFailureKind.Timeout && e.failure.retryable
        }
        @Assert(rejected, true)
    }

    @TestCase
    public func testInputStreamBackendFailurePropagatesTyped(): Unit {
        let writer = openSinkBackedResponseTransportWriter({ _ => })
        var rejected = false
        try {
            let _ = pumpIgniteInputStreamToResponseTransport(
                LisiIoThrowingInputStream(),
                writer,
                4,
                8,
                2,
                IoOperationContext(false, false)
            )
        } catch (e: LisiIoTransportException) {
            rejected = e.failure.kind == IoFailureKind.BackendFailure
        }
        @Assert(rejected, true)
    }

    @TestCase
    public func testSourceAndSinkCloseAreIdempotent(): Unit {
        let source = IgniteInputStreamIoSource(LisiIoChunkedInputStream("x".toArray(), 1))
        let sink = IgniteResponseTransportIoSink(openSinkBackedResponseTransportWriter({ _ => }))

        @Assert(lisiIoCloseOutcome(source.close()), "CLOSED_NOW")
        @Assert(lisiIoCloseOutcome(source.close()), "ALREADY_CLOSED")
        @Assert(lisiIoCloseOutcome(sink.close()), "CLOSED_NOW")
        @Assert(lisiIoCloseOutcome(sink.close()), "ALREADY_CLOSED")
    }

    @TestCase
    public func testResponseTransportSinkPropagatesFlushAndCloseLifecycle(): Unit {
        let events = ArrayList<String>()
        let writer = openLifecycleSinkBackedResponseTransportWriter(
            {bytes => events.add("write:${String.fromUtf8(bytes)}")},
            {=> events.add("flush")},
            {=> events.add("close")}
        )
        let sink = IgniteResponseTransportIoSink(writer)
        let context = IoOperationContext(false, false)

        let writeTurn = sink.write("body".toArray(), 0, 4, context)
        let flushTurn = sink.flush(context)
        let closeTurn = sink.close()
        let secondCloseTurn = sink.close()

        @Assert(writeTurn.failure.isNone(), true)
        @Assert(flushTurn.failure.isNone(), true)
        @Assert(lisiIoCloseOutcome(closeTurn), "CLOSED_NOW")
        @Assert(lisiIoCloseOutcome(secondCloseTurn), "ALREADY_CLOSED")
        @Assert(events.size, Int64(3))
        @Assert(events[0], "write:body")
        @Assert(events[1], "flush")
        @Assert(events[2], "close")
    }
}

class LisiIoChunkedInputStream <: InputStream {
    let _bytes: Array<Byte>
    let _chunkSize: Int64
    var _offset: Int64 = 0

    init(bytes: Array<Byte>, chunkSize: Int64) {
        this._bytes = bytes
        this._chunkSize = chunkSize
    }

    public override func read(outBuf: Array<Byte>): Int64 {
        if (_offset >= _bytes.size || outBuf.size == 0) {
            return 0
        }
        let remaining = _bytes.size - _offset
        var count = if (_chunkSize < remaining) { _chunkSize } else { remaining }
        if (outBuf.size < count) {
            count = outBuf.size
        }
        var i: Int64 = 0
        while (i < count) {
            outBuf[i] = _bytes[_offset + i]
            i += 1
        }
        _offset += count
        count
    }
}

class LisiIoThrowingInputStream <: InputStream {
    public override func read(outBuf: Array<Byte>): Int64 {
        throw Exception("scripted input failure")
    }
}

class LisiIoScriptedSource <: IoByteSource {
    let _progressTurns: Array<Int64>
    let _neverProgress: Bool
    let _closeGuard = IoCloseGuard(IoCloseSemantics.CallerOwnedIdempotent)
    var _turn: Int64 = 0

    init(progressTurns: Array<Int64>, neverProgress: Bool) {
        this._progressTurns = progressTurns
        this._neverProgress = neverProgress
    }

    public override func read(
        target: Array<UInt8>,
        offset: Int64,
        length: Int64,
        context: IoOperationContext
    ): IoReadTurn {
        if (let Some(failure) <- ioOperationPreflight(IoOperation.Read, context)) {
            return ioReadFailure(failure)
        }
        if (_neverProgress) {
            return ioReadSuccess(IoReadResult(0, IoProgressState.NoProgress))
        }
        if (_turn >= _progressTurns.size) {
            return ioReadSuccess(IoReadResult(0, IoProgressState.Eof))
        }
        let count = _progressTurns[_turn]
        _turn += 1
        var i: Int64 = 0
        while (i < count && i < length) {
            target[offset + i] = UInt8(65 + i)
            i += 1
        }
        ioReadSuccess(IoReadResult(i, IoProgressState.Progress))
    }

    public override func closeSemantics(): IoCloseSemantics {
        IoCloseSemantics.CallerOwnedIdempotent
    }

    public override func close(): IoCloseTurn {
        ioCloseSuccess(_closeGuard.close())
    }
}

class LisiIoPartialSink <: IoByteSink {
    let _maxPerWrite: Int64
    let _bytes = ArrayList<UInt8>()
    let _closeGuard = IoCloseGuard(IoCloseSemantics.CallerOwnedIdempotent)

    init(maxPerWrite: Int64) {
        this._maxPerWrite = maxPerWrite
    }

    public override func write(
        source: Array<UInt8>,
        offset: Int64,
        length: Int64,
        context: IoOperationContext
    ): IoWriteTurn {
        if (let Some(failure) <- ioOperationPreflight(IoOperation.Write, context)) {
            return ioWriteFailure(failure)
        }
        let count = if (_maxPerWrite < length) { _maxPerWrite } else { length }
        var i: Int64 = 0
        while (i < count) {
            _bytes.add(source[offset + i])
            i += 1
        }
        ioWriteSuccess(IoWriteResult(count, IoProgressState.Progress))
    }

    public override func flush(context: IoOperationContext): IoFlushTurn {
        if (let Some(failure) <- ioOperationPreflight(IoOperation.Flush, context)) {
            return ioFlushFailure(failure)
        }
        ioFlushSuccess(IoFlushResult(IoFlushState.Flushed))
    }

    public override func closeSemantics(): IoCloseSemantics {
        IoCloseSemantics.CallerOwnedIdempotent
    }

    public override func close(): IoCloseTurn {
        ioCloseSuccess(_closeGuard.close())
    }

    func size(): Int64 {
        _bytes.size
    }
}

func lisiIoCloseOutcome(turn: IoCloseTurn): String {
    match (turn.outcome) {
        case Some(outcome) => outcome.toString()
        case None => "FAILED"
    }
}
