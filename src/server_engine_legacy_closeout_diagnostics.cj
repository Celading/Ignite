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

public class IgniteRuntimeDefaultPathApplyGateRequest {
    public let applyGateId: String
    public let executionChainGateCarried: Bool
    public let applyOrderMarkerCarried: Bool
    public let dryRunProofCarried: Bool
    public let rollbackPlanCarried: Bool
    public let auditMarkerCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let operatorAcknowledgementCarried: Bool
    public let blockingIsolationModePreserved: Bool
    public let actualDefaultEngineFlipRequested: Bool
    public let defaultEngineConfigMutationRequested: Bool
    public let runtimeDefaultPathMutationRequested: Bool
    public let publicReleaseRequested: Bool
    public let stdxRemovalRequested: Bool
    public let h1H2QuicRuntimeClosureClaimed: Bool

    public init(
        applyGateId: String,
        executionChainGateCarried: Bool,
        applyOrderMarkerCarried: Bool,
        dryRunProofCarried: Bool,
        rollbackPlanCarried: Bool,
        auditMarkerCarried: Bool,
        observabilityMarkerCarried: Bool,
        operatorAcknowledgementCarried: Bool,
        blockingIsolationModePreserved: Bool,
        actualDefaultEngineFlipRequested: Bool,
        defaultEngineConfigMutationRequested: Bool,
        runtimeDefaultPathMutationRequested: Bool,
        publicReleaseRequested: Bool,
        stdxRemovalRequested: Bool,
        h1H2QuicRuntimeClosureClaimed: Bool
    ) {
        this.applyGateId = applyGateId
        this.executionChainGateCarried = executionChainGateCarried
        this.applyOrderMarkerCarried = applyOrderMarkerCarried
        this.dryRunProofCarried = dryRunProofCarried
        this.rollbackPlanCarried = rollbackPlanCarried
        this.auditMarkerCarried = auditMarkerCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
        this.operatorAcknowledgementCarried = operatorAcknowledgementCarried
        this.blockingIsolationModePreserved = blockingIsolationModePreserved
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

public class IgniteRuntimeDefaultPathApplyGateReceipt {
    public let applyGateAccepted: Bool
    public let executionChainGateAccepted: Bool
    public let executionChainGateMode: String
    public let applyGateId: String
    public let applyGateMode: String
    public let executionChainGateReceipt: IgniteRuntimeDefaultPathExecutionChainGateReceipt
    public let applyGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathApplyGateAllowed: Bool
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
        applyGateAccepted: Bool,
        executionChainGateAccepted: Bool,
        executionChainGateMode: String,
        applyGateId: String,
        applyGateMode: String,
        executionChainGateReceipt: IgniteRuntimeDefaultPathExecutionChainGateReceipt,
        applyGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathApplyGateAllowed: Bool,
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
        this.applyGateAccepted = applyGateAccepted
        this.executionChainGateAccepted = executionChainGateAccepted
        this.executionChainGateMode = executionChainGateMode
        this.applyGateId = applyGateId
        this.applyGateMode = applyGateMode
        this.executionChainGateReceipt = executionChainGateReceipt
        this.applyGateRecorded = applyGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathApplyGateAllowed =
            runtimeDefaultPathApplyGateAllowed
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

public func buildIgniteRuntimeDefaultPathApplyGateReceipt(
    executionChainGateReceipt: IgniteRuntimeDefaultPathExecutionChainGateReceipt,
    request: IgniteRuntimeDefaultPathApplyGateRequest
): IgniteRuntimeDefaultPathApplyGateReceipt {
    let nonClaims = igniteRuntimeDefaultPathApplyGateNonClaims()
    if (!executionChainGateReceipt.executionChainGateAccepted) {
        return IgniteRuntimeDefaultPathApplyGateReceipt(
            false,
            executionChainGateReceipt.executionChainGateAccepted,
            executionChainGateReceipt.executionChainGateMode,
            request.applyGateId,
            "none",
            executionChainGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-execution-chain-gate",
            "collect-accepted-runtime-default-path-execution-chain-gate-first",
            ["RUNTIME_DEFAULT_PATH_EXECUTION_CHAIN_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0561 execution-chain gate before apply-gate consumption",
            "QUIC must not consume runtime default-path apply gates from rejected execution-chain receipts"
        )
    }

    let applyGateMode = igniteRuntimeDefaultPathApplyGateModeFor(
        executionChainGateReceipt.executionChainGateMode
    )
    let blockers = igniteRuntimeDefaultPathApplyGateBlockers(
        request,
        applyGateMode
    )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathApplyGateReceipt(
            false,
            executionChainGateReceipt.executionChainGateAccepted,
            executionChainGateReceipt.executionChainGateMode,
            request.applyGateId,
            applyGateMode,
            executionChainGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-apply-gate-input",
            "fix-runtime-default-path-apply-gate-before-controlled-apply",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry apply order, dry-run proof, rollback plan, audit marker, observability marker, operator acknowledgement, and keep default mutation out",
            "QUIC can reuse apply-gate blockers before stream default-path apply gates"
        )
    }

    IgniteRuntimeDefaultPathApplyGateReceipt(
        true,
        executionChainGateReceipt.executionChainGateAccepted,
        executionChainGateReceipt.executionChainGateMode,
        request.applyGateId,
        applyGateMode,
        executionChainGateReceipt,
        true,
        "record-runtime-default-path-apply-gate",
        "accepted-runtime-default-path-apply-gate-receipt",
        "apply-gate-ready-without-runtime-default-path-mutation",
        [],
        true,
        false,
        false,
        false,
        false,
        false,
        false,
        nonClaims,
        "next packet may prove controlled apply dry-run or staging handoff without flipping defaults or mutating config",
        "QUIC can reuse the apply gate modes before stream runtime default-path apply gates"
    )
}

func igniteRuntimeDefaultPathApplyGateModeFor(
    executionChainGateMode: String
): String {
    if (
        executionChainGateMode ==
        "short-runtime-default-path-execution-chain-gate"
    ) {
        return "short-runtime-default-path-apply-gate"
    }
    if (
        executionChainGateMode ==
        "long-runtime-default-path-execution-chain-gate"
    ) {
        return "long-runtime-default-path-apply-gate"
    }
    if (
        executionChainGateMode ==
        "blocking-isolation-runtime-default-path-execution-chain-gate"
    ) {
        return "blocking-isolation-runtime-default-path-apply-gate"
    }
    "unknown-runtime-default-path-apply-gate"
}

func igniteRuntimeDefaultPathApplyGateBlockers(
    request: IgniteRuntimeDefaultPathApplyGateRequest,
    applyGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.applyGateId.size == 0) {
        blockers.add("RUNTIME_DEFAULT_PATH_APPLY_GATE_ID_NOT_CARRIED")
    }
    if (!request.executionChainGateCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_EXECUTION_CHAIN_GATE_NOT_CARRIED")
    }
    if (!request.applyOrderMarkerCarried) {
        blockers.add("APPLY_ORDER_MARKER_NOT_CARRIED")
    }
    if (!request.dryRunProofCarried) {
        blockers.add("DRY_RUN_PROOF_NOT_CARRIED")
    }
    if (!request.rollbackPlanCarried) {
        blockers.add("ROLLBACK_PLAN_NOT_CARRIED")
    }
    if (!request.auditMarkerCarried) {
        blockers.add("AUDIT_MARKER_NOT_CARRIED")
    }
    if (!request.observabilityMarkerCarried) {
        blockers.add("OBSERVABILITY_MARKER_NOT_CARRIED")
    }
    if (!request.operatorAcknowledgementCarried) {
        blockers.add("OPERATOR_ACKNOWLEDGEMENT_NOT_CARRIED")
    }
    if (!request.blockingIsolationModePreserved) {
        blockers.add("BLOCKING_ISOLATION_MODE_NOT_PRESERVED")
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
    if (applyGateMode == "unknown-runtime-default-path-apply-gate") {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_EXECUTION_CHAIN_GATE_MODE")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathApplyGateNonClaims(): Array<String> {
    [
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_PUBLIC_RELEASE",
        "NO_STDX_REMOVAL",
        "NO_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
    ]
}

public class IgniteControlledRuntimeDefaultPathApplyDryRunRequest {
    public let controlledRuntimeDefaultPathApplyDryRunId: String
    public let runtimeDefaultPathApplyGateReceiptCarried: Bool
    public let controlledApplyDryRunScopeCarried: Bool
    public let dryRunExecutionOrderCarried: Bool
    public let controlPlaneMarkerCarried: Bool
    public let rollbackPlanCarried: Bool
    public let auditMarkerCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let operatorAcknowledgementCarried: Bool
    public let blockingIsolationModePreserved: Bool
    public let actualDefaultEngineFlipRequested: Bool
    public let defaultEngineConfigMutationRequested: Bool
    public let runtimeDefaultPathMutationRequested: Bool
    public let publicReleaseRequested: Bool
    public let stdxRemovalRequested: Bool
    public let h1H2QuicRuntimeClosureClaimed: Bool

    public init(
        controlledRuntimeDefaultPathApplyDryRunId: String,
        runtimeDefaultPathApplyGateReceiptCarried: Bool,
        controlledApplyDryRunScopeCarried: Bool,
        dryRunExecutionOrderCarried: Bool,
        controlPlaneMarkerCarried: Bool,
        rollbackPlanCarried: Bool,
        auditMarkerCarried: Bool,
        observabilityMarkerCarried: Bool,
        operatorAcknowledgementCarried: Bool,
        blockingIsolationModePreserved: Bool,
        actualDefaultEngineFlipRequested: Bool,
        defaultEngineConfigMutationRequested: Bool,
        runtimeDefaultPathMutationRequested: Bool,
        publicReleaseRequested: Bool,
        stdxRemovalRequested: Bool,
        h1H2QuicRuntimeClosureClaimed: Bool
    ) {
        this.controlledRuntimeDefaultPathApplyDryRunId =
            controlledRuntimeDefaultPathApplyDryRunId
        this.runtimeDefaultPathApplyGateReceiptCarried =
            runtimeDefaultPathApplyGateReceiptCarried
        this.controlledApplyDryRunScopeCarried =
            controlledApplyDryRunScopeCarried
        this.dryRunExecutionOrderCarried = dryRunExecutionOrderCarried
        this.controlPlaneMarkerCarried = controlPlaneMarkerCarried
        this.rollbackPlanCarried = rollbackPlanCarried
        this.auditMarkerCarried = auditMarkerCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
        this.operatorAcknowledgementCarried = operatorAcknowledgementCarried
        this.blockingIsolationModePreserved = blockingIsolationModePreserved
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

public class IgniteControlledRuntimeDefaultPathApplyDryRunReceipt {
    public let controlledRuntimeDefaultPathApplyDryRunAccepted: Bool
    public let runtimeDefaultPathApplyGateAccepted: Bool
    public let runtimeDefaultPathApplyGateMode: String
    public let controlledRuntimeDefaultPathApplyDryRunMode: String
    public let controlledRuntimeDefaultPathApplyDryRunId: String
    public let runtimeDefaultPathApplyGateId: String
    public let applyGateReceipt: IgniteRuntimeDefaultPathApplyGateReceipt
    public let controlledRuntimeDefaultPathApplyDryRunRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let controlledRuntimeDefaultPathApplyDryRunAllowed: Bool
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
        controlledRuntimeDefaultPathApplyDryRunAccepted: Bool,
        runtimeDefaultPathApplyGateAccepted: Bool,
        runtimeDefaultPathApplyGateMode: String,
        controlledRuntimeDefaultPathApplyDryRunMode: String,
        controlledRuntimeDefaultPathApplyDryRunId: String,
        runtimeDefaultPathApplyGateId: String,
        applyGateReceipt: IgniteRuntimeDefaultPathApplyGateReceipt,
        controlledRuntimeDefaultPathApplyDryRunRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        controlledRuntimeDefaultPathApplyDryRunAllowed: Bool,
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
        this.controlledRuntimeDefaultPathApplyDryRunAccepted =
            controlledRuntimeDefaultPathApplyDryRunAccepted
        this.runtimeDefaultPathApplyGateAccepted =
            runtimeDefaultPathApplyGateAccepted
        this.runtimeDefaultPathApplyGateMode = runtimeDefaultPathApplyGateMode
        this.controlledRuntimeDefaultPathApplyDryRunMode =
            controlledRuntimeDefaultPathApplyDryRunMode
        this.controlledRuntimeDefaultPathApplyDryRunId =
            controlledRuntimeDefaultPathApplyDryRunId
        this.runtimeDefaultPathApplyGateId = runtimeDefaultPathApplyGateId
        this.applyGateReceipt = applyGateReceipt
        this.controlledRuntimeDefaultPathApplyDryRunRecorded =
            controlledRuntimeDefaultPathApplyDryRunRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.controlledRuntimeDefaultPathApplyDryRunAllowed =
            controlledRuntimeDefaultPathApplyDryRunAllowed
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

public func buildIgniteControlledRuntimeDefaultPathApplyDryRunReceipt(
    applyGateReceipt: IgniteRuntimeDefaultPathApplyGateReceipt,
    request: IgniteControlledRuntimeDefaultPathApplyDryRunRequest
): IgniteControlledRuntimeDefaultPathApplyDryRunReceipt {
    let nonClaims = igniteControlledRuntimeDefaultPathApplyDryRunNonClaims()
    if (!applyGateReceipt.applyGateAccepted) {
        return IgniteControlledRuntimeDefaultPathApplyDryRunReceipt(
            false,
            applyGateReceipt.applyGateAccepted,
            applyGateReceipt.applyGateMode,
            "none",
            request.controlledRuntimeDefaultPathApplyDryRunId,
            applyGateReceipt.applyGateId,
            applyGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-apply-gate",
            "collect-accepted-runtime-default-path-apply-gate-first",
            ["RUNTIME_DEFAULT_PATH_APPLY_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0562 apply gate before controlled apply dry-run consumption",
            "QUIC must not consume controlled runtime default-path apply dry-run gates from rejected apply-gate receipts"
        )
    }

    let controlledApplyDryRunMode =
        igniteControlledRuntimeDefaultPathApplyDryRunModeFor(
            applyGateReceipt.applyGateMode
        )
    let blockers = igniteControlledRuntimeDefaultPathApplyDryRunBlockers(
        request,
        controlledApplyDryRunMode
    )
    if (blockers.size > 0) {
        return IgniteControlledRuntimeDefaultPathApplyDryRunReceipt(
            false,
            applyGateReceipt.applyGateAccepted,
            applyGateReceipt.applyGateMode,
            controlledApplyDryRunMode,
            request.controlledRuntimeDefaultPathApplyDryRunId,
            applyGateReceipt.applyGateId,
            applyGateReceipt,
            false,
            "block",
            "blocked-controlled-runtime-default-path-apply-dry-run-input",
            "fix-controlled-runtime-default-path-apply-dry-run-before-acceptance",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry controlled dry-run scope, execution order, control-plane marker, rollback plan, audit marker, observability marker, operator acknowledgement, and keep default mutation out",
            "QUIC can reuse controlled apply dry-run blockers before stream default-path staging gates"
        )
    }

    IgniteControlledRuntimeDefaultPathApplyDryRunReceipt(
        true,
        applyGateReceipt.applyGateAccepted,
        applyGateReceipt.applyGateMode,
        controlledApplyDryRunMode,
        request.controlledRuntimeDefaultPathApplyDryRunId,
        applyGateReceipt.applyGateId,
        applyGateReceipt,
        true,
        "record-controlled-runtime-default-path-apply-dry-run",
        "accepted-controlled-runtime-default-path-apply-dry-run-receipt",
        "controlled-apply-dry-run-ready-without-runtime-default-path-mutation",
        [],
        true,
        false,
        false,
        false,
        false,
        false,
        false,
        nonClaims,
        "next packet may prove controlled apply dry-run acceptance or staging handoff without flipping defaults or mutating config",
        "QUIC can reuse the controlled apply dry-run modes before stream runtime default-path staging gates"
    )
}

func igniteControlledRuntimeDefaultPathApplyDryRunModeFor(
    applyGateMode: String
): String {
    if (applyGateMode == "short-runtime-default-path-apply-gate") {
        return "short-controlled-runtime-default-path-apply-dry-run"
    }
    if (applyGateMode == "long-runtime-default-path-apply-gate") {
        return "long-controlled-runtime-default-path-apply-dry-run"
    }
    if (
        applyGateMode ==
        "blocking-isolation-runtime-default-path-apply-gate"
    ) {
        return "blocking-isolation-controlled-runtime-default-path-apply-dry-run"
    }
    "unknown-controlled-runtime-default-path-apply-dry-run"
}

func igniteControlledRuntimeDefaultPathApplyDryRunBlockers(
    request: IgniteControlledRuntimeDefaultPathApplyDryRunRequest,
    controlledApplyDryRunMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.controlledRuntimeDefaultPathApplyDryRunId.size == 0) {
        blockers.add(
            "CONTROLLED_RUNTIME_DEFAULT_PATH_APPLY_DRY_RUN_ID_NOT_CARRIED"
        )
    }
    if (!request.runtimeDefaultPathApplyGateReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_APPLY_GATE_RECEIPT_NOT_CARRIED")
    }
    if (!request.controlledApplyDryRunScopeCarried) {
        blockers.add("CONTROLLED_APPLY_DRY_RUN_SCOPE_NOT_CARRIED")
    }
    if (!request.dryRunExecutionOrderCarried) {
        blockers.add("DRY_RUN_EXECUTION_ORDER_NOT_CARRIED")
    }
    if (!request.controlPlaneMarkerCarried) {
        blockers.add("CONTROL_PLANE_MARKER_NOT_CARRIED")
    }
    if (!request.rollbackPlanCarried) {
        blockers.add("ROLLBACK_PLAN_NOT_CARRIED")
    }
    if (!request.auditMarkerCarried) {
        blockers.add("AUDIT_MARKER_NOT_CARRIED")
    }
    if (!request.observabilityMarkerCarried) {
        blockers.add("OBSERVABILITY_MARKER_NOT_CARRIED")
    }
    if (!request.operatorAcknowledgementCarried) {
        blockers.add("OPERATOR_ACKNOWLEDGEMENT_NOT_CARRIED")
    }
    if (!request.blockingIsolationModePreserved) {
        blockers.add("BLOCKING_ISOLATION_MODE_NOT_PRESERVED")
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
        controlledApplyDryRunMode ==
        "unknown-controlled-runtime-default-path-apply-dry-run"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_APPLY_GATE_MODE")
    }
    blockers.toArray()
}

func igniteControlledRuntimeDefaultPathApplyDryRunNonClaims(): Array<String> {
    igniteRuntimeDefaultPathApplyGateNonClaims()
}

public class IgniteA2RuntimeExecutionWiringCloseRequest {
    public let a2CloseId: String
    public let controlledApplyDryRunReceiptCarried: Bool
    public let productionQueueMutationBoundaryCarried: Bool
    public let liveExecutorEnqueueBoundaryCarried: Bool
    public let runtimeTaskSpawnBoundaryCarried: Bool
    public let handlerInvocationBoundaryCarried: Bool
    public let requestContextMutationBoundaryCarried: Bool
    public let responseWriteBoundaryCarried: Bool
    public let transportCommitBoundaryCarried: Bool
    public let liveServerWiringBoundaryCarried: Bool
    public let defaultPathApplyDryRunBoundaryCarried: Bool
    public let current0800NonDefaultFlipScopeCarried: Bool
    public let acceptedPreviousGateEvidenceCarried: Bool
    public let realRuntimeProofGapsRecorded: Bool
    public let nextMacroTargetRecorded: Bool
    public let actualDefaultEngineFlipRequested: Bool
    public let defaultEngineConfigMutationRequested: Bool
    public let runtimeDefaultPathMutationRequested: Bool
    public let stdxRemovalRequested: Bool
    public let h1NativeDefaultClaimed: Bool
    public let h2RuntimeClosureClaimed: Bool
    public let nativeClientClosureClaimed: Bool
    public let jsonSourceZeroClaimed: Bool
    public let compressionReplacementClaimed: Bool
    public let websocketSseReplacementClaimed: Bool
    public let ioDriverLisiCompletionClaimed: Bool
    public let publicApiPerformanceReleaseOrHostedClaimed: Bool
    public let sourceOwnedHaomoNavIngestClaimed: Bool
    public let odAuditAcceptanceClaimed: Bool

    public init(
        a2CloseId: String,
        controlledApplyDryRunReceiptCarried: Bool,
        productionQueueMutationBoundaryCarried: Bool,
        liveExecutorEnqueueBoundaryCarried: Bool,
        runtimeTaskSpawnBoundaryCarried: Bool,
        handlerInvocationBoundaryCarried: Bool,
        requestContextMutationBoundaryCarried: Bool,
        responseWriteBoundaryCarried: Bool,
        transportCommitBoundaryCarried: Bool,
        liveServerWiringBoundaryCarried: Bool,
        defaultPathApplyDryRunBoundaryCarried: Bool,
        current0800NonDefaultFlipScopeCarried: Bool,
        acceptedPreviousGateEvidenceCarried: Bool,
        realRuntimeProofGapsRecorded: Bool,
        nextMacroTargetRecorded: Bool,
        actualDefaultEngineFlipRequested: Bool,
        defaultEngineConfigMutationRequested: Bool,
        runtimeDefaultPathMutationRequested: Bool,
        stdxRemovalRequested: Bool,
        h1NativeDefaultClaimed: Bool,
        h2RuntimeClosureClaimed: Bool,
        nativeClientClosureClaimed: Bool,
        jsonSourceZeroClaimed: Bool,
        compressionReplacementClaimed: Bool,
        websocketSseReplacementClaimed: Bool,
        ioDriverLisiCompletionClaimed: Bool,
        publicApiPerformanceReleaseOrHostedClaimed: Bool,
        sourceOwnedHaomoNavIngestClaimed: Bool,
        odAuditAcceptanceClaimed: Bool
    ) {
        this.a2CloseId = a2CloseId
        this.controlledApplyDryRunReceiptCarried =
            controlledApplyDryRunReceiptCarried
        this.productionQueueMutationBoundaryCarried =
            productionQueueMutationBoundaryCarried
        this.liveExecutorEnqueueBoundaryCarried =
            liveExecutorEnqueueBoundaryCarried
        this.runtimeTaskSpawnBoundaryCarried = runtimeTaskSpawnBoundaryCarried
        this.handlerInvocationBoundaryCarried =
            handlerInvocationBoundaryCarried
        this.requestContextMutationBoundaryCarried =
            requestContextMutationBoundaryCarried
        this.responseWriteBoundaryCarried = responseWriteBoundaryCarried
        this.transportCommitBoundaryCarried = transportCommitBoundaryCarried
        this.liveServerWiringBoundaryCarried = liveServerWiringBoundaryCarried
        this.defaultPathApplyDryRunBoundaryCarried =
            defaultPathApplyDryRunBoundaryCarried
        this.current0800NonDefaultFlipScopeCarried =
            current0800NonDefaultFlipScopeCarried
        this.acceptedPreviousGateEvidenceCarried =
            acceptedPreviousGateEvidenceCarried
        this.realRuntimeProofGapsRecorded = realRuntimeProofGapsRecorded
        this.nextMacroTargetRecorded = nextMacroTargetRecorded
        this.actualDefaultEngineFlipRequested =
            actualDefaultEngineFlipRequested
        this.defaultEngineConfigMutationRequested =
            defaultEngineConfigMutationRequested
        this.runtimeDefaultPathMutationRequested =
            runtimeDefaultPathMutationRequested
        this.stdxRemovalRequested = stdxRemovalRequested
        this.h1NativeDefaultClaimed = h1NativeDefaultClaimed
        this.h2RuntimeClosureClaimed = h2RuntimeClosureClaimed
        this.nativeClientClosureClaimed = nativeClientClosureClaimed
        this.jsonSourceZeroClaimed = jsonSourceZeroClaimed
        this.compressionReplacementClaimed = compressionReplacementClaimed
        this.websocketSseReplacementClaimed = websocketSseReplacementClaimed
        this.ioDriverLisiCompletionClaimed = ioDriverLisiCompletionClaimed
        this.publicApiPerformanceReleaseOrHostedClaimed =
            publicApiPerformanceReleaseOrHostedClaimed
        this.sourceOwnedHaomoNavIngestClaimed =
            sourceOwnedHaomoNavIngestClaimed
        this.odAuditAcceptanceClaimed = odAuditAcceptanceClaimed
    }
}

public class IgniteA2RuntimeExecutionWiringCloseReceipt {
    public let a2RuntimeExecutionWiringCloseAccepted: Bool
    public let controlledRuntimeDefaultPathApplyDryRunAccepted: Bool
    public let controlledRuntimeDefaultPathApplyDryRunMode: String
    public let a2RuntimeExecutionWiringCloseMode: String
    public let a2CloseId: String
    public let controlledRuntimeDefaultPathApplyDryRunId: String
    public let controlledApplyDryRunReceipt: IgniteControlledRuntimeDefaultPathApplyDryRunReceipt
    public let acceptedSurfaces: Array<String>
    public let unverifiedRuntimeProofs: Array<String>
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeExecutionWiringCloseAllowed: Bool
    public let a2ClosedForCurrent0800NonDefaultFlipScope: Bool
    public let actualDefaultEngineFlipAllowed: Bool
    public let defaultEngineConfigMutationAllowed: Bool
    public let runtimeDefaultPathMutationAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let h1NativeDefaultClaimAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
    public let nativeClientClosureClaimAllowed: Bool
    public let jsonSourceZeroClaimAllowed: Bool
    public let compressionReplacementClaimAllowed: Bool
    public let websocketSseReplacementClaimAllowed: Bool
    public let ioDriverLisiCompletionClaimAllowed: Bool
    public let publicApiPerformanceReleaseOrHostedClaimAllowed: Bool
    public let sourceOwnedHaomoNavIngestClaimAllowed: Bool
    public let odAuditAcceptanceClaimAllowed: Bool
    public let nonClaims: Array<String>
    public let nextMacroTarget: String
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        a2RuntimeExecutionWiringCloseAccepted: Bool,
        controlledRuntimeDefaultPathApplyDryRunAccepted: Bool,
        controlledRuntimeDefaultPathApplyDryRunMode: String,
        a2RuntimeExecutionWiringCloseMode: String,
        a2CloseId: String,
        controlledRuntimeDefaultPathApplyDryRunId: String,
        controlledApplyDryRunReceipt: IgniteControlledRuntimeDefaultPathApplyDryRunReceipt,
        acceptedSurfaces: Array<String>,
        unverifiedRuntimeProofs: Array<String>,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeExecutionWiringCloseAllowed: Bool,
        a2ClosedForCurrent0800NonDefaultFlipScope: Bool,
        actualDefaultEngineFlipAllowed: Bool,
        defaultEngineConfigMutationAllowed: Bool,
        runtimeDefaultPathMutationAllowed: Bool,
        stdxRemovalAllowed: Bool,
        h1NativeDefaultClaimAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
        nativeClientClosureClaimAllowed: Bool,
        jsonSourceZeroClaimAllowed: Bool,
        compressionReplacementClaimAllowed: Bool,
        websocketSseReplacementClaimAllowed: Bool,
        ioDriverLisiCompletionClaimAllowed: Bool,
        publicApiPerformanceReleaseOrHostedClaimAllowed: Bool,
        sourceOwnedHaomoNavIngestClaimAllowed: Bool,
        odAuditAcceptanceClaimAllowed: Bool,
        nonClaims: Array<String>,
        nextMacroTarget: String,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.a2RuntimeExecutionWiringCloseAccepted =
            a2RuntimeExecutionWiringCloseAccepted
        this.controlledRuntimeDefaultPathApplyDryRunAccepted =
            controlledRuntimeDefaultPathApplyDryRunAccepted
        this.controlledRuntimeDefaultPathApplyDryRunMode =
            controlledRuntimeDefaultPathApplyDryRunMode
        this.a2RuntimeExecutionWiringCloseMode =
            a2RuntimeExecutionWiringCloseMode
        this.a2CloseId = a2CloseId
        this.controlledRuntimeDefaultPathApplyDryRunId =
            controlledRuntimeDefaultPathApplyDryRunId
        this.controlledApplyDryRunReceipt = controlledApplyDryRunReceipt
        this.acceptedSurfaces = acceptedSurfaces.clone()
        this.unverifiedRuntimeProofs = unverifiedRuntimeProofs.clone()
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeExecutionWiringCloseAllowed =
            runtimeExecutionWiringCloseAllowed
        this.a2ClosedForCurrent0800NonDefaultFlipScope =
            a2ClosedForCurrent0800NonDefaultFlipScope
        this.actualDefaultEngineFlipAllowed = actualDefaultEngineFlipAllowed
        this.defaultEngineConfigMutationAllowed =
            defaultEngineConfigMutationAllowed
        this.runtimeDefaultPathMutationAllowed =
            runtimeDefaultPathMutationAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.h1NativeDefaultClaimAllowed = h1NativeDefaultClaimAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.nativeClientClosureClaimAllowed = nativeClientClosureClaimAllowed
        this.jsonSourceZeroClaimAllowed = jsonSourceZeroClaimAllowed
        this.compressionReplacementClaimAllowed =
            compressionReplacementClaimAllowed
        this.websocketSseReplacementClaimAllowed =
            websocketSseReplacementClaimAllowed
        this.ioDriverLisiCompletionClaimAllowed =
            ioDriverLisiCompletionClaimAllowed
        this.publicApiPerformanceReleaseOrHostedClaimAllowed =
            publicApiPerformanceReleaseOrHostedClaimAllowed
        this.sourceOwnedHaomoNavIngestClaimAllowed =
            sourceOwnedHaomoNavIngestClaimAllowed
        this.odAuditAcceptanceClaimAllowed = odAuditAcceptanceClaimAllowed
        this.nonClaims = nonClaims.clone()
        this.nextMacroTarget = nextMacroTarget
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteA2RuntimeExecutionWiringCloseReceipt(
    controlledApplyDryRunReceipt: IgniteControlledRuntimeDefaultPathApplyDryRunReceipt,
    request: IgniteA2RuntimeExecutionWiringCloseRequest
): IgniteA2RuntimeExecutionWiringCloseReceipt {
    let nonClaims = igniteA2RuntimeExecutionWiringCloseNonClaims()
    let unverifiedRuntimeProofs =
        igniteA2RuntimeExecutionWiringUnverifiedRuntimeProofs()
    if (!controlledApplyDryRunReceipt.controlledRuntimeDefaultPathApplyDryRunAccepted) {
        return IgniteA2RuntimeExecutionWiringCloseReceipt(
            false,
            controlledApplyDryRunReceipt
                .controlledRuntimeDefaultPathApplyDryRunAccepted,
            controlledApplyDryRunReceipt
                .controlledRuntimeDefaultPathApplyDryRunMode,
            "none",
            request.a2CloseId,
            controlledApplyDryRunReceipt
                .controlledRuntimeDefaultPathApplyDryRunId,
            controlledApplyDryRunReceipt,
            [],
            unverifiedRuntimeProofs,
            "block",
            "blocked-controlled-runtime-default-path-apply-dry-run",
            "collect-accepted-controlled-runtime-default-path-apply-dry-run-first",
            ["CONTROLLED_RUNTIME_DEFAULT_PATH_APPLY_DRY_RUN_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
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
            "HQ-0564-remains-live",
            "return to HQ-0563 controlled apply dry-run before A2 closeout",
            "QUIC must not consume A2 runtime execution wiring close receipts from rejected controlled apply dry-run receipts"
        )
    }

    let closeMode = igniteA2RuntimeExecutionWiringCloseModeFor(
        controlledApplyDryRunReceipt.controlledRuntimeDefaultPathApplyDryRunMode
    )
    let blockers = igniteA2RuntimeExecutionWiringCloseBlockers(
        request,
        closeMode
    )
    let acceptedSurfaces =
        igniteA2RuntimeExecutionWiringAcceptedSurfaces(request)
    if (blockers.size > 0) {
        return IgniteA2RuntimeExecutionWiringCloseReceipt(
            false,
            controlledApplyDryRunReceipt
                .controlledRuntimeDefaultPathApplyDryRunAccepted,
            controlledApplyDryRunReceipt
                .controlledRuntimeDefaultPathApplyDryRunMode,
            closeMode,
            request.a2CloseId,
            controlledApplyDryRunReceipt
                .controlledRuntimeDefaultPathApplyDryRunId,
            controlledApplyDryRunReceipt,
            acceptedSurfaces,
            unverifiedRuntimeProofs,
            "block",
            "blocked-a2-runtime-execution-wiring-close-input",
            "fix-a2-runtime-execution-wiring-close-matrix-before-acceptance",
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
            false,
            false,
            nonClaims,
            "HQ-0564-remains-live",
            "carry all nine A2 surfaces, non-default-flip scope, previous gate evidence, real runtime proof gaps, next macro target, and keep overclaims out",
            "QUIC can reuse A2 close blockers before stream runtime execution wiring closeout"
        )
    }

    IgniteA2RuntimeExecutionWiringCloseReceipt(
        true,
        controlledApplyDryRunReceipt
            .controlledRuntimeDefaultPathApplyDryRunAccepted,
        controlledApplyDryRunReceipt
            .controlledRuntimeDefaultPathApplyDryRunMode,
        closeMode,
        request.a2CloseId,
        controlledApplyDryRunReceipt.controlledRuntimeDefaultPathApplyDryRunId,
        controlledApplyDryRunReceipt,
        acceptedSurfaces,
        unverifiedRuntimeProofs,
        "record-a2-runtime-execution-wiring-standard-close",
        "accepted-a2-runtime-execution-wiring-close-receipt",
        "A2 accepted for current 0800 non-default-flip scope",
        [],
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
        nonClaims,
        "return-to-ig0800-big-order-queue-with-fresh-standard-packet",
        "close HQ-0564, park A2, and reopen the next macro target without reusing the micro-receipt suffix chain",
        "QUIC can reuse the A2 close matrix as execution-wiring prior art without claiming H1/H2/QUIC runtime closure"
    )
}

func igniteA2RuntimeExecutionWiringCloseModeFor(
    controlledApplyDryRunMode: String
): String {
    if (
        controlledApplyDryRunMode ==
        "short-controlled-runtime-default-path-apply-dry-run"
    ) {
        return "short-a2-runtime-execution-wiring-close"
    }
    if (
        controlledApplyDryRunMode ==
        "long-controlled-runtime-default-path-apply-dry-run"
    ) {
        return "long-a2-runtime-execution-wiring-close"
    }
    if (
        controlledApplyDryRunMode ==
        "blocking-isolation-controlled-runtime-default-path-apply-dry-run"
    ) {
        return "blocking-isolation-a2-runtime-execution-wiring-close"
    }
    "unknown-a2-runtime-execution-wiring-close"
}

func igniteA2RuntimeExecutionWiringAcceptedSurfaces(
    request: IgniteA2RuntimeExecutionWiringCloseRequest
): Array<String> {
    var surfaces = ArrayList<String>()
    if (request.productionQueueMutationBoundaryCarried) {
        surfaces.add("production-queue-mutation-boundary")
    }
    if (request.liveExecutorEnqueueBoundaryCarried) {
        surfaces.add("live-executor-enqueue-boundary")
    }
    if (request.runtimeTaskSpawnBoundaryCarried) {
        surfaces.add("runtime-task-spawn-boundary")
    }
    if (request.handlerInvocationBoundaryCarried) {
        surfaces.add("handler-invocation-boundary")
    }
    if (request.requestContextMutationBoundaryCarried) {
        surfaces.add("request-context-mutation-boundary")
    }
    if (request.responseWriteBoundaryCarried) {
        surfaces.add("response-write-boundary")
    }
    if (request.transportCommitBoundaryCarried) {
        surfaces.add("transport-commit-boundary")
    }
    if (request.liveServerWiringBoundaryCarried) {
        surfaces.add("live-server-wiring-boundary")
    }
    if (request.defaultPathApplyDryRunBoundaryCarried) {
        surfaces.add("default-path-apply-dry-run-boundary")
    }
    surfaces.toArray()
}

func igniteA2RuntimeExecutionWiringCloseBlockers(
    request: IgniteA2RuntimeExecutionWiringCloseRequest,
    closeMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.a2CloseId.size == 0) {
        blockers.add("A2_RUNTIME_EXECUTION_WIRING_CLOSE_ID_NOT_CARRIED")
    }
    if (!request.controlledApplyDryRunReceiptCarried) {
        blockers.add("CONTROLLED_APPLY_DRY_RUN_RECEIPT_NOT_CARRIED")
    }
    if (!request.productionQueueMutationBoundaryCarried) {
        blockers.add("PRODUCTION_QUEUE_MUTATION_BOUNDARY_NOT_CARRIED")
    }
    if (!request.liveExecutorEnqueueBoundaryCarried) {
        blockers.add("LIVE_EXECUTOR_ENQUEUE_BOUNDARY_NOT_CARRIED")
    }
    if (!request.runtimeTaskSpawnBoundaryCarried) {
        blockers.add("RUNTIME_TASK_SPAWN_BOUNDARY_NOT_CARRIED")
    }
    if (!request.handlerInvocationBoundaryCarried) {
        blockers.add("HANDLER_INVOCATION_BOUNDARY_NOT_CARRIED")
    }
    if (!request.requestContextMutationBoundaryCarried) {
        blockers.add("REQUEST_CONTEXT_MUTATION_BOUNDARY_NOT_CARRIED")
    }
    if (!request.responseWriteBoundaryCarried) {
        blockers.add("RESPONSE_WRITE_BOUNDARY_NOT_CARRIED")
    }
    if (!request.transportCommitBoundaryCarried) {
        blockers.add("TRANSPORT_COMMIT_BOUNDARY_NOT_CARRIED")
    }
    if (!request.liveServerWiringBoundaryCarried) {
        blockers.add("LIVE_SERVER_WIRING_BOUNDARY_NOT_CARRIED")
    }
    if (!request.defaultPathApplyDryRunBoundaryCarried) {
        blockers.add("DEFAULT_PATH_APPLY_DRY_RUN_BOUNDARY_NOT_CARRIED")
    }
    if (!request.current0800NonDefaultFlipScopeCarried) {
        blockers.add("CURRENT_0800_NON_DEFAULT_FLIP_SCOPE_NOT_CARRIED")
    }
    if (!request.acceptedPreviousGateEvidenceCarried) {
        blockers.add("ACCEPTED_PREVIOUS_GATE_EVIDENCE_NOT_CARRIED")
    }
    if (!request.realRuntimeProofGapsRecorded) {
        blockers.add("REAL_RUNTIME_PROOF_GAPS_NOT_RECORDED")
    }
    if (!request.nextMacroTargetRecorded) {
        blockers.add("NEXT_MACRO_TARGET_NOT_RECORDED")
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
    if (request.stdxRemovalRequested) {
        blockers.add("STDX_REMOVAL_REQUESTED")
    }
    if (request.h1NativeDefaultClaimed) {
        blockers.add("H1_NATIVE_DEFAULT_CLAIMED")
    }
    if (request.h2RuntimeClosureClaimed) {
        blockers.add("H2_RUNTIME_CLOSURE_CLAIMED")
    }
    if (request.nativeClientClosureClaimed) {
        blockers.add("NATIVE_CLIENT_CLOSURE_CLAIMED")
    }
    if (request.jsonSourceZeroClaimed) {
        blockers.add("JSON_SOURCE_ZERO_CLAIMED")
    }
    if (request.compressionReplacementClaimed) {
        blockers.add("COMPRESSION_REPLACEMENT_CLAIMED")
    }
    if (request.websocketSseReplacementClaimed) {
        blockers.add("WEBSOCKET_SSE_REPLACEMENT_CLAIMED")
    }
    if (request.ioDriverLisiCompletionClaimed) {
        blockers.add("IODRIVER_LISI_COMPLETION_CLAIMED")
    }
    if (request.publicApiPerformanceReleaseOrHostedClaimed) {
        blockers.add("PUBLIC_API_PERFORMANCE_RELEASE_OR_HOSTED_CLAIMED")
    }
    if (request.sourceOwnedHaomoNavIngestClaimed) {
        blockers.add("SOURCE_OWNED_HAOMONAV_INGEST_CLAIMED")
    }
    if (request.odAuditAcceptanceClaimed) {
        blockers.add("OD_AUDIT_ACCEPTANCE_CLAIMED")
    }
    if (closeMode == "unknown-a2-runtime-execution-wiring-close") {
        blockers.add("UNKNOWN_CONTROLLED_APPLY_DRY_RUN_MODE")
    }
    blockers.toArray()
}

func igniteA2RuntimeExecutionWiringUnverifiedRuntimeProofs(): Array<String> {
    [
        "ACTUAL_RUNTIME_TASK_SPAWN_NOT_CLAIMED",
        "ACTUAL_HANDLER_INVOCATION_NOT_CLAIMED",
        "ACTUAL_REQUEST_CONTEXT_MUTATION_NOT_CLAIMED",
        "ACTUAL_RESPONSE_WRITE_NOT_CLAIMED",
        "ACTUAL_TRANSPORT_COMMIT_NOT_CLAIMED",
        "ACTUAL_LIVE_SERVER_DEFAULT_WIRING_NOT_CLAIMED",
        "ACTUAL_DEFAULT_ENGINE_FLIP_NOT_CLAIMED",
        "STDX_REMOVAL_NOT_CLAIMED",
    ]
}

func igniteA2RuntimeExecutionWiringCloseNonClaims(): Array<String> {
    [
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
        "NO_DEFAULT_ENGINE_CONFIG_MUTATION",
        "NO_RUNTIME_DEFAULT_PATH_MUTATION",
        "NO_STDX_REMOVAL",
        "NO_H1_NATIVE_DEFAULT_CLAIM",
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_NATIVE_CLIENT_CLOSURE_CLAIM",
        "NO_JSON_SOURCE_ZERO_CLAIM",
        "NO_COMPRESSION_REPLACEMENT_CLAIM",
        "NO_WEBSOCKET_SSE_REPLACEMENT_CLAIM",
        "NO_IODRIVER_LISI_COMPLETION_CLAIM",
        "NO_PUBLIC_API_PERFORMANCE_RELEASE_OR_HOSTED_PUBLICATION_CLAIM",
        "NO_SOURCE_OWNED_HAOMONAV_INGEST_CLAIM",
        "NO_OD_AUDIT_ACCEPTANCE_CLAIM",
    ]
}

public class IgniteStdxReplacementClaimGateRequest {
    public let replacementGateId: String
    public let stdxImportInventoryCarried: Bool
    public let runtimeReplacementPlanCarried: Bool
    public let sourceZeroReplacementPlanCarried: Bool
    public let h1ServerDefaultFlipProofCarried: Bool
    public let h1ClientNativeProofCarried: Bool
    public let h2ServerRuntimeClosureProofCarried: Bool
    public let h2ClientNativeProofCarried: Bool
    public let jinguisslTlsProviderProofCarried: Bool
    public let ioDriverBackendProofCarried: Bool
    public let proxyTransportNativeProofCarried: Bool
    public let seaJsonBridgeProofCarried: Bool
    public let compressionNativeProofCarried: Bool
    public let websocketNativeProofCarried: Bool
    public let testOnlyStdxSurfaceClassified: Bool
    public let publicDocsAndRollbackProofCarried: Bool
    public let runtimeStdxReplacementClaimRequested: Bool
    public let sourceZeroStdxClaimRequested: Bool
    public let publicReleaseClaimRequested: Bool
    public let stdxRemovalRequested: Bool

    public init(
        replacementGateId: String,
        stdxImportInventoryCarried: Bool,
        runtimeReplacementPlanCarried: Bool,
        sourceZeroReplacementPlanCarried: Bool,
        h1ServerDefaultFlipProofCarried: Bool,
        h1ClientNativeProofCarried: Bool,
        h2ServerRuntimeClosureProofCarried: Bool,
        h2ClientNativeProofCarried: Bool,
        jinguisslTlsProviderProofCarried: Bool,
        ioDriverBackendProofCarried: Bool,
        proxyTransportNativeProofCarried: Bool,
        seaJsonBridgeProofCarried: Bool,
        compressionNativeProofCarried: Bool,
        websocketNativeProofCarried: Bool,
        testOnlyStdxSurfaceClassified: Bool,
        publicDocsAndRollbackProofCarried: Bool,
        runtimeStdxReplacementClaimRequested: Bool,
        sourceZeroStdxClaimRequested: Bool,
        publicReleaseClaimRequested: Bool,
        stdxRemovalRequested: Bool
    ) {
        this.replacementGateId = replacementGateId
        this.stdxImportInventoryCarried = stdxImportInventoryCarried
        this.runtimeReplacementPlanCarried = runtimeReplacementPlanCarried
        this.sourceZeroReplacementPlanCarried = sourceZeroReplacementPlanCarried
        this.h1ServerDefaultFlipProofCarried = h1ServerDefaultFlipProofCarried
        this.h1ClientNativeProofCarried = h1ClientNativeProofCarried
        this.h2ServerRuntimeClosureProofCarried =
            h2ServerRuntimeClosureProofCarried
        this.h2ClientNativeProofCarried = h2ClientNativeProofCarried
        this.jinguisslTlsProviderProofCarried =
            jinguisslTlsProviderProofCarried
        this.ioDriverBackendProofCarried = ioDriverBackendProofCarried
        this.proxyTransportNativeProofCarried =
            proxyTransportNativeProofCarried
        this.seaJsonBridgeProofCarried = seaJsonBridgeProofCarried
        this.compressionNativeProofCarried = compressionNativeProofCarried
        this.websocketNativeProofCarried = websocketNativeProofCarried
        this.testOnlyStdxSurfaceClassified = testOnlyStdxSurfaceClassified
        this.publicDocsAndRollbackProofCarried =
            publicDocsAndRollbackProofCarried
        this.runtimeStdxReplacementClaimRequested =
            runtimeStdxReplacementClaimRequested
        this.sourceZeroStdxClaimRequested = sourceZeroStdxClaimRequested
        this.publicReleaseClaimRequested = publicReleaseClaimRequested
        this.stdxRemovalRequested = stdxRemovalRequested
    }
}

public class IgniteStdxReplacementClaimGateReceipt {
    public let stdxReplacementClaimGateAccepted: Bool
    public let replacementGateId: String
    public let claimMode: String
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeStdxReplacementClaimAllowed: Bool
    public let sourceZeroStdxClaimAllowed: Bool
    public let publicReleaseClaimAllowed: Bool
    public let stdxRemovalAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        stdxReplacementClaimGateAccepted: Bool,
        replacementGateId: String,
        claimMode: String,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeStdxReplacementClaimAllowed: Bool,
        sourceZeroStdxClaimAllowed: Bool,
        publicReleaseClaimAllowed: Bool,
        stdxRemovalAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.stdxReplacementClaimGateAccepted =
            stdxReplacementClaimGateAccepted
        this.replacementGateId = replacementGateId
        this.claimMode = claimMode
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeStdxReplacementClaimAllowed =
            runtimeStdxReplacementClaimAllowed
        this.sourceZeroStdxClaimAllowed = sourceZeroStdxClaimAllowed
        this.publicReleaseClaimAllowed = publicReleaseClaimAllowed
        this.stdxRemovalAllowed = stdxRemovalAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteStdxReplacementClaimGateReceipt(
    request: IgniteStdxReplacementClaimGateRequest
): IgniteStdxReplacementClaimGateReceipt {
    let nonClaims = igniteStdxReplacementClaimGateNonClaims()
    let claimMode = igniteStdxReplacementClaimGateMode(request)
    let blockers = igniteStdxReplacementClaimGateBlockers(
        request,
        claimMode
    )
    if (blockers.size > 0) {
        return IgniteStdxReplacementClaimGateReceipt(
            false,
            request.replacementGateId,
            claimMode,
            "block",
            "blocked-stdx-replacement-claim-input",
            "complete-stdx-replacement-evidence-before-claim",
            blockers,
            false,
            false,
            false,
            false,
            nonClaims,
            "fill the missing replacement proof slices before any stdx replacement, source-zero, release, or removal claim",
            "QUIC can reuse this claim gate to separate runtime replacement from source-zero dependency removal"
        )
    }

    if (claimMode == "inventory-only-stdx-replacement-gate") {
        return IgniteStdxReplacementClaimGateReceipt(
            true,
            request.replacementGateId,
            claimMode,
            "record-stdx-replacement-inventory",
            "accepted-stdx-replacement-inventory-receipt",
            "record-inventory-without-replacement-claim",
            [],
            false,
            false,
            false,
            false,
            nonClaims,
            "open one bounded child packet for the next missing replacement proof surface",
            "QUIC can reuse inventory-only gates before claiming transport-family stdx-free status"
        )
    }

    let sourceZeroAllowed = request.sourceZeroStdxClaimRequested ||
        request.stdxRemovalRequested
    let publicReleaseAllowed = request.publicReleaseClaimRequested ||
        request.stdxRemovalRequested
    IgniteStdxReplacementClaimGateReceipt(
        true,
        request.replacementGateId,
        claimMode,
        "record-stdx-replacement-claim-gate",
        "accepted-stdx-replacement-claim-gate-receipt",
        "replacement-claim-gate-ready-without-mutating-dependencies",
        [],
        request.runtimeStdxReplacementClaimRequested ||
            request.sourceZeroStdxClaimRequested ||
            request.publicReleaseClaimRequested ||
            request.stdxRemovalRequested,
        sourceZeroAllowed,
        publicReleaseAllowed,
        request.stdxRemovalRequested,
        nonClaims,
        "claim gate is ready only as evidence; dependency removal, default flip, release, and public docs still need their own packets",
        "QUIC can reuse this as a source-zero claim gate after its stream, flow, fixture, TLS, and IoDriver proofs are complete"
    )
}

func igniteStdxReplacementClaimGateMode(
    request: IgniteStdxReplacementClaimGateRequest
): String {
    if (request.stdxRemovalRequested) {
        return "source-zero-stdx-removal-claim-gate"
    }
    if (request.publicReleaseClaimRequested) {
        return "public-release-stdx-replacement-claim-gate"
    }
    if (request.sourceZeroStdxClaimRequested) {
        return "source-zero-stdx-replacement-claim-gate"
    }
    if (request.runtimeStdxReplacementClaimRequested) {
        return "runtime-stdx-replacement-claim-gate"
    }
    "inventory-only-stdx-replacement-gate"
}

func igniteStdxReplacementClaimGateBlockers(
    request: IgniteStdxReplacementClaimGateRequest,
    claimMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.replacementGateId.size == 0) {
        blockers.add("STDX_REPLACEMENT_GATE_ID_NOT_CARRIED")
    }
    if (!request.stdxImportInventoryCarried) {
        blockers.add("STDX_IMPORT_INVENTORY_NOT_CARRIED")
    }
    if (claimMode != "inventory-only-stdx-replacement-gate") {
        igniteStdxReplacementClaimGateAddRuntimeBlockers(request, blockers)
    }
    if (
        claimMode == "source-zero-stdx-replacement-claim-gate" ||
        claimMode == "public-release-stdx-replacement-claim-gate" ||
        claimMode == "source-zero-stdx-removal-claim-gate"
    ) {
        igniteStdxReplacementClaimGateAddSourceZeroBlockers(request, blockers)
    }
    if (
        claimMode == "public-release-stdx-replacement-claim-gate" ||
        claimMode == "source-zero-stdx-removal-claim-gate"
    ) {
        if (!request.publicDocsAndRollbackProofCarried) {
            blockers.add("PUBLIC_DOCS_AND_ROLLBACK_PROOF_NOT_CARRIED")
        }
    }
    blockers.toArray()
}

func igniteStdxReplacementClaimGateAddRuntimeBlockers(
    request: IgniteStdxReplacementClaimGateRequest,
    blockers: ArrayList<String>
): Unit {
    if (!request.runtimeReplacementPlanCarried) {
        blockers.add("RUNTIME_REPLACEMENT_PLAN_NOT_CARRIED")
    }
    if (!request.h1ServerDefaultFlipProofCarried) {
        blockers.add("H1_SERVER_DEFAULT_FLIP_PROOF_NOT_CARRIED")
    }
    if (!request.h1ClientNativeProofCarried) {
        blockers.add("H1_CLIENT_NATIVE_PROOF_NOT_CARRIED")
    }
    if (!request.h2ServerRuntimeClosureProofCarried) {
        blockers.add("H2_SERVER_RUNTIME_CLOSURE_PROOF_NOT_CARRIED")
    }
    if (!request.h2ClientNativeProofCarried) {
        blockers.add("H2_CLIENT_NATIVE_PROOF_NOT_CARRIED")
    }
    if (!request.jinguisslTlsProviderProofCarried) {
        blockers.add("JINGUISSL_TLS_PROVIDER_PROOF_NOT_CARRIED")
    }
    if (!request.ioDriverBackendProofCarried) {
        blockers.add("IODRIVER_BACKEND_PROOF_NOT_CARRIED")
    }
    if (!request.proxyTransportNativeProofCarried) {
        blockers.add("PROXY_TRANSPORT_NATIVE_PROOF_NOT_CARRIED")
    }
}

func igniteStdxReplacementClaimGateAddSourceZeroBlockers(
    request: IgniteStdxReplacementClaimGateRequest,
    blockers: ArrayList<String>
): Unit {
    if (!request.sourceZeroReplacementPlanCarried) {
        blockers.add("SOURCE_ZERO_REPLACEMENT_PLAN_NOT_CARRIED")
    }
    if (!request.seaJsonBridgeProofCarried) {
        blockers.add("SEAJSON_BRIDGE_PROOF_NOT_CARRIED")
    }
    if (!request.compressionNativeProofCarried) {
        blockers.add("COMPRESSION_NATIVE_PROOF_NOT_CARRIED")
    }
    if (!request.websocketNativeProofCarried) {
        blockers.add("WEBSOCKET_NATIVE_PROOF_NOT_CARRIED")
    }
    if (!request.testOnlyStdxSurfaceClassified) {
        blockers.add("TEST_ONLY_STDX_SURFACE_NOT_CLASSIFIED")
    }
}

func igniteStdxReplacementClaimGateNonClaims(): Array<String> {
    [
        "NO_STDX_DEPENDENCY_REMOVAL",
        "NO_DEFAULT_ENGINE_FLIP",
        "NO_PUBLIC_RELEASE",
        "NO_SOURCE_ZERO_STDX_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
    ]
}

public class JinguiAcceptedTransportH2DiagnosticOnlyHandoffEvidence {
    public let launchGate: JinguiAcceptedTransportH2RuntimeProofLaunchGate
    public let providerOwner: String
    public let providerFailureCode: String
    public let explicitStopConditionCarried: Bool
    public let diagnosticScope: String

    public init(
        launchGate: JinguiAcceptedTransportH2RuntimeProofLaunchGate,
        providerOwner: String,
        providerFailureCode: String,
        explicitStopConditionCarried: Bool,
        diagnosticScope: String
    ) {
        this.launchGate = launchGate
        this.providerOwner = providerOwner
        this.providerFailureCode = providerFailureCode
        this.explicitStopConditionCarried = explicitStopConditionCarried
        this.diagnosticScope = diagnosticScope
    }
}

public class JinguiAcceptedTransportH2DiagnosticOnlyHandoff {
    public let diagnosticHandoffAllowed: Bool
    public let h2RuntimeProofLaunchAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
    public let status: String
    public let decision: String
    public let providerOwner: String
    public let providerFailureCode: String
    public let diagnosticScope: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        diagnosticHandoffAllowed: Bool,
        h2RuntimeProofLaunchAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
        status: String,
        decision: String,
        providerOwner: String,
        providerFailureCode: String,
        diagnosticScope: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.diagnosticHandoffAllowed = diagnosticHandoffAllowed
        this.h2RuntimeProofLaunchAllowed = h2RuntimeProofLaunchAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.status = status
        this.decision = decision
        this.providerOwner = providerOwner
        this.providerFailureCode = providerFailureCode
        this.diagnosticScope = diagnosticScope
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2DiagnosticOnlyHandoff(
    evidence: JinguiAcceptedTransportH2DiagnosticOnlyHandoffEvidence
): JinguiAcceptedTransportH2DiagnosticOnlyHandoff {
    let nonClaims =
        jinguiAcceptedTransportH2DiagnosticOnlyHandoffNonClaims()
    if (evidence.launchGate.h2RuntimeProofLaunchAllowed) {
        return JinguiAcceptedTransportH2DiagnosticOnlyHandoff(
            false,
            false,
            false,
            "not-diagnostic-provider-ready",
            "open-runtime-proof-packet-instead-of-diagnostic-handoff",
            evidence.providerOwner,
            evidence.providerFailureCode,
            evidence.diagnosticScope,
            ["RUNTIME_PROOF_LAUNCH_READY"],
            nonClaims,
            "do not label provider-ready runtime launch as diagnostic-only handoff",
            "QUIC should open a runtime proof packet rather than carry a provider blocker when provider proof is ready"
        )
    }
    if (
        evidence.launchGate.status !=
        "diagnostic-only-provider-blocker-carried"
    ) {
        return JinguiAcceptedTransportH2DiagnosticOnlyHandoff(
            false,
            false,
            false,
            "blocked-before-diagnostic-handoff",
            "carry-provider-blocker-before-diagnostic-handoff",
            evidence.providerOwner,
            evidence.providerFailureCode,
            evidence.diagnosticScope,
            jinguiAcceptedTransportH2DiagnosticOnlyHandoffBlockers(evidence),
            nonClaims,
            "carry the provider blocker explicitly before opening diagnostic-only H2 work",
            "QUIC should not run diagnostic packets unless the handshake/provider blocker is explicit"
        )
    }
    if (
        !evidence.explicitStopConditionCarried ||
        evidence.providerFailureCode.size == 0 ||
        evidence.providerOwner.size == 0
    ) {
        return JinguiAcceptedTransportH2DiagnosticOnlyHandoff(
            false,
            false,
            false,
            "blocked-diagnostic-stop-condition-missing",
            "attach-provider-owner-failure-code-and-stop-condition",
            evidence.providerOwner,
            evidence.providerFailureCode,
            evidence.diagnosticScope,
            jinguiAcceptedTransportH2DiagnosticOnlyHandoffBlockers(evidence),
            nonClaims,
            "record provider owner, failure code, and explicit stop condition before diagnostic-only H2 work",
            "QUIC diagnostic handoff must carry owner, failure code, and explicit stop condition"
        )
    }
    JinguiAcceptedTransportH2DiagnosticOnlyHandoff(
        true,
        false,
        false,
        "ready-for-h2-diagnostic-only-handoff",
        "run-diagnostic-only-with-explicit-provider-stop-condition",
        evidence.providerOwner,
        evidence.providerFailureCode,
        evidence.diagnosticScope,
        evidence.launchGate.blockers,
        nonClaims,
        "run only diagnostic H2 work and stop at the carried provider blocker",
        "QUIC can reuse this diagnostic-only handoff for explicit handshake/provider blockers"
    )
}

func jinguiAcceptedTransportH2DiagnosticOnlyHandoffBlockers(
    evidence: JinguiAcceptedTransportH2DiagnosticOnlyHandoffEvidence
): Array<String> {
    var blockers = ArrayList<String>()
    if (evidence.launchGate.status !=
        "diagnostic-only-provider-blocker-carried") {
        blockers.add("LAUNCH_GATE:${evidence.launchGate.status}")
    }
    if (!evidence.explicitStopConditionCarried) {
        blockers.add("MISSING:EXPLICIT_PROVIDER_STOP_CONDITION")
    }
    if (evidence.providerOwner.size == 0) {
        blockers.add("MISSING:PROVIDER_OWNER")
    }
    if (evidence.providerFailureCode.size == 0) {
        blockers.add("MISSING:PROVIDER_FAILURE_CODE")
    }
    for (blocker in evidence.launchGate.blockers) {
        blockers.add(blocker)
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2DiagnosticOnlyHandoffNonClaims(): Array<String> {
    [
        "NO_PROVIDER_FIX",
        "NO_ACCEPTED_TRANSPORT_ATTACH_PASS_CLAIM",
        "NO_H2_RUNTIME_LAUNCH_CLAIM",
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_H2_SCHEDULER_CLAIM",
        "NO_H2SPEC_CLAIM",
    ]
}

public class JinguiAcceptedTransportH2DiagnosticWorkEvidence {
    public let handoff: JinguiAcceptedTransportH2DiagnosticOnlyHandoff
    public let requestedDiagnosticKind: String
    public let modelOnlyDiagnosticProof: Bool
    public let runtimeSocketRequested: Bool
    public let browserReplayRequested: Bool
    public let schedulerRequested: Bool
    public let h2specRequested: Bool

    public init(
        handoff: JinguiAcceptedTransportH2DiagnosticOnlyHandoff,
        requestedDiagnosticKind: String,
        modelOnlyDiagnosticProof: Bool,
        runtimeSocketRequested: Bool,
        browserReplayRequested: Bool,
        schedulerRequested: Bool,
        h2specRequested: Bool
    ) {
        this.handoff = handoff
        this.requestedDiagnosticKind = requestedDiagnosticKind
        this.modelOnlyDiagnosticProof = modelOnlyDiagnosticProof
        this.runtimeSocketRequested = runtimeSocketRequested
        this.browserReplayRequested = browserReplayRequested
        this.schedulerRequested = schedulerRequested
        this.h2specRequested = h2specRequested
    }
}

public class JinguiAcceptedTransportH2DiagnosticWorkGate {
    public let diagnosticWorkAllowed: Bool
    public let h2RuntimeProofLaunchAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
    public let status: String
    public let decision: String
    public let requestedDiagnosticKind: String
    public let allowedDiagnosticKinds: Array<String>
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        diagnosticWorkAllowed: Bool,
        h2RuntimeProofLaunchAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
        status: String,
        decision: String,
        requestedDiagnosticKind: String,
        allowedDiagnosticKinds: Array<String>,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.diagnosticWorkAllowed = diagnosticWorkAllowed
        this.h2RuntimeProofLaunchAllowed = h2RuntimeProofLaunchAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.status = status
        this.decision = decision
        this.requestedDiagnosticKind = requestedDiagnosticKind
        this.allowedDiagnosticKinds = allowedDiagnosticKinds.clone()
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2DiagnosticWorkGate(
    evidence: JinguiAcceptedTransportH2DiagnosticWorkEvidence
): JinguiAcceptedTransportH2DiagnosticWorkGate {
    let allowedKinds = jinguiAcceptedTransportH2DiagnosticWorkAllowedKinds()
    let nonClaims = jinguiAcceptedTransportH2DiagnosticWorkNonClaims()

    if (!evidence.handoff.diagnosticHandoffAllowed) {
        return JinguiAcceptedTransportH2DiagnosticWorkGate(
            false,
            false,
            false,
            "blocked-diagnostic-handoff-not-ready",
            "complete-diagnostic-handoff-before-work",
            evidence.requestedDiagnosticKind,
            allowedKinds,
            jinguiAcceptedTransportH2DiagnosticWorkBlockers(evidence),
            nonClaims,
            "complete the provider-blocker diagnostic handoff before opening diagnostic work",
            "QUIC should not run diagnostics until the provider or handshake blocker handoff is accepted"
        )
    }
    if (
        !jinguiAcceptedTransportH2DiagnosticWorkKindAllowed(
            allowedKinds,
            evidence.requestedDiagnosticKind
        )
    ) {
        return JinguiAcceptedTransportH2DiagnosticWorkGate(
            false,
            false,
            false,
            "blocked-unsupported-diagnostic-kind",
            "choose-supported-model-only-diagnostic-kind",
            evidence.requestedDiagnosticKind,
            allowedKinds,
            jinguiAcceptedTransportH2DiagnosticWorkBlockers(evidence),
            nonClaims,
            "choose header projection, wire fixture, stream lifecycle, flow budget, or provider readiness reprobe diagnostic work",
            "QUIC should keep supported diagnostic kinds explicit before runtime packets"
        )
    }
    if (
        evidence.runtimeSocketRequested ||
        evidence.browserReplayRequested ||
        evidence.schedulerRequested ||
        evidence.h2specRequested
    ) {
        return JinguiAcceptedTransportH2DiagnosticWorkGate(
            false,
            false,
            false,
            "blocked-runtime-scope-in-diagnostic-work",
            "split-runtime-or-closure-work-out-of-diagnostic-gate",
            evidence.requestedDiagnosticKind,
            allowedKinds,
            jinguiAcceptedTransportH2DiagnosticWorkBlockers(evidence),
            nonClaims,
            "split runtime socket, browser replay, scheduler, or h2spec work into later packets after provider readiness",
            "QUIC diagnostics must not smuggle runtime, interop, scheduler, or conformance work through a provider-blocked gate"
        )
    }
    if (!evidence.modelOnlyDiagnosticProof) {
        return JinguiAcceptedTransportH2DiagnosticWorkGate(
            false,
            false,
            false,
            "blocked-model-only-proof-missing",
            "carry-model-only-diagnostic-proof-before-work",
            evidence.requestedDiagnosticKind,
            allowedKinds,
            jinguiAcceptedTransportH2DiagnosticWorkBlockers(evidence),
            nonClaims,
            "record that the diagnostic has no runtime socket, browser replay, scheduler, or h2spec dependency",
            "QUIC diagnostic packets should carry a model-only proof before runtime proof exists"
        )
    }

    JinguiAcceptedTransportH2DiagnosticWorkGate(
        true,
        false,
        false,
        "ready-for-provider-blocked-h2-diagnostic-work",
        "run-model-only-diagnostic-and-stop-at-provider-blocker",
        evidence.requestedDiagnosticKind,
        allowedKinds,
        evidence.handoff.blockers,
        nonClaims,
        "run the bounded model-only diagnostic and stop at the carried provider blocker",
        "QUIC can reuse this gate for model-only diagnostics while handshake/provider readiness is blocked"
    )
}

func jinguiAcceptedTransportH2DiagnosticWorkAllowedKinds(): Array<String> {
    [
        "h2-header-projection-diagnostic",
        "h2-wire-fixture-diagnostic",
        "h2-stream-lifecycle-diagnostic",
        "h2-flow-budget-diagnostic",
        "provider-readiness-reprobe",
    ]
}

func jinguiAcceptedTransportH2DiagnosticWorkKindAllowed(
    allowedKinds: Array<String>,
    requestedDiagnosticKind: String
): Bool {
    for (kind in allowedKinds) {
        if (kind == requestedDiagnosticKind) {
            return true
        }
    }
    false
}

func jinguiAcceptedTransportH2DiagnosticWorkBlockers(
    evidence: JinguiAcceptedTransportH2DiagnosticWorkEvidence
): Array<String> {
    var blockers = ArrayList<String>()
    if (!evidence.handoff.diagnosticHandoffAllowed) {
        blockers.add("HANDOFF:${evidence.handoff.status}")
        for (blocker in evidence.handoff.blockers) {
            blockers.add("HANDOFF_BLOCKER:${blocker}")
        }
    }
    let allowedKinds = jinguiAcceptedTransportH2DiagnosticWorkAllowedKinds()
    if (
        !jinguiAcceptedTransportH2DiagnosticWorkKindAllowed(
            allowedKinds,
            evidence.requestedDiagnosticKind
        )
    ) {
        blockers.add(
            "UNSUPPORTED_DIAGNOSTIC_KIND:${evidence.requestedDiagnosticKind}"
        )
    }
    if (evidence.runtimeSocketRequested) {
        blockers.add("FORBIDDEN:H2_RUNTIME_SOCKET_REQUESTED")
    }
    if (evidence.browserReplayRequested) {
        blockers.add("FORBIDDEN:H2_BROWSER_REPLAY_REQUESTED")
    }
    if (evidence.schedulerRequested) {
        blockers.add("FORBIDDEN:H2_SCHEDULER_REQUESTED")
    }
    if (evidence.h2specRequested) {
        blockers.add("FORBIDDEN:H2SPEC_REQUESTED")
    }
    if (!evidence.modelOnlyDiagnosticProof) {
        blockers.add("MISSING:MODEL_ONLY_DIAGNOSTIC_PROOF")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2DiagnosticWorkNonClaims(): Array<String> {
    [
        "NO_PROVIDER_FIX",
        "NO_ACCEPTED_TRANSPORT_ATTACH_PASS_CLAIM",
        "NO_H2_RUNTIME_LAUNCH_CLAIM",
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_H2_BROWSER_REPLAY_CLAIM",
        "NO_H2_SCHEDULER_CLAIM",
        "NO_H2SPEC_CLAIM",
    ]
}

public class JinguiAcceptedTransportH2WireFixtureDiagnosticExpectation {
    public let expectedFrameCount: Int64
    public let expectedFrameTypes: Array<UInt8>
    public let expectedStreamIds: Array<Int64>
    public let headerBlockExpectationEnabled: Bool
    public let expectedCompletedHeaderBlockCount: Int64
    public let expectedFirstHeaderBlockStreamId: Int64

    public init(
        expectedFrameCount: Int64,
        expectedFrameTypes: Array<UInt8>,
        expectedStreamIds: Array<Int64>,
        headerBlockExpectationEnabled: Bool,
        expectedCompletedHeaderBlockCount: Int64,
        expectedFirstHeaderBlockStreamId: Int64
    ) {
        this.expectedFrameCount = expectedFrameCount
        this.expectedFrameTypes = expectedFrameTypes.clone()
        this.expectedStreamIds = expectedStreamIds.clone()
        this.headerBlockExpectationEnabled = headerBlockExpectationEnabled
        this.expectedCompletedHeaderBlockCount =
            expectedCompletedHeaderBlockCount
        this.expectedFirstHeaderBlockStreamId = expectedFirstHeaderBlockStreamId
    }
}

public class JinguiAcceptedTransportH2WireFixtureDiagnosticEvidence {
    public let gate: JinguiAcceptedTransportH2DiagnosticWorkGate
    public let fixtureWire: Array<Byte>
    public let expectation: JinguiAcceptedTransportH2WireFixtureDiagnosticExpectation
    public let modelOnlyFixtureProof: Bool

    public init(
        gate: JinguiAcceptedTransportH2DiagnosticWorkGate,
        fixtureWire: Array<Byte>,
        expectation: JinguiAcceptedTransportH2WireFixtureDiagnosticExpectation,
        modelOnlyFixtureProof: Bool
    ) {
        this.gate = gate
        this.fixtureWire =
            cloneServerEngineByteWindow(
                fixtureWire,
                0,
                fixtureWire.size
            )
        this.expectation = expectation
        this.modelOnlyFixtureProof = modelOnlyFixtureProof
    }
}

public class JinguiAcceptedTransportH2WireFixtureDiagnosticReceipt {
    public let accepted: Bool
    public let status: String
    public let decision: String
    public let frameCount: Int64
    public let frameTypes: Array<UInt8>
    public let streamIds: Array<Int64>
    public let completedHeaderBlockCount: Int64
    public let firstHeaderBlockStreamId: Int64
    public let diagnosticKind: String
    public let h2RuntimeProofLaunchAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        accepted: Bool,
        status: String,
        decision: String,
        frameCount: Int64,
        frameTypes: Array<UInt8>,
        streamIds: Array<Int64>,
        completedHeaderBlockCount: Int64,
        firstHeaderBlockStreamId: Int64,
        diagnosticKind: String,
        h2RuntimeProofLaunchAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.accepted = accepted
        this.status = status
        this.decision = decision
        this.frameCount = frameCount
        this.frameTypes = frameTypes.clone()
        this.streamIds = streamIds.clone()
        this.completedHeaderBlockCount = completedHeaderBlockCount
        this.firstHeaderBlockStreamId = firstHeaderBlockStreamId
        this.diagnosticKind = diagnosticKind
        this.h2RuntimeProofLaunchAllowed = h2RuntimeProofLaunchAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2WireFixtureDiagnosticReceipt(
    evidence: JinguiAcceptedTransportH2WireFixtureDiagnosticEvidence
): JinguiAcceptedTransportH2WireFixtureDiagnosticReceipt {
    let nonClaims =
        jinguiAcceptedTransportH2WireFixtureDiagnosticNonClaims(
            evidence.gate
        )
    let frameWires = splitJinguiAcceptedTransportH2FrameWire(
        evidence.fixtureWire
    )
    let frameTypes = ArrayList<UInt8>()
    let streamIds = ArrayList<Int64>()
    let headerAccumulator = JinguiAcceptedTransportH2HeaderBlockAccumulator()

    for (frameWire in frameWires) {
        let frame = parseJinguiAcceptedTransportH2FrameWire(frameWire)
        frameTypes.add(frame.frameType)
        streamIds.add(frame.streamId)
        if (
            frame.frameType == UInt8(0x1) ||
            frame.frameType == UInt8(0x9)
        ) {
            headerAccumulator.append(frame)
        } else if (headerAccumulator.hasOpenHeaderBlock()) {
            let blockers = ArrayList<String>()
            blockers.add(
                "HEADER_BLOCK_INTERLEAVED_FRAME:type=${Int64(frame.frameType)}"
            )
            return jinguiAcceptedTransportH2WireFixtureDiagnosticBlocked(
                evidence,
                frameTypes,
                streamIds,
                0,
                0,
                blockers.toArray(),
                "blocked-header-block-interleaving",
                "keep wire fixture at model-only valid header-block boundaries",
                nonClaims
            )
        }
    }

    let completedHeaderBlocks = headerAccumulator.drainCompleteHeaderBlocks()
    var firstHeaderBlockStreamId: Int64 = 0
    if (completedHeaderBlocks.size > 0) {
        firstHeaderBlockStreamId = completedHeaderBlocks[0].streamId
    }

    let blockers =
        jinguiAcceptedTransportH2WireFixtureDiagnosticBlockers(
            evidence,
            frameTypes.toArray(),
            streamIds.toArray(),
            completedHeaderBlocks,
            headerAccumulator.hasOpenHeaderBlock()
        )
    if (blockers.size > 0) {
        return jinguiAcceptedTransportH2WireFixtureDiagnosticBlocked(
            evidence,
            frameTypes,
            streamIds,
            completedHeaderBlocks.size,
            firstHeaderBlockStreamId,
            blockers,
            "blocked-wire-fixture-diagnostic-mismatch",
            "repair model-only wire fixture expectations before runtime work",
            nonClaims
        )
    }

    JinguiAcceptedTransportH2WireFixtureDiagnosticReceipt(
        true,
        "accepted-model-only-h2-wire-fixture-diagnostic",
        "accept-wire-fixture-diagnostic-and-stop-at-provider-blocker",
        frameWires.size,
        frameTypes.toArray(),
        streamIds.toArray(),
        completedHeaderBlocks.size,
        firstHeaderBlockStreamId,
        evidence.gate.requestedDiagnosticKind,
        false,
        false,
        evidence.gate.blockers,
        nonClaims,
        "keep the fixture as model-only proof until provider readiness permits runtime launch",
        "QUIC can reuse this receipt shape for packet/datagram fixtures before runtime launch"
    )
}

func jinguiAcceptedTransportH2WireFixtureDiagnosticBlocked(
    evidence: JinguiAcceptedTransportH2WireFixtureDiagnosticEvidence,
    frameTypes: ArrayList<UInt8>,
    streamIds: ArrayList<Int64>,
    completedHeaderBlockCount: Int64,
    firstHeaderBlockStreamId: Int64,
    blockers: Array<String>,
    status: String,
    decision: String,
    nonClaims: Array<String>
): JinguiAcceptedTransportH2WireFixtureDiagnosticReceipt {
    JinguiAcceptedTransportH2WireFixtureDiagnosticReceipt(
        false,
        status,
        decision,
        frameTypes.size,
        frameTypes.toArray(),
        streamIds.toArray(),
        completedHeaderBlockCount,
        firstHeaderBlockStreamId,
        evidence.gate.requestedDiagnosticKind,
        false,
        false,
        blockers,
        nonClaims,
        "stop this fixture packet before runtime launch or closure claims",
        "QUIC should carry fixture mismatch as model feedback, not runtime truth"
    )
}

func jinguiAcceptedTransportH2WireFixtureDiagnosticBlockers(
    evidence: JinguiAcceptedTransportH2WireFixtureDiagnosticEvidence,
    frameTypes: Array<UInt8>,
    streamIds: Array<Int64>,
    completedHeaderBlocks: Array<JinguiAcceptedTransportH2HeaderBlockSnapshot>,
    hasOpenHeaderBlock: Bool
): Array<String> {
    let blockers = ArrayList<String>()
    if (!evidence.gate.diagnosticWorkAllowed) {
        blockers.add("GATE:${evidence.gate.status}")
        for (blocker in evidence.gate.blockers) {
            blockers.add("GATE_BLOCKER:${blocker}")
        }
    }
    if (evidence.gate.requestedDiagnosticKind != "h2-wire-fixture-diagnostic") {
        blockers.add(
            "GATE_KIND_MISMATCH:${evidence.gate.requestedDiagnosticKind}"
        )
    }
    if (!evidence.modelOnlyFixtureProof) {
        blockers.add("MISSING:MODEL_ONLY_WIRE_FIXTURE_PROOF")
    }
    if (frameTypes.size != evidence.expectation.expectedFrameCount) {
        blockers.add(
            "FRAME_COUNT_MISMATCH:expected=${evidence.expectation.expectedFrameCount}:actual=${frameTypes.size}"
        )
    }
    if (frameTypes.size != evidence.expectation.expectedFrameTypes.size) {
        blockers.add(
            "EXPECTED_FRAME_TYPES_SIZE_MISMATCH:expected=${evidence.expectation.expectedFrameTypes.size}:actual=${frameTypes.size}"
        )
    } else {
        var i: Int64 = 0
        while (i < frameTypes.size) {
            if (frameTypes[i] != evidence.expectation.expectedFrameTypes[i]) {
                blockers.add(
                    "FRAME_TYPE_MISMATCH:index=${i}:expected=${Int64(evidence.expectation.expectedFrameTypes[i])}:actual=${Int64(frameTypes[i])}"
                )
            }
            i += 1
        }
    }
    if (streamIds.size != evidence.expectation.expectedStreamIds.size) {
        blockers.add(
            "EXPECTED_STREAM_IDS_SIZE_MISMATCH:expected=${evidence.expectation.expectedStreamIds.size}:actual=${streamIds.size}"
        )
    } else {
        var i: Int64 = 0
        while (i < streamIds.size) {
            if (streamIds[i] != evidence.expectation.expectedStreamIds[i]) {
                blockers.add(
                    "STREAM_ID_MISMATCH:index=${i}:expected=${evidence.expectation.expectedStreamIds[i]}:actual=${streamIds[i]}"
                )
            }
            i += 1
        }
    }
    if (hasOpenHeaderBlock) {
        blockers.add("HEADER_BLOCK_LEFT_OPEN")
    }
    if (evidence.expectation.headerBlockExpectationEnabled) {
        if (
            completedHeaderBlocks.size !=
            evidence.expectation.expectedCompletedHeaderBlockCount
        ) {
            blockers.add(
                "HEADER_BLOCK_COUNT_MISMATCH:expected=${evidence.expectation.expectedCompletedHeaderBlockCount}:actual=${completedHeaderBlocks.size}"
            )
        }
        if (
            evidence.expectation.expectedCompletedHeaderBlockCount > 0 &&
            completedHeaderBlocks.size > 0 &&
            completedHeaderBlocks[0].streamId !=
            evidence.expectation.expectedFirstHeaderBlockStreamId
        ) {
            blockers.add(
                "HEADER_BLOCK_STREAM_ID_MISMATCH:expected=${evidence.expectation.expectedFirstHeaderBlockStreamId}:actual=${completedHeaderBlocks[0].streamId}"
            )
        }
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2WireFixtureDiagnosticNonClaims(
    gate: JinguiAcceptedTransportH2DiagnosticWorkGate
): Array<String> {
    let nonClaims = ArrayList<String>()
    for (item in gate.nonClaims) {
        nonClaims.add(item)
    }
    nonClaims.add("NO_HPACK_DECODE_CLAIM")
    nonClaims.add("NO_RUNTIME_SOCKET_CLAIM")
    nonClaims.add("NO_H2_MULTIPLEXING_CLOSURE_CLAIM")
    nonClaims.toArray()
}
