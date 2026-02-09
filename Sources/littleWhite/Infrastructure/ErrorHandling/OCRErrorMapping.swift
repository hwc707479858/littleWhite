import Foundation

public enum OCREngineError: Error, Equatable, Sendable {
    case timeout
    case noText
    case engine
}

public enum OCRErrorMapper {
    public static func map(_ error: OCREngineError) -> AppError {
        switch error {
        case .timeout:
            return AppError(kind: .userFacing("OCR 识别超时，请重试"), reasonCode: .ocrTimeout)
        case .noText:
            return AppError(kind: .userFacing("未识别到可用文本"), reasonCode: .ocrNoText)
        case .engine:
            return AppError(kind: .userFacing("OCR 引擎异常，请稍后重试"), reasonCode: .ocrEngineError)
        }
    }

    public static func mapAny(_ error: Error) -> AppError {
        if let engine = error as? OCREngineError {
            return map(engine)
        }
        if let appError = error as? AppError {
            return appError
        }
        return AppError(kind: .userFacing("OCR 识别失败"), reasonCode: .ocrEngineError)
    }
}
