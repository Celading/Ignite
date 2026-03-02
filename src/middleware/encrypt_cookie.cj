package ignite.middleware

import ignite.{Handler, Ctx}

public class EncryptCookieConfig {
    public var key: String
    public var exceptNames: Array<String> = []

    public init(key: String, exceptNames!: Array<String> = []) {
        this.key = key
        this.exceptNames = exceptNames
    }
}

public func encryptCookieMiddleware(config: EncryptCookieConfig): Handler {
    let keyBytes = config.key.toArray()
    { ctx: Ctx =>
        ctx.next()
    }
}

public func encryptValue(value: String, key: String): String {
    let vBytes = value.toArray()
    let kBytes = key.toArray()
    let encrypted = xorBytes(vBytes, kBytes)
    base64Encode(encrypted)
}

public func decryptValue(encoded: String, key: String): String {
    let encrypted = base64Decode(encoded)
    let kBytes = key.toArray()
    let decrypted = xorBytes(encrypted, kBytes)
    String.fromUtf8(decrypted)
}

func xorBytes(data: Array<UInt8>, key: Array<UInt8>): Array<UInt8> {
    if (key.size == 0) { return data }
    let result = Array<UInt8>(data.size, repeat: 0)
    for (i in 0..data.size) {
        result[i] = data[i] ^ key[i % key.size]
    }
    result
}
