package ignite.native_h2

import std.collection.ArrayList

let NATIVE_H2_SETTING_HEADER_TABLE_SIZE: Int64 = 1
let NATIVE_H2_SETTING_ENABLE_PUSH: Int64 = 2
let NATIVE_H2_SETTING_INITIAL_WINDOW_SIZE: Int64 = 4
let NATIVE_H2_SETTING_MAX_FRAME_SIZE: Int64 = 5
let NATIVE_H2_SETTING_MAX_HEADER_LIST_SIZE: Int64 = 6
let NATIVE_H2_MAX_FRAME_PAYLOAD: Int64 = 16777215

class NativeH2PeerSettings {
    var headerTableSize: Int64 = NATIVE_H2_HPACK_DEFAULT_DYNAMIC_TABLE_SIZE
    var initialStreamWindow: Int64 = NATIVE_H2_INITIAL_FLOW_WINDOW
    var maxFramePayload: Int64 = NATIVE_H2_DEFAULT_MAX_FRAME_PAYLOAD
    var maxHeaderListSize: ?Int64 = None

    func apply(payload: Array<UInt8>): Array<Int64> {
        if (payload.size % 6 != 0) {
            nativeH2ProtocolFailure(
                "native H2 SETTINGS payload must contain 6-byte entries",
                NATIVE_H2_ERROR_FRAME_SIZE
            )
        }
        let windowDeltas = ArrayList<Int64>()
        var offset: Int64 = 0
        while (offset < payload.size) {
            let settingId =
                (Int64(payload[offset]) << 8) + Int64(payload[offset + 1])
            let value =
                (Int64(payload[offset + 2]) << 24) +
                (Int64(payload[offset + 3]) << 16) +
                (Int64(payload[offset + 4]) << 8) +
                Int64(payload[offset + 5])
            if (settingId == NATIVE_H2_SETTING_HEADER_TABLE_SIZE) {
                headerTableSize = value
            } else if (settingId == NATIVE_H2_SETTING_ENABLE_PUSH) {
                if (value != 0 && value != 1) {
                    nativeH2ProtocolFailure(
                        "native H2 SETTINGS_ENABLE_PUSH must be zero or one"
                    )
                }
            } else if (settingId == NATIVE_H2_SETTING_INITIAL_WINDOW_SIZE) {
                if (value > NATIVE_H2_MAX_FLOW_WINDOW) {
                    nativeH2ProtocolFailure(
                        "native H2 SETTINGS_INITIAL_WINDOW_SIZE exceeds the flow window",
                        NATIVE_H2_ERROR_FLOW_CONTROL
                    )
                }
                let delta = value - initialStreamWindow
                initialStreamWindow = value
                windowDeltas.add(delta)
            } else if (settingId == NATIVE_H2_SETTING_MAX_FRAME_SIZE) {
                if (value < NATIVE_H2_DEFAULT_MAX_FRAME_PAYLOAD ||
                    value > NATIVE_H2_MAX_FRAME_PAYLOAD) {
                    nativeH2ProtocolFailure(
                        "native H2 SETTINGS_MAX_FRAME_SIZE is outside the RFC range"
                    )
                }
                maxFramePayload = value
            } else if (settingId == NATIVE_H2_SETTING_MAX_HEADER_LIST_SIZE) {
                maxHeaderListSize = Some(value)
            }
            offset += 6
        }
        windowDeltas.toArray()
    }
}

func nativeH2AdjustedSendWindow(current: Int64, delta: Int64): Int64 {
    if (delta > 0 && current > NATIVE_H2_MAX_FLOW_WINDOW - delta) {
        nativeH2ProtocolFailure(
            "native H2 initial window update overflows a response stream",
            NATIVE_H2_ERROR_FLOW_CONTROL
        )
    }
    current + delta
}
