import Foundation

public struct OCRConfidenceSummary: Equatable, Sendable {
    public let lowConfidenceSpans: [String]
    public let averageConfidence: Double

    public init(lowConfidenceSpans: [String], averageConfidence: Double) {
        self.lowConfidenceSpans = lowConfidenceSpans
        self.averageConfidence = averageConfidence
    }
}

public struct OCRExtractionInput: Equatable, Sendable {
    public let rawText: String
    public let sourceReportId: UUID
    public let createdAt: Date

    public init(rawText: String, sourceReportId: UUID, createdAt: Date) {
        self.rawText = rawText
        self.sourceReportId = sourceReportId
        self.createdAt = createdAt
    }
}

public struct OCRTextResult: Equatable, Sendable {
    public let rawText: String
    public let confidenceSummary: OCRConfidenceSummary
    public let sourceReportId: UUID
    public let durationMs: Int
    public let recognizedAt: Date

    public init(
        rawText: String,
        confidenceSummary: OCRConfidenceSummary,
        sourceReportId: UUID,
        durationMs: Int,
        recognizedAt: Date
    ) {
        self.rawText = rawText
        self.confidenceSummary = confidenceSummary
        self.sourceReportId = sourceReportId
        self.durationMs = durationMs
        self.recognizedAt = recognizedAt
    }

    public func toExtractionInput() -> OCRExtractionInput {
        OCRExtractionInput(
            rawText: rawText,
            sourceReportId: sourceReportId,
            createdAt: recognizedAt
        )
    }
}
