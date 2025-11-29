//
//  UserDefaultsStorage.swift
//  CiraSwift
//
//  Simple persistent storage using UserDefaults (for MVP testing)
//

import Foundation

class UserDefaultsStorage {
    static let shared = UserDefaultsStorage()
    private let defaults = UserDefaults.standard
    
    // MARK: - Keys
    private enum Keys {
        static let photos = "saved_photos"
        static let chapters = "saved_chapters"
    }
    
    // MARK: - Photos
    func savePhotos(_ photos: [Photo]) {
        if let encoded = try? JSONEncoder().encode(photos) {
            defaults.set(encoded, forKey: Keys.photos)
        }
    }
    
    func loadPhotos() -> [Photo] {
        guard let data = defaults.data(forKey: Keys.photos),
              let photos = try? JSONDecoder().decode([Photo].self, from: data) else {
            return []
        }
        return photos
    }
    
    // MARK: - Chapters
    func saveChapters(_ chapters: [StoryChapter]) {
        if let encoded = try? JSONEncoder().encode(chapters) {
            defaults.set(encoded, forKey: Keys.chapters)
        }
    }
    
    func loadChapters() -> [StoryChapter] {
        guard let data = defaults.data(forKey: Keys.chapters),
              let chapters = try? JSONDecoder().decode([StoryChapter].self, from: data) else {
            return []
        }
        return chapters
    }
    
    // MARK: - Clear All
    func clearAll() {
        defaults.removeObject(forKey: Keys.photos)
        defaults.removeObject(forKey: Keys.chapters)
    }
}
