package ignite.native_h2

import ignite.{App, ServerNativeTlsH2RuntimeHook, SocketServerEngineShell}

/// Builds the explicit Native TLS H2 runtime hook for SocketServerEngineShell.
public func nativeTlsH2RuntimeHook(): ServerNativeTlsH2RuntimeHook {
    { socket, ready, app, remoteAddress =>
        if (ready.selectedAlpn.toAsciiLower() != "h2") {
            throw Exception("native TLS H2 runtime requires negotiated ALPN h2")
        }
        serveNativeH2AppTransportConnection(
            NativeH2JinguiServerTransport(socket, ready),
            app,
            remoteAddress: remoteAddress
        )
    }
}

/// Installs the preview Native TLS H2 path without changing HTTPS defaults.
public func useExperimentalNativeTlsH2SocketServerEngine(app: App): App {
    app.serverEngine(SocketServerEngineShell(
        selectionLabel: "manual-opt-in-native-tls-h2",
        nativeTlsH2RuntimeHook: Some(nativeTlsH2RuntimeHook())
    ))
}
