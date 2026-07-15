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

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateRequest {
    public let runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId: String
    public let preparationApplyDryRunAcceptanceBoundaryReceiptCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let preparationApplyDryRunCloseoutGateCarried: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId: String,
        preparationApplyDryRunAcceptanceBoundaryReceiptCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        preparationApplyDryRunCloseoutGateCarried: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId
        this.preparationApplyDryRunAcceptanceBoundaryReceiptCarried =
            preparationApplyDryRunAcceptanceBoundaryReceiptCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.preparationApplyDryRunCloseoutGateCarried =
            preparationApplyDryRunCloseoutGateCarried
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

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateReceipt {
    public let runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId: String
    public let preparationApplyDryRunAcceptanceBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryReceipt
    public let runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateAllowed: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId: String,
        preparationApplyDryRunAcceptanceBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryReceipt,
        runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateAllowed: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryMode =
            runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateMode =
            runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId
        this.preparationApplyDryRunAcceptanceBoundaryReceipt =
            preparationApplyDryRunAcceptanceBoundaryReceipt
        this.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateRecorded =
            runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateAllowed =
            runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateAllowed
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

public func buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateReceipt(
    preparationApplyDryRunAcceptanceBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateRequest
): IgniteRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateNonClaims()
    if (
        !preparationApplyDryRunAcceptanceBoundaryReceipt
            .runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateReceipt(
            false,
            preparationApplyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryAccepted,
            preparationApplyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryMode,
            "none",
            request.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
            preparationApplyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
            preparationApplyDryRunAcceptanceBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-acceptance-boundary-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-apply-dry-run-acceptance-boundary-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_ACCEPTANCE_BOUNDARY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0529 runtime default-path mutation preparation apply dry-run acceptance boundary input before closeout-gate work",
            "QUIC must not consume runtime default-path mutation preparation apply dry-run closeout gates from rejected acceptance boundaries"
        )
    }

    let closeoutGateMode =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateModeFor(
            preparationApplyDryRunAcceptanceBoundaryReceipt
                .runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateBlockers(
            request,
            closeoutGateMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateReceipt(
            false,
            preparationApplyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryAccepted,
            preparationApplyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryMode,
            closeoutGateMode,
            request.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
            preparationApplyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
            preparationApplyDryRunAcceptanceBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-closeout-gate-input",
            "fix-runtime-default-path-mutation-preparation-apply-dry-run-closeout-gate-before-runtime-default-mutation",
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
            "carry preparation apply-dry-run closeout gate id, accepted acceptance boundary receipt, runtime default-path mutation lock, closeout gate marker, downstream consumer boundary, rollback order, runtime guard plan, observability marker, closeout audit marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation preparation apply dry-run closeout-gate blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateReceipt(
        true,
        preparationApplyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryAccepted,
        preparationApplyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryMode,
        closeoutGateMode,
        request.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
        preparationApplyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
        preparationApplyDryRunAcceptanceBoundaryReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-apply-dry-run-closeout-gate",
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-closeout-gate-receipt",
        "record-runtime-default-path-mutation-preparation-apply-dry-run-closeout-gate-without-runtime-default-mutation",
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
        "next packet may prove controlled runtime default-path mutation preparation apply dry-run handoff without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation apply dry-run closeout-gate modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateModeFor(
    acceptanceBoundaryMode: String
): String {
    if (
        acceptanceBoundaryMode ==
        "short-runtime-default-path-mutation-preparation-apply-dry-run-acceptance-boundary"
    ) {
        return "short-runtime-default-path-mutation-preparation-apply-dry-run-closeout-gate"
    }
    if (
        acceptanceBoundaryMode ==
        "long-runtime-default-path-mutation-preparation-apply-dry-run-acceptance-boundary"
    ) {
        return "long-runtime-default-path-mutation-preparation-apply-dry-run-closeout-gate"
    }
    if (
        acceptanceBoundaryMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-acceptance-boundary"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-closeout-gate"
    }
    "unknown-runtime-default-path-mutation-preparation-apply-dry-run-closeout-gate"
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateRequest,
    closeoutGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_CLOSEOUT_GATE_ID_NOT_CARRIED")
    }
    if (!request.preparationApplyDryRunAcceptanceBoundaryReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_ACCEPTANCE_BOUNDARY_RECEIPT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.preparationApplyDryRunCloseoutGateCarried) {
        blockers.add("PREPARATION_APPLY_DRY_RUN_CLOSEOUT_GATE_NOT_CARRIED")
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
        "unknown-runtime-default-path-mutation-preparation-apply-dry-run-closeout-gate"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_ACCEPTANCE_BOUNDARY")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryNonClaims()
}

public class IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffRequest {
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId: String
    public let preparationApplyDryRunCloseoutGateReceiptCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let controlledPreparationApplyDryRunHandoffCarried: Bool
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
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId: String,
        preparationApplyDryRunCloseoutGateReceiptCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        controlledPreparationApplyDryRunHandoffCarried: Bool,
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
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId
        this.preparationApplyDryRunCloseoutGateReceiptCarried =
            preparationApplyDryRunCloseoutGateReceiptCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.controlledPreparationApplyDryRunHandoffCarried =
            controlledPreparationApplyDryRunHandoffCarried
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

public class IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffReceipt {
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateMode: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffMode: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId: String
    public let preparationApplyDryRunCloseoutGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateReceipt
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffAllowed: Bool
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
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateMode: String,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffMode: String,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId: String,
        preparationApplyDryRunCloseoutGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateReceipt,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffAllowed: Bool,
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
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffAccepted =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateMode =
            runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateMode
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffMode =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffMode
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId
        this.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId
        this.preparationApplyDryRunCloseoutGateReceipt =
            preparationApplyDryRunCloseoutGateReceipt
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffRecorded =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffAllowed =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffAllowed
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

public func buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffReceipt(
    preparationApplyDryRunCloseoutGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateReceipt,
    request: IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffRequest
): IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffReceipt {
    let nonClaims =
        igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffNonClaims()
    if (
        !preparationApplyDryRunCloseoutGateReceipt
            .runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateAccepted
    ) {
        return IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffReceipt(
            false,
            preparationApplyDryRunCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateAccepted,
            preparationApplyDryRunCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateMode,
            "none",
            request.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
            preparationApplyDryRunCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
            preparationApplyDryRunCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
            preparationApplyDryRunCloseoutGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-closeout-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-apply-dry-run-closeout-gate-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_CLOSEOUT_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0530 runtime default-path mutation preparation apply dry-run closeout gate input before controlled handoff work",
            "QUIC must not consume controlled runtime default-path mutation preparation apply dry-run handoff receipts from rejected closeout gates"
        )
    }

    let handoffMode =
        igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffModeFor(
            preparationApplyDryRunCloseoutGateReceipt
                .runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateMode
        )
    let blockers =
        igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBlockers(
            request,
            handoffMode
        )
    if (blockers.size > 0) {
        return IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffReceipt(
            false,
            preparationApplyDryRunCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateAccepted,
            preparationApplyDryRunCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateMode,
            handoffMode,
            request.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
            preparationApplyDryRunCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
            preparationApplyDryRunCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
            preparationApplyDryRunCloseoutGateReceipt,
            false,
            "block",
            "blocked-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-input",
            "fix-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-before-runtime-default-mutation",
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
            "carry controlled preparation apply-dry-run handoff id, accepted closeout gate receipt, runtime default-path mutation lock, controlled handoff marker, downstream consumer boundary, rollback order, runtime guard plan, observability marker, handoff audit marker, and keep runtime default mutation out",
            "QUIC can reuse the same controlled runtime default-path mutation preparation apply dry-run handoff blockers before default stream runtime mutation"
        )
    }

    IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffReceipt(
        true,
        preparationApplyDryRunCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateAccepted,
        preparationApplyDryRunCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateMode,
        handoffMode,
        request.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
        preparationApplyDryRunCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
        preparationApplyDryRunCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
        preparationApplyDryRunCloseoutGateReceipt,
        true,
        "record-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff",
        "accepted-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-receipt",
        "record-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation preparation apply dry-run handoff boundary without mutating runtime defaults",
        "QUIC can reuse lane-specific controlled runtime default-path mutation preparation apply dry-run handoff modes before runtime default mutation"
    )
}

func igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffModeFor(
    closeoutGateMode: String
): String {
    if (
        closeoutGateMode ==
        "short-runtime-default-path-mutation-preparation-apply-dry-run-closeout-gate"
    ) {
        return "short-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff"
    }
    if (
        closeoutGateMode ==
        "long-runtime-default-path-mutation-preparation-apply-dry-run-closeout-gate"
    ) {
        return "long-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff"
    }
    if (
        closeoutGateMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-closeout-gate"
    ) {
        return "blocking-isolation-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff"
    }
    "unknown-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff"
}

func igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBlockers(
    request: IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffRequest,
    handoffMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId.size == 0
    ) {
        blockers.add("CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_ID_NOT_CARRIED")
    }
    if (!request.preparationApplyDryRunCloseoutGateReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_CLOSEOUT_GATE_RECEIPT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.controlledPreparationApplyDryRunHandoffCarried) {
        blockers.add("CONTROLLED_PREPARATION_APPLY_DRY_RUN_HANDOFF_NOT_CARRIED")
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
        "unknown-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_CLOSEOUT_GATE")
    }
    blockers.toArray()
}

func igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationApplyDryRunCloseoutGateNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryRequest {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId: String
    public let controlledPreparationApplyDryRunHandoffReceiptCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let preparationApplyDryRunHandoffBoundaryCarried: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId: String,
        controlledPreparationApplyDryRunHandoffReceiptCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        preparationApplyDryRunHandoffBoundaryCarried: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId
        this.controlledPreparationApplyDryRunHandoffReceiptCarried =
            controlledPreparationApplyDryRunHandoffReceiptCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.preparationApplyDryRunHandoffBoundaryCarried =
            preparationApplyDryRunHandoffBoundaryCarried
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

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryReceipt {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryAccepted: Bool
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffAccepted: Bool
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId: String
    public let controlledPreparationApplyDryRunHandoffReceipt: IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffReceipt
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryAllowed: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryAccepted: Bool,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffAccepted: Bool,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId: String,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId: String,
        controlledPreparationApplyDryRunHandoffReceipt: IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffReceipt,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryAllowed: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryAccepted
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffAccepted =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffAccepted
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffMode =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId
        this.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId
        this.controlledPreparationApplyDryRunHandoffReceipt =
            controlledPreparationApplyDryRunHandoffReceipt
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryRecorded =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryAllowed =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryAllowed
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

public func buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryReceipt(
    controlledPreparationApplyDryRunHandoffReceipt: IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryRequest
): IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryNonClaims()
    if (
        !controlledPreparationApplyDryRunHandoffReceipt
            .controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryReceipt(
            false,
            controlledPreparationApplyDryRunHandoffReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffAccepted,
            controlledPreparationApplyDryRunHandoffReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffMode,
            "none",
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId,
            controlledPreparationApplyDryRunHandoffReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
            controlledPreparationApplyDryRunHandoffReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
            controlledPreparationApplyDryRunHandoffReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
            controlledPreparationApplyDryRunHandoffReceipt,
            false,
            "block",
            "blocked-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-receipt",
            "collect-accepted-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-receipt-first",
            ["CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0531 controlled runtime default-path mutation preparation apply dry-run handoff input before handoff-boundary work",
            "QUIC must not consume runtime default-path mutation preparation apply dry-run handoff boundary receipts from rejected controlled handoffs"
        )
    }

    let handoffBoundaryMode =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryModeFor(
            controlledPreparationApplyDryRunHandoffReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryBlockers(
            request,
            handoffBoundaryMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryReceipt(
            false,
            controlledPreparationApplyDryRunHandoffReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffAccepted,
            controlledPreparationApplyDryRunHandoffReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffMode,
            handoffBoundaryMode,
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId,
            controlledPreparationApplyDryRunHandoffReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
            controlledPreparationApplyDryRunHandoffReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
            controlledPreparationApplyDryRunHandoffReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
            controlledPreparationApplyDryRunHandoffReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-boundary-input",
            "fix-runtime-default-path-mutation-preparation-apply-dry-run-handoff-boundary-before-runtime-default-mutation",
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
            "carry preparation apply-dry-run handoff boundary id, accepted controlled handoff receipt, runtime default-path mutation lock, handoff boundary marker, downstream consumer boundary, rollback order, runtime guard plan, observability marker, boundary audit marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation preparation apply dry-run handoff-boundary blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryReceipt(
        true,
        controlledPreparationApplyDryRunHandoffReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffAccepted,
        controlledPreparationApplyDryRunHandoffReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffMode,
        handoffBoundaryMode,
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId,
        controlledPreparationApplyDryRunHandoffReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
        controlledPreparationApplyDryRunHandoffReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
        controlledPreparationApplyDryRunHandoffReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
        controlledPreparationApplyDryRunHandoffReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-boundary",
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-boundary-receipt",
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-boundary-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation preparation apply dry-run handoff apply-boundary without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation apply dry-run handoff-boundary modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryModeFor(
    controlledHandoffMode: String
): String {
    if (
        controlledHandoffMode ==
        "short-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff"
    ) {
        return "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-boundary"
    }
    if (
        controlledHandoffMode ==
        "long-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff"
    ) {
        return "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-boundary"
    }
    if (
        controlledHandoffMode ==
        "blocking-isolation-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-boundary"
    }
    "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-boundary"
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryRequest,
    handoffBoundaryMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_BOUNDARY_ID_NOT_CARRIED")
    }
    if (!request.controlledPreparationApplyDryRunHandoffReceiptCarried) {
        blockers.add("CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_RECEIPT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.preparationApplyDryRunHandoffBoundaryCarried) {
        blockers.add("PREPARATION_APPLY_DRY_RUN_HANDOFF_BOUNDARY_NOT_CARRIED")
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
        "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-boundary"
    ) {
        blockers.add("UNKNOWN_CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryNonClaims(): Array<String> {
    igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryRequest {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryReceiptCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let preparationApplyDryRunHandoffApplyBoundaryCarried: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryReceiptCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        preparationApplyDryRunHandoffApplyBoundaryCarried: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryReceiptCarried =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryReceiptCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.preparationApplyDryRunHandoffApplyBoundaryCarried =
            preparationApplyDryRunHandoffApplyBoundaryCarried
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

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryReceipt {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId: String
    public let handoffBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryReceipt
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryAllowed: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId: String,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId: String,
        handoffBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryReceipt,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryAllowed: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId
        this.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId
        this.handoffBoundaryReceipt = handoffBoundaryReceipt
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryRecorded =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryAllowed =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryAllowed
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

public func buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryReceipt(
    handoffBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryRequest
): IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryNonClaims()
    if (
        !handoffBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryReceipt(
            false,
            handoffBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryAccepted,
            handoffBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryMode,
            "none",
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId,
            handoffBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId,
            handoffBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
            handoffBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
            handoffBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
            handoffBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-boundary-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-boundary-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_BOUNDARY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0532 runtime default-path mutation preparation apply dry-run handoff-boundary input before handoff apply-boundary work",
            "QUIC must not consume handoff apply-boundary receipts from rejected runtime default-path mutation preparation handoff-boundary receipts"
        )
    }

    let handoffApplyBoundaryMode =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryModeFor(
            handoffBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryBlockers(
            request,
            handoffApplyBoundaryMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryReceipt(
            false,
            handoffBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryAccepted,
            handoffBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryMode,
            handoffApplyBoundaryMode,
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId,
            handoffBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId,
            handoffBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
            handoffBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
            handoffBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
            handoffBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-input",
            "fix-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-before-runtime-default-mutation",
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
            "carry preparation handoff apply-boundary id, accepted handoff-boundary receipt, runtime default-path mutation lock, handoff apply-boundary marker, downstream consumer boundary, rollback order, runtime guard plan, observability marker, boundary audit marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation preparation handoff apply-boundary blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryReceipt(
        true,
        handoffBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryAccepted,
        handoffBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryMode,
        handoffApplyBoundaryMode,
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId,
        handoffBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId,
        handoffBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
        handoffBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
        handoffBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
        handoffBoundaryReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary",
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-receipt",
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation preparation apply dry-run handoff apply-boundary gate without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation apply dry-run handoff apply-boundary modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryModeFor(
    handoffBoundaryMode: String
): String {
    if (
        handoffBoundaryMode ==
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-boundary"
    ) {
        return "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary"
    }
    if (
        handoffBoundaryMode ==
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-boundary"
    ) {
        return "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary"
    }
    if (
        handoffBoundaryMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-boundary"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary"
    }
    "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary"
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryRequest,
    handoffApplyBoundaryMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_ID_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_BOUNDARY_RECEIPT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.preparationApplyDryRunHandoffApplyBoundaryCarried) {
        blockers.add("PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_NOT_CARRIED")
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
        "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_BOUNDARY")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateRequest {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryReceiptCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let preparationApplyDryRunHandoffApplyBoundaryGateCarried: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryReceiptCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        preparationApplyDryRunHandoffApplyBoundaryGateCarried: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryReceiptCarried =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryReceiptCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.preparationApplyDryRunHandoffApplyBoundaryGateCarried =
            preparationApplyDryRunHandoffApplyBoundaryGateCarried
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

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateReceipt {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId: String
    public let handoffApplyBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryReceipt
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateAllowed: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId: String,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId: String,
        handoffApplyBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryReceipt,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateAllowed: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId
        this.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId
        this.handoffApplyBoundaryReceipt = handoffApplyBoundaryReceipt
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateRecorded =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateAllowed =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateAllowed
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

public func buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateReceipt(
    handoffApplyBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateRequest
): IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateNonClaims()
    if (
        !handoffApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateReceipt(
            false,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryAccepted,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryMode,
            "none",
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId,
            handoffApplyBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
            handoffApplyBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0533 runtime default-path mutation preparation apply dry-run handoff apply-boundary input before handoff apply-boundary gate work",
            "QUIC must not consume handoff apply-boundary gate receipts from rejected runtime default-path mutation preparation handoff apply-boundary receipts"
        )
    }

    let handoffApplyBoundaryGateMode =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateModeFor(
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateBlockers(
            request,
            handoffApplyBoundaryGateMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateReceipt(
            false,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryAccepted,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryMode,
            handoffApplyBoundaryGateMode,
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId,
            handoffApplyBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
            handoffApplyBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-input",
            "fix-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-before-runtime-default-mutation",
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
            "carry preparation handoff apply-boundary gate id, accepted handoff apply-boundary receipt, runtime default-path mutation lock, handoff apply-boundary gate marker, downstream consumer boundary, rollback order, runtime guard plan, observability marker, boundary audit marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation preparation handoff apply-boundary gate blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateReceipt(
        true,
        handoffApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryAccepted,
        handoffApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryMode,
        handoffApplyBoundaryGateMode,
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId,
        handoffApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId,
        handoffApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId,
        handoffApplyBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
        handoffApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
        handoffApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
        handoffApplyBoundaryReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate",
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-receipt",
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation apply dry-run handoff apply-boundary gate modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateModeFor(
    handoffApplyBoundaryMode: String
): String {
    if (
        handoffApplyBoundaryMode ==
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary"
    ) {
        return "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate"
    }
    if (
        handoffApplyBoundaryMode ==
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary"
    ) {
        return "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate"
    }
    if (
        handoffApplyBoundaryMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate"
    }
    "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate"
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateRequest,
    handoffApplyBoundaryGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_ID_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_RECEIPT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.preparationApplyDryRunHandoffApplyBoundaryGateCarried) {
        blockers.add("PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_NOT_CARRIED")
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
        "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutRequest {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateReceiptCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let preparationApplyDryRunHandoffApplyBoundaryGateCloseoutCarried: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateReceiptCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        preparationApplyDryRunHandoffApplyBoundaryGateCloseoutCarried: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateReceiptCarried =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateReceiptCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.preparationApplyDryRunHandoffApplyBoundaryGateCloseoutCarried =
            preparationApplyDryRunHandoffApplyBoundaryGateCloseoutCarried
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

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutReceipt {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId: String
    public let handoffApplyBoundaryGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateReceipt
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutAllowed: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId: String,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId: String,
        handoffApplyBoundaryGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateReceipt,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutAllowed: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId
        this.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId
        this.handoffApplyBoundaryGateReceipt = handoffApplyBoundaryGateReceipt
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutRecorded =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutAllowed =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutAllowed
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

public func buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutReceipt(
    handoffApplyBoundaryGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutRequest
): IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutNonClaims()
    if (
        !handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutReceipt(
            false,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateAccepted,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateMode,
            "none",
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId,
            handoffApplyBoundaryGateReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
            handoffApplyBoundaryGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0534 runtime default-path mutation preparation apply dry-run handoff apply-boundary gate input before gate closeout work",
            "QUIC must not consume gate closeout receipts from rejected runtime default-path mutation preparation handoff apply-boundary gate receipts"
        )
    }

    let handoffApplyBoundaryGateCloseoutMode =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutModeFor(
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBlockers(
            request,
            handoffApplyBoundaryGateCloseoutMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutReceipt(
            false,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateAccepted,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateMode,
            handoffApplyBoundaryGateCloseoutMode,
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId,
            handoffApplyBoundaryGateReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
            handoffApplyBoundaryGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-input",
            "fix-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-before-runtime-default-mutation",
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
            "carry preparation handoff apply-boundary gate closeout id, accepted gate receipt, runtime default-path mutation lock, gate closeout marker, downstream consumer boundary, rollback order, runtime guard plan, observability marker, boundary audit marker, closeout ledger marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation preparation handoff apply-boundary gate closeout blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutReceipt(
        true,
        handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateAccepted,
        handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateMode,
        handoffApplyBoundaryGateCloseoutMode,
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId,
        handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId,
        handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId,
        handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId,
        handoffApplyBoundaryGateReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
        handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
        handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
        handoffApplyBoundaryGateReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout",
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-receipt",
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout boundary without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutModeFor(
    handoffApplyBoundaryGateMode: String
): String {
    if (
        handoffApplyBoundaryGateMode ==
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate"
    ) {
        return "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout"
    }
    if (
        handoffApplyBoundaryGateMode ==
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate"
    ) {
        return "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout"
    }
    if (
        handoffApplyBoundaryGateMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout"
    }
    "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout"
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutRequest,
    handoffApplyBoundaryGateCloseoutMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_ID_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_RECEIPT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.preparationApplyDryRunHandoffApplyBoundaryGateCloseoutCarried) {
        blockers.add("PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_NOT_CARRIED")
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
        "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryRequest {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutReceiptCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let preparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryCarried: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutReceiptCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        preparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryCarried: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutReceiptCarried =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutReceiptCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.preparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryCarried =
            preparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryCarried
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

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryReceipt {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId: String
    public let handoffApplyBoundaryGateCloseoutReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutReceipt
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryAllowed: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId: String,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId: String,
        handoffApplyBoundaryGateCloseoutReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutReceipt,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryAllowed: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId
        this.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId
        this.handoffApplyBoundaryGateCloseoutReceipt =
            handoffApplyBoundaryGateCloseoutReceipt
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryRecorded =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryAllowed =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryAllowed
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

public func buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryReceipt(
    handoffApplyBoundaryGateCloseoutReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryRequest
): IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryNonClaims()
    if (
        !handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryReceipt(
            false,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutAccepted,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutMode,
            "none",
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId,
            handoffApplyBoundaryGateCloseoutReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
            handoffApplyBoundaryGateCloseoutReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0535 runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout input before closeout boundary work",
            "QUIC must not consume closeout-boundary receipts from rejected runtime default-path mutation preparation handoff apply-boundary gate closeout receipts"
        )
    }

    let handoffApplyBoundaryGateCloseoutBoundaryMode =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryModeFor(
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryBlockers(
            request,
            handoffApplyBoundaryGateCloseoutBoundaryMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryReceipt(
            false,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutAccepted,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutMode,
            handoffApplyBoundaryGateCloseoutBoundaryMode,
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId,
            handoffApplyBoundaryGateCloseoutReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
            handoffApplyBoundaryGateCloseoutReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-input",
            "fix-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-before-runtime-default-mutation",
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
            "carry preparation handoff apply-boundary gate closeout boundary id, accepted gate closeout receipt, runtime default-path mutation lock, gate closeout boundary marker, downstream consumer boundary, rollback order, runtime guard plan, observability marker, boundary audit marker, closeout ledger marker, closeout boundary marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation preparation handoff apply-boundary gate closeout boundary blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryReceipt(
        true,
        handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutAccepted,
        handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutMode,
        handoffApplyBoundaryGateCloseoutBoundaryMode,
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId,
        handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId,
        handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId,
        handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId,
        handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId,
        handoffApplyBoundaryGateCloseoutReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
        handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
        handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
        handoffApplyBoundaryGateCloseoutReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary",
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-receipt",
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout boundary gate without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout boundary modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryModeFor(
    handoffApplyBoundaryGateCloseoutMode: String
): String {
    if (
        handoffApplyBoundaryGateCloseoutMode ==
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout"
    ) {
        return "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary"
    }
    if (
        handoffApplyBoundaryGateCloseoutMode ==
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout"
    ) {
        return "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary"
    }
    if (
        handoffApplyBoundaryGateCloseoutMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary"
    }
    "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary"
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryRequest,
    handoffApplyBoundaryGateCloseoutBoundaryMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_ID_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_RECEIPT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.preparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryCarried) {
        blockers.add("PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_NOT_CARRIED")
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
        "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateRequest {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryReceiptCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let preparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateCarried: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryReceiptCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        preparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateCarried: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryReceiptCarried =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryReceiptCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.preparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateCarried =
            preparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateCarried
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

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateReceipt {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId: String
    public let handoffApplyBoundaryGateCloseoutBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryReceipt
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateAllowed: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId: String,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId: String,
        handoffApplyBoundaryGateCloseoutBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryReceipt,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateAllowed: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId
        this.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId
        this.handoffApplyBoundaryGateCloseoutBoundaryReceipt =
            handoffApplyBoundaryGateCloseoutBoundaryReceipt
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateRecorded =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateAllowed =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateAllowed
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

public func buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateReceipt(
    handoffApplyBoundaryGateCloseoutBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateRequest
): IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateNonClaims()
    if (
        !handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateReceipt(
            false,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryAccepted,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryMode,
            "none",
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0536 runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout boundary input before closeout boundary gate work",
            "QUIC must not consume closeout-boundary-gate receipts from rejected runtime default-path mutation preparation handoff apply-boundary gate closeout boundary receipts"
        )
    }

    let handoffApplyBoundaryGateCloseoutBoundaryGateMode =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateModeFor(
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateBlockers(
            request,
            handoffApplyBoundaryGateCloseoutBoundaryGateMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateReceipt(
            false,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryAccepted,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryMode,
            handoffApplyBoundaryGateCloseoutBoundaryGateMode,
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-input",
            "fix-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-before-runtime-default-mutation",
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
            "carry preparation handoff apply-boundary gate closeout boundary gate id, accepted gate closeout boundary receipt, runtime default-path mutation lock, gate closeout boundary gate marker, downstream consumer boundary, rollback order, runtime guard plan, observability marker, boundary audit marker, closeout ledger marker, closeout boundary marker, closeout boundary gate marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation preparation handoff apply-boundary gate closeout boundary gate blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateReceipt(
        true,
        handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryAccepted,
        handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryMode,
        handoffApplyBoundaryGateCloseoutBoundaryGateMode,
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId,
        handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId,
        handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId,
        handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId,
        handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId,
        handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId,
        handoffApplyBoundaryGateCloseoutBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
        handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
        handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
        handoffApplyBoundaryGateCloseoutBoundaryReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate",
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-receipt",
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-without-runtime-default-mutation",
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
        "next packet may consume runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout boundary gate into the preparation gate without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout boundary gate modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateModeFor(
    handoffApplyBoundaryGateCloseoutBoundaryMode: String
): String {
    if (
        handoffApplyBoundaryGateCloseoutBoundaryMode ==
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary"
    ) {
        return "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate"
    }
    if (
        handoffApplyBoundaryGateCloseoutBoundaryMode ==
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary"
    ) {
        return "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate"
    }
    if (
        handoffApplyBoundaryGateCloseoutBoundaryMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate"
    }
    "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate"
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateRequest,
    handoffApplyBoundaryGateCloseoutBoundaryGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_ID_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_RECEIPT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.preparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateCarried) {
        blockers.add("PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_NOT_CARRIED")
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
        "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateRequest {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateReceiptCarried: Bool
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
    public let closeoutLedgerMarkerCarried: Bool
    public let closeoutBoundaryMarkerCarried: Bool
    public let closeoutBoundaryGateMarkerCarried: Bool
    public let preparationGateMarkerCarried: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateReceiptCarried: Bool,
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
        closeoutLedgerMarkerCarried: Bool,
        closeoutBoundaryMarkerCarried: Bool,
        closeoutBoundaryGateMarkerCarried: Bool,
        preparationGateMarkerCarried: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateReceiptCarried =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateReceiptCarried
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
        this.closeoutLedgerMarkerCarried = closeoutLedgerMarkerCarried
        this.closeoutBoundaryMarkerCarried = closeoutBoundaryMarkerCarried
        this.closeoutBoundaryGateMarkerCarried =
            closeoutBoundaryGateMarkerCarried
        this.preparationGateMarkerCarried = preparationGateMarkerCarried
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

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateReceipt {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId: String
    public let handoffApplyBoundaryGateCloseoutBoundaryGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateReceipt
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateAllowed: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId: String,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId: String,
        handoffApplyBoundaryGateCloseoutBoundaryGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateReceipt,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateAllowed: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId
        this.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId
        this.handoffApplyBoundaryGateCloseoutBoundaryGateReceipt =
            handoffApplyBoundaryGateCloseoutBoundaryGateReceipt
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateRecorded =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateAllowed =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateAllowed
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

public func buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateReceipt(
    handoffApplyBoundaryGateCloseoutBoundaryGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateRequest
): IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateNonClaims()
    if (
        !handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateReceipt(
            false,
            handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateAccepted,
            handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateMode,
            "none",
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateId,
            handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId,
            handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId,
            handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId,
            handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId,
            handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId,
            handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId,
            handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
            handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
            handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
            handoffApplyBoundaryGateCloseoutBoundaryGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0537 runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout boundary gate input before preparation-gate work",
            "QUIC must not consume preparation-gate receipts from rejected runtime default-path mutation preparation handoff apply-boundary gate closeout boundary gate receipts"
        )
    }

    let preparationGateMode =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateModeFor(
            handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateBlockers(
            request,
            preparationGateMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateReceipt(
            false,
            handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateAccepted,
            handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateMode,
            preparationGateMode,
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateId,
            handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId,
            handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId,
            handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId,
            handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId,
            handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId,
            handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId,
            handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
            handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
            handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
            handoffApplyBoundaryGateCloseoutBoundaryGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-gate-input",
            "fix-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-gate-before-runtime-default-mutation",
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
            "carry preparation-gate id, accepted closeout-boundary-gate receipt, runtime default-path mutation lock, default path candidate, runtime mutation preparation plan, rollback order, runtime guard plan, observability marker, boundary audit marker, source-zero stdx separation, public claim boundary, QUIC reuse boundary, closeout markers, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation preparation-gate blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateReceipt(
        true,
        handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateAccepted,
        handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateMode,
        preparationGateMode,
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateId,
        handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId,
        handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId,
        handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId,
        handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId,
        handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId,
        handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId,
        handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
        handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
        handoffApplyBoundaryGateCloseoutBoundaryGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
        handoffApplyBoundaryGateCloseoutBoundaryGateReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-gate",
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-gate-receipt",
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-gate-without-runtime-default-mutation",
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
        "next packet may consume this preparation-gate receipt without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation-gate modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateModeFor(
    closeoutBoundaryGateMode: String
): String {
    if (
        closeoutBoundaryGateMode ==
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate"
    ) {
        return "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-gate"
    }
    if (
        closeoutBoundaryGateMode ==
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate"
    ) {
        return "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-gate"
    }
    if (
        closeoutBoundaryGateMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-gate"
    }
    "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-gate"
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateRequest,
    preparationGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_GATE_ID_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_RECEIPT_NOT_CARRIED")
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
    if (!request.closeoutLedgerMarkerCarried) {
        blockers.add("CLOSEOUT_LEDGER_MARKER_NOT_CARRIED")
    }
    if (!request.closeoutBoundaryMarkerCarried) {
        blockers.add("CLOSEOUT_BOUNDARY_MARKER_NOT_CARRIED")
    }
    if (!request.closeoutBoundaryGateMarkerCarried) {
        blockers.add("CLOSEOUT_BOUNDARY_GATE_MARKER_NOT_CARRIED")
    }
    if (!request.preparationGateMarkerCarried) {
        blockers.add("PREPARATION_GATE_MARKER_NOT_CARRIED")
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
        preparationGateMode ==
        "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-gate"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_MODE")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryRequest {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateReceiptCarried: Bool
    public let preparationBoundaryMarkerCarried: Bool
    public let mutationReadinessReviewMarkerCarried: Bool
    public let rollbackVerificationMarkerCarried: Bool
    public let defaultPathCandidateFreezeCarried: Bool
    public let runtimeGuardReviewCarried: Bool
    public let observabilityReviewCarried: Bool
    public let sourceZeroStdxClaimSeparated: Bool
    public let publicClaimBoundaryCarried: Bool
    public let quicReuseBoundaryCarried: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateReceiptCarried: Bool,
        preparationBoundaryMarkerCarried: Bool,
        mutationReadinessReviewMarkerCarried: Bool,
        rollbackVerificationMarkerCarried: Bool,
        defaultPathCandidateFreezeCarried: Bool,
        runtimeGuardReviewCarried: Bool,
        observabilityReviewCarried: Bool,
        sourceZeroStdxClaimSeparated: Bool,
        publicClaimBoundaryCarried: Bool,
        quicReuseBoundaryCarried: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateReceiptCarried =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateReceiptCarried
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

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryReceipt {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId: String
    public let preparationGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateReceipt
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryAllowed: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId: String,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId: String,
        preparationGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateReceipt,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryAllowed: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId
        this.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId
        this.preparationGateReceipt = preparationGateReceipt
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryRecorded =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryAllowed =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryAllowed
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

public func buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryReceipt(
    preparationGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryRequest
): IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryNonClaims()
    if (
        !preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryReceipt(
            false,
            preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateAccepted,
            preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateMode,
            "none",
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryId,
            preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateId,
            preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId,
            preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId,
            preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId,
            preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId,
            preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId,
            preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId,
            preparationGateReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
            preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
            preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
            preparationGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-gate-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0538 runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout boundary gate preparation-gate input before preparation-boundary work",
            "QUIC must not consume preparation-boundary receipts from rejected runtime default-path mutation preparation closeout-boundary-gate preparation-gate receipts"
        )
    }

    let preparationBoundaryMode =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryModeFor(
            preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryBlockers(
            request,
            preparationBoundaryMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryReceipt(
            false,
            preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateAccepted,
            preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateMode,
            preparationBoundaryMode,
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryId,
            preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateId,
            preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId,
            preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId,
            preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId,
            preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId,
            preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId,
            preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId,
            preparationGateReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
            preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
            preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
            preparationGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-boundary-input",
            "fix-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-boundary-before-runtime-default-mutation",
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
            "carry preparation-boundary id, accepted preparation-gate receipt, preparation boundary marker, readiness review, rollback verification, default path candidate freeze, runtime guard review, observability review, source-zero stdx separation, public claim boundary, QUIC reuse boundary, closeout markers, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation preparation-boundary blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryReceipt(
        true,
        preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateAccepted,
        preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateMode,
        preparationBoundaryMode,
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryId,
        preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateId,
        preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId,
        preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId,
        preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId,
        preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId,
        preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId,
        preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId,
        preparationGateReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
        preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
        preparationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
        preparationGateReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-boundary",
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-boundary-receipt",
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-boundary-without-runtime-default-mutation",
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
        "next packet may consume this preparation-boundary receipt without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation-boundary modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryModeFor(
    preparationGateMode: String
): String {
    if (
        preparationGateMode ==
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-gate"
    ) {
        return "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-boundary"
    }
    if (
        preparationGateMode ==
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-gate"
    ) {
        return "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-boundary"
    }
    if (
        preparationGateMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-gate"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-boundary"
    }
    "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-boundary"
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryRequest,
    preparationBoundaryMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_BOUNDARY_ID_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_GATE_RECEIPT_NOT_CARRIED")
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
        preparationBoundaryMode ==
        "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-boundary"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_GATE_MODE")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunRequest {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryReceiptCarried: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryReceiptCarried: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryReceiptCarried =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryReceiptCarried
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

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunReceipt {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId: String
    public let preparationBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryReceipt
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunAllowed: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId: String,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId: String,
        preparationBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryReceipt,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunAllowed: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId
        this.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId
        this.preparationBoundaryReceipt = preparationBoundaryReceipt
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunRecorded =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunAllowed =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunAllowed
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

public func buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunReceipt(
    preparationBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunRequest
): IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunNonClaims()
    if (
        !preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunReceipt(
            false,
            preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryAccepted,
            preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryMode,
            "none",
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunId,
            preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryId,
            preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateId,
            preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId,
            preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId,
            preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId,
            preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId,
            preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId,
            preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId,
            preparationBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
            preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
            preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
            preparationBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-boundary-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-boundary-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_BOUNDARY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0539 runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout boundary gate preparation-boundary input before preparation-dry-run work",
            "QUIC must not consume preparation-dry-run receipts from rejected runtime default-path mutation preparation closeout-boundary-gate preparation-boundary receipts"
        )
    }

    let preparationDryRunMode =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunModeFor(
            preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunBlockers(
            request,
            preparationDryRunMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunReceipt(
            false,
            preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryAccepted,
            preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryMode,
            preparationDryRunMode,
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunId,
            preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryId,
            preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateId,
            preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId,
            preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId,
            preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId,
            preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId,
            preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId,
            preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId,
            preparationBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
            preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
            preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
            preparationBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-dry-run-input",
            "fix-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-dry-run-before-runtime-default-mutation",
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
            "carry preparation-dry-run id, accepted preparation-boundary receipt, dry-run plan, simulation inputs, default-path candidate snapshot, rollback dry-run plan, runtime guard dry-run, observability marker, source-zero stdx separation, public claim boundary, and QUIC reuse boundary",
            "QUIC can reuse the same runtime default-path mutation preparation-dry-run blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunReceipt(
        true,
        preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryAccepted,
        preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryMode,
        preparationDryRunMode,
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunId,
        preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryId,
        preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateId,
        preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId,
        preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId,
        preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId,
        preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId,
        preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId,
        preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId,
        preparationBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
        preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
        preparationBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
        preparationBoundaryReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-dry-run",
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-dry-run-receipt",
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-dry-run-without-runtime-default-mutation",
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
        "next packet may consume this preparation-dry-run receipt without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation-dry-run modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunModeFor(
    preparationBoundaryMode: String
): String {
    if (
        preparationBoundaryMode ==
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-boundary"
    ) {
        return "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-dry-run"
    }
    if (
        preparationBoundaryMode ==
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-boundary"
    ) {
        return "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-dry-run"
    }
    if (
        preparationBoundaryMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-boundary"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-dry-run"
    }
    "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-dry-run"
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunRequest,
    preparationDryRunMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_DRY_RUN_ID_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_BOUNDARY_RECEIPT_NOT_CARRIED")
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
        "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-dry-run"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_BOUNDARY_MODE")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryNonClaims()
}
