package ignite.client

import std.net.{IPSocketAddress, TcpServerSocket}
import std.convert.*
import std.env.getVariable
import std.fs.{File, OpenMode}
import ignite.native_tls.NativeTls13ClientConfig

let NATIVE_TLS_POOL_PRESSURE_HOST = "www." + "example.com"

@Test
public class NativeTlsPoolPressureInternalTestSuite {
    @TestCase
    public func testNativeTlsH1AndH2PoolsSettleAfterRepeatedEncryptedTurns(): Unit {
        nativeTlsPoolPressureWriteMarker("IGNITE_NATIVE_TLS_POOL_START_MARKER")
        let startMs = nativeTlsPoolPressureEnv("IGNITE_NATIVE_TLS_POOL_START_MS", 0, 5000)
        if (startMs > 0) {
            sleep(Duration.millisecond * startMs)
        }
        let turns = nativeTlsPoolPressureTurns()
        let h1 = runNativeTlsH1Pressure(turns)
        let h2 = runNativeTlsH2Pressure(turns)

        @Assert(h1.openedConnections, Int64(1))
        @Assert(h1.reusedConnections, turns - 1)
        @Assert(h1.idleConnections, Int64(0))
        @Assert(h2.openedConnections, Int64(1))
        @Assert(h2.reusedConnections, turns - 1)
        @Assert(h2.idleConnections, Int64(0))
        println(
            "[native-tls-pool-pressure] h1Opened=${h1.openedConnections} " +
            "h1Reused=${h1.reusedConnections} h1Retired=${h1.retiredConnections} " +
            "h2Opened=${h2.openedConnections} h2Reused=${h2.reusedConnections} " +
            "h2Retired=${h2.retiredConnections}"
        )
        nativeTlsPoolPressureWriteMarker("IGNITE_NATIVE_TLS_POOL_SETTLE_MARKER")
        let settleMs = nativeTlsPoolPressureEnv("IGNITE_NATIVE_TLS_POOL_SETTLE_MS", 0, 5000)
        if (settleMs > 0) {
            sleep(Duration.millisecond * settleMs)
        }
    }
}

func nativeTlsPoolPressureWriteMarker(envName: String): Unit {
    if (let Some(path) <- getVariable(envName)) {
        if (path.trimAscii().size > 0) {
            let file = File(path.trimAscii(), OpenMode.Write)
            try {
                file.write("native-tls-pools-settled".toArray())
                file.flush()
            } finally {
                file.close()
            }
        }
    }
}

func nativeTlsPoolPressureTurns(): Int64 {
    nativeTlsPoolPressureEnv("IGNITE_NATIVE_TLS_POOL_TURNS", 64, 4096)
}

func nativeTlsPoolPressureEnv(name: String, fallback: Int64, maximum: Int64): Int64 {
    if (let Some(raw) <- getVariable(name)) {
        try {
            let value = Int64.parse(raw.trimAscii())
            if (value > 0 && value <= maximum) {
                return value
            }
        } catch (_: Exception) {}
    }
    fallback
}

func runNativeTlsH1Pressure(turns: Int64): NativeTlsPoolProtocolSnapshot {
    let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
    listener.bind()
    let port = (listener.localAddress as IPSocketAddress)?.port ??
        throw Exception("native TLS H1 pressure could not reserve loopback port")
    let serverFuture = spawn {
        let accepted = listener.accept()
        accepted.readTimeout = Some(Duration.second * 5)
        accepted.writeTimeout = Some(Duration.second * 5)
        try {
            serveNativeTlsH1ReuseTurnsFixture(accepted, turns)
        } finally {
            try { accepted.close() } catch (_: Exception) {}
        }
    }
    let client = RestClient(
        readTimeout: Duration.second * 5,
        writeTimeout: Duration.second * 5,
        poolSize: 1
    ).nativeTlsIdleTimeout(Duration.second * 5)
        .useNativeTls(NativeTls13ClientConfig(
            nativeTlsTestText("policy_root.pem"),
            NATIVE_TLS_POOL_PRESSURE_HOST,
            intermediatesPemBundle: nativeTlsTestText("policy_intermediate.pem"),
            alpnProtocols: ["http/1.1"],
            requireTargetHostnameMatch: false
        ))
    try {
        for (turn in 1..(turns + 1)) {
            let response = client.get("https://127.0.0.1:${port}/reuse-${turn}")
            @Assert(response.body(), "reuse-h1-${turn}")
        }
        let _ = serverFuture.get(Duration.second * 5)
    } finally {
        client.close()
        try { listener.close() } catch (_: Exception) {}
    }
    client.nativeTlsRuntimeSnapshot().h1
}

func runNativeTlsH2Pressure(turns: Int64): NativeTlsPoolProtocolSnapshot {
    let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
    listener.bind()
    let port = (listener.localAddress as IPSocketAddress)?.port ??
        throw Exception("native TLS H2 pressure could not reserve loopback port")
    let serverFuture = spawn {
        let accepted = listener.accept()
        accepted.readTimeout = Some(Duration.second * 5)
        accepted.writeTimeout = Some(Duration.second * 5)
        try {
            serveNativeTlsH2ReuseTurnsFixture(accepted, turns)
        } finally {
            try { accepted.close() } catch (_: Exception) {}
        }
    }
    let client = RestClient(
        readTimeout: Duration.second * 5,
        writeTimeout: Duration.second * 5,
        poolSize: 1
    ).preferTransportBackend(NATIVE_H2_CLIENT_BACKEND)
        .nativeTlsIdleTimeout(Duration.second * 5)
        .useNativeTls(NativeTls13ClientConfig(
            nativeTlsTestText("policy_root.pem"),
            NATIVE_TLS_POOL_PRESSURE_HOST,
            intermediatesPemBundle: nativeTlsTestText("policy_intermediate.pem"),
            alpnProtocols: ["h2"],
            requireTargetHostnameMatch: false
        ))
    try {
        for (turn in 1..(turns + 1)) {
            let response = client.get("https://127.0.0.1:${port}/reuse-${turn}")
            @Assert(response.body(), "reuse-h2-${turn}")
        }
        let _ = serverFuture.get(Duration.second * 5)
    } finally {
        client.close()
        try { listener.close() } catch (_: Exception) {}
    }
    client.nativeTlsRuntimeSnapshot().h2
}
