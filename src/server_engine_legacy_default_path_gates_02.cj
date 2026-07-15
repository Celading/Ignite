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

public class IgniteRuntimeDefaultPathMutationPreparationCommitBoundaryRequest {
    public let runtimeDefaultPathMutationPreparationCommitBoundaryId: String
    public let controlledPreparationCommitApplySnapshotCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let preparationCommitBoundarySnapshotCarried: Bool
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
        runtimeDefaultPathMutationPreparationCommitBoundaryId: String,
        controlledPreparationCommitApplySnapshotCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        preparationCommitBoundarySnapshotCarried: Bool,
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
        this.runtimeDefaultPathMutationPreparationCommitBoundaryId =
            runtimeDefaultPathMutationPreparationCommitBoundaryId
        this.controlledPreparationCommitApplySnapshotCarried =
            controlledPreparationCommitApplySnapshotCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.preparationCommitBoundarySnapshotCarried =
            preparationCommitBoundarySnapshotCarried
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

public class IgniteRuntimeDefaultPathMutationPreparationCommitBoundaryReceipt {
    public let runtimeDefaultPathMutationPreparationCommitBoundaryAccepted: Bool
    public let controlledRuntimeDefaultPathMutationPreparationCommitApplyAccepted: Bool
    public let controlledRuntimeDefaultPathMutationPreparationCommitApplyMode: String
    public let runtimeDefaultPathMutationPreparationCommitBoundaryMode: String
    public let runtimeDefaultPathMutationPreparationCommitBoundaryId: String
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
    public let controlledPreparationCommitApplyReceipt: IgniteControlledRuntimeDefaultPathMutationPreparationCommitApplyReceipt
    public let runtimeDefaultPathMutationPreparationCommitBoundaryRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationCommitBoundaryAllowed: Bool
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
        runtimeDefaultPathMutationPreparationCommitBoundaryAccepted: Bool,
        controlledRuntimeDefaultPathMutationPreparationCommitApplyAccepted: Bool,
        controlledRuntimeDefaultPathMutationPreparationCommitApplyMode: String,
        runtimeDefaultPathMutationPreparationCommitBoundaryMode: String,
        runtimeDefaultPathMutationPreparationCommitBoundaryId: String,
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
        controlledPreparationCommitApplyReceipt: IgniteControlledRuntimeDefaultPathMutationPreparationCommitApplyReceipt,
        runtimeDefaultPathMutationPreparationCommitBoundaryRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationCommitBoundaryAllowed: Bool,
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
        this.runtimeDefaultPathMutationPreparationCommitBoundaryAccepted =
            runtimeDefaultPathMutationPreparationCommitBoundaryAccepted
        this.controlledRuntimeDefaultPathMutationPreparationCommitApplyAccepted =
            controlledRuntimeDefaultPathMutationPreparationCommitApplyAccepted
        this.controlledRuntimeDefaultPathMutationPreparationCommitApplyMode =
            controlledRuntimeDefaultPathMutationPreparationCommitApplyMode
        this.runtimeDefaultPathMutationPreparationCommitBoundaryMode =
            runtimeDefaultPathMutationPreparationCommitBoundaryMode
        this.runtimeDefaultPathMutationPreparationCommitBoundaryId =
            runtimeDefaultPathMutationPreparationCommitBoundaryId
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
        this.controlledPreparationCommitApplyReceipt =
            controlledPreparationCommitApplyReceipt
        this.runtimeDefaultPathMutationPreparationCommitBoundaryRecorded =
            runtimeDefaultPathMutationPreparationCommitBoundaryRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationCommitBoundaryAllowed =
            runtimeDefaultPathMutationPreparationCommitBoundaryAllowed
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

public func buildIgniteRuntimeDefaultPathMutationPreparationCommitBoundaryReceipt(
    controlledPreparationCommitApplyReceipt: IgniteControlledRuntimeDefaultPathMutationPreparationCommitApplyReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationCommitBoundaryRequest
): IgniteRuntimeDefaultPathMutationPreparationCommitBoundaryReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationCommitBoundaryNonClaims()
    if (
        !controlledPreparationCommitApplyReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationCommitBoundaryReceipt(
            false,
            controlledPreparationCommitApplyReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyAccepted,
            controlledPreparationCommitApplyReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyMode,
            "none",
            request.runtimeDefaultPathMutationPreparationCommitBoundaryId,
            controlledPreparationCommitApplyReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyId,
            controlledPreparationCommitApplyReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateId,
            controlledPreparationCommitApplyReceipt.runtimeDefaultPathMutationPreparationCommitDryRunId,
            controlledPreparationCommitApplyReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
            controlledPreparationCommitApplyReceipt.controlledPreparationApplyId,
            controlledPreparationCommitApplyReceipt.preparationApplyGateId,
            controlledPreparationCommitApplyReceipt.preparationDryRunId,
            controlledPreparationCommitApplyReceipt.preparationBoundaryId,
            controlledPreparationCommitApplyReceipt.preparationGateId,
            controlledPreparationCommitApplyReceipt.closeoutBoundaryGateId,
            controlledPreparationCommitApplyReceipt.closeoutBoundaryId,
            controlledPreparationCommitApplyReceipt.closeoutId,
            controlledPreparationCommitApplyReceipt,
            false,
            "block",
            "blocked-controlled-runtime-default-path-mutation-preparation-commit-apply-receipt",
            "collect-accepted-controlled-runtime-default-path-mutation-preparation-commit-apply-receipt-first",
            ["CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_APPLY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0519 controlled runtime default-path mutation preparation commit apply input before preparation commit boundary work",
            "QUIC must not consume runtime default-path mutation preparation commit boundary receipts from rejected controlled preparation commit apply receipts"
        )
    }

    let preparationCommitBoundaryMode =
        igniteRuntimeDefaultPathMutationPreparationCommitBoundaryModeFor(
            controlledPreparationCommitApplyReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationCommitBoundaryBlockers(
            request,
            preparationCommitBoundaryMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationCommitBoundaryReceipt(
            false,
            controlledPreparationCommitApplyReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyAccepted,
            controlledPreparationCommitApplyReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyMode,
            preparationCommitBoundaryMode,
            request.runtimeDefaultPathMutationPreparationCommitBoundaryId,
            controlledPreparationCommitApplyReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyId,
            controlledPreparationCommitApplyReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateId,
            controlledPreparationCommitApplyReceipt.runtimeDefaultPathMutationPreparationCommitDryRunId,
            controlledPreparationCommitApplyReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
            controlledPreparationCommitApplyReceipt.controlledPreparationApplyId,
            controlledPreparationCommitApplyReceipt.preparationApplyGateId,
            controlledPreparationCommitApplyReceipt.preparationDryRunId,
            controlledPreparationCommitApplyReceipt.preparationBoundaryId,
            controlledPreparationCommitApplyReceipt.preparationGateId,
            controlledPreparationCommitApplyReceipt.closeoutBoundaryGateId,
            controlledPreparationCommitApplyReceipt.closeoutBoundaryId,
            controlledPreparationCommitApplyReceipt.closeoutId,
            controlledPreparationCommitApplyReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-commit-boundary-input",
            "fix-runtime-default-path-mutation-preparation-commit-boundary-before-runtime-default-mutation",
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
            "carry preparation commit boundary id, controlled preparation commit apply snapshot, runtime default-path mutation lock, preparation commit boundary snapshot, rollback order, runtime guard plan, observability marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation preparation commit boundary blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationPreparationCommitBoundaryReceipt(
        true,
        controlledPreparationCommitApplyReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyAccepted,
        controlledPreparationCommitApplyReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyMode,
        preparationCommitBoundaryMode,
        request.runtimeDefaultPathMutationPreparationCommitBoundaryId,
        controlledPreparationCommitApplyReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyId,
        controlledPreparationCommitApplyReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateId,
        controlledPreparationCommitApplyReceipt.runtimeDefaultPathMutationPreparationCommitDryRunId,
        controlledPreparationCommitApplyReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
        controlledPreparationCommitApplyReceipt.controlledPreparationApplyId,
        controlledPreparationCommitApplyReceipt.preparationApplyGateId,
        controlledPreparationCommitApplyReceipt.preparationDryRunId,
        controlledPreparationCommitApplyReceipt.preparationBoundaryId,
        controlledPreparationCommitApplyReceipt.preparationGateId,
        controlledPreparationCommitApplyReceipt.closeoutBoundaryGateId,
        controlledPreparationCommitApplyReceipt.closeoutBoundaryId,
        controlledPreparationCommitApplyReceipt.closeoutId,
        controlledPreparationCommitApplyReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-commit-boundary",
        "accepted-runtime-default-path-mutation-preparation-commit-boundary-receipt",
        "record-runtime-default-path-mutation-preparation-commit-boundary-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation preparation finalization gate without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation commit boundary modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationCommitBoundaryModeFor(
    controlledPreparationCommitApplyMode: String
): String {
    if (
        controlledPreparationCommitApplyMode ==
        "short-controlled-runtime-default-path-mutation-preparation-commit-apply"
    ) {
        return "short-runtime-default-path-mutation-preparation-commit-boundary"
    }
    if (
        controlledPreparationCommitApplyMode ==
        "long-controlled-runtime-default-path-mutation-preparation-commit-apply"
    ) {
        return "long-runtime-default-path-mutation-preparation-commit-boundary"
    }
    if (
        controlledPreparationCommitApplyMode ==
        "blocking-isolation-controlled-runtime-default-path-mutation-preparation-commit-apply"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-commit-boundary"
    }
    "unknown-runtime-default-path-mutation-preparation-commit-boundary"
}

func igniteRuntimeDefaultPathMutationPreparationCommitBoundaryBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationCommitBoundaryRequest,
    preparationCommitBoundaryMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.runtimeDefaultPathMutationPreparationCommitBoundaryId.size == 0) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_BOUNDARY_ID_NOT_CARRIED")
    }
    if (!request.controlledPreparationCommitApplySnapshotCarried) {
        blockers.add("CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_APPLY_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.preparationCommitBoundarySnapshotCarried) {
        blockers.add("PREPARATION_COMMIT_BOUNDARY_SNAPSHOT_NOT_CARRIED")
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
        preparationCommitBoundaryMode ==
        "unknown-runtime-default-path-mutation-preparation-commit-boundary"
    ) {
        blockers.add("UNKNOWN_CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_APPLY")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationCommitBoundaryNonClaims(): Array<String> {
    igniteControlledRuntimeDefaultPathMutationPreparationCommitApplyNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationFinalizationGateRequest {
    public let runtimeDefaultPathMutationPreparationFinalizationGateId: String
    public let preparationCommitBoundarySnapshotCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let rollbackOrderCarried: Bool
    public let runtimeGuardPlanCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let finalizationAuditMarkerCarried: Bool
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
        runtimeDefaultPathMutationPreparationFinalizationGateId: String,
        preparationCommitBoundarySnapshotCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        rollbackOrderCarried: Bool,
        runtimeGuardPlanCarried: Bool,
        observabilityMarkerCarried: Bool,
        finalizationAuditMarkerCarried: Bool,
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
        this.runtimeDefaultPathMutationPreparationFinalizationGateId =
            runtimeDefaultPathMutationPreparationFinalizationGateId
        this.preparationCommitBoundarySnapshotCarried =
            preparationCommitBoundarySnapshotCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.rollbackOrderCarried = rollbackOrderCarried
        this.runtimeGuardPlanCarried = runtimeGuardPlanCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
        this.finalizationAuditMarkerCarried = finalizationAuditMarkerCarried
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

public class IgniteRuntimeDefaultPathMutationPreparationFinalizationGateReceipt {
    public let runtimeDefaultPathMutationPreparationFinalizationGateAccepted: Bool
    public let runtimeDefaultPathMutationPreparationCommitBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationPreparationCommitBoundaryMode: String
    public let runtimeDefaultPathMutationPreparationFinalizationGateMode: String
    public let runtimeDefaultPathMutationPreparationFinalizationGateId: String
    public let runtimeDefaultPathMutationPreparationCommitBoundaryId: String
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
    public let preparationCommitBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationCommitBoundaryReceipt
    public let runtimeDefaultPathMutationPreparationFinalizationGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationFinalizationGateAllowed: Bool
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
        runtimeDefaultPathMutationPreparationFinalizationGateAccepted: Bool,
        runtimeDefaultPathMutationPreparationCommitBoundaryAccepted: Bool,
        runtimeDefaultPathMutationPreparationCommitBoundaryMode: String,
        runtimeDefaultPathMutationPreparationFinalizationGateMode: String,
        runtimeDefaultPathMutationPreparationFinalizationGateId: String,
        runtimeDefaultPathMutationPreparationCommitBoundaryId: String,
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
        preparationCommitBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationCommitBoundaryReceipt,
        runtimeDefaultPathMutationPreparationFinalizationGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationFinalizationGateAllowed: Bool,
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
        this.runtimeDefaultPathMutationPreparationFinalizationGateAccepted =
            runtimeDefaultPathMutationPreparationFinalizationGateAccepted
        this.runtimeDefaultPathMutationPreparationCommitBoundaryAccepted =
            runtimeDefaultPathMutationPreparationCommitBoundaryAccepted
        this.runtimeDefaultPathMutationPreparationCommitBoundaryMode =
            runtimeDefaultPathMutationPreparationCommitBoundaryMode
        this.runtimeDefaultPathMutationPreparationFinalizationGateMode =
            runtimeDefaultPathMutationPreparationFinalizationGateMode
        this.runtimeDefaultPathMutationPreparationFinalizationGateId =
            runtimeDefaultPathMutationPreparationFinalizationGateId
        this.runtimeDefaultPathMutationPreparationCommitBoundaryId =
            runtimeDefaultPathMutationPreparationCommitBoundaryId
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
        this.preparationCommitBoundaryReceipt =
            preparationCommitBoundaryReceipt
        this.runtimeDefaultPathMutationPreparationFinalizationGateRecorded =
            runtimeDefaultPathMutationPreparationFinalizationGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationFinalizationGateAllowed =
            runtimeDefaultPathMutationPreparationFinalizationGateAllowed
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

public func buildIgniteRuntimeDefaultPathMutationPreparationFinalizationGateReceipt(
    preparationCommitBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationCommitBoundaryReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationFinalizationGateRequest
): IgniteRuntimeDefaultPathMutationPreparationFinalizationGateReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationFinalizationGateNonClaims()
    if (
        !preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationFinalizationGateReceipt(
            false,
            preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryAccepted,
            preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryMode,
            "none",
            request.runtimeDefaultPathMutationPreparationFinalizationGateId,
            preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryId,
            preparationCommitBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyId,
            preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateId,
            preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitDryRunId,
            preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
            preparationCommitBoundaryReceipt.controlledPreparationApplyId,
            preparationCommitBoundaryReceipt.preparationApplyGateId,
            preparationCommitBoundaryReceipt.preparationDryRunId,
            preparationCommitBoundaryReceipt.preparationBoundaryId,
            preparationCommitBoundaryReceipt.preparationGateId,
            preparationCommitBoundaryReceipt.closeoutBoundaryGateId,
            preparationCommitBoundaryReceipt.closeoutBoundaryId,
            preparationCommitBoundaryReceipt.closeoutId,
            preparationCommitBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-commit-boundary-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-commit-boundary-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_BOUNDARY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0520 runtime default-path mutation preparation commit boundary input before preparation finalization gate work",
            "QUIC must not consume runtime default-path mutation preparation finalization gate receipts from rejected preparation commit boundary receipts"
        )
    }

    let preparationFinalizationGateMode =
        igniteRuntimeDefaultPathMutationPreparationFinalizationGateModeFor(
            preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationFinalizationGateBlockers(
            request,
            preparationFinalizationGateMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationFinalizationGateReceipt(
            false,
            preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryAccepted,
            preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryMode,
            preparationFinalizationGateMode,
            request.runtimeDefaultPathMutationPreparationFinalizationGateId,
            preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryId,
            preparationCommitBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyId,
            preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateId,
            preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitDryRunId,
            preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
            preparationCommitBoundaryReceipt.controlledPreparationApplyId,
            preparationCommitBoundaryReceipt.preparationApplyGateId,
            preparationCommitBoundaryReceipt.preparationDryRunId,
            preparationCommitBoundaryReceipt.preparationBoundaryId,
            preparationCommitBoundaryReceipt.preparationGateId,
            preparationCommitBoundaryReceipt.closeoutBoundaryGateId,
            preparationCommitBoundaryReceipt.closeoutBoundaryId,
            preparationCommitBoundaryReceipt.closeoutId,
            preparationCommitBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-finalization-gate-input",
            "fix-runtime-default-path-mutation-preparation-finalization-gate-before-runtime-default-mutation",
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
            "carry preparation finalization gate id, preparation commit boundary snapshot, runtime default-path mutation lock, rollback order, runtime guard plan, observability marker, finalization audit marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation preparation finalization gate blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationPreparationFinalizationGateReceipt(
        true,
        preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryAccepted,
        preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryMode,
        preparationFinalizationGateMode,
        request.runtimeDefaultPathMutationPreparationFinalizationGateId,
        preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryId,
        preparationCommitBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyId,
        preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateId,
        preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitDryRunId,
        preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
        preparationCommitBoundaryReceipt.controlledPreparationApplyId,
        preparationCommitBoundaryReceipt.preparationApplyGateId,
        preparationCommitBoundaryReceipt.preparationDryRunId,
        preparationCommitBoundaryReceipt.preparationBoundaryId,
        preparationCommitBoundaryReceipt.preparationGateId,
        preparationCommitBoundaryReceipt.closeoutBoundaryGateId,
        preparationCommitBoundaryReceipt.closeoutBoundaryId,
        preparationCommitBoundaryReceipt.closeoutId,
        preparationCommitBoundaryReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-finalization-gate",
        "accepted-runtime-default-path-mutation-preparation-finalization-gate-receipt",
        "record-runtime-default-path-mutation-preparation-finalization-gate-without-runtime-default-mutation",
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
        "next packet may prove controlled runtime default-path mutation preparation finalization apply without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation finalization gate modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationFinalizationGateModeFor(
    preparationCommitBoundaryMode: String
): String {
    if (
        preparationCommitBoundaryMode ==
        "short-runtime-default-path-mutation-preparation-commit-boundary"
    ) {
        return "short-runtime-default-path-mutation-preparation-finalization-gate"
    }
    if (
        preparationCommitBoundaryMode ==
        "long-runtime-default-path-mutation-preparation-commit-boundary"
    ) {
        return "long-runtime-default-path-mutation-preparation-finalization-gate"
    }
    if (
        preparationCommitBoundaryMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-commit-boundary"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-finalization-gate"
    }
    "unknown-runtime-default-path-mutation-preparation-finalization-gate"
}

func igniteRuntimeDefaultPathMutationPreparationFinalizationGateBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationFinalizationGateRequest,
    preparationFinalizationGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationPreparationFinalizationGateId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_FINALIZATION_GATE_ID_NOT_CARRIED")
    }
    if (!request.preparationCommitBoundarySnapshotCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_BOUNDARY_SNAPSHOT_NOT_CARRIED")
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
    if (!request.finalizationAuditMarkerCarried) {
        blockers.add("FINALIZATION_AUDIT_MARKER_NOT_CARRIED")
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
        preparationFinalizationGateMode ==
        "unknown-runtime-default-path-mutation-preparation-finalization-gate"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_COMMIT_BOUNDARY")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationFinalizationGateNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationCommitBoundaryNonClaims()
}

public class IgniteControlledRuntimeDefaultPathMutationPreparationFinalizationApplyRequest {
    public let controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId: String
    public let preparationFinalizationGateSnapshotCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let preparationFinalizationApplyBoundaryCarried: Bool
    public let rollbackOrderCarried: Bool
    public let runtimeGuardPlanCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let finalizationAuditMarkerCarried: Bool
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
        controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId: String,
        preparationFinalizationGateSnapshotCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        preparationFinalizationApplyBoundaryCarried: Bool,
        rollbackOrderCarried: Bool,
        runtimeGuardPlanCarried: Bool,
        observabilityMarkerCarried: Bool,
        finalizationAuditMarkerCarried: Bool,
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
        this.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId =
            controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId
        this.preparationFinalizationGateSnapshotCarried =
            preparationFinalizationGateSnapshotCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.preparationFinalizationApplyBoundaryCarried =
            preparationFinalizationApplyBoundaryCarried
        this.rollbackOrderCarried = rollbackOrderCarried
        this.runtimeGuardPlanCarried = runtimeGuardPlanCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
        this.finalizationAuditMarkerCarried = finalizationAuditMarkerCarried
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

public class IgniteControlledRuntimeDefaultPathMutationPreparationFinalizationApplyReceipt {
    public let controlledRuntimeDefaultPathMutationPreparationFinalizationApplyAccepted: Bool
    public let runtimeDefaultPathMutationPreparationFinalizationGateAccepted: Bool
    public let runtimeDefaultPathMutationPreparationFinalizationGateMode: String
    public let controlledRuntimeDefaultPathMutationPreparationFinalizationApplyMode: String
    public let controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId: String
    public let runtimeDefaultPathMutationPreparationFinalizationGateId: String
    public let runtimeDefaultPathMutationPreparationCommitBoundaryId: String
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
    public let preparationFinalizationGateReceipt: IgniteRuntimeDefaultPathMutationPreparationFinalizationGateReceipt
    public let controlledRuntimeDefaultPathMutationPreparationFinalizationApplyRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let controlledRuntimeDefaultPathMutationPreparationFinalizationApplyAllowed: Bool
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
        controlledRuntimeDefaultPathMutationPreparationFinalizationApplyAccepted: Bool,
        runtimeDefaultPathMutationPreparationFinalizationGateAccepted: Bool,
        runtimeDefaultPathMutationPreparationFinalizationGateMode: String,
        controlledRuntimeDefaultPathMutationPreparationFinalizationApplyMode: String,
        controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId: String,
        runtimeDefaultPathMutationPreparationFinalizationGateId: String,
        runtimeDefaultPathMutationPreparationCommitBoundaryId: String,
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
        preparationFinalizationGateReceipt: IgniteRuntimeDefaultPathMutationPreparationFinalizationGateReceipt,
        controlledRuntimeDefaultPathMutationPreparationFinalizationApplyRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        controlledRuntimeDefaultPathMutationPreparationFinalizationApplyAllowed: Bool,
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
        this.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyAccepted =
            controlledRuntimeDefaultPathMutationPreparationFinalizationApplyAccepted
        this.runtimeDefaultPathMutationPreparationFinalizationGateAccepted =
            runtimeDefaultPathMutationPreparationFinalizationGateAccepted
        this.runtimeDefaultPathMutationPreparationFinalizationGateMode =
            runtimeDefaultPathMutationPreparationFinalizationGateMode
        this.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyMode =
            controlledRuntimeDefaultPathMutationPreparationFinalizationApplyMode
        this.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId =
            controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId
        this.runtimeDefaultPathMutationPreparationFinalizationGateId =
            runtimeDefaultPathMutationPreparationFinalizationGateId
        this.runtimeDefaultPathMutationPreparationCommitBoundaryId =
            runtimeDefaultPathMutationPreparationCommitBoundaryId
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
        this.preparationFinalizationGateReceipt =
            preparationFinalizationGateReceipt
        this.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyRecorded =
            controlledRuntimeDefaultPathMutationPreparationFinalizationApplyRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyAllowed =
            controlledRuntimeDefaultPathMutationPreparationFinalizationApplyAllowed
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

public func buildIgniteControlledRuntimeDefaultPathMutationPreparationFinalizationApplyReceipt(
    preparationFinalizationGateReceipt: IgniteRuntimeDefaultPathMutationPreparationFinalizationGateReceipt,
    request: IgniteControlledRuntimeDefaultPathMutationPreparationFinalizationApplyRequest
): IgniteControlledRuntimeDefaultPathMutationPreparationFinalizationApplyReceipt {
    let nonClaims =
        igniteControlledRuntimeDefaultPathMutationPreparationFinalizationApplyNonClaims()
    if (
        !preparationFinalizationGateReceipt
            .runtimeDefaultPathMutationPreparationFinalizationGateAccepted
    ) {
        return IgniteControlledRuntimeDefaultPathMutationPreparationFinalizationApplyReceipt(
            false,
            preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationFinalizationGateAccepted,
            preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationFinalizationGateMode,
            "none",
            request.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId,
            preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationFinalizationGateId,
            preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryId,
            preparationFinalizationGateReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyId,
            preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateId,
            preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationCommitDryRunId,
            preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
            preparationFinalizationGateReceipt.controlledPreparationApplyId,
            preparationFinalizationGateReceipt.preparationApplyGateId,
            preparationFinalizationGateReceipt.preparationDryRunId,
            preparationFinalizationGateReceipt.preparationBoundaryId,
            preparationFinalizationGateReceipt.preparationGateId,
            preparationFinalizationGateReceipt.closeoutBoundaryGateId,
            preparationFinalizationGateReceipt.closeoutBoundaryId,
            preparationFinalizationGateReceipt.closeoutId,
            preparationFinalizationGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-finalization-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-finalization-gate-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_FINALIZATION_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0521 runtime default-path mutation preparation finalization gate input before controlled preparation finalization apply work",
            "QUIC must not consume controlled runtime default-path mutation preparation finalization apply receipts from rejected preparation finalization-gate receipts"
        )
    }

    let controlledPreparationFinalizationApplyMode =
        igniteControlledRuntimeDefaultPathMutationPreparationFinalizationApplyModeFor(
            preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationFinalizationGateMode
        )
    let blockers =
        igniteControlledRuntimeDefaultPathMutationPreparationFinalizationApplyBlockers(
            request,
            controlledPreparationFinalizationApplyMode
        )
    if (blockers.size > 0) {
        return IgniteControlledRuntimeDefaultPathMutationPreparationFinalizationApplyReceipt(
            false,
            preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationFinalizationGateAccepted,
            preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationFinalizationGateMode,
            controlledPreparationFinalizationApplyMode,
            request.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId,
            preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationFinalizationGateId,
            preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryId,
            preparationFinalizationGateReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyId,
            preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateId,
            preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationCommitDryRunId,
            preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
            preparationFinalizationGateReceipt.controlledPreparationApplyId,
            preparationFinalizationGateReceipt.preparationApplyGateId,
            preparationFinalizationGateReceipt.preparationDryRunId,
            preparationFinalizationGateReceipt.preparationBoundaryId,
            preparationFinalizationGateReceipt.preparationGateId,
            preparationFinalizationGateReceipt.closeoutBoundaryGateId,
            preparationFinalizationGateReceipt.closeoutBoundaryId,
            preparationFinalizationGateReceipt.closeoutId,
            preparationFinalizationGateReceipt,
            false,
            "block",
            "blocked-controlled-runtime-default-path-mutation-preparation-finalization-apply-input",
            "fix-controlled-runtime-default-path-mutation-preparation-finalization-apply-before-runtime-default-mutation",
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
            "carry controlled preparation finalization apply id, preparation finalization-gate snapshot, runtime default-path mutation lock, preparation finalization apply boundary, rollback order, runtime guard plan, observability marker, finalization audit marker, and keep runtime default mutation out",
            "QUIC can reuse the same controlled runtime default-path mutation preparation finalization apply blockers before default stream runtime mutation"
        )
    }

    IgniteControlledRuntimeDefaultPathMutationPreparationFinalizationApplyReceipt(
        true,
        preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationFinalizationGateAccepted,
        preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationFinalizationGateMode,
        controlledPreparationFinalizationApplyMode,
        request.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId,
        preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationFinalizationGateId,
        preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryId,
        preparationFinalizationGateReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyId,
        preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateId,
        preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationCommitDryRunId,
        preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
        preparationFinalizationGateReceipt.controlledPreparationApplyId,
        preparationFinalizationGateReceipt.preparationApplyGateId,
        preparationFinalizationGateReceipt.preparationDryRunId,
        preparationFinalizationGateReceipt.preparationBoundaryId,
        preparationFinalizationGateReceipt.preparationGateId,
        preparationFinalizationGateReceipt.closeoutBoundaryGateId,
        preparationFinalizationGateReceipt.closeoutBoundaryId,
        preparationFinalizationGateReceipt.closeoutId,
        preparationFinalizationGateReceipt,
        true,
        "record-controlled-runtime-default-path-mutation-preparation-finalization-apply",
        "accepted-controlled-runtime-default-path-mutation-preparation-finalization-apply-receipt",
        "record-controlled-runtime-default-path-mutation-preparation-finalization-apply-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation preparation closeout gate without mutating runtime defaults",
        "QUIC can reuse lane-specific controlled runtime default-path mutation preparation finalization apply modes before runtime default mutation"
    )
}

func igniteControlledRuntimeDefaultPathMutationPreparationFinalizationApplyModeFor(
    preparationFinalizationGateMode: String
): String {
    if (
        preparationFinalizationGateMode ==
        "short-runtime-default-path-mutation-preparation-finalization-gate"
    ) {
        return "short-controlled-runtime-default-path-mutation-preparation-finalization-apply"
    }
    if (
        preparationFinalizationGateMode ==
        "long-runtime-default-path-mutation-preparation-finalization-gate"
    ) {
        return "long-controlled-runtime-default-path-mutation-preparation-finalization-apply"
    }
    if (
        preparationFinalizationGateMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-finalization-gate"
    ) {
        return "blocking-isolation-controlled-runtime-default-path-mutation-preparation-finalization-apply"
    }
    "unknown-controlled-runtime-default-path-mutation-preparation-finalization-apply"
}

func igniteControlledRuntimeDefaultPathMutationPreparationFinalizationApplyBlockers(
    request: IgniteControlledRuntimeDefaultPathMutationPreparationFinalizationApplyRequest,
    controlledPreparationFinalizationApplyMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId.size ==
        0
    ) {
        blockers.add("CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_FINALIZATION_APPLY_ID_NOT_CARRIED")
    }
    if (!request.preparationFinalizationGateSnapshotCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_FINALIZATION_GATE_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.preparationFinalizationApplyBoundaryCarried) {
        blockers.add("PREPARATION_FINALIZATION_APPLY_BOUNDARY_NOT_CARRIED")
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
    if (!request.finalizationAuditMarkerCarried) {
        blockers.add("FINALIZATION_AUDIT_MARKER_NOT_CARRIED")
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
        controlledPreparationFinalizationApplyMode ==
        "unknown-controlled-runtime-default-path-mutation-preparation-finalization-apply"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_FINALIZATION_GATE")
    }
    blockers.toArray()
}

func igniteControlledRuntimeDefaultPathMutationPreparationFinalizationApplyNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationFinalizationGateNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationCloseoutGateRequest {
    public let runtimeDefaultPathMutationPreparationCloseoutGateId: String
    public let controlledPreparationFinalizationApplySnapshotCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let preparationCloseoutGateCarried: Bool
    public let closeoutReviewCarried: Bool
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
        runtimeDefaultPathMutationPreparationCloseoutGateId: String,
        controlledPreparationFinalizationApplySnapshotCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        preparationCloseoutGateCarried: Bool,
        closeoutReviewCarried: Bool,
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
        this.runtimeDefaultPathMutationPreparationCloseoutGateId =
            runtimeDefaultPathMutationPreparationCloseoutGateId
        this.controlledPreparationFinalizationApplySnapshotCarried =
            controlledPreparationFinalizationApplySnapshotCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.preparationCloseoutGateCarried =
            preparationCloseoutGateCarried
        this.closeoutReviewCarried = closeoutReviewCarried
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

public class IgniteRuntimeDefaultPathMutationPreparationCloseoutGateReceipt {
    public let runtimeDefaultPathMutationPreparationCloseoutGateAccepted: Bool
    public let controlledRuntimeDefaultPathMutationPreparationFinalizationApplyAccepted: Bool
    public let controlledRuntimeDefaultPathMutationPreparationFinalizationApplyMode: String
    public let runtimeDefaultPathMutationPreparationCloseoutGateMode: String
    public let runtimeDefaultPathMutationPreparationCloseoutGateId: String
    public let controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId: String
    public let runtimeDefaultPathMutationPreparationFinalizationGateId: String
    public let runtimeDefaultPathMutationPreparationCommitBoundaryId: String
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
    public let controlledPreparationFinalizationApplyReceipt: IgniteControlledRuntimeDefaultPathMutationPreparationFinalizationApplyReceipt
    public let runtimeDefaultPathMutationPreparationCloseoutGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationCloseoutGateAllowed: Bool
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
        runtimeDefaultPathMutationPreparationCloseoutGateAccepted: Bool,
        controlledRuntimeDefaultPathMutationPreparationFinalizationApplyAccepted: Bool,
        controlledRuntimeDefaultPathMutationPreparationFinalizationApplyMode: String,
        runtimeDefaultPathMutationPreparationCloseoutGateMode: String,
        runtimeDefaultPathMutationPreparationCloseoutGateId: String,
        controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId: String,
        runtimeDefaultPathMutationPreparationFinalizationGateId: String,
        runtimeDefaultPathMutationPreparationCommitBoundaryId: String,
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
        controlledPreparationFinalizationApplyReceipt: IgniteControlledRuntimeDefaultPathMutationPreparationFinalizationApplyReceipt,
        runtimeDefaultPathMutationPreparationCloseoutGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationCloseoutGateAllowed: Bool,
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
        this.runtimeDefaultPathMutationPreparationCloseoutGateAccepted =
            runtimeDefaultPathMutationPreparationCloseoutGateAccepted
        this.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyAccepted =
            controlledRuntimeDefaultPathMutationPreparationFinalizationApplyAccepted
        this.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyMode =
            controlledRuntimeDefaultPathMutationPreparationFinalizationApplyMode
        this.runtimeDefaultPathMutationPreparationCloseoutGateMode =
            runtimeDefaultPathMutationPreparationCloseoutGateMode
        this.runtimeDefaultPathMutationPreparationCloseoutGateId =
            runtimeDefaultPathMutationPreparationCloseoutGateId
        this.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId =
            controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId
        this.runtimeDefaultPathMutationPreparationFinalizationGateId =
            runtimeDefaultPathMutationPreparationFinalizationGateId
        this.runtimeDefaultPathMutationPreparationCommitBoundaryId =
            runtimeDefaultPathMutationPreparationCommitBoundaryId
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
        this.controlledPreparationFinalizationApplyReceipt =
            controlledPreparationFinalizationApplyReceipt
        this.runtimeDefaultPathMutationPreparationCloseoutGateRecorded =
            runtimeDefaultPathMutationPreparationCloseoutGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationCloseoutGateAllowed =
            runtimeDefaultPathMutationPreparationCloseoutGateAllowed
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

public func buildIgniteRuntimeDefaultPathMutationPreparationCloseoutGateReceipt(
    controlledPreparationFinalizationApplyReceipt: IgniteControlledRuntimeDefaultPathMutationPreparationFinalizationApplyReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationCloseoutGateRequest
): IgniteRuntimeDefaultPathMutationPreparationCloseoutGateReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationCloseoutGateNonClaims()
    if (
        !controlledPreparationFinalizationApplyReceipt
            .controlledRuntimeDefaultPathMutationPreparationFinalizationApplyAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationCloseoutGateReceipt(
            false,
            controlledPreparationFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyAccepted,
            controlledPreparationFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyMode,
            "none",
            request.runtimeDefaultPathMutationPreparationCloseoutGateId,
            controlledPreparationFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId,
            controlledPreparationFinalizationApplyReceipt.runtimeDefaultPathMutationPreparationFinalizationGateId,
            controlledPreparationFinalizationApplyReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryId,
            controlledPreparationFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyId,
            controlledPreparationFinalizationApplyReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateId,
            controlledPreparationFinalizationApplyReceipt.runtimeDefaultPathMutationPreparationCommitDryRunId,
            controlledPreparationFinalizationApplyReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
            controlledPreparationFinalizationApplyReceipt.controlledPreparationApplyId,
            controlledPreparationFinalizationApplyReceipt.preparationApplyGateId,
            controlledPreparationFinalizationApplyReceipt.preparationDryRunId,
            controlledPreparationFinalizationApplyReceipt.preparationBoundaryId,
            controlledPreparationFinalizationApplyReceipt.preparationGateId,
            controlledPreparationFinalizationApplyReceipt.closeoutBoundaryGateId,
            controlledPreparationFinalizationApplyReceipt.closeoutBoundaryId,
            controlledPreparationFinalizationApplyReceipt.closeoutId,
            controlledPreparationFinalizationApplyReceipt,
            false,
            "block",
            "blocked-controlled-runtime-default-path-mutation-preparation-finalization-apply-receipt",
            "collect-accepted-controlled-runtime-default-path-mutation-preparation-finalization-apply-receipt-first",
            ["CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_FINALIZATION_APPLY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0522 controlled runtime default-path mutation preparation finalization apply input before preparation closeout gate work",
            "QUIC must not consume runtime default-path mutation preparation closeout gates from rejected controlled preparation finalization-apply receipts"
        )
    }

    let preparationCloseoutGateMode =
        igniteRuntimeDefaultPathMutationPreparationCloseoutGateModeFor(
            controlledPreparationFinalizationApplyReceipt
                .controlledRuntimeDefaultPathMutationPreparationFinalizationApplyMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationCloseoutGateBlockers(
            request,
            preparationCloseoutGateMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationCloseoutGateReceipt(
            false,
            controlledPreparationFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyAccepted,
            controlledPreparationFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyMode,
            preparationCloseoutGateMode,
            request.runtimeDefaultPathMutationPreparationCloseoutGateId,
            controlledPreparationFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId,
            controlledPreparationFinalizationApplyReceipt.runtimeDefaultPathMutationPreparationFinalizationGateId,
            controlledPreparationFinalizationApplyReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryId,
            controlledPreparationFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyId,
            controlledPreparationFinalizationApplyReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateId,
            controlledPreparationFinalizationApplyReceipt.runtimeDefaultPathMutationPreparationCommitDryRunId,
            controlledPreparationFinalizationApplyReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
            controlledPreparationFinalizationApplyReceipt.controlledPreparationApplyId,
            controlledPreparationFinalizationApplyReceipt.preparationApplyGateId,
            controlledPreparationFinalizationApplyReceipt.preparationDryRunId,
            controlledPreparationFinalizationApplyReceipt.preparationBoundaryId,
            controlledPreparationFinalizationApplyReceipt.preparationGateId,
            controlledPreparationFinalizationApplyReceipt.closeoutBoundaryGateId,
            controlledPreparationFinalizationApplyReceipt.closeoutBoundaryId,
            controlledPreparationFinalizationApplyReceipt.closeoutId,
            controlledPreparationFinalizationApplyReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-closeout-gate-input",
            "fix-runtime-default-path-mutation-preparation-closeout-gate-before-runtime-default-mutation",
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
            "carry preparation closeout gate id, controlled preparation finalization-apply snapshot, runtime default-path mutation lock, preparation closeout gate, closeout review, rollback order, runtime guard plan, observability marker, closeout audit marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation preparation closeout gate blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationPreparationCloseoutGateReceipt(
        true,
        controlledPreparationFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyAccepted,
        controlledPreparationFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyMode,
        preparationCloseoutGateMode,
        request.runtimeDefaultPathMutationPreparationCloseoutGateId,
        controlledPreparationFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId,
        controlledPreparationFinalizationApplyReceipt.runtimeDefaultPathMutationPreparationFinalizationGateId,
        controlledPreparationFinalizationApplyReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryId,
        controlledPreparationFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyId,
        controlledPreparationFinalizationApplyReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateId,
        controlledPreparationFinalizationApplyReceipt.runtimeDefaultPathMutationPreparationCommitDryRunId,
        controlledPreparationFinalizationApplyReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
        controlledPreparationFinalizationApplyReceipt.controlledPreparationApplyId,
        controlledPreparationFinalizationApplyReceipt.preparationApplyGateId,
        controlledPreparationFinalizationApplyReceipt.preparationDryRunId,
        controlledPreparationFinalizationApplyReceipt.preparationBoundaryId,
        controlledPreparationFinalizationApplyReceipt.preparationGateId,
        controlledPreparationFinalizationApplyReceipt.closeoutBoundaryGateId,
        controlledPreparationFinalizationApplyReceipt.closeoutBoundaryId,
        controlledPreparationFinalizationApplyReceipt.closeoutId,
        controlledPreparationFinalizationApplyReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-closeout-gate",
        "accepted-runtime-default-path-mutation-preparation-closeout-gate-receipt",
        "record-runtime-default-path-mutation-preparation-closeout-gate-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation preparation handoff gate without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation closeout gate modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationCloseoutGateModeFor(
    controlledPreparationFinalizationApplyMode: String
): String {
    if (
        controlledPreparationFinalizationApplyMode ==
        "short-controlled-runtime-default-path-mutation-preparation-finalization-apply"
    ) {
        return "short-runtime-default-path-mutation-preparation-closeout-gate"
    }
    if (
        controlledPreparationFinalizationApplyMode ==
        "long-controlled-runtime-default-path-mutation-preparation-finalization-apply"
    ) {
        return "long-runtime-default-path-mutation-preparation-closeout-gate"
    }
    if (
        controlledPreparationFinalizationApplyMode ==
        "blocking-isolation-controlled-runtime-default-path-mutation-preparation-finalization-apply"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-closeout-gate"
    }
    "unknown-runtime-default-path-mutation-preparation-closeout-gate"
}

func igniteRuntimeDefaultPathMutationPreparationCloseoutGateBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationCloseoutGateRequest,
    preparationCloseoutGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationPreparationCloseoutGateId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_CLOSEOUT_GATE_ID_NOT_CARRIED")
    }
    if (!request.controlledPreparationFinalizationApplySnapshotCarried) {
        blockers.add("CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_FINALIZATION_APPLY_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.preparationCloseoutGateCarried) {
        blockers.add("PREPARATION_CLOSEOUT_GATE_NOT_CARRIED")
    }
    if (!request.closeoutReviewCarried) {
        blockers.add("CLOSEOUT_REVIEW_NOT_CARRIED")
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
        preparationCloseoutGateMode ==
        "unknown-runtime-default-path-mutation-preparation-closeout-gate"
    ) {
        blockers.add("UNKNOWN_CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_FINALIZATION_APPLY")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationCloseoutGateNonClaims(): Array<String> {
    igniteControlledRuntimeDefaultPathMutationPreparationFinalizationApplyNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationHandoffGateRequest {
    public let runtimeDefaultPathMutationPreparationHandoffGateId: String
    public let preparationCloseoutGateSnapshotCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let preparationHandoffGateCarried: Bool
    public let handoffReviewCarried: Bool
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
        runtimeDefaultPathMutationPreparationHandoffGateId: String,
        preparationCloseoutGateSnapshotCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        preparationHandoffGateCarried: Bool,
        handoffReviewCarried: Bool,
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
        this.runtimeDefaultPathMutationPreparationHandoffGateId =
            runtimeDefaultPathMutationPreparationHandoffGateId
        this.preparationCloseoutGateSnapshotCarried =
            preparationCloseoutGateSnapshotCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.preparationHandoffGateCarried =
            preparationHandoffGateCarried
        this.handoffReviewCarried = handoffReviewCarried
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

public class IgniteRuntimeDefaultPathMutationPreparationHandoffGateReceipt {
    public let runtimeDefaultPathMutationPreparationHandoffGateAccepted: Bool
    public let runtimeDefaultPathMutationPreparationCloseoutGateAccepted: Bool
    public let runtimeDefaultPathMutationPreparationCloseoutGateMode: String
    public let runtimeDefaultPathMutationPreparationHandoffGateMode: String
    public let runtimeDefaultPathMutationPreparationHandoffGateId: String
    public let runtimeDefaultPathMutationPreparationCloseoutGateId: String
    public let controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId: String
    public let runtimeDefaultPathMutationPreparationFinalizationGateId: String
    public let runtimeDefaultPathMutationPreparationCommitBoundaryId: String
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
    public let preparationCloseoutGateReceipt: IgniteRuntimeDefaultPathMutationPreparationCloseoutGateReceipt
    public let runtimeDefaultPathMutationPreparationHandoffGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationHandoffGateAllowed: Bool
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
        runtimeDefaultPathMutationPreparationHandoffGateAccepted: Bool,
        runtimeDefaultPathMutationPreparationCloseoutGateAccepted: Bool,
        runtimeDefaultPathMutationPreparationCloseoutGateMode: String,
        runtimeDefaultPathMutationPreparationHandoffGateMode: String,
        runtimeDefaultPathMutationPreparationHandoffGateId: String,
        runtimeDefaultPathMutationPreparationCloseoutGateId: String,
        controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId: String,
        runtimeDefaultPathMutationPreparationFinalizationGateId: String,
        runtimeDefaultPathMutationPreparationCommitBoundaryId: String,
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
        preparationCloseoutGateReceipt: IgniteRuntimeDefaultPathMutationPreparationCloseoutGateReceipt,
        runtimeDefaultPathMutationPreparationHandoffGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationHandoffGateAllowed: Bool,
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
        this.runtimeDefaultPathMutationPreparationHandoffGateAccepted =
            runtimeDefaultPathMutationPreparationHandoffGateAccepted
        this.runtimeDefaultPathMutationPreparationCloseoutGateAccepted =
            runtimeDefaultPathMutationPreparationCloseoutGateAccepted
        this.runtimeDefaultPathMutationPreparationCloseoutGateMode =
            runtimeDefaultPathMutationPreparationCloseoutGateMode
        this.runtimeDefaultPathMutationPreparationHandoffGateMode =
            runtimeDefaultPathMutationPreparationHandoffGateMode
        this.runtimeDefaultPathMutationPreparationHandoffGateId =
            runtimeDefaultPathMutationPreparationHandoffGateId
        this.runtimeDefaultPathMutationPreparationCloseoutGateId =
            runtimeDefaultPathMutationPreparationCloseoutGateId
        this.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId =
            controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId
        this.runtimeDefaultPathMutationPreparationFinalizationGateId =
            runtimeDefaultPathMutationPreparationFinalizationGateId
        this.runtimeDefaultPathMutationPreparationCommitBoundaryId =
            runtimeDefaultPathMutationPreparationCommitBoundaryId
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
        this.preparationCloseoutGateReceipt =
            preparationCloseoutGateReceipt
        this.runtimeDefaultPathMutationPreparationHandoffGateRecorded =
            runtimeDefaultPathMutationPreparationHandoffGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationHandoffGateAllowed =
            runtimeDefaultPathMutationPreparationHandoffGateAllowed
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

public func buildIgniteRuntimeDefaultPathMutationPreparationHandoffGateReceipt(
    preparationCloseoutGateReceipt: IgniteRuntimeDefaultPathMutationPreparationCloseoutGateReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationHandoffGateRequest
): IgniteRuntimeDefaultPathMutationPreparationHandoffGateReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationHandoffGateNonClaims()
    if (
        !preparationCloseoutGateReceipt
            .runtimeDefaultPathMutationPreparationCloseoutGateAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationHandoffGateReceipt(
            false,
            preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationCloseoutGateAccepted,
            preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationCloseoutGateMode,
            "none",
            request.runtimeDefaultPathMutationPreparationHandoffGateId,
            preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationCloseoutGateId,
            preparationCloseoutGateReceipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId,
            preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationFinalizationGateId,
            preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryId,
            preparationCloseoutGateReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyId,
            preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateId,
            preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationCommitDryRunId,
            preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
            preparationCloseoutGateReceipt.controlledPreparationApplyId,
            preparationCloseoutGateReceipt.preparationApplyGateId,
            preparationCloseoutGateReceipt.preparationDryRunId,
            preparationCloseoutGateReceipt.preparationBoundaryId,
            preparationCloseoutGateReceipt.preparationGateId,
            preparationCloseoutGateReceipt.closeoutBoundaryGateId,
            preparationCloseoutGateReceipt.closeoutBoundaryId,
            preparationCloseoutGateReceipt.closeoutId,
            preparationCloseoutGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-closeout-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-closeout-gate-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_CLOSEOUT_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0523 runtime default-path mutation preparation closeout gate input before preparation handoff gate work",
            "QUIC must not consume runtime default-path mutation preparation handoff gates from rejected preparation closeout gate receipts"
        )
    }

    let preparationHandoffGateMode =
        igniteRuntimeDefaultPathMutationPreparationHandoffGateModeFor(
            preparationCloseoutGateReceipt
                .runtimeDefaultPathMutationPreparationCloseoutGateMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationHandoffGateBlockers(
            request,
            preparationHandoffGateMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationHandoffGateReceipt(
            false,
            preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationCloseoutGateAccepted,
            preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationCloseoutGateMode,
            preparationHandoffGateMode,
            request.runtimeDefaultPathMutationPreparationHandoffGateId,
            preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationCloseoutGateId,
            preparationCloseoutGateReceipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId,
            preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationFinalizationGateId,
            preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryId,
            preparationCloseoutGateReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyId,
            preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateId,
            preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationCommitDryRunId,
            preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
            preparationCloseoutGateReceipt.controlledPreparationApplyId,
            preparationCloseoutGateReceipt.preparationApplyGateId,
            preparationCloseoutGateReceipt.preparationDryRunId,
            preparationCloseoutGateReceipt.preparationBoundaryId,
            preparationCloseoutGateReceipt.preparationGateId,
            preparationCloseoutGateReceipt.closeoutBoundaryGateId,
            preparationCloseoutGateReceipt.closeoutBoundaryId,
            preparationCloseoutGateReceipt.closeoutId,
            preparationCloseoutGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-handoff-gate-input",
            "fix-runtime-default-path-mutation-preparation-handoff-gate-before-runtime-default-mutation",
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
            "carry preparation handoff gate id, preparation closeout gate snapshot, runtime default-path mutation lock, preparation handoff gate, handoff review, rollback order, runtime guard plan, observability marker, handoff audit marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation preparation handoff gate blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationPreparationHandoffGateReceipt(
        true,
        preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationCloseoutGateAccepted,
        preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationCloseoutGateMode,
        preparationHandoffGateMode,
        request.runtimeDefaultPathMutationPreparationHandoffGateId,
        preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationCloseoutGateId,
        preparationCloseoutGateReceipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId,
        preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationFinalizationGateId,
        preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryId,
        preparationCloseoutGateReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyId,
        preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateId,
        preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationCommitDryRunId,
        preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
        preparationCloseoutGateReceipt.controlledPreparationApplyId,
        preparationCloseoutGateReceipt.preparationApplyGateId,
        preparationCloseoutGateReceipt.preparationDryRunId,
        preparationCloseoutGateReceipt.preparationBoundaryId,
        preparationCloseoutGateReceipt.preparationGateId,
        preparationCloseoutGateReceipt.closeoutBoundaryGateId,
        preparationCloseoutGateReceipt.closeoutBoundaryId,
        preparationCloseoutGateReceipt.closeoutId,
        preparationCloseoutGateReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-handoff-gate",
        "accepted-runtime-default-path-mutation-preparation-handoff-gate-receipt",
        "record-runtime-default-path-mutation-preparation-handoff-gate-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation preparation acceptance boundary without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation handoff gate modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationHandoffGateModeFor(
    preparationCloseoutGateMode: String
): String {
    if (
        preparationCloseoutGateMode ==
        "short-runtime-default-path-mutation-preparation-closeout-gate"
    ) {
        return "short-runtime-default-path-mutation-preparation-handoff-gate"
    }
    if (
        preparationCloseoutGateMode ==
        "long-runtime-default-path-mutation-preparation-closeout-gate"
    ) {
        return "long-runtime-default-path-mutation-preparation-handoff-gate"
    }
    if (
        preparationCloseoutGateMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-closeout-gate"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-handoff-gate"
    }
    "unknown-runtime-default-path-mutation-preparation-handoff-gate"
}

func igniteRuntimeDefaultPathMutationPreparationHandoffGateBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationHandoffGateRequest,
    preparationHandoffGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationPreparationHandoffGateId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_HANDOFF_GATE_ID_NOT_CARRIED")
    }
    if (!request.preparationCloseoutGateSnapshotCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_CLOSEOUT_GATE_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.preparationHandoffGateCarried) {
        blockers.add("PREPARATION_HANDOFF_GATE_NOT_CARRIED")
    }
    if (!request.handoffReviewCarried) {
        blockers.add("HANDOFF_REVIEW_NOT_CARRIED")
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
        preparationHandoffGateMode ==
        "unknown-runtime-default-path-mutation-preparation-handoff-gate"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_CLOSEOUT_GATE")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationHandoffGateNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationCloseoutGateNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationAcceptanceBoundaryRequest {
    public let runtimeDefaultPathMutationPreparationAcceptanceBoundaryId: String
    public let preparationHandoffGateReceiptCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let preparationAcceptanceBoundaryCarried: Bool
    public let downstreamConsumerBoundaryCarried: Bool
    public let rollbackOrderCarried: Bool
    public let runtimeGuardPlanCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let acceptanceAuditMarkerCarried: Bool
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
        runtimeDefaultPathMutationPreparationAcceptanceBoundaryId: String,
        preparationHandoffGateReceiptCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        preparationAcceptanceBoundaryCarried: Bool,
        downstreamConsumerBoundaryCarried: Bool,
        rollbackOrderCarried: Bool,
        runtimeGuardPlanCarried: Bool,
        observabilityMarkerCarried: Bool,
        acceptanceAuditMarkerCarried: Bool,
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
        this.runtimeDefaultPathMutationPreparationAcceptanceBoundaryId =
            runtimeDefaultPathMutationPreparationAcceptanceBoundaryId
        this.preparationHandoffGateReceiptCarried =
            preparationHandoffGateReceiptCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.preparationAcceptanceBoundaryCarried =
            preparationAcceptanceBoundaryCarried
        this.downstreamConsumerBoundaryCarried =
            downstreamConsumerBoundaryCarried
        this.rollbackOrderCarried = rollbackOrderCarried
        this.runtimeGuardPlanCarried = runtimeGuardPlanCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
        this.acceptanceAuditMarkerCarried = acceptanceAuditMarkerCarried
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

public class IgniteRuntimeDefaultPathMutationPreparationAcceptanceBoundaryReceipt {
    public let runtimeDefaultPathMutationPreparationAcceptanceBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationPreparationHandoffGateAccepted: Bool
    public let runtimeDefaultPathMutationPreparationHandoffGateMode: String
    public let runtimeDefaultPathMutationPreparationAcceptanceBoundaryMode: String
    public let runtimeDefaultPathMutationPreparationAcceptanceBoundaryId: String
    public let runtimeDefaultPathMutationPreparationHandoffGateId: String
    public let runtimeDefaultPathMutationPreparationCloseoutGateId: String
    public let controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId: String
    public let runtimeDefaultPathMutationPreparationFinalizationGateId: String
    public let runtimeDefaultPathMutationPreparationCommitBoundaryId: String
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
    public let preparationHandoffGateReceipt: IgniteRuntimeDefaultPathMutationPreparationHandoffGateReceipt
    public let runtimeDefaultPathMutationPreparationAcceptanceBoundaryRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationAcceptanceBoundaryAllowed: Bool
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
        runtimeDefaultPathMutationPreparationAcceptanceBoundaryAccepted: Bool,
        runtimeDefaultPathMutationPreparationHandoffGateAccepted: Bool,
        runtimeDefaultPathMutationPreparationHandoffGateMode: String,
        runtimeDefaultPathMutationPreparationAcceptanceBoundaryMode: String,
        runtimeDefaultPathMutationPreparationAcceptanceBoundaryId: String,
        runtimeDefaultPathMutationPreparationHandoffGateId: String,
        runtimeDefaultPathMutationPreparationCloseoutGateId: String,
        controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId: String,
        runtimeDefaultPathMutationPreparationFinalizationGateId: String,
        runtimeDefaultPathMutationPreparationCommitBoundaryId: String,
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
        preparationHandoffGateReceipt: IgniteRuntimeDefaultPathMutationPreparationHandoffGateReceipt,
        runtimeDefaultPathMutationPreparationAcceptanceBoundaryRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationAcceptanceBoundaryAllowed: Bool,
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
        this.runtimeDefaultPathMutationPreparationAcceptanceBoundaryAccepted =
            runtimeDefaultPathMutationPreparationAcceptanceBoundaryAccepted
        this.runtimeDefaultPathMutationPreparationHandoffGateAccepted =
            runtimeDefaultPathMutationPreparationHandoffGateAccepted
        this.runtimeDefaultPathMutationPreparationHandoffGateMode =
            runtimeDefaultPathMutationPreparationHandoffGateMode
        this.runtimeDefaultPathMutationPreparationAcceptanceBoundaryMode =
            runtimeDefaultPathMutationPreparationAcceptanceBoundaryMode
        this.runtimeDefaultPathMutationPreparationAcceptanceBoundaryId =
            runtimeDefaultPathMutationPreparationAcceptanceBoundaryId
        this.runtimeDefaultPathMutationPreparationHandoffGateId =
            runtimeDefaultPathMutationPreparationHandoffGateId
        this.runtimeDefaultPathMutationPreparationCloseoutGateId =
            runtimeDefaultPathMutationPreparationCloseoutGateId
        this.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId =
            controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId
        this.runtimeDefaultPathMutationPreparationFinalizationGateId =
            runtimeDefaultPathMutationPreparationFinalizationGateId
        this.runtimeDefaultPathMutationPreparationCommitBoundaryId =
            runtimeDefaultPathMutationPreparationCommitBoundaryId
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
        this.preparationHandoffGateReceipt =
            preparationHandoffGateReceipt
        this.runtimeDefaultPathMutationPreparationAcceptanceBoundaryRecorded =
            runtimeDefaultPathMutationPreparationAcceptanceBoundaryRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationAcceptanceBoundaryAllowed =
            runtimeDefaultPathMutationPreparationAcceptanceBoundaryAllowed
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

public func buildIgniteRuntimeDefaultPathMutationPreparationAcceptanceBoundaryReceipt(
    preparationHandoffGateReceipt: IgniteRuntimeDefaultPathMutationPreparationHandoffGateReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationAcceptanceBoundaryRequest
): IgniteRuntimeDefaultPathMutationPreparationAcceptanceBoundaryReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationAcceptanceBoundaryNonClaims()
    if (
        !preparationHandoffGateReceipt
            .runtimeDefaultPathMutationPreparationHandoffGateAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationAcceptanceBoundaryReceipt(
            false,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationHandoffGateAccepted,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationHandoffGateMode,
            "none",
            request.runtimeDefaultPathMutationPreparationAcceptanceBoundaryId,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationHandoffGateId,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationCloseoutGateId,
            preparationHandoffGateReceipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationFinalizationGateId,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryId,
            preparationHandoffGateReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyId,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateId,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationCommitDryRunId,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
            preparationHandoffGateReceipt.controlledPreparationApplyId,
            preparationHandoffGateReceipt.preparationApplyGateId,
            preparationHandoffGateReceipt.preparationDryRunId,
            preparationHandoffGateReceipt.preparationBoundaryId,
            preparationHandoffGateReceipt.preparationGateId,
            preparationHandoffGateReceipt.closeoutBoundaryGateId,
            preparationHandoffGateReceipt.closeoutBoundaryId,
            preparationHandoffGateReceipt.closeoutId,
            preparationHandoffGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-handoff-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-handoff-gate-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_HANDOFF_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0524 runtime default-path mutation preparation handoff gate input before preparation acceptance boundary work",
            "QUIC must not consume runtime default-path mutation preparation acceptance-boundary receipts from rejected preparation handoff-gate receipts"
        )
    }

    let preparationAcceptanceBoundaryMode =
        igniteRuntimeDefaultPathMutationPreparationAcceptanceBoundaryModeFor(
            preparationHandoffGateReceipt
                .runtimeDefaultPathMutationPreparationHandoffGateMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationAcceptanceBoundaryBlockers(
            request,
            preparationAcceptanceBoundaryMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationAcceptanceBoundaryReceipt(
            false,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationHandoffGateAccepted,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationHandoffGateMode,
            preparationAcceptanceBoundaryMode,
            request.runtimeDefaultPathMutationPreparationAcceptanceBoundaryId,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationHandoffGateId,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationCloseoutGateId,
            preparationHandoffGateReceipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationFinalizationGateId,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryId,
            preparationHandoffGateReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyId,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateId,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationCommitDryRunId,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
            preparationHandoffGateReceipt.controlledPreparationApplyId,
            preparationHandoffGateReceipt.preparationApplyGateId,
            preparationHandoffGateReceipt.preparationDryRunId,
            preparationHandoffGateReceipt.preparationBoundaryId,
            preparationHandoffGateReceipt.preparationGateId,
            preparationHandoffGateReceipt.closeoutBoundaryGateId,
            preparationHandoffGateReceipt.closeoutBoundaryId,
            preparationHandoffGateReceipt.closeoutId,
            preparationHandoffGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-acceptance-boundary-input",
            "fix-runtime-default-path-mutation-preparation-acceptance-boundary-before-runtime-default-mutation",
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
            "carry preparation acceptance boundary id, preparation handoff-gate receipt, runtime default-path mutation lock, preparation acceptance boundary, downstream consumer boundary, rollback order, runtime guard plan, observability marker, acceptance audit marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation preparation acceptance-boundary blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationPreparationAcceptanceBoundaryReceipt(
        true,
        preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationHandoffGateAccepted,
        preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationHandoffGateMode,
        preparationAcceptanceBoundaryMode,
        request.runtimeDefaultPathMutationPreparationAcceptanceBoundaryId,
        preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationHandoffGateId,
        preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationCloseoutGateId,
        preparationHandoffGateReceipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId,
        preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationFinalizationGateId,
        preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryId,
        preparationHandoffGateReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyId,
        preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateId,
        preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationCommitDryRunId,
        preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
        preparationHandoffGateReceipt.controlledPreparationApplyId,
        preparationHandoffGateReceipt.preparationApplyGateId,
        preparationHandoffGateReceipt.preparationDryRunId,
        preparationHandoffGateReceipt.preparationBoundaryId,
        preparationHandoffGateReceipt.preparationGateId,
        preparationHandoffGateReceipt.closeoutBoundaryGateId,
        preparationHandoffGateReceipt.closeoutBoundaryId,
        preparationHandoffGateReceipt.closeoutId,
        preparationHandoffGateReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-acceptance-boundary",
        "accepted-runtime-default-path-mutation-preparation-acceptance-boundary-receipt",
        "record-runtime-default-path-mutation-preparation-acceptance-boundary-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation preparation apply boundary without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation acceptance-boundary modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationAcceptanceBoundaryModeFor(
    preparationHandoffGateMode: String
): String {
    if (
        preparationHandoffGateMode ==
        "short-runtime-default-path-mutation-preparation-handoff-gate"
    ) {
        return "short-runtime-default-path-mutation-preparation-acceptance-boundary"
    }
    if (
        preparationHandoffGateMode ==
        "long-runtime-default-path-mutation-preparation-handoff-gate"
    ) {
        return "long-runtime-default-path-mutation-preparation-acceptance-boundary"
    }
    if (
        preparationHandoffGateMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-handoff-gate"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-acceptance-boundary"
    }
    "unknown-runtime-default-path-mutation-preparation-acceptance-boundary"
}

func igniteRuntimeDefaultPathMutationPreparationAcceptanceBoundaryBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationAcceptanceBoundaryRequest,
    preparationAcceptanceBoundaryMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationPreparationAcceptanceBoundaryId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_ACCEPTANCE_BOUNDARY_ID_NOT_CARRIED")
    }
    if (!request.preparationHandoffGateReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_HANDOFF_GATE_RECEIPT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.preparationAcceptanceBoundaryCarried) {
        blockers.add("PREPARATION_ACCEPTANCE_BOUNDARY_NOT_CARRIED")
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
    if (!request.acceptanceAuditMarkerCarried) {
        blockers.add("ACCEPTANCE_AUDIT_MARKER_NOT_CARRIED")
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
        preparationAcceptanceBoundaryMode ==
        "unknown-runtime-default-path-mutation-preparation-acceptance-boundary"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_HANDOFF_GATE")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationAcceptanceBoundaryNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationHandoffGateNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationApplyBoundaryRequest {
    public let runtimeDefaultPathMutationPreparationApplyBoundaryId: String
    public let preparationAcceptanceBoundaryReceiptCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let preparationApplyBoundaryCarried: Bool
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
        runtimeDefaultPathMutationPreparationApplyBoundaryId: String,
        preparationAcceptanceBoundaryReceiptCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        preparationApplyBoundaryCarried: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyBoundaryId =
            runtimeDefaultPathMutationPreparationApplyBoundaryId
        this.preparationAcceptanceBoundaryReceiptCarried =
            preparationAcceptanceBoundaryReceiptCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.preparationApplyBoundaryCarried =
            preparationApplyBoundaryCarried
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

public class IgniteRuntimeDefaultPathMutationPreparationApplyBoundaryReceipt {
    public let runtimeDefaultPathMutationPreparationApplyBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationPreparationAcceptanceBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationPreparationAcceptanceBoundaryMode: String
    public let runtimeDefaultPathMutationPreparationApplyBoundaryMode: String
    public let runtimeDefaultPathMutationPreparationApplyBoundaryId: String
    public let runtimeDefaultPathMutationPreparationAcceptanceBoundaryId: String
    public let runtimeDefaultPathMutationPreparationHandoffGateId: String
    public let runtimeDefaultPathMutationPreparationCloseoutGateId: String
    public let controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId: String
    public let runtimeDefaultPathMutationPreparationFinalizationGateId: String
    public let runtimeDefaultPathMutationPreparationCommitBoundaryId: String
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
    public let preparationAcceptanceBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationAcceptanceBoundaryReceipt
    public let runtimeDefaultPathMutationPreparationApplyBoundaryRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationApplyBoundaryAllowed: Bool
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
        runtimeDefaultPathMutationPreparationApplyBoundaryAccepted: Bool,
        runtimeDefaultPathMutationPreparationAcceptanceBoundaryAccepted: Bool,
        runtimeDefaultPathMutationPreparationAcceptanceBoundaryMode: String,
        runtimeDefaultPathMutationPreparationApplyBoundaryMode: String,
        runtimeDefaultPathMutationPreparationApplyBoundaryId: String,
        runtimeDefaultPathMutationPreparationAcceptanceBoundaryId: String,
        runtimeDefaultPathMutationPreparationHandoffGateId: String,
        runtimeDefaultPathMutationPreparationCloseoutGateId: String,
        controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId: String,
        runtimeDefaultPathMutationPreparationFinalizationGateId: String,
        runtimeDefaultPathMutationPreparationCommitBoundaryId: String,
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
        preparationAcceptanceBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationAcceptanceBoundaryReceipt,
        runtimeDefaultPathMutationPreparationApplyBoundaryRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationApplyBoundaryAllowed: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyBoundaryAccepted =
            runtimeDefaultPathMutationPreparationApplyBoundaryAccepted
        this.runtimeDefaultPathMutationPreparationAcceptanceBoundaryAccepted =
            runtimeDefaultPathMutationPreparationAcceptanceBoundaryAccepted
        this.runtimeDefaultPathMutationPreparationAcceptanceBoundaryMode =
            runtimeDefaultPathMutationPreparationAcceptanceBoundaryMode
        this.runtimeDefaultPathMutationPreparationApplyBoundaryMode =
            runtimeDefaultPathMutationPreparationApplyBoundaryMode
        this.runtimeDefaultPathMutationPreparationApplyBoundaryId =
            runtimeDefaultPathMutationPreparationApplyBoundaryId
        this.runtimeDefaultPathMutationPreparationAcceptanceBoundaryId =
            runtimeDefaultPathMutationPreparationAcceptanceBoundaryId
        this.runtimeDefaultPathMutationPreparationHandoffGateId =
            runtimeDefaultPathMutationPreparationHandoffGateId
        this.runtimeDefaultPathMutationPreparationCloseoutGateId =
            runtimeDefaultPathMutationPreparationCloseoutGateId
        this.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId =
            controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId
        this.runtimeDefaultPathMutationPreparationFinalizationGateId =
            runtimeDefaultPathMutationPreparationFinalizationGateId
        this.runtimeDefaultPathMutationPreparationCommitBoundaryId =
            runtimeDefaultPathMutationPreparationCommitBoundaryId
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
        this.preparationAcceptanceBoundaryReceipt =
            preparationAcceptanceBoundaryReceipt
        this.runtimeDefaultPathMutationPreparationApplyBoundaryRecorded =
            runtimeDefaultPathMutationPreparationApplyBoundaryRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationApplyBoundaryAllowed =
            runtimeDefaultPathMutationPreparationApplyBoundaryAllowed
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

public func buildIgniteRuntimeDefaultPathMutationPreparationApplyBoundaryReceipt(
    preparationAcceptanceBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationAcceptanceBoundaryReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationApplyBoundaryRequest
): IgniteRuntimeDefaultPathMutationPreparationApplyBoundaryReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationApplyBoundaryNonClaims()
    if (
        !preparationAcceptanceBoundaryReceipt
            .runtimeDefaultPathMutationPreparationAcceptanceBoundaryAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyBoundaryReceipt(
            false,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationAcceptanceBoundaryAccepted,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationAcceptanceBoundaryMode,
            "none",
            request.runtimeDefaultPathMutationPreparationApplyBoundaryId,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationAcceptanceBoundaryId,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationHandoffGateId,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationCloseoutGateId,
            preparationAcceptanceBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationFinalizationGateId,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryId,
            preparationAcceptanceBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyId,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateId,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitDryRunId,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
            preparationAcceptanceBoundaryReceipt.controlledPreparationApplyId,
            preparationAcceptanceBoundaryReceipt.preparationApplyGateId,
            preparationAcceptanceBoundaryReceipt.preparationDryRunId,
            preparationAcceptanceBoundaryReceipt.preparationBoundaryId,
            preparationAcceptanceBoundaryReceipt.preparationGateId,
            preparationAcceptanceBoundaryReceipt.closeoutBoundaryGateId,
            preparationAcceptanceBoundaryReceipt.closeoutBoundaryId,
            preparationAcceptanceBoundaryReceipt.closeoutId,
            preparationAcceptanceBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-acceptance-boundary-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-acceptance-boundary-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_ACCEPTANCE_BOUNDARY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0525 runtime default-path mutation preparation acceptance boundary input before preparation apply-boundary work",
            "QUIC must not consume runtime default-path mutation preparation apply-boundary receipts from rejected preparation acceptance-boundary receipts"
        )
    }

    let preparationApplyBoundaryMode =
        igniteRuntimeDefaultPathMutationPreparationApplyBoundaryModeFor(
            preparationAcceptanceBoundaryReceipt
                .runtimeDefaultPathMutationPreparationAcceptanceBoundaryMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationApplyBoundaryBlockers(
            request,
            preparationApplyBoundaryMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyBoundaryReceipt(
            false,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationAcceptanceBoundaryAccepted,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationAcceptanceBoundaryMode,
            preparationApplyBoundaryMode,
            request.runtimeDefaultPathMutationPreparationApplyBoundaryId,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationAcceptanceBoundaryId,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationHandoffGateId,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationCloseoutGateId,
            preparationAcceptanceBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationFinalizationGateId,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryId,
            preparationAcceptanceBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyId,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateId,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitDryRunId,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
            preparationAcceptanceBoundaryReceipt.controlledPreparationApplyId,
            preparationAcceptanceBoundaryReceipt.preparationApplyGateId,
            preparationAcceptanceBoundaryReceipt.preparationDryRunId,
            preparationAcceptanceBoundaryReceipt.preparationBoundaryId,
            preparationAcceptanceBoundaryReceipt.preparationGateId,
            preparationAcceptanceBoundaryReceipt.closeoutBoundaryGateId,
            preparationAcceptanceBoundaryReceipt.closeoutBoundaryId,
            preparationAcceptanceBoundaryReceipt.closeoutId,
            preparationAcceptanceBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-boundary-input",
            "fix-runtime-default-path-mutation-preparation-apply-boundary-before-runtime-default-mutation",
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
            "carry preparation apply-boundary id, preparation acceptance-boundary receipt, runtime default-path mutation lock, preparation apply boundary, downstream consumer boundary, rollback order, runtime guard plan, observability marker, apply audit marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation preparation apply-boundary blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationPreparationApplyBoundaryReceipt(
        true,
        preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationAcceptanceBoundaryAccepted,
        preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationAcceptanceBoundaryMode,
        preparationApplyBoundaryMode,
        request.runtimeDefaultPathMutationPreparationApplyBoundaryId,
        preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationAcceptanceBoundaryId,
        preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationHandoffGateId,
        preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationCloseoutGateId,
        preparationAcceptanceBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId,
        preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationFinalizationGateId,
        preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryId,
        preparationAcceptanceBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyId,
        preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateId,
        preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitDryRunId,
        preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
        preparationAcceptanceBoundaryReceipt.controlledPreparationApplyId,
        preparationAcceptanceBoundaryReceipt.preparationApplyGateId,
        preparationAcceptanceBoundaryReceipt.preparationDryRunId,
        preparationAcceptanceBoundaryReceipt.preparationBoundaryId,
        preparationAcceptanceBoundaryReceipt.preparationGateId,
        preparationAcceptanceBoundaryReceipt.closeoutBoundaryGateId,
        preparationAcceptanceBoundaryReceipt.closeoutBoundaryId,
        preparationAcceptanceBoundaryReceipt.closeoutId,
        preparationAcceptanceBoundaryReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-apply-boundary",
        "accepted-runtime-default-path-mutation-preparation-apply-boundary-receipt",
        "record-runtime-default-path-mutation-preparation-apply-boundary-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation preparation apply dry-run without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation apply-boundary modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationApplyBoundaryModeFor(
    preparationAcceptanceBoundaryMode: String
): String {
    if (
        preparationAcceptanceBoundaryMode ==
        "short-runtime-default-path-mutation-preparation-acceptance-boundary"
    ) {
        return "short-runtime-default-path-mutation-preparation-apply-boundary"
    }
    if (
        preparationAcceptanceBoundaryMode ==
        "long-runtime-default-path-mutation-preparation-acceptance-boundary"
    ) {
        return "long-runtime-default-path-mutation-preparation-apply-boundary"
    }
    if (
        preparationAcceptanceBoundaryMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-acceptance-boundary"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-apply-boundary"
    }
    "unknown-runtime-default-path-mutation-preparation-apply-boundary"
}

func igniteRuntimeDefaultPathMutationPreparationApplyBoundaryBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationApplyBoundaryRequest,
    preparationApplyBoundaryMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationPreparationApplyBoundaryId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_BOUNDARY_ID_NOT_CARRIED")
    }
    if (!request.preparationAcceptanceBoundaryReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_ACCEPTANCE_BOUNDARY_RECEIPT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.preparationApplyBoundaryCarried) {
        blockers.add("PREPARATION_APPLY_BOUNDARY_NOT_CARRIED")
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
        preparationApplyBoundaryMode ==
        "unknown-runtime-default-path-mutation-preparation-apply-boundary"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_ACCEPTANCE_BOUNDARY")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationApplyBoundaryNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationAcceptanceBoundaryNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunRequest {
    public let runtimeDefaultPathMutationPreparationApplyDryRunId: String
    public let preparationApplyBoundaryReceiptCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let preparationApplyDryRunCarried: Bool
    public let stagedPreparationApplyPlanCarried: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunId: String,
        preparationApplyBoundaryReceiptCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        preparationApplyDryRunCarried: Bool,
        stagedPreparationApplyPlanCarried: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunId =
            runtimeDefaultPathMutationPreparationApplyDryRunId
        this.preparationApplyBoundaryReceiptCarried =
            preparationApplyBoundaryReceiptCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.preparationApplyDryRunCarried =
            preparationApplyDryRunCarried
        this.stagedPreparationApplyPlanCarried =
            stagedPreparationApplyPlanCarried
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

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunReceipt {
    public let runtimeDefaultPathMutationPreparationApplyDryRunAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyBoundaryMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunId: String
    public let runtimeDefaultPathMutationPreparationApplyBoundaryId: String
    public let runtimeDefaultPathMutationPreparationAcceptanceBoundaryId: String
    public let runtimeDefaultPathMutationPreparationHandoffGateId: String
    public let runtimeDefaultPathMutationPreparationCloseoutGateId: String
    public let controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId: String
    public let runtimeDefaultPathMutationPreparationFinalizationGateId: String
    public let runtimeDefaultPathMutationPreparationCommitBoundaryId: String
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
    public let preparationApplyBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyBoundaryReceipt
    public let runtimeDefaultPathMutationPreparationApplyDryRunRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationApplyDryRunAllowed: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyBoundaryAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyBoundaryMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunId: String,
        runtimeDefaultPathMutationPreparationApplyBoundaryId: String,
        runtimeDefaultPathMutationPreparationAcceptanceBoundaryId: String,
        runtimeDefaultPathMutationPreparationHandoffGateId: String,
        runtimeDefaultPathMutationPreparationCloseoutGateId: String,
        controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId: String,
        runtimeDefaultPathMutationPreparationFinalizationGateId: String,
        runtimeDefaultPathMutationPreparationCommitBoundaryId: String,
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
        preparationApplyBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyBoundaryReceipt,
        runtimeDefaultPathMutationPreparationApplyDryRunRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationApplyDryRunAllowed: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunAccepted
        this.runtimeDefaultPathMutationPreparationApplyBoundaryAccepted =
            runtimeDefaultPathMutationPreparationApplyBoundaryAccepted
        this.runtimeDefaultPathMutationPreparationApplyBoundaryMode =
            runtimeDefaultPathMutationPreparationApplyBoundaryMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunMode =
            runtimeDefaultPathMutationPreparationApplyDryRunMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunId =
            runtimeDefaultPathMutationPreparationApplyDryRunId
        this.runtimeDefaultPathMutationPreparationApplyBoundaryId =
            runtimeDefaultPathMutationPreparationApplyBoundaryId
        this.runtimeDefaultPathMutationPreparationAcceptanceBoundaryId =
            runtimeDefaultPathMutationPreparationAcceptanceBoundaryId
        this.runtimeDefaultPathMutationPreparationHandoffGateId =
            runtimeDefaultPathMutationPreparationHandoffGateId
        this.runtimeDefaultPathMutationPreparationCloseoutGateId =
            runtimeDefaultPathMutationPreparationCloseoutGateId
        this.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId =
            controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId
        this.runtimeDefaultPathMutationPreparationFinalizationGateId =
            runtimeDefaultPathMutationPreparationFinalizationGateId
        this.runtimeDefaultPathMutationPreparationCommitBoundaryId =
            runtimeDefaultPathMutationPreparationCommitBoundaryId
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
        this.preparationApplyBoundaryReceipt =
            preparationApplyBoundaryReceipt
        this.runtimeDefaultPathMutationPreparationApplyDryRunRecorded =
            runtimeDefaultPathMutationPreparationApplyDryRunRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationApplyDryRunAllowed =
            runtimeDefaultPathMutationPreparationApplyDryRunAllowed
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

public func buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunReceipt(
    preparationApplyBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyBoundaryReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunRequest
): IgniteRuntimeDefaultPathMutationPreparationApplyDryRunReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunNonClaims()
    if (
        !preparationApplyBoundaryReceipt
            .runtimeDefaultPathMutationPreparationApplyBoundaryAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunReceipt(
            false,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyBoundaryAccepted,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyBoundaryMode,
            "none",
            request.runtimeDefaultPathMutationPreparationApplyDryRunId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyBoundaryId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationAcceptanceBoundaryId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationHandoffGateId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationCloseoutGateId,
            preparationApplyBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationFinalizationGateId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryId,
            preparationApplyBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitDryRunId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
            preparationApplyBoundaryReceipt.controlledPreparationApplyId,
            preparationApplyBoundaryReceipt.preparationApplyGateId,
            preparationApplyBoundaryReceipt.preparationDryRunId,
            preparationApplyBoundaryReceipt.preparationBoundaryId,
            preparationApplyBoundaryReceipt.preparationGateId,
            preparationApplyBoundaryReceipt.closeoutBoundaryGateId,
            preparationApplyBoundaryReceipt.closeoutBoundaryId,
            preparationApplyBoundaryReceipt.closeoutId,
            preparationApplyBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-boundary-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-apply-boundary-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_BOUNDARY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0526 runtime default-path mutation preparation apply boundary input before preparation apply dry-run work",
            "QUIC must not consume runtime default-path mutation preparation apply dry-run receipts from rejected preparation apply-boundary receipts"
        )
    }

    let preparationApplyDryRunMode =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunModeFor(
            preparationApplyBoundaryReceipt
                .runtimeDefaultPathMutationPreparationApplyBoundaryMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunBlockers(
            request,
            preparationApplyDryRunMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunReceipt(
            false,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyBoundaryAccepted,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyBoundaryMode,
            preparationApplyDryRunMode,
            request.runtimeDefaultPathMutationPreparationApplyDryRunId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyBoundaryId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationAcceptanceBoundaryId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationHandoffGateId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationCloseoutGateId,
            preparationApplyBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationFinalizationGateId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryId,
            preparationApplyBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitDryRunId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
            preparationApplyBoundaryReceipt.controlledPreparationApplyId,
            preparationApplyBoundaryReceipt.preparationApplyGateId,
            preparationApplyBoundaryReceipt.preparationDryRunId,
            preparationApplyBoundaryReceipt.preparationBoundaryId,
            preparationApplyBoundaryReceipt.preparationGateId,
            preparationApplyBoundaryReceipt.closeoutBoundaryGateId,
            preparationApplyBoundaryReceipt.closeoutBoundaryId,
            preparationApplyBoundaryReceipt.closeoutId,
            preparationApplyBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-input",
            "fix-runtime-default-path-mutation-preparation-apply-dry-run-before-runtime-default-mutation",
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
            "carry preparation apply-dry-run id, preparation apply-boundary receipt, runtime default-path mutation lock, preparation apply dry-run marker, staged preparation apply plan, rollback preview, runtime guard plan, observability marker, apply audit marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation preparation apply dry-run blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationPreparationApplyDryRunReceipt(
        true,
        preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyBoundaryAccepted,
        preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyBoundaryMode,
        preparationApplyDryRunMode,
        request.runtimeDefaultPathMutationPreparationApplyDryRunId,
        preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyBoundaryId,
        preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationAcceptanceBoundaryId,
        preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationHandoffGateId,
        preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationCloseoutGateId,
        preparationApplyBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId,
        preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationFinalizationGateId,
        preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryId,
        preparationApplyBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyId,
        preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateId,
        preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitDryRunId,
        preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
        preparationApplyBoundaryReceipt.controlledPreparationApplyId,
        preparationApplyBoundaryReceipt.preparationApplyGateId,
        preparationApplyBoundaryReceipt.preparationDryRunId,
        preparationApplyBoundaryReceipt.preparationBoundaryId,
        preparationApplyBoundaryReceipt.preparationGateId,
        preparationApplyBoundaryReceipt.closeoutBoundaryGateId,
        preparationApplyBoundaryReceipt.closeoutBoundaryId,
        preparationApplyBoundaryReceipt.closeoutId,
        preparationApplyBoundaryReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-apply-dry-run",
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-receipt",
        "record-runtime-default-path-mutation-preparation-apply-dry-run-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation preparation apply gate without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation apply dry-run modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunModeFor(
    preparationApplyBoundaryMode: String
): String {
    if (
        preparationApplyBoundaryMode ==
        "short-runtime-default-path-mutation-preparation-apply-boundary"
    ) {
        return "short-runtime-default-path-mutation-preparation-apply-dry-run"
    }
    if (
        preparationApplyBoundaryMode ==
        "long-runtime-default-path-mutation-preparation-apply-boundary"
    ) {
        return "long-runtime-default-path-mutation-preparation-apply-dry-run"
    }
    if (
        preparationApplyBoundaryMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-boundary"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run"
    }
    "unknown-runtime-default-path-mutation-preparation-apply-dry-run"
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunRequest,
    preparationApplyDryRunMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationPreparationApplyDryRunId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_ID_NOT_CARRIED")
    }
    if (!request.preparationApplyBoundaryReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_BOUNDARY_RECEIPT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.preparationApplyDryRunCarried) {
        blockers.add("PREPARATION_APPLY_DRY_RUN_NOT_CARRIED")
    }
    if (!request.stagedPreparationApplyPlanCarried) {
        blockers.add("STAGED_PREPARATION_APPLY_PLAN_NOT_CARRIED")
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
        preparationApplyDryRunMode ==
        "unknown-runtime-default-path-mutation-preparation-apply-dry-run"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_BOUNDARY")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationApplyBoundaryNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunGateRequest {
    public let runtimeDefaultPathMutationPreparationApplyDryRunGateId: String
    public let preparationApplyDryRunReceiptCarried: Bool
    public let applyDryRunReviewCarried: Bool
    public let preparationApplyDryRunGateMarkerCarried: Bool
    public let stagedApplyReadinessCarried: Bool
    public let rollbackApplyGateCarried: Bool
    public let runtimeGuardApplyGateCarried: Bool
    public let observabilityApplyGateMarkerCarried: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunGateId: String,
        preparationApplyDryRunReceiptCarried: Bool,
        applyDryRunReviewCarried: Bool,
        preparationApplyDryRunGateMarkerCarried: Bool,
        stagedApplyReadinessCarried: Bool,
        rollbackApplyGateCarried: Bool,
        runtimeGuardApplyGateCarried: Bool,
        observabilityApplyGateMarkerCarried: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunGateId
        this.preparationApplyDryRunReceiptCarried =
            preparationApplyDryRunReceiptCarried
        this.applyDryRunReviewCarried = applyDryRunReviewCarried
        this.preparationApplyDryRunGateMarkerCarried =
            preparationApplyDryRunGateMarkerCarried
        this.stagedApplyReadinessCarried = stagedApplyReadinessCarried
        this.rollbackApplyGateCarried = rollbackApplyGateCarried
        this.runtimeGuardApplyGateCarried = runtimeGuardApplyGateCarried
        this.observabilityApplyGateMarkerCarried =
            observabilityApplyGateMarkerCarried
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

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunGateReceipt {
    public let runtimeDefaultPathMutationPreparationApplyDryRunGateAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunGateMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunId: String
    public let runtimeDefaultPathMutationPreparationApplyBoundaryId: String
    public let runtimeDefaultPathMutationPreparationAcceptanceBoundaryId: String
    public let runtimeDefaultPathMutationPreparationHandoffGateId: String
    public let runtimeDefaultPathMutationPreparationCloseoutGateId: String
    public let controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId: String
    public let runtimeDefaultPathMutationPreparationFinalizationGateId: String
    public let runtimeDefaultPathMutationPreparationCommitBoundaryId: String
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
    public let preparationApplyDryRunReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunReceipt
    public let runtimeDefaultPathMutationPreparationApplyDryRunGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationApplyDryRunGateAllowed: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunGateAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunGateMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunId: String,
        runtimeDefaultPathMutationPreparationApplyBoundaryId: String,
        runtimeDefaultPathMutationPreparationAcceptanceBoundaryId: String,
        runtimeDefaultPathMutationPreparationHandoffGateId: String,
        runtimeDefaultPathMutationPreparationCloseoutGateId: String,
        controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId: String,
        runtimeDefaultPathMutationPreparationFinalizationGateId: String,
        runtimeDefaultPathMutationPreparationCommitBoundaryId: String,
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
        preparationApplyDryRunReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunReceipt,
        runtimeDefaultPathMutationPreparationApplyDryRunGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationApplyDryRunGateAllowed: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunGateAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunGateAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunMode =
            runtimeDefaultPathMutationPreparationApplyDryRunMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunGateMode =
            runtimeDefaultPathMutationPreparationApplyDryRunGateMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunId =
            runtimeDefaultPathMutationPreparationApplyDryRunId
        this.runtimeDefaultPathMutationPreparationApplyBoundaryId =
            runtimeDefaultPathMutationPreparationApplyBoundaryId
        this.runtimeDefaultPathMutationPreparationAcceptanceBoundaryId =
            runtimeDefaultPathMutationPreparationAcceptanceBoundaryId
        this.runtimeDefaultPathMutationPreparationHandoffGateId =
            runtimeDefaultPathMutationPreparationHandoffGateId
        this.runtimeDefaultPathMutationPreparationCloseoutGateId =
            runtimeDefaultPathMutationPreparationCloseoutGateId
        this.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId =
            controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId
        this.runtimeDefaultPathMutationPreparationFinalizationGateId =
            runtimeDefaultPathMutationPreparationFinalizationGateId
        this.runtimeDefaultPathMutationPreparationCommitBoundaryId =
            runtimeDefaultPathMutationPreparationCommitBoundaryId
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
        this.preparationApplyDryRunReceipt = preparationApplyDryRunReceipt
        this.runtimeDefaultPathMutationPreparationApplyDryRunGateRecorded =
            runtimeDefaultPathMutationPreparationApplyDryRunGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationApplyDryRunGateAllowed =
            runtimeDefaultPathMutationPreparationApplyDryRunGateAllowed
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

public func buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunGateReceipt(
    preparationApplyDryRunReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunGateRequest
): IgniteRuntimeDefaultPathMutationPreparationApplyDryRunGateReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunGateNonClaims()
    if (
        !preparationApplyDryRunReceipt
            .runtimeDefaultPathMutationPreparationApplyDryRunAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunGateReceipt(
            false,
            preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAccepted,
            preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunMode,
            "none",
            request.runtimeDefaultPathMutationPreparationApplyDryRunGateId,
            preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunId,
            preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationApplyBoundaryId,
            preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationAcceptanceBoundaryId,
            preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationHandoffGateId,
            preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationCloseoutGateId,
            preparationApplyDryRunReceipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId,
            preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationFinalizationGateId,
            preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryId,
            preparationApplyDryRunReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyId,
            preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateId,
            preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationCommitDryRunId,
            preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
            preparationApplyDryRunReceipt.controlledPreparationApplyId,
            preparationApplyDryRunReceipt.preparationApplyGateId,
            preparationApplyDryRunReceipt.preparationDryRunId,
            preparationApplyDryRunReceipt.preparationBoundaryId,
            preparationApplyDryRunReceipt.preparationGateId,
            preparationApplyDryRunReceipt.closeoutBoundaryGateId,
            preparationApplyDryRunReceipt.closeoutBoundaryId,
            preparationApplyDryRunReceipt.closeoutId,
            preparationApplyDryRunReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-apply-dry-run-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0527 runtime default-path mutation preparation apply dry-run input before preparation apply dry-run gate work",
            "QUIC must not consume runtime default-path mutation preparation apply dry-run gate receipts from rejected preparation apply dry-run receipts"
        )
    }

    let preparationApplyDryRunGateMode =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunGateModeFor(
            preparationApplyDryRunReceipt
                .runtimeDefaultPathMutationPreparationApplyDryRunMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunGateBlockers(
            request,
            preparationApplyDryRunGateMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunGateReceipt(
            false,
            preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAccepted,
            preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunMode,
            preparationApplyDryRunGateMode,
            request.runtimeDefaultPathMutationPreparationApplyDryRunGateId,
            preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunId,
            preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationApplyBoundaryId,
            preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationAcceptanceBoundaryId,
            preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationHandoffGateId,
            preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationCloseoutGateId,
            preparationApplyDryRunReceipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId,
            preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationFinalizationGateId,
            preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryId,
            preparationApplyDryRunReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyId,
            preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateId,
            preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationCommitDryRunId,
            preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
            preparationApplyDryRunReceipt.controlledPreparationApplyId,
            preparationApplyDryRunReceipt.preparationApplyGateId,
            preparationApplyDryRunReceipt.preparationDryRunId,
            preparationApplyDryRunReceipt.preparationBoundaryId,
            preparationApplyDryRunReceipt.preparationGateId,
            preparationApplyDryRunReceipt.closeoutBoundaryGateId,
            preparationApplyDryRunReceipt.closeoutBoundaryId,
            preparationApplyDryRunReceipt.closeoutId,
            preparationApplyDryRunReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-gate-input",
            "fix-runtime-default-path-mutation-preparation-apply-dry-run-gate-before-runtime-default-mutation",
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
            "carry preparation apply-dry-run gate id, preparation apply-dry-run receipt, dry-run review, gate marker, staged apply readiness, rollback apply gate, runtime guard apply gate, observability apply gate marker, apply audit marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation preparation apply dry-run gate blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationPreparationApplyDryRunGateReceipt(
        true,
        preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAccepted,
        preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunMode,
        preparationApplyDryRunGateMode,
        request.runtimeDefaultPathMutationPreparationApplyDryRunGateId,
        preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunId,
        preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationApplyBoundaryId,
        preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationAcceptanceBoundaryId,
        preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationHandoffGateId,
        preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationCloseoutGateId,
        preparationApplyDryRunReceipt.controlledRuntimeDefaultPathMutationPreparationFinalizationApplyId,
        preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationFinalizationGateId,
        preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationCommitBoundaryId,
        preparationApplyDryRunReceipt.controlledRuntimeDefaultPathMutationPreparationCommitApplyId,
        preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationCommitApplyGateId,
        preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationCommitDryRunId,
        preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationCommitPlanId,
        preparationApplyDryRunReceipt.controlledPreparationApplyId,
        preparationApplyDryRunReceipt.preparationApplyGateId,
        preparationApplyDryRunReceipt.preparationDryRunId,
        preparationApplyDryRunReceipt.preparationBoundaryId,
        preparationApplyDryRunReceipt.preparationGateId,
        preparationApplyDryRunReceipt.closeoutBoundaryGateId,
        preparationApplyDryRunReceipt.closeoutBoundaryId,
        preparationApplyDryRunReceipt.closeoutId,
        preparationApplyDryRunReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-apply-dry-run-gate",
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-gate-receipt",
        "record-runtime-default-path-mutation-preparation-apply-dry-run-gate-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation preparation apply dry-run acceptance boundary without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation apply dry-run gate modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunGateModeFor(
    preparationApplyDryRunMode: String
): String {
    if (
        preparationApplyDryRunMode ==
        "short-runtime-default-path-mutation-preparation-apply-dry-run"
    ) {
        return "short-runtime-default-path-mutation-preparation-apply-dry-run-gate"
    }
    if (
        preparationApplyDryRunMode ==
        "long-runtime-default-path-mutation-preparation-apply-dry-run"
    ) {
        return "long-runtime-default-path-mutation-preparation-apply-dry-run-gate"
    }
    if (
        preparationApplyDryRunMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-gate"
    }
    "unknown-runtime-default-path-mutation-preparation-apply-dry-run-gate"
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunGateBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunGateRequest,
    preparationApplyDryRunGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationPreparationApplyDryRunGateId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_GATE_ID_NOT_CARRIED")
    }
    if (!request.preparationApplyDryRunReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_RECEIPT_NOT_CARRIED")
    }
    if (!request.applyDryRunReviewCarried) {
        blockers.add("APPLY_DRY_RUN_REVIEW_NOT_CARRIED")
    }
    if (!request.preparationApplyDryRunGateMarkerCarried) {
        blockers.add("PREPARATION_APPLY_DRY_RUN_GATE_MARKER_NOT_CARRIED")
    }
    if (!request.stagedApplyReadinessCarried) {
        blockers.add("STAGED_APPLY_READINESS_NOT_CARRIED")
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
        preparationApplyDryRunGateMode ==
        "unknown-runtime-default-path-mutation-preparation-apply-dry-run-gate"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_MODE")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunGateNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationApplyDryRunNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryRequest {
    public let runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId: String
    public let preparationApplyDryRunGateReceiptCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let preparationApplyDryRunAcceptanceBoundaryCarried: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId: String,
        preparationApplyDryRunGateReceiptCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        preparationApplyDryRunAcceptanceBoundaryCarried: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId
        this.preparationApplyDryRunGateReceiptCarried =
            preparationApplyDryRunGateReceiptCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.preparationApplyDryRunAcceptanceBoundaryCarried =
            preparationApplyDryRunAcceptanceBoundaryCarried
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

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryReceipt {
    public let runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunGateAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunGateMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunGateId: String
    public let preparationApplyDryRunGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunGateReceipt
    public let runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryAllowed: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunGateAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunGateMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunGateId: String,
        preparationApplyDryRunGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunGateReceipt,
        runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryAllowed: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunGateAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunGateAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunGateMode =
            runtimeDefaultPathMutationPreparationApplyDryRunGateMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryMode =
            runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId
        this.runtimeDefaultPathMutationPreparationApplyDryRunGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunGateId
        this.preparationApplyDryRunGateReceipt =
            preparationApplyDryRunGateReceipt
        this.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryRecorded =
            runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryAllowed =
            runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryAllowed
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

public func buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryReceipt(
    preparationApplyDryRunGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunGateReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryRequest
): IgniteRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryNonClaims()
    if (
        !preparationApplyDryRunGateReceipt
            .runtimeDefaultPathMutationPreparationApplyDryRunGateAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryReceipt(
            false,
            preparationApplyDryRunGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunGateAccepted,
            preparationApplyDryRunGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunGateMode,
            "none",
            request.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
            preparationApplyDryRunGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunGateId,
            preparationApplyDryRunGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-apply-dry-run-gate-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0528 runtime default-path mutation preparation apply dry-run gate input before acceptance-boundary work",
            "QUIC must not consume runtime default-path mutation preparation apply dry-run acceptance boundary receipts from rejected gates"
        )
    }

    let acceptanceBoundaryMode =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryModeFor(
            preparationApplyDryRunGateReceipt
                .runtimeDefaultPathMutationPreparationApplyDryRunGateMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryBlockers(
            request,
            acceptanceBoundaryMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryReceipt(
            false,
            preparationApplyDryRunGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunGateAccepted,
            preparationApplyDryRunGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunGateMode,
            acceptanceBoundaryMode,
            request.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
            preparationApplyDryRunGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunGateId,
            preparationApplyDryRunGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-acceptance-boundary-input",
            "fix-runtime-default-path-mutation-preparation-apply-dry-run-acceptance-boundary-before-runtime-default-mutation",
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
            "carry preparation apply-dry-run acceptance boundary id, accepted gate receipt, runtime default-path mutation lock, acceptance boundary marker, downstream consumer boundary, rollback order, runtime guard plan, observability marker, apply audit marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation preparation apply dry-run acceptance-boundary blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryReceipt(
        true,
        preparationApplyDryRunGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunGateAccepted,
        preparationApplyDryRunGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunGateMode,
        acceptanceBoundaryMode,
        request.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
        preparationApplyDryRunGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunGateId,
        preparationApplyDryRunGateReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-apply-dry-run-acceptance-boundary",
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-acceptance-boundary-receipt",
        "record-runtime-default-path-mutation-preparation-apply-dry-run-acceptance-boundary-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation preparation apply dry-run closeout gate without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation apply dry-run acceptance-boundary modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryModeFor(
    preparationApplyDryRunGateMode: String
): String {
    if (
        preparationApplyDryRunGateMode ==
        "short-runtime-default-path-mutation-preparation-apply-dry-run-gate"
    ) {
        return "short-runtime-default-path-mutation-preparation-apply-dry-run-acceptance-boundary"
    }
    if (
        preparationApplyDryRunGateMode ==
        "long-runtime-default-path-mutation-preparation-apply-dry-run-gate"
    ) {
        return "long-runtime-default-path-mutation-preparation-apply-dry-run-acceptance-boundary"
    }
    if (
        preparationApplyDryRunGateMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-gate"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-acceptance-boundary"
    }
    "unknown-runtime-default-path-mutation-preparation-apply-dry-run-acceptance-boundary"
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryRequest,
    acceptanceBoundaryMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_ACCEPTANCE_BOUNDARY_ID_NOT_CARRIED")
    }
    if (!request.preparationApplyDryRunGateReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_GATE_RECEIPT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.preparationApplyDryRunAcceptanceBoundaryCarried) {
        blockers.add("PREPARATION_APPLY_DRY_RUN_ACCEPTANCE_BOUNDARY_NOT_CARRIED")
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
        "unknown-runtime-default-path-mutation-preparation-apply-dry-run-acceptance-boundary"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_GATE")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationApplyDryRunGateNonClaims()
}
