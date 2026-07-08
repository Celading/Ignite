package ignite.tests

import ignite.*
import std.collection.ArrayList

@Test
public class ServerH2WireFixtureDiagnosticTestSuite {
    @TestCase
    public func testModelOnlyWireFixtureDiagnosticAcceptsKnownHeadersAndDataFrames(): Unit {
        let headersWire = buildHq0440H2FrameWire(
            hq0440ByteArray("abc".toArray()),
            frameType: UInt8(0x1),
            flags: UInt8(0x5),
            streamId: 1
        )
        let dataWire = buildHq0440H2FrameWire(
            hq0440ByteArray("payload".toArray()),
            frameType: UInt8(0x0),
            flags: UInt8(0x1),
            streamId: 1
        )
        let receipt = buildJinguiAcceptedTransportH2WireFixtureDiagnosticReceipt(
            JinguiAcceptedTransportH2WireFixtureDiagnosticEvidence(
                buildHq0440WireFixtureDiagnosticGate(),
                concatHq0440ByteArrays([headersWire, dataWire]),
                JinguiAcceptedTransportH2WireFixtureDiagnosticExpectation(
                    2,
                    [UInt8(0x1), UInt8(0x0)],
                    [1, 1],
                    true,
                    1,
                    1
                ),
                true
            )
        )

        @Assert(receipt.accepted, true)
        @Assert(
            receipt.status,
            "accepted-model-only-h2-wire-fixture-diagnostic"
        )
        @Assert(receipt.frameCount, 2)
        @Assert(receipt.frameTypes[0], UInt8(0x1))
        @Assert(receipt.frameTypes[1], UInt8(0x0))
        @Assert(receipt.streamIds[0], 1)
        @Assert(receipt.completedHeaderBlockCount, 1)
        @Assert(receipt.firstHeaderBlockStreamId, 1)
        @Assert(receipt.h2RuntimeProofLaunchAllowed, false)
        @Assert(receipt.h2RuntimeClosureClaimAllowed, false)
        @Assert(receipt.nonClaims[7], "NO_HPACK_DECODE_CLAIM")
    }

    @TestCase
    public func testWireFixtureDiagnosticBlocksWhenGateIsNotAllowed(): Unit {
        let gate = buildJinguiAcceptedTransportH2DiagnosticWorkGate(
            JinguiAcceptedTransportH2DiagnosticWorkEvidence(
                buildHq0440CarriedDiagnosticHandoff(),
                "h2-wire-fixture-diagnostic",
                true,
                true,
                false,
                false,
                false
            )
        )
        let receipt = buildJinguiAcceptedTransportH2WireFixtureDiagnosticReceipt(
            JinguiAcceptedTransportH2WireFixtureDiagnosticEvidence(
                gate,
                buildHq0440H2FrameWire(
                    hq0440ByteArray("abc".toArray()),
                    frameType: UInt8(0x1),
                    flags: UInt8(0x5),
                    streamId: 1
                ),
                JinguiAcceptedTransportH2WireFixtureDiagnosticExpectation(
                    1,
                    [UInt8(0x1)],
                    [1],
                    true,
                    1,
                    1
                ),
                true
            )
        )

        @Assert(receipt.accepted, false)
        @Assert(
            receipt.status,
            "blocked-wire-fixture-diagnostic-mismatch"
        )
        @Assert(receipt.blockers[0], "GATE:blocked-runtime-scope-in-diagnostic-work")
        @Assert(receipt.blockers[1], "GATE_BLOCKER:FORBIDDEN:H2_RUNTIME_SOCKET_REQUESTED")
    }

    @TestCase
    public func testWireFixtureDiagnosticBlocksFrameTypeMismatch(): Unit {
        let receipt = buildJinguiAcceptedTransportH2WireFixtureDiagnosticReceipt(
            JinguiAcceptedTransportH2WireFixtureDiagnosticEvidence(
                buildHq0440WireFixtureDiagnosticGate(),
                buildHq0440H2FrameWire(
                    hq0440ByteArray("payload".toArray()),
                    frameType: UInt8(0x0),
                    flags: UInt8(0x1),
                    streamId: 3
                ),
                JinguiAcceptedTransportH2WireFixtureDiagnosticExpectation(
                    1,
                    [UInt8(0x1)],
                    [3],
                    false,
                    0,
                    0
                ),
                true
            )
        )

        @Assert(receipt.accepted, false)
        @Assert(
            receipt.blockers[0],
            "FRAME_TYPE_MISMATCH:index=0:expected=1:actual=0"
        )
    }

    @TestCase
    public func testWireFixtureDiagnosticBlocksStreamIdMismatch(): Unit {
        let receipt = buildJinguiAcceptedTransportH2WireFixtureDiagnosticReceipt(
            JinguiAcceptedTransportH2WireFixtureDiagnosticEvidence(
                buildHq0440WireFixtureDiagnosticGate(),
                buildHq0440H2FrameWire(
                    hq0440ByteArray("abc".toArray()),
                    frameType: UInt8(0x1),
                    flags: UInt8(0x5),
                    streamId: 5
                ),
                JinguiAcceptedTransportH2WireFixtureDiagnosticExpectation(
                    1,
                    [UInt8(0x1)],
                    [7],
                    true,
                    1,
                    5
                ),
                true
            )
        )

        @Assert(receipt.accepted, false)
        @Assert(
            receipt.blockers[0],
            "STREAM_ID_MISMATCH:index=0:expected=7:actual=5"
        )
    }

    @TestCase
    public func testRuntimeScopeRequestRemainsBlockedByDiagnosticWorkGate(): Unit {
        let gate = buildJinguiAcceptedTransportH2DiagnosticWorkGate(
            JinguiAcceptedTransportH2DiagnosticWorkEvidence(
                buildHq0440CarriedDiagnosticHandoff(),
                "h2-wire-fixture-diagnostic",
                true,
                false,
                true,
                true,
                true
            )
        )

        @Assert(gate.diagnosticWorkAllowed, false)
        @Assert(gate.status, "blocked-runtime-scope-in-diagnostic-work")
        @Assert(gate.blockers[0], "FORBIDDEN:H2_BROWSER_REPLAY_REQUESTED")
        @Assert(gate.blockers[2], "FORBIDDEN:H2SPEC_REQUESTED")
    }
}

func buildHq0440WireFixtureDiagnosticGate():
    JinguiAcceptedTransportH2DiagnosticWorkGate {
    buildJinguiAcceptedTransportH2DiagnosticWorkGate(
        JinguiAcceptedTransportH2DiagnosticWorkEvidence(
            buildHq0440CarriedDiagnosticHandoff(),
            "h2-wire-fixture-diagnostic",
            true,
            false,
            false,
            false,
            false
        )
    )
}

func buildHq0440CarriedDiagnosticHandoff():
    JinguiAcceptedTransportH2DiagnosticOnlyHandoff {
    buildJinguiAcceptedTransportH2DiagnosticOnlyHandoff(
        JinguiAcceptedTransportH2DiagnosticOnlyHandoffEvidence(
            buildHq0440LaunchGateFromCurrentProviderBlocker(true),
            "JinguiSSL-contract",
            "TLS13_TRANSCRIPT_HASH_SIZE",
            true,
            "h2-wire-fixture-diagnostic"
        )
    )
}

func buildHq0440LaunchGateFromCurrentProviderBlocker(
    carried: Bool
): JinguiAcceptedTransportH2RuntimeProofLaunchGate {
    let classification = classifyServerJinguiAcceptedTransportTlsAttachBlocker(
        "accepted transport TLS1.3 X25519 attach failed: TLS1.3 transcript hash must be SHA-256 sized"
    )
    let attachGate = buildServerJinguiAcceptedTransportTlsAttachProofGate(
        ServerJinguiAcceptedTransportTlsAttachProofGateEvidence(
            classification,
            false,
            false,
            false,
            carried
        )
    )
    buildJinguiAcceptedTransportH2RuntimeProofLaunchGate(
        JinguiAcceptedTransportH2RuntimeProofLaunchEvidence(
            attachGate,
            true,
            true,
            true,
            true,
            buildHq0737AcceptedRuntimeProgressReadoutForLaunchTest()
        )
    )
}

func hq0440ByteArray(input: Array<UInt8>): Array<Byte> {
    let out = Array<Byte>(input.size, repeat: 0)
    var i: Int64 = 0
    while (i < input.size) {
        out[i] = input[i]
        i += 1
    }
    out
}

func buildHq0440H2FrameWire(
    payload: Array<Byte>,
    frameType!: UInt8 = UInt8(0),
    flags!: UInt8 = UInt8(0),
    streamId!: Int64 = 1
): Array<Byte> {
    let out = ArrayList<Byte>()
    let payloadLen = payload.size
    out.add(UInt8((payloadLen >> 16) & 0xff))
    out.add(UInt8((payloadLen >> 8) & 0xff))
    out.add(UInt8(payloadLen & 0xff))
    out.add(frameType)
    out.add(flags)
    out.add(UInt8((streamId >> 24) & 0x7f))
    out.add(UInt8((streamId >> 16) & 0xff))
    out.add(UInt8((streamId >> 8) & 0xff))
    out.add(UInt8(streamId & 0xff))
    for (b in payload) {
        out.add(b)
    }
    out.toArray()
}

func concatHq0440ByteArrays(
    parts: Array<Array<Byte>>
): Array<Byte> {
    let out = ArrayList<Byte>()
    for (part in parts) {
        for (b in part) {
            out.add(b)
        }
    }
    out.toArray()
}
