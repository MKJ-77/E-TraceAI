import SwiftUI
import SwiftData
import CoreImage.CIFilterBuiltins

struct EstimateView: View {
    let device: DeviceType
    let condition: Condition
    var parts: [Part]? = nil

    @Environment(\.modelContext) private var modelContext
    @State private var estimateID = UUID()
    @State private var droppedOff = false

    var body: some View {
        let result = EstimateEngine.estimate(device: device, condition: condition, parts: parts)
        let deviceParts = parts ?? device.parts

        List {
            Section("Estimated value") {
                Text("Rs \(result.low) to Rs \(result.high)")
                    .font(.title.bold())
                    .foregroundStyle(.green)
                Text("A range, not a promise. The final price is set by the recycler's rate card.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("How this is calculated") {
                HStack {
                    Text("Material recovery")
                    Spacer()
                    Text("Rs \(result.materialValue)").foregroundStyle(.secondary)
                }
                HStack {
                    Text("Reuse and handling")
                    Spacer()
                    Text("Rs \(result.reuseValue)").foregroundStyle(.secondary)
                }
                HStack {
                    Text("Condition (\(condition.rawValue))")
                    Spacer()
                    Text("\(Int(condition.factor * 100))%").foregroundStyle(.secondary)
                }
                Text("Estimate = (material + reuse) × condition, then ±20%. Recycler rate cards and local prices vary, so treat this as a guide.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("What's likely inside") {
                ForEach(deviceParts) { part in
                    HStack {
                        Text(part.name)
                        Spacer()
                        Text("about \(Int(part.grams)) g").foregroundStyle(.secondary)
                    }
                }
                if !device.note.isEmpty {
                    Text(device.note).font(.footnote).foregroundStyle(.secondary)
                }
            }

            Section("Drop-off code") {
                if let qr = Self.qrImage(from: "etrace://estimate/\(estimateID.uuidString)?item=\(device.rawValue)") {
                    Image(uiImage: qr)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                        .frame(maxWidth: .infinity)
                }
                Text("Show this at a drop-box. When it scans the code, you get a token.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Button {
                    let entry = DropOff(deviceName: device.rawValue,
                                        valueLow: result.low,
                                        valueHigh: result.high)
                    modelContext.insert(entry)
                    droppedOff = true
                } label: {
                    Label(droppedOff ? "Token added to wallet" : "Simulate drop-box scan (demo)",
                          systemImage: droppedOff ? "checkmark.circle.fill" : "qrcode.viewfinder")
                }
                .disabled(droppedOff)
            }
        }
        .navigationTitle(device.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }

    static func qrImage(from string: String) -> UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        guard let output = filter.outputImage?.transformed(by: CGAffineTransform(scaleX: 10, y: 10)) else { return nil }
        let context = CIContext()
        guard let cgImage = context.createCGImage(output, from: output.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
