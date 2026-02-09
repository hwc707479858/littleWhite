import Foundation

public struct ImportView {
    public let viewModel: ImportViewModel

    public init(viewModel: ImportViewModel) {
        self.viewModel = viewModel
    }

    public func titleText() -> String {
        "报告导入"
    }
}
