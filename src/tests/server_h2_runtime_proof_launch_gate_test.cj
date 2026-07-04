package ignite.tests

import ignite.*

@Test
public class ServerH2RuntimeProofLaunchGateTestSuite {
    @TestCase
    public func testProviderBlockerStopsBeforeRuntimeLaunch(): Unit {
        let attachGate = buildCurrentProviderBlockedAttachGate(false)
        let launchGate = buildJinguiAcceptedTransportH2RuntimeProofLaunchGate(
            JinguiAcceptedTransportH2RuntimeProofLaunchEvidence(
                attachGate,
                true,
                true,
                true,
                true
            )
        )

        @Assert(launchGate.status, "blocked-provider-attach-gate")
        @Assert(launchGate.decision, "stop-before-h2-runtime-launch")
        @Assert(launchGate.diagnosticPacketAllowed, false)
        @Assert(launchGate.h2RuntimeProofLaunchAllowed, false)
        @Assert(launchGate.h2RuntimeClosureClaimAllowed, false)
        @Assert(launchGate.blockers[0], "PROVIDER_ATTACH_GATE:blocked-provider-contract")
        @Assert(launchGate.closureMissingProofs[0], "H2_RUNTIME_SOCKET_PROOF")
    }

    @TestCase
    public func testCarriedProviderBlockerAllowsDiagnosticOnly(): Unit {
        let attachGate = buildCurrentProviderBlockedAttachGate(true)
        let launchGate = buildJinguiAcceptedTransportH2RuntimeProofLaunchGate(
            JinguiAcceptedTransportH2RuntimeProofLaunchEvidence(
                attachGate,
                true,
                true,
                true,
                true
            )
        )

        @Assert(launchGate.status, "diagnostic-only-provider-blocker-carried")
        @Assert(launchGate.decision, "run-h2-diagnostic-only-with-provider-blocker-stop-condition")
        @Assert(launchGate.diagnosticPacketAllowed, true)
        @Assert(launchGate.h2RuntimeProofLaunchAllowed, false)
        @Assert(launchGate.h2RuntimeClosureClaimAllowed, false)
        @Assert(launchGate.blockers[0], "PROVIDER_ATTACH_GATE:expected-provider-blocker-carried")
    }

    @TestCase
    public func testMissingH2ModelProofBlocksRuntimeLaunchAfterProviderReady(): Unit {
        let attachGate = buildProviderReadyAttachGate()
        let launchGate = buildJinguiAcceptedTransportH2RuntimeProofLaunchGate(
            JinguiAcceptedTransportH2RuntimeProofLaunchEvidence(
                attachGate,
                true,
                false,
                true,
                false
            )
        )

        @Assert(launchGate.status, "blocked-h2-launch-precondition-gap")
        @Assert(launchGate.decision, "collect-h2-model-proofs-before-runtime-launch")
        @Assert(launchGate.h2RuntimeProofLaunchAllowed, false)
        @Assert(launchGate.missingLaunchProofs[0], "H2_FLOW_BUDGET_WINDOW_UPDATE_PROOF")
        @Assert(launchGate.missingLaunchProofs[1], "H2_WIRE_FIXTURE_PROOF")
        @Assert(launchGate.blockers[0], "MISSING:H2_FLOW_BUDGET_WINDOW_UPDATE_PROOF")
    }

    @TestCase
    public func testProviderReadyAndH2PreconditionsAllowRuntimeLaunchOnly(): Unit {
        let attachGate = buildProviderReadyAttachGate()
        let launchGate = buildJinguiAcceptedTransportH2RuntimeProofLaunchGate(
            JinguiAcceptedTransportH2RuntimeProofLaunchEvidence(
                attachGate,
                true,
                true,
                true,
                true
            )
        )

        @Assert(launchGate.status, "ready-for-h2-runtime-proof-launch")
        @Assert(launchGate.decision, "open-bounded-h2-runtime-proof-packet")
        @Assert(launchGate.diagnosticPacketAllowed, true)
        @Assert(launchGate.h2RuntimeProofLaunchAllowed, true)
        @Assert(launchGate.h2RuntimeClosureClaimAllowed, false)
        @Assert(launchGate.missingLaunchProofs.size, 0)
        @Assert(launchGate.closureMissingProofs[3], "H2SPEC_PROOF")
        @Assert(launchGate.nonClaims[2], "NO_H2_RUNTIME_CLOSURE_CLAIM")
    }
}

func buildCurrentProviderBlockedAttachGate(
    carried: Bool
): ServerJinguiAcceptedTransportTlsAttachProofGate {
    let classification = classifyServerJinguiAcceptedTransportTlsAttachBlocker(
        "accepted transport TLS1.3 X25519 attach failed: TLS1.3 transcript hash must be SHA-256 sized"
    )
    buildServerJinguiAcceptedTransportTlsAttachProofGate(
        ServerJinguiAcceptedTransportTlsAttachProofGateEvidence(
            classification,
            false,
            false,
            false,
            carried
        )
    )
}

func buildProviderReadyAttachGate(): ServerJinguiAcceptedTransportTlsAttachProofGate {
    let classification = classifyServerJinguiAcceptedTransportTlsAttachBlocker("")
    buildServerJinguiAcceptedTransportTlsAttachProofGate(
        ServerJinguiAcceptedTransportTlsAttachProofGateEvidence(
            classification,
            true,
            true,
            false,
            false
        )
    )
}
