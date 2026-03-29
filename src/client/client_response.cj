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

    public func discard(): Unit {
        let tmp = Array<UInt8>(16384, repeat: 0)
        while (true) {
            if (_resp.body.read(tmp) <= 0) {
                break
            }
        }
    }
}
