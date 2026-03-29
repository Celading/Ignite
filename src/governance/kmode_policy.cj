package ignite.governance

import ignite.Ctx

public enum KModeCapability {
    | Diag
    | Read
    | Write
    | Admin
}

public class KModePolicy {
    public var enabled: Bool = false
    public var legacyOpen: Bool = false
    public var headerName: String = "X-KMode-Key"
    public var headerKey: String = ""
    public var allowIPs: Array<String> = ["127.0.0.1", "::1"]
    public var capabilities: Array<KModeCapability> = [Diag]

    public init(
        enabled!: Bool = false,
        legacyOpen!: Bool = false,
        headerName!: String = "X-KMode-Key",
        headerKey!: String = "",
        allowIPs!: Array<String> = ["127.0.0.1", "::1"],
        capabilities!: Array<KModeCapability> = [Diag]
    ) {
        this.enabled = enabled
        this.legacyOpen = legacyOpen
        this.headerName = headerName
        this.headerKey = headerKey
        this.allowIPs = allowIPs
        this.capabilities = capabilities
    }

    public func authorize(ctx: Ctx): Bool {
        if (!enabled) { return false }
        if (legacyOpen) { return true }
        let headerVal = ctx.header(headerName) ?? ""
        if (headerKey.size == 0 || headerVal.size == 0) { return false }
        if (headerVal != headerKey) { return false }
        ipAllowed(ctx.ip)
    }

    public func hasCapability(cap: KModeCapability): Bool {
        let target = capabilityName(cap)
        for (item in capabilities) {
            if (capabilityName(item) == target) { return true }
        }
        false
    }

    public func capabilitiesString(): String {
        if (capabilities.size == 0) { return "" }
        var out = ""
        var first = true
        for (cap in capabilities) {
            if (!first) { out += "," }
            first = false
            out += capabilityName(cap)
        }
        out
    }

    public func ipAllowed(ip: String): Bool {
        if (allowIPs.size == 0) { return true }
        for (allowed in allowIPs) {
            if (allowed == "*") { return true }
            if (allowed == ip) { return true }
        }
        false
    }
}

public func capabilityName(cap: KModeCapability): String {
    match (cap) {
        case Diag => "diag"
        case Read => "read"
        case Write => "write"
        case Admin => "admin"
    }
}
