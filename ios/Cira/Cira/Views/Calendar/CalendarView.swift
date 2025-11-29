//
//  CalendarView.swift
//  Cira
//
//  Calendar screen - Refactored with Cira Component Library
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @Environment(\.dismiss) private var dismiss
    @State private var subscriptionModalVisible = false
    
    private let monthsData: [MonthCalendarData]
    private let streak: Int
    private let totalPhotos: Int
    
    private let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    private let monthNames = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
    
    // Mock user data
    private let userData = CalendarUserData(
        name: "John Doe",
        username: "@johndoe",
        avatar: "https://picsum.photos/200/200?random=user",
        hasSubscription: false
    )
    
    init() {
        let data = CalendarView.generateMockData()
        self.monthsData = data
        self.streak = CalendarView.calculateStreak(monthsData: data)
        self.totalPhotos = CalendarView.calculateTotalPhotos(monthsData: data)
    }
    
    var body: some View {
        ZStack {
            CiraColors.backgroundPrimary.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Calendar ScrollView
                ScrollView(showsIndicators: false) {
                    VStack(spacing: CiraSpacing.xl) {
                        // User Info Card
                        userInfoCard
                        
                        ForEach(monthsData) { monthData in
                            monthCalendarView(monthData: monthData)
                        }
                    }
                    .padding(.horizontal, CiraSpacing.lg)
                    .padding(.top, CiraSpacing.md)
                    .padding(.bottom, 100)
                }
                
                // Stats Cards - Fixed at bottom
                statsView
            }
        }
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { subscriptionModalVisible = true } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                        Text("Gold")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#F39C12"), Color(hex: "#E67E22")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
            }
        }
        .sheet(isPresented: $subscriptionModalVisible) {
            SubscriptionModalView(isPresented: $subscriptionModalVisible)
        }
    }
    
    // MARK: - User Info Card
    private var userInfoCard: some View {
        HStack(spacing: CiraSpacing.md) {
            AsyncImage(url: URL(string: userData.avatar)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: CiraSize.avatarMD, height: CiraSize.avatarMD)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(CiraColors.warning, lineWidth: 2)
                        )
                default:
                    Circle()
                        .fill(CiraColors.backgroundTertiary)
                        .frame(width: CiraSize.avatarMD, height: CiraSize.avatarMD)
                }
            }
            
            VStack(alignment: .leading, spacing: CiraSpacing.xxs) {
                Text(userData.name)
                    .font(CiraTypography.headline)
                    .foregroundColor(CiraColors.textPrimary)
                
                Text(userData.username)
                    .font(CiraTypography.subheadline)
                    .foregroundColor(CiraColors.textSecondary)
            }
            
            Spacer()
        }
        .padding(CiraSpacing.md)
        .background(CiraColors.backgroundSecondary)
        .cornerRadius(CiraSize.radiusMD)
    }
    
    // MARK: - Month Calendar View
    private func monthCalendarView(monthData: MonthCalendarData) -> some View {
        VStack(alignment: .leading, spacing: CiraSpacing.md) {
            // Month Title
            Text("\(monthNames[monthData.month]) \(monthData.year)")
                .font(CiraTypography.title3)
                .fontWeight(.bold)
                .foregroundColor(CiraColors.textPrimary)
                .padding(.leading, CiraSpacing.xxs)
            
            // Weekday Headers
            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(CiraColors.textTertiary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, CiraSpacing.xs)
            
            // Calendar Grid
            let weeks = generateCalendarWeeks(monthData: monthData)
            VStack(spacing: 4) {
                ForEach(0..<weeks.count, id: \.self) { weekIndex in
                    HStack(spacing: 4) {
                        ForEach(0..<7, id: \.self) { dayIndex in
                            let day = weeks[weekIndex][dayIndex]
                            dayCellView(day: day)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Day Cell View
    private func dayCellView(day: PhotoDayData?) -> some View {
        Group {
            if let day = day {
                let isToday = checkIsToday(dateString: day.date)
                
                Button(action: {}) {
                    VStack(spacing: 4) {
                        // Day Number
                        Text("\(day.dayNumber)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(isToday ? Color(hex: "#5DADE2") : Color(hex: "#34495E"))
                        
                        // Photo Thumbnail or Placeholder
                        if day.hasPhotos && !day.photos.isEmpty {
                            ZStack(alignment: .bottomTrailing) {
                                AsyncImage(url: URL(string: day.photos[0])) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .clipped()
                                    default:
                                        Rectangle()
                                            .fill(Color(hex: "#F8F9FA"))
                                    }
                                }
                                .cornerRadius(8)
                                
                                if day.photos.count > 1 {
                                    Text("+\(day.photos.count - 1)")
                                        .font(.system(size: 7, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 3)
                                        .padding(.vertical, 1)
                                        .background(Color.black.opacity(0.75))
                                        .cornerRadius(6)
                                        .offset(x: -1, y: -1)
                                }
                            }
                        } else {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color(hex: "#DFE4E8"), style: StrokeStyle(lineWidth: 1.5, dash: [3]))
                                )
                                .padding(4)
                        }
                    }
                    .padding(5)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(0.7, contentMode: .fit)
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isToday ? Color(hex: "#5DADE2") : Color(hex: "#ECECEC"), lineWidth: isToday ? 2 : 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                // Empty cell
                Color.clear
                    .frame(maxWidth: .infinity)
                    .aspectRatio(0.7, contentMode: .fit)
            }
        }
    }
    
    // MARK: - Stats View
    private var statsView: some View {
        HStack(spacing: CiraSpacing.md) {
            // Streak Card
            HStack(spacing: CiraSpacing.md) {
                Image(systemName: "flame.fill")
                    .font(.system(size: CiraSize.iconLG))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: CiraSpacing.xxs) {
                    Text("\(streak)")
                        .font(CiraTypography.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Day Streak")
                        .font(CiraTypography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
            }
            .padding(CiraSpacing.md)
            .background(CiraGradients.statOrange)
            .cornerRadius(CiraSize.radiusLG)
            .ciraShadow(CiraShadow.card)
            
            // Total Photos Card
            HStack(spacing: CiraSpacing.md) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: CiraSize.iconLG))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: CiraSpacing.xxs) {
                    Text("\(totalPhotos)")
                        .font(CiraTypography.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Photos")
                        .font(CiraTypography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
            }
            .padding(CiraSpacing.md)
            .background(CiraGradients.statBlue)
            .cornerRadius(CiraSize.radiusLG)
            .ciraShadow(CiraShadow.card)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .padding(.bottom, 16)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.08), radius: 8, y: -2)
    }
    
    // MARK: - Helper Functions
    private func generateCalendarWeeks(monthData: MonthCalendarData) -> [[PhotoDayData?]] {
        let firstDayOfWeek = Calendar.current.component(.weekday, from: Date(year: monthData.year, month: monthData.month + 1, day: 1) ?? Date()) - 1
        
        var calendarDays: [PhotoDayData?] = Array(repeating: nil, count: firstDayOfWeek)
        calendarDays.append(contentsOf: monthData.days)
        
        let remainingCells = 7 - (calendarDays.count % 7)
        if remainingCells < 7 {
            calendarDays.append(contentsOf: Array(repeating: nil, count: remainingCells))
        }
        
        var weeks: [[PhotoDayData?]] = []
        for i in stride(from: 0, to: calendarDays.count, by: 7) {
            weeks.append(Array(calendarDays[i..<min(i + 7, calendarDays.count)]))
        }
        
        return weeks
    }
    
    private func checkIsToday(dateString: String) -> Bool {
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return dateString == formatter.string(from: today)
    }
    
    // MARK: - Static Data Generators
    static func generateMockData() -> [MonthCalendarData] {
        var months: [MonthCalendarData] = []
        let currentDate = Date()
        let calendar = Calendar.current
        
        let mockPhotos = (1...10).map { "https://picsum.photos/200/200?random=\($0)" }
        
        for i in (0..<6).reversed() {
            guard let targetDate = calendar.date(byAdding: .month, value: -i, to: currentDate) else { continue }
            let year = calendar.component(.year, from: targetDate)
            let month = calendar.component(.month, from: targetDate) - 1
            
            let daysInMonth = calendar.range(of: .day, in: .month, for: targetDate)?.count ?? 30
            var days: [PhotoDayData] = []
            
            for day in 1...daysInMonth {
                let dateString = String(format: "%04d-%02d-%02d", year, month + 1, day)
                let hasPhotos = Double.random(in: 0...1) > 0.3
                let photoCount = hasPhotos ? Int.random(in: 1...3) : 0
                let photos = hasPhotos ? Array(mockPhotos.shuffled().prefix(photoCount)) : []
                
                days.append(PhotoDayData(
                    date: dateString,
                    dayNumber: day,
                    photos: photos,
                    hasPhotos: hasPhotos
                ))
            }
            
            months.append(MonthCalendarData(year: year, month: month, days: days))
        }
        
        return months
    }
    
    static func calculateStreak(monthsData: [MonthCalendarData]) -> Int {
        Int.random(in: 3...15)
    }
    
    static func calculateTotalPhotos(monthsData: [MonthCalendarData]) -> Int {
        monthsData.reduce(0) { total, month in
            total + month.days.reduce(0) { $0 + $1.photos.count }
        }
    }
}

// MARK: - Data Models
struct MonthCalendarData: Identifiable {
    let id = UUID()
    let year: Int
    let month: Int
    let days: [PhotoDayData]
}

struct PhotoDayData: Identifiable {
    let id = UUID()
    let date: String
    let dayNumber: Int
    let photos: [String]
    let hasPhotos: Bool
}

struct CalendarUserData {
    let name: String
    let username: String
    let avatar: String
    let hasSubscription: Bool
}

// MARK: - Subscription Plan Model
struct SubscriptionPlan: Identifiable {
    let id: String
    let name: String
    let targetUsers: String
    let monthlyPrice: Int
    let yearlyPrice: Int
    let storage: String
    let aiVoice: String
    let sharing: String
    let duration: String
    let colors: [Color]
    let icon: String
    let isPopular: Bool
    
    static let plans: [SubscriptionPlan] = [
        SubscriptionPlan(
            id: "free",
            name: "Free / Starter",
            targetUsers: "New users, gifting first memory",
            monthlyPrice: 0,
            yearlyPrice: 0,
            storage: "20 photos / 1 story",
            aiVoice: "1 auto-generated voice story",
            sharing: "3 story chapters",
            duration: "30 days (temporary)",
            colors: [Color(hex: "#95A5A6"), Color(hex: "#7F8C8D")],
            icon: "gift",
            isPopular: false
        ),
        SubscriptionPlan(
            id: "personal",
            name: "Personal",
            targetUsers: "Individuals (memory journaling)",
            monthlyPrice: 79000,
            yearlyPrice: 899000,
            storage: "200 photos / 10 stories",
            aiVoice: "Warm family storytelling AI",
            sharing: "Shared family feed",
            duration: "Permanent",
            colors: [Color(hex: "#3498DB"), Color(hex: "#2980B9")],
            icon: "person",
            isPopular: false
        ),
        SubscriptionPlan(
            id: "family",
            name: "Family",
            targetUsers: "Families (2–5 members)",
            monthlyPrice: 179000,
            yearlyPrice: 2040000,
            storage: "1,000 photos",
            aiVoice: "Personalized voices",
            sharing: "Shared family feed",
            duration: "Permanent",
            colors: [Color(hex: "#F39C12"), Color(hex: "#E67E22")],
            icon: "person.2",
            isPopular: true
        ),
        SubscriptionPlan(
            id: "premium",
            name: "Premium Family",
            targetUsers: "Large or extended families",
            monthlyPrice: 499000,
            yearlyPrice: 5599000,
            storage: "Unlimited",
            aiVoice: "Personalized voices",
            sharing: "Shared family feed",
            duration: "Lifetime",
            colors: [Color(hex: "#9B59B6"), Color(hex: "#8E44AD")],
            icon: "star",
            isPopular: false
        )
    ]
    
    var formattedMonthlyPrice: String {
        if monthlyPrice == 0 { return "Free" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return "₫\(formatter.string(from: NSNumber(value: monthlyPrice)) ?? "\(monthlyPrice)")"
    }
    
    var formattedYearlyPrice: String {
        if yearlyPrice == 0 { return "Free" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return "₫\(formatter.string(from: NSNumber(value: yearlyPrice)) ?? "\(yearlyPrice)")"
    }
    
    var yearlySavingsPercent: Int {
        guard monthlyPrice > 0 else { return 0 }
        let yearlyFromMonthly = monthlyPrice * 12
        return Int((1.0 - Double(yearlyPrice) / Double(yearlyFromMonthly)) * 100)
    }
}

// MARK: - Subscription Modal View
struct SubscriptionModalView: View {
    @Binding var isPresented: Bool
    @State private var selectedPlanId: String?
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Plans
                    ForEach(SubscriptionPlan.plans) { plan in
                        PlanCard(plan: plan, isSelected: selectedPlanId == plan.id) {
                            selectedPlanId = plan.id
                        }
                    }
                    
                    // Bottom Info
                    bottomInfoSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .background(Color(hex: "#F8F9FA"))
            .navigationTitle("Cira Gold")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color(hex: "#BDC3C7"))
                    }
                }
            }
        }
    }
    
    private var headerSection: some View {
        HStack(spacing: 12) {
            // Gold Star Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#F39C12"), Color(hex: "#E67E22")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                
                Image(systemName: "star.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Choose your perfect plan")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "#2C3E50"))
                
                Text("Unlock all premium features")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "#7F8C8D"))
            }
            
            Spacer()
        }
        .padding(.top, 16)
    }
    
    private var bottomInfoSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "shield.checkmark.fill")
                .font(.system(size: 24))
                .foregroundColor(Color(hex: "#27AE60"))
            
            Text("All plans include secure cloud storage and 24/7 support")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(hex: "#27AE60"))
                .lineSpacing(2)
        }
        .padding(16)
        .background(Color(hex: "#E8F8F5"))
        .cornerRadius(16)
    }
}

// MARK: - Plan Card
struct PlanCard: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Popular Badge
            if plan.isPopular {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                    Text("MOST POPULAR")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(0.5)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#F39C12"), Color(hex: "#E67E22")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .offset(y: 8)
                .zIndex(1)
            }
            
            Button(action: onSelect) {
                VStack(spacing: 0) {
                    // Plan Header
                    HStack(spacing: 16) {
                        Image(systemName: plan.icon)
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(plan.name)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(plan.targetUsers)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white.opacity(0.95))
                        }
                        
                        Spacer()
                    }
                    .padding(20)
                    .background(
                        LinearGradient(
                            colors: plan.colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    
                    // Pricing Section
                    VStack(spacing: 12) {
                        HStack {
                            Text("Monthly")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(hex: "#7F8C8D"))
                            
                            Spacer()
                            
                            Text(plan.formattedMonthlyPrice)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color(hex: "#2C3E50"))
                        }
                        
                        if plan.yearlyPrice > 0 {
                            HStack {
                                Text("Yearly")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color(hex: "#7F8C8D"))
                                
                                Spacer()
                                
                                HStack(spacing: 8) {
                                    Text(plan.formattedYearlyPrice)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(Color(hex: "#2C3E50"))
                                    
                                    Text("Save \(plan.yearlySavingsPercent)%")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color(hex: "#27AE60"))
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(hex: "#F8F9FA"))
                    
                    // Features Section
                    VStack(spacing: 16) {
                        FeatureRow(icon: "folder", iconColor: Color(hex: "#3498DB"), label: "Storage", value: plan.storage)
                        FeatureRow(icon: "mic", iconColor: Color(hex: "#9B59B6"), label: "AI Voice", value: plan.aiVoice)
                        FeatureRow(icon: "arrowshape.turn.up.right", iconColor: Color(hex: "#E74C3C"), label: "Sharing", value: plan.sharing)
                        FeatureRow(icon: "clock", iconColor: Color(hex: "#F39C12"), label: "Duration", value: plan.duration)
                    }
                    .padding(20)
                    
                    // Select Button
                    HStack(spacing: 8) {
                        Text(plan.id == "free" ? "Start Free" : "Select Plan")
                            .font(.system(size: 16, weight: .bold))
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: plan.colors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .background(Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(plan.isPopular ? Color(hex: "#F39C12") : Color(hex: "#E8E8E8"), lineWidth: 2)
                )
                .shadow(color: plan.isPopular ? Color(hex: "#F39C12").opacity(0.2) : Color.black.opacity(0.1), radius: 8, y: 4)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.top, plan.isPopular ? 8 : 0)
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(iconColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "#7F8C8D"))
                
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "#2C3E50"))
            }
            
            Spacer()
        }
    }
}

// MARK: - Date Extension
extension Date {
    init?(year: Int, month: Int, day: Int) {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        guard let date = Calendar.current.date(from: components) else { return nil }
        self = date
    }
}

#Preview {
    CalendarView()
        .environmentObject(NavigationManager())
}
