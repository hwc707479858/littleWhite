public enum ImportReasonCode: String, Equatable, Sendable {
    case unsupportedFormat = "UNSUPPORTED_FORMAT"
    case readFailed = "READ_FAILED"
    case userCancelled = "USER_CANCELLED"
    case pickerError = "PICKER_ERROR"
    case ocrTimeout = "OCR_TIMEOUT"
    case ocrNoText = "OCR_NO_TEXT"
    case ocrEngineError = "OCR_ENGINE_ERROR"
}

public struct AppError: Error, Equatable, Sendable {
    public enum Kind: Equatable, Sendable {
        case userFacing(String)
    }

    public let kind: Kind
    public let reasonCode: ImportReasonCode

    public init(kind: Kind, reasonCode: ImportReasonCode) {
        self.kind = kind
        self.reasonCode = reasonCode
    }
}
