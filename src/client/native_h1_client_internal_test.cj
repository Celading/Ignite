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
