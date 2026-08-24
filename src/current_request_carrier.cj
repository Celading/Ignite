package ignite

import std.collection.ArrayList
import std.io.InputStream
import stdx.net.http.{HttpContext, HttpHeaders, WebSocket}

/// Ignite-owned ingress wrapper for the current request carrier.
///
/// The current implementation is still stdx-backed, but `Ctx` no longer needs
/// to be constructed directly from `HttpContext`.
public interface CurrentRequestCarrier {
    func upgradeWebSocketRaw(): WebSocket
    func openResponseTransportWriterRaw(): ResponseTransportWriter
    func requestMethod(): String
    func requestPath(): String
    func requestUrlString(): String
    func requestVersionString(): String
    func requestRemoteAddr(): String
    func requestQueryValue(key: String): ?String
    func requestFormValue(key: String): ?String
    func requestHeaderValue(key: String): ?String
    func requestHeaderFields(): Array<(String, String)>
    func requestTrailerValue(key: String): ?String
    func requestTrailerFields(): Array<(String, String)>
    func requestBodyStream(): InputStream
    func requestBodySize(): ?Int64
    func setResponseStatus(code: UInt16): Unit
    func setResponseHeader(key: String, value: String): Unit
    func addResponseHeader(key: String, value: String): Unit
    func setResponseString(body: String): Unit
    func setResponseBytes(data: Array<UInt8>): Unit
    func attachResponseBodyStream(stream: InputStream): Unit
}

/// Optional compatibility capability for carriers backed by stdx
/// `HttpContext`. Native transports are not required to implement it.
public interface StdxHttpContextCompatibilityCarrier {
    func rawHttpContextCompatibility(): HttpContext
}

func currentRequestCarrierRawHttpContextCompatibility(
    carrier: CurrentRequestCarrier
): HttpContext {
    if (let Some(compatibility) <-
        (carrier as StdxHttpContextCompatibilityCarrier)) {
        return compatibility.rawHttpContextCompatibility()
    }
    throw Exception(
        "current request carrier does not expose stdx HttpContext compatibility"
    )
}

/// Optional carrier capability for transports that can commit a response
/// before the handler and post-handler middleware finish.
public interface ResponseCommitStateCarrier {
    func responseCommitted(): Bool
}

func currentRequestCarrierResponseCommitted(carrier: CurrentRequestCarrier): Bool {
    if (let Some(commitState) <- (carrier as ResponseCommitStateCarrier)) {
        return commitState.responseCommitted()
    }
    false
}

// Raw socket carriers do not pass through stdx URL parsing, so they must
// provide the same decoded query-value contract as `queryForm`.
func readDecodedUrlQueryValue(queryString: String, key: String): ?String {
    if (queryString.size == 0) {
        return None
    }
    for (part in queryString.split("&")) {
        let pair = part.split("=", 2)
        if (pair.size == 0) {
            continue
        }
        let candidateKey = decodeUrlQueryComponent(pair[0])
        if (candidateKey == key) {
            return Some(if (pair.size == 2) {
                decodeUrlQueryComponent(pair[1])
            } else {
                ""
            })
        }
    }
    None
}

func decodeUrlQueryComponent(value: String): String {
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
            let high = urlQueryHexNibble(input[cursor + 1])
            let low = urlQueryHexNibble(input[cursor + 2])
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

func urlQueryHexNibble(value: UInt8): Int64 {
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

public class StdxHttpContextCurrentRequestCarrier <: CurrentRequestCarrier & StdxHttpContextCompatibilityCarrier & PreparedResponseBodyCarrier {
    let _httpCtx: HttpContext

    public init(httpCtx: HttpContext) {
        this._httpCtx = httpCtx
    }

    public override func rawHttpContextCompatibility(): HttpContext {
        _httpCtx
    }

    public override func upgradeWebSocketRaw(): WebSocket {
        WebSocket.upgradeFromServer(_httpCtx)
    }

    public override func openResponseTransportWriterRaw(): ResponseTransportWriter {
        StdxResponseTransportWriter(_httpCtx)
    }

    public override func requestMethod(): String {
        _httpCtx.request.method
    }

    public override func requestPath(): String {
        _httpCtx.request.url.path
    }

    public override func requestUrlString(): String {
        _httpCtx.request.url.toString()
    }

    public override func requestVersionString(): String {
        _httpCtx.request.version.toString()
    }

    public override func requestRemoteAddr(): String {
        _httpCtx.request.remoteAddr
    }

    public override func requestQueryValue(key: String): ?String {
        _httpCtx.request.url.queryForm.get(key)
    }

    public override func requestFormValue(key: String): ?String {
        _httpCtx.request.form.get(key)
    }

    public override func requestHeaderValue(key: String): ?String {
        _httpCtx.request.headers.getFirst(key)
    }

    public override func requestHeaderFields(): Array<(String, String)> {
        flattenCurrentRequestCarrierHeaderFields(_httpCtx.request.headers)
    }

    public override func requestTrailerValue(key: String): ?String {
        let _ = key
        None
    }

    public override func requestTrailerFields(): Array<(String, String)> {
        []
    }

    public override func requestBodyStream(): InputStream {
        _httpCtx.request.body
    }

    public override func requestBodySize(): ?Int64 {
        _httpCtx.request.bodySize
    }

    public override func setResponseStatus(code: UInt16): Unit {
        _httpCtx.responseBuilder.status(code)
    }

    public override func setResponseHeader(key: String, value: String): Unit {
        _httpCtx.responseBuilder.header(key, value)
    }

    public override func addResponseHeader(key: String, value: String): Unit {
        let headers = HttpHeaders()
        headers.add(key, value)
        _httpCtx.responseBuilder.addHeaders(headers)
    }

    public override func setResponseString(body: String): Unit {
        _httpCtx.responseBuilder.body(body)
    }

    public override func setResponseBytes(data: Array<UInt8>): Unit {
        _httpCtx.responseBuilder.body(data)
    }

    public override func setPreparedResponseBody(body: PreparedResponseBody): Unit {
        _httpCtx.responseBuilder.body(body.borrowBytesForTransport())
    }

    public override func attachResponseBodyStream(stream: InputStream): Unit {
        _httpCtx.responseBuilder.body(stream)
    }
}

type CurrentRequestCarrierResponseWriterFactory = () -> ResponseTransportWriter

let CURRENT_REQUEST_CARRIER_STREAM_COPY_BUFFER_SIZE: Int64 = 64 * 1024

class ResponseTransportWriterBackedCurrentRequestCarrier <: CurrentRequestCarrier & StdxHttpContextCompatibilityCarrier & PreparedResponseBodyCarrier & ResponseCommitStateCarrier {
    let _downstream: CurrentRequestCarrier
    let _responseWriterFactory: CurrentRequestCarrierResponseWriterFactory
    var _responseWriter: ?ResponseTransportWriter = None

    init(
        downstream: CurrentRequestCarrier,
        responseWriterFactory: CurrentRequestCarrierResponseWriterFactory
    ) {
        _downstream = downstream
        _responseWriterFactory = responseWriterFactory
    }

    func ensureResponseWriter(): ResponseTransportWriter {
        match (_responseWriter) {
            case Some(writer) => writer
            case None =>
                let writer = _responseWriterFactory()
                _responseWriter = Some(writer)
                writer
        }
    }

    public override func rawHttpContextCompatibility(): HttpContext {
        currentRequestCarrierRawHttpContextCompatibility(_downstream)
    }

    public override func upgradeWebSocketRaw(): WebSocket {
        _downstream.upgradeWebSocketRaw()
    }

    public override func openResponseTransportWriterRaw(): ResponseTransportWriter {
        ensureResponseWriter()
    }

    public override func responseCommitted(): Bool {
        currentRequestCarrierResponseCommitted(_downstream)
    }

    public override func requestMethod(): String {
        _downstream.requestMethod()
    }

    public override func requestPath(): String {
        _downstream.requestPath()
    }

    public override func requestUrlString(): String {
        _downstream.requestUrlString()
    }

    public override func requestVersionString(): String {
        _downstream.requestVersionString()
    }

    public override func requestRemoteAddr(): String {
        _downstream.requestRemoteAddr()
    }

    public override func requestQueryValue(key: String): ?String {
        _downstream.requestQueryValue(key)
    }

    public override func requestFormValue(key: String): ?String {
        _downstream.requestFormValue(key)
    }

    public override func requestHeaderValue(key: String): ?String {
        _downstream.requestHeaderValue(key)
    }

    public override func requestHeaderFields(): Array<(String, String)> {
        _downstream.requestHeaderFields()
    }

    public override func requestTrailerValue(key: String): ?String {
        _downstream.requestTrailerValue(key)
    }

    public override func requestTrailerFields(): Array<(String, String)> {
        _downstream.requestTrailerFields()
    }

    public override func requestBodyStream(): InputStream {
        _downstream.requestBodyStream()
    }

    public override func requestBodySize(): ?Int64 {
        _downstream.requestBodySize()
    }

    public override func setResponseStatus(code: UInt16): Unit {
        _downstream.setResponseStatus(code)
    }

    public override func setResponseHeader(key: String, value: String): Unit {
        _downstream.setResponseHeader(key, value)
    }

    public override func addResponseHeader(key: String, value: String): Unit {
        _downstream.addResponseHeader(key, value)
    }

    public override func setResponseString(body: String): Unit {
        let bytes = body.toArray()
        if (bytes.size == 0) {
            return
        }
        ensureResponseWriter().write(bytes)
    }

    public override func setResponseBytes(data: Array<UInt8>): Unit {
        if (data.size == 0) {
            return
        }
        ensureResponseWriter().write(cloneResponseTransportBytes(data))
    }

    public override func setPreparedResponseBody(body: PreparedResponseBody): Unit {
        if (body.size == 0) {
            return
        }
        ensureResponseWriter().write(body.borrowBytesForTransport())
    }

    public override func attachResponseBodyStream(stream: InputStream): Unit {
        let writer = ensureResponseWriter()
        let buffer = Array<Byte>(
            CURRENT_REQUEST_CARRIER_STREAM_COPY_BUFFER_SIZE,
            repeat: 0
        )
        try {
            while (true) {
                let readLen = stream.read(buffer)
                if (readLen <= 0) {
                    break
                }
                writer.write(
                    currentRequestCarrierByteWindowToUInt8(buffer, readLen)
                )
            }
        } finally {
            closeCurrentRequestCarrierStreamIfResource(stream)
        }
    }
}

func flattenCurrentRequestCarrierHeaderFields(
    headers: HttpHeaders
): Array<(String, String)> {
    let fields = ArrayList<(String, String)>()
    for ((name, values) in headers) {
        for (value in values) {
            fields.add((name, value))
        }
    }
    fields.toArray()
}

func wrapCurrentRequestCarrier(httpCtx: HttpContext): CurrentRequestCarrier {
    StdxHttpContextCurrentRequestCarrier(httpCtx)
}

func wrapCurrentRequestCarrierResponseWriter(
    currentRequestCarrier: CurrentRequestCarrier,
    responseWriterFactory: CurrentRequestCarrierResponseWriterFactory
): CurrentRequestCarrier {
    ResponseTransportWriterBackedCurrentRequestCarrier(
        currentRequestCarrier,
        responseWriterFactory
    )
}

func currentRequestCarrierByteWindowToUInt8(
    input: Array<Byte>,
    size: Int64
): Array<UInt8> {
    let out = Array<UInt8>(size, repeat: 0)
    var i: Int64 = 0
    while (i < size) {
        out[i] = UInt8(input[i])
        i += 1
    }
    out
}

func closeCurrentRequestCarrierStreamIfResource(stream: InputStream): Unit {
    match (stream) {
        case closable: Resource => closable.close()
        case _ => ()
    }
}
