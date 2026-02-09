public struct OCRImportView {
    public let selectedSummary: String?
    public let canStartOCR: Bool

    public init(selectedSummary: String?, canStartOCR: Bool) {
        self.selectedSummary = selectedSummary
        self.canStartOCR = canStartOCR
    }

    public var startButtonEnabled: Bool { canStartOCR }
    public var summaryText: String { selectedSummary ?? "未选择文件" }
}

public struct OCRResultView {
    public let result: OCRTextResult
    public let showRetryButton: Bool

    public init(result: OCRTextResult, showRetryButton: Bool) {
        self.result = result
        self.showRetryButton = showRetryButton
    }

    public var rawText: String { result.rawText }
    public var lowConfidenceLabels: [String] { result.confidenceSummary.lowConfidenceSpans }
    public var retryButtonVisible: Bool { showRetryButton }
}
