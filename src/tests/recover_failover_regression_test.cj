package ignite.tests

import ignite.*
import ignite.governance.KModeFailoverOption
import ignite.governance.AuditConfig
import ignite.middleware.*
import std.collection.ArrayList

@Test
public class RecoverFailoverRegressionTestSuite {
    @TestCase
    public func testRecoverRestartDecisionEmitsHeadersAndAuditDetail(): Unit {
        let auditLines = ArrayList<String>()
        let restartHooks = ArrayList<String>()

        let app = App(config: Config(kmode: true))
        let auditConfig = AuditConfig(
            linuxStyle: false,
            redactSensitiveFields: false,
            output: { line => auditLines.add(line) }
        )
        app.use(auditMiddleware(config: AuditMiddlewareConfig(auditConfig: auditConfig)))
        app.use(
            recoverMiddleware(
                config: RecoverConfig(
                    kmodeFailover: KModeFailoverOption(
                        enabled: true,
                        maxAttempts: 1,
                        intervalMs: 0,
                        terminateOnMiss: false,
                        probeHook: { _, _ => Some("RESTART") }
                    ),
                    onKModeRestart: { _, _, result =>
                        restartHooks.add("${result.exitCause}:${result.decision.toString()}")
                    }
                )
            )
        )
        app.get("/panic", { _ => throw Exception("restart-me") })

        let resp = app.handleForTest("GET", "/panic")
        @Assert(resp.status, UInt16(503))
        @Assert(resp.body, "Service Restart Requested")
        @Assert(resp.header("x-ignite-failover-decision") ?? "", "restart")
        @Assert(resp.header("x-ignite-failover-exit-cause") ?? "", "matched")
        @Assert(resp.header("x-ignite-failover-attempts") ?? "", "1")
        @Assert(restartHooks.size, 1)
        @Assert(restartHooks[0], "matched:restart")
        @Assert(auditLines.size > 0, true)
        @Assert(
            contains(
                auditLines[auditLines.size - 1],
                "\"detail\":\"decision=restart;exitCause=matched;attempts=1;matched=true;lastStatus=200;elapsedMs="
            ),
            true
        )
    }

    @TestCase
    public func testRecoverTerminateDecisionEmitsHeadersAndHook(): Unit {
        let terminateHooks = ArrayList<String>()

        let app = App(config: Config(kmode: true))
        app.use(
            recoverMiddleware(
                config: RecoverConfig(
                    kmodeFailover: KModeFailoverOption(
                        enabled: true,
                        maxAttempts: 2,
                        intervalMs: 0,
                        terminateOnMiss: true,
                        probeHook: { _, _ => Some("MISS") }
                    ),
                    onKModeTerminate: { _, _, result =>
                        terminateHooks.add("${result.exitCause}:${result.decision.toString()}:${result.attempts}")
                    }
                )
            )
        )
        app.get("/panic", { _ => throw Exception("terminate-me") })

        let resp = app.handleForTest("GET", "/panic")
        @Assert(resp.status, UInt16(503))
        @Assert(resp.body, "Service Terminated by KMode Failover")
        @Assert(resp.header("x-ignite-failover-decision") ?? "", "terminate")
        @Assert(resp.header("x-ignite-failover-exit-cause") ?? "", "miss")
        @Assert(resp.header("x-ignite-failover-attempts") ?? "", "2")
        @Assert(terminateHooks.size, 1)
        @Assert(terminateHooks[0], "miss:terminate:2")
    }

    func contains(text: String, target: String): Bool {
        let t = text.toRuneArray()
        let p = target.toRuneArray()
        if (p.size == 0) {
            return true
        }
        if (t.size < p.size) {
            return false
        }
        var i: Int64 = 0
        while (i <= t.size - p.size) {
            var ok = true
            var j: Int64 = 0
            while (j < p.size) {
                if (t[i + j] != p[j]) {
                    ok = false
                    break
                }
                j += 1
            }
            if (ok) {
                return true
            }
            i += 1
        }
        false
    }
}
