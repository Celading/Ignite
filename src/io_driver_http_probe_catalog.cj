package ignite

import ignite.api2

class IoDriverHttpProbeCatalog {
    let _httpResponse: api2.IoDriverProbeReport
    let _httpDownload: api2.IoDriverProbeReport
    let _rangeDownload: api2.IoDriverProbeReport

    init() {
        _httpResponse = buildHttpProbeReport("http-response", false)
        _httpDownload = buildHttpProbeReport("http-download", true)
        _rangeDownload = buildHttpProbeReport("range-download", true)
    }

    func reportFor(transferShape: String, positionedRead: Bool): api2.IoDriverProbeReport {
        if (transferShape == "http-response" && !positionedRead) {
            return _httpResponse
        }
        if (transferShape == "http-download" && positionedRead) {
            return _httpDownload
        }
        if (transferShape == "range-download" && positionedRead) {
            return _rangeDownload
        }
        buildHttpProbeReport(transferShape, positionedRead)
    }

    func initializedReportCount(): Int64 {
        3
    }
}

func buildHttpProbeReport(
    transferShape: String,
    positionedRead: Bool
): api2.IoDriverProbeReport {
    api2.buildIoDriverProbeReport(
        api2.IoDriverPolicyRequest(
            "http",
            "sequential",
            transferShape,
            true,
            positionedRead,
            false,
            false,
            false,
            "",
            false,
            1,
            "ignite-http-runtime"
        )
    )
}
