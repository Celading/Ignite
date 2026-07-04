package ignite.tests

import ignite.*

@Test
public class ServerJinguiSslTlsAttachProofGateTestSuite {
    @TestCase
    public func testCurrentProviderContractBlockerStopsBeforeH2RuntimeProof(): Unit {
        let classification =
            classifyServerJinguiAcceptedTransportTlsAttachBlocker(
                "accepted transport TLS1.3 X25519 attach failed: TLS1.3 transcript hash must be SHA-256 sized"
            )
        let gate = buildServerJinguiAcceptedTransportTlsAttachProofGate(
            ServerJinguiAcceptedTransportTlsAttachProofGateEvidence(
                classification,
                false,
                false,
                false,
                false
            )
        )

        @Assert(gate.status, "blocked-provider-contract")
        @Assert(gate.decision, "stop-before-h2-runtime-proof")
        @Assert(gate.owner, "JinguiSSL-contract")
        @Assert(gate.diagnosticPacketAllowed, false)
        @Assert(gate.h2RuntimeProofAllowed, false)
        @Assert(gate.h2RuntimeClosureClaimAllowed, false)
        @Assert(gate.blockers[0], "TLS13_TRANSCRIPT_HASH_SIZE")
        @Assert(gate.missingProofs[0], "ACCEPTED_TRANSPORT_ATTACH_PASS")
    }

    @TestCase
    public func testCarriedProviderBlockerAllowsDiagnosticOnly(): Unit {
        let classification =
            classifyServerJinguiAcceptedTransportTlsAttachBlocker(
                "accepted transport TLS1.3 X25519 attach failed: TLS1.3 transcript hash must be SHA-256 sized"
            )
        let gate = buildServerJinguiAcceptedTransportTlsAttachProofGate(
            ServerJinguiAcceptedTransportTlsAttachProofGateEvidence(
                classification,
                false,
                false,
                false,
                true
            )
        )

        @Assert(gate.status, "expected-provider-blocker-carried")
        @Assert(gate.decision, "run-diagnostic-only-with-provider-blocker-stop-condition")
        @Assert(gate.diagnosticPacketAllowed, true)
        @Assert(gate.h2RuntimeProofAllowed, false)
        @Assert(gate.h2RuntimeClosureClaimAllowed, false)
        @Assert(gate.blockers[0], "EXPECTED_PROVIDER_BLOCKER:TLS13_TRANSCRIPT_HASH_SIZE")
    }

    @TestCase
    public func testAcceptedProviderProofAndAttachPassAllowsH2RuntimeProofOnly(): Unit {
        let classification =
            classifyServerJinguiAcceptedTransportTlsAttachBlocker("")
        let gate = buildServerJinguiAcceptedTransportTlsAttachProofGate(
            ServerJinguiAcceptedTransportTlsAttachProofGateEvidence(
                classification,
                true,
                true,
                false,
                false
            )
        )

        @Assert(gate.status, "ready-for-h2-runtime-proof")
        @Assert(gate.decision, "run-h2-runtime-proof-without-closure-claim")
        @Assert(gate.owner, "Ignite-H2-runtime-packet")
        @Assert(gate.diagnosticPacketAllowed, true)
        @Assert(gate.h2RuntimeProofAllowed, true)
        @Assert(gate.h2RuntimeClosureClaimAllowed, false)
        @Assert(gate.nonClaims[2], "NO_H2_RUNTIME_CLOSURE_CLAIM")
    }

    @TestCase
    public func testAlternateProviderAttachPassAlsoAllowsH2RuntimeProofOnly(): Unit {
        let classification =
            classifyServerJinguiAcceptedTransportTlsAttachBlocker("")
        let gate = buildServerJinguiAcceptedTransportTlsAttachProofGate(
            ServerJinguiAcceptedTransportTlsAttachProofGateEvidence(
                classification,
                false,
                true,
                true,
                false
            )
        )

        @Assert(gate.status, "ready-for-h2-runtime-proof")
        @Assert(gate.h2RuntimeProofAllowed, true)
        @Assert(gate.h2RuntimeClosureClaimAllowed, false)
        @Assert(gate.missingProofs.size, 0)
    }
}
