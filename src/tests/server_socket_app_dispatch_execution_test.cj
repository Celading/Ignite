package ignite.tests

import ignite.*
import std.collection.ArrayList

@Test
public class ServerSocketAppDispatchExecutionTestSuite {
    @TestCase
    public func testCurrentCarrierHelperPreservesMatchedRouteMiddlewareExecution(): Unit {
        let steps = ArrayList<String>()
        let app = App()
        app.use({ ctx =>
            steps.add("global")
            ctx.next()
        })
        app.get("/chain", [
            { ctx =>
                steps.add("first")
                ctx.next()
            },
            { ctx =>
                steps.add("last")
                let _ = ctx.sendString("ok")
            }
        ])

        let resp = app.handleForTest("GET", "/chain")

        @Assert(resp.status, UInt16(200))
        @Assert(resp.body, "ok")
        @Assert(joinExecutionSteps(steps), "global>first>last")
    }

    @TestCase
    public func testCurrentCarrierHelperPreservesMethodFallbackSemantics(): Unit {
        let app = App()
        app.use({ ctx =>
            let _ = ctx.setHeader("x-global-middleware", "1")
            ctx.next()
        })
        app.get("/users", { ctx =>
            let _ = ctx.sendString("users")
        })
        app.notFound({ ctx =>
            let _ = ctx.sendString("custom-404")
        })
        app.methodNotAllowed({ ctx =>
            let _ = ctx.sendString("custom-405")
        })

        let methodNotAllowedResp = app.handleForTest("POST", "/users")
        let notFoundResp = app.handleForTest("POST", "/missing")

        @Assert(methodNotAllowedResp.status, UInt16(405))
        @Assert(methodNotAllowedResp.body, "custom-405")
        @Assert(methodNotAllowedResp.header("allow") ?? "", "GET")
        @Assert(methodNotAllowedResp.header("x-global-middleware") ?? "", "1")
        @Assert(notFoundResp.status, UInt16(404))
        @Assert(notFoundResp.body, "custom-404")
        @Assert(notFoundResp.header("x-global-middleware") ?? "", "1")
    }

    @TestCase
    public func testCurrentCarrierHelperPreservesKmodeSelfCheckShortCircuit(): Unit {
        let option = RouteOption()
        option.withTestOption(TestOption(
            enabled: true,
            mock: true,
            probe: true,
            storage: "memory",
            report: "inline",
            versionTag: "0700"
        ))

        let app = App(config: Config(kmode: true))
        app.post(
            "/echo",
            { ctx =>
                let _ = ctx.json(#"{"live":true}"#)
            },
            option: option
        )

        let resp = app.handleForTest(
            "POST",
            "/echo?__ignite_test=mock",
            body: #"{"name":"ignite"}"#,
            headers: [("content-type", "application/json")]
        )

        @Assert(resp.status, UInt16(200))
        @Assert(resp.header("x-ignite-self-check") ?? "", "IGTEST-0700")
        @Assert(containsExecutionText(resp.body, #""mode": "mock""#), true)
        @Assert(containsExecutionText(resp.body, #""live":true"#), false)
    }

    @TestCase
    public func testCurrentCarrierHelperPreservesDefaultFiveHundredPath(): Unit {
        let app = App()
        app.get("/panic", { _ =>
            throw Exception("boom")
        })

        let resp = app.handleForTest("GET", "/panic")

        @Assert(resp.status, UInt16(500))
        @Assert(resp.body, "Internal Server Error")
        @Assert(resp.header("content-type") ?? "", "text/plain; charset=utf-8")
    }
}

func joinExecutionSteps(steps: ArrayList<String>): String {
    var out = ""
    var first = true
    for (step in steps) {
        if (!first) {
            out += ">"
        }
        first = false
        out += step
    }
    out
}

func containsExecutionText(text: String, target: String): Bool {
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
