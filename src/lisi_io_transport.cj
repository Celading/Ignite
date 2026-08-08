package ignite

import std.io.InputStream
import lisi.io.*

public class LisiIoTransportException <: Exception {
    public let failure: IoContractFailure

    public init(failure: IoContractFailure) {
        super("${failure.operation.toString()}: ${failure.message}")
        this.failure = failure
    }
}

public struct LisiIoTransportReceipt {
    public let providerContractVersion: String
    public let adapterVersion: String
    public let selectedProvider: String
    public let selectionClass: String
    public let bytesRead: Int64
    public let bytesWritten: Int64
    public let readTurns: Int64
    public let writeTurns: Int64
    public let noProgressTurns: Int64
    public let maxBufferedBytesObserved: Int64
    public let finalPressure: String
    public let flushState: String
    public let sourceClose: String
    public let sinkClose: String

    public init(
        providerContractVersion: String,
        adapterVersion: String,
        selectedProvider: String,
        selectionClass: String,
        bytesRead: Int64,
        bytesWritten: Int64,
        readTurns: Int64,
        writeTurns: Int64,
        noProgressTurns: Int64,
        maxBufferedBytesObserved: Int64,
        finalPressure: String,
        flushState: String,
        sourceClose: String,
        sinkClose: String
    ) {
        this.providerContractVersion = providerContractVersion
        this.adapterVersion = adapterVersion
        this.selectedProvider = selectedProvider
        this.selectionClass = selectionClass
        this.bytesRead = bytesRead
        this.bytesWritten = bytesWritten
        this.readTurns = readTurns
        this.writeTurns = writeTurns
        this.noProgressTurns = noProgressTurns
        this.maxBufferedBytesObserved = maxBufferedBytesObserved
        this.finalPressure = finalPressure
        this.flushState = flushState
        this.sourceClose = sourceClose
        this.sinkClose = sinkClose
    }
}

/// Adapts an Ignite response `InputStream` to the source-owned lisi.io contract.
/// `InputStream.read(...) == 0` is EOF in this adapter; generic no-progress
/// behavior remains testable through the contract-facing pump overload.
public class IgniteInputStreamIoSource <: IoByteSource {
    let _stream: InputStream
    let _closeGuard = IoCloseGuard(IoCloseSemantics.CallerOwnedIdempotent)

    public init(stream: InputStream) {
        this._stream = stream
    }

    public override func read(
        target: Array<UInt8>,
        offset: Int64,
        length: Int64,
        context: IoOperationContext
    ): IoReadTurn {
        if (let Some(failure) <- ioOperationPreflight(IoOperation.Read, context)) {
            return ioReadFailure(failure)
        }
        if (_closeGuard.isClosed()) {
            return ioReadFailure(
                IoContractFailure(
                    IoFailureKind.Closed,
                    IoOperation.Read,
                    "Ignite input stream adapter is closed",
                    false
                )
            )
        }
        if (!isLisiIoSliceValid(target.size, offset, length)) {
            return ioReadFailure(
                IoContractFailure(
                    IoFailureKind.InvalidInput,
                    IoOperation.Read,
                    "read slice is outside the target buffer",
                    false
                )
            )
        }

        try {
            let readBuffer = Array<Byte>(length, repeat: 0)
            let count = _stream.read(readBuffer)
            if (count <= 0) {
                return ioReadSuccess(IoReadResult(0, IoProgressState.Eof))
            }
            var i: Int64 = 0
            while (i < count) {
                target[offset + i] = UInt8(readBuffer[i])
                i += 1
            }
            ioReadSuccess(IoReadResult(count, IoProgressState.Progress))
        } catch (e: Exception) {
            ioReadFailure(
                mapIoBackendFailure(
                    IoOperation.Read,
                    "BACKEND_FAILURE",
                    "Ignite InputStream read failed: ${e}"
                )
            )
        }
    }

    public override func closeSemantics(): IoCloseSemantics {
        IoCloseSemantics.CallerOwnedIdempotent
    }

    public override func close(): IoCloseTurn {
        ioCloseSuccess(_closeGuard.close())
    }
}

/// Adapts the real Ignite response-writer seam without taking ownership of the
/// underlying socket/session. A writer call is all-progress or a typed failure.
public class IgniteResponseTransportIoSink <: IoByteSink {
    let _writer: ResponseTransportWriter
    let _closeGuard = IoCloseGuard(IoCloseSemantics.CallerOwnedIdempotent)

    public init(writer: ResponseTransportWriter) {
        this._writer = writer
    }

    public override func write(
        source: Array<UInt8>,
        offset: Int64,
        length: Int64,
        context: IoOperationContext
    ): IoWriteTurn {
        if (let Some(failure) <- ioOperationPreflight(IoOperation.Write, context)) {
            return ioWriteFailure(failure)
        }
        if (_closeGuard.isClosed()) {
            return ioWriteFailure(
                IoContractFailure(
                    IoFailureKind.Closed,
                    IoOperation.Write,
                    "Ignite response transport adapter is closed",
                    false
                )
            )
        }
        if (!isLisiIoSliceValid(source.size, offset, length)) {
            return ioWriteFailure(
                IoContractFailure(
                    IoFailureKind.InvalidInput,
                    IoOperation.Write,
                    "write slice is outside the source buffer",
                    false
                )
            )
        }

        let chunk = Array<UInt8>(length, repeat: 0)
        var i: Int64 = 0
        while (i < length) {
            chunk[i] = source[offset + i]
            i += 1
        }
        try {
            _writer.write(chunk)
            ioWriteSuccess(IoWriteResult(length, IoProgressState.Progress))
        } catch (e: Exception) {
            ioWriteFailure(
                mapIoBackendFailure(
                    IoOperation.Write,
                    "BACKEND_FAILURE",
                    "Ignite response transport write failed: ${e}"
                )
            )
        }
    }

    public override func flush(context: IoOperationContext): IoFlushTurn {
        if (let Some(failure) <- ioOperationPreflight(IoOperation.Flush, context)) {
            return ioFlushFailure(failure)
        }
        if (_closeGuard.isClosed()) {
            return ioFlushFailure(
                IoContractFailure(
                    IoFailureKind.Closed,
                    IoOperation.Flush,
                    "Ignite response transport adapter is closed",
                    false
                )
            )
        }
        ioFlushSuccess(IoFlushResult(IoFlushState.Flushed))
    }

    public override func closeSemantics(): IoCloseSemantics {
        IoCloseSemantics.CallerOwnedIdempotent
    }

    public override func close(): IoCloseTurn {
        ioCloseSuccess(_closeGuard.close())
    }
}

/// Pumps one source/sink pair under the accepted lisi.io v1 progress,
/// pressure, cancellation, timeout, flush and close contract.
public func pumpLisiIoTransport(
    source: IoByteSource,
    sink: IoByteSink,
    bufferBytes: Int64,
    maxBufferedBytes: Int64,
    maxConsecutiveNoProgress: Int64,
    context: IoOperationContext
): LisiIoTransportReceipt {
    if (bufferBytes <= 0 || maxBufferedBytes <= 0 || maxConsecutiveNoProgress <= 0) {
        throw LisiIoTransportException(
            IoContractFailure(
                IoFailureKind.InvalidInput,
                IoOperation.Read,
                "buffer and no-progress limits must be positive",
                false
            )
        )
    }

    let selection = selectIoBackend(
        IoPolicy(
            stableDefaultIoProviderId(),
            false,
            [IoOperation.Read, IoOperation.Write, IoOperation.Flush, IoOperation.Close],
            maxBufferedBytes
        )
    )
    if (selection.selectionClass == IoSelectionClass.Unsupported) {
        throw LisiIoTransportException(
            IoContractFailure(
                IoFailureKind.UnsupportedOperation,
                IoOperation.Read,
                "no stable lisi.io provider satisfies the Ignite transport adapter",
                false
            )
        )
    }

    let effectiveBufferBytes = if (bufferBytes < maxBufferedBytes) {
        bufferBytes
    } else {
        maxBufferedBytes
    }
    let highWatermark = if (maxBufferedBytes == 1) {
        1
    } else {
        let candidate = (maxBufferedBytes * 3) / 4
        if (candidate > 0) { candidate } else { 1 }
    }
    let lowWatermark = if (highWatermark > 1) { highWatermark / 2 } else { 0 }
    let bufferPolicy = IoBufferPolicy(maxBufferedBytes, highWatermark, lowWatermark)
    if (let Some(failure) <- validateIoBufferPolicy(bufferPolicy)) {
        throw LisiIoTransportException(failure)
    }

    let readNoProgress = IoNoProgressGuard(IoProgressBudget(maxConsecutiveNoProgress))
    let writeNoProgress = IoNoProgressGuard(IoProgressBudget(maxConsecutiveNoProgress))
    let buffer = Array<UInt8>(effectiveBufferBytes, repeat: 0)
    var bytesRead: Int64 = 0
    var bytesWritten: Int64 = 0
    var readTurns: Int64 = 0
    var writeTurns: Int64 = 0
    var noProgressTurns: Int64 = 0
    var maxBufferedObserved: Int64 = 0
    var pressure = IoPressureState.Open
    var flushState = "NOT_ATTEMPTED"
    var sourceClose = "NOT_ATTEMPTED"
    var sinkClose = "NOT_ATTEMPTED"

    try {
        var done = false
        while (!done) {
            let readTurn = source.read(buffer, 0, effectiveBufferBytes, context)
            readTurns += 1
            if (let Some(failure) <- validateIoReadTurn(readTurn, effectiveBufferBytes)) {
                throw LisiIoTransportException(failure)
            }
            if (let Some(failure) <- readTurn.failure) {
                throw LisiIoTransportException(failure)
            }
            match (readTurn.result) {
                case Some(result) =>
                    if (let Some(failure) <- readNoProgress.observe(IoOperation.Read, result.state)) {
                        throw LisiIoTransportException(failure)
                    }
                    match (result.state) {
                        case IoProgressState.Eof => done = true
                        case IoProgressState.NoProgress => noProgressTurns += 1
                        case IoProgressState.Progress =>
                            if (let Some(failure) <- enforceIoBufferLimit(0, result.bytesRead, bufferPolicy)) {
                                throw LisiIoTransportException(failure)
                            }
                            if (result.bytesRead > maxBufferedObserved) {
                                maxBufferedObserved = result.bytesRead
                            }
                            pressure = nextIoPressureState(pressure, result.bytesRead, bufferPolicy)
                            bytesRead += result.bytesRead
                            var offset: Int64 = 0
                            while (offset < result.bytesRead) {
                                let requested = result.bytesRead - offset
                                let writeTurn = sink.write(buffer, offset, requested, context)
                                writeTurns += 1
                                if (let Some(failure) <- validateIoWriteTurn(writeTurn, requested)) {
                                    throw LisiIoTransportException(failure)
                                }
                                if (let Some(failure) <- writeTurn.failure) {
                                    throw LisiIoTransportException(failure)
                                }
                                match (writeTurn.result) {
                                    case Some(writeResult) =>
                                        if (let Some(failure) <- writeNoProgress.observe(IoOperation.Write, writeResult.state)) {
                                            throw LisiIoTransportException(failure)
                                        }
                                        if (writeResult.state == IoProgressState.NoProgress) {
                                            noProgressTurns += 1
                                        } else {
                                            offset += writeResult.bytesWritten
                                            bytesWritten += writeResult.bytesWritten
                                        }
                                    case None => ()
                                }
                            }
                            pressure = nextIoPressureState(pressure, 0, bufferPolicy)
                    }
                case None => ()
            }
        }

        let flushTurn = sink.flush(context)
        if (let Some(failure) <- validateIoFlushTurn(flushTurn)) {
            throw LisiIoTransportException(failure)
        }
        if (let Some(failure) <- flushTurn.failure) {
            throw LisiIoTransportException(failure)
        }
        match (flushTurn.result) {
            case Some(result) => flushState = result.state.toString()
            case None => ()
        }
    } finally {
        sinkClose = lisiIoCloseTurnLabel(sink.close())
        sourceClose = lisiIoCloseTurnLabel(source.close())
    }

    LisiIoTransportReceipt(
        ioProviderContractVersion(),
        "ignite-lisi-transport-adapter-v1",
        selection.providerId,
        selection.selectionClass.toString(),
        bytesRead,
        bytesWritten,
        readTurns,
        writeTurns,
        noProgressTurns,
        maxBufferedObserved,
        pressure.toString(),
        flushState,
        sourceClose,
        sinkClose
    )
}

/// Real Ignite consumer used by Native H1 and Native TLS H1 stream responses.
public func pumpIgniteInputStreamToResponseTransport(
    stream: InputStream,
    writer: ResponseTransportWriter,
    bufferBytes: Int64,
    maxBufferedBytes: Int64,
    maxConsecutiveNoProgress: Int64,
    context: IoOperationContext
): LisiIoTransportReceipt {
    pumpLisiIoTransport(
        IgniteInputStreamIoSource(stream),
        IgniteResponseTransportIoSink(writer),
        bufferBytes,
        maxBufferedBytes,
        maxConsecutiveNoProgress,
        context
    )
}

func isLisiIoSliceValid(size: Int64, offset: Int64, length: Int64): Bool {
    offset >= 0 && length > 0 && offset <= size && length <= size - offset
}

func lisiIoCloseTurnLabel(turn: IoCloseTurn): String {
    if (let Some(failure) <- turn.failure) {
        return "FAILED:${failure.kind.toString()}"
    }
    match (turn.outcome) {
        case Some(outcome) => outcome.toString()
        case None => "INVALID"
    }
}
