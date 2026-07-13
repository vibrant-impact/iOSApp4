//
//  PresetManagerView.swift
//  iOSApp4
//
//  Created by stephanie otteson on 2026-07-12.
//

import SwiftUI

struct PresetManagerView: View {
    @ObservedObject var viewModel: AmbientViewModel
    @State private var newSceneName: String = ""
    @State private var activeTab: PresetTab = .presets
    
    enum PresetTab {
        case presets
        case saved
    }
    
    // MARK: - Curated Factory Presets Listing
    // Replicates your exact curated scenes data arrays natively
    private let curatedPresets: [(name: String, description: String, params: SoundscapeParams)] = [
        ("Pacific Solitude", "Deep ocean swells with slow, spacious minor melodies, wind chimes, and trailing delays.", SoundscapeParams(oceanVolume: 0.9, droneVolume: 0.5, rainVolume: 0.1, harpVolume: 0.1, chimesVolume: 0.6, bowlsVolume: 0.5, fluteVolume: 0.3, melodySpeed: 2.0, melodyJumpiness: 1, melodyDrift: -0.1, scale: .aMinorPentatonic, octave: 3, lfoRate: 1.0/45.0, lfoDepth: 1200, delayTime: 1.2, delayFeedback: 0.75, delayMix: 0.6, masterVolume: 0.8)),
        ("Cosmic Nebula", "Shining sweep filters, high speed LFOs, and sparkling wind chime walks.", SoundscapeParams(oceanVolume: 0.2, droneVolume: 0.7, rainVolume: 0.4, harpVolume: 0.0, chimesVolume: 0.8, bowlsVolume: 0.6, fluteVolume: 0.2, melodySpeed: 1.1, melodyJumpiness: 2, melodyDrift: 0.25, scale: .hirajoshi, octave: 4, lfoRate: 1.0/15.0, lfoDepth: 2200, delayTime: 0.6, delayFeedback: 0.65, delayMix: 0.55, masterVolume: 0.8)),
        ("Zen Temple Garden", "Gentle water ripples, sparkling acoustic harp, and a perfectly balanced C Major Pentatonic melody.", SoundscapeParams(oceanVolume: 0.45, droneVolume: 0.2, rainVolume: 0.7, harpVolume: 0.4, chimesVolume: 0.5, bowlsVolume: 0.8, fluteVolume: 0.6, melodySpeed: 1.4, melodyJumpiness: 1, melodyDrift: 0.0, scale: .cMajorPentatonic, octave: 4, lfoRate: 1.0/30.0, lfoDepth: 800, delayTime: 1.0, delayFeedback: 0.85, delayMix: 0.7, masterVolume: 0.85)),
        ("Dorian Rain Cathedral", "Heavy pouring textures matched with deep meditative harp arpeggios and dark Dorian chords.", SoundscapeParams(oceanVolume: 0.1, droneVolume: 0.85, rainVolume: 0.95, harpVolume: 0.7, chimesVolume: 0.2, bowlsVolume: 0.3, fluteVolume: 0.5, melodySpeed: 1.7, melodyJumpiness: 2, melodyDrift: -0.2, scale: .dDorian, octave: 3, lfoRate: 1.0/60.0, lfoDepth: 1500, delayTime: 0.8, delayFeedback: 0.8, delayMix: 0.5, masterVolume: 0.8)),
        ("Astral Shimmer", "Cosmic Lydian melodies ascending with sweeping air textures and bright chime cascades.", SoundscapeParams(oceanVolume: 0.3, droneVolume: 0.4, rainVolume: 0.2, harpVolume: 0.2, chimesVolume: 0.7, bowlsVolume: 0.4, fluteVolume: 0.7, melodySpeed: 0.8, melodyJumpiness: 3, melodyDrift: 0.35, scale: .eLydian, octave: 4, lfoRate: 1.0/12.0, lfoDepth: 2500, delayTime: 0.4, delayFeedback: 0.5, delayMix: 0.5, masterVolume: 0.75))
    ]
    
    var body: some View {
        let currentTheme = AppTheme.current(for: viewModel.params.scale)
        
        VStack(alignment: .leading, spacing: 16) {
            // MARK: - Header & Tab Switcher
            HStack {
                Label("Saved Playlists", systemImage: "folder.badge.plus")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(currentTheme.accentColor)
                
                Spacer()
                
                // Segmented Layout Bar
                HStack(spacing: 4) {
                    TabButton(text: "Curated", isActive: activeTab == .presets) { activeTab = .presets }
                    TabButton(text: "My Saved (\(viewModel.savedScenes.count))", isActive: activeTab == .saved) { activeTab = .saved }
                }
                .padding(2)
                .background(Color.black.opacity(0.3))
                .cornerRadius(8)
            }
            
            Text("Save, manage, and toggle customized ambient textures as reusable scenes instantly.")
                .font(.caption)
                .foregroundColor(.slate)
            
            // MARK: - Lists Content Engine
            VStack {
                switch activeTab {
                case .presets:
                    curatedPresetsView(theme: currentTheme)
                case .saved:
                    userSavedPresetsView(theme: currentTheme)
                }
            }
            .frame(maxHeight: 240) // Constrained bounds matching web max-h-56 container loops
            
            // MARK: - Add New Preset Form Element
            Divider()
                .background(Color.white.opacity(0.05))
            
            HStack(spacing: 10) {
                TextField("Name current soundscape...", text: $newSceneName)
                    .font(.caption)
                    .padding(10)
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                    .submitLabel(.done)
                    .onSubmit(submitNewPreset)
                
                Button(action: submitNewPreset) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.down")
                        Text("Save")
                    }
                    .font(.caption.bold())
                    .foregroundColor(.black)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(currentTheme.accentColor)
                    .cornerRadius(8)
                }
                .disabled(newSceneName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding()
        .background(Color.white.opacity(0.03))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
    
    // MARK: - Curated Scene Row Builder
    @ViewBuilder
    private func curatedPresetsView(theme: AppTheme) -> some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 8) {
                ForEach(0..<curatedPresets.count, id: \.self) { idx in
                    let preset = curatedPresets[idx]
                    let isLoaded = viewModel.params == preset.params
                    
                    Button(action: { viewModel.loadScene(preset.params) }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(preset.name)
                                    .font(.caption.bold())
                                    .foregroundColor(isLoaded ? theme.accentColor : .white)
                                Text(preset.description)
                                    .font(.system(size: 10))
                                    .foregroundColor(.slate)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                            }
                            Spacer()
                            
                            if isLoaded {
                                statusBadge(theme: theme)
                            } else {
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                                    .foregroundColor(.slate.opacity(0.5))
                            }
                        }
                        .padding(10)
                        .background(isLoaded ? theme.badgeBg.opacity(0.3) : Color.black.opacity(0.2))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isLoaded ? theme.accentColor.opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - User Saved Scene Row Builder
    @ViewBuilder
    private func userSavedPresetsView(theme: AppTheme) -> some View {
        if viewModel.savedScenes.isEmpty {
            VStack(spacing: 8) {
                Spacer()
                Image(systemName: "music.note.list")
                    .font(.title2)
                    .foregroundColor(.slate.opacity(0.4))
                Text("No saved scenes yet.")
                    .font(.caption)
                    .foregroundColor(.slate)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 8) {
                    ForEach(viewModel.savedScenes) { scene in
                        let isLoaded = viewModel.params == scene.params
                        
                        HStack {
                            Button(action: { viewModel.loadScene(scene.params) }) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(scene.name)
                                        .font(.caption.bold())
                                        .foregroundColor(isLoaded ? theme.accentColor : .white)
                                    Text("Created \(Date(timeIntervalSince1970: scene.createdAt).formatted(date: .abbreviated, time: .omitted))")
                                        .font(.system(size: 9, design: .monospaced))
                                        .foregroundColor(.slate.opacity(0.6))
                                }
                                Spacer()
                            }
                            
                            HStack(spacing: 12) {
                                if isLoaded {
                                    statusBadge(theme: theme)
                                }
                                
                                Button(action: { viewModel.deleteScene(id: scene.id) }) {
                                    Image(systemName: "trash")
                                        .font(.caption)
                                        .foregroundColor(.red.opacity(0.7))
                                }
                            }
                        }
                        .padding(10)
                        .background(isLoaded ? theme.badgeBg.opacity(0.3) : Color.black.opacity(0.2))
                        .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    // MARK: - View Component Helpers
    @ViewBuilder
    private func statusBadge(theme: AppTheme) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(theme.accentColor)
                .frame(width: 4, height: 4)
                .symbolEffect(.pulse, isActive: viewModel.isPlaying)
            Text(viewModel.isPlaying ? "Playing" : "Loaded")
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(theme.accentColor)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(theme.badgeBg)
        .cornerRadius(6)
    }
    
    private func submitNewPreset() {
        let name = newSceneName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        viewModel.saveCurrentScene(named: name)
        newSceneName = ""
    }
}

// MARK: - Subview Row Layout Tab Link Button
struct TabButton: View {
    let text: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 10, weight: isActive ? .bold : .medium, design: .monospaced))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(isActive ? Color.white.opacity(0.1) : Color.clear)
                .foregroundColor(isActive ? .white : .slate)
                .cornerRadius(6)
        }
    }
}
