//
//  AmbientViewModel.swift
//  iOSApp4
//
//  Created by stephanie otteson on 2026-07-12.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class AmbientViewModel: ObservableObject {
    // MARK: - Published UI States
    @Published var params: SoundscapeParams = SoundscapeParams()
    @Published var isPlaying: Bool = false
    @Published var savedScenes: [SavedScene] = []
    @Published var communityScenes: [SavedScene] = []
    @Published var isLoadingCommunityScenes: Bool = false
    @Published var activeNoteName: String = ""
    @Published var activeNoteFrequency: Float = 0.0
    @Published var showWelcomeModal: Bool = true
    @Published var currentUserId: String? = nil
    
    // MARK: - Internal Alogrithmic Properties
    private var currentWalkIndex: Int = 7 // Start in the middle of our 15-note scale
    private var melodyTimer: Timer?
    
    // MARK: - Audio Engine Reference Holder
    private var audioEngine = GenerativeAudioEngine()
    
    // MARK: - Firestore Reference
    private let db = Firestore.firestore()
    
    init() {
        authenticateSilentUser()
    }
    
    func authenticateSilentUser() {
        Auth.auth().signInAnonymously { [weak self] authResult, error in
            if let signInError = error {
                print("Failed to authenticate silently: \(signInError.localizedDescription)")
                return
            }
            
            if let validUser = authResult?.user {
                self?.currentUserId = validUser.uid
                print("Silent authentication successful. User ID: \(validUser.uid)")
                
                // Fetch cloud data immediately after successful login
                self?.fetchCloudScenes()
            }
        }
    }
    
    // Function to handle the Firestore query
    func fetchCommunityScenes() {
        isLoadingCommunityScenes = true
        let db = Firestore.firestore()
        
        db.collection("communityScenes")
            .order(by: "createdAt", descending: true)
            .limit(to: 50)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                // Ensure state updates happen on the main thread
                DispatchQueue.main.async {
                    self.isLoadingCommunityScenes = false // Turn off loader
                    
                    if let error = error {
                        print("Error fetching community scenes: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let documents = snapshot?.documents else { return }
                    
                    self.communityScenes = documents.compactMap { doc -> SavedScene? in
                        try? doc.data(as: SavedScene.self)
                    }
                }
            }
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
        
        // Include the new isPublic boolean (defaulting to false for personal saves)
        let newScene = SavedScene(
            id: UUID().uuidString,
            name: cleanedName,
            params: params,
            createdAt: Date().timeIntervalSince1970,
            isPublic: false
        )
        
        // Optimistically update the UI immediately
        savedScenes.insert(newScene, at: 0)
        
        // Push to the cloud
        saveSceneToCloud(newScene)
    }
    
    func deleteScene(sceneId: String) {
        guard let currentUserId = self.currentUserId else { return }
        
        // Remove from Firestore
        db.collection("users")
            .document(currentUserId)
            .collection("savedScenes")
            .document(sceneId)
            .delete() { [weak self] error in
                if let error = error {
                    print("Error removing document: \(error.localizedDescription)")
                } else {
                    // Remove from local array on the main thread once confirmed
                    DispatchQueue.main.async {
                        self?.savedScenes.removeAll { $0.id == sceneId }
                    }
                }
            }
    }
    
    func loadScene(_ sceneParams: SoundscapeParams) {
        params = sceneParams
        // If engine is actively performing, sweep parameters smoothly in real time
        // audioEngine?.updateParams(params)
    }
    
    func updateEngineParams() {
        audioEngine.updateParams(from: params)
    }
    
    // MARK: - Cloud Data Methods
    
    func saveSceneToCloud(_ scene: SavedScene) {
        // Ensure we have a valid user ID before attempting to save
        guard let currentUserId = self.currentUserId else {
            print("Cannot save to cloud: No user authenticated.")
            return
        }
        
        // Convert the SoundscapeParams to a dictionary for Firestore
        // Note: Make sure SoundscapeParams and SavedScene conform to Codable in their model files!
        do {
            let sceneData = try Firestore.Encoder().encode(scene)
            
            db.collection("users")
                .document(currentUserId)
                .collection("savedScenes")
                .document(scene.id)
                .setData(sceneData) { error in
                    if let error = error {
                        print("Error saving scene to cloud: \(error.localizedDescription)")
                    } else {
                        print("Scene successfully saved to cloud: \(scene.name)")
                    }
                }
        } catch {
            print("Error encoding scene data: \(error)")
        }
    }
    
    func fetchCloudScenes() {
        guard let currentUserId = self.currentUserId else { return }
        
        db.collection("users")
            .document(currentUserId)
            .collection("savedScenes")
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] snapshot, error in
                
                // Move the decoding onto the main thread to satisfy the MainActor isolation!
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error fetching cloud scenes: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let documents = snapshot?.documents else { return }
                    
                    var fetchedScenes: [SavedScene] = []
                    for document in documents {
                        if let scene = try? document.data(as: SavedScene.self) {
                            fetchedScenes.append(scene)
                        }
                    }
                    
                    // Update our published array
                    self?.savedScenes = fetchedScenes
                }
            }
    }
}
