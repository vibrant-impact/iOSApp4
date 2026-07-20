//
//  InstrumentSelectorCard.swift
//  iOSApp4
//
//  Created by stephanie otteson on 2026-07-19.
//

import SwiftUI

struct InstrumentSelectorCard: View {
    @Binding var parameters: SoundscapeParameters
    let accentColor: Color = .blue // Replace with your theme.accentColor if passed down
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Generative Instrument")
                .font(.system(.caption, design: .monospaced))
                .bold()
                .foregroundColor(accentColor)
            
            HStack {
                Text("Active Voice")
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Picker("Instrument", selection: $parameters.selectedInstrument) {
                    ForEach(GenerativeInstrument.allCases, id: \.self) { instrumentOption in
                        Text(instrumentOption.displayName)
                            .tag(instrumentOption)
                    }
                }
                .pickerStyle(.menu)
                .tint(accentColor)
                .background(Color.black.opacity(0.2))
                .cornerRadius(8)
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}
