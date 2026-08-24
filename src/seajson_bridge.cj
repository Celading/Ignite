package ignite

import std.io.{ByteBuffer, OutputStream}
import seajson.JsonWriter as SeaJsonNativeWriter
import stdx.encoding.json.stream.JsonWriter as StdxJsonWriter

/// Ignite-owned JSON backend bridge.
///
/// The default callback path is SeaJson-backed. The typed
/// `JsonSerializable` helpers below remain an explicit stdx compatibility
/// lane until a later reader/typed-contract migration packet.
func writeJsonCallbackThroughSeaJsonBridge(
    out: OutputStream,
    writerFn: (IgniteJsonWriter) -> Unit
): Unit {
    let writer = IgniteJsonWriter(out)
    writerFn(writer)
    writer.finish()
}

func writeJsonSerializableThroughSeaJsonBridge<T>(
    writer: JsonWriter,
    obj: T
): Unit where T <: JsonSerializable {
    obj.toJson(writer)
}

func writeJsonWriterEncodableThroughSeaJsonBridge(
    out: OutputStream,
    obj: JsonWriterEncodable
): Unit {
    let writer = SeaJsonNativeWriter(out: out)
    obj.writeJson(writer)
    writer.finish()
}

func writeSeaJsonCallbackThroughSeaJsonBridge(
    out: OutputStream,
    writerFn: (SeaJsonWriter) -> Unit
): Unit {
    let writer = SeaJsonNativeWriter(out: out)
    writerFn(writer)
    writer.finish()
}

func serializeJsonThroughSeaJsonBridge<T>(obj: T): String where T <: JsonSerializable {
    let buf = ByteBuffer()
    let writer = StdxJsonWriter(buf)
    obj.toJson(writer)
    writer.flush()
    String.fromUtf8(buf.bytes())
}
