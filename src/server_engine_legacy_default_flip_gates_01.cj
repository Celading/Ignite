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

public class IgniteDefaultEngineFlipApplyGateRequest {
    public let defaultEngineFlipApplyGateId: String
    public let readinessGateSnapshotCarried: Bool
    public let candidateEngineIdCarried: Bool
    public let defaultRouteMutationPlanCarried: Bool
    public let configurationIsolationPlanCarried: Bool
    public let rollbackVerificationPlanCarried: Bool
    public let releaseGuardSnapshotCarried: Bool
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
    public let publicReleaseRequested: Bool
    public let stdxRemovalRequested: Bool
    public let h1H2QuicRuntimeClosureClaimed: Bool

    public init(
        defaultEngineFlipApplyGateId: String,
        readinessGateSnapshotCarried: Bool,
        candidateEngineIdCarried: Bool,
        defaultRouteMutationPlanCarried: Bool,
        configurationIsolationPlanCarried: Bool,
        rollbackVerificationPlanCarried: Bool,
        releaseGuardSnapshotCarried: Bool,
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
        publicReleaseRequested: Bool,
        stdxRemovalRequested: Bool,
        h1H2QuicRuntimeClosureClaimed: Bool
    ) {
        this.defaultEngineFlipApplyGateId = defaultEngineFlipApplyGateId
        this.readinessGateSnapshotCarried = readinessGateSnapshotCarried
        this.candidateEngineIdCarried = candidateEngineIdCarried
        this.defaultRouteMutationPlanCarried = defaultRouteMutationPlanCarried
        this.configurationIsolationPlanCarried =
            configurationIsolationPlanCarried
        this.rollbackVerificationPlanCarried = rollbackVerificationPlanCarried
        this.releaseGuardSnapshotCarried = releaseGuardSnapshotCarried
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
        this.publicReleaseRequested = publicReleaseRequested
        this.stdxRemovalRequested = stdxRemovalRequested
        this.h1H2QuicRuntimeClosureClaimed = h1H2QuicRuntimeClosureClaimed
    }
}

public class IgniteDefaultEngineFlipApplyGateReceipt {
    public let defaultEngineFlipApplyGateAccepted: Bool
    public let defaultEngineFlipReadinessAccepted: Bool
    public let defaultEngineFlipReadinessMode: String
    public let defaultEngineFlipApplyGateMode: String
    public let defaultEngineFlipApplyGateId: String
    public let defaultEngineFlipReadinessGateId: String
    public let liveServerWiringGateId: String
    public let transportCommitGateId: String
    public let responseWriteGateId: String
    public let requestContextMutationGateId: String
    public let handlerInvocationGateId: String
    public let runtimeSpawnGateId: String
    public let liveEnqueueProofId: String
    public let executorHandoffId: String
    public let controlledMutationApplyId: String
    public let mutationApplyGateId: String
    public let mutationCommitPlanId: String
    public let mutationDryRunId: String
    public let mutationGateId: String
    public let commitBoundaryId: String
    public let queueWriteId: String
    public let queueDepthBefore: Int64
    public let queueDepthAfter: Int64
    public let defaultEngineFlipApplyGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let defaultEngineFlipApplyGateAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let actualHandlerInvocationAllowed: Bool
    public let actualRequestContextMutationAllowed: Bool
    public let actualResponseWriteAllowed: Bool
    public let actualTransportCommitAllowed: Bool
    public let actualLiveServerWiringAllowed: Bool
    public let actualDefaultEngineFlipAllowed: Bool
    public let defaultEngineConfigMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h1H2QuicRuntimeClosureClaimAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        defaultEngineFlipApplyGateAccepted: Bool,
        defaultEngineFlipReadinessAccepted: Bool,
        defaultEngineFlipReadinessMode: String,
        defaultEngineFlipApplyGateMode: String,
        defaultEngineFlipApplyGateId: String,
        defaultEngineFlipReadinessGateId: String,
        liveServerWiringGateId: String,
        transportCommitGateId: String,
        responseWriteGateId: String,
        requestContextMutationGateId: String,
        handlerInvocationGateId: String,
        runtimeSpawnGateId: String,
        liveEnqueueProofId: String,
        executorHandoffId: String,
        controlledMutationApplyId: String,
        mutationApplyGateId: String,
        mutationCommitPlanId: String,
        mutationDryRunId: String,
        mutationGateId: String,
        commitBoundaryId: String,
        queueWriteId: String,
        queueDepthBefore: Int64,
        queueDepthAfter: Int64,
        defaultEngineFlipApplyGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        defaultEngineFlipApplyGateAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        actualHandlerInvocationAllowed: Bool,
        actualRequestContextMutationAllowed: Bool,
        actualResponseWriteAllowed: Bool,
        actualTransportCommitAllowed: Bool,
        actualLiveServerWiringAllowed: Bool,
        actualDefaultEngineFlipAllowed: Bool,
        defaultEngineConfigMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h1H2QuicRuntimeClosureClaimAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.defaultEngineFlipApplyGateAccepted =
            defaultEngineFlipApplyGateAccepted
        this.defaultEngineFlipReadinessAccepted =
            defaultEngineFlipReadinessAccepted
        this.defaultEngineFlipReadinessMode = defaultEngineFlipReadinessMode
        this.defaultEngineFlipApplyGateMode = defaultEngineFlipApplyGateMode
        this.defaultEngineFlipApplyGateId = defaultEngineFlipApplyGateId
        this.defaultEngineFlipReadinessGateId =
            defaultEngineFlipReadinessGateId
        this.liveServerWiringGateId = liveServerWiringGateId
        this.transportCommitGateId = transportCommitGateId
        this.responseWriteGateId = responseWriteGateId
        this.requestContextMutationGateId = requestContextMutationGateId
        this.handlerInvocationGateId = handlerInvocationGateId
        this.runtimeSpawnGateId = runtimeSpawnGateId
        this.liveEnqueueProofId = liveEnqueueProofId
        this.executorHandoffId = executorHandoffId
        this.controlledMutationApplyId = controlledMutationApplyId
        this.mutationApplyGateId = mutationApplyGateId
        this.mutationCommitPlanId = mutationCommitPlanId
        this.mutationDryRunId = mutationDryRunId
        this.mutationGateId = mutationGateId
        this.commitBoundaryId = commitBoundaryId
        this.queueWriteId = queueWriteId
        this.queueDepthBefore = queueDepthBefore
        this.queueDepthAfter = queueDepthAfter
        this.defaultEngineFlipApplyGateRecorded =
            defaultEngineFlipApplyGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.defaultEngineFlipApplyGateAllowed =
            defaultEngineFlipApplyGateAllowed
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
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h1H2QuicRuntimeClosureClaimAllowed =
            h1H2QuicRuntimeClosureClaimAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteDefaultEngineFlipApplyGateReceipt(
    readinessReceipt: IgniteDefaultEngineFlipReadinessGateReceipt,
    request: IgniteDefaultEngineFlipApplyGateRequest
): IgniteDefaultEngineFlipApplyGateReceipt {
    let nonClaims = igniteDefaultEngineFlipApplyGateNonClaims()
    if (!readinessReceipt.defaultEngineFlipReadinessAccepted) {
        return IgniteDefaultEngineFlipApplyGateReceipt(
            false,
            readinessReceipt.defaultEngineFlipReadinessAccepted,
            readinessReceipt.defaultEngineFlipReadinessMode,
            "none",
            request.defaultEngineFlipApplyGateId,
            readinessReceipt.defaultEngineFlipReadinessGateId,
            readinessReceipt.liveServerWiringGateId,
            readinessReceipt.transportCommitGateId,
            readinessReceipt.responseWriteGateId,
            readinessReceipt.requestContextMutationGateId,
            readinessReceipt.handlerInvocationGateId,
            readinessReceipt.runtimeSpawnGateId,
            readinessReceipt.liveEnqueueProofId,
            readinessReceipt.executorHandoffId,
            readinessReceipt.controlledMutationApplyId,
            readinessReceipt.mutationApplyGateId,
            readinessReceipt.mutationCommitPlanId,
            readinessReceipt.mutationDryRunId,
            readinessReceipt.mutationGateId,
            readinessReceipt.commitBoundaryId,
            readinessReceipt.queueWriteId,
            readinessReceipt.queueDepthBefore,
            readinessReceipt.queueDepthAfter,
            false,
            "block",
            "blocked-default-engine-flip-readiness-gate-receipt",
            "collect-accepted-default-engine-flip-readiness-gate-receipt-first",
            ["DEFAULT_ENGINE_FLIP_READINESS_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
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
            "return to HQ-0477 default-engine-flip readiness input before apply-gate work",
            "QUIC must not consume default-engine-flip apply-gate receipts from rejected readiness gates"
        )
    }

    let applyGateMode = igniteDefaultEngineFlipApplyGateModeFor(
        readinessReceipt.defaultEngineFlipReadinessMode
    )
    let blockers = igniteDefaultEngineFlipApplyGateBlockers(
        request,
        applyGateMode
    )
    if (blockers.size > 0) {
        return IgniteDefaultEngineFlipApplyGateReceipt(
            false,
            readinessReceipt.defaultEngineFlipReadinessAccepted,
            readinessReceipt.defaultEngineFlipReadinessMode,
            applyGateMode,
            request.defaultEngineFlipApplyGateId,
            readinessReceipt.defaultEngineFlipReadinessGateId,
            readinessReceipt.liveServerWiringGateId,
            readinessReceipt.transportCommitGateId,
            readinessReceipt.responseWriteGateId,
            readinessReceipt.requestContextMutationGateId,
            readinessReceipt.handlerInvocationGateId,
            readinessReceipt.runtimeSpawnGateId,
            readinessReceipt.liveEnqueueProofId,
            readinessReceipt.executorHandoffId,
            readinessReceipt.controlledMutationApplyId,
            readinessReceipt.mutationApplyGateId,
            readinessReceipt.mutationCommitPlanId,
            readinessReceipt.mutationDryRunId,
            readinessReceipt.mutationGateId,
            readinessReceipt.commitBoundaryId,
            readinessReceipt.queueWriteId,
            readinessReceipt.queueDepthBefore,
            readinessReceipt.queueDepthAfter,
            false,
            "block",
            "blocked-default-engine-flip-apply-gate-input",
            "fix-default-engine-flip-apply-gate-before-default-mutation",
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
            nonClaims,
            "carry apply gate id, readiness snapshot, candidate engine id, default-route mutation plan, config isolation plan, rollback verification, release guard, and keep default mutation out",
            "QUIC can reuse the same default-engine-flip apply-gate blockers before default stream runtime mutation"
        )
    }

    IgniteDefaultEngineFlipApplyGateReceipt(
        true,
        readinessReceipt.defaultEngineFlipReadinessAccepted,
        readinessReceipt.defaultEngineFlipReadinessMode,
        applyGateMode,
        request.defaultEngineFlipApplyGateId,
        readinessReceipt.defaultEngineFlipReadinessGateId,
        readinessReceipt.liveServerWiringGateId,
        readinessReceipt.transportCommitGateId,
        readinessReceipt.responseWriteGateId,
        readinessReceipt.requestContextMutationGateId,
        readinessReceipt.handlerInvocationGateId,
        readinessReceipt.runtimeSpawnGateId,
        readinessReceipt.liveEnqueueProofId,
        readinessReceipt.executorHandoffId,
        readinessReceipt.controlledMutationApplyId,
        readinessReceipt.mutationApplyGateId,
        readinessReceipt.mutationCommitPlanId,
        readinessReceipt.mutationDryRunId,
        readinessReceipt.mutationGateId,
        readinessReceipt.commitBoundaryId,
        readinessReceipt.queueWriteId,
        readinessReceipt.queueDepthBefore,
        readinessReceipt.queueDepthAfter,
        true,
        "record-default-engine-flip-apply-gate",
        "accepted-default-engine-flip-apply-gate-receipt",
        "record-default-engine-flip-apply-gate-without-default-engine-mutation",
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
        nonClaims,
        "next packet may prove controlled default-engine-flip apply without flipping the default engine",
        "QUIC can reuse lane-specific default-engine-flip apply modes before runtime default mutation"
    )
}

func igniteDefaultEngineFlipApplyGateModeFor(
    readinessMode: String
): String {
    if (readinessMode == "short-default-engine-flip-readiness-gate") {
        return "short-default-engine-flip-apply-gate"
    }
    if (readinessMode == "long-default-engine-flip-readiness-gate") {
        return "long-default-engine-flip-apply-gate"
    }
    if (readinessMode == "blocking-isolation-default-engine-flip-readiness-gate") {
        return "blocking-isolation-default-engine-flip-apply-gate"
    }
    "unknown-default-engine-flip-apply-gate"
}

func igniteDefaultEngineFlipApplyGateBlockers(
    request: IgniteDefaultEngineFlipApplyGateRequest,
    applyGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.defaultEngineFlipApplyGateId.size == 0) {
        blockers.add("DEFAULT_ENGINE_FLIP_APPLY_GATE_ID_NOT_CARRIED")
    }
    if (!request.readinessGateSnapshotCarried) {
        blockers.add("DEFAULT_ENGINE_FLIP_READINESS_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.candidateEngineIdCarried) {
        blockers.add("CANDIDATE_ENGINE_ID_NOT_CARRIED")
    }
    if (!request.defaultRouteMutationPlanCarried) {
        blockers.add("DEFAULT_ROUTE_MUTATION_PLAN_NOT_CARRIED")
    }
    if (!request.configurationIsolationPlanCarried) {
        blockers.add("CONFIGURATION_ISOLATION_PLAN_NOT_CARRIED")
    }
    if (!request.rollbackVerificationPlanCarried) {
        blockers.add("ROLLBACK_VERIFICATION_PLAN_NOT_CARRIED")
    }
    if (!request.releaseGuardSnapshotCarried) {
        blockers.add("RELEASE_GUARD_SNAPSHOT_NOT_CARRIED")
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
    if (request.publicReleaseRequested) {
        blockers.add("PUBLIC_RELEASE_REQUESTED")
    }
    if (request.stdxRemovalRequested) {
        blockers.add("STDX_REMOVAL_REQUESTED")
    }
    if (request.h1H2QuicRuntimeClosureClaimed) {
        blockers.add("H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    }
    if (applyGateMode == "unknown-default-engine-flip-apply-gate") {
        blockers.add("UNKNOWN_DEFAULT_ENGINE_FLIP_READINESS_GATE")
    }
    blockers.toArray()
}

func igniteDefaultEngineFlipApplyGateNonClaims(): Array<String> {
    [
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_H1_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
        "NO_ACTUAL_LIVE_SERVER_WIRING",
        "NO_PRODUCTION_QUEUE_MUTATION",
        "NO_ACTUAL_RUNTIME_TASK_SPAWN",
        "NO_ACTUAL_HANDLER_INVOCATION",
        "NO_ACTUAL_REQUEST_CONTEXT_MUTATION",
        "NO_ACTUAL_RESPONSE_WRITE",
        "NO_ACTUAL_TRANSPORT_COMMIT",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
    ]
}

public class IgniteControlledDefaultEngineFlipApplyRequest {
    public let controlledDefaultEngineFlipApplyId: String
    public let applyGateSnapshotCarried: Bool
    public let candidateEngineIdCarried: Bool
    public let isolatedConfigDraftCarried: Bool
    public let defaultRouteMutationDryRunCarried: Bool
    public let rollbackCheckpointCarried: Bool
    public let operatorApprovalMarkerCarried: Bool
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
        controlledDefaultEngineFlipApplyId: String,
        applyGateSnapshotCarried: Bool,
        candidateEngineIdCarried: Bool,
        isolatedConfigDraftCarried: Bool,
        defaultRouteMutationDryRunCarried: Bool,
        rollbackCheckpointCarried: Bool,
        operatorApprovalMarkerCarried: Bool,
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
        this.controlledDefaultEngineFlipApplyId =
            controlledDefaultEngineFlipApplyId
        this.applyGateSnapshotCarried = applyGateSnapshotCarried
        this.candidateEngineIdCarried = candidateEngineIdCarried
        this.isolatedConfigDraftCarried = isolatedConfigDraftCarried
        this.defaultRouteMutationDryRunCarried =
            defaultRouteMutationDryRunCarried
        this.rollbackCheckpointCarried = rollbackCheckpointCarried
        this.operatorApprovalMarkerCarried = operatorApprovalMarkerCarried
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

public class IgniteControlledDefaultEngineFlipApplyReceipt {
    public let controlledDefaultEngineFlipApplyAccepted: Bool
    public let defaultEngineFlipApplyGateAccepted: Bool
    public let defaultEngineFlipApplyGateMode: String
    public let controlledDefaultEngineFlipApplyMode: String
    public let controlledDefaultEngineFlipApplyId: String
    public let defaultEngineFlipApplyGateId: String
    public let defaultEngineFlipReadinessGateId: String
    public let liveServerWiringGateId: String
    public let transportCommitGateId: String
    public let responseWriteGateId: String
    public let requestContextMutationGateId: String
    public let handlerInvocationGateId: String
    public let runtimeSpawnGateId: String
    public let liveEnqueueProofId: String
    public let executorHandoffId: String
    public let controlledMutationApplyId: String
    public let mutationApplyGateId: String
    public let mutationCommitPlanId: String
    public let mutationDryRunId: String
    public let mutationGateId: String
    public let commitBoundaryId: String
    public let queueWriteId: String
    public let queueDepthBefore: Int64
    public let queueDepthAfter: Int64
    public let controlledDefaultEngineFlipApplyRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let controlledDefaultEngineFlipApplyAllowed: Bool
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
        controlledDefaultEngineFlipApplyAccepted: Bool,
        defaultEngineFlipApplyGateAccepted: Bool,
        defaultEngineFlipApplyGateMode: String,
        controlledDefaultEngineFlipApplyMode: String,
        controlledDefaultEngineFlipApplyId: String,
        defaultEngineFlipApplyGateId: String,
        defaultEngineFlipReadinessGateId: String,
        liveServerWiringGateId: String,
        transportCommitGateId: String,
        responseWriteGateId: String,
        requestContextMutationGateId: String,
        handlerInvocationGateId: String,
        runtimeSpawnGateId: String,
        liveEnqueueProofId: String,
        executorHandoffId: String,
        controlledMutationApplyId: String,
        mutationApplyGateId: String,
        mutationCommitPlanId: String,
        mutationDryRunId: String,
        mutationGateId: String,
        commitBoundaryId: String,
        queueWriteId: String,
        queueDepthBefore: Int64,
        queueDepthAfter: Int64,
        controlledDefaultEngineFlipApplyRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        controlledDefaultEngineFlipApplyAllowed: Bool,
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
        this.controlledDefaultEngineFlipApplyAccepted =
            controlledDefaultEngineFlipApplyAccepted
        this.defaultEngineFlipApplyGateAccepted =
            defaultEngineFlipApplyGateAccepted
        this.defaultEngineFlipApplyGateMode = defaultEngineFlipApplyGateMode
        this.controlledDefaultEngineFlipApplyMode =
            controlledDefaultEngineFlipApplyMode
        this.controlledDefaultEngineFlipApplyId =
            controlledDefaultEngineFlipApplyId
        this.defaultEngineFlipApplyGateId = defaultEngineFlipApplyGateId
        this.defaultEngineFlipReadinessGateId =
            defaultEngineFlipReadinessGateId
        this.liveServerWiringGateId = liveServerWiringGateId
        this.transportCommitGateId = transportCommitGateId
        this.responseWriteGateId = responseWriteGateId
        this.requestContextMutationGateId = requestContextMutationGateId
        this.handlerInvocationGateId = handlerInvocationGateId
        this.runtimeSpawnGateId = runtimeSpawnGateId
        this.liveEnqueueProofId = liveEnqueueProofId
        this.executorHandoffId = executorHandoffId
        this.controlledMutationApplyId = controlledMutationApplyId
        this.mutationApplyGateId = mutationApplyGateId
        this.mutationCommitPlanId = mutationCommitPlanId
        this.mutationDryRunId = mutationDryRunId
        this.mutationGateId = mutationGateId
        this.commitBoundaryId = commitBoundaryId
        this.queueWriteId = queueWriteId
        this.queueDepthBefore = queueDepthBefore
        this.queueDepthAfter = queueDepthAfter
        this.controlledDefaultEngineFlipApplyRecorded =
            controlledDefaultEngineFlipApplyRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.controlledDefaultEngineFlipApplyAllowed =
            controlledDefaultEngineFlipApplyAllowed
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

public func buildIgniteControlledDefaultEngineFlipApplyReceipt(
    applyGateReceipt: IgniteDefaultEngineFlipApplyGateReceipt,
    request: IgniteControlledDefaultEngineFlipApplyRequest
): IgniteControlledDefaultEngineFlipApplyReceipt {
    let nonClaims = igniteControlledDefaultEngineFlipApplyNonClaims()
    if (!applyGateReceipt.defaultEngineFlipApplyGateAccepted) {
        return IgniteControlledDefaultEngineFlipApplyReceipt(
            false,
            applyGateReceipt.defaultEngineFlipApplyGateAccepted,
            applyGateReceipt.defaultEngineFlipApplyGateMode,
            "none",
            request.controlledDefaultEngineFlipApplyId,
            applyGateReceipt.defaultEngineFlipApplyGateId,
            applyGateReceipt.defaultEngineFlipReadinessGateId,
            applyGateReceipt.liveServerWiringGateId,
            applyGateReceipt.transportCommitGateId,
            applyGateReceipt.responseWriteGateId,
            applyGateReceipt.requestContextMutationGateId,
            applyGateReceipt.handlerInvocationGateId,
            applyGateReceipt.runtimeSpawnGateId,
            applyGateReceipt.liveEnqueueProofId,
            applyGateReceipt.executorHandoffId,
            applyGateReceipt.controlledMutationApplyId,
            applyGateReceipt.mutationApplyGateId,
            applyGateReceipt.mutationCommitPlanId,
            applyGateReceipt.mutationDryRunId,
            applyGateReceipt.mutationGateId,
            applyGateReceipt.commitBoundaryId,
            applyGateReceipt.queueWriteId,
            applyGateReceipt.queueDepthBefore,
            applyGateReceipt.queueDepthAfter,
            false,
            "block",
            "blocked-default-engine-flip-apply-gate-receipt",
            "collect-accepted-default-engine-flip-apply-gate-receipt-first",
            ["DEFAULT_ENGINE_FLIP_APPLY_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0478 default-engine-flip apply-gate input before controlled apply work",
            "QUIC must not consume controlled default-engine-flip receipts from rejected apply gates"
        )
    }

    let controlledMode = igniteControlledDefaultEngineFlipApplyModeFor(
        applyGateReceipt.defaultEngineFlipApplyGateMode
    )
    let blockers = igniteControlledDefaultEngineFlipApplyBlockers(
        request,
        controlledMode
    )
    if (blockers.size > 0) {
        return IgniteControlledDefaultEngineFlipApplyReceipt(
            false,
            applyGateReceipt.defaultEngineFlipApplyGateAccepted,
            applyGateReceipt.defaultEngineFlipApplyGateMode,
            controlledMode,
            request.controlledDefaultEngineFlipApplyId,
            applyGateReceipt.defaultEngineFlipApplyGateId,
            applyGateReceipt.defaultEngineFlipReadinessGateId,
            applyGateReceipt.liveServerWiringGateId,
            applyGateReceipt.transportCommitGateId,
            applyGateReceipt.responseWriteGateId,
            applyGateReceipt.requestContextMutationGateId,
            applyGateReceipt.handlerInvocationGateId,
            applyGateReceipt.runtimeSpawnGateId,
            applyGateReceipt.liveEnqueueProofId,
            applyGateReceipt.executorHandoffId,
            applyGateReceipt.controlledMutationApplyId,
            applyGateReceipt.mutationApplyGateId,
            applyGateReceipt.mutationCommitPlanId,
            applyGateReceipt.mutationDryRunId,
            applyGateReceipt.mutationGateId,
            applyGateReceipt.commitBoundaryId,
            applyGateReceipt.queueWriteId,
            applyGateReceipt.queueDepthBefore,
            applyGateReceipt.queueDepthAfter,
            false,
            "block",
            "blocked-controlled-default-engine-flip-apply-input",
            "fix-controlled-default-engine-flip-apply-before-default-mutation",
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
            "carry controlled apply id, apply-gate snapshot, candidate engine id, isolated config draft, default-route dry-run, rollback checkpoint, approval marker, observability marker, and keep runtime default-path mutation out",
            "QUIC can reuse controlled default-engine-flip blockers before default stream runtime mutation"
        )
    }

    IgniteControlledDefaultEngineFlipApplyReceipt(
        true,
        applyGateReceipt.defaultEngineFlipApplyGateAccepted,
        applyGateReceipt.defaultEngineFlipApplyGateMode,
        controlledMode,
        request.controlledDefaultEngineFlipApplyId,
        applyGateReceipt.defaultEngineFlipApplyGateId,
        applyGateReceipt.defaultEngineFlipReadinessGateId,
        applyGateReceipt.liveServerWiringGateId,
        applyGateReceipt.transportCommitGateId,
        applyGateReceipt.responseWriteGateId,
        applyGateReceipt.requestContextMutationGateId,
        applyGateReceipt.handlerInvocationGateId,
        applyGateReceipt.runtimeSpawnGateId,
        applyGateReceipt.liveEnqueueProofId,
        applyGateReceipt.executorHandoffId,
        applyGateReceipt.controlledMutationApplyId,
        applyGateReceipt.mutationApplyGateId,
        applyGateReceipt.mutationCommitPlanId,
        applyGateReceipt.mutationDryRunId,
        applyGateReceipt.mutationGateId,
        applyGateReceipt.commitBoundaryId,
        applyGateReceipt.queueWriteId,
        applyGateReceipt.queueDepthBefore,
        applyGateReceipt.queueDepthAfter,
        true,
        "record-controlled-default-engine-flip-apply",
        "accepted-controlled-default-engine-flip-apply-receipt",
        "record-controlled-default-engine-flip-apply-without-default-mutation",
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
        "next packet may prove default-engine mutation commit-plan without mutating runtime defaults",
        "QUIC can reuse lane-specific controlled default-engine-flip apply modes before runtime default mutation"
    )
}

func igniteControlledDefaultEngineFlipApplyModeFor(
    applyGateMode: String
): String {
    if (applyGateMode == "short-default-engine-flip-apply-gate") {
        return "short-controlled-default-engine-flip-apply"
    }
    if (applyGateMode == "long-default-engine-flip-apply-gate") {
        return "long-controlled-default-engine-flip-apply"
    }
    if (applyGateMode == "blocking-isolation-default-engine-flip-apply-gate") {
        return "blocking-isolation-controlled-default-engine-flip-apply"
    }
    "unknown-controlled-default-engine-flip-apply"
}

func igniteControlledDefaultEngineFlipApplyBlockers(
    request: IgniteControlledDefaultEngineFlipApplyRequest,
    controlledMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.controlledDefaultEngineFlipApplyId.size == 0) {
        blockers.add("CONTROLLED_DEFAULT_ENGINE_FLIP_APPLY_ID_NOT_CARRIED")
    }
    if (!request.applyGateSnapshotCarried) {
        blockers.add("DEFAULT_ENGINE_FLIP_APPLY_GATE_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.candidateEngineIdCarried) {
        blockers.add("CANDIDATE_ENGINE_ID_NOT_CARRIED")
    }
    if (!request.isolatedConfigDraftCarried) {
        blockers.add("ISOLATED_CONFIG_DRAFT_NOT_CARRIED")
    }
    if (!request.defaultRouteMutationDryRunCarried) {
        blockers.add("DEFAULT_ROUTE_MUTATION_DRY_RUN_NOT_CARRIED")
    }
    if (!request.rollbackCheckpointCarried) {
        blockers.add("ROLLBACK_CHECKPOINT_NOT_CARRIED")
    }
    if (!request.operatorApprovalMarkerCarried) {
        blockers.add("OPERATOR_APPROVAL_MARKER_NOT_CARRIED")
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
    if (controlledMode == "unknown-controlled-default-engine-flip-apply") {
        blockers.add("UNKNOWN_DEFAULT_ENGINE_FLIP_APPLY_GATE")
    }
    blockers.toArray()
}

func igniteControlledDefaultEngineFlipApplyNonClaims(): Array<String> {
    [
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_H1_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
        "NO_ACTUAL_LIVE_SERVER_WIRING",
        "NO_PRODUCTION_QUEUE_MUTATION",
        "NO_ACTUAL_RUNTIME_TASK_SPAWN",
        "NO_ACTUAL_HANDLER_INVOCATION",
        "NO_ACTUAL_REQUEST_CONTEXT_MUTATION",
        "NO_ACTUAL_RESPONSE_WRITE",
        "NO_ACTUAL_TRANSPORT_COMMIT",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
    ]
}

public class IgniteDefaultEngineMutationCommitPlanRequest {
    public let defaultEngineMutationCommitPlanId: String
    public let controlledApplySnapshotCarried: Bool
    public let candidateEngineIdCarried: Bool
    public let mutationPlanIdCarried: Bool
    public let runtimeDefaultPathTargetCarried: Bool
    public let atomicSwitchPlanCarried: Bool
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
        defaultEngineMutationCommitPlanId: String,
        controlledApplySnapshotCarried: Bool,
        candidateEngineIdCarried: Bool,
        mutationPlanIdCarried: Bool,
        runtimeDefaultPathTargetCarried: Bool,
        atomicSwitchPlanCarried: Bool,
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
        this.defaultEngineMutationCommitPlanId =
            defaultEngineMutationCommitPlanId
        this.controlledApplySnapshotCarried = controlledApplySnapshotCarried
        this.candidateEngineIdCarried = candidateEngineIdCarried
        this.mutationPlanIdCarried = mutationPlanIdCarried
        this.runtimeDefaultPathTargetCarried = runtimeDefaultPathTargetCarried
        this.atomicSwitchPlanCarried = atomicSwitchPlanCarried
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

public class IgniteDefaultEngineMutationCommitPlanReceipt {
    public let defaultEngineMutationCommitPlanAccepted: Bool
    public let controlledDefaultEngineFlipApplyAccepted: Bool
    public let controlledDefaultEngineFlipApplyMode: String
    public let defaultEngineMutationCommitPlanMode: String
    public let defaultEngineMutationCommitPlanId: String
    public let controlledDefaultEngineFlipApplyId: String
    public let defaultEngineFlipApplyGateId: String
    public let defaultEngineFlipReadinessGateId: String
    public let liveServerWiringGateId: String
    public let transportCommitGateId: String
    public let responseWriteGateId: String
    public let requestContextMutationGateId: String
    public let handlerInvocationGateId: String
    public let runtimeSpawnGateId: String
    public let liveEnqueueProofId: String
    public let executorHandoffId: String
    public let controlledMutationApplyId: String
    public let mutationApplyGateId: String
    public let mutationCommitPlanId: String
    public let mutationDryRunId: String
    public let mutationGateId: String
    public let commitBoundaryId: String
    public let queueWriteId: String
    public let queueDepthBefore: Int64
    public let queueDepthAfter: Int64
    public let defaultEngineMutationCommitPlanRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let defaultEngineMutationCommitPlanAllowed: Bool
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
        defaultEngineMutationCommitPlanAccepted: Bool,
        controlledDefaultEngineFlipApplyAccepted: Bool,
        controlledDefaultEngineFlipApplyMode: String,
        defaultEngineMutationCommitPlanMode: String,
        defaultEngineMutationCommitPlanId: String,
        controlledDefaultEngineFlipApplyId: String,
        defaultEngineFlipApplyGateId: String,
        defaultEngineFlipReadinessGateId: String,
        liveServerWiringGateId: String,
        transportCommitGateId: String,
        responseWriteGateId: String,
        requestContextMutationGateId: String,
        handlerInvocationGateId: String,
        runtimeSpawnGateId: String,
        liveEnqueueProofId: String,
        executorHandoffId: String,
        controlledMutationApplyId: String,
        mutationApplyGateId: String,
        mutationCommitPlanId: String,
        mutationDryRunId: String,
        mutationGateId: String,
        commitBoundaryId: String,
        queueWriteId: String,
        queueDepthBefore: Int64,
        queueDepthAfter: Int64,
        defaultEngineMutationCommitPlanRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        defaultEngineMutationCommitPlanAllowed: Bool,
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
        this.defaultEngineMutationCommitPlanAccepted =
            defaultEngineMutationCommitPlanAccepted
        this.controlledDefaultEngineFlipApplyAccepted =
            controlledDefaultEngineFlipApplyAccepted
        this.controlledDefaultEngineFlipApplyMode =
            controlledDefaultEngineFlipApplyMode
        this.defaultEngineMutationCommitPlanMode =
            defaultEngineMutationCommitPlanMode
        this.defaultEngineMutationCommitPlanId =
            defaultEngineMutationCommitPlanId
        this.controlledDefaultEngineFlipApplyId =
            controlledDefaultEngineFlipApplyId
        this.defaultEngineFlipApplyGateId = defaultEngineFlipApplyGateId
        this.defaultEngineFlipReadinessGateId =
            defaultEngineFlipReadinessGateId
        this.liveServerWiringGateId = liveServerWiringGateId
        this.transportCommitGateId = transportCommitGateId
        this.responseWriteGateId = responseWriteGateId
        this.requestContextMutationGateId = requestContextMutationGateId
        this.handlerInvocationGateId = handlerInvocationGateId
        this.runtimeSpawnGateId = runtimeSpawnGateId
        this.liveEnqueueProofId = liveEnqueueProofId
        this.executorHandoffId = executorHandoffId
        this.controlledMutationApplyId = controlledMutationApplyId
        this.mutationApplyGateId = mutationApplyGateId
        this.mutationCommitPlanId = mutationCommitPlanId
        this.mutationDryRunId = mutationDryRunId
        this.mutationGateId = mutationGateId
        this.commitBoundaryId = commitBoundaryId
        this.queueWriteId = queueWriteId
        this.queueDepthBefore = queueDepthBefore
        this.queueDepthAfter = queueDepthAfter
        this.defaultEngineMutationCommitPlanRecorded =
            defaultEngineMutationCommitPlanRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.defaultEngineMutationCommitPlanAllowed =
            defaultEngineMutationCommitPlanAllowed
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

public func buildIgniteDefaultEngineMutationCommitPlanReceipt(
    controlledApplyReceipt: IgniteControlledDefaultEngineFlipApplyReceipt,
    request: IgniteDefaultEngineMutationCommitPlanRequest
): IgniteDefaultEngineMutationCommitPlanReceipt {
    let nonClaims = igniteDefaultEngineMutationCommitPlanNonClaims()
    if (!controlledApplyReceipt.controlledDefaultEngineFlipApplyAccepted) {
        return IgniteDefaultEngineMutationCommitPlanReceipt(
            false,
            controlledApplyReceipt.controlledDefaultEngineFlipApplyAccepted,
            controlledApplyReceipt.controlledDefaultEngineFlipApplyMode,
            "none",
            request.defaultEngineMutationCommitPlanId,
            controlledApplyReceipt.controlledDefaultEngineFlipApplyId,
            controlledApplyReceipt.defaultEngineFlipApplyGateId,
            controlledApplyReceipt.defaultEngineFlipReadinessGateId,
            controlledApplyReceipt.liveServerWiringGateId,
            controlledApplyReceipt.transportCommitGateId,
            controlledApplyReceipt.responseWriteGateId,
            controlledApplyReceipt.requestContextMutationGateId,
            controlledApplyReceipt.handlerInvocationGateId,
            controlledApplyReceipt.runtimeSpawnGateId,
            controlledApplyReceipt.liveEnqueueProofId,
            controlledApplyReceipt.executorHandoffId,
            controlledApplyReceipt.controlledMutationApplyId,
            controlledApplyReceipt.mutationApplyGateId,
            controlledApplyReceipt.mutationCommitPlanId,
            controlledApplyReceipt.mutationDryRunId,
            controlledApplyReceipt.mutationGateId,
            controlledApplyReceipt.commitBoundaryId,
            controlledApplyReceipt.queueWriteId,
            controlledApplyReceipt.queueDepthBefore,
            controlledApplyReceipt.queueDepthAfter,
            false,
            "block",
            "blocked-controlled-default-engine-flip-apply-receipt",
            "collect-accepted-controlled-default-engine-flip-apply-receipt-first",
            ["CONTROLLED_DEFAULT_ENGINE_FLIP_APPLY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0479 controlled default-engine-flip apply input before commit-plan work",
            "QUIC must not consume default-engine mutation commit-plan receipts from rejected controlled apply receipts"
        )
    }

    let commitPlanMode = igniteDefaultEngineMutationCommitPlanModeFor(
        controlledApplyReceipt.controlledDefaultEngineFlipApplyMode
    )
    let blockers = igniteDefaultEngineMutationCommitPlanBlockers(
        request,
        commitPlanMode
    )
    if (blockers.size > 0) {
        return IgniteDefaultEngineMutationCommitPlanReceipt(
            false,
            controlledApplyReceipt.controlledDefaultEngineFlipApplyAccepted,
            controlledApplyReceipt.controlledDefaultEngineFlipApplyMode,
            commitPlanMode,
            request.defaultEngineMutationCommitPlanId,
            controlledApplyReceipt.controlledDefaultEngineFlipApplyId,
            controlledApplyReceipt.defaultEngineFlipApplyGateId,
            controlledApplyReceipt.defaultEngineFlipReadinessGateId,
            controlledApplyReceipt.liveServerWiringGateId,
            controlledApplyReceipt.transportCommitGateId,
            controlledApplyReceipt.responseWriteGateId,
            controlledApplyReceipt.requestContextMutationGateId,
            controlledApplyReceipt.handlerInvocationGateId,
            controlledApplyReceipt.runtimeSpawnGateId,
            controlledApplyReceipt.liveEnqueueProofId,
            controlledApplyReceipt.executorHandoffId,
            controlledApplyReceipt.controlledMutationApplyId,
            controlledApplyReceipt.mutationApplyGateId,
            controlledApplyReceipt.mutationCommitPlanId,
            controlledApplyReceipt.mutationDryRunId,
            controlledApplyReceipt.mutationGateId,
            controlledApplyReceipt.commitBoundaryId,
            controlledApplyReceipt.queueWriteId,
            controlledApplyReceipt.queueDepthBefore,
            controlledApplyReceipt.queueDepthAfter,
            false,
            "block",
            "blocked-default-engine-mutation-commit-plan-input",
            "fix-default-engine-mutation-commit-plan-before-default-mutation",
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
            "carry commit-plan id, controlled apply snapshot, candidate engine id, mutation plan id, runtime default-path target, atomic switch plan, rollback order, runtime guard plan, observability marker, and keep runtime default mutation out",
            "QUIC can reuse the same default-engine mutation commit-plan blockers before default stream runtime mutation"
        )
    }

    IgniteDefaultEngineMutationCommitPlanReceipt(
        true,
        controlledApplyReceipt.controlledDefaultEngineFlipApplyAccepted,
        controlledApplyReceipt.controlledDefaultEngineFlipApplyMode,
        commitPlanMode,
        request.defaultEngineMutationCommitPlanId,
        controlledApplyReceipt.controlledDefaultEngineFlipApplyId,
        controlledApplyReceipt.defaultEngineFlipApplyGateId,
        controlledApplyReceipt.defaultEngineFlipReadinessGateId,
        controlledApplyReceipt.liveServerWiringGateId,
        controlledApplyReceipt.transportCommitGateId,
        controlledApplyReceipt.responseWriteGateId,
        controlledApplyReceipt.requestContextMutationGateId,
        controlledApplyReceipt.handlerInvocationGateId,
        controlledApplyReceipt.runtimeSpawnGateId,
        controlledApplyReceipt.liveEnqueueProofId,
        controlledApplyReceipt.executorHandoffId,
        controlledApplyReceipt.controlledMutationApplyId,
        controlledApplyReceipt.mutationApplyGateId,
        controlledApplyReceipt.mutationCommitPlanId,
        controlledApplyReceipt.mutationDryRunId,
        controlledApplyReceipt.mutationGateId,
        controlledApplyReceipt.commitBoundaryId,
        controlledApplyReceipt.queueWriteId,
        controlledApplyReceipt.queueDepthBefore,
        controlledApplyReceipt.queueDepthAfter,
        true,
        "record-default-engine-mutation-commit-plan",
        "accepted-default-engine-mutation-commit-plan-receipt",
        "record-default-engine-mutation-commit-plan-without-default-mutation",
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
        "next packet may prove default-engine mutation dry-run without mutating runtime defaults",
        "QUIC can reuse lane-specific default-engine mutation commit-plan modes before runtime default mutation"
    )
}

func igniteDefaultEngineMutationCommitPlanModeFor(
    controlledMode: String
): String {
    if (controlledMode == "short-controlled-default-engine-flip-apply") {
        return "short-default-engine-mutation-commit-plan"
    }
    if (controlledMode == "long-controlled-default-engine-flip-apply") {
        return "long-default-engine-mutation-commit-plan"
    }
    if (controlledMode == "blocking-isolation-controlled-default-engine-flip-apply") {
        return "blocking-isolation-default-engine-mutation-commit-plan"
    }
    "unknown-default-engine-mutation-commit-plan"
}

func igniteDefaultEngineMutationCommitPlanBlockers(
    request: IgniteDefaultEngineMutationCommitPlanRequest,
    commitPlanMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.defaultEngineMutationCommitPlanId.size == 0) {
        blockers.add("DEFAULT_ENGINE_MUTATION_COMMIT_PLAN_ID_NOT_CARRIED")
    }
    if (!request.controlledApplySnapshotCarried) {
        blockers.add("CONTROLLED_DEFAULT_ENGINE_FLIP_APPLY_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.candidateEngineIdCarried) {
        blockers.add("CANDIDATE_ENGINE_ID_NOT_CARRIED")
    }
    if (!request.mutationPlanIdCarried) {
        blockers.add("MUTATION_PLAN_ID_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathTargetCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_TARGET_NOT_CARRIED")
    }
    if (!request.atomicSwitchPlanCarried) {
        blockers.add("ATOMIC_SWITCH_PLAN_NOT_CARRIED")
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
    if (commitPlanMode == "unknown-default-engine-mutation-commit-plan") {
        blockers.add("UNKNOWN_CONTROLLED_DEFAULT_ENGINE_FLIP_APPLY")
    }
    blockers.toArray()
}

func igniteDefaultEngineMutationCommitPlanNonClaims(): Array<String> {
    [
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_H1_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
        "NO_ACTUAL_LIVE_SERVER_WIRING",
        "NO_PRODUCTION_QUEUE_MUTATION",
        "NO_ACTUAL_RUNTIME_TASK_SPAWN",
        "NO_ACTUAL_HANDLER_INVOCATION",
        "NO_ACTUAL_REQUEST_CONTEXT_MUTATION",
        "NO_ACTUAL_RESPONSE_WRITE",
        "NO_ACTUAL_TRANSPORT_COMMIT",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
    ]
}

public class IgniteDefaultEngineMutationDryRunRequest {
    public let defaultEngineMutationDryRunId: String
    public let commitPlanSnapshotCarried: Bool
    public let candidateEngineIdCarried: Bool
    public let runtimeDefaultPathTargetCarried: Bool
    public let isolatedMutationPlanCarried: Bool
    public let dryRunSandboxCarried: Bool
    public let configDiffPreviewCarried: Bool
    public let rollbackSimulationCarried: Bool
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
        defaultEngineMutationDryRunId: String,
        commitPlanSnapshotCarried: Bool,
        candidateEngineIdCarried: Bool,
        runtimeDefaultPathTargetCarried: Bool,
        isolatedMutationPlanCarried: Bool,
        dryRunSandboxCarried: Bool,
        configDiffPreviewCarried: Bool,
        rollbackSimulationCarried: Bool,
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
        this.defaultEngineMutationDryRunId = defaultEngineMutationDryRunId
        this.commitPlanSnapshotCarried = commitPlanSnapshotCarried
        this.candidateEngineIdCarried = candidateEngineIdCarried
        this.runtimeDefaultPathTargetCarried = runtimeDefaultPathTargetCarried
        this.isolatedMutationPlanCarried = isolatedMutationPlanCarried
        this.dryRunSandboxCarried = dryRunSandboxCarried
        this.configDiffPreviewCarried = configDiffPreviewCarried
        this.rollbackSimulationCarried = rollbackSimulationCarried
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

public class IgniteDefaultEngineMutationDryRunReceipt {
    public let defaultEngineMutationDryRunAccepted: Bool
    public let defaultEngineMutationCommitPlanAccepted: Bool
    public let defaultEngineMutationCommitPlanMode: String
    public let defaultEngineMutationDryRunMode: String
    public let defaultEngineMutationDryRunId: String
    public let defaultEngineMutationCommitPlanId: String
    public let commitPlanReceipt: IgniteDefaultEngineMutationCommitPlanReceipt
    public let defaultEngineMutationDryRunRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let defaultEngineMutationDryRunAllowed: Bool
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
        defaultEngineMutationDryRunAccepted: Bool,
        defaultEngineMutationCommitPlanAccepted: Bool,
        defaultEngineMutationCommitPlanMode: String,
        defaultEngineMutationDryRunMode: String,
        defaultEngineMutationDryRunId: String,
        defaultEngineMutationCommitPlanId: String,
        commitPlanReceipt: IgniteDefaultEngineMutationCommitPlanReceipt,
        defaultEngineMutationDryRunRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        defaultEngineMutationDryRunAllowed: Bool,
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
        this.defaultEngineMutationDryRunAccepted =
            defaultEngineMutationDryRunAccepted
        this.defaultEngineMutationCommitPlanAccepted =
            defaultEngineMutationCommitPlanAccepted
        this.defaultEngineMutationCommitPlanMode =
            defaultEngineMutationCommitPlanMode
        this.defaultEngineMutationDryRunMode = defaultEngineMutationDryRunMode
        this.defaultEngineMutationDryRunId = defaultEngineMutationDryRunId
        this.defaultEngineMutationCommitPlanId =
            defaultEngineMutationCommitPlanId
        this.commitPlanReceipt = commitPlanReceipt
        this.defaultEngineMutationDryRunRecorded =
            defaultEngineMutationDryRunRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.defaultEngineMutationDryRunAllowed =
            defaultEngineMutationDryRunAllowed
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

public func buildIgniteDefaultEngineMutationDryRunReceipt(
    commitPlanReceipt: IgniteDefaultEngineMutationCommitPlanReceipt,
    request: IgniteDefaultEngineMutationDryRunRequest
): IgniteDefaultEngineMutationDryRunReceipt {
    let nonClaims = igniteDefaultEngineMutationDryRunNonClaims()
    if (!commitPlanReceipt.defaultEngineMutationCommitPlanAccepted) {
        return IgniteDefaultEngineMutationDryRunReceipt(
            false,
            commitPlanReceipt.defaultEngineMutationCommitPlanAccepted,
            commitPlanReceipt.defaultEngineMutationCommitPlanMode,
            "none",
            request.defaultEngineMutationDryRunId,
            commitPlanReceipt.defaultEngineMutationCommitPlanId,
            commitPlanReceipt,
            false,
            "block",
            "blocked-default-engine-mutation-commit-plan-receipt",
            "collect-accepted-default-engine-mutation-commit-plan-receipt-first",
            ["DEFAULT_ENGINE_MUTATION_COMMIT_PLAN_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0480 default-engine mutation commit-plan input before dry-run work",
            "QUIC must not consume default-engine mutation dry-run receipts from rejected commit-plan receipts"
        )
    }

    let dryRunMode = igniteDefaultEngineMutationDryRunModeFor(
        commitPlanReceipt.defaultEngineMutationCommitPlanMode
    )
    let blockers = igniteDefaultEngineMutationDryRunBlockers(
        request,
        dryRunMode
    )
    if (blockers.size > 0) {
        return IgniteDefaultEngineMutationDryRunReceipt(
            false,
            commitPlanReceipt.defaultEngineMutationCommitPlanAccepted,
            commitPlanReceipt.defaultEngineMutationCommitPlanMode,
            dryRunMode,
            request.defaultEngineMutationDryRunId,
            commitPlanReceipt.defaultEngineMutationCommitPlanId,
            commitPlanReceipt,
            false,
            "block",
            "blocked-default-engine-mutation-dry-run-input",
            "fix-default-engine-mutation-dry-run-before-default-mutation",
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
            "carry dry-run id, commit-plan snapshot, candidate engine id, runtime default-path target, isolated mutation plan, dry-run sandbox, config diff preview, rollback simulation, runtime guard plan, observability marker, and keep runtime default mutation out",
            "QUIC can reuse the same default-engine mutation dry-run blockers before default stream runtime mutation"
        )
    }

    IgniteDefaultEngineMutationDryRunReceipt(
        true,
        commitPlanReceipt.defaultEngineMutationCommitPlanAccepted,
        commitPlanReceipt.defaultEngineMutationCommitPlanMode,
        dryRunMode,
        request.defaultEngineMutationDryRunId,
        commitPlanReceipt.defaultEngineMutationCommitPlanId,
        commitPlanReceipt,
        true,
        "record-default-engine-mutation-dry-run",
        "accepted-default-engine-mutation-dry-run-receipt",
        "record-default-engine-mutation-dry-run-without-default-mutation",
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
        "next packet may prove default-engine mutation apply-gate without mutating runtime defaults",
        "QUIC can reuse lane-specific default-engine mutation dry-run modes before runtime default mutation"
    )
}

func igniteDefaultEngineMutationDryRunModeFor(
    commitPlanMode: String
): String {
    if (commitPlanMode == "short-default-engine-mutation-commit-plan") {
        return "short-default-engine-mutation-dry-run"
    }
    if (commitPlanMode == "long-default-engine-mutation-commit-plan") {
        return "long-default-engine-mutation-dry-run"
    }
    if (commitPlanMode == "blocking-isolation-default-engine-mutation-commit-plan") {
        return "blocking-isolation-default-engine-mutation-dry-run"
    }
    "unknown-default-engine-mutation-dry-run"
}

func igniteDefaultEngineMutationDryRunBlockers(
    request: IgniteDefaultEngineMutationDryRunRequest,
    dryRunMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.defaultEngineMutationDryRunId.size == 0) {
        blockers.add("DEFAULT_ENGINE_MUTATION_DRY_RUN_ID_NOT_CARRIED")
    }
    if (!request.commitPlanSnapshotCarried) {
        blockers.add("DEFAULT_ENGINE_MUTATION_COMMIT_PLAN_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.candidateEngineIdCarried) {
        blockers.add("CANDIDATE_ENGINE_ID_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathTargetCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_TARGET_NOT_CARRIED")
    }
    if (!request.isolatedMutationPlanCarried) {
        blockers.add("ISOLATED_MUTATION_PLAN_NOT_CARRIED")
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
    if (dryRunMode == "unknown-default-engine-mutation-dry-run") {
        blockers.add("UNKNOWN_DEFAULT_ENGINE_MUTATION_COMMIT_PLAN")
    }
    blockers.toArray()
}

func igniteDefaultEngineMutationDryRunNonClaims(): Array<String> {
    [
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_H1_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
        "NO_ACTUAL_LIVE_SERVER_WIRING",
        "NO_PRODUCTION_QUEUE_MUTATION",
        "NO_ACTUAL_RUNTIME_TASK_SPAWN",
        "NO_ACTUAL_HANDLER_INVOCATION",
        "NO_ACTUAL_REQUEST_CONTEXT_MUTATION",
        "NO_ACTUAL_RESPONSE_WRITE",
        "NO_ACTUAL_TRANSPORT_COMMIT",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
    ]
}

public class IgniteDefaultEngineMutationApplyGateRequest {
    public let defaultEngineMutationApplyGateId: String
    public let dryRunSnapshotCarried: Bool
    public let candidateEngineIdCarried: Bool
    public let runtimeDefaultPathTargetCarried: Bool
    public let applyPreconditionGateCarried: Bool
    public let configMutationLockCarried: Bool
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
        defaultEngineMutationApplyGateId: String,
        dryRunSnapshotCarried: Bool,
        candidateEngineIdCarried: Bool,
        runtimeDefaultPathTargetCarried: Bool,
        applyPreconditionGateCarried: Bool,
        configMutationLockCarried: Bool,
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
        this.defaultEngineMutationApplyGateId =
            defaultEngineMutationApplyGateId
        this.dryRunSnapshotCarried = dryRunSnapshotCarried
        this.candidateEngineIdCarried = candidateEngineIdCarried
        this.runtimeDefaultPathTargetCarried = runtimeDefaultPathTargetCarried
        this.applyPreconditionGateCarried = applyPreconditionGateCarried
        this.configMutationLockCarried = configMutationLockCarried
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

public class IgniteDefaultEngineMutationApplyGateReceipt {
    public let defaultEngineMutationApplyGateAccepted: Bool
    public let defaultEngineMutationDryRunAccepted: Bool
    public let defaultEngineMutationDryRunMode: String
    public let defaultEngineMutationApplyGateMode: String
    public let defaultEngineMutationApplyGateId: String
    public let defaultEngineMutationDryRunId: String
    public let defaultEngineMutationCommitPlanId: String
    public let dryRunReceipt: IgniteDefaultEngineMutationDryRunReceipt
    public let defaultEngineMutationApplyGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let defaultEngineMutationApplyGateAllowed: Bool
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
        defaultEngineMutationApplyGateAccepted: Bool,
        defaultEngineMutationDryRunAccepted: Bool,
        defaultEngineMutationDryRunMode: String,
        defaultEngineMutationApplyGateMode: String,
        defaultEngineMutationApplyGateId: String,
        defaultEngineMutationDryRunId: String,
        defaultEngineMutationCommitPlanId: String,
        dryRunReceipt: IgniteDefaultEngineMutationDryRunReceipt,
        defaultEngineMutationApplyGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        defaultEngineMutationApplyGateAllowed: Bool,
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
        this.defaultEngineMutationApplyGateAccepted =
            defaultEngineMutationApplyGateAccepted
        this.defaultEngineMutationDryRunAccepted =
            defaultEngineMutationDryRunAccepted
        this.defaultEngineMutationDryRunMode = defaultEngineMutationDryRunMode
        this.defaultEngineMutationApplyGateMode =
            defaultEngineMutationApplyGateMode
        this.defaultEngineMutationApplyGateId =
            defaultEngineMutationApplyGateId
        this.defaultEngineMutationDryRunId = defaultEngineMutationDryRunId
        this.defaultEngineMutationCommitPlanId =
            defaultEngineMutationCommitPlanId
        this.dryRunReceipt = dryRunReceipt
        this.defaultEngineMutationApplyGateRecorded =
            defaultEngineMutationApplyGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.defaultEngineMutationApplyGateAllowed =
            defaultEngineMutationApplyGateAllowed
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

public func buildIgniteDefaultEngineMutationApplyGateReceipt(
    dryRunReceipt: IgniteDefaultEngineMutationDryRunReceipt,
    request: IgniteDefaultEngineMutationApplyGateRequest
): IgniteDefaultEngineMutationApplyGateReceipt {
    let nonClaims = igniteDefaultEngineMutationApplyGateNonClaims()
    if (!dryRunReceipt.defaultEngineMutationDryRunAccepted) {
        return IgniteDefaultEngineMutationApplyGateReceipt(
            false,
            dryRunReceipt.defaultEngineMutationDryRunAccepted,
            dryRunReceipt.defaultEngineMutationDryRunMode,
            "none",
            request.defaultEngineMutationApplyGateId,
            dryRunReceipt.defaultEngineMutationDryRunId,
            dryRunReceipt.defaultEngineMutationCommitPlanId,
            dryRunReceipt,
            false,
            "block",
            "blocked-default-engine-mutation-dry-run-receipt",
            "collect-accepted-default-engine-mutation-dry-run-receipt-first",
            ["DEFAULT_ENGINE_MUTATION_DRY_RUN_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0481 default-engine mutation dry-run input before apply-gate work",
            "QUIC must not consume default-engine mutation apply-gate receipts from rejected dry-run receipts"
        )
    }

    let applyGateMode = igniteDefaultEngineMutationApplyGateModeFor(
        dryRunReceipt.defaultEngineMutationDryRunMode
    )
    let blockers = igniteDefaultEngineMutationApplyGateBlockers(
        request,
        applyGateMode
    )
    if (blockers.size > 0) {
        return IgniteDefaultEngineMutationApplyGateReceipt(
            false,
            dryRunReceipt.defaultEngineMutationDryRunAccepted,
            dryRunReceipt.defaultEngineMutationDryRunMode,
            applyGateMode,
            request.defaultEngineMutationApplyGateId,
            dryRunReceipt.defaultEngineMutationDryRunId,
            dryRunReceipt.defaultEngineMutationCommitPlanId,
            dryRunReceipt,
            false,
            "block",
            "blocked-default-engine-mutation-apply-gate-input",
            "fix-default-engine-mutation-apply-gate-before-default-mutation",
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
            "carry apply-gate id, dry-run snapshot, candidate engine id, runtime default-path target, apply precondition gate, config mutation lock, rollback order, runtime guard plan, observability marker, and keep runtime default mutation out",
            "QUIC can reuse the same default-engine mutation apply-gate blockers before default stream runtime mutation"
        )
    }

    IgniteDefaultEngineMutationApplyGateReceipt(
        true,
        dryRunReceipt.defaultEngineMutationDryRunAccepted,
        dryRunReceipt.defaultEngineMutationDryRunMode,
        applyGateMode,
        request.defaultEngineMutationApplyGateId,
        dryRunReceipt.defaultEngineMutationDryRunId,
        dryRunReceipt.defaultEngineMutationCommitPlanId,
        dryRunReceipt,
        true,
        "record-default-engine-mutation-apply-gate",
        "accepted-default-engine-mutation-apply-gate-receipt",
        "record-default-engine-mutation-apply-gate-without-default-mutation",
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
        "next packet may prove controlled default-engine mutation apply without mutating runtime defaults",
        "QUIC can reuse lane-specific default-engine mutation apply-gate modes before runtime default mutation"
    )
}

func igniteDefaultEngineMutationApplyGateModeFor(
    dryRunMode: String
): String {
    if (dryRunMode == "short-default-engine-mutation-dry-run") {
        return "short-default-engine-mutation-apply-gate"
    }
    if (dryRunMode == "long-default-engine-mutation-dry-run") {
        return "long-default-engine-mutation-apply-gate"
    }
    if (dryRunMode == "blocking-isolation-default-engine-mutation-dry-run") {
        return "blocking-isolation-default-engine-mutation-apply-gate"
    }
    "unknown-default-engine-mutation-apply-gate"
}

func igniteDefaultEngineMutationApplyGateBlockers(
    request: IgniteDefaultEngineMutationApplyGateRequest,
    applyGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.defaultEngineMutationApplyGateId.size == 0) {
        blockers.add("DEFAULT_ENGINE_MUTATION_APPLY_GATE_ID_NOT_CARRIED")
    }
    if (!request.dryRunSnapshotCarried) {
        blockers.add("DEFAULT_ENGINE_MUTATION_DRY_RUN_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.candidateEngineIdCarried) {
        blockers.add("CANDIDATE_ENGINE_ID_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathTargetCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_TARGET_NOT_CARRIED")
    }
    if (!request.applyPreconditionGateCarried) {
        blockers.add("APPLY_PRECONDITION_GATE_NOT_CARRIED")
    }
    if (!request.configMutationLockCarried) {
        blockers.add("CONFIG_MUTATION_LOCK_NOT_CARRIED")
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
    if (applyGateMode == "unknown-default-engine-mutation-apply-gate") {
        blockers.add("UNKNOWN_DEFAULT_ENGINE_MUTATION_DRY_RUN")
    }
    blockers.toArray()
}

func igniteDefaultEngineMutationApplyGateNonClaims(): Array<String> {
    [
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_H1_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
        "NO_ACTUAL_LIVE_SERVER_WIRING",
        "NO_PRODUCTION_QUEUE_MUTATION",
        "NO_ACTUAL_RUNTIME_TASK_SPAWN",
        "NO_ACTUAL_HANDLER_INVOCATION",
        "NO_ACTUAL_REQUEST_CONTEXT_MUTATION",
        "NO_ACTUAL_RESPONSE_WRITE",
        "NO_ACTUAL_TRANSPORT_COMMIT",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
    ]
}

public class IgniteControlledDefaultEngineMutationApplyRequest {
    public let controlledDefaultEngineMutationApplyId: String
    public let applyGateReceiptCarried: Bool
    public let controlledApplyScopeCarried: Bool
    public let defaultEngineMutationLockCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
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
        controlledDefaultEngineMutationApplyId: String,
        applyGateReceiptCarried: Bool,
        controlledApplyScopeCarried: Bool,
        defaultEngineMutationLockCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
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
        this.controlledDefaultEngineMutationApplyId =
            controlledDefaultEngineMutationApplyId
        this.applyGateReceiptCarried = applyGateReceiptCarried
        this.controlledApplyScopeCarried = controlledApplyScopeCarried
        this.defaultEngineMutationLockCarried =
            defaultEngineMutationLockCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
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

public class IgniteControlledDefaultEngineMutationApplyReceipt {
    public let controlledDefaultEngineMutationApplyAccepted: Bool
    public let defaultEngineMutationApplyGateAccepted: Bool
    public let defaultEngineMutationApplyGateMode: String
    public let controlledDefaultEngineMutationApplyMode: String
    public let controlledDefaultEngineMutationApplyId: String
    public let defaultEngineMutationApplyGateId: String
    public let defaultEngineMutationDryRunId: String
    public let defaultEngineMutationCommitPlanId: String
    public let applyGateReceipt: IgniteDefaultEngineMutationApplyGateReceipt
    public let controlledDefaultEngineMutationApplyRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let controlledDefaultEngineMutationApplyAllowed: Bool
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
        controlledDefaultEngineMutationApplyAccepted: Bool,
        defaultEngineMutationApplyGateAccepted: Bool,
        defaultEngineMutationApplyGateMode: String,
        controlledDefaultEngineMutationApplyMode: String,
        controlledDefaultEngineMutationApplyId: String,
        defaultEngineMutationApplyGateId: String,
        defaultEngineMutationDryRunId: String,
        defaultEngineMutationCommitPlanId: String,
        applyGateReceipt: IgniteDefaultEngineMutationApplyGateReceipt,
        controlledDefaultEngineMutationApplyRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        controlledDefaultEngineMutationApplyAllowed: Bool,
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
        this.controlledDefaultEngineMutationApplyAccepted =
            controlledDefaultEngineMutationApplyAccepted
        this.defaultEngineMutationApplyGateAccepted =
            defaultEngineMutationApplyGateAccepted
        this.defaultEngineMutationApplyGateMode =
            defaultEngineMutationApplyGateMode
        this.controlledDefaultEngineMutationApplyMode =
            controlledDefaultEngineMutationApplyMode
        this.controlledDefaultEngineMutationApplyId =
            controlledDefaultEngineMutationApplyId
        this.defaultEngineMutationApplyGateId =
            defaultEngineMutationApplyGateId
        this.defaultEngineMutationDryRunId = defaultEngineMutationDryRunId
        this.defaultEngineMutationCommitPlanId =
            defaultEngineMutationCommitPlanId
        this.applyGateReceipt = applyGateReceipt
        this.controlledDefaultEngineMutationApplyRecorded =
            controlledDefaultEngineMutationApplyRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.controlledDefaultEngineMutationApplyAllowed =
            controlledDefaultEngineMutationApplyAllowed
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

public func buildIgniteControlledDefaultEngineMutationApplyReceipt(
    applyGateReceipt: IgniteDefaultEngineMutationApplyGateReceipt,
    request: IgniteControlledDefaultEngineMutationApplyRequest
): IgniteControlledDefaultEngineMutationApplyReceipt {
    let nonClaims = igniteControlledDefaultEngineMutationApplyNonClaims()
    if (!applyGateReceipt.defaultEngineMutationApplyGateAccepted) {
        return IgniteControlledDefaultEngineMutationApplyReceipt(
            false,
            applyGateReceipt.defaultEngineMutationApplyGateAccepted,
            applyGateReceipt.defaultEngineMutationApplyGateMode,
            "none",
            request.controlledDefaultEngineMutationApplyId,
            applyGateReceipt.defaultEngineMutationApplyGateId,
            applyGateReceipt.defaultEngineMutationDryRunId,
            applyGateReceipt.defaultEngineMutationCommitPlanId,
            applyGateReceipt,
            false,
            "block",
            "blocked-default-engine-mutation-apply-gate-receipt",
            "collect-accepted-default-engine-mutation-apply-gate-receipt-first",
            ["DEFAULT_ENGINE_MUTATION_APPLY_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0482 default-engine mutation apply-gate input before controlled apply work",
            "QUIC must not consume controlled default-engine mutation apply receipts from rejected apply-gate receipts"
        )
    }

    let controlledApplyMode = igniteControlledDefaultEngineMutationApplyModeFor(
        applyGateReceipt.defaultEngineMutationApplyGateMode
    )
    let blockers = igniteControlledDefaultEngineMutationApplyBlockers(
        request,
        controlledApplyMode
    )
    if (blockers.size > 0) {
        return IgniteControlledDefaultEngineMutationApplyReceipt(
            false,
            applyGateReceipt.defaultEngineMutationApplyGateAccepted,
            applyGateReceipt.defaultEngineMutationApplyGateMode,
            controlledApplyMode,
            request.controlledDefaultEngineMutationApplyId,
            applyGateReceipt.defaultEngineMutationApplyGateId,
            applyGateReceipt.defaultEngineMutationDryRunId,
            applyGateReceipt.defaultEngineMutationCommitPlanId,
            applyGateReceipt,
            false,
            "block",
            "blocked-controlled-default-engine-mutation-apply-input",
            "fix-controlled-default-engine-mutation-apply-before-runtime-default-mutation",
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
            "carry controlled apply id, apply-gate receipt, controlled scope, mutation lock, runtime default-path lock, rollback order, runtime guard plan, observability marker, and keep runtime default mutation out",
            "QUIC can reuse the same controlled default-engine mutation apply blockers before default stream runtime mutation"
        )
    }

    IgniteControlledDefaultEngineMutationApplyReceipt(
        true,
        applyGateReceipt.defaultEngineMutationApplyGateAccepted,
        applyGateReceipt.defaultEngineMutationApplyGateMode,
        controlledApplyMode,
        request.controlledDefaultEngineMutationApplyId,
        applyGateReceipt.defaultEngineMutationApplyGateId,
        applyGateReceipt.defaultEngineMutationDryRunId,
        applyGateReceipt.defaultEngineMutationCommitPlanId,
        applyGateReceipt,
        true,
        "record-controlled-default-engine-mutation-apply",
        "accepted-controlled-default-engine-mutation-apply-receipt",
        "record-controlled-default-engine-mutation-apply-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation gate without mutating runtime defaults",
        "QUIC can reuse lane-specific controlled default-engine mutation apply modes before runtime default mutation"
    )
}

func igniteControlledDefaultEngineMutationApplyModeFor(
    applyGateMode: String
): String {
    if (applyGateMode == "short-default-engine-mutation-apply-gate") {
        return "short-controlled-default-engine-mutation-apply"
    }
    if (applyGateMode == "long-default-engine-mutation-apply-gate") {
        return "long-controlled-default-engine-mutation-apply"
    }
    if (applyGateMode == "blocking-isolation-default-engine-mutation-apply-gate") {
        return "blocking-isolation-controlled-default-engine-mutation-apply"
    }
    "unknown-controlled-default-engine-mutation-apply"
}

func igniteControlledDefaultEngineMutationApplyBlockers(
    request: IgniteControlledDefaultEngineMutationApplyRequest,
    controlledApplyMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.controlledDefaultEngineMutationApplyId.size == 0) {
        blockers.add("CONTROLLED_DEFAULT_ENGINE_MUTATION_APPLY_ID_NOT_CARRIED")
    }
    if (!request.applyGateReceiptCarried) {
        blockers.add("DEFAULT_ENGINE_MUTATION_APPLY_GATE_RECEIPT_NOT_CARRIED")
    }
    if (!request.controlledApplyScopeCarried) {
        blockers.add("CONTROLLED_APPLY_SCOPE_NOT_CARRIED")
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
    if (controlledApplyMode == "unknown-controlled-default-engine-mutation-apply") {
        blockers.add("UNKNOWN_DEFAULT_ENGINE_MUTATION_APPLY_GATE")
    }
    blockers.toArray()
}

func igniteControlledDefaultEngineMutationApplyNonClaims(): Array<String> {
    [
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_H1_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
        "NO_ACTUAL_LIVE_SERVER_WIRING",
        "NO_PRODUCTION_QUEUE_MUTATION",
        "NO_ACTUAL_RUNTIME_TASK_SPAWN",
        "NO_ACTUAL_HANDLER_INVOCATION",
        "NO_ACTUAL_REQUEST_CONTEXT_MUTATION",
        "NO_ACTUAL_RESPONSE_WRITE",
        "NO_ACTUAL_TRANSPORT_COMMIT",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
    ]
}

public class IgniteRuntimeDefaultPathMutationGateRequest {
    public let runtimeDefaultPathMutationGateId: String
    public let controlledApplyReceiptCarried: Bool
    public let targetRuntimeDefaultPathCarried: Bool
    public let mutationGatePreconditionCarried: Bool
    public let defaultEngineMutationLockCarried: Bool
    public let configMutationLockCarried: Bool
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
        runtimeDefaultPathMutationGateId: String,
        controlledApplyReceiptCarried: Bool,
        targetRuntimeDefaultPathCarried: Bool,
        mutationGatePreconditionCarried: Bool,
        defaultEngineMutationLockCarried: Bool,
        configMutationLockCarried: Bool,
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
        this.runtimeDefaultPathMutationGateId =
            runtimeDefaultPathMutationGateId
        this.controlledApplyReceiptCarried = controlledApplyReceiptCarried
        this.targetRuntimeDefaultPathCarried =
            targetRuntimeDefaultPathCarried
        this.mutationGatePreconditionCarried =
            mutationGatePreconditionCarried
        this.defaultEngineMutationLockCarried =
            defaultEngineMutationLockCarried
        this.configMutationLockCarried = configMutationLockCarried
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

public class IgniteRuntimeDefaultPathMutationGateReceipt {
    public let runtimeDefaultPathMutationGateAccepted: Bool
    public let controlledDefaultEngineMutationApplyAccepted: Bool
    public let controlledDefaultEngineMutationApplyMode: String
    public let runtimeDefaultPathMutationGateMode: String
    public let runtimeDefaultPathMutationGateId: String
    public let controlledDefaultEngineMutationApplyId: String
    public let defaultEngineMutationApplyGateId: String
    public let defaultEngineMutationDryRunId: String
    public let defaultEngineMutationCommitPlanId: String
    public let controlledApplyReceipt: IgniteControlledDefaultEngineMutationApplyReceipt
    public let runtimeDefaultPathMutationGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationGateAllowed: Bool
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
        runtimeDefaultPathMutationGateAccepted: Bool,
        controlledDefaultEngineMutationApplyAccepted: Bool,
        controlledDefaultEngineMutationApplyMode: String,
        runtimeDefaultPathMutationGateMode: String,
        runtimeDefaultPathMutationGateId: String,
        controlledDefaultEngineMutationApplyId: String,
        defaultEngineMutationApplyGateId: String,
        defaultEngineMutationDryRunId: String,
        defaultEngineMutationCommitPlanId: String,
        controlledApplyReceipt: IgniteControlledDefaultEngineMutationApplyReceipt,
        runtimeDefaultPathMutationGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationGateAllowed: Bool,
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
        this.runtimeDefaultPathMutationGateAccepted =
            runtimeDefaultPathMutationGateAccepted
        this.controlledDefaultEngineMutationApplyAccepted =
            controlledDefaultEngineMutationApplyAccepted
        this.controlledDefaultEngineMutationApplyMode =
            controlledDefaultEngineMutationApplyMode
        this.runtimeDefaultPathMutationGateMode =
            runtimeDefaultPathMutationGateMode
        this.runtimeDefaultPathMutationGateId =
            runtimeDefaultPathMutationGateId
        this.controlledDefaultEngineMutationApplyId =
            controlledDefaultEngineMutationApplyId
        this.defaultEngineMutationApplyGateId =
            defaultEngineMutationApplyGateId
        this.defaultEngineMutationDryRunId = defaultEngineMutationDryRunId
        this.defaultEngineMutationCommitPlanId =
            defaultEngineMutationCommitPlanId
        this.controlledApplyReceipt = controlledApplyReceipt
        this.runtimeDefaultPathMutationGateRecorded =
            runtimeDefaultPathMutationGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationGateAllowed =
            runtimeDefaultPathMutationGateAllowed
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

public func buildIgniteRuntimeDefaultPathMutationGateReceipt(
    controlledApplyReceipt: IgniteControlledDefaultEngineMutationApplyReceipt,
    request: IgniteRuntimeDefaultPathMutationGateRequest
): IgniteRuntimeDefaultPathMutationGateReceipt {
    let nonClaims = igniteRuntimeDefaultPathMutationGateNonClaims()
    if (!controlledApplyReceipt.controlledDefaultEngineMutationApplyAccepted) {
        return IgniteRuntimeDefaultPathMutationGateReceipt(
            false,
            controlledApplyReceipt.controlledDefaultEngineMutationApplyAccepted,
            controlledApplyReceipt.controlledDefaultEngineMutationApplyMode,
            "none",
            request.runtimeDefaultPathMutationGateId,
            controlledApplyReceipt.controlledDefaultEngineMutationApplyId,
            controlledApplyReceipt.defaultEngineMutationApplyGateId,
            controlledApplyReceipt.defaultEngineMutationDryRunId,
            controlledApplyReceipt.defaultEngineMutationCommitPlanId,
            controlledApplyReceipt,
            false,
            "block",
            "blocked-controlled-default-engine-mutation-apply-receipt",
            "collect-accepted-controlled-default-engine-mutation-apply-receipt-first",
            ["CONTROLLED_DEFAULT_ENGINE_MUTATION_APPLY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0483 controlled default-engine mutation apply input before runtime default-path mutation gate work",
            "QUIC must not consume runtime default-path mutation gate receipts from rejected controlled apply receipts"
        )
    }

    let gateMode = igniteRuntimeDefaultPathMutationGateModeFor(
        controlledApplyReceipt.controlledDefaultEngineMutationApplyMode
    )
    let blockers = igniteRuntimeDefaultPathMutationGateBlockers(
        request,
        gateMode
    )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationGateReceipt(
            false,
            controlledApplyReceipt.controlledDefaultEngineMutationApplyAccepted,
            controlledApplyReceipt.controlledDefaultEngineMutationApplyMode,
            gateMode,
            request.runtimeDefaultPathMutationGateId,
            controlledApplyReceipt.controlledDefaultEngineMutationApplyId,
            controlledApplyReceipt.defaultEngineMutationApplyGateId,
            controlledApplyReceipt.defaultEngineMutationDryRunId,
            controlledApplyReceipt.defaultEngineMutationCommitPlanId,
            controlledApplyReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-gate-input",
            "fix-runtime-default-path-mutation-gate-before-runtime-default-mutation",
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
            "carry runtime default-path mutation gate id, controlled apply receipt, target default path, gate precondition, mutation locks, rollback order, runtime guard plan, observability marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation gate blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationGateReceipt(
        true,
        controlledApplyReceipt.controlledDefaultEngineMutationApplyAccepted,
        controlledApplyReceipt.controlledDefaultEngineMutationApplyMode,
        gateMode,
        request.runtimeDefaultPathMutationGateId,
        controlledApplyReceipt.controlledDefaultEngineMutationApplyId,
        controlledApplyReceipt.defaultEngineMutationApplyGateId,
        controlledApplyReceipt.defaultEngineMutationDryRunId,
        controlledApplyReceipt.defaultEngineMutationCommitPlanId,
        controlledApplyReceipt,
        true,
        "record-runtime-default-path-mutation-gate",
        "accepted-runtime-default-path-mutation-gate-receipt",
        "record-runtime-default-path-mutation-gate-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation dry-run without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation gate modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationGateModeFor(
    controlledApplyMode: String
): String {
    if (controlledApplyMode == "short-controlled-default-engine-mutation-apply") {
        return "short-runtime-default-path-mutation-gate"
    }
    if (controlledApplyMode == "long-controlled-default-engine-mutation-apply") {
        return "long-runtime-default-path-mutation-gate"
    }
    if (controlledApplyMode == "blocking-isolation-controlled-default-engine-mutation-apply") {
        return "blocking-isolation-runtime-default-path-mutation-gate"
    }
    "unknown-runtime-default-path-mutation-gate"
}

func igniteRuntimeDefaultPathMutationGateBlockers(
    request: IgniteRuntimeDefaultPathMutationGateRequest,
    gateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.runtimeDefaultPathMutationGateId.size == 0) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_GATE_ID_NOT_CARRIED")
    }
    if (!request.controlledApplyReceiptCarried) {
        blockers.add("CONTROLLED_DEFAULT_ENGINE_MUTATION_APPLY_RECEIPT_NOT_CARRIED")
    }
    if (!request.targetRuntimeDefaultPathCarried) {
        blockers.add("TARGET_RUNTIME_DEFAULT_PATH_NOT_CARRIED")
    }
    if (!request.mutationGatePreconditionCarried) {
        blockers.add("MUTATION_GATE_PRECONDITION_NOT_CARRIED")
    }
    if (!request.defaultEngineMutationLockCarried) {
        blockers.add("DEFAULT_ENGINE_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.configMutationLockCarried) {
        blockers.add("CONFIG_MUTATION_LOCK_NOT_CARRIED")
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
    if (gateMode == "unknown-runtime-default-path-mutation-gate") {
        blockers.add("UNKNOWN_CONTROLLED_DEFAULT_ENGINE_MUTATION_APPLY")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationGateNonClaims(): Array<String> {
    [
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_H1_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
        "NO_ACTUAL_LIVE_SERVER_WIRING",
        "NO_PRODUCTION_QUEUE_MUTATION",
        "NO_ACTUAL_RUNTIME_TASK_SPAWN",
        "NO_ACTUAL_HANDLER_INVOCATION",
        "NO_ACTUAL_REQUEST_CONTEXT_MUTATION",
        "NO_ACTUAL_RESPONSE_WRITE",
        "NO_ACTUAL_TRANSPORT_COMMIT",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
    ]
}

public class IgniteRuntimeDefaultPathMutationDryRunRequest {
    public let runtimeDefaultPathMutationDryRunId: String
    public let runtimeDefaultPathMutationGateReceiptCarried: Bool
    public let targetRuntimeDefaultPathCarried: Bool
    public let dryRunPlanCarried: Bool
    public let defaultEngineMutationLockCarried: Bool
    public let configMutationLockCarried: Bool
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
        runtimeDefaultPathMutationDryRunId: String,
        runtimeDefaultPathMutationGateReceiptCarried: Bool,
        targetRuntimeDefaultPathCarried: Bool,
        dryRunPlanCarried: Bool,
        defaultEngineMutationLockCarried: Bool,
        configMutationLockCarried: Bool,
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
        this.runtimeDefaultPathMutationDryRunId =
            runtimeDefaultPathMutationDryRunId
        this.runtimeDefaultPathMutationGateReceiptCarried =
            runtimeDefaultPathMutationGateReceiptCarried
        this.targetRuntimeDefaultPathCarried =
            targetRuntimeDefaultPathCarried
        this.dryRunPlanCarried = dryRunPlanCarried
        this.defaultEngineMutationLockCarried =
            defaultEngineMutationLockCarried
        this.configMutationLockCarried = configMutationLockCarried
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

public class IgniteRuntimeDefaultPathMutationDryRunReceipt {
    public let runtimeDefaultPathMutationDryRunAccepted: Bool
    public let runtimeDefaultPathMutationGateAccepted: Bool
    public let runtimeDefaultPathMutationGateMode: String
    public let runtimeDefaultPathMutationDryRunMode: String
    public let runtimeDefaultPathMutationDryRunId: String
    public let runtimeDefaultPathMutationGateId: String
    public let controlledDefaultEngineMutationApplyId: String
    public let defaultEngineMutationApplyGateId: String
    public let defaultEngineMutationDryRunId: String
    public let defaultEngineMutationCommitPlanId: String
    public let gateReceipt: IgniteRuntimeDefaultPathMutationGateReceipt
    public let runtimeDefaultPathMutationDryRunRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationDryRunAllowed: Bool
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
        runtimeDefaultPathMutationDryRunAccepted: Bool,
        runtimeDefaultPathMutationGateAccepted: Bool,
        runtimeDefaultPathMutationGateMode: String,
        runtimeDefaultPathMutationDryRunMode: String,
        runtimeDefaultPathMutationDryRunId: String,
        runtimeDefaultPathMutationGateId: String,
        controlledDefaultEngineMutationApplyId: String,
        defaultEngineMutationApplyGateId: String,
        defaultEngineMutationDryRunId: String,
        defaultEngineMutationCommitPlanId: String,
        gateReceipt: IgniteRuntimeDefaultPathMutationGateReceipt,
        runtimeDefaultPathMutationDryRunRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationDryRunAllowed: Bool,
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
        this.runtimeDefaultPathMutationDryRunAccepted =
            runtimeDefaultPathMutationDryRunAccepted
        this.runtimeDefaultPathMutationGateAccepted =
            runtimeDefaultPathMutationGateAccepted
        this.runtimeDefaultPathMutationGateMode =
            runtimeDefaultPathMutationGateMode
        this.runtimeDefaultPathMutationDryRunMode =
            runtimeDefaultPathMutationDryRunMode
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
        this.gateReceipt = gateReceipt
        this.runtimeDefaultPathMutationDryRunRecorded =
            runtimeDefaultPathMutationDryRunRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationDryRunAllowed =
            runtimeDefaultPathMutationDryRunAllowed
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

public func buildIgniteRuntimeDefaultPathMutationDryRunReceipt(
    gateReceipt: IgniteRuntimeDefaultPathMutationGateReceipt,
    request: IgniteRuntimeDefaultPathMutationDryRunRequest
): IgniteRuntimeDefaultPathMutationDryRunReceipt {
    let nonClaims = igniteRuntimeDefaultPathMutationDryRunNonClaims()
    if (!gateReceipt.runtimeDefaultPathMutationGateAccepted) {
        return IgniteRuntimeDefaultPathMutationDryRunReceipt(
            false,
            gateReceipt.runtimeDefaultPathMutationGateAccepted,
            gateReceipt.runtimeDefaultPathMutationGateMode,
            "none",
            request.runtimeDefaultPathMutationDryRunId,
            gateReceipt.runtimeDefaultPathMutationGateId,
            gateReceipt.controlledDefaultEngineMutationApplyId,
            gateReceipt.defaultEngineMutationApplyGateId,
            gateReceipt.defaultEngineMutationDryRunId,
            gateReceipt.defaultEngineMutationCommitPlanId,
            gateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-gate-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0484 runtime default-path mutation gate input before dry-run work",
            "QUIC must not consume runtime default-path mutation dry-run receipts from rejected gate receipts"
        )
    }

    let dryRunMode = igniteRuntimeDefaultPathMutationDryRunModeFor(
        gateReceipt.runtimeDefaultPathMutationGateMode
    )
    let blockers = igniteRuntimeDefaultPathMutationDryRunBlockers(
        request,
        dryRunMode
    )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationDryRunReceipt(
            false,
            gateReceipt.runtimeDefaultPathMutationGateAccepted,
            gateReceipt.runtimeDefaultPathMutationGateMode,
            dryRunMode,
            request.runtimeDefaultPathMutationDryRunId,
            gateReceipt.runtimeDefaultPathMutationGateId,
            gateReceipt.controlledDefaultEngineMutationApplyId,
            gateReceipt.defaultEngineMutationApplyGateId,
            gateReceipt.defaultEngineMutationDryRunId,
            gateReceipt.defaultEngineMutationCommitPlanId,
            gateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-dry-run-input",
            "fix-runtime-default-path-mutation-dry-run-before-runtime-default-mutation",
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
            "carry runtime default-path mutation dry-run id, gate receipt, target default path, dry-run plan, mutation locks, rollback order, runtime guard plan, observability marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation dry-run blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationDryRunReceipt(
        true,
        gateReceipt.runtimeDefaultPathMutationGateAccepted,
        gateReceipt.runtimeDefaultPathMutationGateMode,
        dryRunMode,
        request.runtimeDefaultPathMutationDryRunId,
        gateReceipt.runtimeDefaultPathMutationGateId,
        gateReceipt.controlledDefaultEngineMutationApplyId,
        gateReceipt.defaultEngineMutationApplyGateId,
        gateReceipt.defaultEngineMutationDryRunId,
        gateReceipt.defaultEngineMutationCommitPlanId,
        gateReceipt,
        true,
        "record-runtime-default-path-mutation-dry-run",
        "accepted-runtime-default-path-mutation-dry-run-receipt",
        "record-runtime-default-path-mutation-dry-run-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation apply-gate without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation dry-run modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationDryRunModeFor(
    gateMode: String
): String {
    if (gateMode == "short-runtime-default-path-mutation-gate") {
        return "short-runtime-default-path-mutation-dry-run"
    }
    if (gateMode == "long-runtime-default-path-mutation-gate") {
        return "long-runtime-default-path-mutation-dry-run"
    }
    if (gateMode == "blocking-isolation-runtime-default-path-mutation-gate") {
        return "blocking-isolation-runtime-default-path-mutation-dry-run"
    }
    "unknown-runtime-default-path-mutation-dry-run"
}

func igniteRuntimeDefaultPathMutationDryRunBlockers(
    request: IgniteRuntimeDefaultPathMutationDryRunRequest,
    dryRunMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.runtimeDefaultPathMutationDryRunId.size == 0) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_DRY_RUN_ID_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationGateReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_GATE_RECEIPT_NOT_CARRIED")
    }
    if (!request.targetRuntimeDefaultPathCarried) {
        blockers.add("TARGET_RUNTIME_DEFAULT_PATH_NOT_CARRIED")
    }
    if (!request.dryRunPlanCarried) {
        blockers.add("DRY_RUN_PLAN_NOT_CARRIED")
    }
    if (!request.defaultEngineMutationLockCarried) {
        blockers.add("DEFAULT_ENGINE_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.configMutationLockCarried) {
        blockers.add("CONFIG_MUTATION_LOCK_NOT_CARRIED")
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
    if (dryRunMode == "unknown-runtime-default-path-mutation-dry-run") {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_GATE")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationDryRunNonClaims(): Array<String> {
    [
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_H1_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
        "NO_ACTUAL_LIVE_SERVER_WIRING",
        "NO_PRODUCTION_QUEUE_MUTATION",
        "NO_ACTUAL_RUNTIME_TASK_SPAWN",
        "NO_ACTUAL_HANDLER_INVOCATION",
        "NO_ACTUAL_REQUEST_CONTEXT_MUTATION",
        "NO_ACTUAL_RESPONSE_WRITE",
        "NO_ACTUAL_TRANSPORT_COMMIT",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
    ]
}

public class IgniteRuntimeDefaultPathMutationApplyGateRequest {
    public let runtimeDefaultPathMutationApplyGateId: String
    public let runtimeDefaultPathMutationDryRunReceiptCarried: Bool
    public let targetRuntimeDefaultPathCarried: Bool
    public let applyGatePreconditionCarried: Bool
    public let defaultEngineMutationLockCarried: Bool
    public let configMutationLockCarried: Bool
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
        runtimeDefaultPathMutationApplyGateId: String,
        runtimeDefaultPathMutationDryRunReceiptCarried: Bool,
        targetRuntimeDefaultPathCarried: Bool,
        applyGatePreconditionCarried: Bool,
        defaultEngineMutationLockCarried: Bool,
        configMutationLockCarried: Bool,
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
        this.runtimeDefaultPathMutationApplyGateId =
            runtimeDefaultPathMutationApplyGateId
        this.runtimeDefaultPathMutationDryRunReceiptCarried =
            runtimeDefaultPathMutationDryRunReceiptCarried
        this.targetRuntimeDefaultPathCarried =
            targetRuntimeDefaultPathCarried
        this.applyGatePreconditionCarried = applyGatePreconditionCarried
        this.defaultEngineMutationLockCarried =
            defaultEngineMutationLockCarried
        this.configMutationLockCarried = configMutationLockCarried
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

public class IgniteRuntimeDefaultPathMutationApplyGateReceipt {
    public let runtimeDefaultPathMutationApplyGateAccepted: Bool
    public let runtimeDefaultPathMutationDryRunAccepted: Bool
    public let runtimeDefaultPathMutationDryRunMode: String
    public let runtimeDefaultPathMutationApplyGateMode: String
    public let runtimeDefaultPathMutationApplyGateId: String
    public let runtimeDefaultPathMutationDryRunId: String
    public let runtimeDefaultPathMutationGateId: String
    public let controlledDefaultEngineMutationApplyId: String
    public let defaultEngineMutationApplyGateId: String
    public let defaultEngineMutationDryRunId: String
    public let defaultEngineMutationCommitPlanId: String
    public let dryRunReceipt: IgniteRuntimeDefaultPathMutationDryRunReceipt
    public let runtimeDefaultPathMutationApplyGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationApplyGateAllowed: Bool
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
        runtimeDefaultPathMutationApplyGateAccepted: Bool,
        runtimeDefaultPathMutationDryRunAccepted: Bool,
        runtimeDefaultPathMutationDryRunMode: String,
        runtimeDefaultPathMutationApplyGateMode: String,
        runtimeDefaultPathMutationApplyGateId: String,
        runtimeDefaultPathMutationDryRunId: String,
        runtimeDefaultPathMutationGateId: String,
        controlledDefaultEngineMutationApplyId: String,
        defaultEngineMutationApplyGateId: String,
        defaultEngineMutationDryRunId: String,
        defaultEngineMutationCommitPlanId: String,
        dryRunReceipt: IgniteRuntimeDefaultPathMutationDryRunReceipt,
        runtimeDefaultPathMutationApplyGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationApplyGateAllowed: Bool,
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
        this.runtimeDefaultPathMutationApplyGateAccepted =
            runtimeDefaultPathMutationApplyGateAccepted
        this.runtimeDefaultPathMutationDryRunAccepted =
            runtimeDefaultPathMutationDryRunAccepted
        this.runtimeDefaultPathMutationDryRunMode =
            runtimeDefaultPathMutationDryRunMode
        this.runtimeDefaultPathMutationApplyGateMode =
            runtimeDefaultPathMutationApplyGateMode
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
        this.dryRunReceipt = dryRunReceipt
        this.runtimeDefaultPathMutationApplyGateRecorded =
            runtimeDefaultPathMutationApplyGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationApplyGateAllowed =
            runtimeDefaultPathMutationApplyGateAllowed
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

public func buildIgniteRuntimeDefaultPathMutationApplyGateReceipt(
    dryRunReceipt: IgniteRuntimeDefaultPathMutationDryRunReceipt,
    request: IgniteRuntimeDefaultPathMutationApplyGateRequest
): IgniteRuntimeDefaultPathMutationApplyGateReceipt {
    let nonClaims = igniteRuntimeDefaultPathMutationApplyGateNonClaims()
    if (!dryRunReceipt.runtimeDefaultPathMutationDryRunAccepted) {
        return IgniteRuntimeDefaultPathMutationApplyGateReceipt(
            false,
            dryRunReceipt.runtimeDefaultPathMutationDryRunAccepted,
            dryRunReceipt.runtimeDefaultPathMutationDryRunMode,
            "none",
            request.runtimeDefaultPathMutationApplyGateId,
            dryRunReceipt.runtimeDefaultPathMutationDryRunId,
            dryRunReceipt.runtimeDefaultPathMutationGateId,
            dryRunReceipt.controlledDefaultEngineMutationApplyId,
            dryRunReceipt.defaultEngineMutationApplyGateId,
            dryRunReceipt.defaultEngineMutationDryRunId,
            dryRunReceipt.defaultEngineMutationCommitPlanId,
            dryRunReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-dry-run-receipt",
            "collect-accepted-runtime-default-path-mutation-dry-run-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_DRY_RUN_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0485 runtime default-path mutation dry-run input before apply-gate work",
            "QUIC must not consume runtime default-path mutation apply-gate receipts from rejected dry-run receipts"
        )
    }

    let applyGateMode = igniteRuntimeDefaultPathMutationApplyGateModeFor(
        dryRunReceipt.runtimeDefaultPathMutationDryRunMode
    )
    let blockers = igniteRuntimeDefaultPathMutationApplyGateBlockers(
        request,
        applyGateMode
    )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationApplyGateReceipt(
            false,
            dryRunReceipt.runtimeDefaultPathMutationDryRunAccepted,
            dryRunReceipt.runtimeDefaultPathMutationDryRunMode,
            applyGateMode,
            request.runtimeDefaultPathMutationApplyGateId,
            dryRunReceipt.runtimeDefaultPathMutationDryRunId,
            dryRunReceipt.runtimeDefaultPathMutationGateId,
            dryRunReceipt.controlledDefaultEngineMutationApplyId,
            dryRunReceipt.defaultEngineMutationApplyGateId,
            dryRunReceipt.defaultEngineMutationDryRunId,
            dryRunReceipt.defaultEngineMutationCommitPlanId,
            dryRunReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-apply-gate-input",
            "fix-runtime-default-path-mutation-apply-gate-before-runtime-default-mutation",
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
            "carry runtime default-path mutation apply-gate id, dry-run receipt, target default path, apply-gate precondition, mutation locks, rollback order, runtime guard plan, observability marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation apply-gate blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationApplyGateReceipt(
        true,
        dryRunReceipt.runtimeDefaultPathMutationDryRunAccepted,
        dryRunReceipt.runtimeDefaultPathMutationDryRunMode,
        applyGateMode,
        request.runtimeDefaultPathMutationApplyGateId,
        dryRunReceipt.runtimeDefaultPathMutationDryRunId,
        dryRunReceipt.runtimeDefaultPathMutationGateId,
        dryRunReceipt.controlledDefaultEngineMutationApplyId,
        dryRunReceipt.defaultEngineMutationApplyGateId,
        dryRunReceipt.defaultEngineMutationDryRunId,
        dryRunReceipt.defaultEngineMutationCommitPlanId,
        dryRunReceipt,
        true,
        "record-runtime-default-path-mutation-apply-gate",
        "accepted-runtime-default-path-mutation-apply-gate-receipt",
        "record-runtime-default-path-mutation-apply-gate-without-runtime-default-mutation",
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
        "next packet may prove controlled runtime default-path mutation apply without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation apply-gate modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationApplyGateModeFor(
    dryRunMode: String
): String {
    if (dryRunMode == "short-runtime-default-path-mutation-dry-run") {
        return "short-runtime-default-path-mutation-apply-gate"
    }
    if (dryRunMode == "long-runtime-default-path-mutation-dry-run") {
        return "long-runtime-default-path-mutation-apply-gate"
    }
    if (dryRunMode == "blocking-isolation-runtime-default-path-mutation-dry-run") {
        return "blocking-isolation-runtime-default-path-mutation-apply-gate"
    }
    "unknown-runtime-default-path-mutation-apply-gate"
}

func igniteRuntimeDefaultPathMutationApplyGateBlockers(
    request: IgniteRuntimeDefaultPathMutationApplyGateRequest,
    applyGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.runtimeDefaultPathMutationApplyGateId.size == 0) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_APPLY_GATE_ID_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationDryRunReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_DRY_RUN_RECEIPT_NOT_CARRIED")
    }
    if (!request.targetRuntimeDefaultPathCarried) {
        blockers.add("TARGET_RUNTIME_DEFAULT_PATH_NOT_CARRIED")
    }
    if (!request.applyGatePreconditionCarried) {
        blockers.add("APPLY_GATE_PRECONDITION_NOT_CARRIED")
    }
    if (!request.defaultEngineMutationLockCarried) {
        blockers.add("DEFAULT_ENGINE_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.configMutationLockCarried) {
        blockers.add("CONFIG_MUTATION_LOCK_NOT_CARRIED")
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
    if (applyGateMode == "unknown-runtime-default-path-mutation-apply-gate") {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_DRY_RUN")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationApplyGateNonClaims(): Array<String> {
    [
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_H1_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
        "NO_ACTUAL_LIVE_SERVER_WIRING",
        "NO_PRODUCTION_QUEUE_MUTATION",
        "NO_ACTUAL_RUNTIME_TASK_SPAWN",
        "NO_ACTUAL_HANDLER_INVOCATION",
        "NO_ACTUAL_REQUEST_CONTEXT_MUTATION",
        "NO_ACTUAL_RESPONSE_WRITE",
        "NO_ACTUAL_TRANSPORT_COMMIT",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
    ]
}

public class IgniteControlledRuntimeDefaultPathMutationApplyRequest {
    public let controlledRuntimeDefaultPathMutationApplyId: String
    public let applyGateReceiptCarried: Bool
    public let controlledApplyScopeCarried: Bool
    public let defaultEngineMutationLockCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
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
        controlledRuntimeDefaultPathMutationApplyId: String,
        applyGateReceiptCarried: Bool,
        controlledApplyScopeCarried: Bool,
        defaultEngineMutationLockCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
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
        this.controlledRuntimeDefaultPathMutationApplyId =
            controlledRuntimeDefaultPathMutationApplyId
        this.applyGateReceiptCarried = applyGateReceiptCarried
        this.controlledApplyScopeCarried = controlledApplyScopeCarried
        this.defaultEngineMutationLockCarried =
            defaultEngineMutationLockCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
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

public class IgniteControlledRuntimeDefaultPathMutationApplyReceipt {
    public let controlledRuntimeDefaultPathMutationApplyAccepted: Bool
    public let runtimeDefaultPathMutationApplyGateAccepted: Bool
    public let runtimeDefaultPathMutationApplyGateMode: String
    public let controlledRuntimeDefaultPathMutationApplyMode: String
    public let controlledRuntimeDefaultPathMutationApplyId: String
    public let runtimeDefaultPathMutationApplyGateId: String
    public let runtimeDefaultPathMutationDryRunId: String
    public let runtimeDefaultPathMutationGateId: String
    public let controlledDefaultEngineMutationApplyId: String
    public let defaultEngineMutationApplyGateId: String
    public let defaultEngineMutationDryRunId: String
    public let defaultEngineMutationCommitPlanId: String
    public let applyGateReceipt: IgniteRuntimeDefaultPathMutationApplyGateReceipt
    public let controlledRuntimeDefaultPathMutationApplyRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let controlledRuntimeDefaultPathMutationApplyAllowed: Bool
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
        controlledRuntimeDefaultPathMutationApplyAccepted: Bool,
        runtimeDefaultPathMutationApplyGateAccepted: Bool,
        runtimeDefaultPathMutationApplyGateMode: String,
        controlledRuntimeDefaultPathMutationApplyMode: String,
        controlledRuntimeDefaultPathMutationApplyId: String,
        runtimeDefaultPathMutationApplyGateId: String,
        runtimeDefaultPathMutationDryRunId: String,
        runtimeDefaultPathMutationGateId: String,
        controlledDefaultEngineMutationApplyId: String,
        defaultEngineMutationApplyGateId: String,
        defaultEngineMutationDryRunId: String,
        defaultEngineMutationCommitPlanId: String,
        applyGateReceipt: IgniteRuntimeDefaultPathMutationApplyGateReceipt,
        controlledRuntimeDefaultPathMutationApplyRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        controlledRuntimeDefaultPathMutationApplyAllowed: Bool,
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
        this.controlledRuntimeDefaultPathMutationApplyAccepted =
            controlledRuntimeDefaultPathMutationApplyAccepted
        this.runtimeDefaultPathMutationApplyGateAccepted =
            runtimeDefaultPathMutationApplyGateAccepted
        this.runtimeDefaultPathMutationApplyGateMode =
            runtimeDefaultPathMutationApplyGateMode
        this.controlledRuntimeDefaultPathMutationApplyMode =
            controlledRuntimeDefaultPathMutationApplyMode
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
        this.applyGateReceipt = applyGateReceipt
        this.controlledRuntimeDefaultPathMutationApplyRecorded =
            controlledRuntimeDefaultPathMutationApplyRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.controlledRuntimeDefaultPathMutationApplyAllowed =
            controlledRuntimeDefaultPathMutationApplyAllowed
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

public func buildIgniteControlledRuntimeDefaultPathMutationApplyReceipt(
    applyGateReceipt: IgniteRuntimeDefaultPathMutationApplyGateReceipt,
    request: IgniteControlledRuntimeDefaultPathMutationApplyRequest
): IgniteControlledRuntimeDefaultPathMutationApplyReceipt {
    let nonClaims = igniteControlledRuntimeDefaultPathMutationApplyNonClaims()
    if (!applyGateReceipt.runtimeDefaultPathMutationApplyGateAccepted) {
        return IgniteControlledRuntimeDefaultPathMutationApplyReceipt(
            false,
            applyGateReceipt.runtimeDefaultPathMutationApplyGateAccepted,
            applyGateReceipt.runtimeDefaultPathMutationApplyGateMode,
            "none",
            request.controlledRuntimeDefaultPathMutationApplyId,
            applyGateReceipt.runtimeDefaultPathMutationApplyGateId,
            applyGateReceipt.runtimeDefaultPathMutationDryRunId,
            applyGateReceipt.runtimeDefaultPathMutationGateId,
            applyGateReceipt.controlledDefaultEngineMutationApplyId,
            applyGateReceipt.defaultEngineMutationApplyGateId,
            applyGateReceipt.defaultEngineMutationDryRunId,
            applyGateReceipt.defaultEngineMutationCommitPlanId,
            applyGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-apply-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-apply-gate-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_APPLY_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0486 runtime default-path mutation apply-gate input before controlled apply work",
            "QUIC must not consume controlled runtime default-path mutation apply receipts from rejected apply-gates"
        )
    }

    let controlledApplyMode =
        igniteControlledRuntimeDefaultPathMutationApplyModeFor(
            applyGateReceipt.runtimeDefaultPathMutationApplyGateMode
        )
    let blockers = igniteControlledRuntimeDefaultPathMutationApplyBlockers(
        request,
        controlledApplyMode
    )
    if (blockers.size > 0) {
        return IgniteControlledRuntimeDefaultPathMutationApplyReceipt(
            false,
            applyGateReceipt.runtimeDefaultPathMutationApplyGateAccepted,
            applyGateReceipt.runtimeDefaultPathMutationApplyGateMode,
            controlledApplyMode,
            request.controlledRuntimeDefaultPathMutationApplyId,
            applyGateReceipt.runtimeDefaultPathMutationApplyGateId,
            applyGateReceipt.runtimeDefaultPathMutationDryRunId,
            applyGateReceipt.runtimeDefaultPathMutationGateId,
            applyGateReceipt.controlledDefaultEngineMutationApplyId,
            applyGateReceipt.defaultEngineMutationApplyGateId,
            applyGateReceipt.defaultEngineMutationDryRunId,
            applyGateReceipt.defaultEngineMutationCommitPlanId,
            applyGateReceipt,
            false,
            "block",
            "blocked-controlled-runtime-default-path-mutation-apply-input",
            "fix-controlled-runtime-default-path-mutation-apply-before-runtime-default-mutation",
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
            "carry controlled runtime default-path mutation apply id, apply-gate receipt, controlled scope, mutation locks, rollback order, runtime guard plan, observability marker, and keep runtime default mutation out",
            "QUIC can reuse the same controlled runtime default-path mutation apply blockers before default stream runtime mutation"
        )
    }

    IgniteControlledRuntimeDefaultPathMutationApplyReceipt(
        true,
        applyGateReceipt.runtimeDefaultPathMutationApplyGateAccepted,
        applyGateReceipt.runtimeDefaultPathMutationApplyGateMode,
        controlledApplyMode,
        request.controlledRuntimeDefaultPathMutationApplyId,
        applyGateReceipt.runtimeDefaultPathMutationApplyGateId,
        applyGateReceipt.runtimeDefaultPathMutationDryRunId,
        applyGateReceipt.runtimeDefaultPathMutationGateId,
        applyGateReceipt.controlledDefaultEngineMutationApplyId,
        applyGateReceipt.defaultEngineMutationApplyGateId,
        applyGateReceipt.defaultEngineMutationDryRunId,
        applyGateReceipt.defaultEngineMutationCommitPlanId,
        applyGateReceipt,
        true,
        "record-controlled-runtime-default-path-mutation-apply",
        "accepted-controlled-runtime-default-path-mutation-apply-receipt",
        "record-controlled-runtime-default-path-mutation-apply-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation commit-plan without mutating runtime defaults",
        "QUIC can reuse lane-specific controlled runtime default-path mutation apply modes before runtime default mutation"
    )
}

func igniteControlledRuntimeDefaultPathMutationApplyModeFor(
    applyGateMode: String
): String {
    if (applyGateMode == "short-runtime-default-path-mutation-apply-gate") {
        return "short-controlled-runtime-default-path-mutation-apply"
    }
    if (applyGateMode == "long-runtime-default-path-mutation-apply-gate") {
        return "long-controlled-runtime-default-path-mutation-apply"
    }
    if (
        applyGateMode ==
        "blocking-isolation-runtime-default-path-mutation-apply-gate"
    ) {
        return "blocking-isolation-controlled-runtime-default-path-mutation-apply"
    }
    "unknown-controlled-runtime-default-path-mutation-apply"
}

func igniteControlledRuntimeDefaultPathMutationApplyBlockers(
    request: IgniteControlledRuntimeDefaultPathMutationApplyRequest,
    controlledApplyMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.controlledRuntimeDefaultPathMutationApplyId.size == 0) {
        blockers.add("CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_ID_NOT_CARRIED")
    }
    if (!request.applyGateReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_APPLY_GATE_RECEIPT_NOT_CARRIED")
    }
    if (!request.controlledApplyScopeCarried) {
        blockers.add("CONTROLLED_APPLY_SCOPE_NOT_CARRIED")
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
        controlledApplyMode ==
        "unknown-controlled-runtime-default-path-mutation-apply"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_GATE")
    }
    blockers.toArray()
}

func igniteControlledRuntimeDefaultPathMutationApplyNonClaims(): Array<String> {
    [
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_H1_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
        "NO_ACTUAL_LIVE_SERVER_WIRING",
        "NO_PRODUCTION_QUEUE_MUTATION",
        "NO_ACTUAL_RUNTIME_TASK_SPAWN",
        "NO_ACTUAL_HANDLER_INVOCATION",
        "NO_ACTUAL_REQUEST_CONTEXT_MUTATION",
        "NO_ACTUAL_RESPONSE_WRITE",
        "NO_ACTUAL_TRANSPORT_COMMIT",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
    ]
}

public class IgniteRuntimeDefaultPathMutationCommitPlanRequest {
    public let runtimeDefaultPathMutationCommitPlanId: String
    public let controlledApplySnapshotCarried: Bool
    public let targetRuntimeDefaultPathCarried: Bool
    public let mutationPlanIdCarried: Bool
    public let atomicSwitchPlanCarried: Bool
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
        runtimeDefaultPathMutationCommitPlanId: String,
        controlledApplySnapshotCarried: Bool,
        targetRuntimeDefaultPathCarried: Bool,
        mutationPlanIdCarried: Bool,
        atomicSwitchPlanCarried: Bool,
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
        this.runtimeDefaultPathMutationCommitPlanId =
            runtimeDefaultPathMutationCommitPlanId
        this.controlledApplySnapshotCarried = controlledApplySnapshotCarried
        this.targetRuntimeDefaultPathCarried = targetRuntimeDefaultPathCarried
        this.mutationPlanIdCarried = mutationPlanIdCarried
        this.atomicSwitchPlanCarried = atomicSwitchPlanCarried
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

public class IgniteRuntimeDefaultPathMutationCommitPlanReceipt {
    public let runtimeDefaultPathMutationCommitPlanAccepted: Bool
    public let controlledRuntimeDefaultPathMutationApplyAccepted: Bool
    public let controlledRuntimeDefaultPathMutationApplyMode: String
    public let runtimeDefaultPathMutationCommitPlanMode: String
    public let runtimeDefaultPathMutationCommitPlanId: String
    public let controlledRuntimeDefaultPathMutationApplyId: String
    public let runtimeDefaultPathMutationApplyGateId: String
    public let runtimeDefaultPathMutationDryRunId: String
    public let runtimeDefaultPathMutationGateId: String
    public let controlledDefaultEngineMutationApplyId: String
    public let defaultEngineMutationApplyGateId: String
    public let defaultEngineMutationDryRunId: String
    public let defaultEngineMutationCommitPlanId: String
    public let controlledApplyReceipt: IgniteControlledRuntimeDefaultPathMutationApplyReceipt
    public let runtimeDefaultPathMutationCommitPlanRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationCommitPlanAllowed: Bool
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
        runtimeDefaultPathMutationCommitPlanAccepted: Bool,
        controlledRuntimeDefaultPathMutationApplyAccepted: Bool,
        controlledRuntimeDefaultPathMutationApplyMode: String,
        runtimeDefaultPathMutationCommitPlanMode: String,
        runtimeDefaultPathMutationCommitPlanId: String,
        controlledRuntimeDefaultPathMutationApplyId: String,
        runtimeDefaultPathMutationApplyGateId: String,
        runtimeDefaultPathMutationDryRunId: String,
        runtimeDefaultPathMutationGateId: String,
        controlledDefaultEngineMutationApplyId: String,
        defaultEngineMutationApplyGateId: String,
        defaultEngineMutationDryRunId: String,
        defaultEngineMutationCommitPlanId: String,
        controlledApplyReceipt: IgniteControlledRuntimeDefaultPathMutationApplyReceipt,
        runtimeDefaultPathMutationCommitPlanRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationCommitPlanAllowed: Bool,
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
        this.runtimeDefaultPathMutationCommitPlanAccepted =
            runtimeDefaultPathMutationCommitPlanAccepted
        this.controlledRuntimeDefaultPathMutationApplyAccepted =
            controlledRuntimeDefaultPathMutationApplyAccepted
        this.controlledRuntimeDefaultPathMutationApplyMode =
            controlledRuntimeDefaultPathMutationApplyMode
        this.runtimeDefaultPathMutationCommitPlanMode =
            runtimeDefaultPathMutationCommitPlanMode
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
        this.controlledApplyReceipt = controlledApplyReceipt
        this.runtimeDefaultPathMutationCommitPlanRecorded =
            runtimeDefaultPathMutationCommitPlanRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationCommitPlanAllowed =
            runtimeDefaultPathMutationCommitPlanAllowed
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

public func buildIgniteRuntimeDefaultPathMutationCommitPlanReceipt(
    controlledApplyReceipt: IgniteControlledRuntimeDefaultPathMutationApplyReceipt,
    request: IgniteRuntimeDefaultPathMutationCommitPlanRequest
): IgniteRuntimeDefaultPathMutationCommitPlanReceipt {
    let nonClaims = igniteRuntimeDefaultPathMutationCommitPlanNonClaims()
    if (!controlledApplyReceipt.controlledRuntimeDefaultPathMutationApplyAccepted) {
        return IgniteRuntimeDefaultPathMutationCommitPlanReceipt(
            false,
            controlledApplyReceipt.controlledRuntimeDefaultPathMutationApplyAccepted,
            controlledApplyReceipt.controlledRuntimeDefaultPathMutationApplyMode,
            "none",
            request.runtimeDefaultPathMutationCommitPlanId,
            controlledApplyReceipt.controlledRuntimeDefaultPathMutationApplyId,
            controlledApplyReceipt.runtimeDefaultPathMutationApplyGateId,
            controlledApplyReceipt.runtimeDefaultPathMutationDryRunId,
            controlledApplyReceipt.runtimeDefaultPathMutationGateId,
            controlledApplyReceipt.controlledDefaultEngineMutationApplyId,
            controlledApplyReceipt.defaultEngineMutationApplyGateId,
            controlledApplyReceipt.defaultEngineMutationDryRunId,
            controlledApplyReceipt.defaultEngineMutationCommitPlanId,
            controlledApplyReceipt,
            false,
            "block",
            "blocked-controlled-runtime-default-path-mutation-apply-receipt",
            "collect-accepted-controlled-runtime-default-path-mutation-apply-receipt-first",
            ["CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0487 controlled runtime default-path mutation apply input before commit-plan work",
            "QUIC must not consume runtime default-path mutation commit-plan receipts from rejected controlled apply receipts"
        )
    }

    let commitPlanMode = igniteRuntimeDefaultPathMutationCommitPlanModeFor(
        controlledApplyReceipt.controlledRuntimeDefaultPathMutationApplyMode
    )
    let blockers = igniteRuntimeDefaultPathMutationCommitPlanBlockers(
        request,
        commitPlanMode
    )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationCommitPlanReceipt(
            false,
            controlledApplyReceipt.controlledRuntimeDefaultPathMutationApplyAccepted,
            controlledApplyReceipt.controlledRuntimeDefaultPathMutationApplyMode,
            commitPlanMode,
            request.runtimeDefaultPathMutationCommitPlanId,
            controlledApplyReceipt.controlledRuntimeDefaultPathMutationApplyId,
            controlledApplyReceipt.runtimeDefaultPathMutationApplyGateId,
            controlledApplyReceipt.runtimeDefaultPathMutationDryRunId,
            controlledApplyReceipt.runtimeDefaultPathMutationGateId,
            controlledApplyReceipt.controlledDefaultEngineMutationApplyId,
            controlledApplyReceipt.defaultEngineMutationApplyGateId,
            controlledApplyReceipt.defaultEngineMutationDryRunId,
            controlledApplyReceipt.defaultEngineMutationCommitPlanId,
            controlledApplyReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-commit-plan-input",
            "fix-runtime-default-path-mutation-commit-plan-before-runtime-default-mutation",
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
            "carry runtime default-path mutation commit-plan id, controlled apply snapshot, target runtime default path, mutation plan id, atomic switch plan, rollback order, runtime guard plan, observability marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation commit-plan blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationCommitPlanReceipt(
        true,
        controlledApplyReceipt.controlledRuntimeDefaultPathMutationApplyAccepted,
        controlledApplyReceipt.controlledRuntimeDefaultPathMutationApplyMode,
        commitPlanMode,
        request.runtimeDefaultPathMutationCommitPlanId,
        controlledApplyReceipt.controlledRuntimeDefaultPathMutationApplyId,
        controlledApplyReceipt.runtimeDefaultPathMutationApplyGateId,
        controlledApplyReceipt.runtimeDefaultPathMutationDryRunId,
        controlledApplyReceipt.runtimeDefaultPathMutationGateId,
        controlledApplyReceipt.controlledDefaultEngineMutationApplyId,
        controlledApplyReceipt.defaultEngineMutationApplyGateId,
        controlledApplyReceipt.defaultEngineMutationDryRunId,
        controlledApplyReceipt.defaultEngineMutationCommitPlanId,
        controlledApplyReceipt,
        true,
        "record-runtime-default-path-mutation-commit-plan",
        "accepted-runtime-default-path-mutation-commit-plan-receipt",
        "record-runtime-default-path-mutation-commit-plan-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation dry-run before actual runtime default mutation",
        "QUIC can reuse lane-specific runtime default-path mutation commit-plan modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationCommitPlanModeFor(
    controlledApplyMode: String
): String {
    if (
        controlledApplyMode ==
        "short-controlled-runtime-default-path-mutation-apply"
    ) {
        return "short-runtime-default-path-mutation-commit-plan"
    }
    if (
        controlledApplyMode ==
        "long-controlled-runtime-default-path-mutation-apply"
    ) {
        return "long-runtime-default-path-mutation-commit-plan"
    }
    if (
        controlledApplyMode ==
        "blocking-isolation-controlled-runtime-default-path-mutation-apply"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-commit-plan"
    }
    "unknown-runtime-default-path-mutation-commit-plan"
}

func igniteRuntimeDefaultPathMutationCommitPlanBlockers(
    request: IgniteRuntimeDefaultPathMutationCommitPlanRequest,
    commitPlanMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.runtimeDefaultPathMutationCommitPlanId.size == 0) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_PLAN_ID_NOT_CARRIED")
    }
    if (!request.controlledApplySnapshotCarried) {
        blockers.add("CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.targetRuntimeDefaultPathCarried) {
        blockers.add("TARGET_RUNTIME_DEFAULT_PATH_NOT_CARRIED")
    }
    if (!request.mutationPlanIdCarried) {
        blockers.add("MUTATION_PLAN_ID_NOT_CARRIED")
    }
    if (!request.atomicSwitchPlanCarried) {
        blockers.add("ATOMIC_SWITCH_PLAN_NOT_CARRIED")
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
    if (commitPlanMode == "unknown-runtime-default-path-mutation-commit-plan") {
        blockers.add("UNKNOWN_CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationCommitPlanNonClaims(): Array<String> {
    [
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_H1_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
        "NO_ACTUAL_LIVE_SERVER_WIRING",
        "NO_PRODUCTION_QUEUE_MUTATION",
        "NO_ACTUAL_RUNTIME_TASK_SPAWN",
        "NO_ACTUAL_HANDLER_INVOCATION",
        "NO_ACTUAL_REQUEST_CONTEXT_MUTATION",
        "NO_ACTUAL_RESPONSE_WRITE",
        "NO_ACTUAL_TRANSPORT_COMMIT",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
    ]
}
