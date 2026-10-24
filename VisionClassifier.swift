import UIKit
import Vision
import ImageIO

struct DetectedLabel: Identifiable {
    let id = UUID()
    let name: String
    let confidence: Float
}

enum VisionClassifier {
    // Runs Apple's on-device image classifier. No internet, no AWS needed.
    static func classify(_ image: UIImage) async -> [DetectedLabel] {
        guard let cgImage = image.cgImage else { return [] }
        let orientation = cgOrientation(from: image.imageOrientation)

        let raw: [(String, Float)] = await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let request = VNClassifyImageRequest()
                let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
                do {
                    try handler.perform([request])
                    let observations = request.results ?? []
                    let sorted = observations
                        .filter { $0.confidence > 0.05 }
                        .sorted { $0.confidence > $1.confidence }
                        .prefix(10)
                    continuation.resume(returning: sorted.map { ($0.identifier, $0.confidence) })
                } catch {
                    continuation.resume(returning: [])
                }
            }
        }
        return raw.map { DetectedLabel(name: $0.0, confidence: $0.1) }
    }

    private static func cgOrientation(from o: UIImage.Orientation) -> CGImagePropertyOrientation {
        switch o {
        case .up: return .up
        case .upMirrored: return .upMirrored
        case .down: return .down
        case .downMirrored: return .downMirrored
        case .left: return .left
        case .leftMirrored: return .leftMirrored
        case .right: return .right
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
}
