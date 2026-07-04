package ignite.tests

import ignite.*

@Test
public class BlockingExternalOperationIsolationProofReceiptTestSuite {
    @TestCase
    public func testBlockingIsolationProofBlocksUnsafeLaneEvidence(): Unit {
        let requestSchedulerReceipt = buildIgniteRequestSchedulerProofReceipt(
            IgniteRequestSchedulerProofEvidence(
                "request-level",
                true,
                true,
                true,
                true
            )
        )
        let receipt =
            buildIgniteBlockingExternalOperationIsolationProofReceipt(
                IgniteBlockingExternalOperationIsolationEvidence(
                    requestSchedulerReceipt,
                    true,
                    true,
                    "handler-lane",
                    false,
                    true,
                    true
                )
            )

        @Assert(receipt.status, "blocked-blocking-external-operation-isolation-proof-gap")
        @Assert(receipt.decision, "collect-blocking-operation-inventory-risk-lane-and-guard-proof")
        @Assert(receipt.blockingExternalOperationIsolationProofAccepted, false)
        @Assert(receipt.runtimeNativeClaimAllowed, false)
        @Assert(receipt.blockers[0], "ISOLATED_EXECUTION_LANE_MISSING")
        @Assert(receipt.blockers[1], "SCHEDULER_PROTECTION_BOUNDARY_MISSING")
        @Assert(receipt.runtimeDesignGate.missingProofs[0], "LONG_SHORT_TASK_LANE_PROOF")
        @Assert(receipt.runtimeDesignGate.missingProofs[1], "BLOCKING_EXTERNAL_OPERATION_ISOLATION_PROOF")
        @Assert(receipt.nonClaims[0], "NO_RUNTIME_SCHEDULER_IMPLEMENTATION")
    }

    @TestCase
    public func testAcceptedBlockingIsolationProofStillBlocksRuntimeNativeClaim(): Unit {
        let requestSchedulerReceipt = buildIgniteRequestSchedulerProofReceipt(
            IgniteRequestSchedulerProofEvidence(
                "request-level",
                true,
                true,
                true,
                true
            )
        )
        let receipt =
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

        @Assert(receipt.status, "accepted-blocking-external-operation-isolation-proof")
        @Assert(receipt.decision, "carry-blocking-isolation-proof-into-runtime-design-gate")
        @Assert(receipt.blockingExternalOperationIsolationProofAccepted, true)
        @Assert(receipt.runtimeNativeClaimAllowed, false)
        @Assert(receipt.blockers.size, 0)
        @Assert(receipt.runtimeDesignGate.status, "blocked-runtime-native-claim-gap")
        @Assert(receipt.runtimeDesignGate.missingProofs.size, 2)
        @Assert(receipt.runtimeDesignGate.missingProofs[0], "LONG_SHORT_TASK_LANE_PROOF")
        @Assert(receipt.runtimeDesignGate.missingProofs[1], "FAIRNESS_BACKPRESSURE_PROOF")
        @Assert(receipt.nonClaims[3], "NO_FAIRNESS_BACKPRESSURE_PROOF")
    }
}
