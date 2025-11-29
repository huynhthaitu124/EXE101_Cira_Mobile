//
//  CiraStatCard.swift
//  Cira
//
//  Statistics/info card with value and label
//  Used for displaying metrics and counts
//

import SwiftUI

struct CiraStatCard: View {
    let value: String
    let label: String
    let icon: String?
    let gradient: LinearGradient?
    let style: Style
    let action: (() -> Void)?
    
    enum Style {
        case filled     // Gradient background
        case outlined   // Border only
        case minimal    // No background, just content
    }
    
    init(
        value: String,
        label: String,
        icon: String? = nil,
        gradient: LinearGradient? = nil,
        style: Style = .filled,
        action: (() -> Void)? = nil
    ) {
        self.value = value
        self.label = label
        self.icon = icon
        self.gradient = gradient
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Group {
            if let action = action {
                Button(action: action) {
                    cardContent
                }
                .buttonStyle(CiraCardPressStyle())
            } else {
                cardContent
            }
        }
    }
    
    private var cardContent: some View {
        VStack(spacing: CiraSpacing.xs) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: CiraSize.iconMS, weight: .medium))
                    .foregroundColor(style == .filled ? .white.opacity(0.9) : CiraColors.primary)
            }
            
            Text(value)
                .font(CiraTypography.title2)
                .fontWeight(.bold)
                .foregroundColor(style == .filled ? .white : CiraColors.textPrimary)
            
            Text(label)
                .font(CiraTypography.caption)
                .foregroundColor(style == .filled ? .white.opacity(0.8) : CiraColors.textSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(CiraSpacing.md)
        .background(
            Group {
                switch style {
                case .filled:
                    RoundedRectangle(cornerRadius: CiraSize.radiusMD)
                        .fill(gradient ?? CiraGradients.statBlue)
                case .outlined:
                    RoundedRectangle(cornerRadius: CiraSize.radiusMD)
                        .stroke(CiraColors.border, lineWidth: 1)
                        .background(
                            RoundedRectangle(cornerRadius: CiraSize.radiusMD)
                                .fill(CiraColors.backgroundSecondary)
                        )
                case .minimal:
                    Color.clear
                }
            }
        )
    }
}

// MARK: - Convenience Constructors
extension CiraStatCard {
    /// Photo count stat
    static func photos(_ count: Int, action: (() -> Void)? = nil) -> CiraStatCard {
        CiraStatCard(
            value: "\(count)",
            label: "Ảnh",
            icon: "photo",
            gradient: CiraGradients.statBlue,
            style: .filled,
            action: action
        )
    }
    
    /// Streak stat
    static func streak(_ days: Int, action: (() -> Void)? = nil) -> CiraStatCard {
        CiraStatCard(
            value: "\(days)",
            label: "Ngày liên tiếp",
            icon: "flame.fill",
            gradient: CiraGradients.statOrange,
            style: .filled,
            action: action
        )
    }
    
    /// Members stat
    static func members(_ count: Int, action: (() -> Void)? = nil) -> CiraStatCard {
        CiraStatCard(
            value: "\(count)",
            label: "Thành viên",
            icon: "person.2.fill",
            gradient: CiraGradients.statGreen,
            style: .filled,
            action: action
        )
    }
    
    /// Storage stat
    static func storage(used: String, action: (() -> Void)? = nil) -> CiraStatCard {
        CiraStatCard(
            value: used,
            label: "Dung lượng",
            icon: "externaldrive.fill",
            gradient: CiraGradients.statPurple,
            style: .filled,
            action: action
        )
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: CiraSpacing.lg) {
        // Filled style
        HStack(spacing: CiraSpacing.md) {
            CiraStatCard.photos(256)
            CiraStatCard.streak(7)
        }
        
        HStack(spacing: CiraSpacing.md) {
            CiraStatCard.members(5)
            CiraStatCard.storage(used: "2.4 GB")
        }
        
        // Outlined style
        HStack(spacing: CiraSpacing.md) {
            CiraStatCard(value: "42", label: "Album", style: .outlined)
            CiraStatCard(value: "128", label: "Video", style: .outlined)
        }
        
        // Minimal style
        HStack(spacing: CiraSpacing.md) {
            CiraStatCard(value: "1.2K", label: "Lượt xem", icon: "eye", style: .minimal)
            CiraStatCard(value: "89", label: "Thích", icon: "heart.fill", style: .minimal)
        }
    }
    .padding(CiraSpacing.lg)
    .background(CiraColors.backgroundPrimary)
}
