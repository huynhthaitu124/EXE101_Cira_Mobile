//
//  CiraSection.swift
//  Cira
//
//  Section container with optional header and "See All" button
//  Used for organizing content in screens
//

import SwiftUI

struct CiraSection<Content: View>: View {
    let title: String?
    let subtitle: String?
    let seeAllAction: (() -> Void)?
    let content: () -> Content
    
    init(
        title: String? = nil,
        subtitle: String? = nil,
        seeAllAction: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.seeAllAction = seeAllAction
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: CiraSpacing.md) {
            // Header
            if title != nil || seeAllAction != nil {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        if let title = title {
                            Text(title)
                                .font(CiraTypography.title3)
                                .fontWeight(.bold)
                                .foregroundColor(CiraColors.textPrimary)
                        }
                        
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(CiraTypography.subheadline)
                                .foregroundColor(CiraColors.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    if let seeAllAction = seeAllAction {
                        Button(action: seeAllAction) {
                            Text("Xem tất cả")
                                .font(CiraTypography.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(CiraColors.primary)
                        }
                    }
                }
            }
            
            // Content
            content()
        }
    }
}

// MARK: - Horizontal Scroll Section
struct CiraHorizontalSection<Content: View>: View {
    let title: String?
    let subtitle: String?
    let seeAllAction: (() -> Void)?
    let spacing: CGFloat
    let content: () -> Content
    
    init(
        title: String? = nil,
        subtitle: String? = nil,
        seeAllAction: (() -> Void)? = nil,
        spacing: CGFloat = CiraSpacing.md,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.seeAllAction = seeAllAction
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: CiraSpacing.md) {
            // Header
            if title != nil || seeAllAction != nil {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        if let title = title {
                            Text(title)
                                .font(CiraTypography.title3)
                                .fontWeight(.bold)
                                .foregroundColor(CiraColors.textPrimary)
                        }
                        
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(CiraTypography.subheadline)
                                .foregroundColor(CiraColors.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    if let seeAllAction = seeAllAction {
                        Button(action: seeAllAction) {
                            Text("Xem tất cả")
                                .font(CiraTypography.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(CiraColors.primary)
                        }
                    }
                }
                .padding(.horizontal, CiraSpacing.lg)
            }
            
            // Horizontal Scroll Content
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: spacing) {
                    content()
                }
                .padding(.horizontal, CiraSpacing.lg)
            }
        }
    }
}

// MARK: - Card Section (with background)
struct CiraCardSection<Content: View>: View {
    let title: String?
    let icon: String?
    let content: () -> Content
    
    init(
        title: String? = nil,
        icon: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: CiraSpacing.md) {
            if let title = title {
                HStack(spacing: CiraSpacing.sm) {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: CiraSize.iconSM, weight: .medium))
                            .foregroundColor(CiraColors.primary)
                    }
                    
                    Text(title)
                        .font(CiraTypography.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(CiraColors.textPrimary)
                }
            }
            
            content()
        }
        .padding(CiraSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: CiraSize.radiusLG)
                .fill(CiraColors.backgroundSecondary)
        )
        .ciraShadow(CiraShadow.card)
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: CiraSpacing.xl) {
            // Regular Section
            CiraSection(title: "Tính năng", subtitle: "Khám phá Cira") {
                CiraFeatureGrid(items: [
                    .init(title: "Chụp ảnh", subtitle: nil, icon: "camera.fill", gradient: CiraGradients.featureBlue, badge: nil) {},
                    .init(title: "Thư viện", subtitle: nil, icon: "photo", gradient: CiraGradients.featureGreen, badge: nil) {}
                ])
            }
            .padding(.horizontal, CiraSpacing.lg)
            
            // Horizontal Section
            CiraHorizontalSection(title: "Kỷ niệm", seeAllAction: {}) {
                ForEach(0..<5) { _ in
                    RoundedRectangle(cornerRadius: CiraSize.radiusMD)
                        .fill(CiraGradients.featurePurple)
                        .frame(width: 200, height: 120)
                }
            }
            
            // Card Section
            CiraCardSection(title: "Thống kê", icon: "chart.bar.fill") {
                CiraStatsGrid(items: [
                    .init(value: "256", label: "Ảnh", style: .outlined),
                    .init(value: "7", label: "Streak", style: .outlined)
                ])
            }
            .padding(.horizontal, CiraSpacing.lg)
        }
        .padding(.vertical, CiraSpacing.lg)
    }
    .background(CiraColors.backgroundPrimary)
}
