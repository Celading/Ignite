import ignite.*
import std.env.getVariable

main() {
    let port = UInt16(readPositiveInt64Env("IGNITE_HQ0856_PORT", 18893))
    let app = App(config: Config(
        appName: "ignite-native-h1-small-heap-hardening",
        enableNetworkChangeNotice: false,
        serverBackendPolicy: ServerBackendPolicy.NativeH1
    ))
    let largeBody = buildPreparedLargeHtmlBody()

    app.get("/large", { ctx =>
        _ = ctx
            .setHeader("content-type", "text/html; charset=utf-8")
            .sendPrepared(largeBody)
    })

    app.get("/poll", { ctx =>
        _ = ctx.json(#"{"ok":true,"mode":"poll"}"#)
    })

    app.get("/hold", { ctx =>
        sleep(Duration.millisecond * 300)
        _ = ctx.sendString("held")
    })

    app.get("/metrics", { ctx =>
        _ = ctx.json(app.serverRuntimeSnapshot().toJson())
    })

    spawn {
        while (true) {
            sleep(Duration.millisecond * 500)
            println("[hq0856-runtime] ${app.serverRuntimeSnapshot().toJson()}")
        }
    }

    println("[sample/native-h1-small-heap] listening on http://127.0.0.1:${port}")
    println("[sample/native-h1-small-heap] preparedBodyBytes=${largeBody.size}")
    app.listen("127.0.0.1", port)
}

func buildPreparedLargeHtmlBody(): PreparedResponseBody {
    let pattern = "<section>ignite-native-h1-small-heap-fixture</section>\n".toArray()
    let bytes = Array<UInt8>(512 * 1024, repeat: 0)
    var i: Int64 = 0
    while (i < bytes.size) {
        bytes[i] = pattern[i % pattern.size]
        i += 1
    }
    PreparedResponseBody(bytes)
}

func readPositiveInt64Env(name: String, fallback: Int64): Int64 {
    if (let Some(raw) <- getVariable(name)) {
        if (let Some(parsed) <- parsePositiveInt64(raw)) {
            return parsed
        }
    }
    fallback
}

func parsePositiveInt64(raw: String): ?Int64 {
    let text = raw.trimAscii()
    if (text.size == 0) {
        return None
    }
    let runes = text.toRuneArray()
    var value: Int64 = 0
    var i: Int64 = 0
    while (i < runes.size) {
        let ch = runes[i]
        if (ch < r'0' || ch > r'9') {
            return None
        }
        value = value * 10 + (Int64(UInt32(ch)) - Int64(UInt32(r'0')))
        i += 1
    }
    if (value <= 0 || value > 65535) {
        return None
    }
    Some(value)
}
