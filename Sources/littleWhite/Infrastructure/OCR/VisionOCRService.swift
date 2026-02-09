import Foundation

public struct OCRRequestConfiguration: Equatable, Sendable {
    public let usesLanguageCorrection: Bool
    public let recognitionLanguages: [String]

    public init(usesLanguageCorrection: Bool, recognitionLanguages: [String]) {
        self.usesLanguageCorrection = usesLanguageCorrection
        self.recognitionLanguages = recognitionLanguages
    }
}

public struct OCRTextObservation: Equatable, Sendable {
    public let text: String
    public let confidence: Double

    public init(text: String, confidence: Double) {
        self.text = text
        self.confidence = confidence
    }
}

public protocol OCRTextRecognizing {
    @MainActor
    func recognizeText(from url: URL, configuration: OCRRequestConfiguration) async throws -> [OCRTextObservation]
}

public struct VisionOCRService {
    public let defaultConfiguration: OCRRequestConfiguration
    private let recognizer: OCRTextRecognizing

    public init(
        defaultConfiguration: OCRRequestConfiguration = .init(
            usesLanguageCorrection: true,
            recognitionLanguages: ["zh-Hans", "en-US"]
        )
    ) {
        self.recognizer = Self.makeDefaultRecognizer()
        self.defaultConfiguration = defaultConfiguration
    }

    public init(
        recognizer: OCRTextRecognizing,
        defaultConfiguration: OCRRequestConfiguration = .init(
            usesLanguageCorrection: true,
            recognitionLanguages: ["zh-Hans", "en-US"]
        )
    ) {
        self.recognizer = recognizer
        self.defaultConfiguration = defaultConfiguration
    }

    private static func makeDefaultRecognizer() -> OCRTextRecognizing {
        if #available(iOS 13.0, macOS 10.15, *) {
            return VisionTextRecognizer()
        }
        return VisionTextRecognizerFallback()
    }

    public func merge(observations: [OCRTextObservation]) -> String {
        observations.map(\.text).joined(separator: "\n")
    }

    public func buildConfidenceSummary(
        from observations: [OCRTextObservation],
        threshold: Double = 0.6
    ) -> OCRConfidenceSummary {
        let low = observations.filter { $0.confidence < threshold }.map(\.text)
        let average = observations.isEmpty
            ? 0.0
            : observations.map(\.confidence).reduce(0.0, +) / Double(observations.count)
        return OCRConfidenceSummary(lowConfidenceSpans: low, averageConfidence: average)
    }

    @MainActor
    public func recognizeText(report: ImportedReport) async throws -> OCRTextResult {
        let startedAt = Date()
        let observations = try await recognizer.recognizeText(
            from: report.localURL,
            configuration: defaultConfiguration
        )
        let raw = merge(observations: observations)
        let elapsedMs = max(1, Int(Date().timeIntervalSince(startedAt) * 1000))

        return OCRTextResult(
            rawText: raw,
            confidenceSummary: buildConfidenceSummary(from: observations),
            sourceReportId: report.id,
            durationMs: elapsedMs,
            recognizedAt: Date()
        )
    }
}

#if canImport(Vision)
import Vision

@available(iOS 13.0, macOS 10.15, *)
public struct VisionTextRecognizer: OCRTextRecognizing {
    public init() {}

    @MainActor
    public func recognizeText(from url: URL, configuration: OCRRequestConfiguration) async throws -> [OCRTextObservation] {
        // Runtime Vision integration is intentionally isolated here.
        // In package tests, this path is generally not executed.
        let request = VNRecognizeTextRequest()
        request.usesLanguageCorrection = configuration.usesLanguageCorrection
        request.recognitionLanguages = configuration.recognitionLanguages

        let handler = VNImageRequestHandler(url: url)
        try handler.perform([request])

        let observations = (request.results ?? []).compactMap { observation in
            observation.topCandidates(1).first.map {
                OCRTextObservation(text: $0.string, confidence: Double($0.confidence))
            }
        }

        return observations
    }
}
#else
public struct VisionTextRecognizer: OCRTextRecognizing {
    public init() {}

    @MainActor
    public func recognizeText(from url: URL, configuration: OCRRequestConfiguration) async throws -> [OCRTextObservation] {
        []
    }
}
#endif

private struct VisionTextRecognizerFallback: OCRTextRecognizing {
    @MainActor
    func recognizeText(from url: URL, configuration: OCRRequestConfiguration) async throws -> [OCRTextObservation] {
        []
    }
}
