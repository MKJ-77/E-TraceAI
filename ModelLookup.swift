import Foundation

struct ModelMatch {
    let device: DeviceType
    let name: String
    let parts: [Part]?
}

enum ModelLookup {
    private struct Entry {
        let keywords: [String]
        let device: DeviceType
        let name: String
        let parts: [Part]?
    }

    private static let entries: [Entry] = [
        Entry(
            keywords: ["archer c6", "archer c50", "archer c20", "archer ax"],
            device: .router,
            name: "TP-Link Archer router",
            parts: [
                Part(name: "Circuit board", grams: 110, material: .circuitBoard),
                Part(name: "Copper wiring", grams: 55, material: .copper),
                Part(name: "Plastic casing", grams: 160, material: .plastic)
            ]
        ),
        Entry(
            keywords: ["tl-wr841", "tl-wr740", "tl-wr940", "tl-wr"],
            device: .router,
            name: "TP-Link TL-WR router",
            parts: [
                Part(name: "Circuit board", grams: 95, material: .circuitBoard),
                Part(name: "Copper wiring", grams: 45, material: .copper),
                Part(name: "Plastic casing", grams: 175, material: .plastic)
            ]
        ),
        Entry(
            keywords: ["jiofi", "jio fi", "airtel", "modem", "wi-fi router"],
            device: .router,
            name: "Network router or modem",
            parts: nil
        ),
        Entry(
            keywords: ["iphone 11", "iphone 12", "iphone 13", "iphone 14", "iphone 15"],
            device: .phone,
            name: "Apple iPhone",
            parts: [
                Part(name: "Circuit board", grams: 26, material: .circuitBoard),
                Part(name: "Lithium battery", grams: 42, material: .lithiumCells),
                Part(name: "Display", grams: 48, material: .displayGlass)
            ]
        ),
        Entry(
            keywords: ["galaxy", "samsung", "redmi", "realme", "oneplus", "poco", "vivo", "oppo", "moto"],
            device: .phone,
            name: "Android phone",
            parts: [
                Part(name: "Circuit board", grams: 24, material: .circuitBoard),
                Part(name: "Lithium battery", grams: 44, material: .lithiumCells),
                Part(name: "Display", grams: 46, material: .displayGlass)
            ]
        ),
        Entry(
            keywords: ["lithium", "li-ion", "li ion", "power bank", "powerbank", "battery pack"],
            device: .battery,
            name: "Lithium battery pack",
            parts: [
                Part(name: "Lithium cells", grams: 120, material: .lithiumCells),
                Part(name: "Copper wiring", grams: 8, material: .copper),
                Part(name: "Plastic casing", grams: 20, material: .plastic)
            ]
        ),
        Entry(
            keywords: ["pcb", "motherboard", "circuit board", "mainboard"],
            device: .circuitBoard,
            name: "Circuit board",
            parts: nil
        )
    ]

    static func match(_ text: String) -> ModelMatch? {
        let lower = text.lowercased()
        guard !lower.isEmpty else { return nil }

        for entry in entries where entry.keywords.contains(where: { lower.contains($0) }) {
            return ModelMatch(device: entry.device, name: entry.name, parts: entry.parts)
        }
        return nil
    }
}
