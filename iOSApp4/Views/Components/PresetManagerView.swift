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
        case community
    }
    
    // MARK: - Curated Factory Presets Listing
    // Temporarily empty; to be redefined later
    private let curatedPresets: [(name: String, description: String, parameters: SoundscapeParameters)] = []
    
    var body: some View {
        let currentTheme = AppTheme.current(for: viewModel.parameters.scale)
        
        VStack(alignment: .leading, spacing: 16) {
            // MARK: - Header & Tab Switcher
            VStack(alignment: .leading, spacing: 12) {
                Label("Saved Playlists", systemImage: "folder.badge.plus")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(currentTheme.accentColor)

                // temp developer button to add community files
                Button(action: {
                    viewModel.seedCommunityScenes()
                }) {
                    Text("Seed Mock Community Data")
                        .font(.caption)
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
                
                // Segmented Layout Bar - Now stretching full width below the title!
                HStack(spacing: 4) {
                    TabButton(text: "Curated", isActive: activeTab == .presets) { activeTab = .presets }
                    TabButton(text: "My Saved (\(viewModel.savedScenes.count))", isActive: activeTab == .saved) { activeTab = .saved }
                    TabButton(text: "Community", isActive: activeTab == .community) { activeTab = .community }
                }
                .frame(maxWidth: .infinity)
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
                case .community:
                    communityPresetsView(theme: currentTheme)
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
                    let isLoaded = viewModel.parameters == preset.parameters
                    
                    Button(action: { viewModel.loadScene(preset.parameters) }) {
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
                        let isLoaded = viewModel.parameters == scene.parameters
                        
                        HStack {
                            Button(action: { viewModel.loadScene(scene.parameters) }) {
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
                                
                                Button(action: { viewModel.deleteScene(sceneId: scene.id) }) {
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
    
    // MARK: - Community Scene Row Builder
    @ViewBuilder
    private func communityPresetsView(theme: AppTheme) -> some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 12) {
                if viewModel.isLoadingCommunityScenes {
                    // Active Loading State
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: theme.accentColor))
                        Text("Discovering soundscapes...")
                            .font(.caption)
                            .foregroundColor(.slate)
                    }
                    .padding(.top, 30)
                    
                } else if viewModel.communityScenes.isEmpty {
                    // Graceful Empty or Network Error State
                    VStack(spacing: 8) {
                        Image(systemName: "icloud.slash")
                            .font(.title2)
                            .foregroundColor(.slate.opacity(0.4))
                        Text("No community scenes found.")
                            .font(.caption)
                            .foregroundColor(.slate)
                    }
                    .padding(.top, 30)
                    
                } else {
                    // Successful Data State
                    ForEach(viewModel.communityScenes) { sceneItem in
                        DiscoverCardView(
                            sceneData: sceneItem,
                            playAction: {
                                viewModel.loadScene(sceneItem.parameters)
                                viewModel.updateEngineParameters()
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
        }
        .onAppear {
            // Only fetch if we don't already have data, saving Firestore reads
            if viewModel.communityScenes.isEmpty {
                viewModel.fetchCommunityScenes()
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
                .padding(.horizontal, 4)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity) // Stretches the tabs to fill the bar evenly
                .background(isActive ? Color.white.opacity(0.1) : Color.clear)
                .foregroundColor(isActive ? .white : .slate)
                .cornerRadius(6)
        }
    }
}
