//
//  BaseMelodyLoopOption.swift
//  iOSApp4
//
//  Created by stephanie otteson on 2026-07-19.
//

import Foundation

enum BaseMelodyLoopOption: String, CaseIterable, Codable {
    case groundingHandpan = "Grounding Handpan"
    case somaticPulse = "Somatic Pulse"
    case celestialVoices = "Celestial Voices"
    case earthHarmonicDrone = "Earth Harmonic Drone"
    case angelicFrequencies = "Angelic Frequencies"
    case etherealWinds = "Ethereal Winds"
    case deepMeditation = "Deep Meditation"
    case ancestralRhythm = "Ancestral Rhythm"
    case resonantBells = "Resonant Bells"
    case crystalChimes = "Crystal Chimes"
    
    var audioFileName: String {
        switch self {
        case .groundingHandpan: return "handpan-base"
        case .somaticPulse: return "heartbeat-base"
        case .celestialVoices: return "choir-base"
        case .earthHarmonicDrone: return "drone-base"
        case .angelicFrequencies: return "angelic-base"
        case .etherealWinds: return "airy-base"
        case .deepMeditation: return "meditative-base"
        case .ancestralRhythm: return "tribal-base"
        case .resonantBells: return "bells-base"
        case .crystalChimes: return "chimes-base"
        }
    }
}


