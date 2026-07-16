package ignite

import std.collection.ArrayList
import std.io.InputStream

public enum CompressionFormat <: Equatable<CompressionFormat> {
    | Gzip
    | Deflate

    public operator func ==(right: CompressionFormat): Bool {
        ordinalValue() == right.ordinalValue()
    }

    public operator func !=(right: CompressionFormat): Bool {
        !(this == right)
    }

    func ordinalValue(): Int64 {
        match (this) {
            case Gzip => 0
            case Deflate => 1
        }
    }
}

/// Compress one buffered response with Ignite-owned DEFLATE framing.
///
/// Levels are normalized to `0..9`. Level zero emits stored blocks; positive
/// levels use a bounded single-candidate LZ77 search with fixed Huffman codes.
public func compressResponsePayload(
    body: Array<UInt8>,
    format: CompressionFormat,
    level!: Int64 = 6
): Array<UInt8> {
    let normalizedLevel = normalizeCompressionLevel(level)
    let deflated = if (normalizedLevel == 0) {
        encodeStoredDeflate(body)
    } else {
        encodeFixedDeflate(body)
    }
    let out = ArrayList<UInt8>()
    appendCompressionHeader(out, format)
    appendUInt8Array(out, deflated)
    appendCompressionTrailer(out, format, body)
    out.toArray()
}

/// Incrementally frame one response stream as gzip or raw DEFLATE.
///
/// Streaming uses stored DEFLATE blocks so source bytes are never captured as
/// one whole response. Buffered responses use the fixed-Huffman path above.
public class CompressionInputStream <: InputStream & Resource {
    let source: InputStream
    let format: CompressionFormat
    let chunkSize: Int64
    var headerEmitted: Bool = false
    var finished: Bool = false
    var closed: Bool = false
    var currentChunk: ?Array<Byte> = None
    var pending: Array<Byte> = []
    var pendingCursor: Int64 = 0
    var crcState: Int64 = 0xffffffff
    var inputSize: Int64 = 0

    public init(
        source: InputStream,
        format: CompressionFormat,
        chunkSize!: Int64 = 16384
    ) {
        this.source = source
        this.format = format
        this.chunkSize = normalizeCompressionChunkSize(chunkSize)
    }

    public override func read(outBuf: Array<Byte>): Int64 {
        if (outBuf.size == 0 || closed) {
            return 0
        }
        var written: Int64 = 0
        while (written < outBuf.size) {
            if (pendingCursor < pending.size) {
                let available = pending.size - pendingCursor
                let remaining = outBuf.size - written
                let copyLen = if (available < remaining) { available } else { remaining }
                for (i in 0..copyLen) {
                    outBuf[written + i] = pending[pendingCursor + i]
                }
                pendingCursor += copyLen
                written += copyLen
                continue
            }
            if (!prepareNextOutput()) {
                break
            }
        }
        written
    }

    public func close(): Unit {
        if (closed) {
            return
        }
        closed = true
        match (source) {
            case closable: Resource => closable.close()
            case _ => ()
        }
    }

    public func isClosed(): Bool {
        closed
    }

    func prepareNextOutput(): Bool {
        pending = []
        pendingCursor = 0
        if (!headerEmitted) {
            headerEmitted = true
            pending = compressionHeaderBytes(format)
            return true
        }
        if (finished) {
            return false
        }

        if (currentChunk.isNone()) {
            currentChunk = Some(readCompressionChunk(source, chunkSize))
        }
        let chunk = match (currentChunk) {
            case Some(value) => value
            case None => Array<Byte>(0, repeat: 0)
        }
        let next = if (chunk.size == 0) {
            Array<Byte>(0, repeat: 0)
        } else {
            readCompressionChunk(source, chunkSize)
        }
        let isFinal = chunk.size == 0 || next.size == 0

        updateCompressionChecksum(chunk)
        let out = ArrayList<Byte>()
        appendStoredBlock(out, chunk, isFinal)
        if (isFinal) {
            appendStreamingTrailer(out)
            finished = true
            currentChunk = None
        } else {
            currentChunk = Some(next)
        }
        pending = out.toArray()
        true
    }

    func updateCompressionChecksum(chunk: Array<Byte>): Unit {
        for (byte in chunk) {
            let value = Int64(UInt8(byte))
            crcState = crc32UpdateByte(crcState, value)
            inputSize = (inputSize + 1) & 0xffffffff
        }
    }

    func appendStreamingTrailer(out: ArrayList<Byte>): Unit {
        match (format) {
            case Gzip =>
                let crc = (crcState ^ 0xffffffff) & 0xffffffff
                appendLittleEndian32(out, crc)
                appendLittleEndian32(out, inputSize)
            case Deflate => ()
        }
    }
}

class DeflateBitWriter {
    let out = ArrayList<UInt8>()
    var bits: Int64 = 0
    var bitCount: Int64 = 0

    func writeBits(value: Int64, count: Int64): Unit {
        let mask = if (count == 0) { 0 } else { (Int64(1) << count) - 1 }
        bits = bits | ((value & mask) << bitCount)
        bitCount += count
        while (bitCount >= 8) {
            out.add(UInt8(bits & 0xff))
            bits = bits >> 8
            bitCount -= 8
        }
    }

    func finish(): Array<UInt8> {
        if (bitCount > 0) {
            out.add(UInt8(bits & 0xff))
            bits = 0
            bitCount = 0
        }
        out.toArray()
    }
}

func encodeFixedDeflate(body: Array<UInt8>): Array<UInt8> {
    let writer = DeflateBitWriter()
    writer.writeBits(0x03, 3) // BFINAL=1, BTYPE=fixed Huffman.
    let hashTable = Array<Int64>(65536, repeat: -1)
    var cursor: Int64 = 0
    while (cursor < body.size) {
        var matchLength: Int64 = 0
        var matchDistance: Int64 = 0
        if (cursor + 2 < body.size) {
            let hash = compressionHash(body, cursor)
            let candidate = hashTable[hash]
            hashTable[hash] = cursor
            if (candidate >= 0 && cursor - candidate <= 32768) {
                let maxLength = minCompressionInt(258, body.size - cursor)
                var length: Int64 = 0
                while (length < maxLength && body[candidate + length] == body[cursor + length]) {
                    length += 1
                }
                if (length >= 3) {
                    matchLength = length
                    matchDistance = cursor - candidate
                }
            }
        }

        if (matchLength >= 3) {
            writeLengthDistance(writer, matchLength, matchDistance)
            var inserted: Int64 = 1
            while (inserted < matchLength && cursor + inserted + 2 < body.size) {
                hashTable[compressionHash(body, cursor + inserted)] = cursor + inserted
                inserted += 1
            }
            cursor += matchLength
        } else {
            writeFixedSymbol(writer, Int64(body[cursor]))
            cursor += 1
        }
    }
    writeFixedSymbol(writer, 256)
    writer.finish()
}

func encodeStoredDeflate(body: Array<UInt8>): Array<UInt8> {
    let out = ArrayList<UInt8>()
    var cursor: Int64 = 0
    if (body.size == 0) {
        appendStoredUInt8Block(out, [], true)
        return out.toArray()
    }
    while (cursor < body.size) {
        let remaining = body.size - cursor
        let size = if (remaining > 65535) { 65535 } else { remaining }
        let chunk = Array<UInt8>(size, repeat: 0)
        for (i in 0..size) {
            chunk[i] = body[cursor + i]
        }
        cursor += size
        appendStoredUInt8Block(out, chunk, cursor >= body.size)
    }
    out.toArray()
}

func writeFixedSymbol(writer: DeflateBitWriter, symbol: Int64): Unit {
    if (symbol <= 143) {
        writer.writeBits(reverseCompressionBits(0x30 + symbol, 8), 8)
    } else if (symbol <= 255) {
        writer.writeBits(reverseCompressionBits(0x190 + symbol - 144, 9), 9)
    } else if (symbol <= 279) {
        writer.writeBits(reverseCompressionBits(symbol - 256, 7), 7)
    } else {
        writer.writeBits(reverseCompressionBits(0xc0 + symbol - 280, 8), 8)
    }
}

func writeLengthDistance(writer: DeflateBitWriter, length: Int64, distance: Int64): Unit {
    let lengthBases: Array<Int64> = [
        3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31,
        35, 43, 51, 59, 67, 83, 99, 115, 131, 163, 195, 227, 258
    ]
    let lengthExtras: Array<Int64> = [
        0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2,
        3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0
    ]
    var lengthIndex: Int64 = 0
    while (lengthIndex + 1 < lengthBases.size && length >= lengthBases[lengthIndex + 1]) {
        lengthIndex += 1
    }
    writeFixedSymbol(writer, 257 + lengthIndex)
    let lengthExtra = lengthExtras[lengthIndex]
    if (lengthExtra > 0) {
        writer.writeBits(length - lengthBases[lengthIndex], lengthExtra)
    }

    let distanceBases: Array<Int64> = [
        1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65, 97, 129, 193,
        257, 385, 513, 769, 1025, 1537, 2049, 3073, 4097, 6145, 8193,
        12289, 16385, 24577
    ]
    let distanceExtras: Array<Int64> = [
        0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6,
        7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13
    ]
    var distanceIndex: Int64 = 0
    while (distanceIndex + 1 < distanceBases.size && distance >= distanceBases[distanceIndex + 1]) {
        distanceIndex += 1
    }
    writer.writeBits(reverseCompressionBits(distanceIndex, 5), 5)
    let distanceExtra = distanceExtras[distanceIndex]
    if (distanceExtra > 0) {
        writer.writeBits(distance - distanceBases[distanceIndex], distanceExtra)
    }
}

func appendCompressionHeader(out: ArrayList<UInt8>, format: CompressionFormat): Unit {
    appendUInt8Array(out, compressionHeaderUInt8(format))
}

func compressionHeaderUInt8(format: CompressionFormat): Array<UInt8> {
    match (format) {
        case Gzip => [0x1f, 0x8b, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff]
        case Deflate => Array<UInt8>(0, repeat: 0)
    }
}

func compressionHeaderBytes(format: CompressionFormat): Array<Byte> {
    let header = compressionHeaderUInt8(format)
    let out = Array<Byte>(header.size, repeat: 0)
    for (i in 0..header.size) {
        out[i] = header[i]
    }
    out
}

func appendCompressionTrailer(
    out: ArrayList<UInt8>,
    format: CompressionFormat,
    body: Array<UInt8>
): Unit {
    match (format) {
        case Gzip =>
            var crc: Int64 = 0xffffffff
            for (value in body) {
                crc = crc32UpdateByte(crc, Int64(value))
            }
            appendLittleEndian32(out, (crc ^ 0xffffffff) & 0xffffffff)
            appendLittleEndian32(out, body.size & 0xffffffff)
        case Deflate => ()
    }
}

func appendStoredUInt8Block(out: ArrayList<UInt8>, chunk: Array<UInt8>, finalBlock: Bool): Unit {
    out.add(if (finalBlock) { 0x01 } else { 0x00 })
    let length = chunk.size
    let complement = 0xffff - length
    out.add(UInt8(length & 0xff))
    out.add(UInt8((length >> 8) & 0xff))
    out.add(UInt8(complement & 0xff))
    out.add(UInt8((complement >> 8) & 0xff))
    appendUInt8Array(out, chunk)
}

func appendStoredBlock(out: ArrayList<Byte>, chunk: Array<Byte>, finalBlock: Bool): Unit {
    out.add(if (finalBlock) { 0x01 } else { 0x00 })
    let length = chunk.size
    let complement = 0xffff - length
    out.add(UInt8(length & 0xff))
    out.add(UInt8((length >> 8) & 0xff))
    out.add(UInt8(complement & 0xff))
    out.add(UInt8((complement >> 8) & 0xff))
    for (value in chunk) {
        out.add(value)
    }
}

func appendUInt8Array(out: ArrayList<UInt8>, bytes: Array<UInt8>): Unit {
    for (value in bytes) {
        out.add(value)
    }
}

func appendLittleEndian32(out: ArrayList<UInt8>, value: Int64): Unit {
    out.add(UInt8(value & 0xff))
    out.add(UInt8((value >> 8) & 0xff))
    out.add(UInt8((value >> 16) & 0xff))
    out.add(UInt8((value >> 24) & 0xff))
}

func readCompressionChunk(source: InputStream, size: Int64): Array<Byte> {
    let out = ArrayList<Byte>()
    while (out.size < size) {
        let remaining = size - out.size
        let readSize = if (remaining < 4096) { remaining } else { 4096 }
        let buffer = Array<Byte>(readSize, repeat: 0)
        let count = source.read(buffer)
        if (count <= 0) {
            break
        }
        for (i in 0..count) {
            out.add(buffer[i])
        }
    }
    out.toArray()
}

func crc32UpdateByte(current: Int64, value: Int64): Int64 {
    var crc = current ^ (value & 0xff)
    for (_ in 0..8) {
        if ((crc & 1) != 0) {
            crc = (crc >> 1) ^ 0xedb88320
        } else {
            crc = crc >> 1
        }
    }
    crc & 0xffffffff
}

func compressionHash(body: Array<UInt8>, offset: Int64): Int64 {
    let a = Int64(body[offset])
    let b = Int64(body[offset + 1])
    let c = Int64(body[offset + 2])
    ((a * 251 + b) * 251 + c) & 0xffff
}

func reverseCompressionBits(value: Int64, count: Int64): Int64 {
    var source = value
    var reversed: Int64 = 0
    for (_ in 0..count) {
        reversed = (reversed << 1) | (source & 1)
        source = source >> 1
    }
    reversed
}

func normalizeCompressionLevel(level: Int64): Int64 {
    if (level < 0) { return 0 }
    if (level > 9) { return 9 }
    level
}

func normalizeCompressionChunkSize(size: Int64): Int64 {
    if (size < 256) { return 256 }
    if (size > 65535) { return 65535 }
    size
}

func minCompressionInt(left: Int64, right: Int64): Int64 {
    if (left < right) { left } else { right }
}
