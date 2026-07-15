package ignite.tests

import std.unittest.*
import std.unittest.testmacro.*
import ignite.*

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateRequest(
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
        "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-closeout-gate-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_CLOSEOUT_GATE_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_BOUNDARY_RECEIPT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[3],
        "APPLY_DRY_RUN_ACCEPTANCE_CLOSEOUT_GATE_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[4],
        "DOWNSTREAM_CONSUMER_BOUNDARY_NOT_CARRIED"
    )
    @Assert(receipt.blockers[5], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "CLOSEOUT_AUDIT_MARKER_NOT_CARRIED")
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateRecorded,
        false
    )
}
func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-apply-dry-run-acceptance-closeout-gate-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateMode,
        "short-runtime-default-path-mutation-apply-dry-run-acceptance-closeout-gate"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateMode,
        "long-runtime-default-path-mutation-apply-dry-run-acceptance-closeout-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateMode,
        "blocking-isolation-runtime-default-path-mutation-apply-dry-run-acceptance-closeout-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.applyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateRecorded,
        true
    )
}

func runTestControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBlocksRejectedCloseoutGate(): Unit {
    let rejectedCloseoutGate =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateRequest(
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
        buildIgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffReceipt(
            rejectedCloseoutGate,
            acceptedControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-closeout-gate-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_CLOSEOUT_GATE_NOT_ACCEPTED"
    )
}

func runTestControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateReceiptFor(
                "short-handler"
            ),
            IgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffRequest(
                "controlled-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAccepted,
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

func runTestControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateReceiptFor(
                "long-handler"
            ),
            IgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffRequest(
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
        "blocked-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-input"
    )
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_CLOSEOUT_GATE_RECEIPT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[3],
        "CONTROLLED_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[4],
        "DOWNSTREAM_CONSUMER_BOUNDARY_NOT_CARRIED"
    )
    @Assert(receipt.blockers[5], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "HANDOFF_AUDIT_MARKER_NOT_CARRIED")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffRecorded,
        false
    )
}

func runTestControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateReceiptFor(
                "short-handler"
            ),
            acceptedControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffRequest()
        )
    let longReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateReceiptFor(
                "long-handler"
            ),
            acceptedControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffRequest()
        )
    let blockingReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateReceiptFor(
                "blocking-external-operation"
            ),
            acceptedControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-receipt"
    )
    @Assert(
        shortReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffMode,
        "short-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-handoff"
    )
    @Assert(
        longReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffMode,
        "long-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-handoff"
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffMode,
        "blocking-isolation-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-handoff"
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAccepted,
        true
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.applyDryRunAcceptanceCloseoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateRecorded,
        true
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffRecorded,
        true
    )
}

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryBlocksRejectedControlledHandoff(): Unit {
    let rejectedControlledHandoff =
        buildIgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateReceiptFor(
                "short-handler"
            ),
            IgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffRequest(
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
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceipt(
            rejectedControlledHandoff,
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryRequest()
        )

    @Assert(
        receipt.status,
        "blocked-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAccepted,
        false
    )
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceipt(
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryRequest(
                "runtime-default-path-mutation-apply-dry-run-acceptance-handoff-boundary-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-boundary-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAccepted,
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

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceipt(
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryRequest(
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
        "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-boundary-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_BOUNDARY_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_RECEIPT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[3],
        "APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_BOUNDARY_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[4],
        "DOWNSTREAM_CONSUMER_BOUNDARY_NOT_CARRIED"
    )
    @Assert(receipt.blockers[5], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "BOUNDARY_AUDIT_MARKER_NOT_CARRIED")
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceipt(
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceipt(
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceipt(
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-boundary-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryMode,
        "short-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-boundary"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryMode,
        "long-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryMode,
        "blocking-isolation-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.controlledApplyDryRunAcceptanceHandoffReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryRecorded,
        true
    )
}

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryBlocksRejectedHandoffBoundary(): Unit {
    let rejectedHandoffBoundary =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceipt(
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryRequest(
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
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceipt(
            rejectedHandoffBoundary,
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-boundary-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_BOUNDARY_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryRequest(
                "runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAccepted,
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

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryRequest(
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
        "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_BOUNDARY_RECEIPT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[3],
        "APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[4],
        "DOWNSTREAM_CONSUMER_BOUNDARY_NOT_CARRIED"
    )
    @Assert(receipt.blockers[5], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "BOUNDARY_AUDIT_MARKER_NOT_CARRIED")
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryMode,
        "short-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryMode,
        "long-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryMode,
        "blocking-isolation-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryRecorded,
        true
    )
}

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateBlocksRejectedApplyBoundary(): Unit {
    let rejectedApplyBoundary =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryRequest(
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
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceipt(
            rejectedApplyBoundary,
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateRequest(
                "runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAccepted,
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

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateRequest(
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
        "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_RECEIPT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[3],
        "APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[4],
        "DOWNSTREAM_CONSUMER_BOUNDARY_NOT_CARRIED"
    )
    @Assert(receipt.blockers[5], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "BOUNDARY_AUDIT_MARKER_NOT_CARRIED")
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateMode,
        "short-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateMode,
        "long-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateMode,
        "blocking-isolation-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateRecorded,
        true
    )
}

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBlocksRejectedGate(): Unit {
    let rejectedGate =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateRequest(
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
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceipt(
            rejectedGate,
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutRequest(
                "runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAccepted,
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

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutRequest(
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
        "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_RECEIPT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[3],
        "APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_NOT_CARRIED"
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
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutMode,
        "short-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutMode,
        "long-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutMode,
        "blocking-isolation-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutRecorded,
        true
    )
}

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryBlocksRejectedCloseout(): Unit {
    let rejectedCloseout =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutRequest(
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
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceipt(
            rejectedCloseout,
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryRequest(
                "runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAccepted,
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

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryRequest(
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
        "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_RECEIPT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[3],
        "APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_NOT_CARRIED"
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
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryMode,
        "short-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryMode,
        "long-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryMode,
        "blocking-isolation-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryRecorded,
        true
    )
}

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateBlocksRejectedBoundary(): Unit {
    let rejectedBoundary =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryRequest(
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
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateReceipt(
            rejectedBoundary,
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateRequest(
                "runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-gate-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-gate-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateAccepted,
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

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateRequest(
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
        "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-gate-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_RECEIPT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[3],
        "APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_NOT_CARRIED"
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
    @Assert(receipt.blockers[11], "CLOSEOUT_BOUNDARY_GATE_MARKER_NOT_CARRIED")
    @Assert(
        receipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-gate-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateMode,
        "short-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-gate"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateMode,
        "long-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateMode,
        "blocking-isolation-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateRecorded,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationGateBlocksRejectedCloseoutBoundaryGate(): Unit {
    let rejectedCloseoutBoundaryGate =
        buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateRequest(
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
        buildIgniteRuntimeDefaultPathMutationPreparationGateReceipt(
            rejectedCloseoutBoundaryGate,
            acceptedRuntimeDefaultPathMutationPreparationGateRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-gate-upstream-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(receipt.runtimeDefaultPathMutationPreparationGateAccepted, false)
    @Assert(receipt.closeoutBoundaryGateAccepted, false)
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_CLOSEOUT_BOUNDARY_GATE_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationGateRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationGateReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationGateRequest(
                "runtime-default-path-mutation-preparation-gate-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-gate-input"
    )
    @Assert(receipt.action, "block")
    @Assert(receipt.runtimeDefaultPathMutationPreparationGateAccepted, false)
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

func runTestRuntimeDefaultPathMutationPreparationGateBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationGateReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationGateRequest(
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
        "blocked-runtime-default-path-mutation-preparation-gate-input"
    )
    @Assert(receipt.runtimeDefaultPathMutationPreparationGateAccepted, false)
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_GATE_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_CLOSEOUT_BOUNDARY_GATE_RECEIPT_NOT_CARRIED"
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
    @Assert(receipt.runtimeDefaultPathMutationPreparationGateRecorded, false)
}

func runTestRuntimeDefaultPathMutationPreparationGateMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationGateReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationGateRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationGateReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationGateRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationGateReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationGateRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-gate-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationGateMode,
        "short-runtime-default-path-mutation-preparation-gate"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationGateMode,
        "long-runtime-default-path-mutation-preparation-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationGateMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-gate"
    )
    @Assert(blockingReceipt.runtimeDefaultPathMutationPreparationGateAccepted, true)
    @Assert(blockingReceipt.runtimeDefaultPathMutationPreparationGateAllowed, true)
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.closeoutBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateRecorded,
        true
    )
    @Assert(blockingReceipt.runtimeDefaultPathMutationPreparationGateRecorded, true)
}

func runTestRuntimeDefaultPathMutationPreparationBoundaryBlocksRejectedPreparationGate(): Unit {
    let rejectedPreparationGate =
        buildIgniteRuntimeDefaultPathMutationPreparationGateReceipt(
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationGateRequest(
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
        buildIgniteRuntimeDefaultPathMutationPreparationBoundaryReceipt(
            rejectedPreparationGate,
            acceptedRuntimeDefaultPathMutationPreparationBoundaryRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-boundary-upstream-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(receipt.runtimeDefaultPathMutationPreparationBoundaryAccepted, false)
    @Assert(receipt.preparationGateAccepted, false)
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_GATE_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationBoundaryRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationBoundaryReceipt(
            runtimeDefaultPathMutationPreparationGateReceiptFor("short-handler"),
            IgniteRuntimeDefaultPathMutationPreparationBoundaryRequest(
                "runtime-default-path-mutation-preparation-boundary-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-boundary-input"
    )
    @Assert(receipt.action, "block")
    @Assert(receipt.runtimeDefaultPathMutationPreparationBoundaryAccepted, false)
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

func runTestRuntimeDefaultPathMutationPreparationBoundaryBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationBoundaryReceipt(
            runtimeDefaultPathMutationPreparationGateReceiptFor("long-handler"),
            IgniteRuntimeDefaultPathMutationPreparationBoundaryRequest(
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
        "blocked-runtime-default-path-mutation-preparation-boundary-input"
    )
    @Assert(receipt.runtimeDefaultPathMutationPreparationBoundaryAccepted, false)
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_BOUNDARY_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_GATE_RECEIPT_NOT_CARRIED"
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
    @Assert(receipt.runtimeDefaultPathMutationPreparationBoundaryRecorded, false)
}

func runTestRuntimeDefaultPathMutationPreparationBoundaryMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationBoundaryReceipt(
            runtimeDefaultPathMutationPreparationGateReceiptFor("short-handler"),
            acceptedRuntimeDefaultPathMutationPreparationBoundaryRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationBoundaryReceipt(
            runtimeDefaultPathMutationPreparationGateReceiptFor("long-handler"),
            acceptedRuntimeDefaultPathMutationPreparationBoundaryRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationBoundaryReceipt(
            runtimeDefaultPathMutationPreparationGateReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationBoundaryRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-boundary-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationBoundaryMode,
        "short-runtime-default-path-mutation-preparation-boundary"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationBoundaryMode,
        "long-runtime-default-path-mutation-preparation-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationBoundaryMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationBoundaryAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationBoundaryAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.preparationGateReceipt.runtimeDefaultPathMutationPreparationGateRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationBoundaryRecorded,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationDryRunBlocksRejectedPreparationBoundary(): Unit {
    let rejectedPreparationBoundary =
        buildIgniteRuntimeDefaultPathMutationPreparationBoundaryReceipt(
            runtimeDefaultPathMutationPreparationGateReceiptFor("short-handler"),
            IgniteRuntimeDefaultPathMutationPreparationBoundaryRequest(
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
        buildIgniteRuntimeDefaultPathMutationPreparationDryRunReceipt(
            rejectedPreparationBoundary,
            acceptedRuntimeDefaultPathMutationPreparationDryRunRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-dry-run-upstream-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(receipt.runtimeDefaultPathMutationPreparationDryRunAccepted, false)
    @Assert(receipt.preparationBoundaryAccepted, false)
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_BOUNDARY_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationDryRunRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationDryRunReceipt(
            runtimeDefaultPathMutationPreparationBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationDryRunRequest(
                "runtime-default-path-mutation-preparation-dry-run-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-dry-run-input"
    )
    @Assert(receipt.action, "block")
    @Assert(receipt.runtimeDefaultPathMutationPreparationDryRunAccepted, false)
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

func runTestRuntimeDefaultPathMutationPreparationDryRunBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationDryRunReceipt(
            runtimeDefaultPathMutationPreparationBoundaryReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationDryRunRequest(
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
        "blocked-runtime-default-path-mutation-preparation-dry-run-input"
    )
    @Assert(receipt.runtimeDefaultPathMutationPreparationDryRunAccepted, false)
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_DRY_RUN_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_BOUNDARY_RECEIPT_NOT_CARRIED"
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
    @Assert(receipt.runtimeDefaultPathMutationPreparationDryRunRecorded, false)
}

func runTestRuntimeDefaultPathMutationPreparationDryRunMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationDryRunReceipt(
            runtimeDefaultPathMutationPreparationBoundaryReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationDryRunRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationDryRunReceipt(
            runtimeDefaultPathMutationPreparationBoundaryReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationDryRunRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationDryRunReceipt(
            runtimeDefaultPathMutationPreparationBoundaryReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationDryRunRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-dry-run-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationDryRunMode,
        "short-runtime-default-path-mutation-preparation-dry-run"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationDryRunMode,
        "long-runtime-default-path-mutation-preparation-dry-run"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationDryRunMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-dry-run"
    )
    @Assert(blockingReceipt.runtimeDefaultPathMutationPreparationDryRunAccepted, true)
    @Assert(blockingReceipt.runtimeDefaultPathMutationPreparationDryRunAllowed, true)
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationBoundaryRecorded,
        true
    )
    @Assert(blockingReceipt.runtimeDefaultPathMutationPreparationDryRunRecorded, true)
}

func runTestRuntimeDefaultPathMutationPreparationApplyGateBlocksRejectedPreparationDryRun(): Unit {
    let rejectedPreparationDryRun =
        buildIgniteRuntimeDefaultPathMutationPreparationDryRunReceipt(
            runtimeDefaultPathMutationPreparationBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationDryRunRequest(
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
        buildIgniteRuntimeDefaultPathMutationPreparationApplyGateReceipt(
            rejectedPreparationDryRun,
            acceptedRuntimeDefaultPathMutationPreparationApplyGateRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-gate-upstream-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(receipt.runtimeDefaultPathMutationPreparationApplyGateAccepted, false)
    @Assert(receipt.preparationDryRunAccepted, false)
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_DRY_RUN_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyGateRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyGateReceipt(
            runtimeDefaultPathMutationPreparationDryRunReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyGateRequest(
                "runtime-default-path-mutation-preparation-apply-gate-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-apply-gate-input"
    )
    @Assert(receipt.action, "block")
    @Assert(receipt.runtimeDefaultPathMutationPreparationApplyGateAccepted, false)
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

func runTestRuntimeDefaultPathMutationPreparationApplyGateBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyGateReceipt(
            runtimeDefaultPathMutationPreparationDryRunReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyGateRequest(
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
        "blocked-runtime-default-path-mutation-preparation-apply-gate-input"
    )
    @Assert(receipt.runtimeDefaultPathMutationPreparationApplyGateAccepted, false)
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_GATE_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_DRY_RUN_RECEIPT_NOT_CARRIED"
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
    @Assert(receipt.runtimeDefaultPathMutationPreparationApplyGateRecorded, false)
}

func runTestRuntimeDefaultPathMutationPreparationApplyGateMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyGateReceipt(
            runtimeDefaultPathMutationPreparationDryRunReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyGateRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyGateReceipt(
            runtimeDefaultPathMutationPreparationDryRunReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyGateRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyGateReceipt(
            runtimeDefaultPathMutationPreparationDryRunReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyGateRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-apply-gate-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationApplyGateMode,
        "short-runtime-default-path-mutation-preparation-apply-gate"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationApplyGateMode,
        "long-runtime-default-path-mutation-preparation-apply-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyGateMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyGateAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyGateAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.preparationDryRunReceipt.runtimeDefaultPathMutationPreparationDryRunRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyGateRecorded,
        true
    )
}

func runTestControlledRuntimeDefaultPathMutationPreparationApplyBlocksRejectedPreparationApplyGate(): Unit {
    let rejectedPreparationApplyGate =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyGateReceipt(
            runtimeDefaultPathMutationPreparationDryRunReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyGateRequest(
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
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyReceipt(
            rejectedPreparationApplyGate,
            acceptedControlledRuntimeDefaultPathMutationPreparationApplyRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-gate-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationApplyAccepted,
        false
    )
    @Assert(receipt.preparationApplyGateAccepted, false)
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_GATE_NOT_ACCEPTED"
    )
}

func runTestControlledRuntimeDefaultPathMutationPreparationApplyRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyReceipt(
            runtimeDefaultPathMutationPreparationApplyGateReceiptFor(
                "short-handler"
            ),
            IgniteControlledRuntimeDefaultPathMutationPreparationApplyRequest(
                "controlled-runtime-default-path-mutation-preparation-apply-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-controlled-runtime-default-path-mutation-preparation-apply-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationApplyAccepted,
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

func runTestControlledRuntimeDefaultPathMutationPreparationApplyBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyReceipt(
            runtimeDefaultPathMutationPreparationApplyGateReceiptFor(
                "long-handler"
            ),
            IgniteControlledRuntimeDefaultPathMutationPreparationApplyRequest(
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
        "blocked-controlled-runtime-default-path-mutation-preparation-apply-input"
    )
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationApplyAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_GATE_RECEIPT_NOT_CARRIED"
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
        receipt.controlledRuntimeDefaultPathMutationPreparationApplyRecorded,
        false
    )
}

func runTestControlledRuntimeDefaultPathMutationPreparationApplyMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyReceipt(
            runtimeDefaultPathMutationPreparationApplyGateReceiptFor(
                "short-handler"
            ),
            acceptedControlledRuntimeDefaultPathMutationPreparationApplyRequest()
        )
    let longReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyReceipt(
            runtimeDefaultPathMutationPreparationApplyGateReceiptFor(
                "long-handler"
            ),
            acceptedControlledRuntimeDefaultPathMutationPreparationApplyRequest()
        )
    let blockingReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyReceipt(
            runtimeDefaultPathMutationPreparationApplyGateReceiptFor(
                "blocking-external-operation"
            ),
            acceptedControlledRuntimeDefaultPathMutationPreparationApplyRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-controlled-runtime-default-path-mutation-preparation-apply-receipt"
    )
    @Assert(
        shortReceipt.controlledRuntimeDefaultPathMutationPreparationApplyMode,
        "short-controlled-runtime-default-path-mutation-preparation-apply"
    )
    @Assert(
        longReceipt.controlledRuntimeDefaultPathMutationPreparationApplyMode,
        "long-controlled-runtime-default-path-mutation-preparation-apply"
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationPreparationApplyMode,
        "blocking-isolation-controlled-runtime-default-path-mutation-preparation-apply"
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationPreparationApplyAccepted,
        true
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationPreparationApplyAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyGateRecorded,
        true
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationPreparationApplyRecorded,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationCommitPlanBlocksRejectedControlledPreparationApply(): Unit {
    let rejectedControlledPreparationApply =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyReceipt(
            runtimeDefaultPathMutationPreparationApplyGateReceiptFor(
                "short-handler"
            ),
            IgniteControlledRuntimeDefaultPathMutationPreparationApplyRequest(
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
        buildIgniteRuntimeDefaultPathMutationPreparationCommitPlanReceipt(
            rejectedControlledPreparationApply,
            acceptedRuntimeDefaultPathMutationPreparationCommitPlanRequest()
        )

    @Assert(
        receipt.status,
        "blocked-controlled-runtime-default-path-mutation-preparation-apply-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationCommitPlanAccepted,
        false
    )
    @Assert(receipt.controlledPreparationApplyAccepted, false)
    @Assert(
        receipt.blockers[0],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationCommitPlanRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationCommitPlanReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationCommitPlanRequest(
                "runtime-default-path-mutation-preparation-commit-plan-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-commit-plan-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationCommitPlanAccepted,
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

func runTestRuntimeDefaultPathMutationPreparationCommitPlanBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationCommitPlanReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationCommitPlanRequest(
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
        "blocked-runtime-default-path-mutation-preparation-commit-plan-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationCommitPlanAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_PLAN_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_RECEIPT_NOT_CARRIED"
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
        receipt.runtimeDefaultPathMutationPreparationCommitPlanRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationCommitPlanMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationCommitPlanReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationCommitPlanRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationCommitPlanReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationCommitPlanRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationCommitPlanReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationCommitPlanRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-commit-plan-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationCommitPlanMode,
        "short-runtime-default-path-mutation-preparation-commit-plan"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationCommitPlanMode,
        "long-runtime-default-path-mutation-preparation-commit-plan"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationCommitPlanMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-commit-plan"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationCommitPlanAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationCommitPlanAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.controlledPreparationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationCommitPlanRecorded,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationCommitDryRunBlocksRejectedPreparationCommitPlan(): Unit {
    let rejectedPreparationCommitPlan =
        buildIgniteRuntimeDefaultPathMutationPreparationCommitPlanReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationCommitPlanRequest(
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
        buildIgniteRuntimeDefaultPathMutationPreparationCommitDryRunReceipt(
            rejectedPreparationCommitPlan,
            acceptedRuntimeDefaultPathMutationPreparationCommitDryRunRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-commit-plan-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationCommitDryRunAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationCommitPlanAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_PLAN_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationCommitDryRunRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationCommitDryRunReceipt(
            runtimeDefaultPathMutationPreparationCommitPlanReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationCommitDryRunRequest(
                "runtime-default-path-mutation-preparation-commit-dry-run-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-commit-dry-run-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationCommitDryRunAccepted,
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

func runTestRuntimeDefaultPathMutationPreparationCommitDryRunBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationCommitDryRunReceipt(
            runtimeDefaultPathMutationPreparationCommitPlanReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationCommitDryRunRequest(
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
        "blocked-runtime-default-path-mutation-preparation-commit-dry-run-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationCommitDryRunAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_DRY_RUN_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_PLAN_SNAPSHOT_NOT_CARRIED"
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
        receipt.runtimeDefaultPathMutationPreparationCommitDryRunRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationCommitDryRunMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationCommitDryRunReceipt(
            runtimeDefaultPathMutationPreparationCommitPlanReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationCommitDryRunRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationCommitDryRunReceipt(
            runtimeDefaultPathMutationPreparationCommitPlanReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationCommitDryRunRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationCommitDryRunReceipt(
            runtimeDefaultPathMutationPreparationCommitPlanReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationCommitDryRunRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-commit-dry-run-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationCommitDryRunMode,
        "short-runtime-default-path-mutation-preparation-commit-dry-run"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationCommitDryRunMode,
        "long-runtime-default-path-mutation-preparation-commit-dry-run"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationCommitDryRunMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-commit-dry-run"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationCommitDryRunAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationCommitDryRunAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.preparationCommitPlanReceipt.runtimeDefaultPathMutationPreparationCommitPlanRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationCommitDryRunRecorded,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationCommitApplyGateBlocksRejectedPreparationCommitDryRun(): Unit {
    let rejectedPreparationCommitPlan =
        buildIgniteRuntimeDefaultPathMutationPreparationCommitPlanReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationCommitPlanRequest(
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
    let rejectedDryRun =
        buildIgniteRuntimeDefaultPathMutationPreparationCommitDryRunReceipt(
            rejectedPreparationCommitPlan,
            acceptedRuntimeDefaultPathMutationPreparationCommitDryRunRequest()
        )
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationCommitApplyGateReceipt(
            rejectedDryRun,
            acceptedRuntimeDefaultPathMutationPreparationCommitApplyGateRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-commit-dry-run-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationCommitApplyGateAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationCommitDryRunAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_DRY_RUN_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationCommitApplyGateRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationCommitApplyGateReceipt(
            runtimeDefaultPathMutationPreparationCommitDryRunReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationCommitApplyGateRequest(
                "runtime-default-path-mutation-preparation-commit-apply-gate-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-commit-apply-gate-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationCommitApplyGateAccepted,
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

func runTestRuntimeDefaultPathMutationPreparationCommitApplyGateBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationCommitApplyGateReceipt(
            runtimeDefaultPathMutationPreparationCommitDryRunReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationCommitApplyGateRequest(
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
        "blocked-runtime-default-path-mutation-preparation-commit-apply-gate-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationCommitApplyGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_APPLY_GATE_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_DRY_RUN_SNAPSHOT_NOT_CARRIED"
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
        receipt.runtimeDefaultPathMutationPreparationCommitApplyGateRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationCommitApplyGateMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationCommitApplyGateReceipt(
            runtimeDefaultPathMutationPreparationCommitDryRunReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationCommitApplyGateRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationCommitApplyGateReceipt(
            runtimeDefaultPathMutationPreparationCommitDryRunReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationCommitApplyGateRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationCommitApplyGateReceipt(
            runtimeDefaultPathMutationPreparationCommitDryRunReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationCommitApplyGateRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-commit-apply-gate-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateMode,
        "short-runtime-default-path-mutation-preparation-commit-apply-gate"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateMode,
        "long-runtime-default-path-mutation-preparation-commit-apply-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-commit-apply-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.preparationCommitDryRunReceipt.runtimeDefaultPathMutationPreparationCommitDryRunRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateRecorded,
        true
    )
}

func runTestControlledRuntimeDefaultPathMutationPreparationCommitApplyBlocksRejectedPreparationCommitApplyGate(): Unit {
    let rejectedPreparationCommitPlan =
        buildIgniteRuntimeDefaultPathMutationPreparationCommitPlanReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationCommitPlanRequest(
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
    let rejectedDryRun =
        buildIgniteRuntimeDefaultPathMutationPreparationCommitDryRunReceipt(
            rejectedPreparationCommitPlan,
            acceptedRuntimeDefaultPathMutationPreparationCommitDryRunRequest()
        )
    let rejectedApplyGate =
        buildIgniteRuntimeDefaultPathMutationPreparationCommitApplyGateReceipt(
            rejectedDryRun,
            acceptedRuntimeDefaultPathMutationPreparationCommitApplyGateRequest()
        )
    let receipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationCommitApplyReceipt(
            rejectedApplyGate,
            acceptedControlledRuntimeDefaultPathMutationPreparationCommitApplyRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-commit-apply-gate-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationCommitApplyGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_APPLY_GATE_NOT_ACCEPTED"
    )
}

func runTestControlledRuntimeDefaultPathMutationPreparationCommitApplyRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationCommitApplyReceipt(
            runtimeDefaultPathMutationPreparationCommitApplyGateReceiptFor(
                "short-handler"
            ),
            IgniteControlledRuntimeDefaultPathMutationPreparationCommitApplyRequest(
                "controlled-runtime-default-path-mutation-preparation-commit-apply-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-controlled-runtime-default-path-mutation-preparation-commit-apply-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyAccepted,
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

func runTestControlledRuntimeDefaultPathMutationPreparationCommitApplyBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationCommitApplyReceipt(
            runtimeDefaultPathMutationPreparationCommitApplyGateReceiptFor(
                "long-handler"
            ),
            IgniteControlledRuntimeDefaultPathMutationPreparationCommitApplyRequest(
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
        "blocked-controlled-runtime-default-path-mutation-preparation-commit-apply-input"
    )
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_APPLY_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_APPLY_GATE_SNAPSHOT_NOT_CARRIED"
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
        receipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyRecorded,
        false
    )
}

func runTestControlledRuntimeDefaultPathMutationPreparationCommitApplyMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationCommitApplyReceipt(
            runtimeDefaultPathMutationPreparationCommitApplyGateReceiptFor(
                "short-handler"
            ),
            acceptedControlledRuntimeDefaultPathMutationPreparationCommitApplyRequest()
        )
    let longReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationCommitApplyReceipt(
            runtimeDefaultPathMutationPreparationCommitApplyGateReceiptFor(
                "long-handler"
            ),
            acceptedControlledRuntimeDefaultPathMutationPreparationCommitApplyRequest()
        )
    let blockingReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationCommitApplyReceipt(
            runtimeDefaultPathMutationPreparationCommitApplyGateReceiptFor(
                "blocking-external-operation"
            ),
            acceptedControlledRuntimeDefaultPathMutationPreparationCommitApplyRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-controlled-runtime-default-path-mutation-preparation-commit-apply-receipt"
    )
    @Assert(
        shortReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyMode,
        "short-controlled-runtime-default-path-mutation-preparation-commit-apply"
    )
    @Assert(
        longReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyMode,
        "long-controlled-runtime-default-path-mutation-preparation-commit-apply"
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyMode,
        "blocking-isolation-controlled-runtime-default-path-mutation-preparation-commit-apply"
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyAccepted,
        true
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateRecorded,
        true
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyRecorded,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationCommitBoundaryBlocksRejectedControlledApply(): Unit {
    let rejectedPreparationCommitPlan =
        buildIgniteRuntimeDefaultPathMutationPreparationCommitPlanReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationCommitPlanRequest(
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
    let rejectedDryRun =
        buildIgniteRuntimeDefaultPathMutationPreparationCommitDryRunReceipt(
            rejectedPreparationCommitPlan,
            acceptedRuntimeDefaultPathMutationPreparationCommitDryRunRequest()
        )
    let rejectedApplyGate =
        buildIgniteRuntimeDefaultPathMutationPreparationCommitApplyGateReceipt(
            rejectedDryRun,
            acceptedRuntimeDefaultPathMutationPreparationCommitApplyGateRequest()
        )
    let rejectedControlledApply =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationCommitApplyReceipt(
            rejectedApplyGate,
            acceptedControlledRuntimeDefaultPathMutationPreparationCommitApplyRequest()
        )
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationCommitBoundaryReceipt(
            rejectedControlledApply,
            acceptedRuntimeDefaultPathMutationPreparationCommitBoundaryRequest()
        )

    @Assert(
        receipt.status,
        "blocked-controlled-runtime-default-path-mutation-preparation-commit-apply-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationCommitBoundaryAccepted,
        false
    )
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_APPLY_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationCommitBoundaryRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationCommitBoundaryReceipt(
            controlledRuntimeDefaultPathMutationPreparationCommitApplyReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationCommitBoundaryRequest(
                "runtime-default-path-mutation-preparation-commit-boundary-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-commit-boundary-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationCommitBoundaryAccepted,
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

func runTestRuntimeDefaultPathMutationPreparationCommitBoundaryBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationCommitBoundaryReceipt(
            controlledRuntimeDefaultPathMutationPreparationCommitApplyReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationCommitBoundaryRequest(
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
        "blocked-runtime-default-path-mutation-preparation-commit-boundary-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationCommitBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_BOUNDARY_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_APPLY_SNAPSHOT_NOT_CARRIED"
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
        receipt.runtimeDefaultPathMutationPreparationCommitBoundaryRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationCommitBoundaryMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationCommitBoundaryReceipt(
            controlledRuntimeDefaultPathMutationPreparationCommitApplyReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationCommitBoundaryRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationCommitBoundaryReceipt(
            controlledRuntimeDefaultPathMutationPreparationCommitApplyReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationCommitBoundaryRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationCommitBoundaryReceipt(
            controlledRuntimeDefaultPathMutationPreparationCommitApplyReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationCommitBoundaryRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-commit-boundary-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryMode,
        "short-runtime-default-path-mutation-preparation-commit-boundary"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryMode,
        "long-runtime-default-path-mutation-preparation-commit-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-commit-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.controlledPreparationCommitApplyReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryRecorded,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationFinalizationGateBlocksRejectedCommitBoundary(): Unit {
    let rejectedBoundary =
        buildIgniteRuntimeDefaultPathMutationPreparationCommitBoundaryReceipt(
            controlledRuntimeDefaultPathMutationPreparationCommitApplyReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationCommitBoundaryRequest(
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
        buildIgniteRuntimeDefaultPathMutationPreparationFinalizationGateReceipt(
            rejectedBoundary,
            acceptedRuntimeDefaultPathMutationPreparationFinalizationGateRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-commit-boundary-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationFinalizationGateAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationCommitBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_BOUNDARY_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationFinalizationGateRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationFinalizationGateReceipt(
            runtimeDefaultPathMutationPreparationCommitBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationFinalizationGateRequest(
                "runtime-default-path-mutation-preparation-finalization-gate-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-finalization-gate-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationFinalizationGateAccepted,
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

func runTestRuntimeDefaultPathMutationPreparationFinalizationGateBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationFinalizationGateReceipt(
            runtimeDefaultPathMutationPreparationCommitBoundaryReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationFinalizationGateRequest(
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
        "blocked-runtime-default-path-mutation-preparation-finalization-gate-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationFinalizationGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_FINALIZATION_GATE_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_BOUNDARY_SNAPSHOT_NOT_CARRIED"
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
        receipt.runtimeDefaultPathMutationPreparationFinalizationGateRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationFinalizationGateMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationFinalizationGateReceipt(
            runtimeDefaultPathMutationPreparationCommitBoundaryReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationFinalizationGateRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationFinalizationGateReceipt(
            runtimeDefaultPathMutationPreparationCommitBoundaryReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationFinalizationGateRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationFinalizationGateReceipt(
            runtimeDefaultPathMutationPreparationCommitBoundaryReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationFinalizationGateRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-finalization-gate-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationFinalizationGateMode,
        "short-runtime-default-path-mutation-preparation-finalization-gate"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationFinalizationGateMode,
        "long-runtime-default-path-mutation-preparation-finalization-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationFinalizationGateMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-finalization-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationFinalizationGateAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationFinalizationGateAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationFinalizationGateRecorded,
        true
    )
}

func runTestControlledRuntimeDefaultPathMutationPreparationFinalizationApplyBlocksRejectedFinalizationGate(): Unit {
    let rejectedBoundary =
        buildIgniteRuntimeDefaultPathMutationPreparationCommitBoundaryReceipt(
            controlledRuntimeDefaultPathMutationPreparationCommitApplyReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationCommitBoundaryRequest(
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
        buildIgniteRuntimeDefaultPathMutationPreparationFinalizationGateReceipt(
            rejectedBoundary,
            acceptedRuntimeDefaultPathMutationPreparationFinalizationGateRequest()
        )
    let receipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationFinalizationApplyReceipt(
            rejectedFinalizationGate,
            acceptedControlledRuntimeDefaultPathMutationPreparationFinalizationApplyRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-finalization-gate-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationFinalizationGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_FINALIZATION_GATE_NOT_ACCEPTED"
    )
}

func runTestControlledRuntimeDefaultPathMutationPreparationFinalizationApplyRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationFinalizationApplyReceipt(
            runtimeDefaultPathMutationPreparationFinalizationGateReceiptFor(
                "short-handler"
            ),
            IgniteControlledRuntimeDefaultPathMutationPreparationFinalizationApplyRequest(
                "controlled-runtime-default-path-mutation-preparation-finalization-apply-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-controlled-runtime-default-path-mutation-preparation-finalization-apply-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyAccepted,
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

func runTestControlledRuntimeDefaultPathMutationPreparationFinalizationApplyBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationFinalizationApplyReceipt(
            runtimeDefaultPathMutationPreparationFinalizationGateReceiptFor(
                "long-handler"
            ),
            IgniteControlledRuntimeDefaultPathMutationPreparationFinalizationApplyRequest(
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
        "blocked-controlled-runtime-default-path-mutation-preparation-finalization-apply-input"
    )
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_FINALIZATION_APPLY_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_FINALIZATION_GATE_SNAPSHOT_NOT_CARRIED"
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
        receipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyRecorded,
        false
    )
}

func runTestControlledRuntimeDefaultPathMutationPreparationFinalizationApplyMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationFinalizationApplyReceipt(
            runtimeDefaultPathMutationPreparationFinalizationGateReceiptFor(
                "short-handler"
            ),
            acceptedControlledRuntimeDefaultPathMutationPreparationFinalizationApplyRequest()
        )
    let longReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationFinalizationApplyReceipt(
            runtimeDefaultPathMutationPreparationFinalizationGateReceiptFor(
                "long-handler"
            ),
            acceptedControlledRuntimeDefaultPathMutationPreparationFinalizationApplyRequest()
        )
    let blockingReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationFinalizationApplyReceipt(
            runtimeDefaultPathMutationPreparationFinalizationGateReceiptFor(
                "blocking-external-operation"
            ),
            acceptedControlledRuntimeDefaultPathMutationPreparationFinalizationApplyRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-controlled-runtime-default-path-mutation-preparation-finalization-apply-receipt"
    )
    @Assert(
        shortReceipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyMode,
        "short-controlled-runtime-default-path-mutation-preparation-finalization-apply"
    )
    @Assert(
        longReceipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyMode,
        "long-controlled-runtime-default-path-mutation-preparation-finalization-apply"
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyMode,
        "blocking-isolation-controlled-runtime-default-path-mutation-preparation-finalization-apply"
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyAccepted,
        true
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationFinalizationGateRecorded,
        true
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyRecorded,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationCloseoutGateBlocksRejectedControlledFinalizationApply(): Unit {
    let rejectedFinalizationGate =
        buildIgniteRuntimeDefaultPathMutationPreparationFinalizationGateReceipt(
            runtimeDefaultPathMutationPreparationCommitBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationFinalizationGateRequest(
                "",
                false,
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
    let rejectedFinalizationApply =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationFinalizationApplyReceipt(
            rejectedFinalizationGate,
            acceptedControlledRuntimeDefaultPathMutationPreparationFinalizationApplyRequest()
        )
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationCloseoutGateReceipt(
            rejectedFinalizationApply,
            acceptedRuntimeDefaultPathMutationPreparationCloseoutGateRequest()
        )

    @Assert(
        receipt.status,
        "blocked-controlled-runtime-default-path-mutation-preparation-finalization-apply-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationCloseoutGateAccepted,
        false
    )
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_FINALIZATION_APPLY_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationCloseoutGateRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationCloseoutGateReceipt(
            controlledRuntimeDefaultPathMutationPreparationFinalizationApplyReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationCloseoutGateRequest(
                "runtime-default-path-mutation-preparation-closeout-gate-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-closeout-gate-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationCloseoutGateAccepted,
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

func runTestRuntimeDefaultPathMutationPreparationCloseoutGateBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationCloseoutGateReceipt(
            controlledRuntimeDefaultPathMutationPreparationFinalizationApplyReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationCloseoutGateRequest(
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
        "blocked-runtime-default-path-mutation-preparation-closeout-gate-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationCloseoutGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_CLOSEOUT_GATE_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_FINALIZATION_APPLY_SNAPSHOT_NOT_CARRIED"
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
        receipt.runtimeDefaultPathMutationPreparationCloseoutGateRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationCloseoutGateMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationCloseoutGateReceipt(
            controlledRuntimeDefaultPathMutationPreparationFinalizationApplyReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationCloseoutGateRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationCloseoutGateReceipt(
            controlledRuntimeDefaultPathMutationPreparationFinalizationApplyReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationCloseoutGateRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationCloseoutGateReceipt(
            controlledRuntimeDefaultPathMutationPreparationFinalizationApplyReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationCloseoutGateRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-closeout-gate-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationCloseoutGateMode,
        "short-runtime-default-path-mutation-preparation-closeout-gate"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationCloseoutGateMode,
        "long-runtime-default-path-mutation-preparation-closeout-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationCloseoutGateMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-closeout-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationCloseoutGateAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationCloseoutGateAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.controlledPreparationFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationCloseoutGateRecorded,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationHandoffGateBlocksRejectedCloseoutGate(): Unit {
    let rejectedCloseoutGate =
        buildIgniteRuntimeDefaultPathMutationPreparationCloseoutGateReceipt(
            controlledRuntimeDefaultPathMutationPreparationFinalizationApplyReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationCloseoutGateRequest(
                "",
                false,
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
                false,
                false,
                false
            )
        )
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationHandoffGateReceipt(
            rejectedCloseoutGate,
            acceptedRuntimeDefaultPathMutationPreparationHandoffGateRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-closeout-gate-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationHandoffGateAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationCloseoutGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_CLOSEOUT_GATE_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationHandoffGateRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationHandoffGateReceipt(
            runtimeDefaultPathMutationPreparationCloseoutGateReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationHandoffGateRequest(
                "runtime-default-path-mutation-preparation-handoff-gate-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-handoff-gate-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationHandoffGateAccepted,
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

func runTestRuntimeDefaultPathMutationPreparationHandoffGateBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationHandoffGateReceipt(
            runtimeDefaultPathMutationPreparationCloseoutGateReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationHandoffGateRequest(
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
        "blocked-runtime-default-path-mutation-preparation-handoff-gate-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationHandoffGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_HANDOFF_GATE_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_CLOSEOUT_GATE_SNAPSHOT_NOT_CARRIED"
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
        receipt.runtimeDefaultPathMutationPreparationHandoffGateRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationHandoffGateMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationHandoffGateReceipt(
            runtimeDefaultPathMutationPreparationCloseoutGateReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationHandoffGateRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationHandoffGateReceipt(
            runtimeDefaultPathMutationPreparationCloseoutGateReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationHandoffGateRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationHandoffGateReceipt(
            runtimeDefaultPathMutationPreparationCloseoutGateReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationHandoffGateRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-handoff-gate-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationHandoffGateMode,
        "short-runtime-default-path-mutation-preparation-handoff-gate"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationHandoffGateMode,
        "long-runtime-default-path-mutation-preparation-handoff-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationHandoffGateMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-handoff-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationHandoffGateAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationHandoffGateAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationCloseoutGateRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationHandoffGateRecorded,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationAcceptanceBoundaryBlocksRejectedHandoffGate(): Unit {
    let rejectedHandoffGate =
        buildIgniteRuntimeDefaultPathMutationPreparationHandoffGateReceipt(
            runtimeDefaultPathMutationPreparationCloseoutGateReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationHandoffGateRequest(
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
        buildIgniteRuntimeDefaultPathMutationPreparationAcceptanceBoundaryReceipt(
            rejectedHandoffGate,
            acceptedRuntimeDefaultPathMutationPreparationAcceptanceBoundaryRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-handoff-gate-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationAcceptanceBoundaryAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationHandoffGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_HANDOFF_GATE_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationAcceptanceBoundaryRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationAcceptanceBoundaryReceipt(
            runtimeDefaultPathMutationPreparationHandoffGateReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationAcceptanceBoundaryRequest(
                "runtime-default-path-mutation-preparation-acceptance-boundary-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-acceptance-boundary-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationAcceptanceBoundaryAccepted,
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

func runTestRuntimeDefaultPathMutationPreparationAcceptanceBoundaryBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationAcceptanceBoundaryReceipt(
            runtimeDefaultPathMutationPreparationHandoffGateReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationAcceptanceBoundaryRequest(
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
        "blocked-runtime-default-path-mutation-preparation-acceptance-boundary-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationAcceptanceBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_ACCEPTANCE_BOUNDARY_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_HANDOFF_GATE_RECEIPT_NOT_CARRIED"
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
        receipt.runtimeDefaultPathMutationPreparationAcceptanceBoundaryRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationAcceptanceBoundaryMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationAcceptanceBoundaryReceipt(
            runtimeDefaultPathMutationPreparationHandoffGateReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationAcceptanceBoundaryRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationAcceptanceBoundaryReceipt(
            runtimeDefaultPathMutationPreparationHandoffGateReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationAcceptanceBoundaryRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationAcceptanceBoundaryReceipt(
            runtimeDefaultPathMutationPreparationHandoffGateReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationAcceptanceBoundaryRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-acceptance-boundary-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationAcceptanceBoundaryMode,
        "short-runtime-default-path-mutation-preparation-acceptance-boundary"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationAcceptanceBoundaryMode,
        "long-runtime-default-path-mutation-preparation-acceptance-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationAcceptanceBoundaryMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-acceptance-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationAcceptanceBoundaryAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationAcceptanceBoundaryAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationHandoffGateRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationAcceptanceBoundaryRecorded,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyBoundaryBlocksRejectedAcceptanceBoundary(): Unit {
    let rejectedAcceptanceBoundary =
        buildIgniteRuntimeDefaultPathMutationPreparationAcceptanceBoundaryReceipt(
            runtimeDefaultPathMutationPreparationHandoffGateReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationAcceptanceBoundaryRequest(
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
        buildIgniteRuntimeDefaultPathMutationPreparationApplyBoundaryReceipt(
            rejectedAcceptanceBoundary,
            acceptedRuntimeDefaultPathMutationPreparationApplyBoundaryRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-acceptance-boundary-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyBoundaryAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationAcceptanceBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_ACCEPTANCE_BOUNDARY_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyBoundaryRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyBoundaryReceipt(
            runtimeDefaultPathMutationPreparationAcceptanceBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyBoundaryRequest(
                "runtime-default-path-mutation-preparation-apply-boundary-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-apply-boundary-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyBoundaryAccepted,
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

func runTestRuntimeDefaultPathMutationPreparationApplyBoundaryBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyBoundaryReceipt(
            runtimeDefaultPathMutationPreparationAcceptanceBoundaryReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyBoundaryRequest(
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
        "blocked-runtime-default-path-mutation-preparation-apply-boundary-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_BOUNDARY_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_ACCEPTANCE_BOUNDARY_RECEIPT_NOT_CARRIED"
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
        receipt.runtimeDefaultPathMutationPreparationApplyBoundaryRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyBoundaryMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyBoundaryReceipt(
            runtimeDefaultPathMutationPreparationAcceptanceBoundaryReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyBoundaryRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyBoundaryReceipt(
            runtimeDefaultPathMutationPreparationAcceptanceBoundaryReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyBoundaryRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyBoundaryReceipt(
            runtimeDefaultPathMutationPreparationAcceptanceBoundaryReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyBoundaryRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-apply-boundary-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationApplyBoundaryMode,
        "short-runtime-default-path-mutation-preparation-apply-boundary"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationApplyBoundaryMode,
        "long-runtime-default-path-mutation-preparation-apply-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyBoundaryMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyBoundaryAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyBoundaryAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationAcceptanceBoundaryRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyBoundaryRecorded,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunBlocksRejectedApplyBoundary(): Unit {
    let rejectedApplyBoundary =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyBoundaryReceipt(
            runtimeDefaultPathMutationPreparationAcceptanceBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyBoundaryRequest(
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
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunReceipt(
            rejectedApplyBoundary,
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-boundary-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_BOUNDARY_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunReceipt(
            runtimeDefaultPathMutationPreparationApplyBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunRequest(
                "runtime-default-path-mutation-preparation-apply-dry-run-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunAccepted,
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

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunReceipt(
            runtimeDefaultPathMutationPreparationApplyBoundaryReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunRequest(
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_BOUNDARY_RECEIPT_NOT_CARRIED"
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
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunReceipt(
            runtimeDefaultPathMutationPreparationApplyBoundaryReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunReceipt(
            runtimeDefaultPathMutationPreparationApplyBoundaryReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunReceipt(
            runtimeDefaultPathMutationPreparationApplyBoundaryReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationApplyDryRunMode,
        "short-runtime-default-path-mutation-preparation-apply-dry-run"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationApplyDryRunMode,
        "long-runtime-default-path-mutation-preparation-apply-dry-run"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyBoundaryRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunRecorded,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunGateBlocksRejectedApplyDryRun(): Unit {
    let rejectedApplyDryRun =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunReceipt(
            runtimeDefaultPathMutationPreparationApplyBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunRequest(
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
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunGateReceipt(
            rejectedApplyDryRun,
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunGateRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunGateAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunGateRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunGateRequest(
                "runtime-default-path-mutation-preparation-apply-dry-run-gate-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-gate-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunGateAccepted,
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

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunGateBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunGateRequest(
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-gate-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_GATE_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_RECEIPT_NOT_CARRIED"
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
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunGateRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunGateMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunGateRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunGateRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunGateRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-gate-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationApplyDryRunGateMode,
        "short-runtime-default-path-mutation-preparation-apply-dry-run-gate"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationApplyDryRunGateMode,
        "long-runtime-default-path-mutation-preparation-apply-dry-run-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunGateMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunGateAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunGateAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunGateRecorded,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryBlocksRejectedGate(): Unit {
    let rejectedGate =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunGateRequest(
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
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryReceipt(
            rejectedGate,
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-gate-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_GATE_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunGateReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryRequest(
                "runtime-default-path-mutation-preparation-apply-dry-run-acceptance-boundary-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-acceptance-boundary-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryAccepted,
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

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunGateReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryRequest(
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-acceptance-boundary-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_ACCEPTANCE_BOUNDARY_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_GATE_RECEIPT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[3],
        "PREPARATION_APPLY_DRY_RUN_ACCEPTANCE_BOUNDARY_NOT_CARRIED"
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
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunGateReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunGateReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunGateReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-acceptance-boundary-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryMode,
        "short-runtime-default-path-mutation-preparation-apply-dry-run-acceptance-boundary"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryMode,
        "long-runtime-default-path-mutation-preparation-apply-dry-run-acceptance-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-acceptance-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.preparationApplyDryRunGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunGateRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryRecorded,
        true
    )
    let reusableReceipt =
        runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryReceiptFor(
            "short-handler"
        )
    @Assert(
        reusableReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryAccepted,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateBlocksRejectedAcceptanceBoundary(): Unit {
    let rejectedAcceptanceBoundary =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunGateReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryRequest(
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
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateReceipt(
            rejectedAcceptanceBoundary,
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-acceptance-boundary-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_ACCEPTANCE_BOUNDARY_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateRequest(
                "runtime-default-path-mutation-preparation-apply-dry-run-closeout-gate-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-closeout-gate-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateAccepted,
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

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateRequest(
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-closeout-gate-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_CLOSEOUT_GATE_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_ACCEPTANCE_BOUNDARY_RECEIPT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[3],
        "PREPARATION_APPLY_DRY_RUN_CLOSEOUT_GATE_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[4],
        "DOWNSTREAM_CONSUMER_BOUNDARY_NOT_CARRIED"
    )
    @Assert(receipt.blockers[5], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "CLOSEOUT_AUDIT_MARKER_NOT_CARRIED")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-closeout-gate-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateMode,
        "short-runtime-default-path-mutation-preparation-apply-dry-run-closeout-gate"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateMode,
        "long-runtime-default-path-mutation-preparation-apply-dry-run-closeout-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-closeout-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.preparationApplyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateRecorded,
        true
    )
    let reusableReceipt =
        runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateReceiptFor(
            "short-handler"
        )
    @Assert(
        reusableReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateAccepted,
        true
    )
}

func runTestControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBlocksRejectedCloseoutGate(): Unit {
    let rejectedCloseoutGate =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateRequest(
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
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffReceipt(
            rejectedCloseoutGate,
            acceptedControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-closeout-gate-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_CLOSEOUT_GATE_NOT_ACCEPTED"
    )
}

func runTestControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateReceiptFor(
                "short-handler"
            ),
            IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffRequest(
                "controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffAccepted,
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

func runTestControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateReceiptFor(
                "long-handler"
            ),
            IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffRequest(
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
        "blocked-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-input"
    )
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_CLOSEOUT_GATE_RECEIPT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[3],
        "CONTROLLED_PREPARATION_APPLY_DRY_RUN_HANDOFF_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[4],
        "DOWNSTREAM_CONSUMER_BOUNDARY_NOT_CARRIED"
    )
    @Assert(receipt.blockers[5], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "HANDOFF_AUDIT_MARKER_NOT_CARRIED")
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffRecorded,
        false
    )
}

func runTestControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateReceiptFor(
                "short-handler"
            ),
            acceptedControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffRequest()
        )
    let longReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateReceiptFor(
                "long-handler"
            ),
            acceptedControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffRequest()
        )
    let blockingReceipt =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateReceiptFor(
                "blocking-external-operation"
            ),
            acceptedControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-receipt"
    )
    @Assert(
        shortReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffMode,
        "short-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff"
    )
    @Assert(
        longReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffMode,
        "long-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff"
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffMode,
        "blocking-isolation-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff"
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffAccepted,
        true
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.preparationApplyDryRunCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateRecorded,
        true
    )
    @Assert(
        blockingReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffRecorded,
        true
    )
    let reusableReceipt =
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffReceiptFor(
            "short-handler"
        )
    @Assert(
        reusableReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffAccepted,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryBlocksRejectedControlledHandoff(): Unit {
    let rejectedControlledHandoff =
        buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateReceiptFor(
                "short-handler"
            ),
            IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffRequest(
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
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryReceipt(
            rejectedControlledHandoff,
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryRequest()
        )

    @Assert(
        receipt.status,
        "blocked-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryAccepted,
        false
    )
    @Assert(
        receipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryRequest(
                "runtime-default-path-mutation-preparation-apply-dry-run-handoff-boundary-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-boundary-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryAccepted,
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

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryRequest(
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-boundary-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_BOUNDARY_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_RECEIPT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[3],
        "PREPARATION_APPLY_DRY_RUN_HANDOFF_BOUNDARY_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[4],
        "DOWNSTREAM_CONSUMER_BOUNDARY_NOT_CARRIED"
    )
    @Assert(receipt.blockers[5], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "BOUNDARY_AUDIT_MARKER_NOT_CARRIED")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-boundary-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryMode,
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-boundary"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryMode,
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.controlledPreparationApplyDryRunHandoffReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryRecorded,
        true
    )
    let reusableReceipt =
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryReceiptFor(
            "short-handler"
        )
    @Assert(
        reusableReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryAccepted,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryBlocksRejectedHandoffBoundary(): Unit {
    let rejectedHandoffBoundary =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryReceipt(
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryRequest(
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
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryReceipt(
            rejectedHandoffBoundary,
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-boundary-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_BOUNDARY_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryRequest(
                "runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryAccepted,
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

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryRequest(
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_BOUNDARY_RECEIPT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[3],
        "PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[4],
        "DOWNSTREAM_CONSUMER_BOUNDARY_NOT_CARRIED"
    )
    @Assert(receipt.blockers[5], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "BOUNDARY_AUDIT_MARKER_NOT_CARRIED")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryMode,
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryMode,
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.handoffBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryRecorded,
        true
    )
    let reusableReceipt =
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryReceiptFor(
            "short-handler"
        )
    @Assert(
        reusableReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryAccepted,
        true
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateBlocksRejectedApplyBoundary(): Unit {
    let rejectedApplyBoundary =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryRequest(
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
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateReceipt(
            rejectedApplyBoundary,
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateRequest()
        )

    @Assert(
        receipt.status,
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-receipt"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateAccepted,
        false
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_NOT_ACCEPTED"
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateRefusesRuntimeMutation(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryReceiptFor(
                "short-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateRequest(
                "runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-2",
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-input"
    )
    @Assert(receipt.action, "block")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateAccepted,
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

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateBlocksMissingMarkers(): Unit {
    let receipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryReceiptFor(
                "long-handler"
            ),
            IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateRequest(
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
        "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-input"
    )
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateAccepted,
        false
    )
    @Assert(
        receipt.blockers[0],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_ID_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[1],
        "RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_RECEIPT_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[2],
        "RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[3],
        "PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_NOT_CARRIED"
    )
    @Assert(
        receipt.blockers[4],
        "DOWNSTREAM_CONSUMER_BOUNDARY_NOT_CARRIED"
    )
    @Assert(receipt.blockers[5], "ROLLBACK_ORDER_NOT_CARRIED")
    @Assert(receipt.blockers[6], "RUNTIME_GUARD_PLAN_NOT_CARRIED")
    @Assert(receipt.blockers[7], "OBSERVABILITY_MARKER_NOT_CARRIED")
    @Assert(receipt.blockers[8], "BOUNDARY_AUDIT_MARKER_NOT_CARRIED")
    @Assert(
        receipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateRecorded,
        false
    )
}

func runTestRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateMapsLaneModes(): Unit {
    let shortReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryReceiptFor(
                "short-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateRequest()
        )
    let longReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryReceiptFor(
                "long-handler"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateRequest()
        )
    let blockingReceipt =
        buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateReceipt(
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryReceiptFor(
                "blocking-external-operation"
            ),
            acceptedRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateRequest()
        )

    @Assert(
        shortReceipt.status,
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-receipt"
    )
    @Assert(
        shortReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateMode,
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate"
    )
    @Assert(
        longReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateMode,
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateMode,
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate"
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateAccepted,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateAllowed,
        true
    )
    @Assert(blockingReceipt.actualDefaultEngineFlipAllowed, false)
    @Assert(blockingReceipt.defaultEngineConfigMutationAllowed, false)
    @Assert(blockingReceipt.runtimeDefaultPathMutationAllowed, false)
    @Assert(blockingReceipt.publicReleaseAllowed, false)
    @Assert(blockingReceipt.stdxRemovalAllowed, false)
    @Assert(
        blockingReceipt.handoffApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryRecorded,
        true
    )
    @Assert(
        blockingReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateRecorded,
        true
    )
    let reusableReceipt =
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateReceiptFor(
            "short-handler"
        )
    @Assert(
        reusableReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateAccepted,
        true
    )
}
