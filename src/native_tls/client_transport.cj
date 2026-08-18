package ignite.native_tls

import std.collection.ArrayList
import ignite.transport.{NativeByteTransport, NativeReadTimeoutControl}
import jinguissl.live.{
    ContractHttpClientTlsTrustRequest,
    ContractTlsHttpNegotiationPolicy,
    ContractTls13HttpClientVerifiedSessionRuntime,
    ContractTls13IncrementalHandshakeStatus,
    ContractTlsRecordChannel,
    ContractTlsRecordContentType,
    ContractTlsVersion,
    ContractX509PinPolicy,
    ContractTlsAlertDescription,
    contractTls13BuildHttpClientHelloX25519,
    contractTls13CollectIncrementalHandshakeRecords,
    contractTryTls13OpenHttpClientRuntimeFromWireDerivedServerFlight,
    contractTlsDecodeAlertPayload,
    contractTlsEncodePlaintextRecord
}

let NATIVE_TLS13_MAX_RECORD_PAYLOAD: Int64 = 18432
let NATIVE_TLS13_APPLICATION_FRAGMENT: Int64 = 16384

public class NativeTls13ClientConfig {
    public let trustAnchorsPemBundle: String
    public let intermediatesPemBundle: String
    public let hostname: String
    public let validationTime: String
    public let alpnProtocols: Array<String>
    public let requireTargetHostnameMatch: Bool
    public let allowedLeafDerSha256: Array<Array<Byte>>
    public let allowedLeafSpkiSha256: Array<Array<Byte>>

    public init(
        trustAnchorsPemBundle: String,
        hostname: String,
        intermediatesPemBundle!: String = "",
        validationTime!: String = "",
        alpnProtocols!: Array<String> = ["http/1.1"],
        requireTargetHostnameMatch!: Bool = true,
        allowedLeafDerSha256!: Array<Array<Byte>> = [],
        allowedLeafSpkiSha256!: Array<Array<Byte>> = []
    ) {
        if (trustAnchorsPemBundle.trimAscii().size == 0) {
            throw Exception("native TLS trust anchors must not be empty")
        }
        if (hostname.trimAscii().size == 0) {
            throw Exception("native TLS hostname must not be empty")
        }
        if (alpnProtocols.size == 0) {
            throw Exception("native TLS ALPN preference must not be empty")
        }
        this.trustAnchorsPemBundle = trustAnchorsPemBundle
        this.intermediatesPemBundle = intermediatesPemBundle
        this.hostname = hostname.trimAscii().toAsciiLower()
        this.validationTime = validationTime.trimAscii()
        this.alpnProtocols = alpnProtocols.clone()
        this.requireTargetHostnameMatch = requireTargetHostnameMatch
        this.allowedLeafDerSha256 = nativeTls13ClonePins(allowedLeafDerSha256)
        this.allowedLeafSpkiSha256 = nativeTls13ClonePins(allowedLeafSpkiSha256)
    }
}

public class NativeTls13ClientHandshake {
    public let transport: NativeTls13ClientTransport
    public let negotiatedAlpn: String
    public let runtime: ContractTls13HttpClientVerifiedSessionRuntime

    public init(
        transport: NativeTls13ClientTransport,
        negotiatedAlpn: String,
        runtime: ContractTls13HttpClientVerifiedSessionRuntime
    ) {
        this.transport = transport
        this.negotiatedAlpn = negotiatedAlpn.trimAscii()
        this.runtime = runtime
    }
}

public class NativeTls13ClientTransport <: NativeByteTransport & NativeReadTimeoutControl {
    let raw: NativeByteTransport
    let channel: ContractTlsRecordChannel
    var pendingPlaintext: Array<Byte> = []
    var pendingOffset: Int64 = 0
    var closed: Bool = false

    public init(raw: NativeByteTransport, channel: ContractTlsRecordChannel) {
        this.raw = raw
        this.channel = channel
    }

    public override func read(outBuf: Array<Byte>): Int64 {
        if (closed || outBuf.size == 0) {
            return 0
        }
        while (pendingOffset >= pendingPlaintext.size) {
            let encoded = nativeTls13ReadRecord(raw)
            if (encoded.size == 0) {
                return 0
            }
            let plain = channel.open(encoded)
            if (plain.contentType == ContractTlsRecordContentType.Alert) {
                let alert = contractTlsDecodeAlertPayload(plain.fragment)
                if (alert.description == ContractTlsAlertDescription.AlertCloseNotify) {
                    settlePeerCloseNotify()
                    return 0
                }
                throw Exception("native TLS peer alert: " + alert.description.toString())
            }
            if (plain.contentType != ContractTlsRecordContentType.ApplicationData) {
                throw Exception(
                    "native TLS expected application data, got " + plain.contentType.toString()
                )
            }
            pendingPlaintext = plain.fragment
            pendingOffset = 0
            if (pendingPlaintext.size == 0) {
                continue
            }
        }
        let remaining = pendingPlaintext.size - pendingOffset
        let count = if (remaining < outBuf.size) { remaining } else { outBuf.size }
        var i: Int64 = 0
        while (i < count) {
            outBuf[i] = pendingPlaintext[pendingOffset + i]
            i += 1
        }
        pendingOffset += count
        if (pendingOffset >= pendingPlaintext.size) {
            pendingPlaintext = []
            pendingOffset = 0
        }
        count
    }

    public override func write(data: Array<Byte>): Unit {
        if (closed) {
            throw Exception("native TLS transport is closed")
        }
        if (data.size == 0) {
            return
        }
        let records = channel.sealFragments(
            ContractTlsRecordContentType.ApplicationData,
            data,
            maxFragmentLen: NATIVE_TLS13_APPLICATION_FRAGMENT
        )
        for (record in records) {
            raw.write(record)
        }
    }

    public override func close(): Unit {
        if (closed) {
            return
        }
        closed = true
        try { raw.write(channel.sendCloseNotify()) } catch (_: Exception) {}
        raw.close()
    }

    public override func isClosed(): Bool {
        closed || raw.isClosed()
    }

    public override func currentReadTimeout(): ?Duration {
        match (raw) {
            case control: NativeReadTimeoutControl => control.currentReadTimeout()
            case _ => None
        }
    }

    public override func updateReadTimeout(value: ?Duration): Unit {
        match (raw) {
            case control: NativeReadTimeoutControl => control.updateReadTimeout(value)
            case _ => ()
        }
    }

    func settlePeerCloseNotify(): Unit {
        if (closed) {
            return
        }
        closed = true
        try { raw.write(channel.sendCloseNotify()) } catch (_: Exception) {}
        try { raw.close() } catch (_: Exception) {}
    }
}

public func openNativeTls13ClientTransport(
    raw: NativeByteTransport,
    config: NativeTls13ClientConfig
): NativeTls13ClientHandshake {
    let clientHello = contractTls13BuildHttpClientHelloX25519(
        config.hostname,
        alpnProtocols: config.alpnProtocols
    )
    raw.write(contractTlsEncodePlaintextRecord(
        ContractTlsVersion.Tls12,
        ContractTlsRecordContentType.Handshake,
        clientHello.encodedClientHello
    ))

    let wire = ArrayList<Byte>()
    var recordCount: Int64 = 0
    while (recordCount < 5) {
        let record = nativeTls13ReadRecord(raw)
        if (record.size == 0) {
            throw Exception("native TLS peer closed during server flight")
        }
        nativeTls13Append(wire, record)
        recordCount += 1
    }
    let collected = contractTls13CollectIncrementalHandshakeRecords([], wire.toArray())
    let outcome = contractTryTls13OpenHttpClientRuntimeFromWireDerivedServerFlight(
        clientHello,
        ContractHttpClientTlsTrustRequest(
            config.trustAnchorsPemBundle,
            intermediatesPemBundle: config.intermediatesPemBundle,
            hostname: config.hostname,
            validationTime: config.validationTime,
            pinPolicy: ContractX509PinPolicy(
                allowedLeafDerSha256: config.allowedLeafDerSha256,
                allowedLeafSpkiSha256: config.allowedLeafSpkiSha256
            ),
            policy: ContractTlsHttpNegotiationPolicy(
                requireServerName: true,
                allowedServerNames: [config.hostname],
                alpnPreference: config.alpnProtocols
            )
        ),
        collected
    )
    if (!outcome.ok || outcome.status != ContractTls13IncrementalHandshakeStatus.Completed) {
        throw Exception("native TLS handshake failed: " + outcome.message)
    }
    let result = outcome.result ?? throw Exception("native TLS handshake result is unavailable")
    raw.write(result.clientFinished.encodedRecord)
    let runtime = result.runtime
    let channel = runtime.channelSet.clientChannel
    NativeTls13ClientHandshake(
        NativeTls13ClientTransport(raw, channel),
        runtime.result.selectedAlpn,
        runtime
    )
}

func nativeTls13ReadRecord(raw: NativeByteTransport): Array<Byte> {
    let header = nativeTls13ReadExactlyOrEof(raw, 5)
    if (header.size == 0) {
        return []
    }
    let payloadLength = (Int64(header[3]) << 8) + Int64(header[4])
    if (payloadLength < 0 || payloadLength > NATIVE_TLS13_MAX_RECORD_PAYLOAD) {
        throw Exception("native TLS record payload exceeds bounded limit")
    }
    let payload = nativeTls13ReadExactlyOrEof(raw, payloadLength)
    if (payload.size != payloadLength) {
        throw Exception("native TLS peer closed during record payload")
    }
    let out = ArrayList<Byte>()
    nativeTls13Append(out, header)
    nativeTls13Append(out, payload)
    out.toArray()
}

func nativeTls13ReadExactlyOrEof(raw: NativeByteTransport, length: Int64): Array<Byte> {
    if (length == 0) {
        return []
    }
    let out = Array<Byte>(length, repeat: 0)
    var offset: Int64 = 0
    while (offset < length) {
        let chunk = Array<Byte>(length - offset, repeat: 0)
        let count = raw.read(chunk)
        if (count <= 0) {
            if (offset == 0) {
                return []
            }
            throw Exception("native TLS peer closed during bounded read")
        }
        var i: Int64 = 0
        while (i < count) {
            out[offset + i] = chunk[i]
            i += 1
        }
        offset += count
    }
    out
}

func nativeTls13Append(out: ArrayList<Byte>, bytes: Array<Byte>): Unit {
    for (value in bytes) {
        out.add(value)
    }
}

func nativeTls13ClonePins(input: Array<Array<Byte>>): Array<Array<Byte>> {
    let out = ArrayList<Array<Byte>>()
    for (pin in input) {
        if (pin.size != 32) {
            throw Exception("native TLS SHA-256 pins must be 32 bytes")
        }
        out.add(pin.clone())
    }
    out.toArray()
}
