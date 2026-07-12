package ignite

import std.collection.ArrayList
import std.fs.exists

public func selectPrecompressedStaticAssetPath(
    acceptEncodingRaw: String,
    rangeHeader: String,
    filePath: String,
    brotliSuffix!: String = ".br",
    zstdSuffix!: String = ".zst"
): ?(String, String) {
    if (rangeHeader.trimAscii().size > 0) {
        return None
    }
    let brQuality = staticAssetEncodingQuality(acceptEncodingRaw, "br")
    let zstdQuality = staticAssetEncodingQuality(acceptEncodingRaw, "zstd")
    let brPath = filePath + brotliSuffix
    let zstdPath = filePath + zstdSuffix
    if (brQuality >= zstdQuality && brQuality > 0 && exists(brPath)) {
        return Some((brPath, "br"))
    }
    if (zstdQuality > 0 && exists(zstdPath)) {
        return Some((zstdPath, "zstd"))
    }
    if (brQuality > 0 && exists(brPath)) {
        return Some((brPath, "br"))
    }
    None
}

func staticAssetEncodingQuality(raw: String, target: String): Int64 {
    var exact: Int64 = -1
    var wildcard: Int64 = -1
    for (part in raw.trimAscii().toAsciiLower().split(",")) {
        let tokens = part.trimAscii().split(";")
        if (tokens.size == 0) {
            continue
        }
        var quality: Int64 = 1000
        var i: Int64 = 1
        while (i < tokens.size) {
            let kv = tokens[i].trimAscii().split("=", 2)
            if (kv.size == 2 && kv[0].trimAscii() == "q") {
                quality = parseStaticAssetQValue(kv[1])
            }
            i += 1
        }
        let name = tokens[0].trimAscii()
        if (name == target) {
            exact = quality
        } else if (name == "*") {
            wildcard = quality
        }
    }
    if (exact >= 0) { exact } else { wildcard }
}

func parseStaticAssetQValue(raw: String): Int64 {
    let parts = raw.trimAscii().split(".", 2)
    if (parts.size == 0 || parts[0].size == 0) {
        return -1
    }
    let whole = parseStaticAssetDigits(parts[0])
    if (whole < 0 || whole > 1) {
        return -1
    }
    var fraction: Int64 = 0
    if (parts.size == 2) {
        var scale: Int64 = 100
        var count: Int64 = 0
        for (ch in parts[1].toRuneArray()) {
            if (count >= 3) { break }
            if (ch < r'0' || ch > r'9') { return -1 }
            fraction += staticAssetDigitValue(ch) * scale
            scale /= 10
            count += 1
        }
    }
    if (whole == 1) {
        if (fraction > 0) { -1 } else { 1000 }
    } else {
        fraction
    }
}

func parseStaticAssetDigits(raw: String): Int64 {
    var out: Int64 = 0
    for (ch in raw.toRuneArray()) {
        if (ch < r'0' || ch > r'9') { return -1 }
        out = out * 10 + staticAssetDigitValue(ch)
    }
    out
}

func staticAssetDigitValue(ch: Rune): Int64 {
    match (ch) {
        case r'0' => 0
        case r'1' => 1
        case r'2' => 2
        case r'3' => 3
        case r'4' => 4
        case r'5' => 5
        case r'6' => 6
        case r'7' => 7
        case r'8' => 8
        case r'9' => 9
        case _ => -1
    }
}

public func resolveStaticAssetPath(root: String, rawPath: String): ?String {
    let rootPath = root.trimAscii()
    if (rootPath.size == 0) {
        return None
    }
    if (let Some(relativePath) <- normalizeStaticAssetRequestPath(rawPath)) {
        return Some(joinStaticAssetPath(rootPath, relativePath))
    }
    None
}

public func normalizeStaticAssetRequestPath(rawPath: String): ?String {
    let path = rawPath.trimAscii()
    if (path.size == 0 || path == "/") {
        return Some("")
    }

    let segments = ArrayList<String>()
    let chars = path.toRuneArray()
    var current = ""
    var i: Int64 = 0
    while (i < chars.size) {
        let ch = chars[i]
        if (ch == r'/' || ch == r'\\') {
            if (!appendStaticAssetSegment(segments, current)) {
                return None
            }
            current = ""
        } else {
            current += ch.toString()
        }
        i += 1
    }

    if (!appendStaticAssetSegment(segments, current)) {
        return None
    }
    Some(joinStaticAssetSegments(segments))
}

func appendStaticAssetSegment(segments: ArrayList<String>, segment: String): Bool {
    if (segment.size == 0 || segment == ".") {
        return true
    }
    if (segment == "..") {
        return false
    }
    segments.add(segment)
    true
}

func joinStaticAssetSegments(segments: ArrayList<String>): String {
    if (segments.size == 0) {
        return ""
    }
    var out = ""
    var i: Int64 = 0
    while (i < segments.size) {
        if (i > 0) {
            out += "/"
        }
        out += segments[i]
        i += 1
    }
    out
}

func joinStaticAssetPath(root: String, relativePath: String): String {
    if (relativePath.size == 0) {
        return root
    }
    let chars = root.toRuneArray()
    if (chars.size > 0) {
        let tail = chars[chars.size - 1]
        if (tail == r'/' || tail == r'\\') {
            return root + relativePath
        }
    }
    root + "/" + relativePath
}
