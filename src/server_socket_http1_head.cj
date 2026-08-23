package ignite

import std.collection.ArrayList

public enum SocketHttp11HeadErrorCode <: Equatable<SocketHttp11HeadErrorCode> & ToString {
    | LimitExceeded
    | MalformedRequestLine
    | UnsupportedVersion
    | MalformedHeader
    | InvalidHeaderName

    public operator func ==(right: SocketHttp11HeadErrorCode): Bool {
        ordinalValue() == right.ordinalValue()
    }

    public operator func !=(right: SocketHttp11HeadErrorCode): Bool {
        !(this == right)
    }

    public func ordinalValue(): Int64 {
        match (this) {
            case LimitExceeded => 0
            case MalformedRequestLine => 1
            case UnsupportedVersion => 2
            case MalformedHeader => 3
            case InvalidHeaderName => 4
        }
    }

    public func toString(): String {
        match (this) {
            case LimitExceeded => "LIMIT_EXCEEDED"
            case MalformedRequestLine => "MALFORMED_REQUEST_LINE"
            case UnsupportedVersion => "UNSUPPORTED_VERSION"
            case MalformedHeader => "MALFORMED_HEADER"
            case InvalidHeaderName => "INVALID_HEADER_NAME"
        }
    }
}

public class SocketHttp11HeadException <: Exception {
    public let code: SocketHttp11HeadErrorCode

    public init(code: SocketHttp11HeadErrorCode, message: String) {
        super(message)
        this.code = code
    }
}

public struct SocketHttp11Header {
    public let name: String
    public let value: String

    public init(name: String, value: String) {
        this.name = name
        this.value = value
    }
}

public class SocketHttp11RequestHead {
    public let method: String
    public let target: String
    public let version: String
    public let headers: Array<SocketHttp11Header>
    public let headBytes: Int64
    public let bodyOffset: Int64

    public init(
        method: String,
        target: String,
        version: String,
        headers: Array<SocketHttp11Header>,
        headBytes: Int64
    ) {
        this.method = method
        this.target = target
        this.version = version
        this.headers = cloneSocketHttp11Headers(headers)
        this.headBytes = headBytes
        this.bodyOffset = headBytes
    }

    public func header(name: String): ?String {
        let normalized = name.trimAscii().toAsciiLower()
        for (header in headers) {
            if (header.name == normalized) {
                return Some(header.value)
            }
        }
        None
    }
}

public class SocketHttp11HeadParseOption {
    public let maxHeaderBytes: Int64
    public let maxHeaderCount: Int64
    public let maxRequestLineBytes: Int64

    public init(
        maxHeaderBytes!: Int64 = 16 * 1024,
        maxHeaderCount!: Int64 = 100,
        maxRequestLineBytes!: Int64 = 4 * 1024
    ) {
        this.maxHeaderBytes = if (maxHeaderBytes > 0) { maxHeaderBytes } else { 16 * 1024 }
        this.maxHeaderCount = if (maxHeaderCount > 0) { maxHeaderCount } else { 100 }
        this.maxRequestLineBytes = if (maxRequestLineBytes > 0) { maxRequestLineBytes } else { 4 * 1024 }
    }
}

public func tryParseSocketHttp11RequestHead(
    bytes: Array<UInt8>,
    option!: SocketHttp11HeadParseOption = SocketHttp11HeadParseOption()
): ?SocketHttp11RequestHead {
    let headStart = findSocketHttp11HeadTerminator(bytes)
    if (headStart < 0) {
        if (bytes.size > option.maxHeaderBytes) {
            throw SocketHttp11HeadException(
                SocketHttp11HeadErrorCode.LimitExceeded,
                "HTTP/1.1 request head exceeds configured byte limit before terminator"
            )
        }
        return None
    }

    let consumedBytes = headStart + 4
    if (consumedBytes > option.maxHeaderBytes) {
        throw SocketHttp11HeadException(
            SocketHttp11HeadErrorCode.LimitExceeded,
            "HTTP/1.1 request head exceeds configured byte limit"
        )
    }

    let headText = decodeSocketHttp11HeadText(bytes, headStart)
    let requestLineEnd = findSocketHttp11LineEnd(headText, 0)
    if (requestLineEnd == 0) {
        throw SocketHttp11HeadException(
            SocketHttp11HeadErrorCode.MalformedRequestLine,
            "empty HTTP/1.1 request line"
        )
    }
    if (requestLineEnd > option.maxRequestLineBytes) {
        throw SocketHttp11HeadException(
            SocketHttp11HeadErrorCode.LimitExceeded,
            "HTTP/1.1 request line exceeds configured byte limit"
        )
    }

    let firstSpace = findSocketHttp11Byte(headText, UInt8(32), 0, requestLineEnd)
    let secondSpace = if (firstSpace >= 0) {
        findSocketHttp11Byte(headText, UInt8(32), firstSpace + 1, requestLineEnd)
    } else {
        -1
    }
    let thirdSpace = if (secondSpace >= 0) {
        findSocketHttp11Byte(headText, UInt8(32), secondSpace + 1, requestLineEnd)
    } else {
        -1
    }
    if (
        firstSpace <= 0 ||
        secondSpace <= firstSpace + 1 ||
        secondSpace >= requestLineEnd - 1 ||
        thirdSpace >= 0
    ) {
        throw SocketHttp11HeadException(
            SocketHttp11HeadErrorCode.MalformedRequestLine,
            "HTTP/1.1 request line must contain method, target, and version"
        )
    }

    let method = headText[..firstSpace]
    let target = headText[firstSpace + 1..secondSpace]
    let version = headText[secondSpace + 1..requestLineEnd]
    let validMethod = isSocketHttp11Token(method)
    if (method.size == 0 || target.size == 0 || !validMethod) {
        throw SocketHttp11HeadException(
            SocketHttp11HeadErrorCode.MalformedRequestLine,
            "HTTP/1.1 request line contains an invalid method or target"
        )
    }
    if (version != "HTTP/1.1") {
        throw SocketHttp11HeadException(
            SocketHttp11HeadErrorCode.UnsupportedVersion,
            "only HTTP/1.1 request heads are accepted by the socket parser foundation"
        )
    }

    let headers = ArrayList<SocketHttp11Header>()
    var lineStart = if (requestLineEnd < headText.size) { requestLineEnd + 2 } else { headText.size }
    while (lineStart < headText.size) {
        let lineEnd = findSocketHttp11LineEnd(headText, lineStart)
        if (lineEnd == lineStart) {
            throw SocketHttp11HeadException(
                SocketHttp11HeadErrorCode.MalformedHeader,
                "unexpected empty header line before terminator"
            )
        }
        if (headers.size >= option.maxHeaderCount) {
            throw SocketHttp11HeadException(
                SocketHttp11HeadErrorCode.LimitExceeded,
                "HTTP/1.1 header count exceeds configured limit"
            )
        }

        let colon = findSocketHttp11Byte(headText, UInt8(58), lineStart, lineEnd)
        if (colon <= lineStart) {
            throw SocketHttp11HeadException(
                SocketHttp11HeadErrorCode.MalformedHeader,
                "HTTP/1.1 header line must contain a name and ':'"
            )
        }

        let name = headText[lineStart..colon]
        if (!isSocketHttp11HeaderName(name)) {
            throw SocketHttp11HeadException(
                SocketHttp11HeadErrorCode.InvalidHeaderName,
                "HTTP/1.1 header name contains an invalid token character"
            )
        }

        let rawValue = headText[colon + 1..lineEnd]
        validateSocketHttp11RequestHeaderValue(rawValue)
        let value = rawValue.trimAscii()
        headers.add(SocketHttp11Header(normalizeSocketHttp11HeaderName(name), value))
        lineStart = if (lineEnd < headText.size) { lineEnd + 2 } else { headText.size }
    }

    let parsedHeaders = headers.toArray()
    validateSocketHttp11RequestHost(parsedHeaders)

    Some(
        SocketHttp11RequestHead(
            method,
            target,
            version,
            parsedHeaders,
            consumedBytes
        )
    )
}

func validateSocketHttp11RequestHeaderValue(value: String): Unit {
    for (byte in value.toArray()) {
        if ((byte < UInt8(32) && byte != UInt8(9)) || byte == UInt8(127)) {
            throw SocketHttp11HeadException(
                SocketHttp11HeadErrorCode.MalformedHeader,
                "HTTP/1.1 request header value contains a forbidden control byte"
            )
        }
    }
}

func validateSocketHttp11RequestHost(headers: Array<SocketHttp11Header>): Unit {
    var hostCount: Int64 = 0
    var hostValue: String = ""
    for (header in headers) {
        if (header.name == "host") {
            hostCount += 1
            hostValue = header.value
        }
    }
    if (hostCount == 0) {
        throw SocketHttp11HeadException(
            SocketHttp11HeadErrorCode.MalformedHeader,
            "HTTP/1.1 requests require exactly one Host header"
        )
    }
    if (hostCount > 1) {
        throw SocketHttp11HeadException(
            SocketHttp11HeadErrorCode.MalformedHeader,
            "HTTP/1.1 requests reject multiple Host headers"
        )
    }
    if (!isSocketHttp11RequestAuthorityValid(hostValue)) {
        throw SocketHttp11HeadException(
            SocketHttp11HeadErrorCode.MalformedHeader,
            "HTTP/1.1 Host must contain one valid uri-host and optional decimal port"
        )
    }
}

func isSocketHttp11RequestAuthorityValid(
    value: String,
    requireUsablePort!: Bool = false
): Bool {
    let raw = value.trimAscii()
    if (raw.size == 0) {
        return false
    }
    let bytes = raw.toArray()
    if (bytes[0] == UInt8(91)) {
        return isSocketHttp11BracketedAuthorityValid(bytes, requireUsablePort)
    }

    var colonIndex: Int64 = -1
    for (i in 0..bytes.size) {
        if (bytes[i] == UInt8(58)) {
            if (colonIndex >= 0) {
                return false
            }
            colonIndex = i
        }
    }
    let hostEnd = if (colonIndex >= 0) { colonIndex } else { bytes.size }
    if (!isSocketHttp11RegNameValid(bytes, 0, hostEnd)) {
        return false
    }
    if (colonIndex < 0) {
        return !requireUsablePort
    }
    isSocketHttp11AuthorityPortValid(bytes, colonIndex + 1, requireUsablePort)
}

func isSocketHttp11BracketedAuthorityValid(
    bytes: Array<UInt8>,
    requireUsablePort: Bool
): Bool {
    var closingIndex: Int64 = -1
    var i: Int64 = 1
    while (i < bytes.size) {
        if (bytes[i] == UInt8(93)) {
            closingIndex = i
            break
        }
        i += 1
    }
    if (closingIndex <= 1 || !isSocketHttp11IpLiteralShapeValid(bytes, 1, closingIndex)) {
        return false
    }
    if (closingIndex + 1 == bytes.size) {
        return !requireUsablePort
    }
    if (bytes[closingIndex + 1] != UInt8(58)) {
        return false
    }
    isSocketHttp11AuthorityPortValid(bytes, closingIndex + 2, requireUsablePort)
}

func isSocketHttp11RegNameValid(bytes: Array<UInt8>, start: Int64, end: Int64): Bool {
    if (start >= end) {
        return false
    }
    var i = start
    while (i < end) {
        let byte = bytes[i]
        if (byte == UInt8(37)) {
            if (
                i + 2 >= end ||
                !isSocketHttp11HexDigit(bytes[i + 1]) ||
                !isSocketHttp11HexDigit(bytes[i + 2])
            ) {
                return false
            }
            i += 3
            continue
        }
        if (!isSocketHttp11RegNameByte(byte)) {
            return false
        }
        i += 1
    }
    true
}

func isSocketHttp11IpLiteralShapeValid(
    bytes: Array<UInt8>,
    start: Int64,
    end: Int64
): Bool {
    if (bytes[start] == UInt8(118) || bytes[start] == UInt8(86)) {
        var i = start + 1
        let versionStart = i
        while (i < end && isSocketHttp11HexDigit(bytes[i])) {
            i += 1
        }
        if (i == versionStart || i >= end || bytes[i] != UInt8(46)) {
            return false
        }
        i += 1
        if (i >= end) {
            return false
        }
        while (i < end) {
            if (
                !isSocketHttp11UnreservedByte(bytes[i]) &&
                !isSocketHttp11SubDelimiterByte(bytes[i]) &&
                bytes[i] != UInt8(58)
            ) {
                return false
            }
            i += 1
        }
        return true
    }

    var hasColon = false
    for (i in start..end) {
        let byte = bytes[i]
        if (byte == UInt8(58)) {
            hasColon = true
        } else if (!isSocketHttp11HexDigit(byte) && byte != UInt8(46)) {
            return false
        }
    }
    hasColon
}

func isSocketHttp11AuthorityPortValid(
    bytes: Array<UInt8>,
    start: Int64,
    requireUsablePort: Bool
): Bool {
    if (start >= bytes.size) {
        return !requireUsablePort
    }
    var value: Int64 = 0
    for (i in start..bytes.size) {
        let byte = bytes[i]
        if (byte < UInt8(48) || byte > UInt8(57)) {
            return false
        }
        if (requireUsablePort) {
            value = value * 10 + Int64(byte) - Int64(UInt8(48))
            if (value > 65535) {
                return false
            }
        }
    }
    !requireUsablePort || value > 0
}

func isSocketHttp11RegNameByte(byte: UInt8): Bool {
    isSocketHttp11UnreservedByte(byte) || isSocketHttp11SubDelimiterByte(byte)
}

func isSocketHttp11UnreservedByte(byte: UInt8): Bool {
    (byte >= UInt8(65) && byte <= UInt8(90)) ||
    (byte >= UInt8(97) && byte <= UInt8(122)) ||
    (byte >= UInt8(48) && byte <= UInt8(57)) ||
    byte == UInt8(45) || byte == UInt8(46) || byte == UInt8(95) || byte == UInt8(126)
}

func isSocketHttp11SubDelimiterByte(byte: UInt8): Bool {
    byte == UInt8(33) || byte == UInt8(36) || byte == UInt8(38) ||
    byte == UInt8(39) || byte == UInt8(40) || byte == UInt8(41) ||
    byte == UInt8(42) || byte == UInt8(43) || byte == UInt8(59) ||
    byte == UInt8(61)
}

func isSocketHttp11HexDigit(byte: UInt8): Bool {
    (byte >= UInt8(48) && byte <= UInt8(57)) ||
    (byte >= UInt8(65) && byte <= UInt8(70)) ||
    (byte >= UInt8(97) && byte <= UInt8(102))
}

func cloneSocketHttp11Headers(headers: Array<SocketHttp11Header>): Array<SocketHttp11Header> {
    let out = Array<SocketHttp11Header>(headers.size, repeat: SocketHttp11Header("", ""))
    for (i in 0..headers.size) {
        out[i] = SocketHttp11Header(headers[i].name, headers[i].value)
    }
    out
}

func findSocketHttp11HeadTerminator(bytes: Array<UInt8>): Int64 {
    if (bytes.size < 4) {
        return -1
    }
    var i: Int64 = 0
    while (i <= bytes.size - 4) {
        if (
            bytes[i] == UInt8(13) &&
            bytes[i + 1] == UInt8(10) &&
            bytes[i + 2] == UInt8(13) &&
            bytes[i + 3] == UInt8(10)
        ) {
            return i
        }
        i += 1
    }
    -1
}

func decodeSocketHttp11HeadText(bytes: Array<UInt8>, length: Int64): String {
    if (length <= 0) {
        return ""
    }
    String.fromUtf8(bytes[..length])
}

func findSocketHttp11LineEnd(input: String, start: Int64): Int64 {
    var i = start
    while (i + 1 < input.size) {
        if (input[i] == UInt8(13) && input[i + 1] == UInt8(10)) {
            return i
        }
        i += 1
    }
    input.size
}

func findSocketHttp11Byte(
    input: String,
    target: UInt8,
    start: Int64,
    end: Int64
): Int64 {
    var i = start
    while (i < end) {
        if (input[i] == target) {
            return i
        }
        i += 1
    }
    -1
}

func normalizeSocketHttp11HeaderName(input: String): String {
    for (i in 0..input.size) {
        let code = input[i]
        if (code >= UInt8(65) && code <= UInt8(90)) {
            return input.toAsciiLower()
        }
    }
    input
}

func isSocketHttp11HeaderName(input: String): Bool {
    if (input.size == 0) {
        return false
    }
    isSocketHttp11Token(input)
}

func isSocketHttp11Token(input: String): Bool {
    if (input.size == 0) {
        return false
    }
    for (i in 0..input.size) {
        if (!socketHttp11TokenByteAllowed(input[i])) {
            return false
        }
    }
    true
}

func socketHttp11TokenByteAllowed(code: UInt8): Bool {
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
