package ignite.tests

import ignite.*

@Test
public class ExecutorAdmissionToEnqueueBridgeTestSuite {
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

    private func admissionDecisionReceiptFor(
        workKind: String
    ): IgniteExecutorEnqueueAdmissionDecisionReceipt {
        buildIgniteExecutorEnqueueAdmissionDecisionReceipt(
            enqueueDryRunReceiptFor(workKind),
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
        )
    }

    private func acceptedBridgeRequest(): IgniteExecutorAdmissionToEnqueueBridgeRequest {
        IgniteExecutorAdmissionToEnqueueBridgeRequest(
            "executor-admission-to-enqueue-bridge-1",
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
            false,
            false
        )
    }

    @TestCase
    public func testBridgeBlocksRejectedAdmissionDecision(): Unit {
        let rejectedAdmissionDecision = buildIgniteExecutorEnqueueAdmissionDecisionReceipt(
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
                false,
                false,
                false,
                false,
                false,
                false
            )
        )
        let receipt = buildIgniteExecutorAdmissionToEnqueueBridgeReceipt(
            rejectedAdmissionDecision,
            acceptedBridgeRequest()
        )

        @Assert(
            receipt.status,
            "blocked-executor-enqueue-admission-decision-receipt"
        )
        @Assert(receipt.action, "block")
        @Assert(receipt.executorAdmissionToEnqueueBridgeAccepted, false)
        @Assert(receipt.executorEnqueueAdmissionDecisionAccepted, false)
        @Assert(
            receipt.blockers[0],
            "EXECUTOR_ENQUEUE_ADMISSION_DECISION_NOT_ACCEPTED"
        )
    }

    @TestCase
    public func testBridgeRefusesQueueWriteAndLiveOverreach(): Unit {
        let receipt = buildIgniteExecutorAdmissionToEnqueueBridgeReceipt(
            admissionDecisionReceiptFor("short-handler"),
            IgniteExecutorAdmissionToEnqueueBridgeRequest(
                "executor-admission-to-enqueue-bridge-2",
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
                true,
                true
            )
        )

        @Assert(
            receipt.status,
            "blocked-executor-admission-to-enqueue-bridge-input"
        )
        @Assert(receipt.action, "block")
        @Assert(receipt.executorAdmissionToEnqueueBridgeAccepted, false)
        @Assert(receipt.blockers[0], "REAL_QUEUE_WRITE_REQUESTED")
        @Assert(receipt.blockers[1], "LIVE_EXECUTOR_ENQUEUE_REQUESTED")
        @Assert(receipt.blockers[2], "RUNTIME_TASK_SPAWN_REQUESTED")
        @Assert(receipt.blockers[3], "HANDLER_INVOCATION_REQUESTED")
        @Assert(receipt.blockers[4], "REQUEST_CONTEXT_MUTATION_REQUESTED")
        @Assert(receipt.blockers[5], "RESPONSE_WRITE_REQUESTED")
        @Assert(receipt.blockers[6], "TRANSPORT_COMMIT_REQUESTED")
        @Assert(receipt.blockers[7], "LIVE_SERVER_WIRING_REQUESTED")
        @Assert(receipt.realQueueWriteAllowed, false)
        @Assert(receipt.nonClaims[0], "NO_REAL_QUEUE_WRITE")
    }

    @TestCase
    public func testBridgeMapsDistinctLaneModes(): Unit {
        let shortReceipt = buildIgniteExecutorAdmissionToEnqueueBridgeReceipt(
            admissionDecisionReceiptFor("short-handler"),
            acceptedBridgeRequest()
        )
        let longReceipt = buildIgniteExecutorAdmissionToEnqueueBridgeReceipt(
            admissionDecisionReceiptFor("long-handler"),
            acceptedBridgeRequest()
        )
        let blockingReceipt = buildIgniteExecutorAdmissionToEnqueueBridgeReceipt(
            admissionDecisionReceiptFor("blocking-external-operation"),
            acceptedBridgeRequest()
        )

        @Assert(
            shortReceipt.status,
            "accepted-executor-admission-to-enqueue-bridge-receipt"
        )
        @Assert(
            shortReceipt.executorAdmissionToEnqueueBridgeMode,
            "short-executor-admission-to-enqueue-bridge"
        )
        @Assert(
            longReceipt.executorAdmissionToEnqueueBridgeMode,
            "long-executor-admission-to-enqueue-bridge"
        )
        @Assert(
            blockingReceipt.executorAdmissionToEnqueueBridgeMode,
            "blocking-isolation-executor-admission-to-enqueue-bridge"
        )
        @Assert(blockingReceipt.executorAdmissionToEnqueueBridgeAccepted, true)
        @Assert(blockingReceipt.realQueueWriteAllowed, false)
        @Assert(
            blockingReceipt.action,
            "record-executor-admission-to-enqueue-bridge-receipt"
        )
    }
}
