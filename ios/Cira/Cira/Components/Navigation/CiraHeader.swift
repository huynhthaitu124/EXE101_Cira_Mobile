//
//  CiraHeader.swift
//  Cira
//
//  Unified header component for all screens
//  Supports back button, title, subtitle, and action buttons
//

import SwiftUI

struct CiraHeader: View {
    let title: String
    let subtitle: String?
    let style: Style
    let leftAction: HeaderAction?
    let rightActions: [HeaderAction]
    
    enum Style {
        case large       // Large title with optional subtitle
        case standard    // Standard navigation bar style
        case compact     // Compact with centered title
        
        var titleFont: Font {
            switch self {
            case .large: return CiraTypography.largeTitle
            case .standard: return CiraTypography.title3
            case .compact: return CiraTypography.headline
            }
        }
        
        var spacing: CGFloat {
            switch self {
            case .large: return CiraSpacing.lg
            case .standard: return CiraSpacing.md
            case .compact: return CiraSpacing.sm
            }
        }
    }
    
    struct HeaderAction: Identifiable {
        let id = UUID()
        let icon: String
        let badge: Int?
        let style: CiraIconButtonStyle
        let action: () -> Void
        
        init(icon: String, badge: Int? = nil, style: CiraIconButtonStyle = .filled, action: @escaping () -> Void) {
            self.icon = icon
            self.badge = badge
            self.style = style
            self.action = action
        }
    }
    
    init(
        title: String,
        subtitle: String? = nil,
        style: Style = .large,
        leftAction: HeaderAction? = nil,
        rightActions: [HeaderAction] = []
    ) {
        self.title = title
        self.subtitle = subtitle
        self.style = style
        self.leftAction = leftAction
        self.rightActions = rightActions
    }
    
    var body: some View {
        switch style {
        case .large:
            largeHeader
        case .standard:
            standardHeader
        case .compact:
            compactHeader
        }
    }
    
    // MARK: - Large Header
    private var largeHeader: some View {
        VStack(alignment: .leading, spacing: CiraSpacing.xs) {
            HStack(alignment: .center) {
                if let leftAction = leftAction {
                    CiraIconButton(
                        icon: leftAction.icon,
                        style: leftAction.style,
                        size: .medium,
                        action: leftAction.action
                    )
                    .padding(.trailing, CiraSpacing.sm)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(style.titleFont)
                        .fontWeight(.bold)
                        .foregroundColor(CiraColors.textPrimary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(CiraTypography.subheadline)
                            .foregroundColor(CiraColors.textSecondary)
                    }
                }
                
                Spacer()
                
                HStack(spacing: CiraSpacing.sm) {
                    ForEach(rightActions) { action in
                        headerButton(for: action)
                    }
                }
            }
        }
        .padding(.horizontal, CiraSpacing.lg)
        .padding(.vertical, style.spacing)
    }
    
    // MARK: - Standard Header
    private var standardHeader: some View {
        HStack(alignment: .center) {
            if let leftAction = leftAction {
                CiraIconButton(
                    icon: leftAction.icon,
                    style: leftAction.style,
                    size: .medium,
                    action: leftAction.action
                )
            } else {
                // Placeholder for alignment
                Color.clear
                    .frame(width: CiraSize.iconButtonSM, height: CiraSize.iconButtonSM)
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text(title)
                    .font(style.titleFont)
                    .fontWeight(.semibold)
                    .foregroundColor(CiraColors.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(CiraTypography.caption)
                        .foregroundColor(CiraColors.textSecondary)
                }
            }
            
            Spacer()
            
            if !rightActions.isEmpty {
                HStack(spacing: CiraSpacing.sm) {
                    ForEach(rightActions) { action in
                        headerButton(for: action)
                    }
                }
            } else {
                // Placeholder for alignment
                Color.clear
                    .frame(width: CiraSize.iconButtonSM, height: CiraSize.iconButtonSM)
            }
        }
        .padding(.horizontal, CiraSpacing.lg)
        .padding(.vertical, style.spacing)
    }
    
    // MARK: - Compact Header
    private var compactHeader: some View {
        HStack(alignment: .center) {
            if let leftAction = leftAction {
                CiraIconButton(
                    icon: leftAction.icon,
                    style: .ghost,
                    size: .small,
                    action: leftAction.action
                )
            }
            
            Spacer()
            
            Text(title)
                .font(style.titleFont)
                .fontWeight(.semibold)
                .foregroundColor(CiraColors.textPrimary)
            
            Spacer()
            
            if let firstAction = rightActions.first {
                CiraIconButton(
                    icon: firstAction.icon,
                    style: .ghost,
                    size: .small,
                    action: firstAction.action
                )
            }
        }
        .padding(.horizontal, CiraSpacing.md)
        .padding(.vertical, style.spacing)
    }
    
    // MARK: - Header Button with Badge
    @ViewBuilder
    private func headerButton(for action: HeaderAction) -> some View {
        ZStack(alignment: .topTrailing) {
            CiraIconButton(
                icon: action.icon,
                style: action.style,
                size: .medium,
                action: action.action
            )
            
            if let badge = action.badge, badge > 0 {
                Text(badge > 99 ? "99+" : "\(badge)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(CiraColors.error)
                    .clipShape(Capsule())
                    .offset(x: 6, y: -4)
            }
        }
    }
}

// MARK: - Convenience Initializers
extension CiraHeader {
    /// Simple header with just title
    static func simple(_ title: String, subtitle: String? = nil) -> CiraHeader {
        CiraHeader(title: title, subtitle: subtitle, style: .large)
    }
    
    /// Header with back button
    static func withBack(_ title: String, subtitle: String? = nil, onBack: @escaping () -> Void) -> CiraHeader {
        CiraHeader(
            title: title,
            subtitle: subtitle,
            style: .standard,
            leftAction: HeaderAction(icon: "arrow.left", action: onBack)
        )
    }
    
    /// Dashboard style header with profile and notifications
    static func dashboard(
        greeting: String,
        subtitle: String,
        notificationCount: Int = 0,
        onProfile: @escaping () -> Void,
        onNotifications: @escaping () -> Void
    ) -> CiraHeader {
        CiraHeader(
            title: greeting,
            subtitle: subtitle,
            style: .large,
            rightActions: [
                HeaderAction(icon: "bell", badge: notificationCount, style: .elevated, action: onNotifications),
                HeaderAction(icon: "person.circle", style: .elevated, action: onProfile)
            ]
        )
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 24) {
        CiraHeader.simple("Thư viện", subtitle: "256 khoảnh khắc")
        
        Divider()
        
        CiraHeader.withBack("Chi tiết ảnh", subtitle: "12 tháng 1, 2024") {}
        
        Divider()
        
        CiraHeader.dashboard(
            greeting: "Chào buổi sáng! 👋",
            subtitle: "Hãy ghi lại khoảnh khắc hôm nay",
            notificationCount: 5,
            onProfile: {},
            onNotifications: {}
        )
        
        Divider()
        
        CiraHeader(
            title: "Tin nhắn",
            style: .standard,
            rightActions: [
                CiraHeader.HeaderAction(icon: "square.and.pencil", action: {}),
                CiraHeader.HeaderAction(icon: "ellipsis", action: {})
            ]
        )
        
        Spacer()
    }
    .background(CiraColors.backgroundPrimary)
}
