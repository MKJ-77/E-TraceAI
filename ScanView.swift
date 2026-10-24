import SwiftUI
import PhotosUI

struct ScanView: View {
    @State private var pickerItem: PhotosPickerItem?
    @State private var image: UIImage?
    @State private var labels: [DetectedLabel] = []
    @State private var ocrText = ""
    @State private var modelMatch: ModelMatch?
    @State private var detectionSource: String?
    @State private var aiReason: String?
    @State private var geminiStatus: String?
    @State private var showGeminiError = false
    @State private var connectionTest: String?
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
                        if let modelMatch, modelMatch.device == device, modelMatch.name != device.rawValue {
                            Text("Matched model: \(modelMatch.name)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        if let detectionSource {
                            Text(detectionSource)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        if let aiReason {
                            Text(aiReason)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text("Not sure what this is. Try a clearer photo, or pick the device type yourself.")
                            .foregroundStyle(.orange)
                    }

                    if geminiStatus != nil {
                        Button {
                            showGeminiError = true
                        } label: {
                            HStack {
                                Label("Some error occurred with Gemini. Tap for details.",
                                      systemImage: "exclamationmark.triangle")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                            }
                            .font(.footnote)
                            .foregroundStyle(.orange)
                        }
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
                            EstimateView(device: device,
                                         condition: condition,
                                         parts: modelMatch?.device == device ? modelMatch?.parts : nil)
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

                if !ocrText.isEmpty {
                    Section {
                        DisclosureGroup("Text on the item") {
                            Text(ocrText)
                                .font(.footnote)
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
        .sheet(isPresented: $showGeminiError) {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(geminiStatus ?? "No details available.")
                            .font(.system(.footnote, design: .monospaced))
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Divider()

                        Button {
                            Task {
                                connectionTest = "Testing..."
                                connectionTest = await GeminiClassifier.ping()
                            }
                        } label: {
                            Label("Test connection", systemImage: "dot.radiowaves.left.and.right")
                        }

                        if let connectionTest {
                            Text(connectionTest)
                                .font(.system(.footnote, design: .monospaced))
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Button {
                            Task { await retryWithBackupModel() }
                        } label: {
                            Label("Retry with Gemini 3.6 Flash", systemImage: "arrow.clockwise")
                        }
                    }
                    .padding()
                }
                .navigationTitle("Gemini error")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") { showGeminiError = false }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        ShareLink(item: geminiStatus ?? "No details available.")
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
    }

    private func load(_ item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data) else { return }

        image = uiImage
        device = nil
        modelMatch = nil
        detectionSource = nil
        aiReason = nil
        geminiStatus = nil
        connectionTest = nil
        autoDetected = false
        isAnalyzing = true

        let foundLabels = await VisionClassifier.classify(uiImage)
        let recognizedText = await VisionClassifier.recognizeText(uiImage)

        labels = foundLabels
        ocrText = recognizedText

        let gemini = await GeminiClassifier.classify(uiImage, hint: recognizedText)
        geminiStatus = gemini.note

        if let guess = gemini.guess {
            device = guess.device
            if let name = guess.modelName {
                modelMatch = ModelMatch(device: guess.device, name: name, parts: nil)
            }
            if let detectedCondition = guess.condition {
                condition = detectedCondition
            }
            autoDetected = true
            detectionSource = gemini.usedFallback
                ? "Identified by Gemini 3.6 Flash (fallback)."
                : "Identified by Gemini."
            aiReason = guess.reason
        } else if let match = ModelLookup.match(recognizedText) {
            device = match.device
            modelMatch = match
            autoDetected = true
            detectionSource = "Identified from the label text."
        } else if let labelDevice = firstConfidentDevice(in: foundLabels) {
            device = labelDevice
            autoDetected = true
            detectionSource = "Identified from the photo."
        } else if let aiDevice = await AIDeviceGuesser.guess(labels: foundLabels.map(\.name),
                                                             ocr: recognizedText) {
            device = aiDevice
            autoDetected = true
            detectionSource = "Identified by the on-device AI."
        }

        isAnalyzing = false
    }

    private func retryWithBackupModel() async {
        guard let image else { return }
        showGeminiError = false
        connectionTest = nil
        isAnalyzing = true

        let result = await GeminiClassifier.classify(image,
                                                     hint: ocrText,
                                                     modelOverride: "gemini-3.6-flash")
        geminiStatus = result.note

        if let guess = result.guess {
            device = guess.device
            if let name = guess.modelName {
                modelMatch = ModelMatch(device: guess.device, name: name, parts: nil)
            }
            if let detectedCondition = guess.condition {
                condition = detectedCondition
            }
            autoDetected = true
            detectionSource = "Identified by Gemini 3.6 Flash."
            aiReason = guess.reason
        }

        isAnalyzing = false
    }

    private func firstConfidentDevice(in labels: [DetectedLabel]) -> DeviceType? {
        for label in labels where label.confidence >= EstimateEngine.minConfidence {
            if let match = EstimateEngine.match(label: label.name) {
                return match
            }
        }
        return nil
    }
}
