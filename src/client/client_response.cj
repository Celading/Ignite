package ignite.client

import stdx.net.http.{HttpResponse, HttpHeaders}
import std.collection.ArrayList
import std.io.InputStream

// ── ClientResponse ──

public class ClientResponse {
    let _resp: HttpResponse
    var _bodyCache: ?Array<UInt8> = None

    public init(resp: HttpResponse) {
        _resp = resp
    }

    public prop status: UInt16 {
        get() { _resp.status }
    }

    public prop headers: HttpHeaders {
        get() { _resp.headers }
    }

    public func isOk(): Bool {
        let s = Int64(_resp.status)
        s >= 200 && s < 300
    }

    public func isSuccess(): Bool {
        isOk()
    }

    public func bodyStream(): InputStream {
        _resp.body
    }

    public func body(): String {
        String.fromUtf8(bodyBytes())
    }

    public func bodyBytes(): Array<UInt8> {
        if (let Some(cached) <- _bodyCache) {
            return cached
        }
        let chunks = ArrayList<Array<UInt8>>()
        let tmp = Array<UInt8>(16384, repeat: 0)
        var totalSize: Int64 = 0
        while (true) {
            let n = _resp.body.read(tmp)
            if (n <= 0) { break }
            let chunk = Array<UInt8>(n, repeat: 0)
            for (i in 0..n) {
                chunk[i] = tmp[i]
            }
            totalSize += n
            chunks.add(chunk)
        }

        let arr = Array<UInt8>(totalSize, repeat: 0)
        var offset: Int64 = 0
        for (chunk in chunks) {
            for (i in 0..chunk.size) {
                arr[offset + i] = chunk[i]
            }
            offset += chunk.size
        }

        _bodyCache = arr
        arr
    }

    public func json(): String {
        body()
    }

    public func header(name: String): ?String {
        _resp.headers.getFirst(name)
    }

    public func headerValues(name: String): ArrayList<String> {
        let list = ArrayList<String>()
        for (v in _resp.headers.get(name)) {
            list.add(v)
        }
        list
    }

    public func observeSnapshot(): ?ClientObserveSnapshot {
        if (!hasObserveHeaders()) {
            return None
        }
        let errorClass = normalizedObserveErrorClass(headerOr("x-ignite-observe-error-class", "NONE"))
        Some(
            ClientObserveSnapshot(
                if (errorClass == "NONE") { "success" } else { "error" },
                errorClass,
                "response",
                "-",
                headerOr("x-ignite-observe-backend-id", "-"),
                headerOr("x-ignite-observe-provider-id", "-"),
                headerOr("x-ignite-observe-crypto-provider-id", "-"),
                headerOr("x-ignite-observe-public-path", "-"),
                headerOr("x-ignite-observe-risk-level", "-"),
                headerOr("x-ignite-observe-transport-tags", "-"),
                false,
                false,
                false,
                parseObserveInt64("x-ignite-observe-retry-count", 0),
                parseObserveInt64("x-ignite-observe-duration-ms", 0),
                headerOr("x-ignite-observe-fields", "-"),
                status,
                "-",
                "-",
                "-",
                false,
                ""
            )
        )
    }

    public func transportTouchpoint(): ?ClientTransportTouchpoint {
        if (!hasObserveHeaders()) {
            return None
        }
        Some(
            ClientTransportTouchpoint(
                headerOr("x-ignite-observe-candidate-order", "-"),
                headerOr("x-ignite-observe-backend-id", "-"),
                headerOr("x-ignite-observe-selected-reason", "-"),
                headerOr("x-ignite-observe-fallback-chain", "-"),
                headerOr("x-ignite-observe-provider-id", "-"),
                headerOr("x-ignite-observe-crypto-provider-id", "-"),
                headerOr("x-ignite-observe-public-path", "-"),
                headerOr("x-ignite-observe-risk-level", "-"),
                headerOr("x-ignite-observe-transport-tags", "-")
            )
        )
    }

    public func discard(): Unit {
        let tmp = Array<UInt8>(16384, repeat: 0)
        while (true) {
            if (_resp.body.read(tmp) <= 0) {
                break
            }
        }
    }

    func hasObserveHeaders(): Bool {
        if (let Some(_backend) <- header("x-ignite-observe-backend-id")) {
            return true
        }
        false
    }

    func headerOr(name: String, fallback: String): String {
        if (let Some(value) <- header(name)) {
            return value
        }
        fallback
    }

    func normalizedObserveErrorClass(value: String): String {
        if (value == "NONE") {
            return "NONE"
        }
        value
    }

    func parseObserveInt64(name: String, fallback: Int64): Int64 {
        if (let Some(value) <- header(name)) {
            return parseDecimalInt64(value, fallback)
        }
        fallback
    }
}

func parseDecimalInt64(value: String, fallback: Int64): Int64 {
    let digits = value.trimAscii()
    if (digits.size == 0) {
        return fallback
    }
    var result: Int64 = 0
    for (ch in digits.toRuneArray()) {
        if (ch < r'0' || ch > r'9') {
            return fallback
        }
        result = result * 10 + (Int64(UInt32(ch)) - Int64(UInt32(r'0')))
    }
    result
}
