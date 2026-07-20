//
//  GenerativeInstrument.swift
//  iOSApp4
//
//  Created by stephanie otteson on 2026-07-19.
//

import Foundation

enum GenerativeInstrument: String, CaseIterable, Codable {
    case acousticHarp = "acoustic-harp-c"
    case bell = "bell-c"
    case singingBowl = "singing-bowl-c"
    case gong = "gong-c"
    case panFlute = "pan-flute-c"
    case steelTongueDrum = "steel-tongue-drum-c"
    
    var displayName: String {
        switch self {
        case .acousticHarp: return "Acoustic Harp"
        case .bell: return "Bell"
        case .singingBowl: return "Singing Bowl"
        case .gong: return "Gong"
        case .panFlute: return "Pan Flute"
        case .steelTongueDrum: return "Steel Tongue Drum"
        }
    }
}
