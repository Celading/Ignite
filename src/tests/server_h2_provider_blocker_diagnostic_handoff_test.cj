package ignite.tests

import ignite.*

@Test
public class ServerH2ProviderBlockerDiagnosticHandoffTestSuite {
    @TestCase
    public func testCarriedProviderBlockerAllowsDiagnosticHandoffOnly(): Unit {
        let handoff = buildJinguiAcceptedTransportH2DiagnosticOnlyHandoff(
            JinguiAcceptedTransportH2DiagnosticOnlyHandoffEvidence(
                buildHq0437LaunchGateFromCurrentProviderBlocker(true),
                "JinguiSSL-contract",
                "TLS13_TRANSCRIPT_HASH_SIZE",
                true,
                "h2-provider-blocker-diagnostic"
            )
        )

        @Assert(handoff.status, "ready-for-h2-diagnostic-only-handoff")
        @Assert(
            handoff.decision,
            "run-diagnostic-only-with-explicit-provider-stop-condition"
        )
        @Assert(handoff.diagnosticHandoffAllowed, true)
        @Assert(handoff.h2RuntimeProofLaunchAllowed, false)
        @Assert(handoff.h2RuntimeClosureClaimAllowed, false)
        @Assert(handoff.providerOwner, "JinguiSSL-contract")
        @Assert(handoff.providerFailureCode, "TLS13_TRANSCRIPT_HASH_SIZE")
        @Assert(handoff.nonClaims[2], "NO_H2_RUNTIME_LAUNCH_CLAIM")
    }

    @TestCase
    public func testUncarriedProviderBlockerCannotEnterDiagnosticHandoff(): Unit {
        let handoff = buildJinguiAcceptedTransportH2DiagnosticOnlyHandoff(
            JinguiAcceptedTransportH2DiagnosticOnlyHandoffEvidence(
                buildHq0437LaunchGateFromCurrentProviderBlocker(false),
                "JinguiSSL-contract",
                "TLS13_TRANSCRIPT_HASH_SIZE",
                false,
                "h2-provider-blocker-diagnostic"
            )
        )

        @Assert(handoff.status, "blocked-before-diagnostic-handoff")
        @Assert(
            handoff.decision,
            "carry-provider-blocker-before-diagnostic-handoff"
        )
        @Assert(handoff.diagnosticHandoffAllowed, false)
        @Assert(handoff.h2RuntimeProofLaunchAllowed, false)
        @Assert(handoff.blockers[0], "LAUNCH_GATE:blocked-provider-attach-gate")
    }

    @TestCase
    public func testMissingStopConditionBlocksDiagnosticHandoff(): Unit {
        let handoff = buildJinguiAcceptedTransportH2DiagnosticOnlyHandoff(
            JinguiAcceptedTransportH2DiagnosticOnlyHandoffEvidence(
                buildHq0437LaunchGateFromCurrentProviderBlocker(true),
                "JinguiSSL-contract",
                "",
                false,
                "h2-provider-blocker-diagnostic"
            )
        )

        @Assert(handoff.status, "blocked-diagnostic-stop-condition-missing")
        @Assert(
            handoff.decision,
            "attach-provider-owner-failure-code-and-stop-condition"
        )
        @Assert(handoff.diagnosticHandoffAllowed, false)
        @Assert(handoff.blockers[0], "MISSING:EXPLICIT_PROVIDER_STOP_CONDITION")
        @Assert(handoff.blockers[1], "MISSING:PROVIDER_FAILURE_CODE")
    }

    @TestCase
    public func testProviderReadyRuntimeLaunchIsNotDiagnosticHandoff(): Unit {
        let handoff = buildJinguiAcceptedTransportH2DiagnosticOnlyHandoff(
            JinguiAcceptedTransportH2DiagnosticOnlyHandoffEvidence(
                buildHq0437ProviderReadyLaunchGate(),
                "",
                "",
                false,
                "h2-provider-blocker-diagnostic"
            )
        )

        @Assert(handoff.status, "not-diagnostic-provider-ready")
        @Assert(
            handoff.decision,
            "open-runtime-proof-packet-instead-of-diagnostic-handoff"
        )
        @Assert(handoff.diagnosticHandoffAllowed, false)
        @Assert(handoff.h2RuntimeProofLaunchAllowed, false)
        @Assert(handoff.blockers[0], "RUNTIME_PROOF_LAUNCH_READY")
    }
}

func buildHq0437LaunchGateFromCurrentProviderBlocker(
    carried: Bool
): JinguiAcceptedTransportH2RuntimeProofLaunchGate {
    let classification = classifyServerJinguiAcceptedTransportTlsAttachBlocker(
        "accepted transport TLS1.3 X25519 attach failed: TLS1.3 transcript hash must be SHA-256 sized"
    )
    let attachGate = buildServerJinguiAcceptedTransportTlsAttachProofGate(
        ServerJinguiAcceptedTransportTlsAttachProofGateEvidence(
            classification,
            false,
            false,
            false,
            carried
        )
    )
    buildJinguiAcceptedTransportH2RuntimeProofLaunchGate(
        JinguiAcceptedTransportH2RuntimeProofLaunchEvidence(
            attachGate,
            true,
            true,
            true,
            true,
            buildHq0737AcceptedRuntimeProgressReadoutForLaunchTest()
        )
    )
}

func buildHq0437ProviderReadyLaunchGate():
    JinguiAcceptedTransportH2RuntimeProofLaunchGate {
    let classification = classifyServerJinguiAcceptedTransportTlsAttachBlocker("")
    let attachGate = buildServerJinguiAcceptedTransportTlsAttachProofGate(
        ServerJinguiAcceptedTransportTlsAttachProofGateEvidence(
            classification,
            true,
            true,
            false,
            false
        )
    )
    buildJinguiAcceptedTransportH2RuntimeProofLaunchGate(
        JinguiAcceptedTransportH2RuntimeProofLaunchEvidence(
            attachGate,
            true,
            true,
            true,
            true,
            buildHq0737AcceptedRuntimeProgressReadoutForLaunchTest()
        )
    )
}
