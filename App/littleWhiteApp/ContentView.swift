import SwiftUI

@MainActor
final class DemoOCRScreenViewModel: ObservableObject {
    @Published private(set) var screenState: OCRViewModel.State = .idle

    private let ocrViewModel: OCRViewModel
    private var selectedReport: ImportedReport?

    init() {
        let repository = DemoOCRRepository()
        let useCase = RunOCRUseCase(repository: repository)
        self.ocrViewModel = OCRViewModel(useCase: useCase)
    }

    func pickSamplePDF() {
        selectedReport = ImportedReport(
            sourceType: .pdf,
            mimeType: "application/pdf",
            localURL: URL(fileURLWithPath: "/tmp/sample-blood-report.pdf")
        )
        if let selectedReport {
            ocrViewModel.selectReport(selectedReport)
            screenState = ocrViewModel.state
        }
    }

    func startOCR() {
        guard !isRecognizing else { return }
        screenState = .recognizing
        Task {
            await ocrViewModel.startOCR()
            screenState = ocrViewModel.state
        }
    }

    func retryOCR() {
        guard !isRecognizing else { return }
        screenState = .recognizing
        Task {
            await ocrViewModel.retryOCR()
            screenState = ocrViewModel.state
        }
    }

    var importViewModel: OCRImportView {
        OCRImportView(
            selectedSummary: selectedReport.map { "\($0.mimeType) | \($0.localURL.lastPathComponent)" },
            canStartOCR: ocrViewModel.canStartOCR && !isRecognizing
        )
    }

    var isRecognizing: Bool {
        if case .recognizing = screenState { return true }
        return false
    }
}

struct ContentView: View {
    @StateObject private var viewModel: DemoOCRScreenViewModel

    init(viewModel: DemoOCRScreenViewModel = DemoOCRScreenViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("血常规 OCR 演示")
                    .font(.title2)
                    .fontWeight(.semibold)

                GroupBox("OCR 导入页") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(viewModel.importViewModel.summaryText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 12) {
                            Button("选择示例 PDF") {
                                viewModel.pickSamplePDF()
                            }
                            .buttonStyle(.bordered)
                            .disabled(viewModel.isRecognizing)

                            Button("开始 OCR") {
                                viewModel.startOCR()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(!viewModel.importViewModel.startButtonEnabled)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
                }

                GroupBox("OCR 结果页") {
                    resultBody
                }

                Spacer()
            }
            .padding()
            .navigationTitle("littleWhite")
        }
    }

    @ViewBuilder
    private var resultBody: some View {
        switch viewModel.screenState {
        case .idle, .fileSelected:
            Text("请选择文件并点击开始 OCR")
                .foregroundStyle(.secondary)

        case .recognizing:
            HStack(spacing: 8) {
                ProgressView()
                Text("识别中...")
            }

        case let .recognized(result):
            let resultView = OCRResultView(result: result, showRetryButton: false)
            VStack(alignment: .leading, spacing: 10) {
                ScrollView {
                    Text(resultView.rawText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
                .frame(maxHeight: 200)

                if !resultView.lowConfidenceLabels.isEmpty {
                    Text("低置信标记：\(resultView.lowConfidenceLabels.joined(separator: "、"))")
                        .font(.footnote)
                        .foregroundStyle(.orange)
                }
            }

        case let .failed(error):
            VStack(alignment: .leading, spacing: 10) {
                Text(error.message)
                    .foregroundStyle(.red)

                Button("重试 OCR") {
                    viewModel.retryOCR()
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

private final class DemoOCRRepository: OCRRepository {
    @MainActor
    func recognizeText(from report: ImportedReport) async throws -> OCRTextResult {
        try await Task.sleep(for: .milliseconds(350))

        return OCRTextResult(
            rawText: "WBC 5.8\nRBC 4.35\nHGB 126\nPLT 221",
            confidenceSummary: OCRConfidenceSummary(
                lowConfidenceSpans: ["HGB 126"],
                averageConfidence: 0.96
            ),
            sourceReportId: report.id,
            durationMs: 350,
            recognizedAt: Date()
        )
    }
}

private extension AppError {
    var message: String {
        switch kind {
        case let .userFacing(text):
            return text
        }
    }
}
