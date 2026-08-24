package ignite.tests

import ignite.*
import std.collection.{ArrayList, HashMap}
import std.io.InputStream
import stdx.net.http.HttpHeaders

@Test
public class ServerSocketAppDispatchExecutionTestSuite {
    @TestCase
    public func testCurrentCarrierHelperPreservesMatchedRouteMiddlewareExecution(): Unit {
        let steps = ArrayList<String>()
        let app = App()
        app.use({ ctx =>
            steps.add("global")
            ctx.next()
        })
        app.get("/chain", [
            { ctx =>
                steps.add("first")
                ctx.next()
            },
            { ctx =>
                steps.add("last")
                let _ = ctx.sendString("ok")
            }
        ])

        let resp = app.handleForTest("GET", "/chain")

        @Assert(resp.status, UInt16(200))
        @Assert(resp.body, "ok")
        @Assert(joinExecutionSteps(steps), "global>first>last")
    }

    @TestCase
    public func testCurrentCarrierHelperPreservesMethodFallbackSemantics(): Unit {
        let app = App()
        app.use({ ctx =>
            let _ = ctx.setHeader("x-global-middleware", "1")
            ctx.next()
        })
        app.get("/users", { ctx =>
            let _ = ctx.sendString("users")
        })
        app.notFound({ ctx =>
            let _ = ctx.sendString("custom-404")
        })
        app.methodNotAllowed({ ctx =>
            let _ = ctx.sendString("custom-405")
        })

        let methodNotAllowedResp = app.handleForTest("POST", "/users")
        let notFoundResp = app.handleForTest("POST", "/missing")

        @Assert(methodNotAllowedResp.status, UInt16(405))
        @Assert(methodNotAllowedResp.body, "custom-405")
        @Assert(methodNotAllowedResp.header("allow") ?? "", "GET")
        @Assert(methodNotAllowedResp.header("x-global-middleware") ?? "", "1")
        @Assert(notFoundResp.status, UInt16(404))
        @Assert(notFoundResp.body, "custom-404")
        @Assert(notFoundResp.header("x-global-middleware") ?? "", "1")
    }

    @TestCase
    public func testCurrentCarrierHelperPreservesKmodeSelfCheckShortCircuit(): Unit {
        let option = RouteOption()
        option.withTestOption(TestOption(
            enabled: true,
            mock: true,
            probe: true,
            storage: "memory",
            report: "inline",
            versionTag: "0700"
        ))

        let app = App(config: Config(kmode: true))
        app.post(
            "/echo",
            { ctx =>
                let _ = ctx.json(#"{"live":true}"#)
            },
            option: option
        )

        let resp = app.handleForTest(
            "POST",
            "/echo?__ignite_test=mock",
            body: #"{"name":"ignite"}"#,
            headers: [("content-type", "application/json")]
        )

        @Assert(resp.status, UInt16(200))
        @Assert(resp.header("x-ignite-self-check") ?? "", "IGTEST-0700")
        @Assert(containsExecutionText(resp.body, #""mode": "mock""#), true)
        @Assert(containsExecutionText(resp.body, #""live":true"#), false)
    }

    @TestCase
    public func testCurrentCarrierHelperPreservesDefaultFiveHundredPath(): Unit {
        let app = App()
        app.get("/panic", { _ =>
            throw Exception("boom")
        })

        let resp = app.handleForTest("GET", "/panic")

        @Assert(resp.status, UInt16(500))
        @Assert(resp.body, "Internal Server Error")
        @Assert(resp.header("content-type") ?? "", "text/plain; charset=utf-8")
    }

    @TestCase
    public func testCurrentCarrierV2ProvidesRequestMetadataWhileKeepingHttpContextCompatibilitySurface(): Unit {
        let app = App(config: Config(serverPreferredBackendHint: "stdx-default"))
        app.get("/carrier", { ctx =>
            let carrier = ctx.currentRequestCarrier()
            let request = ctx.httpContext().request
            let mode = carrier.requestQueryValue("mode") ?? ""
            let _ = ctx
                .setHeader("x-carrier-method", carrier.requestMethod())
                .sendString(carrier.requestMethod() + ":" + carrier.requestPath() + ":" + mode + ":" + request.url.path)
        })

        let resp = app.handleForTest("GET", "/carrier?mode=full")

        @Assert(resp.status, UInt16(200))
        @Assert(resp.header("x-carrier-method") ?? "", "GET")
        @Assert(resp.body, "GET:/carrier:full:/carrier")
    }

    @TestCase
    public func testCoreCarrierRejectsOptionalRawHttpContextCompatibilityWithoutProvider(): Unit {
        let carrier = DispatchEntryTrackingCarrier("GET", "/carrier-entry")
        let ctx = Ctx(carrier, App())

        try {
            let _ = ctx.httpContext()
            @Fail("core-only carrier should not expose stdx HttpContext compatibility")
        } catch (e: Exception) {
            @Assert(
                e.message,
                "current request carrier does not expose stdx HttpContext compatibility"
            )
        }
    }

    @TestCase
    public func testWebSocketUpgradeUsesCarrierSeamWithoutEagerRawHttpContextFetch(): Unit {
        let carrier = WebSocketUpgradeSentinelCarrier()
        let ctx = Ctx(carrier, App())

        try {
            let _ = ctx.upgradeWebSocket()
            @Fail("websocket upgrade should stop at the carrier seam sentinel")
        } catch (_: WebSocketUpgradeSentinelException) {}

        @Assert(carrier.upgradeWebSocketCalls, Int64(1))
        @Assert(carrier.subProtocols.size, Int64(0))
        @Assert(
            carrier.maxIncomingMessageBytes,
            WebSocketOptions().maxIncomingMessageBytes
        )
    }

    @TestCase
    public func testWebSocketUpgradeCapabilityForwardsSubProtocolsAndOptions(): Unit {
        let carrier = WebSocketUpgradeSentinelCarrier()
        let ctx = Ctx(carrier, App())

        try {
            let _ = ctx.upgradeWebSocketWithSubProtocolsAndOptions(
                ["chat.v2", "chat.v1"],
                WebSocketOptions(maxIncomingMessageBytes: 2048)
            )
            @Fail("websocket upgrade should stop at the carrier seam sentinel")
        } catch (_: WebSocketUpgradeSentinelException) {}

        @Assert(carrier.upgradeWebSocketCalls, Int64(1))
        @Assert(carrier.subProtocols.size, Int64(2))
        @Assert(carrier.subProtocols[0], "chat.v2")
        @Assert(carrier.subProtocols[1], "chat.v1")
        @Assert(carrier.maxIncomingMessageBytes, Int64(2048))
    }

    @TestCase
    public func testCoreCarrierRejectsOptionalWebSocketUpgradeWithoutProvider(): Unit {
        let carrier = DispatchEntryTrackingCarrier("GET", "/carrier-entry")
        let ctx = Ctx(carrier, App())

        try {
            let _ = ctx.upgradeWebSocket()
            @Fail("core-only carrier should not expose WebSocket upgrade capability")
        } catch (e: Exception) {
            @Assert(
                e.message,
                "current request carrier does not expose WebSocket upgrade capability"
            )
        }
    }

    @TestCase
    public func testHandleRequestDispatchesThroughCarrierEntryWithoutRawHttpContext(): Unit {
        let app = App()
        app.get("/carrier-entry", { ctx =>
            let _ = ctx
                .setHeader("x-entry", "1")
                .sendString("ok-entry")
        })

        let carrier = DispatchEntryTrackingCarrier("GET", "/carrier-entry")
        app.handleRequest(carrier)

        @Assert(carrier.responseStatus, UInt16(200))
        @Assert(carrier.header("content-type") ?? "", "text/plain; charset=utf-8")
        @Assert(carrier.header("x-entry") ?? "", "1")
        @Assert(carrier.responseBody, "ok-entry")
    }

    @TestCase
    public func testHandleRequestDefaultFiveHundredPathNoLongerNeedsRawHttpContext(): Unit {
        let app = App()
        app.get("/panic-entry", { _ =>
            throw Exception("panic-entry")
        })

        let carrier = DispatchEntryTrackingCarrier("GET", "/panic-entry")
        app.handleRequest(carrier)

        @Assert(carrier.responseStatus, UInt16(500))
        @Assert(carrier.header("content-type") ?? "", "text/plain; charset=utf-8")
        @Assert(carrier.responseBody, "Internal Server Error")
    }

    @TestCase
    public func testResponseWriterOpensThroughCarrierTransportWriterSeamWithoutRawHttpContext(): Unit {
        let carrier = ResponseTransportSeamTrackingCarrier()
        let writer = ResponseWriter(carrier)
        writer.writeString("stream-body")

        @Assert(carrier.responseTransportOpenCalls, Int64(1))
        @Assert(carrier.responseTransportWriteCalls, Int64(1))
        @Assert(carrier.responseTransportBody, "stream-body")
        @Assert(carrier.header("transfer-encoding") ?? "", "chunked")
    }

    @TestCase
    public func testCtxTransportWriterUsesCarrierSeamWithoutChunkedHeaderMutation(): Unit {
        let carrier = ResponseTransportSeamTrackingCarrier()
        let ctx = Ctx(carrier, App())
        let writer = ctx.transportWriter()
        writer.write("transport-body".toArray())

        @Assert(carrier.responseTransportOpenCalls, Int64(1))
        @Assert(carrier.responseTransportWriteCalls, Int64(1))
        @Assert(carrier.responseTransportBody, "transport-body")
        @Assert(carrier.header("transfer-encoding") ?? "", "")
    }

    @TestCase
    public func testCtxTransportOutputStreamUsesCarrierSeamWithoutChunkedHeaderMutation(): Unit {
        let carrier = ResponseTransportSeamTrackingCarrier()
        let ctx = Ctx(carrier, App())
        let out = ctx.transportOutputStream()
        out.write(toDispatchTestByteArray("transport-out".toArray()))

        @Assert(carrier.responseTransportOpenCalls, Int64(1))
        @Assert(carrier.responseTransportWriteCalls, Int64(1))
        @Assert(carrier.responseTransportBody, "transport-out")
        @Assert(carrier.header("transfer-encoding") ?? "", "")
    }
}

func joinExecutionSteps(steps: ArrayList<String>): String {
    var out = ""
    var first = true
    for (step in steps) {
        if (!first) {
            out += ">"
        }
        first = false
        out += step
    }
    out
}

func toDispatchTestByteArray(input: Array<UInt8>): Array<Byte> {
    let out = Array<Byte>(input.size, repeat: 0)
    var i: Int64 = 0
    while (i < input.size) {
        out[i] = input[i]
        i += 1
    }
    out
}

func containsExecutionText(text: String, target: String): Bool {
    let t = text.toRuneArray()
    let p = target.toRuneArray()
    if (p.size == 0) {
        return true
    }
    if (t.size < p.size) {
        return false
    }
    var i: Int64 = 0
    while (i <= t.size - p.size) {
        var ok = true
        var j: Int64 = 0
        while (j < p.size) {
            if (t[i + j] != p[j]) {
                ok = false
                break
            }
            j += 1
        }
        if (ok) {
            return true
        }
        i += 1
    }
    false
}

class WebSocketUpgradeSentinelException <: Exception {
    init(message: String) {
        super(message)
    }
}

class WebSocketUpgradeSentinelCarrier <: CurrentRequestCarrier & WebSocketUpgradeCarrier {
    public var upgradeWebSocketCalls: Int64 = 0
    public var subProtocols: Array<String> = []
    public var maxIncomingMessageBytes: Int64 = 0
    let body = EmptyCarrierInputStream()

    public override func upgradeWebSocket(
        subProtocols: Array<String>,
        options: WebSocketOptions
    ): WsConn {
        this.subProtocols = subProtocols
        maxIncomingMessageBytes = options.maxIncomingMessageBytes
        upgradeWebSocketCalls += 1
        throw WebSocketUpgradeSentinelException("carrier upgrade seam reached")
    }

    public override func openResponseTransportWriterRaw(): ResponseTransportWriter {
        throw Exception("response transport writer should not open in websocket upgrade test")
    }

    public override func requestMethod(): String {
        "GET"
    }

    public override func requestPath(): String {
        "/ws"
    }

    public override func requestUrlString(): String {
        "/ws"
    }

    public override func requestVersionString(): String {
        "HTTP/1.1"
    }

    public override func requestRemoteAddr(): String {
        "127.0.0.1"
    }

    public override func requestQueryValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestFormValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestHeaderValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestHeaderFields(): Array<(String, String)> {
        []
    }

    public override func requestTrailerValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestTrailerFields(): Array<(String, String)> {
        []
    }

    public override func requestBodyStream(): InputStream {
        body
    }

    public override func requestBodySize(): ?Int64 {
        Some(Int64(0))
    }

    public override func setResponseStatus(code: UInt16): Unit {
        let _ = code
    }

    public override func setResponseHeader(key: String, value: String): Unit {
        let _ = key
        let _ = value
    }

    public override func addResponseHeader(key: String, value: String): Unit {
        let _ = key
        let _ = value
    }

    public override func setResponseString(body: String): Unit {
        let _ = body
    }

    public override func setResponseBytes(data: Array<UInt8>): Unit {
        let _ = data
    }

    public override func attachResponseBodyStream(stream: InputStream): Unit {
        let _ = stream
    }
}

class EmptyCarrierInputStream <: InputStream {
    public override func read(outBuf: Array<Byte>): Int64 {
        let _ = outBuf
        0
    }

    public func close(): Unit {}
}

class DispatchEntryTrackingCarrier <: CurrentRequestCarrier {
    let methodText: String
    let pathText: String
    let body = EmptyCarrierInputStream()
    let responseHeaders = HashMap<String, String>()
    public var responseStatus: UInt16 = 200
    public var responseBody: String = ""

    init(methodText: String, pathText: String) {
        this.methodText = methodText
        this.pathText = pathText
    }

    public func header(name: String): ?String {
        responseHeaders.get(name.trimAscii().toAsciiLower())
    }

    public override func openResponseTransportWriterRaw(): ResponseTransportWriter {
        throw Exception("response transport writer should not open in dispatch entry tests")
    }

    public override func requestMethod(): String {
        methodText
    }

    public override func requestPath(): String {
        pathText
    }

    public override func requestUrlString(): String {
        pathText
    }

    public override func requestVersionString(): String {
        "HTTP/1.1"
    }

    public override func requestRemoteAddr(): String {
        "127.0.0.1"
    }

    public override func requestQueryValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestFormValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestHeaderValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestHeaderFields(): Array<(String, String)> {
        []
    }

    public override func requestTrailerValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestTrailerFields(): Array<(String, String)> {
        []
    }

    public override func requestBodyStream(): InputStream {
        body
    }

    public override func requestBodySize(): ?Int64 {
        Some(Int64(0))
    }

    public override func setResponseStatus(code: UInt16): Unit {
        responseStatus = code
    }

    public override func setResponseHeader(key: String, value: String): Unit {
        responseHeaders.add(key.trimAscii().toAsciiLower(), value)
    }

    public override func addResponseHeader(key: String, value: String): Unit {
        responseHeaders.add(key.trimAscii().toAsciiLower(), value)
    }

    public override func setResponseString(body: String): Unit {
        responseBody = body
    }

    public override func setResponseBytes(data: Array<UInt8>): Unit {
        responseBody = String.fromUtf8(data)
    }

    public override func attachResponseBodyStream(stream: InputStream): Unit {
        let _ = stream
    }
}

class ResponseTransportSeamTrackingCarrier <: CurrentRequestCarrier {
    let body = EmptyCarrierInputStream()
    let responseHeaders = HashMap<String, String>()
    public var responseTransportOpenCalls: Int64 = 0
    public var responseTransportWriteCalls: Int64 = 0
    public var responseTransportBody: String = ""
    public var responseStatus: UInt16 = 200

    public func header(name: String): ?String {
        responseHeaders.get(name.trimAscii().toAsciiLower())
    }

    public override func openResponseTransportWriterRaw(): ResponseTransportWriter {
        responseTransportOpenCalls += 1
        TrackingResponseTransportWriter(this)
    }

    public override func requestMethod(): String {
        "GET"
    }

    public override func requestPath(): String {
        "/transport"
    }

    public override func requestUrlString(): String {
        "/transport"
    }

    public override func requestVersionString(): String {
        "HTTP/1.1"
    }

    public override func requestRemoteAddr(): String {
        "127.0.0.1"
    }

    public override func requestQueryValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestFormValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestHeaderValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestHeaderFields(): Array<(String, String)> {
        []
    }

    public override func requestTrailerValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestTrailerFields(): Array<(String, String)> {
        []
    }

    public override func requestBodyStream(): InputStream {
        body
    }

    public override func requestBodySize(): ?Int64 {
        Some(Int64(0))
    }

    public override func setResponseStatus(code: UInt16): Unit {
        responseStatus = code
    }

    public override func setResponseHeader(key: String, value: String): Unit {
        responseHeaders.add(key.trimAscii().toAsciiLower(), value)
    }

    public override func addResponseHeader(key: String, value: String): Unit {
        responseHeaders.add(key.trimAscii().toAsciiLower(), value)
    }

    public override func setResponseString(body: String): Unit {
        let _ = body
    }

    public override func setResponseBytes(data: Array<UInt8>): Unit {
        let _ = data
    }

    public override func attachResponseBodyStream(stream: InputStream): Unit {
        let _ = stream
    }
}

class TrackingResponseTransportWriter <: ResponseTransportWriter {
    let carrier: ResponseTransportSeamTrackingCarrier

    init(carrier: ResponseTransportSeamTrackingCarrier) {
        this.carrier = carrier
    }

    public override func write(data: Array<UInt8>): Unit {
        carrier.responseTransportWriteCalls += 1
        carrier.responseTransportBody += String.fromUtf8(data)
    }
}
