package ignite.tests

import ignite.*
import std.collection.ArrayList
import std.io.InputStream
import stdx.net.http.{HttpContext, HttpHeaders, WebSocket}

@Test
public class H2FlowBudgetNonLossGuardTestSuite {
    @TestCase
    public func testConnectionWindowShortageDoesNotSpendStreamBudgetBeforeRetry(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(3, 8)

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        let blockedByConnectionWindow = model.trySpendData(1, 4)
        @Assert(blockedByConnectionWindow.statusName, "waiting-for-window-update")
        @Assert(blockedByConnectionWindow.canWrite, false)
        @Assert(blockedByConnectionWindow.waitingForWindowUpdate, true)
        @Assert(blockedByConnectionWindow.protocolError, false)
        @Assert(blockedByConnectionWindow.connectionSendBudget, 3)
        @Assert(blockedByConnectionWindow.streamSendBudget, 8)

        let connectionWindowUpdate =
            model.observeWindowUpdateFrame(
                JinguiAcceptedTransportH2FrameWireSnapshot(
                    4,
                    UInt8(0x8),
                    UInt8(0x0),
                    0,
                    h2FlowBudgetNonLossGuardWindowUpdatePayload(2)
                )
            )
        @Assert(connectionWindowUpdate.connectionScoped, true)
        @Assert(connectionWindowUpdate.increment, 2)

        let sentAfterConnectionWindowUpdate = model.trySpendData(1, 4)
        @Assert(sentAfterConnectionWindowUpdate.statusName, "sent")
        @Assert(sentAfterConnectionWindowUpdate.connectionSendBudget, 1)
        @Assert(sentAfterConnectionWindowUpdate.streamSendBudget, 4)
    }

    @TestCase
    public func testWriterFlowGateShortageIsNonLossyUntilWindowUpdate(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(3, 8)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        let blockedByConnectionWindow = gate.tryClaimDataWrite(1, 4)
        @Assert(blockedByConnectionWindow.statusName, "waiting-for-window-update")
        @Assert(blockedByConnectionWindow.canWrite, false)
        @Assert(blockedByConnectionWindow.waitingForWindowUpdate, true)
        @Assert(blockedByConnectionWindow.connectionSendBudget, 3)
        @Assert(blockedByConnectionWindow.streamSendBudget, 8)
        @Assert(model.connectionSendBudget(), 3)
        @Assert(model.streamSendBudget(1), 8)

        model.observeWindowUpdateFrame(
            JinguiAcceptedTransportH2FrameWireSnapshot(
                4,
                UInt8(0x8),
                UInt8(0x0),
                0,
                h2FlowBudgetNonLossGuardWindowUpdatePayload(2)
            )
        )

        let sentAfterWindowUpdate = gate.tryClaimDataWrite(1, 4)
        @Assert(sentAfterWindowUpdate.statusName, "sent")
        @Assert(sentAfterWindowUpdate.canWrite, true)
        @Assert(sentAfterWindowUpdate.connectionSendBudget, 1)
        @Assert(sentAfterWindowUpdate.streamSendBudget, 4)
        @Assert(model.connectionSendBudget(), 1)
        @Assert(model.streamSendBudget(1), 4)
    }

    @TestCase
    public func testWriterFlowQueueKeepsBlockedHeadUntilWindowUpdate(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(3, 8)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLength(1, 4), 1)
        let blocked = queue.tryDrainHead()
        @Assert(blocked.drained, false)
        @Assert(blocked.waitingForWindowUpdate, true)
        @Assert(blocked.pendingCount, 1)
        @Assert(blocked.decision.statusName, "waiting-for-window-update")
        @Assert(queue.pendingCount(), 1)
        @Assert(model.connectionSendBudget(), 3)
        @Assert(model.streamSendBudget(1), 8)

        model.observeWindowUpdateFrame(
            JinguiAcceptedTransportH2FrameWireSnapshot(
                4,
                UInt8(0x8),
                UInt8(0x0),
                0,
                h2FlowBudgetNonLossGuardWindowUpdatePayload(2)
            )
        )

        let drained = queue.tryDrainHead()
        @Assert(drained.drained, true)
        @Assert(drained.waitingForWindowUpdate, false)
        @Assert(drained.pendingCount, 0)
        @Assert(drained.decision.statusName, "sent")
        @Assert(queue.pendingCount(), 0)
        @Assert(model.connectionSendBudget(), 1)
        @Assert(model.streamSendBudget(1), 4)
    }

    @TestCase
    public func testWriterFlowQueueChunkDrainKeepsRemainingBytesOnWindowWait(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(6, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLength(1, 10), 1)
        let firstChunk = queue.tryDrainHeadChunk(4)
        @Assert(firstChunk.drained, true)
        @Assert(firstChunk.byteCount, 4)
        @Assert(firstChunk.remainingByteCount, 6)
        @Assert(firstChunk.pendingCount, 1)
        @Assert(queue.pendingCount(), 1)
        @Assert(model.connectionSendBudget(), 2)
        @Assert(model.streamSendBudget(1), 16)

        let blockedSecondChunk = queue.tryDrainHeadChunk(4)
        @Assert(blockedSecondChunk.drained, false)
        @Assert(blockedSecondChunk.waitingForWindowUpdate, true)
        @Assert(blockedSecondChunk.byteCount, 4)
        @Assert(blockedSecondChunk.remainingByteCount, 6)
        @Assert(blockedSecondChunk.pendingCount, 1)
        @Assert(queue.pendingCount(), 1)
        @Assert(model.connectionSendBudget(), 2)
        @Assert(model.streamSendBudget(1), 16)

        model.observeWindowUpdateFrame(
            JinguiAcceptedTransportH2FrameWireSnapshot(
                4,
                UInt8(0x8),
                UInt8(0x0),
                0,
                h2FlowBudgetNonLossGuardWindowUpdatePayload(4)
            )
        )

        let secondChunk = queue.tryDrainHeadChunk(4)
        @Assert(secondChunk.drained, true)
        @Assert(secondChunk.byteCount, 4)
        @Assert(secondChunk.remainingByteCount, 2)
        @Assert(secondChunk.pendingCount, 1)
        @Assert(queue.pendingCount(), 1)
        @Assert(model.connectionSendBudget(), 2)
        @Assert(model.streamSendBudget(1), 12)
    }

    @TestCase
    public func testWriterFlowQueueEndStreamOnlyOnFinalChunk(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(10, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLengthWithEndStream(1, 6, true), 1)
        let firstChunk = queue.tryDrainHeadChunk(4)
        @Assert(firstChunk.drained, true)
        @Assert(firstChunk.endStream, false)
        @Assert(firstChunk.byteCount, 4)
        @Assert(firstChunk.remainingByteCount, 2)
        @Assert(firstChunk.pendingCount, 1)

        let finalChunk = queue.tryDrainHeadChunk(4)
        @Assert(finalChunk.drained, true)
        @Assert(finalChunk.endStream, true)
        @Assert(finalChunk.byteCount, 2)
        @Assert(finalChunk.remainingByteCount, 0)
        @Assert(finalChunk.pendingCount, 0)
        @Assert(queue.pendingCount(), 0)
        @Assert(model.connectionSendBudget(), 4)
        @Assert(model.streamSendBudget(1), 14)
    }

    @TestCase
    public func testWriterDataFrameSnapshotUsesChunkEndStreamFlag(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(10, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLengthWithEndStream(1, 6, true), 1)
        let firstChunk = queue.tryDrainHeadChunk(4)
        let firstFrame =
            buildJinguiAcceptedTransportH2WriterDataFrameWireSnapshot(
                firstChunk,
                h2FlowBudgetNonLossGuardBytes("abcd")
            )
        @Assert(firstFrame.frameType, UInt8(0x0))
        @Assert(firstFrame.flags, UInt8(0x0))
        @Assert(firstFrame.streamId, 1)
        @Assert(firstFrame.payloadLength, 4)
        @Assert(firstFrame.payload.size, 4)

        let finalChunk = queue.tryDrainHeadChunk(4)
        let finalFrame =
            buildJinguiAcceptedTransportH2WriterDataFrameWireSnapshot(
                finalChunk,
                h2FlowBudgetNonLossGuardBytes("ef")
            )
        @Assert(finalFrame.frameType, UInt8(0x0))
        @Assert(finalFrame.flags, UInt8(0x1))
        @Assert(finalFrame.streamId, 1)
        @Assert(finalFrame.payloadLength, 2)
        @Assert(finalFrame.payload.size, 2)
    }

    @TestCase
    public func testWriterDataFrameSnapshotRejectsBlockedChunk(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(3, 8)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLength(1, 4), 1)
        let blockedChunk = queue.tryDrainHeadChunk(4)
        var rejected = false
        try {
            let _ = buildJinguiAcceptedTransportH2WriterDataFrameWireSnapshot(
                blockedChunk,
                h2FlowBudgetNonLossGuardBytes("abcd")
            )
        } catch (_: Exception) {
            rejected = true
        }
        @Assert(rejected, true)
    }

    @TestCase
    public func testWriterDataFrameRawWireEncoderRoundTripsSnapshot(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(10, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLengthWithEndStream(1, 4, true), 1)
        let chunk = queue.tryDrainHeadChunk(4)
        let frame =
            buildJinguiAcceptedTransportH2WriterDataFrameWireSnapshot(
                chunk,
                h2FlowBudgetNonLossGuardBytes("DATA")
            )
        let wire = encodeJinguiAcceptedTransportH2DataFrameWireSnapshot(frame)

        @Assert(wire.size, 13)
        @Assert(wire[0], UInt8(0x0))
        @Assert(wire[1], UInt8(0x0))
        @Assert(wire[2], UInt8(0x4))
        @Assert(wire[3], UInt8(0x0))
        @Assert(wire[4], UInt8(0x1))
        @Assert(wire[5], UInt8(0x0))
        @Assert(wire[6], UInt8(0x0))
        @Assert(wire[7], UInt8(0x0))
        @Assert(wire[8], UInt8(0x1))

        let parsed = parseJinguiAcceptedTransportH2FrameWire(wire)
        @Assert(parsed.payloadLength, 4)
        @Assert(parsed.frameType, UInt8(0x0))
        @Assert(parsed.flags, UInt8(0x1))
        @Assert(parsed.streamId, 1)
        @Assert(parsed.payload, h2FlowBudgetNonLossGuardBytes("DATA"))
    }

    @TestCase
    public func testWriterDataFrameRawWireEncoderRejectsInvalidSnapshot(): Unit {
        var rejectedZeroStream = false
        try {
            let _ = encodeJinguiAcceptedTransportH2DataFrameWireSnapshot(
                JinguiAcceptedTransportH2FrameWireSnapshot(
                    1,
                    UInt8(0x0),
                    UInt8(0x0),
                    0,
                    h2FlowBudgetNonLossGuardBytes("x")
                )
            )
        } catch (_: Exception) {
            rejectedZeroStream = true
        }
        @Assert(rejectedZeroStream, true)

        var rejectedLengthMismatch = false
        try {
            let _ = encodeJinguiAcceptedTransportH2DataFrameWireSnapshot(
                JinguiAcceptedTransportH2FrameWireSnapshot(
                    2,
                    UInt8(0x0),
                    UInt8(0x0),
                    1,
                    h2FlowBudgetNonLossGuardBytes("x")
                )
            )
        } catch (_: Exception) {
            rejectedLengthMismatch = true
        }
        @Assert(rejectedLengthMismatch, true)
    }

    @TestCase
    public func testWriterDataFrameSinkStoresEncodedWire(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(10, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        let sink = JinguiAcceptedTransportH2FrameWireBufferSink()

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLengthWithEndStream(1, 4, true), 1)
        let chunk = queue.tryDrainHeadChunk(4)
        let frame =
            buildJinguiAcceptedTransportH2WriterDataFrameWireSnapshot(
                chunk,
                h2FlowBudgetNonLossGuardBytes("sink")
            )
        let written =
            writeJinguiAcceptedTransportH2DataFrameWireSnapshotToSink(
                frame,
                sink
            )

        @Assert(written, 13)
        @Assert(sink.frameCount(), 1)
        let parsed = parseJinguiAcceptedTransportH2FrameWire(
            sink.lastFrameWire()
        )
        @Assert(parsed.frameType, UInt8(0x0))
        @Assert(parsed.flags, UInt8(0x1))
        @Assert(parsed.streamId, 1)
        @Assert(parsed.payload, h2FlowBudgetNonLossGuardBytes("sink"))
    }

    @TestCase
    public func testWriterDataFrameSinkDoesNotAppendAfterEncodeFailure(): Unit {
        let sink = JinguiAcceptedTransportH2FrameWireBufferSink()
        var rejected = false
        try {
            let _ = writeJinguiAcceptedTransportH2DataFrameWireSnapshotToSink(
                JinguiAcceptedTransportH2FrameWireSnapshot(
                    1,
                    UInt8(0x0),
                    UInt8(0x0),
                    0,
                    h2FlowBudgetNonLossGuardBytes("x")
                ),
                sink
            )
        } catch (_: Exception) {
            rejected = true
        }

        @Assert(rejected, true)
        @Assert(sink.frameCount(), 0)
    }

    @TestCase
    public func testWriterDataFrameSocketAdapterContractReceivesEncodedWire(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(10, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        let adapter = H2FlowBudgetNonLossGuardSocketAdapterContractSink()

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLengthWithEndStream(1, 4, true), 1)
        let chunk = queue.tryDrainHeadChunk(4)
        let frame =
            buildJinguiAcceptedTransportH2WriterDataFrameWireSnapshot(
                chunk,
                h2FlowBudgetNonLossGuardBytes("sock")
            )
        let written =
            writeJinguiAcceptedTransportH2DataFrameWireSnapshotToSink(
                frame,
                adapter
            )

        @Assert(written, 13)
        @Assert(adapter.writeCalls, 1)
        @Assert(adapter.totalBytes, 13)
        let parsed = parseJinguiAcceptedTransportH2FrameWire(adapter.lastWire())
        @Assert(parsed.frameType, UInt8(0x0))
        @Assert(parsed.flags, UInt8(0x1))
        @Assert(parsed.streamId, 1)
        @Assert(parsed.payload, h2FlowBudgetNonLossGuardBytes("sock"))
    }

    @TestCase
    public func testWriterDataFrameSocketAdapterContractRejectsBeforeWrite(): Unit {
        let adapter = H2FlowBudgetNonLossGuardSocketAdapterContractSink()
        var rejected = false
        try {
            let _ = writeJinguiAcceptedTransportH2DataFrameWireSnapshotToSink(
                JinguiAcceptedTransportH2FrameWireSnapshot(
                    1,
                    UInt8(0x0),
                    UInt8(0x0),
                    0,
                    h2FlowBudgetNonLossGuardBytes("x")
                ),
                adapter
            )
        } catch (_: Exception) {
            rejected = true
        }

        @Assert(rejected, true)
        @Assert(adapter.writeCalls, 0)
        @Assert(adapter.totalBytes, 0)
    }

    @TestCase
    public func testWriterDataFrameFunctionSinkDelegatesEncodedWire(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(10, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        let capture = H2FlowBudgetNonLossGuardFunctionSinkCapture()
        let sink = JinguiAcceptedTransportH2FrameWireFunctionSink({ wire =>
            capture.write(wire)
        })

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLengthWithEndStream(1, 4, true), 1)
        let chunk = queue.tryDrainHeadChunk(4)
        let frame =
            buildJinguiAcceptedTransportH2WriterDataFrameWireSnapshot(
                chunk,
                h2FlowBudgetNonLossGuardBytes("sock")
            )
        let written =
            writeJinguiAcceptedTransportH2DataFrameWireSnapshotToSink(
                frame,
                sink
            )

        @Assert(written, 13)
        @Assert(capture.writeCalls, 1)
        let parsed = parseJinguiAcceptedTransportH2FrameWire(capture.lastWire())
        @Assert(parsed.frameType, UInt8(0x0))
        @Assert(parsed.flags, UInt8(0x1))
        @Assert(parsed.streamId, 1)
        @Assert(parsed.payload, h2FlowBudgetNonLossGuardBytes("sock"))
    }

    @TestCase
    public func testWriterDataFrameFunctionSinkRejectsBeforeDelegate(): Unit {
        let capture = H2FlowBudgetNonLossGuardFunctionSinkCapture()
        let sink = JinguiAcceptedTransportH2FrameWireFunctionSink({ wire =>
            capture.write(wire)
        })
        var rejected = false
        try {
            let _ = writeJinguiAcceptedTransportH2DataFrameWireSnapshotToSink(
                JinguiAcceptedTransportH2FrameWireSnapshot(
                    1,
                    UInt8(0x0),
                    UInt8(0x0),
                    0,
                    h2FlowBudgetNonLossGuardBytes("x")
                ),
                sink
            )
        } catch (_: Exception) {
            rejected = true
        }

        @Assert(rejected, true)
        @Assert(capture.writeCalls, 0)
    }

    @TestCase
    public func testWriterDataFrameSocketDryRunSinkAcceptsCompleteWrite(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(10, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        let capture = H2FlowBudgetNonLossGuardFunctionSinkCapture()
        let sink = JinguiAcceptedTransportH2FrameWireSocketDryRunSink({ wire =>
            capture.write(wire)
        })

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLengthWithEndStream(1, 4, true), 1)
        let chunk = queue.tryDrainHeadChunk(4)
        let frame =
            buildJinguiAcceptedTransportH2WriterDataFrameWireSnapshot(
                chunk,
                h2FlowBudgetNonLossGuardBytes("sock")
            )
        let written =
            writeJinguiAcceptedTransportH2DataFrameWireSnapshotToSink(
                frame,
                sink
            )

        @Assert(written, 13)
        @Assert(sink.writeCalls(), 1)
        @Assert(capture.writeCalls, 1)
        let result = sink.lastResult()
        @Assert(result.statusName, "complete-write")
        @Assert(result.attempted, true)
        @Assert(result.completed, true)
        @Assert(result.byteCount, 13)
        @Assert(result.writtenByteCount, 13)
        let parsed = parseJinguiAcceptedTransportH2FrameWire(capture.lastWire())
        @Assert(parsed.frameType, UInt8(0x0))
        @Assert(parsed.flags, UInt8(0x1))
        @Assert(parsed.streamId, 1)
        @Assert(parsed.payload, h2FlowBudgetNonLossGuardBytes("sock"))
    }

    @TestCase
    public func testWriterDataFrameSocketDryRunSinkRejectsShortWrite(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(10, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        let capture = H2FlowBudgetNonLossGuardFunctionSinkCapture()
        let sink = JinguiAcceptedTransportH2FrameWireSocketDryRunSink({ wire =>
            capture.write(wire) - 1
        })

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLengthWithEndStream(1, 4, true), 1)
        let chunk = queue.tryDrainHeadChunk(4)
        let frame =
            buildJinguiAcceptedTransportH2WriterDataFrameWireSnapshot(
                chunk,
                h2FlowBudgetNonLossGuardBytes("sock")
            )
        var rejected = false
        try {
            let _ = writeJinguiAcceptedTransportH2DataFrameWireSnapshotToSink(
                frame,
                sink
            )
        } catch (_: Exception) {
            rejected = true
        }

        @Assert(rejected, true)
        @Assert(sink.writeCalls(), 1)
        @Assert(capture.writeCalls, 1)
        let result = sink.lastResult()
        @Assert(result.statusName, "incomplete-write")
        @Assert(result.attempted, true)
        @Assert(result.completed, false)
        @Assert(result.byteCount, 13)
        @Assert(result.writtenByteCount, 12)
    }

    @TestCase
    public func testWriterDataFrameSocketDryRunSinkRejectsInvalidBeforeWrite(): Unit {
        let capture = H2FlowBudgetNonLossGuardFunctionSinkCapture()
        let sink = JinguiAcceptedTransportH2FrameWireSocketDryRunSink({ wire =>
            capture.write(wire)
        })
        var rejected = false
        try {
            let _ = writeJinguiAcceptedTransportH2DataFrameWireSnapshotToSink(
                JinguiAcceptedTransportH2FrameWireSnapshot(
                    1,
                    UInt8(0x0),
                    UInt8(0x0),
                    0,
                    h2FlowBudgetNonLossGuardBytes("x")
                ),
                sink
            )
        } catch (_: Exception) {
            rejected = true
        }

        @Assert(rejected, true)
        @Assert(sink.writeCalls(), 0)
        @Assert(capture.writeCalls, 0)
        @Assert(sink.lastResult().statusName, "not-run")
    }

    @TestCase
    public func testWriterDataFrameAcceptedTransportAttachDryRunCompleteWrite(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(10, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        let capture = H2FlowBudgetNonLossGuardFunctionSinkCapture()

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLengthWithEndStream(1, 4, true), 1)
        let chunk = queue.tryDrainHeadChunk(4)
        let frame =
            buildJinguiAcceptedTransportH2WriterDataFrameWireSnapshot(
                chunk,
                h2FlowBudgetNonLossGuardBytes("sock")
            )
        let result = attachJinguiAcceptedTransportH2DataFrameWriterDryRun(
            h2FlowBudgetNonLossGuardTransport(),
            frame,
            { wire => capture.write(wire) }
        )

        @Assert(result.transportId, "h2-flow-budget-transport")
        @Assert(result.transportKind, "accepted-socket")
        @Assert(result.statusName, "attached-complete-write")
        @Assert(result.attempted, true)
        @Assert(result.completed, true)
        @Assert(result.byteCount, 13)
        @Assert(result.writtenByteCount, 13)
        @Assert(result.writeCalls, 1)
        @Assert(capture.writeCalls, 1)
    }

    @TestCase
    public func testWriterDataFrameAcceptedTransportAttachDryRunShortWrite(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(10, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        let capture = H2FlowBudgetNonLossGuardFunctionSinkCapture()

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLengthWithEndStream(1, 4, true), 1)
        let chunk = queue.tryDrainHeadChunk(4)
        let frame =
            buildJinguiAcceptedTransportH2WriterDataFrameWireSnapshot(
                chunk,
                h2FlowBudgetNonLossGuardBytes("sock")
            )
        let result = attachJinguiAcceptedTransportH2DataFrameWriterDryRun(
            h2FlowBudgetNonLossGuardTransport(),
            frame,
            { wire => capture.write(wire) - 1 }
        )

        @Assert(result.transportId, "h2-flow-budget-transport")
        @Assert(result.statusName, "attached-incomplete-write")
        @Assert(result.attempted, true)
        @Assert(result.completed, false)
        @Assert(result.byteCount, 13)
        @Assert(result.writtenByteCount, 12)
        @Assert(result.writeCalls, 1)
        @Assert(capture.writeCalls, 1)
    }

    @TestCase
    public func testWriterDataFrameAcceptedTransportAttachDryRunRejectsInvalidBeforeWrite(): Unit {
        let capture = H2FlowBudgetNonLossGuardFunctionSinkCapture()
        var rejected = false
        try {
            let _ = attachJinguiAcceptedTransportH2DataFrameWriterDryRun(
                h2FlowBudgetNonLossGuardTransport(),
                JinguiAcceptedTransportH2FrameWireSnapshot(
                    1,
                    UInt8(0x0),
                    UInt8(0x0),
                    0,
                    h2FlowBudgetNonLossGuardBytes("x")
                ),
                { wire => capture.write(wire) }
            )
        } catch (_: Exception) {
            rejected = true
        }

        @Assert(rejected, true)
        @Assert(capture.writeCalls, 0)
    }

    @TestCase
    public func testWriterDataFrameApplicationDataResponseWriterDryRunCompleteWrite(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(10, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        let capture = H2FlowBudgetNonLossGuardFunctionSinkCapture()

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLengthWithEndStream(1, 4, true), 1)
        let chunk = queue.tryDrainHeadChunk(4)
        let frame =
            buildJinguiAcceptedTransportH2WriterDataFrameWireSnapshot(
                chunk,
                h2FlowBudgetNonLossGuardBytes("sock")
            )
        let result =
            dryRunJinguiAcceptedTransportH2ApplicationDataResponseWriter(
                "jingui-accepted-transport-application-data-response-writer",
                h2FlowBudgetNonLossGuardTransport(),
                frame,
                { wire => capture.write(wire) }
            )

        @Assert(
            result.responseWriterSurface,
            "jingui-accepted-transport-application-data-response-writer"
        )
        @Assert(result.transportId, "h2-flow-budget-transport")
        @Assert(result.attachStatusName, "attached-complete-write")
        @Assert(result.statusName, "application-data-writer-complete")
        @Assert(result.attempted, true)
        @Assert(result.completed, true)
        @Assert(result.byteCount, 13)
        @Assert(result.writtenByteCount, 13)
        @Assert(result.writeCalls, 1)
        @Assert(capture.writeCalls, 1)
    }

    @TestCase
    public func testWriterDataFrameApplicationDataResponseWriterDryRunShortWrite(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(10, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        let capture = H2FlowBudgetNonLossGuardFunctionSinkCapture()

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLengthWithEndStream(1, 4, true), 1)
        let chunk = queue.tryDrainHeadChunk(4)
        let frame =
            buildJinguiAcceptedTransportH2WriterDataFrameWireSnapshot(
                chunk,
                h2FlowBudgetNonLossGuardBytes("sock")
            )
        let result =
            dryRunJinguiAcceptedTransportH2ApplicationDataResponseWriter(
                "jingui-accepted-transport-application-data-response-writer",
                h2FlowBudgetNonLossGuardTransport(),
                frame,
                { wire => capture.write(wire) - 1 }
            )

        @Assert(result.transportId, "h2-flow-budget-transport")
        @Assert(result.attachStatusName, "attached-incomplete-write")
        @Assert(result.statusName, "application-data-writer-incomplete")
        @Assert(result.attempted, true)
        @Assert(result.completed, false)
        @Assert(result.byteCount, 13)
        @Assert(result.writtenByteCount, 12)
        @Assert(result.writeCalls, 1)
        @Assert(capture.writeCalls, 1)
    }

    @TestCase
    public func testWriterDataFrameApplicationDataResponseWriterDryRunRejectsInvalidBeforeWrite(): Unit {
        let capture = H2FlowBudgetNonLossGuardFunctionSinkCapture()
        var rejected = false
        try {
            let _ =
                dryRunJinguiAcceptedTransportH2ApplicationDataResponseWriter(
                    "jingui-accepted-transport-application-data-response-writer",
                    h2FlowBudgetNonLossGuardTransport(),
                    JinguiAcceptedTransportH2FrameWireSnapshot(
                        1,
                        UInt8(0x0),
                        UInt8(0x0),
                        0,
                        h2FlowBudgetNonLossGuardBytes("x")
                    ),
                    { wire => capture.write(wire) }
                )
        } catch (_: Exception) {
            rejected = true
        }

        @Assert(rejected, true)
        @Assert(capture.writeCalls, 0)
    }

    @TestCase
    public func testWriterDataFrameResponseTransportWriterAdapterDryRunWritesEncodedDataFrame(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(10, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        let capture = H2FlowBudgetNonLossGuardResponseTransportCapture()

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLengthWithEndStream(1, 4, true), 1)
        let chunk = queue.tryDrainHeadChunk(4)
        let frame =
            buildJinguiAcceptedTransportH2WriterDataFrameWireSnapshot(
                chunk,
                h2FlowBudgetNonLossGuardBytes("rtrn")
            )
        let writer = openSinkBackedResponseTransportWriter({ bytes =>
            capture.write(bytes)
        })
        let result =
            dryRunJinguiAcceptedTransportH2ResponseTransportWriterAdapter(
                "response-transport-writer",
                h2FlowBudgetNonLossGuardTransport(),
                frame,
                writer
            )

        @Assert(result.responseWriterSurface, "response-transport-writer")
        @Assert(result.transportId, "h2-flow-budget-transport")
        @Assert(result.transportKind, "accepted-socket")
        @Assert(result.statusName, "response-transport-writer-complete")
        @Assert(result.attempted, true)
        @Assert(result.completed, true)
        @Assert(result.byteCount, 13)
        @Assert(result.writeCalls, 1)
        @Assert(capture.writeCalls, 1)
        @Assert(capture.totalBytes, 13)
        let parsed = parseJinguiAcceptedTransportH2FrameWire(capture.lastWire())
        @Assert(parsed.frameType, UInt8(0x0))
        @Assert(parsed.flags, UInt8(0x1))
        @Assert(parsed.streamId, 1)
        @Assert(parsed.payload, h2FlowBudgetNonLossGuardBytes("rtrn"))
    }

    @TestCase
    public func testWriterDataFrameResponseTransportWriterAdapterDryRunPropagatesWriterFailure(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(10, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        let writer = H2FlowBudgetNonLossGuardFailingResponseTransportWriter()

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLengthWithEndStream(1, 4, true), 1)
        let chunk = queue.tryDrainHeadChunk(4)
        let frame =
            buildJinguiAcceptedTransportH2WriterDataFrameWireSnapshot(
                chunk,
                h2FlowBudgetNonLossGuardBytes("fail")
            )
        var propagated = false
        try {
            let _ =
                dryRunJinguiAcceptedTransportH2ResponseTransportWriterAdapter(
                    "response-transport-writer",
                    h2FlowBudgetNonLossGuardTransport(),
                    frame,
                    writer
                )
        } catch (_: Exception) {
            propagated = true
        }

        @Assert(propagated, true)
        @Assert(writer.writeCalls, 1)
    }

    @TestCase
    public func testWriterDataFrameResponseTransportWriterAdapterDryRunRejectsInvalidBeforeWrite(): Unit {
        let capture = H2FlowBudgetNonLossGuardResponseTransportCapture()
        let writer = openSinkBackedResponseTransportWriter({ bytes =>
            capture.write(bytes)
        })

        var rejected = false
        try {
            let _ =
                dryRunJinguiAcceptedTransportH2ResponseTransportWriterAdapter(
                    "response-transport-writer",
                    h2FlowBudgetNonLossGuardTransport(),
                    JinguiAcceptedTransportH2FrameWireSnapshot(
                        1,
                        UInt8(0x0),
                        UInt8(0x0),
                        0,
                        h2FlowBudgetNonLossGuardBytes("x")
                    ),
                    writer
                )
        } catch (_: Exception) {
            rejected = true
        }

        @Assert(rejected, true)
        @Assert(capture.writeCalls, 0)
        @Assert(capture.totalBytes, 0)
    }

    @TestCase
    public func testWriterDataFrameNativeResponseCommitAdapterGateWritesEncodedDataFrame(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(10, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        let capture = H2FlowBudgetNonLossGuardResponseTransportCapture()

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLengthWithEndStream(1, 4, true), 1)
        let chunk = queue.tryDrainHeadChunk(4)
        let writer = openSinkBackedResponseTransportWriter({ bytes =>
            capture.write(bytes)
        })
        let result =
            dryRunJinguiAcceptedTransportH2NativeResponseCommitAdapterGate(
                "native-h2-response-commit-adapter",
                h2FlowBudgetNonLossGuardTransport(),
                chunk,
                h2FlowBudgetNonLossGuardBytes("gate"),
                writer
            )

        @Assert(result.responseWriterSurface, "native-h2-response-commit-adapter")
        @Assert(result.transportId, "h2-flow-budget-transport")
        @Assert(result.transportKind, "accepted-socket")
        @Assert(result.adapterStatusName, "response-transport-writer-complete")
        @Assert(result.statusName, "native-response-commit-adapter-complete")
        @Assert(result.attempted, true)
        @Assert(result.completed, true)
        @Assert(result.streamId, 1)
        @Assert(result.endStream, true)
        @Assert(result.byteCount, 13)
        @Assert(result.writeCalls, 1)
        @Assert(capture.writeCalls, 1)
        @Assert(capture.totalBytes, 13)
        let parsed = parseJinguiAcceptedTransportH2FrameWire(capture.lastWire())
        @Assert(parsed.frameType, UInt8(0x0))
        @Assert(parsed.flags, UInt8(0x1))
        @Assert(parsed.streamId, 1)
        @Assert(parsed.payload, h2FlowBudgetNonLossGuardBytes("gate"))
    }

    @TestCase
    public func testWriterDataFrameNativeResponseCommitAdapterGatePropagatesWriterFailure(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(10, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        let writer = H2FlowBudgetNonLossGuardFailingResponseTransportWriter()

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLengthWithEndStream(1, 4, true), 1)
        let chunk = queue.tryDrainHeadChunk(4)
        var propagated = false
        try {
            let _ =
                dryRunJinguiAcceptedTransportH2NativeResponseCommitAdapterGate(
                    "native-h2-response-commit-adapter",
                    h2FlowBudgetNonLossGuardTransport(),
                    chunk,
                    h2FlowBudgetNonLossGuardBytes("fail"),
                    writer
                )
        } catch (_: Exception) {
            propagated = true
        }

        @Assert(propagated, true)
        @Assert(writer.writeCalls, 1)
    }

    @TestCase
    public func testWriterDataFrameNativeResponseCommitAdapterGateRejectsBlockedDrainBeforeWrite(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(3, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        let capture = H2FlowBudgetNonLossGuardResponseTransportCapture()
        let writer = openSinkBackedResponseTransportWriter({ bytes =>
            capture.write(bytes)
        })

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLengthWithEndStream(1, 4, true), 1)
        let blocked = queue.tryDrainHeadChunk(4)
        @Assert(blocked.drained, false)

        var rejected = false
        try {
            let _ =
                dryRunJinguiAcceptedTransportH2NativeResponseCommitAdapterGate(
                    "native-h2-response-commit-adapter",
                    h2FlowBudgetNonLossGuardTransport(),
                    blocked,
                    h2FlowBudgetNonLossGuardBytes("wait"),
                    writer
                )
        } catch (_: Exception) {
            rejected = true
        }

        @Assert(rejected, true)
        @Assert(capture.writeCalls, 0)
        @Assert(capture.totalBytes, 0)
    }

    @TestCase
    public func testWriterDataFrameLiveResponseWriterAcquisitionGateWritesEncodedDataFrame(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(10, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        let capture = H2FlowBudgetNonLossGuardResponseTransportCapture()

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLengthWithEndStream(1, 4, true), 1)
        let chunk = queue.tryDrainHeadChunk(4)
        let writer = openSinkBackedResponseTransportWriter({ bytes =>
            capture.write(bytes)
        })
        let carrier =
            H2FlowBudgetNonLossGuardCurrentRequestCarrier(writer, false)
        let result =
            dryRunJinguiAcceptedTransportH2LiveResponseWriterAcquisitionGate(
                "live-response-writer-acquisition-gate",
                h2FlowBudgetNonLossGuardTransport(),
                chunk,
                h2FlowBudgetNonLossGuardBytes("live"),
                carrier
            )

        @Assert(result.responseWriterSurface, "live-response-writer-acquisition-gate")
        @Assert(result.transportId, "h2-flow-budget-transport")
        @Assert(result.transportKind, "accepted-socket")
        @Assert(result.acquisitionStatusName, "response-transport-writer-acquired")
        @Assert(result.commitStatusName, "native-response-commit-adapter-complete")
        @Assert(result.statusName, "live-response-writer-acquisition-gate-complete")
        @Assert(result.attempted, true)
        @Assert(result.completed, true)
        @Assert(result.streamId, 1)
        @Assert(result.endStream, true)
        @Assert(result.byteCount, 13)
        @Assert(result.writeCalls, 1)
        @Assert(carrier.openCalls, 1)
        @Assert(capture.writeCalls, 1)
        @Assert(capture.totalBytes, 13)
        let parsed = parseJinguiAcceptedTransportH2FrameWire(capture.lastWire())
        @Assert(parsed.frameType, UInt8(0x0))
        @Assert(parsed.flags, UInt8(0x1))
        @Assert(parsed.streamId, 1)
        @Assert(parsed.payload, h2FlowBudgetNonLossGuardBytes("live"))
    }

    @TestCase
    public func testWriterDataFrameLiveResponseWriterAcquisitionGatePropagatesAcquireFailure(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(10, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        let capture = H2FlowBudgetNonLossGuardResponseTransportCapture()
        let writer = openSinkBackedResponseTransportWriter({ bytes =>
            capture.write(bytes)
        })

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLengthWithEndStream(1, 4, true), 1)
        let chunk = queue.tryDrainHeadChunk(4)
        let carrier =
            H2FlowBudgetNonLossGuardCurrentRequestCarrier(writer, true)
        var propagated = false
        try {
            let _ =
                dryRunJinguiAcceptedTransportH2LiveResponseWriterAcquisitionGate(
                    "live-response-writer-acquisition-gate",
                    h2FlowBudgetNonLossGuardTransport(),
                    chunk,
                    h2FlowBudgetNonLossGuardBytes("fail"),
                    carrier
                )
        } catch (_: Exception) {
            propagated = true
        }

        @Assert(propagated, true)
        @Assert(carrier.openCalls, 1)
        @Assert(capture.writeCalls, 0)
        @Assert(capture.totalBytes, 0)
    }

    @TestCase
    public func testWriterDataFrameLiveResponseWriterAcquisitionGatePropagatesWriterFailure(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(10, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        let writer = H2FlowBudgetNonLossGuardFailingResponseTransportWriter()

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLengthWithEndStream(1, 4, true), 1)
        let chunk = queue.tryDrainHeadChunk(4)
        let carrier =
            H2FlowBudgetNonLossGuardCurrentRequestCarrier(writer, false)
        var propagated = false
        try {
            let _ =
                dryRunJinguiAcceptedTransportH2LiveResponseWriterAcquisitionGate(
                    "live-response-writer-acquisition-gate",
                    h2FlowBudgetNonLossGuardTransport(),
                    chunk,
                    h2FlowBudgetNonLossGuardBytes("fail"),
                    carrier
                )
        } catch (_: Exception) {
            propagated = true
        }

        @Assert(propagated, true)
        @Assert(carrier.openCalls, 1)
        @Assert(writer.writeCalls, 1)
    }

    @TestCase
    public func testWriterDataFrameLiveResponseWriterAcquisitionGateRejectsBlockedDrainBeforeAcquire(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(3, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        let capture = H2FlowBudgetNonLossGuardResponseTransportCapture()
        let writer = openSinkBackedResponseTransportWriter({ bytes =>
            capture.write(bytes)
        })

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLengthWithEndStream(1, 4, true), 1)
        let blocked = queue.tryDrainHeadChunk(4)
        @Assert(blocked.drained, false)
        let carrier =
            H2FlowBudgetNonLossGuardCurrentRequestCarrier(writer, false)
        var rejected = false
        try {
            let _ =
                dryRunJinguiAcceptedTransportH2LiveResponseWriterAcquisitionGate(
                    "live-response-writer-acquisition-gate",
                    h2FlowBudgetNonLossGuardTransport(),
                    blocked,
                    h2FlowBudgetNonLossGuardBytes("wait"),
                    carrier
                )
        } catch (_: Exception) {
            rejected = true
        }

        @Assert(rejected, true)
        @Assert(carrier.openCalls, 0)
        @Assert(capture.writeCalls, 0)
        @Assert(capture.totalBytes, 0)
    }

    @TestCase
    public func testWriterDataFrameLiveResponseWriterLeaseGateReusesWriterAcrossTwoDataFrames(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(20, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        let capture = H2FlowBudgetNonLossGuardResponseTransportCapture()

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLengthWithEndStream(1, 8, true), 1)
        let firstChunk = queue.tryDrainHeadChunk(4)
        let secondChunk = queue.tryDrainHeadChunk(4)
        let writer = openSinkBackedResponseTransportWriter({ bytes =>
            capture.write(bytes)
        })
        let carrier =
            H2FlowBudgetNonLossGuardCurrentRequestCarrier(writer, false)
        let lease =
            JinguiAcceptedTransportH2LiveResponseWriterLeaseGate(carrier)

        let first =
            lease.commitDataFrame(
                "live-response-writer-lease-gate",
                h2FlowBudgetNonLossGuardTransport(),
                firstChunk,
                h2FlowBudgetNonLossGuardBytes("part")
            )
        let second =
            lease.commitDataFrame(
                "live-response-writer-lease-gate",
                h2FlowBudgetNonLossGuardTransport(),
                secondChunk,
                h2FlowBudgetNonLossGuardBytes("done")
            )

        @Assert(first.acquisitionStatusName, "response-transport-writer-acquired")
        @Assert(first.statusName, "live-response-writer-lease-gate-complete")
        @Assert(first.endStream, false)
        @Assert(second.acquisitionStatusName, "response-transport-writer-reused")
        @Assert(second.statusName, "live-response-writer-lease-gate-complete")
        @Assert(second.endStream, true)
        @Assert(carrier.openCalls, 1)
        @Assert(lease.acquisitionCount(), 1)
        @Assert(capture.writeCalls, 2)
        @Assert(capture.totalBytes, 26)
        let firstParsed =
            parseJinguiAcceptedTransportH2FrameWire(capture.wireAt(0))
        let secondParsed =
            parseJinguiAcceptedTransportH2FrameWire(capture.wireAt(1))
        @Assert(firstParsed.flags, UInt8(0x0))
        @Assert(firstParsed.streamId, 1)
        @Assert(firstParsed.payload, h2FlowBudgetNonLossGuardBytes("part"))
        @Assert(secondParsed.flags, UInt8(0x1))
        @Assert(secondParsed.streamId, 1)
        @Assert(secondParsed.payload, h2FlowBudgetNonLossGuardBytes("done"))
    }

    @TestCase
    public func testWriterDataFrameLiveResponseWriterLeaseGatePropagatesWriterFailure(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(10, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        let writer = H2FlowBudgetNonLossGuardFailingResponseTransportWriter()

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLengthWithEndStream(1, 4, true), 1)
        let chunk = queue.tryDrainHeadChunk(4)
        let carrier =
            H2FlowBudgetNonLossGuardCurrentRequestCarrier(writer, false)
        let lease =
            JinguiAcceptedTransportH2LiveResponseWriterLeaseGate(carrier)
        var propagated = false
        try {
            let _ =
                lease.commitDataFrame(
                    "live-response-writer-lease-gate",
                    h2FlowBudgetNonLossGuardTransport(),
                    chunk,
                    h2FlowBudgetNonLossGuardBytes("fail")
                )
        } catch (_: Exception) {
            propagated = true
        }

        @Assert(propagated, true)
        @Assert(carrier.openCalls, 1)
        @Assert(lease.acquisitionCount(), 1)
        @Assert(writer.writeCalls, 1)
    }

    @TestCase
    public func testWriterDataFrameLiveResponseWriterLeaseGateRejectsBlockedDrainBeforeAcquire(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(3, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        let capture = H2FlowBudgetNonLossGuardResponseTransportCapture()
        let writer = openSinkBackedResponseTransportWriter({ bytes =>
            capture.write(bytes)
        })

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLengthWithEndStream(1, 4, true), 1)
        let blocked = queue.tryDrainHeadChunk(4)
        @Assert(blocked.drained, false)
        let carrier =
            H2FlowBudgetNonLossGuardCurrentRequestCarrier(writer, false)
        let lease =
            JinguiAcceptedTransportH2LiveResponseWriterLeaseGate(carrier)
        var rejected = false
        try {
            let _ =
                lease.commitDataFrame(
                    "live-response-writer-lease-gate",
                    h2FlowBudgetNonLossGuardTransport(),
                    blocked,
                    h2FlowBudgetNonLossGuardBytes("wait")
                )
        } catch (_: Exception) {
            rejected = true
        }

        @Assert(rejected, true)
        @Assert(carrier.openCalls, 0)
        @Assert(lease.acquisitionCount(), 0)
        @Assert(capture.writeCalls, 0)
        @Assert(capture.totalBytes, 0)
    }

    @TestCase
    public func testWriterDataFrameAcceptedSocketResponseWriterHandoffGateReusesWriterAndPreservesTransport(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(20, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        let capture = H2FlowBudgetNonLossGuardResponseTransportCapture()

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLengthWithEndStream(1, 8, true), 1)
        let firstChunk = queue.tryDrainHeadChunk(4)
        let secondChunk = queue.tryDrainHeadChunk(4)
        let writer = openSinkBackedResponseTransportWriter({ bytes =>
            capture.write(bytes)
        })
        let carrier =
            H2FlowBudgetNonLossGuardCurrentRequestCarrier(writer, false)
        let handoff =
            JinguiAcceptedTransportH2AcceptedSocketResponseWriterHandoffGate(
                h2FlowBudgetNonLossGuardTransport(),
                carrier
            )

        let first =
            handoff.commitDataFrame(
                "accepted-socket-response-writer-handoff-gate",
                firstChunk,
                h2FlowBudgetNonLossGuardBytes("part")
            )
        let second =
            handoff.commitDataFrame(
                "accepted-socket-response-writer-handoff-gate",
                secondChunk,
                h2FlowBudgetNonLossGuardBytes("done")
            )

        @Assert(handoff.transportId(), "h2-flow-budget-transport")
        @Assert(handoff.transportKind(), "accepted-socket")
        @Assert(first.transportId, "h2-flow-budget-transport")
        @Assert(first.transportKind, "accepted-socket")
        @Assert(first.acquisitionStatusName, "response-transport-writer-acquired")
        @Assert(first.statusName, "live-response-writer-lease-gate-complete")
        @Assert(first.endStream, false)
        @Assert(second.transportId, "h2-flow-budget-transport")
        @Assert(second.transportKind, "accepted-socket")
        @Assert(second.acquisitionStatusName, "response-transport-writer-reused")
        @Assert(second.statusName, "live-response-writer-lease-gate-complete")
        @Assert(second.endStream, true)
        @Assert(carrier.openCalls, 1)
        @Assert(handoff.acquisitionCount(), 1)
        @Assert(capture.writeCalls, 2)
        @Assert(capture.totalBytes, 26)
        let firstParsed =
            parseJinguiAcceptedTransportH2FrameWire(capture.wireAt(0))
        let secondParsed =
            parseJinguiAcceptedTransportH2FrameWire(capture.wireAt(1))
        @Assert(firstParsed.flags, UInt8(0x0))
        @Assert(firstParsed.streamId, 1)
        @Assert(firstParsed.payload, h2FlowBudgetNonLossGuardBytes("part"))
        @Assert(secondParsed.flags, UInt8(0x1))
        @Assert(secondParsed.streamId, 1)
        @Assert(secondParsed.payload, h2FlowBudgetNonLossGuardBytes("done"))
    }

    @TestCase
    public func testWriterDataFrameAcceptedSocketResponseWriterHandoffGatePropagatesWriterFailure(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(10, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        let writer = H2FlowBudgetNonLossGuardFailingResponseTransportWriter()

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLengthWithEndStream(1, 4, true), 1)
        let chunk = queue.tryDrainHeadChunk(4)
        let carrier =
            H2FlowBudgetNonLossGuardCurrentRequestCarrier(writer, false)
        let handoff =
            JinguiAcceptedTransportH2AcceptedSocketResponseWriterHandoffGate(
                h2FlowBudgetNonLossGuardTransport(),
                carrier
            )
        var propagated = false
        try {
            let _ =
                handoff.commitDataFrame(
                    "accepted-socket-response-writer-handoff-gate",
                    chunk,
                    h2FlowBudgetNonLossGuardBytes("fail")
                )
        } catch (_: Exception) {
            propagated = true
        }

        @Assert(propagated, true)
        @Assert(carrier.openCalls, 1)
        @Assert(handoff.acquisitionCount(), 1)
        @Assert(writer.writeCalls, 1)
    }

    @TestCase
    public func testWriterDataFrameAcceptedSocketResponseWriterHandoffGateRejectsBlockedDrainBeforeAcquire(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(3, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        let capture = H2FlowBudgetNonLossGuardResponseTransportCapture()
        let writer = openSinkBackedResponseTransportWriter({ bytes =>
            capture.write(bytes)
        })

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLengthWithEndStream(1, 4, true), 1)
        let blocked = queue.tryDrainHeadChunk(4)
        @Assert(blocked.drained, false)
        let carrier =
            H2FlowBudgetNonLossGuardCurrentRequestCarrier(writer, false)
        let handoff =
            JinguiAcceptedTransportH2AcceptedSocketResponseWriterHandoffGate(
                h2FlowBudgetNonLossGuardTransport(),
                carrier
            )
        var rejected = false
        try {
            let _ =
                handoff.commitDataFrame(
                    "accepted-socket-response-writer-handoff-gate",
                    blocked,
                    h2FlowBudgetNonLossGuardBytes("wait")
                )
        } catch (_: Exception) {
            rejected = true
        }

        @Assert(rejected, true)
        @Assert(carrier.openCalls, 0)
        @Assert(handoff.acquisitionCount(), 0)
        @Assert(capture.writeCalls, 0)
        @Assert(capture.totalBytes, 0)
    }

    @TestCase
    public func testAcceptedSocketQueuedDataPayloadCommitSeamDrainsAndReusesWriter(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(20, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        let capture = H2FlowBudgetNonLossGuardResponseTransportCapture()

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLengthWithEndStream(1, 8, true), 1)
        let writer = openSinkBackedResponseTransportWriter({ bytes =>
            capture.write(bytes)
        })
        let carrier =
            H2FlowBudgetNonLossGuardCurrentRequestCarrier(writer, false)
        let handoff =
            JinguiAcceptedTransportH2AcceptedSocketResponseWriterHandoffGate(
                h2FlowBudgetNonLossGuardTransport(),
                carrier
            )

        let first =
            handoff.commitNextQueuedDataPayload(
                "accepted-socket-queued-data-payload-commit-seam",
                queue,
                h2FlowBudgetNonLossGuardBytes("part")
            )
        let second =
            handoff.commitNextQueuedDataPayload(
                "accepted-socket-queued-data-payload-commit-seam",
                queue,
                h2FlowBudgetNonLossGuardBytes("done")
            )

        @Assert(first.acquisitionStatusName, "response-transport-writer-acquired")
        @Assert(first.endStream, false)
        @Assert(second.acquisitionStatusName, "response-transport-writer-reused")
        @Assert(second.endStream, true)
        @Assert(queue.pendingCount(), 0)
        @Assert(model.connectionSendBudget(), 12)
        @Assert(model.streamSendBudget(1), 12)
        @Assert(carrier.openCalls, 1)
        @Assert(handoff.acquisitionCount(), 1)
        @Assert(capture.writeCalls, 2)
        @Assert(capture.totalBytes, 26)
        let firstParsed =
            parseJinguiAcceptedTransportH2FrameWire(capture.wireAt(0))
        let secondParsed =
            parseJinguiAcceptedTransportH2FrameWire(capture.wireAt(1))
        @Assert(firstParsed.flags, UInt8(0x0))
        @Assert(firstParsed.payload, h2FlowBudgetNonLossGuardBytes("part"))
        @Assert(secondParsed.flags, UInt8(0x1))
        @Assert(secondParsed.payload, h2FlowBudgetNonLossGuardBytes("done"))
    }

    @TestCase
    public func testAcceptedSocketQueuedDataPayloadCommitSeamWaitsForWindowUpdateBeforeAcquire(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(3, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        let capture = H2FlowBudgetNonLossGuardResponseTransportCapture()
        let writer = openSinkBackedResponseTransportWriter({ bytes =>
            capture.write(bytes)
        })

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLengthWithEndStream(1, 4, true), 1)
        let carrier =
            H2FlowBudgetNonLossGuardCurrentRequestCarrier(writer, false)
        let handoff =
            JinguiAcceptedTransportH2AcceptedSocketResponseWriterHandoffGate(
                h2FlowBudgetNonLossGuardTransport(),
                carrier
            )
        var rejected = false
        try {
            let _ =
                handoff.commitNextQueuedDataPayload(
                    "accepted-socket-queued-data-payload-commit-seam",
                    queue,
                    h2FlowBudgetNonLossGuardBytes("wait")
                )
        } catch (_: Exception) {
            rejected = true
        }

        @Assert(rejected, true)
        @Assert(queue.pendingCount(), 1)
        @Assert(queue.headRemainingByteCount(), 4)
        @Assert(model.connectionSendBudget(), 3)
        @Assert(model.streamSendBudget(1), 20)
        @Assert(carrier.openCalls, 0)
        @Assert(handoff.acquisitionCount(), 0)
        @Assert(capture.writeCalls, 0)
        @Assert(capture.totalBytes, 0)
    }

    @TestCase
    public func testAcceptedSocketQueuedDataPayloadCommitSeamRejectsOversizedPayloadBeforeDrain(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(20, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        let capture = H2FlowBudgetNonLossGuardResponseTransportCapture()
        let writer = openSinkBackedResponseTransportWriter({ bytes =>
            capture.write(bytes)
        })

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLengthWithEndStream(1, 4, true), 1)
        let carrier =
            H2FlowBudgetNonLossGuardCurrentRequestCarrier(writer, false)
        let handoff =
            JinguiAcceptedTransportH2AcceptedSocketResponseWriterHandoffGate(
                h2FlowBudgetNonLossGuardTransport(),
                carrier
            )
        var rejected = false
        try {
            let _ =
                handoff.commitNextQueuedDataPayload(
                    "accepted-socket-queued-data-payload-commit-seam",
                    queue,
                    h2FlowBudgetNonLossGuardBytes("too-long")
                )
        } catch (_: Exception) {
            rejected = true
        }

        @Assert(rejected, true)
        @Assert(queue.pendingCount(), 1)
        @Assert(queue.headRemainingByteCount(), 4)
        @Assert(model.connectionSendBudget(), 20)
        @Assert(model.streamSendBudget(1), 20)
        @Assert(carrier.openCalls, 0)
        @Assert(handoff.acquisitionCount(), 0)
        @Assert(capture.writeCalls, 0)
        @Assert(capture.totalBytes, 0)
    }

    @TestCase
    public func testWriterDataFrameAcceptedSocketResponseWriterLifecycleProbeWritesThroughCarrierLifecycle(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(20, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        let capture = H2FlowBudgetNonLossGuardResponseTransportCapture()
        let lifecycle =
            ServerJinguiAcceptedTransportSocketResponseWriterLifecycle(
                { bytes => capture.write(bytes) }
            )

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLengthWithEndStream(1, 8, true), 1)
        let carrier =
            H2FlowBudgetNonLossGuardAcceptedSocketLifecycleCarrier(
                lifecycle,
                false
            )
        let handoff =
            JinguiAcceptedTransportH2AcceptedSocketResponseWriterHandoffGate(
                h2FlowBudgetNonLossGuardTransport(),
                carrier
            )

        let first =
            handoff.commitNextQueuedDataPayload(
                "accepted-socket-response-writer-lifecycle-probe",
                queue,
                h2FlowBudgetNonLossGuardBytes("part")
            )
        let second =
            handoff.commitNextQueuedDataPayload(
                "accepted-socket-response-writer-lifecycle-probe",
                queue,
                h2FlowBudgetNonLossGuardBytes("done")
            )

        @Assert(first.transportId, "h2-flow-budget-transport")
        @Assert(first.transportKind, "accepted-socket")
        @Assert(first.acquisitionStatusName, "response-transport-writer-acquired")
        @Assert(second.transportId, "h2-flow-budget-transport")
        @Assert(second.transportKind, "accepted-socket")
        @Assert(second.acquisitionStatusName, "response-transport-writer-reused")
        @Assert(second.endStream, true)
        @Assert(carrier.openCalls, 1)
        @Assert(handoff.acquisitionCount(), 1)
        @Assert(lifecycle.socketWriteCount, 2)
        @Assert(lifecycle.totalEncodedSocketBytes, 26)
        @Assert(capture.writeCalls, 2)
        @Assert(capture.totalBytes, 26)
        let firstParsed =
            parseJinguiAcceptedTransportH2FrameWire(capture.wireAt(0))
        let secondParsed =
            parseJinguiAcceptedTransportH2FrameWire(capture.wireAt(1))
        @Assert(firstParsed.flags, UInt8(0x0))
        @Assert(firstParsed.payload, h2FlowBudgetNonLossGuardBytes("part"))
        @Assert(secondParsed.flags, UInt8(0x1))
        @Assert(secondParsed.payload, h2FlowBudgetNonLossGuardBytes("done"))
    }

    @TestCase
    public func testWriterDataFrameAcceptedSocketResponseWriterLifecycleProbeRejectsBlockedDrainBeforeCarrierOpen(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(3, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        let capture = H2FlowBudgetNonLossGuardResponseTransportCapture()
        let lifecycle =
            ServerJinguiAcceptedTransportSocketResponseWriterLifecycle(
                { bytes => capture.write(bytes) }
            )

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLengthWithEndStream(1, 4, true), 1)
        let carrier =
            H2FlowBudgetNonLossGuardAcceptedSocketLifecycleCarrier(
                lifecycle,
                false
            )
        let handoff =
            JinguiAcceptedTransportH2AcceptedSocketResponseWriterHandoffGate(
                h2FlowBudgetNonLossGuardTransport(),
                carrier
            )
        var rejected = false
        try {
            let _ =
                handoff.commitNextQueuedDataPayload(
                    "accepted-socket-response-writer-lifecycle-probe",
                    queue,
                    h2FlowBudgetNonLossGuardBytes("wait")
                )
        } catch (_: Exception) {
            rejected = true
        }

        @Assert(rejected, true)
        @Assert(carrier.openCalls, 0)
        @Assert(handoff.acquisitionCount(), 0)
        @Assert(lifecycle.socketWriteCount, 0)
        @Assert(lifecycle.totalEncodedSocketBytes, 0)
        @Assert(capture.writeCalls, 0)
        @Assert(capture.totalBytes, 0)
    }

    @TestCase
    public func testWriterDataFrameAcceptedSocketResponseWriterLifecycleProbePropagatesSinkFailure(): Unit {
        let model = JinguiAcceptedTransportH2FlowBudgetModel(10, 20)
        let gate = JinguiAcceptedTransportH2WriterFlowGate(model)
        let queue = JinguiAcceptedTransportH2WriterFlowQueue(gate)
        let failingSink = H2FlowBudgetNonLossGuardFailingAcceptedSocketSink()
        let lifecycle =
            ServerJinguiAcceptedTransportSocketResponseWriterLifecycle(
                { bytes => failingSink.write(bytes) }
            )

        model.observeHeaders(
            JinguiAcceptedTransportH2HeaderBlockSnapshot(
                1,
                false,
                false,
                false,
                false,
                0,
                0,
                h2FlowBudgetNonLossGuardBytes("s1")
            )
        )

        @Assert(queue.enqueueDataLengthWithEndStream(1, 4, true), 1)
        let chunk = queue.tryDrainHeadChunk(4)
        let carrier =
            H2FlowBudgetNonLossGuardAcceptedSocketLifecycleCarrier(
                lifecycle,
                false
            )
        let handoff =
            JinguiAcceptedTransportH2AcceptedSocketResponseWriterHandoffGate(
                h2FlowBudgetNonLossGuardTransport(),
                carrier
            )
        var propagated = false
        try {
            let _ =
                handoff.commitDataFrame(
                    "accepted-socket-response-writer-lifecycle-probe",
                    chunk,
                    h2FlowBudgetNonLossGuardBytes("fail")
                )
        } catch (_: Exception) {
            propagated = true
        }

        @Assert(propagated, true)
        @Assert(carrier.openCalls, 1)
        @Assert(handoff.acquisitionCount(), 1)
        @Assert(lifecycle.socketWriteCount, 0)
        @Assert(lifecycle.totalEncodedSocketBytes, 0)
        @Assert(failingSink.writeCalls, 1)
    }
}

class H2FlowBudgetNonLossGuardAcceptedSocketLifecycleCarrier <: CurrentRequestCarrier {
    let lifecycle: ServerJinguiAcceptedTransportSocketResponseWriterLifecycle
    let failOnOpen: Bool
    let body = H2FlowBudgetNonLossGuardEmptyInputStream()
    public var openCalls: Int64 = 0

    init(
        lifecycle: ServerJinguiAcceptedTransportSocketResponseWriterLifecycle,
        failOnOpen: Bool
    ) {
        this.lifecycle = lifecycle
        this.failOnOpen = failOnOpen
    }

    public override func rawHttpContext(): HttpContext {
        throw Exception("raw HttpContext should not be required for H2 accepted-socket lifecycle probe")
    }

    public override func upgradeWebSocketRaw(): WebSocket {
        throw Exception("websocket upgrade should not run in H2 accepted-socket lifecycle probe")
    }

    public override func openResponseTransportWriterRaw(): ResponseTransportWriter {
        openCalls += 1
        if (failOnOpen) {
            throw Exception("accepted-socket lifecycle writer acquisition failed")
        }
        lifecycle.openResponseTransportWriter()
    }

    public override func requestMethod(): String {
        "GET"
    }

    public override func requestPath(): String {
        "/h2-accepted-socket-lifecycle"
    }

    public override func requestUrlString(): String {
        "/h2-accepted-socket-lifecycle"
    }

    public override func requestVersionString(): String {
        "HTTP/2"
    }

    public override func requestRemoteAddr(): String {
        "127.0.0.1"
    }

    public override func requestQueryValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestFormValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestHeaderValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestHeaderFields(): Array<(String, String)> {
        []
    }

    public override func requestTrailerValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestTrailerFields(): Array<(String, String)> {
        []
    }

    public override func requestBodyStream(): InputStream {
        body
    }

    public override func requestBodySize(): ?Int64 {
        Some(Int64(0))
    }

    public override func setResponseStatus(code: UInt16): Unit {
        let _ = code
    }

    public override func setResponseHeader(key: String, value: String): Unit {
        let _ = key
        let _ = value
    }

    public override func addResponseHeader(key: String, value: String): Unit {
        let _ = key
        let _ = value
    }

    public override func setResponseString(body: String): Unit {
        let _ = body
    }

    public override func setResponseBytes(data: Array<UInt8>): Unit {
        let _ = data
    }

    public override func attachResponseBodyStream(stream: InputStream): Unit {
        let _ = stream
    }
}

class H2FlowBudgetNonLossGuardCurrentRequestCarrier <: CurrentRequestCarrier {
    let writer: ResponseTransportWriter
    let failOnOpen: Bool
    let body = H2FlowBudgetNonLossGuardEmptyInputStream()
    public var openCalls: Int64 = 0

    init(writer: ResponseTransportWriter, failOnOpen: Bool) {
        this.writer = writer
        this.failOnOpen = failOnOpen
    }

    public override func rawHttpContext(): HttpContext {
        throw Exception("raw HttpContext should not be required for H2 live response writer acquisition gate")
    }

    public override func upgradeWebSocketRaw(): WebSocket {
        throw Exception("websocket upgrade should not run in H2 live response writer acquisition gate")
    }

    public override func openResponseTransportWriterRaw(): ResponseTransportWriter {
        openCalls += 1
        if (failOnOpen) {
            throw Exception("response transport writer acquisition failed")
        }
        writer
    }

    public override func requestMethod(): String {
        "GET"
    }

    public override func requestPath(): String {
        "/h2-live-writer"
    }

    public override func requestUrlString(): String {
        "/h2-live-writer"
    }

    public override func requestVersionString(): String {
        "HTTP/2"
    }

    public override func requestRemoteAddr(): String {
        "127.0.0.1"
    }

    public override func requestQueryValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestFormValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestHeaderValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestHeaderFields(): Array<(String, String)> {
        []
    }

    public override func requestTrailerValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestTrailerFields(): Array<(String, String)> {
        []
    }

    public override func requestBodyStream(): InputStream {
        body
    }

    public override func requestBodySize(): ?Int64 {
        Some(Int64(0))
    }

    public override func setResponseStatus(code: UInt16): Unit {
        let _ = code
    }

    public override func setResponseHeader(key: String, value: String): Unit {
        let _ = key
        let _ = value
    }

    public override func addResponseHeader(key: String, value: String): Unit {
        let _ = key
        let _ = value
    }

    public override func setResponseString(body: String): Unit {
        let _ = body
    }

    public override func setResponseBytes(data: Array<UInt8>): Unit {
        let _ = data
    }

    public override func attachResponseBodyStream(stream: InputStream): Unit {
        let _ = stream
    }
}

class H2FlowBudgetNonLossGuardEmptyInputStream <: InputStream {
    public override func read(outBuf: Array<Byte>): Int64 {
        let _ = outBuf
        0
    }
}

func h2FlowBudgetNonLossGuardBytes(text: String): Array<Byte> {
    let input = text.toArray()
    let out = Array<Byte>(input.size, repeat: 0)
    var i: Int64 = 0
    while (i < input.size) {
        out[i] = input[i]
        i += 1
    }
    out
}

func h2FlowBudgetNonLossGuardWindowUpdatePayload(increment: Int64): Array<Byte> {
    let out = Array<Byte>(4, repeat: 0)
    out[0] = UInt8((increment >> 24) & 0xff)
    out[1] = UInt8((increment >> 16) & 0xff)
    out[2] = UInt8((increment >> 8) & 0xff)
    out[3] = UInt8(increment & 0xff)
    out
}

func h2FlowBudgetNonLossGuardTransport(): ServerJinguiAcceptedTransportDescriptorSnapshot {
    ServerJinguiAcceptedTransportDescriptorSnapshot(
        "h2-flow-budget-transport",
        "accepted-socket",
        "127.0.0.1:443",
        "127.0.0.1:50000"
    )
}

class H2FlowBudgetNonLossGuardSocketAdapterContractSink <: JinguiAcceptedTransportH2FrameWireWriterSink {
    public var writeCalls: Int64 = 0
    public var totalBytes: Int64 = 0
    let _wires = ArrayList<Array<Byte>>()

    public override func writeFrameWire(frameWire: Array<Byte>): Int64 {
        writeCalls += 1
        totalBytes += frameWire.size
        _wires.add(h2FlowBudgetNonLossGuardCloneBytes(frameWire))
        frameWire.size
    }

    public func lastWire(): Array<Byte> {
        if (_wires.size == 0) {
            throw Exception("adapter contract sink has no frame wire")
        }
        h2FlowBudgetNonLossGuardCloneBytes(_wires[_wires.size - 1])
    }
}

func h2FlowBudgetNonLossGuardCloneBytes(input: Array<Byte>): Array<Byte> {
    let out = Array<Byte>(input.size, repeat: 0)
    var i: Int64 = 0
    while (i < input.size) {
        out[i] = input[i]
        i += 1
    }
    out
}

class H2FlowBudgetNonLossGuardFunctionSinkCapture {
    public var writeCalls: Int64 = 0
    let _wires = ArrayList<Array<Byte>>()

    public func write(wire: Array<Byte>): Int64 {
        writeCalls += 1
        _wires.add(h2FlowBudgetNonLossGuardCloneBytes(wire))
        wire.size
    }

    public func lastWire(): Array<Byte> {
        if (_wires.size == 0) {
            throw Exception("function sink capture has no frame wire")
        }
        h2FlowBudgetNonLossGuardCloneBytes(_wires[_wires.size - 1])
    }
}

class H2FlowBudgetNonLossGuardResponseTransportCapture {
    public var writeCalls: Int64 = 0
    public var totalBytes: Int64 = 0
    let _wires = ArrayList<Array<UInt8>>()

    public func write(wire: Array<UInt8>): Unit {
        writeCalls += 1
        totalBytes += wire.size
        _wires.add(h2FlowBudgetNonLossGuardCloneUInt8Bytes(wire))
    }

    public func lastWire(): Array<Byte> {
        if (_wires.size == 0) {
            throw Exception("response transport capture has no frame wire")
        }
        h2FlowBudgetNonLossGuardUInt8BytesAsBytes(_wires[_wires.size - 1])
    }

    public func wireAt(index: Int64): Array<Byte> {
        if (index < 0 || index >= _wires.size) {
            throw Exception("response transport capture frame index out of range")
        }
        h2FlowBudgetNonLossGuardUInt8BytesAsBytes(_wires[index])
    }
}

class H2FlowBudgetNonLossGuardFailingResponseTransportWriter <: ResponseTransportWriter {
    public var writeCalls: Int64 = 0

    public override func write(data: Array<UInt8>): Unit {
        writeCalls += 1
        throw Exception("response transport writer failed")
    }
}

class H2FlowBudgetNonLossGuardFailingAcceptedSocketSink {
    public var writeCalls: Int64 = 0

    public func write(data: Array<UInt8>): Unit {
        let _ = data
        writeCalls += 1
        throw Exception("accepted-socket lifecycle sink failed")
    }
}

func h2FlowBudgetNonLossGuardCloneUInt8Bytes(input: Array<UInt8>): Array<UInt8> {
    let out = Array<UInt8>(input.size, repeat: 0)
    var i: Int64 = 0
    while (i < input.size) {
        out[i] = input[i]
        i += 1
    }
    out
}

func h2FlowBudgetNonLossGuardUInt8BytesAsBytes(input: Array<UInt8>): Array<Byte> {
    let out = Array<Byte>(input.size, repeat: 0)
    var i: Int64 = 0
    while (i < input.size) {
        out[i] = input[i]
        i += 1
    }
    out
}
