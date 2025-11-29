//
//  Color+Theme.swift
//  CiraSwift
//
//  Theme colors matching React Native design (warm, cream, beige)
//

import SwiftUI

extension Color {
    // MARK: - Brand Colors (from RN code)
    static let brandTeal = Color(hex: "#4ECDC4")
    static let brandBlue = Color(hex: "#5DADE2")
    static let brandPurple = Color(hex: "#667EEA")
    static let brandGreen = Color(hex: "#34C759")
    
    // MARK: - Color Palette (from RN HomeScreen colorPalettes)
    static let warmRed = Color(hex: "#FF6B6B")
    static let teal = Color(hex: "#4ECDC4")
    static let mint = Color(hex: "#95E1D3")
    static let pink = Color(hex: "#F38181")
    static let purple = Color(hex: "#AA96DA")
    static let lightPink = Color(hex: "#FCBAD3")
    static let yellow = Color(hex: "#FFD93D")
    static let green = Color(hex: "#6BCB77")
    static let blue = Color(hex: "#4D96FF")
    static let salmon = Color(hex: "#FF8787")
    
    // MARK: - Glassmorphism Colors
    static let glassBackground = Color.white.opacity(0.95)
    static let glassBorder = Color.black.opacity(0.08)
    static let glassOverlay = Color.black.opacity(0.08)
    
    // MARK: - Helper
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // Get random palette color
    static func randomPaletteColor() -> Color {
        let colors: [Color] = [
            .warmRed, .teal, .mint, .pink, .purple,
            .lightPink, .yellow, .green, .blue, .salmon
        ]
        return colors.randomElement() ?? .brandTeal
    }
    
    // MARK: - Color to Hex Conversion
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        let r = components[0]
        let g = components[1]
        let b = components[2]
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
