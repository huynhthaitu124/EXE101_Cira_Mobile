//
//  CiraGradientButton.swift
//  Cira
//
//  Gradient button for premium/special actions
//  Used for feature highlights and premium CTAs
//

import SwiftUI

struct CiraGradientButton: View {
    let title: String
    let icon: String?
    let gradient: LinearGradient
    let size: Size
    let isFullWidth: Bool
    let action: () -> Void
    
    enum Size {
        case small
        case medium
        case large
        
        var height: CGFloat {
            switch self {
            case .small: return 40
            case .medium: return 48
            case .large: return 56
            }
        }
        
        var fontSize: Font {
            switch self {
            case .small: return CiraTypography.footnote
            case .medium: return CiraTypography.callout
            case .large: return CiraTypography.body
            }
        }
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 14
            case .medium: return 18
            case .large: return 20
            }
        }
    }
    
    init(
        _ title: String,
        icon: String? = nil,
        gradient: LinearGradient = CiraGradients.premium,
        size: Size = .medium,
        isFullWidth: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.gradient = gradient
        self.size = size
        self.isFullWidth = isFullWidth
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: CiraSpacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: size.iconSize, weight: .semibold))
                }
                
                Text(title)
                    .font(size.fontSize.bold())
            }
            .foregroundColor(.white)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(height: size.height)
            .padding(.horizontal, isFullWidth ? 0 : CiraSpacing.xl)
            .background(
                RoundedRectangle(cornerRadius: CiraSize.radiusMD)
                    .fill(gradient)
            )
            .ciraShadow(CiraShadow.elevated)
        }
        .buttonStyle(CiraGradientButtonPressStyle())
    }
}

// MARK: - Press Animation
struct CiraGradientButtonPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.95 : 1.0)
            .animation(CiraAnimation.quick, value: configuration.isPressed)
    }
}

// MARK: - Convenience Initializers
extension CiraGradientButton {
    /// Premium upgrade button
    static func premium(_ title: String = "Nâng cấp Premium", action: @escaping () -> Void) -> CiraGradientButton {
        CiraGradientButton(title, icon: "crown.fill", gradient: CiraGradients.premium, action: action)
    }
    
    /// Camera/capture button with blue gradient
    static func capture(_ title: String = "Chụp ảnh", action: @escaping () -> Void) -> CiraGradientButton {
        CiraGradientButton(title, icon: "camera.fill", gradient: CiraGradients.featureBlue, action: action)
    }
    
    /// Share button with green gradient
    static func share(_ title: String = "Chia sẻ", action: @escaping () -> Void) -> CiraGradientButton {
        CiraGradientButton(title, icon: "square.and.arrow.up", gradient: CiraGradients.featureGreen, action: action)
    }
    
    /// AI feature button with purple gradient
    static func ai(_ title: String = "AI Magic", action: @escaping () -> Void) -> CiraGradientButton {
        CiraGradientButton(title, icon: "sparkles", gradient: CiraGradients.featurePurple, action: action)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 16) {
        CiraGradientButton.premium {}
        
        CiraGradientButton.capture {}
        
        CiraGradientButton.share {}
        
        CiraGradientButton.ai {}
        
        HStack(spacing: 12) {
            CiraGradientButton("Nhỏ", gradient: CiraGradients.featureOrange, size: .small, isFullWidth: false) {}
            CiraGradientButton("Vừa", gradient: CiraGradients.featurePink, size: .medium, isFullWidth: false) {}
        }
    }
    .padding()
    .background(CiraColors.backgroundPrimary)
}
