package ignite.native_h2

@Test
public class NativeH2SettingsInternalTestSuite {
    @TestCase
    public func testPeerSettingsApplyEntriesInWireOrder(): Unit {
        let settings = NativeH2PeerSettings()
        let deltas = settings.apply([
            UInt8(0), UInt8(4), UInt8(0), UInt8(1), UInt8(0), UInt8(0),
            UInt8(0), UInt8(4), UInt8(0), UInt8(0), UInt8(0xff), UInt8(0xfe),
            UInt8(0), UInt8(5), UInt8(0), UInt8(0), UInt8(0x80), UInt8(0)
        ])

        @Assert(deltas.size, 2)
        @Assert(deltas[0], 1)
        @Assert(deltas[1], -2)
        @Assert(settings.initialStreamWindow, 65534)
        @Assert(settings.maxFramePayload, 32768)
    }

    @TestCase
    public func testPeerSettingsIgnoreUnknownEntries(): Unit {
        let settings = NativeH2PeerSettings()
        let deltas = settings.apply([
            UInt8(0), UInt8(0x99), UInt8(0), UInt8(0), UInt8(0), UInt8(7)
        ])

        @Assert(deltas.size, 0)
        @Assert(settings.initialStreamWindow, NATIVE_H2_INITIAL_FLOW_WINDOW)
        @Assert(settings.maxFramePayload, NATIVE_H2_DEFAULT_MAX_FRAME_PAYLOAD)
    }

    @TestCase
    public func testPeerSettingsCarryHeaderTableAndHeaderListLimits(): Unit {
        let settings = NativeH2PeerSettings()
        let _ = settings.apply([
            UInt8(0), UInt8(1), UInt8(0), UInt8(0), UInt8(0x02), UInt8(0),
            UInt8(0), UInt8(6), UInt8(0), UInt8(0), UInt8(0x08), UInt8(0)
        ])

        @Assert(settings.headerTableSize, 512)
        @Assert(settings.maxHeaderListSize ?? -1, 2048)
    }

    @TestCase
    public func testPeerSettingsRejectInvalidKnownValues(): Unit {
        @Assert(
            nativeH2SettingsErrorCode([
                UInt8(0), UInt8(2), UInt8(0), UInt8(0), UInt8(0), UInt8(2)
            ]),
            NATIVE_H2_ERROR_PROTOCOL
        )
        @Assert(
            nativeH2SettingsErrorCode([
                UInt8(0), UInt8(4), UInt8(0x80), UInt8(0), UInt8(0), UInt8(0)
            ]),
            NATIVE_H2_ERROR_FLOW_CONTROL
        )
        @Assert(
            nativeH2SettingsErrorCode([
                UInt8(0), UInt8(5), UInt8(0), UInt8(0), UInt8(0x20), UInt8(0)
            ]),
            NATIVE_H2_ERROR_PROTOCOL
        )
        @Assert(
            nativeH2SettingsErrorCode([
                UInt8(0), UInt8(5), UInt8(1), UInt8(0), UInt8(0), UInt8(0)
            ]),
            NATIVE_H2_ERROR_PROTOCOL
        )
    }

    @TestCase
    public func testInitialWindowAdjustmentAllowsNegativeAndRejectsOverflow(): Unit {
        @Assert(nativeH2AdjustedSendWindow(3, -5), -2)
        @Assert(nativeH2FlowWindowWouldOverflow(NATIVE_H2_MAX_FLOW_WINDOW, 1), true)
        @Assert(nativeH2FlowWindowWouldOverflow(NATIVE_H2_MAX_FLOW_WINDOW - 1, 1), false)

        var errorCode: Int64 = NATIVE_H2_ERROR_NO_ERROR
        try {
            let _ = nativeH2AdjustedSendWindow(NATIVE_H2_MAX_FLOW_WINDOW, 1)
        } catch (e: NativeH2ProtocolException) {
            errorCode = e.errorCode
        }
        @Assert(errorCode, NATIVE_H2_ERROR_FLOW_CONTROL)
    }
}

func nativeH2SettingsErrorCode(payload: Array<UInt8>): Int64 {
    try {
        let _ = NativeH2PeerSettings().apply(payload)
        NATIVE_H2_ERROR_NO_ERROR
    } catch (e: NativeH2ProtocolException) {
        e.errorCode
    }
}
