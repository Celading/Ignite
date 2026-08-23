package ignite.client

import std.collection.{ArrayList, HashMap}
import std.io.InputStream
import std.net.TcpSocket
import std.sync.Mutex
import stdx.net.http.HttpHeaders

let NATIVE_H1_CLIENT_BACKEND = "ignite-native-h1-client"

class NativeH1ClientTarget {
    let scheme: String
    let host: String
    let port: UInt16
    let requestTarget: String
    let hostHeader: String

    init(scheme: String, host: String, port: UInt16, requestTarget: String, hostHeader: String) {
        this.scheme = scheme
        this.host = host
        this.port = port
        this.requestTarget = requestTarget
        this.hostHeader = hostHeader
    }
}

public class NativeH1ClientConnectionPool {
    let mtx = Mutex()
    let maxIdlePerOrigin: Int64
    var idle = HashMap<String, ArrayList<TcpSocket>>()

    init(maxIdlePerOrigin: Int64) {
        this.maxIdlePerOrigin = if (maxIdlePerOrigin > 0) { maxIdlePerOrigin } else { 0 }
    }

    func enabled(): Bool {
        maxIdlePerOrigin > 0
    }

    func acquire(origin: String): ?TcpSocket {
        var selected: ?TcpSocket = None
        synchronized(mtx) {
            if (let Some(sockets) <- idle.get(origin)) {
                while (sockets.size > 0) {
                    let socket = sockets.remove(at: sockets.size - 1)
                    if (!socket.isClosed()) {
                        selected = Some(socket)
                        break
                    }
                }
                if (sockets.size == 0) {
                    let _ = idle.remove(origin)
                }
            }
        }
        selected
    }

    func release(origin: String, socket: TcpSocket): Unit {
        if (!enabled() || socket.isClosed()) {
            closeNativeH1Socket(socket)
            return
        }
        var retained = false
        synchronized(mtx) {
            var sockets = if (let Some(existing) <- idle.get(origin)) {
                existing
            } else {
                let created = ArrayList<TcpSocket>()
                idle.add(origin, created)
                created
            }
            if (sockets.size < maxIdlePerOrigin) {
                sockets.add(socket)
                retained = true
            }
        }
        if (!retained) {
            closeNativeH1Socket(socket)
        }
    }

    func close(): Unit {
        synchronized(mtx) {
            for ((_origin, sockets) in idle) {
                for (socket in sockets) {
                    closeNativeH1Socket(socket)
                }
            }
            idle = HashMap<String, ArrayList<TcpSocket>>()
        }
    }
}

class NativeH1ClientBytesInputStream <: InputStream {
    let bytes: Array<UInt8>
    var offset: Int64 = 0

    init(bytes: Array<UInt8>) {
        this.bytes = cloneNativeH1Bytes(bytes)
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

class NativeH1ClientHeaderReadResult {
    let headerBytes: Array<UInt8>
    let prefetchedBody: Array<UInt8>

    init(headerBytes: Array<UInt8>, prefetchedBody: Array<UInt8>) {
        this.headerBytes = headerBytes
        this.prefetchedBody = prefetchedBody
    }
}

class NativeH1ClientParsedResponseHead {
    let version: String
    let status: Int64
    let headers: HttpHeaders

    init(version: String, status: Int64, headers: HttpHeaders) {
        this.version = version
        this.status = status
        this.headers = headers
    }
}

class NativeH1ResponseFraming {
    let mode: String
    let contentLength: Int64

    init(mode: String, contentLength: Int64) {
        this.mode = mode
        this.contentLength = contentLength
    }
}

class NativeH1ClientSocketReader {
    let socket: TcpSocket
    let prefetched: Array<UInt8>
    var prefetchedOffset: Int64 = 0

    init(socket: TcpSocket, prefetched: Array<UInt8>) {
        this.socket = socket
        this.prefetched = prefetched
    }

    func readAtMost(outBuf: Array<Byte>, limit: Int64): Int64 {
        if (limit <= 0 || outBuf.size == 0) {
            return 0
        }
        let wanted = if (limit < outBuf.size) { limit } else { outBuf.size }
        var copied: Int64 = 0
        while (copied < wanted && prefetchedOffset < prefetched.size) {
            outBuf[copied] = prefetched[prefetchedOffset]
            copied += 1
            prefetchedOffset += 1
        }
        if (copied == wanted) {
            return copied
        }
        let remaining = wanted - copied
        let tmp = Array<UInt8>(remaining, repeat: 0)
        let n = socket.read(tmp)
        if (n <= 0) {
            return copied
        }
        var i: Int64 = 0
        while (i < n) {
            outBuf[copied + i] = tmp[i]
            i += 1
        }
        copied + n
    }

    func readByte(): Int64 {
        let one = Array<UInt8>(1, repeat: 0)
        let n = readAtMost(one, 1)
        if (n <= 0) {
            return -1
        }
        Int64(one[0])
    }

    func readLine(): String {
        let out = ArrayList<UInt8>()
        while (out.size <= 8192) {
            let value = readByte()
            if (value < 0) {
                throw Exception("native H1 response line is incomplete")
            }
            if (value == 13) {
                if (readByte() != 10) {
                    throw Exception("native H1 response line terminator is invalid")
                }
                return String.fromUtf8(out.toArray())
            }
            out.add(UInt8(value))
        }
        throw Exception("native H1 response line exceeds 8192 bytes")
    }

    func hasUnreadPrefetched(): Bool {
        prefetchedOffset < prefetched.size
    }
}

class NativeH1ClientResponseInputStream <: InputStream & Resource {
    let reader: NativeH1ClientSocketReader
    let socket: TcpSocket
    let mode: String
    var remaining: Int64
    var chunkRemaining: Int64 = 0
    var closed: Bool = false
    let pool: NativeH1ClientConnectionPool
    let origin: String
    let reusable: Bool

    init(
        socket: TcpSocket,
        prefetched: Array<UInt8>,
        mode: String,
        remaining: Int64,
        pool: NativeH1ClientConnectionPool,
        origin: String,
        reusable: Bool
    ) {
        this.socket = socket
        this.reader = NativeH1ClientSocketReader(socket, prefetched)
        this.mode = mode
        this.remaining = remaining
        this.pool = pool
        this.origin = origin
        this.reusable = reusable
    }

    public override func read(outBuf: Array<Byte>): Int64 {
        if (closed || outBuf.size == 0) {
            return 0
        }
        try {
            if (mode == "length") {
                return readLengthBody(outBuf)
            }
            if (mode == "chunked") {
                return readChunkedBody(outBuf)
            }
            readCloseDelimitedBody(outBuf)
        } catch (e: Exception) {
            close()
            throw e
        }
    }

    public func close(): Unit {
        if (closed) {
            return
        }
        closed = true
        closeNativeH1Socket(socket)
    }

    public func isClosed(): Bool {
        closed
    }

    func readLengthBody(outBuf: Array<Byte>): Int64 {
        if (remaining <= 0) {
            close()
            return 0
        }
        let n = reader.readAtMost(outBuf, remaining)
        if (n <= 0) {
            throw Exception("native H1 response Content-Length is incomplete")
        }
        remaining -= n
        if (remaining == 0) {
            finish()
        }
        n
    }

    func readCloseDelimitedBody(outBuf: Array<Byte>): Int64 {
        let n = reader.readAtMost(outBuf, outBuf.size)
        if (n <= 0) {
            finish()
            return 0
        }
        n
    }

    func readChunkedBody(outBuf: Array<Byte>): Int64 {
        var total: Int64 = 0
        while (total < outBuf.size) {
            if (chunkRemaining == 0) {
                let sizeLine = reader.readLine().trimAscii()
                let semicolon = nativeH1IndexOf(sizeLine, ";")
                let sizeText = if (semicolon >= 0) {
                    nativeH1RuneSlice(sizeLine.toRuneArray(), 0, semicolon)
                } else {
                    sizeLine
                }
                chunkRemaining = parseNativeH1Hex(sizeText)
                if (chunkRemaining < 0) {
                    throw Exception("native H1 chunk size is invalid")
                }
                if (chunkRemaining == 0) {
                    consumeTrailers()
                    finish()
                    return total
                }
            }

            let wanted = if (chunkRemaining < outBuf.size - total) {
                chunkRemaining
            } else {
                outBuf.size - total
            }
            let tmp = Array<UInt8>(wanted, repeat: 0)
            let n = reader.readAtMost(tmp, wanted)
            if (n <= 0) {
                throw Exception("native H1 chunk payload is incomplete")
            }
            var i: Int64 = 0
            while (i < n) {
                outBuf[total + i] = tmp[i]
                i += 1
            }
            total += n
            chunkRemaining -= n
            if (chunkRemaining == 0) {
                if (reader.readByte() != 13 || reader.readByte() != 10) {
                    throw Exception("native H1 chunk terminator is invalid")
                }
            }
        }
        total
    }

    func consumeTrailers(): Unit {
        while (true) {
            if (reader.readLine().size == 0) {
                return
            }
        }
    }

    func finish(): Unit {
        if (closed) {
            return
        }
        closed = true
        if (reusable && !reader.hasUnreadPrefetched() && !socket.isClosed()) {
            pool.release(origin, socket)
        } else {
            closeNativeH1Socket(socket)
        }
    }
}

func sendNativeH1Request(
    method: String,
    url: String,
    headers: HashMap<String, String>,
    body: Array<UInt8>,
    bodyStream: ?InputStream,
    bodyStreamLength: Int64,
    readTimeout: Duration,
    writeTimeout: Duration,
    pool: NativeH1ClientConnectionPool
): ClientResponse {
    let target = parseNativeH1Target(url)
    if (target.scheme != "http") {
        throw Exception("native H1 cleartext transport requires http://")
    }
    let origin = nativeH1PoolOrigin(target)
    let requestReusable = pool.enabled() && !nativeH1HeaderValueContains(headers, "connection", "close")
    var pooled: ?TcpSocket = None
    if (requestReusable) {
        pooled = pool.acquire(origin)
    }
    var reused = false
    let socket = match (pooled) {
        case Some(existing) =>
            reused = true
            existing
        case None => TcpSocket(target.host, target.port)
    }
    socket.readTimeout = Some(readTimeout)
    socket.writeTimeout = Some(writeTimeout)
    if (!reused) {
        try {
            socket.connect(timeout: Some(readTimeout))
        } catch (e: Exception) {
            throw Exception("native H1 network connect failed: " + e.message)
        }
    }
    var transferred = false
    try {
        let contentLength = if (bodyStream.isSome()) { bodyStreamLength } else { body.size }
        try {
            socket.write(buildNativeH1RequestHead(method, target, headers, contentLength, requestReusable))
            match (bodyStream) {
                case Some(stream) => writeNativeH1RequestStream(socket, stream, bodyStreamLength)
                case None =>
                    if (body.size > 0) {
                        socket.write(body)
                    }
            }
        } catch (e: Exception) {
            throw Exception("native H1 network write failed: " + e.message)
        }
        let response = try {
            readNativeH1Response(socket, method, pool, origin, requestReusable)
        } catch (e: Exception) {
            throw Exception("native H1 network read failed: " + e.message)
        }
        transferred = true
        response
    } finally {
        if (!transferred) {
            closeNativeH1Socket(socket)
        }
    }
}

func parseNativeH1Target(rawUrl: String): NativeH1ClientTarget {
    let url = rawUrl.trimAscii()
    let lower = url.toAsciiLower()
    let scheme = if (nativeH1StartsWith(lower, "https://")) {
        "https"
    } else if (nativeH1StartsWith(lower, "http://")) {
        "http"
    } else {
        throw Exception("native H1 client URL scheme must be http or https")
    }
    let runes = url.toRuneArray()
    var index: Int64 = if (scheme == "https") { 8 } else { 7 }
    var authority = ""
    while (index < runes.size) {
        let ch = runes[index]
        if (ch == r'/' || ch == r'?' || ch == r'#') {
            break
        }
        authority += ch.toString()
        index += 1
    }
    if (authority.size == 0) {
        throw Exception("native H1 client URL host is empty")
    }
    var requestTarget = "/"
    if (index < runes.size) {
        if (runes[index] == r'/') {
            requestTarget = nativeH1RuneSlice(runes, index, runes.size)
        } else if (runes[index] == r'?') {
            requestTarget = "/" + nativeH1RuneSlice(runes, index, runes.size)
        }
    }
    let fragmentIndex = nativeH1IndexOf(requestTarget, "#")
    if (fragmentIndex >= 0) {
        requestTarget = nativeH1RuneSlice(requestTarget.toRuneArray(), 0, fragmentIndex)
    }

    var host = authority
    var port: UInt16 = if (scheme == "https") { UInt16(443) } else { UInt16(80) }
    if (nativeH1StartsWith(authority, "[")) {
        let closing = nativeH1IndexOf(authority, "]")
        if (closing <= 1) {
            throw Exception("native H1 client IPv6 authority is invalid")
        }
        let authorityRunes = authority.toRuneArray()
        host = nativeH1RuneSlice(authorityRunes, 1, closing)
        if (closing + 1 < authorityRunes.size) {
            if (authorityRunes[closing + 1] != r':') {
                throw Exception("native H1 client IPv6 authority suffix is invalid")
            }
            let portText = nativeH1RuneSlice(authorityRunes, closing + 2, authorityRunes.size)
            port = parseNativeH1Port(portText)
        }
    } else {
        let colon = nativeH1LastIndexOf(authority, ":")
        if (colon > 0) {
            if (nativeH1IndexOf(authority, ":") != colon) {
                throw Exception("native H1 client IPv6 URL must use brackets")
            }
            let authorityRunes = authority.toRuneArray()
            let portText = nativeH1RuneSlice(authorityRunes, colon + 1, authorityRunes.size)
            port = parseNativeH1Port(portText)
            host = nativeH1RuneSlice(authorityRunes, 0, colon)
        }
    }
    if (host.size == 0) {
        throw Exception("native H1 client URL host is empty")
    }
    NativeH1ClientTarget(scheme, host, port, requestTarget, authority)
}

func buildNativeH1RequestHead(
    method: String,
    target: NativeH1ClientTarget,
    headers: HashMap<String, String>,
    contentLength: Int64,
    requestReusable: Bool
): Array<UInt8> {
    var head = method.trimAscii().toAsciiUpper() + " " + target.requestTarget + " HTTP/1.1\r\n"
    if (!nativeH1HasHeader(headers, "host")) {
        head += "Host: " + target.hostHeader + "\r\n"
    }
    for ((name, value) in headers) {
        head += name + ": " + value + "\r\n"
    }
    if (!nativeH1HasHeader(headers, "connection")) {
        head += if (requestReusable) { "Connection: keep-alive\r\n" } else { "Connection: close\r\n" }
    }
    if (contentLength > 0 && !nativeH1HasHeader(headers, "content-length") &&
        !nativeH1HasHeader(headers, "transfer-encoding")) {
        head += "Content-Length: ${contentLength}\r\n"
    }
    head += "\r\n"
    head.toArray()
}

func writeNativeH1RequestStream(
    socket: TcpSocket,
    stream: InputStream,
    contentLength: Int64
): Unit {
    var remaining = contentLength
    while (remaining > 0) {
        let wanted = if (remaining < 8192) { remaining } else { 8192 }
        let tmp = Array<UInt8>(wanted, repeat: 0)
        let n = stream.read(tmp)
        if (n <= 0) {
            throw Exception("native H1 request body stream ended before Content-Length")
        }
        if (n > remaining) {
            throw Exception("native H1 request body stream exceeded Content-Length")
        }
        socket.write(nativeH1ByteSlice(tmp, 0, n))
        remaining -= n
    }
}

func readNativeH1ResponseHeader(socket: TcpSocket): NativeH1ClientHeaderReadResult {
    readNativeH1ResponseHeader(socket, Array<UInt8>())
}

func readNativeH1ResponseHeader(
    socket: TcpSocket,
    prefetched: Array<UInt8>
): NativeH1ClientHeaderReadResult {
    let out = ArrayList<UInt8>()
    for (value in prefetched) {
        out.add(value)
    }
    let buf = Array<UInt8>(4096, repeat: 0)
    while (out.size <= 65536) {
        let bytes = out.toArray()
        let headerEnd = nativeH1IndexOfBytes(bytes, "\r\n\r\n".toArray(), 0)
        if (headerEnd >= 0) {
            return NativeH1ClientHeaderReadResult(
                nativeH1ByteSlice(bytes, 0, headerEnd),
                nativeH1ByteSlice(bytes, headerEnd + 4, bytes.size)
            )
        }
        let n = socket.read(buf)
        if (n <= 0) {
            throw Exception("native H1 response closed before headers completed")
        }
        var i: Int64 = 0
        while (i < n) {
            out.add(buf[i])
            i += 1
        }
    }
    throw Exception("native H1 response headers exceed 65536 bytes")
}

func parseNativeH1ResponseHead(headerBytes: Array<UInt8>): NativeH1ClientParsedResponseHead {
    let headerText = String.fromUtf8(headerBytes)
    let lines = headerText.split("\r\n")
    if (lines.size == 0) {
        throw Exception("native H1 response is missing status line")
    }
    let statusParts = lines[0].split(" ", 3)
    if (statusParts.size < 2) {
        throw Exception("native H1 response status line is invalid")
    }
    if (statusParts[0] != "HTTP/1.1") {
        throw Exception("native H1 response version must be HTTP/1.1")
    }
    let statusValue = parseNativeH1Decimal(statusParts[1])
    if (statusValue < 100 || statusValue > 999) {
        throw Exception("native H1 response status is invalid")
    }
    let headers = HttpHeaders()
    var lineIndex: Int64 = 1
    while (lineIndex < lines.size) {
        let line = lines[lineIndex]
        let colon = nativeH1IndexOf(line, ":")
        if (colon <= 0) {
            throw Exception("native H1 response header line is malformed")
        }
        let runes = line.toRuneArray()
        let name = nativeH1RuneSlice(runes, 0, colon)
        if (!isNativeH1ResponseHeaderName(name)) {
            throw Exception("native H1 response header name is invalid")
        }
        let rawValue = nativeH1RuneSlice(runes, colon + 1, runes.size)
        validateNativeH1ResponseHeaderValue(rawValue)
        headers.add(name, rawValue.trimAscii())
        lineIndex += 1
    }
    NativeH1ClientParsedResponseHead(statusParts[0], statusValue, headers)
}

func isNativeH1ResponseHeaderName(input: String): Bool {
    if (input.size == 0) {
        return false
    }
    for (byte in input.toArray()) {
        if (!nativeH1ResponseTokenByteAllowed(byte)) {
            return false
        }
    }
    true
}

func nativeH1ResponseTokenByteAllowed(code: UInt8): Bool {
    (code >= UInt8(48) && code <= UInt8(57)) ||
    (code >= UInt8(65) && code <= UInt8(90)) ||
    (code >= UInt8(97) && code <= UInt8(122)) ||
    code == UInt8(33) ||
    (code >= UInt8(35) && code <= UInt8(39)) ||
    code == UInt8(42) ||
    code == UInt8(43) ||
    code == UInt8(45) ||
    code == UInt8(46) ||
    code == UInt8(94) ||
    code == UInt8(95) ||
    code == UInt8(96) ||
    code == UInt8(124) ||
    code == UInt8(126)
}

func validateNativeH1ResponseHeaderValue(value: String): Unit {
    for (byte in value.toArray()) {
        if ((byte < UInt8(32) && byte != UInt8(9)) || byte == UInt8(127)) {
            throw Exception("native H1 response header value contains a forbidden control byte")
        }
    }
}

func readNativeH1Response(
    socket: TcpSocket,
    method: String,
    pool: NativeH1ClientConnectionPool,
    origin: String,
    requestReusable: Bool
): ClientResponse {
    var readResult = readNativeH1ResponseHeader(socket)
    var parsedHead = parseNativeH1ResponseHead(readResult.headerBytes)
    var interimCount: Int64 = 0
    while (parsedHead.status >= 100 && parsedHead.status < 200 && parsedHead.status != 101) {
        interimCount += 1
        if (interimCount > 8) {
            throw Exception("native H1 response exceeds 8 interim responses")
        }
        readResult = readNativeH1ResponseHeader(socket, readResult.prefetchedBody)
        parsedHead = parseNativeH1ResponseHead(readResult.headerBytes)
    }
    let statusValue = parsedHead.status
    let headers = parsedHead.headers
    let framing = resolveNativeH1ResponseFraming(headers)
    let responseReusable = requestReusable && parsedHead.version == "HTTP/1.1" && statusValue != 101 &&
        !nativeH1HeaderContains(headers, "connection", "close")
    if (method.trimAscii().toAsciiUpper() == "HEAD" ||
        statusValue == 204 || statusValue == 304) {
        settleNativeH1BodylessSocket(socket, pool, origin, responseReusable, readResult.prefetchedBody)
        return ClientResponse(UInt16(statusValue), headers, NativeH1ClientBytesInputStream(Array<UInt8>()))
    }
    if (framing.mode == "chunked") {
        let stream = NativeH1ClientResponseInputStream(
            socket, readResult.prefetchedBody, "chunked", -1, pool, origin, responseReusable
        )
        return ClientResponse(
            UInt16(statusValue),
            headers,
            stream,
            closeHook: { => stream.close() }
        )
    }
    if (framing.mode == "length") {
        let length = framing.contentLength
        if (length == 0) {
            settleNativeH1BodylessSocket(socket, pool, origin, responseReusable, readResult.prefetchedBody)
            return ClientResponse(UInt16(statusValue), headers, NativeH1ClientBytesInputStream(Array<UInt8>()))
        }
        let stream = NativeH1ClientResponseInputStream(
            socket, readResult.prefetchedBody, "length", length, pool, origin, responseReusable
        )
        return ClientResponse(
            UInt16(statusValue),
            headers,
            stream,
            closeHook: { => stream.close() }
        )
    }
    let stream = NativeH1ClientResponseInputStream(
        socket, readResult.prefetchedBody, "close", -1, pool, origin, false
    )
    ClientResponse(
        UInt16(statusValue),
        headers,
        stream,
        closeHook: { => stream.close() }
    )
}

func resolveNativeH1ResponseFraming(headers: HttpHeaders): NativeH1ResponseFraming {
    let transferEncodingValues = collectNativeH1ResponseHeaderValues(headers, "transfer-encoding")
    let contentLengthValues = collectNativeH1ResponseHeaderValues(headers, "content-length")
    if (transferEncodingValues.size > 0 && contentLengthValues.size > 0) {
        throw Exception("native H1 response mixes Transfer-Encoding and Content-Length")
    }
    if (transferEncodingValues.size > 0) {
        let tokens = parseNativeH1ResponseCommaTokens(transferEncodingValues, "Transfer-Encoding")
        if (tokens.size != 1 || tokens[0] != "chunked") {
            throw Exception("native H1 response Transfer-Encoding is unsupported")
        }
        return NativeH1ResponseFraming("chunked", -1)
    }
    if (contentLengthValues.size > 0) {
        let values = parseNativeH1ResponseCommaTokens(contentLengthValues, "Content-Length")
        var selected: ?Int64 = None
        for (value in values) {
            let parsed = parseNativeH1Decimal(value)
            if (parsed < 0) {
                throw Exception("native H1 response Content-Length is invalid")
            }
            match (selected) {
                case Some(existing) =>
                    if (existing != parsed) {
                        throw Exception("native H1 response Content-Length values conflict")
                    }
                case None => selected = Some(parsed)
            }
        }
        return NativeH1ResponseFraming("length", selected ?? 0)
    }
    NativeH1ResponseFraming("close", -1)
}

func collectNativeH1ResponseHeaderValues(headers: HttpHeaders, name: String): Array<String> {
    let out = ArrayList<String>()
    for (value in headers.get(name)) {
        out.add(value)
    }
    out.toArray()
}

func parseNativeH1ResponseCommaTokens(values: Array<String>, name: String): Array<String> {
    let out = ArrayList<String>()
    for (value in values) {
        for (part in value.split(",")) {
            let token = part.trimAscii().toAsciiLower()
            if (token.size == 0) {
                throw Exception("native H1 response ${name} is invalid")
            }
            out.add(token)
        }
    }
    out.toArray()
}

func settleNativeH1BodylessSocket(
    socket: TcpSocket,
    pool: NativeH1ClientConnectionPool,
    origin: String,
    reusable: Bool,
    prefetchedBody: Array<UInt8>
): Unit {
    if (reusable && prefetchedBody.size == 0 && !socket.isClosed()) {
        pool.release(origin, socket)
    } else {
        closeNativeH1Socket(socket)
    }
}

func nativeH1PoolOrigin(target: NativeH1ClientTarget): String {
    let host = target.host.toAsciiLower()
    if (nativeH1IndexOf(host, ":") >= 0) {
        return target.scheme + "://[" + host + "]:" + target.port.toString()
    }
    target.scheme + "://" + host + ":" + target.port.toString()
}

func parseNativeH1Port(portText: String): UInt16 {
    let parsedPort = parseNativeH1Decimal(portText)
    if (parsedPort <= 0 || parsedPort > 65535) {
        throw Exception("native H1 client URL port is invalid")
    }
    UInt16(parsedPort)
}

func cloneNativeH1Headers(input: HashMap<String, String>): HashMap<String, String> {
    let out = HashMap<String, String>()
    for ((name, value) in input) {
        out.add(name, value)
    }
    out
}

func removeNativeH1Header(headers: HashMap<String, String>, target: String): Unit {
    let names = ArrayList<String>()
    for ((name, _value) in headers) {
        if (name.trimAscii().toAsciiLower() == target) {
            names.add(name)
        }
    }
    for (name in names) {
        let _ = headers.remove(name)
    }
}

func resolveNativeH1RedirectUrl(currentUrl: String, rawLocation: String): String {
    let location = rawLocation.trimAscii()
    if (location.size == 0) {
        throw Exception("native H1 redirect Location is empty")
    }
    let lower = location.toAsciiLower()
    if (nativeH1StartsWith(lower, "http://") || nativeH1StartsWith(lower, "https://")) {
        return location
    }
    let current = parseNativeH1Target(currentUrl)
    if (nativeH1StartsWith(location, "//")) {
        return current.scheme + ":" + location
    }
    let origin = current.scheme + "://" + current.hostHeader
    if (nativeH1StartsWith(location, "/")) {
        return origin + location
    }
    var path = current.requestTarget
    let query = nativeH1IndexOf(path, "?")
    if (query >= 0) {
        path = nativeH1RuneSlice(path.toRuneArray(), 0, query)
    }
    let slash = nativeH1LastIndexOf(path, "/")
    let basePath = if (slash >= 0) {
        nativeH1RuneSlice(path.toRuneArray(), 0, slash + 1)
    } else {
        "/"
    }
    origin + basePath + location
}

func closeNativeH1Socket(socket: TcpSocket): Unit {
    if (!socket.isClosed()) {
        try {
            socket.close()
        } catch (_: Exception) {}
    }
}

func nativeH1HasHeader(headers: HashMap<String, String>, target: String): Bool {
    for ((name, _value) in headers) {
        if (name.trimAscii().toAsciiLower() == target) {
            return true
        }
    }
    false
}

func nativeH1HeaderValueContains(
    headers: HashMap<String, String>,
    name: String,
    target: String
): Bool {
    for ((candidateName, value) in headers) {
        if (candidateName.trimAscii().toAsciiLower() == name &&
            nativeH1IndexOf(value.toAsciiLower(), target.toAsciiLower()) >= 0) {
            return true
        }
    }
    false
}

func nativeH1HeaderContains(headers: HttpHeaders, name: String, target: String): Bool {
    for (value in headers.get(name)) {
        if (nativeH1IndexOf(value.toAsciiLower(), target.toAsciiLower()) >= 0) {
            return true
        }
    }
    false
}

func nativeH1IndexOfBytes(input: Array<UInt8>, target: Array<UInt8>, start: Int64): Int64 {
    if (target.size == 0) {
        return start
    }
    var i = start
    while (i + target.size <= input.size) {
        var matched = true
        var j: Int64 = 0
        while (j < target.size) {
            if (input[i + j] != target[j]) {
                matched = false
                break
            }
            j += 1
        }
        if (matched) {
            return i
        }
        i += 1
    }
    -1
}

func nativeH1ByteSlice(input: Array<UInt8>, start: Int64, end: Int64): Array<UInt8> {
    let out = Array<UInt8>(end - start, repeat: 0)
    var i: Int64 = 0
    while (start + i < end) {
        out[i] = input[start + i]
        i += 1
    }
    out
}

func cloneNativeH1Bytes(input: Array<UInt8>): Array<UInt8> {
    nativeH1ByteSlice(input, 0, input.size)
}

func nativeH1StartsWith(text: String, prefix: String): Bool {
    nativeH1IndexOf(text, prefix) == 0
}

func nativeH1IndexOf(text: String, target: String): Int64 {
    let input = text.toRuneArray()
    let expected = target.toRuneArray()
    if (expected.size == 0) {
        return 0
    }
    var i: Int64 = 0
    while (i + expected.size <= input.size) {
        var matched = true
        var j: Int64 = 0
        while (j < expected.size) {
            if (input[i + j] != expected[j]) {
                matched = false
                break
            }
            j += 1
        }
        if (matched) {
            return i
        }
        i += 1
    }
    -1
}

func nativeH1LastIndexOf(text: String, target: String): Int64 {
    let input = text.toRuneArray()
    let expected = target.toRuneArray()
    if (expected.size == 0 || input.size < expected.size) {
        return -1
    }
    var i = input.size - expected.size
    while (i >= 0) {
        var matched = true
        var j: Int64 = 0
        while (j < expected.size) {
            if (input[i + j] != expected[j]) {
                matched = false
                break
            }
            j += 1
        }
        if (matched) {
            return i
        }
        i -= 1
    }
    -1
}

func nativeH1RuneSlice(input: Array<Rune>, start: Int64, end: Int64): String {
    var out = ""
    var i = start
    while (i < end) {
        out += input[i].toString()
        i += 1
    }
    out
}

func parseNativeH1Decimal(text: String): Int64 {
    let digits = text.trimAscii().toRuneArray()
    if (digits.size == 0) {
        return -1
    }
    var value: Int64 = 0
    for (ch in digits) {
        if (ch < r'0' || ch > r'9') {
            return -1
        }
        value = value * 10 + Int64(UInt32(ch) - UInt32(r'0'))
    }
    value
}

func parseNativeH1Hex(text: String): Int64 {
    let digits = text.trimAscii().toAsciiLower().toRuneArray()
    if (digits.size == 0) {
        return -1
    }
    var value: Int64 = 0
    for (ch in digits) {
        var digit: Int64 = -1
        if (ch >= r'0' && ch <= r'9') {
            digit = Int64(UInt32(ch) - UInt32(r'0'))
        } else if (ch >= r'a' && ch <= r'f') {
            digit = 10 + Int64(UInt32(ch) - UInt32(r'a'))
        }
        if (digit < 0) {
            return -1
        }
        value = value * 16 + digit
    }
    value
}
