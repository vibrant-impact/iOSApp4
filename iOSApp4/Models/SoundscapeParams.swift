//
//  SoundscapeParams.swift
//  iOSApp4
//
//  Created by stephanie otteson on 2026-07-12.
//

import Foundation

struct SoundscapeParams: Codable, Equatable {
    var oceanVolume: Float = 0.5
    var droneVolume: Float = 0.4
    var rainVolume: Float = 0.3
    var harpVolume: Float = 0.35
    var chimesVolume: Float = 0.45
    var bowlsVolume: Float = 0.3
    var fluteVolume: Float = 0.25
    
    var melodySpeed: Float = 1.5
    var melodyJumpiness: Int = 2
    var melodyDrift: Float = 0.0
    var scale: MusicalScale = .cMajorPentatonic
    var octave: Int = 4
    
    var lfoRate: Float = 1.0 / 40.0
    var lfoDepth: Float = 1500.0
    
    var delayTime: Float = 0.8
    var delayFeedback: Float = 0.7
    var delayMix: Float = 0.4
    
    var masterVolume: Float = 0.8
}
