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

func sendNativeH1Request(
    method: String,
    url: String,
    headers: HashMap<String, String>,
    body: Array<UInt8>
): ClientResponse {
    let target = parseNativeH1Target(url)
    let socket = TcpSocket(target.host, target.port)
    socket.connect()
    try {
        socket.write(buildNativeH1RequestWire(method, target, headers, body))
        let responseWire = readNativeH1ResponseWire(socket)
        parseNativeH1Response(responseWire, method)
    } finally {
        if (!socket.isClosed()) {
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

func readNativeH1ResponseWire(socket: TcpSocket): Array<UInt8> {
    let out = ArrayList<UInt8>()
    let buf = Array<UInt8>(8192, repeat: 0)
    while (true) {
        let n = socket.read(buf)
        if (n <= 0) {
            break
        }
        var i: Int64 = 0
        while (i < n) {
            out.add(buf[i])
            i += 1
        }
    }
    out.toArray()
}

func parseNativeH1Response(wire: Array<UInt8>, method: String): ClientResponse {
    let headerEnd = nativeH1IndexOfBytes(wire, "\r\n\r\n".toArray(), 0)
    if (headerEnd < 0) {
        throw Exception("native H1 response is missing header terminator")
    }
    let headerText = String.fromUtf8(nativeH1ByteSlice(wire, 0, headerEnd))
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
    let framedBody = nativeH1ByteSlice(wire, headerEnd + 4, wire.size)
    let body = if (method.trimAscii().toAsciiUpper() == "HEAD" ||
        statusValue == 204 || statusValue == 304) {
        Array<UInt8>()
    } else if (nativeH1HeaderContains(headers, "transfer-encoding", "chunked")) {
        decodeNativeH1ChunkedBody(framedBody)
    } else if (let Some(lengthText) <- headers.getFirst("content-length")) {
        let length = parseNativeH1Decimal(lengthText)
        if (length < 0 || framedBody.size < length) {
            throw Exception("native H1 response Content-Length is incomplete")
        }
        nativeH1ByteSlice(framedBody, 0, length)
    } else {
        framedBody
    }
    ClientResponse(UInt16(statusValue), headers, NativeH1ClientBytesInputStream(body))
}

func decodeNativeH1ChunkedBody(wire: Array<UInt8>): Array<UInt8> {
    let out = ArrayList<UInt8>()
    var offset: Int64 = 0
    while (true) {
        let lineEnd = nativeH1IndexOfBytes(wire, "\r\n".toArray(), offset)
        if (lineEnd < 0) {
            throw Exception("native H1 chunk size line is incomplete")
        }
        let sizeLine = String.fromUtf8(nativeH1ByteSlice(wire, offset, lineEnd)).trimAscii()
        let semicolon = nativeH1IndexOf(sizeLine, ";")
        let sizeText = if (semicolon >= 0) {
            nativeH1RuneSlice(sizeLine.toRuneArray(), 0, semicolon)
        } else {
            sizeLine
        }
        let chunkSize = parseNativeH1Hex(sizeText)
        offset = lineEnd + 2
        if (chunkSize == 0) {
            return out.toArray()
        }
        if (chunkSize < 0 || offset + chunkSize + 2 > wire.size) {
            throw Exception("native H1 chunk payload is incomplete")
        }
        var i: Int64 = 0
        while (i < chunkSize) {
            out.add(wire[offset + i])
            i += 1
        }
        offset += chunkSize
        if (wire[offset] != UInt8(13) || wire[offset + 1] != UInt8(10)) {
            throw Exception("native H1 chunk terminator is invalid")
        }
        offset += 2
    }
    out.toArray()
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
