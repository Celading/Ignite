package ignite.tests

import ignite.*

@Test
public class SocketHttp11HeadParseTestSuite {
    @TestCase
    public func testParserReturnsNoneUntilHeadTerminatorArrives(): Unit {
        let partial = "GET /hello HTTP/1.1\r\nHost: example.com\r\n".toArray()
        let parsed = tryParseSocketHttp11RequestHead(partial)
        match (parsed) {
            case Some(_) => @Fail("partial HTTP/1.1 head should require more bytes")
            case None => ()
        }
    }

    @TestCase
    public func testParserDecodesMethodTargetHeadersAndBodyOffset(): Unit {
        let headText =
            "POST /upload?part=1 HTTP/1.1\r\n" +
            "Host: Example.com\r\n" +
            "X-Test: one\r\n" +
            "X-Test: two\r\n" +
            "Content-Length: 4\r\n" +
            "\r\n"
        let wire = (headText + "body").toArray()

        match (tryParseSocketHttp11RequestHead(wire)) {
            case Some(parsed) =>
                @Assert(parsed.method, "POST")
                @Assert(parsed.target, "/upload?part=1")
                @Assert(parsed.version, "HTTP/1.1")
                @Assert(parsed.headers.size, 4)
                @Assert(parsed.header("host") ?? "", "Example.com")
                @Assert(parsed.header("content-length") ?? "", "4")
                @Assert(parsed.headBytes, headText.toArray().size)
                @Assert(parsed.bodyOffset, headText.toArray().size)
                @Assert(parsed.headers[1].name, "x-test")
                @Assert(parsed.headers[1].value, "one")
                @Assert(parsed.headers[2].name, "x-test")
                @Assert(parsed.headers[2].value, "two")
            case None => @Fail("complete HTTP/1.1 head should parse")
        }
    }

    @TestCase
    public func testParserRejectsUnsupportedVersion(): Unit {
        assertSocketHttp11HeadFailure(
            "GET /legacy HTTP/1.0\r\nHost: example.com\r\n\r\n".toArray(),
            SocketHttp11HeadErrorCode.UnsupportedVersion
        )
    }

    @TestCase
    public func testParserRejectsMalformedRequestLineAndHeaderName(): Unit {
        assertSocketHttp11HeadFailure(
            "GET /broken\r\nHost: example.com\r\n\r\n".toArray(),
            SocketHttp11HeadErrorCode.MalformedRequestLine
        )

        assertSocketHttp11HeadFailure(
            "GET /ok HTTP/1.1\r\nBad Header: value\r\n\r\n".toArray(),
            SocketHttp11HeadErrorCode.InvalidHeaderName
        )
    }

    @TestCase
    public func testParserRequiresOneUnambiguousHostAuthority(): Unit {
        assertSocketHttp11HeadFailure(
            "GET /missing HTTP/1.1\r\nX-Test: value\r\n\r\n".toArray(),
            SocketHttp11HeadErrorCode.MalformedHeader
        )
        assertSocketHttp11HeadFailure(
            "GET /empty HTTP/1.1\r\nHost: \r\n\r\n".toArray(),
            SocketHttp11HeadErrorCode.MalformedHeader
        )
        assertSocketHttp11HeadFailure(
            "GET /duplicate HTTP/1.1\r\nHost: first.example\r\nHost: second.example\r\n\r\n".toArray(),
            SocketHttp11HeadErrorCode.MalformedHeader
        )
        assertSocketHttp11HeadFailure(
            "GET /combined HTTP/1.1\r\nHost: first.example, second.example\r\n\r\n".toArray(),
            SocketHttp11HeadErrorCode.MalformedHeader
        )
    }

    @TestCase
    public func testParserRejectsForbiddenHeaderValueControlsButKeepsHorizontalTabWhitespace(): Unit {
        let prefix = "GET /control HTTP/1.1\r\nHost: example.com\r\nX-Test: safe".toArray()
        let suffix = "unsafe\r\n\r\n".toArray()
        let wire = Array<UInt8>(prefix.size + 1 + suffix.size, repeat: 0)
        var cursor: Int64 = 0
        for (byte in prefix) {
            wire[cursor] = byte
            cursor += 1
        }
        wire[cursor] = UInt8(0)
        cursor += 1
        for (byte in suffix) {
            wire[cursor] = byte
            cursor += 1
        }
        assertSocketHttp11HeadFailure(
            wire,
            SocketHttp11HeadErrorCode.MalformedHeader
        )

        match (tryParseSocketHttp11RequestHead(
            "GET /tab HTTP/1.1\r\nHost: example.com\r\nX-Test:\t value \t\r\n\r\n".toArray()
        )) {
            case Some(parsed) => @Assert(parsed.header("x-test") ?? "", "value")
            case None => @Fail("horizontal-tab field whitespace should remain accepted")
        }
    }

    @TestCase
    public func testParserKeepsFullRfcTokenPunctuationCoverage(): Unit {
        let wire =
            "M-SEARCH /token HTTP/1.1\r\n" +
            "Host: example.com\r\n" +
            "X!#$%&'*+-.^_`|~Token: value\r\n" +
            "\r\n"
        match (tryParseSocketHttp11RequestHead(wire.toArray())) {
            case Some(parsed) =>
                @Assert(parsed.method, "M-SEARCH")
                @Assert(parsed.headers[1].name, "x!#$%&'*+-.^_`|~token")
            case None => @Fail("complete token-punctuation request should parse")
        }
    }

    @TestCase
    public func testParserRespectsConfiguredHeaderByteAndCountLimits(): Unit {
        let option = SocketHttp11HeadParseOption(maxHeaderBytes: 24)
        assertSocketHttp11HeadFailure(
            "GET /tiny HTTP/1.1\r\nHost: example.com\r\n\r\n".toArray(),
            SocketHttp11HeadErrorCode.LimitExceeded,
            option: option
        )

        let countOption = SocketHttp11HeadParseOption(maxHeaderCount: 1)
        assertSocketHttp11HeadFailure(
            "GET /ok HTTP/1.1\r\nHost: example.com\r\nX-Test: value\r\n\r\n".toArray(),
            SocketHttp11HeadErrorCode.LimitExceeded,
            option: countOption
        )
    }
}

func assertSocketHttp11HeadFailure(
    bytes: Array<UInt8>,
    expectedCode: SocketHttp11HeadErrorCode,
    option!: SocketHttp11HeadParseOption = SocketHttp11HeadParseOption()
): Unit {
    try {
        let _ = tryParseSocketHttp11RequestHead(bytes, option: option)
        @Fail("socket HTTP/1.1 head parse should have failed")
    } catch (e: SocketHttp11HeadException) {
        @Assert(e.code, expectedCode)
    }
}
