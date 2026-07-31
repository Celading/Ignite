package ignite.native_h2

import std.collection.{ArrayList, HashMap}
import std.io.InputStream

/// Response metadata paired with a one-pass Native H2 body stream.
public class NativeH2ClientStreamedResponse {
    public let status: UInt16
    public let headers: Array<NativeH2Header>
    public let informational: Array<NativeH2ClientResponseHead>
    let stream: NativeH2ClientResponseInputStream

    init(
        head: NativeH2ClientResponseHead,
        informational: Array<NativeH2ClientResponseHead>,
        stream: NativeH2ClientResponseInputStream
    ) {
        status = head.status
        headers = nativeH2CloneHeaders(head.headers)
        this.informational = nativeH2CloneResponseHeads(informational)
        this.stream = stream
    }

    public func header(name: String): ?String {
        let normalized = name.trimAscii().toAsciiLower()
        for (header in headers) {
            if (header.name == normalized) {
                return Some(header.value)
            }
        }
        None
    }

    public func bodyStream(): InputStream {
        stream
    }

    public func trailers(): Array<NativeH2Header> {
        stream.trailers()
    }

    public func close(): Unit {
        stream.close()
    }
}

class NativeH2ClientStreamLease {
    let streamId: Int64
    var head: ?NativeH2ClientResponseHead = None
    let informational = ArrayList<NativeH2ClientResponseHead>()
    var trailers = Array<NativeH2Header>()
    let outbound = HashMap<Int64, NativeH2ClientOutboundStream>()
    let orderedStreamIds = ArrayList<Int64>()
    var pendingResponseHead: ?NativeH2PendingResponseHead = None
    var pendingBody = Array<UInt8>()
    var pendingBodyOffset: Int64 = 0
    var pendingBodyEndsStream = false
    var consumedStreamCredit: Int64 = 0
    var consumedConnectionCredit: Int64 = 0
    var remoteEnded = false
    var released = false

    init(streamId: Int64) {
        this.streamId = streamId
        orderedStreamIds.add(streamId)
    }

    func pendingBodySize(): Int64 {
        pendingBody.size - pendingBodyOffset
    }
}

class NativeH2ClientResponseInputStream <: InputStream & Resource {
    let connection: NativeH2ClientConnection
    let lease: NativeH2ClientStreamLease
    var closed = false

    init(connection: NativeH2ClientConnection, lease: NativeH2ClientStreamLease) {
        this.connection = connection
        this.lease = lease
    }

    public override func read(outBuf: Array<Byte>): Int64 {
        if (closed || outBuf.size == 0) {
            return 0
        }
        try {
            while (lease.pendingBodySize() == 0 &&
                (!lease.remoteEnded || lease.outbound.size > 0)) {
                nativeH2ClientAdvanceStreamedResponse(connection, lease)
            }
            if (lease.pendingBodySize() == 0) {
                nativeH2ClientReleaseStreamLease(connection, lease)
                closed = true
                return 0
            }

            let count = min(outBuf.size, lease.pendingBodySize())
            var i: Int64 = 0
            while (i < count) {
                outBuf[i] = lease.pendingBody[lease.pendingBodyOffset + i]
                i += 1
            }
            lease.pendingBodyOffset += count
            lease.consumedStreamCredit += count
            lease.consumedConnectionCredit += count
            if (lease.pendingBodySize() == 0) {
                lease.pendingBody = Array<UInt8>()
                lease.pendingBodyOffset = 0
                if (lease.pendingBodyEndsStream) {
                    lease.remoteEnded = true
                }
                lease.pendingBodyEndsStream = false
            }
            nativeH2ClientRefillStreamedReceiveWindows(connection, lease, false)
            if (lease.remoteEnded && lease.pendingBodySize() == 0 && lease.outbound.size == 0) {
                nativeH2ClientReleaseStreamLease(connection, lease)
                closed = true
            }
            count
        } catch (e: Exception) {
            nativeH2ClientFailStreamLease(connection, lease)
            closed = true
            throw e
        }
    }

    public func close(): Unit {
        if (closed) {
            return
        }
        closed = true
        if (lease.remoteEnded && lease.outbound.size == 0) {
            let discarded = lease.pendingBodySize()
            lease.consumedConnectionCredit += discarded
            lease.pendingBody = Array<UInt8>()
            lease.pendingBodyOffset = 0
            nativeH2ClientReleaseStreamLease(connection, lease)
            return
        }
        nativeH2ClientCancelStreamLease(connection, lease)
    }

    public func isClosed(): Bool {
        closed
    }

    func trailers(): Array<NativeH2Header> {
        nativeH2CloneHeaders(lease.trailers)
    }
}

func nativeH2ClientOpenStreamedResponse(
    connection: NativeH2ClientConnection,
    request: NativeH2ClientRequest
): NativeH2ClientStreamedResponse {
    if (connection.finished || connection.retiring) {
        throw Exception("native H2 client connection is finished")
    }
    if (connection.activeStreamLease.isSome() || connection.activeMultiplexSession) {
        throw Exception("native H2 client connection already has an active response owner")
    }
    if (!connection.initialized) {
        connection.transport.write(NATIVE_H2_PREFACE)
        nativeH2ClientWriteFrame(
            connection.transport,
            NativeH2Frame(UInt8(0x4), UInt8(0), 0, nativeH2ClientSettingsPayload())
        )
        nativeH2ClientCompleteSettingsHandshake(connection.transport, connection.peerSettings)
        connection.initialized = true
    }

    let lease = NativeH2ClientStreamLease(connection.nextStreamId)
    connection.nextStreamId += 2
    connection.activeStreamLease = Some(lease)
    try {
        nativeH2ClientWriteRequestHead(connection.transport, lease.streamId, request)
        if (request.body.size > 0) {
            lease.outbound.add(
                lease.streamId,
                NativeH2ClientOutboundStream(
                    lease.streamId,
                    request.body,
                    connection.peerSettings.initialStreamWindow
                )
            )
        }
        while (lease.head.isNone()) {
            nativeH2ClientAdvanceStreamedResponse(connection, lease)
        }
        let head = lease.head ?? throw Exception("native H2 streamed response head is missing")
        let stream = NativeH2ClientResponseInputStream(connection, lease)
        NativeH2ClientStreamedResponse(head, lease.informational.toArray(), stream)
    } catch (e: Exception) {
        nativeH2ClientFailStreamLease(connection, lease)
        throw e
    }
}

func nativeH2ClientAdvanceStreamedResponse(
    connection: NativeH2ClientConnection,
    lease: NativeH2ClientStreamLease
): Unit {
    connection.connectionSendWindow = nativeH2ClientFlushRequestBodies(
        connection.transport,
        lease.outbound,
        lease.orderedStreamIds,
        connection.connectionSendWindow,
        connection.peerSettings.maxFramePayload
    )
    if (lease.remoteEnded && lease.outbound.size == 0) {
        return
    }

    let frame = nativeH2ClientReadFrame(connection.transport)
    if (let Some(pending) <- lease.pendingResponseHead) {
        if (frame.frameType != UInt8(0x9) || frame.streamId != pending.streamId) {
            nativeH2ClientProtocolFailure(
                pending.streamId,
                NATIVE_H2_ERROR_PROTOCOL,
                "native H2 streamed response requires contiguous CONTINUATION frames"
            )
        }
        pending.append(frame.payload)
        if ((frame.flags & UInt8(0x4)) != UInt8(0)) {
            nativeH2ClientApplyStreamedHeaderBlock(
                lease, pending.endStream, pending.headerBlock(), connection.responseDecoder
            )
            lease.pendingResponseHead = None
        }
        return
    }
    if (frame.frameType == UInt8(0x9)) {
        nativeH2ClientProtocolFailure(
            frame.streamId,
            NATIVE_H2_ERROR_PROTOCOL,
            "native H2 streamed response received orphan CONTINUATION"
        )
    }
    if (frame.frameType == UInt8(0x4)) {
        nativeH2ClientApplySettings(
            connection.transport, frame, connection.peerSettings, lease.outbound
        )
        return
    }
    if (frame.frameType == UInt8(0x8)) {
        let increment = nativeH2DecodeWindowUpdate(frame)
        if (frame.streamId == 0) {
            connection.connectionSendWindow = nativeH2IncreaseFlowWindow(
                connection.connectionSendWindow, increment, "client connection send"
            )
        } else if (frame.streamId == lease.streamId) {
            if (let Some(outbound) <- lease.outbound.get(lease.streamId)) {
                outbound.sendWindow = nativeH2IncreaseFlowWindow(
                    outbound.sendWindow, increment, "client stream send"
                )
            }
        } else {
            nativeH2ClientProtocolFailure(
                frame.streamId,
                NATIVE_H2_ERROR_PROTOCOL,
                "native H2 streamed response WINDOW_UPDATE references another stream"
            )
        }
        return
    }
    if (frame.frameType == UInt8(0x6)) {
        if (frame.streamId != 0 || frame.payload.size != 8) {
            nativeH2ClientProtocolFailure(
                frame.streamId,
                NATIVE_H2_ERROR_FRAME_SIZE,
                "native H2 streamed response received invalid PING"
            )
        }
        if ((frame.flags & UInt8(0x1)) == UInt8(0)) {
            nativeH2ClientWriteFrame(
                connection.transport,
                NativeH2Frame(UInt8(0x6), UInt8(0x1), 0, frame.payload)
            )
        }
        return
    }
    if (frame.frameType == UInt8(0x7)) {
        if (frame.streamId != 0 || frame.payload.size < 8) {
            throw NativeH2ClientException(
                "protocol", 0, NATIVE_H2_ERROR_FRAME_SIZE,
                "native H2 streamed response received malformed GOAWAY"
            )
        }
        throw NativeH2ClientException(
            "goaway",
            nativeH2ClientDecode31Bit(frame.payload, 0),
            nativeH2ClientDecode32Bit(frame.payload, 4),
            "native H2 streamed response received GOAWAY before completion"
        )
    }
    if (frame.frameType == UInt8(0x1)) {
        nativeH2ClientRequireStream(lease, frame)
        if (lease.remoteEnded) {
            nativeH2ClientProtocolFailure(
                frame.streamId,
                NATIVE_H2_ERROR_STREAM_CLOSED,
                "native H2 streamed response received HEADERS after completion"
            )
        }
        let fragment = nativeH2ClientHeaderBlockFragment(frame)
        let endStream = (frame.flags & UInt8(0x1)) != UInt8(0)
        if ((frame.flags & UInt8(0x4)) == UInt8(0)) {
            lease.pendingResponseHead = Some(
                NativeH2PendingResponseHead(frame.streamId, endStream, fragment)
            )
        } else {
            nativeH2ClientApplyStreamedHeaderBlock(
                lease, endStream, fragment, connection.responseDecoder
            )
        }
        return
    }
    if (frame.frameType == UInt8(0x0)) {
        nativeH2ClientRequireStream(lease, frame)
        if (lease.head.isNone() || lease.remoteEnded) {
            nativeH2ClientProtocolFailure(
                frame.streamId,
                NATIVE_H2_ERROR_PROTOCOL,
                "native H2 streamed response received DATA outside an open response"
            )
        }
        if (lease.pendingBodySize() > 0) {
            throw Exception("native H2 streamed response body frame was not consumed")
        }
        lease.pendingBody = frame.payload
        lease.pendingBodyOffset = 0
        lease.pendingBodyEndsStream = (frame.flags & UInt8(0x1)) != UInt8(0)
        if (frame.payload.size == 0 && lease.pendingBodyEndsStream) {
            lease.remoteEnded = true
            lease.pendingBodyEndsStream = false
        }
        return
    }
    if (frame.frameType == UInt8(0x3)) {
        nativeH2ClientRequireStream(lease, frame)
        if (frame.payload.size != 4) {
            throw NativeH2ClientException(
                "protocol", frame.streamId, NATIVE_H2_ERROR_FRAME_SIZE,
                "native H2 streamed response received malformed RST_STREAM"
            )
        }
        throw NativeH2ClientException(
            "reset", frame.streamId, nativeH2ClientDecode32Bit(frame.payload, 0),
            "native H2 streamed response was reset"
        )
    }
    // Unknown extension and irrelevant control frames remain ignorable.
}

func nativeH2ClientApplyStreamedHeaderBlock(
    lease: NativeH2ClientStreamLease,
    endStream: Bool,
    payload: Array<UInt8>,
    decoder: NativeH2HpackDecoderState
): Unit {
    if (lease.head.isNone()) {
        let decoded = decoder.decodeResponseHead(payload)
        if (decoded.status >= 100 && decoded.status < 200) {
            if (decoded.status == 101 || endStream) {
                nativeH2ClientProtocolFailure(
                    lease.streamId,
                    NATIVE_H2_ERROR_PROTOCOL,
                    "native H2 streamed informational response is invalid"
                )
            }
            lease.informational.add(decoded)
            return
        }
        lease.head = Some(decoded)
        lease.remoteEnded = endStream
        return
    }
    if (!endStream) {
        nativeH2ClientProtocolFailure(
            lease.streamId,
            NATIVE_H2_ERROR_PROTOCOL,
            "native H2 streamed response trailers must end the stream"
        )
    }
    lease.trailers = decoder.decodeResponseTrailers(payload)
    lease.remoteEnded = true
}

func nativeH2ClientRequireStream(
    lease: NativeH2ClientStreamLease,
    frame: NativeH2Frame
): Unit {
    if (frame.streamId != lease.streamId) {
        nativeH2ClientProtocolFailure(
            frame.streamId,
            NATIVE_H2_ERROR_PROTOCOL,
            "native H2 streamed response received a frame for another stream"
        )
    }
}

func nativeH2ClientRefillStreamedReceiveWindows(
    connection: NativeH2ClientConnection,
    lease: NativeH2ClientStreamLease,
    forceConnection: Bool
): Unit {
    if (!lease.remoteEnded && lease.consumedStreamCredit >=
        NATIVE_H2_CLIENT_STREAM_REFILL_THRESHOLD) {
        nativeH2ClientWriteFrame(
            connection.transport,
            nativeH2ClientWindowUpdate(lease.streamId, lease.consumedStreamCredit)
        )
        lease.consumedStreamCredit = 0
    }
    if (lease.consumedConnectionCredit >= NATIVE_H2_CLIENT_CONNECTION_REFILL_THRESHOLD ||
        (forceConnection && lease.consumedConnectionCredit > 0)) {
        nativeH2ClientWriteFrame(
            connection.transport,
            nativeH2ClientWindowUpdate(0, lease.consumedConnectionCredit)
        )
        lease.consumedConnectionCredit = 0
    }
}

func nativeH2ClientReleaseStreamLease(
    connection: NativeH2ClientConnection,
    lease: NativeH2ClientStreamLease
): Unit {
    if (lease.released) {
        return
    }
    nativeH2ClientRefillStreamedReceiveWindows(connection, lease, true)
    lease.released = true
    connection.activeStreamLease = None
}

func nativeH2ClientCancelStreamLease(
    connection: NativeH2ClientConnection,
    lease: NativeH2ClientStreamLease
): Unit {
    if (lease.released) {
        return
    }
    try {
        nativeH2ClientWriteFrame(
            connection.transport,
            NativeH2Frame(
                UInt8(0x3), UInt8(0), lease.streamId,
                nativeH2ErrorCodePayload(NATIVE_H2_ERROR_CANCEL)
            )
        )
    } catch (_: Exception) {}
    lease.released = true
    connection.activeStreamLease = None
    // Cancellation retires this Preview connection from reuse, but keeps the
    // caller-owned transport alive long enough for an orderly GOAWAY.
    connection.retiring = true
}

func nativeH2ClientFailStreamLease(
    connection: NativeH2ClientConnection,
    lease: NativeH2ClientStreamLease
): Unit {
    if (lease.released) {
        return
    }
    lease.released = true
    connection.activeStreamLease = None
    connection.finished = true
    try { connection.transport.close() } catch (_: Exception) {}
}
