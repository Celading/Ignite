package ignite.client

import std.random.Random

/// Returns whether a session request can be replayed without re-reading a
/// caller-owned stream.
func nativeH2SessionRetryEligible(
    method: String,
    hasBodyStream: Bool,
    config: ClientRetryConfig
): Bool {
    if (!config.enabled || config.maxAttempts <= 1 || hasBodyStream) {
        return false
    }
    if (!config.idempotentOnly) {
        return true
    }
    let normalized = method.trimAscii().toAsciiUpper()
    normalized == "GET" || normalized == "HEAD" || normalized == "OPTIONS" ||
        normalized == "PUT" || normalized == "DELETE"
}

func nativeH2SessionRetryStatus(
    status: UInt16,
    config: ClientRetryConfig,
    attempt: Int64
): Bool {
    if (!config.enabled || attempt >= config.maxAttempts) {
        return false
    }
    for (code in config.retryStatusCodes) {
        if (code == Int64(status)) {
            return true
        }
    }
    false
}

func nativeH2SessionRetryBackoff(config: ClientRetryConfig, attempt: Int64): Unit {
    if (attempt >= config.maxAttempts) {
        return
    }
    var delay = config.baseDelayMs
    var i: Int64 = 1
    while (i < attempt) {
        if (delay >= config.maxDelayMs) {
            delay = config.maxDelayMs
            break
        }
        let doubled = delay * 2
        delay = if (doubled > config.maxDelayMs) {
            config.maxDelayMs
        } else {
            doubled
        }
        i += 1
    }
    if (config.jitterMs > 0) {
        let range = UInt64(config.jitterMs + 1)
        let jitter = Int64(Random().nextUInt64() % range)
        let sum = delay + jitter
        delay = if (sum > config.maxDelayMs) { config.maxDelayMs } else { sum }
    }
    if (delay > 0) {
        sleep(Duration.millisecond * delay)
    }
}
