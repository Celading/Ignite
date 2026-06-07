package ignite.tests

import JinguiSSL.jinguissl.contract.*
import jinguissl_core.jinguissl.crypto.tls.TlsSessionCache

@Test
public class JinguiSslContractLinkTestSuite {
    @TestCase
    public func testContractFacadeStaysLinkableForTlsPrecheckPath(): Unit {
        @Assert(ContractErrorCode.BadInput.toString(), "BAD_INPUT")
    }

    @TestCase
    public func testRemainingDirectCoreTlsSessionCacheSeamStaysExplicit(): Unit {
        let cache = TlsSessionCache(maxEntries: 2, defaultTtlSeconds: 60)
        @Assert(cache.size, 0)
    }
}
