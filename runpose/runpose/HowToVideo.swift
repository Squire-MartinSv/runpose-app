//
//  HowToVideo.swift
//  runpose
//
//  Created by Martin Svadlenka on 15.11.2024.
//

import SwiftUI

struct HowToVideo: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("")) {
                    HowToSteps(title: "Length of the video", description: "The application limits video duration to a maximum of 5 seconds to ensure efficient processing. Five seconds is sufficient for optimal angle analysis. Additionally, the video must be at least 2 seconds long to accurately capture and analyze the runner's movements.")
                    HowToSteps(title: "Make sure there is only one person.", description: "There has to be only one clearly recorded person in the video. In other case the analysis might be corrupted and angles misscalculated in between multiple personas in the video.")
                    HowToSteps(title: "Make sure the runner is fully visible", description: "The runner has to be fully visible within the whole video footage in order to process and analyse body position angles correctly.")
                    HowToSteps(title: "Take the video from side", description: "For optimal analysis and angles precision, the video must be taken from the side of the runner.")
                }
            }
            .navigationTitle("How to take a video")
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(GroupedListStyle())
        }
    }
}

struct HowToSteps: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical)
    }
}

struct HowToVideo_Previews: PreviewProvider {
    static var previews: some View {
        ComingSoon()
    }
}
