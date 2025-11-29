//
//  ChapterDetailView.swift
//  CiraSwift
//
//  Detail view for a story chapter with photos carousel
//

import SwiftUI

struct ChapterDetailView: View {
    let chapter: StoryChapter
    let onDismiss: () -> Void
    let onToggleFavorite: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "#2C3E50"))
                }
                
                Spacer()
                
                Text("Story Chapter")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "#2C3E50"))
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: onToggleFavorite) {
                        Image(systemName: chapter.isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 24))
                            .foregroundColor(chapter.isFavorite ? Color(hex: "#E74C3C") : Color(hex: "#2C3E50"))
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "#2C3E50"))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .overlay(
                Rectangle()
                    .fill(Color(hex: "#F0F0F0"))
                    .frame(height: 1),
                alignment: .bottom
            )
            
            // Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Chapter Header
                    VStack(spacing: 8) {
                        HStack(alignment: .top, spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(chapter.title)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color(hex: "#2C3E50"))
                                
                                // Author info for family chapters
                                if let author = chapter.author, let initial = chapter.authorInitial {
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(Color.brandBlue)
                                            .frame(width: 24, height: 24)
                                            .overlay(
                                                Text(initial)
                                                    .font(.system(size: 11, weight: .bold))
                                                    .foregroundColor(.white)
                                            )
                                        
                                        Text("by \(author)")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(Color(hex: "#2C3E50"))
                                    }
                                }
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(hex: "#95A5A6"))
                                    
                                    Text(formatDate(chapter.createdAt))
                                        .font(.system(size: 13))
                                        .foregroundColor(Color(hex: "#95A5A6"))
                                    
                                    Text("•")
                                        .foregroundColor(Color(hex: "#95A5A6"))
                                    
                                    Text("\(chapter.photoCount) photos")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color(hex: "#95A5A6"))
                                }
                            }
                            
                            Spacer()
                            
                            // Play Story button
                            Button(action: {}) {
                                HStack(spacing: 8) {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 16))
                                    Text("Play Story")
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.brandBlue)
                                .cornerRadius(20)
                            }
                        }
                    }
                    
                    // Description
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 18))
                            .foregroundColor(.brandBlue)
                        
                        Text(chapter.description)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#2C3E50"))
                            .lineSpacing(8)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color(hex: "#F8F9FA"))
                    .cornerRadius(16)
                    
                    // Photos Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Photos")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "#2C3E50"))
                        
                        // Photos list
                        ForEach(Array(chapter.photos.enumerated()), id: \.offset) { index, photo in
                            PhotoDetailCard(photo: photo, index: index)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
                .padding(.bottom, 100)
            }
        }
        .background(Color.white)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Photo Detail Card
struct PhotoDetailCard: View {
    let photo: Photo
    let index: Int
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 12) {
                // Photo
                if let imageURL = photo.imageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color(hex: photo.dominantColor))
                            .overlay(
                                VStack(spacing: 8) {
                                    Image(systemName: "photo")
                                        .font(.system(size: 48))
                                        .foregroundColor(.white.opacity(0.5))
                                    Text("Photo \(index + 1)")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            )
                    }
                    .frame(height: geometry.size.width * 0.75)
                    .clipped()
                    .cornerRadius(16)
                } else {
                    Rectangle()
                        .fill(Color(hex: photo.dominantColor))
                        .frame(height: geometry.size.width * 0.75)
                        .cornerRadius(16)
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "photo")
                                    .font(.system(size: 48))
                                    .foregroundColor(.white.opacity(0.5))
                                Text("Photo \(index + 1)")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        )
                }
            
            // Photo info
            VStack(spacing: 8) {
                // Timestamp
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#95A5A6"))
                    
                    Text(formatTimestamp(photo.timestamp))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "#95A5A6"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Caption
                if !photo.caption.isEmpty {
                    Text(photo.caption)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#2C3E50"))
                        .lineSpacing(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .background(Color(hex: "#F8F9FA"))
                        .cornerRadius(12)
                }
                
                // Voice note indicator
                if let voiceNote = photo.voiceNote {
                    HStack(spacing: 8) {
                        Image(systemName: "waveform")
                            .font(.system(size: 14))
                        Text("Voice story (\(formatDuration(voiceNote.duration)))")
                            .font(.system(size: 13, weight: .medium))
                        Spacer()
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.brandBlue)
                    }
                    .foregroundColor(Color(hex: "#2C3E50"))
                    .padding(12)
                    .background(Color(hex: "#F0F8FF"))
                    .cornerRadius(12)
                }
                }
            }
        }
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a, MMM d"
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    ChapterDetailView(
        chapter: StoryChapter(
            title: "Summer Vacation",
            description: "Amazing beach days with family",
            photoCount: 3
        ),
        onDismiss: {},
        onToggleFavorite: {}
    )
}
