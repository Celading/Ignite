package ignite.tests

import ignite.*

@Test
public class ServerEngineDefaultFlipReadinessTestSuite {
    @TestCase
    public func testSocketServerEngineShellDefaultFlipReadinessBlocksWhenOnlyProductionCandidateIsReady(): Unit {
        let productionGate = buildSocketServerEngineShellProductionCandidateGate(
            SocketServerEngineShellProductionCandidateEvidence(
                2,
                false,
                true,
                true,
                true,
                true
            )
        )
        let readinessGate = SocketServerEngineShell().defaultFlipReadinessGate(
            SocketServerEngineShellDefaultFlipReadinessEvidence(
                productionGate,
                false,
                false,
                false,
                false
            )
        )

        @Assert(productionGate.productionCandidate, true)
        @Assert(readinessGate.defaultFlipReady, false)
        @Assert(readinessGate.status, "blocked-default-flip-readiness-gap")
        @Assert(readinessGate.decision, "keep-stdx-default")
        @Assert(readinessGate.requiredProofs[0], "PRODUCTION_CANDIDATE_GATE_READY")
        @Assert(readinessGate.missingProofs[0], "OPERATOR_ACCEPTANCE_PROOF")
        @Assert(readinessGate.missingProofs[1], "RELEASE_GUARD_PROOF")
        @Assert(readinessGate.blockers[0], "MISSING:OPERATOR_ACCEPTANCE_PROOF")
        @Assert(readinessGate.nonClaims[0], "NO_DEFAULT_FLIP_IN_THIS_PACKET")
        @Assert(readinessGate.quicReuseHook, "QUIC and future native transports should split production-candidate readiness from default-selection readiness")
    }

    @TestCase
    public func testSocketServerEngineShellDefaultFlipReadinessCarriesProductionCandidateBlockers(): Unit {
        let productionGate = buildSocketServerEngineShellProductionCandidateGate(
            SocketServerEngineShellProductionCandidateEvidence(
                1,
                false,
                false,
                false,
                false,
                false
            )
        )
        let readinessGate = buildSocketServerEngineShellDefaultFlipReadinessGate(
            SocketServerEngineShellDefaultFlipReadinessEvidence(
                productionGate,
                true,
                true,
                true,
                true
            )
        )

        @Assert(productionGate.productionCandidate, false)
        @Assert(readinessGate.defaultFlipReady, false)
        @Assert(readinessGate.decision, "keep-stdx-default")
        @Assert(readinessGate.missingProofs[0], "PRODUCTION_CANDIDATE_GATE_READY")
        @Assert(readinessGate.blockers[0], "PRODUCTION_CANDIDATE_GATE_NOT_READY")
        @Assert(readinessGate.blockers[1], "PRODUCTION_CANDIDATE_BLOCKER:MISSING:ACCEPT_LOOP_MULTI_CONNECTION_PROOF")
        @Assert(readinessGate.nonClaims[1], "NO_STDX_REMOVAL_CLAIM")
    }

    @TestCase
    public func testSocketServerEngineShellDefaultFlipReadinessReadyStillRequiresSeparateChangePacket(): Unit {
        let productionGate = buildSocketServerEngineShellProductionCandidateGate(
            SocketServerEngineShellProductionCandidateEvidence(
                2,
                false,
                true,
                true,
                true,
                true
            )
        )
        let readinessGate = buildSocketServerEngineShellDefaultFlipReadinessGate(
            SocketServerEngineShellDefaultFlipReadinessEvidence(
                productionGate,
                true,
                true,
                true,
                true
            )
        )

        @Assert(readinessGate.defaultFlipReady, true)
        @Assert(readinessGate.status, "default-flip-readiness-ready")
        @Assert(readinessGate.decision, "ready-for-separate-default-engine-change-packet")
        @Assert(readinessGate.missingProofs.size, 0)
        @Assert(readinessGate.blockers.size, 0)
        @Assert(readinessGate.nextAction, "open an explicit release/default-engine-change packet; do not flip default in this proof packet")
        @Assert(readinessGate.nonClaims[0], "NO_DEFAULT_FLIP_IN_THIS_PACKET")
    }

    @TestCase
    public func testH1DefaultReplacementPreflightAcceptsEvidenceButStillDoesNotFlip(): Unit {
        let providerGate = hq0566CompleteProviderReadinessGate()
        let productionGate =
            buildSocketServerEngineShellProductionCandidateGateWithTlsProviderReadiness(
                SocketServerEngineShellProductionCandidateEvidence(
                    2,
                    true,
                    true,
                    true,
                    true,
                    true
                ),
                providerGate
            )
        let readinessGate = buildSocketServerEngineShellDefaultFlipReadinessGate(
            SocketServerEngineShellDefaultFlipReadinessEvidence(
                productionGate,
                true,
                true,
                true,
                true
            )
        )
        let preflightGate =
            SocketServerEngineShell().h1DefaultReplacementPreflightGate(
                SocketServerEngineShellH1DefaultReplacementPreflightEvidence(
                    "hq-0567-h1-default-replacement-preflight",
                    productionGate,
                    readinessGate,
                    providerGate,
                    true,
                    true,
                    true,
                    true,
                    false,
                    false,
                    false,
                    false,
                    false,
                    false
                )
            )

        @Assert(productionGate.productionCandidate, true)
        @Assert(readinessGate.defaultFlipReady, true)
        @Assert(preflightGate.h1DefaultReplacementPreflightAccepted, true)
        @Assert(preflightGate.status, "h1-native-default-replacement-preflight-ready")
        @Assert(preflightGate.decision, "ready-for-separate-default-engine-change-packet")
        @Assert(preflightGate.defaultFlipAllowed, false)
        @Assert(preflightGate.stdxRemovalAllowed, false)
        @Assert(preflightGate.publicReleaseOrHostedPublicationAllowed, false)
        @Assert(preflightGate.nonClaims[0], "NO_ACTUAL_DEFAULT_ENGINE_FLIP")
        @Assert(preflightGate.nonClaims[4], "NO_H1_NATIVE_DEFAULT_REPLACEMENT_CLOSEOUT_CLAIM")
    }

    @TestCase
    public func testH1DefaultReplacementPreflightBlocksProviderGap(): Unit {
        let providerGate = buildServerJinguiTlsProviderReadinessGate(
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
        let productionGate =
            buildSocketServerEngineShellProductionCandidateGateWithTlsProviderReadiness(
                SocketServerEngineShellProductionCandidateEvidence(
                    2,
                    true,
                    true,
                    true,
                    true,
                    true
                ),
                providerGate
            )
        let readinessGate = buildSocketServerEngineShellDefaultFlipReadinessGate(
            SocketServerEngineShellDefaultFlipReadinessEvidence(
                productionGate,
                true,
                true,
                true,
                true
            )
        )
        let preflightGate =
            buildSocketServerEngineShellH1DefaultReplacementPreflightGate(
                SocketServerEngineShellH1DefaultReplacementPreflightEvidence(
                    "hq-0567-provider-gap",
                    productionGate,
                    readinessGate,
                    providerGate,
                    true,
                    true,
                    true,
                    true,
                    false,
                    false,
                    false,
                    false,
                    false,
                    false
                )
            )

        @Assert(preflightGate.h1DefaultReplacementPreflightAccepted, false)
        @Assert(preflightGate.status, "blocked-h1-native-default-replacement-preflight-gap")
        @Assert(preflightGate.blockers[0], "PRODUCTION_CANDIDATE_GATE_NOT_READY")
        @Assert(preflightGate.blockers[1], "PRODUCTION_CANDIDATE_BLOCKER:TLS_PROVIDER_SEAM_REQUIRED")
        @Assert(preflightGate.blockers[2], "PRODUCTION_CANDIDATE_BLOCKER:TLS_PROVIDER_GATE:diagnostic-only-provider-blocker-carried")
        @Assert(preflightGate.decision, "keep-stdx-default")
    }

    @TestCase
    public func testH1DefaultReplacementPreflightBlocksOverclaims(): Unit {
        let providerGate = hq0566CompleteProviderReadinessGate()
        let productionGate =
            buildSocketServerEngineShellProductionCandidateGateWithTlsProviderReadiness(
                SocketServerEngineShellProductionCandidateEvidence(
                    2,
                    true,
                    true,
                    true,
                    true,
                    true
                ),
                providerGate
            )
        let readinessGate = buildSocketServerEngineShellDefaultFlipReadinessGate(
            SocketServerEngineShellDefaultFlipReadinessEvidence(
                productionGate,
                true,
                true,
                true,
                true
            )
        )
        let preflightGate =
            buildSocketServerEngineShellH1DefaultReplacementPreflightGate(
                SocketServerEngineShellH1DefaultReplacementPreflightEvidence(
                    "hq-0567-overclaim",
                    productionGate,
                    readinessGate,
                    providerGate,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true
                )
            )

        @Assert(preflightGate.h1DefaultReplacementPreflightAccepted, false)
        @Assert(preflightGate.blockers[0], "ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
        @Assert(preflightGate.blockers[1], "DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
        @Assert(preflightGate.blockers[2], "RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
        @Assert(preflightGate.blockers[3], "STDX_REMOVAL_REQUESTED")
        @Assert(preflightGate.blockers[4], "H2_RUNTIME_CLOSURE_CLAIMED")
        @Assert(preflightGate.blockers[5], "PUBLIC_RELEASE_OR_HOSTED_PUBLICATION_CLAIMED")
        @Assert(preflightGate.defaultEngineConfigMutationAllowed, false)
    }

    @TestCase
    public func testH1DefaultReplacementPreflightBlocksBoundaryProofGaps(): Unit {
        let providerGate = hq0566CompleteProviderReadinessGate()
        let productionGate =
            buildSocketServerEngineShellProductionCandidateGateWithTlsProviderReadiness(
                SocketServerEngineShellProductionCandidateEvidence(
                    2,
                    true,
                    true,
                    true,
                    true,
                    true
                ),
                providerGate
            )
        let readinessGate = buildSocketServerEngineShellDefaultFlipReadinessGate(
            SocketServerEngineShellDefaultFlipReadinessEvidence(
                productionGate,
                true,
                true,
                true,
                true
            )
        )
        let preflightGate =
            buildSocketServerEngineShellH1DefaultReplacementPreflightGate(
                SocketServerEngineShellH1DefaultReplacementPreflightEvidence(
                    "hq-0567-boundary-gap",
                    productionGate,
                    readinessGate,
                    providerGate,
                    false,
                    false,
                    false,
                    false,
                    false,
                    false,
                    false,
                    false,
                    false,
                    false
                )
            )

        @Assert(preflightGate.h1DefaultReplacementPreflightAccepted, false)
        @Assert(preflightGate.requiredProofs[4], "STDX_CLAIM_BOUNDARY_PROOF")
        @Assert(preflightGate.blockers[0], "STDX_CLAIM_BOUNDARY_PROOF_NOT_CARRIED")
        @Assert(preflightGate.blockers[1], "DEFAULT_ENGINE_CONFIG_UNCHANGED_PROOF_NOT_CARRIED")
        @Assert(preflightGate.blockers[2], "HOSTED_DEPENDENCY_PROJECTION_PROOF_NOT_CARRIED")
        @Assert(preflightGate.blockers[3], "SEPARATE_CHANGE_PACKET_PROOF_NOT_CARRIED")
    }

    @TestCase
    public func testH1DefaultEngineControlledSwitchAcceptsPlanButDoesNotMutateDefault(): Unit {
        let switchGate =
            SocketServerEngineShell().h1DefaultEngineControlledSwitchGate(
                SocketServerEngineShellH1DefaultEngineControlledSwitchEvidence(
                    "hq-0568-h1-default-engine-controlled-switch",
                    hq0568AcceptedH1PreflightGate(),
                    "ignite-native-h1",
                    "stdx-http-server",
                    "native-h1",
                    true,
                    true,
                    true,
                    true,
                    true,
                    false,
                    false,
                    false,
                    false,
                    false,
                    false,
                    false
                )
            )

        @Assert(switchGate.controlledSwitchAccepted, true)
        @Assert(switchGate.switchPlanReady, true)
        @Assert(switchGate.status, "h1-default-engine-controlled-switch-ready")
        @Assert(switchGate.decision, "ready-for-separate-runtime-default-mutation-packet")
        @Assert(switchGate.candidateEngine, "ignite-native-h1")
        @Assert(switchGate.fallbackEngine, "stdx-http-server")
        @Assert(switchGate.actualDefaultEngineFlipAllowed, false)
        @Assert(switchGate.appConstructorDefaultMutationAllowed, false)
        @Assert(switchGate.runtimeDefaultPathMutationAllowed, false)
        @Assert(switchGate.nonClaims[1], "NO_APP_CONSTRUCTOR_DEFAULT_MUTATION")
    }

    @TestCase
    public func testH1DefaultEngineControlledSwitchBlocksRejectedPreflight(): Unit {
        let providerGate = buildServerJinguiTlsProviderReadinessGate(
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
        let productionGate =
            buildSocketServerEngineShellProductionCandidateGateWithTlsProviderReadiness(
                SocketServerEngineShellProductionCandidateEvidence(
                    2,
                    true,
                    true,
                    true,
                    true,
                    true
                ),
                providerGate
            )
        let readinessGate = buildSocketServerEngineShellDefaultFlipReadinessGate(
            SocketServerEngineShellDefaultFlipReadinessEvidence(
                productionGate,
                true,
                true,
                true,
                true
            )
        )
        let preflightGate =
            buildSocketServerEngineShellH1DefaultReplacementPreflightGate(
                SocketServerEngineShellH1DefaultReplacementPreflightEvidence(
                    "hq-0568-rejected-preflight",
                    productionGate,
                    readinessGate,
                    providerGate,
                    true,
                    true,
                    true,
                    true,
                    false,
                    false,
                    false,
                    false,
                    false,
                    false
                )
            )
        let switchGate =
            buildSocketServerEngineShellH1DefaultEngineControlledSwitchGate(
                SocketServerEngineShellH1DefaultEngineControlledSwitchEvidence(
                    "hq-0568-rejected-preflight-switch",
                    preflightGate,
                    "ignite-native-h1",
                    "stdx-http-server",
                    "native-h1",
                    true,
                    true,
                    true,
                    true,
                    true,
                    false,
                    false,
                    false,
                    false,
                    false,
                    false,
                    false
                )
            )

        @Assert(switchGate.controlledSwitchAccepted, false)
        @Assert(switchGate.status, "blocked-h1-default-engine-controlled-switch-gap")
        @Assert(switchGate.blockers[0], "H1_DEFAULT_REPLACEMENT_PREFLIGHT_NOT_ACCEPTED")
        @Assert(switchGate.blockers[1], "PREFLIGHT_BLOCKER:PRODUCTION_CANDIDATE_GATE_NOT_READY")
        @Assert(switchGate.decision, "keep-stdx-default")
    }

    @TestCase
    public func testH1DefaultEngineControlledSwitchBlocksCandidateFallbackAndHintDrift(): Unit {
        let switchGate =
            buildSocketServerEngineShellH1DefaultEngineControlledSwitchGate(
                SocketServerEngineShellH1DefaultEngineControlledSwitchEvidence(
                    "hq-0568-candidate-drift",
                    hq0568AcceptedH1PreflightGate(),
                    "stdx-http-server",
                    "none",
                    "stdx",
                    true,
                    true,
                    true,
                    true,
                    true,
                    false,
                    false,
                    false,
                    false,
                    false,
                    false,
                    false
                )
            )

        @Assert(switchGate.controlledSwitchAccepted, false)
        @Assert(switchGate.blockers[0], "CANDIDATE_ENGINE_NOT_IGNITE_NATIVE_H1")
        @Assert(switchGate.blockers[1], "FALLBACK_ENGINE_NOT_STDX_HTTP_SERVER")
        @Assert(switchGate.blockers[2], "CONFIG_HINT_NOT_NATIVE_H1")
        @Assert(switchGate.switchPlanReady, false)
    }

    @TestCase
    public func testH1DefaultEngineControlledSwitchBlocksMutationAndReleaseOverclaims(): Unit {
        let switchGate =
            buildSocketServerEngineShellH1DefaultEngineControlledSwitchGate(
                SocketServerEngineShellH1DefaultEngineControlledSwitchEvidence(
                    "hq-0568-overclaim",
                    hq0568AcceptedH1PreflightGate(),
                    "ignite-native-h1",
                    "stdx-http-server",
                    "ignite-native-h1",
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true
                )
            )

        @Assert(switchGate.controlledSwitchAccepted, false)
        @Assert(switchGate.blockers[0], "ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
        @Assert(switchGate.blockers[1], "APP_CONSTRUCTOR_DEFAULT_MUTATION_REQUESTED")
        @Assert(switchGate.blockers[2], "DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
        @Assert(switchGate.blockers[3], "RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
        @Assert(switchGate.blockers[4], "STDX_REMOVAL_REQUESTED")
        @Assert(switchGate.blockers[5], "H2_RUNTIME_CLOSURE_CLAIMED")
        @Assert(switchGate.blockers[6], "PUBLIC_RELEASE_OR_HOSTED_PUBLICATION_CLAIMED")
        @Assert(switchGate.publicReleaseOrHostedPublicationAllowed, false)
    }

    @TestCase
    public func testH1DefaultMutationReleaseGuardAcceptsEvidenceButStillDoesNotFlip(): Unit {
        let guard =
            SocketServerEngineShell().h1DefaultMutationReleaseGuard(
                SocketServerEngineShellH1DefaultMutationReleaseGuardEvidence(
                    "hq-0570-h1-default-mutation-release-guard",
                    hq0570AcceptedH1ControlledSwitchGate(),
                    "0.8.0",
                    "Ignite0800",
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    false,
                    false,
                    false,
                    false,
                    false,
                    false,
                    false
                )
            )

        @Assert(guard.releaseGuardAccepted, true)
        @Assert(guard.defaultMutationPacketReady, true)
        @Assert(guard.status, "h1-default-mutation-release-guard-ready")
        @Assert(guard.decision, "ready-for-separate-default-mutation-packet")
        @Assert(guard.releaseVersionTarget, "0.8.0")
        @Assert(guard.publicBaselineProjection, "Ignite0800")
        @Assert(guard.actualDefaultEngineFlipAllowed, false)
        @Assert(guard.appConstructorDefaultMutationAllowed, false)
        @Assert(guard.publicReleaseOrHostedPublicationAllowed, false)
        @Assert(guard.nonClaims[8], "NO_RELEASE_TAG_MR_PR_HOSTED_PUBLICATION")
    }

    @TestCase
    public func testH1DefaultMutationReleaseGuardBlocksRejectedControlledSwitch(): Unit {
        let rejectedSwitch =
            buildSocketServerEngineShellH1DefaultEngineControlledSwitchGate(
                SocketServerEngineShellH1DefaultEngineControlledSwitchEvidence(
                    "hq-0570-rejected-switch",
                    hq0568AcceptedH1PreflightGate(),
                    "stdx-http-server",
                    "none",
                    "stdx",
                    true,
                    true,
                    true,
                    true,
                    true,
                    false,
                    false,
                    false,
                    false,
                    false,
                    false,
                    false
                )
            )
        let guard =
            buildSocketServerEngineShellH1DefaultMutationReleaseGuard(
                SocketServerEngineShellH1DefaultMutationReleaseGuardEvidence(
                    "hq-0570-rejected-switch-guard",
                    rejectedSwitch,
                    "0.8.0",
                    "Ignite0800",
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    false,
                    false,
                    false,
                    false,
                    false,
                    false,
                    false
                )
            )

        @Assert(guard.releaseGuardAccepted, false)
        @Assert(guard.status, "blocked-h1-default-mutation-release-guard-gap")
        @Assert(guard.blockers[0], "H1_DEFAULT_ENGINE_CONTROLLED_SWITCH_NOT_ACCEPTED")
        @Assert(guard.blockers[1], "CONTROLLED_SWITCH_BLOCKER:CANDIDATE_ENGINE_NOT_IGNITE_NATIVE_H1")
        @Assert(guard.defaultMutationPacketReady, false)
        @Assert(guard.decision, "keep-stdx-default")
    }

    @TestCase
    public func testH1DefaultMutationReleaseGuardBlocksProofGaps(): Unit {
        let guard =
            buildSocketServerEngineShellH1DefaultMutationReleaseGuard(
                SocketServerEngineShellH1DefaultMutationReleaseGuardEvidence(
                    "hq-0570-proof-gap",
                    hq0570AcceptedH1ControlledSwitchGate(),
                    "",
                    "",
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
                    false
                )
            )

        @Assert(guard.releaseGuardAccepted, false)
        @Assert(guard.requiredProofs[0], "GUARD_ID")
        @Assert(guard.blockers[0], "RELEASE_VERSION_TARGET_NOT_CARRIED")
        @Assert(guard.blockers[1], "PUBLIC_BASELINE_PROJECTION_NOT_CARRIED")
        @Assert(guard.blockers[2], "RELEASE_GUARD_PROOF_NOT_CARRIED")
        @Assert(guard.blockers[3], "ROLLBACK_VERIFICATION_PROOF_NOT_CARRIED")
        @Assert(guard.blockers[4], "PUBLIC_DOCS_PROOF_NOT_CARRIED")
        @Assert(guard.blockers[5], "MIGRATION_GUIDE_PROOF_NOT_CARRIED")
        @Assert(guard.blockers[6], "HOSTED_DEPENDENCY_PROJECTION_PROOF_NOT_CARRIED")
        @Assert(guard.blockers[7], "HOSTED_DEPENDENCY_RESOLUTION_PROOF_NOT_CARRIED")
        @Assert(guard.blockers[8], "PUBLIC_BASELINE_PROJECTION_PROOF_NOT_CARRIED")
        @Assert(guard.blockers[9], "SEPARATE_DEFAULT_MUTATION_PACKET_PROOF_NOT_CARRIED")
    }

    @TestCase
    public func testH1DefaultMutationReleaseGuardBlocksMutationAndReleaseOverclaims(): Unit {
        let guard =
            buildSocketServerEngineShellH1DefaultMutationReleaseGuard(
                SocketServerEngineShellH1DefaultMutationReleaseGuardEvidence(
                    "hq-0570-overclaim",
                    hq0570AcceptedH1ControlledSwitchGate(),
                    "0.8.0",
                    "Ignite0800",
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true
                )
            )

        @Assert(guard.releaseGuardAccepted, false)
        @Assert(guard.blockers[0], "ACTUAL_DEFAULT_ENGINE_FLIP_REQUESTED")
        @Assert(guard.blockers[1], "APP_CONSTRUCTOR_DEFAULT_MUTATION_REQUESTED")
        @Assert(guard.blockers[2], "DEFAULT_ENGINE_CONFIG_MUTATION_REQUESTED")
        @Assert(guard.blockers[3], "RUNTIME_DEFAULT_PATH_MUTATION_REQUESTED")
        @Assert(guard.blockers[4], "STDX_REMOVAL_REQUESTED")
        @Assert(guard.blockers[5], "H2_RUNTIME_CLOSURE_CLAIMED")
        @Assert(guard.blockers[6], "PUBLIC_RELEASE_OR_HOSTED_PUBLICATION_CLAIMED")
        @Assert(guard.publicReleaseOrHostedPublicationAllowed, false)
    }

    @TestCase
    public func testH1CleartextDefaultCloseAcceptsOnlyCleartextDefaultSlice(): Unit {
        let gate =
            SocketServerEngineShell().h1CleartextDefaultCloseGate(
                SocketServerEngineShellH1CleartextDefaultCloseEvidence(
                    "hq-0572-h1-cleartext-default-close",
                    hq0571AcceptedH1DefaultMutationReleaseGuard(),
                    true,
                    true,
                    true,
                    true,
                    true,
                    false,
                    false,
                    false,
                    false,
                    false
                )
            )

        @Assert(gate.cleartextDefaultCloseAccepted, true)
        @Assert(gate.cleartextDefaultNativeAccepted, true)
        @Assert(gate.fullH1NativeDefaultReplacementAccepted, false)
        @Assert(gate.status, "h1-cleartext-default-close-accepted")
        @Assert(
            gate.decision,
            "accept-ignitenext-cleartext-default-native-and-advance-with-tls-stdx-fallback"
        )
        @Assert(gate.sourceZeroStdxAllowed, false)
        @Assert(gate.stdxRemovalAllowed, false)
        @Assert(gate.tlsNativeH1Allowed, false)
        @Assert(gate.h2RuntimeClosureAllowed, false)
        @Assert(gate.publicReleaseOrHostedPublicationAllowed, false)
        @Assert(gate.nonClaims[0], "NO_IGNITE0700_PUBLIC_BASELINE_MUTATION")
        @Assert(gate.nonClaims[4], "NO_FULL_H1_NATIVE_DEFAULT_REPLACEMENT_CLAIM")
    }

    @TestCase
    public func testH1CleartextDefaultCloseBlocksRejectedReleaseGuard(): Unit {
        let rejectedGuard =
            buildSocketServerEngineShellH1DefaultMutationReleaseGuard(
                SocketServerEngineShellH1DefaultMutationReleaseGuardEvidence(
                    "",
                    hq0570AcceptedH1ControlledSwitchGate(),
                    "",
                    "",
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
                    false
                )
            )
        let gate =
            buildSocketServerEngineShellH1CleartextDefaultCloseGate(
                SocketServerEngineShellH1CleartextDefaultCloseEvidence(
                    "hq-0572-rejected-release-guard",
                    rejectedGuard,
                    true,
                    true,
                    true,
                    true,
                    true,
                    false,
                    false,
                    false,
                    false,
                    false
                )
            )

        @Assert(gate.cleartextDefaultCloseAccepted, false)
        @Assert(gate.status, "blocked-h1-cleartext-default-close-gap")
        @Assert(gate.blockers[0], "H1_DEFAULT_MUTATION_RELEASE_GUARD_NOT_ACCEPTED")
        @Assert(gate.blockers[1], "RELEASE_GUARD_BLOCKER:GUARD_ID_NOT_CARRIED")
        @Assert(gate.decision, "keep-sr010-open-before-broader-claim")
    }

    @TestCase
    public func testH1CleartextDefaultCloseBlocksProofGaps(): Unit {
        let gate =
            buildSocketServerEngineShellH1CleartextDefaultCloseGate(
                SocketServerEngineShellH1CleartextDefaultCloseEvidence(
                    "hq-0572-proof-gap",
                    hq0571AcceptedH1DefaultMutationReleaseGuard(),
                    false,
                    false,
                    false,
                    false,
                    false,
                    false,
                    false,
                    false,
                    false,
                    false
                )
            )

        @Assert(gate.cleartextDefaultCloseAccepted, false)
        @Assert(gate.requiredProofs[0], "CLOSE_ID")
        @Assert(gate.blockers[0], "DEFAULT_NATIVE_SELECTION_PROOF_NOT_CARRIED")
        @Assert(gate.blockers[1], "STDX_ROLLBACK_HINT_PROOF_NOT_CARRIED")
        @Assert(gate.blockers[2], "TLS_FALLBACK_PRESERVATION_PROOF_NOT_CARRIED")
        @Assert(gate.blockers[3], "FOCUSED_REGRESSION_PROOF_NOT_CARRIED")
        @Assert(gate.blockers[4], "PUBLIC_BASELINE_NON_MUTATION_PROOF_NOT_CARRIED")
    }

    @TestCase
    public func testH1CleartextDefaultCloseBlocksSourceZeroTlsH2AndReleaseOverclaims(): Unit {
        let gate =
            buildSocketServerEngineShellH1CleartextDefaultCloseGate(
                SocketServerEngineShellH1CleartextDefaultCloseEvidence(
                    "hq-0572-overclaim",
                    hq0571AcceptedH1DefaultMutationReleaseGuard(),
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true
                )
            )

        @Assert(gate.cleartextDefaultCloseAccepted, false)
        @Assert(gate.blockers[0], "SOURCE_ZERO_STDX_CLAIMED")
        @Assert(gate.blockers[1], "STDX_REMOVAL_REQUESTED")
        @Assert(gate.blockers[2], "TLS_NATIVE_H1_CLAIMED")
        @Assert(gate.blockers[3], "H2_RUNTIME_CLOSURE_CLAIMED")
        @Assert(gate.blockers[4], "PUBLIC_RELEASE_OR_HOSTED_PUBLICATION_CLAIMED")
        @Assert(gate.fullH1NativeDefaultReplacementAccepted, false)
    }

    @TestCase
    public func testH1TlsNativeSeamCloseGapAcceptsSeamButDoesNotMutateDefault(): Unit {
        let gate =
            SocketServerEngineShell().h1TlsNativeSeamCloseGapGate(
                SocketServerEngineShellH1TlsNativeSeamCloseGapEvidence(
                    "hq-0573-h1-tls-native-seam-close-gap",
                    hq0572AcceptedH1CleartextDefaultCloseGate(),
                    hq0566CompleteProviderReadinessGate(),
                    true,
                    true,
                    true,
                    true,
                    true,
                    false,
                    false,
                    false,
                    false,
                    false,
                    false
                )
            )

        @Assert(gate.h1TlsNativeSeamReady, true)
        @Assert(gate.status, "h1-tls-native-seam-close-gap-ready")
        @Assert(
            gate.decision,
            "accept-h1-tls-native-seam-and-open-default-tls-mutation-packet"
        )
        @Assert(gate.defaultTlsNativeMutationAllowed, false)
        @Assert(gate.fullH1NativeDefaultReplacementAccepted, false)
        @Assert(gate.sourceZeroStdxAllowed, false)
        @Assert(gate.stdxRemovalAllowed, false)
        @Assert(gate.h2RuntimeClosureAllowed, false)
        @Assert(gate.publicReleaseOrHostedPublicationAllowed, false)
        @Assert(gate.nonClaims[0], "NO_APP_TLS_DEFAULT_MUTATION")
        @Assert(gate.nonClaims[4], "NO_FULL_H1_NATIVE_DEFAULT_REPLACEMENT_CLAIM")
    }

    @TestCase
    public func testH1TlsNativeSeamCloseGapBlocksProviderReadinessGap(): Unit {
        let providerGate = buildServerJinguiTlsProviderReadinessGate(
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
        let gate =
            buildSocketServerEngineShellH1TlsNativeSeamCloseGapGate(
                SocketServerEngineShellH1TlsNativeSeamCloseGapEvidence(
                    "hq-0573-provider-gap",
                    hq0572AcceptedH1CleartextDefaultCloseGate(),
                    providerGate,
                    true,
                    true,
                    true,
                    true,
                    true,
                    false,
                    false,
                    false,
                    false,
                    false,
                    false
                )
            )

        @Assert(gate.h1TlsNativeSeamReady, false)
        @Assert(gate.status, "blocked-h1-tls-native-seam-close-gap")
        @Assert(gate.blockers[0], "JINGUISSL_PROVIDER_READINESS_NOT_ACCEPTED")
        @Assert(
            gate.blockers[1],
            "PROVIDER_READINESS_BLOCKER:ATTACH_GATE:expected-provider-blocker-carried"
        )
        @Assert(
            gate.blockers[2],
            "PROVIDER_READINESS_BLOCKER:ATTACH_BLOCKER:EXPECTED_PROVIDER_BLOCKER:TLS13_TRANSCRIPT_HASH_SIZE"
        )
        @Assert(
            gate.blockers[3],
            "PROVIDER_READINESS_BLOCKER:ATTACH_MISSING:ACCEPTED_TRANSPORT_ATTACH_PASS"
        )
        @Assert(
            gate.blockers[4],
            "PROVIDER_READINESS_BLOCKER:ATTACH_MISSING:PROVIDER_CONTRACT_OR_ALTERNATE_ATTACH_PROOF"
        )
        @Assert(gate.blockers[5], "H1_TLS_PROVIDER_SEAM_NOT_SATISFIED")
        @Assert(gate.decision, "keep-h1-tls-native-seam-open-before-default-mutation")
    }

    @TestCase
    public func testH1TlsNativeSeamCloseGapBlocksRuntimeProofGaps(): Unit {
        let gate =
            buildSocketServerEngineShellH1TlsNativeSeamCloseGapGate(
                SocketServerEngineShellH1TlsNativeSeamCloseGapEvidence(
                    "hq-0573-runtime-proof-gap",
                    hq0572AcceptedH1CleartextDefaultCloseGate(),
                    hq0566CompleteProviderReadinessGate(),
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
                    false
                )
            )

        @Assert(gate.h1TlsNativeSeamReady, false)
        @Assert(gate.requiredProofs[0], "CLOSE_ID")
        @Assert(gate.requiredProofs[7], "ROLLBACK_FALLBACK_PROOF")
        @Assert(gate.blockers[0], "ACCEPTED_TRANSPORT_ATTACH_PASS_PROOF_NOT_CARRIED")
        @Assert(gate.blockers[1], "RUNTIME_SAFE_HANDSHAKE_PROOF_NOT_CARRIED")
        @Assert(gate.blockers[2], "LIVE_LISTEN_ATTACH_PROOF_NOT_CARRIED")
        @Assert(gate.blockers[3], "TLS_CONFIG_SELECTION_PROOF_NOT_CARRIED")
        @Assert(gate.blockers[4], "ROLLBACK_FALLBACK_PROOF_NOT_CARRIED")
    }

    @TestCase
    public func testH1TlsNativeSeamCloseGapBlocksDefaultMutationSourceZeroH1H2AndReleaseOverclaims(): Unit {
        let gate =
            buildSocketServerEngineShellH1TlsNativeSeamCloseGapGate(
                SocketServerEngineShellH1TlsNativeSeamCloseGapEvidence(
                    "hq-0573-overclaim",
                    hq0572AcceptedH1CleartextDefaultCloseGate(),
                    hq0566CompleteProviderReadinessGate(),
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true
                )
            )

        @Assert(gate.h1TlsNativeSeamReady, false)
        @Assert(gate.blockers[0], "DEFAULT_TLS_NATIVE_MUTATION_REQUESTED")
        @Assert(gate.blockers[1], "SOURCE_ZERO_STDX_CLAIMED")
        @Assert(gate.blockers[2], "STDX_REMOVAL_REQUESTED")
        @Assert(gate.blockers[3], "FULL_H1_NATIVE_DEFAULT_REPLACEMENT_CLAIMED")
        @Assert(gate.blockers[4], "H2_RUNTIME_CLOSURE_CLAIMED")
        @Assert(gate.blockers[5], "PUBLIC_RELEASE_OR_HOSTED_PUBLICATION_CLAIMED")
        @Assert(gate.defaultTlsNativeMutationAllowed, false)
    }

    @TestCase
    public func testAppTlsDefaultMutationDryRunAcceptsWithoutMutatingDefault(): Unit {
        let app = App(config: Config(enableNetworkChangeNotice: false))
        let gate = app.appTlsDefaultMutationDryRunGate(
            AppTlsDefaultMutationDryRunEvidence(
                "hq-0574-app-tls-default-mutation-dry-run",
                hq0573AcceptedH1TlsNativeSeamCloseGapGate(),
                true,
                true,
                true,
                true,
                true,
                false,
                false,
                false,
                false,
                false,
                false
            )
        )

        @Assert(gate.dryRunAccepted, true)
        @Assert(gate.status, "app-tls-default-mutation-dry-run-ready")
        @Assert(
            gate.decision,
            "accept-app-tls-default-mutation-dry-run-and-open-apply-gate-packet"
        )
        @Assert(gate.appTlsDefaultMutationDryRunAccepted, true)
        @Assert(gate.actualAppTlsDefaultMutationAllowed, false)
        @Assert(gate.sourceZeroStdxAllowed, false)
        @Assert(gate.stdxRemovalAllowed, false)
        @Assert(gate.fullH1NativeDefaultReplacementAccepted, false)
        @Assert(gate.h2RuntimeClosureAllowed, false)
        @Assert(gate.publicReleaseOrHostedPublicationAllowed, false)
        @Assert(gate.nonClaims[0], "NO_ACTUAL_APP_TLS_DEFAULT_MUTATION")
        @Assert(gate.nonClaims[4], "NO_FULL_H1_NATIVE_DEFAULT_REPLACEMENT_CLAIM")
    }

    @TestCase
    public func testAppTlsDefaultMutationDryRunBlocksWhenSeamIsNotReady(): Unit {
        let blockedSeam = buildSocketServerEngineShellH1TlsNativeSeamCloseGapGate(
            SocketServerEngineShellH1TlsNativeSeamCloseGapEvidence(
                "hq-0574-blocked-seam",
                hq0572AcceptedH1CleartextDefaultCloseGate(),
                hq0566CompleteProviderReadinessGate(),
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
                false
            )
        )
        let gate = buildAppTlsDefaultMutationDryRunGate(
            AppTlsDefaultMutationDryRunEvidence(
                "hq-0574-seam-gap",
                blockedSeam,
                true,
                true,
                true,
                true,
                true,
                false,
                false,
                false,
                false,
                false,
                false
            )
        )

        @Assert(gate.dryRunAccepted, false)
        @Assert(gate.status, "blocked-app-tls-default-mutation-dry-run-gap")
        @Assert(gate.blockers[0], "H1_TLS_NATIVE_SEAM_CLOSE_GAP_NOT_READY")
        @Assert(
            gate.blockers[1],
            "H1_TLS_SEAM_BLOCKER:ACCEPTED_TRANSPORT_ATTACH_PASS_PROOF_NOT_CARRIED"
        )
        @Assert(
            gate.decision,
            "keep-app-tls-default-mutation-blocked-before-apply"
        )
    }

    @TestCase
    public func testAppTlsDefaultMutationDryRunBlocksLocalProofGaps(): Unit {
        let gate = buildAppTlsDefaultMutationDryRunGate(
            AppTlsDefaultMutationDryRunEvidence(
                "hq-0574-proof-gap",
                hq0573AcceptedH1TlsNativeSeamCloseGapGate(),
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
                false
            )
        )

        @Assert(gate.dryRunAccepted, false)
        @Assert(
            gate.requiredProofs[2],
            "TLS_CONFIG_NATIVE_SELECTION_DRY_RUN_PROOF"
        )
        @Assert(
            gate.blockers[0],
            "TLS_CONFIG_NATIVE_SELECTION_DRY_RUN_PROOF_NOT_CARRIED"
        )
        @Assert(gate.blockers[1], "STDX_ROLLBACK_HINT_PROOF_NOT_CARRIED")
        @Assert(gate.blockers[2], "STARTUP_OBSERVATION_PROOF_NOT_CARRIED")
        @Assert(gate.blockers[3], "FOCUSED_REGRESSION_PROOF_NOT_CARRIED")
        @Assert(
            gate.blockers[4],
            "PUBLIC_BASELINE_NON_MUTATION_PROOF_NOT_CARRIED"
        )
    }

    @TestCase
    public func testAppTlsDefaultMutationDryRunBlocksMutationSourceZeroH1H2AndReleaseOverclaims(): Unit {
        let gate = buildAppTlsDefaultMutationDryRunGate(
            AppTlsDefaultMutationDryRunEvidence(
                "hq-0574-overclaim",
                hq0573AcceptedH1TlsNativeSeamCloseGapGate(),
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true
            )
        )

        @Assert(gate.dryRunAccepted, false)
        @Assert(gate.blockers[0], "ACTUAL_APP_TLS_DEFAULT_MUTATION_REQUESTED")
        @Assert(gate.blockers[1], "SOURCE_ZERO_STDX_CLAIMED")
        @Assert(gate.blockers[2], "STDX_REMOVAL_REQUESTED")
        @Assert(gate.blockers[3], "FULL_H1_NATIVE_DEFAULT_REPLACEMENT_CLAIMED")
        @Assert(gate.blockers[4], "H2_RUNTIME_CLOSURE_CLAIMED")
        @Assert(gate.blockers[5], "PUBLIC_RELEASE_OR_HOSTED_PUBLICATION_CLAIMED")
        @Assert(gate.actualAppTlsDefaultMutationAllowed, false)
    }

    @TestCase
    public func testAppTlsDefaultMutationApplyGateAcceptsApplyBoundaryButDoesNotMutateDefault(): Unit {
        let app = App(config: Config(enableNetworkChangeNotice: false))
        let gate = app.appTlsDefaultMutationApplyGate(
            AppTlsDefaultMutationApplyGateEvidence(
                "hq-0575-app-tls-default-mutation-apply-gate",
                hq0574AcceptedAppTlsDefaultMutationDryRunGate(),
                true,
                true,
                true,
                true,
                true,
                false,
                false,
                false,
                false,
                false,
                false,
                false
            )
        )

        @Assert(gate.applyGateAccepted, true)
        @Assert(gate.status, "app-tls-default-mutation-apply-gate-ready")
        @Assert(
            gate.decision,
            "accept-apply-gate-and-open-native-tls-ingress-or-mutation-packet"
        )
        @Assert(gate.nativeSocketTlsListenSupportReady, true)
        @Assert(gate.acceptedTransportLiveIngressReady, true)
        @Assert(gate.appPolicyMutationPlanReady, true)
        @Assert(gate.actualAppTlsDefaultMutationAllowed, false)
        @Assert(gate.nativeTlsLiveIngressImplementationAllowed, false)
        @Assert(gate.sourceZeroStdxAllowed, false)
        @Assert(gate.stdxRemovalAllowed, false)
        @Assert(gate.fullH1NativeDefaultReplacementAccepted, false)
        @Assert(gate.h2RuntimeClosureAllowed, false)
        @Assert(gate.publicReleaseOrHostedPublicationAllowed, false)
        @Assert(gate.nonClaims[0], "NO_ACTUAL_APP_TLS_DEFAULT_MUTATION")
        @Assert(gate.nonClaims[1], "NO_NATIVE_TLS_LIVE_INGRESS_IMPLEMENTATION")
    }

    @TestCase
    public func testAppTlsDefaultMutationApplyGateBlocksRejectedDryRun(): Unit {
        let rejectedDryRun = buildAppTlsDefaultMutationDryRunGate(
            AppTlsDefaultMutationDryRunEvidence(
                "hq-0575-rejected-dry-run",
                hq0573AcceptedH1TlsNativeSeamCloseGapGate(),
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
                false
            )
        )
        let gate = buildAppTlsDefaultMutationApplyGate(
            AppTlsDefaultMutationApplyGateEvidence(
                "hq-0575-dry-run-gap",
                rejectedDryRun,
                true,
                true,
                true,
                true,
                true,
                false,
                false,
                false,
                false,
                false,
                false,
                false
            )
        )

        @Assert(gate.applyGateAccepted, false)
        @Assert(gate.status, "blocked-app-tls-default-mutation-apply-gate")
        @Assert(gate.blockers[0], "APP_TLS_DEFAULT_MUTATION_DRY_RUN_NOT_ACCEPTED")
        @Assert(
            gate.blockers[1],
            "DRY_RUN_BLOCKER:TLS_CONFIG_NATIVE_SELECTION_DRY_RUN_PROOF_NOT_CARRIED"
        )
    }

    @TestCase
    public func testAppTlsDefaultMutationApplyGateBlocksCurrentNativeTlsListenSupportGap(): Unit {
        let gate = buildAppTlsDefaultMutationApplyGate(
            AppTlsDefaultMutationApplyGateEvidence(
                "hq-0575-native-listen-gap",
                hq0574AcceptedAppTlsDefaultMutationDryRunGate(),
                false,
                false,
                true,
                true,
                true,
                false,
                false,
                false,
                false,
                false,
                false,
                false
            )
        )

        @Assert(gate.applyGateAccepted, false)
        @Assert(gate.blockers[0], "NATIVE_SOCKET_TLS_LISTEN_SUPPORT_PROOF_NOT_CARRIED")
        @Assert(gate.blockers[1], "ACCEPTED_TRANSPORT_LIVE_INGRESS_PROOF_NOT_CARRIED")
        @Assert(
            gate.decision,
            "keep-app-tls-default-mutation-blocked-before-native-tls-ingress"
        )
    }

    @TestCase
    public func testAppTlsDefaultMutationApplyGateBlocksMutationImplementationSourceZeroH1H2AndReleaseOverclaims(): Unit {
        let gate = buildAppTlsDefaultMutationApplyGate(
            AppTlsDefaultMutationApplyGateEvidence(
                "hq-0575-overclaim",
                hq0574AcceptedAppTlsDefaultMutationDryRunGate(),
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true
            )
        )

        @Assert(gate.applyGateAccepted, false)
        @Assert(gate.blockers[0], "ACTUAL_APP_TLS_DEFAULT_MUTATION_REQUESTED")
        @Assert(gate.blockers[1], "NATIVE_TLS_LIVE_INGRESS_IMPLEMENTATION_REQUESTED")
        @Assert(gate.blockers[2], "SOURCE_ZERO_STDX_CLAIMED")
        @Assert(gate.blockers[3], "STDX_REMOVAL_REQUESTED")
        @Assert(gate.blockers[4], "FULL_H1_NATIVE_DEFAULT_REPLACEMENT_CLAIMED")
        @Assert(gate.blockers[5], "H2_RUNTIME_CLOSURE_CLAIMED")
        @Assert(gate.blockers[6], "PUBLIC_RELEASE_OR_HOSTED_PUBLICATION_CLAIMED")
        @Assert(gate.actualAppTlsDefaultMutationAllowed, false)
    }

    @TestCase
    public func testAppTlsLiveIngressConsumptionGateAcceptsHq0576FirstCutButDoesNotMutateDefault(): Unit {
        let app = App(config: Config(enableNetworkChangeNotice: false))
        let gate = app.appTlsLiveIngressConsumptionGate(
            AppTlsLiveIngressConsumptionEvidence(
                "hq-0577-app-tls-live-ingress-consumption",
                hq0575AcceptedAppTlsDefaultMutationApplyGate(),
                true,
                true,
                true,
                true,
                true,
                true,
                false,
                false,
                false,
                false,
                false,
                false
            )
        )

        @Assert(gate.consumptionGateAccepted, true)
        @Assert(gate.status, "app-tls-live-ingress-consumption-gate-ready")
        @Assert(
            gate.decision,
            "accept-hq0576-live-ingress-consumption-and-open-app-tls-default-selection-mutation-packet"
        )
        @Assert(gate.nativeTlsLiveIngressFirstCutConsumed, true)
        @Assert(gate.acceptedTransportH2HeadersPlusDataReady, true)
        @Assert(gate.staleNativeIngressBlockerRebased, true)
        @Assert(gate.actualAppTlsDefaultMutationAllowed, false)
        @Assert(gate.sourceZeroStdxAllowed, false)
        @Assert(gate.stdxRemovalAllowed, false)
        @Assert(gate.fullH1NativeDefaultReplacementAccepted, false)
        @Assert(gate.h2RuntimeClosureAllowed, false)
        @Assert(gate.publicReleaseOrHostedPublicationAllowed, false)
        @Assert(gate.nonClaims[0], "NO_ACTUAL_APP_TLS_DEFAULT_MUTATION")
        @Assert(gate.nonClaims[6], "NO_BROWSER_GRADE_TLS_H2_COMPATIBILITY_CLAIM")
    }

    @TestCase
    public func testAppTlsLiveIngressConsumptionGateBlocksMissingHq0576FirstCutProofs(): Unit {
        let gate = buildAppTlsLiveIngressConsumptionGate(
            AppTlsLiveIngressConsumptionEvidence(
                "hq-0577-missing-live-ingress-first-cut",
                hq0575AcceptedAppTlsDefaultMutationApplyGate(),
                false,
                false,
                false,
                true,
                true,
                true,
                false,
                false,
                false,
                false,
                false,
                false
            )
        )

        @Assert(gate.consumptionGateAccepted, false)
        @Assert(gate.status, "blocked-app-tls-live-ingress-consumption-gate")
        @Assert(
            gate.blockers[0],
            "NATIVE_TLS_LIVE_INGRESS_FIRST_CUT_RECEIPT_PROOF_NOT_CARRIED"
        )
        @Assert(
            gate.blockers[1],
            "ACCEPTED_TRANSPORT_H2_HEADERS_PLUS_DATA_PROOF_NOT_CARRIED"
        )
        @Assert(
            gate.blockers[2],
            "STALE_NATIVE_INGRESS_BLOCKER_REBASED_PROOF_NOT_CARRIED"
        )
        @Assert(
            gate.decision,
            "keep-app-tls-default-mutation-blocked-before-live-ingress-consumption"
        )
    }

    @TestCase
    public func testAppTlsLiveIngressConsumptionGateBlocksMutationSourceZeroH1H2AndReleaseOverclaims(): Unit {
        let gate = buildAppTlsLiveIngressConsumptionGate(
            AppTlsLiveIngressConsumptionEvidence(
                "hq-0577-overclaim",
                hq0575AcceptedAppTlsDefaultMutationApplyGate(),
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true
            )
        )

        @Assert(gate.consumptionGateAccepted, false)
        @Assert(gate.blockers[0], "ACTUAL_APP_TLS_DEFAULT_MUTATION_REQUESTED")
        @Assert(gate.blockers[1], "SOURCE_ZERO_STDX_CLAIMED")
        @Assert(gate.blockers[2], "STDX_REMOVAL_REQUESTED")
        @Assert(gate.blockers[3], "FULL_H1_NATIVE_DEFAULT_REPLACEMENT_CLAIMED")
        @Assert(gate.blockers[4], "H2_RUNTIME_CLOSURE_CLAIMED")
        @Assert(gate.blockers[5], "PUBLIC_RELEASE_OR_HOSTED_PUBLICATION_CLAIMED")
        @Assert(gate.actualAppTlsDefaultMutationAllowed, false)
    }

    @TestCase
    public func testAppTlsDefaultSelectionMutationAcceptsTlsDefaultNativeAndRollback(): Unit {
        let app = App(config: Config(enableNetworkChangeNotice: false))
        let gate = app.appTlsDefaultSelectionMutationGate(
            AppTlsDefaultSelectionMutationEvidence(
                "hq-0578-app-tls-default-selection-mutation",
                hq0577AcceptedAppTlsLiveIngressConsumptionGate(),
                true,
                true,
                true,
                true,
                true,
                false,
                false,
                false,
                false,
                false,
                false
            )
        )

        @Assert(gate.mutationAccepted, true)
        @Assert(gate.status, "app-tls-default-selection-mutation-accepted")
        @Assert(
            gate.decision,
            "accept-app-tls-default-selection-mutation-and-preserve-stdx-rollback"
        )
        @Assert(gate.appTlsDefaultSelectionMutated, true)
        @Assert(gate.tlsConfigDefaultNativeSelected, true)
        @Assert(gate.explicitStdxRollbackPreserved, true)
        @Assert(gate.sourceZeroStdxAllowed, false)
        @Assert(gate.stdxRemovalAllowed, false)
        @Assert(gate.fullH1NativeDefaultReplacementAccepted, false)
        @Assert(gate.h2RuntimeClosureAllowed, false)
        @Assert(gate.browserGradeTlsH2CompatibilityAllowed, false)
        @Assert(gate.publicReleaseOrHostedPublicationAllowed, false)
        @Assert(gate.nonClaims[0], "NO_IGNITE0700_PUBLIC_BASELINE_MUTATION")
        @Assert(gate.nonClaims[5], "NO_BROWSER_GRADE_TLS_H2_COMPATIBILITY_CLAIM")
    }

    @TestCase
    public func testAppTlsDefaultSelectionMutationBlocksRejectedConsumptionGate(): Unit {
        let rejectedConsumptionGate = buildAppTlsLiveIngressConsumptionGate(
            AppTlsLiveIngressConsumptionEvidence(
                "hq-0578-rejected-consumption-input",
                hq0575AcceptedAppTlsDefaultMutationApplyGate(),
                false,
                false,
                false,
                true,
                true,
                true,
                false,
                false,
                false,
                false,
                false,
                false
            )
        )
        let gate = buildAppTlsDefaultSelectionMutationGate(
            AppTlsDefaultSelectionMutationEvidence(
                "hq-0578-missing-consumption",
                rejectedConsumptionGate,
                true,
                true,
                true,
                true,
                true,
                false,
                false,
                false,
                false,
                false,
                false
            )
        )

        @Assert(gate.mutationAccepted, false)
        @Assert(gate.status, "blocked-app-tls-default-selection-mutation")
        @Assert(gate.blockers[0], "APP_TLS_LIVE_INGRESS_CONSUMPTION_NOT_ACCEPTED")
        @Assert(
            gate.blockers[1],
            "CONSUMPTION_GATE_BLOCKER:NATIVE_TLS_LIVE_INGRESS_FIRST_CUT_RECEIPT_PROOF_NOT_CARRIED"
        )
        @Assert(gate.decision, "keep-app-tls-default-selection-mutation-blocked")
    }

    @TestCase
    public func testAppTlsDefaultSelectionMutationBlocksSourceZeroH1H2BrowserAndReleaseOverclaims(): Unit {
        let gate = buildAppTlsDefaultSelectionMutationGate(
            AppTlsDefaultSelectionMutationEvidence(
                "hq-0578-overclaim",
                hq0577AcceptedAppTlsLiveIngressConsumptionGate(),
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true
            )
        )

        @Assert(gate.mutationAccepted, false)
        @Assert(gate.blockers[0], "SOURCE_ZERO_STDX_CLAIMED")
        @Assert(gate.blockers[1], "STDX_REMOVAL_REQUESTED")
        @Assert(gate.blockers[2], "FULL_H1_NATIVE_DEFAULT_REPLACEMENT_CLAIMED")
        @Assert(gate.blockers[3], "H2_RUNTIME_CLOSURE_CLAIMED")
        @Assert(gate.blockers[4], "BROWSER_GRADE_TLS_H2_COMPATIBILITY_CLAIMED")
        @Assert(gate.blockers[5], "PUBLIC_RELEASE_OR_HOSTED_PUBLICATION_CLAIMED")
        @Assert(gate.appTlsDefaultSelectionMutated, false)
    }

    @TestCase
    public func testAppServerEngineSelectionPolicyDefaultsTlsConfigToStdxFallback(): Unit {
        let decision = buildAppServerEngineSelectionPolicyDecision(
            Config(
                tlsCertFile: "cert.pem",
                tlsKeyFile: "key.pem",
                enableNetworkChangeNotice: false
            )
        )

        @Assert(decision.tlsConfigured, true)
        @Assert(decision.nativeSocketShellSelected, false)
        @Assert(decision.stdxRollbackSelected, true)
        @Assert(decision.tlsDefaultSelected, false)
        @Assert(decision.selectionLabel, "tls-stdx-fallback")
        @Assert(decision.selectedEngineId, "stdx-http-server")
        @Assert(decision.selectedReason, "tls-provider-gap-default-stdx")
    }

    @TestCase
    public func testAppServerEngineSelectionPolicyAllowsExplicitNativeTlsOptIn(): Unit {
        let decision = buildAppServerEngineSelectionPolicyDecision(
            Config(
                tlsCertFile: "cert.pem",
                tlsKeyFile: "key.pem",
                enableNetworkChangeNotice: false,
                serverPreferredBackendHint: "native-h1",
                allowExperimentalServerBackend: true
            )
        )

        @Assert(decision.tlsConfigured, true)
        @Assert(decision.nativeSocketShellSelected, true)
        @Assert(decision.stdxRollbackSelected, false)
        @Assert(decision.tlsDefaultSelected, false)
        @Assert(decision.configOptInSelected, true)
        @Assert(decision.selectionLabel, "config-opt-in-tls")
        @Assert(decision.selectedEngineId, "ignite-native-h1")
        @Assert(decision.selectedReason, "explicit-native-h1-tls-backend-hint")
    }

    @TestCase
    public func testAppServerEngineSelectionPolicyKeepsExplicitStdxRollbackForTls(): Unit {
        let decision = buildAppServerEngineSelectionPolicyDecision(
            Config(
                tlsCertFile: "cert.pem",
                tlsKeyFile: "key.pem",
                enableNetworkChangeNotice: false,
                serverPreferredBackendHint: "stdx-http-server"
            )
        )

        @Assert(decision.tlsConfigured, true)
        @Assert(decision.nativeSocketShellSelected, false)
        @Assert(decision.stdxRollbackSelected, true)
        @Assert(decision.tlsDefaultSelected, false)
        @Assert(decision.selectionLabel, "stdx-rollback")
        @Assert(decision.selectedEngineId, "stdx-http-server")
        @Assert(decision.selectedReason, "explicit-stdx-backend-hint")
    }
}

func hq0577AcceptedAppTlsLiveIngressConsumptionGate(
): AppTlsLiveIngressConsumptionGate {
    buildAppTlsLiveIngressConsumptionGate(
        AppTlsLiveIngressConsumptionEvidence(
            "hq-0577-accepted-app-tls-live-ingress-consumption",
            hq0575AcceptedAppTlsDefaultMutationApplyGate(),
            true,
            true,
            true,
            true,
            true,
            true,
            false,
            false,
            false,
            false,
            false,
            false
        )
    )
}

func hq0575AcceptedAppTlsDefaultMutationApplyGate(
): AppTlsDefaultMutationApplyGate {
    buildAppTlsDefaultMutationApplyGate(
        AppTlsDefaultMutationApplyGateEvidence(
            "hq-0575-accepted-app-tls-default-mutation-apply-gate",
            hq0574AcceptedAppTlsDefaultMutationDryRunGate(),
            true,
            true,
            true,
            true,
            true,
            false,
            false,
            false,
            false,
            false,
            false,
            false
        )
    )
}

func hq0574AcceptedAppTlsDefaultMutationDryRunGate(
): AppTlsDefaultMutationDryRunGate {
    buildAppTlsDefaultMutationDryRunGate(
        AppTlsDefaultMutationDryRunEvidence(
            "hq-0574-accepted-app-tls-default-mutation-dry-run",
            hq0573AcceptedH1TlsNativeSeamCloseGapGate(),
            true,
            true,
            true,
            true,
            true,
            false,
            false,
            false,
            false,
            false,
            false
        )
    )
}

func hq0573AcceptedH1TlsNativeSeamCloseGapGate(
): SocketServerEngineShellH1TlsNativeSeamCloseGapGate {
    buildSocketServerEngineShellH1TlsNativeSeamCloseGapGate(
        SocketServerEngineShellH1TlsNativeSeamCloseGapEvidence(
            "hq-0573-accepted-h1-tls-native-seam-close-gap",
            hq0572AcceptedH1CleartextDefaultCloseGate(),
            hq0566CompleteProviderReadinessGate(),
            true,
            true,
            true,
            true,
            true,
            false,
            false,
            false,
            false,
            false,
            false
        )
    )
}

func hq0572AcceptedH1CleartextDefaultCloseGate(
): SocketServerEngineShellH1CleartextDefaultCloseGate {
    buildSocketServerEngineShellH1CleartextDefaultCloseGate(
        SocketServerEngineShellH1CleartextDefaultCloseEvidence(
            "hq-0572-accepted-h1-cleartext-default-close",
            hq0571AcceptedH1DefaultMutationReleaseGuard(),
            true,
            true,
            true,
            true,
            true,
            false,
            false,
            false,
            false,
            false
        )
    )
}

func hq0571AcceptedH1DefaultMutationReleaseGuard(
): SocketServerEngineShellH1DefaultMutationReleaseGuard {
    buildSocketServerEngineShellH1DefaultMutationReleaseGuard(
        SocketServerEngineShellH1DefaultMutationReleaseGuardEvidence(
            "hq-0571-accepted-default-mutation-release-guard",
            hq0570AcceptedH1ControlledSwitchGate(),
            "0.8.0",
            "Ignite0800",
            true,
            true,
            true,
            true,
            true,
            true,
            true,
            true,
            false,
            false,
            false,
            false,
            false,
            false,
            false
        )
    )
}

func hq0570AcceptedH1ControlledSwitchGate(
): SocketServerEngineShellH1DefaultEngineControlledSwitchGate {
    buildSocketServerEngineShellH1DefaultEngineControlledSwitchGate(
        SocketServerEngineShellH1DefaultEngineControlledSwitchEvidence(
            "hq-0570-accepted-controlled-switch",
            hq0568AcceptedH1PreflightGate(),
            "ignite-native-h1",
            "stdx-http-server",
            "native-h1",
            true,
            true,
            true,
            true,
            true,
            false,
            false,
            false,
            false,
            false,
            false,
            false
        )
    )
}

func hq0568AcceptedH1PreflightGate(
): SocketServerEngineShellH1DefaultReplacementPreflightGate {
    let providerGate = hq0566CompleteProviderReadinessGate()
    let productionGate =
        buildSocketServerEngineShellProductionCandidateGateWithTlsProviderReadiness(
            SocketServerEngineShellProductionCandidateEvidence(
                2,
                true,
                true,
                true,
                true,
                true
            ),
            providerGate
        )
    let readinessGate = buildSocketServerEngineShellDefaultFlipReadinessGate(
        SocketServerEngineShellDefaultFlipReadinessEvidence(
            productionGate,
            true,
            true,
            true,
            true
        )
    )
    buildSocketServerEngineShellH1DefaultReplacementPreflightGate(
        SocketServerEngineShellH1DefaultReplacementPreflightEvidence(
            "hq-0568-accepted-preflight",
            productionGate,
            readinessGate,
            providerGate,
            true,
            true,
            true,
            true,
            false,
            false,
            false,
            false,
            false,
            false
        )
    )
}
