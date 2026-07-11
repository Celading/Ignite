package ignite.client

@Test
public class ClientTransportErrorInternalTestSuite {
    @TestCase
    public func testTlsHandshakeEnvelopeCanBecomeRetryableFallbackCandidate(): Unit {
        let selection = buildClientTransportSelectionDecision(
            "https://127.0.0.1:18443/internal-handshake",
            None,
            preferredBackendHint: "jinguissl-provider-candidate",
            allowExperimental: true
        )
        let envelope = buildTransportErrorEnvelope(
            Exception("tls handshake failed during client hello"),
            "",
            true,
            selectionDecision: selection
        )

        @Assert(envelope.family, "TLS")
        @Assert(envelope.phase, "handshake")
        @Assert(envelope.causeCode, "tls_handshake_error")
        @Assert(envelope.retryable, true)
        @Assert(envelope.fallbackSuggested, true)
        @Assert(envelope.connectionConsumed, false)

        let record = buildSuggestedFallbackDecisionRecord(selection, envelope)
        match (record) {
            case Some(value) =>
                @Assert(value.fromBackend, "jinguissl-provider-candidate@tls:jinguissl")
                @Assert(value.toBackend, "stdx-http-client")
                @Assert(value.finalOutcome, "suggested-only")
                @Assert(value.requestReplayRequired, false)
            case None => @Fail("expected handshake fallback record")
        }

        let snapshot = buildClientObserveSnapshot(
            envelope,
            0,
            0,
            "case=internal-handshake",
            selectionDecision: selection,
            fallbackRecord: record
        )
        @Assert(containsInternalObserveText(snapshot.toLogLine(), "retryable=true"), true)
        @Assert(containsInternalObserveText(snapshot.toLogLine(), "fallbackOutcome=suggested-only"), true)
        @Assert(containsInternalObserveText(snapshot.toJson(), "\"causeCode\":\"tls_handshake_error\""), true)
    }

    @TestCase
    public func testNativeH1NetworkStagesMapToStableTransportEnvelope(): Unit {
        let connect = buildTransportErrorEnvelope(
            Exception("native H1 network connect failed: refused"),
            "",
            true
        )
        @Assert(connect.family, "NETWORK")
        @Assert(connect.phase, "connect")
        @Assert(connect.causeCode, "connection_refused")
        @Assert(connect.retryable, true)
        @Assert(connect.connectionConsumed, false)

        let write = buildTransportErrorEnvelope(
            Exception("native H1 network write failed: socket closed"),
            "",
            true
        )
        @Assert(write.family, "NETWORK")
        @Assert(write.phase, "write")
        @Assert(write.causeCode, "write_error")
        @Assert(write.retryable, false)
        @Assert(write.connectionConsumed, true)

        let read = buildTransportErrorEnvelope(
            Exception("native H1 network read failed: response incomplete"),
            "",
            true
        )
        @Assert(read.family, "NETWORK")
        @Assert(read.phase, "read")
        @Assert(read.causeCode, "read_error")
        @Assert(read.retryable, false)
        @Assert(read.connectionConsumed, true)
    }
}

func containsInternalObserveText(text: String, target: String): Bool {
    let t = text.toRuneArray()
    let p = target.toRuneArray()
    if (p.size == 0) {
        return true
    }
    if (t.size < p.size) {
        return false
    }
    var i: Int64 = 0
    while (i <= t.size - p.size) {
        var ok = true
        var j: Int64 = 0
        while (j < p.size) {
            if (t[i + j] != p[j]) {
                ok = false
                break
            }
            j += 1
        }
        if (ok) {
            return true
        }
        i += 1
    }
    false
}
