//
//  ColorExtensions.swift
//  rufus
//
//  Created by AI Assistant on 2025-07-28.
//

import SwiftUI

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        
        guard !hex.isEmpty && Scanner(string: hex).scanHexInt64(&int) else {
            self.init(.sRGB, red: 0.0, green: 0.478, blue: 1.0, opacity: 1.0)
            return
        }
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            // Default to blue color for invalid formats
            self.init(.sRGB, red: 0.0, green: 0.478, blue: 1.0, opacity: 1.0)
            return
        }

        // Ensure values are valid (not NaN) before creating color
        let red = max(0, min(255, Double(r))) / 255.0
        let green = max(0, min(255, Double(g))) / 255.0
        let blue = max(0, min(255, Double(b))) / 255.0
        let alpha = max(0, min(255, Double(a))) / 255.0
        
        self.init(
            .sRGB,
            red: red.isFinite ? red : 0.0,
            green: green.isFinite ? green : 0.0,
            blue: blue.isFinite ? blue : 0.0,
            opacity: alpha.isFinite ? alpha : 1.0
        )
    }
}
