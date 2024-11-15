//  VideoChecker.swift
//  runpose

import SwiftUI
import AVFoundation
import Vision

struct VideoChecker: View {
    let videoURL: URL
    var validationHandler: (Bool) -> Void
    @State private var detectedObjects: [(name: String, confidence: Double)] = []
    @State private var message: String = "Analyzing objects in video..."
    @State private var isLoading = true
    @State private var previewImage: UIImage?
    @State private var isVideoValid = false

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(2)
                    .onAppear(perform: analyzeVideo)
            } else {
                if let image = previewImage {
                    // Conditional frame color based on validation status
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 300, maxHeight: 300)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isVideoValid ? Color.green : Color.red, lineWidth: 5)
                        )
                        .overlay(
                            isVideoValid ?
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 40))
                                    .offset(x: 100, y: -100) // Position the checkmark icon at the top right
                                :
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 40))
                                    .offset(x: 100, y: -100) // Position the cross icon at the top right
                        )
                }

                Text(message)
                    .padding()
                    .foregroundColor(isVideoValid ? .green : .red)
                    .font(.headline)

                // Display detected objects with specific styling
                VStack(alignment: .leading) {
                    ForEach(detectedObjects, id: \.name) { object in
                        HStack {
                            Text(object.name)
                                .font(.headline)
                                .foregroundColor(object.name == "person" && object.confidence >= 60 ? .green : .primary)
                            Spacer()
                            Text("\(object.confidence*100, specifier: "%.2f")%")
                                .foregroundColor(object.name == "person" && object.confidence >= 60 ? .green : .secondary)
                        }
                        .padding(10)
                        .background(object.name == "person" && object.confidence >= 60 ? Color.green.opacity(0.2) : Color.purple.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.top)
            }
        }
        .navigationTitle("Video Validation")
        .navigationBarTitleDisplayMode(.inline)
        .padding()
    }

    private func analyzeVideo() {
        isLoading = true
        generatePreviewImage(for: videoURL) { image in
            guard let image = image else {
                message = "Failed to extract a frame from the video."
                isLoading = false
                return
            }
            self.previewImage = image
            let handler = YOLOModelHandler()
            handler.detectObjects(in: image) { results in
                self.detectedObjects = results
                validateDetectedObjects()
                isLoading = false
            }
        }
    }

    private func validateDetectedObjects() {
        // Check if there's exactly one "person" object with confidence > 60%
        let persons = detectedObjects.filter { $0.name == "person" && $0.confidence * 100 >= 60 }
        if persons.count == 1 {
            isVideoValid = true
            validationHandler(true)
            message = "Validation successful. Video is ready for analysis."
        } else {
            isVideoValid = false
            validationHandler(false)
            message = "Validation failed. Please ensure exactly one person is present in the video with clear visibility."
        }
    }

    private func generatePreviewImage(for url: URL, completion: @escaping (UIImage?) -> Void) {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: CMTime(seconds: 1, preferredTimescale: 30))]) { _, cgImage, _, _, _ in
            if let cgImage = cgImage {
                completion(UIImage(cgImage: cgImage))
            } else {
                completion(nil)
            }
        }
    }
}


class YOLOModelHandler {
    private var model: VNCoreMLModel?
    private var request: VNCoreMLRequest?

    init() {
        do {
            let configuration = MLModelConfiguration()
            let model = try yolov8m(configuration: configuration) // Replace with your YOLO model
            self.model = try VNCoreMLModel(for: model.model)
            self.request = VNCoreMLRequest(model: self.model!, completionHandler: { (request, error) in
                // Error handling here
            })
        } catch {
            print("Error loading model: \(error)")
        }
    }

    func detectObjects(in image: UIImage, completion: @escaping ([(name: String, confidence: Double)]) -> Void) {
        guard let ciImage = CIImage(image: image),
              let request = self.request else {
            completion([])
            return
        }

        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
                self.handleDetection(request: request, error: nil, completion: completion)
            } catch {
                print("Failed to perform detection: \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }

    private func handleDetection(request: VNRequest, error: Error?, completion: @escaping ([(name: String, confidence: Double)]) -> Void) {
        guard let results = request.results as? [VNRecognizedObjectObservation] else {
            DispatchQueue.main.async {
                completion([])
            }
            return
        }

        let descriptions = results.map { result in
            let confidence = Double(result.confidence) // Convert Float to Double
            let identifier = result.labels.first?.identifier ?? "Unknown"
            return (identifier, confidence)
        }

        DispatchQueue.main.async {
            completion(descriptions)
        }
    }
}

