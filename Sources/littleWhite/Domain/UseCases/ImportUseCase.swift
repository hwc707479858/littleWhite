import Foundation

public protocol ImportRepository {
    @MainActor
    func loadImportedReport() async throws -> ImportedReport
}

public protocol ImportUseCase {
    @MainActor
    func execute() async throws -> ImportedReport
}

public struct ImportReportUseCase: ImportUseCase {
    private let repository: ImportRepository

    public init(repository: ImportRepository) {
        self.repository = repository
    }

    @MainActor
    public func execute() async throws -> ImportedReport {
        try await repository.loadImportedReport()
    }
}
