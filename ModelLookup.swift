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
            keywords: ["tata sky", "tata play", "dish tv", "d2h", "airtel digital", "jio stb",
                       "jio set top", "set top box", "set-top box", "dth box", "cable box",
                       "apple tv", "fire tv", "chromecast", "roku"],
            device: .setTopBox,
            name: "Set-top box",
            parts: nil
        ),
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
            keywords: ["jiofi", "jio fi", "jiofiber", "jio fiber", "airtel 4g", "airtel hotspot",
                       "modem", "wi-fi router", "wifi router", "router"],
            device: .router,
            name: "Network router or modem",
            parts: nil
        ),
        Entry(
            keywords: ["macbook", "thinkpad", "ideapad", "chromebook", "ultrabook", "vivobook",
                       "inspiron", "latitude", "xps", "pavilion", "aspire", "zenbook",
                       "surface laptop", "galaxy book", "redmibook", "mi notebook", "realme book",
                       "laptop", "notebook computer"],
            device: .laptop,
            name: "Laptop",
            parts: nil
        ),
        Entry(
            keywords: ["ipad", "galaxy tab", "surface pro", "lenovo tab", "mi pad", "realme pad",
                       "redmi pad", "xiaomi pad", "oneplus pad", "oppo pad", "vivo pad", "tablet"],
            device: .tablet,
            name: "Tablet",
            parts: nil
        ),
        Entry(
            keywords: ["apple watch", "galaxy watch", "oneplus watch", "realme watch", "redmi watch",
                       "oppo watch", "fitbit", "amazfit", "mi band", "garmin", "smartwatch", "smart watch"],
            device: .smartwatch,
            name: "Smartwatch",
            parts: nil
        ),
        Entry(
            keywords: ["bravia", "smart tv", "led tv", "lcd tv", "oled tv", "qled", "television", " tv ", "tv"],
            device: .television,
            name: "Television",
            parts: nil
        ),
        Entry(
            keywords: ["headphone", "earphone", "earbud", "airpods", "buds", "headset",
                       "wh-1000", "quietcomfort", "enco"],
            device: .headphones,
            name: "Headphones",
            parts: nil
        ),
        Entry(
            keywords: ["soundbar", "speaker", "boombox", "homepod", "echo dot", "echo show"],
            device: .speaker,
            name: "Speaker",
            parts: nil
        ),
        Entry(
            keywords: ["iphone"],
            device: .phone,
            name: "Apple iPhone",
            parts: [
                Part(name: "Circuit board", grams: 26, material: .circuitBoard),
                Part(name: "Lithium battery", grams: 42, material: .lithiumCells),
                Part(name: "Display", grams: 48, material: .displayGlass)
            ]
        ),
        Entry(
            keywords: ["samsung galaxy", "galaxy s", "galaxy note", "galaxy a", "galaxy m",
                       "galaxy z", "redmi", "realme", "oneplus", "poco", "vivo", "oppo",
                       "moto", "pixel", "nothing phone", "android phone", "smartphone",
                       "mobile phone", "iqoo", "infinix", "tecno", "lava", "micromax",
                       "honor", "nokia", "zenfone", "phone"],
            device: .phone,
            name: "Android phone",
            parts: [
                Part(name: "Circuit board", grams: 24, material: .circuitBoard),
                Part(name: "Lithium battery", grams: 44, material: .lithiumCells),
                Part(name: "Display", grams: 46, material: .displayGlass)
            ]
        ),
        Entry(
            keywords: ["monitor", "ultrawide", "computer screen"],
            device: .monitor,
            name: "Monitor",
            parts: nil
        ),
        Entry(
            keywords: ["laserjet", "inkjet", "deskjet", "pixma", "ecotank", "printer"],
            device: .printer,
            name: "Printer",
            parts: nil
        ),
        Entry(
            keywords: ["keyboard", "keypad"],
            device: .keyboard,
            name: "Keyboard",
            parts: nil
        ),
        Entry(
            keywords: ["mouse", "trackpad", "trackball"],
            device: .mouse,
            name: "Mouse",
            parts: nil
        ),
        Entry(
            keywords: ["dslr", "mirrorless", "gopro", "webcam", "digital camera", "canon eos", "nikon", "camera"],
            device: .camera,
            name: "Camera",
            parts: nil
        ),
        Entry(
            keywords: ["playstation", "xbox", "nintendo switch", "nintendo", "game console", "gaming console"],
            device: .gameConsole,
            name: "Game console",
            parts: nil
        ),
        Entry(
            keywords: ["seagate", "western digital", "wd elements", "hard drive", "hard disk",
                       "hdd", "ssd", "solid state drive"],
            device: .hardDrive,
            name: "Hard drive",
            parts: nil
        ),
        Entry(
            keywords: ["uninterruptible", "inverter", "microtek", "luminous", "apc ", " ups", "ups"],
            device: .ups,
            name: "UPS or inverter",
            parts: nil
        ),
        Entry(
            keywords: ["smps", "power supply", "power adapter", "adapter", "charger", "power brick"],
            device: .powerSupply,
            name: "Power supply",
            parts: nil
        ),
        Entry(
            keywords: ["usb cable", "hdmi cable", "power cord", "charging cable", "lightning cable",
                       "type-c cable", "cable"],
            device: .cables,
            name: "Cables and chargers",
            parts: nil
        ),
        Entry(
            keywords: ["lithium", "li-ion", "li ion", "power bank", "powerbank", "battery pack", "battery"],
            device: .battery,
            name: "Lithium battery pack",
            parts: [
                Part(name: "Lithium cells", grams: 120, material: .lithiumCells),
                Part(name: "Copper wiring", grams: 8, material: .copper),
                Part(name: "Plastic casing", grams: 20, material: .plastic)
            ]
        ),
        Entry(
            keywords: ["pcb", "motherboard", "circuit board", "mainboard", "electronic board"],
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
