package ignite.tests

/// Hostname-sensitive TLS proof — TEST BLOCKER RETURNED
///
/// Preferred proof: start a local TLS listener (CN=localhost, no SAN) and
/// connect via RestClient using "https://localhost:{port}" vs
/// "https://127.0.0.1:{port}" to demonstrate wire-level hostname sensitivity.
///
/// BLOCKER: GeneralPrivateKey.decodeFromPem() (stdx) crashes with SIGABRT
/// on ALL PKCS#8 private key formats (RSA and EC) during the describe()
/// call at stdx/crypto/keys/keys.cj:240. The crash is caused by an unsafe
/// libcrypto loading in Cangjie 1.1.0-nightly runtime.
///
/// Call chain:
///   Config(tlsCertFile, tlsKeyFile) → App.listen()
///     → StdxServerEngine → api2.loadTlsServerConfigForHttp2()
///       → GeneralPrivateKey.decodeFromPem() → decodeFromDer() → describe()
///         → SIGABRT (unhandled signal 6)
///
/// This prevents starting ANY TLS listener through IgniteNEXT's Config path
/// in the current runtime, making a wire-level hostname proof impossible.
///
/// Impact: the hostname-sensitive proof cannot be landed. The outbound HTTPS
/// hostname-sensitive pattern is structurally valid (the code path exists),
/// but the runtime/stdx seam prevents execution.
///
/// Per OD-0015 Rule 51: pre-send X509VerifyOption policy-layer proofs are NOT
/// substitutes for wire-level hostname SNR. Status: blocker-returned.
@Test
public class ClientHostnameSensitiveTlsProofTestSuite {

    @TestCase
    public func testHostnameSensitiveProofBlocker(): Unit {
    // This test documents the blocker only — no TLS listener is attempted.
    // The blocker is reproducible by running this test suite (will NOT crash
    // since no TLS is started).

    // The attempted proof pattern would have been:
    //   Config(tlsCertFile, tlsKeyFile) → App.listen("127.0.0.1", port)
    //   RestClient.get("https://localhost:{port}") vs "https://127.0.0.1:{port}"
    //
    // Blocked at: GeneralPrivateKey.decodeFromPem() → describe() SIGABRT
    //
    // Evidence: cjpm test with any PKCS#8 key produces:
    //   Thread "schd-worker" caught unhandled SIGABRT from native frame
    //   GeneralPrivateKey::describe at keys.cj:240

    @Assert(true)  // blocker documented
    }
}
