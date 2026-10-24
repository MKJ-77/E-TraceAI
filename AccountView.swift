import SwiftUI

struct AccountView: View {
    @Environment(AuthManager.self) private var auth

    var body: some View {
        List {
            if let account = auth.currentAccount {
                Section {
                    HStack(spacing: 14) {
                        Image(systemName: account.role.icon)
                            .font(.title)
                            .foregroundStyle(.green)
                            .frame(width: 40)
                        VStack(alignment: .leading) {
                            Text(account.name).font(.headline)
                            Text(account.email).font(.footnote).foregroundStyle(.secondary)
                            Text(account.role.rawValue).font(.footnote).foregroundStyle(.green)
                        }
                    }
                }
            }
            Section {
                Button("Sign out", role: .destructive) { auth.logout() }
            }
        }
        .navigationTitle("Account")
    }
}
