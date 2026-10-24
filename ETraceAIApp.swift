import SwiftUI
import SwiftData

@main
struct ETraceAIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Creates the on-device database for the rewards wallet
        .modelContainer(for: DropOff.self)
    }
}
