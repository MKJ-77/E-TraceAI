import SwiftUI
import SwiftData

// Admin overview. Reads the drop-offs saved on this device (demo data only).
struct AdminView: View {
    @Query(sort: \DropOff.date, order: .reverse) private var items: [DropOff]

    private var totalLow: Int { items.reduce(0) { $0 + $1.valueLow } }
    private var totalHigh: Int { items.reduce(0) { $0 + $1.valueHigh } }
    private var totalTokens: Int { items.reduce(0) { $0 + $1.tokens } }

    private var byDevice: [(name: String, count: Int)] {
        Dictionary(grouping: items, by: \.deviceName)
            .map { (name: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    var body: some View {
        List {
            Section("Overview") {
                stat("Drop-offs", "\(items.count)")
                stat("Tokens issued", "\(totalTokens)")
                stat("Estimated value", items.isEmpty ? "Rs 0" : "Rs \(totalLow) to Rs \(totalHigh)")
            }

            Section("By device type") {
                if byDevice.isEmpty {
                    Text("No drop-offs yet.").foregroundStyle(.secondary)
                }
                ForEach(byDevice, id: \.name) { row in
                    HStack {
                        Text(row.name)
                        Spacer()
                        Text("\(row.count)").foregroundStyle(.secondary)
                    }
                }
            }

            Section("Recent activity") {
                if items.isEmpty {
                    Text("Nothing yet.").foregroundStyle(.secondary)
                }
                ForEach(items.prefix(20)) { item in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.deviceName).font(.headline)
                        Text("Rs \(item.valueLow) to Rs \(item.valueHigh) · \(item.date.formatted(date: .abbreviated, time: .shortened))")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Admin")
    }

    private func stat(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value).bold().foregroundStyle(.green)
        }
    }
}
