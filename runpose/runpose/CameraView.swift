import SwiftUI
import AVFoundation
import AVKit

struct CameraView: View {
    @State private var isVideoPickerDisplayed = false
    @State private var selectedVideoURL: URL?
    @State private var navigateToVideoChecker = false
    @State private var navigateToPoseAnalyzer = false
    @State private var isVideoUploadedOK = false
    @State private var isVideoValidated = false

    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                if let videoURL = selectedVideoURL, isVideoUploadedOK {
                    AVPlayerLayerRepresentable(videoURL: videoURL)
                        .frame(maxWidth: 300, maxHeight: 300)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isVideoValidated ? Color.green : Color.gray, lineWidth: 5)
                        )

                    Text("Video is ready to be validated.")
                        .foregroundColor(.gray)
                        .padding(.bottom, 5)

                    Button(action: {
                        print("Validate video button clicked") // Debug: Button press
                        navigateToVideoChecker = true
                    }) {
                        Label("Validate video", systemImage: "checkmark.circle")
                    }
                    .buttonStyle(PurpleButtonStyle())

                    Button(action: {
                        if isVideoValidated {
                            navigateToPoseAnalyzer = true
                        } else {
                            alertMessage = "Video must be validated first before analysis."
                            showAlert = true
                        }
                    }) {
                        Label("Analyse running pose", systemImage: "person.crop.rectangle")
                    }
                    .buttonStyle(PurpleButtonStyle())

                    Button("Change Video") {
                        isVideoPickerDisplayed = true
                    }
                    .buttonStyle(YellowButtonStyle())
                } else {
                    Spacer()

                    NavigationLink(destination: HowToVideo()) {
                        VStack {
                            Text("VIDEO MUST BE 5 SECONDS OR SHORTER")
                                .font(.headline)
                                .foregroundColor(.purple)
                                .padding(.top, 5)

                            Image(systemName: "info.circle")
                                .font(.system(size: 50))
                                .foregroundColor(.purple)
                                .padding(.top, 5)

                            Text("Read: How to record a proper video for pose analysis?")
                                .font(.headline)
                                .foregroundColor(.purple)
                                .padding(.top, 5)
                        }
                        .padding()
                        .background(Color.clear)
                    }

                    Spacer()

                    Text("No video selected")
                        .foregroundColor(.secondary)

                    Button("Upload Video") {
                        isVideoPickerDisplayed = true
                    }
                    .buttonStyle(PurpleButtonStyle())

                    NavigationLink(destination: ComingSoon()) {
                        Text("Record Video")
                    }
                    .buttonStyle(GreyButtonStyle())
                }
            }
            .padding()
            .navigationBarTitle("Record or upload running video", displayMode: .inline)
            .sheet(isPresented: $isVideoPickerDisplayed) {
                VideoPicker(selectedVideoURL: $selectedVideoURL, isVideoUploadedOK: $isVideoUploadedOK, alertMessage: $alertMessage, showAlert: $showAlert)
                    .onChange(of: selectedVideoURL) {
                        isVideoValidated = false
                    }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Upload Result"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }

            // Navigation destinations using boolean flags
            .navigationDestination(isPresented: $navigateToVideoChecker) {
                if let videoURL = selectedVideoURL {
                    VideoChecker(videoURL: videoURL, validationHandler: { isValid in
                        isVideoValidated = isValid
                    })
                } else {
                    Text("No video available")
                }
            }
            .navigationDestination(isPresented: $navigateToPoseAnalyzer) {
                Text("Pose Analyzer Placeholder") // Placeholder for PoseAnalyzer view
            }
        }
    }
}

// Video preview view
struct VideoPlayerView: View {
    let url: URL
    
    var body: some View {
        VideoPlayer(player: AVPlayer(url: url))
            .onDisappear { AVPlayer(url: url).pause() }
    }
}

struct VideoPicker: UIViewControllerRepresentable {
    @Binding var selectedVideoURL: URL?
    @Binding var isVideoUploadedOK: Bool
    @Binding var alertMessage: String
    @Binding var showAlert: Bool

    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.mediaTypes = ["public.movie"]
        return picker
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // Intentionally left empty
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: VideoPicker

        init(_ parent: VideoPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let videoURL = info[.mediaURL] as? URL {
                let asset = AVAsset(url: videoURL)
                
                // Asynchronously load the duration
                Task {
                    do {
                        let duration = try await asset.load(.duration)
                        let durationSeconds = CMTimeGetSeconds(duration)
                        
                        DispatchQueue.main.async {
                            if durationSeconds <= 5.0 {
                                self.parent.selectedVideoURL = videoURL
                                self.parent.isVideoUploadedOK = true
                                self.parent.alertMessage = "Video has been uploaded sucessfully. Duration: \(durationSeconds) seconds."
                            } else {
                                self.parent.isVideoUploadedOK = false
                                self.parent.alertMessage = "The selected video is longer than 5 seconds. Please select a shorter video."
                            }
                            self.parent.showAlert = true
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self.parent.alertMessage = "Failed to load video duration."
                            self.parent.showAlert = true
                        }
                    }
                }
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// Custom UIViewRepresentable for AVPlayerLayer
struct AVPlayerLayerRepresentable: UIViewRepresentable {
    let videoURL: URL
    private let player = AVPlayer()

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        playerLayer.frame = view.bounds
        view.layer.addSublayer(playerLayer)
        
        player.replaceCurrentItem(with: AVPlayerItem(url: videoURL))
        player.play()
        
        // Observe bounds changes to update player layer's frame
        view.layer.setNeedsLayout()
        view.layer.layoutIfNeeded()

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let playerLayer = uiView.layer.sublayers?.first as? AVPlayerLayer {
            playerLayer.frame = uiView.bounds
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
            .previewDisplayName("Camera View - Initial State")
    }
}

