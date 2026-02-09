import Foundation

public enum ImportSourceType: Equatable {
    case photo
    case pdf
}

public struct ImportedReport: Equatable {
    public let id: UUID
    public let sourceType: ImportSourceType
    public let mimeType: String
    public let localURL: URL
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        sourceType: ImportSourceType,
        mimeType: String,
        localURL: URL,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.sourceType = sourceType
        self.mimeType = mimeType
        self.localURL = localURL
        self.createdAt = createdAt
    }
}
