package ignite.client

import std.collection.{ArrayList, HashMap}
import std.io.InputStream
import std.net.TcpSocket
import stdx.net.http.HttpHeaders

let NATIVE_H1_CLIENT_BACKEND = "ignite-native-h1-client"

class NativeH1ClientTarget {
    let host: String
    let port: UInt16
    let requestTarget: String
    let hostHeader: String

    init(host: String, port: UInt16, requestTarget: String, hostHeader: String) {
        this.host = host
        this.port = port
        this.requestTarget = requestTarget
        this.hostHeader = hostHeader
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
}

class NativeH1ClientResponseInputStream <: InputStream & Resource {
    let reader: NativeH1ClientSocketReader
    let socket: TcpSocket
    let mode: String
    var remaining: Int64
    var chunkRemaining: Int64 = 0
    var closed: Bool = false

    init(
        socket: TcpSocket,
        prefetched: Array<UInt8>,
        mode: String,
        remaining: Int64
    ) {
        this.socket = socket
        this.reader = NativeH1ClientSocketReader(socket, prefetched)
        this.mode = mode
        this.remaining = remaining
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
        if (!socket.isClosed()) {
            socket.close()
        }
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
            close()
        }
        n
    }

    func readCloseDelimitedBody(outBuf: Array<Byte>): Int64 {
        let n = reader.readAtMost(outBuf, outBuf.size)
        if (n <= 0) {
            close()
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
                    close()
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
}

func sendNativeH1Request(
    method: String,
    url: String,
    headers: HashMap<String, String>,
    body: Array<UInt8>,
    readTimeout: Duration,
    writeTimeout: Duration
): ClientResponse {
    let target = parseNativeH1Target(url)
    let socket = TcpSocket(target.host, target.port)
    socket.readTimeout = Some(readTimeout)
    socket.writeTimeout = Some(writeTimeout)
    socket.connect(timeout: Some(readTimeout))
    var transferred = false
    try {
        socket.write(buildNativeH1RequestWire(method, target, headers, body))
        let response = readNativeH1Response(socket, method)
        transferred = true
        response
    } finally {
        if (!transferred && !socket.isClosed()) {
            socket.close()
        }
    }
}

func parseNativeH1Target(rawUrl: String): NativeH1ClientTarget {
    let url = rawUrl.trimAscii()
    if (!nativeH1StartsWith(url.toAsciiLower(), "http://")) {
        throw Exception("native H1 client first slice supports http:// only")
    }
    let runes = url.toRuneArray()
    var index: Int64 = 7
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
    var port: UInt16 = 80
    let colon = nativeH1LastIndexOf(authority, ":")
    if (colon > 0) {
        let portText = nativeH1RuneSlice(authority.toRuneArray(), colon + 1, authority.toRuneArray().size)
        let parsedPort = parseNativeH1Decimal(portText)
        if (parsedPort <= 0 || parsedPort > 65535) {
            throw Exception("native H1 client URL port is invalid")
        }
        host = nativeH1RuneSlice(authority.toRuneArray(), 0, colon)
        port = UInt16(parsedPort)
    }
    if (host.size == 0) {
        throw Exception("native H1 client URL host is empty")
    }
    NativeH1ClientTarget(host, port, requestTarget, authority)
}

func buildNativeH1RequestWire(
    method: String,
    target: NativeH1ClientTarget,
    headers: HashMap<String, String>,
    body: Array<UInt8>
): Array<UInt8> {
    var head = method.trimAscii().toAsciiUpper() + " " + target.requestTarget + " HTTP/1.1\r\n"
    if (!nativeH1HasHeader(headers, "host")) {
        head += "Host: " + target.hostHeader + "\r\n"
    }
    for ((name, value) in headers) {
        head += name + ": " + value + "\r\n"
    }
    if (!nativeH1HasHeader(headers, "connection")) {
        head += "Connection: close\r\n"
    }
    if (body.size > 0 && !nativeH1HasHeader(headers, "content-length") &&
        !nativeH1HasHeader(headers, "transfer-encoding")) {
        head += "Content-Length: ${body.size}\r\n"
    }
    head += "\r\n"
    let headBytes = head.toArray()
    let out = Array<UInt8>(headBytes.size + body.size, repeat: 0)
    var i: Int64 = 0
    while (i < headBytes.size) {
        out[i] = headBytes[i]
        i += 1
    }
    var j: Int64 = 0
    while (j < body.size) {
        out[headBytes.size + j] = body[j]
        j += 1
    }
    out
}

func readNativeH1ResponseHeader(socket: TcpSocket): NativeH1ClientHeaderReadResult {
    let out = ArrayList<UInt8>()
    let buf = Array<UInt8>(4096, repeat: 0)
    while (out.size <= 65536) {
        let n = socket.read(buf)
        if (n <= 0) {
            throw Exception("native H1 response closed before headers completed")
        }
        var i: Int64 = 0
        while (i < n) {
            out.add(buf[i])
            i += 1
        }
        let bytes = out.toArray()
        let headerEnd = nativeH1IndexOfBytes(bytes, "\r\n\r\n".toArray(), 0)
        if (headerEnd >= 0) {
            return NativeH1ClientHeaderReadResult(
                nativeH1ByteSlice(bytes, 0, headerEnd),
                nativeH1ByteSlice(bytes, headerEnd + 4, bytes.size)
            )
        }
    }
    throw Exception("native H1 response headers exceed 65536 bytes")
}

func readNativeH1Response(socket: TcpSocket, method: String): ClientResponse {
    let readResult = readNativeH1ResponseHeader(socket)
    let headerText = String.fromUtf8(readResult.headerBytes)
    let lines = headerText.split("\r\n")
    if (lines.size == 0) {
        throw Exception("native H1 response is missing status line")
    }
    let statusParts = lines[0].split(" ", 3)
    if (statusParts.size < 2) {
        throw Exception("native H1 response status line is invalid")
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
        if (colon > 0) {
            let runes = line.toRuneArray()
            let name = nativeH1RuneSlice(runes, 0, colon).trimAscii()
            let value = nativeH1RuneSlice(runes, colon + 1, runes.size).trimAscii()
            headers.add(name, value)
        }
        lineIndex += 1
    }
    if (method.trimAscii().toAsciiUpper() == "HEAD" ||
        statusValue == 204 || statusValue == 304) {
        if (!socket.isClosed()) {
            socket.close()
        }
        return ClientResponse(UInt16(statusValue), headers, NativeH1ClientBytesInputStream(Array<UInt8>()))
    }
    if (nativeH1HeaderContains(headers, "transfer-encoding", "chunked")) {
        let stream = NativeH1ClientResponseInputStream(socket, readResult.prefetchedBody, "chunked", -1)
        return ClientResponse(
            UInt16(statusValue),
            headers,
            stream,
            closeHook: { => stream.close() }
        )
    }
    if (let Some(lengthText) <- headers.getFirst("content-length")) {
        let length = parseNativeH1Decimal(lengthText)
        if (length < 0) {
            throw Exception("native H1 response Content-Length is invalid")
        }
        if (length == 0) {
            if (!socket.isClosed()) {
                socket.close()
            }
            return ClientResponse(UInt16(statusValue), headers, NativeH1ClientBytesInputStream(Array<UInt8>()))
        }
        let stream = NativeH1ClientResponseInputStream(socket, readResult.prefetchedBody, "length", length)
        return ClientResponse(
            UInt16(statusValue),
            headers,
            stream,
            closeHook: { => stream.close() }
        )
    }
    let stream = NativeH1ClientResponseInputStream(socket, readResult.prefetchedBody, "close", -1)
    ClientResponse(
        UInt16(statusValue),
        headers,
        stream,
        closeHook: { => stream.close() }
    )
}

func nativeH1HasHeader(headers: HashMap<String, String>, target: String): Bool {
    for ((name, _value) in headers) {
        if (name.trimAscii().toAsciiLower() == target) {
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
