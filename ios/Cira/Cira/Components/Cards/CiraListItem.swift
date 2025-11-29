//
//  CiraListItem.swift
//  Cira
//
//  List item component for messages, settings, etc.
//  Supports avatar, title, subtitle, and trailing accessories
//

import SwiftUI

struct CiraListItem: View {
    let title: String
    let subtitle: String?
    let leadingContent: LeadingContent?
    let trailingContent: TrailingContent?
    let isDestructive: Bool
    let action: (() -> Void)?
    
    // MARK: - Leading Content Types
    enum LeadingContent {
        case icon(String, Color)
        case avatar(String?, Color)  // Image name or nil for placeholder
        case systemImage(String)
        case custom(AnyView)
        
        @ViewBuilder
        func view() -> some View {
            switch self {
            case .icon(let name, let color):
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: CiraSize.avatarSM, height: CiraSize.avatarSM)
                    
                    Image(systemName: name)
                        .font(.system(size: CiraSize.iconSM, weight: .medium))
                        .foregroundColor(color)
                }
                
            case .avatar(let imageName, let color):
                if let imageName = imageName {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: CiraSize.avatarSM, height: CiraSize.avatarSM)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: CiraSize.avatarSM, height: CiraSize.avatarSM)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: CiraSize.iconSM))
                                .foregroundColor(color)
                        )
                }
                
            case .systemImage(let name):
                Image(systemName: name)
                    .font(.system(size: CiraSize.iconMD, weight: .medium))
                    .foregroundColor(CiraColors.textSecondary)
                    .frame(width: CiraSize.avatarSM, height: CiraSize.avatarSM)
                
            case .custom(let view):
                view
            }
        }
    }
    
    // MARK: - Trailing Content Types
    enum TrailingContent {
        case chevron
        case toggle(Binding<Bool>)
        case badge(String, Color)
        case text(String)
        case icon(String, Color)
        case custom(AnyView)
        
        @ViewBuilder
        func view() -> some View {
            switch self {
            case .chevron:
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(CiraColors.textTertiary)
                
            case .toggle(let isOn):
                Toggle("", isOn: isOn)
                    .labelsHidden()
                    .tint(CiraColors.primary)
                
            case .badge(let text, let color):
                Text(text)
                    .font(CiraTypography.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color)
                    .clipShape(Capsule())
                
            case .text(let text):
                Text(text)
                    .font(CiraTypography.subheadline)
                    .foregroundColor(CiraColors.textSecondary)
                
            case .icon(let name, let color):
                Image(systemName: name)
                    .font(.system(size: CiraSize.iconSM, weight: .medium))
                    .foregroundColor(color)
                
            case .custom(let view):
                view
            }
        }
    }
    
    init(
        title: String,
        subtitle: String? = nil,
        leadingContent: LeadingContent? = nil,
        trailingContent: TrailingContent? = nil,
        isDestructive: Bool = false,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leadingContent = leadingContent
        self.trailingContent = trailingContent
        self.isDestructive = isDestructive
        self.action = action
    }
    
    var body: some View {
        Group {
            if let action = action {
                Button(action: action) {
                    itemContent
                }
                .buttonStyle(CiraListItemPressStyle())
            } else {
                itemContent
            }
        }
    }
    
    private var itemContent: some View {
        HStack(spacing: CiraSpacing.md) {
            // Leading
            if let leadingContent = leadingContent {
                leadingContent.view()
            }
            
            // Title & Subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(CiraTypography.body)
                    .foregroundColor(isDestructive ? CiraColors.error : CiraColors.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(CiraTypography.subheadline)
                        .foregroundColor(CiraColors.textSecondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Trailing
            if let trailingContent = trailingContent {
                trailingContent.view()
            }
        }
        .padding(.horizontal, CiraSpacing.lg)
        .padding(.vertical, CiraSpacing.md)
        .background(CiraColors.backgroundSecondary)
    }
}

// MARK: - Press Style
struct CiraListItemPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? CiraColors.backgroundTertiary : Color.clear)
            .animation(CiraAnimation.quick, value: configuration.isPressed)
    }
}

// MARK: - Convenience Constructors
extension CiraListItem {
    /// Setting item with icon and chevron
    static func setting(
        title: String,
        icon: String,
        iconColor: Color = CiraColors.primary,
        action: @escaping () -> Void
    ) -> CiraListItem {
        CiraListItem(
            title: title,
            leadingContent: .icon(icon, iconColor),
            trailingContent: .chevron,
            action: action
        )
    }
    
    /// Toggle setting item
    static func toggle(
        title: String,
        subtitle: String? = nil,
        icon: String,
        iconColor: Color = CiraColors.primary,
        isOn: Binding<Bool>
    ) -> CiraListItem {
        CiraListItem(
            title: title,
            subtitle: subtitle,
            leadingContent: .icon(icon, iconColor),
            trailingContent: .toggle(isOn)
        )
    }
    
    /// Message/conversation item
    static func conversation(
        name: String,
        lastMessage: String,
        avatar: String? = nil,
        unreadCount: Int = 0,
        action: @escaping () -> Void
    ) -> CiraListItem {
        CiraListItem(
            title: name,
            subtitle: lastMessage,
            leadingContent: .avatar(avatar, CiraColors.primary),
            trailingContent: unreadCount > 0 ? .badge("\(unreadCount)", CiraColors.primary) : nil,
            action: action
        )
    }
    
    /// Destructive action item
    static func destructive(
        title: String,
        icon: String,
        action: @escaping () -> Void
    ) -> CiraListItem {
        CiraListItem(
            title: title,
            leadingContent: .icon(icon, CiraColors.error),
            trailingContent: .chevron,
            isDestructive: true,
            action: action
        )
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 0) {
        CiraListItem.setting(title: "Thông báo", icon: "bell.fill") {}
        
        Divider().padding(.leading, 72)
        
        CiraListItem.setting(title: "Bảo mật", icon: "lock.fill", iconColor: .green) {}
        
        Divider().padding(.leading, 72)
        
        CiraListItem.toggle(
            title: "Chế độ tối",
            subtitle: "Tự động theo hệ thống",
            icon: "moon.fill",
            iconColor: .purple,
            isOn: .constant(true)
        )
        
        Divider()
        
        CiraListItem.conversation(
            name: "Gia đình",
            lastMessage: "Mẹ: Hôm nay đi ăn tối nhé!",
            unreadCount: 3
        ) {}
        
        Divider()
        
        CiraListItem.destructive(title: "Đăng xuất", icon: "arrow.right.square") {}
    }
    .background(CiraColors.backgroundPrimary)
}
