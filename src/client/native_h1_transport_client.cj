package ignite.client

import std.collection.{ArrayList, HashMap}
import std.io.InputStream
import ignite.transport.NativeByteTransport

class NativeH1TransportReader {
    let transport: NativeByteTransport
    let prefetched: Array<UInt8>
    var prefetchedOffset: Int64 = 0

    init(transport: NativeByteTransport, prefetched: Array<UInt8>) {
        this.transport = transport
        this.prefetched = prefetched
    }

    func readAtMost(outBuf: Array<Byte>, limit: Int64): Int64 {
        if (limit <= 0 || outBuf.size == 0) {
            return 0
        }
        let wanted = if (limit < outBuf.size) { limit } else { outBuf.size }
        var copied: Int64 = 0
        while (copied < wanted && prefetchedOffset < prefetched.size) {
            outBuf[copied] = prefetched[prefetchedOffset]
            copied += 1
            prefetchedOffset += 1
        }
        if (copied == wanted) {
            return copied
        }
        let tmp = Array<UInt8>(wanted - copied, repeat: 0)
        let count = transport.read(tmp)
        if (count <= 0) {
            return copied
        }
        var i: Int64 = 0
        while (i < count) {
            outBuf[copied + i] = tmp[i]
            i += 1
        }
        copied + count
    }

    func readByte(): Int64 {
        let one = Array<UInt8>(1, repeat: 0)
        let count = readAtMost(one, 1)
        if (count <= 0) { -1 } else { Int64(one[0]) }
    }

    func readLine(): String {
        let out = ArrayList<UInt8>()
        while (out.size <= 8192) {
            let value = readByte()
            if (value < 0) {
                throw Exception("native H1 response line is incomplete")
            }
            if (value == 13) {
                if (readByte() != 10) {
                    throw Exception("native H1 response line terminator is invalid")
                }
                return String.fromUtf8(out.toArray())
            }
            out.add(UInt8(value))
        }
        throw Exception("native H1 response line exceeds 8192 bytes")
    }
}

class NativeH1TransportResponseInputStream <: InputStream & Resource {
    let reader: NativeH1TransportReader
    let transport: NativeByteTransport
    let mode: String
    let reusable: Bool
    let settleHook: ?((Bool) -> Unit)
    var remaining: Int64
    var chunkRemaining: Int64 = 0
    var closed: Bool = false

    init(
        transport: NativeByteTransport,
        prefetched: Array<UInt8>,
        mode: String,
        remaining: Int64,
        reusable!: Bool = false,
        settleHook!: ?((Bool) -> Unit) = None
    ) {
        this.transport = transport
        this.reader = NativeH1TransportReader(transport, prefetched)
        this.mode = mode
        this.remaining = remaining
        this.reusable = reusable
        this.settleHook = settleHook
    }

    public override func read(outBuf: Array<Byte>): Int64 {
        if (closed || outBuf.size == 0) {
            return 0
        }
        try {
            if (mode == "length") {
                return readLengthBody(outBuf)
            }
            if (mode == "chunked") {
                return readChunkedBody(outBuf)
            }
            readCloseDelimitedBody(outBuf)
        } catch (e: Exception) {
            close()
            throw e
        }
    }

    public func close(): Unit {
        finish(false)
    }

    func finish(completed: Bool): Unit {
        if (closed) {
            return
        }
        closed = true
        if (let Some(settle) <- settleHook) {
            settle(completed && reusable)
        } else {
            try { transport.close() } catch (_: Exception) {}
        }
    }

    public func isClosed(): Bool {
        closed
    }

    func readLengthBody(outBuf: Array<Byte>): Int64 {
        if (remaining <= 0) {
            finish(true)
            return 0
        }
        let count = reader.readAtMost(outBuf, remaining)
        if (count <= 0) {
            throw Exception("native H1 response Content-Length is incomplete")
        }
        remaining -= count
        if (remaining == 0) {
            finish(true)
        }
        count
    }

    func readCloseDelimitedBody(outBuf: Array<Byte>): Int64 {
        let count = reader.readAtMost(outBuf, outBuf.size)
        if (count <= 0) {
            finish(false)
            return 0
        }
        count
    }

    func readChunkedBody(outBuf: Array<Byte>): Int64 {
        var total: Int64 = 0
        while (total < outBuf.size) {
            if (chunkRemaining == 0) {
                let sizeLine = reader.readLine().trimAscii()
                let semicolon = nativeH1IndexOf(sizeLine, ";")
                let sizeText = if (semicolon >= 0) {
                    nativeH1RuneSlice(sizeLine.toRuneArray(), 0, semicolon)
                } else {
                    sizeLine
                }
                chunkRemaining = parseNativeH1Hex(sizeText)
                if (chunkRemaining < 0) {
                    throw Exception("native H1 chunk size is invalid")
                }
                if (chunkRemaining == 0) {
                    consumeTrailers()
                    finish(true)
                    return total
                }
            }
            let wanted = if (chunkRemaining < outBuf.size - total) {
                chunkRemaining
            } else {
                outBuf.size - total
            }
            let tmp = Array<UInt8>(wanted, repeat: 0)
            let count = reader.readAtMost(tmp, wanted)
            if (count <= 0) {
                throw Exception("native H1 chunk payload is incomplete")
            }
            var i: Int64 = 0
            while (i < count) {
                outBuf[total + i] = tmp[i]
                i += 1
            }
            total += count
            chunkRemaining -= count
            if (chunkRemaining == 0 && (reader.readByte() != 13 || reader.readByte() != 10)) {
                throw Exception("native H1 chunk terminator is invalid")
            }
        }
        total
    }

    func consumeTrailers(): Unit {
        var consumedBytes: Int64 = 0
        while (true) {
            let line = reader.readLine()
            consumedBytes = validateNativeH1ResponseTrailerLine(line, consumedBytes)
            if (line.size == 0) {
                return
            }
        }
    }
}

func sendNativeH1RequestOverTransport(
    method: String,
    url: String,
    headers: HashMap<String, String>,
    body: Array<UInt8>,
    bodyStream: ?InputStream,
    bodyStreamLength: Int64,
    transport: NativeByteTransport,
    reusable!: Bool = false,
    settleHook!: ?((Bool) -> Unit) = None
): ClientResponse {
    let target = parseNativeH1Target(url)
    var transferred = false
    try {
        let contentLength = if (bodyStream.isSome()) { bodyStreamLength } else { body.size }
        transport.write(buildNativeH1RequestHead(method, target, headers, contentLength, reusable))
        match (bodyStream) {
            case Some(stream) => writeNativeH1TransportStream(transport, stream, bodyStreamLength)
            case None =>
                if (body.size > 0) {
                    transport.write(body)
                }
        }
        let response = readNativeH1TransportResponse(
            transport,
            method,
            reusable: reusable,
            settleHook: settleHook
        )
        transferred = true
        response
    } finally {
        if (!transferred) {
            try { transport.close() } catch (_: Exception) {}
        }
    }
}

func writeNativeH1TransportStream(
    transport: NativeByteTransport,
    stream: InputStream,
    contentLength: Int64
): Unit {
    var remaining = contentLength
    while (remaining > 0) {
        let wanted = if (remaining < 8192) { remaining } else { 8192 }
        let tmp = Array<UInt8>(wanted, repeat: 0)
        let count = stream.read(tmp)
        if (count <= 0) {
            throw Exception("native H1 request body stream ended before Content-Length")
        }
        if (count > remaining) {
            throw Exception("native H1 request body stream exceeded Content-Length")
        }
        transport.write(nativeH1ByteSlice(tmp, 0, count))
        remaining -= count
    }
}

func readNativeH1TransportResponseHeader(
    transport: NativeByteTransport,
    prefetched!: Array<UInt8> = []
): NativeH1ClientHeaderReadResult {
    let out = ArrayList<UInt8>()
    for (value in prefetched) {
        out.add(value)
    }
    let buf = Array<UInt8>(4096, repeat: 0)
    while (out.size <= 65536) {
        let bytes = out.toArray()
        let headerEnd = nativeH1IndexOfBytes(bytes, "\r\n\r\n".toArray(), 0)
        if (headerEnd >= 0) {
            return NativeH1ClientHeaderReadResult(
                nativeH1ByteSlice(bytes, 0, headerEnd),
                nativeH1ByteSlice(bytes, headerEnd + 4, bytes.size)
            )
        }
        let count = transport.read(buf)
        if (count <= 0) {
            throw Exception("native H1 response closed before headers completed")
        }
        var i: Int64 = 0
        while (i < count) {
            out.add(buf[i])
            i += 1
        }
    }
    throw Exception("native H1 response headers exceed 65536 bytes")
}

func readNativeH1TransportResponse(
    transport: NativeByteTransport,
    method: String,
    reusable!: Bool = false,
    settleHook!: ?((Bool) -> Unit) = None
): ClientResponse {
    var readResult = readNativeH1TransportResponseHeader(transport)
    var parsedHead = parseNativeH1ResponseHead(readResult.headerBytes)
    var interimCount: Int64 = 0
    while (parsedHead.status >= 100 && parsedHead.status < 200 && parsedHead.status != 101) {
        interimCount += 1
        if (interimCount > 8) {
            throw Exception("native H1 response exceeds 8 interim responses")
        }
        readResult = readNativeH1TransportResponseHeader(
            transport,
            prefetched: readResult.prefetchedBody
        )
        parsedHead = parseNativeH1ResponseHead(readResult.headerBytes)
    }
    let statusValue = parsedHead.status
    validateNativeH1RestResponseStatus(statusValue)
    let headerFields = parsedHead.headerFields
    let framing = resolveNativeH1ResponseFraming(headerFields)
    var responseReusable = reusable &&
        !nativeH1HeaderContains(headerFields, "connection", "close")
    if (method.trimAscii().toAsciiUpper() == "HEAD" || statusValue == 204 || statusValue == 304) {
        responseReusable = responseReusable && readResult.prefetchedBody.size == 0
        if (let Some(settle) <- settleHook) {
            settle(responseReusable)
        } else {
            transport.close()
        }
        return ClientResponse(UInt16(statusValue), headerFields, NativeH1ClientBytesInputStream([]))
    }
    let stream = if (framing.mode == "chunked") {
        NativeH1TransportResponseInputStream(
            transport,
            readResult.prefetchedBody,
            "chunked",
            -1,
            reusable: responseReusable,
            settleHook: settleHook
        )
    } else if (framing.mode == "length") {
        NativeH1TransportResponseInputStream(
            transport,
            readResult.prefetchedBody,
            "length",
            framing.contentLength,
            reusable: responseReusable,
            settleHook: settleHook
        )
    } else {
        NativeH1TransportResponseInputStream(
            transport,
            readResult.prefetchedBody,
            "close",
            -1,
            reusable: false,
            settleHook: settleHook
        )
    }
    ClientResponse(
        UInt16(statusValue),
        headerFields,
        stream,
        closeHook: { => stream.close() }
    )
}
