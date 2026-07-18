import ignite.{BrotliCompressionInputStream, compressBrotliResponsePayload}
import std.collection.ArrayList
import std.env.getVariable
import std.fs.{File, OpenMode}
import std.io.InputStream

main() {
    let outputRoot = getVariable("IGNITE_BROTLI_INTEROP_ROOT") ?? "/tmp/ignite-brotli-interop"
    let bufferedRaw = Array<UInt8>(65536, repeat: 0x41)
    let shortThreeRaw = Array<UInt8>(3, repeat: 0x31)
    let shortThirtyTwoRaw = Array<UInt8>(32, repeat: 0x32)
    let emptyRaw = Array<UInt8>(0, repeat: 0)
    let streamedRaw = Array<UInt8>(131172, repeat: 0)
    for (i in 0..65536) {
        streamedRaw[i] = 0x42
    }
    for (i in 0..100) {
        streamedRaw[65536 + i] = UInt8((i * 31) & 0xff)
    }
    for (i in 65636..streamedRaw.size) {
        streamedRaw[i] = 0x43
    }

    writeBytes(outputRoot + "/buffered.raw", bufferedRaw)
    writeBytes(outputRoot + "/buffered.br", compressBrotliResponsePayload(bufferedRaw))
    writeBytes(outputRoot + "/short-3.raw", shortThreeRaw)
    writeBytes(outputRoot + "/short-3.br", compressBrotliResponsePayload(shortThreeRaw))
    writeBytes(outputRoot + "/short-32.raw", shortThirtyTwoRaw)
    writeBytes(outputRoot + "/short-32.br", compressBrotliResponsePayload(shortThirtyTwoRaw))
    writeBytes(outputRoot + "/empty.raw", emptyRaw)
    writeBytes(outputRoot + "/empty.br", compressBrotliResponsePayload(emptyRaw))
    let boundaryLengths: Array<Int64> = [
        3, 4, 5, 6, 7, 8, 9, 10,
        11, 13, 15, 19, 23, 31, 39, 55,
        71, 103, 135, 199, 327, 583, 1095, 2119
    ]
    for (length in boundaryLengths) {
        let raw = Array<UInt8>(length, repeat: 0x44)
        writeBytes(outputRoot + "/boundary-${length}.raw", raw)
        writeBytes(outputRoot + "/boundary-${length}.br", compressBrotliResponsePayload(raw))
    }
    writeBytes(outputRoot + "/streamed.raw", streamedRaw)
    let stream = BrotliCompressionInputStream(BytesInput(streamedRaw), chunkSize: 65536)
    writeBytes(outputRoot + "/streamed.br", readAll(stream))
    println("buffered=65536;streamed=131172;short=3,32;boundaries=24;empty=0;result=generated")
}

func writeBytes(path: String, bytes: Array<UInt8>): Unit {
    let file = File(path, OpenMode.Write)
    try {
        file.write(bytes)
    } finally {
        file.close()
    }
}

func readAll(stream: InputStream): Array<UInt8> {
    let out = ArrayList<UInt8>()
    let buffer = Array<UInt8>(4096, repeat: 0)
    try {
        while (true) {
            let count = stream.read(buffer)
            if (count <= 0) {
                break
            }
            for (i in 0..count) {
                out.add(buffer[i])
            }
        }
    } finally {
        match (stream) {
            case resource: Resource => resource.close()
            case _ => ()
        }
    }
    out.toArray()
}

class BytesInput <: InputStream {
    let bytes: Array<UInt8>
    var cursor: Int64 = 0

    init(bytes: Array<UInt8>) {
        this.bytes = bytes
    }

    public override func read(outBuf: Array<Byte>): Int64 {
        if (cursor >= bytes.size || outBuf.size == 0) {
            return 0
        }
        let remaining = bytes.size - cursor
        let count = if (remaining < outBuf.size) { remaining } else { outBuf.size }
        for (i in 0..count) {
            outBuf[i] = bytes[cursor + i]
        }
        cursor += count
        count
    }
}
