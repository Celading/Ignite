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

public class JinguiAcceptedTransportH2DefaultEngineReadinessGateEvidence {
    public let h2LiveServerWiringGateBridge:
        JinguiAcceptedTransportH2LiveServerWiringGateBridge
    public let defaultEngineFlipReadinessGateReceipt:
        IgniteDefaultEngineFlipReadinessGateReceipt

    public init(
        h2LiveServerWiringGateBridge:
            JinguiAcceptedTransportH2LiveServerWiringGateBridge,
        defaultEngineFlipReadinessGateReceipt:
            IgniteDefaultEngineFlipReadinessGateReceipt
    ) {
        this.h2LiveServerWiringGateBridge = h2LiveServerWiringGateBridge
        this.defaultEngineFlipReadinessGateReceipt =
            defaultEngineFlipReadinessGateReceipt
    }
}

public class JinguiAcceptedTransportH2DefaultEngineReadinessGateBridge {
    public let h2DefaultEngineReadinessGateAccepted: Bool
    public let h2LiveServerWiringGateAccepted: Bool
    public let defaultEngineFlipReadinessAccepted: Bool
    public let defaultEngineFlipReadinessAllowed: Bool
    public let boundedDefaultEngineReadinessFollowupAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let actualHandlerInvocationAllowed: Bool
    public let actualRequestContextMutationAllowed: Bool
    public let actualResponseWriteAllowed: Bool
    public let actualTransportCommitAllowed: Bool
    public let actualLiveServerWiringAllowed: Bool
    public let actualDefaultEngineFlipAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
    public let liveServerWiringGateMode: String
    public let defaultEngineFlipReadinessMode: String
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
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2DefaultEngineReadinessGateAccepted: Bool,
        h2LiveServerWiringGateAccepted: Bool,
        defaultEngineFlipReadinessAccepted: Bool,
        defaultEngineFlipReadinessAllowed: Bool,
        boundedDefaultEngineReadinessFollowupAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        actualHandlerInvocationAllowed: Bool,
        actualRequestContextMutationAllowed: Bool,
        actualResponseWriteAllowed: Bool,
        actualTransportCommitAllowed: Bool,
        actualLiveServerWiringAllowed: Bool,
        actualDefaultEngineFlipAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
        liveServerWiringGateMode: String,
        defaultEngineFlipReadinessMode: String,
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
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2DefaultEngineReadinessGateAccepted =
            h2DefaultEngineReadinessGateAccepted
        this.h2LiveServerWiringGateAccepted = h2LiveServerWiringGateAccepted
        this.defaultEngineFlipReadinessAccepted =
            defaultEngineFlipReadinessAccepted
        this.defaultEngineFlipReadinessAllowed =
            defaultEngineFlipReadinessAllowed
        this.boundedDefaultEngineReadinessFollowupAllowed =
            boundedDefaultEngineReadinessFollowupAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.actualRuntimeTaskSpawnAllowed = actualRuntimeTaskSpawnAllowed
        this.actualHandlerInvocationAllowed = actualHandlerInvocationAllowed
        this.actualRequestContextMutationAllowed =
            actualRequestContextMutationAllowed
        this.actualResponseWriteAllowed = actualResponseWriteAllowed
        this.actualTransportCommitAllowed = actualTransportCommitAllowed
        this.actualLiveServerWiringAllowed = actualLiveServerWiringAllowed
        this.actualDefaultEngineFlipAllowed = actualDefaultEngineFlipAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.liveServerWiringGateMode = liveServerWiringGateMode
        this.defaultEngineFlipReadinessMode = defaultEngineFlipReadinessMode
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
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2DefaultEngineReadinessGateBridge(
    evidence: JinguiAcceptedTransportH2DefaultEngineReadinessGateEvidence
): JinguiAcceptedTransportH2DefaultEngineReadinessGateBridge {
    let h2LiveServerWiringBridge = evidence.h2LiveServerWiringGateBridge
    let readinessReceipt = evidence.defaultEngineFlipReadinessGateReceipt
    let nonClaims =
        jinguiAcceptedTransportH2DefaultEngineReadinessGateNonClaims()
    if (
        !h2LiveServerWiringBridge.h2LiveServerWiringGateAccepted ||
        !h2LiveServerWiringBridge.boundedLiveServerWiringGateFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2DefaultEngineReadinessGateBridge(
            false,
            h2LiveServerWiringBridge.h2LiveServerWiringGateAccepted,
            readinessReceipt.defaultEngineFlipReadinessAccepted,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            h2LiveServerWiringBridge.liveServerWiringGateMode,
            readinessReceipt.defaultEngineFlipReadinessMode,
            readinessReceipt.defaultEngineFlipReadinessGateId,
            h2LiveServerWiringBridge.liveServerWiringGateId,
            h2LiveServerWiringBridge.transportCommitGateId,
            h2LiveServerWiringBridge.responseWriteGateId,
            h2LiveServerWiringBridge.requestContextMutationGateId,
            h2LiveServerWiringBridge.handlerInvocationGateId,
            h2LiveServerWiringBridge.runtimeSpawnGateId,
            h2LiveServerWiringBridge.liveEnqueueProofId,
            h2LiveServerWiringBridge.executorHandoffId,
            h2LiveServerWiringBridge.controlledMutationApplyId,
            h2LiveServerWiringBridge.mutationApplyGateId,
            h2LiveServerWiringBridge.mutationCommitPlanId,
            h2LiveServerWiringBridge.mutationDryRunId,
            h2LiveServerWiringBridge.mutationGateId,
            h2LiveServerWiringBridge.commitBoundaryId,
            h2LiveServerWiringBridge.queueWriteId,
            h2LiveServerWiringBridge.queueDepthBefore,
            h2LiveServerWiringBridge.queueDepthAfter,
            "blocked-h2-live-server-wiring-gate-bridge",
            "collect-accepted-h2-live-server-wiring-gate-before-default-engine-readiness-gate",
            jinguiAcceptedTransportH2DefaultEngineReadinessGateLiveBridgeBlockers(
                h2LiveServerWiringBridge
            ),
            nonClaims,
            "repair H2 live server wiring gate before default-engine readiness; do not treat generic readiness receipts as H2 runtime readiness",
            "QUIC must pass live stream wiring gate before default stream runtime readiness"
        )
    }
    if (
        !readinessReceipt.defaultEngineFlipReadinessAccepted ||
        !readinessReceipt.defaultEngineFlipReadinessAllowed
    ) {
        return JinguiAcceptedTransportH2DefaultEngineReadinessGateBridge(
            false,
            true,
            readinessReceipt.defaultEngineFlipReadinessAccepted,
            readinessReceipt.defaultEngineFlipReadinessAllowed,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            readinessReceipt.liveServerWiringGateMode,
            readinessReceipt.defaultEngineFlipReadinessMode,
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
            "blocked-default-engine-readiness-gate-receipt",
            "collect-accepted-default-engine-readiness-gate-before-default-engine-apply-gate",
            jinguiAcceptedTransportH2DefaultEngineReadinessGateReceiptBlockers(
                readinessReceipt
            ),
            nonClaims,
            readinessReceipt.nextAction,
            "QUIC must not consume rejected default-engine readiness receipts for stream runtime apply"
        )
    }

    JinguiAcceptedTransportH2DefaultEngineReadinessGateBridge(
        true,
        true,
        true,
        readinessReceipt.defaultEngineFlipReadinessAllowed,
        true,
        readinessReceipt.productionQueueMutationAllowed,
        readinessReceipt.actualRuntimeTaskSpawnAllowed,
        readinessReceipt.actualHandlerInvocationAllowed,
        readinessReceipt.actualRequestContextMutationAllowed,
        readinessReceipt.actualResponseWriteAllowed,
        readinessReceipt.actualTransportCommitAllowed,
        readinessReceipt.actualLiveServerWiringAllowed,
        readinessReceipt.actualDefaultEngineFlipAllowed,
        readinessReceipt.publicReleaseAllowed,
        readinessReceipt.stdxRemovalAllowed,
        false,
        readinessReceipt.liveServerWiringGateMode,
        readinessReceipt.defaultEngineFlipReadinessMode,
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
        "accepted-h2-default-engine-readiness-gate-bridge",
        "record-h2-default-engine-readiness-without-default-engine-flip",
        [],
        nonClaims,
        "next packet may plan H2 default-engine apply gate; actual default flip, release, stdx removal, and H2 closure remain denied",
        "QUIC can reuse H2-style live-wiring-gate plus default-readiness separation before runtime default apply"
    )
}

func jinguiAcceptedTransportH2DefaultEngineReadinessGateLiveBridgeBlockers(
    bridge: JinguiAcceptedTransportH2LiveServerWiringGateBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("H2_LIVE_SERVER_WIRING_GATE:${bridge.status}")
    for (blocker in bridge.blockers) {
        blockers.add("H2_LIVE_SERVER_WIRING_GATE_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2DefaultEngineReadinessGateReceiptBlockers(
    receipt: IgniteDefaultEngineFlipReadinessGateReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("DEFAULT_ENGINE_READINESS_GATE:${receipt.status}")
    for (blocker in receipt.blockers) {
        blockers.add("DEFAULT_ENGINE_READINESS_GATE_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2DefaultEngineReadinessGateNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_ACTUAL_LIVE_SERVER_WIRING",
        "NO_ACTUAL_RESPONSE_WRITE",
        "NO_ACTUAL_TRANSPORT_COMMIT",
        "NO_ACTUAL_REQUEST_CONTEXT_MUTATION",
        "NO_ACTUAL_HANDLER_INVOCATION",
        "NO_ACTUAL_RUNTIME_TASK_SPAWN",
        "NO_PRODUCTION_QUEUE_MUTATION",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2DefaultEngineApplyGateEvidence {
    public let h2DefaultEngineReadinessGateBridge:
        JinguiAcceptedTransportH2DefaultEngineReadinessGateBridge
    public let defaultEngineFlipApplyGateReceipt:
        IgniteDefaultEngineFlipApplyGateReceipt

    public init(
        h2DefaultEngineReadinessGateBridge:
            JinguiAcceptedTransportH2DefaultEngineReadinessGateBridge,
        defaultEngineFlipApplyGateReceipt:
            IgniteDefaultEngineFlipApplyGateReceipt
    ) {
        this.h2DefaultEngineReadinessGateBridge =
            h2DefaultEngineReadinessGateBridge
        this.defaultEngineFlipApplyGateReceipt =
            defaultEngineFlipApplyGateReceipt
    }
}

public class JinguiAcceptedTransportH2DefaultEngineApplyGateBridge {
    public let h2DefaultEngineApplyGateAccepted: Bool
    public let h2DefaultEngineReadinessGateAccepted: Bool
    public let defaultEngineFlipApplyGateAccepted: Bool
    public let defaultEngineFlipApplyGateAllowed: Bool
    public let boundedDefaultEngineApplyGateFollowupAllowed: Bool
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
    public let h2RuntimeClosureClaimAllowed: Bool
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
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2DefaultEngineApplyGateAccepted: Bool,
        h2DefaultEngineReadinessGateAccepted: Bool,
        defaultEngineFlipApplyGateAccepted: Bool,
        defaultEngineFlipApplyGateAllowed: Bool,
        boundedDefaultEngineApplyGateFollowupAllowed: Bool,
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
        h2RuntimeClosureClaimAllowed: Bool,
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
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2DefaultEngineApplyGateAccepted =
            h2DefaultEngineApplyGateAccepted
        this.h2DefaultEngineReadinessGateAccepted =
            h2DefaultEngineReadinessGateAccepted
        this.defaultEngineFlipApplyGateAccepted =
            defaultEngineFlipApplyGateAccepted
        this.defaultEngineFlipApplyGateAllowed =
            defaultEngineFlipApplyGateAllowed
        this.boundedDefaultEngineApplyGateFollowupAllowed =
            boundedDefaultEngineApplyGateFollowupAllowed
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
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.defaultEngineFlipReadinessMode =
            defaultEngineFlipReadinessMode
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
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2DefaultEngineApplyGateBridge(
    evidence: JinguiAcceptedTransportH2DefaultEngineApplyGateEvidence
): JinguiAcceptedTransportH2DefaultEngineApplyGateBridge {
    let h2ReadinessBridge = evidence.h2DefaultEngineReadinessGateBridge
    let applyReceipt = evidence.defaultEngineFlipApplyGateReceipt
    let nonClaims = jinguiAcceptedTransportH2DefaultEngineApplyGateNonClaims()
    if (
        !h2ReadinessBridge.h2DefaultEngineReadinessGateAccepted ||
        !h2ReadinessBridge.boundedDefaultEngineReadinessFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2DefaultEngineApplyGateBridge(
            false,
            h2ReadinessBridge.h2DefaultEngineReadinessGateAccepted,
            applyReceipt.defaultEngineFlipApplyGateAccepted,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            h2ReadinessBridge.defaultEngineFlipReadinessMode,
            applyReceipt.defaultEngineFlipApplyGateMode,
            applyReceipt.defaultEngineFlipApplyGateId,
            h2ReadinessBridge.defaultEngineFlipReadinessGateId,
            h2ReadinessBridge.liveServerWiringGateId,
            h2ReadinessBridge.transportCommitGateId,
            h2ReadinessBridge.responseWriteGateId,
            h2ReadinessBridge.requestContextMutationGateId,
            h2ReadinessBridge.handlerInvocationGateId,
            h2ReadinessBridge.runtimeSpawnGateId,
            h2ReadinessBridge.liveEnqueueProofId,
            h2ReadinessBridge.executorHandoffId,
            h2ReadinessBridge.controlledMutationApplyId,
            h2ReadinessBridge.mutationApplyGateId,
            h2ReadinessBridge.mutationCommitPlanId,
            h2ReadinessBridge.mutationDryRunId,
            h2ReadinessBridge.mutationGateId,
            h2ReadinessBridge.commitBoundaryId,
            h2ReadinessBridge.queueWriteId,
            h2ReadinessBridge.queueDepthBefore,
            h2ReadinessBridge.queueDepthAfter,
            "blocked-h2-default-engine-readiness-gate-bridge",
            "collect-accepted-h2-default-engine-readiness-gate-before-default-engine-apply-gate",
            jinguiAcceptedTransportH2DefaultEngineApplyGateReadinessBridgeBlockers(
                h2ReadinessBridge
            ),
            nonClaims,
            "repair H2 default-engine readiness before apply gate; do not treat generic apply receipts as H2 runtime apply",
            "QUIC must pass default stream runtime readiness before runtime apply gate"
        )
    }
    if (
        !applyReceipt.defaultEngineFlipApplyGateAccepted ||
        !applyReceipt.defaultEngineFlipApplyGateAllowed
    ) {
        return JinguiAcceptedTransportH2DefaultEngineApplyGateBridge(
            false,
            true,
            applyReceipt.defaultEngineFlipApplyGateAccepted,
            applyReceipt.defaultEngineFlipApplyGateAllowed,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            applyReceipt.defaultEngineFlipReadinessMode,
            applyReceipt.defaultEngineFlipApplyGateMode,
            applyReceipt.defaultEngineFlipApplyGateId,
            applyReceipt.defaultEngineFlipReadinessGateId,
            applyReceipt.liveServerWiringGateId,
            applyReceipt.transportCommitGateId,
            applyReceipt.responseWriteGateId,
            applyReceipt.requestContextMutationGateId,
            applyReceipt.handlerInvocationGateId,
            applyReceipt.runtimeSpawnGateId,
            applyReceipt.liveEnqueueProofId,
            applyReceipt.executorHandoffId,
            applyReceipt.controlledMutationApplyId,
            applyReceipt.mutationApplyGateId,
            applyReceipt.mutationCommitPlanId,
            applyReceipt.mutationDryRunId,
            applyReceipt.mutationGateId,
            applyReceipt.commitBoundaryId,
            applyReceipt.queueWriteId,
            applyReceipt.queueDepthBefore,
            applyReceipt.queueDepthAfter,
            "blocked-default-engine-apply-gate-receipt",
            "collect-accepted-default-engine-apply-gate-before-controlled-default-apply",
            jinguiAcceptedTransportH2DefaultEngineApplyGateReceiptBlockers(
                applyReceipt
            ),
            nonClaims,
            applyReceipt.nextAction,
            "QUIC must not consume rejected apply receipts for default stream runtime mutation"
        )
    }

    JinguiAcceptedTransportH2DefaultEngineApplyGateBridge(
        true,
        true,
        true,
        applyReceipt.defaultEngineFlipApplyGateAllowed,
        true,
        applyReceipt.productionQueueMutationAllowed,
        applyReceipt.actualRuntimeTaskSpawnAllowed,
        applyReceipt.actualHandlerInvocationAllowed,
        applyReceipt.actualRequestContextMutationAllowed,
        applyReceipt.actualResponseWriteAllowed,
        applyReceipt.actualTransportCommitAllowed,
        applyReceipt.actualLiveServerWiringAllowed,
        applyReceipt.actualDefaultEngineFlipAllowed,
        applyReceipt.defaultEngineConfigMutationAllowed,
        applyReceipt.publicReleaseAllowed,
        applyReceipt.stdxRemovalAllowed,
        false,
        applyReceipt.defaultEngineFlipReadinessMode,
        applyReceipt.defaultEngineFlipApplyGateMode,
        applyReceipt.defaultEngineFlipApplyGateId,
        applyReceipt.defaultEngineFlipReadinessGateId,
        applyReceipt.liveServerWiringGateId,
        applyReceipt.transportCommitGateId,
        applyReceipt.responseWriteGateId,
        applyReceipt.requestContextMutationGateId,
        applyReceipt.handlerInvocationGateId,
        applyReceipt.runtimeSpawnGateId,
        applyReceipt.liveEnqueueProofId,
        applyReceipt.executorHandoffId,
        applyReceipt.controlledMutationApplyId,
        applyReceipt.mutationApplyGateId,
        applyReceipt.mutationCommitPlanId,
        applyReceipt.mutationDryRunId,
        applyReceipt.mutationGateId,
        applyReceipt.commitBoundaryId,
        applyReceipt.queueWriteId,
        applyReceipt.queueDepthBefore,
        applyReceipt.queueDepthAfter,
        "accepted-h2-default-engine-apply-gate-bridge",
        "record-h2-default-engine-apply-gate-without-default-mutation",
        [],
        nonClaims,
        "next packet may plan controlled H2 default-engine apply; actual default flip, config mutation, release, stdx removal, and H2 closure remain denied",
        "QUIC can reuse H2-style readiness plus apply-gate separation before controlled runtime mutation"
    )
}

func jinguiAcceptedTransportH2DefaultEngineApplyGateReadinessBridgeBlockers(
    bridge: JinguiAcceptedTransportH2DefaultEngineReadinessGateBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("H2_DEFAULT_ENGINE_READINESS_GATE:${bridge.status}")
    for (blocker in bridge.blockers) {
        blockers.add("H2_DEFAULT_ENGINE_READINESS_GATE_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2DefaultEngineApplyGateReceiptBlockers(
    receipt: IgniteDefaultEngineFlipApplyGateReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("DEFAULT_ENGINE_APPLY_GATE:${receipt.status}")
    for (blocker in receipt.blockers) {
        blockers.add("DEFAULT_ENGINE_APPLY_GATE_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2DefaultEngineApplyGateNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_ACTUAL_LIVE_SERVER_WIRING",
        "NO_ACTUAL_RESPONSE_WRITE",
        "NO_ACTUAL_TRANSPORT_COMMIT",
        "NO_ACTUAL_REQUEST_CONTEXT_MUTATION",
        "NO_ACTUAL_HANDLER_INVOCATION",
        "NO_ACTUAL_RUNTIME_TASK_SPAWN",
        "NO_PRODUCTION_QUEUE_MUTATION",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2ControlledDefaultEngineApplyEvidence {
    public let h2DefaultEngineApplyGateBridge:
        JinguiAcceptedTransportH2DefaultEngineApplyGateBridge
    public let controlledDefaultEngineFlipApplyReceipt:
        IgniteControlledDefaultEngineFlipApplyReceipt

    public init(
        h2DefaultEngineApplyGateBridge:
            JinguiAcceptedTransportH2DefaultEngineApplyGateBridge,
        controlledDefaultEngineFlipApplyReceipt:
            IgniteControlledDefaultEngineFlipApplyReceipt
    ) {
        this.h2DefaultEngineApplyGateBridge =
            h2DefaultEngineApplyGateBridge
        this.controlledDefaultEngineFlipApplyReceipt =
            controlledDefaultEngineFlipApplyReceipt
    }
}

public class JinguiAcceptedTransportH2ControlledDefaultEngineApplyBridge {
    public let h2ControlledDefaultEngineApplyAccepted: Bool
    public let h2DefaultEngineApplyGateAccepted: Bool
    public let controlledDefaultEngineFlipApplyAccepted: Bool
    public let controlledDefaultEngineFlipApplyAllowed: Bool
    public let boundedControlledDefaultEngineApplyFollowupAllowed: Bool
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
    public let h2RuntimeClosureClaimAllowed: Bool
    public let defaultEngineFlipReadinessMode: String
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
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2ControlledDefaultEngineApplyAccepted: Bool,
        h2DefaultEngineApplyGateAccepted: Bool,
        controlledDefaultEngineFlipApplyAccepted: Bool,
        controlledDefaultEngineFlipApplyAllowed: Bool,
        boundedControlledDefaultEngineApplyFollowupAllowed: Bool,
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
        h2RuntimeClosureClaimAllowed: Bool,
        defaultEngineFlipReadinessMode: String,
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
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2ControlledDefaultEngineApplyAccepted =
            h2ControlledDefaultEngineApplyAccepted
        this.h2DefaultEngineApplyGateAccepted =
            h2DefaultEngineApplyGateAccepted
        this.controlledDefaultEngineFlipApplyAccepted =
            controlledDefaultEngineFlipApplyAccepted
        this.controlledDefaultEngineFlipApplyAllowed =
            controlledDefaultEngineFlipApplyAllowed
        this.boundedControlledDefaultEngineApplyFollowupAllowed =
            boundedControlledDefaultEngineApplyFollowupAllowed
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
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.defaultEngineFlipReadinessMode =
            defaultEngineFlipReadinessMode
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
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2ControlledDefaultEngineApplyBridge(
    evidence: JinguiAcceptedTransportH2ControlledDefaultEngineApplyEvidence
): JinguiAcceptedTransportH2ControlledDefaultEngineApplyBridge {
    let h2ApplyBridge = evidence.h2DefaultEngineApplyGateBridge
    let controlledReceipt = evidence.controlledDefaultEngineFlipApplyReceipt
    let nonClaims =
        jinguiAcceptedTransportH2ControlledDefaultEngineApplyNonClaims()
    if (
        !h2ApplyBridge.h2DefaultEngineApplyGateAccepted ||
        !h2ApplyBridge.boundedDefaultEngineApplyGateFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2ControlledDefaultEngineApplyBridge(
            false,
            h2ApplyBridge.h2DefaultEngineApplyGateAccepted,
            controlledReceipt.controlledDefaultEngineFlipApplyAccepted,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            h2ApplyBridge.defaultEngineFlipReadinessMode,
            h2ApplyBridge.defaultEngineFlipApplyGateMode,
            controlledReceipt.controlledDefaultEngineFlipApplyMode,
            controlledReceipt.controlledDefaultEngineFlipApplyId,
            h2ApplyBridge.defaultEngineFlipApplyGateId,
            h2ApplyBridge.defaultEngineFlipReadinessGateId,
            h2ApplyBridge.liveServerWiringGateId,
            h2ApplyBridge.transportCommitGateId,
            h2ApplyBridge.responseWriteGateId,
            h2ApplyBridge.requestContextMutationGateId,
            h2ApplyBridge.handlerInvocationGateId,
            h2ApplyBridge.runtimeSpawnGateId,
            h2ApplyBridge.liveEnqueueProofId,
            h2ApplyBridge.executorHandoffId,
            h2ApplyBridge.controlledMutationApplyId,
            h2ApplyBridge.mutationApplyGateId,
            h2ApplyBridge.mutationCommitPlanId,
            h2ApplyBridge.mutationDryRunId,
            h2ApplyBridge.mutationGateId,
            h2ApplyBridge.commitBoundaryId,
            h2ApplyBridge.queueWriteId,
            h2ApplyBridge.queueDepthBefore,
            h2ApplyBridge.queueDepthAfter,
            "blocked-h2-default-engine-apply-gate-bridge",
            "collect-accepted-h2-default-engine-apply-gate-before-controlled-default-apply",
            jinguiAcceptedTransportH2ControlledDefaultEngineApplyBridgeBlockers(
                h2ApplyBridge
            ),
            nonClaims,
            "repair H2 default-engine apply gate before controlled default apply; do not treat generic controlled apply receipts as H2 runtime mutation",
            "QUIC must pass default stream apply gate before controlled runtime apply"
        )
    }
    if (
        !controlledReceipt.controlledDefaultEngineFlipApplyAccepted ||
        !controlledReceipt.controlledDefaultEngineFlipApplyAllowed
    ) {
        return JinguiAcceptedTransportH2ControlledDefaultEngineApplyBridge(
            false,
            true,
            controlledReceipt.controlledDefaultEngineFlipApplyAccepted,
            controlledReceipt.controlledDefaultEngineFlipApplyAllowed,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            h2ApplyBridge.defaultEngineFlipReadinessMode,
            controlledReceipt.defaultEngineFlipApplyGateMode,
            controlledReceipt.controlledDefaultEngineFlipApplyMode,
            controlledReceipt.controlledDefaultEngineFlipApplyId,
            controlledReceipt.defaultEngineFlipApplyGateId,
            controlledReceipt.defaultEngineFlipReadinessGateId,
            controlledReceipt.liveServerWiringGateId,
            controlledReceipt.transportCommitGateId,
            controlledReceipt.responseWriteGateId,
            controlledReceipt.requestContextMutationGateId,
            controlledReceipt.handlerInvocationGateId,
            controlledReceipt.runtimeSpawnGateId,
            controlledReceipt.liveEnqueueProofId,
            controlledReceipt.executorHandoffId,
            controlledReceipt.controlledMutationApplyId,
            controlledReceipt.mutationApplyGateId,
            controlledReceipt.mutationCommitPlanId,
            controlledReceipt.mutationDryRunId,
            controlledReceipt.mutationGateId,
            controlledReceipt.commitBoundaryId,
            controlledReceipt.queueWriteId,
            controlledReceipt.queueDepthBefore,
            controlledReceipt.queueDepthAfter,
            "blocked-controlled-default-engine-apply-receipt",
            "collect-accepted-controlled-default-engine-apply-before-default-mutation-plan",
            jinguiAcceptedTransportH2ControlledDefaultEngineApplyReceiptBlockers(
                controlledReceipt
            ),
            nonClaims,
            controlledReceipt.nextAction,
            "QUIC must not consume rejected controlled apply receipts for default stream runtime mutation"
        )
    }

    JinguiAcceptedTransportH2ControlledDefaultEngineApplyBridge(
        true,
        true,
        true,
        controlledReceipt.controlledDefaultEngineFlipApplyAllowed,
        true,
        controlledReceipt.productionQueueMutationAllowed,
        controlledReceipt.actualRuntimeTaskSpawnAllowed,
        controlledReceipt.actualHandlerInvocationAllowed,
        controlledReceipt.actualRequestContextMutationAllowed,
        controlledReceipt.actualResponseWriteAllowed,
        controlledReceipt.actualTransportCommitAllowed,
        controlledReceipt.actualLiveServerWiringAllowed,
        controlledReceipt.actualDefaultEngineFlipAllowed,
        controlledReceipt.defaultEngineConfigMutationAllowed,
        controlledReceipt.runtimeDefaultPathMutationAllowed,
        controlledReceipt.publicReleaseAllowed,
        controlledReceipt.stdxRemovalAllowed,
        false,
        h2ApplyBridge.defaultEngineFlipReadinessMode,
        controlledReceipt.defaultEngineFlipApplyGateMode,
        controlledReceipt.controlledDefaultEngineFlipApplyMode,
        controlledReceipt.controlledDefaultEngineFlipApplyId,
        controlledReceipt.defaultEngineFlipApplyGateId,
        controlledReceipt.defaultEngineFlipReadinessGateId,
        controlledReceipt.liveServerWiringGateId,
        controlledReceipt.transportCommitGateId,
        controlledReceipt.responseWriteGateId,
        controlledReceipt.requestContextMutationGateId,
        controlledReceipt.handlerInvocationGateId,
        controlledReceipt.runtimeSpawnGateId,
        controlledReceipt.liveEnqueueProofId,
        controlledReceipt.executorHandoffId,
        controlledReceipt.controlledMutationApplyId,
        controlledReceipt.mutationApplyGateId,
        controlledReceipt.mutationCommitPlanId,
        controlledReceipt.mutationDryRunId,
        controlledReceipt.mutationGateId,
        controlledReceipt.commitBoundaryId,
        controlledReceipt.queueWriteId,
        controlledReceipt.queueDepthBefore,
        controlledReceipt.queueDepthAfter,
        "accepted-h2-controlled-default-engine-apply-bridge",
        "record-h2-controlled-default-engine-apply-without-default-mutation",
        [],
        nonClaims,
        "next packet may plan H2 default-engine mutation commit-plan; actual default flip, config mutation, runtime default-path mutation, release, stdx removal, and H2 closure remain denied",
        "QUIC can reuse H2-style apply gate plus controlled apply separation before runtime mutation planning"
    )
}

func jinguiAcceptedTransportH2ControlledDefaultEngineApplyBridgeBlockers(
    bridge: JinguiAcceptedTransportH2DefaultEngineApplyGateBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("H2_DEFAULT_ENGINE_APPLY_GATE:${bridge.status}")
    for (blocker in bridge.blockers) {
        blockers.add("H2_DEFAULT_ENGINE_APPLY_GATE_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2ControlledDefaultEngineApplyReceiptBlockers(
    receipt: IgniteControlledDefaultEngineFlipApplyReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("CONTROLLED_DEFAULT_ENGINE_APPLY:${receipt.status}")
    for (blocker in receipt.blockers) {
        blockers.add("CONTROLLED_DEFAULT_ENGINE_APPLY_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2ControlledDefaultEngineApplyNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_ACTUAL_LIVE_SERVER_WIRING",
        "NO_ACTUAL_RESPONSE_WRITE",
        "NO_ACTUAL_TRANSPORT_COMMIT",
        "NO_ACTUAL_REQUEST_CONTEXT_MUTATION",
        "NO_ACTUAL_HANDLER_INVOCATION",
        "NO_ACTUAL_RUNTIME_TASK_SPAWN",
        "NO_PRODUCTION_QUEUE_MUTATION",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2DefaultEngineMutationCommitPlanEvidence {
    public let h2ControlledDefaultEngineApplyBridge:
        JinguiAcceptedTransportH2ControlledDefaultEngineApplyBridge
    public let defaultEngineMutationCommitPlanReceipt:
        IgniteDefaultEngineMutationCommitPlanReceipt

    public init(
        h2ControlledDefaultEngineApplyBridge:
            JinguiAcceptedTransportH2ControlledDefaultEngineApplyBridge,
        defaultEngineMutationCommitPlanReceipt:
            IgniteDefaultEngineMutationCommitPlanReceipt
    ) {
        this.h2ControlledDefaultEngineApplyBridge =
            h2ControlledDefaultEngineApplyBridge
        this.defaultEngineMutationCommitPlanReceipt =
            defaultEngineMutationCommitPlanReceipt
    }
}

public class JinguiAcceptedTransportH2DefaultEngineMutationCommitPlanBridge {
    public let h2DefaultEngineMutationCommitPlanAccepted: Bool
    public let h2ControlledDefaultEngineApplyAccepted: Bool
    public let defaultEngineMutationCommitPlanAccepted: Bool
    public let defaultEngineMutationCommitPlanAllowed: Bool
    public let boundedDefaultEngineMutationCommitPlanFollowupAllowed: Bool
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
    public let h2RuntimeClosureClaimAllowed: Bool
    public let defaultEngineMutationCommitPlanMode: String
    public let defaultEngineMutationCommitPlanId: String
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
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2DefaultEngineMutationCommitPlanAccepted: Bool,
        h2ControlledDefaultEngineApplyAccepted: Bool,
        defaultEngineMutationCommitPlanAccepted: Bool,
        defaultEngineMutationCommitPlanAllowed: Bool,
        boundedDefaultEngineMutationCommitPlanFollowupAllowed: Bool,
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
        h2RuntimeClosureClaimAllowed: Bool,
        defaultEngineMutationCommitPlanMode: String,
        defaultEngineMutationCommitPlanId: String,
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
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2DefaultEngineMutationCommitPlanAccepted =
            h2DefaultEngineMutationCommitPlanAccepted
        this.h2ControlledDefaultEngineApplyAccepted =
            h2ControlledDefaultEngineApplyAccepted
        this.defaultEngineMutationCommitPlanAccepted =
            defaultEngineMutationCommitPlanAccepted
        this.defaultEngineMutationCommitPlanAllowed =
            defaultEngineMutationCommitPlanAllowed
        this.boundedDefaultEngineMutationCommitPlanFollowupAllowed =
            boundedDefaultEngineMutationCommitPlanFollowupAllowed
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
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.defaultEngineMutationCommitPlanMode =
            defaultEngineMutationCommitPlanMode
        this.defaultEngineMutationCommitPlanId =
            defaultEngineMutationCommitPlanId
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
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2DefaultEngineMutationCommitPlanBridge(
    evidence: JinguiAcceptedTransportH2DefaultEngineMutationCommitPlanEvidence
): JinguiAcceptedTransportH2DefaultEngineMutationCommitPlanBridge {
    let h2ControlledApplyBridge =
        evidence.h2ControlledDefaultEngineApplyBridge
    let commitPlanReceipt = evidence.defaultEngineMutationCommitPlanReceipt
    let nonClaims =
        jinguiAcceptedTransportH2DefaultEngineMutationCommitPlanNonClaims()
    if (
        !h2ControlledApplyBridge.h2ControlledDefaultEngineApplyAccepted ||
        !h2ControlledApplyBridge.boundedControlledDefaultEngineApplyFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2DefaultEngineMutationCommitPlanBridge(
            false,
            h2ControlledApplyBridge.h2ControlledDefaultEngineApplyAccepted,
            commitPlanReceipt.defaultEngineMutationCommitPlanAccepted,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            commitPlanReceipt.defaultEngineMutationCommitPlanMode,
            commitPlanReceipt.defaultEngineMutationCommitPlanId,
            h2ControlledApplyBridge.controlledDefaultEngineFlipApplyMode,
            h2ControlledApplyBridge.controlledDefaultEngineFlipApplyId,
            h2ControlledApplyBridge.defaultEngineFlipApplyGateId,
            h2ControlledApplyBridge.defaultEngineFlipReadinessGateId,
            h2ControlledApplyBridge.liveServerWiringGateId,
            h2ControlledApplyBridge.transportCommitGateId,
            h2ControlledApplyBridge.responseWriteGateId,
            h2ControlledApplyBridge.requestContextMutationGateId,
            h2ControlledApplyBridge.handlerInvocationGateId,
            h2ControlledApplyBridge.runtimeSpawnGateId,
            h2ControlledApplyBridge.liveEnqueueProofId,
            h2ControlledApplyBridge.executorHandoffId,
            h2ControlledApplyBridge.controlledMutationApplyId,
            h2ControlledApplyBridge.mutationApplyGateId,
            h2ControlledApplyBridge.mutationCommitPlanId,
            h2ControlledApplyBridge.mutationDryRunId,
            h2ControlledApplyBridge.mutationGateId,
            h2ControlledApplyBridge.commitBoundaryId,
            h2ControlledApplyBridge.queueWriteId,
            h2ControlledApplyBridge.queueDepthBefore,
            h2ControlledApplyBridge.queueDepthAfter,
            "blocked-h2-controlled-default-engine-apply-bridge",
            "collect-accepted-h2-controlled-default-engine-apply-before-default-engine-mutation-commit-plan",
            jinguiAcceptedTransportH2DefaultEngineMutationCommitPlanApplyBlockers(
                h2ControlledApplyBridge
            ),
            nonClaims,
            "repair H2 controlled default-engine apply bridge before default-engine mutation commit-plan; do not treat generic commit-plan receipts as H2 runtime mutation",
            "QUIC must pass stream controlled apply before default stream mutation commit-plan"
        )
    }
    if (
        !commitPlanReceipt.defaultEngineMutationCommitPlanAccepted ||
        !commitPlanReceipt.defaultEngineMutationCommitPlanAllowed
    ) {
        return JinguiAcceptedTransportH2DefaultEngineMutationCommitPlanBridge(
            false,
            true,
            commitPlanReceipt.defaultEngineMutationCommitPlanAccepted,
            commitPlanReceipt.defaultEngineMutationCommitPlanAllowed,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            commitPlanReceipt.defaultEngineMutationCommitPlanMode,
            commitPlanReceipt.defaultEngineMutationCommitPlanId,
            commitPlanReceipt.controlledDefaultEngineFlipApplyMode,
            commitPlanReceipt.controlledDefaultEngineFlipApplyId,
            commitPlanReceipt.defaultEngineFlipApplyGateId,
            commitPlanReceipt.defaultEngineFlipReadinessGateId,
            commitPlanReceipt.liveServerWiringGateId,
            commitPlanReceipt.transportCommitGateId,
            commitPlanReceipt.responseWriteGateId,
            commitPlanReceipt.requestContextMutationGateId,
            commitPlanReceipt.handlerInvocationGateId,
            commitPlanReceipt.runtimeSpawnGateId,
            commitPlanReceipt.liveEnqueueProofId,
            commitPlanReceipt.executorHandoffId,
            commitPlanReceipt.controlledMutationApplyId,
            commitPlanReceipt.mutationApplyGateId,
            commitPlanReceipt.mutationCommitPlanId,
            commitPlanReceipt.mutationDryRunId,
            commitPlanReceipt.mutationGateId,
            commitPlanReceipt.commitBoundaryId,
            commitPlanReceipt.queueWriteId,
            commitPlanReceipt.queueDepthBefore,
            commitPlanReceipt.queueDepthAfter,
            "blocked-default-engine-mutation-commit-plan-receipt",
            "collect-accepted-default-engine-mutation-commit-plan-before-default-engine-mutation-dry-run",
            jinguiAcceptedTransportH2DefaultEngineMutationCommitPlanReceiptBlockers(
                commitPlanReceipt
            ),
            nonClaims,
            commitPlanReceipt.nextAction,
            "QUIC must not consume rejected default-engine mutation commit-plan receipts for stream default mutation"
        )
    }

    JinguiAcceptedTransportH2DefaultEngineMutationCommitPlanBridge(
        true,
        true,
        true,
        commitPlanReceipt.defaultEngineMutationCommitPlanAllowed,
        true,
        commitPlanReceipt.productionQueueMutationAllowed,
        commitPlanReceipt.actualRuntimeTaskSpawnAllowed,
        commitPlanReceipt.actualHandlerInvocationAllowed,
        commitPlanReceipt.actualRequestContextMutationAllowed,
        commitPlanReceipt.actualResponseWriteAllowed,
        commitPlanReceipt.actualTransportCommitAllowed,
        commitPlanReceipt.actualLiveServerWiringAllowed,
        commitPlanReceipt.actualDefaultEngineFlipAllowed,
        commitPlanReceipt.defaultEngineConfigMutationAllowed,
        commitPlanReceipt.runtimeDefaultPathMutationAllowed,
        commitPlanReceipt.publicReleaseAllowed,
        commitPlanReceipt.stdxRemovalAllowed,
        false,
        commitPlanReceipt.defaultEngineMutationCommitPlanMode,
        commitPlanReceipt.defaultEngineMutationCommitPlanId,
        commitPlanReceipt.controlledDefaultEngineFlipApplyMode,
        commitPlanReceipt.controlledDefaultEngineFlipApplyId,
        commitPlanReceipt.defaultEngineFlipApplyGateId,
        commitPlanReceipt.defaultEngineFlipReadinessGateId,
        commitPlanReceipt.liveServerWiringGateId,
        commitPlanReceipt.transportCommitGateId,
        commitPlanReceipt.responseWriteGateId,
        commitPlanReceipt.requestContextMutationGateId,
        commitPlanReceipt.handlerInvocationGateId,
        commitPlanReceipt.runtimeSpawnGateId,
        commitPlanReceipt.liveEnqueueProofId,
        commitPlanReceipt.executorHandoffId,
        commitPlanReceipt.controlledMutationApplyId,
        commitPlanReceipt.mutationApplyGateId,
        commitPlanReceipt.mutationCommitPlanId,
        commitPlanReceipt.mutationDryRunId,
        commitPlanReceipt.mutationGateId,
        commitPlanReceipt.commitBoundaryId,
        commitPlanReceipt.queueWriteId,
        commitPlanReceipt.queueDepthBefore,
        commitPlanReceipt.queueDepthAfter,
        "accepted-h2-default-engine-mutation-commit-plan-bridge",
        "record-h2-default-engine-mutation-commit-plan-without-default-engine-mutation",
        [],
        nonClaims,
        "next packet may dry-run H2 default-engine mutation; actual default flip, config mutation, runtime default-path mutation, release, stdx removal, and H2 closure remain denied",
        "QUIC can reuse H2-style controlled apply plus generic commit-plan separation before runtime default mutation dry-run"
    )
}

func jinguiAcceptedTransportH2DefaultEngineMutationCommitPlanApplyBlockers(
    bridge: JinguiAcceptedTransportH2ControlledDefaultEngineApplyBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("H2_CONTROLLED_DEFAULT_ENGINE_APPLY:${bridge.status}")
    for (blocker in bridge.blockers) {
        blockers.add("H2_CONTROLLED_DEFAULT_ENGINE_APPLY_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2DefaultEngineMutationCommitPlanReceiptBlockers(
    receipt: IgniteDefaultEngineMutationCommitPlanReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("DEFAULT_ENGINE_MUTATION_COMMIT_PLAN:${receipt.status}")
    for (blocker in receipt.blockers) {
        blockers.add("DEFAULT_ENGINE_MUTATION_COMMIT_PLAN_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2DefaultEngineMutationCommitPlanNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_ACTUAL_LIVE_SERVER_WIRING",
        "NO_ACTUAL_RESPONSE_WRITE",
        "NO_ACTUAL_TRANSPORT_COMMIT",
        "NO_ACTUAL_REQUEST_CONTEXT_MUTATION",
        "NO_ACTUAL_HANDLER_INVOCATION",
        "NO_ACTUAL_RUNTIME_TASK_SPAWN",
        "NO_PRODUCTION_QUEUE_MUTATION",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2DefaultEngineMutationDryRunEvidence {
    public let h2DefaultEngineMutationCommitPlanBridge:
        JinguiAcceptedTransportH2DefaultEngineMutationCommitPlanBridge
    public let defaultEngineMutationDryRunReceipt:
        IgniteDefaultEngineMutationDryRunReceipt

    public init(
        h2DefaultEngineMutationCommitPlanBridge:
            JinguiAcceptedTransportH2DefaultEngineMutationCommitPlanBridge,
        defaultEngineMutationDryRunReceipt:
            IgniteDefaultEngineMutationDryRunReceipt
    ) {
        this.h2DefaultEngineMutationCommitPlanBridge =
            h2DefaultEngineMutationCommitPlanBridge
        this.defaultEngineMutationDryRunReceipt =
            defaultEngineMutationDryRunReceipt
    }
}

public class JinguiAcceptedTransportH2DefaultEngineMutationDryRunBridge {
    public let h2DefaultEngineMutationDryRunAccepted: Bool
    public let h2DefaultEngineMutationCommitPlanAccepted: Bool
    public let defaultEngineMutationDryRunAccepted: Bool
    public let defaultEngineMutationDryRunAllowed: Bool
    public let boundedDefaultEngineMutationDryRunFollowupAllowed: Bool
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
    public let h2RuntimeClosureClaimAllowed: Bool
    public let defaultEngineMutationDryRunMode: String
    public let defaultEngineMutationDryRunId: String
    public let defaultEngineMutationCommitPlanMode: String
    public let defaultEngineMutationCommitPlanId: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2DefaultEngineMutationDryRunAccepted: Bool,
        h2DefaultEngineMutationCommitPlanAccepted: Bool,
        defaultEngineMutationDryRunAccepted: Bool,
        defaultEngineMutationDryRunAllowed: Bool,
        boundedDefaultEngineMutationDryRunFollowupAllowed: Bool,
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
        h2RuntimeClosureClaimAllowed: Bool,
        defaultEngineMutationDryRunMode: String,
        defaultEngineMutationDryRunId: String,
        defaultEngineMutationCommitPlanMode: String,
        defaultEngineMutationCommitPlanId: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2DefaultEngineMutationDryRunAccepted =
            h2DefaultEngineMutationDryRunAccepted
        this.h2DefaultEngineMutationCommitPlanAccepted =
            h2DefaultEngineMutationCommitPlanAccepted
        this.defaultEngineMutationDryRunAccepted =
            defaultEngineMutationDryRunAccepted
        this.defaultEngineMutationDryRunAllowed =
            defaultEngineMutationDryRunAllowed
        this.boundedDefaultEngineMutationDryRunFollowupAllowed =
            boundedDefaultEngineMutationDryRunFollowupAllowed
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
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.defaultEngineMutationDryRunMode = defaultEngineMutationDryRunMode
        this.defaultEngineMutationDryRunId = defaultEngineMutationDryRunId
        this.defaultEngineMutationCommitPlanMode =
            defaultEngineMutationCommitPlanMode
        this.defaultEngineMutationCommitPlanId =
            defaultEngineMutationCommitPlanId
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2DefaultEngineMutationDryRunBridge(
    evidence: JinguiAcceptedTransportH2DefaultEngineMutationDryRunEvidence
): JinguiAcceptedTransportH2DefaultEngineMutationDryRunBridge {
    let h2CommitPlanBridge =
        evidence.h2DefaultEngineMutationCommitPlanBridge
    let dryRunReceipt = evidence.defaultEngineMutationDryRunReceipt
    let nonClaims =
        jinguiAcceptedTransportH2DefaultEngineMutationDryRunNonClaims()
    if (
        !h2CommitPlanBridge.h2DefaultEngineMutationCommitPlanAccepted ||
        !h2CommitPlanBridge.boundedDefaultEngineMutationCommitPlanFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2DefaultEngineMutationDryRunBridge(
            false,
            h2CommitPlanBridge.h2DefaultEngineMutationCommitPlanAccepted,
            dryRunReceipt.defaultEngineMutationDryRunAccepted,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            dryRunReceipt.defaultEngineMutationDryRunMode,
            dryRunReceipt.defaultEngineMutationDryRunId,
            h2CommitPlanBridge.defaultEngineMutationCommitPlanMode,
            h2CommitPlanBridge.defaultEngineMutationCommitPlanId,
            "blocked-h2-default-engine-mutation-commit-plan-bridge",
            "collect-accepted-h2-default-engine-mutation-commit-plan-before-default-engine-mutation-dry-run",
            jinguiAcceptedTransportH2DefaultEngineMutationDryRunCommitPlanBlockers(
                h2CommitPlanBridge
            ),
            nonClaims,
            "repair H2 default-engine mutation commit-plan bridge before default-engine mutation dry-run; do not treat generic dry-run receipts as H2 runtime mutation",
            "QUIC must pass stream default mutation commit-plan before default stream mutation dry-run"
        )
    }
    if (
        !dryRunReceipt.defaultEngineMutationDryRunAccepted ||
        !dryRunReceipt.defaultEngineMutationDryRunAllowed
    ) {
        return JinguiAcceptedTransportH2DefaultEngineMutationDryRunBridge(
            false,
            true,
            dryRunReceipt.defaultEngineMutationDryRunAccepted,
            dryRunReceipt.defaultEngineMutationDryRunAllowed,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            dryRunReceipt.defaultEngineMutationDryRunMode,
            dryRunReceipt.defaultEngineMutationDryRunId,
            dryRunReceipt.defaultEngineMutationCommitPlanMode,
            dryRunReceipt.defaultEngineMutationCommitPlanId,
            "blocked-default-engine-mutation-dry-run-receipt",
            "collect-accepted-default-engine-mutation-dry-run-before-default-engine-mutation-apply-gate",
            jinguiAcceptedTransportH2DefaultEngineMutationDryRunReceiptBlockers(
                dryRunReceipt
            ),
            nonClaims,
            dryRunReceipt.nextAction,
            "QUIC must not consume rejected default-engine mutation dry-run receipts for stream default mutation"
        )
    }

    JinguiAcceptedTransportH2DefaultEngineMutationDryRunBridge(
        true,
        true,
        true,
        dryRunReceipt.defaultEngineMutationDryRunAllowed,
        true,
        dryRunReceipt.productionQueueMutationAllowed,
        dryRunReceipt.actualRuntimeTaskSpawnAllowed,
        dryRunReceipt.actualHandlerInvocationAllowed,
        dryRunReceipt.actualRequestContextMutationAllowed,
        dryRunReceipt.actualResponseWriteAllowed,
        dryRunReceipt.actualTransportCommitAllowed,
        dryRunReceipt.actualLiveServerWiringAllowed,
        dryRunReceipt.actualDefaultEngineFlipAllowed,
        dryRunReceipt.defaultEngineConfigMutationAllowed,
        dryRunReceipt.runtimeDefaultPathMutationAllowed,
        dryRunReceipt.publicReleaseAllowed,
        dryRunReceipt.stdxRemovalAllowed,
        false,
        dryRunReceipt.defaultEngineMutationDryRunMode,
        dryRunReceipt.defaultEngineMutationDryRunId,
        dryRunReceipt.defaultEngineMutationCommitPlanMode,
        dryRunReceipt.defaultEngineMutationCommitPlanId,
        "accepted-h2-default-engine-mutation-dry-run-bridge",
        "record-h2-default-engine-mutation-dry-run-without-default-engine-mutation",
        [],
        nonClaims,
        "next packet may gate H2 default-engine mutation apply; actual default flip, config mutation, runtime default-path mutation, release, stdx removal, and H2 closure remain denied",
        "QUIC can reuse H2-style commit-plan plus generic dry-run separation before runtime default mutation apply gate"
    )
}

func jinguiAcceptedTransportH2DefaultEngineMutationDryRunCommitPlanBlockers(
    bridge: JinguiAcceptedTransportH2DefaultEngineMutationCommitPlanBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("H2_DEFAULT_ENGINE_MUTATION_COMMIT_PLAN:${bridge.status}")
    for (blocker in bridge.blockers) {
        blockers.add("H2_DEFAULT_ENGINE_MUTATION_COMMIT_PLAN_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2DefaultEngineMutationDryRunReceiptBlockers(
    receipt: IgniteDefaultEngineMutationDryRunReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("DEFAULT_ENGINE_MUTATION_DRY_RUN:${receipt.status}")
    for (blocker in receipt.blockers) {
        blockers.add("DEFAULT_ENGINE_MUTATION_DRY_RUN_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2DefaultEngineMutationDryRunNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_ACTUAL_LIVE_SERVER_WIRING",
        "NO_ACTUAL_RESPONSE_WRITE",
        "NO_ACTUAL_TRANSPORT_COMMIT",
        "NO_ACTUAL_REQUEST_CONTEXT_MUTATION",
        "NO_ACTUAL_HANDLER_INVOCATION",
        "NO_ACTUAL_RUNTIME_TASK_SPAWN",
        "NO_PRODUCTION_QUEUE_MUTATION",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2DefaultEngineMutationApplyGateEvidence {
    public let h2DefaultEngineMutationDryRunBridge:
        JinguiAcceptedTransportH2DefaultEngineMutationDryRunBridge
    public let defaultEngineMutationApplyGateReceipt:
        IgniteDefaultEngineMutationApplyGateReceipt

    public init(
        h2DefaultEngineMutationDryRunBridge:
            JinguiAcceptedTransportH2DefaultEngineMutationDryRunBridge,
        defaultEngineMutationApplyGateReceipt:
            IgniteDefaultEngineMutationApplyGateReceipt
    ) {
        this.h2DefaultEngineMutationDryRunBridge =
            h2DefaultEngineMutationDryRunBridge
        this.defaultEngineMutationApplyGateReceipt =
            defaultEngineMutationApplyGateReceipt
    }
}

public class JinguiAcceptedTransportH2DefaultEngineMutationApplyGateBridge {
    public let h2DefaultEngineMutationApplyGateAccepted: Bool
    public let h2DefaultEngineMutationDryRunAccepted: Bool
    public let defaultEngineMutationApplyGateAccepted: Bool
    public let defaultEngineMutationApplyGateAllowed: Bool
    public let boundedDefaultEngineMutationApplyGateFollowupAllowed: Bool
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
    public let h2RuntimeClosureClaimAllowed: Bool
    public let defaultEngineMutationApplyGateMode: String
    public let defaultEngineMutationApplyGateId: String
    public let defaultEngineMutationDryRunMode: String
    public let defaultEngineMutationDryRunId: String
    public let defaultEngineMutationCommitPlanId: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2DefaultEngineMutationApplyGateAccepted: Bool,
        h2DefaultEngineMutationDryRunAccepted: Bool,
        defaultEngineMutationApplyGateAccepted: Bool,
        defaultEngineMutationApplyGateAllowed: Bool,
        boundedDefaultEngineMutationApplyGateFollowupAllowed: Bool,
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
        h2RuntimeClosureClaimAllowed: Bool,
        defaultEngineMutationApplyGateMode: String,
        defaultEngineMutationApplyGateId: String,
        defaultEngineMutationDryRunMode: String,
        defaultEngineMutationDryRunId: String,
        defaultEngineMutationCommitPlanId: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2DefaultEngineMutationApplyGateAccepted =
            h2DefaultEngineMutationApplyGateAccepted
        this.h2DefaultEngineMutationDryRunAccepted =
            h2DefaultEngineMutationDryRunAccepted
        this.defaultEngineMutationApplyGateAccepted =
            defaultEngineMutationApplyGateAccepted
        this.defaultEngineMutationApplyGateAllowed =
            defaultEngineMutationApplyGateAllowed
        this.boundedDefaultEngineMutationApplyGateFollowupAllowed =
            boundedDefaultEngineMutationApplyGateFollowupAllowed
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
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.defaultEngineMutationApplyGateMode =
            defaultEngineMutationApplyGateMode
        this.defaultEngineMutationApplyGateId =
            defaultEngineMutationApplyGateId
        this.defaultEngineMutationDryRunMode = defaultEngineMutationDryRunMode
        this.defaultEngineMutationDryRunId = defaultEngineMutationDryRunId
        this.defaultEngineMutationCommitPlanId =
            defaultEngineMutationCommitPlanId
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2DefaultEngineMutationApplyGateBridge(
    evidence: JinguiAcceptedTransportH2DefaultEngineMutationApplyGateEvidence
): JinguiAcceptedTransportH2DefaultEngineMutationApplyGateBridge {
    let h2DryRunBridge = evidence.h2DefaultEngineMutationDryRunBridge
    let applyGateReceipt = evidence.defaultEngineMutationApplyGateReceipt
    let nonClaims =
        jinguiAcceptedTransportH2DefaultEngineMutationApplyGateNonClaims()
    if (
        !h2DryRunBridge.h2DefaultEngineMutationDryRunAccepted ||
        !h2DryRunBridge.boundedDefaultEngineMutationDryRunFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2DefaultEngineMutationApplyGateBridge(
            false,
            h2DryRunBridge.h2DefaultEngineMutationDryRunAccepted,
            applyGateReceipt.defaultEngineMutationApplyGateAccepted,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            applyGateReceipt.defaultEngineMutationApplyGateMode,
            applyGateReceipt.defaultEngineMutationApplyGateId,
            h2DryRunBridge.defaultEngineMutationDryRunMode,
            h2DryRunBridge.defaultEngineMutationDryRunId,
            h2DryRunBridge.defaultEngineMutationCommitPlanId,
            "blocked-h2-default-engine-mutation-dry-run-bridge",
            "collect-accepted-h2-default-engine-mutation-dry-run-before-default-engine-mutation-apply-gate",
            jinguiAcceptedTransportH2DefaultEngineMutationApplyGateDryRunBlockers(
                h2DryRunBridge
            ),
            nonClaims,
            "repair H2 default-engine mutation dry-run bridge before default-engine mutation apply-gate; do not treat generic apply-gate receipts as H2 runtime mutation",
            "QUIC must pass stream default mutation dry-run before default stream mutation apply gate"
        )
    }
    if (
        !applyGateReceipt.defaultEngineMutationApplyGateAccepted ||
        !applyGateReceipt.defaultEngineMutationApplyGateAllowed
    ) {
        return JinguiAcceptedTransportH2DefaultEngineMutationApplyGateBridge(
            false,
            true,
            applyGateReceipt.defaultEngineMutationApplyGateAccepted,
            applyGateReceipt.defaultEngineMutationApplyGateAllowed,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            applyGateReceipt.defaultEngineMutationApplyGateMode,
            applyGateReceipt.defaultEngineMutationApplyGateId,
            applyGateReceipt.defaultEngineMutationDryRunMode,
            applyGateReceipt.defaultEngineMutationDryRunId,
            applyGateReceipt.defaultEngineMutationCommitPlanId,
            "blocked-default-engine-mutation-apply-gate-receipt",
            "collect-accepted-default-engine-mutation-apply-gate-before-controlled-default-engine-mutation-apply",
            jinguiAcceptedTransportH2DefaultEngineMutationApplyGateReceiptBlockers(
                applyGateReceipt
            ),
            nonClaims,
            applyGateReceipt.nextAction,
            "QUIC must not consume rejected default-engine mutation apply-gate receipts for stream default mutation"
        )
    }

    JinguiAcceptedTransportH2DefaultEngineMutationApplyGateBridge(
        true,
        true,
        true,
        applyGateReceipt.defaultEngineMutationApplyGateAllowed,
        true,
        applyGateReceipt.productionQueueMutationAllowed,
        applyGateReceipt.actualRuntimeTaskSpawnAllowed,
        applyGateReceipt.actualHandlerInvocationAllowed,
        applyGateReceipt.actualRequestContextMutationAllowed,
        applyGateReceipt.actualResponseWriteAllowed,
        applyGateReceipt.actualTransportCommitAllowed,
        applyGateReceipt.actualLiveServerWiringAllowed,
        applyGateReceipt.actualDefaultEngineFlipAllowed,
        applyGateReceipt.defaultEngineConfigMutationAllowed,
        applyGateReceipt.runtimeDefaultPathMutationAllowed,
        applyGateReceipt.publicReleaseAllowed,
        applyGateReceipt.stdxRemovalAllowed,
        false,
        applyGateReceipt.defaultEngineMutationApplyGateMode,
        applyGateReceipt.defaultEngineMutationApplyGateId,
        applyGateReceipt.defaultEngineMutationDryRunMode,
        applyGateReceipt.defaultEngineMutationDryRunId,
        applyGateReceipt.defaultEngineMutationCommitPlanId,
        "accepted-h2-default-engine-mutation-apply-gate-bridge",
        "record-h2-default-engine-mutation-apply-gate-without-default-engine-mutation",
        [],
        nonClaims,
        "next packet may prove controlled H2 default-engine mutation apply; actual default flip, config mutation, runtime default-path mutation, release, stdx removal, and H2 closure remain denied",
        "QUIC can reuse H2-style dry-run plus generic apply-gate separation before controlled runtime default mutation"
    )
}

func jinguiAcceptedTransportH2DefaultEngineMutationApplyGateDryRunBlockers(
    bridge: JinguiAcceptedTransportH2DefaultEngineMutationDryRunBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("H2_DEFAULT_ENGINE_MUTATION_DRY_RUN:${bridge.status}")
    for (blocker in bridge.blockers) {
        blockers.add("H2_DEFAULT_ENGINE_MUTATION_DRY_RUN_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2DefaultEngineMutationApplyGateReceiptBlockers(
    receipt: IgniteDefaultEngineMutationApplyGateReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("DEFAULT_ENGINE_MUTATION_APPLY_GATE:${receipt.status}")
    for (blocker in receipt.blockers) {
        blockers.add("DEFAULT_ENGINE_MUTATION_APPLY_GATE_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2DefaultEngineMutationApplyGateNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_ACTUAL_LIVE_SERVER_WIRING",
        "NO_ACTUAL_RESPONSE_WRITE",
        "NO_ACTUAL_TRANSPORT_COMMIT",
        "NO_ACTUAL_REQUEST_CONTEXT_MUTATION",
        "NO_ACTUAL_HANDLER_INVOCATION",
        "NO_ACTUAL_RUNTIME_TASK_SPAWN",
        "NO_PRODUCTION_QUEUE_MUTATION",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2ControlledDefaultEngineMutationApplyEvidence {
    public let h2DefaultEngineMutationApplyGateBridge:
        JinguiAcceptedTransportH2DefaultEngineMutationApplyGateBridge
    public let controlledDefaultEngineMutationApplyReceipt:
        IgniteControlledDefaultEngineMutationApplyReceipt

    public init(
        h2DefaultEngineMutationApplyGateBridge:
            JinguiAcceptedTransportH2DefaultEngineMutationApplyGateBridge,
        controlledDefaultEngineMutationApplyReceipt:
            IgniteControlledDefaultEngineMutationApplyReceipt
    ) {
        this.h2DefaultEngineMutationApplyGateBridge =
            h2DefaultEngineMutationApplyGateBridge
        this.controlledDefaultEngineMutationApplyReceipt =
            controlledDefaultEngineMutationApplyReceipt
    }
}

public class JinguiAcceptedTransportH2ControlledDefaultEngineMutationApplyBridge {
    public let h2ControlledDefaultEngineMutationApplyAccepted: Bool
    public let h2DefaultEngineMutationApplyGateAccepted: Bool
    public let controlledDefaultEngineMutationApplyAccepted: Bool
    public let controlledDefaultEngineMutationApplyAllowed: Bool
    public let boundedControlledDefaultEngineMutationApplyFollowupAllowed: Bool
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
    public let h2RuntimeClosureClaimAllowed: Bool
    public let controlledDefaultEngineMutationApplyMode: String
    public let controlledDefaultEngineMutationApplyId: String
    public let defaultEngineMutationApplyGateMode: String
    public let defaultEngineMutationApplyGateId: String
    public let defaultEngineMutationDryRunId: String
    public let defaultEngineMutationCommitPlanId: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2ControlledDefaultEngineMutationApplyAccepted: Bool,
        h2DefaultEngineMutationApplyGateAccepted: Bool,
        controlledDefaultEngineMutationApplyAccepted: Bool,
        controlledDefaultEngineMutationApplyAllowed: Bool,
        boundedControlledDefaultEngineMutationApplyFollowupAllowed: Bool,
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
        h2RuntimeClosureClaimAllowed: Bool,
        controlledDefaultEngineMutationApplyMode: String,
        controlledDefaultEngineMutationApplyId: String,
        defaultEngineMutationApplyGateMode: String,
        defaultEngineMutationApplyGateId: String,
        defaultEngineMutationDryRunId: String,
        defaultEngineMutationCommitPlanId: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2ControlledDefaultEngineMutationApplyAccepted =
            h2ControlledDefaultEngineMutationApplyAccepted
        this.h2DefaultEngineMutationApplyGateAccepted =
            h2DefaultEngineMutationApplyGateAccepted
        this.controlledDefaultEngineMutationApplyAccepted =
            controlledDefaultEngineMutationApplyAccepted
        this.controlledDefaultEngineMutationApplyAllowed =
            controlledDefaultEngineMutationApplyAllowed
        this.boundedControlledDefaultEngineMutationApplyFollowupAllowed =
            boundedControlledDefaultEngineMutationApplyFollowupAllowed
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
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.controlledDefaultEngineMutationApplyMode =
            controlledDefaultEngineMutationApplyMode
        this.controlledDefaultEngineMutationApplyId =
            controlledDefaultEngineMutationApplyId
        this.defaultEngineMutationApplyGateMode =
            defaultEngineMutationApplyGateMode
        this.defaultEngineMutationApplyGateId =
            defaultEngineMutationApplyGateId
        this.defaultEngineMutationDryRunId = defaultEngineMutationDryRunId
        this.defaultEngineMutationCommitPlanId =
            defaultEngineMutationCommitPlanId
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2ControlledDefaultEngineMutationApplyBridge(
    evidence: JinguiAcceptedTransportH2ControlledDefaultEngineMutationApplyEvidence
): JinguiAcceptedTransportH2ControlledDefaultEngineMutationApplyBridge {
    let h2ApplyGateBridge = evidence.h2DefaultEngineMutationApplyGateBridge
    let controlledApplyReceipt =
        evidence.controlledDefaultEngineMutationApplyReceipt
    let nonClaims =
        jinguiAcceptedTransportH2ControlledDefaultEngineMutationApplyNonClaims()
    if (
        !h2ApplyGateBridge.h2DefaultEngineMutationApplyGateAccepted ||
        !h2ApplyGateBridge.boundedDefaultEngineMutationApplyGateFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2ControlledDefaultEngineMutationApplyBridge(
            false,
            h2ApplyGateBridge.h2DefaultEngineMutationApplyGateAccepted,
            controlledApplyReceipt.controlledDefaultEngineMutationApplyAccepted,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            controlledApplyReceipt.controlledDefaultEngineMutationApplyMode,
            controlledApplyReceipt.controlledDefaultEngineMutationApplyId,
            h2ApplyGateBridge.defaultEngineMutationApplyGateMode,
            h2ApplyGateBridge.defaultEngineMutationApplyGateId,
            h2ApplyGateBridge.defaultEngineMutationDryRunId,
            h2ApplyGateBridge.defaultEngineMutationCommitPlanId,
            "blocked-h2-default-engine-mutation-apply-gate-bridge",
            "collect-accepted-h2-default-engine-mutation-apply-gate-before-controlled-default-engine-mutation-apply",
            jinguiAcceptedTransportH2ControlledDefaultEngineMutationApplyGateBlockers(
                h2ApplyGateBridge
            ),
            nonClaims,
            "repair H2 default-engine mutation apply-gate bridge before controlled default-engine mutation apply; do not treat generic controlled-apply receipts as H2 runtime mutation",
            "QUIC must pass stream default mutation apply-gate before controlled stream default mutation apply"
        )
    }
    if (
        !controlledApplyReceipt.controlledDefaultEngineMutationApplyAccepted ||
        !controlledApplyReceipt.controlledDefaultEngineMutationApplyAllowed
    ) {
        return JinguiAcceptedTransportH2ControlledDefaultEngineMutationApplyBridge(
            false,
            true,
            controlledApplyReceipt.controlledDefaultEngineMutationApplyAccepted,
            controlledApplyReceipt.controlledDefaultEngineMutationApplyAllowed,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            controlledApplyReceipt.controlledDefaultEngineMutationApplyMode,
            controlledApplyReceipt.controlledDefaultEngineMutationApplyId,
            controlledApplyReceipt.defaultEngineMutationApplyGateMode,
            controlledApplyReceipt.defaultEngineMutationApplyGateId,
            controlledApplyReceipt.defaultEngineMutationDryRunId,
            controlledApplyReceipt.defaultEngineMutationCommitPlanId,
            "blocked-controlled-default-engine-mutation-apply-receipt",
            "collect-accepted-controlled-default-engine-mutation-apply-before-runtime-default-path-mutation-gate",
            jinguiAcceptedTransportH2ControlledDefaultEngineMutationApplyReceiptBlockers(
                controlledApplyReceipt
            ),
            nonClaims,
            controlledApplyReceipt.nextAction,
            "QUIC must not consume rejected controlled default-engine mutation apply receipts for stream default mutation"
        )
    }

    JinguiAcceptedTransportH2ControlledDefaultEngineMutationApplyBridge(
        true,
        true,
        true,
        controlledApplyReceipt.controlledDefaultEngineMutationApplyAllowed,
        true,
        controlledApplyReceipt.productionQueueMutationAllowed,
        controlledApplyReceipt.actualRuntimeTaskSpawnAllowed,
        controlledApplyReceipt.actualHandlerInvocationAllowed,
        controlledApplyReceipt.actualRequestContextMutationAllowed,
        controlledApplyReceipt.actualResponseWriteAllowed,
        controlledApplyReceipt.actualTransportCommitAllowed,
        controlledApplyReceipt.actualLiveServerWiringAllowed,
        controlledApplyReceipt.actualDefaultEngineFlipAllowed,
        controlledApplyReceipt.defaultEngineConfigMutationAllowed,
        controlledApplyReceipt.runtimeDefaultPathMutationAllowed,
        controlledApplyReceipt.publicReleaseAllowed,
        controlledApplyReceipt.stdxRemovalAllowed,
        false,
        controlledApplyReceipt.controlledDefaultEngineMutationApplyMode,
        controlledApplyReceipt.controlledDefaultEngineMutationApplyId,
        controlledApplyReceipt.defaultEngineMutationApplyGateMode,
        controlledApplyReceipt.defaultEngineMutationApplyGateId,
        controlledApplyReceipt.defaultEngineMutationDryRunId,
        controlledApplyReceipt.defaultEngineMutationCommitPlanId,
        "accepted-h2-controlled-default-engine-mutation-apply-bridge",
        "record-h2-controlled-default-engine-mutation-apply-without-runtime-default-mutation",
        [],
        nonClaims,
        "next packet may gate H2 runtime default-path mutation; actual runtime default-path mutation, release, stdx removal, and H2 closure remain denied",
        "QUIC can reuse H2-style apply-gate plus generic controlled-apply separation before runtime default mutation gate"
    )
}

func jinguiAcceptedTransportH2ControlledDefaultEngineMutationApplyGateBlockers(
    bridge: JinguiAcceptedTransportH2DefaultEngineMutationApplyGateBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("H2_DEFAULT_ENGINE_MUTATION_APPLY_GATE:${bridge.status}")
    for (blocker in bridge.blockers) {
        blockers.add("H2_DEFAULT_ENGINE_MUTATION_APPLY_GATE_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2ControlledDefaultEngineMutationApplyReceiptBlockers(
    receipt: IgniteControlledDefaultEngineMutationApplyReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("CONTROLLED_DEFAULT_ENGINE_MUTATION_APPLY:${receipt.status}")
    for (blocker in receipt.blockers) {
        blockers.add(
            "CONTROLLED_DEFAULT_ENGINE_MUTATION_APPLY_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2ControlledDefaultEngineMutationApplyNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_ACTUAL_LIVE_SERVER_WIRING",
        "NO_ACTUAL_RESPONSE_WRITE",
        "NO_ACTUAL_TRANSPORT_COMMIT",
        "NO_ACTUAL_REQUEST_CONTEXT_MUTATION",
        "NO_ACTUAL_HANDLER_INVOCATION",
        "NO_ACTUAL_RUNTIME_TASK_SPAWN",
        "NO_PRODUCTION_QUEUE_MUTATION",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationGateEvidence {
    public let h2ControlledDefaultEngineMutationApplyBridge:
        JinguiAcceptedTransportH2ControlledDefaultEngineMutationApplyBridge
    public let runtimeDefaultPathMutationGateReceipt:
        IgniteRuntimeDefaultPathMutationGateReceipt

    public init(
        h2ControlledDefaultEngineMutationApplyBridge:
            JinguiAcceptedTransportH2ControlledDefaultEngineMutationApplyBridge,
        runtimeDefaultPathMutationGateReceipt:
            IgniteRuntimeDefaultPathMutationGateReceipt
    ) {
        this.h2ControlledDefaultEngineMutationApplyBridge =
            h2ControlledDefaultEngineMutationApplyBridge
        this.runtimeDefaultPathMutationGateReceipt =
            runtimeDefaultPathMutationGateReceipt
    }
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationGateBridge {
    public let h2RuntimeDefaultPathMutationGateAccepted: Bool
    public let h2ControlledDefaultEngineMutationApplyAccepted: Bool
    public let runtimeDefaultPathMutationGateAccepted: Bool
    public let runtimeDefaultPathMutationGateAllowed: Bool
    public let boundedRuntimeDefaultPathMutationGateFollowupAllowed: Bool
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
    public let h2RuntimeClosureClaimAllowed: Bool
    public let runtimeDefaultPathMutationGateMode: String
    public let runtimeDefaultPathMutationGateId: String
    public let controlledDefaultEngineMutationApplyMode: String
    public let controlledDefaultEngineMutationApplyId: String
    public let defaultEngineMutationApplyGateId: String
    public let defaultEngineMutationDryRunId: String
    public let defaultEngineMutationCommitPlanId: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2RuntimeDefaultPathMutationGateAccepted: Bool,
        h2ControlledDefaultEngineMutationApplyAccepted: Bool,
        runtimeDefaultPathMutationGateAccepted: Bool,
        runtimeDefaultPathMutationGateAllowed: Bool,
        boundedRuntimeDefaultPathMutationGateFollowupAllowed: Bool,
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
        h2RuntimeClosureClaimAllowed: Bool,
        runtimeDefaultPathMutationGateMode: String,
        runtimeDefaultPathMutationGateId: String,
        controlledDefaultEngineMutationApplyMode: String,
        controlledDefaultEngineMutationApplyId: String,
        defaultEngineMutationApplyGateId: String,
        defaultEngineMutationDryRunId: String,
        defaultEngineMutationCommitPlanId: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2RuntimeDefaultPathMutationGateAccepted =
            h2RuntimeDefaultPathMutationGateAccepted
        this.h2ControlledDefaultEngineMutationApplyAccepted =
            h2ControlledDefaultEngineMutationApplyAccepted
        this.runtimeDefaultPathMutationGateAccepted =
            runtimeDefaultPathMutationGateAccepted
        this.runtimeDefaultPathMutationGateAllowed =
            runtimeDefaultPathMutationGateAllowed
        this.boundedRuntimeDefaultPathMutationGateFollowupAllowed =
            boundedRuntimeDefaultPathMutationGateFollowupAllowed
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
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.runtimeDefaultPathMutationGateMode =
            runtimeDefaultPathMutationGateMode
        this.runtimeDefaultPathMutationGateId =
            runtimeDefaultPathMutationGateId
        this.controlledDefaultEngineMutationApplyMode =
            controlledDefaultEngineMutationApplyMode
        this.controlledDefaultEngineMutationApplyId =
            controlledDefaultEngineMutationApplyId
        this.defaultEngineMutationApplyGateId =
            defaultEngineMutationApplyGateId
        this.defaultEngineMutationDryRunId = defaultEngineMutationDryRunId
        this.defaultEngineMutationCommitPlanId =
            defaultEngineMutationCommitPlanId
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2RuntimeDefaultPathMutationGateBridge(
    evidence: JinguiAcceptedTransportH2RuntimeDefaultPathMutationGateEvidence
): JinguiAcceptedTransportH2RuntimeDefaultPathMutationGateBridge {
    let h2ControlledApplyBridge =
        evidence.h2ControlledDefaultEngineMutationApplyBridge
    let runtimeGateReceipt = evidence.runtimeDefaultPathMutationGateReceipt
    let nonClaims =
        jinguiAcceptedTransportH2RuntimeDefaultPathMutationGateNonClaims()
    if (
        !h2ControlledApplyBridge.h2ControlledDefaultEngineMutationApplyAccepted ||
        !h2ControlledApplyBridge.boundedControlledDefaultEngineMutationApplyFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationGateBridge(
            false,
            h2ControlledApplyBridge.h2ControlledDefaultEngineMutationApplyAccepted,
            runtimeGateReceipt.runtimeDefaultPathMutationGateAccepted,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            runtimeGateReceipt.runtimeDefaultPathMutationGateMode,
            runtimeGateReceipt.runtimeDefaultPathMutationGateId,
            runtimeGateReceipt.controlledDefaultEngineMutationApplyMode,
            runtimeGateReceipt.controlledDefaultEngineMutationApplyId,
            h2ControlledApplyBridge.defaultEngineMutationApplyGateId,
            h2ControlledApplyBridge.defaultEngineMutationDryRunId,
            h2ControlledApplyBridge.defaultEngineMutationCommitPlanId,
            "blocked-h2-controlled-default-engine-mutation-apply-bridge",
            "collect-accepted-h2-controlled-default-engine-mutation-apply-before-runtime-default-path-mutation-gate",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationGateApplyBlockers(
                h2ControlledApplyBridge
            ),
            nonClaims,
            "repair H2 controlled default-engine mutation apply bridge before runtime default-path mutation gate; do not treat generic gate receipts as H2 runtime mutation",
            "QUIC must pass controlled stream default mutation apply before runtime default-path mutation gate"
        )
    }
    if (
        !runtimeGateReceipt.runtimeDefaultPathMutationGateAccepted ||
        !runtimeGateReceipt.runtimeDefaultPathMutationGateAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationGateBridge(
            false,
            true,
            runtimeGateReceipt.runtimeDefaultPathMutationGateAccepted,
            runtimeGateReceipt.runtimeDefaultPathMutationGateAllowed,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            runtimeGateReceipt.runtimeDefaultPathMutationGateMode,
            runtimeGateReceipt.runtimeDefaultPathMutationGateId,
            runtimeGateReceipt.controlledDefaultEngineMutationApplyMode,
            runtimeGateReceipt.controlledDefaultEngineMutationApplyId,
            runtimeGateReceipt.defaultEngineMutationApplyGateId,
            runtimeGateReceipt.defaultEngineMutationDryRunId,
            runtimeGateReceipt.defaultEngineMutationCommitPlanId,
            "blocked-runtime-default-path-mutation-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-gate-before-runtime-default-path-mutation-dry-run",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationGateReceiptBlockers(
                runtimeGateReceipt
            ),
            nonClaims,
            runtimeGateReceipt.nextAction,
            "QUIC must not consume rejected runtime default-path mutation gate receipts for stream default mutation"
        )
    }

    JinguiAcceptedTransportH2RuntimeDefaultPathMutationGateBridge(
        true,
        true,
        true,
        runtimeGateReceipt.runtimeDefaultPathMutationGateAllowed,
        true,
        runtimeGateReceipt.productionQueueMutationAllowed,
        runtimeGateReceipt.actualRuntimeTaskSpawnAllowed,
        runtimeGateReceipt.actualHandlerInvocationAllowed,
        runtimeGateReceipt.actualRequestContextMutationAllowed,
        runtimeGateReceipt.actualResponseWriteAllowed,
        runtimeGateReceipt.actualTransportCommitAllowed,
        runtimeGateReceipt.actualLiveServerWiringAllowed,
        runtimeGateReceipt.actualDefaultEngineFlipAllowed,
        runtimeGateReceipt.defaultEngineConfigMutationAllowed,
        runtimeGateReceipt.runtimeDefaultPathMutationAllowed,
        runtimeGateReceipt.publicReleaseAllowed,
        runtimeGateReceipt.stdxRemovalAllowed,
        false,
        runtimeGateReceipt.runtimeDefaultPathMutationGateMode,
        runtimeGateReceipt.runtimeDefaultPathMutationGateId,
        runtimeGateReceipt.controlledDefaultEngineMutationApplyMode,
        runtimeGateReceipt.controlledDefaultEngineMutationApplyId,
        runtimeGateReceipt.defaultEngineMutationApplyGateId,
        runtimeGateReceipt.defaultEngineMutationDryRunId,
        runtimeGateReceipt.defaultEngineMutationCommitPlanId,
        "accepted-h2-runtime-default-path-mutation-gate-bridge",
        "record-h2-runtime-default-path-mutation-gate-without-runtime-default-mutation",
        [],
        nonClaims,
        "next packet may prove H2 runtime default-path mutation dry-run; actual runtime default-path mutation, release, stdx removal, and H2 closure remain denied",
        "QUIC can reuse H2-style controlled-apply plus generic runtime default-path mutation gate separation before runtime default mutation"
    )
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationGateApplyBlockers(
    bridge: JinguiAcceptedTransportH2ControlledDefaultEngineMutationApplyBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("H2_CONTROLLED_DEFAULT_ENGINE_MUTATION_APPLY:${bridge.status}")
    for (blocker in bridge.blockers) {
        blockers.add(
            "H2_CONTROLLED_DEFAULT_ENGINE_MUTATION_APPLY_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationGateReceiptBlockers(
    receipt: IgniteRuntimeDefaultPathMutationGateReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_GATE:${receipt.status}")
    for (blocker in receipt.blockers) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_GATE_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationGateNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_ACTUAL_LIVE_SERVER_WIRING",
        "NO_ACTUAL_RESPONSE_WRITE",
        "NO_ACTUAL_TRANSPORT_COMMIT",
        "NO_ACTUAL_REQUEST_CONTEXT_MUTATION",
        "NO_ACTUAL_HANDLER_INVOCATION",
        "NO_ACTUAL_RUNTIME_TASK_SPAWN",
        "NO_PRODUCTION_QUEUE_MUTATION",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationDryRunEvidence {
    public let h2RuntimeDefaultPathMutationGateBridge:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationGateBridge
    public let runtimeDefaultPathMutationDryRunReceipt:
        IgniteRuntimeDefaultPathMutationDryRunReceipt

    public init(
        h2RuntimeDefaultPathMutationGateBridge:
            JinguiAcceptedTransportH2RuntimeDefaultPathMutationGateBridge,
        runtimeDefaultPathMutationDryRunReceipt:
            IgniteRuntimeDefaultPathMutationDryRunReceipt
    ) {
        this.h2RuntimeDefaultPathMutationGateBridge =
            h2RuntimeDefaultPathMutationGateBridge
        this.runtimeDefaultPathMutationDryRunReceipt =
            runtimeDefaultPathMutationDryRunReceipt
    }
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationDryRunBridge {
    public let h2RuntimeDefaultPathMutationDryRunAccepted: Bool
    public let h2RuntimeDefaultPathMutationGateAccepted: Bool
    public let runtimeDefaultPathMutationDryRunAccepted: Bool
    public let runtimeDefaultPathMutationDryRunAllowed: Bool
    public let boundedRuntimeDefaultPathMutationDryRunFollowupAllowed: Bool
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
    public let h2RuntimeClosureClaimAllowed: Bool
    public let runtimeDefaultPathMutationDryRunMode: String
    public let runtimeDefaultPathMutationDryRunId: String
    public let runtimeDefaultPathMutationGateMode: String
    public let runtimeDefaultPathMutationGateId: String
    public let controlledDefaultEngineMutationApplyId: String
    public let defaultEngineMutationApplyGateId: String
    public let defaultEngineMutationDryRunId: String
    public let defaultEngineMutationCommitPlanId: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2RuntimeDefaultPathMutationDryRunAccepted: Bool,
        h2RuntimeDefaultPathMutationGateAccepted: Bool,
        runtimeDefaultPathMutationDryRunAccepted: Bool,
        runtimeDefaultPathMutationDryRunAllowed: Bool,
        boundedRuntimeDefaultPathMutationDryRunFollowupAllowed: Bool,
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
        h2RuntimeClosureClaimAllowed: Bool,
        runtimeDefaultPathMutationDryRunMode: String,
        runtimeDefaultPathMutationDryRunId: String,
        runtimeDefaultPathMutationGateMode: String,
        runtimeDefaultPathMutationGateId: String,
        controlledDefaultEngineMutationApplyId: String,
        defaultEngineMutationApplyGateId: String,
        defaultEngineMutationDryRunId: String,
        defaultEngineMutationCommitPlanId: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2RuntimeDefaultPathMutationDryRunAccepted =
            h2RuntimeDefaultPathMutationDryRunAccepted
        this.h2RuntimeDefaultPathMutationGateAccepted =
            h2RuntimeDefaultPathMutationGateAccepted
        this.runtimeDefaultPathMutationDryRunAccepted =
            runtimeDefaultPathMutationDryRunAccepted
        this.runtimeDefaultPathMutationDryRunAllowed =
            runtimeDefaultPathMutationDryRunAllowed
        this.boundedRuntimeDefaultPathMutationDryRunFollowupAllowed =
            boundedRuntimeDefaultPathMutationDryRunFollowupAllowed
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
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.runtimeDefaultPathMutationDryRunMode =
            runtimeDefaultPathMutationDryRunMode
        this.runtimeDefaultPathMutationDryRunId =
            runtimeDefaultPathMutationDryRunId
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
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2RuntimeDefaultPathMutationDryRunBridge(
    evidence: JinguiAcceptedTransportH2RuntimeDefaultPathMutationDryRunEvidence
): JinguiAcceptedTransportH2RuntimeDefaultPathMutationDryRunBridge {
    let h2RuntimeGateBridge =
        evidence.h2RuntimeDefaultPathMutationGateBridge
    let runtimeDryRunReceipt = evidence.runtimeDefaultPathMutationDryRunReceipt
    let nonClaims =
        jinguiAcceptedTransportH2RuntimeDefaultPathMutationDryRunNonClaims()
    if (
        !h2RuntimeGateBridge.h2RuntimeDefaultPathMutationGateAccepted ||
        !h2RuntimeGateBridge.boundedRuntimeDefaultPathMutationGateFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationDryRunBridge(
            false,
            h2RuntimeGateBridge.h2RuntimeDefaultPathMutationGateAccepted,
            runtimeDryRunReceipt.runtimeDefaultPathMutationDryRunAccepted,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            runtimeDryRunReceipt.runtimeDefaultPathMutationDryRunMode,
            runtimeDryRunReceipt.runtimeDefaultPathMutationDryRunId,
            runtimeDryRunReceipt.runtimeDefaultPathMutationGateMode,
            runtimeDryRunReceipt.runtimeDefaultPathMutationGateId,
            h2RuntimeGateBridge.controlledDefaultEngineMutationApplyId,
            h2RuntimeGateBridge.defaultEngineMutationApplyGateId,
            h2RuntimeGateBridge.defaultEngineMutationDryRunId,
            h2RuntimeGateBridge.defaultEngineMutationCommitPlanId,
            "blocked-h2-runtime-default-path-mutation-gate-bridge",
            "collect-accepted-h2-runtime-default-path-mutation-gate-before-runtime-default-path-mutation-dry-run",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationDryRunGateBlockers(
                h2RuntimeGateBridge
            ),
            nonClaims,
            "repair H2 runtime default-path mutation gate bridge before dry-run; do not treat generic dry-run receipts as H2 runtime mutation",
            "QUIC must pass runtime default-path mutation gate before stream default mutation dry-run"
        )
    }
    if (
        !runtimeDryRunReceipt.runtimeDefaultPathMutationDryRunAccepted ||
        !runtimeDryRunReceipt.runtimeDefaultPathMutationDryRunAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationDryRunBridge(
            false,
            true,
            runtimeDryRunReceipt.runtimeDefaultPathMutationDryRunAccepted,
            runtimeDryRunReceipt.runtimeDefaultPathMutationDryRunAllowed,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            runtimeDryRunReceipt.runtimeDefaultPathMutationDryRunMode,
            runtimeDryRunReceipt.runtimeDefaultPathMutationDryRunId,
            runtimeDryRunReceipt.runtimeDefaultPathMutationGateMode,
            runtimeDryRunReceipt.runtimeDefaultPathMutationGateId,
            runtimeDryRunReceipt.controlledDefaultEngineMutationApplyId,
            runtimeDryRunReceipt.defaultEngineMutationApplyGateId,
            runtimeDryRunReceipt.defaultEngineMutationDryRunId,
            runtimeDryRunReceipt.defaultEngineMutationCommitPlanId,
            "blocked-runtime-default-path-mutation-dry-run-receipt",
            "collect-accepted-runtime-default-path-mutation-dry-run-before-runtime-default-path-mutation-apply-gate",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationDryRunReceiptBlockers(
                runtimeDryRunReceipt
            ),
            nonClaims,
            runtimeDryRunReceipt.nextAction,
            "QUIC must not consume rejected runtime default-path mutation dry-run receipts for stream default mutation"
        )
    }

    JinguiAcceptedTransportH2RuntimeDefaultPathMutationDryRunBridge(
        true,
        true,
        true,
        runtimeDryRunReceipt.runtimeDefaultPathMutationDryRunAllowed,
        true,
        runtimeDryRunReceipt.productionQueueMutationAllowed,
        runtimeDryRunReceipt.actualRuntimeTaskSpawnAllowed,
        runtimeDryRunReceipt.actualHandlerInvocationAllowed,
        runtimeDryRunReceipt.actualRequestContextMutationAllowed,
        runtimeDryRunReceipt.actualResponseWriteAllowed,
        runtimeDryRunReceipt.actualTransportCommitAllowed,
        runtimeDryRunReceipt.actualLiveServerWiringAllowed,
        runtimeDryRunReceipt.actualDefaultEngineFlipAllowed,
        runtimeDryRunReceipt.defaultEngineConfigMutationAllowed,
        runtimeDryRunReceipt.runtimeDefaultPathMutationAllowed,
        runtimeDryRunReceipt.publicReleaseAllowed,
        runtimeDryRunReceipt.stdxRemovalAllowed,
        false,
        runtimeDryRunReceipt.runtimeDefaultPathMutationDryRunMode,
        runtimeDryRunReceipt.runtimeDefaultPathMutationDryRunId,
        runtimeDryRunReceipt.runtimeDefaultPathMutationGateMode,
        runtimeDryRunReceipt.runtimeDefaultPathMutationGateId,
        runtimeDryRunReceipt.controlledDefaultEngineMutationApplyId,
        runtimeDryRunReceipt.defaultEngineMutationApplyGateId,
        runtimeDryRunReceipt.defaultEngineMutationDryRunId,
        runtimeDryRunReceipt.defaultEngineMutationCommitPlanId,
        "accepted-h2-runtime-default-path-mutation-dry-run-bridge",
        "record-h2-runtime-default-path-mutation-dry-run-without-runtime-default-mutation",
        [],
        nonClaims,
        "next packet may prove H2 runtime default-path mutation apply-gate; actual runtime default-path mutation, release, stdx removal, and H2 closure remain denied",
        "QUIC can reuse H2-style runtime gate plus generic dry-run separation before runtime default mutation"
    )
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationDryRunGateBlockers(
    bridge: JinguiAcceptedTransportH2RuntimeDefaultPathMutationGateBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("H2_RUNTIME_DEFAULT_PATH_MUTATION_GATE:${bridge.status}")
    for (blocker in bridge.blockers) {
        blockers.add("H2_RUNTIME_DEFAULT_PATH_MUTATION_GATE_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationDryRunReceiptBlockers(
    receipt: IgniteRuntimeDefaultPathMutationDryRunReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_DRY_RUN:${receipt.status}")
    for (blocker in receipt.blockers) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_DRY_RUN_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationDryRunNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_GATE",
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_ACTUAL_LIVE_SERVER_WIRING",
        "NO_ACTUAL_RESPONSE_WRITE",
        "NO_ACTUAL_TRANSPORT_COMMIT",
        "NO_ACTUAL_REQUEST_CONTEXT_MUTATION",
        "NO_ACTUAL_HANDLER_INVOCATION",
        "NO_ACTUAL_RUNTIME_TASK_SPAWN",
        "NO_PRODUCTION_QUEUE_MUTATION",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyGateEvidence {
    public let h2RuntimeDefaultPathMutationDryRunBridge:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationDryRunBridge
    public let runtimeDefaultPathMutationApplyGateReceipt:
        IgniteRuntimeDefaultPathMutationApplyGateReceipt

    public init(
        h2RuntimeDefaultPathMutationDryRunBridge:
            JinguiAcceptedTransportH2RuntimeDefaultPathMutationDryRunBridge,
        runtimeDefaultPathMutationApplyGateReceipt:
            IgniteRuntimeDefaultPathMutationApplyGateReceipt
    ) {
        this.h2RuntimeDefaultPathMutationDryRunBridge =
            h2RuntimeDefaultPathMutationDryRunBridge
        this.runtimeDefaultPathMutationApplyGateReceipt =
            runtimeDefaultPathMutationApplyGateReceipt
    }
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyGateBridge {
    public let h2RuntimeDefaultPathMutationApplyGateAccepted: Bool
    public let h2RuntimeDefaultPathMutationDryRunAccepted: Bool
    public let runtimeDefaultPathMutationApplyGateAccepted: Bool
    public let runtimeDefaultPathMutationApplyGateAllowed: Bool
    public let boundedRuntimeDefaultPathMutationApplyGateFollowupAllowed: Bool
    public let runtimeDefaultPathMutationApplyGateMode: String
    public let runtimeDefaultPathMutationApplyGateId: String
    public let runtimeDefaultPathMutationDryRunMode: String
    public let runtimeDefaultPathMutationDryRunId: String
    public let runtimeDefaultPathMutationGateId: String
    public let actualDefaultEngineFlipAllowed: Bool
    public let defaultEngineConfigMutationAllowed: Bool
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2RuntimeDefaultPathMutationApplyGateAccepted: Bool,
        h2RuntimeDefaultPathMutationDryRunAccepted: Bool,
        runtimeDefaultPathMutationApplyGateAccepted: Bool,
        runtimeDefaultPathMutationApplyGateAllowed: Bool,
        boundedRuntimeDefaultPathMutationApplyGateFollowupAllowed: Bool,
        runtimeDefaultPathMutationApplyGateMode: String,
        runtimeDefaultPathMutationApplyGateId: String,
        runtimeDefaultPathMutationDryRunMode: String,
        runtimeDefaultPathMutationDryRunId: String,
        runtimeDefaultPathMutationGateId: String,
        actualDefaultEngineFlipAllowed: Bool,
        defaultEngineConfigMutationAllowed: Bool,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2RuntimeDefaultPathMutationApplyGateAccepted =
            h2RuntimeDefaultPathMutationApplyGateAccepted
        this.h2RuntimeDefaultPathMutationDryRunAccepted =
            h2RuntimeDefaultPathMutationDryRunAccepted
        this.runtimeDefaultPathMutationApplyGateAccepted =
            runtimeDefaultPathMutationApplyGateAccepted
        this.runtimeDefaultPathMutationApplyGateAllowed =
            runtimeDefaultPathMutationApplyGateAllowed
        this.boundedRuntimeDefaultPathMutationApplyGateFollowupAllowed =
            boundedRuntimeDefaultPathMutationApplyGateFollowupAllowed
        this.runtimeDefaultPathMutationApplyGateMode =
            runtimeDefaultPathMutationApplyGateMode
        this.runtimeDefaultPathMutationApplyGateId =
            runtimeDefaultPathMutationApplyGateId
        this.runtimeDefaultPathMutationDryRunMode =
            runtimeDefaultPathMutationDryRunMode
        this.runtimeDefaultPathMutationDryRunId =
            runtimeDefaultPathMutationDryRunId
        this.runtimeDefaultPathMutationGateId =
            runtimeDefaultPathMutationGateId
        this.actualDefaultEngineFlipAllowed = actualDefaultEngineFlipAllowed
        this.defaultEngineConfigMutationAllowed =
            defaultEngineConfigMutationAllowed
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyGateBridge(
    evidence: JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyGateEvidence
): JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyGateBridge {
    let h2DryRunBridge = evidence.h2RuntimeDefaultPathMutationDryRunBridge
    let applyGateReceipt = evidence.runtimeDefaultPathMutationApplyGateReceipt
    let nonClaims =
        jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyGateNonClaims()
    if (
        !h2DryRunBridge.h2RuntimeDefaultPathMutationDryRunAccepted ||
        !h2DryRunBridge.boundedRuntimeDefaultPathMutationDryRunFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyGateBridge(
            false,
            h2DryRunBridge.h2RuntimeDefaultPathMutationDryRunAccepted,
            applyGateReceipt.runtimeDefaultPathMutationApplyGateAccepted,
            false,
            false,
            applyGateReceipt.runtimeDefaultPathMutationApplyGateMode,
            applyGateReceipt.runtimeDefaultPathMutationApplyGateId,
            applyGateReceipt.runtimeDefaultPathMutationDryRunMode,
            applyGateReceipt.runtimeDefaultPathMutationDryRunId,
            applyGateReceipt.runtimeDefaultPathMutationGateId,
            false,
            false,
            false,
            false,
            false,
            false,
            "blocked-h2-runtime-default-path-mutation-dry-run-bridge",
            "collect-accepted-h2-runtime-default-path-mutation-dry-run-before-runtime-default-path-mutation-apply-gate",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyGateDryRunBlockers(
                h2DryRunBridge
            ),
            nonClaims,
            "repair H2 runtime default-path mutation dry-run bridge before apply-gate; do not treat generic apply-gate receipts as H2 runtime mutation",
            "QUIC must pass runtime default-path mutation dry-run before stream default mutation apply-gate"
        )
    }
    if (
        !applyGateReceipt.runtimeDefaultPathMutationApplyGateAccepted ||
        !applyGateReceipt.runtimeDefaultPathMutationApplyGateAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyGateBridge(
            false,
            true,
            applyGateReceipt.runtimeDefaultPathMutationApplyGateAccepted,
            applyGateReceipt.runtimeDefaultPathMutationApplyGateAllowed,
            false,
            applyGateReceipt.runtimeDefaultPathMutationApplyGateMode,
            applyGateReceipt.runtimeDefaultPathMutationApplyGateId,
            applyGateReceipt.runtimeDefaultPathMutationDryRunMode,
            applyGateReceipt.runtimeDefaultPathMutationDryRunId,
            applyGateReceipt.runtimeDefaultPathMutationGateId,
            false,
            false,
            false,
            false,
            false,
            false,
            "blocked-runtime-default-path-mutation-apply-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-apply-gate-before-controlled-runtime-default-path-mutation-apply",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyGateReceiptBlockers(
                applyGateReceipt
            ),
            nonClaims,
            applyGateReceipt.nextAction,
            "QUIC must not consume rejected runtime default-path mutation apply-gate receipts for stream default mutation"
        )
    }

    JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyGateBridge(
        true,
        true,
        true,
        applyGateReceipt.runtimeDefaultPathMutationApplyGateAllowed,
        true,
        applyGateReceipt.runtimeDefaultPathMutationApplyGateMode,
        applyGateReceipt.runtimeDefaultPathMutationApplyGateId,
        applyGateReceipt.runtimeDefaultPathMutationDryRunMode,
        applyGateReceipt.runtimeDefaultPathMutationDryRunId,
        applyGateReceipt.runtimeDefaultPathMutationGateId,
        applyGateReceipt.actualDefaultEngineFlipAllowed,
        applyGateReceipt.defaultEngineConfigMutationAllowed,
        applyGateReceipt.runtimeDefaultPathMutationAllowed,
        applyGateReceipt.publicReleaseAllowed,
        applyGateReceipt.stdxRemovalAllowed,
        false,
        "accepted-h2-runtime-default-path-mutation-apply-gate-bridge",
        "record-h2-runtime-default-path-mutation-apply-gate-without-runtime-default-mutation",
        [],
        nonClaims,
        "next packet may prove H2 controlled runtime default-path mutation apply; actual runtime default-path mutation, release, stdx removal, and H2 closure remain denied",
        "QUIC can reuse H2-style dry-run plus generic apply-gate separation before runtime default mutation"
    )
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyGateDryRunBlockers(
    bridge: JinguiAcceptedTransportH2RuntimeDefaultPathMutationDryRunBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("H2_RUNTIME_DEFAULT_PATH_MUTATION_DRY_RUN:${bridge.status}")
    for (blocker in bridge.blockers) {
        blockers.add("H2_RUNTIME_DEFAULT_PATH_MUTATION_DRY_RUN_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyGateReceiptBlockers(
    receipt: IgniteRuntimeDefaultPathMutationApplyGateReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_APPLY_GATE:${receipt.status}")
    for (blocker in receipt.blockers) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_APPLY_GATE_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyGateNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY",
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyEvidence {
    public let h2RuntimeDefaultPathMutationApplyGateBridge:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyGateBridge
    public let controlledRuntimeDefaultPathMutationApplyReceipt:
        IgniteControlledRuntimeDefaultPathMutationApplyReceipt

    public init(
        h2RuntimeDefaultPathMutationApplyGateBridge:
            JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyGateBridge,
        controlledRuntimeDefaultPathMutationApplyReceipt:
            IgniteControlledRuntimeDefaultPathMutationApplyReceipt
    ) {
        this.h2RuntimeDefaultPathMutationApplyGateBridge =
            h2RuntimeDefaultPathMutationApplyGateBridge
        this.controlledRuntimeDefaultPathMutationApplyReceipt =
            controlledRuntimeDefaultPathMutationApplyReceipt
    }
}

public class JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyBridge {
    public let h2ControlledRuntimeDefaultPathMutationApplyAccepted: Bool
    public let h2RuntimeDefaultPathMutationApplyGateAccepted: Bool
    public let controlledRuntimeDefaultPathMutationApplyAccepted: Bool
    public let controlledRuntimeDefaultPathMutationApplyAllowed: Bool
    public let boundedControlledRuntimeDefaultPathMutationApplyFollowupAllowed: Bool
    public let controlledRuntimeDefaultPathMutationApplyMode: String
    public let controlledRuntimeDefaultPathMutationApplyId: String
    public let runtimeDefaultPathMutationApplyGateMode: String
    public let runtimeDefaultPathMutationApplyGateId: String
    public let runtimeDefaultPathMutationDryRunId: String
    public let runtimeDefaultPathMutationGateId: String
    public let actualDefaultEngineFlipAllowed: Bool
    public let defaultEngineConfigMutationAllowed: Bool
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2ControlledRuntimeDefaultPathMutationApplyAccepted: Bool,
        h2RuntimeDefaultPathMutationApplyGateAccepted: Bool,
        controlledRuntimeDefaultPathMutationApplyAccepted: Bool,
        controlledRuntimeDefaultPathMutationApplyAllowed: Bool,
        boundedControlledRuntimeDefaultPathMutationApplyFollowupAllowed: Bool,
        controlledRuntimeDefaultPathMutationApplyMode: String,
        controlledRuntimeDefaultPathMutationApplyId: String,
        runtimeDefaultPathMutationApplyGateMode: String,
        runtimeDefaultPathMutationApplyGateId: String,
        runtimeDefaultPathMutationDryRunId: String,
        runtimeDefaultPathMutationGateId: String,
        actualDefaultEngineFlipAllowed: Bool,
        defaultEngineConfigMutationAllowed: Bool,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2ControlledRuntimeDefaultPathMutationApplyAccepted =
            h2ControlledRuntimeDefaultPathMutationApplyAccepted
        this.h2RuntimeDefaultPathMutationApplyGateAccepted =
            h2RuntimeDefaultPathMutationApplyGateAccepted
        this.controlledRuntimeDefaultPathMutationApplyAccepted =
            controlledRuntimeDefaultPathMutationApplyAccepted
        this.controlledRuntimeDefaultPathMutationApplyAllowed =
            controlledRuntimeDefaultPathMutationApplyAllowed
        this.boundedControlledRuntimeDefaultPathMutationApplyFollowupAllowed =
            boundedControlledRuntimeDefaultPathMutationApplyFollowupAllowed
        this.controlledRuntimeDefaultPathMutationApplyMode =
            controlledRuntimeDefaultPathMutationApplyMode
        this.controlledRuntimeDefaultPathMutationApplyId =
            controlledRuntimeDefaultPathMutationApplyId
        this.runtimeDefaultPathMutationApplyGateMode =
            runtimeDefaultPathMutationApplyGateMode
        this.runtimeDefaultPathMutationApplyGateId =
            runtimeDefaultPathMutationApplyGateId
        this.runtimeDefaultPathMutationDryRunId =
            runtimeDefaultPathMutationDryRunId
        this.runtimeDefaultPathMutationGateId =
            runtimeDefaultPathMutationGateId
        this.actualDefaultEngineFlipAllowed = actualDefaultEngineFlipAllowed
        this.defaultEngineConfigMutationAllowed =
            defaultEngineConfigMutationAllowed
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyBridge(
    evidence: JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyEvidence
): JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyBridge {
    let h2ApplyGateBridge =
        evidence.h2RuntimeDefaultPathMutationApplyGateBridge
    let controlledApplyReceipt =
        evidence.controlledRuntimeDefaultPathMutationApplyReceipt
    let nonClaims =
        jinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyNonClaims()
    if (
        !h2ApplyGateBridge.h2RuntimeDefaultPathMutationApplyGateAccepted ||
        !h2ApplyGateBridge.boundedRuntimeDefaultPathMutationApplyGateFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyBridge(
            false,
            h2ApplyGateBridge.h2RuntimeDefaultPathMutationApplyGateAccepted,
            controlledApplyReceipt.controlledRuntimeDefaultPathMutationApplyAccepted,
            false,
            false,
            controlledApplyReceipt.controlledRuntimeDefaultPathMutationApplyMode,
            controlledApplyReceipt.controlledRuntimeDefaultPathMutationApplyId,
            controlledApplyReceipt.runtimeDefaultPathMutationApplyGateMode,
            controlledApplyReceipt.runtimeDefaultPathMutationApplyGateId,
            controlledApplyReceipt.runtimeDefaultPathMutationDryRunId,
            controlledApplyReceipt.runtimeDefaultPathMutationGateId,
            false,
            false,
            false,
            false,
            false,
            false,
            "blocked-h2-runtime-default-path-mutation-apply-gate-bridge",
            "collect-accepted-h2-runtime-default-path-mutation-apply-gate-before-controlled-runtime-default-path-mutation-apply",
            jinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyGateBlockers(
                h2ApplyGateBridge
            ),
            nonClaims,
            "repair H2 runtime default-path mutation apply-gate bridge before controlled apply; do not treat generic controlled apply receipts as H2 runtime mutation",
            "QUIC must pass runtime default-path mutation apply-gate before controlled stream default mutation apply"
        )
    }
    if (
        !controlledApplyReceipt.controlledRuntimeDefaultPathMutationApplyAccepted ||
        !controlledApplyReceipt.controlledRuntimeDefaultPathMutationApplyAllowed
    ) {
        return JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyBridge(
            false,
            true,
            controlledApplyReceipt.controlledRuntimeDefaultPathMutationApplyAccepted,
            controlledApplyReceipt.controlledRuntimeDefaultPathMutationApplyAllowed,
            false,
            controlledApplyReceipt.controlledRuntimeDefaultPathMutationApplyMode,
            controlledApplyReceipt.controlledRuntimeDefaultPathMutationApplyId,
            controlledApplyReceipt.runtimeDefaultPathMutationApplyGateMode,
            controlledApplyReceipt.runtimeDefaultPathMutationApplyGateId,
            controlledApplyReceipt.runtimeDefaultPathMutationDryRunId,
            controlledApplyReceipt.runtimeDefaultPathMutationGateId,
            false,
            false,
            false,
            false,
            false,
            false,
            "blocked-controlled-runtime-default-path-mutation-apply-receipt",
            "collect-accepted-controlled-runtime-default-path-mutation-apply-before-runtime-default-path-mutation-commit-plan",
            jinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyReceiptBlockers(
                controlledApplyReceipt
            ),
            nonClaims,
            controlledApplyReceipt.nextAction,
            "QUIC must not consume rejected controlled runtime default-path mutation apply receipts for stream default mutation"
        )
    }

    JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyBridge(
        true,
        true,
        true,
        controlledApplyReceipt.controlledRuntimeDefaultPathMutationApplyAllowed,
        true,
        controlledApplyReceipt.controlledRuntimeDefaultPathMutationApplyMode,
        controlledApplyReceipt.controlledRuntimeDefaultPathMutationApplyId,
        controlledApplyReceipt.runtimeDefaultPathMutationApplyGateMode,
        controlledApplyReceipt.runtimeDefaultPathMutationApplyGateId,
        controlledApplyReceipt.runtimeDefaultPathMutationDryRunId,
        controlledApplyReceipt.runtimeDefaultPathMutationGateId,
        controlledApplyReceipt.actualDefaultEngineFlipAllowed,
        controlledApplyReceipt.defaultEngineConfigMutationAllowed,
        controlledApplyReceipt.runtimeDefaultPathMutationAllowed,
        controlledApplyReceipt.publicReleaseAllowed,
        controlledApplyReceipt.stdxRemovalAllowed,
        false,
        "accepted-h2-controlled-runtime-default-path-mutation-apply-bridge",
        "record-h2-controlled-runtime-default-path-mutation-apply-without-runtime-default-mutation",
        [],
        nonClaims,
        "next packet may prove H2 runtime default-path mutation commit-plan; actual runtime default-path mutation, release, stdx removal, and H2 closure remain denied",
        "QUIC can reuse H2-style apply-gate plus generic controlled-apply separation before runtime default mutation"
    )
}

func jinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyGateBlockers(
    bridge: JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyGateBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("H2_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_GATE:${bridge.status}")
    for (blocker in bridge.blockers) {
        blockers.add(
            "H2_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_GATE_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyReceiptBlockers(
    receipt: IgniteControlledRuntimeDefaultPathMutationApplyReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY:${receipt.status}")
    for (blocker in receipt.blockers) {
        blockers.add(
            "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_PLAN",
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitPlanEvidence {
    public let h2ControlledRuntimeDefaultPathMutationApplyBridge:
        JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyBridge
    public let runtimeDefaultPathMutationCommitPlanReceipt:
        IgniteRuntimeDefaultPathMutationCommitPlanReceipt

    public init(
        h2ControlledRuntimeDefaultPathMutationApplyBridge:
            JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyBridge,
        runtimeDefaultPathMutationCommitPlanReceipt:
            IgniteRuntimeDefaultPathMutationCommitPlanReceipt
    ) {
        this.h2ControlledRuntimeDefaultPathMutationApplyBridge =
            h2ControlledRuntimeDefaultPathMutationApplyBridge
        this.runtimeDefaultPathMutationCommitPlanReceipt =
            runtimeDefaultPathMutationCommitPlanReceipt
    }
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitPlanBridge {
    public let h2RuntimeDefaultPathMutationCommitPlanAccepted: Bool
    public let h2ControlledRuntimeDefaultPathMutationApplyAccepted: Bool
    public let runtimeDefaultPathMutationCommitPlanAccepted: Bool
    public let runtimeDefaultPathMutationCommitPlanAllowed: Bool
    public let boundedRuntimeDefaultPathMutationCommitPlanFollowupAllowed: Bool
    public let runtimeDefaultPathMutationCommitPlanMode: String
    public let runtimeDefaultPathMutationCommitPlanId: String
    public let controlledRuntimeDefaultPathMutationApplyMode: String
    public let controlledRuntimeDefaultPathMutationApplyId: String
    public let runtimeDefaultPathMutationApplyGateId: String
    public let runtimeDefaultPathMutationDryRunId: String
    public let runtimeDefaultPathMutationGateId: String
    public let actualDefaultEngineFlipAllowed: Bool
    public let defaultEngineConfigMutationAllowed: Bool
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2RuntimeDefaultPathMutationCommitPlanAccepted: Bool,
        h2ControlledRuntimeDefaultPathMutationApplyAccepted: Bool,
        runtimeDefaultPathMutationCommitPlanAccepted: Bool,
        runtimeDefaultPathMutationCommitPlanAllowed: Bool,
        boundedRuntimeDefaultPathMutationCommitPlanFollowupAllowed: Bool,
        runtimeDefaultPathMutationCommitPlanMode: String,
        runtimeDefaultPathMutationCommitPlanId: String,
        controlledRuntimeDefaultPathMutationApplyMode: String,
        controlledRuntimeDefaultPathMutationApplyId: String,
        runtimeDefaultPathMutationApplyGateId: String,
        runtimeDefaultPathMutationDryRunId: String,
        runtimeDefaultPathMutationGateId: String,
        actualDefaultEngineFlipAllowed: Bool,
        defaultEngineConfigMutationAllowed: Bool,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2RuntimeDefaultPathMutationCommitPlanAccepted =
            h2RuntimeDefaultPathMutationCommitPlanAccepted
        this.h2ControlledRuntimeDefaultPathMutationApplyAccepted =
            h2ControlledRuntimeDefaultPathMutationApplyAccepted
        this.runtimeDefaultPathMutationCommitPlanAccepted =
            runtimeDefaultPathMutationCommitPlanAccepted
        this.runtimeDefaultPathMutationCommitPlanAllowed =
            runtimeDefaultPathMutationCommitPlanAllowed
        this.boundedRuntimeDefaultPathMutationCommitPlanFollowupAllowed =
            boundedRuntimeDefaultPathMutationCommitPlanFollowupAllowed
        this.runtimeDefaultPathMutationCommitPlanMode =
            runtimeDefaultPathMutationCommitPlanMode
        this.runtimeDefaultPathMutationCommitPlanId =
            runtimeDefaultPathMutationCommitPlanId
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
        this.actualDefaultEngineFlipAllowed = actualDefaultEngineFlipAllowed
        this.defaultEngineConfigMutationAllowed =
            defaultEngineConfigMutationAllowed
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitPlanBridge(
    evidence: JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitPlanEvidence
): JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitPlanBridge {
    let h2ControlledApplyBridge =
        evidence.h2ControlledRuntimeDefaultPathMutationApplyBridge
    let commitPlanReceipt =
        evidence.runtimeDefaultPathMutationCommitPlanReceipt
    let nonClaims =
        jinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitPlanNonClaims()
    if (
        !h2ControlledApplyBridge.h2ControlledRuntimeDefaultPathMutationApplyAccepted ||
        !h2ControlledApplyBridge.boundedControlledRuntimeDefaultPathMutationApplyFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitPlanBridge(
            false,
            h2ControlledApplyBridge.h2ControlledRuntimeDefaultPathMutationApplyAccepted,
            commitPlanReceipt.runtimeDefaultPathMutationCommitPlanAccepted,
            false,
            false,
            commitPlanReceipt.runtimeDefaultPathMutationCommitPlanMode,
            commitPlanReceipt.runtimeDefaultPathMutationCommitPlanId,
            commitPlanReceipt.controlledRuntimeDefaultPathMutationApplyMode,
            commitPlanReceipt.controlledRuntimeDefaultPathMutationApplyId,
            commitPlanReceipt.runtimeDefaultPathMutationApplyGateId,
            commitPlanReceipt.runtimeDefaultPathMutationDryRunId,
            commitPlanReceipt.runtimeDefaultPathMutationGateId,
            false,
            false,
            false,
            false,
            false,
            false,
            "blocked-h2-controlled-runtime-default-path-mutation-apply-bridge",
            "collect-accepted-h2-controlled-runtime-default-path-mutation-apply-before-runtime-default-path-mutation-commit-plan",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitPlanControlledApplyBlockers(
                h2ControlledApplyBridge
            ),
            nonClaims,
            "repair H2 controlled runtime default-path mutation apply bridge before commit-plan; do not treat generic commit-plan receipts as H2 runtime mutation",
            "QUIC must pass controlled stream default mutation apply before runtime default-path mutation commit-plan"
        )
    }
    if (
        !commitPlanReceipt.runtimeDefaultPathMutationCommitPlanAccepted ||
        !commitPlanReceipt.runtimeDefaultPathMutationCommitPlanAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitPlanBridge(
            false,
            true,
            commitPlanReceipt.runtimeDefaultPathMutationCommitPlanAccepted,
            commitPlanReceipt.runtimeDefaultPathMutationCommitPlanAllowed,
            false,
            commitPlanReceipt.runtimeDefaultPathMutationCommitPlanMode,
            commitPlanReceipt.runtimeDefaultPathMutationCommitPlanId,
            commitPlanReceipt.controlledRuntimeDefaultPathMutationApplyMode,
            commitPlanReceipt.controlledRuntimeDefaultPathMutationApplyId,
            commitPlanReceipt.runtimeDefaultPathMutationApplyGateId,
            commitPlanReceipt.runtimeDefaultPathMutationDryRunId,
            commitPlanReceipt.runtimeDefaultPathMutationGateId,
            false,
            false,
            false,
            false,
            false,
            false,
            "blocked-runtime-default-path-mutation-commit-plan-receipt",
            "collect-accepted-runtime-default-path-mutation-commit-plan-before-runtime-default-path-mutation-commit-dry-run",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitPlanReceiptBlockers(
                commitPlanReceipt
            ),
            nonClaims,
            commitPlanReceipt.nextAction,
            "QUIC must not consume rejected runtime default-path mutation commit-plan receipts for stream default mutation"
        )
    }

    JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitPlanBridge(
        true,
        true,
        true,
        commitPlanReceipt.runtimeDefaultPathMutationCommitPlanAllowed,
        true,
        commitPlanReceipt.runtimeDefaultPathMutationCommitPlanMode,
        commitPlanReceipt.runtimeDefaultPathMutationCommitPlanId,
        commitPlanReceipt.controlledRuntimeDefaultPathMutationApplyMode,
        commitPlanReceipt.controlledRuntimeDefaultPathMutationApplyId,
        commitPlanReceipt.runtimeDefaultPathMutationApplyGateId,
        commitPlanReceipt.runtimeDefaultPathMutationDryRunId,
        commitPlanReceipt.runtimeDefaultPathMutationGateId,
        commitPlanReceipt.actualDefaultEngineFlipAllowed,
        commitPlanReceipt.defaultEngineConfigMutationAllowed,
        commitPlanReceipt.runtimeDefaultPathMutationAllowed,
        commitPlanReceipt.publicReleaseAllowed,
        commitPlanReceipt.stdxRemovalAllowed,
        false,
        "accepted-h2-runtime-default-path-mutation-commit-plan-bridge",
        "record-h2-runtime-default-path-mutation-commit-plan-without-runtime-default-mutation",
        [],
        nonClaims,
        "next packet may prove H2 runtime default-path mutation commit-dry-run; actual runtime default-path mutation, release, stdx removal, and H2 closure remain denied",
        "QUIC can reuse H2-style controlled-apply plus generic commit-plan separation before runtime default mutation"
    )
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitPlanControlledApplyBlockers(
    bridge:
        JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("H2_CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY:${bridge.status}")
    for (blocker in bridge.blockers) {
        blockers.add(
            "H2_CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitPlanReceiptBlockers(
    receipt: IgniteRuntimeDefaultPathMutationCommitPlanReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_PLAN:${receipt.status}")
    for (blocker in receipt.blockers) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_PLAN_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitPlanNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_DRY_RUN",
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitDryRunEvidence {
    public let h2RuntimeDefaultPathMutationCommitPlanBridge:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitPlanBridge
    public let runtimeDefaultPathMutationCommitDryRunReceipt:
        IgniteRuntimeDefaultPathMutationCommitDryRunReceipt

    public init(
        h2RuntimeDefaultPathMutationCommitPlanBridge:
            JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitPlanBridge,
        runtimeDefaultPathMutationCommitDryRunReceipt:
            IgniteRuntimeDefaultPathMutationCommitDryRunReceipt
    ) {
        this.h2RuntimeDefaultPathMutationCommitPlanBridge =
            h2RuntimeDefaultPathMutationCommitPlanBridge
        this.runtimeDefaultPathMutationCommitDryRunReceipt =
            runtimeDefaultPathMutationCommitDryRunReceipt
    }
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitDryRunBridge {
    public let h2RuntimeDefaultPathMutationCommitDryRunAccepted: Bool
    public let h2RuntimeDefaultPathMutationCommitPlanAccepted: Bool
    public let runtimeDefaultPathMutationCommitDryRunAccepted: Bool
    public let runtimeDefaultPathMutationCommitDryRunAllowed: Bool
    public let boundedRuntimeDefaultPathMutationCommitDryRunFollowupAllowed: Bool
    public let runtimeDefaultPathMutationCommitDryRunMode: String
    public let runtimeDefaultPathMutationCommitDryRunId: String
    public let runtimeDefaultPathMutationCommitPlanId: String
    public let controlledRuntimeDefaultPathMutationApplyId: String
    public let runtimeDefaultPathMutationApplyGateId: String
    public let runtimeDefaultPathMutationDryRunId: String
    public let runtimeDefaultPathMutationGateId: String
    public let actualDefaultEngineFlipAllowed: Bool
    public let defaultEngineConfigMutationAllowed: Bool
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2RuntimeDefaultPathMutationCommitDryRunAccepted: Bool,
        h2RuntimeDefaultPathMutationCommitPlanAccepted: Bool,
        runtimeDefaultPathMutationCommitDryRunAccepted: Bool,
        runtimeDefaultPathMutationCommitDryRunAllowed: Bool,
        boundedRuntimeDefaultPathMutationCommitDryRunFollowupAllowed: Bool,
        runtimeDefaultPathMutationCommitDryRunMode: String,
        runtimeDefaultPathMutationCommitDryRunId: String,
        runtimeDefaultPathMutationCommitPlanId: String,
        controlledRuntimeDefaultPathMutationApplyId: String,
        runtimeDefaultPathMutationApplyGateId: String,
        runtimeDefaultPathMutationDryRunId: String,
        runtimeDefaultPathMutationGateId: String,
        actualDefaultEngineFlipAllowed: Bool,
        defaultEngineConfigMutationAllowed: Bool,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2RuntimeDefaultPathMutationCommitDryRunAccepted =
            h2RuntimeDefaultPathMutationCommitDryRunAccepted
        this.h2RuntimeDefaultPathMutationCommitPlanAccepted =
            h2RuntimeDefaultPathMutationCommitPlanAccepted
        this.runtimeDefaultPathMutationCommitDryRunAccepted =
            runtimeDefaultPathMutationCommitDryRunAccepted
        this.runtimeDefaultPathMutationCommitDryRunAllowed =
            runtimeDefaultPathMutationCommitDryRunAllowed
        this.boundedRuntimeDefaultPathMutationCommitDryRunFollowupAllowed =
            boundedRuntimeDefaultPathMutationCommitDryRunFollowupAllowed
        this.runtimeDefaultPathMutationCommitDryRunMode =
            runtimeDefaultPathMutationCommitDryRunMode
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
        this.actualDefaultEngineFlipAllowed = actualDefaultEngineFlipAllowed
        this.defaultEngineConfigMutationAllowed =
            defaultEngineConfigMutationAllowed
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitDryRunBridge(
    evidence: JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitDryRunEvidence
): JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitDryRunBridge {
    let h2CommitPlanBridge =
        evidence.h2RuntimeDefaultPathMutationCommitPlanBridge
    let dryRunReceipt =
        evidence.runtimeDefaultPathMutationCommitDryRunReceipt
    let nonClaims =
        jinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitDryRunNonClaims()
    if (
        !h2CommitPlanBridge.h2RuntimeDefaultPathMutationCommitPlanAccepted ||
        !h2CommitPlanBridge.boundedRuntimeDefaultPathMutationCommitPlanFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitDryRunBridge(
            false,
            h2CommitPlanBridge.h2RuntimeDefaultPathMutationCommitPlanAccepted,
            dryRunReceipt.runtimeDefaultPathMutationCommitDryRunAccepted,
            false,
            false,
            dryRunReceipt.runtimeDefaultPathMutationCommitDryRunMode,
            dryRunReceipt.runtimeDefaultPathMutationCommitDryRunId,
            dryRunReceipt.runtimeDefaultPathMutationCommitPlanId,
            dryRunReceipt.controlledRuntimeDefaultPathMutationApplyId,
            dryRunReceipt.runtimeDefaultPathMutationApplyGateId,
            dryRunReceipt.runtimeDefaultPathMutationDryRunId,
            dryRunReceipt.runtimeDefaultPathMutationGateId,
            false,
            false,
            false,
            false,
            false,
            false,
            "blocked-h2-runtime-default-path-mutation-commit-plan-bridge",
            "collect-accepted-h2-runtime-default-path-mutation-commit-plan-before-runtime-default-path-mutation-commit-dry-run",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitDryRunCommitPlanBlockers(
                h2CommitPlanBridge
            ),
            nonClaims,
            "repair H2 runtime default-path mutation commit-plan bridge before commit-dry-run; do not treat generic commit-dry-run receipts as H2 runtime mutation",
            "QUIC must pass stream default mutation commit-plan before runtime default-path mutation commit-dry-run"
        )
    }
    if (
        !dryRunReceipt.runtimeDefaultPathMutationCommitDryRunAccepted ||
        !dryRunReceipt.runtimeDefaultPathMutationCommitDryRunAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitDryRunBridge(
            false,
            true,
            dryRunReceipt.runtimeDefaultPathMutationCommitDryRunAccepted,
            dryRunReceipt.runtimeDefaultPathMutationCommitDryRunAllowed,
            false,
            dryRunReceipt.runtimeDefaultPathMutationCommitDryRunMode,
            dryRunReceipt.runtimeDefaultPathMutationCommitDryRunId,
            dryRunReceipt.runtimeDefaultPathMutationCommitPlanId,
            dryRunReceipt.controlledRuntimeDefaultPathMutationApplyId,
            dryRunReceipt.runtimeDefaultPathMutationApplyGateId,
            dryRunReceipt.runtimeDefaultPathMutationDryRunId,
            dryRunReceipt.runtimeDefaultPathMutationGateId,
            false,
            false,
            false,
            false,
            false,
            false,
            "blocked-runtime-default-path-mutation-commit-dry-run-receipt",
            "collect-accepted-runtime-default-path-mutation-commit-dry-run-before-runtime-default-path-mutation-commit-apply-gate",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitDryRunReceiptBlockers(
                dryRunReceipt
            ),
            nonClaims,
            dryRunReceipt.nextAction,
            "QUIC must not consume rejected runtime default-path mutation commit-dry-run receipts for stream default mutation"
        )
    }

    JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitDryRunBridge(
        true,
        true,
        true,
        dryRunReceipt.runtimeDefaultPathMutationCommitDryRunAllowed,
        true,
        dryRunReceipt.runtimeDefaultPathMutationCommitDryRunMode,
        dryRunReceipt.runtimeDefaultPathMutationCommitDryRunId,
        dryRunReceipt.runtimeDefaultPathMutationCommitPlanId,
        dryRunReceipt.controlledRuntimeDefaultPathMutationApplyId,
        dryRunReceipt.runtimeDefaultPathMutationApplyGateId,
        dryRunReceipt.runtimeDefaultPathMutationDryRunId,
        dryRunReceipt.runtimeDefaultPathMutationGateId,
        dryRunReceipt.actualDefaultEngineFlipAllowed,
        dryRunReceipt.defaultEngineConfigMutationAllowed,
        dryRunReceipt.runtimeDefaultPathMutationAllowed,
        dryRunReceipt.publicReleaseAllowed,
        dryRunReceipt.stdxRemovalAllowed,
        false,
        "accepted-h2-runtime-default-path-mutation-commit-dry-run-bridge",
        "record-h2-runtime-default-path-mutation-commit-dry-run-without-runtime-default-mutation",
        [],
        nonClaims,
        "next packet may prove H2 runtime default-path mutation commit apply-gate; actual runtime default-path mutation, release, stdx removal, and H2 closure remain denied",
        "QUIC can reuse H2-style commit-plan plus generic commit-dry-run separation before runtime default mutation"
    )
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitDryRunCommitPlanBlockers(
    bridge: JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitPlanBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("H2_RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_PLAN:${bridge.status}")
    for (blocker in bridge.blockers) {
        blockers.add(
            "H2_RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_PLAN_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitDryRunReceiptBlockers(
    receipt: IgniteRuntimeDefaultPathMutationCommitDryRunReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_DRY_RUN:${receipt.status}")
    for (blocker in receipt.blockers) {
        blockers.add(
            "RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_DRY_RUN_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitDryRunNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_APPLY_GATE",
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitApplyGateEvidence {
    public let h2RuntimeDefaultPathMutationCommitDryRunBridge:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitDryRunBridge
    public let runtimeDefaultPathMutationCommitApplyGateReceipt:
        IgniteRuntimeDefaultPathMutationCommitApplyGateReceipt

    public init(
        h2RuntimeDefaultPathMutationCommitDryRunBridge:
            JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitDryRunBridge,
        runtimeDefaultPathMutationCommitApplyGateReceipt:
            IgniteRuntimeDefaultPathMutationCommitApplyGateReceipt
    ) {
        this.h2RuntimeDefaultPathMutationCommitDryRunBridge =
            h2RuntimeDefaultPathMutationCommitDryRunBridge
        this.runtimeDefaultPathMutationCommitApplyGateReceipt =
            runtimeDefaultPathMutationCommitApplyGateReceipt
    }
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitApplyGateBridge {
    public let h2RuntimeDefaultPathMutationCommitApplyGateAccepted: Bool
    public let h2RuntimeDefaultPathMutationCommitDryRunAccepted: Bool
    public let runtimeDefaultPathMutationCommitApplyGateAccepted: Bool
    public let runtimeDefaultPathMutationCommitApplyGateAllowed: Bool
    public let boundedRuntimeDefaultPathMutationCommitApplyGateFollowupAllowed: Bool
    public let runtimeDefaultPathMutationCommitApplyGateMode: String
    public let runtimeDefaultPathMutationCommitApplyGateId: String
    public let runtimeDefaultPathMutationCommitDryRunId: String
    public let runtimeDefaultPathMutationCommitPlanId: String
    public let controlledRuntimeDefaultPathMutationApplyId: String
    public let runtimeDefaultPathMutationApplyGateId: String
    public let runtimeDefaultPathMutationDryRunId: String
    public let runtimeDefaultPathMutationGateId: String
    public let actualDefaultEngineFlipAllowed: Bool
    public let defaultEngineConfigMutationAllowed: Bool
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2RuntimeDefaultPathMutationCommitApplyGateAccepted: Bool,
        h2RuntimeDefaultPathMutationCommitDryRunAccepted: Bool,
        runtimeDefaultPathMutationCommitApplyGateAccepted: Bool,
        runtimeDefaultPathMutationCommitApplyGateAllowed: Bool,
        boundedRuntimeDefaultPathMutationCommitApplyGateFollowupAllowed: Bool,
        runtimeDefaultPathMutationCommitApplyGateMode: String,
        runtimeDefaultPathMutationCommitApplyGateId: String,
        runtimeDefaultPathMutationCommitDryRunId: String,
        runtimeDefaultPathMutationCommitPlanId: String,
        controlledRuntimeDefaultPathMutationApplyId: String,
        runtimeDefaultPathMutationApplyGateId: String,
        runtimeDefaultPathMutationDryRunId: String,
        runtimeDefaultPathMutationGateId: String,
        actualDefaultEngineFlipAllowed: Bool,
        defaultEngineConfigMutationAllowed: Bool,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2RuntimeDefaultPathMutationCommitApplyGateAccepted =
            h2RuntimeDefaultPathMutationCommitApplyGateAccepted
        this.h2RuntimeDefaultPathMutationCommitDryRunAccepted =
            h2RuntimeDefaultPathMutationCommitDryRunAccepted
        this.runtimeDefaultPathMutationCommitApplyGateAccepted =
            runtimeDefaultPathMutationCommitApplyGateAccepted
        this.runtimeDefaultPathMutationCommitApplyGateAllowed =
            runtimeDefaultPathMutationCommitApplyGateAllowed
        this.boundedRuntimeDefaultPathMutationCommitApplyGateFollowupAllowed =
            boundedRuntimeDefaultPathMutationCommitApplyGateFollowupAllowed
        this.runtimeDefaultPathMutationCommitApplyGateMode =
            runtimeDefaultPathMutationCommitApplyGateMode
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
        this.actualDefaultEngineFlipAllowed = actualDefaultEngineFlipAllowed
        this.defaultEngineConfigMutationAllowed =
            defaultEngineConfigMutationAllowed
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitApplyGateBridge(
    evidence: JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitApplyGateEvidence
): JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitApplyGateBridge {
    let h2CommitDryRunBridge =
        evidence.h2RuntimeDefaultPathMutationCommitDryRunBridge
    let applyGateReceipt =
        evidence.runtimeDefaultPathMutationCommitApplyGateReceipt
    let nonClaims =
        jinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitApplyGateNonClaims()
    if (
        !h2CommitDryRunBridge.h2RuntimeDefaultPathMutationCommitDryRunAccepted ||
        !h2CommitDryRunBridge.boundedRuntimeDefaultPathMutationCommitDryRunFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitApplyGateBridge(
            false,
            h2CommitDryRunBridge.h2RuntimeDefaultPathMutationCommitDryRunAccepted,
            applyGateReceipt.runtimeDefaultPathMutationCommitApplyGateAccepted,
            false,
            false,
            applyGateReceipt.runtimeDefaultPathMutationCommitApplyGateMode,
            applyGateReceipt.runtimeDefaultPathMutationCommitApplyGateId,
            applyGateReceipt.runtimeDefaultPathMutationCommitDryRunId,
            applyGateReceipt.runtimeDefaultPathMutationCommitPlanId,
            applyGateReceipt.controlledRuntimeDefaultPathMutationApplyId,
            applyGateReceipt.runtimeDefaultPathMutationApplyGateId,
            applyGateReceipt.runtimeDefaultPathMutationDryRunId,
            applyGateReceipt.runtimeDefaultPathMutationGateId,
            false,
            false,
            false,
            false,
            false,
            false,
            "blocked-h2-runtime-default-path-mutation-commit-dry-run-bridge",
            "collect-accepted-h2-runtime-default-path-mutation-commit-dry-run-before-runtime-default-path-mutation-commit-apply-gate",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitApplyGateDryRunBlockers(
                h2CommitDryRunBridge
            ),
            nonClaims,
            "repair H2 runtime default-path mutation commit-dry-run bridge before commit-apply-gate; do not treat generic commit-apply-gate receipts as H2 runtime mutation",
            "QUIC must pass stream default mutation commit-dry-run before runtime default-path mutation commit-apply-gate"
        )
    }
    if (
        !applyGateReceipt.runtimeDefaultPathMutationCommitApplyGateAccepted ||
        !applyGateReceipt.runtimeDefaultPathMutationCommitApplyGateAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitApplyGateBridge(
            false,
            true,
            applyGateReceipt.runtimeDefaultPathMutationCommitApplyGateAccepted,
            applyGateReceipt.runtimeDefaultPathMutationCommitApplyGateAllowed,
            false,
            applyGateReceipt.runtimeDefaultPathMutationCommitApplyGateMode,
            applyGateReceipt.runtimeDefaultPathMutationCommitApplyGateId,
            applyGateReceipt.runtimeDefaultPathMutationCommitDryRunId,
            applyGateReceipt.runtimeDefaultPathMutationCommitPlanId,
            applyGateReceipt.controlledRuntimeDefaultPathMutationApplyId,
            applyGateReceipt.runtimeDefaultPathMutationApplyGateId,
            applyGateReceipt.runtimeDefaultPathMutationDryRunId,
            applyGateReceipt.runtimeDefaultPathMutationGateId,
            false,
            false,
            false,
            false,
            false,
            false,
            "blocked-runtime-default-path-mutation-commit-apply-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-commit-apply-gate-before-controlled-runtime-default-path-mutation-commit-apply",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitApplyGateReceiptBlockers(
                applyGateReceipt
            ),
            nonClaims,
            applyGateReceipt.nextAction,
            "QUIC must not consume rejected runtime default-path mutation commit-apply-gate receipts for stream default mutation"
        )
    }

    JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitApplyGateBridge(
        true,
        true,
        true,
        applyGateReceipt.runtimeDefaultPathMutationCommitApplyGateAllowed,
        true,
        applyGateReceipt.runtimeDefaultPathMutationCommitApplyGateMode,
        applyGateReceipt.runtimeDefaultPathMutationCommitApplyGateId,
        applyGateReceipt.runtimeDefaultPathMutationCommitDryRunId,
        applyGateReceipt.runtimeDefaultPathMutationCommitPlanId,
        applyGateReceipt.controlledRuntimeDefaultPathMutationApplyId,
        applyGateReceipt.runtimeDefaultPathMutationApplyGateId,
        applyGateReceipt.runtimeDefaultPathMutationDryRunId,
        applyGateReceipt.runtimeDefaultPathMutationGateId,
        applyGateReceipt.actualDefaultEngineFlipAllowed,
        applyGateReceipt.defaultEngineConfigMutationAllowed,
        applyGateReceipt.runtimeDefaultPathMutationAllowed,
        applyGateReceipt.publicReleaseAllowed,
        applyGateReceipt.stdxRemovalAllowed,
        false,
        "accepted-h2-runtime-default-path-mutation-commit-apply-gate-bridge",
        "record-h2-runtime-default-path-mutation-commit-apply-gate-without-runtime-default-mutation",
        [],
        nonClaims,
        "next packet may prove H2 controlled runtime default-path mutation commit apply; actual runtime default-path mutation, release, stdx removal, and H2 closure remain denied",
        "QUIC can reuse H2-style commit-dry-run plus generic commit-apply-gate separation before runtime default mutation"
    )
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitApplyGateDryRunBlockers(
    bridge:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitDryRunBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("H2_RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_DRY_RUN:${bridge.status}")
    for (blocker in bridge.blockers) {
        blockers.add(
            "H2_RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_DRY_RUN_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitApplyGateReceiptBlockers(
    receipt: IgniteRuntimeDefaultPathMutationCommitApplyGateReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_APPLY_GATE:${receipt.status}")
    for (blocker in receipt.blockers) {
        blockers.add(
            "RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_APPLY_GATE_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitApplyGateNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_APPLY",
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationCommitApplyEvidence {
    public let h2RuntimeDefaultPathMutationCommitApplyGateBridge:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitApplyGateBridge
    public let controlledRuntimeDefaultPathMutationCommitApplyReceipt:
        IgniteControlledRuntimeDefaultPathMutationCommitApplyReceipt

    public init(
        h2RuntimeDefaultPathMutationCommitApplyGateBridge:
            JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitApplyGateBridge,
        controlledRuntimeDefaultPathMutationCommitApplyReceipt:
            IgniteControlledRuntimeDefaultPathMutationCommitApplyReceipt
    ) {
        this.h2RuntimeDefaultPathMutationCommitApplyGateBridge =
            h2RuntimeDefaultPathMutationCommitApplyGateBridge
        this.controlledRuntimeDefaultPathMutationCommitApplyReceipt =
            controlledRuntimeDefaultPathMutationCommitApplyReceipt
    }
}

public class JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationCommitApplyBridge {
    public let h2ControlledRuntimeDefaultPathMutationCommitApplyAccepted: Bool
    public let h2RuntimeDefaultPathMutationCommitApplyGateAccepted: Bool
    public let controlledRuntimeDefaultPathMutationCommitApplyAccepted: Bool
    public let controlledRuntimeDefaultPathMutationCommitApplyAllowed: Bool
    public let boundedControlledRuntimeDefaultPathMutationCommitApplyFollowupAllowed: Bool
    public let controlledRuntimeDefaultPathMutationCommitApplyMode: String
    public let controlledRuntimeDefaultPathMutationCommitApplyId: String
    public let runtimeDefaultPathMutationCommitApplyGateId: String
    public let runtimeDefaultPathMutationCommitDryRunId: String
    public let runtimeDefaultPathMutationCommitPlanId: String
    public let controlledRuntimeDefaultPathMutationApplyId: String
    public let runtimeDefaultPathMutationApplyGateId: String
    public let runtimeDefaultPathMutationDryRunId: String
    public let runtimeDefaultPathMutationGateId: String
    public let actualDefaultEngineFlipAllowed: Bool
    public let defaultEngineConfigMutationAllowed: Bool
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2ControlledRuntimeDefaultPathMutationCommitApplyAccepted: Bool,
        h2RuntimeDefaultPathMutationCommitApplyGateAccepted: Bool,
        controlledRuntimeDefaultPathMutationCommitApplyAccepted: Bool,
        controlledRuntimeDefaultPathMutationCommitApplyAllowed: Bool,
        boundedControlledRuntimeDefaultPathMutationCommitApplyFollowupAllowed: Bool,
        controlledRuntimeDefaultPathMutationCommitApplyMode: String,
        controlledRuntimeDefaultPathMutationCommitApplyId: String,
        runtimeDefaultPathMutationCommitApplyGateId: String,
        runtimeDefaultPathMutationCommitDryRunId: String,
        runtimeDefaultPathMutationCommitPlanId: String,
        controlledRuntimeDefaultPathMutationApplyId: String,
        runtimeDefaultPathMutationApplyGateId: String,
        runtimeDefaultPathMutationDryRunId: String,
        runtimeDefaultPathMutationGateId: String,
        actualDefaultEngineFlipAllowed: Bool,
        defaultEngineConfigMutationAllowed: Bool,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2ControlledRuntimeDefaultPathMutationCommitApplyAccepted =
            h2ControlledRuntimeDefaultPathMutationCommitApplyAccepted
        this.h2RuntimeDefaultPathMutationCommitApplyGateAccepted =
            h2RuntimeDefaultPathMutationCommitApplyGateAccepted
        this.controlledRuntimeDefaultPathMutationCommitApplyAccepted =
            controlledRuntimeDefaultPathMutationCommitApplyAccepted
        this.controlledRuntimeDefaultPathMutationCommitApplyAllowed =
            controlledRuntimeDefaultPathMutationCommitApplyAllowed
        this.boundedControlledRuntimeDefaultPathMutationCommitApplyFollowupAllowed =
            boundedControlledRuntimeDefaultPathMutationCommitApplyFollowupAllowed
        this.controlledRuntimeDefaultPathMutationCommitApplyMode =
            controlledRuntimeDefaultPathMutationCommitApplyMode
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
        this.actualDefaultEngineFlipAllowed = actualDefaultEngineFlipAllowed
        this.defaultEngineConfigMutationAllowed =
            defaultEngineConfigMutationAllowed
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationCommitApplyBridge(
    evidence: JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationCommitApplyEvidence
): JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationCommitApplyBridge {
    let h2CommitApplyGateBridge =
        evidence.h2RuntimeDefaultPathMutationCommitApplyGateBridge
    let controlledApplyReceipt =
        evidence.controlledRuntimeDefaultPathMutationCommitApplyReceipt
    let nonClaims =
        jinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationCommitApplyNonClaims()
    if (
        !h2CommitApplyGateBridge.h2RuntimeDefaultPathMutationCommitApplyGateAccepted ||
        !h2CommitApplyGateBridge.boundedRuntimeDefaultPathMutationCommitApplyGateFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationCommitApplyBridge(
            false,
            h2CommitApplyGateBridge.h2RuntimeDefaultPathMutationCommitApplyGateAccepted,
            controlledApplyReceipt.controlledRuntimeDefaultPathMutationCommitApplyAccepted,
            false,
            false,
            controlledApplyReceipt.controlledRuntimeDefaultPathMutationCommitApplyMode,
            controlledApplyReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
            controlledApplyReceipt.runtimeDefaultPathMutationCommitApplyGateId,
            controlledApplyReceipt.runtimeDefaultPathMutationCommitDryRunId,
            controlledApplyReceipt.runtimeDefaultPathMutationCommitPlanId,
            controlledApplyReceipt.controlledRuntimeDefaultPathMutationApplyId,
            controlledApplyReceipt.runtimeDefaultPathMutationApplyGateId,
            controlledApplyReceipt.runtimeDefaultPathMutationDryRunId,
            controlledApplyReceipt.runtimeDefaultPathMutationGateId,
            false,
            false,
            false,
            false,
            false,
            false,
            "blocked-h2-runtime-default-path-mutation-commit-apply-gate-bridge",
            "collect-accepted-h2-runtime-default-path-mutation-commit-apply-gate-before-controlled-runtime-default-path-mutation-commit-apply",
            jinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationCommitApplyGateBlockers(
                h2CommitApplyGateBridge
            ),
            nonClaims,
            "repair H2 runtime default-path mutation commit-apply-gate bridge before controlled commit-apply; do not treat generic controlled commit-apply receipts as H2 runtime mutation",
            "QUIC must pass stream default mutation commit-apply-gate before controlled runtime default-path mutation commit-apply"
        )
    }
    if (
        !controlledApplyReceipt.controlledRuntimeDefaultPathMutationCommitApplyAccepted ||
        !controlledApplyReceipt.controlledRuntimeDefaultPathMutationCommitApplyAllowed
    ) {
        return JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationCommitApplyBridge(
            false,
            true,
            controlledApplyReceipt.controlledRuntimeDefaultPathMutationCommitApplyAccepted,
            controlledApplyReceipt.controlledRuntimeDefaultPathMutationCommitApplyAllowed,
            false,
            controlledApplyReceipt.controlledRuntimeDefaultPathMutationCommitApplyMode,
            controlledApplyReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
            controlledApplyReceipt.runtimeDefaultPathMutationCommitApplyGateId,
            controlledApplyReceipt.runtimeDefaultPathMutationCommitDryRunId,
            controlledApplyReceipt.runtimeDefaultPathMutationCommitPlanId,
            controlledApplyReceipt.controlledRuntimeDefaultPathMutationApplyId,
            controlledApplyReceipt.runtimeDefaultPathMutationApplyGateId,
            controlledApplyReceipt.runtimeDefaultPathMutationDryRunId,
            controlledApplyReceipt.runtimeDefaultPathMutationGateId,
            false,
            false,
            false,
            false,
            false,
            false,
            "blocked-controlled-runtime-default-path-mutation-commit-apply-receipt",
            "collect-accepted-controlled-runtime-default-path-mutation-commit-apply-before-runtime-default-path-mutation-commit-boundary",
            jinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationCommitApplyReceiptBlockers(
                controlledApplyReceipt
            ),
            nonClaims,
            controlledApplyReceipt.nextAction,
            "QUIC must not consume rejected controlled runtime default-path mutation commit-apply receipts for stream default mutation"
        )
    }

    JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationCommitApplyBridge(
        true,
        true,
        true,
        controlledApplyReceipt.controlledRuntimeDefaultPathMutationCommitApplyAllowed,
        true,
        controlledApplyReceipt.controlledRuntimeDefaultPathMutationCommitApplyMode,
        controlledApplyReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
        controlledApplyReceipt.runtimeDefaultPathMutationCommitApplyGateId,
        controlledApplyReceipt.runtimeDefaultPathMutationCommitDryRunId,
        controlledApplyReceipt.runtimeDefaultPathMutationCommitPlanId,
        controlledApplyReceipt.controlledRuntimeDefaultPathMutationApplyId,
        controlledApplyReceipt.runtimeDefaultPathMutationApplyGateId,
        controlledApplyReceipt.runtimeDefaultPathMutationDryRunId,
        controlledApplyReceipt.runtimeDefaultPathMutationGateId,
        controlledApplyReceipt.actualDefaultEngineFlipAllowed,
        controlledApplyReceipt.defaultEngineConfigMutationAllowed,
        controlledApplyReceipt.runtimeDefaultPathMutationAllowed,
        controlledApplyReceipt.publicReleaseAllowed,
        controlledApplyReceipt.stdxRemovalAllowed,
        false,
        "accepted-h2-controlled-runtime-default-path-mutation-commit-apply-bridge",
        "record-h2-controlled-runtime-default-path-mutation-commit-apply-without-runtime-default-mutation",
        [],
        nonClaims,
        "next packet may prove H2 runtime default-path mutation commit-boundary; actual runtime default-path mutation, release, stdx removal, and H2 closure remain denied",
        "QUIC can reuse H2-style commit-apply-gate plus generic controlled commit-apply separation before runtime default mutation"
    )
}

func jinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationCommitApplyGateBlockers(
    bridge:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitApplyGateBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("H2_RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_APPLY_GATE:${bridge.status}")
    for (blocker in bridge.blockers) {
        blockers.add(
            "H2_RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_APPLY_GATE_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationCommitApplyReceiptBlockers(
    receipt: IgniteControlledRuntimeDefaultPathMutationCommitApplyReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_APPLY:${receipt.status}"
    )
    for (blocker in receipt.blockers) {
        blockers.add(
            "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_APPLY_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationCommitApplyNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_BOUNDARY",
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitBoundaryEvidence {
    public let h2ControlledRuntimeDefaultPathMutationCommitApplyBridge:
        JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationCommitApplyBridge
    public let runtimeDefaultPathMutationCommitBoundaryReceipt:
        IgniteRuntimeDefaultPathMutationCommitBoundaryReceipt

    public init(
        h2ControlledRuntimeDefaultPathMutationCommitApplyBridge:
            JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationCommitApplyBridge,
        runtimeDefaultPathMutationCommitBoundaryReceipt:
            IgniteRuntimeDefaultPathMutationCommitBoundaryReceipt
    ) {
        this.h2ControlledRuntimeDefaultPathMutationCommitApplyBridge =
            h2ControlledRuntimeDefaultPathMutationCommitApplyBridge
        this.runtimeDefaultPathMutationCommitBoundaryReceipt =
            runtimeDefaultPathMutationCommitBoundaryReceipt
    }
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitBoundaryBridge {
    public let h2RuntimeDefaultPathMutationCommitBoundaryAccepted: Bool
    public let h2ControlledRuntimeDefaultPathMutationCommitApplyAccepted: Bool
    public let runtimeDefaultPathMutationCommitBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationCommitBoundaryAllowed: Bool
    public let boundedRuntimeDefaultPathMutationCommitBoundaryFollowupAllowed: Bool
    public let controlledRuntimeDefaultPathMutationCommitApplyMode: String
    public let runtimeDefaultPathMutationCommitBoundaryMode: String
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
    public let h2RuntimeClosureClaimAllowed: Bool
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2RuntimeDefaultPathMutationCommitBoundaryAccepted: Bool,
        h2ControlledRuntimeDefaultPathMutationCommitApplyAccepted: Bool,
        runtimeDefaultPathMutationCommitBoundaryAccepted: Bool,
        runtimeDefaultPathMutationCommitBoundaryAllowed: Bool,
        boundedRuntimeDefaultPathMutationCommitBoundaryFollowupAllowed: Bool,
        controlledRuntimeDefaultPathMutationCommitApplyMode: String,
        runtimeDefaultPathMutationCommitBoundaryMode: String,
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
        h2RuntimeClosureClaimAllowed: Bool,
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2RuntimeDefaultPathMutationCommitBoundaryAccepted =
            h2RuntimeDefaultPathMutationCommitBoundaryAccepted
        this.h2ControlledRuntimeDefaultPathMutationCommitApplyAccepted =
            h2ControlledRuntimeDefaultPathMutationCommitApplyAccepted
        this.runtimeDefaultPathMutationCommitBoundaryAccepted =
            runtimeDefaultPathMutationCommitBoundaryAccepted
        this.runtimeDefaultPathMutationCommitBoundaryAllowed =
            runtimeDefaultPathMutationCommitBoundaryAllowed
        this.boundedRuntimeDefaultPathMutationCommitBoundaryFollowupAllowed =
            boundedRuntimeDefaultPathMutationCommitBoundaryFollowupAllowed
        this.controlledRuntimeDefaultPathMutationCommitApplyMode =
            controlledRuntimeDefaultPathMutationCommitApplyMode
        this.runtimeDefaultPathMutationCommitBoundaryMode =
            runtimeDefaultPathMutationCommitBoundaryMode
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
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitBoundaryBridge(
    evidence: JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitBoundaryEvidence
): JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitBoundaryBridge {
    let h2ControlledApplyBridge =
        evidence.h2ControlledRuntimeDefaultPathMutationCommitApplyBridge
    let commitBoundaryReceipt =
        evidence.runtimeDefaultPathMutationCommitBoundaryReceipt
    let nonClaims =
        jinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitBoundaryNonClaims()
    if (
        !h2ControlledApplyBridge.h2ControlledRuntimeDefaultPathMutationCommitApplyAccepted ||
        !h2ControlledApplyBridge.boundedControlledRuntimeDefaultPathMutationCommitApplyFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitBoundaryBridge(
            false,
            h2ControlledApplyBridge.h2ControlledRuntimeDefaultPathMutationCommitApplyAccepted,
            commitBoundaryReceipt.runtimeDefaultPathMutationCommitBoundaryAccepted,
            false,
            false,
            commitBoundaryReceipt.controlledRuntimeDefaultPathMutationCommitApplyMode,
            commitBoundaryReceipt.runtimeDefaultPathMutationCommitBoundaryMode,
            commitBoundaryReceipt.runtimeDefaultPathMutationCommitBoundaryId,
            commitBoundaryReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
            commitBoundaryReceipt.runtimeDefaultPathMutationCommitApplyGateId,
            commitBoundaryReceipt.runtimeDefaultPathMutationCommitDryRunId,
            commitBoundaryReceipt.runtimeDefaultPathMutationCommitPlanId,
            commitBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyId,
            commitBoundaryReceipt.runtimeDefaultPathMutationApplyGateId,
            commitBoundaryReceipt.runtimeDefaultPathMutationDryRunId,
            commitBoundaryReceipt.runtimeDefaultPathMutationGateId,
            commitBoundaryReceipt.controlledDefaultEngineMutationApplyId,
            commitBoundaryReceipt.defaultEngineMutationApplyGateId,
            commitBoundaryReceipt.defaultEngineMutationDryRunId,
            commitBoundaryReceipt.defaultEngineMutationCommitPlanId,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            "blocked-h2-controlled-runtime-default-path-mutation-commit-apply-bridge",
            "collect-accepted-h2-controlled-runtime-default-path-mutation-commit-apply-before-runtime-default-path-mutation-commit-boundary",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitBoundaryControlledApplyBlockers(
                h2ControlledApplyBridge
            ),
            nonClaims,
            "repair H2 controlled runtime default-path mutation commit-apply bridge before commit boundary; do not treat generic commit-boundary receipts as H2 runtime mutation",
            "QUIC must pass controlled stream default mutation commit-apply before runtime default-path mutation commit boundary"
        )
    }
    if (
        !commitBoundaryReceipt.runtimeDefaultPathMutationCommitBoundaryAccepted ||
        !commitBoundaryReceipt.runtimeDefaultPathMutationCommitBoundaryAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitBoundaryBridge(
            false,
            true,
            commitBoundaryReceipt.runtimeDefaultPathMutationCommitBoundaryAccepted,
            commitBoundaryReceipt.runtimeDefaultPathMutationCommitBoundaryAllowed,
            false,
            commitBoundaryReceipt.controlledRuntimeDefaultPathMutationCommitApplyMode,
            commitBoundaryReceipt.runtimeDefaultPathMutationCommitBoundaryMode,
            commitBoundaryReceipt.runtimeDefaultPathMutationCommitBoundaryId,
            commitBoundaryReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
            commitBoundaryReceipt.runtimeDefaultPathMutationCommitApplyGateId,
            commitBoundaryReceipt.runtimeDefaultPathMutationCommitDryRunId,
            commitBoundaryReceipt.runtimeDefaultPathMutationCommitPlanId,
            commitBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyId,
            commitBoundaryReceipt.runtimeDefaultPathMutationApplyGateId,
            commitBoundaryReceipt.runtimeDefaultPathMutationDryRunId,
            commitBoundaryReceipt.runtimeDefaultPathMutationGateId,
            commitBoundaryReceipt.controlledDefaultEngineMutationApplyId,
            commitBoundaryReceipt.defaultEngineMutationApplyGateId,
            commitBoundaryReceipt.defaultEngineMutationDryRunId,
            commitBoundaryReceipt.defaultEngineMutationCommitPlanId,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            "blocked-runtime-default-path-mutation-commit-boundary-receipt",
            "collect-accepted-runtime-default-path-mutation-commit-boundary-before-finalization-gate",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitBoundaryReceiptBlockers(
                commitBoundaryReceipt
            ),
            nonClaims,
            commitBoundaryReceipt.nextAction,
            "QUIC must not consume rejected runtime default-path mutation commit-boundary receipts for stream default mutation"
        )
    }

    JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitBoundaryBridge(
        true,
        true,
        true,
        commitBoundaryReceipt.runtimeDefaultPathMutationCommitBoundaryAllowed,
        true,
        commitBoundaryReceipt.controlledRuntimeDefaultPathMutationCommitApplyMode,
        commitBoundaryReceipt.runtimeDefaultPathMutationCommitBoundaryMode,
        commitBoundaryReceipt.runtimeDefaultPathMutationCommitBoundaryId,
        commitBoundaryReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
        commitBoundaryReceipt.runtimeDefaultPathMutationCommitApplyGateId,
        commitBoundaryReceipt.runtimeDefaultPathMutationCommitDryRunId,
        commitBoundaryReceipt.runtimeDefaultPathMutationCommitPlanId,
        commitBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyId,
        commitBoundaryReceipt.runtimeDefaultPathMutationApplyGateId,
        commitBoundaryReceipt.runtimeDefaultPathMutationDryRunId,
        commitBoundaryReceipt.runtimeDefaultPathMutationGateId,
        commitBoundaryReceipt.controlledDefaultEngineMutationApplyId,
        commitBoundaryReceipt.defaultEngineMutationApplyGateId,
        commitBoundaryReceipt.defaultEngineMutationDryRunId,
        commitBoundaryReceipt.defaultEngineMutationCommitPlanId,
        commitBoundaryReceipt.productionQueueMutationAllowed,
        commitBoundaryReceipt.actualRuntimeTaskSpawnAllowed,
        commitBoundaryReceipt.actualHandlerInvocationAllowed,
        commitBoundaryReceipt.actualRequestContextMutationAllowed,
        commitBoundaryReceipt.actualResponseWriteAllowed,
        commitBoundaryReceipt.actualTransportCommitAllowed,
        commitBoundaryReceipt.actualLiveServerWiringAllowed,
        commitBoundaryReceipt.actualDefaultEngineFlipAllowed,
        commitBoundaryReceipt.defaultEngineConfigMutationAllowed,
        commitBoundaryReceipt.runtimeDefaultPathMutationAllowed,
        commitBoundaryReceipt.publicReleaseAllowed,
        commitBoundaryReceipt.stdxRemovalAllowed,
        false,
        "accepted-h2-runtime-default-path-mutation-commit-boundary-bridge",
        "record-h2-runtime-default-path-mutation-commit-boundary-without-runtime-default-mutation",
        [],
        nonClaims,
        "next packet may prove H2 runtime default-path mutation finalization gate; actual runtime default-path mutation, release, stdx removal, and H2 closure remain denied",
        "QUIC can reuse H2-style controlled commit-apply plus generic commit-boundary separation before runtime default mutation"
    )
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitBoundaryControlledApplyBlockers(
    bridge:
        JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationCommitApplyBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "H2_CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_APPLY:${bridge.status}"
    )
    for (blocker in bridge.blockers) {
        blockers.add(
            "H2_CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_APPLY_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitBoundaryReceiptBlockers(
    receipt: IgniteRuntimeDefaultPathMutationCommitBoundaryReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_BOUNDARY:${receipt.status}"
    )
    for (blocker in receipt.blockers) {
        blockers.add(
            "RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_BOUNDARY_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitBoundaryNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION_FINALIZATION_GATE",
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationFinalizationGateEvidence {
    public let h2RuntimeDefaultPathMutationCommitBoundaryBridge:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitBoundaryBridge
    public let runtimeDefaultPathMutationFinalizationGateReceipt:
        IgniteRuntimeDefaultPathMutationFinalizationGateReceipt

    public init(
        h2RuntimeDefaultPathMutationCommitBoundaryBridge:
            JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitBoundaryBridge,
        runtimeDefaultPathMutationFinalizationGateReceipt:
            IgniteRuntimeDefaultPathMutationFinalizationGateReceipt
    ) {
        this.h2RuntimeDefaultPathMutationCommitBoundaryBridge =
            h2RuntimeDefaultPathMutationCommitBoundaryBridge
        this.runtimeDefaultPathMutationFinalizationGateReceipt =
            runtimeDefaultPathMutationFinalizationGateReceipt
    }
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationFinalizationGateBridge {
    public let h2RuntimeDefaultPathMutationFinalizationGateAccepted: Bool
    public let h2RuntimeDefaultPathMutationCommitBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationFinalizationGateAccepted: Bool
    public let runtimeDefaultPathMutationFinalizationGateAllowed: Bool
    public let boundedRuntimeDefaultPathMutationFinalizationGateFollowupAllowed: Bool
    public let runtimeDefaultPathMutationCommitBoundaryMode: String
    public let runtimeDefaultPathMutationFinalizationGateMode: String
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
    public let h2RuntimeClosureClaimAllowed: Bool
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2RuntimeDefaultPathMutationFinalizationGateAccepted: Bool,
        h2RuntimeDefaultPathMutationCommitBoundaryAccepted: Bool,
        runtimeDefaultPathMutationFinalizationGateAccepted: Bool,
        runtimeDefaultPathMutationFinalizationGateAllowed: Bool,
        boundedRuntimeDefaultPathMutationFinalizationGateFollowupAllowed: Bool,
        runtimeDefaultPathMutationCommitBoundaryMode: String,
        runtimeDefaultPathMutationFinalizationGateMode: String,
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
        h2RuntimeClosureClaimAllowed: Bool,
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2RuntimeDefaultPathMutationFinalizationGateAccepted =
            h2RuntimeDefaultPathMutationFinalizationGateAccepted
        this.h2RuntimeDefaultPathMutationCommitBoundaryAccepted =
            h2RuntimeDefaultPathMutationCommitBoundaryAccepted
        this.runtimeDefaultPathMutationFinalizationGateAccepted =
            runtimeDefaultPathMutationFinalizationGateAccepted
        this.runtimeDefaultPathMutationFinalizationGateAllowed =
            runtimeDefaultPathMutationFinalizationGateAllowed
        this.boundedRuntimeDefaultPathMutationFinalizationGateFollowupAllowed =
            boundedRuntimeDefaultPathMutationFinalizationGateFollowupAllowed
        this.runtimeDefaultPathMutationCommitBoundaryMode =
            runtimeDefaultPathMutationCommitBoundaryMode
        this.runtimeDefaultPathMutationFinalizationGateMode =
            runtimeDefaultPathMutationFinalizationGateMode
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
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2RuntimeDefaultPathMutationFinalizationGateBridge(
    evidence: JinguiAcceptedTransportH2RuntimeDefaultPathMutationFinalizationGateEvidence
): JinguiAcceptedTransportH2RuntimeDefaultPathMutationFinalizationGateBridge {
    let h2CommitBoundaryBridge =
        evidence.h2RuntimeDefaultPathMutationCommitBoundaryBridge
    let finalizationGateReceipt =
        evidence.runtimeDefaultPathMutationFinalizationGateReceipt
    let nonClaims =
        jinguiAcceptedTransportH2RuntimeDefaultPathMutationFinalizationGateNonClaims()
    if (
        !h2CommitBoundaryBridge.h2RuntimeDefaultPathMutationCommitBoundaryAccepted ||
        !h2CommitBoundaryBridge.boundedRuntimeDefaultPathMutationCommitBoundaryFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationFinalizationGateBridge(
            false,
            h2CommitBoundaryBridge.h2RuntimeDefaultPathMutationCommitBoundaryAccepted,
            finalizationGateReceipt.runtimeDefaultPathMutationFinalizationGateAccepted,
            false,
            false,
            finalizationGateReceipt.runtimeDefaultPathMutationCommitBoundaryMode,
            finalizationGateReceipt.runtimeDefaultPathMutationFinalizationGateMode,
            finalizationGateReceipt.runtimeDefaultPathMutationFinalizationGateId,
            finalizationGateReceipt.runtimeDefaultPathMutationCommitBoundaryId,
            finalizationGateReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
            finalizationGateReceipt.runtimeDefaultPathMutationCommitApplyGateId,
            finalizationGateReceipt.runtimeDefaultPathMutationCommitDryRunId,
            finalizationGateReceipt.runtimeDefaultPathMutationCommitPlanId,
            finalizationGateReceipt.controlledRuntimeDefaultPathMutationApplyId,
            finalizationGateReceipt.runtimeDefaultPathMutationApplyGateId,
            finalizationGateReceipt.runtimeDefaultPathMutationDryRunId,
            finalizationGateReceipt.runtimeDefaultPathMutationGateId,
            finalizationGateReceipt.controlledDefaultEngineMutationApplyId,
            finalizationGateReceipt.defaultEngineMutationApplyGateId,
            finalizationGateReceipt.defaultEngineMutationDryRunId,
            finalizationGateReceipt.defaultEngineMutationCommitPlanId,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            "blocked-h2-runtime-default-path-mutation-commit-boundary-bridge",
            "collect-accepted-h2-runtime-default-path-mutation-commit-boundary-before-finalization-gate",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationFinalizationGateCommitBoundaryBlockers(
                h2CommitBoundaryBridge
            ),
            nonClaims,
            "repair H2 runtime default-path mutation commit-boundary bridge before finalization gate; do not treat generic finalization-gate receipts as H2 runtime mutation",
            "QUIC must pass stream default mutation commit-boundary before runtime default-path mutation finalization gate"
        )
    }
    if (
        !finalizationGateReceipt.runtimeDefaultPathMutationFinalizationGateAccepted ||
        !finalizationGateReceipt.runtimeDefaultPathMutationFinalizationGateAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationFinalizationGateBridge(
            false,
            true,
            finalizationGateReceipt.runtimeDefaultPathMutationFinalizationGateAccepted,
            finalizationGateReceipt.runtimeDefaultPathMutationFinalizationGateAllowed,
            false,
            finalizationGateReceipt.runtimeDefaultPathMutationCommitBoundaryMode,
            finalizationGateReceipt.runtimeDefaultPathMutationFinalizationGateMode,
            finalizationGateReceipt.runtimeDefaultPathMutationFinalizationGateId,
            finalizationGateReceipt.runtimeDefaultPathMutationCommitBoundaryId,
            finalizationGateReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
            finalizationGateReceipt.runtimeDefaultPathMutationCommitApplyGateId,
            finalizationGateReceipt.runtimeDefaultPathMutationCommitDryRunId,
            finalizationGateReceipt.runtimeDefaultPathMutationCommitPlanId,
            finalizationGateReceipt.controlledRuntimeDefaultPathMutationApplyId,
            finalizationGateReceipt.runtimeDefaultPathMutationApplyGateId,
            finalizationGateReceipt.runtimeDefaultPathMutationDryRunId,
            finalizationGateReceipt.runtimeDefaultPathMutationGateId,
            finalizationGateReceipt.controlledDefaultEngineMutationApplyId,
            finalizationGateReceipt.defaultEngineMutationApplyGateId,
            finalizationGateReceipt.defaultEngineMutationDryRunId,
            finalizationGateReceipt.defaultEngineMutationCommitPlanId,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            "blocked-runtime-default-path-mutation-finalization-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-finalization-gate-before-controlled-finalization-apply",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationFinalizationGateReceiptBlockers(
                finalizationGateReceipt
            ),
            nonClaims,
            finalizationGateReceipt.nextAction,
            "QUIC must not consume rejected runtime default-path mutation finalization-gate receipts for stream default mutation"
        )
    }

    JinguiAcceptedTransportH2RuntimeDefaultPathMutationFinalizationGateBridge(
        true,
        true,
        true,
        finalizationGateReceipt.runtimeDefaultPathMutationFinalizationGateAllowed,
        true,
        finalizationGateReceipt.runtimeDefaultPathMutationCommitBoundaryMode,
        finalizationGateReceipt.runtimeDefaultPathMutationFinalizationGateMode,
        finalizationGateReceipt.runtimeDefaultPathMutationFinalizationGateId,
        finalizationGateReceipt.runtimeDefaultPathMutationCommitBoundaryId,
        finalizationGateReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
        finalizationGateReceipt.runtimeDefaultPathMutationCommitApplyGateId,
        finalizationGateReceipt.runtimeDefaultPathMutationCommitDryRunId,
        finalizationGateReceipt.runtimeDefaultPathMutationCommitPlanId,
        finalizationGateReceipt.controlledRuntimeDefaultPathMutationApplyId,
        finalizationGateReceipt.runtimeDefaultPathMutationApplyGateId,
        finalizationGateReceipt.runtimeDefaultPathMutationDryRunId,
        finalizationGateReceipt.runtimeDefaultPathMutationGateId,
        finalizationGateReceipt.controlledDefaultEngineMutationApplyId,
        finalizationGateReceipt.defaultEngineMutationApplyGateId,
        finalizationGateReceipt.defaultEngineMutationDryRunId,
        finalizationGateReceipt.defaultEngineMutationCommitPlanId,
        finalizationGateReceipt.productionQueueMutationAllowed,
        finalizationGateReceipt.actualRuntimeTaskSpawnAllowed,
        finalizationGateReceipt.actualHandlerInvocationAllowed,
        finalizationGateReceipt.actualRequestContextMutationAllowed,
        finalizationGateReceipt.actualResponseWriteAllowed,
        finalizationGateReceipt.actualTransportCommitAllowed,
        finalizationGateReceipt.actualLiveServerWiringAllowed,
        finalizationGateReceipt.actualDefaultEngineFlipAllowed,
        finalizationGateReceipt.defaultEngineConfigMutationAllowed,
        finalizationGateReceipt.runtimeDefaultPathMutationAllowed,
        finalizationGateReceipt.publicReleaseAllowed,
        finalizationGateReceipt.stdxRemovalAllowed,
        false,
        "accepted-h2-runtime-default-path-mutation-finalization-gate-bridge",
        "record-h2-runtime-default-path-mutation-finalization-gate-without-runtime-default-mutation",
        [],
        nonClaims,
        "next packet may prove H2 controlled runtime default-path mutation finalization apply; actual runtime default-path mutation, release, stdx removal, and H2 closure remain denied",
        "QUIC can reuse H2-style commit-boundary plus generic finalization-gate separation before runtime default mutation"
    )
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationFinalizationGateCommitBoundaryBlockers(
    bridge:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationCommitBoundaryBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "H2_RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_BOUNDARY:${bridge.status}"
    )
    for (blocker in bridge.blockers) {
        blockers.add(
            "H2_RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_BOUNDARY_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationFinalizationGateReceiptBlockers(
    receipt: IgniteRuntimeDefaultPathMutationFinalizationGateReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "RUNTIME_DEFAULT_PATH_MUTATION_FINALIZATION_GATE:${receipt.status}"
    )
    for (blocker in receipt.blockers) {
        blockers.add(
            "RUNTIME_DEFAULT_PATH_MUTATION_FINALIZATION_GATE_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationFinalizationGateNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_FINALIZATION_APPLY",
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationFinalizationApplyEvidence {
    public let h2RuntimeDefaultPathMutationFinalizationGateBridge:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationFinalizationGateBridge
    public let controlledRuntimeDefaultPathMutationFinalizationApplyReceipt:
        IgniteControlledRuntimeDefaultPathMutationFinalizationApplyReceipt

    public init(
        h2RuntimeDefaultPathMutationFinalizationGateBridge:
            JinguiAcceptedTransportH2RuntimeDefaultPathMutationFinalizationGateBridge,
        controlledRuntimeDefaultPathMutationFinalizationApplyReceipt:
            IgniteControlledRuntimeDefaultPathMutationFinalizationApplyReceipt
    ) {
        this.h2RuntimeDefaultPathMutationFinalizationGateBridge =
            h2RuntimeDefaultPathMutationFinalizationGateBridge
        this.controlledRuntimeDefaultPathMutationFinalizationApplyReceipt =
            controlledRuntimeDefaultPathMutationFinalizationApplyReceipt
    }
}

public class JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationFinalizationApplyBridge {
    public let h2ControlledRuntimeDefaultPathMutationFinalizationApplyAccepted: Bool
    public let h2RuntimeDefaultPathMutationFinalizationGateAccepted: Bool
    public let controlledRuntimeDefaultPathMutationFinalizationApplyAccepted: Bool
    public let controlledRuntimeDefaultPathMutationFinalizationApplyAllowed: Bool
    public let boundedControlledRuntimeDefaultPathMutationFinalizationApplyFollowupAllowed: Bool
    public let runtimeDefaultPathMutationFinalizationGateMode: String
    public let controlledRuntimeDefaultPathMutationFinalizationApplyMode: String
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
    public let h2RuntimeClosureClaimAllowed: Bool
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2ControlledRuntimeDefaultPathMutationFinalizationApplyAccepted: Bool,
        h2RuntimeDefaultPathMutationFinalizationGateAccepted: Bool,
        controlledRuntimeDefaultPathMutationFinalizationApplyAccepted: Bool,
        controlledRuntimeDefaultPathMutationFinalizationApplyAllowed: Bool,
        boundedControlledRuntimeDefaultPathMutationFinalizationApplyFollowupAllowed: Bool,
        runtimeDefaultPathMutationFinalizationGateMode: String,
        controlledRuntimeDefaultPathMutationFinalizationApplyMode: String,
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
        h2RuntimeClosureClaimAllowed: Bool,
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2ControlledRuntimeDefaultPathMutationFinalizationApplyAccepted =
            h2ControlledRuntimeDefaultPathMutationFinalizationApplyAccepted
        this.h2RuntimeDefaultPathMutationFinalizationGateAccepted =
            h2RuntimeDefaultPathMutationFinalizationGateAccepted
        this.controlledRuntimeDefaultPathMutationFinalizationApplyAccepted =
            controlledRuntimeDefaultPathMutationFinalizationApplyAccepted
        this.controlledRuntimeDefaultPathMutationFinalizationApplyAllowed =
            controlledRuntimeDefaultPathMutationFinalizationApplyAllowed
        this.boundedControlledRuntimeDefaultPathMutationFinalizationApplyFollowupAllowed =
            boundedControlledRuntimeDefaultPathMutationFinalizationApplyFollowupAllowed
        this.runtimeDefaultPathMutationFinalizationGateMode =
            runtimeDefaultPathMutationFinalizationGateMode
        this.controlledRuntimeDefaultPathMutationFinalizationApplyMode =
            controlledRuntimeDefaultPathMutationFinalizationApplyMode
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
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationFinalizationApplyBridge(
    evidence:
        JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationFinalizationApplyEvidence
): JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationFinalizationApplyBridge {
    let h2FinalizationGateBridge =
        evidence.h2RuntimeDefaultPathMutationFinalizationGateBridge
    let controlledApplyReceipt =
        evidence.controlledRuntimeDefaultPathMutationFinalizationApplyReceipt
    let nonClaims =
        jinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationFinalizationApplyNonClaims()
    if (
        !h2FinalizationGateBridge.h2RuntimeDefaultPathMutationFinalizationGateAccepted ||
        !h2FinalizationGateBridge.boundedRuntimeDefaultPathMutationFinalizationGateFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationFinalizationApplyBridge(
            false,
            h2FinalizationGateBridge.h2RuntimeDefaultPathMutationFinalizationGateAccepted,
            controlledApplyReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyAccepted,
            false,
            false,
            controlledApplyReceipt.runtimeDefaultPathMutationFinalizationGateMode,
            controlledApplyReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyMode,
            controlledApplyReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyId,
            controlledApplyReceipt.runtimeDefaultPathMutationFinalizationGateId,
            controlledApplyReceipt.runtimeDefaultPathMutationCommitBoundaryId,
            controlledApplyReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
            controlledApplyReceipt.runtimeDefaultPathMutationCommitApplyGateId,
            controlledApplyReceipt.runtimeDefaultPathMutationCommitDryRunId,
            controlledApplyReceipt.runtimeDefaultPathMutationCommitPlanId,
            controlledApplyReceipt.controlledRuntimeDefaultPathMutationApplyId,
            controlledApplyReceipt.runtimeDefaultPathMutationApplyGateId,
            controlledApplyReceipt.runtimeDefaultPathMutationDryRunId,
            controlledApplyReceipt.runtimeDefaultPathMutationGateId,
            controlledApplyReceipt.controlledDefaultEngineMutationApplyId,
            controlledApplyReceipt.defaultEngineMutationApplyGateId,
            controlledApplyReceipt.defaultEngineMutationDryRunId,
            controlledApplyReceipt.defaultEngineMutationCommitPlanId,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            "blocked-h2-runtime-default-path-mutation-finalization-gate-bridge",
            "collect-accepted-h2-runtime-default-path-mutation-finalization-gate-before-controlled-finalization-apply",
            jinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationFinalizationApplyGateBlockers(
                h2FinalizationGateBridge
            ),
            nonClaims,
            "repair H2 runtime default-path mutation finalization-gate bridge before controlled finalization apply; do not treat generic controlled finalization receipts as H2 runtime mutation",
            "QUIC must pass stream default mutation finalization gate before controlled runtime default mutation finalization apply"
        )
    }
    if (
        !controlledApplyReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyAccepted ||
        !controlledApplyReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyAllowed
    ) {
        return JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationFinalizationApplyBridge(
            false,
            true,
            controlledApplyReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyAccepted,
            controlledApplyReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyAllowed,
            false,
            controlledApplyReceipt.runtimeDefaultPathMutationFinalizationGateMode,
            controlledApplyReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyMode,
            controlledApplyReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyId,
            controlledApplyReceipt.runtimeDefaultPathMutationFinalizationGateId,
            controlledApplyReceipt.runtimeDefaultPathMutationCommitBoundaryId,
            controlledApplyReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
            controlledApplyReceipt.runtimeDefaultPathMutationCommitApplyGateId,
            controlledApplyReceipt.runtimeDefaultPathMutationCommitDryRunId,
            controlledApplyReceipt.runtimeDefaultPathMutationCommitPlanId,
            controlledApplyReceipt.controlledRuntimeDefaultPathMutationApplyId,
            controlledApplyReceipt.runtimeDefaultPathMutationApplyGateId,
            controlledApplyReceipt.runtimeDefaultPathMutationDryRunId,
            controlledApplyReceipt.runtimeDefaultPathMutationGateId,
            controlledApplyReceipt.controlledDefaultEngineMutationApplyId,
            controlledApplyReceipt.defaultEngineMutationApplyGateId,
            controlledApplyReceipt.defaultEngineMutationDryRunId,
            controlledApplyReceipt.defaultEngineMutationCommitPlanId,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            "blocked-controlled-runtime-default-path-mutation-finalization-apply-receipt",
            "collect-accepted-controlled-runtime-default-path-mutation-finalization-apply-before-closeout-gate",
            jinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationFinalizationApplyReceiptBlockers(
                controlledApplyReceipt
            ),
            nonClaims,
            controlledApplyReceipt.nextAction,
            "QUIC must not consume rejected controlled runtime default-path mutation finalization-apply receipts for stream default mutation"
        )
    }

    JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationFinalizationApplyBridge(
        true,
        true,
        true,
        controlledApplyReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyAllowed,
        true,
        controlledApplyReceipt.runtimeDefaultPathMutationFinalizationGateMode,
        controlledApplyReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyMode,
        controlledApplyReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyId,
        controlledApplyReceipt.runtimeDefaultPathMutationFinalizationGateId,
        controlledApplyReceipt.runtimeDefaultPathMutationCommitBoundaryId,
        controlledApplyReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
        controlledApplyReceipt.runtimeDefaultPathMutationCommitApplyGateId,
        controlledApplyReceipt.runtimeDefaultPathMutationCommitDryRunId,
        controlledApplyReceipt.runtimeDefaultPathMutationCommitPlanId,
        controlledApplyReceipt.controlledRuntimeDefaultPathMutationApplyId,
        controlledApplyReceipt.runtimeDefaultPathMutationApplyGateId,
        controlledApplyReceipt.runtimeDefaultPathMutationDryRunId,
        controlledApplyReceipt.runtimeDefaultPathMutationGateId,
        controlledApplyReceipt.controlledDefaultEngineMutationApplyId,
        controlledApplyReceipt.defaultEngineMutationApplyGateId,
        controlledApplyReceipt.defaultEngineMutationDryRunId,
        controlledApplyReceipt.defaultEngineMutationCommitPlanId,
        controlledApplyReceipt.productionQueueMutationAllowed,
        controlledApplyReceipt.actualRuntimeTaskSpawnAllowed,
        controlledApplyReceipt.actualHandlerInvocationAllowed,
        controlledApplyReceipt.actualRequestContextMutationAllowed,
        controlledApplyReceipt.actualResponseWriteAllowed,
        controlledApplyReceipt.actualTransportCommitAllowed,
        controlledApplyReceipt.actualLiveServerWiringAllowed,
        controlledApplyReceipt.actualDefaultEngineFlipAllowed,
        controlledApplyReceipt.defaultEngineConfigMutationAllowed,
        controlledApplyReceipt.runtimeDefaultPathMutationAllowed,
        controlledApplyReceipt.publicReleaseAllowed,
        controlledApplyReceipt.stdxRemovalAllowed,
        false,
        "accepted-h2-controlled-runtime-default-path-mutation-finalization-apply-bridge",
        "record-h2-controlled-runtime-default-path-mutation-finalization-apply-without-runtime-default-mutation",
        [],
        nonClaims,
        "next packet may prove H2 runtime default-path mutation closeout gate; actual runtime default-path mutation, release, stdx removal, and H2 closure remain denied",
        "QUIC can reuse H2-style finalization-gate plus generic controlled-finalization-apply separation before runtime default mutation"
    )
}

func jinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationFinalizationApplyGateBlockers(
    bridge:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationFinalizationGateBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "H2_RUNTIME_DEFAULT_PATH_MUTATION_FINALIZATION_GATE:${bridge.status}"
    )
    for (blocker in bridge.blockers) {
        blockers.add(
            "H2_RUNTIME_DEFAULT_PATH_MUTATION_FINALIZATION_GATE_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationFinalizationApplyReceiptBlockers(
    receipt: IgniteControlledRuntimeDefaultPathMutationFinalizationApplyReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_FINALIZATION_APPLY:${receipt.status}"
    )
    for (blocker in receipt.blockers) {
        blockers.add(
            "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_FINALIZATION_APPLY_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationFinalizationApplyNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION_CLOSEOUT_GATE",
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationCloseoutGateEvidence {
    public let h2ControlledRuntimeDefaultPathMutationFinalizationApplyBridge:
        JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationFinalizationApplyBridge
    public let runtimeDefaultPathMutationCloseoutGateReceipt:
        IgniteRuntimeDefaultPathMutationCloseoutGateReceipt

    public init(
        h2ControlledRuntimeDefaultPathMutationFinalizationApplyBridge:
            JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationFinalizationApplyBridge,
        runtimeDefaultPathMutationCloseoutGateReceipt:
            IgniteRuntimeDefaultPathMutationCloseoutGateReceipt
    ) {
        this.h2ControlledRuntimeDefaultPathMutationFinalizationApplyBridge =
            h2ControlledRuntimeDefaultPathMutationFinalizationApplyBridge
        this.runtimeDefaultPathMutationCloseoutGateReceipt =
            runtimeDefaultPathMutationCloseoutGateReceipt
    }
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationCloseoutGateBridge {
    public let h2RuntimeDefaultPathMutationCloseoutGateAccepted: Bool
    public let h2ControlledRuntimeDefaultPathMutationFinalizationApplyAccepted: Bool
    public let runtimeDefaultPathMutationCloseoutGateAccepted: Bool
    public let runtimeDefaultPathMutationCloseoutGateAllowed: Bool
    public let boundedRuntimeDefaultPathMutationCloseoutGateFollowupAllowed: Bool
    public let controlledRuntimeDefaultPathMutationFinalizationApplyMode: String
    public let runtimeDefaultPathMutationCloseoutGateMode: String
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
    public let h2RuntimeClosureClaimAllowed: Bool
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2RuntimeDefaultPathMutationCloseoutGateAccepted: Bool,
        h2ControlledRuntimeDefaultPathMutationFinalizationApplyAccepted: Bool,
        runtimeDefaultPathMutationCloseoutGateAccepted: Bool,
        runtimeDefaultPathMutationCloseoutGateAllowed: Bool,
        boundedRuntimeDefaultPathMutationCloseoutGateFollowupAllowed: Bool,
        controlledRuntimeDefaultPathMutationFinalizationApplyMode: String,
        runtimeDefaultPathMutationCloseoutGateMode: String,
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
        h2RuntimeClosureClaimAllowed: Bool,
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2RuntimeDefaultPathMutationCloseoutGateAccepted =
            h2RuntimeDefaultPathMutationCloseoutGateAccepted
        this.h2ControlledRuntimeDefaultPathMutationFinalizationApplyAccepted =
            h2ControlledRuntimeDefaultPathMutationFinalizationApplyAccepted
        this.runtimeDefaultPathMutationCloseoutGateAccepted =
            runtimeDefaultPathMutationCloseoutGateAccepted
        this.runtimeDefaultPathMutationCloseoutGateAllowed =
            runtimeDefaultPathMutationCloseoutGateAllowed
        this.boundedRuntimeDefaultPathMutationCloseoutGateFollowupAllowed =
            boundedRuntimeDefaultPathMutationCloseoutGateFollowupAllowed
        this.controlledRuntimeDefaultPathMutationFinalizationApplyMode =
            controlledRuntimeDefaultPathMutationFinalizationApplyMode
        this.runtimeDefaultPathMutationCloseoutGateMode =
            runtimeDefaultPathMutationCloseoutGateMode
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
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2RuntimeDefaultPathMutationCloseoutGateBridge(
    evidence: JinguiAcceptedTransportH2RuntimeDefaultPathMutationCloseoutGateEvidence
): JinguiAcceptedTransportH2RuntimeDefaultPathMutationCloseoutGateBridge {
    let h2ControlledFinalizationApplyBridge =
        evidence.h2ControlledRuntimeDefaultPathMutationFinalizationApplyBridge
    let closeoutGateReceipt =
        evidence.runtimeDefaultPathMutationCloseoutGateReceipt
    let nonClaims =
        jinguiAcceptedTransportH2RuntimeDefaultPathMutationCloseoutGateNonClaims()
    if (
        !h2ControlledFinalizationApplyBridge
            .h2ControlledRuntimeDefaultPathMutationFinalizationApplyAccepted ||
        !h2ControlledFinalizationApplyBridge
            .boundedControlledRuntimeDefaultPathMutationFinalizationApplyFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationCloseoutGateBridge(
            false,
            h2ControlledFinalizationApplyBridge.h2ControlledRuntimeDefaultPathMutationFinalizationApplyAccepted,
            closeoutGateReceipt.runtimeDefaultPathMutationCloseoutGateAccepted,
            false,
            false,
            closeoutGateReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyMode,
            closeoutGateReceipt.runtimeDefaultPathMutationCloseoutGateMode,
            closeoutGateReceipt.runtimeDefaultPathMutationCloseoutGateId,
            closeoutGateReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyId,
            closeoutGateReceipt.runtimeDefaultPathMutationFinalizationGateId,
            closeoutGateReceipt.runtimeDefaultPathMutationCommitBoundaryId,
            closeoutGateReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
            closeoutGateReceipt.runtimeDefaultPathMutationCommitApplyGateId,
            closeoutGateReceipt.runtimeDefaultPathMutationCommitDryRunId,
            closeoutGateReceipt.runtimeDefaultPathMutationCommitPlanId,
            closeoutGateReceipt.controlledRuntimeDefaultPathMutationApplyId,
            closeoutGateReceipt.runtimeDefaultPathMutationApplyGateId,
            closeoutGateReceipt.runtimeDefaultPathMutationDryRunId,
            closeoutGateReceipt.runtimeDefaultPathMutationGateId,
            closeoutGateReceipt.controlledDefaultEngineMutationApplyId,
            closeoutGateReceipt.defaultEngineMutationApplyGateId,
            closeoutGateReceipt.defaultEngineMutationDryRunId,
            closeoutGateReceipt.defaultEngineMutationCommitPlanId,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            "blocked-h2-controlled-runtime-default-path-mutation-finalization-apply-bridge",
            "collect-accepted-h2-controlled-runtime-default-path-mutation-finalization-apply-before-closeout-gate",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationCloseoutGateControlledApplyBlockers(
                h2ControlledFinalizationApplyBridge
            ),
            nonClaims,
            "repair H2 controlled runtime default-path mutation finalization-apply bridge before closeout gate; do not treat generic closeout receipts as H2 runtime mutation",
            "QUIC must pass stream default mutation controlled finalization-apply before runtime default mutation closeout gate"
        )
    }
    if (
        !closeoutGateReceipt.runtimeDefaultPathMutationCloseoutGateAccepted ||
        !closeoutGateReceipt.runtimeDefaultPathMutationCloseoutGateAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationCloseoutGateBridge(
            false,
            true,
            closeoutGateReceipt.runtimeDefaultPathMutationCloseoutGateAccepted,
            closeoutGateReceipt.runtimeDefaultPathMutationCloseoutGateAllowed,
            false,
            closeoutGateReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyMode,
            closeoutGateReceipt.runtimeDefaultPathMutationCloseoutGateMode,
            closeoutGateReceipt.runtimeDefaultPathMutationCloseoutGateId,
            closeoutGateReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyId,
            closeoutGateReceipt.runtimeDefaultPathMutationFinalizationGateId,
            closeoutGateReceipt.runtimeDefaultPathMutationCommitBoundaryId,
            closeoutGateReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
            closeoutGateReceipt.runtimeDefaultPathMutationCommitApplyGateId,
            closeoutGateReceipt.runtimeDefaultPathMutationCommitDryRunId,
            closeoutGateReceipt.runtimeDefaultPathMutationCommitPlanId,
            closeoutGateReceipt.controlledRuntimeDefaultPathMutationApplyId,
            closeoutGateReceipt.runtimeDefaultPathMutationApplyGateId,
            closeoutGateReceipt.runtimeDefaultPathMutationDryRunId,
            closeoutGateReceipt.runtimeDefaultPathMutationGateId,
            closeoutGateReceipt.controlledDefaultEngineMutationApplyId,
            closeoutGateReceipt.defaultEngineMutationApplyGateId,
            closeoutGateReceipt.defaultEngineMutationDryRunId,
            closeoutGateReceipt.defaultEngineMutationCommitPlanId,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            "blocked-runtime-default-path-mutation-closeout-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-closeout-gate-before-handoff-gate",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationCloseoutGateReceiptBlockers(
                closeoutGateReceipt
            ),
            nonClaims,
            closeoutGateReceipt.nextAction,
            "QUIC must not consume rejected runtime default-path mutation closeout-gate receipts for stream default mutation"
        )
    }

    JinguiAcceptedTransportH2RuntimeDefaultPathMutationCloseoutGateBridge(
        true,
        true,
        true,
        closeoutGateReceipt.runtimeDefaultPathMutationCloseoutGateAllowed,
        true,
        closeoutGateReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyMode,
        closeoutGateReceipt.runtimeDefaultPathMutationCloseoutGateMode,
        closeoutGateReceipt.runtimeDefaultPathMutationCloseoutGateId,
        closeoutGateReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyId,
        closeoutGateReceipt.runtimeDefaultPathMutationFinalizationGateId,
        closeoutGateReceipt.runtimeDefaultPathMutationCommitBoundaryId,
        closeoutGateReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
        closeoutGateReceipt.runtimeDefaultPathMutationCommitApplyGateId,
        closeoutGateReceipt.runtimeDefaultPathMutationCommitDryRunId,
        closeoutGateReceipt.runtimeDefaultPathMutationCommitPlanId,
        closeoutGateReceipt.controlledRuntimeDefaultPathMutationApplyId,
        closeoutGateReceipt.runtimeDefaultPathMutationApplyGateId,
        closeoutGateReceipt.runtimeDefaultPathMutationDryRunId,
        closeoutGateReceipt.runtimeDefaultPathMutationGateId,
        closeoutGateReceipt.controlledDefaultEngineMutationApplyId,
        closeoutGateReceipt.defaultEngineMutationApplyGateId,
        closeoutGateReceipt.defaultEngineMutationDryRunId,
        closeoutGateReceipt.defaultEngineMutationCommitPlanId,
        closeoutGateReceipt.productionQueueMutationAllowed,
        closeoutGateReceipt.actualRuntimeTaskSpawnAllowed,
        closeoutGateReceipt.actualHandlerInvocationAllowed,
        closeoutGateReceipt.actualRequestContextMutationAllowed,
        closeoutGateReceipt.actualResponseWriteAllowed,
        closeoutGateReceipt.actualTransportCommitAllowed,
        closeoutGateReceipt.actualLiveServerWiringAllowed,
        closeoutGateReceipt.actualDefaultEngineFlipAllowed,
        closeoutGateReceipt.defaultEngineConfigMutationAllowed,
        closeoutGateReceipt.runtimeDefaultPathMutationAllowed,
        closeoutGateReceipt.publicReleaseAllowed,
        closeoutGateReceipt.stdxRemovalAllowed,
        false,
        "accepted-h2-runtime-default-path-mutation-closeout-gate-bridge",
        "record-h2-runtime-default-path-mutation-closeout-gate-without-runtime-default-mutation",
        [],
        nonClaims,
        "next packet may prove H2 runtime default-path mutation handoff gate; actual runtime default-path mutation, release, stdx removal, and H2 closure remain denied",
        "QUIC can reuse H2-style controlled-finalization-apply plus generic closeout-gate separation before runtime default mutation"
    )
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationCloseoutGateControlledApplyBlockers(
    bridge:
        JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationFinalizationApplyBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "H2_CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_FINALIZATION_APPLY:${bridge.status}"
    )
    for (blocker in bridge.blockers) {
        blockers.add(
            "H2_CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_FINALIZATION_APPLY_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationCloseoutGateReceiptBlockers(
    receipt: IgniteRuntimeDefaultPathMutationCloseoutGateReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "RUNTIME_DEFAULT_PATH_MUTATION_CLOSEOUT_GATE:${receipt.status}"
    )
    for (blocker in receipt.blockers) {
        blockers.add(
            "RUNTIME_DEFAULT_PATH_MUTATION_CLOSEOUT_GATE_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationCloseoutGateNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION_HANDOFF_GATE",
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationHandoffGateEvidence {
    public let h2RuntimeDefaultPathMutationCloseoutGateBridge:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationCloseoutGateBridge
    public let runtimeDefaultPathMutationHandoffGateReceipt:
        IgniteRuntimeDefaultPathMutationHandoffGateReceipt

    public init(
        h2RuntimeDefaultPathMutationCloseoutGateBridge:
            JinguiAcceptedTransportH2RuntimeDefaultPathMutationCloseoutGateBridge,
        runtimeDefaultPathMutationHandoffGateReceipt:
            IgniteRuntimeDefaultPathMutationHandoffGateReceipt
    ) {
        this.h2RuntimeDefaultPathMutationCloseoutGateBridge =
            h2RuntimeDefaultPathMutationCloseoutGateBridge
        this.runtimeDefaultPathMutationHandoffGateReceipt =
            runtimeDefaultPathMutationHandoffGateReceipt
    }
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationHandoffGateBridge {
    public let h2RuntimeDefaultPathMutationHandoffGateAccepted: Bool
    public let h2RuntimeDefaultPathMutationCloseoutGateAccepted: Bool
    public let runtimeDefaultPathMutationHandoffGateAccepted: Bool
    public let runtimeDefaultPathMutationHandoffGateAllowed: Bool
    public let boundedRuntimeDefaultPathMutationHandoffGateFollowupAllowed: Bool
    public let runtimeDefaultPathMutationCloseoutGateMode: String
    public let runtimeDefaultPathMutationHandoffGateMode: String
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
    public let h2RuntimeClosureClaimAllowed: Bool
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2RuntimeDefaultPathMutationHandoffGateAccepted: Bool,
        h2RuntimeDefaultPathMutationCloseoutGateAccepted: Bool,
        runtimeDefaultPathMutationHandoffGateAccepted: Bool,
        runtimeDefaultPathMutationHandoffGateAllowed: Bool,
        boundedRuntimeDefaultPathMutationHandoffGateFollowupAllowed: Bool,
        runtimeDefaultPathMutationCloseoutGateMode: String,
        runtimeDefaultPathMutationHandoffGateMode: String,
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
        h2RuntimeClosureClaimAllowed: Bool,
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2RuntimeDefaultPathMutationHandoffGateAccepted =
            h2RuntimeDefaultPathMutationHandoffGateAccepted
        this.h2RuntimeDefaultPathMutationCloseoutGateAccepted =
            h2RuntimeDefaultPathMutationCloseoutGateAccepted
        this.runtimeDefaultPathMutationHandoffGateAccepted =
            runtimeDefaultPathMutationHandoffGateAccepted
        this.runtimeDefaultPathMutationHandoffGateAllowed =
            runtimeDefaultPathMutationHandoffGateAllowed
        this.boundedRuntimeDefaultPathMutationHandoffGateFollowupAllowed =
            boundedRuntimeDefaultPathMutationHandoffGateFollowupAllowed
        this.runtimeDefaultPathMutationCloseoutGateMode =
            runtimeDefaultPathMutationCloseoutGateMode
        this.runtimeDefaultPathMutationHandoffGateMode =
            runtimeDefaultPathMutationHandoffGateMode
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
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2RuntimeDefaultPathMutationHandoffGateBridge(
    evidence: JinguiAcceptedTransportH2RuntimeDefaultPathMutationHandoffGateEvidence
): JinguiAcceptedTransportH2RuntimeDefaultPathMutationHandoffGateBridge {
    let h2CloseoutGateBridge =
        evidence.h2RuntimeDefaultPathMutationCloseoutGateBridge
    let handoffGateReceipt =
        evidence.runtimeDefaultPathMutationHandoffGateReceipt
    let nonClaims =
        jinguiAcceptedTransportH2RuntimeDefaultPathMutationHandoffGateNonClaims()
    if (
        !h2CloseoutGateBridge.h2RuntimeDefaultPathMutationCloseoutGateAccepted ||
        !h2CloseoutGateBridge.boundedRuntimeDefaultPathMutationCloseoutGateFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationHandoffGateBridge(
            false,
            h2CloseoutGateBridge.h2RuntimeDefaultPathMutationCloseoutGateAccepted,
            handoffGateReceipt.runtimeDefaultPathMutationHandoffGateAccepted,
            false,
            false,
            handoffGateReceipt.runtimeDefaultPathMutationCloseoutGateMode,
            handoffGateReceipt.runtimeDefaultPathMutationHandoffGateMode,
            handoffGateReceipt.runtimeDefaultPathMutationHandoffGateId,
            handoffGateReceipt.runtimeDefaultPathMutationCloseoutGateId,
            handoffGateReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyId,
            handoffGateReceipt.runtimeDefaultPathMutationFinalizationGateId,
            handoffGateReceipt.runtimeDefaultPathMutationCommitBoundaryId,
            handoffGateReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
            handoffGateReceipt.runtimeDefaultPathMutationCommitApplyGateId,
            handoffGateReceipt.runtimeDefaultPathMutationCommitDryRunId,
            handoffGateReceipt.runtimeDefaultPathMutationCommitPlanId,
            handoffGateReceipt.controlledRuntimeDefaultPathMutationApplyId,
            handoffGateReceipt.runtimeDefaultPathMutationApplyGateId,
            handoffGateReceipt.runtimeDefaultPathMutationDryRunId,
            handoffGateReceipt.runtimeDefaultPathMutationGateId,
            handoffGateReceipt.controlledDefaultEngineMutationApplyId,
            handoffGateReceipt.defaultEngineMutationApplyGateId,
            handoffGateReceipt.defaultEngineMutationDryRunId,
            handoffGateReceipt.defaultEngineMutationCommitPlanId,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            "blocked-h2-runtime-default-path-mutation-closeout-gate-bridge",
            "collect-accepted-h2-runtime-default-path-mutation-closeout-gate-before-handoff-gate",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationHandoffGateCloseoutBlockers(
                h2CloseoutGateBridge
            ),
            nonClaims,
            "repair H2 runtime default-path mutation closeout-gate bridge before handoff gate; do not treat generic handoff receipts as H2 runtime mutation",
            "QUIC must pass stream default mutation closeout gate before runtime default mutation handoff gate"
        )
    }
    if (
        !handoffGateReceipt.runtimeDefaultPathMutationHandoffGateAccepted ||
        !handoffGateReceipt.runtimeDefaultPathMutationHandoffGateAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationHandoffGateBridge(
            false,
            true,
            handoffGateReceipt.runtimeDefaultPathMutationHandoffGateAccepted,
            handoffGateReceipt.runtimeDefaultPathMutationHandoffGateAllowed,
            false,
            handoffGateReceipt.runtimeDefaultPathMutationCloseoutGateMode,
            handoffGateReceipt.runtimeDefaultPathMutationHandoffGateMode,
            handoffGateReceipt.runtimeDefaultPathMutationHandoffGateId,
            handoffGateReceipt.runtimeDefaultPathMutationCloseoutGateId,
            handoffGateReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyId,
            handoffGateReceipt.runtimeDefaultPathMutationFinalizationGateId,
            handoffGateReceipt.runtimeDefaultPathMutationCommitBoundaryId,
            handoffGateReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
            handoffGateReceipt.runtimeDefaultPathMutationCommitApplyGateId,
            handoffGateReceipt.runtimeDefaultPathMutationCommitDryRunId,
            handoffGateReceipt.runtimeDefaultPathMutationCommitPlanId,
            handoffGateReceipt.controlledRuntimeDefaultPathMutationApplyId,
            handoffGateReceipt.runtimeDefaultPathMutationApplyGateId,
            handoffGateReceipt.runtimeDefaultPathMutationDryRunId,
            handoffGateReceipt.runtimeDefaultPathMutationGateId,
            handoffGateReceipt.controlledDefaultEngineMutationApplyId,
            handoffGateReceipt.defaultEngineMutationApplyGateId,
            handoffGateReceipt.defaultEngineMutationDryRunId,
            handoffGateReceipt.defaultEngineMutationCommitPlanId,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            "blocked-runtime-default-path-mutation-handoff-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-handoff-gate-before-acceptance-boundary",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationHandoffGateReceiptBlockers(
                handoffGateReceipt
            ),
            nonClaims,
            handoffGateReceipt.nextAction,
            "QUIC must not consume rejected runtime default-path mutation handoff-gate receipts for stream default mutation"
        )
    }

    JinguiAcceptedTransportH2RuntimeDefaultPathMutationHandoffGateBridge(
        true,
        true,
        true,
        handoffGateReceipt.runtimeDefaultPathMutationHandoffGateAllowed,
        true,
        handoffGateReceipt.runtimeDefaultPathMutationCloseoutGateMode,
        handoffGateReceipt.runtimeDefaultPathMutationHandoffGateMode,
        handoffGateReceipt.runtimeDefaultPathMutationHandoffGateId,
        handoffGateReceipt.runtimeDefaultPathMutationCloseoutGateId,
        handoffGateReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyId,
        handoffGateReceipt.runtimeDefaultPathMutationFinalizationGateId,
        handoffGateReceipt.runtimeDefaultPathMutationCommitBoundaryId,
        handoffGateReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
        handoffGateReceipt.runtimeDefaultPathMutationCommitApplyGateId,
        handoffGateReceipt.runtimeDefaultPathMutationCommitDryRunId,
        handoffGateReceipt.runtimeDefaultPathMutationCommitPlanId,
        handoffGateReceipt.controlledRuntimeDefaultPathMutationApplyId,
        handoffGateReceipt.runtimeDefaultPathMutationApplyGateId,
        handoffGateReceipt.runtimeDefaultPathMutationDryRunId,
        handoffGateReceipt.runtimeDefaultPathMutationGateId,
        handoffGateReceipt.controlledDefaultEngineMutationApplyId,
        handoffGateReceipt.defaultEngineMutationApplyGateId,
        handoffGateReceipt.defaultEngineMutationDryRunId,
        handoffGateReceipt.defaultEngineMutationCommitPlanId,
        handoffGateReceipt.productionQueueMutationAllowed,
        handoffGateReceipt.actualRuntimeTaskSpawnAllowed,
        handoffGateReceipt.actualHandlerInvocationAllowed,
        handoffGateReceipt.actualRequestContextMutationAllowed,
        handoffGateReceipt.actualResponseWriteAllowed,
        handoffGateReceipt.actualTransportCommitAllowed,
        handoffGateReceipt.actualLiveServerWiringAllowed,
        handoffGateReceipt.actualDefaultEngineFlipAllowed,
        handoffGateReceipt.defaultEngineConfigMutationAllowed,
        handoffGateReceipt.runtimeDefaultPathMutationAllowed,
        handoffGateReceipt.publicReleaseAllowed,
        handoffGateReceipt.stdxRemovalAllowed,
        false,
        "accepted-h2-runtime-default-path-mutation-handoff-gate-bridge",
        "record-h2-runtime-default-path-mutation-handoff-gate-without-runtime-default-mutation",
        [],
        nonClaims,
        "next packet may prove H2 runtime default-path mutation acceptance boundary; actual runtime default-path mutation, release, stdx removal, and H2 closure remain denied",
        "QUIC can reuse H2-style closeout-gate plus generic handoff-gate separation before runtime default mutation"
    )
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationHandoffGateCloseoutBlockers(
    bridge: JinguiAcceptedTransportH2RuntimeDefaultPathMutationCloseoutGateBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "H2_RUNTIME_DEFAULT_PATH_MUTATION_CLOSEOUT_GATE:${bridge.status}"
    )
    for (blocker in bridge.blockers) {
        blockers.add(
            "H2_RUNTIME_DEFAULT_PATH_MUTATION_CLOSEOUT_GATE_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationHandoffGateReceiptBlockers(
    receipt: IgniteRuntimeDefaultPathMutationHandoffGateReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "RUNTIME_DEFAULT_PATH_MUTATION_HANDOFF_GATE:${receipt.status}"
    )
    for (blocker in receipt.blockers) {
        blockers.add(
            "RUNTIME_DEFAULT_PATH_MUTATION_HANDOFF_GATE_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationHandoffGateNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION_ACCEPTANCE_BOUNDARY",
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationAcceptanceBoundaryEvidence {
    public let h2RuntimeDefaultPathMutationHandoffGateBridge:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationHandoffGateBridge
    public let runtimeDefaultPathMutationAcceptanceBoundaryReceipt:
        IgniteRuntimeDefaultPathMutationAcceptanceBoundaryReceipt

    public init(
        h2RuntimeDefaultPathMutationHandoffGateBridge:
            JinguiAcceptedTransportH2RuntimeDefaultPathMutationHandoffGateBridge,
        runtimeDefaultPathMutationAcceptanceBoundaryReceipt:
            IgniteRuntimeDefaultPathMutationAcceptanceBoundaryReceipt
    ) {
        this.h2RuntimeDefaultPathMutationHandoffGateBridge =
            h2RuntimeDefaultPathMutationHandoffGateBridge
        this.runtimeDefaultPathMutationAcceptanceBoundaryReceipt =
            runtimeDefaultPathMutationAcceptanceBoundaryReceipt
    }
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationAcceptanceBoundaryBridge {
    public let h2RuntimeDefaultPathMutationAcceptanceBoundaryAccepted: Bool
    public let h2RuntimeDefaultPathMutationHandoffGateAccepted: Bool
    public let runtimeDefaultPathMutationAcceptanceBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationAcceptanceBoundaryAllowed: Bool
    public let boundedRuntimeDefaultPathMutationAcceptanceBoundaryFollowupAllowed: Bool
    public let runtimeDefaultPathMutationAcceptanceBoundaryMode: String
    public let runtimeDefaultPathMutationAcceptanceBoundaryId: String
    public let runtimeDefaultPathMutationHandoffGateId: String
    public let runtimeDefaultPathMutationCloseoutGateId: String
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
    public let h2RuntimeClosureClaimAllowed: Bool
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2RuntimeDefaultPathMutationAcceptanceBoundaryAccepted: Bool,
        h2RuntimeDefaultPathMutationHandoffGateAccepted: Bool,
        runtimeDefaultPathMutationAcceptanceBoundaryAccepted: Bool,
        runtimeDefaultPathMutationAcceptanceBoundaryAllowed: Bool,
        boundedRuntimeDefaultPathMutationAcceptanceBoundaryFollowupAllowed: Bool,
        runtimeDefaultPathMutationAcceptanceBoundaryMode: String,
        runtimeDefaultPathMutationAcceptanceBoundaryId: String,
        runtimeDefaultPathMutationHandoffGateId: String,
        runtimeDefaultPathMutationCloseoutGateId: String,
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
        h2RuntimeClosureClaimAllowed: Bool,
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2RuntimeDefaultPathMutationAcceptanceBoundaryAccepted =
            h2RuntimeDefaultPathMutationAcceptanceBoundaryAccepted
        this.h2RuntimeDefaultPathMutationHandoffGateAccepted =
            h2RuntimeDefaultPathMutationHandoffGateAccepted
        this.runtimeDefaultPathMutationAcceptanceBoundaryAccepted =
            runtimeDefaultPathMutationAcceptanceBoundaryAccepted
        this.runtimeDefaultPathMutationAcceptanceBoundaryAllowed =
            runtimeDefaultPathMutationAcceptanceBoundaryAllowed
        this.boundedRuntimeDefaultPathMutationAcceptanceBoundaryFollowupAllowed =
            boundedRuntimeDefaultPathMutationAcceptanceBoundaryFollowupAllowed
        this.runtimeDefaultPathMutationAcceptanceBoundaryMode =
            runtimeDefaultPathMutationAcceptanceBoundaryMode
        this.runtimeDefaultPathMutationAcceptanceBoundaryId =
            runtimeDefaultPathMutationAcceptanceBoundaryId
        this.runtimeDefaultPathMutationHandoffGateId =
            runtimeDefaultPathMutationHandoffGateId
        this.runtimeDefaultPathMutationCloseoutGateId =
            runtimeDefaultPathMutationCloseoutGateId
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
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2RuntimeDefaultPathMutationAcceptanceBoundaryBridge(
    evidence: JinguiAcceptedTransportH2RuntimeDefaultPathMutationAcceptanceBoundaryEvidence
): JinguiAcceptedTransportH2RuntimeDefaultPathMutationAcceptanceBoundaryBridge {
    let h2HandoffGateBridge =
        evidence.h2RuntimeDefaultPathMutationHandoffGateBridge
    let acceptanceBoundaryReceipt =
        evidence.runtimeDefaultPathMutationAcceptanceBoundaryReceipt
    let nonClaims =
        jinguiAcceptedTransportH2RuntimeDefaultPathMutationAcceptanceBoundaryNonClaims()
    if (
        !h2HandoffGateBridge.h2RuntimeDefaultPathMutationHandoffGateAccepted ||
        !h2HandoffGateBridge.boundedRuntimeDefaultPathMutationHandoffGateFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationAcceptanceBoundaryBridge(
            false,
            h2HandoffGateBridge.h2RuntimeDefaultPathMutationHandoffGateAccepted,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationAcceptanceBoundaryAccepted,
            false,
            false,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationAcceptanceBoundaryMode,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationAcceptanceBoundaryId,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationHandoffGateId,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationCloseoutGateId,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            "blocked-h2-runtime-default-path-mutation-handoff-gate-bridge",
            "collect-accepted-h2-runtime-default-path-mutation-handoff-gate-before-acceptance-boundary",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationAcceptanceBoundaryHandoffBlockers(
                h2HandoffGateBridge
            ),
            nonClaims,
            "repair H2 runtime default-path mutation handoff-gate bridge before acceptance boundary; do not treat generic acceptance receipts as H2 runtime mutation",
            "QUIC must pass stream default mutation handoff gate before runtime default mutation acceptance boundary"
        )
    }
    if (
        !acceptanceBoundaryReceipt.runtimeDefaultPathMutationAcceptanceBoundaryAccepted ||
        !acceptanceBoundaryReceipt.runtimeDefaultPathMutationAcceptanceBoundaryAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationAcceptanceBoundaryBridge(
            false,
            true,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationAcceptanceBoundaryAccepted,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationAcceptanceBoundaryAllowed,
            false,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationAcceptanceBoundaryMode,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationAcceptanceBoundaryId,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationHandoffGateId,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationCloseoutGateId,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            "blocked-runtime-default-path-mutation-acceptance-boundary-receipt",
            "collect-accepted-runtime-default-path-mutation-acceptance-boundary-before-apply-boundary",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationAcceptanceBoundaryReceiptBlockers(
                acceptanceBoundaryReceipt
            ),
            nonClaims,
            acceptanceBoundaryReceipt.nextAction,
            "QUIC must not consume rejected runtime default-path mutation acceptance-boundary receipts for stream default mutation"
        )
    }

    JinguiAcceptedTransportH2RuntimeDefaultPathMutationAcceptanceBoundaryBridge(
        true,
        true,
        true,
        acceptanceBoundaryReceipt.runtimeDefaultPathMutationAcceptanceBoundaryAllowed,
        true,
        acceptanceBoundaryReceipt.runtimeDefaultPathMutationAcceptanceBoundaryMode,
        acceptanceBoundaryReceipt.runtimeDefaultPathMutationAcceptanceBoundaryId,
        acceptanceBoundaryReceipt.runtimeDefaultPathMutationHandoffGateId,
        acceptanceBoundaryReceipt.runtimeDefaultPathMutationCloseoutGateId,
        acceptanceBoundaryReceipt.productionQueueMutationAllowed,
        acceptanceBoundaryReceipt.actualRuntimeTaskSpawnAllowed,
        acceptanceBoundaryReceipt.actualHandlerInvocationAllowed,
        acceptanceBoundaryReceipt.actualRequestContextMutationAllowed,
        acceptanceBoundaryReceipt.actualResponseWriteAllowed,
        acceptanceBoundaryReceipt.actualTransportCommitAllowed,
        acceptanceBoundaryReceipt.actualLiveServerWiringAllowed,
        acceptanceBoundaryReceipt.actualDefaultEngineFlipAllowed,
        acceptanceBoundaryReceipt.defaultEngineConfigMutationAllowed,
        acceptanceBoundaryReceipt.runtimeDefaultPathMutationAllowed,
        acceptanceBoundaryReceipt.publicReleaseAllowed,
        acceptanceBoundaryReceipt.stdxRemovalAllowed,
        false,
        "accepted-h2-runtime-default-path-mutation-acceptance-boundary-bridge",
        "record-h2-runtime-default-path-mutation-acceptance-boundary-without-runtime-default-mutation",
        [],
        nonClaims,
        "next packet may prove H2 runtime default-path mutation apply boundary; actual runtime default-path mutation, release, stdx removal, and H2 closure remain denied",
        "QUIC can reuse H2-style handoff-gate plus generic acceptance-boundary separation before runtime default mutation"
    )
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationAcceptanceBoundaryHandoffBlockers(
    bridge: JinguiAcceptedTransportH2RuntimeDefaultPathMutationHandoffGateBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "H2_RUNTIME_DEFAULT_PATH_MUTATION_HANDOFF_GATE:${bridge.status}"
    )
    for (blocker in bridge.blockers) {
        blockers.add(
            "H2_RUNTIME_DEFAULT_PATH_MUTATION_HANDOFF_GATE_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationAcceptanceBoundaryReceiptBlockers(
    receipt: IgniteRuntimeDefaultPathMutationAcceptanceBoundaryReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "RUNTIME_DEFAULT_PATH_MUTATION_ACCEPTANCE_BOUNDARY:${receipt.status}"
    )
    for (blocker in receipt.blockers) {
        blockers.add(
            "RUNTIME_DEFAULT_PATH_MUTATION_ACCEPTANCE_BOUNDARY_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationAcceptanceBoundaryNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_BOUNDARY",
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyBoundaryEvidence {
    public let h2RuntimeDefaultPathMutationAcceptanceBoundaryBridge:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationAcceptanceBoundaryBridge
    public let runtimeDefaultPathMutationApplyBoundaryReceipt:
        IgniteRuntimeDefaultPathMutationApplyBoundaryReceipt

    public init(
        h2RuntimeDefaultPathMutationAcceptanceBoundaryBridge:
            JinguiAcceptedTransportH2RuntimeDefaultPathMutationAcceptanceBoundaryBridge,
        runtimeDefaultPathMutationApplyBoundaryReceipt:
            IgniteRuntimeDefaultPathMutationApplyBoundaryReceipt
    ) {
        this.h2RuntimeDefaultPathMutationAcceptanceBoundaryBridge =
            h2RuntimeDefaultPathMutationAcceptanceBoundaryBridge
        this.runtimeDefaultPathMutationApplyBoundaryReceipt =
            runtimeDefaultPathMutationApplyBoundaryReceipt
    }
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyBoundaryBridge {
    public let h2RuntimeDefaultPathMutationApplyBoundaryAccepted: Bool
    public let h2RuntimeDefaultPathMutationAcceptanceBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationApplyBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationApplyBoundaryAllowed: Bool
    public let boundedRuntimeDefaultPathMutationApplyBoundaryFollowupAllowed: Bool
    public let runtimeDefaultPathMutationApplyBoundaryMode: String
    public let runtimeDefaultPathMutationApplyBoundaryId: String
    public let runtimeDefaultPathMutationAcceptanceBoundaryId: String
    public let runtimeDefaultPathMutationHandoffGateId: String
    public let runtimeDefaultPathMutationCloseoutGateId: String
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2RuntimeDefaultPathMutationApplyBoundaryAccepted: Bool,
        h2RuntimeDefaultPathMutationAcceptanceBoundaryAccepted: Bool,
        runtimeDefaultPathMutationApplyBoundaryAccepted: Bool,
        runtimeDefaultPathMutationApplyBoundaryAllowed: Bool,
        boundedRuntimeDefaultPathMutationApplyBoundaryFollowupAllowed: Bool,
        runtimeDefaultPathMutationApplyBoundaryMode: String,
        runtimeDefaultPathMutationApplyBoundaryId: String,
        runtimeDefaultPathMutationAcceptanceBoundaryId: String,
        runtimeDefaultPathMutationHandoffGateId: String,
        runtimeDefaultPathMutationCloseoutGateId: String,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2RuntimeDefaultPathMutationApplyBoundaryAccepted =
            h2RuntimeDefaultPathMutationApplyBoundaryAccepted
        this.h2RuntimeDefaultPathMutationAcceptanceBoundaryAccepted =
            h2RuntimeDefaultPathMutationAcceptanceBoundaryAccepted
        this.runtimeDefaultPathMutationApplyBoundaryAccepted =
            runtimeDefaultPathMutationApplyBoundaryAccepted
        this.runtimeDefaultPathMutationApplyBoundaryAllowed =
            runtimeDefaultPathMutationApplyBoundaryAllowed
        this.boundedRuntimeDefaultPathMutationApplyBoundaryFollowupAllowed =
            boundedRuntimeDefaultPathMutationApplyBoundaryFollowupAllowed
        this.runtimeDefaultPathMutationApplyBoundaryMode =
            runtimeDefaultPathMutationApplyBoundaryMode
        this.runtimeDefaultPathMutationApplyBoundaryId =
            runtimeDefaultPathMutationApplyBoundaryId
        this.runtimeDefaultPathMutationAcceptanceBoundaryId =
            runtimeDefaultPathMutationAcceptanceBoundaryId
        this.runtimeDefaultPathMutationHandoffGateId =
            runtimeDefaultPathMutationHandoffGateId
        this.runtimeDefaultPathMutationCloseoutGateId =
            runtimeDefaultPathMutationCloseoutGateId
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyBoundaryBridge(
    evidence: JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyBoundaryEvidence
): JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyBoundaryBridge {
    let h2AcceptanceBoundaryBridge =
        evidence.h2RuntimeDefaultPathMutationAcceptanceBoundaryBridge
    let applyBoundaryReceipt =
        evidence.runtimeDefaultPathMutationApplyBoundaryReceipt
    let nonClaims =
        jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyBoundaryNonClaims()
    if (
        !h2AcceptanceBoundaryBridge.h2RuntimeDefaultPathMutationAcceptanceBoundaryAccepted ||
        !h2AcceptanceBoundaryBridge.boundedRuntimeDefaultPathMutationAcceptanceBoundaryFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyBoundaryBridge(
            false,
            h2AcceptanceBoundaryBridge.h2RuntimeDefaultPathMutationAcceptanceBoundaryAccepted,
            applyBoundaryReceipt.runtimeDefaultPathMutationApplyBoundaryAccepted,
            false,
            false,
            applyBoundaryReceipt.runtimeDefaultPathMutationApplyBoundaryMode,
            applyBoundaryReceipt.runtimeDefaultPathMutationApplyBoundaryId,
            applyBoundaryReceipt.runtimeDefaultPathMutationAcceptanceBoundaryId,
            applyBoundaryReceipt.runtimeDefaultPathMutationHandoffGateId,
            applyBoundaryReceipt.runtimeDefaultPathMutationCloseoutGateId,
            false,
            false,
            false,
            false,
            "blocked-h2-runtime-default-path-mutation-acceptance-boundary-bridge",
            "collect-accepted-h2-runtime-default-path-mutation-acceptance-boundary-before-apply-boundary",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyBoundaryAcceptanceBlockers(
                h2AcceptanceBoundaryBridge
            ),
            nonClaims,
            "repair H2 runtime default-path mutation acceptance-boundary bridge before apply boundary; do not treat generic apply receipts as H2 runtime mutation",
            "QUIC must pass stream default mutation acceptance boundary before runtime default mutation apply boundary"
        )
    }
    if (
        !applyBoundaryReceipt.runtimeDefaultPathMutationApplyBoundaryAccepted ||
        !applyBoundaryReceipt.runtimeDefaultPathMutationApplyBoundaryAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyBoundaryBridge(
            false,
            true,
            applyBoundaryReceipt.runtimeDefaultPathMutationApplyBoundaryAccepted,
            applyBoundaryReceipt.runtimeDefaultPathMutationApplyBoundaryAllowed,
            false,
            applyBoundaryReceipt.runtimeDefaultPathMutationApplyBoundaryMode,
            applyBoundaryReceipt.runtimeDefaultPathMutationApplyBoundaryId,
            applyBoundaryReceipt.runtimeDefaultPathMutationAcceptanceBoundaryId,
            applyBoundaryReceipt.runtimeDefaultPathMutationHandoffGateId,
            applyBoundaryReceipt.runtimeDefaultPathMutationCloseoutGateId,
            false,
            false,
            false,
            false,
            "blocked-runtime-default-path-mutation-apply-boundary-receipt",
            "collect-accepted-runtime-default-path-mutation-apply-boundary-before-apply-dry-run",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyBoundaryReceiptBlockers(
                applyBoundaryReceipt
            ),
            nonClaims,
            applyBoundaryReceipt.nextAction,
            "QUIC must not consume rejected runtime default-path mutation apply-boundary receipts for stream default mutation"
        )
    }

    JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyBoundaryBridge(
        true,
        true,
        true,
        applyBoundaryReceipt.runtimeDefaultPathMutationApplyBoundaryAllowed,
        true,
        applyBoundaryReceipt.runtimeDefaultPathMutationApplyBoundaryMode,
        applyBoundaryReceipt.runtimeDefaultPathMutationApplyBoundaryId,
        applyBoundaryReceipt.runtimeDefaultPathMutationAcceptanceBoundaryId,
        applyBoundaryReceipt.runtimeDefaultPathMutationHandoffGateId,
        applyBoundaryReceipt.runtimeDefaultPathMutationCloseoutGateId,
        applyBoundaryReceipt.runtimeDefaultPathMutationAllowed,
        applyBoundaryReceipt.publicReleaseAllowed,
        applyBoundaryReceipt.stdxRemovalAllowed,
        false,
        "accepted-h2-runtime-default-path-mutation-apply-boundary-bridge",
        "record-h2-runtime-default-path-mutation-apply-boundary-without-runtime-default-mutation",
        [],
        nonClaims,
        "next packet may prove H2 runtime default-path mutation apply dry-run; actual runtime default-path mutation, release, stdx removal, and H2 closure remain denied",
        "QUIC can reuse H2-style acceptance-boundary plus generic apply-boundary separation before runtime default mutation"
    )
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyBoundaryAcceptanceBlockers(
    bridge: JinguiAcceptedTransportH2RuntimeDefaultPathMutationAcceptanceBoundaryBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "H2_RUNTIME_DEFAULT_PATH_MUTATION_ACCEPTANCE_BOUNDARY:${bridge.status}"
    )
    for (blocker in bridge.blockers) {
        blockers.add(
            "H2_RUNTIME_DEFAULT_PATH_MUTATION_ACCEPTANCE_BOUNDARY_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyBoundaryReceiptBlockers(
    receipt: IgniteRuntimeDefaultPathMutationApplyBoundaryReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_BOUNDARY:${receipt.status}"
    )
    for (blocker in receipt.blockers) {
        blockers.add(
            "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_BOUNDARY_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyBoundaryNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN",
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunEvidence {
    public let h2RuntimeDefaultPathMutationApplyBoundaryBridge:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyBoundaryBridge
    public let runtimeDefaultPathMutationApplyDryRunReceipt:
        IgniteRuntimeDefaultPathMutationApplyDryRunReceipt

    public init(
        h2RuntimeDefaultPathMutationApplyBoundaryBridge:
            JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyBoundaryBridge,
        runtimeDefaultPathMutationApplyDryRunReceipt:
            IgniteRuntimeDefaultPathMutationApplyDryRunReceipt
    ) {
        this.h2RuntimeDefaultPathMutationApplyBoundaryBridge =
            h2RuntimeDefaultPathMutationApplyBoundaryBridge
        this.runtimeDefaultPathMutationApplyDryRunReceipt =
            runtimeDefaultPathMutationApplyDryRunReceipt
    }
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunBridge {
    public let h2RuntimeDefaultPathMutationApplyDryRunAccepted: Bool
    public let h2RuntimeDefaultPathMutationApplyBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAllowed: Bool
    public let boundedRuntimeDefaultPathMutationApplyDryRunFollowupAllowed: Bool
    public let runtimeDefaultPathMutationApplyDryRunMode: String
    public let runtimeDefaultPathMutationApplyDryRunId: String
    public let runtimeDefaultPathMutationApplyBoundaryId: String
    public let runtimeDefaultPathMutationAcceptanceBoundaryId: String
    public let runtimeDefaultPathMutationHandoffGateId: String
    public let runtimeDefaultPathMutationCloseoutGateId: String
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2RuntimeDefaultPathMutationApplyDryRunAccepted: Bool,
        h2RuntimeDefaultPathMutationApplyBoundaryAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAllowed: Bool,
        boundedRuntimeDefaultPathMutationApplyDryRunFollowupAllowed: Bool,
        runtimeDefaultPathMutationApplyDryRunMode: String,
        runtimeDefaultPathMutationApplyDryRunId: String,
        runtimeDefaultPathMutationApplyBoundaryId: String,
        runtimeDefaultPathMutationAcceptanceBoundaryId: String,
        runtimeDefaultPathMutationHandoffGateId: String,
        runtimeDefaultPathMutationCloseoutGateId: String,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2RuntimeDefaultPathMutationApplyDryRunAccepted =
            h2RuntimeDefaultPathMutationApplyDryRunAccepted
        this.h2RuntimeDefaultPathMutationApplyBoundaryAccepted =
            h2RuntimeDefaultPathMutationApplyBoundaryAccepted
        this.runtimeDefaultPathMutationApplyDryRunAccepted =
            runtimeDefaultPathMutationApplyDryRunAccepted
        this.runtimeDefaultPathMutationApplyDryRunAllowed =
            runtimeDefaultPathMutationApplyDryRunAllowed
        this.boundedRuntimeDefaultPathMutationApplyDryRunFollowupAllowed =
            boundedRuntimeDefaultPathMutationApplyDryRunFollowupAllowed
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
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunBridge(
    evidence: JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunEvidence
): JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunBridge {
    let h2ApplyBoundaryBridge =
        evidence.h2RuntimeDefaultPathMutationApplyBoundaryBridge
    let applyDryRunReceipt =
        evidence.runtimeDefaultPathMutationApplyDryRunReceipt
    let nonClaims =
        jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunNonClaims()
    if (
        !h2ApplyBoundaryBridge.h2RuntimeDefaultPathMutationApplyBoundaryAccepted ||
        !h2ApplyBoundaryBridge.boundedRuntimeDefaultPathMutationApplyBoundaryFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunBridge(
            false,
            h2ApplyBoundaryBridge.h2RuntimeDefaultPathMutationApplyBoundaryAccepted,
            applyDryRunReceipt.runtimeDefaultPathMutationApplyDryRunAccepted,
            false,
            false,
            applyDryRunReceipt.runtimeDefaultPathMutationApplyDryRunMode,
            applyDryRunReceipt.runtimeDefaultPathMutationApplyDryRunId,
            applyDryRunReceipt.runtimeDefaultPathMutationApplyBoundaryId,
            applyDryRunReceipt.runtimeDefaultPathMutationAcceptanceBoundaryId,
            applyDryRunReceipt.runtimeDefaultPathMutationHandoffGateId,
            applyDryRunReceipt.runtimeDefaultPathMutationCloseoutGateId,
            false,
            false,
            false,
            false,
            "blocked-h2-runtime-default-path-mutation-apply-boundary-bridge",
            "collect-accepted-h2-runtime-default-path-mutation-apply-boundary-before-apply-dry-run",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunApplyBoundaryBlockers(
                h2ApplyBoundaryBridge
            ),
            nonClaims,
            "repair H2 runtime default-path mutation apply-boundary bridge before apply dry-run; do not treat generic apply-dry-run receipts as H2 runtime mutation",
            "QUIC must pass stream default mutation apply boundary before runtime default mutation apply dry-run"
        )
    }
    if (
        !applyDryRunReceipt.runtimeDefaultPathMutationApplyDryRunAccepted ||
        !applyDryRunReceipt.runtimeDefaultPathMutationApplyDryRunAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunBridge(
            false,
            true,
            applyDryRunReceipt.runtimeDefaultPathMutationApplyDryRunAccepted,
            applyDryRunReceipt.runtimeDefaultPathMutationApplyDryRunAllowed,
            false,
            applyDryRunReceipt.runtimeDefaultPathMutationApplyDryRunMode,
            applyDryRunReceipt.runtimeDefaultPathMutationApplyDryRunId,
            applyDryRunReceipt.runtimeDefaultPathMutationApplyBoundaryId,
            applyDryRunReceipt.runtimeDefaultPathMutationAcceptanceBoundaryId,
            applyDryRunReceipt.runtimeDefaultPathMutationHandoffGateId,
            applyDryRunReceipt.runtimeDefaultPathMutationCloseoutGateId,
            false,
            false,
            false,
            false,
            "blocked-runtime-default-path-mutation-apply-dry-run-receipt",
            "collect-accepted-runtime-default-path-mutation-apply-dry-run-before-acceptance-gate",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunReceiptBlockers(
                applyDryRunReceipt
            ),
            nonClaims,
            applyDryRunReceipt.nextAction,
            "QUIC must not consume rejected runtime default-path mutation apply-dry-run receipts for stream default mutation"
        )
    }

    JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunBridge(
        true,
        true,
        true,
        applyDryRunReceipt.runtimeDefaultPathMutationApplyDryRunAllowed,
        true,
        applyDryRunReceipt.runtimeDefaultPathMutationApplyDryRunMode,
        applyDryRunReceipt.runtimeDefaultPathMutationApplyDryRunId,
        applyDryRunReceipt.runtimeDefaultPathMutationApplyBoundaryId,
        applyDryRunReceipt.runtimeDefaultPathMutationAcceptanceBoundaryId,
        applyDryRunReceipt.runtimeDefaultPathMutationHandoffGateId,
        applyDryRunReceipt.runtimeDefaultPathMutationCloseoutGateId,
        applyDryRunReceipt.runtimeDefaultPathMutationAllowed,
        applyDryRunReceipt.publicReleaseAllowed,
        applyDryRunReceipt.stdxRemovalAllowed,
        false,
        "accepted-h2-runtime-default-path-mutation-apply-dry-run-bridge",
        "record-h2-runtime-default-path-mutation-apply-dry-run-without-runtime-default-mutation",
        [],
        nonClaims,
        "next packet may prove H2 runtime default-path mutation apply-dry-run acceptance gate; actual runtime default-path mutation, release, stdx removal, and H2 closure remain denied",
        "QUIC can reuse H2-style apply-boundary plus generic apply-dry-run separation before runtime default mutation"
    )
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunApplyBoundaryBlockers(
    bridge: JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyBoundaryBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "H2_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_BOUNDARY:${bridge.status}"
    )
    for (blocker in bridge.blockers) {
        blockers.add(
            "H2_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_BOUNDARY_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunReceiptBlockers(
    receipt: IgniteRuntimeDefaultPathMutationApplyDryRunReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN:${receipt.status}"
    )
    for (blocker in receipt.blockers) {
        blockers.add(
            "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_GATE",
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceGateEvidence {
    public let h2RuntimeDefaultPathMutationApplyDryRunBridge:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunBridge
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceGateReceipt:
        IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceGateReceipt

    public init(
        h2RuntimeDefaultPathMutationApplyDryRunBridge:
            JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunBridge,
        runtimeDefaultPathMutationApplyDryRunAcceptanceGateReceipt:
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceGateReceipt
    ) {
        this.h2RuntimeDefaultPathMutationApplyDryRunBridge =
            h2RuntimeDefaultPathMutationApplyDryRunBridge
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceGateReceipt =
            runtimeDefaultPathMutationApplyDryRunAcceptanceGateReceipt
    }
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceGateBridge {
    public let h2RuntimeDefaultPathMutationApplyDryRunAcceptanceGateAccepted: Bool
    public let h2RuntimeDefaultPathMutationApplyDryRunAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceGateAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceGateAllowed: Bool
    public let boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceGateFollowupAllowed: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceGateMode: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String
    public let runtimeDefaultPathMutationApplyDryRunId: String
    public let runtimeDefaultPathMutationApplyBoundaryId: String
    public let runtimeDefaultPathMutationAcceptanceBoundaryId: String
    public let runtimeDefaultPathMutationHandoffGateId: String
    public let runtimeDefaultPathMutationCloseoutGateId: String
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2RuntimeDefaultPathMutationApplyDryRunAcceptanceGateAccepted: Bool,
        h2RuntimeDefaultPathMutationApplyDryRunAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceGateAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceGateAllowed: Bool,
        boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceGateFollowupAllowed: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceGateMode: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String,
        runtimeDefaultPathMutationApplyDryRunId: String,
        runtimeDefaultPathMutationApplyBoundaryId: String,
        runtimeDefaultPathMutationAcceptanceBoundaryId: String,
        runtimeDefaultPathMutationHandoffGateId: String,
        runtimeDefaultPathMutationCloseoutGateId: String,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceGateAccepted =
            h2RuntimeDefaultPathMutationApplyDryRunAcceptanceGateAccepted
        this.h2RuntimeDefaultPathMutationApplyDryRunAccepted =
            h2RuntimeDefaultPathMutationApplyDryRunAccepted
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceGateAccepted =
            runtimeDefaultPathMutationApplyDryRunAcceptanceGateAccepted
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceGateAllowed =
            runtimeDefaultPathMutationApplyDryRunAcceptanceGateAllowed
        this.boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceGateFollowupAllowed =
            boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceGateFollowupAllowed
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
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceGateBridge(
    evidence: JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceGateEvidence
): JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceGateBridge {
    let h2ApplyDryRunBridge =
        evidence.h2RuntimeDefaultPathMutationApplyDryRunBridge
    let acceptanceGateReceipt =
        evidence.runtimeDefaultPathMutationApplyDryRunAcceptanceGateReceipt
    let nonClaims =
        jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceGateNonClaims()
    if (
        !h2ApplyDryRunBridge.h2RuntimeDefaultPathMutationApplyDryRunAccepted ||
        !h2ApplyDryRunBridge.boundedRuntimeDefaultPathMutationApplyDryRunFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceGateBridge(
            false,
            h2ApplyDryRunBridge.h2RuntimeDefaultPathMutationApplyDryRunAccepted,
            acceptanceGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateAccepted,
            false,
            false,
            acceptanceGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateMode,
            acceptanceGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            acceptanceGateReceipt.runtimeDefaultPathMutationApplyDryRunId,
            acceptanceGateReceipt.runtimeDefaultPathMutationApplyBoundaryId,
            acceptanceGateReceipt.runtimeDefaultPathMutationAcceptanceBoundaryId,
            acceptanceGateReceipt.runtimeDefaultPathMutationHandoffGateId,
            acceptanceGateReceipt.runtimeDefaultPathMutationCloseoutGateId,
            false,
            false,
            false,
            false,
            "blocked-h2-runtime-default-path-mutation-apply-dry-run-bridge",
            "collect-accepted-h2-runtime-default-path-mutation-apply-dry-run-before-acceptance-gate",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceGateApplyDryRunBlockers(
                h2ApplyDryRunBridge
            ),
            nonClaims,
            "repair H2 runtime default-path mutation apply-dry-run bridge before apply-dry-run acceptance gate; do not treat generic acceptance-gate receipts as H2 runtime mutation",
            "QUIC must pass stream default mutation apply dry-run before runtime default mutation apply-dry-run acceptance gate"
        )
    }
    if (
        !acceptanceGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateAccepted ||
        !acceptanceGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceGateBridge(
            false,
            true,
            acceptanceGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateAccepted,
            acceptanceGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateAllowed,
            false,
            acceptanceGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateMode,
            acceptanceGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            acceptanceGateReceipt.runtimeDefaultPathMutationApplyDryRunId,
            acceptanceGateReceipt.runtimeDefaultPathMutationApplyBoundaryId,
            acceptanceGateReceipt.runtimeDefaultPathMutationAcceptanceBoundaryId,
            acceptanceGateReceipt.runtimeDefaultPathMutationHandoffGateId,
            acceptanceGateReceipt.runtimeDefaultPathMutationCloseoutGateId,
            false,
            false,
            false,
            false,
            "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-apply-dry-run-acceptance-gate-before-controlled-acceptance",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceGateReceiptBlockers(
                acceptanceGateReceipt
            ),
            nonClaims,
            acceptanceGateReceipt.nextAction,
            "QUIC must not consume rejected runtime default-path mutation apply-dry-run acceptance-gate receipts for stream default mutation"
        )
    }

    JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceGateBridge(
        true,
        true,
        true,
        acceptanceGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateAllowed,
        true,
        acceptanceGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateMode,
        acceptanceGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
        acceptanceGateReceipt.runtimeDefaultPathMutationApplyDryRunId,
        acceptanceGateReceipt.runtimeDefaultPathMutationApplyBoundaryId,
        acceptanceGateReceipt.runtimeDefaultPathMutationAcceptanceBoundaryId,
        acceptanceGateReceipt.runtimeDefaultPathMutationHandoffGateId,
        acceptanceGateReceipt.runtimeDefaultPathMutationCloseoutGateId,
        acceptanceGateReceipt.runtimeDefaultPathMutationAllowed,
        acceptanceGateReceipt.publicReleaseAllowed,
        acceptanceGateReceipt.stdxRemovalAllowed,
        false,
        "accepted-h2-runtime-default-path-mutation-apply-dry-run-acceptance-gate-bridge",
        "record-h2-runtime-default-path-mutation-apply-dry-run-acceptance-gate-without-runtime-default-mutation",
        [],
        nonClaims,
        "next packet may prove H2 controlled runtime default-path mutation apply-dry-run acceptance; actual runtime default-path mutation, release, stdx removal, and H2 closure remain denied",
        "QUIC can reuse H2-style apply-dry-run plus generic apply-dry-run acceptance-gate separation before runtime default mutation"
    )
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceGateApplyDryRunBlockers(
    bridge: JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "H2_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN:${bridge.status}"
    )
    for (blocker in bridge.blockers) {
        blockers.add(
            "H2_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceGateReceiptBlockers(
    receipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceGateReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_GATE:${receipt.status}"
    )
    for (blocker in receipt.blockers) {
        blockers.add(
            "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_GATE_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceGateNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE",
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceEvidence {
    public let h2RuntimeDefaultPathMutationApplyDryRunAcceptanceGateBridge:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceGateBridge
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceReceipt:
        IgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceReceipt

    public init(
        h2RuntimeDefaultPathMutationApplyDryRunAcceptanceGateBridge:
            JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceGateBridge,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceReceipt:
            IgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceReceipt
    ) {
        this.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceGateBridge =
            h2RuntimeDefaultPathMutationApplyDryRunAcceptanceGateBridge
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceReceipt =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceReceipt
    }
}

public class JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceBridge {
    public let h2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAccepted: Bool
    public let h2RuntimeDefaultPathMutationApplyDryRunAcceptanceGateAccepted: Bool
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAccepted: Bool
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAllowed: Bool
    public let boundedControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceFollowupAllowed: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceGateMode: String
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceMode: String
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String
    public let runtimeDefaultPathMutationApplyDryRunId: String
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAccepted: Bool,
        h2RuntimeDefaultPathMutationApplyDryRunAcceptanceGateAccepted: Bool,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAccepted: Bool,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAllowed: Bool,
        boundedControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceFollowupAllowed: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceGateMode: String,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceMode: String,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String,
        runtimeDefaultPathMutationApplyDryRunId: String,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAccepted =
            h2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAccepted
        this.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceGateAccepted =
            h2RuntimeDefaultPathMutationApplyDryRunAcceptanceGateAccepted
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAccepted =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAccepted
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAllowed =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAllowed
        this.boundedControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceFollowupAllowed =
            boundedControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceFollowupAllowed
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
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceBridge(
    evidence:
        JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceEvidence
): JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceBridge {
    let h2AcceptanceGateBridge =
        evidence.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceGateBridge
    let controlledAcceptanceReceipt =
        evidence.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceReceipt
    let nonClaims =
        jinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceNonClaims()
    if (
        !h2AcceptanceGateBridge.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceGateAccepted ||
        !h2AcceptanceGateBridge.boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceGateFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceBridge(
            false,
            h2AcceptanceGateBridge.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceGateAccepted,
            controlledAcceptanceReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAccepted,
            false,
            false,
            controlledAcceptanceReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateMode,
            controlledAcceptanceReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceMode,
            controlledAcceptanceReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            controlledAcceptanceReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            controlledAcceptanceReceipt.runtimeDefaultPathMutationApplyDryRunId,
            false,
            false,
            false,
            false,
            "blocked-h2-runtime-default-path-mutation-apply-dry-run-acceptance-gate-bridge",
            "collect-accepted-h2-runtime-default-path-mutation-apply-dry-run-acceptance-gate-before-controlled-acceptance",
            jinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceGateBlockers(
                h2AcceptanceGateBridge
            ),
            nonClaims,
            "repair H2 runtime default-path mutation apply-dry-run acceptance-gate bridge before controlled apply-dry-run acceptance; do not treat generic controlled acceptance receipts as H2 runtime mutation",
            "QUIC must pass stream default mutation apply-dry-run acceptance gate before controlled runtime default mutation apply-dry-run acceptance"
        )
    }
    if (
        !controlledAcceptanceReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAccepted ||
        !controlledAcceptanceReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAllowed
    ) {
        return JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceBridge(
            false,
            true,
            controlledAcceptanceReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAccepted,
            controlledAcceptanceReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAllowed,
            false,
            controlledAcceptanceReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateMode,
            controlledAcceptanceReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceMode,
            controlledAcceptanceReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            controlledAcceptanceReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            controlledAcceptanceReceipt.runtimeDefaultPathMutationApplyDryRunId,
            false,
            false,
            false,
            false,
            "blocked-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-receipt",
            "collect-accepted-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-before-acceptance-boundary",
            jinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceReceiptBlockers(
                controlledAcceptanceReceipt
            ),
            nonClaims,
            controlledAcceptanceReceipt.nextAction,
            "QUIC must not consume rejected controlled runtime default-path mutation apply-dry-run acceptance receipts for stream default mutation"
        )
    }

    JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceBridge(
        true,
        true,
        true,
        controlledAcceptanceReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAllowed,
        true,
        controlledAcceptanceReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateMode,
        controlledAcceptanceReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceMode,
        controlledAcceptanceReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
        controlledAcceptanceReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
        controlledAcceptanceReceipt.runtimeDefaultPathMutationApplyDryRunId,
        controlledAcceptanceReceipt.runtimeDefaultPathMutationAllowed,
        controlledAcceptanceReceipt.publicReleaseAllowed,
        controlledAcceptanceReceipt.stdxRemovalAllowed,
        false,
        "accepted-h2-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-bridge",
        "record-h2-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-without-runtime-default-mutation",
        [],
        nonClaims,
        "next packet may prove H2 runtime default-path mutation apply-dry-run acceptance boundary; actual runtime default-path mutation, release, stdx removal, and H2 closure remain denied",
        "QUIC can reuse H2-style acceptance-gate plus generic controlled-acceptance separation before runtime default mutation"
    )
}

func jinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceGateBlockers(
    bridge: JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceGateBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "H2_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_GATE:${bridge.status}"
    )
    for (blocker in bridge.blockers) {
        blockers.add(
            "H2_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_GATE_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceReceiptBlockers(
    receipt: IgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE:${receipt.status}"
    )
    for (blocker in receipt.blockers) {
        blockers.add(
            "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_BOUNDARY",
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryEvidence {
    public let h2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceBridge:
        JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceBridge
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryReceipt:
        IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryReceipt

    public init(
        h2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceBridge:
            JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceBridge,
        runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryReceipt:
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryReceipt
    ) {
        this.h2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceBridge =
            h2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceBridge
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryReceipt =
            runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryReceipt
    }
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryBridge {
    public let h2RuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAccepted: Bool
    public let h2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAllowed: Bool
    public let boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryFollowupAllowed: Bool
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceMode: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryMode: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId: String
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String
    public let runtimeDefaultPathMutationApplyDryRunId: String
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2RuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAccepted: Bool,
        h2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAllowed: Bool,
        boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryFollowupAllowed: Bool,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceMode: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryMode: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId: String,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String,
        runtimeDefaultPathMutationApplyDryRunId: String,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAccepted =
            h2RuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAccepted
        this.h2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAccepted =
            h2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAccepted
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAccepted =
            runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAccepted
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAllowed =
            runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAllowed
        this.boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryFollowupAllowed =
            boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryFollowupAllowed
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
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryBridge(
    evidence:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryEvidence
): JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryBridge {
    let h2ControlledAcceptanceBridge =
        evidence.h2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceBridge
    let acceptanceBoundaryReceipt =
        evidence.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryReceipt
    let nonClaims =
        jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryNonClaims()
    if (
        !h2ControlledAcceptanceBridge.h2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAccepted ||
        !h2ControlledAcceptanceBridge.boundedControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryBridge(
            false,
            h2ControlledAcceptanceBridge.h2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceAccepted,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAccepted,
            false,
            false,
            acceptanceBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceMode,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryMode,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
            acceptanceBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunId,
            false,
            false,
            false,
            false,
            "blocked-h2-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-bridge",
            "collect-accepted-h2-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-before-acceptance-boundary",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryControlledBridgeBlockers(
                h2ControlledAcceptanceBridge
            ),
            nonClaims,
            "repair H2 controlled runtime default-path mutation apply-dry-run acceptance bridge before acceptance boundary; do not treat generic acceptance-boundary receipts as H2 runtime mutation",
            "QUIC must pass stream controlled default mutation apply-dry-run acceptance before acceptance-boundary proof"
        )
    }
    if (
        !acceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAccepted ||
        !acceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryBridge(
            false,
            true,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAccepted,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAllowed,
            false,
            acceptanceBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceMode,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryMode,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
            acceptanceBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunId,
            false,
            false,
            false,
            false,
            "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-boundary-receipt",
            "collect-accepted-runtime-default-path-mutation-apply-dry-run-acceptance-boundary-before-closeout-gate",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryReceiptBlockers(
                acceptanceBoundaryReceipt
            ),
            nonClaims,
            acceptanceBoundaryReceipt.nextAction,
            "QUIC must not consume rejected runtime default-path mutation apply-dry-run acceptance boundary receipts for stream default mutation"
        )
    }

    JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryBridge(
        true,
        true,
        true,
        acceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAllowed,
        true,
        acceptanceBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceMode,
        acceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryMode,
        acceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
        acceptanceBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
        acceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
        acceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunId,
        acceptanceBoundaryReceipt.runtimeDefaultPathMutationAllowed,
        acceptanceBoundaryReceipt.publicReleaseAllowed,
        acceptanceBoundaryReceipt.stdxRemovalAllowed,
        false,
        "accepted-h2-runtime-default-path-mutation-apply-dry-run-acceptance-boundary-bridge",
        "record-h2-runtime-default-path-mutation-apply-dry-run-acceptance-boundary-without-runtime-default-mutation",
        [],
        nonClaims,
        "next packet may prove H2 runtime default-path mutation apply-dry-run acceptance closeout gate; actual runtime default-path mutation, release, stdx removal, and H2 closure remain denied",
        "QUIC can reuse H2-style controlled-acceptance plus generic acceptance-boundary separation before runtime default mutation"
    )
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryControlledBridgeBlockers(
    bridge:
        JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "H2_CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE:${bridge.status}"
    )
    for (blocker in bridge.blockers) {
        blockers.add(
            "H2_CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryReceiptBlockers(
    receipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_BOUNDARY:${receipt.status}"
    )
    for (blocker in receipt.blockers) {
        blockers.add(
            "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_BOUNDARY_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_CLOSEOUT_GATE",
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateEvidence {
    public let h2RuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryBridge:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryBridge
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateReceipt:
        IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateReceipt

    public init(
        h2RuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryBridge:
            JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryBridge,
        runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateReceipt:
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateReceipt
    ) {
        this.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryBridge =
            h2RuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryBridge
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateReceipt =
            runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateReceipt
    }
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateBridge {
    public let h2RuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAccepted: Bool
    public let h2RuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAllowed: Bool
    public let boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateFollowupAllowed: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryMode: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateMode: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId: String
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String
    public let runtimeDefaultPathMutationApplyDryRunId: String
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2RuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAccepted: Bool,
        h2RuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAllowed: Bool,
        boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateFollowupAllowed: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryMode: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateMode: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId: String,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String,
        runtimeDefaultPathMutationApplyDryRunId: String,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAccepted =
            h2RuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAccepted
        this.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAccepted =
            h2RuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAccepted
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAccepted =
            runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAccepted
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAllowed =
            runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAllowed
        this.boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateFollowupAllowed =
            boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateFollowupAllowed
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
        this.runtimeDefaultPathMutationApplyDryRunId =
            runtimeDefaultPathMutationApplyDryRunId
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateBridge(
    evidence:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateEvidence
): JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateBridge {
    let h2BoundaryBridge =
        evidence.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryBridge
    let closeoutGateReceipt =
        evidence.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateReceipt
    let boundaryReceipt =
        closeoutGateReceipt.applyDryRunAcceptanceBoundaryReceipt
    let nonClaims =
        jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateNonClaims()
    if (
        !h2BoundaryBridge.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAccepted ||
        !h2BoundaryBridge.boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateBridge(
            false,
            h2BoundaryBridge.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryAccepted,
            closeoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAccepted,
            false,
            false,
            closeoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryMode,
            closeoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateMode,
            closeoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
            closeoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
            closeoutGateReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            closeoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            boundaryReceipt.runtimeDefaultPathMutationApplyDryRunId,
            false,
            false,
            false,
            false,
            "blocked-h2-runtime-default-path-mutation-apply-dry-run-acceptance-boundary-bridge",
            "collect-accepted-h2-runtime-default-path-mutation-apply-dry-run-acceptance-boundary-before-closeout-gate",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateBoundaryBlockers(
                h2BoundaryBridge
            ),
            nonClaims,
            "repair H2 runtime default-path mutation apply-dry-run acceptance boundary bridge before closeout gate; do not treat generic closeout gates as H2 runtime mutation",
            "QUIC must pass stream default mutation apply-dry-run acceptance boundary before closeout-gate proof"
        )
    }
    if (
        !closeoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAccepted ||
        !closeoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateBridge(
            false,
            true,
            closeoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAccepted,
            closeoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAllowed,
            false,
            closeoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryMode,
            closeoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateMode,
            closeoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
            closeoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
            closeoutGateReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            closeoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            boundaryReceipt.runtimeDefaultPathMutationApplyDryRunId,
            false,
            false,
            false,
            false,
            "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-closeout-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-apply-dry-run-acceptance-closeout-gate-before-controlled-handoff",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateReceiptBlockers(
                closeoutGateReceipt
            ),
            nonClaims,
            closeoutGateReceipt.nextAction,
            "QUIC must not consume rejected runtime default-path mutation apply-dry-run acceptance closeout-gate receipts for stream default mutation"
        )
    }

    JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateBridge(
        true,
        true,
        true,
        closeoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAllowed,
        true,
        closeoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryMode,
        closeoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateMode,
        closeoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
        closeoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
        closeoutGateReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
        closeoutGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
        boundaryReceipt.runtimeDefaultPathMutationApplyDryRunId,
        closeoutGateReceipt.runtimeDefaultPathMutationAllowed,
        closeoutGateReceipt.publicReleaseAllowed,
        closeoutGateReceipt.stdxRemovalAllowed,
        false,
        "accepted-h2-runtime-default-path-mutation-apply-dry-run-acceptance-closeout-gate-bridge",
        "record-h2-runtime-default-path-mutation-apply-dry-run-acceptance-closeout-gate-without-runtime-default-mutation",
        [],
        nonClaims,
        "next packet may prove controlled H2 runtime default-path mutation apply-dry-run acceptance handoff or stdx claim separation; actual runtime default-path mutation, release, stdx removal, and H2 closure remain denied",
        "QUIC can reuse H2-style acceptance-boundary plus generic closeout-gate separation before runtime default mutation"
    )
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateBoundaryBlockers(
    bridge:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceBoundaryBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "H2_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_BOUNDARY:${bridge.status}"
    )
    for (blocker in bridge.blockers) {
        blockers.add(
            "H2_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_BOUNDARY_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateReceiptBlockers(
    receipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_CLOSEOUT_GATE:${receipt.status}"
    )
    for (blocker in receipt.blockers) {
        blockers.add(
            "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_CLOSEOUT_GATE_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF",
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffEvidence {
    public let h2RuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateBridge:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateBridge
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffReceipt:
        IgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffReceipt

    public init(
        h2RuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateBridge:
            JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateBridge,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffReceipt:
            IgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffReceipt
    ) {
        this.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateBridge =
            h2RuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateBridge
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffReceipt =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffReceipt
    }
}

public class JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBridge {
    public let h2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAccepted: Bool
    public let h2RuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAccepted: Bool
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAccepted: Bool
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAllowed: Bool
    public let boundedControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffFollowupAllowed: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateMode: String
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffMode: String
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId: String
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String
    public let runtimeDefaultPathMutationApplyDryRunId: String
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAccepted: Bool,
        h2RuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAccepted: Bool,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAccepted: Bool,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAllowed: Bool,
        boundedControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffFollowupAllowed: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateMode: String,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffMode: String,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId: String,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String,
        runtimeDefaultPathMutationApplyDryRunId: String,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAccepted =
            h2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAccepted
        this.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAccepted =
            h2RuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAccepted
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAccepted =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAccepted
        this.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAllowed =
            controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAllowed
        this.boundedControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffFollowupAllowed =
            boundedControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffFollowupAllowed
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
        this.runtimeDefaultPathMutationApplyDryRunId =
            runtimeDefaultPathMutationApplyDryRunId
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBridge(
    evidence:
        JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffEvidence
): JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBridge {
    let h2CloseoutGateBridge =
        evidence.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateBridge
    let handoffReceipt =
        evidence.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffReceipt
    let closeoutGateReceipt =
        handoffReceipt.applyDryRunAcceptanceCloseoutGateReceipt
    let boundaryReceipt =
        closeoutGateReceipt.applyDryRunAcceptanceBoundaryReceipt
    let nonClaims =
        jinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffNonClaims()
    if (
        !h2CloseoutGateBridge.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAccepted ||
        !h2CloseoutGateBridge.boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBridge(
            false,
            h2CloseoutGateBridge.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateAccepted,
            handoffReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAccepted,
            false,
            false,
            handoffReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateMode,
            handoffReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffMode,
            handoffReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
            handoffReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
            handoffReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
            handoffReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            handoffReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            boundaryReceipt.runtimeDefaultPathMutationApplyDryRunId,
            false,
            false,
            false,
            false,
            "blocked-h2-runtime-default-path-mutation-apply-dry-run-acceptance-closeout-gate-bridge",
            "collect-accepted-h2-runtime-default-path-mutation-apply-dry-run-acceptance-closeout-gate-before-controlled-handoff",
            jinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffCloseoutGateBlockers(
                h2CloseoutGateBridge
            ),
            nonClaims,
            "repair H2 runtime default-path mutation apply-dry-run acceptance closeout-gate bridge before controlled handoff; do not treat generic handoff receipts as H2 runtime mutation",
            "QUIC must pass stream default mutation apply-dry-run acceptance closeout gate before controlled handoff proof"
        )
    }
    if (
        !handoffReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAccepted ||
        !handoffReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAllowed
    ) {
        return JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBridge(
            false,
            true,
            handoffReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAccepted,
            handoffReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAllowed,
            false,
            handoffReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateMode,
            handoffReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffMode,
            handoffReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
            handoffReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
            handoffReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
            handoffReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            handoffReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            boundaryReceipt.runtimeDefaultPathMutationApplyDryRunId,
            false,
            false,
            false,
            false,
            "blocked-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-receipt",
            "collect-accepted-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-before-handoff-boundary",
            jinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffReceiptBlockers(
                handoffReceipt
            ),
            nonClaims,
            handoffReceipt.nextAction,
            "QUIC must not consume rejected controlled runtime default-path mutation apply-dry-run acceptance handoff receipts for stream default mutation"
        )
    }

    JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBridge(
        true,
        true,
        true,
        handoffReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAllowed,
        true,
        handoffReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateMode,
        handoffReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffMode,
        handoffReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
        handoffReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
        handoffReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
        handoffReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
        handoffReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
        boundaryReceipt.runtimeDefaultPathMutationApplyDryRunId,
        handoffReceipt.runtimeDefaultPathMutationAllowed,
        handoffReceipt.publicReleaseAllowed,
        handoffReceipt.stdxRemovalAllowed,
        false,
        "accepted-h2-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-bridge",
        "record-h2-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-without-runtime-default-mutation",
        [],
        nonClaims,
        "next packet may prove runtime default-path mutation apply-dry-run acceptance handoff boundary or stdx claim separation; actual runtime default-path mutation, release, stdx removal, and H2 closure remain denied",
        "QUIC can reuse H2-style closeout-gate plus generic controlled-handoff separation before runtime default mutation"
    )
}

func jinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffCloseoutGateBlockers(
    bridge:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "H2_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_CLOSEOUT_GATE:${bridge.status}"
    )
    for (blocker in bridge.blockers) {
        blockers.add(
            "H2_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_CLOSEOUT_GATE_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffReceiptBlockers(
    receipt: IgniteControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF:${receipt.status}"
    )
    for (blocker in receipt.blockers) {
        blockers.add(
            "CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_BOUNDARY",
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryEvidence {
    public let h2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBridge:
        JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBridge
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceipt:
        IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceipt

    public init(
        h2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBridge:
            JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBridge,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceipt:
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceipt
    ) {
        this.h2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBridge =
            h2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBridge
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceipt =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceipt
    }
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryBridge {
    public let h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAccepted: Bool
    public let h2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAllowed: Bool
    public let boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryFollowupAllowed: Bool
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffMode: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryMode: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId: String
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId: String
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String
    public let runtimeDefaultPathMutationApplyDryRunId: String
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAccepted: Bool,
        h2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAllowed: Bool,
        boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryFollowupAllowed: Bool,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffMode: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryMode: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId: String,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId: String,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String,
        runtimeDefaultPathMutationApplyDryRunId: String,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAccepted =
            h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAccepted
        this.h2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAccepted =
            h2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAccepted
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAccepted =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAccepted
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAllowed =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAllowed
        this.boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryFollowupAllowed =
            boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryFollowupAllowed
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
        this.runtimeDefaultPathMutationApplyDryRunId =
            runtimeDefaultPathMutationApplyDryRunId
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryBridge(
    evidence:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryEvidence
): JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryBridge {
    let h2ControlledHandoffBridge =
        evidence.h2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBridge
    let handoffBoundaryReceipt =
        evidence.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceipt
    let controlledHandoffReceipt =
        handoffBoundaryReceipt.controlledApplyDryRunAcceptanceHandoffReceipt
    let closeoutGateReceipt =
        controlledHandoffReceipt.applyDryRunAcceptanceCloseoutGateReceipt
    let acceptanceBoundaryReceipt =
        closeoutGateReceipt.applyDryRunAcceptanceBoundaryReceipt
    let nonClaims =
        jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryNonClaims()
    if (
        !h2ControlledHandoffBridge.h2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAccepted ||
        !h2ControlledHandoffBridge.boundedControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryBridge(
            false,
            h2ControlledHandoffBridge.h2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffAccepted,
            handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAccepted,
            false,
            false,
            handoffBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffMode,
            handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryMode,
            handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId,
            handoffBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
            handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
            handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
            handoffBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunId,
            false,
            false,
            false,
            false,
            "blocked-h2-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-bridge",
            "collect-accepted-h2-controlled-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-before-handoff-boundary",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryControlledHandoffBlockers(
                h2ControlledHandoffBridge
            ),
            nonClaims,
            "repair H2 controlled runtime default-path mutation apply-dry-run acceptance handoff bridge before handoff-boundary; do not treat generic handoff-boundary receipts as H2 runtime mutation",
            "QUIC must pass stream controlled handoff before runtime default mutation handoff-boundary proof"
        )
    }
    if (
        !handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAccepted ||
        !handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryBridge(
            false,
            true,
            handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAccepted,
            handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAllowed,
            false,
            handoffBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffMode,
            handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryMode,
            handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId,
            handoffBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
            handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
            handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
            handoffBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunId,
            false,
            false,
            false,
            false,
            "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-boundary-receipt",
            "collect-accepted-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-boundary-before-apply-boundary",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceiptBlockers(
                handoffBoundaryReceipt
            ),
            nonClaims,
            handoffBoundaryReceipt.nextAction,
            "QUIC must not consume rejected runtime default-path mutation apply-dry-run acceptance handoff-boundary receipts for stream default mutation"
        )
    }

    JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryBridge(
        true,
        true,
        true,
        handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAllowed,
        true,
        handoffBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffMode,
        handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryMode,
        handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId,
        handoffBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
        handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
        handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
        handoffBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
        handoffBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
        acceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunId,
        handoffBoundaryReceipt.runtimeDefaultPathMutationAllowed,
        handoffBoundaryReceipt.publicReleaseAllowed,
        handoffBoundaryReceipt.stdxRemovalAllowed,
        false,
        "accepted-h2-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-boundary-bridge",
        "record-h2-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-boundary-without-runtime-default-mutation",
        [],
        nonClaims,
        "next packet may prove runtime default-path mutation apply-dry-run acceptance handoff apply-boundary or stdx claim separation; actual runtime default-path mutation, release, stdx removal, and H2 closure remain denied",
        "QUIC can reuse H2-style controlled-handoff plus generic handoff-boundary separation before runtime default mutation"
    )
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryControlledHandoffBlockers(
    bridge:
        JinguiAcceptedTransportH2ControlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "H2_CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF:${bridge.status}"
    )
    for (blocker in bridge.blockers) {
        blockers.add(
            "H2_CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceiptBlockers(
    receipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_BOUNDARY:${receipt.status}"
    )
    for (blocker in receipt.blockers) {
        blockers.add(
            "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_BOUNDARY_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY",
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryEvidence {
    public let h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryBridge:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryBridge
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceipt:
        IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceipt

    public init(
        h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryBridge:
            JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryBridge,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceipt:
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceipt
    ) {
        this.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryBridge =
            h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryBridge
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceipt =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceipt
    }
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryBridge {
    public let h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAccepted: Bool
    public let h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAllowed: Bool
    public let boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateFollowupAllowed: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryMode: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryMode: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId: String
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId: String
    public let controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId: String
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String
    public let runtimeDefaultPathMutationApplyDryRunId: String
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAccepted: Bool,
        h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAllowed: Bool,
        boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateFollowupAllowed: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryMode: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryMode: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId: String,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId: String,
        controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId: String,
        runtimeDefaultPathMutationApplyDryRunAcceptanceGateId: String,
        runtimeDefaultPathMutationApplyDryRunId: String,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAccepted =
            h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAccepted
        this.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAccepted =
            h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAccepted
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAccepted =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAccepted
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAllowed =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAllowed
        this.boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateFollowupAllowed =
            boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateFollowupAllowed
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
        this.runtimeDefaultPathMutationApplyDryRunId =
            runtimeDefaultPathMutationApplyDryRunId
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryBridge(
    evidence:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryEvidence
): JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryBridge {
    let h2HandoffBoundaryBridge =
        evidence.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryBridge
    let handoffApplyBoundaryReceipt =
        evidence.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceipt
    let nonClaims =
        jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryNonClaims()
    if (
        !h2HandoffBoundaryBridge.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAccepted ||
        !h2HandoffBoundaryBridge.boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryBridge(
            false,
            h2HandoffBoundaryBridge.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryAccepted,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAccepted,
            false,
            false,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryMode,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryMode,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId,
            handoffApplyBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
            handoffApplyBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            h2HandoffBoundaryBridge.runtimeDefaultPathMutationApplyDryRunId,
            false,
            false,
            false,
            false,
            "blocked-h2-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-boundary-bridge",
            "collect-accepted-h2-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-boundary-before-handoff-apply-boundary",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryHandoffBoundaryBlockers(
                h2HandoffBoundaryBridge
            ),
            nonClaims,
            "repair H2 runtime default-path mutation apply-dry-run acceptance handoff-boundary bridge before handoff apply-boundary; do not treat generic handoff apply-boundary receipts as H2 runtime mutation",
            "QUIC must pass stream handoff-boundary before runtime default mutation handoff apply-boundary proof"
        )
    }
    if (
        !handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAccepted ||
        !handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryBridge(
            false,
            true,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAccepted,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAllowed,
            false,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryMode,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryMode,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId,
            handoffApplyBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
            handoffApplyBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            h2HandoffBoundaryBridge.runtimeDefaultPathMutationApplyDryRunId,
            false,
            false,
            false,
            false,
            "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-receipt",
            "collect-accepted-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-before-apply-boundary-gate",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceiptBlockers(
                handoffApplyBoundaryReceipt
            ),
            nonClaims,
            handoffApplyBoundaryReceipt.nextAction,
            "QUIC must not consume rejected runtime default-path mutation apply-dry-run acceptance handoff apply-boundary receipts for stream default mutation"
        )
    }

    JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryBridge(
        true,
        true,
        true,
        handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAllowed,
        true,
        handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryMode,
        handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryMode,
        handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId,
        handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId,
        handoffApplyBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
        handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
        handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
        handoffApplyBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
        handoffApplyBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
        h2HandoffBoundaryBridge.runtimeDefaultPathMutationApplyDryRunId,
        handoffApplyBoundaryReceipt.runtimeDefaultPathMutationAllowed,
        handoffApplyBoundaryReceipt.publicReleaseAllowed,
        handoffApplyBoundaryReceipt.stdxRemovalAllowed,
        false,
        "accepted-h2-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-bridge",
        "record-h2-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-without-runtime-default-mutation",
        [],
        nonClaims,
        "next packet may prove runtime default-path mutation apply-dry-run acceptance handoff apply-boundary gate or stdx claim separation; actual runtime default-path mutation, release, stdx removal, and H2 closure remain denied",
        "QUIC can reuse H2-style handoff-boundary plus generic handoff apply-boundary separation before runtime default mutation"
    )
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryHandoffBoundaryBlockers(
    bridge:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "H2_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_BOUNDARY:${bridge.status}"
    )
    for (blocker in bridge.blockers) {
        blockers.add(
            "H2_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_BOUNDARY_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceiptBlockers(
    receipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY:${receipt.status}"
    )
    for (blocker in receipt.blockers) {
        blockers.add(
            "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE",
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateEvidence {
    public let h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryBridge:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryBridge
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceipt:
        IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceipt

    public init(
        h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryBridge:
            JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryBridge,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceipt:
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceipt
    ) {
        this.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryBridge =
            h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryBridge
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceipt =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceipt
    }
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateBridge {
    public let h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAccepted: Bool
    public let h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAllowed: Bool
    public let boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutFollowupAllowed: Bool
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
    public let runtimeDefaultPathMutationApplyDryRunId: String
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAccepted: Bool,
        h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAllowed: Bool,
        boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutFollowupAllowed: Bool,
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
        runtimeDefaultPathMutationApplyDryRunId: String,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAccepted =
            h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAccepted
        this.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAccepted =
            h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAccepted
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAccepted =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAccepted
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAllowed =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAllowed
        this.boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutFollowupAllowed =
            boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutFollowupAllowed
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
        this.runtimeDefaultPathMutationApplyDryRunId =
            runtimeDefaultPathMutationApplyDryRunId
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateBridge(
    evidence:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateEvidence
): JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateBridge {
    let h2HandoffApplyBoundaryBridge =
        evidence.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryBridge
    let handoffApplyBoundaryGateReceipt =
        evidence.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceipt
    let nonClaims =
        jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateNonClaims()
    if (
        !h2HandoffApplyBoundaryBridge.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAccepted ||
        !h2HandoffApplyBoundaryBridge.boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateBridge(
            false,
            h2HandoffApplyBoundaryBridge.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryAccepted,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAccepted,
            false,
            false,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryMode,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateMode,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId,
            handoffApplyBoundaryGateReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
            handoffApplyBoundaryGateReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            h2HandoffApplyBoundaryBridge.runtimeDefaultPathMutationApplyDryRunId,
            false,
            false,
            false,
            false,
            "blocked-h2-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-bridge",
            "collect-accepted-h2-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-before-handoff-apply-boundary-gate",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateHandoffApplyBoundaryBlockers(
                h2HandoffApplyBoundaryBridge
            ),
            nonClaims,
            "repair H2 runtime default-path mutation apply-dry-run acceptance handoff apply-boundary bridge before handoff apply-boundary gate; do not treat generic handoff apply-boundary gate receipts as H2 runtime mutation",
            "QUIC must pass stream handoff apply-boundary before runtime default mutation handoff apply-boundary gate proof"
        )
    }
    if (
        !handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAccepted ||
        !handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateBridge(
            false,
            true,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAccepted,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAllowed,
            false,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryMode,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateMode,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId,
            handoffApplyBoundaryGateReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
            handoffApplyBoundaryGateReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            h2HandoffApplyBoundaryBridge.runtimeDefaultPathMutationApplyDryRunId,
            false,
            false,
            false,
            false,
            "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-before-gate-closeout",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceiptBlockers(
                handoffApplyBoundaryGateReceipt
            ),
            nonClaims,
            handoffApplyBoundaryGateReceipt.nextAction,
            "QUIC must not consume rejected runtime default-path mutation apply-dry-run acceptance handoff apply-boundary gate receipts for stream default mutation"
        )
    }

    JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateBridge(
        true,
        true,
        true,
        handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAllowed,
        true,
        handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryMode,
        handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateMode,
        handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId,
        handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId,
        handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId,
        handoffApplyBoundaryGateReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
        handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
        handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
        handoffApplyBoundaryGateReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
        handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
        h2HandoffApplyBoundaryBridge.runtimeDefaultPathMutationApplyDryRunId,
        handoffApplyBoundaryGateReceipt.runtimeDefaultPathMutationAllowed,
        handoffApplyBoundaryGateReceipt.publicReleaseAllowed,
        handoffApplyBoundaryGateReceipt.stdxRemovalAllowed,
        false,
        "accepted-h2-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-bridge",
        "record-h2-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-without-runtime-default-mutation",
        [],
        nonClaims,
        "next packet may prove runtime default-path mutation apply-dry-run acceptance handoff apply-boundary gate closeout or stdx claim separation; actual runtime default-path mutation, release, stdx removal, and H2 closure remain denied",
        "QUIC can reuse H2-style handoff apply-boundary plus generic handoff apply-boundary gate separation before runtime default mutation"
    )
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateHandoffApplyBoundaryBlockers(
    bridge:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "H2_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY:${bridge.status}"
    )
    for (blocker in bridge.blockers) {
        blockers.add(
            "H2_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceiptBlockers(
    receipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE:${receipt.status}"
    )
    for (blocker in receipt.blockers) {
        blockers.add(
            "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT",
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutEvidence {
    public let h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateBridge:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateBridge
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceipt:
        IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceipt

    public init(
        h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateBridge:
            JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateBridge,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceipt:
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceipt
    ) {
        this.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateBridge =
            h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateBridge
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceipt =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceipt
    }
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBridge {
    public let h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAccepted: Bool
    public let h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAllowed: Bool
    public let boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryFollowupAllowed: Bool
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
    public let runtimeDefaultPathMutationApplyDryRunId: String
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAccepted: Bool,
        h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAllowed: Bool,
        boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryFollowupAllowed: Bool,
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
        runtimeDefaultPathMutationApplyDryRunId: String,
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAccepted =
            h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAccepted
        this.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAccepted =
            h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAccepted
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAccepted =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAccepted
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAllowed =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAllowed
        this.boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryFollowupAllowed =
            boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryFollowupAllowed
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
        this.runtimeDefaultPathMutationApplyDryRunId =
            runtimeDefaultPathMutationApplyDryRunId
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBridge(
    evidence:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutEvidence
): JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBridge {
    let h2HandoffApplyBoundaryGateBridge =
        evidence.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateBridge
    let handoffApplyBoundaryGateCloseoutReceipt =
        evidence.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceipt
    let nonClaims =
        jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutNonClaims()
    if (
        !h2HandoffApplyBoundaryGateBridge.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAccepted ||
        !h2HandoffApplyBoundaryGateBridge.boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBridge(
            false,
            h2HandoffApplyBoundaryGateBridge.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateAccepted,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAccepted,
            false,
            false,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateMode,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutMode,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId,
            handoffApplyBoundaryGateCloseoutReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
            handoffApplyBoundaryGateCloseoutReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            h2HandoffApplyBoundaryGateBridge.runtimeDefaultPathMutationApplyDryRunId,
            false,
            false,
            false,
            false,
            "blocked-h2-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-bridge",
            "collect-accepted-h2-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-before-gate-closeout",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutHandoffApplyBoundaryGateBlockers(
                h2HandoffApplyBoundaryGateBridge
            ),
            nonClaims,
            "repair H2 runtime default-path mutation apply-dry-run acceptance handoff apply-boundary gate bridge before gate closeout; do not treat generic gate closeout receipts as H2 runtime mutation",
            "QUIC must pass stream handoff apply-boundary gate before runtime default mutation gate closeout proof"
        )
    }
    if (
        !handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAccepted ||
        !handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBridge(
            false,
            true,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAccepted,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAllowed,
            false,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateMode,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutMode,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId,
            handoffApplyBoundaryGateCloseoutReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
            handoffApplyBoundaryGateCloseoutReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
            handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
            h2HandoffApplyBoundaryGateBridge.runtimeDefaultPathMutationApplyDryRunId,
            false,
            false,
            false,
            false,
            "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-receipt",
            "collect-accepted-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-before-closeout-boundary",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceiptBlockers(
                handoffApplyBoundaryGateCloseoutReceipt
            ),
            nonClaims,
            handoffApplyBoundaryGateCloseoutReceipt.nextAction,
            "QUIC must not consume rejected runtime default-path mutation apply-dry-run acceptance handoff apply-boundary gate closeout receipts for stream default mutation"
        )
    }

    JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBridge(
        true,
        true,
        true,
        handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAllowed,
        true,
        handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateMode,
        handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutMode,
        handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutId,
        handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateId,
        handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryId,
        handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffBoundaryId,
        handoffApplyBoundaryGateCloseoutReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffId,
        handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceCloseoutGateId,
        handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceBoundaryId,
        handoffApplyBoundaryGateCloseoutReceipt.controlledRuntimeDefaultPathMutationApplyDryRunAcceptanceId,
        handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceGateId,
        h2HandoffApplyBoundaryGateBridge.runtimeDefaultPathMutationApplyDryRunId,
        handoffApplyBoundaryGateCloseoutReceipt.runtimeDefaultPathMutationAllowed,
        handoffApplyBoundaryGateCloseoutReceipt.publicReleaseAllowed,
        handoffApplyBoundaryGateCloseoutReceipt.stdxRemovalAllowed,
        false,
        "accepted-h2-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-bridge",
        "record-h2-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-without-runtime-default-mutation",
        [],
        nonClaims,
        "next packet may prove runtime default-path mutation apply-dry-run acceptance handoff apply-boundary gate closeout boundary or stdx claim separation; actual runtime default-path mutation, release, stdx removal, and H2 closure remain denied",
        "QUIC can reuse H2-style handoff apply-boundary gate plus generic gate closeout separation before runtime default mutation"
    )
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutHandoffApplyBoundaryGateBlockers(
    bridge:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "H2_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE:${bridge.status}"
    )
    for (blocker in bridge.blockers) {
        blockers.add(
            "H2_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceiptBlockers(
    receipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT:${receipt.status}"
    )
    for (blocker in receipt.blockers) {
        blockers.add(
            "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY",
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryEvidence {
    public let h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBridge:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBridge
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceipt:
        IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceipt

    public init(
        h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBridge:
            JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBridge,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceipt:
            IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceipt
    ) {
        this.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBridge =
            h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBridge
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceipt =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceipt
    }
}

public class JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryBridge {
    public let h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAccepted: Bool
    public let h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAllowed: Bool
    public let boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryFollowupAllowed: Bool
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
    public let runtimeDefaultPathMutationAllowed: Bool
    public let publicReleaseAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAccepted: Bool,
        h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAccepted: Bool,
        runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAllowed: Bool,
        boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryFollowupAllowed: Bool,
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
        runtimeDefaultPathMutationAllowed: Bool,
        publicReleaseAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAccepted =
            h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAccepted
        this.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAccepted =
            h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAccepted
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAccepted =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAccepted
        this.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAllowed =
            runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAllowed
        this.boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryFollowupAllowed =
            boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryFollowupAllowed
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
        this.runtimeDefaultPathMutationAllowed = runtimeDefaultPathMutationAllowed
        this.publicReleaseAllowed = publicReleaseAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryBridge(
    evidence:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryEvidence
): JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryBridge {
    let h2HandoffApplyBoundaryGateCloseoutBridge =
        evidence.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBridge
    let handoffApplyBoundaryGateCloseoutBoundaryReceipt =
        evidence.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceipt
    let nonClaims =
        jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryNonClaims()
    if (
        !h2HandoffApplyBoundaryGateCloseoutBridge.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAccepted ||
        !h2HandoffApplyBoundaryGateCloseoutBridge.boundedRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryBridge(
            false,
            h2HandoffApplyBoundaryGateCloseoutBridge.h2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutAccepted,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAccepted,
            false,
            false,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutMode,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryMode,
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
            false,
            false,
            false,
            false,
            "blocked-h2-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-bridge",
            "collect-accepted-h2-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-before-closeout-boundary",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryHandoffApplyBoundaryGateCloseoutBlockers(
                h2HandoffApplyBoundaryGateCloseoutBridge
            ),
            nonClaims,
            "repair H2 runtime default-path mutation apply-dry-run acceptance handoff apply-boundary gate closeout bridge before closeout boundary; do not treat generic closeout boundary receipts as H2 runtime mutation",
            "QUIC must pass stream handoff apply-boundary gate closeout before runtime default mutation closeout boundary proof"
        )
    }
    if (
        !handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAccepted ||
        !handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryBridge(
            false,
            true,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAccepted,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAllowed,
            false,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutMode,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryMode,
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
            false,
            false,
            false,
            false,
            "blocked-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-receipt",
            "collect-accepted-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-before-stdx-claim-separation",
            jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceiptBlockers(
                handoffApplyBoundaryGateCloseoutBoundaryReceipt
            ),
            nonClaims,
            handoffApplyBoundaryGateCloseoutBoundaryReceipt.nextAction,
            "QUIC must not consume rejected runtime default-path mutation apply-dry-run acceptance handoff apply-boundary gate closeout boundary receipts for stream default mutation"
        )
    }

    JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryBridge(
        true,
        true,
        true,
        handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryAllowed,
        true,
        handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutMode,
        handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryMode,
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
        handoffApplyBoundaryGateCloseoutBoundaryReceipt.runtimeDefaultPathMutationAllowed,
        handoffApplyBoundaryGateCloseoutBoundaryReceipt.publicReleaseAllowed,
        handoffApplyBoundaryGateCloseoutBoundaryReceipt.stdxRemovalAllowed,
        false,
        "accepted-h2-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-bridge",
        "record-h2-runtime-default-path-mutation-apply-dry-run-acceptance-handoff-apply-boundary-gate-closeout-boundary-without-runtime-default-mutation",
        [],
        nonClaims,
        "next packet may prove stdx claim separation or runtime default mutation preparation; actual runtime default-path mutation, release, stdx removal, and H2 closure remain denied",
        "QUIC can reuse H2-style handoff apply-boundary gate closeout plus generic closeout boundary separation before runtime default mutation"
    )
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryHandoffApplyBoundaryGateCloseoutBlockers(
    bridge:
        JinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "H2_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT:${bridge.status}"
    )
    for (blocker in bridge.blockers) {
        blockers.add(
            "H2_RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceiptBlockers(
    receipt: IgniteRuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY:${receipt.status}"
    )
    for (blocker in receipt.blockers) {
        blockers.add(
            "RUNTIME_DEFAULT_PATH_MUTATION_APPLY_DRY_RUN_ACCEPTANCE_HANDOFF_APPLY_BOUNDARY_GATE_CLOSEOUT_BOUNDARY_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeDefaultPathMutationApplyDryRunAcceptanceHandoffApplyBoundaryGateCloseoutBoundaryNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_STDX_CLAIM_SEPARATION",
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_PUBLIC_RELEASE_READINESS",
        "NO_STDX_REMOVAL",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}
