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

public class IgniteRuntimeConcurrencyDesignEvidence {
    public let requestLevelSchedulerProof: Bool
    public let handlerIoDecouplingProof: Bool
    public let longShortTaskLaneProof: Bool
    public let blockingExternalOperationIsolationProof: Bool
    public let fairnessBackpressureProof: Bool

    public init(
        requestLevelSchedulerProof: Bool,
        handlerIoDecouplingProof: Bool,
        longShortTaskLaneProof: Bool,
        blockingExternalOperationIsolationProof: Bool,
        fairnessBackpressureProof: Bool
    ) {
        this.requestLevelSchedulerProof = requestLevelSchedulerProof
        this.handlerIoDecouplingProof = handlerIoDecouplingProof
        this.longShortTaskLaneProof = longShortTaskLaneProof
        this.blockingExternalOperationIsolationProof =
            blockingExternalOperationIsolationProof
        this.fairnessBackpressureProof = fairnessBackpressureProof
    }
}

public class IgniteRuntimeConcurrencyDesignGate {
    public let cangjieRuntimeNativeClaimAllowed: Bool
    public let implementationPacketAllowed: Bool
    public let status: String
    public let decision: String
    public let missingProofs: Array<String>
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        cangjieRuntimeNativeClaimAllowed: Bool,
        implementationPacketAllowed: Bool,
        status: String,
        decision: String,
        missingProofs: Array<String>,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.cangjieRuntimeNativeClaimAllowed =
            cangjieRuntimeNativeClaimAllowed
        this.implementationPacketAllowed = implementationPacketAllowed
        this.status = status
        this.decision = decision
        this.missingProofs = missingProofs.clone()
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteRuntimeConcurrencyDesignGate(
    evidence: IgniteRuntimeConcurrencyDesignEvidence
): IgniteRuntimeConcurrencyDesignGate {
    let missingProofs = igniteRuntimeConcurrencyMissingProofs(evidence)
    let nonClaims = igniteRuntimeConcurrencyNonClaims()
    if (missingProofs.size > 0) {
        return IgniteRuntimeConcurrencyDesignGate(
            false,
            false,
            "blocked-runtime-native-claim-gap",
            "collect-request-scheduler-and-blocking-isolation-proofs",
            missingProofs,
            igniteRuntimeConcurrencyBlockers(missingProofs),
            nonClaims,
            "open the next bounded proof for request scheduler, long/short lane, blocking isolation, or fairness/backpressure before implementation",
            "QUIC should reuse this gate before claiming stream scheduler or runtime-native concurrency"
        )
    }
    IgniteRuntimeConcurrencyDesignGate(
        true,
        true,
        "ready-for-runtime-concurrency-implementation-packet",
        "open-bounded-runtime-scheduler-implementation-packet",
        [],
        [],
        nonClaims,
        "open one implementation packet; do not claim production performance until benchmark and runtime proof land",
        "QUIC can reuse request/stream isolation, backpressure, and blocking containment vocabulary"
    )
}

func igniteRuntimeConcurrencyMissingProofs(
    evidence: IgniteRuntimeConcurrencyDesignEvidence
): Array<String> {
    var missing = ArrayList<String>()
    if (!evidence.requestLevelSchedulerProof) {
        missing.add("REQUEST_LEVEL_SCHEDULER_PROOF")
    }
    if (!evidence.handlerIoDecouplingProof) {
        missing.add("HANDLER_IO_DECOUPLING_PROOF")
    }
    if (!evidence.longShortTaskLaneProof) {
        missing.add("LONG_SHORT_TASK_LANE_PROOF")
    }
    if (!evidence.blockingExternalOperationIsolationProof) {
        missing.add("BLOCKING_EXTERNAL_OPERATION_ISOLATION_PROOF")
    }
    if (!evidence.fairnessBackpressureProof) {
        missing.add("FAIRNESS_BACKPRESSURE_PROOF")
    }
    missing.toArray()
}

func igniteRuntimeConcurrencyBlockers(
    missingProofs: Array<String>
): Array<String> {
    var blockers = ArrayList<String>()
    for (missing in missingProofs) {
        blockers.add("MISSING:${missing}")
    }
    blockers.toArray()
}

func igniteRuntimeConcurrencyNonClaims(): Array<String> {
    [
        "NO_RUNTIME_NATIVE_CLAIM_WITHOUT_SCHEDULER_PROOF",
        "NO_BLOCKING_FFI_ISOLATION_CLAIM_WITHOUT_PROOF",
        "NO_FAIRNESS_OR_BACKPRESSURE_CLAIM_WITHOUT_PROOF",
        "NO_PERFORMANCE_CLAIM_WITHOUT_BENCHMARK",
    ]
}

public class IgniteRequestSchedulerProofEvidence {
    public let schedulerScope: String
    public let requestIdentityCarried: Bool
    public let handlerTaskBoundaryProof: Bool
    public let ioTaskBoundarySeparated: Bool
    public let connectionLevelOnlyFallbackBlocked: Bool

    public init(
        schedulerScope: String,
        requestIdentityCarried: Bool,
        handlerTaskBoundaryProof: Bool,
        ioTaskBoundarySeparated: Bool,
        connectionLevelOnlyFallbackBlocked: Bool
    ) {
        this.schedulerScope = schedulerScope
        this.requestIdentityCarried = requestIdentityCarried
        this.handlerTaskBoundaryProof = handlerTaskBoundaryProof
        this.ioTaskBoundarySeparated = ioTaskBoundarySeparated
        this.connectionLevelOnlyFallbackBlocked =
            connectionLevelOnlyFallbackBlocked
    }
}

public class IgniteRequestSchedulerProofReceipt {
    public let requestLevelSchedulerProofAccepted: Bool
    public let handlerIoDecouplingProofAccepted: Bool
    public let runtimeNativeClaimAllowed: Bool
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDesignGate: IgniteRuntimeConcurrencyDesignGate
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        requestLevelSchedulerProofAccepted: Bool,
        handlerIoDecouplingProofAccepted: Bool,
        runtimeNativeClaimAllowed: Bool,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDesignGate: IgniteRuntimeConcurrencyDesignGate,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.requestLevelSchedulerProofAccepted =
            requestLevelSchedulerProofAccepted
        this.handlerIoDecouplingProofAccepted =
            handlerIoDecouplingProofAccepted
        this.runtimeNativeClaimAllowed = runtimeNativeClaimAllowed
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDesignGate = runtimeDesignGate
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteRequestSchedulerProofReceipt(
    evidence: IgniteRequestSchedulerProofEvidence
): IgniteRequestSchedulerProofReceipt {
    let blockers = igniteRequestSchedulerProofBlockers(evidence)
    let accepted = blockers.size == 0
    let runtimeDesignEvidence = IgniteRuntimeConcurrencyDesignEvidence(
        accepted,
        accepted,
        false,
        false,
        false
    )
    let runtimeDesignGate =
        buildIgniteRuntimeConcurrencyDesignGate(runtimeDesignEvidence)
    let nonClaims = igniteRequestSchedulerProofNonClaims()
    if (!accepted) {
        return IgniteRequestSchedulerProofReceipt(
            false,
            false,
            false,
            "blocked-request-scheduler-proof-gap",
            "collect-request-identity-and-handler-io-boundary-proof",
            blockers,
            runtimeDesignGate,
            nonClaims,
            "reopen a bounded request scheduler proof packet with request identity, handler task boundary, I/O separation, and connection-level fallback blocking evidence",
            "QUIC must not claim stream scheduler readiness from connection-level-only evidence"
        )
    }
    IgniteRequestSchedulerProofReceipt(
        true,
        true,
        runtimeDesignGate.cangjieRuntimeNativeClaimAllowed,
        "accepted-request-scheduler-proof",
        "carry-request-scheduler-proof-into-runtime-design-gate",
        [],
        runtimeDesignGate,
        nonClaims,
        "next proof must cover long/short task lanes, blocking external operation isolation, or fairness/backpressure before runtime-native claim",
        "QUIC can reuse request/stream identity plus handler/I-O boundary proof before stream scheduler claims"
    )
}

func igniteRequestSchedulerProofBlockers(
    evidence: IgniteRequestSchedulerProofEvidence
): Array<String> {
    var blockers = ArrayList<String>()
    if (evidence.schedulerScope != "request-level") {
        blockers.add("SCOPE_NOT_REQUEST_LEVEL")
    }
    if (!evidence.requestIdentityCarried) {
        blockers.add("REQUEST_IDENTITY_NOT_CARRIED")
    }
    if (!evidence.handlerTaskBoundaryProof) {
        blockers.add("HANDLER_TASK_BOUNDARY_MISSING")
    }
    if (!evidence.ioTaskBoundarySeparated) {
        blockers.add("IO_TASK_BOUNDARY_NOT_SEPARATED")
    }
    if (!evidence.connectionLevelOnlyFallbackBlocked) {
        blockers.add("CONNECTION_LEVEL_ONLY_FALLBACK_NOT_BLOCKED")
    }
    blockers.toArray()
}

func igniteRequestSchedulerProofNonClaims(): Array<String> {
    [
        "NO_SCHEDULER_IMPLEMENTATION",
        "NO_LONG_SHORT_TASK_LANE_PROOF",
        "NO_BLOCKING_ISOLATION_PROOF",
        "NO_FAIRNESS_BACKPRESSURE_PROOF",
        "NO_RUNTIME_NATIVE_CLAIM",
    ]
}

public class IgniteBlockingExternalOperationIsolationEvidence {
    public let requestSchedulerReceipt: IgniteRequestSchedulerProofReceipt
    public let blockingOperationInventoryCarried: Bool
    public let nativeFfiFileDatabaseRiskClassified: Bool
    public let isolatedExecutionLane: String
    public let schedulerProtectionBoundaryProof: Bool
    public let cancellationTimeoutGuard: Bool
    public let backpressureHandoffProof: Bool

    public init(
        requestSchedulerReceipt: IgniteRequestSchedulerProofReceipt,
        blockingOperationInventoryCarried: Bool,
        nativeFfiFileDatabaseRiskClassified: Bool,
        isolatedExecutionLane: String,
        schedulerProtectionBoundaryProof: Bool,
        cancellationTimeoutGuard: Bool,
        backpressureHandoffProof: Bool
    ) {
        this.requestSchedulerReceipt = requestSchedulerReceipt
        this.blockingOperationInventoryCarried =
            blockingOperationInventoryCarried
        this.nativeFfiFileDatabaseRiskClassified =
            nativeFfiFileDatabaseRiskClassified
        this.isolatedExecutionLane = isolatedExecutionLane
        this.schedulerProtectionBoundaryProof =
            schedulerProtectionBoundaryProof
        this.cancellationTimeoutGuard = cancellationTimeoutGuard
        this.backpressureHandoffProof = backpressureHandoffProof
    }
}

public class IgniteBlockingExternalOperationIsolationProofReceipt {
    public let blockingExternalOperationIsolationProofAccepted: Bool
    public let runtimeNativeClaimAllowed: Bool
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDesignGate: IgniteRuntimeConcurrencyDesignGate
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        blockingExternalOperationIsolationProofAccepted: Bool,
        runtimeNativeClaimAllowed: Bool,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDesignGate: IgniteRuntimeConcurrencyDesignGate,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.blockingExternalOperationIsolationProofAccepted =
            blockingExternalOperationIsolationProofAccepted
        this.runtimeNativeClaimAllowed = runtimeNativeClaimAllowed
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDesignGate = runtimeDesignGate
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteBlockingExternalOperationIsolationProofReceipt(
    evidence: IgniteBlockingExternalOperationIsolationEvidence
): IgniteBlockingExternalOperationIsolationProofReceipt {
    let blockers = igniteBlockingExternalOperationIsolationBlockers(evidence)
    let accepted = blockers.size == 0
    let runtimeDesignEvidence = IgniteRuntimeConcurrencyDesignEvidence(
        evidence.requestSchedulerReceipt.requestLevelSchedulerProofAccepted,
        evidence.requestSchedulerReceipt.handlerIoDecouplingProofAccepted,
        false,
        accepted,
        false
    )
    let runtimeDesignGate =
        buildIgniteRuntimeConcurrencyDesignGate(runtimeDesignEvidence)
    let nonClaims = igniteBlockingExternalOperationIsolationNonClaims()
    if (!accepted) {
        return IgniteBlockingExternalOperationIsolationProofReceipt(
            false,
            false,
            "blocked-blocking-external-operation-isolation-proof-gap",
            "collect-blocking-operation-inventory-risk-lane-and-guard-proof",
            blockers,
            runtimeDesignGate,
            nonClaims,
            "reopen a bounded blocking isolation proof packet with inventory, risk classification, isolated lane, scheduler protection, cancellation/timeout, and backpressure handoff evidence",
            "QUIC must not claim stream runtime isolation until blocking/native operation risk is isolated from stream scheduler lanes"
        )
    }
    IgniteBlockingExternalOperationIsolationProofReceipt(
        true,
        runtimeDesignGate.cangjieRuntimeNativeClaimAllowed,
        "accepted-blocking-external-operation-isolation-proof",
        "carry-blocking-isolation-proof-into-runtime-design-gate",
        [],
        runtimeDesignGate,
        nonClaims,
        "next proof must cover long/short task lanes or fairness/backpressure before runtime-native claim",
        "QUIC can reuse blocking/native operation isolation before stream scheduler implementation claims"
    )
}

func igniteBlockingExternalOperationIsolationBlockers(
    evidence: IgniteBlockingExternalOperationIsolationEvidence
): Array<String> {
    var blockers = ArrayList<String>()
    if (!evidence.requestSchedulerReceipt.requestLevelSchedulerProofAccepted) {
        blockers.add("REQUEST_SCHEDULER_PROOF_NOT_ACCEPTED")
    }
    if (!evidence.requestSchedulerReceipt.handlerIoDecouplingProofAccepted) {
        blockers.add("HANDLER_IO_DECOUPLING_PROOF_NOT_ACCEPTED")
    }
    if (!evidence.blockingOperationInventoryCarried) {
        blockers.add("BLOCKING_OPERATION_INVENTORY_MISSING")
    }
    if (!evidence.nativeFfiFileDatabaseRiskClassified) {
        blockers.add("BLOCKING_RISK_CLASSIFICATION_MISSING")
    }
    if (evidence.isolatedExecutionLane != "blocking-isolation-lane") {
        blockers.add("ISOLATED_EXECUTION_LANE_MISSING")
    }
    if (!evidence.schedulerProtectionBoundaryProof) {
        blockers.add("SCHEDULER_PROTECTION_BOUNDARY_MISSING")
    }
    if (!evidence.cancellationTimeoutGuard) {
        blockers.add("CANCELLATION_TIMEOUT_GUARD_MISSING")
    }
    if (!evidence.backpressureHandoffProof) {
        blockers.add("BACKPRESSURE_HANDOFF_PROOF_MISSING")
    }
    blockers.toArray()
}

func igniteBlockingExternalOperationIsolationNonClaims(): Array<String> {
    [
        "NO_RUNTIME_SCHEDULER_IMPLEMENTATION",
        "NO_BLOCKING_OPERATION_RUNTIME_IMPLEMENTATION",
        "NO_LONG_SHORT_TASK_LANE_PROOF",
        "NO_FAIRNESS_BACKPRESSURE_PROOF",
        "NO_PERFORMANCE_CLAIM",
    ]
}

public class IgniteLongShortTaskLaneProofEvidence {
    public let requestSchedulerReceipt: IgniteRequestSchedulerProofReceipt
    public let blockingIsolationReceipt: IgniteBlockingExternalOperationIsolationProofReceipt
    public let shortTaskLaneIdentified: Bool
    public let longTaskLaneIdentified: Bool
    public let laneHandoffPolicyCarried: Bool
    public let starvationGuardProof: Bool
    public let cancellationTimeoutPropagationProof: Bool
    public let observabilityHookProof: Bool

    public init(
        requestSchedulerReceipt: IgniteRequestSchedulerProofReceipt,
        blockingIsolationReceipt: IgniteBlockingExternalOperationIsolationProofReceipt,
        shortTaskLaneIdentified: Bool,
        longTaskLaneIdentified: Bool,
        laneHandoffPolicyCarried: Bool,
        starvationGuardProof: Bool,
        cancellationTimeoutPropagationProof: Bool,
        observabilityHookProof: Bool
    ) {
        this.requestSchedulerReceipt = requestSchedulerReceipt
        this.blockingIsolationReceipt = blockingIsolationReceipt
        this.shortTaskLaneIdentified = shortTaskLaneIdentified
        this.longTaskLaneIdentified = longTaskLaneIdentified
        this.laneHandoffPolicyCarried = laneHandoffPolicyCarried
        this.starvationGuardProof = starvationGuardProof
        this.cancellationTimeoutPropagationProof =
            cancellationTimeoutPropagationProof
        this.observabilityHookProof = observabilityHookProof
    }
}

public class IgniteLongShortTaskLaneProofReceipt {
    public let longShortTaskLaneProofAccepted: Bool
    public let runtimeNativeClaimAllowed: Bool
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDesignGate: IgniteRuntimeConcurrencyDesignGate
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        longShortTaskLaneProofAccepted: Bool,
        runtimeNativeClaimAllowed: Bool,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDesignGate: IgniteRuntimeConcurrencyDesignGate,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.longShortTaskLaneProofAccepted =
            longShortTaskLaneProofAccepted
        this.runtimeNativeClaimAllowed = runtimeNativeClaimAllowed
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDesignGate = runtimeDesignGate
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteLongShortTaskLaneProofReceipt(
    evidence: IgniteLongShortTaskLaneProofEvidence
): IgniteLongShortTaskLaneProofReceipt {
    let blockers = igniteLongShortTaskLaneProofBlockers(evidence)
    let accepted = blockers.size == 0
    let runtimeDesignEvidence = IgniteRuntimeConcurrencyDesignEvidence(
        evidence.requestSchedulerReceipt.requestLevelSchedulerProofAccepted,
        evidence.requestSchedulerReceipt.handlerIoDecouplingProofAccepted,
        accepted,
        evidence.blockingIsolationReceipt.blockingExternalOperationIsolationProofAccepted,
        false
    )
    let runtimeDesignGate =
        buildIgniteRuntimeConcurrencyDesignGate(runtimeDesignEvidence)
    let nonClaims = igniteLongShortTaskLaneProofNonClaims()
    if (!accepted) {
        return IgniteLongShortTaskLaneProofReceipt(
            false,
            false,
            "blocked-long-short-task-lane-proof-gap",
            "collect-short-long-lane-handoff-starvation-and-observability-proof",
            blockers,
            runtimeDesignGate,
            nonClaims,
            "reopen a bounded long/short task lane proof packet with short lane, long lane, handoff, starvation guard, cancellation/timeout propagation, and observability evidence",
            "QUIC must not claim stream lane scheduling until short/long stream work separation is proven"
        )
    }
    IgniteLongShortTaskLaneProofReceipt(
        true,
        runtimeDesignGate.cangjieRuntimeNativeClaimAllowed,
        "accepted-long-short-task-lane-proof",
        "carry-long-short-task-lane-proof-into-runtime-design-gate",
        [],
        runtimeDesignGate,
        nonClaims,
        "next proof must cover fairness/backpressure before runtime-native claim",
        "QUIC can reuse short/long stream lane separation before scheduler implementation claims"
    )
}

func igniteLongShortTaskLaneProofBlockers(
    evidence: IgniteLongShortTaskLaneProofEvidence
): Array<String> {
    var blockers = ArrayList<String>()
    if (!evidence.requestSchedulerReceipt.requestLevelSchedulerProofAccepted) {
        blockers.add("REQUEST_SCHEDULER_PROOF_NOT_ACCEPTED")
    }
    if (!evidence.requestSchedulerReceipt.handlerIoDecouplingProofAccepted) {
        blockers.add("HANDLER_IO_DECOUPLING_PROOF_NOT_ACCEPTED")
    }
    if (!evidence.blockingIsolationReceipt.blockingExternalOperationIsolationProofAccepted) {
        blockers.add("BLOCKING_ISOLATION_PROOF_NOT_ACCEPTED")
    }
    if (!evidence.shortTaskLaneIdentified) {
        blockers.add("SHORT_TASK_LANE_NOT_IDENTIFIED")
    }
    if (!evidence.longTaskLaneIdentified) {
        blockers.add("LONG_TASK_LANE_NOT_IDENTIFIED")
    }
    if (!evidence.laneHandoffPolicyCarried) {
        blockers.add("LANE_HANDOFF_POLICY_MISSING")
    }
    if (!evidence.starvationGuardProof) {
        blockers.add("STARVATION_GUARD_PROOF_MISSING")
    }
    if (!evidence.cancellationTimeoutPropagationProof) {
        blockers.add("CANCELLATION_TIMEOUT_PROPAGATION_MISSING")
    }
    if (!evidence.observabilityHookProof) {
        blockers.add("OBSERVABILITY_HOOK_PROOF_MISSING")
    }
    blockers.toArray()
}

func igniteLongShortTaskLaneProofNonClaims(): Array<String> {
    [
        "NO_RUNTIME_SCHEDULER_IMPLEMENTATION",
        "NO_TASK_LANE_RUNTIME_IMPLEMENTATION",
        "NO_FAIRNESS_BACKPRESSURE_PROOF",
        "NO_PERFORMANCE_CLAIM",
        "NO_RUNTIME_NATIVE_CLAIM",
    ]
}

public class IgniteFairnessBackpressureProofEvidence {
    public let requestSchedulerReceipt: IgniteRequestSchedulerProofReceipt
    public let blockingIsolationReceipt: IgniteBlockingExternalOperationIsolationProofReceipt
    public let longShortTaskLaneReceipt: IgniteLongShortTaskLaneProofReceipt
    public let boundedQueuePolicyCarried: Bool
    public let fairnessRotationProof: Bool
    public let pressureSignalPropagationProof: Bool
    public let overloadRejectionOrDeferralPolicy: Bool
    public let perLaneAccountingProof: Bool
    public let observabilityHookProof: Bool

    public init(
        requestSchedulerReceipt: IgniteRequestSchedulerProofReceipt,
        blockingIsolationReceipt: IgniteBlockingExternalOperationIsolationProofReceipt,
        longShortTaskLaneReceipt: IgniteLongShortTaskLaneProofReceipt,
        boundedQueuePolicyCarried: Bool,
        fairnessRotationProof: Bool,
        pressureSignalPropagationProof: Bool,
        overloadRejectionOrDeferralPolicy: Bool,
        perLaneAccountingProof: Bool,
        observabilityHookProof: Bool
    ) {
        this.requestSchedulerReceipt = requestSchedulerReceipt
        this.blockingIsolationReceipt = blockingIsolationReceipt
        this.longShortTaskLaneReceipt = longShortTaskLaneReceipt
        this.boundedQueuePolicyCarried = boundedQueuePolicyCarried
        this.fairnessRotationProof = fairnessRotationProof
        this.pressureSignalPropagationProof =
            pressureSignalPropagationProof
        this.overloadRejectionOrDeferralPolicy =
            overloadRejectionOrDeferralPolicy
        this.perLaneAccountingProof = perLaneAccountingProof
        this.observabilityHookProof = observabilityHookProof
    }
}

public class IgniteFairnessBackpressureProofReceipt {
    public let fairnessBackpressureProofAccepted: Bool
    public let runtimeNativeClaimAllowed: Bool
    public let implementationPacketAllowed: Bool
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDesignGate: IgniteRuntimeConcurrencyDesignGate
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        fairnessBackpressureProofAccepted: Bool,
        runtimeNativeClaimAllowed: Bool,
        implementationPacketAllowed: Bool,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDesignGate: IgniteRuntimeConcurrencyDesignGate,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.fairnessBackpressureProofAccepted =
            fairnessBackpressureProofAccepted
        this.runtimeNativeClaimAllowed = runtimeNativeClaimAllowed
        this.implementationPacketAllowed = implementationPacketAllowed
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeDesignGate = runtimeDesignGate
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteFairnessBackpressureProofReceipt(
    evidence: IgniteFairnessBackpressureProofEvidence
): IgniteFairnessBackpressureProofReceipt {
    let blockers = igniteFairnessBackpressureProofBlockers(evidence)
    let accepted = blockers.size == 0
    let runtimeDesignEvidence = IgniteRuntimeConcurrencyDesignEvidence(
        evidence.requestSchedulerReceipt.requestLevelSchedulerProofAccepted,
        evidence.requestSchedulerReceipt.handlerIoDecouplingProofAccepted,
        evidence.longShortTaskLaneReceipt.longShortTaskLaneProofAccepted,
        evidence.blockingIsolationReceipt.blockingExternalOperationIsolationProofAccepted,
        accepted
    )
    let runtimeDesignGate =
        buildIgniteRuntimeConcurrencyDesignGate(runtimeDesignEvidence)
    let nonClaims = igniteFairnessBackpressureProofNonClaims()
    if (!accepted) {
        return IgniteFairnessBackpressureProofReceipt(
            false,
            false,
            false,
            "blocked-fairness-backpressure-proof-gap",
            "collect-bounded-queue-fairness-pressure-overload-accounting-proof",
            blockers,
            runtimeDesignGate,
            nonClaims,
            "reopen a bounded fairness/backpressure proof packet with bounded queue, rotation, pressure signal, overload policy, accounting, and observability evidence",
            "QUIC must not claim stream scheduler readiness until stream pressure and fairness rules are proven"
        )
    }
    IgniteFairnessBackpressureProofReceipt(
        true,
        runtimeDesignGate.cangjieRuntimeNativeClaimAllowed,
        runtimeDesignGate.implementationPacketAllowed,
        "accepted-fairness-backpressure-proof",
        "open-bounded-runtime-scheduler-implementation-packet",
        [],
        runtimeDesignGate,
        nonClaims,
        "open one runtime scheduler implementation packet; keep performance, release, and H2/QUIC closure claims separate",
        "QUIC can reuse bounded queues, pressure signals, fairness rotation, and overload policy before stream scheduler implementation"
    )
}

func igniteFairnessBackpressureProofBlockers(
    evidence: IgniteFairnessBackpressureProofEvidence
): Array<String> {
    var blockers = ArrayList<String>()
    if (!evidence.requestSchedulerReceipt.requestLevelSchedulerProofAccepted) {
        blockers.add("REQUEST_SCHEDULER_PROOF_NOT_ACCEPTED")
    }
    if (!evidence.requestSchedulerReceipt.handlerIoDecouplingProofAccepted) {
        blockers.add("HANDLER_IO_DECOUPLING_PROOF_NOT_ACCEPTED")
    }
    if (!evidence.blockingIsolationReceipt.blockingExternalOperationIsolationProofAccepted) {
        blockers.add("BLOCKING_ISOLATION_PROOF_NOT_ACCEPTED")
    }
    if (!evidence.longShortTaskLaneReceipt.longShortTaskLaneProofAccepted) {
        blockers.add("LONG_SHORT_TASK_LANE_PROOF_NOT_ACCEPTED")
    }
    if (!evidence.boundedQueuePolicyCarried) {
        blockers.add("BOUNDED_QUEUE_POLICY_MISSING")
    }
    if (!evidence.fairnessRotationProof) {
        blockers.add("FAIRNESS_ROTATION_PROOF_MISSING")
    }
    if (!evidence.pressureSignalPropagationProof) {
        blockers.add("PRESSURE_SIGNAL_PROPAGATION_MISSING")
    }
    if (!evidence.overloadRejectionOrDeferralPolicy) {
        blockers.add("OVERLOAD_REJECTION_OR_DEFERRAL_POLICY_MISSING")
    }
    if (!evidence.perLaneAccountingProof) {
        blockers.add("PER_LANE_ACCOUNTING_PROOF_MISSING")
    }
    if (!evidence.observabilityHookProof) {
        blockers.add("OBSERVABILITY_HOOK_PROOF_MISSING")
    }
    blockers.toArray()
}

func igniteFairnessBackpressureProofNonClaims(): Array<String> {
    [
        "NO_RUNTIME_SCHEDULER_IMPLEMENTATION",
        "NO_FAIRNESS_BACKPRESSURE_RUNTIME_IMPLEMENTATION",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_CLAIM",
        "NO_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
    ]
}

public class IgniteRuntimeSchedulerShellWorkItem {
    public let requestIdentityCarried: Bool
    public let workKind: String
    public let cancellationTimeoutCarried: Bool
    public let observabilityContextCarried: Bool

    public init(
        requestIdentityCarried: Bool,
        workKind: String,
        cancellationTimeoutCarried: Bool,
        observabilityContextCarried: Bool
    ) {
        this.requestIdentityCarried = requestIdentityCarried
        this.workKind = workKind
        this.cancellationTimeoutCarried = cancellationTimeoutCarried
        this.observabilityContextCarried = observabilityContextCarried
    }
}

public class IgniteRuntimeSchedulerShellLaneState {
    public let queued: Int64
    public let capacity: Int64
    public let overloadPolicy: String

    public init(
        queued: Int64,
        capacity: Int64,
        overloadPolicy: String
    ) {
        this.queued = queued
        this.capacity = capacity
        this.overloadPolicy = overloadPolicy
    }
}

public class IgniteRuntimeSchedulerShellDecision {
    public let schedulerShellAccepted: Bool
    public let implementationPacketAllowed: Bool
    public let selectedLane: String
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let queueAfter: Int64
    public let pressureSignal: String
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        schedulerShellAccepted: Bool,
        implementationPacketAllowed: Bool,
        selectedLane: String,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        queueAfter: Int64,
        pressureSignal: String,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.schedulerShellAccepted = schedulerShellAccepted
        this.implementationPacketAllowed = implementationPacketAllowed
        this.selectedLane = selectedLane
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.queueAfter = queueAfter
        this.pressureSignal = pressureSignal
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteRuntimeSchedulerShellDecision(
    proofReceipt: IgniteFairnessBackpressureProofReceipt,
    workItem: IgniteRuntimeSchedulerShellWorkItem,
    laneState: IgniteRuntimeSchedulerShellLaneState
): IgniteRuntimeSchedulerShellDecision {
    let nonClaims = igniteRuntimeSchedulerShellNonClaims()
    if (!proofReceipt.implementationPacketAllowed) {
        return IgniteRuntimeSchedulerShellDecision(
            false,
            false,
            "none",
            "block",
            "blocked-runtime-concurrency-proof-gate",
            "collect-accepted-runtime-concurrency-proof-receipts-first",
            ["FAIRNESS_BACKPRESSURE_PROOF_NOT_ACCEPTED"],
            laneState.queued,
            "not-evaluated",
            nonClaims,
            "reopen proof receipt chain before runtime scheduler shell work",
            "QUIC must not consume scheduler shell without accepted runtime concurrency proof receipts"
        )
    }

    let selectedLane = igniteRuntimeSchedulerShellLaneFor(workItem.workKind)
    let blockers = igniteRuntimeSchedulerShellBlockers(
        workItem,
        laneState,
        selectedLane
    )
    if (blockers.size > 0) {
        return IgniteRuntimeSchedulerShellDecision(
            false,
            proofReceipt.implementationPacketAllowed,
            selectedLane,
            "block",
            "blocked-runtime-scheduler-shell-input",
            "fix-work-item-lane-state-before-enqueue",
            blockers,
            laneState.queued,
            "invalid-input",
            nonClaims,
            "provide request identity, known work kind, cancellation/timeout, observability, and valid bounded lane state",
            "QUIC can reuse the same invalid-input blockers for stream scheduler shell work"
        )
    }

    if (laneState.queued >= laneState.capacity) {
        let action = igniteRuntimeSchedulerShellOverloadAction(
            laneState.overloadPolicy
        )
        return IgniteRuntimeSchedulerShellDecision(
            false,
            proofReceipt.implementationPacketAllowed,
            selectedLane,
            action,
            "pressured-runtime-scheduler-shell-lane",
            "apply-overload-policy-before-enqueue",
            [],
            laneState.queued,
            "lane-full",
            nonClaims,
            "defer or reject according to overload policy; do not enqueue beyond bounded capacity",
            "QUIC can reuse lane-full pressure decisions for stream scheduling"
        )
    }

    IgniteRuntimeSchedulerShellDecision(
        true,
        proofReceipt.implementationPacketAllowed,
        selectedLane,
        "enqueue",
        "accepted-runtime-scheduler-shell-decision",
        "enqueue-work-item-into-selected-lane",
        [],
        laneState.queued + 1,
        "within-capacity",
        nonClaims,
        "next packet may wire this shell into an internal executor boundary",
        "QUIC can reuse work kind to stream lane mapping before live execution"
    )
}

func igniteRuntimeSchedulerShellLaneFor(workKind: String): String {
    if (workKind == "short-handler") {
        return "short-task-lane"
    }
    if (workKind == "long-handler") {
        return "long-task-lane"
    }
    if (workKind == "blocking-external-operation") {
        return "blocking-isolation-lane"
    }
    "unknown-lane"
}

func igniteRuntimeSchedulerShellBlockers(
    workItem: IgniteRuntimeSchedulerShellWorkItem,
    laneState: IgniteRuntimeSchedulerShellLaneState,
    selectedLane: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (!workItem.requestIdentityCarried) {
        blockers.add("REQUEST_IDENTITY_NOT_CARRIED")
    }
    if (selectedLane == "unknown-lane") {
        blockers.add("UNKNOWN_WORK_KIND")
    }
    if (!workItem.cancellationTimeoutCarried) {
        blockers.add("CANCELLATION_TIMEOUT_NOT_CARRIED")
    }
    if (!workItem.observabilityContextCarried) {
        blockers.add("OBSERVABILITY_CONTEXT_NOT_CARRIED")
    }
    if (laneState.capacity <= 0) {
        blockers.add("LANE_CAPACITY_INVALID")
    }
    if (laneState.queued < 0) {
        blockers.add("LANE_QUEUED_INVALID")
    }
    if (
        laneState.overloadPolicy != "defer" &&
        laneState.overloadPolicy != "reject"
    ) {
        blockers.add("OVERLOAD_POLICY_INVALID")
    }
    blockers.toArray()
}

func igniteRuntimeSchedulerShellOverloadAction(
    overloadPolicy: String
): String {
    if (overloadPolicy == "reject") {
        return "reject"
    }
    "defer"
}

func igniteRuntimeSchedulerShellNonClaims(): Array<String> {
    [
        "NO_LIVE_SERVER_WIRING",
        "NO_RUNTIME_TASK_SPAWN",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
        "NO_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
    ]
}

public class IgniteRuntimeExecutorBoundaryRequest {
    public let executorBoundaryId: String
    public let requestExecutionEnvelopeCarried: Bool
    public let laneOwnershipCarried: Bool
    public let workerIsolationCarried: Bool
    public let runtimeTaskSpawnRequested: Bool
    public let liveServerWiringRequested: Bool

    public init(
        executorBoundaryId: String,
        requestExecutionEnvelopeCarried: Bool,
        laneOwnershipCarried: Bool,
        workerIsolationCarried: Bool,
        runtimeTaskSpawnRequested: Bool,
        liveServerWiringRequested: Bool
    ) {
        this.executorBoundaryId = executorBoundaryId
        this.requestExecutionEnvelopeCarried = requestExecutionEnvelopeCarried
        this.laneOwnershipCarried = laneOwnershipCarried
        this.workerIsolationCarried = workerIsolationCarried
        this.runtimeTaskSpawnRequested = runtimeTaskSpawnRequested
        this.liveServerWiringRequested = liveServerWiringRequested
    }
}

public class IgniteRuntimeExecutorBoundaryPlan {
    public let boundaryPlanAccepted: Bool
    public let schedulerShellAccepted: Bool
    public let selectedLane: String
    public let executorBoundaryId: String
    public let executionMode: String
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeTaskSpawnAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        boundaryPlanAccepted: Bool,
        schedulerShellAccepted: Bool,
        selectedLane: String,
        executorBoundaryId: String,
        executionMode: String,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeTaskSpawnAllowed: Bool,
        liveServerWiringAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.boundaryPlanAccepted = boundaryPlanAccepted
        this.schedulerShellAccepted = schedulerShellAccepted
        this.selectedLane = selectedLane
        this.executorBoundaryId = executorBoundaryId
        this.executionMode = executionMode
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeTaskSpawnAllowed = runtimeTaskSpawnAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteRuntimeExecutorBoundaryPlan(
    schedulerDecision: IgniteRuntimeSchedulerShellDecision,
    request: IgniteRuntimeExecutorBoundaryRequest
): IgniteRuntimeExecutorBoundaryPlan {
    let nonClaims = igniteRuntimeExecutorBoundaryNonClaims()
    if (!schedulerDecision.schedulerShellAccepted) {
        return IgniteRuntimeExecutorBoundaryPlan(
            false,
            schedulerDecision.schedulerShellAccepted,
            schedulerDecision.selectedLane,
            request.executorBoundaryId,
            "none",
            "block",
            "blocked-runtime-scheduler-shell-decision",
            "collect-accepted-scheduler-shell-decision-first",
            ["SCHEDULER_SHELL_DECISION_NOT_ACCEPTED"],
            false,
            false,
            nonClaims,
            "return to HQ-0449 scheduler shell input before executor boundary planning",
            "QUIC must not consume executor boundary plans from rejected scheduler decisions"
        )
    }

    let executionMode =
        igniteRuntimeExecutorBoundaryModeFor(schedulerDecision.selectedLane)
    let blockers = igniteRuntimeExecutorBoundaryBlockers(
        request,
        executionMode
    )
    if (blockers.size > 0) {
        return IgniteRuntimeExecutorBoundaryPlan(
            false,
            schedulerDecision.schedulerShellAccepted,
            schedulerDecision.selectedLane,
            request.executorBoundaryId,
            executionMode,
            "block",
            "blocked-runtime-executor-boundary-input",
            "fix-executor-boundary-envelope-before-runtime-wiring",
            blockers,
            false,
            false,
            nonClaims,
            "carry boundary id, request envelope, lane ownership, worker isolation, and keep live/spawn requests out",
            "QUIC can reuse the same executor-boundary blockers before stream executor wiring"
        )
    }

    IgniteRuntimeExecutorBoundaryPlan(
        true,
        schedulerDecision.schedulerShellAccepted,
        schedulerDecision.selectedLane,
        request.executorBoundaryId,
        executionMode,
        "record-boundary-plan",
        "accepted-runtime-executor-boundary-plan",
        "wire-scheduler-decision-into-internal-executor-boundary-plan",
        [],
        false,
        false,
        nonClaims,
        "next packet may attach this boundary plan to a controlled internal executor seam",
        "QUIC can reuse lane-specific executor boundary modes before live stream execution"
    )
}

func igniteRuntimeExecutorBoundaryModeFor(selectedLane: String): String {
    if (selectedLane == "short-task-lane") {
        return "short-handler-executor-boundary"
    }
    if (selectedLane == "long-task-lane") {
        return "long-handler-executor-boundary"
    }
    if (selectedLane == "blocking-isolation-lane") {
        return "blocking-isolation-executor-boundary"
    }
    "unknown-executor-boundary"
}

func igniteRuntimeExecutorBoundaryBlockers(
    request: IgniteRuntimeExecutorBoundaryRequest,
    executionMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.executorBoundaryId.size == 0) {
        blockers.add("EXECUTOR_BOUNDARY_ID_NOT_CARRIED")
    }
    if (!request.requestExecutionEnvelopeCarried) {
        blockers.add("REQUEST_EXECUTION_ENVELOPE_NOT_CARRIED")
    }
    if (!request.laneOwnershipCarried) {
        blockers.add("LANE_OWNERSHIP_NOT_CARRIED")
    }
    if (!request.workerIsolationCarried) {
        blockers.add("WORKER_ISOLATION_NOT_CARRIED")
    }
    if (request.runtimeTaskSpawnRequested) {
        blockers.add("RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.liveServerWiringRequested) {
        blockers.add("LIVE_SERVER_WIRING_REQUESTED")
    }
    if (executionMode == "unknown-executor-boundary") {
        blockers.add("UNKNOWN_EXECUTOR_BOUNDARY")
    }
    blockers.toArray()
}

func igniteRuntimeExecutorBoundaryNonClaims(): Array<String> {
    [
        "NO_LIVE_SERVER_WIRING",
        "NO_RUNTIME_TASK_SPAWN",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
        "NO_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
    ]
}

public class IgniteControlledExecutorSeamRequest {
    public let seamId: String
    public let sealedWorkEnvelopeCarried: Bool
    public let handlerAdapterCarried: Bool
    public let resultChannelCarried: Bool
    public let backpressureSignalCarried: Bool
    public let handlerInvocationRequested: Bool
    public let runtimeTaskSpawnRequested: Bool
    public let liveServerWiringRequested: Bool

    public init(
        seamId: String,
        sealedWorkEnvelopeCarried: Bool,
        handlerAdapterCarried: Bool,
        resultChannelCarried: Bool,
        backpressureSignalCarried: Bool,
        handlerInvocationRequested: Bool,
        runtimeTaskSpawnRequested: Bool,
        liveServerWiringRequested: Bool
    ) {
        this.seamId = seamId
        this.sealedWorkEnvelopeCarried = sealedWorkEnvelopeCarried
        this.handlerAdapterCarried = handlerAdapterCarried
        this.resultChannelCarried = resultChannelCarried
        this.backpressureSignalCarried = backpressureSignalCarried
        this.handlerInvocationRequested = handlerInvocationRequested
        this.runtimeTaskSpawnRequested = runtimeTaskSpawnRequested
        this.liveServerWiringRequested = liveServerWiringRequested
    }
}

public class IgniteControlledExecutorSeamReceipt {
    public let controlledSeamAccepted: Bool
    public let boundaryPlanAccepted: Bool
    public let selectedLane: String
    public let executionMode: String
    public let seamMode: String
    public let seamId: String
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let handlerInvocationAllowed: Bool
    public let runtimeTaskSpawnAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        controlledSeamAccepted: Bool,
        boundaryPlanAccepted: Bool,
        selectedLane: String,
        executionMode: String,
        seamMode: String,
        seamId: String,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        handlerInvocationAllowed: Bool,
        runtimeTaskSpawnAllowed: Bool,
        liveServerWiringAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.controlledSeamAccepted = controlledSeamAccepted
        this.boundaryPlanAccepted = boundaryPlanAccepted
        this.selectedLane = selectedLane
        this.executionMode = executionMode
        this.seamMode = seamMode
        this.seamId = seamId
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.handlerInvocationAllowed = handlerInvocationAllowed
        this.runtimeTaskSpawnAllowed = runtimeTaskSpawnAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteControlledExecutorSeamReceipt(
    boundaryPlan: IgniteRuntimeExecutorBoundaryPlan,
    request: IgniteControlledExecutorSeamRequest
): IgniteControlledExecutorSeamReceipt {
    let nonClaims = igniteControlledExecutorSeamNonClaims()
    if (!boundaryPlan.boundaryPlanAccepted) {
        return IgniteControlledExecutorSeamReceipt(
            false,
            boundaryPlan.boundaryPlanAccepted,
            boundaryPlan.selectedLane,
            boundaryPlan.executionMode,
            "none",
            request.seamId,
            "block",
            "blocked-runtime-executor-boundary-plan",
            "collect-accepted-executor-boundary-plan-first",
            ["EXECUTOR_BOUNDARY_PLAN_NOT_ACCEPTED"],
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0450 executor boundary input before controlled seam work",
            "QUIC must not consume controlled executor seams from rejected boundary plans"
        )
    }

    let seamMode = igniteControlledExecutorSeamModeFor(
        boundaryPlan.executionMode
    )
    let blockers = igniteControlledExecutorSeamBlockers(
        request,
        seamMode
    )
    if (blockers.size > 0) {
        return IgniteControlledExecutorSeamReceipt(
            false,
            boundaryPlan.boundaryPlanAccepted,
            boundaryPlan.selectedLane,
            boundaryPlan.executionMode,
            seamMode,
            request.seamId,
            "block",
            "blocked-controlled-executor-seam-input",
            "fix-controlled-seam-envelope-before-executor-attach",
            blockers,
            false,
            false,
            false,
            nonClaims,
            "carry seam id, sealed work envelope, handler adapter, result channel, backpressure signal, and keep live execution requests out",
            "QUIC can reuse the same controlled-seam blockers before stream executor attach"
        )
    }

    IgniteControlledExecutorSeamReceipt(
        true,
        boundaryPlan.boundaryPlanAccepted,
        boundaryPlan.selectedLane,
        boundaryPlan.executionMode,
        seamMode,
        request.seamId,
        "record-controlled-seam-receipt",
        "accepted-controlled-executor-seam-receipt",
        "record-controlled-executor-seam-without-runtime-execution",
        [],
        false,
        false,
        false,
        nonClaims,
        "next packet may attach a controlled internal executor adapter without widening public API",
        "QUIC can reuse lane-specific controlled seam modes before live stream execution"
    )
}

func igniteControlledExecutorSeamModeFor(executionMode: String): String {
    if (executionMode == "short-handler-executor-boundary") {
        return "short-handler-controlled-executor-seam"
    }
    if (executionMode == "long-handler-executor-boundary") {
        return "long-handler-controlled-executor-seam"
    }
    if (executionMode == "blocking-isolation-executor-boundary") {
        return "blocking-isolation-controlled-executor-seam"
    }
    "unknown-controlled-executor-seam"
}

func igniteControlledExecutorSeamBlockers(
    request: IgniteControlledExecutorSeamRequest,
    seamMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.seamId.size == 0) {
        blockers.add("CONTROLLED_SEAM_ID_NOT_CARRIED")
    }
    if (!request.sealedWorkEnvelopeCarried) {
        blockers.add("SEALED_WORK_ENVELOPE_NOT_CARRIED")
    }
    if (!request.handlerAdapterCarried) {
        blockers.add("HANDLER_ADAPTER_NOT_CARRIED")
    }
    if (!request.resultChannelCarried) {
        blockers.add("RESULT_CHANNEL_NOT_CARRIED")
    }
    if (!request.backpressureSignalCarried) {
        blockers.add("BACKPRESSURE_SIGNAL_NOT_CARRIED")
    }
    if (request.handlerInvocationRequested) {
        blockers.add("HANDLER_INVOCATION_REQUESTED")
    }
    if (request.runtimeTaskSpawnRequested) {
        blockers.add("RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.liveServerWiringRequested) {
        blockers.add("LIVE_SERVER_WIRING_REQUESTED")
    }
    if (seamMode == "unknown-controlled-executor-seam") {
        blockers.add("UNKNOWN_CONTROLLED_EXECUTOR_SEAM")
    }
    blockers.toArray()
}

func igniteControlledExecutorSeamNonClaims(): Array<String> {
    [
        "NO_LIVE_SERVER_WIRING",
        "NO_HANDLER_INVOCATION",
        "NO_RUNTIME_TASK_SPAWN",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
        "NO_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
    ]
}

public class IgniteControlledExecutorAdapterAttachRequest {
    public let adapterId: String
    public let handlerAdapterContractCarried: Bool
    public let requestContextProjectionCarried: Bool
    public let responseChannelProjectionCarried: Bool
    public let errorBoundaryCarried: Bool
    public let handlerInvocationRequested: Bool
    public let requestContextMutationRequested: Bool
    public let runtimeTaskSpawnRequested: Bool
    public let liveServerWiringRequested: Bool

    public init(
        adapterId: String,
        handlerAdapterContractCarried: Bool,
        requestContextProjectionCarried: Bool,
        responseChannelProjectionCarried: Bool,
        errorBoundaryCarried: Bool,
        handlerInvocationRequested: Bool,
        requestContextMutationRequested: Bool,
        runtimeTaskSpawnRequested: Bool,
        liveServerWiringRequested: Bool
    ) {
        this.adapterId = adapterId
        this.handlerAdapterContractCarried = handlerAdapterContractCarried
        this.requestContextProjectionCarried = requestContextProjectionCarried
        this.responseChannelProjectionCarried = responseChannelProjectionCarried
        this.errorBoundaryCarried = errorBoundaryCarried
        this.handlerInvocationRequested = handlerInvocationRequested
        this.requestContextMutationRequested = requestContextMutationRequested
        this.runtimeTaskSpawnRequested = runtimeTaskSpawnRequested
        this.liveServerWiringRequested = liveServerWiringRequested
    }
}

public class IgniteControlledExecutorAdapterAttachReceipt {
    public let adapterAttachAccepted: Bool
    public let controlledSeamAccepted: Bool
    public let seamMode: String
    public let adapterMode: String
    public let adapterId: String
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let handlerInvocationAllowed: Bool
    public let requestContextMutationAllowed: Bool
    public let runtimeTaskSpawnAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        adapterAttachAccepted: Bool,
        controlledSeamAccepted: Bool,
        seamMode: String,
        adapterMode: String,
        adapterId: String,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        handlerInvocationAllowed: Bool,
        requestContextMutationAllowed: Bool,
        runtimeTaskSpawnAllowed: Bool,
        liveServerWiringAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.adapterAttachAccepted = adapterAttachAccepted
        this.controlledSeamAccepted = controlledSeamAccepted
        this.seamMode = seamMode
        this.adapterMode = adapterMode
        this.adapterId = adapterId
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.handlerInvocationAllowed = handlerInvocationAllowed
        this.requestContextMutationAllowed = requestContextMutationAllowed
        this.runtimeTaskSpawnAllowed = runtimeTaskSpawnAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteControlledExecutorAdapterAttachReceipt(
    seamReceipt: IgniteControlledExecutorSeamReceipt,
    request: IgniteControlledExecutorAdapterAttachRequest
): IgniteControlledExecutorAdapterAttachReceipt {
    let nonClaims = igniteControlledExecutorAdapterAttachNonClaims()
    if (!seamReceipt.controlledSeamAccepted) {
        return IgniteControlledExecutorAdapterAttachReceipt(
            false,
            seamReceipt.controlledSeamAccepted,
            seamReceipt.seamMode,
            "none",
            request.adapterId,
            "block",
            "blocked-controlled-executor-seam-receipt",
            "collect-accepted-controlled-seam-receipt-first",
            ["CONTROLLED_EXECUTOR_SEAM_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0451 controlled seam input before adapter attach work",
            "QUIC must not consume adapter attach receipts from rejected controlled seams"
        )
    }

    let adapterMode = igniteControlledExecutorAdapterAttachModeFor(
        seamReceipt.seamMode
    )
    let blockers = igniteControlledExecutorAdapterAttachBlockers(
        request,
        adapterMode
    )
    if (blockers.size > 0) {
        return IgniteControlledExecutorAdapterAttachReceipt(
            false,
            seamReceipt.controlledSeamAccepted,
            seamReceipt.seamMode,
            adapterMode,
            request.adapterId,
            "block",
            "blocked-controlled-executor-adapter-attach-input",
            "fix-adapter-attach-envelope-before-handler-dry-run",
            blockers,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry adapter id, handler contract, request projection, response projection, error boundary, and keep live adapter requests out",
            "QUIC can reuse the same adapter-attach blockers before stream handler adapter dry-run"
        )
    }

    IgniteControlledExecutorAdapterAttachReceipt(
        true,
        seamReceipt.controlledSeamAccepted,
        seamReceipt.seamMode,
        adapterMode,
        request.adapterId,
        "record-adapter-attach-receipt",
        "accepted-controlled-executor-adapter-attach-receipt",
        "record-controlled-adapter-attach-without-handler-invocation",
        [],
        false,
        false,
        false,
        false,
        nonClaims,
        "next packet may dry-run the handler adapter contract without invoking user handlers",
        "QUIC can reuse lane-specific adapter attach modes before live stream handler execution"
    )
}

func igniteControlledExecutorAdapterAttachModeFor(seamMode: String): String {
    if (seamMode == "short-handler-controlled-executor-seam") {
        return "short-handler-adapter-attach"
    }
    if (seamMode == "long-handler-controlled-executor-seam") {
        return "long-handler-adapter-attach"
    }
    if (seamMode == "blocking-isolation-controlled-executor-seam") {
        return "blocking-isolation-adapter-attach"
    }
    "unknown-adapter-attach"
}

func igniteControlledExecutorAdapterAttachBlockers(
    request: IgniteControlledExecutorAdapterAttachRequest,
    adapterMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.adapterId.size == 0) {
        blockers.add("ADAPTER_ID_NOT_CARRIED")
    }
    if (!request.handlerAdapterContractCarried) {
        blockers.add("HANDLER_ADAPTER_CONTRACT_NOT_CARRIED")
    }
    if (!request.requestContextProjectionCarried) {
        blockers.add("REQUEST_CONTEXT_PROJECTION_NOT_CARRIED")
    }
    if (!request.responseChannelProjectionCarried) {
        blockers.add("RESPONSE_CHANNEL_PROJECTION_NOT_CARRIED")
    }
    if (!request.errorBoundaryCarried) {
        blockers.add("ERROR_BOUNDARY_NOT_CARRIED")
    }
    if (request.handlerInvocationRequested) {
        blockers.add("HANDLER_INVOCATION_REQUESTED")
    }
    if (request.requestContextMutationRequested) {
        blockers.add("REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.runtimeTaskSpawnRequested) {
        blockers.add("RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.liveServerWiringRequested) {
        blockers.add("LIVE_SERVER_WIRING_REQUESTED")
    }
    if (adapterMode == "unknown-adapter-attach") {
        blockers.add("UNKNOWN_ADAPTER_ATTACH")
    }
    blockers.toArray()
}

func igniteControlledExecutorAdapterAttachNonClaims(): Array<String> {
    [
        "NO_LIVE_SERVER_WIRING",
        "NO_HANDLER_INVOCATION",
        "NO_REQUEST_CONTEXT_MUTATION",
        "NO_RUNTIME_TASK_SPAWN",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
        "NO_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
    ]
}

public class IgniteHandlerAdapterDryRunRequest {
    public let dryRunId: String
    public let handlerAdapterContractSnapshotCarried: Bool
    public let requestProjectionSnapshotCarried: Bool
    public let responseExpectationMarkerCarried: Bool
    public let errorBoundaryMarkerCarried: Bool
    public let handlerInvocationRequested: Bool
    public let requestContextMutationRequested: Bool
    public let runtimeTaskSpawnRequested: Bool
    public let liveServerWiringRequested: Bool

    public init(
        dryRunId: String,
        handlerAdapterContractSnapshotCarried: Bool,
        requestProjectionSnapshotCarried: Bool,
        responseExpectationMarkerCarried: Bool,
        errorBoundaryMarkerCarried: Bool,
        handlerInvocationRequested: Bool,
        requestContextMutationRequested: Bool,
        runtimeTaskSpawnRequested: Bool,
        liveServerWiringRequested: Bool
    ) {
        this.dryRunId = dryRunId
        this.handlerAdapterContractSnapshotCarried =
            handlerAdapterContractSnapshotCarried
        this.requestProjectionSnapshotCarried = requestProjectionSnapshotCarried
        this.responseExpectationMarkerCarried = responseExpectationMarkerCarried
        this.errorBoundaryMarkerCarried = errorBoundaryMarkerCarried
        this.handlerInvocationRequested = handlerInvocationRequested
        this.requestContextMutationRequested = requestContextMutationRequested
        this.runtimeTaskSpawnRequested = runtimeTaskSpawnRequested
        this.liveServerWiringRequested = liveServerWiringRequested
    }
}

public class IgniteHandlerAdapterDryRunReceipt {
    public let handlerDryRunAccepted: Bool
    public let adapterAttachAccepted: Bool
    public let adapterMode: String
    public let dryRunMode: String
    public let dryRunId: String
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let handlerInvocationAllowed: Bool
    public let requestContextMutationAllowed: Bool
    public let runtimeTaskSpawnAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        handlerDryRunAccepted: Bool,
        adapterAttachAccepted: Bool,
        adapterMode: String,
        dryRunMode: String,
        dryRunId: String,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        handlerInvocationAllowed: Bool,
        requestContextMutationAllowed: Bool,
        runtimeTaskSpawnAllowed: Bool,
        liveServerWiringAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.handlerDryRunAccepted = handlerDryRunAccepted
        this.adapterAttachAccepted = adapterAttachAccepted
        this.adapterMode = adapterMode
        this.dryRunMode = dryRunMode
        this.dryRunId = dryRunId
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.handlerInvocationAllowed = handlerInvocationAllowed
        this.requestContextMutationAllowed = requestContextMutationAllowed
        this.runtimeTaskSpawnAllowed = runtimeTaskSpawnAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteHandlerAdapterDryRunReceipt(
    adapterAttachReceipt: IgniteControlledExecutorAdapterAttachReceipt,
    request: IgniteHandlerAdapterDryRunRequest
): IgniteHandlerAdapterDryRunReceipt {
    let nonClaims = igniteHandlerAdapterDryRunNonClaims()
    if (!adapterAttachReceipt.adapterAttachAccepted) {
        return IgniteHandlerAdapterDryRunReceipt(
            false,
            adapterAttachReceipt.adapterAttachAccepted,
            adapterAttachReceipt.adapterMode,
            "none",
            request.dryRunId,
            "block",
            "blocked-controlled-executor-adapter-attach-receipt",
            "collect-accepted-adapter-attach-receipt-first",
            ["CONTROLLED_EXECUTOR_ADAPTER_ATTACH_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0452 adapter attach input before handler dry-run work",
            "QUIC must not consume handler dry-run receipts from rejected adapter attach receipts"
        )
    }

    let dryRunMode = igniteHandlerAdapterDryRunModeFor(
        adapterAttachReceipt.adapterMode
    )
    let blockers = igniteHandlerAdapterDryRunBlockers(
        request,
        dryRunMode
    )
    if (blockers.size > 0) {
        return IgniteHandlerAdapterDryRunReceipt(
            false,
            adapterAttachReceipt.adapterAttachAccepted,
            adapterAttachReceipt.adapterMode,
            dryRunMode,
            request.dryRunId,
            "block",
            "blocked-handler-adapter-dry-run-input",
            "fix-handler-dry-run-envelope-before-request-execution-simulation",
            blockers,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry dry-run id, handler contract snapshot, request projection snapshot, response expectation marker, error boundary marker, and keep live execution requests out",
            "QUIC can reuse the same dry-run blockers before stream request execution simulation"
        )
    }

    IgniteHandlerAdapterDryRunReceipt(
        true,
        adapterAttachReceipt.adapterAttachAccepted,
        adapterAttachReceipt.adapterMode,
        dryRunMode,
        request.dryRunId,
        "record-handler-adapter-dry-run-receipt",
        "accepted-handler-adapter-dry-run-receipt",
        "record-handler-adapter-dry-run-without-handler-invocation",
        [],
        false,
        false,
        false,
        false,
        nonClaims,
        "next packet may simulate request execution boundaries without invoking user handlers",
        "QUIC can reuse lane-specific handler dry-run modes before live stream handler execution"
    )
}

func igniteHandlerAdapterDryRunModeFor(adapterMode: String): String {
    if (adapterMode == "short-handler-adapter-attach") {
        return "short-handler-adapter-dry-run"
    }
    if (adapterMode == "long-handler-adapter-attach") {
        return "long-handler-adapter-dry-run"
    }
    if (adapterMode == "blocking-isolation-adapter-attach") {
        return "blocking-isolation-handler-dry-run"
    }
    "unknown-handler-adapter-dry-run"
}

func igniteHandlerAdapterDryRunBlockers(
    request: IgniteHandlerAdapterDryRunRequest,
    dryRunMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.dryRunId.size == 0) {
        blockers.add("DRY_RUN_ID_NOT_CARRIED")
    }
    if (!request.handlerAdapterContractSnapshotCarried) {
        blockers.add("HANDLER_ADAPTER_CONTRACT_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.requestProjectionSnapshotCarried) {
        blockers.add("REQUEST_PROJECTION_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.responseExpectationMarkerCarried) {
        blockers.add("RESPONSE_EXPECTATION_MARKER_NOT_CARRIED")
    }
    if (!request.errorBoundaryMarkerCarried) {
        blockers.add("ERROR_BOUNDARY_MARKER_NOT_CARRIED")
    }
    if (request.handlerInvocationRequested) {
        blockers.add("HANDLER_INVOCATION_REQUESTED")
    }
    if (request.requestContextMutationRequested) {
        blockers.add("REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.runtimeTaskSpawnRequested) {
        blockers.add("RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.liveServerWiringRequested) {
        blockers.add("LIVE_SERVER_WIRING_REQUESTED")
    }
    if (dryRunMode == "unknown-handler-adapter-dry-run") {
        blockers.add("UNKNOWN_HANDLER_ADAPTER_DRY_RUN")
    }
    blockers.toArray()
}

func igniteHandlerAdapterDryRunNonClaims(): Array<String> {
    [
        "NO_LIVE_SERVER_WIRING",
        "NO_HANDLER_INVOCATION",
        "NO_REQUEST_CONTEXT_MUTATION",
        "NO_RUNTIME_TASK_SPAWN",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
        "NO_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
    ]
}

public class IgniteRequestExecutionSimulationRequest {
    public let simulationId: String
    public let requestEnvelopeSnapshotCarried: Bool
    public let handlerDryRunPlanCarried: Bool
    public let responseCommitPlanCarried: Bool
    public let errorRecoveryPlanCarried: Bool
    public let schedulerDecisionSnapshotCarried: Bool
    public let handlerInvocationRequested: Bool
    public let requestContextMutationRequested: Bool
    public let runtimeTaskSpawnRequested: Bool
    public let responseWriteRequested: Bool
    public let liveServerWiringRequested: Bool

    public init(
        simulationId: String,
        requestEnvelopeSnapshotCarried: Bool,
        handlerDryRunPlanCarried: Bool,
        responseCommitPlanCarried: Bool,
        errorRecoveryPlanCarried: Bool,
        schedulerDecisionSnapshotCarried: Bool,
        handlerInvocationRequested: Bool,
        requestContextMutationRequested: Bool,
        runtimeTaskSpawnRequested: Bool,
        responseWriteRequested: Bool,
        liveServerWiringRequested: Bool
    ) {
        this.simulationId = simulationId
        this.requestEnvelopeSnapshotCarried = requestEnvelopeSnapshotCarried
        this.handlerDryRunPlanCarried = handlerDryRunPlanCarried
        this.responseCommitPlanCarried = responseCommitPlanCarried
        this.errorRecoveryPlanCarried = errorRecoveryPlanCarried
        this.schedulerDecisionSnapshotCarried =
            schedulerDecisionSnapshotCarried
        this.handlerInvocationRequested = handlerInvocationRequested
        this.requestContextMutationRequested = requestContextMutationRequested
        this.runtimeTaskSpawnRequested = runtimeTaskSpawnRequested
        this.responseWriteRequested = responseWriteRequested
        this.liveServerWiringRequested = liveServerWiringRequested
    }
}

public class IgniteRequestExecutionSimulationReceipt {
    public let requestExecutionSimulationAccepted: Bool
    public let handlerDryRunAccepted: Bool
    public let dryRunMode: String
    public let simulationMode: String
    public let simulationId: String
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let handlerInvocationAllowed: Bool
    public let requestContextMutationAllowed: Bool
    public let runtimeTaskSpawnAllowed: Bool
    public let responseWriteAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        requestExecutionSimulationAccepted: Bool,
        handlerDryRunAccepted: Bool,
        dryRunMode: String,
        simulationMode: String,
        simulationId: String,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        handlerInvocationAllowed: Bool,
        requestContextMutationAllowed: Bool,
        runtimeTaskSpawnAllowed: Bool,
        responseWriteAllowed: Bool,
        liveServerWiringAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.requestExecutionSimulationAccepted =
            requestExecutionSimulationAccepted
        this.handlerDryRunAccepted = handlerDryRunAccepted
        this.dryRunMode = dryRunMode
        this.simulationMode = simulationMode
        this.simulationId = simulationId
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.handlerInvocationAllowed = handlerInvocationAllowed
        this.requestContextMutationAllowed = requestContextMutationAllowed
        this.runtimeTaskSpawnAllowed = runtimeTaskSpawnAllowed
        this.responseWriteAllowed = responseWriteAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteRequestExecutionSimulationReceipt(
    handlerDryRunReceipt: IgniteHandlerAdapterDryRunReceipt,
    request: IgniteRequestExecutionSimulationRequest
): IgniteRequestExecutionSimulationReceipt {
    let nonClaims = igniteRequestExecutionSimulationNonClaims()
    if (!handlerDryRunReceipt.handlerDryRunAccepted) {
        return IgniteRequestExecutionSimulationReceipt(
            false,
            handlerDryRunReceipt.handlerDryRunAccepted,
            handlerDryRunReceipt.dryRunMode,
            "none",
            request.simulationId,
            "block",
            "blocked-handler-adapter-dry-run-receipt",
            "collect-accepted-handler-dry-run-receipt-first",
            ["HANDLER_ADAPTER_DRY_RUN_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0453 handler dry-run input before request execution simulation work",
            "QUIC must not consume request execution simulation receipts from rejected handler dry-runs"
        )
    }

    let simulationMode = igniteRequestExecutionSimulationModeFor(
        handlerDryRunReceipt.dryRunMode
    )
    let blockers = igniteRequestExecutionSimulationBlockers(
        request,
        simulationMode
    )
    if (blockers.size > 0) {
        return IgniteRequestExecutionSimulationReceipt(
            false,
            handlerDryRunReceipt.handlerDryRunAccepted,
            handlerDryRunReceipt.dryRunMode,
            simulationMode,
            request.simulationId,
            "block",
            "blocked-request-execution-simulation-input",
            "fix-request-execution-simulation-envelope-before-execution-plan-commit",
            blockers,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry simulation id, request envelope, dry-run plan, response commit plan, error recovery plan, scheduler snapshot, and keep live execution requests out",
            "QUIC can reuse the same simulation blockers before stream execution plan commit"
        )
    }

    IgniteRequestExecutionSimulationReceipt(
        true,
        handlerDryRunReceipt.handlerDryRunAccepted,
        handlerDryRunReceipt.dryRunMode,
        simulationMode,
        request.simulationId,
        "record-request-execution-simulation-receipt",
        "accepted-request-execution-simulation-receipt",
        "record-request-execution-simulation-without-live-execution",
        [],
        false,
        false,
        false,
        false,
        false,
        nonClaims,
        "next packet may commit an execution plan boundary without invoking user handlers",
        "QUIC can reuse lane-specific request simulation modes before live stream execution"
    )
}

func igniteRequestExecutionSimulationModeFor(dryRunMode: String): String {
    if (dryRunMode == "short-handler-adapter-dry-run") {
        return "short-request-execution-simulation"
    }
    if (dryRunMode == "long-handler-adapter-dry-run") {
        return "long-request-execution-simulation"
    }
    if (dryRunMode == "blocking-isolation-handler-dry-run") {
        return "blocking-isolation-request-execution-simulation"
    }
    "unknown-request-execution-simulation"
}

func igniteRequestExecutionSimulationBlockers(
    request: IgniteRequestExecutionSimulationRequest,
    simulationMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.simulationId.size == 0) {
        blockers.add("SIMULATION_ID_NOT_CARRIED")
    }
    if (!request.requestEnvelopeSnapshotCarried) {
        blockers.add("REQUEST_ENVELOPE_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.handlerDryRunPlanCarried) {
        blockers.add("HANDLER_DRY_RUN_PLAN_NOT_CARRIED")
    }
    if (!request.responseCommitPlanCarried) {
        blockers.add("RESPONSE_COMMIT_PLAN_NOT_CARRIED")
    }
    if (!request.errorRecoveryPlanCarried) {
        blockers.add("ERROR_RECOVERY_PLAN_NOT_CARRIED")
    }
    if (!request.schedulerDecisionSnapshotCarried) {
        blockers.add("SCHEDULER_DECISION_SNAPSHOT_NOT_CARRIED")
    }
    if (request.handlerInvocationRequested) {
        blockers.add("HANDLER_INVOCATION_REQUESTED")
    }
    if (request.requestContextMutationRequested) {
        blockers.add("REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.runtimeTaskSpawnRequested) {
        blockers.add("RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.responseWriteRequested) {
        blockers.add("RESPONSE_WRITE_REQUESTED")
    }
    if (request.liveServerWiringRequested) {
        blockers.add("LIVE_SERVER_WIRING_REQUESTED")
    }
    if (simulationMode == "unknown-request-execution-simulation") {
        blockers.add("UNKNOWN_REQUEST_EXECUTION_SIMULATION")
    }
    blockers.toArray()
}

func igniteRequestExecutionSimulationNonClaims(): Array<String> {
    [
        "NO_LIVE_SERVER_WIRING",
        "NO_HANDLER_INVOCATION",
        "NO_REQUEST_CONTEXT_MUTATION",
        "NO_RUNTIME_TASK_SPAWN",
        "NO_RESPONSE_WRITE",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
        "NO_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
    ]
}

public class IgniteExecutionPlanCommitBoundaryRequest {
    public let executionPlanId: String
    public let requestSimulationSnapshotCarried: Bool
    public let selectedLaneSnapshotCarried: Bool
    public let responseCommitBoundaryCarried: Bool
    public let errorBoundaryCarried: Bool
    public let cancellationBoundaryCarried: Bool
    public let backpressureBoundaryCarried: Bool
    public let handlerInvocationRequested: Bool
    public let requestContextMutationRequested: Bool
    public let runtimeTaskSpawnRequested: Bool
    public let responseWriteRequested: Bool
    public let transportCommitRequested: Bool
    public let liveServerWiringRequested: Bool

    public init(
        executionPlanId: String,
        requestSimulationSnapshotCarried: Bool,
        selectedLaneSnapshotCarried: Bool,
        responseCommitBoundaryCarried: Bool,
        errorBoundaryCarried: Bool,
        cancellationBoundaryCarried: Bool,
        backpressureBoundaryCarried: Bool,
        handlerInvocationRequested: Bool,
        requestContextMutationRequested: Bool,
        runtimeTaskSpawnRequested: Bool,
        responseWriteRequested: Bool,
        transportCommitRequested: Bool,
        liveServerWiringRequested: Bool
    ) {
        this.executionPlanId = executionPlanId
        this.requestSimulationSnapshotCarried =
            requestSimulationSnapshotCarried
        this.selectedLaneSnapshotCarried = selectedLaneSnapshotCarried
        this.responseCommitBoundaryCarried = responseCommitBoundaryCarried
        this.errorBoundaryCarried = errorBoundaryCarried
        this.cancellationBoundaryCarried = cancellationBoundaryCarried
        this.backpressureBoundaryCarried = backpressureBoundaryCarried
        this.handlerInvocationRequested = handlerInvocationRequested
        this.requestContextMutationRequested = requestContextMutationRequested
        this.runtimeTaskSpawnRequested = runtimeTaskSpawnRequested
        this.responseWriteRequested = responseWriteRequested
        this.transportCommitRequested = transportCommitRequested
        this.liveServerWiringRequested = liveServerWiringRequested
    }
}

public class IgniteExecutionPlanCommitBoundaryReceipt {
    public let executionPlanCommitAccepted: Bool
    public let requestExecutionSimulationAccepted: Bool
    public let simulationMode: String
    public let executionPlanMode: String
    public let executionPlanId: String
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let handlerInvocationAllowed: Bool
    public let requestContextMutationAllowed: Bool
    public let runtimeTaskSpawnAllowed: Bool
    public let responseWriteAllowed: Bool
    public let transportCommitAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        executionPlanCommitAccepted: Bool,
        requestExecutionSimulationAccepted: Bool,
        simulationMode: String,
        executionPlanMode: String,
        executionPlanId: String,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        handlerInvocationAllowed: Bool,
        requestContextMutationAllowed: Bool,
        runtimeTaskSpawnAllowed: Bool,
        responseWriteAllowed: Bool,
        transportCommitAllowed: Bool,
        liveServerWiringAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.executionPlanCommitAccepted = executionPlanCommitAccepted
        this.requestExecutionSimulationAccepted =
            requestExecutionSimulationAccepted
        this.simulationMode = simulationMode
        this.executionPlanMode = executionPlanMode
        this.executionPlanId = executionPlanId
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.handlerInvocationAllowed = handlerInvocationAllowed
        this.requestContextMutationAllowed = requestContextMutationAllowed
        this.runtimeTaskSpawnAllowed = runtimeTaskSpawnAllowed
        this.responseWriteAllowed = responseWriteAllowed
        this.transportCommitAllowed = transportCommitAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteExecutionPlanCommitBoundaryReceipt(
    simulationReceipt: IgniteRequestExecutionSimulationReceipt,
    request: IgniteExecutionPlanCommitBoundaryRequest
): IgniteExecutionPlanCommitBoundaryReceipt {
    let nonClaims = igniteExecutionPlanCommitBoundaryNonClaims()
    if (!simulationReceipt.requestExecutionSimulationAccepted) {
        return IgniteExecutionPlanCommitBoundaryReceipt(
            false,
            simulationReceipt.requestExecutionSimulationAccepted,
            simulationReceipt.simulationMode,
            "none",
            request.executionPlanId,
            "block",
            "blocked-request-execution-simulation-receipt",
            "collect-accepted-request-execution-simulation-receipt-first",
            ["REQUEST_EXECUTION_SIMULATION_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0454 request execution simulation input before execution-plan commit work",
            "QUIC must not consume execution-plan commit receipts from rejected request simulations"
        )
    }

    let executionPlanMode = igniteExecutionPlanCommitBoundaryModeFor(
        simulationReceipt.simulationMode
    )
    let blockers = igniteExecutionPlanCommitBoundaryBlockers(
        request,
        executionPlanMode
    )
    if (blockers.size > 0) {
        return IgniteExecutionPlanCommitBoundaryReceipt(
            false,
            simulationReceipt.requestExecutionSimulationAccepted,
            simulationReceipt.simulationMode,
            executionPlanMode,
            request.executionPlanId,
            "block",
            "blocked-execution-plan-commit-boundary-input",
            "fix-execution-plan-boundary-before-executor-dispatch-planning",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry plan id, request simulation snapshot, lane snapshot, response commit boundary, error boundary, cancellation boundary, backpressure boundary, and keep live commit requests out",
            "QUIC can reuse the same execution-plan blockers before stream executor dispatch planning"
        )
    }

    IgniteExecutionPlanCommitBoundaryReceipt(
        true,
        simulationReceipt.requestExecutionSimulationAccepted,
        simulationReceipt.simulationMode,
        executionPlanMode,
        request.executionPlanId,
        "record-execution-plan-commit-boundary-receipt",
        "accepted-execution-plan-commit-boundary-receipt",
        "record-execution-plan-boundary-without-live-execution",
        [],
        false,
        false,
        false,
        false,
        false,
        false,
        nonClaims,
        "next packet may plan executor dispatch without invoking user handlers or committing transport output",
        "QUIC can reuse lane-specific execution-plan modes before live stream dispatch"
    )
}

func igniteExecutionPlanCommitBoundaryModeFor(
    simulationMode: String
): String {
    if (simulationMode == "short-request-execution-simulation") {
        return "short-execution-plan-commit-boundary"
    }
    if (simulationMode == "long-request-execution-simulation") {
        return "long-execution-plan-commit-boundary"
    }
    if (simulationMode == "blocking-isolation-request-execution-simulation") {
        return "blocking-isolation-execution-plan-commit-boundary"
    }
    "unknown-execution-plan-commit-boundary"
}

func igniteExecutionPlanCommitBoundaryBlockers(
    request: IgniteExecutionPlanCommitBoundaryRequest,
    executionPlanMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.executionPlanId.size == 0) {
        blockers.add("EXECUTION_PLAN_ID_NOT_CARRIED")
    }
    if (!request.requestSimulationSnapshotCarried) {
        blockers.add("REQUEST_SIMULATION_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.selectedLaneSnapshotCarried) {
        blockers.add("SELECTED_LANE_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.responseCommitBoundaryCarried) {
        blockers.add("RESPONSE_COMMIT_BOUNDARY_NOT_CARRIED")
    }
    if (!request.errorBoundaryCarried) {
        blockers.add("ERROR_BOUNDARY_NOT_CARRIED")
    }
    if (!request.cancellationBoundaryCarried) {
        blockers.add("CANCELLATION_BOUNDARY_NOT_CARRIED")
    }
    if (!request.backpressureBoundaryCarried) {
        blockers.add("BACKPRESSURE_BOUNDARY_NOT_CARRIED")
    }
    if (request.handlerInvocationRequested) {
        blockers.add("HANDLER_INVOCATION_REQUESTED")
    }
    if (request.requestContextMutationRequested) {
        blockers.add("REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.runtimeTaskSpawnRequested) {
        blockers.add("RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.responseWriteRequested) {
        blockers.add("RESPONSE_WRITE_REQUESTED")
    }
    if (request.transportCommitRequested) {
        blockers.add("TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.liveServerWiringRequested) {
        blockers.add("LIVE_SERVER_WIRING_REQUESTED")
    }
    if (executionPlanMode == "unknown-execution-plan-commit-boundary") {
        blockers.add("UNKNOWN_EXECUTION_PLAN_COMMIT_BOUNDARY")
    }
    blockers.toArray()
}

func igniteExecutionPlanCommitBoundaryNonClaims(): Array<String> {
    [
        "NO_LIVE_SERVER_WIRING",
        "NO_HANDLER_INVOCATION",
        "NO_REQUEST_CONTEXT_MUTATION",
        "NO_RUNTIME_TASK_SPAWN",
        "NO_RESPONSE_WRITE",
        "NO_TRANSPORT_COMMIT",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
        "NO_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
    ]
}

public class IgniteExecutorDispatchPlanRequest {
    public let dispatchPlanId: String
    public let executionPlanBoundarySnapshotCarried: Bool
    public let executorLaneMarkerCarried: Bool
    public let queuePolicyCarried: Bool
    public let isolationPolicyCarried: Bool
    public let cancellationPropagationCarried: Bool
    public let backpressureHandoffCarried: Bool
    public let handlerInvocationRequested: Bool
    public let requestContextMutationRequested: Bool
    public let runtimeTaskSpawnRequested: Bool
    public let responseWriteRequested: Bool
    public let transportCommitRequested: Bool
    public let liveServerWiringRequested: Bool

    public init(
        dispatchPlanId: String,
        executionPlanBoundarySnapshotCarried: Bool,
        executorLaneMarkerCarried: Bool,
        queuePolicyCarried: Bool,
        isolationPolicyCarried: Bool,
        cancellationPropagationCarried: Bool,
        backpressureHandoffCarried: Bool,
        handlerInvocationRequested: Bool,
        requestContextMutationRequested: Bool,
        runtimeTaskSpawnRequested: Bool,
        responseWriteRequested: Bool,
        transportCommitRequested: Bool,
        liveServerWiringRequested: Bool
    ) {
        this.dispatchPlanId = dispatchPlanId
        this.executionPlanBoundarySnapshotCarried =
            executionPlanBoundarySnapshotCarried
        this.executorLaneMarkerCarried = executorLaneMarkerCarried
        this.queuePolicyCarried = queuePolicyCarried
        this.isolationPolicyCarried = isolationPolicyCarried
        this.cancellationPropagationCarried = cancellationPropagationCarried
        this.backpressureHandoffCarried = backpressureHandoffCarried
        this.handlerInvocationRequested = handlerInvocationRequested
        this.requestContextMutationRequested = requestContextMutationRequested
        this.runtimeTaskSpawnRequested = runtimeTaskSpawnRequested
        this.responseWriteRequested = responseWriteRequested
        this.transportCommitRequested = transportCommitRequested
        this.liveServerWiringRequested = liveServerWiringRequested
    }
}

public class IgniteExecutorDispatchPlanReceipt {
    public let executorDispatchPlanAccepted: Bool
    public let executionPlanCommitAccepted: Bool
    public let executionPlanMode: String
    public let executorDispatchPlanMode: String
    public let dispatchPlanId: String
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let handlerInvocationAllowed: Bool
    public let requestContextMutationAllowed: Bool
    public let runtimeTaskSpawnAllowed: Bool
    public let responseWriteAllowed: Bool
    public let transportCommitAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        executorDispatchPlanAccepted: Bool,
        executionPlanCommitAccepted: Bool,
        executionPlanMode: String,
        executorDispatchPlanMode: String,
        dispatchPlanId: String,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        handlerInvocationAllowed: Bool,
        requestContextMutationAllowed: Bool,
        runtimeTaskSpawnAllowed: Bool,
        responseWriteAllowed: Bool,
        transportCommitAllowed: Bool,
        liveServerWiringAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.executorDispatchPlanAccepted = executorDispatchPlanAccepted
        this.executionPlanCommitAccepted = executionPlanCommitAccepted
        this.executionPlanMode = executionPlanMode
        this.executorDispatchPlanMode = executorDispatchPlanMode
        this.dispatchPlanId = dispatchPlanId
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.handlerInvocationAllowed = handlerInvocationAllowed
        this.requestContextMutationAllowed = requestContextMutationAllowed
        this.runtimeTaskSpawnAllowed = runtimeTaskSpawnAllowed
        this.responseWriteAllowed = responseWriteAllowed
        this.transportCommitAllowed = transportCommitAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteExecutorDispatchPlanReceipt(
    executionPlanReceipt: IgniteExecutionPlanCommitBoundaryReceipt,
    request: IgniteExecutorDispatchPlanRequest
): IgniteExecutorDispatchPlanReceipt {
    let nonClaims = igniteExecutorDispatchPlanNonClaims()
    if (!executionPlanReceipt.executionPlanCommitAccepted) {
        return IgniteExecutorDispatchPlanReceipt(
            false,
            executionPlanReceipt.executionPlanCommitAccepted,
            executionPlanReceipt.executionPlanMode,
            "none",
            request.dispatchPlanId,
            "block",
            "blocked-execution-plan-commit-boundary-receipt",
            "collect-accepted-execution-plan-commit-boundary-receipt-first",
            ["EXECUTION_PLAN_COMMIT_BOUNDARY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0455 execution-plan commit boundary input before executor dispatch planning",
            "QUIC must not consume executor dispatch plan receipts from rejected execution-plan boundaries"
        )
    }

    let dispatchPlanMode = igniteExecutorDispatchPlanModeFor(
        executionPlanReceipt.executionPlanMode
    )
    let blockers = igniteExecutorDispatchPlanBlockers(
        request,
        dispatchPlanMode
    )
    if (blockers.size > 0) {
        return IgniteExecutorDispatchPlanReceipt(
            false,
            executionPlanReceipt.executionPlanCommitAccepted,
            executionPlanReceipt.executionPlanMode,
            dispatchPlanMode,
            request.dispatchPlanId,
            "block",
            "blocked-executor-dispatch-plan-input",
            "fix-executor-dispatch-plan-before-enqueue-or-dry-run-dispatch",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry dispatch plan id, execution plan boundary snapshot, executor lane marker, queue policy, isolation policy, cancellation propagation, backpressure handoff, and keep live dispatch requests out",
            "QUIC can reuse the same executor dispatch blockers before stream executor enqueue planning"
        )
    }

    IgniteExecutorDispatchPlanReceipt(
        true,
        executionPlanReceipt.executionPlanCommitAccepted,
        executionPlanReceipt.executionPlanMode,
        dispatchPlanMode,
        request.dispatchPlanId,
        "record-executor-dispatch-plan-receipt",
        "accepted-executor-dispatch-plan-receipt",
        "record-executor-dispatch-plan-without-live-dispatch",
        [],
        false,
        false,
        false,
        false,
        false,
        false,
        nonClaims,
        "next packet may plan executor enqueue or dry-run dispatch without invoking user handlers or spawning runtime tasks",
        "QUIC can reuse lane-specific executor dispatch plan modes before live stream enqueue"
    )
}

func igniteExecutorDispatchPlanModeFor(executionPlanMode: String): String {
    if (executionPlanMode == "short-execution-plan-commit-boundary") {
        return "short-executor-dispatch-plan"
    }
    if (executionPlanMode == "long-execution-plan-commit-boundary") {
        return "long-executor-dispatch-plan"
    }
    if (executionPlanMode == "blocking-isolation-execution-plan-commit-boundary") {
        return "blocking-isolation-executor-dispatch-plan"
    }
    "unknown-executor-dispatch-plan"
}

func igniteExecutorDispatchPlanBlockers(
    request: IgniteExecutorDispatchPlanRequest,
    dispatchPlanMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.dispatchPlanId.size == 0) {
        blockers.add("DISPATCH_PLAN_ID_NOT_CARRIED")
    }
    if (!request.executionPlanBoundarySnapshotCarried) {
        blockers.add("EXECUTION_PLAN_BOUNDARY_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.executorLaneMarkerCarried) {
        blockers.add("EXECUTOR_LANE_MARKER_NOT_CARRIED")
    }
    if (!request.queuePolicyCarried) {
        blockers.add("QUEUE_POLICY_NOT_CARRIED")
    }
    if (!request.isolationPolicyCarried) {
        blockers.add("ISOLATION_POLICY_NOT_CARRIED")
    }
    if (!request.cancellationPropagationCarried) {
        blockers.add("CANCELLATION_PROPAGATION_NOT_CARRIED")
    }
    if (!request.backpressureHandoffCarried) {
        blockers.add("BACKPRESSURE_HANDOFF_NOT_CARRIED")
    }
    if (request.handlerInvocationRequested) {
        blockers.add("HANDLER_INVOCATION_REQUESTED")
    }
    if (request.requestContextMutationRequested) {
        blockers.add("REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.runtimeTaskSpawnRequested) {
        blockers.add("RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.responseWriteRequested) {
        blockers.add("RESPONSE_WRITE_REQUESTED")
    }
    if (request.transportCommitRequested) {
        blockers.add("TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.liveServerWiringRequested) {
        blockers.add("LIVE_SERVER_WIRING_REQUESTED")
    }
    if (dispatchPlanMode == "unknown-executor-dispatch-plan") {
        blockers.add("UNKNOWN_EXECUTOR_DISPATCH_PLAN")
    }
    blockers.toArray()
}

func igniteExecutorDispatchPlanNonClaims(): Array<String> {
    [
        "NO_LIVE_SERVER_WIRING",
        "NO_HANDLER_INVOCATION",
        "NO_REQUEST_CONTEXT_MUTATION",
        "NO_RUNTIME_TASK_SPAWN",
        "NO_RESPONSE_WRITE",
        "NO_TRANSPORT_COMMIT",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
        "NO_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
    ]
}

public class IgniteExecutorEnqueueDryRunRequest {
    public let enqueueAttemptId: String
    public let dispatchPlanSnapshotCarried: Bool
    public let queueAdmissionPolicyCarried: Bool
    public let executorTokenSnapshotCarried: Bool
    public let dryRunDispatchMarkerCarried: Bool
    public let cancellationPropagationCarried: Bool
    public let backpressureLeaseCarried: Bool
    public let completionCallbackBoundaryCarried: Bool
    public let liveExecutorEnqueueRequested: Bool
    public let handlerInvocationRequested: Bool
    public let requestContextMutationRequested: Bool
    public let runtimeTaskSpawnRequested: Bool
    public let responseWriteRequested: Bool
    public let transportCommitRequested: Bool
    public let liveServerWiringRequested: Bool

    public init(
        enqueueAttemptId: String,
        dispatchPlanSnapshotCarried: Bool,
        queueAdmissionPolicyCarried: Bool,
        executorTokenSnapshotCarried: Bool,
        dryRunDispatchMarkerCarried: Bool,
        cancellationPropagationCarried: Bool,
        backpressureLeaseCarried: Bool,
        completionCallbackBoundaryCarried: Bool,
        liveExecutorEnqueueRequested: Bool,
        handlerInvocationRequested: Bool,
        requestContextMutationRequested: Bool,
        runtimeTaskSpawnRequested: Bool,
        responseWriteRequested: Bool,
        transportCommitRequested: Bool,
        liveServerWiringRequested: Bool
    ) {
        this.enqueueAttemptId = enqueueAttemptId
        this.dispatchPlanSnapshotCarried = dispatchPlanSnapshotCarried
        this.queueAdmissionPolicyCarried = queueAdmissionPolicyCarried
        this.executorTokenSnapshotCarried = executorTokenSnapshotCarried
        this.dryRunDispatchMarkerCarried = dryRunDispatchMarkerCarried
        this.cancellationPropagationCarried = cancellationPropagationCarried
        this.backpressureLeaseCarried = backpressureLeaseCarried
        this.completionCallbackBoundaryCarried =
            completionCallbackBoundaryCarried
        this.liveExecutorEnqueueRequested = liveExecutorEnqueueRequested
        this.handlerInvocationRequested = handlerInvocationRequested
        this.requestContextMutationRequested = requestContextMutationRequested
        this.runtimeTaskSpawnRequested = runtimeTaskSpawnRequested
        this.responseWriteRequested = responseWriteRequested
        this.transportCommitRequested = transportCommitRequested
        this.liveServerWiringRequested = liveServerWiringRequested
    }
}

public class IgniteExecutorEnqueueDryRunReceipt {
    public let executorEnqueueDryRunAccepted: Bool
    public let executorDispatchPlanAccepted: Bool
    public let executorDispatchPlanMode: String
    public let executorEnqueueDryRunMode: String
    public let enqueueAttemptId: String
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let liveExecutorEnqueueAllowed: Bool
    public let handlerInvocationAllowed: Bool
    public let requestContextMutationAllowed: Bool
    public let runtimeTaskSpawnAllowed: Bool
    public let responseWriteAllowed: Bool
    public let transportCommitAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        executorEnqueueDryRunAccepted: Bool,
        executorDispatchPlanAccepted: Bool,
        executorDispatchPlanMode: String,
        executorEnqueueDryRunMode: String,
        enqueueAttemptId: String,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        liveExecutorEnqueueAllowed: Bool,
        handlerInvocationAllowed: Bool,
        requestContextMutationAllowed: Bool,
        runtimeTaskSpawnAllowed: Bool,
        responseWriteAllowed: Bool,
        transportCommitAllowed: Bool,
        liveServerWiringAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.executorEnqueueDryRunAccepted = executorEnqueueDryRunAccepted
        this.executorDispatchPlanAccepted = executorDispatchPlanAccepted
        this.executorDispatchPlanMode = executorDispatchPlanMode
        this.executorEnqueueDryRunMode = executorEnqueueDryRunMode
        this.enqueueAttemptId = enqueueAttemptId
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.liveExecutorEnqueueAllowed = liveExecutorEnqueueAllowed
        this.handlerInvocationAllowed = handlerInvocationAllowed
        this.requestContextMutationAllowed = requestContextMutationAllowed
        this.runtimeTaskSpawnAllowed = runtimeTaskSpawnAllowed
        this.responseWriteAllowed = responseWriteAllowed
        this.transportCommitAllowed = transportCommitAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteExecutorEnqueueDryRunReceipt(
    dispatchPlanReceipt: IgniteExecutorDispatchPlanReceipt,
    request: IgniteExecutorEnqueueDryRunRequest
): IgniteExecutorEnqueueDryRunReceipt {
    let nonClaims = igniteExecutorEnqueueDryRunNonClaims()
    if (!dispatchPlanReceipt.executorDispatchPlanAccepted) {
        return IgniteExecutorEnqueueDryRunReceipt(
            false,
            dispatchPlanReceipt.executorDispatchPlanAccepted,
            dispatchPlanReceipt.executorDispatchPlanMode,
            "none",
            request.enqueueAttemptId,
            "block",
            "blocked-executor-dispatch-plan-receipt",
            "collect-accepted-executor-dispatch-plan-receipt-first",
            ["EXECUTOR_DISPATCH_PLAN_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0456 executor dispatch plan input before enqueue dry-run work",
            "QUIC must not consume executor enqueue dry-run receipts from rejected dispatch plans"
        )
    }

    let enqueueDryRunMode = igniteExecutorEnqueueDryRunModeFor(
        dispatchPlanReceipt.executorDispatchPlanMode
    )
    let blockers = igniteExecutorEnqueueDryRunBlockers(
        request,
        enqueueDryRunMode
    )
    if (blockers.size > 0) {
        return IgniteExecutorEnqueueDryRunReceipt(
            false,
            dispatchPlanReceipt.executorDispatchPlanAccepted,
            dispatchPlanReceipt.executorDispatchPlanMode,
            enqueueDryRunMode,
            request.enqueueAttemptId,
            "block",
            "blocked-executor-enqueue-dry-run-input",
            "fix-executor-enqueue-dry-run-before-enqueue-admission",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry enqueue attempt id, dispatch plan snapshot, queue admission policy, executor token snapshot, dry-run marker, cancellation propagation, backpressure lease, completion callback boundary, and keep live enqueue requests out",
            "QUIC can reuse the same enqueue dry-run blockers before stream executor enqueue admission"
        )
    }

    IgniteExecutorEnqueueDryRunReceipt(
        true,
        dispatchPlanReceipt.executorDispatchPlanAccepted,
        dispatchPlanReceipt.executorDispatchPlanMode,
        enqueueDryRunMode,
        request.enqueueAttemptId,
        "record-executor-enqueue-dry-run-receipt",
        "accepted-executor-enqueue-dry-run-receipt",
        "record-executor-enqueue-dry-run-without-live-enqueue",
        [],
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        nonClaims,
        "next packet may plan enqueue admission without spawning runtime tasks or invoking user handlers",
        "QUIC can reuse lane-specific enqueue dry-run modes before live stream task enqueue"
    )
}

func igniteExecutorEnqueueDryRunModeFor(
    dispatchPlanMode: String
): String {
    if (dispatchPlanMode == "short-executor-dispatch-plan") {
        return "short-executor-enqueue-dry-run"
    }
    if (dispatchPlanMode == "long-executor-dispatch-plan") {
        return "long-executor-enqueue-dry-run"
    }
    if (dispatchPlanMode == "blocking-isolation-executor-dispatch-plan") {
        return "blocking-isolation-executor-enqueue-dry-run"
    }
    "unknown-executor-enqueue-dry-run"
}

func igniteExecutorEnqueueDryRunBlockers(
    request: IgniteExecutorEnqueueDryRunRequest,
    enqueueDryRunMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.enqueueAttemptId.size == 0) {
        blockers.add("ENQUEUE_ATTEMPT_ID_NOT_CARRIED")
    }
    if (!request.dispatchPlanSnapshotCarried) {
        blockers.add("DISPATCH_PLAN_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.queueAdmissionPolicyCarried) {
        blockers.add("QUEUE_ADMISSION_POLICY_NOT_CARRIED")
    }
    if (!request.executorTokenSnapshotCarried) {
        blockers.add("EXECUTOR_TOKEN_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.dryRunDispatchMarkerCarried) {
        blockers.add("DRY_RUN_DISPATCH_MARKER_NOT_CARRIED")
    }
    if (!request.cancellationPropagationCarried) {
        blockers.add("CANCELLATION_PROPAGATION_NOT_CARRIED")
    }
    if (!request.backpressureLeaseCarried) {
        blockers.add("BACKPRESSURE_LEASE_NOT_CARRIED")
    }
    if (!request.completionCallbackBoundaryCarried) {
        blockers.add("COMPLETION_CALLBACK_BOUNDARY_NOT_CARRIED")
    }
    if (request.liveExecutorEnqueueRequested) {
        blockers.add("LIVE_EXECUTOR_ENQUEUE_REQUESTED")
    }
    if (request.handlerInvocationRequested) {
        blockers.add("HANDLER_INVOCATION_REQUESTED")
    }
    if (request.requestContextMutationRequested) {
        blockers.add("REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.runtimeTaskSpawnRequested) {
        blockers.add("RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.responseWriteRequested) {
        blockers.add("RESPONSE_WRITE_REQUESTED")
    }
    if (request.transportCommitRequested) {
        blockers.add("TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.liveServerWiringRequested) {
        blockers.add("LIVE_SERVER_WIRING_REQUESTED")
    }
    if (enqueueDryRunMode == "unknown-executor-enqueue-dry-run") {
        blockers.add("UNKNOWN_EXECUTOR_ENQUEUE_DRY_RUN")
    }
    blockers.toArray()
}

func igniteExecutorEnqueueDryRunNonClaims(): Array<String> {
    [
        "NO_LIVE_SERVER_WIRING",
        "NO_LIVE_EXECUTOR_ENQUEUE",
        "NO_HANDLER_INVOCATION",
        "NO_REQUEST_CONTEXT_MUTATION",
        "NO_RUNTIME_TASK_SPAWN",
        "NO_RESPONSE_WRITE",
        "NO_TRANSPORT_COMMIT",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
        "NO_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
    ]
}

public class IgniteExecutorEnqueueAdmissionDecisionRequest {
    public let admissionDecisionId: String
    public let enqueueDryRunSnapshotCarried: Bool
    public let capacitySnapshotCarried: Bool
    public let laneQuotaSnapshotCarried: Bool
    public let queueOrderPolicyCarried: Bool
    public let cancellationWindowCarried: Bool
    public let backpressureLeaseCarried: Bool
    public let completionBoundaryCarried: Bool
    public let liveExecutorEnqueueRequested: Bool
    public let runtimeTaskSpawnRequested: Bool
    public let handlerInvocationRequested: Bool
    public let requestContextMutationRequested: Bool
    public let responseWriteRequested: Bool
    public let transportCommitRequested: Bool
    public let liveServerWiringRequested: Bool

    public init(
        admissionDecisionId: String,
        enqueueDryRunSnapshotCarried: Bool,
        capacitySnapshotCarried: Bool,
        laneQuotaSnapshotCarried: Bool,
        queueOrderPolicyCarried: Bool,
        cancellationWindowCarried: Bool,
        backpressureLeaseCarried: Bool,
        completionBoundaryCarried: Bool,
        liveExecutorEnqueueRequested: Bool,
        runtimeTaskSpawnRequested: Bool,
        handlerInvocationRequested: Bool,
        requestContextMutationRequested: Bool,
        responseWriteRequested: Bool,
        transportCommitRequested: Bool,
        liveServerWiringRequested: Bool
    ) {
        this.admissionDecisionId = admissionDecisionId
        this.enqueueDryRunSnapshotCarried = enqueueDryRunSnapshotCarried
        this.capacitySnapshotCarried = capacitySnapshotCarried
        this.laneQuotaSnapshotCarried = laneQuotaSnapshotCarried
        this.queueOrderPolicyCarried = queueOrderPolicyCarried
        this.cancellationWindowCarried = cancellationWindowCarried
        this.backpressureLeaseCarried = backpressureLeaseCarried
        this.completionBoundaryCarried = completionBoundaryCarried
        this.liveExecutorEnqueueRequested = liveExecutorEnqueueRequested
        this.runtimeTaskSpawnRequested = runtimeTaskSpawnRequested
        this.handlerInvocationRequested = handlerInvocationRequested
        this.requestContextMutationRequested = requestContextMutationRequested
        this.responseWriteRequested = responseWriteRequested
        this.transportCommitRequested = transportCommitRequested
        this.liveServerWiringRequested = liveServerWiringRequested
    }
}

public class IgniteExecutorEnqueueAdmissionDecisionReceipt {
    public let executorEnqueueAdmissionDecisionAccepted: Bool
    public let executorEnqueueDryRunAccepted: Bool
    public let executorEnqueueDryRunMode: String
    public let executorEnqueueAdmissionDecisionMode: String
    public let admissionDecisionId: String
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let liveExecutorEnqueueAllowed: Bool
    public let runtimeTaskSpawnAllowed: Bool
    public let handlerInvocationAllowed: Bool
    public let requestContextMutationAllowed: Bool
    public let responseWriteAllowed: Bool
    public let transportCommitAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        executorEnqueueAdmissionDecisionAccepted: Bool,
        executorEnqueueDryRunAccepted: Bool,
        executorEnqueueDryRunMode: String,
        executorEnqueueAdmissionDecisionMode: String,
        admissionDecisionId: String,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        liveExecutorEnqueueAllowed: Bool,
        runtimeTaskSpawnAllowed: Bool,
        handlerInvocationAllowed: Bool,
        requestContextMutationAllowed: Bool,
        responseWriteAllowed: Bool,
        transportCommitAllowed: Bool,
        liveServerWiringAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.executorEnqueueAdmissionDecisionAccepted =
            executorEnqueueAdmissionDecisionAccepted
        this.executorEnqueueDryRunAccepted = executorEnqueueDryRunAccepted
        this.executorEnqueueDryRunMode = executorEnqueueDryRunMode
        this.executorEnqueueAdmissionDecisionMode =
            executorEnqueueAdmissionDecisionMode
        this.admissionDecisionId = admissionDecisionId
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.liveExecutorEnqueueAllowed = liveExecutorEnqueueAllowed
        this.runtimeTaskSpawnAllowed = runtimeTaskSpawnAllowed
        this.handlerInvocationAllowed = handlerInvocationAllowed
        this.requestContextMutationAllowed = requestContextMutationAllowed
        this.responseWriteAllowed = responseWriteAllowed
        this.transportCommitAllowed = transportCommitAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteExecutorEnqueueAdmissionDecisionReceipt(
    enqueueDryRunReceipt: IgniteExecutorEnqueueDryRunReceipt,
    request: IgniteExecutorEnqueueAdmissionDecisionRequest
): IgniteExecutorEnqueueAdmissionDecisionReceipt {
    let nonClaims = igniteExecutorEnqueueAdmissionDecisionNonClaims()
    if (!enqueueDryRunReceipt.executorEnqueueDryRunAccepted) {
        return IgniteExecutorEnqueueAdmissionDecisionReceipt(
            false,
            enqueueDryRunReceipt.executorEnqueueDryRunAccepted,
            enqueueDryRunReceipt.executorEnqueueDryRunMode,
            "none",
            request.admissionDecisionId,
            "block",
            "blocked-executor-enqueue-dry-run-receipt",
            "collect-accepted-executor-enqueue-dry-run-receipt-first",
            ["EXECUTOR_ENQUEUE_DRY_RUN_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0457 executor enqueue dry-run input before admission decision work",
            "QUIC must not consume enqueue admission decisions from rejected enqueue dry-runs"
        )
    }

    let admissionMode = igniteExecutorEnqueueAdmissionDecisionModeFor(
        enqueueDryRunReceipt.executorEnqueueDryRunMode
    )
    let blockers = igniteExecutorEnqueueAdmissionDecisionBlockers(
        request,
        admissionMode
    )
    if (blockers.size > 0) {
        return IgniteExecutorEnqueueAdmissionDecisionReceipt(
            false,
            enqueueDryRunReceipt.executorEnqueueDryRunAccepted,
            enqueueDryRunReceipt.executorEnqueueDryRunMode,
            admissionMode,
            request.admissionDecisionId,
            "block",
            "blocked-executor-enqueue-admission-decision-input",
            "fix-executor-enqueue-admission-decision-before-admission-to-enqueue-bridge",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry admission decision id, enqueue dry-run snapshot, capacity snapshot, lane quota snapshot, queue order policy, cancellation window, backpressure lease, completion boundary, and keep live enqueue requests out",
            "QUIC can reuse the same admission decision blockers before stream task enqueue admission"
        )
    }

    IgniteExecutorEnqueueAdmissionDecisionReceipt(
        true,
        enqueueDryRunReceipt.executorEnqueueDryRunAccepted,
        enqueueDryRunReceipt.executorEnqueueDryRunMode,
        admissionMode,
        request.admissionDecisionId,
        "record-executor-enqueue-admission-decision-receipt",
        "accepted-executor-enqueue-admission-decision-receipt",
        "record-executor-enqueue-admission-decision-without-live-enqueue",
        [],
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        nonClaims,
        "next packet may plan an admission-to-enqueue bridge without writing a real queue or spawning runtime tasks",
        "QUIC can reuse lane-specific admission decision modes before live stream task enqueue"
    )
}

func igniteExecutorEnqueueAdmissionDecisionModeFor(
    enqueueDryRunMode: String
): String {
    if (enqueueDryRunMode == "short-executor-enqueue-dry-run") {
        return "short-executor-enqueue-admission-decision"
    }
    if (enqueueDryRunMode == "long-executor-enqueue-dry-run") {
        return "long-executor-enqueue-admission-decision"
    }
    if (enqueueDryRunMode == "blocking-isolation-executor-enqueue-dry-run") {
        return "blocking-isolation-executor-enqueue-admission-decision"
    }
    "unknown-executor-enqueue-admission-decision"
}

func igniteExecutorEnqueueAdmissionDecisionBlockers(
    request: IgniteExecutorEnqueueAdmissionDecisionRequest,
    admissionMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.admissionDecisionId.size == 0) {
        blockers.add("ADMISSION_DECISION_ID_NOT_CARRIED")
    }
    if (!request.enqueueDryRunSnapshotCarried) {
        blockers.add("ENQUEUE_DRY_RUN_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.capacitySnapshotCarried) {
        blockers.add("CAPACITY_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.laneQuotaSnapshotCarried) {
        blockers.add("LANE_QUOTA_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.queueOrderPolicyCarried) {
        blockers.add("QUEUE_ORDER_POLICY_NOT_CARRIED")
    }
    if (!request.cancellationWindowCarried) {
        blockers.add("CANCELLATION_WINDOW_NOT_CARRIED")
    }
    if (!request.backpressureLeaseCarried) {
        blockers.add("BACKPRESSURE_LEASE_NOT_CARRIED")
    }
    if (!request.completionBoundaryCarried) {
        blockers.add("COMPLETION_BOUNDARY_NOT_CARRIED")
    }
    if (request.liveExecutorEnqueueRequested) {
        blockers.add("LIVE_EXECUTOR_ENQUEUE_REQUESTED")
    }
    if (request.runtimeTaskSpawnRequested) {
        blockers.add("RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.handlerInvocationRequested) {
        blockers.add("HANDLER_INVOCATION_REQUESTED")
    }
    if (request.requestContextMutationRequested) {
        blockers.add("REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.responseWriteRequested) {
        blockers.add("RESPONSE_WRITE_REQUESTED")
    }
    if (request.transportCommitRequested) {
        blockers.add("TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.liveServerWiringRequested) {
        blockers.add("LIVE_SERVER_WIRING_REQUESTED")
    }
    if (admissionMode == "unknown-executor-enqueue-admission-decision") {
        blockers.add("UNKNOWN_EXECUTOR_ENQUEUE_ADMISSION_DECISION")
    }
    blockers.toArray()
}

func igniteExecutorEnqueueAdmissionDecisionNonClaims(): Array<String> {
    [
        "NO_LIVE_SERVER_WIRING",
        "NO_LIVE_EXECUTOR_ENQUEUE",
        "NO_HANDLER_INVOCATION",
        "NO_REQUEST_CONTEXT_MUTATION",
        "NO_RUNTIME_TASK_SPAWN",
        "NO_RESPONSE_WRITE",
        "NO_TRANSPORT_COMMIT",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
        "NO_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
    ]
}

public class IgniteExecutorAdmissionToEnqueueBridgeRequest {
    public let bridgeId: String
    public let admissionDecisionSnapshotCarried: Bool
    public let queueSlotReservationCarried: Bool
    public let executorTokenCarried: Bool
    public let enqueueIntentMarkerCarried: Bool
    public let cancellationFenceCarried: Bool
    public let backpressureLeaseCarried: Bool
    public let completionBoundaryCarried: Bool
    public let realQueueWriteRequested: Bool
    public let liveExecutorEnqueueRequested: Bool
    public let runtimeTaskSpawnRequested: Bool
    public let handlerInvocationRequested: Bool
    public let requestContextMutationRequested: Bool
    public let responseWriteRequested: Bool
    public let transportCommitRequested: Bool
    public let liveServerWiringRequested: Bool

    public init(
        bridgeId: String,
        admissionDecisionSnapshotCarried: Bool,
        queueSlotReservationCarried: Bool,
        executorTokenCarried: Bool,
        enqueueIntentMarkerCarried: Bool,
        cancellationFenceCarried: Bool,
        backpressureLeaseCarried: Bool,
        completionBoundaryCarried: Bool,
        realQueueWriteRequested: Bool,
        liveExecutorEnqueueRequested: Bool,
        runtimeTaskSpawnRequested: Bool,
        handlerInvocationRequested: Bool,
        requestContextMutationRequested: Bool,
        responseWriteRequested: Bool,
        transportCommitRequested: Bool,
        liveServerWiringRequested: Bool
    ) {
        this.bridgeId = bridgeId
        this.admissionDecisionSnapshotCarried =
            admissionDecisionSnapshotCarried
        this.queueSlotReservationCarried = queueSlotReservationCarried
        this.executorTokenCarried = executorTokenCarried
        this.enqueueIntentMarkerCarried = enqueueIntentMarkerCarried
        this.cancellationFenceCarried = cancellationFenceCarried
        this.backpressureLeaseCarried = backpressureLeaseCarried
        this.completionBoundaryCarried = completionBoundaryCarried
        this.realQueueWriteRequested = realQueueWriteRequested
        this.liveExecutorEnqueueRequested = liveExecutorEnqueueRequested
        this.runtimeTaskSpawnRequested = runtimeTaskSpawnRequested
        this.handlerInvocationRequested = handlerInvocationRequested
        this.requestContextMutationRequested = requestContextMutationRequested
        this.responseWriteRequested = responseWriteRequested
        this.transportCommitRequested = transportCommitRequested
        this.liveServerWiringRequested = liveServerWiringRequested
    }
}

public class IgniteExecutorAdmissionToEnqueueBridgeReceipt {
    public let executorAdmissionToEnqueueBridgeAccepted: Bool
    public let executorEnqueueAdmissionDecisionAccepted: Bool
    public let executorEnqueueAdmissionDecisionMode: String
    public let executorAdmissionToEnqueueBridgeMode: String
    public let bridgeId: String
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let realQueueWriteAllowed: Bool
    public let liveExecutorEnqueueAllowed: Bool
    public let runtimeTaskSpawnAllowed: Bool
    public let handlerInvocationAllowed: Bool
    public let requestContextMutationAllowed: Bool
    public let responseWriteAllowed: Bool
    public let transportCommitAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        executorAdmissionToEnqueueBridgeAccepted: Bool,
        executorEnqueueAdmissionDecisionAccepted: Bool,
        executorEnqueueAdmissionDecisionMode: String,
        executorAdmissionToEnqueueBridgeMode: String,
        bridgeId: String,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        realQueueWriteAllowed: Bool,
        liveExecutorEnqueueAllowed: Bool,
        runtimeTaskSpawnAllowed: Bool,
        handlerInvocationAllowed: Bool,
        requestContextMutationAllowed: Bool,
        responseWriteAllowed: Bool,
        transportCommitAllowed: Bool,
        liveServerWiringAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.executorAdmissionToEnqueueBridgeAccepted =
            executorAdmissionToEnqueueBridgeAccepted
        this.executorEnqueueAdmissionDecisionAccepted =
            executorEnqueueAdmissionDecisionAccepted
        this.executorEnqueueAdmissionDecisionMode =
            executorEnqueueAdmissionDecisionMode
        this.executorAdmissionToEnqueueBridgeMode =
            executorAdmissionToEnqueueBridgeMode
        this.bridgeId = bridgeId
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.realQueueWriteAllowed = realQueueWriteAllowed
        this.liveExecutorEnqueueAllowed = liveExecutorEnqueueAllowed
        this.runtimeTaskSpawnAllowed = runtimeTaskSpawnAllowed
        this.handlerInvocationAllowed = handlerInvocationAllowed
        this.requestContextMutationAllowed = requestContextMutationAllowed
        this.responseWriteAllowed = responseWriteAllowed
        this.transportCommitAllowed = transportCommitAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteExecutorAdmissionToEnqueueBridgeReceipt(
    admissionDecisionReceipt: IgniteExecutorEnqueueAdmissionDecisionReceipt,
    request: IgniteExecutorAdmissionToEnqueueBridgeRequest
): IgniteExecutorAdmissionToEnqueueBridgeReceipt {
    let nonClaims = igniteExecutorAdmissionToEnqueueBridgeNonClaims()
    if (!admissionDecisionReceipt.executorEnqueueAdmissionDecisionAccepted) {
        return IgniteExecutorAdmissionToEnqueueBridgeReceipt(
            false,
            admissionDecisionReceipt.executorEnqueueAdmissionDecisionAccepted,
            admissionDecisionReceipt.executorEnqueueAdmissionDecisionMode,
            "none",
            request.bridgeId,
            "block",
            "blocked-executor-enqueue-admission-decision-receipt",
            "collect-accepted-executor-enqueue-admission-decision-receipt-first",
            ["EXECUTOR_ENQUEUE_ADMISSION_DECISION_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0458 executor enqueue admission decision input before bridge work",
            "QUIC must not consume admission-to-enqueue bridge receipts from rejected admission decisions"
        )
    }

    let bridgeMode = igniteExecutorAdmissionToEnqueueBridgeModeFor(
        admissionDecisionReceipt.executorEnqueueAdmissionDecisionMode
    )
    let blockers = igniteExecutorAdmissionToEnqueueBridgeBlockers(
        request,
        bridgeMode
    )
    if (blockers.size > 0) {
        return IgniteExecutorAdmissionToEnqueueBridgeReceipt(
            false,
            admissionDecisionReceipt.executorEnqueueAdmissionDecisionAccepted,
            admissionDecisionReceipt.executorEnqueueAdmissionDecisionMode,
            bridgeMode,
            request.bridgeId,
            "block",
            "blocked-executor-admission-to-enqueue-bridge-input",
            "fix-executor-admission-to-enqueue-bridge-before-real-queue-write",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry bridge id, admission decision snapshot, queue slot reservation, executor token, enqueue intent marker, cancellation fence, backpressure lease, completion boundary, and keep real queue writes out",
            "QUIC can reuse the same bridge blockers before stream task queue-write seam work"
        )
    }

    IgniteExecutorAdmissionToEnqueueBridgeReceipt(
        true,
        admissionDecisionReceipt.executorEnqueueAdmissionDecisionAccepted,
        admissionDecisionReceipt.executorEnqueueAdmissionDecisionMode,
        bridgeMode,
        request.bridgeId,
        "record-executor-admission-to-enqueue-bridge-receipt",
        "accepted-executor-admission-to-enqueue-bridge-receipt",
        "record-executor-admission-to-enqueue-bridge-without-real-queue-write",
        [],
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        nonClaims,
        "next packet may plan a real-queue-write seam without spawning runtime tasks or invoking user handlers",
        "QUIC can reuse lane-specific admission-to-enqueue bridge modes before live stream task queue write"
    )
}

func igniteExecutorAdmissionToEnqueueBridgeModeFor(
    admissionMode: String
): String {
    if (admissionMode == "short-executor-enqueue-admission-decision") {
        return "short-executor-admission-to-enqueue-bridge"
    }
    if (admissionMode == "long-executor-enqueue-admission-decision") {
        return "long-executor-admission-to-enqueue-bridge"
    }
    if (
        admissionMode ==
        "blocking-isolation-executor-enqueue-admission-decision"
    ) {
        return "blocking-isolation-executor-admission-to-enqueue-bridge"
    }
    "unknown-executor-admission-to-enqueue-bridge"
}

func igniteExecutorAdmissionToEnqueueBridgeBlockers(
    request: IgniteExecutorAdmissionToEnqueueBridgeRequest,
    bridgeMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.bridgeId.size == 0) {
        blockers.add("BRIDGE_ID_NOT_CARRIED")
    }
    if (!request.admissionDecisionSnapshotCarried) {
        blockers.add("ADMISSION_DECISION_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.queueSlotReservationCarried) {
        blockers.add("QUEUE_SLOT_RESERVATION_NOT_CARRIED")
    }
    if (!request.executorTokenCarried) {
        blockers.add("EXECUTOR_TOKEN_NOT_CARRIED")
    }
    if (!request.enqueueIntentMarkerCarried) {
        blockers.add("ENQUEUE_INTENT_MARKER_NOT_CARRIED")
    }
    if (!request.cancellationFenceCarried) {
        blockers.add("CANCELLATION_FENCE_NOT_CARRIED")
    }
    if (!request.backpressureLeaseCarried) {
        blockers.add("BACKPRESSURE_LEASE_NOT_CARRIED")
    }
    if (!request.completionBoundaryCarried) {
        blockers.add("COMPLETION_BOUNDARY_NOT_CARRIED")
    }
    if (request.realQueueWriteRequested) {
        blockers.add("REAL_QUEUE_WRITE_REQUESTED")
    }
    if (request.liveExecutorEnqueueRequested) {
        blockers.add("LIVE_EXECUTOR_ENQUEUE_REQUESTED")
    }
    if (request.runtimeTaskSpawnRequested) {
        blockers.add("RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.handlerInvocationRequested) {
        blockers.add("HANDLER_INVOCATION_REQUESTED")
    }
    if (request.requestContextMutationRequested) {
        blockers.add("REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.responseWriteRequested) {
        blockers.add("RESPONSE_WRITE_REQUESTED")
    }
    if (request.transportCommitRequested) {
        blockers.add("TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.liveServerWiringRequested) {
        blockers.add("LIVE_SERVER_WIRING_REQUESTED")
    }
    if (bridgeMode == "unknown-executor-admission-to-enqueue-bridge") {
        blockers.add("UNKNOWN_EXECUTOR_ADMISSION_TO_ENQUEUE_BRIDGE")
    }
    blockers.toArray()
}

func igniteExecutorAdmissionToEnqueueBridgeNonClaims(): Array<String> {
    [
        "NO_REAL_QUEUE_WRITE",
        "NO_LIVE_SERVER_WIRING",
        "NO_LIVE_EXECUTOR_ENQUEUE",
        "NO_HANDLER_INVOCATION",
        "NO_REQUEST_CONTEXT_MUTATION",
        "NO_RUNTIME_TASK_SPAWN",
        "NO_RESPONSE_WRITE",
        "NO_TRANSPORT_COMMIT",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
        "NO_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
    ]
}

public class IgniteControlledExecutorQueueWriteRequest {
    public let queueWriteId: String
    public let bridgeSnapshotCarried: Bool
    public let queueEntryIdCarried: Bool
    public let laneKeyCarried: Bool
    public let isolatedQueueModelCarried: Bool
    public let capacitySnapshotCarried: Bool
    public let enqueueOrderMarkerCarried: Bool
    public let cancellationFenceCarried: Bool
    public let backpressureLeaseCarried: Bool
    public let completionBoundaryCarried: Bool
    public let queueDepthBefore: Int64
    public let queueCapacity: Int64
    public let productionQueueMutationRequested: Bool
    public let liveExecutorEnqueueRequested: Bool
    public let runtimeTaskSpawnRequested: Bool
    public let handlerInvocationRequested: Bool
    public let requestContextMutationRequested: Bool
    public let responseWriteRequested: Bool
    public let transportCommitRequested: Bool
    public let liveServerWiringRequested: Bool

    public init(
        queueWriteId: String,
        bridgeSnapshotCarried: Bool,
        queueEntryIdCarried: Bool,
        laneKeyCarried: Bool,
        isolatedQueueModelCarried: Bool,
        capacitySnapshotCarried: Bool,
        enqueueOrderMarkerCarried: Bool,
        cancellationFenceCarried: Bool,
        backpressureLeaseCarried: Bool,
        completionBoundaryCarried: Bool,
        queueDepthBefore: Int64,
        queueCapacity: Int64,
        productionQueueMutationRequested: Bool,
        liveExecutorEnqueueRequested: Bool,
        runtimeTaskSpawnRequested: Bool,
        handlerInvocationRequested: Bool,
        requestContextMutationRequested: Bool,
        responseWriteRequested: Bool,
        transportCommitRequested: Bool,
        liveServerWiringRequested: Bool
    ) {
        this.queueWriteId = queueWriteId
        this.bridgeSnapshotCarried = bridgeSnapshotCarried
        this.queueEntryIdCarried = queueEntryIdCarried
        this.laneKeyCarried = laneKeyCarried
        this.isolatedQueueModelCarried = isolatedQueueModelCarried
        this.capacitySnapshotCarried = capacitySnapshotCarried
        this.enqueueOrderMarkerCarried = enqueueOrderMarkerCarried
        this.cancellationFenceCarried = cancellationFenceCarried
        this.backpressureLeaseCarried = backpressureLeaseCarried
        this.completionBoundaryCarried = completionBoundaryCarried
        this.queueDepthBefore = queueDepthBefore
        this.queueCapacity = queueCapacity
        this.productionQueueMutationRequested =
            productionQueueMutationRequested
        this.liveExecutorEnqueueRequested = liveExecutorEnqueueRequested
        this.runtimeTaskSpawnRequested = runtimeTaskSpawnRequested
        this.handlerInvocationRequested = handlerInvocationRequested
        this.requestContextMutationRequested = requestContextMutationRequested
        this.responseWriteRequested = responseWriteRequested
        this.transportCommitRequested = transportCommitRequested
        this.liveServerWiringRequested = liveServerWiringRequested
    }
}

public class IgniteControlledExecutorQueueWriteReceipt {
    public let controlledExecutorQueueWriteAccepted: Bool
    public let executorAdmissionToEnqueueBridgeAccepted: Bool
    public let executorAdmissionToEnqueueBridgeMode: String
    public let controlledExecutorQueueWriteMode: String
    public let queueWriteId: String
    public let queueDepthBefore: Int64
    public let queueDepthAfter: Int64
    public let queueEntryRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let controlledQueueWriteAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let liveExecutorEnqueueAllowed: Bool
    public let runtimeTaskSpawnAllowed: Bool
    public let handlerInvocationAllowed: Bool
    public let requestContextMutationAllowed: Bool
    public let responseWriteAllowed: Bool
    public let transportCommitAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        controlledExecutorQueueWriteAccepted: Bool,
        executorAdmissionToEnqueueBridgeAccepted: Bool,
        executorAdmissionToEnqueueBridgeMode: String,
        controlledExecutorQueueWriteMode: String,
        queueWriteId: String,
        queueDepthBefore: Int64,
        queueDepthAfter: Int64,
        queueEntryRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        controlledQueueWriteAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        liveExecutorEnqueueAllowed: Bool,
        runtimeTaskSpawnAllowed: Bool,
        handlerInvocationAllowed: Bool,
        requestContextMutationAllowed: Bool,
        responseWriteAllowed: Bool,
        transportCommitAllowed: Bool,
        liveServerWiringAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.controlledExecutorQueueWriteAccepted =
            controlledExecutorQueueWriteAccepted
        this.executorAdmissionToEnqueueBridgeAccepted =
            executorAdmissionToEnqueueBridgeAccepted
        this.executorAdmissionToEnqueueBridgeMode =
            executorAdmissionToEnqueueBridgeMode
        this.controlledExecutorQueueWriteMode =
            controlledExecutorQueueWriteMode
        this.queueWriteId = queueWriteId
        this.queueDepthBefore = queueDepthBefore
        this.queueDepthAfter = queueDepthAfter
        this.queueEntryRecorded = queueEntryRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.controlledQueueWriteAllowed = controlledQueueWriteAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.liveExecutorEnqueueAllowed = liveExecutorEnqueueAllowed
        this.runtimeTaskSpawnAllowed = runtimeTaskSpawnAllowed
        this.handlerInvocationAllowed = handlerInvocationAllowed
        this.requestContextMutationAllowed = requestContextMutationAllowed
        this.responseWriteAllowed = responseWriteAllowed
        this.transportCommitAllowed = transportCommitAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteControlledExecutorQueueWriteReceipt(
    bridgeReceipt: IgniteExecutorAdmissionToEnqueueBridgeReceipt,
    request: IgniteControlledExecutorQueueWriteRequest
): IgniteControlledExecutorQueueWriteReceipt {
    let nonClaims = igniteControlledExecutorQueueWriteNonClaims()
    if (!bridgeReceipt.executorAdmissionToEnqueueBridgeAccepted) {
        return IgniteControlledExecutorQueueWriteReceipt(
            false,
            bridgeReceipt.executorAdmissionToEnqueueBridgeAccepted,
            bridgeReceipt.executorAdmissionToEnqueueBridgeMode,
            "none",
            request.queueWriteId,
            request.queueDepthBefore,
            request.queueDepthBefore,
            false,
            "block",
            "blocked-executor-admission-to-enqueue-bridge-receipt",
            "collect-accepted-executor-admission-to-enqueue-bridge-receipt-first",
            ["EXECUTOR_ADMISSION_TO_ENQUEUE_BRIDGE_NOT_ACCEPTED"],
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
            "return to HQ-0459 executor admission-to-enqueue bridge input before controlled queue-write work",
            "QUIC must not consume controlled queue-write receipts from rejected admission-to-enqueue bridges"
        )
    }

    let queueWriteMode = igniteControlledExecutorQueueWriteModeFor(
        bridgeReceipt.executorAdmissionToEnqueueBridgeMode
    )
    let blockers = igniteControlledExecutorQueueWriteBlockers(
        request,
        queueWriteMode
    )
    if (blockers.size > 0) {
        return IgniteControlledExecutorQueueWriteReceipt(
            false,
            bridgeReceipt.executorAdmissionToEnqueueBridgeAccepted,
            bridgeReceipt.executorAdmissionToEnqueueBridgeMode,
            queueWriteMode,
            request.queueWriteId,
            request.queueDepthBefore,
            request.queueDepthBefore,
            false,
            "block",
            "blocked-controlled-executor-queue-write-input",
            "fix-controlled-executor-queue-write-before-runtime-queue-integration",
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
            nonClaims,
            "carry queue write id, bridge snapshot, queue entry id, lane key, isolated queue model, capacity snapshot, enqueue order marker, cancellation fence, backpressure lease, completion boundary, and keep production queue mutation out",
            "QUIC can reuse the same controlled queue-write blockers before stream task queue integration"
        )
    }

    let queueDepthAfter = request.queueDepthBefore + 1
    IgniteControlledExecutorQueueWriteReceipt(
        true,
        bridgeReceipt.executorAdmissionToEnqueueBridgeAccepted,
        bridgeReceipt.executorAdmissionToEnqueueBridgeMode,
        queueWriteMode,
        request.queueWriteId,
        request.queueDepthBefore,
        queueDepthAfter,
        true,
        "record-controlled-executor-queue-write-receipt",
        "accepted-controlled-executor-queue-write-receipt",
        "record-controlled-executor-queue-write-without-production-queue-mutation",
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
        nonClaims,
        "next packet may plan runtime queue integration without invoking user handlers or spawning production tasks",
        "QUIC can reuse lane-specific controlled queue-write modes before live stream task queue integration"
    )
}

func igniteControlledExecutorQueueWriteModeFor(
    bridgeMode: String
): String {
    if (bridgeMode == "short-executor-admission-to-enqueue-bridge") {
        return "short-controlled-executor-queue-write"
    }
    if (bridgeMode == "long-executor-admission-to-enqueue-bridge") {
        return "long-controlled-executor-queue-write"
    }
    if (
        bridgeMode ==
        "blocking-isolation-executor-admission-to-enqueue-bridge"
    ) {
        return "blocking-isolation-controlled-executor-queue-write"
    }
    "unknown-controlled-executor-queue-write"
}

func igniteControlledExecutorQueueWriteBlockers(
    request: IgniteControlledExecutorQueueWriteRequest,
    queueWriteMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.queueWriteId.size == 0) {
        blockers.add("QUEUE_WRITE_ID_NOT_CARRIED")
    }
    if (!request.bridgeSnapshotCarried) {
        blockers.add("BRIDGE_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.queueEntryIdCarried) {
        blockers.add("QUEUE_ENTRY_ID_NOT_CARRIED")
    }
    if (!request.laneKeyCarried) {
        blockers.add("LANE_KEY_NOT_CARRIED")
    }
    if (!request.isolatedQueueModelCarried) {
        blockers.add("ISOLATED_QUEUE_MODEL_NOT_CARRIED")
    }
    if (!request.capacitySnapshotCarried) {
        blockers.add("CAPACITY_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.enqueueOrderMarkerCarried) {
        blockers.add("ENQUEUE_ORDER_MARKER_NOT_CARRIED")
    }
    if (!request.cancellationFenceCarried) {
        blockers.add("CANCELLATION_FENCE_NOT_CARRIED")
    }
    if (!request.backpressureLeaseCarried) {
        blockers.add("BACKPRESSURE_LEASE_NOT_CARRIED")
    }
    if (!request.completionBoundaryCarried) {
        blockers.add("COMPLETION_BOUNDARY_NOT_CARRIED")
    }
    if (request.queueDepthBefore < 0) {
        blockers.add("QUEUE_DEPTH_BEFORE_NEGATIVE")
    }
    if (request.queueCapacity <= 0) {
        blockers.add("QUEUE_CAPACITY_NOT_POSITIVE")
    }
    if (request.queueCapacity > 0 && request.queueDepthBefore >= request.queueCapacity) {
        blockers.add("CONTROLLED_QUEUE_CAPACITY_EXHAUSTED")
    }
    if (request.productionQueueMutationRequested) {
        blockers.add("PRODUCTION_QUEUE_MUTATION_REQUESTED")
    }
    if (request.liveExecutorEnqueueRequested) {
        blockers.add("LIVE_EXECUTOR_ENQUEUE_REQUESTED")
    }
    if (request.runtimeTaskSpawnRequested) {
        blockers.add("RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.handlerInvocationRequested) {
        blockers.add("HANDLER_INVOCATION_REQUESTED")
    }
    if (request.requestContextMutationRequested) {
        blockers.add("REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.responseWriteRequested) {
        blockers.add("RESPONSE_WRITE_REQUESTED")
    }
    if (request.transportCommitRequested) {
        blockers.add("TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.liveServerWiringRequested) {
        blockers.add("LIVE_SERVER_WIRING_REQUESTED")
    }
    if (queueWriteMode == "unknown-controlled-executor-queue-write") {
        blockers.add("UNKNOWN_CONTROLLED_EXECUTOR_QUEUE_WRITE")
    }
    blockers.toArray()
}

func igniteControlledExecutorQueueWriteNonClaims(): Array<String> {
    [
        "NO_PRODUCTION_QUEUE_MUTATION",
        "NO_LIVE_SERVER_WIRING",
        "NO_LIVE_EXECUTOR_ENQUEUE",
        "NO_HANDLER_INVOCATION",
        "NO_REQUEST_CONTEXT_MUTATION",
        "NO_RUNTIME_TASK_SPAWN",
        "NO_RESPONSE_WRITE",
        "NO_TRANSPORT_COMMIT",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
        "NO_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
    ]
}

public class IgniteRuntimeQueueIntegrationPlanRequest {
    public let integrationPlanId: String
    public let queueWriteSnapshotCarried: Bool
    public let queueEntryReferenceCarried: Bool
    public let laneDispatchPlanCarried: Bool
    public let executorOwnershipTokenCarried: Bool
    public let drainLoopPlanCarried: Bool
    public let cancellationPropagationCarried: Bool
    public let timeoutBoundaryCarried: Bool
    public let completionCallbackCarried: Bool
    public let productionQueueMutationRequested: Bool
    public let liveExecutorEnqueueRequested: Bool
    public let runtimeTaskSpawnRequested: Bool
    public let handlerInvocationRequested: Bool
    public let requestContextMutationRequested: Bool
    public let responseWriteRequested: Bool
    public let transportCommitRequested: Bool
    public let liveServerWiringRequested: Bool

    public init(
        integrationPlanId: String,
        queueWriteSnapshotCarried: Bool,
        queueEntryReferenceCarried: Bool,
        laneDispatchPlanCarried: Bool,
        executorOwnershipTokenCarried: Bool,
        drainLoopPlanCarried: Bool,
        cancellationPropagationCarried: Bool,
        timeoutBoundaryCarried: Bool,
        completionCallbackCarried: Bool,
        productionQueueMutationRequested: Bool,
        liveExecutorEnqueueRequested: Bool,
        runtimeTaskSpawnRequested: Bool,
        handlerInvocationRequested: Bool,
        requestContextMutationRequested: Bool,
        responseWriteRequested: Bool,
        transportCommitRequested: Bool,
        liveServerWiringRequested: Bool
    ) {
        this.integrationPlanId = integrationPlanId
        this.queueWriteSnapshotCarried = queueWriteSnapshotCarried
        this.queueEntryReferenceCarried = queueEntryReferenceCarried
        this.laneDispatchPlanCarried = laneDispatchPlanCarried
        this.executorOwnershipTokenCarried = executorOwnershipTokenCarried
        this.drainLoopPlanCarried = drainLoopPlanCarried
        this.cancellationPropagationCarried =
            cancellationPropagationCarried
        this.timeoutBoundaryCarried = timeoutBoundaryCarried
        this.completionCallbackCarried = completionCallbackCarried
        this.productionQueueMutationRequested =
            productionQueueMutationRequested
        this.liveExecutorEnqueueRequested = liveExecutorEnqueueRequested
        this.runtimeTaskSpawnRequested = runtimeTaskSpawnRequested
        this.handlerInvocationRequested = handlerInvocationRequested
        this.requestContextMutationRequested = requestContextMutationRequested
        this.responseWriteRequested = responseWriteRequested
        this.transportCommitRequested = transportCommitRequested
        this.liveServerWiringRequested = liveServerWiringRequested
    }
}

public class IgniteRuntimeQueueIntegrationPlanReceipt {
    public let runtimeQueueIntegrationPlanAccepted: Bool
    public let controlledExecutorQueueWriteAccepted: Bool
    public let controlledExecutorQueueWriteMode: String
    public let runtimeQueueIntegrationPlanMode: String
    public let integrationPlanId: String
    public let queueWriteId: String
    public let queueDepthBefore: Int64
    public let queueDepthAfter: Int64
    public let queueIntegrationPlanned: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeQueueIntegrationPlanAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let liveExecutorEnqueueAllowed: Bool
    public let runtimeTaskSpawnAllowed: Bool
    public let handlerInvocationAllowed: Bool
    public let requestContextMutationAllowed: Bool
    public let responseWriteAllowed: Bool
    public let transportCommitAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        runtimeQueueIntegrationPlanAccepted: Bool,
        controlledExecutorQueueWriteAccepted: Bool,
        controlledExecutorQueueWriteMode: String,
        runtimeQueueIntegrationPlanMode: String,
        integrationPlanId: String,
        queueWriteId: String,
        queueDepthBefore: Int64,
        queueDepthAfter: Int64,
        queueIntegrationPlanned: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeQueueIntegrationPlanAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        liveExecutorEnqueueAllowed: Bool,
        runtimeTaskSpawnAllowed: Bool,
        handlerInvocationAllowed: Bool,
        requestContextMutationAllowed: Bool,
        responseWriteAllowed: Bool,
        transportCommitAllowed: Bool,
        liveServerWiringAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.runtimeQueueIntegrationPlanAccepted =
            runtimeQueueIntegrationPlanAccepted
        this.controlledExecutorQueueWriteAccepted =
            controlledExecutorQueueWriteAccepted
        this.controlledExecutorQueueWriteMode =
            controlledExecutorQueueWriteMode
        this.runtimeQueueIntegrationPlanMode =
            runtimeQueueIntegrationPlanMode
        this.integrationPlanId = integrationPlanId
        this.queueWriteId = queueWriteId
        this.queueDepthBefore = queueDepthBefore
        this.queueDepthAfter = queueDepthAfter
        this.queueIntegrationPlanned = queueIntegrationPlanned
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeQueueIntegrationPlanAllowed =
            runtimeQueueIntegrationPlanAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.liveExecutorEnqueueAllowed = liveExecutorEnqueueAllowed
        this.runtimeTaskSpawnAllowed = runtimeTaskSpawnAllowed
        this.handlerInvocationAllowed = handlerInvocationAllowed
        this.requestContextMutationAllowed = requestContextMutationAllowed
        this.responseWriteAllowed = responseWriteAllowed
        this.transportCommitAllowed = transportCommitAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteRuntimeQueueIntegrationPlanReceipt(
    queueWriteReceipt: IgniteControlledExecutorQueueWriteReceipt,
    request: IgniteRuntimeQueueIntegrationPlanRequest
): IgniteRuntimeQueueIntegrationPlanReceipt {
    let nonClaims = igniteRuntimeQueueIntegrationPlanNonClaims()
    if (!queueWriteReceipt.controlledExecutorQueueWriteAccepted) {
        return IgniteRuntimeQueueIntegrationPlanReceipt(
            false,
            queueWriteReceipt.controlledExecutorQueueWriteAccepted,
            queueWriteReceipt.controlledExecutorQueueWriteMode,
            "none",
            request.integrationPlanId,
            queueWriteReceipt.queueWriteId,
            queueWriteReceipt.queueDepthBefore,
            queueWriteReceipt.queueDepthAfter,
            false,
            "block",
            "blocked-controlled-executor-queue-write-receipt",
            "collect-accepted-controlled-executor-queue-write-receipt-first",
            ["CONTROLLED_EXECUTOR_QUEUE_WRITE_NOT_ACCEPTED"],
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
            "return to HQ-0460 controlled executor queue-write input before runtime queue integration planning",
            "QUIC must not consume runtime queue integration plans from rejected controlled queue writes"
        )
    }

    let integrationPlanMode = igniteRuntimeQueueIntegrationPlanModeFor(
        queueWriteReceipt.controlledExecutorQueueWriteMode
    )
    let blockers = igniteRuntimeQueueIntegrationPlanBlockers(
        request,
        integrationPlanMode
    )
    if (blockers.size > 0) {
        return IgniteRuntimeQueueIntegrationPlanReceipt(
            false,
            queueWriteReceipt.controlledExecutorQueueWriteAccepted,
            queueWriteReceipt.controlledExecutorQueueWriteMode,
            integrationPlanMode,
            request.integrationPlanId,
            queueWriteReceipt.queueWriteId,
            queueWriteReceipt.queueDepthBefore,
            queueWriteReceipt.queueDepthAfter,
            false,
            "block",
            "blocked-runtime-queue-integration-plan-input",
            "fix-runtime-queue-integration-plan-before-queue-commit-boundary",
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
            nonClaims,
            "carry integration plan id, queue write snapshot, queue entry reference, lane dispatch plan, executor ownership token, drain loop plan, cancellation propagation, timeout boundary, completion callback, and keep production queue mutation out",
            "QUIC can reuse the same runtime queue integration blockers before stream task queue commit boundaries"
        )
    }

    IgniteRuntimeQueueIntegrationPlanReceipt(
        true,
        queueWriteReceipt.controlledExecutorQueueWriteAccepted,
        queueWriteReceipt.controlledExecutorQueueWriteMode,
        integrationPlanMode,
        request.integrationPlanId,
        queueWriteReceipt.queueWriteId,
        queueWriteReceipt.queueDepthBefore,
        queueWriteReceipt.queueDepthAfter,
        true,
        "record-runtime-queue-integration-plan-receipt",
        "accepted-runtime-queue-integration-plan-receipt",
        "record-runtime-queue-integration-plan-without-production-queue-mutation",
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
        nonClaims,
        "next packet may plan queue commit boundaries without invoking user handlers or spawning production tasks",
        "QUIC can reuse lane-specific runtime queue integration modes before live stream task queue commit"
    )
}

func igniteRuntimeQueueIntegrationPlanModeFor(
    queueWriteMode: String
): String {
    if (queueWriteMode == "short-controlled-executor-queue-write") {
        return "short-runtime-queue-integration-plan"
    }
    if (queueWriteMode == "long-controlled-executor-queue-write") {
        return "long-runtime-queue-integration-plan"
    }
    if (
        queueWriteMode ==
        "blocking-isolation-controlled-executor-queue-write"
    ) {
        return "blocking-isolation-runtime-queue-integration-plan"
    }
    "unknown-runtime-queue-integration-plan"
}

func igniteRuntimeQueueIntegrationPlanBlockers(
    request: IgniteRuntimeQueueIntegrationPlanRequest,
    integrationPlanMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.integrationPlanId.size == 0) {
        blockers.add("INTEGRATION_PLAN_ID_NOT_CARRIED")
    }
    if (!request.queueWriteSnapshotCarried) {
        blockers.add("QUEUE_WRITE_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.queueEntryReferenceCarried) {
        blockers.add("QUEUE_ENTRY_REFERENCE_NOT_CARRIED")
    }
    if (!request.laneDispatchPlanCarried) {
        blockers.add("LANE_DISPATCH_PLAN_NOT_CARRIED")
    }
    if (!request.executorOwnershipTokenCarried) {
        blockers.add("EXECUTOR_OWNERSHIP_TOKEN_NOT_CARRIED")
    }
    if (!request.drainLoopPlanCarried) {
        blockers.add("DRAIN_LOOP_PLAN_NOT_CARRIED")
    }
    if (!request.cancellationPropagationCarried) {
        blockers.add("CANCELLATION_PROPAGATION_NOT_CARRIED")
    }
    if (!request.timeoutBoundaryCarried) {
        blockers.add("TIMEOUT_BOUNDARY_NOT_CARRIED")
    }
    if (!request.completionCallbackCarried) {
        blockers.add("COMPLETION_CALLBACK_NOT_CARRIED")
    }
    if (request.productionQueueMutationRequested) {
        blockers.add("PRODUCTION_QUEUE_MUTATION_REQUESTED")
    }
    if (request.liveExecutorEnqueueRequested) {
        blockers.add("LIVE_EXECUTOR_ENQUEUE_REQUESTED")
    }
    if (request.runtimeTaskSpawnRequested) {
        blockers.add("RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.handlerInvocationRequested) {
        blockers.add("HANDLER_INVOCATION_REQUESTED")
    }
    if (request.requestContextMutationRequested) {
        blockers.add("REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.responseWriteRequested) {
        blockers.add("RESPONSE_WRITE_REQUESTED")
    }
    if (request.transportCommitRequested) {
        blockers.add("TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.liveServerWiringRequested) {
        blockers.add("LIVE_SERVER_WIRING_REQUESTED")
    }
    if (integrationPlanMode == "unknown-runtime-queue-integration-plan") {
        blockers.add("UNKNOWN_RUNTIME_QUEUE_INTEGRATION_PLAN")
    }
    blockers.toArray()
}

func igniteRuntimeQueueIntegrationPlanNonClaims(): Array<String> {
    [
        "NO_PRODUCTION_QUEUE_MUTATION",
        "NO_LIVE_SERVER_WIRING",
        "NO_LIVE_EXECUTOR_ENQUEUE",
        "NO_HANDLER_INVOCATION",
        "NO_REQUEST_CONTEXT_MUTATION",
        "NO_RUNTIME_TASK_SPAWN",
        "NO_RESPONSE_WRITE",
        "NO_TRANSPORT_COMMIT",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
        "NO_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
    ]
}

public class IgniteRuntimeQueueCommitBoundaryRequest {
    public let commitBoundaryId: String
    public let integrationPlanSnapshotCarried: Bool
    public let queueEntryCommitReferenceCarried: Bool
    public let laneCommitFenceCarried: Bool
    public let executorOwnershipFenceCarried: Bool
    public let drainLoopCheckpointCarried: Bool
    public let cancellationFenceCarried: Bool
    public let timeoutFenceCarried: Bool
    public let completionBoundaryCarried: Bool
    public let productionQueueMutationRequested: Bool
    public let liveExecutorEnqueueRequested: Bool
    public let runtimeTaskSpawnRequested: Bool
    public let handlerInvocationRequested: Bool
    public let requestContextMutationRequested: Bool
    public let responseWriteRequested: Bool
    public let transportCommitRequested: Bool
    public let liveServerWiringRequested: Bool

    public init(
        commitBoundaryId: String,
        integrationPlanSnapshotCarried: Bool,
        queueEntryCommitReferenceCarried: Bool,
        laneCommitFenceCarried: Bool,
        executorOwnershipFenceCarried: Bool,
        drainLoopCheckpointCarried: Bool,
        cancellationFenceCarried: Bool,
        timeoutFenceCarried: Bool,
        completionBoundaryCarried: Bool,
        productionQueueMutationRequested: Bool,
        liveExecutorEnqueueRequested: Bool,
        runtimeTaskSpawnRequested: Bool,
        handlerInvocationRequested: Bool,
        requestContextMutationRequested: Bool,
        responseWriteRequested: Bool,
        transportCommitRequested: Bool,
        liveServerWiringRequested: Bool
    ) {
        this.commitBoundaryId = commitBoundaryId
        this.integrationPlanSnapshotCarried =
            integrationPlanSnapshotCarried
        this.queueEntryCommitReferenceCarried =
            queueEntryCommitReferenceCarried
        this.laneCommitFenceCarried = laneCommitFenceCarried
        this.executorOwnershipFenceCarried = executorOwnershipFenceCarried
        this.drainLoopCheckpointCarried = drainLoopCheckpointCarried
        this.cancellationFenceCarried = cancellationFenceCarried
        this.timeoutFenceCarried = timeoutFenceCarried
        this.completionBoundaryCarried = completionBoundaryCarried
        this.productionQueueMutationRequested =
            productionQueueMutationRequested
        this.liveExecutorEnqueueRequested = liveExecutorEnqueueRequested
        this.runtimeTaskSpawnRequested = runtimeTaskSpawnRequested
        this.handlerInvocationRequested = handlerInvocationRequested
        this.requestContextMutationRequested = requestContextMutationRequested
        this.responseWriteRequested = responseWriteRequested
        this.transportCommitRequested = transportCommitRequested
        this.liveServerWiringRequested = liveServerWiringRequested
    }
}

public class IgniteRuntimeQueueCommitBoundaryReceipt {
    public let runtimeQueueCommitBoundaryAccepted: Bool
    public let runtimeQueueIntegrationPlanAccepted: Bool
    public let runtimeQueueIntegrationPlanMode: String
    public let runtimeQueueCommitBoundaryMode: String
    public let commitBoundaryId: String
    public let integrationPlanId: String
    public let queueWriteId: String
    public let queueDepthBefore: Int64
    public let queueDepthAfter: Int64
    public let queueCommitBoundaryRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeQueueCommitBoundaryAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let liveExecutorEnqueueAllowed: Bool
    public let runtimeTaskSpawnAllowed: Bool
    public let handlerInvocationAllowed: Bool
    public let requestContextMutationAllowed: Bool
    public let responseWriteAllowed: Bool
    public let transportCommitAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        runtimeQueueCommitBoundaryAccepted: Bool,
        runtimeQueueIntegrationPlanAccepted: Bool,
        runtimeQueueIntegrationPlanMode: String,
        runtimeQueueCommitBoundaryMode: String,
        commitBoundaryId: String,
        integrationPlanId: String,
        queueWriteId: String,
        queueDepthBefore: Int64,
        queueDepthAfter: Int64,
        queueCommitBoundaryRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeQueueCommitBoundaryAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        liveExecutorEnqueueAllowed: Bool,
        runtimeTaskSpawnAllowed: Bool,
        handlerInvocationAllowed: Bool,
        requestContextMutationAllowed: Bool,
        responseWriteAllowed: Bool,
        transportCommitAllowed: Bool,
        liveServerWiringAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.runtimeQueueCommitBoundaryAccepted =
            runtimeQueueCommitBoundaryAccepted
        this.runtimeQueueIntegrationPlanAccepted =
            runtimeQueueIntegrationPlanAccepted
        this.runtimeQueueIntegrationPlanMode =
            runtimeQueueIntegrationPlanMode
        this.runtimeQueueCommitBoundaryMode =
            runtimeQueueCommitBoundaryMode
        this.commitBoundaryId = commitBoundaryId
        this.integrationPlanId = integrationPlanId
        this.queueWriteId = queueWriteId
        this.queueDepthBefore = queueDepthBefore
        this.queueDepthAfter = queueDepthAfter
        this.queueCommitBoundaryRecorded = queueCommitBoundaryRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeQueueCommitBoundaryAllowed =
            runtimeQueueCommitBoundaryAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.liveExecutorEnqueueAllowed = liveExecutorEnqueueAllowed
        this.runtimeTaskSpawnAllowed = runtimeTaskSpawnAllowed
        this.handlerInvocationAllowed = handlerInvocationAllowed
        this.requestContextMutationAllowed = requestContextMutationAllowed
        this.responseWriteAllowed = responseWriteAllowed
        this.transportCommitAllowed = transportCommitAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteRuntimeQueueCommitBoundaryReceipt(
    integrationPlanReceipt: IgniteRuntimeQueueIntegrationPlanReceipt,
    request: IgniteRuntimeQueueCommitBoundaryRequest
): IgniteRuntimeQueueCommitBoundaryReceipt {
    let nonClaims = igniteRuntimeQueueCommitBoundaryNonClaims()
    if (!integrationPlanReceipt.runtimeQueueIntegrationPlanAccepted) {
        return IgniteRuntimeQueueCommitBoundaryReceipt(
            false,
            integrationPlanReceipt.runtimeQueueIntegrationPlanAccepted,
            integrationPlanReceipt.runtimeQueueIntegrationPlanMode,
            "none",
            request.commitBoundaryId,
            integrationPlanReceipt.integrationPlanId,
            integrationPlanReceipt.queueWriteId,
            integrationPlanReceipt.queueDepthBefore,
            integrationPlanReceipt.queueDepthAfter,
            false,
            "block",
            "blocked-runtime-queue-integration-plan-receipt",
            "collect-accepted-runtime-queue-integration-plan-receipt-first",
            ["RUNTIME_QUEUE_INTEGRATION_PLAN_NOT_ACCEPTED"],
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
            "return to HQ-0461 runtime queue integration plan input before queue commit boundary work",
            "QUIC must not consume queue commit boundary receipts from rejected runtime queue integration plans"
        )
    }

    let commitBoundaryMode = igniteRuntimeQueueCommitBoundaryModeFor(
        integrationPlanReceipt.runtimeQueueIntegrationPlanMode
    )
    let blockers = igniteRuntimeQueueCommitBoundaryBlockers(
        request,
        commitBoundaryMode
    )
    if (blockers.size > 0) {
        return IgniteRuntimeQueueCommitBoundaryReceipt(
            false,
            integrationPlanReceipt.runtimeQueueIntegrationPlanAccepted,
            integrationPlanReceipt.runtimeQueueIntegrationPlanMode,
            commitBoundaryMode,
            request.commitBoundaryId,
            integrationPlanReceipt.integrationPlanId,
            integrationPlanReceipt.queueWriteId,
            integrationPlanReceipt.queueDepthBefore,
            integrationPlanReceipt.queueDepthAfter,
            false,
            "block",
            "blocked-runtime-queue-commit-boundary-input",
            "fix-runtime-queue-commit-boundary-before-production-queue-mutation-gate",
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
            nonClaims,
            "carry commit boundary id, integration plan snapshot, queue entry commit reference, lane commit fence, executor ownership fence, drain loop checkpoint, cancellation fence, timeout fence, completion boundary, and keep production queue mutation out",
            "QUIC can reuse the same queue commit boundary blockers before stream task queue mutation gates"
        )
    }

    IgniteRuntimeQueueCommitBoundaryReceipt(
        true,
        integrationPlanReceipt.runtimeQueueIntegrationPlanAccepted,
        integrationPlanReceipt.runtimeQueueIntegrationPlanMode,
        commitBoundaryMode,
        request.commitBoundaryId,
        integrationPlanReceipt.integrationPlanId,
        integrationPlanReceipt.queueWriteId,
        integrationPlanReceipt.queueDepthBefore,
        integrationPlanReceipt.queueDepthAfter,
        true,
        "record-runtime-queue-commit-boundary-receipt",
        "accepted-runtime-queue-commit-boundary-receipt",
        "record-runtime-queue-commit-boundary-without-production-queue-mutation",
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
        nonClaims,
        "next packet may gate production queue mutation without invoking user handlers or spawning production tasks",
        "QUIC can reuse lane-specific runtime queue commit boundary modes before live stream task queue mutation"
    )
}

func igniteRuntimeQueueCommitBoundaryModeFor(
    integrationPlanMode: String
): String {
    if (integrationPlanMode == "short-runtime-queue-integration-plan") {
        return "short-runtime-queue-commit-boundary"
    }
    if (integrationPlanMode == "long-runtime-queue-integration-plan") {
        return "long-runtime-queue-commit-boundary"
    }
    if (
        integrationPlanMode ==
        "blocking-isolation-runtime-queue-integration-plan"
    ) {
        return "blocking-isolation-runtime-queue-commit-boundary"
    }
    "unknown-runtime-queue-commit-boundary"
}

func igniteRuntimeQueueCommitBoundaryBlockers(
    request: IgniteRuntimeQueueCommitBoundaryRequest,
    commitBoundaryMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.commitBoundaryId.size == 0) {
        blockers.add("COMMIT_BOUNDARY_ID_NOT_CARRIED")
    }
    if (!request.integrationPlanSnapshotCarried) {
        blockers.add("INTEGRATION_PLAN_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.queueEntryCommitReferenceCarried) {
        blockers.add("QUEUE_ENTRY_COMMIT_REFERENCE_NOT_CARRIED")
    }
    if (!request.laneCommitFenceCarried) {
        blockers.add("LANE_COMMIT_FENCE_NOT_CARRIED")
    }
    if (!request.executorOwnershipFenceCarried) {
        blockers.add("EXECUTOR_OWNERSHIP_FENCE_NOT_CARRIED")
    }
    if (!request.drainLoopCheckpointCarried) {
        blockers.add("DRAIN_LOOP_CHECKPOINT_NOT_CARRIED")
    }
    if (!request.cancellationFenceCarried) {
        blockers.add("CANCELLATION_FENCE_NOT_CARRIED")
    }
    if (!request.timeoutFenceCarried) {
        blockers.add("TIMEOUT_FENCE_NOT_CARRIED")
    }
    if (!request.completionBoundaryCarried) {
        blockers.add("COMPLETION_BOUNDARY_NOT_CARRIED")
    }
    if (request.productionQueueMutationRequested) {
        blockers.add("PRODUCTION_QUEUE_MUTATION_REQUESTED")
    }
    if (request.liveExecutorEnqueueRequested) {
        blockers.add("LIVE_EXECUTOR_ENQUEUE_REQUESTED")
    }
    if (request.runtimeTaskSpawnRequested) {
        blockers.add("RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.handlerInvocationRequested) {
        blockers.add("HANDLER_INVOCATION_REQUESTED")
    }
    if (request.requestContextMutationRequested) {
        blockers.add("REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.responseWriteRequested) {
        blockers.add("RESPONSE_WRITE_REQUESTED")
    }
    if (request.transportCommitRequested) {
        blockers.add("TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.liveServerWiringRequested) {
        blockers.add("LIVE_SERVER_WIRING_REQUESTED")
    }
    if (commitBoundaryMode == "unknown-runtime-queue-commit-boundary") {
        blockers.add("UNKNOWN_RUNTIME_QUEUE_COMMIT_BOUNDARY")
    }
    blockers.toArray()
}

func igniteRuntimeQueueCommitBoundaryNonClaims(): Array<String> {
    [
        "NO_PRODUCTION_QUEUE_MUTATION",
        "NO_LIVE_SERVER_WIRING",
        "NO_LIVE_EXECUTOR_ENQUEUE",
        "NO_HANDLER_INVOCATION",
        "NO_REQUEST_CONTEXT_MUTATION",
        "NO_RUNTIME_TASK_SPAWN",
        "NO_RESPONSE_WRITE",
        "NO_TRANSPORT_COMMIT",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
        "NO_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
    ]
}

public class IgniteProductionQueueMutationGateRequest {
    public let mutationGateId: String
    public let commitBoundarySnapshotCarried: Bool
    public let queueMutationIntentCarried: Bool
    public let queueStorageTargetCarried: Bool
    public let laneOwnershipCarried: Bool
    public let executorOwnershipCarried: Bool
    public let mutationRollbackCarried: Bool
    public let backpressureFenceCarried: Bool
    public let completionFenceCarried: Bool
    public let actualProductionQueueMutationRequested: Bool
    public let liveExecutorEnqueueRequested: Bool
    public let runtimeTaskSpawnRequested: Bool
    public let handlerInvocationRequested: Bool
    public let requestContextMutationRequested: Bool
    public let responseWriteRequested: Bool
    public let transportCommitRequested: Bool
    public let liveServerWiringRequested: Bool

    public init(
        mutationGateId: String,
        commitBoundarySnapshotCarried: Bool,
        queueMutationIntentCarried: Bool,
        queueStorageTargetCarried: Bool,
        laneOwnershipCarried: Bool,
        executorOwnershipCarried: Bool,
        mutationRollbackCarried: Bool,
        backpressureFenceCarried: Bool,
        completionFenceCarried: Bool,
        actualProductionQueueMutationRequested: Bool,
        liveExecutorEnqueueRequested: Bool,
        runtimeTaskSpawnRequested: Bool,
        handlerInvocationRequested: Bool,
        requestContextMutationRequested: Bool,
        responseWriteRequested: Bool,
        transportCommitRequested: Bool,
        liveServerWiringRequested: Bool
    ) {
        this.mutationGateId = mutationGateId
        this.commitBoundarySnapshotCarried =
            commitBoundarySnapshotCarried
        this.queueMutationIntentCarried = queueMutationIntentCarried
        this.queueStorageTargetCarried = queueStorageTargetCarried
        this.laneOwnershipCarried = laneOwnershipCarried
        this.executorOwnershipCarried = executorOwnershipCarried
        this.mutationRollbackCarried = mutationRollbackCarried
        this.backpressureFenceCarried = backpressureFenceCarried
        this.completionFenceCarried = completionFenceCarried
        this.actualProductionQueueMutationRequested =
            actualProductionQueueMutationRequested
        this.liveExecutorEnqueueRequested = liveExecutorEnqueueRequested
        this.runtimeTaskSpawnRequested = runtimeTaskSpawnRequested
        this.handlerInvocationRequested = handlerInvocationRequested
        this.requestContextMutationRequested = requestContextMutationRequested
        this.responseWriteRequested = responseWriteRequested
        this.transportCommitRequested = transportCommitRequested
        this.liveServerWiringRequested = liveServerWiringRequested
    }
}

public class IgniteProductionQueueMutationGateReceipt {
    public let productionQueueMutationGateAccepted: Bool
    public let runtimeQueueCommitBoundaryAccepted: Bool
    public let runtimeQueueCommitBoundaryMode: String
    public let productionQueueMutationGateMode: String
    public let mutationGateId: String
    public let commitBoundaryId: String
    public let queueWriteId: String
    public let queueDepthBefore: Int64
    public let queueDepthAfter: Int64
    public let mutationGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let productionQueueMutationGateAllowed: Bool
    public let actualProductionQueueMutationAllowed: Bool
    public let liveExecutorEnqueueAllowed: Bool
    public let runtimeTaskSpawnAllowed: Bool
    public let handlerInvocationAllowed: Bool
    public let requestContextMutationAllowed: Bool
    public let responseWriteAllowed: Bool
    public let transportCommitAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        productionQueueMutationGateAccepted: Bool,
        runtimeQueueCommitBoundaryAccepted: Bool,
        runtimeQueueCommitBoundaryMode: String,
        productionQueueMutationGateMode: String,
        mutationGateId: String,
        commitBoundaryId: String,
        queueWriteId: String,
        queueDepthBefore: Int64,
        queueDepthAfter: Int64,
        mutationGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        productionQueueMutationGateAllowed: Bool,
        actualProductionQueueMutationAllowed: Bool,
        liveExecutorEnqueueAllowed: Bool,
        runtimeTaskSpawnAllowed: Bool,
        handlerInvocationAllowed: Bool,
        requestContextMutationAllowed: Bool,
        responseWriteAllowed: Bool,
        transportCommitAllowed: Bool,
        liveServerWiringAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.productionQueueMutationGateAccepted =
            productionQueueMutationGateAccepted
        this.runtimeQueueCommitBoundaryAccepted =
            runtimeQueueCommitBoundaryAccepted
        this.runtimeQueueCommitBoundaryMode =
            runtimeQueueCommitBoundaryMode
        this.productionQueueMutationGateMode =
            productionQueueMutationGateMode
        this.mutationGateId = mutationGateId
        this.commitBoundaryId = commitBoundaryId
        this.queueWriteId = queueWriteId
        this.queueDepthBefore = queueDepthBefore
        this.queueDepthAfter = queueDepthAfter
        this.mutationGateRecorded = mutationGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.productionQueueMutationGateAllowed =
            productionQueueMutationGateAllowed
        this.actualProductionQueueMutationAllowed =
            actualProductionQueueMutationAllowed
        this.liveExecutorEnqueueAllowed = liveExecutorEnqueueAllowed
        this.runtimeTaskSpawnAllowed = runtimeTaskSpawnAllowed
        this.handlerInvocationAllowed = handlerInvocationAllowed
        this.requestContextMutationAllowed = requestContextMutationAllowed
        this.responseWriteAllowed = responseWriteAllowed
        this.transportCommitAllowed = transportCommitAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteProductionQueueMutationGateReceipt(
    commitBoundaryReceipt: IgniteRuntimeQueueCommitBoundaryReceipt,
    request: IgniteProductionQueueMutationGateRequest
): IgniteProductionQueueMutationGateReceipt {
    let nonClaims = igniteProductionQueueMutationGateNonClaims()
    if (!commitBoundaryReceipt.runtimeQueueCommitBoundaryAccepted) {
        return IgniteProductionQueueMutationGateReceipt(
            false,
            commitBoundaryReceipt.runtimeQueueCommitBoundaryAccepted,
            commitBoundaryReceipt.runtimeQueueCommitBoundaryMode,
            "none",
            request.mutationGateId,
            commitBoundaryReceipt.commitBoundaryId,
            commitBoundaryReceipt.queueWriteId,
            commitBoundaryReceipt.queueDepthBefore,
            commitBoundaryReceipt.queueDepthAfter,
            false,
            "block",
            "blocked-runtime-queue-commit-boundary-receipt",
            "collect-accepted-runtime-queue-commit-boundary-receipt-first",
            ["RUNTIME_QUEUE_COMMIT_BOUNDARY_NOT_ACCEPTED"],
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
            "return to HQ-0462 runtime queue commit boundary input before production queue mutation gate work",
            "QUIC must not consume production queue mutation gate receipts from rejected queue commit boundaries"
        )
    }

    let gateMode = igniteProductionQueueMutationGateModeFor(
        commitBoundaryReceipt.runtimeQueueCommitBoundaryMode
    )
    let blockers = igniteProductionQueueMutationGateBlockers(
        request,
        gateMode
    )
    if (blockers.size > 0) {
        return IgniteProductionQueueMutationGateReceipt(
            false,
            commitBoundaryReceipt.runtimeQueueCommitBoundaryAccepted,
            commitBoundaryReceipt.runtimeQueueCommitBoundaryMode,
            gateMode,
            request.mutationGateId,
            commitBoundaryReceipt.commitBoundaryId,
            commitBoundaryReceipt.queueWriteId,
            commitBoundaryReceipt.queueDepthBefore,
            commitBoundaryReceipt.queueDepthAfter,
            false,
            "block",
            "blocked-production-queue-mutation-gate-input",
            "fix-production-queue-mutation-gate-before-mutation-dry-run",
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
            nonClaims,
            "carry mutation gate id, commit boundary snapshot, queue mutation intent, queue storage target, lane ownership, executor ownership, mutation rollback, backpressure fence, completion fence, and keep actual production queue mutation out",
            "QUIC can reuse the same production queue mutation gate blockers before stream task queue mutation dry-run"
        )
    }

    IgniteProductionQueueMutationGateReceipt(
        true,
        commitBoundaryReceipt.runtimeQueueCommitBoundaryAccepted,
        commitBoundaryReceipt.runtimeQueueCommitBoundaryMode,
        gateMode,
        request.mutationGateId,
        commitBoundaryReceipt.commitBoundaryId,
        commitBoundaryReceipt.queueWriteId,
        commitBoundaryReceipt.queueDepthBefore,
        commitBoundaryReceipt.queueDepthAfter,
        true,
        "record-production-queue-mutation-gate-receipt",
        "accepted-production-queue-mutation-gate-receipt",
        "record-production-queue-mutation-gate-without-actual-mutation",
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
        nonClaims,
        "next packet may plan production queue mutation dry-run without invoking user handlers or spawning production tasks",
        "QUIC can reuse lane-specific production queue mutation gate modes before live stream task queue mutation"
    )
}

func igniteProductionQueueMutationGateModeFor(
    commitBoundaryMode: String
): String {
    if (commitBoundaryMode == "short-runtime-queue-commit-boundary") {
        return "short-production-queue-mutation-gate"
    }
    if (commitBoundaryMode == "long-runtime-queue-commit-boundary") {
        return "long-production-queue-mutation-gate"
    }
    if (
        commitBoundaryMode ==
        "blocking-isolation-runtime-queue-commit-boundary"
    ) {
        return "blocking-isolation-production-queue-mutation-gate"
    }
    "unknown-production-queue-mutation-gate"
}

func igniteProductionQueueMutationGateBlockers(
    request: IgniteProductionQueueMutationGateRequest,
    gateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.mutationGateId.size == 0) {
        blockers.add("MUTATION_GATE_ID_NOT_CARRIED")
    }
    if (!request.commitBoundarySnapshotCarried) {
        blockers.add("COMMIT_BOUNDARY_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.queueMutationIntentCarried) {
        blockers.add("QUEUE_MUTATION_INTENT_NOT_CARRIED")
    }
    if (!request.queueStorageTargetCarried) {
        blockers.add("QUEUE_STORAGE_TARGET_NOT_CARRIED")
    }
    if (!request.laneOwnershipCarried) {
        blockers.add("LANE_OWNERSHIP_NOT_CARRIED")
    }
    if (!request.executorOwnershipCarried) {
        blockers.add("EXECUTOR_OWNERSHIP_NOT_CARRIED")
    }
    if (!request.mutationRollbackCarried) {
        blockers.add("MUTATION_ROLLBACK_NOT_CARRIED")
    }
    if (!request.backpressureFenceCarried) {
        blockers.add("BACKPRESSURE_FENCE_NOT_CARRIED")
    }
    if (!request.completionFenceCarried) {
        blockers.add("COMPLETION_FENCE_NOT_CARRIED")
    }
    if (request.actualProductionQueueMutationRequested) {
        blockers.add("ACTUAL_PRODUCTION_QUEUE_MUTATION_REQUESTED")
    }
    if (request.liveExecutorEnqueueRequested) {
        blockers.add("LIVE_EXECUTOR_ENQUEUE_REQUESTED")
    }
    if (request.runtimeTaskSpawnRequested) {
        blockers.add("RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.handlerInvocationRequested) {
        blockers.add("HANDLER_INVOCATION_REQUESTED")
    }
    if (request.requestContextMutationRequested) {
        blockers.add("REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.responseWriteRequested) {
        blockers.add("RESPONSE_WRITE_REQUESTED")
    }
    if (request.transportCommitRequested) {
        blockers.add("TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.liveServerWiringRequested) {
        blockers.add("LIVE_SERVER_WIRING_REQUESTED")
    }
    if (gateMode == "unknown-production-queue-mutation-gate") {
        blockers.add("UNKNOWN_PRODUCTION_QUEUE_MUTATION_GATE")
    }
    blockers.toArray()
}

func igniteProductionQueueMutationGateNonClaims(): Array<String> {
    [
        "NO_ACTUAL_PRODUCTION_QUEUE_MUTATION",
        "NO_LIVE_SERVER_WIRING",
        "NO_LIVE_EXECUTOR_ENQUEUE",
        "NO_HANDLER_INVOCATION",
        "NO_REQUEST_CONTEXT_MUTATION",
        "NO_RUNTIME_TASK_SPAWN",
        "NO_RESPONSE_WRITE",
        "NO_TRANSPORT_COMMIT",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
        "NO_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
    ]
}

public class IgniteProductionQueueMutationDryRunRequest {
    public let mutationDryRunId: String
    public let mutationGateSnapshotCarried: Bool
    public let queueStorageSnapshotCarried: Bool
    public let mutationWritePlanCarried: Bool
    public let queueDepthTransitionCarried: Bool
    public let laneTokenSnapshotCarried: Bool
    public let executorTokenSnapshotCarried: Bool
    public let rollbackSnapshotCarried: Bool
    public let backpressureLeaseCarried: Bool
    public let completionCallbackBoundaryCarried: Bool
    public let actualProductionQueueMutationRequested: Bool
    public let liveExecutorEnqueueRequested: Bool
    public let runtimeTaskSpawnRequested: Bool
    public let handlerInvocationRequested: Bool
    public let requestContextMutationRequested: Bool
    public let responseWriteRequested: Bool
    public let transportCommitRequested: Bool
    public let liveServerWiringRequested: Bool

    public init(
        mutationDryRunId: String,
        mutationGateSnapshotCarried: Bool,
        queueStorageSnapshotCarried: Bool,
        mutationWritePlanCarried: Bool,
        queueDepthTransitionCarried: Bool,
        laneTokenSnapshotCarried: Bool,
        executorTokenSnapshotCarried: Bool,
        rollbackSnapshotCarried: Bool,
        backpressureLeaseCarried: Bool,
        completionCallbackBoundaryCarried: Bool,
        actualProductionQueueMutationRequested: Bool,
        liveExecutorEnqueueRequested: Bool,
        runtimeTaskSpawnRequested: Bool,
        handlerInvocationRequested: Bool,
        requestContextMutationRequested: Bool,
        responseWriteRequested: Bool,
        transportCommitRequested: Bool,
        liveServerWiringRequested: Bool
    ) {
        this.mutationDryRunId = mutationDryRunId
        this.mutationGateSnapshotCarried =
            mutationGateSnapshotCarried
        this.queueStorageSnapshotCarried = queueStorageSnapshotCarried
        this.mutationWritePlanCarried = mutationWritePlanCarried
        this.queueDepthTransitionCarried = queueDepthTransitionCarried
        this.laneTokenSnapshotCarried = laneTokenSnapshotCarried
        this.executorTokenSnapshotCarried = executorTokenSnapshotCarried
        this.rollbackSnapshotCarried = rollbackSnapshotCarried
        this.backpressureLeaseCarried = backpressureLeaseCarried
        this.completionCallbackBoundaryCarried =
            completionCallbackBoundaryCarried
        this.actualProductionQueueMutationRequested =
            actualProductionQueueMutationRequested
        this.liveExecutorEnqueueRequested = liveExecutorEnqueueRequested
        this.runtimeTaskSpawnRequested = runtimeTaskSpawnRequested
        this.handlerInvocationRequested = handlerInvocationRequested
        this.requestContextMutationRequested = requestContextMutationRequested
        this.responseWriteRequested = responseWriteRequested
        this.transportCommitRequested = transportCommitRequested
        this.liveServerWiringRequested = liveServerWiringRequested
    }
}

public class IgniteProductionQueueMutationDryRunReceipt {
    public let productionQueueMutationDryRunAccepted: Bool
    public let productionQueueMutationGateAccepted: Bool
    public let productionQueueMutationGateMode: String
    public let productionQueueMutationDryRunMode: String
    public let mutationDryRunId: String
    public let mutationGateId: String
    public let commitBoundaryId: String
    public let queueWriteId: String
    public let queueDepthBefore: Int64
    public let queueDepthAfter: Int64
    public let mutationDryRunRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let productionQueueMutationDryRunAllowed: Bool
    public let actualProductionQueueMutationAllowed: Bool
    public let liveExecutorEnqueueAllowed: Bool
    public let runtimeTaskSpawnAllowed: Bool
    public let handlerInvocationAllowed: Bool
    public let requestContextMutationAllowed: Bool
    public let responseWriteAllowed: Bool
    public let transportCommitAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        productionQueueMutationDryRunAccepted: Bool,
        productionQueueMutationGateAccepted: Bool,
        productionQueueMutationGateMode: String,
        productionQueueMutationDryRunMode: String,
        mutationDryRunId: String,
        mutationGateId: String,
        commitBoundaryId: String,
        queueWriteId: String,
        queueDepthBefore: Int64,
        queueDepthAfter: Int64,
        mutationDryRunRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        productionQueueMutationDryRunAllowed: Bool,
        actualProductionQueueMutationAllowed: Bool,
        liveExecutorEnqueueAllowed: Bool,
        runtimeTaskSpawnAllowed: Bool,
        handlerInvocationAllowed: Bool,
        requestContextMutationAllowed: Bool,
        responseWriteAllowed: Bool,
        transportCommitAllowed: Bool,
        liveServerWiringAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.productionQueueMutationDryRunAccepted =
            productionQueueMutationDryRunAccepted
        this.productionQueueMutationGateAccepted =
            productionQueueMutationGateAccepted
        this.productionQueueMutationGateMode =
            productionQueueMutationGateMode
        this.productionQueueMutationDryRunMode =
            productionQueueMutationDryRunMode
        this.mutationDryRunId = mutationDryRunId
        this.mutationGateId = mutationGateId
        this.commitBoundaryId = commitBoundaryId
        this.queueWriteId = queueWriteId
        this.queueDepthBefore = queueDepthBefore
        this.queueDepthAfter = queueDepthAfter
        this.mutationDryRunRecorded = mutationDryRunRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.productionQueueMutationDryRunAllowed =
            productionQueueMutationDryRunAllowed
        this.actualProductionQueueMutationAllowed =
            actualProductionQueueMutationAllowed
        this.liveExecutorEnqueueAllowed = liveExecutorEnqueueAllowed
        this.runtimeTaskSpawnAllowed = runtimeTaskSpawnAllowed
        this.handlerInvocationAllowed = handlerInvocationAllowed
        this.requestContextMutationAllowed = requestContextMutationAllowed
        this.responseWriteAllowed = responseWriteAllowed
        this.transportCommitAllowed = transportCommitAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteProductionQueueMutationDryRunReceipt(
    gateReceipt: IgniteProductionQueueMutationGateReceipt,
    request: IgniteProductionQueueMutationDryRunRequest
): IgniteProductionQueueMutationDryRunReceipt {
    let nonClaims = igniteProductionQueueMutationDryRunNonClaims()
    if (!gateReceipt.productionQueueMutationGateAccepted) {
        return IgniteProductionQueueMutationDryRunReceipt(
            false,
            gateReceipt.productionQueueMutationGateAccepted,
            gateReceipt.productionQueueMutationGateMode,
            "none",
            request.mutationDryRunId,
            gateReceipt.mutationGateId,
            gateReceipt.commitBoundaryId,
            gateReceipt.queueWriteId,
            gateReceipt.queueDepthBefore,
            gateReceipt.queueDepthAfter,
            false,
            "block",
            "blocked-production-queue-mutation-gate-receipt",
            "collect-accepted-production-queue-mutation-gate-receipt-first",
            ["PRODUCTION_QUEUE_MUTATION_GATE_NOT_ACCEPTED"],
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
            "return to HQ-0463 production queue mutation gate input before mutation dry-run work",
            "QUIC must not consume production queue mutation dry-run receipts from rejected mutation gates"
        )
    }

    let dryRunMode = igniteProductionQueueMutationDryRunModeFor(
        gateReceipt.productionQueueMutationGateMode
    )
    let blockers = igniteProductionQueueMutationDryRunBlockers(
        request,
        dryRunMode
    )
    if (blockers.size > 0) {
        return IgniteProductionQueueMutationDryRunReceipt(
            false,
            gateReceipt.productionQueueMutationGateAccepted,
            gateReceipt.productionQueueMutationGateMode,
            dryRunMode,
            request.mutationDryRunId,
            gateReceipt.mutationGateId,
            gateReceipt.commitBoundaryId,
            gateReceipt.queueWriteId,
            gateReceipt.queueDepthBefore,
            gateReceipt.queueDepthAfter,
            false,
            "block",
            "blocked-production-queue-mutation-dry-run-input",
            "fix-production-queue-mutation-dry-run-before-mutation-commit-plan",
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
            nonClaims,
            "carry dry-run id, mutation gate snapshot, queue storage snapshot, mutation write plan, queue depth transition, lane token snapshot, executor token snapshot, rollback snapshot, backpressure lease, completion callback boundary, and keep actual production queue mutation out",
            "QUIC can reuse the same mutation dry-run blockers before stream task queue mutation commit planning"
        )
    }

    IgniteProductionQueueMutationDryRunReceipt(
        true,
        gateReceipt.productionQueueMutationGateAccepted,
        gateReceipt.productionQueueMutationGateMode,
        dryRunMode,
        request.mutationDryRunId,
        gateReceipt.mutationGateId,
        gateReceipt.commitBoundaryId,
        gateReceipt.queueWriteId,
        gateReceipt.queueDepthBefore,
        gateReceipt.queueDepthAfter,
        true,
        "record-production-queue-mutation-dry-run-receipt",
        "accepted-production-queue-mutation-dry-run-receipt",
        "record-production-queue-mutation-dry-run-without-actual-mutation",
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
        nonClaims,
        "next packet may plan production queue mutation commit-plan without invoking user handlers or spawning production tasks",
        "QUIC can reuse lane-specific production queue mutation dry-run modes before live stream task queue mutation"
    )
}

func igniteProductionQueueMutationDryRunModeFor(
    gateMode: String
): String {
    if (gateMode == "short-production-queue-mutation-gate") {
        return "short-production-queue-mutation-dry-run"
    }
    if (gateMode == "long-production-queue-mutation-gate") {
        return "long-production-queue-mutation-dry-run"
    }
    if (
        gateMode ==
        "blocking-isolation-production-queue-mutation-gate"
    ) {
        return "blocking-isolation-production-queue-mutation-dry-run"
    }
    "unknown-production-queue-mutation-dry-run"
}

func igniteProductionQueueMutationDryRunBlockers(
    request: IgniteProductionQueueMutationDryRunRequest,
    dryRunMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.mutationDryRunId.size == 0) {
        blockers.add("MUTATION_DRY_RUN_ID_NOT_CARRIED")
    }
    if (!request.mutationGateSnapshotCarried) {
        blockers.add("MUTATION_GATE_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.queueStorageSnapshotCarried) {
        blockers.add("QUEUE_STORAGE_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.mutationWritePlanCarried) {
        blockers.add("MUTATION_WRITE_PLAN_NOT_CARRIED")
    }
    if (!request.queueDepthTransitionCarried) {
        blockers.add("QUEUE_DEPTH_TRANSITION_NOT_CARRIED")
    }
    if (!request.laneTokenSnapshotCarried) {
        blockers.add("LANE_TOKEN_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.executorTokenSnapshotCarried) {
        blockers.add("EXECUTOR_TOKEN_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.rollbackSnapshotCarried) {
        blockers.add("ROLLBACK_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.backpressureLeaseCarried) {
        blockers.add("BACKPRESSURE_LEASE_NOT_CARRIED")
    }
    if (!request.completionCallbackBoundaryCarried) {
        blockers.add("COMPLETION_CALLBACK_BOUNDARY_NOT_CARRIED")
    }
    if (request.actualProductionQueueMutationRequested) {
        blockers.add("ACTUAL_PRODUCTION_QUEUE_MUTATION_REQUESTED")
    }
    if (request.liveExecutorEnqueueRequested) {
        blockers.add("LIVE_EXECUTOR_ENQUEUE_REQUESTED")
    }
    if (request.runtimeTaskSpawnRequested) {
        blockers.add("RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.handlerInvocationRequested) {
        blockers.add("HANDLER_INVOCATION_REQUESTED")
    }
    if (request.requestContextMutationRequested) {
        blockers.add("REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.responseWriteRequested) {
        blockers.add("RESPONSE_WRITE_REQUESTED")
    }
    if (request.transportCommitRequested) {
        blockers.add("TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.liveServerWiringRequested) {
        blockers.add("LIVE_SERVER_WIRING_REQUESTED")
    }
    if (dryRunMode == "unknown-production-queue-mutation-dry-run") {
        blockers.add("UNKNOWN_PRODUCTION_QUEUE_MUTATION_DRY_RUN")
    }
    blockers.toArray()
}

func igniteProductionQueueMutationDryRunNonClaims(): Array<String> {
    [
        "NO_ACTUAL_PRODUCTION_QUEUE_MUTATION",
        "NO_LIVE_SERVER_WIRING",
        "NO_LIVE_EXECUTOR_ENQUEUE",
        "NO_HANDLER_INVOCATION",
        "NO_REQUEST_CONTEXT_MUTATION",
        "NO_RUNTIME_TASK_SPAWN",
        "NO_RESPONSE_WRITE",
        "NO_TRANSPORT_COMMIT",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
        "NO_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
    ]
}

public class IgniteProductionQueueMutationCommitPlanRequest {
    public let mutationCommitPlanId: String
    public let dryRunSnapshotCarried: Bool
    public let queueMutationOperationCarried: Bool
    public let queueOwnerTokenCarried: Bool
    public let queueSlotReservationCarried: Bool
    public let queueDepthExpectationCarried: Bool
    public let rollbackPlanCarried: Bool
    public let fallbackPlanCarried: Bool
    public let completionCallbackBoundaryCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let actualProductionQueueMutationRequested: Bool
    public let liveExecutorEnqueueRequested: Bool
    public let runtimeTaskSpawnRequested: Bool
    public let handlerInvocationRequested: Bool
    public let requestContextMutationRequested: Bool
    public let responseWriteRequested: Bool
    public let transportCommitRequested: Bool
    public let liveServerWiringRequested: Bool

    public init(
        mutationCommitPlanId: String,
        dryRunSnapshotCarried: Bool,
        queueMutationOperationCarried: Bool,
        queueOwnerTokenCarried: Bool,
        queueSlotReservationCarried: Bool,
        queueDepthExpectationCarried: Bool,
        rollbackPlanCarried: Bool,
        fallbackPlanCarried: Bool,
        completionCallbackBoundaryCarried: Bool,
        observabilityMarkerCarried: Bool,
        actualProductionQueueMutationRequested: Bool,
        liveExecutorEnqueueRequested: Bool,
        runtimeTaskSpawnRequested: Bool,
        handlerInvocationRequested: Bool,
        requestContextMutationRequested: Bool,
        responseWriteRequested: Bool,
        transportCommitRequested: Bool,
        liveServerWiringRequested: Bool
    ) {
        this.mutationCommitPlanId = mutationCommitPlanId
        this.dryRunSnapshotCarried = dryRunSnapshotCarried
        this.queueMutationOperationCarried = queueMutationOperationCarried
        this.queueOwnerTokenCarried = queueOwnerTokenCarried
        this.queueSlotReservationCarried = queueSlotReservationCarried
        this.queueDepthExpectationCarried = queueDepthExpectationCarried
        this.rollbackPlanCarried = rollbackPlanCarried
        this.fallbackPlanCarried = fallbackPlanCarried
        this.completionCallbackBoundaryCarried =
            completionCallbackBoundaryCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
        this.actualProductionQueueMutationRequested =
            actualProductionQueueMutationRequested
        this.liveExecutorEnqueueRequested = liveExecutorEnqueueRequested
        this.runtimeTaskSpawnRequested = runtimeTaskSpawnRequested
        this.handlerInvocationRequested = handlerInvocationRequested
        this.requestContextMutationRequested = requestContextMutationRequested
        this.responseWriteRequested = responseWriteRequested
        this.transportCommitRequested = transportCommitRequested
        this.liveServerWiringRequested = liveServerWiringRequested
    }
}

public class IgniteProductionQueueMutationCommitPlanReceipt {
    public let productionQueueMutationCommitPlanAccepted: Bool
    public let productionQueueMutationDryRunAccepted: Bool
    public let productionQueueMutationDryRunMode: String
    public let productionQueueMutationCommitPlanMode: String
    public let mutationCommitPlanId: String
    public let mutationDryRunId: String
    public let mutationGateId: String
    public let commitBoundaryId: String
    public let queueWriteId: String
    public let queueDepthBefore: Int64
    public let queueDepthAfter: Int64
    public let commitPlanRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let productionQueueMutationCommitPlanAllowed: Bool
    public let actualProductionQueueMutationAllowed: Bool
    public let liveExecutorEnqueueAllowed: Bool
    public let runtimeTaskSpawnAllowed: Bool
    public let handlerInvocationAllowed: Bool
    public let requestContextMutationAllowed: Bool
    public let responseWriteAllowed: Bool
    public let transportCommitAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        productionQueueMutationCommitPlanAccepted: Bool,
        productionQueueMutationDryRunAccepted: Bool,
        productionQueueMutationDryRunMode: String,
        productionQueueMutationCommitPlanMode: String,
        mutationCommitPlanId: String,
        mutationDryRunId: String,
        mutationGateId: String,
        commitBoundaryId: String,
        queueWriteId: String,
        queueDepthBefore: Int64,
        queueDepthAfter: Int64,
        commitPlanRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        productionQueueMutationCommitPlanAllowed: Bool,
        actualProductionQueueMutationAllowed: Bool,
        liveExecutorEnqueueAllowed: Bool,
        runtimeTaskSpawnAllowed: Bool,
        handlerInvocationAllowed: Bool,
        requestContextMutationAllowed: Bool,
        responseWriteAllowed: Bool,
        transportCommitAllowed: Bool,
        liveServerWiringAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.productionQueueMutationCommitPlanAccepted =
            productionQueueMutationCommitPlanAccepted
        this.productionQueueMutationDryRunAccepted =
            productionQueueMutationDryRunAccepted
        this.productionQueueMutationDryRunMode =
            productionQueueMutationDryRunMode
        this.productionQueueMutationCommitPlanMode =
            productionQueueMutationCommitPlanMode
        this.mutationCommitPlanId = mutationCommitPlanId
        this.mutationDryRunId = mutationDryRunId
        this.mutationGateId = mutationGateId
        this.commitBoundaryId = commitBoundaryId
        this.queueWriteId = queueWriteId
        this.queueDepthBefore = queueDepthBefore
        this.queueDepthAfter = queueDepthAfter
        this.commitPlanRecorded = commitPlanRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.productionQueueMutationCommitPlanAllowed =
            productionQueueMutationCommitPlanAllowed
        this.actualProductionQueueMutationAllowed =
            actualProductionQueueMutationAllowed
        this.liveExecutorEnqueueAllowed = liveExecutorEnqueueAllowed
        this.runtimeTaskSpawnAllowed = runtimeTaskSpawnAllowed
        this.handlerInvocationAllowed = handlerInvocationAllowed
        this.requestContextMutationAllowed = requestContextMutationAllowed
        this.responseWriteAllowed = responseWriteAllowed
        this.transportCommitAllowed = transportCommitAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteProductionQueueMutationCommitPlanReceipt(
    dryRunReceipt: IgniteProductionQueueMutationDryRunReceipt,
    request: IgniteProductionQueueMutationCommitPlanRequest
): IgniteProductionQueueMutationCommitPlanReceipt {
    let nonClaims = igniteProductionQueueMutationCommitPlanNonClaims()
    if (!dryRunReceipt.productionQueueMutationDryRunAccepted) {
        return IgniteProductionQueueMutationCommitPlanReceipt(
            false,
            dryRunReceipt.productionQueueMutationDryRunAccepted,
            dryRunReceipt.productionQueueMutationDryRunMode,
            "none",
            request.mutationCommitPlanId,
            dryRunReceipt.mutationDryRunId,
            dryRunReceipt.mutationGateId,
            dryRunReceipt.commitBoundaryId,
            dryRunReceipt.queueWriteId,
            dryRunReceipt.queueDepthBefore,
            dryRunReceipt.queueDepthAfter,
            false,
            "block",
            "blocked-production-queue-mutation-dry-run-receipt",
            "collect-accepted-production-queue-mutation-dry-run-receipt-first",
            ["PRODUCTION_QUEUE_MUTATION_DRY_RUN_NOT_ACCEPTED"],
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
            "return to HQ-0464 production queue mutation dry-run input before commit-plan work",
            "QUIC must not consume production queue mutation commit-plan receipts from rejected mutation dry-runs"
        )
    }

    let commitPlanMode = igniteProductionQueueMutationCommitPlanModeFor(
        dryRunReceipt.productionQueueMutationDryRunMode
    )
    let blockers = igniteProductionQueueMutationCommitPlanBlockers(
        request,
        commitPlanMode
    )
    if (blockers.size > 0) {
        return IgniteProductionQueueMutationCommitPlanReceipt(
            false,
            dryRunReceipt.productionQueueMutationDryRunAccepted,
            dryRunReceipt.productionQueueMutationDryRunMode,
            commitPlanMode,
            request.mutationCommitPlanId,
            dryRunReceipt.mutationDryRunId,
            dryRunReceipt.mutationGateId,
            dryRunReceipt.commitBoundaryId,
            dryRunReceipt.queueWriteId,
            dryRunReceipt.queueDepthBefore,
            dryRunReceipt.queueDepthAfter,
            false,
            "block",
            "blocked-production-queue-mutation-commit-plan-input",
            "fix-production-queue-mutation-commit-plan-before-apply-gate",
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
            nonClaims,
            "carry commit-plan id, dry-run snapshot, queue mutation operation, queue owner token, queue slot reservation, queue depth expectation, rollback plan, fallback plan, completion callback boundary, observability marker, and keep actual production queue mutation out",
            "QUIC can reuse the same mutation commit-plan blockers before stream task queue mutation apply-gating"
        )
    }

    IgniteProductionQueueMutationCommitPlanReceipt(
        true,
        dryRunReceipt.productionQueueMutationDryRunAccepted,
        dryRunReceipt.productionQueueMutationDryRunMode,
        commitPlanMode,
        request.mutationCommitPlanId,
        dryRunReceipt.mutationDryRunId,
        dryRunReceipt.mutationGateId,
        dryRunReceipt.commitBoundaryId,
        dryRunReceipt.queueWriteId,
        dryRunReceipt.queueDepthBefore,
        dryRunReceipt.queueDepthAfter,
        true,
        "record-production-queue-mutation-commit-plan-receipt",
        "accepted-production-queue-mutation-commit-plan-receipt",
        "record-production-queue-mutation-commit-plan-without-actual-mutation",
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
        nonClaims,
        "next packet may plan production queue mutation apply-gate without invoking user handlers or spawning production tasks",
        "QUIC can reuse lane-specific production queue mutation commit-plan modes before live stream task queue mutation"
    )
}

func igniteProductionQueueMutationCommitPlanModeFor(
    dryRunMode: String
): String {
    if (dryRunMode == "short-production-queue-mutation-dry-run") {
        return "short-production-queue-mutation-commit-plan"
    }
    if (dryRunMode == "long-production-queue-mutation-dry-run") {
        return "long-production-queue-mutation-commit-plan"
    }
    if (
        dryRunMode ==
        "blocking-isolation-production-queue-mutation-dry-run"
    ) {
        return "blocking-isolation-production-queue-mutation-commit-plan"
    }
    "unknown-production-queue-mutation-commit-plan"
}

func igniteProductionQueueMutationCommitPlanBlockers(
    request: IgniteProductionQueueMutationCommitPlanRequest,
    commitPlanMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.mutationCommitPlanId.size == 0) {
        blockers.add("MUTATION_COMMIT_PLAN_ID_NOT_CARRIED")
    }
    if (!request.dryRunSnapshotCarried) {
        blockers.add("DRY_RUN_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.queueMutationOperationCarried) {
        blockers.add("QUEUE_MUTATION_OPERATION_NOT_CARRIED")
    }
    if (!request.queueOwnerTokenCarried) {
        blockers.add("QUEUE_OWNER_TOKEN_NOT_CARRIED")
    }
    if (!request.queueSlotReservationCarried) {
        blockers.add("QUEUE_SLOT_RESERVATION_NOT_CARRIED")
    }
    if (!request.queueDepthExpectationCarried) {
        blockers.add("QUEUE_DEPTH_EXPECTATION_NOT_CARRIED")
    }
    if (!request.rollbackPlanCarried) {
        blockers.add("ROLLBACK_PLAN_NOT_CARRIED")
    }
    if (!request.fallbackPlanCarried) {
        blockers.add("FALLBACK_PLAN_NOT_CARRIED")
    }
    if (!request.completionCallbackBoundaryCarried) {
        blockers.add("COMPLETION_CALLBACK_BOUNDARY_NOT_CARRIED")
    }
    if (!request.observabilityMarkerCarried) {
        blockers.add("OBSERVABILITY_MARKER_NOT_CARRIED")
    }
    if (request.actualProductionQueueMutationRequested) {
        blockers.add("ACTUAL_PRODUCTION_QUEUE_MUTATION_REQUESTED")
    }
    if (request.liveExecutorEnqueueRequested) {
        blockers.add("LIVE_EXECUTOR_ENQUEUE_REQUESTED")
    }
    if (request.runtimeTaskSpawnRequested) {
        blockers.add("RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.handlerInvocationRequested) {
        blockers.add("HANDLER_INVOCATION_REQUESTED")
    }
    if (request.requestContextMutationRequested) {
        blockers.add("REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.responseWriteRequested) {
        blockers.add("RESPONSE_WRITE_REQUESTED")
    }
    if (request.transportCommitRequested) {
        blockers.add("TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.liveServerWiringRequested) {
        blockers.add("LIVE_SERVER_WIRING_REQUESTED")
    }
    if (commitPlanMode == "unknown-production-queue-mutation-commit-plan") {
        blockers.add("UNKNOWN_PRODUCTION_QUEUE_MUTATION_COMMIT_PLAN")
    }
    blockers.toArray()
}

func igniteProductionQueueMutationCommitPlanNonClaims(): Array<String> {
    [
        "NO_ACTUAL_PRODUCTION_QUEUE_MUTATION",
        "NO_LIVE_SERVER_WIRING",
        "NO_LIVE_EXECUTOR_ENQUEUE",
        "NO_HANDLER_INVOCATION",
        "NO_REQUEST_CONTEXT_MUTATION",
        "NO_RUNTIME_TASK_SPAWN",
        "NO_RESPONSE_WRITE",
        "NO_TRANSPORT_COMMIT",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
        "NO_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
    ]
}

public class IgniteProductionQueueMutationApplyGateRequest {
    public let mutationApplyGateId: String
    public let commitPlanSnapshotCarried: Bool
    public let applyPermissionTokenCarried: Bool
    public let queueMutationGuardCarried: Bool
    public let queueStatePrecheckCarried: Bool
    public let rollbackCheckpointCarried: Bool
    public let fallbackPathCarried: Bool
    public let idempotencyKeyCarried: Bool
    public let completionFenceCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let actualProductionQueueMutationRequested: Bool
    public let liveExecutorEnqueueRequested: Bool
    public let runtimeTaskSpawnRequested: Bool
    public let handlerInvocationRequested: Bool
    public let requestContextMutationRequested: Bool
    public let responseWriteRequested: Bool
    public let transportCommitRequested: Bool
    public let liveServerWiringRequested: Bool

    public init(
        mutationApplyGateId: String,
        commitPlanSnapshotCarried: Bool,
        applyPermissionTokenCarried: Bool,
        queueMutationGuardCarried: Bool,
        queueStatePrecheckCarried: Bool,
        rollbackCheckpointCarried: Bool,
        fallbackPathCarried: Bool,
        idempotencyKeyCarried: Bool,
        completionFenceCarried: Bool,
        observabilityMarkerCarried: Bool,
        actualProductionQueueMutationRequested: Bool,
        liveExecutorEnqueueRequested: Bool,
        runtimeTaskSpawnRequested: Bool,
        handlerInvocationRequested: Bool,
        requestContextMutationRequested: Bool,
        responseWriteRequested: Bool,
        transportCommitRequested: Bool,
        liveServerWiringRequested: Bool
    ) {
        this.mutationApplyGateId = mutationApplyGateId
        this.commitPlanSnapshotCarried = commitPlanSnapshotCarried
        this.applyPermissionTokenCarried = applyPermissionTokenCarried
        this.queueMutationGuardCarried = queueMutationGuardCarried
        this.queueStatePrecheckCarried = queueStatePrecheckCarried
        this.rollbackCheckpointCarried = rollbackCheckpointCarried
        this.fallbackPathCarried = fallbackPathCarried
        this.idempotencyKeyCarried = idempotencyKeyCarried
        this.completionFenceCarried = completionFenceCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
        this.actualProductionQueueMutationRequested =
            actualProductionQueueMutationRequested
        this.liveExecutorEnqueueRequested = liveExecutorEnqueueRequested
        this.runtimeTaskSpawnRequested = runtimeTaskSpawnRequested
        this.handlerInvocationRequested = handlerInvocationRequested
        this.requestContextMutationRequested = requestContextMutationRequested
        this.responseWriteRequested = responseWriteRequested
        this.transportCommitRequested = transportCommitRequested
        this.liveServerWiringRequested = liveServerWiringRequested
    }
}

public class IgniteProductionQueueMutationApplyGateReceipt {
    public let productionQueueMutationApplyGateAccepted: Bool
    public let productionQueueMutationCommitPlanAccepted: Bool
    public let productionQueueMutationCommitPlanMode: String
    public let productionQueueMutationApplyGateMode: String
    public let mutationApplyGateId: String
    public let mutationCommitPlanId: String
    public let mutationDryRunId: String
    public let mutationGateId: String
    public let commitBoundaryId: String
    public let queueWriteId: String
    public let queueDepthBefore: Int64
    public let queueDepthAfter: Int64
    public let applyGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let productionQueueMutationApplyGateAllowed: Bool
    public let actualProductionQueueMutationAllowed: Bool
    public let liveExecutorEnqueueAllowed: Bool
    public let runtimeTaskSpawnAllowed: Bool
    public let handlerInvocationAllowed: Bool
    public let requestContextMutationAllowed: Bool
    public let responseWriteAllowed: Bool
    public let transportCommitAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        productionQueueMutationApplyGateAccepted: Bool,
        productionQueueMutationCommitPlanAccepted: Bool,
        productionQueueMutationCommitPlanMode: String,
        productionQueueMutationApplyGateMode: String,
        mutationApplyGateId: String,
        mutationCommitPlanId: String,
        mutationDryRunId: String,
        mutationGateId: String,
        commitBoundaryId: String,
        queueWriteId: String,
        queueDepthBefore: Int64,
        queueDepthAfter: Int64,
        applyGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        productionQueueMutationApplyGateAllowed: Bool,
        actualProductionQueueMutationAllowed: Bool,
        liveExecutorEnqueueAllowed: Bool,
        runtimeTaskSpawnAllowed: Bool,
        handlerInvocationAllowed: Bool,
        requestContextMutationAllowed: Bool,
        responseWriteAllowed: Bool,
        transportCommitAllowed: Bool,
        liveServerWiringAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.productionQueueMutationApplyGateAccepted =
            productionQueueMutationApplyGateAccepted
        this.productionQueueMutationCommitPlanAccepted =
            productionQueueMutationCommitPlanAccepted
        this.productionQueueMutationCommitPlanMode =
            productionQueueMutationCommitPlanMode
        this.productionQueueMutationApplyGateMode =
            productionQueueMutationApplyGateMode
        this.mutationApplyGateId = mutationApplyGateId
        this.mutationCommitPlanId = mutationCommitPlanId
        this.mutationDryRunId = mutationDryRunId
        this.mutationGateId = mutationGateId
        this.commitBoundaryId = commitBoundaryId
        this.queueWriteId = queueWriteId
        this.queueDepthBefore = queueDepthBefore
        this.queueDepthAfter = queueDepthAfter
        this.applyGateRecorded = applyGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.productionQueueMutationApplyGateAllowed =
            productionQueueMutationApplyGateAllowed
        this.actualProductionQueueMutationAllowed =
            actualProductionQueueMutationAllowed
        this.liveExecutorEnqueueAllowed = liveExecutorEnqueueAllowed
        this.runtimeTaskSpawnAllowed = runtimeTaskSpawnAllowed
        this.handlerInvocationAllowed = handlerInvocationAllowed
        this.requestContextMutationAllowed = requestContextMutationAllowed
        this.responseWriteAllowed = responseWriteAllowed
        this.transportCommitAllowed = transportCommitAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteProductionQueueMutationApplyGateReceipt(
    commitPlanReceipt: IgniteProductionQueueMutationCommitPlanReceipt,
    request: IgniteProductionQueueMutationApplyGateRequest
): IgniteProductionQueueMutationApplyGateReceipt {
    let nonClaims = igniteProductionQueueMutationApplyGateNonClaims()
    if (!commitPlanReceipt.productionQueueMutationCommitPlanAccepted) {
        return IgniteProductionQueueMutationApplyGateReceipt(
            false,
            commitPlanReceipt.productionQueueMutationCommitPlanAccepted,
            commitPlanReceipt.productionQueueMutationCommitPlanMode,
            "none",
            request.mutationApplyGateId,
            commitPlanReceipt.mutationCommitPlanId,
            commitPlanReceipt.mutationDryRunId,
            commitPlanReceipt.mutationGateId,
            commitPlanReceipt.commitBoundaryId,
            commitPlanReceipt.queueWriteId,
            commitPlanReceipt.queueDepthBefore,
            commitPlanReceipt.queueDepthAfter,
            false,
            "block",
            "blocked-production-queue-mutation-commit-plan-receipt",
            "collect-accepted-production-queue-mutation-commit-plan-receipt-first",
            ["PRODUCTION_QUEUE_MUTATION_COMMIT_PLAN_NOT_ACCEPTED"],
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
            "return to HQ-0465 production queue mutation commit-plan input before apply-gate work",
            "QUIC must not consume production queue mutation apply-gate receipts from rejected mutation commit-plans"
        )
    }

    let applyGateMode = igniteProductionQueueMutationApplyGateModeFor(
        commitPlanReceipt.productionQueueMutationCommitPlanMode
    )
    let blockers = igniteProductionQueueMutationApplyGateBlockers(
        request,
        applyGateMode
    )
    if (blockers.size > 0) {
        return IgniteProductionQueueMutationApplyGateReceipt(
            false,
            commitPlanReceipt.productionQueueMutationCommitPlanAccepted,
            commitPlanReceipt.productionQueueMutationCommitPlanMode,
            applyGateMode,
            request.mutationApplyGateId,
            commitPlanReceipt.mutationCommitPlanId,
            commitPlanReceipt.mutationDryRunId,
            commitPlanReceipt.mutationGateId,
            commitPlanReceipt.commitBoundaryId,
            commitPlanReceipt.queueWriteId,
            commitPlanReceipt.queueDepthBefore,
            commitPlanReceipt.queueDepthAfter,
            false,
            "block",
            "blocked-production-queue-mutation-apply-gate-input",
            "fix-production-queue-mutation-apply-gate-before-controlled-apply",
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
            nonClaims,
            "carry apply-gate id, commit-plan snapshot, apply permission token, queue mutation guard, queue state precheck, rollback checkpoint, fallback path, idempotency key, completion fence, observability marker, and keep actual production queue mutation out",
            "QUIC can reuse the same mutation apply-gate blockers before stream task queue controlled apply"
        )
    }

    IgniteProductionQueueMutationApplyGateReceipt(
        true,
        commitPlanReceipt.productionQueueMutationCommitPlanAccepted,
        commitPlanReceipt.productionQueueMutationCommitPlanMode,
        applyGateMode,
        request.mutationApplyGateId,
        commitPlanReceipt.mutationCommitPlanId,
        commitPlanReceipt.mutationDryRunId,
        commitPlanReceipt.mutationGateId,
        commitPlanReceipt.commitBoundaryId,
        commitPlanReceipt.queueWriteId,
        commitPlanReceipt.queueDepthBefore,
        commitPlanReceipt.queueDepthAfter,
        true,
        "record-production-queue-mutation-apply-gate-receipt",
        "accepted-production-queue-mutation-apply-gate-receipt",
        "record-production-queue-mutation-apply-gate-without-actual-mutation",
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
        nonClaims,
        "next packet may plan controlled production queue mutation apply without invoking user handlers or spawning production tasks",
        "QUIC can reuse lane-specific production queue mutation apply-gate modes before live stream task queue mutation"
    )
}

func igniteProductionQueueMutationApplyGateModeFor(
    commitPlanMode: String
): String {
    if (commitPlanMode == "short-production-queue-mutation-commit-plan") {
        return "short-production-queue-mutation-apply-gate"
    }
    if (commitPlanMode == "long-production-queue-mutation-commit-plan") {
        return "long-production-queue-mutation-apply-gate"
    }
    if (
        commitPlanMode ==
        "blocking-isolation-production-queue-mutation-commit-plan"
    ) {
        return "blocking-isolation-production-queue-mutation-apply-gate"
    }
    "unknown-production-queue-mutation-apply-gate"
}

func igniteProductionQueueMutationApplyGateBlockers(
    request: IgniteProductionQueueMutationApplyGateRequest,
    applyGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.mutationApplyGateId.size == 0) {
        blockers.add("MUTATION_APPLY_GATE_ID_NOT_CARRIED")
    }
    if (!request.commitPlanSnapshotCarried) {
        blockers.add("COMMIT_PLAN_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.applyPermissionTokenCarried) {
        blockers.add("APPLY_PERMISSION_TOKEN_NOT_CARRIED")
    }
    if (!request.queueMutationGuardCarried) {
        blockers.add("QUEUE_MUTATION_GUARD_NOT_CARRIED")
    }
    if (!request.queueStatePrecheckCarried) {
        blockers.add("QUEUE_STATE_PRECHECK_NOT_CARRIED")
    }
    if (!request.rollbackCheckpointCarried) {
        blockers.add("ROLLBACK_CHECKPOINT_NOT_CARRIED")
    }
    if (!request.fallbackPathCarried) {
        blockers.add("FALLBACK_PATH_NOT_CARRIED")
    }
    if (!request.idempotencyKeyCarried) {
        blockers.add("IDEMPOTENCY_KEY_NOT_CARRIED")
    }
    if (!request.completionFenceCarried) {
        blockers.add("COMPLETION_FENCE_NOT_CARRIED")
    }
    if (!request.observabilityMarkerCarried) {
        blockers.add("OBSERVABILITY_MARKER_NOT_CARRIED")
    }
    if (request.actualProductionQueueMutationRequested) {
        blockers.add("ACTUAL_PRODUCTION_QUEUE_MUTATION_REQUESTED")
    }
    if (request.liveExecutorEnqueueRequested) {
        blockers.add("LIVE_EXECUTOR_ENQUEUE_REQUESTED")
    }
    if (request.runtimeTaskSpawnRequested) {
        blockers.add("RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.handlerInvocationRequested) {
        blockers.add("HANDLER_INVOCATION_REQUESTED")
    }
    if (request.requestContextMutationRequested) {
        blockers.add("REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.responseWriteRequested) {
        blockers.add("RESPONSE_WRITE_REQUESTED")
    }
    if (request.transportCommitRequested) {
        blockers.add("TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.liveServerWiringRequested) {
        blockers.add("LIVE_SERVER_WIRING_REQUESTED")
    }
    if (applyGateMode == "unknown-production-queue-mutation-apply-gate") {
        blockers.add("UNKNOWN_PRODUCTION_QUEUE_MUTATION_APPLY_GATE")
    }
    blockers.toArray()
}

func igniteProductionQueueMutationApplyGateNonClaims(): Array<String> {
    [
        "NO_ACTUAL_PRODUCTION_QUEUE_MUTATION",
        "NO_LIVE_SERVER_WIRING",
        "NO_LIVE_EXECUTOR_ENQUEUE",
        "NO_HANDLER_INVOCATION",
        "NO_REQUEST_CONTEXT_MUTATION",
        "NO_RUNTIME_TASK_SPAWN",
        "NO_RESPONSE_WRITE",
        "NO_TRANSPORT_COMMIT",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
        "NO_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
    ]
}

public class IgniteControlledProductionQueueMutationApplyRequest {
    public let controlledMutationApplyId: String
    public let applyGateSnapshotCarried: Bool
    public let mutationLeaseCarried: Bool
    public let queueSlotOwnershipCarried: Bool
    public let queueDepthTransitionCarried: Bool
    public let rollbackArmedCarried: Bool
    public let fallbackArmedCarried: Bool
    public let idempotencyConfirmed: Bool
    public let completionFenceCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let liveExecutorEnqueueRequested: Bool
    public let runtimeTaskSpawnRequested: Bool
    public let handlerInvocationRequested: Bool
    public let requestContextMutationRequested: Bool
    public let responseWriteRequested: Bool
    public let transportCommitRequested: Bool
    public let liveServerWiringRequested: Bool

    public init(
        controlledMutationApplyId: String,
        applyGateSnapshotCarried: Bool,
        mutationLeaseCarried: Bool,
        queueSlotOwnershipCarried: Bool,
        queueDepthTransitionCarried: Bool,
        rollbackArmedCarried: Bool,
        fallbackArmedCarried: Bool,
        idempotencyConfirmed: Bool,
        completionFenceCarried: Bool,
        observabilityMarkerCarried: Bool,
        liveExecutorEnqueueRequested: Bool,
        runtimeTaskSpawnRequested: Bool,
        handlerInvocationRequested: Bool,
        requestContextMutationRequested: Bool,
        responseWriteRequested: Bool,
        transportCommitRequested: Bool,
        liveServerWiringRequested: Bool
    ) {
        this.controlledMutationApplyId = controlledMutationApplyId
        this.applyGateSnapshotCarried = applyGateSnapshotCarried
        this.mutationLeaseCarried = mutationLeaseCarried
        this.queueSlotOwnershipCarried = queueSlotOwnershipCarried
        this.queueDepthTransitionCarried = queueDepthTransitionCarried
        this.rollbackArmedCarried = rollbackArmedCarried
        this.fallbackArmedCarried = fallbackArmedCarried
        this.idempotencyConfirmed = idempotencyConfirmed
        this.completionFenceCarried = completionFenceCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
        this.liveExecutorEnqueueRequested = liveExecutorEnqueueRequested
        this.runtimeTaskSpawnRequested = runtimeTaskSpawnRequested
        this.handlerInvocationRequested = handlerInvocationRequested
        this.requestContextMutationRequested = requestContextMutationRequested
        this.responseWriteRequested = responseWriteRequested
        this.transportCommitRequested = transportCommitRequested
        this.liveServerWiringRequested = liveServerWiringRequested
    }
}

public class IgniteControlledProductionQueueMutationApplyReceipt {
    public let controlledProductionQueueMutationApplyAccepted: Bool
    public let productionQueueMutationApplyGateAccepted: Bool
    public let productionQueueMutationApplyGateMode: String
    public let controlledProductionQueueMutationApplyMode: String
    public let controlledMutationApplyId: String
    public let mutationApplyGateId: String
    public let mutationCommitPlanId: String
    public let mutationDryRunId: String
    public let mutationGateId: String
    public let commitBoundaryId: String
    public let queueWriteId: String
    public let queueDepthBefore: Int64
    public let queueDepthAfter: Int64
    public let controlledApplyRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let controlledProductionQueueMutationApplyAllowed: Bool
    public let liveExecutorEnqueueAllowed: Bool
    public let runtimeTaskSpawnAllowed: Bool
    public let handlerInvocationAllowed: Bool
    public let requestContextMutationAllowed: Bool
    public let responseWriteAllowed: Bool
    public let transportCommitAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        controlledProductionQueueMutationApplyAccepted: Bool,
        productionQueueMutationApplyGateAccepted: Bool,
        productionQueueMutationApplyGateMode: String,
        controlledProductionQueueMutationApplyMode: String,
        controlledMutationApplyId: String,
        mutationApplyGateId: String,
        mutationCommitPlanId: String,
        mutationDryRunId: String,
        mutationGateId: String,
        commitBoundaryId: String,
        queueWriteId: String,
        queueDepthBefore: Int64,
        queueDepthAfter: Int64,
        controlledApplyRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        controlledProductionQueueMutationApplyAllowed: Bool,
        liveExecutorEnqueueAllowed: Bool,
        runtimeTaskSpawnAllowed: Bool,
        handlerInvocationAllowed: Bool,
        requestContextMutationAllowed: Bool,
        responseWriteAllowed: Bool,
        transportCommitAllowed: Bool,
        liveServerWiringAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.controlledProductionQueueMutationApplyAccepted =
            controlledProductionQueueMutationApplyAccepted
        this.productionQueueMutationApplyGateAccepted =
            productionQueueMutationApplyGateAccepted
        this.productionQueueMutationApplyGateMode =
            productionQueueMutationApplyGateMode
        this.controlledProductionQueueMutationApplyMode =
            controlledProductionQueueMutationApplyMode
        this.controlledMutationApplyId = controlledMutationApplyId
        this.mutationApplyGateId = mutationApplyGateId
        this.mutationCommitPlanId = mutationCommitPlanId
        this.mutationDryRunId = mutationDryRunId
        this.mutationGateId = mutationGateId
        this.commitBoundaryId = commitBoundaryId
        this.queueWriteId = queueWriteId
        this.queueDepthBefore = queueDepthBefore
        this.queueDepthAfter = queueDepthAfter
        this.controlledApplyRecorded = controlledApplyRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.controlledProductionQueueMutationApplyAllowed =
            controlledProductionQueueMutationApplyAllowed
        this.liveExecutorEnqueueAllowed = liveExecutorEnqueueAllowed
        this.runtimeTaskSpawnAllowed = runtimeTaskSpawnAllowed
        this.handlerInvocationAllowed = handlerInvocationAllowed
        this.requestContextMutationAllowed = requestContextMutationAllowed
        this.responseWriteAllowed = responseWriteAllowed
        this.transportCommitAllowed = transportCommitAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteControlledProductionQueueMutationApplyReceipt(
    applyGateReceipt: IgniteProductionQueueMutationApplyGateReceipt,
    request: IgniteControlledProductionQueueMutationApplyRequest
): IgniteControlledProductionQueueMutationApplyReceipt {
    let nonClaims = igniteControlledProductionQueueMutationApplyNonClaims()
    if (!applyGateReceipt.productionQueueMutationApplyGateAccepted) {
        return IgniteControlledProductionQueueMutationApplyReceipt(
            false,
            applyGateReceipt.productionQueueMutationApplyGateAccepted,
            applyGateReceipt.productionQueueMutationApplyGateMode,
            "none",
            request.controlledMutationApplyId,
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
            "blocked-production-queue-mutation-apply-gate-receipt",
            "collect-accepted-production-queue-mutation-apply-gate-receipt-first",
            ["PRODUCTION_QUEUE_MUTATION_APPLY_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0466 production queue mutation apply-gate input before controlled apply work",
            "QUIC must not consume controlled production queue mutation apply receipts from rejected apply-gates"
        )
    }

    let controlledApplyMode = igniteControlledProductionQueueMutationApplyModeFor(
        applyGateReceipt.productionQueueMutationApplyGateMode
    )
    let blockers = igniteControlledProductionQueueMutationApplyBlockers(
        request,
        controlledApplyMode
    )
    if (blockers.size > 0) {
        return IgniteControlledProductionQueueMutationApplyReceipt(
            false,
            applyGateReceipt.productionQueueMutationApplyGateAccepted,
            applyGateReceipt.productionQueueMutationApplyGateMode,
            controlledApplyMode,
            request.controlledMutationApplyId,
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
            "blocked-controlled-production-queue-mutation-apply-input",
            "fix-controlled-production-queue-mutation-apply-before-executor-handoff",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry controlled apply id, apply-gate snapshot, mutation lease, queue slot ownership, queue depth transition, rollback armed, fallback armed, idempotency confirmation, completion fence, observability marker, and keep live enqueue out",
            "QUIC can reuse the same controlled apply blockers before stream task executor handoff"
        )
    }

    IgniteControlledProductionQueueMutationApplyReceipt(
        true,
        applyGateReceipt.productionQueueMutationApplyGateAccepted,
        applyGateReceipt.productionQueueMutationApplyGateMode,
        controlledApplyMode,
        request.controlledMutationApplyId,
        applyGateReceipt.mutationApplyGateId,
        applyGateReceipt.mutationCommitPlanId,
        applyGateReceipt.mutationDryRunId,
        applyGateReceipt.mutationGateId,
        applyGateReceipt.commitBoundaryId,
        applyGateReceipt.queueWriteId,
        applyGateReceipt.queueDepthBefore,
        applyGateReceipt.queueDepthAfter,
        true,
        "record-controlled-production-queue-mutation-apply-receipt",
        "accepted-controlled-production-queue-mutation-apply-receipt",
        "record-controlled-production-queue-mutation-apply-without-live-enqueue",
        [],
        true,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        nonClaims,
        "next packet may plan executor handoff without invoking user handlers or spawning production tasks",
        "QUIC can reuse lane-specific controlled production queue mutation apply modes before live stream task enqueue"
    )
}

func igniteControlledProductionQueueMutationApplyModeFor(
    applyGateMode: String
): String {
    if (applyGateMode == "short-production-queue-mutation-apply-gate") {
        return "short-controlled-production-queue-mutation-apply"
    }
    if (applyGateMode == "long-production-queue-mutation-apply-gate") {
        return "long-controlled-production-queue-mutation-apply"
    }
    if (
        applyGateMode ==
        "blocking-isolation-production-queue-mutation-apply-gate"
    ) {
        return "blocking-isolation-controlled-production-queue-mutation-apply"
    }
    "unknown-controlled-production-queue-mutation-apply"
}

func igniteControlledProductionQueueMutationApplyBlockers(
    request: IgniteControlledProductionQueueMutationApplyRequest,
    controlledApplyMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.controlledMutationApplyId.size == 0) {
        blockers.add("CONTROLLED_MUTATION_APPLY_ID_NOT_CARRIED")
    }
    if (!request.applyGateSnapshotCarried) {
        blockers.add("APPLY_GATE_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.mutationLeaseCarried) {
        blockers.add("MUTATION_LEASE_NOT_CARRIED")
    }
    if (!request.queueSlotOwnershipCarried) {
        blockers.add("QUEUE_SLOT_OWNERSHIP_NOT_CARRIED")
    }
    if (!request.queueDepthTransitionCarried) {
        blockers.add("QUEUE_DEPTH_TRANSITION_NOT_CARRIED")
    }
    if (!request.rollbackArmedCarried) {
        blockers.add("ROLLBACK_ARMED_NOT_CARRIED")
    }
    if (!request.fallbackArmedCarried) {
        blockers.add("FALLBACK_ARMED_NOT_CARRIED")
    }
    if (!request.idempotencyConfirmed) {
        blockers.add("IDEMPOTENCY_NOT_CONFIRMED")
    }
    if (!request.completionFenceCarried) {
        blockers.add("COMPLETION_FENCE_NOT_CARRIED")
    }
    if (!request.observabilityMarkerCarried) {
        blockers.add("OBSERVABILITY_MARKER_NOT_CARRIED")
    }
    if (request.liveExecutorEnqueueRequested) {
        blockers.add("LIVE_EXECUTOR_ENQUEUE_REQUESTED")
    }
    if (request.runtimeTaskSpawnRequested) {
        blockers.add("RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.handlerInvocationRequested) {
        blockers.add("HANDLER_INVOCATION_REQUESTED")
    }
    if (request.requestContextMutationRequested) {
        blockers.add("REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.responseWriteRequested) {
        blockers.add("RESPONSE_WRITE_REQUESTED")
    }
    if (request.transportCommitRequested) {
        blockers.add("TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.liveServerWiringRequested) {
        blockers.add("LIVE_SERVER_WIRING_REQUESTED")
    }
    if (
        controlledApplyMode ==
        "unknown-controlled-production-queue-mutation-apply"
    ) {
        blockers.add("UNKNOWN_CONTROLLED_PRODUCTION_QUEUE_MUTATION_APPLY")
    }
    blockers.toArray()
}

func igniteControlledProductionQueueMutationApplyNonClaims(): Array<String> {
    [
        "NO_LIVE_SERVER_WIRING",
        "NO_LIVE_EXECUTOR_ENQUEUE",
        "NO_HANDLER_INVOCATION",
        "NO_REQUEST_CONTEXT_MUTATION",
        "NO_RUNTIME_TASK_SPAWN",
        "NO_RESPONSE_WRITE",
        "NO_TRANSPORT_COMMIT",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
        "NO_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
    ]
}

public class IgniteExecutorHandoffRequest {
    public let executorHandoffId: String
    public let controlledApplySnapshotCarried: Bool
    public let executorLaneCarried: Bool
    public let executorTokenCarried: Bool
    public let queueSlotCarried: Bool
    public let dispatchPlanCarried: Bool
    public let backpressureMarkerCarried: Bool
    public let cancellationBoundaryCarried: Bool
    public let completionCallbackCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let liveExecutorEnqueueRequested: Bool
    public let runtimeTaskSpawnRequested: Bool
    public let handlerInvocationRequested: Bool
    public let requestContextMutationRequested: Bool
    public let responseWriteRequested: Bool
    public let transportCommitRequested: Bool
    public let liveServerWiringRequested: Bool

    public init(
        executorHandoffId: String,
        controlledApplySnapshotCarried: Bool,
        executorLaneCarried: Bool,
        executorTokenCarried: Bool,
        queueSlotCarried: Bool,
        dispatchPlanCarried: Bool,
        backpressureMarkerCarried: Bool,
        cancellationBoundaryCarried: Bool,
        completionCallbackCarried: Bool,
        observabilityMarkerCarried: Bool,
        liveExecutorEnqueueRequested: Bool,
        runtimeTaskSpawnRequested: Bool,
        handlerInvocationRequested: Bool,
        requestContextMutationRequested: Bool,
        responseWriteRequested: Bool,
        transportCommitRequested: Bool,
        liveServerWiringRequested: Bool
    ) {
        this.executorHandoffId = executorHandoffId
        this.controlledApplySnapshotCarried = controlledApplySnapshotCarried
        this.executorLaneCarried = executorLaneCarried
        this.executorTokenCarried = executorTokenCarried
        this.queueSlotCarried = queueSlotCarried
        this.dispatchPlanCarried = dispatchPlanCarried
        this.backpressureMarkerCarried = backpressureMarkerCarried
        this.cancellationBoundaryCarried = cancellationBoundaryCarried
        this.completionCallbackCarried = completionCallbackCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
        this.liveExecutorEnqueueRequested = liveExecutorEnqueueRequested
        this.runtimeTaskSpawnRequested = runtimeTaskSpawnRequested
        this.handlerInvocationRequested = handlerInvocationRequested
        this.requestContextMutationRequested = requestContextMutationRequested
        this.responseWriteRequested = responseWriteRequested
        this.transportCommitRequested = transportCommitRequested
        this.liveServerWiringRequested = liveServerWiringRequested
    }
}

public class IgniteExecutorHandoffReceipt {
    public let executorHandoffAccepted: Bool
    public let controlledProductionQueueMutationApplyAccepted: Bool
    public let controlledProductionQueueMutationApplyMode: String
    public let executorHandoffMode: String
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
    public let executorHandoffRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let executorHandoffAllowed: Bool
    public let liveExecutorEnqueueAllowed: Bool
    public let runtimeTaskSpawnAllowed: Bool
    public let handlerInvocationAllowed: Bool
    public let requestContextMutationAllowed: Bool
    public let responseWriteAllowed: Bool
    public let transportCommitAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        executorHandoffAccepted: Bool,
        controlledProductionQueueMutationApplyAccepted: Bool,
        controlledProductionQueueMutationApplyMode: String,
        executorHandoffMode: String,
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
        executorHandoffRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        executorHandoffAllowed: Bool,
        liveExecutorEnqueueAllowed: Bool,
        runtimeTaskSpawnAllowed: Bool,
        handlerInvocationAllowed: Bool,
        requestContextMutationAllowed: Bool,
        responseWriteAllowed: Bool,
        transportCommitAllowed: Bool,
        liveServerWiringAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.executorHandoffAccepted = executorHandoffAccepted
        this.controlledProductionQueueMutationApplyAccepted =
            controlledProductionQueueMutationApplyAccepted
        this.controlledProductionQueueMutationApplyMode =
            controlledProductionQueueMutationApplyMode
        this.executorHandoffMode = executorHandoffMode
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
        this.executorHandoffRecorded = executorHandoffRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.executorHandoffAllowed = executorHandoffAllowed
        this.liveExecutorEnqueueAllowed = liveExecutorEnqueueAllowed
        this.runtimeTaskSpawnAllowed = runtimeTaskSpawnAllowed
        this.handlerInvocationAllowed = handlerInvocationAllowed
        this.requestContextMutationAllowed = requestContextMutationAllowed
        this.responseWriteAllowed = responseWriteAllowed
        this.transportCommitAllowed = transportCommitAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteExecutorHandoffReceipt(
    controlledApplyReceipt: IgniteControlledProductionQueueMutationApplyReceipt,
    request: IgniteExecutorHandoffRequest
): IgniteExecutorHandoffReceipt {
    let nonClaims = igniteExecutorHandoffNonClaims()
    if (!controlledApplyReceipt.controlledProductionQueueMutationApplyAccepted) {
        return IgniteExecutorHandoffReceipt(
            false,
            controlledApplyReceipt.controlledProductionQueueMutationApplyAccepted,
            controlledApplyReceipt.controlledProductionQueueMutationApplyMode,
            "none",
            request.executorHandoffId,
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
            "blocked-controlled-production-queue-mutation-apply-receipt",
            "collect-accepted-controlled-production-queue-mutation-apply-receipt-first",
            ["CONTROLLED_PRODUCTION_QUEUE_MUTATION_APPLY_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0467 controlled production queue mutation apply input before executor handoff work",
            "QUIC must not consume executor handoff receipts from rejected controlled applies"
        )
    }

    let executorHandoffMode = igniteExecutorHandoffModeFor(
        controlledApplyReceipt.controlledProductionQueueMutationApplyMode
    )
    let blockers = igniteExecutorHandoffBlockers(
        request,
        executorHandoffMode
    )
    if (blockers.size > 0) {
        return IgniteExecutorHandoffReceipt(
            false,
            controlledApplyReceipt.controlledProductionQueueMutationApplyAccepted,
            controlledApplyReceipt.controlledProductionQueueMutationApplyMode,
            executorHandoffMode,
            request.executorHandoffId,
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
            "blocked-executor-handoff-input",
            "fix-executor-handoff-before-live-enqueue-proof",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry executor handoff id, controlled apply snapshot, executor lane, executor token, queue slot, dispatch plan, backpressure marker, cancellation boundary, completion callback, observability marker, and keep live enqueue out",
            "QUIC can reuse the same executor handoff blockers before stream task live enqueue proof"
        )
    }

    IgniteExecutorHandoffReceipt(
        true,
        controlledApplyReceipt.controlledProductionQueueMutationApplyAccepted,
        controlledApplyReceipt.controlledProductionQueueMutationApplyMode,
        executorHandoffMode,
        request.executorHandoffId,
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
        "record-executor-handoff-receipt",
        "accepted-executor-handoff-receipt",
        "record-executor-handoff-without-live-enqueue",
        [],
        true,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        nonClaims,
        "next packet may prove live executor enqueue without invoking user handlers or spawning production tasks",
        "QUIC can reuse lane-specific executor handoff modes before live stream task enqueue"
    )
}

func igniteExecutorHandoffModeFor(
    controlledApplyMode: String
): String {
    if (controlledApplyMode == "short-controlled-production-queue-mutation-apply") {
        return "short-executor-handoff"
    }
    if (controlledApplyMode == "long-controlled-production-queue-mutation-apply") {
        return "long-executor-handoff"
    }
    if (
        controlledApplyMode ==
        "blocking-isolation-controlled-production-queue-mutation-apply"
    ) {
        return "blocking-isolation-executor-handoff"
    }
    "unknown-executor-handoff"
}

func igniteExecutorHandoffBlockers(
    request: IgniteExecutorHandoffRequest,
    executorHandoffMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.executorHandoffId.size == 0) {
        blockers.add("EXECUTOR_HANDOFF_ID_NOT_CARRIED")
    }
    if (!request.controlledApplySnapshotCarried) {
        blockers.add("CONTROLLED_APPLY_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.executorLaneCarried) {
        blockers.add("EXECUTOR_LANE_NOT_CARRIED")
    }
    if (!request.executorTokenCarried) {
        blockers.add("EXECUTOR_TOKEN_NOT_CARRIED")
    }
    if (!request.queueSlotCarried) {
        blockers.add("QUEUE_SLOT_NOT_CARRIED")
    }
    if (!request.dispatchPlanCarried) {
        blockers.add("DISPATCH_PLAN_NOT_CARRIED")
    }
    if (!request.backpressureMarkerCarried) {
        blockers.add("BACKPRESSURE_MARKER_NOT_CARRIED")
    }
    if (!request.cancellationBoundaryCarried) {
        blockers.add("CANCELLATION_BOUNDARY_NOT_CARRIED")
    }
    if (!request.completionCallbackCarried) {
        blockers.add("COMPLETION_CALLBACK_NOT_CARRIED")
    }
    if (!request.observabilityMarkerCarried) {
        blockers.add("OBSERVABILITY_MARKER_NOT_CARRIED")
    }
    if (request.liveExecutorEnqueueRequested) {
        blockers.add("LIVE_EXECUTOR_ENQUEUE_REQUESTED")
    }
    if (request.runtimeTaskSpawnRequested) {
        blockers.add("RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.handlerInvocationRequested) {
        blockers.add("HANDLER_INVOCATION_REQUESTED")
    }
    if (request.requestContextMutationRequested) {
        blockers.add("REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.responseWriteRequested) {
        blockers.add("RESPONSE_WRITE_REQUESTED")
    }
    if (request.transportCommitRequested) {
        blockers.add("TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.liveServerWiringRequested) {
        blockers.add("LIVE_SERVER_WIRING_REQUESTED")
    }
    if (executorHandoffMode == "unknown-executor-handoff") {
        blockers.add("UNKNOWN_EXECUTOR_HANDOFF")
    }
    blockers.toArray()
}

func igniteExecutorHandoffNonClaims(): Array<String> {
    [
        "NO_LIVE_SERVER_WIRING",
        "NO_LIVE_EXECUTOR_ENQUEUE",
        "NO_HANDLER_INVOCATION",
        "NO_REQUEST_CONTEXT_MUTATION",
        "NO_RUNTIME_TASK_SPAWN",
        "NO_RESPONSE_WRITE",
        "NO_TRANSPORT_COMMIT",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
        "NO_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
    ]
}

public class IgniteLiveExecutorEnqueueProofGateRequest {
    public let liveEnqueueProofId: String
    public let executorHandoffSnapshotCarried: Bool
    public let liveEnqueueTokenCarried: Bool
    public let queueOwnershipMarkerCarried: Bool
    public let capacityProofCarried: Bool
    public let fairnessProofCarried: Bool
    public let cancellationProofCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let completionProofCarried: Bool
    public let productionQueueMutationRequested: Bool
    public let runtimeTaskSpawnRequested: Bool
    public let handlerInvocationRequested: Bool
    public let requestContextMutationRequested: Bool
    public let responseWriteRequested: Bool
    public let transportCommitRequested: Bool
    public let liveServerWiringRequested: Bool

    public init(
        liveEnqueueProofId: String,
        executorHandoffSnapshotCarried: Bool,
        liveEnqueueTokenCarried: Bool,
        queueOwnershipMarkerCarried: Bool,
        capacityProofCarried: Bool,
        fairnessProofCarried: Bool,
        cancellationProofCarried: Bool,
        observabilityMarkerCarried: Bool,
        completionProofCarried: Bool,
        productionQueueMutationRequested: Bool,
        runtimeTaskSpawnRequested: Bool,
        handlerInvocationRequested: Bool,
        requestContextMutationRequested: Bool,
        responseWriteRequested: Bool,
        transportCommitRequested: Bool,
        liveServerWiringRequested: Bool
    ) {
        this.liveEnqueueProofId = liveEnqueueProofId
        this.executorHandoffSnapshotCarried = executorHandoffSnapshotCarried
        this.liveEnqueueTokenCarried = liveEnqueueTokenCarried
        this.queueOwnershipMarkerCarried = queueOwnershipMarkerCarried
        this.capacityProofCarried = capacityProofCarried
        this.fairnessProofCarried = fairnessProofCarried
        this.cancellationProofCarried = cancellationProofCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
        this.completionProofCarried = completionProofCarried
        this.productionQueueMutationRequested = productionQueueMutationRequested
        this.runtimeTaskSpawnRequested = runtimeTaskSpawnRequested
        this.handlerInvocationRequested = handlerInvocationRequested
        this.requestContextMutationRequested = requestContextMutationRequested
        this.responseWriteRequested = responseWriteRequested
        this.transportCommitRequested = transportCommitRequested
        this.liveServerWiringRequested = liveServerWiringRequested
    }
}

public class IgniteLiveExecutorEnqueueProofGateReceipt {
    public let liveExecutorEnqueueProofGateAccepted: Bool
    public let executorHandoffAccepted: Bool
    public let executorHandoffMode: String
    public let liveExecutorEnqueueProofGateMode: String
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
    public let liveEnqueueProofRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let liveExecutorEnqueueProofGateAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let runtimeTaskSpawnAllowed: Bool
    public let handlerInvocationAllowed: Bool
    public let requestContextMutationAllowed: Bool
    public let responseWriteAllowed: Bool
    public let transportCommitAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        liveExecutorEnqueueProofGateAccepted: Bool,
        executorHandoffAccepted: Bool,
        executorHandoffMode: String,
        liveExecutorEnqueueProofGateMode: String,
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
        liveEnqueueProofRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        liveExecutorEnqueueProofGateAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        runtimeTaskSpawnAllowed: Bool,
        handlerInvocationAllowed: Bool,
        requestContextMutationAllowed: Bool,
        responseWriteAllowed: Bool,
        transportCommitAllowed: Bool,
        liveServerWiringAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.liveExecutorEnqueueProofGateAccepted =
            liveExecutorEnqueueProofGateAccepted
        this.executorHandoffAccepted = executorHandoffAccepted
        this.executorHandoffMode = executorHandoffMode
        this.liveExecutorEnqueueProofGateMode = liveExecutorEnqueueProofGateMode
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
        this.liveEnqueueProofRecorded = liveEnqueueProofRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.liveExecutorEnqueueProofGateAllowed =
            liveExecutorEnqueueProofGateAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.runtimeTaskSpawnAllowed = runtimeTaskSpawnAllowed
        this.handlerInvocationAllowed = handlerInvocationAllowed
        this.requestContextMutationAllowed = requestContextMutationAllowed
        this.responseWriteAllowed = responseWriteAllowed
        this.transportCommitAllowed = transportCommitAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteLiveExecutorEnqueueProofGateReceipt(
    executorHandoffReceipt: IgniteExecutorHandoffReceipt,
    request: IgniteLiveExecutorEnqueueProofGateRequest
): IgniteLiveExecutorEnqueueProofGateReceipt {
    let nonClaims = igniteLiveExecutorEnqueueProofGateNonClaims()
    if (!executorHandoffReceipt.executorHandoffAccepted) {
        return IgniteLiveExecutorEnqueueProofGateReceipt(
            false,
            executorHandoffReceipt.executorHandoffAccepted,
            executorHandoffReceipt.executorHandoffMode,
            "none",
            request.liveEnqueueProofId,
            executorHandoffReceipt.executorHandoffId,
            executorHandoffReceipt.controlledMutationApplyId,
            executorHandoffReceipt.mutationApplyGateId,
            executorHandoffReceipt.mutationCommitPlanId,
            executorHandoffReceipt.mutationDryRunId,
            executorHandoffReceipt.mutationGateId,
            executorHandoffReceipt.commitBoundaryId,
            executorHandoffReceipt.queueWriteId,
            executorHandoffReceipt.queueDepthBefore,
            executorHandoffReceipt.queueDepthAfter,
            false,
            "block",
            "blocked-executor-handoff-receipt",
            "collect-accepted-executor-handoff-receipt-first",
            ["EXECUTOR_HANDOFF_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0468 executor handoff input before live enqueue proof gate work",
            "QUIC must not consume live enqueue proof gate receipts from rejected executor handoffs"
        )
    }

    let liveEnqueueMode = igniteLiveExecutorEnqueueProofGateModeFor(
        executorHandoffReceipt.executorHandoffMode
    )
    let blockers = igniteLiveExecutorEnqueueProofGateBlockers(
        request,
        liveEnqueueMode
    )
    if (blockers.size > 0) {
        return IgniteLiveExecutorEnqueueProofGateReceipt(
            false,
            executorHandoffReceipt.executorHandoffAccepted,
            executorHandoffReceipt.executorHandoffMode,
            liveEnqueueMode,
            request.liveEnqueueProofId,
            executorHandoffReceipt.executorHandoffId,
            executorHandoffReceipt.controlledMutationApplyId,
            executorHandoffReceipt.mutationApplyGateId,
            executorHandoffReceipt.mutationCommitPlanId,
            executorHandoffReceipt.mutationDryRunId,
            executorHandoffReceipt.mutationGateId,
            executorHandoffReceipt.commitBoundaryId,
            executorHandoffReceipt.queueWriteId,
            executorHandoffReceipt.queueDepthBefore,
            executorHandoffReceipt.queueDepthAfter,
            false,
            "block",
            "blocked-live-executor-enqueue-proof-gate-input",
            "fix-live-enqueue-proof-gate-before-runtime-task-spawn",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry live enqueue proof id, executor handoff snapshot, enqueue token, queue ownership, capacity, fairness, cancellation, observability, completion proof, and keep runtime spawn out",
            "QUIC can reuse the same live enqueue proof blockers before stream task runtime spawn"
        )
    }

    IgniteLiveExecutorEnqueueProofGateReceipt(
        true,
        executorHandoffReceipt.executorHandoffAccepted,
        executorHandoffReceipt.executorHandoffMode,
        liveEnqueueMode,
        request.liveEnqueueProofId,
        executorHandoffReceipt.executorHandoffId,
        executorHandoffReceipt.controlledMutationApplyId,
        executorHandoffReceipt.mutationApplyGateId,
        executorHandoffReceipt.mutationCommitPlanId,
        executorHandoffReceipt.mutationDryRunId,
        executorHandoffReceipt.mutationGateId,
        executorHandoffReceipt.commitBoundaryId,
        executorHandoffReceipt.queueWriteId,
        executorHandoffReceipt.queueDepthBefore,
        executorHandoffReceipt.queueDepthAfter,
        true,
        "record-live-executor-enqueue-proof-gate",
        "accepted-live-executor-enqueue-proof-gate-receipt",
        "record-live-enqueue-proof-without-production-queue-mutation",
        [],
        true,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        nonClaims,
        "next packet may prove runtime task spawn gate without invoking user handlers or writing responses",
        "QUIC can reuse lane-specific live enqueue proof gate modes before stream task spawn gate"
    )
}

func igniteLiveExecutorEnqueueProofGateModeFor(
    executorHandoffMode: String
): String {
    if (executorHandoffMode == "short-executor-handoff") {
        return "short-live-executor-enqueue-proof-gate"
    }
    if (executorHandoffMode == "long-executor-handoff") {
        return "long-live-executor-enqueue-proof-gate"
    }
    if (executorHandoffMode == "blocking-isolation-executor-handoff") {
        return "blocking-isolation-live-executor-enqueue-proof-gate"
    }
    "unknown-live-executor-enqueue-proof-gate"
}

func igniteLiveExecutorEnqueueProofGateBlockers(
    request: IgniteLiveExecutorEnqueueProofGateRequest,
    liveEnqueueMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.liveEnqueueProofId.size == 0) {
        blockers.add("LIVE_ENQUEUE_PROOF_ID_NOT_CARRIED")
    }
    if (!request.executorHandoffSnapshotCarried) {
        blockers.add("EXECUTOR_HANDOFF_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.liveEnqueueTokenCarried) {
        blockers.add("LIVE_ENQUEUE_TOKEN_NOT_CARRIED")
    }
    if (!request.queueOwnershipMarkerCarried) {
        blockers.add("QUEUE_OWNERSHIP_MARKER_NOT_CARRIED")
    }
    if (!request.capacityProofCarried) {
        blockers.add("CAPACITY_PROOF_NOT_CARRIED")
    }
    if (!request.fairnessProofCarried) {
        blockers.add("FAIRNESS_PROOF_NOT_CARRIED")
    }
    if (!request.cancellationProofCarried) {
        blockers.add("CANCELLATION_PROOF_NOT_CARRIED")
    }
    if (!request.observabilityMarkerCarried) {
        blockers.add("OBSERVABILITY_MARKER_NOT_CARRIED")
    }
    if (!request.completionProofCarried) {
        blockers.add("COMPLETION_PROOF_NOT_CARRIED")
    }
    if (request.productionQueueMutationRequested) {
        blockers.add("PRODUCTION_QUEUE_MUTATION_REQUESTED")
    }
    if (request.runtimeTaskSpawnRequested) {
        blockers.add("RUNTIME_TASK_SPAWN_REQUESTED")
    }
    if (request.handlerInvocationRequested) {
        blockers.add("HANDLER_INVOCATION_REQUESTED")
    }
    if (request.requestContextMutationRequested) {
        blockers.add("REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.responseWriteRequested) {
        blockers.add("RESPONSE_WRITE_REQUESTED")
    }
    if (request.transportCommitRequested) {
        blockers.add("TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.liveServerWiringRequested) {
        blockers.add("LIVE_SERVER_WIRING_REQUESTED")
    }
    if (liveEnqueueMode == "unknown-live-executor-enqueue-proof-gate") {
        blockers.add("UNKNOWN_EXECUTOR_HANDOFF")
    }
    blockers.toArray()
}

func igniteLiveExecutorEnqueueProofGateNonClaims(): Array<String> {
    [
        "NO_LIVE_SERVER_WIRING",
        "NO_PRODUCTION_QUEUE_MUTATION",
        "NO_HANDLER_INVOCATION",
        "NO_REQUEST_CONTEXT_MUTATION",
        "NO_RUNTIME_TASK_SPAWN",
        "NO_RESPONSE_WRITE",
        "NO_TRANSPORT_COMMIT",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
        "NO_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
    ]
}

public class IgniteRuntimeTaskSpawnGateRequest {
    public let runtimeSpawnGateId: String
    public let liveEnqueueProofSnapshotCarried: Bool
    public let taskEnvelopeCarried: Bool
    public let schedulerLaneCarried: Bool
    public let spawnTokenCarried: Bool
    public let lifecycleMarkerCarried: Bool
    public let cancellationBoundaryCarried: Bool
    public let handlerIsolationMarkerCarried: Bool
    public let responseIsolationMarkerCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let productionQueueMutationRequested: Bool
    public let actualRuntimeTaskSpawnRequested: Bool
    public let handlerInvocationRequested: Bool
    public let requestContextMutationRequested: Bool
    public let responseWriteRequested: Bool
    public let transportCommitRequested: Bool
    public let liveServerWiringRequested: Bool

    public init(
        runtimeSpawnGateId: String,
        liveEnqueueProofSnapshotCarried: Bool,
        taskEnvelopeCarried: Bool,
        schedulerLaneCarried: Bool,
        spawnTokenCarried: Bool,
        lifecycleMarkerCarried: Bool,
        cancellationBoundaryCarried: Bool,
        handlerIsolationMarkerCarried: Bool,
        responseIsolationMarkerCarried: Bool,
        observabilityMarkerCarried: Bool,
        productionQueueMutationRequested: Bool,
        actualRuntimeTaskSpawnRequested: Bool,
        handlerInvocationRequested: Bool,
        requestContextMutationRequested: Bool,
        responseWriteRequested: Bool,
        transportCommitRequested: Bool,
        liveServerWiringRequested: Bool
    ) {
        this.runtimeSpawnGateId = runtimeSpawnGateId
        this.liveEnqueueProofSnapshotCarried = liveEnqueueProofSnapshotCarried
        this.taskEnvelopeCarried = taskEnvelopeCarried
        this.schedulerLaneCarried = schedulerLaneCarried
        this.spawnTokenCarried = spawnTokenCarried
        this.lifecycleMarkerCarried = lifecycleMarkerCarried
        this.cancellationBoundaryCarried = cancellationBoundaryCarried
        this.handlerIsolationMarkerCarried = handlerIsolationMarkerCarried
        this.responseIsolationMarkerCarried = responseIsolationMarkerCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
        this.productionQueueMutationRequested = productionQueueMutationRequested
        this.actualRuntimeTaskSpawnRequested = actualRuntimeTaskSpawnRequested
        this.handlerInvocationRequested = handlerInvocationRequested
        this.requestContextMutationRequested = requestContextMutationRequested
        this.responseWriteRequested = responseWriteRequested
        this.transportCommitRequested = transportCommitRequested
        this.liveServerWiringRequested = liveServerWiringRequested
    }
}

public class IgniteRuntimeTaskSpawnGateReceipt {
    public let runtimeTaskSpawnGateAccepted: Bool
    public let liveExecutorEnqueueProofGateAccepted: Bool
    public let liveExecutorEnqueueProofGateMode: String
    public let runtimeTaskSpawnGateMode: String
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
    public let runtimeTaskSpawnGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeTaskSpawnGateAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let handlerInvocationAllowed: Bool
    public let requestContextMutationAllowed: Bool
    public let responseWriteAllowed: Bool
    public let transportCommitAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        runtimeTaskSpawnGateAccepted: Bool,
        liveExecutorEnqueueProofGateAccepted: Bool,
        liveExecutorEnqueueProofGateMode: String,
        runtimeTaskSpawnGateMode: String,
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
        runtimeTaskSpawnGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeTaskSpawnGateAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        handlerInvocationAllowed: Bool,
        requestContextMutationAllowed: Bool,
        responseWriteAllowed: Bool,
        transportCommitAllowed: Bool,
        liveServerWiringAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.runtimeTaskSpawnGateAccepted = runtimeTaskSpawnGateAccepted
        this.liveExecutorEnqueueProofGateAccepted =
            liveExecutorEnqueueProofGateAccepted
        this.liveExecutorEnqueueProofGateMode = liveExecutorEnqueueProofGateMode
        this.runtimeTaskSpawnGateMode = runtimeTaskSpawnGateMode
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
        this.runtimeTaskSpawnGateRecorded = runtimeTaskSpawnGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.runtimeTaskSpawnGateAllowed = runtimeTaskSpawnGateAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.actualRuntimeTaskSpawnAllowed = actualRuntimeTaskSpawnAllowed
        this.handlerInvocationAllowed = handlerInvocationAllowed
        this.requestContextMutationAllowed = requestContextMutationAllowed
        this.responseWriteAllowed = responseWriteAllowed
        this.transportCommitAllowed = transportCommitAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteRuntimeTaskSpawnGateReceipt(
    liveEnqueueProofGateReceipt: IgniteLiveExecutorEnqueueProofGateReceipt,
    request: IgniteRuntimeTaskSpawnGateRequest
): IgniteRuntimeTaskSpawnGateReceipt {
    let nonClaims = igniteRuntimeTaskSpawnGateNonClaims()
    if (!liveEnqueueProofGateReceipt.liveExecutorEnqueueProofGateAccepted) {
        return IgniteRuntimeTaskSpawnGateReceipt(
            false,
            liveEnqueueProofGateReceipt.liveExecutorEnqueueProofGateAccepted,
            liveEnqueueProofGateReceipt.liveExecutorEnqueueProofGateMode,
            "none",
            request.runtimeSpawnGateId,
            liveEnqueueProofGateReceipt.liveEnqueueProofId,
            liveEnqueueProofGateReceipt.executorHandoffId,
            liveEnqueueProofGateReceipt.controlledMutationApplyId,
            liveEnqueueProofGateReceipt.mutationApplyGateId,
            liveEnqueueProofGateReceipt.mutationCommitPlanId,
            liveEnqueueProofGateReceipt.mutationDryRunId,
            liveEnqueueProofGateReceipt.mutationGateId,
            liveEnqueueProofGateReceipt.commitBoundaryId,
            liveEnqueueProofGateReceipt.queueWriteId,
            liveEnqueueProofGateReceipt.queueDepthBefore,
            liveEnqueueProofGateReceipt.queueDepthAfter,
            false,
            "block",
            "blocked-live-executor-enqueue-proof-gate-receipt",
            "collect-accepted-live-executor-enqueue-proof-gate-receipt-first",
            ["LIVE_EXECUTOR_ENQUEUE_PROOF_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0469 live enqueue proof gate input before runtime task spawn gate work",
            "QUIC must not consume runtime task spawn gate receipts from rejected live enqueue proof gates"
        )
    }

    let spawnGateMode = igniteRuntimeTaskSpawnGateModeFor(
        liveEnqueueProofGateReceipt.liveExecutorEnqueueProofGateMode
    )
    let blockers = igniteRuntimeTaskSpawnGateBlockers(
        request,
        spawnGateMode
    )
    if (blockers.size > 0) {
        return IgniteRuntimeTaskSpawnGateReceipt(
            false,
            liveEnqueueProofGateReceipt.liveExecutorEnqueueProofGateAccepted,
            liveEnqueueProofGateReceipt.liveExecutorEnqueueProofGateMode,
            spawnGateMode,
            request.runtimeSpawnGateId,
            liveEnqueueProofGateReceipt.liveEnqueueProofId,
            liveEnqueueProofGateReceipt.executorHandoffId,
            liveEnqueueProofGateReceipt.controlledMutationApplyId,
            liveEnqueueProofGateReceipt.mutationApplyGateId,
            liveEnqueueProofGateReceipt.mutationCommitPlanId,
            liveEnqueueProofGateReceipt.mutationDryRunId,
            liveEnqueueProofGateReceipt.mutationGateId,
            liveEnqueueProofGateReceipt.commitBoundaryId,
            liveEnqueueProofGateReceipt.queueWriteId,
            liveEnqueueProofGateReceipt.queueDepthBefore,
            liveEnqueueProofGateReceipt.queueDepthAfter,
            false,
            "block",
            "blocked-runtime-task-spawn-gate-input",
            "fix-runtime-task-spawn-gate-before-handler-invocation",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry runtime spawn gate id, live enqueue proof snapshot, task envelope, scheduler lane, spawn token, lifecycle, cancellation, handler isolation, response isolation, observability markers, and keep actual spawn out",
            "QUIC can reuse the same spawn gate blockers before stream handler invocation"
        )
    }

    IgniteRuntimeTaskSpawnGateReceipt(
        true,
        liveEnqueueProofGateReceipt.liveExecutorEnqueueProofGateAccepted,
        liveEnqueueProofGateReceipt.liveExecutorEnqueueProofGateMode,
        spawnGateMode,
        request.runtimeSpawnGateId,
        liveEnqueueProofGateReceipt.liveEnqueueProofId,
        liveEnqueueProofGateReceipt.executorHandoffId,
        liveEnqueueProofGateReceipt.controlledMutationApplyId,
        liveEnqueueProofGateReceipt.mutationApplyGateId,
        liveEnqueueProofGateReceipt.mutationCommitPlanId,
        liveEnqueueProofGateReceipt.mutationDryRunId,
        liveEnqueueProofGateReceipt.mutationGateId,
        liveEnqueueProofGateReceipt.commitBoundaryId,
        liveEnqueueProofGateReceipt.queueWriteId,
        liveEnqueueProofGateReceipt.queueDepthBefore,
        liveEnqueueProofGateReceipt.queueDepthAfter,
        true,
        "record-runtime-task-spawn-gate",
        "accepted-runtime-task-spawn-gate-receipt",
        "record-runtime-task-spawn-gate-without-actual-task-spawn",
        [],
        true,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        nonClaims,
        "next packet may prove handler invocation gate without mutating request context or writing responses",
        "QUIC can reuse lane-specific runtime task spawn gate modes before stream handler invocation gate"
    )
}

func igniteRuntimeTaskSpawnGateModeFor(
    liveEnqueueMode: String
): String {
    if (liveEnqueueMode == "short-live-executor-enqueue-proof-gate") {
        return "short-runtime-task-spawn-gate"
    }
    if (liveEnqueueMode == "long-live-executor-enqueue-proof-gate") {
        return "long-runtime-task-spawn-gate"
    }
    if (
        liveEnqueueMode ==
        "blocking-isolation-live-executor-enqueue-proof-gate"
    ) {
        return "blocking-isolation-runtime-task-spawn-gate"
    }
    "unknown-runtime-task-spawn-gate"
}

func igniteRuntimeTaskSpawnGateBlockers(
    request: IgniteRuntimeTaskSpawnGateRequest,
    spawnGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.runtimeSpawnGateId.size == 0) {
        blockers.add("RUNTIME_SPAWN_GATE_ID_NOT_CARRIED")
    }
    if (!request.liveEnqueueProofSnapshotCarried) {
        blockers.add("LIVE_ENQUEUE_PROOF_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.taskEnvelopeCarried) {
        blockers.add("TASK_ENVELOPE_NOT_CARRIED")
    }
    if (!request.schedulerLaneCarried) {
        blockers.add("SCHEDULER_LANE_NOT_CARRIED")
    }
    if (!request.spawnTokenCarried) {
        blockers.add("SPAWN_TOKEN_NOT_CARRIED")
    }
    if (!request.lifecycleMarkerCarried) {
        blockers.add("LIFECYCLE_MARKER_NOT_CARRIED")
    }
    if (!request.cancellationBoundaryCarried) {
        blockers.add("CANCELLATION_BOUNDARY_NOT_CARRIED")
    }
    if (!request.handlerIsolationMarkerCarried) {
        blockers.add("HANDLER_ISOLATION_MARKER_NOT_CARRIED")
    }
    if (!request.responseIsolationMarkerCarried) {
        blockers.add("RESPONSE_ISOLATION_MARKER_NOT_CARRIED")
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
    if (request.handlerInvocationRequested) {
        blockers.add("HANDLER_INVOCATION_REQUESTED")
    }
    if (request.requestContextMutationRequested) {
        blockers.add("REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.responseWriteRequested) {
        blockers.add("RESPONSE_WRITE_REQUESTED")
    }
    if (request.transportCommitRequested) {
        blockers.add("TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.liveServerWiringRequested) {
        blockers.add("LIVE_SERVER_WIRING_REQUESTED")
    }
    if (spawnGateMode == "unknown-runtime-task-spawn-gate") {
        blockers.add("UNKNOWN_LIVE_ENQUEUE_PROOF_GATE")
    }
    blockers.toArray()
}

func igniteRuntimeTaskSpawnGateNonClaims(): Array<String> {
    [
        "NO_LIVE_SERVER_WIRING",
        "NO_PRODUCTION_QUEUE_MUTATION",
        "NO_ACTUAL_RUNTIME_TASK_SPAWN",
        "NO_HANDLER_INVOCATION",
        "NO_REQUEST_CONTEXT_MUTATION",
        "NO_RESPONSE_WRITE",
        "NO_TRANSPORT_COMMIT",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
        "NO_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
    ]
}

public class IgniteHandlerInvocationGateRequest {
    public let handlerInvocationGateId: String
    public let runtimeSpawnGateSnapshotCarried: Bool
    public let handlerReferenceCarried: Bool
    public let invocationTokenCarried: Bool
    public let requestSnapshotCarried: Bool
    public let ctxIsolationCarried: Bool
    public let responsePlanCarried: Bool
    public let errorBoundaryCarried: Bool
    public let cancellationBoundaryCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let productionQueueMutationRequested: Bool
    public let actualRuntimeTaskSpawnRequested: Bool
    public let actualHandlerInvocationRequested: Bool
    public let requestContextMutationRequested: Bool
    public let responseWriteRequested: Bool
    public let transportCommitRequested: Bool
    public let liveServerWiringRequested: Bool

    public init(
        handlerInvocationGateId: String,
        runtimeSpawnGateSnapshotCarried: Bool,
        handlerReferenceCarried: Bool,
        invocationTokenCarried: Bool,
        requestSnapshotCarried: Bool,
        ctxIsolationCarried: Bool,
        responsePlanCarried: Bool,
        errorBoundaryCarried: Bool,
        cancellationBoundaryCarried: Bool,
        observabilityMarkerCarried: Bool,
        productionQueueMutationRequested: Bool,
        actualRuntimeTaskSpawnRequested: Bool,
        actualHandlerInvocationRequested: Bool,
        requestContextMutationRequested: Bool,
        responseWriteRequested: Bool,
        transportCommitRequested: Bool,
        liveServerWiringRequested: Bool
    ) {
        this.handlerInvocationGateId = handlerInvocationGateId
        this.runtimeSpawnGateSnapshotCarried = runtimeSpawnGateSnapshotCarried
        this.handlerReferenceCarried = handlerReferenceCarried
        this.invocationTokenCarried = invocationTokenCarried
        this.requestSnapshotCarried = requestSnapshotCarried
        this.ctxIsolationCarried = ctxIsolationCarried
        this.responsePlanCarried = responsePlanCarried
        this.errorBoundaryCarried = errorBoundaryCarried
        this.cancellationBoundaryCarried = cancellationBoundaryCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
        this.productionQueueMutationRequested = productionQueueMutationRequested
        this.actualRuntimeTaskSpawnRequested = actualRuntimeTaskSpawnRequested
        this.actualHandlerInvocationRequested = actualHandlerInvocationRequested
        this.requestContextMutationRequested = requestContextMutationRequested
        this.responseWriteRequested = responseWriteRequested
        this.transportCommitRequested = transportCommitRequested
        this.liveServerWiringRequested = liveServerWiringRequested
    }
}

public class IgniteHandlerInvocationGateReceipt {
    public let handlerInvocationGateAccepted: Bool
    public let runtimeTaskSpawnGateAccepted: Bool
    public let runtimeTaskSpawnGateMode: String
    public let handlerInvocationGateMode: String
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
    public let handlerInvocationGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let handlerInvocationGateAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let actualHandlerInvocationAllowed: Bool
    public let requestContextMutationAllowed: Bool
    public let responseWriteAllowed: Bool
    public let transportCommitAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        handlerInvocationGateAccepted: Bool,
        runtimeTaskSpawnGateAccepted: Bool,
        runtimeTaskSpawnGateMode: String,
        handlerInvocationGateMode: String,
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
        handlerInvocationGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        handlerInvocationGateAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        actualHandlerInvocationAllowed: Bool,
        requestContextMutationAllowed: Bool,
        responseWriteAllowed: Bool,
        transportCommitAllowed: Bool,
        liveServerWiringAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.handlerInvocationGateAccepted = handlerInvocationGateAccepted
        this.runtimeTaskSpawnGateAccepted = runtimeTaskSpawnGateAccepted
        this.runtimeTaskSpawnGateMode = runtimeTaskSpawnGateMode
        this.handlerInvocationGateMode = handlerInvocationGateMode
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
        this.handlerInvocationGateRecorded = handlerInvocationGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.handlerInvocationGateAllowed = handlerInvocationGateAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.actualRuntimeTaskSpawnAllowed = actualRuntimeTaskSpawnAllowed
        this.actualHandlerInvocationAllowed = actualHandlerInvocationAllowed
        this.requestContextMutationAllowed = requestContextMutationAllowed
        this.responseWriteAllowed = responseWriteAllowed
        this.transportCommitAllowed = transportCommitAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteHandlerInvocationGateReceipt(
    runtimeTaskSpawnGateReceipt: IgniteRuntimeTaskSpawnGateReceipt,
    request: IgniteHandlerInvocationGateRequest
): IgniteHandlerInvocationGateReceipt {
    let nonClaims = igniteHandlerInvocationGateNonClaims()
    if (!runtimeTaskSpawnGateReceipt.runtimeTaskSpawnGateAccepted) {
        return IgniteHandlerInvocationGateReceipt(
            false,
            runtimeTaskSpawnGateReceipt.runtimeTaskSpawnGateAccepted,
            runtimeTaskSpawnGateReceipt.runtimeTaskSpawnGateMode,
            "none",
            request.handlerInvocationGateId,
            runtimeTaskSpawnGateReceipt.runtimeSpawnGateId,
            runtimeTaskSpawnGateReceipt.liveEnqueueProofId,
            runtimeTaskSpawnGateReceipt.executorHandoffId,
            runtimeTaskSpawnGateReceipt.controlledMutationApplyId,
            runtimeTaskSpawnGateReceipt.mutationApplyGateId,
            runtimeTaskSpawnGateReceipt.mutationCommitPlanId,
            runtimeTaskSpawnGateReceipt.mutationDryRunId,
            runtimeTaskSpawnGateReceipt.mutationGateId,
            runtimeTaskSpawnGateReceipt.commitBoundaryId,
            runtimeTaskSpawnGateReceipt.queueWriteId,
            runtimeTaskSpawnGateReceipt.queueDepthBefore,
            runtimeTaskSpawnGateReceipt.queueDepthAfter,
            false,
            "block",
            "blocked-runtime-task-spawn-gate-receipt",
            "collect-accepted-runtime-task-spawn-gate-receipt-first",
            ["RUNTIME_TASK_SPAWN_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0470 runtime task spawn gate input before handler invocation gate work",
            "QUIC must not consume handler invocation gate receipts from rejected runtime task spawn gates"
        )
    }

    let invocationGateMode = igniteHandlerInvocationGateModeFor(
        runtimeTaskSpawnGateReceipt.runtimeTaskSpawnGateMode
    )
    let blockers = igniteHandlerInvocationGateBlockers(
        request,
        invocationGateMode
    )
    if (blockers.size > 0) {
        return IgniteHandlerInvocationGateReceipt(
            false,
            runtimeTaskSpawnGateReceipt.runtimeTaskSpawnGateAccepted,
            runtimeTaskSpawnGateReceipt.runtimeTaskSpawnGateMode,
            invocationGateMode,
            request.handlerInvocationGateId,
            runtimeTaskSpawnGateReceipt.runtimeSpawnGateId,
            runtimeTaskSpawnGateReceipt.liveEnqueueProofId,
            runtimeTaskSpawnGateReceipt.executorHandoffId,
            runtimeTaskSpawnGateReceipt.controlledMutationApplyId,
            runtimeTaskSpawnGateReceipt.mutationApplyGateId,
            runtimeTaskSpawnGateReceipt.mutationCommitPlanId,
            runtimeTaskSpawnGateReceipt.mutationDryRunId,
            runtimeTaskSpawnGateReceipt.mutationGateId,
            runtimeTaskSpawnGateReceipt.commitBoundaryId,
            runtimeTaskSpawnGateReceipt.queueWriteId,
            runtimeTaskSpawnGateReceipt.queueDepthBefore,
            runtimeTaskSpawnGateReceipt.queueDepthAfter,
            false,
            "block",
            "blocked-handler-invocation-gate-input",
            "fix-handler-invocation-gate-before-request-context-mutation",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry handler invocation gate id, runtime spawn gate snapshot, handler reference, invocation token, request snapshot, ctx isolation, response plan, error boundary, cancellation boundary, observability markers, and keep actual handler invocation out",
            "QUIC can reuse the same invocation gate blockers before stream context mutation"
        )
    }

    IgniteHandlerInvocationGateReceipt(
        true,
        runtimeTaskSpawnGateReceipt.runtimeTaskSpawnGateAccepted,
        runtimeTaskSpawnGateReceipt.runtimeTaskSpawnGateMode,
        invocationGateMode,
        request.handlerInvocationGateId,
        runtimeTaskSpawnGateReceipt.runtimeSpawnGateId,
        runtimeTaskSpawnGateReceipt.liveEnqueueProofId,
        runtimeTaskSpawnGateReceipt.executorHandoffId,
        runtimeTaskSpawnGateReceipt.controlledMutationApplyId,
        runtimeTaskSpawnGateReceipt.mutationApplyGateId,
        runtimeTaskSpawnGateReceipt.mutationCommitPlanId,
        runtimeTaskSpawnGateReceipt.mutationDryRunId,
        runtimeTaskSpawnGateReceipt.mutationGateId,
        runtimeTaskSpawnGateReceipt.commitBoundaryId,
        runtimeTaskSpawnGateReceipt.queueWriteId,
        runtimeTaskSpawnGateReceipt.queueDepthBefore,
        runtimeTaskSpawnGateReceipt.queueDepthAfter,
        true,
        "record-handler-invocation-gate",
        "accepted-handler-invocation-gate-receipt",
        "record-handler-invocation-gate-without-actual-handler-call",
        [],
        true,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        nonClaims,
        "next packet may prove request-context mutation gate without writing responses",
        "QUIC can reuse lane-specific handler invocation gate modes before stream context mutation gate"
    )
}

func igniteHandlerInvocationGateModeFor(
    spawnGateMode: String
): String {
    if (spawnGateMode == "short-runtime-task-spawn-gate") {
        return "short-handler-invocation-gate"
    }
    if (spawnGateMode == "long-runtime-task-spawn-gate") {
        return "long-handler-invocation-gate"
    }
    if (spawnGateMode == "blocking-isolation-runtime-task-spawn-gate") {
        return "blocking-isolation-handler-invocation-gate"
    }
    "unknown-handler-invocation-gate"
}

func igniteHandlerInvocationGateBlockers(
    request: IgniteHandlerInvocationGateRequest,
    invocationGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.handlerInvocationGateId.size == 0) {
        blockers.add("HANDLER_INVOCATION_GATE_ID_NOT_CARRIED")
    }
    if (!request.runtimeSpawnGateSnapshotCarried) {
        blockers.add("RUNTIME_TASK_SPAWN_GATE_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.handlerReferenceCarried) {
        blockers.add("HANDLER_REFERENCE_NOT_CARRIED")
    }
    if (!request.invocationTokenCarried) {
        blockers.add("INVOCATION_TOKEN_NOT_CARRIED")
    }
    if (!request.requestSnapshotCarried) {
        blockers.add("REQUEST_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.ctxIsolationCarried) {
        blockers.add("CTX_ISOLATION_NOT_CARRIED")
    }
    if (!request.responsePlanCarried) {
        blockers.add("RESPONSE_PLAN_NOT_CARRIED")
    }
    if (!request.errorBoundaryCarried) {
        blockers.add("ERROR_BOUNDARY_NOT_CARRIED")
    }
    if (!request.cancellationBoundaryCarried) {
        blockers.add("CANCELLATION_BOUNDARY_NOT_CARRIED")
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
    if (request.requestContextMutationRequested) {
        blockers.add("REQUEST_CONTEXT_MUTATION_REQUESTED")
    }
    if (request.responseWriteRequested) {
        blockers.add("RESPONSE_WRITE_REQUESTED")
    }
    if (request.transportCommitRequested) {
        blockers.add("TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.liveServerWiringRequested) {
        blockers.add("LIVE_SERVER_WIRING_REQUESTED")
    }
    if (invocationGateMode == "unknown-handler-invocation-gate") {
        blockers.add("UNKNOWN_RUNTIME_TASK_SPAWN_GATE")
    }
    blockers.toArray()
}

func igniteHandlerInvocationGateNonClaims(): Array<String> {
    [
        "NO_LIVE_SERVER_WIRING",
        "NO_PRODUCTION_QUEUE_MUTATION",
        "NO_ACTUAL_RUNTIME_TASK_SPAWN",
        "NO_ACTUAL_HANDLER_INVOCATION",
        "NO_REQUEST_CONTEXT_MUTATION",
        "NO_RESPONSE_WRITE",
        "NO_TRANSPORT_COMMIT",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
        "NO_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
    ]
}

public class IgniteRequestContextMutationGateRequest {
    public let requestContextMutationGateId: String
    public let handlerInvocationGateSnapshotCarried: Bool
    public let requestContextCarrierCarried: Bool
    public let ctxMutationPlanCarried: Bool
    public let routeParamsSnapshotCarried: Bool
    public let querySnapshotCarried: Bool
    public let bodyAccessPlanCarried: Bool
    public let stateIsolationCarried: Bool
    public let errorBoundaryCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let productionQueueMutationRequested: Bool
    public let actualRuntimeTaskSpawnRequested: Bool
    public let actualHandlerInvocationRequested: Bool
    public let actualRequestContextMutationRequested: Bool
    public let responseWriteRequested: Bool
    public let transportCommitRequested: Bool
    public let liveServerWiringRequested: Bool

    public init(
        requestContextMutationGateId: String,
        handlerInvocationGateSnapshotCarried: Bool,
        requestContextCarrierCarried: Bool,
        ctxMutationPlanCarried: Bool,
        routeParamsSnapshotCarried: Bool,
        querySnapshotCarried: Bool,
        bodyAccessPlanCarried: Bool,
        stateIsolationCarried: Bool,
        errorBoundaryCarried: Bool,
        observabilityMarkerCarried: Bool,
        productionQueueMutationRequested: Bool,
        actualRuntimeTaskSpawnRequested: Bool,
        actualHandlerInvocationRequested: Bool,
        actualRequestContextMutationRequested: Bool,
        responseWriteRequested: Bool,
        transportCommitRequested: Bool,
        liveServerWiringRequested: Bool
    ) {
        this.requestContextMutationGateId = requestContextMutationGateId
        this.handlerInvocationGateSnapshotCarried =
            handlerInvocationGateSnapshotCarried
        this.requestContextCarrierCarried = requestContextCarrierCarried
        this.ctxMutationPlanCarried = ctxMutationPlanCarried
        this.routeParamsSnapshotCarried = routeParamsSnapshotCarried
        this.querySnapshotCarried = querySnapshotCarried
        this.bodyAccessPlanCarried = bodyAccessPlanCarried
        this.stateIsolationCarried = stateIsolationCarried
        this.errorBoundaryCarried = errorBoundaryCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
        this.productionQueueMutationRequested = productionQueueMutationRequested
        this.actualRuntimeTaskSpawnRequested = actualRuntimeTaskSpawnRequested
        this.actualHandlerInvocationRequested = actualHandlerInvocationRequested
        this.actualRequestContextMutationRequested =
            actualRequestContextMutationRequested
        this.responseWriteRequested = responseWriteRequested
        this.transportCommitRequested = transportCommitRequested
        this.liveServerWiringRequested = liveServerWiringRequested
    }
}

public class IgniteRequestContextMutationGateReceipt {
    public let requestContextMutationGateAccepted: Bool
    public let handlerInvocationGateAccepted: Bool
    public let handlerInvocationGateMode: String
    public let requestContextMutationGateMode: String
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
    public let requestContextMutationGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let requestContextMutationGateAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let actualHandlerInvocationAllowed: Bool
    public let actualRequestContextMutationAllowed: Bool
    public let responseWriteAllowed: Bool
    public let transportCommitAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        requestContextMutationGateAccepted: Bool,
        handlerInvocationGateAccepted: Bool,
        handlerInvocationGateMode: String,
        requestContextMutationGateMode: String,
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
        requestContextMutationGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        requestContextMutationGateAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        actualHandlerInvocationAllowed: Bool,
        actualRequestContextMutationAllowed: Bool,
        responseWriteAllowed: Bool,
        transportCommitAllowed: Bool,
        liveServerWiringAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.requestContextMutationGateAccepted =
            requestContextMutationGateAccepted
        this.handlerInvocationGateAccepted = handlerInvocationGateAccepted
        this.handlerInvocationGateMode = handlerInvocationGateMode
        this.requestContextMutationGateMode = requestContextMutationGateMode
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
        this.requestContextMutationGateRecorded =
            requestContextMutationGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.requestContextMutationGateAllowed =
            requestContextMutationGateAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.actualRuntimeTaskSpawnAllowed = actualRuntimeTaskSpawnAllowed
        this.actualHandlerInvocationAllowed = actualHandlerInvocationAllowed
        this.actualRequestContextMutationAllowed =
            actualRequestContextMutationAllowed
        this.responseWriteAllowed = responseWriteAllowed
        this.transportCommitAllowed = transportCommitAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteRequestContextMutationGateReceipt(
    handlerInvocationGateReceipt: IgniteHandlerInvocationGateReceipt,
    request: IgniteRequestContextMutationGateRequest
): IgniteRequestContextMutationGateReceipt {
    let nonClaims = igniteRequestContextMutationGateNonClaims()
    if (!handlerInvocationGateReceipt.handlerInvocationGateAccepted) {
        return IgniteRequestContextMutationGateReceipt(
            false,
            handlerInvocationGateReceipt.handlerInvocationGateAccepted,
            handlerInvocationGateReceipt.handlerInvocationGateMode,
            "none",
            request.requestContextMutationGateId,
            handlerInvocationGateReceipt.handlerInvocationGateId,
            handlerInvocationGateReceipt.runtimeSpawnGateId,
            handlerInvocationGateReceipt.liveEnqueueProofId,
            handlerInvocationGateReceipt.executorHandoffId,
            handlerInvocationGateReceipt.controlledMutationApplyId,
            handlerInvocationGateReceipt.mutationApplyGateId,
            handlerInvocationGateReceipt.mutationCommitPlanId,
            handlerInvocationGateReceipt.mutationDryRunId,
            handlerInvocationGateReceipt.mutationGateId,
            handlerInvocationGateReceipt.commitBoundaryId,
            handlerInvocationGateReceipt.queueWriteId,
            handlerInvocationGateReceipt.queueDepthBefore,
            handlerInvocationGateReceipt.queueDepthAfter,
            false,
            "block",
            "blocked-handler-invocation-gate-receipt",
            "collect-accepted-handler-invocation-gate-receipt-first",
            ["HANDLER_INVOCATION_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0471 handler invocation gate input before request-context mutation gate work",
            "QUIC must not consume request-context mutation gate receipts from rejected handler invocation gates"
        )
    }

    let mutationGateMode = igniteRequestContextMutationGateModeFor(
        handlerInvocationGateReceipt.handlerInvocationGateMode
    )
    let blockers = igniteRequestContextMutationGateBlockers(
        request,
        mutationGateMode
    )
    if (blockers.size > 0) {
        return IgniteRequestContextMutationGateReceipt(
            false,
            handlerInvocationGateReceipt.handlerInvocationGateAccepted,
            handlerInvocationGateReceipt.handlerInvocationGateMode,
            mutationGateMode,
            request.requestContextMutationGateId,
            handlerInvocationGateReceipt.handlerInvocationGateId,
            handlerInvocationGateReceipt.runtimeSpawnGateId,
            handlerInvocationGateReceipt.liveEnqueueProofId,
            handlerInvocationGateReceipt.executorHandoffId,
            handlerInvocationGateReceipt.controlledMutationApplyId,
            handlerInvocationGateReceipt.mutationApplyGateId,
            handlerInvocationGateReceipt.mutationCommitPlanId,
            handlerInvocationGateReceipt.mutationDryRunId,
            handlerInvocationGateReceipt.mutationGateId,
            handlerInvocationGateReceipt.commitBoundaryId,
            handlerInvocationGateReceipt.queueWriteId,
            handlerInvocationGateReceipt.queueDepthBefore,
            handlerInvocationGateReceipt.queueDepthAfter,
            false,
            "block",
            "blocked-request-context-mutation-gate-input",
            "fix-request-context-mutation-gate-before-response-write",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry request-context mutation gate id, handler invocation snapshot, request context carrier, ctx mutation plan, route/query/body snapshots, state isolation, error boundary, observability markers, and keep actual ctx mutation out",
            "QUIC can reuse the same context mutation gate blockers before stream response write"
        )
    }

    IgniteRequestContextMutationGateReceipt(
        true,
        handlerInvocationGateReceipt.handlerInvocationGateAccepted,
        handlerInvocationGateReceipt.handlerInvocationGateMode,
        mutationGateMode,
        request.requestContextMutationGateId,
        handlerInvocationGateReceipt.handlerInvocationGateId,
        handlerInvocationGateReceipt.runtimeSpawnGateId,
        handlerInvocationGateReceipt.liveEnqueueProofId,
        handlerInvocationGateReceipt.executorHandoffId,
        handlerInvocationGateReceipt.controlledMutationApplyId,
        handlerInvocationGateReceipt.mutationApplyGateId,
        handlerInvocationGateReceipt.mutationCommitPlanId,
        handlerInvocationGateReceipt.mutationDryRunId,
        handlerInvocationGateReceipt.mutationGateId,
        handlerInvocationGateReceipt.commitBoundaryId,
        handlerInvocationGateReceipt.queueWriteId,
        handlerInvocationGateReceipt.queueDepthBefore,
        handlerInvocationGateReceipt.queueDepthAfter,
        true,
        "record-request-context-mutation-gate",
        "accepted-request-context-mutation-gate-receipt",
        "record-request-context-mutation-gate-without-actual-ctx-mutation",
        [],
        true,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        nonClaims,
        "next packet may prove response-write gate without committing transport",
        "QUIC can reuse lane-specific context mutation gate modes before stream response write gate"
    )
}

func igniteRequestContextMutationGateModeFor(
    handlerInvocationGateMode: String
): String {
    if (handlerInvocationGateMode == "short-handler-invocation-gate") {
        return "short-request-context-mutation-gate"
    }
    if (handlerInvocationGateMode == "long-handler-invocation-gate") {
        return "long-request-context-mutation-gate"
    }
    if (
        handlerInvocationGateMode ==
        "blocking-isolation-handler-invocation-gate"
    ) {
        return "blocking-isolation-request-context-mutation-gate"
    }
    "unknown-request-context-mutation-gate"
}

func igniteRequestContextMutationGateBlockers(
    request: IgniteRequestContextMutationGateRequest,
    mutationGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.requestContextMutationGateId.size == 0) {
        blockers.add("REQUEST_CONTEXT_MUTATION_GATE_ID_NOT_CARRIED")
    }
    if (!request.handlerInvocationGateSnapshotCarried) {
        blockers.add("HANDLER_INVOCATION_GATE_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.requestContextCarrierCarried) {
        blockers.add("REQUEST_CONTEXT_CARRIER_NOT_CARRIED")
    }
    if (!request.ctxMutationPlanCarried) {
        blockers.add("CTX_MUTATION_PLAN_NOT_CARRIED")
    }
    if (!request.routeParamsSnapshotCarried) {
        blockers.add("ROUTE_PARAMS_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.querySnapshotCarried) {
        blockers.add("QUERY_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.bodyAccessPlanCarried) {
        blockers.add("BODY_ACCESS_PLAN_NOT_CARRIED")
    }
    if (!request.stateIsolationCarried) {
        blockers.add("STATE_ISOLATION_NOT_CARRIED")
    }
    if (!request.errorBoundaryCarried) {
        blockers.add("ERROR_BOUNDARY_NOT_CARRIED")
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
    if (request.responseWriteRequested) {
        blockers.add("RESPONSE_WRITE_REQUESTED")
    }
    if (request.transportCommitRequested) {
        blockers.add("TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.liveServerWiringRequested) {
        blockers.add("LIVE_SERVER_WIRING_REQUESTED")
    }
    if (mutationGateMode == "unknown-request-context-mutation-gate") {
        blockers.add("UNKNOWN_HANDLER_INVOCATION_GATE")
    }
    blockers.toArray()
}

func igniteRequestContextMutationGateNonClaims(): Array<String> {
    [
        "NO_LIVE_SERVER_WIRING",
        "NO_PRODUCTION_QUEUE_MUTATION",
        "NO_ACTUAL_RUNTIME_TASK_SPAWN",
        "NO_ACTUAL_HANDLER_INVOCATION",
        "NO_ACTUAL_REQUEST_CONTEXT_MUTATION",
        "NO_RESPONSE_WRITE",
        "NO_TRANSPORT_COMMIT",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
        "NO_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
    ]
}

public class IgniteResponseWriteGateRequest {
    public let responseWriteGateId: String
    public let requestContextMutationGateSnapshotCarried: Bool
    public let responseCarrierCarried: Bool
    public let statusHeaderPlanCarried: Bool
    public let bodyWriterPlanCarried: Bool
    public let streamingPlanCarried: Bool
    public let errorResponsePlanCarried: Bool
    public let backpressurePlanCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let productionQueueMutationRequested: Bool
    public let actualRuntimeTaskSpawnRequested: Bool
    public let actualHandlerInvocationRequested: Bool
    public let actualRequestContextMutationRequested: Bool
    public let actualResponseWriteRequested: Bool
    public let transportCommitRequested: Bool
    public let liveServerWiringRequested: Bool

    public init(
        responseWriteGateId: String,
        requestContextMutationGateSnapshotCarried: Bool,
        responseCarrierCarried: Bool,
        statusHeaderPlanCarried: Bool,
        bodyWriterPlanCarried: Bool,
        streamingPlanCarried: Bool,
        errorResponsePlanCarried: Bool,
        backpressurePlanCarried: Bool,
        observabilityMarkerCarried: Bool,
        productionQueueMutationRequested: Bool,
        actualRuntimeTaskSpawnRequested: Bool,
        actualHandlerInvocationRequested: Bool,
        actualRequestContextMutationRequested: Bool,
        actualResponseWriteRequested: Bool,
        transportCommitRequested: Bool,
        liveServerWiringRequested: Bool
    ) {
        this.responseWriteGateId = responseWriteGateId
        this.requestContextMutationGateSnapshotCarried =
            requestContextMutationGateSnapshotCarried
        this.responseCarrierCarried = responseCarrierCarried
        this.statusHeaderPlanCarried = statusHeaderPlanCarried
        this.bodyWriterPlanCarried = bodyWriterPlanCarried
        this.streamingPlanCarried = streamingPlanCarried
        this.errorResponsePlanCarried = errorResponsePlanCarried
        this.backpressurePlanCarried = backpressurePlanCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
        this.productionQueueMutationRequested = productionQueueMutationRequested
        this.actualRuntimeTaskSpawnRequested = actualRuntimeTaskSpawnRequested
        this.actualHandlerInvocationRequested = actualHandlerInvocationRequested
        this.actualRequestContextMutationRequested =
            actualRequestContextMutationRequested
        this.actualResponseWriteRequested = actualResponseWriteRequested
        this.transportCommitRequested = transportCommitRequested
        this.liveServerWiringRequested = liveServerWiringRequested
    }
}

public class IgniteResponseWriteGateReceipt {
    public let responseWriteGateAccepted: Bool
    public let requestContextMutationGateAccepted: Bool
    public let requestContextMutationGateMode: String
    public let responseWriteGateMode: String
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
    public let responseWriteGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let responseWriteGateAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let actualHandlerInvocationAllowed: Bool
    public let actualRequestContextMutationAllowed: Bool
    public let actualResponseWriteAllowed: Bool
    public let transportCommitAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        responseWriteGateAccepted: Bool,
        requestContextMutationGateAccepted: Bool,
        requestContextMutationGateMode: String,
        responseWriteGateMode: String,
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
        responseWriteGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        responseWriteGateAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        actualHandlerInvocationAllowed: Bool,
        actualRequestContextMutationAllowed: Bool,
        actualResponseWriteAllowed: Bool,
        transportCommitAllowed: Bool,
        liveServerWiringAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.responseWriteGateAccepted = responseWriteGateAccepted
        this.requestContextMutationGateAccepted =
            requestContextMutationGateAccepted
        this.requestContextMutationGateMode = requestContextMutationGateMode
        this.responseWriteGateMode = responseWriteGateMode
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
        this.responseWriteGateRecorded = responseWriteGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.responseWriteGateAllowed = responseWriteGateAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.actualRuntimeTaskSpawnAllowed = actualRuntimeTaskSpawnAllowed
        this.actualHandlerInvocationAllowed = actualHandlerInvocationAllowed
        this.actualRequestContextMutationAllowed =
            actualRequestContextMutationAllowed
        this.actualResponseWriteAllowed = actualResponseWriteAllowed
        this.transportCommitAllowed = transportCommitAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteResponseWriteGateReceipt(
    requestContextMutationGateReceipt: IgniteRequestContextMutationGateReceipt,
    request: IgniteResponseWriteGateRequest
): IgniteResponseWriteGateReceipt {
    let nonClaims = igniteResponseWriteGateNonClaims()
    if (!requestContextMutationGateReceipt.requestContextMutationGateAccepted) {
        return IgniteResponseWriteGateReceipt(
            false,
            requestContextMutationGateReceipt.requestContextMutationGateAccepted,
            requestContextMutationGateReceipt.requestContextMutationGateMode,
            "none",
            request.responseWriteGateId,
            requestContextMutationGateReceipt.requestContextMutationGateId,
            requestContextMutationGateReceipt.handlerInvocationGateId,
            requestContextMutationGateReceipt.runtimeSpawnGateId,
            requestContextMutationGateReceipt.liveEnqueueProofId,
            requestContextMutationGateReceipt.executorHandoffId,
            requestContextMutationGateReceipt.controlledMutationApplyId,
            requestContextMutationGateReceipt.mutationApplyGateId,
            requestContextMutationGateReceipt.mutationCommitPlanId,
            requestContextMutationGateReceipt.mutationDryRunId,
            requestContextMutationGateReceipt.mutationGateId,
            requestContextMutationGateReceipt.commitBoundaryId,
            requestContextMutationGateReceipt.queueWriteId,
            requestContextMutationGateReceipt.queueDepthBefore,
            requestContextMutationGateReceipt.queueDepthAfter,
            false,
            "block",
            "blocked-request-context-mutation-gate-receipt",
            "collect-accepted-request-context-mutation-gate-receipt-first",
            ["REQUEST_CONTEXT_MUTATION_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0473 request-context mutation gate input before response-write gate work",
            "QUIC must not consume response-write gate receipts from rejected request-context mutation gates"
        )
    }

    let writeGateMode = igniteResponseWriteGateModeFor(
        requestContextMutationGateReceipt.requestContextMutationGateMode
    )
    let blockers = igniteResponseWriteGateBlockers(request, writeGateMode)
    if (blockers.size > 0) {
        return IgniteResponseWriteGateReceipt(
            false,
            requestContextMutationGateReceipt.requestContextMutationGateAccepted,
            requestContextMutationGateReceipt.requestContextMutationGateMode,
            writeGateMode,
            request.responseWriteGateId,
            requestContextMutationGateReceipt.requestContextMutationGateId,
            requestContextMutationGateReceipt.handlerInvocationGateId,
            requestContextMutationGateReceipt.runtimeSpawnGateId,
            requestContextMutationGateReceipt.liveEnqueueProofId,
            requestContextMutationGateReceipt.executorHandoffId,
            requestContextMutationGateReceipt.controlledMutationApplyId,
            requestContextMutationGateReceipt.mutationApplyGateId,
            requestContextMutationGateReceipt.mutationCommitPlanId,
            requestContextMutationGateReceipt.mutationDryRunId,
            requestContextMutationGateReceipt.mutationGateId,
            requestContextMutationGateReceipt.commitBoundaryId,
            requestContextMutationGateReceipt.queueWriteId,
            requestContextMutationGateReceipt.queueDepthBefore,
            requestContextMutationGateReceipt.queueDepthAfter,
            false,
            "block",
            "blocked-response-write-gate-input",
            "fix-response-write-gate-before-transport-commit",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry response-write gate id, request-context mutation snapshot, response carrier, status/header plan, body writer plan, streaming plan, error response plan, backpressure plan, observability markers, and keep actual response write out",
            "QUIC can reuse the same response-write gate blockers before stream transport commit"
        )
    }

    IgniteResponseWriteGateReceipt(
        true,
        requestContextMutationGateReceipt.requestContextMutationGateAccepted,
        requestContextMutationGateReceipt.requestContextMutationGateMode,
        writeGateMode,
        request.responseWriteGateId,
        requestContextMutationGateReceipt.requestContextMutationGateId,
        requestContextMutationGateReceipt.handlerInvocationGateId,
        requestContextMutationGateReceipt.runtimeSpawnGateId,
        requestContextMutationGateReceipt.liveEnqueueProofId,
        requestContextMutationGateReceipt.executorHandoffId,
        requestContextMutationGateReceipt.controlledMutationApplyId,
        requestContextMutationGateReceipt.mutationApplyGateId,
        requestContextMutationGateReceipt.mutationCommitPlanId,
        requestContextMutationGateReceipt.mutationDryRunId,
        requestContextMutationGateReceipt.mutationGateId,
        requestContextMutationGateReceipt.commitBoundaryId,
        requestContextMutationGateReceipt.queueWriteId,
        requestContextMutationGateReceipt.queueDepthBefore,
        requestContextMutationGateReceipt.queueDepthAfter,
        true,
        "record-response-write-gate",
        "accepted-response-write-gate-receipt",
        "record-response-write-gate-without-actual-response-write",
        [],
        true,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        nonClaims,
        "next packet may prove transport-commit gate without writing socket transport",
        "QUIC can reuse lane-specific response-write gate modes before stream transport commit gate"
    )
}

func igniteResponseWriteGateModeFor(
    requestContextMutationGateMode: String
): String {
    if (
        requestContextMutationGateMode ==
        "short-request-context-mutation-gate"
    ) {
        return "short-response-write-gate"
    }
    if (
        requestContextMutationGateMode ==
        "long-request-context-mutation-gate"
    ) {
        return "long-response-write-gate"
    }
    if (
        requestContextMutationGateMode ==
        "blocking-isolation-request-context-mutation-gate"
    ) {
        return "blocking-isolation-response-write-gate"
    }
    "unknown-response-write-gate"
}

func igniteResponseWriteGateBlockers(
    request: IgniteResponseWriteGateRequest,
    writeGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.responseWriteGateId.size == 0) {
        blockers.add("RESPONSE_WRITE_GATE_ID_NOT_CARRIED")
    }
    if (!request.requestContextMutationGateSnapshotCarried) {
        blockers.add("REQUEST_CONTEXT_MUTATION_GATE_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.responseCarrierCarried) {
        blockers.add("RESPONSE_CARRIER_NOT_CARRIED")
    }
    if (!request.statusHeaderPlanCarried) {
        blockers.add("STATUS_HEADER_PLAN_NOT_CARRIED")
    }
    if (!request.bodyWriterPlanCarried) {
        blockers.add("BODY_WRITER_PLAN_NOT_CARRIED")
    }
    if (!request.streamingPlanCarried) {
        blockers.add("STREAMING_PLAN_NOT_CARRIED")
    }
    if (!request.errorResponsePlanCarried) {
        blockers.add("ERROR_RESPONSE_PLAN_NOT_CARRIED")
    }
    if (!request.backpressurePlanCarried) {
        blockers.add("BACKPRESSURE_PLAN_NOT_CARRIED")
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
    if (request.transportCommitRequested) {
        blockers.add("TRANSPORT_COMMIT_REQUESTED")
    }
    if (request.liveServerWiringRequested) {
        blockers.add("LIVE_SERVER_WIRING_REQUESTED")
    }
    if (writeGateMode == "unknown-response-write-gate") {
        blockers.add("UNKNOWN_REQUEST_CONTEXT_MUTATION_GATE")
    }
    blockers.toArray()
}

func igniteResponseWriteGateNonClaims(): Array<String> {
    [
        "NO_LIVE_SERVER_WIRING",
        "NO_PRODUCTION_QUEUE_MUTATION",
        "NO_ACTUAL_RUNTIME_TASK_SPAWN",
        "NO_ACTUAL_HANDLER_INVOCATION",
        "NO_ACTUAL_REQUEST_CONTEXT_MUTATION",
        "NO_ACTUAL_RESPONSE_WRITE",
        "NO_TRANSPORT_COMMIT",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
        "NO_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
    ]
}

public class IgniteTransportCommitGateRequest {
    public let transportCommitGateId: String
    public let responseWriteGateSnapshotCarried: Bool
    public let transportCarrierCarried: Bool
    public let protocolFramePlanCarried: Bool
    public let flushPlanCarried: Bool
    public let completionPlanCarried: Bool
    public let failureRecoveryPlanCarried: Bool
    public let backpressureReleasePlanCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let productionQueueMutationRequested: Bool
    public let actualRuntimeTaskSpawnRequested: Bool
    public let actualHandlerInvocationRequested: Bool
    public let actualRequestContextMutationRequested: Bool
    public let actualResponseWriteRequested: Bool
    public let actualTransportCommitRequested: Bool
    public let liveServerWiringRequested: Bool

    public init(
        transportCommitGateId: String,
        responseWriteGateSnapshotCarried: Bool,
        transportCarrierCarried: Bool,
        protocolFramePlanCarried: Bool,
        flushPlanCarried: Bool,
        completionPlanCarried: Bool,
        failureRecoveryPlanCarried: Bool,
        backpressureReleasePlanCarried: Bool,
        observabilityMarkerCarried: Bool,
        productionQueueMutationRequested: Bool,
        actualRuntimeTaskSpawnRequested: Bool,
        actualHandlerInvocationRequested: Bool,
        actualRequestContextMutationRequested: Bool,
        actualResponseWriteRequested: Bool,
        actualTransportCommitRequested: Bool,
        liveServerWiringRequested: Bool
    ) {
        this.transportCommitGateId = transportCommitGateId
        this.responseWriteGateSnapshotCarried =
            responseWriteGateSnapshotCarried
        this.transportCarrierCarried = transportCarrierCarried
        this.protocolFramePlanCarried = protocolFramePlanCarried
        this.flushPlanCarried = flushPlanCarried
        this.completionPlanCarried = completionPlanCarried
        this.failureRecoveryPlanCarried = failureRecoveryPlanCarried
        this.backpressureReleasePlanCarried = backpressureReleasePlanCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
        this.productionQueueMutationRequested = productionQueueMutationRequested
        this.actualRuntimeTaskSpawnRequested = actualRuntimeTaskSpawnRequested
        this.actualHandlerInvocationRequested = actualHandlerInvocationRequested
        this.actualRequestContextMutationRequested =
            actualRequestContextMutationRequested
        this.actualResponseWriteRequested = actualResponseWriteRequested
        this.actualTransportCommitRequested = actualTransportCommitRequested
        this.liveServerWiringRequested = liveServerWiringRequested
    }
}

public class IgniteTransportCommitGateReceipt {
    public let transportCommitGateAccepted: Bool
    public let responseWriteGateAccepted: Bool
    public let responseWriteGateMode: String
    public let transportCommitGateMode: String
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
    public let transportCommitGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let transportCommitGateAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let actualHandlerInvocationAllowed: Bool
    public let actualRequestContextMutationAllowed: Bool
    public let actualResponseWriteAllowed: Bool
    public let actualTransportCommitAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        transportCommitGateAccepted: Bool,
        responseWriteGateAccepted: Bool,
        responseWriteGateMode: String,
        transportCommitGateMode: String,
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
        transportCommitGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        transportCommitGateAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        actualHandlerInvocationAllowed: Bool,
        actualRequestContextMutationAllowed: Bool,
        actualResponseWriteAllowed: Bool,
        actualTransportCommitAllowed: Bool,
        liveServerWiringAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.transportCommitGateAccepted = transportCommitGateAccepted
        this.responseWriteGateAccepted = responseWriteGateAccepted
        this.responseWriteGateMode = responseWriteGateMode
        this.transportCommitGateMode = transportCommitGateMode
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
        this.transportCommitGateRecorded = transportCommitGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.transportCommitGateAllowed = transportCommitGateAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.actualRuntimeTaskSpawnAllowed = actualRuntimeTaskSpawnAllowed
        this.actualHandlerInvocationAllowed = actualHandlerInvocationAllowed
        this.actualRequestContextMutationAllowed =
            actualRequestContextMutationAllowed
        this.actualResponseWriteAllowed = actualResponseWriteAllowed
        this.actualTransportCommitAllowed = actualTransportCommitAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteTransportCommitGateReceipt(
    responseWriteGateReceipt: IgniteResponseWriteGateReceipt,
    request: IgniteTransportCommitGateRequest
): IgniteTransportCommitGateReceipt {
    let nonClaims = igniteTransportCommitGateNonClaims()
    if (!responseWriteGateReceipt.responseWriteGateAccepted) {
        return IgniteTransportCommitGateReceipt(
            false,
            responseWriteGateReceipt.responseWriteGateAccepted,
            responseWriteGateReceipt.responseWriteGateMode,
            "none",
            request.transportCommitGateId,
            responseWriteGateReceipt.responseWriteGateId,
            responseWriteGateReceipt.requestContextMutationGateId,
            responseWriteGateReceipt.handlerInvocationGateId,
            responseWriteGateReceipt.runtimeSpawnGateId,
            responseWriteGateReceipt.liveEnqueueProofId,
            responseWriteGateReceipt.executorHandoffId,
            responseWriteGateReceipt.controlledMutationApplyId,
            responseWriteGateReceipt.mutationApplyGateId,
            responseWriteGateReceipt.mutationCommitPlanId,
            responseWriteGateReceipt.mutationDryRunId,
            responseWriteGateReceipt.mutationGateId,
            responseWriteGateReceipt.commitBoundaryId,
            responseWriteGateReceipt.queueWriteId,
            responseWriteGateReceipt.queueDepthBefore,
            responseWriteGateReceipt.queueDepthAfter,
            false,
            "block",
            "blocked-response-write-gate-receipt",
            "collect-accepted-response-write-gate-receipt-first",
            ["RESPONSE_WRITE_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "return to HQ-0474 response-write gate input before transport-commit gate work",
            "QUIC must not consume transport-commit gate receipts from rejected response-write gates"
        )
    }

    let commitGateMode = igniteTransportCommitGateModeFor(
        responseWriteGateReceipt.responseWriteGateMode
    )
    let blockers = igniteTransportCommitGateBlockers(request, commitGateMode)
    if (blockers.size > 0) {
        return IgniteTransportCommitGateReceipt(
            false,
            responseWriteGateReceipt.responseWriteGateAccepted,
            responseWriteGateReceipt.responseWriteGateMode,
            commitGateMode,
            request.transportCommitGateId,
            responseWriteGateReceipt.responseWriteGateId,
            responseWriteGateReceipt.requestContextMutationGateId,
            responseWriteGateReceipt.handlerInvocationGateId,
            responseWriteGateReceipt.runtimeSpawnGateId,
            responseWriteGateReceipt.liveEnqueueProofId,
            responseWriteGateReceipt.executorHandoffId,
            responseWriteGateReceipt.controlledMutationApplyId,
            responseWriteGateReceipt.mutationApplyGateId,
            responseWriteGateReceipt.mutationCommitPlanId,
            responseWriteGateReceipt.mutationDryRunId,
            responseWriteGateReceipt.mutationGateId,
            responseWriteGateReceipt.commitBoundaryId,
            responseWriteGateReceipt.queueWriteId,
            responseWriteGateReceipt.queueDepthBefore,
            responseWriteGateReceipt.queueDepthAfter,
            false,
            "block",
            "blocked-transport-commit-gate-input",
            "fix-transport-commit-gate-before-live-server-wiring",
            blockers,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            nonClaims,
            "carry transport-commit gate id, response-write snapshot, transport carrier, protocol frame plan, flush plan, completion plan, failure recovery plan, backpressure release plan, observability markers, and keep actual transport commit out",
            "QUIC can reuse the same transport-commit gate blockers before live stream wiring"
        )
    }

    IgniteTransportCommitGateReceipt(
        true,
        responseWriteGateReceipt.responseWriteGateAccepted,
        responseWriteGateReceipt.responseWriteGateMode,
        commitGateMode,
        request.transportCommitGateId,
        responseWriteGateReceipt.responseWriteGateId,
        responseWriteGateReceipt.requestContextMutationGateId,
        responseWriteGateReceipt.handlerInvocationGateId,
        responseWriteGateReceipt.runtimeSpawnGateId,
        responseWriteGateReceipt.liveEnqueueProofId,
        responseWriteGateReceipt.executorHandoffId,
        responseWriteGateReceipt.controlledMutationApplyId,
        responseWriteGateReceipt.mutationApplyGateId,
        responseWriteGateReceipt.mutationCommitPlanId,
        responseWriteGateReceipt.mutationDryRunId,
        responseWriteGateReceipt.mutationGateId,
        responseWriteGateReceipt.commitBoundaryId,
        responseWriteGateReceipt.queueWriteId,
        responseWriteGateReceipt.queueDepthBefore,
        responseWriteGateReceipt.queueDepthAfter,
        true,
        "record-transport-commit-gate",
        "accepted-transport-commit-gate-receipt",
        "record-transport-commit-gate-without-actual-transport-commit",
        [],
        true,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        nonClaims,
        "next packet may prove live-server wiring gate without flipping the default engine",
        "QUIC can reuse lane-specific transport-commit gate modes before live stream wiring gate"
    )
}

func igniteTransportCommitGateModeFor(
    responseWriteGateMode: String
): String {
    if (responseWriteGateMode == "short-response-write-gate") {
        return "short-transport-commit-gate"
    }
    if (responseWriteGateMode == "long-response-write-gate") {
        return "long-transport-commit-gate"
    }
    if (responseWriteGateMode == "blocking-isolation-response-write-gate") {
        return "blocking-isolation-transport-commit-gate"
    }
    "unknown-transport-commit-gate"
}

func igniteTransportCommitGateBlockers(
    request: IgniteTransportCommitGateRequest,
    commitGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.transportCommitGateId.size == 0) {
        blockers.add("TRANSPORT_COMMIT_GATE_ID_NOT_CARRIED")
    }
    if (!request.responseWriteGateSnapshotCarried) {
        blockers.add("RESPONSE_WRITE_GATE_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.transportCarrierCarried) {
        blockers.add("TRANSPORT_CARRIER_NOT_CARRIED")
    }
    if (!request.protocolFramePlanCarried) {
        blockers.add("PROTOCOL_FRAME_PLAN_NOT_CARRIED")
    }
    if (!request.flushPlanCarried) {
        blockers.add("FLUSH_PLAN_NOT_CARRIED")
    }
    if (!request.completionPlanCarried) {
        blockers.add("COMPLETION_PLAN_NOT_CARRIED")
    }
    if (!request.failureRecoveryPlanCarried) {
        blockers.add("FAILURE_RECOVERY_PLAN_NOT_CARRIED")
    }
    if (!request.backpressureReleasePlanCarried) {
        blockers.add("BACKPRESSURE_RELEASE_PLAN_NOT_CARRIED")
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
    if (request.liveServerWiringRequested) {
        blockers.add("LIVE_SERVER_WIRING_REQUESTED")
    }
    if (commitGateMode == "unknown-transport-commit-gate") {
        blockers.add("UNKNOWN_RESPONSE_WRITE_GATE")
    }
    blockers.toArray()
}

func igniteTransportCommitGateNonClaims(): Array<String> {
    [
        "NO_LIVE_SERVER_WIRING",
        "NO_PRODUCTION_QUEUE_MUTATION",
        "NO_ACTUAL_RUNTIME_TASK_SPAWN",
        "NO_ACTUAL_HANDLER_INVOCATION",
        "NO_ACTUAL_REQUEST_CONTEXT_MUTATION",
        "NO_ACTUAL_RESPONSE_WRITE",
        "NO_ACTUAL_TRANSPORT_COMMIT",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
        "NO_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
    ]
}

public class IgniteLiveServerWiringGateRequest {
    public let liveServerWiringGateId: String
    public let transportCommitGateSnapshotCarried: Bool
    public let serverLifecyclePlanCarried: Bool
    public let listenerBindingPlanCarried: Bool
    public let connectionAcceptPlanCarried: Bool
    public let requestDispatchLoopPlanCarried: Bool
    public let shutdownPlanCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let productionQueueMutationRequested: Bool
    public let actualRuntimeTaskSpawnRequested: Bool
    public let actualHandlerInvocationRequested: Bool
    public let actualRequestContextMutationRequested: Bool
    public let actualResponseWriteRequested: Bool
    public let actualTransportCommitRequested: Bool
    public let actualLiveServerWiringRequested: Bool
    public let defaultEngineFlipRequested: Bool

    public init(
        liveServerWiringGateId: String,
        transportCommitGateSnapshotCarried: Bool,
        serverLifecyclePlanCarried: Bool,
        listenerBindingPlanCarried: Bool,
        connectionAcceptPlanCarried: Bool,
        requestDispatchLoopPlanCarried: Bool,
        shutdownPlanCarried: Bool,
        observabilityMarkerCarried: Bool,
        productionQueueMutationRequested: Bool,
        actualRuntimeTaskSpawnRequested: Bool,
        actualHandlerInvocationRequested: Bool,
        actualRequestContextMutationRequested: Bool,
        actualResponseWriteRequested: Bool,
        actualTransportCommitRequested: Bool,
        actualLiveServerWiringRequested: Bool,
        defaultEngineFlipRequested: Bool
    ) {
        this.liveServerWiringGateId = liveServerWiringGateId
        this.transportCommitGateSnapshotCarried =
            transportCommitGateSnapshotCarried
        this.serverLifecyclePlanCarried = serverLifecyclePlanCarried
        this.listenerBindingPlanCarried = listenerBindingPlanCarried
        this.connectionAcceptPlanCarried = connectionAcceptPlanCarried
        this.requestDispatchLoopPlanCarried = requestDispatchLoopPlanCarried
        this.shutdownPlanCarried = shutdownPlanCarried
        this.observabilityMarkerCarried = observabilityMarkerCarried
        this.productionQueueMutationRequested = productionQueueMutationRequested
        this.actualRuntimeTaskSpawnRequested = actualRuntimeTaskSpawnRequested
        this.actualHandlerInvocationRequested = actualHandlerInvocationRequested
        this.actualRequestContextMutationRequested =
            actualRequestContextMutationRequested
        this.actualResponseWriteRequested = actualResponseWriteRequested
        this.actualTransportCommitRequested = actualTransportCommitRequested
        this.actualLiveServerWiringRequested = actualLiveServerWiringRequested
        this.defaultEngineFlipRequested = defaultEngineFlipRequested
    }
}

public class IgniteLiveServerWiringGateReceipt {
    public let liveServerWiringGateAccepted: Bool
    public let transportCommitGateAccepted: Bool
    public let transportCommitGateMode: String
    public let liveServerWiringGateMode: String
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
    public let liveServerWiringGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let liveServerWiringGateAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let actualHandlerInvocationAllowed: Bool
    public let actualRequestContextMutationAllowed: Bool
    public let actualResponseWriteAllowed: Bool
    public let actualTransportCommitAllowed: Bool
    public let actualLiveServerWiringAllowed: Bool
    public let defaultEngineFlipAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        liveServerWiringGateAccepted: Bool,
        transportCommitGateAccepted: Bool,
        transportCommitGateMode: String,
        liveServerWiringGateMode: String,
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
        liveServerWiringGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        liveServerWiringGateAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        actualHandlerInvocationAllowed: Bool,
        actualRequestContextMutationAllowed: Bool,
        actualResponseWriteAllowed: Bool,
        actualTransportCommitAllowed: Bool,
        actualLiveServerWiringAllowed: Bool,
        defaultEngineFlipAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.liveServerWiringGateAccepted = liveServerWiringGateAccepted
        this.transportCommitGateAccepted = transportCommitGateAccepted
        this.transportCommitGateMode = transportCommitGateMode
        this.liveServerWiringGateMode = liveServerWiringGateMode
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
        this.liveServerWiringGateRecorded = liveServerWiringGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.liveServerWiringGateAllowed = liveServerWiringGateAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.actualRuntimeTaskSpawnAllowed = actualRuntimeTaskSpawnAllowed
        this.actualHandlerInvocationAllowed = actualHandlerInvocationAllowed
        this.actualRequestContextMutationAllowed =
            actualRequestContextMutationAllowed
        this.actualResponseWriteAllowed = actualResponseWriteAllowed
        this.actualTransportCommitAllowed = actualTransportCommitAllowed
        this.actualLiveServerWiringAllowed = actualLiveServerWiringAllowed
        this.defaultEngineFlipAllowed = defaultEngineFlipAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteLiveServerWiringGateReceipt(
    transportCommitGateReceipt: IgniteTransportCommitGateReceipt,
    request: IgniteLiveServerWiringGateRequest
): IgniteLiveServerWiringGateReceipt {
    let nonClaims = igniteLiveServerWiringGateNonClaims()
    if (!transportCommitGateReceipt.transportCommitGateAccepted) {
        return IgniteLiveServerWiringGateReceipt(
            false,
            transportCommitGateReceipt.transportCommitGateAccepted,
            transportCommitGateReceipt.transportCommitGateMode,
            "none",
            request.liveServerWiringGateId,
            transportCommitGateReceipt.transportCommitGateId,
            transportCommitGateReceipt.responseWriteGateId,
            transportCommitGateReceipt.requestContextMutationGateId,
            transportCommitGateReceipt.handlerInvocationGateId,
            transportCommitGateReceipt.runtimeSpawnGateId,
            transportCommitGateReceipt.liveEnqueueProofId,
            transportCommitGateReceipt.executorHandoffId,
            transportCommitGateReceipt.controlledMutationApplyId,
            transportCommitGateReceipt.mutationApplyGateId,
            transportCommitGateReceipt.mutationCommitPlanId,
            transportCommitGateReceipt.mutationDryRunId,
            transportCommitGateReceipt.mutationGateId,
            transportCommitGateReceipt.commitBoundaryId,
            transportCommitGateReceipt.queueWriteId,
            transportCommitGateReceipt.queueDepthBefore,
            transportCommitGateReceipt.queueDepthAfter,
            false,
            "block",
            "blocked-transport-commit-gate-receipt",
            "collect-accepted-transport-commit-gate-receipt-first",
            ["TRANSPORT_COMMIT_GATE_NOT_ACCEPTED"],
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
            "return to HQ-0475 transport-commit gate input before live-server-wiring gate work",
            "QUIC must not consume live-server-wiring gate receipts from rejected transport-commit gates"
        )
    }

    let wiringGateMode = igniteLiveServerWiringGateModeFor(
        transportCommitGateReceipt.transportCommitGateMode
    )
    let blockers = igniteLiveServerWiringGateBlockers(request, wiringGateMode)
    if (blockers.size > 0) {
        return IgniteLiveServerWiringGateReceipt(
            false,
            transportCommitGateReceipt.transportCommitGateAccepted,
            transportCommitGateReceipt.transportCommitGateMode,
            wiringGateMode,
            request.liveServerWiringGateId,
            transportCommitGateReceipt.transportCommitGateId,
            transportCommitGateReceipt.responseWriteGateId,
            transportCommitGateReceipt.requestContextMutationGateId,
            transportCommitGateReceipt.handlerInvocationGateId,
            transportCommitGateReceipt.runtimeSpawnGateId,
            transportCommitGateReceipt.liveEnqueueProofId,
            transportCommitGateReceipt.executorHandoffId,
            transportCommitGateReceipt.controlledMutationApplyId,
            transportCommitGateReceipt.mutationApplyGateId,
            transportCommitGateReceipt.mutationCommitPlanId,
            transportCommitGateReceipt.mutationDryRunId,
            transportCommitGateReceipt.mutationGateId,
            transportCommitGateReceipt.commitBoundaryId,
            transportCommitGateReceipt.queueWriteId,
            transportCommitGateReceipt.queueDepthBefore,
            transportCommitGateReceipt.queueDepthAfter,
            false,
            "block",
            "blocked-live-server-wiring-gate-input",
            "fix-live-server-wiring-gate-before-default-engine-flip",
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
            nonClaims,
            "carry live-server-wiring gate id, transport-commit snapshot, server lifecycle plan, listener binding plan, connection accept plan, request dispatch loop plan, shutdown plan, observability markers, and keep actual live wiring out",
            "QUIC can reuse the same live-server-wiring gate blockers before default stream runtime flip"
        )
    }

    IgniteLiveServerWiringGateReceipt(
        true,
        transportCommitGateReceipt.transportCommitGateAccepted,
        transportCommitGateReceipt.transportCommitGateMode,
        wiringGateMode,
        request.liveServerWiringGateId,
        transportCommitGateReceipt.transportCommitGateId,
        transportCommitGateReceipt.responseWriteGateId,
        transportCommitGateReceipt.requestContextMutationGateId,
        transportCommitGateReceipt.handlerInvocationGateId,
        transportCommitGateReceipt.runtimeSpawnGateId,
        transportCommitGateReceipt.liveEnqueueProofId,
        transportCommitGateReceipt.executorHandoffId,
        transportCommitGateReceipt.controlledMutationApplyId,
        transportCommitGateReceipt.mutationApplyGateId,
        transportCommitGateReceipt.mutationCommitPlanId,
        transportCommitGateReceipt.mutationDryRunId,
        transportCommitGateReceipt.mutationGateId,
        transportCommitGateReceipt.commitBoundaryId,
        transportCommitGateReceipt.queueWriteId,
        transportCommitGateReceipt.queueDepthBefore,
        transportCommitGateReceipt.queueDepthAfter,
        true,
        "record-live-server-wiring-gate",
        "accepted-live-server-wiring-gate-receipt",
        "record-live-server-wiring-gate-without-actual-live-wiring",
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
        nonClaims,
        "next packet may prove default-engine-flip readiness without flipping the default engine",
        "QUIC can reuse lane-specific live-server-wiring gate modes before runtime default flip"
    )
}

func igniteLiveServerWiringGateModeFor(
    transportCommitGateMode: String
): String {
    if (transportCommitGateMode == "short-transport-commit-gate") {
        return "short-live-server-wiring-gate"
    }
    if (transportCommitGateMode == "long-transport-commit-gate") {
        return "long-live-server-wiring-gate"
    }
    if (transportCommitGateMode == "blocking-isolation-transport-commit-gate") {
        return "blocking-isolation-live-server-wiring-gate"
    }
    "unknown-live-server-wiring-gate"
}

func igniteLiveServerWiringGateBlockers(
    request: IgniteLiveServerWiringGateRequest,
    wiringGateMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.liveServerWiringGateId.size == 0) {
        blockers.add("LIVE_SERVER_WIRING_GATE_ID_NOT_CARRIED")
    }
    if (!request.transportCommitGateSnapshotCarried) {
        blockers.add("TRANSPORT_COMMIT_GATE_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.serverLifecyclePlanCarried) {
        blockers.add("SERVER_LIFECYCLE_PLAN_NOT_CARRIED")
    }
    if (!request.listenerBindingPlanCarried) {
        blockers.add("LISTENER_BINDING_PLAN_NOT_CARRIED")
    }
    if (!request.connectionAcceptPlanCarried) {
        blockers.add("CONNECTION_ACCEPT_PLAN_NOT_CARRIED")
    }
    if (!request.requestDispatchLoopPlanCarried) {
        blockers.add("REQUEST_DISPATCH_LOOP_PLAN_NOT_CARRIED")
    }
    if (!request.shutdownPlanCarried) {
        blockers.add("SHUTDOWN_PLAN_NOT_CARRIED")
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
    if (request.defaultEngineFlipRequested) {
        blockers.add("DEFAULT_ENGINE_FLIP_REQUESTED")
    }
    if (wiringGateMode == "unknown-live-server-wiring-gate") {
        blockers.add("UNKNOWN_TRANSPORT_COMMIT_GATE")
    }
    blockers.toArray()
}

func igniteLiveServerWiringGateNonClaims(): Array<String> {
    [
        "NO_ACTUAL_LIVE_SERVER_WIRING",
        "NO_DEFAULT_ENGINE_FLIP",
        "NO_PRODUCTION_QUEUE_MUTATION",
        "NO_ACTUAL_RUNTIME_TASK_SPAWN",
        "NO_ACTUAL_HANDLER_INVOCATION",
        "NO_ACTUAL_REQUEST_CONTEXT_MUTATION",
        "NO_ACTUAL_RESPONSE_WRITE",
        "NO_ACTUAL_TRANSPORT_COMMIT",
        "NO_PUBLIC_API",
        "NO_PERFORMANCE_CLAIM",
        "NO_H2_QUIC_RUNTIME_CLOSURE_CLAIM",
    ]
}

public class IgniteDefaultEngineFlipReadinessGateRequest {
    public let defaultEngineFlipReadinessGateId: String
    public let liveServerWiringGateSnapshotCarried: Bool
    public let defaultEngineCandidatePlanCarried: Bool
    public let rollbackPlanCarried: Bool
    public let releaseGuardPlanCarried: Bool
    public let runtimeParityProofPlanCarried: Bool
    public let stdxReplacementBoundaryCarried: Bool
    public let observabilityMarkerCarried: Bool
    public let productionQueueMutationRequested: Bool
    public let actualRuntimeTaskSpawnRequested: Bool
    public let actualHandlerInvocationRequested: Bool
    public let actualRequestContextMutationRequested: Bool
    public let actualResponseWriteRequested: Bool
    public let actualTransportCommitRequested: Bool
    public let actualLiveServerWiringRequested: Bool
    public let actualDefaultEngineFlipRequested: Bool
    public let publicReleaseRequested: Bool
    public let stdxRemovalRequested: Bool
    public let h1H2QuicRuntimeClosureClaimed: Bool

    public init(
        defaultEngineFlipReadinessGateId: String,
        liveServerWiringGateSnapshotCarried: Bool,
        defaultEngineCandidatePlanCarried: Bool,
        rollbackPlanCarried: Bool,
        releaseGuardPlanCarried: Bool,
        runtimeParityProofPlanCarried: Bool,
        stdxReplacementBoundaryCarried: Bool,
        observabilityMarkerCarried: Bool,
        productionQueueMutationRequested: Bool,
        actualRuntimeTaskSpawnRequested: Bool,
        actualHandlerInvocationRequested: Bool,
        actualRequestContextMutationRequested: Bool,
        actualResponseWriteRequested: Bool,
        actualTransportCommitRequested: Bool,
        actualLiveServerWiringRequested: Bool,
        actualDefaultEngineFlipRequested: Bool,
        publicReleaseRequested: Bool,
        stdxRemovalRequested: Bool,
        h1H2QuicRuntimeClosureClaimed: Bool
    ) {
        this.defaultEngineFlipReadinessGateId =
            defaultEngineFlipReadinessGateId
        this.liveServerWiringGateSnapshotCarried =
            liveServerWiringGateSnapshotCarried
        this.defaultEngineCandidatePlanCarried =
            defaultEngineCandidatePlanCarried
        this.rollbackPlanCarried = rollbackPlanCarried
        this.releaseGuardPlanCarried = releaseGuardPlanCarried
        this.runtimeParityProofPlanCarried = runtimeParityProofPlanCarried
        this.stdxReplacementBoundaryCarried = stdxReplacementBoundaryCarried
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
        this.publicReleaseRequested = publicReleaseRequested
        this.stdxRemovalRequested = stdxRemovalRequested
        this.h1H2QuicRuntimeClosureClaimed = h1H2QuicRuntimeClosureClaimed
    }
}

public class IgniteDefaultEngineFlipReadinessGateReceipt {
    public let defaultEngineFlipReadinessAccepted: Bool
    public let liveServerWiringGateAccepted: Bool
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
    public let defaultEngineFlipReadinessGateRecorded: Bool
    public let action: String
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let defaultEngineFlipReadinessAllowed: Bool
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
    public let h1H2QuicRuntimeClosureClaimAllowed: Bool
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        defaultEngineFlipReadinessAccepted: Bool,
        liveServerWiringGateAccepted: Bool,
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
        defaultEngineFlipReadinessGateRecorded: Bool,
        action: String,
        status: String,
        decision: String,
        blockers: Array<String>,
        defaultEngineFlipReadinessAllowed: Bool,
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
        h1H2QuicRuntimeClosureClaimAllowed: Bool,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.defaultEngineFlipReadinessAccepted =
            defaultEngineFlipReadinessAccepted
        this.liveServerWiringGateAccepted = liveServerWiringGateAccepted
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
        this.defaultEngineFlipReadinessGateRecorded =
            defaultEngineFlipReadinessGateRecorded
        this.action = action
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.defaultEngineFlipReadinessAllowed =
            defaultEngineFlipReadinessAllowed
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
        this.h1H2QuicRuntimeClosureClaimAllowed =
            h1H2QuicRuntimeClosureClaimAllowed
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildIgniteDefaultEngineFlipReadinessGateReceipt(
    liveServerWiringGateReceipt: IgniteLiveServerWiringGateReceipt,
    request: IgniteDefaultEngineFlipReadinessGateRequest
): IgniteDefaultEngineFlipReadinessGateReceipt {
    let nonClaims = igniteDefaultEngineFlipReadinessGateNonClaims()
    if (!liveServerWiringGateReceipt.liveServerWiringGateAccepted) {
        return IgniteDefaultEngineFlipReadinessGateReceipt(
            false,
            liveServerWiringGateReceipt.liveServerWiringGateAccepted,
            liveServerWiringGateReceipt.liveServerWiringGateMode,
            "none",
            request.defaultEngineFlipReadinessGateId,
            liveServerWiringGateReceipt.liveServerWiringGateId,
            liveServerWiringGateReceipt.transportCommitGateId,
            liveServerWiringGateReceipt.responseWriteGateId,
            liveServerWiringGateReceipt.requestContextMutationGateId,
            liveServerWiringGateReceipt.handlerInvocationGateId,
            liveServerWiringGateReceipt.runtimeSpawnGateId,
            liveServerWiringGateReceipt.liveEnqueueProofId,
            liveServerWiringGateReceipt.executorHandoffId,
            liveServerWiringGateReceipt.controlledMutationApplyId,
            liveServerWiringGateReceipt.mutationApplyGateId,
            liveServerWiringGateReceipt.mutationCommitPlanId,
            liveServerWiringGateReceipt.mutationDryRunId,
            liveServerWiringGateReceipt.mutationGateId,
            liveServerWiringGateReceipt.commitBoundaryId,
            liveServerWiringGateReceipt.queueWriteId,
            liveServerWiringGateReceipt.queueDepthBefore,
            liveServerWiringGateReceipt.queueDepthAfter,
            false,
            "block",
            "blocked-live-server-wiring-gate-receipt",
            "collect-accepted-live-server-wiring-gate-receipt-first",
            ["LIVE_SERVER_WIRING_GATE_NOT_ACCEPTED"],
            false,
            false,
            false,
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
            "return to HQ-0476 live-server-wiring gate input before default-engine-flip readiness work",
            "QUIC must not consume default-engine-flip readiness receipts from rejected live-server-wiring gates"
        )
    }

    let readinessMode = igniteDefaultEngineFlipReadinessGateModeFor(
        liveServerWiringGateReceipt.liveServerWiringGateMode
    )
    let blockers = igniteDefaultEngineFlipReadinessGateBlockers(
        request,
        readinessMode
    )
    if (blockers.size > 0) {
        return IgniteDefaultEngineFlipReadinessGateReceipt(
            false,
            liveServerWiringGateReceipt.liveServerWiringGateAccepted,
            liveServerWiringGateReceipt.liveServerWiringGateMode,
            readinessMode,
            request.defaultEngineFlipReadinessGateId,
            liveServerWiringGateReceipt.liveServerWiringGateId,
            liveServerWiringGateReceipt.transportCommitGateId,
            liveServerWiringGateReceipt.responseWriteGateId,
            liveServerWiringGateReceipt.requestContextMutationGateId,
            liveServerWiringGateReceipt.handlerInvocationGateId,
            liveServerWiringGateReceipt.runtimeSpawnGateId,
            liveServerWiringGateReceipt.liveEnqueueProofId,
            liveServerWiringGateReceipt.executorHandoffId,
            liveServerWiringGateReceipt.controlledMutationApplyId,
            liveServerWiringGateReceipt.mutationApplyGateId,
            liveServerWiringGateReceipt.mutationCommitPlanId,
            liveServerWiringGateReceipt.mutationDryRunId,
            liveServerWiringGateReceipt.mutationGateId,
            liveServerWiringGateReceipt.commitBoundaryId,
            liveServerWiringGateReceipt.queueWriteId,
            liveServerWiringGateReceipt.queueDepthBefore,
            liveServerWiringGateReceipt.queueDepthAfter,
            false,
            "block",
            "blocked-default-engine-flip-readiness-gate-input",
            "fix-default-engine-flip-readiness-gate-before-runtime-flip",
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
            nonClaims,
            "carry readiness gate id, live-server-wiring snapshot, default engine candidate plan, rollback plan, release guard plan, runtime parity proof plan, stdx boundary, and keep the default flip out",
            "QUIC can reuse the same default-engine-flip readiness blockers before default stream runtime flip"
        )
    }

    IgniteDefaultEngineFlipReadinessGateReceipt(
        true,
        liveServerWiringGateReceipt.liveServerWiringGateAccepted,
        liveServerWiringGateReceipt.liveServerWiringGateMode,
        readinessMode,
        request.defaultEngineFlipReadinessGateId,
        liveServerWiringGateReceipt.liveServerWiringGateId,
        liveServerWiringGateReceipt.transportCommitGateId,
        liveServerWiringGateReceipt.responseWriteGateId,
        liveServerWiringGateReceipt.requestContextMutationGateId,
        liveServerWiringGateReceipt.handlerInvocationGateId,
        liveServerWiringGateReceipt.runtimeSpawnGateId,
        liveServerWiringGateReceipt.liveEnqueueProofId,
        liveServerWiringGateReceipt.executorHandoffId,
        liveServerWiringGateReceipt.controlledMutationApplyId,
        liveServerWiringGateReceipt.mutationApplyGateId,
        liveServerWiringGateReceipt.mutationCommitPlanId,
        liveServerWiringGateReceipt.mutationDryRunId,
        liveServerWiringGateReceipt.mutationGateId,
        liveServerWiringGateReceipt.commitBoundaryId,
        liveServerWiringGateReceipt.queueWriteId,
        liveServerWiringGateReceipt.queueDepthBefore,
        liveServerWiringGateReceipt.queueDepthAfter,
        true,
        "record-default-engine-flip-readiness-gate",
        "accepted-default-engine-flip-readiness-gate-receipt",
        "record-default-engine-flip-readiness-without-default-engine-flip",
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
        nonClaims,
        "next packet may prove default-engine-flip apply gate without flipping the default engine",
        "QUIC can reuse lane-specific default-engine-flip readiness modes before runtime default flip"
    )
}

func igniteDefaultEngineFlipReadinessGateModeFor(
    liveServerWiringGateMode: String
): String {
    if (liveServerWiringGateMode == "short-live-server-wiring-gate") {
        return "short-default-engine-flip-readiness-gate"
    }
    if (liveServerWiringGateMode == "long-live-server-wiring-gate") {
        return "long-default-engine-flip-readiness-gate"
    }
    if (liveServerWiringGateMode == "blocking-isolation-live-server-wiring-gate") {
        return "blocking-isolation-default-engine-flip-readiness-gate"
    }
    "unknown-default-engine-flip-readiness-gate"
}

func igniteDefaultEngineFlipReadinessGateBlockers(
    request: IgniteDefaultEngineFlipReadinessGateRequest,
    readinessMode: String
): Array<String> {
    var blockers = ArrayList<String>()
    if (request.defaultEngineFlipReadinessGateId.size == 0) {
        blockers.add("DEFAULT_ENGINE_FLIP_READINESS_GATE_ID_NOT_CARRIED")
    }
    if (!request.liveServerWiringGateSnapshotCarried) {
        blockers.add("LIVE_SERVER_WIRING_GATE_SNAPSHOT_NOT_CARRIED")
    }
    if (!request.defaultEngineCandidatePlanCarried) {
        blockers.add("DEFAULT_ENGINE_CANDIDATE_PLAN_NOT_CARRIED")
    }
    if (!request.rollbackPlanCarried) {
        blockers.add("ROLLBACK_PLAN_NOT_CARRIED")
    }
    if (!request.releaseGuardPlanCarried) {
        blockers.add("RELEASE_GUARD_PLAN_NOT_CARRIED")
    }
    if (!request.runtimeParityProofPlanCarried) {
        blockers.add("RUNTIME_PARITY_PROOF_PLAN_NOT_CARRIED")
    }
    if (!request.stdxReplacementBoundaryCarried) {
        blockers.add("STDX_REPLACEMENT_BOUNDARY_NOT_CARRIED")
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
    if (request.publicReleaseRequested) {
        blockers.add("PUBLIC_RELEASE_REQUESTED")
    }
    if (request.stdxRemovalRequested) {
        blockers.add("STDX_REMOVAL_REQUESTED")
    }
    if (request.h1H2QuicRuntimeClosureClaimed) {
        blockers.add("H1_H2_QUIC_RUNTIME_CLOSURE_CLAIMED")
    }
    if (readinessMode == "unknown-default-engine-flip-readiness-gate") {
        blockers.add("UNKNOWN_LIVE_SERVER_WIRING_GATE")
    }
    blockers.toArray()
}

func igniteDefaultEngineFlipReadinessGateNonClaims(): Array<String> {
    [
        "NO_ACTUAL_DEFAULT_ENGINE_FLIP",
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
