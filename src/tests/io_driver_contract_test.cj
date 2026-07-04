package ignite.tests

import ignite.api2

@Test
public class IoDriverContractTestSuite {
    @TestCase
    public func testStdFsBlockingSelectedByDefault(): Unit {
        let request = api2.IoDriverPolicyRequest(
            "file-service",
            "sequential",
            "local-copy",
            true,
            true,
            false,
            false,
            false,
            "",
            false,
            4,
            "platform=macos"
        )
        let decision = api2.selectIoDriver(request)

        @Assert(decision.selectedDriver, "std-fs-blocking")
        @Assert(decision.publicPath, "stable-default")
        @Assert(decision.riskLevel, "low")
    }

    @TestCase
    public func testHttpRangeDownloadPrefersIgniteStreamSeam(): Unit {
        let request = api2.IoDriverPolicyRequest(
            "http",
            "sequential",
            "range-download",
            true,
            true,
            false,
            false,
            false,
            "",
            false,
            8,
            "platform=linux"
        )
        let decision = api2.selectIoDriver(request)

        @Assert(decision.selectedDriver, "ignite-stream-seam")
        @Assert(decision.selectedReason, "http_streaming_shape")
        @Assert(decision.publicPath, "stable-stream-seam")
    }

    @TestCase
    public func testProxyDownstreamPrefersIgniteStreamSeam(): Unit {
        let request = api2.IoDriverPolicyRequest(
            "http-proxy",
            "sequential",
            "proxy-downstream",
            true,
            false,
            false,
            false,
            false,
            "",
            false,
            8,
            "platform=linux"
        )
        let decision = api2.selectIoDriver(request)

        @Assert(decision.selectedDriver, "ignite-stream-seam")
        @Assert(decision.selectedReason, "http_streaming_shape")
        @Assert(decision.publicPath, "stable-stream-seam")
    }

    @TestCase
    public func testProxyRequestUploadPrefersIgniteStreamSeam(): Unit {
        let request = api2.IoDriverPolicyRequest(
            "http-proxy",
            "sequential",
            "proxy-request-upload",
            true,
            false,
            false,
            false,
            false,
            "",
            false,
            8,
            "platform=linux"
        )
        let decision = api2.selectIoDriver(request)

        @Assert(decision.selectedDriver, "ignite-stream-seam")
        @Assert(decision.selectedReason, "http_streaming_shape")
        @Assert(decision.publicPath, "stable-stream-seam")
    }

    @TestCase
    public func testProxyLocalErrorResponsePrefersIgniteBufferedResponseSeam(): Unit {
        let request = api2.IoDriverPolicyRequest(
            "http-proxy",
            "sequential",
            "proxy-local-error-response",
            false,
            false,
            false,
            false,
            false,
            "",
            false,
            1,
            "platform=linux"
        )
        let decision = api2.selectIoDriver(request)

        @Assert(decision.selectedDriver, "ignite-buffered-response-seam")
        @Assert(decision.selectedReason, "http_buffered_response_shape")
        @Assert(decision.publicPath, "stable-buffered-response-seam")
    }

    @TestCase
    public func testNativeDriverRequiresExperimentalOptIn(): Unit {
        let request = api2.IoDriverPolicyRequest(
            "file-service",
            "sequential",
            "local-copy",
            true,
            true,
            false,
            true,
            false,
            "linux-native-candidate",
            false,
            4,
            "platform=linux"
        )
        let decision = api2.selectIoDriver(request)

        @Assert(decision.selectedDriver, "")
        @Assert(decision.selectedReason, "unsupported_request")
        @Assert(decision.blockedCandidates.size > 0, true)
        @Assert(decision.blockedCandidates[0], "linux-native-candidate:EXPERIMENTAL_DISABLED")
    }

    @TestCase
    public func testNativeDriverRequiresMatchingPlatformHint(): Unit {
        let request = api2.IoDriverPolicyRequest(
            "file-service",
            "random",
            "local-copy",
            true,
            true,
            true,
            true,
            true,
            "linux-native-candidate",
            true,
            16,
            "platform=windows"
        )
        let decision = api2.selectIoDriver(request)

        @Assert(decision.selectedDriver, "")
        @Assert(decision.blockedCandidates[0], "linux-native-candidate:PLATFORM_SCOPE_UNCONFIRMED")
    }

    @TestCase
    public func testLinuxNativeCanBeSelectedWhenExplicitlyAllowed(): Unit {
        let request = api2.IoDriverPolicyRequest(
            "file-service",
            "random",
            "local-copy",
            true,
            true,
            true,
            true,
            true,
            "linux-native-candidate",
            true,
            16,
            "platform=linux"
        )
        let decision = api2.selectIoDriver(request)

        @Assert(decision.selectedDriver, "linux-native-candidate")
        @Assert(decision.selectedReason, "preferred_driver_hint")
        @Assert(decision.publicPath, "experimental-only")
        @Assert(decision.fallbackChain[0], "std-fs-blocking")
        @Assert(decision.fallbackChain[1], "ignite-stream-seam")
    }

    @TestCase
    public func testProbeReportKeepsZeroCopyUnclaimedForStableStreamPath(): Unit {
        let request = api2.IoDriverPolicyRequest(
            "http",
            "sequential",
            "http-download",
            true,
            true,
            false,
            false,
            false,
            "",
            false,
            8,
            "platform=linux"
        )
        let report = api2.buildIoDriverProbeReport(request)

        @Assert(report.decision.selectedDriver, "ignite-stream-seam")
        @Assert(report.selectedFamily, "ignite")
        @Assert(report.canClaimZeroCopy, false)
        @Assert(report.benchmarkRequired, false)
        @Assert(report.labGate.labFeature, false)
        @Assert(report.runtimeLimitations[0], "IGNITE_STREAM_SEAM_ONLY")
    }

    @TestCase
    public func testProbeReportMarksLinuxNativeAsBenchmarkRequired(): Unit {
        let request = api2.IoDriverPolicyRequest(
            "file-service",
            "random",
            "local-copy",
            true,
            true,
            true,
            true,
            true,
            "linux-native-candidate",
            true,
            16,
            "platform=linux"
        )
        let report = api2.buildIoDriverProbeReport(request)

        @Assert(report.decision.selectedDriver, "linux-native-candidate")
        @Assert(report.selectedFamily, "native-ffi")
        @Assert(report.canClaimZeroCopy, false)
        @Assert(report.benchmarkRequired, true)
        @Assert(report.runtimeLimitations[0], "LAB_NATIVE_BACKEND")
        @Assert(report.runtimeLimitations[1], "BENCHMARK_RECEIPT_REQUIRED")
        @Assert(report.runtimeLimitations[2], "FALLBACK_PROOF_REQUIRED")
        @Assert(report.labGate.labFeature, true)
        @Assert(report.labGate.accepted, true)
        @Assert(report.nativeBridgePlan.bridgeLanguage, "c")
        @Assert(report.nativeBridgePlan.entryPoints[0], "sendfile")
    }

    @TestCase
    public func testProbeReportMarksWindowsNativeAsExperimentalOverlappedCandidate(): Unit {
        let request = api2.IoDriverPolicyRequest(
            "file-service",
            "random",
            "local-copy",
            true,
            true,
            true,
            false,
            true,
            "windows-native-candidate",
            true,
            16,
            "platform=windows"
        )
        let report = api2.buildIoDriverProbeReport(request)

        @Assert(report.decision.selectedDriver, "windows-native-candidate")
        @Assert(report.decision.publicPath, "experimental-only")
        @Assert(report.selectedFamily, "native-ffi")
        @Assert(report.canClaimZeroCopy, false)
        @Assert(report.benchmarkRequired, true)
        @Assert(report.runtimeLimitations[0], "LAB_NATIVE_BACKEND")
        @Assert(report.runtimeLimitations[1], "BENCHMARK_RECEIPT_REQUIRED")
        @Assert(report.runtimeLimitations[2], "FALLBACK_PROOF_REQUIRED")
        @Assert(report.labGate.labFeature, true)
        @Assert(report.labGate.accepted, true)
        @Assert(report.nativeBridgePlan.bridgeLanguage, "c-or-rust")
        @Assert(report.nativeBridgePlan.bridgeFamily, "windows-overlapped-ffi")
        @Assert(report.nativeBridgePlan.entryPoints[0], "CreateFileW")
        @Assert(report.nativeBridgePlan.recommendedFirstStep, "start with overlapped file IO before full IOCP scheduler")
    }

    @TestCase
    public func testProbeReportMarksMacosNativeAsExperimentalSendfileCandidate(): Unit {
        let request = api2.IoDriverPolicyRequest(
            "file-service",
            "random",
            "local-copy",
            true,
            true,
            true,
            true,
            false,
            "macos-native-candidate",
            true,
            16,
            "platform=macos"
        )
        let report = api2.buildIoDriverProbeReport(request)

        @Assert(report.decision.selectedDriver, "macos-native-candidate")
        @Assert(report.decision.publicPath, "experimental-only")
        @Assert(report.selectedFamily, "native-ffi")
        @Assert(report.canClaimZeroCopy, false)
        @Assert(report.benchmarkRequired, true)
        @Assert(report.runtimeLimitations[0], "LAB_NATIVE_BACKEND")
        @Assert(report.runtimeLimitations[1], "BENCHMARK_RECEIPT_REQUIRED")
        @Assert(report.runtimeLimitations[2], "FALLBACK_PROOF_REQUIRED")
        @Assert(report.labGate.labFeature, true)
        @Assert(report.labGate.accepted, true)
        @Assert(report.nativeBridgePlan.bridgeLanguage, "c")
        @Assert(report.nativeBridgePlan.bridgeFamily, "darwin-ffi")
        @Assert(report.nativeBridgePlan.entryPoints[0], "sendfile")
        @Assert(report.nativeBridgePlan.recommendedFirstStep, "start with sendfile-style proof for file-to-socket downloads")
    }

    @TestCase
    public func testBackendReadinessMarksStableStreamPathReadyWithoutNativeReceipts(): Unit {
        let request = api2.IoDriverPolicyRequest(
            "http",
            "sequential",
            "http-download",
            true,
            true,
            false,
            false,
            false,
            "",
            false,
            8,
            "platform=linux"
        )
        let receipt = api2.buildIoDriverBackendReadinessReceipt(
            request,
            api2.IoDriverBackendReadinessEvidence("", "", "", "")
        )

        @Assert(receipt.selectedDriver, "ignite-stream-seam")
        @Assert(receipt.publicPath, "stable-stream-seam")
        @Assert(receipt.ready, true)
        @Assert(receipt.status, "ready-stable-path")
        @Assert(receipt.requiredProofs.size, 0)
        @Assert(receipt.missingProofs.size, 0)
        @Assert(receipt.nonClaims[0], "NO_KERNEL_ZERO_COPY_CLAIM")
    }

    @TestCase
    public func testBackendReadinessBlocksNativeCandidateUntilAllReceiptsExist(): Unit {
        let request = api2.IoDriverPolicyRequest(
            "file-service",
            "random",
            "local-copy",
            true,
            true,
            true,
            true,
            true,
            "linux-native-candidate",
            true,
            16,
            "platform=linux"
        )
        let receipt = api2.buildIoDriverBackendReadinessReceipt(
            request,
            api2.IoDriverBackendReadinessEvidence("", "", "", "")
        )

        @Assert(receipt.selectedDriver, "linux-native-candidate")
        @Assert(receipt.ready, false)
        @Assert(receipt.status, "blocked-lab-proof-missing")
        @Assert(receipt.requiredProofs[0], "BENCHMARK_RECEIPT")
        @Assert(receipt.requiredProofs[1], "FALLBACK_PROOF")
        @Assert(receipt.requiredProofs[2], "PLATFORM_PROBE")
        @Assert(receipt.requiredProofs[3], "LIFETIME_AUDIT")
        @Assert(receipt.missingProofs[0], "BENCHMARK_RECEIPT")
        @Assert(receipt.missingProofs[1], "FALLBACK_PROOF")
        @Assert(receipt.missingProofs[2], "PLATFORM_PROBE")
        @Assert(receipt.missingProofs[3], "LIFETIME_AUDIT")
        @Assert(receipt.blockers[0], "MISSING:BENCHMARK_RECEIPT")
        @Assert(receipt.nonClaims[0], "NO_NATIVE_BACKEND_IMPLEMENTED")
    }

    @TestCase
    public func testBackendReadinessAllowsNativeImplementationPacketOnlyAfterReceipts(): Unit {
        let request = api2.IoDriverPolicyRequest(
            "file-service",
            "random",
            "local-copy",
            true,
            true,
            true,
            true,
            true,
            "linux-native-candidate",
            true,
            16,
            "platform=linux"
        )
        let receipt = api2.buildIoDriverBackendReadinessReceipt(
            request,
            api2.IoDriverBackendReadinessEvidence(
                "_helper/archive/knowledge/benchmark-receipt.md",
                "_helper/archive/knowledge/fallback-proof.md",
                "_helper/archive/knowledge/platform-probe.md",
                "_helper/archive/knowledge/lifetime-audit.md"
            )
        )

        @Assert(receipt.selectedDriver, "linux-native-candidate")
        @Assert(receipt.ready, true)
        @Assert(receipt.status, "ready-lab-backend-implementation-packet")
        @Assert(receipt.missingProofs.size, 0)
        @Assert(receipt.blockers.size, 0)
        @Assert(receipt.nextAction, "open one backend implementation packet with attached receipts")
        @Assert(receipt.nonClaims[2], "NO_PERFORMANCE_CLAIM")
    }

    @TestCase
    public func testBackendReadinessKeepsUnsupportedRequestBlocked(): Unit {
        let request = api2.IoDriverPolicyRequest(
            "file-service",
            "random",
            "local-copy",
            true,
            true,
            true,
            true,
            true,
            "linux-native-candidate",
            false,
            16,
            "platform=linux"
        )
        let receipt = api2.buildIoDriverBackendReadinessReceipt(
            request,
            api2.IoDriverBackendReadinessEvidence(
                "_helper/archive/knowledge/benchmark-receipt.md",
                "_helper/archive/knowledge/fallback-proof.md",
                "_helper/archive/knowledge/platform-probe.md",
                "_helper/archive/knowledge/lifetime-audit.md"
            )
        )

        @Assert(receipt.selectedDriver, "")
        @Assert(receipt.ready, false)
        @Assert(receipt.status, "blocked-unsupported-request")
        @Assert(receipt.blockers[0], "UNSUPPORTED_REQUEST")
        @Assert(receipt.blockers[1], "BLOCKED:linux-native-candidate:EXPERIMENTAL_DISABLED")
        @Assert(receipt.nextAction, "narrow request or add stable fallback before backend work")
    }

    @TestCase
    public func testLinuxFileBackendReceiptProbeStopsBeforeMissingReceipts(): Unit {
        let request = api2.IoDriverPolicyRequest(
            "file-service",
            "random",
            "local-copy",
            true,
            true,
            true,
            true,
            true,
            "linux-native-candidate",
            true,
            16,
            "platform=linux"
        )
        let probe = api2.buildIoDriverLinuxFileBackendReceiptProbe(
            request,
            api2.IoDriverBackendReadinessEvidence("", "", "", "")
        )

        @Assert(probe.selectedDriver, "linux-native-candidate")
        @Assert(probe.readyForImplementationPacket, false)
        @Assert(probe.status, "blocked-linux-receipt-missing")
        @Assert(probe.entryPoints[0], "sendfile")
        @Assert(probe.entryPoints[1], "copy_file_range")
        @Assert(probe.fallbackChain[0], "std-fs-blocking")
        @Assert(probe.requiredReceipts[0], "BENCHMARK_RECEIPT")
        @Assert(probe.missingReceipts[0], "BENCHMARK_RECEIPT")
        @Assert(probe.benchmarkReceiptStatus, "BENCHMARK_RECEIPT_MISSING")
        @Assert(probe.platformProbeStatus, "PLATFORM_HINT_LINUX_BUT_PROBE_MISSING")
        @Assert(probe.blockers[0], "MISSING:BENCHMARK_RECEIPT")
        @Assert(probe.nonClaims[2], "NO_PERFORMANCE_CLAIM")
    }

    @TestCase
    public func testLinuxFileBackendReceiptProbeBlocksWhenPlatformDoesNotSelectLinuxCandidate(): Unit {
        let request = api2.IoDriverPolicyRequest(
            "file-service",
            "random",
            "local-copy",
            true,
            true,
            true,
            true,
            true,
            "linux-native-candidate",
            true,
            16,
            "platform=macos"
        )
        let probe = api2.buildIoDriverLinuxFileBackendReceiptProbe(
            request,
            api2.IoDriverBackendReadinessEvidence("", "", "", "")
        )

        @Assert(probe.selectedDriver, "")
        @Assert(probe.readyForImplementationPacket, false)
        @Assert(probe.status, "blocked-linux-candidate-not-selected")
        @Assert(probe.entryPoints.size, 0)
        @Assert(probe.platformProbeStatus, "PLATFORM_SCOPE_UNCONFIRMED")
        @Assert(probe.blockers[0], "LINUX_NATIVE_CANDIDATE_NOT_SELECTED")
        @Assert(probe.blockers[1], "UNSUPPORTED_REQUEST")
        @Assert(probe.blockers[2], "BLOCKED:linux-native-candidate:PLATFORM_SCOPE_UNCONFIRMED")
        @Assert(probe.nextAction, "keep stable fallback and collect Linux platform proof before backend work")
    }

    @TestCase
    public func testLinuxFileBackendReceiptProbeAllowsOnlyImplementationPacketAfterReceipts(): Unit {
        let request = api2.IoDriverPolicyRequest(
            "file-service",
            "random",
            "local-copy",
            true,
            true,
            true,
            true,
            true,
            "linux-native-candidate",
            true,
            16,
            "platform=linux"
        )
        let probe = api2.buildIoDriverLinuxFileBackendReceiptProbe(
            request,
            api2.IoDriverBackendReadinessEvidence(
                "_helper/archive/knowledge/linux-sendfile-benchmark-receipt.md",
                "_helper/archive/knowledge/linux-sendfile-fallback-proof.md",
                "_helper/archive/knowledge/linux-sendfile-platform-probe.md",
                "_helper/archive/knowledge/linux-sendfile-lifetime-audit.md"
            )
        )

        @Assert(probe.selectedDriver, "linux-native-candidate")
        @Assert(probe.readyForImplementationPacket, true)
        @Assert(probe.status, "ready-linux-file-backend-implementation-packet")
        @Assert(probe.missingReceipts.size, 0)
        @Assert(probe.blockers.size, 0)
        @Assert(probe.benchmarkReceiptStatus, "BENCHMARK_RECEIPT_PROVIDED")
        @Assert(probe.fallbackProofStatus, "FALLBACK_PROOF_PROVIDED")
        @Assert(probe.platformProbeStatus, "PLATFORM_PROBE_PROVIDED")
        @Assert(probe.lifetimeAuditStatus, "LIFETIME_AUDIT_PROVIDED")
        @Assert(probe.nextAction, "open one Linux file backend implementation packet with attached receipts")
        @Assert(probe.nonClaims[0], "NO_NATIVE_BACKEND_IMPLEMENTED")
    }
}
