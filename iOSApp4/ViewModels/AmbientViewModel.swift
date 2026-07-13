//
//  AmbientViewModel.swift
//  iOSApp4
//
//  Created by stephanie otteson on 2026-07-12.
//

import Foundation
import Combine

class AmbientViewModel: ObservableObject {
    // MARK: - Published UI States
    @Published var params: SoundscapeParams = SoundscapeParams()
    @Published var isPlaying: Bool = false
    @Published var savedScenes: [SavedScene] = []
    @Published var activeNoteName: String = ""
    @Published var activeNoteFrequency: Float = 0.0
    @Published var showWelcomeModal: Bool = true
    
    // MARK: - Internal Alogrithmic Properties
    private var currentWalkIndex: Int = 7 // Start in the middle of our 15-note scale
    private var melodyTimer: Timer?
    private let userDefaultsKey = "ambient_saved_scenes"
    
    // MARK: - Audio Engine Reference Holder
    private var audioEngine = GenerativeAudioEngine()
    
    init() {
        loadSavedScenes()
    }
    
    // MARK: - Core Playback Control
    func togglePlayback() {
        if isPlaying {
            stopEngine()
        } else {
            startEngine()
        }
    }
    
    private func startEngine() {
        audioEngine.start()
        audioEngine.updateParams(from: params)
        
        isPlaying = true
        showWelcomeModal = false
        
        // Seed initial walk index to middle register of chosen scale
        currentWalkIndex = params.scale.frequencies.count / 2
        scheduleNextMelodyNote()
    }
    
    private func stopEngine() {
        melodyTimer?.invalidate()
        melodyTimer = nil
        
        audioEngine.stop()
        
        isPlaying = false
        activeNoteName = ""
        activeNoteFrequency = 0.0
    }
    
    // MARK: - The Markov Chain Random Walk Scheduler
    private func scheduleNextMelodyNote() {
        melodyTimer?.invalidate()
        
        guard isPlaying else { return }
        
        // 1. Run our mathematical random walk matrix calculation
        currentWalkIndex = getNextRandomWalkIndex(
            currentIndex: currentWalkIndex,
            scaleLength: params.scale.frequencies.count,
            jumpiness: params.melodyJumpiness,
            drift: params.melodyDrift
        )
        
        // 2. Extract note values safely
        let scaleFrequencies = params.scale.frequencies
        let scaleNotes = params.scale.notes
        
        if currentWalkIndex < scaleFrequencies.count {
            let nextFreq = scaleFrequencies[currentWalkIndex]
            let nextName = scaleNotes[currentWalkIndex]
            
            // 3. Update main thread UI bindings for our visual ripples
            DispatchQueue.main.async {
                self.activeNoteFrequency = nextFreq
                self.activeNoteName = nextName
            }
            
            // 4. Fire voice node trigger inside our engine graph
            audioEngine.playSynthNote(frequency: nextFreq)
        }
        
        // 5. Add organic micro-timing humanization interval drift (+/- 25ms)
        let microDelay = Float.random(in: -0.025...0.025)
        let nextInterval = Double(max(0.15, params.melodySpeed + microDelay))
        
        melodyTimer = Timer.scheduledTimer(withTimeInterval: nextInterval, repeats: false) { [weak self] _ in
            self?.scheduleNextMelodyNote()
        }
    }
    
    private func getNextRandomWalkIndex(
        currentIndex: Int,
        scaleLength: Int,
        jumpiness: Int,
        drift: Float
    ) -> Int {
        var possibleIndices: [(index: Int, weight: Float)] = []
        
        for offset in -jumpiness...jumpiness {
            let targetIdx = currentIndex + offset
            
            if targetIdx >= 0 && targetIdx < scaleLength {
                // Match your exact web equation modeling: exponential weights with low index 0 weight
                let baseWeight: Float = offset == 0 ? 0.1 : exp(-Float(abs(offset)) / 1.5)
                let driftMultiplier = 1.0 + (drift * Float(offset))
                let weight = baseWeight * max(0.01, driftMultiplier)
                
                possibleIndices.append((index: targetIdx, weight: weight))
            }
        }
        
        if possibleIndices.isEmpty {
            return scaleLength / 2
        }
        
        let totalWeight = possibleIndices.reduce(0.0) { $0 + $1.weight }
        var randomVal = Float.random(in: 0...totalWeight)
        
        for item in possibleIndices {
            randomVal -= item.weight
            if randomVal <= 0 {
                return item.index
            }
        }
        
        return possibleIndices.last?.index ?? (scaleLength / 2)
    }
    
    // MARK: - Presets & Local Custom Scene Storage Management
    func saveCurrentScene(named name: String) {
        let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedName.isEmpty else { return }
        
        let newScene = SavedScene(
            id: UUID().uuidString,
            name: cleanedName,
            params: params,
            createdAt: Date().timeIntervalSince1970
        )
        
        savedScenes.insert(newScene, at: 0)
        saveToPersistentStorage()
    }
    
    func deleteScene(id: String) {
        savedScenes.removeAll { $0.id == id }
        saveToPersistentStorage()
    }
    
    func loadScene(_ sceneParams: SoundscapeParams) {
        params = sceneParams
        // If engine is actively performing, sweep parameters smoothly in real time
        // audioEngine?.updateParams(params)
    }
    
    private func saveToPersistentStorage() {
        if let encoded = try? JSONEncoder().encode(savedScenes) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadSavedScenes() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([SavedScene].self, from: data) {
            savedScenes = decoded
        }
    }
    
    func updateEngineParams() {
        audioEngine.updateParams(from: params)
    }
}
