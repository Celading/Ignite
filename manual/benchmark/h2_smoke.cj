import ignite.native_h2.*
import std.collection.ArrayList
import std.convert.*
import std.env.getVariable
import std.net.TcpSocket
import std.time.MonoTime

let H2_SMOKE_HOST = "127.0.0.1"
let H2_SMOKE_PORT: UInt16 = 18880
let H2_SMOKE_EXPECTED = "Hello, Ignite!"

main() {
    let rounds = readPositiveInt64("IGNITE_BENCH_H2_ROUNDS", 32)
    let streamsPerRound = readPositiveInt64("IGNITE_BENCH_H2_STREAMS", 8)
    if (streamsPerRound > 32) {
        throw Exception("IGNITE_BENCH_H2_STREAMS must not exceed 32")
    }
    let socket = connectNativeH2BenchmarkSocket()
    let connection = NativeH2ClientConnection(socket)
    var completed: Int64 = 0
    let started = MonoTime.now()
    try {
        var round: Int64 = 0
        while (round < rounds) {
            let requests = ArrayList<NativeH2ClientRequest>()
            var stream: Int64 = 0
            while (stream < streamsPerRound) {
                requests.add(NativeH2ClientRequest(
                    "GET", "http", "localhost", "/plaintext"
                ))
                stream += 1
            }
            let responses = connection.sendBatch(requests.toArray())
            for (response in responses) {
                if (response.status != UInt16(200)) {
                    throw Exception("Native H2 Benchmark smoke received non-200 response")
                }
                if (String.fromUtf8(response.body) != H2_SMOKE_EXPECTED) {
                    throw Exception("Native H2 Benchmark smoke received an unexpected body")
                }
                completed += 1
            }
            round += 1
        }
        connection.finish()
    } finally {
        if (!socket.isClosed()) {
            socket.close()
        }
    }
    let elapsedMillis = (MonoTime.now() - started).toMilliseconds()
    let requestsPerSecond = if (elapsedMillis > 0) {
        completed * 1000 / elapsedMillis
    } else {
        completed * 1000
    }
    println(
        "{\"schema\":\"ignite-native-h2-smoke-v1\"," +
        "\"backend\":\"native-h2\"," +
        "\"protocol\":\"http/h2-prior-knowledge\"," +
        "\"requests\":${completed},\"errors\":0," +
        "\"rounds\":${rounds},\"streamsPerRound\":${streamsPerRound}," +
        "\"elapsedMillis\":${elapsedMillis}," +
        "\"requestsPerSecond\":${requestsPerSecond}}"
    )
}

func connectNativeH2BenchmarkSocket(): TcpSocket {
    var attempts: Int64 = 0
    while (attempts < 120) {
        let socket = TcpSocket(H2_SMOKE_HOST, H2_SMOKE_PORT)
        socket.readTimeout = Some(Duration.second * 5)
        socket.writeTimeout = Some(Duration.second * 5)
        try {
            socket.connect(timeout: Some(Duration.millisecond * 500))
            return socket
        } catch (_: Exception) {
            if (!socket.isClosed()) {
                socket.close()
            }
            sleep(Duration.millisecond * 250)
            attempts += 1
        }
    }
    throw Exception("Native H2 Benchmark server did not become ready")
}

func readPositiveInt64(name: String, fallback: Int64): Int64 {
    if (let Some(raw) <- getVariable(name)) {
        try {
            let value = Int64.parse(raw.trimAscii())
            if (value > 0) {
                return value
            }
        } catch (_: Exception) {}
    }
    fallback
}
