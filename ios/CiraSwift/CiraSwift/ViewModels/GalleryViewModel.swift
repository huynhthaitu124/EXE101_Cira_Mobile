//
//  GalleryViewModel.swift
//  CiraSwift
//
//  ViewModel for gallery and story chapters
//

import SwiftUI
import Combine

@MainActor
class GalleryViewModel: ObservableObject {
    // MARK: - Published State
    @Published var chapters: [StoryChapter] = []
    @Published var selectedChapter: StoryChapter?
    
    init() {
        // Load chapters from storage
        loadChapters()
    }
    
    func loadChapters() {
        // TODO: Load from CoreData/UserDefaults
        // For now, use mock data
        chapters = []
    }
    
    func createChapter(title: String, description: String, icon: String = "📸") {
        let newChapter = StoryChapter(
            title: title,
            description: description,
            icon: icon,
            coverColor: Color.randomPaletteColor().toHex() ?? "#5DADE2"
        )
        chapters.append(newChapter)
        // TODO: Save to storage
    }
    
    func addPhotoToChapter(chapterId: UUID, photo: Photo) {
        if let index = chapters.firstIndex(where: { $0.id == chapterId }) {
            chapters[index].photos.append(photo)
            chapters[index].photoCount += 1
            // TODO: Save to storage
        }
    }
}

// MARK: - Color to Hex Helper
extension Color {
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        let r = components[0]
        let g = components[1]
        let b = components[2]
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
