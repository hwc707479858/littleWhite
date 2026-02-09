import SwiftUI

@main
struct littleWhiteApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: DemoOCRScreenViewModel())
        }
    }
}
