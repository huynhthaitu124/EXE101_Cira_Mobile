//
//  CiraPrimaryButton.swift
//  Cira
//
//  Primary action button with various variants
//  Full-width button for main CTAs
//

import SwiftUI

struct CiraPrimaryButton: View {
    let title: String
    let icon: String?
    let variant: Variant
    let size: Size
    let isFullWidth: Bool
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    enum Variant {
        case primary
        case secondary
        case ghost
        case danger
        
        var backgroundColor: Color {
            switch self {
            case .primary: return CiraColors.primary
            case .secondary: return CiraColors.backgroundSecondary
            case .ghost: return .clear
            case .danger: return CiraColors.error
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary: return .white
            case .secondary: return CiraColors.textPrimary
            case .ghost: return CiraColors.primary
            case .danger: return .white
            }
        }
        
        var borderColor: Color? {
            switch self {
            case .ghost: return CiraColors.border
            default: return nil
            }
        }
    }
    
    enum Size {
        case small   // Height 36
        case medium  // Height 44
        case large   // Height 52
        
        var height: CGFloat {
            switch self {
            case .small: return 36
            case .medium: return 44
            case .large: return 52
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
            case .medium: return 16
            case .large: return 18
            }
        }
        
        var horizontalPadding: CGFloat {
            switch self {
            case .small: return CiraSpacing.md
            case .medium: return CiraSpacing.lg
            case .large: return CiraSpacing.xl
            }
        }
    }
    
    init(
        _ title: String,
        icon: String? = nil,
        variant: Variant = .primary,
        size: Size = .medium,
        isFullWidth: Bool = true,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.variant = variant
        self.size = size
        self.isFullWidth = isFullWidth
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            if !isLoading && !isDisabled {
                action()
            }
        }) {
            HStack(spacing: CiraSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: variant.foregroundColor))
                        .scaleEffect(0.8)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: size.iconSize, weight: .medium))
                    }
                    
                    Text(title)
                        .font(size.fontSize.bold())
                }
            }
            .foregroundColor(variant.foregroundColor)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(height: size.height)
            .padding(.horizontal, isFullWidth ? 0 : size.horizontalPadding)
            .background(
                RoundedRectangle(cornerRadius: CiraSize.radiusMD)
                    .fill(isDisabled ? variant.backgroundColor.opacity(0.5) : variant.backgroundColor)
            )
            .overlay(
                Group {
                    if let borderColor = variant.borderColor {
                        RoundedRectangle(cornerRadius: CiraSize.radiusMD)
                            .stroke(borderColor, lineWidth: 1)
                    }
                }
            )
        }
        .disabled(isDisabled || isLoading)
        .buttonStyle(CiraPrimaryButtonPressStyle(variant: variant))
    }
}

// MARK: - Press Animation Style
struct CiraPrimaryButtonPressStyle: ButtonStyle {
    let variant: CiraPrimaryButton.Variant
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(CiraAnimation.quick, value: configuration.isPressed)
    }
}

// MARK: - Convenience Initializers
extension CiraPrimaryButton {
    /// Primary CTA button
    static func primary(_ title: String, icon: String? = nil, action: @escaping () -> Void) -> CiraPrimaryButton {
        CiraPrimaryButton(title, icon: icon, variant: .primary, action: action)
    }
    
    /// Secondary button
    static func secondary(_ title: String, icon: String? = nil, action: @escaping () -> Void) -> CiraPrimaryButton {
        CiraPrimaryButton(title, icon: icon, variant: .secondary, action: action)
    }
    
    /// Ghost/outline button
    static func ghost(_ title: String, icon: String? = nil, action: @escaping () -> Void) -> CiraPrimaryButton {
        CiraPrimaryButton(title, icon: icon, variant: .ghost, action: action)
    }
    
    /// Danger/destructive button
    static func danger(_ title: String, icon: String? = nil, action: @escaping () -> Void) -> CiraPrimaryButton {
        CiraPrimaryButton(title, icon: icon, variant: .danger, action: action)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 16) {
        CiraPrimaryButton.primary("Tiếp tục", icon: "arrow.right") {}
        
        CiraPrimaryButton.secondary("Chọn ảnh", icon: "photo") {}
        
        CiraPrimaryButton.ghost("Huỷ bỏ") {}
        
        CiraPrimaryButton.danger("Xoá tài khoản", icon: "trash") {}
        
        HStack(spacing: 12) {
            CiraPrimaryButton("Nhỏ", variant: .primary, size: .small, isFullWidth: false) {}
            CiraPrimaryButton("Vừa", variant: .secondary, size: .medium, isFullWidth: false) {}
            CiraPrimaryButton("Lớn", variant: .primary, size: .large, isFullWidth: false) {}
        }
        
        CiraPrimaryButton("Đang tải...", variant: .primary, isLoading: true) {}
        
        CiraPrimaryButton("Không khả dụng", variant: .primary, isDisabled: true) {}
    }
    .padding()
    .background(CiraColors.backgroundPrimary)
}
