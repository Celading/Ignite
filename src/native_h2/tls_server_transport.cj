package ignite.native_h2

import jinguissl.live.{
    ContractTls13IncrementalServerReadyRuntime,
    ContractTlsRecordChannel,
    ContractTlsRecordContentType
}
import std.collection.ArrayList
import std.net.TcpSocket

let NATIVE_H2_TLS_MAX_RECORD_PAYLOAD: Int64 = 18432
// JinguiSSL Core currently counts the TLS 1.3 inner content-type byte against
// its ciphertext ceiling, so 16384 bytes would overflow by one after sealing.
let NATIVE_H2_TLS_MAX_APPLICATION_FRAGMENT: Int64 = 16383

/// Presents one accepted JinguiSSL TLS session as plaintext H2 bytes.
///
/// The accepted socket is caller-owned. This adapter only consumes complete
/// TLS records, preserves handshake-coalesced pending bytes, and maintains the
/// record channel sequence through ordered reads and writes.
public class NativeH2JinguiServerTransport <: NativeH2DuplexTransport {
    let socket: TcpSocket
    let channel: ContractTlsRecordChannel
    let pendingRecords: Array<Array<Byte>>
    let pendingWire = ArrayList<UInt8>()
    let plaintext = ArrayList<UInt8>()
    var pendingRecordOffset: Int64 = 0
    var plaintextOffset: Int64 = 0

    public init(
        socket: TcpSocket,
        ready: ContractTls13IncrementalServerReadyRuntime
    ) {
        this.socket = socket
        this.channel = ready.session.recordChannel
        this.pendingRecords = ready.pendingApplicationRecords
        for (value in ready.pendingBytes) {
            pendingWire.add(UInt8(value))
        }
    }

    public override func read(outBuf: Array<UInt8>): Int64 {
        if (outBuf.size == 0) {
            return 0
        }
        while (plaintextOffset >= plaintext.size) {
            plaintext.clear()
            plaintextOffset = 0
            let record = readNextRecord()
            if (record.size == 0) {
                return 0
            }
            let opened = channel.openApplicationData(nativeH2TlsToByteArray(record))
            for (value in opened) {
                plaintext.add(UInt8(value))
            }
        }
        let available = plaintext.size - plaintextOffset
        let count = if (available < outBuf.size) { available } else { outBuf.size }
        var i: Int64 = 0
        while (i < count) {
            outBuf[i] = plaintext[plaintextOffset + i]
            i += 1
        }
        plaintextOffset += count
        count
    }

    public override func write(data: Array<UInt8>): Unit {
        let records = channel.sealFragments(
            ContractTlsRecordContentType.ApplicationData,
            nativeH2TlsToByteArray(data),
            maxFragmentLen: NATIVE_H2_TLS_MAX_APPLICATION_FRAGMENT
        )
        for (record in records) {
            socket.write(nativeH2TlsToUInt8Array(record))
        }
    }

    public override func currentReadTimeout(): ?Duration {
        socket.readTimeout
    }

    public override func updateReadTimeout(value: ?Duration): Unit {
        socket.readTimeout = value
    }

    func readNextRecord(): Array<UInt8> {
        if (pendingRecordOffset < pendingRecords.size) {
            let record = nativeH2TlsToUInt8Array(pendingRecords[pendingRecordOffset])
            pendingRecordOffset += 1
            return record
        }
        while (true) {
            if (pendingWire.size >= 5) {
                let payloadLength =
                    (Int64(pendingWire[3]) << 8) + Int64(pendingWire[4])
                if (payloadLength > NATIVE_H2_TLS_MAX_RECORD_PAYLOAD) {
                    throw Exception("native H2 TLS record payload exceeds bounded limit")
                }
                let recordLength = 5 + payloadLength
                if (pendingWire.size >= recordLength) {
                    let record = Array<UInt8>(recordLength, repeat: 0)
                    var i: Int64 = 0
                    while (i < recordLength) {
                        record[i] = pendingWire[i]
                        i += 1
                    }
                    let remaining = ArrayList<UInt8>()
                    while (i < pendingWire.size) {
                        remaining.add(pendingWire[i])
                        i += 1
                    }
                    pendingWire.clear()
                    for (value in remaining) {
                        pendingWire.add(value)
                    }
                    return record
                }
            }
            let chunk = Array<UInt8>(4096, repeat: 0)
            let count = socket.read(chunk)
            if (count <= 0) {
                if (pendingWire.size > 0) {
                    throw Exception("native H2 TLS peer closed during a record")
                }
                return Array<UInt8>()
            }
            var i: Int64 = 0
            while (i < count) {
                pendingWire.add(chunk[i])
                i += 1
            }
        }
        Array<UInt8>()
    }
}

func nativeH2TlsToByteArray(values: Array<UInt8>): Array<Byte> {
    let out = Array<Byte>(values.size, repeat: 0)
    var i: Int64 = 0
    while (i < values.size) {
        out[i] = values[i]
        i += 1
    }
    out
}

func nativeH2TlsToUInt8Array(values: Array<Byte>): Array<UInt8> {
    let out = Array<UInt8>(values.size, repeat: 0)
    var i: Int64 = 0
    while (i < values.size) {
        out[i] = UInt8(values[i])
        i += 1
    }
    out
}
