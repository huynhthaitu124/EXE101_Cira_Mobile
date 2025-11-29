//
//  CiraMemoryCard.swift
//  Cira
//
//  Memory/moment card for notifications and memories
//  Displays photo with overlay text and action
//

import SwiftUI

struct CiraMemoryCard: View {
    let title: String
    let subtitle: String
    let date: String?
    let imageName: String?
    let gradient: LinearGradient
    let icon: String?
    let action: () -> Void
    
    init(
        title: String,
        subtitle: String,
        date: String? = nil,
        imageName: String? = nil,
        gradient: LinearGradient = CiraGradients.featurePurple,
        icon: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.date = date
        self.imageName = imageName
        self.gradient = gradient
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                // Background
                if let imageName = imageName {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: CiraSize.cardMD)
                        .clipped()
                } else {
                    gradient
                }
                
                // Overlay gradient
                LinearGradient(
                    colors: [.clear, .black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Content
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: CiraSpacing.xxs) {
                        if let icon = icon {
                            Image(systemName: icon)
                                .font(.system(size: CiraSize.iconSM))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.bottom, CiraSpacing.xxs)
                        }
                        
                        Text(title)
                            .font(CiraTypography.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text(subtitle)
                            .font(CiraTypography.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    if let date = date {
                        Text(date)
                            .font(CiraTypography.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(CiraSpacing.md)
            }
            .frame(height: CiraSize.cardMD)
            .clipShape(RoundedRectangle(cornerRadius: CiraSize.radiusLG))
            .ciraShadow(CiraShadow.card)
        }
        .buttonStyle(CiraCardPressStyle())
    }
}

// MARK: - Convenience Constructors
extension CiraMemoryCard {
    /// Memory from past years
    static func memory(
        yearsAgo: Int,
        photoCount: Int,
        action: @escaping () -> Void
    ) -> CiraMemoryCard {
        CiraMemoryCard(
            title: "\(yearsAgo) năm trước",
            subtitle: "\(photoCount) khoảnh khắc",
            date: "Xem ngay",
            gradient: CiraGradients.featurePurple,
            icon: "clock.arrow.circlepath",
            action: action
        )
    }
    
    /// Reminder card
    static func reminder(
        title: String,
        time: String,
        action: @escaping () -> Void
    ) -> CiraMemoryCard {
        CiraMemoryCard(
            title: title,
            subtitle: "Nhắc nhở",
            date: time,
            gradient: CiraGradients.featureOrange,
            icon: "bell.fill",
            action: action
        )
    }
    
    /// Achievement card
    static func achievement(
        title: String,
        description: String,
        action: @escaping () -> Void
    ) -> CiraMemoryCard {
        CiraMemoryCard(
            title: title,
            subtitle: description,
            gradient: CiraGradients.premium,
            icon: "star.fill",
            action: action
        )
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: CiraSpacing.md) {
            CiraMemoryCard.memory(yearsAgo: 2, photoCount: 24) {}
            
            CiraMemoryCard.reminder(
                title: "Chụp ảnh hôm nay",
                time: "18:00"
            ) {}
            
            CiraMemoryCard.achievement(
                title: "7 ngày liên tiếp! 🔥",
                description: "Bạn đã duy trì streak xuất sắc"
            ) {}
            
            CiraMemoryCard(
                title: "Kỷ niệm tuyệt vời",
                subtitle: "Cùng gia đình đi biển",
                date: "12/01/2024",
                gradient: CiraGradients.featureBlue,
                icon: "heart.fill"
            ) {}
        }
        .padding(CiraSpacing.lg)
    }
    .background(CiraColors.backgroundPrimary)
}
