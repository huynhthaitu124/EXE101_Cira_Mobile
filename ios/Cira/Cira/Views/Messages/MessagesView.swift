//
//  MessagesView.swift
//  Cira
//
//  Messages screen - Refactored with Cira Component Library
//

import SwiftUI

struct MessagesView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    private let conversations: [Conversation] = [
        Conversation(
            id: "1",
            name: "Mom",
            avatar: "https://i.pravatar.cc/150?img=1",
            lastMessage: "Cảm ơn con đã chia sẻ những bức ảnh đẹp! ❤️",
            timestamp: "2 phút trước",
            unread: 2,
            online: true
        ),
        Conversation(
            id: "2",
            name: "Dad",
            avatar: "https://i.pravatar.cc/150?img=2",
            lastMessage: "Bức ảnh hôm nay đẹp quá!",
            timestamp: "15 phút trước",
            unread: 0,
            online: true
        ),
        Conversation(
            id: "3",
            name: "Sister Emily",
            avatar: "https://i.pravatar.cc/150?img=3",
            lastMessage: "Mình thích tấm ảnh sunset lắm 🌅",
            timestamp: "1 giờ trước",
            unread: 1,
            online: false
        ),
        Conversation(
            id: "4",
            name: "Brother John",
            avatar: "https://i.pravatar.cc/150?img=4",
            lastMessage: "Haha cái ảnh này vui quá 😂",
            timestamp: "3 giờ trước",
            unread: 0,
            online: false
        ),
        Conversation(
            id: "5",
            name: "Grandma",
            avatar: "https://i.pravatar.cc/150?img=5",
            lastMessage: "Con yêu ơi, bà nhớ con lắm",
            timestamp: "Hôm qua",
            unread: 0,
            online: false
        ),
        Conversation(
            id: "6",
            name: "Uncle Mike",
            avatar: "https://i.pravatar.cc/150?img=6",
            lastMessage: "Cuối tuần này đi chơi nhé!",
            timestamp: "Hôm qua",
            unread: 0,
            online: true
        ),
        Conversation(
            id: "7",
            name: "Aunt Sarah",
            avatar: "https://i.pravatar.cc/150?img=7",
            lastMessage: "Ảnh gia đình đẹp quá ❤️",
            timestamp: "2 ngày trước",
            unread: 0,
            online: false
        )
    ]
    
    var body: some View {
        ZStack {
            CiraColors.backgroundPrimary.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Search Bar
                searchBar
                
                // Conversations List
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(conversations) { conversation in
                            ConversationRow(conversation: conversation)
                        }
                    }
                    .padding(.bottom, CiraSpacing.xl)
                }
            }
        }
        .navigationTitle("Messages")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {} label: {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 17))
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: CiraSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: CiraSize.iconSM))
                .foregroundColor(CiraColors.textTertiary)
            
            TextField("Tìm kiếm tin nhắn...", text: $searchText)
                .font(CiraTypography.body)
                .foregroundColor(CiraColors.textPrimary)
        }
        .padding(.horizontal, CiraSpacing.md)
        .padding(.vertical, CiraSpacing.sm)
        .background(CiraColors.backgroundSecondary)
        .cornerRadius(CiraSize.radiusMD)
        .padding(.horizontal, CiraSpacing.lg)
        .padding(.vertical, CiraSpacing.md)
    }
}

// MARK: - Conversation Row
struct ConversationRow: View {
    let conversation: Conversation
    @State private var showCallAlert = false
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: CiraSpacing.md) {
                // Avatar with Online Indicator
                ZStack(alignment: .bottomTrailing) {
                    AsyncImage(url: URL(string: conversation.avatar)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: CiraSize.avatarMD, height: CiraSize.avatarMD)
                                .clipShape(Circle())
                        default:
                            Circle()
                                .fill(CiraColors.backgroundTertiary)
                                .frame(width: CiraSize.avatarMD, height: CiraSize.avatarMD)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(CiraColors.textTertiary)
                                )
                        }
                    }
                    
                    if conversation.online {
                        Circle()
                            .fill(CiraColors.success)
                            .frame(width: 14, height: 14)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .offset(x: 2, y: 2)
                    }
                }
                
                // Message Info
                VStack(alignment: .leading, spacing: CiraSpacing.xxs) {
                    HStack {
                        Text(conversation.name)
                            .font(conversation.unread > 0 ? CiraTypography.body.bold() : CiraTypography.body)
                            .foregroundColor(CiraColors.textPrimary)
                        
                        Spacer()
                        
                        Text(conversation.timestamp)
                            .font(CiraTypography.caption)
                            .fontWeight(conversation.unread > 0 ? .semibold : .regular)
                            .foregroundColor(conversation.unread > 0 ? CiraColors.primary : CiraColors.textTertiary)
                    }
                    
                    HStack {
                        Text(conversation.lastMessage)
                            .font(CiraTypography.subheadline)
                            .fontWeight(conversation.unread > 0 ? .medium : .regular)
                            .foregroundColor(conversation.unread > 0 ? CiraColors.textPrimary : CiraColors.textSecondary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        if conversation.unread > 0 {
                            Text("\(conversation.unread)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .frame(minWidth: 20)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(CiraColors.primary)
                                )
                        }
                    }
                }
                
                // Call Button
                CiraIconButton(
                    icon: "phone.fill",
                    style: .tinted(CiraColors.primary),
                    size: .medium
                ) {
                    showCallAlert = true
                }
                .alert("Gọi điện", isPresented: $showCallAlert) {
                    Button("Hủy", role: .cancel) {}
                    Button("Gọi ngay") {}
                } message: {
                    Text("Bạn có muốn gọi cho \(conversation.name) không?")
                }
            }
            .padding(.horizontal, CiraSpacing.lg)
            .padding(.vertical, CiraSpacing.md)
            .background(conversation.unread > 0 ? CiraColors.primary.opacity(0.05) : Color.clear)
        }
        .buttonStyle(CiraListItemPressStyle())
    }
}

// MARK: - Data Model
struct Conversation: Identifiable {
    let id: String
    let name: String
    let avatar: String
    let lastMessage: String
    let timestamp: String
    let unread: Int
    let online: Bool
}

#Preview {
    MessagesView()
        .environmentObject(NavigationManager())
}
