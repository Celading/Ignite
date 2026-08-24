package ignite.native_h2

import ignite.{
    App,
    CurrentRequestCarrier,
    ResponseCommitStateCarrier,
    ResponseTransportLifecycle,
    ResponseTransportWriter
}
import std.collection.{ArrayList, HashMap}
import std.io.InputStream
import std.net.TcpSocket
import stdx.net.http.{HttpContext, HttpHeaders, WebSocket}

/// Serves the first native H2 stream through Ignite's existing App dispatch.
public func serveNativeH2SingleStreamApp(
    socket: TcpSocket,
    app: App,
    remoteAddress!: String = ""
): Unit {
    serveNativeH2LiveSingleStreamTransport(
        NativeH2TcpTransport(socket), { request, headCommit, dataCommit =>
        let carrier = NativeH2AppCurrentRequestCarrier(
            request, remoteAddress,
            responseHeadCommit: Some(headCommit),
            responseDataCommit: Some(dataCommit)
        )
        app.handleRequest(carrier)
        carrier.response()
    }, maxRequestBodySize: app.config.bodyLimit)
}

/// Serves multiple native H2 streams through the existing Ignite App dispatch.
public func serveNativeH2AppConnection(
    socket: TcpSocket,
    app: App,
    remoteAddress!: String = "",
    maxCompletedStreams!: Int64 = 0,
    control!: ?NativeH2ConnectionControl = None
): Unit {
    serveNativeH2AppTransportConnection(
        NativeH2TcpTransport(socket), app,
        remoteAddress: remoteAddress,
        maxCompletedStreams: maxCompletedStreams,
        control: control
    )
}

/// Serves native H2 App traffic over an already-decoded byte transport.
public func serveNativeH2AppTransportConnection(
    transport: NativeH2DuplexTransport,
    app: App,
    remoteAddress!: String = "",
    maxCompletedStreams!: Int64 = 0,
    control!: ?NativeH2ConnectionControl = None
): Unit {
    serveNativeH2LiveTransportConnection(transport, { request, headCommit, dataCommit =>
        let carrier = NativeH2AppCurrentRequestCarrier(
            request, remoteAddress,
            responseHeadCommit: Some(headCommit),
            responseDataCommit: Some(dataCommit)
        )
        app.handleRequest(carrier)
        carrier.response()
    }, maxCompletedStreams: maxCompletedStreams, control: control,
        maxRequestBodySize: app.config.bodyLimit)
}

func serveTrackedNativeH2AppConnection(
    socket: TcpSocket,
    app: App,
    remoteAddress: String,
    control: NativeH2ConnectionControl
): Unit {
    nativeH2ServeTransportConnection(NativeH2TcpTransport(socket), { request =>
        let carrier = NativeH2AppCurrentRequestCarrier(request, remoteAddress)
        app.handleRequest(carrier)
        carrier.response()
    }, control: Some(control), maxRequestBodySize: app.config.bodyLimit,
        liveHandler: Some({ request, headCommit, dataCommit =>
            let carrier = NativeH2AppCurrentRequestCarrier(
                request, remoteAddress,
                responseHeadCommit: Some(headCommit),
                responseDataCommit: Some(dataCommit)
            )
            app.handleRequest(carrier)
            carrier.response()
        }))
}

class NativeH2AppBytesInputStream <: InputStream {
    let bytes: Array<UInt8>
    var offset: Int64 = 0

    init(bytes: Array<UInt8>) {
        this.bytes = nativeH2Clone(bytes)
    }

    public override func read(outBuf: Array<Byte>): Int64 {
        if (offset >= bytes.size || outBuf.size == 0) {
            return 0
        }
        let remaining = bytes.size - offset
        let count = if (remaining < outBuf.size) { remaining } else { outBuf.size }
        var i: Int64 = 0
        while (i < count) {
            outBuf[i] = bytes[offset + i]
            i += 1
        }
        offset += count
        count
    }
}

class NativeH2AppResponseTransportWriter <: ResponseTransportWriter & ResponseTransportLifecycle {
    let carrier: NativeH2AppCurrentRequestCarrier
    var closed: Bool = false

    init(carrier: NativeH2AppCurrentRequestCarrier) {
        this.carrier = carrier
    }

    public override func write(data: Array<UInt8>): Unit {
        if (closed) {
            throw Exception("response transport writer is closed")
        }
        carrier.commitResponseHead()
        carrier.commitResponseData(data)
    }

    public override func flush(): Unit {
        if (closed) {
            throw Exception("response transport writer is closed")
        }
        carrier.commitResponseHead()
    }

    public override func close(): Unit {
        if (closed) {
            return
        }
        closed = true
        carrier.commitResponseHead()
        carrier.commitResponseEnd()
    }
}

class NativeH2AppCurrentRequestCarrier <: CurrentRequestCarrier & ResponseCommitStateCarrier {
    let request: NativeH2SingleStreamRequest
    let remoteAddress: String
    let requestPathValue: String
    let queryStringValue: String
    let requestHeadersValue: HttpHeaders
    let requestTrailersValue: HttpHeaders
    let responseHeadersValue = HashMap<String, ArrayList<String>>()
    var responseStatusValue: UInt16 = 200
    var responseBodyValue = ArrayList<UInt8>()
    var responseBodyStreamValue: ?InputStream = None
    let responseHeadCommit: ?NativeH2ResponseHeadCommit
    let responseDataCommit: ?NativeH2ResponseDataCommit

    init(
        request: NativeH2SingleStreamRequest,
        remoteAddress: String,
        responseHeadCommit!: ?NativeH2ResponseHeadCommit = None,
        responseDataCommit!: ?NativeH2ResponseDataCommit = None
    ) {
        this.request = request
        this.remoteAddress = remoteAddress
        let targetParts = request.path.split("?", 2)
        this.requestPathValue = if (targetParts.size > 0 && targetParts[0].size > 0) {
            targetParts[0]
        } else {
            "/"
        }
        this.queryStringValue = if (targetParts.size == 2) { targetParts[1] } else { "" }
        let headers = HttpHeaders()
        headers.add("host", request.authority)
        for (header in request.headers) {
            headers.add(header.name, header.value)
        }
        this.requestHeadersValue = headers
        let trailers = HttpHeaders()
        for (trailer in request.trailers) {
            trailers.add(trailer.name, trailer.value)
        }
        this.requestTrailersValue = trailers
        this.responseHeadCommit = responseHeadCommit
        this.responseDataCommit = responseDataCommit
    }

    public override func rawHttpContext(): HttpContext {
        throw Exception("native H2 App carrier does not expose raw HttpContext")
    }

    public override func upgradeWebSocketRaw(): WebSocket {
        throw Exception("native H2 first slice does not support WebSocket upgrade")
    }

    public override func openResponseTransportWriterRaw(): ResponseTransportWriter {
        NativeH2AppResponseTransportWriter(this)
    }

    public override func requestMethod(): String {
        request.method
    }

    public override func requestPath(): String {
        requestPathValue
    }

    public override func requestUrlString(): String {
        request.scheme + "://" + request.authority + request.path
    }

    public override func requestVersionString(): String {
        "HTTP/2"
    }

    public override func requestRemoteAddr(): String {
        remoteAddress
    }

    public override func requestQueryValue(key: String): ?String {
        nativeH2ReadDecodedQueryValue(queryStringValue, key)
    }

    public override func requestFormValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestHeaderValue(key: String): ?String {
        requestHeadersValue.getFirst(key)
    }

    public override func requestHeaders(): HttpHeaders {
        requestHeadersValue
    }

    public override func requestTrailers(): HttpHeaders {
        requestTrailersValue
    }

    public override func requestBodyStream(): InputStream {
        NativeH2AppBytesInputStream(request.body)
    }

    public override func requestBodySize(): ?Int64 {
        Some(request.body.size)
    }

    public override func setResponseStatus(code: UInt16): Unit {
        ensureResponseMetadataMutable()
        let numeric = Int64(code)
        if (numeric < 200 || numeric > 999) {
            throw Exception("native H2 first slice requires a final response status between 200 and 999")
        }
        responseStatusValue = code
    }

    public override func setResponseHeader(key: String, value: String): Unit {
        ensureResponseMetadataMutable()
        let normalized = nativeH2NormalizeAppResponseHeaderName(key)
        nativeH2ValidateHeaderValue(value)
        let values = ArrayList<String>()
        values.add(value.trimAscii())
        responseHeadersValue.add(normalized, values)
    }

    public override func addResponseHeader(key: String, value: String): Unit {
        ensureResponseMetadataMutable()
        appendResponseHeader(key, value)
    }

    public override func setResponseString(body: String): Unit {
        closeResponseStream()
        replaceResponseBytes(body.toArray())
    }

    public override func setResponseBytes(data: Array<UInt8>): Unit {
        closeResponseStream()
        replaceResponseBytes(data)
    }

    public override func attachResponseBodyStream(stream: InputStream): Unit {
        closeResponseStream()
        responseBodyValue = ArrayList<UInt8>()
        responseBodyStreamValue = Some(stream)
    }

    public override func responseCommitted(): Bool {
        if (let Some(commit) <- responseHeadCommit) {
            return commit.written()
        }
        false
    }

    func commitResponseHead(): Unit {
        if (let Some(commit) <- responseHeadCommit) {
            commit.request(responseStatusValue, responseHeaders())
            commit.awaitWritten()
        }
    }

    func commitResponseData(data: Array<UInt8>): Unit {
        if (nativeH2ResponseBodyForbidden(request.method, responseStatusValue)) {
            throw Exception("native H2 response body is forbidden for this response")
        }
        if (let Some(commit) <- responseDataCommit) {
            commit.submit(data)
        } else {
            appendResponseBytes(data)
        }
    }

    func commitResponseEnd(): Unit {
        if (nativeH2ResponseBodyForbidden(request.method, responseStatusValue)) {
            return
        }
        if (let Some(commit) <- responseDataCommit) {
            commit.requestEnd()
        }
    }

    func response(): NativeH2SingleStreamResponse {
        let headers = responseHeaders()
        let stream = responseBodyStreamValue
        responseBodyStreamValue = None
        NativeH2SingleStreamResponse(
            status: responseStatusValue,
            headers: headers,
            body: responseBodyValue.toArray(),
            bodyStream: stream
        )
    }

    func responseHeaders(): Array<NativeH2Header> {
        let headers = ArrayList<NativeH2Header>()
        for ((name, values) in responseHeadersValue) {
            for (value in values) {
                headers.add(NativeH2Header(name, value))
            }
        }
        headers.toArray()
    }

    func ensureResponseMetadataMutable(): Unit {
        if (let Some(commit) <- responseHeadCommit) {
            if (commit.requested()) {
                throw Exception("native H2 response metadata is frozen after HEADERS commit")
            }
        }
    }

    func appendResponseHeader(key: String, value: String): Unit {
        let normalized = nativeH2NormalizeAppResponseHeaderName(key)
        nativeH2ValidateHeaderValue(value)
        match (responseHeadersValue.get(normalized)) {
            case Some(values) => values.add(value.trimAscii())
            case None =>
                let values = ArrayList<String>()
                values.add(value.trimAscii())
                responseHeadersValue.add(normalized, values)
        }
    }

    func appendResponseBytes(data: Array<UInt8>): Unit {
        for (value in data) {
            responseBodyValue.add(value)
        }
    }

    func replaceResponseBytes(data: Array<UInt8>): Unit {
        responseBodyValue = ArrayList<UInt8>()
        appendResponseBytes(data)
    }

    func closeResponseStream(): Unit {
        if (let Some(stream) <- responseBodyStreamValue) {
            match (stream) {
                case resource: Resource => resource.close()
                case _ => ()
            }
        }
        responseBodyStreamValue = None
    }
}

func nativeH2NormalizeAppResponseHeaderName(name: String): String {
    nativeH2ValidateHeaderName(name, false, false)
    name.toAsciiLower()
}

func nativeH2ValidateHeaderName(
    name: String,
    allowPseudo: Bool,
    requireLowercase: Bool
): Unit {
    let bytes = name.toArray()
    if (bytes.size == 0) {
        throw Exception("native H2 header name cannot be empty")
    }
    var cursor: Int64 = 0
    if (bytes[0] == UInt8(0x3a)) {
        if (!allowPseudo || bytes.size == 1) {
            throw Exception("native H2 response ordinary header name cannot be pseudo")
        }
        cursor = 1
    }
    while (cursor < bytes.size) {
        let byte = bytes[cursor]
        let alphaNumeric = (byte >= UInt8(0x30) && byte <= UInt8(0x39)) ||
            (byte >= UInt8(0x41) && byte <= UInt8(0x5a)) ||
            (byte >= UInt8(0x61) && byte <= UInt8(0x7a))
        let punctuation = byte == UInt8(0x21) || byte == UInt8(0x23) ||
            byte == UInt8(0x24) || byte == UInt8(0x25) || byte == UInt8(0x26) ||
            byte == UInt8(0x27) || byte == UInt8(0x2a) || byte == UInt8(0x2b) ||
            byte == UInt8(0x2d) || byte == UInt8(0x2e) || byte == UInt8(0x5e) ||
            byte == UInt8(0x5f) || byte == UInt8(0x60) || byte == UInt8(0x7c) ||
            byte == UInt8(0x7e)
        if (!alphaNumeric && !punctuation) {
            throw Exception("native H2 response header name contains an invalid token byte")
        }
        if (requireLowercase && byte >= UInt8(0x41) && byte <= UInt8(0x5a)) {
            throw Exception("native H2 encoded response header names must be lowercase")
        }
        cursor += 1
    }
}

func nativeH2ValidateHeaderValue(value: String): Unit {
    for (byte in value.toArray()) {
        if ((byte < UInt8(32) && byte != UInt8(9)) || byte == UInt8(127)) {
            throw Exception("native H2 response header value contains a forbidden control byte")
        }
    }
}

func nativeH2ReadDecodedQueryValue(queryString: String, key: String): ?String {
    if (queryString.size == 0) {
        return None
    }
    for (part in queryString.split("&")) {
        let pair = part.split("=", 2)
        if (pair.size == 0) {
            continue
        }
        let candidateKey = nativeH2DecodeQueryComponent(pair[0])
        if (candidateKey == key) {
            return Some(if (pair.size == 2) {
                nativeH2DecodeQueryComponent(pair[1])
            } else {
                ""
            })
        }
    }
    None
}

func nativeH2DecodeQueryComponent(value: String): String {
    let input = value.toArray()
    let out = ArrayList<UInt8>()
    var cursor: Int64 = 0
    while (cursor < input.size) {
        let current = input[cursor]
        if (current == UInt8(0x2b)) {
            out.add(UInt8(0x20))
            cursor += 1
            continue
        }
        if (current == UInt8(0x25) && cursor + 2 < input.size) {
            let high = nativeH2QueryHexNibble(input[cursor + 1])
            let low = nativeH2QueryHexNibble(input[cursor + 2])
            if (high >= 0 && low >= 0) {
                out.add(UInt8((high << 4) | low))
                cursor += 3
                continue
            }
        }
        out.add(current)
        cursor += 1
    }
    try {
        String.fromUtf8(out.toArray())
    } catch (_: Exception) {
        value
    }
}

func nativeH2QueryHexNibble(value: UInt8): Int64 {
    let numeric = Int64(value)
    if (numeric >= 0x30 && numeric <= 0x39) {
        return numeric - 0x30
    }
    if (numeric >= 0x41 && numeric <= 0x46) {
        return numeric - 0x41 + 10
    }
    if (numeric >= 0x61 && numeric <= 0x66) {
        return numeric - 0x61 + 10
    }
    -1
}
