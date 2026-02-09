import Foundation

public struct ImportFormatValidator {
    public init() {}

    public func validate(mimeType: String) throws -> SupportedReportFormat {
        guard let format = SupportedReportFormat.detect(fromMimeType: mimeType) else {
            throw AppError(kind: .userFacing("仅支持 JPG/PNG/PDF 文件"), reasonCode: .unsupportedFormat)
        }
        return format
    }
}

public protocol OCRTriggering {
    @MainActor
    func triggerOCR(for report: ImportedReport) async
}

public struct NoopOCRTrigger: OCRTriggering {
    public init() {}
    @MainActor
    public func triggerOCR(for report: ImportedReport) async {}
}

@MainActor
public final class ImportFlowOrchestrator {
    private let validator: ImportFormatValidator
    private let ocrTrigger: OCRTriggering
    private let eventTracker: ImportEventTracker?

    public private(set) var lastError: AppError?

    public init(
        validator: ImportFormatValidator,
        ocrTrigger: OCRTriggering,
        eventTracker: ImportEventTracker? = nil
    ) {
        self.validator = validator
        self.ocrTrigger = ocrTrigger
        self.eventTracker = eventTracker
    }

    public func handleImportedFile(url: URL, mimeType: String) async {
        eventTracker?.trackStarted()
        do {
            let format = try validator.validate(mimeType: mimeType)
            let sourceType: ImportSourceType = (format == .pdf) ? .pdf : .photo
            let report = ImportedReport(sourceType: sourceType, mimeType: mimeType, localURL: url)
            lastError = nil
            await ocrTrigger.triggerOCR(for: report)
            eventTracker?.trackSucceeded()
        } catch let appError as AppError {
            lastError = appError
            eventTracker?.trackFailed(reasonCode: appError.reasonCode)
        } catch {
            let appError = AppError(kind: .userFacing("导入失败"), reasonCode: .pickerError)
            lastError = appError
            eventTracker?.trackFailed(reasonCode: appError.reasonCode)
        }
    }
}
