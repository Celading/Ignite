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

public class IgniteRuntimeDefaultPathMutationCommitDryRunRequest {
    public let runtimeDefaultPathMutationCommitDryRunId: String
    public let commitPlanSnapshotCarried: Bool
    public let targetRuntimeDefaultPathCarried: Bool
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
        runtimeDefaultPathMutationCommitDryRunId: String,
        commitPlanSnapshotCarried: Bool,
        targetRuntimeDefaultPathCarried: Bool,
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
        this.runtimeDefaultPathMutationCommitDryRunId =
            runtimeDefaultPathMutationCommitDryRunId
        this.commitPlanSnapshotCarried = commitPlanSnapshotCarried
        this.targetRuntimeDefaultPathCarried = targetRuntimeDefaultPathCarried
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

public class IgniteRuntimeDefaultPathMutationCommitDryRunReceipt {
    public let runtimeDefaultPathMutationCommitDryRunAccepted: Bool
    public let runtimeDefaultPathMutationCommitPlanAccepted: Bool
    public let runtimeDefaultPathMutationCommitPlanMode: String
    public let runtimeDefaultPathMutationCommitDryRunMode: String
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
    public let commitPlanReceipt: IgniteRuntimeDefaultPathMutationCommitPlanReceipt
    public let runtimeDefaultPathMutationCommitDryRunRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationCommitDryRunAllowed: Bool
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
        runtimeDefaultPathMutationCommitDryRunAccepted: Bool,
        runtimeDefaultPathMutationCommitPlanAccepted: Bool,
        runtimeDefaultPathMutationCommitPlanMode: String,
        runtimeDefaultPathMutationCommitDryRunMode: String,
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
        commitPlanReceipt: IgniteRuntimeDefaultPathMutationCommitPlanReceipt,
        runtimeDefaultPathMutationCommitDryRunRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationCommitDryRunAllowed: Bool,
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
        this.runtimeDefaultPathMutationCommitDryRunAccepted =
            runtimeDefaultPathMutationCommitDryRunAccepted
        this.runtimeDefaultPathMutationCommitPlanAccepted =
            runtimeDefaultPathMutationCommitPlanAccepted
        this.runtimeDefaultPathMutationCommitPlanMode =
            runtimeDefaultPathMutationCommitPlanMode
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
        this.controlledDefaultEngineMutationApplyId =
            controlledDefaultEngineMutationApplyId
        this.defaultEngineMutationApplyGateId =
            defaultEngineMutationApplyGateId
        this.defaultEngineMutationDryRunId = defaultEngineMutationDryRunId
        this.defaultEngineMutationCommitPlanId =
            defaultEngineMutationCommitPlanId
        this.commitPlanReceipt = commitPlanReceipt
        this.runtimeDefaultPathMutationCommitDryRunRecorded =
            runtimeDefaultPathMutationCommitDryRunRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationCommitDryRunAllowed =
            runtimeDefaultPathMutationCommitDryRunAllowed
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

public func buildIgniteRuntimeDefaultPathMutationCommitDryRunReceipt(
    commitPlanReceipt: IgniteRuntimeDefaultPathMutationCommitPlanReceipt,
    request: IgniteRuntimeDefaultPathMutationCommitDryRunRequest
): IgniteRuntimeDefaultPathMutationCommitDryRunReceipt {
    let nonClaims = igniteRuntimeDefaultPathMutationCommitDryRunNonClaims()
    if (!commitPlanReceipt.runtimeDefaultPathMutationCommitPlanAccepted) {
        return IgniteRuntimeDefaultPathMutationCommitDryRunReceipt(
            false,
            commitPlanReceipt.runtimeDefaultPathMutationCommitPlanAccepted,
            commitPlanReceipt.runtimeDefaultPathMutationCommitPlanMode,
            "none",
            request.runtimeDefaultPathMutationCommitDryRunId,
            commitPlanReceipt.runtimeDefaultPathMutationCommitPlanId,
            commitPlanReceipt.controlledRuntimeDefaultPathMutationApplyId,
            commitPlanReceipt.runtimeDefaultPathMutationApplyGateId,
            commitPlanReceipt.runtimeDefaultPathMutationDryRunId,
            commitPlanReceipt.runtimeDefaultPathMutationGateId,
            commitPlanReceipt.controlledDefaultEngineMutationApplyId,
            commitPlanReceipt.defaultEngineMutationApplyGateId,
            commitPlanReceipt.defaultEngineMutationDryRunId,
            commitPlanReceipt.defaultEngineMutationCommitPlanId,
            commitPlanReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-commit-plan-receipt",
            "collect-accepted-runtime-default-path-mutation-commit-plan-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_PLAN_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0488 runtime default-path mutation commit-plan input before commit dry-run work",
            "QUIC must not consume runtime default-path mutation commit dry-run receipts from rejected commit-plan receipts"
        )
    }

    let dryRunMode = igniteRuntimeDefaultPathMutationCommitDryRunModeFor(
        commitPlanReceipt.runtimeDefaultPathMutationCommitPlanMode
    )
    let blockers = igniteRuntimeDefaultPathMutationCommitDryRunBlockers(
        request,
        dryRunMode
    )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationCommitDryRunReceipt(
            false,
            commitPlanReceipt.runtimeDefaultPathMutationCommitPlanAccepted,
            commitPlanReceipt.runtimeDefaultPathMutationCommitPlanMode,
            dryRunMode,
            request.runtimeDefaultPathMutationCommitDryRunId,
            commitPlanReceipt.runtimeDefaultPathMutationCommitPlanId,
            commitPlanReceipt.controlledRuntimeDefaultPathMutationApplyId,
            commitPlanReceipt.runtimeDefaultPathMutationApplyGateId,
            commitPlanReceipt.runtimeDefaultPathMutationDryRunId,
            commitPlanReceipt.runtimeDefaultPathMutationGateId,
            commitPlanReceipt.controlledDefaultEngineMutationApplyId,
            commitPlanReceipt.defaultEngineMutationApplyGateId,
            commitPlanReceipt.defaultEngineMutationDryRunId,
            commitPlanReceipt.defaultEngineMutationCommitPlanId,
            commitPlanReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-commit-dry-run-input",
            "fix-runtime-default-path-mutation-commit-dry-run-before-runtime-default-mutation",
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
            "carry commit dry-run id, commit-plan snapshot, target runtime default path, isolated mutation plan, dry-run sandbox, config diff preview, rollback simulation, runtime guard plan, observability marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation commit dry-run blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationCommitDryRunReceipt(
        true,
        commitPlanReceipt.runtimeDefaultPathMutationCommitPlanAccepted,
        commitPlanReceipt.runtimeDefaultPathMutationCommitPlanMode,
        dryRunMode,
        request.runtimeDefaultPathMutationCommitDryRunId,
        commitPlanReceipt.runtimeDefaultPathMutationCommitPlanId,
        commitPlanReceipt.controlledRuntimeDefaultPathMutationApplyId,
        commitPlanReceipt.runtimeDefaultPathMutationApplyGateId,
        commitPlanReceipt.runtimeDefaultPathMutationDryRunId,
        commitPlanReceipt.runtimeDefaultPathMutationGateId,
        commitPlanReceipt.controlledDefaultEngineMutationApplyId,
        commitPlanReceipt.defaultEngineMutationApplyGateId,
        commitPlanReceipt.defaultEngineMutationDryRunId,
        commitPlanReceipt.defaultEngineMutationCommitPlanId,
        commitPlanReceipt,
        true,
        "record-runtime-default-path-mutation-commit-dry-run",
        "accepted-runtime-default-path-mutation-commit-dry-run-receipt",
        "record-runtime-default-path-mutation-commit-dry-run-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation commit apply-gate without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation commit dry-run modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationCommitDryRunModeFor(
    commitPlanMode: String
): String {
    if (commitPlanMode == "short-runtime-default-path-mutation-commit-plan") {
        return "short-runtime-default-path-mutation-commit-dry-run"
    }
    if (commitPlanMode == "long-runtime-default-path-mutation-commit-plan") {
        return "long-runtime-default-path-mutation-commit-dry-run"
    }
    if (
        commitPlanMode ==
        "blocking-isolation-runtime-default-path-mutation-commit-plan"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-commit-dry-run"
    }
    "unknown-runtime-default-path-mutation-commit-dry-run"
}

func igniteRuntimeDefaultPathMutationCommitDryRunBlockers(
    request: IgniteRuntimeDefaultPathMutationCommitDryRunRequest,
    dryRunMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.runtimeDefaultPathMutationCommitDryRunId.size == 0) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_DRY_RUN_ID_NOT_CARRIED")
    }
    if (!request.commitPlanSnapshotCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_PLAN_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.targetRuntimeDefaultPathCarried) {
        blockers.add("TARGET_RUNTIME_DEFAULT_PATH_NOT_CARRIED")
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
    if (
        dryRunMode ==
        "unknown-runtime-default-path-mutation-commit-dry-run"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_PLAN")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationCommitDryRunNonClaims(): Array<String> {
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

public class IgniteRuntimeDefaultPathMutationCommitApplyGateRequest {
    public let runtimeDefaultPathMutationCommitApplyGateId: String
    public let dryRunSnapshotCarried: Bool
    public let targetRuntimeDefaultPathCarried: Bool
    public let applyPreconditionGateCarried: Bool
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
        runtimeDefaultPathMutationCommitApplyGateId: String,
        dryRunSnapshotCarried: Bool,
        targetRuntimeDefaultPathCarried: Bool,
        applyPreconditionGateCarried: Bool,
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
        this.runtimeDefaultPathMutationCommitApplyGateId =
            runtimeDefaultPathMutationCommitApplyGateId
        this.dryRunSnapshotCarried = dryRunSnapshotCarried
        this.targetRuntimeDefaultPathCarried = targetRuntimeDefaultPathCarried
        this.applyPreconditionGateCarried = applyPreconditionGateCarried
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

public class IgniteRuntimeDefaultPathMutationCommitApplyGateReceipt {
    public let runtimeDefaultPathMutationCommitApplyGateAccepted: Bool
    public let runtimeDefaultPathMutationCommitDryRunAccepted: Bool
    public let runtimeDefaultPathMutationCommitDryRunMode: String
    public let runtimeDefaultPathMutationCommitApplyGateMode: String
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
    public let dryRunReceipt: IgniteRuntimeDefaultPathMutationCommitDryRunReceipt
    public let runtimeDefaultPathMutationCommitApplyGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationCommitApplyGateAllowed: Bool
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
        runtimeDefaultPathMutationCommitApplyGateAccepted: Bool,
        runtimeDefaultPathMutationCommitDryRunAccepted: Bool,
        runtimeDefaultPathMutationCommitDryRunMode: String,
        runtimeDefaultPathMutationCommitApplyGateMode: String,
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
        dryRunReceipt: IgniteRuntimeDefaultPathMutationCommitDryRunReceipt,
        runtimeDefaultPathMutationCommitApplyGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationCommitApplyGateAllowed: Bool,
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
        this.runtimeDefaultPathMutationCommitApplyGateAccepted =
            runtimeDefaultPathMutationCommitApplyGateAccepted
        this.runtimeDefaultPathMutationCommitDryRunAccepted =
            runtimeDefaultPathMutationCommitDryRunAccepted
        this.runtimeDefaultPathMutationCommitDryRunMode =
            runtimeDefaultPathMutationCommitDryRunMode
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
        this.controlledDefaultEngineMutationApplyId =
            controlledDefaultEngineMutationApplyId
        this.defaultEngineMutationApplyGateId =
            defaultEngineMutationApplyGateId
        this.defaultEngineMutationDryRunId = defaultEngineMutationDryRunId
        this.defaultEngineMutationCommitPlanId =
            defaultEngineMutationCommitPlanId
        this.dryRunReceipt = dryRunReceipt
        this.runtimeDefaultPathMutationCommitApplyGateRecorded =
            runtimeDefaultPathMutationCommitApplyGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationCommitApplyGateAllowed =
            runtimeDefaultPathMutationCommitApplyGateAllowed
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

public func buildIgniteRuntimeDefaultPathMutationCommitApplyGateReceipt(
    dryRunReceipt: IgniteRuntimeDefaultPathMutationCommitDryRunReceipt,
    request: IgniteRuntimeDefaultPathMutationCommitApplyGateRequest
): IgniteRuntimeDefaultPathMutationCommitApplyGateReceipt {
    let nonClaims = igniteRuntimeDefaultPathMutationCommitApplyGateNonClaims()
    if (!dryRunReceipt.runtimeDefaultPathMutationCommitDryRunAccepted) {
        return IgniteRuntimeDefaultPathMutationCommitApplyGateReceipt(
            false,
            dryRunReceipt.runtimeDefaultPathMutationCommitDryRunAccepted,
            dryRunReceipt.runtimeDefaultPathMutationCommitDryRunMode,
            "none",
            request.runtimeDefaultPathMutationCommitApplyGateId,
            dryRunReceipt.runtimeDefaultPathMutationCommitDryRunId,
            dryRunReceipt.runtimeDefaultPathMutationCommitPlanId,
            dryRunReceipt.controlledRuntimeDefaultPathMutationApplyId,
            dryRunReceipt.runtimeDefaultPathMutationApplyGateId,
            dryRunReceipt.runtimeDefaultPathMutationDryRunId,
            dryRunReceipt.runtimeDefaultPathMutationGateId,
            dryRunReceipt.controlledDefaultEngineMutationApplyId,
            dryRunReceipt.defaultEngineMutationApplyGateId,
            dryRunReceipt.defaultEngineMutationDryRunId,
            dryRunReceipt.defaultEngineMutationCommitPlanId,
            dryRunReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-commit-dry-run-receipt",
            "collect-accepted-runtime-default-path-mutation-commit-dry-run-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_DRY_RUN_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0489 runtime default-path mutation commit dry-run input before commit apply-gate work",
            "QUIC must not consume runtime default-path mutation commit apply-gate receipts from rejected commit dry-run receipts"
        )
    }

    let applyGateMode = igniteRuntimeDefaultPathMutationCommitApplyGateModeFor(
        dryRunReceipt.runtimeDefaultPathMutationCommitDryRunMode
    )
    let blockers = igniteRuntimeDefaultPathMutationCommitApplyGateBlockers(
        request,
        applyGateMode
    )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationCommitApplyGateReceipt(
            false,
            dryRunReceipt.runtimeDefaultPathMutationCommitDryRunAccepted,
            dryRunReceipt.runtimeDefaultPathMutationCommitDryRunMode,
            applyGateMode,
            request.runtimeDefaultPathMutationCommitApplyGateId,
            dryRunReceipt.runtimeDefaultPathMutationCommitDryRunId,
            dryRunReceipt.runtimeDefaultPathMutationCommitPlanId,
            dryRunReceipt.controlledRuntimeDefaultPathMutationApplyId,
            dryRunReceipt.runtimeDefaultPathMutationApplyGateId,
            dryRunReceipt.runtimeDefaultPathMutationDryRunId,
            dryRunReceipt.runtimeDefaultPathMutationGateId,
            dryRunReceipt.controlledDefaultEngineMutationApplyId,
            dryRunReceipt.defaultEngineMutationApplyGateId,
            dryRunReceipt.defaultEngineMutationDryRunId,
            dryRunReceipt.defaultEngineMutationCommitPlanId,
            dryRunReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-commit-apply-gate-input",
            "fix-runtime-default-path-mutation-commit-apply-gate-before-runtime-default-mutation",
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
            "carry commit apply-gate id, dry-run snapshot, target runtime default path, apply precondition gate, runtime default-path mutation lock, rollback order, runtime guard plan, observability marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation commit apply-gate blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationCommitApplyGateReceipt(
        true,
        dryRunReceipt.runtimeDefaultPathMutationCommitDryRunAccepted,
        dryRunReceipt.runtimeDefaultPathMutationCommitDryRunMode,
        applyGateMode,
        request.runtimeDefaultPathMutationCommitApplyGateId,
        dryRunReceipt.runtimeDefaultPathMutationCommitDryRunId,
        dryRunReceipt.runtimeDefaultPathMutationCommitPlanId,
        dryRunReceipt.controlledRuntimeDefaultPathMutationApplyId,
        dryRunReceipt.runtimeDefaultPathMutationApplyGateId,
        dryRunReceipt.runtimeDefaultPathMutationDryRunId,
        dryRunReceipt.runtimeDefaultPathMutationGateId,
        dryRunReceipt.controlledDefaultEngineMutationApplyId,
        dryRunReceipt.defaultEngineMutationApplyGateId,
        dryRunReceipt.defaultEngineMutationDryRunId,
        dryRunReceipt.defaultEngineMutationCommitPlanId,
        dryRunReceipt,
        true,
        "record-runtime-default-path-mutation-commit-apply-gate",
        "accepted-runtime-default-path-mutation-commit-apply-gate-receipt",
        "record-runtime-default-path-mutation-commit-apply-gate-without-runtime-default-mutation",
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
        "next packet may prove controlled runtime default-path mutation commit apply without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation commit apply-gate modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationCommitApplyGateModeFor(
    dryRunMode: String
): String {
    if (dryRunMode == "short-runtime-default-path-mutation-commit-dry-run") {
        return "short-runtime-default-path-mutation-commit-apply-gate"
    }
    if (dryRunMode == "long-runtime-default-path-mutation-commit-dry-run") {
        return "long-runtime-default-path-mutation-commit-apply-gate"
    }
    if (
        dryRunMode ==
        "blocking-isolation-runtime-default-path-mutation-commit-dry-run"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-commit-apply-gate"
    }
    "unknown-runtime-default-path-mutation-commit-apply-gate"
}

func igniteRuntimeDefaultPathMutationCommitApplyGateBlockers(
    request: IgniteRuntimeDefaultPathMutationCommitApplyGateRequest,
    applyGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.runtimeDefaultPathMutationCommitApplyGateId.size == 0) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_APPLY_GATE_ID_NOT_CARRIED")
    }
    if (!request.dryRunSnapshotCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_DRY_RUN_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.targetRuntimeDefaultPathCarried) {
        blockers.add("TARGET_RUNTIME_DEFAULT_PATH_NOT_CARRIED")
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
        applyGateMode ==
        "unknown-runtime-default-path-mutation-commit-apply-gate"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_DRY_RUN")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationCommitApplyGateNonClaims(): Array<String> {
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

public class IgniteControlledRuntimeDefaultPathMutationCommitApplyRequest {
    public let controlledRuntimeDefaultPathMutationCommitApplyId: String
    public let applyGateSnapshotCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let mutationCommitBoundaryCarried: Bool
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
        controlledRuntimeDefaultPathMutationCommitApplyId: String,
        applyGateSnapshotCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        mutationCommitBoundaryCarried: Bool,
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
        this.controlledRuntimeDefaultPathMutationCommitApplyId =
            controlledRuntimeDefaultPathMutationCommitApplyId
        this.applyGateSnapshotCarried = applyGateSnapshotCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.mutationCommitBoundaryCarried = mutationCommitBoundaryCarried
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

public class IgniteControlledRuntimeDefaultPathMutationCommitApplyReceipt {
    public let controlledRuntimeDefaultPathMutationCommitApplyAccepted: Bool
    public let runtimeDefaultPathMutationCommitApplyGateAccepted: Bool
    public let runtimeDefaultPathMutationCommitApplyGateMode: String
    public let controlledRuntimeDefaultPathMutationCommitApplyMode: String
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
    public let applyGateReceipt: IgniteRuntimeDefaultPathMutationCommitApplyGateReceipt
    public let controlledRuntimeDefaultPathMutationCommitApplyRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let controlledRuntimeDefaultPathMutationCommitApplyAllowed: Bool
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
        controlledRuntimeDefaultPathMutationCommitApplyAccepted: Bool,
        runtimeDefaultPathMutationCommitApplyGateAccepted: Bool,
        runtimeDefaultPathMutationCommitApplyGateMode: String,
        controlledRuntimeDefaultPathMutationCommitApplyMode: String,
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
        applyGateReceipt: IgniteRuntimeDefaultPathMutationCommitApplyGateReceipt,
        controlledRuntimeDefaultPathMutationCommitApplyRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        controlledRuntimeDefaultPathMutationCommitApplyAllowed: Bool,
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
        this.controlledRuntimeDefaultPathMutationCommitApplyAccepted =
            controlledRuntimeDefaultPathMutationCommitApplyAccepted
        this.runtimeDefaultPathMutationCommitApplyGateAccepted =
            runtimeDefaultPathMutationCommitApplyGateAccepted
        this.runtimeDefaultPathMutationCommitApplyGateMode =
            runtimeDefaultPathMutationCommitApplyGateMode
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
        this.controlledDefaultEngineMutationApplyId =
            controlledDefaultEngineMutationApplyId
        this.defaultEngineMutationApplyGateId =
            defaultEngineMutationApplyGateId
        this.defaultEngineMutationDryRunId = defaultEngineMutationDryRunId
        this.defaultEngineMutationCommitPlanId =
            defaultEngineMutationCommitPlanId
        this.applyGateReceipt = applyGateReceipt
        this.controlledRuntimeDefaultPathMutationCommitApplyRecorded =
            controlledRuntimeDefaultPathMutationCommitApplyRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.controlledRuntimeDefaultPathMutationCommitApplyAllowed =
            controlledRuntimeDefaultPathMutationCommitApplyAllowed
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

public func buildIgniteControlledRuntimeDefaultPathMutationCommitApplyReceipt(
    applyGateReceipt: IgniteRuntimeDefaultPathMutationCommitApplyGateReceipt,
    request: IgniteControlledRuntimeDefaultPathMutationCommitApplyRequest
): IgniteControlledRuntimeDefaultPathMutationCommitApplyReceipt {
    let nonClaims = igniteControlledRuntimeDefaultPathMutationCommitApplyNonClaims()
    if (!applyGateReceipt.runtimeDefaultPathMutationCommitApplyGateAccepted) {
        return IgniteControlledRuntimeDefaultPathMutationCommitApplyReceipt(
            false,
            applyGateReceipt.runtimeDefaultPathMutationCommitApplyGateAccepted,
            applyGateReceipt.runtimeDefaultPathMutationCommitApplyGateMode,
            "none",
            request.controlledRuntimeDefaultPathMutationCommitApplyId,
            applyGateReceipt.runtimeDefaultPathMutationCommitApplyGateId,
            applyGateReceipt.runtimeDefaultPathMutationCommitDryRunId,
            applyGateReceipt.runtimeDefaultPathMutationCommitPlanId,
            applyGateReceipt.controlledRuntimeDefaultPathMutationApplyId,
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
            "blocked-runtime-default-path-mutation-commit-apply-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-commit-apply-gate-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_APPLY_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0490 runtime default-path mutation commit apply-gate input before controlled commit apply work",
            "QUIC must not consume controlled runtime default-path mutation commit apply receipts from rejected commit apply-gate receipts"
        )
    }

    let controlledApplyMode =
        igniteControlledRuntimeDefaultPathMutationCommitApplyModeFor(
            applyGateReceipt.runtimeDefaultPathMutationCommitApplyGateMode
        )
    let blockers =
        igniteControlledRuntimeDefaultPathMutationCommitApplyBlockers(
            request,
            controlledApplyMode
        )
    if (blockers.size > 0) {
        return IgniteControlledRuntimeDefaultPathMutationCommitApplyReceipt(
            false,
            applyGateReceipt.runtimeDefaultPathMutationCommitApplyGateAccepted,
            applyGateReceipt.runtimeDefaultPathMutationCommitApplyGateMode,
            controlledApplyMode,
            request.controlledRuntimeDefaultPathMutationCommitApplyId,
            applyGateReceipt.runtimeDefaultPathMutationCommitApplyGateId,
            applyGateReceipt.runtimeDefaultPathMutationCommitDryRunId,
            applyGateReceipt.runtimeDefaultPathMutationCommitPlanId,
            applyGateReceipt.controlledRuntimeDefaultPathMutationApplyId,
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
            "blocked-controlled-runtime-default-path-mutation-commit-apply-input",
            "fix-controlled-runtime-default-path-mutation-commit-apply-before-runtime-default-mutation",
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
            "carry controlled commit apply id, apply-gate snapshot, runtime default-path mutation lock, mutation commit boundary, rollback order, runtime guard plan, observability marker, and keep runtime default mutation out",
            "QUIC can reuse the same controlled runtime default-path mutation commit apply blockers before default stream runtime mutation"
        )
    }

    IgniteControlledRuntimeDefaultPathMutationCommitApplyReceipt(
        true,
        applyGateReceipt.runtimeDefaultPathMutationCommitApplyGateAccepted,
        applyGateReceipt.runtimeDefaultPathMutationCommitApplyGateMode,
        controlledApplyMode,
        request.controlledRuntimeDefaultPathMutationCommitApplyId,
        applyGateReceipt.runtimeDefaultPathMutationCommitApplyGateId,
        applyGateReceipt.runtimeDefaultPathMutationCommitDryRunId,
        applyGateReceipt.runtimeDefaultPathMutationCommitPlanId,
        applyGateReceipt.controlledRuntimeDefaultPathMutationApplyId,
        applyGateReceipt.runtimeDefaultPathMutationApplyGateId,
        applyGateReceipt.runtimeDefaultPathMutationDryRunId,
        applyGateReceipt.runtimeDefaultPathMutationGateId,
        applyGateReceipt.controlledDefaultEngineMutationApplyId,
        applyGateReceipt.defaultEngineMutationApplyGateId,
        applyGateReceipt.defaultEngineMutationDryRunId,
        applyGateReceipt.defaultEngineMutationCommitPlanId,
        applyGateReceipt,
        true,
        "record-controlled-runtime-default-path-mutation-commit-apply",
        "accepted-controlled-runtime-default-path-mutation-commit-apply-receipt",
        "record-controlled-runtime-default-path-mutation-commit-apply-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation commit boundary without mutating runtime defaults",
        "QUIC can reuse lane-specific controlled runtime default-path mutation commit apply modes before runtime default mutation"
    )
}

func igniteControlledRuntimeDefaultPathMutationCommitApplyModeFor(
    applyGateMode: String
): String {
    if (applyGateMode == "short-runtime-default-path-mutation-commit-apply-gate") {
        return "short-controlled-runtime-default-path-mutation-commit-apply"
    }
    if (applyGateMode == "long-runtime-default-path-mutation-commit-apply-gate") {
        return "long-controlled-runtime-default-path-mutation-commit-apply"
    }
    if (
        applyGateMode ==
        "blocking-isolation-runtime-default-path-mutation-commit-apply-gate"
    ) {
        return "blocking-isolation-controlled-runtime-default-path-mutation-commit-apply"
    }
    "unknown-controlled-runtime-default-path-mutation-commit-apply"
}

func igniteControlledRuntimeDefaultPathMutationCommitApplyBlockers(
    request: IgniteControlledRuntimeDefaultPathMutationCommitApplyRequest,
    controlledApplyMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.controlledRuntimeDefaultPathMutationCommitApplyId.size == 0) {
        blockers.add("CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_APPLY_ID_NOT_CARRIED")
    }
    if (!request.applyGateSnapshotCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_APPLY_GATE_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.mutationCommitBoundaryCarried) {
        blockers.add("MUTATION_COMMIT_BOUNDARY_NOT_CARRIED")
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
        "unknown-controlled-runtime-default-path-mutation-commit-apply"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_APPLY_GATE")
    }
    blockers.toArray()
}

func igniteControlledRuntimeDefaultPathMutationCommitApplyNonClaims(): Array<String> {
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

public class IgniteRuntimeDefaultPathMutationCommitBoundaryRequest {
    public let runtimeDefaultPathMutationCommitBoundaryId: String
    public let controlledCommitApplySnapshotCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let commitBoundarySnapshotCarried: Bool
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
        runtimeDefaultPathMutationCommitBoundaryId: String,
        controlledCommitApplySnapshotCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        commitBoundarySnapshotCarried: Bool,
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
        this.runtimeDefaultPathMutationCommitBoundaryId =
            runtimeDefaultPathMutationCommitBoundaryId
        this.controlledCommitApplySnapshotCarried =
            controlledCommitApplySnapshotCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.commitBoundarySnapshotCarried = commitBoundarySnapshotCarried
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

public class IgniteRuntimeDefaultPathMutationCommitBoundaryReceipt {
    public let runtimeDefaultPathMutationCommitBoundaryAccepted: Bool
    public let controlledRuntimeDefaultPathMutationCommitApplyAccepted: Bool
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
    public let controlledCommitApplyReceipt: IgniteControlledRuntimeDefaultPathMutationCommitApplyReceipt
    public let runtimeDefaultPathMutationCommitBoundaryRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationCommitBoundaryAllowed: Bool
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
        runtimeDefaultPathMutationCommitBoundaryAccepted: Bool,
        controlledRuntimeDefaultPathMutationCommitApplyAccepted: Bool,
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
        controlledCommitApplyReceipt: IgniteControlledRuntimeDefaultPathMutationCommitApplyReceipt,
        runtimeDefaultPathMutationCommitBoundaryRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationCommitBoundaryAllowed: Bool,
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
        this.runtimeDefaultPathMutationCommitBoundaryAccepted =
            runtimeDefaultPathMutationCommitBoundaryAccepted
        this.controlledRuntimeDefaultPathMutationCommitApplyAccepted =
            controlledRuntimeDefaultPathMutationCommitApplyAccepted
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
        this.controlledCommitApplyReceipt = controlledCommitApplyReceipt
        this.runtimeDefaultPathMutationCommitBoundaryRecorded =
            runtimeDefaultPathMutationCommitBoundaryRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationCommitBoundaryAllowed =
            runtimeDefaultPathMutationCommitBoundaryAllowed
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

public func buildIgniteRuntimeDefaultPathMutationCommitBoundaryReceipt(
    controlledCommitApplyReceipt: IgniteControlledRuntimeDefaultPathMutationCommitApplyReceipt,
    request: IgniteRuntimeDefaultPathMutationCommitBoundaryRequest
): IgniteRuntimeDefaultPathMutationCommitBoundaryReceipt {
    let nonClaims = igniteRuntimeDefaultPathMutationCommitBoundaryNonClaims()
    if (!controlledCommitApplyReceipt.controlledRuntimeDefaultPathMutationCommitApplyAccepted) {
        return IgniteRuntimeDefaultPathMutationCommitBoundaryReceipt(
            false,
            controlledCommitApplyReceipt.controlledRuntimeDefaultPathMutationCommitApplyAccepted,
            controlledCommitApplyReceipt.controlledRuntimeDefaultPathMutationCommitApplyMode,
            "none",
            request.runtimeDefaultPathMutationCommitBoundaryId,
            controlledCommitApplyReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
            controlledCommitApplyReceipt.runtimeDefaultPathMutationCommitApplyGateId,
            controlledCommitApplyReceipt.runtimeDefaultPathMutationCommitDryRunId,
            controlledCommitApplyReceipt.runtimeDefaultPathMutationCommitPlanId,
            controlledCommitApplyReceipt.controlledRuntimeDefaultPathMutationApplyId,
            controlledCommitApplyReceipt.runtimeDefaultPathMutationApplyGateId,
            controlledCommitApplyReceipt.runtimeDefaultPathMutationDryRunId,
            controlledCommitApplyReceipt.runtimeDefaultPathMutationGateId,
            controlledCommitApplyReceipt.controlledDefaultEngineMutationApplyId,
            controlledCommitApplyReceipt.defaultEngineMutationApplyGateId,
            controlledCommitApplyReceipt.defaultEngineMutationDryRunId,
            controlledCommitApplyReceipt.defaultEngineMutationCommitPlanId,
            controlledCommitApplyReceipt,
            false,
            "block",
            "blocked-controlled-runtime-default-path-mutation-commit-apply-receipt",
            "collect-accepted-controlled-runtime-default-path-mutation-commit-apply-receipt-first",
            ["CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_APPLY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0491 controlled runtime default-path mutation commit apply input before commit boundary work",
            "QUIC must not consume runtime default-path mutation commit boundary receipts from rejected controlled commit apply receipts"
        )
    }

    let commitBoundaryMode =
        igniteRuntimeDefaultPathMutationCommitBoundaryModeFor(
            controlledCommitApplyReceipt.controlledRuntimeDefaultPathMutationCommitApplyMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationCommitBoundaryBlockers(
            request,
            commitBoundaryMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationCommitBoundaryReceipt(
            false,
            controlledCommitApplyReceipt.controlledRuntimeDefaultPathMutationCommitApplyAccepted,
            controlledCommitApplyReceipt.controlledRuntimeDefaultPathMutationCommitApplyMode,
            commitBoundaryMode,
            request.runtimeDefaultPathMutationCommitBoundaryId,
            controlledCommitApplyReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
            controlledCommitApplyReceipt.runtimeDefaultPathMutationCommitApplyGateId,
            controlledCommitApplyReceipt.runtimeDefaultPathMutationCommitDryRunId,
            controlledCommitApplyReceipt.runtimeDefaultPathMutationCommitPlanId,
            controlledCommitApplyReceipt.controlledRuntimeDefaultPathMutationApplyId,
            controlledCommitApplyReceipt.runtimeDefaultPathMutationApplyGateId,
            controlledCommitApplyReceipt.runtimeDefaultPathMutationDryRunId,
            controlledCommitApplyReceipt.runtimeDefaultPathMutationGateId,
            controlledCommitApplyReceipt.controlledDefaultEngineMutationApplyId,
            controlledCommitApplyReceipt.defaultEngineMutationApplyGateId,
            controlledCommitApplyReceipt.defaultEngineMutationDryRunId,
            controlledCommitApplyReceipt.defaultEngineMutationCommitPlanId,
            controlledCommitApplyReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-commit-boundary-input",
            "fix-runtime-default-path-mutation-commit-boundary-before-runtime-default-mutation",
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
            "carry commit boundary id, controlled commit apply snapshot, runtime default-path mutation lock, commit boundary snapshot, rollback order, runtime guard plan, observability marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation commit boundary blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationCommitBoundaryReceipt(
        true,
        controlledCommitApplyReceipt.controlledRuntimeDefaultPathMutationCommitApplyAccepted,
        controlledCommitApplyReceipt.controlledRuntimeDefaultPathMutationCommitApplyMode,
        commitBoundaryMode,
        request.runtimeDefaultPathMutationCommitBoundaryId,
        controlledCommitApplyReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
        controlledCommitApplyReceipt.runtimeDefaultPathMutationCommitApplyGateId,
        controlledCommitApplyReceipt.runtimeDefaultPathMutationCommitDryRunId,
        controlledCommitApplyReceipt.runtimeDefaultPathMutationCommitPlanId,
        controlledCommitApplyReceipt.controlledRuntimeDefaultPathMutationApplyId,
        controlledCommitApplyReceipt.runtimeDefaultPathMutationApplyGateId,
        controlledCommitApplyReceipt.runtimeDefaultPathMutationDryRunId,
        controlledCommitApplyReceipt.runtimeDefaultPathMutationGateId,
        controlledCommitApplyReceipt.controlledDefaultEngineMutationApplyId,
        controlledCommitApplyReceipt.defaultEngineMutationApplyGateId,
        controlledCommitApplyReceipt.defaultEngineMutationDryRunId,
        controlledCommitApplyReceipt.defaultEngineMutationCommitPlanId,
        controlledCommitApplyReceipt,
        true,
        "record-runtime-default-path-mutation-commit-boundary",
        "accepted-runtime-default-path-mutation-commit-boundary-receipt",
        "record-runtime-default-path-mutation-commit-boundary-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation finalization gate without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation commit boundary modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationCommitBoundaryModeFor(
    controlledCommitApplyMode: String
): String {
    if (
        controlledCommitApplyMode ==
        "short-controlled-runtime-default-path-mutation-commit-apply"
    ) {
        return "short-runtime-default-path-mutation-commit-boundary"
    }
    if (
        controlledCommitApplyMode ==
        "long-controlled-runtime-default-path-mutation-commit-apply"
    ) {
        return "long-runtime-default-path-mutation-commit-boundary"
    }
    if (
        controlledCommitApplyMode ==
        "blocking-isolation-controlled-runtime-default-path-mutation-commit-apply"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-commit-boundary"
    }
    "unknown-runtime-default-path-mutation-commit-boundary"
}

func igniteRuntimeDefaultPathMutationCommitBoundaryBlockers(
    request: IgniteRuntimeDefaultPathMutationCommitBoundaryRequest,
    commitBoundaryMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.runtimeDefaultPathMutationCommitBoundaryId.size == 0) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_BOUNDARY_ID_NOT_CARRIED")
    }
    if (!request.controlledCommitApplySnapshotCarried) {
        blockers.add("CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_APPLY_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.commitBoundarySnapshotCarried) {
        blockers.add("COMMIT_BOUNDARY_SNAPSHOT_NOT_CARRIED")
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
        commitBoundaryMode ==
        "unknown-runtime-default-path-mutation-commit-boundary"
    ) {
        blockers.add("UNKNOWN_CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_APPLY")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationCommitBoundaryNonClaims(): Array<String> {
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

public class IgniteRuntimeDefaultPathMutationFinalizationGateRequest {
    public let runtimeDefaultPathMutationFinalizationGateId: String
    public let commitBoundarySnapshotCarried: Bool
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
        runtimeDefaultPathMutationFinalizationGateId: String,
        commitBoundarySnapshotCarried: Bool,
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
        this.runtimeDefaultPathMutationFinalizationGateId =
            runtimeDefaultPathMutationFinalizationGateId
        this.commitBoundarySnapshotCarried = commitBoundarySnapshotCarried
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

public class IgniteRuntimeDefaultPathMutationFinalizationGateReceipt {
    public let runtimeDefaultPathMutationFinalizationGateAccepted: Bool
    public let runtimeDefaultPathMutationCommitBoundaryAccepted: Bool
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
    public let commitBoundaryReceipt: IgniteRuntimeDefaultPathMutationCommitBoundaryReceipt
    public let runtimeDefaultPathMutationFinalizationGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationFinalizationGateAllowed: Bool
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
        runtimeDefaultPathMutationFinalizationGateAccepted: Bool,
        runtimeDefaultPathMutationCommitBoundaryAccepted: Bool,
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
        commitBoundaryReceipt: IgniteRuntimeDefaultPathMutationCommitBoundaryReceipt,
        runtimeDefaultPathMutationFinalizationGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationFinalizationGateAllowed: Bool,
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
        this.runtimeDefaultPathMutationFinalizationGateAccepted =
            runtimeDefaultPathMutationFinalizationGateAccepted
        this.runtimeDefaultPathMutationCommitBoundaryAccepted =
            runtimeDefaultPathMutationCommitBoundaryAccepted
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
        this.commitBoundaryReceipt = commitBoundaryReceipt
        this.runtimeDefaultPathMutationFinalizationGateRecorded =
            runtimeDefaultPathMutationFinalizationGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationFinalizationGateAllowed =
            runtimeDefaultPathMutationFinalizationGateAllowed
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

public func buildIgniteRuntimeDefaultPathMutationFinalizationGateReceipt(
    commitBoundaryReceipt: IgniteRuntimeDefaultPathMutationCommitBoundaryReceipt,
    request: IgniteRuntimeDefaultPathMutationFinalizationGateRequest
): IgniteRuntimeDefaultPathMutationFinalizationGateReceipt {
    let nonClaims = igniteRuntimeDefaultPathMutationFinalizationGateNonClaims()
    if (!commitBoundaryReceipt.runtimeDefaultPathMutationCommitBoundaryAccepted) {
        return IgniteRuntimeDefaultPathMutationFinalizationGateReceipt(
            false,
            commitBoundaryReceipt.runtimeDefaultPathMutationCommitBoundaryAccepted,
            commitBoundaryReceipt.runtimeDefaultPathMutationCommitBoundaryMode,
            "none",
            request.runtimeDefaultPathMutationFinalizationGateId,
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
            commitBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-commit-boundary-receipt",
            "collect-accepted-runtime-default-path-mutation-commit-boundary-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_BOUNDARY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0492 runtime default-path mutation commit boundary input before finalization gate work",
            "QUIC must not consume runtime default-path mutation finalization gate receipts from rejected commit boundary receipts"
        )
    }

    let finalizationGateMode =
        igniteRuntimeDefaultPathMutationFinalizationGateModeFor(
            commitBoundaryReceipt.runtimeDefaultPathMutationCommitBoundaryMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationFinalizationGateBlockers(
            request,
            finalizationGateMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationFinalizationGateReceipt(
            false,
            commitBoundaryReceipt.runtimeDefaultPathMutationCommitBoundaryAccepted,
            commitBoundaryReceipt.runtimeDefaultPathMutationCommitBoundaryMode,
            finalizationGateMode,
            request.runtimeDefaultPathMutationFinalizationGateId,
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
            commitBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-finalization-gate-input",
            "fix-runtime-default-path-mutation-finalization-gate-before-runtime-default-mutation",
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
            "carry finalization gate id, commit boundary snapshot, runtime default-path mutation lock, rollback order, runtime guard plan, observability marker, finalization audit marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation finalization gate blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationFinalizationGateReceipt(
        true,
        commitBoundaryReceipt.runtimeDefaultPathMutationCommitBoundaryAccepted,
        commitBoundaryReceipt.runtimeDefaultPathMutationCommitBoundaryMode,
        finalizationGateMode,
        request.runtimeDefaultPathMutationFinalizationGateId,
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
        commitBoundaryReceipt,
        true,
        "record-runtime-default-path-mutation-finalization-gate",
        "accepted-runtime-default-path-mutation-finalization-gate-receipt",
        "record-runtime-default-path-mutation-finalization-gate-without-runtime-default-mutation",
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
        "next packet may prove controlled runtime default-path mutation finalization apply without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation finalization gate modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationFinalizationGateModeFor(
    commitBoundaryMode: String
): String {
    if (
        commitBoundaryMode ==
        "short-runtime-default-path-mutation-commit-boundary"
    ) {
        return "short-runtime-default-path-mutation-finalization-gate"
    }
    if (
        commitBoundaryMode ==
        "long-runtime-default-path-mutation-commit-boundary"
    ) {
        return "long-runtime-default-path-mutation-finalization-gate"
    }
    if (
        commitBoundaryMode ==
        "blocking-isolation-runtime-default-path-mutation-commit-boundary"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-finalization-gate"
    }
    "unknown-runtime-default-path-mutation-finalization-gate"
}

func igniteRuntimeDefaultPathMutationFinalizationGateBlockers(
    request: IgniteRuntimeDefaultPathMutationFinalizationGateRequest,
    finalizationGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.runtimeDefaultPathMutationFinalizationGateId.size == 0) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_FINALIZATION_GATE_ID_NOT_CARRIED")
    }
    if (!request.commitBoundarySnapshotCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_BOUNDARY_SNAPSHOT_NOT_CARRIED")
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
        finalizationGateMode ==
        "unknown-runtime-default-path-mutation-finalization-gate"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_COMMIT_BOUNDARY")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationFinalizationGateNonClaims(): Array<String> {
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

public class IgniteControlledRuntimeDefaultPathMutationFinalizationApplyRequest {
    public let controlledRuntimeDefaultPathMutationFinalizationApplyId: String
    public let finalizationGateSnapshotCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let finalizationApplyBoundaryCarried: Bool
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
        controlledRuntimeDefaultPathMutationFinalizationApplyId: String,
        finalizationGateSnapshotCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        finalizationApplyBoundaryCarried: Bool,
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
        this.controlledRuntimeDefaultPathMutationFinalizationApplyId =
            controlledRuntimeDefaultPathMutationFinalizationApplyId
        this.finalizationGateSnapshotCarried =
            finalizationGateSnapshotCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.finalizationApplyBoundaryCarried =
            finalizationApplyBoundaryCarried
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

public class IgniteControlledRuntimeDefaultPathMutationFinalizationApplyReceipt {
    public let controlledRuntimeDefaultPathMutationFinalizationApplyAccepted: Bool
    public let runtimeDefaultPathMutationFinalizationGateAccepted: Bool
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
    public let finalizationGateReceipt: IgniteRuntimeDefaultPathMutationFinalizationGateReceipt
    public let controlledRuntimeDefaultPathMutationFinalizationApplyRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let controlledRuntimeDefaultPathMutationFinalizationApplyAllowed: Bool
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
        controlledRuntimeDefaultPathMutationFinalizationApplyAccepted: Bool,
        runtimeDefaultPathMutationFinalizationGateAccepted: Bool,
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
        finalizationGateReceipt: IgniteRuntimeDefaultPathMutationFinalizationGateReceipt,
        controlledRuntimeDefaultPathMutationFinalizationApplyRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        controlledRuntimeDefaultPathMutationFinalizationApplyAllowed: Bool,
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
        this.controlledRuntimeDefaultPathMutationFinalizationApplyAccepted =
            controlledRuntimeDefaultPathMutationFinalizationApplyAccepted
        this.runtimeDefaultPathMutationFinalizationGateAccepted =
            runtimeDefaultPathMutationFinalizationGateAccepted
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
        this.finalizationGateReceipt = finalizationGateReceipt
        this.controlledRuntimeDefaultPathMutationFinalizationApplyRecorded =
            controlledRuntimeDefaultPathMutationFinalizationApplyRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.controlledRuntimeDefaultPathMutationFinalizationApplyAllowed =
            controlledRuntimeDefaultPathMutationFinalizationApplyAllowed
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

public func buildIgniteControlledRuntimeDefaultPathMutationFinalizationApplyReceipt(
    finalizationGateReceipt: IgniteRuntimeDefaultPathMutationFinalizationGateReceipt,
    request: IgniteControlledRuntimeDefaultPathMutationFinalizationApplyRequest
): IgniteControlledRuntimeDefaultPathMutationFinalizationApplyReceipt {
    let nonClaims =
        igniteControlledRuntimeDefaultPathMutationFinalizationApplyNonClaims()
    if (
        !finalizationGateReceipt
            .runtimeDefaultPathMutationFinalizationGateAccepted
    ) {
        return IgniteControlledRuntimeDefaultPathMutationFinalizationApplyReceipt(
            false,
            finalizationGateReceipt.runtimeDefaultPathMutationFinalizationGateAccepted,
            finalizationGateReceipt.runtimeDefaultPathMutationFinalizationGateMode,
            "none",
            request.controlledRuntimeDefaultPathMutationFinalizationApplyId,
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
            finalizationGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-finalization-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-finalization-gate-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_FINALIZATION_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0493 runtime default-path mutation finalization gate input before controlled finalization apply work",
            "QUIC must not consume controlled runtime default-path mutation finalization apply receipts from rejected finalization-gate receipts"
        )
    }

    let controlledApplyMode =
        igniteControlledRuntimeDefaultPathMutationFinalizationApplyModeFor(
            finalizationGateReceipt.runtimeDefaultPathMutationFinalizationGateMode
        )
    let blockers =
        igniteControlledRuntimeDefaultPathMutationFinalizationApplyBlockers(
            request,
            controlledApplyMode
        )
    if (blockers.size > 0) {
        return IgniteControlledRuntimeDefaultPathMutationFinalizationApplyReceipt(
            false,
            finalizationGateReceipt.runtimeDefaultPathMutationFinalizationGateAccepted,
            finalizationGateReceipt.runtimeDefaultPathMutationFinalizationGateMode,
            controlledApplyMode,
            request.controlledRuntimeDefaultPathMutationFinalizationApplyId,
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
            finalizationGateReceipt,
            false,
            "block",
            "blocked-controlled-runtime-default-path-mutation-finalization-apply-input",
            "fix-controlled-runtime-default-path-mutation-finalization-apply-before-runtime-default-mutation",
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
            "carry controlled finalization apply id, finalization-gate snapshot, runtime default-path mutation lock, finalization apply boundary, rollback order, runtime guard plan, observability marker, finalization audit marker, and keep runtime default mutation out",
            "QUIC can reuse the same controlled runtime default-path mutation finalization apply blockers before default stream runtime mutation"
        )
    }

    IgniteControlledRuntimeDefaultPathMutationFinalizationApplyReceipt(
        true,
        finalizationGateReceipt.runtimeDefaultPathMutationFinalizationGateAccepted,
        finalizationGateReceipt.runtimeDefaultPathMutationFinalizationGateMode,
        controlledApplyMode,
        request.controlledRuntimeDefaultPathMutationFinalizationApplyId,
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
        finalizationGateReceipt,
        true,
        "record-controlled-runtime-default-path-mutation-finalization-apply",
        "accepted-controlled-runtime-default-path-mutation-finalization-apply-receipt",
        "record-controlled-runtime-default-path-mutation-finalization-apply-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation closeout or stdx claim separation without mutating runtime defaults",
        "QUIC can reuse lane-specific controlled runtime default-path mutation finalization apply modes before runtime default mutation"
    )
}

func igniteControlledRuntimeDefaultPathMutationFinalizationApplyModeFor(
    finalizationGateMode: String
): String {
    if (
        finalizationGateMode ==
        "short-runtime-default-path-mutation-finalization-gate"
    ) {
        return "short-controlled-runtime-default-path-mutation-finalization-apply"
    }
    if (
        finalizationGateMode ==
        "long-runtime-default-path-mutation-finalization-gate"
    ) {
        return "long-controlled-runtime-default-path-mutation-finalization-apply"
    }
    if (
        finalizationGateMode ==
        "blocking-isolation-runtime-default-path-mutation-finalization-gate"
    ) {
        return "blocking-isolation-controlled-runtime-default-path-mutation-finalization-apply"
    }
    "unknown-controlled-runtime-default-path-mutation-finalization-apply"
}

func igniteControlledRuntimeDefaultPathMutationFinalizationApplyBlockers(
    request: IgniteControlledRuntimeDefaultPathMutationFinalizationApplyRequest,
    controlledApplyMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (
        request.controlledRuntimeDefaultPathMutationFinalizationApplyId.size ==
        0
    ) {
        blockers.add("CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_FINALIZATION_APPLY_ID_NOT_CARRIED")
    }
    if (!request.finalizationGateSnapshotCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_FINALIZATION_GATE_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.finalizationApplyBoundaryCarried) {
        blockers.add("FINALIZATION_APPLY_BOUNDARY_NOT_CARRIED")
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
        controlledApplyMode ==
        "unknown-controlled-runtime-default-path-mutation-finalization-apply"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_FINALIZATION_GATE")
    }
    blockers.toArray()
}

func igniteControlledRuntimeDefaultPathMutationFinalizationApplyNonClaims(): Array<String> {
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

public class IgniteRuntimeDefaultPathMutationCloseoutGateRequest {
    public let runtimeDefaultPathMutationCloseoutGateId: String
    public let controlledFinalizationApplySnapshotCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let closeoutBoundaryCarried: Bool
    public let rollbackOrderCarried: Bool
    public let runtimeGuardPlanCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let finalizationAuditMarkerCarried: Bool
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
        runtimeDefaultPathMutationCloseoutGateId: String,
        controlledFinalizationApplySnapshotCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        closeoutBoundaryCarried: Bool,
        rollbackOrderCarried: Bool,
        runtimeGuardPlanCarried: Bool,
        observabilityMarkerCarried: Bool,
        finalizationAuditMarkerCarried: Bool,
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
        this.runtimeDefaultPathMutationCloseoutGateId =
            runtimeDefaultPathMutationCloseoutGateId
        this.controlledFinalizationApplySnapshotCarried =
            controlledFinalizationApplySnapshotCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.closeoutBoundaryCarried = closeoutBoundaryCarried
        this.rollbackOrderCarried = rollbackOrderCarried
        this.runtimeGuardPlanCarried = runtimeGuardPlanCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
        this.finalizationAuditMarkerCarried = finalizationAuditMarkerCarried
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

public class IgniteRuntimeDefaultPathMutationCloseoutGateReceipt {
    public let runtimeDefaultPathMutationCloseoutGateAccepted: Bool
    public let controlledRuntimeDefaultPathMutationFinalizationApplyAccepted: Bool
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
    public let controlledFinalizationApplyReceipt: IgniteControlledRuntimeDefaultPathMutationFinalizationApplyReceipt
    public let runtimeDefaultPathMutationCloseoutGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationCloseoutGateAllowed: Bool
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
        runtimeDefaultPathMutationCloseoutGateAccepted: Bool,
        controlledRuntimeDefaultPathMutationFinalizationApplyAccepted: Bool,
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
        controlledFinalizationApplyReceipt: IgniteControlledRuntimeDefaultPathMutationFinalizationApplyReceipt,
        runtimeDefaultPathMutationCloseoutGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationCloseoutGateAllowed: Bool,
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
        this.runtimeDefaultPathMutationCloseoutGateAccepted =
            runtimeDefaultPathMutationCloseoutGateAccepted
        this.controlledRuntimeDefaultPathMutationFinalizationApplyAccepted =
            controlledRuntimeDefaultPathMutationFinalizationApplyAccepted
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
        this.controlledFinalizationApplyReceipt =
            controlledFinalizationApplyReceipt
        this.runtimeDefaultPathMutationCloseoutGateRecorded =
            runtimeDefaultPathMutationCloseoutGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationCloseoutGateAllowed =
            runtimeDefaultPathMutationCloseoutGateAllowed
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

public func buildIgniteRuntimeDefaultPathMutationCloseoutGateReceipt(
    controlledFinalizationApplyReceipt: IgniteControlledRuntimeDefaultPathMutationFinalizationApplyReceipt,
    request: IgniteRuntimeDefaultPathMutationCloseoutGateRequest
): IgniteRuntimeDefaultPathMutationCloseoutGateReceipt {
    let nonClaims = igniteRuntimeDefaultPathMutationCloseoutGateNonClaims()
    if (
        !controlledFinalizationApplyReceipt
            .controlledRuntimeDefaultPathMutationFinalizationApplyAccepted
    ) {
        return IgniteRuntimeDefaultPathMutationCloseoutGateReceipt(
            false,
            controlledFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyAccepted,
            controlledFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyMode,
            "none",
            request.runtimeDefaultPathMutationCloseoutGateId,
            controlledFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyId,
            controlledFinalizationApplyReceipt.runtimeDefaultPathMutationFinalizationGateId,
            controlledFinalizationApplyReceipt.runtimeDefaultPathMutationCommitBoundaryId,
            controlledFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
            controlledFinalizationApplyReceipt.runtimeDefaultPathMutationCommitApplyGateId,
            controlledFinalizationApplyReceipt.runtimeDefaultPathMutationCommitDryRunId,
            controlledFinalizationApplyReceipt.runtimeDefaultPathMutationCommitPlanId,
            controlledFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationApplyId,
            controlledFinalizationApplyReceipt.runtimeDefaultPathMutationApplyGateId,
            controlledFinalizationApplyReceipt.runtimeDefaultPathMutationDryRunId,
            controlledFinalizationApplyReceipt.runtimeDefaultPathMutationGateId,
            controlledFinalizationApplyReceipt.controlledDefaultEngineMutationApplyId,
            controlledFinalizationApplyReceipt.defaultEngineMutationApplyGateId,
            controlledFinalizationApplyReceipt.defaultEngineMutationDryRunId,
            controlledFinalizationApplyReceipt.defaultEngineMutationCommitPlanId,
            controlledFinalizationApplyReceipt,
            false,
            "block",
            "blocked-controlled-runtime-default-path-mutation-finalization-apply-receipt",
            "collect-accepted-controlled-runtime-default-path-mutation-finalization-apply-receipt-first",
            ["CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_FINALIZATION_APPLY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0494 controlled runtime default-path mutation finalization apply input before closeout gate work",
            "QUIC must not consume runtime default-path mutation closeout gate receipts from rejected controlled finalization-apply receipts"
        )
    }

    let closeoutGateMode =
        igniteRuntimeDefaultPathMutationCloseoutGateModeFor(
            controlledFinalizationApplyReceipt
                .controlledRuntimeDefaultPathMutationFinalizationApplyMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationCloseoutGateBlockers(
            request,
            closeoutGateMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationCloseoutGateReceipt(
            false,
            controlledFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyAccepted,
            controlledFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyMode,
            closeoutGateMode,
            request.runtimeDefaultPathMutationCloseoutGateId,
            controlledFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyId,
            controlledFinalizationApplyReceipt.runtimeDefaultPathMutationFinalizationGateId,
            controlledFinalizationApplyReceipt.runtimeDefaultPathMutationCommitBoundaryId,
            controlledFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
            controlledFinalizationApplyReceipt.runtimeDefaultPathMutationCommitApplyGateId,
            controlledFinalizationApplyReceipt.runtimeDefaultPathMutationCommitDryRunId,
            controlledFinalizationApplyReceipt.runtimeDefaultPathMutationCommitPlanId,
            controlledFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationApplyId,
            controlledFinalizationApplyReceipt.runtimeDefaultPathMutationApplyGateId,
            controlledFinalizationApplyReceipt.runtimeDefaultPathMutationDryRunId,
            controlledFinalizationApplyReceipt.runtimeDefaultPathMutationGateId,
            controlledFinalizationApplyReceipt.controlledDefaultEngineMutationApplyId,
            controlledFinalizationApplyReceipt.defaultEngineMutationApplyGateId,
            controlledFinalizationApplyReceipt.defaultEngineMutationDryRunId,
            controlledFinalizationApplyReceipt.defaultEngineMutationCommitPlanId,
            controlledFinalizationApplyReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-closeout-gate-input",
            "fix-runtime-default-path-mutation-closeout-gate-before-runtime-default-mutation",
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
            "carry closeout gate id, controlled finalization-apply snapshot, runtime default-path mutation lock, closeout boundary, rollback order, runtime guard plan, observability marker, finalization audit marker, closeout audit marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation closeout gate blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationCloseoutGateReceipt(
        true,
        controlledFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyAccepted,
        controlledFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyMode,
        closeoutGateMode,
        request.runtimeDefaultPathMutationCloseoutGateId,
        controlledFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyId,
        controlledFinalizationApplyReceipt.runtimeDefaultPathMutationFinalizationGateId,
        controlledFinalizationApplyReceipt.runtimeDefaultPathMutationCommitBoundaryId,
        controlledFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
        controlledFinalizationApplyReceipt.runtimeDefaultPathMutationCommitApplyGateId,
        controlledFinalizationApplyReceipt.runtimeDefaultPathMutationCommitDryRunId,
        controlledFinalizationApplyReceipt.runtimeDefaultPathMutationCommitPlanId,
        controlledFinalizationApplyReceipt.controlledRuntimeDefaultPathMutationApplyId,
        controlledFinalizationApplyReceipt.runtimeDefaultPathMutationApplyGateId,
        controlledFinalizationApplyReceipt.runtimeDefaultPathMutationDryRunId,
        controlledFinalizationApplyReceipt.runtimeDefaultPathMutationGateId,
        controlledFinalizationApplyReceipt.controlledDefaultEngineMutationApplyId,
        controlledFinalizationApplyReceipt.defaultEngineMutationApplyGateId,
        controlledFinalizationApplyReceipt.defaultEngineMutationDryRunId,
        controlledFinalizationApplyReceipt.defaultEngineMutationCommitPlanId,
        controlledFinalizationApplyReceipt,
        true,
        "record-runtime-default-path-mutation-closeout-gate",
        "accepted-runtime-default-path-mutation-closeout-gate-receipt",
        "record-runtime-default-path-mutation-closeout-gate-without-runtime-default-mutation",
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
        "next packet may prove stdx claim separation or runtime default-path mutation handoff without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation closeout gate modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationCloseoutGateModeFor(
    controlledApplyMode: String
): String {
    if (
        controlledApplyMode ==
        "short-controlled-runtime-default-path-mutation-finalization-apply"
    ) {
        return "short-runtime-default-path-mutation-closeout-gate"
    }
    if (
        controlledApplyMode ==
        "long-controlled-runtime-default-path-mutation-finalization-apply"
    ) {
        return "long-runtime-default-path-mutation-closeout-gate"
    }
    if (
        controlledApplyMode ==
        "blocking-isolation-controlled-runtime-default-path-mutation-finalization-apply"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-closeout-gate"
    }
    "unknown-runtime-default-path-mutation-closeout-gate"
}

func igniteRuntimeDefaultPathMutationCloseoutGateBlockers(
    request: IgniteRuntimeDefaultPathMutationCloseoutGateRequest,
    closeoutGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.runtimeDefaultPathMutationCloseoutGateId.size == 0) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_CLOSEOUT_GATE_ID_NOT_CARRIED")
    }
    if (!request.controlledFinalizationApplySnapshotCarried) {
        blockers.add("CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_FINALIZATION_APPLY_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.closeoutBoundaryCarried) {
        blockers.add("CLOSEOUT_BOUNDARY_NOT_CARRIED")
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
        "unknown-runtime-default-path-mutation-closeout-gate"
    ) {
        blockers.add("UNKNOWN_CONTROLLED_RUNTIME_DEFAULT_PATH_MUTATION_FINALIZATION_APPLY")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationCloseoutGateNonClaims(): Array<String> {
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

public class IgniteRuntimeDefaultPathMutationHandoffGateRequest {
    public let runtimeDefaultPathMutationHandoffGateId: String
    public let closeoutGateReceiptCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let handoffBoundaryCarried: Bool
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
        runtimeDefaultPathMutationHandoffGateId: String,
        closeoutGateReceiptCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        handoffBoundaryCarried: Bool,
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
        this.runtimeDefaultPathMutationHandoffGateId =
            runtimeDefaultPathMutationHandoffGateId
        this.closeoutGateReceiptCarried = closeoutGateReceiptCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.handoffBoundaryCarried = handoffBoundaryCarried
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

public class IgniteRuntimeDefaultPathMutationHandoffGateReceipt {
    public let runtimeDefaultPathMutationHandoffGateAccepted: Bool
    public let runtimeDefaultPathMutationCloseoutGateAccepted: Bool
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
    public let closeoutGateReceipt: IgniteRuntimeDefaultPathMutationCloseoutGateReceipt
    public let runtimeDefaultPathMutationHandoffGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationHandoffGateAllowed: Bool
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
        runtimeDefaultPathMutationHandoffGateAccepted: Bool,
        runtimeDefaultPathMutationCloseoutGateAccepted: Bool,
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
        closeoutGateReceipt: IgniteRuntimeDefaultPathMutationCloseoutGateReceipt,
        runtimeDefaultPathMutationHandoffGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationHandoffGateAllowed: Bool,
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
        this.runtimeDefaultPathMutationHandoffGateAccepted =
            runtimeDefaultPathMutationHandoffGateAccepted
        this.runtimeDefaultPathMutationCloseoutGateAccepted =
            runtimeDefaultPathMutationCloseoutGateAccepted
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
        this.closeoutGateReceipt = closeoutGateReceipt
        this.runtimeDefaultPathMutationHandoffGateRecorded =
            runtimeDefaultPathMutationHandoffGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationHandoffGateAllowed =
            runtimeDefaultPathMutationHandoffGateAllowed
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

public func buildIgniteRuntimeDefaultPathMutationHandoffGateReceipt(
    closeoutGateReceipt: IgniteRuntimeDefaultPathMutationCloseoutGateReceipt,
    request: IgniteRuntimeDefaultPathMutationHandoffGateRequest
): IgniteRuntimeDefaultPathMutationHandoffGateReceipt {
    let nonClaims = igniteRuntimeDefaultPathMutationHandoffGateNonClaims()
    if (!closeoutGateReceipt.runtimeDefaultPathMutationCloseoutGateAccepted) {
        return IgniteRuntimeDefaultPathMutationHandoffGateReceipt(
            false,
            closeoutGateReceipt.runtimeDefaultPathMutationCloseoutGateAccepted,
            closeoutGateReceipt.runtimeDefaultPathMutationCloseoutGateMode,
            "none",
            request.runtimeDefaultPathMutationHandoffGateId,
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
            closeoutGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-closeout-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-closeout-gate-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_CLOSEOUT_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0495 runtime default-path mutation closeout gate input before handoff gate work",
            "QUIC must not consume runtime default-path mutation handoff gate receipts from rejected closeout-gate receipts"
        )
    }

    let handoffGateMode =
        igniteRuntimeDefaultPathMutationHandoffGateModeFor(
            closeoutGateReceipt.runtimeDefaultPathMutationCloseoutGateMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationHandoffGateBlockers(
            request,
            handoffGateMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationHandoffGateReceipt(
            false,
            closeoutGateReceipt.runtimeDefaultPathMutationCloseoutGateAccepted,
            closeoutGateReceipt.runtimeDefaultPathMutationCloseoutGateMode,
            handoffGateMode,
            request.runtimeDefaultPathMutationHandoffGateId,
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
            closeoutGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-handoff-gate-input",
            "fix-runtime-default-path-mutation-handoff-gate-before-runtime-default-mutation",
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
            "carry handoff gate id, closeout-gate receipt, runtime default-path mutation lock, handoff boundary, downstream consumer boundary, rollback order, runtime guard plan, observability marker, handoff audit marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation handoff gate blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationHandoffGateReceipt(
        true,
        closeoutGateReceipt.runtimeDefaultPathMutationCloseoutGateAccepted,
        closeoutGateReceipt.runtimeDefaultPathMutationCloseoutGateMode,
        handoffGateMode,
        request.runtimeDefaultPathMutationHandoffGateId,
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
        closeoutGateReceipt,
        true,
        "record-runtime-default-path-mutation-handoff-gate",
        "accepted-runtime-default-path-mutation-handoff-gate-receipt",
        "record-runtime-default-path-mutation-handoff-gate-without-runtime-default-mutation",
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
        "next packet may prove stdx claim separation or runtime default-path mutation acceptance boundary without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation handoff gate modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationHandoffGateModeFor(
    closeoutGateMode: String
): String {
    if (
        closeoutGateMode ==
        "short-runtime-default-path-mutation-closeout-gate"
    ) {
        return "short-runtime-default-path-mutation-handoff-gate"
    }
    if (
        closeoutGateMode ==
        "long-runtime-default-path-mutation-closeout-gate"
    ) {
        return "long-runtime-default-path-mutation-handoff-gate"
    }
    if (
        closeoutGateMode ==
        "blocking-isolation-runtime-default-path-mutation-closeout-gate"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-handoff-gate"
    }
    "unknown-runtime-default-path-mutation-handoff-gate"
}

func igniteRuntimeDefaultPathMutationHandoffGateBlockers(
    request: IgniteRuntimeDefaultPathMutationHandoffGateRequest,
    handoffGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.runtimeDefaultPathMutationHandoffGateId.size == 0) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_HANDOFF_GATE_ID_NOT_CARRIED")
    }
    if (!request.closeoutGateReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_CLOSEOUT_GATE_RECEIPT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.handoffBoundaryCarried) {
        blockers.add("HANDOFF_BOUNDARY_NOT_CARRIED")
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
        handoffGateMode ==
        "unknown-runtime-default-path-mutation-handoff-gate"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_CLOSEOUT_GATE")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationHandoffGateNonClaims(): Array<String> {
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

public class IgniteRuntimeDefaultPathMutationAcceptanceBoundaryRequest {
    public let runtimeDefaultPathMutationAcceptanceBoundaryId: String
    public let handoffGateReceiptCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let acceptanceBoundaryCarried: Bool
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
        runtimeDefaultPathMutationAcceptanceBoundaryId: String,
        handoffGateReceiptCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        acceptanceBoundaryCarried: Bool,
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
        this.runtimeDefaultPathMutationAcceptanceBoundaryId =
            runtimeDefaultPathMutationAcceptanceBoundaryId
        this.handoffGateReceiptCarried = handoffGateReceiptCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.acceptanceBoundaryCarried = acceptanceBoundaryCarried
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

public class IgniteRuntimeDefaultPathMutationAcceptanceBoundaryReceipt {
    public let runtimeDefaultPathMutationAcceptanceBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationHandoffGateAccepted: Bool
    public let runtimeDefaultPathMutationHandoffGateMode: String
    public let runtimeDefaultPathMutationAcceptanceBoundaryMode: String
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
    public let handoffGateReceipt: IgniteRuntimeDefaultPathMutationHandoffGateReceipt
    public let runtimeDefaultPathMutationAcceptanceBoundaryRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationAcceptanceBoundaryAllowed: Bool
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
        runtimeDefaultPathMutationAcceptanceBoundaryAccepted: Bool,
        runtimeDefaultPathMutationHandoffGateAccepted: Bool,
        runtimeDefaultPathMutationHandoffGateMode: String,
        runtimeDefaultPathMutationAcceptanceBoundaryMode: String,
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
        handoffGateReceipt: IgniteRuntimeDefaultPathMutationHandoffGateReceipt,
        runtimeDefaultPathMutationAcceptanceBoundaryRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationAcceptanceBoundaryAllowed: Bool,
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
        this.runtimeDefaultPathMutationAcceptanceBoundaryAccepted =
            runtimeDefaultPathMutationAcceptanceBoundaryAccepted
        this.runtimeDefaultPathMutationHandoffGateAccepted =
            runtimeDefaultPathMutationHandoffGateAccepted
        this.runtimeDefaultPathMutationHandoffGateMode =
            runtimeDefaultPathMutationHandoffGateMode
        this.runtimeDefaultPathMutationAcceptanceBoundaryMode =
            runtimeDefaultPathMutationAcceptanceBoundaryMode
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
        this.handoffGateReceipt = handoffGateReceipt
        this.runtimeDefaultPathMutationAcceptanceBoundaryRecorded =
            runtimeDefaultPathMutationAcceptanceBoundaryRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationAcceptanceBoundaryAllowed =
            runtimeDefaultPathMutationAcceptanceBoundaryAllowed
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

public func buildIgniteRuntimeDefaultPathMutationAcceptanceBoundaryReceipt(
    handoffGateReceipt: IgniteRuntimeDefaultPathMutationHandoffGateReceipt,
    request: IgniteRuntimeDefaultPathMutationAcceptanceBoundaryRequest
): IgniteRuntimeDefaultPathMutationAcceptanceBoundaryReceipt {
    let nonClaims =
        igniteRuntimeDefaultPathMutationAcceptanceBoundaryNonClaims()
    if (!handoffGateReceipt.runtimeDefaultPathMutationHandoffGateAccepted) {
        return IgniteRuntimeDefaultPathMutationAcceptanceBoundaryReceipt(
            false,
            handoffGateReceipt.runtimeDefaultPathMutationHandoffGateAccepted,
            handoffGateReceipt.runtimeDefaultPathMutationHandoffGateMode,
            "none",
            request.runtimeDefaultPathMutationAcceptanceBoundaryId,
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
            handoffGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-handoff-gate-receipt",
            "collect-accepted-runtime-default-path-mutation-handoff-gate-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_HANDOFF_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0496 runtime default-path mutation handoff gate input before acceptance boundary work",
            "QUIC must not consume runtime default-path mutation acceptance-boundary receipts from rejected handoff-gate receipts"
        )
    }

    let acceptanceBoundaryMode =
        igniteRuntimeDefaultPathMutationAcceptanceBoundaryModeFor(
            handoffGateReceipt.runtimeDefaultPathMutationHandoffGateMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationAcceptanceBoundaryBlockers(
            request,
            acceptanceBoundaryMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationAcceptanceBoundaryReceipt(
            false,
            handoffGateReceipt.runtimeDefaultPathMutationHandoffGateAccepted,
            handoffGateReceipt.runtimeDefaultPathMutationHandoffGateMode,
            acceptanceBoundaryMode,
            request.runtimeDefaultPathMutationAcceptanceBoundaryId,
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
            handoffGateReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-acceptance-boundary-input",
            "fix-runtime-default-path-mutation-acceptance-boundary-before-runtime-default-mutation",
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
            "carry acceptance boundary id, handoff-gate receipt, runtime default-path mutation lock, acceptance boundary, downstream consumer boundary, rollback order, runtime guard plan, observability marker, acceptance audit marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation acceptance-boundary blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationAcceptanceBoundaryReceipt(
        true,
        handoffGateReceipt.runtimeDefaultPathMutationHandoffGateAccepted,
        handoffGateReceipt.runtimeDefaultPathMutationHandoffGateMode,
        acceptanceBoundaryMode,
        request.runtimeDefaultPathMutationAcceptanceBoundaryId,
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
        handoffGateReceipt,
        true,
        "record-runtime-default-path-mutation-acceptance-boundary",
        "accepted-runtime-default-path-mutation-acceptance-boundary-receipt",
        "record-runtime-default-path-mutation-acceptance-boundary-without-runtime-default-mutation",
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
        "next packet may prove stdx claim separation or runtime default-path mutation apply boundary without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation acceptance-boundary modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationAcceptanceBoundaryModeFor(
    handoffGateMode: String
): String {
    if (
        handoffGateMode ==
        "short-runtime-default-path-mutation-handoff-gate"
    ) {
        return "short-runtime-default-path-mutation-acceptance-boundary"
    }
    if (
        handoffGateMode ==
        "long-runtime-default-path-mutation-handoff-gate"
    ) {
        return "long-runtime-default-path-mutation-acceptance-boundary"
    }
    if (
        handoffGateMode ==
        "blocking-isolation-runtime-default-path-mutation-handoff-gate"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-acceptance-boundary"
    }
    "unknown-runtime-default-path-mutation-acceptance-boundary"
}

func igniteRuntimeDefaultPathMutationAcceptanceBoundaryBlockers(
    request: IgniteRuntimeDefaultPathMutationAcceptanceBoundaryRequest,
    acceptanceBoundaryMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.runtimeDefaultPathMutationAcceptanceBoundaryId.size == 0) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_ACCEPTANCE_BOUNDARY_ID_NOT_CARRIED")
    }
    if (!request.handoffGateReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_HANDOFF_GATE_RECEIPT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.acceptanceBoundaryCarried) {
        blockers.add("ACCEPTANCE_BOUNDARY_NOT_CARRIED")
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
        acceptanceBoundaryMode ==
        "unknown-runtime-default-path-mutation-acceptance-boundary"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_HANDOFF_GATE")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationAcceptanceBoundaryNonClaims(): Array<String> {
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

public class IgniteRuntimeDefaultPathMutationApplyBoundaryRequest {
    public let runtimeDefaultPathMutationApplyBoundaryId: String
    public let acceptanceBoundaryReceiptCarried: Bool
    public let runtimeDefaultPathMutationLockCarried: Bool
    public let applyBoundaryCarried: Bool
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
        runtimeDefaultPathMutationApplyBoundaryId: String,
        acceptanceBoundaryReceiptCarried: Bool,
        runtimeDefaultPathMutationLockCarried: Bool,
        applyBoundaryCarried: Bool,
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
        this.runtimeDefaultPathMutationApplyBoundaryId =
            runtimeDefaultPathMutationApplyBoundaryId
        this.acceptanceBoundaryReceiptCarried =
            acceptanceBoundaryReceiptCarried
        this.runtimeDefaultPathMutationLockCarried =
            runtimeDefaultPathMutationLockCarried
        this.applyBoundaryCarried = applyBoundaryCarried
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

public class IgniteRuntimeDefaultPathMutationApplyBoundaryReceipt {
    public let runtimeDefaultPathMutationApplyBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationAcceptanceBoundaryAccepted: Bool
    public let runtimeDefaultPathMutationAcceptanceBoundaryMode: String
    public let runtimeDefaultPathMutationApplyBoundaryMode: String
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
    public let acceptanceBoundaryReceipt: IgniteRuntimeDefaultPathMutationAcceptanceBoundaryReceipt
    public let runtimeDefaultPathMutationApplyBoundaryRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDefaultPathMutationApplyBoundaryAllowed: Bool
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
        runtimeDefaultPathMutationApplyBoundaryAccepted: Bool,
        runtimeDefaultPathMutationAcceptanceBoundaryAccepted: Bool,
        runtimeDefaultPathMutationAcceptanceBoundaryMode: String,
        runtimeDefaultPathMutationApplyBoundaryMode: String,
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
        acceptanceBoundaryReceipt: IgniteRuntimeDefaultPathMutationAcceptanceBoundaryReceipt,
        runtimeDefaultPathMutationApplyBoundaryRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDefaultPathMutationApplyBoundaryAllowed: Bool,
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
        this.runtimeDefaultPathMutationApplyBoundaryAccepted =
            runtimeDefaultPathMutationApplyBoundaryAccepted
        this.runtimeDefaultPathMutationAcceptanceBoundaryAccepted =
            runtimeDefaultPathMutationAcceptanceBoundaryAccepted
        this.runtimeDefaultPathMutationAcceptanceBoundaryMode =
            runtimeDefaultPathMutationAcceptanceBoundaryMode
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
        this.acceptanceBoundaryReceipt = acceptanceBoundaryReceipt
        this.runtimeDefaultPathMutationApplyBoundaryRecorded =
            runtimeDefaultPathMutationApplyBoundaryRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDefaultPathMutationApplyBoundaryAllowed =
            runtimeDefaultPathMutationApplyBoundaryAllowed
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

public func buildIgniteRuntimeDefaultPathMutationApplyBoundaryReceipt(
    acceptanceBoundaryReceipt: IgniteRuntimeDefaultPathMutationAcceptanceBoundaryReceipt,
    request: IgniteRuntimeDefaultPathMutationApplyBoundaryRequest
): IgniteRuntimeDefaultPathMutationApplyBoundaryReceipt {
    let nonClaims = igniteRuntimeDefaultPathMutationApplyBoundaryNonClaims()
    if (!acceptanceBoundaryReceipt.runtimeDefaultPathMutationAcceptanceBoundaryAccepted) {
        return IgniteRuntimeDefaultPathMutationApplyBoundaryReceipt(
            false,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationAcceptanceBoundaryAccepted,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationAcceptanceBoundaryMode,
            "none",
            request.runtimeDefaultPathMutationApplyBoundaryId,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationAcceptanceBoundaryId,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationHandoffGateId,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationCloseoutGateId,
            acceptanceBoundaryReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyId,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationFinalizationGateId,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationCommitBoundaryId,
            acceptanceBoundaryReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationCommitApplyGateId,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationCommitDryRunId,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationCommitPlanId,
            acceptanceBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyId,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyGateId,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationDryRunId,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationGateId,
            acceptanceBoundaryReceipt.controlledDefaultEngineMutationApplyId,
            acceptanceBoundaryReceipt.defaultEngineMutationApplyGateId,
            acceptanceBoundaryReceipt.defaultEngineMutationDryRunId,
            acceptanceBoundaryReceipt.defaultEngineMutationCommitPlanId,
            acceptanceBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-acceptance-boundary-receipt",
            "collect-accepted-runtime-default-path-mutation-acceptance-boundary-receipt-first",
            ["RUNTIME_DEFAULT_PATH_MUTATION_ACCEPTANCE_BOUNDARY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
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
            "return to HQ-0497 runtime default-path mutation acceptance boundary input before apply-boundary work",
            "QUIC must not consume runtime default-path mutation apply-boundary receipts from rejected acceptance-boundary receipts"
        )
    }

    let applyBoundaryMode =
        igniteRuntimeDefaultPathMutationApplyBoundaryModeFor(
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationAcceptanceBoundaryMode
        )
    let blockers =
        igniteRuntimeDefaultPathMutationApplyBoundaryBlockers(
            request,
            applyBoundaryMode
        )
    if (blockers.size > 0) {
        return IgniteRuntimeDefaultPathMutationApplyBoundaryReceipt(
            false,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationAcceptanceBoundaryAccepted,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationAcceptanceBoundaryMode,
            applyBoundaryMode,
            request.runtimeDefaultPathMutationApplyBoundaryId,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationAcceptanceBoundaryId,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationHandoffGateId,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationCloseoutGateId,
            acceptanceBoundaryReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyId,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationFinalizationGateId,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationCommitBoundaryId,
            acceptanceBoundaryReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationCommitApplyGateId,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationCommitDryRunId,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationCommitPlanId,
            acceptanceBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyId,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyGateId,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationDryRunId,
            acceptanceBoundaryReceipt.runtimeDefaultPathMutationGateId,
            acceptanceBoundaryReceipt.controlledDefaultEngineMutationApplyId,
            acceptanceBoundaryReceipt.defaultEngineMutationApplyGateId,
            acceptanceBoundaryReceipt.defaultEngineMutationDryRunId,
            acceptanceBoundaryReceipt.defaultEngineMutationCommitPlanId,
            acceptanceBoundaryReceipt,
            false,
            "block",
            "blocked-runtime-default-path-mutation-apply-boundary-input",
            "fix-runtime-default-path-mutation-apply-boundary-before-runtime-default-mutation",
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
            "carry apply-boundary id, acceptance-boundary receipt, runtime default-path mutation lock, apply boundary, downstream consumer boundary, rollback order, runtime guard plan, observability marker, apply audit marker, and keep runtime default mutation out",
            "QUIC can reuse the same runtime default-path mutation apply-boundary blockers before default stream runtime mutation"
        )
    }

    IgniteRuntimeDefaultPathMutationApplyBoundaryReceipt(
        true,
        acceptanceBoundaryReceipt.runtimeDefaultPathMutationAcceptanceBoundaryAccepted,
        acceptanceBoundaryReceipt.runtimeDefaultPathMutationAcceptanceBoundaryMode,
        applyBoundaryMode,
        request.runtimeDefaultPathMutationApplyBoundaryId,
        acceptanceBoundaryReceipt.runtimeDefaultPathMutationAcceptanceBoundaryId,
        acceptanceBoundaryReceipt.runtimeDefaultPathMutationHandoffGateId,
        acceptanceBoundaryReceipt.runtimeDefaultPathMutationCloseoutGateId,
        acceptanceBoundaryReceipt.controlledRuntimeDefaultPathMutationFinalizationApplyId,
        acceptanceBoundaryReceipt.runtimeDefaultPathMutationFinalizationGateId,
        acceptanceBoundaryReceipt.runtimeDefaultPathMutationCommitBoundaryId,
        acceptanceBoundaryReceipt.controlledRuntimeDefaultPathMutationCommitApplyId,
        acceptanceBoundaryReceipt.runtimeDefaultPathMutationCommitApplyGateId,
        acceptanceBoundaryReceipt.runtimeDefaultPathMutationCommitDryRunId,
        acceptanceBoundaryReceipt.runtimeDefaultPathMutationCommitPlanId,
        acceptanceBoundaryReceipt.controlledRuntimeDefaultPathMutationApplyId,
        acceptanceBoundaryReceipt.runtimeDefaultPathMutationApplyGateId,
        acceptanceBoundaryReceipt.runtimeDefaultPathMutationDryRunId,
        acceptanceBoundaryReceipt.runtimeDefaultPathMutationGateId,
        acceptanceBoundaryReceipt.controlledDefaultEngineMutationApplyId,
        acceptanceBoundaryReceipt.defaultEngineMutationApplyGateId,
        acceptanceBoundaryReceipt.defaultEngineMutationDryRunId,
        acceptanceBoundaryReceipt.defaultEngineMutationCommitPlanId,
        acceptanceBoundaryReceipt,
        true,
        "record-runtime-default-path-mutation-apply-boundary",
        "accepted-runtime-default-path-mutation-apply-boundary-receipt",
        "record-runtime-default-path-mutation-apply-boundary-without-runtime-default-mutation",
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
        "next packet may prove runtime default-path mutation apply dry-run or stdx claim separation without mutating runtime defaults",
        "QUIC can reuse lane-specific runtime default-path mutation apply-boundary modes before runtime default mutation"
    )
}

func igniteRuntimeDefaultPathMutationApplyBoundaryModeFor(
    acceptanceBoundaryMode: String
): String {
    if (
        acceptanceBoundaryMode ==
        "short-runtime-default-path-mutation-acceptance-boundary"
    ) {
        return "short-runtime-default-path-mutation-apply-boundary"
    }
    if (
        acceptanceBoundaryMode ==
        "long-runtime-default-path-mutation-acceptance-boundary"
    ) {
        return "long-runtime-default-path-mutation-apply-boundary"
    }
    if (
        acceptanceBoundaryMode ==
        "blocking-isolation-runtime-default-path-mutation-acceptance-boundary"
    ) {
        return "blocking-isolation-runtime-default-path-mutation-apply-boundary"
    }
    "unknown-runtime-default-path-mutation-apply-boundary"
}

func igniteRuntimeDefaultPathMutationApplyBoundaryBlockers(
    request: IgniteRuntimeDefaultPathMutationApplyBoundaryRequest,
    applyBoundaryMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.runtimeDefaultPathMutationApplyBoundaryId.size == 0) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_APPLY_BOUNDARY_ID_NOT_CARRIED")
    }
    if (!request.acceptanceBoundaryReceiptCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_ACCEPTANCE_BOUNDARY_RECEIPT_NOT_CARRIED")
    }
    if (!request.runtimeDefaultPathMutationLockCarried) {
        blockers.add("RUNTIME_DEFAULT_PATH_MUTATION_LOCK_NOT_CARRIED")
    }
    if (!request.applyBoundaryCarried) {
        blockers.add("APPLY_BOUNDARY_NOT_CARRIED")
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
        applyBoundaryMode ==
        "unknown-runtime-default-path-mutation-apply-boundary"
    ) {
        blockers.add("UNKNOWN_RUNTIME_DEFAULT_PATH_MUTATION_ACCEPTANCE_BOUNDARY")
    }
    blockers.toArray()
}

func igniteRuntimeDefaultPathMutationApplyBoundaryNonClaims(): Array<String> {
    igniteRuntimeDefaultPathMutationAcceptanceBoundaryNonClaims()
}
