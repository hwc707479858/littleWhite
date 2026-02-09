import Foundation

public struct ImportEvent: Equatable {
    public let name: String
    public let reasonCode: ImportReasonCode?
    public let timestamp: Date

    public init(name: String, reasonCode: ImportReasonCode?, timestamp: Date = Date()) {
        self.name = name
        self.reasonCode = reasonCode
        self.timestamp = timestamp
    }
}

public protocol ImportEventLogging {
    func log(_ event: ImportEvent)
}

public final class InMemoryImportEventLogger: ImportEventLogging {
    public private(set) var events: [ImportEvent] = []

    public init() {}

    public func log(_ event: ImportEvent) {
        events.append(event)
    }
}

public struct ImportEventTracker {
    private let logger: ImportEventLogging

    public init(logger: ImportEventLogging) {
        self.logger = logger
    }

    public func trackStarted() {
        logger.log(ImportEvent(name: "import.request.started", reasonCode: nil))
    }

    public func trackSucceeded() {
        logger.log(ImportEvent(name: "import.request.succeeded", reasonCode: nil))
    }

    public func trackFailed(reasonCode: ImportReasonCode) {
        logger.log(ImportEvent(name: "import.request.failed", reasonCode: reasonCode))
    }
}
