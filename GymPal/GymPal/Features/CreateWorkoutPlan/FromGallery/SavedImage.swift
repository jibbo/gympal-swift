//
//  SavedImage.swift
//  GymFocus
//
//  Created by Giovanni De Francesco on 28/07/25.
//

import SwiftUI

struct SavedImage: Identifiable, Codable, Hashable {
    let id: UUID
    let filename: String
    
    static func == (lhs: SavedImage, rhs: SavedImage) -> Bool {
        lhs.id == rhs.id && lhs.filename == rhs.filename
    }
}
