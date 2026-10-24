import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

enum AIDeviceGuesser {
    @MainActor
    static func guess(labels: [String], ocr: String?) async -> DeviceType? {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            return await FoundationDeviceGuesser.guess(labels: labels, ocr: ocr)
        }
        #endif
        return nil
    }
}

#if canImport(FoundationModels)
@available(iOS 26.0, *)
@Generable
struct DeviceGuess {
    @Guide(description: "One of: Mobile Phone, Laptop, Router, Circuit Board, Battery, Desktop PC, Tablet, Monitor, Television, Printer, Keyboard, Mouse, Headphones, Speaker, Camera, Game Console, Power Supply, Cables & Chargers, Set-top Box, Smartwatch, Hard Drive, UPS / Inverter, Unknown")
    var device: String

    @Guide(description: "Confidence between 0 and 1")
    var confidence: Double
}

@available(iOS 26.0, *)
enum FoundationDeviceGuesser {
    @MainActor
    static func guess(labels: [String], ocr: String?) async -> DeviceType? {
        let model = SystemLanguageModel.default
        guard case .available = model.availability else { return nil }

        let text = String((ocr ?? "").prefix(1500))
        let labelList = labels.prefix(10).joined(separator: ", ")

        let session = LanguageModelSession(
            model: model,
            instructions: """
            You identify electronic waste from a photo. Use only the vision labels \
            and the text printed on the device. Answer with the single best device \
            type, or Unknown when the evidence is weak. Never invent a model number.
            """
        )

        do {
            let response = try await session.respond(
                to: "Vision labels: \(labelList)\nText on device: \(text.isEmpty ? "none" : text)",
                generating: DeviceGuess.self
            )
            let result = response.content
            guard result.confidence >= 0.5 else { return nil }
            if let direct = DeviceType.fromGeminiID(result.device) { return direct }
            return EstimateEngine.match(label: result.device)
        } catch {
            return nil
        }
    }
}
#endif
