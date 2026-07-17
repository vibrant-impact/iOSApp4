//
//  SavedScene.swift
//  iOSApp4
//
//  Created by stephanie otteson on 2026-07-12.
//

import Foundation

struct SavedScene: Identifiable, Codable, Equatable {
    let id: String         // Conforms to Identifiable for easy SwiftUI ForEach loops
    let name: String       // The custom text name the user gives the preset
    let params: SoundscapeParams // The captured slider configuration properties
    let createdAt: Double  // Unix timestamp to track when it was saved
    var isPublic: Bool = false // allows you to query the database for all public scenes across all users, as a "Discover" feed
}
