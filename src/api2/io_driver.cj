package ignite.api2

import std.collection.ArrayList

/// Ignite-owned projection of the lisi.io capability decision shape.
///
/// This is a policy/probe surface only. It intentionally does not attach
/// native syscalls, claim zero-copy, or add a direct lisi dependency.
public struct IoDriverCapabilityRecord {
    public let driverId: String
    public let driverFamily: String
    public let platformScope: String
    public let cjScope: String
    public let supportsStreamRead: Bool
    public let supportsStreamWrite: Bool
    public let supportsPositionedRead: Bool
    public let supportsPositionedWrite: Bool
    public let supportsKernelCopy: Bool
    public let supportsAsyncCompletion: Bool
    public let supportsBackpressure: Bool
    public let experimental: Bool
    public let defaultEligible: Bool
    public let unsupportedReasons: Array<String>
    public let notes: Array<String>

    public init(
        driverId: String,
        driverFamily: String,
        platformScope: String,
        cjScope: String,
        supportsStreamRead: Bool,
        supportsStreamWrite: Bool,
        supportsPositionedRead: Bool,
        supportsPositionedWrite: Bool,
        supportsKernelCopy: Bool,
        supportsAsyncCompletion: Bool,
        supportsBackpressure: Bool,
        experimental: Bool,
        defaultEligible: Bool,
        unsupportedReasons: Array<String>,
        notes: Array<String>
    ) {
        this.driverId = driverId
        this.driverFamily = driverFamily
        this.platformScope = platformScope
        this.cjScope = cjScope
        this.supportsStreamRead = supportsStreamRead
        this.supportsStreamWrite = supportsStreamWrite
        this.supportsPositionedRead = supportsPositionedRead
        this.supportsPositionedWrite = supportsPositionedWrite
        this.supportsKernelCopy = supportsKernelCopy
        this.supportsAsyncCompletion = supportsAsyncCompletion
        this.supportsBackpressure = supportsBackpressure
        this.experimental = experimental
        this.defaultEligible = defaultEligible
        this.unsupportedReasons = unsupportedReasons
        this.notes = notes
    }
}

public struct IoDriverPolicyRequest {
    public let scene: String
    public let accessPattern: String
    public let transferShape: String
    public let requiresStreaming: Bool
    public let requiresPositionedRead: Bool
    public let requiresPositionedWrite: Bool
    public let requiresKernelCopy: Bool
    public let requiresAsyncCompletion: Bool
    public let preferredDriverHint: String
    public let allowExperimental: Bool
    public let maxConcurrencyHint: Int64
    public let runtimeHint: String

    public init(
        scene: String,
        accessPattern: String,
        transferShape: String,
        requiresStreaming: Bool,
        requiresPositionedRead: Bool,
        requiresPositionedWrite: Bool,
        requiresKernelCopy: Bool,
        requiresAsyncCompletion: Bool,
        preferredDriverHint: String,
        allowExperimental: Bool,
        maxConcurrencyHint: Int64,
        runtimeHint: String
    ) {
        this.scene = scene
        this.accessPattern = accessPattern
        this.transferShape = transferShape
        this.requiresStreaming = requiresStreaming
        this.requiresPositionedRead = requiresPositionedRead
        this.requiresPositionedWrite = requiresPositionedWrite
        this.requiresKernelCopy = requiresKernelCopy
        this.requiresAsyncCompletion = requiresAsyncCompletion
        this.preferredDriverHint = preferredDriverHint
        this.allowExperimental = allowExperimental
        this.maxConcurrencyHint = maxConcurrencyHint
        this.runtimeHint = runtimeHint
    }
}

public struct IoDriverDecision {
    public let candidateOrder: Array<String>
    public let selectedDriver: String
    public let selectedReason: String
    public let fallbackChain: Array<String>
    public let blockedCandidates: Array<String>
    public let riskLevel: String
    public let publicPath: String
    public let observabilityTags: Array<String>

    public init(
        candidateOrder: Array<String>,
        selectedDriver: String,
        selectedReason: String,
        fallbackChain: Array<String>,
        blockedCandidates: Array<String>,
        riskLevel: String,
        publicPath: String,
        observabilityTags: Array<String>
    ) {
        this.candidateOrder = candidateOrder
        this.selectedDriver = selectedDriver
        this.selectedReason = selectedReason
        this.fallbackChain = fallbackChain
        this.blockedCandidates = blockedCandidates
        this.riskLevel = riskLevel
        this.publicPath = publicPath
        this.observabilityTags = observabilityTags
    }
}

public struct IoDriverLabGate {
    public let labFeature: Bool
    public let gateName: String
    public let optInRequired: Bool
    public let optInProvided: Bool
    public let accepted: Bool
    public let reason: String

    public init(
        labFeature: Bool,
        gateName: String,
        optInRequired: Bool,
        optInProvided: Bool,
        accepted: Bool,
        reason: String
    ) {
        this.labFeature = labFeature
        this.gateName = gateName
        this.optInRequired = optInRequired
        this.optInProvided = optInProvided
        this.accepted = accepted
        this.reason = reason
    }
}

public struct IoDriverNativeBridgePlan {
    public let bridgeLanguage: String
    public let bridgeFamily: String
    public let entryPoints: Array<String>
    public let safetyNotes: Array<String>
    public let buildNotes: Array<String>
    public let recommendedFirstStep: String

    public init(
        bridgeLanguage: String,
        bridgeFamily: String,
        entryPoints: Array<String>,
        safetyNotes: Array<String>,
        buildNotes: Array<String>,
        recommendedFirstStep: String
    ) {
        this.bridgeLanguage = bridgeLanguage
        this.bridgeFamily = bridgeFamily
        this.entryPoints = entryPoints
        this.safetyNotes = safetyNotes
        this.buildNotes = buildNotes
        this.recommendedFirstStep = recommendedFirstStep
    }
}

public struct IoDriverProbeReport {
    public let decision: IoDriverDecision
    public let labGate: IoDriverLabGate
    public let selectedFamily: String
    public let canClaimZeroCopy: Bool
    public let benchmarkRequired: Bool
    public let runtimeLimitations: Array<String>
    public let nativeBridgePlan: IoDriverNativeBridgePlan

    public init(
        decision: IoDriverDecision,
        labGate: IoDriverLabGate,
        selectedFamily: String,
        canClaimZeroCopy: Bool,
        benchmarkRequired: Bool,
        runtimeLimitations: Array<String>,
        nativeBridgePlan: IoDriverNativeBridgePlan
    ) {
        this.decision = decision
        this.labGate = labGate
        this.selectedFamily = selectedFamily
        this.canClaimZeroCopy = canClaimZeroCopy
        this.benchmarkRequired = benchmarkRequired
        this.runtimeLimitations = runtimeLimitations
        this.nativeBridgePlan = nativeBridgePlan
    }
}

public struct IoDriverBackendReadinessEvidence {
    public let benchmarkReceiptRef: String
    public let fallbackProofRef: String
    public let platformProbeRef: String
    public let lifetimeAuditRef: String

    public init(
        benchmarkReceiptRef: String,
        fallbackProofRef: String,
        platformProbeRef: String,
        lifetimeAuditRef: String
    ) {
        this.benchmarkReceiptRef = benchmarkReceiptRef
        this.fallbackProofRef = fallbackProofRef
        this.platformProbeRef = platformProbeRef
        this.lifetimeAuditRef = lifetimeAuditRef
    }
}

public struct IoDriverBackendReadinessReceipt {
    public let selectedDriver: String
    public let publicPath: String
    public let ready: Bool
    public let status: String
    public let requiredProofs: Array<String>
    public let missingProofs: Array<String>
    public let blockers: Array<String>
    public let nextAction: String
    public let nonClaims: Array<String>

    public init(
        selectedDriver: String,
        publicPath: String,
        ready: Bool,
        status: String,
        requiredProofs: Array<String>,
        missingProofs: Array<String>,
        blockers: Array<String>,
        nextAction: String,
        nonClaims: Array<String>
    ) {
        this.selectedDriver = selectedDriver
        this.publicPath = publicPath
        this.ready = ready
        this.status = status
        this.requiredProofs = requiredProofs
        this.missingProofs = missingProofs
        this.blockers = blockers
        this.nextAction = nextAction
        this.nonClaims = nonClaims
    }
}

public struct IoDriverLinuxFileBackendReceiptProbe {
    public let selectedDriver: String
    public let publicPath: String
    public let entryPoints: Array<String>
    public let fallbackChain: Array<String>
    public let readyForImplementationPacket: Bool
    public let status: String
    public let requiredReceipts: Array<String>
    public let missingReceipts: Array<String>
    public let benchmarkReceiptStatus: String
    public let fallbackProofStatus: String
    public let platformProbeStatus: String
    public let lifetimeAuditStatus: String
    public let blockers: Array<String>
    public let nextAction: String
    public let nonClaims: Array<String>

    public init(
        selectedDriver: String,
        publicPath: String,
        entryPoints: Array<String>,
        fallbackChain: Array<String>,
        readyForImplementationPacket: Bool,
        status: String,
        requiredReceipts: Array<String>,
        missingReceipts: Array<String>,
        benchmarkReceiptStatus: String,
        fallbackProofStatus: String,
        platformProbeStatus: String,
        lifetimeAuditStatus: String,
        blockers: Array<String>,
        nextAction: String,
        nonClaims: Array<String>
    ) {
        this.selectedDriver = selectedDriver
        this.publicPath = publicPath
        this.entryPoints = entryPoints
        this.fallbackChain = fallbackChain
        this.readyForImplementationPacket = readyForImplementationPacket
        this.status = status
        this.requiredReceipts = requiredReceipts
        this.missingReceipts = missingReceipts
        this.benchmarkReceiptStatus = benchmarkReceiptStatus
        this.fallbackProofStatus = fallbackProofStatus
        this.platformProbeStatus = platformProbeStatus
        this.lifetimeAuditStatus = lifetimeAuditStatus
        this.blockers = blockers
        this.nextAction = nextAction
        this.nonClaims = nonClaims
    }
}

public func builtInIoDriverCapabilities(): Array<IoDriverCapabilityRecord> {
    [
        stdFsBlockingIoDriverCapability(),
        igniteStreamSeamIoDriverCapability(),
        igniteBufferedResponseSeamIoDriverCapability(),
        linuxNativeIoDriverCandidateCapability(),
        windowsNativeIoDriverCandidateCapability(),
        macosNativeIoDriverCandidateCapability(),
    ]
}

public func selectIoDriver(request: IoDriverPolicyRequest): IoDriverDecision {
    selectIoDriver(request, builtInIoDriverCapabilities())
}

public func selectIoDriver(
    request: IoDriverPolicyRequest,
    capabilities: Array<IoDriverCapabilityRecord>
): IoDriverDecision {
    let ordered = orderIoDriverCapabilities(capabilities, request)
    let candidateOrder = extractIoDriverIds(ordered)

    var blocked = ArrayList<String>()
    for (capability in ordered) {
        if (let Some(reason) <- unsupportedIoDriverReason(capability, request)) {
            blocked.add("${capability.driverId}:${reason}")
            continue
        }

        let publicPath = ioDriverPublicPathFor(capability)
        return IoDriverDecision(
            candidateOrder,
            capability.driverId,
            resolveIoDriverSelectedReason(capability, request, blocked.toArray()),
            ioDriverFallbackChainFor(capability, ordered),
            blocked.toArray(),
            ioDriverRiskLevelFor(capability),
            publicPath,
            buildIoDriverObservabilityTags(request, capability.driverId, publicPath)
        )
    }

    IoDriverDecision(
        candidateOrder,
        "",
        "unsupported_request",
        [],
        blocked.toArray(),
        "high",
        "unsupported",
        buildUnsupportedIoDriverTags(request)
    )
}

public func ioDriverLabGateFor(
    request: IoDriverPolicyRequest,
    driverId: String
): IoDriverLabGate {
    if (!isLabIoDriver(driverId)) {
        return IoDriverLabGate(false, "stable-io", false, true, true, "STABLE_PATH")
    }

    IoDriverLabGate(
        true,
        "io-native-lab",
        true,
        request.allowExperimental,
        request.allowExperimental,
        if (request.allowExperimental) { "LAB_OPT_IN_ACCEPTED" } else { "LAB_OPT_IN_REQUIRED" }
    )
}

public func buildIoDriverProbeReport(request: IoDriverPolicyRequest): IoDriverProbeReport {
    let decision = selectIoDriver(request)
    let benchmarkRequired = request.requiresKernelCopy ||
        request.requiresAsyncCompletion ||
        decision.publicPath == "experimental-only"

    IoDriverProbeReport(
        decision,
        ioDriverLabGateFor(request, decision.selectedDriver),
        ioDriverFamilyForSelected(decision.selectedDriver),
        false,
        benchmarkRequired,
        buildIoDriverRuntimeLimitations(request, decision),
        buildIoDriverNativeBridgePlan(decision.selectedDriver)
    )
}

public func buildIoDriverBackendReadinessReceipt(
    request: IoDriverPolicyRequest,
    evidence: IoDriverBackendReadinessEvidence
): IoDriverBackendReadinessReceipt {
    let report = buildIoDriverProbeReport(request)
    if (report.decision.selectedDriver.size == 0) {
        return IoDriverBackendReadinessReceipt(
            report.decision.selectedDriver,
            report.decision.publicPath,
            false,
            "blocked-unsupported-request",
            [],
            [],
            buildIoDriverUnsupportedBackendBlockers(report),
            "narrow request or add stable fallback before backend work",
            ["NO_BACKEND_IMPLEMENTATION_CLAIM", "NO_ZERO_COPY_CLAIM", "NO_PERFORMANCE_CLAIM"]
        )
    }

    if (!report.labGate.labFeature) {
        return IoDriverBackendReadinessReceipt(
            report.decision.selectedDriver,
            report.decision.publicPath,
            true,
            "ready-stable-path",
            [],
            [],
            [],
            "continue with stable Ignite/std path; native backend proof not required",
            ["NO_KERNEL_ZERO_COPY_CLAIM", "NO_NATIVE_BACKEND_CLAIM"]
        )
    }

    let requiredProofs = ioDriverNativeBackendRequiredProofs()
    let missingProofs = buildIoDriverBackendMissingProofs(evidence)
    let accepted = report.labGate.accepted && missingProofs.size == 0

    IoDriverBackendReadinessReceipt(
        report.decision.selectedDriver,
        report.decision.publicPath,
        accepted,
        if (accepted) { "ready-lab-backend-implementation-packet" } else { "blocked-lab-proof-missing" },
        requiredProofs,
        missingProofs,
        buildIoDriverNativeBackendBlockers(report, missingProofs),
        if (accepted) { "open one backend implementation packet with attached receipts" } else { "collect benchmark, fallback, platform, and lifetime receipts before backend work" },
        ["NO_NATIVE_BACKEND_IMPLEMENTED", "NO_ZERO_COPY_CLAIM", "NO_PERFORMANCE_CLAIM"]
    )
}

public func buildIoDriverLinuxFileBackendReceiptProbe(
    request: IoDriverPolicyRequest,
    evidence: IoDriverBackendReadinessEvidence
): IoDriverLinuxFileBackendReceiptProbe {
    let report = buildIoDriverProbeReport(request)
    let readiness = buildIoDriverBackendReadinessReceipt(request, evidence)
    let linuxCandidateSelected = report.decision.selectedDriver == "linux-native-candidate"
    let ready = linuxCandidateSelected && readiness.ready

    IoDriverLinuxFileBackendReceiptProbe(
        report.decision.selectedDriver,
        report.decision.publicPath,
        if (linuxCandidateSelected) { report.nativeBridgePlan.entryPoints } else { [] },
        report.decision.fallbackChain,
        ready,
        buildIoDriverLinuxFileBackendProbeStatus(linuxCandidateSelected, ready, readiness),
        ioDriverNativeBackendRequiredProofs(),
        readiness.missingProofs,
        buildIoDriverReceiptStatus(evidence.benchmarkReceiptRef, "BENCHMARK_RECEIPT"),
        buildIoDriverReceiptStatus(evidence.fallbackProofRef, "FALLBACK_PROOF"),
        buildIoDriverLinuxPlatformProbeStatus(request, evidence.platformProbeRef),
        buildIoDriverReceiptStatus(evidence.lifetimeAuditRef, "LIFETIME_AUDIT"),
        buildIoDriverLinuxFileBackendProbeBlockers(readiness, linuxCandidateSelected),
        buildIoDriverLinuxFileBackendProbeNextAction(linuxCandidateSelected, ready),
        ["NO_NATIVE_BACKEND_IMPLEMENTED", "NO_ZERO_COPY_CLAIM", "NO_PERFORMANCE_CLAIM"]
    )
}

func stdFsBlockingIoDriverCapability(): IoDriverCapabilityRecord {
    IoDriverCapabilityRecord(
        "std-fs-blocking",
        "std.fs",
        "cross-platform",
        "cj>=1.1.0",
        true,
        true,
        true,
        false,
        false,
        false,
        false,
        false,
        true,
        [],
        ["CURRENT_STABLE_FILE_IO_BASELINE", "BLOCKING_IO", "NO_ZERO_COPY_CLAIM"]
    )
}

func igniteStreamSeamIoDriverCapability(): IoDriverCapabilityRecord {
    IoDriverCapabilityRecord(
        "ignite-stream-seam",
        "ignite",
        "cross-platform",
        "cj>=1.1.0",
        true,
        true,
        true,
        false,
        false,
        false,
        true,
        false,
        true,
        [],
        ["HTTP_RANGE_STREAMING_SEAM", "SEND_STREAM_COMPATIBLE", "NO_KERNEL_ZERO_COPY_CLAIM"]
    )
}

func igniteBufferedResponseSeamIoDriverCapability(): IoDriverCapabilityRecord {
    IoDriverCapabilityRecord(
        "ignite-buffered-response-seam",
        "ignite",
        "cross-platform",
        "cj>=1.1.0",
        false,
        true,
        false,
        false,
        false,
        false,
        false,
        false,
        true,
        [],
        ["HTTP_BUFFERED_RESPONSE_SEAM", "SEND_STRING_COMPATIBLE", "NO_KERNEL_ZERO_COPY_CLAIM"]
    )
}

func linuxNativeIoDriverCandidateCapability(): IoDriverCapabilityRecord {
    IoDriverCapabilityRecord(
        "linux-native-candidate",
        "native-ffi",
        "linux",
        "experimental",
        true,
        true,
        true,
        true,
        true,
        true,
        true,
        true,
        false,
        ["NATIVE_BRIDGE_NOT_ATTACHED"],
        ["SENDFILE_OR_COPY_FILE_RANGE_FIRST", "IO_URING_LATER", "OPTIONAL_BACKEND_ONLY"]
    )
}

func windowsNativeIoDriverCandidateCapability(): IoDriverCapabilityRecord {
    IoDriverCapabilityRecord(
        "windows-native-candidate",
        "native-ffi",
        "windows",
        "experimental",
        true,
        true,
        true,
        true,
        false,
        true,
        true,
        true,
        false,
        ["NATIVE_BRIDGE_NOT_ATTACHED"],
        ["OVERLAPPED_IO_OR_IOCP_LATER", "OPTIONAL_BACKEND_ONLY"]
    )
}

func macosNativeIoDriverCandidateCapability(): IoDriverCapabilityRecord {
    IoDriverCapabilityRecord(
        "macos-native-candidate",
        "native-ffi",
        "macos",
        "experimental",
        true,
        true,
        true,
        true,
        true,
        false,
        true,
        true,
        false,
        ["NATIVE_BRIDGE_NOT_ATTACHED"],
        ["SENDFILE_STYLE_PROOF_LATER", "OPTIONAL_BACKEND_ONLY"]
    )
}

func orderIoDriverCapabilities(
    capabilities: Array<IoDriverCapabilityRecord>,
    request: IoDriverPolicyRequest
): Array<IoDriverCapabilityRecord> {
    var ordered = ArrayList<IoDriverCapabilityRecord>()
    let hint = request.preferredDriverHint.trimAscii()

    if (hint.size > 0) {
        for (capability in capabilities) {
            if (capability.driverId == hint) {
                appendIoDriverCapabilityIfMissing(ordered, capability)
            }
        }
    }

    if (shouldPreferIgniteIoStream(request)) {
        for (capability in capabilities) {
            if (capability.driverId == "ignite-stream-seam") {
                appendIoDriverCapabilityIfMissing(ordered, capability)
            }
        }
    }

    if (shouldPreferIgniteBufferedResponse(request)) {
        for (capability in capabilities) {
            if (capability.driverId == "ignite-buffered-response-seam") {
                appendIoDriverCapabilityIfMissing(ordered, capability)
            }
        }
    }

    for (capability in capabilities) {
        if (capability.defaultEligible && !capability.experimental && capability.driverId == "std-fs-blocking") {
            appendIoDriverCapabilityIfMissing(ordered, capability)
        }
    }

    for (capability in capabilities) {
        if (capability.defaultEligible && !capability.experimental && capability.driverId != "std-fs-blocking") {
            appendIoDriverCapabilityIfMissing(ordered, capability)
        }
    }

    for (capability in capabilities) {
        if (!(capability.defaultEligible && !capability.experimental)) {
            appendIoDriverCapabilityIfMissing(ordered, capability)
        }
    }

    ordered.toArray()
}

func appendIoDriverCapabilityIfMissing(
    list: ArrayList<IoDriverCapabilityRecord>,
    capability: IoDriverCapabilityRecord
): Unit {
    for (existing in list) {
        if (existing.driverId == capability.driverId) {
            return
        }
    }
    list.add(capability)
}

func shouldPreferIgniteIoStream(request: IoDriverPolicyRequest): Bool {
    if (!request.requiresStreaming) {
        return false
    }
    let shape = normalizeIoDriverText(request.transferShape)
    shape == "http-response" || shape == "http-download" || shape == "range-download" ||
        shape == "proxy-downstream" || shape == "proxy-request-upload"
}

func shouldPreferIgniteBufferedResponse(request: IoDriverPolicyRequest): Bool {
    let shape = normalizeIoDriverText(request.transferShape)
    shape == "proxy-local-error-response"
}

func extractIoDriverIds(capabilities: Array<IoDriverCapabilityRecord>): Array<String> {
    var ids = ArrayList<String>()
    for (capability in capabilities) {
        ids.add(capability.driverId)
    }
    ids.toArray()
}

func unsupportedIoDriverReason(
    capability: IoDriverCapabilityRecord,
    request: IoDriverPolicyRequest
): ?String {
    if (!request.allowExperimental && capability.experimental) {
        return Some("EXPERIMENTAL_DISABLED")
    }

    if (!ioDriverPlatformScopeMatches(capability.platformScope, request.runtimeHint)) {
        return Some("PLATFORM_SCOPE_UNCONFIRMED")
    }

    if (request.requiresStreaming && !(capability.supportsStreamRead && capability.supportsStreamWrite)) {
        return Some("STREAMING_UNSUPPORTED")
    }

    if (request.requiresPositionedRead && !capability.supportsPositionedRead) {
        return Some("POSITIONED_READ_UNSUPPORTED")
    }

    if (request.requiresPositionedWrite && !capability.supportsPositionedWrite) {
        return Some("POSITIONED_WRITE_UNSUPPORTED")
    }

    if (request.requiresKernelCopy && !capability.supportsKernelCopy) {
        return Some("KERNEL_COPY_UNSUPPORTED")
    }

    if (request.requiresAsyncCompletion && !capability.supportsAsyncCompletion) {
        return Some("ASYNC_COMPLETION_UNSUPPORTED")
    }

    None
}

func ioDriverPlatformScopeMatches(platformScope: String, runtimeHint: String): Bool {
    let scope = normalizeIoDriverText(platformScope)
    if (scope == "cross-platform" || scope.size == 0) {
        return true
    }

    let hint = normalizeIoDriverText(runtimeHint)
    hint.contains("platform=${scope}") || hint.contains(scope)
}

func resolveIoDriverSelectedReason(
    capability: IoDriverCapabilityRecord,
    request: IoDriverPolicyRequest,
    blockedCandidates: Array<String>
): String {
    if (request.preferredDriverHint.trimAscii() == capability.driverId) {
        return "preferred_driver_hint"
    }

    if (capability.driverId == "ignite-stream-seam" && shouldPreferIgniteIoStream(request)) {
        return "http_streaming_shape"
    }

    if (capability.driverId == "ignite-buffered-response-seam" && shouldPreferIgniteBufferedResponse(request)) {
        return "http_buffered_response_shape"
    }

    if (capability.defaultEligible && blockedCandidates.size > 0) {
        return "fallback_to_stable_default"
    }

    if (capability.defaultEligible) {
        return "stable_default_path"
    }

    if (capability.experimental) {
        return "experimental_allowed"
    }

    "first_supported_candidate"
}

func ioDriverFallbackChainFor(
    selected: IoDriverCapabilityRecord,
    ordered: Array<IoDriverCapabilityRecord>
): Array<String> {
    var chain = ArrayList<String>()
    if (selected.experimental) {
        for (capability in ordered) {
            if (capability.defaultEligible && !capability.experimental) {
                chain.add(capability.driverId)
            }
        }
    }
    chain.toArray()
}

func ioDriverPublicPathFor(capability: IoDriverCapabilityRecord): String {
    if (capability.driverId == "ignite-stream-seam") {
        return "stable-stream-seam"
    }
    if (capability.driverId == "ignite-buffered-response-seam") {
        return "stable-buffered-response-seam"
    }
    if (capability.defaultEligible && !capability.experimental) {
        return "stable-default"
    }
    if (capability.experimental) {
        return "experimental-only"
    }
    "unsupported"
}

func ioDriverRiskLevelFor(capability: IoDriverCapabilityRecord): String {
    if (capability.experimental) {
        return "medium"
    }
    "low"
}

func ioDriverFamilyForSelected(selectedDriver: String): String {
    if (selectedDriver == "std-fs-blocking") {
        return "std.fs"
    }
    if (selectedDriver == "ignite-stream-seam") {
        return "ignite"
    }
    if (selectedDriver == "ignite-buffered-response-seam") {
        return "ignite"
    }
    if (isLabIoDriver(selectedDriver)) {
        return "native-ffi"
    }
    "unsupported"
}

func isLabIoDriver(driverId: String): Bool {
    driverId == "linux-native-candidate" ||
        driverId == "windows-native-candidate" ||
        driverId == "macos-native-candidate"
}

func buildIoDriverRuntimeLimitations(
    request: IoDriverPolicyRequest,
    decision: IoDriverDecision
): Array<String> {
    var out = ArrayList<String>()

    if (decision.selectedDriver == "std-fs-blocking") {
        out.add("BLOCKING_STD_FS_BASELINE")
        out.add("NO_KERNEL_ZERO_COPY_CLAIM")
    }

    if (decision.selectedDriver == "ignite-stream-seam") {
        out.add("IGNITE_STREAM_SEAM_ONLY")
        out.add("NO_KERNEL_ZERO_COPY_CLAIM")
    }

    if (decision.selectedDriver == "ignite-buffered-response-seam") {
        out.add("IGNITE_BUFFERED_RESPONSE_SEAM_ONLY")
        out.add("NO_KERNEL_ZERO_COPY_CLAIM")
    }

    if (decision.publicPath == "experimental-only") {
        out.add("LAB_NATIVE_BACKEND")
        out.add("BENCHMARK_RECEIPT_REQUIRED")
        out.add("FALLBACK_PROOF_REQUIRED")
    }

    if (request.requiresAsyncCompletion && decision.selectedDriver.size == 0) {
        out.add("ASYNC_COMPLETION_NOT_AVAILABLE")
    }

    for (blocked in decision.blockedCandidates) {
        out.add("BLOCKED:${blocked}")
    }

    out.toArray()
}

func ioDriverNativeBackendRequiredProofs(): Array<String> {
    ["BENCHMARK_RECEIPT", "FALLBACK_PROOF", "PLATFORM_PROBE", "LIFETIME_AUDIT"]
}

func buildIoDriverBackendMissingProofs(evidence: IoDriverBackendReadinessEvidence): Array<String> {
    var missing = ArrayList<String>()
    if (!hasIoDriverReceiptRef(evidence.benchmarkReceiptRef)) {
        missing.add("BENCHMARK_RECEIPT")
    }
    if (!hasIoDriverReceiptRef(evidence.fallbackProofRef)) {
        missing.add("FALLBACK_PROOF")
    }
    if (!hasIoDriverReceiptRef(evidence.platformProbeRef)) {
        missing.add("PLATFORM_PROBE")
    }
    if (!hasIoDriverReceiptRef(evidence.lifetimeAuditRef)) {
        missing.add("LIFETIME_AUDIT")
    }
    missing.toArray()
}

func buildIoDriverNativeBackendBlockers(
    report: IoDriverProbeReport,
    missingProofs: Array<String>
): Array<String> {
    var blockers = ArrayList<String>()
    if (!report.labGate.accepted) {
        blockers.add("LAB_OPT_IN_REQUIRED")
    }
    for (missing in missingProofs) {
        blockers.add("MISSING:${missing}")
    }
    blockers.toArray()
}

func buildIoDriverUnsupportedBackendBlockers(report: IoDriverProbeReport): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("UNSUPPORTED_REQUEST")
    for (blocked in report.decision.blockedCandidates) {
        blockers.add("BLOCKED:${blocked}")
    }
    blockers.toArray()
}

func hasIoDriverReceiptRef(value: String): Bool {
    value.trimAscii().size > 0
}

func buildIoDriverLinuxFileBackendProbeStatus(
    linuxCandidateSelected: Bool,
    ready: Bool,
    readiness: IoDriverBackendReadinessReceipt
): String {
    if (ready) {
        return "ready-linux-file-backend-implementation-packet"
    }
    if (!linuxCandidateSelected) {
        return "blocked-linux-candidate-not-selected"
    }
    if (readiness.missingProofs.size > 0) {
        return "blocked-linux-receipt-missing"
    }
    "blocked-linux-receipt-inconclusive"
}

func buildIoDriverReceiptStatus(ref: String, receiptName: String): String {
    if (hasIoDriverReceiptRef(ref)) {
        return "${receiptName}_PROVIDED"
    }
    "${receiptName}_MISSING"
}

func buildIoDriverLinuxPlatformProbeStatus(
    request: IoDriverPolicyRequest,
    platformProbeRef: String
): String {
    if (hasIoDriverReceiptRef(platformProbeRef)) {
        return "PLATFORM_PROBE_PROVIDED"
    }
    if (ioDriverPlatformScopeMatches("linux", request.runtimeHint)) {
        return "PLATFORM_HINT_LINUX_BUT_PROBE_MISSING"
    }
    "PLATFORM_SCOPE_UNCONFIRMED"
}

func buildIoDriverLinuxFileBackendProbeBlockers(
    readiness: IoDriverBackendReadinessReceipt,
    linuxCandidateSelected: Bool
): Array<String> {
    var blockers = ArrayList<String>()
    if (!linuxCandidateSelected) {
        blockers.add("LINUX_NATIVE_CANDIDATE_NOT_SELECTED")
    }
    for (blocker in readiness.blockers) {
        blockers.add(blocker)
    }
    blockers.toArray()
}

func buildIoDriverLinuxFileBackendProbeNextAction(
    linuxCandidateSelected: Bool,
    ready: Bool
): String {
    if (ready) {
        return "open one Linux file backend implementation packet with attached receipts"
    }
    if (!linuxCandidateSelected) {
        return "keep stable fallback and collect Linux platform proof before backend work"
    }
    "collect Linux benchmark, fallback, platform, and lifetime receipts before backend work"
}

func buildIoDriverNativeBridgePlan(selectedDriver: String): IoDriverNativeBridgePlan {
    if (selectedDriver == "linux-native-candidate") {
        return IoDriverNativeBridgePlan(
            "c",
            "posix-ffi",
            ["sendfile", "copy_file_range", "pread", "pwrite", "io_uring_probe_later"],
            ["keep fd ownership outside business code", "preserve std.fs fallback", "measure copy count before zero-copy claim"],
            ["compile native bridge as optional artifact", "gate by platform=linux runtime hint"],
            "start with sendfile/copy_file_range proof before io_uring"
        )
    }

    if (selectedDriver == "windows-native-candidate") {
        return IoDriverNativeBridgePlan(
            "c-or-rust",
            "windows-overlapped-ffi",
            ["CreateFileW", "ReadFileEx", "WriteFileEx", "GetQueuedCompletionStatus"],
            ["keep HANDLE ownership explicit", "do not block stable std.fs fallback", "surface completion errors as structured fallback reasons"],
            ["compile bridge only for windows targets", "link Windows system libraries explicitly"],
            "start with overlapped file IO before full IOCP scheduler"
        )
    }

    if (selectedDriver == "macos-native-candidate") {
        return IoDriverNativeBridgePlan(
            "c",
            "darwin-ffi",
            ["sendfile", "pread", "pwrite", "fcopyfile_probe_later"],
            ["preserve std.fs fallback", "avoid claiming kernel-copy until measured", "keep path validation in caller"],
            ["compile bridge only for darwin targets"],
            "start with sendfile-style proof for file-to-socket downloads"
        )
    }

    IoDriverNativeBridgePlan(
        "none",
        "not-required",
        [],
        ["stable path does not require native bridge"],
        [],
        "use std.fs or Ignite stream seam first"
    )
}

func buildIoDriverObservabilityTags(
    request: IoDriverPolicyRequest,
    driverId: String,
    publicPath: String
): Array<String> {
    [
        "scene:${normalizeIoDriverText(request.scene)}",
        "access:${normalizeIoDriverText(request.accessPattern)}",
        "shape:${normalizeIoDriverText(request.transferShape)}",
        "selected_driver:${driverId}",
        "public_path:${publicPath}",
        "concurrency:${request.maxConcurrencyHint}",
    ]
}

func buildUnsupportedIoDriverTags(request: IoDriverPolicyRequest): Array<String> {
    [
        "scene:${normalizeIoDriverText(request.scene)}",
        "access:${normalizeIoDriverText(request.accessPattern)}",
        "shape:${normalizeIoDriverText(request.transferShape)}",
        "selected_driver:",
        "public_path:unsupported",
        "concurrency:${request.maxConcurrencyHint}",
    ]
}

func normalizeIoDriverText(text: String): String {
    text.trimAscii().toAsciiLower()
}
