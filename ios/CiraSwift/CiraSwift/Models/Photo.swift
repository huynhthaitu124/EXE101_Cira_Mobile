//
//  Photo.swift
//  CiraSwift
//
//  Data model for photos
//

import Foundation
import PhotosUI

struct Photo: Identifiable, Codable {
    let id: UUID
    var imageURL: String? // Local file URL
    var dominantColor: String // Hex color
    var tags: [String]
    var caption: String
    var timestamp: Date
    var chapterId: String?
    var thumbnailURL: String?
    
    init(
        id: UUID = UUID(),
        imageURL: String? = nil,
        dominantColor: String = "#000000",
        tags: [String] = [],
        caption: String = "",
        timestamp: Date = Date(),
        chapterId: String? = nil,
        thumbnailURL: String? = nil
    ) {
        self.id = id
        self.imageURL = imageURL
        self.dominantColor = dominantColor
        self.tags = tags
        self.caption = caption
        self.timestamp = timestamp
        self.chapterId = chapterId
        self.thumbnailURL = thumbnailURL
    }
}
