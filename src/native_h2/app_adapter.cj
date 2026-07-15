package ignite.native_h2

import ignite.{App, CurrentRequestCarrier, ResponseTransportWriter}
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
    serveNativeH2SingleStream(socket, { request =>
        let carrier = NativeH2AppCurrentRequestCarrier(request, remoteAddress)
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
    serveNativeH2Connection(socket, { request =>
        let carrier = NativeH2AppCurrentRequestCarrier(request, remoteAddress)
        app.handleRequest(carrier)
        carrier.response()
    }, maxCompletedStreams: maxCompletedStreams, control: control,
        maxRequestBodySize: app.config.bodyLimit)
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

class NativeH2AppResponseTransportWriter <: ResponseTransportWriter {
    let carrier: NativeH2AppCurrentRequestCarrier

    init(carrier: NativeH2AppCurrentRequestCarrier) {
        this.carrier = carrier
    }

    public override func write(data: Array<UInt8>): Unit {
        carrier.appendResponseBytes(data)
    }
}

class NativeH2AppCurrentRequestCarrier <: CurrentRequestCarrier {
    let request: NativeH2SingleStreamRequest
    let remoteAddress: String
    let requestPathValue: String
    let queryStringValue: String
    let requestHeadersValue: HttpHeaders
    let requestTrailersValue: HttpHeaders
    let responseHeadersValue = HashMap<String, String>()
    var responseStatusValue: UInt16 = 200
    var responseBodyValue = ArrayList<UInt8>()
    var responseBodyStreamValue: ?InputStream = None

    init(request: NativeH2SingleStreamRequest, remoteAddress: String) {
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
        if (queryStringValue.size == 0) {
            return None
        }
        for (part in queryStringValue.split("&")) {
            let pair = part.split("=", 2)
            if (pair.size > 0 && pair[0] == key) {
                return Some(if (pair.size == 2) { pair[1] } else { "" })
            }
        }
        None
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
        let numeric = Int64(code)
        if (numeric < 200 || numeric > 999) {
            throw Exception("native H2 first slice requires a final response status between 200 and 999")
        }
        responseStatusValue = code
    }

    public override func setResponseHeader(key: String, value: String): Unit {
        responseHeadersValue.add(key.trimAscii().toAsciiLower(), value.trimAscii())
    }

    public override func addResponseHeaders(headers: HttpHeaders): Unit {
        for ((name, values) in headers) {
            for (value in values) {
                setResponseHeader(name, value)
            }
        }
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

    func response(): NativeH2SingleStreamResponse {
        consumeResponseStream()
        let headers = ArrayList<NativeH2Header>()
        for ((name, value) in responseHeadersValue) {
            headers.add(NativeH2Header(name, value))
        }
        NativeH2SingleStreamResponse(
            status: responseStatusValue,
            headers: headers.toArray(),
            body: responseBodyValue.toArray()
        )
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

    func consumeResponseStream(): Unit {
        if (let Some(stream) <- responseBodyStreamValue) {
            let chunk = Array<Byte>(16384, repeat: 0)
            try {
                while (true) {
                    let count = stream.read(chunk)
                    if (count <= 0) {
                        break
                    }
                    let data = Array<UInt8>(count, repeat: 0)
                    var i: Int64 = 0
                    while (i < count) {
                        data[i] = UInt8(chunk[i])
                        i += 1
                    }
                    appendResponseBytes(data)
                }
            } finally {
                closeResponseStream()
            }
        }
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
