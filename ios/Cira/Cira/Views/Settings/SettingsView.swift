//
//  SettingsView.swift
//  Cira
//
//  Settings screen - Refactored with Cira Component Library
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @Environment(\.dismiss) private var dismiss
    @State private var pushEnabled = true
    @State private var emailEnabled = false
    @State private var darkMode = false
    
    var body: some View {
        ZStack {
            CiraColors.backgroundPrimary.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: CiraSpacing.lg) {
                    // Notifications Section
                    notificationsSection
                    
                    // Appearance Section
                    appearanceSection
                    
                    // Account Section
                    accountSection
                    
                    // Logout Button
                    CiraPrimaryButton.danger("Logout", icon: "arrow.right.square") {
                        // Handle logout
                    }
                    .padding(.horizontal, CiraSpacing.lg)
                    
                    // App Version
                    Text("Version 1.0.0")
                        .font(CiraTypography.caption)
                        .foregroundColor(CiraColors.textTertiary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, CiraSpacing.md)
                }
                .padding(.top, CiraSpacing.md)
                .padding(.bottom, CiraSpacing.xxl)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Notifications Section
    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: CiraSpacing.sm) {
            Text("NOTIFICATIONS")
                .font(CiraTypography.caption)
                .fontWeight(.bold)
                .foregroundColor(CiraColors.textSecondary)
                .padding(.horizontal, CiraSpacing.lg)
            
            VStack(spacing: 0) {
                CiraListItem.toggle(
                    title: "Push Notifications",
                    icon: "bell.fill",
                    iconColor: CiraColors.primary,
                    isOn: $pushEnabled
                )
                
                Divider()
                    .padding(.leading, 72)
                
                CiraListItem.toggle(
                    title: "Email Notifications",
                    icon: "envelope.fill",
                    iconColor: CiraColors.primary,
                    isOn: $emailEnabled
                )
            }
            .background(CiraColors.backgroundSecondary)
            .cornerRadius(CiraSize.radiusMD)
            .padding(.horizontal, CiraSpacing.lg)
        }
    }
    
    // MARK: - Appearance Section
    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: CiraSpacing.sm) {
            Text("APPEARANCE")
                .font(CiraTypography.caption)
                .fontWeight(.bold)
                .foregroundColor(CiraColors.textSecondary)
                .padding(.horizontal, CiraSpacing.lg)
            
            CiraListItem.toggle(
                title: "Dark Mode",
                subtitle: "Follow system settings",
                icon: "moon.fill",
                iconColor: .purple,
                isOn: $darkMode
            )
            .background(CiraColors.backgroundSecondary)
            .cornerRadius(CiraSize.radiusMD)
            .padding(.horizontal, CiraSpacing.lg)
        }
    }
    
    // MARK: - Account Section
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: CiraSpacing.sm) {
            Text("ACCOUNT")
                .font(CiraTypography.caption)
                .fontWeight(.bold)
                .foregroundColor(CiraColors.textSecondary)
                .padding(.horizontal, CiraSpacing.lg)
            
            VStack(spacing: CiraSpacing.sm) {
                CiraListItem.setting(title: "Change Password", icon: "key.fill", iconColor: .orange) {}
                    .background(CiraColors.backgroundSecondary)
                    .cornerRadius(CiraSize.radiusMD)
                
                CiraListItem(
                    title: "Language",
                    leadingContent: .icon("globe", CiraColors.primary),
                    trailingContent: .text("English")
                ) {}
                .background(CiraColors.backgroundSecondary)
                .cornerRadius(CiraSize.radiusMD)
                
                CiraListItem.setting(title: "Privacy Policy", icon: "shield.checkered", iconColor: .green) {}
                    .background(CiraColors.backgroundSecondary)
                    .cornerRadius(CiraSize.radiusMD)
                
                CiraListItem.setting(title: "Terms of Service", icon: "doc.text.fill", iconColor: .blue) {}
                    .background(CiraColors.backgroundSecondary)
                    .cornerRadius(CiraSize.radiusMD)
            }
            .padding(.horizontal, CiraSpacing.lg)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(NavigationManager())
}
