package ignite

@Test
public class IoDriverHttpProbeCatalogInternalTestSuite {
    @TestCase
    public func testAppCatalogBuildsStableHttpShapesOnceAndReusesThem(): Unit {
        let app = App()
        @Assert(app.ioDriverProbeCatalogInitializedReportCount(), Int64(3))

        for (_ in 0..1000) {
            let response = app.ioDriverProbeReportForHttpStream("http-response", false)
            let download = app.ioDriverProbeReportForHttpStream("http-download", true)
            let range = app.ioDriverProbeReportForHttpStream("range-download", true)
            @Assert(response.decision.selectedDriver, "ignite-stream-seam")
            @Assert(download.decision.selectedDriver, "ignite-stream-seam")
            @Assert(range.decision.selectedDriver, "ignite-stream-seam")
        }

        @Assert(app.ioDriverProbeCatalogInitializedReportCount(), Int64(3))
    }
}
