package ignite

import std.fs.{File, OpenMode}
import std.collection.ArrayList
import std.io.InputStream
import std.net.TcpSocket
import stdx.net.http.{ServerBuilder, Server, HttpRequestDistributor, HttpRequestHandler, HttpContext, HttpHeaders, WebSocket}
import ignite.api2
import jinguissl.live.{
    ContractAcceptedTransportDescriptor,
    ContractHttpServerAttachPlan,
    ContractHttpServerAttachResult,
    ContractHttpServerAcceptedTransportSession,
    ContractHttpServerAcceptedTransportTls13X25519Request,
    ContractHttpServerLibraryStartupRequest,
    ContractTlsRecordContentType,
    ContractHttpServerTlsConfigRequest,
    ContractTlsHttpNegotiationPolicy,
    contractAttachAcceptedTransportTls13X25519,
    contractAttachAcceptedTransportTls13X25519Request,
    contractCloseAcceptedTransportSession,
    contractPlanHttpServerAttachRequest
}

public class IgniteRuntimeDefaultPathMutationApplyDryRunRequest {
    public let runtimeDefaultPathMutationApplyDryRunId: String
    public let applyBoundaryReceiptCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let applyDryRunCarried: Bool
    public let stagedApplyPlanCarried: Bool
    public let rollbackPreviewCarried: Bool
    public let runtimeGuardPlanCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let applyAuditMarkerCarried: Bool
    public let productionQueueMutationRequested: Bool
    public let actualRuntimeTaskSpawnRequested: Bool
    public let actualHandlerInvocationRequested: Bool
    public let actualRequestContextMutationRequested: Bool
    public let actualResponseWriteRequested: Bool
    public let actualTransportCommitRequested: Bool
    public let actualLiveServerWiringRequested: Bool
    public let actualDefaultEngineFlipRequested: Bool
    public let defaultEngineConfigMutationRequested: Bool
    public let runtimeDefaultPathMutationRequested: Bool
    public let publicReleaseRequested: Bool
    public let stdxRemovalRequested: Bool
    public let h1H2QuicRuntimeClosureClaimed: Bool

    public init(
        runtimeDefaultPathMutationApplyDryRunId: String,
        applyBoundaryReceiptCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        applyDryRunCarried: Bool,
        stagedApplyPlanCarried: Bool,
        rollbackPreviewCarried: Bool,
        runtimeGuardPlanCarried: Bool,
        observabilityMarkerCarried: Bool,
        applyAuditMarkerCarried: Bool,
        productionQueueMutationRequested: Bool,
        actualRuntimeTaskSpawnRequested: Bool,
        actualHandlerInvocationRequested: Bool,
        actualRequestContextMutationRequested: Bool,
        actualResponseWriteRequested: Bool,
        actualTransportCommitRequested: Bool,
        actualLiveServerWiringRequested: Bool,
        actualDefaultEngineFlipRequested: Bool,
        defaultEngineConfigMutationRequested: Bool,
        runtimeDefaultPathMutationRequested: Bool,
        publicReleaseRequested: Bool,
        stdxRemovalRequested: Bool,
        h1H2QuicRuntimeClosureClaimed: Bool
    ) {
        this.runtimeDefaultPathMutationApplyDryRunId =
            runtimeDefaultPathMutationApplyDryRunId
        this.applyBoundaryReceiptCarried = applyBoundaryReceiptCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.applyDryRunCarried = applyDryRunCarried
        this.stagedApplyPlanCarried = stagedApplyPlanCarried
        this.rollbackPreviewCarried = rollbackPreviewCarried
        this.runtimeGuardPlanCarried = runtimeGuardPlanCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
        this.applyAuditMarkerCarried = applyAuditMarkerCarried
        this.productionQueueMutationRequested = productionQueueMutationRequested
        this.actualRuntimeTaskSpawnRequested = actualRuntimeTaskSpawnRequested
        this.actualHandlerInvocationRequested = actualHandlerInvocationRequested
        this.actualRequestContextMutationRequested =
            actualRequestContextMutationRequested
        this.actualResponseWriteRequested = actualResponseWriteRequested
        this.actualTransportCommitRequested = actualTransportCommitRequested
        this.actualLiveServerWiringRequested = actualLiveServerWiringRequested
        this.actualDefaultEngineFlipRequested =
            actualDefaultEngineFlipRequested
        this.defaultEngineConfigMutationRequested =
            defaultEngineConfigMutationRequested
        this.runtimeDefaultPathMutationRequested =
            runtimeDefaultPathMutationRequested
        this.publicReleaseRequested = publicReleaseRequested
        this.stdxRemovalRequested = stdxRemovalRequested
        this.h1H2QuicRuntimeClosureClaimed = h1H2QuicRuntimeClosureClaimed
    }
}

public class IgniteRuntimeDefaultPathMutationApplyDryRunReceipt {
    public let runtimeDefaultPathMutationApplyDryRunAccepted: Bool
    public let runtimeDefaultPathMutationApplyBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationApplyBoundaryMode: String
    public let runtimeDefaultPathMutationApplyDryRunMode: String
    public let runtimeDefaultPathMutationApplyDryRunId: String
    public let runtimeDefaultPathMutationApplyBoundaryId: String
    public let runtimeDefaultPathMutationAcceptanceBoundaryId: String
    public let runtimeDefaultPathMutationHandoffGateId: String
    public let runtimeDefaultPathMutationCloseoutGateId: String
    public let controlledRuntimeDefaultPathMutationFinalizationApplyId: String
    public let runtimeDefaultPathMutationFinalizationGateId: String
    public let runtimeDefaultPathMutationCommitBoundaryId: String
    public let controlledRuntimeDefaultPathMutationCommitApplyId: String
    public let runtimeDefaultPathMutationCommitApplyGateId: String
    public let runtimeDefaultPathMutationCommitDryRunId: String
    public let runtimeDefaultPathMutationCommitPlanId: String
    public let controlledRuntimeDefaultPathMutationApplyId: String
    public let runtimeDefaultPathMutationApplyGateId: String
    public let runtimeDefaultPathMutationDryRunId: String
    public let runtimeDefaultPathMutationGateId: String
    public let controlledDefaultEngineMutationApplyId: String
    public let defaultEngineMutationApplyGateId: String
    public let defaultEngineMutationDryRunId: String
    public let defaultEngineMutationCommitPlanId: String
    public let applyBoundaryReceipt: IgniteRuntimeDefaultPathMutationApplyBoundaryReceipt
    public let runtimeDefaultPathMutationApplyDryRunRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationApplyDryRunAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let actualHandlerInvocationAllowed: Bool
    public let actualRequestContextMutationAllowed: Bool
    public let actualResponseWriteAllowed: Bool
    public let actualTransportCommitAllowed: Bool
    public let actualLiveServerWiringAllowed: Bool
    public let actualDefaultEngineFlipAllowed: Bool
    public let defaultEngineConfigMutationAllowed: Bool
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h1H2QuicRuntimeClosureClaimAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        runtimeDefaultPathMutationApplyDryRunAccepted: Bool,
        runtimeDefaultPathMutationApplyBoundaryAccepted: Bool,
        runtimeDefaultPathMutationApplyBoundaryMode: String,
        runtimeDefaultPathMutationApplyDryRunMode: String,
        runtimeDefaultPathMutationApplyDryRunId: String,
        runtimeDefaultPathMutationApplyBoundaryId: String,
        runtimeDefaultPathMutationAcceptanceBoundaryId: String,
        runtimeDefaultPathMutationHandoffGateId: String,
        runtimeDefaultPathMutationCloseoutGateId: String,
        controlledRuntimeDefaultPathMutationFinalizationApplyId: String,
        runtimeDefaultPathMutationFinalizationGateId: String,
        runtimeDefaultPathMutationCommitBoundaryId: String,
        controlledRuntimeDefaultPathMutationCommitApplyId: String,
        runtimeDefaultPathMutationCommitApplyGateId: String,
        runtimeDefaultPathMutationCommitDryRunId: String,
        runtimeDefaultPathMutationCommitPlanId: String,
        controlledRuntimeDefaultPathMutationApplyId: String,
        runtimeDefaultPathMutationApplyGateId: String,
        runtimeDefaultPathMutationDryRunId: String,
        runtimeDefaultPathMutationGateId: String,
        controlledDefaultEngineMutationApplyId: String,
        defaultEngineMutationApplyGateId: String,
        defaultEngineMutationDryRunId: String,
        defaultEngineMutationCommitPlanId: String,
        applyBoundaryReceipt: IgniteRuntimeDefaultPathMutationApplyBoundaryReceipt,
        runtimeDefaultPathMutationApplyDryRunRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationApplyDryRunAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        actualHandlerInvocationAllowed: Bool,
        actualRequestContextMutationAllowed: Bool,
        actualResponseWriteAllowed: Bool,
        actualTransportCommitAllowed: Bool,
        actualLiveServerWiringAllowed: Bool,
        actualDefaultEngineFlipAllowed: Bool,
        defaultEngineConfigMutationAllowed: Bool,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h1H2QuicRuntimeClosureClaimAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.runtimeDefaultPathMutationApplyDryRunAccepted =
            runtimeDefaultPathMutationApplyDryRunAccepted
        this.runtimeDefaultPathMutationApplyBoundaryAccepted =
            runtimeDefaultPathMutationApplyBoundaryAccepted
        this.runtimeDefaultPathMutationApplyBoundaryMode =
            runtimeDefaultPathMutationApplyBoundaryMode
        this.runtimeDefaultPathMutationApplyDryRunMode =
            runtimeDefaultPathMutationApplyDryRunMode
        this.runtimeDefaultPathMutationApplyDryRunId =
            runtimeDefaultPathMutationApplyDryRunId
        this.runtimeDefaultPathMutationApplyBoundaryId =
            runtimeDefaultPathMutationApplyBoundaryId
        this.runtimeDefaultPathMutationAcceptanceBoundaryId =
            runtimeDefaultPathMutationAcceptanceBoundaryId
        this.runtimeDefaultPathMutationHandoffGateId =
            runtimeDefaultPathMutationHandoffGateId
        this.runtimeDefaultPathMutationCloseoutGateId =
            runtimeDefaultPathMutationCloseoutGateId
        this.controlledRuntimeDefaultPathMutationFinalizationApplyId =
            controlledRuntimeDefaultPathMutationFinalizationApplyId
        this.runtimeDefaultPathMutationFinalizationGateId =
            runtimeDefaultPathMutationFinalizationGateId
        this.runtimeDefaultPathMutationCommitBoundaryId =
            runtimeDefaultPathMutationCommitBoundaryId
        this.controlledRuntimeDefaultPathMutationCommitApplyId =
            controlledRuntimeDefaultPathMutationCommitApplyId
        this.runtimeDefaultPathMutationCommitApplyGateId =
            runtimeDefaultPathMutationCommitApplyGateId
        this.runtimeDefaultPathMutationCommitDryRunId =
            runtimeDefaultPathMutationCommitDryRunId
        this.runtimeDefaultPathMutationCommitPlanId =
            runtimeDefaultPathMutationCommitPlanId
        this.controlledRuntimeDefaultPathMutationApplyId =
            controlledRuntimeDefaultPathMutationApplyId
        this.runtimeDefaultPathMutationApplyGateId =
            runtimeDefaultPathMutationApplyGateId
        this.runtimeDefaultPathMutationDryRunId =
            runtimeDefaultPathMutationDryRunId
        this.runtimeDefaultPathMutationGateId =
            runtimeDefaultPathMutationGateId
        this.controlledDefaultEngineMutationApplyId =
            controlledDefaultEngineMutationApplyId
        this.defaultEngineMutationApplyGateId =
            defaultEngineMutationApplyGateId
        this.defaultEngineMutationDryRunId = defaultEngineMutationDryRunId
        this.defaultEngineMutationCommitPlanId =
            defaultEngineMutationCommitPlanId
        this.applyBoundaryReceipt = applyBoundaryReceipt
        this.runtimeDefaultPathMutationApplyDryRunRecorded =
            runtimeDefaultPathMutationApplyDryRunRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationApplyDryRunAllowed =
            runtimeDefaultPathMutationApplyDryRunAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.actualRuntimeTaskSpawnAllowed = actualRuntimeTaskSpawnAllowed
        this.actualHandlerInvocationAllowed = actualHandlerInvocationAllowed
        this.actualRequestContextMutationAllowed =
            actualRequestContextMutationAllowed
        this.actualResponseWriteAllowed = actualResponseWriteAllowed
        this.actualTransportCommitAllowed = actualTransportCommitAllowed
        this.actualLiveServerWiringAllowed = actualLiveServerWiringAllowed
        this.actualDefaultEngineFlipAllowed = actualDefaultEngineFlipAllowed
        this.defaultEngineConfigMutationAllowed =
            defaultEngineConfigMutationAllowed
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h1H2QuicRuntimeClosureClaimAllowed =
            h1H2QuicRuntimeClosureClaimAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteRuntimeDefaultPathMutationApplyDryRunReceipt(
    applyBoundaryReceipt: IgniteRuntimeDefaultPathMutationApplyBoundaryReceipt,
    request: IgniteRuntimeDefaultPathMutationApplyDryRunRequest
): IgniteRuntimeDefaultPathMutationApplyDryRunReceipt {
    let nonClaims = igniteRuntimeDefaultPathMutationApplyDryRunNonClaims()
    if (!applyBoundaryReceipt.runtimeDefaultPathMutationApplyBoundaryAccepted) {
        return IgniteRuntimeDefaultPathMutationApplyDryRunReceipt(
            false,
            applyBoundaryReceipt.runtimeDefaultPathMutationApplyBoundaryAccepted,
            applyBoundaryReceipt.runtimeDefaultPathMutationApplyBoundaryMode,
            "none",
            request.runtimeDefaultPathMutationApplyDryRunId,
            applyBoundaryReceipt.runtimeDefaultPathMutationApplyBoundaryId,
            applyBoundaryReceipt.runtimeDefaultPathMutationAcceptanceBoundaryId,
            applyBoundaryReceipt.runtimeDefaultPathMutationHandoffGateId,
            applyBoundaryReceipt.runtimeDefaultPathMutationCloseoutGateId,
            applyBoundaryReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyId,
            applyBoundaryReceipt.runtimeDefaultPathMutationFinalizationGateId,
            applyBoundaryReceipt.runtimeDefaultPathMutationCommitBoundaryId,
            applyBoundaryReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
            applyBoundaryReceipt.runtimeDefaultPathMutationCommitApplyGateId,
            applyBoundaryReceipt.runtimeDefaultPathMutationCommitDryRunId,
            applyBoundaryReceipt.runtimeDefaultPathMutationCommitPlanId,
            applyBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyId,
            applyBoundaryReceipt.runtimeDefaultPathMutationApplyGateId,
            applyBoundaryReceipt.runtimeDefaultPathMutationDryRunId,
            applyBoundaryReceipt.runtimeDefaultPathMutationGateId,
            applyBoundaryReceipt.controlledDefaultEngineMutationApplyId,
            applyBoundaryReceipt.defaultEngineMutationApplyGateId,
            applyBoundaryReceipt.defaultEngineMutationDryRunId,
            applyBoundaryReceipt.defaultEngineMutationCommitPlanId,
            applyBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-apply-boundary-receipt",
            "collect-accepted-runtime-default-path-mutation-apply-boundary-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_APPLY_BOUNDARY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0498 runtime default-path mutation apply boundary input before apply dry-run work",
            "QUIC must not consume runtime default-path mutation apply dry-run receipts from rejected apply-boundary receipts"
        )
    }

    let applyDryRunMode =
        igniteRuntimeDefaultPathMutationApplyDryRunModeFor(
            applyBoundaryReceipt.runtimeDefaultPathMutationApplyBoundaryMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationApplyDryRunBlockers(
            request,
            applyDryRunMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationApplyDryRunReceipt(
            false,
            applyBoundaryReceipt.runtimeDefaultPathMutationApplyBoundaryAccepted,
            applyBoundaryReceipt.runtimeDefaultPathMutationApplyBoundaryMode,
            applyDryRunMode,
            request.runtimeDefaultPathMutationApplyDryRunId,
            applyBoundaryReceipt.runtimeDefaultPathMutationApplyBoundaryId,
            applyBoundaryReceipt.runtimeDefaultPathMutationAcceptanceBoundaryId,
            applyBoundaryReceipt.runtimeDefaultPathMutationHandoffGateId,
            applyBoundaryReceipt.runtimeDefaultPathMutationCloseoutGateId,
            applyBoundaryReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyId,
            applyBoundaryReceipt.runtimeDefaultPathMutationFinalizationGateId,
            applyBoundaryReceipt.runtimeDefaultPathMutationCommitBoundaryId,
            applyBoundaryReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
            applyBoundaryReceipt.runtimeDefaultPathMutationCommitApplyGateId,
            applyBoundaryReceipt.runtimeDefaultPathMutationCommitDryRunId,
            applyBoundaryReceipt.runtimeDefaultPathMutationCommitPlanId,
            applyBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyId,
            applyBoundaryReceipt.runtimeDefaultPathMutationApplyGateId,
            applyBoundaryReceipt.runtimeDefaultPathMutationDryRunId,
            applyBoundaryReceipt.runtimeDefaultPathMutationGateId,
            applyBoundaryReceipt.controlledDefaultEngineMutationApplyId,
            applyBoundaryReceipt.defaultEngineMutationApplyGateId,
            applyBoundaryReceipt.defaultEngineMutationDryRunId,
            applyBoundaryReceipt.defaultEngineMutationCommitPlanId,
            applyBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-apply-dry-run-input",
            "fix-runtime-default-path-mutation-apply-dry-run-before-runtime-default-mutation",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry apply-dry-run id, apply-boundary receipt, runtime default-path mutation lock, apply dry-run marker, staged apply plan, rollback preview, runtime guard plan, observability marker, apply audit marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation apply dry-run blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationApplyDryRunReceipt(
        true,
        applyBoundaryReceipt.runtimeDefaultPathMutationApplyBoundaryAccepted,
        applyBoundaryReceipt.runtimeDefaultPathMutationApplyBoundaryMode,
        applyDryRunMode,
        request.runtimeDefaultPathMutationApplyDryRunId,
        applyBoundaryReceipt.runtimeDefaultPathMutationApplyBoundaryId,
        applyBoundaryReceipt.runtimeDefaultPathMutationAcceptanceBoundaryId,
        applyBoundaryReceipt.runtimeDefaultPathMutationHandoffGateId,
        applyBoundaryReceipt.runtimeDefaultPathMutationCloseoutGateId,
        applyBoundaryReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyId,
        applyBoundaryReceipt.runtimeDefaultPathMutationFinalizationGateId,
        applyBoundaryReceipt.runtimeDefaultPathMutationCommitBoundaryId,
        applyBoundaryReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
        applyBoundaryReceipt.runtimeDefaultPathMutationCommitApplyGateId,
        applyBoundaryReceipt.runtimeDefaultPathMutationCommitDryRunId,
        applyBoundaryReceipt.runtimeDefaultPathMutationCommitPlanId,
        applyBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyId,
        applyBoundaryReceipt.runtimeDefaultPathMutationApplyGateId,
        applyBoundaryReceipt.runtimeDefaultPathMutationDryRunId,
        applyBoundaryReceipt.runtimeDefaultPathMutationGateId,
        applyBoundaryReceipt.controlledDefaultEngineMutationApplyId,
        applyBoundaryReceipt.defaultEngineMutationApplyGateId,
        applyBoundaryReceipt.defaultEngineMutationDryRunId,
        applyBoundaryReceipt.defaultEngineMutationCommitPlanId,
        applyBoundaryReceipt,
        true,
        "record-runtime-default-path-mutation-apply-dry-run",
        "accepted-runtime-default-path-mutation-apply-dry-run-receipt",
        "record-runtime-default-path-mutation-apply-dry-run-without-runtime-default-mutation",
        [],
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
        nonClaims,
        "next packet may prove runtime default-path mutation apply-dry-run acceptance gate or stdx claim separation without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation apply dry-run modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationApplyDryRunModeFor(
    applyBoundaryMode: String
): String {
    if (
        applyBoundaryMode ==
        "short-runtime-default-path-mutation-apply-boundary"
    ) {
        return "short-runtime-default-path-mutation-apply-dry-run"
    }
    if (
        applyBoundaryMode ==
        "long-runtime-default-path-mutation-apply-boundary"
    ) {
        return "long-runtime-default-path-mutation-apply-dry-run"
    }
    if (
        applyBoundaryMode ==
        "blocking-isolation-runtime-default-path-mutation-apply-boundary"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-apply-dry-run"
    }
    "unknown-runtime-default-path-mutation-apply-dry-run"
}

func igniteRuntimeDefaultPathMutationApplyDryRunBlockers(
    request: IgniteRuntimeDefaultPathMutationApplyDryRunRequest,
    applyDryRunMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.runtimeDefaultPathMutationApplyDryRunId.size == 0) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ID_NOT_CARRIED")
    }
    if (!request.applyBoundaryReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_APPLY_BOUNDARY_RECEIPT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.applyDryRunCarried) {
        blockers.add("APPLY_DRY_RUN_NOT_CARRIED")
    }
    if (!request.stagedApplyPlanCarried) {
        blockers.add("STAGED_APPLY_PLAN_NOT_CARRIED")
    }
    if (!request.rollbackPreviewCarried) {
        blockers.add("ROLLBACK_PREVIEW_NOT_CARRIED")
    }
    if (!request.runtimeGuardPlanCarried) {
        blockers.add("RUNTIME_GUARD_PLAN_NOT_CARRIED")
    }
    if (!request.observabilityMarkerCarried) {
        blockers.add("OBSERVABILITY_MARKER_NOT_CARRIED")
    }
    if (!request.applyAuditMarkerCarried) {
        blockers.add("APPLY_AUDIT_MARKER_NOT_CARRIED")
    }
    if (request.productionQueueMutationRequested) {
        blockers.add("PRODUCTION_QUEUE_MUTATION_REQUESTED")
    }
    if (request.actualRuntimeTaskSpawnRequested) {
        blockers.add("ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.actualHandlerInvocationRequested) {
        blockers.add("ACTUAL_HANDLER_INVOCATION_REQUESTED")
    }
    if (request.actualRequestContextMutationRequested) {
        blockers.add("ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.actualResponseWriteRequested) {
        blockers.add("ACTUAL_RESPONSE_WRITE_REQUESTED")
    }
    if (request.actualTransportCommitRequested) {
        blockers.add("ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.actualLiveServerWiringRequested) {
        blockers.add("ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    }
    if (request.actualDefaultEngineFlipRequested) {
        blockers.add("ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    }
    if (request.defaultEngineConfigMutationRequested) {
        blockers.add("DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    }
    if (request.runtimeDefaultPathMutationRequested) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    }
    if (request.publicReleaseRequested) {
        blockers.add("PUBLIC_RELEASE_REQUESTED")
    }
    if (request.stdxRemovalRequested) {
        blockers.add("STDX_REMOVAL_REQUESTED")
    }
    if (request.h1H2QuicRuntimeClosureClaimed) {
        blockers.add("H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    }
    if (
        applyDryRunMode ==
        "unknown-runtime-default-path-mutation-apply-dry-run"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_BOUNDARY")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationApplyDryRunNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationApplyBoundaryNonClaims()
}

public class IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceGateRequest {
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String
    public let applyDryRunReceiptCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let applyDryRunAcceptanceGateCarried: Bool
    public let dryRunResultReviewCarried: Bool
    public let rollbackPreviewCarried: Bool
    public let runtimeGuardPlanCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let applyAuditMarkerCarried: Bool
    public let productionQueueMutationRequested: Bool
    public let actualRuntimeTaskSpawnRequested: Bool
    public let actualHandlerInvocationRequested: Bool
    public let actualRequestContextMutationRequested: Bool
    public let actualResponseWriteRequested: Bool
    public let actualTransportCommitRequested: Bool
    public let actualLiveServerWiringRequested: Bool
    public let actualDefaultEngineFlipRequested: Bool
    public let defaultEngineConfigMutationRequested: Bool
    public let runtimeDefaultPathMutationRequested: Bool
    public let publicReleaseRequested: Bool
    public let stdxRemovalRequested: Bool
    public let h1H2QuicRuntimeClosureClaimed: Bool

    public init(
        runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String,
        applyDryRunReceiptCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        applyDryRunAcceptanceGateCarried: Bool,
        dryRunResultReviewCarried: Bool,
        rollbackPreviewCarried: Bool,
        runtimeGuardPlanCarried: Bool,
        observabilityMarkerCarried: Bool,
        applyAuditMarkerCarried: Bool,
        productionQueueMutationRequested: Bool,
        actualRuntimeTaskSpawnRequested: Bool,
        actualHandlerInvocationRequested: Bool,
        actualRequestContextMutationRequested: Bool,
        actualResponseWriteRequested: Bool,
        actualTransportCommitRequested: Bool,
        actualLiveServerWiringRequested: Bool,
        actualDefaultEngineFlipRequested: Bool,
        defaultEngineConfigMutationRequested: Bool,
        runtimeDefaultPathMutationRequested: Bool,
        publicReleaseRequested: Bool,
        stdxRemovalRequested: Bool,
        h1H2QuicRuntimeClosureClaimed: Bool
    ) {
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceGateId
        this.applyDryRunReceiptCarried = applyDryRunReceiptCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.applyDryRunAcceptanceGateCarried =
            applyDryRunAcceptanceGateCarried
        this.dryRunResultReviewCarried = dryRunResultReviewCarried
        this.rollbackPreviewCarried = rollbackPreviewCarried
        this.runtimeGuardPlanCarried = runtimeGuardPlanCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
        this.applyAuditMarkerCarried = applyAuditMarkerCarried
        this.productionQueueMutationRequested = productionQueueMutationRequested
        this.actualRuntimeTaskSpawnRequested = actualRuntimeTaskSpawnRequested
        this.actualHandlerInvocationRequested = actualHandlerInvocationRequested
        this.actualRequestContextMutationRequested =
            actualRequestContextMutationRequested
        this.actualResponseWriteRequested = actualResponseWriteRequested
        this.actualTransportCommitRequested = actualTransportCommitRequested
        this.actualLiveServerWiringRequested = actualLiveServerWiringRequested
        this.actualDefaultEngineFlipRequested =
            actualDefaultEngineFlipRequested
        this.defaultEngineConfigMutationRequested =
            defaultEngineConfigMutationRequested
        this.runtimeDefaultPathMutationRequested =
            runtimeDefaultPathMutationRequested
        this.publicReleaseRequested = publicReleaseRequested
        this.stdxRemovalRequested = stdxRemovalRequested
        this.h1H2QuicRuntimeClosureClaimed = h1H2QuicRuntimeClosureClaimed
    }
}

public class IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceGateReceipt {
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceGateAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunMode: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceGateMode: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String
    public let runtimeDefaultPathMutationApplyDryRunId: String
    public let runtimeDefaultPathMutationApplyBoundaryId: String
    public let runtimeDefaultPathMutationAcceptanceBoundaryId: String
    public let runtimeDefaultPathMutationHandoffGateId: String
    public let runtimeDefaultPathMutationCloseoutGateId: String
    public let controlledRuntimeDefaultPathMutationFinalizationApplyId: String
    public let runtimeDefaultPathMutationFinalizationGateId: String
    public let runtimeDefaultPathMutationCommitBoundaryId: String
    public let controlledRuntimeDefaultPathMutationCommitApplyId: String
    public let runtimeDefaultPathMutationCommitApplyGateId: String
    public let runtimeDefaultPathMutationCommitDryRunId: String
    public let runtimeDefaultPathMutationCommitPlanId: String
    public let controlledRuntimeDefaultPathMutationApplyId: String
    public let runtimeDefaultPathMutationApplyGateId: String
    public let runtimeDefaultPathMutationDryRunId: String
    public let runtimeDefaultPathMutationGateId: String
    public let controlledDefaultEngineMutationApplyId: String
    public let defaultEngineMutationApplyGateId: String
    public let defaultEngineMutationDryRunId: String
    public let defaultEngineMutationCommitPlanId: String
    public let applyDryRunReceipt: IgniteRuntimeDefaultPathMutationApplyDryRunReceipt
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceGateAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let actualHandlerInvocationAllowed: Bool
    public let actualRequestContextMutationAllowed: Bool
    public let actualResponseWriteAllowed: Bool
    public let actualTransportCommitAllowed: Bool
    public let actualLiveServerWiringAllowed: Bool
    public let actualDefaultEngineFlipAllowed: Bool
    public let defaultEngineConfigMutationAllowed: Bool
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h1H2QuicRuntimeClosureClaimAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        runtimeDefaultPathMutationApplyDryRunAcceptanceGateAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunMode: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceGateMode: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String,
        runtimeDefaultPathMutationApplyDryRunId: String,
        runtimeDefaultPathMutationApplyBoundaryId: String,
        runtimeDefaultPathMutationAcceptanceBoundaryId: String,
        runtimeDefaultPathMutationHandoffGateId: String,
        runtimeDefaultPathMutationCloseoutGateId: String,
        controlledRuntimeDefaultPathMutationFinalizationApplyId: String,
        runtimeDefaultPathMutationFinalizationGateId: String,
        runtimeDefaultPathMutationCommitBoundaryId: String,
        controlledRuntimeDefaultPathMutationCommitApplyId: String,
        runtimeDefaultPathMutationCommitApplyGateId: String,
        runtimeDefaultPathMutationCommitDryRunId: String,
        runtimeDefaultPathMutationCommitPlanId: String,
        controlledRuntimeDefaultPathMutationApplyId: String,
        runtimeDefaultPathMutationApplyGateId: String,
        runtimeDefaultPathMutationDryRunId: String,
        runtimeDefaultPathMutationGateId: String,
        controlledDefaultEngineMutationApplyId: String,
        defaultEngineMutationApplyGateId: String,
        defaultEngineMutationDryRunId: String,
        defaultEngineMutationCommitPlanId: String,
        applyDryRunReceipt: IgniteRuntimeDefaultPathMutationApplyDryRunReceipt,
        runtimeDefaultPathMutationApplyDryRunAcceptanceGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationApplyDryRunAcceptanceGateAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        actualHandlerInvocationAllowed: Bool,
        actualRequestContextMutationAllowed: Bool,
        actualResponseWriteAllowed: Bool,
        actualTransportCommitAllowed: Bool,
        actualLiveServerWiringAllowed: Bool,
        actualDefaultEngineFlipAllowed: Bool,
        defaultEngineConfigMutationAllowed: Bool,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h1H2QuicRuntimeClosureClaimAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceGateAccepted =
            runtimeDefaultPathMutationApplyDryRunAcceptanceGateAccepted
        this.runtimeDefaultPathMutationApplyDryRunAccepted =
            runtimeDefaultPathMutationApplyDryRunAccepted
        this.runtimeDefaultPathMutationApplyDryRunMode =
            runtimeDefaultPathMutationApplyDryRunMode
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceGateMode =
            runtimeDefaultPathMutationApplyDryRunAcceptanceGateMode
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceGateId
        this.runtimeDefaultPathMutationApplyDryRunId =
            runtimeDefaultPathMutationApplyDryRunId
        this.runtimeDefaultPathMutationApplyBoundaryId =
            runtimeDefaultPathMutationApplyBoundaryId
        this.runtimeDefaultPathMutationAcceptanceBoundaryId =
            runtimeDefaultPathMutationAcceptanceBoundaryId
        this.runtimeDefaultPathMutationHandoffGateId =
            runtimeDefaultPathMutationHandoffGateId
        this.runtimeDefaultPathMutationCloseoutGateId =
            runtimeDefaultPathMutationCloseoutGateId
        this.controlledRuntimeDefaultPathMutationFinalizationApplyId =
            controlledRuntimeDefaultPathMutationFinalizationApplyId
        this.runtimeDefaultPathMutationFinalizationGateId =
            runtimeDefaultPathMutationFinalizationGateId
        this.runtimeDefaultPathMutationCommitBoundaryId =
            runtimeDefaultPathMutationCommitBoundaryId
        this.controlledRuntimeDefaultPathMutationCommitApplyId =
            controlledRuntimeDefaultPathMutationCommitApplyId
        this.runtimeDefaultPathMutationCommitApplyGateId =
            runtimeDefaultPathMutationCommitApplyGateId
        this.runtimeDefaultPathMutationCommitDryRunId =
            runtimeDefaultPathMutationCommitDryRunId
        this.runtimeDefaultPathMutationCommitPlanId =
            runtimeDefaultPathMutationCommitPlanId
        this.controlledRuntimeDefaultPathMutationApplyId =
            controlledRuntimeDefaultPathMutationApplyId
        this.runtimeDefaultPathMutationApplyGateId =
            runtimeDefaultPathMutationApplyGateId
        this.runtimeDefaultPathMutationDryRunId =
            runtimeDefaultPathMutationDryRunId
        this.runtimeDefaultPathMutationGateId =
            runtimeDefaultPathMutationGateId
        this.controlledDefaultEngineMutationApplyId =
            controlledDefaultEngineMutationApplyId
        this.defaultEngineMutationApplyGateId =
            defaultEngineMutationApplyGateId
        this.defaultEngineMutationDryRunId = defaultEngineMutationDryRunId
        this.defaultEngineMutationCommitPlanId =
            defaultEngineMutationCommitPlanId
        this.applyDryRunReceipt = applyDryRunReceipt
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceGateRecorded =
            runtimeDefaultPathMutationApplyDryRunAcceptanceGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceGateAllowed =
            runtimeDefaultPathMutationApplyDryRunAcceptanceGateAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.actualRuntimeTaskSpawnAllowed = actualRuntimeTaskSpawnAllowed
        this.actualHandlerInvocationAllowed = actualHandlerInvocationAllowed
        this.actualRequestContextMutationAllowed =
            actualRequestContextMutationAllowed
        this.actualResponseWriteAllowed = actualResponseWriteAllowed
        this.actualTransportCommitAllowed = actualTransportCommitAllowed
        this.actualLiveServerWiringAllowed = actualLiveServerWiringAllowed
        this.actualDefaultEngineFlipAllowed = actualDefaultEngineFlipAllowed
        this.defaultEngineConfigMutationAllowed =
            defaultEngineConfigMutationAllowed
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h1H2QuicRuntimeClosureClaimAllowed =
            h1H2QuicRuntimeClosureClaimAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceGateReceipt(
    applyDryRunReceipt: IgniteRuntimeDefaultPathMutationApplyDryRunReceipt,
    request: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceGateRequest
): IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceGateReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceGateNonClaims()
    if (!applyDryRunReceipt.runtimeDefaultPathMutationApplyDryRunAccepted) {
        return IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceGateReceipt(
            false,
            applyDryRunReceipt.runtimeDefaultPathMutationApplyDryRunAccepted,
            applyDryRunReceipt.runtimeDefaultPathMutationApplyDryRunMode,
            "none",
            request.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            applyDryRunReceipt.runtimeDefaultPathMutationApplyDryRunId,
            applyDryRunReceipt.runtimeDefaultPathMutationApplyBoundaryId,
            applyDryRunReceipt.runtimeDefaultPathMutationAcceptanceBoundaryId,
            applyDryRunReceipt.runtimeDefaultPathMutationHandoffGateId,
            applyDryRunReceipt.runtimeDefaultPathMutationCloseoutGateId,
            applyDryRunReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyId,
            applyDryRunReceipt.runtimeDefaultPathMutationFinalizationGateId,
            applyDryRunReceipt.runtimeDefaultPathMutationCommitBoundaryId,
            applyDryRunReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
            applyDryRunReceipt.runtimeDefaultPathMutationCommitApplyGateId,
            applyDryRunReceipt.runtimeDefaultPathMutationCommitDryRunId,
            applyDryRunReceipt.runtimeDefaultPathMutationCommitPlanId,
            applyDryRunReceipt.controlledRuntimeDefaultPathMutationApplyId,
            applyDryRunReceipt.runtimeDefaultPathMutationApplyGateId,
            applyDryRunReceipt.runtimeDefaultPathMutationDryRunId,
            applyDryRunReceipt.runtimeDefaultPathMutationGateId,
            applyDryRunReceipt.controlledDefaultEngineMutationApplyId,
            applyDryRunReceipt.defaultEngineMutationApplyGateId,
            applyDryRunReceipt.defaultEngineMutationDryRunId,
            applyDryRunReceipt.defaultEngineMutationCommitPlanId,
            applyDryRunReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-apply-dry-run-receipt",
            "collect-accepted-runtime-default-path-mutation-apply-dry-run-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0499 runtime default-path mutation apply dry-run input before acceptance-gate work",
            "QUIC must not consume runtime default-path mutation apply-dry-run acceptance gate receipts from rejected apply dry-run receipts"
        )
    }

    let acceptanceGateMode =
        igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceGateModeFor(
            applyDryRunReceipt.runtimeDefaultPathMutationApplyDryRunMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceGateBlockers(
            request,
            acceptanceGateMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceGateReceipt(
            false,
            applyDryRunReceipt.runtimeDefaultPathMutationApplyDryRunAccepted,
            applyDryRunReceipt.runtimeDefaultPathMutationApplyDryRunMode,
            acceptanceGateMode,
            request.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            applyDryRunReceipt.runtimeDefaultPathMutationApplyDryRunId,
            applyDryRunReceipt.runtimeDefaultPathMutationApplyBoundaryId,
            applyDryRunReceipt.runtimeDefaultPathMutationAcceptanceBoundaryId,
            applyDryRunReceipt.runtimeDefaultPathMutationHandoffGateId,
            applyDryRunReceipt.runtimeDefaultPathMutationCloseoutGateId,
            applyDryRunReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyId,
            applyDryRunReceipt.runtimeDefaultPathMutationFinalizationGateId,
            applyDryRunReceipt.runtimeDefaultPathMutationCommitBoundaryId,
            applyDryRunReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
            applyDryRunReceipt.runtimeDefaultPathMutationCommitApplyGateId,
            applyDryRunReceipt.runtimeDefaultPathMutationCommitDryRunId,
            applyDryRunReceipt.runtimeDefaultPathMutationCommitPlanId,
            applyDryRunReceipt.controlledRuntimeDefaultPathMutationApplyId,
            applyDryRunReceipt.runtimeDefaultPathMutationApplyGateId,
            applyDryRunReceipt.runtimeDefaultPathMutationDryRunId,
            applyDryRunReceipt.runtimeDefaultPathMutationGateId,
            applyDryRunReceipt.controlledDefaultEngineMutationApplyId,
            applyDryRunReceipt.defaultEngineMutationApplyGateId,
            applyDryRunReceipt.defaultEngineMutationDryRunId,
            applyDryRunReceipt.defaultEngineMutationCommitPlanId,
            applyDryRunReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-gate-input",
            "fix-runtime-default-path-mutation-apply-dry-run-acceptance-gate-before-runtime-default-mutation",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry apply-dry-run acceptance gate id, apply dry-run receipt, runtime default-path mutation lock, acceptance gate marker, dry-run result review, rollback preview, runtime guard plan, observability marker, apply audit marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation apply-dry-run acceptance gate blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceGateReceipt(
        true,
        applyDryRunReceipt.runtimeDefaultPathMutationApplyDryRunAccepted,
        applyDryRunReceipt.runtimeDefaultPathMutationApplyDryRunMode,
        acceptanceGateMode,
        request.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
        applyDryRunReceipt.runtimeDefaultPathMutationApplyDryRunId,
        applyDryRunReceipt.runtimeDefaultPathMutationApplyBoundaryId,
        applyDryRunReceipt.runtimeDefaultPathMutationAcceptanceBoundaryId,
        applyDryRunReceipt.runtimeDefaultPathMutationHandoffGateId,
        applyDryRunReceipt.runtimeDefaultPathMutationCloseoutGateId,
        applyDryRunReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyId,
        applyDryRunReceipt.runtimeDefaultPathMutationFinalizationGateId,
        applyDryRunReceipt.runtimeDefaultPathMutationCommitBoundaryId,
        applyDryRunReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
        applyDryRunReceipt.runtimeDefaultPathMutationCommitApplyGateId,
        applyDryRunReceipt.runtimeDefaultPathMutationCommitDryRunId,
        applyDryRunReceipt.runtimeDefaultPathMutationCommitPlanId,
        applyDryRunReceipt.controlledRuntimeDefaultPathMutationApplyId,
        applyDryRunReceipt.runtimeDefaultPathMutationApplyGateId,
        applyDryRunReceipt.runtimeDefaultPathMutationDryRunId,
        applyDryRunReceipt.runtimeDefaultPathMutationGateId,
        applyDryRunReceipt.controlledDefaultEngineMutationApplyId,
        applyDryRunReceipt.defaultEngineMutationApplyGateId,
        applyDryRunReceipt.defaultEngineMutationDryRunId,
        applyDryRunReceipt.defaultEngineMutationCommitPlanId,
        applyDryRunReceipt,
        true,
        "record-runtime-default-path-mutation-apply-dry-run-acceptance-gate",
        "accepted-runtime-default-path-mutation-apply-dry-run-acceptance-gate-receipt",
        "record-runtime-default-path-mutation-apply-dry-run-acceptance-gate-without-runtime-default-mutation",
        [],
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
        nonClaims,
        "next packet may prove controlled runtime default-path mutation apply-dry-run acceptance or stdx claim separation without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation apply-dry-run acceptance gate modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceGateModeFor(
    applyDryRunMode: String
): String {
    if (
        applyDryRunMode ==
        "short-runtime-default-path-mutation-apply-dry-run"
    ) {
        return "short-runtime-default-path-mutation-apply-dry-run-acceptance-gate"
    }
    if (
        applyDryRunMode ==
        "long-runtime-default-path-mutation-apply-dry-run"
    ) {
        return "long-runtime-default-path-mutation-apply-dry-run-acceptance-gate"
    }
    if (
        applyDryRunMode ==
        "blocking-isolation-runtime-default-path-mutation-apply-dry-run"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-apply-dry-run-acceptance-gate"
    }
    "unknown-runtime-default-path-mutation-apply-dry-run-acceptance-gate"
}

func igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceGateBlockers(
    request: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceGateRequest,
    acceptanceGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId.size == 0) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_GATE_ID_NOT_CARRIED")
    }
    if (!request.applyDryRunReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_RECEIPT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.applyDryRunAcceptanceGateCarried) {
        blockers.add("APPLY_DRY_RUN_ACCEPTANCE_GATE_NOT_CARRIED")
    }
    if (!request.dryRunResultReviewCarried) {
        blockers.add("DRY_RUN_RESULT_REVIEW_NOT_CARRIED")
    }
    if (!request.rollbackPreviewCarried) {
        blockers.add("ROLLBACK_PREVIEW_NOT_CARRIED")
    }
    if (!request.runtimeGuardPlanCarried) {
        blockers.add("RUNTIME_GUARD_PLAN_NOT_CARRIED")
    }
    if (!request.observabilityMarkerCarried) {
        blockers.add("OBSERVABILITY_MARKER_NOT_CARRIED")
    }
    if (!request.applyAuditMarkerCarried) {
        blockers.add("APPLY_AUDIT_MARKER_NOT_CARRIED")
    }
    if (request.productionQueueMutationRequested) {
        blockers.add("PRODUCTION_QUEUE_MUTATION_REQUESTED")
    }
    if (request.actualRuntimeTaskSpawnRequested) {
        blockers.add("ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.actualHandlerInvocationRequested) {
        blockers.add("ACTUAL_HANDLER_INVOCATION_REQUESTED")
    }
    if (request.actualRequestContextMutationRequested) {
        blockers.add("ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.actualResponseWriteRequested) {
        blockers.add("ACTUAL_RESPONSE_WRITE_REQUESTED")
    }
    if (request.actualTransportCommitRequested) {
        blockers.add("ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.actualLiveServerWiringRequested) {
        blockers.add("ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    }
    if (request.actualDefaultEngineFlipRequested) {
        blockers.add("ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    }
    if (request.defaultEngineConfigMutationRequested) {
        blockers.add("DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    }
    if (request.runtimeDefaultPathMutationRequested) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    }
    if (request.publicReleaseRequested) {
        blockers.add("PUBLIC_RELEASE_REQUESTED")
    }
    if (request.stdxRemovalRequested) {
        blockers.add("STDX_REMOVAL_REQUESTED")
    }
    if (request.h1H2QuicRuntimeClosureClaimed) {
        blockers.add("H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    }
    if (
        acceptanceGateMode ==
        "unknown-runtime-default-path-mutation-apply-dry-run-acceptance-gate"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceGateNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationApplyDryRunNonClaims()
}

public class IgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceRequest {
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId: String
    public let applyDryRunAcceptanceGateReceiptCarried: Bool
    public let controlledApplyDryRunAcceptanceScopeCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let applyDryRunAcceptanceReviewCarried: Bool
    public let rollbackOrderCarried: Bool
    public let runtimeGuardPlanCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let applyAuditMarkerCarried: Bool
    public let productionQueueMutationRequested: Bool
    public let actualRuntimeTaskSpawnRequested: Bool
    public let actualHandlerInvocationRequested: Bool
    public let actualRequestContextMutationRequested: Bool
    public let actualResponseWriteRequested: Bool
    public let actualTransportCommitRequested: Bool
    public let actualLiveServerWiringRequested: Bool
    public let actualDefaultEngineFlipRequested: Bool
    public let defaultEngineConfigMutationRequested: Bool
    public let runtimeDefaultPathMutationRequested: Bool
    public let publicReleaseRequested: Bool
    public let stdxRemovalRequested: Bool
    public let h1H2QuicRuntimeClosureClaimed: Bool

    public init(
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId: String,
        applyDryRunAcceptanceGateReceiptCarried: Bool,
        controlledApplyDryRunAcceptanceScopeCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        applyDryRunAcceptanceReviewCarried: Bool,
        rollbackOrderCarried: Bool,
        runtimeGuardPlanCarried: Bool,
        observabilityMarkerCarried: Bool,
        applyAuditMarkerCarried: Bool,
        productionQueueMutationRequested: Bool,
        actualRuntimeTaskSpawnRequested: Bool,
        actualHandlerInvocationRequested: Bool,
        actualRequestContextMutationRequested: Bool,
        actualResponseWriteRequested: Bool,
        actualTransportCommitRequested: Bool,
        actualLiveServerWiringRequested: Bool,
        actualDefaultEngineFlipRequested: Bool,
        defaultEngineConfigMutationRequested: Bool,
        runtimeDefaultPathMutationRequested: Bool,
        publicReleaseRequested: Bool,
        stdxRemovalRequested: Bool,
        h1H2QuicRuntimeClosureClaimed: Bool
    ) {
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId
        this.applyDryRunAcceptanceGateReceiptCarried =
            applyDryRunAcceptanceGateReceiptCarried
        this.controlledApplyDryRunAcceptanceScopeCarried =
            controlledApplyDryRunAcceptanceScopeCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.applyDryRunAcceptanceReviewCarried =
            applyDryRunAcceptanceReviewCarried
        this.rollbackOrderCarried = rollbackOrderCarried
        this.runtimeGuardPlanCarried = runtimeGuardPlanCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
        this.applyAuditMarkerCarried = applyAuditMarkerCarried
        this.productionQueueMutationRequested = productionQueueMutationRequested
        this.actualRuntimeTaskSpawnRequested = actualRuntimeTaskSpawnRequested
        this.actualHandlerInvocationRequested = actualHandlerInvocationRequested
        this.actualRequestContextMutationRequested =
            actualRequestContextMutationRequested
        this.actualResponseWriteRequested = actualResponseWriteRequested
        this.actualTransportCommitRequested = actualTransportCommitRequested
        this.actualLiveServerWiringRequested = actualLiveServerWiringRequested
        this.actualDefaultEngineFlipRequested =
            actualDefaultEngineFlipRequested
        this.defaultEngineConfigMutationRequested =
            defaultEngineConfigMutationRequested
        this.runtimeDefaultPathMutationRequested =
            runtimeDefaultPathMutationRequested
        this.publicReleaseRequested = publicReleaseRequested
        this.stdxRemovalRequested = stdxRemovalRequested
        this.h1H2QuicRuntimeClosureClaimed = h1H2QuicRuntimeClosureClaimed
    }
}

public class IgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceReceipt {
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceGateAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceGateMode: String
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceMode: String
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String
    public let runtimeDefaultPathMutationApplyDryRunId: String
    public let runtimeDefaultPathMutationApplyBoundaryId: String
    public let runtimeDefaultPathMutationAcceptanceBoundaryId: String
    public let runtimeDefaultPathMutationHandoffGateId: String
    public let runtimeDefaultPathMutationCloseoutGateId: String
    public let controlledRuntimeDefaultPathMutationFinalizationApplyId: String
    public let runtimeDefaultPathMutationFinalizationGateId: String
    public let runtimeDefaultPathMutationCommitBoundaryId: String
    public let controlledRuntimeDefaultPathMutationCommitApplyId: String
    public let runtimeDefaultPathMutationCommitApplyGateId: String
    public let runtimeDefaultPathMutationCommitDryRunId: String
    public let runtimeDefaultPathMutationCommitPlanId: String
    public let controlledRuntimeDefaultPathMutationApplyId: String
    public let runtimeDefaultPathMutationApplyGateId: String
    public let runtimeDefaultPathMutationDryRunId: String
    public let runtimeDefaultPathMutationGateId: String
    public let controlledDefaultEngineMutationApplyId: String
    public let defaultEngineMutationApplyGateId: String
    public let defaultEngineMutationDryRunId: String
    public let defaultEngineMutationCommitPlanId: String
    public let applyDryRunAcceptanceGateReceipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceGateReceipt
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let actualHandlerInvocationAllowed: Bool
    public let actualRequestContextMutationAllowed: Bool
    public let actualResponseWriteAllowed: Bool
    public let actualTransportCommitAllowed: Bool
    public let actualLiveServerWiringAllowed: Bool
    public let actualDefaultEngineFlipAllowed: Bool
    public let defaultEngineConfigMutationAllowed: Bool
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h1H2QuicRuntimeClosureClaimAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceGateAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceGateMode: String,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceMode: String,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String,
        runtimeDefaultPathMutationApplyDryRunId: String,
        runtimeDefaultPathMutationApplyBoundaryId: String,
        runtimeDefaultPathMutationAcceptanceBoundaryId: String,
        runtimeDefaultPathMutationHandoffGateId: String,
        runtimeDefaultPathMutationCloseoutGateId: String,
        controlledRuntimeDefaultPathMutationFinalizationApplyId: String,
        runtimeDefaultPathMutationFinalizationGateId: String,
        runtimeDefaultPathMutationCommitBoundaryId: String,
        controlledRuntimeDefaultPathMutationCommitApplyId: String,
        runtimeDefaultPathMutationCommitApplyGateId: String,
        runtimeDefaultPathMutationCommitDryRunId: String,
        runtimeDefaultPathMutationCommitPlanId: String,
        controlledRuntimeDefaultPathMutationApplyId: String,
        runtimeDefaultPathMutationApplyGateId: String,
        runtimeDefaultPathMutationDryRunId: String,
        runtimeDefaultPathMutationGateId: String,
        controlledDefaultEngineMutationApplyId: String,
        defaultEngineMutationApplyGateId: String,
        defaultEngineMutationDryRunId: String,
        defaultEngineMutationCommitPlanId: String,
        applyDryRunAcceptanceGateReceipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceGateReceipt,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        actualHandlerInvocationAllowed: Bool,
        actualRequestContextMutationAllowed: Bool,
        actualResponseWriteAllowed: Bool,
        actualTransportCommitAllowed: Bool,
        actualLiveServerWiringAllowed: Bool,
        actualDefaultEngineFlipAllowed: Bool,
        defaultEngineConfigMutationAllowed: Bool,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h1H2QuicRuntimeClosureClaimAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAccepted =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAccepted
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceGateAccepted =
            runtimeDefaultPathMutationApplyDryRunAcceptanceGateAccepted
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceGateMode =
            runtimeDefaultPathMutationApplyDryRunAcceptanceGateMode
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceMode =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceMode
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceGateId
        this.runtimeDefaultPathMutationApplyDryRunId =
            runtimeDefaultPathMutationApplyDryRunId
        this.runtimeDefaultPathMutationApplyBoundaryId =
            runtimeDefaultPathMutationApplyBoundaryId
        this.runtimeDefaultPathMutationAcceptanceBoundaryId =
            runtimeDefaultPathMutationAcceptanceBoundaryId
        this.runtimeDefaultPathMutationHandoffGateId =
            runtimeDefaultPathMutationHandoffGateId
        this.runtimeDefaultPathMutationCloseoutGateId =
            runtimeDefaultPathMutationCloseoutGateId
        this.controlledRuntimeDefaultPathMutationFinalizationApplyId =
            controlledRuntimeDefaultPathMutationFinalizationApplyId
        this.runtimeDefaultPathMutationFinalizationGateId =
            runtimeDefaultPathMutationFinalizationGateId
        this.runtimeDefaultPathMutationCommitBoundaryId =
            runtimeDefaultPathMutationCommitBoundaryId
        this.controlledRuntimeDefaultPathMutationCommitApplyId =
            controlledRuntimeDefaultPathMutationCommitApplyId
        this.runtimeDefaultPathMutationCommitApplyGateId =
            runtimeDefaultPathMutationCommitApplyGateId
        this.runtimeDefaultPathMutationCommitDryRunId =
            runtimeDefaultPathMutationCommitDryRunId
        this.runtimeDefaultPathMutationCommitPlanId =
            runtimeDefaultPathMutationCommitPlanId
        this.controlledRuntimeDefaultPathMutationApplyId =
            controlledRuntimeDefaultPathMutationApplyId
        this.runtimeDefaultPathMutationApplyGateId =
            runtimeDefaultPathMutationApplyGateId
        this.runtimeDefaultPathMutationDryRunId =
            runtimeDefaultPathMutationDryRunId
        this.runtimeDefaultPathMutationGateId =
            runtimeDefaultPathMutationGateId
        this.controlledDefaultEngineMutationApplyId =
            controlledDefaultEngineMutationApplyId
        this.defaultEngineMutationApplyGateId =
            defaultEngineMutationApplyGateId
        this.defaultEngineMutationDryRunId = defaultEngineMutationDryRunId
        this.defaultEngineMutationCommitPlanId =
            defaultEngineMutationCommitPlanId
        this.applyDryRunAcceptanceGateReceipt =
            applyDryRunAcceptanceGateReceipt
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceRecorded =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAllowed =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.actualRuntimeTaskSpawnAllowed = actualRuntimeTaskSpawnAllowed
        this.actualHandlerInvocationAllowed = actualHandlerInvocationAllowed
        this.actualRequestContextMutationAllowed =
            actualRequestContextMutationAllowed
        this.actualResponseWriteAllowed = actualResponseWriteAllowed
        this.actualTransportCommitAllowed = actualTransportCommitAllowed
        this.actualLiveServerWiringAllowed = actualLiveServerWiringAllowed
        this.actualDefaultEngineFlipAllowed = actualDefaultEngineFlipAllowed
        this.defaultEngineConfigMutationAllowed =
            defaultEngineConfigMutationAllowed
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h1H2QuicRuntimeClosureClaimAllowed =
            h1H2QuicRuntimeClosureClaimAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceReceipt(
    applyDryRunAcceptanceGateReceipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceGateReceipt,
    request: IgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceRequest
): IgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceReceipt {
    let nonClaims =
        igniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceNonClaims()
    if (
        !applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateAccepted
    ) {
        return IgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceReceipt(
            false,
            applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateAccepted,
            applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateMode,
            "none",
            request.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationApplyDryRunId,
            applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationApplyBoundaryId,
            applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationAcceptanceBoundaryId,
            applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationHandoffGateId,
            applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationCloseoutGateId,
            applyDryRunAcceptanceGateReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyId,
            applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationFinalizationGateId,
            applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationCommitBoundaryId,
            applyDryRunAcceptanceGateReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
            applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationCommitApplyGateId,
            applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationCommitDryRunId,
            applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationCommitPlanId,
            applyDryRunAcceptanceGateReceipt.controlledRuntimeDefaultPathMutationApplyId,
            applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationApplyGateId,
            applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationDryRunId,
            applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationGateId,
            applyDryRunAcceptanceGateReceipt.controlledDefaultEngineMutationApplyId,
            applyDryRunAcceptanceGateReceipt.defaultEngineMutationApplyGateId,
            applyDryRunAcceptanceGateReceipt.defaultEngineMutationDryRunId,
            applyDryRunAcceptanceGateReceipt.defaultEngineMutationCommitPlanId,
            applyDryRunAcceptanceGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-apply-dry-run-acceptance-gate-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0500 runtime default-path mutation apply-dry-run acceptance gate input before controlled apply-dry-run acceptance work",
            "QUIC must not consume controlled runtime default-path mutation apply-dry-run acceptance receipts from rejected apply-dry-run acceptance gates"
        )
    }

    let controlledAcceptanceMode =
        igniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceModeFor(
            applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateMode
        )
    let blockers =
        igniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceBlockers(
            request,
            controlledAcceptanceMode
        )
    if (blockers.size > 0) {
        return IgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceReceipt(
            false,
            applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateAccepted,
            applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateMode,
            controlledAcceptanceMode,
            request.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationApplyDryRunId,
            applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationApplyBoundaryId,
            applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationAcceptanceBoundaryId,
            applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationHandoffGateId,
            applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationCloseoutGateId,
            applyDryRunAcceptanceGateReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyId,
            applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationFinalizationGateId,
            applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationCommitBoundaryId,
            applyDryRunAcceptanceGateReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
            applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationCommitApplyGateId,
            applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationCommitDryRunId,
            applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationCommitPlanId,
            applyDryRunAcceptanceGateReceipt.controlledRuntimeDefaultPathMutationApplyId,
            applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationApplyGateId,
            applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationDryRunId,
            applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationGateId,
            applyDryRunAcceptanceGateReceipt.controlledDefaultEngineMutationApplyId,
            applyDryRunAcceptanceGateReceipt.defaultEngineMutationApplyGateId,
            applyDryRunAcceptanceGateReceipt.defaultEngineMutationDryRunId,
            applyDryRunAcceptanceGateReceipt.defaultEngineMutationCommitPlanId,
            applyDryRunAcceptanceGateReceipt,
            false,
            "block",
            "blocked-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-input",
            "fix-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-before-runtime-default-mutation",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry controlled apply-dry-run acceptance id, apply-dry-run acceptance gate receipt, controlled scope, runtime default-path mutation lock, dry-run acceptance review, rollback order, runtime guard plan, observability marker, apply audit marker, and keep runtime default mutation out",
            "QUIC can reuse the same controlled runtime default-path mutation apply-dry-run acceptance blockers before default stream runtime mutation"
        )
    }

    IgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceReceipt(
        true,
        applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateAccepted,
        applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateMode,
        controlledAcceptanceMode,
        request.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
        applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
        applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationApplyDryRunId,
        applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationApplyBoundaryId,
        applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationAcceptanceBoundaryId,
        applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationHandoffGateId,
        applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationCloseoutGateId,
        applyDryRunAcceptanceGateReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyId,
        applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationFinalizationGateId,
        applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationCommitBoundaryId,
        applyDryRunAcceptanceGateReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
        applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationCommitApplyGateId,
        applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationCommitDryRunId,
        applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationCommitPlanId,
        applyDryRunAcceptanceGateReceipt.controlledRuntimeDefaultPathMutationApplyId,
        applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationApplyGateId,
        applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationDryRunId,
        applyDryRunAcceptanceGateReceipt.runtimeDefaultPathMutationGateId,
        applyDryRunAcceptanceGateReceipt.controlledDefaultEngineMutationApplyId,
        applyDryRunAcceptanceGateReceipt.defaultEngineMutationApplyGateId,
        applyDryRunAcceptanceGateReceipt.defaultEngineMutationDryRunId,
        applyDryRunAcceptanceGateReceipt.defaultEngineMutationCommitPlanId,
        applyDryRunAcceptanceGateReceipt,
        true,
        "record-controlled-runtime-default-path-mutation-apply-dry-run-acceptance",
        "accepted-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-receipt",
        "record-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-without-runtime-default-mutation",
        [],
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
        nonClaims,
        "next packet may prove runtime default-path mutation apply-dry-run acceptance boundary or stdx claim separation without mutating runtime defaults",
        "QUIC can reuse lane-specific controlled runtime default-path mutation apply-dry-run acceptance modes before runtime default mutation"
    )
}

func igniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceModeFor(
    applyDryRunAcceptanceGateMode: String
): String {
    if (
        applyDryRunAcceptanceGateMode ==
        "short-runtime-default-path-mutation-apply-dry-run-acceptance-gate"
    ) {
        return "short-controlled-runtime-default-path-mutation-apply-dry-run-acceptance"
    }
    if (
        applyDryRunAcceptanceGateMode ==
        "long-runtime-default-path-mutation-apply-dry-run-acceptance-gate"
    ) {
        return "long-controlled-runtime-default-path-mutation-apply-dry-run-acceptance"
    }
    if (
        applyDryRunAcceptanceGateMode ==
        "blocking-isolation-runtime-default-path-mutation-apply-dry-run-acceptance-gate"
    ) {
        return "blocking-isolation-controlled-runtime-default-path-mutation-apply-dry-run-acceptance"
    }
    "unknown-controlled-runtime-default-path-mutation-apply-dry-run-acceptance"
}

func igniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceBlockers(
    request: IgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceRequest,
    controlledAcceptanceMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId.size == 0
    ) {
        blockers.add("CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_ID_NOT_CARRIED")
    }
    if (!request.applyDryRunAcceptanceGateReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_GATE_RECEIPT_NOT_CARRIED")
    }
    if (!request.controlledApplyDryRunAcceptanceScopeCarried) {
        blockers.add("CONTROLLED_APPLY_DRY_RUN_ACCEPTANCE_SCOPE_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.applyDryRunAcceptanceReviewCarried) {
        blockers.add("APPLY_DRY_RUN_ACCEPTANCE_REVIEW_NOT_CARRIED")
    }
    if (!request.rollbackOrderCarried) {
        blockers.add("ROLLBACK_ORDER_NOT_CARRIED")
    }
    if (!request.runtimeGuardPlanCarried) {
        blockers.add("RUNTIME_GUARD_PLAN_NOT_CARRIED")
    }
    if (!request.observabilityMarkerCarried) {
        blockers.add("OBSERVABILITY_MARKER_NOT_CARRIED")
    }
    if (!request.applyAuditMarkerCarried) {
        blockers.add("APPLY_AUDIT_MARKER_NOT_CARRIED")
    }
    if (request.productionQueueMutationRequested) {
        blockers.add("PRODUCTION_QUEUE_MUTATION_REQUESTED")
    }
    if (request.actualRuntimeTaskSpawnRequested) {
        blockers.add("ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.actualHandlerInvocationRequested) {
        blockers.add("ACTUAL_HANDLER_INVOCATION_REQUESTED")
    }
    if (request.actualRequestContextMutationRequested) {
        blockers.add("ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.actualResponseWriteRequested) {
        blockers.add("ACTUAL_RESPONSE_WRITE_REQUESTED")
    }
    if (request.actualTransportCommitRequested) {
        blockers.add("ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.actualLiveServerWiringRequested) {
        blockers.add("ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    }
    if (request.actualDefaultEngineFlipRequested) {
        blockers.add("ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    }
    if (request.defaultEngineConfigMutationRequested) {
        blockers.add("DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    }
    if (request.runtimeDefaultPathMutationRequested) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    }
    if (request.publicReleaseRequested) {
        blockers.add("PUBLIC_RELEASE_REQUESTED")
    }
    if (request.stdxRemovalRequested) {
        blockers.add("STDX_REMOVAL_REQUESTED")
    }
    if (request.h1H2QuicRuntimeClosureClaimed) {
        blockers.add("H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    }
    if (
        controlledAcceptanceMode ==
        "unknown-controlled-runtime-default-path-mutation-apply-dry-run-acceptance"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_GATE")
    }
    blockers.toArray()
}

func igniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceGateNonClaims()
}

public class IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryRequest {
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId: String
    public let controlledApplyDryRunAcceptanceReceiptCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let applyDryRunAcceptanceBoundaryCarried: Bool
    public let downstreamConsumerBoundaryCarried: Bool
    public let rollbackOrderCarried: Bool
    public let runtimeGuardPlanCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let applyAuditMarkerCarried: Bool
    public let productionQueueMutationRequested: Bool
    public let actualRuntimeTaskSpawnRequested: Bool
    public let actualHandlerInvocationRequested: Bool
    public let actualRequestContextMutationRequested: Bool
    public let actualResponseWriteRequested: Bool
    public let actualTransportCommitRequested: Bool
    public let actualLiveServerWiringRequested: Bool
    public let actualDefaultEngineFlipRequested: Bool
    public let defaultEngineConfigMutationRequested: Bool
    public let runtimeDefaultPathMutationRequested: Bool
    public let publicReleaseRequested: Bool
    public let stdxRemovalRequested: Bool
    public let h1H2QuicRuntimeClosureClaimed: Bool

    public init(
        runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId: String,
        controlledApplyDryRunAcceptanceReceiptCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        applyDryRunAcceptanceBoundaryCarried: Bool,
        downstreamConsumerBoundaryCarried: Bool,
        rollbackOrderCarried: Bool,
        runtimeGuardPlanCarried: Bool,
        observabilityMarkerCarried: Bool,
        applyAuditMarkerCarried: Bool,
        productionQueueMutationRequested: Bool,
        actualRuntimeTaskSpawnRequested: Bool,
        actualHandlerInvocationRequested: Bool,
        actualRequestContextMutationRequested: Bool,
        actualResponseWriteRequested: Bool,
        actualTransportCommitRequested: Bool,
        actualLiveServerWiringRequested: Bool,
        actualDefaultEngineFlipRequested: Bool,
        defaultEngineConfigMutationRequested: Bool,
        runtimeDefaultPathMutationRequested: Bool,
        publicReleaseRequested: Bool,
        stdxRemovalRequested: Bool,
        h1H2QuicRuntimeClosureClaimed: Bool
    ) {
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId
        this.controlledApplyDryRunAcceptanceReceiptCarried =
            controlledApplyDryRunAcceptanceReceiptCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.applyDryRunAcceptanceBoundaryCarried =
            applyDryRunAcceptanceBoundaryCarried
        this.downstreamConsumerBoundaryCarried =
            downstreamConsumerBoundaryCarried
        this.rollbackOrderCarried = rollbackOrderCarried
        this.runtimeGuardPlanCarried = runtimeGuardPlanCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
        this.applyAuditMarkerCarried = applyAuditMarkerCarried
        this.productionQueueMutationRequested = productionQueueMutationRequested
        this.actualRuntimeTaskSpawnRequested = actualRuntimeTaskSpawnRequested
        this.actualHandlerInvocationRequested = actualHandlerInvocationRequested
        this.actualRequestContextMutationRequested =
            actualRequestContextMutationRequested
        this.actualResponseWriteRequested = actualResponseWriteRequested
        this.actualTransportCommitRequested = actualTransportCommitRequested
        this.actualLiveServerWiringRequested = actualLiveServerWiringRequested
        this.actualDefaultEngineFlipRequested =
            actualDefaultEngineFlipRequested
        this.defaultEngineConfigMutationRequested =
            defaultEngineConfigMutationRequested
        this.runtimeDefaultPathMutationRequested =
            runtimeDefaultPathMutationRequested
        this.publicReleaseRequested = publicReleaseRequested
        this.stdxRemovalRequested = stdxRemovalRequested
        this.h1H2QuicRuntimeClosureClaimed = h1H2QuicRuntimeClosureClaimed
    }
}

public class IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryReceipt {
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAccepted: Bool
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAccepted: Bool
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceMode: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryMode: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId: String
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String
    public let runtimeDefaultPathMutationApplyDryRunId: String
    public let runtimeDefaultPathMutationApplyBoundaryId: String
    public let runtimeDefaultPathMutationAcceptanceBoundaryId: String
    public let runtimeDefaultPathMutationHandoffGateId: String
    public let runtimeDefaultPathMutationCloseoutGateId: String
    public let controlledRuntimeDefaultPathMutationFinalizationApplyId: String
    public let runtimeDefaultPathMutationFinalizationGateId: String
    public let runtimeDefaultPathMutationCommitBoundaryId: String
    public let controlledRuntimeDefaultPathMutationCommitApplyId: String
    public let runtimeDefaultPathMutationCommitApplyGateId: String
    public let runtimeDefaultPathMutationCommitDryRunId: String
    public let runtimeDefaultPathMutationCommitPlanId: String
    public let controlledRuntimeDefaultPathMutationApplyId: String
    public let runtimeDefaultPathMutationApplyGateId: String
    public let runtimeDefaultPathMutationDryRunId: String
    public let runtimeDefaultPathMutationGateId: String
    public let controlledDefaultEngineMutationApplyId: String
    public let defaultEngineMutationApplyGateId: String
    public let defaultEngineMutationDryRunId: String
    public let defaultEngineMutationCommitPlanId: String
    public let controlledApplyDryRunAcceptanceReceipt: IgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceReceipt
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let actualHandlerInvocationAllowed: Bool
    public let actualRequestContextMutationAllowed: Bool
    public let actualResponseWriteAllowed: Bool
    public let actualTransportCommitAllowed: Bool
    public let actualLiveServerWiringAllowed: Bool
    public let actualDefaultEngineFlipAllowed: Bool
    public let defaultEngineConfigMutationAllowed: Bool
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h1H2QuicRuntimeClosureClaimAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAccepted: Bool,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAccepted: Bool,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceMode: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryMode: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId: String,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String,
        runtimeDefaultPathMutationApplyDryRunId: String,
        runtimeDefaultPathMutationApplyBoundaryId: String,
        runtimeDefaultPathMutationAcceptanceBoundaryId: String,
        runtimeDefaultPathMutationHandoffGateId: String,
        runtimeDefaultPathMutationCloseoutGateId: String,
        controlledRuntimeDefaultPathMutationFinalizationApplyId: String,
        runtimeDefaultPathMutationFinalizationGateId: String,
        runtimeDefaultPathMutationCommitBoundaryId: String,
        controlledRuntimeDefaultPathMutationCommitApplyId: String,
        runtimeDefaultPathMutationCommitApplyGateId: String,
        runtimeDefaultPathMutationCommitDryRunId: String,
        runtimeDefaultPathMutationCommitPlanId: String,
        controlledRuntimeDefaultPathMutationApplyId: String,
        runtimeDefaultPathMutationApplyGateId: String,
        runtimeDefaultPathMutationDryRunId: String,
        runtimeDefaultPathMutationGateId: String,
        controlledDefaultEngineMutationApplyId: String,
        defaultEngineMutationApplyGateId: String,
        defaultEngineMutationDryRunId: String,
        defaultEngineMutationCommitPlanId: String,
        controlledApplyDryRunAcceptanceReceipt: IgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceReceipt,
        runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        actualHandlerInvocationAllowed: Bool,
        actualRequestContextMutationAllowed: Bool,
        actualResponseWriteAllowed: Bool,
        actualTransportCommitAllowed: Bool,
        actualLiveServerWiringAllowed: Bool,
        actualDefaultEngineFlipAllowed: Bool,
        defaultEngineConfigMutationAllowed: Bool,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h1H2QuicRuntimeClosureClaimAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAccepted =
            runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAccepted
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAccepted =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAccepted
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceMode =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceMode
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryMode =
            runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryMode
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceGateId
        this.runtimeDefaultPathMutationApplyDryRunId =
            runtimeDefaultPathMutationApplyDryRunId
        this.runtimeDefaultPathMutationApplyBoundaryId =
            runtimeDefaultPathMutationApplyBoundaryId
        this.runtimeDefaultPathMutationAcceptanceBoundaryId =
            runtimeDefaultPathMutationAcceptanceBoundaryId
        this.runtimeDefaultPathMutationHandoffGateId =
            runtimeDefaultPathMutationHandoffGateId
        this.runtimeDefaultPathMutationCloseoutGateId =
            runtimeDefaultPathMutationCloseoutGateId
        this.controlledRuntimeDefaultPathMutationFinalizationApplyId =
            controlledRuntimeDefaultPathMutationFinalizationApplyId
        this.runtimeDefaultPathMutationFinalizationGateId =
            runtimeDefaultPathMutationFinalizationGateId
        this.runtimeDefaultPathMutationCommitBoundaryId =
            runtimeDefaultPathMutationCommitBoundaryId
        this.controlledRuntimeDefaultPathMutationCommitApplyId =
            controlledRuntimeDefaultPathMutationCommitApplyId
        this.runtimeDefaultPathMutationCommitApplyGateId =
            runtimeDefaultPathMutationCommitApplyGateId
        this.runtimeDefaultPathMutationCommitDryRunId =
            runtimeDefaultPathMutationCommitDryRunId
        this.runtimeDefaultPathMutationCommitPlanId =
            runtimeDefaultPathMutationCommitPlanId
        this.controlledRuntimeDefaultPathMutationApplyId =
            controlledRuntimeDefaultPathMutationApplyId
        this.runtimeDefaultPathMutationApplyGateId =
            runtimeDefaultPathMutationApplyGateId
        this.runtimeDefaultPathMutationDryRunId =
            runtimeDefaultPathMutationDryRunId
        this.runtimeDefaultPathMutationGateId =
            runtimeDefaultPathMutationGateId
        this.controlledDefaultEngineMutationApplyId =
            controlledDefaultEngineMutationApplyId
        this.defaultEngineMutationApplyGateId =
            defaultEngineMutationApplyGateId
        this.defaultEngineMutationDryRunId = defaultEngineMutationDryRunId
        this.defaultEngineMutationCommitPlanId =
            defaultEngineMutationCommitPlanId
        this.controlledApplyDryRunAcceptanceReceipt =
            controlledApplyDryRunAcceptanceReceipt
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryRecorded =
            runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAllowed =
            runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.actualRuntimeTaskSpawnAllowed = actualRuntimeTaskSpawnAllowed
        this.actualHandlerInvocationAllowed = actualHandlerInvocationAllowed
        this.actualRequestContextMutationAllowed =
            actualRequestContextMutationAllowed
        this.actualResponseWriteAllowed = actualResponseWriteAllowed
        this.actualTransportCommitAllowed = actualTransportCommitAllowed
        this.actualLiveServerWiringAllowed = actualLiveServerWiringAllowed
        this.actualDefaultEngineFlipAllowed = actualDefaultEngineFlipAllowed
        this.defaultEngineConfigMutationAllowed =
            defaultEngineConfigMutationAllowed
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h1H2QuicRuntimeClosureClaimAllowed =
            h1H2QuicRuntimeClosureClaimAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryReceipt(
    controlledApplyDryRunAcceptanceReceipt: IgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceReceipt,
    request: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryRequest
): IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryNonClaims()
    if (
        !controlledApplyDryRunAcceptanceReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryReceipt(
            false,
            controlledApplyDryRunAcceptanceReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAccepted,
            controlledApplyDryRunAcceptanceReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceMode,
            "none",
            request.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
            controlledApplyDryRunAcceptanceReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationApplyDryRunId,
            controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationApplyBoundaryId,
            controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationAcceptanceBoundaryId,
            controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationHandoffGateId,
            controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationCloseoutGateId,
            controlledApplyDryRunAcceptanceReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyId,
            controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationFinalizationGateId,
            controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationCommitBoundaryId,
            controlledApplyDryRunAcceptanceReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
            controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationCommitApplyGateId,
            controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationCommitDryRunId,
            controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationCommitPlanId,
            controlledApplyDryRunAcceptanceReceipt.controlledRuntimeDefaultPathMutationApplyId,
            controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationApplyGateId,
            controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationDryRunId,
            controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationGateId,
            controlledApplyDryRunAcceptanceReceipt.controlledDefaultEngineMutationApplyId,
            controlledApplyDryRunAcceptanceReceipt.defaultEngineMutationApplyGateId,
            controlledApplyDryRunAcceptanceReceipt.defaultEngineMutationDryRunId,
            controlledApplyDryRunAcceptanceReceipt.defaultEngineMutationCommitPlanId,
            controlledApplyDryRunAcceptanceReceipt,
            false,
            "block",
            "blocked-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-receipt",
            "collect-accepted-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-receipt-first",
            ["CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0501 controlled runtime default-path mutation apply-dry-run acceptance input before acceptance-boundary work",
            "QUIC must not consume runtime default-path mutation apply-dry-run acceptance boundary receipts from rejected controlled acceptances"
        )
    }

    let acceptanceBoundaryMode =
        igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryModeFor(
            controlledApplyDryRunAcceptanceReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryBlockers(
            request,
            acceptanceBoundaryMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryReceipt(
            false,
            controlledApplyDryRunAcceptanceReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAccepted,
            controlledApplyDryRunAcceptanceReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceMode,
            acceptanceBoundaryMode,
            request.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
            controlledApplyDryRunAcceptanceReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationApplyDryRunId,
            controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationApplyBoundaryId,
            controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationAcceptanceBoundaryId,
            controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationHandoffGateId,
            controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationCloseoutGateId,
            controlledApplyDryRunAcceptanceReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyId,
            controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationFinalizationGateId,
            controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationCommitBoundaryId,
            controlledApplyDryRunAcceptanceReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
            controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationCommitApplyGateId,
            controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationCommitDryRunId,
            controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationCommitPlanId,
            controlledApplyDryRunAcceptanceReceipt.controlledRuntimeDefaultPathMutationApplyId,
            controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationApplyGateId,
            controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationDryRunId,
            controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationGateId,
            controlledApplyDryRunAcceptanceReceipt.controlledDefaultEngineMutationApplyId,
            controlledApplyDryRunAcceptanceReceipt.defaultEngineMutationApplyGateId,
            controlledApplyDryRunAcceptanceReceipt.defaultEngineMutationDryRunId,
            controlledApplyDryRunAcceptanceReceipt.defaultEngineMutationCommitPlanId,
            controlledApplyDryRunAcceptanceReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-boundary-input",
            "fix-runtime-default-path-mutation-apply-dry-run-acceptance-boundary-before-runtime-default-mutation",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry apply-dry-run acceptance boundary id, controlled acceptance receipt, runtime default-path mutation lock, acceptance boundary marker, downstream consumer boundary, rollback order, runtime guard plan, observability marker, apply audit marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation apply-dry-run acceptance boundary blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryReceipt(
        true,
        controlledApplyDryRunAcceptanceReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAccepted,
        controlledApplyDryRunAcceptanceReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceMode,
        acceptanceBoundaryMode,
        request.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
        controlledApplyDryRunAcceptanceReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
        controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
        controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationApplyDryRunId,
        controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationApplyBoundaryId,
        controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationAcceptanceBoundaryId,
        controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationHandoffGateId,
        controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationCloseoutGateId,
        controlledApplyDryRunAcceptanceReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyId,
        controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationFinalizationGateId,
        controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationCommitBoundaryId,
        controlledApplyDryRunAcceptanceReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
        controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationCommitApplyGateId,
        controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationCommitDryRunId,
        controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationCommitPlanId,
        controlledApplyDryRunAcceptanceReceipt.controlledRuntimeDefaultPathMutationApplyId,
        controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationApplyGateId,
        controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationDryRunId,
        controlledApplyDryRunAcceptanceReceipt.runtimeDefaultPathMutationGateId,
        controlledApplyDryRunAcceptanceReceipt.controlledDefaultEngineMutationApplyId,
        controlledApplyDryRunAcceptanceReceipt.defaultEngineMutationApplyGateId,
        controlledApplyDryRunAcceptanceReceipt.defaultEngineMutationDryRunId,
        controlledApplyDryRunAcceptanceReceipt.defaultEngineMutationCommitPlanId,
        controlledApplyDryRunAcceptanceReceipt,
        true,
        "record-runtime-default-path-mutation-apply-dry-run-acceptance-boundary",
        "accepted-runtime-default-path-mutation-apply-dry-run-acceptance-boundary-receipt",
        "record-runtime-default-path-mutation-apply-dry-run-acceptance-boundary-without-runtime-default-mutation",
        [],
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
        nonClaims,
        "next packet may prove runtime default-path mutation apply-dry-run acceptance closeout gate or stdx claim separation without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation apply-dry-run acceptance boundary modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryModeFor(
    controlledAcceptanceMode: String
): String {
    if (
        controlledAcceptanceMode ==
        "short-controlled-runtime-default-path-mutation-apply-dry-run-acceptance"
    ) {
        return "short-runtime-default-path-mutation-apply-dry-run-acceptance-boundary"
    }
    if (
        controlledAcceptanceMode ==
        "long-controlled-runtime-default-path-mutation-apply-dry-run-acceptance"
    ) {
        return "long-runtime-default-path-mutation-apply-dry-run-acceptance-boundary"
    }
    if (
        controlledAcceptanceMode ==
        "blocking-isolation-controlled-runtime-default-path-mutation-apply-dry-run-acceptance"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-apply-dry-run-acceptance-boundary"
    }
    "unknown-runtime-default-path-mutation-apply-dry-run-acceptance-boundary"
}

func igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryBlockers(
    request: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryRequest,
    acceptanceBoundaryMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_BOUNDARY_ID_NOT_CARRIED")
    }
    if (!request.controlledApplyDryRunAcceptanceReceiptCarried) {
        blockers.add("CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_RECEIPT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.applyDryRunAcceptanceBoundaryCarried) {
        blockers.add("APPLY_DRY_RUN_ACCEPTANCE_BOUNDARY_NOT_CARRIED")
    }
    if (!request.downstreamConsumerBoundaryCarried) {
        blockers.add("DOWNSTREAM_CONSUMER_BOUNDARY_NOT_CARRIED")
    }
    if (!request.rollbackOrderCarried) {
        blockers.add("ROLLBACK_ORDER_NOT_CARRIED")
    }
    if (!request.runtimeGuardPlanCarried) {
        blockers.add("RUNTIME_GUARD_PLAN_NOT_CARRIED")
    }
    if (!request.observabilityMarkerCarried) {
        blockers.add("OBSERVABILITY_MARKER_NOT_CARRIED")
    }
    if (!request.applyAuditMarkerCarried) {
        blockers.add("APPLY_AUDIT_MARKER_NOT_CARRIED")
    }
    if (request.productionQueueMutationRequested) {
        blockers.add("PRODUCTION_QUEUE_MUTATION_REQUESTED")
    }
    if (request.actualRuntimeTaskSpawnRequested) {
        blockers.add("ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.actualHandlerInvocationRequested) {
        blockers.add("ACTUAL_HANDLER_INVOCATION_REQUESTED")
    }
    if (request.actualRequestContextMutationRequested) {
        blockers.add("ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.actualResponseWriteRequested) {
        blockers.add("ACTUAL_RESPONSE_WRITE_REQUESTED")
    }
    if (request.actualTransportCommitRequested) {
        blockers.add("ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.actualLiveServerWiringRequested) {
        blockers.add("ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    }
    if (request.actualDefaultEngineFlipRequested) {
        blockers.add("ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    }
    if (request.defaultEngineConfigMutationRequested) {
        blockers.add("DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    }
    if (request.runtimeDefaultPathMutationRequested) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    }
    if (request.publicReleaseRequested) {
        blockers.add("PUBLIC_RELEASE_REQUESTED")
    }
    if (request.stdxRemovalRequested) {
        blockers.add("STDX_REMOVAL_REQUESTED")
    }
    if (request.h1H2QuicRuntimeClosureClaimed) {
        blockers.add("H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    }
    if (
        acceptanceBoundaryMode ==
        "unknown-runtime-default-path-mutation-apply-dry-run-acceptance-boundary"
    ) {
        blockers.add("UNKNOWN_CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryNonClaims(): Array<String> {
    igniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceNonClaims()
}

public class IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateRequest {
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId: String
    public let applyDryRunAcceptanceBoundaryReceiptCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let applyDryRunAcceptanceCloseoutGateCarried: Bool
    public let downstreamConsumerBoundaryCarried: Bool
    public let rollbackOrderCarried: Bool
    public let runtimeGuardPlanCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let closeoutAuditMarkerCarried: Bool
    public let productionQueueMutationRequested: Bool
    public let actualRuntimeTaskSpawnRequested: Bool
    public let actualHandlerInvocationRequested: Bool
    public let actualRequestContextMutationRequested: Bool
    public let actualResponseWriteRequested: Bool
    public let actualTransportCommitRequested: Bool
    public let actualLiveServerWiringRequested: Bool
    public let actualDefaultEngineFlipRequested: Bool
    public let defaultEngineConfigMutationRequested: Bool
    public let runtimeDefaultPathMutationRequested: Bool
    public let publicReleaseRequested: Bool
    public let stdxRemovalRequested: Bool
    public let h1H2QuicRuntimeClosureClaimed: Bool

    public init(
        runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId: String,
        applyDryRunAcceptanceBoundaryReceiptCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        applyDryRunAcceptanceCloseoutGateCarried: Bool,
        downstreamConsumerBoundaryCarried: Bool,
        rollbackOrderCarried: Bool,
        runtimeGuardPlanCarried: Bool,
        observabilityMarkerCarried: Bool,
        closeoutAuditMarkerCarried: Bool,
        productionQueueMutationRequested: Bool,
        actualRuntimeTaskSpawnRequested: Bool,
        actualHandlerInvocationRequested: Bool,
        actualRequestContextMutationRequested: Bool,
        actualResponseWriteRequested: Bool,
        actualTransportCommitRequested: Bool,
        actualLiveServerWiringRequested: Bool,
        actualDefaultEngineFlipRequested: Bool,
        defaultEngineConfigMutationRequested: Bool,
        runtimeDefaultPathMutationRequested: Bool,
        publicReleaseRequested: Bool,
        stdxRemovalRequested: Bool,
        h1H2QuicRuntimeClosureClaimed: Bool
    ) {
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId
        this.applyDryRunAcceptanceBoundaryReceiptCarried =
            applyDryRunAcceptanceBoundaryReceiptCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.applyDryRunAcceptanceCloseoutGateCarried =
            applyDryRunAcceptanceCloseoutGateCarried
        this.downstreamConsumerBoundaryCarried =
            downstreamConsumerBoundaryCarried
        this.rollbackOrderCarried = rollbackOrderCarried
        this.runtimeGuardPlanCarried = runtimeGuardPlanCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
        this.closeoutAuditMarkerCarried = closeoutAuditMarkerCarried
        this.productionQueueMutationRequested = productionQueueMutationRequested
        this.actualRuntimeTaskSpawnRequested = actualRuntimeTaskSpawnRequested
        this.actualHandlerInvocationRequested = actualHandlerInvocationRequested
        this.actualRequestContextMutationRequested =
            actualRequestContextMutationRequested
        this.actualResponseWriteRequested = actualResponseWriteRequested
        this.actualTransportCommitRequested = actualTransportCommitRequested
        this.actualLiveServerWiringRequested = actualLiveServerWiringRequested
        this.actualDefaultEngineFlipRequested =
            actualDefaultEngineFlipRequested
        this.defaultEngineConfigMutationRequested =
            defaultEngineConfigMutationRequested
        this.runtimeDefaultPathMutationRequested =
            runtimeDefaultPathMutationRequested
        this.publicReleaseRequested = publicReleaseRequested
        this.stdxRemovalRequested = stdxRemovalRequested
        this.h1H2QuicRuntimeClosureClaimed = h1H2QuicRuntimeClosureClaimed
    }
}

public class IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateReceipt {
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryMode: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateMode: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId: String
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String
    public let applyDryRunAcceptanceBoundaryReceipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryReceipt
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let actualHandlerInvocationAllowed: Bool
    public let actualRequestContextMutationAllowed: Bool
    public let actualResponseWriteAllowed: Bool
    public let actualTransportCommitAllowed: Bool
    public let actualLiveServerWiringAllowed: Bool
    public let actualDefaultEngineFlipAllowed: Bool
    public let defaultEngineConfigMutationAllowed: Bool
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h1H2QuicRuntimeClosureClaimAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryMode: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateMode: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId: String,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String,
        applyDryRunAcceptanceBoundaryReceipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryReceipt,
        runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        actualHandlerInvocationAllowed: Bool,
        actualRequestContextMutationAllowed: Bool,
        actualResponseWriteAllowed: Bool,
        actualTransportCommitAllowed: Bool,
        actualLiveServerWiringAllowed: Bool,
        actualDefaultEngineFlipAllowed: Bool,
        defaultEngineConfigMutationAllowed: Bool,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h1H2QuicRuntimeClosureClaimAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAccepted =
            runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAccepted
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAccepted =
            runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAccepted
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryMode =
            runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryMode
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateMode =
            runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateMode
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceGateId
        this.applyDryRunAcceptanceBoundaryReceipt =
            applyDryRunAcceptanceBoundaryReceipt
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateRecorded =
            runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAllowed =
            runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.actualRuntimeTaskSpawnAllowed = actualRuntimeTaskSpawnAllowed
        this.actualHandlerInvocationAllowed = actualHandlerInvocationAllowed
        this.actualRequestContextMutationAllowed =
            actualRequestContextMutationAllowed
        this.actualResponseWriteAllowed = actualResponseWriteAllowed
        this.actualTransportCommitAllowed = actualTransportCommitAllowed
        this.actualLiveServerWiringAllowed = actualLiveServerWiringAllowed
        this.actualDefaultEngineFlipAllowed = actualDefaultEngineFlipAllowed
        this.defaultEngineConfigMutationAllowed =
            defaultEngineConfigMutationAllowed
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h1H2QuicRuntimeClosureClaimAllowed =
            h1H2QuicRuntimeClosureClaimAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateReceipt(
    applyDryRunAcceptanceBoundaryReceipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryReceipt,
    request: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateRequest
): IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateNonClaims()
    if (
        !applyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateReceipt(
            false,
            applyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAccepted,
            applyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryMode,
            "none",
            request.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
            applyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
            applyDryRunAcceptanceBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            applyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            applyDryRunAcceptanceBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-boundary-receipt",
            "collect-accepted-runtime-default-path-mutation-apply-dry-run-acceptance-boundary-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_BOUNDARY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0502 runtime default-path mutation apply-dry-run acceptance boundary input before closeout-gate work",
            "QUIC must not consume runtime default-path mutation apply-dry-run acceptance closeout gates from rejected acceptance boundaries"
        )
    }

    let closeoutGateMode =
        igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateModeFor(
            applyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateBlockers(
            request,
            closeoutGateMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateReceipt(
            false,
            applyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAccepted,
            applyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryMode,
            closeoutGateMode,
            request.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
            applyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
            applyDryRunAcceptanceBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            applyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            applyDryRunAcceptanceBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-closeout-gate-input",
            "fix-runtime-default-path-mutation-apply-dry-run-acceptance-closeout-gate-before-runtime-default-mutation",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry apply-dry-run acceptance closeout gate id, accepted boundary receipt, runtime default-path mutation lock, closeout gate marker, downstream consumer boundary, rollback order, runtime guard plan, observability marker, closeout audit marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation apply-dry-run acceptance closeout-gate blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateReceipt(
        true,
        applyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAccepted,
        applyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryMode,
        closeoutGateMode,
        request.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
        applyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
        applyDryRunAcceptanceBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
        applyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
        applyDryRunAcceptanceBoundaryReceipt,
        true,
        "record-runtime-default-path-mutation-apply-dry-run-acceptance-closeout-gate",
        "accepted-runtime-default-path-mutation-apply-dry-run-acceptance-closeout-gate-receipt",
        "record-runtime-default-path-mutation-apply-dry-run-acceptance-closeout-gate-without-runtime-default-mutation",
        [],
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
        nonClaims,
        "next packet may prove controlled runtime default-path mutation apply-dry-run acceptance handoff or stdx claim separation without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation apply-dry-run acceptance closeout-gate modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateModeFor(
    acceptanceBoundaryMode: String
): String {
    if (
        acceptanceBoundaryMode ==
        "short-runtime-default-path-mutation-apply-dry-run-acceptance-boundary"
    ) {
        return "short-runtime-default-path-mutation-apply-dry-run-acceptance-closeout-gate"
    }
    if (
        acceptanceBoundaryMode ==
        "long-runtime-default-path-mutation-apply-dry-run-acceptance-boundary"
    ) {
        return "long-runtime-default-path-mutation-apply-dry-run-acceptance-closeout-gate"
    }
    if (
        acceptanceBoundaryMode ==
        "blocking-isolation-runtime-default-path-mutation-apply-dry-run-acceptance-boundary"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-apply-dry-run-acceptance-closeout-gate"
    }
    "unknown-runtime-default-path-mutation-apply-dry-run-acceptance-closeout-gate"
}

func igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateBlockers(
    request: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateRequest,
    closeoutGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_CLOSEOUT_GATE_ID_NOT_CARRIED")
    }
    if (!request.applyDryRunAcceptanceBoundaryReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_BOUNDARY_RECEIPT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.applyDryRunAcceptanceCloseoutGateCarried) {
        blockers.add("APPLY_DRY_RUN_ACCEPTANCE_CLOSEOUT_GATE_NOT_CARRIED")
    }
    if (!request.downstreamConsumerBoundaryCarried) {
        blockers.add("DOWNSTREAM_CONSUMER_BOUNDARY_NOT_CARRIED")
    }
    if (!request.rollbackOrderCarried) {
        blockers.add("ROLLBACK_ORDER_NOT_CARRIED")
    }
    if (!request.runtimeGuardPlanCarried) {
        blockers.add("RUNTIME_GUARD_PLAN_NOT_CARRIED")
    }
    if (!request.observabilityMarkerCarried) {
        blockers.add("OBSERVABILITY_MARKER_NOT_CARRIED")
    }
    if (!request.closeoutAuditMarkerCarried) {
        blockers.add("CLOSEOUT_AUDIT_MARKER_NOT_CARRIED")
    }
    if (request.productionQueueMutationRequested) {
        blockers.add("PRODUCTION_QUEUE_MUTATION_REQUESTED")
    }
    if (request.actualRuntimeTaskSpawnRequested) {
        blockers.add("ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.actualHandlerInvocationRequested) {
        blockers.add("ACTUAL_HANDLER_INVOCATION_REQUESTED")
    }
    if (request.actualRequestContextMutationRequested) {
        blockers.add("ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.actualResponseWriteRequested) {
        blockers.add("ACTUAL_RESPONSE_WRITE_REQUESTED")
    }
    if (request.actualTransportCommitRequested) {
        blockers.add("ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.actualLiveServerWiringRequested) {
        blockers.add("ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    }
    if (request.actualDefaultEngineFlipRequested) {
        blockers.add("ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    }
    if (request.defaultEngineConfigMutationRequested) {
        blockers.add("DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    }
    if (request.runtimeDefaultPathMutationRequested) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    }
    if (request.publicReleaseRequested) {
        blockers.add("PUBLIC_RELEASE_REQUESTED")
    }
    if (request.stdxRemovalRequested) {
        blockers.add("STDX_REMOVAL_REQUESTED")
    }
    if (request.h1H2QuicRuntimeClosureClaimed) {
        blockers.add("H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    }
    if (
        closeoutGateMode ==
        "unknown-runtime-default-path-mutation-apply-dry-run-acceptance-closeout-gate"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_BOUNDARY")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryNonClaims()
}

public class IgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffRequest {
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId: String
    public let applyDryRunAcceptanceCloseoutGateReceiptCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let controlledApplyDryRunAcceptanceHandoffCarried: Bool
    public let downstreamConsumerBoundaryCarried: Bool
    public let rollbackOrderCarried: Bool
    public let runtimeGuardPlanCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let handoffAuditMarkerCarried: Bool
    public let productionQueueMutationRequested: Bool
    public let actualRuntimeTaskSpawnRequested: Bool
    public let actualHandlerInvocationRequested: Bool
    public let actualRequestContextMutationRequested: Bool
    public let actualResponseWriteRequested: Bool
    public let actualTransportCommitRequested: Bool
    public let actualLiveServerWiringRequested: Bool
    public let actualDefaultEngineFlipRequested: Bool
    public let defaultEngineConfigMutationRequested: Bool
    public let runtimeDefaultPathMutationRequested: Bool
    public let publicReleaseRequested: Bool
    public let stdxRemovalRequested: Bool
    public let h1H2QuicRuntimeClosureClaimed: Bool

    public init(
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId: String,
        applyDryRunAcceptanceCloseoutGateReceiptCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        controlledApplyDryRunAcceptanceHandoffCarried: Bool,
        downstreamConsumerBoundaryCarried: Bool,
        rollbackOrderCarried: Bool,
        runtimeGuardPlanCarried: Bool,
        observabilityMarkerCarried: Bool,
        handoffAuditMarkerCarried: Bool,
        productionQueueMutationRequested: Bool,
        actualRuntimeTaskSpawnRequested: Bool,
        actualHandlerInvocationRequested: Bool,
        actualRequestContextMutationRequested: Bool,
        actualResponseWriteRequested: Bool,
        actualTransportCommitRequested: Bool,
        actualLiveServerWiringRequested: Bool,
        actualDefaultEngineFlipRequested: Bool,
        defaultEngineConfigMutationRequested: Bool,
        runtimeDefaultPathMutationRequested: Bool,
        publicReleaseRequested: Bool,
        stdxRemovalRequested: Bool,
        h1H2QuicRuntimeClosureClaimed: Bool
    ) {
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId
        this.applyDryRunAcceptanceCloseoutGateReceiptCarried =
            applyDryRunAcceptanceCloseoutGateReceiptCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.controlledApplyDryRunAcceptanceHandoffCarried =
            controlledApplyDryRunAcceptanceHandoffCarried
        this.downstreamConsumerBoundaryCarried =
            downstreamConsumerBoundaryCarried
        this.rollbackOrderCarried = rollbackOrderCarried
        this.runtimeGuardPlanCarried = runtimeGuardPlanCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
        this.handoffAuditMarkerCarried = handoffAuditMarkerCarried
        this.productionQueueMutationRequested = productionQueueMutationRequested
        this.actualRuntimeTaskSpawnRequested = actualRuntimeTaskSpawnRequested
        this.actualHandlerInvocationRequested = actualHandlerInvocationRequested
        this.actualRequestContextMutationRequested =
            actualRequestContextMutationRequested
        this.actualResponseWriteRequested = actualResponseWriteRequested
        this.actualTransportCommitRequested = actualTransportCommitRequested
        this.actualLiveServerWiringRequested = actualLiveServerWiringRequested
        this.actualDefaultEngineFlipRequested =
            actualDefaultEngineFlipRequested
        this.defaultEngineConfigMutationRequested =
            defaultEngineConfigMutationRequested
        this.runtimeDefaultPathMutationRequested =
            runtimeDefaultPathMutationRequested
        this.publicReleaseRequested = publicReleaseRequested
        this.stdxRemovalRequested = stdxRemovalRequested
        this.h1H2QuicRuntimeClosureClaimed = h1H2QuicRuntimeClosureClaimed
    }
}

public class IgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffReceipt {
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateMode: String
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffMode: String
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId: String
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String
    public let applyDryRunAcceptanceCloseoutGateReceipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateReceipt
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let actualHandlerInvocationAllowed: Bool
    public let actualRequestContextMutationAllowed: Bool
    public let actualResponseWriteAllowed: Bool
    public let actualTransportCommitAllowed: Bool
    public let actualLiveServerWiringAllowed: Bool
    public let actualDefaultEngineFlipAllowed: Bool
    public let defaultEngineConfigMutationAllowed: Bool
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h1H2QuicRuntimeClosureClaimAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateMode: String,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffMode: String,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId: String,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String,
        applyDryRunAcceptanceCloseoutGateReceipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateReceipt,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        actualHandlerInvocationAllowed: Bool,
        actualRequestContextMutationAllowed: Bool,
        actualResponseWriteAllowed: Bool,
        actualTransportCommitAllowed: Bool,
        actualLiveServerWiringAllowed: Bool,
        actualDefaultEngineFlipAllowed: Bool,
        defaultEngineConfigMutationAllowed: Bool,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h1H2QuicRuntimeClosureClaimAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAccepted =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAccepted
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAccepted =
            runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAccepted
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateMode =
            runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateMode
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffMode =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffMode
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceGateId
        this.applyDryRunAcceptanceCloseoutGateReceipt =
            applyDryRunAcceptanceCloseoutGateReceipt
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffRecorded =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAllowed =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.actualRuntimeTaskSpawnAllowed = actualRuntimeTaskSpawnAllowed
        this.actualHandlerInvocationAllowed = actualHandlerInvocationAllowed
        this.actualRequestContextMutationAllowed =
            actualRequestContextMutationAllowed
        this.actualResponseWriteAllowed = actualResponseWriteAllowed
        this.actualTransportCommitAllowed = actualTransportCommitAllowed
        this.actualLiveServerWiringAllowed = actualLiveServerWiringAllowed
        this.actualDefaultEngineFlipAllowed = actualDefaultEngineFlipAllowed
        this.defaultEngineConfigMutationAllowed =
            defaultEngineConfigMutationAllowed
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h1H2QuicRuntimeClosureClaimAllowed =
            h1H2QuicRuntimeClosureClaimAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffReceipt(
    applyDryRunAcceptanceCloseoutGateReceipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateReceipt,
    request: IgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffRequest
): IgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffReceipt {
    let nonClaims =
        igniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffNonClaims()
    if (
        !applyDryRunAcceptanceCloseoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAccepted
    ) {
        return IgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffReceipt(
            false,
            applyDryRunAcceptanceCloseoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAccepted,
            applyDryRunAcceptanceCloseoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateMode,
            "none",
            request.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
            applyDryRunAcceptanceCloseoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
            applyDryRunAcceptanceCloseoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
            applyDryRunAcceptanceCloseoutGateReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            applyDryRunAcceptanceCloseoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            applyDryRunAcceptanceCloseoutGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-closeout-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-apply-dry-run-acceptance-closeout-gate-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_CLOSEOUT_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0503 runtime default-path mutation apply-dry-run acceptance closeout gate input before controlled handoff work",
            "QUIC must not consume controlled runtime default-path mutation apply-dry-run acceptance handoff receipts from rejected closeout gates"
        )
    }

    let handoffMode =
        igniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffModeFor(
            applyDryRunAcceptanceCloseoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateMode
        )
    let blockers =
        igniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBlockers(
            request,
            handoffMode
        )
    if (blockers.size > 0) {
        return IgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffReceipt(
            false,
            applyDryRunAcceptanceCloseoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAccepted,
            applyDryRunAcceptanceCloseoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateMode,
            handoffMode,
            request.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
            applyDryRunAcceptanceCloseoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
            applyDryRunAcceptanceCloseoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
            applyDryRunAcceptanceCloseoutGateReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            applyDryRunAcceptanceCloseoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            applyDryRunAcceptanceCloseoutGateReceipt,
            false,
            "block",
            "blocked-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-input",
            "fix-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-before-runtime-default-mutation",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry controlled apply-dry-run acceptance handoff id, accepted closeout gate receipt, runtime default-path mutation lock, controlled handoff marker, downstream consumer boundary, rollback order, runtime guard plan, observability marker, handoff audit marker, and keep runtime default mutation out",
            "QUIC can reuse the same controlled runtime default-path mutation apply-dry-run acceptance handoff blockers before default stream runtime mutation"
        )
    }

    IgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffReceipt(
        true,
        applyDryRunAcceptanceCloseoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAccepted,
        applyDryRunAcceptanceCloseoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateMode,
        handoffMode,
        request.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
        applyDryRunAcceptanceCloseoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
        applyDryRunAcceptanceCloseoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
        applyDryRunAcceptanceCloseoutGateReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
        applyDryRunAcceptanceCloseoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
        applyDryRunAcceptanceCloseoutGateReceipt,
        true,
        "record-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-handoff",
        "accepted-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-receipt",
        "record-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-without-runtime-default-mutation",
        [],
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
        nonClaims,
        "next packet may prove runtime default-path mutation apply-dry-run acceptance handoff boundary or stdx claim separation without mutating runtime defaults",
        "QUIC can reuse lane-specific controlled runtime default-path mutation apply-dry-run acceptance handoff modes before runtime default mutation"
    )
}

func igniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffModeFor(
    closeoutGateMode: String
): String {
    if (
        closeoutGateMode ==
        "short-runtime-default-path-mutation-apply-dry-run-acceptance-closeout-gate"
    ) {
        return "short-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-handoff"
    }
    if (
        closeoutGateMode ==
        "long-runtime-default-path-mutation-apply-dry-run-acceptance-closeout-gate"
    ) {
        return "long-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-handoff"
    }
    if (
        closeoutGateMode ==
        "blocking-isolation-runtime-default-path-mutation-apply-dry-run-acceptance-closeout-gate"
    ) {
        return "blocking-isolation-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-handoff"
    }
    "unknown-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-handoff"
}

func igniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBlockers(
    request: IgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffRequest,
    handoffMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId.size == 0
    ) {
        blockers.add("CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_ID_NOT_CARRIED")
    }
    if (!request.applyDryRunAcceptanceCloseoutGateReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_CLOSEOUT_GATE_RECEIPT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.controlledApplyDryRunAcceptanceHandoffCarried) {
        blockers.add("CONTROLLED_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_NOT_CARRIED")
    }
    if (!request.downstreamConsumerBoundaryCarried) {
        blockers.add("DOWNSTREAM_CONSUMER_BOUNDARY_NOT_CARRIED")
    }
    if (!request.rollbackOrderCarried) {
        blockers.add("ROLLBACK_ORDER_NOT_CARRIED")
    }
    if (!request.runtimeGuardPlanCarried) {
        blockers.add("RUNTIME_GUARD_PLAN_NOT_CARRIED")
    }
    if (!request.observabilityMarkerCarried) {
        blockers.add("OBSERVABILITY_MARKER_NOT_CARRIED")
    }
    if (!request.handoffAuditMarkerCarried) {
        blockers.add("HANDOFF_AUDIT_MARKER_NOT_CARRIED")
    }
    if (request.productionQueueMutationRequested) {
        blockers.add("PRODUCTION_QUEUE_MUTATION_REQUESTED")
    }
    if (request.actualRuntimeTaskSpawnRequested) {
        blockers.add("ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.actualHandlerInvocationRequested) {
        blockers.add("ACTUAL_HANDLER_INVOCATION_REQUESTED")
    }
    if (request.actualRequestContextMutationRequested) {
        blockers.add("ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.actualResponseWriteRequested) {
        blockers.add("ACTUAL_RESPONSE_WRITE_REQUESTED")
    }
    if (request.actualTransportCommitRequested) {
        blockers.add("ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.actualLiveServerWiringRequested) {
        blockers.add("ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    }
    if (request.actualDefaultEngineFlipRequested) {
        blockers.add("ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    }
    if (request.defaultEngineConfigMutationRequested) {
        blockers.add("DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    }
    if (request.runtimeDefaultPathMutationRequested) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    }
    if (request.publicReleaseRequested) {
        blockers.add("PUBLIC_RELEASE_REQUESTED")
    }
    if (request.stdxRemovalRequested) {
        blockers.add("STDX_REMOVAL_REQUESTED")
    }
    if (request.h1H2QuicRuntimeClosureClaimed) {
        blockers.add("H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    }
    if (
        handoffMode ==
        "unknown-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-handoff"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_CLOSEOUT_GATE")
    }
    blockers.toArray()
}

func igniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateNonClaims()
}

public class IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryRequest {
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId: String
    public let controlledApplyDryRunAcceptanceHandoffReceiptCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let applyDryRunAcceptanceHandoffBoundaryCarried: Bool
    public let downstreamConsumerBoundaryCarried: Bool
    public let rollbackOrderCarried: Bool
    public let runtimeGuardPlanCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let boundaryAuditMarkerCarried: Bool
    public let productionQueueMutationRequested: Bool
    public let actualRuntimeTaskSpawnRequested: Bool
    public let actualHandlerInvocationRequested: Bool
    public let actualRequestContextMutationRequested: Bool
    public let actualResponseWriteRequested: Bool
    public let actualTransportCommitRequested: Bool
    public let actualLiveServerWiringRequested: Bool
    public let actualDefaultEngineFlipRequested: Bool
    public let defaultEngineConfigMutationRequested: Bool
    public let runtimeDefaultPathMutationRequested: Bool
    public let publicReleaseRequested: Bool
    public let stdxRemovalRequested: Bool
    public let h1H2QuicRuntimeClosureClaimed: Bool

    public init(
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId: String,
        controlledApplyDryRunAcceptanceHandoffReceiptCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        applyDryRunAcceptanceHandoffBoundaryCarried: Bool,
        downstreamConsumerBoundaryCarried: Bool,
        rollbackOrderCarried: Bool,
        runtimeGuardPlanCarried: Bool,
        observabilityMarkerCarried: Bool,
        boundaryAuditMarkerCarried: Bool,
        productionQueueMutationRequested: Bool,
        actualRuntimeTaskSpawnRequested: Bool,
        actualHandlerInvocationRequested: Bool,
        actualRequestContextMutationRequested: Bool,
        actualResponseWriteRequested: Bool,
        actualTransportCommitRequested: Bool,
        actualLiveServerWiringRequested: Bool,
        actualDefaultEngineFlipRequested: Bool,
        defaultEngineConfigMutationRequested: Bool,
        runtimeDefaultPathMutationRequested: Bool,
        publicReleaseRequested: Bool,
        stdxRemovalRequested: Bool,
        h1H2QuicRuntimeClosureClaimed: Bool
    ) {
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId
        this.controlledApplyDryRunAcceptanceHandoffReceiptCarried =
            controlledApplyDryRunAcceptanceHandoffReceiptCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.applyDryRunAcceptanceHandoffBoundaryCarried =
            applyDryRunAcceptanceHandoffBoundaryCarried
        this.downstreamConsumerBoundaryCarried =
            downstreamConsumerBoundaryCarried
        this.rollbackOrderCarried = rollbackOrderCarried
        this.runtimeGuardPlanCarried = runtimeGuardPlanCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
        this.boundaryAuditMarkerCarried = boundaryAuditMarkerCarried
        this.productionQueueMutationRequested = productionQueueMutationRequested
        this.actualRuntimeTaskSpawnRequested = actualRuntimeTaskSpawnRequested
        this.actualHandlerInvocationRequested = actualHandlerInvocationRequested
        this.actualRequestContextMutationRequested =
            actualRequestContextMutationRequested
        this.actualResponseWriteRequested = actualResponseWriteRequested
        this.actualTransportCommitRequested = actualTransportCommitRequested
        this.actualLiveServerWiringRequested = actualLiveServerWiringRequested
        this.actualDefaultEngineFlipRequested =
            actualDefaultEngineFlipRequested
        this.defaultEngineConfigMutationRequested =
            defaultEngineConfigMutationRequested
        this.runtimeDefaultPathMutationRequested =
            runtimeDefaultPathMutationRequested
        this.publicReleaseRequested = publicReleaseRequested
        this.stdxRemovalRequested = stdxRemovalRequested
        this.h1H2QuicRuntimeClosureClaimed = h1H2QuicRuntimeClosureClaimed
    }
}

public class IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceipt {
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAccepted: Bool
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAccepted: Bool
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffMode: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryMode: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId: String
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId: String
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String
    public let controlledApplyDryRunAcceptanceHandoffReceipt: IgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffReceipt
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let actualHandlerInvocationAllowed: Bool
    public let actualRequestContextMutationAllowed: Bool
    public let actualResponseWriteAllowed: Bool
    public let actualTransportCommitAllowed: Bool
    public let actualLiveServerWiringAllowed: Bool
    public let actualDefaultEngineFlipAllowed: Bool
    public let defaultEngineConfigMutationAllowed: Bool
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h1H2QuicRuntimeClosureClaimAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAccepted: Bool,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAccepted: Bool,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffMode: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryMode: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId: String,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId: String,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String,
        controlledApplyDryRunAcceptanceHandoffReceipt: IgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffReceipt,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        actualHandlerInvocationAllowed: Bool,
        actualRequestContextMutationAllowed: Bool,
        actualResponseWriteAllowed: Bool,
        actualTransportCommitAllowed: Bool,
        actualLiveServerWiringAllowed: Bool,
        actualDefaultEngineFlipAllowed: Bool,
        defaultEngineConfigMutationAllowed: Bool,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h1H2QuicRuntimeClosureClaimAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAccepted =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAccepted
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAccepted =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAccepted
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffMode =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffMode
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryMode =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryMode
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceGateId
        this.controlledApplyDryRunAcceptanceHandoffReceipt =
            controlledApplyDryRunAcceptanceHandoffReceipt
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryRecorded =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAllowed =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.actualRuntimeTaskSpawnAllowed = actualRuntimeTaskSpawnAllowed
        this.actualHandlerInvocationAllowed = actualHandlerInvocationAllowed
        this.actualRequestContextMutationAllowed =
            actualRequestContextMutationAllowed
        this.actualResponseWriteAllowed = actualResponseWriteAllowed
        this.actualTransportCommitAllowed = actualTransportCommitAllowed
        this.actualLiveServerWiringAllowed = actualLiveServerWiringAllowed
        this.actualDefaultEngineFlipAllowed = actualDefaultEngineFlipAllowed
        this.defaultEngineConfigMutationAllowed =
            defaultEngineConfigMutationAllowed
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h1H2QuicRuntimeClosureClaimAllowed =
            h1H2QuicRuntimeClosureClaimAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceipt(
    controlledApplyDryRunAcceptanceHandoffReceipt: IgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffReceipt,
    request: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryRequest
): IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryNonClaims()
    if (
        !controlledApplyDryRunAcceptanceHandoffReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceipt(
            false,
            controlledApplyDryRunAcceptanceHandoffReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAccepted,
            controlledApplyDryRunAcceptanceHandoffReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffMode,
            "none",
            request.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId,
            controlledApplyDryRunAcceptanceHandoffReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
            controlledApplyDryRunAcceptanceHandoffReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
            controlledApplyDryRunAcceptanceHandoffReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
            controlledApplyDryRunAcceptanceHandoffReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            controlledApplyDryRunAcceptanceHandoffReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            controlledApplyDryRunAcceptanceHandoffReceipt,
            false,
            "block",
            "blocked-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-receipt",
            "collect-accepted-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-receipt-first",
            ["CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0504 controlled runtime default-path mutation apply-dry-run acceptance handoff input before handoff-boundary work",
            "QUIC must not consume runtime default-path mutation apply-dry-run acceptance handoff boundary receipts from rejected controlled handoffs"
        )
    }

    let handoffBoundaryMode =
        igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryModeFor(
            controlledApplyDryRunAcceptanceHandoffReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryBlockers(
            request,
            handoffBoundaryMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceipt(
            false,
            controlledApplyDryRunAcceptanceHandoffReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAccepted,
            controlledApplyDryRunAcceptanceHandoffReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffMode,
            handoffBoundaryMode,
            request.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId,
            controlledApplyDryRunAcceptanceHandoffReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
            controlledApplyDryRunAcceptanceHandoffReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
            controlledApplyDryRunAcceptanceHandoffReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
            controlledApplyDryRunAcceptanceHandoffReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            controlledApplyDryRunAcceptanceHandoffReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            controlledApplyDryRunAcceptanceHandoffReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-boundary-input",
            "fix-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-boundary-before-runtime-default-mutation",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry apply-dry-run acceptance handoff boundary id, accepted controlled handoff receipt, runtime default-path mutation lock, handoff boundary marker, downstream consumer boundary, rollback order, runtime guard plan, observability marker, boundary audit marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation apply-dry-run acceptance handoff-boundary blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceipt(
        true,
        controlledApplyDryRunAcceptanceHandoffReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAccepted,
        controlledApplyDryRunAcceptanceHandoffReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffMode,
        handoffBoundaryMode,
        request.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId,
        controlledApplyDryRunAcceptanceHandoffReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
        controlledApplyDryRunAcceptanceHandoffReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
        controlledApplyDryRunAcceptanceHandoffReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
        controlledApplyDryRunAcceptanceHandoffReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
        controlledApplyDryRunAcceptanceHandoffReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
        controlledApplyDryRunAcceptanceHandoffReceipt,
        true,
        "record-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-boundary",
        "accepted-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-boundary-receipt",
        "record-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-boundary-without-runtime-default-mutation",
        [],
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
        nonClaims,
        "next packet may prove runtime default-path mutation apply-dry-run acceptance handoff apply-boundary or stdx claim separation without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation apply-dry-run acceptance handoff-boundary modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryModeFor(
    controlledHandoffMode: String
): String {
    if (
        controlledHandoffMode ==
        "short-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-handoff"
    ) {
        return "short-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-boundary"
    }
    if (
        controlledHandoffMode ==
        "long-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-handoff"
    ) {
        return "long-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-boundary"
    }
    if (
        controlledHandoffMode ==
        "blocking-isolation-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-handoff"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-boundary"
    }
    "unknown-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-boundary"
}

func igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryBlockers(
    request: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryRequest,
    handoffBoundaryMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_BOUNDARY_ID_NOT_CARRIED")
    }
    if (!request.controlledApplyDryRunAcceptanceHandoffReceiptCarried) {
        blockers.add("CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_RECEIPT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.applyDryRunAcceptanceHandoffBoundaryCarried) {
        blockers.add("APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_BOUNDARY_NOT_CARRIED")
    }
    if (!request.downstreamConsumerBoundaryCarried) {
        blockers.add("DOWNSTREAM_CONSUMER_BOUNDARY_NOT_CARRIED")
    }
    if (!request.rollbackOrderCarried) {
        blockers.add("ROLLBACK_ORDER_NOT_CARRIED")
    }
    if (!request.runtimeGuardPlanCarried) {
        blockers.add("RUNTIME_GUARD_PLAN_NOT_CARRIED")
    }
    if (!request.observabilityMarkerCarried) {
        blockers.add("OBSERVABILITY_MARKER_NOT_CARRIED")
    }
    if (!request.boundaryAuditMarkerCarried) {
        blockers.add("BOUNDARY_AUDIT_MARKER_NOT_CARRIED")
    }
    if (request.productionQueueMutationRequested) {
        blockers.add("PRODUCTION_QUEUE_MUTATION_REQUESTED")
    }
    if (request.actualRuntimeTaskSpawnRequested) {
        blockers.add("ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.actualHandlerInvocationRequested) {
        blockers.add("ACTUAL_HANDLER_INVOCATION_REQUESTED")
    }
    if (request.actualRequestContextMutationRequested) {
        blockers.add("ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.actualResponseWriteRequested) {
        blockers.add("ACTUAL_RESPONSE_WRITE_REQUESTED")
    }
    if (request.actualTransportCommitRequested) {
        blockers.add("ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.actualLiveServerWiringRequested) {
        blockers.add("ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    }
    if (request.actualDefaultEngineFlipRequested) {
        blockers.add("ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    }
    if (request.defaultEngineConfigMutationRequested) {
        blockers.add("DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    }
    if (request.runtimeDefaultPathMutationRequested) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    }
    if (request.publicReleaseRequested) {
        blockers.add("PUBLIC_RELEASE_REQUESTED")
    }
    if (request.stdxRemovalRequested) {
        blockers.add("STDX_REMOVAL_REQUESTED")
    }
    if (request.h1H2QuicRuntimeClosureClaimed) {
        blockers.add("H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    }
    if (
        handoffBoundaryMode ==
        "unknown-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-boundary"
    ) {
        blockers.add("UNKNOWN_CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryNonClaims(): Array<String> {
    igniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffNonClaims()
}

public class IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryRequest {
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceiptCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let applyDryRunAcceptanceHandoffApplyBoundaryCarried: Bool
    public let downstreamConsumerBoundaryCarried: Bool
    public let rollbackOrderCarried: Bool
    public let runtimeGuardPlanCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let boundaryAuditMarkerCarried: Bool
    public let productionQueueMutationRequested: Bool
    public let actualRuntimeTaskSpawnRequested: Bool
    public let actualHandlerInvocationRequested: Bool
    public let actualRequestContextMutationRequested: Bool
    public let actualResponseWriteRequested: Bool
    public let actualTransportCommitRequested: Bool
    public let actualLiveServerWiringRequested: Bool
    public let actualDefaultEngineFlipRequested: Bool
    public let defaultEngineConfigMutationRequested: Bool
    public let runtimeDefaultPathMutationRequested: Bool
    public let publicReleaseRequested: Bool
    public let stdxRemovalRequested: Bool
    public let h1H2QuicRuntimeClosureClaimed: Bool

    public init(
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceiptCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        applyDryRunAcceptanceHandoffApplyBoundaryCarried: Bool,
        downstreamConsumerBoundaryCarried: Bool,
        rollbackOrderCarried: Bool,
        runtimeGuardPlanCarried: Bool,
        observabilityMarkerCarried: Bool,
        boundaryAuditMarkerCarried: Bool,
        productionQueueMutationRequested: Bool,
        actualRuntimeTaskSpawnRequested: Bool,
        actualHandlerInvocationRequested: Bool,
        actualRequestContextMutationRequested: Bool,
        actualResponseWriteRequested: Bool,
        actualTransportCommitRequested: Bool,
        actualLiveServerWiringRequested: Bool,
        actualDefaultEngineFlipRequested: Bool,
        defaultEngineConfigMutationRequested: Bool,
        runtimeDefaultPathMutationRequested: Bool,
        publicReleaseRequested: Bool,
        stdxRemovalRequested: Bool,
        h1H2QuicRuntimeClosureClaimed: Bool
    ) {
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceiptCarried =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceiptCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.applyDryRunAcceptanceHandoffApplyBoundaryCarried =
            applyDryRunAcceptanceHandoffApplyBoundaryCarried
        this.downstreamConsumerBoundaryCarried =
            downstreamConsumerBoundaryCarried
        this.rollbackOrderCarried = rollbackOrderCarried
        this.runtimeGuardPlanCarried = runtimeGuardPlanCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
        this.boundaryAuditMarkerCarried = boundaryAuditMarkerCarried
        this.productionQueueMutationRequested = productionQueueMutationRequested
        this.actualRuntimeTaskSpawnRequested = actualRuntimeTaskSpawnRequested
        this.actualHandlerInvocationRequested = actualHandlerInvocationRequested
        this.actualRequestContextMutationRequested =
            actualRequestContextMutationRequested
        this.actualResponseWriteRequested = actualResponseWriteRequested
        this.actualTransportCommitRequested = actualTransportCommitRequested
        this.actualLiveServerWiringRequested = actualLiveServerWiringRequested
        this.actualDefaultEngineFlipRequested =
            actualDefaultEngineFlipRequested
        this.defaultEngineConfigMutationRequested =
            defaultEngineConfigMutationRequested
        this.runtimeDefaultPathMutationRequested =
            runtimeDefaultPathMutationRequested
        this.publicReleaseRequested = publicReleaseRequested
        this.stdxRemovalRequested = stdxRemovalRequested
        this.h1H2QuicRuntimeClosureClaimed = h1H2QuicRuntimeClosureClaimed
    }
}

public class IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceipt {
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryMode: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryMode: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId: String
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId: String
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String
    public let handoffBoundaryReceipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceipt
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let actualHandlerInvocationAllowed: Bool
    public let actualRequestContextMutationAllowed: Bool
    public let actualResponseWriteAllowed: Bool
    public let actualTransportCommitAllowed: Bool
    public let actualLiveServerWiringAllowed: Bool
    public let actualDefaultEngineFlipAllowed: Bool
    public let defaultEngineConfigMutationAllowed: Bool
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h1H2QuicRuntimeClosureClaimAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryMode: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryMode: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId: String,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId: String,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String,
        handoffBoundaryReceipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceipt,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        actualHandlerInvocationAllowed: Bool,
        actualRequestContextMutationAllowed: Bool,
        actualResponseWriteAllowed: Bool,
        actualTransportCommitAllowed: Bool,
        actualLiveServerWiringAllowed: Bool,
        actualDefaultEngineFlipAllowed: Bool,
        defaultEngineConfigMutationAllowed: Bool,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h1H2QuicRuntimeClosureClaimAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAccepted =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAccepted
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAccepted =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAccepted
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryMode =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryMode
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryMode =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryMode
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceGateId
        this.handoffBoundaryReceipt = handoffBoundaryReceipt
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryRecorded =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAllowed =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.actualRuntimeTaskSpawnAllowed = actualRuntimeTaskSpawnAllowed
        this.actualHandlerInvocationAllowed = actualHandlerInvocationAllowed
        this.actualRequestContextMutationAllowed =
            actualRequestContextMutationAllowed
        this.actualResponseWriteAllowed = actualResponseWriteAllowed
        this.actualTransportCommitAllowed = actualTransportCommitAllowed
        this.actualLiveServerWiringAllowed = actualLiveServerWiringAllowed
        this.actualDefaultEngineFlipAllowed = actualDefaultEngineFlipAllowed
        this.defaultEngineConfigMutationAllowed =
            defaultEngineConfigMutationAllowed
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h1H2QuicRuntimeClosureClaimAllowed =
            h1H2QuicRuntimeClosureClaimAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceipt(
    handoffBoundaryReceipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceipt,
    request: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryRequest
): IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryNonClaims()
    if (
        !handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceipt(
            false,
            handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAccepted,
            handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryMode,
            "none",
            request.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId,
            handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId,
            handoffBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
            handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
            handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
            handoffBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            handoffBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-boundary-receipt",
            "collect-accepted-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-boundary-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_BOUNDARY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0505 runtime default-path mutation apply-dry-run acceptance handoff-boundary input before handoff apply-boundary work",
            "QUIC must not consume handoff apply-boundary receipts from rejected runtime default-path mutation handoff-boundary receipts"
        )
    }

    let handoffApplyBoundaryMode =
        igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryModeFor(
            handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryBlockers(
            request,
            handoffApplyBoundaryMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceipt(
            false,
            handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAccepted,
            handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryMode,
            handoffApplyBoundaryMode,
            request.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId,
            handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId,
            handoffBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
            handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
            handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
            handoffBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            handoffBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-input",
            "fix-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-before-runtime-default-mutation",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry handoff apply-boundary id, accepted handoff-boundary receipt, runtime default-path mutation lock, handoff apply-boundary marker, downstream consumer boundary, rollback order, runtime guard plan, observability marker, boundary audit marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation handoff apply-boundary blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceipt(
        true,
        handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAccepted,
        handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryMode,
        handoffApplyBoundaryMode,
        request.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId,
        handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId,
        handoffBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
        handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
        handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
        handoffBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
        handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
        handoffBoundaryReceipt,
        true,
        "record-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary",
        "accepted-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-receipt",
        "record-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-without-runtime-default-mutation",
        [],
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
        nonClaims,
        "next packet may prove runtime default-path mutation apply-dry-run acceptance handoff apply-boundary gate or stdx claim separation without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation apply-dry-run acceptance handoff apply-boundary modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryModeFor(
    handoffBoundaryMode: String
): String {
    if (
        handoffBoundaryMode ==
        "short-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-boundary"
    ) {
        return "short-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary"
    }
    if (
        handoffBoundaryMode ==
        "long-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-boundary"
    ) {
        return "long-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary"
    }
    if (
        handoffBoundaryMode ==
        "blocking-isolation-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-boundary"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary"
    }
    "unknown-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary"
}

func igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryBlockers(
    request: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryRequest,
    handoffApplyBoundaryMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_ID_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_BOUNDARY_RECEIPT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.applyDryRunAcceptanceHandoffApplyBoundaryCarried) {
        blockers.add("APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_NOT_CARRIED")
    }
    if (!request.downstreamConsumerBoundaryCarried) {
        blockers.add("DOWNSTREAM_CONSUMER_BOUNDARY_NOT_CARRIED")
    }
    if (!request.rollbackOrderCarried) {
        blockers.add("ROLLBACK_ORDER_NOT_CARRIED")
    }
    if (!request.runtimeGuardPlanCarried) {
        blockers.add("RUNTIME_GUARD_PLAN_NOT_CARRIED")
    }
    if (!request.observabilityMarkerCarried) {
        blockers.add("OBSERVABILITY_MARKER_NOT_CARRIED")
    }
    if (!request.boundaryAuditMarkerCarried) {
        blockers.add("BOUNDARY_AUDIT_MARKER_NOT_CARRIED")
    }
    if (request.productionQueueMutationRequested) {
        blockers.add("PRODUCTION_QUEUE_MUTATION_REQUESTED")
    }
    if (request.actualRuntimeTaskSpawnRequested) {
        blockers.add("ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.actualHandlerInvocationRequested) {
        blockers.add("ACTUAL_HANDLER_INVOCATION_REQUESTED")
    }
    if (request.actualRequestContextMutationRequested) {
        blockers.add("ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.actualResponseWriteRequested) {
        blockers.add("ACTUAL_RESPONSE_WRITE_REQUESTED")
    }
    if (request.actualTransportCommitRequested) {
        blockers.add("ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.actualLiveServerWiringRequested) {
        blockers.add("ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    }
    if (request.actualDefaultEngineFlipRequested) {
        blockers.add("ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    }
    if (request.defaultEngineConfigMutationRequested) {
        blockers.add("DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    }
    if (request.runtimeDefaultPathMutationRequested) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    }
    if (request.publicReleaseRequested) {
        blockers.add("PUBLIC_RELEASE_REQUESTED")
    }
    if (request.stdxRemovalRequested) {
        blockers.add("STDX_REMOVAL_REQUESTED")
    }
    if (request.h1H2QuicRuntimeClosureClaimed) {
        blockers.add("H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    }
    if (
        handoffApplyBoundaryMode ==
        "unknown-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_BOUNDARY")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryNonClaims()
}

public class IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateRequest {
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceiptCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let applyDryRunAcceptanceHandoffApplyBoundaryGateCarried: Bool
    public let downstreamConsumerBoundaryCarried: Bool
    public let rollbackOrderCarried: Bool
    public let runtimeGuardPlanCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let boundaryAuditMarkerCarried: Bool
    public let productionQueueMutationRequested: Bool
    public let actualRuntimeTaskSpawnRequested: Bool
    public let actualHandlerInvocationRequested: Bool
    public let actualRequestContextMutationRequested: Bool
    public let actualResponseWriteRequested: Bool
    public let actualTransportCommitRequested: Bool
    public let actualLiveServerWiringRequested: Bool
    public let actualDefaultEngineFlipRequested: Bool
    public let defaultEngineConfigMutationRequested: Bool
    public let runtimeDefaultPathMutationRequested: Bool
    public let publicReleaseRequested: Bool
    public let stdxRemovalRequested: Bool
    public let h1H2QuicRuntimeClosureClaimed: Bool

    public init(
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceiptCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        applyDryRunAcceptanceHandoffApplyBoundaryGateCarried: Bool,
        downstreamConsumerBoundaryCarried: Bool,
        rollbackOrderCarried: Bool,
        runtimeGuardPlanCarried: Bool,
        observabilityMarkerCarried: Bool,
        boundaryAuditMarkerCarried: Bool,
        productionQueueMutationRequested: Bool,
        actualRuntimeTaskSpawnRequested: Bool,
        actualHandlerInvocationRequested: Bool,
        actualRequestContextMutationRequested: Bool,
        actualResponseWriteRequested: Bool,
        actualTransportCommitRequested: Bool,
        actualLiveServerWiringRequested: Bool,
        actualDefaultEngineFlipRequested: Bool,
        defaultEngineConfigMutationRequested: Bool,
        runtimeDefaultPathMutationRequested: Bool,
        publicReleaseRequested: Bool,
        stdxRemovalRequested: Bool,
        h1H2QuicRuntimeClosureClaimed: Bool
    ) {
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceiptCarried =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceiptCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.applyDryRunAcceptanceHandoffApplyBoundaryGateCarried =
            applyDryRunAcceptanceHandoffApplyBoundaryGateCarried
        this.downstreamConsumerBoundaryCarried =
            downstreamConsumerBoundaryCarried
        this.rollbackOrderCarried = rollbackOrderCarried
        this.runtimeGuardPlanCarried = runtimeGuardPlanCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
        this.boundaryAuditMarkerCarried = boundaryAuditMarkerCarried
        this.productionQueueMutationRequested = productionQueueMutationRequested
        this.actualRuntimeTaskSpawnRequested = actualRuntimeTaskSpawnRequested
        this.actualHandlerInvocationRequested = actualHandlerInvocationRequested
        this.actualRequestContextMutationRequested =
            actualRequestContextMutationRequested
        this.actualResponseWriteRequested = actualResponseWriteRequested
        this.actualTransportCommitRequested = actualTransportCommitRequested
        this.actualLiveServerWiringRequested = actualLiveServerWiringRequested
        this.actualDefaultEngineFlipRequested =
            actualDefaultEngineFlipRequested
        this.defaultEngineConfigMutationRequested =
            defaultEngineConfigMutationRequested
        this.runtimeDefaultPathMutationRequested =
            runtimeDefaultPathMutationRequested
        this.publicReleaseRequested = publicReleaseRequested
        this.stdxRemovalRequested = stdxRemovalRequested
        this.h1H2QuicRuntimeClosureClaimed = h1H2QuicRuntimeClosureClaimed
    }
}

public class IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceipt {
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryMode: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateMode: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId: String
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId: String
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String
    public let handoffApplyBoundaryReceipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceipt
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let actualHandlerInvocationAllowed: Bool
    public let actualRequestContextMutationAllowed: Bool
    public let actualResponseWriteAllowed: Bool
    public let actualTransportCommitAllowed: Bool
    public let actualLiveServerWiringAllowed: Bool
    public let actualDefaultEngineFlipAllowed: Bool
    public let defaultEngineConfigMutationAllowed: Bool
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h1H2QuicRuntimeClosureClaimAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryMode: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateMode: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId: String,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId: String,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String,
        handoffApplyBoundaryReceipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceipt,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        actualHandlerInvocationAllowed: Bool,
        actualRequestContextMutationAllowed: Bool,
        actualResponseWriteAllowed: Bool,
        actualTransportCommitAllowed: Bool,
        actualLiveServerWiringAllowed: Bool,
        actualDefaultEngineFlipAllowed: Bool,
        defaultEngineConfigMutationAllowed: Bool,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h1H2QuicRuntimeClosureClaimAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAccepted =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAccepted
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAccepted =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAccepted
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryMode =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryMode
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateMode =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateMode
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceGateId
        this.handoffApplyBoundaryReceipt = handoffApplyBoundaryReceipt
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateRecorded =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAllowed =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.actualRuntimeTaskSpawnAllowed = actualRuntimeTaskSpawnAllowed
        this.actualHandlerInvocationAllowed = actualHandlerInvocationAllowed
        this.actualRequestContextMutationAllowed =
            actualRequestContextMutationAllowed
        this.actualResponseWriteAllowed = actualResponseWriteAllowed
        this.actualTransportCommitAllowed = actualTransportCommitAllowed
        this.actualLiveServerWiringAllowed = actualLiveServerWiringAllowed
        this.actualDefaultEngineFlipAllowed = actualDefaultEngineFlipAllowed
        this.defaultEngineConfigMutationAllowed =
            defaultEngineConfigMutationAllowed
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h1H2QuicRuntimeClosureClaimAllowed =
            h1H2QuicRuntimeClosureClaimAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceipt(
    handoffApplyBoundaryReceipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceipt,
    request: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateRequest
): IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateNonClaims()
    if (
        !handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceipt(
            false,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAccepted,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryMode,
            "none",
            request.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId,
            handoffApplyBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
            handoffApplyBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            handoffApplyBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-receipt",
            "collect-accepted-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0506 runtime default-path mutation apply-dry-run acceptance handoff apply-boundary input before handoff apply-boundary gate work",
            "QUIC must not consume handoff apply-boundary gate receipts from rejected runtime default-path mutation handoff apply-boundary receipts"
        )
    }

    let handoffApplyBoundaryGateMode =
        igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateModeFor(
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateBlockers(
            request,
            handoffApplyBoundaryGateMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceipt(
            false,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAccepted,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryMode,
            handoffApplyBoundaryGateMode,
            request.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId,
            handoffApplyBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
            handoffApplyBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            handoffApplyBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-input",
            "fix-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-before-runtime-default-mutation",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry handoff apply-boundary gate id, accepted handoff apply-boundary receipt, runtime default-path mutation lock, handoff apply-boundary gate marker, downstream consumer boundary, rollback order, runtime guard plan, observability marker, boundary audit marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation handoff apply-boundary gate blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceipt(
        true,
        handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAccepted,
        handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryMode,
        handoffApplyBoundaryGateMode,
        request.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId,
        handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId,
        handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId,
        handoffApplyBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
        handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
        handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
        handoffApplyBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
        handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
        handoffApplyBoundaryReceipt,
        true,
        "record-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate",
        "accepted-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-receipt",
        "record-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-without-runtime-default-mutation",
        [],
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
        nonClaims,
        "next packet may prove runtime default-path mutation apply-dry-run acceptance handoff apply-boundary gate closeout or stdx claim separation without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation apply-dry-run acceptance handoff apply-boundary gate modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateModeFor(
    handoffApplyBoundaryMode: String
): String {
    if (
        handoffApplyBoundaryMode ==
        "short-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary"
    ) {
        return "short-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate"
    }
    if (
        handoffApplyBoundaryMode ==
        "long-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary"
    ) {
        return "long-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate"
    }
    if (
        handoffApplyBoundaryMode ==
        "blocking-isolation-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate"
    }
    "unknown-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate"
}

func igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateBlockers(
    request: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateRequest,
    handoffApplyBoundaryGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_ID_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_RECEIPT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.applyDryRunAcceptanceHandoffApplyBoundaryGateCarried) {
        blockers.add("APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_NOT_CARRIED")
    }
    if (!request.downstreamConsumerBoundaryCarried) {
        blockers.add("DOWNSTREAM_CONSUMER_BOUNDARY_NOT_CARRIED")
    }
    if (!request.rollbackOrderCarried) {
        blockers.add("ROLLBACK_ORDER_NOT_CARRIED")
    }
    if (!request.runtimeGuardPlanCarried) {
        blockers.add("RUNTIME_GUARD_PLAN_NOT_CARRIED")
    }
    if (!request.observabilityMarkerCarried) {
        blockers.add("OBSERVABILITY_MARKER_NOT_CARRIED")
    }
    if (!request.boundaryAuditMarkerCarried) {
        blockers.add("BOUNDARY_AUDIT_MARKER_NOT_CARRIED")
    }
    if (request.productionQueueMutationRequested) {
        blockers.add("PRODUCTION_QUEUE_MUTATION_REQUESTED")
    }
    if (request.actualRuntimeTaskSpawnRequested) {
        blockers.add("ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.actualHandlerInvocationRequested) {
        blockers.add("ACTUAL_HANDLER_INVOCATION_REQUESTED")
    }
    if (request.actualRequestContextMutationRequested) {
        blockers.add("ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.actualResponseWriteRequested) {
        blockers.add("ACTUAL_RESPONSE_WRITE_REQUESTED")
    }
    if (request.actualTransportCommitRequested) {
        blockers.add("ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.actualLiveServerWiringRequested) {
        blockers.add("ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    }
    if (request.actualDefaultEngineFlipRequested) {
        blockers.add("ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    }
    if (request.defaultEngineConfigMutationRequested) {
        blockers.add("DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    }
    if (request.runtimeDefaultPathMutationRequested) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    }
    if (request.publicReleaseRequested) {
        blockers.add("PUBLIC_RELEASE_REQUESTED")
    }
    if (request.stdxRemovalRequested) {
        blockers.add("STDX_REMOVAL_REQUESTED")
    }
    if (request.h1H2QuicRuntimeClosureClaimed) {
        blockers.add("H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    }
    if (
        handoffApplyBoundaryGateMode ==
        "unknown-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryNonClaims()
}

public class IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutRequest {
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceiptCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let applyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutCarried: Bool
    public let downstreamConsumerBoundaryCarried: Bool
    public let rollbackOrderCarried: Bool
    public let runtimeGuardPlanCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let boundaryAuditMarkerCarried: Bool
    public let closeoutLedgerMarkerCarried: Bool
    public let productionQueueMutationRequested: Bool
    public let actualRuntimeTaskSpawnRequested: Bool
    public let actualHandlerInvocationRequested: Bool
    public let actualRequestContextMutationRequested: Bool
    public let actualResponseWriteRequested: Bool
    public let actualTransportCommitRequested: Bool
    public let actualLiveServerWiringRequested: Bool
    public let actualDefaultEngineFlipRequested: Bool
    public let defaultEngineConfigMutationRequested: Bool
    public let runtimeDefaultPathMutationRequested: Bool
    public let publicReleaseRequested: Bool
    public let stdxRemovalRequested: Bool
    public let h1H2QuicRuntimeClosureClaimed: Bool

    public init(
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceiptCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        applyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutCarried: Bool,
        downstreamConsumerBoundaryCarried: Bool,
        rollbackOrderCarried: Bool,
        runtimeGuardPlanCarried: Bool,
        observabilityMarkerCarried: Bool,
        boundaryAuditMarkerCarried: Bool,
        closeoutLedgerMarkerCarried: Bool,
        productionQueueMutationRequested: Bool,
        actualRuntimeTaskSpawnRequested: Bool,
        actualHandlerInvocationRequested: Bool,
        actualRequestContextMutationRequested: Bool,
        actualResponseWriteRequested: Bool,
        actualTransportCommitRequested: Bool,
        actualLiveServerWiringRequested: Bool,
        actualDefaultEngineFlipRequested: Bool,
        defaultEngineConfigMutationRequested: Bool,
        runtimeDefaultPathMutationRequested: Bool,
        publicReleaseRequested: Bool,
        stdxRemovalRequested: Bool,
        h1H2QuicRuntimeClosureClaimed: Bool
    ) {
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceiptCarried =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceiptCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.applyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutCarried =
            applyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutCarried
        this.downstreamConsumerBoundaryCarried =
            downstreamConsumerBoundaryCarried
        this.rollbackOrderCarried = rollbackOrderCarried
        this.runtimeGuardPlanCarried = runtimeGuardPlanCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
        this.boundaryAuditMarkerCarried = boundaryAuditMarkerCarried
        this.closeoutLedgerMarkerCarried = closeoutLedgerMarkerCarried
        this.productionQueueMutationRequested = productionQueueMutationRequested
        this.actualRuntimeTaskSpawnRequested = actualRuntimeTaskSpawnRequested
        this.actualHandlerInvocationRequested = actualHandlerInvocationRequested
        this.actualRequestContextMutationRequested =
            actualRequestContextMutationRequested
        this.actualResponseWriteRequested = actualResponseWriteRequested
        this.actualTransportCommitRequested = actualTransportCommitRequested
        this.actualLiveServerWiringRequested = actualLiveServerWiringRequested
        this.actualDefaultEngineFlipRequested =
            actualDefaultEngineFlipRequested
        this.defaultEngineConfigMutationRequested =
            defaultEngineConfigMutationRequested
        this.runtimeDefaultPathMutationRequested =
            runtimeDefaultPathMutationRequested
        this.publicReleaseRequested = publicReleaseRequested
        this.stdxRemovalRequested = stdxRemovalRequested
        this.h1H2QuicRuntimeClosureClaimed = h1H2QuicRuntimeClosureClaimed
    }
}

public class IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceipt {
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateMode: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutMode: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId: String
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId: String
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String
    public let handoffApplyBoundaryGateReceipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceipt
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let actualHandlerInvocationAllowed: Bool
    public let actualRequestContextMutationAllowed: Bool
    public let actualResponseWriteAllowed: Bool
    public let actualTransportCommitAllowed: Bool
    public let actualLiveServerWiringAllowed: Bool
    public let actualDefaultEngineFlipAllowed: Bool
    public let defaultEngineConfigMutationAllowed: Bool
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h1H2QuicRuntimeClosureClaimAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateMode: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutMode: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId: String,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId: String,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String,
        handoffApplyBoundaryGateReceipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceipt,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        actualHandlerInvocationAllowed: Bool,
        actualRequestContextMutationAllowed: Bool,
        actualResponseWriteAllowed: Bool,
        actualTransportCommitAllowed: Bool,
        actualLiveServerWiringAllowed: Bool,
        actualDefaultEngineFlipAllowed: Bool,
        defaultEngineConfigMutationAllowed: Bool,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h1H2QuicRuntimeClosureClaimAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAccepted =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAccepted
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAccepted =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAccepted
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateMode =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateMode
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutMode =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutMode
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceGateId
        this.handoffApplyBoundaryGateReceipt = handoffApplyBoundaryGateReceipt
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutRecorded =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAllowed =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.actualRuntimeTaskSpawnAllowed = actualRuntimeTaskSpawnAllowed
        this.actualHandlerInvocationAllowed = actualHandlerInvocationAllowed
        this.actualRequestContextMutationAllowed =
            actualRequestContextMutationAllowed
        this.actualResponseWriteAllowed = actualResponseWriteAllowed
        this.actualTransportCommitAllowed = actualTransportCommitAllowed
        this.actualLiveServerWiringAllowed = actualLiveServerWiringAllowed
        this.actualDefaultEngineFlipAllowed = actualDefaultEngineFlipAllowed
        this.defaultEngineConfigMutationAllowed =
            defaultEngineConfigMutationAllowed
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h1H2QuicRuntimeClosureClaimAllowed =
            h1H2QuicRuntimeClosureClaimAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceipt(
    handoffApplyBoundaryGateReceipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceipt,
    request: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutRequest
): IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutNonClaims()
    if (
        !handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceipt(
            false,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAccepted,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateMode,
            "none",
            request.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutId,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId,
            handoffApplyBoundaryGateReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
            handoffApplyBoundaryGateReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            handoffApplyBoundaryGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0507 runtime default-path mutation apply-dry-run acceptance handoff apply-boundary gate input before closeout work",
            "QUIC must not consume handoff apply-boundary gate closeout receipts from rejected runtime default-path mutation handoff apply-boundary gate receipts"
        )
    }

    let handoffApplyBoundaryGateCloseoutMode =
        igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutModeFor(
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBlockers(
            request,
            handoffApplyBoundaryGateCloseoutMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceipt(
            false,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAccepted,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateMode,
            handoffApplyBoundaryGateCloseoutMode,
            request.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutId,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId,
            handoffApplyBoundaryGateReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
            handoffApplyBoundaryGateReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            handoffApplyBoundaryGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-input",
            "fix-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-before-runtime-default-mutation",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry handoff apply-boundary gate closeout id, accepted gate receipt, runtime default-path mutation lock, closeout marker, downstream consumer boundary, rollback order, runtime guard plan, observability marker, boundary audit marker, closeout ledger marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation handoff apply-boundary gate closeout blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceipt(
        true,
        handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAccepted,
        handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateMode,
        handoffApplyBoundaryGateCloseoutMode,
        request.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutId,
        handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId,
        handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId,
        handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId,
        handoffApplyBoundaryGateReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
        handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
        handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
        handoffApplyBoundaryGateReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
        handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
        handoffApplyBoundaryGateReceipt,
        true,
        "record-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout",
        "accepted-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-receipt",
        "record-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-without-runtime-default-mutation",
        [],
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
        nonClaims,
        "next packet may prove stdx claim separation or runtime default mutation preparation without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation apply-dry-run acceptance handoff apply-boundary gate closeout modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutModeFor(
    handoffApplyBoundaryGateMode: String
): String {
    if (
        handoffApplyBoundaryGateMode ==
        "short-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate"
    ) {
        return "short-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout"
    }
    if (
        handoffApplyBoundaryGateMode ==
        "long-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate"
    ) {
        return "long-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout"
    }
    if (
        handoffApplyBoundaryGateMode ==
        "blocking-isolation-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout"
    }
    "unknown-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout"
}

func igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBlockers(
    request: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutRequest,
    handoffApplyBoundaryGateCloseoutMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_ID_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_RECEIPT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.applyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutCarried) {
        blockers.add("APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_NOT_CARRIED")
    }
    if (!request.downstreamConsumerBoundaryCarried) {
        blockers.add("DOWNSTREAM_CONSUMER_BOUNDARY_NOT_CARRIED")
    }
    if (!request.rollbackOrderCarried) {
        blockers.add("ROLLBACK_ORDER_NOT_CARRIED")
    }
    if (!request.runtimeGuardPlanCarried) {
        blockers.add("RUNTIME_GUARD_PLAN_NOT_CARRIED")
    }
    if (!request.observabilityMarkerCarried) {
        blockers.add("OBSERVABILITY_MARKER_NOT_CARRIED")
    }
    if (!request.boundaryAuditMarkerCarried) {
        blockers.add("BOUNDARY_AUDIT_MARKER_NOT_CARRIED")
    }
    if (!request.closeoutLedgerMarkerCarried) {
        blockers.add("CLOSEOUT_LEDGER_MARKER_NOT_CARRIED")
    }
    if (request.productionQueueMutationRequested) {
        blockers.add("PRODUCTION_QUEUE_MUTATION_REQUESTED")
    }
    if (request.actualRuntimeTaskSpawnRequested) {
        blockers.add("ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.actualHandlerInvocationRequested) {
        blockers.add("ACTUAL_HANDLER_INVOCATION_REQUESTED")
    }
    if (request.actualRequestContextMutationRequested) {
        blockers.add("ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.actualResponseWriteRequested) {
        blockers.add("ACTUAL_RESPONSE_WRITE_REQUESTED")
    }
    if (request.actualTransportCommitRequested) {
        blockers.add("ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.actualLiveServerWiringRequested) {
        blockers.add("ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    }
    if (request.actualDefaultEngineFlipRequested) {
        blockers.add("ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    }
    if (request.defaultEngineConfigMutationRequested) {
        blockers.add("DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    }
    if (request.runtimeDefaultPathMutationRequested) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    }
    if (request.publicReleaseRequested) {
        blockers.add("PUBLIC_RELEASE_REQUESTED")
    }
    if (request.stdxRemovalRequested) {
        blockers.add("STDX_REMOVAL_REQUESTED")
    }
    if (request.h1H2QuicRuntimeClosureClaimed) {
        blockers.add("H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    }
    if (
        handoffApplyBoundaryGateCloseoutMode ==
        "unknown-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateNonClaims()
}

public class IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryRequest {
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceiptCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let applyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryCarried: Bool
    public let downstreamConsumerBoundaryCarried: Bool
    public let rollbackOrderCarried: Bool
    public let runtimeGuardPlanCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let boundaryAuditMarkerCarried: Bool
    public let closeoutLedgerMarkerCarried: Bool
    public let closeoutBoundaryMarkerCarried: Bool
    public let productionQueueMutationRequested: Bool
    public let actualRuntimeTaskSpawnRequested: Bool
    public let actualHandlerInvocationRequested: Bool
    public let actualRequestContextMutationRequested: Bool
    public let actualResponseWriteRequested: Bool
    public let actualTransportCommitRequested: Bool
    public let actualLiveServerWiringRequested: Bool
    public let actualDefaultEngineFlipRequested: Bool
    public let defaultEngineConfigMutationRequested: Bool
    public let runtimeDefaultPathMutationRequested: Bool
    public let publicReleaseRequested: Bool
    public let stdxRemovalRequested: Bool
    public let h1H2QuicRuntimeClosureClaimed: Bool

    public init(
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceiptCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        applyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryCarried: Bool,
        downstreamConsumerBoundaryCarried: Bool,
        rollbackOrderCarried: Bool,
        runtimeGuardPlanCarried: Bool,
        observabilityMarkerCarried: Bool,
        boundaryAuditMarkerCarried: Bool,
        closeoutLedgerMarkerCarried: Bool,
        closeoutBoundaryMarkerCarried: Bool,
        productionQueueMutationRequested: Bool,
        actualRuntimeTaskSpawnRequested: Bool,
        actualHandlerInvocationRequested: Bool,
        actualRequestContextMutationRequested: Bool,
        actualResponseWriteRequested: Bool,
        actualTransportCommitRequested: Bool,
        actualLiveServerWiringRequested: Bool,
        actualDefaultEngineFlipRequested: Bool,
        defaultEngineConfigMutationRequested: Bool,
        runtimeDefaultPathMutationRequested: Bool,
        publicReleaseRequested: Bool,
        stdxRemovalRequested: Bool,
        h1H2QuicRuntimeClosureClaimed: Bool
    ) {
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceiptCarried =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceiptCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.applyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryCarried =
            applyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryCarried
        this.downstreamConsumerBoundaryCarried =
            downstreamConsumerBoundaryCarried
        this.rollbackOrderCarried = rollbackOrderCarried
        this.runtimeGuardPlanCarried = runtimeGuardPlanCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
        this.boundaryAuditMarkerCarried = boundaryAuditMarkerCarried
        this.closeoutLedgerMarkerCarried = closeoutLedgerMarkerCarried
        this.closeoutBoundaryMarkerCarried = closeoutBoundaryMarkerCarried
        this.productionQueueMutationRequested = productionQueueMutationRequested
        this.actualRuntimeTaskSpawnRequested = actualRuntimeTaskSpawnRequested
        this.actualHandlerInvocationRequested = actualHandlerInvocationRequested
        this.actualRequestContextMutationRequested =
            actualRequestContextMutationRequested
        this.actualResponseWriteRequested = actualResponseWriteRequested
        this.actualTransportCommitRequested = actualTransportCommitRequested
        this.actualLiveServerWiringRequested = actualLiveServerWiringRequested
        this.actualDefaultEngineFlipRequested =
            actualDefaultEngineFlipRequested
        this.defaultEngineConfigMutationRequested =
            defaultEngineConfigMutationRequested
        this.runtimeDefaultPathMutationRequested =
            runtimeDefaultPathMutationRequested
        this.publicReleaseRequested = publicReleaseRequested
        this.stdxRemovalRequested = stdxRemovalRequested
        this.h1H2QuicRuntimeClosureClaimed = h1H2QuicRuntimeClosureClaimed
    }
}

public class IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceipt {
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutMode: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryMode: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId: String
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId: String
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String
    public let handoffApplyBoundaryGateCloseoutReceipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceipt
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let actualHandlerInvocationAllowed: Bool
    public let actualRequestContextMutationAllowed: Bool
    public let actualResponseWriteAllowed: Bool
    public let actualTransportCommitAllowed: Bool
    public let actualLiveServerWiringAllowed: Bool
    public let actualDefaultEngineFlipAllowed: Bool
    public let defaultEngineConfigMutationAllowed: Bool
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h1H2QuicRuntimeClosureClaimAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutMode: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryMode: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId: String,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId: String,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String,
        handoffApplyBoundaryGateCloseoutReceipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceipt,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        actualHandlerInvocationAllowed: Bool,
        actualRequestContextMutationAllowed: Bool,
        actualResponseWriteAllowed: Bool,
        actualTransportCommitAllowed: Bool,
        actualLiveServerWiringAllowed: Bool,
        actualDefaultEngineFlipAllowed: Bool,
        defaultEngineConfigMutationAllowed: Bool,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h1H2QuicRuntimeClosureClaimAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAccepted =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAccepted
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAccepted =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAccepted
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutMode =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutMode
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryMode =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryMode
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceGateId
        this.handoffApplyBoundaryGateCloseoutReceipt =
            handoffApplyBoundaryGateCloseoutReceipt
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryRecorded =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAllowed =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.actualRuntimeTaskSpawnAllowed = actualRuntimeTaskSpawnAllowed
        this.actualHandlerInvocationAllowed = actualHandlerInvocationAllowed
        this.actualRequestContextMutationAllowed =
            actualRequestContextMutationAllowed
        this.actualResponseWriteAllowed = actualResponseWriteAllowed
        this.actualTransportCommitAllowed = actualTransportCommitAllowed
        this.actualLiveServerWiringAllowed = actualLiveServerWiringAllowed
        this.actualDefaultEngineFlipAllowed = actualDefaultEngineFlipAllowed
        this.defaultEngineConfigMutationAllowed =
            defaultEngineConfigMutationAllowed
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h1H2QuicRuntimeClosureClaimAllowed =
            h1H2QuicRuntimeClosureClaimAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceipt(
    handoffApplyBoundaryGateCloseoutReceipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceipt,
    request: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryRequest
): IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryNonClaims()
    if (
        !handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceipt(
            false,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAccepted,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutMode,
            "none",
            request.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId,
            handoffApplyBoundaryGateCloseoutReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
            handoffApplyBoundaryGateCloseoutReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            handoffApplyBoundaryGateCloseoutReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-receipt",
            "collect-accepted-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0508 runtime default-path mutation apply-dry-run acceptance handoff apply-boundary gate closeout input before closeout boundary work",
            "QUIC must not consume handoff apply-boundary gate closeout boundary receipts from rejected runtime default-path mutation handoff apply-boundary gate closeout receipts"
        )
    }

    let handoffApplyBoundaryGateCloseoutBoundaryMode =
        igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryModeFor(
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryBlockers(
            request,
            handoffApplyBoundaryGateCloseoutBoundaryMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceipt(
            false,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAccepted,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutMode,
            handoffApplyBoundaryGateCloseoutBoundaryMode,
            request.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId,
            handoffApplyBoundaryGateCloseoutReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
            handoffApplyBoundaryGateCloseoutReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            handoffApplyBoundaryGateCloseoutReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-input",
            "fix-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-before-runtime-default-mutation",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry handoff apply-boundary gate closeout boundary id, accepted closeout receipt, runtime default-path mutation lock, closeout boundary marker, downstream consumer boundary, rollback order, runtime guard plan, observability marker, boundary audit marker, closeout ledger marker, closeout boundary marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation handoff apply-boundary gate closeout boundary blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceipt(
        true,
        handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAccepted,
        handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutMode,
        handoffApplyBoundaryGateCloseoutBoundaryMode,
        request.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryId,
        handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutId,
        handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId,
        handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId,
        handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId,
        handoffApplyBoundaryGateCloseoutReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
        handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
        handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
        handoffApplyBoundaryGateCloseoutReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
        handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
        handoffApplyBoundaryGateCloseoutReceipt,
        true,
        "record-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary",
        "accepted-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-receipt",
        "record-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-without-runtime-default-mutation",
        [],
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
        nonClaims,
        "next packet may prove stdx claim separation or runtime default mutation preparation without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation apply-dry-run acceptance handoff apply-boundary gate closeout boundary modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryModeFor(
    handoffApplyBoundaryGateCloseoutMode: String
): String {
    if (
        handoffApplyBoundaryGateCloseoutMode ==
        "short-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout"
    ) {
        return "short-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary"
    }
    if (
        handoffApplyBoundaryGateCloseoutMode ==
        "long-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout"
    ) {
        return "long-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary"
    }
    if (
        handoffApplyBoundaryGateCloseoutMode ==
        "blocking-isolation-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary"
    }
    "unknown-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary"
}

func igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryBlockers(
    request: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryRequest,
    handoffApplyBoundaryGateCloseoutBoundaryMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_ID_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_RECEIPT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.applyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryCarried) {
        blockers.add("APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_NOT_CARRIED")
    }
    if (!request.downstreamConsumerBoundaryCarried) {
        blockers.add("DOWNSTREAM_CONSUMER_BOUNDARY_NOT_CARRIED")
    }
    if (!request.rollbackOrderCarried) {
        blockers.add("ROLLBACK_ORDER_NOT_CARRIED")
    }
    if (!request.runtimeGuardPlanCarried) {
        blockers.add("RUNTIME_GUARD_PLAN_NOT_CARRIED")
    }
    if (!request.observabilityMarkerCarried) {
        blockers.add("OBSERVABILITY_MARKER_NOT_CARRIED")
    }
    if (!request.boundaryAuditMarkerCarried) {
        blockers.add("BOUNDARY_AUDIT_MARKER_NOT_CARRIED")
    }
    if (!request.closeoutLedgerMarkerCarried) {
        blockers.add("CLOSEOUT_LEDGER_MARKER_NOT_CARRIED")
    }
    if (!request.closeoutBoundaryMarkerCarried) {
        blockers.add("CLOSEOUT_BOUNDARY_MARKER_NOT_CARRIED")
    }
    if (request.productionQueueMutationRequested) {
        blockers.add("PRODUCTION_QUEUE_MUTATION_REQUESTED")
    }
    if (request.actualRuntimeTaskSpawnRequested) {
        blockers.add("ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.actualHandlerInvocationRequested) {
        blockers.add("ACTUAL_HANDLER_INVOCATION_REQUESTED")
    }
    if (request.actualRequestContextMutationRequested) {
        blockers.add("ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.actualResponseWriteRequested) {
        blockers.add("ACTUAL_RESPONSE_WRITE_REQUESTED")
    }
    if (request.actualTransportCommitRequested) {
        blockers.add("ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.actualLiveServerWiringRequested) {
        blockers.add("ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    }
    if (request.actualDefaultEngineFlipRequested) {
        blockers.add("ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    }
    if (request.defaultEngineConfigMutationRequested) {
        blockers.add("DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    }
    if (request.runtimeDefaultPathMutationRequested) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    }
    if (request.publicReleaseRequested) {
        blockers.add("PUBLIC_RELEASE_REQUESTED")
    }
    if (request.stdxRemovalRequested) {
        blockers.add("STDX_REMOVAL_REQUESTED")
    }
    if (request.h1H2QuicRuntimeClosureClaimed) {
        blockers.add("H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    }
    if (
        handoffApplyBoundaryGateCloseoutBoundaryMode ==
        "unknown-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutNonClaims()
}

public class IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateRequest {
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceiptCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let applyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateCarried: Bool
    public let downstreamConsumerBoundaryCarried: Bool
    public let rollbackOrderCarried: Bool
    public let runtimeGuardPlanCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let boundaryAuditMarkerCarried: Bool
    public let closeoutLedgerMarkerCarried: Bool
    public let closeoutBoundaryMarkerCarried: Bool
    public let closeoutBoundaryGateMarkerCarried: Bool
    public let productionQueueMutationRequested: Bool
    public let actualRuntimeTaskSpawnRequested: Bool
    public let actualHandlerInvocationRequested: Bool
    public let actualRequestContextMutationRequested: Bool
    public let actualResponseWriteRequested: Bool
    public let actualTransportCommitRequested: Bool
    public let actualLiveServerWiringRequested: Bool
    public let actualDefaultEngineFlipRequested: Bool
    public let defaultEngineConfigMutationRequested: Bool
    public let runtimeDefaultPathMutationRequested: Bool
    public let publicReleaseRequested: Bool
    public let stdxRemovalRequested: Bool
    public let h1H2QuicRuntimeClosureClaimed: Bool

    public init(
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceiptCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        applyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateCarried: Bool,
        downstreamConsumerBoundaryCarried: Bool,
        rollbackOrderCarried: Bool,
        runtimeGuardPlanCarried: Bool,
        observabilityMarkerCarried: Bool,
        boundaryAuditMarkerCarried: Bool,
        closeoutLedgerMarkerCarried: Bool,
        closeoutBoundaryMarkerCarried: Bool,
        closeoutBoundaryGateMarkerCarried: Bool,
        productionQueueMutationRequested: Bool,
        actualRuntimeTaskSpawnRequested: Bool,
        actualHandlerInvocationRequested: Bool,
        actualRequestContextMutationRequested: Bool,
        actualResponseWriteRequested: Bool,
        actualTransportCommitRequested: Bool,
        actualLiveServerWiringRequested: Bool,
        actualDefaultEngineFlipRequested: Bool,
        defaultEngineConfigMutationRequested: Bool,
        runtimeDefaultPathMutationRequested: Bool,
        publicReleaseRequested: Bool,
        stdxRemovalRequested: Bool,
        h1H2QuicRuntimeClosureClaimed: Bool
    ) {
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceiptCarried =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceiptCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.applyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateCarried =
            applyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateCarried
        this.downstreamConsumerBoundaryCarried =
            downstreamConsumerBoundaryCarried
        this.rollbackOrderCarried = rollbackOrderCarried
        this.runtimeGuardPlanCarried = runtimeGuardPlanCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
        this.boundaryAuditMarkerCarried = boundaryAuditMarkerCarried
        this.closeoutLedgerMarkerCarried = closeoutLedgerMarkerCarried
        this.closeoutBoundaryMarkerCarried = closeoutBoundaryMarkerCarried
        this.closeoutBoundaryGateMarkerCarried =
            closeoutBoundaryGateMarkerCarried
        this.productionQueueMutationRequested = productionQueueMutationRequested
        this.actualRuntimeTaskSpawnRequested = actualRuntimeTaskSpawnRequested
        this.actualHandlerInvocationRequested = actualHandlerInvocationRequested
        this.actualRequestContextMutationRequested =
            actualRequestContextMutationRequested
        this.actualResponseWriteRequested = actualResponseWriteRequested
        this.actualTransportCommitRequested = actualTransportCommitRequested
        this.actualLiveServerWiringRequested = actualLiveServerWiringRequested
        this.actualDefaultEngineFlipRequested =
            actualDefaultEngineFlipRequested
        this.defaultEngineConfigMutationRequested =
            defaultEngineConfigMutationRequested
        this.runtimeDefaultPathMutationRequested =
            runtimeDefaultPathMutationRequested
        this.publicReleaseRequested = publicReleaseRequested
        this.stdxRemovalRequested = stdxRemovalRequested
        this.h1H2QuicRuntimeClosureClaimed = h1H2QuicRuntimeClosureClaimed
    }
}

public class IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateReceipt {
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryMode: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateMode: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId: String
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId: String
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String
    public let handoffApplyBoundaryGateCloseoutBoundaryReceipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceipt
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let actualHandlerInvocationAllowed: Bool
    public let actualRequestContextMutationAllowed: Bool
    public let actualResponseWriteAllowed: Bool
    public let actualTransportCommitAllowed: Bool
    public let actualLiveServerWiringAllowed: Bool
    public let actualDefaultEngineFlipAllowed: Bool
    public let defaultEngineConfigMutationAllowed: Bool
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h1H2QuicRuntimeClosureClaimAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryMode: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateMode: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId: String,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId: String,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String,
        handoffApplyBoundaryGateCloseoutBoundaryReceipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceipt,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        actualHandlerInvocationAllowed: Bool,
        actualRequestContextMutationAllowed: Bool,
        actualResponseWriteAllowed: Bool,
        actualTransportCommitAllowed: Bool,
        actualLiveServerWiringAllowed: Bool,
        actualDefaultEngineFlipAllowed: Bool,
        defaultEngineConfigMutationAllowed: Bool,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h1H2QuicRuntimeClosureClaimAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateAccepted =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateAccepted
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAccepted =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAccepted
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryMode =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryMode
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateMode =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateMode
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId =
            runtimeDefaultPathMutationApplyDryRunAcceptanceGateId
        this.handoffApplyBoundaryGateCloseoutBoundaryReceipt =
            handoffApplyBoundaryGateCloseoutBoundaryReceipt
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateRecorded =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateAllowed =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.actualRuntimeTaskSpawnAllowed = actualRuntimeTaskSpawnAllowed
        this.actualHandlerInvocationAllowed = actualHandlerInvocationAllowed
        this.actualRequestContextMutationAllowed =
            actualRequestContextMutationAllowed
        this.actualResponseWriteAllowed = actualResponseWriteAllowed
        this.actualTransportCommitAllowed = actualTransportCommitAllowed
        this.actualLiveServerWiringAllowed = actualLiveServerWiringAllowed
        this.actualDefaultEngineFlipAllowed = actualDefaultEngineFlipAllowed
        this.defaultEngineConfigMutationAllowed =
            defaultEngineConfigMutationAllowed
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h1H2QuicRuntimeClosureClaimAllowed =
            h1H2QuicRuntimeClosureClaimAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateReceipt(
    handoffApplyBoundaryGateCloseoutBoundaryReceipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceipt,
    request: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateRequest
): IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateNonClaims()
    if (
        !handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateReceipt(
            false,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAccepted,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryMode,
            "none",
            request.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-receipt",
            "collect-accepted-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0509 runtime default-path mutation apply-dry-run acceptance handoff apply-boundary gate closeout boundary input before closeout boundary gate work",
            "QUIC must not consume handoff apply-boundary gate closeout boundary gate receipts from rejected runtime default-path mutation handoff apply-boundary gate closeout boundary receipts"
        )
    }

    let handoffApplyBoundaryGateCloseoutBoundaryGateMode =
        igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateModeFor(
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateBlockers(
            request,
            handoffApplyBoundaryGateCloseoutBoundaryGateMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateReceipt(
            false,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAccepted,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryMode,
            handoffApplyBoundaryGateCloseoutBoundaryGateMode,
            request.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-gate-input",
            "fix-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-gate-before-runtime-default-mutation",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry handoff apply-boundary gate closeout boundary gate id, accepted closeout boundary receipt, runtime default-path mutation lock, closeout boundary gate marker, downstream consumer boundary, rollback order, runtime guard plan, observability marker, boundary audit marker, closeout ledger marker, closeout boundary marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation handoff apply-boundary gate closeout boundary gate blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateReceipt(
        true,
        handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAccepted,
        handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryMode,
        handoffApplyBoundaryGateCloseoutBoundaryGateMode,
        request.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateId,
        handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryId,
        handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutId,
        handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId,
        handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId,
        handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId,
        handoffApplyBoundaryGateCloseoutBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
        handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
        handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
        handoffApplyBoundaryGateCloseoutBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
        handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
        handoffApplyBoundaryGateCloseoutBoundaryReceipt,
        true,
        "record-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-gate",
        "accepted-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-gate-receipt",
        "record-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-gate-without-runtime-default-mutation",
        [],
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
        nonClaims,
        "next packet may prove stdx claim separation or runtime default mutation preparation without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation apply-dry-run acceptance handoff apply-boundary gate closeout boundary gate modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateModeFor(
    handoffApplyBoundaryGateCloseoutBoundaryMode: String
): String {
    if (
        handoffApplyBoundaryGateCloseoutBoundaryMode ==
        "short-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary"
    ) {
        return "short-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-gate"
    }
    if (
        handoffApplyBoundaryGateCloseoutBoundaryMode ==
        "long-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary"
    ) {
        return "long-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-gate"
    }
    if (
        handoffApplyBoundaryGateCloseoutBoundaryMode ==
        "blocking-isolation-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-gate"
    }
    "unknown-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-gate"
}

func igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateBlockers(
    request: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateRequest,
    handoffApplyBoundaryGateCloseoutBoundaryGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_ID_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_RECEIPT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.applyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateCarried) {
        blockers.add("APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_NOT_CARRIED")
    }
    if (!request.downstreamConsumerBoundaryCarried) {
        blockers.add("DOWNSTREAM_CONSUMER_BOUNDARY_NOT_CARRIED")
    }
    if (!request.rollbackOrderCarried) {
        blockers.add("ROLLBACK_ORDER_NOT_CARRIED")
    }
    if (!request.runtimeGuardPlanCarried) {
        blockers.add("RUNTIME_GUARD_PLAN_NOT_CARRIED")
    }
    if (!request.observabilityMarkerCarried) {
        blockers.add("OBSERVABILITY_MARKER_NOT_CARRIED")
    }
    if (!request.boundaryAuditMarkerCarried) {
        blockers.add("BOUNDARY_AUDIT_MARKER_NOT_CARRIED")
    }
    if (!request.closeoutLedgerMarkerCarried) {
        blockers.add("CLOSEOUT_LEDGER_MARKER_NOT_CARRIED")
    }
    if (!request.closeoutBoundaryMarkerCarried) {
        blockers.add("CLOSEOUT_BOUNDARY_MARKER_NOT_CARRIED")
    }
    if (!request.closeoutBoundaryGateMarkerCarried) {
        blockers.add("CLOSEOUT_BOUNDARY_GATE_MARKER_NOT_CARRIED")
    }
    if (request.productionQueueMutationRequested) {
        blockers.add("PRODUCTION_QUEUE_MUTATION_REQUESTED")
    }
    if (request.actualRuntimeTaskSpawnRequested) {
        blockers.add("ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.actualHandlerInvocationRequested) {
        blockers.add("ACTUAL_HANDLER_INVOCATION_REQUESTED")
    }
    if (request.actualRequestContextMutationRequested) {
        blockers.add("ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.actualResponseWriteRequested) {
        blockers.add("ACTUAL_RESPONSE_WRITE_REQUESTED")
    }
    if (request.actualTransportCommitRequested) {
        blockers.add("ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.actualLiveServerWiringRequested) {
        blockers.add("ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    }
    if (request.actualDefaultEngineFlipRequested) {
        blockers.add("ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    }
    if (request.defaultEngineConfigMutationRequested) {
        blockers.add("DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    }
    if (request.runtimeDefaultPathMutationRequested) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    }
    if (request.publicReleaseRequested) {
        blockers.add("PUBLIC_RELEASE_REQUESTED")
    }
    if (request.stdxRemovalRequested) {
        blockers.add("STDX_REMOVAL_REQUESTED")
    }
    if (request.h1H2QuicRuntimeClosureClaimed) {
        blockers.add("H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    }
    if (
        handoffApplyBoundaryGateCloseoutBoundaryGateMode ==
        "unknown-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-gate"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationGateRequest {
    public let runtimeDefaultPathMutationPreparationGateId: String
    public let closeoutBoundaryGateReceiptCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let defaultPathCandidateCarried: Bool
    public let runtimeMutationPreparationPlanCarried: Bool
    public let rollbackOrderCarried: Bool
    public let runtimeGuardPlanCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let boundaryAuditMarkerCarried: Bool
    public let sourceZeroStdxClaimSeparated: Bool
    public let publicClaimBoundaryCarried: Bool
    public let quicReuseBoundaryCarried: Bool
    public let productionQueueMutationRequested: Bool
    public let actualRuntimeTaskSpawnRequested: Bool
    public let actualHandlerInvocationRequested: Bool
    public let actualRequestContextMutationRequested: Bool
    public let actualResponseWriteRequested: Bool
    public let actualTransportCommitRequested: Bool
    public let actualLiveServerWiringRequested: Bool
    public let actualDefaultEngineFlipRequested: Bool
    public let defaultEngineConfigMutationRequested: Bool
    public let runtimeDefaultPathMutationRequested: Bool
    public let publicReleaseRequested: Bool
    public let stdxRemovalRequested: Bool
    public let h1H2QuicRuntimeClosureClaimed: Bool

    public init(
        runtimeDefaultPathMutationPreparationGateId: String,
        closeoutBoundaryGateReceiptCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        defaultPathCandidateCarried: Bool,
        runtimeMutationPreparationPlanCarried: Bool,
        rollbackOrderCarried: Bool,
        runtimeGuardPlanCarried: Bool,
        observabilityMarkerCarried: Bool,
        boundaryAuditMarkerCarried: Bool,
        sourceZeroStdxClaimSeparated: Bool,
        publicClaimBoundaryCarried: Bool,
        quicReuseBoundaryCarried: Bool,
        productionQueueMutationRequested: Bool,
        actualRuntimeTaskSpawnRequested: Bool,
        actualHandlerInvocationRequested: Bool,
        actualRequestContextMutationRequested: Bool,
        actualResponseWriteRequested: Bool,
        actualTransportCommitRequested: Bool,
        actualLiveServerWiringRequested: Bool,
        actualDefaultEngineFlipRequested: Bool,
        defaultEngineConfigMutationRequested: Bool,
        runtimeDefaultPathMutationRequested: Bool,
        publicReleaseRequested: Bool,
        stdxRemovalRequested: Bool,
        h1H2QuicRuntimeClosureClaimed: Bool
    ) {
        this.runtimeDefaultPathMutationPreparationGateId =
            runtimeDefaultPathMutationPreparationGateId
        this.closeoutBoundaryGateReceiptCarried =
            closeoutBoundaryGateReceiptCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.defaultPathCandidateCarried = defaultPathCandidateCarried
        this.runtimeMutationPreparationPlanCarried =
            runtimeMutationPreparationPlanCarried
        this.rollbackOrderCarried = rollbackOrderCarried
        this.runtimeGuardPlanCarried = runtimeGuardPlanCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
        this.boundaryAuditMarkerCarried = boundaryAuditMarkerCarried
        this.sourceZeroStdxClaimSeparated = sourceZeroStdxClaimSeparated
        this.publicClaimBoundaryCarried = publicClaimBoundaryCarried
        this.quicReuseBoundaryCarried = quicReuseBoundaryCarried
        this.productionQueueMutationRequested = productionQueueMutationRequested
        this.actualRuntimeTaskSpawnRequested = actualRuntimeTaskSpawnRequested
        this.actualHandlerInvocationRequested = actualHandlerInvocationRequested
        this.actualRequestContextMutationRequested =
            actualRequestContextMutationRequested
        this.actualResponseWriteRequested = actualResponseWriteRequested
        this.actualTransportCommitRequested = actualTransportCommitRequested
        this.actualLiveServerWiringRequested = actualLiveServerWiringRequested
        this.actualDefaultEngineFlipRequested =
            actualDefaultEngineFlipRequested
        this.defaultEngineConfigMutationRequested =
            defaultEngineConfigMutationRequested
        this.runtimeDefaultPathMutationRequested =
            runtimeDefaultPathMutationRequested
        this.publicReleaseRequested = publicReleaseRequested
        this.stdxRemovalRequested = stdxRemovalRequested
        this.h1H2QuicRuntimeClosureClaimed = h1H2QuicRuntimeClosureClaimed
    }
}

public class IgniteRuntimeDefaultPathMutationPreparationGateReceipt {
    public let runtimeDefaultPathMutationPreparationGateAccepted: Bool
    public let closeoutBoundaryGateAccepted: Bool
    public let closeoutBoundaryGateMode: String
    public let runtimeDefaultPathMutationPreparationGateMode: String
    public let runtimeDefaultPathMutationPreparationGateId: String
    public let closeoutBoundaryGateId: String
    public let closeoutBoundaryId: String
    public let closeoutId: String
    public let closeoutBoundaryGateReceipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateReceipt
    public let runtimeDefaultPathMutationPreparationGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationGateAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let actualHandlerInvocationAllowed: Bool
    public let actualRequestContextMutationAllowed: Bool
    public let actualResponseWriteAllowed: Bool
    public let actualTransportCommitAllowed: Bool
    public let actualLiveServerWiringAllowed: Bool
    public let actualDefaultEngineFlipAllowed: Bool
    public let defaultEngineConfigMutationAllowed: Bool
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h1H2QuicRuntimeClosureClaimAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        runtimeDefaultPathMutationPreparationGateAccepted: Bool,
        closeoutBoundaryGateAccepted: Bool,
        closeoutBoundaryGateMode: String,
        runtimeDefaultPathMutationPreparationGateMode: String,
        runtimeDefaultPathMutationPreparationGateId: String,
        closeoutBoundaryGateId: String,
        closeoutBoundaryId: String,
        closeoutId: String,
        closeoutBoundaryGateReceipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateReceipt,
        runtimeDefaultPathMutationPreparationGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationGateAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        actualHandlerInvocationAllowed: Bool,
        actualRequestContextMutationAllowed: Bool,
        actualResponseWriteAllowed: Bool,
        actualTransportCommitAllowed: Bool,
        actualLiveServerWiringAllowed: Bool,
        actualDefaultEngineFlipAllowed: Bool,
        defaultEngineConfigMutationAllowed: Bool,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h1H2QuicRuntimeClosureClaimAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.runtimeDefaultPathMutationPreparationGateAccepted =
            runtimeDefaultPathMutationPreparationGateAccepted
        this.closeoutBoundaryGateAccepted = closeoutBoundaryGateAccepted
        this.closeoutBoundaryGateMode = closeoutBoundaryGateMode
        this.runtimeDefaultPathMutationPreparationGateMode =
            runtimeDefaultPathMutationPreparationGateMode
        this.runtimeDefaultPathMutationPreparationGateId =
            runtimeDefaultPathMutationPreparationGateId
        this.closeoutBoundaryGateId = closeoutBoundaryGateId
        this.closeoutBoundaryId = closeoutBoundaryId
        this.closeoutId = closeoutId
        this.closeoutBoundaryGateReceipt = closeoutBoundaryGateReceipt
        this.runtimeDefaultPathMutationPreparationGateRecorded =
            runtimeDefaultPathMutationPreparationGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationGateAllowed =
            runtimeDefaultPathMutationPreparationGateAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.actualRuntimeTaskSpawnAllowed = actualRuntimeTaskSpawnAllowed
        this.actualHandlerInvocationAllowed = actualHandlerInvocationAllowed
        this.actualRequestContextMutationAllowed =
            actualRequestContextMutationAllowed
        this.actualResponseWriteAllowed = actualResponseWriteAllowed
        this.actualTransportCommitAllowed = actualTransportCommitAllowed
        this.actualLiveServerWiringAllowed = actualLiveServerWiringAllowed
        this.actualDefaultEngineFlipAllowed = actualDefaultEngineFlipAllowed
        this.defaultEngineConfigMutationAllowed =
            defaultEngineConfigMutationAllowed
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h1H2QuicRuntimeClosureClaimAllowed =
            h1H2QuicRuntimeClosureClaimAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteRuntimeDefaultPathMutationPreparationGateReceipt(
    closeoutBoundaryGateReceipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationGateRequest
): IgniteRuntimeDefaultPathMutationPreparationGateReceipt {
    let nonClaims = igniteRuntimeDefaultPathMutationPreparationGateNonClaims()
    if (!closeoutBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateAccepted) {
        return IgniteRuntimeDefaultPathMutationPreparationGateReceipt(
            false,
            closeoutBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateAccepted,
            closeoutBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateMode,
            "none",
            request.runtimeDefaultPathMutationPreparationGateId,
            closeoutBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateId,
            closeoutBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryId,
            closeoutBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutId,
            closeoutBoundaryGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-gate-upstream-receipt",
            "collect-accepted-runtime-default-path-mutation-closeout-boundary-gate-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_CLOSEOUT_BOUNDARY_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0510 runtime default-path mutation closeout boundary gate input before preparation work",
            "QUIC must not consume preparation gate receipts from rejected runtime default-path mutation closeout boundary gate receipts"
        )
    }

    let preparationGateMode = igniteRuntimeDefaultPathMutationPreparationGateModeFor(
        closeoutBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateMode
    )
    let blockers = igniteRuntimeDefaultPathMutationPreparationGateBlockers(
        request,
        preparationGateMode
    )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationGateReceipt(
            false,
            closeoutBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateAccepted,
            closeoutBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateMode,
            preparationGateMode,
            request.runtimeDefaultPathMutationPreparationGateId,
            closeoutBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateId,
            closeoutBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryId,
            closeoutBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutId,
            closeoutBoundaryGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-gate-input",
            "fix-runtime-default-path-mutation-preparation-gate-before-runtime-default-mutation",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry preparation gate id, accepted closeout boundary gate receipt, runtime default-path mutation lock, default path candidate, preparation plan, source-zero stdx separation, public claim boundary, QUIC reuse boundary, rollback order, runtime guard plan, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation preparation blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationPreparationGateReceipt(
        true,
        closeoutBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateAccepted,
        closeoutBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateMode,
        preparationGateMode,
        request.runtimeDefaultPathMutationPreparationGateId,
        closeoutBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateId,
        closeoutBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryId,
        closeoutBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutId,
        closeoutBoundaryGateReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-gate",
        "accepted-runtime-default-path-mutation-preparation-gate-receipt",
        "record-runtime-default-path-mutation-preparation-gate-without-runtime-default-mutation",
        [],
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
        nonClaims,
        "next packet may prove runtime default-path mutation preparation boundary or dry-run handoff without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation gate modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationGateModeFor(
    closeoutBoundaryGateMode: String
): String {
    if (
        closeoutBoundaryGateMode ==
        "short-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-gate"
    ) {
        return "short-runtime-default-path-mutation-preparation-gate"
    }
    if (
        closeoutBoundaryGateMode ==
        "long-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-gate"
    ) {
        return "long-runtime-default-path-mutation-preparation-gate"
    }
    if (
        closeoutBoundaryGateMode ==
        "blocking-isolation-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-gate"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-gate"
    }
    "unknown-runtime-default-path-mutation-preparation-gate"
}

func igniteRuntimeDefaultPathMutationPreparationGateBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationGateRequest,
    preparationGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.runtimeDefaultPathMutationPreparationGateId.size == 0) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_GATE_ID_NOT_CARRIED")
    }
    if (!request.closeoutBoundaryGateReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_CLOSEOUT_BOUNDARY_GATE_RECEIPT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.defaultPathCandidateCarried) {
        blockers.add("DEFAULT_PATH_CANDIDATE_NOT_CARRIED")
    }
    if (!request.runtimeMutationPreparationPlanCarried) {
        blockers.add("RUNTIME_MUTATION_PREPARATION_PLAN_NOT_CARRIED")
    }
    if (!request.rollbackOrderCarried) {
        blockers.add("ROLLBACK_ORDER_NOT_CARRIED")
    }
    if (!request.runtimeGuardPlanCarried) {
        blockers.add("RUNTIME_GUARD_PLAN_NOT_CARRIED")
    }
    if (!request.observabilityMarkerCarried) {
        blockers.add("OBSERVABILITY_MARKER_NOT_CARRIED")
    }
    if (!request.boundaryAuditMarkerCarried) {
        blockers.add("BOUNDARY_AUDIT_MARKER_NOT_CARRIED")
    }
    if (!request.sourceZeroStdxClaimSeparated) {
        blockers.add("SOURCE_ZERO_STDX_CLAIM_NOT_SEPARATED")
    }
    if (!request.publicClaimBoundaryCarried) {
        blockers.add("PUBLIC_CLAIM_BOUNDARY_NOT_CARRIED")
    }
    if (!request.quicReuseBoundaryCarried) {
        blockers.add("QUIC_REUSE_BOUNDARY_NOT_CARRIED")
    }
    if (request.productionQueueMutationRequested) {
        blockers.add("PRODUCTION_QUEUE_MUTATION_REQUESTED")
    }
    if (request.actualRuntimeTaskSpawnRequested) {
        blockers.add("ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.actualHandlerInvocationRequested) {
        blockers.add("ACTUAL_HANDLER_INVOCATION_REQUESTED")
    }
    if (request.actualRequestContextMutationRequested) {
        blockers.add("ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.actualResponseWriteRequested) {
        blockers.add("ACTUAL_RESPONSE_WRITE_REQUESTED")
    }
    if (request.actualTransportCommitRequested) {
        blockers.add("ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.actualLiveServerWiringRequested) {
        blockers.add("ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    }
    if (request.actualDefaultEngineFlipRequested) {
        blockers.add("ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    }
    if (request.defaultEngineConfigMutationRequested) {
        blockers.add("DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    }
    if (request.runtimeDefaultPathMutationRequested) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    }
    if (request.publicReleaseRequested) {
        blockers.add("PUBLIC_RELEASE_REQUESTED")
    }
    if (request.stdxRemovalRequested) {
        blockers.add("STDX_REMOVAL_REQUESTED")
    }
    if (request.h1H2QuicRuntimeClosureClaimed) {
        blockers.add("H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    }
    if (preparationGateMode == "unknown-runtime-default-path-mutation-preparation-gate") {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_CLOSEOUT_BOUNDARY_GATE_MODE")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationGateNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryGateNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationBoundaryRequest {
    public let runtimeDefaultPathMutationPreparationBoundaryId: String
    public let preparationGateReceiptCarried: Bool
    public let preparationBoundaryMarkerCarried: Bool
    public let mutationReadinessReviewMarkerCarried: Bool
    public let rollbackVerificationMarkerCarried: Bool
    public let defaultPathCandidateFreezeCarried: Bool
    public let runtimeGuardReviewCarried: Bool
    public let observabilityReviewCarried: Bool
    public let sourceZeroStdxClaimSeparated: Bool
    public let publicClaimBoundaryCarried: Bool
    public let quicReuseBoundaryCarried: Bool
    public let productionQueueMutationRequested: Bool
    public let actualRuntimeTaskSpawnRequested: Bool
    public let actualHandlerInvocationRequested: Bool
    public let actualRequestContextMutationRequested: Bool
    public let actualResponseWriteRequested: Bool
    public let actualTransportCommitRequested: Bool
    public let actualLiveServerWiringRequested: Bool
    public let actualDefaultEngineFlipRequested: Bool
    public let defaultEngineConfigMutationRequested: Bool
    public let runtimeDefaultPathMutationRequested: Bool
    public let publicReleaseRequested: Bool
    public let stdxRemovalRequested: Bool
    public let h1H2QuicRuntimeClosureClaimed: Bool

    public init(
        runtimeDefaultPathMutationPreparationBoundaryId: String,
        preparationGateReceiptCarried: Bool,
        preparationBoundaryMarkerCarried: Bool,
        mutationReadinessReviewMarkerCarried: Bool,
        rollbackVerificationMarkerCarried: Bool,
        defaultPathCandidateFreezeCarried: Bool,
        runtimeGuardReviewCarried: Bool,
        observabilityReviewCarried: Bool,
        sourceZeroStdxClaimSeparated: Bool,
        publicClaimBoundaryCarried: Bool,
        quicReuseBoundaryCarried: Bool,
        productionQueueMutationRequested: Bool,
        actualRuntimeTaskSpawnRequested: Bool,
        actualHandlerInvocationRequested: Bool,
        actualRequestContextMutationRequested: Bool,
        actualResponseWriteRequested: Bool,
        actualTransportCommitRequested: Bool,
        actualLiveServerWiringRequested: Bool,
        actualDefaultEngineFlipRequested: Bool,
        defaultEngineConfigMutationRequested: Bool,
        runtimeDefaultPathMutationRequested: Bool,
        publicReleaseRequested: Bool,
        stdxRemovalRequested: Bool,
        h1H2QuicRuntimeClosureClaimed: Bool
    ) {
        this.runtimeDefaultPathMutationPreparationBoundaryId =
            runtimeDefaultPathMutationPreparationBoundaryId
        this.preparationGateReceiptCarried = preparationGateReceiptCarried
        this.preparationBoundaryMarkerCarried = preparationBoundaryMarkerCarried
        this.mutationReadinessReviewMarkerCarried =
            mutationReadinessReviewMarkerCarried
        this.rollbackVerificationMarkerCarried =
            rollbackVerificationMarkerCarried
        this.defaultPathCandidateFreezeCarried =
            defaultPathCandidateFreezeCarried
        this.runtimeGuardReviewCarried = runtimeGuardReviewCarried
        this.observabilityReviewCarried = observabilityReviewCarried
        this.sourceZeroStdxClaimSeparated = sourceZeroStdxClaimSeparated
        this.publicClaimBoundaryCarried = publicClaimBoundaryCarried
        this.quicReuseBoundaryCarried = quicReuseBoundaryCarried
        this.productionQueueMutationRequested = productionQueueMutationRequested
        this.actualRuntimeTaskSpawnRequested = actualRuntimeTaskSpawnRequested
        this.actualHandlerInvocationRequested = actualHandlerInvocationRequested
        this.actualRequestContextMutationRequested =
            actualRequestContextMutationRequested
        this.actualResponseWriteRequested = actualResponseWriteRequested
        this.actualTransportCommitRequested = actualTransportCommitRequested
        this.actualLiveServerWiringRequested = actualLiveServerWiringRequested
        this.actualDefaultEngineFlipRequested =
            actualDefaultEngineFlipRequested
        this.defaultEngineConfigMutationRequested =
            defaultEngineConfigMutationRequested
        this.runtimeDefaultPathMutationRequested =
            runtimeDefaultPathMutationRequested
        this.publicReleaseRequested = publicReleaseRequested
        this.stdxRemovalRequested = stdxRemovalRequested
        this.h1H2QuicRuntimeClosureClaimed = h1H2QuicRuntimeClosureClaimed
    }
}

public class IgniteRuntimeDefaultPathMutationPreparationBoundaryReceipt {
    public let runtimeDefaultPathMutationPreparationBoundaryAccepted: Bool
    public let preparationGateAccepted: Bool
    public let preparationGateMode: String
    public let runtimeDefaultPathMutationPreparationBoundaryMode: String
    public let runtimeDefaultPathMutationPreparationBoundaryId: String
    public let preparationGateId: String
    public let closeoutBoundaryGateId: String
    public let closeoutBoundaryId: String
    public let closeoutId: String
    public let preparationGateReceipt: IgniteRuntimeDefaultPathMutationPreparationGateReceipt
    public let runtimeDefaultPathMutationPreparationBoundaryRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationBoundaryAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let actualHandlerInvocationAllowed: Bool
    public let actualRequestContextMutationAllowed: Bool
    public let actualResponseWriteAllowed: Bool
    public let actualTransportCommitAllowed: Bool
    public let actualLiveServerWiringAllowed: Bool
    public let actualDefaultEngineFlipAllowed: Bool
    public let defaultEngineConfigMutationAllowed: Bool
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h1H2QuicRuntimeClosureClaimAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        runtimeDefaultPathMutationPreparationBoundaryAccepted: Bool,
        preparationGateAccepted: Bool,
        preparationGateMode: String,
        runtimeDefaultPathMutationPreparationBoundaryMode: String,
        runtimeDefaultPathMutationPreparationBoundaryId: String,
        preparationGateId: String,
        closeoutBoundaryGateId: String,
        closeoutBoundaryId: String,
        closeoutId: String,
        preparationGateReceipt: IgniteRuntimeDefaultPathMutationPreparationGateReceipt,
        runtimeDefaultPathMutationPreparationBoundaryRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationBoundaryAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        actualHandlerInvocationAllowed: Bool,
        actualRequestContextMutationAllowed: Bool,
        actualResponseWriteAllowed: Bool,
        actualTransportCommitAllowed: Bool,
        actualLiveServerWiringAllowed: Bool,
        actualDefaultEngineFlipAllowed: Bool,
        defaultEngineConfigMutationAllowed: Bool,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h1H2QuicRuntimeClosureClaimAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.runtimeDefaultPathMutationPreparationBoundaryAccepted =
            runtimeDefaultPathMutationPreparationBoundaryAccepted
        this.preparationGateAccepted = preparationGateAccepted
        this.preparationGateMode = preparationGateMode
        this.runtimeDefaultPathMutationPreparationBoundaryMode =
            runtimeDefaultPathMutationPreparationBoundaryMode
        this.runtimeDefaultPathMutationPreparationBoundaryId =
            runtimeDefaultPathMutationPreparationBoundaryId
        this.preparationGateId = preparationGateId
        this.closeoutBoundaryGateId = closeoutBoundaryGateId
        this.closeoutBoundaryId = closeoutBoundaryId
        this.closeoutId = closeoutId
        this.preparationGateReceipt = preparationGateReceipt
        this.runtimeDefaultPathMutationPreparationBoundaryRecorded =
            runtimeDefaultPathMutationPreparationBoundaryRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationBoundaryAllowed =
            runtimeDefaultPathMutationPreparationBoundaryAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.actualRuntimeTaskSpawnAllowed = actualRuntimeTaskSpawnAllowed
        this.actualHandlerInvocationAllowed = actualHandlerInvocationAllowed
        this.actualRequestContextMutationAllowed =
            actualRequestContextMutationAllowed
        this.actualResponseWriteAllowed = actualResponseWriteAllowed
        this.actualTransportCommitAllowed = actualTransportCommitAllowed
        this.actualLiveServerWiringAllowed = actualLiveServerWiringAllowed
        this.actualDefaultEngineFlipAllowed = actualDefaultEngineFlipAllowed
        this.defaultEngineConfigMutationAllowed =
            defaultEngineConfigMutationAllowed
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h1H2QuicRuntimeClosureClaimAllowed =
            h1H2QuicRuntimeClosureClaimAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteRuntimeDefaultPathMutationPreparationBoundaryReceipt(
    preparationGateReceipt: IgniteRuntimeDefaultPathMutationPreparationGateReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationBoundaryRequest
): IgniteRuntimeDefaultPathMutationPreparationBoundaryReceipt {
    let nonClaims = igniteRuntimeDefaultPathMutationPreparationBoundaryNonClaims()
    if (!preparationGateReceipt.runtimeDefaultPathMutationPreparationGateAccepted) {
        return IgniteRuntimeDefaultPathMutationPreparationBoundaryReceipt(
            false,
            preparationGateReceipt.runtimeDefaultPathMutationPreparationGateAccepted,
            preparationGateReceipt.runtimeDefaultPathMutationPreparationGateMode,
            "none",
            request.runtimeDefaultPathMutationPreparationBoundaryId,
            preparationGateReceipt.runtimeDefaultPathMutationPreparationGateId,
            preparationGateReceipt.closeoutBoundaryGateId,
            preparationGateReceipt.closeoutBoundaryId,
            preparationGateReceipt.closeoutId,
            preparationGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-boundary-upstream-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-gate-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0511 runtime default-path mutation preparation gate input before preparation boundary work",
            "QUIC must not consume preparation boundary receipts from rejected runtime default-path mutation preparation gate receipts"
        )
    }

    let preparationBoundaryMode =
        igniteRuntimeDefaultPathMutationPreparationBoundaryModeFor(
            preparationGateReceipt.runtimeDefaultPathMutationPreparationGateMode
        )
    let blockers = igniteRuntimeDefaultPathMutationPreparationBoundaryBlockers(
        request,
        preparationBoundaryMode
    )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationBoundaryReceipt(
            false,
            preparationGateReceipt.runtimeDefaultPathMutationPreparationGateAccepted,
            preparationGateReceipt.runtimeDefaultPathMutationPreparationGateMode,
            preparationBoundaryMode,
            request.runtimeDefaultPathMutationPreparationBoundaryId,
            preparationGateReceipt.runtimeDefaultPathMutationPreparationGateId,
            preparationGateReceipt.closeoutBoundaryGateId,
            preparationGateReceipt.closeoutBoundaryId,
            preparationGateReceipt.closeoutId,
            preparationGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-boundary-input",
            "fix-runtime-default-path-mutation-preparation-boundary-before-runtime-default-mutation",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry preparation boundary id, accepted preparation gate receipt, preparation boundary marker, readiness review, rollback verification, default path candidate freeze, runtime guard review, observability review, source-zero stdx separation, public claim boundary, and QUIC reuse boundary",
            "QUIC can reuse the same runtime default-path mutation preparation boundary blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationPreparationBoundaryReceipt(
        true,
        preparationGateReceipt.runtimeDefaultPathMutationPreparationGateAccepted,
        preparationGateReceipt.runtimeDefaultPathMutationPreparationGateMode,
        preparationBoundaryMode,
        request.runtimeDefaultPathMutationPreparationBoundaryId,
        preparationGateReceipt.runtimeDefaultPathMutationPreparationGateId,
        preparationGateReceipt.closeoutBoundaryGateId,
        preparationGateReceipt.closeoutBoundaryId,
        preparationGateReceipt.closeoutId,
        preparationGateReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-boundary",
        "accepted-runtime-default-path-mutation-preparation-boundary-receipt",
        "record-runtime-default-path-mutation-preparation-boundary-without-runtime-default-mutation",
        [],
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
        nonClaims,
        "next packet may prove runtime default-path mutation preparation dry-run without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation boundary modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationBoundaryModeFor(
    preparationGateMode: String
): String {
    if (preparationGateMode == "short-runtime-default-path-mutation-preparation-gate") {
        return "short-runtime-default-path-mutation-preparation-boundary"
    }
    if (preparationGateMode == "long-runtime-default-path-mutation-preparation-gate") {
        return "long-runtime-default-path-mutation-preparation-boundary"
    }
    if (
        preparationGateMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-gate"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-boundary"
    }
    "unknown-runtime-default-path-mutation-preparation-boundary"
}

func igniteRuntimeDefaultPathMutationPreparationBoundaryBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationBoundaryRequest,
    preparationBoundaryMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.runtimeDefaultPathMutationPreparationBoundaryId.size == 0) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_BOUNDARY_ID_NOT_CARRIED")
    }
    if (!request.preparationGateReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_GATE_RECEIPT_NOT_CARRIED")
    }
    if (!request.preparationBoundaryMarkerCarried) {
        blockers.add("PREPARATION_BOUNDARY_MARKER_NOT_CARRIED")
    }
    if (!request.mutationReadinessReviewMarkerCarried) {
        blockers.add("MUTATION_READINESS_REVIEW_MARKER_NOT_CARRIED")
    }
    if (!request.rollbackVerificationMarkerCarried) {
        blockers.add("ROLLBACK_VERIFICATION_MARKER_NOT_CARRIED")
    }
    if (!request.defaultPathCandidateFreezeCarried) {
        blockers.add("DEFAULT_PATH_CANDIDATE_FREEZE_NOT_CARRIED")
    }
    if (!request.runtimeGuardReviewCarried) {
        blockers.add("RUNTIME_GUARD_REVIEW_NOT_CARRIED")
    }
    if (!request.observabilityReviewCarried) {
        blockers.add("OBSERVABILITY_REVIEW_NOT_CARRIED")
    }
    if (!request.sourceZeroStdxClaimSeparated) {
        blockers.add("SOURCE_ZERO_STDX_CLAIM_NOT_SEPARATED")
    }
    if (!request.publicClaimBoundaryCarried) {
        blockers.add("PUBLIC_CLAIM_BOUNDARY_NOT_CARRIED")
    }
    if (!request.quicReuseBoundaryCarried) {
        blockers.add("QUIC_REUSE_BOUNDARY_NOT_CARRIED")
    }
    if (request.productionQueueMutationRequested) {
        blockers.add("PRODUCTION_QUEUE_MUTATION_REQUESTED")
    }
    if (request.actualRuntimeTaskSpawnRequested) {
        blockers.add("ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.actualHandlerInvocationRequested) {
        blockers.add("ACTUAL_HANDLER_INVOCATION_REQUESTED")
    }
    if (request.actualRequestContextMutationRequested) {
        blockers.add("ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.actualResponseWriteRequested) {
        blockers.add("ACTUAL_RESPONSE_WRITE_REQUESTED")
    }
    if (request.actualTransportCommitRequested) {
        blockers.add("ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.actualLiveServerWiringRequested) {
        blockers.add("ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    }
    if (request.actualDefaultEngineFlipRequested) {
        blockers.add("ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    }
    if (request.defaultEngineConfigMutationRequested) {
        blockers.add("DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    }
    if (request.runtimeDefaultPathMutationRequested) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    }
    if (request.publicReleaseRequested) {
        blockers.add("PUBLIC_RELEASE_REQUESTED")
    }
    if (request.stdxRemovalRequested) {
        blockers.add("STDX_REMOVAL_REQUESTED")
    }
    if (request.h1H2QuicRuntimeClosureClaimed) {
        blockers.add("H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    }
    if (
        preparationBoundaryMode ==
        "unknown-runtime-default-path-mutation-preparation-boundary"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_GATE_MODE")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationBoundaryNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationGateNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationDryRunRequest {
    public let runtimeDefaultPathMutationPreparationDryRunId: String
    public let preparationBoundaryReceiptCarried: Bool
    public let preparationDryRunPlanCarried: Bool
    public let simulationInputSnapshotCarried: Bool
    public let defaultPathCandidateSnapshotCarried: Bool
    public let rollbackDryRunPlanCarried: Bool
    public let runtimeGuardDryRunCarried: Bool
    public let observabilityDryRunMarkerCarried: Bool
    public let sourceZeroStdxClaimSeparated: Bool
    public let publicClaimBoundaryCarried: Bool
    public let quicReuseBoundaryCarried: Bool
    public let productionQueueMutationRequested: Bool
    public let actualRuntimeTaskSpawnRequested: Bool
    public let actualHandlerInvocationRequested: Bool
    public let actualRequestContextMutationRequested: Bool
    public let actualResponseWriteRequested: Bool
    public let actualTransportCommitRequested: Bool
    public let actualLiveServerWiringRequested: Bool
    public let actualDefaultEngineFlipRequested: Bool
    public let defaultEngineConfigMutationRequested: Bool
    public let runtimeDefaultPathMutationRequested: Bool
    public let publicReleaseRequested: Bool
    public let stdxRemovalRequested: Bool
    public let h1H2QuicRuntimeClosureClaimed: Bool

    public init(
        runtimeDefaultPathMutationPreparationDryRunId: String,
        preparationBoundaryReceiptCarried: Bool,
        preparationDryRunPlanCarried: Bool,
        simulationInputSnapshotCarried: Bool,
        defaultPathCandidateSnapshotCarried: Bool,
        rollbackDryRunPlanCarried: Bool,
        runtimeGuardDryRunCarried: Bool,
        observabilityDryRunMarkerCarried: Bool,
        sourceZeroStdxClaimSeparated: Bool,
        publicClaimBoundaryCarried: Bool,
        quicReuseBoundaryCarried: Bool,
        productionQueueMutationRequested: Bool,
        actualRuntimeTaskSpawnRequested: Bool,
        actualHandlerInvocationRequested: Bool,
        actualRequestContextMutationRequested: Bool,
        actualResponseWriteRequested: Bool,
        actualTransportCommitRequested: Bool,
        actualLiveServerWiringRequested: Bool,
        actualDefaultEngineFlipRequested: Bool,
        defaultEngineConfigMutationRequested: Bool,
        runtimeDefaultPathMutationRequested: Bool,
        publicReleaseRequested: Bool,
        stdxRemovalRequested: Bool,
        h1H2QuicRuntimeClosureClaimed: Bool
    ) {
        this.runtimeDefaultPathMutationPreparationDryRunId =
            runtimeDefaultPathMutationPreparationDryRunId
        this.preparationBoundaryReceiptCarried =
            preparationBoundaryReceiptCarried
        this.preparationDryRunPlanCarried = preparationDryRunPlanCarried
        this.simulationInputSnapshotCarried =
            simulationInputSnapshotCarried
        this.defaultPathCandidateSnapshotCarried =
            defaultPathCandidateSnapshotCarried
        this.rollbackDryRunPlanCarried = rollbackDryRunPlanCarried
        this.runtimeGuardDryRunCarried = runtimeGuardDryRunCarried
        this.observabilityDryRunMarkerCarried =
            observabilityDryRunMarkerCarried
        this.sourceZeroStdxClaimSeparated = sourceZeroStdxClaimSeparated
        this.publicClaimBoundaryCarried = publicClaimBoundaryCarried
        this.quicReuseBoundaryCarried = quicReuseBoundaryCarried
        this.productionQueueMutationRequested = productionQueueMutationRequested
        this.actualRuntimeTaskSpawnRequested = actualRuntimeTaskSpawnRequested
        this.actualHandlerInvocationRequested = actualHandlerInvocationRequested
        this.actualRequestContextMutationRequested =
            actualRequestContextMutationRequested
        this.actualResponseWriteRequested = actualResponseWriteRequested
        this.actualTransportCommitRequested = actualTransportCommitRequested
        this.actualLiveServerWiringRequested = actualLiveServerWiringRequested
        this.actualDefaultEngineFlipRequested =
            actualDefaultEngineFlipRequested
        this.defaultEngineConfigMutationRequested =
            defaultEngineConfigMutationRequested
        this.runtimeDefaultPathMutationRequested =
            runtimeDefaultPathMutationRequested
        this.publicReleaseRequested = publicReleaseRequested
        this.stdxRemovalRequested = stdxRemovalRequested
        this.h1H2QuicRuntimeClosureClaimed = h1H2QuicRuntimeClosureClaimed
    }
}

public class IgniteRuntimeDefaultPathMutationPreparationDryRunReceipt {
    public let runtimeDefaultPathMutationPreparationDryRunAccepted: Bool
    public let preparationBoundaryAccepted: Bool
    public let preparationBoundaryMode: String
    public let runtimeDefaultPathMutationPreparationDryRunMode: String
    public let runtimeDefaultPathMutationPreparationDryRunId: String
    public let preparationBoundaryId: String
    public let preparationGateId: String
    public let closeoutBoundaryGateId: String
    public let closeoutBoundaryId: String
    public let closeoutId: String
    public let preparationBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationBoundaryReceipt
    public let runtimeDefaultPathMutationPreparationDryRunRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationDryRunAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let actualHandlerInvocationAllowed: Bool
    public let actualRequestContextMutationAllowed: Bool
    public let actualResponseWriteAllowed: Bool
    public let actualTransportCommitAllowed: Bool
    public let actualLiveServerWiringAllowed: Bool
    public let actualDefaultEngineFlipAllowed: Bool
    public let defaultEngineConfigMutationAllowed: Bool
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h1H2QuicRuntimeClosureClaimAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        runtimeDefaultPathMutationPreparationDryRunAccepted: Bool,
        preparationBoundaryAccepted: Bool,
        preparationBoundaryMode: String,
        runtimeDefaultPathMutationPreparationDryRunMode: String,
        runtimeDefaultPathMutationPreparationDryRunId: String,
        preparationBoundaryId: String,
        preparationGateId: String,
        closeoutBoundaryGateId: String,
        closeoutBoundaryId: String,
        closeoutId: String,
        preparationBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationBoundaryReceipt,
        runtimeDefaultPathMutationPreparationDryRunRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationDryRunAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        actualHandlerInvocationAllowed: Bool,
        actualRequestContextMutationAllowed: Bool,
        actualResponseWriteAllowed: Bool,
        actualTransportCommitAllowed: Bool,
        actualLiveServerWiringAllowed: Bool,
        actualDefaultEngineFlipAllowed: Bool,
        defaultEngineConfigMutationAllowed: Bool,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h1H2QuicRuntimeClosureClaimAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.runtimeDefaultPathMutationPreparationDryRunAccepted =
            runtimeDefaultPathMutationPreparationDryRunAccepted
        this.preparationBoundaryAccepted = preparationBoundaryAccepted
        this.preparationBoundaryMode = preparationBoundaryMode
        this.runtimeDefaultPathMutationPreparationDryRunMode =
            runtimeDefaultPathMutationPreparationDryRunMode
        this.runtimeDefaultPathMutationPreparationDryRunId =
            runtimeDefaultPathMutationPreparationDryRunId
        this.preparationBoundaryId = preparationBoundaryId
        this.preparationGateId = preparationGateId
        this.closeoutBoundaryGateId = closeoutBoundaryGateId
        this.closeoutBoundaryId = closeoutBoundaryId
        this.closeoutId = closeoutId
        this.preparationBoundaryReceipt = preparationBoundaryReceipt
        this.runtimeDefaultPathMutationPreparationDryRunRecorded =
            runtimeDefaultPathMutationPreparationDryRunRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationDryRunAllowed =
            runtimeDefaultPathMutationPreparationDryRunAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.actualRuntimeTaskSpawnAllowed = actualRuntimeTaskSpawnAllowed
        this.actualHandlerInvocationAllowed = actualHandlerInvocationAllowed
        this.actualRequestContextMutationAllowed =
            actualRequestContextMutationAllowed
        this.actualResponseWriteAllowed = actualResponseWriteAllowed
        this.actualTransportCommitAllowed = actualTransportCommitAllowed
        this.actualLiveServerWiringAllowed = actualLiveServerWiringAllowed
        this.actualDefaultEngineFlipAllowed = actualDefaultEngineFlipAllowed
        this.defaultEngineConfigMutationAllowed =
            defaultEngineConfigMutationAllowed
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h1H2QuicRuntimeClosureClaimAllowed =
            h1H2QuicRuntimeClosureClaimAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteRuntimeDefaultPathMutationPreparationDryRunReceipt(
    preparationBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationBoundaryReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationDryRunRequest
): IgniteRuntimeDefaultPathMutationPreparationDryRunReceipt {
    let nonClaims = igniteRuntimeDefaultPathMutationPreparationDryRunNonClaims()
    if (
        !preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationBoundaryAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationDryRunReceipt(
            false,
            preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationBoundaryAccepted,
            preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationBoundaryMode,
            "none",
            request.runtimeDefaultPathMutationPreparationDryRunId,
            preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationBoundaryId,
            preparationBoundaryReceipt.preparationGateId,
            preparationBoundaryReceipt.closeoutBoundaryGateId,
            preparationBoundaryReceipt.closeoutBoundaryId,
            preparationBoundaryReceipt.closeoutId,
            preparationBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-dry-run-upstream-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-boundary-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_BOUNDARY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0512 runtime default-path mutation preparation boundary input before preparation dry-run work",
            "QUIC must not consume preparation dry-run receipts from rejected runtime default-path mutation preparation boundary receipts"
        )
    }

    let preparationDryRunMode =
        igniteRuntimeDefaultPathMutationPreparationDryRunModeFor(
            preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationBoundaryMode
        )
    let blockers = igniteRuntimeDefaultPathMutationPreparationDryRunBlockers(
        request,
        preparationDryRunMode
    )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationDryRunReceipt(
            false,
            preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationBoundaryAccepted,
            preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationBoundaryMode,
            preparationDryRunMode,
            request.runtimeDefaultPathMutationPreparationDryRunId,
            preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationBoundaryId,
            preparationBoundaryReceipt.preparationGateId,
            preparationBoundaryReceipt.closeoutBoundaryGateId,
            preparationBoundaryReceipt.closeoutBoundaryId,
            preparationBoundaryReceipt.closeoutId,
            preparationBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-dry-run-input",
            "fix-runtime-default-path-mutation-preparation-dry-run-before-runtime-default-mutation",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry preparation dry-run id, accepted preparation boundary receipt, dry-run plan, simulation inputs, default-path candidate snapshot, rollback dry-run plan, runtime guard dry-run, observability marker, source-zero stdx separation, public claim boundary, and QUIC reuse boundary",
            "QUIC can reuse the same runtime default-path mutation preparation dry-run blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationPreparationDryRunReceipt(
        true,
        preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationBoundaryAccepted,
        preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationBoundaryMode,
        preparationDryRunMode,
        request.runtimeDefaultPathMutationPreparationDryRunId,
        preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationBoundaryId,
        preparationBoundaryReceipt.preparationGateId,
        preparationBoundaryReceipt.closeoutBoundaryGateId,
        preparationBoundaryReceipt.closeoutBoundaryId,
        preparationBoundaryReceipt.closeoutId,
        preparationBoundaryReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-dry-run",
        "accepted-runtime-default-path-mutation-preparation-dry-run-receipt",
        "record-runtime-default-path-mutation-preparation-dry-run-without-runtime-default-mutation",
        [],
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
        nonClaims,
        "next packet may prove runtime default-path mutation preparation apply-gate without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation dry-run modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationDryRunModeFor(
    preparationBoundaryMode: String
): String {
    if (
        preparationBoundaryMode ==
        "short-runtime-default-path-mutation-preparation-boundary"
    ) {
        return "short-runtime-default-path-mutation-preparation-dry-run"
    }
    if (
        preparationBoundaryMode ==
        "long-runtime-default-path-mutation-preparation-boundary"
    ) {
        return "long-runtime-default-path-mutation-preparation-dry-run"
    }
    if (
        preparationBoundaryMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-boundary"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-dry-run"
    }
    "unknown-runtime-default-path-mutation-preparation-dry-run"
}

func igniteRuntimeDefaultPathMutationPreparationDryRunBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationDryRunRequest,
    preparationDryRunMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.runtimeDefaultPathMutationPreparationDryRunId.size == 0) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_DRY_RUN_ID_NOT_CARRIED")
    }
    if (!request.preparationBoundaryReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_BOUNDARY_RECEIPT_NOT_CARRIED")
    }
    if (!request.preparationDryRunPlanCarried) {
        blockers.add("PREPARATION_DRY_RUN_PLAN_NOT_CARRIED")
    }
    if (!request.simulationInputSnapshotCarried) {
        blockers.add("SIMULATION_INPUT_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.defaultPathCandidateSnapshotCarried) {
        blockers.add("DEFAULT_PATH_CANDIDATE_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.rollbackDryRunPlanCarried) {
        blockers.add("ROLLBACK_DRY_RUN_PLAN_NOT_CARRIED")
    }
    if (!request.runtimeGuardDryRunCarried) {
        blockers.add("RUNTIME_GUARD_DRY_RUN_NOT_CARRIED")
    }
    if (!request.observabilityDryRunMarkerCarried) {
        blockers.add("OBSERVABILITY_DRY_RUN_MARKER_NOT_CARRIED")
    }
    if (!request.sourceZeroStdxClaimSeparated) {
        blockers.add("SOURCE_ZERO_STDX_CLAIM_NOT_SEPARATED")
    }
    if (!request.publicClaimBoundaryCarried) {
        blockers.add("PUBLIC_CLAIM_BOUNDARY_NOT_CARRIED")
    }
    if (!request.quicReuseBoundaryCarried) {
        blockers.add("QUIC_REUSE_BOUNDARY_NOT_CARRIED")
    }
    if (request.productionQueueMutationRequested) {
        blockers.add("PRODUCTION_QUEUE_MUTATION_REQUESTED")
    }
    if (request.actualRuntimeTaskSpawnRequested) {
        blockers.add("ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.actualHandlerInvocationRequested) {
        blockers.add("ACTUAL_HANDLER_INVOCATION_REQUESTED")
    }
    if (request.actualRequestContextMutationRequested) {
        blockers.add("ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.actualResponseWriteRequested) {
        blockers.add("ACTUAL_RESPONSE_WRITE_REQUESTED")
    }
    if (request.actualTransportCommitRequested) {
        blockers.add("ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.actualLiveServerWiringRequested) {
        blockers.add("ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    }
    if (request.actualDefaultEngineFlipRequested) {
        blockers.add("ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    }
    if (request.defaultEngineConfigMutationRequested) {
        blockers.add("DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    }
    if (request.runtimeDefaultPathMutationRequested) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    }
    if (request.publicReleaseRequested) {
        blockers.add("PUBLIC_RELEASE_REQUESTED")
    }
    if (request.stdxRemovalRequested) {
        blockers.add("STDX_REMOVAL_REQUESTED")
    }
    if (request.h1H2QuicRuntimeClosureClaimed) {
        blockers.add("H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    }
    if (
        preparationDryRunMode ==
        "unknown-runtime-default-path-mutation-preparation-dry-run"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_BOUNDARY_MODE")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationDryRunNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationBoundaryNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationApplyGateRequest {
    public let runtimeDefaultPathMutationPreparationApplyGateId: String
    public let preparationDryRunReceiptCarried: Bool
    public let preparationApplyGateMarkerCarried: Bool
    public let dryRunResultReviewCarried: Bool
    public let applyReadinessMarkerCarried: Bool
    public let rollbackApplyGateCarried: Bool
    public let runtimeGuardApplyGateCarried: Bool
    public let observabilityApplyGateMarkerCarried: Bool
    public let sourceZeroStdxClaimSeparated: Bool
    public let publicClaimBoundaryCarried: Bool
    public let quicReuseBoundaryCarried: Bool
    public let productionQueueMutationRequested: Bool
    public let actualRuntimeTaskSpawnRequested: Bool
    public let actualHandlerInvocationRequested: Bool
    public let actualRequestContextMutationRequested: Bool
    public let actualResponseWriteRequested: Bool
    public let actualTransportCommitRequested: Bool
    public let actualLiveServerWiringRequested: Bool
    public let actualDefaultEngineFlipRequested: Bool
    public let defaultEngineConfigMutationRequested: Bool
    public let runtimeDefaultPathMutationRequested: Bool
    public let publicReleaseRequested: Bool
    public let stdxRemovalRequested: Bool
    public let h1H2QuicRuntimeClosureClaimed: Bool

    public init(
        runtimeDefaultPathMutationPreparationApplyGateId: String,
        preparationDryRunReceiptCarried: Bool,
        preparationApplyGateMarkerCarried: Bool,
        dryRunResultReviewCarried: Bool,
        applyReadinessMarkerCarried: Bool,
        rollbackApplyGateCarried: Bool,
        runtimeGuardApplyGateCarried: Bool,
        observabilityApplyGateMarkerCarried: Bool,
        sourceZeroStdxClaimSeparated: Bool,
        publicClaimBoundaryCarried: Bool,
        quicReuseBoundaryCarried: Bool,
        productionQueueMutationRequested: Bool,
        actualRuntimeTaskSpawnRequested: Bool,
        actualHandlerInvocationRequested: Bool,
        actualRequestContextMutationRequested: Bool,
        actualResponseWriteRequested: Bool,
        actualTransportCommitRequested: Bool,
        actualLiveServerWiringRequested: Bool,
        actualDefaultEngineFlipRequested: Bool,
        defaultEngineConfigMutationRequested: Bool,
        runtimeDefaultPathMutationRequested: Bool,
        publicReleaseRequested: Bool,
        stdxRemovalRequested: Bool,
        h1H2QuicRuntimeClosureClaimed: Bool
    ) {
        this.runtimeDefaultPathMutationPreparationApplyGateId =
            runtimeDefaultPathMutationPreparationApplyGateId
        this.preparationDryRunReceiptCarried =
            preparationDryRunReceiptCarried
        this.preparationApplyGateMarkerCarried =
            preparationApplyGateMarkerCarried
        this.dryRunResultReviewCarried = dryRunResultReviewCarried
        this.applyReadinessMarkerCarried = applyReadinessMarkerCarried
        this.rollbackApplyGateCarried = rollbackApplyGateCarried
        this.runtimeGuardApplyGateCarried = runtimeGuardApplyGateCarried
        this.observabilityApplyGateMarkerCarried =
            observabilityApplyGateMarkerCarried
        this.sourceZeroStdxClaimSeparated = sourceZeroStdxClaimSeparated
        this.publicClaimBoundaryCarried = publicClaimBoundaryCarried
        this.quicReuseBoundaryCarried = quicReuseBoundaryCarried
        this.productionQueueMutationRequested = productionQueueMutationRequested
        this.actualRuntimeTaskSpawnRequested = actualRuntimeTaskSpawnRequested
        this.actualHandlerInvocationRequested = actualHandlerInvocationRequested
        this.actualRequestContextMutationRequested =
            actualRequestContextMutationRequested
        this.actualResponseWriteRequested = actualResponseWriteRequested
        this.actualTransportCommitRequested = actualTransportCommitRequested
        this.actualLiveServerWiringRequested = actualLiveServerWiringRequested
        this.actualDefaultEngineFlipRequested =
            actualDefaultEngineFlipRequested
        this.defaultEngineConfigMutationRequested =
            defaultEngineConfigMutationRequested
        this.runtimeDefaultPathMutationRequested =
            runtimeDefaultPathMutationRequested
        this.publicReleaseRequested = publicReleaseRequested
        this.stdxRemovalRequested = stdxRemovalRequested
        this.h1H2QuicRuntimeClosureClaimed = h1H2QuicRuntimeClosureClaimed
    }
}

public class IgniteRuntimeDefaultPathMutationPreparationApplyGateReceipt {
    public let runtimeDefaultPathMutationPreparationApplyGateAccepted: Bool
    public let preparationDryRunAccepted: Bool
    public let preparationDryRunMode: String
    public let runtimeDefaultPathMutationPreparationApplyGateMode: String
    public let runtimeDefaultPathMutationPreparationApplyGateId: String
    public let preparationDryRunId: String
    public let preparationBoundaryId: String
    public let preparationGateId: String
    public let closeoutBoundaryGateId: String
    public let closeoutBoundaryId: String
    public let closeoutId: String
    public let preparationDryRunReceipt: IgniteRuntimeDefaultPathMutationPreparationDryRunReceipt
    public let runtimeDefaultPathMutationPreparationApplyGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationApplyGateAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let actualHandlerInvocationAllowed: Bool
    public let actualRequestContextMutationAllowed: Bool
    public let actualResponseWriteAllowed: Bool
    public let actualTransportCommitAllowed: Bool
    public let actualLiveServerWiringAllowed: Bool
    public let actualDefaultEngineFlipAllowed: Bool
    public let defaultEngineConfigMutationAllowed: Bool
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h1H2QuicRuntimeClosureClaimAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        runtimeDefaultPathMutationPreparationApplyGateAccepted: Bool,
        preparationDryRunAccepted: Bool,
        preparationDryRunMode: String,
        runtimeDefaultPathMutationPreparationApplyGateMode: String,
        runtimeDefaultPathMutationPreparationApplyGateId: String,
        preparationDryRunId: String,
        preparationBoundaryId: String,
        preparationGateId: String,
        closeoutBoundaryGateId: String,
        closeoutBoundaryId: String,
        closeoutId: String,
        preparationDryRunReceipt: IgniteRuntimeDefaultPathMutationPreparationDryRunReceipt,
        runtimeDefaultPathMutationPreparationApplyGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationApplyGateAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        actualHandlerInvocationAllowed: Bool,
        actualRequestContextMutationAllowed: Bool,
        actualResponseWriteAllowed: Bool,
        actualTransportCommitAllowed: Bool,
        actualLiveServerWiringAllowed: Bool,
        actualDefaultEngineFlipAllowed: Bool,
        defaultEngineConfigMutationAllowed: Bool,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h1H2QuicRuntimeClosureClaimAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.runtimeDefaultPathMutationPreparationApplyGateAccepted =
            runtimeDefaultPathMutationPreparationApplyGateAccepted
        this.preparationDryRunAccepted = preparationDryRunAccepted
        this.preparationDryRunMode = preparationDryRunMode
        this.runtimeDefaultPathMutationPreparationApplyGateMode =
            runtimeDefaultPathMutationPreparationApplyGateMode
        this.runtimeDefaultPathMutationPreparationApplyGateId =
            runtimeDefaultPathMutationPreparationApplyGateId
        this.preparationDryRunId = preparationDryRunId
        this.preparationBoundaryId = preparationBoundaryId
        this.preparationGateId = preparationGateId
        this.closeoutBoundaryGateId = closeoutBoundaryGateId
        this.closeoutBoundaryId = closeoutBoundaryId
        this.closeoutId = closeoutId
        this.preparationDryRunReceipt = preparationDryRunReceipt
        this.runtimeDefaultPathMutationPreparationApplyGateRecorded =
            runtimeDefaultPathMutationPreparationApplyGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationApplyGateAllowed =
            runtimeDefaultPathMutationPreparationApplyGateAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.actualRuntimeTaskSpawnAllowed = actualRuntimeTaskSpawnAllowed
        this.actualHandlerInvocationAllowed = actualHandlerInvocationAllowed
        this.actualRequestContextMutationAllowed =
            actualRequestContextMutationAllowed
        this.actualResponseWriteAllowed = actualResponseWriteAllowed
        this.actualTransportCommitAllowed = actualTransportCommitAllowed
        this.actualLiveServerWiringAllowed = actualLiveServerWiringAllowed
        this.actualDefaultEngineFlipAllowed = actualDefaultEngineFlipAllowed
        this.defaultEngineConfigMutationAllowed =
            defaultEngineConfigMutationAllowed
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h1H2QuicRuntimeClosureClaimAllowed =
            h1H2QuicRuntimeClosureClaimAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteRuntimeDefaultPathMutationPreparationApplyGateReceipt(
    preparationDryRunReceipt: IgniteRuntimeDefaultPathMutationPreparationDryRunReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationApplyGateRequest
): IgniteRuntimeDefaultPathMutationPreparationApplyGateReceipt {
    let nonClaims = igniteRuntimeDefaultPathMutationPreparationApplyGateNonClaims()
    if (
        !preparationDryRunReceipt.runtimeDefaultPathMutationPreparationDryRunAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyGateReceipt(
            false,
            preparationDryRunReceipt.runtimeDefaultPathMutationPreparationDryRunAccepted,
            preparationDryRunReceipt.runtimeDefaultPathMutationPreparationDryRunMode,
            "none",
            request.runtimeDefaultPathMutationPreparationApplyGateId,
            preparationDryRunReceipt.runtimeDefaultPathMutationPreparationDryRunId,
            preparationDryRunReceipt.preparationBoundaryId,
            preparationDryRunReceipt.preparationGateId,
            preparationDryRunReceipt.closeoutBoundaryGateId,
            preparationDryRunReceipt.closeoutBoundaryId,
            preparationDryRunReceipt.closeoutId,
            preparationDryRunReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-gate-upstream-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-dry-run-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_DRY_RUN_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0513 runtime default-path mutation preparation dry-run input before preparation apply-gate work",
            "QUIC must not consume preparation apply-gate receipts from rejected runtime default-path mutation preparation dry-run receipts"
        )
    }

    let preparationApplyGateMode =
        igniteRuntimeDefaultPathMutationPreparationApplyGateModeFor(
            preparationDryRunReceipt.runtimeDefaultPathMutationPreparationDryRunMode
        )
    let blockers = igniteRuntimeDefaultPathMutationPreparationApplyGateBlockers(
        request,
        preparationApplyGateMode
    )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyGateReceipt(
            false,
            preparationDryRunReceipt.runtimeDefaultPathMutationPreparationDryRunAccepted,
            preparationDryRunReceipt.runtimeDefaultPathMutationPreparationDryRunMode,
            preparationApplyGateMode,
            request.runtimeDefaultPathMutationPreparationApplyGateId,
            preparationDryRunReceipt.runtimeDefaultPathMutationPreparationDryRunId,
            preparationDryRunReceipt.preparationBoundaryId,
            preparationDryRunReceipt.preparationGateId,
            preparationDryRunReceipt.closeoutBoundaryGateId,
            preparationDryRunReceipt.closeoutBoundaryId,
            preparationDryRunReceipt.closeoutId,
            preparationDryRunReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-gate-input",
            "fix-runtime-default-path-mutation-preparation-apply-gate-before-runtime-default-mutation",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry preparation apply-gate id, accepted preparation dry-run receipt, apply-gate marker, dry-run result review, apply readiness, rollback apply gate, runtime guard apply gate, observability marker, source-zero stdx separation, public claim boundary, and QUIC reuse boundary",
            "QUIC can reuse the same runtime default-path mutation preparation apply-gate blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationPreparationApplyGateReceipt(
        true,
        preparationDryRunReceipt.runtimeDefaultPathMutationPreparationDryRunAccepted,
        preparationDryRunReceipt.runtimeDefaultPathMutationPreparationDryRunMode,
        preparationApplyGateMode,
        request.runtimeDefaultPathMutationPreparationApplyGateId,
        preparationDryRunReceipt.runtimeDefaultPathMutationPreparationDryRunId,
        preparationDryRunReceipt.preparationBoundaryId,
        preparationDryRunReceipt.preparationGateId,
        preparationDryRunReceipt.closeoutBoundaryGateId,
        preparationDryRunReceipt.closeoutBoundaryId,
        preparationDryRunReceipt.closeoutId,
        preparationDryRunReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-apply-gate",
        "accepted-runtime-default-path-mutation-preparation-apply-gate-receipt",
        "record-runtime-default-path-mutation-preparation-apply-gate-without-runtime-default-mutation",
        [],
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
        nonClaims,
        "next packet may prove controlled runtime default-path mutation preparation apply without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation apply-gate modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationApplyGateModeFor(
    preparationDryRunMode: String
): String {
    if (
        preparationDryRunMode ==
        "short-runtime-default-path-mutation-preparation-dry-run"
    ) {
        return "short-runtime-default-path-mutation-preparation-apply-gate"
    }
    if (
        preparationDryRunMode ==
        "long-runtime-default-path-mutation-preparation-dry-run"
    ) {
        return "long-runtime-default-path-mutation-preparation-apply-gate"
    }
    if (
        preparationDryRunMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-dry-run"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-apply-gate"
    }
    "unknown-runtime-default-path-mutation-preparation-apply-gate"
}

func igniteRuntimeDefaultPathMutationPreparationApplyGateBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationApplyGateRequest,
    preparationApplyGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.runtimeDefaultPathMutationPreparationApplyGateId.size == 0) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_GATE_ID_NOT_CARRIED")
    }
    if (!request.preparationDryRunReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_DRY_RUN_RECEIPT_NOT_CARRIED")
    }
    if (!request.preparationApplyGateMarkerCarried) {
        blockers.add("PREPARATION_APPLY_GATE_MARKER_NOT_CARRIED")
    }
    if (!request.dryRunResultReviewCarried) {
        blockers.add("DRY_RUN_RESULT_REVIEW_NOT_CARRIED")
    }
    if (!request.applyReadinessMarkerCarried) {
        blockers.add("APPLY_READINESS_MARKER_NOT_CARRIED")
    }
    if (!request.rollbackApplyGateCarried) {
        blockers.add("ROLLBACK_APPLY_GATE_NOT_CARRIED")
    }
    if (!request.runtimeGuardApplyGateCarried) {
        blockers.add("RUNTIME_GUARD_APPLY_GATE_NOT_CARRIED")
    }
    if (!request.observabilityApplyGateMarkerCarried) {
        blockers.add("OBSERVABILITY_APPLY_GATE_MARKER_NOT_CARRIED")
    }
    if (!request.sourceZeroStdxClaimSeparated) {
        blockers.add("SOURCE_ZERO_STDX_CLAIM_NOT_SEPARATED")
    }
    if (!request.publicClaimBoundaryCarried) {
        blockers.add("PUBLIC_CLAIM_BOUNDARY_NOT_CARRIED")
    }
    if (!request.quicReuseBoundaryCarried) {
        blockers.add("QUIC_REUSE_BOUNDARY_NOT_CARRIED")
    }
    if (request.productionQueueMutationRequested) {
        blockers.add("PRODUCTION_QUEUE_MUTATION_REQUESTED")
    }
    if (request.actualRuntimeTaskSpawnRequested) {
        blockers.add("ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.actualHandlerInvocationRequested) {
        blockers.add("ACTUAL_HANDLER_INVOCATION_REQUESTED")
    }
    if (request.actualRequestContextMutationRequested) {
        blockers.add("ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.actualResponseWriteRequested) {
        blockers.add("ACTUAL_RESPONSE_WRITE_REQUESTED")
    }
    if (request.actualTransportCommitRequested) {
        blockers.add("ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.actualLiveServerWiringRequested) {
        blockers.add("ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    }
    if (request.actualDefaultEngineFlipRequested) {
        blockers.add("ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    }
    if (request.defaultEngineConfigMutationRequested) {
        blockers.add("DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    }
    if (request.runtimeDefaultPathMutationRequested) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    }
    if (request.publicReleaseRequested) {
        blockers.add("PUBLIC_RELEASE_REQUESTED")
    }
    if (request.stdxRemovalRequested) {
        blockers.add("STDX_REMOVAL_REQUESTED")
    }
    if (request.h1H2QuicRuntimeClosureClaimed) {
        blockers.add("H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    }
    if (
        preparationApplyGateMode ==
        "unknown-runtime-default-path-mutation-preparation-apply-gate"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_DRY_RUN_MODE")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationApplyGateNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationDryRunNonClaims()
}

public class IgniteControlledRuntimeDefaultPathMutationPreparationApplyRequest {
    public let controlledRuntimeDefaultPathMutationPreparationApplyId: String
    public let preparationApplyGateReceiptCarried: Bool
    public let controlledPreparationApplyScopeCarried: Bool
    public let defaultEngineMutationLockCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let rollbackOrderCarried: Bool
    public let runtimeGuardPlanCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let sourceZeroStdxClaimSeparated: Bool
    public let productionQueueMutationRequested: Bool
    public let actualRuntimeTaskSpawnRequested: Bool
    public let actualHandlerInvocationRequested: Bool
    public let actualRequestContextMutationRequested: Bool
    public let actualResponseWriteRequested: Bool
    public let actualTransportCommitRequested: Bool
    public let actualLiveServerWiringRequested: Bool
    public let actualDefaultEngineFlipRequested: Bool
    public let defaultEngineConfigMutationRequested: Bool
    public let runtimeDefaultPathMutationRequested: Bool
    public let publicReleaseRequested: Bool
    public let stdxRemovalRequested: Bool
    public let h1H2QuicRuntimeClosureClaimed: Bool

    public init(
        controlledRuntimeDefaultPathMutationPreparationApplyId: String,
        preparationApplyGateReceiptCarried: Bool,
        controlledPreparationApplyScopeCarried: Bool,
        defaultEngineMutationLockCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        rollbackOrderCarried: Bool,
        runtimeGuardPlanCarried: Bool,
        observabilityMarkerCarried: Bool,
        sourceZeroStdxClaimSeparated: Bool,
        productionQueueMutationRequested: Bool,
        actualRuntimeTaskSpawnRequested: Bool,
        actualHandlerInvocationRequested: Bool,
        actualRequestContextMutationRequested: Bool,
        actualResponseWriteRequested: Bool,
        actualTransportCommitRequested: Bool,
        actualLiveServerWiringRequested: Bool,
        actualDefaultEngineFlipRequested: Bool,
        defaultEngineConfigMutationRequested: Bool,
        runtimeDefaultPathMutationRequested: Bool,
        publicReleaseRequested: Bool,
        stdxRemovalRequested: Bool,
        h1H2QuicRuntimeClosureClaimed: Bool
    ) {
        this.controlledRuntimeDefaultPathMutationPreparationApplyId =
            controlledRuntimeDefaultPathMutationPreparationApplyId
        this.preparationApplyGateReceiptCarried =
            preparationApplyGateReceiptCarried
        this.controlledPreparationApplyScopeCarried =
            controlledPreparationApplyScopeCarried
        this.defaultEngineMutationLockCarried =
            defaultEngineMutationLockCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.rollbackOrderCarried = rollbackOrderCarried
        this.runtimeGuardPlanCarried = runtimeGuardPlanCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
        this.sourceZeroStdxClaimSeparated = sourceZeroStdxClaimSeparated
        this.productionQueueMutationRequested = productionQueueMutationRequested
        this.actualRuntimeTaskSpawnRequested = actualRuntimeTaskSpawnRequested
        this.actualHandlerInvocationRequested = actualHandlerInvocationRequested
        this.actualRequestContextMutationRequested =
            actualRequestContextMutationRequested
        this.actualResponseWriteRequested = actualResponseWriteRequested
        this.actualTransportCommitRequested = actualTransportCommitRequested
        this.actualLiveServerWiringRequested = actualLiveServerWiringRequested
        this.actualDefaultEngineFlipRequested =
            actualDefaultEngineFlipRequested
        this.defaultEngineConfigMutationRequested =
            defaultEngineConfigMutationRequested
        this.runtimeDefaultPathMutationRequested =
            runtimeDefaultPathMutationRequested
        this.publicReleaseRequested = publicReleaseRequested
        this.stdxRemovalRequested = stdxRemovalRequested
        this.h1H2QuicRuntimeClosureClaimed = h1H2QuicRuntimeClosureClaimed
    }
}

public class IgniteControlledRuntimeDefaultPathMutationPreparationApplyReceipt {
    public let controlledRuntimeDefaultPathMutationPreparationApplyAccepted: Bool
    public let preparationApplyGateAccepted: Bool
    public let preparationApplyGateMode: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyMode: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyId: String
    public let preparationApplyGateId: String
    public let preparationDryRunId: String
    public let preparationBoundaryId: String
    public let preparationGateId: String
    public let closeoutBoundaryGateId: String
    public let closeoutBoundaryId: String
    public let closeoutId: String
    public let preparationApplyGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyGateReceipt
    public let controlledRuntimeDefaultPathMutationPreparationApplyRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let controlledRuntimeDefaultPathMutationPreparationApplyAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let actualHandlerInvocationAllowed: Bool
    public let actualRequestContextMutationAllowed: Bool
    public let actualResponseWriteAllowed: Bool
    public let actualTransportCommitAllowed: Bool
    public let actualLiveServerWiringAllowed: Bool
    public let actualDefaultEngineFlipAllowed: Bool
    public let defaultEngineConfigMutationAllowed: Bool
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h1H2QuicRuntimeClosureClaimAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        controlledRuntimeDefaultPathMutationPreparationApplyAccepted: Bool,
        preparationApplyGateAccepted: Bool,
        preparationApplyGateMode: String,
        controlledRuntimeDefaultPathMutationPreparationApplyMode: String,
        controlledRuntimeDefaultPathMutationPreparationApplyId: String,
        preparationApplyGateId: String,
        preparationDryRunId: String,
        preparationBoundaryId: String,
        preparationGateId: String,
        closeoutBoundaryGateId: String,
        closeoutBoundaryId: String,
        closeoutId: String,
        preparationApplyGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyGateReceipt,
        controlledRuntimeDefaultPathMutationPreparationApplyRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        controlledRuntimeDefaultPathMutationPreparationApplyAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        actualHandlerInvocationAllowed: Bool,
        actualRequestContextMutationAllowed: Bool,
        actualResponseWriteAllowed: Bool,
        actualTransportCommitAllowed: Bool,
        actualLiveServerWiringAllowed: Bool,
        actualDefaultEngineFlipAllowed: Bool,
        defaultEngineConfigMutationAllowed: Bool,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h1H2QuicRuntimeClosureClaimAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.controlledRuntimeDefaultPathMutationPreparationApplyAccepted =
            controlledRuntimeDefaultPathMutationPreparationApplyAccepted
        this.preparationApplyGateAccepted = preparationApplyGateAccepted
        this.preparationApplyGateMode = preparationApplyGateMode
        this.controlledRuntimeDefaultPathMutationPreparationApplyMode =
            controlledRuntimeDefaultPathMutationPreparationApplyMode
        this.controlledRuntimeDefaultPathMutationPreparationApplyId =
            controlledRuntimeDefaultPathMutationPreparationApplyId
        this.preparationApplyGateId = preparationApplyGateId
        this.preparationDryRunId = preparationDryRunId
        this.preparationBoundaryId = preparationBoundaryId
        this.preparationGateId = preparationGateId
        this.closeoutBoundaryGateId = closeoutBoundaryGateId
        this.closeoutBoundaryId = closeoutBoundaryId
        this.closeoutId = closeoutId
        this.preparationApplyGateReceipt = preparationApplyGateReceipt
        this.controlledRuntimeDefaultPathMutationPreparationApplyRecorded =
            controlledRuntimeDefaultPathMutationPreparationApplyRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.controlledRuntimeDefaultPathMutationPreparationApplyAllowed =
            controlledRuntimeDefaultPathMutationPreparationApplyAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.actualRuntimeTaskSpawnAllowed = actualRuntimeTaskSpawnAllowed
        this.actualHandlerInvocationAllowed = actualHandlerInvocationAllowed
        this.actualRequestContextMutationAllowed =
            actualRequestContextMutationAllowed
        this.actualResponseWriteAllowed = actualResponseWriteAllowed
        this.actualTransportCommitAllowed = actualTransportCommitAllowed
        this.actualLiveServerWiringAllowed = actualLiveServerWiringAllowed
        this.actualDefaultEngineFlipAllowed = actualDefaultEngineFlipAllowed
        this.defaultEngineConfigMutationAllowed =
            defaultEngineConfigMutationAllowed
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h1H2QuicRuntimeClosureClaimAllowed =
            h1H2QuicRuntimeClosureClaimAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyReceipt(
    preparationApplyGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyGateReceipt,
    request: IgniteControlledRuntimeDefaultPathMutationPreparationApplyRequest
): IgniteControlledRuntimeDefaultPathMutationPreparationApplyReceipt {
    let nonClaims = igniteControlledRuntimeDefaultPathMutationPreparationApplyNonClaims()
    if (
        !preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyGateAccepted
    ) {
        return IgniteControlledRuntimeDefaultPathMutationPreparationApplyReceipt(
            false,
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyGateAccepted,
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyGateMode,
            "none",
            request.controlledRuntimeDefaultPathMutationPreparationApplyId,
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyGateId,
            preparationApplyGateReceipt.preparationDryRunId,
            preparationApplyGateReceipt.preparationBoundaryId,
            preparationApplyGateReceipt.preparationGateId,
            preparationApplyGateReceipt.closeoutBoundaryGateId,
            preparationApplyGateReceipt.closeoutBoundaryId,
            preparationApplyGateReceipt.closeoutId,
            preparationApplyGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-apply-gate-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0514 runtime default-path mutation preparation apply-gate input before controlled preparation apply work",
            "QUIC must not consume controlled preparation apply receipts from rejected runtime default-path mutation preparation apply-gate receipts"
        )
    }

    let controlledPreparationApplyMode =
        igniteControlledRuntimeDefaultPathMutationPreparationApplyModeFor(
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyGateMode
        )
    let blockers =
        igniteControlledRuntimeDefaultPathMutationPreparationApplyBlockers(
            request,
            controlledPreparationApplyMode
        )
    if (blockers.size > 0) {
        return IgniteControlledRuntimeDefaultPathMutationPreparationApplyReceipt(
            false,
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyGateAccepted,
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyGateMode,
            controlledPreparationApplyMode,
            request.controlledRuntimeDefaultPathMutationPreparationApplyId,
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyGateId,
            preparationApplyGateReceipt.preparationDryRunId,
            preparationApplyGateReceipt.preparationBoundaryId,
            preparationApplyGateReceipt.preparationGateId,
            preparationApplyGateReceipt.closeoutBoundaryGateId,
            preparationApplyGateReceipt.closeoutBoundaryId,
            preparationApplyGateReceipt.closeoutId,
            preparationApplyGateReceipt,
            false,
            "block",
            "blocked-controlled-runtime-default-path-mutation-preparation-apply-input",
            "fix-controlled-runtime-default-path-mutation-preparation-apply-before-runtime-default-mutation",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry controlled preparation apply id, preparation apply-gate receipt, controlled scope, mutation locks, rollback order, runtime guard plan, observability marker, source-zero stdx separation, and keep runtime default mutation out",
            "QUIC can reuse the same controlled preparation apply blockers before default stream runtime mutation"
        )
    }

    IgniteControlledRuntimeDefaultPathMutationPreparationApplyReceipt(
        true,
        preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyGateAccepted,
        preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyGateMode,
        controlledPreparationApplyMode,
        request.controlledRuntimeDefaultPathMutationPreparationApplyId,
        preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyGateId,
        preparationApplyGateReceipt.preparationDryRunId,
        preparationApplyGateReceipt.preparationBoundaryId,
        preparationApplyGateReceipt.preparationGateId,
        preparationApplyGateReceipt.closeoutBoundaryGateId,
        preparationApplyGateReceipt.closeoutBoundaryId,
        preparationApplyGateReceipt.closeoutId,
        preparationApplyGateReceipt,
        true,
        "record-controlled-runtime-default-path-mutation-preparation-apply",
        "accepted-controlled-runtime-default-path-mutation-preparation-apply-receipt",
        "record-controlled-runtime-default-path-mutation-preparation-apply-without-runtime-default-mutation",
        [],
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
        nonClaims,
        "next packet may prove runtime default-path mutation preparation commit-plan without mutating runtime defaults",
        "QUIC can reuse lane-specific controlled preparation apply modes before runtime default mutation"
    )
}

func igniteControlledRuntimeDefaultPathMutationPreparationApplyModeFor(
    preparationApplyGateMode: String
): String {
    if (
        preparationApplyGateMode ==
        "short-runtime-default-path-mutation-preparation-apply-gate"
    ) {
        return "short-controlled-runtime-default-path-mutation-preparation-apply"
    }
    if (
        preparationApplyGateMode ==
        "long-runtime-default-path-mutation-preparation-apply-gate"
    ) {
        return "long-controlled-runtime-default-path-mutation-preparation-apply"
    }
    if (
        preparationApplyGateMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-gate"
    ) {
        return "blocking-isolation-controlled-runtime-default-path-mutation-preparation-apply"
    }
    "unknown-controlled-runtime-default-path-mutation-preparation-apply"
}

func igniteControlledRuntimeDefaultPathMutationPreparationApplyBlockers(
    request: IgniteControlledRuntimeDefaultPathMutationPreparationApplyRequest,
    controlledPreparationApplyMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.controlledRuntimeDefaultPathMutationPreparationApplyId.size == 0
    ) {
        blockers.add("CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_ID_NOT_CARRIED")
    }
    if (!request.preparationApplyGateReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_GATE_RECEIPT_NOT_CARRIED")
    }
    if (!request.controlledPreparationApplyScopeCarried) {
        blockers.add("CONTROLLED_PREPARATION_APPLY_SCOPE_NOT_CARRIED")
    }
    if (!request.defaultEngineMutationLockCarried) {
        blockers.add("DEFAULT_ENGINE_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.rollbackOrderCarried) {
        blockers.add("ROLLBACK_ORDER_NOT_CARRIED")
    }
    if (!request.runtimeGuardPlanCarried) {
        blockers.add("RUNTIME_GUARD_PLAN_NOT_CARRIED")
    }
    if (!request.observabilityMarkerCarried) {
        blockers.add("OBSERVABILITY_MARKER_NOT_CARRIED")
    }
    if (!request.sourceZeroStdxClaimSeparated) {
        blockers.add("SOURCE_ZERO_STDX_CLAIM_NOT_SEPARATED")
    }
    if (request.productionQueueMutationRequested) {
        blockers.add("PRODUCTION_QUEUE_MUTATION_REQUESTED")
    }
    if (request.actualRuntimeTaskSpawnRequested) {
        blockers.add("ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.actualHandlerInvocationRequested) {
        blockers.add("ACTUAL_HANDLER_INVOCATION_REQUESTED")
    }
    if (request.actualRequestContextMutationRequested) {
        blockers.add("ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.actualResponseWriteRequested) {
        blockers.add("ACTUAL_RESPONSE_WRITE_REQUESTED")
    }
    if (request.actualTransportCommitRequested) {
        blockers.add("ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.actualLiveServerWiringRequested) {
        blockers.add("ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    }
    if (request.actualDefaultEngineFlipRequested) {
        blockers.add("ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    }
    if (request.defaultEngineConfigMutationRequested) {
        blockers.add("DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    }
    if (request.runtimeDefaultPathMutationRequested) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    }
    if (request.publicReleaseRequested) {
        blockers.add("PUBLIC_RELEASE_REQUESTED")
    }
    if (request.stdxRemovalRequested) {
        blockers.add("STDX_REMOVAL_REQUESTED")
    }
    if (request.h1H2QuicRuntimeClosureClaimed) {
        blockers.add("H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    }
    if (
        controlledPreparationApplyMode ==
        "unknown-controlled-runtime-default-path-mutation-preparation-apply"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_GATE")
    }
    blockers.toArray()
}

func igniteControlledRuntimeDefaultPathMutationPreparationApplyNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationApplyGateNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationCommitPlanRequest {
    public let runtimeDefaultPathMutationPreparationCommitPlanId: String
    public let controlledPreparationApplyReceiptCarried: Bool
    public let preparationCommitPlanMarkerCarried: Bool
    public let controlledPreparationApplyReviewCarried: Bool
    public let commitPlanReadinessMarkerCarried: Bool
    public let rollbackCommitPlanCarried: Bool
    public let runtimeGuardCommitPlanCarried: Bool
    public let observabilityCommitPlanMarkerCarried: Bool
    public let sourceZeroStdxClaimSeparated: Bool
    public let publicClaimBoundaryCarried: Bool
    public let quicReuseBoundaryCarried: Bool
    public let productionQueueMutationRequested: Bool
    public let actualRuntimeTaskSpawnRequested: Bool
    public let actualHandlerInvocationRequested: Bool
    public let actualRequestContextMutationRequested: Bool
    public let actualResponseWriteRequested: Bool
    public let actualTransportCommitRequested: Bool
    public let actualLiveServerWiringRequested: Bool
    public let actualDefaultEngineFlipRequested: Bool
    public let defaultEngineConfigMutationRequested: Bool
    public let runtimeDefaultPathMutationRequested: Bool
    public let publicReleaseRequested: Bool
    public let stdxRemovalRequested: Bool
    public let h1H2QuicRuntimeClosureClaimed: Bool

    public init(
        runtimeDefaultPathMutationPreparationCommitPlanId: String,
        controlledPreparationApplyReceiptCarried: Bool,
        preparationCommitPlanMarkerCarried: Bool,
        controlledPreparationApplyReviewCarried: Bool,
        commitPlanReadinessMarkerCarried: Bool,
        rollbackCommitPlanCarried: Bool,
        runtimeGuardCommitPlanCarried: Bool,
        observabilityCommitPlanMarkerCarried: Bool,
        sourceZeroStdxClaimSeparated: Bool,
        publicClaimBoundaryCarried: Bool,
        quicReuseBoundaryCarried: Bool,
        productionQueueMutationRequested: Bool,
        actualRuntimeTaskSpawnRequested: Bool,
        actualHandlerInvocationRequested: Bool,
        actualRequestContextMutationRequested: Bool,
        actualResponseWriteRequested: Bool,
        actualTransportCommitRequested: Bool,
        actualLiveServerWiringRequested: Bool,
        actualDefaultEngineFlipRequested: Bool,
        defaultEngineConfigMutationRequested: Bool,
        runtimeDefaultPathMutationRequested: Bool,
        publicReleaseRequested: Bool,
        stdxRemovalRequested: Bool,
        h1H2QuicRuntimeClosureClaimed: Bool
    ) {
        this.runtimeDefaultPathMutationPreparationCommitPlanId =
            runtimeDefaultPathMutationPreparationCommitPlanId
        this.controlledPreparationApplyReceiptCarried =
            controlledPreparationApplyReceiptCarried
        this.preparationCommitPlanMarkerCarried =
            preparationCommitPlanMarkerCarried
        this.controlledPreparationApplyReviewCarried =
            controlledPreparationApplyReviewCarried
        this.commitPlanReadinessMarkerCarried =
            commitPlanReadinessMarkerCarried
        this.rollbackCommitPlanCarried = rollbackCommitPlanCarried
        this.runtimeGuardCommitPlanCarried = runtimeGuardCommitPlanCarried
        this.observabilityCommitPlanMarkerCarried =
            observabilityCommitPlanMarkerCarried
        this.sourceZeroStdxClaimSeparated = sourceZeroStdxClaimSeparated
        this.publicClaimBoundaryCarried = publicClaimBoundaryCarried
        this.quicReuseBoundaryCarried = quicReuseBoundaryCarried
        this.productionQueueMutationRequested = productionQueueMutationRequested
        this.actualRuntimeTaskSpawnRequested = actualRuntimeTaskSpawnRequested
        this.actualHandlerInvocationRequested = actualHandlerInvocationRequested
        this.actualRequestContextMutationRequested =
            actualRequestContextMutationRequested
        this.actualResponseWriteRequested = actualResponseWriteRequested
        this.actualTransportCommitRequested = actualTransportCommitRequested
        this.actualLiveServerWiringRequested = actualLiveServerWiringRequested
        this.actualDefaultEngineFlipRequested =
            actualDefaultEngineFlipRequested
        this.defaultEngineConfigMutationRequested =
            defaultEngineConfigMutationRequested
        this.runtimeDefaultPathMutationRequested =
            runtimeDefaultPathMutationRequested
        this.publicReleaseRequested = publicReleaseRequested
        this.stdxRemovalRequested = stdxRemovalRequested
        this.h1H2QuicRuntimeClosureClaimed = h1H2QuicRuntimeClosureClaimed
    }
}

public class IgniteRuntimeDefaultPathMutationPreparationCommitPlanReceipt {
    public let runtimeDefaultPathMutationPreparationCommitPlanAccepted: Bool
    public let controlledPreparationApplyAccepted: Bool
    public let controlledPreparationApplyMode: String
    public let runtimeDefaultPathMutationPreparationCommitPlanMode: String
    public let runtimeDefaultPathMutationPreparationCommitPlanId: String
    public let controlledPreparationApplyId: String
    public let preparationApplyGateId: String
    public let preparationDryRunId: String
    public let preparationBoundaryId: String
    public let preparationGateId: String
    public let closeoutBoundaryGateId: String
    public let closeoutBoundaryId: String
    public let closeoutId: String
    public let controlledPreparationApplyReceipt: IgniteControlledRuntimeDefaultPathMutationPreparationApplyReceipt
    public let runtimeDefaultPathMutationPreparationCommitPlanRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationCommitPlanAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let actualHandlerInvocationAllowed: Bool
    public let actualRequestContextMutationAllowed: Bool
    public let actualResponseWriteAllowed: Bool
    public let actualTransportCommitAllowed: Bool
    public let actualLiveServerWiringAllowed: Bool
    public let actualDefaultEngineFlipAllowed: Bool
    public let defaultEngineConfigMutationAllowed: Bool
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h1H2QuicRuntimeClosureClaimAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        runtimeDefaultPathMutationPreparationCommitPlanAccepted: Bool,
        controlledPreparationApplyAccepted: Bool,
        controlledPreparationApplyMode: String,
        runtimeDefaultPathMutationPreparationCommitPlanMode: String,
        runtimeDefaultPathMutationPreparationCommitPlanId: String,
        controlledPreparationApplyId: String,
        preparationApplyGateId: String,
        preparationDryRunId: String,
        preparationBoundaryId: String,
        preparationGateId: String,
        closeoutBoundaryGateId: String,
        closeoutBoundaryId: String,
        closeoutId: String,
        controlledPreparationApplyReceipt: IgniteControlledRuntimeDefaultPathMutationPreparationApplyReceipt,
        runtimeDefaultPathMutationPreparationCommitPlanRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationCommitPlanAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        actualHandlerInvocationAllowed: Bool,
        actualRequestContextMutationAllowed: Bool,
        actualResponseWriteAllowed: Bool,
        actualTransportCommitAllowed: Bool,
        actualLiveServerWiringAllowed: Bool,
        actualDefaultEngineFlipAllowed: Bool,
        defaultEngineConfigMutationAllowed: Bool,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h1H2QuicRuntimeClosureClaimAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.runtimeDefaultPathMutationPreparationCommitPlanAccepted =
            runtimeDefaultPathMutationPreparationCommitPlanAccepted
        this.controlledPreparationApplyAccepted =
            controlledPreparationApplyAccepted
        this.controlledPreparationApplyMode = controlledPreparationApplyMode
        this.runtimeDefaultPathMutationPreparationCommitPlanMode =
            runtimeDefaultPathMutationPreparationCommitPlanMode
        this.runtimeDefaultPathMutationPreparationCommitPlanId =
            runtimeDefaultPathMutationPreparationCommitPlanId
        this.controlledPreparationApplyId = controlledPreparationApplyId
        this.preparationApplyGateId = preparationApplyGateId
        this.preparationDryRunId = preparationDryRunId
        this.preparationBoundaryId = preparationBoundaryId
        this.preparationGateId = preparationGateId
        this.closeoutBoundaryGateId = closeoutBoundaryGateId
        this.closeoutBoundaryId = closeoutBoundaryId
        this.closeoutId = closeoutId
        this.controlledPreparationApplyReceipt =
            controlledPreparationApplyReceipt
        this.runtimeDefaultPathMutationPreparationCommitPlanRecorded =
            runtimeDefaultPathMutationPreparationCommitPlanRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationCommitPlanAllowed =
            runtimeDefaultPathMutationPreparationCommitPlanAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.actualRuntimeTaskSpawnAllowed = actualRuntimeTaskSpawnAllowed
        this.actualHandlerInvocationAllowed = actualHandlerInvocationAllowed
        this.actualRequestContextMutationAllowed =
            actualRequestContextMutationAllowed
        this.actualResponseWriteAllowed = actualResponseWriteAllowed
        this.actualTransportCommitAllowed = actualTransportCommitAllowed
        this.actualLiveServerWiringAllowed = actualLiveServerWiringAllowed
        this.actualDefaultEngineFlipAllowed = actualDefaultEngineFlipAllowed
        this.defaultEngineConfigMutationAllowed =
            defaultEngineConfigMutationAllowed
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h1H2QuicRuntimeClosureClaimAllowed =
            h1H2QuicRuntimeClosureClaimAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteRuntimeDefaultPathMutationPreparationCommitPlanReceipt(
    controlledPreparationApplyReceipt: IgniteControlledRuntimeDefaultPathMutationPreparationApplyReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationCommitPlanRequest
): IgniteRuntimeDefaultPathMutationPreparationCommitPlanReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationCommitPlanNonClaims()
    if (
        !controlledPreparationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationCommitPlanReceipt(
            false,
            controlledPreparationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyAccepted,
            controlledPreparationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyMode,
            "none",
            request.runtimeDefaultPathMutationPreparationCommitPlanId,
            controlledPreparationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyId,
            controlledPreparationApplyReceipt.preparationApplyGateId,
            controlledPreparationApplyReceipt.preparationDryRunId,
            controlledPreparationApplyReceipt.preparationBoundaryId,
            controlledPreparationApplyReceipt.preparationGateId,
            controlledPreparationApplyReceipt.closeoutBoundaryGateId,
            controlledPreparationApplyReceipt.closeoutBoundaryId,
            controlledPreparationApplyReceipt.closeoutId,
            controlledPreparationApplyReceipt,
            false,
            "block",
            "blocked-controlled-runtime-default-path-mutation-preparation-apply-receipt",
            "collect-accepted-controlled-runtime-default-path-mutation-preparation-apply-receipt-first",
            ["CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0515 controlled runtime default-path mutation preparation apply input before preparation commit-plan work",
            "QUIC must not consume preparation commit-plan receipts from rejected controlled preparation apply receipts"
        )
    }

    let preparationCommitPlanMode =
        igniteRuntimeDefaultPathMutationPreparationCommitPlanModeFor(
            controlledPreparationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationCommitPlanBlockers(
            request,
            preparationCommitPlanMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationCommitPlanReceipt(
            false,
            controlledPreparationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyAccepted,
            controlledPreparationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyMode,
            preparationCommitPlanMode,
            request.runtimeDefaultPathMutationPreparationCommitPlanId,
            controlledPreparationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyId,
            controlledPreparationApplyReceipt.preparationApplyGateId,
            controlledPreparationApplyReceipt.preparationDryRunId,
            controlledPreparationApplyReceipt.preparationBoundaryId,
            controlledPreparationApplyReceipt.preparationGateId,
            controlledPreparationApplyReceipt.closeoutBoundaryGateId,
            controlledPreparationApplyReceipt.closeoutBoundaryId,
            controlledPreparationApplyReceipt.closeoutId,
            controlledPreparationApplyReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-commit-plan-input",
            "fix-runtime-default-path-mutation-preparation-commit-plan-before-runtime-default-mutation",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry preparation commit-plan id, accepted controlled preparation apply receipt, commit-plan marker, review marker, readiness marker, rollback commit plan, runtime guard commit plan, observability marker, source-zero stdx separation, public claim boundary, and QUIC reuse boundary",
            "QUIC can reuse the same runtime default-path mutation preparation commit-plan blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationPreparationCommitPlanReceipt(
        true,
        controlledPreparationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyAccepted,
        controlledPreparationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyMode,
        preparationCommitPlanMode,
        request.runtimeDefaultPathMutationPreparationCommitPlanId,
        controlledPreparationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyId,
        controlledPreparationApplyReceipt.preparationApplyGateId,
        controlledPreparationApplyReceipt.preparationDryRunId,
        controlledPreparationApplyReceipt.preparationBoundaryId,
        controlledPreparationApplyReceipt.preparationGateId,
        controlledPreparationApplyReceipt.closeoutBoundaryGateId,
        controlledPreparationApplyReceipt.closeoutBoundaryId,
        controlledPreparationApplyReceipt.closeoutId,
        controlledPreparationApplyReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-commit-plan",
        "accepted-runtime-default-path-mutation-preparation-commit-plan-receipt",
        "record-runtime-default-path-mutation-preparation-commit-plan-without-runtime-default-mutation",
        [],
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
        nonClaims,
        "next packet may prove runtime default-path mutation preparation commit dry-run without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation commit-plan modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationCommitPlanModeFor(
    controlledPreparationApplyMode: String
): String {
    if (
        controlledPreparationApplyMode ==
        "short-controlled-runtime-default-path-mutation-preparation-apply"
    ) {
        return "short-runtime-default-path-mutation-preparation-commit-plan"
    }
    if (
        controlledPreparationApplyMode ==
        "long-controlled-runtime-default-path-mutation-preparation-apply"
    ) {
        return "long-runtime-default-path-mutation-preparation-commit-plan"
    }
    if (
        controlledPreparationApplyMode ==
        "blocking-isolation-controlled-runtime-default-path-mutation-preparation-apply"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-commit-plan"
    }
    "unknown-runtime-default-path-mutation-preparation-commit-plan"
}

func igniteRuntimeDefaultPathMutationPreparationCommitPlanBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationCommitPlanRequest,
    preparationCommitPlanMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.runtimeDefaultPathMutationPreparationCommitPlanId.size == 0) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_PLAN_ID_NOT_CARRIED")
    }
    if (!request.controlledPreparationApplyReceiptCarried) {
        blockers.add("CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_RECEIPT_NOT_CARRIED")
    }
    if (!request.preparationCommitPlanMarkerCarried) {
        blockers.add("PREPARATION_COMMIT_PLAN_MARKER_NOT_CARRIED")
    }
    if (!request.controlledPreparationApplyReviewCarried) {
        blockers.add("CONTROLLED_PREPARATION_APPLY_REVIEW_NOT_CARRIED")
    }
    if (!request.commitPlanReadinessMarkerCarried) {
        blockers.add("COMMIT_PLAN_READINESS_MARKER_NOT_CARRIED")
    }
    if (!request.rollbackCommitPlanCarried) {
        blockers.add("ROLLBACK_COMMIT_PLAN_NOT_CARRIED")
    }
    if (!request.runtimeGuardCommitPlanCarried) {
        blockers.add("RUNTIME_GUARD_COMMIT_PLAN_NOT_CARRIED")
    }
    if (!request.observabilityCommitPlanMarkerCarried) {
        blockers.add("OBSERVABILITY_COMMIT_PLAN_MARKER_NOT_CARRIED")
    }
    if (!request.sourceZeroStdxClaimSeparated) {
        blockers.add("SOURCE_ZERO_STDX_CLAIM_NOT_SEPARATED")
    }
    if (!request.publicClaimBoundaryCarried) {
        blockers.add("PUBLIC_CLAIM_BOUNDARY_NOT_CARRIED")
    }
    if (!request.quicReuseBoundaryCarried) {
        blockers.add("QUIC_REUSE_BOUNDARY_NOT_CARRIED")
    }
    if (request.productionQueueMutationRequested) {
        blockers.add("PRODUCTION_QUEUE_MUTATION_REQUESTED")
    }
    if (request.actualRuntimeTaskSpawnRequested) {
        blockers.add("ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.actualHandlerInvocationRequested) {
        blockers.add("ACTUAL_HANDLER_INVOCATION_REQUESTED")
    }
    if (request.actualRequestContextMutationRequested) {
        blockers.add("ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.actualResponseWriteRequested) {
        blockers.add("ACTUAL_RESPONSE_WRITE_REQUESTED")
    }
    if (request.actualTransportCommitRequested) {
        blockers.add("ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.actualLiveServerWiringRequested) {
        blockers.add("ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    }
    if (request.actualDefaultEngineFlipRequested) {
        blockers.add("ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    }
    if (request.defaultEngineConfigMutationRequested) {
        blockers.add("DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    }
    if (request.runtimeDefaultPathMutationRequested) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    }
    if (request.publicReleaseRequested) {
        blockers.add("PUBLIC_RELEASE_REQUESTED")
    }
    if (request.stdxRemovalRequested) {
        blockers.add("STDX_REMOVAL_REQUESTED")
    }
    if (request.h1H2QuicRuntimeClosureClaimed) {
        blockers.add("H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    }
    if (
        preparationCommitPlanMode ==
        "unknown-runtime-default-path-mutation-preparation-commit-plan"
    ) {
        blockers.add("UNKNOWN_CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationCommitPlanNonClaims(): Array<String> {
    igniteControlledRuntimeDefaultPathMutationPreparationApplyNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationCommitDryRunRequest {
    public let runtimeDefaultPathMutationPreparationCommitDryRunId: String
    public let preparationCommitPlanSnapshotCarried: Bool
    public let preparationCommitDryRunMarkerCarried: Bool
    public let targetRuntimeDefaultPathPreviewCarried: Bool
    public let isolatedPreparationPlanCarried: Bool
    public let dryRunSandboxCarried: Bool
    public let configDiffPreviewCarried: Bool
    public let rollbackSimulationCarried: Bool
    public let runtimeGuardPlanCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let sourceZeroStdxClaimSeparated: Bool
    public let quicReuseBoundaryCarried: Bool
    public let productionQueueMutationRequested: Bool
    public let actualRuntimeTaskSpawnRequested: Bool
    public let actualHandlerInvocationRequested: Bool
    public let actualRequestContextMutationRequested: Bool
    public let actualResponseWriteRequested: Bool
    public let actualTransportCommitRequested: Bool
    public let actualLiveServerWiringRequested: Bool
    public let actualDefaultEngineFlipRequested: Bool
    public let defaultEngineConfigMutationRequested: Bool
    public let runtimeDefaultPathMutationRequested: Bool
    public let publicReleaseRequested: Bool
    public let stdxRemovalRequested: Bool
    public let h1H2QuicRuntimeClosureClaimed: Bool

    public init(
        runtimeDefaultPathMutationPreparationCommitDryRunId: String,
        preparationCommitPlanSnapshotCarried: Bool,
        preparationCommitDryRunMarkerCarried: Bool,
        targetRuntimeDefaultPathPreviewCarried: Bool,
        isolatedPreparationPlanCarried: Bool,
        dryRunSandboxCarried: Bool,
        configDiffPreviewCarried: Bool,
        rollbackSimulationCarried: Bool,
        runtimeGuardPlanCarried: Bool,
        observabilityMarkerCarried: Bool,
        sourceZeroStdxClaimSeparated: Bool,
        quicReuseBoundaryCarried: Bool,
        productionQueueMutationRequested: Bool,
        actualRuntimeTaskSpawnRequested: Bool,
        actualHandlerInvocationRequested: Bool,
        actualRequestContextMutationRequested: Bool,
        actualResponseWriteRequested: Bool,
        actualTransportCommitRequested: Bool,
        actualLiveServerWiringRequested: Bool,
        actualDefaultEngineFlipRequested: Bool,
        defaultEngineConfigMutationRequested: Bool,
        runtimeDefaultPathMutationRequested: Bool,
        publicReleaseRequested: Bool,
        stdxRemovalRequested: Bool,
        h1H2QuicRuntimeClosureClaimed: Bool
    ) {
        this.runtimeDefaultPathMutationPreparationCommitDryRunId =
            runtimeDefaultPathMutationPreparationCommitDryRunId
        this.preparationCommitPlanSnapshotCarried =
            preparationCommitPlanSnapshotCarried
        this.preparationCommitDryRunMarkerCarried =
            preparationCommitDryRunMarkerCarried
        this.targetRuntimeDefaultPathPreviewCarried =
            targetRuntimeDefaultPathPreviewCarried
        this.isolatedPreparationPlanCarried =
            isolatedPreparationPlanCarried
        this.dryRunSandboxCarried = dryRunSandboxCarried
        this.configDiffPreviewCarried = configDiffPreviewCarried
        this.rollbackSimulationCarried = rollbackSimulationCarried
        this.runtimeGuardPlanCarried = runtimeGuardPlanCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
        this.sourceZeroStdxClaimSeparated = sourceZeroStdxClaimSeparated
        this.quicReuseBoundaryCarried = quicReuseBoundaryCarried
        this.productionQueueMutationRequested = productionQueueMutationRequested
        this.actualRuntimeTaskSpawnRequested = actualRuntimeTaskSpawnRequested
        this.actualHandlerInvocationRequested = actualHandlerInvocationRequested
        this.actualRequestContextMutationRequested =
            actualRequestContextMutationRequested
        this.actualResponseWriteRequested = actualResponseWriteRequested
        this.actualTransportCommitRequested = actualTransportCommitRequested
        this.actualLiveServerWiringRequested = actualLiveServerWiringRequested
        this.actualDefaultEngineFlipRequested =
            actualDefaultEngineFlipRequested
        this.defaultEngineConfigMutationRequested =
            defaultEngineConfigMutationRequested
        this.runtimeDefaultPathMutationRequested =
            runtimeDefaultPathMutationRequested
        this.publicReleaseRequested = publicReleaseRequested
        this.stdxRemovalRequested = stdxRemovalRequested
        this.h1H2QuicRuntimeClosureClaimed = h1H2QuicRuntimeClosureClaimed
    }
}

public class IgniteRuntimeDefaultPathMutationPreparationCommitDryRunReceipt {
    public let runtimeDefaultPathMutationPreparationCommitDryRunAccepted: Bool
    public let runtimeDefaultPathMutationPreparationCommitPlanAccepted: Bool
    public let runtimeDefaultPathMutationPreparationCommitPlanMode: String
    public let runtimeDefaultPathMutationPreparationCommitDryRunMode: String
    public let runtimeDefaultPathMutationPreparationCommitDryRunId: String
    public let runtimeDefaultPathMutationPreparationCommitPlanId: String
    public let controlledPreparationApplyId: String
    public let preparationApplyGateId: String
    public let preparationDryRunId: String
    public let preparationBoundaryId: String
    public let preparationGateId: String
    public let closeoutBoundaryGateId: String
    public let closeoutBoundaryId: String
    public let closeoutId: String
    public let preparationCommitPlanReceipt: IgniteRuntimeDefaultPathMutationPreparationCommitPlanReceipt
    public let runtimeDefaultPathMutationPreparationCommitDryRunRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationCommitDryRunAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let actualHandlerInvocationAllowed: Bool
    public let actualRequestContextMutationAllowed: Bool
    public let actualResponseWriteAllowed: Bool
    public let actualTransportCommitAllowed: Bool
    public let actualLiveServerWiringAllowed: Bool
    public let actualDefaultEngineFlipAllowed: Bool
    public let defaultEngineConfigMutationAllowed: Bool
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h1H2QuicRuntimeClosureClaimAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        runtimeDefaultPathMutationPreparationCommitDryRunAccepted: Bool,
        runtimeDefaultPathMutationPreparationCommitPlanAccepted: Bool,
        runtimeDefaultPathMutationPreparationCommitPlanMode: String,
        runtimeDefaultPathMutationPreparationCommitDryRunMode: String,
        runtimeDefaultPathMutationPreparationCommitDryRunId: String,
        runtimeDefaultPathMutationPreparationCommitPlanId: String,
        controlledPreparationApplyId: String,
        preparationApplyGateId: String,
        preparationDryRunId: String,
        preparationBoundaryId: String,
        preparationGateId: String,
        closeoutBoundaryGateId: String,
        closeoutBoundaryId: String,
        closeoutId: String,
        preparationCommitPlanReceipt: IgniteRuntimeDefaultPathMutationPreparationCommitPlanReceipt,
        runtimeDefaultPathMutationPreparationCommitDryRunRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationCommitDryRunAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        actualHandlerInvocationAllowed: Bool,
        actualRequestContextMutationAllowed: Bool,
        actualResponseWriteAllowed: Bool,
        actualTransportCommitAllowed: Bool,
        actualLiveServerWiringAllowed: Bool,
        actualDefaultEngineFlipAllowed: Bool,
        defaultEngineConfigMutationAllowed: Bool,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h1H2QuicRuntimeClosureClaimAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.runtimeDefaultPathMutationPreparationCommitDryRunAccepted =
            runtimeDefaultPathMutationPreparationCommitDryRunAccepted
        this.runtimeDefaultPathMutationPreparationCommitPlanAccepted =
            runtimeDefaultPathMutationPreparationCommitPlanAccepted
        this.runtimeDefaultPathMutationPreparationCommitPlanMode =
            runtimeDefaultPathMutationPreparationCommitPlanMode
        this.runtimeDefaultPathMutationPreparationCommitDryRunMode =
            runtimeDefaultPathMutationPreparationCommitDryRunMode
        this.runtimeDefaultPathMutationPreparationCommitDryRunId =
            runtimeDefaultPathMutationPreparationCommitDryRunId
        this.runtimeDefaultPathMutationPreparationCommitPlanId =
            runtimeDefaultPathMutationPreparationCommitPlanId
        this.controlledPreparationApplyId = controlledPreparationApplyId
        this.preparationApplyGateId = preparationApplyGateId
        this.preparationDryRunId = preparationDryRunId
        this.preparationBoundaryId = preparationBoundaryId
        this.preparationGateId = preparationGateId
        this.closeoutBoundaryGateId = closeoutBoundaryGateId
        this.closeoutBoundaryId = closeoutBoundaryId
        this.closeoutId = closeoutId
        this.preparationCommitPlanReceipt = preparationCommitPlanReceipt
        this.runtimeDefaultPathMutationPreparationCommitDryRunRecorded =
            runtimeDefaultPathMutationPreparationCommitDryRunRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationCommitDryRunAllowed =
            runtimeDefaultPathMutationPreparationCommitDryRunAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.actualRuntimeTaskSpawnAllowed = actualRuntimeTaskSpawnAllowed
        this.actualHandlerInvocationAllowed = actualHandlerInvocationAllowed
        this.actualRequestContextMutationAllowed =
            actualRequestContextMutationAllowed
        this.actualResponseWriteAllowed = actualResponseWriteAllowed
        this.actualTransportCommitAllowed = actualTransportCommitAllowed
        this.actualLiveServerWiringAllowed = actualLiveServerWiringAllowed
        this.actualDefaultEngineFlipAllowed = actualDefaultEngineFlipAllowed
        this.defaultEngineConfigMutationAllowed =
            defaultEngineConfigMutationAllowed
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h1H2QuicRuntimeClosureClaimAllowed =
            h1H2QuicRuntimeClosureClaimAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteRuntimeDefaultPathMutationPreparationCommitDryRunReceipt(
    preparationCommitPlanReceipt: IgniteRuntimeDefaultPathMutationPreparationCommitPlanReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationCommitDryRunRequest
): IgniteRuntimeDefaultPathMutationPreparationCommitDryRunReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationCommitDryRunNonClaims()
    if (
        !preparationCommitPlanReceipt.runtimeDefaultPathMutationPreparationCommitPlanAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationCommitDryRunReceipt(
            false,
            preparationCommitPlanReceipt.runtimeDefaultPathMutationPreparationCommitPlanAccepted,
            preparationCommitPlanReceipt.runtimeDefaultPathMutationPreparationCommitPlanMode,
            "none",
            request.runtimeDefaultPathMutationPreparationCommitDryRunId,
            preparationCommitPlanReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
            preparationCommitPlanReceipt.controlledPreparationApplyId,
            preparationCommitPlanReceipt.preparationApplyGateId,
            preparationCommitPlanReceipt.preparationDryRunId,
            preparationCommitPlanReceipt.preparationBoundaryId,
            preparationCommitPlanReceipt.preparationGateId,
            preparationCommitPlanReceipt.closeoutBoundaryGateId,
            preparationCommitPlanReceipt.closeoutBoundaryId,
            preparationCommitPlanReceipt.closeoutId,
            preparationCommitPlanReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-commit-plan-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-commit-plan-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_PLAN_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0516 runtime default-path mutation preparation commit-plan input before preparation commit dry-run work",
            "QUIC must not consume runtime default-path mutation preparation commit dry-run receipts from rejected preparation commit-plan receipts"
        )
    }

    let preparationCommitDryRunMode =
        igniteRuntimeDefaultPathMutationPreparationCommitDryRunModeFor(
            preparationCommitPlanReceipt.runtimeDefaultPathMutationPreparationCommitPlanMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationCommitDryRunBlockers(
            request,
            preparationCommitDryRunMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationCommitDryRunReceipt(
            false,
            preparationCommitPlanReceipt.runtimeDefaultPathMutationPreparationCommitPlanAccepted,
            preparationCommitPlanReceipt.runtimeDefaultPathMutationPreparationCommitPlanMode,
            preparationCommitDryRunMode,
            request.runtimeDefaultPathMutationPreparationCommitDryRunId,
            preparationCommitPlanReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
            preparationCommitPlanReceipt.controlledPreparationApplyId,
            preparationCommitPlanReceipt.preparationApplyGateId,
            preparationCommitPlanReceipt.preparationDryRunId,
            preparationCommitPlanReceipt.preparationBoundaryId,
            preparationCommitPlanReceipt.preparationGateId,
            preparationCommitPlanReceipt.closeoutBoundaryGateId,
            preparationCommitPlanReceipt.closeoutBoundaryId,
            preparationCommitPlanReceipt.closeoutId,
            preparationCommitPlanReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-commit-dry-run-input",
            "fix-runtime-default-path-mutation-preparation-commit-dry-run-before-runtime-default-mutation",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry preparation commit dry-run id, preparation commit-plan snapshot, dry-run marker, target runtime default-path preview, isolated preparation plan, dry-run sandbox, config diff preview, rollback simulation, runtime guard plan, observability marker, source-zero stdx separation, and QUIC reuse boundary",
            "QUIC can reuse the same runtime default-path mutation preparation commit dry-run blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationPreparationCommitDryRunReceipt(
        true,
        preparationCommitPlanReceipt.runtimeDefaultPathMutationPreparationCommitPlanAccepted,
        preparationCommitPlanReceipt.runtimeDefaultPathMutationPreparationCommitPlanMode,
        preparationCommitDryRunMode,
        request.runtimeDefaultPathMutationPreparationCommitDryRunId,
        preparationCommitPlanReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
        preparationCommitPlanReceipt.controlledPreparationApplyId,
        preparationCommitPlanReceipt.preparationApplyGateId,
        preparationCommitPlanReceipt.preparationDryRunId,
        preparationCommitPlanReceipt.preparationBoundaryId,
        preparationCommitPlanReceipt.preparationGateId,
        preparationCommitPlanReceipt.closeoutBoundaryGateId,
        preparationCommitPlanReceipt.closeoutBoundaryId,
        preparationCommitPlanReceipt.closeoutId,
        preparationCommitPlanReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-commit-dry-run",
        "accepted-runtime-default-path-mutation-preparation-commit-dry-run-receipt",
        "record-runtime-default-path-mutation-preparation-commit-dry-run-without-runtime-default-mutation",
        [],
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
        nonClaims,
        "next packet may prove runtime default-path mutation preparation commit apply-gate without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation commit dry-run modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationCommitDryRunModeFor(
    preparationCommitPlanMode: String
): String {
    if (
        preparationCommitPlanMode ==
        "short-runtime-default-path-mutation-preparation-commit-plan"
    ) {
        return "short-runtime-default-path-mutation-preparation-commit-dry-run"
    }
    if (
        preparationCommitPlanMode ==
        "long-runtime-default-path-mutation-preparation-commit-plan"
    ) {
        return "long-runtime-default-path-mutation-preparation-commit-dry-run"
    }
    if (
        preparationCommitPlanMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-commit-plan"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-commit-dry-run"
    }
    "unknown-runtime-default-path-mutation-preparation-commit-dry-run"
}

func igniteRuntimeDefaultPathMutationPreparationCommitDryRunBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationCommitDryRunRequest,
    preparationCommitDryRunMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.runtimeDefaultPathMutationPreparationCommitDryRunId.size == 0) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_DRY_RUN_ID_NOT_CARRIED")
    }
    if (!request.preparationCommitPlanSnapshotCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_PLAN_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.preparationCommitDryRunMarkerCarried) {
        blockers.add("PREPARATION_COMMIT_DRY_RUN_MARKER_NOT_CARRIED")
    }
    if (!request.targetRuntimeDefaultPathPreviewCarried) {
        blockers.add("TARGET_RUNTIME_DEFAULT_PATH_PREVIEW_NOT_CARRIED")
    }
    if (!request.isolatedPreparationPlanCarried) {
        blockers.add("ISOLATED_PREPARATION_PLAN_NOT_CARRIED")
    }
    if (!request.dryRunSandboxCarried) {
        blockers.add("DRY_RUN_SANDBOX_NOT_CARRIED")
    }
    if (!request.configDiffPreviewCarried) {
        blockers.add("CONFIG_DIFF_PREVIEW_NOT_CARRIED")
    }
    if (!request.rollbackSimulationCarried) {
        blockers.add("ROLLBACK_SIMULATION_NOT_CARRIED")
    }
    if (!request.runtimeGuardPlanCarried) {
        blockers.add("RUNTIME_GUARD_PLAN_NOT_CARRIED")
    }
    if (!request.observabilityMarkerCarried) {
        blockers.add("OBSERVABILITY_MARKER_NOT_CARRIED")
    }
    if (!request.sourceZeroStdxClaimSeparated) {
        blockers.add("SOURCE_ZERO_STDX_CLAIM_NOT_SEPARATED")
    }
    if (!request.quicReuseBoundaryCarried) {
        blockers.add("QUIC_REUSE_BOUNDARY_NOT_CARRIED")
    }
    if (request.productionQueueMutationRequested) {
        blockers.add("PRODUCTION_QUEUE_MUTATION_REQUESTED")
    }
    if (request.actualRuntimeTaskSpawnRequested) {
        blockers.add("ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.actualHandlerInvocationRequested) {
        blockers.add("ACTUAL_HANDLER_INVOCATION_REQUESTED")
    }
    if (request.actualRequestContextMutationRequested) {
        blockers.add("ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.actualResponseWriteRequested) {
        blockers.add("ACTUAL_RESPONSE_WRITE_REQUESTED")
    }
    if (request.actualTransportCommitRequested) {
        blockers.add("ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.actualLiveServerWiringRequested) {
        blockers.add("ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    }
    if (request.actualDefaultEngineFlipRequested) {
        blockers.add("ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    }
    if (request.defaultEngineConfigMutationRequested) {
        blockers.add("DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    }
    if (request.runtimeDefaultPathMutationRequested) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    }
    if (request.publicReleaseRequested) {
        blockers.add("PUBLIC_RELEASE_REQUESTED")
    }
    if (request.stdxRemovalRequested) {
        blockers.add("STDX_REMOVAL_REQUESTED")
    }
    if (request.h1H2QuicRuntimeClosureClaimed) {
        blockers.add("H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    }
    if (
        preparationCommitDryRunMode ==
        "unknown-runtime-default-path-mutation-preparation-commit-dry-run"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_PLAN")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationCommitDryRunNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationCommitPlanNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationCommitApplyGateRequest {
    public let runtimeDefaultPathMutationPreparationCommitApplyGateId: String
    public let preparationCommitDryRunSnapshotCarried: Bool
    public let targetRuntimeDefaultPathPreviewCarried: Bool
    public let applyPreconditionGateCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let rollbackOrderCarried: Bool
    public let runtimeGuardPlanCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let sourceZeroStdxClaimSeparated: Bool
    public let quicReuseBoundaryCarried: Bool
    public let productionQueueMutationRequested: Bool
    public let actualRuntimeTaskSpawnRequested: Bool
    public let actualHandlerInvocationRequested: Bool
    public let actualRequestContextMutationRequested: Bool
    public let actualResponseWriteRequested: Bool
    public let actualTransportCommitRequested: Bool
    public let actualLiveServerWiringRequested: Bool
    public let actualDefaultEngineFlipRequested: Bool
    public let defaultEngineConfigMutationRequested: Bool
    public let runtimeDefaultPathMutationRequested: Bool
    public let publicReleaseRequested: Bool
    public let stdxRemovalRequested: Bool
    public let h1H2QuicRuntimeClosureClaimed: Bool

    public init(
        runtimeDefaultPathMutationPreparationCommitApplyGateId: String,
        preparationCommitDryRunSnapshotCarried: Bool,
        targetRuntimeDefaultPathPreviewCarried: Bool,
        applyPreconditionGateCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        rollbackOrderCarried: Bool,
        runtimeGuardPlanCarried: Bool,
        observabilityMarkerCarried: Bool,
        sourceZeroStdxClaimSeparated: Bool,
        quicReuseBoundaryCarried: Bool,
        productionQueueMutationRequested: Bool,
        actualRuntimeTaskSpawnRequested: Bool,
        actualHandlerInvocationRequested: Bool,
        actualRequestContextMutationRequested: Bool,
        actualResponseWriteRequested: Bool,
        actualTransportCommitRequested: Bool,
        actualLiveServerWiringRequested: Bool,
        actualDefaultEngineFlipRequested: Bool,
        defaultEngineConfigMutationRequested: Bool,
        runtimeDefaultPathMutationRequested: Bool,
        publicReleaseRequested: Bool,
        stdxRemovalRequested: Bool,
        h1H2QuicRuntimeClosureClaimed: Bool
    ) {
        this.runtimeDefaultPathMutationPreparationCommitApplyGateId =
            runtimeDefaultPathMutationPreparationCommitApplyGateId
        this.preparationCommitDryRunSnapshotCarried =
            preparationCommitDryRunSnapshotCarried
        this.targetRuntimeDefaultPathPreviewCarried =
            targetRuntimeDefaultPathPreviewCarried
        this.applyPreconditionGateCarried = applyPreconditionGateCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.rollbackOrderCarried = rollbackOrderCarried
        this.runtimeGuardPlanCarried = runtimeGuardPlanCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
        this.sourceZeroStdxClaimSeparated = sourceZeroStdxClaimSeparated
        this.quicReuseBoundaryCarried = quicReuseBoundaryCarried
        this.productionQueueMutationRequested = productionQueueMutationRequested
        this.actualRuntimeTaskSpawnRequested = actualRuntimeTaskSpawnRequested
        this.actualHandlerInvocationRequested = actualHandlerInvocationRequested
        this.actualRequestContextMutationRequested =
            actualRequestContextMutationRequested
        this.actualResponseWriteRequested = actualResponseWriteRequested
        this.actualTransportCommitRequested = actualTransportCommitRequested
        this.actualLiveServerWiringRequested = actualLiveServerWiringRequested
        this.actualDefaultEngineFlipRequested =
            actualDefaultEngineFlipRequested
        this.defaultEngineConfigMutationRequested =
            defaultEngineConfigMutationRequested
        this.runtimeDefaultPathMutationRequested =
            runtimeDefaultPathMutationRequested
        this.publicReleaseRequested = publicReleaseRequested
        this.stdxRemovalRequested = stdxRemovalRequested
        this.h1H2QuicRuntimeClosureClaimed = h1H2QuicRuntimeClosureClaimed
    }
}

public class IgniteRuntimeDefaultPathMutationPreparationCommitApplyGateReceipt {
    public let runtimeDefaultPathMutationPreparationCommitApplyGateAccepted: Bool
    public let runtimeDefaultPathMutationPreparationCommitDryRunAccepted: Bool
    public let runtimeDefaultPathMutationPreparationCommitDryRunMode: String
    public let runtimeDefaultPathMutationPreparationCommitApplyGateMode: String
    public let runtimeDefaultPathMutationPreparationCommitApplyGateId: String
    public let runtimeDefaultPathMutationPreparationCommitDryRunId: String
    public let runtimeDefaultPathMutationPreparationCommitPlanId: String
    public let controlledPreparationApplyId: String
    public let preparationApplyGateId: String
    public let preparationDryRunId: String
    public let preparationBoundaryId: String
    public let preparationGateId: String
    public let closeoutBoundaryGateId: String
    public let closeoutBoundaryId: String
    public let closeoutId: String
    public let preparationCommitDryRunReceipt: IgniteRuntimeDefaultPathMutationPreparationCommitDryRunReceipt
    public let runtimeDefaultPathMutationPreparationCommitApplyGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationCommitApplyGateAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let actualHandlerInvocationAllowed: Bool
    public let actualRequestContextMutationAllowed: Bool
    public let actualResponseWriteAllowed: Bool
    public let actualTransportCommitAllowed: Bool
    public let actualLiveServerWiringAllowed: Bool
    public let actualDefaultEngineFlipAllowed: Bool
    public let defaultEngineConfigMutationAllowed: Bool
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h1H2QuicRuntimeClosureClaimAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        runtimeDefaultPathMutationPreparationCommitApplyGateAccepted: Bool,
        runtimeDefaultPathMutationPreparationCommitDryRunAccepted: Bool,
        runtimeDefaultPathMutationPreparationCommitDryRunMode: String,
        runtimeDefaultPathMutationPreparationCommitApplyGateMode: String,
        runtimeDefaultPathMutationPreparationCommitApplyGateId: String,
        runtimeDefaultPathMutationPreparationCommitDryRunId: String,
        runtimeDefaultPathMutationPreparationCommitPlanId: String,
        controlledPreparationApplyId: String,
        preparationApplyGateId: String,
        preparationDryRunId: String,
        preparationBoundaryId: String,
        preparationGateId: String,
        closeoutBoundaryGateId: String,
        closeoutBoundaryId: String,
        closeoutId: String,
        preparationCommitDryRunReceipt: IgniteRuntimeDefaultPathMutationPreparationCommitDryRunReceipt,
        runtimeDefaultPathMutationPreparationCommitApplyGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationCommitApplyGateAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        actualHandlerInvocationAllowed: Bool,
        actualRequestContextMutationAllowed: Bool,
        actualResponseWriteAllowed: Bool,
        actualTransportCommitAllowed: Bool,
        actualLiveServerWiringAllowed: Bool,
        actualDefaultEngineFlipAllowed: Bool,
        defaultEngineConfigMutationAllowed: Bool,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h1H2QuicRuntimeClosureClaimAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.runtimeDefaultPathMutationPreparationCommitApplyGateAccepted =
            runtimeDefaultPathMutationPreparationCommitApplyGateAccepted
        this.runtimeDefaultPathMutationPreparationCommitDryRunAccepted =
            runtimeDefaultPathMutationPreparationCommitDryRunAccepted
        this.runtimeDefaultPathMutationPreparationCommitDryRunMode =
            runtimeDefaultPathMutationPreparationCommitDryRunMode
        this.runtimeDefaultPathMutationPreparationCommitApplyGateMode =
            runtimeDefaultPathMutationPreparationCommitApplyGateMode
        this.runtimeDefaultPathMutationPreparationCommitApplyGateId =
            runtimeDefaultPathMutationPreparationCommitApplyGateId
        this.runtimeDefaultPathMutationPreparationCommitDryRunId =
            runtimeDefaultPathMutationPreparationCommitDryRunId
        this.runtimeDefaultPathMutationPreparationCommitPlanId =
            runtimeDefaultPathMutationPreparationCommitPlanId
        this.controlledPreparationApplyId = controlledPreparationApplyId
        this.preparationApplyGateId = preparationApplyGateId
        this.preparationDryRunId = preparationDryRunId
        this.preparationBoundaryId = preparationBoundaryId
        this.preparationGateId = preparationGateId
        this.closeoutBoundaryGateId = closeoutBoundaryGateId
        this.closeoutBoundaryId = closeoutBoundaryId
        this.closeoutId = closeoutId
        this.preparationCommitDryRunReceipt = preparationCommitDryRunReceipt
        this.runtimeDefaultPathMutationPreparationCommitApplyGateRecorded =
            runtimeDefaultPathMutationPreparationCommitApplyGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationCommitApplyGateAllowed =
            runtimeDefaultPathMutationPreparationCommitApplyGateAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.actualRuntimeTaskSpawnAllowed = actualRuntimeTaskSpawnAllowed
        this.actualHandlerInvocationAllowed = actualHandlerInvocationAllowed
        this.actualRequestContextMutationAllowed =
            actualRequestContextMutationAllowed
        this.actualResponseWriteAllowed = actualResponseWriteAllowed
        this.actualTransportCommitAllowed = actualTransportCommitAllowed
        this.actualLiveServerWiringAllowed = actualLiveServerWiringAllowed
        this.actualDefaultEngineFlipAllowed = actualDefaultEngineFlipAllowed
        this.defaultEngineConfigMutationAllowed =
            defaultEngineConfigMutationAllowed
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h1H2QuicRuntimeClosureClaimAllowed =
            h1H2QuicRuntimeClosureClaimAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteRuntimeDefaultPathMutationPreparationCommitApplyGateReceipt(
    preparationCommitDryRunReceipt: IgniteRuntimeDefaultPathMutationPreparationCommitDryRunReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationCommitApplyGateRequest
): IgniteRuntimeDefaultPathMutationPreparationCommitApplyGateReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationCommitApplyGateNonClaims()
    if (
        !preparationCommitDryRunReceipt.runtimeDefaultPathMutationPreparationCommitDryRunAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationCommitApplyGateReceipt(
            false,
            preparationCommitDryRunReceipt.runtimeDefaultPathMutationPreparationCommitDryRunAccepted,
            preparationCommitDryRunReceipt.runtimeDefaultPathMutationPreparationCommitDryRunMode,
            "none",
            request.runtimeDefaultPathMutationPreparationCommitApplyGateId,
            preparationCommitDryRunReceipt.runtimeDefaultPathMutationPreparationCommitDryRunId,
            preparationCommitDryRunReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
            preparationCommitDryRunReceipt.controlledPreparationApplyId,
            preparationCommitDryRunReceipt.preparationApplyGateId,
            preparationCommitDryRunReceipt.preparationDryRunId,
            preparationCommitDryRunReceipt.preparationBoundaryId,
            preparationCommitDryRunReceipt.preparationGateId,
            preparationCommitDryRunReceipt.closeoutBoundaryGateId,
            preparationCommitDryRunReceipt.closeoutBoundaryId,
            preparationCommitDryRunReceipt.closeoutId,
            preparationCommitDryRunReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-commit-dry-run-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-commit-dry-run-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_DRY_RUN_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0517 runtime default-path mutation preparation commit-dry-run input before preparation commit apply-gate work",
            "QUIC must not consume runtime default-path mutation preparation commit apply-gate receipts from rejected preparation commit-dry-run receipts"
        )
    }

    let preparationCommitApplyGateMode =
        igniteRuntimeDefaultPathMutationPreparationCommitApplyGateModeFor(
            preparationCommitDryRunReceipt.runtimeDefaultPathMutationPreparationCommitDryRunMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationCommitApplyGateBlockers(
            request,
            preparationCommitApplyGateMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationCommitApplyGateReceipt(
            false,
            preparationCommitDryRunReceipt.runtimeDefaultPathMutationPreparationCommitDryRunAccepted,
            preparationCommitDryRunReceipt.runtimeDefaultPathMutationPreparationCommitDryRunMode,
            preparationCommitApplyGateMode,
            request.runtimeDefaultPathMutationPreparationCommitApplyGateId,
            preparationCommitDryRunReceipt.runtimeDefaultPathMutationPreparationCommitDryRunId,
            preparationCommitDryRunReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
            preparationCommitDryRunReceipt.controlledPreparationApplyId,
            preparationCommitDryRunReceipt.preparationApplyGateId,
            preparationCommitDryRunReceipt.preparationDryRunId,
            preparationCommitDryRunReceipt.preparationBoundaryId,
            preparationCommitDryRunReceipt.preparationGateId,
            preparationCommitDryRunReceipt.closeoutBoundaryGateId,
            preparationCommitDryRunReceipt.closeoutBoundaryId,
            preparationCommitDryRunReceipt.closeoutId,
            preparationCommitDryRunReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-commit-apply-gate-input",
            "fix-runtime-default-path-mutation-preparation-commit-apply-gate-before-runtime-default-mutation",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry preparation commit apply-gate id, dry-run snapshot, target runtime default-path preview, apply precondition gate, runtime default-path mutation lock, rollback order, runtime guard plan, observability marker, source-zero stdx separation, and QUIC reuse boundary",
            "QUIC can reuse the same runtime default-path mutation preparation commit apply-gate blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationPreparationCommitApplyGateReceipt(
        true,
        preparationCommitDryRunReceipt.runtimeDefaultPathMutationPreparationCommitDryRunAccepted,
        preparationCommitDryRunReceipt.runtimeDefaultPathMutationPreparationCommitDryRunMode,
        preparationCommitApplyGateMode,
        request.runtimeDefaultPathMutationPreparationCommitApplyGateId,
        preparationCommitDryRunReceipt.runtimeDefaultPathMutationPreparationCommitDryRunId,
        preparationCommitDryRunReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
        preparationCommitDryRunReceipt.controlledPreparationApplyId,
        preparationCommitDryRunReceipt.preparationApplyGateId,
        preparationCommitDryRunReceipt.preparationDryRunId,
        preparationCommitDryRunReceipt.preparationBoundaryId,
        preparationCommitDryRunReceipt.preparationGateId,
        preparationCommitDryRunReceipt.closeoutBoundaryGateId,
        preparationCommitDryRunReceipt.closeoutBoundaryId,
        preparationCommitDryRunReceipt.closeoutId,
        preparationCommitDryRunReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-commit-apply-gate",
        "accepted-runtime-default-path-mutation-preparation-commit-apply-gate-receipt",
        "record-runtime-default-path-mutation-preparation-commit-apply-gate-without-runtime-default-mutation",
        [],
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
        nonClaims,
        "next packet may prove controlled runtime default-path mutation preparation commit apply without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation commit apply-gate modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationCommitApplyGateModeFor(
    preparationCommitDryRunMode: String
): String {
    if (
        preparationCommitDryRunMode ==
        "short-runtime-default-path-mutation-preparation-commit-dry-run"
    ) {
        return "short-runtime-default-path-mutation-preparation-commit-apply-gate"
    }
    if (
        preparationCommitDryRunMode ==
        "long-runtime-default-path-mutation-preparation-commit-dry-run"
    ) {
        return "long-runtime-default-path-mutation-preparation-commit-apply-gate"
    }
    if (
        preparationCommitDryRunMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-commit-dry-run"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-commit-apply-gate"
    }
    "unknown-runtime-default-path-mutation-preparation-commit-apply-gate"
}

func igniteRuntimeDefaultPathMutationPreparationCommitApplyGateBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationCommitApplyGateRequest,
    preparationCommitApplyGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.runtimeDefaultPathMutationPreparationCommitApplyGateId.size == 0) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_APPLY_GATE_ID_NOT_CARRIED")
    }
    if (!request.preparationCommitDryRunSnapshotCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_DRY_RUN_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.targetRuntimeDefaultPathPreviewCarried) {
        blockers.add("TARGET_RUNTIME_DEFAULT_PATH_PREVIEW_NOT_CARRIED")
    }
    if (!request.applyPreconditionGateCarried) {
        blockers.add("APPLY_PRECONDITION_GATE_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.rollbackOrderCarried) {
        blockers.add("ROLLBACK_ORDER_NOT_CARRIED")
    }
    if (!request.runtimeGuardPlanCarried) {
        blockers.add("RUNTIME_GUARD_PLAN_NOT_CARRIED")
    }
    if (!request.observabilityMarkerCarried) {
        blockers.add("OBSERVABILITY_MARKER_NOT_CARRIED")
    }
    if (!request.sourceZeroStdxClaimSeparated) {
        blockers.add("SOURCE_ZERO_STDX_CLAIM_NOT_SEPARATED")
    }
    if (!request.quicReuseBoundaryCarried) {
        blockers.add("QUIC_REUSE_BOUNDARY_NOT_CARRIED")
    }
    if (request.productionQueueMutationRequested) {
        blockers.add("PRODUCTION_QUEUE_MUTATION_REQUESTED")
    }
    if (request.actualRuntimeTaskSpawnRequested) {
        blockers.add("ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.actualHandlerInvocationRequested) {
        blockers.add("ACTUAL_HANDLER_INVOCATION_REQUESTED")
    }
    if (request.actualRequestContextMutationRequested) {
        blockers.add("ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.actualResponseWriteRequested) {
        blockers.add("ACTUAL_RESPONSE_WRITE_REQUESTED")
    }
    if (request.actualTransportCommitRequested) {
        blockers.add("ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.actualLiveServerWiringRequested) {
        blockers.add("ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    }
    if (request.actualDefaultEngineFlipRequested) {
        blockers.add("ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    }
    if (request.defaultEngineConfigMutationRequested) {
        blockers.add("DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    }
    if (request.runtimeDefaultPathMutationRequested) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    }
    if (request.publicReleaseRequested) {
        blockers.add("PUBLIC_RELEASE_REQUESTED")
    }
    if (request.stdxRemovalRequested) {
        blockers.add("STDX_REMOVAL_REQUESTED")
    }
    if (request.h1H2QuicRuntimeClosureClaimed) {
        blockers.add("H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    }
    if (
        preparationCommitApplyGateMode ==
        "unknown-runtime-default-path-mutation-preparation-commit-apply-gate"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_DRY_RUN")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationCommitApplyGateNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationCommitDryRunNonClaims()
}

public class IgniteControlledRuntimeDefaultPathMutationPreparationCommitApplyRequest {
    public let controlledRuntimeDefaultPathMutationPreparationCommitApplyId: String
    public let preparationCommitApplyGateSnapshotCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let preparationCommitApplyBoundaryCarried: Bool
    public let rollbackOrderCarried: Bool
    public let runtimeGuardPlanCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let productionQueueMutationRequested: Bool
    public let actualRuntimeTaskSpawnRequested: Bool
    public let actualHandlerInvocationRequested: Bool
    public let actualRequestContextMutationRequested: Bool
    public let actualResponseWriteRequested: Bool
    public let actualTransportCommitRequested: Bool
    public let actualLiveServerWiringRequested: Bool
    public let actualDefaultEngineFlipRequested: Bool
    public let defaultEngineConfigMutationRequested: Bool
    public let runtimeDefaultPathMutationRequested: Bool
    public let publicReleaseRequested: Bool
    public let stdxRemovalRequested: Bool
    public let h1H2QuicRuntimeClosureClaimed: Bool

    public init(
        controlledRuntimeDefaultPathMutationPreparationCommitApplyId: String,
        preparationCommitApplyGateSnapshotCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        preparationCommitApplyBoundaryCarried: Bool,
        rollbackOrderCarried: Bool,
        runtimeGuardPlanCarried: Bool,
        observabilityMarkerCarried: Bool,
        productionQueueMutationRequested: Bool,
        actualRuntimeTaskSpawnRequested: Bool,
        actualHandlerInvocationRequested: Bool,
        actualRequestContextMutationRequested: Bool,
        actualResponseWriteRequested: Bool,
        actualTransportCommitRequested: Bool,
        actualLiveServerWiringRequested: Bool,
        actualDefaultEngineFlipRequested: Bool,
        defaultEngineConfigMutationRequested: Bool,
        runtimeDefaultPathMutationRequested: Bool,
        publicReleaseRequested: Bool,
        stdxRemovalRequested: Bool,
        h1H2QuicRuntimeClosureClaimed: Bool
    ) {
        this.controlledRuntimeDefaultPathMutationPreparationCommitApplyId =
            controlledRuntimeDefaultPathMutationPreparationCommitApplyId
        this.preparationCommitApplyGateSnapshotCarried =
            preparationCommitApplyGateSnapshotCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.preparationCommitApplyBoundaryCarried =
            preparationCommitApplyBoundaryCarried
        this.rollbackOrderCarried = rollbackOrderCarried
        this.runtimeGuardPlanCarried = runtimeGuardPlanCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
        this.productionQueueMutationRequested = productionQueueMutationRequested
        this.actualRuntimeTaskSpawnRequested = actualRuntimeTaskSpawnRequested
        this.actualHandlerInvocationRequested = actualHandlerInvocationRequested
        this.actualRequestContextMutationRequested =
            actualRequestContextMutationRequested
        this.actualResponseWriteRequested = actualResponseWriteRequested
        this.actualTransportCommitRequested = actualTransportCommitRequested
        this.actualLiveServerWiringRequested = actualLiveServerWiringRequested
        this.actualDefaultEngineFlipRequested =
            actualDefaultEngineFlipRequested
        this.defaultEngineConfigMutationRequested =
            defaultEngineConfigMutationRequested
        this.runtimeDefaultPathMutationRequested =
            runtimeDefaultPathMutationRequested
        this.publicReleaseRequested = publicReleaseRequested
        this.stdxRemovalRequested = stdxRemovalRequested
        this.h1H2QuicRuntimeClosureClaimed = h1H2QuicRuntimeClosureClaimed
    }
}

public class IgniteControlledRuntimeDefaultPathMutationPreparationCommitApplyReceipt {
    public let controlledRuntimeDefaultPathMutationPreparationCommitApplyAccepted: Bool
    public let runtimeDefaultPathMutationPreparationCommitApplyGateAccepted: Bool
    public let runtimeDefaultPathMutationPreparationCommitApplyGateMode: String
    public let controlledRuntimeDefaultPathMutationPreparationCommitApplyMode: String
    public let controlledRuntimeDefaultPathMutationPreparationCommitApplyId: String
    public let runtimeDefaultPathMutationPreparationCommitApplyGateId: String
    public let runtimeDefaultPathMutationPreparationCommitDryRunId: String
    public let runtimeDefaultPathMutationPreparationCommitPlanId: String
    public let controlledPreparationApplyId: String
    public let preparationApplyGateId: String
    public let preparationDryRunId: String
    public let preparationBoundaryId: String
    public let preparationGateId: String
    public let closeoutBoundaryGateId: String
    public let closeoutBoundaryId: String
    public let closeoutId: String
    public let preparationCommitApplyGateReceipt: IgniteRuntimeDefaultPathMutationPreparationCommitApplyGateReceipt
    public let controlledRuntimeDefaultPathMutationPreparationCommitApplyRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let controlledRuntimeDefaultPathMutationPreparationCommitApplyAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let actualHandlerInvocationAllowed: Bool
    public let actualRequestContextMutationAllowed: Bool
    public let actualResponseWriteAllowed: Bool
    public let actualTransportCommitAllowed: Bool
    public let actualLiveServerWiringAllowed: Bool
    public let actualDefaultEngineFlipAllowed: Bool
    public let defaultEngineConfigMutationAllowed: Bool
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h1H2QuicRuntimeClosureClaimAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        controlledRuntimeDefaultPathMutationPreparationCommitApplyAccepted: Bool,
        runtimeDefaultPathMutationPreparationCommitApplyGateAccepted: Bool,
        runtimeDefaultPathMutationPreparationCommitApplyGateMode: String,
        controlledRuntimeDefaultPathMutationPreparationCommitApplyMode: String,
        controlledRuntimeDefaultPathMutationPreparationCommitApplyId: String,
        runtimeDefaultPathMutationPreparationCommitApplyGateId: String,
        runtimeDefaultPathMutationPreparationCommitDryRunId: String,
        runtimeDefaultPathMutationPreparationCommitPlanId: String,
        controlledPreparationApplyId: String,
        preparationApplyGateId: String,
        preparationDryRunId: String,
        preparationBoundaryId: String,
        preparationGateId: String,
        closeoutBoundaryGateId: String,
        closeoutBoundaryId: String,
        closeoutId: String,
        preparationCommitApplyGateReceipt: IgniteRuntimeDefaultPathMutationPreparationCommitApplyGateReceipt,
        controlledRuntimeDefaultPathMutationPreparationCommitApplyRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        controlledRuntimeDefaultPathMutationPreparationCommitApplyAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        actualHandlerInvocationAllowed: Bool,
        actualRequestContextMutationAllowed: Bool,
        actualResponseWriteAllowed: Bool,
        actualTransportCommitAllowed: Bool,
        actualLiveServerWiringAllowed: Bool,
        actualDefaultEngineFlipAllowed: Bool,
        defaultEngineConfigMutationAllowed: Bool,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h1H2QuicRuntimeClosureClaimAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.controlledRuntimeDefaultPathMutationPreparationCommitApplyAccepted =
            controlledRuntimeDefaultPathMutationPreparationCommitApplyAccepted
        this.runtimeDefaultPathMutationPreparationCommitApplyGateAccepted =
            runtimeDefaultPathMutationPreparationCommitApplyGateAccepted
        this.runtimeDefaultPathMutationPreparationCommitApplyGateMode =
            runtimeDefaultPathMutationPreparationCommitApplyGateMode
        this.controlledRuntimeDefaultPathMutationPreparationCommitApplyMode =
            controlledRuntimeDefaultPathMutationPreparationCommitApplyMode
        this.controlledRuntimeDefaultPathMutationPreparationCommitApplyId =
            controlledRuntimeDefaultPathMutationPreparationCommitApplyId
        this.runtimeDefaultPathMutationPreparationCommitApplyGateId =
            runtimeDefaultPathMutationPreparationCommitApplyGateId
        this.runtimeDefaultPathMutationPreparationCommitDryRunId =
            runtimeDefaultPathMutationPreparationCommitDryRunId
        this.runtimeDefaultPathMutationPreparationCommitPlanId =
            runtimeDefaultPathMutationPreparationCommitPlanId
        this.controlledPreparationApplyId = controlledPreparationApplyId
        this.preparationApplyGateId = preparationApplyGateId
        this.preparationDryRunId = preparationDryRunId
        this.preparationBoundaryId = preparationBoundaryId
        this.preparationGateId = preparationGateId
        this.closeoutBoundaryGateId = closeoutBoundaryGateId
        this.closeoutBoundaryId = closeoutBoundaryId
        this.closeoutId = closeoutId
        this.preparationCommitApplyGateReceipt =
            preparationCommitApplyGateReceipt
        this.controlledRuntimeDefaultPathMutationPreparationCommitApplyRecorded =
            controlledRuntimeDefaultPathMutationPreparationCommitApplyRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.controlledRuntimeDefaultPathMutationPreparationCommitApplyAllowed =
            controlledRuntimeDefaultPathMutationPreparationCommitApplyAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.actualRuntimeTaskSpawnAllowed = actualRuntimeTaskSpawnAllowed
        this.actualHandlerInvocationAllowed = actualHandlerInvocationAllowed
        this.actualRequestContextMutationAllowed =
            actualRequestContextMutationAllowed
        this.actualResponseWriteAllowed = actualResponseWriteAllowed
        this.actualTransportCommitAllowed = actualTransportCommitAllowed
        this.actualLiveServerWiringAllowed = actualLiveServerWiringAllowed
        this.actualDefaultEngineFlipAllowed = actualDefaultEngineFlipAllowed
        this.defaultEngineConfigMutationAllowed =
            defaultEngineConfigMutationAllowed
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h1H2QuicRuntimeClosureClaimAllowed =
            h1H2QuicRuntimeClosureClaimAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteControlledRuntimeDefaultPathMutationPreparationCommitApplyReceipt(
    preparationCommitApplyGateReceipt: IgniteRuntimeDefaultPathMutationPreparationCommitApplyGateReceipt,
    request: IgniteControlledRuntimeDefaultPathMutationPreparationCommitApplyRequest
): IgniteControlledRuntimeDefaultPathMutationPreparationCommitApplyReceipt {
    let nonClaims =
        igniteControlledRuntimeDefaultPathMutationPreparationCommitApplyNonClaims()
    if (
        !preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateAccepted
    ) {
        return IgniteControlledRuntimeDefaultPathMutationPreparationCommitApplyReceipt(
            false,
            preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateAccepted,
            preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateMode,
            "none",
            request.controlledRuntimeDefaultPathMutationPreparationCommitApplyId,
            preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateId,
            preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationCommitDryRunId,
            preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
            preparationCommitApplyGateReceipt.controlledPreparationApplyId,
            preparationCommitApplyGateReceipt.preparationApplyGateId,
            preparationCommitApplyGateReceipt.preparationDryRunId,
            preparationCommitApplyGateReceipt.preparationBoundaryId,
            preparationCommitApplyGateReceipt.preparationGateId,
            preparationCommitApplyGateReceipt.closeoutBoundaryGateId,
            preparationCommitApplyGateReceipt.closeoutBoundaryId,
            preparationCommitApplyGateReceipt.closeoutId,
            preparationCommitApplyGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-commit-apply-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-commit-apply-gate-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_APPLY_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0518 runtime default-path mutation preparation commit apply-gate input before controlled preparation commit apply work",
            "QUIC must not consume controlled runtime default-path mutation preparation commit apply receipts from rejected preparation commit apply-gate receipts"
        )
    }

    let controlledPreparationCommitApplyMode =
        igniteControlledRuntimeDefaultPathMutationPreparationCommitApplyModeFor(
            preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateMode
        )
    let blockers =
        igniteControlledRuntimeDefaultPathMutationPreparationCommitApplyBlockers(
            request,
            controlledPreparationCommitApplyMode
        )
    if (blockers.size > 0) {
        return IgniteControlledRuntimeDefaultPathMutationPreparationCommitApplyReceipt(
            false,
            preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateAccepted,
            preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateMode,
            controlledPreparationCommitApplyMode,
            request.controlledRuntimeDefaultPathMutationPreparationCommitApplyId,
            preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateId,
            preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationCommitDryRunId,
            preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
            preparationCommitApplyGateReceipt.controlledPreparationApplyId,
            preparationCommitApplyGateReceipt.preparationApplyGateId,
            preparationCommitApplyGateReceipt.preparationDryRunId,
            preparationCommitApplyGateReceipt.preparationBoundaryId,
            preparationCommitApplyGateReceipt.preparationGateId,
            preparationCommitApplyGateReceipt.closeoutBoundaryGateId,
            preparationCommitApplyGateReceipt.closeoutBoundaryId,
            preparationCommitApplyGateReceipt.closeoutId,
            preparationCommitApplyGateReceipt,
            false,
            "block",
            "blocked-controlled-runtime-default-path-mutation-preparation-commit-apply-input",
            "fix-controlled-runtime-default-path-mutation-preparation-commit-apply-before-runtime-default-mutation",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry controlled preparation commit apply id, preparation commit apply-gate snapshot, runtime default-path mutation lock, preparation commit apply boundary, rollback order, runtime guard plan, observability marker, and keep runtime default mutation out",
            "QUIC can reuse the same controlled runtime default-path mutation preparation commit apply blockers before default stream runtime mutation"
        )
    }

    IgniteControlledRuntimeDefaultPathMutationPreparationCommitApplyReceipt(
        true,
        preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateAccepted,
        preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateMode,
        controlledPreparationCommitApplyMode,
        request.controlledRuntimeDefaultPathMutationPreparationCommitApplyId,
        preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateId,
        preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationCommitDryRunId,
        preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
        preparationCommitApplyGateReceipt.controlledPreparationApplyId,
        preparationCommitApplyGateReceipt.preparationApplyGateId,
        preparationCommitApplyGateReceipt.preparationDryRunId,
        preparationCommitApplyGateReceipt.preparationBoundaryId,
        preparationCommitApplyGateReceipt.preparationGateId,
        preparationCommitApplyGateReceipt.closeoutBoundaryGateId,
        preparationCommitApplyGateReceipt.closeoutBoundaryId,
        preparationCommitApplyGateReceipt.closeoutId,
        preparationCommitApplyGateReceipt,
        true,
        "record-controlled-runtime-default-path-mutation-preparation-commit-apply",
        "accepted-controlled-runtime-default-path-mutation-preparation-commit-apply-receipt",
        "record-controlled-runtime-default-path-mutation-preparation-commit-apply-without-runtime-default-mutation",
        [],
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
        nonClaims,
        "next packet may prove runtime default-path mutation preparation commit boundary without mutating runtime defaults",
        "QUIC can reuse lane-specific controlled runtime default-path mutation preparation commit apply modes before runtime default mutation"
    )
}

func igniteControlledRuntimeDefaultPathMutationPreparationCommitApplyModeFor(
    preparationCommitApplyGateMode: String
): String {
    if (
        preparationCommitApplyGateMode ==
        "short-runtime-default-path-mutation-preparation-commit-apply-gate"
    ) {
        return "short-controlled-runtime-default-path-mutation-preparation-commit-apply"
    }
    if (
        preparationCommitApplyGateMode ==
        "long-runtime-default-path-mutation-preparation-commit-apply-gate"
    ) {
        return "long-controlled-runtime-default-path-mutation-preparation-commit-apply"
    }
    if (
        preparationCommitApplyGateMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-commit-apply-gate"
    ) {
        return "blocking-isolation-controlled-runtime-default-path-mutation-preparation-commit-apply"
    }
    "unknown-controlled-runtime-default-path-mutation-preparation-commit-apply"
}

func igniteControlledRuntimeDefaultPathMutationPreparationCommitApplyBlockers(
    request: IgniteControlledRuntimeDefaultPathMutationPreparationCommitApplyRequest,
    controlledPreparationCommitApplyMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.controlledRuntimeDefaultPathMutationPreparationCommitApplyId.size == 0) {
        blockers.add("CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_APPLY_ID_NOT_CARRIED")
    }
    if (!request.preparationCommitApplyGateSnapshotCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_APPLY_GATE_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.preparationCommitApplyBoundaryCarried) {
        blockers.add("PREPARATION_COMMIT_APPLY_BOUNDARY_NOT_CARRIED")
    }
    if (!request.rollbackOrderCarried) {
        blockers.add("ROLLBACK_ORDER_NOT_CARRIED")
    }
    if (!request.runtimeGuardPlanCarried) {
        blockers.add("RUNTIME_GUARD_PLAN_NOT_CARRIED")
    }
    if (!request.observabilityMarkerCarried) {
        blockers.add("OBSERVABILITY_MARKER_NOT_CARRIED")
    }
    if (request.productionQueueMutationRequested) {
        blockers.add("PRODUCTION_QUEUE_MUTATION_REQUESTED")
    }
    if (request.actualRuntimeTaskSpawnRequested) {
        blockers.add("ACTUAL_RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.actualHandlerInvocationRequested) {
        blockers.add("ACTUAL_HANDLER_INVOCATION_REQUESTED")
    }
    if (request.actualRequestContextMutationRequested) {
        blockers.add("ACTUAL_REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.actualResponseWriteRequested) {
        blockers.add("ACTUAL_RESPONSE_WRITE_REQUESTED")
    }
    if (request.actualTransportCommitRequested) {
        blockers.add("ACTUAL_TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.actualLiveServerWiringRequested) {
        blockers.add("ACTUAL_LIVE_SERVER_WIRING_REQUESTED")
    }
    if (request.actualDefaultEngineFlipRequested) {
        blockers.add("ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
    }
    if (request.defaultEngineConfigMutationRequested) {
        blockers.add("DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
    }
    if (request.runtimeDefaultPathMutationRequested) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
    }
    if (request.publicReleaseRequested) {
        blockers.add("PUBLIC_RELEASE_REQUESTED")
    }
    if (request.stdxRemovalRequested) {
        blockers.add("STDX_REMOVAL_REQUESTED")
    }
    if (request.h1H2QuicRuntimeClosureClaimed) {
        blockers.add("H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    }
    if (
        controlledPreparationCommitApplyMode ==
        "unknown-controlled-runtime-default-path-mutation-preparation-commit-apply"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_APPLY_GATE")
    }
    blockers.toArray()
}

func igniteControlledRuntimeDefaultPathMutationPreparationCommitApplyNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationCommitApplyGateNonClaims()
}
