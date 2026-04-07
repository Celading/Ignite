package ignite.governance

import ignite.client.RestClient

public type KModeFailoverProbeHook = (Int64, String) -> ?String
public type KModeFailoverWaitHook = (Int64) -> Unit

public enum KModeFailoverDecision <: Equatable<KModeFailoverDecision> & ToString {
    | Continue
    | Restart
    | Terminate

    public operator func ==(right: KModeFailoverDecision): Bool {
        ordinalValue() == right.ordinalValue()
    }

    public operator func !=(right: KModeFailoverDecision): Bool {
        !(this == right)
    }

    public func ordinalValue(): Int64 {
        match (this) {
            case Continue => 0
            case Restart => 1
            case Terminate => 2
        }
    }

    public func toString(): String {
        match (this) {
            case Continue => "continue"
            case Restart => "restart"
            case Terminate => "terminate"
        }
    }
}

public class KModeFailoverOption {
    public var enabled: Bool = false
    public var probeUrl: String = "http://localhost:8828"
    public var probeMethod: String = "POST"
    public var probePayload: String = ""
    public var probeHeaderName: String = "X-Ignite-KMode"
    public var probeHeaderValue: String = "emergency"
    public var expectedResponse: String = "RESTART"
    public var probeTimeoutSec: Int64 = 3
    public var maxAttempts: Int64 = 3
    public var intervalMs: Int64 = 1000
    public var restartOnMatch: Bool = true
    public var terminateOnMiss: Bool = true
    public var probeHook: ?KModeFailoverProbeHook = None
    public var waitHook: ?KModeFailoverWaitHook = None

    public init(
        enabled!: Bool = false,
        probeUrl!: String = "http://localhost:8828",
        probeMethod!: String = "POST",
        probePayload!: String = "",
        probeHeaderName!: String = "X-Ignite-KMode",
        probeHeaderValue!: String = "emergency",
        expectedResponse!: String = "RESTART",
        probeTimeoutSec!: Int64 = 3,
        maxAttempts!: Int64 = 3,
        intervalMs!: Int64 = 1000,
        restartOnMatch!: Bool = true,
        terminateOnMiss!: Bool = true,
        probeHook!: ?KModeFailoverProbeHook = None,
        waitHook!: ?KModeFailoverWaitHook = None
    ) {
        this.enabled = enabled
        this.probeUrl = probeUrl
        this.probeMethod = normalizeMethod(probeMethod)
        this.probePayload = probePayload
        this.probeHeaderName = probeHeaderName
        this.probeHeaderValue = probeHeaderValue
        this.expectedResponse = expectedResponse.trimAscii()
        this.probeTimeoutSec = if (probeTimeoutSec > 0) { probeTimeoutSec } else { 1 }
        this.maxAttempts = if (maxAttempts > 0) { maxAttempts } else { 1 }
        this.intervalMs = if (intervalMs >= 0) { intervalMs } else { 0 }
        this.restartOnMatch = restartOnMatch
        this.terminateOnMiss = terminateOnMiss
        this.probeHook = probeHook
        this.waitHook = waitHook
    }
}

public class KModeFailoverResult {
    public let decision: KModeFailoverDecision
    public let attempts: Int64
    public let matched: Bool
    public let lastStatus: Int64
    public let lastResponse: String
    public let reason: String

    public init(
        decision: KModeFailoverDecision,
        attempts: Int64,
        matched: Bool,
        lastStatus: Int64,
        lastResponse: String,
        reason: String
    ) {
        this.decision = decision
        this.attempts = attempts
        this.matched = matched
        this.lastStatus = lastStatus
        this.lastResponse = lastResponse
        this.reason = reason
    }
}

public func runKModeFailover(option: KModeFailoverOption, reason: String): KModeFailoverResult {
    if (!option.enabled) {
        return KModeFailoverResult(
            Continue,
            0,
            false,
            -1,
            "",
            reason
        )
    }

    var attempt: Int64 = 1
    var lastStatus: Int64 = -1
    var lastResponse = ""

    while (attempt <= option.maxAttempts) {
        let probe = executeProbe(option, attempt, reason)
        if (let Some((status, response)) <- probe) {
            lastStatus = status
            lastResponse = response
            if (status >= 200 && status < 300 && response.trimAscii() == option.expectedResponse) {
                let decision = if (option.restartOnMatch) { Restart } else { Continue }
                return KModeFailoverResult(
                    decision,
                    attempt,
                    true,
                    lastStatus,
                    lastResponse,
                    reason
                )
            }
        } else {
            lastStatus = -1
        }

        if (attempt < option.maxAttempts && option.intervalMs > 0) {
            waitForFailoverInterval(option, option.intervalMs)
        }
        attempt += 1
    }

    let finalDecision = if (option.terminateOnMiss) { Terminate } else { Continue }
    KModeFailoverResult(
        finalDecision,
        option.maxAttempts,
        false,
        lastStatus,
        lastResponse,
        reason
    )
}

func executeProbe(option: KModeFailoverOption, attempt: Int64, reason: String): ?(Int64, String) {
    if (let Some(hook) <- option.probeHook) {
        if (let Some(response) <- hook(attempt, reason)) {
            return Some((200, response))
        }
        return None
    }

    let client = RestClient(
        readTimeout: Duration.second * option.probeTimeoutSec,
        writeTimeout: Duration.second * option.probeTimeoutSec,
        poolSize: 2
    )
    var output: ?(Int64, String) = None
    try {
        let req = client.request()
            .method(option.probeMethod)
            .url(option.probeUrl)
            .header("content-type", "text/plain; charset=utf-8")
            .header("x-ignite-kmode-reason", reason)

        if (option.probeHeaderName.size > 0) {
            req.header(option.probeHeaderName, option.probeHeaderValue)
        }

        if (methodSupportsBody(option.probeMethod)) {
            req.body(option.probePayload)
        }

        let resp = req.send()
        output = Some((Int64(resp.status), resp.body()))
    } catch (_: Exception) {
        output = None
    } finally {
        client.close()
    }
    output
}

func methodSupportsBody(method: String): Bool {
    method == "POST" || method == "PUT" || method == "PATCH" || method == "DELETE"
}

func normalizeMethod(raw: String): String {
    let m = raw.trimAscii().toAsciiUpper()
    if (m.size == 0) {
        return "POST"
    }
    m
}

func waitForFailoverInterval(option: KModeFailoverOption, ms: Int64): Unit {
    if (ms <= 0) {
        return
    }
    if (let Some(waitHook) <- option.waitHook) {
        waitHook(ms)
        return
    }
    sleep(Duration.millisecond * ms)
}
