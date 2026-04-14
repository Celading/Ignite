import ignite.*
import std.env.getVariable
import std.fs.{exists, File, OpenMode}

let H2_WIRE_CERT_FALLBACK = "../_helper/testdata/tls/server-cert-a.pem"
let H2_WIRE_KEY_FALLBACK = "../_helper/testdata/tls/server-key-a.pem"
let H2_WIRE_FIXTURE = "/tmp/ignite_sample_h2_wire_fixture.txt"
let H2_WIRE_HOST = "127.0.0.1"
let H2_WIRE_PORT: UInt16 = 18444
let H2_STREAM_BODY = "chunk-1\nchunk-2\nchunk-3\n"

main() {
    let certFile = resolveTlsPath("IGNITE_SAMPLE_TLS_CERT", H2_WIRE_CERT_FALLBACK)
    let keyFile = resolveTlsPath("IGNITE_SAMPLE_TLS_KEY", H2_WIRE_KEY_FALLBACK)
    if (certFile.size == 0 || keyFile.size == 0) {
        printTlsHint()
        return
    }

    let fixture = buildLargeFixture()
    writeTextFile(H2_WIRE_FIXTURE, fixture)

    let app = App(config: Config(
        appName: "ignite-sample-h2-wire",
        tlsCertFile: certFile,
        tlsKeyFile: keyFile
    ))

    app.get("/health", { ctx =>
        _ = ctx.json(#"{"ok":true,"sample":"h2wire"}"#)
    })

    app.get("/stream", { ctx =>
        _ = ctx
            .status(200)
            .setHeader("content-type", "text/plain; charset=utf-8")
            .setHeader("x-h2-wire-mode", "writer")
        let writer = ctx.writer()
        writer.writeString("chunk-1\n")
        sleep(Duration.millisecond * 80)
        writer.writeString("chunk-2\n")
        sleep(Duration.millisecond * 80)
        writer.writeString("chunk-3\n")
    })

    app.get("/file", { ctx =>
        _ = ctx
            .setHeader("x-h2-wire-mode", "sendFile")
            .setHeader("x-h2-wire-size", fixture.size.toString())
        _ = ctx.sendFile(H2_WIRE_FIXTURE)
    })

    println("[sample/h2wire] listening on https://${H2_WIRE_HOST}:${H2_WIRE_PORT}")
    println("[sample/h2wire] local fixture bytes: ${fixture.size}")
    println("[sample/h2wire] try: curl -k --http2 -i https://${H2_WIRE_HOST}:${H2_WIRE_PORT}/health")
    println("[sample/h2wire] try: curl -k --http2 -N https://${H2_WIRE_HOST}:${H2_WIRE_PORT}/stream")
    println("[sample/h2wire] try: curl -k --http2 -o /tmp/ignite_h2_wire.out -D - https://${H2_WIRE_HOST}:${H2_WIRE_PORT}/file")
    app.listen(H2_WIRE_HOST, H2_WIRE_PORT)
}

func resolveTlsPath(envName: String, fallback: String): String {
    if (let Some(path) <- getVariable(envName)) {
        let trimmed = path.trimAscii()
        if (trimmed.size > 0 && exists(trimmed)) {
            return trimmed
        }
    }
    if (exists(fallback)) {
        return fallback
    }
    ""
}

func printTlsHint(): Unit {
    println("[sample/h2wire] missing TLS certificate or key")
    println("[sample/h2wire] set IGNITE_SAMPLE_TLS_CERT and IGNITE_SAMPLE_TLS_KEY")
    println("[sample/h2wire] local workspace fallback is ${H2_WIRE_CERT_FALLBACK} / ${H2_WIRE_KEY_FALLBACK}")
}

func buildLargeFixture(): String {
    let line = "ignite-h2-wire-file-block-0123456789abcdef\n"
    var out = ""
    for (_ in 0..4096) {
        out += line
    }
    out
}

func writeTextFile(path: String, body: String): Unit {
    let file = File(path, OpenMode.Write)
    file.write(body.toArray())
    file.close()
}
