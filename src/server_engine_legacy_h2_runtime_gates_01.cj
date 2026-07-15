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

func ensureServerJinguiAcceptedTransportSessionCodecReady(
    session: ContractHttpServerAcceptedTransportSession
): Unit {
    if (!session.secureSessionReady) {
        throw Exception(
            "accepted transport/session application-data codec requires secureSessionReady=true, got status=${session.status.toString()}"
        )
    }
}

public class ServerJinguiAcceptedTransportTlsAttachBlockerClassification {
    public let status: String
    public let owner: String
    public let failureCode: String
    public let attachSurface: String
    public let h2RuntimeBlocked: Bool
    public let message: String
    public let nextAction: String
    public let nonClaims: Array<String>

    public init(
        status: String,
        owner: String,
        failureCode: String,
        attachSurface: String,
        h2RuntimeBlocked: Bool,
        message: String,
        nextAction: String,
        nonClaims: Array<String>
    ) {
        this.status = status
        this.owner = owner
        this.failureCode = failureCode
        this.attachSurface = attachSurface
        this.h2RuntimeBlocked = h2RuntimeBlocked
        this.message = message
        this.nextAction = nextAction
        this.nonClaims = nonClaims.clone()
    }
}

public class ServerJinguiAcceptedTransportTlsAttachProofGateEvidence {
    public let classification: ServerJinguiAcceptedTransportTlsAttachBlockerClassification
    public let providerContractProofAccepted: Bool
    public let acceptedTransportAttachPass: Bool
    public let alternateProviderSelected: Bool
    public let expectedProviderBlockerCarried: Bool

    public init(
        classification: ServerJinguiAcceptedTransportTlsAttachBlockerClassification,
        providerContractProofAccepted: Bool,
        acceptedTransportAttachPass: Bool,
        alternateProviderSelected: Bool,
        expectedProviderBlockerCarried: Bool
    ) {
        this.classification = classification
        this.providerContractProofAccepted = providerContractProofAccepted
        this.acceptedTransportAttachPass = acceptedTransportAttachPass
        this.alternateProviderSelected = alternateProviderSelected
        this.expectedProviderBlockerCarried = expectedProviderBlockerCarried
    }
}

public class ServerJinguiAcceptedTransportTlsAttachProofGate {
    public let diagnosticPacketAllowed: Bool
    public let h2RuntimeProofAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
    public let status: String
    public let decision: String
    public let owner: String
    public let blockers: Array<String>
    public let missingProofs: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        diagnosticPacketAllowed: Bool,
        h2RuntimeProofAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
        status: String,
        decision: String,
        owner: String,
        blockers: Array<String>,
        missingProofs: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.diagnosticPacketAllowed = diagnosticPacketAllowed
        this.h2RuntimeProofAllowed = h2RuntimeProofAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.status = status
        this.decision = decision
        this.owner = owner
        this.blockers = blockers.clone()
        this.missingProofs = missingProofs.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func classifyServerJinguiAcceptedTransportTlsAttachBlocker(
    message: String
): ServerJinguiAcceptedTransportTlsAttachBlockerClassification {
    let normalized = message.trimAscii()
    if (
        serverEngineTextContains(
            normalized,
            "TLS1.3 transcript hash must be SHA-256 sized"
        )
    ) {
        return ServerJinguiAcceptedTransportTlsAttachBlockerClassification(
            "blocked-provider-contract",
            "JinguiSSL-contract",
            "TLS13_TRANSCRIPT_HASH_SIZE",
            "accepted-transport-tls13-x25519",
            true,
            normalized,
            "route provider-side transcript-hash contract proof before claiming Ignite H2/TLS runtime closure",
            [
                "NO_PROVIDER_FIX",
                "NO_ACCEPTED_TRANSPORT_ATTACH_PASS",
                "NO_H2_RUNTIME_CLOSURE",
                "NO_RELEASE_CLAIM",
            ]
        )
    }
    if (
        serverEngineTextContains(
            normalized,
            "accepted transport TLS1.3 X25519 attach failed"
        )
    ) {
        return ServerJinguiAcceptedTransportTlsAttachBlockerClassification(
            "blocked-provider-attach",
            "JinguiSSL-contract",
            "TLS13_ACCEPTED_TRANSPORT_ATTACH_FAILED",
            "accepted-transport-tls13-x25519",
            true,
            normalized,
            "route provider-side accepted-transport attach proof before widening Ignite H2/TLS claims",
            [
                "NO_PROVIDER_FIX",
                "NO_ACCEPTED_TRANSPORT_ATTACH_PASS",
                "NO_H2_RUNTIME_CLOSURE",
                "NO_RELEASE_CLAIM",
            ]
        )
    }
    ServerJinguiAcceptedTransportTlsAttachBlockerClassification(
        "unclassified",
        "unknown",
        "UNKNOWN",
        "accepted-transport-tls13-x25519",
        false,
        normalized,
        "capture a narrower failure anchor before assigning owner",
        [
            "NO_PROVIDER_FIX",
            "NO_OWNER_ASSIGNMENT",
            "NO_H2_RUNTIME_CLOSURE",
            "NO_RELEASE_CLAIM",
        ]
    )
}

public func buildServerJinguiAcceptedTransportTlsAttachProofGate(
    evidence: ServerJinguiAcceptedTransportTlsAttachProofGateEvidence
): ServerJinguiAcceptedTransportTlsAttachProofGate {
    let missingProofs =
        serverJinguiAcceptedTransportTlsAttachProofGateMissingProofs(evidence)
    let nonClaims = serverJinguiAcceptedTransportTlsAttachProofGateNonClaims()
    if (
        evidence.classification.h2RuntimeBlocked &&
        evidence.expectedProviderBlockerCarried
    ) {
        return ServerJinguiAcceptedTransportTlsAttachProofGate(
            true,
            false,
            false,
            "expected-provider-blocker-carried",
            "run-diagnostic-only-with-provider-blocker-stop-condition",
            evidence.classification.owner,
            [
                "EXPECTED_PROVIDER_BLOCKER:${evidence.classification.failureCode}",
            ],
            missingProofs,
            nonClaims,
            "only run packets that explicitly carry the provider blocker; do not claim H2 runtime proof or closure",
            "QUIC can run diagnostic packets with carried provider blockers, but cannot claim runtime closure from them"
        )
    }
    if (evidence.classification.h2RuntimeBlocked) {
        return ServerJinguiAcceptedTransportTlsAttachProofGate(
            false,
            false,
            false,
            evidence.classification.status,
            "stop-before-h2-runtime-proof",
            evidence.classification.owner,
            serverJinguiAcceptedTransportTlsAttachProofGateBlockers(
                evidence,
                missingProofs
            ),
            missingProofs,
            nonClaims,
            evidence.classification.nextAction,
            "QUIC must classify provider attach blockers before assigning stream, flow-control, or scheduler ownership"
        )
    }
    if (
        evidence.acceptedTransportAttachPass &&
        serverJinguiAcceptedTransportTlsAttachProofReady(evidence)
    ) {
        return ServerJinguiAcceptedTransportTlsAttachProofGate(
            true,
            true,
            false,
            "ready-for-h2-runtime-proof",
            "run-h2-runtime-proof-without-closure-claim",
            "Ignite-H2-runtime-packet",
            [],
            [],
            nonClaims,
            "open a bounded H2 runtime proof packet; closure still requires that packet proof",
            "QUIC can reuse this gate before moving from handshake/provider proof to runtime proof"
        )
    }
    ServerJinguiAcceptedTransportTlsAttachProofGate(
        false,
        false,
        false,
        serverJinguiAcceptedTransportTlsAttachProofGateBlockedStatus(evidence),
        "stop-before-h2-runtime-proof",
        evidence.classification.owner,
        serverJinguiAcceptedTransportTlsAttachProofGateBlockers(
            evidence,
            missingProofs
        ),
        missingProofs,
        nonClaims,
        "collect accepted-transport attach pass plus provider contract or alternate-provider proof before H2 runtime proof",
        "QUIC should not turn missing provider attach proof into runtime ownership"
    )
}

func serverJinguiAcceptedTransportTlsAttachProofReady(
    evidence: ServerJinguiAcceptedTransportTlsAttachProofGateEvidence
): Bool {
    evidence.acceptedTransportAttachPass &&
        (
            evidence.providerContractProofAccepted ||
            evidence.alternateProviderSelected
        ) &&
        !evidence.classification.h2RuntimeBlocked
}

func serverJinguiAcceptedTransportTlsAttachProofGateMissingProofs(
    evidence: ServerJinguiAcceptedTransportTlsAttachProofGateEvidence
): Array<String> {
    var missing = ArrayList<String>()
    if (!evidence.acceptedTransportAttachPass) {
        missing.add("ACCEPTED_TRANSPORT_ATTACH_PASS")
    }
    if (
        !evidence.providerContractProofAccepted &&
        !evidence.alternateProviderSelected
    ) {
        missing.add("PROVIDER_CONTRACT_OR_ALTERNATE_ATTACH_PROOF")
    }
    if (
        evidence.classification.status == "unclassified" &&
        !evidence.acceptedTransportAttachPass
    ) {
        missing.add("NARROW_FAILURE_ANCHOR")
    }
    missing.toArray()
}

func serverJinguiAcceptedTransportTlsAttachProofGateBlockers(
    evidence: ServerJinguiAcceptedTransportTlsAttachProofGateEvidence,
    missingProofs: Array<String>
): Array<String> {
    var blockers = ArrayList<String>()
    if (evidence.classification.h2RuntimeBlocked) {
        blockers.add(evidence.classification.failureCode)
    }
    for (missing in missingProofs) {
        blockers.add("MISSING:${missing}")
    }
    blockers.toArray()
}

func serverJinguiAcceptedTransportTlsAttachProofGateBlockedStatus(
    evidence: ServerJinguiAcceptedTransportTlsAttachProofGateEvidence
): String {
    if (evidence.classification.status == "unclassified") {
        return "blocked-provider-proof-missing"
    }
    evidence.classification.status
}

func serverJinguiAcceptedTransportTlsAttachProofGateNonClaims(): Array<String> {
    [
        "NO_PROVIDER_FIX",
        "NO_ACCEPTED_TRANSPORT_ATTACH_PASS_CLAIM",
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_RELEASE_CLAIM",
    ]
}

public class ServerJinguiTlsProviderReadinessEvidence {
    public let attachGate: ServerJinguiAcceptedTransportTlsAttachProofGate
    public let stableContractImportSurfaceProof: Bool
    public let certKeyContractApiProof: Bool
    public let alpnAdvertiseAndReportProof: Bool
    public let errorTaxonomyProof: Bool
    public let sessionCloseShutdownProof: Bool
    public let providerVersionReceiptProof: Bool

    public init(
        attachGate: ServerJinguiAcceptedTransportTlsAttachProofGate,
        stableContractImportSurfaceProof: Bool,
        certKeyContractApiProof: Bool,
        alpnAdvertiseAndReportProof: Bool,
        errorTaxonomyProof: Bool,
        sessionCloseShutdownProof: Bool,
        providerVersionReceiptProof: Bool
    ) {
        this.attachGate = attachGate
        this.stableContractImportSurfaceProof =
            stableContractImportSurfaceProof
        this.certKeyContractApiProof = certKeyContractApiProof
        this.alpnAdvertiseAndReportProof = alpnAdvertiseAndReportProof
        this.errorTaxonomyProof = errorTaxonomyProof
        this.sessionCloseShutdownProof = sessionCloseShutdownProof
        this.providerVersionReceiptProof = providerVersionReceiptProof
    }
}

public class ServerJinguiTlsProviderReadinessGate {
    public let providerReadinessAccepted: Bool
    public let h1TlsProviderSeamSatisfied: Bool
    public let h2ProviderPreconditionSatisfied: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
    public let status: String
    public let decision: String
    public let owner: String
    public let blockers: Array<String>
    public let missingProofs: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        providerReadinessAccepted: Bool,
        h1TlsProviderSeamSatisfied: Bool,
        h2ProviderPreconditionSatisfied: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
        status: String,
        decision: String,
        owner: String,
        blockers: Array<String>,
        missingProofs: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.providerReadinessAccepted = providerReadinessAccepted
        this.h1TlsProviderSeamSatisfied = h1TlsProviderSeamSatisfied
        this.h2ProviderPreconditionSatisfied = h2ProviderPreconditionSatisfied
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.status = status
        this.decision = decision
        this.owner = owner
        this.blockers = blockers.clone()
        this.missingProofs = missingProofs.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildServerJinguiTlsProviderReadinessGate(
    evidence: ServerJinguiTlsProviderReadinessEvidence
): ServerJinguiTlsProviderReadinessGate {
    let missingProofs =
        serverJinguiTlsProviderReadinessMissingProofs(evidence)
    let nonClaims = serverJinguiTlsProviderReadinessNonClaims()
    if (evidence.attachGate.status == "expected-provider-blocker-carried") {
        return ServerJinguiTlsProviderReadinessGate(
            false,
            false,
            false,
            false,
            "diagnostic-only-provider-blocker-carried",
            "keep-provider-readiness-blocked-and-run-diagnostic-only",
            evidence.attachGate.owner,
            serverJinguiTlsProviderReadinessAttachBlockers(evidence.attachGate),
            missingProofs,
            nonClaims,
            "wait for provider-side attach proof before satisfying SR-030 readiness",
            "QUIC may reuse the diagnostic blocker, but cannot claim provider readiness from it"
        )
    }
    if (!evidence.attachGate.h2RuntimeProofAllowed) {
        return ServerJinguiTlsProviderReadinessGate(
            false,
            false,
            false,
            false,
            "blocked-provider-attach-gate",
            "stop-before-provider-readiness-consumption",
            evidence.attachGate.owner,
            serverJinguiTlsProviderReadinessAttachBlockers(evidence.attachGate),
            missingProofs,
            nonClaims,
            evidence.attachGate.nextAction,
            "QUIC must not consume TLS provider readiness while attach proof is blocked"
        )
    }
    if (missingProofs.size > 0) {
        return ServerJinguiTlsProviderReadinessGate(
            false,
            false,
            false,
            false,
            "blocked-provider-readiness-gap",
            "collect-provider-readiness-evidence-before-consuming-seam",
            "Ignite-SR030-consumption-gate",
            serverJinguiTlsProviderReadinessMissingBlockers(missingProofs),
            missingProofs,
            nonClaims,
            "collect contract import, cert/key API, ALPN, error taxonomy, shutdown, and provider receipt proof",
            "QUIC can reuse the same readiness evidence checklist before consuming a TLS provider"
        )
    }
    ServerJinguiTlsProviderReadinessGate(
        true,
        true,
        true,
        false,
        "ready-for-ignite-provider-consumption",
        "satisfy-tls-provider-seam-without-default-flip",
        "Ignite-SR030-consumption-gate",
        [],
        [],
        nonClaims,
        "use this readiness gate only as an upstream provider seam; open separate runtime/default packets for H1 or H2",
        "QUIC can reuse the provider-readiness checklist but still needs its own runtime proof"
    )
}

func serverJinguiTlsProviderReadinessMissingProofs(
    evidence: ServerJinguiTlsProviderReadinessEvidence
): Array<String> {
    var missing = ArrayList<String>()
    if (!evidence.stableContractImportSurfaceProof) {
        missing.add("STABLE_CONTRACT_IMPORT_SURFACE_PROOF")
    }
    if (!evidence.certKeyContractApiProof) {
        missing.add("CERT_KEY_CONTRACT_API_PROOF")
    }
    if (!evidence.alpnAdvertiseAndReportProof) {
        missing.add("ALPN_ADVERTISE_AND_REPORT_PROOF")
    }
    if (!evidence.errorTaxonomyProof) {
        missing.add("ERROR_TAXONOMY_PROOF")
    }
    if (!evidence.sessionCloseShutdownProof) {
        missing.add("SESSION_CLOSE_SHUTDOWN_PROOF")
    }
    if (!evidence.providerVersionReceiptProof) {
        missing.add("PROVIDER_VERSION_RECEIPT_PROOF")
    }
    missing.toArray()
}

func serverJinguiTlsProviderReadinessAttachBlockers(
    attachGate: ServerJinguiAcceptedTransportTlsAttachProofGate
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("ATTACH_GATE:${attachGate.status}")
    for (blocker in attachGate.blockers) {
        blockers.add("ATTACH_BLOCKER:${blocker}")
    }
    for (missing in attachGate.missingProofs) {
        blockers.add("ATTACH_MISSING:${missing}")
    }
    blockers.toArray()
}

func serverJinguiTlsProviderReadinessMissingBlockers(
    missingProofs: Array<String>
): Array<String> {
    var blockers = ArrayList<String>()
    for (missing in missingProofs) {
        blockers.add("MISSING:${missing}")
    }
    blockers.toArray()
}

func serverJinguiTlsProviderReadinessNonClaims(): Array<String> {
    [
        "NO_PROVIDER_SOURCE_CHANGE_CLAIM",
        "NO_STDX_TLS_REMOVAL_CLAIM",
        "NO_H1_DEFAULT_FLIP_CLAIM",
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_RELEASE_CLAIM",
    ]
}

public class JinguiAcceptedTransportH2RuntimeProofLaunchEvidence {
    public let providerAttachGate: ServerJinguiAcceptedTransportTlsAttachProofGate
    public let streamLifecycleProof: Bool
    public let flowBudgetWindowUpdateProof: Bool
    public let headerProjectionProof: Bool
    public let wireFixtureProof: Bool
    public let responseTurnProgressReadout:
        JinguiAcceptedTransportH2RuntimeProgressReadout

    public init(
        providerAttachGate: ServerJinguiAcceptedTransportTlsAttachProofGate,
        streamLifecycleProof: Bool,
        flowBudgetWindowUpdateProof: Bool,
        headerProjectionProof: Bool,
        wireFixtureProof: Bool,
        responseTurnProgressReadout:
            JinguiAcceptedTransportH2RuntimeProgressReadout
    ) {
        this.providerAttachGate = providerAttachGate
        this.streamLifecycleProof = streamLifecycleProof
        this.flowBudgetWindowUpdateProof = flowBudgetWindowUpdateProof
        this.headerProjectionProof = headerProjectionProof
        this.wireFixtureProof = wireFixtureProof
        this.responseTurnProgressReadout = responseTurnProgressReadout
    }
}

public class JinguiAcceptedTransportH2RuntimeProofLaunchGate {
    public let diagnosticPacketAllowed: Bool
    public let h2RuntimeProofLaunchAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let missingLaunchProofs: Array<String>
    public let closureMissingProofs: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        diagnosticPacketAllowed: Bool,
        h2RuntimeProofLaunchAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
        status: String,
        decision: String,
        blockers: Array<String>,
        missingLaunchProofs: Array<String>,
        closureMissingProofs: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.diagnosticPacketAllowed = diagnosticPacketAllowed
        this.h2RuntimeProofLaunchAllowed = h2RuntimeProofLaunchAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.missingLaunchProofs = missingLaunchProofs.clone()
        this.closureMissingProofs = closureMissingProofs.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2RuntimeProofLaunchGate(
    evidence: JinguiAcceptedTransportH2RuntimeProofLaunchEvidence
): JinguiAcceptedTransportH2RuntimeProofLaunchGate {
    let missingLaunchProofs =
        jinguiAcceptedTransportH2RuntimeProofLaunchMissingProofs(evidence)
    let closureMissingProofs =
        jinguiAcceptedTransportH2RuntimeProofClosureMissingProofs()
    let nonClaims = jinguiAcceptedTransportH2RuntimeProofLaunchNonClaims()

    if (
        evidence.providerAttachGate.status ==
        "expected-provider-blocker-carried"
    ) {
        return JinguiAcceptedTransportH2RuntimeProofLaunchGate(
            true,
            false,
            false,
            "diagnostic-only-provider-blocker-carried",
            "run-h2-diagnostic-only-with-provider-blocker-stop-condition",
            jinguiAcceptedTransportH2RuntimeProofLaunchProviderBlockers(
                evidence.providerAttachGate
            ),
            missingLaunchProofs,
            closureMissingProofs,
            nonClaims,
            "run only diagnostic packets that explicitly carry the provider blocker; do not launch H2 runtime proof",
            "QUIC can carry handshake/provider blockers for diagnostics without claiming runtime progress"
        )
    }
    if (!evidence.providerAttachGate.h2RuntimeProofAllowed) {
        return JinguiAcceptedTransportH2RuntimeProofLaunchGate(
            false,
            false,
            false,
            "blocked-provider-attach-gate",
            "stop-before-h2-runtime-launch",
            jinguiAcceptedTransportH2RuntimeProofLaunchProviderBlockers(
                evidence.providerAttachGate
            ),
            missingLaunchProofs,
            closureMissingProofs,
            nonClaims,
            evidence.providerAttachGate.nextAction,
            "QUIC should not start runtime proof while provider attach proof is blocked"
        )
    }
    if (
        jinguiAcceptedTransportH2RuntimeProofLaunchResponseTurnProgressBlocked(
            evidence.responseTurnProgressReadout
        )
    ) {
        return JinguiAcceptedTransportH2RuntimeProofLaunchGate(
            false,
            false,
            false,
            "blocked-h2-response-turn-progress",
            "repair-response-turn-progress-before-runtime-launch",
            jinguiAcceptedTransportH2RuntimeProofLaunchProgressBlockers(
                evidence.responseTurnProgressReadout
            ),
            missingLaunchProofs,
            closureMissingProofs,
            nonClaims,
            evidence.responseTurnProgressReadout.nextAction,
            "QUIC should consume accepted stream progress before runtime proof launch"
        )
    }
    if (missingLaunchProofs.size > 0) {
        return JinguiAcceptedTransportH2RuntimeProofLaunchGate(
            false,
            false,
            false,
            "blocked-h2-launch-precondition-gap",
            "collect-h2-model-proofs-before-runtime-launch",
            jinguiAcceptedTransportH2RuntimeProofLaunchBlockers(
                missingLaunchProofs
            ),
            missingLaunchProofs,
            closureMissingProofs,
            nonClaims,
            "collect H2 stream lifecycle, flow-budget, header projection, and wire fixture proofs before runtime launch",
            "QUIC should collect stream, flow, header/packet, and fixture proofs before runtime launch"
        )
    }
    JinguiAcceptedTransportH2RuntimeProofLaunchGate(
        true,
        true,
        false,
        "ready-for-h2-runtime-proof-launch",
        "open-bounded-h2-runtime-proof-packet",
        [],
        [],
        closureMissingProofs,
        nonClaims,
        "open a bounded H2 runtime proof packet; closure still requires runtime socket, browser replay, scheduler, and h2spec proof",
        "QUIC can reuse this launch gate after provider proof and before runtime closure claims"
    )
}

func jinguiAcceptedTransportH2RuntimeProofLaunchMissingProofs(
    evidence: JinguiAcceptedTransportH2RuntimeProofLaunchEvidence
): Array<String> {
    var missing = ArrayList<String>()
    if (!evidence.streamLifecycleProof) {
        missing.add("H2_STREAM_LIFECYCLE_PROOF")
    }
    if (!evidence.flowBudgetWindowUpdateProof) {
        missing.add("H2_FLOW_BUDGET_WINDOW_UPDATE_PROOF")
    }
    if (!evidence.headerProjectionProof) {
        missing.add("H2_HEADER_PROJECTION_PROOF")
    }
    if (!evidence.wireFixtureProof) {
        missing.add("H2_WIRE_FIXTURE_PROOF")
    }
    if (
        jinguiAcceptedTransportH2RuntimeProofLaunchResponseTurnProgressBlocked(
            evidence.responseTurnProgressReadout
        )
    ) {
        missing.add("H2_RESPONSE_TURN_PROGRESS_PROOF")
    }
    missing.toArray()
}

func jinguiAcceptedTransportH2RuntimeProofLaunchResponseTurnProgressBlocked(
    readout: JinguiAcceptedTransportH2RuntimeProgressReadout
): Bool {
    !readout.responseTurnProgressAccepted ||
        !readout.h2RuntimeProofContinuationAllowed
}

func jinguiAcceptedTransportH2RuntimeProofLaunchProviderBlockers(
    providerAttachGate: ServerJinguiAcceptedTransportTlsAttachProofGate
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("PROVIDER_ATTACH_GATE:${providerAttachGate.status}")
    for (blocker in providerAttachGate.blockers) {
        blockers.add("PROVIDER_ATTACH_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeProofLaunchProgressBlockers(
    readout: JinguiAcceptedTransportH2RuntimeProgressReadout
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("RESPONSE_TURN_PROGRESS:${readout.status}")
    for (blocker in readout.blockers) {
        blockers.add("RESPONSE_TURN_BLOCKER:${blocker}")
    }
    if (readout.closeReason != "") {
        blockers.add("RESPONSE_TURN_CLOSE_REASON:${readout.closeReason}")
    }
    if (readout.remainingBodyByteCount > 0) {
        blockers.add(
            "RESPONSE_TURN_REMAINING_BODY_BYTES:${readout.remainingBodyByteCount}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeProofLaunchBlockers(
    missingLaunchProofs: Array<String>
): Array<String> {
    var blockers = ArrayList<String>()
    for (missing in missingLaunchProofs) {
        blockers.add("MISSING:${missing}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeProofClosureMissingProofs(): Array<String> {
    [
        "H2_RUNTIME_SOCKET_PROOF",
        "H2_BROWSER_REPLAY_PROOF",
        "H2_SCHEDULER_PROOF",
        "H2SPEC_PROOF",
    ]
}

func jinguiAcceptedTransportH2RuntimeProofLaunchNonClaims(): Array<String> {
    [
        "NO_PROVIDER_FIX",
        "NO_ACCEPTED_TRANSPORT_ATTACH_PASS_CLAIM",
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_H2_SCHEDULER_CLAIM",
        "NO_H2SPEC_CLAIM",
    ]
}

public class JinguiAcceptedTransportH2RuntimeLaunchSchedulerIntakeEvidence {
    public let launchGate: JinguiAcceptedTransportH2RuntimeProofLaunchGate
    public let requestSchedulerReceipt: IgniteRequestSchedulerProofReceipt

    public init(
        launchGate: JinguiAcceptedTransportH2RuntimeProofLaunchGate,
        requestSchedulerReceipt: IgniteRequestSchedulerProofReceipt
    ) {
        this.launchGate = launchGate
        this.requestSchedulerReceipt = requestSchedulerReceipt
    }
}

public class JinguiAcceptedTransportH2RuntimeLaunchSchedulerIntakeGate {
    public let schedulerIntakeAllowed: Bool
    public let boundedSchedulerFollowupAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
    public let runtimeNativeClaimAllowed: Bool
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let runtimeDesignGate: IgniteRuntimeConcurrencyDesignGate
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        schedulerIntakeAllowed: Bool,
        boundedSchedulerFollowupAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
        runtimeNativeClaimAllowed: Bool,
        status: String,
        decision: String,
        blockers: Array<String>,
        runtimeDesignGate: IgniteRuntimeConcurrencyDesignGate,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.schedulerIntakeAllowed = schedulerIntakeAllowed
        this.boundedSchedulerFollowupAllowed =
            boundedSchedulerFollowupAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
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

public func buildJinguiAcceptedTransportH2RuntimeLaunchSchedulerIntakeGate(
    evidence: JinguiAcceptedTransportH2RuntimeLaunchSchedulerIntakeEvidence
): JinguiAcceptedTransportH2RuntimeLaunchSchedulerIntakeGate {
    let nonClaims =
        jinguiAcceptedTransportH2RuntimeLaunchSchedulerIntakeNonClaims()
    if (!evidence.launchGate.h2RuntimeProofLaunchAllowed) {
        return JinguiAcceptedTransportH2RuntimeLaunchSchedulerIntakeGate(
            false,
            false,
            false,
            false,
            "blocked-h2-runtime-proof-launch-not-ready",
            "complete-h2-runtime-proof-launch-before-scheduler-intake",
            jinguiAcceptedTransportH2RuntimeLaunchSchedulerIntakeLaunchBlockers(
                evidence.launchGate
            ),
            evidence.requestSchedulerReceipt.runtimeDesignGate,
            nonClaims,
            "repair H2 runtime proof launch gate before scheduler intake; do not treat diagnostics as scheduler readiness",
            "QUIC should not start stream scheduler intake before stream runtime launch is accepted"
        )
    }
    if (
        !evidence.requestSchedulerReceipt.requestLevelSchedulerProofAccepted ||
        !evidence.requestSchedulerReceipt.handlerIoDecouplingProofAccepted
    ) {
        return JinguiAcceptedTransportH2RuntimeLaunchSchedulerIntakeGate(
            false,
            false,
            false,
            false,
            "blocked-request-scheduler-proof-intake",
            "collect-request-level-scheduler-proof-before-h2-scheduler-intake",
            jinguiAcceptedTransportH2RuntimeLaunchSchedulerIntakeRequestBlockers(
                evidence.requestSchedulerReceipt
            ),
            evidence.requestSchedulerReceipt.runtimeDesignGate,
            nonClaims,
            evidence.requestSchedulerReceipt.nextAction,
            "QUIC must carry stream identity and handler/I-O boundary proof before stream scheduler intake"
        )
    }
    JinguiAcceptedTransportH2RuntimeLaunchSchedulerIntakeGate(
        true,
        true,
        false,
        evidence.requestSchedulerReceipt.runtimeNativeClaimAllowed,
        "ready-for-h2-runtime-scheduler-intake",
        "open-bounded-h2-runtime-scheduler-followup",
        [],
        evidence.requestSchedulerReceipt.runtimeDesignGate,
        nonClaims,
        "open a bounded H2 runtime scheduler follow-up; runtime-native and H2 closure claims still require long/short lane, blocking isolation, fairness/backpressure, browser, and h2spec proof",
        "QUIC can reuse launch-plus-scheduler-intake before stream scheduler implementation"
    )
}

func jinguiAcceptedTransportH2RuntimeLaunchSchedulerIntakeLaunchBlockers(
    launchGate: JinguiAcceptedTransportH2RuntimeProofLaunchGate
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("H2_LAUNCH_GATE:${launchGate.status}")
    for (blocker in launchGate.blockers) {
        blockers.add("H2_LAUNCH_BLOCKER:${blocker}")
    }
    for (missing in launchGate.missingLaunchProofs) {
        blockers.add("H2_LAUNCH_MISSING:${missing}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeLaunchSchedulerIntakeRequestBlockers(
    receipt: IgniteRequestSchedulerProofReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("REQUEST_SCHEDULER:${receipt.status}")
    for (blocker in receipt.blockers) {
        blockers.add("REQUEST_SCHEDULER_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeLaunchSchedulerIntakeNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_RUNTIME_SCHEDULER_IMPLEMENTATION",
        "NO_RUNTIME_NATIVE_CLAIM",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
    ]
}

public class JinguiAcceptedTransportH2SchedulerRuntimeQueueAdmissionEvidence {
    public let schedulerIntakeGate:
        JinguiAcceptedTransportH2RuntimeLaunchSchedulerIntakeGate
    public let runtimeQueueIntegrationPlanReceipt:
        IgniteRuntimeQueueIntegrationPlanReceipt

    public init(
        schedulerIntakeGate:
            JinguiAcceptedTransportH2RuntimeLaunchSchedulerIntakeGate,
        runtimeQueueIntegrationPlanReceipt:
            IgniteRuntimeQueueIntegrationPlanReceipt
    ) {
        this.schedulerIntakeGate = schedulerIntakeGate
        this.runtimeQueueIntegrationPlanReceipt =
            runtimeQueueIntegrationPlanReceipt
    }
}

public class JinguiAcceptedTransportH2SchedulerRuntimeQueueAdmissionBridge {
    public let h2SchedulerRuntimeQueueAdmissionAccepted: Bool
    public let schedulerIntakeAllowed: Bool
    public let runtimeQueueIntegrationPlanAccepted: Bool
    public let runtimeQueueIntegrationPlanAllowed: Bool
    public let boundedRuntimeQueueFollowupAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let liveExecutorEnqueueAllowed: Bool
    public let runtimeTaskSpawnAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
    public let runtimeQueueIntegrationPlanMode: String
    public let integrationPlanId: String
    public let queueDepthBefore: Int64
    public let queueDepthAfter: Int64
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2SchedulerRuntimeQueueAdmissionAccepted: Bool,
        schedulerIntakeAllowed: Bool,
        runtimeQueueIntegrationPlanAccepted: Bool,
        runtimeQueueIntegrationPlanAllowed: Bool,
        boundedRuntimeQueueFollowupAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        liveExecutorEnqueueAllowed: Bool,
        runtimeTaskSpawnAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
        runtimeQueueIntegrationPlanMode: String,
        integrationPlanId: String,
        queueDepthBefore: Int64,
        queueDepthAfter: Int64,
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2SchedulerRuntimeQueueAdmissionAccepted =
            h2SchedulerRuntimeQueueAdmissionAccepted
        this.schedulerIntakeAllowed = schedulerIntakeAllowed
        this.runtimeQueueIntegrationPlanAccepted =
            runtimeQueueIntegrationPlanAccepted
        this.runtimeQueueIntegrationPlanAllowed =
            runtimeQueueIntegrationPlanAllowed
        this.boundedRuntimeQueueFollowupAllowed =
            boundedRuntimeQueueFollowupAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.liveExecutorEnqueueAllowed = liveExecutorEnqueueAllowed
        this.runtimeTaskSpawnAllowed = runtimeTaskSpawnAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.runtimeQueueIntegrationPlanMode =
            runtimeQueueIntegrationPlanMode
        this.integrationPlanId = integrationPlanId
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

public func buildJinguiAcceptedTransportH2SchedulerRuntimeQueueAdmissionBridge(
    evidence: JinguiAcceptedTransportH2SchedulerRuntimeQueueAdmissionEvidence
): JinguiAcceptedTransportH2SchedulerRuntimeQueueAdmissionBridge {
    let planReceipt = evidence.runtimeQueueIntegrationPlanReceipt
    let nonClaims =
        jinguiAcceptedTransportH2SchedulerRuntimeQueueAdmissionNonClaims()
    if (
        !evidence.schedulerIntakeGate.schedulerIntakeAllowed ||
        !evidence.schedulerIntakeGate.boundedSchedulerFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2SchedulerRuntimeQueueAdmissionBridge(
            false,
            evidence.schedulerIntakeGate.schedulerIntakeAllowed,
            planReceipt.runtimeQueueIntegrationPlanAccepted,
            planReceipt.runtimeQueueIntegrationPlanAllowed,
            false,
            false,
            false,
            false,
            false,
            planReceipt.runtimeQueueIntegrationPlanMode,
            planReceipt.integrationPlanId,
            planReceipt.queueDepthBefore,
            planReceipt.queueDepthAfter,
            "blocked-h2-runtime-scheduler-intake",
            "collect-accepted-h2-scheduler-intake-before-runtime-queue-admission",
            jinguiAcceptedTransportH2SchedulerRuntimeQueueAdmissionIntakeBlockers(
                evidence.schedulerIntakeGate
            ),
            nonClaims,
            "repair H2 scheduler intake before runtime queue admission; do not treat H2 launch readiness as queue admission readiness",
            "QUIC must pass stream scheduler intake before stream runtime queue admission"
        )
    }
    if (
        !planReceipt.runtimeQueueIntegrationPlanAccepted ||
        !planReceipt.runtimeQueueIntegrationPlanAllowed
    ) {
        return JinguiAcceptedTransportH2SchedulerRuntimeQueueAdmissionBridge(
            false,
            true,
            planReceipt.runtimeQueueIntegrationPlanAccepted,
            planReceipt.runtimeQueueIntegrationPlanAllowed,
            false,
            false,
            false,
            false,
            false,
            planReceipt.runtimeQueueIntegrationPlanMode,
            planReceipt.integrationPlanId,
            planReceipt.queueDepthBefore,
            planReceipt.queueDepthAfter,
            "blocked-runtime-queue-integration-plan-receipt",
            "collect-accepted-runtime-queue-integration-plan-before-h2-queue-admission",
            jinguiAcceptedTransportH2SchedulerRuntimeQueueAdmissionPlanBlockers(
                planReceipt
            ),
            nonClaims,
            planReceipt.nextAction,
            "QUIC must not consume rejected runtime queue integration plans for stream queue admission"
        )
    }

    JinguiAcceptedTransportH2SchedulerRuntimeQueueAdmissionBridge(
        true,
        true,
        true,
        planReceipt.runtimeQueueIntegrationPlanAllowed,
        true,
        planReceipt.productionQueueMutationAllowed,
        planReceipt.liveExecutorEnqueueAllowed,
        planReceipt.runtimeTaskSpawnAllowed,
        false,
        planReceipt.runtimeQueueIntegrationPlanMode,
        planReceipt.integrationPlanId,
        planReceipt.queueDepthBefore,
        planReceipt.queueDepthAfter,
        "accepted-h2-scheduler-runtime-queue-admission-bridge",
        "record-h2-scheduler-intake-to-runtime-queue-admission-without-runtime-task-spawn",
        [],
        nonClaims,
        "next packet may plan H2 runtime queue commit boundaries; production mutation, live executor enqueue, runtime task spawn, H2 closure, and release flip remain denied",
        "QUIC can reuse scheduler-intake plus runtime queue admission before stream queue commit boundaries"
    )
}

func jinguiAcceptedTransportH2SchedulerRuntimeQueueAdmissionIntakeBlockers(
    gate: JinguiAcceptedTransportH2RuntimeLaunchSchedulerIntakeGate
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("H2_SCHEDULER_INTAKE:${gate.status}")
    for (blocker in gate.blockers) {
        blockers.add("H2_SCHEDULER_INTAKE_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2SchedulerRuntimeQueueAdmissionPlanBlockers(
    receipt: IgniteRuntimeQueueIntegrationPlanReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("RUNTIME_QUEUE_INTEGRATION_PLAN:${receipt.status}")
    for (blocker in receipt.blockers) {
        blockers.add("RUNTIME_QUEUE_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2SchedulerRuntimeQueueAdmissionNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_RUNTIME_SCHEDULER_IMPLEMENTATION",
        "NO_PRODUCTION_QUEUE_MUTATION",
        "NO_LIVE_EXECUTOR_ENQUEUE",
        "NO_RUNTIME_TASK_SPAWN",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2RuntimeQueueCommitBoundaryEvidence {
    public let queueAdmissionBridge:
        JinguiAcceptedTransportH2SchedulerRuntimeQueueAdmissionBridge
    public let runtimeQueueCommitBoundaryReceipt:
        IgniteRuntimeQueueCommitBoundaryReceipt

    public init(
        queueAdmissionBridge:
            JinguiAcceptedTransportH2SchedulerRuntimeQueueAdmissionBridge,
        runtimeQueueCommitBoundaryReceipt:
            IgniteRuntimeQueueCommitBoundaryReceipt
    ) {
        this.queueAdmissionBridge = queueAdmissionBridge
        this.runtimeQueueCommitBoundaryReceipt =
            runtimeQueueCommitBoundaryReceipt
    }
}

public class JinguiAcceptedTransportH2RuntimeQueueCommitBoundaryBridge {
    public let h2RuntimeQueueCommitBoundaryAccepted: Bool
    public let h2RuntimeQueueAdmissionAccepted: Bool
    public let runtimeQueueCommitBoundaryAccepted: Bool
    public let runtimeQueueCommitBoundaryAllowed: Bool
    public let boundedCommitBoundaryFollowupAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let liveExecutorEnqueueAllowed: Bool
    public let runtimeTaskSpawnAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
    public let runtimeQueueCommitBoundaryMode: String
    public let commitBoundaryId: String
    public let integrationPlanId: String
    public let queueDepthBefore: Int64
    public let queueDepthAfter: Int64
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2RuntimeQueueCommitBoundaryAccepted: Bool,
        h2RuntimeQueueAdmissionAccepted: Bool,
        runtimeQueueCommitBoundaryAccepted: Bool,
        runtimeQueueCommitBoundaryAllowed: Bool,
        boundedCommitBoundaryFollowupAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        liveExecutorEnqueueAllowed: Bool,
        runtimeTaskSpawnAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
        runtimeQueueCommitBoundaryMode: String,
        commitBoundaryId: String,
        integrationPlanId: String,
        queueDepthBefore: Int64,
        queueDepthAfter: Int64,
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2RuntimeQueueCommitBoundaryAccepted =
            h2RuntimeQueueCommitBoundaryAccepted
        this.h2RuntimeQueueAdmissionAccepted =
            h2RuntimeQueueAdmissionAccepted
        this.runtimeQueueCommitBoundaryAccepted =
            runtimeQueueCommitBoundaryAccepted
        this.runtimeQueueCommitBoundaryAllowed =
            runtimeQueueCommitBoundaryAllowed
        this.boundedCommitBoundaryFollowupAllowed =
            boundedCommitBoundaryFollowupAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.liveExecutorEnqueueAllowed = liveExecutorEnqueueAllowed
        this.runtimeTaskSpawnAllowed = runtimeTaskSpawnAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.runtimeQueueCommitBoundaryMode =
            runtimeQueueCommitBoundaryMode
        this.commitBoundaryId = commitBoundaryId
        this.integrationPlanId = integrationPlanId
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

public func buildJinguiAcceptedTransportH2RuntimeQueueCommitBoundaryBridge(
    evidence: JinguiAcceptedTransportH2RuntimeQueueCommitBoundaryEvidence
): JinguiAcceptedTransportH2RuntimeQueueCommitBoundaryBridge {
    let commitReceipt = evidence.runtimeQueueCommitBoundaryReceipt
    let nonClaims =
        jinguiAcceptedTransportH2RuntimeQueueCommitBoundaryNonClaims()
    if (
        !evidence.queueAdmissionBridge.h2SchedulerRuntimeQueueAdmissionAccepted ||
        !evidence.queueAdmissionBridge.boundedRuntimeQueueFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeQueueCommitBoundaryBridge(
            false,
            evidence.queueAdmissionBridge.h2SchedulerRuntimeQueueAdmissionAccepted,
            commitReceipt.runtimeQueueCommitBoundaryAccepted,
            commitReceipt.runtimeQueueCommitBoundaryAllowed,
            false,
            false,
            false,
            false,
            false,
            commitReceipt.runtimeQueueCommitBoundaryMode,
            commitReceipt.commitBoundaryId,
            commitReceipt.integrationPlanId,
            commitReceipt.queueDepthBefore,
            commitReceipt.queueDepthAfter,
            "blocked-h2-runtime-queue-admission-bridge",
            "collect-accepted-h2-runtime-queue-admission-before-commit-boundary",
            jinguiAcceptedTransportH2RuntimeQueueCommitBoundaryAdmissionBlockers(
                evidence.queueAdmissionBridge
            ),
            nonClaims,
            "repair H2 runtime queue admission before queue commit boundary; do not treat admission planning as commit-boundary readiness",
            "QUIC must pass stream queue admission before stream queue commit boundary"
        )
    }
    if (
        !commitReceipt.runtimeQueueCommitBoundaryAccepted ||
        !commitReceipt.runtimeQueueCommitBoundaryAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeQueueCommitBoundaryBridge(
            false,
            true,
            commitReceipt.runtimeQueueCommitBoundaryAccepted,
            commitReceipt.runtimeQueueCommitBoundaryAllowed,
            false,
            false,
            false,
            false,
            false,
            commitReceipt.runtimeQueueCommitBoundaryMode,
            commitReceipt.commitBoundaryId,
            commitReceipt.integrationPlanId,
            commitReceipt.queueDepthBefore,
            commitReceipt.queueDepthAfter,
            "blocked-runtime-queue-commit-boundary-receipt",
            "collect-accepted-runtime-queue-commit-boundary-before-h2-queue-mutation-gate",
            jinguiAcceptedTransportH2RuntimeQueueCommitBoundaryReceiptBlockers(
                commitReceipt
            ),
            nonClaims,
            commitReceipt.nextAction,
            "QUIC must not consume rejected queue commit boundaries for stream queue mutation gates"
        )
    }

    JinguiAcceptedTransportH2RuntimeQueueCommitBoundaryBridge(
        true,
        true,
        true,
        commitReceipt.runtimeQueueCommitBoundaryAllowed,
        true,
        commitReceipt.productionQueueMutationAllowed,
        commitReceipt.liveExecutorEnqueueAllowed,
        commitReceipt.runtimeTaskSpawnAllowed,
        false,
        commitReceipt.runtimeQueueCommitBoundaryMode,
        commitReceipt.commitBoundaryId,
        commitReceipt.integrationPlanId,
        commitReceipt.queueDepthBefore,
        commitReceipt.queueDepthAfter,
        "accepted-h2-runtime-queue-commit-boundary-bridge",
        "record-h2-runtime-queue-admission-to-commit-boundary-without-production-mutation",
        [],
        nonClaims,
        "next packet may plan an H2 production queue mutation gate; production mutation, live executor enqueue, runtime task spawn, H2 closure, and release flip remain denied",
        "QUIC can reuse queue admission plus commit boundary before stream queue mutation gates"
    )
}

func jinguiAcceptedTransportH2RuntimeQueueCommitBoundaryAdmissionBlockers(
    bridge: JinguiAcceptedTransportH2SchedulerRuntimeQueueAdmissionBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("H2_QUEUE_ADMISSION:${bridge.status}")
    for (blocker in bridge.blockers) {
        blockers.add("H2_QUEUE_ADMISSION_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeQueueCommitBoundaryReceiptBlockers(
    receipt: IgniteRuntimeQueueCommitBoundaryReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("RUNTIME_QUEUE_COMMIT_BOUNDARY:${receipt.status}")
    for (blocker in receipt.blockers) {
        blockers.add("RUNTIME_QUEUE_COMMIT_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeQueueCommitBoundaryNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_RUNTIME_SCHEDULER_IMPLEMENTATION",
        "NO_PRODUCTION_QUEUE_MUTATION",
        "NO_LIVE_EXECUTOR_ENQUEUE",
        "NO_RUNTIME_TASK_SPAWN",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2ProductionQueueMutationGateEvidence {
    public let h2RuntimeQueueCommitBoundaryBridge:
        JinguiAcceptedTransportH2RuntimeQueueCommitBoundaryBridge
    public let productionQueueMutationGateReceipt:
        IgniteProductionQueueMutationGateReceipt

    public init(
        h2RuntimeQueueCommitBoundaryBridge:
            JinguiAcceptedTransportH2RuntimeQueueCommitBoundaryBridge,
        productionQueueMutationGateReceipt:
            IgniteProductionQueueMutationGateReceipt
    ) {
        this.h2RuntimeQueueCommitBoundaryBridge =
            h2RuntimeQueueCommitBoundaryBridge
        this.productionQueueMutationGateReceipt =
            productionQueueMutationGateReceipt
    }
}

public class JinguiAcceptedTransportH2ProductionQueueMutationGateBridge {
    public let h2ProductionQueueMutationGateAccepted: Bool
    public let h2RuntimeQueueCommitBoundaryAccepted: Bool
    public let productionQueueMutationGateAccepted: Bool
    public let productionQueueMutationGateAllowed: Bool
    public let boundedProductionQueueMutationGateFollowupAllowed: Bool
    public let actualProductionQueueMutationAllowed: Bool
    public let liveExecutorEnqueueAllowed: Bool
    public let runtimeTaskSpawnAllowed: Bool
    public let handlerInvocationAllowed: Bool
    public let requestContextMutationAllowed: Bool
    public let responseWriteAllowed: Bool
    public let transportCommitAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
    public let productionQueueMutationGateMode: String
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
        h2ProductionQueueMutationGateAccepted: Bool,
        h2RuntimeQueueCommitBoundaryAccepted: Bool,
        productionQueueMutationGateAccepted: Bool,
        productionQueueMutationGateAllowed: Bool,
        boundedProductionQueueMutationGateFollowupAllowed: Bool,
        actualProductionQueueMutationAllowed: Bool,
        liveExecutorEnqueueAllowed: Bool,
        runtimeTaskSpawnAllowed: Bool,
        handlerInvocationAllowed: Bool,
        requestContextMutationAllowed: Bool,
        responseWriteAllowed: Bool,
        transportCommitAllowed: Bool,
        liveServerWiringAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
        productionQueueMutationGateMode: String,
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
        this.h2ProductionQueueMutationGateAccepted =
            h2ProductionQueueMutationGateAccepted
        this.h2RuntimeQueueCommitBoundaryAccepted =
            h2RuntimeQueueCommitBoundaryAccepted
        this.productionQueueMutationGateAccepted =
            productionQueueMutationGateAccepted
        this.productionQueueMutationGateAllowed =
            productionQueueMutationGateAllowed
        this.boundedProductionQueueMutationGateFollowupAllowed =
            boundedProductionQueueMutationGateFollowupAllowed
        this.actualProductionQueueMutationAllowed =
            actualProductionQueueMutationAllowed
        this.liveExecutorEnqueueAllowed = liveExecutorEnqueueAllowed
        this.runtimeTaskSpawnAllowed = runtimeTaskSpawnAllowed
        this.handlerInvocationAllowed = handlerInvocationAllowed
        this.requestContextMutationAllowed = requestContextMutationAllowed
        this.responseWriteAllowed = responseWriteAllowed
        this.transportCommitAllowed = transportCommitAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.productionQueueMutationGateMode =
            productionQueueMutationGateMode
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

public func buildJinguiAcceptedTransportH2ProductionQueueMutationGateBridge(
    evidence: JinguiAcceptedTransportH2ProductionQueueMutationGateEvidence
): JinguiAcceptedTransportH2ProductionQueueMutationGateBridge {
    let h2Bridge = evidence.h2RuntimeQueueCommitBoundaryBridge
    let gateReceipt = evidence.productionQueueMutationGateReceipt
    let nonClaims =
        jinguiAcceptedTransportH2ProductionQueueMutationGateNonClaims()
    if (
        !h2Bridge.h2RuntimeQueueCommitBoundaryAccepted ||
        !h2Bridge.boundedCommitBoundaryFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2ProductionQueueMutationGateBridge(
            false,
            h2Bridge.h2RuntimeQueueCommitBoundaryAccepted,
            gateReceipt.productionQueueMutationGateAccepted,
            gateReceipt.productionQueueMutationGateAllowed,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            gateReceipt.productionQueueMutationGateMode,
            gateReceipt.mutationGateId,
            h2Bridge.commitBoundaryId,
            gateReceipt.queueWriteId,
            h2Bridge.queueDepthBefore,
            h2Bridge.queueDepthAfter,
            "blocked-h2-runtime-queue-commit-boundary-bridge",
            "collect-accepted-h2-runtime-queue-commit-boundary-before-production-queue-mutation-gate",
            jinguiAcceptedTransportH2ProductionQueueMutationGateCommitBoundaryBlockers(
                h2Bridge
            ),
            nonClaims,
            "repair H2 queue commit boundary before production queue mutation gate; do not treat generic queue gates as H2 runtime readiness",
            "QUIC must pass stream queue commit boundaries before stream queue mutation gates"
        )
    }
    if (
        !gateReceipt.productionQueueMutationGateAccepted ||
        !gateReceipt.productionQueueMutationGateAllowed
    ) {
        return JinguiAcceptedTransportH2ProductionQueueMutationGateBridge(
            false,
            true,
            gateReceipt.productionQueueMutationGateAccepted,
            gateReceipt.productionQueueMutationGateAllowed,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            gateReceipt.productionQueueMutationGateMode,
            gateReceipt.mutationGateId,
            gateReceipt.commitBoundaryId,
            gateReceipt.queueWriteId,
            gateReceipt.queueDepthBefore,
            gateReceipt.queueDepthAfter,
            "blocked-production-queue-mutation-gate-receipt",
            "collect-accepted-production-queue-mutation-gate-before-h2-mutation-dry-run",
            jinguiAcceptedTransportH2ProductionQueueMutationGateReceiptBlockers(
                gateReceipt
            ),
            nonClaims,
            gateReceipt.nextAction,
            "QUIC must not consume rejected production queue mutation gates for stream mutation dry-runs"
        )
    }

    JinguiAcceptedTransportH2ProductionQueueMutationGateBridge(
        true,
        true,
        true,
        gateReceipt.productionQueueMutationGateAllowed,
        true,
        gateReceipt.actualProductionQueueMutationAllowed,
        gateReceipt.liveExecutorEnqueueAllowed,
        gateReceipt.runtimeTaskSpawnAllowed,
        gateReceipt.handlerInvocationAllowed,
        gateReceipt.requestContextMutationAllowed,
        gateReceipt.responseWriteAllowed,
        gateReceipt.transportCommitAllowed,
        gateReceipt.liveServerWiringAllowed,
        false,
        gateReceipt.productionQueueMutationGateMode,
        gateReceipt.mutationGateId,
        gateReceipt.commitBoundaryId,
        gateReceipt.queueWriteId,
        gateReceipt.queueDepthBefore,
        gateReceipt.queueDepthAfter,
        "accepted-h2-production-queue-mutation-gate-bridge",
        "record-h2-commit-boundary-to-production-queue-mutation-gate-without-actual-mutation",
        [],
        nonClaims,
        "next packet may plan an H2 production queue mutation dry-run; actual mutation, live executor enqueue, runtime task spawn, H2 closure, and release flip remain denied",
        "QUIC can reuse H2-style commit-boundary plus mutation-gate separation before stream queue mutation dry-runs"
    )
}

func jinguiAcceptedTransportH2ProductionQueueMutationGateCommitBoundaryBlockers(
    bridge: JinguiAcceptedTransportH2RuntimeQueueCommitBoundaryBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("H2_RUNTIME_QUEUE_COMMIT_BOUNDARY:${bridge.status}")
    for (blocker in bridge.blockers) {
        blockers.add("H2_RUNTIME_QUEUE_COMMIT_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2ProductionQueueMutationGateReceiptBlockers(
    receipt: IgniteProductionQueueMutationGateReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("PRODUCTION_QUEUE_MUTATION_GATE:${receipt.status}")
    for (blocker in receipt.blockers) {
        blockers.add("PRODUCTION_QUEUE_MUTATION_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2ProductionQueueMutationGateNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_ACTUAL_PRODUCTION_QUEUE_MUTATION",
        "NO_LIVE_EXECUTOR_ENQUEUE",
        "NO_RUNTIME_TASK_SPAWN",
        "NO_HANDLER_INVOCATION",
        "NO_REQUEST_CONTEXT_MUTATION",
        "NO_RESPONSE_WRITE",
        "NO_TRANSPORT_COMMIT",
        "NO_LIVE_SERVER_WIRING",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2ProductionQueueMutationDryRunEvidence {
    public let h2ProductionQueueMutationGateBridge:
        JinguiAcceptedTransportH2ProductionQueueMutationGateBridge
    public let productionQueueMutationDryRunReceipt:
        IgniteProductionQueueMutationDryRunReceipt

    public init(
        h2ProductionQueueMutationGateBridge:
            JinguiAcceptedTransportH2ProductionQueueMutationGateBridge,
        productionQueueMutationDryRunReceipt:
            IgniteProductionQueueMutationDryRunReceipt
    ) {
        this.h2ProductionQueueMutationGateBridge =
            h2ProductionQueueMutationGateBridge
        this.productionQueueMutationDryRunReceipt =
            productionQueueMutationDryRunReceipt
    }
}

public class JinguiAcceptedTransportH2ProductionQueueMutationDryRunBridge {
    public let h2ProductionQueueMutationDryRunAccepted: Bool
    public let h2ProductionQueueMutationGateAccepted: Bool
    public let productionQueueMutationDryRunAccepted: Bool
    public let productionQueueMutationDryRunAllowed: Bool
    public let boundedProductionQueueMutationDryRunFollowupAllowed: Bool
    public let actualProductionQueueMutationAllowed: Bool
    public let liveExecutorEnqueueAllowed: Bool
    public let runtimeTaskSpawnAllowed: Bool
    public let handlerInvocationAllowed: Bool
    public let requestContextMutationAllowed: Bool
    public let responseWriteAllowed: Bool
    public let transportCommitAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
    public let productionQueueMutationDryRunMode: String
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
        h2ProductionQueueMutationDryRunAccepted: Bool,
        h2ProductionQueueMutationGateAccepted: Bool,
        productionQueueMutationDryRunAccepted: Bool,
        productionQueueMutationDryRunAllowed: Bool,
        boundedProductionQueueMutationDryRunFollowupAllowed: Bool,
        actualProductionQueueMutationAllowed: Bool,
        liveExecutorEnqueueAllowed: Bool,
        runtimeTaskSpawnAllowed: Bool,
        handlerInvocationAllowed: Bool,
        requestContextMutationAllowed: Bool,
        responseWriteAllowed: Bool,
        transportCommitAllowed: Bool,
        liveServerWiringAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
        productionQueueMutationDryRunMode: String,
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
        this.h2ProductionQueueMutationDryRunAccepted =
            h2ProductionQueueMutationDryRunAccepted
        this.h2ProductionQueueMutationGateAccepted =
            h2ProductionQueueMutationGateAccepted
        this.productionQueueMutationDryRunAccepted =
            productionQueueMutationDryRunAccepted
        this.productionQueueMutationDryRunAllowed =
            productionQueueMutationDryRunAllowed
        this.boundedProductionQueueMutationDryRunFollowupAllowed =
            boundedProductionQueueMutationDryRunFollowupAllowed
        this.actualProductionQueueMutationAllowed =
            actualProductionQueueMutationAllowed
        this.liveExecutorEnqueueAllowed = liveExecutorEnqueueAllowed
        this.runtimeTaskSpawnAllowed = runtimeTaskSpawnAllowed
        this.handlerInvocationAllowed = handlerInvocationAllowed
        this.requestContextMutationAllowed = requestContextMutationAllowed
        this.responseWriteAllowed = responseWriteAllowed
        this.transportCommitAllowed = transportCommitAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.productionQueueMutationDryRunMode =
            productionQueueMutationDryRunMode
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

public func buildJinguiAcceptedTransportH2ProductionQueueMutationDryRunBridge(
    evidence: JinguiAcceptedTransportH2ProductionQueueMutationDryRunEvidence
): JinguiAcceptedTransportH2ProductionQueueMutationDryRunBridge {
    let h2GateBridge = evidence.h2ProductionQueueMutationGateBridge
    let dryRunReceipt = evidence.productionQueueMutationDryRunReceipt
    let nonClaims =
        jinguiAcceptedTransportH2ProductionQueueMutationDryRunNonClaims()
    if (
        !h2GateBridge.h2ProductionQueueMutationGateAccepted ||
        !h2GateBridge.boundedProductionQueueMutationGateFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2ProductionQueueMutationDryRunBridge(
            false,
            h2GateBridge.h2ProductionQueueMutationGateAccepted,
            dryRunReceipt.productionQueueMutationDryRunAccepted,
            dryRunReceipt.productionQueueMutationDryRunAllowed,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            dryRunReceipt.productionQueueMutationDryRunMode,
            dryRunReceipt.mutationDryRunId,
            h2GateBridge.mutationGateId,
            h2GateBridge.commitBoundaryId,
            h2GateBridge.queueWriteId,
            h2GateBridge.queueDepthBefore,
            h2GateBridge.queueDepthAfter,
            "blocked-h2-production-queue-mutation-gate-bridge",
            "collect-accepted-h2-production-queue-mutation-gate-before-dry-run",
            jinguiAcceptedTransportH2ProductionQueueMutationDryRunGateBlockers(
                h2GateBridge
            ),
            nonClaims,
            "repair H2 production queue mutation gate before dry-run; do not treat generic dry-run receipts as H2 runtime readiness",
            "QUIC must pass stream mutation gates before stream mutation dry-runs"
        )
    }
    if (
        !dryRunReceipt.productionQueueMutationDryRunAccepted ||
        !dryRunReceipt.productionQueueMutationDryRunAllowed
    ) {
        return JinguiAcceptedTransportH2ProductionQueueMutationDryRunBridge(
            false,
            true,
            dryRunReceipt.productionQueueMutationDryRunAccepted,
            dryRunReceipt.productionQueueMutationDryRunAllowed,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            dryRunReceipt.productionQueueMutationDryRunMode,
            dryRunReceipt.mutationDryRunId,
            dryRunReceipt.mutationGateId,
            dryRunReceipt.commitBoundaryId,
            dryRunReceipt.queueWriteId,
            dryRunReceipt.queueDepthBefore,
            dryRunReceipt.queueDepthAfter,
            "blocked-production-queue-mutation-dry-run-receipt",
            "collect-accepted-production-queue-mutation-dry-run-before-h2-commit-plan",
            jinguiAcceptedTransportH2ProductionQueueMutationDryRunReceiptBlockers(
                dryRunReceipt
            ),
            nonClaims,
            dryRunReceipt.nextAction,
            "QUIC must not consume rejected production mutation dry-runs for stream mutation commit plans"
        )
    }

    JinguiAcceptedTransportH2ProductionQueueMutationDryRunBridge(
        true,
        true,
        true,
        dryRunReceipt.productionQueueMutationDryRunAllowed,
        true,
        dryRunReceipt.actualProductionQueueMutationAllowed,
        dryRunReceipt.liveExecutorEnqueueAllowed,
        dryRunReceipt.runtimeTaskSpawnAllowed,
        dryRunReceipt.handlerInvocationAllowed,
        dryRunReceipt.requestContextMutationAllowed,
        dryRunReceipt.responseWriteAllowed,
        dryRunReceipt.transportCommitAllowed,
        dryRunReceipt.liveServerWiringAllowed,
        false,
        dryRunReceipt.productionQueueMutationDryRunMode,
        dryRunReceipt.mutationDryRunId,
        dryRunReceipt.mutationGateId,
        dryRunReceipt.commitBoundaryId,
        dryRunReceipt.queueWriteId,
        dryRunReceipt.queueDepthBefore,
        dryRunReceipt.queueDepthAfter,
        "accepted-h2-production-queue-mutation-dry-run-bridge",
        "record-h2-production-queue-mutation-dry-run-without-actual-mutation",
        [],
        nonClaims,
        "next packet may plan an H2 production queue mutation commit-plan; actual mutation, live executor enqueue, runtime task spawn, H2 closure, and release flip remain denied",
        "QUIC can reuse H2-style mutation gate plus dry-run separation before stream queue mutation commit plans"
    )
}

func jinguiAcceptedTransportH2ProductionQueueMutationDryRunGateBlockers(
    bridge: JinguiAcceptedTransportH2ProductionQueueMutationGateBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("H2_PRODUCTION_QUEUE_MUTATION_GATE:${bridge.status}")
    for (blocker in bridge.blockers) {
        blockers.add("H2_PRODUCTION_QUEUE_MUTATION_GATE_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2ProductionQueueMutationDryRunReceiptBlockers(
    receipt: IgniteProductionQueueMutationDryRunReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("PRODUCTION_QUEUE_MUTATION_DRY_RUN:${receipt.status}")
    for (blocker in receipt.blockers) {
        blockers.add("PRODUCTION_QUEUE_MUTATION_DRY_RUN_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2ProductionQueueMutationDryRunNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_ACTUAL_PRODUCTION_QUEUE_MUTATION",
        "NO_LIVE_EXECUTOR_ENQUEUE",
        "NO_RUNTIME_TASK_SPAWN",
        "NO_HANDLER_INVOCATION",
        "NO_REQUEST_CONTEXT_MUTATION",
        "NO_RESPONSE_WRITE",
        "NO_TRANSPORT_COMMIT",
        "NO_LIVE_SERVER_WIRING",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2ProductionQueueMutationCommitPlanEvidence {
    public let h2ProductionQueueMutationDryRunBridge:
        JinguiAcceptedTransportH2ProductionQueueMutationDryRunBridge
    public let productionQueueMutationCommitPlanReceipt:
        IgniteProductionQueueMutationCommitPlanReceipt

    public init(
        h2ProductionQueueMutationDryRunBridge:
            JinguiAcceptedTransportH2ProductionQueueMutationDryRunBridge,
        productionQueueMutationCommitPlanReceipt:
            IgniteProductionQueueMutationCommitPlanReceipt
    ) {
        this.h2ProductionQueueMutationDryRunBridge =
            h2ProductionQueueMutationDryRunBridge
        this.productionQueueMutationCommitPlanReceipt =
            productionQueueMutationCommitPlanReceipt
    }
}

public class JinguiAcceptedTransportH2ProductionQueueMutationCommitPlanBridge {
    public let h2ProductionQueueMutationCommitPlanAccepted: Bool
    public let h2ProductionQueueMutationDryRunAccepted: Bool
    public let productionQueueMutationCommitPlanAccepted: Bool
    public let productionQueueMutationCommitPlanAllowed: Bool
    public let boundedProductionQueueMutationCommitPlanFollowupAllowed: Bool
    public let actualProductionQueueMutationAllowed: Bool
    public let liveExecutorEnqueueAllowed: Bool
    public let runtimeTaskSpawnAllowed: Bool
    public let handlerInvocationAllowed: Bool
    public let requestContextMutationAllowed: Bool
    public let responseWriteAllowed: Bool
    public let transportCommitAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
    public let productionQueueMutationCommitPlanMode: String
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
        h2ProductionQueueMutationCommitPlanAccepted: Bool,
        h2ProductionQueueMutationDryRunAccepted: Bool,
        productionQueueMutationCommitPlanAccepted: Bool,
        productionQueueMutationCommitPlanAllowed: Bool,
        boundedProductionQueueMutationCommitPlanFollowupAllowed: Bool,
        actualProductionQueueMutationAllowed: Bool,
        liveExecutorEnqueueAllowed: Bool,
        runtimeTaskSpawnAllowed: Bool,
        handlerInvocationAllowed: Bool,
        requestContextMutationAllowed: Bool,
        responseWriteAllowed: Bool,
        transportCommitAllowed: Bool,
        liveServerWiringAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
        productionQueueMutationCommitPlanMode: String,
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
        this.h2ProductionQueueMutationCommitPlanAccepted =
            h2ProductionQueueMutationCommitPlanAccepted
        this.h2ProductionQueueMutationDryRunAccepted =
            h2ProductionQueueMutationDryRunAccepted
        this.productionQueueMutationCommitPlanAccepted =
            productionQueueMutationCommitPlanAccepted
        this.productionQueueMutationCommitPlanAllowed =
            productionQueueMutationCommitPlanAllowed
        this.boundedProductionQueueMutationCommitPlanFollowupAllowed =
            boundedProductionQueueMutationCommitPlanFollowupAllowed
        this.actualProductionQueueMutationAllowed =
            actualProductionQueueMutationAllowed
        this.liveExecutorEnqueueAllowed = liveExecutorEnqueueAllowed
        this.runtimeTaskSpawnAllowed = runtimeTaskSpawnAllowed
        this.handlerInvocationAllowed = handlerInvocationAllowed
        this.requestContextMutationAllowed = requestContextMutationAllowed
        this.responseWriteAllowed = responseWriteAllowed
        this.transportCommitAllowed = transportCommitAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.productionQueueMutationCommitPlanMode =
            productionQueueMutationCommitPlanMode
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

public func buildJinguiAcceptedTransportH2ProductionQueueMutationCommitPlanBridge(
    evidence: JinguiAcceptedTransportH2ProductionQueueMutationCommitPlanEvidence
): JinguiAcceptedTransportH2ProductionQueueMutationCommitPlanBridge {
    let h2DryRunBridge = evidence.h2ProductionQueueMutationDryRunBridge
    let commitPlanReceipt = evidence.productionQueueMutationCommitPlanReceipt
    let nonClaims =
        jinguiAcceptedTransportH2ProductionQueueMutationCommitPlanNonClaims()
    if (
        !h2DryRunBridge.h2ProductionQueueMutationDryRunAccepted ||
        !h2DryRunBridge.boundedProductionQueueMutationDryRunFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2ProductionQueueMutationCommitPlanBridge(
            false,
            h2DryRunBridge.h2ProductionQueueMutationDryRunAccepted,
            commitPlanReceipt.productionQueueMutationCommitPlanAccepted,
            commitPlanReceipt.productionQueueMutationCommitPlanAllowed,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            commitPlanReceipt.productionQueueMutationCommitPlanMode,
            commitPlanReceipt.mutationCommitPlanId,
            h2DryRunBridge.mutationDryRunId,
            h2DryRunBridge.mutationGateId,
            h2DryRunBridge.commitBoundaryId,
            h2DryRunBridge.queueWriteId,
            h2DryRunBridge.queueDepthBefore,
            h2DryRunBridge.queueDepthAfter,
            "blocked-h2-production-queue-mutation-dry-run-bridge",
            "collect-accepted-h2-production-queue-mutation-dry-run-before-commit-plan",
            jinguiAcceptedTransportH2ProductionQueueMutationCommitPlanDryRunBlockers(
                h2DryRunBridge
            ),
            nonClaims,
            "repair H2 production queue mutation dry-run before commit-plan; do not treat generic commit-plan receipts as H2 runtime readiness",
            "QUIC must pass stream mutation dry-runs before stream mutation commit-plans"
        )
    }
    if (
        !commitPlanReceipt.productionQueueMutationCommitPlanAccepted ||
        !commitPlanReceipt.productionQueueMutationCommitPlanAllowed
    ) {
        return JinguiAcceptedTransportH2ProductionQueueMutationCommitPlanBridge(
            false,
            true,
            commitPlanReceipt.productionQueueMutationCommitPlanAccepted,
            commitPlanReceipt.productionQueueMutationCommitPlanAllowed,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            commitPlanReceipt.productionQueueMutationCommitPlanMode,
            commitPlanReceipt.mutationCommitPlanId,
            commitPlanReceipt.mutationDryRunId,
            commitPlanReceipt.mutationGateId,
            commitPlanReceipt.commitBoundaryId,
            commitPlanReceipt.queueWriteId,
            commitPlanReceipt.queueDepthBefore,
            commitPlanReceipt.queueDepthAfter,
            "blocked-production-queue-mutation-commit-plan-receipt",
            "collect-accepted-production-queue-mutation-commit-plan-before-h2-apply-gate",
            jinguiAcceptedTransportH2ProductionQueueMutationCommitPlanReceiptBlockers(
                commitPlanReceipt
            ),
            nonClaims,
            commitPlanReceipt.nextAction,
            "QUIC must not consume rejected production mutation commit-plans for stream mutation apply gates"
        )
    }

    JinguiAcceptedTransportH2ProductionQueueMutationCommitPlanBridge(
        true,
        true,
        true,
        commitPlanReceipt.productionQueueMutationCommitPlanAllowed,
        true,
        commitPlanReceipt.actualProductionQueueMutationAllowed,
        commitPlanReceipt.liveExecutorEnqueueAllowed,
        commitPlanReceipt.runtimeTaskSpawnAllowed,
        commitPlanReceipt.handlerInvocationAllowed,
        commitPlanReceipt.requestContextMutationAllowed,
        commitPlanReceipt.responseWriteAllowed,
        commitPlanReceipt.transportCommitAllowed,
        commitPlanReceipt.liveServerWiringAllowed,
        false,
        commitPlanReceipt.productionQueueMutationCommitPlanMode,
        commitPlanReceipt.mutationCommitPlanId,
        commitPlanReceipt.mutationDryRunId,
        commitPlanReceipt.mutationGateId,
        commitPlanReceipt.commitBoundaryId,
        commitPlanReceipt.queueWriteId,
        commitPlanReceipt.queueDepthBefore,
        commitPlanReceipt.queueDepthAfter,
        "accepted-h2-production-queue-mutation-commit-plan-bridge",
        "record-h2-production-queue-mutation-commit-plan-without-actual-mutation",
        [],
        nonClaims,
        "next packet may plan an H2 production queue mutation apply-gate; actual mutation, live executor enqueue, runtime task spawn, H2 closure, and release flip remain denied",
        "QUIC can reuse H2-style dry-run plus commit-plan separation before stream queue mutation apply gates"
    )
}

func jinguiAcceptedTransportH2ProductionQueueMutationCommitPlanDryRunBlockers(
    bridge: JinguiAcceptedTransportH2ProductionQueueMutationDryRunBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("H2_PRODUCTION_QUEUE_MUTATION_DRY_RUN:${bridge.status}")
    for (blocker in bridge.blockers) {
        blockers.add("H2_PRODUCTION_QUEUE_MUTATION_DRY_RUN_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2ProductionQueueMutationCommitPlanReceiptBlockers(
    receipt: IgniteProductionQueueMutationCommitPlanReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("PRODUCTION_QUEUE_MUTATION_COMMIT_PLAN:${receipt.status}")
    for (blocker in receipt.blockers) {
        blockers.add("PRODUCTION_QUEUE_MUTATION_COMMIT_PLAN_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2ProductionQueueMutationCommitPlanNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_ACTUAL_PRODUCTION_QUEUE_MUTATION",
        "NO_LIVE_EXECUTOR_ENQUEUE",
        "NO_RUNTIME_TASK_SPAWN",
        "NO_HANDLER_INVOCATION",
        "NO_REQUEST_CONTEXT_MUTATION",
        "NO_RESPONSE_WRITE",
        "NO_TRANSPORT_COMMIT",
        "NO_LIVE_SERVER_WIRING",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2ProductionQueueMutationApplyGateEvidence {
    public let h2ProductionQueueMutationCommitPlanBridge:
        JinguiAcceptedTransportH2ProductionQueueMutationCommitPlanBridge
    public let productionQueueMutationApplyGateReceipt:
        IgniteProductionQueueMutationApplyGateReceipt

    public init(
        h2ProductionQueueMutationCommitPlanBridge:
            JinguiAcceptedTransportH2ProductionQueueMutationCommitPlanBridge,
        productionQueueMutationApplyGateReceipt:
            IgniteProductionQueueMutationApplyGateReceipt
    ) {
        this.h2ProductionQueueMutationCommitPlanBridge =
            h2ProductionQueueMutationCommitPlanBridge
        this.productionQueueMutationApplyGateReceipt =
            productionQueueMutationApplyGateReceipt
    }
}

public class JinguiAcceptedTransportH2ProductionQueueMutationApplyGateBridge {
    public let h2ProductionQueueMutationApplyGateAccepted: Bool
    public let h2ProductionQueueMutationCommitPlanAccepted: Bool
    public let productionQueueMutationApplyGateAccepted: Bool
    public let productionQueueMutationApplyGateAllowed: Bool
    public let boundedProductionQueueMutationApplyGateFollowupAllowed: Bool
    public let actualProductionQueueMutationAllowed: Bool
    public let controlledProductionQueueMutationApplyAllowed: Bool
    public let liveExecutorEnqueueAllowed: Bool
    public let runtimeTaskSpawnAllowed: Bool
    public let handlerInvocationAllowed: Bool
    public let requestContextMutationAllowed: Bool
    public let responseWriteAllowed: Bool
    public let transportCommitAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
    public let productionQueueMutationApplyGateMode: String
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
        h2ProductionQueueMutationApplyGateAccepted: Bool,
        h2ProductionQueueMutationCommitPlanAccepted: Bool,
        productionQueueMutationApplyGateAccepted: Bool,
        productionQueueMutationApplyGateAllowed: Bool,
        boundedProductionQueueMutationApplyGateFollowupAllowed: Bool,
        actualProductionQueueMutationAllowed: Bool,
        controlledProductionQueueMutationApplyAllowed: Bool,
        liveExecutorEnqueueAllowed: Bool,
        runtimeTaskSpawnAllowed: Bool,
        handlerInvocationAllowed: Bool,
        requestContextMutationAllowed: Bool,
        responseWriteAllowed: Bool,
        transportCommitAllowed: Bool,
        liveServerWiringAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
        productionQueueMutationApplyGateMode: String,
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
        this.h2ProductionQueueMutationApplyGateAccepted =
            h2ProductionQueueMutationApplyGateAccepted
        this.h2ProductionQueueMutationCommitPlanAccepted =
            h2ProductionQueueMutationCommitPlanAccepted
        this.productionQueueMutationApplyGateAccepted =
            productionQueueMutationApplyGateAccepted
        this.productionQueueMutationApplyGateAllowed =
            productionQueueMutationApplyGateAllowed
        this.boundedProductionQueueMutationApplyGateFollowupAllowed =
            boundedProductionQueueMutationApplyGateFollowupAllowed
        this.actualProductionQueueMutationAllowed =
            actualProductionQueueMutationAllowed
        this.controlledProductionQueueMutationApplyAllowed =
            controlledProductionQueueMutationApplyAllowed
        this.liveExecutorEnqueueAllowed = liveExecutorEnqueueAllowed
        this.runtimeTaskSpawnAllowed = runtimeTaskSpawnAllowed
        this.handlerInvocationAllowed = handlerInvocationAllowed
        this.requestContextMutationAllowed = requestContextMutationAllowed
        this.responseWriteAllowed = responseWriteAllowed
        this.transportCommitAllowed = transportCommitAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
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
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2ProductionQueueMutationApplyGateBridge(
    evidence: JinguiAcceptedTransportH2ProductionQueueMutationApplyGateEvidence
): JinguiAcceptedTransportH2ProductionQueueMutationApplyGateBridge {
    let h2CommitPlanBridge = evidence.h2ProductionQueueMutationCommitPlanBridge
    let applyGateReceipt = evidence.productionQueueMutationApplyGateReceipt
    let nonClaims =
        jinguiAcceptedTransportH2ProductionQueueMutationApplyGateNonClaims()
    if (
        !h2CommitPlanBridge.h2ProductionQueueMutationCommitPlanAccepted ||
        !h2CommitPlanBridge.boundedProductionQueueMutationCommitPlanFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2ProductionQueueMutationApplyGateBridge(
            false,
            h2CommitPlanBridge.h2ProductionQueueMutationCommitPlanAccepted,
            applyGateReceipt.productionQueueMutationApplyGateAccepted,
            applyGateReceipt.productionQueueMutationApplyGateAllowed,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            applyGateReceipt.productionQueueMutationApplyGateMode,
            applyGateReceipt.mutationApplyGateId,
            h2CommitPlanBridge.mutationCommitPlanId,
            h2CommitPlanBridge.mutationDryRunId,
            h2CommitPlanBridge.mutationGateId,
            h2CommitPlanBridge.commitBoundaryId,
            h2CommitPlanBridge.queueWriteId,
            h2CommitPlanBridge.queueDepthBefore,
            h2CommitPlanBridge.queueDepthAfter,
            "blocked-h2-production-queue-mutation-commit-plan-bridge",
            "collect-accepted-h2-production-queue-mutation-commit-plan-before-apply-gate",
            jinguiAcceptedTransportH2ProductionQueueMutationApplyGateCommitPlanBlockers(
                h2CommitPlanBridge
            ),
            nonClaims,
            "repair H2 production queue mutation commit-plan before apply-gate; do not treat generic apply-gate receipts as H2 runtime readiness",
            "QUIC must pass stream mutation commit-plans before stream mutation apply gates"
        )
    }
    if (
        !applyGateReceipt.productionQueueMutationApplyGateAccepted ||
        !applyGateReceipt.productionQueueMutationApplyGateAllowed
    ) {
        return JinguiAcceptedTransportH2ProductionQueueMutationApplyGateBridge(
            false,
            true,
            applyGateReceipt.productionQueueMutationApplyGateAccepted,
            applyGateReceipt.productionQueueMutationApplyGateAllowed,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            applyGateReceipt.productionQueueMutationApplyGateMode,
            applyGateReceipt.mutationApplyGateId,
            applyGateReceipt.mutationCommitPlanId,
            applyGateReceipt.mutationDryRunId,
            applyGateReceipt.mutationGateId,
            applyGateReceipt.commitBoundaryId,
            applyGateReceipt.queueWriteId,
            applyGateReceipt.queueDepthBefore,
            applyGateReceipt.queueDepthAfter,
            "blocked-production-queue-mutation-apply-gate-receipt",
            "collect-accepted-production-queue-mutation-apply-gate-before-h2-controlled-apply",
            jinguiAcceptedTransportH2ProductionQueueMutationApplyGateReceiptBlockers(
                applyGateReceipt
            ),
            nonClaims,
            applyGateReceipt.nextAction,
            "QUIC must not consume rejected production mutation apply-gates for stream mutation controlled apply"
        )
    }

    JinguiAcceptedTransportH2ProductionQueueMutationApplyGateBridge(
        true,
        true,
        true,
        applyGateReceipt.productionQueueMutationApplyGateAllowed,
        true,
        applyGateReceipt.actualProductionQueueMutationAllowed,
        false,
        applyGateReceipt.liveExecutorEnqueueAllowed,
        applyGateReceipt.runtimeTaskSpawnAllowed,
        applyGateReceipt.handlerInvocationAllowed,
        applyGateReceipt.requestContextMutationAllowed,
        applyGateReceipt.responseWriteAllowed,
        applyGateReceipt.transportCommitAllowed,
        applyGateReceipt.liveServerWiringAllowed,
        false,
        applyGateReceipt.productionQueueMutationApplyGateMode,
        applyGateReceipt.mutationApplyGateId,
        applyGateReceipt.mutationCommitPlanId,
        applyGateReceipt.mutationDryRunId,
        applyGateReceipt.mutationGateId,
        applyGateReceipt.commitBoundaryId,
        applyGateReceipt.queueWriteId,
        applyGateReceipt.queueDepthBefore,
        applyGateReceipt.queueDepthAfter,
        "accepted-h2-production-queue-mutation-apply-gate-bridge",
        "record-h2-production-queue-mutation-apply-gate-without-controlled-apply",
        [],
        nonClaims,
        "next packet may plan an H2 controlled production queue mutation apply; actual mutation, live executor enqueue, runtime task spawn, H2 closure, and release flip remain denied",
        "QUIC can reuse H2-style commit-plan plus apply-gate separation before stream queue mutation controlled apply"
    )
}

func jinguiAcceptedTransportH2ProductionQueueMutationApplyGateCommitPlanBlockers(
    bridge: JinguiAcceptedTransportH2ProductionQueueMutationCommitPlanBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("H2_PRODUCTION_QUEUE_MUTATION_COMMIT_PLAN:${bridge.status}")
    for (blocker in bridge.blockers) {
        blockers.add(
            "H2_PRODUCTION_QUEUE_MUTATION_COMMIT_PLAN_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2ProductionQueueMutationApplyGateReceiptBlockers(
    receipt: IgniteProductionQueueMutationApplyGateReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("PRODUCTION_QUEUE_MUTATION_APPLY_GATE:${receipt.status}")
    for (blocker in receipt.blockers) {
        blockers.add("PRODUCTION_QUEUE_MUTATION_APPLY_GATE_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2ProductionQueueMutationApplyGateNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_ACTUAL_PRODUCTION_QUEUE_MUTATION",
        "NO_CONTROLLED_PRODUCTION_QUEUE_MUTATION_APPLY",
        "NO_LIVE_EXECUTOR_ENQUEUE",
        "NO_RUNTIME_TASK_SPAWN",
        "NO_HANDLER_INVOCATION",
        "NO_REQUEST_CONTEXT_MUTATION",
        "NO_RESPONSE_WRITE",
        "NO_TRANSPORT_COMMIT",
        "NO_LIVE_SERVER_WIRING",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2ControlledProductionQueueMutationApplyEvidence {
    public let h2ProductionQueueMutationApplyGateBridge:
        JinguiAcceptedTransportH2ProductionQueueMutationApplyGateBridge
    public let controlledProductionQueueMutationApplyReceipt:
        IgniteControlledProductionQueueMutationApplyReceipt

    public init(
        h2ProductionQueueMutationApplyGateBridge:
            JinguiAcceptedTransportH2ProductionQueueMutationApplyGateBridge,
        controlledProductionQueueMutationApplyReceipt:
            IgniteControlledProductionQueueMutationApplyReceipt
    ) {
        this.h2ProductionQueueMutationApplyGateBridge =
            h2ProductionQueueMutationApplyGateBridge
        this.controlledProductionQueueMutationApplyReceipt =
            controlledProductionQueueMutationApplyReceipt
    }
}

public class JinguiAcceptedTransportH2ControlledProductionQueueMutationApplyBridge {
    public let h2ControlledProductionQueueMutationApplyAccepted: Bool
    public let h2ProductionQueueMutationApplyGateAccepted: Bool
    public let controlledProductionQueueMutationApplyAccepted: Bool
    public let controlledProductionQueueMutationApplyAllowed: Bool
    public let boundedControlledProductionQueueMutationApplyFollowupAllowed:
        Bool
    public let liveExecutorEnqueueAllowed: Bool
    public let runtimeTaskSpawnAllowed: Bool
    public let handlerInvocationAllowed: Bool
    public let requestContextMutationAllowed: Bool
    public let responseWriteAllowed: Bool
    public let transportCommitAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
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
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2ControlledProductionQueueMutationApplyAccepted: Bool,
        h2ProductionQueueMutationApplyGateAccepted: Bool,
        controlledProductionQueueMutationApplyAccepted: Bool,
        controlledProductionQueueMutationApplyAllowed: Bool,
        boundedControlledProductionQueueMutationApplyFollowupAllowed: Bool,
        liveExecutorEnqueueAllowed: Bool,
        runtimeTaskSpawnAllowed: Bool,
        handlerInvocationAllowed: Bool,
        requestContextMutationAllowed: Bool,
        responseWriteAllowed: Bool,
        transportCommitAllowed: Bool,
        liveServerWiringAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
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
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2ControlledProductionQueueMutationApplyAccepted =
            h2ControlledProductionQueueMutationApplyAccepted
        this.h2ProductionQueueMutationApplyGateAccepted =
            h2ProductionQueueMutationApplyGateAccepted
        this.controlledProductionQueueMutationApplyAccepted =
            controlledProductionQueueMutationApplyAccepted
        this.controlledProductionQueueMutationApplyAllowed =
            controlledProductionQueueMutationApplyAllowed
        this.boundedControlledProductionQueueMutationApplyFollowupAllowed =
            boundedControlledProductionQueueMutationApplyFollowupAllowed
        this.liveExecutorEnqueueAllowed = liveExecutorEnqueueAllowed
        this.runtimeTaskSpawnAllowed = runtimeTaskSpawnAllowed
        this.handlerInvocationAllowed = handlerInvocationAllowed
        this.requestContextMutationAllowed = requestContextMutationAllowed
        this.responseWriteAllowed = responseWriteAllowed
        this.transportCommitAllowed = transportCommitAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
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
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2ControlledProductionQueueMutationApplyBridge(
    evidence: JinguiAcceptedTransportH2ControlledProductionQueueMutationApplyEvidence
): JinguiAcceptedTransportH2ControlledProductionQueueMutationApplyBridge {
    let h2ApplyGateBridge = evidence.h2ProductionQueueMutationApplyGateBridge
    let controlledApplyReceipt =
        evidence.controlledProductionQueueMutationApplyReceipt
    let nonClaims =
        jinguiAcceptedTransportH2ControlledProductionQueueMutationApplyNonClaims()
    if (
        !h2ApplyGateBridge.h2ProductionQueueMutationApplyGateAccepted ||
        !h2ApplyGateBridge.boundedProductionQueueMutationApplyGateFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2ControlledProductionQueueMutationApplyBridge(
            false,
            h2ApplyGateBridge.h2ProductionQueueMutationApplyGateAccepted,
            controlledApplyReceipt.controlledProductionQueueMutationApplyAccepted,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            controlledApplyReceipt.controlledProductionQueueMutationApplyMode,
            controlledApplyReceipt.controlledMutationApplyId,
            h2ApplyGateBridge.mutationApplyGateId,
            h2ApplyGateBridge.mutationCommitPlanId,
            h2ApplyGateBridge.mutationDryRunId,
            h2ApplyGateBridge.mutationGateId,
            h2ApplyGateBridge.commitBoundaryId,
            h2ApplyGateBridge.queueWriteId,
            h2ApplyGateBridge.queueDepthBefore,
            h2ApplyGateBridge.queueDepthAfter,
            "blocked-h2-production-queue-mutation-apply-gate-bridge",
            "collect-accepted-h2-production-queue-mutation-apply-gate-before-controlled-apply",
            jinguiAcceptedTransportH2ControlledProductionQueueMutationApplyGateBlockers(
                h2ApplyGateBridge
            ),
            nonClaims,
            "repair H2 production queue mutation apply-gate before controlled apply; do not treat generic controlled-apply receipts as H2 runtime readiness",
            "QUIC must pass stream mutation apply-gates before stream mutation controlled apply"
        )
    }
    if (
        !controlledApplyReceipt.controlledProductionQueueMutationApplyAccepted ||
        !controlledApplyReceipt.controlledProductionQueueMutationApplyAllowed
    ) {
        return JinguiAcceptedTransportH2ControlledProductionQueueMutationApplyBridge(
            false,
            true,
            controlledApplyReceipt.controlledProductionQueueMutationApplyAccepted,
            controlledApplyReceipt.controlledProductionQueueMutationApplyAllowed,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            controlledApplyReceipt.controlledProductionQueueMutationApplyMode,
            controlledApplyReceipt.controlledMutationApplyId,
            controlledApplyReceipt.mutationApplyGateId,
            controlledApplyReceipt.mutationCommitPlanId,
            controlledApplyReceipt.mutationDryRunId,
            controlledApplyReceipt.mutationGateId,
            controlledApplyReceipt.commitBoundaryId,
            controlledApplyReceipt.queueWriteId,
            controlledApplyReceipt.queueDepthBefore,
            controlledApplyReceipt.queueDepthAfter,
            "blocked-controlled-production-queue-mutation-apply-receipt",
            "collect-accepted-controlled-production-queue-mutation-apply-before-h2-executor-handoff",
            jinguiAcceptedTransportH2ControlledProductionQueueMutationApplyReceiptBlockers(
                controlledApplyReceipt
            ),
            nonClaims,
            controlledApplyReceipt.nextAction,
            "QUIC must not consume rejected controlled mutation apply receipts for stream executor handoff"
        )
    }

    JinguiAcceptedTransportH2ControlledProductionQueueMutationApplyBridge(
        true,
        true,
        true,
        controlledApplyReceipt.controlledProductionQueueMutationApplyAllowed,
        true,
        controlledApplyReceipt.liveExecutorEnqueueAllowed,
        controlledApplyReceipt.runtimeTaskSpawnAllowed,
        controlledApplyReceipt.handlerInvocationAllowed,
        controlledApplyReceipt.requestContextMutationAllowed,
        controlledApplyReceipt.responseWriteAllowed,
        controlledApplyReceipt.transportCommitAllowed,
        controlledApplyReceipt.liveServerWiringAllowed,
        false,
        controlledApplyReceipt.controlledProductionQueueMutationApplyMode,
        controlledApplyReceipt.controlledMutationApplyId,
        controlledApplyReceipt.mutationApplyGateId,
        controlledApplyReceipt.mutationCommitPlanId,
        controlledApplyReceipt.mutationDryRunId,
        controlledApplyReceipt.mutationGateId,
        controlledApplyReceipt.commitBoundaryId,
        controlledApplyReceipt.queueWriteId,
        controlledApplyReceipt.queueDepthBefore,
        controlledApplyReceipt.queueDepthAfter,
        "accepted-h2-controlled-production-queue-mutation-apply-bridge",
        "record-h2-controlled-production-queue-mutation-apply-without-executor-handoff",
        [],
        nonClaims,
        "next packet may plan an H2 executor handoff gate; live executor enqueue, runtime task spawn, H2 closure, and release flip remain denied",
        "QUIC can reuse H2-style apply-gate plus controlled-apply separation before stream executor handoff"
    )
}

func jinguiAcceptedTransportH2ControlledProductionQueueMutationApplyGateBlockers(
    bridge: JinguiAcceptedTransportH2ProductionQueueMutationApplyGateBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("H2_PRODUCTION_QUEUE_MUTATION_APPLY_GATE:${bridge.status}")
    for (blocker in bridge.blockers) {
        blockers.add("H2_PRODUCTION_QUEUE_MUTATION_APPLY_GATE_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2ControlledProductionQueueMutationApplyReceiptBlockers(
    receipt: IgniteControlledProductionQueueMutationApplyReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "CONTROLLED_PRODUCTION_QUEUE_MUTATION_APPLY:${receipt.status}"
    )
    for (blocker in receipt.blockers) {
        blockers.add(
            "CONTROLLED_PRODUCTION_QUEUE_MUTATION_APPLY_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2ControlledProductionQueueMutationApplyNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_EXECUTOR_HANDOFF",
        "NO_LIVE_EXECUTOR_ENQUEUE",
        "NO_RUNTIME_TASK_SPAWN",
        "NO_HANDLER_INVOCATION",
        "NO_REQUEST_CONTEXT_MUTATION",
        "NO_RESPONSE_WRITE",
        "NO_TRANSPORT_COMMIT",
        "NO_LIVE_SERVER_WIRING",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2ExecutorHandoffEvidence {
    public let h2ControlledProductionQueueMutationApplyBridge:
        JinguiAcceptedTransportH2ControlledProductionQueueMutationApplyBridge
    public let executorHandoffReceipt: IgniteExecutorHandoffReceipt

    public init(
        h2ControlledProductionQueueMutationApplyBridge:
            JinguiAcceptedTransportH2ControlledProductionQueueMutationApplyBridge,
        executorHandoffReceipt: IgniteExecutorHandoffReceipt
    ) {
        this.h2ControlledProductionQueueMutationApplyBridge =
            h2ControlledProductionQueueMutationApplyBridge
        this.executorHandoffReceipt = executorHandoffReceipt
    }
}

public class JinguiAcceptedTransportH2ExecutorHandoffBridge {
    public let h2ExecutorHandoffAccepted: Bool
    public let h2ControlledProductionQueueMutationApplyAccepted: Bool
    public let executorHandoffAccepted: Bool
    public let executorHandoffAllowed: Bool
    public let boundedExecutorHandoffFollowupAllowed: Bool
    public let liveExecutorEnqueueAllowed: Bool
    public let runtimeTaskSpawnAllowed: Bool
    public let handlerInvocationAllowed: Bool
    public let requestContextMutationAllowed: Bool
    public let responseWriteAllowed: Bool
    public let transportCommitAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
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
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2ExecutorHandoffAccepted: Bool,
        h2ControlledProductionQueueMutationApplyAccepted: Bool,
        executorHandoffAccepted: Bool,
        executorHandoffAllowed: Bool,
        boundedExecutorHandoffFollowupAllowed: Bool,
        liveExecutorEnqueueAllowed: Bool,
        runtimeTaskSpawnAllowed: Bool,
        handlerInvocationAllowed: Bool,
        requestContextMutationAllowed: Bool,
        responseWriteAllowed: Bool,
        transportCommitAllowed: Bool,
        liveServerWiringAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
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
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2ExecutorHandoffAccepted = h2ExecutorHandoffAccepted
        this.h2ControlledProductionQueueMutationApplyAccepted =
            h2ControlledProductionQueueMutationApplyAccepted
        this.executorHandoffAccepted = executorHandoffAccepted
        this.executorHandoffAllowed = executorHandoffAllowed
        this.boundedExecutorHandoffFollowupAllowed =
            boundedExecutorHandoffFollowupAllowed
        this.liveExecutorEnqueueAllowed = liveExecutorEnqueueAllowed
        this.runtimeTaskSpawnAllowed = runtimeTaskSpawnAllowed
        this.handlerInvocationAllowed = handlerInvocationAllowed
        this.requestContextMutationAllowed = requestContextMutationAllowed
        this.responseWriteAllowed = responseWriteAllowed
        this.transportCommitAllowed = transportCommitAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
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
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2ExecutorHandoffBridge(
    evidence: JinguiAcceptedTransportH2ExecutorHandoffEvidence
): JinguiAcceptedTransportH2ExecutorHandoffBridge {
    let h2ControlledApplyBridge =
        evidence.h2ControlledProductionQueueMutationApplyBridge
    let executorHandoffReceipt = evidence.executorHandoffReceipt
    let nonClaims = jinguiAcceptedTransportH2ExecutorHandoffNonClaims()
    if (
        !h2ControlledApplyBridge.h2ControlledProductionQueueMutationApplyAccepted ||
        !h2ControlledApplyBridge.boundedControlledProductionQueueMutationApplyFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2ExecutorHandoffBridge(
            false,
            h2ControlledApplyBridge.h2ControlledProductionQueueMutationApplyAccepted,
            executorHandoffReceipt.executorHandoffAccepted,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            executorHandoffReceipt.executorHandoffMode,
            executorHandoffReceipt.executorHandoffId,
            h2ControlledApplyBridge.controlledMutationApplyId,
            h2ControlledApplyBridge.mutationApplyGateId,
            h2ControlledApplyBridge.mutationCommitPlanId,
            h2ControlledApplyBridge.mutationDryRunId,
            h2ControlledApplyBridge.mutationGateId,
            h2ControlledApplyBridge.commitBoundaryId,
            h2ControlledApplyBridge.queueWriteId,
            h2ControlledApplyBridge.queueDepthBefore,
            h2ControlledApplyBridge.queueDepthAfter,
            "blocked-h2-controlled-production-queue-mutation-apply-bridge",
            "collect-accepted-h2-controlled-production-queue-mutation-apply-before-executor-handoff",
            jinguiAcceptedTransportH2ExecutorHandoffControlledApplyBlockers(
                h2ControlledApplyBridge
            ),
            nonClaims,
            "repair H2 controlled production queue mutation apply before executor handoff; do not treat generic executor handoff receipts as H2 runtime readiness",
            "QUIC must pass stream controlled mutation apply before stream executor handoff"
        )
    }
    if (
        !executorHandoffReceipt.executorHandoffAccepted ||
        !executorHandoffReceipt.executorHandoffAllowed
    ) {
        return JinguiAcceptedTransportH2ExecutorHandoffBridge(
            false,
            true,
            executorHandoffReceipt.executorHandoffAccepted,
            executorHandoffReceipt.executorHandoffAllowed,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            executorHandoffReceipt.executorHandoffMode,
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
            "blocked-executor-handoff-receipt",
            "collect-accepted-executor-handoff-before-live-enqueue-proof",
            jinguiAcceptedTransportH2ExecutorHandoffReceiptBlockers(
                executorHandoffReceipt
            ),
            nonClaims,
            executorHandoffReceipt.nextAction,
            "QUIC must not consume rejected executor handoff receipts for stream live enqueue proof"
        )
    }

    JinguiAcceptedTransportH2ExecutorHandoffBridge(
        true,
        true,
        true,
        executorHandoffReceipt.executorHandoffAllowed,
        true,
        executorHandoffReceipt.liveExecutorEnqueueAllowed,
        executorHandoffReceipt.runtimeTaskSpawnAllowed,
        executorHandoffReceipt.handlerInvocationAllowed,
        executorHandoffReceipt.requestContextMutationAllowed,
        executorHandoffReceipt.responseWriteAllowed,
        executorHandoffReceipt.transportCommitAllowed,
        executorHandoffReceipt.liveServerWiringAllowed,
        false,
        executorHandoffReceipt.executorHandoffMode,
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
        "accepted-h2-executor-handoff-bridge",
        "record-h2-executor-handoff-without-live-enqueue",
        [],
        nonClaims,
        "next packet may plan an H2 live executor enqueue proof gate; runtime task spawn, H2 closure, and release flip remain denied",
        "QUIC can reuse H2-style controlled-apply plus executor-handoff separation before stream live enqueue proof"
    )
}

func jinguiAcceptedTransportH2ExecutorHandoffControlledApplyBlockers(
    bridge: JinguiAcceptedTransportH2ControlledProductionQueueMutationApplyBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add(
        "H2_CONTROLLED_PRODUCTION_QUEUE_MUTATION_APPLY:${bridge.status}"
    )
    for (blocker in bridge.blockers) {
        blockers.add(
            "H2_CONTROLLED_PRODUCTION_QUEUE_MUTATION_APPLY_BLOCKER:${blocker}"
        )
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2ExecutorHandoffReceiptBlockers(
    receipt: IgniteExecutorHandoffReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("EXECUTOR_HANDOFF:${receipt.status}")
    for (blocker in receipt.blockers) {
        blockers.add("EXECUTOR_HANDOFF_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2ExecutorHandoffNonClaims(): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_LIVE_EXECUTOR_ENQUEUE",
        "NO_RUNTIME_TASK_SPAWN",
        "NO_HANDLER_INVOCATION",
        "NO_REQUEST_CONTEXT_MUTATION",
        "NO_RESPONSE_WRITE",
        "NO_TRANSPORT_COMMIT",
        "NO_LIVE_SERVER_WIRING",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2LiveExecutorEnqueueProofGateEvidence {
    public let h2ExecutorHandoffBridge:
        JinguiAcceptedTransportH2ExecutorHandoffBridge
    public let liveExecutorEnqueueProofGateReceipt:
        IgniteLiveExecutorEnqueueProofGateReceipt

    public init(
        h2ExecutorHandoffBridge: JinguiAcceptedTransportH2ExecutorHandoffBridge,
        liveExecutorEnqueueProofGateReceipt:
            IgniteLiveExecutorEnqueueProofGateReceipt
    ) {
        this.h2ExecutorHandoffBridge = h2ExecutorHandoffBridge
        this.liveExecutorEnqueueProofGateReceipt =
            liveExecutorEnqueueProofGateReceipt
    }
}

public class JinguiAcceptedTransportH2LiveExecutorEnqueueProofGateBridge {
    public let h2LiveExecutorEnqueueProofGateAccepted: Bool
    public let h2ExecutorHandoffAccepted: Bool
    public let liveExecutorEnqueueProofGateAccepted: Bool
    public let liveExecutorEnqueueProofGateAllowed: Bool
    public let boundedLiveExecutorEnqueueProofGateFollowupAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let runtimeTaskSpawnAllowed: Bool
    public let handlerInvocationAllowed: Bool
    public let requestContextMutationAllowed: Bool
    public let responseWriteAllowed: Bool
    public let transportCommitAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
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
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2LiveExecutorEnqueueProofGateAccepted: Bool,
        h2ExecutorHandoffAccepted: Bool,
        liveExecutorEnqueueProofGateAccepted: Bool,
        liveExecutorEnqueueProofGateAllowed: Bool,
        boundedLiveExecutorEnqueueProofGateFollowupAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        runtimeTaskSpawnAllowed: Bool,
        handlerInvocationAllowed: Bool,
        requestContextMutationAllowed: Bool,
        responseWriteAllowed: Bool,
        transportCommitAllowed: Bool,
        liveServerWiringAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
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
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2LiveExecutorEnqueueProofGateAccepted =
            h2LiveExecutorEnqueueProofGateAccepted
        this.h2ExecutorHandoffAccepted = h2ExecutorHandoffAccepted
        this.liveExecutorEnqueueProofGateAccepted =
            liveExecutorEnqueueProofGateAccepted
        this.liveExecutorEnqueueProofGateAllowed =
            liveExecutorEnqueueProofGateAllowed
        this.boundedLiveExecutorEnqueueProofGateFollowupAllowed =
            boundedLiveExecutorEnqueueProofGateFollowupAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.runtimeTaskSpawnAllowed = runtimeTaskSpawnAllowed
        this.handlerInvocationAllowed = handlerInvocationAllowed
        this.requestContextMutationAllowed = requestContextMutationAllowed
        this.responseWriteAllowed = responseWriteAllowed
        this.transportCommitAllowed = transportCommitAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.liveExecutorEnqueueProofGateMode =
            liveExecutorEnqueueProofGateMode
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

public func buildJinguiAcceptedTransportH2LiveExecutorEnqueueProofGateBridge(
    evidence: JinguiAcceptedTransportH2LiveExecutorEnqueueProofGateEvidence
): JinguiAcceptedTransportH2LiveExecutorEnqueueProofGateBridge {
    let h2ExecutorHandoffBridge = evidence.h2ExecutorHandoffBridge
    let liveEnqueueProofGateReceipt =
        evidence.liveExecutorEnqueueProofGateReceipt
    let nonClaims =
        jinguiAcceptedTransportH2LiveExecutorEnqueueProofGateNonClaims()
    if (
        !h2ExecutorHandoffBridge.h2ExecutorHandoffAccepted ||
        !h2ExecutorHandoffBridge.boundedExecutorHandoffFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2LiveExecutorEnqueueProofGateBridge(
            false,
            h2ExecutorHandoffBridge.h2ExecutorHandoffAccepted,
            liveEnqueueProofGateReceipt.liveExecutorEnqueueProofGateAccepted,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            liveEnqueueProofGateReceipt.liveExecutorEnqueueProofGateMode,
            liveEnqueueProofGateReceipt.liveEnqueueProofId,
            h2ExecutorHandoffBridge.executorHandoffId,
            h2ExecutorHandoffBridge.controlledMutationApplyId,
            h2ExecutorHandoffBridge.mutationApplyGateId,
            h2ExecutorHandoffBridge.mutationCommitPlanId,
            h2ExecutorHandoffBridge.mutationDryRunId,
            h2ExecutorHandoffBridge.mutationGateId,
            h2ExecutorHandoffBridge.commitBoundaryId,
            h2ExecutorHandoffBridge.queueWriteId,
            h2ExecutorHandoffBridge.queueDepthBefore,
            h2ExecutorHandoffBridge.queueDepthAfter,
            "blocked-h2-executor-handoff-bridge",
            "collect-accepted-h2-executor-handoff-before-live-enqueue-proof-gate",
            jinguiAcceptedTransportH2LiveExecutorEnqueueProofGateHandoffBlockers(
                h2ExecutorHandoffBridge
            ),
            nonClaims,
            "repair H2 executor handoff before live enqueue proof gate; do not treat generic live enqueue proof receipts as H2 runtime readiness",
            "QUIC must pass stream executor handoff before stream live enqueue proof gate"
        )
    }
    if (
        !liveEnqueueProofGateReceipt.liveExecutorEnqueueProofGateAccepted ||
        !liveEnqueueProofGateReceipt.liveExecutorEnqueueProofGateAllowed
    ) {
        return JinguiAcceptedTransportH2LiveExecutorEnqueueProofGateBridge(
            false,
            true,
            liveEnqueueProofGateReceipt.liveExecutorEnqueueProofGateAccepted,
            liveEnqueueProofGateReceipt.liveExecutorEnqueueProofGateAllowed,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            liveEnqueueProofGateReceipt.liveExecutorEnqueueProofGateMode,
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
            "blocked-live-executor-enqueue-proof-gate-receipt",
            "collect-accepted-live-executor-enqueue-proof-gate-before-runtime-task-spawn-gate",
            jinguiAcceptedTransportH2LiveExecutorEnqueueProofGateReceiptBlockers(
                liveEnqueueProofGateReceipt
            ),
            nonClaims,
            liveEnqueueProofGateReceipt.nextAction,
            "QUIC must not consume rejected live enqueue proof gate receipts for stream runtime spawn"
        )
    }

    JinguiAcceptedTransportH2LiveExecutorEnqueueProofGateBridge(
        true,
        true,
        true,
        liveEnqueueProofGateReceipt.liveExecutorEnqueueProofGateAllowed,
        true,
        liveEnqueueProofGateReceipt.productionQueueMutationAllowed,
        liveEnqueueProofGateReceipt.runtimeTaskSpawnAllowed,
        liveEnqueueProofGateReceipt.handlerInvocationAllowed,
        liveEnqueueProofGateReceipt.requestContextMutationAllowed,
        liveEnqueueProofGateReceipt.responseWriteAllowed,
        liveEnqueueProofGateReceipt.transportCommitAllowed,
        liveEnqueueProofGateReceipt.liveServerWiringAllowed,
        false,
        liveEnqueueProofGateReceipt.liveExecutorEnqueueProofGateMode,
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
        "accepted-h2-live-executor-enqueue-proof-gate-bridge",
        "record-h2-live-enqueue-proof-gate-without-runtime-task-spawn",
        [],
        nonClaims,
        "next packet may plan an H2 runtime task spawn gate; handler invocation, H2 closure, and release flip remain denied",
        "QUIC can reuse H2-style executor-handoff plus live-enqueue-proof separation before stream runtime spawn gate"
    )
}

func jinguiAcceptedTransportH2LiveExecutorEnqueueProofGateHandoffBlockers(
    bridge: JinguiAcceptedTransportH2ExecutorHandoffBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("H2_EXECUTOR_HANDOFF:${bridge.status}")
    for (blocker in bridge.blockers) {
        blockers.add("H2_EXECUTOR_HANDOFF_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2LiveExecutorEnqueueProofGateReceiptBlockers(
    receipt: IgniteLiveExecutorEnqueueProofGateReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("LIVE_EXECUTOR_ENQUEUE_PROOF_GATE:${receipt.status}")
    for (blocker in receipt.blockers) {
        blockers.add("LIVE_EXECUTOR_ENQUEUE_PROOF_GATE_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2LiveExecutorEnqueueProofGateNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_PRODUCTION_QUEUE_MUTATION",
        "NO_RUNTIME_TASK_SPAWN",
        "NO_HANDLER_INVOCATION",
        "NO_REQUEST_CONTEXT_MUTATION",
        "NO_RESPONSE_WRITE",
        "NO_TRANSPORT_COMMIT",
        "NO_LIVE_SERVER_WIRING",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2RuntimeTaskSpawnGateEvidence {
    public let h2LiveExecutorEnqueueProofGateBridge:
        JinguiAcceptedTransportH2LiveExecutorEnqueueProofGateBridge
    public let runtimeTaskSpawnGateReceipt:
        IgniteRuntimeTaskSpawnGateReceipt

    public init(
        h2LiveExecutorEnqueueProofGateBridge:
            JinguiAcceptedTransportH2LiveExecutorEnqueueProofGateBridge,
        runtimeTaskSpawnGateReceipt: IgniteRuntimeTaskSpawnGateReceipt
    ) {
        this.h2LiveExecutorEnqueueProofGateBridge =
            h2LiveExecutorEnqueueProofGateBridge
        this.runtimeTaskSpawnGateReceipt = runtimeTaskSpawnGateReceipt
    }
}

public class JinguiAcceptedTransportH2RuntimeTaskSpawnGateBridge {
    public let h2RuntimeTaskSpawnGateAccepted: Bool
    public let h2LiveExecutorEnqueueProofGateAccepted: Bool
    public let runtimeTaskSpawnGateAccepted: Bool
    public let runtimeTaskSpawnGateAllowed: Bool
    public let boundedRuntimeTaskSpawnGateFollowupAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let handlerInvocationAllowed: Bool
    public let requestContextMutationAllowed: Bool
    public let responseWriteAllowed: Bool
    public let transportCommitAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
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
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2RuntimeTaskSpawnGateAccepted: Bool,
        h2LiveExecutorEnqueueProofGateAccepted: Bool,
        runtimeTaskSpawnGateAccepted: Bool,
        runtimeTaskSpawnGateAllowed: Bool,
        boundedRuntimeTaskSpawnGateFollowupAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        handlerInvocationAllowed: Bool,
        requestContextMutationAllowed: Bool,
        responseWriteAllowed: Bool,
        transportCommitAllowed: Bool,
        liveServerWiringAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
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
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2RuntimeTaskSpawnGateAccepted = h2RuntimeTaskSpawnGateAccepted
        this.h2LiveExecutorEnqueueProofGateAccepted =
            h2LiveExecutorEnqueueProofGateAccepted
        this.runtimeTaskSpawnGateAccepted = runtimeTaskSpawnGateAccepted
        this.runtimeTaskSpawnGateAllowed = runtimeTaskSpawnGateAllowed
        this.boundedRuntimeTaskSpawnGateFollowupAllowed =
            boundedRuntimeTaskSpawnGateFollowupAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.actualRuntimeTaskSpawnAllowed = actualRuntimeTaskSpawnAllowed
        this.handlerInvocationAllowed = handlerInvocationAllowed
        this.requestContextMutationAllowed = requestContextMutationAllowed
        this.responseWriteAllowed = responseWriteAllowed
        this.transportCommitAllowed = transportCommitAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
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
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2RuntimeTaskSpawnGateBridge(
    evidence: JinguiAcceptedTransportH2RuntimeTaskSpawnGateEvidence
): JinguiAcceptedTransportH2RuntimeTaskSpawnGateBridge {
    let h2LiveEnqueueBridge = evidence.h2LiveExecutorEnqueueProofGateBridge
    let runtimeTaskSpawnGateReceipt = evidence.runtimeTaskSpawnGateReceipt
    let nonClaims = jinguiAcceptedTransportH2RuntimeTaskSpawnGateNonClaims()
    if (
        !h2LiveEnqueueBridge.h2LiveExecutorEnqueueProofGateAccepted ||
        !h2LiveEnqueueBridge.boundedLiveExecutorEnqueueProofGateFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeTaskSpawnGateBridge(
            false,
            h2LiveEnqueueBridge.h2LiveExecutorEnqueueProofGateAccepted,
            runtimeTaskSpawnGateReceipt.runtimeTaskSpawnGateAccepted,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            runtimeTaskSpawnGateReceipt.runtimeTaskSpawnGateMode,
            runtimeTaskSpawnGateReceipt.runtimeSpawnGateId,
            h2LiveEnqueueBridge.liveEnqueueProofId,
            h2LiveEnqueueBridge.executorHandoffId,
            h2LiveEnqueueBridge.controlledMutationApplyId,
            h2LiveEnqueueBridge.mutationApplyGateId,
            h2LiveEnqueueBridge.mutationCommitPlanId,
            h2LiveEnqueueBridge.mutationDryRunId,
            h2LiveEnqueueBridge.mutationGateId,
            h2LiveEnqueueBridge.commitBoundaryId,
            h2LiveEnqueueBridge.queueWriteId,
            h2LiveEnqueueBridge.queueDepthBefore,
            h2LiveEnqueueBridge.queueDepthAfter,
            "blocked-h2-live-executor-enqueue-proof-gate-bridge",
            "collect-accepted-h2-live-enqueue-proof-gate-before-runtime-task-spawn-gate",
            jinguiAcceptedTransportH2RuntimeTaskSpawnGateLiveEnqueueBlockers(
                h2LiveEnqueueBridge
            ),
            nonClaims,
            "repair H2 live enqueue proof gate before runtime task spawn gate; do not treat generic runtime spawn gate receipts as H2 runtime readiness",
            "QUIC must pass stream live enqueue proof gate before stream runtime task spawn gate"
        )
    }
    if (
        !runtimeTaskSpawnGateReceipt.runtimeTaskSpawnGateAccepted ||
        !runtimeTaskSpawnGateReceipt.runtimeTaskSpawnGateAllowed
    ) {
        return JinguiAcceptedTransportH2RuntimeTaskSpawnGateBridge(
            false,
            true,
            runtimeTaskSpawnGateReceipt.runtimeTaskSpawnGateAccepted,
            runtimeTaskSpawnGateReceipt.runtimeTaskSpawnGateAllowed,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            runtimeTaskSpawnGateReceipt.runtimeTaskSpawnGateMode,
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
            "blocked-runtime-task-spawn-gate-receipt",
            "collect-accepted-runtime-task-spawn-gate-before-handler-invocation-gate",
            jinguiAcceptedTransportH2RuntimeTaskSpawnGateReceiptBlockers(
                runtimeTaskSpawnGateReceipt
            ),
            nonClaims,
            runtimeTaskSpawnGateReceipt.nextAction,
            "QUIC must not consume rejected runtime task spawn gate receipts for stream handler invocation"
        )
    }

    JinguiAcceptedTransportH2RuntimeTaskSpawnGateBridge(
        true,
        true,
        true,
        runtimeTaskSpawnGateReceipt.runtimeTaskSpawnGateAllowed,
        true,
        runtimeTaskSpawnGateReceipt.productionQueueMutationAllowed,
        runtimeTaskSpawnGateReceipt.actualRuntimeTaskSpawnAllowed,
        runtimeTaskSpawnGateReceipt.handlerInvocationAllowed,
        runtimeTaskSpawnGateReceipt.requestContextMutationAllowed,
        runtimeTaskSpawnGateReceipt.responseWriteAllowed,
        runtimeTaskSpawnGateReceipt.transportCommitAllowed,
        runtimeTaskSpawnGateReceipt.liveServerWiringAllowed,
        false,
        runtimeTaskSpawnGateReceipt.runtimeTaskSpawnGateMode,
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
        "accepted-h2-runtime-task-spawn-gate-bridge",
        "record-h2-runtime-task-spawn-gate-without-actual-task-spawn",
        [],
        nonClaims,
        "next packet may plan an H2 handler invocation gate; actual spawn, response write, H2 closure, and release flip remain denied",
        "QUIC can reuse H2-style live-enqueue-proof plus runtime-spawn-gate separation before stream handler invocation gate"
    )
}

func jinguiAcceptedTransportH2RuntimeTaskSpawnGateLiveEnqueueBlockers(
    bridge: JinguiAcceptedTransportH2LiveExecutorEnqueueProofGateBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("H2_LIVE_EXECUTOR_ENQUEUE_PROOF_GATE:${bridge.status}")
    for (blocker in bridge.blockers) {
        blockers.add("H2_LIVE_EXECUTOR_ENQUEUE_PROOF_GATE_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeTaskSpawnGateReceiptBlockers(
    receipt: IgniteRuntimeTaskSpawnGateReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("RUNTIME_TASK_SPAWN_GATE:${receipt.status}")
    for (blocker in receipt.blockers) {
        blockers.add("RUNTIME_TASK_SPAWN_GATE_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RuntimeTaskSpawnGateNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_ACTUAL_RUNTIME_TASK_SPAWN",
        "NO_HANDLER_INVOCATION",
        "NO_REQUEST_CONTEXT_MUTATION",
        "NO_RESPONSE_WRITE",
        "NO_TRANSPORT_COMMIT",
        "NO_LIVE_SERVER_WIRING",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2HandlerInvocationGateEvidence {
    public let h2RuntimeTaskSpawnGateBridge:
        JinguiAcceptedTransportH2RuntimeTaskSpawnGateBridge
    public let handlerInvocationGateReceipt:
        IgniteHandlerInvocationGateReceipt

    public init(
        h2RuntimeTaskSpawnGateBridge:
            JinguiAcceptedTransportH2RuntimeTaskSpawnGateBridge,
        handlerInvocationGateReceipt: IgniteHandlerInvocationGateReceipt
    ) {
        this.h2RuntimeTaskSpawnGateBridge = h2RuntimeTaskSpawnGateBridge
        this.handlerInvocationGateReceipt = handlerInvocationGateReceipt
    }
}

public class JinguiAcceptedTransportH2HandlerInvocationGateBridge {
    public let h2HandlerInvocationGateAccepted: Bool
    public let h2RuntimeTaskSpawnGateAccepted: Bool
    public let handlerInvocationGateAccepted: Bool
    public let handlerInvocationGateAllowed: Bool
    public let boundedHandlerInvocationGateFollowupAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let actualHandlerInvocationAllowed: Bool
    public let requestContextMutationAllowed: Bool
    public let responseWriteAllowed: Bool
    public let transportCommitAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
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
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2HandlerInvocationGateAccepted: Bool,
        h2RuntimeTaskSpawnGateAccepted: Bool,
        handlerInvocationGateAccepted: Bool,
        handlerInvocationGateAllowed: Bool,
        boundedHandlerInvocationGateFollowupAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        actualHandlerInvocationAllowed: Bool,
        requestContextMutationAllowed: Bool,
        responseWriteAllowed: Bool,
        transportCommitAllowed: Bool,
        liveServerWiringAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
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
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2HandlerInvocationGateAccepted =
            h2HandlerInvocationGateAccepted
        this.h2RuntimeTaskSpawnGateAccepted =
            h2RuntimeTaskSpawnGateAccepted
        this.handlerInvocationGateAccepted = handlerInvocationGateAccepted
        this.handlerInvocationGateAllowed = handlerInvocationGateAllowed
        this.boundedHandlerInvocationGateFollowupAllowed =
            boundedHandlerInvocationGateFollowupAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.actualRuntimeTaskSpawnAllowed = actualRuntimeTaskSpawnAllowed
        this.actualHandlerInvocationAllowed = actualHandlerInvocationAllowed
        this.requestContextMutationAllowed = requestContextMutationAllowed
        this.responseWriteAllowed = responseWriteAllowed
        this.transportCommitAllowed = transportCommitAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
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
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2HandlerInvocationGateBridge(
    evidence: JinguiAcceptedTransportH2HandlerInvocationGateEvidence
): JinguiAcceptedTransportH2HandlerInvocationGateBridge {
    let h2RuntimeSpawnBridge = evidence.h2RuntimeTaskSpawnGateBridge
    let handlerInvocationGateReceipt =
        evidence.handlerInvocationGateReceipt
    let nonClaims =
        jinguiAcceptedTransportH2HandlerInvocationGateNonClaims()
    if (
        !h2RuntimeSpawnBridge.h2RuntimeTaskSpawnGateAccepted ||
        !h2RuntimeSpawnBridge.boundedRuntimeTaskSpawnGateFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2HandlerInvocationGateBridge(
            false,
            h2RuntimeSpawnBridge.h2RuntimeTaskSpawnGateAccepted,
            handlerInvocationGateReceipt.handlerInvocationGateAccepted,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            handlerInvocationGateReceipt.handlerInvocationGateMode,
            handlerInvocationGateReceipt.handlerInvocationGateId,
            h2RuntimeSpawnBridge.runtimeSpawnGateId,
            h2RuntimeSpawnBridge.liveEnqueueProofId,
            h2RuntimeSpawnBridge.executorHandoffId,
            h2RuntimeSpawnBridge.controlledMutationApplyId,
            h2RuntimeSpawnBridge.mutationApplyGateId,
            h2RuntimeSpawnBridge.mutationCommitPlanId,
            h2RuntimeSpawnBridge.mutationDryRunId,
            h2RuntimeSpawnBridge.mutationGateId,
            h2RuntimeSpawnBridge.commitBoundaryId,
            h2RuntimeSpawnBridge.queueWriteId,
            h2RuntimeSpawnBridge.queueDepthBefore,
            h2RuntimeSpawnBridge.queueDepthAfter,
            "blocked-h2-runtime-task-spawn-gate-bridge",
            "collect-accepted-h2-runtime-task-spawn-gate-before-handler-invocation-gate",
            jinguiAcceptedTransportH2HandlerInvocationGateRuntimeBlockers(
                h2RuntimeSpawnBridge
            ),
            nonClaims,
            "repair H2 runtime task spawn gate before handler invocation gate; do not treat generic handler invocation receipts as H2 runtime readiness",
            "QUIC must pass stream runtime task spawn gate before stream handler invocation gate"
        )
    }
    if (
        !handlerInvocationGateReceipt.handlerInvocationGateAccepted ||
        !handlerInvocationGateReceipt.handlerInvocationGateAllowed
    ) {
        return JinguiAcceptedTransportH2HandlerInvocationGateBridge(
            false,
            true,
            handlerInvocationGateReceipt.handlerInvocationGateAccepted,
            handlerInvocationGateReceipt.handlerInvocationGateAllowed,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            handlerInvocationGateReceipt.handlerInvocationGateMode,
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
            "blocked-handler-invocation-gate-receipt",
            "collect-accepted-handler-invocation-gate-before-request-context-mutation-gate",
            jinguiAcceptedTransportH2HandlerInvocationGateReceiptBlockers(
                handlerInvocationGateReceipt
            ),
            nonClaims,
            handlerInvocationGateReceipt.nextAction,
            "QUIC must not consume rejected handler invocation gate receipts for stream context mutation"
        )
    }

    JinguiAcceptedTransportH2HandlerInvocationGateBridge(
        true,
        true,
        true,
        handlerInvocationGateReceipt.handlerInvocationGateAllowed,
        true,
        handlerInvocationGateReceipt.productionQueueMutationAllowed,
        handlerInvocationGateReceipt.actualRuntimeTaskSpawnAllowed,
        handlerInvocationGateReceipt.actualHandlerInvocationAllowed,
        handlerInvocationGateReceipt.requestContextMutationAllowed,
        handlerInvocationGateReceipt.responseWriteAllowed,
        handlerInvocationGateReceipt.transportCommitAllowed,
        handlerInvocationGateReceipt.liveServerWiringAllowed,
        false,
        handlerInvocationGateReceipt.handlerInvocationGateMode,
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
        "accepted-h2-handler-invocation-gate-bridge",
        "record-h2-handler-invocation-gate-without-actual-handler-call",
        [],
        nonClaims,
        "next packet may plan an H2 request context mutation gate; actual handler invocation, response write, H2 closure, and release flip remain denied",
        "QUIC can reuse H2-style runtime-spawn-gate plus handler-invocation-gate separation before stream context mutation gate"
    )
}

func jinguiAcceptedTransportH2HandlerInvocationGateRuntimeBlockers(
    bridge: JinguiAcceptedTransportH2RuntimeTaskSpawnGateBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("H2_RUNTIME_TASK_SPAWN_GATE:${bridge.status}")
    for (blocker in bridge.blockers) {
        blockers.add("H2_RUNTIME_TASK_SPAWN_GATE_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2HandlerInvocationGateReceiptBlockers(
    receipt: IgniteHandlerInvocationGateReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("HANDLER_INVOCATION_GATE:${receipt.status}")
    for (blocker in receipt.blockers) {
        blockers.add("HANDLER_INVOCATION_GATE_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2HandlerInvocationGateNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_ACTUAL_RUNTIME_TASK_SPAWN",
        "NO_ACTUAL_HANDLER_INVOCATION",
        "NO_REQUEST_CONTEXT_MUTATION",
        "NO_RESPONSE_WRITE",
        "NO_TRANSPORT_COMMIT",
        "NO_LIVE_SERVER_WIRING",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2RequestContextMutationGateEvidence {
    public let h2HandlerInvocationGateBridge:
        JinguiAcceptedTransportH2HandlerInvocationGateBridge
    public let requestContextMutationGateReceipt:
        IgniteRequestContextMutationGateReceipt

    public init(
        h2HandlerInvocationGateBridge:
            JinguiAcceptedTransportH2HandlerInvocationGateBridge,
        requestContextMutationGateReceipt:
            IgniteRequestContextMutationGateReceipt
    ) {
        this.h2HandlerInvocationGateBridge = h2HandlerInvocationGateBridge
        this.requestContextMutationGateReceipt =
            requestContextMutationGateReceipt
    }
}

public class JinguiAcceptedTransportH2RequestContextMutationGateBridge {
    public let h2RequestContextMutationGateAccepted: Bool
    public let h2HandlerInvocationGateAccepted: Bool
    public let requestContextMutationGateAccepted: Bool
    public let requestContextMutationGateAllowed: Bool
    public let boundedRequestContextMutationGateFollowupAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let actualHandlerInvocationAllowed: Bool
    public let actualRequestContextMutationAllowed: Bool
    public let responseWriteAllowed: Bool
    public let transportCommitAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
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
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2RequestContextMutationGateAccepted: Bool,
        h2HandlerInvocationGateAccepted: Bool,
        requestContextMutationGateAccepted: Bool,
        requestContextMutationGateAllowed: Bool,
        boundedRequestContextMutationGateFollowupAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        actualHandlerInvocationAllowed: Bool,
        actualRequestContextMutationAllowed: Bool,
        responseWriteAllowed: Bool,
        transportCommitAllowed: Bool,
        liveServerWiringAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
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
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2RequestContextMutationGateAccepted =
            h2RequestContextMutationGateAccepted
        this.h2HandlerInvocationGateAccepted =
            h2HandlerInvocationGateAccepted
        this.requestContextMutationGateAccepted =
            requestContextMutationGateAccepted
        this.requestContextMutationGateAllowed =
            requestContextMutationGateAllowed
        this.boundedRequestContextMutationGateFollowupAllowed =
            boundedRequestContextMutationGateFollowupAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.actualRuntimeTaskSpawnAllowed = actualRuntimeTaskSpawnAllowed
        this.actualHandlerInvocationAllowed = actualHandlerInvocationAllowed
        this.actualRequestContextMutationAllowed =
            actualRequestContextMutationAllowed
        this.responseWriteAllowed = responseWriteAllowed
        this.transportCommitAllowed = transportCommitAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.handlerInvocationGateMode = handlerInvocationGateMode
        this.requestContextMutationGateMode =
            requestContextMutationGateMode
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

public func buildJinguiAcceptedTransportH2RequestContextMutationGateBridge(
    evidence: JinguiAcceptedTransportH2RequestContextMutationGateEvidence
): JinguiAcceptedTransportH2RequestContextMutationGateBridge {
    let h2HandlerBridge = evidence.h2HandlerInvocationGateBridge
    let requestContextMutationGateReceipt =
        evidence.requestContextMutationGateReceipt
    let nonClaims =
        jinguiAcceptedTransportH2RequestContextMutationGateNonClaims()
    if (
        !h2HandlerBridge.h2HandlerInvocationGateAccepted ||
        !h2HandlerBridge.boundedHandlerInvocationGateFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2RequestContextMutationGateBridge(
            false,
            h2HandlerBridge.h2HandlerInvocationGateAccepted,
            requestContextMutationGateReceipt.requestContextMutationGateAccepted,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            requestContextMutationGateReceipt.handlerInvocationGateMode,
            requestContextMutationGateReceipt.requestContextMutationGateMode,
            requestContextMutationGateReceipt.requestContextMutationGateId,
            h2HandlerBridge.handlerInvocationGateId,
            h2HandlerBridge.runtimeSpawnGateId,
            h2HandlerBridge.liveEnqueueProofId,
            h2HandlerBridge.executorHandoffId,
            h2HandlerBridge.controlledMutationApplyId,
            h2HandlerBridge.mutationApplyGateId,
            h2HandlerBridge.mutationCommitPlanId,
            h2HandlerBridge.mutationDryRunId,
            h2HandlerBridge.mutationGateId,
            h2HandlerBridge.commitBoundaryId,
            h2HandlerBridge.queueWriteId,
            h2HandlerBridge.queueDepthBefore,
            h2HandlerBridge.queueDepthAfter,
            "blocked-h2-handler-invocation-gate-bridge",
            "collect-accepted-h2-handler-invocation-gate-before-request-context-mutation-gate",
            jinguiAcceptedTransportH2RequestContextMutationGateHandlerBlockers(
                h2HandlerBridge
            ),
            nonClaims,
            "repair H2 handler invocation gate before request context mutation gate; do not treat generic request context mutation receipts as H2 runtime readiness",
            "QUIC must pass stream handler invocation gate before stream context mutation gate"
        )
    }
    if (
        !requestContextMutationGateReceipt.requestContextMutationGateAccepted ||
        !requestContextMutationGateReceipt.requestContextMutationGateAllowed
    ) {
        return JinguiAcceptedTransportH2RequestContextMutationGateBridge(
            false,
            true,
            requestContextMutationGateReceipt.requestContextMutationGateAccepted,
            requestContextMutationGateReceipt.requestContextMutationGateAllowed,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            requestContextMutationGateReceipt.handlerInvocationGateMode,
            requestContextMutationGateReceipt.requestContextMutationGateMode,
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
            "blocked-request-context-mutation-gate-receipt",
            "collect-accepted-request-context-mutation-gate-before-response-write-gate",
            jinguiAcceptedTransportH2RequestContextMutationGateReceiptBlockers(
                requestContextMutationGateReceipt
            ),
            nonClaims,
            requestContextMutationGateReceipt.nextAction,
            "QUIC must not consume rejected request context mutation gate receipts for stream response write"
        )
    }

    JinguiAcceptedTransportH2RequestContextMutationGateBridge(
        true,
        true,
        true,
        requestContextMutationGateReceipt.requestContextMutationGateAllowed,
        true,
        requestContextMutationGateReceipt.productionQueueMutationAllowed,
        requestContextMutationGateReceipt.actualRuntimeTaskSpawnAllowed,
        requestContextMutationGateReceipt.actualHandlerInvocationAllowed,
        requestContextMutationGateReceipt.actualRequestContextMutationAllowed,
        requestContextMutationGateReceipt.responseWriteAllowed,
        requestContextMutationGateReceipt.transportCommitAllowed,
        requestContextMutationGateReceipt.liveServerWiringAllowed,
        false,
        requestContextMutationGateReceipt.handlerInvocationGateMode,
        requestContextMutationGateReceipt.requestContextMutationGateMode,
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
        "accepted-h2-request-context-mutation-gate-bridge",
        "record-h2-request-context-mutation-gate-without-actual-ctx-mutation",
        [],
        nonClaims,
        "next packet may plan an H2 response write gate; actual context mutation, transport commit, H2 closure, and release flip remain denied",
        "QUIC can reuse H2-style handler-invocation-gate plus request-context-mutation-gate separation before stream response write gate"
    )
}

func jinguiAcceptedTransportH2RequestContextMutationGateHandlerBlockers(
    bridge: JinguiAcceptedTransportH2HandlerInvocationGateBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("H2_HANDLER_INVOCATION_GATE:${bridge.status}")
    for (blocker in bridge.blockers) {
        blockers.add("H2_HANDLER_INVOCATION_GATE_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RequestContextMutationGateReceiptBlockers(
    receipt: IgniteRequestContextMutationGateReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("REQUEST_CONTEXT_MUTATION_GATE:${receipt.status}")
    for (blocker in receipt.blockers) {
        blockers.add("REQUEST_CONTEXT_MUTATION_GATE_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2RequestContextMutationGateNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_ACTUAL_RUNTIME_TASK_SPAWN",
        "NO_ACTUAL_HANDLER_INVOCATION",
        "NO_ACTUAL_REQUEST_CONTEXT_MUTATION",
        "NO_RESPONSE_WRITE",
        "NO_TRANSPORT_COMMIT",
        "NO_LIVE_SERVER_WIRING",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2ResponseWriteGateEvidence {
    public let h2RequestContextMutationGateBridge:
        JinguiAcceptedTransportH2RequestContextMutationGateBridge
    public let responseWriteGateReceipt: IgniteResponseWriteGateReceipt

    public init(
        h2RequestContextMutationGateBridge:
            JinguiAcceptedTransportH2RequestContextMutationGateBridge,
        responseWriteGateReceipt: IgniteResponseWriteGateReceipt
    ) {
        this.h2RequestContextMutationGateBridge =
            h2RequestContextMutationGateBridge
        this.responseWriteGateReceipt = responseWriteGateReceipt
    }
}

public class JinguiAcceptedTransportH2ResponseWriteGateBridge {
    public let h2ResponseWriteGateAccepted: Bool
    public let h2RequestContextMutationGateAccepted: Bool
    public let responseWriteGateAccepted: Bool
    public let responseWriteGateAllowed: Bool
    public let boundedResponseWriteGateFollowupAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let actualHandlerInvocationAllowed: Bool
    public let actualRequestContextMutationAllowed: Bool
    public let actualResponseWriteAllowed: Bool
    public let transportCommitAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
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
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2ResponseWriteGateAccepted: Bool,
        h2RequestContextMutationGateAccepted: Bool,
        responseWriteGateAccepted: Bool,
        responseWriteGateAllowed: Bool,
        boundedResponseWriteGateFollowupAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        actualHandlerInvocationAllowed: Bool,
        actualRequestContextMutationAllowed: Bool,
        actualResponseWriteAllowed: Bool,
        transportCommitAllowed: Bool,
        liveServerWiringAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
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
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2ResponseWriteGateAccepted = h2ResponseWriteGateAccepted
        this.h2RequestContextMutationGateAccepted =
            h2RequestContextMutationGateAccepted
        this.responseWriteGateAccepted = responseWriteGateAccepted
        this.responseWriteGateAllowed = responseWriteGateAllowed
        this.boundedResponseWriteGateFollowupAllowed =
            boundedResponseWriteGateFollowupAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.actualRuntimeTaskSpawnAllowed = actualRuntimeTaskSpawnAllowed
        this.actualHandlerInvocationAllowed = actualHandlerInvocationAllowed
        this.actualRequestContextMutationAllowed =
            actualRequestContextMutationAllowed
        this.actualResponseWriteAllowed = actualResponseWriteAllowed
        this.transportCommitAllowed = transportCommitAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
        this.requestContextMutationGateMode =
            requestContextMutationGateMode
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
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2ResponseWriteGateBridge(
    evidence: JinguiAcceptedTransportH2ResponseWriteGateEvidence
): JinguiAcceptedTransportH2ResponseWriteGateBridge {
    let h2ContextBridge = evidence.h2RequestContextMutationGateBridge
    let responseWriteGateReceipt = evidence.responseWriteGateReceipt
    let nonClaims = jinguiAcceptedTransportH2ResponseWriteGateNonClaims()
    if (
        !h2ContextBridge.h2RequestContextMutationGateAccepted ||
        !h2ContextBridge.boundedRequestContextMutationGateFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2ResponseWriteGateBridge(
            false,
            h2ContextBridge.h2RequestContextMutationGateAccepted,
            responseWriteGateReceipt.responseWriteGateAccepted,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            responseWriteGateReceipt.requestContextMutationGateMode,
            responseWriteGateReceipt.responseWriteGateMode,
            responseWriteGateReceipt.responseWriteGateId,
            h2ContextBridge.requestContextMutationGateId,
            h2ContextBridge.handlerInvocationGateId,
            h2ContextBridge.runtimeSpawnGateId,
            h2ContextBridge.liveEnqueueProofId,
            h2ContextBridge.executorHandoffId,
            h2ContextBridge.controlledMutationApplyId,
            h2ContextBridge.mutationApplyGateId,
            h2ContextBridge.mutationCommitPlanId,
            h2ContextBridge.mutationDryRunId,
            h2ContextBridge.mutationGateId,
            h2ContextBridge.commitBoundaryId,
            h2ContextBridge.queueWriteId,
            h2ContextBridge.queueDepthBefore,
            h2ContextBridge.queueDepthAfter,
            "blocked-h2-request-context-mutation-gate-bridge",
            "collect-accepted-h2-request-context-mutation-gate-before-response-write-gate",
            jinguiAcceptedTransportH2ResponseWriteGateContextBlockers(
                h2ContextBridge
            ),
            nonClaims,
            "repair H2 request context mutation gate before response write gate; do not treat generic response write receipts as H2 runtime readiness",
            "QUIC must pass stream context mutation gate before stream response write gate"
        )
    }
    if (
        !responseWriteGateReceipt.responseWriteGateAccepted ||
        !responseWriteGateReceipt.responseWriteGateAllowed
    ) {
        return JinguiAcceptedTransportH2ResponseWriteGateBridge(
            false,
            true,
            responseWriteGateReceipt.responseWriteGateAccepted,
            responseWriteGateReceipt.responseWriteGateAllowed,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            responseWriteGateReceipt.requestContextMutationGateMode,
            responseWriteGateReceipt.responseWriteGateMode,
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
            "blocked-response-write-gate-receipt",
            "collect-accepted-response-write-gate-before-transport-commit-gate",
            jinguiAcceptedTransportH2ResponseWriteGateReceiptBlockers(
                responseWriteGateReceipt
            ),
            nonClaims,
            responseWriteGateReceipt.nextAction,
            "QUIC must not consume rejected response write gate receipts for stream transport commit"
        )
    }

    JinguiAcceptedTransportH2ResponseWriteGateBridge(
        true,
        true,
        true,
        responseWriteGateReceipt.responseWriteGateAllowed,
        true,
        responseWriteGateReceipt.productionQueueMutationAllowed,
        responseWriteGateReceipt.actualRuntimeTaskSpawnAllowed,
        responseWriteGateReceipt.actualHandlerInvocationAllowed,
        responseWriteGateReceipt.actualRequestContextMutationAllowed,
        responseWriteGateReceipt.actualResponseWriteAllowed,
        responseWriteGateReceipt.transportCommitAllowed,
        responseWriteGateReceipt.liveServerWiringAllowed,
        false,
        responseWriteGateReceipt.requestContextMutationGateMode,
        responseWriteGateReceipt.responseWriteGateMode,
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
        "accepted-h2-response-write-gate-bridge",
        "record-h2-response-write-gate-without-actual-response-write",
        [],
        nonClaims,
        "next packet may plan an H2 transport commit gate; actual response write, H2 closure, and release flip remain denied",
        "QUIC can reuse H2-style context-mutation-gate plus response-write-gate separation before stream transport commit gate"
    )
}

func jinguiAcceptedTransportH2ResponseWriteGateContextBlockers(
    bridge: JinguiAcceptedTransportH2RequestContextMutationGateBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("H2_REQUEST_CONTEXT_MUTATION_GATE:${bridge.status}")
    for (blocker in bridge.blockers) {
        blockers.add("H2_REQUEST_CONTEXT_MUTATION_GATE_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2ResponseWriteGateReceiptBlockers(
    receipt: IgniteResponseWriteGateReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("RESPONSE_WRITE_GATE:${receipt.status}")
    for (blocker in receipt.blockers) {
        blockers.add("RESPONSE_WRITE_GATE_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2ResponseWriteGateNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_ACTUAL_RUNTIME_TASK_SPAWN",
        "NO_ACTUAL_HANDLER_INVOCATION",
        "NO_ACTUAL_REQUEST_CONTEXT_MUTATION",
        "NO_ACTUAL_RESPONSE_WRITE",
        "NO_TRANSPORT_COMMIT",
        "NO_LIVE_SERVER_WIRING",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2TransportCommitGateEvidence {
    public let h2ResponseWriteGateBridge:
        JinguiAcceptedTransportH2ResponseWriteGateBridge
    public let transportCommitGateReceipt: IgniteTransportCommitGateReceipt

    public init(
        h2ResponseWriteGateBridge:
            JinguiAcceptedTransportH2ResponseWriteGateBridge,
        transportCommitGateReceipt: IgniteTransportCommitGateReceipt
    ) {
        this.h2ResponseWriteGateBridge = h2ResponseWriteGateBridge
        this.transportCommitGateReceipt = transportCommitGateReceipt
    }
}

public class JinguiAcceptedTransportH2TransportCommitGateBridge {
    public let h2TransportCommitGateAccepted: Bool
    public let h2ResponseWriteGateAccepted: Bool
    public let transportCommitGateAccepted: Bool
    public let transportCommitGateAllowed: Bool
    public let boundedTransportCommitGateFollowupAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let actualHandlerInvocationAllowed: Bool
    public let actualRequestContextMutationAllowed: Bool
    public let actualResponseWriteAllowed: Bool
    public let actualTransportCommitAllowed: Bool
    public let liveServerWiringAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
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
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2TransportCommitGateAccepted: Bool,
        h2ResponseWriteGateAccepted: Bool,
        transportCommitGateAccepted: Bool,
        transportCommitGateAllowed: Bool,
        boundedTransportCommitGateFollowupAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        actualHandlerInvocationAllowed: Bool,
        actualRequestContextMutationAllowed: Bool,
        actualResponseWriteAllowed: Bool,
        actualTransportCommitAllowed: Bool,
        liveServerWiringAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
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
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2TransportCommitGateAccepted = h2TransportCommitGateAccepted
        this.h2ResponseWriteGateAccepted = h2ResponseWriteGateAccepted
        this.transportCommitGateAccepted = transportCommitGateAccepted
        this.transportCommitGateAllowed = transportCommitGateAllowed
        this.boundedTransportCommitGateFollowupAllowed =
            boundedTransportCommitGateFollowupAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.actualRuntimeTaskSpawnAllowed = actualRuntimeTaskSpawnAllowed
        this.actualHandlerInvocationAllowed = actualHandlerInvocationAllowed
        this.actualRequestContextMutationAllowed =
            actualRequestContextMutationAllowed
        this.actualResponseWriteAllowed = actualResponseWriteAllowed
        this.actualTransportCommitAllowed = actualTransportCommitAllowed
        this.liveServerWiringAllowed = liveServerWiringAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
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
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2TransportCommitGateBridge(
    evidence: JinguiAcceptedTransportH2TransportCommitGateEvidence
): JinguiAcceptedTransportH2TransportCommitGateBridge {
    let h2ResponseWriteBridge = evidence.h2ResponseWriteGateBridge
    let transportCommitGateReceipt = evidence.transportCommitGateReceipt
    let nonClaims = jinguiAcceptedTransportH2TransportCommitGateNonClaims()
    if (
        !h2ResponseWriteBridge.h2ResponseWriteGateAccepted ||
        !h2ResponseWriteBridge.boundedResponseWriteGateFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2TransportCommitGateBridge(
            false,
            h2ResponseWriteBridge.h2ResponseWriteGateAccepted,
            transportCommitGateReceipt.transportCommitGateAccepted,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            transportCommitGateReceipt.responseWriteGateMode,
            transportCommitGateReceipt.transportCommitGateMode,
            transportCommitGateReceipt.transportCommitGateId,
            h2ResponseWriteBridge.responseWriteGateId,
            h2ResponseWriteBridge.requestContextMutationGateId,
            h2ResponseWriteBridge.handlerInvocationGateId,
            h2ResponseWriteBridge.runtimeSpawnGateId,
            h2ResponseWriteBridge.liveEnqueueProofId,
            h2ResponseWriteBridge.executorHandoffId,
            h2ResponseWriteBridge.controlledMutationApplyId,
            h2ResponseWriteBridge.mutationApplyGateId,
            h2ResponseWriteBridge.mutationCommitPlanId,
            h2ResponseWriteBridge.mutationDryRunId,
            h2ResponseWriteBridge.mutationGateId,
            h2ResponseWriteBridge.commitBoundaryId,
            h2ResponseWriteBridge.queueWriteId,
            h2ResponseWriteBridge.queueDepthBefore,
            h2ResponseWriteBridge.queueDepthAfter,
            "blocked-h2-response-write-gate-bridge",
            "collect-accepted-h2-response-write-gate-before-transport-commit-gate",
            jinguiAcceptedTransportH2TransportCommitGateResponseBlockers(
                h2ResponseWriteBridge
            ),
            nonClaims,
            "repair H2 response write gate before transport commit gate; do not treat generic transport commit receipts as H2 runtime readiness",
            "QUIC must pass stream response write gate before stream transport commit gate"
        )
    }
    if (
        !transportCommitGateReceipt.transportCommitGateAccepted ||
        !transportCommitGateReceipt.transportCommitGateAllowed
    ) {
        return JinguiAcceptedTransportH2TransportCommitGateBridge(
            false,
            true,
            transportCommitGateReceipt.transportCommitGateAccepted,
            transportCommitGateReceipt.transportCommitGateAllowed,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            transportCommitGateReceipt.responseWriteGateMode,
            transportCommitGateReceipt.transportCommitGateMode,
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
            "blocked-transport-commit-gate-receipt",
            "collect-accepted-transport-commit-gate-before-live-server-wiring-gate",
            jinguiAcceptedTransportH2TransportCommitGateReceiptBlockers(
                transportCommitGateReceipt
            ),
            nonClaims,
            transportCommitGateReceipt.nextAction,
            "QUIC must not consume rejected transport commit gate receipts for live stream wiring"
        )
    }

    JinguiAcceptedTransportH2TransportCommitGateBridge(
        true,
        true,
        true,
        transportCommitGateReceipt.transportCommitGateAllowed,
        true,
        transportCommitGateReceipt.productionQueueMutationAllowed,
        transportCommitGateReceipt.actualRuntimeTaskSpawnAllowed,
        transportCommitGateReceipt.actualHandlerInvocationAllowed,
        transportCommitGateReceipt.actualRequestContextMutationAllowed,
        transportCommitGateReceipt.actualResponseWriteAllowed,
        transportCommitGateReceipt.actualTransportCommitAllowed,
        transportCommitGateReceipt.liveServerWiringAllowed,
        false,
        transportCommitGateReceipt.responseWriteGateMode,
        transportCommitGateReceipt.transportCommitGateMode,
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
        "accepted-h2-transport-commit-gate-bridge",
        "record-h2-transport-commit-gate-without-actual-transport-commit",
        [],
        nonClaims,
        "next packet may plan an H2 live server wiring gate; actual transport commit, H2 closure, and release flip remain denied",
        "QUIC can reuse H2-style response-write-gate plus transport-commit-gate separation before live stream wiring gate"
    )
}

func jinguiAcceptedTransportH2TransportCommitGateResponseBlockers(
    bridge: JinguiAcceptedTransportH2ResponseWriteGateBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("H2_RESPONSE_WRITE_GATE:${bridge.status}")
    for (blocker in bridge.blockers) {
        blockers.add("H2_RESPONSE_WRITE_GATE_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2TransportCommitGateReceiptBlockers(
    receipt: IgniteTransportCommitGateReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("TRANSPORT_COMMIT_GATE:${receipt.status}")
    for (blocker in receipt.blockers) {
        blockers.add("TRANSPORT_COMMIT_GATE_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2TransportCommitGateNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_ACTUAL_RUNTIME_TASK_SPAWN",
        "NO_ACTUAL_HANDLER_INVOCATION",
        "NO_ACTUAL_REQUEST_CONTEXT_MUTATION",
        "NO_ACTUAL_RESPONSE_WRITE",
        "NO_ACTUAL_TRANSPORT_COMMIT",
        "NO_LIVE_SERVER_WIRING",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}

public class JinguiAcceptedTransportH2LiveServerWiringGateEvidence {
    public let h2TransportCommitGateBridge:
        JinguiAcceptedTransportH2TransportCommitGateBridge
    public let liveServerWiringGateReceipt: IgniteLiveServerWiringGateReceipt

    public init(
        h2TransportCommitGateBridge:
            JinguiAcceptedTransportH2TransportCommitGateBridge,
        liveServerWiringGateReceipt: IgniteLiveServerWiringGateReceipt
    ) {
        this.h2TransportCommitGateBridge = h2TransportCommitGateBridge
        this.liveServerWiringGateReceipt = liveServerWiringGateReceipt
    }
}

public class JinguiAcceptedTransportH2LiveServerWiringGateBridge {
    public let h2LiveServerWiringGateAccepted: Bool
    public let h2TransportCommitGateAccepted: Bool
    public let liveServerWiringGateAccepted: Bool
    public let liveServerWiringGateAllowed: Bool
    public let boundedLiveServerWiringGateFollowupAllowed: Bool
    public let productionQueueMutationAllowed: Bool
    public let actualRuntimeTaskSpawnAllowed: Bool
    public let actualHandlerInvocationAllowed: Bool
    public let actualRequestContextMutationAllowed: Bool
    public let actualResponseWriteAllowed: Bool
    public let actualTransportCommitAllowed: Bool
    public let actualLiveServerWiringAllowed: Bool
    public let defaultEngineFlipAllowed: Bool
    public let h2RuntimeClosureClaimAllowed: Bool
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
    public let status: String
    public let decision: String
    public let blockers: Array<String>
    public let nonClaims: Array<String>
    public let nextAction: String
    public let quicReuseHook: String

    public init(
        h2LiveServerWiringGateAccepted: Bool,
        h2TransportCommitGateAccepted: Bool,
        liveServerWiringGateAccepted: Bool,
        liveServerWiringGateAllowed: Bool,
        boundedLiveServerWiringGateFollowupAllowed: Bool,
        productionQueueMutationAllowed: Bool,
        actualRuntimeTaskSpawnAllowed: Bool,
        actualHandlerInvocationAllowed: Bool,
        actualRequestContextMutationAllowed: Bool,
        actualResponseWriteAllowed: Bool,
        actualTransportCommitAllowed: Bool,
        actualLiveServerWiringAllowed: Bool,
        defaultEngineFlipAllowed: Bool,
        h2RuntimeClosureClaimAllowed: Bool,
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
        status: String,
        decision: String,
        blockers: Array<String>,
        nonClaims: Array<String>,
        nextAction: String,
        quicReuseHook: String
    ) {
        this.h2LiveServerWiringGateAccepted = h2LiveServerWiringGateAccepted
        this.h2TransportCommitGateAccepted = h2TransportCommitGateAccepted
        this.liveServerWiringGateAccepted = liveServerWiringGateAccepted
        this.liveServerWiringGateAllowed = liveServerWiringGateAllowed
        this.boundedLiveServerWiringGateFollowupAllowed =
            boundedLiveServerWiringGateFollowupAllowed
        this.productionQueueMutationAllowed = productionQueueMutationAllowed
        this.actualRuntimeTaskSpawnAllowed = actualRuntimeTaskSpawnAllowed
        this.actualHandlerInvocationAllowed = actualHandlerInvocationAllowed
        this.actualRequestContextMutationAllowed =
            actualRequestContextMutationAllowed
        this.actualResponseWriteAllowed = actualResponseWriteAllowed
        this.actualTransportCommitAllowed = actualTransportCommitAllowed
        this.actualLiveServerWiringAllowed = actualLiveServerWiringAllowed
        this.defaultEngineFlipAllowed = defaultEngineFlipAllowed
        this.h2RuntimeClosureClaimAllowed = h2RuntimeClosureClaimAllowed
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
        this.status = status
        this.decision = decision
        this.blockers = blockers.clone()
        this.nonClaims = nonClaims.clone()
        this.nextAction = nextAction
        this.quicReuseHook = quicReuseHook
    }
}

public func buildJinguiAcceptedTransportH2LiveServerWiringGateBridge(
    evidence: JinguiAcceptedTransportH2LiveServerWiringGateEvidence
): JinguiAcceptedTransportH2LiveServerWiringGateBridge {
    let h2TransportCommitBridge = evidence.h2TransportCommitGateBridge
    let liveServerWiringGateReceipt = evidence.liveServerWiringGateReceipt
    let nonClaims = jinguiAcceptedTransportH2LiveServerWiringGateNonClaims()
    if (
        !h2TransportCommitBridge.h2TransportCommitGateAccepted ||
        !h2TransportCommitBridge.boundedTransportCommitGateFollowupAllowed
    ) {
        return JinguiAcceptedTransportH2LiveServerWiringGateBridge(
            false,
            h2TransportCommitBridge.h2TransportCommitGateAccepted,
            liveServerWiringGateReceipt.liveServerWiringGateAccepted,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            liveServerWiringGateReceipt.transportCommitGateMode,
            liveServerWiringGateReceipt.liveServerWiringGateMode,
            liveServerWiringGateReceipt.liveServerWiringGateId,
            h2TransportCommitBridge.transportCommitGateId,
            h2TransportCommitBridge.responseWriteGateId,
            h2TransportCommitBridge.requestContextMutationGateId,
            h2TransportCommitBridge.handlerInvocationGateId,
            h2TransportCommitBridge.runtimeSpawnGateId,
            h2TransportCommitBridge.liveEnqueueProofId,
            h2TransportCommitBridge.executorHandoffId,
            h2TransportCommitBridge.controlledMutationApplyId,
            h2TransportCommitBridge.mutationApplyGateId,
            h2TransportCommitBridge.mutationCommitPlanId,
            h2TransportCommitBridge.mutationDryRunId,
            h2TransportCommitBridge.mutationGateId,
            h2TransportCommitBridge.commitBoundaryId,
            h2TransportCommitBridge.queueWriteId,
            h2TransportCommitBridge.queueDepthBefore,
            h2TransportCommitBridge.queueDepthAfter,
            "blocked-h2-transport-commit-gate-bridge",
            "collect-accepted-h2-transport-commit-gate-before-live-server-wiring-gate",
            jinguiAcceptedTransportH2LiveServerWiringGateTransportBlockers(
                h2TransportCommitBridge
            ),
            nonClaims,
            "repair H2 transport commit gate before live server wiring gate; do not treat generic live wiring receipts as H2 runtime readiness",
            "QUIC must pass stream transport commit gate before live stream wiring gate"
        )
    }
    if (
        !liveServerWiringGateReceipt.liveServerWiringGateAccepted ||
        !liveServerWiringGateReceipt.liveServerWiringGateAllowed
    ) {
        return JinguiAcceptedTransportH2LiveServerWiringGateBridge(
            false,
            true,
            liveServerWiringGateReceipt.liveServerWiringGateAccepted,
            liveServerWiringGateReceipt.liveServerWiringGateAllowed,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            liveServerWiringGateReceipt.transportCommitGateMode,
            liveServerWiringGateReceipt.liveServerWiringGateMode,
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
            "blocked-live-server-wiring-gate-receipt",
            "collect-accepted-live-server-wiring-gate-before-default-engine-readiness-gate",
            jinguiAcceptedTransportH2LiveServerWiringGateReceiptBlockers(
                liveServerWiringGateReceipt
            ),
            nonClaims,
            liveServerWiringGateReceipt.nextAction,
            "QUIC must not consume rejected live server wiring gate receipts for default stream runtime flip"
        )
    }

    JinguiAcceptedTransportH2LiveServerWiringGateBridge(
        true,
        true,
        true,
        liveServerWiringGateReceipt.liveServerWiringGateAllowed,
        true,
        liveServerWiringGateReceipt.productionQueueMutationAllowed,
        liveServerWiringGateReceipt.actualRuntimeTaskSpawnAllowed,
        liveServerWiringGateReceipt.actualHandlerInvocationAllowed,
        liveServerWiringGateReceipt.actualRequestContextMutationAllowed,
        liveServerWiringGateReceipt.actualResponseWriteAllowed,
        liveServerWiringGateReceipt.actualTransportCommitAllowed,
        liveServerWiringGateReceipt.actualLiveServerWiringAllowed,
        liveServerWiringGateReceipt.defaultEngineFlipAllowed,
        false,
        liveServerWiringGateReceipt.transportCommitGateMode,
        liveServerWiringGateReceipt.liveServerWiringGateMode,
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
        "accepted-h2-live-server-wiring-gate-bridge",
        "record-h2-live-server-wiring-gate-without-actual-live-wiring",
        [],
        nonClaims,
        "next packet may plan H2 default-engine readiness; actual live wiring, H2 closure, and release flip remain denied",
        "QUIC can reuse H2-style transport-commit-gate plus live-wiring-gate separation before runtime default flip"
    )
}

func jinguiAcceptedTransportH2LiveServerWiringGateTransportBlockers(
    bridge: JinguiAcceptedTransportH2TransportCommitGateBridge
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("H2_TRANSPORT_COMMIT_GATE:${bridge.status}")
    for (blocker in bridge.blockers) {
        blockers.add("H2_TRANSPORT_COMMIT_GATE_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2LiveServerWiringGateReceiptBlockers(
    receipt: IgniteLiveServerWiringGateReceipt
): Array<String> {
    var blockers = ArrayList<String>()
    blockers.add("LIVE_SERVER_WIRING_GATE:${receipt.status}")
    for (blocker in receipt.blockers) {
        blockers.add("LIVE_SERVER_WIRING_GATE_BLOCKER:${blocker}")
    }
    blockers.toArray()
}

func jinguiAcceptedTransportH2LiveServerWiringGateNonClaims(
): Array<String> {
    [
        "NO_H2_RUNTIME_CLOSURE_CLAIM",
        "NO_ACTUAL_RUNTIME_TASK_SPAWN",
        "NO_ACTUAL_HANDLER_INVOCATION",
        "NO_ACTUAL_REQUEST_CONTEXT_MUTATION",
        "NO_ACTUAL_RESPONSE_WRITE",
        "NO_ACTUAL_TRANSPORT_COMMIT",
        "NO_ACTUAL_LIVE_SERVER_WIRING",
        "NO_DEFAULT_ENGINE_FLIP",
        "NO_BROWSER_OR_H2SPEC_CLAIM",
        "NO_PERFORMANCE_CLAIM",
        "NO_RELEASE_DEFAULT_FLIP",
    ]
}
