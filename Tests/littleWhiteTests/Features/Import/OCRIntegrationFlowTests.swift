import Foundation
import Testing
@testable import littleWhite

@MainActor
private final class PendingContextStoreSpy: PendingExtractionContextStoring {
    private(set) var saved: PendingExtractionContext?

    func save(_ context: PendingExtractionContext) {
        saved = context
    }
}

@MainActor
private final class OCREventLoggerSpy: OCREventLogging {
    private(set) var events: [OCREvent] = []
    func log(_ event: OCREvent) { events.append(event) }
}

@MainActor
private struct OCRRepoSuccessStub: OCRRepository {
    let result: OCRTextResult
    func recognizeText(from report: ImportedReport) async throws -> OCRTextResult { result }
}

@MainActor
private struct OCRRepoFailureStub: OCRRepository {
    let error: Error
    func recognizeText(from report: ImportedReport) async throws -> OCRTextResult { throw error }
}

struct OCRIntegrationFlowTests {
    @Test
    @MainActor
    func selectFileUpdatesToFileSelectedAndStartButtonEnabled() {
        let vm = OCRViewModel(useCase: RunOCRUseCase(repository: OCRRepoSuccessStub(result: .fixture())))
        let report = ImportedReport(sourceType: .photo, mimeType: "image/jpeg", localURL: URL(fileURLWithPath: "/tmp/a.jpg"))

        vm.selectReport(report)

        #expect(vm.state.isFileSelected)
        #expect(vm.canStartOCR)
    }

    @Test
    @MainActor
    func successfulOCRStoresPendingExtractionContextAndTracksSuccessEvent() async {
        let report = ImportedReport(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
            sourceType: .photo,
            mimeType: "image/jpeg",
            localURL: URL(fileURLWithPath: "/tmp/a.jpg")
        )
        let result = OCRTextResult(
            rawText: "WBC 3.2",
            confidenceSummary: .init(lowConfidenceSpans: ["WBC"], averageConfidence: 0.82),
            sourceReportId: report.id,
            durationMs: 100,
            recognizedAt: Date(timeIntervalSince1970: 20)
        )

        let store = PendingContextStoreSpy()
        let logger = OCREventLoggerSpy()
        let vm = OCRViewModel(
            useCase: RunOCRUseCase(repository: OCRRepoSuccessStub(result: result)),
            eventTracker: OCREventTracker(logger: logger),
            pendingStore: store
        )

        vm.selectReport(report)
        await vm.startOCR()

        #expect(vm.state.isRecognized)
        #expect(store.saved?.input.rawText == "WBC 3.2")
        #expect(logger.events.map(\.name) == ["ocr.request.started", "ocr.request.succeeded"])
        #expect((logger.events.last?.durationMs ?? 0) >= 0)
    }

    @Test
    @MainActor
    func failedOCRDoesNotWritePendingExtractionContext() async {
        let report = ImportedReport(sourceType: .photo, mimeType: "image/jpeg", localURL: URL(fileURLWithPath: "/tmp/a.jpg"))
        let store = PendingContextStoreSpy()
        let vm = OCRViewModel(
            useCase: RunOCRUseCase(repository: OCRRepoFailureStub(error: OCREngineError.timeout)),
            pendingStore: store
        )

        vm.selectReport(report)
        await vm.startOCR()

        #expect(store.saved == nil)
    }

    @Test
    @MainActor
    func failedFeedbackPathIsUnderThreeSeconds() async {
        let report = ImportedReport(sourceType: .photo, mimeType: "image/jpeg", localURL: URL(fileURLWithPath: "/tmp/a.jpg"))
        let vm = OCRViewModel(
            useCase: RunOCRUseCase(repository: OCRRepoFailureStub(error: OCREngineError.timeout))
        )
        vm.selectReport(report)

        let start = Date()
        await vm.startOCR()
        let elapsed = Date().timeIntervalSince(start)

        #expect(elapsed < 3.0)
    }
}

private extension OCRTextResult {
    static func fixture() -> OCRTextResult {
        OCRTextResult(
            rawText: "RBC 3.1",
            confidenceSummary: .init(lowConfidenceSpans: [], averageConfidence: 0.9),
            sourceReportId: UUID(),
            durationMs: 70,
            recognizedAt: Date()
        )
    }
}

private extension OCRViewModel.State {
    var isFileSelected: Bool {
        if case .fileSelected = self { return true }
        return false
    }

    var isRecognized: Bool {
        if case .recognized = self { return true }
        return false
    }
}
