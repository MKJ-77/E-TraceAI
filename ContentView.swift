import SwiftUI

struct ContentView: View {
    @Environment(AuthManager.self) private var auth

    var body: some View {
        Group {
            if let account = auth.currentAccount {
                switch account.role {
                case .user: userTabs
                case .collector: collectorTabs
                case .admin: adminTabs
                }
            } else {
                LoginView()
            }
        }
        .tint(.green)
    }

    private var userTabs: some View {
        TabView {
            NavigationStack { ScanView() }
                .tabItem { Label("Scan", systemImage: "camera.viewfinder") }
            NavigationStack { RewardsView() }
                .tabItem { Label("Rewards", systemImage: "leaf.circle") }
            NavigationStack { AccountView() }
                .tabItem { Label("Account", systemImage: "person.crop.circle") }
        }
    }

    private var collectorTabs: some View {
        TabView {
            NavigationStack { PickupView() }
                .tabItem { Label("Route", systemImage: "map") }
            NavigationStack { CollectorView() }
                .tabItem { Label("Collect", systemImage: "checkmark.seal") }
            NavigationStack { AccountView() }
                .tabItem { Label("Account", systemImage: "person.crop.circle") }
        }
    }

    private var adminTabs: some View {
        TabView {
            NavigationStack { AdminView() }
                .tabItem { Label("Dashboard", systemImage: "chart.bar") }
            NavigationStack { PickupView() }
                .tabItem { Label("Drop-boxes", systemImage: "map") }
            NavigationStack { AccountView() }
                .tabItem { Label("Account", systemImage: "person.crop.circle") }
        }
    }
}
