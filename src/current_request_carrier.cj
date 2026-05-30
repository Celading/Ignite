package ignite

import std.io.InputStream
import stdx.net.http.{HttpContext, HttpHeaders, WebSocket}

/// Ignite-owned ingress wrapper for the current request carrier.
///
/// The current implementation is still stdx-backed, but `Ctx` no longer needs
/// to be constructed directly from `HttpContext`.
public interface CurrentRequestCarrier {
    func rawHttpContext(): HttpContext
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
    func requestHeaders(): HttpHeaders
    func requestBodyStream(): InputStream
    func requestBodySize(): ?Int64
    func setResponseStatus(code: UInt16): Unit
    func setResponseHeader(key: String, value: String): Unit
    func addResponseHeaders(headers: HttpHeaders): Unit
    func setResponseString(body: String): Unit
    func setResponseBytes(data: Array<UInt8>): Unit
    func attachResponseBodyStream(stream: InputStream): Unit
}

public class StdxHttpContextCurrentRequestCarrier <: CurrentRequestCarrier {
    let _httpCtx: HttpContext

    public init(httpCtx: HttpContext) {
        this._httpCtx = httpCtx
    }

    public override func rawHttpContext(): HttpContext {
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

    public override func requestHeaders(): HttpHeaders {
        _httpCtx.request.headers
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

    public override func addResponseHeaders(headers: HttpHeaders): Unit {
        _httpCtx.responseBuilder.addHeaders(headers)
    }

    public override func setResponseString(body: String): Unit {
        _httpCtx.responseBuilder.body(body)
    }

    public override func setResponseBytes(data: Array<UInt8>): Unit {
        _httpCtx.responseBuilder.body(data)
    }

    public override func attachResponseBodyStream(stream: InputStream): Unit {
        _httpCtx.responseBuilder.body(stream)
    }
}

func wrapCurrentRequestCarrier(httpCtx: HttpContext): CurrentRequestCarrier {
    StdxHttpContextCurrentRequestCarrier(httpCtx)
}
