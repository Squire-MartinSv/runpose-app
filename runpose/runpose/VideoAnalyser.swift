import SwiftUI
import AVKit
import Vision
import UIKit

struct VideoAnalyser: View {
    let videoURL: URL
    @State private var annotatedVideoURL: URL?
    @State private var isProcessing: Bool = false
    @State private var totalFramesProcessed: Int = 0

    // Track minimal and maximal angles for knees and elbows
    @State private var minLeftKneeAngle: Double = 180.0
    @State private var maxLeftKneeAngle: Double = 0.0
    @State private var minRightKneeAngle: Double = 180.0
    @State private var maxRightKneeAngle: Double = 0.0
    @State private var minLeftElbowAngle: Double = 180.0
    @State private var maxLeftElbowAngle: Double = 0.0
    @State private var minRightElbowAngle: Double = 180.0
    @State private var maxRightElbowAngle: Double = 0.0
    @State private var minBodyLeanAngle: Double = 180.0
    @State private var maxBodyLeanAngle: Double = 0.0
    @State private var minEarEyeAngle: Double = 45.0
    @State private var maxEarEyeAngle: Double = -45.0

    var body: some View {
        ZStack {
            if isProcessing {
                VStack {
                    Spacer()
                    Image("Runpose_logo_png")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                    ProgressView("Analyzing video...")
                    Spacer()
                }
            } else {
                ScrollView {
                    VStack(spacing: 1) { // Reduced spacing between boxes
                        if let annotatedVideoURL = annotatedVideoURL {
                            // Video player
                            let player = AVPlayer(url: annotatedVideoURL)
                            VideoPlayer(player: player)
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .cornerRadius(10)
                                .onAppear {
                                    print("Playing annotated video: \(annotatedVideoURL.absoluteString)")
                                    player.play() // Ensure playback starts when the view appears
                                }
                                .onDisappear {
                                    player.pause() // Pause playback when the view disappears
                                }

                            // Total frames processed
                            Text("Total frames processed: \(totalFramesProcessed)")
                                .font(.subheadline)
                                .padding(.top, 10)
                        } else {
                            Text("No video available")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }

                        // Expandable boxes for knees and elbows
                        ExpandableAngleBox(
                            label: "Left Knee Angles",
                            minAngle: minLeftKneeAngle,
                            maxAngle: maxLeftKneeAngle,
                            recommendedRange: (5, 170)
                        )

                        ExpandableAngleBox(
                            label: "Right Knee Angles",
                            minAngle: minRightKneeAngle,
                            maxAngle: maxRightKneeAngle,
                            recommendedRange: (5, 170)
                        )

                        ExpandableAngleBox(
                            label: "Left Elbow Angles",
                            minAngle: minLeftElbowAngle,
                            maxAngle: maxLeftElbowAngle,
                            recommendedRange: (5, 170)
                        )

                        ExpandableAngleBox(
                            label: "Right Elbow Angles",
                            minAngle: minRightElbowAngle,
                            maxAngle: maxRightElbowAngle,
                            recommendedRange: (5, 170)
                        )
                        
                        ExpandableAngleBox(
                            label: "Body Lean Angles",
                            minAngle: minBodyLeanAngle,
                            maxAngle: maxBodyLeanAngle,
                            recommendedRange: (5, 170)
                        )
                        
                        ExpandableAngleBox(
                            label: "Head Horizontal Angles",
                            minAngle: minEarEyeAngle,
                            maxAngle: maxEarEyeAngle,
                            recommendedRange: (-45, 45) // Example recommended range
                        )
                    }
                    .padding(.horizontal, 16) // Add padding to the scrollable content
                }
            }
        }
        .onAppear {
            processVideo()
        }
    }

    private func processVideo() {
        isProcessing = true

        extractFrames(from: videoURL) { frames in
            guard let frames = frames else {
                print("Failed to extract frames.")
                DispatchQueue.main.async {
                    self.isProcessing = false
                }
                return
            }

            // Skip every second frame - debuggin - delete for production
            let filteredFrames = frames.enumerated().compactMap { index, frame in
                return index % 2 == 0 ? frame : nil
            }

            // Annotate frames and calculate angles
            var annotatedFrames = filteredFrames.compactMap { frame -> UIImage? in
                if let (boundingBox, keypoints) = self.extractCoordinates(from: frame),
                   let annotatedFrame = self.drawBoundingBoxAndKeypoints(on: frame, boundingBox: boundingBox, keypoints: keypoints) {
                    // Calculate left knee angle if keypoints 11, 13, 15 are recognized
                    if let leftKneeAngle = self.calculateAngleIfPossible(keypoints: keypoints, jointIndex: 13, connection1: 11, connection2: 15) {
                        DispatchQueue.main.async {
                            self.updateLeftKneeAngle(angle: leftKneeAngle)
                        }
                    }
                    // Calculate right knee angle if keypoints 12, 14, 16 are recognized
                    if let rightKneeAngle = self.calculateAngleIfPossible(keypoints: keypoints, jointIndex: 14, connection1: 12, connection2: 16) {
                        DispatchQueue.main.async {
                            self.updateRightKneeAngle(angle: rightKneeAngle)
                        }
                    }
                    // Calculate left elbow angle
                    if let leftElbowAngle = self.calculateAngleIfPossible(keypoints: keypoints, jointIndex: 7, connection1: 5, connection2: 9) {
                        DispatchQueue.main.async {
                            self.updateLeftElbowAngle(angle: leftElbowAngle)
                        }
                    }
                    // Calculate right elbow angle
                    if let rightElbowAngle = self.calculateAngleIfPossible(keypoints: keypoints, jointIndex: 8, connection1: 6, connection2: 10) {
                        DispatchQueue.main.async {
                            self.updateRightElbowAngle(angle: rightElbowAngle)
                        }
                    }
                    // Calculate body lean angle
                    if let bodyLeanAngle = self.calculateAngleIfPossible(keypoints: keypoints, jointIndex: 11, connection1: 5, connection2: 17) {
                        DispatchQueue.main.async {
                            self.updateBodyLeanAngle(angle: bodyLeanAngle)
                        }
                    }
                    // Calculate lean of head - straight look, down look, up look
                    if let earEyeAngle = self.calculateEarEyeAngle(keypoints: keypoints) {
                        DispatchQueue.main.async {
                            self.updateEarEyeAngle(angle: earEyeAngle)
                        }
                    }
                    return annotatedFrame
                }
                return nil
            }

            // Create annotated video
            guard let annotatedVideo = self.createVideo(from: annotatedFrames, originalVideoURL: self.videoURL) else {
                print("Failed to create annotated video.")
                DispatchQueue.main.async {
                    self.isProcessing = false
                }
                return
            }

            // Clear annotatedFrames to free memory
            annotatedFrames.removeAll()

            // Update the state on the main thread
            DispatchQueue.main.async {
                self.annotatedVideoURL = annotatedVideo
                self.totalFramesProcessed = filteredFrames.count // Store the total frames processed
                self.isProcessing = false
            }
        }
    }

    private func updateLeftKneeAngle(angle: Double) {
        if angle < minLeftKneeAngle {
            minLeftKneeAngle = angle
        }
        if angle > maxLeftKneeAngle {
            maxLeftKneeAngle = angle
        }
    }

    private func updateRightKneeAngle(angle: Double) {
        if angle < minRightKneeAngle {
            minRightKneeAngle = angle
        }
        if angle > maxRightKneeAngle {
            maxRightKneeAngle = angle
        }
    }
    private func updateLeftElbowAngle(angle: Double) {
        if angle < minLeftElbowAngle {
            minLeftElbowAngle = angle
        }
        if angle > maxLeftElbowAngle {
            maxLeftElbowAngle = angle
        }
    }

    private func updateRightElbowAngle(angle: Double) {
        if angle < minRightElbowAngle {
            minRightElbowAngle = angle
        }
        if angle > maxRightElbowAngle {
            maxRightElbowAngle = angle
        }
    }
    private func updateBodyLeanAngle(angle: Double) {
        if angle < minBodyLeanAngle {
            minBodyLeanAngle = angle
        }
        if angle > maxBodyLeanAngle {
            maxBodyLeanAngle = angle
        }
    }
    private func updateEarEyeAngle(angle: Double) {
        if angle < minEarEyeAngle {
            minEarEyeAngle = angle
        }
        if angle > maxEarEyeAngle {
            maxEarEyeAngle = angle
        }
    }

    private func calculateAngleIfPossible(keypoints: [(CGPoint, Float)], jointIndex: Int, connection1: Int, connection2: Int) -> Double? {
        guard keypoints.count > max(jointIndex, connection1, connection2),
              keypoints[jointIndex].1 > 0.5, // Confidence check
              keypoints[connection1].1 > 0.5,
              keypoints[connection2].1 > 0.5 else {
            return nil // One or more keypoints are missing or have low confidence
        }

        return calculateAngle(
            at: jointIndex,
            keypoints: keypoints,
            connection1: connection1,
            connection2: connection2
        )
    }

    private func calculateAngle(at jointIndex: Int, keypoints: [(CGPoint, Float)], connection1: Int, connection2: Int) -> Double {
        let joint = keypoints[jointIndex].0
        let point1 = keypoints[connection1].0
        let point2 = keypoints[connection2].0

        let vector1 = CGPoint(x: point1.x - joint.x, y: point1.y - joint.y)
        let vector2 = CGPoint(x: point2.x - joint.x, y: point2.y - joint.y)

        let dotProduct = vector1.x * vector2.x + vector1.y * vector2.y
        let magnitude1 = sqrt(vector1.x * vector1.x + vector1.y * vector1.y)
        let magnitude2 = sqrt(vector2.x * vector2.x + vector2.y * vector2.y)

        let cosineAngle = dotProduct / (magnitude1 * magnitude2)
        let angleInRadians = acos(cosineAngle)

        return angleInRadians * (180 / Double.pi) // Convert radians to degrees
    }
    
    private func calculateEarEyeAngle(keypoints: [(CGPoint, Float)]) -> Double? {
        // Check for keypoints 3 and 1 (primary case)
        if keypoints.count > max(3, 1),
           keypoints[3].1 > 0.5, // Confidence check for ear
           keypoints[1].1 > 0.5  // Confidence check for eye
        {
            let ear = keypoints[3].0
            let eye = keypoints[1].0
            return calculateHorizontalAngle(ear: ear, eye: eye)
        }
        // Check for keypoints 4 and 2 (secondary case)
        else if keypoints.count > max(4, 2),
                keypoints[4].1 > 0.5, // Confidence check for ear
                keypoints[2].1 > 0.5  // Confidence check for eye
        {
            let ear = keypoints[4].0
            let eye = keypoints[2].0
            return calculateHorizontalAngle(ear: ear, eye: eye)
        }
        // Neither set of keypoints is available
        return nil
    }

    // Helper function to calculate the horizontal angle
    private func calculateHorizontalAngle(ear: CGPoint, eye: CGPoint) -> Double {
        let deltaY = eye.y - ear.y
        let deltaX = eye.x - ear.x
        let angleRadians = atan2(deltaY, deltaX) // atan2 handles quadrant-based angles
        let angleDegrees = angleRadians * (180 / .pi)
        return angleDegrees // No normalization needed as it's already in correct range
    }


    private func extractFrames(from videoURL: URL, completion: @escaping ([UIImage]?) -> Void) {
        let asset = AVAsset(url: videoURL)
        var frames: [UIImage] = []

        asset.loadTracks(withMediaType: .video) { tracks, error in
            guard let videoTrack = tracks?.first, error == nil else {
                print("Failed to load video tracks: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }

            let outputSettings: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB
            ]
            let reader: AVAssetReader
            do {
                reader = try AVAssetReader(asset: asset)
            } catch {
                print("Failed to create AVAssetReader: \(error)")
                completion(nil)
                return
            }

            let trackOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: outputSettings)
            reader.add(trackOutput)

            guard reader.startReading() else {
                print("Failed to start reading video: \(reader.error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }

            while let sampleBuffer = trackOutput.copyNextSampleBuffer(),
                  let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                let ciImage = CIImage(cvPixelBuffer: imageBuffer)
                let context = CIContext()
                if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                    let image = UIImage(cgImage: cgImage)
                    frames.append(image)
                }
            }

            completion(frames)
        }
    }

    private func createVideo(from frames: [UIImage], originalVideoURL: URL) -> URL? {
        let fileManager = FileManager.default
        let outputPath = fileManager.temporaryDirectory.appendingPathComponent("annotated_video.mp4")
        try? fileManager.removeItem(at: outputPath) // Remove any existing file

        guard let videoSize = frames.first?.size else {
            print("No frames to process.")
            return nil
        }

        do {
            let writer = try AVAssetWriter(outputURL: outputPath, fileType: .mp4)

            let settings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: Int(videoSize.width),
                AVVideoHeightKey: Int(videoSize.height)
            ]
            let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
            let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: nil)
            writer.add(input)

            writer.startWriting()
            writer.startSession(atSourceTime: .zero)

            var frameCount: Int64 = 0

            for frame in frames {
                guard let buffer = frame.toCVPixelBuffer() else { continue }
                while !input.isReadyForMoreMediaData { } // Ensure input is ready
                adaptor.append(buffer, withPresentationTime: CMTime(value: frameCount, timescale: 30))
                frameCount += 1
            }

            input.markAsFinished()
            var success = false

            writer.finishWriting {
                success = writer.status == .completed
            }

            // Wait for the writing process to complete
            while writer.status == .writing {
                Thread.sleep(forTimeInterval: 0.1)
            }

            if success {
                print("Finished writing successfully: \(outputPath.absoluteString)")
                return outputPath
            } else {
                print("Failed to write video: \(writer.error?.localizedDescription ?? "Unknown error")")
                return nil
            }
        } catch {
            print("Failed to create AVAssetWriter: \(error)")
            return nil
        }
    }

    private func extractCoordinates(from image: UIImage) -> (CGRect, [(CGPoint, Float)])? {
        guard let resizedImage = resizeImage(image: image, targetSize: CGSize(width: 640, height: 640)),
              let pixelBuffer = resizedImage.toCVPixelBuffer() else {
            print("Failed to resize image or convert to pixel buffer.")
            return nil
        }

        do {
            let model = try yolov8xpose(configuration: MLModelConfiguration())
            let input = yolov8xposeInput(image: pixelBuffer)
            let prediction = try model.prediction(input: input)

            let outputArray = prediction.var_1487ShapedArray
            let imageWidthScale = image.size.width / 640
            let imageHeightScale = image.size.height / 640

            for anchorIndex in 0..<8400 {
                let confidence = outputArray[0, 4, anchorIndex].scalar ?? 0.0
                if confidence > 0.5 {
                    let centerX = outputArray[0, 0, anchorIndex].scalar ?? 0.0
                    let centerY = outputArray[0, 1, anchorIndex].scalar ?? 0.0
                    let boxWidth = outputArray[0, 2, anchorIndex].scalar ?? 0.0
                    let boxHeight = outputArray[0, 3, anchorIndex].scalar ?? 0.0

                    let scaledCenterX = CGFloat(centerX) * imageWidthScale
                    let scaledCenterY = CGFloat(centerY) * imageHeightScale
                    let scaledBoxWidth = CGFloat(boxWidth) * imageWidthScale
                    let scaledBoxHeight = CGFloat(boxHeight) * imageHeightScale

                    let boundingBox = CGRect(
                        x: scaledCenterX - scaledBoxWidth / 2,
                        y: scaledCenterY - scaledBoxHeight / 2,
                        width: scaledBoxWidth,
                        height: scaledBoxHeight
                    )

                    var keypoints: [(CGPoint, Float)] = []
                    for keypointIndex in stride(from: 5, to: 55, by: 3) {
                        let keypointX = outputArray[0, keypointIndex, anchorIndex].scalar ?? 0.0
                        let keypointY = outputArray[0, keypointIndex + 1, anchorIndex].scalar ?? 0.0
                        let keypointConfidence = outputArray[0, keypointIndex + 2, anchorIndex].scalar ?? 0.0

                        let scaledKeypointX = CGFloat(keypointX) * imageWidthScale
                        let scaledKeypointY = CGFloat(keypointY) * imageHeightScale
                        let keypoint = CGPoint(x: scaledKeypointX, y: scaledKeypointY)

                        keypoints.append((keypoint, keypointConfidence))
                    }
                    // Add artificial keypoint 17 - vertical axes above left hip
                    if keypoints.count > max(11, 5), keypoints[11].1 > 0.5, keypoints[5].1 > 0.5 {
                        let hip = keypoints[11].0
                        let shoulder = keypoints[5].0
                        let verticalOffset = 2 * abs(shoulder.y - hip.y)
                        let artificialKeypoint = CGPoint(x: hip.x, y: hip.y - verticalOffset)
                        keypoints.append((artificialKeypoint, 1.0)) // Confidence set to 1.0
                    }

                    return (boundingBox, keypoints)
                }
            }
        } catch {
            print("Error during YOLO model prediction: \(error)")
        }

        return nil
    }

    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }

    private func drawBoundingBoxAndKeypoints(on image: UIImage, boundingBox: CGRect, keypoints: [(CGPoint, Float)]) -> UIImage? {
        let connections = [
            (0, 1), (0, 2), (1, 3), (2, 4),       // Head
            (5, 6), (5, 11), (6, 12), (11, 12),   // Torso
            (5, 7), (6, 8), (7, 9), (8, 10),      // Arms
            (11, 13), (12, 14), (13, 15), (14, 16), // Legs
            (4, 6), // Head to shoulder connection
            (11, 17) // Connection to artificial keypoint
        ]

        let renderer = UIGraphicsImageRenderer(size: image.size)

        return renderer.image { context in
            image.draw(at: .zero)

            UIColor.magenta.setStroke()
            let boundingBoxPath = UIBezierPath(rect: boundingBox)
            boundingBoxPath.lineWidth = 2
            boundingBoxPath.stroke()

            UIColor.yellow.setStroke()
            for (startIdx, endIdx) in connections {
                guard startIdx < keypoints.count, endIdx < keypoints.count else { continue }
                let (startPoint, startConfidence) = keypoints[startIdx]
                let (endPoint, endConfidence) = keypoints[endIdx]

                if startConfidence > 0.5 && endConfidence > 0.5 {
                    let path = UIBezierPath()
                    path.move(to: startPoint)
                    path.addLine(to: endPoint)
                    path.lineWidth = 2
                    path.stroke()
                }
            }

            UIColor.blue.setFill()
            for (index, (point, confidence)) in keypoints.enumerated() where confidence > 0.5 {
                let rect = CGRect(x: point.x - 2, y: point.y - 2, width: 4, height: 4)
                let circlePath = UIBezierPath(ovalIn: rect)
                circlePath.fill()

                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14),
                    .foregroundColor: UIColor.magenta
                ]
                let label = "\(index)"
                label.draw(at: CGPoint(x: point.x + 4, y: point.y - 4), withAttributes: attributes)
            }
        }
    }
}

struct ExpandableAngleBox: View {
    let label: String
    let minAngle: Double
    let maxAngle: Double
    let recommendedRange: (min: Double, max: Double)
    @State private var isExpanded: Bool = false

    var body: some View {
        DisclosureGroup(
            isExpanded: $isExpanded,
            content: {
                VStack(alignment: .leading, spacing: 8) {
                    // Display minimal and maximal angles
                    Text("Minimal angle: \(Int(minAngle))°")
                        .font(.subheadline)
                    Text("Maximal angle: \(Int(maxAngle))°")
                        .font(.subheadline)

                    // Recommended range
                    Text("Recommended range: \(Int(recommendedRange.min))° - \(Int(recommendedRange.max))°")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    // Scale with gradient and markers
                    AngleRangeIndicator(
                        minAngle: minAngle,
                        maxAngle: maxAngle,
                        currentRange: (min: recommendedRange.min, max: recommendedRange.max)
                    )
                    .frame(height: 20) // Height of the scale
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                )
                //.padding(.horizontal, 16) // Slight offset for gray rectangle
            },
            label: {
                HStack {
                    Text(label)
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(Int(minAngle))° - \(Int(maxAngle))°")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    Image(systemName: "chevron.right") // Chevron icon
                        .rotationEffect(.degrees(isExpanded ? 90 : 0)) // Rotate when expanded
                        .foregroundColor(.white)
                }
                .padding()
                .frame(maxWidth: UIScreen.main.bounds.width)// - 32) // Slight offset for purple rectangle
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.purple.opacity(0.75), Color.purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .cornerRadius(8)
                )
            }
        )
        .padding(.vertical, 2) // Reduced vertical padding between boxes
        .accentColor(.clear) // Remove default chevron color
    }
}

struct AngleRangeIndicator: View {
    let minAngle: Double
    let maxAngle: Double
    let currentRange: (min: Double, max: Double)

    var body: some View {
        VStack {
            HStack {
                // Display min range
                Text("\(Int(currentRange.min))°")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background gradient for the range
                        LinearGradient(
                            gradient: Gradient(colors: [.yellow, .green, .yellow]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(height: 10)
                        .cornerRadius(5)

                        // Marker for the minimum angle
                        let minPosition = calculatePosition(for: minAngle, width: geometry.size.width)
                        Circle()
                            .frame(width: 14, height: 14)
                            .foregroundColor(.gray)
                            .offset(x: minPosition - 6) // Center the marker

                        // Marker for the maximum angle
                        let maxPosition = calculatePosition(for: maxAngle, width: geometry.size.width)
                        Circle()
                            .frame(width: 14, height: 14)
                            .foregroundColor(.gray)
                            .offset(x: maxPosition - 6) // Center the marker
                    }
                }

                // Display max range
                Text("\(Int(currentRange.max))°")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
        .frame(height: 20) // Fixed height for the scale
    }

    private func calculatePosition(for angle: Double, width: CGFloat) -> CGFloat {
        let clampedAngle = min(max(angle, currentRange.min), currentRange.max)
        let range = currentRange.max - currentRange.min
        let normalizedPosition = (clampedAngle - currentRange.min) / range
        return CGFloat(normalizedPosition) * width
    }
}



extension UIImage {
    func toCVPixelBuffer() -> CVPixelBuffer? {
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault, Int(size.width), Int(size.height),
            kCVPixelFormatType_32ARGB, attrs, &pixelBuffer
        )
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return nil }

        CVPixelBufferLockBaseAddress(buffer, [])
        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        )
        guard let cgImage = self.cgImage else { return nil }
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        CVPixelBufferUnlockBaseAddress(buffer, [])
        return buffer
    }
}

