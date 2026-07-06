package ignite.tests

import ignite.*

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
