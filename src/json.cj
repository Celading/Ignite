package ignite

import std.io.ByteBuffer
import seajson.{
    JsonEncodable as SeaJsonEncodable,
    JsonWriterEncodable as SeaJsonWriterEncodable,
    defaultJsonEncoder as seaJsonDefaultJsonEncoder
}
import stdx.encoding.json.stream.{
    JsonWriter as StdxJsonWriter,
    JsonReader as StdxJsonReader,
    JsonSerializable as StdxJsonSerializable,
    JsonDeserializable as StdxJsonDeserializable
}

public type JsonWriter = StdxJsonWriter
public type JsonEncodable = SeaJsonEncodable
public type JsonWriterEncodable = SeaJsonWriterEncodable
public type JsonSerializable = StdxJsonSerializable
public type JsonDeserializable<T> = StdxJsonDeserializable<T>
public type JsonEncoder = (JsonEncodable) -> String

func defaultJsonEncoder(obj: JsonEncodable): String {
    seaJsonDefaultJsonEncoder(obj)
}

public func serializeJson<T>(obj: T): String where T <: JsonSerializable {
    serializeJsonThroughSeaJsonBridge<T>(obj)
}

public func deserializeJson<T>(jsonStr: String): T where T <: JsonDeserializable<T> {
    let buf = ByteBuffer(jsonStr.toArray())
    let reader = StdxJsonReader(buf)
    T.fromJson(reader)
}
