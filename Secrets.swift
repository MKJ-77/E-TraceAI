import Foundation

enum Secrets {
    static var geminiAPIKey: String? {
        value(for: "GEMINI_API_KEY", environment: "GEMINI_API_KEY")
    }

    static var geminiModel: String {
        value(for: "GEMINI_MODEL", environment: "GEMINI_MODEL") ?? "gemini-3.8-flash"
    }

    private static func value(for key: String, environment: String) -> String? {
        if let env = ProcessInfo.processInfo.environment[environment]?
            .trimmingCharacters(in: .whitespacesAndNewlines),
           !env.isEmpty {
            return env
        }
        guard let url = secretsURL(),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
              let value = plist[key] as? String else {
            return nil
        }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private static func secretsURL() -> URL? {
        if let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist") {
            return url
        }
        guard let root = Bundle.main.resourceURL,
              let files = FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil) else {
            return nil
        }
        for case let url as URL in files where url.lastPathComponent == "Secrets.plist" {
            return url
        }
        return nil
    }
}
