import ignite.*
import std.env.getVariable

let BENCH_HOST = "127.0.0.1"
let BENCH_PORT: UInt16 = 18880
let BENCH_LARGE_BODY = buildRepeatedBody("0123456789abcdef", 4096)

main() {
    let backendHint = resolveBackendHint()
    let config = Config(
        appName: "ignite-0800-benchmark",
        serverPreferredBackendHint: backendHint
    )
    let decision = buildAppServerEngineSelectionPolicyDecision(config)
    let app = App(config: config)

    app.get("/health", { ctx =>
        _ = ctx.sendString("ok")
    })

    app.get("/plaintext", { ctx =>
        _ = ctx.sendString("Hello, Ignite!")
    })

    app.get("/json", { ctx =>
        _ = ctx.json(#"{"framework":"ignite","version":"0.8.0","ok":true}"#)
    })

    app.get("/bytes/64k", { ctx =>
        _ = ctx
            .setHeader("content-type", "application/octet-stream")
            .sendString(BENCH_LARGE_BODY)
    })

    println("[benchmark] backend=${decision.selectedEngineId}")
    println("[benchmark] listening on http://${BENCH_HOST}:${BENCH_PORT}")
    app.listen(BENCH_HOST, BENCH_PORT)
}

func resolveBackendHint(): String {
    if (let Some(raw) <- getVariable("IGNITE_BENCH_BACKEND")) {
        let backend = raw.trimAscii().toAsciiLower()
        if (backend == "stdx" || backend == "stdx-default") {
            return "stdx-default"
        }
    }
    ""
}

func buildRepeatedBody(part: String, count: Int64): String {
    var body = ""
    for (_ in 0..count) {
        body += part
    }
    body
}
