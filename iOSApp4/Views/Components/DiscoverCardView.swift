//
//  DiscoverCardView.swift
//  iOSApp4
//
//  Created by stephanie otteson on 2026-07-16.
//

import SwiftUI

struct DiscoverCardView: View {
    let sceneData: SavedScene
    let playAction: () -> Void
    
    var body: some View {
        ZStack {
            // MARK: - Sacred Geometry Background Accents
            GeometryReader { geo in
                Circle()
                    .stroke(lineWidth: 1)
                    .foregroundColor(.white.opacity(0.1))
                    .frame(width: geo.size.width * 0.8)
                    .offset(x: -geo.size.width * 0.1, y: -geo.size.height * 0.2)
                
                Circle()
                    .stroke(lineWidth: 0.5)
                    .foregroundColor(.white.opacity(0.05))
                    .frame(width: geo.size.width * 1.2)
                    .offset(x: geo.size.width * 0.3, y: geo.size.height * 0.1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
            
            // MARK: - Card Content
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(sceneData.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("Ambient Generative")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Button(action: playAction) {
                        Image(systemName: "play.circle.fill")
                            .resizable()
                            .frame(width: 44, height: 44)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                }
                
                // Audio Parameter Tags
                HStack(spacing: 8) {
                    parameterTag(icon: "waveform.path", value: "Drift: \(String(format: "%.1f", sceneData.parameters.melodyDrift))")
                    parameterTag(icon: "hare.fill", value: "Speed: \(String(format: "%.1f", sceneData.parameters.melodySpeed))")
                }
            }
            .padding(24)
        }
        // MARK: - Glassmorphism modifiers
        .background(.ultraThinMaterial)
        .environment(\.colorScheme, .dark) // Forces the material to be dark glass
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
    
    // MARK: - Helper UI Component
    @ViewBuilder
    private func parameterTag(icon: String, value: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .foregroundColor(.white.opacity(0.9))
    }
}
