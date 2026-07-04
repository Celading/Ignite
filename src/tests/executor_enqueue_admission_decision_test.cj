package ignite.tests

import ignite.*

@Test
public class ExecutorEnqueueAdmissionDecisionTestSuite {
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

    private func dispatchPlanReceiptFor(
        workKind: String
    ): IgniteExecutorDispatchPlanReceipt {
        buildIgniteExecutorDispatchPlanReceipt(
            executionPlanReceiptFor(workKind),
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
        )
    }

    private func enqueueDryRunReceiptFor(
        workKind: String
    ): IgniteExecutorEnqueueDryRunReceipt {
        buildIgniteExecutorEnqueueDryRunReceipt(
            dispatchPlanReceiptFor(workKind),
            IgniteExecutorEnqueueDryRunRequest(
                "executor-enqueue-dry-run-1",
                true,
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
                false,
                false
            )
        )
    }

    private func acceptedAdmissionDecisionRequest(): IgniteExecutorEnqueueAdmissionDecisionRequest {
        IgniteExecutorEnqueueAdmissionDecisionRequest(
            "executor-enqueue-admission-decision-1",
            true,
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
            false,
            false
        )
    }

    @TestCase
    public func testAdmissionDecisionBlocksRejectedEnqueueDryRun(): Unit {
        let rejectedDryRun = buildIgniteExecutorEnqueueDryRunReceipt(
            dispatchPlanReceiptFor("short-handler"),
            IgniteExecutorEnqueueDryRunRequest(
                "executor-enqueue-dry-run-2",
                true,
                true,
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
        let receipt = buildIgniteExecutorEnqueueAdmissionDecisionReceipt(
            rejectedDryRun,
            acceptedAdmissionDecisionRequest()
        )

        @Assert(receipt.status, "blocked-executor-enqueue-dry-run-receipt")
        @Assert(receipt.action, "block")
        @Assert(receipt.executorEnqueueAdmissionDecisionAccepted, false)
        @Assert(receipt.executorEnqueueDryRunAccepted, false)
        @Assert(receipt.blockers[0], "EXECUTOR_ENQUEUE_DRY_RUN_NOT_ACCEPTED")
    }

    @TestCase
    public func testAdmissionDecisionRefusesLiveAdmissionOverreach(): Unit {
        let receipt = buildIgniteExecutorEnqueueAdmissionDecisionReceipt(
            enqueueDryRunReceiptFor("short-handler"),
            IgniteExecutorEnqueueAdmissionDecisionRequest(
                "executor-enqueue-admission-decision-2",
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
                true,
                true,
                true
            )
        )

        @Assert(receipt.status, "blocked-executor-enqueue-admission-decision-input")
        @Assert(receipt.action, "block")
        @Assert(receipt.executorEnqueueAdmissionDecisionAccepted, false)
        @Assert(receipt.blockers[0], "LIVE_EXECUTOR_ENQUEUE_REQUESTED")
        @Assert(receipt.blockers[1], "RUNTIME_TASK_SPAWN_REQUESTED")
        @Assert(receipt.blockers[2], "HANDLER_INVOCATION_REQUESTED")
        @Assert(receipt.blockers[3], "REQUEST_CONTEXT_MUTATION_REQUESTED")
        @Assert(receipt.blockers[4], "RESPONSE_WRITE_REQUESTED")
        @Assert(receipt.blockers[5], "TRANSPORT_COMMIT_REQUESTED")
        @Assert(receipt.blockers[6], "LIVE_SERVER_WIRING_REQUESTED")
        @Assert(receipt.liveExecutorEnqueueAllowed, false)
        @Assert(receipt.nonClaims[1], "NO_LIVE_EXECUTOR_ENQUEUE")
    }

    @TestCase
    public func testAdmissionDecisionMapsDistinctLaneModes(): Unit {
        let shortReceipt = buildIgniteExecutorEnqueueAdmissionDecisionReceipt(
            enqueueDryRunReceiptFor("short-handler"),
            acceptedAdmissionDecisionRequest()
        )
        let longReceipt = buildIgniteExecutorEnqueueAdmissionDecisionReceipt(
            enqueueDryRunReceiptFor("long-handler"),
            acceptedAdmissionDecisionRequest()
        )
        let blockingReceipt = buildIgniteExecutorEnqueueAdmissionDecisionReceipt(
            enqueueDryRunReceiptFor("blocking-external-operation"),
            acceptedAdmissionDecisionRequest()
        )

        @Assert(
            shortReceipt.status,
            "accepted-executor-enqueue-admission-decision-receipt"
        )
        @Assert(
            shortReceipt.executorEnqueueAdmissionDecisionMode,
            "short-executor-enqueue-admission-decision"
        )
        @Assert(
            longReceipt.executorEnqueueAdmissionDecisionMode,
            "long-executor-enqueue-admission-decision"
        )
        @Assert(
            blockingReceipt.executorEnqueueAdmissionDecisionMode,
            "blocking-isolation-executor-enqueue-admission-decision"
        )
        @Assert(blockingReceipt.executorEnqueueAdmissionDecisionAccepted, true)
        @Assert(blockingReceipt.runtimeTaskSpawnAllowed, false)
        @Assert(
            blockingReceipt.action,
            "record-executor-enqueue-admission-decision-receipt"
        )
    }
}
