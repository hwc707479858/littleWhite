import Foundation
import Testing
@testable import littleWhite

@MainActor
private final class OCRRepositorySequenceStub: OCRRepository {
    var queue: [Result<OCRTextResult, Error>]

    init(queue: [Result<OCRTextResult, Error>]) {
        self.queue = queue
    }

    func recognizeText(from report: ImportedReport) async throws -> OCRTextResult {
        let next = queue.removeFirst()
        switch next {
        case .success(let r): return r
        case .failure(let e): throw e
        }
    }
}

struct OCRFlowTests {
    @Test
    func ocrErrorMapperMapsExpectedCodes() {
        #expect(OCRErrorMapper.map(OCREngineError.timeout).reasonCode == .ocrTimeout)
        #expect(OCRErrorMapper.map(OCREngineError.noText).reasonCode == .ocrNoText)
        #expect(OCRErrorMapper.map(OCREngineError.engine).reasonCode == .ocrEngineError)
    }

    @Test
    @MainActor
    func timeoutIsMappedToOCRTimeoutInViewModel() async {
        let report = ImportedReport(sourceType: .photo, mimeType: "image/jpeg", localURL: URL(fileURLWithPath: "/tmp/r.jpg"))
        let repo = OCRRepositorySequenceStub(queue: [.failure(OCREngineError.timeout)])
        let vm = OCRViewModel(useCase: RunOCRUseCase(repository: repo))

        await vm.runOCR(for: report)

        if case .failed(let error) = vm.state {
            #expect(error.reasonCode == .ocrTimeout)
        } else {
            Issue.record("Expected failed state")
        }
    }

    @Test
    @MainActor
    func engineErrorIsMappedToOCREngineErrorInViewModel() async {
        let report = ImportedReport(sourceType: .photo, mimeType: "image/jpeg", localURL: URL(fileURLWithPath: "/tmp/r.jpg"))
        let repo = OCRRepositorySequenceStub(queue: [.failure(OCREngineError.engine)])
        let vm = OCRViewModel(useCase: RunOCRUseCase(repository: repo))

        await vm.runOCR(for: report)

        if case .failed(let error) = vm.state {
            #expect(error.reasonCode == .ocrEngineError)
        } else {
            Issue.record("Expected failed state")
        }
    }

    @Test
    @MainActor
    func emptyTextIsMappedToOCRNoTextInViewModel() async {
        let report = ImportedReport(sourceType: .photo, mimeType: "image/jpeg", localURL: URL(fileURLWithPath: "/tmp/r.jpg"))
        let result = OCRTextResult(
            rawText: "   ",
            confidenceSummary: .init(lowConfidenceSpans: [], averageConfidence: 0.0),
            sourceReportId: report.id,
            durationMs: 77,
            recognizedAt: Date()
        )
        let repo = OCRRepositorySequenceStub(queue: [.success(result)])
        let vm = OCRViewModel(useCase: RunOCRUseCase(repository: repo))

        await vm.runOCR(for: report)

        if case .failed(let error) = vm.state {
            #expect(error.reasonCode == .ocrNoText)
        } else {
            Issue.record("Expected failed state")
        }
    }

    @Test
    @MainActor
    func retryOCRCanMoveFromFailedBackToRecognizingAndSuccess() async {
        let report = ImportedReport(
            id: UUID(),
            sourceType: .photo,
            mimeType: "image/jpeg",
            localURL: URL(fileURLWithPath: "/tmp/r.jpg")
        )
        let success = OCRTextResult(
            rawText: "WBC 3.2",
            confidenceSummary: .init(lowConfidenceSpans: [], averageConfidence: 0.9),
            sourceReportId: report.id,
            durationMs: 88,
            recognizedAt: Date()
        )

        let repository = OCRRepositorySequenceStub(queue: [
            .failure(OCREngineError.timeout),
            .success(success)
        ])
        let viewModel = OCRViewModel(useCase: RunOCRUseCase(repository: repository))

        await viewModel.runOCR(for: report)
        #expect(viewModel.state.isFailed)

        await viewModel.retryOCR()
        #expect(viewModel.state.isRecognized)
    }
}

private extension OCRViewModel.State {
    var isFailed: Bool {
        if case .failed = self { return true }
        return false
    }

    var isRecognized: Bool {
        if case .recognized = self { return true }
        return false
    }
}
