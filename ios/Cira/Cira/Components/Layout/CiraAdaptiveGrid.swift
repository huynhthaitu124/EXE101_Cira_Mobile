//
//  CiraAdaptiveGrid.swift
//  Cira
//
//  Responsive grid layout that adapts to screen size
//  Automatically adjusts columns based on available width
//

import SwiftUI

struct CiraAdaptiveGrid<Content: View>: View {
    let columns: Int
    let spacing: CGFloat
    let content: () -> Content
    
    init(
        columns: Int = 2,
        spacing: CGFloat = CiraSpacing.md,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.columns = columns
        self.spacing = spacing
        self.content = content
    }
    
    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns)
    }
    
    var body: some View {
        LazyVGrid(columns: gridColumns, spacing: spacing) {
            content()
        }
    }
}

// MARK: - Photo Grid
struct CiraPhotoGrid<Content: View>: View {
    let columns: Int
    let spacing: CGFloat
    let aspectRatio: CGFloat
    let content: () -> Content
    
    init(
        columns: Int = 3,
        spacing: CGFloat = CiraSpacing.xxs,
        aspectRatio: CGFloat = 1.0,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.columns = columns
        self.spacing = spacing
        self.aspectRatio = aspectRatio
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            let itemWidth = (geometry.size.width - spacing * CGFloat(columns - 1)) / CGFloat(columns)
            
            LazyVGrid(
                columns: Array(repeating: GridItem(.fixed(itemWidth), spacing: spacing), count: columns),
                spacing: spacing
            ) {
                content()
            }
        }
    }
}

// MARK: - Photo Grid Item
struct CiraPhotoGridItem: View {
    let imageName: String?
    let aspectRatio: CGFloat
    let cornerRadius: CGFloat
    let overlay: AnyView?
    let action: (() -> Void)?
    
    init(
        imageName: String? = nil,
        aspectRatio: CGFloat = 1.0,
        cornerRadius: CGFloat = CiraSize.radiusSM,
        overlay: AnyView? = nil,
        action: (() -> Void)? = nil
    ) {
        self.imageName = imageName
        self.aspectRatio = aspectRatio
        self.cornerRadius = cornerRadius
        self.overlay = overlay
        self.action = action
    }
    
    var body: some View {
        let content = ZStack {
            if let imageName = imageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                CiraColors.backgroundTertiary
            }
            
            if let overlay = overlay {
                overlay
            }
        }
        .aspectRatio(aspectRatio, contentMode: .fill)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        
        if let action = action {
            Button(action: action) {
                content
            }
            .buttonStyle(CiraCardPressStyle())
        } else {
            content
        }
    }
}

// MARK: - Responsive Columns Calculator
struct CiraGridLayout {
    /// Calculate optimal columns based on screen width and minimum item width
    static func optimalColumns(
        for width: CGFloat,
        minItemWidth: CGFloat = 150,
        spacing: CGFloat = CiraSpacing.md
    ) -> Int {
        let availableWidth = width
        let itemWidthWithSpacing = minItemWidth + spacing
        let columns = max(1, Int(floor(availableWidth / itemWidthWithSpacing)))
        return columns
    }
    
    /// Standard 2-column grid items
    static var twoColumn: [GridItem] {
        [
            GridItem(.flexible(), spacing: CiraSpacing.md),
            GridItem(.flexible(), spacing: CiraSpacing.md)
        ]
    }
    
    /// Standard 3-column grid items (for photos)
    static var threeColumn: [GridItem] {
        [
            GridItem(.flexible(), spacing: CiraSpacing.xxs),
            GridItem(.flexible(), spacing: CiraSpacing.xxs),
            GridItem(.flexible(), spacing: CiraSpacing.xxs)
        ]
    }
    
    /// Standard 4-column grid items (for thumbnails)
    static var fourColumn: [GridItem] {
        [
            GridItem(.flexible(), spacing: CiraSpacing.xxs),
            GridItem(.flexible(), spacing: CiraSpacing.xxs),
            GridItem(.flexible(), spacing: CiraSpacing.xxs),
            GridItem(.flexible(), spacing: CiraSpacing.xxs)
        ]
    }
    
    /// Adaptive grid that adjusts to screen width
    static func adaptive(minWidth: CGFloat = 100) -> [GridItem] {
        [GridItem(.adaptive(minimum: minWidth), spacing: CiraSpacing.xs)]
    }
}

// MARK: - Feature Grid (2x2 for Dashboard)
struct CiraFeatureGrid: View {
    let items: [FeatureGridItem]
    
    struct FeatureGridItem: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String?
        let icon: String
        let gradient: LinearGradient
        let badge: String?
        let action: () -> Void
    }
    
    init(items: [FeatureGridItem]) {
        self.items = items
    }
    
    var body: some View {
        LazyVGrid(columns: CiraGridLayout.twoColumn, spacing: CiraSpacing.md) {
            ForEach(items) { item in
                CiraFeatureCard(
                    title: item.title,
                    subtitle: item.subtitle,
                    icon: item.icon,
                    gradient: item.gradient,
                    badge: item.badge,
                    action: item.action
                )
            }
        }
    }
}

// MARK: - Stats Grid
struct CiraStatsGrid: View {
    let items: [StatGridItem]
    let columns: Int
    
    struct StatGridItem: Identifiable {
        let id = UUID()
        let value: String
        let label: String
        let icon: String?
        let gradient: LinearGradient?
        let style: CiraStatCard.Style
        let action: (() -> Void)?
        
        init(
            value: String,
            label: String,
            icon: String? = nil,
            gradient: LinearGradient? = nil,
            style: CiraStatCard.Style = .filled,
            action: (() -> Void)? = nil
        ) {
            self.value = value
            self.label = label
            self.icon = icon
            self.gradient = gradient
            self.style = style
            self.action = action
        }
    }
    
    init(items: [StatGridItem], columns: Int = 2) {
        self.items = items
        self.columns = columns
    }
    
    var body: some View {
        let gridItems = Array(repeating: GridItem(.flexible(), spacing: CiraSpacing.md), count: columns)
        
        LazyVGrid(columns: gridItems, spacing: CiraSpacing.md) {
            ForEach(items) { item in
                CiraStatCard(
                    value: item.value,
                    label: item.label,
                    icon: item.icon,
                    gradient: item.gradient,
                    style: item.style,
                    action: item.action
                )
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: CiraSpacing.xl) {
            // Feature Grid
            Text("Feature Grid (2x2)")
                .font(CiraTypography.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            CiraFeatureGrid(items: [
                .init(title: "Chụp ảnh", subtitle: nil, icon: "camera.fill", gradient: CiraGradients.featureBlue, badge: nil) {},
                .init(title: "Thư viện", subtitle: "256 ảnh", icon: "photo", gradient: CiraGradients.featureGreen, badge: nil) {},
                .init(title: "Gia đình", subtitle: nil, icon: "person.3", gradient: CiraGradients.featureOrange, badge: nil) {},
                .init(title: "AI Magic", subtitle: nil, icon: "sparkles", gradient: CiraGradients.featurePink, badge: "MỚI") {}
            ])
            
            // Stats Grid
            Text("Stats Grid (2x2)")
                .font(CiraTypography.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            CiraStatsGrid(items: [
                .init(value: "256", label: "Ảnh", icon: "photo", gradient: CiraGradients.statBlue),
                .init(value: "7", label: "Streak", icon: "flame.fill", gradient: CiraGradients.statOrange),
                .init(value: "5", label: "Thành viên", icon: "person.2", gradient: CiraGradients.statGreen),
                .init(value: "2.4 GB", label: "Dung lượng", icon: "externaldrive", gradient: CiraGradients.statPurple)
            ])
            
            // Photo Grid
            Text("Photo Grid (3 columns)")
                .font(CiraTypography.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: CiraGridLayout.threeColumn, spacing: CiraSpacing.xxs) {
                ForEach(0..<9) { _ in
                    CiraPhotoGridItem()
                        .frame(height: 120)
                }
            }
        }
        .padding(CiraSpacing.lg)
    }
    .background(CiraColors.backgroundPrimary)
}
