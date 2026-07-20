//
//  AppRootView.swift
//  iOSApp4
//
//  Created by stephanie otteson on 2026-07-19.
//

import SwiftUI

struct AppRootView: View {
    @StateObject private var ambientViewModel = AmbientViewModel()
    @State private var isDiscoverSheetOpen: Bool = false
    
    var body: some View {
        let activeTheme = AppTheme.current(for: ambientViewModel.parameters.scale)
        
        ZStack {
            // Background Canvas Fluid Layer
            activeTheme.bgGradient
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // MARK: - Header Section
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            
                            HStack(spacing: 8) {
                                Image(systemName: "radio.fill")
                                    .foregroundColor(activeTheme.accentColor)
                                    .symbolEffect(.pulse, isActive: ambientViewModel.isPlaying)
                                
                                Text("Generative Ambient")
                                    .font(.system(.title3, design: .default))
                                    .bold()
                                    .foregroundColor(.white)
                                
                                Text(activeTheme.name)
                                    .font(.system(.caption2, design: .monospaced))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(activeTheme.badgeBg)
                                    .foregroundColor(activeTheme.accentColor)
                                    .cornerRadius(6)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(activeTheme.accentColor.opacity(0.3), lineWidth: 0.5)
                                    )
                            }
                            Text("Mathematical soundscapes generated on-the-fly using Markov walks.")
                                .font(.caption)
                                .foregroundColor(.slate)
                        }
                        Spacer()
                    }
                    .padding(.top, 16)
                    
                    // MARK: - Master Action Audio Trigger Panel
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Endless Generation Engine")
                                .font(.system(.caption, design: .monospaced))
                                .bold()
                                .foregroundColor(activeTheme.accentColor)
                            
                            Text(ambientViewModel.isPlaying ? "Immersive audio is active" : "Initiate unique ambient audio")
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Button(action: { ambientViewModel.togglePlayback() }) {
                            Image(systemName: ambientViewModel.isPlaying ? "pause.fill" : "play.fill")
                                .font(.title2)
                                .foregroundColor(.black)
                                .frame(width: 56, height: 56)
                                .background(
                                    Circle()
                                        .fill(ambientViewModel.isPlaying ? Color.red : activeTheme.accentColor)
                                )
                                .shadow(color: (ambientViewModel.isPlaying ? Color.red : activeTheme.accentColor).opacity(0.3), radius: 10)
                        }
                    }
                    .padding(20)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    
                    // MARK: - Visualizer Stack
                    VStack(spacing: 0) {
                        // Original, beautiful particle visualizer
                        WaveformVisualizerView(
                            activeNoteName: ambientViewModel.activeNoteName,
                            activeNoteFrequency: ambientViewModel.activeNoteFrequency,
                            lfoRate: ambientViewModel.parameters.lfoRate,
                            isPlaying: ambientViewModel.isPlaying
                        )
                        
                        // New continuous breathing waveform as a visual anchor
                        ContinuousWaveformView(
                            isEnginePlaying: ambientViewModel.isPlaying,
                            activeNoteFrequency: ambientViewModel.activeNoteFrequency
                        )
                        .padding(.top, 8)
                    }
                    .padding()
                    .background(Color.black.opacity(0.2)) // Shared backdrop to unite them
                    .cornerRadius(20)
                    
                    // MARK: - Controllers Matrix
                    VStack(spacing: 20) {
                        
                        // The unified console replaces the three scattered individual cards
                        UnifiedControlConsoleView(parameters: $ambientViewModel.parameters)
                        
                        // Soundscape Mixer Component Container (Kept for the atmospheric canvas loops)
                        SoundscapeMixerCard(ambientViewModel: ambientViewModel)
                        
                        // Preset Selector
                        PresetManagerView(viewModel: ambientViewModel)
                    }
                }
                .padding(.horizontal)
            }
        }
        .environment(\.colorScheme, ColorScheme.dark) // Enforce crisp high-contrast dark palette
        // Watch parameter updates and sync them directly to the native audio hardware
        .onChange(of: ambientViewModel.parameters) { _, _ in
            ambientViewModel.updateEngineParameters()
        }
    }
}
