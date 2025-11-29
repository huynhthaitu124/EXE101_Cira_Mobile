//
//  CiraIconButton.swift
//  Cira
//
//  Reusable circular icon button component
//  Replaces all duplicate circular buttons across the app
//

import SwiftUI

struct CiraIconButton: View {
    let icon: String
    let style: CiraIconButtonStyle
    let size: Size
    var iconColor: Color?
    let action: () -> Void
    
    enum Size {
        case small   // 32pt
        case medium  // 36pt
        case large   // 44pt
        case xlarge  // 56pt
        
        var dimension: CGFloat {
            switch self {
            case .small: return CiraSize.iconButtonXS
            case .medium: return CiraSize.iconButtonSM
            case .large: return CiraSize.iconButtonMD
            case .xlarge: return CiraSize.iconButtonLG
            }
        }
        
        var iconSize: CGFloat {
            switch self {
            case .small: return CiraSize.iconSM
            case .medium: return CiraSize.iconMS
            case .large: return CiraSize.iconMD
            case .xlarge: return CiraSize.iconML
            }
        }
    }
    
    init(
        icon: String,
        style: CiraIconButtonStyle = .filled,
        size: Size = .large,
        iconColor: Color? = nil,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.style = style
        self.size = size
        self.iconColor = iconColor
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(style.backgroundColor)
                    .frame(width: size.dimension, height: size.dimension)
                
                Image(systemName: icon)
                    .font(.system(size: size.iconSize, weight: .medium))
                    .foregroundColor(foregroundColor)
            }
            .ciraShadow(style.hasShadow ? CiraShadow.button : CiraShadowStyle(color: .clear, radius: 0, x: 0, y: 0))
        }
        .buttonStyle(CiraIconButtonPressStyle())
    }
    
    private var foregroundColor: Color {
        if let iconColor = iconColor {
            return iconColor
        }
        switch style {
        case .tinted(let color):
            return color
        default:
            return CiraColors.textPrimary
        }
    }
}

// MARK: - Press Animation Style
struct CiraIconButtonPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(CiraAnimation.quick, value: configuration.isPressed)
    }
}

// MARK: - Convenience Initializers
extension CiraIconButton {
    /// Back button with arrow.left icon
    static func back(action: @escaping () -> Void) -> CiraIconButton {
        CiraIconButton(
            icon: "arrow.left",
            style: .filled,
            size: .medium,
            action: action
        )
    }
    
    /// Close button with xmark icon
    static func close(action: @escaping () -> Void) -> CiraIconButton {
        CiraIconButton(
            icon: "xmark",
            style: .filled,
            size: .medium,
            action: action
        )
    }
    
    /// Notification bell button
    static func notifications(action: @escaping () -> Void) -> CiraIconButton {
        CiraIconButton(
            icon: "bell",
            style: .elevated,
            size: .large,
            action: action
        )
    }
    
    /// Profile/person button
    static func profile(action: @escaping () -> Void) -> CiraIconButton {
        CiraIconButton(
            icon: "person.circle",
            style: .elevated,
            size: .large,
            iconColor: CiraColors.textPrimary,
            action: action
        )
    }
    
    /// Settings gear button
    static func settings(action: @escaping () -> Void) -> CiraIconButton {
        CiraIconButton(
            icon: "gearshape",
            style: .filled,
            size: .large,
            action: action
        )
    }
    
    /// Add/plus button
    static func add(style: CiraIconButtonStyle = .tinted(CiraColors.primary), action: @escaping () -> Void) -> CiraIconButton {
        CiraIconButton(
            icon: "plus",
            style: style,
            size: .large,
            action: action
        )
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 16) {
            CiraIconButton.back {}
            CiraIconButton.close {}
            CiraIconButton.notifications {}
            CiraIconButton.profile {}
        }
        
        HStack(spacing: 16) {
            CiraIconButton(icon: "heart.fill", style: .tinted(CiraColors.error), size: .medium) {}
            CiraIconButton(icon: "star.fill", style: .tinted(CiraColors.warning), size: .medium) {}
            CiraIconButton(icon: "camera.fill", style: .tinted(CiraColors.primary), size: .medium) {}
        }
        
        HStack(spacing: 16) {
            CiraIconButton(icon: "arrow.left", style: .ghost, size: .small) {}
            CiraIconButton(icon: "ellipsis", style: .ghost, size: .medium) {}
            CiraIconButton(icon: "chevron.right", style: .ghost, size: .large) {}
        }
    }
    .padding()
    .background(CiraColors.backgroundPrimary)
}
