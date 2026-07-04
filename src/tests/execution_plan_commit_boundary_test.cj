package ignite.tests

import ignite.*

@Test
public class ExecutionPlanCommitBoundaryTestSuite {
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

    private func acceptedExecutionPlanRequest(): IgniteExecutionPlanCommitBoundaryRequest {
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
    }

    @TestCase
    public func testExecutionPlanBlocksRejectedSimulation(): Unit {
        let rejectedSimulation = buildIgniteRequestExecutionSimulationReceipt(
            handlerDryRunReceiptFor("short-handler"),
            IgniteRequestExecutionSimulationRequest(
                "request-execution-simulation-2",
                true,
                true,
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
        let receipt = buildIgniteExecutionPlanCommitBoundaryReceipt(
            rejectedSimulation,
            acceptedExecutionPlanRequest()
        )

        @Assert(receipt.status, "blocked-request-execution-simulation-receipt")
        @Assert(receipt.action, "block")
        @Assert(receipt.executionPlanCommitAccepted, false)
        @Assert(receipt.requestExecutionSimulationAccepted, false)
        @Assert(receipt.blockers[0], "REQUEST_EXECUTION_SIMULATION_NOT_ACCEPTED")
    }

    @TestCase
    public func testExecutionPlanRefusesLiveCommitOverreach(): Unit {
        let receipt = buildIgniteExecutionPlanCommitBoundaryReceipt(
            simulationReceiptFor("short-handler"),
            IgniteExecutionPlanCommitBoundaryRequest(
                "execution-plan-commit-2",
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

        @Assert(receipt.status, "blocked-execution-plan-commit-boundary-input")
        @Assert(receipt.action, "block")
        @Assert(receipt.executionPlanCommitAccepted, false)
        @Assert(receipt.blockers[0], "HANDLER_INVOCATION_REQUESTED")
        @Assert(receipt.blockers[1], "REQUEST_CONTEXT_MUTATION_REQUESTED")
        @Assert(receipt.blockers[2], "RUNTIME_TASK_SPAWN_REQUESTED")
        @Assert(receipt.blockers[3], "RESPONSE_WRITE_REQUESTED")
        @Assert(receipt.blockers[4], "TRANSPORT_COMMIT_REQUESTED")
        @Assert(receipt.blockers[5], "LIVE_SERVER_WIRING_REQUESTED")
        @Assert(receipt.transportCommitAllowed, false)
        @Assert(receipt.nonClaims[5], "NO_TRANSPORT_COMMIT")
    }

    @TestCase
    public func testExecutionPlanMapsDistinctLaneModes(): Unit {
        let shortReceipt = buildIgniteExecutionPlanCommitBoundaryReceipt(
            simulationReceiptFor("short-handler"),
            acceptedExecutionPlanRequest()
        )
        let longReceipt = buildIgniteExecutionPlanCommitBoundaryReceipt(
            simulationReceiptFor("long-handler"),
            acceptedExecutionPlanRequest()
        )
        let blockingReceipt = buildIgniteExecutionPlanCommitBoundaryReceipt(
            simulationReceiptFor("blocking-external-operation"),
            acceptedExecutionPlanRequest()
        )

        @Assert(shortReceipt.status, "accepted-execution-plan-commit-boundary-receipt")
        @Assert(shortReceipt.executionPlanMode, "short-execution-plan-commit-boundary")
        @Assert(longReceipt.executionPlanMode, "long-execution-plan-commit-boundary")
        @Assert(
            blockingReceipt.executionPlanMode,
            "blocking-isolation-execution-plan-commit-boundary"
        )
        @Assert(blockingReceipt.executionPlanCommitAccepted, true)
        @Assert(blockingReceipt.handlerInvocationAllowed, false)
        @Assert(blockingReceipt.action, "record-execution-plan-commit-boundary-receipt")
    }
}
