//
//  DiscoverFeedSheet.swift
//  iOSApp4
//
//  Created by stephanie otteson on 2026-07-16.
//

import SwiftUI

struct DiscoverFeedSheet: View {
    @ObservedObject var viewModel: AmbientViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                // Deep space background to match the aesthetic
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // For right now, we will just loop through your own saved scenes
                        // to test the UI until we write the global public query!
                        ForEach(viewModel.savedScenes, id: \.id) { sceneItem in
                            DiscoverCardView(
                                sceneData: sceneItem,
                                playAction: {
                                    viewModel.loadScene(sceneItem.parameters)
                                    viewModel.updateEngineParameters()
                                }
                            )
                        }
                    }
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle("Community Vibes")
            .navigationBarTitleDisplayMode(.inline)
            // Optional: add a close button if the user prefers tapping over dragging
        }
        // Force dark mode to maintain the esoteric visual identity
        .environment(\.colorScheme, .dark)
    }
}
