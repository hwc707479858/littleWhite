import Foundation
import Testing
@testable import littleWhite

struct VisionOCRServiceTests {
    @Test
    func requestConfigurationDefaultsToLanguageCorrectionEnabled() {
        let service = VisionOCRService()

        let config = service.defaultConfiguration

        #expect(config.usesLanguageCorrection)
        #expect(config.recognitionLanguages == ["zh-Hans", "en-US"])
    }

    @Test
    func mergeObservationsKeepsInputOrderAsReadableMultilineText() {
        let service = VisionOCRService()
        let observations = [
            OCRTextObservation(text: "WBC 3.2", confidence: 0.93),
            OCRTextObservation(text: "HGB 100", confidence: 0.91),
            OCRTextObservation(text: "PLT 120", confidence: 0.89)
        ]

        let merged = service.merge(observations: observations)

        #expect(merged == "WBC 3.2\nHGB 100\nPLT 120")
    }

    @Test
    func confidenceSummaryMarksLowConfidenceSpans() {
        let service = VisionOCRService()
        let observations = [
            OCRTextObservation(text: "WBC", confidence: 0.4),
            OCRTextObservation(text: "HGB", confidence: 0.95)
        ]

        let summary = service.buildConfidenceSummary(from: observations, threshold: 0.6)

        #expect(summary.lowConfidenceSpans == ["WBC"])
        #expect(summary.averageConfidence > 0.67)
    }
}
