import SwiftUI
import SwiftData

@main
struct ETraceAIApp: App {
    @State private var auth = AuthManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(auth)
        }
        // Creates the on-device database for the rewards wallet
        .modelContainer(for: DropOff.self)
    }
}
