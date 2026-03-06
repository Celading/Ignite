package ignite.client

import stdx.net.http.{
    Client, ClientBuilder, HttpRequestBuilder, HttpRequest,
    HttpResponse, HttpHeaders
}
import std.collection.{ArrayList, HashMap}
import std.io.InputStream
import std.unicode.*
import std.random.Random

// ── URL / Form 编码 ──

func urlEncode(s: String): String {
    let allowed = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~"
    let runes = s.toRuneArray()
    var result = ""
    for (r in runes) {
        let c = r.toString()
        if (c == " ") {
            result += "+"
        } else if (strContains(allowed, c)) {
            result += c
        } else {
            let bytes = c.toArray()
            for (b in bytes) {
                let n = Int64(b)
                result += "%"
                if (n < 16) { result += "0" }
                result += intToHex(n)
            }
        }
    }
    result
}

func strContains(haystack: String, needle: String): Bool {
    let h = haystack.toRuneArray()
    let n = needle.toRuneArray()
    if (n.size == 0) { return true }
    if (h.size < n.size) { return false }
    for (i in 0..=(h.size - n.size)) {
        var ok = true
        for (j in 0..n.size) {
            if (h[i + j] != n[j]) { ok = false; break }
        }
        if (ok) { return true }
    }
    false
}

func intToHex(n: Int64): String {
    if (n < 10) { return "${n}" }
    if (n < 16) { return String.fromUtf8([UInt8(87 + n)]) }
    intToHex(n / 16) + intToHex(n % 16)
}

func buildQueryString(params: ArrayList<(String, String)>): String {
    if (params.size == 0) { return "" }
    var first = true
    var result = ""
    for ((k, v) in params) {
        if (!first) { result += "&" }
        first = false
        result += urlEncode(k) + "=" + urlEncode(v)
    }
    result
}

func buildFormUrlEncoded(params: ArrayList<(String, String)>): String {
    buildQueryString(params)
}

// ── Multipart 请求体 ──

public class MultipartFile {
    public let name: String
    public let filename: String
    public let contentType: String
    public let data: Array<UInt8>

    public init(name: String, filename: String, contentType: String, data: Array<UInt8>) {
        this.name = name
        this.filename = filename
        this.contentType = contentType
        this.data = data
    }
}

func buildMultipartBody(
    boundary: String,
    fields: ArrayList<(String, String)>,
    files: ArrayList<MultipartFile>
): Array<UInt8> {
    let crlf = [UInt8(13), UInt8(10)]
    let dash = "--".toArray()
    let b = boundary.toArray()
    let result = ArrayList<UInt8>()

    func append(s: String): Unit {
        for (x in s.toArray()) { result.add(x) }
    }
    func appendBytes(arr: Array<UInt8>): Unit {
        for (x in arr) { result.add(x) }
    }

    for ((name, value) in fields) {
        appendBytes(dash)
        appendBytes(b)
        appendBytes(crlf)
        append("Content-Disposition: form-data; name=\"${name}\"")
        appendBytes(crlf)
        appendBytes(crlf)
        append(value)
        appendBytes(crlf)
    }

    for (f in files) {
        appendBytes(dash)
        appendBytes(b)
        appendBytes(crlf)
        append("Content-Disposition: form-data; name=\"${f.name}\"; filename=\"${f.filename}\"")
        appendBytes(crlf)
        append("Content-Type: ${f.contentType}")
        appendBytes(crlf)
        appendBytes(crlf)
        appendBytes(f.data)
        appendBytes(crlf)
    }

    appendBytes(dash)
    appendBytes(b)
    append("--")
    appendBytes(crlf)
    result.toArray()
}

func randomBoundary(): String {
    let rng = Random()
    let hex = "0123456789abcdef".toRuneArray()
    var s = ""
    for (_ in 0..32) {
        s += hex[Int64(rng.nextUInt64() % 16)].toString()
    }
    s
}

// ── Cookie 存储 ──

public class CookieStore {
    var _store: HashMap<String, HashMap<String, String>> = HashMap<String, HashMap<String, String>>()

    public init() {}

    public func addFromResponse(host: String, response: ClientResponse): Unit {
        let setCookies = response.headerValues("set-cookie")
        for (line in setCookies) {
            let parts = line.split(";", 2)
            if (parts.size >= 1) {
                let kv = parts[0].trimAscii().split("=", 2)
                if (kv.size == 2) {
                    let name = kv[0].trimAscii()
                    let value = kv[1].trimAscii()
                    if (!_store.contains(host)) {
                        _store.add(host, HashMap<String, String>())
                    }
                    if (let Some(m) <- _store.get(host)) {
                        m.add(name, value)
                    }
                }
            }
        }
    }

    public func getCookieHeader(host: String): String {
        match (_store.get(host)) {
            case Some(m) =>
                var first = true
                var result = ""
                for ((name, value) in m) {
                    if (!first) { result += "; " }
                    first = false
                    result += name + "=" + value
                }
                result
            case None => ""
        }
    }
}

// ── RestClient ──

public class RestClient {
    let _client: Client
    var _baseUrl: String = ""
    var _defaultHeaders: HashMap<String, String> = HashMap<String, String>()
    var _cookieStore: ?CookieStore = None

    public init() {
        _client = ClientBuilder().build()
    }

    public init(
        readTimeout!: Duration = Duration.second * 15,
        writeTimeout!: Duration = Duration.second * 15,
        poolSize!: Int64 = 10
    ) {
        _client = ClientBuilder()
            .readTimeout(readTimeout)
            .writeTimeout(writeTimeout)
            .poolSize(poolSize)
            .build()
    }

    public func baseUrl(url: String): RestClient {
        _baseUrl = url
        this
    }

    public func defaultHeader(name: String, value: String): RestClient {
        _defaultHeaders.add(name, value)
        this
    }

    public func useCookies(): RestClient {
        _cookieStore = CookieStore()
        this
    }

    public func useCookies(store: CookieStore): RestClient {
        _cookieStore = store
        this
    }

    func resolveUrl(url: String): String {
        if (_baseUrl.size == 0) { return url }
        if (strStartsWith(url, "http://") || strStartsWith(url, "https://")) {
            return url
        }
        let base = _baseUrl
        if (base.toRuneArray()[base.size - 1] == r'/') {
            if (url.size > 0 && url.toRuneArray()[0] == r'/') {
                return base + substringFrom(url, 1)
            }
            return base + url
        }
        if (url.size > 0 && url.toRuneArray()[0] == r'/') {
            return base + url
        }
        base + "/" + url
    }

    func hostFromUrl(url: String): String {
        var start = 0
        if (strStartsWith(url, "https://")) { start = 8 }
        else if (strStartsWith(url, "http://")) { start = 6 }
        let rest = substringFrom(url, start)
        let slash = findChar(rest, r'/')
        if (slash < 0) { rest } else { rest.split("/", 2)[0] }
    }

    func findChar(s: String, ch: Rune): Int64 {
        let runes = s.toRuneArray()
        for (i in 0..runes.size) {
            if (runes[i] == ch) { return i }
        }
        -1
    }

    func strStartsWith(s: String, prefix: String): Bool {
        if (s.size < prefix.size) { return false }
        let sArr = s.toRuneArray()
        let pArr = prefix.toRuneArray()
        for (i in 0..pArr.size) {
            if (sArr[i] != pArr[i]) { return false }
        }
        true
    }

    func substringFrom(s: String, start: Int64): String {
        let runes = s.toRuneArray()
        var result = ""
        for (i in start..runes.size) {
            result += runes[i].toString()
        }
        result
    }

    public func get(url: String): ClientResponse {
        let u = resolveUrl(url)
        let resp = ClientResponse(_client.get(u))
        maybeStoreCookies(u, resp)
        resp
    }

    public func post(url: String, body: String): ClientResponse {
        let u = resolveUrl(url)
        let resp = ClientResponse(_client.post(u, body))
        maybeStoreCookies(u, resp)
        resp
    }

    public func postJson(url: String, json: String): ClientResponse {
        let u = resolveUrl(url)
        let req = HttpRequestBuilder()
            .post()
            .url(u)
            .header("content-type", "application/json")
            .body(json)
            .build()
        let resp = ClientResponse(_client.send(req))
        maybeStoreCookies(u, resp)
        resp
    }

    public func postForm(url: String, params: ArrayList<(String, String)>): ClientResponse {
        let u = resolveUrl(url)
        let body = buildFormUrlEncoded(params)
        let req = HttpRequestBuilder()
            .post()
            .url(u)
            .header("content-type", "application/x-www-form-urlencoded")
            .body(body)
            .build()
        let resp = ClientResponse(_client.send(req))
        maybeStoreCookies(u, resp)
        resp
    }

    public func postMultipart(
        url: String,
        fields: ArrayList<(String, String)>,
        files: ArrayList<MultipartFile>
    ): ClientResponse {
        let u = resolveUrl(url)
        let boundary = randomBoundary()
        let body = buildMultipartBody(boundary, fields, files)
        let req = HttpRequestBuilder()
            .post()
            .url(u)
            .header("content-type", "multipart/form-data; boundary=${boundary}")
            .body(body)
            .build()
        let resp = ClientResponse(_client.send(req))
        maybeStoreCookies(u, resp)
        resp
    }

    public func put(url: String, body: String): ClientResponse {
        let u = resolveUrl(url)
        let resp = ClientResponse(_client.put(u, body))
        maybeStoreCookies(u, resp)
        resp
    }

    public func delete(url: String): ClientResponse {
        let u = resolveUrl(url)
        let resp = ClientResponse(_client.delete(u))
        maybeStoreCookies(u, resp)
        resp
    }

    public func head(url: String): ClientResponse {
        let u = resolveUrl(url)
        ClientResponse(_client.head(u))
    }

    public func options(url: String): ClientResponse {
        let u = resolveUrl(url)
        let req = HttpRequestBuilder()
            .method("OPTIONS")
            .url(u)
            .build()
        let resp = ClientResponse(_client.send(req))
        maybeStoreCookies(u, resp)
        resp
    }

    public func patch(url: String, body: String): ClientResponse {
        let u = resolveUrl(url)
        let req = HttpRequestBuilder()
            .method("PATCH")
            .url(u)
            .body(body)
            .build()
        let resp = ClientResponse(_client.send(req))
        maybeStoreCookies(u, resp)
        resp
    }

    public func request(): RequestBuilder {
        RequestBuilder(_client, _baseUrl, _defaultHeaders, _cookieStore)
    }

    public func close(): Unit {
        _client.close()
    }

    func maybeStoreCookies(url: String, resp: ClientResponse): Unit {
        if (let Some(store) <- _cookieStore) {
            let host = hostFromUrl(url)
            store.addFromResponse(host, resp)
        }
    }
}

// ── RequestBuilder ──

public class RequestBuilder {
    let _client: Client
    let _baseUrl: String
    let _defaultHeaders: HashMap<String, String>
    let _cookieStore: ?CookieStore
    let _builder: HttpRequestBuilder = HttpRequestBuilder()
    var _currentUrl: String = ""
    var _queryParams: ArrayList<(String, String)> = ArrayList<(String, String)>()
    var _formParams: ?ArrayList<(String, String)> = None
    var _multipartFields: ?ArrayList<(String, String)> = None
    var _multipartFiles: ?ArrayList<MultipartFile> = None

    init(
        client: Client,
        baseUrl: String,
        defaultHeaders: HashMap<String, String>,
        cookieStore: ?CookieStore
    ) {
        _client = client
        _baseUrl = baseUrl
        _defaultHeaders = defaultHeaders
        _cookieStore = cookieStore
        for ((k, v) in defaultHeaders) {
            _builder.header(k, v)
        }
    }

    public func method(m: String): RequestBuilder {
        _builder.method(m)
        this
    }

    public func url(u: String): RequestBuilder {
        var full = u
        if (_baseUrl.size > 0 && u.toRuneArray().size > 0) {
            let runes = u.toRuneArray()
            let isAbs = (u.size >= 7 && u.toRuneArray()[0] == r'h' && u.toRuneArray()[1] == r't')
            if (!isAbs) {
                if (runes[0] == r'/') {
                    full = _baseUrl + u
                } else {
                    let baseRunes = _baseUrl.toRuneArray()
                    if (baseRunes.size > 0 && baseRunes[baseRunes.size - 1] == r'/') {
                        full = _baseUrl + u
                    } else {
                        full = _baseUrl + "/" + u
                    }
                }
            }
        }
        _currentUrl = full
        _builder.url(full)
        this
    }

    public func query(key: String, value: String): RequestBuilder {
        _queryParams.add((key, value))
        this
    }

    public func header(name: String, value: String): RequestBuilder {
        _builder.header(name, value)
        this
    }

    public func addHeader(name: String, value: String): RequestBuilder {
        _builder.header(name, value)
        this
    }

    public func basicAuth(user: String, pass: String): RequestBuilder {
        let raw = user + ":" + pass
        let encoded = base64EncodeBytes(raw.toArray())
        _builder.header("Authorization", "Basic " + encoded)
        this
    }

    public func bearerToken(token: String): RequestBuilder {
        _builder.header("Authorization", "Bearer " + token)
        this
    }

    func base64EncodeBytes(data: Array<UInt8>): String {
        let table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
        let chars = table.toRuneArray()
        var result = ""
        var i: Int64 = 0
        while (i < data.size) {
            let b0 = Int64(data[i])
            let b1 = if (i + 1 < data.size) { Int64(data[i + 1]) } else { 0 }
            let b2 = if (i + 2 < data.size) { Int64(data[i + 2]) } else { 0 }
            let triple = (b0 << 16) | (b1 << 8) | b2
            result += chars[(triple >> 18) & 0x3F].toString()
            result += chars[(triple >> 12) & 0x3F].toString()
            result += if (i + 1 < data.size) { chars[(triple >> 6) & 0x3F].toString() } else { "=" }
            result += if (i + 2 < data.size) { chars[triple & 0x3F].toString() } else { "=" }
            i += 3
        }
        result
    }

    public func body(b: String): RequestBuilder {
        _builder.body(b)
        this
    }

    public func bodyBytes(b: Array<UInt8>): RequestBuilder {
        _builder.body(b)
        this
    }

    public func form(params: ArrayList<(String, String)>): RequestBuilder {
        _formParams = params
        _multipartFields = None
        _multipartFiles = None
        this
    }

    public func multipart(
        fields: ArrayList<(String, String)>,
        files: ArrayList<MultipartFile>
    ): RequestBuilder {
        _multipartFields = fields
        _multipartFiles = files
        _formParams = None
        this
    }

    public func send(): ClientResponse {
        var finalUrl = _currentUrl
        if (_queryParams.size > 0) {
            let qs = buildQueryString(_queryParams)
            if (containsStr(_currentUrl, "?")) {
                finalUrl = _currentUrl + "&" + qs
            } else {
                finalUrl = _currentUrl + "?" + qs
            }
            _builder.url(finalUrl)
        }

        if (let Some(params) <- _formParams) {
            _builder.header("content-type", "application/x-www-form-urlencoded")
            _builder.body(buildFormUrlEncoded(params).toArray())
        }
        if (let Some(fields) <- _multipartFields) {
            if (let Some(files) <- _multipartFiles) {
                let boundary = randomBoundary()
                _builder.header("content-type", "multipart/form-data; boundary=${boundary}")
                _builder.body(buildMultipartBody(boundary, fields, files))
            }
        }

        let urlForHost = if (finalUrl.size > 0) { finalUrl } else { _currentUrl }
        if (let Some(store) <- _cookieStore) {
            let host = hostFromUrl(urlForHost)
            let cookieHeader = store.getCookieHeader(host)
            if (cookieHeader.size > 0) {
                _builder.header("Cookie", cookieHeader)
            }
        }

        let resp = ClientResponse(_client.send(_builder.build()))
        if (let Some(store) <- _cookieStore) {
            store.addFromResponse(hostFromUrl(urlForHost), resp)
        }
        resp
    }

    func containsStr(hay: String, needle: String): Bool {
        let h = hay.toRuneArray()
        let n = needle.toRuneArray()
        if (n.size == 0) { return true }
        if (h.size < n.size) { return false }
        for (i in 0..=(h.size - n.size)) {
            var ok = true
            for (j in 0..n.size) {
                if (h[i + j] != n[j]) { ok = false; break }
            }
            if (ok) { return true }
        }
        false
    }

    func hostFromUrl(url: String): String {
        var start: Int64 = 0
        let runes = url.toRuneArray()
        if (runes.size >= 8) {
            if (runes[0] == r'h' && runes[1] == r't' && runes[2] == r't' && runes[3] == r'p' && runes[4] == r's' && runes[5] == r':' && runes[6] == r'/' && runes[7] == r'/') {
                start = 8
            }
        }
        if (start == 0 && runes.size >= 7) {
            if (runes[0] == r'h' && runes[1] == r't' && runes[2] == r't' && runes[3] == r'p' && runes[4] == r':' && runes[5] == r'/' && runes[6] == r'/') {
                start = 7
            }
        }
        var result = ""
        for (i in start..runes.size) {
            if (runes[i] == r'/') { break }
            result += runes[i].toString()
        }
        result
    }
}

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
        let buf = ArrayList<UInt8>()
        let tmp = Array<UInt8>(4096, repeat: 0)
        while (true) {
            let n = _resp.body.read(tmp)
            if (n <= 0) { break }
            for (i in 0..n) {
                buf.add(tmp[i])
            }
        }
        let arr = buf.toArray()
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
        match (_resp.headers.getFirst(name)) {
            case Some(v) => list.add(v)
            case None => ()
        }
        list
    }

    public func discard(): Unit {
        let tmp = Array<UInt8>(1024, repeat: 0)
        while (_resp.body.read(tmp) > 0) {}
    }
}
