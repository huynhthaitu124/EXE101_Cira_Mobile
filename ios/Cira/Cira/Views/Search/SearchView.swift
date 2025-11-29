//
//  SearchView.swift
//  Cira
//
//  Search screen - Refactored with Cira Component Library
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    private let recentSearches = ["Family dinner", "Grandma birthday", "Park photos", "Tết 2025"]
    private let photos = Array(1...24)
    
    var body: some View {
        ZStack {
            CiraColors.backgroundPrimary.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Search Bar Header
                searchBarView
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Recent Searches (only show when not searching)
                        if searchText.isEmpty {
                            recentSearchesView
                        }
                        
                        // Photo Grid
                        photoGrid
                    }
                }
            }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Search Bar
    private var searchBarView: some View {
        HStack(spacing: CiraSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: CiraSize.iconMS))
                .foregroundColor(CiraColors.textTertiary)
            
            TextField("Search photos, people, places...", text: $searchText)
                .font(CiraTypography.body)
                .foregroundColor(CiraColors.textPrimary)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: CiraSize.iconSM))
                        .foregroundColor(CiraColors.textTertiary)
                }
            }
        }
        .padding(.horizontal, CiraSpacing.md)
        .padding(.vertical, CiraSpacing.md)
        .background(CiraColors.backgroundSecondary)
        .cornerRadius(CiraSize.radiusMD)
        .padding(.horizontal, CiraSpacing.lg)
        .padding(.vertical, CiraSpacing.sm)
    }
    
    // MARK: - Recent Searches
    private var recentSearchesView: some View {
        CiraSection(title: "Recent", seeAllAction: {}) {
            VStack(spacing: 0) {
                ForEach(recentSearches, id: \.self) { search in
                    HStack {
                        HStack(spacing: CiraSpacing.sm) {
                            Image(systemName: "clock")
                                .font(.system(size: CiraSize.iconMS))
                                .foregroundColor(CiraColors.textTertiary)
                            
                            Text(search)
                                .font(CiraTypography.body)
                                .foregroundColor(CiraColors.textPrimary)
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "xmark")
                                .font(.system(size: CiraSize.iconSM))
                                .foregroundColor(CiraColors.textTertiary)
                        }
                    }
                    .padding(.vertical, CiraSpacing.md)
                }
            }
        }
        .padding(.horizontal, CiraSpacing.lg)
        .padding(.vertical, CiraSpacing.md)
    }
    
    // MARK: - Photo Grid
    private var photoGrid: some View {
        LazyVGrid(columns: CiraGridLayout.threeColumn, spacing: CiraSpacing.xxs) {
            ForEach(photos, id: \.self) { _ in
                CiraPhotoGridItem(aspectRatio: 1.0, cornerRadius: 0)
            }
        }
        .padding(.horizontal, CiraSpacing.xxs)
        .padding(.vertical, CiraSpacing.sm)
    }
}

#Preview {
    SearchView()
        .environmentObject(NavigationManager())
}
