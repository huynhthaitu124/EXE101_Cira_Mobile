//
//  FeedView.swift
//  CiraSwift
//
//  Family feed screen (matching FeedScreen.tsx exactly)
//

import SwiftUI

struct FeedView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @Environment(\.dismiss) private var dismiss
    @State private var posts: [FeedPost] = FeedPost.mockData
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Feed ScrollView
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 24) {
                        ForEach($posts) { $post in
                            FeedPostView(post: $post)
                        }
                    }
                }
            }
        }
        .navigationTitle("Everyone")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {} label: {
                    Image(systemName: "bubble.left")
                        .font(.system(size: 17))
                        .foregroundColor(.primary)
                }
            }
        }
    }
}

// MARK: - Feed Post View
struct FeedPostView: View {
    @Binding var post: FeedPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // User Header
            HStack {
                HStack(spacing: 12) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.05))
                            .frame(width: 40, height: 40)
                        
                        Text(post.user.avatar)
                            .font(.system(size: 20))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(post.user.name)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.black)
                        
                        Text(post.timestamp)
                            .font(.system(size: 12))
                            .foregroundColor(.black.opacity(0.5))
                    }
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16))
                        .foregroundColor(.black.opacity(0.7))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            // Image
            AsyncImage(url: URL(string: post.image)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(0.8, contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .clipped()
                case .failure:
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .aspectRatio(0.8, contentMode: .fill)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.gray.opacity(0.3))
                        )
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .aspectRatio(0.8, contentMode: .fill)
                        .overlay(ProgressView())
                @unknown default:
                    EmptyView()
                }
            }
            
            // Actions
            HStack {
                HStack(spacing: 20) {
                    Button(action: { toggleLike() }) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 24))
                            .foregroundColor(post.isLiked ? Color(hex: "#FF3B30") : .black)
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 22))
                            .foregroundColor(.black)
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "paperplane")
                            .font(.system(size: 22))
                            .foregroundColor(.black)
                    }
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 22))
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            // Likes
            Text("\(post.likes) \(post.likes == 1 ? "like" : "likes")")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            
            // Caption
            HStack(spacing: 4) {
                Text(post.user.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                
                Text(post.caption)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
            
            // Comments
            if !post.comments.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Button(action: {}) {
                        Text("View all \(post.comments.count) comments")
                            .font(.system(size: 13))
                            .foregroundColor(.black.opacity(0.5))
                    }
                    .padding(.bottom, 4)
                    
                    ForEach(post.comments.prefix(2)) { comment in
                        HStack(alignment: .top, spacing: 8) {
                            Text(comment.avatar)
                                .font(.system(size: 16))
                            
                            HStack(spacing: 4) {
                                Text(comment.user)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.black)
                                
                                Text(comment.text)
                                    .font(.system(size: 13))
                                    .foregroundColor(.black)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // Add Comment
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.05))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "person.circle")
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                }
                
                Text("Add a comment...")
                    .font(.system(size: 13))
                    .foregroundColor(.black.opacity(0.5))
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
    }
    
    private func toggleLike() {
        post.isLiked.toggle()
        post.likes += post.isLiked ? 1 : -1
    }
}

// MARK: - Data Models
struct FeedPost: Identifiable {
    let id: String
    let user: FeedUser
    let image: String
    let caption: String
    let timestamp: String
    var likes: Int
    var isLiked: Bool
    let comments: [FeedComment]
    
    static let mockData: [FeedPost] = [
        FeedPost(
            id: "1",
            user: FeedUser(name: "Mom", avatar: "👩"),
            image: "https://picsum.photos/400/500?random=1",
            caption: "Beautiful sunset at the beach today! 🌅",
            timestamp: "2 hours ago",
            likes: 12,
            isLiked: true,
            comments: [
                FeedComment(id: "1", user: "Dad", text: "Gorgeous! Miss you ❤️", avatar: "👨"),
                FeedComment(id: "2", user: "Sister", text: "So pretty! 😍", avatar: "👧")
            ]
        ),
        FeedPost(
            id: "2",
            user: FeedUser(name: "Dad", avatar: "👨"),
            image: "https://picsum.photos/400/500?random=2",
            caption: "Made pancakes for breakfast! 🥞",
            timestamp: "5 hours ago",
            likes: 8,
            isLiked: false,
            comments: [
                FeedComment(id: "1", user: "Mom", text: "Yummy! Save some for me 😋", avatar: "👩")
            ]
        ),
        FeedPost(
            id: "3",
            user: FeedUser(name: "Sister", avatar: "👧"),
            image: "https://picsum.photos/400/500?random=3",
            caption: "First day at the new job! Wish me luck! 💼✨",
            timestamp: "1 day ago",
            likes: 15,
            isLiked: true,
            comments: [
                FeedComment(id: "1", user: "Mom", text: "So proud of you! 🎉", avatar: "👩"),
                FeedComment(id: "2", user: "Dad", text: "Good luck sweetheart! 👍", avatar: "👨"),
                FeedComment(id: "3", user: "Grandma", text: "You got this! ❤️", avatar: "👵")
            ]
        ),
        FeedPost(
            id: "4",
            user: FeedUser(name: "Grandma", avatar: "👵"),
            image: "https://picsum.photos/400/500?random=4",
            caption: "Garden is blooming! 🌸🌺",
            timestamp: "2 days ago",
            likes: 20,
            isLiked: true,
            comments: [
                FeedComment(id: "1", user: "Mom", text: "Beautiful flowers! 🌹", avatar: "👩"),
                FeedComment(id: "2", user: "Sister", text: "Can I come visit? 🥰", avatar: "👧")
            ]
        )
    ]
}

struct FeedUser {
    let name: String
    let avatar: String
}

struct FeedComment: Identifiable {
    let id: String
    let user: String
    let text: String
    let avatar: String
}

#Preview {
    FeedView()
        .environmentObject(NavigationManager())
}
