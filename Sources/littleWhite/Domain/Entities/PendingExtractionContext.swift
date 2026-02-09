import Foundation

public struct PendingExtractionContext: Equatable, Sendable {
    public let input: OCRExtractionInput
    public let confidenceSummary: OCRConfidenceSummary
    public let createdAt: Date

    public init(input: OCRExtractionInput, confidenceSummary: OCRConfidenceSummary, createdAt: Date = Date()) {
        self.input = input
        self.confidenceSummary = confidenceSummary
        self.createdAt = createdAt
    }
}

public protocol PendingExtractionContextStoring {
    @MainActor
    func save(_ context: PendingExtractionContext)
}

public final class InMemoryPendingExtractionStore: PendingExtractionContextStoring {
    public private(set) var current: PendingExtractionContext?

    public init() {}

    @MainActor
    public func save(_ context: PendingExtractionContext) {
        current = context
    }
}
