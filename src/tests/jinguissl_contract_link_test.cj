package ignite.tests

import jinguissl.contract.*

@Test
public class JinguiSslContractLinkTestSuite {
    @TestCase
    public func testContractFacadeStaysLinkableForTlsPrecheckPath(): Unit {
        @Assert(ContractErrorCode.BadInput.toString(), "BAD_INPUT")
    }
}
