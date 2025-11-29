//
//  CiraFeatureCard.swift
//  Cira
//
//  Feature card with gradient background and icon
//  Used in Dashboard for feature navigation
//

import SwiftUI

struct CiraFeatureCard: View {
    let title: String
    let subtitle: String?
    let icon: String
    let gradient: LinearGradient
    let badge: String?
    let size: Size
    let action: () -> Void
    
    enum Size {
        case small   // Grid cell size
        case medium  // Half width
        case large   // Full width
        
        var height: CGFloat {
            switch self {
            case .small: return CiraSize.cardSM
            case .medium: return CiraSize.cardMD
            case .large: return CiraSize.cardLG
            }
        }
        
        var iconSize: CGFloat {
            switch self {
            case .small: return CiraSize.iconMD
            case .medium: return CiraSize.iconML
            case .large: return CiraSize.iconLG
            }
        }
        
        var titleFont: Font {
            switch self {
            case .small: return CiraTypography.footnote
            case .medium: return CiraTypography.callout
            case .large: return CiraTypography.body
            }
        }
    }
    
    init(
        title: String,
        subtitle: String? = nil,
        icon: String,
        gradient: LinearGradient = CiraGradients.featureBlue,
        badge: String? = nil,
        size: Size = .medium,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.gradient = gradient
        self.badge = badge
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                // Background
                RoundedRectangle(cornerRadius: CiraSize.radiusLG)
                    .fill(gradient)
                
                // Content
                VStack(alignment: .leading, spacing: CiraSpacing.sm) {
                    // Icon
                    Image(systemName: icon)
                        .font(.system(size: size.iconSize, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                    
                    // Title & Subtitle
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(size.titleFont.bold())
                            .foregroundColor(.white)
                            .lineLimit(2)
                        
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(CiraTypography.caption)
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(1)
                        }
                    }
                }
                .padding(CiraSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Badge
                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.25))
                        .clipShape(Capsule())
                        .padding(CiraSpacing.sm)
                }
            }
            .frame(height: size.height)
        }
        .buttonStyle(CiraCardPressStyle())
    }
}

// MARK: - Press Style
struct CiraCardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(CiraAnimation.quick, value: configuration.isPressed)
    }
}

// MARK: - Feature Card Presets
extension CiraFeatureCard {
    static func camera(action: @escaping () -> Void) -> CiraFeatureCard {
        CiraFeatureCard(
            title: "Chụp ảnh",
            subtitle: "Ghi lại khoảnh khắc",
            icon: "camera.fill",
            gradient: CiraGradients.featureBlue,
            action: action
        )
    }
    
    static func gallery(count: Int, action: @escaping () -> Void) -> CiraFeatureCard {
        CiraFeatureCard(
            title: "Thư viện",
            subtitle: "\(count) ảnh",
            icon: "photo.on.rectangle.angled",
            gradient: CiraGradients.featureGreen,
            action: action
        )
    }
    
    static func family(action: @escaping () -> Void) -> CiraFeatureCard {
        CiraFeatureCard(
            title: "Gia đình",
            subtitle: "Chia sẻ khoảnh khắc",
            icon: "person.3.fill",
            gradient: CiraGradients.featureOrange,
            action: action
        )
    }
    
    static func calendar(action: @escaping () -> Void) -> CiraFeatureCard {
        CiraFeatureCard(
            title: "Lịch ảnh",
            subtitle: "Xem theo ngày",
            icon: "calendar",
            gradient: CiraGradients.featurePurple,
            action: action
        )
    }
    
    static func aiMagic(action: @escaping () -> Void) -> CiraFeatureCard {
        CiraFeatureCard(
            title: "AI Magic",
            subtitle: "Tự động tạo album",
            icon: "sparkles",
            gradient: CiraGradients.featurePink,
            badge: "MỚI",
            action: action
        )
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: CiraSpacing.md) {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: CiraSpacing.md),
                GridItem(.flexible(), spacing: CiraSpacing.md)
            ], spacing: CiraSpacing.md) {
                CiraFeatureCard.camera {}
                CiraFeatureCard.gallery(count: 256) {}
                CiraFeatureCard.family {}
                CiraFeatureCard.calendar {}
            }
            
            CiraFeatureCard.aiMagic {}
        }
        .padding(CiraSpacing.lg)
    }
    .background(CiraColors.backgroundPrimary)
}
