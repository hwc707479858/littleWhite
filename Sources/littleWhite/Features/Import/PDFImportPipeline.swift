import Foundation
#if canImport(UIKit)
import UniformTypeIdentifiers
import UIKit
#endif

public struct PickedDocumentItem: Equatable {
    public let localURL: URL
    public let mimeType: String

    public init(localURL: URL, mimeType: String) {
        self.localURL = localURL
        self.mimeType = mimeType
    }
}

public protocol SecurityScopedAccessing {
    func startAccessingSecurityScopedResource(for url: URL) -> Bool
    func stopAccessingSecurityScopedResource(for url: URL)
}

public struct FoundationSecurityScopedAccessor: SecurityScopedAccessing {
    public init() {}

    public func startAccessingSecurityScopedResource(for url: URL) -> Bool {
        url.startAccessingSecurityScopedResource()
    }

    public func stopAccessingSecurityScopedResource(for url: URL) {
        url.stopAccessingSecurityScopedResource()
    }
}

public final class MockSecurityScopedAccessor: SecurityScopedAccessing {
    public private(set) var startCount = 0
    public private(set) var stopCount = 0

    public init() {}

    public func startAccessingSecurityScopedResource(for url: URL) -> Bool {
        startCount += 1
        return true
    }

    public func stopAccessingSecurityScopedResource(for url: URL) {
        stopCount += 1
    }
}

public final class DeniedSecurityScopedAccessor: SecurityScopedAccessing {
    public init() {}

    public func startAccessingSecurityScopedResource(for url: URL) -> Bool { false }
    public func stopAccessingSecurityScopedResource(for url: URL) {}
}

public struct PDFImportProcessor {
    public init() {}

    public func mapToReport(_ item: PickedDocumentItem, importedAt: Date = Date()) throws -> ImportedReport {
        guard SupportedReportFormat.detect(fromMimeType: item.mimeType) == .pdf else {
            throw AppError(kind: .userFacing("仅支持 PDF 文件"), reasonCode: .unsupportedFormat)
        }

        return ImportedReport(
            sourceType: .pdf,
            mimeType: item.mimeType,
            localURL: item.localURL,
            createdAt: importedAt
        )
    }

    public func importPDF(
        from item: PickedDocumentItem,
        accessor: SecurityScopedAccessing,
        importedAt: Date = Date()
    ) throws -> ImportedReport {
        let granted = accessor.startAccessingSecurityScopedResource(for: item.localURL)
        guard granted else {
            throw AppError(kind: .userFacing("无法访问所选 PDF"), reasonCode: .readFailed)
        }
        defer { accessor.stopAccessingSecurityScopedResource(for: item.localURL) }

        return try mapToReport(item, importedAt: importedAt)
    }
}

#if canImport(UIKit)
@available(iOS 14.0, *)
public final class DocumentPickerClient: NSObject, UIDocumentPickerDelegate {
    private var continuation: CheckedContinuation<[PickedDocumentItem], Error>?

    public override init() {}

    public static func makePicker() -> UIDocumentPickerViewController {
        UIDocumentPickerViewController(forOpeningContentTypes: [.pdf], asCopy: true)
    }

    public func pickDocuments() async throws -> [PickedDocumentItem] {
        // Runtime picker presentation should be coordinated by app layer.
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
        }
    }

    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let first = urls.first else {
            continuation?.resume(returning: [])
            continuation = nil
            return
        }
        continuation?.resume(returning: [PickedDocumentItem(localURL: first, mimeType: "application/pdf")])
        continuation = nil
    }

    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        continuation?.resume(returning: [])
        continuation = nil
    }
}
#endif
