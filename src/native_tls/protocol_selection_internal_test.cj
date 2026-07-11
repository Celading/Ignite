package ignite.native_tls

@Test
public class NativeTlsProtocolSelectionInternalTestSuite {
    @TestCase
    public func testSelectsH2AndHttp11FromNegotiatedAlpn(): Unit {
        @Assert(
            selectNativeTlsApplicationProtocol(" H2 "),
            NativeTlsApplicationProtocol.H2
        )
        @Assert(
            selectNativeTlsApplicationProtocol("http/1.1"),
            NativeTlsApplicationProtocol.Http11
        )
    }

    @TestCase
    public func testRejectsMissingOrUnknownNegotiatedAlpn(): Unit {
        var rejected = false
        try {
            let _ = selectNativeTlsApplicationProtocol("")
        } catch (e: NativeTlsProtocolSelectionException) {
            rejected = true
            @Assert(e.negotiatedAlpn, "")
        }
        @Assert(rejected, true)
    }
}
