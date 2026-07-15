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

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateRequest {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunReceiptCarried: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunReceiptCarried: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunReceiptCarried =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunReceiptCarried
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

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateReceipt {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateId: String
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
    public let preparationDryRunReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunReceipt
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateAllowed: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateId: String,
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
        preparationDryRunReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunReceipt,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateAllowed: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateId
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
        this.preparationDryRunReceipt = preparationDryRunReceipt
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateRecorded =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateAllowed =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateAllowed
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

public func buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateReceipt(
    preparationDryRunReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateRequest
): IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateNonClaims()
    if (
        !preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateReceipt(
            false,
            preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunAccepted,
            preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunMode,
            "none",
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateId,
            preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunId,
            preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryId,
            preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateId,
            preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId,
            preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId,
            preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId,
            preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId,
            preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId,
            preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId,
            preparationDryRunReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
            preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
            preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
            preparationDryRunReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-dry-run-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-dry-run-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_DRY_RUN_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0540 runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout boundary gate preparation-dry-run input before preparation-apply-gate work",
            "QUIC must not consume preparation-apply-gate receipts from rejected runtime default-path mutation preparation closeout-boundary-gate preparation-dry-run receipts"
        )
    }

    let preparationApplyGateMode =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateModeFor(
            preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateBlockers(
            request,
            preparationApplyGateMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateReceipt(
            false,
            preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunAccepted,
            preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunMode,
            preparationApplyGateMode,
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateId,
            preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunId,
            preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryId,
            preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateId,
            preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId,
            preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId,
            preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId,
            preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId,
            preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId,
            preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId,
            preparationDryRunReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
            preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
            preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
            preparationDryRunReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-gate-input",
            "fix-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-gate-before-runtime-default-mutation",
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
            "carry preparation-apply-gate id, accepted preparation-dry-run receipt, apply-gate marker, dry-run result review, apply readiness, rollback apply gate, runtime guard apply gate, observability marker, source-zero stdx separation, public claim boundary, and QUIC reuse boundary",
            "QUIC can reuse the same runtime default-path mutation preparation-apply-gate blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateReceipt(
        true,
        preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunAccepted,
        preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunMode,
        preparationApplyGateMode,
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateId,
        preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunId,
        preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryId,
        preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateId,
        preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId,
        preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId,
        preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId,
        preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId,
        preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId,
        preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId,
        preparationDryRunReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
        preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
        preparationDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
        preparationDryRunReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-gate",
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-gate-receipt",
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-gate-without-runtime-default-mutation",
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
        "QUIC can reuse lane-specific runtime default-path mutation preparation-apply-gate modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateModeFor(
    preparationDryRunMode: String
): String {
    if (
        preparationDryRunMode ==
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-dry-run"
    ) {
        return "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-gate"
    }
    if (
        preparationDryRunMode ==
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-dry-run"
    ) {
        return "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-gate"
    }
    if (
        preparationDryRunMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-dry-run"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-gate"
    }
    "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-gate"
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateRequest,
    preparationApplyGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_GATE_ID_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_DRY_RUN_RECEIPT_NOT_CARRIED")
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
        "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-gate"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_DRY_RUN_MODE")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunNonClaims()
}

public class IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyRequest {
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyId: String
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
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyId: String,
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
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyId =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyId
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

public class IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyReceipt {
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyAccepted: Bool
    public let preparationApplyGateAccepted: Bool
    public let preparationApplyGateMode: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyMode: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyId: String
    public let preparationApplyGateId: String
    public let preparationDryRunId: String
    public let preparationBoundaryId: String
    public let preparationGateId: String
    public let closeoutBoundaryGateId: String
    public let closeoutBoundaryId: String
    public let closeoutId: String
    public let applyBoundaryGateId: String
    public let applyBoundaryId: String
    public let handoffBoundaryId: String
    public let controlledHandoffId: String
    public let closeoutGateId: String
    public let acceptanceBoundaryId: String
    public let preparationApplyGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateReceipt
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyAllowed: Bool
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
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyAccepted: Bool,
        preparationApplyGateAccepted: Bool,
        preparationApplyGateMode: String,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyMode: String,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyId: String,
        preparationApplyGateId: String,
        preparationDryRunId: String,
        preparationBoundaryId: String,
        preparationGateId: String,
        closeoutBoundaryGateId: String,
        closeoutBoundaryId: String,
        closeoutId: String,
        applyBoundaryGateId: String,
        applyBoundaryId: String,
        handoffBoundaryId: String,
        controlledHandoffId: String,
        closeoutGateId: String,
        acceptanceBoundaryId: String,
        preparationApplyGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateReceipt,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyAllowed: Bool,
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
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyAccepted =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyAccepted
        this.preparationApplyGateAccepted = preparationApplyGateAccepted
        this.preparationApplyGateMode = preparationApplyGateMode
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyMode =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyMode
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyId =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyId
        this.preparationApplyGateId = preparationApplyGateId
        this.preparationDryRunId = preparationDryRunId
        this.preparationBoundaryId = preparationBoundaryId
        this.preparationGateId = preparationGateId
        this.closeoutBoundaryGateId = closeoutBoundaryGateId
        this.closeoutBoundaryId = closeoutBoundaryId
        this.closeoutId = closeoutId
        this.applyBoundaryGateId = applyBoundaryGateId
        this.applyBoundaryId = applyBoundaryId
        this.handoffBoundaryId = handoffBoundaryId
        this.controlledHandoffId = controlledHandoffId
        this.closeoutGateId = closeoutGateId
        this.acceptanceBoundaryId = acceptanceBoundaryId
        this.preparationApplyGateReceipt = preparationApplyGateReceipt
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyRecorded =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyAllowed =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyAllowed
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

public func buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyReceipt(
    preparationApplyGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateReceipt,
    request: IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyRequest
): IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyReceipt {
    let nonClaims =
        igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyNonClaims()
    if (
        !preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateAccepted
    ) {
        return IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyReceipt(
            false,
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateAccepted,
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateMode,
            "none",
            request.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyId,
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateId,
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunId,
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryId,
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateId,
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId,
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId,
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId,
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId,
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId,
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId,
            preparationApplyGateReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
            preparationApplyGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-gate-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0541 runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout boundary gate preparation-apply-gate input before controlled preparation-apply work",
            "QUIC must not consume controlled preparation-apply receipts from rejected preparation-apply-gate receipts"
        )
    }

    let controlledPreparationApplyMode =
        igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyModeFor(
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateMode
        )
    let blockers =
        igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBlockers(
            request,
            controlledPreparationApplyMode
        )
    if (blockers.size > 0) {
        return IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyReceipt(
            false,
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateAccepted,
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateMode,
            controlledPreparationApplyMode,
            request.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyId,
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateId,
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunId,
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryId,
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateId,
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId,
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId,
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId,
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId,
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId,
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId,
            preparationApplyGateReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
            preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
            preparationApplyGateReceipt,
            false,
            "block",
            "blocked-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-input",
            "fix-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-before-runtime-default-mutation",
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
            "carry controlled preparation-apply id, preparation apply-gate receipt, controlled scope, mutation locks, rollback order, runtime guard plan, observability marker, source-zero stdx separation, and keep runtime default mutation out",
            "QUIC can reuse the same controlled preparation-apply blockers before default stream runtime mutation"
        )
    }

    IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyReceipt(
        true,
        preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateAccepted,
        preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateMode,
        controlledPreparationApplyMode,
        request.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyId,
        preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateId,
        preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationDryRunId,
        preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationBoundaryId,
        preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationGateId,
        preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGateId,
        preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryId,
        preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutId,
        preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateId,
        preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryId,
        preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffBoundaryId,
        preparationApplyGateReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffId,
        preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunCloseoutGateId,
        preparationApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunAcceptanceBoundaryId,
        preparationApplyGateReceipt,
        true,
        "record-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply",
        "accepted-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-receipt",
        "record-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-without-runtime-default-mutation",
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
        "QUIC can reuse lane-specific controlled preparation-apply modes before runtime default mutation"
    )
}

func igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyModeFor(
    preparationApplyGateMode: String
): String {
    if (
        preparationApplyGateMode ==
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-gate"
    ) {
        return "short-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply"
    }
    if (
        preparationApplyGateMode ==
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-gate"
    ) {
        return "long-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply"
    }
    if (
        preparationApplyGateMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-gate"
    ) {
        return "blocking-isolation-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply"
    }
    "unknown-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply"
}

func igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBlockers(
    request: IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyRequest,
    controlledPreparationApplyMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyId.size == 0
    ) {
        blockers.add("CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_ID_NOT_CARRIED")
    }
    if (!request.preparationApplyGateReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_GATE_RECEIPT_NOT_CARRIED")
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
        "unknown-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_GATE")
    }
    blockers.toArray()
}

func igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyGateNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanRequest {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId: String
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId: String,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId
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

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanReceipt {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanAccepted: Bool
    public let controlledPreparationApplyAccepted: Bool
    public let controlledPreparationApplyMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId: String
    public let controlledPreparationApplyId: String
    public let preparationApplyGateId: String
    public let preparationDryRunId: String
    public let preparationBoundaryId: String
    public let preparationGateId: String
    public let closeoutBoundaryGateId: String
    public let closeoutBoundaryId: String
    public let closeoutId: String
    public let applyBoundaryGateId: String
    public let applyBoundaryId: String
    public let handoffBoundaryId: String
    public let controlledHandoffId: String
    public let closeoutGateId: String
    public let acceptanceBoundaryId: String
    public let controlledPreparationApplyReceipt: IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyReceipt
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanAllowed: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanAccepted: Bool,
        controlledPreparationApplyAccepted: Bool,
        controlledPreparationApplyMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId: String,
        controlledPreparationApplyId: String,
        preparationApplyGateId: String,
        preparationDryRunId: String,
        preparationBoundaryId: String,
        preparationGateId: String,
        closeoutBoundaryGateId: String,
        closeoutBoundaryId: String,
        closeoutId: String,
        applyBoundaryGateId: String,
        applyBoundaryId: String,
        handoffBoundaryId: String,
        controlledHandoffId: String,
        closeoutGateId: String,
        acceptanceBoundaryId: String,
        controlledPreparationApplyReceipt: IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyReceipt,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanAllowed: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanAccepted
        this.controlledPreparationApplyAccepted =
            controlledPreparationApplyAccepted
        this.controlledPreparationApplyMode = controlledPreparationApplyMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId
        this.controlledPreparationApplyId = controlledPreparationApplyId
        this.preparationApplyGateId = preparationApplyGateId
        this.preparationDryRunId = preparationDryRunId
        this.preparationBoundaryId = preparationBoundaryId
        this.preparationGateId = preparationGateId
        this.closeoutBoundaryGateId = closeoutBoundaryGateId
        this.closeoutBoundaryId = closeoutBoundaryId
        this.closeoutId = closeoutId
        this.applyBoundaryGateId = applyBoundaryGateId
        this.applyBoundaryId = applyBoundaryId
        this.handoffBoundaryId = handoffBoundaryId
        this.controlledHandoffId = controlledHandoffId
        this.closeoutGateId = closeoutGateId
        this.acceptanceBoundaryId = acceptanceBoundaryId
        this.controlledPreparationApplyReceipt =
            controlledPreparationApplyReceipt
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanRecorded =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanAllowed =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanAllowed
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

public func buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanReceipt(
    controlledPreparationApplyReceipt: IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanRequest
): IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanNonClaims()
    if (
        !controlledPreparationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanReceipt(
            false,
            controlledPreparationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyAccepted,
            controlledPreparationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyMode,
            "none",
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
            controlledPreparationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyId,
            controlledPreparationApplyReceipt.preparationApplyGateId,
            controlledPreparationApplyReceipt.preparationDryRunId,
            controlledPreparationApplyReceipt.preparationBoundaryId,
            controlledPreparationApplyReceipt.preparationGateId,
            controlledPreparationApplyReceipt.closeoutBoundaryGateId,
            controlledPreparationApplyReceipt.closeoutBoundaryId,
            controlledPreparationApplyReceipt.closeoutId,
            controlledPreparationApplyReceipt.applyBoundaryGateId,
            controlledPreparationApplyReceipt.applyBoundaryId,
            controlledPreparationApplyReceipt.handoffBoundaryId,
            controlledPreparationApplyReceipt.controlledHandoffId,
            controlledPreparationApplyReceipt.closeoutGateId,
            controlledPreparationApplyReceipt.acceptanceBoundaryId,
            controlledPreparationApplyReceipt,
            false,
            "block",
            "blocked-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-receipt",
            "collect-accepted-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-receipt-first",
            ["CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0542 controlled runtime default-path mutation preparation apply input before preparation commit-plan work",
            "QUIC must not consume preparation commit-plan receipts from rejected controlled preparation apply receipts"
        )
    }

    let preparationCommitPlanMode =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanModeFor(
            controlledPreparationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanBlockers(
            request,
            preparationCommitPlanMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanReceipt(
            false,
            controlledPreparationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyAccepted,
            controlledPreparationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyMode,
            preparationCommitPlanMode,
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
            controlledPreparationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyId,
            controlledPreparationApplyReceipt.preparationApplyGateId,
            controlledPreparationApplyReceipt.preparationDryRunId,
            controlledPreparationApplyReceipt.preparationBoundaryId,
            controlledPreparationApplyReceipt.preparationGateId,
            controlledPreparationApplyReceipt.closeoutBoundaryGateId,
            controlledPreparationApplyReceipt.closeoutBoundaryId,
            controlledPreparationApplyReceipt.closeoutId,
            controlledPreparationApplyReceipt.applyBoundaryGateId,
            controlledPreparationApplyReceipt.applyBoundaryId,
            controlledPreparationApplyReceipt.handoffBoundaryId,
            controlledPreparationApplyReceipt.controlledHandoffId,
            controlledPreparationApplyReceipt.closeoutGateId,
            controlledPreparationApplyReceipt.acceptanceBoundaryId,
            controlledPreparationApplyReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-plan-input",
            "fix-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-plan-before-runtime-default-mutation",
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
            "carry preparation commit-plan id, accepted controlled preparation-apply receipt, commit-plan marker, review marker, readiness marker, rollback commit plan, runtime guard commit plan, observability marker, source-zero stdx separation, public claim boundary, and QUIC reuse boundary",
            "QUIC can reuse the same runtime default-path mutation preparation commit-plan blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanReceipt(
        true,
        controlledPreparationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyAccepted,
        controlledPreparationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyMode,
        preparationCommitPlanMode,
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
        controlledPreparationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyId,
        controlledPreparationApplyReceipt.preparationApplyGateId,
        controlledPreparationApplyReceipt.preparationDryRunId,
        controlledPreparationApplyReceipt.preparationBoundaryId,
        controlledPreparationApplyReceipt.preparationGateId,
        controlledPreparationApplyReceipt.closeoutBoundaryGateId,
        controlledPreparationApplyReceipt.closeoutBoundaryId,
        controlledPreparationApplyReceipt.closeoutId,
        controlledPreparationApplyReceipt.applyBoundaryGateId,
        controlledPreparationApplyReceipt.applyBoundaryId,
        controlledPreparationApplyReceipt.handoffBoundaryId,
        controlledPreparationApplyReceipt.controlledHandoffId,
        controlledPreparationApplyReceipt.closeoutGateId,
        controlledPreparationApplyReceipt.acceptanceBoundaryId,
        controlledPreparationApplyReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-plan",
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-plan-receipt",
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-plan-without-runtime-default-mutation",
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

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanModeFor(
    controlledPreparationApplyMode: String
): String {
    if (
        controlledPreparationApplyMode ==
        "short-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply"
    ) {
        return "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-plan"
    }
    if (
        controlledPreparationApplyMode ==
        "long-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply"
    ) {
        return "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-plan"
    }
    if (
        controlledPreparationApplyMode ==
        "blocking-isolation-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-plan"
    }
    "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-plan"
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanRequest,
    preparationCommitPlanMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_PLAN_ID_NOT_CARRIED")
    }
    if (!request.controlledPreparationApplyReceiptCarried) {
        blockers.add("CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_RECEIPT_NOT_CARRIED")
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
        "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-plan"
    ) {
        blockers.add("UNKNOWN_CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanNonClaims(): Array<String> {
    igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunRequest {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId: String
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId: String,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId
        this.preparationCommitPlanSnapshotCarried =
            preparationCommitPlanSnapshotCarried
        this.preparationCommitDryRunMarkerCarried =
            preparationCommitDryRunMarkerCarried
        this.targetRuntimeDefaultPathPreviewCarried =
            targetRuntimeDefaultPathPreviewCarried
        this.isolatedPreparationPlanCarried = isolatedPreparationPlanCarried
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

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunReceipt {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId: String
    public let controlledPreparationApplyId: String
    public let preparationApplyGateId: String
    public let preparationDryRunId: String
    public let preparationBoundaryId: String
    public let preparationGateId: String
    public let closeoutBoundaryGateId: String
    public let closeoutBoundaryId: String
    public let closeoutId: String
    public let applyBoundaryGateId: String
    public let applyBoundaryId: String
    public let handoffBoundaryId: String
    public let controlledHandoffId: String
    public let closeoutGateId: String
    public let acceptanceBoundaryId: String
    public let preparationCommitPlanReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanReceipt
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunAllowed: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId: String,
        controlledPreparationApplyId: String,
        preparationApplyGateId: String,
        preparationDryRunId: String,
        preparationBoundaryId: String,
        preparationGateId: String,
        closeoutBoundaryGateId: String,
        closeoutBoundaryId: String,
        closeoutId: String,
        applyBoundaryGateId: String,
        applyBoundaryId: String,
        handoffBoundaryId: String,
        controlledHandoffId: String,
        closeoutGateId: String,
        acceptanceBoundaryId: String,
        preparationCommitPlanReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanReceipt,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunAllowed: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId
        this.controlledPreparationApplyId = controlledPreparationApplyId
        this.preparationApplyGateId = preparationApplyGateId
        this.preparationDryRunId = preparationDryRunId
        this.preparationBoundaryId = preparationBoundaryId
        this.preparationGateId = preparationGateId
        this.closeoutBoundaryGateId = closeoutBoundaryGateId
        this.closeoutBoundaryId = closeoutBoundaryId
        this.closeoutId = closeoutId
        this.applyBoundaryGateId = applyBoundaryGateId
        this.applyBoundaryId = applyBoundaryId
        this.handoffBoundaryId = handoffBoundaryId
        this.controlledHandoffId = controlledHandoffId
        this.closeoutGateId = closeoutGateId
        this.acceptanceBoundaryId = acceptanceBoundaryId
        this.preparationCommitPlanReceipt = preparationCommitPlanReceipt
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunRecorded =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunAllowed =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunAllowed
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

public func buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunReceipt(
    preparationCommitPlanReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunRequest
): IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunNonClaims()
    if (
        !preparationCommitPlanReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunReceipt(
            false,
            preparationCommitPlanReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanAccepted,
            preparationCommitPlanReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanMode,
            "none",
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId,
            preparationCommitPlanReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
            preparationCommitPlanReceipt.controlledPreparationApplyId,
            preparationCommitPlanReceipt.preparationApplyGateId,
            preparationCommitPlanReceipt.preparationDryRunId,
            preparationCommitPlanReceipt.preparationBoundaryId,
            preparationCommitPlanReceipt.preparationGateId,
            preparationCommitPlanReceipt.closeoutBoundaryGateId,
            preparationCommitPlanReceipt.closeoutBoundaryId,
            preparationCommitPlanReceipt.closeoutId,
            preparationCommitPlanReceipt.applyBoundaryGateId,
            preparationCommitPlanReceipt.applyBoundaryId,
            preparationCommitPlanReceipt.handoffBoundaryId,
            preparationCommitPlanReceipt.controlledHandoffId,
            preparationCommitPlanReceipt.closeoutGateId,
            preparationCommitPlanReceipt.acceptanceBoundaryId,
            preparationCommitPlanReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-plan-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-plan-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_PLAN_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0543 preparation commit-plan input before preparation commit dry-run work",
            "QUIC must not consume runtime default-path mutation preparation commit dry-run receipts from rejected preparation commit-plan receipts"
        )
    }

    let preparationCommitDryRunMode =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunModeFor(
            preparationCommitPlanReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunBlockers(
            request,
            preparationCommitDryRunMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunReceipt(
            false,
            preparationCommitPlanReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanAccepted,
            preparationCommitPlanReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanMode,
            preparationCommitDryRunMode,
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId,
            preparationCommitPlanReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
            preparationCommitPlanReceipt.controlledPreparationApplyId,
            preparationCommitPlanReceipt.preparationApplyGateId,
            preparationCommitPlanReceipt.preparationDryRunId,
            preparationCommitPlanReceipt.preparationBoundaryId,
            preparationCommitPlanReceipt.preparationGateId,
            preparationCommitPlanReceipt.closeoutBoundaryGateId,
            preparationCommitPlanReceipt.closeoutBoundaryId,
            preparationCommitPlanReceipt.closeoutId,
            preparationCommitPlanReceipt.applyBoundaryGateId,
            preparationCommitPlanReceipt.applyBoundaryId,
            preparationCommitPlanReceipt.handoffBoundaryId,
            preparationCommitPlanReceipt.controlledHandoffId,
            preparationCommitPlanReceipt.closeoutGateId,
            preparationCommitPlanReceipt.acceptanceBoundaryId,
            preparationCommitPlanReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-dry-run-input",
            "fix-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-dry-run-before-runtime-default-mutation",
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

    IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunReceipt(
        true,
        preparationCommitPlanReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanAccepted,
        preparationCommitPlanReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanMode,
        preparationCommitDryRunMode,
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId,
        preparationCommitPlanReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
        preparationCommitPlanReceipt.controlledPreparationApplyId,
        preparationCommitPlanReceipt.preparationApplyGateId,
        preparationCommitPlanReceipt.preparationDryRunId,
        preparationCommitPlanReceipt.preparationBoundaryId,
        preparationCommitPlanReceipt.preparationGateId,
        preparationCommitPlanReceipt.closeoutBoundaryGateId,
        preparationCommitPlanReceipt.closeoutBoundaryId,
        preparationCommitPlanReceipt.closeoutId,
        preparationCommitPlanReceipt.applyBoundaryGateId,
        preparationCommitPlanReceipt.applyBoundaryId,
        preparationCommitPlanReceipt.handoffBoundaryId,
        preparationCommitPlanReceipt.controlledHandoffId,
        preparationCommitPlanReceipt.closeoutGateId,
        preparationCommitPlanReceipt.acceptanceBoundaryId,
        preparationCommitPlanReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-dry-run",
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-dry-run-receipt",
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-dry-run-without-runtime-default-mutation",
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

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunModeFor(
    preparationCommitPlanMode: String
): String {
    if (
        preparationCommitPlanMode ==
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-plan"
    ) {
        return "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-dry-run"
    }
    if (
        preparationCommitPlanMode ==
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-plan"
    ) {
        return "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-dry-run"
    }
    if (
        preparationCommitPlanMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-plan"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-dry-run"
    }
    "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-dry-run"
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunRequest,
    preparationCommitDryRunMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_DRY_RUN_ID_NOT_CARRIED")
    }
    if (!request.preparationCommitPlanSnapshotCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_PLAN_SNAPSHOT_NOT_CARRIED")
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
        "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-dry-run"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_PLAN")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateRequest {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId: String
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId: String,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId
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

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateReceipt {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId: String
    public let controlledPreparationApplyId: String
    public let preparationApplyGateId: String
    public let preparationDryRunId: String
    public let preparationBoundaryId: String
    public let preparationGateId: String
    public let closeoutBoundaryGateId: String
    public let closeoutBoundaryId: String
    public let closeoutId: String
    public let applyBoundaryGateId: String
    public let applyBoundaryId: String
    public let handoffBoundaryId: String
    public let controlledHandoffId: String
    public let closeoutGateId: String
    public let acceptanceBoundaryId: String
    public let preparationCommitDryRunReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunReceipt
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateAllowed: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId: String,
        controlledPreparationApplyId: String,
        preparationApplyGateId: String,
        preparationDryRunId: String,
        preparationBoundaryId: String,
        preparationGateId: String,
        closeoutBoundaryGateId: String,
        closeoutBoundaryId: String,
        closeoutId: String,
        applyBoundaryGateId: String,
        applyBoundaryId: String,
        handoffBoundaryId: String,
        controlledHandoffId: String,
        closeoutGateId: String,
        acceptanceBoundaryId: String,
        preparationCommitDryRunReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunReceipt,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateAllowed: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId
        this.controlledPreparationApplyId = controlledPreparationApplyId
        this.preparationApplyGateId = preparationApplyGateId
        this.preparationDryRunId = preparationDryRunId
        this.preparationBoundaryId = preparationBoundaryId
        this.preparationGateId = preparationGateId
        this.closeoutBoundaryGateId = closeoutBoundaryGateId
        this.closeoutBoundaryId = closeoutBoundaryId
        this.closeoutId = closeoutId
        this.applyBoundaryGateId = applyBoundaryGateId
        this.applyBoundaryId = applyBoundaryId
        this.handoffBoundaryId = handoffBoundaryId
        this.controlledHandoffId = controlledHandoffId
        this.closeoutGateId = closeoutGateId
        this.acceptanceBoundaryId = acceptanceBoundaryId
        this.preparationCommitDryRunReceipt = preparationCommitDryRunReceipt
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateRecorded =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateAllowed =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateAllowed
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

public func buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateReceipt(
    preparationCommitDryRunReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateRequest
): IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateNonClaims()
    if (
        !preparationCommitDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateReceipt(
            false,
            preparationCommitDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunAccepted,
            preparationCommitDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunMode,
            "none",
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId,
            preparationCommitDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId,
            preparationCommitDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
            preparationCommitDryRunReceipt.controlledPreparationApplyId,
            preparationCommitDryRunReceipt.preparationApplyGateId,
            preparationCommitDryRunReceipt.preparationDryRunId,
            preparationCommitDryRunReceipt.preparationBoundaryId,
            preparationCommitDryRunReceipt.preparationGateId,
            preparationCommitDryRunReceipt.closeoutBoundaryGateId,
            preparationCommitDryRunReceipt.closeoutBoundaryId,
            preparationCommitDryRunReceipt.closeoutId,
            preparationCommitDryRunReceipt.applyBoundaryGateId,
            preparationCommitDryRunReceipt.applyBoundaryId,
            preparationCommitDryRunReceipt.handoffBoundaryId,
            preparationCommitDryRunReceipt.controlledHandoffId,
            preparationCommitDryRunReceipt.closeoutGateId,
            preparationCommitDryRunReceipt.acceptanceBoundaryId,
            preparationCommitDryRunReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-dry-run-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-dry-run-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_DRY_RUN_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0544 preparation commit-dry-run input before preparation commit apply-gate work",
            "QUIC must not consume runtime default-path mutation preparation commit apply-gate receipts from rejected preparation commit-dry-run receipts"
        )
    }

    let preparationCommitApplyGateMode =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateModeFor(
            preparationCommitDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateBlockers(
            request,
            preparationCommitApplyGateMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateReceipt(
            false,
            preparationCommitDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunAccepted,
            preparationCommitDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunMode,
            preparationCommitApplyGateMode,
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId,
            preparationCommitDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId,
            preparationCommitDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
            preparationCommitDryRunReceipt.controlledPreparationApplyId,
            preparationCommitDryRunReceipt.preparationApplyGateId,
            preparationCommitDryRunReceipt.preparationDryRunId,
            preparationCommitDryRunReceipt.preparationBoundaryId,
            preparationCommitDryRunReceipt.preparationGateId,
            preparationCommitDryRunReceipt.closeoutBoundaryGateId,
            preparationCommitDryRunReceipt.closeoutBoundaryId,
            preparationCommitDryRunReceipt.closeoutId,
            preparationCommitDryRunReceipt.applyBoundaryGateId,
            preparationCommitDryRunReceipt.applyBoundaryId,
            preparationCommitDryRunReceipt.handoffBoundaryId,
            preparationCommitDryRunReceipt.controlledHandoffId,
            preparationCommitDryRunReceipt.closeoutGateId,
            preparationCommitDryRunReceipt.acceptanceBoundaryId,
            preparationCommitDryRunReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply-gate-input",
            "fix-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply-gate-before-runtime-default-mutation",
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
            "carry preparation commit apply-gate id, commit dry-run snapshot, target runtime default-path preview, apply precondition gate, runtime default-path mutation lock, rollback order, runtime guard plan, observability marker, source-zero stdx separation, and QUIC reuse boundary",
            "QUIC can reuse the same runtime default-path mutation preparation commit apply-gate blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateReceipt(
        true,
        preparationCommitDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunAccepted,
        preparationCommitDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunMode,
        preparationCommitApplyGateMode,
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId,
        preparationCommitDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId,
        preparationCommitDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
        preparationCommitDryRunReceipt.controlledPreparationApplyId,
        preparationCommitDryRunReceipt.preparationApplyGateId,
        preparationCommitDryRunReceipt.preparationDryRunId,
        preparationCommitDryRunReceipt.preparationBoundaryId,
        preparationCommitDryRunReceipt.preparationGateId,
        preparationCommitDryRunReceipt.closeoutBoundaryGateId,
        preparationCommitDryRunReceipt.closeoutBoundaryId,
        preparationCommitDryRunReceipt.closeoutId,
        preparationCommitDryRunReceipt.applyBoundaryGateId,
        preparationCommitDryRunReceipt.applyBoundaryId,
        preparationCommitDryRunReceipt.handoffBoundaryId,
        preparationCommitDryRunReceipt.controlledHandoffId,
        preparationCommitDryRunReceipt.closeoutGateId,
        preparationCommitDryRunReceipt.acceptanceBoundaryId,
        preparationCommitDryRunReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply-gate",
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply-gate-receipt",
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply-gate-without-runtime-default-mutation",
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

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateModeFor(
    preparationCommitDryRunMode: String
): String {
    if (
        preparationCommitDryRunMode ==
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-dry-run"
    ) {
        return "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply-gate"
    }
    if (
        preparationCommitDryRunMode ==
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-dry-run"
    ) {
        return "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply-gate"
    }
    if (
        preparationCommitDryRunMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-dry-run"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply-gate"
    }
    "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply-gate"
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateRequest,
    preparationCommitApplyGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_APPLY_GATE_ID_NOT_CARRIED")
    }
    if (!request.preparationCommitDryRunSnapshotCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_DRY_RUN_SNAPSHOT_NOT_CARRIED")
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
        "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply-gate"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_DRY_RUN")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunNonClaims()
}

public class IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyRequest {
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId: String
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
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId: String,
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
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId
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

public class IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyReceipt {
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateMode: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyMode: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId: String
    public let controlledPreparationApplyId: String
    public let preparationApplyGateId: String
    public let preparationDryRunId: String
    public let preparationBoundaryId: String
    public let preparationGateId: String
    public let closeoutBoundaryGateId: String
    public let closeoutBoundaryId: String
    public let closeoutId: String
    public let applyBoundaryGateId: String
    public let applyBoundaryId: String
    public let handoffBoundaryId: String
    public let controlledHandoffId: String
    public let closeoutGateId: String
    public let acceptanceBoundaryId: String
    public let preparationCommitApplyGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateReceipt
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyAllowed: Bool
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
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateMode: String,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyMode: String,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId: String,
        controlledPreparationApplyId: String,
        preparationApplyGateId: String,
        preparationDryRunId: String,
        preparationBoundaryId: String,
        preparationGateId: String,
        closeoutBoundaryGateId: String,
        closeoutBoundaryId: String,
        closeoutId: String,
        applyBoundaryGateId: String,
        applyBoundaryId: String,
        handoffBoundaryId: String,
        controlledHandoffId: String,
        closeoutGateId: String,
        acceptanceBoundaryId: String,
        preparationCommitApplyGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateReceipt,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyAllowed: Bool,
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
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyAccepted =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateMode
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyMode =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyMode
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId
        this.controlledPreparationApplyId = controlledPreparationApplyId
        this.preparationApplyGateId = preparationApplyGateId
        this.preparationDryRunId = preparationDryRunId
        this.preparationBoundaryId = preparationBoundaryId
        this.preparationGateId = preparationGateId
        this.closeoutBoundaryGateId = closeoutBoundaryGateId
        this.closeoutBoundaryId = closeoutBoundaryId
        this.closeoutId = closeoutId
        this.applyBoundaryGateId = applyBoundaryGateId
        this.applyBoundaryId = applyBoundaryId
        this.handoffBoundaryId = handoffBoundaryId
        this.controlledHandoffId = controlledHandoffId
        this.closeoutGateId = closeoutGateId
        this.acceptanceBoundaryId = acceptanceBoundaryId
        this.preparationCommitApplyGateReceipt =
            preparationCommitApplyGateReceipt
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyRecorded =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyAllowed =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyAllowed
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

public func buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyReceipt(
    preparationCommitApplyGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateReceipt,
    request: IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyRequest
): IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyReceipt {
    let nonClaims =
        igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyNonClaims()
    if (
        !preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateAccepted
    ) {
        return IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyReceipt(
            false,
            preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateAccepted,
            preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateMode,
            "none",
            request.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId,
            preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId,
            preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId,
            preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
            preparationCommitApplyGateReceipt.controlledPreparationApplyId,
            preparationCommitApplyGateReceipt.preparationApplyGateId,
            preparationCommitApplyGateReceipt.preparationDryRunId,
            preparationCommitApplyGateReceipt.preparationBoundaryId,
            preparationCommitApplyGateReceipt.preparationGateId,
            preparationCommitApplyGateReceipt.closeoutBoundaryGateId,
            preparationCommitApplyGateReceipt.closeoutBoundaryId,
            preparationCommitApplyGateReceipt.closeoutId,
            preparationCommitApplyGateReceipt.applyBoundaryGateId,
            preparationCommitApplyGateReceipt.applyBoundaryId,
            preparationCommitApplyGateReceipt.handoffBoundaryId,
            preparationCommitApplyGateReceipt.controlledHandoffId,
            preparationCommitApplyGateReceipt.closeoutGateId,
            preparationCommitApplyGateReceipt.acceptanceBoundaryId,
            preparationCommitApplyGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply-gate-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_APPLY_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0545 preparation commit apply-gate input before controlled preparation commit apply work",
            "QUIC must not consume controlled preparation commit apply receipts from rejected preparation commit apply-gate receipts"
        )
    }

    let controlledPreparationCommitApplyMode =
        igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyModeFor(
            preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateMode
        )
    let blockers =
        igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyBlockers(
            request,
            controlledPreparationCommitApplyMode
        )
    if (blockers.size > 0) {
        return IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyReceipt(
            false,
            preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateAccepted,
            preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateMode,
            controlledPreparationCommitApplyMode,
            request.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId,
            preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId,
            preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId,
            preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
            preparationCommitApplyGateReceipt.controlledPreparationApplyId,
            preparationCommitApplyGateReceipt.preparationApplyGateId,
            preparationCommitApplyGateReceipt.preparationDryRunId,
            preparationCommitApplyGateReceipt.preparationBoundaryId,
            preparationCommitApplyGateReceipt.preparationGateId,
            preparationCommitApplyGateReceipt.closeoutBoundaryGateId,
            preparationCommitApplyGateReceipt.closeoutBoundaryId,
            preparationCommitApplyGateReceipt.closeoutId,
            preparationCommitApplyGateReceipt.applyBoundaryGateId,
            preparationCommitApplyGateReceipt.applyBoundaryId,
            preparationCommitApplyGateReceipt.handoffBoundaryId,
            preparationCommitApplyGateReceipt.controlledHandoffId,
            preparationCommitApplyGateReceipt.closeoutGateId,
            preparationCommitApplyGateReceipt.acceptanceBoundaryId,
            preparationCommitApplyGateReceipt,
            false,
            "block",
            "blocked-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply-input",
            "fix-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply-before-runtime-default-mutation",
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
            "QUIC can reuse the same controlled preparation commit apply blockers before default stream runtime mutation"
        )
    }

    IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyReceipt(
        true,
        preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateAccepted,
        preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateMode,
        controlledPreparationCommitApplyMode,
        request.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId,
        preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId,
        preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId,
        preparationCommitApplyGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
        preparationCommitApplyGateReceipt.controlledPreparationApplyId,
        preparationCommitApplyGateReceipt.preparationApplyGateId,
        preparationCommitApplyGateReceipt.preparationDryRunId,
        preparationCommitApplyGateReceipt.preparationBoundaryId,
        preparationCommitApplyGateReceipt.preparationGateId,
        preparationCommitApplyGateReceipt.closeoutBoundaryGateId,
        preparationCommitApplyGateReceipt.closeoutBoundaryId,
        preparationCommitApplyGateReceipt.closeoutId,
        preparationCommitApplyGateReceipt.applyBoundaryGateId,
        preparationCommitApplyGateReceipt.applyBoundaryId,
        preparationCommitApplyGateReceipt.handoffBoundaryId,
        preparationCommitApplyGateReceipt.controlledHandoffId,
        preparationCommitApplyGateReceipt.closeoutGateId,
        preparationCommitApplyGateReceipt.acceptanceBoundaryId,
        preparationCommitApplyGateReceipt,
        true,
        "record-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply",
        "accepted-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply-receipt",
        "record-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply-without-runtime-default-mutation",
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
        "QUIC can reuse lane-specific controlled preparation commit apply modes before runtime default mutation"
    )
}

func igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyModeFor(
    preparationCommitApplyGateMode: String
): String {
    if (
        preparationCommitApplyGateMode ==
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply-gate"
    ) {
        return "short-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply"
    }
    if (
        preparationCommitApplyGateMode ==
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply-gate"
    ) {
        return "long-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply"
    }
    if (
        preparationCommitApplyGateMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply-gate"
    ) {
        return "blocking-isolation-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply"
    }
    "unknown-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply"
}

func igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyBlockers(
    request: IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyRequest,
    controlledPreparationCommitApplyMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId.size == 0
    ) {
        blockers.add("CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_APPLY_ID_NOT_CARRIED")
    }
    if (!request.preparationCommitApplyGateSnapshotCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_APPLY_GATE_SNAPSHOT_NOT_CARRIED")
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
        "unknown-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_APPLY_GATE")
    }
    blockers.toArray()
}

func igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryRequest {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId: String
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId: String,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId
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

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryReceipt {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryAccepted: Bool
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyAccepted: Bool
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId: String
    public let controlledPreparationApplyId: String
    public let preparationApplyGateId: String
    public let preparationDryRunId: String
    public let preparationBoundaryId: String
    public let preparationGateId: String
    public let closeoutBoundaryGateId: String
    public let closeoutBoundaryId: String
    public let closeoutId: String
    public let applyBoundaryGateId: String
    public let applyBoundaryId: String
    public let handoffBoundaryId: String
    public let controlledHandoffId: String
    public let closeoutGateId: String
    public let acceptanceBoundaryId: String
    public let controlledPreparationCommitApplyReceipt: IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyReceipt
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryAllowed: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryAccepted: Bool,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyAccepted: Bool,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId: String,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId: String,
        controlledPreparationApplyId: String,
        preparationApplyGateId: String,
        preparationDryRunId: String,
        preparationBoundaryId: String,
        preparationGateId: String,
        closeoutBoundaryGateId: String,
        closeoutBoundaryId: String,
        closeoutId: String,
        applyBoundaryGateId: String,
        applyBoundaryId: String,
        handoffBoundaryId: String,
        controlledHandoffId: String,
        closeoutGateId: String,
        acceptanceBoundaryId: String,
        controlledPreparationCommitApplyReceipt: IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyReceipt,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryAllowed: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryAccepted
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyAccepted =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyAccepted
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyMode =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId
        this.controlledPreparationApplyId = controlledPreparationApplyId
        this.preparationApplyGateId = preparationApplyGateId
        this.preparationDryRunId = preparationDryRunId
        this.preparationBoundaryId = preparationBoundaryId
        this.preparationGateId = preparationGateId
        this.closeoutBoundaryGateId = closeoutBoundaryGateId
        this.closeoutBoundaryId = closeoutBoundaryId
        this.closeoutId = closeoutId
        this.applyBoundaryGateId = applyBoundaryGateId
        this.applyBoundaryId = applyBoundaryId
        this.handoffBoundaryId = handoffBoundaryId
        this.controlledHandoffId = controlledHandoffId
        this.closeoutGateId = closeoutGateId
        this.acceptanceBoundaryId = acceptanceBoundaryId
        this.controlledPreparationCommitApplyReceipt =
            controlledPreparationCommitApplyReceipt
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryRecorded =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryAllowed =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryAllowed
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

public func buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryReceipt(
    controlledPreparationCommitApplyReceipt: IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryRequest
): IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryNonClaims()
    if (
        !controlledPreparationCommitApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryReceipt(
            false,
            controlledPreparationCommitApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyAccepted,
            controlledPreparationCommitApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyMode,
            "none",
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId,
            controlledPreparationCommitApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId,
            controlledPreparationCommitApplyReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId,
            controlledPreparationCommitApplyReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId,
            controlledPreparationCommitApplyReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
            controlledPreparationCommitApplyReceipt.controlledPreparationApplyId,
            controlledPreparationCommitApplyReceipt.preparationApplyGateId,
            controlledPreparationCommitApplyReceipt.preparationDryRunId,
            controlledPreparationCommitApplyReceipt.preparationBoundaryId,
            controlledPreparationCommitApplyReceipt.preparationGateId,
            controlledPreparationCommitApplyReceipt.closeoutBoundaryGateId,
            controlledPreparationCommitApplyReceipt.closeoutBoundaryId,
            controlledPreparationCommitApplyReceipt.closeoutId,
            controlledPreparationCommitApplyReceipt.applyBoundaryGateId,
            controlledPreparationCommitApplyReceipt.applyBoundaryId,
            controlledPreparationCommitApplyReceipt.handoffBoundaryId,
            controlledPreparationCommitApplyReceipt.controlledHandoffId,
            controlledPreparationCommitApplyReceipt.closeoutGateId,
            controlledPreparationCommitApplyReceipt.acceptanceBoundaryId,
            controlledPreparationCommitApplyReceipt,
            false,
            "block",
            "blocked-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply-receipt",
            "collect-accepted-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply-receipt-first",
            ["CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_APPLY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0546 controlled runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout boundary gate preparation commit apply input before preparation commit boundary work",
            "QUIC must not consume runtime default-path mutation preparation commit boundary receipts from rejected controlled preparation commit apply receipts"
        )
    }

    let preparationCommitBoundaryMode =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryModeFor(
            controlledPreparationCommitApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryBlockers(
            request,
            preparationCommitBoundaryMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryReceipt(
            false,
            controlledPreparationCommitApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyAccepted,
            controlledPreparationCommitApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyMode,
            preparationCommitBoundaryMode,
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId,
            controlledPreparationCommitApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId,
            controlledPreparationCommitApplyReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId,
            controlledPreparationCommitApplyReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId,
            controlledPreparationCommitApplyReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
            controlledPreparationCommitApplyReceipt.controlledPreparationApplyId,
            controlledPreparationCommitApplyReceipt.preparationApplyGateId,
            controlledPreparationCommitApplyReceipt.preparationDryRunId,
            controlledPreparationCommitApplyReceipt.preparationBoundaryId,
            controlledPreparationCommitApplyReceipt.preparationGateId,
            controlledPreparationCommitApplyReceipt.closeoutBoundaryGateId,
            controlledPreparationCommitApplyReceipt.closeoutBoundaryId,
            controlledPreparationCommitApplyReceipt.closeoutId,
            controlledPreparationCommitApplyReceipt.applyBoundaryGateId,
            controlledPreparationCommitApplyReceipt.applyBoundaryId,
            controlledPreparationCommitApplyReceipt.handoffBoundaryId,
            controlledPreparationCommitApplyReceipt.controlledHandoffId,
            controlledPreparationCommitApplyReceipt.closeoutGateId,
            controlledPreparationCommitApplyReceipt.acceptanceBoundaryId,
            controlledPreparationCommitApplyReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-boundary-input",
            "fix-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-boundary-before-runtime-default-mutation",
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

    IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryReceipt(
        true,
        controlledPreparationCommitApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyAccepted,
        controlledPreparationCommitApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyMode,
        preparationCommitBoundaryMode,
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId,
        controlledPreparationCommitApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId,
        controlledPreparationCommitApplyReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId,
        controlledPreparationCommitApplyReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId,
        controlledPreparationCommitApplyReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
        controlledPreparationCommitApplyReceipt.controlledPreparationApplyId,
        controlledPreparationCommitApplyReceipt.preparationApplyGateId,
        controlledPreparationCommitApplyReceipt.preparationDryRunId,
        controlledPreparationCommitApplyReceipt.preparationBoundaryId,
        controlledPreparationCommitApplyReceipt.preparationGateId,
        controlledPreparationCommitApplyReceipt.closeoutBoundaryGateId,
        controlledPreparationCommitApplyReceipt.closeoutBoundaryId,
        controlledPreparationCommitApplyReceipt.closeoutId,
        controlledPreparationCommitApplyReceipt.applyBoundaryGateId,
        controlledPreparationCommitApplyReceipt.applyBoundaryId,
        controlledPreparationCommitApplyReceipt.handoffBoundaryId,
        controlledPreparationCommitApplyReceipt.controlledHandoffId,
        controlledPreparationCommitApplyReceipt.closeoutGateId,
        controlledPreparationCommitApplyReceipt.acceptanceBoundaryId,
        controlledPreparationCommitApplyReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-boundary",
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-boundary-receipt",
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-boundary-without-runtime-default-mutation",
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

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryModeFor(
    controlledPreparationCommitApplyMode: String
): String {
    if (
        controlledPreparationCommitApplyMode ==
        "short-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply"
    ) {
        return "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-boundary"
    }
    if (
        controlledPreparationCommitApplyMode ==
        "long-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply"
    ) {
        return "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-boundary"
    }
    if (
        controlledPreparationCommitApplyMode ==
        "blocking-isolation-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-apply"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-boundary"
    }
    "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-boundary"
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryRequest,
    preparationCommitBoundaryMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_BOUNDARY_ID_NOT_CARRIED")
    }
    if (!request.controlledPreparationCommitApplySnapshotCarried) {
        blockers.add("CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_APPLY_SNAPSHOT_NOT_CARRIED")
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
        "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-boundary"
    ) {
        blockers.add("UNKNOWN_CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_APPLY")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryNonClaims(): Array<String> {
    igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateRequest {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId: String
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId: String,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId
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

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateReceipt {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId: String
    public let controlledPreparationApplyId: String
    public let preparationApplyGateId: String
    public let preparationDryRunId: String
    public let preparationBoundaryId: String
    public let preparationGateId: String
    public let closeoutBoundaryGateId: String
    public let closeoutBoundaryId: String
    public let closeoutId: String
    public let applyBoundaryGateId: String
    public let applyBoundaryId: String
    public let handoffBoundaryId: String
    public let controlledHandoffId: String
    public let closeoutGateId: String
    public let acceptanceBoundaryId: String
    public let preparationCommitBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryReceipt
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateAllowed: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId: String,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId: String,
        controlledPreparationApplyId: String,
        preparationApplyGateId: String,
        preparationDryRunId: String,
        preparationBoundaryId: String,
        preparationGateId: String,
        closeoutBoundaryGateId: String,
        closeoutBoundaryId: String,
        closeoutId: String,
        applyBoundaryGateId: String,
        applyBoundaryId: String,
        handoffBoundaryId: String,
        controlledHandoffId: String,
        closeoutGateId: String,
        acceptanceBoundaryId: String,
        preparationCommitBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryReceipt,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateAllowed: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId
        this.controlledPreparationApplyId = controlledPreparationApplyId
        this.preparationApplyGateId = preparationApplyGateId
        this.preparationDryRunId = preparationDryRunId
        this.preparationBoundaryId = preparationBoundaryId
        this.preparationGateId = preparationGateId
        this.closeoutBoundaryGateId = closeoutBoundaryGateId
        this.closeoutBoundaryId = closeoutBoundaryId
        this.closeoutId = closeoutId
        this.applyBoundaryGateId = applyBoundaryGateId
        this.applyBoundaryId = applyBoundaryId
        this.handoffBoundaryId = handoffBoundaryId
        this.controlledHandoffId = controlledHandoffId
        this.closeoutGateId = closeoutGateId
        this.acceptanceBoundaryId = acceptanceBoundaryId
        this.preparationCommitBoundaryReceipt =
            preparationCommitBoundaryReceipt
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateRecorded =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateAllowed =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateAllowed
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

public func buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateReceipt(
    preparationCommitBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateRequest
): IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateNonClaims()
    if (
        !preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateReceipt(
            false,
            preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryAccepted,
            preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryMode,
            "none",
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId,
            preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId,
            preparationCommitBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId,
            preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId,
            preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId,
            preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
            preparationCommitBoundaryReceipt.controlledPreparationApplyId,
            preparationCommitBoundaryReceipt.preparationApplyGateId,
            preparationCommitBoundaryReceipt.preparationDryRunId,
            preparationCommitBoundaryReceipt.preparationBoundaryId,
            preparationCommitBoundaryReceipt.preparationGateId,
            preparationCommitBoundaryReceipt.closeoutBoundaryGateId,
            preparationCommitBoundaryReceipt.closeoutBoundaryId,
            preparationCommitBoundaryReceipt.closeoutId,
            preparationCommitBoundaryReceipt.applyBoundaryGateId,
            preparationCommitBoundaryReceipt.applyBoundaryId,
            preparationCommitBoundaryReceipt.handoffBoundaryId,
            preparationCommitBoundaryReceipt.controlledHandoffId,
            preparationCommitBoundaryReceipt.closeoutGateId,
            preparationCommitBoundaryReceipt.acceptanceBoundaryId,
            preparationCommitBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-boundary-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-boundary-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_BOUNDARY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0547 runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout boundary gate preparation commit boundary input before preparation finalization gate work",
            "QUIC must not consume runtime default-path mutation preparation finalization gate receipts from rejected preparation commit boundary receipts"
        )
    }

    let preparationFinalizationGateMode =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateModeFor(
            preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateBlockers(
            request,
            preparationFinalizationGateMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateReceipt(
            false,
            preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryAccepted,
            preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryMode,
            preparationFinalizationGateMode,
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId,
            preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId,
            preparationCommitBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId,
            preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId,
            preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId,
            preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
            preparationCommitBoundaryReceipt.controlledPreparationApplyId,
            preparationCommitBoundaryReceipt.preparationApplyGateId,
            preparationCommitBoundaryReceipt.preparationDryRunId,
            preparationCommitBoundaryReceipt.preparationBoundaryId,
            preparationCommitBoundaryReceipt.preparationGateId,
            preparationCommitBoundaryReceipt.closeoutBoundaryGateId,
            preparationCommitBoundaryReceipt.closeoutBoundaryId,
            preparationCommitBoundaryReceipt.closeoutId,
            preparationCommitBoundaryReceipt.applyBoundaryGateId,
            preparationCommitBoundaryReceipt.applyBoundaryId,
            preparationCommitBoundaryReceipt.handoffBoundaryId,
            preparationCommitBoundaryReceipt.controlledHandoffId,
            preparationCommitBoundaryReceipt.closeoutGateId,
            preparationCommitBoundaryReceipt.acceptanceBoundaryId,
            preparationCommitBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-gate-input",
            "fix-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-gate-before-runtime-default-mutation",
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

    IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateReceipt(
        true,
        preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryAccepted,
        preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryMode,
        preparationFinalizationGateMode,
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId,
        preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId,
        preparationCommitBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId,
        preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId,
        preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId,
        preparationCommitBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
        preparationCommitBoundaryReceipt.controlledPreparationApplyId,
        preparationCommitBoundaryReceipt.preparationApplyGateId,
        preparationCommitBoundaryReceipt.preparationDryRunId,
        preparationCommitBoundaryReceipt.preparationBoundaryId,
        preparationCommitBoundaryReceipt.preparationGateId,
        preparationCommitBoundaryReceipt.closeoutBoundaryGateId,
        preparationCommitBoundaryReceipt.closeoutBoundaryId,
        preparationCommitBoundaryReceipt.closeoutId,
        preparationCommitBoundaryReceipt.applyBoundaryGateId,
        preparationCommitBoundaryReceipt.applyBoundaryId,
        preparationCommitBoundaryReceipt.handoffBoundaryId,
        preparationCommitBoundaryReceipt.controlledHandoffId,
        preparationCommitBoundaryReceipt.closeoutGateId,
        preparationCommitBoundaryReceipt.acceptanceBoundaryId,
        preparationCommitBoundaryReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-gate",
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-gate-receipt",
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-gate-without-runtime-default-mutation",
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

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateModeFor(
    preparationCommitBoundaryMode: String
): String {
    if (
        preparationCommitBoundaryMode ==
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-boundary"
    ) {
        return "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-gate"
    }
    if (
        preparationCommitBoundaryMode ==
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-boundary"
    ) {
        return "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-gate"
    }
    if (
        preparationCommitBoundaryMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-commit-boundary"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-gate"
    }
    "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-gate"
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateRequest,
    preparationFinalizationGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_FINALIZATION_GATE_ID_NOT_CARRIED")
    }
    if (!request.preparationCommitBoundarySnapshotCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_BOUNDARY_SNAPSHOT_NOT_CARRIED")
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
        "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-gate"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_COMMIT_BOUNDARY")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryNonClaims()
}

public class IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyRequest {
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId: String
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
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId: String,
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
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId
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

public class IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyReceipt {
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateMode: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyMode: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId: String
    public let controlledPreparationApplyId: String
    public let preparationApplyGateId: String
    public let preparationDryRunId: String
    public let preparationBoundaryId: String
    public let preparationGateId: String
    public let closeoutBoundaryGateId: String
    public let closeoutBoundaryId: String
    public let closeoutId: String
    public let applyBoundaryGateId: String
    public let applyBoundaryId: String
    public let handoffBoundaryId: String
    public let controlledHandoffId: String
    public let closeoutGateId: String
    public let acceptanceBoundaryId: String
    public let preparationFinalizationGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateReceipt
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyAllowed: Bool
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
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateMode: String,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyMode: String,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId: String,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId: String,
        controlledPreparationApplyId: String,
        preparationApplyGateId: String,
        preparationDryRunId: String,
        preparationBoundaryId: String,
        preparationGateId: String,
        closeoutBoundaryGateId: String,
        closeoutBoundaryId: String,
        closeoutId: String,
        applyBoundaryGateId: String,
        applyBoundaryId: String,
        handoffBoundaryId: String,
        controlledHandoffId: String,
        closeoutGateId: String,
        acceptanceBoundaryId: String,
        preparationFinalizationGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateReceipt,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyAllowed: Bool,
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
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyAccepted =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateMode
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyMode =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyMode
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId
        this.controlledPreparationApplyId = controlledPreparationApplyId
        this.preparationApplyGateId = preparationApplyGateId
        this.preparationDryRunId = preparationDryRunId
        this.preparationBoundaryId = preparationBoundaryId
        this.preparationGateId = preparationGateId
        this.closeoutBoundaryGateId = closeoutBoundaryGateId
        this.closeoutBoundaryId = closeoutBoundaryId
        this.closeoutId = closeoutId
        this.applyBoundaryGateId = applyBoundaryGateId
        this.applyBoundaryId = applyBoundaryId
        this.handoffBoundaryId = handoffBoundaryId
        this.controlledHandoffId = controlledHandoffId
        this.closeoutGateId = closeoutGateId
        this.acceptanceBoundaryId = acceptanceBoundaryId
        this.preparationFinalizationGateReceipt =
            preparationFinalizationGateReceipt
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyRecorded =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyAllowed =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyAllowed
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

public func buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyReceipt(
    preparationFinalizationGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateReceipt,
    request: IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyRequest
): IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyReceipt {
    let nonClaims =
        igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyNonClaims()
    if (
        !preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateAccepted
    ) {
        return IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyReceipt(
            false,
            preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateAccepted,
            preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateMode,
            "none",
            request.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId,
            preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId,
            preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId,
            preparationFinalizationGateReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId,
            preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId,
            preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId,
            preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
            preparationFinalizationGateReceipt.controlledPreparationApplyId,
            preparationFinalizationGateReceipt.preparationApplyGateId,
            preparationFinalizationGateReceipt.preparationDryRunId,
            preparationFinalizationGateReceipt.preparationBoundaryId,
            preparationFinalizationGateReceipt.preparationGateId,
            preparationFinalizationGateReceipt.closeoutBoundaryGateId,
            preparationFinalizationGateReceipt.closeoutBoundaryId,
            preparationFinalizationGateReceipt.closeoutId,
            preparationFinalizationGateReceipt.applyBoundaryGateId,
            preparationFinalizationGateReceipt.applyBoundaryId,
            preparationFinalizationGateReceipt.handoffBoundaryId,
            preparationFinalizationGateReceipt.controlledHandoffId,
            preparationFinalizationGateReceipt.closeoutGateId,
            preparationFinalizationGateReceipt.acceptanceBoundaryId,
            preparationFinalizationGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-gate-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_FINALIZATION_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0548 runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout boundary gate preparation finalization gate input before controlled preparation finalization apply work",
            "QUIC must not consume controlled runtime default-path mutation preparation finalization apply receipts from rejected preparation finalization-gate receipts"
        )
    }

    let controlledPreparationFinalizationApplyMode =
        igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyModeFor(
            preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateMode
        )
    let blockers =
        igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyBlockers(
            request,
            controlledPreparationFinalizationApplyMode
        )
    if (blockers.size > 0) {
        return IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyReceipt(
            false,
            preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateAccepted,
            preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateMode,
            controlledPreparationFinalizationApplyMode,
            request.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId,
            preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId,
            preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId,
            preparationFinalizationGateReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId,
            preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId,
            preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId,
            preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
            preparationFinalizationGateReceipt.controlledPreparationApplyId,
            preparationFinalizationGateReceipt.preparationApplyGateId,
            preparationFinalizationGateReceipt.preparationDryRunId,
            preparationFinalizationGateReceipt.preparationBoundaryId,
            preparationFinalizationGateReceipt.preparationGateId,
            preparationFinalizationGateReceipt.closeoutBoundaryGateId,
            preparationFinalizationGateReceipt.closeoutBoundaryId,
            preparationFinalizationGateReceipt.closeoutId,
            preparationFinalizationGateReceipt.applyBoundaryGateId,
            preparationFinalizationGateReceipt.applyBoundaryId,
            preparationFinalizationGateReceipt.handoffBoundaryId,
            preparationFinalizationGateReceipt.controlledHandoffId,
            preparationFinalizationGateReceipt.closeoutGateId,
            preparationFinalizationGateReceipt.acceptanceBoundaryId,
            preparationFinalizationGateReceipt,
            false,
            "block",
            "blocked-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-apply-input",
            "fix-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-apply-before-runtime-default-mutation",
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

    IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyReceipt(
        true,
        preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateAccepted,
        preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateMode,
        controlledPreparationFinalizationApplyMode,
        request.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId,
        preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId,
        preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId,
        preparationFinalizationGateReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId,
        preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId,
        preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId,
        preparationFinalizationGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
        preparationFinalizationGateReceipt.controlledPreparationApplyId,
        preparationFinalizationGateReceipt.preparationApplyGateId,
        preparationFinalizationGateReceipt.preparationDryRunId,
        preparationFinalizationGateReceipt.preparationBoundaryId,
        preparationFinalizationGateReceipt.preparationGateId,
        preparationFinalizationGateReceipt.closeoutBoundaryGateId,
        preparationFinalizationGateReceipt.closeoutBoundaryId,
        preparationFinalizationGateReceipt.closeoutId,
        preparationFinalizationGateReceipt.applyBoundaryGateId,
        preparationFinalizationGateReceipt.applyBoundaryId,
        preparationFinalizationGateReceipt.handoffBoundaryId,
        preparationFinalizationGateReceipt.controlledHandoffId,
        preparationFinalizationGateReceipt.closeoutGateId,
        preparationFinalizationGateReceipt.acceptanceBoundaryId,
        preparationFinalizationGateReceipt,
        true,
        "record-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-apply",
        "accepted-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-apply-receipt",
        "record-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-apply-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout boundary gate preparation closeout gate without mutating runtime defaults",
        "QUIC can reuse lane-specific controlled runtime default-path mutation preparation finalization apply modes before runtime default mutation"
    )
}

func igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyModeFor(
    preparationFinalizationGateMode: String
): String {
    if (
        preparationFinalizationGateMode ==
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-gate"
    ) {
        return "short-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-apply"
    }
    if (
        preparationFinalizationGateMode ==
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-gate"
    ) {
        return "long-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-apply"
    }
    if (
        preparationFinalizationGateMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-gate"
    ) {
        return "blocking-isolation-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-apply"
    }
    "unknown-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-apply"
}

func igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyBlockers(
    request: IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyRequest,
    controlledPreparationFinalizationApplyMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId.size == 0
    ) {
        blockers.add("CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_FINALIZATION_APPLY_ID_NOT_CARRIED")
    }
    if (!request.preparationFinalizationGateSnapshotCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_FINALIZATION_GATE_SNAPSHOT_NOT_CARRIED")
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
        "unknown-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-apply"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_FINALIZATION_GATE")
    }
    blockers.toArray()
}

func igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateRequest {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId: String
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId: String,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId
        this.controlledPreparationFinalizationApplySnapshotCarried =
            controlledPreparationFinalizationApplySnapshotCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.preparationCloseoutGateCarried = preparationCloseoutGateCarried
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

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateReceipt {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateAccepted: Bool
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyAccepted: Bool
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId: String
    public let controlledPreparationApplyId: String
    public let preparationApplyGateId: String
    public let preparationDryRunId: String
    public let preparationBoundaryId: String
    public let preparationGateId: String
    public let closeoutBoundaryGateId: String
    public let closeoutBoundaryId: String
    public let closeoutId: String
    public let applyBoundaryGateId: String
    public let applyBoundaryId: String
    public let handoffBoundaryId: String
    public let controlledHandoffId: String
    public let closeoutGateId: String
    public let acceptanceBoundaryId: String
    public let controlledPreparationFinalizationApplyReceipt: IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyReceipt
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateAllowed: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateAccepted: Bool,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyAccepted: Bool,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId: String,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId: String,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId: String,
        controlledPreparationApplyId: String,
        preparationApplyGateId: String,
        preparationDryRunId: String,
        preparationBoundaryId: String,
        preparationGateId: String,
        closeoutBoundaryGateId: String,
        closeoutBoundaryId: String,
        closeoutId: String,
        applyBoundaryGateId: String,
        applyBoundaryId: String,
        handoffBoundaryId: String,
        controlledHandoffId: String,
        closeoutGateId: String,
        acceptanceBoundaryId: String,
        controlledPreparationFinalizationApplyReceipt: IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyReceipt,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateAllowed: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateAccepted
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyAccepted =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyAccepted
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyMode =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId
        this.controlledPreparationApplyId = controlledPreparationApplyId
        this.preparationApplyGateId = preparationApplyGateId
        this.preparationDryRunId = preparationDryRunId
        this.preparationBoundaryId = preparationBoundaryId
        this.preparationGateId = preparationGateId
        this.closeoutBoundaryGateId = closeoutBoundaryGateId
        this.closeoutBoundaryId = closeoutBoundaryId
        this.closeoutId = closeoutId
        this.applyBoundaryGateId = applyBoundaryGateId
        this.applyBoundaryId = applyBoundaryId
        this.handoffBoundaryId = handoffBoundaryId
        this.controlledHandoffId = controlledHandoffId
        this.closeoutGateId = closeoutGateId
        this.acceptanceBoundaryId = acceptanceBoundaryId
        this.controlledPreparationFinalizationApplyReceipt =
            controlledPreparationFinalizationApplyReceipt
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateRecorded =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateAllowed =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateAllowed
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

public func buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateReceipt(
    controlledPreparationFinalizationApplyReceipt: IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateRequest
): IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateNonClaims()
    if (
        !controlledPreparationFinalizationApplyReceipt
            .controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateReceipt(
            false,
            controlledPreparationFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyAccepted,
            controlledPreparationFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyMode,
            "none",
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId,
            controlledPreparationFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId,
            controlledPreparationFinalizationApplyReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId,
            controlledPreparationFinalizationApplyReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId,
            controlledPreparationFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId,
            controlledPreparationFinalizationApplyReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId,
            controlledPreparationFinalizationApplyReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId,
            controlledPreparationFinalizationApplyReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
            controlledPreparationFinalizationApplyReceipt.controlledPreparationApplyId,
            controlledPreparationFinalizationApplyReceipt.preparationApplyGateId,
            controlledPreparationFinalizationApplyReceipt.preparationDryRunId,
            controlledPreparationFinalizationApplyReceipt.preparationBoundaryId,
            controlledPreparationFinalizationApplyReceipt.preparationGateId,
            controlledPreparationFinalizationApplyReceipt.closeoutBoundaryGateId,
            controlledPreparationFinalizationApplyReceipt.closeoutBoundaryId,
            controlledPreparationFinalizationApplyReceipt.closeoutId,
            controlledPreparationFinalizationApplyReceipt.applyBoundaryGateId,
            controlledPreparationFinalizationApplyReceipt.applyBoundaryId,
            controlledPreparationFinalizationApplyReceipt.handoffBoundaryId,
            controlledPreparationFinalizationApplyReceipt.controlledHandoffId,
            controlledPreparationFinalizationApplyReceipt.closeoutGateId,
            controlledPreparationFinalizationApplyReceipt.acceptanceBoundaryId,
            controlledPreparationFinalizationApplyReceipt,
            false,
            "block",
            "blocked-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-apply-receipt",
            "collect-accepted-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-apply-receipt-first",
            ["CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_FINALIZATION_APPLY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0549 controlled runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout boundary gate preparation finalization apply input before preparation closeout gate work",
            "QUIC must not consume runtime default-path mutation preparation closeout gates from rejected controlled preparation finalization-apply receipts"
        )
    }

    let preparationCloseoutGateMode =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateModeFor(
            controlledPreparationFinalizationApplyReceipt
                .controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateBlockers(
            request,
            preparationCloseoutGateMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateReceipt(
            false,
            controlledPreparationFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyAccepted,
            controlledPreparationFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyMode,
            preparationCloseoutGateMode,
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId,
            controlledPreparationFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId,
            controlledPreparationFinalizationApplyReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId,
            controlledPreparationFinalizationApplyReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId,
            controlledPreparationFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId,
            controlledPreparationFinalizationApplyReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId,
            controlledPreparationFinalizationApplyReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId,
            controlledPreparationFinalizationApplyReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
            controlledPreparationFinalizationApplyReceipt.controlledPreparationApplyId,
            controlledPreparationFinalizationApplyReceipt.preparationApplyGateId,
            controlledPreparationFinalizationApplyReceipt.preparationDryRunId,
            controlledPreparationFinalizationApplyReceipt.preparationBoundaryId,
            controlledPreparationFinalizationApplyReceipt.preparationGateId,
            controlledPreparationFinalizationApplyReceipt.closeoutBoundaryGateId,
            controlledPreparationFinalizationApplyReceipt.closeoutBoundaryId,
            controlledPreparationFinalizationApplyReceipt.closeoutId,
            controlledPreparationFinalizationApplyReceipt.applyBoundaryGateId,
            controlledPreparationFinalizationApplyReceipt.applyBoundaryId,
            controlledPreparationFinalizationApplyReceipt.handoffBoundaryId,
            controlledPreparationFinalizationApplyReceipt.controlledHandoffId,
            controlledPreparationFinalizationApplyReceipt.closeoutGateId,
            controlledPreparationFinalizationApplyReceipt.acceptanceBoundaryId,
            controlledPreparationFinalizationApplyReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-closeout-gate-input",
            "fix-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-closeout-gate-before-runtime-default-mutation",
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

    IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateReceipt(
        true,
        controlledPreparationFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyAccepted,
        controlledPreparationFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyMode,
        preparationCloseoutGateMode,
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId,
        controlledPreparationFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId,
        controlledPreparationFinalizationApplyReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId,
        controlledPreparationFinalizationApplyReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId,
        controlledPreparationFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId,
        controlledPreparationFinalizationApplyReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId,
        controlledPreparationFinalizationApplyReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId,
        controlledPreparationFinalizationApplyReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
        controlledPreparationFinalizationApplyReceipt.controlledPreparationApplyId,
        controlledPreparationFinalizationApplyReceipt.preparationApplyGateId,
        controlledPreparationFinalizationApplyReceipt.preparationDryRunId,
        controlledPreparationFinalizationApplyReceipt.preparationBoundaryId,
        controlledPreparationFinalizationApplyReceipt.preparationGateId,
        controlledPreparationFinalizationApplyReceipt.closeoutBoundaryGateId,
        controlledPreparationFinalizationApplyReceipt.closeoutBoundaryId,
        controlledPreparationFinalizationApplyReceipt.closeoutId,
        controlledPreparationFinalizationApplyReceipt.applyBoundaryGateId,
        controlledPreparationFinalizationApplyReceipt.applyBoundaryId,
        controlledPreparationFinalizationApplyReceipt.handoffBoundaryId,
        controlledPreparationFinalizationApplyReceipt.controlledHandoffId,
        controlledPreparationFinalizationApplyReceipt.closeoutGateId,
        controlledPreparationFinalizationApplyReceipt.acceptanceBoundaryId,
        controlledPreparationFinalizationApplyReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-closeout-gate",
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-closeout-gate-receipt",
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-closeout-gate-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout boundary gate preparation handoff gate without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation closeout gate modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateModeFor(
    controlledPreparationFinalizationApplyMode: String
): String {
    if (
        controlledPreparationFinalizationApplyMode ==
        "short-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-apply"
    ) {
        return "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-closeout-gate"
    }
    if (
        controlledPreparationFinalizationApplyMode ==
        "long-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-apply"
    ) {
        return "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-closeout-gate"
    }
    if (
        controlledPreparationFinalizationApplyMode ==
        "blocking-isolation-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-finalization-apply"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-closeout-gate"
    }
    "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-closeout-gate"
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateRequest,
    preparationCloseoutGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_CLOSEOUT_GATE_ID_NOT_CARRIED")
    }
    if (!request.controlledPreparationFinalizationApplySnapshotCarried) {
        blockers.add("CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_FINALIZATION_APPLY_SNAPSHOT_NOT_CARRIED")
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
        "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-closeout-gate"
    ) {
        blockers.add("UNKNOWN_CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_FINALIZATION_APPLY")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateNonClaims(): Array<String> {
    igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateRequest {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateId: String
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateId: String,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateId
        this.preparationCloseoutGateSnapshotCarried =
            preparationCloseoutGateSnapshotCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.preparationHandoffGateCarried = preparationHandoffGateCarried
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

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateReceipt {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId: String
    public let controlledPreparationApplyId: String
    public let preparationApplyGateId: String
    public let preparationDryRunId: String
    public let preparationBoundaryId: String
    public let preparationGateId: String
    public let closeoutBoundaryGateId: String
    public let closeoutBoundaryId: String
    public let closeoutId: String
    public let applyBoundaryGateId: String
    public let applyBoundaryId: String
    public let handoffBoundaryId: String
    public let controlledHandoffId: String
    public let closeoutGateId: String
    public let acceptanceBoundaryId: String
    public let preparationCloseoutGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateReceipt
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateAllowed: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId: String,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId: String,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId: String,
        controlledPreparationApplyId: String,
        preparationApplyGateId: String,
        preparationDryRunId: String,
        preparationBoundaryId: String,
        preparationGateId: String,
        closeoutBoundaryGateId: String,
        closeoutBoundaryId: String,
        closeoutId: String,
        applyBoundaryGateId: String,
        applyBoundaryId: String,
        handoffBoundaryId: String,
        controlledHandoffId: String,
        closeoutGateId: String,
        acceptanceBoundaryId: String,
        preparationCloseoutGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateReceipt,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateAllowed: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId
        this.controlledPreparationApplyId = controlledPreparationApplyId
        this.preparationApplyGateId = preparationApplyGateId
        this.preparationDryRunId = preparationDryRunId
        this.preparationBoundaryId = preparationBoundaryId
        this.preparationGateId = preparationGateId
        this.closeoutBoundaryGateId = closeoutBoundaryGateId
        this.closeoutBoundaryId = closeoutBoundaryId
        this.closeoutId = closeoutId
        this.applyBoundaryGateId = applyBoundaryGateId
        this.applyBoundaryId = applyBoundaryId
        this.handoffBoundaryId = handoffBoundaryId
        this.controlledHandoffId = controlledHandoffId
        this.closeoutGateId = closeoutGateId
        this.acceptanceBoundaryId = acceptanceBoundaryId
        this.preparationCloseoutGateReceipt = preparationCloseoutGateReceipt
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateRecorded =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateAllowed =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateAllowed
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

public func buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateReceipt(
    preparationCloseoutGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateRequest
): IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateNonClaims()
    if (
        !preparationCloseoutGateReceipt
            .runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateReceipt(
            false,
            preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateAccepted,
            preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateMode,
            "none",
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateId,
            preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId,
            preparationCloseoutGateReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId,
            preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId,
            preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId,
            preparationCloseoutGateReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId,
            preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId,
            preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId,
            preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
            preparationCloseoutGateReceipt.controlledPreparationApplyId,
            preparationCloseoutGateReceipt.preparationApplyGateId,
            preparationCloseoutGateReceipt.preparationDryRunId,
            preparationCloseoutGateReceipt.preparationBoundaryId,
            preparationCloseoutGateReceipt.preparationGateId,
            preparationCloseoutGateReceipt.closeoutBoundaryGateId,
            preparationCloseoutGateReceipt.closeoutBoundaryId,
            preparationCloseoutGateReceipt.closeoutId,
            preparationCloseoutGateReceipt.applyBoundaryGateId,
            preparationCloseoutGateReceipt.applyBoundaryId,
            preparationCloseoutGateReceipt.handoffBoundaryId,
            preparationCloseoutGateReceipt.controlledHandoffId,
            preparationCloseoutGateReceipt.closeoutGateId,
            preparationCloseoutGateReceipt.acceptanceBoundaryId,
            preparationCloseoutGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-closeout-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-closeout-gate-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_CLOSEOUT_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0550 runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout boundary gate preparation closeout gate input before preparation handoff gate work",
            "QUIC must not consume runtime default-path mutation preparation handoff gates from rejected preparation closeout gate receipts"
        )
    }

    let preparationHandoffGateMode =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateModeFor(
            preparationCloseoutGateReceipt
                .runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateBlockers(
            request,
            preparationHandoffGateMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateReceipt(
            false,
            preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateAccepted,
            preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateMode,
            preparationHandoffGateMode,
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateId,
            preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId,
            preparationCloseoutGateReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId,
            preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId,
            preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId,
            preparationCloseoutGateReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId,
            preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId,
            preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId,
            preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
            preparationCloseoutGateReceipt.controlledPreparationApplyId,
            preparationCloseoutGateReceipt.preparationApplyGateId,
            preparationCloseoutGateReceipt.preparationDryRunId,
            preparationCloseoutGateReceipt.preparationBoundaryId,
            preparationCloseoutGateReceipt.preparationGateId,
            preparationCloseoutGateReceipt.closeoutBoundaryGateId,
            preparationCloseoutGateReceipt.closeoutBoundaryId,
            preparationCloseoutGateReceipt.closeoutId,
            preparationCloseoutGateReceipt.applyBoundaryGateId,
            preparationCloseoutGateReceipt.applyBoundaryId,
            preparationCloseoutGateReceipt.handoffBoundaryId,
            preparationCloseoutGateReceipt.controlledHandoffId,
            preparationCloseoutGateReceipt.closeoutGateId,
            preparationCloseoutGateReceipt.acceptanceBoundaryId,
            preparationCloseoutGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-handoff-gate-input",
            "fix-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-handoff-gate-before-runtime-default-mutation",
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

    IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateReceipt(
        true,
        preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateAccepted,
        preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateMode,
        preparationHandoffGateMode,
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateId,
        preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId,
        preparationCloseoutGateReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId,
        preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId,
        preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId,
        preparationCloseoutGateReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId,
        preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId,
        preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId,
        preparationCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
        preparationCloseoutGateReceipt.controlledPreparationApplyId,
        preparationCloseoutGateReceipt.preparationApplyGateId,
        preparationCloseoutGateReceipt.preparationDryRunId,
        preparationCloseoutGateReceipt.preparationBoundaryId,
        preparationCloseoutGateReceipt.preparationGateId,
        preparationCloseoutGateReceipt.closeoutBoundaryGateId,
        preparationCloseoutGateReceipt.closeoutBoundaryId,
        preparationCloseoutGateReceipt.closeoutId,
        preparationCloseoutGateReceipt.applyBoundaryGateId,
        preparationCloseoutGateReceipt.applyBoundaryId,
        preparationCloseoutGateReceipt.handoffBoundaryId,
        preparationCloseoutGateReceipt.controlledHandoffId,
        preparationCloseoutGateReceipt.closeoutGateId,
        preparationCloseoutGateReceipt.acceptanceBoundaryId,
        preparationCloseoutGateReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-handoff-gate",
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-handoff-gate-receipt",
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-handoff-gate-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout boundary gate preparation acceptance boundary without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation handoff gate modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateModeFor(
    preparationCloseoutGateMode: String
): String {
    if (
        preparationCloseoutGateMode ==
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-closeout-gate"
    ) {
        return "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-handoff-gate"
    }
    if (
        preparationCloseoutGateMode ==
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-closeout-gate"
    ) {
        return "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-handoff-gate"
    }
    if (
        preparationCloseoutGateMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-closeout-gate"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-handoff-gate"
    }
    "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-handoff-gate"
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateRequest,
    preparationHandoffGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_HANDOFF_GATE_ID_NOT_CARRIED")
    }
    if (!request.preparationCloseoutGateSnapshotCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_CLOSEOUT_GATE_SNAPSHOT_NOT_CARRIED")
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
        "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-handoff-gate"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_CLOSEOUT_GATE")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryRequest {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryId: String
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryId: String,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryId
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

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryReceipt {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId: String
    public let controlledPreparationApplyId: String
    public let preparationApplyGateId: String
    public let preparationDryRunId: String
    public let preparationBoundaryId: String
    public let preparationGateId: String
    public let closeoutBoundaryGateId: String
    public let closeoutBoundaryId: String
    public let closeoutId: String
    public let applyBoundaryGateId: String
    public let applyBoundaryId: String
    public let handoffBoundaryId: String
    public let controlledHandoffId: String
    public let closeoutGateId: String
    public let acceptanceBoundaryId: String
    public let preparationHandoffGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateReceipt
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryAllowed: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId: String,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId: String,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId: String,
        controlledPreparationApplyId: String,
        preparationApplyGateId: String,
        preparationDryRunId: String,
        preparationBoundaryId: String,
        preparationGateId: String,
        closeoutBoundaryGateId: String,
        closeoutBoundaryId: String,
        closeoutId: String,
        applyBoundaryGateId: String,
        applyBoundaryId: String,
        handoffBoundaryId: String,
        controlledHandoffId: String,
        closeoutGateId: String,
        acceptanceBoundaryId: String,
        preparationHandoffGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateReceipt,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryAllowed: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId
        this.controlledPreparationApplyId = controlledPreparationApplyId
        this.preparationApplyGateId = preparationApplyGateId
        this.preparationDryRunId = preparationDryRunId
        this.preparationBoundaryId = preparationBoundaryId
        this.preparationGateId = preparationGateId
        this.closeoutBoundaryGateId = closeoutBoundaryGateId
        this.closeoutBoundaryId = closeoutBoundaryId
        this.closeoutId = closeoutId
        this.applyBoundaryGateId = applyBoundaryGateId
        this.applyBoundaryId = applyBoundaryId
        this.handoffBoundaryId = handoffBoundaryId
        this.controlledHandoffId = controlledHandoffId
        this.closeoutGateId = closeoutGateId
        this.acceptanceBoundaryId = acceptanceBoundaryId
        this.preparationHandoffGateReceipt = preparationHandoffGateReceipt
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryRecorded =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryAllowed =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryAllowed
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

public func buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryReceipt(
    preparationHandoffGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryRequest
): IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryNonClaims()
    if (
        !preparationHandoffGateReceipt
            .runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryReceipt(
            false,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateAccepted,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateMode,
            "none",
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryId,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateId,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId,
            preparationHandoffGateReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId,
            preparationHandoffGateReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
            preparationHandoffGateReceipt.controlledPreparationApplyId,
            preparationHandoffGateReceipt.preparationApplyGateId,
            preparationHandoffGateReceipt.preparationDryRunId,
            preparationHandoffGateReceipt.preparationBoundaryId,
            preparationHandoffGateReceipt.preparationGateId,
            preparationHandoffGateReceipt.closeoutBoundaryGateId,
            preparationHandoffGateReceipt.closeoutBoundaryId,
            preparationHandoffGateReceipt.closeoutId,
            preparationHandoffGateReceipt.applyBoundaryGateId,
            preparationHandoffGateReceipt.applyBoundaryId,
            preparationHandoffGateReceipt.handoffBoundaryId,
            preparationHandoffGateReceipt.controlledHandoffId,
            preparationHandoffGateReceipt.closeoutGateId,
            preparationHandoffGateReceipt.acceptanceBoundaryId,
            preparationHandoffGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-handoff-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-handoff-gate-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_HANDOFF_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0551 runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout boundary gate preparation handoff gate input before preparation acceptance boundary work",
            "QUIC must not consume runtime default-path mutation preparation acceptance-boundary receipts from rejected preparation handoff-gate receipts"
        )
    }

    let preparationAcceptanceBoundaryMode =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryModeFor(
            preparationHandoffGateReceipt
                .runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryBlockers(
            request,
            preparationAcceptanceBoundaryMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryReceipt(
            false,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateAccepted,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateMode,
            preparationAcceptanceBoundaryMode,
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryId,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateId,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId,
            preparationHandoffGateReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId,
            preparationHandoffGateReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId,
            preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
            preparationHandoffGateReceipt.controlledPreparationApplyId,
            preparationHandoffGateReceipt.preparationApplyGateId,
            preparationHandoffGateReceipt.preparationDryRunId,
            preparationHandoffGateReceipt.preparationBoundaryId,
            preparationHandoffGateReceipt.preparationGateId,
            preparationHandoffGateReceipt.closeoutBoundaryGateId,
            preparationHandoffGateReceipt.closeoutBoundaryId,
            preparationHandoffGateReceipt.closeoutId,
            preparationHandoffGateReceipt.applyBoundaryGateId,
            preparationHandoffGateReceipt.applyBoundaryId,
            preparationHandoffGateReceipt.handoffBoundaryId,
            preparationHandoffGateReceipt.controlledHandoffId,
            preparationHandoffGateReceipt.closeoutGateId,
            preparationHandoffGateReceipt.acceptanceBoundaryId,
            preparationHandoffGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-acceptance-boundary-input",
            "fix-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-acceptance-boundary-before-runtime-default-mutation",
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

    IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryReceipt(
        true,
        preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateAccepted,
        preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateMode,
        preparationAcceptanceBoundaryMode,
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryId,
        preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateId,
        preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId,
        preparationHandoffGateReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId,
        preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId,
        preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId,
        preparationHandoffGateReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId,
        preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId,
        preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId,
        preparationHandoffGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
        preparationHandoffGateReceipt.controlledPreparationApplyId,
        preparationHandoffGateReceipt.preparationApplyGateId,
        preparationHandoffGateReceipt.preparationDryRunId,
        preparationHandoffGateReceipt.preparationBoundaryId,
        preparationHandoffGateReceipt.preparationGateId,
        preparationHandoffGateReceipt.closeoutBoundaryGateId,
        preparationHandoffGateReceipt.closeoutBoundaryId,
        preparationHandoffGateReceipt.closeoutId,
        preparationHandoffGateReceipt.applyBoundaryGateId,
        preparationHandoffGateReceipt.applyBoundaryId,
        preparationHandoffGateReceipt.handoffBoundaryId,
        preparationHandoffGateReceipt.controlledHandoffId,
        preparationHandoffGateReceipt.closeoutGateId,
        preparationHandoffGateReceipt.acceptanceBoundaryId,
        preparationHandoffGateReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-acceptance-boundary",
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-acceptance-boundary-receipt",
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-acceptance-boundary-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout boundary gate preparation apply boundary without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation acceptance-boundary modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryModeFor(
    preparationHandoffGateMode: String
): String {
    if (
        preparationHandoffGateMode ==
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-handoff-gate"
    ) {
        return "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-acceptance-boundary"
    }
    if (
        preparationHandoffGateMode ==
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-handoff-gate"
    ) {
        return "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-acceptance-boundary"
    }
    if (
        preparationHandoffGateMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-handoff-gate"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-acceptance-boundary"
    }
    "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-acceptance-boundary"
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryRequest,
    preparationAcceptanceBoundaryMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_ACCEPTANCE_BOUNDARY_ID_NOT_CARRIED")
    }
    if (!request.preparationHandoffGateReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_HANDOFF_GATE_RECEIPT_NOT_CARRIED")
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
        "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-acceptance-boundary"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_HANDOFF_GATE")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryRequest {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryId: String
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryId: String,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryId
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

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryReceipt {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId: String
    public let controlledPreparationApplyId: String
    public let preparationApplyGateId: String
    public let preparationDryRunId: String
    public let preparationBoundaryId: String
    public let preparationGateId: String
    public let closeoutBoundaryGateId: String
    public let closeoutBoundaryId: String
    public let closeoutId: String
    public let applyBoundaryGateId: String
    public let applyBoundaryId: String
    public let handoffBoundaryId: String
    public let controlledHandoffId: String
    public let closeoutGateId: String
    public let acceptanceBoundaryId: String
    public let preparationAcceptanceBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryReceipt
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryAllowed: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId: String,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId: String,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId: String,
        controlledPreparationApplyId: String,
        preparationApplyGateId: String,
        preparationDryRunId: String,
        preparationBoundaryId: String,
        preparationGateId: String,
        closeoutBoundaryGateId: String,
        closeoutBoundaryId: String,
        closeoutId: String,
        applyBoundaryGateId: String,
        applyBoundaryId: String,
        handoffBoundaryId: String,
        controlledHandoffId: String,
        closeoutGateId: String,
        acceptanceBoundaryId: String,
        preparationAcceptanceBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryReceipt,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryAllowed: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId
        this.controlledPreparationApplyId = controlledPreparationApplyId
        this.preparationApplyGateId = preparationApplyGateId
        this.preparationDryRunId = preparationDryRunId
        this.preparationBoundaryId = preparationBoundaryId
        this.preparationGateId = preparationGateId
        this.closeoutBoundaryGateId = closeoutBoundaryGateId
        this.closeoutBoundaryId = closeoutBoundaryId
        this.closeoutId = closeoutId
        this.applyBoundaryGateId = applyBoundaryGateId
        this.applyBoundaryId = applyBoundaryId
        this.handoffBoundaryId = handoffBoundaryId
        this.controlledHandoffId = controlledHandoffId
        this.closeoutGateId = closeoutGateId
        this.acceptanceBoundaryId = acceptanceBoundaryId
        this.preparationAcceptanceBoundaryReceipt =
            preparationAcceptanceBoundaryReceipt
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryRecorded =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryAllowed =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryAllowed
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

public func buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryReceipt(
    preparationAcceptanceBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryRequest
): IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryNonClaims()
    if (
        !preparationAcceptanceBoundaryReceipt
            .runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryReceipt(
            false,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryAccepted,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryMode,
            "none",
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryId,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryId,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateId,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId,
            preparationAcceptanceBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId,
            preparationAcceptanceBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
            preparationAcceptanceBoundaryReceipt.controlledPreparationApplyId,
            preparationAcceptanceBoundaryReceipt.preparationApplyGateId,
            preparationAcceptanceBoundaryReceipt.preparationDryRunId,
            preparationAcceptanceBoundaryReceipt.preparationBoundaryId,
            preparationAcceptanceBoundaryReceipt.preparationGateId,
            preparationAcceptanceBoundaryReceipt.closeoutBoundaryGateId,
            preparationAcceptanceBoundaryReceipt.closeoutBoundaryId,
            preparationAcceptanceBoundaryReceipt.closeoutId,
            preparationAcceptanceBoundaryReceipt.applyBoundaryGateId,
            preparationAcceptanceBoundaryReceipt.applyBoundaryId,
            preparationAcceptanceBoundaryReceipt.handoffBoundaryId,
            preparationAcceptanceBoundaryReceipt.controlledHandoffId,
            preparationAcceptanceBoundaryReceipt.closeoutGateId,
            preparationAcceptanceBoundaryReceipt.acceptanceBoundaryId,
            preparationAcceptanceBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-acceptance-boundary-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-acceptance-boundary-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_ACCEPTANCE_BOUNDARY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0552 runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout boundary gate preparation acceptance boundary input before preparation apply-boundary work",
            "QUIC must not consume runtime default-path mutation preparation apply-boundary receipts from rejected preparation acceptance-boundary receipts"
        )
    }

    let preparationApplyBoundaryMode =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryModeFor(
            preparationAcceptanceBoundaryReceipt
                .runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryBlockers(
            request,
            preparationApplyBoundaryMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryReceipt(
            false,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryAccepted,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryMode,
            preparationApplyBoundaryMode,
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryId,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryId,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateId,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId,
            preparationAcceptanceBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId,
            preparationAcceptanceBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId,
            preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
            preparationAcceptanceBoundaryReceipt.controlledPreparationApplyId,
            preparationAcceptanceBoundaryReceipt.preparationApplyGateId,
            preparationAcceptanceBoundaryReceipt.preparationDryRunId,
            preparationAcceptanceBoundaryReceipt.preparationBoundaryId,
            preparationAcceptanceBoundaryReceipt.preparationGateId,
            preparationAcceptanceBoundaryReceipt.closeoutBoundaryGateId,
            preparationAcceptanceBoundaryReceipt.closeoutBoundaryId,
            preparationAcceptanceBoundaryReceipt.closeoutId,
            preparationAcceptanceBoundaryReceipt.applyBoundaryGateId,
            preparationAcceptanceBoundaryReceipt.applyBoundaryId,
            preparationAcceptanceBoundaryReceipt.handoffBoundaryId,
            preparationAcceptanceBoundaryReceipt.controlledHandoffId,
            preparationAcceptanceBoundaryReceipt.closeoutGateId,
            preparationAcceptanceBoundaryReceipt.acceptanceBoundaryId,
            preparationAcceptanceBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-boundary-input",
            "fix-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-boundary-before-runtime-default-mutation",
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

    IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryReceipt(
        true,
        preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryAccepted,
        preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryMode,
        preparationApplyBoundaryMode,
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryId,
        preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryId,
        preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateId,
        preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId,
        preparationAcceptanceBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId,
        preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId,
        preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId,
        preparationAcceptanceBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId,
        preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId,
        preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId,
        preparationAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
        preparationAcceptanceBoundaryReceipt.controlledPreparationApplyId,
        preparationAcceptanceBoundaryReceipt.preparationApplyGateId,
        preparationAcceptanceBoundaryReceipt.preparationDryRunId,
        preparationAcceptanceBoundaryReceipt.preparationBoundaryId,
        preparationAcceptanceBoundaryReceipt.preparationGateId,
        preparationAcceptanceBoundaryReceipt.closeoutBoundaryGateId,
        preparationAcceptanceBoundaryReceipt.closeoutBoundaryId,
        preparationAcceptanceBoundaryReceipt.closeoutId,
        preparationAcceptanceBoundaryReceipt.applyBoundaryGateId,
        preparationAcceptanceBoundaryReceipt.applyBoundaryId,
        preparationAcceptanceBoundaryReceipt.handoffBoundaryId,
        preparationAcceptanceBoundaryReceipt.controlledHandoffId,
        preparationAcceptanceBoundaryReceipt.closeoutGateId,
        preparationAcceptanceBoundaryReceipt.acceptanceBoundaryId,
        preparationAcceptanceBoundaryReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-boundary",
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-boundary-receipt",
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-boundary-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout boundary gate preparation apply dry-run without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation apply-boundary modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryModeFor(
    preparationAcceptanceBoundaryMode: String
): String {
    if (
        preparationAcceptanceBoundaryMode ==
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-acceptance-boundary"
    ) {
        return "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-boundary"
    }
    if (
        preparationAcceptanceBoundaryMode ==
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-acceptance-boundary"
    ) {
        return "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-boundary"
    }
    if (
        preparationAcceptanceBoundaryMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-acceptance-boundary"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-boundary"
    }
    "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-boundary"
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryRequest,
    preparationApplyBoundaryMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_BOUNDARY_ID_NOT_CARRIED")
    }
    if (!request.preparationAcceptanceBoundaryReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_ACCEPTANCE_BOUNDARY_RECEIPT_NOT_CARRIED")
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
        "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-boundary"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_ACCEPTANCE_BOUNDARY")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunRequest {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunId: String
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunId: String,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunId
        this.preparationApplyBoundaryReceiptCarried =
            preparationApplyBoundaryReceiptCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.preparationApplyDryRunCarried = preparationApplyDryRunCarried
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

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunReceipt {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId: String
    public let controlledPreparationApplyId: String
    public let preparationApplyGateId: String
    public let preparationDryRunId: String
    public let preparationBoundaryId: String
    public let preparationGateId: String
    public let closeoutBoundaryGateId: String
    public let closeoutBoundaryId: String
    public let closeoutId: String
    public let applyBoundaryGateId: String
    public let applyBoundaryId: String
    public let handoffBoundaryId: String
    public let controlledHandoffId: String
    public let closeoutGateId: String
    public let acceptanceBoundaryId: String
    public let preparationApplyBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryReceipt
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAllowed: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId: String,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId: String,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId: String,
        controlledPreparationApplyId: String,
        preparationApplyGateId: String,
        preparationDryRunId: String,
        preparationBoundaryId: String,
        preparationGateId: String,
        closeoutBoundaryGateId: String,
        closeoutBoundaryId: String,
        closeoutId: String,
        applyBoundaryGateId: String,
        applyBoundaryId: String,
        handoffBoundaryId: String,
        controlledHandoffId: String,
        closeoutGateId: String,
        acceptanceBoundaryId: String,
        preparationApplyBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryReceipt,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAllowed: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId
        this.controlledPreparationApplyId = controlledPreparationApplyId
        this.preparationApplyGateId = preparationApplyGateId
        this.preparationDryRunId = preparationDryRunId
        this.preparationBoundaryId = preparationBoundaryId
        this.preparationGateId = preparationGateId
        this.closeoutBoundaryGateId = closeoutBoundaryGateId
        this.closeoutBoundaryId = closeoutBoundaryId
        this.closeoutId = closeoutId
        this.applyBoundaryGateId = applyBoundaryGateId
        this.applyBoundaryId = applyBoundaryId
        this.handoffBoundaryId = handoffBoundaryId
        this.controlledHandoffId = controlledHandoffId
        this.closeoutGateId = closeoutGateId
        this.acceptanceBoundaryId = acceptanceBoundaryId
        this.preparationApplyBoundaryReceipt = preparationApplyBoundaryReceipt
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunRecorded =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAllowed =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAllowed
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

public func buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunReceipt(
    preparationApplyBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunRequest
): IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunNonClaims()
    if (
        !preparationApplyBoundaryReceipt
            .runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunReceipt(
            false,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryAccepted,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryMode,
            "none",
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId,
            preparationApplyBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId,
            preparationApplyBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
            preparationApplyBoundaryReceipt.controlledPreparationApplyId,
            preparationApplyBoundaryReceipt.preparationApplyGateId,
            preparationApplyBoundaryReceipt.preparationDryRunId,
            preparationApplyBoundaryReceipt.preparationBoundaryId,
            preparationApplyBoundaryReceipt.preparationGateId,
            preparationApplyBoundaryReceipt.closeoutBoundaryGateId,
            preparationApplyBoundaryReceipt.closeoutBoundaryId,
            preparationApplyBoundaryReceipt.closeoutId,
            preparationApplyBoundaryReceipt.applyBoundaryGateId,
            preparationApplyBoundaryReceipt.applyBoundaryId,
            preparationApplyBoundaryReceipt.handoffBoundaryId,
            preparationApplyBoundaryReceipt.controlledHandoffId,
            preparationApplyBoundaryReceipt.closeoutGateId,
            preparationApplyBoundaryReceipt.acceptanceBoundaryId,
            preparationApplyBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-boundary-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-boundary-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_BOUNDARY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0553 runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout boundary gate preparation apply-boundary input before preparation apply-dry-run work",
            "QUIC must not consume runtime default-path mutation preparation apply-dry-run receipts from rejected preparation apply-boundary receipts"
        )
    }

    let preparationApplyDryRunMode =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunModeFor(
            preparationApplyBoundaryReceipt
                .runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunBlockers(
            request,
            preparationApplyDryRunMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunReceipt(
            false,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryAccepted,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryMode,
            preparationApplyDryRunMode,
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId,
            preparationApplyBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId,
            preparationApplyBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId,
            preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
            preparationApplyBoundaryReceipt.controlledPreparationApplyId,
            preparationApplyBoundaryReceipt.preparationApplyGateId,
            preparationApplyBoundaryReceipt.preparationDryRunId,
            preparationApplyBoundaryReceipt.preparationBoundaryId,
            preparationApplyBoundaryReceipt.preparationGateId,
            preparationApplyBoundaryReceipt.closeoutBoundaryGateId,
            preparationApplyBoundaryReceipt.closeoutBoundaryId,
            preparationApplyBoundaryReceipt.closeoutId,
            preparationApplyBoundaryReceipt.applyBoundaryGateId,
            preparationApplyBoundaryReceipt.applyBoundaryId,
            preparationApplyBoundaryReceipt.handoffBoundaryId,
            preparationApplyBoundaryReceipt.controlledHandoffId,
            preparationApplyBoundaryReceipt.closeoutGateId,
            preparationApplyBoundaryReceipt.acceptanceBoundaryId,
            preparationApplyBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-input",
            "fix-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-before-runtime-default-mutation",
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
            "QUIC can reuse the same runtime default-path mutation preparation apply-dry-run blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunReceipt(
        true,
        preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryAccepted,
        preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryMode,
        preparationApplyDryRunMode,
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunId,
        preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryId,
        preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationAcceptanceBoundaryId,
        preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationHandoffGateId,
        preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCloseoutGateId,
        preparationApplyBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationApplyId,
        preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationFinalizationGateId,
        preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitBoundaryId,
        preparationApplyBoundaryReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyId,
        preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitApplyGateId,
        preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitDryRunId,
        preparationApplyBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationCommitPlanId,
        preparationApplyBoundaryReceipt.controlledPreparationApplyId,
        preparationApplyBoundaryReceipt.preparationApplyGateId,
        preparationApplyBoundaryReceipt.preparationDryRunId,
        preparationApplyBoundaryReceipt.preparationBoundaryId,
        preparationApplyBoundaryReceipt.preparationGateId,
        preparationApplyBoundaryReceipt.closeoutBoundaryGateId,
        preparationApplyBoundaryReceipt.closeoutBoundaryId,
        preparationApplyBoundaryReceipt.closeoutId,
        preparationApplyBoundaryReceipt.applyBoundaryGateId,
        preparationApplyBoundaryReceipt.applyBoundaryId,
        preparationApplyBoundaryReceipt.handoffBoundaryId,
        preparationApplyBoundaryReceipt.controlledHandoffId,
        preparationApplyBoundaryReceipt.closeoutGateId,
        preparationApplyBoundaryReceipt.acceptanceBoundaryId,
        preparationApplyBoundaryReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run",
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-receipt",
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout boundary gate preparation apply dry-run gate without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation apply-dry-run modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunModeFor(
    preparationApplyBoundaryMode: String
): String {
    if (
        preparationApplyBoundaryMode ==
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-boundary"
    ) {
        return "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run"
    }
    if (
        preparationApplyBoundaryMode ==
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-boundary"
    ) {
        return "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run"
    }
    if (
        preparationApplyBoundaryMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-boundary"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run"
    }
    "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run"
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunRequest,
    preparationApplyDryRunMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_ID_NOT_CARRIED")
    }
    if (!request.preparationApplyBoundaryReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_BOUNDARY_RECEIPT_NOT_CARRIED")
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
        "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_BOUNDARY")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyBoundaryNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateRequest {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateId: String
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateId: String,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateId
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

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateReceipt {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunId: String
    public let preparationApplyDryRunReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunReceipt
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateAllowed: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunId: String,
        preparationApplyDryRunReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunReceipt,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateAllowed: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunId
        this.preparationApplyDryRunReceipt = preparationApplyDryRunReceipt
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateRecorded =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateAllowed =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateAllowed
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

public func buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateReceipt(
    preparationApplyDryRunReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateRequest
): IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateNonClaims()
    if (
        !preparationApplyDryRunReceipt
            .runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateReceipt(
            false,
            preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAccepted,
            preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunMode,
            "none",
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateId,
            preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunId,
            preparationApplyDryRunReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0554 runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout boundary gate preparation apply-dry-run input before preparation apply-dry-run gate work",
            "QUIC must not consume runtime default-path mutation preparation apply-dry-run gate receipts from rejected preparation apply-dry-run receipts"
        )
    }

    let preparationApplyDryRunGateMode =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateModeFor(
            preparationApplyDryRunReceipt
                .runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateBlockers(
            request,
            preparationApplyDryRunGateMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateReceipt(
            false,
            preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAccepted,
            preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunMode,
            preparationApplyDryRunGateMode,
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateId,
            preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunId,
            preparationApplyDryRunReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-gate-input",
            "fix-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-gate-before-runtime-default-mutation",
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
            "QUIC can reuse the same runtime default-path mutation preparation apply-dry-run gate blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateReceipt(
        true,
        preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAccepted,
        preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunMode,
        preparationApplyDryRunGateMode,
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateId,
        preparationApplyDryRunReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunId,
        preparationApplyDryRunReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-gate",
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-gate-receipt",
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-gate-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout boundary gate preparation acceptance boundary without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation apply-dry-run gate modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateModeFor(
    preparationApplyDryRunMode: String
): String {
    if (
        preparationApplyDryRunMode ==
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run"
    ) {
        return "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-gate"
    }
    if (
        preparationApplyDryRunMode ==
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run"
    ) {
        return "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-gate"
    }
    if (
        preparationApplyDryRunMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-gate"
    }
    "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-gate"
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateRequest,
    preparationApplyDryRunGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_GATE_ID_NOT_CARRIED")
    }
    if (!request.preparationApplyDryRunReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_RECEIPT_NOT_CARRIED")
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
        "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-gate"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_MODE")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryRequest {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId: String
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId: String,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId
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

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryReceipt {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateId: String
    public let preparationApplyDryRunGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateReceipt
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryAllowed: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateId: String,
        preparationApplyDryRunGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateReceipt,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryAllowed: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateId
        this.preparationApplyDryRunGateReceipt =
            preparationApplyDryRunGateReceipt
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryRecorded =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryAllowed =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryAllowed
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

public func buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryReceipt(
    preparationApplyDryRunGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryRequest
): IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryNonClaims()
    if (
        !preparationApplyDryRunGateReceipt
            .runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryReceipt(
            false,
            preparationApplyDryRunGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateAccepted,
            preparationApplyDryRunGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateMode,
            "none",
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId,
            preparationApplyDryRunGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateId,
            preparationApplyDryRunGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-gate-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0555 runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout boundary gate preparation apply-dry-run gate input before preparation apply-dry-run acceptance-boundary work",
            "QUIC must not consume runtime default-path mutation preparation apply-dry-run acceptance-boundary receipts from rejected preparation apply-dry-run gate receipts"
        )
    }

    let acceptanceBoundaryMode =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryModeFor(
            preparationApplyDryRunGateReceipt
                .runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryBlockers(
            request,
            acceptanceBoundaryMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryReceipt(
            false,
            preparationApplyDryRunGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateAccepted,
            preparationApplyDryRunGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateMode,
            acceptanceBoundaryMode,
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId,
            preparationApplyDryRunGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateId,
            preparationApplyDryRunGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-acceptance-boundary-input",
            "fix-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-acceptance-boundary-before-runtime-default-mutation",
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
            "carry preparation apply-dry-run acceptance boundary id, preparation apply-dry-run gate receipt, runtime default-path mutation lock, acceptance boundary marker, downstream consumer boundary, rollback order, runtime guard plan, observability marker, apply audit marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation preparation apply-dry-run acceptance-boundary blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryReceipt(
        true,
        preparationApplyDryRunGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateAccepted,
        preparationApplyDryRunGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateMode,
        acceptanceBoundaryMode,
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId,
        preparationApplyDryRunGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateId,
        preparationApplyDryRunGateReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-acceptance-boundary",
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-acceptance-boundary-receipt",
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-acceptance-boundary-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout boundary gate preparation apply-dry-run closeout gate without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation apply-dry-run acceptance-boundary modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryModeFor(
    preparationApplyDryRunGateMode: String
): String {
    if (
        preparationApplyDryRunGateMode ==
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-gate"
    ) {
        return "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-acceptance-boundary"
    }
    if (
        preparationApplyDryRunGateMode ==
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-gate"
    ) {
        return "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-acceptance-boundary"
    }
    if (
        preparationApplyDryRunGateMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-gate"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-acceptance-boundary"
    }
    "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-acceptance-boundary"
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryRequest,
    acceptanceBoundaryMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_ACCEPTANCE_BOUNDARY_ID_NOT_CARRIED")
    }
    if (!request.preparationApplyDryRunGateReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_GATE_RECEIPT_NOT_CARRIED")
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
        "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-acceptance-boundary"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_GATE")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunGateNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateRequest {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateId: String
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateId: String,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateId
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

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateReceipt {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId: String
    public let preparationApplyDryRunAcceptanceBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryReceipt
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateAllowed: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId: String,
        preparationApplyDryRunAcceptanceBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryReceipt,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateAllowed: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId
        this.preparationApplyDryRunAcceptanceBoundaryReceipt =
            preparationApplyDryRunAcceptanceBoundaryReceipt
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateRecorded =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateAllowed =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateAllowed
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

public func buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateReceipt(
    preparationApplyDryRunAcceptanceBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateRequest
): IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateNonClaims()
    if (
        !preparationApplyDryRunAcceptanceBoundaryReceipt
            .runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateReceipt(
            false,
            preparationApplyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryAccepted,
            preparationApplyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryMode,
            "none",
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateId,
            preparationApplyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId,
            preparationApplyDryRunAcceptanceBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-acceptance-boundary-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-acceptance-boundary-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_ACCEPTANCE_BOUNDARY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0556 runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout boundary gate preparation apply-dry-run acceptance-boundary input before closeout-gate work",
            "QUIC must not consume runtime default-path mutation preparation apply-dry-run closeout-gate receipts from rejected preparation apply-dry-run acceptance-boundary receipts"
        )
    }

    let closeoutGateMode =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateModeFor(
            preparationApplyDryRunAcceptanceBoundaryReceipt
                .runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateBlockers(
            request,
            closeoutGateMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateReceipt(
            false,
            preparationApplyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryAccepted,
            preparationApplyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryMode,
            closeoutGateMode,
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateId,
            preparationApplyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId,
            preparationApplyDryRunAcceptanceBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-closeout-gate-input",
            "fix-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-closeout-gate-before-runtime-default-mutation",
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
            "carry preparation apply-dry-run closeout gate id, accepted preparation apply-dry-run acceptance-boundary receipt, runtime default-path mutation lock, closeout gate marker, downstream consumer boundary, rollback order, runtime guard plan, observability marker, closeout audit marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation preparation apply-dry-run closeout-gate blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateReceipt(
        true,
        preparationApplyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryAccepted,
        preparationApplyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryMode,
        closeoutGateMode,
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateId,
        preparationApplyDryRunAcceptanceBoundaryReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId,
        preparationApplyDryRunAcceptanceBoundaryReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-closeout-gate",
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-closeout-gate-receipt",
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-closeout-gate-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout boundary gate controlled handoff without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation apply-dry-run closeout-gate modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateModeFor(
    acceptanceBoundaryMode: String
): String {
    if (
        acceptanceBoundaryMode ==
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-acceptance-boundary"
    ) {
        return "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-closeout-gate"
    }
    if (
        acceptanceBoundaryMode ==
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-acceptance-boundary"
    ) {
        return "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-closeout-gate"
    }
    if (
        acceptanceBoundaryMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-acceptance-boundary"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-closeout-gate"
    }
    "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-closeout-gate"
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateRequest,
    closeoutGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_CLOSEOUT_GATE_ID_NOT_CARRIED")
    }
    if (!request.preparationApplyDryRunAcceptanceBoundaryReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_ACCEPTANCE_BOUNDARY_RECEIPT_NOT_CARRIED")
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
        "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-closeout-gate"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_ACCEPTANCE_BOUNDARY")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryNonClaims()
}

public class IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffRequest {
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffId: String
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
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffId: String,
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
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffId =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffId
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

public class IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffReceipt {
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateAccepted: Bool
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateMode: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffMode: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId: String
    public let preparationApplyDryRunCloseoutGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateReceipt
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffAllowed: Bool
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
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateAccepted: Bool,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateMode: String,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffMode: String,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId: String,
        preparationApplyDryRunCloseoutGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateReceipt,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffAllowed: Bool,
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
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffAccepted =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateAccepted
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateMode
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffMode =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffMode
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffId =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId
        this.preparationApplyDryRunCloseoutGateReceipt =
            preparationApplyDryRunCloseoutGateReceipt
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffRecorded =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffAllowed =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffAllowed
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

public func buildIgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffReceipt(
    preparationApplyDryRunCloseoutGateReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateReceipt,
    request: IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffRequest
): IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffReceipt {
    let nonClaims =
        igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffNonClaims()
    if (
        !preparationApplyDryRunCloseoutGateReceipt
            .runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateAccepted
    ) {
        return IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffReceipt(
            false,
            preparationApplyDryRunCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateAccepted,
            preparationApplyDryRunCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateMode,
            "none",
            request.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffId,
            preparationApplyDryRunCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateId,
            preparationApplyDryRunCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId,
            preparationApplyDryRunCloseoutGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-closeout-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-closeout-gate-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_CLOSEOUT_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0557 runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout boundary gate preparation apply-dry-run closeout-gate input before controlled handoff work",
            "QUIC must not consume controlled runtime default-path mutation preparation apply dry-run handoff receipts from rejected closeout gates"
        )
    }

    let handoffMode =
        igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffModeFor(
            preparationApplyDryRunCloseoutGateReceipt
                .runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateMode
        )
    let blockers =
        igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBlockers(
            request,
            handoffMode
        )
    if (blockers.size > 0) {
        return IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffReceipt(
            false,
            preparationApplyDryRunCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateAccepted,
            preparationApplyDryRunCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateMode,
            handoffMode,
            request.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffId,
            preparationApplyDryRunCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateId,
            preparationApplyDryRunCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId,
            preparationApplyDryRunCloseoutGateReceipt,
            false,
            "block",
            "blocked-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff-input",
            "fix-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff-before-runtime-default-mutation",
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

    IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffReceipt(
        true,
        preparationApplyDryRunCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateAccepted,
        preparationApplyDryRunCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateMode,
        handoffMode,
        request.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffId,
        preparationApplyDryRunCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateId,
        preparationApplyDryRunCloseoutGateReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId,
        preparationApplyDryRunCloseoutGateReceipt,
        true,
        "record-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff",
        "accepted-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff-receipt",
        "record-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout boundary gate preparation apply-dry-run handoff boundary without mutating runtime defaults",
        "QUIC can reuse lane-specific controlled runtime default-path mutation preparation apply dry-run handoff modes before runtime default mutation"
    )
}

func igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffModeFor(
    closeoutGateMode: String
): String {
    if (
        closeoutGateMode ==
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-closeout-gate"
    ) {
        return "short-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff"
    }
    if (
        closeoutGateMode ==
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-closeout-gate"
    ) {
        return "long-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff"
    }
    if (
        closeoutGateMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-closeout-gate"
    ) {
        return "blocking-isolation-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff"
    }
    "unknown-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff"
}

func igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBlockers(
    request: IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffRequest,
    handoffMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffId.size == 0
    ) {
        blockers.add("CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_HANDOFF_ID_NOT_CARRIED")
    }
    if (!request.preparationApplyDryRunCloseoutGateReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_CLOSEOUT_GATE_RECEIPT_NOT_CARRIED")
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
        "unknown-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_CLOSEOUT_GATE")
    }
    blockers.toArray()
}

func igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateNonClaims()
}

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryRequest {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryId: String
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryId: String,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryId
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

public class IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryReceipt {
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryAccepted: Bool
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffAccepted: Bool
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryMode: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryId: String
    public let controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateId: String
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId: String
    public let controlledPreparationApplyDryRunHandoffReceipt: IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffReceipt
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryAllowed: Bool
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
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryAccepted: Bool,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffAccepted: Bool,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryMode: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryId: String,
        controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateId: String,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId: String,
        controlledPreparationApplyDryRunHandoffReceipt: IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffReceipt,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryAllowed: Bool,
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
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryAccepted =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryAccepted
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffAccepted =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffAccepted
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffMode =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryMode =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryMode
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryId
        this.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffId =
            controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateId
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId
        this.controlledPreparationApplyDryRunHandoffReceipt =
            controlledPreparationApplyDryRunHandoffReceipt
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryRecorded =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryAllowed =
            runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryAllowed
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

public func buildIgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryReceipt(
    controlledPreparationApplyDryRunHandoffReceipt: IgniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffReceipt,
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryRequest
): IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryNonClaims()
    if (
        !controlledPreparationApplyDryRunHandoffReceipt
            .controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryReceipt(
            false,
            controlledPreparationApplyDryRunHandoffReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffAccepted,
            controlledPreparationApplyDryRunHandoffReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffMode,
            "none",
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryId,
            controlledPreparationApplyDryRunHandoffReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffId,
            controlledPreparationApplyDryRunHandoffReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateId,
            controlledPreparationApplyDryRunHandoffReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId,
            controlledPreparationApplyDryRunHandoffReceipt,
            false,
            "block",
            "blocked-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff-receipt",
            "collect-accepted-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff-receipt-first",
            ["CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_HANDOFF_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0558 controlled runtime default-path mutation preparation apply dry-run handoff input before handoff-boundary work",
            "QUIC must not consume runtime default-path mutation preparation apply dry-run handoff-boundary receipts from rejected controlled handoffs"
        )
    }

    let handoffBoundaryMode =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryModeFor(
            controlledPreparationApplyDryRunHandoffReceipt
                .controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryBlockers(
            request,
            handoffBoundaryMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryReceipt(
            false,
            controlledPreparationApplyDryRunHandoffReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffAccepted,
            controlledPreparationApplyDryRunHandoffReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffMode,
            handoffBoundaryMode,
            request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryId,
            controlledPreparationApplyDryRunHandoffReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffId,
            controlledPreparationApplyDryRunHandoffReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateId,
            controlledPreparationApplyDryRunHandoffReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId,
            controlledPreparationApplyDryRunHandoffReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff-boundary-input",
            "fix-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff-boundary-before-runtime-default-mutation",
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
            "carry preparation apply-dry-run handoff-boundary id, accepted controlled handoff receipt, runtime default-path mutation lock, handoff-boundary marker, downstream consumer boundary, rollback order, runtime guard plan, observability marker, boundary audit marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation preparation apply dry-run handoff-boundary blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryReceipt(
        true,
        controlledPreparationApplyDryRunHandoffReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffAccepted,
        controlledPreparationApplyDryRunHandoffReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffMode,
        handoffBoundaryMode,
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryId,
        controlledPreparationApplyDryRunHandoffReceipt.controlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffId,
        controlledPreparationApplyDryRunHandoffReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunCloseoutGateId,
        controlledPreparationApplyDryRunHandoffReceipt.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunAcceptanceBoundaryId,
        controlledPreparationApplyDryRunHandoffReceipt,
        true,
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff-boundary",
        "accepted-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff-boundary-receipt",
        "record-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff-boundary-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation preparation apply dry-run handoff apply-boundary gate closeout boundary gate preparation apply-dry-run handoff apply-boundary without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation preparation apply dry-run handoff-boundary modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryModeFor(
    controlledHandoffMode: String
): String {
    if (
        controlledHandoffMode ==
        "short-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff"
    ) {
        return "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff-boundary"
    }
    if (
        controlledHandoffMode ==
        "long-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff"
    ) {
        return "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff-boundary"
    }
    if (
        controlledHandoffMode ==
        "blocking-isolation-controlled-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff-boundary"
    }
    "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff-boundary"
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryBlockers(
    request: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryRequest,
    handoffBoundaryMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryId.size == 0
    ) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_HANDOFF_BOUNDARY_ID_NOT_CARRIED")
    }
    if (!request.controlledPreparationApplyDryRunHandoffReceiptCarried) {
        blockers.add("CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_HANDOFF_RECEIPT_NOT_CARRIED")
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
        "unknown-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff-boundary"
    ) {
        blockers.add("UNKNOWN_CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_PREPARATION_APPLY_DRY_RUN_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_GATE_PREPARATION_APPLY_DRY_RUN_HANDOFF")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryNonClaims(): Array<String> {
    igniteControlledRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffNonClaims()
}

public class IgniteRuntimeDefaultPathMutationBoundarySummary {
    public let runtimeDefaultPathMutationBoundarySummaryAccepted: Bool
    public let sourceHandoffBoundaryAccepted: Bool
    public let sourceHandoffBoundaryMode: String
    public let sourceHandoffBoundaryId: String
    public let summaryAlias: String
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
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
        runtimeDefaultPathMutationBoundarySummaryAccepted: Bool,
        sourceHandoffBoundaryAccepted: Bool,
        sourceHandoffBoundaryMode: String,
        sourceHandoffBoundaryId: String,
        summaryAlias: String,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
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
        this.runtimeDefaultPathMutationBoundarySummaryAccepted =
            runtimeDefaultPathMutationBoundarySummaryAccepted
        this.sourceHandoffBoundaryAccepted = sourceHandoffBoundaryAccepted
        this.sourceHandoffBoundaryMode = sourceHandoffBoundaryMode
        this.sourceHandoffBoundaryId = sourceHandoffBoundaryId
        this.summaryAlias = summaryAlias
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
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

public func buildIgniteRuntimeDefaultPathMutationBoundarySummary(
    handoffBoundaryReceipt: IgniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryReceipt
): IgniteRuntimeDefaultPathMutationBoundarySummary {
    let nonClaims =
        igniteRuntimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryNonClaims()
    if (
        !handoffBoundaryReceipt
            .runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationBoundarySummary(
            false,
            handoffBoundaryReceipt
                .runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryAccepted,
            handoffBoundaryReceipt
                .runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryMode,
            handoffBoundaryReceipt
                .runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryId,
            "runtime-default-path-boundary-summary-unavailable",
            "block",
            "blocked-runtime-default-path-mutation-boundary-summary-input",
            "carry-accepted-runtime-default-path-mutation-handoff-boundary-before-summary",
            ["RUNTIME_DEFAULT_PATH_MUTATION_HANDOFF_BOUNDARY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0559 handoff-boundary receipt before summary consumption",
            "QUIC must not consume runtime default-path mutation boundary summaries from rejected handoff-boundary receipts"
        )
    }

    let summaryAlias =
        igniteRuntimeDefaultPathMutationBoundarySummaryAliasFor(
            handoffBoundaryReceipt
                .runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryMode
        )
    if (summaryAlias == "runtime-default-path-boundary-summary:unknown") {
        return IgniteRuntimeDefaultPathMutationBoundarySummary(
            false,
            handoffBoundaryReceipt
                .runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryAccepted,
            handoffBoundaryReceipt
                .runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryMode,
            handoffBoundaryReceipt
                .runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryId,
            summaryAlias,
            "block",
            "blocked-runtime-default-path-mutation-boundary-summary-mode",
            "map-runtime-default-path-mutation-handoff-boundary-mode-before-summary",
            ["UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_HANDOFF_BOUNDARY_MODE"],
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "map the accepted handoff-boundary mode before downstream consumption",
            "QUIC summary aliases must only consume known lane modes"
        )
    }

    IgniteRuntimeDefaultPathMutationBoundarySummary(
        true,
        handoffBoundaryReceipt
            .runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryAccepted,
        handoffBoundaryReceipt
            .runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryMode,
        handoffBoundaryReceipt
            .runtimeDefaultPathMutationPreparationApplyDryRunHandoffApplyBoundaryGateCloseoutBoundaryGatePreparationApplyDryRunHandoffBoundaryId,
        summaryAlias,
        "record-runtime-default-path-mutation-boundary-summary",
        "accepted-runtime-default-path-mutation-boundary-summary-receipt",
        "summary-alias-ready-without-runtime-default-mutation",
        [],
        false,
        false,
        false,
        false,
        false,
        false,
        nonClaims,
        "downstream packets may consume this short summary alias instead of extending the handoff-boundary suffix chain",
        "QUIC can reuse the short boundary summary alias for stream runtime mutation preparation without claiming runtime closure"
    )
}

func igniteRuntimeDefaultPathMutationBoundarySummaryAliasFor(
    handoffBoundaryMode: String
): String {
    if (
        handoffBoundaryMode ==
        "short-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff-boundary"
    ) {
        return "runtime-default-path-boundary-summary:short"
    }
    if (
        handoffBoundaryMode ==
        "long-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff-boundary"
    ) {
        return "runtime-default-path-boundary-summary:long"
    }
    if (
        handoffBoundaryMode ==
        "blocking-isolation-runtime-default-path-mutation-preparation-apply-dry-run-handoff-apply-boundary-gate-closeout-boundary-gate-preparation-apply-dry-run-handoff-boundary"
    ) {
        return "runtime-default-path-boundary-summary:blocking-isolation"
    }
    "runtime-default-path-boundary-summary:unknown"
}

public class IgniteRuntimeDefaultPathExecutionChainGateRequest {
    public let executionChainGateId: String
    public let boundarySummaryCarried: Bool
    public let schedulerBoundaryCarried: Bool
    public let requestContextGateCarried: Bool
    public let responseWriteGateCarried: Bool
    public let transportCommitGateCarried: Bool
    public let liveServerWiringGateCarried: Bool
    public let rollbackPlanCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let actualDefaultEngineFlipRequested: Bool
    public let defaultEngineConfigMutationRequested: Bool
    public let runtimeDefaultPathMutationRequested: Bool
    public let publicReleaseRequested: Bool
    public let stdxRemovalRequested: Bool
    public let h1H2QuicRuntimeClosureClaimed: Bool

    public init(
        executionChainGateId: String,
        boundarySummaryCarried: Bool,
        schedulerBoundaryCarried: Bool,
        requestContextGateCarried: Bool,
        responseWriteGateCarried: Bool,
        transportCommitGateCarried: Bool,
        liveServerWiringGateCarried: Bool,
        rollbackPlanCarried: Bool,
        observabilityMarkerCarried: Bool,
        actualDefaultEngineFlipRequested: Bool,
        defaultEngineConfigMutationRequested: Bool,
        runtimeDefaultPathMutationRequested: Bool,
        publicReleaseRequested: Bool,
        stdxRemovalRequested: Bool,
        h1H2QuicRuntimeClosureClaimed: Bool
    ) {
        this.executionChainGateId = executionChainGateId
        this.boundarySummaryCarried = boundarySummaryCarried
        this.schedulerBoundaryCarried = schedulerBoundaryCarried
        this.requestContextGateCarried = requestContextGateCarried
        this.responseWriteGateCarried = responseWriteGateCarried
        this.transportCommitGateCarried = transportCommitGateCarried
        this.liveServerWiringGateCarried = liveServerWiringGateCarried
        this.rollbackPlanCarried = rollbackPlanCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
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

public class IgniteRuntimeDefaultPathExecutionChainGateReceipt {
    public let executionChainGateAccepted: Bool
    public let boundarySummaryAccepted: Bool
    public let summaryAlias: String
    public let executionChainGateId: String
    public let executionChainGateMode: String
    public let boundarySummary: IgniteRuntimeDefaultPathMutationBoundarySummary
    public let executionChainGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let executionChainGateAllowed: Bool
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
        executionChainGateAccepted: Bool,
        boundarySummaryAccepted: Bool,
        summaryAlias: String,
        executionChainGateId: String,
        executionChainGateMode: String,
        boundarySummary: IgniteRuntimeDefaultPathMutationBoundarySummary,
        executionChainGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        executionChainGateAllowed: Bool,
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
        this.executionChainGateAccepted = executionChainGateAccepted
        this.boundarySummaryAccepted = boundarySummaryAccepted
        this.summaryAlias = summaryAlias
        this.executionChainGateId = executionChainGateId
        this.executionChainGateMode = executionChainGateMode
        this.boundarySummary = boundarySummary
        this.executionChainGateRecorded = executionChainGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.executionChainGateAllowed = executionChainGateAllowed
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

public func buildIgniteRuntimeDefaultPathExecutionChainGateReceipt(
    boundarySummary: IgniteRuntimeDefaultPathMutationBoundarySummary,
    request: IgniteRuntimeDefaultPathExecutionChainGateRequest
): IgniteRuntimeDefaultPathExecutionChainGateReceipt {
    let nonClaims = igniteRuntimeDefaultPathExecutionChainGateNonClaims()
    if (!boundarySummary.runtimeDefaultPathMutationBoundarySummaryAccepted) {
        return IgniteRuntimeDefaultPathExecutionChainGateReceipt(
            false,
            boundarySummary.runtimeDefaultPathMutationBoundarySummaryAccepted,
            boundarySummary.summaryAlias,
            request.executionChainGateId,
            "none",
            boundarySummary,
            false,
            "block",
            "blocked-runtime-default-path-boundary-summary",
            "collect-accepted-runtime-default-path-boundary-summary-first",
            ["RUNTIME_DEFAULT_PATH_BOUNDARY_SUMMARY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0560 summary alias before execution-chain gating",
            "QUIC must not consume runtime default-path execution-chain gates from rejected summaries"
        )
    }

    let executionChainGateMode =
        igniteRuntimeDefaultPathExecutionChainGateModeFor(
            boundarySummary.summaryAlias
        )
    let blockers = igniteRuntimeDefaultPathExecutionChainGateBlockers(
        request,
        executionChainGateMode
    )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathExecutionChainGateReceipt(
            false,
            boundarySummary.runtimeDefaultPathMutationBoundarySummaryAccepted,
            boundarySummary.summaryAlias,
            request.executionChainGateId,
            executionChainGateMode,
            boundarySummary,
            false,
            "block",
            "blocked-runtime-default-path-execution-chain-gate-input",
            "fix-execution-chain-gate-before-runtime-default-path-apply",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry scheduler boundary, request-context gate, response-write gate, transport-commit gate, live-server-wiring gate, rollback plan, observability marker, and keep default mutation out",
            "QUIC can reuse execution-chain blockers before stream default-path mutation gates"
        )
    }

    IgniteRuntimeDefaultPathExecutionChainGateReceipt(
        true,
        boundarySummary.runtimeDefaultPathMutationBoundarySummaryAccepted,
        boundarySummary.summaryAlias,
        request.executionChainGateId,
        executionChainGateMode,
        boundarySummary,
        true,
        "record-runtime-default-path-execution-chain-gate",
        "accepted-runtime-default-path-execution-chain-gate-receipt",
        "execution-chain-ready-without-runtime-default-path-mutation",
        [],
        true,
        false,
        false,
        false,
        false,
        false,
        false,
        nonClaims,
        "next packet may prove a runtime default-path apply gate without flipping defaults or mutating config",
        "QUIC can reuse the execution-chain gate modes before stream runtime default-path apply gates"
    )
}

func igniteRuntimeDefaultPathExecutionChainGateModeFor(
    summaryAlias: String
): String {
    if (summaryAlias == "runtime-default-path-boundary-summary:short") {
        return "short-runtime-default-path-execution-chain-gate"
    }
    if (summaryAlias == "runtime-default-path-boundary-summary:long") {
        return "long-runtime-default-path-execution-chain-gate"
    }
    if (
        summaryAlias ==
        "runtime-default-path-boundary-summary:blocking-isolation"
    ) {
        return "blocking-isolation-runtime-default-path-execution-chain-gate"
    }
    "unknown-runtime-default-path-execution-chain-gate"
}

func igniteRuntimeDefaultPathExecutionChainGateBlockers(
    request: IgniteRuntimeDefaultPathExecutionChainGateRequest,
    executionChainGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.executionChainGateId.size == 0) {
        blockers.add("RUNTIME_DEFAULT_PATH_EXECUTION_CHAIN_GATE_ID_NOT_CARRIED")
    }
    if (!request.boundarySummaryCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_BOUNDARY_SUMMARY_NOT_CARRIED")
    }
    if (!request.schedulerBoundaryCarried) {
        blockers.add("SCHEDULER_BOUNDARY_NOT_CARRIED")
    }
    if (!request.requestContextGateCarried) {
        blockers.add("REQUEST_CONTEXT_GATE_NOT_CARRIED")
    }
    if (!request.responseWriteGateCarried) {
        blockers.add("RESPONSE_WRITE_GATE_NOT_CARRIED")
    }
    if (!request.transportCommitGateCarried) {
        blockers.add("TRANSPORT_COMMIT_GATE_NOT_CARRIED")
    }
    if (!request.liveServerWiringGateCarried) {
        blockers.add("LIVE_SERVER_WIRING_GATE_NOT_CARRIED")
    }
    if (!request.rollbackPlanCarried) {
        blockers.add("ROLLBACK_PLAN_NOT_CARRIED")
    }
    if (!request.observabilityMarkerCarried) {
        blockers.add("OBSERVABILITY_MARKER_NOT_CARRIED")
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
        executionChainGateMode ==
        "unknown-runtime-default-path-execution-chain-gate"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_BOUNDARY_SUMMARY_ALIAS")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathExecutionChainGateNonClaims(): Array<String> {
    [
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_PUBLIC_RELEASE",
        "NO_STDX_REMOVAL",
        "NO_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
    ]
}
