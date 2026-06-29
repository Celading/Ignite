package ignite.tests

import jinguissl.contract.*

@Test
public class JinguiSslContractLinkTestSuite {
    @TestCase
    public func testContractFacadeStaysLinkableForTlsPrecheckPath(): Unit {
        @Assert(ContractErrorCode.BadInput.toString(), "BAD_INPUT")
    }

    @TestCase
    public func testContractTlsSessionCacheSeamStaysExplicit(): Unit {
        let cache = ContractTlsSessionCache(maxEntries: 2, defaultTtlSeconds: 60)
        @Assert(cache.size, 0)
    }
}
