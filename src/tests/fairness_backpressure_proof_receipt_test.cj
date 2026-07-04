package ignite.tests

import ignite.*

@Test
public class FairnessBackpressureProofReceiptTestSuite {
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

    private func acceptedLongShortTaskLaneReceipt(
        requestSchedulerReceipt: IgniteRequestSchedulerProofReceipt,
        blockingIsolationReceipt: IgniteBlockingExternalOperationIsolationProofReceipt
    ): IgniteLongShortTaskLaneProofReceipt {
        buildIgniteLongShortTaskLaneProofReceipt(
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
    }

    @TestCase
    public func testFairnessBackpressureProofBlocksMissingPressureAndOverloadPolicy(): Unit {
        let requestSchedulerReceipt = acceptedRequestSchedulerReceipt()
        let blockingIsolationReceipt =
            acceptedBlockingIsolationReceipt(requestSchedulerReceipt)
        let longShortTaskLaneReceipt = acceptedLongShortTaskLaneReceipt(
            requestSchedulerReceipt,
            blockingIsolationReceipt
        )
        let receipt = buildIgniteFairnessBackpressureProofReceipt(
            IgniteFairnessBackpressureProofEvidence(
                requestSchedulerReceipt,
                blockingIsolationReceipt,
                longShortTaskLaneReceipt,
                true,
                true,
                false,
                false,
                true,
                true
            )
        )

        @Assert(receipt.status, "blocked-fairness-backpressure-proof-gap")
        @Assert(receipt.decision, "collect-bounded-queue-fairness-pressure-overload-accounting-proof")
        @Assert(receipt.fairnessBackpressureProofAccepted, false)
        @Assert(receipt.runtimeNativeClaimAllowed, false)
        @Assert(receipt.implementationPacketAllowed, false)
        @Assert(receipt.blockers[0], "PRESSURE_SIGNAL_PROPAGATION_MISSING")
        @Assert(receipt.blockers[1], "OVERLOAD_REJECTION_OR_DEFERRAL_POLICY_MISSING")
        @Assert(receipt.runtimeDesignGate.missingProofs[0], "FAIRNESS_BACKPRESSURE_PROOF")
        @Assert(receipt.nonClaims[0], "NO_RUNTIME_SCHEDULER_IMPLEMENTATION")
    }

    @TestCase
    public func testAcceptedFairnessBackpressureProofAllowsOnlyImplementationPacket(): Unit {
        let requestSchedulerReceipt = acceptedRequestSchedulerReceipt()
        let blockingIsolationReceipt =
            acceptedBlockingIsolationReceipt(requestSchedulerReceipt)
        let longShortTaskLaneReceipt = acceptedLongShortTaskLaneReceipt(
            requestSchedulerReceipt,
            blockingIsolationReceipt
        )
        let receipt = buildIgniteFairnessBackpressureProofReceipt(
            IgniteFairnessBackpressureProofEvidence(
                requestSchedulerReceipt,
                blockingIsolationReceipt,
                longShortTaskLaneReceipt,
                true,
                true,
                true,
                true,
                true,
                true
            )
        )

        @Assert(receipt.status, "accepted-fairness-backpressure-proof")
        @Assert(receipt.decision, "open-bounded-runtime-scheduler-implementation-packet")
        @Assert(receipt.fairnessBackpressureProofAccepted, true)
        @Assert(receipt.runtimeNativeClaimAllowed, true)
        @Assert(receipt.implementationPacketAllowed, true)
        @Assert(receipt.blockers.size, 0)
        @Assert(receipt.runtimeDesignGate.status, "ready-for-runtime-concurrency-implementation-packet")
        @Assert(receipt.runtimeDesignGate.missingProofs.size, 0)
        @Assert(receipt.nonClaims[2], "NO_PERFORMANCE_CLAIM")
        @Assert(receipt.nonClaims[4], "NO_H2_QUIC_RUNTIME_CLOSURE_CLAIM")
    }
}
