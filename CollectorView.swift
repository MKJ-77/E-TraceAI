import SwiftUI

// Where the collector confirms a hand-over. In the real app this would scan the
// user's QR code with the camera; for the demo you paste or type the code.
struct CollectorView: View {
    private struct Collected: Identifiable {
        let id = UUID()
        let device: String
        let code: String
        let date: Date
    }

    @State private var code = ""
    @State private var message: String?
    @State private var messageIsError = false
    @State private var collected: [Collected] = []

    var body: some View {
        List {
            Section("Confirm a drop-off") {
                TextField("etrace://estimate/...", text: $code)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .font(.system(.footnote, design: .monospaced))

                Button {
                    confirm()
                } label: {
                    Label("Mark as collected", systemImage: "checkmark.seal")
                }
                .disabled(code.trimmingCharacters(in: .whitespaces).isEmpty)

                if let message {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(messageIsError ? .red : .green)
                }
                Text("Ask the user to show their drop-off QR code. Camera scanning can be added later.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Collected this session") {
                if collected.isEmpty {
                    Text("Nothing collected yet.").foregroundStyle(.secondary)
                }
                ForEach(collected) { item in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.device).font(.headline)
                        Text("\(item.date.formatted(date: .omitted, time: .shortened)) · \(item.code.prefix(8))...")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Collect")
    }

    private func confirm() {
        let raw = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let comps = URLComponents(string: raw),
              comps.scheme == "etrace",
              comps.host == "estimate",
              let uuid = UUID(uuidString: comps.path.replacingOccurrences(of: "/", with: "")) else {
            message = "That is not a valid E-Trace code."
            messageIsError = true
            return
        }
        if collected.contains(where: { $0.code == uuid.uuidString }) {
            message = "This code was already collected."
            messageIsError = true
            return
        }
        let device = comps.queryItems?.first { $0.name == "item" }?.value ?? "Device"
        collected.insert(Collected(device: device, code: uuid.uuidString, date: Date()), at: 0)
        message = "Collected: \(device)"
        messageIsError = false
        code = ""
    }
}
