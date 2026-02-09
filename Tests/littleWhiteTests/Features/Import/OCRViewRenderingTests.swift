import Foundation
import Testing
@testable import littleWhite

struct OCRViewRenderingTests {
    @Test
    func importViewShowsSummaryAndDisabledStartWhenNoFile() {
        let view = OCRImportView(selectedSummary: nil, canStartOCR: false)

        #expect(view.startButtonEnabled == false)
        #expect(view.summaryText == "未选择文件")
    }

    @Test
    func resultViewShowsRawTextLowConfidenceAndRetry() {
        let result = OCRTextResult(
            rawText: "WBC 3.2\nHGB 100",
            confidenceSummary: .init(lowConfidenceSpans: ["WBC"], averageConfidence: 0.8),
            sourceReportId: UUID(),
            durationMs: 80,
            recognizedAt: Date()
        )
        let view = OCRResultView(result: result, showRetryButton: true)

        #expect(view.rawText == "WBC 3.2\nHGB 100")
        #expect(view.lowConfidenceLabels == ["WBC"])
        #expect(view.retryButtonVisible)
    }
}
