import SwiftUI
import MapKit
import MessageUI

struct DropBox: Identifiable {
    let id = UUID()
    let name: String
    var fill: Double          // 0 to 100. SIMULATED for the demo.
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct PickupView: View {
    // Demo coordinates near KIET, Muradnagar. Change them to real spots on your campus.
    private let depot = CLLocation(latitude: 28.7527, longitude: 77.4986)
    private let recyclerNumber = "+910000000000"   // <-- put a teammate's number here to test

    @State private var boxes: [DropBox] = [
        DropBox(name: "Block E drop-box", fill: 92, latitude: 28.7541, longitude: 77.4999),
        DropBox(name: "Hostel drop-box", fill: 84, latitude: 28.7512, longitude: 77.4962),
        DropBox(name: "Library drop-box", fill: 35, latitude: 28.7530, longitude: 77.4975)
    ]
    @State private var pickupDevices = 0
    @State private var showComposer = false

    private let pickupSpot = CLLocation(latitude: 28.7520, longitude: 77.5004)

    // A stop is either a full drop-box or the pickup request
    private struct Stop {
        let text: String
        let location: CLLocation
    }

    private var openStops: [Stop] {
        var stops: [Stop] = []
        for box in boxes where box.fill >= 80 {
            stops.append(Stop(text: "\(box.name), \(Int(box.fill))% full",
                              location: CLLocation(latitude: box.latitude, longitude: box.longitude)))
        }
        if pickupDevices > 0 {
            stops.append(Stop(text: "Pickup request, \(pickupDevices) device\(pickupDevices == 1 ? "" : "s")",
                              location: pickupSpot))
        }
        return stops
    }

    // Simple nearest-first ordering, starting from the depot
    private var orderedStops: [Stop] {
        var remaining = openStops
        var ordered: [Stop] = []
        var current = depot
        while !remaining.isEmpty {
            var bestIndex = 0
            var bestDistance = Double.greatestFiniteMagnitude
            for (index, stop) in remaining.enumerated() {
                let d = stop.location.distance(from: current)
                if d < bestDistance { bestDistance = d; bestIndex = index }
            }
            let next = remaining.remove(at: bestIndex)
            ordered.append(next)
            current = next.location
        }
        return ordered
    }

    private var routeMessage: String {
        var lines = ["E-Trace route, \(orderedStops.count) stop\(orderedStops.count == 1 ? "" : "s")"]
        for (index, stop) in orderedStops.enumerated() {
            lines.append("\(index + 1). \(stop.text)")
        }
        return lines.joined(separator: "\n")
    }

    var body: some View {
        List {
            Section {
                Map(initialPosition: .region(MKCoordinateRegion(
                    center: depot.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)))) {
                    ForEach(boxes) { box in
                        Marker(box.name, systemImage: "trash", coordinate: box.coordinate)
                            .tint(box.fill >= 80 ? .red : .green)
                    }
                }
                .frame(height: 240)
                .listRowInsets(EdgeInsets())
            }

            Section("Drop-box fill levels (simulated)") {
                ForEach($boxes) { $box in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(box.name)
                            Spacer()
                            Text("\(Int(box.fill))%")
                                .foregroundStyle(box.fill >= 80 ? .red : .secondary)
                        }
                        Slider(value: $box.fill, in: 0...100, step: 1)
                    }
                }
            }

            Section("Request a pickup") {
                Stepper("Devices to collect: \(pickupDevices)", value: $pickupDevices, in: 0...10)
            }

            Section("Route for the recycler") {
                if orderedStops.isEmpty {
                    Text("No stops yet. Push a drop-box past 80% or request a pickup.")
                        .foregroundStyle(.secondary)
                } else {
                    Text(routeMessage).font(.system(.body, design: .monospaced))

                    if MFMessageComposeViewController.canSendText() {
                        Button {
                            showComposer = true
                        } label: {
                            Label("Text route to recycler", systemImage: "message")
                        }
                    }
                    ShareLink(item: routeMessage) {
                        Label("Share route", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
        .navigationTitle("Pickup")
        .sheet(isPresented: $showComposer) {
            MessageComposer(recipients: [recyclerNumber], body: routeMessage) {
                showComposer = false
            }
        }
    }
}
