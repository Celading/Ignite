package ignite.native_h2

import std.sync.{AtomicBool, Mutex}
import std.time.MonoTime

let NATIVE_H2_RESPONSE_HEAD_COMMIT_TIMEOUT = Duration.second * 5

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
            if (MonoTime.now() - startedAt >= NATIVE_H2_RESPONSE_HEAD_COMMIT_TIMEOUT) {
                let message = "native H2 response head commit timed out"
                markFailed(message)
                throw Exception(message)
            }
            sleep(Duration.millisecond)
        }
    }
}
