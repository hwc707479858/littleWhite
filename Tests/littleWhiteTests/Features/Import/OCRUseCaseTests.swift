import Foundation
import Testing
@testable import littleWhite

private struct OCRRepositoryStub: OCRRepository {
    let output: OCRTextResult

    @MainActor
    func recognizeText(from report: ImportedReport) async throws -> OCRTextResult {
        output
    }
}

struct OCRUseCaseTests {
    @Test
    @MainActor
    func runOCRUseCaseReturnsOCRTextResultFromRepository() async throws {
        let report = ImportedReport(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            sourceType: .photo,
            mimeType: "image/jpeg",
            localURL: URL(fileURLWithPath: "/tmp/r.jpg"),
            createdAt: Date(timeIntervalSince1970: 1)
        )
        let expected = OCRTextResult(
            rawText: "WBC 3.2",
            confidenceSummary: .init(lowConfidenceSpans: ["WBC"], averageConfidence: 0.82),
            sourceReportId: report.id,
            durationMs: 120,
            recognizedAt: Date(timeIntervalSince1970: 2)
        )
        let useCase = RunOCRUseCase(repository: OCRRepositoryStub(output: expected))

        let result = try await useCase.execute(report: report)

        #expect(result == expected)
    }

    @Test
    func ocrTextResultCanBuildExtractionInputForStory13() {
        let sourceID = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!
        let recognizedAt = Date(timeIntervalSince1970: 10)
        let result = OCRTextResult(
            rawText: "HGB 100",
            confidenceSummary: .init(lowConfidenceSpans: [], averageConfidence: 0.93),
            sourceReportId: sourceID,
            durationMs: 90,
            recognizedAt: recognizedAt
        )

        let payload = result.toExtractionInput()

        #expect(payload.rawText == "HGB 100")
        #expect(payload.sourceReportId == sourceID)
        #expect(payload.createdAt == recognizedAt)
    }
}
