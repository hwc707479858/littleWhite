import Foundation

public struct OCREvent: Equatable, Sendable {
    public let name: String
    public let reasonCode: ImportReasonCode?
    public let durationMs: Int?
    public let timestamp: Date

    public init(name: String, reasonCode: ImportReasonCode?, durationMs: Int?, timestamp: Date = Date()) {
        self.name = name
        self.reasonCode = reasonCode
        self.durationMs = durationMs
        self.timestamp = timestamp
    }
}

public protocol OCREventLogging {
    @MainActor
    func log(_ event: OCREvent)
}

public final class InMemoryOCREventLogger: OCREventLogging {
    public private(set) var events: [OCREvent] = []
    public init() {}
    @MainActor
    public func log(_ event: OCREvent) { events.append(event) }
}

public struct OCREventTracker {
    private let logger: OCREventLogging

    public init(logger: OCREventLogging) {
        self.logger = logger
    }

    @MainActor
    public func trackStarted() {
        logger.log(OCREvent(name: "ocr.request.started", reasonCode: nil, durationMs: nil))
    }

    @MainActor
    public func trackSucceeded(durationMs: Int) {
        logger.log(OCREvent(name: "ocr.request.succeeded", reasonCode: nil, durationMs: durationMs))
    }

    @MainActor
    public func trackFailed(reasonCode: ImportReasonCode, durationMs: Int? = nil) {
        logger.log(OCREvent(name: "ocr.request.failed", reasonCode: reasonCode, durationMs: durationMs))
    }
}
