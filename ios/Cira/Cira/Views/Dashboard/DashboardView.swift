//
//  DashboardView.swift
//  Cira
//
//  Main dashboard screen - Refactored with Cira Component Library
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var galleryViewModel: GalleryViewModel
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var currentProgress = 7
    @State private var dragOffset: CGFloat = 0
    let maxProgress = 15
    
    private let milestones: [MilestoneData] = [
        MilestoneData(value: 3, icon: "star.fill", color: Color(hex: "#F39C12"), label: "3"),
        MilestoneData(value: 7, icon: "trophy.fill", color: Color(hex: "#E74C3C"), label: "7"),
        MilestoneData(value: 12, icon: "medal.fill", color: Color(hex: "#9B59B6"), label: "12"),
        MilestoneData(value: 15, icon: "rosette", color: Color(hex: "#E91E63"), label: "15")
    ]
    
    var body: some View {
        ZStack {
            CiraColors.backgroundPrimary.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header using CiraHeader component
                headerView
                
                // Subtitle
                subtitleView
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: CiraSpacing.lg) {
                        // Daily Photo Goal
                        dailyPhotoGoalView
                        
                        // Feature Cards Grid using CiraFeatureGrid
                        featureCardsSection
                    }
                    .padding(.bottom, CiraSpacing.xxl)
                }
            }
            .offset(x: dragOffset)
            
            // Swipe indicator (shows when dragging right)
            if dragOffset > 20 {
                HStack {
                    VStack {
                        Image(systemName: "calendar")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(CiraColors.primary)
                        Text("Calendar")
                            .font(CiraTypography.caption)
                            .foregroundColor(CiraColors.textSecondary)
                    }
                    .padding(.leading, CiraSpacing.lg)
                    .opacity(min(1.0, Double(abs(dragOffset)) / 100.0))
                    Spacer()
                }
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    // Only allow right swipe (positive translation)
                    if value.translation.width > 0 {
                        dragOffset = value.translation.width * 0.3
                    }
                }
                .onEnded { value in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        dragOffset = 0
                    }
                    
                    // If swiped right more than 80 points, navigate to Calendar
                    if value.translation.width > 80 {
                        navigationManager.navigate(to: .calendar)
                    }
                }
        )
        .navigationBarHidden(true)
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            CiraIconButton(
                icon: "person.circle",
                style: .elevated,
                size: .large,
                iconColor: CiraColors.textPrimary
            ) {
                navigationManager.navigate(to: .profile)
            }
            
            Spacer()
            
            Text("Cira")
                .font(CiraTypography.title2)
                .fontWeight(.bold)
                .foregroundColor(CiraColors.textPrimary)
            
            Spacer()
            
            CiraIconButton(
                icon: "bell",
                style: .elevated,
                size: .large
            ) {
                navigationManager.navigate(to: .notifications)
            }
        }
        .padding(.horizontal, CiraSpacing.lg)
        .padding(.top, CiraSpacing.md)
        .padding(.bottom, CiraSpacing.sm)
    }
    
    // MARK: - Subtitle
    private var subtitleView: some View {
        VStack(alignment: .leading, spacing: CiraSpacing.xxs) {
            Text("Family Photo Sharing")
                .font(CiraTypography.headline)
                .foregroundColor(CiraColors.textPrimary)
            
            Text("Capture, share, and cherish moments together")
                .font(CiraTypography.subheadline)
                .foregroundColor(CiraColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, CiraSpacing.lg)
        .padding(.vertical, CiraSpacing.md)
    }
    
    // MARK: - Daily Photo Goal
    private var dailyPhotoGoalView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Goal Header
            HStack {
                HStack(spacing: CiraSpacing.sm) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: CiraSize.iconMS, weight: .medium))
                        .foregroundColor(CiraColors.success)
                    
                    Text("Daily Photo Goal")
                        .font(CiraTypography.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(CiraColors.success)
                }
                
                Spacer()
                
                Text("\(currentProgress)/\(maxProgress)")
                    .font(CiraTypography.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(CiraColors.success)
            }
            .padding(.bottom, CiraSpacing.sm)
            
            // Progress Track with Milestones
            ZStack(alignment: .leading) {
                // Background Track
                RoundedRectangle(cornerRadius: CiraSize.radiusSM)
                    .fill(CiraColors.success.opacity(0.15))
                    .frame(height: 12)
                
                // Progress Fill
                GeometryReader { geometry in
                    let progressWidth = geometry.size.width * CGFloat(currentProgress) / CGFloat(maxProgress)
                    
                    RoundedRectangle(cornerRadius: CiraSize.radiusSM)
                        .fill(CiraColors.success)
                        .frame(width: progressWidth, height: 12)
                }
                .frame(height: 12)
                
                // Milestones positioned on the track
                GeometryReader { geometry in
                    let trackWidth = geometry.size.width
                    
                    ForEach(milestones, id: \.value) { milestone in
                        let position = (CGFloat(milestone.value) / CGFloat(maxProgress)) * trackWidth
                        let isAchieved = currentProgress >= milestone.value
                        
                        VStack(spacing: CiraSpacing.sm) {
                            // Milestone Icon Circle
                            ZStack {
                                Circle()
                                    .fill(isAchieved ? milestone.color : Color.white)
                                    .frame(width: CiraSize.iconButtonSM, height: CiraSize.iconButtonSM)
                                
                                Circle()
                                    .stroke(isAchieved ? milestone.color : CiraColors.border, lineWidth: 2)
                                    .frame(width: CiraSize.iconButtonSM, height: CiraSize.iconButtonSM)
                                
                                Image(systemName: milestone.icon)
                                    .font(.system(size: CiraSize.iconSM))
                                    .foregroundColor(isAchieved ? .white : CiraColors.textTertiary)
                            }
                            .ciraShadow(CiraShadow.button)
                            
                            // Label
                            Text(milestone.label)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(isAchieved ? milestone.color : CiraColors.textTertiary)
                        }
                        .position(x: position, y: 6)
                    }
                }
                .frame(height: 12)
            }
            .frame(height: 12)
            .padding(.top, CiraSpacing.sm)
            .padding(.bottom, CiraSpacing.xl)
        }
        .padding(CiraSpacing.lg)
        .background(CiraColors.backgroundSecondary)
        .cornerRadius(CiraSize.radiusLG)
        .ciraShadow(CiraShadow.card)
        .padding(.horizontal, CiraSpacing.lg)
    }
    
    // MARK: - Feature Cards Section
    private var featureCardsSection: some View {
        CiraSection(title: "Features") {
            CiraFeatureGrid(items: [
                .init(
                    title: "Camera",
                    subtitle: "Capture moments",
                    icon: "camera.fill",
                    gradient: CiraGradients.featureBlue,
                    badge: nil
                ) { navigationManager.navigate(to: .camera) },
                .init(
                    title: "Life Chapters",
                    subtitle: "View photos",
                    icon: "photo.on.rectangle.angled",
                    gradient: CiraGradients.featurePurple,
                    badge: nil
                ) { navigationManager.navigate(to: .gallery) },
                .init(
                    title: "Story Creator",
                    subtitle: "AI storytelling",
                    icon: "book.pages.fill",
                    gradient: CiraGradients.featureOrange,
                    badge: "New"
                ) { navigationManager.navigate(to: .storyCreator) },
                .init(
                    title: "Feed",
                    subtitle: "Family updates",
                    icon: "heart.fill",
                    gradient: CiraGradients.featurePink,
                    badge: nil
                ) { navigationManager.navigate(to: .feed) }
            ])
        }
        .padding(.horizontal, CiraSpacing.lg)
    }
}

// MARK: - Data Models
struct MilestoneData {
    let value: Int
    let icon: String
    let color: Color
    let label: String
}

#Preview {
    DashboardView()
        .environmentObject(GalleryViewModel())
        .environmentObject(NavigationManager())
}
