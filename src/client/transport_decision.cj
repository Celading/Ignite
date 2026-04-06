package ignite.client

import ignite.api2 as api2
import ignite.security as security

class TransportSelectionDecision {
    let candidateOrder: String
    let selectedBackend: String
    let selectedReason: String
    let fallbackChain: String
    let riskLevel: String
    let publicPath: String
    let providerId: String
    let cryptoProviderId: String
    let observabilityTags: String

    init(
        candidateOrder: String,
        selectedBackend: String,
        selectedReason: String,
        fallbackChain: String,
        riskLevel: String,
        publicPath: String,
        providerId: String,
        cryptoProviderId: String,
        observabilityTags: String
    ) {
        this.candidateOrder = candidateOrder
        this.selectedBackend = selectedBackend
        this.selectedReason = selectedReason
        this.fallbackChain = fallbackChain
        this.riskLevel = riskLevel
        this.publicPath = publicPath
        this.providerId = providerId
        this.cryptoProviderId = cryptoProviderId
        this.observabilityTags = observabilityTags
    }
}

class TransportFallbackDecisionRecord {
    let fromBackend: String
    let toBackend: String
    let triggerFamily: String
    let triggerPhase: String
    let safeToRetry: Bool
    let requestReplayRequired: Bool
    let visibility: String
    let finalOutcome: String

    init(
        fromBackend: String,
        toBackend: String,
        triggerFamily: String,
        triggerPhase: String,
        safeToRetry: Bool,
        requestReplayRequired: Bool,
        visibility: String,
        finalOutcome: String
    ) {
        this.fromBackend = fromBackend
        this.toBackend = toBackend
        this.triggerFamily = triggerFamily
        this.triggerPhase = triggerPhase
        this.safeToRetry = safeToRetry
        this.requestReplayRequired = requestReplayRequired
        this.visibility = visibility
        this.finalOutcome = finalOutcome
    }
}

func buildClientTransportSelectionDecision(
    targetUrl: String,
    x509Verify: ?security.X509VerifyOption,
    requestCryptoConfig!: ?api2.ClientCryptoConfig = None
): TransportSelectionDecision {
    let scheme = detectTransportScheme(targetUrl)
    let providerId = if (scheme == "https") { "tls:stdx-default" } else { "-" }
    let cryptoProviderId = describeCryptoProvider(requestCryptoConfig)
    var tags = "scene=client,scheme=${scheme}"
    if (cryptoProviderId != "-") {
        tags += ",cryptoProvider=${cryptoProviderId}"
    }
    if (let Some(option) <- x509Verify) {
        if (option.enabled) {
            tags += ",x509=enabled"
        }
    }
    TransportSelectionDecision(
        "stdx-http-client",
        "stdx-http-client",
        if (scheme == "https") { "stable-default-https" } else { "stable-default-http" },
        defaultFallbackChainForScheme(scheme),
        if (scheme == "https" || isX509Enabled(x509Verify) || cryptoProviderId != "-") { "medium" } else { "low" },
        "stable-default",
        providerId,
        cryptoProviderId,
        tags
    )
}

func buildSuggestedFallbackDecisionRecord(
    selection: TransportSelectionDecision,
    envelope: TransportErrorEnvelope
): ?TransportFallbackDecisionRecord {
    if (!envelope.fallbackSuggested) {
        return None
    }
    if (envelope.family == "CRYPTO" && envelope.causeCode == "crypto_unavailable") {
        let fromBackend = selection.selectedBackend + "@" + cryptoProviderOrUnknown(selection)
        let fallbackToStdx = selection.cryptoProviderId != "crypto:stdx-fallback"
        return Some(
            TransportFallbackDecisionRecord(
                fromBackend,
                if (fallbackToStdx) {
                    selection.selectedBackend + "@crypto:stdx-fallback"
                } else {
                    selection.selectedBackend + "@crypto:manual-review"
                },
                envelope.family,
                envelope.phase,
                envelope.retryable,
                envelope.connectionConsumed,
                "internal-only",
                if (fallbackToStdx) { "suggested-only" } else { "manual-review" }
            )
        )
    }
    if (selection.fallbackChain.size == 0 || selection.fallbackChain == "-") {
        return None
    }
    let fromBackend = if (selection.providerId == "-") {
        selection.selectedBackend
    } else {
        selection.selectedBackend + "@" + selection.providerId
    }
    Some(
        TransportFallbackDecisionRecord(
            fromBackend,
            selection.fallbackChain,
            envelope.family,
            envelope.phase,
            envelope.retryable,
            envelope.connectionConsumed,
            "internal-only",
            "suggested-only"
        )
    )
}

func detectTransportScheme(targetUrl: String): String {
    let lower = targetUrl.trimAscii().toAsciiLower()
    if (startsWithTransportDecision(lower, "https://")) {
        return "https"
    }
    if (startsWithTransportDecision(lower, "http://")) {
        return "http"
    }
    "unknown"
}

func defaultFallbackChainForScheme(scheme: String): String {
    if (scheme == "https") {
        return "-"
    }
    "-"
}

func isX509Enabled(option: ?security.X509VerifyOption): Bool {
    if (let Some(value) <- option) {
        return value.enabled
    }
    false
}

func describeCryptoProvider(config: ?api2.ClientCryptoConfig): String {
    if (let Some(value) <- config) {
        return "crypto:" + value.providerKind.toString()
    }
    "-"
}

func cryptoProviderOrUnknown(selection: TransportSelectionDecision): String {
    if (selection.cryptoProviderId == "-") {
        return "crypto:unknown"
    }
    selection.cryptoProviderId
}

func startsWithTransportDecision(text: String, prefix: String): Bool {
    let a = text.toRuneArray()
    let b = prefix.toRuneArray()
    if (a.size < b.size) {
        return false
    }
    for (i in 0..b.size) {
        if (a[i] != b[i]) {
            return false
        }
    }
    true
}
