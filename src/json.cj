package ignite

import std.io.ByteBuffer
import std.io.OutputStream
import seajson.{
    JsonEncodable as SeaJsonEncodable,
    JsonValue as SeaJsonNativeValue,
    JsonWriter as SeaJsonNativeWriter,
    JsonWriterEncodable as SeaJsonWriterEncodable,
    defaultJsonEncoder as seaJsonDefaultJsonEncoder,
    parseJson as seaJsonParseJson,
    jsonField as seaJsonField,
    jsonFieldString as seaJsonFieldString,
    jsonFieldInt as seaJsonFieldInt
}
import stdx.encoding.json.stream.{
    JsonWriter as StdxJsonWriter,
    JsonReader as StdxJsonReader,
    JsonSerializable as StdxJsonSerializable,
    JsonDeserializable as StdxJsonDeserializable
}

/// Ignite-owned fluent writer for the default streaming JSON APIs.
///
/// The compatibility method names preserve Ignite's historical callback shape,
/// while the actual writer and output sink are owned by SeaJson. Typed
/// `JsonSerializable` remains on its explicit legacy bridge until a later
/// migration packet.
public class IgniteJsonWriter {
    let _writer: SeaJsonNativeWriter

    public init(out: OutputStream) {
        _writer = SeaJsonNativeWriter(out: out)
    }

    public func beginObject(): IgniteJsonWriter {
        _writer.beginObject()
        this
    }

    public func startObject(): IgniteJsonWriter {
        beginObject()
    }

    public func endObject(): IgniteJsonWriter {
        _writer.endObject()
        this
    }

    public func beginArray(): IgniteJsonWriter {
        _writer.beginArray()
        this
    }

    public func startArray(): IgniteJsonWriter {
        beginArray()
    }

    public func endArray(): IgniteJsonWriter {
        _writer.endArray()
        this
    }

    public func writeName(key: String): IgniteJsonWriter {
        _writer.name(key)
        this
    }

    public func name(key: String): IgniteJsonWriter {
        writeName(key)
    }

    public func writeValue(value: String): IgniteJsonWriter {
        _writer.value(value)
        this
    }

    public func value(value: String): IgniteJsonWriter {
        writeValue(value)
    }

    public func writeValue(value: Int64): IgniteJsonWriter {
        _writer.value(value)
        this
    }

    public func value(value: Int64): IgniteJsonWriter {
        writeValue(value)
    }

    public func writeValue(value: Int32): IgniteJsonWriter {
        _writer.value(value)
        this
    }

    public func value(value: Int32): IgniteJsonWriter {
        writeValue(value)
    }

    public func writeValue(value: UInt64): IgniteJsonWriter {
        _writer.value(value)
        this
    }

    public func value(value: UInt64): IgniteJsonWriter {
        writeValue(value)
    }

    public func writeValue(value: Float64): IgniteJsonWriter {
        _writer.value(value)
        this
    }

    public func value(value: Float64): IgniteJsonWriter {
        writeValue(value)
    }

    public func writeValue(value: Bool): IgniteJsonWriter {
        _writer.value(value)
        this
    }

    public func value(value: Bool): IgniteJsonWriter {
        writeValue(value)
    }

    public func writeNull(): IgniteJsonWriter {
        _writer.nullValue()
        this
    }

    public func nullValue(): IgniteJsonWriter {
        writeNull()
    }

    public func finish(): Unit {
        _writer.finish()
    }
}

/// Legacy typed-serialization writer retained for `JsonSerializable` source compatibility.
/// New streaming callbacks use `IgniteJsonWriter`.
public type JsonWriter = StdxJsonWriter
/// SeaJson-owned writer surface for new incremental JSON APIs.
public type SeaJsonWriter = SeaJsonNativeWriter
/// SeaJson-backed DOM value used by Ignite's default buffered JSON bind APIs.
public type JsonValue = SeaJsonNativeValue
public type JsonEncodable = SeaJsonEncodable
public type JsonWriterEncodable = SeaJsonWriterEncodable
public type JsonSerializable = StdxJsonSerializable
public type JsonDeserializable<T> = StdxJsonDeserializable<T>
public type JsonReader = StdxJsonReader
public type JsonEncoder = (JsonEncodable) -> String

func defaultJsonEncoder(obj: JsonEncodable): String {
    seaJsonDefaultJsonEncoder(obj)
}

/// Parse one buffered JSON document through SeaJson.
public func parseJsonValue(json: String): JsonValue {
    seaJsonParseJson(json)
}

/// Return an object field without exposing the provider helper namespace.
public func jsonValueField(value: JsonValue, key: String): ?JsonValue {
    seaJsonField(value, key)
}

/// Return a String object field when its JSON type matches.
public func jsonStringField(value: JsonValue, key: String): ?String {
    seaJsonFieldString(value, key)
}

/// Return an Int64 object field when its JSON type is integral.
public func jsonIntField(value: JsonValue, key: String): ?Int64 {
    seaJsonFieldInt(value, key)
}

public func serializeJson<T>(obj: T): String where T <: JsonSerializable {
    serializeJsonThroughSeaJsonBridge<T>(obj)
}

public func deserializeJson<T>(jsonStr: String): T where T <: JsonDeserializable<T> {
    let buf = ByteBuffer(jsonStr.toArray())
    let reader = StdxJsonReader(buf)
    T.fromJson(reader)
}
