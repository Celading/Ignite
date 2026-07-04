package ignite.tests

import ignite.*

@Test
public class RequestSchedulerProofReceiptTestSuite {
    @TestCase
    public func testRequestSchedulerProofBlocksConnectionLevelOnlyEvidence(): Unit {
        let receipt = buildIgniteRequestSchedulerProofReceipt(
            IgniteRequestSchedulerProofEvidence(
                "connection-level",
                false,
                true,
                true,
                false
            )
        )

        @Assert(receipt.status, "blocked-request-scheduler-proof-gap")
        @Assert(receipt.decision, "collect-request-identity-and-handler-io-boundary-proof")
        @Assert(receipt.requestLevelSchedulerProofAccepted, false)
        @Assert(receipt.handlerIoDecouplingProofAccepted, false)
        @Assert(receipt.runtimeNativeClaimAllowed, false)
        @Assert(receipt.blockers[0], "SCOPE_NOT_REQUEST_LEVEL")
        @Assert(receipt.blockers[1], "REQUEST_IDENTITY_NOT_CARRIED")
        @Assert(receipt.blockers[2], "CONNECTION_LEVEL_ONLY_FALLBACK_NOT_BLOCKED")
        @Assert(receipt.runtimeDesignGate.missingProofs[0], "REQUEST_LEVEL_SCHEDULER_PROOF")
        @Assert(receipt.nonClaims[0], "NO_SCHEDULER_IMPLEMENTATION")
    }

    @TestCase
    public func testAcceptedRequestSchedulerProofStillBlocksRuntimeNativeClaim(): Unit {
        let receipt = buildIgniteRequestSchedulerProofReceipt(
            IgniteRequestSchedulerProofEvidence(
                "request-level",
                true,
                true,
                true,
                true
            )
        )

        @Assert(receipt.status, "accepted-request-scheduler-proof")
        @Assert(receipt.decision, "carry-request-scheduler-proof-into-runtime-design-gate")
        @Assert(receipt.requestLevelSchedulerProofAccepted, true)
        @Assert(receipt.handlerIoDecouplingProofAccepted, true)
        @Assert(receipt.runtimeNativeClaimAllowed, false)
        @Assert(receipt.blockers.size, 0)
        @Assert(receipt.runtimeDesignGate.status, "blocked-runtime-native-claim-gap")
        @Assert(receipt.runtimeDesignGate.missingProofs.size, 3)
        @Assert(receipt.runtimeDesignGate.missingProofs[0], "LONG_SHORT_TASK_LANE_PROOF")
        @Assert(receipt.runtimeDesignGate.missingProofs[1], "BLOCKING_EXTERNAL_OPERATION_ISOLATION_PROOF")
        @Assert(receipt.runtimeDesignGate.missingProofs[2], "FAIRNESS_BACKPRESSURE_PROOF")
        @Assert(receipt.nonClaims[4], "NO_RUNTIME_NATIVE_CLAIM")
    }
}

