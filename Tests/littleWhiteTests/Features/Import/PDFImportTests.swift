import Foundation
import Testing
@testable import littleWhite

struct PDFImportTests {
    @Test
    func mapsPDFSelectionToImportedReport() throws {
        let url = URL(fileURLWithPath: "/tmp/report.pdf")
        let picked = PickedDocumentItem(localURL: url, mimeType: "application/pdf")

        let report = try PDFImportProcessor().mapToReport(picked, importedAt: Date(timeIntervalSince1970: 456))

        #expect(report.sourceType == .pdf)
        #expect(report.mimeType == "application/pdf")
        #expect(report.localURL == url)
    }

    @Test
    func securityScopedAccessLifecycleIsPaired() throws {
        let accessor = MockSecurityScopedAccessor()
        let url = URL(fileURLWithPath: "/tmp/report.pdf")

        _ = try PDFImportProcessor().importPDF(
            from: PickedDocumentItem(localURL: url, mimeType: "application/pdf"),
            accessor: accessor,
            importedAt: Date(timeIntervalSince1970: 1)
        )

        #expect(accessor.startCount == 1)
        #expect(accessor.stopCount == 1)
    }

    @Test
    func securityScopedAccessDeniedReturnsReadFailed() {
        let accessor = DeniedSecurityScopedAccessor()
        let url = URL(fileURLWithPath: "/tmp/report.pdf")

        #expect(throws: AppError.self) {
            _ = try PDFImportProcessor().importPDF(
                from: PickedDocumentItem(localURL: url, mimeType: "application/pdf"),
                accessor: accessor
            )
        }
    }
}
