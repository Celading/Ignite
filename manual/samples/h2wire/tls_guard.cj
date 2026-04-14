import ignite.api2
import std.env.getVariable
import std.fs.{exists, File, OpenMode}
import std.collection.ArrayList

let H2_WIRE_CERT_FALLBACK = "../_helper/testdata/tls/server-cert-a.pem"
let H2_WIRE_KEY_FALLBACK = "../_helper/testdata/tls/server-key-a.pem"

main() {
    let certFile = resolveTlsPath("IGNITE_SAMPLE_TLS_CERT", H2_WIRE_CERT_FALLBACK)
    let keyFile = resolveTlsPath("IGNITE_SAMPLE_TLS_KEY", H2_WIRE_KEY_FALLBACK)
    if (certFile.size == 0 || keyFile.size == 0) {
        printTlsHint()
        return
    }

    let certPem = readTextFile(certFile)
    let keyPem = readTextFile(keyFile)
    let normalizedAlpn = api2.precheckHttpServerTlsConfigInput(
        certPem,
        keyPem,
        alpnProtocols: ["h2", "http/1.1"],
        requireHttp2Alpn: true
    )
    println("[sample/h2wire] tls guard precheck ok: " + joinText(normalizedAlpn, ","))

    let _ = api2.loadTlsServerConfigForHttp2(
        certPem,
        keyPem,
        alpnProtocols: ["h2", "http/1.1"],
        requireHttp2Alpn: true,
        enablePrecheck: true
    )
    println("[sample/h2wire] tls guard stdx build ok")
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

func readTextFile(path: String): String {
    let file = File(path, OpenMode.Read)
    let out = ArrayList<UInt8>()
    let tmp = Array<UInt8>(4096, repeat: 0)
    while (true) {
        let n = file.read(tmp)
        if (n <= 0) {
            break
        }
        for (i in 0..n) {
            out.add(tmp[i])
        }
    }
    file.close()
    String.fromUtf8(out.toArray())
}

func joinText(values: Array<String>, separator: String): String {
    var out = ""
    var first = true
    for (value in values) {
        if (!first) {
            out += separator
        }
        out += value
        first = false
    }
    out
}
