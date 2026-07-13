//
//  AppRootView.swift
//  iOSApp4
//
//  Created by stephanie otteson on 2026-07-12.
//

import SwiftUI

struct AppRootView: View {
    @StateObject private var viewModel = AmbientViewModel()
    
    var body: some View {
        let theme = AppTheme.current(for: viewModel.params.scale)
        
        ZStack {
            // Background Canvas Fluid Layer
            theme.bgGradient
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // HEADER SECTION
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                Image(systemName: "radio.fill")
                                    .foregroundColor(theme.accentColor)
                                    .symbolEffect(.pulse, isActive: viewModel.isPlaying)
                                
                                Text("Generative Ambient")
                                    .font(.system(.title3, design: .default))
                                    .bold()
                                    .foregroundColor(.white)
                                
                                Text(theme.name)
                                    .font(.system(.caption2, design: .monospaced))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(theme.badgeBg)
                                    .foregroundColor(theme.accentColor)
                                    .cornerRadius(6)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(theme.accentColor.opacity(0.3), lineWidth: 0.5)
                                    )
                            }
                            Text("Mathematical soundscapes generated on-the-fly using Markov walks.")
                                .font(.caption)
                                .foregroundColor(.slate)
                        }
                        Spacer()
                    }
                    .padding(.top, 16)
                    
                    // VISUALIZER PREVIEW PIPELINE
                    WaveformVisualizerView(
                        activeNoteName: viewModel.activeNoteName,
                        activeNoteFrequency: viewModel.activeNoteFrequency,
                        lfoRate: viewModel.params.lfoRate,
                        isPlaying: viewModel.isPlaying
                    )
                    
                    // MASTER ACTION AUDIO TRIGGER PANEL
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Endless Generation Engine")
                                .font(.system(.caption, design: .monospaced))
                                .bold()
                                .foregroundColor(theme.accentColor)
                            
                            Text(viewModel.isPlaying ? "Immersive audio is active" : "Initiate unique ambient audio")
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Button(action: { viewModel.togglePlayback() }) {
                            Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                                .font(.title2)
                                .foregroundColor(.black)
                                .frame(width: 56, height: 56)
                                .background(
                                    Circle()
                                        .fill(viewModel.isPlaying ? Color.red : theme.accentColor)
                                )
                                .shadow(color: (viewModel.isPlaying ? Color.red : theme.accentColor).opacity(0.3), radius: 10)
                        }
                    }
                    .padding(20)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    
                    // CONTROLLERS MATRIX
                    VStack(spacing: 20) {
                        // Soundscape Mixer Component Container
                        SoundscapeMixerCard(params: $viewModel.params)
                        
                        // Scale / Algorithm Control Configuration
                        MelodyEngineCard(params: $viewModel.params)
                        
                        // Preset Selector
                        PresetManagerView(viewModel: viewModel)
                    }
                }
                .padding(.horizontal)
            }
        }
        .environment(\.colorScheme, ColorScheme.dark) // Enforce crisp high-contrast dark palette
        // Watch parameter updates and sync them directly to the native audio hardware
        .onChange(of: viewModel.params) { _, _ in
            viewModel.updateEngineParams()
        }
    }
}
