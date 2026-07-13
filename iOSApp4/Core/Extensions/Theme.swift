//
//  Theme.swift
//  iOSApp4
//
//  Created by stephanie otteson on 2026-07-12.
//

import SwiftUI

struct AppTheme {
    let name: String
    let accentColor: Color
    let bgGradient: LinearGradient
    let badgeBg: Color
    
    static func current(for scale: MusicalScale) -> AppTheme {
        switch scale {
        case .hirajoshi:
            return AppTheme(
                name: "Zen Garden",
                accentColor: .emerald,
                bgGradient: LinearGradient(colors: [.black, Color(red: 0.02, green: 0.05, blue: 0.03)], startPoint: .top, endPoint: .bottom),
                badgeBg: Color.emerald.opacity(0.15)
            )
        case .eLydian:
            return AppTheme(
                name: "Ethereal Aurora",
                accentColor: .purple,
                bgGradient: LinearGradient(colors: [.black, Color(red: 0.04, green: 0.02, blue: 0.06)], startPoint: .top, endPoint: .bottom),
                badgeBg: Color.purple.opacity(0.15)
            )
        case .dDorian:
            return AppTheme(
                name: "Mystical Solstice",
                accentColor: .amber,
                bgGradient: LinearGradient(colors: [.black, Color(red: 0.05, green: 0.04, blue: 0.02)], startPoint: .top, endPoint: .bottom),
                badgeBg: Color.amber.opacity(0.15)
            )
        case .aMinorPentatonic:
            return AppTheme(
                name: "Storm Sanctuary",
                accentColor: .slate,
                bgGradient: LinearGradient(colors: [.black, Color(red: 0.03, green: 0.03, blue: 0.04)], startPoint: .top, endPoint: .bottom),
                badgeBg: Color.slate.opacity(0.15)
            )
        case .cMajorPentatonic:
            return AppTheme(
                name: "Deep Space",
                accentColor: .indigo,
                bgGradient: LinearGradient(colors: [.black, Color(red: 0.02, green: 0.02, blue: 0.05)], startPoint: .top, endPoint: .bottom),
                badgeBg: Color.indigo.opacity(0.15)
            )
        }
    }
}

// Quick fallback extension for a custom Slate color matching Tailwind slate-400
extension Color {
    static let slate = Color(red: 0.58, green: 0.65, blue: 0.75)
    static let emerald = Color(red: 0.06, green: 0.73, blue: 0.45)
    static let amber = Color(red: 0.96, green: 0.62, blue: 0.04)
    static let sky = Color(red: 0.22, green: 0.65, blue: 0.91)
}

