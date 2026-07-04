package ignite.tests

import ignite.*

@Test
public class ExecutorDispatchPlanTestSuite {
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

    private func seamReceiptFor(
        workKind: String
    ): IgniteControlledExecutorSeamReceipt {
        buildIgniteControlledExecutorSeamReceipt(
            boundaryPlanFor(workKind),
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
        )
    }

    private func adapterAttachReceiptFor(
        workKind: String
    ): IgniteControlledExecutorAdapterAttachReceipt {
        buildIgniteControlledExecutorAdapterAttachReceipt(
            seamReceiptFor(workKind),
            IgniteControlledExecutorAdapterAttachRequest(
                "adapter-attach-1",
                true,
                true,
                true,
                true,
                false,
                false,
                false,
                false
            )
        )
    }

    private func handlerDryRunReceiptFor(
        workKind: String
    ): IgniteHandlerAdapterDryRunReceipt {
        buildIgniteHandlerAdapterDryRunReceipt(
            adapterAttachReceiptFor(workKind),
            IgniteHandlerAdapterDryRunRequest(
                "handler-dry-run-1",
                true,
                true,
                true,
                true,
                false,
                false,
                false,
                false
            )
        )
    }

    private func simulationReceiptFor(
        workKind: String
    ): IgniteRequestExecutionSimulationReceipt {
        buildIgniteRequestExecutionSimulationReceipt(
            handlerDryRunReceiptFor(workKind),
            IgniteRequestExecutionSimulationRequest(
                "request-execution-simulation-1",
                true,
                true,
                true,
                true,
                true,
                false,
                false,
                false,
                false,
                false
            )
        )
    }

    private func executionPlanReceiptFor(
        workKind: String
    ): IgniteExecutionPlanCommitBoundaryReceipt {
        buildIgniteExecutionPlanCommitBoundaryReceipt(
            simulationReceiptFor(workKind),
            IgniteExecutionPlanCommitBoundaryRequest(
                "execution-plan-commit-1",
                true,
                true,
                true,
                true,
                true,
                true,
                false,
                false,
                false,
                false,
                false,
                false
            )
        )
    }

    private func acceptedExecutorDispatchPlanRequest(): IgniteExecutorDispatchPlanRequest {
        IgniteExecutorDispatchPlanRequest(
            "executor-dispatch-plan-1",
            true,
            true,
            true,
            true,
            true,
            true,
            false,
            false,
            false,
            false,
            false,
            false
        )
    }

    @TestCase
    public func testExecutorDispatchBlocksRejectedExecutionPlanBoundary(): Unit {
        let rejectedExecutionPlan = buildIgniteExecutionPlanCommitBoundaryReceipt(
            simulationReceiptFor("short-handler"),
            IgniteExecutionPlanCommitBoundaryRequest(
                "execution-plan-commit-2",
                true,
                true,
                true,
                true,
                true,
                true,
                false,
                false,
                false,
                false,
                true,
                false
            )
        )
        let receipt = buildIgniteExecutorDispatchPlanReceipt(
            rejectedExecutionPlan,
            acceptedExecutorDispatchPlanRequest()
        )

        @Assert(receipt.status, "blocked-execution-plan-commit-boundary-receipt")
        @Assert(receipt.action, "block")
        @Assert(receipt.executorDispatchPlanAccepted, false)
        @Assert(receipt.executionPlanCommitAccepted, false)
        @Assert(receipt.blockers[0], "EXECUTION_PLAN_COMMIT_BOUNDARY_NOT_ACCEPTED")
    }

    @TestCase
    public func testExecutorDispatchRefusesLiveDispatchOverreach(): Unit {
        let receipt = buildIgniteExecutorDispatchPlanReceipt(
            executionPlanReceiptFor("short-handler"),
            IgniteExecutorDispatchPlanRequest(
                "executor-dispatch-plan-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true
            )
        )

        @Assert(receipt.status, "blocked-executor-dispatch-plan-input")
        @Assert(receipt.action, "block")
        @Assert(receipt.executorDispatchPlanAccepted, false)
        @Assert(receipt.blockers[0], "HANDLER_INVOCATION_REQUESTED")
        @Assert(receipt.blockers[1], "REQUEST_CONTEXT_MUTATION_REQUESTED")
        @Assert(receipt.blockers[2], "RUNTIME_TASK_SPAWN_REQUESTED")
        @Assert(receipt.blockers[3], "RESPONSE_WRITE_REQUESTED")
        @Assert(receipt.blockers[4], "TRANSPORT_COMMIT_REQUESTED")
        @Assert(receipt.blockers[5], "LIVE_SERVER_WIRING_REQUESTED")
        @Assert(receipt.runtimeTaskSpawnAllowed, false)
        @Assert(receipt.nonClaims[3], "NO_RUNTIME_TASK_SPAWN")
    }

    @TestCase
    public func testExecutorDispatchMapsDistinctLaneModes(): Unit {
        let shortReceipt = buildIgniteExecutorDispatchPlanReceipt(
            executionPlanReceiptFor("short-handler"),
            acceptedExecutorDispatchPlanRequest()
        )
        let longReceipt = buildIgniteExecutorDispatchPlanReceipt(
            executionPlanReceiptFor("long-handler"),
            acceptedExecutorDispatchPlanRequest()
        )
        let blockingReceipt = buildIgniteExecutorDispatchPlanReceipt(
            executionPlanReceiptFor("blocking-external-operation"),
            acceptedExecutorDispatchPlanRequest()
        )

        @Assert(shortReceipt.status, "accepted-executor-dispatch-plan-receipt")
        @Assert(shortReceipt.executorDispatchPlanMode, "short-executor-dispatch-plan")
        @Assert(longReceipt.executorDispatchPlanMode, "long-executor-dispatch-plan")
        @Assert(
            blockingReceipt.executorDispatchPlanMode,
            "blocking-isolation-executor-dispatch-plan"
        )
        @Assert(blockingReceipt.executorDispatchPlanAccepted, true)
        @Assert(blockingReceipt.handlerInvocationAllowed, false)
        @Assert(blockingReceipt.action, "record-executor-dispatch-plan-receipt")
    }
}
