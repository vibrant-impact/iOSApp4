//
//  WaveformVisualizerView.swift
//  iOSApp4
//
//  Created by stephanie otteson on 2026-07-12.
//

import SwiftUI

// MARK: - Active Note Visual Particle
struct NoteParticle: Identifiable {
    let id = UUID()
    let name: String
    let frequency: Float
    let xPercentage: CGFloat // Calculated 10% to 90% across screen width based on pitch
    let yPosition: CGFloat   // Stays near vertical center with organic vertical jitter
    let color: Color
    var spawnTime: Date = Date()
}

struct WaveformVisualizerView: View {
    let activeNoteName: String
    let activeNoteFrequency: Float
    let lfoRate: Float
    let isPlaying: Bool
    
    @State private var activeParticles: [NoteParticle] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Top Status Bar Layout
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(isPlaying ? Color.indigo : Color.slate)
                        .frame(width: 6, height: 6)
                        .symbolEffect(.pulse, isActive: isPlaying)
                    Text("Harmonic Soundstage")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundColor(.slate)
                }
                Spacer()
                
                if isPlaying && !activeNoteName.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "music.note")
                            .font(.caption2)
                            .foregroundColor(.indigo)
                        Text(activeNoteName)
                            .font(.system(.caption, design: .monospaced))
                            .bold()
                            .foregroundColor(.white)
                        Text(String(format: "%.1fHz", activeNoteFrequency))
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(.slate)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(20)
                } else {
                    Text("endless drifting silence...")
                        .font(.system(.caption2, design: .monospaced))
                        .italic()
                        .foregroundColor(.slate)
                }
            }
            .padding(.horizontal, 4)
            
            // Core Animation Stage via Render-Loop
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let time = timeline.date.timeIntervalSince1970
                    
                    // 1. DRAW BACKGROUND AMBIENT LIQUID LFO WAVES
                    drawAmbientLiquidWaves(in: context, size: size, time: time)
                    
                    // 2. DRAW ACTIVE NOTE RIPPLES & ORBS
                    drawNoteParticles(in: context, size: size, time: timeline.date)
                }
                .frame(height: 160)
                .background(Color.black.opacity(0.4))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
            }
            
            // Horizontal Frequency Guide Description
            HStack {
                Text("Low Registers (Base)")
                Spacer()
                Text("High Registers (Sparkle)")
            }
            .font(.system(size: 8, design: .monospaced))
            .foregroundColor(Color.slate.opacity(0.6))
            .padding(.horizontal, 2)
        }
        // Monitor note trigger properties to instantly spawn rendering models
        .onChange(of: activeNoteFrequency) { _, newFrequency in
            if newFrequency > 0 {
                spawnNewParticle(for: newFrequency, name: activeNoteName)
            }
        }
    }
    
    // MARK: - Procedural Particle Generator
    private func spawnNewParticle(for frequency: Float, name: String) {
        // Map logarithmically from 110Hz to 932Hz over a 10% to 90% boundary matching your web layout
        let minF: Float = 110.0
        let maxF: Float = 932.0
        let logMin = log(minF)
        let logMax = log(maxF)
        let logCurrent = log(max(minF, min(maxF, frequency)))
        
        let xPct = CGFloat((logCurrent - logMin) / (logMax - logMin)) * 0.8 + 0.1
        let yJitter = CGFloat.random(in: 0.4...0.6) // Fluctuate around mid-height lines organically
        
        // Match pitch frequency directly down to gorgeous design colors
        let pitchColor: Color
        switch xPct {
        case ..<0.3: pitchColor = .purple
        case 0.3..<0.5: pitchColor = .indigo
        case 0.5..<0.7: pitchColor = .blue
        case 0.7..<0.85: pitchColor = .sky
        default: pitchColor = .emerald
        }
        
        let particle = NoteParticle(name: name, frequency: frequency, xPercentage: xPct, yPosition: yJitter, color: pitchColor)
        
        // Append to state thread securely while trimming overhead accumulation
        activeParticles.append(particle)
        if activeParticles.count > 15 {
            activeParticles.removeFirst()
        }
    }
    
    // MARK: - Native Rendering Engine Drawing Implementations
    private func drawAmbientLiquidWaves(in context: GraphicsContext, size: CGSize, time: TimeInterval) {
        let width = size.width
        let height = size.height
        let midY = height / 2
        
        // Speed multiplier maps directly to your lfoRate slider properties
        let waveAngle = time * Double(lfoRate) * 1.5
        
        var path = Path()
        path.move(to: CGPoint(x: 0, y: height))
        
        let steps = 60
        for i in 0...steps {
            let x = CGFloat(i) / CGFloat(steps) * width
            // Layer two distinct mathematical curves to achieve an organic fluid motion profile
            let wave1 = sin(CGFloat(i) * 0.05 + CGFloat(waveAngle)) * 25
            let wave2 = cos(CGFloat(i) * 0.03 - CGFloat(waveAngle * 0.5)) * 10
            let y = midY + wave1 + wave2
            
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        // Replicate your web CSS linear gradients using system shading pipelines
        context.fill(
            path,
            with: .linearGradient(
                Gradient(colors: [Color.indigo.opacity(0.04), Color.purple.opacity(0.12)]),
                startPoint: CGPoint(x: 0, y: height / 3),
                endPoint: CGPoint(x: 0, y: height)
            )
        )
    }
    
    private func drawNoteParticles(in context: GraphicsContext, size: CGSize, time: Date) {
        for particle in activeParticles {
            let elapsedTime = time.timeIntervalSince(particle.spawnTime)
            guard elapsedTime < 1.8 else { continue } // Expire particles after 1.8 seconds
            
            let targetX = particle.xPercentage * size.width
            let targetY = particle.yPosition * size.height
            let centerPoint = CGPoint(x: targetX, y: targetY)
            
            // Calculate scale decay and opacity curves for the rings and core
            let opacity = CGFloat(max(0, 1.0 - (elapsedTime / 1.8)))
            let ringScale = CGFloat(0.1 + (elapsedTime / 1.8) * 2.1)
            
            // A. DRAW EXPANDING RIPPLE RING
            let ringRadius: CGFloat = 20 * ringScale
            var ringPath = Path()
            ringPath.addEllipse(in: CGRect(x: targetX - ringRadius, y: targetY - ringRadius, width: ringRadius * 2, height: ringRadius * 2))
            
            context.stroke(
                ringPath,
                with: .color(particle.color.opacity(Double(opacity * 0.6))),
                lineWidth: 1.5
            )
            
            // B. DRAW CORE GLOWING ORB (only fully visible in its initial phase)
            if elapsedTime < 0.6 {
                let coreOpacity = CGFloat(max(0, 1.0 - (elapsedTime / 0.6)))
                let coreRadius: CGFloat = 16 * (1.0 - (elapsedTime / 0.6) * 0.3)
                
                context.drawLayer { layerContext in
                    // Apply subtle drop shadows natively directly around the path boundary grid
                    layerContext.addFilter(.shadow(color: particle.color, radius: 6, x: 0, y: 0))
                    
                    let coreRect = CGRect(x: targetX - coreRadius, y: targetY - coreRadius, width: coreRadius * 2, height: coreRadius * 2)
                    let corePath = Path(ellipseIn: coreRect)
                    
                    layerContext.fill(corePath, with: .color(particle.color.opacity(Double(coreOpacity))))
                    
                    // Print note text into center core
                    let resolvedText = layerContext.resolve(
                        Text(particle.name)
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .foregroundColor(.black)
                    )
                    layerContext.draw(resolvedText, at: centerPoint)
                }
            }
        }
    }
}
