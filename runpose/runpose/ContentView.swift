//
//  ContentView.swift
//  runpose
//
//  Created by Martin Svadlenka on 11.11.2024.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenLicenseAndTerms") private var hasSeenLicenseAndTerms: Bool = false
    @AppStorage("hasSeenDisclaimer") private var hasSeenDisclaimer: Bool = false
    @State private var showLicenseAndTerms = false
    @State private var showDisclaimer = false

    var body: some View {
        GeometryReader { geometry in
            let isPortrait = geometry.size.height > geometry.size.width

            NavigationView {
                VStack {
                    Spacer()
                    Image("Runpose_logo_png")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding(.top, isPortrait ? 20 : 0)
                    
                    Text("Hello runner!")
                        .font(.headline)
                        .padding(.top, isPortrait ? 10 : 0)
                    
                    // Simplified intro text for landscape compatibility
                    Text("Use this app to check your running and get the info that help you understand it")
                        .padding()
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: isPortrait ? .infinity : geometry.size.width * 0.8)
                    
                    NavigationLink(destination: CameraView()) {
                        Text("Start analyzing!")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(10)
                    }
                    .padding()

                    VStack(spacing: 10) {
                        Button(action: {
                            showLicenseAndTerms = true
                        }) {
                            Text("License and Terms")
                                .foregroundColor(.blue)
                                .underline()
                        }
                        
                        Button(action: {
                            showDisclaimer = true
                        }) {
                            Text("Disclaimer")
                                .foregroundColor(.blue)
                                .underline()
                        }
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                }
                .navigationBarTitle("Home", displayMode: .inline)
                .sheet(isPresented: $showLicenseAndTerms) {
                    LicenseTermsView(isFirstLaunch: !hasSeenLicenseAndTerms) {
                        hasSeenLicenseAndTerms = true
                        showLicenseAndTerms = false
                        if !hasSeenDisclaimer {
                            showDisclaimer = true
                        }
                    }
                }
                .sheet(isPresented: $showDisclaimer) {
                    DisclaimerView {
                        hasSeenDisclaimer = true
                        showDisclaimer = false
                    }
                }
                .onAppear {
                    if !hasSeenLicenseAndTerms {
                        showLicenseAndTerms = true
                    } else if !hasSeenDisclaimer {
                        showDisclaimer = true
                    }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

struct DisclaimerView: View {
    @Environment(\.dismiss) var dismiss
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Disclaimer")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            Text("This app provides general guidance on body positioning for running. It is not intended to diagnose, treat, or provide any medical advice. Always consult a medical professional for any health or medical concerns. This app is for informational purposes only.")
                .padding()
                .multilineTextAlignment(.center)
            
            Button(action: {
                onClose()
                dismiss()
            }) {
                Text("I Understand")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(10)
            }
            .padding(.bottom)
        }
        .padding()
    }
}

struct LicenseTermsView: View {
    @Environment(\.dismiss) var dismiss
    let isFirstLaunch: Bool
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("License and Terms")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("License Agreement:")
                        .font(.headline)
                        .padding(.top)

                    Text("""
                    This app is licensed to you for personal use only. Redistribution, modification, or reverse-engineering of this application is strictly prohibited. The app is provided “as is” without any guarantees or warranties of any kind. By using this app, you agree to these terms.
                    """)

                    Text("Terms of Use:")
                        .font(.headline)
                        .padding(.top)

                    Text("""
                    This app provides angle measurements for body positioning while running, intended for informational purposes only. It is not a substitute for professional advice or medical consultations. The developers are not liable for any injuries, damages, or consequences resulting from the use of this app.
                    """)

                    Text("Legal Notices and Open Source Acknowledgment:")
                        .font(.headline)
                        .padding(.top)

                    Text("""
                    Copyright Notice:
                    The application "Runpose" utilizes YOLOv8 pose estimation models, part of the YOLO open-source project, licensed under the GNU Affero General Public License version 3 (AGPLv3).

                    License Details:
                    The YOLOv8 pose model is licensed under the AGPLv3, a free, copyleft license that permits use, modification, and distribution under specified terms.

                    Source Code Availability:
                    In accordance with the AGPLv3, the source code for "Runpose," including all modifications and underlying code, is available on our GitHub repository: https://github.com/Squire-MartinSv/runpose-app.git.

                    AGPLv3 Full Text:
                    To view the full terms of the AGPLv3 license, visit: https://www.gnu.org/licenses/agpl-3.0.html.

                    Disclaimer of Warranty:
                    "Runpose" is provided "AS IS," without warranties of any kind, either express or implied, including but not limited to warranties of merchantability, fitness for a particular purpose, or non-infringement. The authors, copyright holders, and contributors are not liable for any claims, damages, or liabilities arising from the use of this software.

                    Contribution and Modifications:
                    We encourage community contributions to "Runpose." If you'd like to contribute or suggest improvements, visit our GitHub repository. Your input and participation are greatly appreciated.
                    """)
                    .padding(.bottom, 20)

                }
                .padding()
            }

            // `Close` button is now always available
            Button(action: {
                onClose()
                dismiss()
            }) {
                Text("Close")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(10)
            }
            .padding(.bottom)
        }
        .padding()
    }
}


#Preview {
    ContentView()
}


