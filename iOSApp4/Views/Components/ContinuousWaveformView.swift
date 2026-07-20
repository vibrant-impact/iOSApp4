//
//  ContinuousWaveformView.swift
//  iOSApp4
//
//  Created by stephanie otteson on 2026-07-19.
//

import SwiftUI

struct ContinuousWaveformView: View {
    var isEnginePlaying: Bool
    var activeNoteFrequency: Float
    
    @State private var waveformPhaseShift: Double = 0.0
    @State private var waveformAmplitudeMultiplier: CGFloat = 0.2
    
    var body: some View {
        GeometryReader { geometryMetrics in
            Path { drawingPath in
                let drawingWidth = geometryMetrics.size.width
                let drawingHeight = geometryMetrics.size.height
                let verticalCenterPoint = drawingHeight / 2
                
                drawingPath.move(to: CGPoint(x: 0, y: verticalCenterPoint))
                
                for horizontalPosition in stride(from: 0, through: drawingWidth, by: 2) {
                    let relativeHorizontalPosition = horizontalPosition / drawingWidth
                    
                    // Creates a smooth, tapering sine wave formula
                    let sineWaveComponent = sin(relativeHorizontalPosition * .pi * 4 + waveformPhaseShift)
                    let bellCurveEnvelope = sin(relativeHorizontalPosition * .pi) // Tapers the edges
                    
                    let normalizedFrequencyInfluence = CGFloat(activeNoteFrequency.truncatingRemainder(dividingBy: 500) / 500)
                    let dynamicAmplitude = (waveformAmplitudeMultiplier + normalizedFrequencyInfluence * 0.3) * drawingHeight / 2
                    
                    let verticalPosition = verticalCenterPoint + (sineWaveComponent * bellCurveEnvelope * dynamicAmplitude)
                    
                    drawingPath.addLine(to: CGPoint(x: horizontalPosition, y: verticalPosition))
                }
            }
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [.indigo.opacity(0.5), .teal, .indigo.opacity(0.5)]),
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
            )
        }
        .frame(height: 40) // Kept slightly shorter so it acts as an accent footer to the main visualizer
        .onChange(of: isEnginePlaying) { _, currentlyPlaying in
            withAnimation(.easeInOut(duration: 1.0)) {
                waveformAmplitudeMultiplier = currentlyPlaying ? 0.8 : 0.1
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                waveformPhaseShift = .pi * 2
            }
        }
    }
}
