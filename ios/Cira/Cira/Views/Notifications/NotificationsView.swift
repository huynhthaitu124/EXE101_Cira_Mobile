//
//  NotificationsView.swift
//  Cira
//
//  Memories & Reminders screen - Refactored with Cira Component Library
//

import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @Environment(\.dismiss) private var dismiss
    
    private let memories: [MemoryItem] = [
        MemoryItem(
            id: "m1",
            type: .onThisDay,
            title: "On This Day",
            subtitle: "3 years ago - Nov 5, 2022",
            description: "Family trip to Da Lat",
            photoCount: 8,
            icon: "clock",
            color: Color(hex: "#9B59B6"),
            hasPhoto: true
        ),
        MemoryItem(
            id: "m2",
            type: .birthday,
            title: "Birthday",
            subtitle: "Today - November 5",
            description: "Happy Birthday Grandma! 🎂",
            photoCount: 0,
            icon: "gift",
            color: Color(hex: "#E74C3C"),
            hasPhoto: false
        ),
        MemoryItem(
            id: "m3",
            type: .anniversary,
            title: "Anniversary",
            subtitle: "10 years wedding anniversary - Nov 8",
            description: "Mom & Dad's wedding day",
            photoCount: 15,
            icon: "heart",
            color: Color(hex: "#E91E63"),
            hasPhoto: true
        ),
        MemoryItem(
            id: "m4",
            type: .untoldStory,
            title: "Untold Stories",
            subtitle: "12 photos without captions",
            description: "Add stories to these beautiful moments",
            photoCount: 12,
            icon: "rectangle.stack",
            color: Color(hex: "#5DADE2"),
            hasPhoto: true
        ),
        MemoryItem(
            id: "m5",
            type: .weeklyReminder,
            title: "Weekly Reminder",
            subtitle: "7 days since last photo",
            description: "Share a new moment with your family!",
            photoCount: 0,
            icon: "bell",
            color: Color(hex: "#F39C12"),
            hasPhoto: false
        )
    ]
    
    var body: some View {
        ZStack {
            CiraColors.backgroundPrimary.ignoresSafeArea()
            
            // Memories List
            ScrollView(showsIndicators: false) {
                VStack(spacing: CiraSpacing.md) {
                    ForEach(memories) { memory in
                        MemoryCard(memory: memory)
                    }
                }
                .padding(CiraSpacing.lg)
            }
        }
        .navigationTitle("Memories & Reminders")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Memory Card
struct MemoryCard: View {
    let memory: MemoryItem
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: CiraSpacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(memory.color.opacity(0.15))
                        .frame(width: CiraSize.avatarMD, height: CiraSize.avatarMD)
                    
                    Image(systemName: memory.icon)
                        .font(.system(size: CiraSize.iconMD))
                        .foregroundColor(memory.color)
                }
                
                // Content
                VStack(alignment: .leading, spacing: CiraSpacing.xxs) {
                    Text(memory.title)
                        .font(CiraTypography.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(CiraColors.textPrimary)
                    
                    Text(memory.subtitle)
                        .font(CiraTypography.subheadline)
                        .foregroundColor(CiraColors.textSecondary)
                    
                    Text(memory.description)
                        .font(CiraTypography.subheadline)
                        .foregroundColor(CiraColors.textTertiary)
                    
                    if memory.photoCount > 0 {
                        HStack(spacing: CiraSpacing.xxs) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: CiraSize.iconXS))
                                .foregroundColor(CiraColors.primary)
                            
                            Text("\(memory.photoCount) \(memory.photoCount == 1 ? "photo" : "photos")")
                                .font(CiraTypography.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(CiraColors.primary)
                        }
                        .padding(.top, CiraSpacing.xxs)
                    }
                }
                
                Spacer()
                
                // Thumbnail or Arrow
                if memory.hasPhoto {
                    ZStack {
                        RoundedRectangle(cornerRadius: CiraSize.radiusMD)
                            .fill(CiraColors.backgroundTertiary)
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "photo")
                            .font(.system(size: CiraSize.iconMD))
                            .foregroundColor(CiraColors.textTertiary)
                    }
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: CiraSize.iconSM))
                        .foregroundColor(CiraColors.textTertiary)
                }
            }
            .padding(CiraSpacing.lg)
            .background(CiraColors.backgroundSecondary)
            .cornerRadius(CiraSize.radiusLG)
            .ciraShadow(CiraShadow.card)
        }
        .buttonStyle(CiraCardPressStyle())
    }
}

// MARK: - Data Models
struct MemoryItem: Identifiable {
    let id: String
    let type: MemoryType
    let title: String
    let subtitle: String
    let description: String
    let photoCount: Int
    let icon: String
    let color: Color
    let hasPhoto: Bool
}

enum MemoryType {
    case onThisDay
    case birthday
    case anniversary
    case untoldStory
    case weeklyReminder
}

#Preview {
    NotificationsView()
        .environmentObject(NavigationManager())
}
