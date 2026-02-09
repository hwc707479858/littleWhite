import Foundation

public enum SupportedReportFormat: String, CaseIterable, Equatable {
    case jpg
    case jpeg
    case png
    case pdf

    public static func detect(fromMimeType mimeType: String) -> SupportedReportFormat? {
        let normalized = mimeType.lowercased()
        switch normalized {
        case "image/jpg": return .jpg
        case "image/jpeg": return .jpeg
        case "image/png": return .png
        case "application/pdf": return .pdf
        default: return nil
        }
    }

    public var isImage: Bool {
        self == .jpg || self == .jpeg || self == .png
    }
}
