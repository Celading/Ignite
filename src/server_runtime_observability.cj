package ignite

import std.sync.AtomicInt64

public enum ServerBackendPolicy <: Equatable<ServerBackendPolicy> & ToString {
    | Auto
    | NativeH1
    | Stdx

    public operator func ==(right: ServerBackendPolicy): Bool {
        ordinalValue() == right.ordinalValue()
    }

    public operator func !=(right: ServerBackendPolicy): Bool {
        !(this == right)
    }

    public func ordinalValue(): Int64 {
        match (this) {
            case Auto => 0
            case NativeH1 => 1
            case Stdx => 2
        }
    }

    public func toString(): String {
        match (this) {
            case Auto => "auto"
            case NativeH1 => "native-h1"
            case Stdx => "stdx"
        }
    }
}

public struct ServerRuntimeCounterSnapshot {
    public let acceptedConnections: Int64
    public let activeConnections: Int64
    public let activeKeepAliveConnections: Int64
    public let startedRequests: Int64
    public let inFlightRequests: Int64
    public let completedRequests: Int64
    public let rejectedRequests: Int64
    public let requestQueueDepth: Int64

    public init(
        acceptedConnections!: Int64 = 0,
        activeConnections!: Int64 = 0,
        activeKeepAliveConnections!: Int64 = 0,
        startedRequests!: Int64 = 0,
        inFlightRequests!: Int64 = 0,
        completedRequests!: Int64 = 0,
        rejectedRequests!: Int64 = 0,
        requestQueueDepth!: Int64 = 0
    ) {
        this.acceptedConnections = acceptedConnections
        this.activeConnections = activeConnections
        this.activeKeepAliveConnections = activeKeepAliveConnections
        this.startedRequests = startedRequests
        this.inFlightRequests = inFlightRequests
        this.completedRequests = completedRequests
        this.rejectedRequests = rejectedRequests
        this.requestQueueDepth = requestQueueDepth
    }
}

public interface ServerRuntimeObservabilityProvider {
    func runtimeCounterSnapshot(): ServerRuntimeCounterSnapshot
}

class SocketServerRuntimeCounters {
    let _acceptedConnections = AtomicInt64(0)
    let _activeConnections = AtomicInt64(0)
    let _activeKeepAliveConnections = AtomicInt64(0)
    let _startedRequests = AtomicInt64(0)
    let _inFlightRequests = AtomicInt64(0)
    let _completedRequests = AtomicInt64(0)
    let _rejectedRequests = AtomicInt64(0)

    func connectionAccepted(): Unit {
        let _ = _acceptedConnections.fetchAdd(1)
        let _ = _activeConnections.fetchAdd(1)
    }

    func connectionClosed(): Unit {
        let _ = _activeConnections.fetchAdd(-1)
    }

    func keepAliveWaitStarted(): Unit {
        let _ = _activeKeepAliveConnections.fetchAdd(1)
    }

    func keepAliveWaitFinished(): Unit {
        let _ = _activeKeepAliveConnections.fetchAdd(-1)
    }

    func requestStarted(): Unit {
        let _ = _startedRequests.fetchAdd(1)
        let _ = _inFlightRequests.fetchAdd(1)
    }

    func requestCompleted(): Unit {
        let _ = _completedRequests.fetchAdd(1)
        let _ = _inFlightRequests.fetchAdd(-1)
    }

    func requestRejected(started: Bool): Unit {
        let _ = _rejectedRequests.fetchAdd(1)
        if (started) {
            let _ = _inFlightRequests.fetchAdd(-1)
        }
    }

    func snapshot(): ServerRuntimeCounterSnapshot {
        ServerRuntimeCounterSnapshot(
            acceptedConnections: _acceptedConnections.load(),
            activeConnections: nonNegativeRuntimeCounter(_activeConnections.load()),
            activeKeepAliveConnections:
                nonNegativeRuntimeCounter(_activeKeepAliveConnections.load()),
            startedRequests: _startedRequests.load(),
            inFlightRequests: nonNegativeRuntimeCounter(_inFlightRequests.load()),
            completedRequests: _completedRequests.load(),
            rejectedRequests: _rejectedRequests.load(),
            requestQueueDepth: 0
        )
    }
}

public class ServerRuntimeSnapshot {
    public let requestedPolicy: String
    public let selectedBackend: String
    public let selectedReason: String
    public let fallbackReason: String
    public let metricsAvailable: Bool
    public let metricsScope: String
    public let counters: ServerRuntimeCounterSnapshot

    public init(
        requestedPolicy: String,
        selectedBackend: String,
        selectedReason: String,
        fallbackReason: String,
        metricsAvailable: Bool,
        metricsScope: String,
        counters: ServerRuntimeCounterSnapshot
    ) {
        this.requestedPolicy = requestedPolicy
        this.selectedBackend = selectedBackend
        this.selectedReason = selectedReason
        this.fallbackReason = fallbackReason
        this.metricsAvailable = metricsAvailable
        this.metricsScope = metricsScope
        this.counters = counters
    }

    public func toJson(): String {
        #"{"requestedPolicy":"# + "\"" + serverEscapeJson(requestedPolicy) + "\"" +
        #", "selectedBackend":"# + "\"" + serverEscapeJson(selectedBackend) + "\"" +
        #", "selectedReason":"# + "\"" + serverEscapeJson(selectedReason) + "\"" +
        #", "fallbackReason":"# + "\"" + serverEscapeJson(fallbackReason) + "\"" +
        #", "metricsAvailable":"# + serverBoolToJson(metricsAvailable) +
        #", "metricsScope":"# + "\"" + serverEscapeJson(metricsScope) + "\"" +
        #", "acceptedConnections":"# + counters.acceptedConnections.toString() +
        #", "activeConnections":"# + counters.activeConnections.toString() +
        #", "activeKeepAliveConnections":"# + counters.activeKeepAliveConnections.toString() +
        #", "startedRequests":"# + counters.startedRequests.toString() +
        #", "inFlightRequests":"# + counters.inFlightRequests.toString() +
        #", "completedRequests":"# + counters.completedRequests.toString() +
        #", "rejectedRequests":"# + counters.rejectedRequests.toString() +
        #", "requestQueueDepth":"# + counters.requestQueueDepth.toString() + "}"
    }
}

func nonNegativeRuntimeCounter(value: Int64): Int64 {
    if (value < 0) { 0 } else { value }
}
