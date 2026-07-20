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
    @Published var parameters: SoundscapeParameters = SoundscapeParameters()
    @Published var isPlaying: Bool = false
    @Published var savedScenes: [SavedScene] = []
    @Published var communityScenes: [SavedScene] = []
    @Published var isLoadingCommunityScenes: Bool = false
    @Published var activeNoteName: String = ""
    @Published var activeNoteFrequency: Float = 0.0
    @Published var showWelcomeModal: Bool = true
    @Published var currentUserId: String? = nil
    
    // MARK: - Internal Algorithmic Properties
    private var currentWalkIndex: Int = 7
    private var melodyTimer: Timer?
    
    // Dynamic rhythm sequence to prevent robotic equal-interval timing
    private let rhythmPatternArray: [Double] = [1.0, 0.5, 0.5, 2.0, 0.25, 0.25, 1.5]
    private var currentRhythmIndex: Int = 0
    
    // MARK: - Audio Engine Reference Holder
    private var audioEngine = GenerativeAudioEngine()
    
    // MARK: - Firestore Reference
    private let databaseReference = Firestore.firestore()
    
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
                
                self?.fetchCloudScenes()
            }
        }
    }
    
    func fetchCommunityScenes() {
        isLoadingCommunityScenes = true
        
        databaseReference.collection("communityScenes")
            .order(by: "createdAt", descending: true)
            .limit(to: 50)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoadingCommunityScenes = false
                    
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
    
    func seedCommunityScenes() {
        let rainParameters = SoundscapeParameters(
            oceanVolume: 0.1,
            rainVolume: 0.9,
            harpVolume: 0.2,
            melodySpeed: 1.2
        )
        
        let droneParameters = SoundscapeParameters(
            rainVolume: 0.0, bowlsVolume: 0.6, droneVolume: 0.85,
            melodySpeed: 0.5
        )
        
        let mockScenes = [
            SavedScene(
                id: UUID().uuidString,
                name: "Heavy Rain & Harp",
                parameters: rainParameters,
                createdAt: Date().timeIntervalSince1970,
                isPublic: true
            ),
            SavedScene(
                id: UUID().uuidString,
                name: "Deep Meditation Bowls",
                parameters: droneParameters,
                createdAt: Date().timeIntervalSince1970,
                isPublic: true
            )
        ]
        
        for scene in mockScenes {
            do {
                try databaseReference.collection("communityScenes").document(scene.id).setData(from: scene)
                print("Successfully seeded community scene: \(scene.name)")
            } catch let error {
                print("Error uploading mock community scene to Firestore: \(error.localizedDescription)")
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
        audioEngine.startAudioEngine()
        audioEngine.updateParameters(from: parameters)
        
        isPlaying = true
        showWelcomeModal = false
        
        currentWalkIndex = parameters.scale.frequencies.count / 2
        scheduleNextMelodyNote()
    }
    
    private func stopEngine() {
        melodyTimer?.invalidate()
        melodyTimer = nil
        
        audioEngine.pauseAudioEngine()
        
        isPlaying = false
        activeNoteName = ""
        activeNoteFrequency = 0.0
    }
    
    // MARK: - The Markov Chain Random Walk Scheduler
    private func scheduleNextMelodyNote() {
        melodyTimer?.invalidate()
        
        guard isPlaying else { return }
        
        currentWalkIndex = getNextRandomWalkIndex(
            currentIndex: currentWalkIndex,
            scaleLength: parameters.scale.frequencies.count,
            jumpiness: parameters.melodyJumpiness,
            drift: parameters.melodyDrift
        )
        
        let scaleFrequencies = parameters.scale.frequencies
        let scaleNotes = parameters.scale.notes
        
        if currentWalkIndex < scaleFrequencies.count {
            let nextFrequency = scaleFrequencies[currentWalkIndex]
            let nextNoteName = scaleNotes[currentWalkIndex]
            
            DispatchQueue.main.async {
                self.activeNoteFrequency = nextFrequency
                self.activeNoteName = nextNoteName
            }
            
            audioEngine.playGenerativeNote(frequency: nextFrequency)
        }
        
        // Calculate dynamic rhythm logic
        let baseRhythmMultiplier = rhythmPatternArray[currentRhythmIndex]
        currentRhythmIndex = (currentRhythmIndex + 1) % rhythmPatternArray.count
        
        let microDelay = Float.random(in: -0.025...0.025)
        
        // Multiply the user's melody speed by the sequence array to create rhythmic breathing
        let calculatedInterval = (Double(parameters.melodySpeed) * baseRhythmMultiplier) + Double(microDelay)
        let nextIntervalDuration = max(0.15, calculatedInterval)
        
        melodyTimer = Timer.scheduledTimer(withTimeInterval: nextIntervalDuration, repeats: false) { [weak self] _ in
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
            let targetIndex = currentIndex + offset
            
            if targetIndex >= 0 && targetIndex < scaleLength {
                let baseWeight: Float = offset == 0 ? 0.1 : exp(-Float(abs(offset)) / 1.5)
                let driftMultiplier = 1.0 + (drift * Float(offset))
                let calculatedWeight = baseWeight * max(0.01, driftMultiplier)
                
                possibleIndices.append((index: targetIndex, weight: calculatedWeight))
            }
        }
        
        if possibleIndices.isEmpty {
            return scaleLength / 2
        }
        
        let totalWeight = possibleIndices.reduce(0.0) { $0 + $1.weight }
        var randomValue = Float.random(in: 0...totalWeight)
        
        for item in possibleIndices {
            randomValue -= item.weight
            if randomValue <= 0 {
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
            parameters: parameters,
            createdAt: Date().timeIntervalSince1970,
            isPublic: false
        )
        
        savedScenes.insert(newScene, at: 0)
        saveSceneToCloud(newScene)
    }
    
    func deleteScene(sceneId: String) {
        guard let currentUserId = self.currentUserId else { return }
        
        databaseReference.collection("users")
            .document(currentUserId)
            .collection("savedScenes")
            .document(sceneId)
            .delete() { [weak self] error in
                if let error = error {
                    print("Error removing document: \(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        self?.savedScenes.removeAll { $0.id == sceneId }
                    }
                }
            }
    }
    
    func loadScene(_ sceneParameters: SoundscapeParameters) {
        parameters = sceneParameters
    }
    
    func updateEngineParameters() {
        audioEngine.updateParameters(from: parameters)
        
        // Push both the generative instrument and the base loop file updates
        audioEngine.loadInstrumentSample(fileName: parameters.selectedInstrument.rawValue)
        audioEngine.updateBaseMelody(audioFileName: parameters.selectedBaseMelodyLoop.audioFileName)
    }
    
    // MARK: - Cloud Data Methods
    func saveSceneToCloud(_ scene: SavedScene) {
        guard let currentUserId = self.currentUserId else {
            print("Cannot save to cloud: No user authenticated.")
            return
        }
        
        do {
            let sceneData = try Firestore.Encoder().encode(scene)
            
            databaseReference.collection("users")
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
        
        databaseReference.collection("users")
            .document(currentUserId)
            .collection("savedScenes")
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] snapshot, error in
                
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
                    
                    self?.savedScenes = fetchedScenes
                }
            }
    }
}
