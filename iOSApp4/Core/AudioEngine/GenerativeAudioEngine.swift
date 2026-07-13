//
//  GenerativeAudioEngine.swift
//  iOSApp4
//
//  Created by stephanie otteson on 2026-07-12.
//

import AVFoundation

class GenerativeAudioEngine {
    private let engine = AVAudioEngine()
    private var masterGain = AVAudioMixerNode()
    private var delayNode = AVAudioUnitDelay()
    
    // Core synthesis variables
    private var isRunning = false
    private var currentPhase: Float = 0.0
    private var targetFrequency: Float = 440.0
    private var currentFrequency: Float = 440.0
    private var sampleRate: Double = 44100.0
    
    // Optimized volume properties for individual instruments
    private var oceanVolume: Float = 0.5
    private var envelopeVolume: Float = 0.0
    private var isNoteActive = false
    
    init() {
        setupAudioGraph()
    }
    
    private func setupAudioGraph() {
        let format = engine.outputNode.outputFormat(forBus: 0)
        sampleRate = format.sampleRate
        
        let synthSourceNode = AVAudioSourceNode { [weak self] (_, _, frameCount, audioBufferList) -> OSStatus in
            guard let self = self else { return noErr }
            
            let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
            guard let buffer = abl[0].mData?.assumingMemoryBound(to: Float.self) else { return noErr }
            
            // pre-cache target volumes locally to stop audio graph thread clogging
            let activeTargetVol = self.isNoteActive ? Float(0.18) : Float(0.0)
            
            for frame in 0..<Int(frameCount) {
                // Smooth pitch portamento glide
                self.currentFrequency += (self.targetFrequency - self.currentFrequency) * 0.005
                
                let phaseIncrement = (2.0 * .pi * self.currentFrequency) / Float(self.sampleRate)
                self.currentPhase += phaseIncrement
                if self.currentPhase > (2.0 * .pi) { self.currentPhase -= (2.0 * .pi) }
                
                // Pure tone + simulated noise baseline matching ocean mix volume parameters
                let toneSignal = sin(self.currentPhase)
                let noiseSignal = Float.random(in: -1.0...1.0) * self.oceanVolume * 0.08
                
                // Smooth out individual node envelopes quickly
                self.envelopeVolume += (activeTargetVol - self.envelopeVolume) * 0.001
                
                buffer[frame] = (toneSignal * self.envelopeVolume) + noiseSignal
            }
            
            // Duplicate across stereo channels
            if abl.count > 1, let rightBuffer = abl[1].mData?.assumingMemoryBound(to: Float.self) {
                let leftBuffer = abl[0].mData?.assumingMemoryBound(to: Float.self)
                for frame in 0..<Int(frameCount) {
                    rightBuffer[frame] = leftBuffer?[frame] ?? 0.0
                }
            }
            
            return noErr
        }
        
        delayNode.delayTime = 0.8
        delayNode.feedback = 70.0
        delayNode.wetDryMix = 40.0
        
        engine.attach(synthSourceNode)
        engine.attach(delayNode)
        engine.attach(masterGain)
        
        engine.connect(synthSourceNode, to: delayNode, format: format)
        engine.connect(delayNode, to: masterGain, format: format)
        engine.connect(masterGain, to: engine.outputNode, format: format)
    }
    
    // MARK: - Synchronize Parameter Volumes Natively
    func updateParams(from params: SoundscapeParams) {
        // Map engine node modifications safely out of the sample calculations loop
        masterGain.outputVolume = params.masterVolume
        delayNode.delayTime = TimeInterval(params.delayTime)
        delayNode.feedback = params.delayFeedback * 100.0
        delayNode.wetDryMix = params.delayMix * 100.0
        
        // Pass individual instrument parameters dynamically
        self.oceanVolume = params.oceanVolume
    }
    
    func playSynthNote(frequency: Float) {
        targetFrequency = frequency
        isNoteActive = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.isNoteActive = false
        }
    }
    
    func start() {
        guard !isRunning else { return }
        do {
            try engine.start()
            isRunning = true
        } catch {
            print("Could not start audio framework: \(error)")
        }
    }
    
    func stop() {
        guard isRunning else { return }
        engine.stop()
        isRunning = false
    }
}
