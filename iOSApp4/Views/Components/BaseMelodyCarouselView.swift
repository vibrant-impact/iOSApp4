//
//  BaseMelodyCarouselView.swift
//  iOSApp4
//
//  Created by stephanie otteson on 2026-07-19.
//

import SwiftUI

struct BaseMelodyCarouselView: View {
    @Binding var selectedMelodyOption: BaseMelodyLoopOption
    
    // Tracks favorites locally for the UI.
    // Later, this can be moved to your ViewModel to save to Firestore.
    @State private var favoriteBaseMelodies: Set<BaseMelodyLoopOption> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(BaseMelodyLoopOption.allCases, id: \.self) { melodyOption in
                        MelodySelectionCard(
                            melodyOption: melodyOption,
                            isSelected: selectedMelodyOption == melodyOption,
                            isFavorite: favoriteBaseMelodies.contains(melodyOption),
                            onSelect: {
                                selectedMelodyOption = melodyOption
                            },
                            onFavoriteToggle: {
                                toggleFavoriteStatus(for: melodyOption)
                            }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }
    }
    
    private func toggleFavoriteStatus(for melodyOption: BaseMelodyLoopOption) {
        if favoriteBaseMelodies.contains(melodyOption) {
            favoriteBaseMelodies.remove(melodyOption)
        } else {
            favoriteBaseMelodies.insert(melodyOption)
        }
    }
}

struct MelodySelectionCard: View {
    let melodyOption: BaseMelodyLoopOption
    let isSelected: Bool
    let isFavorite: Bool
    let onSelect: () -> Void
    let onFavoriteToggle: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: onFavoriteToggle) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        // NEW: Dynamic color logic for better contrast
                        .foregroundColor(
                            isFavorite ? .pink : (isSelected ? .white.opacity(0.8) : .gray.opacity(0.5))
                        )
                        .padding(8)
                }
            }
            
            Spacer()
            
            Text(melodyOption.rawValue)
                .font(.caption)
                .bold()
                .multilineTextAlignment(.center)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.bottom, 12)
                .padding(.horizontal, 4)
        }
        .frame(width: 120, height: 120)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? Color.indigo : Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.indigo.opacity(0.5) : Color.gray.opacity(0.2), lineWidth: 1)
        )
        // Animates the selection state smoothly
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .onTapGesture {
            onSelect()
        }
    }
}
