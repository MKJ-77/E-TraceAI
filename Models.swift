import Foundation
import SwiftData

// One verified drop-off = one row in the wallet history (stored on the phone)
@Model
final class DropOff {
    var id: UUID
    var deviceName: String
    var valueLow: Int
    var valueHigh: Int
    var tokens: Int
    var date: Date

    init(deviceName: String, valueLow: Int, valueHigh: Int, tokens: Int = 1, date: Date = Date()) {
        self.id = UUID()
        self.deviceName = deviceName
        self.valueLow = valueLow
        self.valueHigh = valueHigh
        self.tokens = tokens
        self.date = date
    }
}
