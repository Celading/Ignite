package ignite.tests

import ignite.*

@Test
public class ExecutorEnqueueDryRunTestSuite {
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

    private func acceptedExecutorEnqueueDryRunRequest(): IgniteExecutorEnqueueDryRunRequest {
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
    }

    @TestCase
    public func testExecutorEnqueueBlocksRejectedDispatchPlan(): Unit {
        let rejectedDispatchPlan = buildIgniteExecutorDispatchPlanReceipt(
            executionPlanReceiptFor("short-handler"),
            IgniteExecutorDispatchPlanRequest(
                "executor-dispatch-plan-2",
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
        let receipt = buildIgniteExecutorEnqueueDryRunReceipt(
            rejectedDispatchPlan,
            acceptedExecutorEnqueueDryRunRequest()
        )

        @Assert(receipt.status, "blocked-executor-dispatch-plan-receipt")
        @Assert(receipt.action, "block")
        @Assert(receipt.executorEnqueueDryRunAccepted, false)
        @Assert(receipt.executorDispatchPlanAccepted, false)
        @Assert(receipt.blockers[0], "EXECUTOR_DISPATCH_PLAN_NOT_ACCEPTED")
    }

    @TestCase
    public func testExecutorEnqueueRefusesLiveEnqueueOverreach(): Unit {
        let receipt = buildIgniteExecutorEnqueueDryRunReceipt(
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
                true,
                true,
                true,
                true,
                true,
                true
            )
        )

        @Assert(receipt.status, "blocked-executor-enqueue-dry-run-input")
        @Assert(receipt.action, "block")
        @Assert(receipt.executorEnqueueDryRunAccepted, false)
        @Assert(receipt.blockers[0], "LIVE_EXECUTOR_ENQUEUE_REQUESTED")
        @Assert(receipt.blockers[1], "HANDLER_INVOCATION_REQUESTED")
        @Assert(receipt.blockers[2], "REQUEST_CONTEXT_MUTATION_REQUESTED")
        @Assert(receipt.blockers[3], "RUNTIME_TASK_SPAWN_REQUESTED")
        @Assert(receipt.blockers[4], "RESPONSE_WRITE_REQUESTED")
        @Assert(receipt.blockers[5], "TRANSPORT_COMMIT_REQUESTED")
        @Assert(receipt.blockers[6], "LIVE_SERVER_WIRING_REQUESTED")
        @Assert(receipt.liveExecutorEnqueueAllowed, false)
        @Assert(receipt.nonClaims[1], "NO_LIVE_EXECUTOR_ENQUEUE")
    }

    @TestCase
    public func testExecutorEnqueueMapsDistinctLaneModes(): Unit {
        let shortReceipt = buildIgniteExecutorEnqueueDryRunReceipt(
            dispatchPlanReceiptFor("short-handler"),
            acceptedExecutorEnqueueDryRunRequest()
        )
        let longReceipt = buildIgniteExecutorEnqueueDryRunReceipt(
            dispatchPlanReceiptFor("long-handler"),
            acceptedExecutorEnqueueDryRunRequest()
        )
        let blockingReceipt = buildIgniteExecutorEnqueueDryRunReceipt(
            dispatchPlanReceiptFor("blocking-external-operation"),
            acceptedExecutorEnqueueDryRunRequest()
        )

        @Assert(shortReceipt.status, "accepted-executor-enqueue-dry-run-receipt")
        @Assert(shortReceipt.executorEnqueueDryRunMode, "short-executor-enqueue-dry-run")
        @Assert(longReceipt.executorEnqueueDryRunMode, "long-executor-enqueue-dry-run")
        @Assert(
            blockingReceipt.executorEnqueueDryRunMode,
            "blocking-isolation-executor-enqueue-dry-run"
        )
        @Assert(blockingReceipt.executorEnqueueDryRunAccepted, true)
        @Assert(blockingReceipt.runtimeTaskSpawnAllowed, false)
        @Assert(blockingReceipt.action, "record-executor-enqueue-dry-run-receipt")
    }
}
