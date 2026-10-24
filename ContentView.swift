import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack { ScanView() }
                .tabItem { Label("Scan", systemImage: "camera.viewfinder") }

            NavigationStack { RewardsView() }
                .tabItem { Label("Rewards", systemImage: "leaf.circle") }

            NavigationStack { PickupView() }
                .tabItem { Label("Pickup", systemImage: "map") }
        }
        .tint(.green)
    }
}
