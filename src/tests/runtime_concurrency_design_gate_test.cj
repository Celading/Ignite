package ignite.tests

import ignite.*

@Test
public class RuntimeConcurrencyDesignGateTestSuite {
    @TestCase
    public func testRuntimeNativeClaimBlockedWhenSchedulerAndIsolationProofsAreMissing(): Unit {
        let gate = buildIgniteRuntimeConcurrencyDesignGate(
            IgniteRuntimeConcurrencyDesignEvidence(
                false,
                false,
                false,
                false,
                false
            )
        )

        @Assert(gate.status, "blocked-runtime-native-claim-gap")
        @Assert(gate.decision, "collect-request-scheduler-and-blocking-isolation-proofs")
        @Assert(gate.cangjieRuntimeNativeClaimAllowed, false)
        @Assert(gate.implementationPacketAllowed, false)
        @Assert(gate.missingProofs[0], "REQUEST_LEVEL_SCHEDULER_PROOF")
        @Assert(gate.missingProofs[3], "BLOCKING_EXTERNAL_OPERATION_ISOLATION_PROOF")
        @Assert(gate.blockers[4], "MISSING:FAIRNESS_BACKPRESSURE_PROOF")
        @Assert(gate.nonClaims[0], "NO_RUNTIME_NATIVE_CLAIM_WITHOUT_SCHEDULER_PROOF")
    }

    @TestCase
    public func testRuntimeImplementationPacketAllowedOnlyAfterAllDesignProofsExist(): Unit {
        let gate = buildIgniteRuntimeConcurrencyDesignGate(
            IgniteRuntimeConcurrencyDesignEvidence(
                true,
                true,
                true,
                true,
                true
            )
        )

        @Assert(gate.status, "ready-for-runtime-concurrency-implementation-packet")
        @Assert(gate.decision, "open-bounded-runtime-scheduler-implementation-packet")
        @Assert(gate.cangjieRuntimeNativeClaimAllowed, true)
        @Assert(gate.implementationPacketAllowed, true)
        @Assert(gate.missingProofs.size, 0)
        @Assert(gate.blockers.size, 0)
        @Assert(gate.nonClaims[3], "NO_PERFORMANCE_CLAIM_WITHOUT_BENCHMARK")
    }
}

