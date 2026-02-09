import Foundation
import Testing
@testable import littleWhite

@MainActor
private final class MockUIOCRTrigger: OCRTriggering {
    func triggerOCR(for report: ImportedReport) async {}
}

struct ImportFlowUITests {
    @Test
    @MainActor
    func showsPendingRecognitionStateAfterSuccessfulImport() async {
        let report = ImportedReport(
            sourceType: .photo,
            mimeType: "image/jpeg",
            localURL: URL(fileURLWithPath: "/tmp/r.jpg")
        )
        let repository = InMemoryImportRepository(report: report)
        let viewModel = ImportViewModel(useCase: ImportReportUseCase(repository: repository))

        await viewModel.startImport()

        #expect(viewModel.state == .imported(report))
    }

    @Test
    @MainActor
    func showsErrorPromptWithinOneSecondForInvalidFormat() async {
        let mockOCR = MockUIOCRTrigger()
        let orchestrator = ImportFlowOrchestrator(
            validator: ImportFormatValidator(),
            ocrTrigger: mockOCR
        )
        let start = Date()

        await orchestrator.handleImportedFile(
            url: URL(fileURLWithPath: "/tmp/unsupported.txt"),
            mimeType: "text/plain"
        )

        let elapsed = Date().timeIntervalSince(start)
        #expect(elapsed < 1.0)
        #expect(orchestrator.lastError?.reasonCode == .unsupportedFormat)
    }
}
