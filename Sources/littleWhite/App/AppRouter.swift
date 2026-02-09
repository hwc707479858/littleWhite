public enum AppRoute: Equatable {
    case importFlow
}

public struct AppRouter {
    public private(set) var currentRoute: AppRoute

    public init(initialRoute: AppRoute = .importFlow) {
        self.currentRoute = initialRoute
    }

    public mutating func navigate(to route: AppRoute) {
        currentRoute = route
    }
}
