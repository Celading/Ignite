package ignite.tests

import ignite.*

@Test
public class RuntimeExecutorBoundaryTestSuite {
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

    private func schedulerDecisionFor(
        workKind: String
    ): IgniteRuntimeSchedulerShellDecision {
        buildIgniteRuntimeSchedulerShellDecision(
            acceptedFairnessBackpressureReceipt(),
            IgniteRuntimeSchedulerShellWorkItem(
                true,
                workKind,
                true,
                true
            ),
            IgniteRuntimeSchedulerShellLaneState(0, 4, "defer")
        )
    }

    private func acceptedBoundaryRequest(): IgniteRuntimeExecutorBoundaryRequest {
        IgniteRuntimeExecutorBoundaryRequest(
            "executor-boundary-1",
            true,
            true,
            true,
            false,
            false
        )
    }

    @TestCase
    public func testExecutorBoundaryBlocksRejectedSchedulerDecision(): Unit {
        let schedulerDecision = buildIgniteRuntimeSchedulerShellDecision(
            acceptedFairnessBackpressureReceipt(),
            IgniteRuntimeSchedulerShellWorkItem(
                true,
                "long-handler",
                true,
                true
            ),
            IgniteRuntimeSchedulerShellLaneState(4, 4, "reject")
        )
        let plan = buildIgniteRuntimeExecutorBoundaryPlan(
            schedulerDecision,
            acceptedBoundaryRequest()
        )

        @Assert(plan.status, "blocked-runtime-scheduler-shell-decision")
        @Assert(plan.action, "block")
        @Assert(plan.boundaryPlanAccepted, false)
        @Assert(plan.schedulerShellAccepted, false)
        @Assert(plan.runtimeTaskSpawnAllowed, false)
        @Assert(plan.blockers[0], "SCHEDULER_SHELL_DECISION_NOT_ACCEPTED")
    }

    @TestCase
    public func testExecutorBoundaryRefusesLiveRuntimeOverreach(): Unit {
        let plan = buildIgniteRuntimeExecutorBoundaryPlan(
            schedulerDecisionFor("short-handler"),
            IgniteRuntimeExecutorBoundaryRequest(
                "executor-boundary-2",
                true,
                true,
                true,
                true,
                true
            )
        )

        @Assert(plan.status, "blocked-runtime-executor-boundary-input")
        @Assert(plan.action, "block")
        @Assert(plan.boundaryPlanAccepted, false)
        @Assert(plan.blockers[0], "RUNTIME_TASK_SPAWN_REQUESTED")
        @Assert(plan.blockers[1], "LIVE_SERVER_WIRING_REQUESTED")
        @Assert(plan.liveServerWiringAllowed, false)
        @Assert(plan.nonClaims[0], "NO_LIVE_SERVER_WIRING")
    }

    @TestCase
    public func testExecutorBoundaryPlansDistinctLaneModes(): Unit {
        let shortPlan = buildIgniteRuntimeExecutorBoundaryPlan(
            schedulerDecisionFor("short-handler"),
            acceptedBoundaryRequest()
        )
        let longPlan = buildIgniteRuntimeExecutorBoundaryPlan(
            schedulerDecisionFor("long-handler"),
            acceptedBoundaryRequest()
        )
        let blockingPlan = buildIgniteRuntimeExecutorBoundaryPlan(
            schedulerDecisionFor("blocking-external-operation"),
            acceptedBoundaryRequest()
        )

        @Assert(shortPlan.status, "accepted-runtime-executor-boundary-plan")
        @Assert(shortPlan.executionMode, "short-handler-executor-boundary")
        @Assert(longPlan.executionMode, "long-handler-executor-boundary")
        @Assert(blockingPlan.executionMode, "blocking-isolation-executor-boundary")
        @Assert(blockingPlan.boundaryPlanAccepted, true)
        @Assert(blockingPlan.runtimeTaskSpawnAllowed, false)
        @Assert(blockingPlan.action, "record-boundary-plan")
    }
}
