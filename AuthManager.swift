import SwiftUI
import Observation

// The three kinds of people who use the app
enum UserRole: String, CaseIterable, Identifiable {
    case admin = "Admin"
    case user = "User"
    case collector = "Collector"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .admin: return "shield.lefthalf.filled"
        case .user: return "person.fill"
        case .collector: return "truck.box.fill"
        }
    }

    var blurb: String {
        switch self {
        case .admin: return "Monitors drop-offs and drop-boxes"
        case .user: return "Scans gadgets and earns tokens"
        case .collector: return "Picks up from drop-boxes"
        }
    }
}

struct DummyAccount: Identifiable {
    let name: String
    let email: String
    let password: String
    let role: UserRole
    var id: String { email }
}

// DEMO ONLY. These credentials are hard-coded and checked on the phone.
// Replace with a real backend (Firebase Auth, your own API, ...) before shipping.
@Observable
final class AuthManager {
    static let accounts: [DummyAccount] = [
        DummyAccount(name: "Campus Admin", email: "admin@etrace.app", password: "admin123", role: .admin),
        DummyAccount(name: "Mradul", email: "user@etrace.app", password: "user123", role: .user),
        DummyAccount(name: "Ravi (Collector)", email: "collector@etrace.app", password: "pick123", role: .collector)
    ]

    private static let sessionKey = "etrace.session.email"

    private(set) var currentAccount: DummyAccount?

    init() {
        // Keep the user signed in across launches
        if let saved = UserDefaults.standard.string(forKey: Self.sessionKey) {
            currentAccount = Self.accounts.first { $0.email == saved }
        }
    }

    /// Returns an error message, or nil on success.
    @discardableResult
    func login(email: String, password: String) -> String? {
        let cleaned = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !cleaned.isEmpty, !password.isEmpty else {
            return "Enter your email and password."
        }
        guard let account = Self.accounts.first(where: { $0.email == cleaned && $0.password == password }) else {
            return "Wrong email or password."
        }
        currentAccount = account
        UserDefaults.standard.set(account.email, forKey: Self.sessionKey)
        return nil
    }

    func logout() {
        currentAccount = nil
        UserDefaults.standard.removeObject(forKey: Self.sessionKey)
    }
}
