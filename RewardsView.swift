import SwiftUI
import SwiftData

struct RewardsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DropOff.date, order: .reverse) private var items: [DropOff]

    private var totalTokens: Int {
        items.reduce(0) { $0 + $1.tokens }
    }

    var body: some View {
        List {
            Section {
                VStack(spacing: 4) {
                    Text("\(totalTokens)")
                        .font(.system(size: 56, weight: .bold))
                        .foregroundStyle(.green)
                    Text("tokens")
                        .foregroundStyle(.secondary)
                    Text("Redeemable for a campus coupon")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }

            Section("Drop-off history") {
                if items.isEmpty {
                    Text("Nothing yet. Scan a gadget, then simulate a drop-box scan.")
                        .foregroundStyle(.secondary)
                }
                ForEach(items) { item in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.deviceName).font(.headline)
                        Text("Rs \(item.valueLow) to Rs \(item.valueHigh) · \(item.date.formatted(date: .abbreviated, time: .shortened))")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if !items.isEmpty {
                Section {
                    Button("Reset demo data", role: .destructive) {
                        for item in items { modelContext.delete(item) }
                    }
                }
            }
        }
        .navigationTitle("Rewards")
    }
}
