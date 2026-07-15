package ignite.tests

import std.unittest.*
import std.unittest.testmacro.*
import ignite.*

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBlocksRejectedGate(): Unit {
    let rejectedGate =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateRequest(
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
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutReceipt(
            rejectedGate,
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutRequest(
                "runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutAccepted,
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

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutRequest(
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

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_RECEIPT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[3],
        "PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[4],
        "DOWNSTREAM_CONSUMER_BOUNDARY_NOT_CARRIED"
    )
    @Assert(receipt.blockers[5], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "BOUNDARY_AUDIT_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[9], "CLOSEOUT_LEDGER_MARKER_NOT_CARRIED")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutMode,
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutMode,
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutRecorded,
        true
    )
    let reusableReceipt =
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutReceiptFor(
            "short-handler"
        )
    @Assert(
        reusableReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutAccepted,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryBlocksRejectedCloseout(): Unit {
    let rejectedCloseout =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutRequest(
                "",
                false,
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
                false,
                false,
                false,
                false,
                false,
                false
            )
        )
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryReceipt(
            rejectedCloseout,
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryRequest(
                "runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryAccepted,
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

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryRequest(
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
                false,
                false
            )
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_RECEIPT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[3],
        "PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[4],
        "DOWNSTREAM_CONSUMER_BOUNDARY_NOT_CARRIED"
    )
    @Assert(receipt.blockers[5], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "BOUNDARY_AUDIT_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[9], "CLOSEOUT_LEDGER_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[10], "CLOSEOUT_BOUNDARY_MARKER_NOT_CARRIED")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryMode,
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryMode,
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryRecorded,
        true
    )
    let reusableReceipt =
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryReceiptFor(
            "short-handler"
        )
    @Assert(
        reusableReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryAccepted,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateBlocksRejectedBoundary(): Unit {
    let rejectedBoundary =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryRequest(
                "",
                false,
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
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateReceipt(
            rejectedBoundary,
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateRequest(
                "runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateAccepted,
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

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateRequest(
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
                false,
                false,
                false
            )
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_RECEIPT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[3],
        "PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[4],
        "DOWNSTREAM_CONSUMER_BOUNDARY_NOT_CARRIED"
    )
    @Assert(receipt.blockers[5], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "BOUNDARY_AUDIT_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[9], "CLOSEOUT_LEDGER_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[10], "CLOSEOUT_BOUNDARY_MARKER_NOT_CARRIED")
    @Assert(
        receipt.blockers[11],
        "CLOSEOUT_BOUNDARY_GATE_MARKER_NOT_CARRIED"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateMode,
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateMode,
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateRecorded,
        true
    )
    let reusableReceipt =
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateReceiptFor(
            "short-handler"
        )
    @Assert(
        reusableReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateAccepted,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateBlocksRejectedCloseoutBoundaryGate(): Unit {
    let rejectedCloseoutBoundaryGate =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateRequest(
                "",
                false,
                true,
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
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateReceipt(
            rejectedCloseoutBoundaryGate,
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateRequest(
                "runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-gate-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-gate-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateAccepted,
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

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateRequest(
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-gate-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_GATE_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_RECEIPT_NOT_CARRIED"
    )
    @Assert(receipt.blockers[2], "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    @Assert(receipt.blockers[3], "DEFAULT_PATH_CANDIDATE_NOT_CARRIED")
    @Assert(receipt.blockers[4], "RUNTIME_MUTATION_PREPARATION_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[5], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "BOUNDARY_AUDIT_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[9], "SOURCE_ZERO_STDX_CLAIM_NOT_SEPARATED")
    @Assert(receipt.blockers[10], "PUBLIC_CLAIM_BOUNDARY_NOT_CARRIED")
    @Assert(receipt.blockers[11], "QUIC_REUSE_BOUNDARY_NOT_CARRIED")
    @Assert(receipt.blockers[12], "CLOSEOUT_LEDGER_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[13], "CLOSEOUT_BOUNDARY_MARKER_NOT_CARRIED")
    @Assert(
        receipt.blockers[14],
        "CLOSEOUT_BOUNDARY_GATE_MARKER_NOT_CARRIED"
    )
    @Assert(receipt.blockers[15], "PREPARATION_GATE_MARKER_NOT_CARRIED")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-gate-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateMode,
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-gate"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateMode,
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateRecorded,
        true
    )
    let reusableReceipt =
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateReceiptFor(
            "short-handler"
        )
    @Assert(
        reusableReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateAccepted,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryBlocksRejectedPreparationGate(): Unit {
    let rejectedPreparationGate =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateRequest(
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
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryReceipt(
            rejectedPreparationGate,
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-gate-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_GATE_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryRequest(
                "runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-boundary-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-boundary-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryAccepted,
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

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryRequest(
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
                false,
                false,
                false,
                false,
                false
            )
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-boundary-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_BOUNDARY_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_GATE_RECEIPT_NOT_CARRIED"
    )
    @Assert(receipt.blockers[2], "PREPARATION_BOUNDARY_MARKER_NOT_CARRIED")
    @Assert(
        receipt.blockers[3],
        "MUTATION_READINESS_REVIEW_MARKER_NOT_CARRIED"
    )
    @Assert(receipt.blockers[4], "ROLLBACK_VERIFICATION_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[5], "DEFAULT_PATH_CANDIDATE_FREEZE_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_REVIEW_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_REVIEW_NOT_CARRIED")
    @Assert(receipt.blockers[8], "SOURCE_ZERO_STDX_CLAIM_NOT_SEPARATED")
    @Assert(receipt.blockers[9], "PUBLIC_CLAIM_BOUNDARY_NOT_CARRIED")
    @Assert(receipt.blockers[10], "QUIC_REUSE_BOUNDARY_NOT_CARRIED")
    @Assert(receipt.blockers[11], "CLOSEOUT_LEDGER_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[12], "CLOSEOUT_BOUNDARY_MARKER_NOT_CARRIED")
    @Assert(
        receipt.blockers[13],
        "CLOSEOUT_BOUNDARY_GATE_MARKER_NOT_CARRIED"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-boundary-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryMode,
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-boundary"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryMode,
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryRecorded,
        true
    )
    let reusableReceipt =
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryReceiptFor(
            "short-handler"
        )
    @Assert(
        reusableReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryAccepted,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunBlocksRejectedPreparationBoundary(): Unit {
    let rejectedPreparationBoundary =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryRequest(
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
                false,
                false,
                false,
                false,
                false
            )
        )
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunReceipt(
            rejectedPreparationBoundary,
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-boundary-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_BOUNDARY_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunRequest(
                "runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-dry-run-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-dry-run-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunAccepted,
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

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunRequest(
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
                false,
                false
            )
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-dry-run-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_DRY_RUN_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_BOUNDARY_RECEIPT_NOT_CARRIED"
    )
    @Assert(receipt.blockers[2], "PREPARATION_DRY_RUN_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[3], "SIMULATION_INPUT_SNAPSHOT_NOT_CARRIED")
    @Assert(receipt.blockers[4], "DEFAULT_PATH_CANDIDATE_SNAPSHOT_NOT_CARRIED")
    @Assert(receipt.blockers[5], "ROLLBACK_DRY_RUN_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_DRY_RUN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_DRY_RUN_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "SOURCE_ZERO_STDX_CLAIM_NOT_SEPARATED")
    @Assert(receipt.blockers[9], "PUBLIC_CLAIM_BOUNDARY_NOT_CARRIED")
    @Assert(receipt.blockers[10], "QUIC_REUSE_BOUNDARY_NOT_CARRIED")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-dry-run-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunMode,
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-dry-run"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunMode,
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-dry-run"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-dry-run"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunRecorded,
        true
    )
    let reusableReceipt =
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunReceiptFor(
            "short-handler"
        )
    @Assert(
        reusableReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunAccepted,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateBlocksRejectedPreparationDryRun(): Unit {
    let rejectedPreparationDryRun =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunRequest(
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
                false,
                false
            )
        )
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateReceipt(
            rejectedPreparationDryRun,
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-dry-run-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_DRY_RUN_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateRequest(
                "runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-gate-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-gate-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateAccepted,
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

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateRequest(
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
                false,
                false
            )
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-gate-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_GATE_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_DRY_RUN_RECEIPT_NOT_CARRIED"
    )
    @Assert(receipt.blockers[2], "PREPARATION_APPLY_GATE_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[3], "DRY_RUN_RESULT_REVIEW_NOT_CARRIED")
    @Assert(receipt.blockers[4], "APPLY_READINESS_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[5], "ROLLBACK_APPLY_GATE_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_APPLY_GATE_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_APPLY_GATE_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "SOURCE_ZERO_STDX_CLAIM_NOT_SEPARATED")
    @Assert(receipt.blockers[9], "PUBLIC_CLAIM_BOUNDARY_NOT_CARRIED")
    @Assert(receipt.blockers[10], "QUIC_REUSE_BOUNDARY_NOT_CARRIED")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-gate-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateMode,
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-gate"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateMode,
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateRecorded,
        true
    )
    let reusableReceipt =
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateReceiptFor(
            "short-handler"
        )
    @Assert(
        reusableReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateAccepted,
        true
    )
}

func runTestControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBlocksRejectedPreparationApplyGate(): Unit {
    let rejectedPreparationApplyGate =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateRequest(
                "",
                false,
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
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyReceipt(
            rejectedPreparationApplyGate,
            acceptedControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-gate-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyAccepted,
        false
    )
    @Assert(receipt.preparationApplyGateAccepted, false)
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_GATE_NOT_ACCEPTED"
    )
}

func runTestControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateReceiptFor(
                "short-handler"
            ),
            IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyRequest(
                "controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyAccepted,
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

func runTestControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateReceiptFor(
                "long-handler"
            ),
            IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyRequest(
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
        "blocked-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-input"
    )
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_GATE_RECEIPT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "CONTROLLED_PREPARATION_APPLY_SCOPE_NOT_CARRIED"
    )
    @Assert(receipt.blockers[3], "DEFAULT_ENGINE_MUTATION_LOCK_NOT_CARRIED")
    @Assert(
        receipt.blockers[4],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(receipt.blockers[5], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "SOURCE_ZERO_STDX_CLAIM_NOT_SEPARATED")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyRecorded,
        false
    )
}

func runTestControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateReceiptFor(
                "short-handler"
            ),
            acceptedControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyRequest()
        )
    let longReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateReceiptFor(
                "long-handler"
            ),
            acceptedControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyRequest()
        )
    let blockingReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateReceiptFor(
                "blocking-external-operation"
            ),
            acceptedControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-receipt"
    )
    @Assert(
        shortReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyMode,
        "short-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply"
    )
    @Assert(
        longReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyMode,
        "long-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply"
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyMode,
        "blocking-isolation-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply"
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyAccepted,
        true
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateRecorded,
        true
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyRecorded,
        true
    )
    let reusableReceipt =
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyReceiptFor(
            "short-handler"
        )
    @Assert(
        reusableReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyAccepted,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanBlocksRejectedControlledPreparationApply(): Unit {
    let rejectedControlledPreparationApply =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateReceiptFor(
                "short-handler"
            ),
            IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyRequest(
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
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanReceipt(
            rejectedControlledPreparationApply,
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanRequest()
        )

    @Assert(
        receipt.status,
        "blocked-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanAccepted,
        false
    )
    @Assert(receipt.controlledPreparationApplyAccepted, false)
    @Assert(
        receipt.blockers[0],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanRequest(
                "runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-plan-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-plan-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanAccepted,
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

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanRequest(
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
                false,
                false
            )
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-plan-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_PLAN_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_RECEIPT_NOT_CARRIED"
    )
    @Assert(receipt.blockers[2], "PREPARATION_COMMIT_PLAN_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[3], "CONTROLLED_PREPARATION_APPLY_REVIEW_NOT_CARRIED")
    @Assert(receipt.blockers[4], "COMMIT_PLAN_READINESS_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[5], "ROLLBACK_COMMIT_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_COMMIT_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_COMMIT_PLAN_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "SOURCE_ZERO_STDX_CLAIM_NOT_SEPARATED")
    @Assert(receipt.blockers[9], "PUBLIC_CLAIM_BOUNDARY_NOT_CARRIED")
    @Assert(receipt.blockers[10], "QUIC_REUSE_BOUNDARY_NOT_CARRIED")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-plan-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanMode,
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-plan"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanMode,
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-plan"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-plan"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.controlledPreparationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanRecorded,
        true
    )
    let reusableReceipt =
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanReceiptFor(
            "short-handler"
        )
    @Assert(
        reusableReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanAccepted,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunBlocksRejectedCommitPlan(): Unit {
    let rejectedCommitPlan =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanRequest(
                "",
                false,
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
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunReceipt(
            rejectedCommitPlan,
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-plan-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_PLAN_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunRequest(
                "runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-dry-run-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-dry-run-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunAccepted,
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

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunRequest(
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
                false,
                false,
                false
            )
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-dry-run-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_DRY_RUN_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_PLAN_SNAPSHOT_NOT_CARRIED"
    )
    @Assert(receipt.blockers[2], "PREPARATION_COMMIT_DRY_RUN_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[3], "TARGET_RUNTIME_DEFAULT_PATH_PREVIEW_NOT_CARRIED")
    @Assert(receipt.blockers[4], "ISOLATED_PREPARATION_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[5], "DRY_RUN_SANDBOX_NOT_CARRIED")
    @Assert(receipt.blockers[6], "CONFIG_DIFF_PREVIEW_NOT_CARRIED")
    @Assert(receipt.blockers[7], "ROLLBACK_SIMULATION_NOT_CARRIED")
    @Assert(receipt.blockers[8], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[9], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[10], "SOURCE_ZERO_STDX_CLAIM_NOT_SEPARATED")
    @Assert(receipt.blockers[11], "QUIC_REUSE_BOUNDARY_NOT_CARRIED")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-dry-run-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunMode,
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-dry-run"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunMode,
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-dry-run"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-dry-run"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.preparationCommitPlanReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunRecorded,
        true
    )
    let reusableReceipt =
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunReceiptFor(
            "short-handler"
        )
    @Assert(
        reusableReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunAccepted,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateBlocksRejectedCommitDryRun(): Unit {
    let rejectedCommitPlan =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanRequest(
                "",
                false,
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
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunReceipt(
            rejectedCommitPlan,
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunRequest()
        )
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateReceipt(
            rejectedDryRun,
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-dry-run-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_DRY_RUN_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateRequest(
                "runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply-gate-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply-gate-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateAccepted,
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

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateRequest(
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

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply-gate-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_APPLY_GATE_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_DRY_RUN_SNAPSHOT_NOT_CARRIED"
    )
    @Assert(receipt.blockers[2], "TARGET_RUNTIME_DEFAULT_PATH_PREVIEW_NOT_CARRIED")
    @Assert(receipt.blockers[3], "APPLY_PRECONDITION_GATE_NOT_CARRIED")
    @Assert(receipt.blockers[4], "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    @Assert(receipt.blockers[5], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "SOURCE_ZERO_STDX_CLAIM_NOT_SEPARATED")
    @Assert(receipt.blockers[9], "QUIC_REUSE_BOUNDARY_NOT_CARRIED")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply-gate-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateMode,
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply-gate"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateMode,
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.preparationCommitDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateRecorded,
        true
    )
    let reusableReceipt =
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateReceiptFor(
            "short-handler"
        )
    @Assert(
        reusableReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateAccepted,
        true
    )
}

func runTestControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyBlocksRejectedPreparationCommitApplyGate(): Unit {
    let rejectedApplyGate =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateRequest(
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
    let receipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyReceipt(
            rejectedApplyGate,
            acceptedControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply-gate-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_APPLY_GATE_NOT_ACCEPTED"
    )
}

func runTestControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateReceiptFor(
                "short-handler"
            ),
            IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyRequest(
                "controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyAccepted,
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

func runTestControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateReceiptFor(
                "long-handler"
            ),
            IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyRequest(
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
        "blocked-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply-input"
    )
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_APPLY_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_APPLY_GATE_SNAPSHOT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(receipt.blockers[3], "PREPARATION_COMMIT_APPLY_BOUNDARY_NOT_CARRIED")
    @Assert(receipt.blockers[4], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[5], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[6], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyRecorded,
        false
    )
}

func runTestControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateReceiptFor(
                "short-handler"
            ),
            acceptedControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyRequest()
        )
    let longReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateReceiptFor(
                "long-handler"
            ),
            acceptedControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyRequest()
        )
    let blockingReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateReceiptFor(
                "blocking-external-operation"
            ),
            acceptedControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply-receipt"
    )
    @Assert(
        shortReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyMode,
        "short-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply"
    )
    @Assert(
        longReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyMode,
        "long-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply"
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyMode,
        "blocking-isolation-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply"
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyAccepted,
        true
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateRecorded,
        true
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyRecorded,
        true
    )
    let reusableReceipt =
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyReceiptFor(
            "short-handler"
        )
    @Assert(
        reusableReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyAccepted,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryBlocksRejectedControlledPreparationCommitApply(): Unit {
    let rejectedApplyGate =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateRequest(
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
    let rejectedControlledApply =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyReceipt(
            rejectedApplyGate,
            acceptedControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyRequest()
        )
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryReceipt(
            rejectedControlledApply,
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryRequest()
        )

    @Assert(
        receipt.status,
        "blocked-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryAccepted,
        false
    )
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_APPLY_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryRefusesRuntimeDefaultStdxAndReleaseOverclaims(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryRequest(
                "runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-boundary-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-boundary-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryAccepted,
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
    @Assert(receipt.stdxRemovalAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryRequest(
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-boundary-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_BOUNDARY_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_APPLY_SNAPSHOT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[3],
        "PREPARATION_COMMIT_BOUNDARY_SNAPSHOT_NOT_CARRIED"
    )
    @Assert(receipt.blockers[4], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[5], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[6], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryMapsLaneModesAndRecordsParent(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-boundary-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryMode,
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-boundary"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryMode,
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.controlledPreparationCommitApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryRecorded,
        true
    )
    @Assert(
        blockingReceipt.applyBoundaryGateId,
        blockingReceipt.controlledPreparationCommitApplyReceipt.applyBoundaryGateId
    )
    let reusableReceipt =
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryReceiptFor(
            "short-handler"
        )
    @Assert(
        reusableReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryAccepted,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateBlocksRejectedCommitBoundary(): Unit {
    let rejectedBoundary =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryRequest(
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
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateReceipt(
            rejectedBoundary,
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-boundary-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_BOUNDARY_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateRefusesRuntimeDefaultStdxAndReleaseOverclaims(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateRequest(
                "runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-gate-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-gate-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateAccepted,
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
    @Assert(receipt.stdxRemovalAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateRequest(
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-gate-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_FINALIZATION_GATE_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_BOUNDARY_SNAPSHOT_NOT_CARRIED"
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
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateMapsLaneModesAndRecordsParent(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-gate-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateMode,
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-gate"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateMode,
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateRecorded,
        true
    )
    @Assert(
        blockingReceipt.applyBoundaryGateId,
        blockingReceipt.preparationCommitBoundaryReceipt.applyBoundaryGateId
    )
    let reusableReceipt =
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateReceiptFor(
            "short-handler"
        )
    @Assert(
        reusableReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateAccepted,
        true
    )
}

func runTestControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyBlocksRejectedFinalizationGate(): Unit {
    let rejectedBoundary =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryRequest(
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
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateReceipt(
            rejectedBoundary,
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateRequest()
        )
    let receipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyReceipt(
            rejectedFinalizationGate,
            acceptedControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-gate-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_FINALIZATION_GATE_NOT_ACCEPTED"
    )
}

func runTestControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyRefusesRuntimeDefaultStdxAndReleaseOverclaims(): Unit {
    let receipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateReceiptFor(
                "short-handler"
            ),
            IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyRequest(
                "controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-apply-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-apply-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyAccepted,
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
    @Assert(receipt.stdxRemovalAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateReceiptFor(
                "long-handler"
            ),
            IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyRequest(
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
        "blocked-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-apply-input"
    )
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_FINALIZATION_APPLY_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_FINALIZATION_GATE_SNAPSHOT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[3],
        "PREPARATION_FINALIZATION_APPLY_BOUNDARY_NOT_CARRIED"
    )
    @Assert(receipt.blockers[4], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[5], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[6], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[7], "FINALIZATION_AUDIT_MARKER_NOT_CARRIED")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyRecorded,
        false
    )
}

func runTestControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyMapsLaneModesAndRecordsParent(): Unit {
    let shortReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateReceiptFor(
                "short-handler"
            ),
            acceptedControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyRequest()
        )
    let longReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateReceiptFor(
                "long-handler"
            ),
            acceptedControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyRequest()
        )
    let blockingReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateReceiptFor(
                "blocking-external-operation"
            ),
            acceptedControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-apply-receipt"
    )
    @Assert(
        shortReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyMode,
        "short-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-apply"
    )
    @Assert(
        longReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyMode,
        "long-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-apply"
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyMode,
        "blocking-isolation-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-apply"
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyAccepted,
        true
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateRecorded,
        true
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyRecorded,
        true
    )
    @Assert(
        blockingReceipt.acceptanceBoundaryId,
        blockingReceipt.preparationFinalizationGateReceipt.acceptanceBoundaryId
    )
    let reusableReceipt =
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyReceiptFor(
            "short-handler"
        )
    @Assert(
        reusableReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyAccepted,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateBlocksRejectedControlledFinalizationApply(): Unit {
    let rejectedBoundary =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryRequest(
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
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateReceipt(
            rejectedBoundary,
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateRequest()
        )
    let rejectedFinalizationApply =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyReceipt(
            rejectedFinalizationGate,
            acceptedControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyRequest()
        )
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateReceipt(
            rejectedFinalizationApply,
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateRequest()
        )

    @Assert(
        receipt.status,
        "blocked-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-apply-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateAccepted,
        false
    )
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_FINALIZATION_APPLY_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateRefusesRuntimeDefaultStdxAndReleaseOverclaims(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateRequest(
                "runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-closeout-gate-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-closeout-gate-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateAccepted,
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
    @Assert(receipt.stdxRemovalAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateRequest(
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-closeout-gate-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_CLOSEOUT_GATE_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_FINALIZATION_APPLY_SNAPSHOT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(receipt.blockers[3], "PREPARATION_CLOSEOUT_GATE_NOT_CARRIED")
    @Assert(receipt.blockers[4], "CLOSEOUT_REVIEW_NOT_CARRIED")
    @Assert(receipt.blockers[5], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "CLOSEOUT_AUDIT_MARKER_NOT_CARRIED")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateMapsLaneModesAndRecordsParent(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-closeout-gate-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateMode,
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-closeout-gate"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateMode,
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-closeout-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-closeout-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.controlledPreparationFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateRecorded,
        true
    )
    @Assert(
        blockingReceipt.acceptanceBoundaryId,
        blockingReceipt.controlledPreparationFinalizationApplyReceipt.acceptanceBoundaryId
    )
    let reusableReceipt =
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateReceiptFor(
            "short-handler"
        )
    @Assert(
        reusableReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateAccepted,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateBlocksRejectedPreparationCloseoutGate(): Unit {
    let rejectedCloseoutGate =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateRequest(
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
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateReceipt(
            rejectedCloseoutGate,
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-closeout-gate-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_CLOSEOUT_GATE_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateRefusesRuntimeDefaultStdxAndReleaseOverclaims(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateRequest(
                "runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-handoff-gate-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-handoff-gate-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateAccepted,
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
    @Assert(receipt.stdxRemovalAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateRequest(
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-handoff-gate-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_HANDOFF_GATE_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_CLOSEOUT_GATE_SNAPSHOT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(receipt.blockers[3], "PREPARATION_HANDOFF_GATE_NOT_CARRIED")
    @Assert(receipt.blockers[4], "HANDOFF_REVIEW_NOT_CARRIED")
    @Assert(receipt.blockers[5], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "HANDOFF_AUDIT_MARKER_NOT_CARRIED")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateMapsLaneModesAndRecordsParent(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-handoff-gate-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateMode,
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-handoff-gate"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateMode,
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-handoff-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-handoff-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateRecorded,
        true
    )
    @Assert(
        blockingReceipt.acceptanceBoundaryId,
        blockingReceipt.preparationCloseoutGateReceipt.acceptanceBoundaryId
    )
    let reusableReceipt =
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateReceiptFor(
            "short-handler"
        )
    @Assert(
        reusableReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateAccepted,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryBlocksRejectedPreparationHandoffGate(): Unit {
    let rejectedHandoffGate =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateRequest(
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
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryReceipt(
            rejectedHandoffGate,
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-handoff-gate-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_HANDOFF_GATE_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryRefusesRuntimeDefaultStdxAndReleaseOverclaims(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryRequest(
                "runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-acceptance-boundary-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-acceptance-boundary-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryAccepted,
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
    @Assert(receipt.stdxRemovalAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryRequest(
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-acceptance-boundary-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_ACCEPTANCE_BOUNDARY_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_HANDOFF_GATE_RECEIPT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[3],
        "PREPARATION_ACCEPTANCE_BOUNDARY_NOT_CARRIED"
    )
    @Assert(receipt.blockers[4], "DOWNSTREAM_CONSUMER_BOUNDARY_NOT_CARRIED")
    @Assert(receipt.blockers[5], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "ACCEPTANCE_AUDIT_MARKER_NOT_CARRIED")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryMapsLaneModesAndRecordsParent(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-acceptance-boundary-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryMode,
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-acceptance-boundary"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryMode,
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-acceptance-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-acceptance-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryRecorded,
        true
    )
    @Assert(
        blockingReceipt.acceptanceBoundaryId,
        blockingReceipt.preparationHandoffGateReceipt.acceptanceBoundaryId
    )
    let reusableReceipt =
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryReceiptFor(
            "short-handler"
        )
    @Assert(
        reusableReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryAccepted,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryBlocksRejectedPreparationAcceptanceBoundary(): Unit {
    let rejectedAcceptanceBoundary =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryRequest(
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
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryReceipt(
            rejectedAcceptanceBoundary,
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-acceptance-boundary-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_ACCEPTANCE_BOUNDARY_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryRefusesRuntimeDefaultStdxAndReleaseOverclaims(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryRequest(
                "runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-boundary-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-boundary-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryAccepted,
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

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryRequest(
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-boundary-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_BOUNDARY_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_ACCEPTANCE_BOUNDARY_RECEIPT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(receipt.blockers[3], "PREPARATION_APPLY_BOUNDARY_NOT_CARRIED")
    @Assert(receipt.blockers[4], "DOWNSTREAM_CONSUMER_BOUNDARY_NOT_CARRIED")
    @Assert(receipt.blockers[5], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "APPLY_AUDIT_MARKER_NOT_CARRIED")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryMapsLaneModesAndRecordsParent(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-boundary-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryMode,
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-boundary"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryMode,
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryRecorded,
        true
    )
    @Assert(
        blockingReceipt.acceptanceBoundaryId,
        blockingReceipt.preparationAcceptanceBoundaryReceipt.acceptanceBoundaryId
    )
    let reusableReceipt =
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryReceiptFor(
            "short-handler"
        )
    @Assert(
        reusableReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryAccepted,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunBlocksRejectedPreparationApplyBoundary(): Unit {
    let rejectedApplyBoundary =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryRequest(
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
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunReceipt(
            rejectedApplyBoundary,
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-boundary-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_BOUNDARY_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunRefusesRuntimeDefaultStdxAndReleaseOverclaims(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunRequest(
                "runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAccepted,
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

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunRequest(
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_BOUNDARY_RECEIPT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(receipt.blockers[3], "PREPARATION_APPLY_DRY_RUN_NOT_CARRIED")
    @Assert(receipt.blockers[4], "STAGED_PREPARATION_APPLY_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[5], "ROLLBACK_PREVIEW_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "APPLY_AUDIT_MARKER_NOT_CARRIED")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunMapsLaneModesAndRecordsParent(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunMode,
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunMode,
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunRecorded,
        true
    )
    @Assert(
        blockingReceipt.applyBoundaryId,
        blockingReceipt.preparationApplyBoundaryReceipt.applyBoundaryId
    )
    let reusableReceipt =
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunReceiptFor(
            "short-handler"
        )
    @Assert(
        reusableReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAccepted,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateBlocksRejectedPreparationApplyDryRun(): Unit {
    let rejectedApplyDryRun =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunRequest(
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
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateReceipt(
            rejectedApplyDryRun,
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateRefusesRuntimeDefaultStdxAndReleaseOverclaims(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateRequest(
                "runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-gate-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-gate-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateAccepted,
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

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateRequest(
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-gate-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_GATE_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_RECEIPT_NOT_CARRIED"
    )
    @Assert(receipt.blockers[2], "APPLY_DRY_RUN_REVIEW_NOT_CARRIED")
    @Assert(
        receipt.blockers[3],
        "PREPARATION_APPLY_DRY_RUN_GATE_MARKER_NOT_CARRIED"
    )
    @Assert(receipt.blockers[4], "STAGED_APPLY_READINESS_NOT_CARRIED")
    @Assert(receipt.blockers[5], "ROLLBACK_APPLY_GATE_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_APPLY_GATE_NOT_CARRIED")
    @Assert(
        receipt.blockers[7],
        "OBSERVABILITY_APPLY_GATE_MARKER_NOT_CARRIED"
    )
    @Assert(receipt.blockers[8], "APPLY_AUDIT_MARKER_NOT_CARRIED")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateMapsLaneModesAndRecordsParent(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-gate-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateMode,
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-gate"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateMode,
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunId,
        blockingReceipt.preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunId
    )
    let reusableReceipt =
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateReceiptFor(
            "short-handler"
        )
    @Assert(
        reusableReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateAccepted,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryBlocksRejectedPreparationApplyDryRunGate(): Unit {
    let rejectedGate =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateRequest(
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
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryReceipt(
            rejectedGate,
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-gate-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_GATE_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryRefusesRuntimeDefaultStdxAndReleaseOverclaims(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryRequest(
                "runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-acceptance-boundary-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-acceptance-boundary-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryAccepted,
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
    @Assert(receipt.stdxRemovalAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryRequest(
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-acceptance-boundary-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_ACCEPTANCE_BOUNDARY_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_GATE_RECEIPT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[3],
        "PREPARATION_APPLY_DRY_RUN_ACCEPTANCE_BOUNDARY_NOT_CARRIED"
    )
    @Assert(receipt.blockers[4], "DOWNSTREAM_CONSUMER_BOUNDARY_NOT_CARRIED")
    @Assert(receipt.blockers[5], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "APPLY_AUDIT_MARKER_NOT_CARRIED")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryMapsLaneModesAndRecordsParent(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-acceptance-boundary-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryMode,
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-acceptance-boundary"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryMode,
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-acceptance-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-acceptance-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.preparationApplyDryRunGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateId,
        blockingReceipt.preparationApplyDryRunGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateId
    )
    let reusableReceipt =
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryReceiptFor(
            "short-handler"
        )
    @Assert(
        reusableReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryAccepted,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateBlocksRejectedPreparationApplyDryRunAcceptanceBoundary(): Unit {
    let rejectedAcceptanceBoundary =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryRequest(
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
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateReceipt(
            rejectedAcceptanceBoundary,
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-acceptance-boundary-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_ACCEPTANCE_BOUNDARY_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateRefusesRuntimeDefaultStdxAndReleaseOverclaims(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateRequest(
                "runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-closeout-gate-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-closeout-gate-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateAccepted,
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
    @Assert(receipt.stdxRemovalAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateBlocksMissingCloseoutGateMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateRequest(
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-closeout-gate-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_CLOSEOUT_GATE_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_ACCEPTANCE_BOUNDARY_RECEIPT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[3],
        "PREPARATION_APPLY_DRY_RUN_CLOSEOUT_GATE_NOT_CARRIED"
    )
    @Assert(receipt.blockers[4], "DOWNSTREAM_CONSUMER_BOUNDARY_NOT_CARRIED")
    @Assert(receipt.blockers[5], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "CLOSEOUT_AUDIT_MARKER_NOT_CARRIED")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateMapsLaneModesAndRecordsParentAcceptanceBoundary(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-closeout-gate-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateMode,
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-closeout-gate"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateMode,
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-closeout-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-closeout-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.preparationApplyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId,
        blockingReceipt.preparationApplyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId
    )
    let reusableReceipt =
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateReceiptFor(
            "short-handler"
        )
    @Assert(
        reusableReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateAccepted,
        true
    )
}

func runTestControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBlocksRejectedPreparationApplyDryRunCloseoutGate(): Unit {
    let rejectedCloseoutGate =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateRequest(
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
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffReceipt(
            rejectedCloseoutGate,
            acceptedControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-closeout-gate-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_CLOSEOUT_GATE_NOT_ACCEPTED"
    )
}

func runTestControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffRefusesRuntimeDefaultStdxAndReleaseOverclaims(): Unit {
    let receipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateReceiptFor(
                "short-handler"
            ),
            IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffRequest(
                "controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffAccepted,
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
    @Assert(receipt.stdxRemovalAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBlocksMissingHandoffMarkers(): Unit {
    let receipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateReceiptFor(
                "long-handler"
            ),
            IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffRequest(
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
        "blocked-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff-input"
    )
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_HANDOFF_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_CLOSEOUT_GATE_RECEIPT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[3],
        "CONTROLLED_PREPARATION_APPLY_DRY_RUN_HANDOFF_NOT_CARRIED"
    )
    @Assert(receipt.blockers[4], "DOWNSTREAM_CONSUMER_BOUNDARY_NOT_CARRIED")
    @Assert(receipt.blockers[5], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "HANDOFF_AUDIT_MARKER_NOT_CARRIED")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffRecorded,
        false
    )
}

func runTestControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffMapsLaneModesAndRecordsParentCloseoutGate(): Unit {
    let shortReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateReceiptFor(
                "short-handler"
            ),
            acceptedControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffRequest()
        )
    let longReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateReceiptFor(
                "long-handler"
            ),
            acceptedControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffRequest()
        )
    let blockingReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateReceiptFor(
                "blocking-external-operation"
            ),
            acceptedControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff-receipt"
    )
    @Assert(
        shortReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffMode,
        "short-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff"
    )
    @Assert(
        longReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffMode,
        "long-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff"
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffMode,
        "blocking-isolation-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff"
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffAccepted,
        true
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.preparationApplyDryRunCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateRecorded,
        true
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateId,
        blockingReceipt.preparationApplyDryRunCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateId
    )
    let reusableReceipt =
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffReceiptFor(
            "short-handler"
        )
    @Assert(
        reusableReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffAccepted,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryBlocksRejectedControlledHandoff(): Unit {
    let rejectedControlledHandoff =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateReceiptFor(
                "short-handler"
            ),
            IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffRequest(
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
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryReceipt(
            rejectedControlledHandoff,
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryRequest()
        )

    @Assert(
        receipt.status,
        "blocked-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryAccepted,
        false
    )
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_HANDOFF_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryRefusesRuntimeDefaultStdxAndReleaseOverclaims(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryRequest(
                "runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff-boundary-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff-boundary-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryAccepted,
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
    @Assert(receipt.stdxRemovalAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryBlocksMissingBoundaryMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryRequest(
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff-boundary-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_HANDOFF_BOUNDARY_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_HANDOFF_RECEIPT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[3],
        "PREPARATION_APPLY_DRY_RUN_HANDOFF_BOUNDARY_NOT_CARRIED"
    )
    @Assert(receipt.blockers[4], "DOWNSTREAM_CONSUMER_BOUNDARY_NOT_CARRIED")
    @Assert(receipt.blockers[5], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "BOUNDARY_AUDIT_MARKER_NOT_CARRIED")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryMapsLaneModesAndRecordsParentControlledHandoff(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff-boundary-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryMode,
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff-boundary"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryMode,
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.controlledPreparationApplyDryRunHandoffReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryRecorded,
        true
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffId,
        blockingReceipt.controlledPreparationApplyDryRunHandoffReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffId
    )
    let reusableReceipt =
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryReceiptFor(
            "short-handler"
        )
    @Assert(
        reusableReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryAccepted,
        true
    )
}

func runTestRuntimeDefaultPathMutationBoundarySummaryRecordsShortAliasWithoutMutation(): Unit {
    let summary = buildIgniteRuntimeDefaultPathMutationBoundarySummary(
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryReceiptFor(
            "short-handler"
        )
    )

    @Assert(summary.status, "accepted-runtime-default-path-mutation-boundary-summary-receipt")
    @Assert(summary.action, "record-runtime-default-path-mutation-boundary-summary")
    @Assert(summary.runtimeDefaultPathMutationBoundarySummaryAccepted, true)
    @Assert(summary.sourceHandoffBoundaryAccepted, true)
    @Assert(
        summary.summaryAlias,
        "runtime-default-path-boundary-summary:short"
    )
    @Assert(
        summary.sourceHandoffBoundaryId,
        "runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff-boundary-1"
    )
    @Assert(summary.actualDefaultEngineFlipAllowed, false)
    @Assert(summary.defaultEngineConfigMutationAllowed, false)
    @Assert(summary.runtimeDefaultPathMutationAllowed, false)
    @Assert(summary.publicReleaseAllowed, false)
    @Assert(summary.stdxRemovalAllowed, false)
    @Assert(summary.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
    @Assert(summary.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestRuntimeDefaultPathMutationBoundarySummaryBlocksRejectedHandoffBoundary(): Unit {
    let rejectedHandoffBoundary =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryRequest(
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
    let summary = buildIgniteRuntimeDefaultPathMutationBoundarySummary(
        rejectedHandoffBoundary
    )

    @Assert(summary.status, "blocked-runtime-default-path-mutation-boundary-summary-input")
    @Assert(summary.action, "block")
    @Assert(summary.runtimeDefaultPathMutationBoundarySummaryAccepted, false)
    @Assert(summary.sourceHandoffBoundaryAccepted, false)
    @Assert(
        summary.summaryAlias,
        "runtime-default-path-boundary-summary-unavailable"
    )
    @Assert(
        summary.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_HANDOFF_BOUNDARY_NOT_ACCEPTED"
    )
    @Assert(summary.runtimeDefaultPathMutationAllowed, false)
}

func runTestRuntimeDefaultPathMutationBoundarySummaryKeepsBlockingIsolationAliasReusableForQuic(): Unit {
    let summary = buildIgniteRuntimeDefaultPathMutationBoundarySummary(
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryReceiptFor(
            "blocking-external-operation"
        )
    )

    @Assert(summary.runtimeDefaultPathMutationBoundarySummaryAccepted, true)
    @Assert(
        summary.summaryAlias,
        "runtime-default-path-boundary-summary:blocking-isolation"
    )
    @Assert(summary.h1H2QuicRuntimeClosureClaimAllowed, false)
    @Assert(
        summary.quicReuseHook,
        "QUIC can reuse the short boundary summary alias for stream runtime mutation preparation without claiming runtime closure"
    )
}

func runTestRuntimeDefaultPathExecutionChainGateRecordsShortSummaryWithoutMutation(): Unit {
    let receipt = buildIgniteRuntimeDefaultPathExecutionChainGateReceipt(
        runtimeDefaultPathMutationBoundarySummaryFor("short-handler"),
        acceptedRuntimeDefaultPathExecutionChainGateRequest()
    )

    @Assert(receipt.status, "accepted-runtime-default-path-execution-chain-gate-receipt")
    @Assert(receipt.action, "record-runtime-default-path-execution-chain-gate")
    @Assert(receipt.executionChainGateAccepted, true)
    @Assert(receipt.boundarySummaryAccepted, true)
    @Assert(
        receipt.summaryAlias,
        "runtime-default-path-boundary-summary:short"
    )
    @Assert(
        receipt.executionChainGateMode,
        "short-runtime-default-path-execution-chain-gate"
    )
    @Assert(receipt.executionChainGateAllowed, true)
    @Assert(receipt.actualDefaultEngineFlipAllowed, false)
    @Assert(receipt.defaultEngineConfigMutationAllowed, false)
    @Assert(receipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(receipt.publicReleaseAllowed, false)
    @Assert(receipt.stdxRemovalAllowed, false)
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestRuntimeDefaultPathExecutionChainGateBlocksRejectedSummary(): Unit {
    let rejectedHandoffBoundary =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryRequest(
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
    let rejectedSummary = buildIgniteRuntimeDefaultPathMutationBoundarySummary(
        rejectedHandoffBoundary
    )
    let receipt = buildIgniteRuntimeDefaultPathExecutionChainGateReceipt(
        rejectedSummary,
        acceptedRuntimeDefaultPathExecutionChainGateRequest()
    )

    @Assert(receipt.status, "blocked-runtime-default-path-boundary-summary")
    @Assert(receipt.action, "block")
    @Assert(receipt.executionChainGateAccepted, false)
    @Assert(receipt.boundarySummaryAccepted, false)
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_BOUNDARY_SUMMARY_NOT_ACCEPTED"
    )
    @Assert(receipt.runtimeDefaultPathMutationAllowed, false)
}

func runTestRuntimeDefaultPathExecutionChainGateBlocksMissingMarkersAndOverclaims(): Unit {
    let receipt = buildIgniteRuntimeDefaultPathExecutionChainGateReceipt(
        runtimeDefaultPathMutationBoundarySummaryFor("long-handler"),
        IgniteRuntimeDefaultPathExecutionChainGateRequest(
            "",
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            true,
            true,
            true,
            true,
            true,
            true
        )
    )

    @Assert(receipt.status, "blocked-runtime-default-path-execution-chain-gate-input")
    @Assert(receipt.executionChainGateAccepted, false)
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_EXECUTION_CHAIN_GATE_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_BOUNDARY_SUMMARY_NOT_CARRIED"
    )
    @Assert(receipt.blockers[2], "SCHEDULER_BOUNDARY_NOT_CARRIED")
    @Assert(receipt.blockers[3], "REQUEST_CONTEXT_GATE_NOT_CARRIED")
    @Assert(receipt.blockers[4], "RESPONSE_WRITE_GATE_NOT_CARRIED")
    @Assert(receipt.blockers[5], "TRANSPORT_COMMIT_GATE_NOT_CARRIED")
    @Assert(receipt.blockers[6], "LIVE_SERVER_WIRING_GATE_NOT_CARRIED")
    @Assert(receipt.blockers[7], "ROLLBACK_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[8], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[9], "ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    @Assert(receipt.blockers[10], "DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    @Assert(receipt.blockers[11], "RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    @Assert(receipt.blockers[12], "PUBLIC_RELEASE_REQUESTED")
    @Assert(receipt.blockers[13], "STDX_REMOVAL_REQUESTED")
    @Assert(receipt.blockers[14], "H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    @Assert(receipt.executionChainGateAllowed, false)
}

func runTestRuntimeDefaultPathExecutionChainGateKeepsBlockingIsolationModeReusableForQuic(): Unit {
    let receipt = runtimeDefaultPathExecutionChainGateReceiptFor(
        "blocking-external-operation"
    )

    @Assert(receipt.executionChainGateAccepted, true)
    @Assert(
        receipt.executionChainGateMode,
        "blocking-isolation-runtime-default-path-execution-chain-gate"
    )
    @Assert(receipt.h1H2QuicRuntimeClosureClaimAllowed, false)
    @Assert(
        receipt.quicReuseHook,
        "QUIC can reuse the execution-chain gate modes before stream runtime default-path apply gates"
    )
}

func runTestRuntimeDefaultPathApplyGateRecordsShortExecutionChainWithoutMutation(): Unit {
    let receipt = buildIgniteRuntimeDefaultPathApplyGateReceipt(
        runtimeDefaultPathExecutionChainGateReceiptFor("short-handler"),
        acceptedRuntimeDefaultPathApplyGateRequest()
    )

    @Assert(receipt.status, "accepted-runtime-default-path-apply-gate-receipt")
    @Assert(receipt.action, "record-runtime-default-path-apply-gate")
    @Assert(receipt.applyGateAccepted, true)
    @Assert(receipt.executionChainGateAccepted, true)
    @Assert(
        receipt.executionChainGateMode,
        "short-runtime-default-path-execution-chain-gate"
    )
    @Assert(
        receipt.applyGateMode,
        "short-runtime-default-path-apply-gate"
    )
    @Assert(receipt.runtimeDefaultPathApplyGateAllowed, true)
    @Assert(receipt.actualDefaultEngineFlipAllowed, false)
    @Assert(receipt.defaultEngineConfigMutationAllowed, false)
    @Assert(receipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(receipt.publicReleaseAllowed, false)
    @Assert(receipt.stdxRemovalAllowed, false)
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestRuntimeDefaultPathApplyGateBlocksRejectedExecutionChain(): Unit {
    let rejectedExecutionChain = buildIgniteRuntimeDefaultPathExecutionChainGateReceipt(
        runtimeDefaultPathMutationBoundarySummaryFor("short-handler"),
        IgniteRuntimeDefaultPathExecutionChainGateRequest(
            "",
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            true,
            true,
            true,
            true,
            true,
            true
        )
    )
    let receipt = buildIgniteRuntimeDefaultPathApplyGateReceipt(
        rejectedExecutionChain,
        acceptedRuntimeDefaultPathApplyGateRequest()
    )

    @Assert(receipt.status, "blocked-runtime-default-path-execution-chain-gate")
    @Assert(receipt.action, "block")
    @Assert(receipt.applyGateAccepted, false)
    @Assert(receipt.executionChainGateAccepted, false)
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_EXECUTION_CHAIN_GATE_NOT_ACCEPTED"
    )
    @Assert(receipt.runtimeDefaultPathMutationAllowed, false)
}

func runTestRuntimeDefaultPathApplyGateBlocksMissingMarkersAndOverclaims(): Unit {
    let receipt = buildIgniteRuntimeDefaultPathApplyGateReceipt(
        runtimeDefaultPathExecutionChainGateReceiptFor("long-handler"),
        IgniteRuntimeDefaultPathApplyGateRequest(
            "",
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            true,
            true,
            true,
            true,
            true,
            true
        )
    )

    @Assert(receipt.status, "blocked-runtime-default-path-apply-gate-input")
    @Assert(receipt.applyGateAccepted, false)
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_APPLY_GATE_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_EXECUTION_CHAIN_GATE_NOT_CARRIED"
    )
    @Assert(receipt.blockers[2], "APPLY_ORDER_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[3], "DRY_RUN_PROOF_NOT_CARRIED")
    @Assert(receipt.blockers[4], "ROLLBACK_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[5], "AUDIT_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OPERATOR_ACKNOWLEDGEMENT_NOT_CARRIED")
    @Assert(receipt.blockers[8], "BLOCKING_ISOLATION_MODE_NOT_PRESERVED")
    @Assert(receipt.blockers[9], "ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    @Assert(receipt.blockers[10], "DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    @Assert(receipt.blockers[11], "RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    @Assert(receipt.blockers[12], "PUBLIC_RELEASE_REQUESTED")
    @Assert(receipt.blockers[13], "STDX_REMOVAL_REQUESTED")
    @Assert(receipt.blockers[14], "H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    @Assert(receipt.runtimeDefaultPathApplyGateAllowed, false)
}

func runTestRuntimeDefaultPathApplyGateKeepsBlockingIsolationModeReusableForQuic(): Unit {
    let receipt = runtimeDefaultPathApplyGateReceiptFor(
        "blocking-external-operation"
    )

    @Assert(receipt.applyGateAccepted, true)
    @Assert(
        receipt.applyGateMode,
        "blocking-isolation-runtime-default-path-apply-gate"
    )
    @Assert(receipt.h1H2QuicRuntimeClosureClaimAllowed, false)
    @Assert(
        receipt.quicReuseHook,
        "QUIC can reuse the apply gate modes before stream runtime default-path apply gates"
    )
}

func runTestControlledRuntimeDefaultPathApplyDryRunRecordsShortApplyGateWithoutMutation(): Unit {
    let receipt = buildIgniteControlledRuntimeDefaultPathApplyDryRunReceipt(
        runtimeDefaultPathApplyGateReceiptFor("short-handler"),
        acceptedControlledRuntimeDefaultPathApplyDryRunRequest()
    )

    @Assert(
        receipt.status,
        "accepted-controlled-runtime-default-path-apply-dry-run-receipt"
    )
    @Assert(
        receipt.action,
        "record-controlled-runtime-default-path-apply-dry-run"
    )
    @Assert(receipt.controlledRuntimeDefaultPathApplyDryRunAccepted, true)
    @Assert(receipt.runtimeDefaultPathApplyGateAccepted, true)
    @Assert(
        receipt.runtimeDefaultPathApplyGateMode,
        "short-runtime-default-path-apply-gate"
    )
    @Assert(
        receipt.controlledRuntimeDefaultPathApplyDryRunMode,
        "short-controlled-runtime-default-path-apply-dry-run"
    )
    @Assert(receipt.controlledRuntimeDefaultPathApplyDryRunAllowed, true)
    @Assert(receipt.actualDefaultEngineFlipAllowed, false)
    @Assert(receipt.defaultEngineConfigMutationAllowed, false)
    @Assert(receipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(receipt.publicReleaseAllowed, false)
    @Assert(receipt.stdxRemovalAllowed, false)
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
}

func runTestControlledRuntimeDefaultPathApplyDryRunBlocksRejectedApplyGate(): Unit {
    let rejectedApplyGate = buildIgniteRuntimeDefaultPathApplyGateReceipt(
        runtimeDefaultPathExecutionChainGateReceiptFor("short-handler"),
        IgniteRuntimeDefaultPathApplyGateRequest(
            "",
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            true,
            true,
            true,
            true,
            true,
            true
        )
    )
    let receipt = buildIgniteControlledRuntimeDefaultPathApplyDryRunReceipt(
        rejectedApplyGate,
        acceptedControlledRuntimeDefaultPathApplyDryRunRequest()
    )

    @Assert(receipt.status, "blocked-runtime-default-path-apply-gate")
    @Assert(receipt.action, "block")
    @Assert(receipt.controlledRuntimeDefaultPathApplyDryRunAccepted, false)
    @Assert(receipt.runtimeDefaultPathApplyGateAccepted, false)
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_APPLY_GATE_NOT_ACCEPTED"
    )
    @Assert(receipt.runtimeDefaultPathMutationAllowed, false)
}

func runTestControlledRuntimeDefaultPathApplyDryRunBlocksMissingMarkersAndOverclaims(): Unit {
    let receipt = buildIgniteControlledRuntimeDefaultPathApplyDryRunReceipt(
        runtimeDefaultPathApplyGateReceiptFor("long-handler"),
        IgniteControlledRuntimeDefaultPathApplyDryRunRequest(
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
        "blocked-controlled-runtime-default-path-apply-dry-run-input"
    )
    @Assert(receipt.controlledRuntimeDefaultPathApplyDryRunAccepted, false)
    @Assert(
        receipt.blockers[0],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_APPLY_DRY_RUN_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_APPLY_GATE_RECEIPT_NOT_CARRIED"
    )
    @Assert(receipt.blockers[2], "CONTROLLED_APPLY_DRY_RUN_SCOPE_NOT_CARRIED")
    @Assert(receipt.blockers[3], "DRY_RUN_EXECUTION_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[4], "CONTROL_PLANE_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[5], "ROLLBACK_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[6], "AUDIT_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "OPERATOR_ACKNOWLEDGEMENT_NOT_CARRIED")
    @Assert(receipt.blockers[9], "BLOCKING_ISOLATION_MODE_NOT_PRESERVED")
    @Assert(receipt.blockers[10], "ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    @Assert(receipt.blockers[11], "DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    @Assert(receipt.blockers[12], "RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    @Assert(receipt.blockers[13], "PUBLIC_RELEASE_REQUESTED")
    @Assert(receipt.blockers[14], "STDX_REMOVAL_REQUESTED")
    @Assert(receipt.blockers[15], "H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    @Assert(receipt.controlledRuntimeDefaultPathApplyDryRunAllowed, false)
}

func runTestControlledRuntimeDefaultPathApplyDryRunKeepsBlockingIsolationModeReusableForQuic(): Unit {
    let receipt = controlledRuntimeDefaultPathApplyDryRunReceiptFor(
        "blocking-external-operation"
    )

    @Assert(receipt.controlledRuntimeDefaultPathApplyDryRunAccepted, true)
    @Assert(
        receipt.controlledRuntimeDefaultPathApplyDryRunMode,
        "blocking-isolation-controlled-runtime-default-path-apply-dry-run"
    )
    @Assert(receipt.h1H2QuicRuntimeClosureClaimAllowed, false)
    @Assert(
        receipt.quicReuseHook,
        "QUIC can reuse the controlled apply dry-run modes before stream runtime default-path staging gates"
    )
}

func runTestA2RuntimeExecutionWiringCloseAcceptsCurrentNonDefaultFlipScope(): Unit {
    let receipt = buildIgniteA2RuntimeExecutionWiringCloseReceipt(
        controlledRuntimeDefaultPathApplyDryRunReceiptFor("short-handler"),
        acceptedA2RuntimeExecutionWiringCloseRequest()
    )

    @Assert(
        receipt.status,
        "accepted-a2-runtime-execution-wiring-close-receipt"
    )
    @Assert(
        receipt.action,
        "record-a2-runtime-execution-wiring-standard-close"
    )
    @Assert(receipt.a2RuntimeExecutionWiringCloseAccepted, true)
    @Assert(receipt.a2ClosedForCurrent0800NonDefaultFlipScope, true)
    @Assert(
        receipt.decision,
        "A2 accepted for current 0800 non-default-flip scope"
    )
    @Assert(
        receipt.a2RuntimeExecutionWiringCloseMode,
        "short-a2-runtime-execution-wiring-close"
    )
    @Assert(
        receipt.acceptedSurfaces[0],
        "production-queue-mutation-boundary"
    )
    @Assert(
        receipt.acceptedSurfaces[8],
        "default-path-apply-dry-run-boundary"
    )
    @Assert(
        receipt.unverifiedRuntimeProofs[0],
        "ACTUAL_RUNTIME_TASK_SPAWN_NOT_CLAIMED"
    )
    @Assert(receipt.actualDefaultEngineFlipAllowed, false)
    @Assert(receipt.defaultEngineConfigMutationAllowed, false)
    @Assert(receipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(receipt.stdxRemovalAllowed, false)
    @Assert(receipt.h2RuntimeClosureClaimAllowed, false)
    @Assert(receipt.nonClaims[2], "NO_RUNTIME_DEFAULT_PATH_MUTATION")
    @Assert(
        receipt.nextMacroTarget,
        "return-to-ig0800-big-order-queue-with-fresh-standard-packet"
    )
}

func runTestA2RuntimeExecutionWiringCloseBlocksRejectedControlledApplyDryRun(): Unit {
    let rejectedControlledApplyDryRun =
        buildIgniteControlledRuntimeDefaultPathApplyDryRunReceipt(
            runtimeDefaultPathApplyGateReceiptFor("short-handler"),
            IgniteControlledRuntimeDefaultPathApplyDryRunRequest(
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
                true,
                true,
                true,
                true,
                true,
                true
            )
        )
    let receipt = buildIgniteA2RuntimeExecutionWiringCloseReceipt(
        rejectedControlledApplyDryRun,
        acceptedA2RuntimeExecutionWiringCloseRequest()
    )

    @Assert(
        receipt.status,
        "blocked-controlled-runtime-default-path-apply-dry-run"
    )
    @Assert(receipt.action, "block")
    @Assert(receipt.a2RuntimeExecutionWiringCloseAccepted, false)
    @Assert(
        receipt.blockers[0],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_APPLY_DRY_RUN_NOT_ACCEPTED"
    )
    @Assert(receipt.a2ClosedForCurrent0800NonDefaultFlipScope, false)
}

func runTestA2RuntimeExecutionWiringCloseBlocksMissingSurfacesAndOverclaims(): Unit {
    let receipt = buildIgniteA2RuntimeExecutionWiringCloseReceipt(
        controlledRuntimeDefaultPathApplyDryRunReceiptFor("long-handler"),
        IgniteA2RuntimeExecutionWiringCloseRequest(
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
            true,
            true,
            true,
            true,
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
        "blocked-a2-runtime-execution-wiring-close-input"
    )
    @Assert(receipt.a2RuntimeExecutionWiringCloseAccepted, false)
    @Assert(
        receipt.blockers[0],
        "A2_RUNTIME_EXECUTION_WIRING_CLOSE_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "CONTROLLED_APPLY_DRY_RUN_RECEIPT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "PRODUCTION_QUEUE_MUTATION_BOUNDARY_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[10],
        "DEFAULT_PATH_APPLY_DRY_RUN_BOUNDARY_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[15],
        "ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED"
    )
    @Assert(receipt.blockers[18], "STDX_REMOVAL_REQUESTED")
    @Assert(receipt.blockers[20], "H2_RUNTIME_CLOSURE_CLAIMED")
    @Assert(
        receipt.blockers[27],
        "SOURCE_OWNED_HAOMONAV_INGEST_CLAIMED"
    )
    @Assert(receipt.blockers[28], "OD_AUDIT_ACCEPTANCE_CLAIMED")
    @Assert(receipt.runtimeExecutionWiringCloseAllowed, false)
}

func runTestA2RuntimeExecutionWiringCloseKeepsBlockingIsolationReusableForQuic(): Unit {
    let receipt = a2RuntimeExecutionWiringCloseReceiptFor(
        "blocking-external-operation"
    )

    @Assert(receipt.a2RuntimeExecutionWiringCloseAccepted, true)
    @Assert(
        receipt.a2RuntimeExecutionWiringCloseMode,
        "blocking-isolation-a2-runtime-execution-wiring-close"
    )
    @Assert(receipt.h2RuntimeClosureClaimAllowed, false)
    @Assert(
        receipt.quicReuseHook,
        "QUIC can reuse the A2 close matrix as execution-wiring prior art without claiming H1/H2/QUIC runtime closure"
    )
}

func runTestStdxReplacementClaimGateRecordsInventoryOnly(): Unit {
    let receipt = buildIgniteStdxReplacementClaimGateReceipt(
        IgniteStdxReplacementClaimGateRequest(
            "stdx-replacement-gate-inventory",
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
            true,
            false,
            false,
            false,
            false,
            false
        )
    )

    @Assert(receipt.status, "accepted-stdx-replacement-inventory-receipt")
    @Assert(receipt.action, "record-stdx-replacement-inventory")
    @Assert(receipt.claimMode, "inventory-only-stdx-replacement-gate")
    @Assert(receipt.stdxReplacementClaimGateAccepted, true)
    @Assert(receipt.runtimeStdxReplacementClaimAllowed, false)
    @Assert(receipt.sourceZeroStdxClaimAllowed, false)
    @Assert(receipt.stdxRemovalAllowed, false)
    @Assert(receipt.nonClaims[0], "NO_STDX_DEPENDENCY_REMOVAL")
}

func runTestStdxReplacementClaimGateBlocksRuntimeClaimUntilRuntimeProofsExist(): Unit {
    let receipt = buildIgniteStdxReplacementClaimGateReceipt(
        IgniteStdxReplacementClaimGateRequest(
            "stdx-replacement-gate-runtime",
            true,
            true,
            false,
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
            true,
            false,
            true,
            false,
            false,
            false
        )
    )

    @Assert(receipt.status, "blocked-stdx-replacement-claim-input")
    @Assert(receipt.action, "block")
    @Assert(receipt.claimMode, "runtime-stdx-replacement-claim-gate")
    @Assert(receipt.stdxReplacementClaimGateAccepted, false)
    @Assert(receipt.blockers[0], "H1_CLIENT_NATIVE_PROOF_NOT_CARRIED")
    @Assert(receipt.blockers[1], "H2_SERVER_RUNTIME_CLOSURE_PROOF_NOT_CARRIED")
    @Assert(receipt.blockers[2], "H2_CLIENT_NATIVE_PROOF_NOT_CARRIED")
    @Assert(receipt.blockers[3], "JINGUISSL_TLS_PROVIDER_PROOF_NOT_CARRIED")
    @Assert(receipt.blockers[4], "IODRIVER_BACKEND_PROOF_NOT_CARRIED")
    @Assert(receipt.blockers[5], "PROXY_TRANSPORT_NATIVE_PROOF_NOT_CARRIED")
    @Assert(receipt.runtimeStdxReplacementClaimAllowed, false)
}

func runTestStdxReplacementClaimGateBlocksSourceZeroClaimUntilUtilitySurfacesAreReplaced(): Unit {
    let receipt = buildIgniteStdxReplacementClaimGateReceipt(
        IgniteStdxReplacementClaimGateRequest(
            "stdx-replacement-gate-source-zero",
            true,
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
            true,
            false,
            true,
            true,
            false,
            false
        )
    )

    @Assert(receipt.status, "blocked-stdx-replacement-claim-input")
    @Assert(receipt.claimMode, "source-zero-stdx-replacement-claim-gate")
    @Assert(receipt.blockers[0], "SEAJSON_BRIDGE_PROOF_NOT_CARRIED")
    @Assert(receipt.blockers[1], "COMPRESSION_NATIVE_PROOF_NOT_CARRIED")
    @Assert(receipt.blockers[2], "WEBSOCKET_NATIVE_PROOF_NOT_CARRIED")
    @Assert(receipt.sourceZeroStdxClaimAllowed, false)
    @Assert(receipt.stdxRemovalAllowed, false)
}

func runTestStdxReplacementClaimGateAllowsRemovalClaimOnlyAsEvidenceGate(): Unit {
    let receipt = buildIgniteStdxReplacementClaimGateReceipt(
        acceptedStdxReplacementClaimGateRequest()
    )

    @Assert(receipt.status, "accepted-stdx-replacement-claim-gate-receipt")
    @Assert(receipt.claimMode, "source-zero-stdx-removal-claim-gate")
    @Assert(receipt.stdxReplacementClaimGateAccepted, true)
    @Assert(receipt.runtimeStdxReplacementClaimAllowed, true)
    @Assert(receipt.sourceZeroStdxClaimAllowed, true)
    @Assert(receipt.publicReleaseClaimAllowed, true)
    @Assert(receipt.stdxRemovalAllowed, true)
    @Assert(
        receipt.decision,
        "replacement-claim-gate-ready-without-mutating-dependencies"
    )
    @Assert(receipt.nonClaims[1], "NO_DEFAULT_ENGINE_FLIP")
}
