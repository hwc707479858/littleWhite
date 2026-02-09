import Foundation

@MainActor
public final class ImportViewModel {
    public enum State: Equatable {
        case idle
        case importing
        case imported(ImportedReport)
        case failed(String)
    }

    public private(set) var state: State = .idle
    private let useCase: ImportUseCase

    public init(useCase: ImportUseCase) {
        self.useCase = useCase
    }

    public func startImport(tracker: ImportEventTracker? = nil) async {
        tracker?.trackStarted()
        state = .importing
        do {
            state = .imported(try await useCase.execute())
            tracker?.trackSucceeded()
        } catch let appError as AppError {
            tracker?.trackFailed(reasonCode: appError.reasonCode)
            state = .failed("导入失败")
        } catch {
            tracker?.trackFailed(reasonCode: .pickerError)
            state = .failed("导入失败")
        }
    }
}
