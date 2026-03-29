package ignite.tests

import ignite.governance.{
    KModeFailoverDecision,
    KModeFailoverOption,
    runKModeFailover
}
import std.collection.ArrayList

@Test
public class KModeFailoverTestSuite {
    @TestCase
    public func testFailoverDisabledReturnsContinue(): Unit {
        let option = KModeFailoverOption(enabled: false)
        let result = runKModeFailover(option, "panic:/health")
        @Assert(result.decision, KModeFailoverDecision.Continue)
        @Assert(result.attempts, 0)
        @Assert(result.matched, false)
    }

    @TestCase
    public func testFailoverMatchReturnsRestart(): Unit {
        let option = KModeFailoverOption(
            enabled: true,
            expectedResponse: "RESTART",
            maxAttempts: 3,
            intervalMs: 0,
            probeHook: { _, _ => Some("RESTART") }
        )
        let result = runKModeFailover(option, "panic:/users")
        @Assert(result.decision, KModeFailoverDecision.Restart)
        @Assert(result.attempts, 1)
        @Assert(result.matched, true)
        @Assert(result.lastStatus, 200)
    }

    @TestCase
    public func testFailoverMissReturnsTerminateAfterMaxAttempts(): Unit {
        let calls = ArrayList<Int64>()
        let option = KModeFailoverOption(
            enabled: true,
            expectedResponse: "RESTART",
            maxAttempts: 4,
            intervalMs: 0,
            terminateOnMiss: true,
            probeHook: { attempt, _ =>
                calls.add(attempt)
                Some("KEEP-RUNNING")
            }
        )

        let result = runKModeFailover(option, "panic:/orders")
        @Assert(result.decision, KModeFailoverDecision.Terminate)
        @Assert(result.matched, false)
        @Assert(result.attempts, 4)
        @Assert(calls.size, 4)
    }

    @TestCase
    public func testFailoverMissCanFallbackToContinue(): Unit {
        let option = KModeFailoverOption(
            enabled: true,
            expectedResponse: "RESTART",
            maxAttempts: 2,
            intervalMs: 0,
            terminateOnMiss: false,
            probeHook: { _, _ => Some("IGNORE") }
        )
        let result = runKModeFailover(option, "panic:/metrics")
        @Assert(result.decision, KModeFailoverDecision.Continue)
        @Assert(result.attempts, 2)
        @Assert(result.matched, false)
    }

    @TestCase
    public func testFailoverNormalizesInvalidTimeoutAndAttempts(): Unit {
        let option = KModeFailoverOption(
            enabled: true,
            probeTimeoutSec: 0,
            maxAttempts: 0,
            intervalMs: -1,
            probeHook: { _, _ => Some("MISS") }
        )
        @Assert(option.probeTimeoutSec, 1)
        @Assert(option.maxAttempts, 1)
        @Assert(option.intervalMs, 0)
    }
}
