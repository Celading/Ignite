package ignite.client

import stdx.net.http.{
    Client, ClientBuilder, HttpRequestBuilder, HttpRequest,
    HttpResponse, HttpHeaders
}
import std.collection.ArrayList
import std.io.InputStream

public class RestClient {
    let _client: Client

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

    public func get(url: String): ClientResponse {
        ClientResponse(_client.get(url))
    }

    public func post(url: String, body: String): ClientResponse {
        ClientResponse(_client.post(url, body))
    }

    public func postJson(url: String, json: String): ClientResponse {
        let req = HttpRequestBuilder()
            .post()
            .url(url)
            .header("content-type", "application/json")
            .body(json)
            .build()
        ClientResponse(_client.send(req))
    }

    public func put(url: String, body: String): ClientResponse {
        ClientResponse(_client.put(url, body))
    }

    public func delete(url: String): ClientResponse {
        ClientResponse(_client.delete(url))
    }

    public func head(url: String): ClientResponse {
        ClientResponse(_client.head(url))
    }

    public func patch(url: String, body: String): ClientResponse {
        let req = HttpRequestBuilder()
            .method("PATCH")
            .url(url)
            .body(body)
            .build()
        ClientResponse(_client.send(req))
    }

    public func request(): RequestBuilder {
        RequestBuilder(_client)
    }

    public func close(): Unit {
        _client.close()
    }
}

public class RequestBuilder {
    let _client: Client
    let _builder: HttpRequestBuilder = HttpRequestBuilder()

    init(client: Client) {
        _client = client
    }

    public func method(m: String): RequestBuilder {
        _builder.method(m)
        this
    }

    public func url(u: String): RequestBuilder {
        _builder.url(u)
        this
    }

    public func header(name: String, value: String): RequestBuilder {
        _builder.header(name, value)
        this
    }

    public func body(b: String): RequestBuilder {
        _builder.body(b)
        this
    }

    public func bodyBytes(b: Array<UInt8>): RequestBuilder {
        _builder.body(b)
        this
    }

    public func send(): ClientResponse {
        ClientResponse(_client.send(_builder.build()))
    }
}

public class ClientResponse {
    let _resp: HttpResponse

    public init(resp: HttpResponse) {
        _resp = resp
    }

    public prop status: UInt16 {
        get() { _resp.status }
    }

    public prop headers: HttpHeaders {
        get() { _resp.headers }
    }

    public func body(): String {
        let buf = ArrayList<UInt8>()
        let tmp = Array<UInt8>(4096, repeat: 0)
        while (true) {
            let n = _resp.body.read(tmp)
            if (n <= 0) { break }
            for (i in 0..n) {
                buf.add(tmp[i])
            }
        }
        String.fromUtf8(buf.toArray())
    }

    public func bodyBytes(): Array<UInt8> {
        let buf = ArrayList<UInt8>()
        let tmp = Array<UInt8>(4096, repeat: 0)
        while (true) {
            let n = _resp.body.read(tmp)
            if (n <= 0) { break }
            for (i in 0..n) {
                buf.add(tmp[i])
            }
        }
        buf.toArray()
    }

    public func header(name: String): ?String {
        _resp.headers.getFirst(name)
    }

    public func discard(): Unit {
        let tmp = Array<UInt8>(1024, repeat: 0)
        while (_resp.body.read(tmp) > 0) {}
    }
}
