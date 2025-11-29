//
//  GalleryView.swift
//  CiraSwift
//
//  Gallery view with story chapters (matching GalleryScreen.tsx)
//

import SwiftUI

struct GalleryView: View {
    @EnvironmentObject var viewModel: GalleryViewModel
    @EnvironmentObject var navigationManager: NavigationManager
    @Environment(\.dismiss) private var dismiss
    @State private var activeTab: Tab = .my
    @State private var selectedChapter: StoryChapter?
    
    enum Tab {
        case my, family
    }
    
    var body: some View {
        ZStack {
            if let selected = selectedChapter {
                // Chapter Detail View
                ChapterDetailView(
                    chapter: selected,
                    onDismiss: { selectedChapter = nil },
                    onToggleFavorite: {
                        viewModel.toggleFavorite(chapterId: selected.id)
                        // Update selected chapter with new favorite state
                        if let updated = (viewModel.myChapters + viewModel.familyChapters).first(where: { $0.id == selected.id }) {
                            selectedChapter = updated
                        }
                    }
                )
            } else {
                // Chapters List View
                ChaptersListView(
                    activeTab: $activeTab,
                    chapters: viewModel.chapters(for: activeTab),
                    onChapterTap: { chapter in
                        selectedChapter = chapter
                    },
                    onToggleFavorite: { id in
                        viewModel.toggleFavorite(chapterId: id)
                    },
                    onCreateChapter: {
                        // TODO: Show create chapter modal
                    },
                    onBack: { dismiss() }
                )
            }
        }
        .navigationTitle("Story Chapters")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if selectedChapter == nil {
                    Button {} label: {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 20))
                            .foregroundColor(.brandBlue)
                    }
                }
            }
        }
    }
}

// MARK: - Chapters List View
struct ChaptersListView: View {
    @Binding var activeTab: GalleryView.Tab
    let chapters: [StoryChapter]
    let onChapterTap: (StoryChapter) -> Void
    let onToggleFavorite: (UUID) -> Void
    let onCreateChapter: () -> Void
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab Navigation
            HStack(spacing: 0) {
                HStack(spacing: 2) {
                    TabButton(
                        title: "My Chapters",
                        isSelected: activeTab == .my,
                        action: { activeTab = .my }
                    )
                    
                    TabButton(
                        title: "Family Chapters",
                        isSelected: activeTab == .family,
                        action: { activeTab = .family }
                    )
                }
                .padding(2)
                .background(Color(hex: "#F5F5F5"))
                .cornerRadius(12)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            // Chapters Grid
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    ForEach(chapters) { chapter in
                        ChapterCard(
                            chapter: chapter,
                            onTap: { onChapterTap(chapter) },
                            onToggleFavorite: { onToggleFavorite(chapter.id) }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
                .padding(.bottom, 100)
            }
        }
        .background(Color.white)
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? .brandBlue : Color(hex: "#95A5A6"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isSelected ? Color.white : Color.clear)
                .cornerRadius(10)
        }
    }
}

// MARK: - Chapter Card
struct ChapterCard: View {
    let chapter: StoryChapter
    let onTap: () -> Void
    let onToggleFavorite: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Cover Image
                ZStack(alignment: .topLeading) {
                    // Image or placeholder
                    if let coverURL = chapter.coverImageURL, let url = URL(string: coverURL) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color(hex: chapter.coverColor))
                        }
                        .frame(height: 140)
                        .clipped()
                    } else {
                        Rectangle()
                            .fill(Color(hex: chapter.coverColor))
                            .frame(height: 140)
                            .overlay(
                                Image(systemName: "photo.stack")
                                    .font(.system(size: 48))
                                    .foregroundColor(.white.opacity(0.5))
                            )
                    }
                    
                    // Gradient overlay
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.6)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    .frame(height: 100)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    
                    // Date badge
                    Text(formatDate(chapter.createdAt))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(12)
                        .padding([.top, .leading], 12)
                    
                    // Favorite button
                    Button(action: {
                        onToggleFavorite()
                    }) {
                        Image(systemName: chapter.isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 18))
                            .foregroundColor(chapter.isFavorite ? Color(hex: "#E74C3C") : .white)
                            .frame(width: 36, height: 36)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding([.top, .trailing], 12)
                }
                .frame(height: 140)
                
                // Chapter Info
                VStack(spacing: 12) {
                    VStack(spacing: 6) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(chapter.title)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Color(hex: "#2C3E50"))
                                    .multilineTextAlignment(.leading)
                                
                                // Author badge for family chapters
                                if let author = chapter.author, let initial = chapter.authorInitial {
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(Color.brandBlue)
                                            .frame(width: 20, height: 20)
                                            .overlay(
                                                Text(initial)
                                                    .font(.system(size: 10, weight: .bold))
                                                    .foregroundColor(.white)
                                            )
                                        
                                        Text("by \(author)")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(Color(hex: "#7F8C8D"))
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 6) {
                                Image(systemName: "photo.stack")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "#95A5A6"))
                                
                                Text("\(chapter.photoCount)")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(hex: "#95A5A6"))
                            }
                        }
                        
                        Text(chapter.description)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#7F8C8D"))
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // View button
                    HStack(spacing: 8) {
                        Image(systemName: "book")
                            .font(.system(size: 18))
                        Text("View Chapter")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.brandBlue)
                    .cornerRadius(12)
                }
                .padding(16)
            }
            .background(Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(hex: "#E8E8E8"), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    GalleryView()
        .environmentObject(GalleryViewModel())
}
