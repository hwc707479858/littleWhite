import Foundation

public final class OCRRepositoryImpl: OCRRepository {
    private let service: VisionOCRService

    public init(service: VisionOCRService = VisionOCRService()) {
        self.service = service
    }

    @MainActor
    public func recognizeText(from report: ImportedReport) async throws -> OCRTextResult {
        try await service.recognizeText(report: report)
    }
}
