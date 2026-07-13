//
//  MusicalScale.swift
//  iOSApp4
//
//  Created by stephanie otteson on 2026-07-12.
//

import Foundation

enum MusicalScale: String, CaseIterable, Codable {
    case cMajorPentatonic = "C_MAJOR_PENTATONIC"
    case aMinorPentatonic = "A_MINOR_PENTATONIC"
    case eLydian = "E_LYDIAN"
    case dDorian = "D_DORIAN"
    case hirajoshi = "HIRAJOSHI"
    
    var frequencies: [Float] {
        switch self {
        case .cMajorPentatonic:
            return [130.81, 146.83, 164.81, 196.00, 220.00, 261.63, 293.66, 329.63, 392.00, 440.00, 523.25, 587.33, 659.25, 783.99, 880.00]
        case .aMinorPentatonic:
            return [110.00, 130.81, 146.83, 164.81, 196.00, 220.00, 261.63, 293.66, 329.63, 392.00, 440.00, 523.25, 587.33, 659.25, 783.99]
        case .eLydian:
            return [164.81, 185.00, 207.65, 233.08, 246.94, 277.18, 311.13, 329.63, 369.99, 415.30, 466.16, 493.88, 554.37, 622.25, 659.25]
        case .dDorian:
            return [146.83, 164.81, 174.61, 196.00, 220.00, 246.94, 261.63, 293.66, 329.63, 349.23, 392.00, 440.00, 493.88, 523.25, 587.33]
        case .hirajoshi:
            return [130.81, 138.59, 174.61, 185.00, 233.08, 261.63, 277.18, 349.23, 369.99, 466.16, 523.25, 554.37, 698.46, 739.99, 932.33]
        }
    }
    
    var notes: [String] {
        switch self {
        case .cMajorPentatonic: return ["C3", "D3", "E3", "G3", "A3", "C4", "D4", "E4", "G4", "A4", "C5", "D5", "E5", "G5", "A5"]
        case .aMinorPentatonic: return ["A2", "C3", "D3", "E3", "G3", "A3", "C4", "D4", "E4", "G4", "A4", "C5", "D5", "E5", "G5"]
        case .eLydian: return ["E3", "F#3", "G#3", "A#3", "B3", "C#4", "D#4", "E4", "F#4", "G#4", "A#4", "B4", "C#5", "D#5", "E5"]
        case .dDorian: return ["D3", "E3", "F3", "G3", "A3", "B3", "C4", "D4", "E4", "F4", "G4", "A4", "B4", "C5", "D5"]
        case .hirajoshi: return ["C3", "Db3", "F3", "Gb3", "Bb3", "C4", "Db4", "F4", "Gb4", "Bb4", "C5", "Db5", "F5", "Gb5", "Bb5"]
        }
    }
}

