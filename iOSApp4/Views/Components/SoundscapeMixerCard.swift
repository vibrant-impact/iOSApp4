//
//  SoundscapeMixerCard.swift
//  iOSApp4
//
//  Created by stephanie otteson on 2026-07-12.
//

import SwiftUI

import SwiftUI

struct SoundscapeMixerCard: View {
    @ObservedObject var ambientViewModel: AmbientViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Atmosphere Mixer")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.bottom, 4)
            
            VStack(spacing: 16) {
                // Ocean Waves
                MixerSliderRow(
                    label: "Ocean Waves",
                    icon: "water.waves",
                    value: $ambientViewModel.parameters.oceanVolume,
                    accentColor: .blue
                )
                .onChange(of: ambientViewModel.parameters.oceanVolume) {
                    ambientViewModel.updateEngineParameters()
                }
                
                // Rainfall
                MixerSliderRow(
                    label: "Rainfall",
                    icon: "cloud.rain",
                    value: $ambientViewModel.parameters.rainVolume,
                    accentColor: .teal
                )
                .onChange(of: ambientViewModel.parameters.rainVolume) {
                    ambientViewModel.updateEngineParameters()
                }
                
                // Deep Drone
                MixerSliderRow(
                    label: "Deep Drone",
                    icon: "aqi.low",
                    value: $ambientViewModel.parameters.droneVolume,
                    accentColor: .purple
                )
                .onChange(of: ambientViewModel.parameters.droneVolume) {
                    ambientViewModel.updateEngineParameters()
                }
                
                // Djembe Rhythm
                MixerSliderRow(
                    label: "Djembe Rhythm",
                    icon: "circle.grid.cross",
                    value: $ambientViewModel.parameters.djembeVolume,
                    accentColor: .orange
                )
                .onChange(of: ambientViewModel.parameters.djembeVolume) {
                    ambientViewModel.updateEngineParameters()
                }
                
                // Shaker
                MixerSliderRow(
                    label: "Shaker",
                    icon: "sparkles",
                    value: $ambientViewModel.parameters.shakerVolume,
                    accentColor: .yellow
                )
                .onChange(of: ambientViewModel.parameters.shakerVolume) {
                    ambientViewModel.updateEngineParameters()
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
        )
    }
}
