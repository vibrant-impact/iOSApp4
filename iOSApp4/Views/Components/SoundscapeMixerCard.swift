//
//  SoundscapeMixerCard.swift
//  iOSApp4
//
//  Created by stephanie otteson on 2026-07-12.
//

import SwiftUI

struct SoundscapeMixerCard: View {
    @Binding var params: SoundscapeParams
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Soundscape Mixer", systemImage: "waveform.and.mic")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.emerald)
                Spacer()
                Text("Ambience")
                    .font(.system(.caption2, design: .monospaced))
                    .padding(.horizontal, 6)
                    .background(Color.emerald.opacity(0.1))
                    .cornerRadius(4)
            }
            
            VStack(spacing: 12) {
                MixerSliderRow(label: "Ocean Waves (Noise Swell)", icon: "waveform.path.ecg", value: $params.oceanVolume, accentColor: .blue)
                MixerSliderRow(label: "Gentle Rain (Bandpass)", icon: "cloud.rain", value: $params.rainVolume, accentColor: .sky)
                MixerSliderRow(label: "Harmonic Drone (Bass Pad)", icon: "wind", value: $params.droneVolume, accentColor: .amber)
                MixerSliderRow(label: "Acoustic Harp (Plucks)", icon: "music.note", value: $params.harpVolume, accentColor: .pink)
            }
        }
        .padding()
        .background(Color.white.opacity(0.03))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
}

struct MixerSliderRow: View {
    let label: String
    let icon: String
    @Binding var value: Float
    let accentColor: Color
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Label(label, systemImage: icon)
                    .font(.caption)
                    .foregroundColor(.slate)
                Spacer()
                Text("\(Int(value * 100))%")
                    .font(.system(.caption, design: .monospaced))
                    .bold()
                    .foregroundColor(accentColor)
            }
            Slider(value: $value, in: 0...1)
                .tint(accentColor)
        }
    }
}
