package ignite

/// Reusable response bytes that are encoded or copied once at construction.
///
/// The mutable backing array is never exposed publicly. Transport carriers may
/// borrow it only for the synchronous response lifetime.
public class PreparedResponseBody {
    let _bytes: Array<UInt8>

    public init(body: String) {
        _bytes = body.toArray()
    }

    public init(body: Array<UInt8>) {
        _bytes = clonePreparedResponseBodyBytes(body)
    }

    public prop size: Int64 {
        get() {
            _bytes.size
        }
    }

    public func copyBytes(): Array<UInt8> {
        clonePreparedResponseBodyBytes(_bytes)
    }

    func borrowBytesForTransport(): Array<UInt8> {
        _bytes
    }
}

interface PreparedResponseBodyCarrier {
    func setPreparedResponseBody(body: PreparedResponseBody): Unit
}

func applyPreparedResponseBody(
    carrier: CurrentRequestCarrier,
    body: PreparedResponseBody
): Unit {
    match (carrier) {
        case prepared: PreparedResponseBodyCarrier =>
            prepared.setPreparedResponseBody(body)
        case _ =>
            carrier.setResponseBytes(body.copyBytes())
    }
}

func clonePreparedResponseBodyBytes(input: Array<UInt8>): Array<UInt8> {
    let out = Array<UInt8>(input.size, repeat: 0)
    input.copyTo(out, 0, 0, input.size)
    out
}
