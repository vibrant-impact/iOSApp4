//
//  MixerSliderRow.swift
//  iOSApp4
//
//  Created by stephanie otteson on 2026-07-19.
//

import SwiftUI

struct MixerSliderRow: View {
    let label: String
    let icon: String
    @Binding var value: Float
    
    // Default values allow for standard 0-1 sliders,
    // but can be overridden for expanded ranges like your Melody Speed
    var sliderRange: ClosedRange<Float> = 0.0...1.0
    var displayDivisor: Float = 1.0
    var accentColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(accentColor)
                    .frame(width: 24)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Calculates the display percentage using full descriptive variables
                Text("\(Int((value / displayDivisor) * 100))%")
                    .font(.caption.monospacedDigit())
                    .foregroundColor(accentColor)
            }
            
            Slider(value: $value, in: sliderRange)
                .accentColor(accentColor)
        }
    }
}
