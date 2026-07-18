package ignite

import std.collection.ArrayList
import std.io.InputStream

let BROTLI_MAX_META_BLOCK_SIZE: Int64 = 65536
let BROTLI_COPY_BASES: Array<Int64> = [
    2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 18,
    22, 30, 38, 54, 70, 102, 134, 198, 326, 582, 1094, 2118
]
let BROTLI_COPY_EXTRA_BITS: Array<Int64> = [
    0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 2, 2,
    3, 3, 4, 4, 5, 5, 6, 7, 8, 9, 10, 24
]

/// Encode one complete response as a standards-compatible Brotli stream.
///
/// The Preview baseline writes bounded RAW meta-blocks and uses one literal
/// plus a distance-one copy command for all-equal blocks. General matching,
/// context modeling, dictionaries, and multi-symbol Huffman trees remain a
/// later optimization boundary.
public func compressBrotliResponsePayload(body: Array<UInt8>): Array<UInt8> {
    let writer = BrotliBitWriter()
    writer.writeBits(0, 1) // WBITS=16.
    var cursor: Int64 = 0
    while (cursor < body.size) {
        let remaining = body.size - cursor
        let size = if (remaining > BROTLI_MAX_META_BLOCK_SIZE) {
            BROTLI_MAX_META_BLOCK_SIZE
        } else {
            remaining
        }
        let block = Array<UInt8>(size, repeat: 0)
        for (i in 0..size) {
            block[i] = body[cursor + i]
        }
        appendBrotliMetaBlock(writer, block)
        cursor += size
    }
    appendBrotliLastEmptyMetaBlock(writer)
    writer.finish()
}

/// Incrementally encode one response as a bounded Brotli stream.
public class BrotliCompressionInputStream <: InputStream & Resource {
    let source: InputStream
    let chunkSize: Int64
    let writer = BrotliBitWriter()
    var started: Bool = false
    var finished: Bool = false
    var closed: Bool = false
    var pending: Array<Byte> = []
    var pendingCursor: Int64 = 0

    public init(source: InputStream, chunkSize!: Int64 = 16384) {
        this.source = source
        this.chunkSize = normalizeBrotliChunkSize(chunkSize)
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
                let copyLength = if (available < remaining) { available } else { remaining }
                for (i in 0..copyLength) {
                    outBuf[written + i] = pending[pendingCursor + i]
                }
                pendingCursor += copyLength
                written += copyLength
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
            case resource: Resource => resource.close()
            case _ => ()
        }
    }

    public func isClosed(): Bool {
        closed
    }

    func prepareNextOutput(): Bool {
        pending = []
        pendingCursor = 0
        if (finished) {
            return false
        }
        if (!started) {
            started = true
            writer.writeBits(0, 1) // WBITS=16.
        }

        let chunk = readCompressionChunk(source, chunkSize)
        if (chunk.size == 0) {
            appendBrotliLastEmptyMetaBlock(writer)
            pending = writer.finishBytes()
            finished = true
            return pending.size > 0
        }
        appendBrotliMetaBlock(writer, chunk)
        pending = writer.takeBytes()
        pending.size > 0
    }
}

class BrotliBitWriter {
    var out = ArrayList<UInt8>()
    var bits: Int64 = 0
    var bitCount: Int64 = 0

    func writeBits(value: Int64, count: Int64): Unit {
        if (count <= 0) {
            return
        }
        let mask = (Int64(1) << count) - 1
        bits = bits | ((value & mask) << bitCount)
        bitCount += count
        while (bitCount >= 8) {
            out.add(UInt8(bits & 0xff))
            bits = bits >> 8
            bitCount -= 8
        }
    }

    func alignByte(): Unit {
        if (bitCount > 0) {
            out.add(UInt8(bits & 0xff))
            bits = 0
            bitCount = 0
        }
    }

    func appendRaw(bytes: Array<UInt8>): Unit {
        alignByte()
        for (value in bytes) {
            out.add(value)
        }
    }

    func takeBytes(): Array<Byte> {
        let bytes = out.toArray()
        out = ArrayList<UInt8>()
        bytes
    }

    func finishBytes(): Array<Byte> {
        alignByte()
        takeBytes()
    }

    func finish(): Array<UInt8> {
        alignByte()
        out.toArray()
    }
}

func appendBrotliMetaBlock(writer: BrotliBitWriter, block: Array<UInt8>): Unit {
    if (block.size >= 3 && brotliBlockIsRle(block)) {
        appendBrotliRleMetaBlock(writer, block[0], block.size)
    } else {
        appendBrotliRawMetaBlock(writer, block)
    }
}

func appendBrotliRawMetaBlock(writer: BrotliBitWriter, block: Array<UInt8>): Unit {
    appendBrotliMetaBlockHeader(writer, block.size, true)
    writer.appendRaw(block)
}

func appendBrotliRleMetaBlock(writer: BrotliBitWriter, value: UInt8, length: Int64): Unit {
    appendBrotliMetaBlockHeader(writer, length, false)
    writer.writeBits(0, 13) // One block type/tree for literals, commands, distances.

    appendBrotliSingleSymbolTree(writer, Int64(value), 8)
    let copyLength = length - 1
    let copyCode = brotliCopyLengthCode(copyLength)
    appendBrotliSingleSymbolTree(writer, brotliRleCommandCode(copyCode), 10)
    appendBrotliSingleSymbolTree(writer, 16, 6) // Distance code 16, extra 0 => distance 1.

    let extraBits = BROTLI_COPY_EXTRA_BITS[copyCode]
    writer.writeBits(copyLength - BROTLI_COPY_BASES[copyCode], extraBits)
    writer.writeBits(0, 1)
}

func appendBrotliMetaBlockHeader(
    writer: BrotliBitWriter,
    length: Int64,
    uncompressed: Bool
): Unit {
    writer.writeBits(0, 1) // Non-final; stream ends with a separate empty block.
    writer.writeBits(0, 2) // Four nibbles encode lengths up to 65536.
    writer.writeBits(length - 1, 16)
    writer.writeBits(if (uncompressed) { 1 } else { 0 }, 1)
}

func appendBrotliLastEmptyMetaBlock(writer: BrotliBitWriter): Unit {
    writer.writeBits(1, 1)
    writer.writeBits(1, 1)
}

func appendBrotliSingleSymbolTree(
    writer: BrotliBitWriter,
    symbol: Int64,
    alphabetBits: Int64
): Unit {
    writer.writeBits(1, 4)
    writer.writeBits(symbol, alphabetBits)
}

func brotliBlockIsRle(block: Array<UInt8>): Bool {
    let first = block[0]
    for (value in block) {
        if (value != first) {
            return false
        }
    }
    true
}

func brotliCopyLengthCode(length: Int64): Int64 {
    if (length < 10) {
        return length - 2
    }
    if (length < 134) {
        let bitCount = brotliLog2Floor(length - 6) - 1
        return (bitCount << 1) + ((length - 6) >> bitCount) + 4
    }
    if (length < 2118) {
        return brotliLog2Floor(length - 70) + 12
    }
    23
}

func brotliRleCommandCode(copyCode: Int64): Int64 {
    let lowBits = 8 | (copyCode & 7) // Insert length code 1.
    if (copyCode < 8) {
        return 128 + lowBits
    }
    if (copyCode < 16) {
        return 192 + lowBits
    }
    384 + lowBits
}

func brotliLog2Floor(value: Int64): Int64 {
    var remaining = value
    var result: Int64 = -1
    while (remaining > 0) {
        remaining = remaining >> 1
        result += 1
    }
    result
}

func normalizeBrotliChunkSize(size: Int64): Int64 {
    if (size < 256) { return 256 }
    if (size > BROTLI_MAX_META_BLOCK_SIZE) { return BROTLI_MAX_META_BLOCK_SIZE }
    size
}
