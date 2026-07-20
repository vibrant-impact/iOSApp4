//
//  UnifiedControlConsoleView.swift
//  iOSApp4
//
//  Created by stephanie otteson on 2026-07-19.
//

import SwiftUI

struct UnifiedControlConsoleView: View {
    @Binding var parameters: SoundscapeParameters
    
    var body: some View {
        VStack(spacing: 24) {
            
            // MARK: - Main Melody Channel
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Label("Main Melody", systemImage: "music.note.house.fill")
                        .font(.headline)
                        .foregroundColor(.indigo)
                    
                    Spacer()
                    
                    Toggle("", isOn: $parameters.isBaseMelodyActive)
                        .labelsHidden()
                        .tint(.indigo)
                }
                
                if parameters.isBaseMelodyActive {
                    BaseMelodyCarouselView(selectedMelodyOption: $parameters.selectedBaseMelodyLoop)
                    
                    MixerSliderRow(
                        label: "Main Melody Volume",
                        icon: "speaker.wave.3.fill",
                        value: $parameters.baseMelodyVolume,
                        sliderRange: 0.0...1.0,
                        displayDivisor: 1.0,
                        accentColor: .indigo
                    )
                }
            }
            .padding()
            .background(Color.white.opacity(0.03))
            .cornerRadius(16)
            
            // MARK: - Instrument Channel
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Label("Instrument Channel", systemImage: "guitars.fill")
                        .font(.headline)
                        .foregroundColor(.teal)
                    
                    Spacer()
                    
                    Toggle("", isOn: $parameters.isInstrumentActive)
                        .labelsHidden()
                        .tint(.teal)
                }
                
                if parameters.isInstrumentActive {
                    InstrumentSelectorCard(parameters: $parameters)
                    
                    MixerSliderRow(
                        label: "Instrument Volume",
                        icon: "speaker.wave.3.fill",
                        value: $parameters.instrumentVolume,
                        sliderRange: 0.0...1.0,
                        displayDivisor: 1.0,
                        accentColor: .teal
                    )
                }
            }
            .padding()
            .background(Color.white.opacity(0.03))
            .cornerRadius(16)
            
            // MARK: - Algorithm Channel
            VStack(alignment: .leading, spacing: 16) {
                Label("Markov Chain Algorithm", systemImage: "shuffle.circle.fill")
                    .font(.headline)
                    .foregroundColor(.purple)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Musical Scale")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
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
                }
                
                MixerSliderRow(
                    label: "Note Pace (Interval Delay)",
                    icon: "timer",
                    value: $parameters.melodySpeed,
                    sliderRange: 0.15...3.0,
                    displayDivisor: 3.0,
                    accentColor: .purple
                )
            }
            .padding()
            .background(Color.white.opacity(0.03))
            .cornerRadius(16)
        }
    }
}
