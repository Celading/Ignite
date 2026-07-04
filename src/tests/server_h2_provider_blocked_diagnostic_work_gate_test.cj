package ignite.tests

import ignite.*

@Test
public class ServerH2ProviderBlockedDiagnosticWorkGateTestSuite {
    @TestCase
    public func testModelOnlyFlowBudgetDiagnosticIsAllowed(): Unit {
        let gate = buildJinguiAcceptedTransportH2DiagnosticWorkGate(
            JinguiAcceptedTransportH2DiagnosticWorkEvidence(
                buildHq0438CarriedDiagnosticHandoff(),
                "h2-flow-budget-diagnostic",
                true,
                false,
                false,
                false,
                false
            )
        )

        @Assert(gate.status, "ready-for-provider-blocked-h2-diagnostic-work")
        @Assert(
            gate.decision,
            "run-model-only-diagnostic-and-stop-at-provider-blocker"
        )
        @Assert(gate.diagnosticWorkAllowed, true)
        @Assert(gate.h2RuntimeProofLaunchAllowed, false)
        @Assert(gate.h2RuntimeClosureClaimAllowed, false)
        @Assert(gate.requestedDiagnosticKind, "h2-flow-budget-diagnostic")
        @Assert(gate.allowedDiagnosticKinds[3], "h2-flow-budget-diagnostic")
        @Assert(gate.nonClaims[2], "NO_H2_RUNTIME_LAUNCH_CLAIM")
    }

    @TestCase
    public func testBlockedWhenDiagnosticHandoffIsNotReady(): Unit {
        let gate = buildJinguiAcceptedTransportH2DiagnosticWorkGate(
            JinguiAcceptedTransportH2DiagnosticWorkEvidence(
                buildHq0438UncarriedDiagnosticHandoff(),
                "h2-flow-budget-diagnostic",
                true,
                false,
                false,
                false,
                false
            )
        )

        @Assert(gate.status, "blocked-diagnostic-handoff-not-ready")
        @Assert(gate.decision, "complete-diagnostic-handoff-before-work")
        @Assert(gate.diagnosticWorkAllowed, false)
        @Assert(gate.blockers[0], "HANDOFF:blocked-before-diagnostic-handoff")
    }

    @TestCase
    public func testRuntimeScopeIsBlockedInDiagnosticWork(): Unit {
        let gate = buildJinguiAcceptedTransportH2DiagnosticWorkGate(
            JinguiAcceptedTransportH2DiagnosticWorkEvidence(
                buildHq0438CarriedDiagnosticHandoff(),
                "h2-wire-fixture-diagnostic",
                true,
                true,
                true,
                true,
                true
            )
        )

        @Assert(gate.status, "blocked-runtime-scope-in-diagnostic-work")
        @Assert(
            gate.decision,
            "split-runtime-or-closure-work-out-of-diagnostic-gate"
        )
        @Assert(gate.diagnosticWorkAllowed, false)
        @Assert(gate.blockers[0], "FORBIDDEN:H2_RUNTIME_SOCKET_REQUESTED")
        @Assert(gate.blockers[3], "FORBIDDEN:H2SPEC_REQUESTED")
    }

    @TestCase
    public func testUnsupportedDiagnosticKindIsBlocked(): Unit {
        let gate = buildJinguiAcceptedTransportH2DiagnosticWorkGate(
            JinguiAcceptedTransportH2DiagnosticWorkEvidence(
                buildHq0438CarriedDiagnosticHandoff(),
                "h2-browser-replay-diagnostic",
                true,
                false,
                false,
                false,
                false
            )
        )

        @Assert(gate.status, "blocked-unsupported-diagnostic-kind")
        @Assert(gate.decision, "choose-supported-model-only-diagnostic-kind")
        @Assert(gate.diagnosticWorkAllowed, false)
        @Assert(
            gate.blockers[0],
            "UNSUPPORTED_DIAGNOSTIC_KIND:h2-browser-replay-diagnostic"
        )
    }

    @TestCase
    public func testMissingModelOnlyProofIsBlocked(): Unit {
        let gate = buildJinguiAcceptedTransportH2DiagnosticWorkGate(
            JinguiAcceptedTransportH2DiagnosticWorkEvidence(
                buildHq0438CarriedDiagnosticHandoff(),
                "h2-header-projection-diagnostic",
                false,
                false,
                false,
                false,
                false
            )
        )

        @Assert(gate.status, "blocked-model-only-proof-missing")
        @Assert(gate.decision, "carry-model-only-diagnostic-proof-before-work")
        @Assert(gate.diagnosticWorkAllowed, false)
        @Assert(gate.blockers[0], "MISSING:MODEL_ONLY_DIAGNOSTIC_PROOF")
    }
}

func buildHq0438CarriedDiagnosticHandoff():
    JinguiAcceptedTransportH2DiagnosticOnlyHandoff {
    buildJinguiAcceptedTransportH2DiagnosticOnlyHandoff(
        JinguiAcceptedTransportH2DiagnosticOnlyHandoffEvidence(
            buildHq0438LaunchGateFromCurrentProviderBlocker(true),
            "JinguiSSL-contract",
            "TLS13_TRANSCRIPT_HASH_SIZE",
            true,
            "h2-provider-blocked-diagnostic-work"
        )
    )
}

func buildHq0438UncarriedDiagnosticHandoff():
    JinguiAcceptedTransportH2DiagnosticOnlyHandoff {
    buildJinguiAcceptedTransportH2DiagnosticOnlyHandoff(
        JinguiAcceptedTransportH2DiagnosticOnlyHandoffEvidence(
            buildHq0438LaunchGateFromCurrentProviderBlocker(false),
            "JinguiSSL-contract",
            "TLS13_TRANSCRIPT_HASH_SIZE",
            false,
            "h2-provider-blocked-diagnostic-work"
        )
    )
}

func buildHq0438LaunchGateFromCurrentProviderBlocker(
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
            true
        )
    )
}
