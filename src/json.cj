package ignite

import std.collection.ArrayList
import std.io.ByteBuffer
import stdx.encoding.json.stream.{
    JsonWriter as StdxJsonWriter,
    JsonReader as StdxJsonReader,
    JsonSerializable as StdxJsonSerializable,
    JsonDeserializable as StdxJsonDeserializable
}

public interface JsonEncodable {
    func toJsonString(): String
}

public type JsonEncoder = (JsonEncodable) -> String

func defaultJsonEncoder(obj: JsonEncodable): String {
    obj.toJsonString()
}

public func serializeJson<T>(obj: T): String where T <: StdxJsonSerializable {
    let buf = ByteBuffer()
    let writer = StdxJsonWriter(buf)
    obj.toJson(writer)
    writer.flush()
    String.fromUtf8(buf.bytes())
}

public func deserializeJson<T>(jsonStr: String): T where T <: StdxJsonDeserializable<T> {
    let buf = ByteBuffer(jsonStr.toArray())
    let reader = StdxJsonReader(buf)
    T.fromJson(reader)
}
