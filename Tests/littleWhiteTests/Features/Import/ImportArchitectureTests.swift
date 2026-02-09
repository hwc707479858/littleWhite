import Testing
@testable import littleWhite

struct ImportArchitectureTests {
    @Test
    @MainActor
    func importModuleSkeletonExists() {
        let repository = InMemoryImportRepository()
        let useCase = ImportReportUseCase(repository: repository)
        let viewModel = ImportViewModel(useCase: useCase)

        #expect(viewModel.state == .idle)
    }

    @Test
    func appRouterContainsImportRoute() {
        let router = AppRouter()
        #expect(router.currentRoute == .importFlow)
    }
}
