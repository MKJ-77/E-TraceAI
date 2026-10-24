import Foundation
import UIKit

struct GeminiGuess {
    let device: DeviceType
    let modelName: String?
    let condition: Condition?
    let confidence: Double
    let reason: String?
}

struct GeminiClassification {
    let guess: GeminiGuess?
    let note: String?
    var usedFallback: Bool = false
}

enum GeminiClassifier {
    private static let endpoint = "https://generativelanguage.googleapis.com/v1beta/interactions"
    private static let fallbackModel = "gemini-3.6-flash"

    private static let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 120
        return URLSession(configuration: config)
    }()

    @MainActor
    static func classify(_ image: UIImage, hint: String? = nil, modelOverride: String? = nil) async -> GeminiClassification {
        let model = modelOverride ?? Secrets.geminiModel
        let result = await perform(image, hint: hint, model: model)

        guard modelOverride == nil,
              result.guess == nil,
              model.contains("gemini-3") || model.contains("gemini-4"),
              shouldRetry(result.note) else {
            return result
        }

        let fallback = await perform(image, hint: hint, model: fallbackModel)
        guard fallback.guess != nil else { return result }
        return GeminiClassification(guess: fallback.guess, note: nil, usedFallback: true)
    }

    @MainActor
    private static func perform(_ image: UIImage, hint: String?, model: String) async -> GeminiClassification {
        guard let apiKey = Secrets.geminiAPIKey else {
            return GeminiClassification(
                guess: nil,
                note: "Gemini key missing. Add GEMINI_API_KEY to Secrets.plist and include Secrets.plist in Copy Bundle Resources."
            )
        }
        guard let jpeg = preparedJPEG(from: image) else {
            return GeminiClassification(guess: nil, note: "Could not read the selected image.")
        }
        guard let url = URL(string: endpoint) else {
            return GeminiClassification(guess: nil, note: "Invalid Gemini endpoint.")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")
        request.setValue("2026-05-20", forHTTPHeaderField: "Api-Revision")

        let body: [String: Any] = [
            "model": model,
            "input": [
                ["type": "text", "text": userPrompt(hint: hint)],
                ["type": "image", "data": jpeg.base64EncodedString(), "mime_type": "image/jpeg"]
            ],
            "system_instruction": systemPrompt,
            "response_format": [
                "type": "text",
                "mime_type": "application/json",
                "schema": responseSchema
            ],
            "generation_config": generationConfig(for: model)
        ]

        let started = Date()
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, response) = try await session.data(for: request)
            let elapsed = formatted(Date().timeIntervalSince(started))

            guard let http = response as? HTTPURLResponse else {
                return GeminiClassification(
                    guess: nil,
                    note: "Gemini returned an unexpected network response after \(elapsed)s (model \(model))."
                )
            }
            guard (200..<300).contains(http.statusCode) else {
                let detail = String(data: data, encoding: .utf8)?.prefix(600) ?? ""
                return GeminiClassification(
                    guess: nil,
                    note: "Gemini HTTP \(http.statusCode) after \(elapsed)s (model \(model)): \(detail)"
                )
            }

            guard let text = extractText(from: data) else {
                let raw = String(data: data, encoding: .utf8)?.prefix(600) ?? ""
                return GeminiClassification(
                    guess: nil,
                    note: "Gemini returned no text after \(elapsed)s (model \(model)). Raw response: \(raw)"
                )
            }
            guard let guess = parse(text) else {
                return GeminiClassification(
                    guess: nil,
                    note: "Could not read Gemini's JSON after \(elapsed)s (model \(model)): \(text.prefix(400))"
                )
            }
            return GeminiClassification(guess: guess, note: nil)
        } catch {
            let elapsed = formatted(Date().timeIntervalSince(started))
            if let urlError = error as? URLError, urlError.code == .timedOut {
                return GeminiClassification(
                    guess: nil,
                    note: "Gemini timed out after \(elapsed)s (model \(model)). Check internet/VPN/proxy, then tap Test connection."
                )
            }
            return GeminiClassification(
                guess: nil,
                note: "Gemini request failed after \(elapsed)s (model \(model)): \(error.localizedDescription)"
            )
        }
    }

    @MainActor
    static func ping(model: String? = nil) async -> String {
        guard let apiKey = Secrets.geminiAPIKey else {
            return "No API key found in Secrets.plist."
        }
        let name = model ?? Secrets.geminiModel
        guard let url = URL(string: endpoint) else {
            return "Invalid Gemini endpoint."
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 20
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")
        request.setValue("2026-05-20", forHTTPHeaderField: "Api-Revision")

        let body: [String: Any] = [
            "model": name,
            "input": "Reply with the single word OK.",
            "generation_config": [
                "thinking_level": "low",
                "max_output_tokens": 16
            ]
        ]

        let started = Date()
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, response) = try await session.data(for: request)
            let elapsed = formatted(Date().timeIntervalSince(started))

            guard let http = response as? HTTPURLResponse else {
                return "Unexpected response after \(elapsed)s."
            }
            if (200..<300).contains(http.statusCode) {
                let text = extractText(from: data) ?? "(no text)"
                return "Connection OK: HTTP \(http.statusCode) in \(elapsed)s using \(name). Reply: \(text.prefix(80))"
            }
            let detail = String(data: data, encoding: .utf8)?.prefix(600) ?? ""
            return "HTTP \(http.statusCode) in \(elapsed)s using \(name): \(detail)"
        } catch {
            return "Failed after \(formatted(Date().timeIntervalSince(started)))s using \(name): \(error.localizedDescription)"
        }
    }

    private static func generationConfig(for model: String) -> [String: Any] {
        var config: [String: Any] = ["max_output_tokens": 512]
        if model.contains("gemini-3") || model.contains("gemini-4") {
            config["thinking_level"] = "low"
        }
        return config
    }

    private static let systemPrompt = """
    You identify electronic waste from a photo. Choose exactly one device id:
    \(DeviceType.allCases.map(\.geminiID).joined(separator: ", ")), or unknown.
    Estimate the visible condition as intact, damaged, or crushed. Only set
    modelName when the model is clearly readable in the image or hint. Never
    invent a model number. Use unknown when the photo does not clearly show an
    electronic device.
    """

    private static func userPrompt(hint: String?) -> String {
        let text = String((hint ?? "").prefix(1500))
        let hintLine = text.isEmpty ? "No readable text was found." : "Text found on the device: \(text)"
        return "\(hintLine)\nClassify the device in the attached photo."
    }

    private static let responseSchema: [String: Any] = [
        "type": "object",
        "properties": [
            "device": [
                "type": "string",
                "enum": DeviceType.allCases.map(\.geminiID) + ["unknown"]
            ],
            "modelName": ["type": "string"],
            "condition": [
                "type": "string",
                "enum": ["intact", "damaged", "crushed"]
            ],
            "confidence": ["type": "number"],
            "reason": ["type": "string"]
        ],
        "required": ["device", "condition", "confidence"]
    ]

    private static func parse(_ text: String) -> GeminiGuess? {
        let cleaned = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = cleaned.data(using: .utf8),
              let payload = try? JSONDecoder().decode(GeminiPayload.self, from: data),
              let device = device(from: payload.device) else {
            return nil
        }

        return GeminiGuess(
            device: device,
            modelName: optional(payload.modelName),
            condition: condition(from: payload.condition),
            confidence: payload.confidence,
            reason: optional(payload.reason)
        )
    }

    private static func extractText(from data: Data) -> String? {
        guard let object = try? JSONSerialization.jsonObject(with: data) else { return nil }
        if let dict = object as? [String: Any],
           let output = dict["output_text"] as? String,
           !output.isEmpty {
            return output
        }

        var texts: [String] = []
        collectText(from: object, into: &texts)
        return texts.last
    }

    private static func collectText(from value: Any, into texts: inout [String]) {
        if let dict = value as? [String: Any] {
            if let type = dict["type"] as? String, type == "thought" { return }
            if let text = dict["text"] as? String, !text.isEmpty {
                texts.append(text)
            }
            for key in ["output", "outputs", "steps", "content", "parts", "response"] {
                if let child = dict[key] {
                    collectText(from: child, into: &texts)
                }
            }
        } else if let array = value as? [Any] {
            for item in array {
                collectText(from: item, into: &texts)
            }
        }
    }

    private static func shouldRetry(_ note: String?) -> Bool {
        guard let note else { return false }
        return note.contains("timed out")
            || note.contains("HTTP 5")
            || note.contains("no text")
            || note.contains("request failed")
    }

    private static func device(from raw: String) -> DeviceType? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.lowercased() != "unknown" else { return nil }

        if let direct = DeviceType.fromGeminiID(trimmed) { return direct }
        if let exact = DeviceType(rawValue: trimmed) { return exact }
        return EstimateEngine.match(label: trimmed)
    }

    private static func condition(from raw: String?) -> Condition? {
        switch raw?.lowercased() {
        case "intact": return .intact
        case "damaged": return .damaged
        case "crushed", "badly broken": return .crushed
        default: return nil
        }
    }

    private static func optional(_ value: String?) -> String? {
        guard let value, !value.isEmpty else { return nil }
        return value
    }

    private static func formatted(_ seconds: TimeInterval) -> String {
        String(format: "%.1f", seconds)
    }

    private static func preparedJPEG(from image: UIImage, maxDimension: CGFloat = 1024) -> Data? {
        let longest = max(image.size.width, image.size.height)
        guard longest > 0 else { return nil }

        let scale = min(1, maxDimension / longest)
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return resized.jpegData(compressionQuality: 0.8)
    }

    private struct GeminiPayload: Decodable {
        let device: String
        let modelName: String?
        let condition: String?
        let confidence: Double
        let reason: String?
    }
}
