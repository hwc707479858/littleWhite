import Foundation
import Testing
@testable import littleWhite

struct ImportEventTrackingTests {
    @Test
    @MainActor
    func tracksStartedAndSucceededOnValidImport() async {
        let logger = InMemoryImportEventLogger()
        let tracker = ImportEventTracker(logger: logger)
        let orchestrator = ImportFlowOrchestrator(
            validator: ImportFormatValidator(),
            ocrTrigger: NoopOCRTrigger(),
            eventTracker: tracker
        )

        await orchestrator.handleImportedFile(url: URL(fileURLWithPath: "/tmp/report.jpg"), mimeType: "image/jpeg")

        #expect(logger.events.map(\.name) == ["import.request.started", "import.request.succeeded"])
    }

    @Test
    @MainActor
    func tracksFailedWithReasonCodeOnInvalidFormat() async {
        let logger = InMemoryImportEventLogger()
        let tracker = ImportEventTracker(logger: logger)
        let orchestrator = ImportFlowOrchestrator(
            validator: ImportFormatValidator(),
            ocrTrigger: NoopOCRTrigger(),
            eventTracker: tracker
        )

        await orchestrator.handleImportedFile(url: URL(fileURLWithPath: "/tmp/report.txt"), mimeType: "text/plain")

        #expect(logger.events.map(\.name) == ["import.request.started", "import.request.failed"])
        #expect(logger.events.last?.reasonCode == .unsupportedFormat)
    }

    @Test
    @MainActor
    func tracksReadFailedForCorruptedInput() async {
        let logger = InMemoryImportEventLogger()
        let tracker = ImportEventTracker(logger: logger)
        let repository = FailingImportRepository(error: AppError(kind: .userFacing("读取失败"), reasonCode: .readFailed))
        let viewModel = ImportViewModel(useCase: ImportReportUseCase(repository: repository))

        await viewModel.startImport(tracker: tracker)

        #expect(logger.events.map(\.name) == ["import.request.started", "import.request.failed"])
        #expect(logger.events.last?.reasonCode == .readFailed)
    }
}
