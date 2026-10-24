import Foundation

enum Material {
    case copper, circuitBoard, plastic, lithiumCells, displayGlass
    case aluminum, steel, preciousMetals, rareEarthMagnets, leadAcid

    var name: String {
        switch self {
        case .copper: return "Copper"
        case .circuitBoard: return "Circuit board"
        case .plastic: return "Plastic"
        case .lithiumCells: return "Lithium cells"
        case .displayGlass: return "Display glass"
        case .aluminum: return "Aluminium"
        case .steel: return "Steel"
        case .preciousMetals: return "Precious metals"
        case .rareEarthMagnets: return "Rare-earth magnets"
        case .leadAcid: return "Lead-acid battery"
        }
    }

    var ratePerKg: Double {
        switch self {
        case .copper: return 850
        case .circuitBoard: return 950
        case .plastic: return 35
        case .lithiumCells: return 320
        case .displayGlass: return 45
        case .aluminum: return 230
        case .steel: return 60
        case .preciousMetals: return 12000
        case .rareEarthMagnets: return 1800
        case .leadAcid: return 110
        }
    }
}

struct Part: Identifiable {
    let id = UUID()
    let name: String
    let grams: Double
    let material: Material
}

enum DeviceType: String, CaseIterable, Identifiable {
    case phone = "Mobile Phone"
    case laptop = "Laptop"
    case router = "Router"
    case circuitBoard = "Circuit Board"
    case battery = "Battery"
    case desktop = "Desktop PC"
    case tablet = "Tablet"
    case monitor = "Monitor"
    case television = "Television"
    case printer = "Printer"
    case keyboard = "Keyboard"
    case mouse = "Mouse"
    case headphones = "Headphones"
    case speaker = "Speaker"
    case camera = "Camera"
    case gameConsole = "Game Console"
    case powerSupply = "Power Supply"
    case cables = "Cables & Chargers"
    case setTopBox = "Set-top Box"
    case smartwatch = "Smartwatch"
    case hardDrive = "Hard Drive"
    case ups = "UPS / Inverter"

    var id: String { rawValue }

    var geminiID: String {
        switch self {
        case .phone: return "phone"
        case .laptop: return "laptop"
        case .router: return "router"
        case .circuitBoard: return "circuitBoard"
        case .battery: return "battery"
        case .desktop: return "desktop"
        case .tablet: return "tablet"
        case .monitor: return "monitor"
        case .television: return "television"
        case .printer: return "printer"
        case .keyboard: return "keyboard"
        case .mouse: return "mouse"
        case .headphones: return "headphones"
        case .speaker: return "speaker"
        case .camera: return "camera"
        case .gameConsole: return "gameConsole"
        case .powerSupply: return "powerSupply"
        case .cables: return "cables"
        case .setTopBox: return "setTopBox"
        case .smartwatch: return "smartwatch"
        case .hardDrive: return "hardDrive"
        case .ups: return "ups"
        }
    }

    static func fromGeminiID(_ raw: String) -> DeviceType? {
        let key = normalizedID(raw)
        if let match = allCases.first(where: { normalizedID($0.geminiID) == key }) {
            return match
        }
        return allCases.first { normalizedID($0.rawValue) == key }
    }

    private static func normalizedID(_ value: String) -> String {
        value.lowercased().filter { $0.isLetter || $0.isNumber }
    }

    var baseValue: Double {
        switch self {
        case .phone: return 700
        case .laptop: return 1800
        case .router: return 150
        case .circuitBoard: return 80
        case .battery: return 60
        case .desktop: return 1500
        case .tablet: return 800
        case .monitor: return 500
        case .television: return 700
        case .printer: return 400
        case .keyboard: return 100
        case .mouse: return 60
        case .headphones: return 150
        case .speaker: return 200
        case .camera: return 900
        case .gameConsole: return 1000
        case .powerSupply: return 100
        case .cables: return 40
        case .setTopBox: return 150
        case .smartwatch: return 400
        case .hardDrive: return 300
        case .ups: return 400
        }
    }

    var parts: [Part] {
        switch self {
        case .phone:
            return [
                Part(name: "Circuit board", grams: 25, material: .circuitBoard),
                Part(name: "Lithium battery", grams: 40, material: .lithiumCells),
                Part(name: "Display", grams: 45, material: .displayGlass),
                Part(name: "Aluminium frame", grams: 25, material: .aluminum),
                Part(name: "Gold and precious metals", grams: 5, material: .preciousMetals),
                Part(name: "Magnets and speakers", grams: 5, material: .rareEarthMagnets)
            ]
        case .laptop:
            return [
                Part(name: "Circuit board", grams: 180, material: .circuitBoard),
                Part(name: "Lithium battery", grams: 220, material: .lithiumCells),
                Part(name: "Display", grams: 250, material: .displayGlass),
                Part(name: "Aluminium chassis", grams: 400, material: .aluminum),
                Part(name: "Copper wiring", grams: 60, material: .copper),
                Part(name: "Gold and precious metals", grams: 10, material: .preciousMetals),
                Part(name: "Magnets and speakers", grams: 15, material: .rareEarthMagnets)
            ]
        case .router:
            return [
                Part(name: "Circuit board", grams: 120, material: .circuitBoard),
                Part(name: "Copper wiring", grams: 60, material: .copper),
                Part(name: "Plastic casing", grams: 150, material: .plastic),
                Part(name: "Aluminium heatsink", grams: 30, material: .aluminum),
                Part(name: "Steel parts", grams: 20, material: .steel)
            ]
        case .circuitBoard:
            return [
                Part(name: "PCB and solder", grams: 100, material: .circuitBoard),
                Part(name: "Copper traces", grams: 20, material: .copper),
                Part(name: "Gold and precious metals", grams: 8, material: .preciousMetals),
                Part(name: "Aluminium heatsink", grams: 10, material: .aluminum)
            ]
        case .battery:
            return [
                Part(name: "Lithium cells", grams: 45, material: .lithiumCells),
                Part(name: "Copper wiring", grams: 5, material: .copper),
                Part(name: "Plastic casing", grams: 10, material: .plastic)
            ]
        case .desktop:
            return [
                Part(name: "Circuit board", grams: 350, material: .circuitBoard),
                Part(name: "Copper wiring", grams: 80, material: .copper),
                Part(name: "Steel chassis", grams: 1500, material: .steel),
                Part(name: "Aluminium heatsink", grams: 300, material: .aluminum),
                Part(name: "Gold and precious metals", grams: 15, material: .preciousMetals),
                Part(name: "Plastic casing", grams: 200, material: .plastic)
            ]
        case .tablet:
            return [
                Part(name: "Circuit board", grams: 40, material: .circuitBoard),
                Part(name: "Lithium battery", grams: 60, material: .lithiumCells),
                Part(name: "Display", grams: 120, material: .displayGlass),
                Part(name: "Aluminium frame", grams: 80, material: .aluminum),
                Part(name: "Gold and precious metals", grams: 5, material: .preciousMetals)
            ]
        case .monitor:
            return [
                Part(name: "Circuit board", grams: 80, material: .circuitBoard),
                Part(name: "Display glass", grams: 900, material: .displayGlass),
                Part(name: "Aluminium parts", grams: 100, material: .aluminum),
                Part(name: "Steel stand", grams: 400, material: .steel),
                Part(name: "Copper wiring", grams: 40, material: .copper),
                Part(name: "Plastic casing", grams: 300, material: .plastic)
            ]
        case .television:
            return [
                Part(name: "Circuit board", grams: 150, material: .circuitBoard),
                Part(name: "Display glass", grams: 1800, material: .displayGlass),
                Part(name: "Aluminium parts", grams: 200, material: .aluminum),
                Part(name: "Steel frame", grams: 500, material: .steel),
                Part(name: "Copper wiring", grams: 60, material: .copper),
                Part(name: "Plastic casing", grams: 800, material: .plastic)
            ]
        case .printer:
            return [
                Part(name: "Circuit board", grams: 60, material: .circuitBoard),
                Part(name: "Plastic casing", grams: 900, material: .plastic),
                Part(name: "Steel frame", grams: 800, material: .steel),
                Part(name: "Copper wiring", grams: 30, material: .copper),
                Part(name: "Aluminium parts", grams: 100, material: .aluminum)
            ]
        case .keyboard:
            return [
                Part(name: "Circuit board", grams: 20, material: .circuitBoard),
                Part(name: "Plastic casing", grams: 250, material: .plastic),
                Part(name: "Steel plate", grams: 100, material: .steel),
                Part(name: "Copper wiring", grams: 5, material: .copper)
            ]
        case .mouse:
            return [
                Part(name: "Circuit board", grams: 8, material: .circuitBoard),
                Part(name: "Plastic casing", grams: 60, material: .plastic),
                Part(name: "Copper wiring", grams: 2, material: .copper)
            ]
        case .headphones:
            return [
                Part(name: "Circuit board", grams: 5, material: .circuitBoard),
                Part(name: "Plastic casing", grams: 80, material: .plastic),
                Part(name: "Copper wiring", grams: 15, material: .copper),
                Part(name: "Magnets", grams: 5, material: .rareEarthMagnets),
                Part(name: "Lithium battery", grams: 10, material: .lithiumCells)
            ]
        case .speaker:
            return [
                Part(name: "Circuit board", grams: 15, material: .circuitBoard),
                Part(name: "Plastic casing", grams: 300, material: .plastic),
                Part(name: "Copper wiring", grams: 20, material: .copper),
                Part(name: "Magnets", grams: 30, material: .rareEarthMagnets),
                Part(name: "Steel parts", grams: 100, material: .steel)
            ]
        case .camera:
            return [
                Part(name: "Circuit board", grams: 50, material: .circuitBoard),
                Part(name: "Display glass", grams: 40, material: .displayGlass),
                Part(name: "Aluminium body", grams: 100, material: .aluminum),
                Part(name: "Plastic casing", grams: 250, material: .plastic),
                Part(name: "Copper wiring", grams: 20, material: .copper),
                Part(name: "Gold and precious metals", grams: 8, material: .preciousMetals),
                Part(name: "Lithium battery", grams: 20, material: .lithiumCells)
            ]
        case .gameConsole:
            return [
                Part(name: "Circuit board", grams: 150, material: .circuitBoard),
                Part(name: "Copper wiring", grams: 40, material: .copper),
                Part(name: "Aluminium heatsink", grams: 100, material: .aluminum),
                Part(name: "Plastic casing", grams: 400, material: .plastic),
                Part(name: "Steel parts", grams: 200, material: .steel),
                Part(name: "Gold and precious metals", grams: 10, material: .preciousMetals)
            ]
        case .powerSupply:
            return [
                Part(name: "Circuit board", grams: 40, material: .circuitBoard),
                Part(name: "Copper wiring", grams: 120, material: .copper),
                Part(name: "Aluminium heatsink", grams: 150, material: .aluminum),
                Part(name: "Steel casing", grams: 200, material: .steel),
                Part(name: "Plastic casing", grams: 100, material: .plastic)
            ]
        case .cables:
            return [
                Part(name: "Copper wiring", grams: 150, material: .copper),
                Part(name: "Plastic insulation", grams: 100, material: .plastic)
            ]
        case .setTopBox:
            return [
                Part(name: "Circuit board", grams: 80, material: .circuitBoard),
                Part(name: "Plastic casing", grams: 250, material: .plastic),
                Part(name: "Steel parts", grams: 150, material: .steel),
                Part(name: "Copper wiring", grams: 20, material: .copper),
                Part(name: "Aluminium heatsink", grams: 50, material: .aluminum)
            ]
        case .smartwatch:
            return [
                Part(name: "Circuit board", grams: 8, material: .circuitBoard),
                Part(name: "Lithium battery", grams: 10, material: .lithiumCells),
                Part(name: "Display glass", grams: 15, material: .displayGlass),
                Part(name: "Aluminium body", grams: 20, material: .aluminum),
                Part(name: "Magnets", grams: 2, material: .rareEarthMagnets),
                Part(name: "Gold and precious metals", grams: 2, material: .preciousMetals)
            ]
        case .hardDrive:
            return [
                Part(name: "Circuit board", grams: 30, material: .circuitBoard),
                Part(name: "Aluminium casing", grams: 300, material: .aluminum),
                Part(name: "Steel parts", grams: 400, material: .steel),
                Part(name: "Copper wiring", grams: 15, material: .copper),
                Part(name: "Gold and precious metals", grams: 3, material: .preciousMetals),
                Part(name: "Magnets", grams: 20, material: .rareEarthMagnets)
            ]
        case .ups:
            return [
                Part(name: "Circuit board", grams: 60, material: .circuitBoard),
                Part(name: "Copper wiring", grams: 200, material: .copper),
                Part(name: "Lead-acid battery", grams: 2500, material: .leadAcid),
                Part(name: "Steel casing", grams: 500, material: .steel),
                Part(name: "Plastic casing", grams: 300, material: .plastic),
                Part(name: "Aluminium heatsink", grams: 100, material: .aluminum)
            ]
        }
    }

    var note: String {
        switch self {
        case .battery:
            return "Batteries are handled separately by the recycler."
        case .phone:
            return "Back up and wipe your data before drop-off."
        case .laptop:
            return "Remove a swollen battery before transport."
        case .desktop:
            return "Wipe or destroy the storage drive before recycling."
        case .tablet:
            return "Check the screen for cracks before reuse."
        case .monitor:
            return "Panel glass is low value; the stand and board are worth more."
        case .television:
            return "Large panels need separate handling."
        case .printer:
            return "Toner and ink cartridges are handled separately."
        case .keyboard:
            return "Value depends mostly on the cable and circuit board."
        case .headphones:
            return "Battery-powered models need separate battery handling."
        case .speaker:
            return "Magnets and copper drive most of the value."
        case .camera:
            return "Lenses are resale items and should be removed first."
        case .gameConsole:
            return "A working console is usually worth more for reuse."
        case .powerSupply:
            return "Capacitors can hold a charge; handle carefully."
        case .cables:
            return "Copper content drives the price."
        case .smartwatch:
            return "Remove a swollen battery before transport."
        case .hardDrive:
            return "Wipe or destroy the data before recycling."
        case .ups:
            return "Lead-acid batteries require separate handling."
        case .router, .circuitBoard, .mouse, .setTopBox:
            return ""
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
    let materialValue: Int
    let reuseValue: Int
    let low: Int
    let high: Int
}

enum EstimateEngine {
    static let minConfidence: Float = 0.30

    static func estimate(device: DeviceType, condition: Condition, parts: [Part]? = nil) -> EstimateResult {
        var material = 0.0
        for part in (parts ?? device.parts) {
            material += (part.grams / 1000.0) * part.material.ratePerKg
        }

        let reuse = device.baseValue
        let adjusted = (material + reuse) * condition.factor
        let low = Int((adjusted * 0.8).rounded())
        let high = Int((adjusted * 1.2).rounded())

        return EstimateResult(
            device: device,
            condition: condition,
            materialValue: Int(material.rounded()),
            reuseValue: Int(reuse.rounded()),
            low: low,
            high: max(high, low + 1)
        )
    }

    private static let keywordTable: [(DeviceType, [String])] = [
        (.laptop, ["laptop", "notebook", "macbook", "thinkpad", "ideapad", "chromebook", "ultrabook"]),
        (.tablet, ["tablet", "ipad", "galaxy tab", "surface pro"]),
        (.smartwatch, ["smartwatch", "smart watch", "apple watch", "galaxy watch", "fitbit", "amazfit", "mi band"]),
        (.phone, ["smartphone", "smart phone", "mobile phone", "cellphone", "cell phone",
                  "cellular phone", "telephone", "telephones", "feature phone", "iphone",
                  "android phone"]),
        (.television, ["television", "smart tv", "led tv", "lcd tv", "oled tv", "bravia", "plasma screen", "tv"]),
        (.monitor, ["monitor", "computer screen", "lcd monitor", "led monitor"]),
        (.printer, ["printer", "laserjet", "inkjet", "deskjet", "pixma", "ecotank"]),
        (.keyboard, ["keyboard", "keypad"]),
        (.mouse, ["mouse", "mice", "trackpad", "trackball"]),
        (.headphones, ["headphone", "earphone", "earbud", "airpods", "headset"]),
        (.speaker, ["speaker", "soundbar", "boombox"]),
        (.camera, ["dslr", "mirrorless", "webcam", "digital camera", "gopro", "camera"]),
        (.gameConsole, ["playstation", "xbox", "nintendo", "game console", "gaming console",
                        "game controller", "joystick"]),
        (.setTopBox, ["set-top", "set top", "dth", "cable box", "digital tv box", "satellite box", "tata sky", "dish tv"]),
        (.hardDrive, ["hard drive", "hard disk", "hdd", "ssd", "solid state drive", "seagate", "western digital"]),
        (.ups, ["uninterruptible", "inverter", "apc", "microtek", "luminous", "ups"]),
        (.powerSupply, ["power supply", "smps", "adapter", "charger", "power brick"]),
        (.cables, ["usb cable", "hdmi cable", "power cord", "charging cable", "copper wire", "cable"]),
        (.router, ["router", "modem", "wifi", "wi-fi", "network switch", "access point"]),
        (.battery, ["battery", "batteries", "power bank", "powerbank", "lithium", "li-ion"]),
        (.circuitBoard, ["circuit", "motherboard", "pcb", "mainboard", "electronic board"]),
        (.desktop, ["desktop", "tower computer", "personal computer", "workstation"])
    ]

    static func match(label: String) -> DeviceType? {
        let text = label.lowercased()
        if text == "tv" || text == "television" { return .television }
        if text == "pc" || text == "computer" { return .desktop }
        if text == "phone" || text == "mobile" { return .phone }
        if text == "ups" { return .ups }

        for (device, words) in keywordTable where words.contains(where: { text.contains($0) }) {
            return device
        }
        return nil
    }
}
