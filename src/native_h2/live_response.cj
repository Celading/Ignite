package ignite.native_h2

import std.sync.{AtomicBool, Mutex}
import std.time.MonoTime

let NATIVE_H2_RESPONSE_COMMIT_TIMEOUT = Duration.second * 5

class NativeH2CommittedResponseHead {
    let status: UInt16
    let headers: Array<NativeH2Header>

    init(status: UInt16, headers: Array<NativeH2Header>) {
        this.status = status
        this.headers = nativeH2CloneHeaders(headers)
    }
}

/// Cross-thread response-head rendezvous between one App handler and the
/// connection coordinator that exclusively owns H2 frame writes.
class NativeH2ResponseHeadCommit {
    let mtx = Mutex()
    let requestedValue = AtomicBool(false)
    let writtenValue = AtomicBool(false)
    let failedValue = AtomicBool(false)
    var statusValue: UInt16 = 200
    var headersValue = Array<NativeH2Header>()
    var failureMessageValue: String = "native H2 response head commit failed"

    func request(status: UInt16, headers: Array<NativeH2Header>): Unit {
        synchronized(mtx) {
            if (!requestedValue.load()) {
                statusValue = status
                headersValue = nativeH2CloneHeaders(headers)
                requestedValue.store(true)
            }
        }
    }

    func pendingHead(): ?NativeH2CommittedResponseHead {
        var result: ?NativeH2CommittedResponseHead = None
        synchronized(mtx) {
            if (requestedValue.load() && !writtenValue.load() && !failedValue.load()) {
                result = Some(NativeH2CommittedResponseHead(statusValue, headersValue))
            }
        }
        result
    }

    func requested(): Bool {
        requestedValue.load()
    }

    func written(): Bool {
        writtenValue.load()
    }

    func markWritten(): Unit {
        writtenValue.store(true)
    }

    func markFailed(message: String): Unit {
        synchronized(mtx) {
            if (!writtenValue.load()) {
                failureMessageValue = message
                failedValue.store(true)
            }
        }
    }

    func awaitWritten(): Unit {
        let startedAt = MonoTime.now()
        while (!writtenValue.load()) {
            if (failedValue.load()) {
                var message = "native H2 response head commit failed"
                synchronized(mtx) { message = failureMessageValue }
                throw Exception(message)
            }
            if (MonoTime.now() - startedAt >= NATIVE_H2_RESPONSE_COMMIT_TIMEOUT) {
                let message = "native H2 response head commit timed out"
                markFailed(message)
                throw Exception(message)
            }
            sleep(Duration.millisecond)
        }
    }
}

/// One immutable handler-owned DATA write whose transport progress is owned by
/// the connection coordinator.
class NativeH2PendingResponseData {
    let bytes: Array<UInt8>
    let writtenValue = AtomicBool(false)
    let failedValue = AtomicBool(false)
    let mtx = Mutex()
    var offset: Int64 = 0
    var failureMessageValue: String = "native H2 response DATA write failed"

    init(bytes: Array<UInt8>) {
        this.bytes = nativeH2Clone(bytes)
    }

    func remaining(): Int64 {
        bytes.size - offset
    }

    func payload(count: Int64): Array<UInt8> {
        nativeH2Slice(bytes, offset, offset + count)
    }

    func advance(count: Int64): Unit {
        offset += count
    }

    func completed(): Bool {
        remaining() == 0
    }

    func written(): Bool {
        writtenValue.load()
    }

    func failed(): Bool {
        failedValue.load()
    }

    func markWritten(): Unit {
        writtenValue.store(true)
    }

    func markFailed(message: String): Unit {
        synchronized(mtx) {
            if (!writtenValue.load()) {
                failureMessageValue = message
                failedValue.store(true)
            }
        }
    }

    func awaitWritten(): Unit {
        let startedAt = MonoTime.now()
        while (!writtenValue.load()) {
            if (failedValue.load()) {
                var message = "native H2 response DATA write failed"
                synchronized(mtx) { message = failureMessageValue }
                throw Exception(message)
            }
            if (MonoTime.now() - startedAt >= NATIVE_H2_RESPONSE_COMMIT_TIMEOUT) {
                let message = "native H2 response DATA write timed out"
                markFailed(message)
                throw Exception(message)
            }
            sleep(Duration.millisecond)
        }
    }
}

/// Cross-thread rendezvous for direct App writer bytes. A writer publishes at
/// most one blocking chunk at a time; the coordinator alone advances it under
/// connection and stream flow control.
class NativeH2ResponseDataCommit {
    let mtx = Mutex()
    let failedValue = AtomicBool(false)
    var pendingValue: ?NativeH2PendingResponseData = None
    var failureMessageValue: String = "native H2 response DATA channel failed"

    func submit(data: Array<UInt8>): Unit {
        if (data.size == 0) {
            return
        }
        let next = NativeH2PendingResponseData(data)
        synchronized(mtx) {
            if (failedValue.load()) {
                throw Exception(failureMessageValue)
            }
            if (let Some(current) <- pendingValue) {
                if (!current.written() && !current.failed()) {
                    throw Exception("native H2 response DATA write is already pending")
                }
            }
            pendingValue = Some(next)
        }
        next.awaitWritten()
    }

    func pendingData(): ?NativeH2PendingResponseData {
        var result: ?NativeH2PendingResponseData = None
        synchronized(mtx) {
            if (let Some(current) <- pendingValue) {
                if (!current.written() && !current.failed()) {
                    result = Some(current)
                }
            }
        }
        result
    }

    func markFailed(message: String): Unit {
        synchronized(mtx) {
            failureMessageValue = message
            failedValue.store(true)
            if (let Some(current) <- pendingValue) {
                current.markFailed(message)
            }
        }
    }
}
