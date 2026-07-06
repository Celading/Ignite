package ignite.tests

import ignite.*
import std.collection.ArrayList

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
