package ignite.tests

import ignite.*
import ignite.middleware.*
import std.collection.ArrayList
import std.fs.exists
import std.net.{IPSocketAddress, TcpServerSocket, TcpSocket}
import std.time.MonoTime
import stdx.net.http.HttpHeaders
import jinguissl.live.{
    ContractTlsRecordChannel,
    contractTls13BuildHttpClientHelloX25519,
    contractTls13CreateClientRecordChannel
}

let NATIVE_TLS_COMMIT_CERT = "testdata/tls/server-cert-a.pem"
let NATIVE_TLS_COMMIT_KEY = "testdata/tls/server-key-a.pem"

@Test
public class NativeTlsResponseCommitTestSuite {
    @TestCase
    public func testAcceptedTlsLiveWriteCommitsBeforeBufferedMiddlewareUnwinds(): Unit {
        let result = runNativeTlsCommitScenario(false)

        @Assert(result.engine.openResponseWire(result.encodedWire), "live-body")
        assertNativeTlsCommitScenario(result)
    }

    @TestCase
    public func testAcceptedTlsCommittedMixedResponsePreservesExistingWireWithoutPostTransform(): Unit {
        let result = runNativeTlsCommitScenario(true)

        @Assert(
            result.engine.openResponseWire(result.encodedWire),
            "buffered-shadowlive-body"
        )
        assertNativeTlsCommitScenario(result)
    }
}

class NativeTlsCommitScenarioResult {
    public let engine: NativeTlsResponseCommitProbeEngine
    public let cacheStore: NativeTlsCommitResponseCacheStore
    public let idempotencyStore: NativeTlsCommitIdempotencyStore
    public let observation: NativeTlsCommitMiddlewareObservation
    public let encodedWire: Array<UInt8>

    public init(
        engine: NativeTlsResponseCommitProbeEngine,
        cacheStore: NativeTlsCommitResponseCacheStore,
        idempotencyStore: NativeTlsCommitIdempotencyStore,
        observation: NativeTlsCommitMiddlewareObservation,
        encodedWire: Array<UInt8>
    ) {
        this.engine = engine
        this.cacheStore = cacheStore
        this.idempotencyStore = idempotencyStore
        this.observation = observation
        this.encodedWire = encodedWire
    }
}

func runNativeTlsCommitScenario(
    includeBufferedResponse: Bool
): NativeTlsCommitScenarioResult {
        let port = reserveNativeTlsCommitPort()
        let cacheStore = NativeTlsCommitResponseCacheStore()
        let idempotencyStore = NativeTlsCommitIdempotencyStore()
        let observation = NativeTlsCommitMiddlewareObservation()
        let app = App(config: Config(
            tlsCertFile: resolveNativeTlsCommitFixturePath(NATIVE_TLS_COMMIT_CERT),
            tlsKeyFile: resolveNativeTlsCommitFixturePath(NATIVE_TLS_COMMIT_KEY),
            enableTlsPrecheck: true,
            enableNetworkChangeNotice: false
        ))
        app.use({ ctx =>
            ctx.next()
            observation.record(ctx)
        })
        app.use(compressMiddleware(config: CompressConfig(minBytes: 0, skipIfNoGain: false)))
        app.use(cacheMiddleware(
            config: CacheConfig(methods: ["POST"]),
            store: Some(cacheStore)
        ))
        app.use(etagMiddleware())
        app.use(idempotencyMiddleware(store: Some(idempotencyStore)))
        app.post("/tls-committed-middleware", { ctx =>
            observation.recordHandlerRun()
            if (includeBufferedResponse) {
                let _ = ctx.sendString("buffered-shadow")
            }
            let writer = ctx.transportWriter()
            writer.write("live-body".toArray())
            closeResponseTransportWriter(writer)
        })
        let engine = NativeTlsResponseCommitProbeEngine()
        app.serverEngine(engine)

        let serverFuture = spawn {
            app.listen("127.0.0.1", port)
        }
        waitForNativeTlsCommitReady(app, port)

        let encodedWire =
            runNativeTlsCommitClient("127.0.0.1", port)
        let _ = serverFuture.get(Duration.second * 5)

        NativeTlsCommitScenarioResult(
            engine,
            cacheStore,
            idempotencyStore,
            observation,
            encodedWire
        )
}

func assertNativeTlsCommitScenario(result: NativeTlsCommitScenarioResult): Unit {
    @Assert(result.engine.responseSocketWriteCount > 0, true)
    @Assert(result.engine.totalEncodedSocketBytes, result.encodedWire.size)
    @Assert(result.engine.responseContentEncoding, "")
    @Assert(result.engine.responseEtag, "")
    @Assert(result.cacheStore.putCalls(), 0)
    @Assert(result.idempotencyStore.putCalls(), 0)
    @Assert(result.observation.handlerRuns(), 1)
    @Assert(result.observation.observations(), 1)
    @Assert(result.observation.allSkippedAfterCommit(), true)
}

class NativeTlsResponseCommitProbeEngine <: ServerEngine {
    public var responseSocketWriteCount: Int64 = 0
    public var totalEncodedSocketBytes: Int64 = 0
    public var responseContentEncoding: String = ""
    public var responseEtag: String = ""
    var clientChannel: ?ContractTlsRecordChannel = None

    public func openResponseWire(encodedWire: Array<UInt8>): String {
        match (clientChannel) {
            case Some(channel) =>
                String.fromUtf8(
                    channel.openAndReassemble(
                        splitJinguiAcceptedTransportRecordWire(
                            nativeTlsCommitByteArray(encodedWire)
                        )
                    )
                )
            case None =>
                throw Exception(
                    "expected client record channel before opening Native TLS response wire"
                )
        }
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }
            let accepted = listener.accept()
            try {
                let clientHello = contractTls13BuildHttpClientHelloX25519(
                    "www.example.com",
                    alpnProtocols: ["http/1.1"],
                    clientPrivateKey: Some(
                        nativeTlsCommitIncrementalBytes(32, start: 928)
                    )
                )
                let headers = HttpHeaders()
                headers.add("accept-encoding", "gzip")
                headers.add("x-idempotency-key", "tls-committed-1")
                let request = ServerJinguiAcceptedTransportLogicalRequest(
                    "POST",
                    "/tls-committed-middleware",
                    versionString: "HTTP/1.1",
                    headers: Some(headers)
                )
                let turn =
                    option.serveJinguiAcceptedTransportSocketLogicalRequest(
                        accepted,
                        app,
                        request,
                        clientHello.encodedClientHello,
                        nativeTlsCommitIncrementalBytes(32, start: 960),
                        transportId: "native-tls-response-commit",
                        maxFragmentLen: 64
                    )
                clientChannel = Some(
                    contractTls13CreateClientRecordChannel(
                        turn.session.keyMaterial,
                        algorithm: turn.session.recordChannel.algorithm
                    )
                )
                responseSocketWriteCount = turn.socketWriteCount
                totalEncodedSocketBytes = turn.totalEncodedSocketBytes
                responseContentEncoding =
                    turn.responseHeaders.getFirst("content-encoding") ?? ""
                responseEtag = turn.responseHeaders.getFirst("etag") ?? ""
            } finally {
                if (!accepted.isClosed()) {
                    accepted.close()
                }
            }
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
        }
    }

    public override func shutdown(): Unit {}
}

class NativeTlsCommitResponseCacheStore <: ResponseCacheStore {
    var putCallCount: Int64 = 0

    public override func getFresh(
        key: String,
        now: MonoTime,
        expiration: Duration
    ): ?ResponseCacheValue {
        None
    }

    public override func put(
        key: String,
        body: String,
        contentType: String,
        now: MonoTime
    ): Unit {
        putCallCount += 1
    }

    public override func cleanupExpired(now: MonoTime, expiration: Duration): Unit {}

    public func putCalls(): Int64 {
        putCallCount
    }
}

class NativeTlsCommitIdempotencyStore <: IdempotencyStore {
    var putCallCount: Int64 = 0

    public override func getFresh(
        key: String,
        now: MonoTime,
        lifetime: Duration
    ): ?IdempotencyValue {
        None
    }

    public override func put(key: String, body: String, now: MonoTime): Unit {
        putCallCount += 1
    }

    public override func cleanupExpired(now: MonoTime, lifetime: Duration): Unit {}

    public func putCalls(): Int64 {
        putCallCount
    }
}

class NativeTlsCommitMiddlewareObservation {
    var handlerRunCount: Int64 = 0
    var observationCount: Int64 = 0
    var compressSkipReason: String = ""
    var etagSkipReason: String = ""
    var cacheSkipReason: String = ""
    var idempotencySkipReason: String = ""

    public func record(ctx: Ctx): Unit {
        observationCount += 1
        compressSkipReason = ctx.getLocal("__ignite_compress_skip_reason") ?? ""
        etagSkipReason = ctx.getLocal("__ignite_etag_skip_reason") ?? ""
        cacheSkipReason = ctx.getLocal("__ignite_cache_skip_reason") ?? ""
        idempotencySkipReason = ctx.getLocal("__ignite_idempotency_skip_reason") ?? ""
    }

    public func recordHandlerRun(): Unit {
        handlerRunCount += 1
    }

    public func handlerRuns(): Int64 {
        handlerRunCount
    }

    public func observations(): Int64 {
        observationCount
    }

    public func allSkippedAfterCommit(): Bool {
        compressSkipReason == "response-committed" &&
            etagSkipReason == "response-committed" &&
            cacheSkipReason == "response-committed" &&
            idempotencySkipReason == "response-committed"
    }
}

func reserveNativeTlsCommitPort(): UInt16 {
    let listener = TcpServerSocket(bindAt: IPSocketAddress.parse("127.0.0.1:0"))
    listener.bind()
    try {
        (listener.localAddress as IPSocketAddress)?.port ??
            throw Exception("could not reserve Native TLS commit test port")
    } finally {
        if (!listener.isClosed()) {
            listener.close()
        }
    }
}

func waitForNativeTlsCommitReady(app: App, port: UInt16): Unit {
    var attempts: Int64 = 0
    while (attempts < 100) {
        match (app.lastServerStartupObserveEvent()) {
            case Some(event) =>
                if (event.phase == "ready" && event.port == port) {
                    return
                }
            case None => ()
        }
        sleep(Duration.millisecond * 10)
        attempts += 1
    }
    @Fail("timed out waiting for Native TLS commit test server")
}

func runNativeTlsCommitClient(host: String, port: UInt16): Array<UInt8> {
    let socket = TcpSocket(IPSocketAddress.parse("${host}:${port}"))
    socket.connect()
    try {
        let out = ArrayList<UInt8>()
        let buf = Array<UInt8>(4096, repeat: 0)
        while (true) {
            let readLen = socket.read(buf)
            if (readLen <= 0) {
                break
            }
            var i: Int64 = 0
            while (i < readLen) {
                out.add(buf[i])
                i += 1
            }
        }
        out.toArray()
    } finally {
        if (!socket.isClosed()) {
            socket.close()
        }
    }
}

func resolveNativeTlsCommitFixturePath(path: String): String {
    if (exists(path)) {
        return path
    }
    let workspacePath = "../" + path
    if (exists(workspacePath)) {
        return workspacePath
    }
    path
}

func nativeTlsCommitIncrementalBytes(
    size: Int64,
    start!: Int64 = 0
): Array<Byte> {
    let out = Array<Byte>(size, repeat: 0)
    var i: Int64 = 0
    while (i < size) {
        out[i] = UInt8((start + i) & 0xff)
        i += 1
    }
    out
}

func nativeTlsCommitByteArray(input: Array<UInt8>): Array<Byte> {
    let out = Array<Byte>(input.size, repeat: 0)
    var i: Int64 = 0
    while (i < input.size) {
        out[i] = input[i]
        i += 1
    }
    out
}
