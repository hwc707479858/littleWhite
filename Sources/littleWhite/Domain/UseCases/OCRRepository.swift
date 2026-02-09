@preconcurrency import Foundation

public protocol OCRRepository {
    @MainActor
    func recognizeText(from report: ImportedReport) async throws -> OCRTextResult
}
