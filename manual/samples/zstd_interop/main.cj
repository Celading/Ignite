import ignite.{ZstdCompressionInputStream, compressZstdResponsePayload}
import std.collection.ArrayList
import std.env.getVariable
import std.fs.{File, OpenMode}
import std.io.InputStream

main() {
    let outputRoot = getVariable("IGNITE_ZSTD_INTEROP_ROOT") ?? "/tmp/ignite-zstd-interop"
    let bufferedRaw = Array<UInt8>(200000, repeat: 0x41)
    let streamedRaw = Array<UInt8>(200000, repeat: 0)
    for (i in 0..streamedRaw.size) {
        streamedRaw[i] = UInt8((i * 37 + i / 11) & 0xff)
    }

    writeBytes(outputRoot + "/buffered.raw", bufferedRaw)
    writeBytes(outputRoot + "/buffered.zst", compressZstdResponsePayload(bufferedRaw))
    writeBytes(outputRoot + "/streamed.raw", streamedRaw)
    let stream = ZstdCompressionInputStream(BytesInput(streamedRaw), chunkSize: 65536)
    writeBytes(outputRoot + "/streamed.zst", readAll(stream))
    println("buffered=200000;streamed=200000;result=generated")
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
