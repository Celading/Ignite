package ignite.native_h2

import ignite.{
    App,
    ServerEngine,
    ServerEngineListenOption,
    ServerEngineReadySignal,
    ServerEngineTransportTouchpointOverride,
    ServerTransportTouchpoint,
    SocketServerEngineShellRuntimeControl
}
import std.net.{IPSocketAddress, TcpServerSocket, TcpSocket}

public class NativeH2ServerEngineException <: Exception {
    public init(message: String) {
        super(message)
    }
}

/// Experimental cleartext prior-knowledge HTTP/2 server for App.listen().
public class NativeH2ServerEngine <:
    ServerEngine & ServerEngineTransportTouchpointOverride {
    let control = SocketServerEngineShellRuntimeControl()
    let connectionControl = NativeH2ConnectionControl()

    public override func overrideTransportTouchpoint(
        addr: String,
        port: UInt16,
        tlsEnabled: Bool,
        baseTouchpoint: ServerTransportTouchpoint
    ): ServerTransportTouchpoint {
        let _ = addr
        let _ = port
        ServerTransportTouchpoint(
            baseTouchpoint.candidateOrder,
            baseTouchpoint.blockedCandidates,
            "ignite-native-h2",
            "explicit-native-h2-prior-knowledge-engine",
            "ignite",
            "ignite.native_h2.NativeH2ServerEngine",
            "experimental",
            tlsEnabled,
            if (tlsEnabled) {
                "native-h2-cleartext-engine-rejects-tls"
            } else {
                "explicit-cleartext-prior-knowledge"
            }
        )
    }

    public override func listen(
        option: ServerEngineListenOption,
        app: App,
        onReady: ?((ServerEngineReadySignal) -> Unit)
    ): Unit {
        rejectNativeH2TlsConfiguration(option)
        let listener = TcpServerSocket(
            bindAt: IPSocketAddress.parse("${option.addr}:${option.port}")
        )
        listener.bind()
        control.attachListener(listener)
        connectionControl.reset()
        try {
            if (let Some(cb) <- onReady) {
                cb(ServerEngineReadySignal())
            }
            serveNativeH2AppConnections(
                listener,
                option,
                app,
                control,
                connectionControl
            )
        } finally {
            if (!listener.isClosed()) {
                listener.close()
            }
            control.detachListener()
        }
    }

    public override func shutdown(): Unit {
        let timeout = Duration.second * 5
        connectionControl.requestDrain(timeout: timeout)
        control.requestShutdown()
        if (!connectionControl.awaitDrained(timeout: timeout)) {
            connectionControl.requestClose()
            let _ = connectionControl.awaitDrained(
                timeout: Duration.millisecond * 100
            )
        }
    }
}

/// Installs the experimental Native H2 engine without changing global defaults.
public func useExperimentalNativeH2ServerEngine(app: App): App {
    app.serverEngine(NativeH2ServerEngine())
}

func rejectNativeH2TlsConfiguration(option: ServerEngineListenOption): Unit {
    if (option.tlsCertFile.size > 0 || option.tlsKeyFile.size > 0) {
        throw NativeH2ServerEngineException(
            "Native H2 ServerEngine supports cleartext prior knowledge only; TLS/ALPN is not enabled"
        )
    }
}

func serveNativeH2AppConnections(
    listener: TcpServerSocket,
    option: ServerEngineListenOption,
    app: App,
    control: SocketServerEngineShellRuntimeControl,
    connectionControl: NativeH2ConnectionControl
): Unit {
    while (!control.shutdownRequested()) {
        try {
            let accepted = listener.accept()
            connectionControl.connectionOpened()
            spawn {
                try {
                    serveNativeH2AcceptedAppConnection(
                        accepted,
                        option,
                        app,
                        connectionControl
                    )
                } finally {
                    connectionControl.connectionClosed()
                }
            }
        } catch (e: Exception) {
            if (control.shutdownRequested()) {
                break
            }
            throw e
        }
    }
}

func serveNativeH2AcceptedAppConnection(
    accepted: TcpSocket,
    option: ServerEngineListenOption,
    app: App,
    connectionControl: NativeH2ConnectionControl
): Unit {
    try {
        accepted.readTimeout = Some(option.readTimeout)
        accepted.writeTimeout = Some(option.writeTimeout)
        serveTrackedNativeH2AppConnection(
            accepted,
            app,
            accepted.remoteAddress.toString(),
            connectionControl
        )
    } catch (_: Exception) {
        // A connection failure must not terminate the listener or sibling H2 connections.
    } finally {
        if (!accepted.isClosed()) {
            accepted.close()
        }
    }
}
