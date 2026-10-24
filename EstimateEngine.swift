import Foundation

// ---------- The "rate card" ----------
// PLACEHOLDER numbers in rupees per kg. In the pitch, the recycler partner owns this table.
// Replace with real rates before showing anyone a price.
enum Material {
    case copper, circuitBoard, plastic, lithiumCells, displayGlass

    var name: String {
        switch self {
        case .copper: return "Copper"
        case .circuitBoard: return "Circuit board"
        case .plastic: return "Plastic"
        case .lithiumCells: return "Lithium cells"
        case .displayGlass: return "Display glass"
        }
    }

    var ratePerKg: Double {
        switch self {
        case .copper: return 600
        case .circuitBoard: return 400
        case .plastic: return 15
        case .lithiumCells: return 100
        case .displayGlass: return 20
        }
    }
}

struct Part: Identifiable {
    let id = UUID()
    let name: String
    let grams: Double
    let material: Material
}

// ---------- The "label to parts" table (slide 6) ----------
enum DeviceType: String, CaseIterable, Identifiable {
    case router = "Router"
    case phone = "Mobile Phone"
    case circuitBoard = "Circuit Board"
    case battery = "Battery"

    var id: String { rawValue }

    // Typical device profile. Weights are rough placeholders.
    var parts: [Part] {
        switch self {
        case .router:
            return [
                Part(name: "Circuit board", grams: 120, material: .circuitBoard),
                Part(name: "Copper wiring", grams: 60, material: .copper),
                Part(name: "Plastic casing", grams: 150, material: .plastic)
            ]
        case .phone:
            return [
                Part(name: "Circuit board", grams: 25, material: .circuitBoard),
                Part(name: "Lithium battery", grams: 40, material: .lithiumCells),
                Part(name: "Display", grams: 45, material: .displayGlass)
            ]
        case .circuitBoard:
            return [
                Part(name: "PCB and solder", grams: 100, material: .circuitBoard),
                Part(name: "Copper traces", grams: 20, material: .copper)
            ]
        case .battery:
            return [
                Part(name: "Lithium cells", grams: 45, material: .lithiumCells)
            ]
        }
    }

    var note: String {
        switch self {
        case .battery: return "Batteries are handled separately by the recycler."
        default: return ""
        }
    }
}

enum Condition: String, CaseIterable, Identifiable {
    case intact = "Intact"
    case damaged = "Damaged"
    case crushed = "Badly broken"

    var id: String { rawValue }

    var factor: Double {
        switch self {
        case .intact: return 1.0
        case .damaged: return 0.8
        case .crushed: return 0.6
        }
    }
}

struct EstimateResult {
    let device: DeviceType
    let condition: Condition
    let low: Int
    let high: Int
}

enum EstimateEngine {
    // Photos below this confidence make the app ask the user to confirm the device type.
    // The deck says 70%. Apple's classifier spreads confidence over many labels,
    // so start lower and tune it after testing on real photos.
    static let minConfidence: Float = 0.30

    // Value = sum(part weight x material rate) x condition factor, shown as a range
    static func estimate(device: DeviceType, condition: Condition) -> EstimateResult {
        var base = 0.0
        for part in device.parts {
            base += (part.grams / 1000.0) * part.material.ratePerKg
        }
        let adjusted = base * condition.factor
        let low = Int((adjusted * 0.8).rounded())
        let high = Int((adjusted * 1.2).rounded())
        return EstimateResult(device: device, condition: condition, low: low, high: max(high, low + 1))
    }

    // Turns whatever label Apple's classifier returns into one of our device types.
    // Keyword matching, because we can't know every exact label name in advance.
    static func match(label: String) -> DeviceType? {
        let text = label.lowercased()
        let routerWords = ["router", "modem", "wifi", "wi-fi", "network"]
        let phoneWords = ["phone", "smartphone", "cellular", "mobile", "iphone"]
        let boardWords = ["circuit", "motherboard", "pcb", "electronic", "chip"]
        let batteryWords = ["battery", "batteries"]

        if routerWords.contains(where: { text.contains($0) }) { return .router }
        if phoneWords.contains(where: { text.contains($0) }) { return .phone }
        if batteryWords.contains(where: { text.contains($0) }) { return .battery }
        if boardWords.contains(where: { text.contains($0) }) { return .circuitBoard }
        return nil
    }
}
