package ignite.client

@Test
public class NativeH1ClientInternalTestSuite {
    @TestCase
    public func testParsesBracketedIpv6AuthorityAndPoolOrigin(): Unit {
        let explicit = parseNativeH1Target("http://[::1]:18080/a?q=1#fragment")
        @Assert(explicit.host, "::1")
        @Assert(explicit.port, UInt16(18080))
        @Assert(explicit.hostHeader, "[::1]:18080")
        @Assert(explicit.requestTarget, "/a?q=1")
        @Assert(nativeH1PoolOrigin(explicit), "[::1]:18080")

        let defaultPort = parseNativeH1Target("http://[2001:db8::7]/")
        @Assert(defaultPort.host, "2001:db8::7")
        @Assert(defaultPort.port, UInt16(80))
        @Assert(defaultPort.hostHeader, "[2001:db8::7]")
        @Assert(nativeH1PoolOrigin(defaultPort), "[2001:db8::7]:80")
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
}
