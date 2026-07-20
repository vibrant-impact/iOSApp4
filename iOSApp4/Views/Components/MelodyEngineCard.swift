//
//  MelodyEngineCard.swift
//  iOSApp4
//
//  Created by stephanie otteson on 2026-07-12.
//

import SwiftUI

struct MelodyEngineCard: View {
    @Binding var parameters: SoundscapeParameters
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Markov Chain Random Walk", systemImage: "shuffle")
                .font(.subheadline)
                .bold()
                .foregroundColor(.indigo)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Select Musical Scale / Vibe")
                    .font(.caption)
                    .foregroundColor(.slate)
                
                Picker("Scale Selection", selection: $parameters.scale) {
                    Text("C Major Pentatonic").tag(MusicalScale.cMajorPentatonic)
                    Text("A Minor Pentatonic").tag(MusicalScale.aMinorPentatonic)
                    Text("E Lydian (Cosmic)").tag(MusicalScale.eLydian)
                    Text("D Dorian (Deep)").tag(MusicalScale.dDorian)
                    Text("Hirajoshi (Zen)").tag(MusicalScale.hirajoshi)
                }
                .pickerStyle(.menu)
                .tint(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 4)
            }
            
            VStack(spacing: 12) {
                MixerSliderRow(
                    label: "Note Pace (Interval Delay)",
                    icon: "timer",
                    value: $parameters.melodySpeed,
                    sliderRange: 0.15...3.0, // Expanded maximum internal scale
                    displayDivisor: 3.0,     // Divides UI text output by 3
                    accentColor: .indigo
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.03))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
}
