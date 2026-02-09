import Foundation
import Testing
@testable import littleWhite

@MainActor
final class MockOCRTrigger: OCRTriggering {
    private(set) var triggerCount = 0

    func triggerOCR(for report: ImportedReport) async {
        triggerCount += 1
    }
}

struct ImportValidationTests {
    @Test
    func unsupportedMimeTypeMapsToUserFacingError() {
        let validator = ImportFormatValidator()

        #expect(throws: AppError.self) {
            try validator.validate(mimeType: "text/plain")
        }
    }

    @Test
    @MainActor
    func invalidFormatStopsBeforeOCRTrigger() async {
        let mockOCR = MockOCRTrigger()
        let validator = ImportFormatValidator()
        let orchestrator = ImportFlowOrchestrator(validator: validator, ocrTrigger: mockOCR)

        await orchestrator.handleImportedFile(url: URL(fileURLWithPath: "/tmp/a.txt"), mimeType: "text/plain")

        #expect(mockOCR.triggerCount == 0)
        #expect(orchestrator.lastError?.reasonCode == .unsupportedFormat)
    }
}
