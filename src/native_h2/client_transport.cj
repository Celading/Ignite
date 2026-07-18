package ignite.native_h2

import ignite.transport.NativeByteTransport

func nativeH2ClientReadFrameOrEof(
    transport: NativeByteTransport
): ?NativeH2Frame {
    let header = Array<UInt8>(9, repeat: 0)
    var offset: Int64 = 0
    while (offset < header.size) {
        let chunk = Array<UInt8>(header.size - offset, repeat: 0)
        let count = transport.read(chunk)
        if (count <= 0) {
            if (offset == 0) {
                return None
            }
            throw Exception("native H2 transport closed during a frame header")
        }
        var i: Int64 = 0
        while (i < count) {
            header[offset + i] = chunk[i]
            i += 1
        }
        offset += count
    }
    let payloadLength =
        (Int64(header[0]) << 16) + (Int64(header[1]) << 8) + Int64(header[2])
    if (payloadLength > NATIVE_H2_DEFAULT_MAX_FRAME_PAYLOAD) {
        throw Exception("native H2 frame payload exceeds the default 16 KiB limit")
    }
    let streamId =
        ((Int64(header[5]) & 0x7f) << 24) +
        (Int64(header[6]) << 16) +
        (Int64(header[7]) << 8) +
        Int64(header[8])
    Some(NativeH2Frame(
        header[3],
        header[4],
        streamId,
        nativeH2ClientReadExactly(transport, payloadLength)
    ))
}

func nativeH2ClientWriteFrame(
    transport: NativeByteTransport,
    frame: NativeH2Frame
): Unit {
    let length = frame.payload.size
    if (length > NATIVE_H2_DEFAULT_MAX_FRAME_PAYLOAD) {
        throw Exception("native H2 client frame exceeds the default 16 KiB limit")
    }
    let wire = Array<UInt8>(9 + length, repeat: 0)
    wire[0] = UInt8((length >> 16) & 0xff)
    wire[1] = UInt8((length >> 8) & 0xff)
    wire[2] = UInt8(length & 0xff)
    wire[3] = frame.frameType
    wire[4] = frame.flags
    wire[5] = UInt8((frame.streamId >> 24) & 0x7f)
    wire[6] = UInt8((frame.streamId >> 16) & 0xff)
    wire[7] = UInt8((frame.streamId >> 8) & 0xff)
    wire[8] = UInt8(frame.streamId & 0xff)
    var i: Int64 = 0
    while (i < length) {
        wire[9 + i] = frame.payload[i]
        i += 1
    }
    transport.write(wire)
}

func nativeH2ClientReadExactly(
    transport: NativeByteTransport,
    length: Int64
): Array<UInt8> {
    let out = Array<UInt8>(length, repeat: 0)
    var offset: Int64 = 0
    while (offset < length) {
        let chunk = Array<UInt8>(length - offset, repeat: 0)
        let count = transport.read(chunk)
        if (count <= 0) {
            throw Exception("native H2 transport closed before bounded read completed")
        }
        var i: Int64 = 0
        while (i < count) {
            out[offset + i] = chunk[i]
            i += 1
        }
        offset += count
    }
    out
}
