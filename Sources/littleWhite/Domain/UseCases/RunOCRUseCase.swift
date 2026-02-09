import Foundation

public struct RunOCRUseCase {
    private let repository: OCRRepository

    public init(repository: OCRRepository) {
        self.repository = repository
    }

    @MainActor
    public func execute(report: ImportedReport) async throws -> OCRTextResult {
        try await repository.recognizeText(from: report)
    }
}
