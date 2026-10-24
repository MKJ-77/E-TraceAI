import SwiftUI

struct LoginView: View {
    @Environment(AuthManager.self) private var auth

    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @FocusState private var focused: Field?

    private enum Field { case email, password }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(spacing: 8) {
                        Image(systemName: "leaf.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(.green)
                        Text("E-Trace AI")
                            .font(.largeTitle.bold())
                        Text("Sign in to continue")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color.clear)

                Section {
                    TextField("Email", text: $email)
                        .textContentType(.username)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($focused, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focused = .password }

                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .focused($focused, equals: .password)
                        .submitLabel(.go)
                        .onSubmit(signIn)

                    if let errorMessage {
                        Label(errorMessage, systemImage: "exclamationmark.triangle")
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }

                    Button(action: signIn) {
                        Text("Sign in").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }

                Section("Demo accounts (tap to fill)") {
                    ForEach(AuthManager.accounts) { account in
                        Button {
                            email = account.email
                            password = account.password
                            errorMessage = nil
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: account.role.icon)
                                    .frame(width: 28)
                                    .foregroundStyle(.green)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(account.role.rawValue).font(.headline)
                                    Text(account.role.blurb)
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                    Text("\(account.email) · \(account.password)")
                                        .font(.system(.caption, design: .monospaced))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }

    private func signIn() {
        focused = nil
        errorMessage = auth.login(email: email, password: password)
    }
}
