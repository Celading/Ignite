package ignite.tests

import ignite.*
import std.fs.exists
import jinguissl.live.{
    ContractAcceptedTransportDescriptor,
    contractTls13BuildHttpClientHelloX25519
}

let HQ0436_ENGINE_TLS_CERT_A = "_helper/testdata/tls/server-cert-a.pem"
let HQ0436_ENGINE_TLS_KEY_A = "_helper/testdata/tls/server-key-a.pem"

@Test
public class ServerJinguiAcceptedTransportReadinessReprobeTestSuite {
    @TestCase
    public func testCurrentSplitJinguiSslReprobeClassifiesTranscriptHashBlocker(): Unit {
        let app = App(config: Config(
            tlsCertFile: hq0436ResolveEngineFixturePath(HQ0436_ENGINE_TLS_CERT_A),
            tlsKeyFile: hq0436ResolveEngineFixturePath(HQ0436_ENGINE_TLS_KEY_A),
            enableTlsPrecheck: true
        ))
        let engine = Hq0436JinguiAcceptedTransportReadinessReprobeEngine()
        app.serverEngine(engine)

        app.listen("127.0.0.1", UInt16(38436))

        @Assert(engine.planAttachSurface, "accepted-socket")
        @Assert(
            hq0436Contains(
                engine.observedError,
                "TLS1.3 transcript hash must be SHA-256 sized"
            ),
            true
        )

        let classification =
            classifyServerJinguiAcceptedTransportTlsAttachBlocker(
                engine.observedError
            )
        @Assert(classification.status, "blocked-provider-contract")
        @Assert(classification.owner, "JinguiSSL-contract")
        @Assert(classification.failureCode, "TLS13_TRANSCRIPT_HASH_SIZE")

        let attachGate = buildServerJinguiAcceptedTransportTlsAttachProofGate(
            ServerJinguiAcceptedTransportTlsAttachProofGateEvidence(
                classification,
                false,
                false,
                false,
                true
            )
        )
        @Assert(attachGate.status, "expected-provider-blocker-carried")
        @Assert(attachGate.diagnosticPacketAllowed, true)
        @Assert(attachGate.h2RuntimeProofAllowed, false)

        let launchGate = buildJinguiAcceptedTransportH2RuntimeProofLaunchGate(
            JinguiAcceptedTransportH2RuntimeProofLaunchEvidence(
                attachGate,
                true,
                true,
                true,
                true
            )
        )
        @Assert(launchGate.status, "diagnostic-only-provider-blocker-carried")
        @Assert(launchGate.diagnosticPacketAllowed, true)
        @Assert(launchGate.h2RuntimeProofLaunchAllowed, false)
        @Assert(launchGate.h2RuntimeClosureClaimAllowed, false)
    }
}

class Hq0436JinguiAcceptedTransportReadinessReprobeEngine <: ServerEngine {
    public var planAttachSurface: String = ""
    public var readyStatus: String = ""
    public var secureSessionReady: Bool = false
    public var negotiatedAlpn: String = ""
    public var requestedServerName: String = ""
    public var acknowledgedServerName: Bool = false
    public var attachSurface: String = ""
    public var transportId: String = ""
    public var observedError: String = ""

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let _ = app
        let transport = ContractAcceptedTransportDescriptor(
            "hq0436-accepted-transport",
            localEndpoint: "127.0.0.1:443",
            remoteEndpoint: "127.0.0.1:55443"
        )
        let clientHello = contractTls13BuildHttpClientHelloX25519(
            "www.example.com",
            alpnProtocols: ["h2", "http/1.1"],
            clientPrivateKey: Some(hq0436IncrementalBytes(32, start: 48))
        )
        let request = option.buildJinguiAcceptedTransportTls13X25519Request(
            transport,
            clientHello.encodedClientHello,
            hq0436IncrementalBytes(32, start: 80)
        )
        planAttachSurface = request.plan.attachSurface

        try {
            let session = option.attachJinguiAcceptedTransportTls13X25519Request(
                request
            )
            let snapshot = option.notifyJinguiAcceptedTransportSession(session)

            readyStatus = snapshot.status
            secureSessionReady = snapshot.secureSessionReady
            negotiatedAlpn = snapshot.jinguiAttachResultSnapshot.negotiatedAlpn
            requestedServerName =
                snapshot.jinguiAttachResultSnapshot.requestedServerName
            acknowledgedServerName =
                snapshot.jinguiAttachResultSnapshot.acknowledgedServerName
            attachSurface = snapshot.jinguiAttachResultSnapshot.attachSurface
            transportId = snapshot.transport.transportId
            let _ = option.closeJinguiAcceptedTransportSession(
                session,
                reason: "hq0436-close"
            )
        } catch (e: Exception) {
            observedError = e.message
        }

        if (let Some(cb) <- onReady) {
            cb(ServerEngineReadySignal())
        }
    }

    public override func shutdown(): Unit {}
}

func hq0436ResolveEngineFixturePath(path: String): String {
    if (exists(path)) {
        return path
    }
    let workspacePath = "../" + path
    if (exists(workspacePath)) {
        return workspacePath
    }
    path
}

func hq0436IncrementalBytes(size: Int64, start!: Int64 = 0): Array<Byte> {
    let out = Array<Byte>(size, repeat: 0)
    var i = 0
    while (i < size) {
        out[i] = UInt8((start + i) & 0xff)
        i += 1
    }
    out
}

func hq0436Contains(text: String, target: String): Bool {
    if (target.size == 0) {
        return true
    }
    if (text.size < target.size) {
        return false
    }
    (text.indexOf(target)).isSome()
}
