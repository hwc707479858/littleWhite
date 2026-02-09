import Foundation

@MainActor
public final class OCRViewModel {
    public enum State: Equatable {
        case idle
        case fileSelected(ImportedReport)
        case recognizing
        case recognized(OCRTextResult)
        case failed(AppError)
    }

    public private(set) var state: State = .idle

    private let useCase: RunOCRUseCase
    private let eventTracker: OCREventTracker?
    private let pendingStore: PendingExtractionContextStoring?
    private var lastReport: ImportedReport?

    public init(
        useCase: RunOCRUseCase,
        eventTracker: OCREventTracker? = nil,
        pendingStore: PendingExtractionContextStoring? = nil
    ) {
        self.useCase = useCase
        self.eventTracker = eventTracker
        self.pendingStore = pendingStore
    }

    public var canStartOCR: Bool {
        if case .fileSelected = state { return true }
        if case .failed = state, lastReport != nil { return true }
        return false
    }

    public func selectReport(_ report: ImportedReport) {
        lastReport = report
        state = .fileSelected(report)
    }

    public func startOCR() async {
        guard let report = lastReport else { return }
        await runOCR(for: report)
    }

    public func runOCR(for report: ImportedReport) async {
        if case .recognizing = state { return }
        lastReport = report
        let startedAt = Date()
        eventTracker?.trackStarted()
        state = .recognizing
        do {
            let result = try await useCase.execute(report: report)
            if result.rawText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let error = OCRErrorMapper.map(.noText)
                state = .failed(error)
                let durationMs = max(1, Int(Date().timeIntervalSince(startedAt) * 1000))
                eventTracker?.trackFailed(reasonCode: error.reasonCode, durationMs: durationMs)
            } else {
                state = .recognized(result)
                pendingStore?.save(
                    PendingExtractionContext(
                        input: result.toExtractionInput(),
                        confidenceSummary: result.confidenceSummary
                    )
                )
                let durationMs = max(1, Int(Date().timeIntervalSince(startedAt) * 1000))
                eventTracker?.trackSucceeded(durationMs: durationMs)
            }
        } catch {
            let mapped = OCRErrorMapper.mapAny(error)
            state = .failed(mapped)
            let durationMs = max(1, Int(Date().timeIntervalSince(startedAt) * 1000))
            eventTracker?.trackFailed(reasonCode: mapped.reasonCode, durationMs: durationMs)
        }
    }

    public func retryOCR() async {
        guard let report = lastReport else { return }
        await runOCR(for: report)
    }
}
