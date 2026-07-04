package ignite.tests

import ignite.*

@Test
public class RuntimeQueueIntegrationPlanTestSuite {
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

    private func bridgeReceiptFor(
        workKind: String
    ): IgniteExecutorAdmissionToEnqueueBridgeReceipt {
        buildIgniteExecutorAdmissionToEnqueueBridgeReceipt(
            admissionDecisionReceiptFor(workKind),
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
        )
    }

    private func acceptedQueueWriteRequest(
        depthBefore: Int64,
        capacity: Int64
    ): IgniteControlledExecutorQueueWriteRequest {
        IgniteControlledExecutorQueueWriteRequest(
            "controlled-executor-queue-write-1",
            true,
            true,
            true,
            true,
            true,
            true,
            true,
            true,
            true,
            depthBefore,
            capacity,
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

    private func queueWriteReceiptFor(
        workKind: String
    ): IgniteControlledExecutorQueueWriteReceipt {
        buildIgniteControlledExecutorQueueWriteReceipt(
            bridgeReceiptFor(workKind),
            acceptedQueueWriteRequest(2, 8)
        )
    }

    private func acceptedIntegrationPlanRequest(): IgniteRuntimeQueueIntegrationPlanRequest {
        IgniteRuntimeQueueIntegrationPlanRequest(
            "runtime-queue-integration-plan-1",
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
            false,
            false,
            false
        )
    }

    @TestCase
    public func testRuntimeQueueIntegrationBlocksRejectedQueueWrite(): Unit {
        let rejectedBridge = buildIgniteExecutorAdmissionToEnqueueBridgeReceipt(
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
                false,
                false,
                false,
                false,
                false,
                false,
                false
            )
        )
        let rejectedQueueWrite = buildIgniteControlledExecutorQueueWriteReceipt(
            rejectedBridge,
            acceptedQueueWriteRequest(0, 4)
        )
        let receipt = buildIgniteRuntimeQueueIntegrationPlanReceipt(
            rejectedQueueWrite,
            acceptedIntegrationPlanRequest()
        )

        @Assert(
            receipt.status,
            "blocked-controlled-executor-queue-write-receipt"
        )
        @Assert(receipt.action, "block")
        @Assert(receipt.runtimeQueueIntegrationPlanAccepted, false)
        @Assert(receipt.controlledExecutorQueueWriteAccepted, false)
        @Assert(
            receipt.blockers[0],
            "CONTROLLED_EXECUTOR_QUEUE_WRITE_NOT_ACCEPTED"
        )
    }

    @TestCase
    public func testRuntimeQueueIntegrationRefusesProductionAndLiveOverreach(): Unit {
        let receipt = buildIgniteRuntimeQueueIntegrationPlanReceipt(
            queueWriteReceiptFor("short-handler"),
            IgniteRuntimeQueueIntegrationPlanRequest(
                "runtime-queue-integration-plan-2",
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
                true,
                true
            )
        )

        @Assert(receipt.status, "blocked-runtime-queue-integration-plan-input")
        @Assert(receipt.action, "block")
        @Assert(receipt.runtimeQueueIntegrationPlanAccepted, false)
        @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
        @Assert(receipt.blockers[1], "LIVE_EXECUTOR_ENQUEUE_REQUESTED")
        @Assert(receipt.blockers[2], "RUNTIME_TASK_SPAWN_REQUESTED")
        @Assert(receipt.blockers[3], "HANDLER_INVOCATION_REQUESTED")
        @Assert(receipt.blockers[4], "REQUEST_CONTEXT_MUTATION_REQUESTED")
        @Assert(receipt.blockers[5], "RESPONSE_WRITE_REQUESTED")
        @Assert(receipt.blockers[6], "TRANSPORT_COMMIT_REQUESTED")
        @Assert(receipt.blockers[7], "LIVE_SERVER_WIRING_REQUESTED")
        @Assert(receipt.productionQueueMutationAllowed, false)
        @Assert(receipt.nonClaims[0], "NO_PRODUCTION_QUEUE_MUTATION")
    }

    @TestCase
    public func testRuntimeQueueIntegrationBlocksMissingPlanMarkers(): Unit {
        let receipt = buildIgniteRuntimeQueueIntegrationPlanReceipt(
            queueWriteReceiptFor("long-handler"),
            IgniteRuntimeQueueIntegrationPlanRequest(
                "",
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false
            )
        )

        @Assert(receipt.status, "blocked-runtime-queue-integration-plan-input")
        @Assert(receipt.runtimeQueueIntegrationPlanAccepted, false)
        @Assert(receipt.blockers[0], "INTEGRATION_PLAN_ID_NOT_CARRIED")
        @Assert(receipt.blockers[1], "QUEUE_WRITE_SNAPSHOT_NOT_CARRIED")
        @Assert(receipt.blockers[2], "QUEUE_ENTRY_REFERENCE_NOT_CARRIED")
        @Assert(receipt.blockers[3], "LANE_DISPATCH_PLAN_NOT_CARRIED")
        @Assert(receipt.blockers[4], "EXECUTOR_OWNERSHIP_TOKEN_NOT_CARRIED")
        @Assert(receipt.blockers[5], "DRAIN_LOOP_PLAN_NOT_CARRIED")
        @Assert(receipt.blockers[6], "CANCELLATION_PROPAGATION_NOT_CARRIED")
        @Assert(receipt.blockers[7], "TIMEOUT_BOUNDARY_NOT_CARRIED")
        @Assert(receipt.blockers[8], "COMPLETION_CALLBACK_NOT_CARRIED")
        @Assert(receipt.queueIntegrationPlanned, false)
    }

    @TestCase
    public func testRuntimeQueueIntegrationMapsLaneModes(): Unit {
        let shortReceipt = buildIgniteRuntimeQueueIntegrationPlanReceipt(
            queueWriteReceiptFor("short-handler"),
            acceptedIntegrationPlanRequest()
        )
        let longReceipt = buildIgniteRuntimeQueueIntegrationPlanReceipt(
            queueWriteReceiptFor("long-handler"),
            acceptedIntegrationPlanRequest()
        )
        let blockingReceipt = buildIgniteRuntimeQueueIntegrationPlanReceipt(
            queueWriteReceiptFor("blocking-external-operation"),
            acceptedIntegrationPlanRequest()
        )

        @Assert(
            shortReceipt.status,
            "accepted-runtime-queue-integration-plan-receipt"
        )
        @Assert(
            shortReceipt.runtimeQueueIntegrationPlanMode,
            "short-runtime-queue-integration-plan"
        )
        @Assert(
            longReceipt.runtimeQueueIntegrationPlanMode,
            "long-runtime-queue-integration-plan"
        )
        @Assert(
            blockingReceipt.runtimeQueueIntegrationPlanMode,
            "blocking-isolation-runtime-queue-integration-plan"
        )
        @Assert(blockingReceipt.runtimeQueueIntegrationPlanAccepted, true)
        @Assert(blockingReceipt.runtimeQueueIntegrationPlanAllowed, true)
        @Assert(blockingReceipt.productionQueueMutationAllowed, false)
        @Assert(blockingReceipt.queueDepthBefore, 2)
        @Assert(blockingReceipt.queueDepthAfter, 3)
        @Assert(blockingReceipt.queueIntegrationPlanned, true)
    }
}
