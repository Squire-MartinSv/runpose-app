//
//  ComingSoon.swift
//  runpose
//
//  Created by Martin Svadlenka on 12.11.2024.
//

import SwiftUI

struct ComingSoon: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Upcoming Features")) {
                    FeatureView(title: "Record a video", description: "Record video directly in the application and have the video automatically optimized for the best angles analysis.")
                    FeatureView(title: "Video modifications", description: "Runpose automatically adjusts video properties, such as brightness and other settings, to optimize the analysis of running posture.")
                    FeatureView(title: "Pick a side", description: "Select whether the video captures the runner's left or right side. This choice enhances the accuracy of posture measurements.")
                }
            }
            .navigationTitle("Features Coming Soon")
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(GroupedListStyle())
        }
    }
}

struct FeatureView: View {
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

struct ComingSoon_Previews: PreviewProvider {
    static var previews: some View {
        ComingSoon()
    }
}


