package ignite.client

class TransportErrorEnvelope {
    let family: String
    let phase: String
    let backendId: String
    let providerId: String
    let retryable: Bool
    let connectionConsumed: Bool
    let fallbackSuggested: Bool
    let causeCode: String
    let message: String

    init(
        family: String,
        phase: String,
        backendId: String,
        providerId: String,
        retryable: Bool,
        connectionConsumed: Bool,
        fallbackSuggested: Bool,
        causeCode: String,
        message: String
    ) {
        this.family = family
        this.phase = phase
        this.backendId = backendId
        this.providerId = providerId
        this.retryable = retryable
        this.connectionConsumed = connectionConsumed
        this.fallbackSuggested = fallbackSuggested
        this.causeCode = causeCode
        this.message = message
    }
}

func buildTransportErrorEnvelope(
    origin: Exception,
    phaseHint: String,
    canRetryMethod: Bool,
    selectionDecision!: ?TransportSelectionDecision = None
): TransportErrorEnvelope {
    let family = classifyTransportErrorFamily(origin)
    let phase = classifyTransportErrorPhase(origin, phaseHint)
    let causeCode = classifyTransportErrorCauseCode(origin, family, phase)
    let connectionConsumed = classifyTransportConnectionConsumed(family, phase)
    let fallbackSuggested = classifyTransportFallbackSuggested(origin, family, phase, causeCode)
    let retryable = classifyTransportRetryable(family, phase, canRetryMethod, connectionConsumed)
    let backendId = if (let Some(selection) <- selectionDecision) {
        selection.selectedBackend
    } else {
        "stdx-http-client"
    }
    let providerId = if (let Some(selection) <- selectionDecision) {
        selection.providerId
    } else {
        "-"
    }
    TransportErrorEnvelope(
        family,
        phase,
        backendId,
        providerId,
        retryable,
        connectionConsumed,
        fallbackSuggested,
        causeCode,
        origin.message
    )
}

func formatTransportObservedError(
    envelope: TransportErrorEnvelope,
    durationMs: Int64,
    retryCount: Int64,
    fields: String,
    selectionDecision!: ?TransportSelectionDecision = None,
    fallbackRecord!: ?TransportFallbackDecisionRecord = None
): String {
    let fieldText = if (fields.size == 0) { "-" } else { fields }
    let publicPath = if (let Some(selection) <- selectionDecision) {
        selection.publicPath
    } else {
        "-"
    }
    let riskLevel = if (let Some(selection) <- selectionDecision) {
        selection.riskLevel
    } else {
        "-"
    }
    let tags = if (let Some(selection) <- selectionDecision) {
        selection.observabilityTags
    } else {
        "-"
    }
    var text = "[ignite.client.observe] errorClass=${envelope.family} phase=${envelope.phase} causeCode=${envelope.causeCode} backendId=${envelope.backendId} providerId=${envelope.providerId} publicPath=${publicPath} riskLevel=${riskLevel} transportTags=${tags} retryable=${envelope.retryable} fallbackSuggested=${envelope.fallbackSuggested} connectionConsumed=${envelope.connectionConsumed} retryCount=${retryCount} durationMs=${durationMs} fields=${fieldText}"
    if (let Some(record) <- fallbackRecord) {
        text += " fallbackFrom=${record.fromBackend} fallbackTo=${record.toBackend} fallbackOutcome=${record.finalOutcome} replayRequired=${record.requestReplayRequired}"
    }
    text += "; cause=${envelope.message}"
    text
}

func classifyTransportErrorFamily(origin: Exception): String {
    let msg = origin.message.toAsciiLower()
    let hasCrypto = containsTransportStr(msg, "crypto")
    let hasDecrypt = containsTransportStr(msg, "decrypt")
    let hasEnvelope = containsTransportStr(msg, "envelope")
    if (hasCrypto || hasDecrypt || hasEnvelope) {
        return "CRYPTO"
    }
    if (containsTransportStr(msg, "timeout")) {
        return "TIMEOUT"
    }
    let hasTls = containsTransportStr(msg, "tls")
    let hasSsl = containsTransportStr(msg, "ssl")
    let hasHandshake = containsTransportStr(msg, "handshake")
    let hasX509 = containsTransportStr(msg, "x509")
    let hasCertificate = containsTransportStr(msg, "certificate")
    if (hasTls || hasSsl || hasHandshake || hasX509 || hasCertificate) {
        return "TLS"
    }
    let hasConnection = containsTransportStr(msg, "connection")
    let hasNetwork = containsTransportStr(msg, "network")
    let hasRefused = containsTransportStr(msg, "refused")
    let hasSocket = containsTransportStr(msg, "socket")
    if (hasConnection || hasNetwork || hasRefused || hasSocket) {
        return "NETWORK"
    }
    "UNKNOWN"
}

func classifyTransportErrorPhase(origin: Exception, phaseHint: String): String {
    if (phaseHint.size > 0) {
        return phaseHint
    }
    let msg = origin.message.toAsciiLower()
    if (containsTransportStr(msg, "tls must be configured") || containsTransportStr(msg, "https requests are sent")) {
        return "handshake"
    }
    if (containsTransportStr(msg, "handshake") || containsTransportStr(msg, "ssl")) {
        return "handshake"
    }
    if (containsTransportStr(msg, "certificate") || containsTransportStr(msg, "x509")) {
        return "verify"
    }
    if (containsTransportStr(msg, "read") && containsTransportStr(msg, "timeout")) {
        return "read"
    }
    if (containsTransportStr(msg, "write") && containsTransportStr(msg, "timeout")) {
        return "write"
    }
    if (containsTransportStr(msg, "connect") || containsTransportStr(msg, "refused") || containsTransportStr(msg, "socket")) {
        return "connect"
    }
    if (containsTransportStr(msg, "timeout")) {
        return "transport"
    }
    "unknown"
}

func classifyTransportErrorCauseCode(origin: Exception, family: String, phase: String): String {
    let msg = origin.message.toAsciiLower()
    if (family == "CRYPTO") {
        if (containsTransportStr(msg, "unavailable")) {
            return "crypto_unavailable"
        }
        if (containsTransportStr(msg, "decrypt")) {
            return "decrypt_failed"
        }
        return "crypto_error"
    }
    if (family == "TLS") {
        if (containsTransportStr(msg, "tls must be configured") || containsTransportStr(msg, "https requests are sent")) {
            return "tls_not_configured"
        }
        if (phase == "handshake") {
            return "tls_handshake_error"
        }
        if (phase == "verify" || containsTransportStr(msg, "certificate") || containsTransportStr(msg, "x509")) {
            return "tls_verify_error"
        }
        return "tls_error"
    }
    if (family == "TIMEOUT") {
        if (phase == "connect") {
            return "connect_timeout"
        }
        if (phase == "read") {
            return "read_timeout"
        }
        if (phase == "write") {
            return "write_timeout"
        }
        return "timeout_error"
    }
    if (family == "NETWORK") {
        if (containsTransportStr(msg, "refused")) {
            return "connection_refused"
        }
        return "connect_error"
    }
    "unknown_error"
}

func classifyTransportConnectionConsumed(family: String, phase: String): Bool {
    if (phase == "read" || phase == "write") {
        return true
    }
    if (family == "TIMEOUT" && phase == "transport") {
        return true
    }
    false
}

func classifyTransportFallbackSuggested(
    origin: Exception,
    family: String,
    phase: String,
    causeCode: String
): Bool {
    let msg = origin.message.toAsciiLower()
    if (causeCode == "crypto_unavailable") {
        return true
    }
    if (family == "TLS" && phase == "handshake" && causeCode == "tls_handshake_error") {
        return true
    }
    if (family == "TLS" && phase != "verify" && containsTransportStr(msg, "provider") && containsTransportStr(msg, "unavailable")) {
        return true
    }
    false
}

func classifyTransportRetryable(
    family: String,
    phase: String,
    canRetryMethod: Bool,
    connectionConsumed: Bool
): Bool {
    if (!canRetryMethod) {
        return false
    }
    if (family == "NETWORK" && !connectionConsumed) {
        return true
    }
    if (family == "TIMEOUT" && phase == "connect") {
        return true
    }
    false
}

func containsTransportStr(hay: String, needle: String): Bool {
    let h = hay.toRuneArray()
    let n = needle.toRuneArray()
    if (n.size == 0) { return true }
    if (h.size < n.size) { return false }
    for (i in 0..=(h.size - n.size)) {
        var ok = true
        for (j in 0..n.size) {
            if (h[i + j] != n[j]) { ok = false; break }
        }
        if (ok) { return true }
    }
    false
}
