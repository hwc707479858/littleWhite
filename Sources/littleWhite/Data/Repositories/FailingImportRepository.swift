import Foundation

public final class FailingImportRepository: ImportRepository {
    private let error: Error

    public init(error: Error) {
        self.error = error
    }

    @MainActor
    public func loadImportedReport() async throws -> ImportedReport {
        throw error
    }
}
