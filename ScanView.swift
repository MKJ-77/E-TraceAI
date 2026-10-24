import SwiftUI
import PhotosUI

struct ScanView: View {
    @State private var pickerItem: PhotosPickerItem?
    @State private var image: UIImage?
    @State private var labels: [DetectedLabel] = []
    @State private var isAnalyzing = false
    @State private var device: DeviceType?
    @State private var autoDetected = false
    @State private var condition: Condition = .damaged

    var body: some View {
        Form {
            Section {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 260)
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Take a photo of the old gadget with the Camera app, then choose it here. Or pick any saved photo.")
                        .foregroundStyle(.secondary)
                }

                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Label(image == nil ? "Choose a photo" : "Choose a different photo",
                          systemImage: "photo.on.rectangle")
                }
            }

            if isAnalyzing {
                Section { HStack { ProgressView(); Text("Looking at the photo...").padding(.leading, 8) } }
            }

            if image != nil && !isAnalyzing {
                Section("Device") {
                    if autoDetected, let device {
                        Label("Looks like: \(device.rawValue)", systemImage: "checkmark.seal")
                    } else {
                        Text("Not sure what this is. Try a clearer photo, or pick the device type yourself.")
                            .foregroundStyle(.orange)
                    }

                    Picker("Device type", selection: $device) {
                        Text("Choose...").tag(DeviceType?.none)
                        ForEach(DeviceType.allCases) { d in
                            Text(d.rawValue).tag(DeviceType?.some(d))
                        }
                    }

                    Picker("Condition", selection: $condition) {
                        ForEach(Condition.allCases) { c in
                            Text(c.rawValue).tag(c)
                        }
                    }
                }

                Section {
                    if let device {
                        NavigationLink("See estimate") {
                            EstimateView(device: device, condition: condition)
                        }
                    }
                }

                if !labels.isEmpty {
                    Section {
                        DisclosureGroup("What the AI saw") {
                            ForEach(labels) { label in
                                HStack {
                                    Text(label.name)
                                    Spacer()
                                    Text("\(Int(label.confidence * 100))%").foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("E-Trace AI")
        .onChange(of: pickerItem) { _, newItem in
            guard let newItem else { return }
            Task { await load(newItem) }
        }
    }

    private func load(_ item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data) else { return }

        image = uiImage
        device = nil
        autoDetected = false
        isAnalyzing = true

        let found = await VisionClassifier.classify(uiImage)
        labels = found

        // Take the first confident label that maps to a device we know
        for label in found where label.confidence >= EstimateEngine.minConfidence {
            if let match = EstimateEngine.match(label: label.name) {
                device = match
                autoDetected = true
                break
            }
        }
        isAnalyzing = false
    }
}
