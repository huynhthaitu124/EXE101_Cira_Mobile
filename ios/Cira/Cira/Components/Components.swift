//
//  Components.swift
//  Cira
//
//  Central export file for all Cira UI components
//  Import this file to access all design system components
//

// MARK: - Design System Foundation
// DesignTokens.swift - CiraScreen, CiraSpacing, CiraSize, CiraTypography, CiraShadow, CiraAnimation
// CiraTheme.swift - CiraColors, CiraGradients, Button/Card Styles

// MARK: - Buttons
// CiraIconButton - Circular icon buttons (back, close, notifications, profile, settings, add)
// CiraPrimaryButton - Primary action buttons (primary, secondary, ghost, danger)
// CiraGradientButton - Gradient buttons (premium, capture, share, ai)

// MARK: - Navigation
// CiraHeader - Unified header (large, standard, compact)

// MARK: - Cards
// CiraFeatureCard - Feature cards with gradient (camera, gallery, family, calendar, aiMagic)
// CiraStatCard - Stat/metric cards (photos, streak, members, storage)
// CiraMemoryCard - Memory/moment cards (memory, reminder, achievement)
// CiraListItem - List items for messages/settings (setting, toggle, conversation, destructive)

// MARK: - Layout
// CiraAdaptiveGrid - Responsive grid layout
// CiraPhotoGrid - Photo grid with aspect ratio
// CiraPhotoGridItem - Individual photo cell
// CiraGridLayout - Grid column presets (twoColumn, threeColumn, fourColumn, adaptive)
// CiraFeatureGrid - 2x2 feature grid
// CiraStatsGrid - Stats display grid
// CiraSection - Section with header and "See All"
// CiraHorizontalSection - Horizontal scroll section
// CiraCardSection - Section with card background

// MARK: - Usage Examples

/*
 
 // Icon Buttons
 CiraIconButton.back { }
 CiraIconButton.notifications { }
 CiraIconButton(icon: "heart.fill", style: .tinted(CiraColors.error), size: .medium) { }
 
 // Primary Buttons
 CiraPrimaryButton.primary("Tiếp tục") { }
 CiraPrimaryButton("Chọn ảnh", icon: "photo", variant: .secondary) { }
 
 // Gradient Buttons
 CiraGradientButton.premium { }
 CiraGradientButton.capture { }
 
 // Headers
 CiraHeader.simple("Thư viện", subtitle: "256 ảnh")
 CiraHeader.withBack("Chi tiết") { }
 CiraHeader.dashboard(greeting: "Chào!", subtitle: "Hôm nay", notificationCount: 3, onProfile: {}, onNotifications: {})
 
 // Feature Cards
 CiraFeatureCard.camera { }
 CiraFeatureCard.gallery(count: 256) { }
 
 // Stat Cards
 CiraStatCard.photos(256)
 CiraStatCard.streak(7)
 
 // Memory Cards
 CiraMemoryCard.memory(yearsAgo: 2, photoCount: 24) { }
 CiraMemoryCard.reminder(title: "Chụp ảnh", time: "18:00") { }
 
 // List Items
 CiraListItem.setting(title: "Thông báo", icon: "bell.fill") { }
 CiraListItem.toggle(title: "Chế độ tối", icon: "moon.fill", isOn: $isDark)
 CiraListItem.conversation(name: "Gia đình", lastMessage: "Hello", unreadCount: 3) { }
 
 // Sections
 CiraSection(title: "Tính năng", seeAllAction: { }) {
     CiraFeatureGrid(items: [...])
 }
 
 CiraHorizontalSection(title: "Kỷ niệm") {
     ForEach(memories) { memory in
         CiraMemoryCard(...)
     }
 }
 
 // Grids
 LazyVGrid(columns: CiraGridLayout.twoColumn) { ... }
 LazyVGrid(columns: CiraGridLayout.threeColumn) { ... }
 
 // Spacing & Sizing
 .padding(CiraSpacing.lg)
 .frame(width: CiraSize.avatarMD)
 .font(CiraTypography.headline)
 .ciraShadow(CiraShadow.card)
 
 // Colors & Gradients
 .foregroundColor(CiraColors.primary)
 .background(CiraGradients.featureBlue)
 
 */
