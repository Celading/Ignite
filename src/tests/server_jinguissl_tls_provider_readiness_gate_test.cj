package ignite.tests

import ignite.*

@Test
public class ServerJinguiSslTlsProviderReadinessGateTestSuite {
    @TestCase
    public func testCarriedProviderBlockerDoesNotSatisfyReadiness(): Unit {
        let readinessGate = buildServerJinguiTlsProviderReadinessGate(
            ServerJinguiTlsProviderReadinessEvidence(
                hq0566ProviderBlockedAttachGate(true),
                true,
                true,
                true,
                true,
                true,
                true
            )
        )

        @Assert(readinessGate.providerReadinessAccepted, false)
        @Assert(readinessGate.h1TlsProviderSeamSatisfied, false)
        @Assert(readinessGate.h2ProviderPreconditionSatisfied, false)
        @Assert(readinessGate.status, "diagnostic-only-provider-blocker-carried")
        @Assert(readinessGate.blockers[0], "ATTACH_GATE:expected-provider-blocker-carried")
        @Assert(readinessGate.nonClaims[3], "NO_H2_RUNTIME_CLOSURE_CLAIM")
    }

    @TestCase
    public func testProviderReadyAttachStillRequiresWorkOrderEvidence(): Unit {
        let readinessGate = buildServerJinguiTlsProviderReadinessGate(
            ServerJinguiTlsProviderReadinessEvidence(
                hq0566ProviderReadyAttachGate(),
                true,
                false,
                true,
                false,
                true,
                false
            )
        )

        @Assert(readinessGate.providerReadinessAccepted, false)
        @Assert(readinessGate.status, "blocked-provider-readiness-gap")
        @Assert(readinessGate.decision, "collect-provider-readiness-evidence-before-consuming-seam")
        @Assert(readinessGate.missingProofs[0], "CERT_KEY_CONTRACT_API_PROOF")
        @Assert(readinessGate.missingProofs[1], "ERROR_TAXONOMY_PROOF")
        @Assert(readinessGate.missingProofs[2], "PROVIDER_VERSION_RECEIPT_PROOF")
        @Assert(readinessGate.blockers[0], "MISSING:CERT_KEY_CONTRACT_API_PROOF")
    }

    @TestCase
    public func testCompleteProviderReadinessSatisfiesProviderSeamOnly(): Unit {
        let readinessGate = hq0566CompleteProviderReadinessGate()

        @Assert(readinessGate.providerReadinessAccepted, true)
        @Assert(readinessGate.h1TlsProviderSeamSatisfied, true)
        @Assert(readinessGate.h2ProviderPreconditionSatisfied, true)
        @Assert(readinessGate.h2RuntimeClosureClaimAllowed, false)
        @Assert(readinessGate.status, "ready-for-ignite-provider-consumption")
        @Assert(readinessGate.decision, "satisfy-tls-provider-seam-without-default-flip")
        @Assert(readinessGate.nonClaims[1], "NO_STDX_TLS_REMOVAL_CLAIM")
        @Assert(readinessGate.nonClaims[2], "NO_H1_DEFAULT_FLIP_CLAIM")
    }

    @TestCase
    public func testProviderReadinessCanClearH1TlsSeamButStillDefersDefaultFlip(): Unit {
        let evidence = SocketServerEngineShellProductionCandidateEvidence(
            2,
            true,
            true,
            true,
            true,
            true
        )
        let legacyGate = buildSocketServerEngineShellProductionCandidateGate(
            evidence
        )
        let readinessGate =
            buildSocketServerEngineShellProductionCandidateGateWithTlsProviderReadiness(
                evidence,
                hq0566CompleteProviderReadinessGate()
            )

        @Assert(legacyGate.productionCandidate, false)
        @Assert(legacyGate.blockers[0], "TLS_PROVIDER_SEAM_REQUIRED")
        @Assert(readinessGate.productionCandidate, true)
        @Assert(readinessGate.blockers.size, 0)
        @Assert(readinessGate.defaultFlipDecision, "defer-default-flip-to-release-gate")
        @Assert(readinessGate.nonClaims[0], "NO_DEFAULT_FLIP")
        @Assert(readinessGate.nonClaims[1], "NO_STDX_REMOVAL_CLAIM")
        @Assert(readinessGate.nonClaims[3], "NO_H2_RUNTIME_CLAIM")
    }
}

func hq0566ProviderBlockedAttachGate(
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

func hq0566ProviderReadyAttachGate(
): ServerJinguiAcceptedTransportTlsAttachProofGate {
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

func hq0566CompleteProviderReadinessGate(
): ServerJinguiTlsProviderReadinessGate {
    buildServerJinguiTlsProviderReadinessGate(
        ServerJinguiTlsProviderReadinessEvidence(
            hq0566ProviderReadyAttachGate(),
            true,
            true,
            true,
            true,
            true,
            true
        )
    )
}
