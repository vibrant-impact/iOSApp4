//
//  SoundscapeParameters.swift
//  iOSApp4
//
//  Created by stephanie otteson on 2026-07-12.
//

import Foundation

struct SoundscapeParameters: Codable, Equatable {
    var oceanVolume: Float = 0.0
    var rainVolume: Float = 0.0
    var harpVolume: Float = 0.0
    var chimesVolume: Float = 0.0
    var bowlsVolume: Float = 0.0
    var fluteVolume: Float = 0.0
    var drumVolume: Float = 0.0
    var droneVolume: Float = 0.0
    var djembeVolume: Float = 0.0
    var shakerVolume: Float = 0.0
    
    // NEW: Unified Console States
    var baseMelodyVolume: Float = 0.8
    var instrumentVolume: Float = 0.8
    var isBaseMelodyActive: Bool = true
    var isInstrumentActive: Bool = true
    
    var selectedInstrument: GenerativeInstrument = .acousticHarp
    var selectedBaseMelodyLoop: BaseMelodyLoopOption = .groundingHandpan
    var baseMelodyPlaybackSpeed: Float = 1.0 // 1.0 is normal speed, 0.5 half speed, 2.0 double
    var melodySpeed: Float = 1.5
    var melodyJumpiness: Int = 2
    var melodyDrift: Float = 0.0
    var scale: MusicalScale = .cMajorPentatonic
    var octave: Int = 4
    
    var lfoRate: Float = 1.0 / 40.0
    var lfoDepth: Float = 1500.0
    
    var delayTime: Float = 0.0
    var delayFeedback: Float = 0.0
    var delayMix: Float = 0.0
    
    var masterVolume: Float = 0.8
}
