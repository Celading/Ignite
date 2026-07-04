package ignite.tests

import ignite.*

@Test
public class ServerJinguiSslTlsAttachBlockerClassificationTestSuite {
    @TestCase
    public func testAcceptedTransportTranscriptHashFailureIsProviderContractBlocker(): Unit {
        let classification =
            classifyServerJinguiAcceptedTransportTlsAttachBlocker(
                "accepted transport TLS1.3 X25519 attach failed: TLS1.3 transcript hash must be SHA-256 sized"
            )

        @Assert(classification.status, "blocked-provider-contract")
        @Assert(classification.owner, "JinguiSSL-contract")
        @Assert(classification.failureCode, "TLS13_TRANSCRIPT_HASH_SIZE")
        @Assert(classification.attachSurface, "accepted-transport-tls13-x25519")
        @Assert(classification.h2RuntimeBlocked, true)
        @Assert(classification.nonClaims[0], "NO_PROVIDER_FIX")
        @Assert(classification.nonClaims[1], "NO_ACCEPTED_TRANSPORT_ATTACH_PASS")
        @Assert(classification.nonClaims[2], "NO_H2_RUNTIME_CLOSURE")
    }

    @TestCase
    public func testGenericAcceptedTransportAttachFailureStillBlocksH2RuntimeClaim(): Unit {
        let classification =
            classifyServerJinguiAcceptedTransportTlsAttachBlocker(
                "accepted transport TLS1.3 X25519 attach failed: provider rejected handshake"
            )

        @Assert(classification.status, "blocked-provider-attach")
        @Assert(classification.owner, "JinguiSSL-contract")
        @Assert(classification.failureCode, "TLS13_ACCEPTED_TRANSPORT_ATTACH_FAILED")
        @Assert(classification.h2RuntimeBlocked, true)
        @Assert(classification.nextAction, "route provider-side accepted-transport attach proof before widening Ignite H2/TLS claims")
    }

    @TestCase
    public func testUnclassifiedAttachFailureDoesNotAssignProviderOwner(): Unit {
        let classification =
            classifyServerJinguiAcceptedTransportTlsAttachBlocker(
                "socket closed while waiting for client data"
            )

        @Assert(classification.status, "unclassified")
        @Assert(classification.owner, "unknown")
        @Assert(classification.failureCode, "UNKNOWN")
        @Assert(classification.h2RuntimeBlocked, false)
        @Assert(classification.nonClaims[1], "NO_OWNER_ASSIGNMENT")
    }
}
