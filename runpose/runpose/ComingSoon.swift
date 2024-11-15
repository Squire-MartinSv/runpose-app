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
                    FeatureView(title: "Live analytics of video", description: "Have the pose rendered directly in the video.")
                    FeatureView(title: "Ability to take video directly in the app", description: "Take video directly within the app and have the video automatically optimized for the best angles analysis.")
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


