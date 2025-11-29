//
//  DesignTokens.swift
//  Cira
//
//  Design system tokens for consistent UI across the app
//  Based on Apple HIG and responsive design principles
//

import SwiftUI

// MARK: - Screen Utilities
struct CiraScreen {
    static var width: CGFloat { UIScreen.main.bounds.width }
    static var height: CGFloat { UIScreen.main.bounds.height }
    static var safeAreaInsets: UIEdgeInsets {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets ?? .zero
    }
    
    /// Base width for scaling (iPhone 14/15 standard)
    static let baseWidth: CGFloat = 390
    
    /// Scale factor based on screen width
    static var scaleFactor: CGFloat { width / baseWidth }
    
    /// Scale a value based on screen width
    static func scale(_ value: CGFloat) -> CGFloat {
        value * scaleFactor
    }
    
    /// Scale with min/max bounds
    static func scale(_ value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        Swift.min(Swift.max(value * scaleFactor, min), max)
    }
    
    /// Check device type
    static var isSmallDevice: Bool { width < 375 }
    static var isLargeDevice: Bool { width > 414 }
    static var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
}

// MARK: - Spacing
struct CiraSpacing {
    /// 2pt - Extra extra small spacing
    static let xxs: CGFloat = 2
    /// 4pt - Extra small spacing
    static let xs: CGFloat = 4
    /// 8pt - Small spacing
    static let sm: CGFloat = 8
    /// 12pt - Medium-small spacing
    static let ms: CGFloat = 12
    /// 16pt - Medium spacing (default)
    static let md: CGFloat = 16
    /// 20pt - Medium-large spacing
    static let ml: CGFloat = 20
    /// 24pt - Large spacing
    static let lg: CGFloat = 24
    /// 32pt - Extra large spacing
    static let xl: CGFloat = 32
    /// 48pt - 2X large spacing
    static let xxl: CGFloat = 48
    
    /// Standard horizontal padding for screens
    static var screenHorizontal: CGFloat { CiraScreen.scale(24, min: 16, max: 32) }
    /// Standard vertical padding for screens
    static var screenVertical: CGFloat { CiraScreen.scale(16, min: 12, max: 24) }
}

// MARK: - Sizes
struct CiraSize {
    // MARK: Icon Buttons
    /// 32pt - Extra small icon button
    static var iconButtonXS: CGFloat { CiraScreen.scale(32, min: 28, max: 36) }
    /// 36pt - Small icon button
    static var iconButtonSM: CGFloat { CiraScreen.scale(36, min: 32, max: 40) }
    /// 44pt - Medium icon button (Apple recommended touch target)
    static var iconButtonMD: CGFloat { CiraScreen.scale(44, min: 40, max: 48) }
    /// 56pt - Large icon button
    static var iconButtonLG: CGFloat { CiraScreen.scale(56, min: 48, max: 64) }
    
    // MARK: Icons
    /// 12pt - Extra small icon
    static let iconXS: CGFloat = 12
    /// 16pt - Small icon
    static let iconSM: CGFloat = 16
    /// 20pt - Medium-small icon
    static let iconMS: CGFloat = 20
    /// 24pt - Medium icon
    static let iconMD: CGFloat = 24
    /// 28pt - Medium-large icon
    static let iconML: CGFloat = 28
    /// 32pt - Large icon
    static let iconLG: CGFloat = 32
    
    // MARK: Cards
    /// Small card height (100pt)
    static var cardSM: CGFloat { CiraScreen.scale(100, min: 90, max: 110) }
    /// Medium card height (140pt)
    static var cardMD: CGFloat { CiraScreen.scale(140, min: 120, max: 160) }
    /// Large card height (180pt)
    static var cardLG: CGFloat { CiraScreen.scale(180, min: 160, max: 200) }
    /// Feature card height
    static var featureCardHeight: CGFloat { CiraScreen.scale(160, min: 140, max: 180) }
    /// Stat card height
    static var statCardHeight: CGFloat { CiraScreen.scale(80, min: 70, max: 90) }
    /// Memory card min height
    static var memoryCardMinHeight: CGFloat { CiraScreen.scale(80, min: 72, max: 96) }
    
    // MARK: Avatars
    /// 32pt - Small avatar
    static var avatarSM: CGFloat { CiraScreen.scale(32, min: 28, max: 36) }
    /// 40pt - Medium avatar
    static var avatarMD: CGFloat { CiraScreen.scale(40, min: 36, max: 44) }
    /// 56pt - Large avatar
    static var avatarLG: CGFloat { CiraScreen.scale(56, min: 48, max: 64) }
    /// 100pt - Extra large avatar (profile)
    static var avatarXL: CGFloat { CiraScreen.scale(100, min: 80, max: 120) }
    
    // MARK: Corner Radius
    /// 8pt - Small radius
    static let radiusSM: CGFloat = 8
    /// 12pt - Medium radius
    static let radiusMD: CGFloat = 12
    /// 16pt - Large radius
    static let radiusLG: CGFloat = 16
    /// 20pt - Extra large radius
    static let radiusXL: CGFloat = 20
    /// Full circle
    static let radiusFull: CGFloat = 999
    
    // MARK: Header
    /// Header height
    static var headerHeight: CGFloat { CiraScreen.scale(56, min: 48, max: 64) }
}

// MARK: - Typography
struct CiraTypography {
    /// 32pt Bold - Large title
    static let largeTitle = Font.system(size: 32, weight: .bold)
    /// 28pt Bold - Title 1
    static let title1 = Font.system(size: 28, weight: .bold)
    /// 24pt Bold - Title 2
    static let title2 = Font.system(size: 24, weight: .bold)
    /// 20pt Semibold - Title 3
    static let title3 = Font.system(size: 20, weight: .semibold)
    /// 18pt Semibold - Headline
    static let headline = Font.system(size: 18, weight: .semibold)
    /// 16pt Semibold - Subheadline
    static let subheadline = Font.system(size: 16, weight: .semibold)
    /// 15pt Regular - Body
    static let body = Font.system(size: 15, weight: .regular)
    /// 14pt Regular - Callout
    static let callout = Font.system(size: 14, weight: .regular)
    /// 13pt Medium - Caption 1
    static let caption1 = Font.system(size: 13, weight: .medium)
    /// 12pt Regular - Caption 2 / Caption alias
    static let caption2 = Font.system(size: 12, weight: .regular)
    /// 12pt Regular - Caption (alias for caption2)
    static let caption = Font.system(size: 12, weight: .regular)
    /// 11pt Medium - Footnote
    static let footnote = Font.system(size: 11, weight: .medium)
}

// MARK: - Shadows
struct CiraShadow {
    /// Light shadow for cards
    static let card = CiraShadowStyle(
        color: Color.black.opacity(0.08),
        radius: 8,
        x: 0,
        y: 2
    )
    
    /// Medium shadow for elevated elements
    static let elevated = CiraShadowStyle(
        color: Color.black.opacity(0.12),
        radius: 12,
        x: 0,
        y: 4
    )
    
    /// Strong shadow for modals/popovers
    static let modal = CiraShadowStyle(
        color: Color.black.opacity(0.15),
        radius: 16,
        x: 0,
        y: 8
    )
    
    /// Subtle shadow for buttons
    static let button = CiraShadowStyle(
        color: Color.black.opacity(0.1),
        radius: 8,
        x: 0,
        y: 2
    )
}

struct CiraShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Extension for Shadows
extension View {
    func ciraShadow(_ style: CiraShadowStyle) -> some View {
        self.shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}

// MARK: - Animation
struct CiraAnimation {
    /// Quick animation (0.2s)
    static let quick = Animation.easeInOut(duration: 0.2)
    /// Standard animation (0.3s)
    static let standard = Animation.easeInOut(duration: 0.3)
    /// Slow animation (0.5s)
    static let slow = Animation.easeInOut(duration: 0.5)
    /// Spring animation
    static let spring = Animation.spring(response: 0.4, dampingFraction: 0.8)
    /// Bouncy spring
    static let bouncy = Animation.spring(response: 0.5, dampingFraction: 0.6)
}
