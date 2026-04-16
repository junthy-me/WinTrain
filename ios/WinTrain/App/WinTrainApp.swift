import SwiftUI

@main
struct WinTrainApp: App {
    @StateObject private var environment = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(environment)
        }
    }
}
