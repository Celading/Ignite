package ignite.tests

import ignite.*

@Test
public class RequestExecutionSimulationTestSuite {
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

    private func acceptedSimulationRequest(): IgniteRequestExecutionSimulationRequest {
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
    }

    @TestCase
    public func testSimulationBlocksRejectedHandlerDryRun(): Unit {
        let rejectedDryRun = buildIgniteHandlerAdapterDryRunReceipt(
            adapterAttachReceiptFor("short-handler"),
            IgniteHandlerAdapterDryRunRequest(
                "handler-dry-run-2",
                true,
                true,
                true,
                true,
                true,
                false,
                false,
                false
            )
        )
        let receipt = buildIgniteRequestExecutionSimulationReceipt(
            rejectedDryRun,
            acceptedSimulationRequest()
        )

        @Assert(receipt.status, "blocked-handler-adapter-dry-run-receipt")
        @Assert(receipt.action, "block")
        @Assert(receipt.requestExecutionSimulationAccepted, false)
        @Assert(receipt.handlerDryRunAccepted, false)
        @Assert(receipt.blockers[0], "HANDLER_ADAPTER_DRY_RUN_NOT_ACCEPTED")
    }

    @TestCase
    public func testSimulationRefusesLiveExecutionOverreach(): Unit {
        let receipt = buildIgniteRequestExecutionSimulationReceipt(
            handlerDryRunReceiptFor("short-handler"),
            IgniteRequestExecutionSimulationRequest(
                "request-execution-simulation-2",
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

        @Assert(receipt.status, "blocked-request-execution-simulation-input")
        @Assert(receipt.action, "block")
        @Assert(receipt.requestExecutionSimulationAccepted, false)
        @Assert(receipt.blockers[0], "HANDLER_INVOCATION_REQUESTED")
        @Assert(receipt.blockers[1], "REQUEST_CONTEXT_MUTATION_REQUESTED")
        @Assert(receipt.blockers[2], "RUNTIME_TASK_SPAWN_REQUESTED")
        @Assert(receipt.blockers[3], "RESPONSE_WRITE_REQUESTED")
        @Assert(receipt.blockers[4], "LIVE_SERVER_WIRING_REQUESTED")
        @Assert(receipt.responseWriteAllowed, false)
        @Assert(receipt.nonClaims[4], "NO_RESPONSE_WRITE")
    }

    @TestCase
    public func testSimulationPlansDistinctLaneModes(): Unit {
        let shortReceipt = buildIgniteRequestExecutionSimulationReceipt(
            handlerDryRunReceiptFor("short-handler"),
            acceptedSimulationRequest()
        )
        let longReceipt = buildIgniteRequestExecutionSimulationReceipt(
            handlerDryRunReceiptFor("long-handler"),
            acceptedSimulationRequest()
        )
        let blockingReceipt = buildIgniteRequestExecutionSimulationReceipt(
            handlerDryRunReceiptFor("blocking-external-operation"),
            acceptedSimulationRequest()
        )

        @Assert(shortReceipt.status, "accepted-request-execution-simulation-receipt")
        @Assert(shortReceipt.simulationMode, "short-request-execution-simulation")
        @Assert(longReceipt.simulationMode, "long-request-execution-simulation")
        @Assert(
            blockingReceipt.simulationMode,
            "blocking-isolation-request-execution-simulation"
        )
        @Assert(blockingReceipt.requestExecutionSimulationAccepted, true)
        @Assert(blockingReceipt.handlerInvocationAllowed, false)
        @Assert(blockingReceipt.action, "record-request-execution-simulation-receipt")
    }
}
