package ignite.tests

import ignite.*

@Test
public class RuntimeSchedulerShellTestSuite {
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

    private func acceptedFairnessBackpressureReceipt(): IgniteFairnessBackpressureProofReceipt {
        let requestSchedulerReceipt = acceptedRequestSchedulerReceipt()
        let blockingIsolationReceipt =
            acceptedBlockingIsolationReceipt(requestSchedulerReceipt)
        let longShortTaskLaneReceipt = acceptedLongShortTaskLaneReceipt(
            requestSchedulerReceipt,
            blockingIsolationReceipt
        )
        buildIgniteFairnessBackpressureProofReceipt(
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
    }

    private func blockedFairnessBackpressureReceipt(): IgniteFairnessBackpressureProofReceipt {
        let requestSchedulerReceipt = acceptedRequestSchedulerReceipt()
        let blockingIsolationReceipt =
            acceptedBlockingIsolationReceipt(requestSchedulerReceipt)
        let longShortTaskLaneReceipt = acceptedLongShortTaskLaneReceipt(
            requestSchedulerReceipt,
            blockingIsolationReceipt
        )
        buildIgniteFairnessBackpressureProofReceipt(
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
    }

    @TestCase
    public func testSchedulerShellBlocksWhenProofGateIsNotAccepted(): Unit {
        let decision = buildIgniteRuntimeSchedulerShellDecision(
            blockedFairnessBackpressureReceipt(),
            IgniteRuntimeSchedulerShellWorkItem(
                true,
                "short-handler",
                true,
                true
            ),
            IgniteRuntimeSchedulerShellLaneState(0, 4, "defer")
        )

        @Assert(decision.status, "blocked-runtime-concurrency-proof-gate")
        @Assert(decision.action, "block")
        @Assert(decision.schedulerShellAccepted, false)
        @Assert(decision.implementationPacketAllowed, false)
        @Assert(decision.blockers[0], "FAIRNESS_BACKPRESSURE_PROOF_NOT_ACCEPTED")
        @Assert(decision.nonClaims[0], "NO_LIVE_SERVER_WIRING")
    }

    @TestCase
    public func testSchedulerShellRoutesShortLongAndBlockingWorkKinds(): Unit {
        let proof = acceptedFairnessBackpressureReceipt()
        let shortDecision = buildIgniteRuntimeSchedulerShellDecision(
            proof,
            IgniteRuntimeSchedulerShellWorkItem(
                true,
                "short-handler",
                true,
                true
            ),
            IgniteRuntimeSchedulerShellLaneState(0, 4, "defer")
        )
        let longDecision = buildIgniteRuntimeSchedulerShellDecision(
            proof,
            IgniteRuntimeSchedulerShellWorkItem(
                true,
                "long-handler",
                true,
                true
            ),
            IgniteRuntimeSchedulerShellLaneState(1, 4, "defer")
        )
        let blockingDecision = buildIgniteRuntimeSchedulerShellDecision(
            proof,
            IgniteRuntimeSchedulerShellWorkItem(
                true,
                "blocking-external-operation",
                true,
                true
            ),
            IgniteRuntimeSchedulerShellLaneState(2, 4, "defer")
        )

        @Assert(shortDecision.selectedLane, "short-task-lane")
        @Assert(longDecision.selectedLane, "long-task-lane")
        @Assert(blockingDecision.selectedLane, "blocking-isolation-lane")
        @Assert(shortDecision.action, "enqueue")
        @Assert(longDecision.queueAfter, 2)
        @Assert(blockingDecision.schedulerShellAccepted, true)
    }

    @TestCase
    public func testSchedulerShellAppliesCapacityPressurePolicy(): Unit {
        let decision = buildIgniteRuntimeSchedulerShellDecision(
            acceptedFairnessBackpressureReceipt(),
            IgniteRuntimeSchedulerShellWorkItem(
                true,
                "long-handler",
                true,
                true
            ),
            IgniteRuntimeSchedulerShellLaneState(4, 4, "reject")
        )

        @Assert(decision.status, "pressured-runtime-scheduler-shell-lane")
        @Assert(decision.selectedLane, "long-task-lane")
        @Assert(decision.action, "reject")
        @Assert(decision.schedulerShellAccepted, false)
        @Assert(decision.implementationPacketAllowed, true)
        @Assert(decision.queueAfter, 4)
        @Assert(decision.pressureSignal, "lane-full")
    }
}
