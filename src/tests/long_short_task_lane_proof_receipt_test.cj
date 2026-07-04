package ignite.tests

import ignite.*

@Test
public class LongShortTaskLaneProofReceiptTestSuite {
    private func acceptedRequestSchedulerReceipt(): IgniteRequestSchedulerProofReceipt {
        buildIgniteRequestSchedulerProofReceipt(
            IgniteRequestSchedulerProofEvidence(
                "request-level",
                true,
                true,
                true,
                true
            )
        )
    }

    private func acceptedBlockingIsolationReceipt(
        requestSchedulerReceipt: IgniteRequestSchedulerProofReceipt
    ): IgniteBlockingExternalOperationIsolationProofReceipt {
        buildIgniteBlockingExternalOperationIsolationProofReceipt(
            IgniteBlockingExternalOperationIsolationEvidence(
                requestSchedulerReceipt,
                true,
                true,
                "blocking-isolation-lane",
                true,
                true,
                true
            )
        )
    }

    @TestCase
    public func testLongShortTaskLaneProofBlocksIncompleteLaneEvidence(): Unit {
        let requestSchedulerReceipt = acceptedRequestSchedulerReceipt()
        let blockingIsolationReceipt =
            acceptedBlockingIsolationReceipt(requestSchedulerReceipt)
        let receipt = buildIgniteLongShortTaskLaneProofReceipt(
            IgniteLongShortTaskLaneProofEvidence(
                requestSchedulerReceipt,
                blockingIsolationReceipt,
                true,
                false,
                true,
                false,
                true,
                true
            )
        )

        @Assert(receipt.status, "blocked-long-short-task-lane-proof-gap")
        @Assert(receipt.decision, "collect-short-long-lane-handoff-starvation-and-observability-proof")
        @Assert(receipt.longShortTaskLaneProofAccepted, false)
        @Assert(receipt.runtimeNativeClaimAllowed, false)
        @Assert(receipt.blockers[0], "LONG_TASK_LANE_NOT_IDENTIFIED")
        @Assert(receipt.blockers[1], "STARVATION_GUARD_PROOF_MISSING")
        @Assert(receipt.runtimeDesignGate.missingProofs[0], "LONG_SHORT_TASK_LANE_PROOF")
        @Assert(receipt.runtimeDesignGate.missingProofs[1], "FAIRNESS_BACKPRESSURE_PROOF")
        @Assert(receipt.nonClaims[0], "NO_RUNTIME_SCHEDULER_IMPLEMENTATION")
    }

    @TestCase
    public func testAcceptedLongShortTaskLaneProofStillBlocksRuntimeNativeClaim(): Unit {
        let requestSchedulerReceipt = acceptedRequestSchedulerReceipt()
        let blockingIsolationReceipt =
            acceptedBlockingIsolationReceipt(requestSchedulerReceipt)
        let receipt = buildIgniteLongShortTaskLaneProofReceipt(
            IgniteLongShortTaskLaneProofEvidence(
                requestSchedulerReceipt,
                blockingIsolationReceipt,
                true,
                true,
                true,
                true,
                true,
                true
            )
        )

        @Assert(receipt.status, "accepted-long-short-task-lane-proof")
        @Assert(receipt.decision, "carry-long-short-task-lane-proof-into-runtime-design-gate")
        @Assert(receipt.longShortTaskLaneProofAccepted, true)
        @Assert(receipt.runtimeNativeClaimAllowed, false)
        @Assert(receipt.blockers.size, 0)
        @Assert(receipt.runtimeDesignGate.status, "blocked-runtime-native-claim-gap")
        @Assert(receipt.runtimeDesignGate.missingProofs.size, 1)
        @Assert(receipt.runtimeDesignGate.missingProofs[0], "FAIRNESS_BACKPRESSURE_PROOF")
        @Assert(receipt.nonClaims[2], "NO_FAIRNESS_BACKPRESSURE_PROOF")
    }
}
