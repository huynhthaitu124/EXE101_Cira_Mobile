//
//  VoiceNote.swift
//  CiraSwift
//
//  Model for voice recordings attached to photos
//

import Foundation

struct VoiceNote: Identifiable, Codable {
    let id: UUID
    var audioURL: String // Local file URL
    var duration: TimeInterval
    var transcribedText: String?
    var timestamp: Date
    var photoId: UUID? // Associated photo
    
    init(
        id: UUID = UUID(),
        audioURL: String,
        duration: TimeInterval,
        transcribedText: String? = nil,
        timestamp: Date = Date(),
        photoId: UUID? = nil
    ) {
        self.id = id
        self.audioURL = audioURL
        self.duration = duration
        self.transcribedText = transcribedText
        self.timestamp = timestamp
        self.photoId = photoId
    }
}
