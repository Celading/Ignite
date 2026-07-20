package ignite.client

public class NativeTlsPoolProtocolSnapshot {
    public let idleConnections: Int64
    public let openedConnections: Int64
    public let reusedConnections: Int64
    public let returnedConnections: Int64
    public let retiredConnections: Int64
    public let expiredConnections: Int64

    public init(
        idleConnections!: Int64 = 0,
        openedConnections!: Int64 = 0,
        reusedConnections!: Int64 = 0,
        returnedConnections!: Int64 = 0,
        retiredConnections!: Int64 = 0,
        expiredConnections!: Int64 = 0
    ) {
        this.idleConnections = idleConnections
        this.openedConnections = openedConnections
        this.reusedConnections = reusedConnections
        this.returnedConnections = returnedConnections
        this.retiredConnections = retiredConnections
        this.expiredConnections = expiredConnections
    }
}

public class NativeTlsClientRuntimeSnapshot {
    public let maxIdleMs: Int64
    public let h1: NativeTlsPoolProtocolSnapshot
    public let h2: NativeTlsPoolProtocolSnapshot

    public init(
        maxIdleMs: Int64,
        h1: NativeTlsPoolProtocolSnapshot,
        h2: NativeTlsPoolProtocolSnapshot
    ) {
        this.maxIdleMs = maxIdleMs
        this.h1 = h1
        this.h2 = h2
    }

    public func toJson(): String {
        "{\"maxIdleMs\":" + maxIdleMs.toString() +
        ",\"h1\":{\"idleConnections\":" + h1.idleConnections.toString() +
        ",\"openedConnections\":" + h1.openedConnections.toString() +
        ",\"reusedConnections\":" + h1.reusedConnections.toString() +
        ",\"returnedConnections\":" + h1.returnedConnections.toString() +
        ",\"retiredConnections\":" + h1.retiredConnections.toString() +
        ",\"expiredConnections\":" + h1.expiredConnections.toString() + "}" +
        ",\"h2\":{\"idleConnections\":" + h2.idleConnections.toString() +
        ",\"openedConnections\":" + h2.openedConnections.toString() +
        ",\"reusedConnections\":" + h2.reusedConnections.toString() +
        ",\"returnedConnections\":" + h2.returnedConnections.toString() +
        ",\"retiredConnections\":" + h2.retiredConnections.toString() +
        ",\"expiredConnections\":" + h2.expiredConnections.toString() + "}}"
    }
}
