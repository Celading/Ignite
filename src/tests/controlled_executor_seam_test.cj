package ignite.tests

import ignite.*

@Test
public class ControlledExecutorSeamTestSuite {
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
        workKind: String,
        queued: Int64,
        capacity: Int64
    ): IgniteRuntimeSchedulerShellDecision {
        buildIgniteRuntimeSchedulerShellDecision(
            acceptedFairnessBackpressureReceipt(),
            IgniteRuntimeSchedulerShellWorkItem(
                true,
                workKind,
                true,
                true
            ),
            IgniteRuntimeSchedulerShellLaneState(queued, capacity, "defer")
        )
    }

    private func boundaryPlanFor(
        workKind: String
    ): IgniteRuntimeExecutorBoundaryPlan {
        buildIgniteRuntimeExecutorBoundaryPlan(
            schedulerDecisionFor(workKind, 0, 4),
            IgniteRuntimeExecutorBoundaryRequest(
                "executor-boundary-1",
                true,
                true,
                true,
                false,
                false
            )
        )
    }

    private func acceptedSeamRequest(): IgniteControlledExecutorSeamRequest {
        IgniteControlledExecutorSeamRequest(
            "controlled-seam-1",
            true,
            true,
            true,
            true,
            false,
            false,
            false
        )
    }

    @TestCase
    public func testControlledSeamBlocksRejectedBoundaryPlan(): Unit {
        let boundaryPlan = buildIgniteRuntimeExecutorBoundaryPlan(
            schedulerDecisionFor("long-handler", 4, 4),
            IgniteRuntimeExecutorBoundaryRequest(
                "executor-boundary-2",
                true,
                true,
                true,
                false,
                false
            )
        )
        let receipt = buildIgniteControlledExecutorSeamReceipt(
            boundaryPlan,
            acceptedSeamRequest()
        )

        @Assert(receipt.status, "blocked-runtime-executor-boundary-plan")
        @Assert(receipt.action, "block")
        @Assert(receipt.controlledSeamAccepted, false)
        @Assert(receipt.boundaryPlanAccepted, false)
        @Assert(receipt.blockers[0], "EXECUTOR_BOUNDARY_PLAN_NOT_ACCEPTED")
    }

    @TestCase
    public func testControlledSeamRefusesLiveExecutionOverreach(): Unit {
        let receipt = buildIgniteControlledExecutorSeamReceipt(
            boundaryPlanFor("short-handler"),
            IgniteControlledExecutorSeamRequest(
                "controlled-seam-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true
            )
        )

        @Assert(receipt.status, "blocked-controlled-executor-seam-input")
        @Assert(receipt.action, "block")
        @Assert(receipt.controlledSeamAccepted, false)
        @Assert(receipt.blockers[0], "HANDLER_INVOCATION_REQUESTED")
        @Assert(receipt.blockers[1], "RUNTIME_TASK_SPAWN_REQUESTED")
        @Assert(receipt.blockers[2], "LIVE_SERVER_WIRING_REQUESTED")
        @Assert(receipt.handlerInvocationAllowed, false)
        @Assert(receipt.nonClaims[1], "NO_HANDLER_INVOCATION")
    }

    @TestCase
    public func testControlledSeamPlansDistinctLaneModes(): Unit {
        let shortReceipt = buildIgniteControlledExecutorSeamReceipt(
            boundaryPlanFor("short-handler"),
            acceptedSeamRequest()
        )
        let longReceipt = buildIgniteControlledExecutorSeamReceipt(
            boundaryPlanFor("long-handler"),
            acceptedSeamRequest()
        )
        let blockingReceipt = buildIgniteControlledExecutorSeamReceipt(
            boundaryPlanFor("blocking-external-operation"),
            acceptedSeamRequest()
        )

        @Assert(shortReceipt.status, "accepted-controlled-executor-seam-receipt")
        @Assert(shortReceipt.seamMode, "short-handler-controlled-executor-seam")
        @Assert(longReceipt.seamMode, "long-handler-controlled-executor-seam")
        @Assert(blockingReceipt.seamMode, "blocking-isolation-controlled-executor-seam")
        @Assert(blockingReceipt.controlledSeamAccepted, true)
        @Assert(blockingReceipt.handlerInvocationAllowed, false)
        @Assert(blockingReceipt.action, "record-controlled-seam-receipt")
    }
}
