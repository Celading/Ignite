package ignite.tests

import ignite.*
import std.collection.ArrayList

@Test
public class SwaggerSelfCheckTestSuite {
    @TestCase
    public func testInterfaceSpecsCarryRequestAndTestMetadata(): Unit {
        let app = App(config: Config(kmode: true))
        app.post(
            "/echo",
            { ctx => _ = ctx.json(#"{"live":true}"#) },
            option: buildEchoOption()
        )

        let spec = mustFindSpec(app.interfaceSpecs(), "sample.echo")
        @Assert(spec.method, "POST")
        @Assert(spec.path, "/echo")
        @Assert(spec.summary, "Echo request payload")

        match (spec.requestBody) {
            case Some(bodySpec) =>
                @Assert(bodySpec.required, true)
                @Assert(bodySpec.contentType, "application/json")
            case None => throw Exception("expected requestBody metadata")
        }

        match (spec.testOption) {
            case Some(testOpt) =>
                @Assert(testOpt.enabled, true)
                @Assert(testOpt.mock, true)
                @Assert(testOpt.probe, true)
                @Assert(testOpt.versionTag, "0500")
            case None => throw Exception("expected testOption metadata")
        }
    }

    @TestCase
    public func testSwaggerJsonIncludesRequestBodyAndTestExtension(): Unit {
        let app = App(config: Config(enableSwagger: true, kmode: true))
        app.swagger(SwaggerInfo(
            title: "Swagger Self Check",
            description: "verifies 0500 self-check metadata",
            version: "0.5.25"
        ))
        app.post(
            "/echo",
            { ctx => _ = ctx.json(#"{"live":true}"#) },
            option: buildEchoOption()
        )

        let resp = app.handleForTest("GET", "/swagger/json")
        @Assert(resp.status, UInt16(200))
        @Assert(contains(resp.body, #""requestBody""#), true)
        @Assert(contains(resp.body, #""x-ignite-test""#), true)
        @Assert(contains(resp.body, #""versionTag": "0500""#), true)
        @Assert(contains(resp.body, #""example": {"name":"ignite","trace":true}"#), true)
        @Assert(contains(resp.body, #""example": {"ok":true,"name":"ignite"}"#), true)
        @Assert(contains(resp.body, #""/swagger/json""#), false)
    }

    @TestCase
    public func testSelfCheckMockInterceptsRouteInKmode(): Unit {
        let app = App(config: Config(kmode: true))
        app.post(
            "/echo",
            { ctx => _ = ctx.json(#"{"live":true}"#) },
            option: buildEchoOption()
        )

        let resp = app.handleForTest(
            "POST",
            "/echo?__ignite_test=mock",
            body: #"{"name":"ignite"}"#,
            headers: [("content-type", "application/json")]
        )
        @Assert(resp.status, UInt16(200))
        @Assert(contains(resp.body, #""mark": "IGTEST-0500""#), true)
        @Assert(contains(resp.body, #""mode": "mock""#), true)
        @Assert(contains(resp.body, #""expectedContentType": "application/json""#), true)
        @Assert(contains(resp.body, #""live":true"#), false)
        @Assert(resp.header("x-ignite-self-check") ?? "", "IGTEST-0500")
    }

    @TestCase
    public func testSelfCheckStaysOffOutsideKmode(): Unit {
        let app = App(config: Config(kmode: false))
        app.post(
            "/echo",
            { ctx => _ = ctx.json(#"{"live":true}"#) },
            option: buildEchoOption()
        )

        let resp = app.handleForTest(
            "POST",
            "/echo?__ignite_test=mock",
            body: #"{"name":"ignite"}"#,
            headers: [("content-type", "application/json")]
        )
        @Assert(resp.status, UInt16(200))
        @Assert(resp.body, #"{"live":true}"#)
    }

    func buildEchoOption(): RouteOption {
        let option = RouteOption()
        option.withSummary("Echo request payload")
        option.withDescription("Debug-only first-run self-check sample.")
        option.withOperationId("sample.echo")
        option.withTag("debug")
        option.withRequestBody(RequestBodySpec(
            contentType: "application/json",
            schema: #"{"type":"object","properties":{"name":{"type":"string"},"trace":{"type":"boolean"}}}"#,
            example: #"{"name":"ignite","trace":true}"#,
            required: true
        ))
        option.withResponse(ResponseSpec(
            200,
            description: "Echo payload",
            contentType: "application/json",
            schema: #"{"type":"object","properties":{"ok":{"type":"boolean"},"name":{"type":"string"}}}"#,
            example: #"{"ok":true,"name":"ignite"}"#
        ))
        option.withTestOption(TestOption(
            enabled: true,
            mock: true,
            probe: true,
            storage: "memory",
            report: "inline",
            versionTag: "0500"
        ))
        option
    }

    func mustFindSpec(specs: ArrayList<InterfaceSpec>, name: String): InterfaceSpec {
        for (spec in specs) {
            if (spec.name == name) {
                return spec
            }
        }
        throw Exception("missing interface spec: ${name}")
    }

    func contains(text: String, sub: String): Bool {
        let t = text.toRuneArray()
        let p = sub.toRuneArray()
        if (p.size == 0) { return true }
        if (t.size < p.size) { return false }
        var i: Int64 = 0
        while (i <= t.size - p.size) {
            var ok = true
            var j: Int64 = 0
            while (j < p.size) {
                if (t[i + j] != p[j]) {
                    ok = false
                    break
                }
                j += 1
            }
            if (ok) { return true }
            i += 1
        }
        false
    }
}
