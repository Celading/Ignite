import ignite.*
import ignite.native_h2.useExperimentalNativeH2ServerEngine
import std.env.getVariable

let BENCH_HOST = "127.0.0.1"
let BENCH_PORT: UInt16 = 18880
let BENCH_BODY_64K = buildRepeatedBody("0123456789abcdef", 4096)
let BENCH_BODY_256K = buildRepeatedBody("0123456789abcdef", 16384)
let BENCH_BODY_1024K = buildRepeatedBody("0123456789abcdef", 65536)
let BENCH_PREPARED_BODY_64K = PreparedResponseBody(BENCH_BODY_64K)
let BENCH_PREPARED_BODY_256K = PreparedResponseBody(BENCH_BODY_256K)
let BENCH_PREPARED_BODY_1024K = PreparedResponseBody(BENCH_BODY_1024K)

main() {
    let backend = resolveBackend()
    let backendHint = if (backend == "stdx") { "stdx-default" } else { "" }
    let config = Config(
        appName: "ignite-0800-benchmark",
        serverPreferredBackendHint: backendHint
    )
    let decision = buildAppServerEngineSelectionPolicyDecision(config)
    let app = App(config: config)
    if (backend == "native-h2") {
        useExperimentalNativeH2ServerEngine(app)
    }

    app.get("/health", { ctx =>
        _ = ctx.sendString("ok")
    })

    app.get("/plaintext", { ctx =>
        _ = ctx.sendString("Hello, Ignite!")
    })

    app.get("/h2/request-headers", { ctx =>
        let userAgent = ctx.header("user-agent") ?? ""
        let accept = ctx.header("accept") ?? ""
        let probe = ctx.header("x-ignite-probe") ?? ""
        _ = ctx.sendString(userAgent + "|" + accept + "|" + probe)
    })

    app.head("/h2/head", { ctx =>
        _ = ctx.sendString("must-not-reach-wire")
    })

    app.post("/h2/request-trailers", { ctx =>
        let trailer = ctx.trailer("x-ignite-trailer") ?? ""
        _ = ctx.sendString(ctx.bodyString() + "|" + trailer)
    })

    app.post("/h2/request-size", { ctx =>
        _ = ctx.sendString(ctx.bodyString().size.toString())
    })

    app.get("/json", { ctx =>
        _ = ctx.json(#"{"framework":"ignite","version":"0.8.2","ok":true}"#)
    })

    app.get("/bytes/64k", { ctx =>
        _ = ctx
            .setHeader("content-type", "application/octet-stream")
            .sendPrepared(BENCH_PREPARED_BODY_64K)
    })

    app.get("/bytes/256k", { ctx =>
        _ = ctx
            .setHeader("content-type", "application/octet-stream")
            .sendPrepared(BENCH_PREPARED_BODY_256K)
    })

    app.get("/bytes/1024k", { ctx =>
        _ = ctx
            .setHeader("content-type", "application/octet-stream")
            .sendPrepared(BENCH_PREPARED_BODY_1024K)
    })

    let selectedBackend = if (backend == "native-h2") {
        "ignite-native-h2"
    } else {
        decision.selectedEngineId
    }
    println("[benchmark] backend=${selectedBackend}")
    println("[benchmark] listening on http://${BENCH_HOST}:${BENCH_PORT}")
    app.listen(BENCH_HOST, BENCH_PORT)
}

func resolveBackend(): String {
    if (let Some(raw) <- getVariable("IGNITE_BENCH_BACKEND")) {
        let backend = raw.trimAscii().toAsciiLower()
        if (backend == "stdx" || backend == "stdx-default") {
            return "stdx"
        }
        if (backend == "native-h2" || backend == "h2") {
            return "native-h2"
        }
    }
    "native"
}

func buildRepeatedBody(part: String, count: Int64): String {
    var body = ""
    var block = part
    var remaining = count
    while (remaining > 0) {
        if (remaining % 2 == 1) {
            body += block
        }
        remaining /= 2
        if (remaining > 0) {
            block += block
        }
    }
    body
}
