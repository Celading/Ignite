package ignite.tests

import std.unittest.*
import std.unittest.testmacro.*
import ignite.*

func runTestProductionQueueMutationGateBlocksRejectedCommitBoundary(): Unit {
    let rejectedIntegrationPlan = buildIgniteRuntimeQueueIntegrationPlanReceipt(
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
            false,
            false,
            false,
            false,
            false,
            false,
            false
        )
    )
    let rejectedCommitBoundary = buildIgniteRuntimeQueueCommitBoundaryReceipt(
        rejectedIntegrationPlan,
        acceptedCommitBoundaryRequest()
    )
    let receipt = buildIgniteProductionQueueMutationGateReceipt(
        rejectedCommitBoundary,
        acceptedMutationGateRequest()
    )

    @Assert(receipt.status, "blocked-runtime-queue-commit-boundary-receipt")
    @Assert(receipt.action, "block")
    @Assert(receipt.productionQueueMutationGateAccepted, false)
    @Assert(receipt.runtimeQueueCommitBoundaryAccepted, false)
    @Assert(receipt.blockers[0], "RUNTIME_QUEUE_COMMIT_BOUNDARY_NOT_ACCEPTED")
}
func runTestProductionQueueMutationGateRefusesActualMutationAndLiveOverreach(): Unit {
    let receipt = buildIgniteProductionQueueMutationGateReceipt(
        commitBoundaryReceiptFor("short-handler"),
        IgniteProductionQueueMutationGateRequest(
            "production-queue-mutation-gate-2",
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

    @Assert(receipt.status, "blocked-production-queue-mutation-gate-input")
    @Assert(receipt.action, "block")
    @Assert(receipt.productionQueueMutationGateAccepted, false)
    @Assert(receipt.blockers[0], "ACTUAL_PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "LIVE_EXECUTOR_ENQUEUE_REQUESTED")
    @Assert(receipt.blockers[2], "RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[3], "HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[4], "REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[5], "RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[6], "TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[7], "LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.actualProductionQueueMutationAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_PRODUCTION_QUEUE_MUTATION")
}

func runTestProductionQueueMutationGateBlocksMissingMarkers(): Unit {
    let receipt = buildIgniteProductionQueueMutationGateReceipt(
        commitBoundaryReceiptFor("long-handler"),
        IgniteProductionQueueMutationGateRequest(
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

    @Assert(receipt.status, "blocked-production-queue-mutation-gate-input")
    @Assert(receipt.productionQueueMutationGateAccepted, false)
    @Assert(receipt.blockers[0], "MUTATION_GATE_ID_NOT_CARRIED")
    @Assert(receipt.blockers[1], "COMMIT_BOUNDARY_SNAPSHOT_NOT_CARRIED")
    @Assert(receipt.blockers[2], "QUEUE_MUTATION_INTENT_NOT_CARRIED")
    @Assert(receipt.blockers[3], "QUEUE_STORAGE_TARGET_NOT_CARRIED")
    @Assert(receipt.blockers[4], "LANE_OWNERSHIP_NOT_CARRIED")
    @Assert(receipt.blockers[5], "EXECUTOR_OWNERSHIP_NOT_CARRIED")
    @Assert(receipt.blockers[6], "MUTATION_ROLLBACK_NOT_CARRIED")
    @Assert(receipt.blockers[7], "BACKPRESSURE_FENCE_NOT_CARRIED")
    @Assert(receipt.blockers[8], "COMPLETION_FENCE_NOT_CARRIED")
    @Assert(receipt.mutationGateRecorded, false)
}

func runTestProductionQueueMutationGateMapsLaneModes(): Unit {
    let shortReceipt = buildIgniteProductionQueueMutationGateReceipt(
        commitBoundaryReceiptFor("short-handler"),
        acceptedMutationGateRequest()
    )
    let longReceipt = buildIgniteProductionQueueMutationGateReceipt(
        commitBoundaryReceiptFor("long-handler"),
        acceptedMutationGateRequest()
    )
    let blockingReceipt = buildIgniteProductionQueueMutationGateReceipt(
        commitBoundaryReceiptFor("blocking-external-operation"),
        acceptedMutationGateRequest()
    )

    @Assert(
        shortReceipt.status,
        "accepted-production-queue-mutation-gate-receipt"
    )
    @Assert(
        shortReceipt.productionQueueMutationGateMode,
        "short-production-queue-mutation-gate"
    )
    @Assert(
        longReceipt.productionQueueMutationGateMode,
        "long-production-queue-mutation-gate"
    )
    @Assert(
        blockingReceipt.productionQueueMutationGateMode,
        "blocking-isolation-production-queue-mutation-gate"
    )
    @Assert(blockingReceipt.productionQueueMutationGateAccepted, true)
    @Assert(blockingReceipt.productionQueueMutationGateAllowed, true)
    @Assert(blockingReceipt.actualProductionQueueMutationAllowed, false)
    @Assert(blockingReceipt.queueDepthBefore, 2)
    @Assert(blockingReceipt.queueDepthAfter, 3)
    @Assert(blockingReceipt.mutationGateRecorded, true)
}

func runTestProductionQueueMutationDryRunBlocksRejectedMutationGate(): Unit {
    let rejectedGate = buildIgniteProductionQueueMutationGateReceipt(
        commitBoundaryReceiptFor("short-handler"),
        IgniteProductionQueueMutationGateRequest(
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
    let receipt = buildIgniteProductionQueueMutationDryRunReceipt(
        rejectedGate,
        acceptedMutationDryRunRequest()
    )

    @Assert(receipt.status, "blocked-production-queue-mutation-gate-receipt")
    @Assert(receipt.action, "block")
    @Assert(receipt.productionQueueMutationDryRunAccepted, false)
    @Assert(receipt.productionQueueMutationGateAccepted, false)
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_GATE_NOT_ACCEPTED")
}

func runTestProductionQueueMutationDryRunRefusesActualMutationAndLiveOverreach(): Unit {
    let gateReceipt = buildIgniteProductionQueueMutationGateReceipt(
        commitBoundaryReceiptFor("short-handler"),
        acceptedMutationGateRequest()
    )
    let receipt = buildIgniteProductionQueueMutationDryRunReceipt(
        gateReceipt,
        IgniteProductionQueueMutationDryRunRequest(
            "production-queue-mutation-dry-run-2",
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
            true,
            true
        )
    )

    @Assert(receipt.status, "blocked-production-queue-mutation-dry-run-input")
    @Assert(receipt.action, "block")
    @Assert(receipt.productionQueueMutationDryRunAccepted, false)
    @Assert(receipt.blockers[0], "ACTUAL_PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "LIVE_EXECUTOR_ENQUEUE_REQUESTED")
    @Assert(receipt.blockers[2], "RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[3], "HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[4], "REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[5], "RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[6], "TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[7], "LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.actualProductionQueueMutationAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_PRODUCTION_QUEUE_MUTATION")
}

func runTestProductionQueueMutationDryRunBlocksMissingMarkers(): Unit {
    let gateReceipt = buildIgniteProductionQueueMutationGateReceipt(
        commitBoundaryReceiptFor("long-handler"),
        acceptedMutationGateRequest()
    )
    let receipt = buildIgniteProductionQueueMutationDryRunReceipt(
        gateReceipt,
        IgniteProductionQueueMutationDryRunRequest(
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
            false,
            false
        )
    )

    @Assert(receipt.status, "blocked-production-queue-mutation-dry-run-input")
    @Assert(receipt.productionQueueMutationDryRunAccepted, false)
    @Assert(receipt.blockers[0], "MUTATION_DRY_RUN_ID_NOT_CARRIED")
    @Assert(receipt.blockers[1], "MUTATION_GATE_SNAPSHOT_NOT_CARRIED")
    @Assert(receipt.blockers[2], "QUEUE_STORAGE_SNAPSHOT_NOT_CARRIED")
    @Assert(receipt.blockers[3], "MUTATION_WRITE_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[4], "QUEUE_DEPTH_TRANSITION_NOT_CARRIED")
    @Assert(receipt.blockers[5], "LANE_TOKEN_SNAPSHOT_NOT_CARRIED")
    @Assert(receipt.blockers[6], "EXECUTOR_TOKEN_SNAPSHOT_NOT_CARRIED")
    @Assert(receipt.blockers[7], "ROLLBACK_SNAPSHOT_NOT_CARRIED")
    @Assert(receipt.blockers[8], "BACKPRESSURE_LEASE_NOT_CARRIED")
    @Assert(receipt.blockers[9], "COMPLETION_CALLBACK_BOUNDARY_NOT_CARRIED")
    @Assert(receipt.mutationDryRunRecorded, false)
}

func runTestProductionQueueMutationDryRunMapsLaneModes(): Unit {
    let shortGateReceipt = buildIgniteProductionQueueMutationGateReceipt(
        commitBoundaryReceiptFor("short-handler"),
        acceptedMutationGateRequest()
    )
    let longGateReceipt = buildIgniteProductionQueueMutationGateReceipt(
        commitBoundaryReceiptFor("long-handler"),
        acceptedMutationGateRequest()
    )
    let blockingGateReceipt = buildIgniteProductionQueueMutationGateReceipt(
        commitBoundaryReceiptFor("blocking-external-operation"),
        acceptedMutationGateRequest()
    )
    let shortReceipt = buildIgniteProductionQueueMutationDryRunReceipt(
        shortGateReceipt,
        acceptedMutationDryRunRequest()
    )
    let longReceipt = buildIgniteProductionQueueMutationDryRunReceipt(
        longGateReceipt,
        acceptedMutationDryRunRequest()
    )
    let blockingReceipt = buildIgniteProductionQueueMutationDryRunReceipt(
        blockingGateReceipt,
        acceptedMutationDryRunRequest()
    )

    @Assert(
        shortReceipt.status,
        "accepted-production-queue-mutation-dry-run-receipt"
    )
    @Assert(
        shortReceipt.productionQueueMutationDryRunMode,
        "short-production-queue-mutation-dry-run"
    )
    @Assert(
        longReceipt.productionQueueMutationDryRunMode,
        "long-production-queue-mutation-dry-run"
    )
    @Assert(
        blockingReceipt.productionQueueMutationDryRunMode,
        "blocking-isolation-production-queue-mutation-dry-run"
    )
    @Assert(blockingReceipt.productionQueueMutationDryRunAccepted, true)
    @Assert(blockingReceipt.productionQueueMutationDryRunAllowed, true)
    @Assert(blockingReceipt.actualProductionQueueMutationAllowed, false)
    @Assert(blockingReceipt.queueDepthBefore, 2)
    @Assert(blockingReceipt.queueDepthAfter, 3)
    @Assert(blockingReceipt.mutationDryRunRecorded, true)
}

func runTestProductionQueueMutationCommitPlanBlocksRejectedDryRun(): Unit {
    let rejectedGate = buildIgniteProductionQueueMutationGateReceipt(
        commitBoundaryReceiptFor("short-handler"),
        IgniteProductionQueueMutationGateRequest(
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
    let rejectedDryRun = buildIgniteProductionQueueMutationDryRunReceipt(
        rejectedGate,
        acceptedMutationDryRunRequest()
    )
    let receipt = buildIgniteProductionQueueMutationCommitPlanReceipt(
        rejectedDryRun,
        acceptedMutationCommitPlanRequest()
    )

    @Assert(receipt.status, "blocked-production-queue-mutation-dry-run-receipt")
    @Assert(receipt.action, "block")
    @Assert(receipt.productionQueueMutationCommitPlanAccepted, false)
    @Assert(receipt.productionQueueMutationDryRunAccepted, false)
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_DRY_RUN_NOT_ACCEPTED")
}

func runTestProductionQueueMutationCommitPlanRefusesActualMutationAndLiveOverreach(): Unit {
    let receipt = buildIgniteProductionQueueMutationCommitPlanReceipt(
        mutationDryRunReceiptFor("short-handler"),
        IgniteProductionQueueMutationCommitPlanRequest(
            "production-queue-mutation-commit-plan-2",
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
            true,
            true
        )
    )

    @Assert(receipt.status, "blocked-production-queue-mutation-commit-plan-input")
    @Assert(receipt.action, "block")
    @Assert(receipt.productionQueueMutationCommitPlanAccepted, false)
    @Assert(receipt.blockers[0], "ACTUAL_PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "LIVE_EXECUTOR_ENQUEUE_REQUESTED")
    @Assert(receipt.blockers[2], "RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[3], "HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[4], "REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[5], "RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[6], "TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[7], "LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.actualProductionQueueMutationAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_PRODUCTION_QUEUE_MUTATION")
}

func runTestProductionQueueMutationCommitPlanBlocksMissingMarkers(): Unit {
    let receipt = buildIgniteProductionQueueMutationCommitPlanReceipt(
        mutationDryRunReceiptFor("long-handler"),
        IgniteProductionQueueMutationCommitPlanRequest(
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
            false,
            false
        )
    )

    @Assert(receipt.status, "blocked-production-queue-mutation-commit-plan-input")
    @Assert(receipt.productionQueueMutationCommitPlanAccepted, false)
    @Assert(receipt.blockers[0], "MUTATION_COMMIT_PLAN_ID_NOT_CARRIED")
    @Assert(receipt.blockers[1], "DRY_RUN_SNAPSHOT_NOT_CARRIED")
    @Assert(receipt.blockers[2], "QUEUE_MUTATION_OPERATION_NOT_CARRIED")
    @Assert(receipt.blockers[3], "QUEUE_OWNER_TOKEN_NOT_CARRIED")
    @Assert(receipt.blockers[4], "QUEUE_SLOT_RESERVATION_NOT_CARRIED")
    @Assert(receipt.blockers[5], "QUEUE_DEPTH_EXPECTATION_NOT_CARRIED")
    @Assert(receipt.blockers[6], "ROLLBACK_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "FALLBACK_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[8], "COMPLETION_CALLBACK_BOUNDARY_NOT_CARRIED")
    @Assert(receipt.blockers[9], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.commitPlanRecorded, false)
}

func runTestProductionQueueMutationCommitPlanMapsLaneModes(): Unit {
    let shortReceipt = buildIgniteProductionQueueMutationCommitPlanReceipt(
        mutationDryRunReceiptFor("short-handler"),
        acceptedMutationCommitPlanRequest()
    )
    let longReceipt = buildIgniteProductionQueueMutationCommitPlanReceipt(
        mutationDryRunReceiptFor("long-handler"),
        acceptedMutationCommitPlanRequest()
    )
    let blockingReceipt = buildIgniteProductionQueueMutationCommitPlanReceipt(
        mutationDryRunReceiptFor("blocking-external-operation"),
        acceptedMutationCommitPlanRequest()
    )

    @Assert(
        shortReceipt.status,
        "accepted-production-queue-mutation-commit-plan-receipt"
    )
    @Assert(
        shortReceipt.productionQueueMutationCommitPlanMode,
        "short-production-queue-mutation-commit-plan"
    )
    @Assert(
        longReceipt.productionQueueMutationCommitPlanMode,
        "long-production-queue-mutation-commit-plan"
    )
    @Assert(
        blockingReceipt.productionQueueMutationCommitPlanMode,
        "blocking-isolation-production-queue-mutation-commit-plan"
    )
    @Assert(blockingReceipt.productionQueueMutationCommitPlanAccepted, true)
    @Assert(blockingReceipt.productionQueueMutationCommitPlanAllowed, true)
    @Assert(blockingReceipt.actualProductionQueueMutationAllowed, false)
    @Assert(blockingReceipt.queueDepthBefore, 2)
    @Assert(blockingReceipt.queueDepthAfter, 3)
    @Assert(blockingReceipt.commitPlanRecorded, true)
}

func runTestProductionQueueMutationApplyGateBlocksRejectedCommitPlan(): Unit {
    let rejectedGate = buildIgniteProductionQueueMutationGateReceipt(
        commitBoundaryReceiptFor("short-handler"),
        IgniteProductionQueueMutationGateRequest(
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
    let rejectedDryRun = buildIgniteProductionQueueMutationDryRunReceipt(
        rejectedGate,
        acceptedMutationDryRunRequest()
    )
    let rejectedCommitPlan = buildIgniteProductionQueueMutationCommitPlanReceipt(
        rejectedDryRun,
        acceptedMutationCommitPlanRequest()
    )
    let receipt = buildIgniteProductionQueueMutationApplyGateReceipt(
        rejectedCommitPlan,
        acceptedMutationApplyGateRequest()
    )

    @Assert(receipt.status, "blocked-production-queue-mutation-commit-plan-receipt")
    @Assert(receipt.action, "block")
    @Assert(receipt.productionQueueMutationApplyGateAccepted, false)
    @Assert(receipt.productionQueueMutationCommitPlanAccepted, false)
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_COMMIT_PLAN_NOT_ACCEPTED")
}

func runTestProductionQueueMutationApplyGateRefusesActualMutationAndLiveOverreach(): Unit {
    let receipt = buildIgniteProductionQueueMutationApplyGateReceipt(
        mutationCommitPlanReceiptFor("short-handler"),
        IgniteProductionQueueMutationApplyGateRequest(
            "production-queue-mutation-apply-gate-2",
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
            true,
            true
        )
    )

    @Assert(receipt.status, "blocked-production-queue-mutation-apply-gate-input")
    @Assert(receipt.action, "block")
    @Assert(receipt.productionQueueMutationApplyGateAccepted, false)
    @Assert(receipt.blockers[0], "ACTUAL_PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "LIVE_EXECUTOR_ENQUEUE_REQUESTED")
    @Assert(receipt.blockers[2], "RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[3], "HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[4], "REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[5], "RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[6], "TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[7], "LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.actualProductionQueueMutationAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_PRODUCTION_QUEUE_MUTATION")
}

func runTestProductionQueueMutationApplyGateBlocksMissingMarkers(): Unit {
    let receipt = buildIgniteProductionQueueMutationApplyGateReceipt(
        mutationCommitPlanReceiptFor("long-handler"),
        IgniteProductionQueueMutationApplyGateRequest(
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
            false,
            false
        )
    )

    @Assert(receipt.status, "blocked-production-queue-mutation-apply-gate-input")
    @Assert(receipt.productionQueueMutationApplyGateAccepted, false)
    @Assert(receipt.blockers[0], "MUTATION_APPLY_GATE_ID_NOT_CARRIED")
    @Assert(receipt.blockers[1], "COMMIT_PLAN_SNAPSHOT_NOT_CARRIED")
    @Assert(receipt.blockers[2], "APPLY_PERMISSION_TOKEN_NOT_CARRIED")
    @Assert(receipt.blockers[3], "QUEUE_MUTATION_GUARD_NOT_CARRIED")
    @Assert(receipt.blockers[4], "QUEUE_STATE_PRECHECK_NOT_CARRIED")
    @Assert(receipt.blockers[5], "ROLLBACK_CHECKPOINT_NOT_CARRIED")
    @Assert(receipt.blockers[6], "FALLBACK_PATH_NOT_CARRIED")
    @Assert(receipt.blockers[7], "IDEMPOTENCY_KEY_NOT_CARRIED")
    @Assert(receipt.blockers[8], "COMPLETION_FENCE_NOT_CARRIED")
    @Assert(receipt.blockers[9], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.applyGateRecorded, false)
}

func runTestProductionQueueMutationApplyGateMapsLaneModes(): Unit {
    let shortReceipt = buildIgniteProductionQueueMutationApplyGateReceipt(
        mutationCommitPlanReceiptFor("short-handler"),
        acceptedMutationApplyGateRequest()
    )
    let longReceipt = buildIgniteProductionQueueMutationApplyGateReceipt(
        mutationCommitPlanReceiptFor("long-handler"),
        acceptedMutationApplyGateRequest()
    )
    let blockingReceipt = buildIgniteProductionQueueMutationApplyGateReceipt(
        mutationCommitPlanReceiptFor("blocking-external-operation"),
        acceptedMutationApplyGateRequest()
    )

    @Assert(
        shortReceipt.status,
        "accepted-production-queue-mutation-apply-gate-receipt"
    )
    @Assert(
        shortReceipt.productionQueueMutationApplyGateMode,
        "short-production-queue-mutation-apply-gate"
    )
    @Assert(
        longReceipt.productionQueueMutationApplyGateMode,
        "long-production-queue-mutation-apply-gate"
    )
    @Assert(
        blockingReceipt.productionQueueMutationApplyGateMode,
        "blocking-isolation-production-queue-mutation-apply-gate"
    )
    @Assert(blockingReceipt.productionQueueMutationApplyGateAccepted, true)
    @Assert(blockingReceipt.productionQueueMutationApplyGateAllowed, true)
    @Assert(blockingReceipt.actualProductionQueueMutationAllowed, false)
    @Assert(blockingReceipt.queueDepthBefore, 2)
    @Assert(blockingReceipt.queueDepthAfter, 3)
    @Assert(blockingReceipt.applyGateRecorded, true)
}

func runTestControlledProductionQueueMutationApplyBlocksRejectedApplyGate(): Unit {
    let rejectedApplyGate = buildIgniteProductionQueueMutationApplyGateReceipt(
        mutationCommitPlanReceiptFor("short-handler"),
        IgniteProductionQueueMutationApplyGateRequest(
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
            false,
            false
        )
    )
    let receipt = buildIgniteControlledProductionQueueMutationApplyReceipt(
        rejectedApplyGate,
        acceptedControlledMutationApplyRequest()
    )

    @Assert(receipt.status, "blocked-production-queue-mutation-apply-gate-receipt")
    @Assert(receipt.action, "block")
    @Assert(receipt.controlledProductionQueueMutationApplyAccepted, false)
    @Assert(receipt.productionQueueMutationApplyGateAccepted, false)
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_APPLY_GATE_NOT_ACCEPTED")
}

func runTestControlledProductionQueueMutationApplyRefusesLiveOverreach(): Unit {
    let receipt = buildIgniteControlledProductionQueueMutationApplyReceipt(
        mutationApplyGateReceiptFor("short-handler"),
        IgniteControlledProductionQueueMutationApplyRequest(
            "controlled-production-queue-mutation-apply-2",
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

    @Assert(receipt.status, "blocked-controlled-production-queue-mutation-apply-input")
    @Assert(receipt.action, "block")
    @Assert(receipt.controlledProductionQueueMutationApplyAccepted, false)
    @Assert(receipt.blockers[0], "LIVE_EXECUTOR_ENQUEUE_REQUESTED")
    @Assert(receipt.blockers[1], "RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.liveExecutorEnqueueAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_LIVE_SERVER_WIRING")
}

func runTestControlledProductionQueueMutationApplyBlocksMissingMarkers(): Unit {
    let receipt = buildIgniteControlledProductionQueueMutationApplyReceipt(
        mutationApplyGateReceiptFor("long-handler"),
        IgniteControlledProductionQueueMutationApplyRequest(
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

    @Assert(receipt.status, "blocked-controlled-production-queue-mutation-apply-input")
    @Assert(receipt.controlledProductionQueueMutationApplyAccepted, false)
    @Assert(receipt.blockers[0], "CONTROLLED_MUTATION_APPLY_ID_NOT_CARRIED")
    @Assert(receipt.blockers[1], "APPLY_GATE_SNAPSHOT_NOT_CARRIED")
    @Assert(receipt.blockers[2], "MUTATION_LEASE_NOT_CARRIED")
    @Assert(receipt.blockers[3], "QUEUE_SLOT_OWNERSHIP_NOT_CARRIED")
    @Assert(receipt.blockers[4], "QUEUE_DEPTH_TRANSITION_NOT_CARRIED")
    @Assert(receipt.blockers[5], "ROLLBACK_ARMED_NOT_CARRIED")
    @Assert(receipt.blockers[6], "FALLBACK_ARMED_NOT_CARRIED")
    @Assert(receipt.blockers[7], "IDEMPOTENCY_NOT_CONFIRMED")
    @Assert(receipt.blockers[8], "COMPLETION_FENCE_NOT_CARRIED")
    @Assert(receipt.blockers[9], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.controlledApplyRecorded, false)
}

func runTestControlledProductionQueueMutationApplyMapsLaneModes(): Unit {
    let shortReceipt = buildIgniteControlledProductionQueueMutationApplyReceipt(
        mutationApplyGateReceiptFor("short-handler"),
        acceptedControlledMutationApplyRequest()
    )
    let longReceipt = buildIgniteControlledProductionQueueMutationApplyReceipt(
        mutationApplyGateReceiptFor("long-handler"),
        acceptedControlledMutationApplyRequest()
    )
    let blockingReceipt = buildIgniteControlledProductionQueueMutationApplyReceipt(
        mutationApplyGateReceiptFor("blocking-external-operation"),
        acceptedControlledMutationApplyRequest()
    )

    @Assert(
        shortReceipt.status,
        "accepted-controlled-production-queue-mutation-apply-receipt"
    )
    @Assert(
        shortReceipt.controlledProductionQueueMutationApplyMode,
        "short-controlled-production-queue-mutation-apply"
    )
    @Assert(
        longReceipt.controlledProductionQueueMutationApplyMode,
        "long-controlled-production-queue-mutation-apply"
    )
    @Assert(
        blockingReceipt.controlledProductionQueueMutationApplyMode,
        "blocking-isolation-controlled-production-queue-mutation-apply"
    )
    @Assert(blockingReceipt.controlledProductionQueueMutationApplyAccepted, true)
    @Assert(blockingReceipt.controlledProductionQueueMutationApplyAllowed, true)
    @Assert(blockingReceipt.liveExecutorEnqueueAllowed, false)
    @Assert(blockingReceipt.queueDepthBefore, 2)
    @Assert(blockingReceipt.queueDepthAfter, 3)
    @Assert(blockingReceipt.controlledApplyRecorded, true)
}

func runTestExecutorHandoffBlocksRejectedControlledApply(): Unit {
    let rejectedControlledApply = buildIgniteControlledProductionQueueMutationApplyReceipt(
        mutationApplyGateReceiptFor("short-handler"),
        IgniteControlledProductionQueueMutationApplyRequest(
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
    let receipt = buildIgniteExecutorHandoffReceipt(
        rejectedControlledApply,
        acceptedExecutorHandoffRequest()
    )

    @Assert(receipt.status, "blocked-controlled-production-queue-mutation-apply-receipt")
    @Assert(receipt.action, "block")
    @Assert(receipt.executorHandoffAccepted, false)
    @Assert(receipt.controlledProductionQueueMutationApplyAccepted, false)
    @Assert(receipt.blockers[0], "CONTROLLED_PRODUCTION_QUEUE_MUTATION_APPLY_NOT_ACCEPTED")
}

func runTestExecutorHandoffRefusesLiveOverreach(): Unit {
    let receipt = buildIgniteExecutorHandoffReceipt(
        controlledMutationApplyReceiptFor("short-handler"),
        IgniteExecutorHandoffRequest(
            "executor-handoff-2",
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

    @Assert(receipt.status, "blocked-executor-handoff-input")
    @Assert(receipt.action, "block")
    @Assert(receipt.executorHandoffAccepted, false)
    @Assert(receipt.blockers[0], "LIVE_EXECUTOR_ENQUEUE_REQUESTED")
    @Assert(receipt.blockers[1], "RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.liveExecutorEnqueueAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_LIVE_SERVER_WIRING")
}

func runTestExecutorHandoffBlocksMissingMarkers(): Unit {
    let receipt = buildIgniteExecutorHandoffReceipt(
        controlledMutationApplyReceiptFor("long-handler"),
        IgniteExecutorHandoffRequest(
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

    @Assert(receipt.status, "blocked-executor-handoff-input")
    @Assert(receipt.executorHandoffAccepted, false)
    @Assert(receipt.blockers[0], "EXECUTOR_HANDOFF_ID_NOT_CARRIED")
    @Assert(receipt.blockers[1], "CONTROLLED_APPLY_SNAPSHOT_NOT_CARRIED")
    @Assert(receipt.blockers[2], "EXECUTOR_LANE_NOT_CARRIED")
    @Assert(receipt.blockers[3], "EXECUTOR_TOKEN_NOT_CARRIED")
    @Assert(receipt.blockers[4], "QUEUE_SLOT_NOT_CARRIED")
    @Assert(receipt.blockers[5], "DISPATCH_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[6], "BACKPRESSURE_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[7], "CANCELLATION_BOUNDARY_NOT_CARRIED")
    @Assert(receipt.blockers[8], "COMPLETION_CALLBACK_NOT_CARRIED")
    @Assert(receipt.blockers[9], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.executorHandoffRecorded, false)
}

func runTestExecutorHandoffMapsLaneModes(): Unit {
    let shortReceipt = buildIgniteExecutorHandoffReceipt(
        controlledMutationApplyReceiptFor("short-handler"),
        acceptedExecutorHandoffRequest()
    )
    let longReceipt = buildIgniteExecutorHandoffReceipt(
        controlledMutationApplyReceiptFor("long-handler"),
        acceptedExecutorHandoffRequest()
    )
    let blockingReceipt = buildIgniteExecutorHandoffReceipt(
        controlledMutationApplyReceiptFor("blocking-external-operation"),
        acceptedExecutorHandoffRequest()
    )

    @Assert(shortReceipt.status, "accepted-executor-handoff-receipt")
    @Assert(shortReceipt.executorHandoffMode, "short-executor-handoff")
    @Assert(longReceipt.executorHandoffMode, "long-executor-handoff")
    @Assert(
        blockingReceipt.executorHandoffMode,
        "blocking-isolation-executor-handoff"
    )
    @Assert(blockingReceipt.executorHandoffAccepted, true)
    @Assert(blockingReceipt.executorHandoffAllowed, true)
    @Assert(blockingReceipt.liveExecutorEnqueueAllowed, false)
    @Assert(blockingReceipt.queueDepthBefore, 2)
    @Assert(blockingReceipt.queueDepthAfter, 3)
    @Assert(blockingReceipt.executorHandoffRecorded, true)
}

func runTestLiveExecutorEnqueueProofGateBlocksRejectedExecutorHandoff(): Unit {
    let rejectedExecutorHandoff = buildIgniteExecutorHandoffReceipt(
        controlledMutationApplyReceiptFor("short-handler"),
        IgniteExecutorHandoffRequest(
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
    let receipt = buildIgniteLiveExecutorEnqueueProofGateReceipt(
        rejectedExecutorHandoff,
        acceptedLiveExecutorEnqueueProofGateRequest()
    )

    @Assert(receipt.status, "blocked-executor-handoff-receipt")
    @Assert(receipt.action, "block")
    @Assert(receipt.liveExecutorEnqueueProofGateAccepted, false)
    @Assert(receipt.executorHandoffAccepted, false)
    @Assert(receipt.blockers[0], "EXECUTOR_HANDOFF_NOT_ACCEPTED")
}

func runTestLiveExecutorEnqueueProofGateRefusesRuntimeOverreach(): Unit {
    let receipt = buildIgniteLiveExecutorEnqueueProofGateReceipt(
        executorHandoffReceiptFor("short-handler"),
        IgniteLiveExecutorEnqueueProofGateRequest(
            "live-enqueue-proof-2",
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

    @Assert(receipt.status, "blocked-live-executor-enqueue-proof-gate-input")
    @Assert(receipt.action, "block")
    @Assert(receipt.liveExecutorEnqueueProofGateAccepted, false)
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.productionQueueMutationAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_LIVE_SERVER_WIRING")
}

func runTestLiveExecutorEnqueueProofGateBlocksMissingMarkers(): Unit {
    let receipt = buildIgniteLiveExecutorEnqueueProofGateReceipt(
        executorHandoffReceiptFor("long-handler"),
        IgniteLiveExecutorEnqueueProofGateRequest(
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
            false
        )
    )

    @Assert(receipt.status, "blocked-live-executor-enqueue-proof-gate-input")
    @Assert(receipt.liveExecutorEnqueueProofGateAccepted, false)
    @Assert(receipt.blockers[0], "LIVE_ENQUEUE_PROOF_ID_NOT_CARRIED")
    @Assert(receipt.blockers[1], "EXECUTOR_HANDOFF_SNAPSHOT_NOT_CARRIED")
    @Assert(receipt.blockers[2], "LIVE_ENQUEUE_TOKEN_NOT_CARRIED")
    @Assert(receipt.blockers[3], "QUEUE_OWNERSHIP_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[4], "CAPACITY_PROOF_NOT_CARRIED")
    @Assert(receipt.blockers[5], "FAIRNESS_PROOF_NOT_CARRIED")
    @Assert(receipt.blockers[6], "CANCELLATION_PROOF_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "COMPLETION_PROOF_NOT_CARRIED")
    @Assert(receipt.liveEnqueueProofRecorded, false)
}

func runTestLiveExecutorEnqueueProofGateMapsLaneModes(): Unit {
    let shortReceipt = buildIgniteLiveExecutorEnqueueProofGateReceipt(
        executorHandoffReceiptFor("short-handler"),
        acceptedLiveExecutorEnqueueProofGateRequest()
    )
    let longReceipt = buildIgniteLiveExecutorEnqueueProofGateReceipt(
        executorHandoffReceiptFor("long-handler"),
        acceptedLiveExecutorEnqueueProofGateRequest()
    )
    let blockingReceipt = buildIgniteLiveExecutorEnqueueProofGateReceipt(
        executorHandoffReceiptFor("blocking-external-operation"),
        acceptedLiveExecutorEnqueueProofGateRequest()
    )

    @Assert(shortReceipt.status, "accepted-live-executor-enqueue-proof-gate-receipt")
    @Assert(
        shortReceipt.liveExecutorEnqueueProofGateMode,
        "short-live-executor-enqueue-proof-gate"
    )
    @Assert(
        longReceipt.liveExecutorEnqueueProofGateMode,
        "long-live-executor-enqueue-proof-gate"
    )
    @Assert(
        blockingReceipt.liveExecutorEnqueueProofGateMode,
        "blocking-isolation-live-executor-enqueue-proof-gate"
    )
    @Assert(blockingReceipt.liveExecutorEnqueueProofGateAccepted, true)
    @Assert(blockingReceipt.liveExecutorEnqueueProofGateAllowed, true)
    @Assert(blockingReceipt.runtimeTaskSpawnAllowed, false)
    @Assert(blockingReceipt.queueDepthBefore, 2)
    @Assert(blockingReceipt.queueDepthAfter, 3)
    @Assert(blockingReceipt.liveEnqueueProofRecorded, true)
}

func runTestRuntimeTaskSpawnGateBlocksRejectedLiveEnqueueProofGate(): Unit {
    let rejectedLiveEnqueueProofGate = buildIgniteLiveExecutorEnqueueProofGateReceipt(
        executorHandoffReceiptFor("short-handler"),
        IgniteLiveExecutorEnqueueProofGateRequest(
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
            false
        )
    )
    let receipt = buildIgniteRuntimeTaskSpawnGateReceipt(
        rejectedLiveEnqueueProofGate,
        acceptedRuntimeTaskSpawnGateRequest()
    )

    @Assert(receipt.status, "blocked-live-executor-enqueue-proof-gate-receipt")
    @Assert(receipt.action, "block")
    @Assert(receipt.runtimeTaskSpawnGateAccepted, false)
    @Assert(receipt.liveExecutorEnqueueProofGateAccepted, false)
    @Assert(receipt.blockers[0], "LIVE_EXECUTOR_ENQUEUE_PROOF_GATE_NOT_ACCEPTED")
}

func runTestRuntimeTaskSpawnGateRefusesActualSpawnAndOverreach(): Unit {
    let receipt = buildIgniteRuntimeTaskSpawnGateReceipt(
        liveEnqueueProofGateReceiptFor("short-handler"),
        IgniteRuntimeTaskSpawnGateRequest(
            "runtime-spawn-gate-2",
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

    @Assert(receipt.status, "blocked-runtime-task-spawn-gate-input")
    @Assert(receipt.action, "block")
    @Assert(receipt.runtimeTaskSpawnGateAccepted, false)
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.actualRuntimeTaskSpawnAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_LIVE_SERVER_WIRING")
}

func runTestRuntimeTaskSpawnGateBlocksMissingMarkers(): Unit {
    let receipt = buildIgniteRuntimeTaskSpawnGateReceipt(
        liveEnqueueProofGateReceiptFor("long-handler"),
        IgniteRuntimeTaskSpawnGateRequest(
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

    @Assert(receipt.status, "blocked-runtime-task-spawn-gate-input")
    @Assert(receipt.runtimeTaskSpawnGateAccepted, false)
    @Assert(receipt.blockers[0], "RUNTIME_SPAWN_GATE_ID_NOT_CARRIED")
    @Assert(receipt.blockers[1], "LIVE_ENQUEUE_PROOF_SNAPSHOT_NOT_CARRIED")
    @Assert(receipt.blockers[2], "TASK_ENVELOPE_NOT_CARRIED")
    @Assert(receipt.blockers[3], "SCHEDULER_LANE_NOT_CARRIED")
    @Assert(receipt.blockers[4], "SPAWN_TOKEN_NOT_CARRIED")
    @Assert(receipt.blockers[5], "LIFECYCLE_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "CANCELLATION_BOUNDARY_NOT_CARRIED")
    @Assert(receipt.blockers[7], "HANDLER_ISOLATION_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "RESPONSE_ISOLATION_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[9], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.runtimeTaskSpawnGateRecorded, false)
}

func runTestRuntimeTaskSpawnGateMapsLaneModes(): Unit {
    let shortReceipt = buildIgniteRuntimeTaskSpawnGateReceipt(
        liveEnqueueProofGateReceiptFor("short-handler"),
        acceptedRuntimeTaskSpawnGateRequest()
    )
    let longReceipt = buildIgniteRuntimeTaskSpawnGateReceipt(
        liveEnqueueProofGateReceiptFor("long-handler"),
        acceptedRuntimeTaskSpawnGateRequest()
    )
    let blockingReceipt = buildIgniteRuntimeTaskSpawnGateReceipt(
        liveEnqueueProofGateReceiptFor("blocking-external-operation"),
        acceptedRuntimeTaskSpawnGateRequest()
    )

    @Assert(shortReceipt.status, "accepted-runtime-task-spawn-gate-receipt")
    @Assert(shortReceipt.runtimeTaskSpawnGateMode, "short-runtime-task-spawn-gate")
    @Assert(longReceipt.runtimeTaskSpawnGateMode, "long-runtime-task-spawn-gate")
    @Assert(
        blockingReceipt.runtimeTaskSpawnGateMode,
        "blocking-isolation-runtime-task-spawn-gate"
    )
    @Assert(blockingReceipt.runtimeTaskSpawnGateAccepted, true)
    @Assert(blockingReceipt.runtimeTaskSpawnGateAllowed, true)
    @Assert(blockingReceipt.actualRuntimeTaskSpawnAllowed, false)
    @Assert(blockingReceipt.handlerInvocationAllowed, false)
    @Assert(blockingReceipt.queueDepthBefore, 2)
    @Assert(blockingReceipt.queueDepthAfter, 3)
    @Assert(blockingReceipt.runtimeTaskSpawnGateRecorded, true)
}

func runTestHandlerInvocationGateBlocksRejectedRuntimeTaskSpawnGate(): Unit {
    let rejectedSpawnGate = buildIgniteRuntimeTaskSpawnGateReceipt(
        liveEnqueueProofGateReceiptFor("short-handler"),
        IgniteRuntimeTaskSpawnGateRequest(
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
    let receipt = buildIgniteHandlerInvocationGateReceipt(
        rejectedSpawnGate,
        acceptedHandlerInvocationGateRequest()
    )

    @Assert(receipt.status, "blocked-runtime-task-spawn-gate-receipt")
    @Assert(receipt.action, "block")
    @Assert(receipt.handlerInvocationGateAccepted, false)
    @Assert(receipt.runtimeTaskSpawnGateAccepted, false)
    @Assert(receipt.blockers[0], "RUNTIME_TASK_SPAWN_GATE_NOT_ACCEPTED")
}

func runTestHandlerInvocationGateRefusesActualHandlerAndOverreach(): Unit {
    let receipt = buildIgniteHandlerInvocationGateReceipt(
        runtimeTaskSpawnGateReceiptFor("short-handler"),
        IgniteHandlerInvocationGateRequest(
            "handler-invocation-gate-2",
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

    @Assert(receipt.status, "blocked-handler-invocation-gate-input")
    @Assert(receipt.action, "block")
    @Assert(receipt.handlerInvocationGateAccepted, false)
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "ACTUAL_HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.actualHandlerInvocationAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_LIVE_SERVER_WIRING")
}

func runTestHandlerInvocationGateBlocksMissingMarkers(): Unit {
    let receipt = buildIgniteHandlerInvocationGateReceipt(
        runtimeTaskSpawnGateReceiptFor("long-handler"),
        IgniteHandlerInvocationGateRequest(
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

    @Assert(receipt.status, "blocked-handler-invocation-gate-input")
    @Assert(receipt.handlerInvocationGateAccepted, false)
    @Assert(receipt.blockers[0], "HANDLER_INVOCATION_GATE_ID_NOT_CARRIED")
    @Assert(receipt.blockers[1], "RUNTIME_TASK_SPAWN_GATE_SNAPSHOT_NOT_CARRIED")
    @Assert(receipt.blockers[2], "HANDLER_REFERENCE_NOT_CARRIED")
    @Assert(receipt.blockers[3], "INVOCATION_TOKEN_NOT_CARRIED")
    @Assert(receipt.blockers[4], "REQUEST_SNAPSHOT_NOT_CARRIED")
    @Assert(receipt.blockers[5], "CTX_ISOLATION_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RESPONSE_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "ERROR_BOUNDARY_NOT_CARRIED")
    @Assert(receipt.blockers[8], "CANCELLATION_BOUNDARY_NOT_CARRIED")
    @Assert(receipt.blockers[9], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.handlerInvocationGateRecorded, false)
}

func runTestHandlerInvocationGateMapsLaneModes(): Unit {
    let shortReceipt = buildIgniteHandlerInvocationGateReceipt(
        runtimeTaskSpawnGateReceiptFor("short-handler"),
        acceptedHandlerInvocationGateRequest()
    )
    let longReceipt = buildIgniteHandlerInvocationGateReceipt(
        runtimeTaskSpawnGateReceiptFor("long-handler"),
        acceptedHandlerInvocationGateRequest()
    )
    let blockingReceipt = buildIgniteHandlerInvocationGateReceipt(
        runtimeTaskSpawnGateReceiptFor("blocking-external-operation"),
        acceptedHandlerInvocationGateRequest()
    )

    @Assert(shortReceipt.status, "accepted-handler-invocation-gate-receipt")
    @Assert(shortReceipt.handlerInvocationGateMode, "short-handler-invocation-gate")
    @Assert(longReceipt.handlerInvocationGateMode, "long-handler-invocation-gate")
    @Assert(
        blockingReceipt.handlerInvocationGateMode,
        "blocking-isolation-handler-invocation-gate"
    )
    @Assert(blockingReceipt.handlerInvocationGateAccepted, true)
    @Assert(blockingReceipt.handlerInvocationGateAllowed, true)
    @Assert(blockingReceipt.actualHandlerInvocationAllowed, false)
    @Assert(blockingReceipt.requestContextMutationAllowed, false)
    @Assert(blockingReceipt.queueDepthBefore, 2)
    @Assert(blockingReceipt.queueDepthAfter, 3)
    @Assert(blockingReceipt.handlerInvocationGateRecorded, true)
}

func runTestRequestContextMutationGateBlocksRejectedHandlerInvocationGate(): Unit {
    let rejectedInvocationGate = buildIgniteHandlerInvocationGateReceipt(
        runtimeTaskSpawnGateReceiptFor("short-handler"),
        IgniteHandlerInvocationGateRequest(
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
    let receipt = buildIgniteRequestContextMutationGateReceipt(
        rejectedInvocationGate,
        acceptedRequestContextMutationGateRequest()
    )

    @Assert(receipt.status, "blocked-handler-invocation-gate-receipt")
    @Assert(receipt.action, "block")
    @Assert(receipt.requestContextMutationGateAccepted, false)
    @Assert(receipt.handlerInvocationGateAccepted, false)
    @Assert(receipt.blockers[0], "HANDLER_INVOCATION_GATE_NOT_ACCEPTED")
}

func runTestRequestContextMutationGateRefusesActualCtxMutationAndOverreach(): Unit {
    let receipt = buildIgniteRequestContextMutationGateReceipt(
        handlerInvocationGateReceiptFor("short-handler"),
        IgniteRequestContextMutationGateRequest(
            "request-context-mutation-gate-2",
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

    @Assert(receipt.status, "blocked-request-context-mutation-gate-input")
    @Assert(receipt.action, "block")
    @Assert(receipt.requestContextMutationGateAccepted, false)
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "ACTUAL_HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.actualRequestContextMutationAllowed, false)
    @Assert(receipt.nonClaims[4], "NO_ACTUAL_REQUEST_CONTEXT_MUTATION")
}

func runTestRequestContextMutationGateBlocksMissingMarkers(): Unit {
    let receipt = buildIgniteRequestContextMutationGateReceipt(
        handlerInvocationGateReceiptFor("long-handler"),
        IgniteRequestContextMutationGateRequest(
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

    @Assert(receipt.status, "blocked-request-context-mutation-gate-input")
    @Assert(receipt.requestContextMutationGateAccepted, false)
    @Assert(receipt.blockers[0], "REQUEST_CONTEXT_MUTATION_GATE_ID_NOT_CARRIED")
    @Assert(receipt.blockers[1], "HANDLER_INVOCATION_GATE_SNAPSHOT_NOT_CARRIED")
    @Assert(receipt.blockers[2], "REQUEST_CONTEXT_CARRIER_NOT_CARRIED")
    @Assert(receipt.blockers[3], "CTX_MUTATION_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[4], "ROUTE_PARAMS_SNAPSHOT_NOT_CARRIED")
    @Assert(receipt.blockers[5], "QUERY_SNAPSHOT_NOT_CARRIED")
    @Assert(receipt.blockers[6], "BODY_ACCESS_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "STATE_ISOLATION_NOT_CARRIED")
    @Assert(receipt.blockers[8], "ERROR_BOUNDARY_NOT_CARRIED")
    @Assert(receipt.blockers[9], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.requestContextMutationGateRecorded, false)
}

func runTestRequestContextMutationGateMapsLaneModes(): Unit {
    let shortReceipt = buildIgniteRequestContextMutationGateReceipt(
        handlerInvocationGateReceiptFor("short-handler"),
        acceptedRequestContextMutationGateRequest()
    )
    let longReceipt = buildIgniteRequestContextMutationGateReceipt(
        handlerInvocationGateReceiptFor("long-handler"),
        acceptedRequestContextMutationGateRequest()
    )
    let blockingReceipt = buildIgniteRequestContextMutationGateReceipt(
        handlerInvocationGateReceiptFor("blocking-external-operation"),
        acceptedRequestContextMutationGateRequest()
    )

    @Assert(shortReceipt.status, "accepted-request-context-mutation-gate-receipt")
    @Assert(
        shortReceipt.requestContextMutationGateMode,
        "short-request-context-mutation-gate"
    )
    @Assert(
        longReceipt.requestContextMutationGateMode,
        "long-request-context-mutation-gate"
    )
    @Assert(
        blockingReceipt.requestContextMutationGateMode,
        "blocking-isolation-request-context-mutation-gate"
    )
    @Assert(blockingReceipt.requestContextMutationGateAccepted, true)
    @Assert(blockingReceipt.requestContextMutationGateAllowed, true)
    @Assert(blockingReceipt.actualRequestContextMutationAllowed, false)
    @Assert(blockingReceipt.responseWriteAllowed, false)
    @Assert(blockingReceipt.queueDepthBefore, 2)
    @Assert(blockingReceipt.queueDepthAfter, 3)
    @Assert(blockingReceipt.requestContextMutationGateRecorded, true)
}

func runTestResponseWriteGateBlocksRejectedRequestContextMutationGate(): Unit {
    let rejectedMutationGate = buildIgniteRequestContextMutationGateReceipt(
        handlerInvocationGateReceiptFor("short-handler"),
        IgniteRequestContextMutationGateRequest(
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
    let receipt = buildIgniteResponseWriteGateReceipt(
        rejectedMutationGate,
        acceptedResponseWriteGateRequest()
    )

    @Assert(receipt.status, "blocked-request-context-mutation-gate-receipt")
    @Assert(receipt.action, "block")
    @Assert(receipt.responseWriteGateAccepted, false)
    @Assert(receipt.requestContextMutationGateAccepted, false)
    @Assert(receipt.blockers[0], "REQUEST_CONTEXT_MUTATION_GATE_NOT_ACCEPTED")
}

func runTestResponseWriteGateRefusesActualWriteAndOverreach(): Unit {
    let receipt = buildIgniteResponseWriteGateReceipt(
        requestContextMutationGateReceiptFor("short-handler"),
        IgniteResponseWriteGateRequest(
            "response-write-gate-2",
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

    @Assert(receipt.status, "blocked-response-write-gate-input")
    @Assert(receipt.action, "block")
    @Assert(receipt.responseWriteGateAccepted, false)
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "ACTUAL_HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "ACTUAL_RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.actualResponseWriteAllowed, false)
    @Assert(receipt.nonClaims[5], "NO_ACTUAL_RESPONSE_WRITE")
}

func runTestResponseWriteGateBlocksMissingMarkers(): Unit {
    let receipt = buildIgniteResponseWriteGateReceipt(
        requestContextMutationGateReceiptFor("long-handler"),
        IgniteResponseWriteGateRequest(
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
            false
        )
    )

    @Assert(receipt.status, "blocked-response-write-gate-input")
    @Assert(receipt.responseWriteGateAccepted, false)
    @Assert(receipt.blockers[0], "RESPONSE_WRITE_GATE_ID_NOT_CARRIED")
    @Assert(receipt.blockers[1], "REQUEST_CONTEXT_MUTATION_GATE_SNAPSHOT_NOT_CARRIED")
    @Assert(receipt.blockers[2], "RESPONSE_CARRIER_NOT_CARRIED")
    @Assert(receipt.blockers[3], "STATUS_HEADER_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[4], "BODY_WRITER_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[5], "STREAMING_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[6], "ERROR_RESPONSE_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "BACKPRESSURE_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[8], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.responseWriteGateRecorded, false)
}

func runTestResponseWriteGateMapsLaneModes(): Unit {
    let shortReceipt = buildIgniteResponseWriteGateReceipt(
        requestContextMutationGateReceiptFor("short-handler"),
        acceptedResponseWriteGateRequest()
    )
    let longReceipt = buildIgniteResponseWriteGateReceipt(
        requestContextMutationGateReceiptFor("long-handler"),
        acceptedResponseWriteGateRequest()
    )
    let blockingReceipt = buildIgniteResponseWriteGateReceipt(
        requestContextMutationGateReceiptFor("blocking-external-operation"),
        acceptedResponseWriteGateRequest()
    )

    @Assert(shortReceipt.status, "accepted-response-write-gate-receipt")
    @Assert(shortReceipt.responseWriteGateMode, "short-response-write-gate")
    @Assert(longReceipt.responseWriteGateMode, "long-response-write-gate")
    @Assert(
        blockingReceipt.responseWriteGateMode,
        "blocking-isolation-response-write-gate"
    )
    @Assert(blockingReceipt.responseWriteGateAccepted, true)
    @Assert(blockingReceipt.responseWriteGateAllowed, true)
    @Assert(blockingReceipt.actualResponseWriteAllowed, false)
    @Assert(blockingReceipt.transportCommitAllowed, false)
    @Assert(blockingReceipt.queueDepthBefore, 2)
    @Assert(blockingReceipt.queueDepthAfter, 3)
    @Assert(blockingReceipt.responseWriteGateRecorded, true)
}

func runTestTransportCommitGateBlocksRejectedResponseWriteGate(): Unit {
    let rejectedResponseWriteGate = buildIgniteResponseWriteGateReceipt(
        requestContextMutationGateReceiptFor("short-handler"),
        IgniteResponseWriteGateRequest(
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
            false
        )
    )
    let receipt = buildIgniteTransportCommitGateReceipt(
        rejectedResponseWriteGate,
        acceptedTransportCommitGateRequest()
    )

    @Assert(receipt.status, "blocked-response-write-gate-receipt")
    @Assert(receipt.action, "block")
    @Assert(receipt.transportCommitGateAccepted, false)
    @Assert(receipt.responseWriteGateAccepted, false)
    @Assert(receipt.blockers[0], "RESPONSE_WRITE_GATE_NOT_ACCEPTED")
}

func runTestTransportCommitGateRefusesActualCommitAndOverreach(): Unit {
    let receipt = buildIgniteTransportCommitGateReceipt(
        responseWriteGateReceiptFor("short-handler"),
        IgniteTransportCommitGateRequest(
            "transport-commit-gate-2",
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

    @Assert(receipt.status, "blocked-transport-commit-gate-input")
    @Assert(receipt.action, "block")
    @Assert(receipt.transportCommitGateAccepted, false)
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "ACTUAL_HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "ACTUAL_RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.actualTransportCommitAllowed, false)
    @Assert(receipt.nonClaims[6], "NO_ACTUAL_TRANSPORT_COMMIT")
}

func runTestTransportCommitGateBlocksMissingMarkers(): Unit {
    let receipt = buildIgniteTransportCommitGateReceipt(
        responseWriteGateReceiptFor("long-handler"),
        IgniteTransportCommitGateRequest(
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
            false
        )
    )

    @Assert(receipt.status, "blocked-transport-commit-gate-input")
    @Assert(receipt.transportCommitGateAccepted, false)
    @Assert(receipt.blockers[0], "TRANSPORT_COMMIT_GATE_ID_NOT_CARRIED")
    @Assert(receipt.blockers[1], "RESPONSE_WRITE_GATE_SNAPSHOT_NOT_CARRIED")
    @Assert(receipt.blockers[2], "TRANSPORT_CARRIER_NOT_CARRIED")
    @Assert(receipt.blockers[3], "PROTOCOL_FRAME_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[4], "FLUSH_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[5], "COMPLETION_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[6], "FAILURE_RECOVERY_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "BACKPRESSURE_RELEASE_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[8], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.transportCommitGateRecorded, false)
}

func runTestTransportCommitGateMapsLaneModes(): Unit {
    let shortReceipt = buildIgniteTransportCommitGateReceipt(
        responseWriteGateReceiptFor("short-handler"),
        acceptedTransportCommitGateRequest()
    )
    let longReceipt = buildIgniteTransportCommitGateReceipt(
        responseWriteGateReceiptFor("long-handler"),
        acceptedTransportCommitGateRequest()
    )
    let blockingReceipt = buildIgniteTransportCommitGateReceipt(
        responseWriteGateReceiptFor("blocking-external-operation"),
        acceptedTransportCommitGateRequest()
    )

    @Assert(shortReceipt.status, "accepted-transport-commit-gate-receipt")
    @Assert(shortReceipt.transportCommitGateMode, "short-transport-commit-gate")
    @Assert(longReceipt.transportCommitGateMode, "long-transport-commit-gate")
    @Assert(
        blockingReceipt.transportCommitGateMode,
        "blocking-isolation-transport-commit-gate"
    )
    @Assert(blockingReceipt.transportCommitGateAccepted, true)
    @Assert(blockingReceipt.transportCommitGateAllowed, true)
    @Assert(blockingReceipt.actualTransportCommitAllowed, false)
    @Assert(blockingReceipt.liveServerWiringAllowed, false)
    @Assert(blockingReceipt.queueDepthBefore, 2)
    @Assert(blockingReceipt.queueDepthAfter, 3)
    @Assert(blockingReceipt.transportCommitGateRecorded, true)
}

func runTestLiveServerWiringGateBlocksRejectedTransportCommitGate(): Unit {
    let rejectedTransportCommitGate = buildIgniteTransportCommitGateReceipt(
        responseWriteGateReceiptFor("short-handler"),
        IgniteTransportCommitGateRequest(
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
            false
        )
    )
    let receipt = buildIgniteLiveServerWiringGateReceipt(
        rejectedTransportCommitGate,
        acceptedLiveServerWiringGateRequest()
    )

    @Assert(receipt.status, "blocked-transport-commit-gate-receipt")
    @Assert(receipt.action, "block")
    @Assert(receipt.liveServerWiringGateAccepted, false)
    @Assert(receipt.transportCommitGateAccepted, false)
    @Assert(receipt.blockers[0], "TRANSPORT_COMMIT_GATE_NOT_ACCEPTED")
}

func runTestLiveServerWiringGateRefusesActualWiringAndDefaultFlip(): Unit {
    let receipt = buildIgniteLiveServerWiringGateReceipt(
        transportCommitGateReceiptFor("short-handler"),
        IgniteLiveServerWiringGateRequest(
            "live-server-wiring-gate-2",
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

    @Assert(receipt.status, "blocked-live-server-wiring-gate-input")
    @Assert(receipt.action, "block")
    @Assert(receipt.liveServerWiringGateAccepted, false)
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "ACTUAL_HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "ACTUAL_RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.blockers[7], "DEFAULT_ENGINE_FLIP_REQUESTED")
    @Assert(receipt.actualLiveServerWiringAllowed, false)
    @Assert(receipt.defaultEngineFlipAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_LIVE_SERVER_WIRING")
    @Assert(receipt.nonClaims[1], "NO_DEFAULT_ENGINE_FLIP")
}

func runTestLiveServerWiringGateBlocksMissingMarkers(): Unit {
    let receipt = buildIgniteLiveServerWiringGateReceipt(
        transportCommitGateReceiptFor("long-handler"),
        IgniteLiveServerWiringGateRequest(
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
            false
        )
    )

    @Assert(receipt.status, "blocked-live-server-wiring-gate-input")
    @Assert(receipt.liveServerWiringGateAccepted, false)
    @Assert(receipt.blockers[0], "LIVE_SERVER_WIRING_GATE_ID_NOT_CARRIED")
    @Assert(receipt.blockers[1], "TRANSPORT_COMMIT_GATE_SNAPSHOT_NOT_CARRIED")
    @Assert(receipt.blockers[2], "SERVER_LIFECYCLE_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[3], "LISTENER_BINDING_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[4], "CONNECTION_ACCEPT_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[5], "REQUEST_DISPATCH_LOOP_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[6], "SHUTDOWN_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.liveServerWiringGateRecorded, false)
}

func runTestLiveServerWiringGateMapsLaneModes(): Unit {
    let shortReceipt = buildIgniteLiveServerWiringGateReceipt(
        transportCommitGateReceiptFor("short-handler"),
        acceptedLiveServerWiringGateRequest()
    )
    let longReceipt = buildIgniteLiveServerWiringGateReceipt(
        transportCommitGateReceiptFor("long-handler"),
        acceptedLiveServerWiringGateRequest()
    )
    let blockingReceipt = buildIgniteLiveServerWiringGateReceipt(
        transportCommitGateReceiptFor("blocking-external-operation"),
        acceptedLiveServerWiringGateRequest()
    )

    @Assert(shortReceipt.status, "accepted-live-server-wiring-gate-receipt")
    @Assert(shortReceipt.liveServerWiringGateMode, "short-live-server-wiring-gate")
    @Assert(longReceipt.liveServerWiringGateMode, "long-live-server-wiring-gate")
    @Assert(
        blockingReceipt.liveServerWiringGateMode,
        "blocking-isolation-live-server-wiring-gate"
    )
    @Assert(blockingReceipt.liveServerWiringGateAccepted, true)
    @Assert(blockingReceipt.liveServerWiringGateAllowed, true)
    @Assert(blockingReceipt.actualLiveServerWiringAllowed, false)
    @Assert(blockingReceipt.defaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.queueDepthBefore, 2)
    @Assert(blockingReceipt.queueDepthAfter, 3)
    @Assert(blockingReceipt.liveServerWiringGateRecorded, true)
}

func runTestDefaultEngineFlipReadinessGateBlocksRejectedLiveServerWiringGate(): Unit {
    let rejectedLiveServerWiringGate = buildIgniteLiveServerWiringGateReceipt(
        transportCommitGateReceiptFor("short-handler"),
        IgniteLiveServerWiringGateRequest(
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
            false
        )
    )
    let receipt = buildIgniteDefaultEngineFlipReadinessGateReceipt(
        rejectedLiveServerWiringGate,
        acceptedDefaultEngineFlipReadinessGateRequest()
    )

    @Assert(receipt.status, "blocked-live-server-wiring-gate-receipt")
    @Assert(receipt.action, "block")
    @Assert(receipt.defaultEngineFlipReadinessAccepted, false)
    @Assert(receipt.liveServerWiringGateAccepted, false)
    @Assert(receipt.blockers[0], "LIVE_SERVER_WIRING_GATE_NOT_ACCEPTED")
}

func runTestDefaultEngineFlipReadinessGateRefusesRuntimeFlipAndReleaseClaims(): Unit {
    let receipt = buildIgniteDefaultEngineFlipReadinessGateReceipt(
        liveServerWiringGateReceiptFor("short-handler"),
        IgniteDefaultEngineFlipReadinessGateRequest(
            "default-engine-flip-readiness-gate-2",
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
            true,
            true,
            true
        )
    )

    @Assert(receipt.status, "blocked-default-engine-flip-readiness-gate-input")
    @Assert(receipt.action, "block")
    @Assert(receipt.defaultEngineFlipReadinessAccepted, false)
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "ACTUAL_HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "ACTUAL_RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.blockers[7], "ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    @Assert(receipt.blockers[8], "PUBLIC_RELEASE_REQUESTED")
    @Assert(receipt.blockers[9], "STDX_REMOVAL_REQUESTED")
    @Assert(receipt.blockers[10], "H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    @Assert(receipt.actualDefaultEngineFlipAllowed, false)
    @Assert(receipt.publicReleaseAllowed, false)
    @Assert(receipt.stdxRemovalAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[1], "NO_PUBLIC_RELEASE_READINESS")
}

func runTestDefaultEngineFlipReadinessGateBlocksMissingMarkers(): Unit {
    let receipt = buildIgniteDefaultEngineFlipReadinessGateReceipt(
        liveServerWiringGateReceiptFor("long-handler"),
        IgniteDefaultEngineFlipReadinessGateRequest(
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
            false,
            false,
            false
        )
    )

    @Assert(receipt.status, "blocked-default-engine-flip-readiness-gate-input")
    @Assert(receipt.defaultEngineFlipReadinessAccepted, false)
    @Assert(
        receipt.blockers[0],
        "DEFAULT_ENGINE_FLIP_READINESS_GATE_ID_NOT_CARRIED"
    )
    @Assert(receipt.blockers[1], "LIVE_SERVER_WIRING_GATE_SNAPSHOT_NOT_CARRIED")
    @Assert(receipt.blockers[2], "DEFAULT_ENGINE_CANDIDATE_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[3], "ROLLBACK_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[4], "RELEASE_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[5], "RUNTIME_PARITY_PROOF_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[6], "STDX_REPLACEMENT_BOUNDARY_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.defaultEngineFlipReadinessGateRecorded, false)
}

func runTestDefaultEngineFlipReadinessGateMapsLaneModes(): Unit {
    let shortReceipt = buildIgniteDefaultEngineFlipReadinessGateReceipt(
        liveServerWiringGateReceiptFor("short-handler"),
        acceptedDefaultEngineFlipReadinessGateRequest()
    )
    let longReceipt = buildIgniteDefaultEngineFlipReadinessGateReceipt(
        liveServerWiringGateReceiptFor("long-handler"),
        acceptedDefaultEngineFlipReadinessGateRequest()
    )
    let blockingReceipt = buildIgniteDefaultEngineFlipReadinessGateReceipt(
        liveServerWiringGateReceiptFor("blocking-external-operation"),
        acceptedDefaultEngineFlipReadinessGateRequest()
    )

    @Assert(
        shortReceipt.status,
        "accepted-default-engine-flip-readiness-gate-receipt"
    )
    @Assert(
        shortReceipt.defaultEngineFlipReadinessMode,
        "short-default-engine-flip-readiness-gate"
    )
    @Assert(
        longReceipt.defaultEngineFlipReadinessMode,
        "long-default-engine-flip-readiness-gate"
    )
    @Assert(
        blockingReceipt.defaultEngineFlipReadinessMode,
        "blocking-isolation-default-engine-flip-readiness-gate"
    )
    @Assert(blockingReceipt.defaultEngineFlipReadinessAccepted, true)
    @Assert(blockingReceipt.defaultEngineFlipReadinessAllowed, true)
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(blockingReceipt.queueDepthBefore, 2)
    @Assert(blockingReceipt.queueDepthAfter, 3)
    @Assert(blockingReceipt.defaultEngineFlipReadinessGateRecorded, true)
}

func runTestDefaultEngineFlipApplyGateBlocksRejectedReadinessGate(): Unit {
    let rejectedReadinessGate = buildIgniteDefaultEngineFlipReadinessGateReceipt(
        liveServerWiringGateReceiptFor("short-handler"),
        IgniteDefaultEngineFlipReadinessGateRequest(
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
            false,
            false,
            false
        )
    )
    let receipt = buildIgniteDefaultEngineFlipApplyGateReceipt(
        rejectedReadinessGate,
        acceptedDefaultEngineFlipApplyGateRequest()
    )

    @Assert(receipt.status, "blocked-default-engine-flip-readiness-gate-receipt")
    @Assert(receipt.action, "block")
    @Assert(receipt.defaultEngineFlipApplyGateAccepted, false)
    @Assert(receipt.defaultEngineFlipReadinessAccepted, false)
    @Assert(
        receipt.blockers[0],
        "DEFAULT_ENGINE_FLIP_READINESS_GATE_NOT_ACCEPTED"
    )
}

func runTestDefaultEngineFlipApplyGateRefusesDefaultMutationAndReleaseClaims(): Unit {
    let receipt = buildIgniteDefaultEngineFlipApplyGateReceipt(
        defaultEngineFlipReadinessGateReceiptFor("short-handler"),
        IgniteDefaultEngineFlipApplyGateRequest(
            "default-engine-flip-apply-gate-2",
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
            true,
            true,
            true,
            true
        )
    )

    @Assert(receipt.status, "blocked-default-engine-flip-apply-gate-input")
    @Assert(receipt.action, "block")
    @Assert(receipt.defaultEngineFlipApplyGateAccepted, false)
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "ACTUAL_HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "ACTUAL_RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.blockers[7], "ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    @Assert(receipt.blockers[8], "DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    @Assert(receipt.blockers[9], "PUBLIC_RELEASE_REQUESTED")
    @Assert(receipt.blockers[10], "STDX_REMOVAL_REQUESTED")
    @Assert(receipt.blockers[11], "H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    @Assert(receipt.actualDefaultEngineFlipAllowed, false)
    @Assert(receipt.defaultEngineConfigMutationAllowed, false)
    @Assert(receipt.publicReleaseAllowed, false)
    @Assert(receipt.stdxRemovalAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[1], "NO_DEFAULT_ENGINE_CONFIG_MUTATION")
}

func runTestDefaultEngineFlipApplyGateBlocksMissingMarkers(): Unit {
    let receipt = buildIgniteDefaultEngineFlipApplyGateReceipt(
        defaultEngineFlipReadinessGateReceiptFor("long-handler"),
        IgniteDefaultEngineFlipApplyGateRequest(
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
            false,
            false,
            false,
            false
        )
    )

    @Assert(receipt.status, "blocked-default-engine-flip-apply-gate-input")
    @Assert(receipt.defaultEngineFlipApplyGateAccepted, false)
    @Assert(receipt.blockers[0], "DEFAULT_ENGINE_FLIP_APPLY_GATE_ID_NOT_CARRIED")
    @Assert(
        receipt.blockers[1],
        "DEFAULT_ENGINE_FLIP_READINESS_SNAPSHOT_NOT_CARRIED"
    )
    @Assert(receipt.blockers[2], "CANDIDATE_ENGINE_ID_NOT_CARRIED")
    @Assert(receipt.blockers[3], "DEFAULT_ROUTE_MUTATION_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[4], "CONFIGURATION_ISOLATION_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[5], "ROLLBACK_VERIFICATION_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RELEASE_GUARD_SNAPSHOT_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.defaultEngineFlipApplyGateRecorded, false)
}

func runTestDefaultEngineFlipApplyGateMapsLaneModes(): Unit {
    let shortReceipt = buildIgniteDefaultEngineFlipApplyGateReceipt(
        defaultEngineFlipReadinessGateReceiptFor("short-handler"),
        acceptedDefaultEngineFlipApplyGateRequest()
    )
    let longReceipt = buildIgniteDefaultEngineFlipApplyGateReceipt(
        defaultEngineFlipReadinessGateReceiptFor("long-handler"),
        acceptedDefaultEngineFlipApplyGateRequest()
    )
    let blockingReceipt = buildIgniteDefaultEngineFlipApplyGateReceipt(
        defaultEngineFlipReadinessGateReceiptFor("blocking-external-operation"),
        acceptedDefaultEngineFlipApplyGateRequest()
    )

    @Assert(shortReceipt.status, "accepted-default-engine-flip-apply-gate-receipt")
    @Assert(
        shortReceipt.defaultEngineFlipApplyGateMode,
        "short-default-engine-flip-apply-gate"
    )
    @Assert(
        longReceipt.defaultEngineFlipApplyGateMode,
        "long-default-engine-flip-apply-gate"
    )
    @Assert(
        blockingReceipt.defaultEngineFlipApplyGateMode,
        "blocking-isolation-default-engine-flip-apply-gate"
    )
    @Assert(blockingReceipt.defaultEngineFlipApplyGateAccepted, true)
    @Assert(blockingReceipt.defaultEngineFlipApplyGateAllowed, true)
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(blockingReceipt.queueDepthBefore, 2)
    @Assert(blockingReceipt.queueDepthAfter, 3)
    @Assert(blockingReceipt.defaultEngineFlipApplyGateRecorded, true)
}

func runTestControlledDefaultEngineFlipApplyBlocksRejectedApplyGate(): Unit {
    let rejectedApplyGate = buildIgniteDefaultEngineFlipApplyGateReceipt(
        defaultEngineFlipReadinessGateReceiptFor("short-handler"),
        IgniteDefaultEngineFlipApplyGateRequest(
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
            false,
            false,
            false,
            false
        )
    )
    let receipt = buildIgniteControlledDefaultEngineFlipApplyReceipt(
        rejectedApplyGate,
        acceptedControlledDefaultEngineFlipApplyRequest()
    )

    @Assert(receipt.status, "blocked-default-engine-flip-apply-gate-receipt")
    @Assert(receipt.action, "block")
    @Assert(receipt.controlledDefaultEngineFlipApplyAccepted, false)
    @Assert(receipt.defaultEngineFlipApplyGateAccepted, false)
    @Assert(receipt.blockers[0], "DEFAULT_ENGINE_FLIP_APPLY_GATE_NOT_ACCEPTED")
}

func runTestControlledDefaultEngineFlipApplyRefusesDefaultPathMutation(): Unit {
    let receipt = buildIgniteControlledDefaultEngineFlipApplyReceipt(
        defaultEngineFlipApplyGateReceiptFor("short-handler"),
        IgniteControlledDefaultEngineFlipApplyRequest(
            "controlled-default-engine-flip-apply-2",
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
            true,
            true,
            true,
            true,
            true
        )
    )

    @Assert(receipt.status, "blocked-controlled-default-engine-flip-apply-input")
    @Assert(receipt.action, "block")
    @Assert(receipt.controlledDefaultEngineFlipApplyAccepted, false)
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "ACTUAL_HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "ACTUAL_RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.blockers[7], "ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    @Assert(receipt.blockers[8], "DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    @Assert(receipt.blockers[9], "RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    @Assert(receipt.blockers[10], "PUBLIC_RELEASE_REQUESTED")
    @Assert(receipt.blockers[11], "STDX_REMOVAL_REQUESTED")
    @Assert(receipt.blockers[12], "H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    @Assert(receipt.actualDefaultEngineFlipAllowed, false)
    @Assert(receipt.defaultEngineConfigMutationAllowed, false)
    @Assert(receipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(receipt.publicReleaseAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestControlledDefaultEngineFlipApplyBlocksMissingMarkers(): Unit {
    let receipt = buildIgniteControlledDefaultEngineFlipApplyReceipt(
        defaultEngineFlipApplyGateReceiptFor("long-handler"),
        IgniteControlledDefaultEngineFlipApplyRequest(
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
            false,
            false,
            false,
            false,
            false
        )
    )

    @Assert(receipt.status, "blocked-controlled-default-engine-flip-apply-input")
    @Assert(receipt.controlledDefaultEngineFlipApplyAccepted, false)
    @Assert(
        receipt.blockers[0],
        "CONTROLLED_DEFAULT_ENGINE_FLIP_APPLY_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "DEFAULT_ENGINE_FLIP_APPLY_GATE_SNAPSHOT_NOT_CARRIED"
    )
    @Assert(receipt.blockers[2], "CANDIDATE_ENGINE_ID_NOT_CARRIED")
    @Assert(receipt.blockers[3], "ISOLATED_CONFIG_DRAFT_NOT_CARRIED")
    @Assert(receipt.blockers[4], "DEFAULT_ROUTE_MUTATION_DRY_RUN_NOT_CARRIED")
    @Assert(receipt.blockers[5], "ROLLBACK_CHECKPOINT_NOT_CARRIED")
    @Assert(receipt.blockers[6], "OPERATOR_APPROVAL_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.controlledDefaultEngineFlipApplyRecorded, false)
}

func runTestControlledDefaultEngineFlipApplyMapsLaneModes(): Unit {
    let shortReceipt = buildIgniteControlledDefaultEngineFlipApplyReceipt(
        defaultEngineFlipApplyGateReceiptFor("short-handler"),
        acceptedControlledDefaultEngineFlipApplyRequest()
    )
    let longReceipt = buildIgniteControlledDefaultEngineFlipApplyReceipt(
        defaultEngineFlipApplyGateReceiptFor("long-handler"),
        acceptedControlledDefaultEngineFlipApplyRequest()
    )
    let blockingReceipt = buildIgniteControlledDefaultEngineFlipApplyReceipt(
        defaultEngineFlipApplyGateReceiptFor("blocking-external-operation"),
        acceptedControlledDefaultEngineFlipApplyRequest()
    )

    @Assert(
        shortReceipt.status,
        "accepted-controlled-default-engine-flip-apply-receipt"
    )
    @Assert(
        shortReceipt.controlledDefaultEngineFlipApplyMode,
        "short-controlled-default-engine-flip-apply"
    )
    @Assert(
        longReceipt.controlledDefaultEngineFlipApplyMode,
        "long-controlled-default-engine-flip-apply"
    )
    @Assert(
        blockingReceipt.controlledDefaultEngineFlipApplyMode,
        "blocking-isolation-controlled-default-engine-flip-apply"
    )
    @Assert(blockingReceipt.controlledDefaultEngineFlipApplyAccepted, true)
    @Assert(blockingReceipt.controlledDefaultEngineFlipApplyAllowed, true)
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(blockingReceipt.queueDepthBefore, 2)
    @Assert(blockingReceipt.queueDepthAfter, 3)
    @Assert(blockingReceipt.controlledDefaultEngineFlipApplyRecorded, true)
}

func runTestDefaultEngineMutationCommitPlanBlocksRejectedControlledApply(): Unit {
    let rejectedControlledApply = buildIgniteControlledDefaultEngineFlipApplyReceipt(
        defaultEngineFlipApplyGateReceiptFor("short-handler"),
        IgniteControlledDefaultEngineFlipApplyRequest(
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
            false,
            false,
            false,
            false,
            false
        )
    )
    let receipt = buildIgniteDefaultEngineMutationCommitPlanReceipt(
        rejectedControlledApply,
        acceptedDefaultEngineMutationCommitPlanRequest()
    )

    @Assert(receipt.status, "blocked-controlled-default-engine-flip-apply-receipt")
    @Assert(receipt.action, "block")
    @Assert(receipt.defaultEngineMutationCommitPlanAccepted, false)
    @Assert(receipt.controlledDefaultEngineFlipApplyAccepted, false)
    @Assert(
        receipt.blockers[0],
        "CONTROLLED_DEFAULT_ENGINE_FLIP_APPLY_NOT_ACCEPTED"
    )
}

func runTestDefaultEngineMutationCommitPlanRefusesRuntimeMutation(): Unit {
    let receipt = buildIgniteDefaultEngineMutationCommitPlanReceipt(
        controlledDefaultEngineFlipApplyReceiptFor("short-handler"),
        IgniteDefaultEngineMutationCommitPlanRequest(
            "default-engine-mutation-commit-plan-2",
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
            true,
            true,
            true,
            true,
            true,
            true
        )
    )

    @Assert(receipt.status, "blocked-default-engine-mutation-commit-plan-input")
    @Assert(receipt.action, "block")
    @Assert(receipt.defaultEngineMutationCommitPlanAccepted, false)
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "ACTUAL_HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "ACTUAL_RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.blockers[7], "ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    @Assert(receipt.blockers[8], "DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    @Assert(receipt.blockers[9], "RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    @Assert(receipt.blockers[10], "PUBLIC_RELEASE_REQUESTED")
    @Assert(receipt.blockers[11], "STDX_REMOVAL_REQUESTED")
    @Assert(receipt.blockers[12], "H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    @Assert(receipt.actualDefaultEngineFlipAllowed, false)
    @Assert(receipt.defaultEngineConfigMutationAllowed, false)
    @Assert(receipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(receipt.publicReleaseAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestDefaultEngineMutationCommitPlanBlocksMissingMarkers(): Unit {
    let receipt = buildIgniteDefaultEngineMutationCommitPlanReceipt(
        controlledDefaultEngineFlipApplyReceiptFor("long-handler"),
        IgniteDefaultEngineMutationCommitPlanRequest(
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
            false,
            false,
            false,
            false,
            false,
            false
        )
    )

    @Assert(receipt.status, "blocked-default-engine-mutation-commit-plan-input")
    @Assert(receipt.defaultEngineMutationCommitPlanAccepted, false)
    @Assert(
        receipt.blockers[0],
        "DEFAULT_ENGINE_MUTATION_COMMIT_PLAN_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "CONTROLLED_DEFAULT_ENGINE_FLIP_APPLY_SNAPSHOT_NOT_CARRIED"
    )
    @Assert(receipt.blockers[2], "CANDIDATE_ENGINE_ID_NOT_CARRIED")
    @Assert(receipt.blockers[3], "MUTATION_PLAN_ID_NOT_CARRIED")
    @Assert(receipt.blockers[4], "RUNTIME_DEFAULT_PATH_TARGET_NOT_CARRIED")
    @Assert(receipt.blockers[5], "ATOMIC_SWITCH_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[6], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[7], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[8], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.defaultEngineMutationCommitPlanRecorded, false)
}

func runTestDefaultEngineMutationCommitPlanMapsLaneModes(): Unit {
    let shortReceipt = buildIgniteDefaultEngineMutationCommitPlanReceipt(
        controlledDefaultEngineFlipApplyReceiptFor("short-handler"),
        acceptedDefaultEngineMutationCommitPlanRequest()
    )
    let longReceipt = buildIgniteDefaultEngineMutationCommitPlanReceipt(
        controlledDefaultEngineFlipApplyReceiptFor("long-handler"),
        acceptedDefaultEngineMutationCommitPlanRequest()
    )
    let blockingReceipt = buildIgniteDefaultEngineMutationCommitPlanReceipt(
        controlledDefaultEngineFlipApplyReceiptFor("blocking-external-operation"),
        acceptedDefaultEngineMutationCommitPlanRequest()
    )

    @Assert(
        shortReceipt.status,
        "accepted-default-engine-mutation-commit-plan-receipt"
    )
    @Assert(
        shortReceipt.defaultEngineMutationCommitPlanMode,
        "short-default-engine-mutation-commit-plan"
    )
    @Assert(
        longReceipt.defaultEngineMutationCommitPlanMode,
        "long-default-engine-mutation-commit-plan"
    )
    @Assert(
        blockingReceipt.defaultEngineMutationCommitPlanMode,
        "blocking-isolation-default-engine-mutation-commit-plan"
    )
    @Assert(blockingReceipt.defaultEngineMutationCommitPlanAccepted, true)
    @Assert(blockingReceipt.defaultEngineMutationCommitPlanAllowed, true)
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(blockingReceipt.queueDepthBefore, 2)
    @Assert(blockingReceipt.queueDepthAfter, 3)
    @Assert(blockingReceipt.defaultEngineMutationCommitPlanRecorded, true)
}

func runTestDefaultEngineMutationDryRunBlocksRejectedCommitPlan(): Unit {
    let rejectedCommitPlan = buildIgniteDefaultEngineMutationCommitPlanReceipt(
        controlledDefaultEngineFlipApplyReceiptFor("short-handler"),
        IgniteDefaultEngineMutationCommitPlanRequest(
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
            false,
            false,
            false,
            false,
            false,
            false
        )
    )
    let receipt = buildIgniteDefaultEngineMutationDryRunReceipt(
        rejectedCommitPlan,
        acceptedDefaultEngineMutationDryRunRequest()
    )

    @Assert(receipt.status, "blocked-default-engine-mutation-commit-plan-receipt")
    @Assert(receipt.action, "block")
    @Assert(receipt.defaultEngineMutationDryRunAccepted, false)
    @Assert(receipt.defaultEngineMutationCommitPlanAccepted, false)
    @Assert(
        receipt.blockers[0],
        "DEFAULT_ENGINE_MUTATION_COMMIT_PLAN_NOT_ACCEPTED"
    )
}

func runTestDefaultEngineMutationDryRunRefusesRuntimeMutation(): Unit {
    let receipt = buildIgniteDefaultEngineMutationDryRunReceipt(
        defaultEngineMutationCommitPlanReceiptFor("short-handler"),
        IgniteDefaultEngineMutationDryRunRequest(
            "default-engine-mutation-dry-run-2",
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
            true,
            true,
            true,
            true,
            true,
            true,
            true
        )
    )

    @Assert(receipt.status, "blocked-default-engine-mutation-dry-run-input")
    @Assert(receipt.action, "block")
    @Assert(receipt.defaultEngineMutationDryRunAccepted, false)
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "ACTUAL_HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "ACTUAL_RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.blockers[7], "ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    @Assert(receipt.blockers[8], "DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    @Assert(receipt.blockers[9], "RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    @Assert(receipt.blockers[10], "PUBLIC_RELEASE_REQUESTED")
    @Assert(receipt.blockers[11], "STDX_REMOVAL_REQUESTED")
    @Assert(receipt.blockers[12], "H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    @Assert(receipt.actualDefaultEngineFlipAllowed, false)
    @Assert(receipt.defaultEngineConfigMutationAllowed, false)
    @Assert(receipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(receipt.publicReleaseAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestDefaultEngineMutationDryRunBlocksMissingMarkers(): Unit {
    let receipt = buildIgniteDefaultEngineMutationDryRunReceipt(
        defaultEngineMutationCommitPlanReceiptFor("long-handler"),
        IgniteDefaultEngineMutationDryRunRequest(
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
            false,
            false,
            false,
            false,
            false,
            false,
            false
        )
    )

    @Assert(receipt.status, "blocked-default-engine-mutation-dry-run-input")
    @Assert(receipt.defaultEngineMutationDryRunAccepted, false)
    @Assert(
        receipt.blockers[0],
        "DEFAULT_ENGINE_MUTATION_DRY_RUN_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "DEFAULT_ENGINE_MUTATION_COMMIT_PLAN_SNAPSHOT_NOT_CARRIED"
    )
    @Assert(receipt.blockers[2], "CANDIDATE_ENGINE_ID_NOT_CARRIED")
    @Assert(receipt.blockers[3], "RUNTIME_DEFAULT_PATH_TARGET_NOT_CARRIED")
    @Assert(receipt.blockers[4], "ISOLATED_MUTATION_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[5], "DRY_RUN_SANDBOX_NOT_CARRIED")
    @Assert(receipt.blockers[6], "CONFIG_DIFF_PREVIEW_NOT_CARRIED")
    @Assert(receipt.blockers[7], "ROLLBACK_SIMULATION_NOT_CARRIED")
    @Assert(receipt.blockers[8], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[9], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.defaultEngineMutationDryRunRecorded, false)
}

func runTestDefaultEngineMutationDryRunMapsLaneModes(): Unit {
    let shortReceipt = buildIgniteDefaultEngineMutationDryRunReceipt(
        defaultEngineMutationCommitPlanReceiptFor("short-handler"),
        acceptedDefaultEngineMutationDryRunRequest()
    )
    let longReceipt = buildIgniteDefaultEngineMutationDryRunReceipt(
        defaultEngineMutationCommitPlanReceiptFor("long-handler"),
        acceptedDefaultEngineMutationDryRunRequest()
    )
    let blockingReceipt = buildIgniteDefaultEngineMutationDryRunReceipt(
        defaultEngineMutationCommitPlanReceiptFor("blocking-external-operation"),
        acceptedDefaultEngineMutationDryRunRequest()
    )

    @Assert(
        shortReceipt.status,
        "accepted-default-engine-mutation-dry-run-receipt"
    )
    @Assert(
        shortReceipt.defaultEngineMutationDryRunMode,
        "short-default-engine-mutation-dry-run"
    )
    @Assert(
        longReceipt.defaultEngineMutationDryRunMode,
        "long-default-engine-mutation-dry-run"
    )
    @Assert(
        blockingReceipt.defaultEngineMutationDryRunMode,
        "blocking-isolation-default-engine-mutation-dry-run"
    )
    @Assert(blockingReceipt.defaultEngineMutationDryRunAccepted, true)
    @Assert(blockingReceipt.defaultEngineMutationDryRunAllowed, true)
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(blockingReceipt.commitPlanReceipt.queueDepthBefore, 2)
    @Assert(blockingReceipt.commitPlanReceipt.queueDepthAfter, 3)
    @Assert(blockingReceipt.defaultEngineMutationDryRunRecorded, true)
}

func runTestDefaultEngineMutationApplyGateBlocksRejectedDryRun(): Unit {
    let rejectedDryRun = buildIgniteDefaultEngineMutationDryRunReceipt(
        defaultEngineMutationCommitPlanReceiptFor("short-handler"),
        IgniteDefaultEngineMutationDryRunRequest(
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
            false,
            false,
            false,
            false,
            false,
            false,
            false
        )
    )
    let receipt = buildIgniteDefaultEngineMutationApplyGateReceipt(
        rejectedDryRun,
        acceptedDefaultEngineMutationApplyGateRequest()
    )

    @Assert(receipt.status, "blocked-default-engine-mutation-dry-run-receipt")
    @Assert(receipt.action, "block")
    @Assert(receipt.defaultEngineMutationApplyGateAccepted, false)
    @Assert(receipt.defaultEngineMutationDryRunAccepted, false)
    @Assert(
        receipt.blockers[0],
        "DEFAULT_ENGINE_MUTATION_DRY_RUN_NOT_ACCEPTED"
    )
}

func runTestDefaultEngineMutationApplyGateRefusesRuntimeMutation(): Unit {
    let receipt = buildIgniteDefaultEngineMutationApplyGateReceipt(
        defaultEngineMutationDryRunReceiptFor("short-handler"),
        IgniteDefaultEngineMutationApplyGateRequest(
            "default-engine-mutation-apply-gate-2",
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
            true,
            true,
            true,
            true,
            true,
            true
        )
    )

    @Assert(receipt.status, "blocked-default-engine-mutation-apply-gate-input")
    @Assert(receipt.action, "block")
    @Assert(receipt.defaultEngineMutationApplyGateAccepted, false)
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "ACTUAL_HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "ACTUAL_RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.blockers[7], "ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    @Assert(receipt.blockers[8], "DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    @Assert(receipt.blockers[9], "RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    @Assert(receipt.blockers[10], "PUBLIC_RELEASE_REQUESTED")
    @Assert(receipt.blockers[11], "STDX_REMOVAL_REQUESTED")
    @Assert(receipt.blockers[12], "H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    @Assert(receipt.actualDefaultEngineFlipAllowed, false)
    @Assert(receipt.defaultEngineConfigMutationAllowed, false)
    @Assert(receipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(receipt.publicReleaseAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestDefaultEngineMutationApplyGateBlocksMissingMarkers(): Unit {
    let receipt = buildIgniteDefaultEngineMutationApplyGateReceipt(
        defaultEngineMutationDryRunReceiptFor("long-handler"),
        IgniteDefaultEngineMutationApplyGateRequest(
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
            false,
            false,
            false,
            false,
            false,
            false
        )
    )

    @Assert(receipt.status, "blocked-default-engine-mutation-apply-gate-input")
    @Assert(receipt.defaultEngineMutationApplyGateAccepted, false)
    @Assert(
        receipt.blockers[0],
        "DEFAULT_ENGINE_MUTATION_APPLY_GATE_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "DEFAULT_ENGINE_MUTATION_DRY_RUN_SNAPSHOT_NOT_CARRIED"
    )
    @Assert(receipt.blockers[2], "CANDIDATE_ENGINE_ID_NOT_CARRIED")
    @Assert(receipt.blockers[3], "RUNTIME_DEFAULT_PATH_TARGET_NOT_CARRIED")
    @Assert(receipt.blockers[4], "APPLY_PRECONDITION_GATE_NOT_CARRIED")
    @Assert(receipt.blockers[5], "CONFIG_MUTATION_LOCK_NOT_CARRIED")
    @Assert(receipt.blockers[6], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[7], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[8], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.defaultEngineMutationApplyGateRecorded, false)
}

func runTestDefaultEngineMutationApplyGateMapsLaneModes(): Unit {
    let shortReceipt = buildIgniteDefaultEngineMutationApplyGateReceipt(
        defaultEngineMutationDryRunReceiptFor("short-handler"),
        acceptedDefaultEngineMutationApplyGateRequest()
    )
    let longReceipt = buildIgniteDefaultEngineMutationApplyGateReceipt(
        defaultEngineMutationDryRunReceiptFor("long-handler"),
        acceptedDefaultEngineMutationApplyGateRequest()
    )
    let blockingReceipt = buildIgniteDefaultEngineMutationApplyGateReceipt(
        defaultEngineMutationDryRunReceiptFor("blocking-external-operation"),
        acceptedDefaultEngineMutationApplyGateRequest()
    )

    @Assert(
        shortReceipt.status,
        "accepted-default-engine-mutation-apply-gate-receipt"
    )
    @Assert(
        shortReceipt.defaultEngineMutationApplyGateMode,
        "short-default-engine-mutation-apply-gate"
    )
    @Assert(
        longReceipt.defaultEngineMutationApplyGateMode,
        "long-default-engine-mutation-apply-gate"
    )
    @Assert(
        blockingReceipt.defaultEngineMutationApplyGateMode,
        "blocking-isolation-default-engine-mutation-apply-gate"
    )
    @Assert(blockingReceipt.defaultEngineMutationApplyGateAccepted, true)
    @Assert(blockingReceipt.defaultEngineMutationApplyGateAllowed, true)
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(blockingReceipt.dryRunReceipt.commitPlanReceipt.queueDepthBefore, 2)
    @Assert(blockingReceipt.dryRunReceipt.commitPlanReceipt.queueDepthAfter, 3)
    @Assert(blockingReceipt.defaultEngineMutationApplyGateRecorded, true)
}

func runTestControlledDefaultEngineMutationApplyBlocksRejectedApplyGate(): Unit {
    let rejectedDryRun = buildIgniteDefaultEngineMutationDryRunReceipt(
        defaultEngineMutationCommitPlanReceiptFor("short-handler"),
        IgniteDefaultEngineMutationDryRunRequest(
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
            false,
            false,
            false,
            false,
            false,
            false,
            false
        )
    )
    let rejectedApplyGate = buildIgniteDefaultEngineMutationApplyGateReceipt(
        rejectedDryRun,
        acceptedDefaultEngineMutationApplyGateRequest()
    )
    let receipt = buildIgniteControlledDefaultEngineMutationApplyReceipt(
        rejectedApplyGate,
        acceptedControlledDefaultEngineMutationApplyRequest()
    )

    @Assert(
        receipt.status,
        "blocked-default-engine-mutation-apply-gate-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(receipt.controlledDefaultEngineMutationApplyAccepted, false)
    @Assert(receipt.defaultEngineMutationApplyGateAccepted, false)
    @Assert(
        receipt.blockers[0],
        "DEFAULT_ENGINE_MUTATION_APPLY_GATE_NOT_ACCEPTED"
    )
}

func runTestControlledDefaultEngineMutationApplyRefusesRuntimeMutation(): Unit {
    let receipt = buildIgniteControlledDefaultEngineMutationApplyReceipt(
        buildIgniteDefaultEngineMutationApplyGateReceipt(
            defaultEngineMutationDryRunReceiptFor("short-handler"),
            acceptedDefaultEngineMutationApplyGateRequest()
        ),
        IgniteControlledDefaultEngineMutationApplyRequest(
            "controlled-default-engine-mutation-apply-2",
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
            true,
            true,
            true,
            true,
            true
        )
    )

    @Assert(
        receipt.status,
        "blocked-controlled-default-engine-mutation-apply-input"
    )
    @Assert(receipt.action, "block")
    @Assert(receipt.controlledDefaultEngineMutationApplyAccepted, false)
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "ACTUAL_HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "ACTUAL_RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.blockers[7], "ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    @Assert(receipt.blockers[8], "DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    @Assert(receipt.blockers[9], "RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    @Assert(receipt.blockers[10], "PUBLIC_RELEASE_REQUESTED")
    @Assert(receipt.blockers[11], "STDX_REMOVAL_REQUESTED")
    @Assert(receipt.blockers[12], "H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    @Assert(receipt.actualDefaultEngineFlipAllowed, false)
    @Assert(receipt.defaultEngineConfigMutationAllowed, false)
    @Assert(receipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(receipt.publicReleaseAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestControlledDefaultEngineMutationApplyBlocksMissingMarkers(): Unit {
    let receipt = buildIgniteControlledDefaultEngineMutationApplyReceipt(
        buildIgniteDefaultEngineMutationApplyGateReceipt(
            defaultEngineMutationDryRunReceiptFor("long-handler"),
            acceptedDefaultEngineMutationApplyGateRequest()
        ),
        IgniteControlledDefaultEngineMutationApplyRequest(
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
            false,
            false,
            false,
            false,
            false
        )
    )

    @Assert(
        receipt.status,
        "blocked-controlled-default-engine-mutation-apply-input"
    )
    @Assert(receipt.controlledDefaultEngineMutationApplyAccepted, false)
    @Assert(
        receipt.blockers[0],
        "CONTROLLED_DEFAULT_ENGINE_MUTATION_APPLY_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "DEFAULT_ENGINE_MUTATION_APPLY_GATE_RECEIPT_NOT_CARRIED"
    )
    @Assert(receipt.blockers[2], "CONTROLLED_APPLY_SCOPE_NOT_CARRIED")
    @Assert(receipt.blockers[3], "DEFAULT_ENGINE_MUTATION_LOCK_NOT_CARRIED")
    @Assert(
        receipt.blockers[4],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(receipt.blockers[5], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.controlledDefaultEngineMutationApplyRecorded, false)
}

func runTestControlledDefaultEngineMutationApplyMapsLaneModes(): Unit {
    let shortReceipt = buildIgniteControlledDefaultEngineMutationApplyReceipt(
        buildIgniteDefaultEngineMutationApplyGateReceipt(
            defaultEngineMutationDryRunReceiptFor("short-handler"),
            acceptedDefaultEngineMutationApplyGateRequest()
        ),
        acceptedControlledDefaultEngineMutationApplyRequest()
    )
    let longReceipt = buildIgniteControlledDefaultEngineMutationApplyReceipt(
        buildIgniteDefaultEngineMutationApplyGateReceipt(
            defaultEngineMutationDryRunReceiptFor("long-handler"),
            acceptedDefaultEngineMutationApplyGateRequest()
        ),
        acceptedControlledDefaultEngineMutationApplyRequest()
    )
    let blockingReceipt = buildIgniteControlledDefaultEngineMutationApplyReceipt(
        buildIgniteDefaultEngineMutationApplyGateReceipt(
            defaultEngineMutationDryRunReceiptFor("blocking-external-operation"),
            acceptedDefaultEngineMutationApplyGateRequest()
        ),
        acceptedControlledDefaultEngineMutationApplyRequest()
    )

    @Assert(
        shortReceipt.status,
        "accepted-controlled-default-engine-mutation-apply-receipt"
    )
    @Assert(
        shortReceipt.controlledDefaultEngineMutationApplyMode,
        "short-controlled-default-engine-mutation-apply"
    )
    @Assert(
        longReceipt.controlledDefaultEngineMutationApplyMode,
        "long-controlled-default-engine-mutation-apply"
    )
    @Assert(
        blockingReceipt.controlledDefaultEngineMutationApplyMode,
        "blocking-isolation-controlled-default-engine-mutation-apply"
    )
    @Assert(blockingReceipt.controlledDefaultEngineMutationApplyAccepted, true)
    @Assert(blockingReceipt.controlledDefaultEngineMutationApplyAllowed, true)
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.queueDepthBefore,
        2
    )
    @Assert(
        blockingReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.queueDepthAfter,
        3
    )
    @Assert(
        blockingReceipt.controlledDefaultEngineMutationApplyRecorded,
        true
    )
}

func runTestRuntimeDefaultPathMutationGateBlocksRejectedControlledApply(): Unit {
    let rejectedDryRun = buildIgniteDefaultEngineMutationDryRunReceipt(
        defaultEngineMutationCommitPlanReceiptFor("short-handler"),
        IgniteDefaultEngineMutationDryRunRequest(
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
            false,
            false,
            false,
            false,
            false,
            false,
            false
        )
    )
    let rejectedApplyGate = buildIgniteDefaultEngineMutationApplyGateReceipt(
        rejectedDryRun,
        acceptedDefaultEngineMutationApplyGateRequest()
    )
    let rejectedControlledApply = buildIgniteControlledDefaultEngineMutationApplyReceipt(
        rejectedApplyGate,
        acceptedControlledDefaultEngineMutationApplyRequest()
    )
    let receipt = buildIgniteRuntimeDefaultPathMutationGateReceipt(
        rejectedControlledApply,
        acceptedRuntimeDefaultPathMutationGateRequest()
    )

    @Assert(
        receipt.status,
        "blocked-controlled-default-engine-mutation-apply-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(receipt.runtimeDefaultPathMutationGateAccepted, false)
    @Assert(receipt.controlledDefaultEngineMutationApplyAccepted, false)
    @Assert(
        receipt.blockers[0],
        "CONTROLLED_DEFAULT_ENGINE_MUTATION_APPLY_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationGateRefusesRuntimeMutation(): Unit {
    let receipt = buildIgniteRuntimeDefaultPathMutationGateReceipt(
        buildIgniteControlledDefaultEngineMutationApplyReceipt(
            buildIgniteDefaultEngineMutationApplyGateReceipt(
                defaultEngineMutationDryRunReceiptFor("short-handler"),
                acceptedDefaultEngineMutationApplyGateRequest()
            ),
            acceptedControlledDefaultEngineMutationApplyRequest()
        ),
        IgniteRuntimeDefaultPathMutationGateRequest(
            "runtime-default-path-mutation-gate-2",
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
            true,
            true,
            true,
            true,
            true,
            true
        )
    )

    @Assert(receipt.status, "blocked-runtime-default-path-mutation-gate-input")
    @Assert(receipt.action, "block")
    @Assert(receipt.runtimeDefaultPathMutationGateAccepted, false)
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "ACTUAL_HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "ACTUAL_RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.blockers[7], "ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    @Assert(receipt.blockers[8], "DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    @Assert(receipt.blockers[9], "RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    @Assert(receipt.blockers[10], "PUBLIC_RELEASE_REQUESTED")
    @Assert(receipt.blockers[11], "STDX_REMOVAL_REQUESTED")
    @Assert(receipt.blockers[12], "H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    @Assert(receipt.actualDefaultEngineFlipAllowed, false)
    @Assert(receipt.defaultEngineConfigMutationAllowed, false)
    @Assert(receipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(receipt.publicReleaseAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestRuntimeDefaultPathMutationGateBlocksMissingMarkers(): Unit {
    let receipt = buildIgniteRuntimeDefaultPathMutationGateReceipt(
        buildIgniteControlledDefaultEngineMutationApplyReceipt(
            buildIgniteDefaultEngineMutationApplyGateReceipt(
                defaultEngineMutationDryRunReceiptFor("long-handler"),
                acceptedDefaultEngineMutationApplyGateRequest()
            ),
            acceptedControlledDefaultEngineMutationApplyRequest()
        ),
        IgniteRuntimeDefaultPathMutationGateRequest(
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
            false,
            false,
            false,
            false,
            false,
            false
        )
    )

    @Assert(receipt.status, "blocked-runtime-default-path-mutation-gate-input")
    @Assert(receipt.runtimeDefaultPathMutationGateAccepted, false)
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_GATE_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "CONTROLLED_DEFAULT_ENGINE_MUTATION_APPLY_RECEIPT_NOT_CARRIED"
    )
    @Assert(receipt.blockers[2], "TARGET_RUNTIME_DEFAULT_PATH_NOT_CARRIED")
    @Assert(receipt.blockers[3], "MUTATION_GATE_PRECONDITION_NOT_CARRIED")
    @Assert(receipt.blockers[4], "DEFAULT_ENGINE_MUTATION_LOCK_NOT_CARRIED")
    @Assert(receipt.blockers[5], "CONFIG_MUTATION_LOCK_NOT_CARRIED")
    @Assert(receipt.blockers[6], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[7], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[8], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.runtimeDefaultPathMutationGateRecorded, false)
}

func runTestRuntimeDefaultPathMutationGateMapsLaneModes(): Unit {
    let shortReceipt = buildIgniteRuntimeDefaultPathMutationGateReceipt(
        buildIgniteControlledDefaultEngineMutationApplyReceipt(
            buildIgniteDefaultEngineMutationApplyGateReceipt(
                defaultEngineMutationDryRunReceiptFor("short-handler"),
                acceptedDefaultEngineMutationApplyGateRequest()
            ),
            acceptedControlledDefaultEngineMutationApplyRequest()
        ),
        acceptedRuntimeDefaultPathMutationGateRequest()
    )
    let longReceipt = buildIgniteRuntimeDefaultPathMutationGateReceipt(
        buildIgniteControlledDefaultEngineMutationApplyReceipt(
            buildIgniteDefaultEngineMutationApplyGateReceipt(
                defaultEngineMutationDryRunReceiptFor("long-handler"),
                acceptedDefaultEngineMutationApplyGateRequest()
            ),
            acceptedControlledDefaultEngineMutationApplyRequest()
        ),
        acceptedRuntimeDefaultPathMutationGateRequest()
    )
    let blockingReceipt = buildIgniteRuntimeDefaultPathMutationGateReceipt(
        buildIgniteControlledDefaultEngineMutationApplyReceipt(
            buildIgniteDefaultEngineMutationApplyGateReceipt(
                defaultEngineMutationDryRunReceiptFor("blocking-external-operation"),
                acceptedDefaultEngineMutationApplyGateRequest()
            ),
            acceptedControlledDefaultEngineMutationApplyRequest()
        ),
        acceptedRuntimeDefaultPathMutationGateRequest()
    )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-gate-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationGateMode,
        "short-runtime-default-path-mutation-gate"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationGateMode,
        "long-runtime-default-path-mutation-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationGateMode,
        "blocking-isolation-runtime-default-path-mutation-gate"
    )
    @Assert(blockingReceipt.runtimeDefaultPathMutationGateAccepted, true)
    @Assert(blockingReceipt.runtimeDefaultPathMutationGateAllowed, true)
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.queueDepthBefore,
        2
    )
    @Assert(
        blockingReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.queueDepthAfter,
        3
    )
    @Assert(blockingReceipt.runtimeDefaultPathMutationGateRecorded, true)
}

func runTestRuntimeDefaultPathMutationDryRunBlocksRejectedGate(): Unit {
    let rejectedControlledApply = buildIgniteControlledDefaultEngineMutationApplyReceipt(
        buildIgniteDefaultEngineMutationApplyGateReceipt(
            buildIgniteDefaultEngineMutationDryRunReceipt(
                defaultEngineMutationCommitPlanReceiptFor("short-handler"),
                IgniteDefaultEngineMutationDryRunRequest(
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
                    false,
                    false,
                    false,
                    false,
                    false,
                    false,
                    false
                )
            ),
            acceptedDefaultEngineMutationApplyGateRequest()
        ),
        acceptedControlledDefaultEngineMutationApplyRequest()
    )
    let rejectedGate = buildIgniteRuntimeDefaultPathMutationGateReceipt(
        rejectedControlledApply,
        acceptedRuntimeDefaultPathMutationGateRequest()
    )
    let receipt = buildIgniteRuntimeDefaultPathMutationDryRunReceipt(
        rejectedGate,
        acceptedRuntimeDefaultPathMutationDryRunRequest()
    )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-gate-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(receipt.runtimeDefaultPathMutationDryRunAccepted, false)
    @Assert(receipt.runtimeDefaultPathMutationGateAccepted, false)
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_GATE_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationDryRunRefusesRuntimeMutation(): Unit {
    let receipt = buildIgniteRuntimeDefaultPathMutationDryRunReceipt(
        runtimeDefaultPathMutationGateReceiptFor("short-handler"),
        IgniteRuntimeDefaultPathMutationDryRunRequest(
            "runtime-default-path-mutation-dry-run-2",
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
            true,
            true,
            true,
            true,
            true,
            true
        )
    )

    @Assert(receipt.status, "blocked-runtime-default-path-mutation-dry-run-input")
    @Assert(receipt.action, "block")
    @Assert(receipt.runtimeDefaultPathMutationDryRunAccepted, false)
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "ACTUAL_HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "ACTUAL_RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.blockers[7], "ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    @Assert(receipt.blockers[8], "DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    @Assert(receipt.blockers[9], "RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    @Assert(receipt.blockers[10], "PUBLIC_RELEASE_REQUESTED")
    @Assert(receipt.blockers[11], "STDX_REMOVAL_REQUESTED")
    @Assert(receipt.blockers[12], "H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    @Assert(receipt.actualDefaultEngineFlipAllowed, false)
    @Assert(receipt.defaultEngineConfigMutationAllowed, false)
    @Assert(receipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(receipt.publicReleaseAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestRuntimeDefaultPathMutationDryRunBlocksMissingMarkers(): Unit {
    let receipt = buildIgniteRuntimeDefaultPathMutationDryRunReceipt(
        runtimeDefaultPathMutationGateReceiptFor("long-handler"),
        IgniteRuntimeDefaultPathMutationDryRunRequest(
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
            false,
            false,
            false,
            false,
            false,
            false
        )
    )

    @Assert(receipt.status, "blocked-runtime-default-path-mutation-dry-run-input")
    @Assert(receipt.runtimeDefaultPathMutationDryRunAccepted, false)
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_DRY_RUN_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_GATE_RECEIPT_NOT_CARRIED"
    )
    @Assert(receipt.blockers[2], "TARGET_RUNTIME_DEFAULT_PATH_NOT_CARRIED")
    @Assert(receipt.blockers[3], "DRY_RUN_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[4], "DEFAULT_ENGINE_MUTATION_LOCK_NOT_CARRIED")
    @Assert(receipt.blockers[5], "CONFIG_MUTATION_LOCK_NOT_CARRIED")
    @Assert(receipt.blockers[6], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[7], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[8], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.runtimeDefaultPathMutationDryRunRecorded, false)
}

func runTestRuntimeDefaultPathMutationDryRunMapsLaneModes(): Unit {
    let shortReceipt = buildIgniteRuntimeDefaultPathMutationDryRunReceipt(
        runtimeDefaultPathMutationGateReceiptFor("short-handler"),
        acceptedRuntimeDefaultPathMutationDryRunRequest()
    )
    let longReceipt = buildIgniteRuntimeDefaultPathMutationDryRunReceipt(
        runtimeDefaultPathMutationGateReceiptFor("long-handler"),
        acceptedRuntimeDefaultPathMutationDryRunRequest()
    )
    let blockingReceipt = buildIgniteRuntimeDefaultPathMutationDryRunReceipt(
        runtimeDefaultPathMutationGateReceiptFor("blocking-external-operation"),
        acceptedRuntimeDefaultPathMutationDryRunRequest()
    )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-dry-run-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationDryRunMode,
        "short-runtime-default-path-mutation-dry-run"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationDryRunMode,
        "long-runtime-default-path-mutation-dry-run"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationDryRunMode,
        "blocking-isolation-runtime-default-path-mutation-dry-run"
    )
    @Assert(blockingReceipt.runtimeDefaultPathMutationDryRunAccepted, true)
    @Assert(blockingReceipt.runtimeDefaultPathMutationDryRunAllowed, true)
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.gateReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.queueDepthBefore,
        2
    )
    @Assert(
        blockingReceipt.gateReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.queueDepthAfter,
        3
    )
    @Assert(blockingReceipt.runtimeDefaultPathMutationDryRunRecorded, true)
}

func runTestRuntimeDefaultPathMutationApplyGateBlocksRejectedDryRun(): Unit {
    let rejectedGate = buildIgniteRuntimeDefaultPathMutationGateReceipt(
        buildIgniteControlledDefaultEngineMutationApplyReceipt(
            buildIgniteDefaultEngineMutationApplyGateReceipt(
                buildIgniteDefaultEngineMutationDryRunReceipt(
                    defaultEngineMutationCommitPlanReceiptFor("short-handler"),
                    IgniteDefaultEngineMutationDryRunRequest(
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
                        false,
                        false,
                        false,
                        false,
                        false,
                        false,
                        false
                    )
                ),
                acceptedDefaultEngineMutationApplyGateRequest()
            ),
            acceptedControlledDefaultEngineMutationApplyRequest()
        ),
        acceptedRuntimeDefaultPathMutationGateRequest()
    )
    let rejectedDryRun = buildIgniteRuntimeDefaultPathMutationDryRunReceipt(
        rejectedGate,
        acceptedRuntimeDefaultPathMutationDryRunRequest()
    )
    let receipt = buildIgniteRuntimeDefaultPathMutationApplyGateReceipt(
        rejectedDryRun,
        acceptedRuntimeDefaultPathMutationApplyGateRequest()
    )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-dry-run-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(receipt.runtimeDefaultPathMutationApplyGateAccepted, false)
    @Assert(receipt.runtimeDefaultPathMutationDryRunAccepted, false)
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_DRY_RUN_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationApplyGateRefusesRuntimeMutation(): Unit {
    let receipt = buildIgniteRuntimeDefaultPathMutationApplyGateReceipt(
        runtimeDefaultPathMutationDryRunReceiptFor("short-handler"),
        IgniteRuntimeDefaultPathMutationApplyGateRequest(
            "runtime-default-path-mutation-apply-gate-2",
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
            true,
            true,
            true,
            true,
            true,
            true
        )
    )

    @Assert(receipt.status, "blocked-runtime-default-path-mutation-apply-gate-input")
    @Assert(receipt.action, "block")
    @Assert(receipt.runtimeDefaultPathMutationApplyGateAccepted, false)
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "ACTUAL_HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "ACTUAL_RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.blockers[7], "ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    @Assert(receipt.blockers[8], "DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    @Assert(receipt.blockers[9], "RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    @Assert(receipt.blockers[10], "PUBLIC_RELEASE_REQUESTED")
    @Assert(receipt.blockers[11], "STDX_REMOVAL_REQUESTED")
    @Assert(receipt.blockers[12], "H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    @Assert(receipt.actualDefaultEngineFlipAllowed, false)
    @Assert(receipt.defaultEngineConfigMutationAllowed, false)
    @Assert(receipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(receipt.publicReleaseAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestRuntimeDefaultPathMutationApplyGateBlocksMissingMarkers(): Unit {
    let receipt = buildIgniteRuntimeDefaultPathMutationApplyGateReceipt(
        runtimeDefaultPathMutationDryRunReceiptFor("long-handler"),
        IgniteRuntimeDefaultPathMutationApplyGateRequest(
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
            false,
            false,
            false,
            false,
            false,
            false
        )
    )

    @Assert(receipt.status, "blocked-runtime-default-path-mutation-apply-gate-input")
    @Assert(receipt.runtimeDefaultPathMutationApplyGateAccepted, false)
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_GATE_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_DRY_RUN_RECEIPT_NOT_CARRIED"
    )
    @Assert(receipt.blockers[2], "TARGET_RUNTIME_DEFAULT_PATH_NOT_CARRIED")
    @Assert(receipt.blockers[3], "APPLY_GATE_PRECONDITION_NOT_CARRIED")
    @Assert(receipt.blockers[4], "DEFAULT_ENGINE_MUTATION_LOCK_NOT_CARRIED")
    @Assert(receipt.blockers[5], "CONFIG_MUTATION_LOCK_NOT_CARRIED")
    @Assert(receipt.blockers[6], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[7], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[8], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.runtimeDefaultPathMutationApplyGateRecorded, false)
}

func runTestRuntimeDefaultPathMutationApplyGateMapsLaneModes(): Unit {
    let shortReceipt = buildIgniteRuntimeDefaultPathMutationApplyGateReceipt(
        runtimeDefaultPathMutationDryRunReceiptFor("short-handler"),
        acceptedRuntimeDefaultPathMutationApplyGateRequest()
    )
    let longReceipt = buildIgniteRuntimeDefaultPathMutationApplyGateReceipt(
        runtimeDefaultPathMutationDryRunReceiptFor("long-handler"),
        acceptedRuntimeDefaultPathMutationApplyGateRequest()
    )
    let blockingReceipt = buildIgniteRuntimeDefaultPathMutationApplyGateReceipt(
        runtimeDefaultPathMutationDryRunReceiptFor("blocking-external-operation"),
        acceptedRuntimeDefaultPathMutationApplyGateRequest()
    )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-apply-gate-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationApplyGateMode,
        "short-runtime-default-path-mutation-apply-gate"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationApplyGateMode,
        "long-runtime-default-path-mutation-apply-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyGateMode,
        "blocking-isolation-runtime-default-path-mutation-apply-gate"
    )
    @Assert(blockingReceipt.runtimeDefaultPathMutationApplyGateAccepted, true)
    @Assert(blockingReceipt.runtimeDefaultPathMutationApplyGateAllowed, true)
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.dryRunReceipt.gateReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.queueDepthBefore,
        2
    )
    @Assert(
        blockingReceipt.dryRunReceipt.gateReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.queueDepthAfter,
        3
    )
    @Assert(blockingReceipt.runtimeDefaultPathMutationApplyGateRecorded, true)
}

func runTestControlledRuntimeDefaultPathMutationApplyBlocksRejectedApplyGate(): Unit {
    let rejectedGate = buildIgniteRuntimeDefaultPathMutationGateReceipt(
        buildIgniteControlledDefaultEngineMutationApplyReceipt(
            buildIgniteDefaultEngineMutationApplyGateReceipt(
                buildIgniteDefaultEngineMutationDryRunReceipt(
                    defaultEngineMutationCommitPlanReceiptFor("short-handler"),
                    IgniteDefaultEngineMutationDryRunRequest(
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
                        false,
                        false,
                        false,
                        false,
                        false,
                        false,
                        false
                    )
                ),
                acceptedDefaultEngineMutationApplyGateRequest()
            ),
            acceptedControlledDefaultEngineMutationApplyRequest()
        ),
        acceptedRuntimeDefaultPathMutationGateRequest()
    )
    let rejectedDryRun = buildIgniteRuntimeDefaultPathMutationDryRunReceipt(
        rejectedGate,
        acceptedRuntimeDefaultPathMutationDryRunRequest()
    )
    let rejectedApplyGate =
        buildIgniteRuntimeDefaultPathMutationApplyGateReceipt(
            rejectedDryRun,
            acceptedRuntimeDefaultPathMutationApplyGateRequest()
        )
    let receipt = buildIgniteControlledRuntimeDefaultPathMutationApplyReceipt(
        rejectedApplyGate,
        acceptedControlledRuntimeDefaultPathMutationApplyRequest()
    )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-apply-gate-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationApplyAccepted,
        false
    )
    @Assert(receipt.runtimeDefaultPathMutationApplyGateAccepted, false)
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_GATE_NOT_ACCEPTED"
    )
}

func runTestControlledRuntimeDefaultPathMutationApplyRefusesRuntimeMutation(): Unit {
    let receipt = buildIgniteControlledRuntimeDefaultPathMutationApplyReceipt(
        runtimeDefaultPathMutationApplyGateReceiptFor("short-handler"),
        IgniteControlledRuntimeDefaultPathMutationApplyRequest(
            "controlled-runtime-default-path-mutation-apply-2",
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
            true,
            true,
            true,
            true,
            true
        )
    )

    @Assert(
        receipt.status,
        "blocked-controlled-runtime-default-path-mutation-apply-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationApplyAccepted,
        false
    )
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "ACTUAL_HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "ACTUAL_RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.blockers[7], "ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    @Assert(receipt.blockers[8], "DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    @Assert(receipt.blockers[9], "RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    @Assert(receipt.blockers[10], "PUBLIC_RELEASE_REQUESTED")
    @Assert(receipt.blockers[11], "STDX_REMOVAL_REQUESTED")
    @Assert(receipt.blockers[12], "H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    @Assert(receipt.actualDefaultEngineFlipAllowed, false)
    @Assert(receipt.defaultEngineConfigMutationAllowed, false)
    @Assert(receipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(receipt.publicReleaseAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestControlledRuntimeDefaultPathMutationApplyBlocksMissingMarkers(): Unit {
    let receipt = buildIgniteControlledRuntimeDefaultPathMutationApplyReceipt(
        runtimeDefaultPathMutationApplyGateReceiptFor("long-handler"),
        IgniteControlledRuntimeDefaultPathMutationApplyRequest(
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
            false,
            false,
            false,
            false,
            false
        )
    )

    @Assert(
        receipt.status,
        "blocked-controlled-runtime-default-path-mutation-apply-input"
    )
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationApplyAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_GATE_RECEIPT_NOT_CARRIED"
    )
    @Assert(receipt.blockers[2], "CONTROLLED_APPLY_SCOPE_NOT_CARRIED")
    @Assert(receipt.blockers[3], "DEFAULT_ENGINE_MUTATION_LOCK_NOT_CARRIED")
    @Assert(
        receipt.blockers[4],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(receipt.blockers[5], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.controlledRuntimeDefaultPathMutationApplyRecorded, false)
}

func runTestControlledRuntimeDefaultPathMutationApplyMapsLaneModes(): Unit {
    let shortReceipt = buildIgniteControlledRuntimeDefaultPathMutationApplyReceipt(
        runtimeDefaultPathMutationApplyGateReceiptFor("short-handler"),
        acceptedControlledRuntimeDefaultPathMutationApplyRequest()
    )
    let longReceipt = buildIgniteControlledRuntimeDefaultPathMutationApplyReceipt(
        runtimeDefaultPathMutationApplyGateReceiptFor("long-handler"),
        acceptedControlledRuntimeDefaultPathMutationApplyRequest()
    )
    let blockingReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationApplyReceipt(
            runtimeDefaultPathMutationApplyGateReceiptFor(
                "blocking-external-operation"
            ),
            acceptedControlledRuntimeDefaultPathMutationApplyRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-controlled-runtime-default-path-mutation-apply-receipt"
    )
    @Assert(
        shortReceipt.controlledRuntimeDefaultPathMutationApplyMode,
        "short-controlled-runtime-default-path-mutation-apply"
    )
    @Assert(
        longReceipt.controlledRuntimeDefaultPathMutationApplyMode,
        "long-controlled-runtime-default-path-mutation-apply"
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationApplyMode,
        "blocking-isolation-controlled-runtime-default-path-mutation-apply"
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationApplyAccepted,
        true
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationApplyAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.applyGateReceipt.dryRunReceipt.gateReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.queueDepthBefore,
        2
    )
    @Assert(
        blockingReceipt.applyGateReceipt.dryRunReceipt.gateReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.queueDepthAfter,
        3
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationApplyRecorded,
        true
    )
}

func runTestRuntimeDefaultPathMutationCommitPlanBlocksRejectedControlledApply(): Unit {
    let rejectedGate = buildIgniteRuntimeDefaultPathMutationGateReceipt(
        buildIgniteControlledDefaultEngineMutationApplyReceipt(
            buildIgniteDefaultEngineMutationApplyGateReceipt(
                buildIgniteDefaultEngineMutationDryRunReceipt(
                    defaultEngineMutationCommitPlanReceiptFor("short-handler"),
                    IgniteDefaultEngineMutationDryRunRequest(
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
                        false,
                        false,
                        false,
                        false,
                        false,
                        false,
                        false
                    )
                ),
                acceptedDefaultEngineMutationApplyGateRequest()
            ),
            acceptedControlledDefaultEngineMutationApplyRequest()
        ),
        acceptedRuntimeDefaultPathMutationGateRequest()
    )
    let rejectedDryRun = buildIgniteRuntimeDefaultPathMutationDryRunReceipt(
        rejectedGate,
        acceptedRuntimeDefaultPathMutationDryRunRequest()
    )
    let rejectedApplyGate =
        buildIgniteRuntimeDefaultPathMutationApplyGateReceipt(
            rejectedDryRun,
            acceptedRuntimeDefaultPathMutationApplyGateRequest()
        )
    let rejectedControlledApply =
        buildIgniteControlledRuntimeDefaultPathMutationApplyReceipt(
            rejectedApplyGate,
            acceptedControlledRuntimeDefaultPathMutationApplyRequest()
        )
    let receipt = buildIgniteRuntimeDefaultPathMutationCommitPlanReceipt(
        rejectedControlledApply,
        acceptedRuntimeDefaultPathMutationCommitPlanRequest()
    )

    @Assert(
        receipt.status,
        "blocked-controlled-runtime-default-path-mutation-apply-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(receipt.runtimeDefaultPathMutationCommitPlanAccepted, false)
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationApplyAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationCommitPlanRefusesRuntimeMutation(): Unit {
    let receipt = buildIgniteRuntimeDefaultPathMutationCommitPlanReceipt(
        controlledRuntimeDefaultPathMutationApplyReceiptFor("short-handler"),
        IgniteRuntimeDefaultPathMutationCommitPlanRequest(
            "runtime-default-path-mutation-commit-plan-2",
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
            true,
            true,
            true,
            true,
            true
        )
    )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-commit-plan-input"
    )
    @Assert(receipt.action, "block")
    @Assert(receipt.runtimeDefaultPathMutationCommitPlanAccepted, false)
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "ACTUAL_HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "ACTUAL_RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.blockers[7], "ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    @Assert(receipt.blockers[8], "DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    @Assert(receipt.blockers[9], "RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    @Assert(receipt.blockers[10], "PUBLIC_RELEASE_REQUESTED")
    @Assert(receipt.blockers[11], "STDX_REMOVAL_REQUESTED")
    @Assert(receipt.blockers[12], "H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    @Assert(receipt.actualDefaultEngineFlipAllowed, false)
    @Assert(receipt.defaultEngineConfigMutationAllowed, false)
    @Assert(receipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(receipt.publicReleaseAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestRuntimeDefaultPathMutationCommitPlanBlocksMissingMarkers(): Unit {
    let receipt = buildIgniteRuntimeDefaultPathMutationCommitPlanReceipt(
        controlledRuntimeDefaultPathMutationApplyReceiptFor("long-handler"),
        IgniteRuntimeDefaultPathMutationCommitPlanRequest(
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
            false,
            false,
            false,
            false,
            false
        )
    )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-commit-plan-input"
    )
    @Assert(receipt.runtimeDefaultPathMutationCommitPlanAccepted, false)
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_PLAN_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_SNAPSHOT_NOT_CARRIED"
    )
    @Assert(receipt.blockers[2], "TARGET_RUNTIME_DEFAULT_PATH_NOT_CARRIED")
    @Assert(receipt.blockers[3], "MUTATION_PLAN_ID_NOT_CARRIED")
    @Assert(receipt.blockers[4], "ATOMIC_SWITCH_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[5], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.runtimeDefaultPathMutationCommitPlanRecorded, false)
}

func runTestRuntimeDefaultPathMutationCommitPlanMapsLaneModes(): Unit {
    let shortReceipt = buildIgniteRuntimeDefaultPathMutationCommitPlanReceipt(
        controlledRuntimeDefaultPathMutationApplyReceiptFor("short-handler"),
        acceptedRuntimeDefaultPathMutationCommitPlanRequest()
    )
    let longReceipt = buildIgniteRuntimeDefaultPathMutationCommitPlanReceipt(
        controlledRuntimeDefaultPathMutationApplyReceiptFor("long-handler"),
        acceptedRuntimeDefaultPathMutationCommitPlanRequest()
    )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationCommitPlanReceipt(
            controlledRuntimeDefaultPathMutationApplyReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationCommitPlanRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-commit-plan-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationCommitPlanMode,
        "short-runtime-default-path-mutation-commit-plan"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationCommitPlanMode,
        "long-runtime-default-path-mutation-commit-plan"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationCommitPlanMode,
        "blocking-isolation-runtime-default-path-mutation-commit-plan"
    )
    @Assert(blockingReceipt.runtimeDefaultPathMutationCommitPlanAccepted, true)
    @Assert(blockingReceipt.runtimeDefaultPathMutationCommitPlanAllowed, true)
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.gateReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.queueDepthBefore,
        2
    )
    @Assert(
        blockingReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.gateReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.queueDepthAfter,
        3
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationCommitPlanRecorded,
        true
    )
}

func runTestRuntimeDefaultPathMutationCommitDryRunBlocksRejectedCommitPlan(): Unit {
    let rejectedCommitPlan =
        buildIgniteRuntimeDefaultPathMutationCommitPlanReceipt(
            controlledRuntimeDefaultPathMutationApplyReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationCommitPlanRequest(
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
                false,
                false,
                false,
                false,
                false
            )
        )
    let receipt = buildIgniteRuntimeDefaultPathMutationCommitDryRunReceipt(
        rejectedCommitPlan,
        acceptedRuntimeDefaultPathMutationCommitDryRunRequest()
    )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-commit-plan-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationCommitDryRunAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationCommitPlanAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_PLAN_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationCommitDryRunRefusesRuntimeMutation(): Unit {
    let receipt = buildIgniteRuntimeDefaultPathMutationCommitDryRunReceipt(
        runtimeDefaultPathMutationCommitPlanReceiptFor("short-handler"),
        IgniteRuntimeDefaultPathMutationCommitDryRunRequest(
            "runtime-default-path-mutation-commit-dry-run-2",
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
        "blocked-runtime-default-path-mutation-commit-dry-run-input"
    )
    @Assert(receipt.action, "block")
    @Assert(receipt.runtimeDefaultPathMutationCommitDryRunAccepted, false)
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "ACTUAL_HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "ACTUAL_RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.blockers[7], "ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    @Assert(receipt.blockers[8], "DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    @Assert(receipt.blockers[9], "RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    @Assert(receipt.blockers[10], "PUBLIC_RELEASE_REQUESTED")
    @Assert(receipt.blockers[11], "STDX_REMOVAL_REQUESTED")
    @Assert(receipt.blockers[12], "H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    @Assert(receipt.actualDefaultEngineFlipAllowed, false)
    @Assert(receipt.defaultEngineConfigMutationAllowed, false)
    @Assert(receipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(receipt.publicReleaseAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestRuntimeDefaultPathMutationCommitDryRunBlocksMissingMarkers(): Unit {
    let receipt = buildIgniteRuntimeDefaultPathMutationCommitDryRunReceipt(
        runtimeDefaultPathMutationCommitPlanReceiptFor("long-handler"),
        IgniteRuntimeDefaultPathMutationCommitDryRunRequest(
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
            false,
            false,
            false,
            false,
            false,
            false
        )
    )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-commit-dry-run-input"
    )
    @Assert(receipt.runtimeDefaultPathMutationCommitDryRunAccepted, false)
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_DRY_RUN_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_PLAN_SNAPSHOT_NOT_CARRIED"
    )
    @Assert(receipt.blockers[2], "TARGET_RUNTIME_DEFAULT_PATH_NOT_CARRIED")
    @Assert(receipt.blockers[3], "ISOLATED_MUTATION_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[4], "DRY_RUN_SANDBOX_NOT_CARRIED")
    @Assert(receipt.blockers[5], "CONFIG_DIFF_PREVIEW_NOT_CARRIED")
    @Assert(receipt.blockers[6], "ROLLBACK_SIMULATION_NOT_CARRIED")
    @Assert(receipt.blockers[7], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[8], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(
        receipt.runtimeDefaultPathMutationCommitDryRunRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationCommitDryRunMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationCommitDryRunReceipt(
            runtimeDefaultPathMutationCommitPlanReceiptFor("short-handler"),
            acceptedRuntimeDefaultPathMutationCommitDryRunRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationCommitDryRunReceipt(
            runtimeDefaultPathMutationCommitPlanReceiptFor("long-handler"),
            acceptedRuntimeDefaultPathMutationCommitDryRunRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationCommitDryRunReceipt(
            runtimeDefaultPathMutationCommitPlanReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationCommitDryRunRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-commit-dry-run-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationCommitDryRunMode,
        "short-runtime-default-path-mutation-commit-dry-run"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationCommitDryRunMode,
        "long-runtime-default-path-mutation-commit-dry-run"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationCommitDryRunMode,
        "blocking-isolation-runtime-default-path-mutation-commit-dry-run"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationCommitDryRunAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationCommitDryRunAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.commitPlanReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.gateReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.queueDepthBefore,
        2
    )
    @Assert(
        blockingReceipt.commitPlanReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.gateReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.queueDepthAfter,
        3
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationCommitDryRunRecorded,
        true
    )
}

func runTestRuntimeDefaultPathMutationCommitApplyGateBlocksRejectedDryRun(): Unit {
    let rejectedCommitPlan =
        buildIgniteRuntimeDefaultPathMutationCommitPlanReceipt(
            controlledRuntimeDefaultPathMutationApplyReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationCommitPlanRequest(
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
                false,
                false,
                false,
                false,
                false
            )
        )
    let rejectedDryRun =
        buildIgniteRuntimeDefaultPathMutationCommitDryRunReceipt(
            rejectedCommitPlan,
            acceptedRuntimeDefaultPathMutationCommitDryRunRequest()
        )
    let receipt = buildIgniteRuntimeDefaultPathMutationCommitApplyGateReceipt(
        rejectedDryRun,
        acceptedRuntimeDefaultPathMutationCommitApplyGateRequest()
    )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-commit-dry-run-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationCommitApplyGateAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationCommitDryRunAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_DRY_RUN_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationCommitApplyGateRefusesRuntimeMutation(): Unit {
    let receipt = buildIgniteRuntimeDefaultPathMutationCommitApplyGateReceipt(
        runtimeDefaultPathMutationCommitDryRunReceiptFor("short-handler"),
        IgniteRuntimeDefaultPathMutationCommitApplyGateRequest(
            "runtime-default-path-mutation-commit-apply-gate-2",
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
            true,
            true,
            true,
            true,
            true
        )
    )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-commit-apply-gate-input"
    )
    @Assert(receipt.action, "block")
    @Assert(receipt.runtimeDefaultPathMutationCommitApplyGateAccepted, false)
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "ACTUAL_HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "ACTUAL_RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.blockers[7], "ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    @Assert(receipt.blockers[8], "DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    @Assert(receipt.blockers[9], "RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    @Assert(receipt.blockers[10], "PUBLIC_RELEASE_REQUESTED")
    @Assert(receipt.blockers[11], "STDX_REMOVAL_REQUESTED")
    @Assert(receipt.blockers[12], "H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    @Assert(receipt.actualDefaultEngineFlipAllowed, false)
    @Assert(receipt.defaultEngineConfigMutationAllowed, false)
    @Assert(receipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(receipt.publicReleaseAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestRuntimeDefaultPathMutationCommitApplyGateBlocksMissingMarkers(): Unit {
    let receipt = buildIgniteRuntimeDefaultPathMutationCommitApplyGateReceipt(
        runtimeDefaultPathMutationCommitDryRunReceiptFor("long-handler"),
        IgniteRuntimeDefaultPathMutationCommitApplyGateRequest(
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
            false,
            false,
            false,
            false,
            false
        )
    )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-commit-apply-gate-input"
    )
    @Assert(receipt.runtimeDefaultPathMutationCommitApplyGateAccepted, false)
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_APPLY_GATE_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_DRY_RUN_SNAPSHOT_NOT_CARRIED"
    )
    @Assert(receipt.blockers[2], "TARGET_RUNTIME_DEFAULT_PATH_NOT_CARRIED")
    @Assert(receipt.blockers[3], "APPLY_PRECONDITION_GATE_NOT_CARRIED")
    @Assert(
        receipt.blockers[4],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(receipt.blockers[5], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(
        receipt.runtimeDefaultPathMutationCommitApplyGateRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationCommitApplyGateMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationCommitApplyGateReceipt(
            runtimeDefaultPathMutationCommitDryRunReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationCommitApplyGateRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationCommitApplyGateReceipt(
            runtimeDefaultPathMutationCommitDryRunReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationCommitApplyGateRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationCommitApplyGateReceipt(
            runtimeDefaultPathMutationCommitDryRunReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationCommitApplyGateRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-commit-apply-gate-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationCommitApplyGateMode,
        "short-runtime-default-path-mutation-commit-apply-gate"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationCommitApplyGateMode,
        "long-runtime-default-path-mutation-commit-apply-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationCommitApplyGateMode,
        "blocking-isolation-runtime-default-path-mutation-commit-apply-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationCommitApplyGateAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationCommitApplyGateAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.dryRunReceipt.commitPlanReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.gateReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.queueDepthBefore,
        2
    )
    @Assert(
        blockingReceipt.dryRunReceipt.commitPlanReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.gateReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.queueDepthAfter,
        3
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationCommitApplyGateRecorded,
        true
    )
}

func runTestControlledRuntimeDefaultPathMutationCommitApplyBlocksRejectedApplyGate(): Unit {
    let rejectedCommitPlan =
        buildIgniteRuntimeDefaultPathMutationCommitPlanReceipt(
            controlledRuntimeDefaultPathMutationApplyReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationCommitPlanRequest(
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
                false,
                false,
                false,
                false,
                false
            )
        )
    let rejectedDryRun =
        buildIgniteRuntimeDefaultPathMutationCommitDryRunReceipt(
            rejectedCommitPlan,
            acceptedRuntimeDefaultPathMutationCommitDryRunRequest()
        )
    let rejectedApplyGate =
        buildIgniteRuntimeDefaultPathMutationCommitApplyGateReceipt(
            rejectedDryRun,
            acceptedRuntimeDefaultPathMutationCommitApplyGateRequest()
        )
    let receipt =
        buildIgniteControlledRuntimeDefaultPathMutationCommitApplyReceipt(
            rejectedApplyGate,
            acceptedControlledRuntimeDefaultPathMutationCommitApplyRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-commit-apply-gate-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationCommitApplyAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationCommitApplyGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_APPLY_GATE_NOT_ACCEPTED"
    )
}

func runTestControlledRuntimeDefaultPathMutationCommitApplyRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteControlledRuntimeDefaultPathMutationCommitApplyReceipt(
            runtimeDefaultPathMutationCommitApplyGateReceiptFor(
                "short-handler"
            ),
            IgniteControlledRuntimeDefaultPathMutationCommitApplyRequest(
                "controlled-runtime-default-path-mutation-commit-apply-2",
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
                true,
                true,
                true,
                true
            )
        )

    @Assert(
        receipt.status,
        "blocked-controlled-runtime-default-path-mutation-commit-apply-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationCommitApplyAccepted,
        false
    )
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "ACTUAL_HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "ACTUAL_RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.blockers[7], "ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    @Assert(receipt.blockers[8], "DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    @Assert(receipt.blockers[9], "RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    @Assert(receipt.blockers[10], "PUBLIC_RELEASE_REQUESTED")
    @Assert(receipt.blockers[11], "STDX_REMOVAL_REQUESTED")
    @Assert(receipt.blockers[12], "H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    @Assert(receipt.actualDefaultEngineFlipAllowed, false)
    @Assert(receipt.defaultEngineConfigMutationAllowed, false)
    @Assert(receipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(receipt.publicReleaseAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestControlledRuntimeDefaultPathMutationCommitApplyBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteControlledRuntimeDefaultPathMutationCommitApplyReceipt(
            runtimeDefaultPathMutationCommitApplyGateReceiptFor(
                "long-handler"
            ),
            IgniteControlledRuntimeDefaultPathMutationCommitApplyRequest(
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
                false,
                false,
                false,
                false
            )
        )

    @Assert(
        receipt.status,
        "blocked-controlled-runtime-default-path-mutation-commit-apply-input"
    )
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationCommitApplyAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_APPLY_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_APPLY_GATE_SNAPSHOT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(receipt.blockers[3], "MUTATION_COMMIT_BOUNDARY_NOT_CARRIED")
    @Assert(receipt.blockers[4], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[5], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[6], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationCommitApplyRecorded,
        false
    )
}

func runTestControlledRuntimeDefaultPathMutationCommitApplyMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationCommitApplyReceipt(
            runtimeDefaultPathMutationCommitApplyGateReceiptFor(
                "short-handler"
            ),
            acceptedControlledRuntimeDefaultPathMutationCommitApplyRequest()
        )
    let longReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationCommitApplyReceipt(
            runtimeDefaultPathMutationCommitApplyGateReceiptFor(
                "long-handler"
            ),
            acceptedControlledRuntimeDefaultPathMutationCommitApplyRequest()
        )
    let blockingReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationCommitApplyReceipt(
            runtimeDefaultPathMutationCommitApplyGateReceiptFor(
                "blocking-external-operation"
            ),
            acceptedControlledRuntimeDefaultPathMutationCommitApplyRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-controlled-runtime-default-path-mutation-commit-apply-receipt"
    )
    @Assert(
        shortReceipt.controlledRuntimeDefaultPathMutationCommitApplyMode,
        "short-controlled-runtime-default-path-mutation-commit-apply"
    )
    @Assert(
        longReceipt.controlledRuntimeDefaultPathMutationCommitApplyMode,
        "long-controlled-runtime-default-path-mutation-commit-apply"
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationCommitApplyMode,
        "blocking-isolation-controlled-runtime-default-path-mutation-commit-apply"
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationCommitApplyAccepted,
        true
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationCommitApplyAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.gateReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.queueDepthBefore,
        2
    )
    @Assert(
        blockingReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.gateReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.queueDepthAfter,
        3
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationCommitApplyRecorded,
        true
    )
}

func runTestRuntimeDefaultPathMutationCommitBoundaryBlocksRejectedControlledApply(): Unit {
    let rejectedCommitPlan =
        buildIgniteRuntimeDefaultPathMutationCommitPlanReceipt(
            controlledRuntimeDefaultPathMutationApplyReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationCommitPlanRequest(
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
                false,
                false,
                false,
                false,
                false
            )
        )
    let rejectedDryRun =
        buildIgniteRuntimeDefaultPathMutationCommitDryRunReceipt(
            rejectedCommitPlan,
            acceptedRuntimeDefaultPathMutationCommitDryRunRequest()
        )
    let rejectedApplyGate =
        buildIgniteRuntimeDefaultPathMutationCommitApplyGateReceipt(
            rejectedDryRun,
            acceptedRuntimeDefaultPathMutationCommitApplyGateRequest()
        )
    let rejectedControlledApply =
        buildIgniteControlledRuntimeDefaultPathMutationCommitApplyReceipt(
            rejectedApplyGate,
            acceptedControlledRuntimeDefaultPathMutationCommitApplyRequest()
        )
    let receipt =
        buildIgniteRuntimeDefaultPathMutationCommitBoundaryReceipt(
            rejectedControlledApply,
            acceptedRuntimeDefaultPathMutationCommitBoundaryRequest()
        )

    @Assert(
        receipt.status,
        "blocked-controlled-runtime-default-path-mutation-commit-apply-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationCommitBoundaryAccepted,
        false
    )
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationCommitApplyAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_APPLY_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationCommitBoundaryRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationCommitBoundaryReceipt(
            controlledRuntimeDefaultPathMutationCommitApplyReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationCommitBoundaryRequest(
                "runtime-default-path-mutation-commit-boundary-2",
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
                true,
                true,
                true,
                true
            )
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-commit-boundary-input"
    )
    @Assert(receipt.action, "block")
    @Assert(receipt.runtimeDefaultPathMutationCommitBoundaryAccepted, false)
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "ACTUAL_HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "ACTUAL_RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.blockers[7], "ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    @Assert(receipt.blockers[8], "DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    @Assert(receipt.blockers[9], "RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    @Assert(receipt.blockers[10], "PUBLIC_RELEASE_REQUESTED")
    @Assert(receipt.blockers[11], "STDX_REMOVAL_REQUESTED")
    @Assert(receipt.blockers[12], "H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    @Assert(receipt.actualDefaultEngineFlipAllowed, false)
    @Assert(receipt.defaultEngineConfigMutationAllowed, false)
    @Assert(receipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(receipt.publicReleaseAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestRuntimeDefaultPathMutationCommitBoundaryBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationCommitBoundaryReceipt(
            controlledRuntimeDefaultPathMutationCommitApplyReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationCommitBoundaryRequest(
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
                false,
                false,
                false,
                false
            )
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-commit-boundary-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationCommitBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_BOUNDARY_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_APPLY_SNAPSHOT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(receipt.blockers[3], "COMMIT_BOUNDARY_SNAPSHOT_NOT_CARRIED")
    @Assert(receipt.blockers[4], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[5], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[6], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(
        receipt.runtimeDefaultPathMutationCommitBoundaryRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationCommitBoundaryMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationCommitBoundaryReceipt(
            controlledRuntimeDefaultPathMutationCommitApplyReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationCommitBoundaryRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationCommitBoundaryReceipt(
            controlledRuntimeDefaultPathMutationCommitApplyReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationCommitBoundaryRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationCommitBoundaryReceipt(
            controlledRuntimeDefaultPathMutationCommitApplyReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationCommitBoundaryRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-commit-boundary-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationCommitBoundaryMode,
        "short-runtime-default-path-mutation-commit-boundary"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationCommitBoundaryMode,
        "long-runtime-default-path-mutation-commit-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationCommitBoundaryMode,
        "blocking-isolation-runtime-default-path-mutation-commit-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationCommitBoundaryAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationCommitBoundaryAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.controlledCommitApplyReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.gateReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.queueDepthBefore,
        2
    )
    @Assert(
        blockingReceipt.controlledCommitApplyReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.gateReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.queueDepthAfter,
        3
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationCommitBoundaryRecorded,
        true
    )
}

func runTestRuntimeDefaultPathMutationFinalizationGateBlocksRejectedCommitBoundary(): Unit {
    let rejectedBoundary =
        buildIgniteRuntimeDefaultPathMutationCommitBoundaryReceipt(
            controlledRuntimeDefaultPathMutationCommitApplyReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationCommitBoundaryRequest(
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
                false,
                false,
                false,
                false
            )
        )
    let receipt =
        buildIgniteRuntimeDefaultPathMutationFinalizationGateReceipt(
            rejectedBoundary,
            acceptedRuntimeDefaultPathMutationFinalizationGateRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-commit-boundary-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationFinalizationGateAccepted,
        false
    )
    @Assert(receipt.runtimeDefaultPathMutationCommitBoundaryAccepted, false)
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_BOUNDARY_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationFinalizationGateRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationFinalizationGateReceipt(
            runtimeDefaultPathMutationCommitBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationFinalizationGateRequest(
                "runtime-default-path-mutation-finalization-gate-2",
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
                true,
                true,
                true,
                true
            )
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-finalization-gate-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationFinalizationGateAccepted,
        false
    )
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "ACTUAL_HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "ACTUAL_RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.blockers[7], "ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    @Assert(receipt.blockers[8], "DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    @Assert(receipt.blockers[9], "RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    @Assert(receipt.blockers[10], "PUBLIC_RELEASE_REQUESTED")
    @Assert(receipt.blockers[11], "STDX_REMOVAL_REQUESTED")
    @Assert(receipt.blockers[12], "H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    @Assert(receipt.actualDefaultEngineFlipAllowed, false)
    @Assert(receipt.defaultEngineConfigMutationAllowed, false)
    @Assert(receipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(receipt.publicReleaseAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestRuntimeDefaultPathMutationFinalizationGateBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationFinalizationGateReceipt(
            runtimeDefaultPathMutationCommitBoundaryReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationFinalizationGateRequest(
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
                false,
                false,
                false,
                false
            )
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-finalization-gate-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationFinalizationGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_FINALIZATION_GATE_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_BOUNDARY_SNAPSHOT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(receipt.blockers[3], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[4], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[5], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "FINALIZATION_AUDIT_MARKER_NOT_CARRIED")
    @Assert(
        receipt.runtimeDefaultPathMutationFinalizationGateRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationFinalizationGateMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationFinalizationGateReceipt(
            runtimeDefaultPathMutationCommitBoundaryReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationFinalizationGateRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationFinalizationGateReceipt(
            runtimeDefaultPathMutationCommitBoundaryReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationFinalizationGateRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationFinalizationGateReceipt(
            runtimeDefaultPathMutationCommitBoundaryReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationFinalizationGateRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-finalization-gate-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationFinalizationGateMode,
        "short-runtime-default-path-mutation-finalization-gate"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationFinalizationGateMode,
        "long-runtime-default-path-mutation-finalization-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationFinalizationGateMode,
        "blocking-isolation-runtime-default-path-mutation-finalization-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationFinalizationGateAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationFinalizationGateAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.commitBoundaryReceipt.controlledCommitApplyReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.gateReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.queueDepthBefore,
        2
    )
    @Assert(
        blockingReceipt.commitBoundaryReceipt.controlledCommitApplyReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.gateReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.queueDepthAfter,
        3
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationFinalizationGateRecorded,
        true
    )
}

func runTestControlledRuntimeDefaultPathMutationFinalizationApplyBlocksRejectedFinalizationGate(): Unit {
    let rejectedBoundary =
        buildIgniteRuntimeDefaultPathMutationCommitBoundaryReceipt(
            controlledRuntimeDefaultPathMutationCommitApplyReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationCommitBoundaryRequest(
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
                false,
                false,
                false,
                false
            )
        )
    let rejectedFinalizationGate =
        buildIgniteRuntimeDefaultPathMutationFinalizationGateReceipt(
            rejectedBoundary,
            acceptedRuntimeDefaultPathMutationFinalizationGateRequest()
        )
    let receipt =
        buildIgniteControlledRuntimeDefaultPathMutationFinalizationApplyReceipt(
            rejectedFinalizationGate,
            acceptedControlledRuntimeDefaultPathMutationFinalizationApplyRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-finalization-gate-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationFinalizationApplyAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationFinalizationGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_FINALIZATION_GATE_NOT_ACCEPTED"
    )
}

func runTestControlledRuntimeDefaultPathMutationFinalizationApplyRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteControlledRuntimeDefaultPathMutationFinalizationApplyReceipt(
            runtimeDefaultPathMutationFinalizationGateReceiptFor(
                "short-handler"
            ),
            IgniteControlledRuntimeDefaultPathMutationFinalizationApplyRequest(
                "controlled-runtime-default-path-mutation-finalization-apply-2",
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
                true,
                true,
                true,
                true,
                true
            )
        )

    @Assert(
        receipt.status,
        "blocked-controlled-runtime-default-path-mutation-finalization-apply-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationFinalizationApplyAccepted,
        false
    )
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "ACTUAL_HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "ACTUAL_RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.blockers[7], "ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    @Assert(receipt.blockers[8], "DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    @Assert(receipt.blockers[9], "RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    @Assert(receipt.blockers[10], "PUBLIC_RELEASE_REQUESTED")
    @Assert(receipt.blockers[11], "STDX_REMOVAL_REQUESTED")
    @Assert(receipt.blockers[12], "H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    @Assert(receipt.actualDefaultEngineFlipAllowed, false)
    @Assert(receipt.defaultEngineConfigMutationAllowed, false)
    @Assert(receipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(receipt.publicReleaseAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestControlledRuntimeDefaultPathMutationFinalizationApplyBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteControlledRuntimeDefaultPathMutationFinalizationApplyReceipt(
            runtimeDefaultPathMutationFinalizationGateReceiptFor(
                "long-handler"
            ),
            IgniteControlledRuntimeDefaultPathMutationFinalizationApplyRequest(
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
                false,
                false,
                false,
                false,
                false
            )
        )

    @Assert(
        receipt.status,
        "blocked-controlled-runtime-default-path-mutation-finalization-apply-input"
    )
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationFinalizationApplyAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_FINALIZATION_APPLY_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_FINALIZATION_GATE_SNAPSHOT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(receipt.blockers[3], "FINALIZATION_APPLY_BOUNDARY_NOT_CARRIED")
    @Assert(receipt.blockers[4], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[5], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[6], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[7], "FINALIZATION_AUDIT_MARKER_NOT_CARRIED")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationFinalizationApplyRecorded,
        false
    )
}

func runTestControlledRuntimeDefaultPathMutationFinalizationApplyMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationFinalizationApplyReceipt(
            runtimeDefaultPathMutationFinalizationGateReceiptFor(
                "short-handler"
            ),
            acceptedControlledRuntimeDefaultPathMutationFinalizationApplyRequest()
        )
    let longReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationFinalizationApplyReceipt(
            runtimeDefaultPathMutationFinalizationGateReceiptFor(
                "long-handler"
            ),
            acceptedControlledRuntimeDefaultPathMutationFinalizationApplyRequest()
        )
    let blockingReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationFinalizationApplyReceipt(
            runtimeDefaultPathMutationFinalizationGateReceiptFor(
                "blocking-external-operation"
            ),
            acceptedControlledRuntimeDefaultPathMutationFinalizationApplyRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-controlled-runtime-default-path-mutation-finalization-apply-receipt"
    )
    @Assert(
        shortReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyMode,
        "short-controlled-runtime-default-path-mutation-finalization-apply"
    )
    @Assert(
        longReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyMode,
        "long-controlled-runtime-default-path-mutation-finalization-apply"
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyMode,
        "blocking-isolation-controlled-runtime-default-path-mutation-finalization-apply"
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyAccepted,
        true
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.finalizationGateReceipt.commitBoundaryReceipt.controlledCommitApplyReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.gateReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.queueDepthBefore,
        2
    )
    @Assert(
        blockingReceipt.finalizationGateReceipt.commitBoundaryReceipt.controlledCommitApplyReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.gateReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.queueDepthAfter,
        3
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyRecorded,
        true
    )
}

func runTestRuntimeDefaultPathMutationCloseoutGateBlocksRejectedControlledFinalizationApply(): Unit {
    let rejectedControlledFinalizationApply =
        buildIgniteControlledRuntimeDefaultPathMutationFinalizationApplyReceipt(
            runtimeDefaultPathMutationFinalizationGateReceiptFor(
                "short-handler"
            ),
            IgniteControlledRuntimeDefaultPathMutationFinalizationApplyRequest(
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
                false,
                false,
                false,
                false,
                false
            )
        )
    let receipt =
        buildIgniteRuntimeDefaultPathMutationCloseoutGateReceipt(
            rejectedControlledFinalizationApply,
            acceptedRuntimeDefaultPathMutationCloseoutGateRequest()
        )

    @Assert(
        receipt.status,
        "blocked-controlled-runtime-default-path-mutation-finalization-apply-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(receipt.runtimeDefaultPathMutationCloseoutGateAccepted, false)
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationFinalizationApplyAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_FINALIZATION_APPLY_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationCloseoutGateRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationCloseoutGateReceipt(
            controlledRuntimeDefaultPathMutationFinalizationApplyReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationCloseoutGateRequest(
                "runtime-default-path-mutation-closeout-gate-2",
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
        "blocked-runtime-default-path-mutation-closeout-gate-input"
    )
    @Assert(receipt.action, "block")
    @Assert(receipt.runtimeDefaultPathMutationCloseoutGateAccepted, false)
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "ACTUAL_HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "ACTUAL_RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.blockers[7], "ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    @Assert(receipt.blockers[8], "DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    @Assert(receipt.blockers[9], "RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    @Assert(receipt.blockers[10], "PUBLIC_RELEASE_REQUESTED")
    @Assert(receipt.blockers[11], "STDX_REMOVAL_REQUESTED")
    @Assert(receipt.blockers[12], "H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    @Assert(receipt.actualDefaultEngineFlipAllowed, false)
    @Assert(receipt.defaultEngineConfigMutationAllowed, false)
    @Assert(receipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(receipt.publicReleaseAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestRuntimeDefaultPathMutationCloseoutGateBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationCloseoutGateReceipt(
            controlledRuntimeDefaultPathMutationFinalizationApplyReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationCloseoutGateRequest(
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
                false,
                false,
                false,
                false,
                false,
                false
            )
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-closeout-gate-input"
    )
    @Assert(receipt.runtimeDefaultPathMutationCloseoutGateAccepted, false)
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_CLOSEOUT_GATE_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_FINALIZATION_APPLY_SNAPSHOT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(receipt.blockers[3], "CLOSEOUT_BOUNDARY_NOT_CARRIED")
    @Assert(receipt.blockers[4], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[5], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[6], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[7], "FINALIZATION_AUDIT_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "CLOSEOUT_AUDIT_MARKER_NOT_CARRIED")
    @Assert(receipt.runtimeDefaultPathMutationCloseoutGateRecorded, false)
}

func runTestRuntimeDefaultPathMutationCloseoutGateMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationCloseoutGateReceipt(
            controlledRuntimeDefaultPathMutationFinalizationApplyReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationCloseoutGateRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationCloseoutGateReceipt(
            controlledRuntimeDefaultPathMutationFinalizationApplyReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationCloseoutGateRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationCloseoutGateReceipt(
            controlledRuntimeDefaultPathMutationFinalizationApplyReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationCloseoutGateRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-closeout-gate-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationCloseoutGateMode,
        "short-runtime-default-path-mutation-closeout-gate"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationCloseoutGateMode,
        "long-runtime-default-path-mutation-closeout-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationCloseoutGateMode,
        "blocking-isolation-runtime-default-path-mutation-closeout-gate"
    )
    @Assert(blockingReceipt.runtimeDefaultPathMutationCloseoutGateAccepted, true)
    @Assert(blockingReceipt.runtimeDefaultPathMutationCloseoutGateAllowed, true)
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.controlledFinalizationApplyReceipt.finalizationGateReceipt.commitBoundaryReceipt.controlledCommitApplyReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.gateReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.queueDepthBefore,
        2
    )
    @Assert(
        blockingReceipt.controlledFinalizationApplyReceipt.finalizationGateReceipt.commitBoundaryReceipt.controlledCommitApplyReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.gateReceipt.controlledApplyReceipt.applyGateReceipt.dryRunReceipt.commitPlanReceipt.queueDepthAfter,
        3
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationCloseoutGateRecorded,
        true
    )
}

func runTestRuntimeDefaultPathMutationHandoffGateBlocksRejectedCloseoutGate(): Unit {
    let rejectedCloseoutGate =
        buildIgniteRuntimeDefaultPathMutationCloseoutGateReceipt(
            controlledRuntimeDefaultPathMutationFinalizationApplyReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationCloseoutGateRequest(
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
                false,
                false,
                false,
                false,
                false,
                false
            )
        )
    let receipt =
        buildIgniteRuntimeDefaultPathMutationHandoffGateReceipt(
            rejectedCloseoutGate,
            acceptedRuntimeDefaultPathMutationHandoffGateRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-closeout-gate-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(receipt.runtimeDefaultPathMutationHandoffGateAccepted, false)
    @Assert(receipt.runtimeDefaultPathMutationCloseoutGateAccepted, false)
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_CLOSEOUT_GATE_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationHandoffGateRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationHandoffGateReceipt(
            runtimeDefaultPathMutationCloseoutGateReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationHandoffGateRequest(
                "runtime-default-path-mutation-handoff-gate-2",
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
        "blocked-runtime-default-path-mutation-handoff-gate-input"
    )
    @Assert(receipt.action, "block")
    @Assert(receipt.runtimeDefaultPathMutationHandoffGateAccepted, false)
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "ACTUAL_HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "ACTUAL_RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.blockers[7], "ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    @Assert(receipt.blockers[8], "DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    @Assert(receipt.blockers[9], "RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    @Assert(receipt.blockers[10], "PUBLIC_RELEASE_REQUESTED")
    @Assert(receipt.blockers[11], "STDX_REMOVAL_REQUESTED")
    @Assert(receipt.blockers[12], "H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    @Assert(receipt.actualDefaultEngineFlipAllowed, false)
    @Assert(receipt.defaultEngineConfigMutationAllowed, false)
    @Assert(receipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(receipt.publicReleaseAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestRuntimeDefaultPathMutationHandoffGateBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationHandoffGateReceipt(
            runtimeDefaultPathMutationCloseoutGateReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationHandoffGateRequest(
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
                false,
                false,
                false,
                false,
                false,
                false
            )
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-handoff-gate-input"
    )
    @Assert(receipt.runtimeDefaultPathMutationHandoffGateAccepted, false)
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_HANDOFF_GATE_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_CLOSEOUT_GATE_RECEIPT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(receipt.blockers[3], "HANDOFF_BOUNDARY_NOT_CARRIED")
    @Assert(receipt.blockers[4], "DOWNSTREAM_CONSUMER_BOUNDARY_NOT_CARRIED")
    @Assert(receipt.blockers[5], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "HANDOFF_AUDIT_MARKER_NOT_CARRIED")
    @Assert(receipt.runtimeDefaultPathMutationHandoffGateRecorded, false)
}

func runTestRuntimeDefaultPathMutationHandoffGateMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationHandoffGateReceipt(
            runtimeDefaultPathMutationCloseoutGateReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationHandoffGateRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationHandoffGateReceipt(
            runtimeDefaultPathMutationCloseoutGateReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationHandoffGateRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationHandoffGateReceipt(
            runtimeDefaultPathMutationCloseoutGateReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationHandoffGateRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-handoff-gate-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationHandoffGateMode,
        "short-runtime-default-path-mutation-handoff-gate"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationHandoffGateMode,
        "long-runtime-default-path-mutation-handoff-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationHandoffGateMode,
        "blocking-isolation-runtime-default-path-mutation-handoff-gate"
    )
    @Assert(blockingReceipt.runtimeDefaultPathMutationHandoffGateAccepted, true)
    @Assert(blockingReceipt.runtimeDefaultPathMutationHandoffGateAllowed, true)
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.closeoutGateReceipt.runtimeDefaultPathMutationCloseoutGateRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationHandoffGateRecorded,
        true
    )
}

func runTestRuntimeDefaultPathMutationAcceptanceBoundaryBlocksRejectedHandoffGate(): Unit {
    let rejectedHandoffGate =
        buildIgniteRuntimeDefaultPathMutationHandoffGateReceipt(
            runtimeDefaultPathMutationCloseoutGateReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationHandoffGateRequest(
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
                false,
                false,
                false,
                false,
                false,
                false
            )
        )
    let receipt =
        buildIgniteRuntimeDefaultPathMutationAcceptanceBoundaryReceipt(
            rejectedHandoffGate,
            acceptedRuntimeDefaultPathMutationAcceptanceBoundaryRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-handoff-gate-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationAcceptanceBoundaryAccepted,
        false
    )
    @Assert(receipt.runtimeDefaultPathMutationHandoffGateAccepted, false)
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_HANDOFF_GATE_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationAcceptanceBoundaryRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationAcceptanceBoundaryReceipt(
            runtimeDefaultPathMutationHandoffGateReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationAcceptanceBoundaryRequest(
                "runtime-default-path-mutation-acceptance-boundary-2",
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
        "blocked-runtime-default-path-mutation-acceptance-boundary-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationAcceptanceBoundaryAccepted,
        false
    )
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "ACTUAL_HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "ACTUAL_RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.blockers[7], "ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    @Assert(receipt.blockers[8], "DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    @Assert(receipt.blockers[9], "RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    @Assert(receipt.blockers[10], "PUBLIC_RELEASE_REQUESTED")
    @Assert(receipt.blockers[11], "STDX_REMOVAL_REQUESTED")
    @Assert(receipt.blockers[12], "H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    @Assert(receipt.actualDefaultEngineFlipAllowed, false)
    @Assert(receipt.defaultEngineConfigMutationAllowed, false)
    @Assert(receipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(receipt.publicReleaseAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestRuntimeDefaultPathMutationAcceptanceBoundaryBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationAcceptanceBoundaryReceipt(
            runtimeDefaultPathMutationHandoffGateReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationAcceptanceBoundaryRequest(
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
                false,
                false,
                false,
                false,
                false,
                false
            )
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-acceptance-boundary-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationAcceptanceBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_ACCEPTANCE_BOUNDARY_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_HANDOFF_GATE_RECEIPT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(receipt.blockers[3], "ACCEPTANCE_BOUNDARY_NOT_CARRIED")
    @Assert(receipt.blockers[4], "DOWNSTREAM_CONSUMER_BOUNDARY_NOT_CARRIED")
    @Assert(receipt.blockers[5], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "ACCEPTANCE_AUDIT_MARKER_NOT_CARRIED")
    @Assert(
        receipt.runtimeDefaultPathMutationAcceptanceBoundaryRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationAcceptanceBoundaryMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationAcceptanceBoundaryReceipt(
            runtimeDefaultPathMutationHandoffGateReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationAcceptanceBoundaryRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationAcceptanceBoundaryReceipt(
            runtimeDefaultPathMutationHandoffGateReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationAcceptanceBoundaryRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationAcceptanceBoundaryReceipt(
            runtimeDefaultPathMutationHandoffGateReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationAcceptanceBoundaryRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-acceptance-boundary-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationAcceptanceBoundaryMode,
        "short-runtime-default-path-mutation-acceptance-boundary"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationAcceptanceBoundaryMode,
        "long-runtime-default-path-mutation-acceptance-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationAcceptanceBoundaryMode,
        "blocking-isolation-runtime-default-path-mutation-acceptance-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationAcceptanceBoundaryAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationAcceptanceBoundaryAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.handoffGateReceipt.runtimeDefaultPathMutationHandoffGateRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationAcceptanceBoundaryRecorded,
        true
    )
}

func runTestRuntimeDefaultPathMutationApplyBoundaryBlocksRejectedAcceptanceBoundary(): Unit {
    let rejectedAcceptanceBoundary =
        buildIgniteRuntimeDefaultPathMutationAcceptanceBoundaryReceipt(
            runtimeDefaultPathMutationHandoffGateReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationAcceptanceBoundaryRequest(
                "",
                false,
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
                false,
                false,
                false,
                false,
                false,
                false
            )
        )
    let receipt =
        buildIgniteRuntimeDefaultPathMutationApplyBoundaryReceipt(
            rejectedAcceptanceBoundary,
            acceptedRuntimeDefaultPathMutationApplyBoundaryRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-acceptance-boundary-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(receipt.runtimeDefaultPathMutationApplyBoundaryAccepted, false)
    @Assert(
        receipt.runtimeDefaultPathMutationAcceptanceBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_ACCEPTANCE_BOUNDARY_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationApplyBoundaryRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationApplyBoundaryReceipt(
            runtimeDefaultPathMutationAcceptanceBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationApplyBoundaryRequest(
                "runtime-default-path-mutation-apply-boundary-2",
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
        "blocked-runtime-default-path-mutation-apply-boundary-input"
    )
    @Assert(receipt.action, "block")
    @Assert(receipt.runtimeDefaultPathMutationApplyBoundaryAccepted, false)
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "ACTUAL_HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "ACTUAL_RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.blockers[7], "ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    @Assert(receipt.blockers[8], "DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    @Assert(receipt.blockers[9], "RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    @Assert(receipt.blockers[10], "PUBLIC_RELEASE_REQUESTED")
    @Assert(receipt.blockers[11], "STDX_REMOVAL_REQUESTED")
    @Assert(receipt.blockers[12], "H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    @Assert(receipt.actualDefaultEngineFlipAllowed, false)
    @Assert(receipt.defaultEngineConfigMutationAllowed, false)
    @Assert(receipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(receipt.publicReleaseAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestRuntimeDefaultPathMutationApplyBoundaryBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationApplyBoundaryReceipt(
            runtimeDefaultPathMutationAcceptanceBoundaryReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationApplyBoundaryRequest(
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
                false,
                false,
                false,
                false,
                false,
                false
            )
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-apply-boundary-input"
    )
    @Assert(receipt.runtimeDefaultPathMutationApplyBoundaryAccepted, false)
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_BOUNDARY_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_ACCEPTANCE_BOUNDARY_RECEIPT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(receipt.blockers[3], "APPLY_BOUNDARY_NOT_CARRIED")
    @Assert(receipt.blockers[4], "DOWNSTREAM_CONSUMER_BOUNDARY_NOT_CARRIED")
    @Assert(receipt.blockers[5], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "APPLY_AUDIT_MARKER_NOT_CARRIED")
    @Assert(receipt.runtimeDefaultPathMutationApplyBoundaryRecorded, false)
}

func runTestRuntimeDefaultPathMutationApplyBoundaryMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationApplyBoundaryReceipt(
            runtimeDefaultPathMutationAcceptanceBoundaryReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationApplyBoundaryRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationApplyBoundaryReceipt(
            runtimeDefaultPathMutationAcceptanceBoundaryReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationApplyBoundaryRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationApplyBoundaryReceipt(
            runtimeDefaultPathMutationAcceptanceBoundaryReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationApplyBoundaryRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-apply-boundary-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationApplyBoundaryMode,
        "short-runtime-default-path-mutation-apply-boundary"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationApplyBoundaryMode,
        "long-runtime-default-path-mutation-apply-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyBoundaryMode,
        "blocking-isolation-runtime-default-path-mutation-apply-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyBoundaryAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyBoundaryAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.acceptanceBoundaryReceipt.runtimeDefaultPathMutationAcceptanceBoundaryRecorded,
        true
    )
    @Assert(blockingReceipt.runtimeDefaultPathMutationApplyBoundaryRecorded, true)
}

func runTestRuntimeDefaultPathMutationApplyDryRunBlocksRejectedApplyBoundary(): Unit {
    let rejectedApplyBoundary =
        buildIgniteRuntimeDefaultPathMutationApplyBoundaryReceipt(
            runtimeDefaultPathMutationAcceptanceBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationApplyBoundaryRequest(
                "",
                false,
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
                false,
                false,
                false,
                false,
                false,
                false
            )
        )
    let receipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunReceipt(
            rejectedApplyBoundary,
            acceptedRuntimeDefaultPathMutationApplyDryRunRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-apply-boundary-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(receipt.runtimeDefaultPathMutationApplyDryRunAccepted, false)
    @Assert(
        receipt.runtimeDefaultPathMutationApplyBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_BOUNDARY_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationApplyDryRunRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunReceipt(
            runtimeDefaultPathMutationApplyBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationApplyDryRunRequest(
                "runtime-default-path-mutation-apply-dry-run-2",
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
        "blocked-runtime-default-path-mutation-apply-dry-run-input"
    )
    @Assert(receipt.action, "block")
    @Assert(receipt.runtimeDefaultPathMutationApplyDryRunAccepted, false)
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "ACTUAL_HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "ACTUAL_RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.blockers[7], "ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    @Assert(receipt.blockers[8], "DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    @Assert(receipt.blockers[9], "RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    @Assert(receipt.blockers[10], "PUBLIC_RELEASE_REQUESTED")
    @Assert(receipt.blockers[11], "STDX_REMOVAL_REQUESTED")
    @Assert(receipt.blockers[12], "H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    @Assert(receipt.actualDefaultEngineFlipAllowed, false)
    @Assert(receipt.defaultEngineConfigMutationAllowed, false)
    @Assert(receipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(receipt.publicReleaseAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestRuntimeDefaultPathMutationApplyDryRunBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunReceipt(
            runtimeDefaultPathMutationApplyBoundaryReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationApplyDryRunRequest(
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
                false,
                false,
                false,
                false,
                false,
                false
            )
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-apply-dry-run-input"
    )
    @Assert(receipt.runtimeDefaultPathMutationApplyDryRunAccepted, false)
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_BOUNDARY_RECEIPT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(receipt.blockers[3], "APPLY_DRY_RUN_NOT_CARRIED")
    @Assert(receipt.blockers[4], "STAGED_APPLY_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[5], "ROLLBACK_PREVIEW_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "APPLY_AUDIT_MARKER_NOT_CARRIED")
    @Assert(receipt.runtimeDefaultPathMutationApplyDryRunRecorded, false)
}

func runTestRuntimeDefaultPathMutationApplyDryRunMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunReceipt(
            runtimeDefaultPathMutationApplyBoundaryReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationApplyDryRunRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunReceipt(
            runtimeDefaultPathMutationApplyBoundaryReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationApplyDryRunRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunReceipt(
            runtimeDefaultPathMutationApplyBoundaryReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationApplyDryRunRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-apply-dry-run-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationApplyDryRunMode,
        "short-runtime-default-path-mutation-apply-dry-run"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationApplyDryRunMode,
        "long-runtime-default-path-mutation-apply-dry-run"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunMode,
        "blocking-isolation-runtime-default-path-mutation-apply-dry-run"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.applyBoundaryReceipt.runtimeDefaultPathMutationApplyBoundaryRecorded,
        true
    )
    @Assert(blockingReceipt.runtimeDefaultPathMutationApplyDryRunRecorded, true)
}

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceGateBlocksRejectedApplyDryRun(): Unit {
    let rejectedApplyDryRun =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunReceipt(
            runtimeDefaultPathMutationApplyBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationApplyDryRunRequest(
                "",
                false,
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
                false,
                false,
                false,
                false,
                false,
                false
            )
        )
    let receipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceGateReceipt(
            rejectedApplyDryRun,
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceGateRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-apply-dry-run-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateAccepted,
        false
    )
    @Assert(receipt.runtimeDefaultPathMutationApplyDryRunAccepted, false)
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceGateRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceGateReceipt(
            runtimeDefaultPathMutationApplyDryRunReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceGateRequest(
                "runtime-default-path-mutation-apply-dry-run-acceptance-gate-2",
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
        "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-gate-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateAccepted,
        false
    )
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "ACTUAL_HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "ACTUAL_RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.blockers[7], "ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    @Assert(receipt.blockers[8], "DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    @Assert(receipt.blockers[9], "RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    @Assert(receipt.blockers[10], "PUBLIC_RELEASE_REQUESTED")
    @Assert(receipt.blockers[11], "STDX_REMOVAL_REQUESTED")
    @Assert(receipt.blockers[12], "H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    @Assert(receipt.actualDefaultEngineFlipAllowed, false)
    @Assert(receipt.defaultEngineConfigMutationAllowed, false)
    @Assert(receipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(receipt.publicReleaseAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceGateBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceGateReceipt(
            runtimeDefaultPathMutationApplyDryRunReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceGateRequest(
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
                false,
                false,
                false,
                false,
                false,
                false
            )
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-gate-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_GATE_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_RECEIPT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[3],
        "APPLY_DRY_RUN_ACCEPTANCE_GATE_NOT_CARRIED"
    )
    @Assert(receipt.blockers[4], "DRY_RUN_RESULT_REVIEW_NOT_CARRIED")
    @Assert(receipt.blockers[5], "ROLLBACK_PREVIEW_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "APPLY_AUDIT_MARKER_NOT_CARRIED")
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceGateMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceGateReceipt(
            runtimeDefaultPathMutationApplyDryRunReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceGateRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceGateReceipt(
            runtimeDefaultPathMutationApplyDryRunReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceGateRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceGateReceipt(
            runtimeDefaultPathMutationApplyDryRunReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceGateRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-apply-dry-run-acceptance-gate-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateMode,
        "short-runtime-default-path-mutation-apply-dry-run-acceptance-gate"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateMode,
        "long-runtime-default-path-mutation-apply-dry-run-acceptance-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateMode,
        "blocking-isolation-runtime-default-path-mutation-apply-dry-run-acceptance-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.applyDryRunReceipt.runtimeDefaultPathMutationApplyDryRunRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateRecorded,
        true
    )
}

func runTestControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceBlocksRejectedAcceptanceGate(): Unit {
    let rejectedAcceptanceGate =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceGateReceipt(
            runtimeDefaultPathMutationApplyDryRunReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceGateRequest(
                "",
                false,
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
                false,
                false,
                false,
                false,
                false,
                false
            )
        )
    let receipt =
        buildIgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceReceipt(
            rejectedAcceptanceGate,
            acceptedControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-gate-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_GATE_NOT_ACCEPTED"
    )
}

func runTestControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceGateReceiptFor(
                "short-handler"
            ),
            IgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceRequest(
                "controlled-runtime-default-path-mutation-apply-dry-run-acceptance-2",
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
        "blocked-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAccepted,
        false
    )
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "ACTUAL_HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "ACTUAL_RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.blockers[7], "ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    @Assert(receipt.blockers[8], "DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    @Assert(receipt.blockers[9], "RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    @Assert(receipt.blockers[10], "PUBLIC_RELEASE_REQUESTED")
    @Assert(receipt.blockers[11], "STDX_REMOVAL_REQUESTED")
    @Assert(receipt.blockers[12], "H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    @Assert(receipt.actualDefaultEngineFlipAllowed, false)
    @Assert(receipt.defaultEngineConfigMutationAllowed, false)
    @Assert(receipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(receipt.publicReleaseAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceGateReceiptFor(
                "long-handler"
            ),
            IgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceRequest(
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
                false,
                false,
                false,
                false,
                false,
                false
            )
        )

    @Assert(
        receipt.status,
        "blocked-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-input"
    )
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_GATE_RECEIPT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "CONTROLLED_APPLY_DRY_RUN_ACCEPTANCE_SCOPE_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[3],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[4],
        "APPLY_DRY_RUN_ACCEPTANCE_REVIEW_NOT_CARRIED"
    )
    @Assert(receipt.blockers[5], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "APPLY_AUDIT_MARKER_NOT_CARRIED")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceRecorded,
        false
    )
}

func runTestControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceGateReceiptFor(
                "short-handler"
            ),
            acceptedControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceRequest()
        )
    let longReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceGateReceiptFor(
                "long-handler"
            ),
            acceptedControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceRequest()
        )
    let blockingReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceGateReceiptFor(
                "blocking-external-operation"
            ),
            acceptedControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-receipt"
    )
    @Assert(
        shortReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceMode,
        "short-controlled-runtime-default-path-mutation-apply-dry-run-acceptance"
    )
    @Assert(
        longReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceMode,
        "long-controlled-runtime-default-path-mutation-apply-dry-run-acceptance"
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceMode,
        "blocking-isolation-controlled-runtime-default-path-mutation-apply-dry-run-acceptance"
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAccepted,
        true
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateRecorded,
        true
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceRecorded,
        true
    )
}

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryBlocksRejectedControlledAcceptance(): Unit {
    let rejectedControlledAcceptance =
        buildIgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceGateReceiptFor(
                "short-handler"
            ),
            IgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceRequest(
                "",
                false,
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
                false,
                false,
                false,
                false,
                false,
                false
            )
        )
    let receipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryReceipt(
            rejectedControlledAcceptance,
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryRequest()
        )

    @Assert(
        receipt.status,
        "blocked-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAccepted,
        false
    )
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryReceipt(
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryRequest(
                "runtime-default-path-mutation-apply-dry-run-acceptance-boundary-2",
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
        "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-boundary-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAccepted,
        false
    )
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "ACTUAL_HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "ACTUAL_RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.blockers[7], "ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    @Assert(receipt.blockers[8], "DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    @Assert(receipt.blockers[9], "RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    @Assert(receipt.blockers[10], "PUBLIC_RELEASE_REQUESTED")
    @Assert(receipt.blockers[11], "STDX_REMOVAL_REQUESTED")
    @Assert(receipt.blockers[12], "H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    @Assert(receipt.actualDefaultEngineFlipAllowed, false)
    @Assert(receipt.defaultEngineConfigMutationAllowed, false)
    @Assert(receipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(receipt.publicReleaseAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryReceipt(
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryRequest(
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
                false,
                false,
                false,
                false,
                false,
                false
            )
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-boundary-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_BOUNDARY_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_RECEIPT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[3],
        "APPLY_DRY_RUN_ACCEPTANCE_BOUNDARY_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[4],
        "DOWNSTREAM_CONSUMER_BOUNDARY_NOT_CARRIED"
    )
    @Assert(receipt.blockers[5], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "APPLY_AUDIT_MARKER_NOT_CARRIED")
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryReceipt(
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryReceipt(
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryReceipt(
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-apply-dry-run-acceptance-boundary-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryMode,
        "short-runtime-default-path-mutation-apply-dry-run-acceptance-boundary"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryMode,
        "long-runtime-default-path-mutation-apply-dry-run-acceptance-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryMode,
        "blocking-isolation-runtime-default-path-mutation-apply-dry-run-acceptance-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.controlledApplyDryRunAcceptanceReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryRecorded,
        true
    )
}

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateBlocksRejectedAcceptanceBoundary(): Unit {
    let rejectedAcceptanceBoundary =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryReceipt(
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryRequest(
                "",
                false,
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
                false,
                false,
                false,
                false,
                false,
                false
            )
        )
    let receipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateReceipt(
            rejectedAcceptanceBoundary,
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-boundary-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_BOUNDARY_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateRequest(
                "runtime-default-path-mutation-apply-dry-run-acceptance-closeout-gate-2",
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
        "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-closeout-gate-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAccepted,
        false
    )
    @Assert(receipt.blockers[0], "PRODUCTION_QUEUE_MUTATION_REQUESTED")
    @Assert(receipt.blockers[1], "ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    @Assert(receipt.blockers[2], "ACTUAL_HANDLER_INVOCATION_REQUESTED")
    @Assert(receipt.blockers[3], "ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    @Assert(receipt.blockers[4], "ACTUAL_RESPONSE_WRITE_REQUESTED")
    @Assert(receipt.blockers[5], "ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    @Assert(receipt.blockers[6], "ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    @Assert(receipt.blockers[7], "ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    @Assert(receipt.blockers[8], "DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    @Assert(receipt.blockers[9], "RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    @Assert(receipt.blockers[10], "PUBLIC_RELEASE_REQUESTED")
    @Assert(receipt.blockers[11], "STDX_REMOVAL_REQUESTED")
    @Assert(receipt.blockers[12], "H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    @Assert(receipt.actualDefaultEngineFlipAllowed, false)
    @Assert(receipt.defaultEngineConfigMutationAllowed, false)
    @Assert(receipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(receipt.publicReleaseAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}
