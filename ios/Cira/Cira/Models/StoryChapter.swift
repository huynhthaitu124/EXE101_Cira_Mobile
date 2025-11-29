//
//  StoryChapter.swift
//  CiraSwift
//
//  Data model for story chapters (albums)
//

import Foundation

struct StoryChapter: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var icon: String // Emoji
    var coverColor: String // Hex color
    var photoCount: Int
    var coverImageURL: String? // Optional cover image
    var createdAt: Date
    var photos: [Photo]
    var isFavorite: Bool // Favorite toggle
    var author: String? // For family chapters
    var authorInitial: String? // For family chapters avatar
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        icon: String = "📸",
        coverColor: String = "#5DADE2",
        photoCount: Int = 0,
        coverImageURL: String? = nil,
        createdAt: Date = Date(),
        photos: [Photo] = [],
        isFavorite: Bool = false,
        author: String? = nil,
        authorInitial: String? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.coverColor = coverColor
        self.photoCount = photoCount
        self.coverImageURL = coverImageURL
        self.createdAt = createdAt
        self.photos = photos
        self.isFavorite = isFavorite
        self.author = author
        self.authorInitial = authorInitial
    }
}
