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
    let maxHeaderListSize: Int64

    init() {
        dynamicTable = NativeH2HpackDynamicTable(
            NATIVE_H2_HPACK_DEFAULT_DYNAMIC_TABLE_SIZE
        )
        maxHeaderListSize = 65536
    }

    init(maxDynamicTableSize: Int64, maxHeaderListSize: Int64) {
        if (maxHeaderListSize <= 0) {
            nativeH2HpackFailure("native H2 HPACK header-list limit must be positive")
        }
        dynamicTable = NativeH2HpackDynamicTable(maxDynamicTableSize)
        this.maxHeaderListSize = maxHeaderListSize
    }

    func dynamicEntryCount(): Int64 {
        dynamicTable.entries.size
    }

    func decodeRequestHead(payload: Array<UInt8>): NativeH2DecodedRequestHead {
        let fields = nativeH2HpackDecodeFields(payload, dynamicTable, maxHeaderListSize)
        var method = ""
        var scheme = ""
        var authority = ""
        var path = ""
        let headers = ArrayList<NativeH2Header>()
        var regularHeaderSeen = false
        var contentLength: ?Int64 = None
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
                nativeH2ValidateRequestHeader(field.name, field.value)
                if (field.name == "content-length") {
                    let parsed = nativeH2ParseContentLength(field.value)
                    if (let Some(previous) <- contentLength) {
                        if (previous != parsed) {
                            nativeH2RequestFailure(
                                "native H2 request has conflicting content-length values"
                            )
                        }
                    }
                    contentLength = Some(parsed)
                }
                headers.add(NativeH2Header(field.name, field.value))
            }
        }
        if (method.size == 0 || scheme.size == 0 || authority.size == 0 || path.size == 0) {
            nativeH2ProtocolFailure(
                "native H2 request requires :method, :scheme, :authority, and :path"
            )
        }
        NativeH2DecodedRequestHead(
            method, scheme, authority, path,
            headers: headers.toArray(),
            contentLength: contentLength
        )
    }

    func decodeRequestTrailers(payload: Array<UInt8>): Array<NativeH2Header> {
        let fields = nativeH2HpackDecodeFields(payload, dynamicTable, maxHeaderListSize)
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

    func decodeResponseHead(payload: Array<UInt8>): NativeH2DecodedResponseHead {
        let fields = nativeH2HpackDecodeFields(payload, dynamicTable, maxHeaderListSize)
        var statusText = ""
        var regularHeaderSeen = false
        let headers = ArrayList<NativeH2Header>()
        for (field in fields) {
            if (field.name.startsWith(":")) {
                if (regularHeaderSeen) {
                    nativeH2HpackFailure(
                        "native H2 response pseudo-header appears after a regular header"
                    )
                }
                if (field.name != ":status") {
                    nativeH2HpackFailure(
                        "native H2 response uses unsupported pseudo-header ${field.name}"
                    )
                }
                if (statusText.size > 0) {
                    nativeH2HpackDuplicatePseudo(field.name)
                }
                statusText = field.value
            } else {
                regularHeaderSeen = true
                headers.add(NativeH2Header(field.name, field.value))
            }
        }
        NativeH2DecodedResponseHead(
            nativeH2ParseResponseStatus(statusText), headers.toArray()
        )
    }

    func decodeResponseTrailers(payload: Array<UInt8>): Array<NativeH2Header> {
        let fields = nativeH2HpackDecodeFields(payload, dynamicTable, maxHeaderListSize)
        let trailers = ArrayList<NativeH2Header>()
        for (field in fields) {
            if (field.name.startsWith(":")) {
                nativeH2HpackFailure(
                    "native H2 response trailers must not contain pseudo-headers"
                )
            }
            trailers.add(NativeH2Header(field.name, field.value))
        }
        trailers.toArray()
    }
}

func nativeH2ParseResponseStatus(value: String): UInt16 {
    let digits = value.toRuneArray()
    if (digits.size != 3) {
        nativeH2HpackFailure("native H2 response :status must contain three digits")
    }
    var parsed: UInt16 = 0
    for (rune in digits) {
        if (rune < r'0' || rune > r'9') {
            nativeH2HpackFailure("native H2 response :status must contain three digits")
        }
        parsed = parsed * 10 + UInt16(UInt32(rune) - UInt32(r'0'))
    }
    parsed
}

func nativeH2ValidateRequestHeader(name: String, value: String): Unit {
    for (rune in name.toRuneArray()) {
        if (rune >= r'A' && rune <= r'Z') {
            nativeH2RequestFailure("native H2 request header name must be lowercase")
        }
    }
    if (name == "connection" || name == "proxy-connection" ||
        name == "keep-alive" || name == "transfer-encoding" ||
        name == "upgrade") {
        nativeH2RequestFailure(
            "native H2 request contains a connection-specific header"
        )
    }
    if (name == "te" && value.trimAscii().toAsciiLower() != "trailers") {
        nativeH2RequestFailure("native H2 TE request header must contain trailers")
    }
}

func nativeH2ParseContentLength(value: String): Int64 {
    let digits = value.trimAscii().toRuneArray()
    if (digits.size == 0) {
        nativeH2RequestFailure("native H2 content-length must contain digits")
    }
    var parsed: Int64 = 0
    for (rune in digits) {
        if (rune < r'0' || rune > r'9') {
            nativeH2RequestFailure("native H2 content-length must contain digits")
        }
        let digit = Int64(UInt32(rune)) - Int64(UInt32(r'0'))
        if (parsed > (9223372036854775807 - digit) / 10) {
            nativeH2RequestFailure("native H2 content-length exceeds Int64 range")
        }
        parsed = parsed * 10 + digit
    }
    parsed
}

func nativeH2DecodeRequestHead(payload: Array<UInt8>): NativeH2DecodedRequestHead {
    NativeH2HpackDecoderState().decodeRequestHead(payload)
}

func nativeH2HpackDecodeFields(
    payload: Array<UInt8>,
    dynamicTable: NativeH2HpackDynamicTable,
    maxHeaderListSize: Int64
): Array<NativeH2HpackField> {
    let out = ArrayList<NativeH2HpackField>()
    var cursor: Int64 = 0
    var tableUpdateAllowed = true
    var headerListSize: Int64 = 0
    while (cursor < payload.size) {
        let lead = Int64(payload[cursor])
        if ((lead & 0x80) != 0) {
            let indexed = nativeH2HpackDecodeInteger(payload, cursor, 7)
            if (indexed.value <= 0) {
                nativeH2HpackFailure("native H2 HPACK indexed field requires index >= 1")
            }
            let field = nativeH2HpackFieldByIndex(indexed.value, dynamicTable)
            headerListSize = nativeH2HpackAppendDecodedField(
                out, field, headerListSize, maxHeaderListSize
            )
            cursor = indexed.nextCursor
            tableUpdateAllowed = false
            continue
        }
        if ((lead & 0x40) != 0) {
            let decoded = nativeH2HpackDecodeLiteral(payload, cursor, 6, dynamicTable)
            headerListSize = nativeH2HpackAppendDecodedField(
                out, decoded.field, headerListSize, maxHeaderListSize
            )
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
        headerListSize = nativeH2HpackAppendDecodedField(
            out, decoded.field, headerListSize, maxHeaderListSize
        )
        cursor = decoded.nextCursor
        tableUpdateAllowed = false
    }
    out.toArray()
}

func nativeH2HpackAppendDecodedField(
    out: ArrayList<NativeH2HpackField>,
    field: NativeH2HpackField,
    currentSize: Int64,
    maxHeaderListSize: Int64
): Int64 {
    let fieldSize = field.name.toArray().size + field.value.toArray().size + 32
    if (currentSize > maxHeaderListSize - fieldSize) {
        nativeH2HpackFailure(
            "native H2 HPACK decoded header list exceeds configured limit"
        )
    }
    out.add(field)
    currentSize + fieldSize
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
        nativeH2HpackDecodeHuffman(
            payload, length.nextCursor, length.value, cursor
        )
    } else {
        String.fromUtf8(
            nativeH2Slice(payload, length.nextCursor, length.nextCursor + length.value)
        )
    }
    NativeH2HpackStringResult(text, length.nextCursor + length.value)
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
