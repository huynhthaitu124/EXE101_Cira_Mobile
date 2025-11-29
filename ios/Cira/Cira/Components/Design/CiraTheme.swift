//
//  CiraTheme.swift
//  Cira
//
//  Unified theme colors and gradients for the app
//

import SwiftUI

// MARK: - Theme Colors
struct CiraColors {
    // MARK: Brand Colors
    static let primary = Color(hex: "#5DADE2")      // Cira Blue
    static let secondary = Color(hex: "#9B59B6")    // Purple
    static let accent = Color(hex: "#E91E63")       // Pink
    static let success = Color(hex: "#4CAF50")      // Green
    static let warning = Color(hex: "#F39C12")      // Orange
    static let error = Color(hex: "#E74C3C")        // Red
    
    // MARK: Text Colors
    static let textPrimary = Color(hex: "#2C3E50")
    static let textSecondary = Color(hex: "#34495E")
    static let textTertiary = Color(hex: "#7F8C8D")
    static let textMuted = Color(hex: "#95A5A6")
    static let textInverse = Color.white
    
    // MARK: Background Colors
    static let backgroundPrimary = Color(hex: "#F8F9FA")
    static let backgroundSecondary = Color.white
    static let backgroundTertiary = Color(hex: "#F0F0F0")
    static let backgroundOverlay = Color.black.opacity(0.05)
    
    // MARK: Border Colors
    static let border = Color(hex: "#E8E8E8")       // Default border
    static let borderLight = Color(hex: "#E8E8E8")
    static let borderMedium = Color(hex: "#D0D0D0")
    static let borderDark = Color(hex: "#BDBDBD")
    
    // MARK: Semantic Colors
    static let like = Color(hex: "#FF3B30")
    static let online = Color(hex: "#4ADE80")
    static let offline = Color(hex: "#95A5A6")
}

// MARK: - Gradients
struct CiraGradients {
    // MARK: Primary Gradients
    static let primary = LinearGradient(
        colors: [Color(hex: "#5DADE2"), Color(hex: "#3498DB")],
        startPoint: .leading, endPoint: .trailing
    )
    static let gradient3 = LinearGradient(
        colors: [Color(hex: "#9B59B6"), Color(hex: "#E91E63")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    
    // MARK: Feature Card Gradients (LinearGradient)
    static let featureBlue = LinearGradient(
        colors: [Color(hex: "#5DADE2"), Color(hex: "#3498DB")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let featureGreen = LinearGradient(
        colors: [Color(hex: "#4CAF50"), Color(hex: "#388E3C")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let featurePurple = LinearGradient(
        colors: [Color(hex: "#9B59B6"), Color(hex: "#8E44AD")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let featureOrange = LinearGradient(
        colors: [Color(hex: "#F39C12"), Color(hex: "#E67E22")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let featurePink = LinearGradient(
        colors: [Color(hex: "#E91E63"), Color(hex: "#C2185B")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    
    // MARK: Stat Card Gradients
    static let statBlue = LinearGradient(
        colors: [Color(hex: "#5DADE2"), Color(hex: "#3498DB")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let statOrange = LinearGradient(
        colors: [Color(hex: "#E74C3C"), Color(hex: "#C0392B")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let statGreen = LinearGradient(
        colors: [Color(hex: "#4CAF50"), Color(hex: "#388E3C")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let statPurple = LinearGradient(
        colors: [Color(hex: "#9B59B6"), Color(hex: "#8E44AD")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    
    // MARK: Premium Gradients
    static let gold = LinearGradient(
        colors: [Color(hex: "#F39C12"), Color(hex: "#E67E22")],
        startPoint: .leading, endPoint: .trailing
    )
    static let premium = LinearGradient(
        colors: [Color(hex: "#667EEA"), Color(hex: "#764BA2")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    
    // MARK: Legacy Color Arrays (for backward compatibility)
    static let camera = [Color(hex: "#5DADE2"), Color(hex: "#3498DB")]
    static let gallery = [Color(hex: "#9B59B6"), Color(hex: "#8E44AD")]
    static let memories = [Color(hex: "#E74C3C"), Color(hex: "#C0392B")]
    static let feed = [Color(hex: "#E91E63"), Color(hex: "#C2185B")]
    
    // MARK: Helper function
    static func linear(_ colors: [Color], startPoint: UnitPoint = .topLeading, endPoint: UnitPoint = .bottomTrailing) -> LinearGradient {
        LinearGradient(colors: colors, startPoint: startPoint, endPoint: endPoint)
    }
}

// MARK: - Button Styles
enum CiraButtonStyle {
    case primary
    case secondary
    case ghost
    case danger
    
    var backgroundColor: Color {
        switch self {
        case .primary: return CiraColors.primary
        case .secondary: return CiraColors.backgroundOverlay
        case .ghost: return .clear
        case .danger: return CiraColors.error
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .primary, .danger: return .white
        case .secondary, .ghost: return CiraColors.textPrimary
        }
    }
}

// MARK: - Icon Button Styles
enum CiraIconButtonStyle {
    /// White background with shadow
    case elevated
    /// Light gray background
    case filled
    /// Transparent background
    case ghost
    /// Colored background
    case tinted(Color)
    
    var backgroundColor: Color {
        switch self {
        case .elevated: return .white
        case .filled: return CiraColors.backgroundOverlay
        case .ghost: return .clear
        case .tinted(let color): return color.opacity(0.15)
        }
    }
    
    var hasShadow: Bool {
        switch self {
        case .elevated: return true
        default: return false
        }
    }
}

// MARK: - Card Styles
enum CiraCardStyle {
    /// White card with shadow
    case elevated
    /// White card with border
    case outlined
    /// Gradient background
    case gradient([Color])
    
    @ViewBuilder
    func background() -> some View {
        switch self {
        case .elevated:
            Color.white
        case .outlined:
            Color.white
        case .gradient(let colors):
            CiraGradients.linear(colors)
        }
    }
}

// MARK: - View Modifiers
extension View {
    /// Apply card style
    func ciraCard(style: CiraCardStyle = .elevated, radius: CGFloat = CiraSize.radiusLG) -> some View {
        self.modifier(CiraCardModifier(style: style, radius: radius))
    }
}

struct CiraCardModifier: ViewModifier {
    let style: CiraCardStyle
    let radius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(style.background())
            .cornerRadius(radius)
            .overlay(
                Group {
                    if case .outlined = style {
                        RoundedRectangle(cornerRadius: radius)
                            .stroke(CiraColors.borderLight, lineWidth: 1)
                    }
                }
            )
            .shadow(
                color: {
                    if case .elevated = style { return CiraShadow.card.color }
                    return .clear
                }(),
                radius: CiraShadow.card.radius,
                x: CiraShadow.card.x,
                y: CiraShadow.card.y
            )
    }
}
