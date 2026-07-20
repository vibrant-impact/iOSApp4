//
//  GenerativeAudioEngine.swift
//  iOSApp4
//
//  Created by stephanie otteson on 2026-07-12.
//

import AVFoundation

class GenerativeAudioEngine {
    private let audioEngine = AVAudioEngine()
    private var masterGainNode = AVAudioMixerNode()
    private var instrumentMixerNode = AVAudioMixerNode()
    private var baseMelodyTimePitchNode = AVAudioUnitTimePitch()
    private var delayNode = AVAudioUnitDelay()
    
    // The sampler that replaces the mathematical sine wave
    private var instrumentSamplerNode = AVAudioUnitSampler()
    
    // MARK: - Looping Background Canvas Nodes
    private var oceanLoopPlayerNode = AVAudioPlayerNode()
    private var rainLoopPlayerNode = AVAudioPlayerNode()
    private var droneLoopPlayerNode = AVAudioPlayerNode()
    private var djembeLoopPlayerNode = AVAudioPlayerNode()
    private var shakerLoopPlayerNode = AVAudioPlayerNode()
    
    // The dedicated node for the main melody
    private var baseMelodyPlayerNode = AVAudioPlayerNode()
    private var currentBaseMelodyIdentifier: String = ""
    
    private var isEngineRunning = false
    
    init() {
        setupAudioGraph()
        
        // Load default instrument and melody files upon initialization
        loadInstrumentSample(fileName: "acoustic-harp-c")
        updateBaseMelody(audioFileName: "handpan-base")
        
        // Load the background canvas loops
        loadAndLoopAudioFile(fileName: "ocean-loop", playerNode: oceanLoopPlayerNode)
        loadAndLoopAudioFile(fileName: "rain-loop", playerNode: rainLoopPlayerNode)
        loadAndLoopAudioFile(fileName: "drone-loop", playerNode: droneLoopPlayerNode)
        loadAndLoopAudioFile(fileName: "djembe-loop", playerNode: djembeLoopPlayerNode)
        loadAndLoopAudioFile(fileName: "shaker-loop", playerNode: shakerLoopPlayerNode)
    }
    
    private func setupAudioGraph() {
        // MARK: - 1. Attach All Nodes First
        // The engine must "know" about every node before any connections are made.

        // Main Melody & Instrument
        audioEngine.attach(baseMelodyPlayerNode)
        audioEngine.attach(instrumentSamplerNode)
        audioEngine.attach(instrumentMixerNode)

        // Effects & Master
        audioEngine.attach(delayNode)
        audioEngine.attach(masterGainNode)
        audioEngine.attach(baseMelodyTimePitchNode)

        // Atmospheric Loops
        audioEngine.attach(oceanLoopPlayerNode)
        audioEngine.attach(rainLoopPlayerNode)
        audioEngine.attach(droneLoopPlayerNode)
        audioEngine.attach(djembeLoopPlayerNode)
        audioEngine.attach(shakerLoopPlayerNode)


        // MARK: - 2. Connect the Audio Graph
        // Now that all nodes are attached, you can safely route the audio signals.

        let outputFormat = audioEngine.outputNode.outputFormat(forBus: 0)

        // Route the generative instrument through its dedicated mixer, then to the delay effect
        audioEngine.connect(instrumentSamplerNode, to: instrumentMixerNode, format: outputFormat)
        audioEngine.connect(instrumentMixerNode, to: delayNode, format: outputFormat)

        // Route the delay effect to the master gain
        audioEngine.connect(delayNode, to: masterGainNode, format: outputFormat)

        // Route the main melody through the time-pitch node, then to the master gain
        audioEngine.connect(baseMelodyPlayerNode, to: baseMelodyTimePitchNode, format: outputFormat)
        audioEngine.connect(baseMelodyTimePitchNode, to: masterGainNode, format: outputFormat)

        // Connect all atmospheric loop players directly to the master gain
        audioEngine.connect(oceanLoopPlayerNode, to: masterGainNode, format: outputFormat)
        audioEngine.connect(rainLoopPlayerNode, to: masterGainNode, format: outputFormat)
        audioEngine.connect(droneLoopPlayerNode, to: masterGainNode, format: outputFormat)
        audioEngine.connect(djembeLoopPlayerNode, to: masterGainNode, format: outputFormat)
        audioEngine.connect(shakerLoopPlayerNode, to: masterGainNode, format: outputFormat)

        // Finally, connect the master gain to the engine's main output hardware
        audioEngine.connect(masterGainNode, to: audioEngine.outputNode, format: outputFormat)
    }
    
    // MARK: - Loop Loading Helper
    private func loadAndLoopAudioFile(fileName: String, playerNode: AVAudioPlayerNode) {
        guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: "wav") else {
            print("Could not find \(fileName).wav in the application bundle.")
            return
        }
        
        do {
            let audioFile = try AVAudioFile(forReading: fileURL)
            let audioFormat = audioFile.processingFormat
            let audioFrameCount = AVAudioFrameCount(audioFile.length)
            
            guard let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount) else {
                print("Could not create audio buffer for \(fileName).")
                return
            }
            
            try audioFile.read(into: audioBuffer)
            
            // Schedule the buffer to loop infinitely
            playerNode.scheduleBuffer(audioBuffer, at: nil, options: .loops, completionHandler: nil)
            
        } catch {
            print("Failed to load and loop \(fileName): \(error.localizedDescription)")
        }
    }
    
    // MARK: - Instrument & Melody Loading
    func loadInstrumentSample(fileName: String) {
        guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: "wav") else {
            print("Could not find \(fileName).wav in the application bundle.")
            return
        }
        
        do {
            try instrumentSamplerNode.loadAudioFiles(at: [fileURL])
            print("Successfully loaded \(fileName).wav into the sampler node.")
        } catch {
            print("Failed to load audio file into the sampler node: \(error)")
        }
    }
    
    func updateBaseMelody(audioFileName: String) {
        // Prevent reloading if the user selects the same melody again
        guard audioFileName != currentBaseMelodyIdentifier else { return }
        
        let wasPlaying = baseMelodyPlayerNode.isPlaying
        if wasPlaying {
            baseMelodyPlayerNode.stop()
        }
        
        // Clear previous buffer schedules
        baseMelodyPlayerNode.reset()
        
        loadAndLoopAudioFile(fileName: audioFileName, playerNode: baseMelodyPlayerNode)
        currentBaseMelodyIdentifier = audioFileName
        
        // Seamlessly restart playback if the engine is currently active
        if isEngineRunning {
            baseMelodyPlayerNode.play()
        }
    }
    
    // MARK: - Generative Playback
    func playGenerativeNote(frequency: Float, velocityAmount: UInt8 = 100) {
        let midiNoteNumber = 69.0 + 12.0 * log2(frequency / 440.0)
        let clampedMidiNote = UInt8(max(0, min(127, Int(midiNoteNumber))))
        instrumentSamplerNode.startNote(clampedMidiNote, withVelocity: velocityAmount, onChannel: 0)
    }
    
    // MARK: - Synchronize Parameter Volumes Natively
    func updateParameters(from soundscapeParameters: SoundscapeParameters) {
        masterGainNode.outputVolume = soundscapeParameters.masterVolume
        delayNode.delayTime = TimeInterval(soundscapeParameters.delayTime)
        delayNode.feedback = soundscapeParameters.delayFeedback * 100.0
        delayNode.wetDryMix = soundscapeParameters.delayMix * 100.0
        
        // Sync the engine's playback rate to your parameters
        baseMelodyTimePitchNode.rate = soundscapeParameters.baseMelodyPlaybackSpeed
        
        // Handle Unified Console Volumes and Mutes
        baseMelodyPlayerNode.volume = soundscapeParameters.isBaseMelodyActive ? soundscapeParameters.baseMelodyVolume : 0.0
        instrumentMixerNode.outputVolume = soundscapeParameters.isInstrumentActive ? soundscapeParameters.instrumentVolume : 0.0
        
        oceanLoopPlayerNode.volume = soundscapeParameters.oceanVolume
        rainLoopPlayerNode.volume = soundscapeParameters.rainVolume
        droneLoopPlayerNode.volume = soundscapeParameters.droneVolume
        djembeLoopPlayerNode.volume = soundscapeParameters.djembeVolume
        shakerLoopPlayerNode.volume = soundscapeParameters.shakerVolume
    }
    
    // MARK: - Engine Controls
    func startAudioEngine() {
        guard !isEngineRunning else { return }
        do {
            try audioEngine.start()
            isEngineRunning = true
            
            let randomRainPanValue = Float.random(in: -0.4...0.4)
            let randomShakerPanValue = Float.random(in: -0.4...0.4)
            
            rainLoopPlayerNode.pan = randomRainPanValue
            shakerLoopPlayerNode.pan = randomShakerPanValue
            
            oceanLoopPlayerNode.play()
            rainLoopPlayerNode.play()
            droneLoopPlayerNode.play()
            djembeLoopPlayerNode.play()
            shakerLoopPlayerNode.play()
            
            // Initiate the main melody loop
            baseMelodyPlayerNode.play()
            
        } catch {
            print("Could not start audio framework: \(error.localizedDescription)")
        }
    }
    
    func pauseAudioEngine() {
        guard isEngineRunning else { return }
        audioEngine.pause() // Pauses the graph, preserving buffers!
        isEngineRunning = false
    }
}
