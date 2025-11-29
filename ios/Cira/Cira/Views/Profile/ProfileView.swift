//
//  ProfileView.swift
//  CiraSwift
//
//  Profile screen (matching ProfileScreen.tsx)
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @Environment(\.dismiss) private var dismiss
    @State private var showSettings = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                
                // Profile Header
                VStack(spacing: 16) {
                    // Avatar
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.brandBlue, Color.brandPurple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.white)
                        )
                    
                    VStack(spacing: 8) {
                        Text("User Name")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "#2C3E50"))
                        
                        Text("Family Memory Keeper")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "#7F8C8D"))
                    }
                }
                
                // Stats
                HStack(spacing: 0) {
                    ProfileStat(value: "142", label: "Photos")
                    
                    Rectangle()
                        .fill(Color(hex: "#E8E8E8"))
                        .frame(width: 1, height: 40)
                    
                    ProfileStat(value: "12", label: "Chapters")
                    
                    Rectangle()
                        .fill(Color(hex: "#E8E8E8"))
                        .frame(width: 1, height: 40)
                    
                    ProfileStat(value: "48", label: "Stories")
                }
                .padding(.vertical, 20)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
                .padding(.horizontal, 20)
                
                // Menu Items
                VStack(spacing: 0) {
                    Button(action: {}) {
                        ProfileMenuItem(
                            icon: "person.circle",
                            title: "Edit Profile",
                            color: Color.brandBlue
                        )
                    }
                    
                    Divider().padding(.leading, 68)
                    
                    Button(action: {}) {
                        ProfileMenuItem(
                            icon: "lock.shield",
                            title: "Privacy & Security",
                            color: Color.brandPurple
                        )
                    }
                    
                    Divider().padding(.leading, 68)
                    
                    Button(action: { navigationManager.navigate(to: .notifications) }) {
                        ProfileMenuItem(
                            icon: "bell.badge",
                            title: "Notifications",
                            color: Color.brandTeal
                        )
                    }
                    
                    Divider().padding(.leading, 68)
                    
                    Button(action: {}) {
                        ProfileMenuItem(
                            icon: "externaldrive",
                            title: "Storage & Data",
                            color: Color.brandTeal
                        )
                    }
                    
                    Divider().padding(.leading, 68)
                    
                    Button(action: { navigationManager.navigate(to: .settings) }) {
                        ProfileMenuItem(
                            icon: "gearshape",
                            title: "Settings",
                            color: Color(hex: "#95A5A6")
                        )
                    }
                }
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
                .padding(.horizontal, 20)
                
                // Sign Out
                Button(action: {}) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 20))
                        Text("Sign Out")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(Color(hex: "#E74C3C"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
                }
                .padding(.horizontal, 20)
                
                Text("Version 1.0.0")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#95A5A6"))
                    .padding(.bottom, 40)
            }
            .padding(.top, 16)
        }
        .background(Color(hex: "#F8F9FA"))
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Profile Stat
struct ProfileStat: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(hex: "#2C3E50"))
            
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#95A5A6"))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Profile Menu Item
struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                )
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "#2C3E50"))
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#95A5A6"))
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(Color.white)
    }
}

#Preview {
    ProfileView()
        .environmentObject(NavigationManager())
}
