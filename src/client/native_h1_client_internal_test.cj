package ignite.client

import stdx.net.http.HttpHeaders

@Test
public class NativeH1ClientInternalTestSuite {
    @TestCase
    public func testParsesBracketedIpv6AuthorityAndPoolOrigin(): Unit {
        let explicit = parseNativeH1Target("http://[::1]:18080/a?q=1#fragment")
        @Assert(explicit.host, "::1")
        @Assert(explicit.port, UInt16(18080))
        @Assert(explicit.scheme, "http")
        @Assert(explicit.hostHeader, "[::1]:18080")
        @Assert(explicit.requestTarget, "/a?q=1")
        @Assert(nativeH1PoolOrigin(explicit), "http://[::1]:18080")

        let defaultPort = parseNativeH1Target("http://[2001:db8::7]/")
        @Assert(defaultPort.host, "2001:db8::7")
        @Assert(defaultPort.port, UInt16(80))
        @Assert(defaultPort.hostHeader, "[2001:db8::7]")
        @Assert(nativeH1PoolOrigin(defaultPort), "http://[2001:db8::7]:80")
    }

    @TestCase
    public func testParsesHttpsAuthorityWithTlsDefaultPort(): Unit {
        let target = parseNativeH1Target("https://example.test/api?q=1#ignored")
        @Assert(target.scheme, "https")
        @Assert(target.host, "example.test")
        @Assert(target.port, UInt16(443))
        @Assert(target.requestTarget, "/api?q=1")
        @Assert(nativeH1PoolOrigin(target), "https://example.test:443")

        let redirected = resolveNativeH1RedirectUrl(
            "https://example.test/base/item",
            "../next"
        )
        @Assert(redirected, "https://example.test/base/../next")
    }

    @TestCase
    public func testRejectsUnbracketedIpv6Authority(): Unit {
        var rejected = false
        try {
            let _ = parseNativeH1Target("http://2001:db8::7/path")
        } catch (e: Exception) {
            rejected = e.message == "native H1 client IPv6 URL must use brackets"
        }
        @Assert(rejected, true)
    }

    @TestCase
    public func testAcceptsOnlyUnambiguousNativeH1ResponseFraming(): Unit {
        let equalLengths = HttpHeaders()
        equalLengths.add("content-length", "5")
        equalLengths.add("content-length", "5, 5")
        let lengthFraming = resolveNativeH1ResponseFraming(equalLengths)
        @Assert(lengthFraming.mode, "length")
        @Assert(lengthFraming.contentLength, Int64(5))

        let chunked = HttpHeaders()
        chunked.add("transfer-encoding", "chunked")
        @Assert(resolveNativeH1ResponseFraming(chunked).mode, "chunked")

        assertNativeH1ResponseFramingRejected({ headers =>
            headers.add("transfer-encoding", "chunked")
            headers.add("content-length", "5")
        })
        assertNativeH1ResponseFramingRejected({ headers =>
            headers.add("content-length", "5")
            headers.add("content-length", "6")
        })
        assertNativeH1ResponseFramingRejected({ headers =>
            headers.add("transfer-encoding", "gzip, chunked")
        })
        assertNativeH1ResponseFramingRejected({ headers =>
            headers.add("transfer-encoding", "chunked, chunked")
        })
        assertNativeH1ResponseFramingRejected({ headers =>
            headers.add("content-length", "5,")
        })
    }

    @TestCase
    public func testAcceptsOnlyValidNativeH1ResponseHeadMetadata(): Unit {
        let valid = parseNativeH1ResponseHead(
            "HTTP/1.1 200 OK\r\nX!#$%&'*+-.^_`|~Token:\t value \t".toArray()
        )
        @Assert(valid.version, "HTTP/1.1")
        @Assert(valid.status, Int64(200))
        let validValues = collectNativeH1ResponseHeaderValues(
            valid.headers,
            "x!#$%&'*+-.^_`|~token"
        )
        @Assert(validValues.size, Int64(1))
        @Assert(validValues[0], "value")

        assertNativeH1ResponseHeadRejected(
            "HTTP/1.0 200 OK\r\nContent-Length: 0".toArray(),
            "native H1 response version must be HTTP/1.1"
        )
        assertNativeH1ResponseHeadRejected(
            "HTTP/1.1 200 OK\r\nMalformed-Field".toArray(),
            "native H1 response header line is malformed"
        )
        assertNativeH1ResponseHeadRejected(
            "HTTP/1.1 200 OK\r\nBad Header: value".toArray(),
            "native H1 response header name is invalid"
        )

        assertNativeH1ResponseHeadRejected(
            nativeH1ResponseHeadWithControl(UInt8(0)),
            "native H1 response header value contains a forbidden control byte"
        )
        assertNativeH1ResponseHeadRejected(
            nativeH1ResponseHeadWithControl(UInt8(31)),
            "native H1 response header value contains a forbidden control byte"
        )
        assertNativeH1ResponseHeadRejected(
            nativeH1ResponseHeadWithControl(UInt8(127)),
            "native H1 response header value contains a forbidden control byte"
        )
    }

    @TestCase
    public func testAcceptsOnlyBoundedValidNativeH1ResponseTrailers(): Unit {
        let first = validateNativeH1ResponseTrailerLine("X-Trailer: value", 0)
        @Assert(first, Int64("X-Trailer: value".toArray().size + 2))
        let completed = validateNativeH1ResponseTrailerLine("", first)
        @Assert(completed, first + 2)

        assertNativeH1ResponseTrailerRejected(
            "Malformed-Trailer",
            0,
            "native H1 response trailer line is malformed"
        )
        assertNativeH1ResponseTrailerRejected(
            "Bad Trailer: value",
            0,
            "native H1 response trailer name is invalid"
        )
        assertNativeH1ResponseTrailerRejected(
            "X-Control: safe" + String.fromUtf8([UInt8(0)]) + "unsafe",
            0,
            "native H1 response trailer value contains a forbidden control byte"
        )
        assertNativeH1ResponseTrailerRejected(
            "X: y",
            NATIVE_H1_RESPONSE_TRAILER_LIMIT - 4,
            "native H1 response trailers exceed 65536 bytes"
        )
    }
}

func assertNativeH1ResponseFramingRejected(fill: (HttpHeaders) -> Unit): Unit {
    let headers = HttpHeaders()
    fill(headers)
    var rejected = false
    try {
        let _ = resolveNativeH1ResponseFraming(headers)
    } catch (_: Exception) {
        rejected = true
    }
    @Assert(rejected, true)
}

func assertNativeH1ResponseHeadRejected(head: Array<UInt8>, message: String): Unit {
    var rejected = false
    try {
        let _ = parseNativeH1ResponseHead(head)
    } catch (e: Exception) {
        rejected = e.message == message
    }
    @Assert(rejected, true)
}

func assertNativeH1ResponseTrailerRejected(
    line: String,
    consumedBytes: Int64,
    message: String
): Unit {
    var rejected = false
    try {
        let _ = validateNativeH1ResponseTrailerLine(line, consumedBytes)
    } catch (e: Exception) {
        rejected = e.message == message
    }
    @Assert(rejected, true)
}

func nativeH1ResponseHeadWithControl(control: UInt8): Array<UInt8> {
    let prefix = "HTTP/1.1 200 OK\r\nX-Control: safe".toArray()
    let suffix = "unsafe".toArray()
    let out = Array<UInt8>(prefix.size + 1 + suffix.size, repeat: 0)
    var cursor: Int64 = 0
    for (byte in prefix) {
        out[cursor] = byte
        cursor += 1
    }
    out[cursor] = control
    cursor += 1
    for (byte in suffix) {
        out[cursor] = byte
        cursor += 1
    }
    out
}
