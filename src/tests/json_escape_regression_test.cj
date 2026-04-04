package ignite.tests

import ignite.*

@Test
public class JsonEscapeRegressionTestSuite {
    @TestCase
    public func testEscapeJsonTextEscapesAllAsciiControls(): Unit {
        let raw = "\u0000\u0001\b\f\n\r\t\"\\"
        let escaped = escapeJsonText(raw)
        @Assert(escaped, "\\u0000\\u0001\\b\\f\\n\\r\\t\\\"\\\\")
    }
}
