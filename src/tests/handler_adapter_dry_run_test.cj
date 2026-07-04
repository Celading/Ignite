package ignite.tests

import ignite.*

@Test
public class HandlerAdapterDryRunTestSuite {
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

    private func acceptedDryRunRequest(): IgniteHandlerAdapterDryRunRequest {
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
    }

    @TestCase
    public func testDryRunBlocksRejectedAdapterAttach(): Unit {
        let rejectedAdapterAttach = buildIgniteControlledExecutorAdapterAttachReceipt(
            seamReceiptFor("short-handler"),
            IgniteControlledExecutorAdapterAttachRequest(
                "adapter-attach-2",
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
        let receipt = buildIgniteHandlerAdapterDryRunReceipt(
            rejectedAdapterAttach,
            acceptedDryRunRequest()
        )

        @Assert(receipt.status, "blocked-controlled-executor-adapter-attach-receipt")
        @Assert(receipt.action, "block")
        @Assert(receipt.handlerDryRunAccepted, false)
        @Assert(receipt.adapterAttachAccepted, false)
        @Assert(receipt.blockers[0], "CONTROLLED_EXECUTOR_ADAPTER_ATTACH_NOT_ACCEPTED")
    }

    @TestCase
    public func testDryRunRefusesLiveHandlerOverreach(): Unit {
        let receipt = buildIgniteHandlerAdapterDryRunReceipt(
            adapterAttachReceiptFor("short-handler"),
            IgniteHandlerAdapterDryRunRequest(
                "handler-dry-run-2",
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

        @Assert(receipt.status, "blocked-handler-adapter-dry-run-input")
        @Assert(receipt.action, "block")
        @Assert(receipt.handlerDryRunAccepted, false)
        @Assert(receipt.blockers[0], "HANDLER_INVOCATION_REQUESTED")
        @Assert(receipt.blockers[1], "REQUEST_CONTEXT_MUTATION_REQUESTED")
        @Assert(receipt.blockers[2], "RUNTIME_TASK_SPAWN_REQUESTED")
        @Assert(receipt.blockers[3], "LIVE_SERVER_WIRING_REQUESTED")
        @Assert(receipt.requestContextMutationAllowed, false)
        @Assert(receipt.nonClaims[1], "NO_HANDLER_INVOCATION")
    }

    @TestCase
    public func testDryRunPlansDistinctLaneModes(): Unit {
        let shortReceipt = buildIgniteHandlerAdapterDryRunReceipt(
            adapterAttachReceiptFor("short-handler"),
            acceptedDryRunRequest()
        )
        let longReceipt = buildIgniteHandlerAdapterDryRunReceipt(
            adapterAttachReceiptFor("long-handler"),
            acceptedDryRunRequest()
        )
        let blockingReceipt = buildIgniteHandlerAdapterDryRunReceipt(
            adapterAttachReceiptFor("blocking-external-operation"),
            acceptedDryRunRequest()
        )

        @Assert(shortReceipt.status, "accepted-handler-adapter-dry-run-receipt")
        @Assert(shortReceipt.dryRunMode, "short-handler-adapter-dry-run")
        @Assert(longReceipt.dryRunMode, "long-handler-adapter-dry-run")
        @Assert(blockingReceipt.dryRunMode, "blocking-isolation-handler-dry-run")
        @Assert(blockingReceipt.handlerDryRunAccepted, true)
        @Assert(blockingReceipt.handlerInvocationAllowed, false)
        @Assert(blockingReceipt.action, "record-handler-adapter-dry-run-receipt")
    }
}
