import Foundation

public final class InMemoryImportRepository: ImportRepository {
    private let report: ImportedReport

    public init(
        report: ImportedReport = ImportedReport(
            sourceType: .photo,
            mimeType: "image/jpeg",
            localURL: URL(fileURLWithPath: "/tmp/report.jpg")
        )
    ) {
        self.report = report
    }

    public func loadImportedReport() async throws -> ImportedReport {
        report
    }
}
