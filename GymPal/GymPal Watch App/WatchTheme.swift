//
//  WatchTheme.swift
//  GymFocus Watch App
//
//  Created by Claude.
//

import SwiftUI

struct WatchTheme {
    static let themes: [String: Color] = [
        "S": Color(red: 0.81, green: 1, blue: 0.01),     // primaryDefault
        "A": Color(red: 0.761, green: 0.529, blue: 0.482), // primaryA
        "B": Color(red: 0.161, green: 0.502, blue: 0.725), // primaryB
        "D": Color(red: 0.533, green: 0, blue: 0.906),     // primaryD
        "F": Color(red: 0.043, green: 0.4, blue: 0.137),   // primaryF
        "E": Color(red: 0, green: 0.404, blue: 0.31),      // primaryE
        "G": Color(red: 1, green: 0.455, blue: 0),         // primaryG
        "R": Color(red: 0.906, green: 0.298, blue: 0.235)  // primaryR
    ]
    
    static func getThemeColor(for key: String) -> Color {
        return themes[key] ?? themes["S"] ?? .green
    }
}

extension Color{
    func luminance() -> Double {
        // 1. Convert SwiftUI Color to UIColor
        let uiColor = UIColor(self)
        
        // 2. Extract RGB values
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
        
        // 3. Compute luminance.
        return 0.2126 * Double(red) + 0.7152 * Double(green) + 0.0722 * Double(blue)
    }
    func isLight() -> Bool {
        return luminance() > 0.5
    }
    
    func textColor() -> Color {
        return isLight() ? .black : .white
    }
}
