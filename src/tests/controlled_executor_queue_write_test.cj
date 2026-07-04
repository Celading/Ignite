package ignite.tests

import ignite.*

@Test
public class ControlledExecutorQueueWriteTestSuite {
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

    @TestCase
    public func testControlledQueueWriteBlocksRejectedBridge(): Unit {
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
        let receipt = buildIgniteControlledExecutorQueueWriteReceipt(
            rejectedBridge,
            acceptedQueueWriteRequest(0, 4)
        )

        @Assert(
            receipt.status,
            "blocked-executor-admission-to-enqueue-bridge-receipt"
        )
        @Assert(receipt.action, "block")
        @Assert(receipt.controlledExecutorQueueWriteAccepted, false)
        @Assert(receipt.executorAdmissionToEnqueueBridgeAccepted, false)
        @Assert(
            receipt.blockers[0],
            "EXECUTOR_ADMISSION_TO_ENQUEUE_BRIDGE_NOT_ACCEPTED"
        )
    }

    @TestCase
    public func testControlledQueueWriteRefusesProductionAndLiveOverreach(): Unit {
        let receipt = buildIgniteControlledExecutorQueueWriteReceipt(
            bridgeReceiptFor("short-handler"),
            IgniteControlledExecutorQueueWriteRequest(
                "controlled-executor-queue-write-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                0,
                4,
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

        @Assert(receipt.status, "blocked-controlled-executor-queue-write-input")
        @Assert(receipt.action, "block")
        @Assert(receipt.controlledExecutorQueueWriteAccepted, false)
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
    public func testControlledQueueWriteBlocksCapacityExhaustion(): Unit {
        let receipt = buildIgniteControlledExecutorQueueWriteReceipt(
            bridgeReceiptFor("long-handler"),
            acceptedQueueWriteRequest(4, 4)
        )

        @Assert(receipt.status, "blocked-controlled-executor-queue-write-input")
        @Assert(receipt.controlledExecutorQueueWriteAccepted, false)
        @Assert(receipt.blockers[0], "CONTROLLED_QUEUE_CAPACITY_EXHAUSTED")
        @Assert(receipt.queueDepthBefore, 4)
        @Assert(receipt.queueDepthAfter, 4)
        @Assert(receipt.queueEntryRecorded, false)
    }

    @TestCase
    public func testControlledQueueWriteMapsLaneModesAndRecordsDepth(): Unit {
        let shortReceipt = buildIgniteControlledExecutorQueueWriteReceipt(
            bridgeReceiptFor("short-handler"),
            acceptedQueueWriteRequest(2, 8)
        )
        let longReceipt = buildIgniteControlledExecutorQueueWriteReceipt(
            bridgeReceiptFor("long-handler"),
            acceptedQueueWriteRequest(2, 8)
        )
        let blockingReceipt = buildIgniteControlledExecutorQueueWriteReceipt(
            bridgeReceiptFor("blocking-external-operation"),
            acceptedQueueWriteRequest(2, 8)
        )

        @Assert(
            shortReceipt.status,
            "accepted-controlled-executor-queue-write-receipt"
        )
        @Assert(
            shortReceipt.controlledExecutorQueueWriteMode,
            "short-controlled-executor-queue-write"
        )
        @Assert(
            longReceipt.controlledExecutorQueueWriteMode,
            "long-controlled-executor-queue-write"
        )
        @Assert(
            blockingReceipt.controlledExecutorQueueWriteMode,
            "blocking-isolation-controlled-executor-queue-write"
        )
        @Assert(blockingReceipt.controlledExecutorQueueWriteAccepted, true)
        @Assert(blockingReceipt.controlledQueueWriteAllowed, true)
        @Assert(blockingReceipt.productionQueueMutationAllowed, false)
        @Assert(blockingReceipt.queueDepthBefore, 2)
        @Assert(blockingReceipt.queueDepthAfter, 3)
        @Assert(blockingReceipt.queueEntryRecorded, true)
    }
}
