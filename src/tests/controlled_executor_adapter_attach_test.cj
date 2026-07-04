package ignite.tests

import ignite.*

@Test
public class ControlledExecutorAdapterAttachTestSuite {
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

    private func acceptedAdapterRequest(): IgniteControlledExecutorAdapterAttachRequest {
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
    }

    @TestCase
    public func testAdapterAttachBlocksRejectedControlledSeam(): Unit {
        let rejectedSeam = buildIgniteControlledExecutorSeamReceipt(
            boundaryPlanFor("short-handler"),
            IgniteControlledExecutorSeamRequest(
                "controlled-seam-2",
                true,
                true,
                true,
                true,
                true,
                false,
                false
            )
        )
        let receipt = buildIgniteControlledExecutorAdapterAttachReceipt(
            rejectedSeam,
            acceptedAdapterRequest()
        )

        @Assert(receipt.status, "blocked-controlled-executor-seam-receipt")
        @Assert(receipt.action, "block")
        @Assert(receipt.adapterAttachAccepted, false)
        @Assert(receipt.controlledSeamAccepted, false)
        @Assert(receipt.blockers[0], "CONTROLLED_EXECUTOR_SEAM_NOT_ACCEPTED")
    }

    @TestCase
    public func testAdapterAttachRefusesLiveAdapterOverreach(): Unit {
        let receipt = buildIgniteControlledExecutorAdapterAttachReceipt(
            seamReceiptFor("short-handler"),
            IgniteControlledExecutorAdapterAttachRequest(
                "adapter-attach-2",
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

        @Assert(receipt.status, "blocked-controlled-executor-adapter-attach-input")
        @Assert(receipt.action, "block")
        @Assert(receipt.adapterAttachAccepted, false)
        @Assert(receipt.blockers[0], "HANDLER_INVOCATION_REQUESTED")
        @Assert(receipt.blockers[1], "REQUEST_CONTEXT_MUTATION_REQUESTED")
        @Assert(receipt.blockers[2], "RUNTIME_TASK_SPAWN_REQUESTED")
        @Assert(receipt.blockers[3], "LIVE_SERVER_WIRING_REQUESTED")
        @Assert(receipt.requestContextMutationAllowed, false)
        @Assert(receipt.nonClaims[2], "NO_REQUEST_CONTEXT_MUTATION")
    }

    @TestCase
    public func testAdapterAttachPlansDistinctLaneModes(): Unit {
        let shortReceipt = buildIgniteControlledExecutorAdapterAttachReceipt(
            seamReceiptFor("short-handler"),
            acceptedAdapterRequest()
        )
        let longReceipt = buildIgniteControlledExecutorAdapterAttachReceipt(
            seamReceiptFor("long-handler"),
            acceptedAdapterRequest()
        )
        let blockingReceipt = buildIgniteControlledExecutorAdapterAttachReceipt(
            seamReceiptFor("blocking-external-operation"),
            acceptedAdapterRequest()
        )

        @Assert(shortReceipt.status, "accepted-controlled-executor-adapter-attach-receipt")
        @Assert(shortReceipt.adapterMode, "short-handler-adapter-attach")
        @Assert(longReceipt.adapterMode, "long-handler-adapter-attach")
        @Assert(blockingReceipt.adapterMode, "blocking-isolation-adapter-attach")
        @Assert(blockingReceipt.adapterAttachAccepted, true)
        @Assert(blockingReceipt.handlerInvocationAllowed, false)
        @Assert(blockingReceipt.action, "record-adapter-attach-receipt")
    }
}
