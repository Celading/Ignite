package ignite

import std.collection.ArrayList
import std.io.InputStream
import std.overflow.WrappingOp

let ZSTD_MAGIC: Array<UInt8> = [0x28, 0xb5, 0x2f, 0xfd]
let ZSTD_MAX_BLOCK_SIZE: Int64 = 131072
let ZSTD_WINDOW_DESCRIPTOR_128K: UInt8 = 0x38

let XXH64_PRIME1: UInt64 = 0x9e3779b185ebca87_u64
let XXH64_PRIME2: UInt64 = 0xc2b2ae3d27d4eb4f_u64
let XXH64_PRIME3: UInt64 = 0x165667b19e3779f9_u64
let XXH64_PRIME4: UInt64 = 0x85ebca77c2b2ae63_u64
let XXH64_PRIME5: UInt64 = 0x27d4eb2f165667c5_u64

/// Encode one complete response as a standards-compatible Zstd frame.
///
/// The Preview baseline uses bounded RAW blocks and switches an all-equal block
/// to Zstd RLE. General sequence/FSE/Huffman compression remains a later
/// optimization and is not implied by this API.
public func compressZstdResponsePayload(
    body: Array<UInt8>,
    checksum!: Bool = true
): Array<UInt8> {
    let out = ArrayList<UInt8>()
    appendZstdKnownSizeHeader(out, body.size, checksum)
    appendZstdBlocks(out, body)
    if (checksum) {
        appendZstdChecksum(out, xxHash64(body))
    }
    out.toArray()
}

/// Incrementally encode an unknown-length response as one bounded Zstd frame.
public class ZstdCompressionInputStream <: InputStream & Resource {
    let source: InputStream
    let chunkSize: Int64
    let checksumEnabled: Bool
    let checksumState = XxHash64State()
    var headerEmitted: Bool = false
    var finished: Bool = false
    var closed: Bool = false
    var currentChunk: ?Array<Byte> = None
    var pending: Array<Byte> = []
    var pendingCursor: Int64 = 0

    public init(
        source: InputStream,
        chunkSize!: Int64 = 16384,
        checksum!: Bool = true
    ) {
        this.source = source
        this.chunkSize = normalizeZstdChunkSize(chunkSize)
        this.checksumEnabled = checksum
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
            pending = zstdUnknownSizeHeaderBytes(checksumEnabled)
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
        let out = ArrayList<Byte>()
        if (chunk.size > 0) {
            checksumState.update(chunk)
        }
        appendZstdBlock(out, chunk, isFinal)
        if (isFinal) {
            if (checksumEnabled) {
                appendZstdChecksumBytes(out, checksumState.digest())
            }
            finished = true
            currentChunk = None
        } else {
            currentChunk = Some(next)
        }
        pending = out.toArray()
        true
    }
}

class XxHash64State {
    var totalLength: UInt64 = 0
    var v1: UInt64 = XXH64_PRIME1.wrappingAdd(XXH64_PRIME2)
    var v2: UInt64 = XXH64_PRIME2
    var v3: UInt64 = 0
    var v4: UInt64 = UInt64(0).wrappingSub(XXH64_PRIME1)
    let memory = Array<UInt8>(32, repeat: 0)
    var memorySize: Int64 = 0

    func update(input: Array<UInt8>): Unit {
        if (input.size == 0) {
            return
        }
        totalLength = totalLength.wrappingAdd(UInt64(input.size))
        var cursor: Int64 = 0

        if (memorySize + input.size < 32) {
            copyXxHashBytes(input, 0, memory, memorySize, input.size)
            memorySize += input.size
            return
        }

        if (memorySize > 0) {
            let fill = 32 - memorySize
            copyXxHashBytes(input, 0, memory, memorySize, fill)
            consumeStripe(memory, 0)
            cursor += fill
            memorySize = 0
        }

        while (cursor + 32 <= input.size) {
            consumeStripe(input, cursor)
            cursor += 32
        }

        let remaining = input.size - cursor
        if (remaining > 0) {
            copyXxHashBytes(input, cursor, memory, 0, remaining)
            memorySize = remaining
        }
    }

    func digest(): UInt64 {
        var hash = if (totalLength >= UInt64(32)) {
            var value = rotateLeft64(v1, 1)
                .wrappingAdd(rotateLeft64(v2, 7))
                .wrappingAdd(rotateLeft64(v3, 12))
                .wrappingAdd(rotateLeft64(v4, 18))
            value = mergeXxHashRound(value, v1)
            value = mergeXxHashRound(value, v2)
            value = mergeXxHashRound(value, v3)
            mergeXxHashRound(value, v4)
        } else {
            XXH64_PRIME5
        }
        hash = hash.wrappingAdd(totalLength)

        var cursor: Int64 = 0
        while (cursor + 8 <= memorySize) {
            let lane = xxHashRound(UInt64(0), readLittleEndian64(memory, cursor))
            hash = hash ^ lane
            hash = rotateLeft64(hash, 27).wrappingMul(XXH64_PRIME1).wrappingAdd(XXH64_PRIME4)
            cursor += 8
        }
        if (cursor + 4 <= memorySize) {
            hash = hash ^ UInt64(readLittleEndian32(memory, cursor)).wrappingMul(XXH64_PRIME1)
            hash = rotateLeft64(hash, 23).wrappingMul(XXH64_PRIME2).wrappingAdd(XXH64_PRIME3)
            cursor += 4
        }
        while (cursor < memorySize) {
            hash = hash ^ UInt64(memory[cursor]).wrappingMul(XXH64_PRIME5)
            hash = rotateLeft64(hash, 11).wrappingMul(XXH64_PRIME1)
            cursor += 1
        }
        avalancheXxHash64(hash)
    }

    func consumeStripe(input: Array<UInt8>, offset: Int64): Unit {
        v1 = xxHashRound(v1, readLittleEndian64(input, offset))
        v2 = xxHashRound(v2, readLittleEndian64(input, offset + 8))
        v3 = xxHashRound(v3, readLittleEndian64(input, offset + 16))
        v4 = xxHashRound(v4, readLittleEndian64(input, offset + 24))
    }
}

func appendZstdKnownSizeHeader(out: ArrayList<UInt8>, contentSize: Int64, checksum: Bool): Unit {
    appendUInt8Array(out, ZSTD_MAGIC)
    let singleSegment = contentSize <= ZSTD_MAX_BLOCK_SIZE
    var descriptor: Int64 = if (singleSegment) { 0x20 } else { 0x00 }
    if (checksum) {
        descriptor = descriptor | 0x04
    }
    if (!singleSegment) {
        if (contentSize <= 0xffffffff) {
            out.add(UInt8(descriptor | 0x80))
            out.add(ZSTD_WINDOW_DESCRIPTOR_128K)
            appendLittleEndian32(out, contentSize)
        } else {
            out.add(UInt8(descriptor | 0xc0))
            out.add(ZSTD_WINDOW_DESCRIPTOR_128K)
            appendLittleEndian64(out, UInt64(contentSize))
        }
    } else if (contentSize < 256) {
        out.add(UInt8(descriptor))
        out.add(UInt8(contentSize))
    } else if (contentSize < 65792) {
        out.add(UInt8(descriptor | 0x40))
        appendLittleEndian16(out, contentSize - 256)
    } else {
        out.add(UInt8(descriptor | 0x80))
        appendLittleEndian32(out, contentSize)
    }
}

func zstdUnknownSizeHeaderBytes(checksum: Bool): Array<Byte> {
    let out = ArrayList<Byte>()
    for (value in ZSTD_MAGIC) {
        out.add(value)
    }
    out.add(if (checksum) { 0x04 } else { 0x00 })
    out.add(ZSTD_WINDOW_DESCRIPTOR_128K)
    out.toArray()
}

func appendZstdBlocks(out: ArrayList<UInt8>, body: Array<UInt8>): Unit {
    if (body.size == 0) {
        appendZstdBlock(out, [], true)
        return
    }
    var cursor: Int64 = 0
    while (cursor < body.size) {
        let remaining = body.size - cursor
        let size = if (remaining > ZSTD_MAX_BLOCK_SIZE) { ZSTD_MAX_BLOCK_SIZE } else { remaining }
        let block = Array<UInt8>(size, repeat: 0)
        copyXxHashBytes(body, cursor, block, 0, size)
        cursor += size
        appendZstdBlock(out, block, cursor >= body.size)
    }
}

func appendZstdBlock(out: ArrayList<UInt8>, block: Array<UInt8>, last: Bool): Unit {
    let useRle = block.size > 1 && zstdBlockIsRle(block)
    let blockType: Int64 = if (useRle) { 1 } else { 0 }
    let header = (block.size << 3) | (blockType << 1) | if (last) { 1 } else { 0 }
    out.add(UInt8(header & 0xff))
    out.add(UInt8((header >> 8) & 0xff))
    out.add(UInt8((header >> 16) & 0xff))
    if (useRle) {
        out.add(block[0])
    } else {
        appendUInt8Array(out, block)
    }
}

func zstdBlockIsRle(block: Array<UInt8>): Bool {
    let first = block[0]
    for (value in block) {
        if (value != first) {
            return false
        }
    }
    true
}

func appendZstdChecksum(out: ArrayList<UInt8>, hash: UInt64): Unit {
    out.add(UInt8(hash & UInt64(0xff)))
    out.add(UInt8((hash >> 8) & UInt64(0xff)))
    out.add(UInt8((hash >> 16) & UInt64(0xff)))
    out.add(UInt8((hash >> 24) & UInt64(0xff)))
}

func appendZstdChecksumBytes(out: ArrayList<Byte>, hash: UInt64): Unit {
    out.add(UInt8(hash & UInt64(0xff)))
    out.add(UInt8((hash >> 8) & UInt64(0xff)))
    out.add(UInt8((hash >> 16) & UInt64(0xff)))
    out.add(UInt8((hash >> 24) & UInt64(0xff)))
}

func appendLittleEndian16(out: ArrayList<UInt8>, value: Int64): Unit {
    out.add(UInt8(value & 0xff))
    out.add(UInt8((value >> 8) & 0xff))
}

func appendLittleEndian64(out: ArrayList<UInt8>, value: UInt64): Unit {
    for (shift in [0, 8, 16, 24, 32, 40, 48, 56]) {
        out.add(UInt8((value >> shift) & UInt64(0xff)))
    }
}

func xxHash64(input: Array<UInt8>): UInt64 {
    let state = XxHash64State()
    state.update(input)
    state.digest()
}

func xxHashRound(accumulator: UInt64, lane: UInt64): UInt64 {
    var value = accumulator.wrappingAdd(lane.wrappingMul(XXH64_PRIME2))
    value = rotateLeft64(value, 31)
    value.wrappingMul(XXH64_PRIME1)
}

func mergeXxHashRound(hash: UInt64, lane: UInt64): UInt64 {
    let mixed = hash ^ xxHashRound(UInt64(0), lane)
    mixed.wrappingMul(XXH64_PRIME1).wrappingAdd(XXH64_PRIME4)
}

func avalancheXxHash64(input: UInt64): UInt64 {
    var value = input
    value = value ^ (value >> 33)
    value = value.wrappingMul(XXH64_PRIME2)
    value = value ^ (value >> 29)
    value = value.wrappingMul(XXH64_PRIME3)
    value ^ (value >> 32)
}

func rotateLeft64(value: UInt64, count: Int64): UInt64 {
    (value << count) | (value >> (64 - count))
}

func readLittleEndian64(input: Array<UInt8>, offset: Int64): UInt64 {
    var value: UInt64 = 0
    var i: Int64 = 0
    while (i < 8) {
        value = value | (UInt64(input[offset + i]) << (i * 8))
        i += 1
    }
    value
}

func readLittleEndian32(input: Array<UInt8>, offset: Int64): UInt32 {
    var value: UInt32 = 0
    var i: Int64 = 0
    while (i < 4) {
        value = value | (UInt32(input[offset + i]) << (i * 8))
        i += 1
    }
    value
}

func copyXxHashBytes(
    source: Array<UInt8>,
    sourceOffset: Int64,
    target: Array<UInt8>,
    targetOffset: Int64,
    length: Int64
): Unit {
    for (i in 0..length) {
        target[targetOffset + i] = source[sourceOffset + i]
    }
}

func normalizeZstdChunkSize(size: Int64): Int64 {
    if (size < 256) { return 256 }
    if (size > ZSTD_MAX_BLOCK_SIZE) { return ZSTD_MAX_BLOCK_SIZE }
    size
}
