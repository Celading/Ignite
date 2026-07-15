package ignite.native_h2

import std.collection.ArrayList

let NATIVE_H2_HPACK_DEFAULT_DYNAMIC_TABLE_SIZE: Int64 = 4096
let NATIVE_H2_HPACK_FIRST_DYNAMIC_INDEX: Int64 = 62

class NativeH2HpackField {
    let name: String
    let value: String

    init(name: String, value: String) {
        this.name = name
        this.value = value
    }
}

class NativeH2HpackIntegerResult {
    let value: Int64
    let nextCursor: Int64

    init(value: Int64, nextCursor: Int64) {
        this.value = value
        this.nextCursor = nextCursor
    }
}

class NativeH2HpackStringResult {
    let text: String
    let nextCursor: Int64

    init(text: String, nextCursor: Int64) {
        this.text = text
        this.nextCursor = nextCursor
    }
}

class NativeH2HpackFieldResult {
    let field: NativeH2HpackField
    let nextCursor: Int64

    init(field: NativeH2HpackField, nextCursor: Int64) {
        this.field = field
        this.nextCursor = nextCursor
    }
}

class NativeH2HpackDynamicTable {
    let entries = ArrayList<NativeH2HpackField>()
    let maxAllowedSize: Int64
    var maxSize: Int64
    var currentSize: Int64 = 0

    init(maxSize: Int64) {
        if (maxSize < 0 || maxSize > NATIVE_H2_HPACK_DEFAULT_DYNAMIC_TABLE_SIZE) {
            nativeH2HpackFailure(
                "native H2 HPACK dynamic table size exceeds bounded default, value=${maxSize}"
            )
        }
        this.maxAllowedSize = maxSize
        this.maxSize = maxSize
    }

    func updateMaxSize(value: Int64): Unit {
        if (value < 0 || value > maxAllowedSize) {
            nativeH2HpackFailure(
                "native H2 HPACK dynamic table update exceeds configured max, value=${value}, max=${maxAllowedSize}"
            )
        }
        maxSize = value
        evictToLimit()
    }

    func add(name: String, value: String): Unit {
        let entry = NativeH2HpackField(name, value)
        let size = entrySize(entry)
        if (size > maxSize) {
            entries.clear()
            currentSize = 0
            return
        }
        entries.add(entry)
        currentSize += size
        evictToLimit()
    }

    func lookup(index: Int64): NativeH2HpackField {
        let offset = index - NATIVE_H2_HPACK_FIRST_DYNAMIC_INDEX
        if (offset < 0 || offset >= entries.size) {
            nativeH2HpackFailure(
                "native H2 HPACK dynamic index is unavailable, index=${index}, entries=${entries.size}"
            )
        }
        entries[entries.size - 1 - offset]
    }

    func evictToLimit(): Unit {
        while (currentSize > maxSize && entries.size > 0) {
            let removed = entries.remove(at: Int64(0))
            currentSize -= entrySize(removed)
        }
    }

    func entrySize(entry: NativeH2HpackField): Int64 {
        entry.name.size + entry.value.size + 32
    }
}

class NativeH2HpackDecoderState {
    let dynamicTable: NativeH2HpackDynamicTable

    init() {
        dynamicTable = NativeH2HpackDynamicTable(
            NATIVE_H2_HPACK_DEFAULT_DYNAMIC_TABLE_SIZE
        )
    }

    func dynamicEntryCount(): Int64 {
        dynamicTable.entries.size
    }

    func decodeRequestHead(payload: Array<UInt8>): NativeH2DecodedRequestHead {
        let fields = nativeH2HpackDecodeFields(payload, dynamicTable)
        var method = ""
        var scheme = ""
        var authority = ""
        var path = ""
        let headers = ArrayList<NativeH2Header>()
        var regularHeaderSeen = false
        for (field in fields) {
            if (field.name.startsWith(":")) {
                if (regularHeaderSeen) {
                    nativeH2HpackFailure(
                        "native H2 HPACK pseudo-header appears after a regular header"
                    )
                }
                if (field.name == ":method") {
                    if (method.size > 0) { nativeH2HpackDuplicatePseudo(field.name) }
                    method = field.value
                } else if (field.name == ":scheme") {
                    if (scheme.size > 0) { nativeH2HpackDuplicatePseudo(field.name) }
                    scheme = field.value
                } else if (field.name == ":authority") {
                    if (authority.size > 0) { nativeH2HpackDuplicatePseudo(field.name) }
                    authority = field.value
                } else if (field.name == ":path") {
                    if (path.size > 0) { nativeH2HpackDuplicatePseudo(field.name) }
                    path = field.value
                } else {
                    nativeH2HpackFailure(
                        "native H2 request uses unsupported pseudo-header ${field.name}"
                    )
                }
            } else {
                regularHeaderSeen = true
                headers.add(NativeH2Header(field.name, field.value))
            }
        }
        if (method.size == 0 || scheme.size == 0 || authority.size == 0 || path.size == 0) {
            nativeH2ProtocolFailure(
                "native H2 request requires :method, :scheme, :authority, and :path"
            )
        }
        NativeH2DecodedRequestHead(
            method, scheme, authority, path, headers: headers.toArray()
        )
    }

    func decodeRequestTrailers(payload: Array<UInt8>): Array<NativeH2Header> {
        let fields = nativeH2HpackDecodeFields(payload, dynamicTable)
        let trailers = ArrayList<NativeH2Header>()
        for (field in fields) {
            if (field.name.startsWith(":")) {
                nativeH2ProtocolFailure(
                    "native H2 request trailers must not contain pseudo-headers"
                )
            }
            trailers.add(NativeH2Header(field.name, field.value))
        }
        trailers.toArray()
    }
}

func nativeH2DecodeRequestHead(payload: Array<UInt8>): NativeH2DecodedRequestHead {
    NativeH2HpackDecoderState().decodeRequestHead(payload)
}

func nativeH2HpackDecodeFields(
    payload: Array<UInt8>,
    dynamicTable: NativeH2HpackDynamicTable
): Array<NativeH2HpackField> {
    let out = ArrayList<NativeH2HpackField>()
    var cursor: Int64 = 0
    var tableUpdateAllowed = true
    while (cursor < payload.size) {
        let lead = Int64(payload[cursor])
        if ((lead & 0x80) != 0) {
            let indexed = nativeH2HpackDecodeInteger(payload, cursor, 7)
            if (indexed.value <= 0) {
                nativeH2HpackFailure("native H2 HPACK indexed field requires index >= 1")
            }
            out.add(nativeH2HpackFieldByIndex(indexed.value, dynamicTable))
            cursor = indexed.nextCursor
            tableUpdateAllowed = false
            continue
        }
        if ((lead & 0x40) != 0) {
            let decoded = nativeH2HpackDecodeLiteral(payload, cursor, 6, dynamicTable)
            out.add(decoded.field)
            dynamicTable.add(decoded.field.name, decoded.field.value)
            cursor = decoded.nextCursor
            tableUpdateAllowed = false
            continue
        }
        if ((lead & 0x20) != 0) {
            if (!tableUpdateAllowed) {
                nativeH2HpackFailure(
                    "native H2 HPACK dynamic table update must precede header fields"
                )
            }
            let update = nativeH2HpackDecodeInteger(payload, cursor, 5)
            dynamicTable.updateMaxSize(update.value)
            cursor = update.nextCursor
            continue
        }
        let decoded = nativeH2HpackDecodeLiteral(payload, cursor, 4, dynamicTable)
        out.add(decoded.field)
        cursor = decoded.nextCursor
        tableUpdateAllowed = false
    }
    out.toArray()
}

func nativeH2HpackDecodeLiteral(
    payload: Array<UInt8>,
    cursor: Int64,
    prefixBits: Int64,
    dynamicTable: NativeH2HpackDynamicTable
): NativeH2HpackFieldResult {
    let nameIndex = nativeH2HpackDecodeInteger(payload, cursor, prefixBits)
    var nextCursor = nameIndex.nextCursor
    let name = if (nameIndex.value == 0) {
        let decoded = nativeH2HpackDecodeString(payload, nextCursor)
        nextCursor = decoded.nextCursor
        decoded.text
    } else {
        nativeH2HpackFieldByIndex(nameIndex.value, dynamicTable).name
    }
    if (name.size == 0) {
        nativeH2HpackFailure("native H2 HPACK header name cannot be empty")
    }
    let value = nativeH2HpackDecodeString(payload, nextCursor)
    NativeH2HpackFieldResult(
        NativeH2HpackField(name, value.text),
        value.nextCursor
    )
}

func nativeH2HpackDecodeInteger(
    payload: Array<UInt8>,
    cursor: Int64,
    prefixBits: Int64
): NativeH2HpackIntegerResult {
    if (cursor >= payload.size) {
        nativeH2HpackFailure("native H2 HPACK integer cursor is out of range")
    }
    let prefixMask = nativeH2HpackPrefixMask(prefixBits)
    var value = Int64(payload[cursor]) & prefixMask
    var nextCursor = cursor + 1
    if (value < prefixMask) {
        return NativeH2HpackIntegerResult(value, nextCursor)
    }
    var shift: Int64 = 0
    while (true) {
        if (nextCursor >= payload.size) {
            nativeH2HpackFailure("native H2 HPACK integer is truncated")
        }
        let octet = Int64(payload[nextCursor])
        if (shift > 56) {
            nativeH2HpackFailure("native H2 HPACK integer exceeds Int64 range")
        }
        value += (octet & 0x7f) << shift
        nextCursor += 1
        if ((octet & 0x80) == 0) {
            break
        }
        shift += 7
    }
    NativeH2HpackIntegerResult(value, nextCursor)
}

func nativeH2HpackDecodeString(
    payload: Array<UInt8>,
    cursor: Int64
): NativeH2HpackStringResult {
    if (cursor >= payload.size) {
        nativeH2HpackFailure("native H2 HPACK string cursor is out of range")
    }
    let huffman = (payload[cursor] & UInt8(0x80)) != UInt8(0)
    let length = nativeH2HpackDecodeInteger(payload, cursor, 7)
    if (length.value > payload.size - length.nextCursor) {
        nativeH2HpackFailure("native H2 HPACK string payload is truncated")
    }
    let text = if (huffman) {
        nativeH2HpackDecodeVisibleAsciiHuffman(
            payload, length.nextCursor, length.value, cursor
        )
    } else {
        String.fromUtf8(
            nativeH2Slice(payload, length.nextCursor, length.nextCursor + length.value)
        )
    }
    NativeH2HpackStringResult(text, length.nextCursor + length.value)
}

func nativeH2HpackDecodeVisibleAsciiHuffman(
    payload: Array<UInt8>,
    payloadCursor: Int64,
    payloadLength: Int64,
    stringOffset: Int64
): String {
    let out = ArrayList<UInt8>()
    var code: Int64 = 0
    var bitCount: Int64 = 0
    var i: Int64 = 0
    while (i < payloadLength) {
        let octet = Int64(payload[payloadCursor + i])
        var bit: Int64 = 7
        while (bit >= 0) {
            code = (code << 1) | ((octet >> bit) & 0x01)
            bitCount += 1
            let symbol = nativeH2HpackVisibleAsciiSymbol(code, bitCount)
            if (symbol >= 0) {
                out.add(UInt8(symbol))
                code = 0
                bitCount = 0
            } else if (!nativeH2HpackVisibleAsciiHasPrefix(code, bitCount)) {
                nativeH2HpackFailure(
                    "native H2 HPACK Huffman string has unsupported symbol at offset=${stringOffset}"
                )
            }
            bit -= 1
        }
        i += 1
    }
    if (bitCount > 0) {
        if (bitCount > 7 || code != (Int64(1) << bitCount) - 1) {
            nativeH2HpackFailure(
                "native H2 HPACK Huffman string has invalid padding at offset=${stringOffset}"
            )
        }
    }
    String.fromUtf8(out.toArray())
}

func nativeH2HpackVisibleAsciiHasPrefix(code: Int64, length: Int64): Bool {
    nativeH2HpackPrefixInRange(code, length, 0x00, 0x09, 5) ||
        nativeH2HpackPrefixInRange(code, length, 0x14, 0x2d, 6) ||
        nativeH2HpackPrefixInRange(code, length, 0x5c, 0x7b, 7) ||
        nativeH2HpackPrefixInRange(code, length, 0xf8, 0xfd, 8) ||
        nativeH2HpackPrefixInRange(code, length, 0x3f8, 0x3fc, 10) ||
        nativeH2HpackPrefixInRange(code, length, 0x7fa, 0x7fc, 11) ||
        nativeH2HpackPrefixInRange(code, length, 0xffa, 0xffb, 12) ||
        nativeH2HpackPrefixInRange(code, length, 0x1ff9, 0x1ffd, 13) ||
        nativeH2HpackPrefixInRange(code, length, 0x3ffc, 0x3ffd, 14) ||
        nativeH2HpackPrefixInRange(code, length, 0x7ffc, 0x7ffe, 15) ||
        nativeH2HpackPrefixInRange(code, length, 0x7fff0, 0x7fff0, 19)
}

func nativeH2HpackPrefixInRange(
    code: Int64,
    length: Int64,
    startCode: Int64,
    endCode: Int64,
    targetLength: Int64
): Bool {
    if (length > targetLength) {
        return false
    }
    let shift = targetLength - length
    code >= (startCode >> shift) && code <= (endCode >> shift)
}

func nativeH2HpackVisibleAsciiSymbol(code: Int64, length: Int64): Int64 {
    if (length == 5) {
        if (code == 0x00) { return 0x30 }
        if (code == 0x01) { return 0x31 }
        if (code == 0x02) { return 0x32 }
        if (code == 0x03) { return 0x61 }
        if (code == 0x04) { return 0x63 }
        if (code == 0x05) { return 0x65 }
        if (code == 0x06) { return 0x69 }
        if (code == 0x07) { return 0x6f }
        if (code == 0x08) { return 0x73 }
        if (code == 0x09) { return 0x74 }
    }
    if (length == 6) {
        if (code == 0x14) { return 0x20 }
        if (code == 0x15) { return 0x25 }
        if (code == 0x16) { return 0x2d }
        if (code == 0x17) { return 0x2e }
        if (code == 0x18) { return 0x2f }
        if (code == 0x19) { return 0x33 }
        if (code == 0x1a) { return 0x34 }
        if (code == 0x1b) { return 0x35 }
        if (code == 0x1c) { return 0x36 }
        if (code == 0x1d) { return 0x37 }
        if (code == 0x1e) { return 0x38 }
        if (code == 0x1f) { return 0x39 }
        if (code == 0x20) { return 0x3d }
        if (code == 0x21) { return 0x41 }
        if (code == 0x22) { return 0x5f }
        if (code == 0x23) { return 0x62 }
        if (code == 0x24) { return 0x64 }
        if (code == 0x25) { return 0x66 }
        if (code == 0x26) { return 0x67 }
        if (code == 0x27) { return 0x68 }
        if (code == 0x28) { return 0x6c }
        if (code == 0x29) { return 0x6d }
        if (code == 0x2a) { return 0x6e }
        if (code == 0x2b) { return 0x70 }
        if (code == 0x2c) { return 0x72 }
        if (code == 0x2d) { return 0x75 }
    }
    if (length == 7) {
        if (code == 0x5c) { return 0x3a }
        if (code == 0x5d) { return 0x42 }
        if (code == 0x5e) { return 0x43 }
        if (code == 0x5f) { return 0x44 }
        if (code == 0x60) { return 0x45 }
        if (code == 0x61) { return 0x46 }
        if (code == 0x62) { return 0x47 }
        if (code == 0x63) { return 0x48 }
        if (code == 0x64) { return 0x49 }
        if (code == 0x65) { return 0x4a }
        if (code == 0x66) { return 0x4b }
        if (code == 0x67) { return 0x4c }
        if (code == 0x68) { return 0x4d }
        if (code == 0x69) { return 0x4e }
        if (code == 0x6a) { return 0x4f }
        if (code == 0x6b) { return 0x50 }
        if (code == 0x6c) { return 0x51 }
        if (code == 0x6d) { return 0x52 }
        if (code == 0x6e) { return 0x53 }
        if (code == 0x6f) { return 0x54 }
        if (code == 0x70) { return 0x55 }
        if (code == 0x71) { return 0x56 }
        if (code == 0x72) { return 0x57 }
        if (code == 0x73) { return 0x59 }
        if (code == 0x74) { return 0x6a }
        if (code == 0x75) { return 0x6b }
        if (code == 0x76) { return 0x71 }
        if (code == 0x77) { return 0x76 }
        if (code == 0x78) { return 0x77 }
        if (code == 0x79) { return 0x78 }
        if (code == 0x7a) { return 0x79 }
        if (code == 0x7b) { return 0x7a }
    }
    if (length == 8) {
        if (code == 0xf8) { return 0x26 }
        if (code == 0xf9) { return 0x2a }
        if (code == 0xfa) { return 0x2c }
        if (code == 0xfb) { return 0x3b }
        if (code == 0xfc) { return 0x58 }
        if (code == 0xfd) { return 0x5a }
    }
    if (length == 10) {
        if (code == 0x3f8) { return 0x21 }
        if (code == 0x3f9) { return 0x22 }
        if (code == 0x3fa) { return 0x28 }
        if (code == 0x3fb) { return 0x29 }
        if (code == 0x3fc) { return 0x3f }
    }
    if (length == 11) {
        if (code == 0x7fa) { return 0x27 }
        if (code == 0x7fb) { return 0x2b }
        if (code == 0x7fc) { return 0x7c }
    }
    if (length == 12) {
        if (code == 0xffa) { return 0x23 }
        if (code == 0xffb) { return 0x3e }
    }
    if (length == 13) {
        if (code == 0x1ff9) { return 0x24 }
        if (code == 0x1ffa) { return 0x40 }
        if (code == 0x1ffb) { return 0x5b }
        if (code == 0x1ffc) { return 0x5d }
        if (code == 0x1ffd) { return 0x7e }
    }
    if (length == 14) {
        if (code == 0x3ffc) { return 0x5e }
        if (code == 0x3ffd) { return 0x7d }
    }
    if (length == 15) {
        if (code == 0x7ffc) { return 0x3c }
        if (code == 0x7ffd) { return 0x60 }
        if (code == 0x7ffe) { return 0x7b }
    }
    if (length == 19 && code == 0x7fff0) { return 0x5c }
    -1
}

func nativeH2HpackFieldByIndex(
    index: Int64,
    dynamicTable: NativeH2HpackDynamicTable
): NativeH2HpackField {
    if (index >= NATIVE_H2_HPACK_FIRST_DYNAMIC_INDEX) {
        return dynamicTable.lookup(index)
    }
    nativeH2HpackStaticField(index)
}

func nativeH2HpackStaticField(index: Int64): NativeH2HpackField {
    if (index == 1) { return NativeH2HpackField(":authority", "") }
    if (index == 2) { return NativeH2HpackField(":method", "GET") }
    if (index == 3) { return NativeH2HpackField(":method", "POST") }
    if (index == 4) { return NativeH2HpackField(":path", "/") }
    if (index == 5) { return NativeH2HpackField(":path", "/index.html") }
    if (index == 6) { return NativeH2HpackField(":scheme", "http") }
    if (index == 7) { return NativeH2HpackField(":scheme", "https") }
    if (index == 8) { return NativeH2HpackField(":status", "200") }
    if (index == 9) { return NativeH2HpackField(":status", "204") }
    if (index == 10) { return NativeH2HpackField(":status", "206") }
    if (index == 11) { return NativeH2HpackField(":status", "304") }
    if (index == 12) { return NativeH2HpackField(":status", "400") }
    if (index == 13) { return NativeH2HpackField(":status", "404") }
    if (index == 14) { return NativeH2HpackField(":status", "500") }
    if (index == 15) { return NativeH2HpackField("accept-charset", "") }
    if (index == 16) { return NativeH2HpackField("accept-encoding", "gzip, deflate") }
    if (index == 17) { return NativeH2HpackField("accept-language", "") }
    if (index == 18) { return NativeH2HpackField("accept-ranges", "") }
    if (index == 19) { return NativeH2HpackField("accept", "") }
    if (index == 20) { return NativeH2HpackField("access-control-allow-origin", "") }
    if (index == 21) { return NativeH2HpackField("age", "") }
    if (index == 22) { return NativeH2HpackField("allow", "") }
    if (index == 23) { return NativeH2HpackField("authorization", "") }
    if (index == 24) { return NativeH2HpackField("cache-control", "") }
    if (index == 25) { return NativeH2HpackField("content-disposition", "") }
    if (index == 26) { return NativeH2HpackField("content-encoding", "") }
    if (index == 27) { return NativeH2HpackField("content-language", "") }
    if (index == 28) { return NativeH2HpackField("content-length", "") }
    if (index == 29) { return NativeH2HpackField("content-location", "") }
    if (index == 30) { return NativeH2HpackField("content-range", "") }
    if (index == 31) { return NativeH2HpackField("content-type", "") }
    if (index == 32) { return NativeH2HpackField("cookie", "") }
    if (index == 33) { return NativeH2HpackField("date", "") }
    if (index == 34) { return NativeH2HpackField("etag", "") }
    if (index == 35) { return NativeH2HpackField("expect", "") }
    if (index == 36) { return NativeH2HpackField("expires", "") }
    if (index == 37) { return NativeH2HpackField("from", "") }
    if (index == 38) { return NativeH2HpackField("host", "") }
    if (index == 39) { return NativeH2HpackField("if-match", "") }
    if (index == 40) { return NativeH2HpackField("if-modified-since", "") }
    if (index == 41) { return NativeH2HpackField("if-none-match", "") }
    if (index == 42) { return NativeH2HpackField("if-range", "") }
    if (index == 43) { return NativeH2HpackField("if-unmodified-since", "") }
    if (index == 44) { return NativeH2HpackField("last-modified", "") }
    if (index == 45) { return NativeH2HpackField("link", "") }
    if (index == 46) { return NativeH2HpackField("location", "") }
    if (index == 47) { return NativeH2HpackField("max-forwards", "") }
    if (index == 48) { return NativeH2HpackField("proxy-authenticate", "") }
    if (index == 49) { return NativeH2HpackField("proxy-authorization", "") }
    if (index == 50) { return NativeH2HpackField("range", "") }
    if (index == 51) { return NativeH2HpackField("referer", "") }
    if (index == 52) { return NativeH2HpackField("refresh", "") }
    if (index == 53) { return NativeH2HpackField("retry-after", "") }
    if (index == 54) { return NativeH2HpackField("server", "") }
    if (index == 55) { return NativeH2HpackField("set-cookie", "") }
    if (index == 56) { return NativeH2HpackField("strict-transport-security", "") }
    if (index == 57) { return NativeH2HpackField("transfer-encoding", "") }
    if (index == 58) { return NativeH2HpackField("user-agent", "") }
    if (index == 59) { return NativeH2HpackField("vary", "") }
    if (index == 60) { return NativeH2HpackField("via", "") }
    if (index == 61) { return NativeH2HpackField("www-authenticate", "") }
    nativeH2HpackFailure("native H2 HPACK static index is invalid, index=${index}")
}

func nativeH2HpackPrefixMask(prefixBits: Int64): Int64 {
    if (prefixBits == 4) { return 0x0f }
    if (prefixBits == 5) { return 0x1f }
    if (prefixBits == 6) { return 0x3f }
    if (prefixBits == 7) { return 0x7f }
    nativeH2HpackFailure("native H2 HPACK prefix width is unsupported")
}

func nativeH2HpackDuplicatePseudo(name: String): Nothing {
    nativeH2HpackFailure("native H2 HPACK pseudo-header is duplicated: ${name}")
}

func nativeH2HpackFailure(message: String): Nothing {
    nativeH2ProtocolFailure(message, NATIVE_H2_ERROR_COMPRESSION)
}
