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
    @Published var myChapters: [StoryChapter] = []
    @Published var familyChapters: [StoryChapter] = []
    @Published var selectedChapter: StoryChapter?
    
    // MARK: - Services
    private let storage = UserDefaultsStorage.shared
    
    init() {
        // Load chapters from UserDefaults
        loadChapters()
        
        // If no data, load mock data for first time
        if myChapters.isEmpty && familyChapters.isEmpty {
            loadMockData()
        }
    }
    
    // MARK: - Load Chapters
    func loadChapters() {
        let allChapters = storage.loadChapters()
        myChapters = allChapters.filter { $0.author == nil }
        familyChapters = allChapters.filter { $0.author != nil }
    }
    
    // MARK: - Load Mock Data (First Time Only)
    private func loadMockData() {
        let mockMyChapters = [
            StoryChapter(
                title: "Summer Vacation 2024",
                description: "Amazing beach days with family, building sandcastles and watching beautiful sunsets together.",
                icon: "🏖️",
                coverColor: "#FFD93D",
                photoCount: 3,
                photos: [
                    Photo(dominantColor: "#FFD93D", caption: "Perfect beach weather! The water is so clear and warm 🌊☀️"),
                    Photo(dominantColor: "#4ECDC4", caption: "Most beautiful sunset I've ever seen with my favorite people ❤️"),
                    Photo(dominantColor: "#95E1D3", caption: "Building sandcastles with the kids. Their imagination is endless! 🏰"),
                ]
            ),
            StoryChapter(
                title: "Birthday Celebration",
                description: "Emma's 5th birthday party filled with laughter, cake, and unforgettable moments.",
                icon: "🎂",
                coverColor: "#FF6B6B",
                photoCount: 3,
                photos: [
                    Photo(dominantColor: "#FF6B6B", caption: "Happy 5th birthday Emma! 🎂"),
                    Photo(dominantColor: "#F38181", caption: "All her friends came! Best party ever 🎈🎉"),
                    Photo(dominantColor: "#FCBAD3", caption: "Opening presents - her face lights up! 🎁"),
                ]
            ),
            StoryChapter(
                title: "Mountain Adventure",
                description: "Hiking through scenic trails, discovering nature, and creating memories.",
                icon: "⛰️",
                coverColor: "#6BCB77",
                photoCount: 4
            ),
        ]
        
        let mockFamilyChapters = [
            StoryChapter(
                title: "Mom's Garden Journey",
                description: "Mom's beautiful flower garden through the seasons.",
                icon: "🌺",
                coverColor: "#95E1D3",
                photoCount: 2,
                author: "Mom",
                authorInitial: "M"
            ),
            StoryChapter(
                title: "Dad's Fishing Adventures",
                description: "Weekend fishing trips and the big catches.",
                icon: "🎣",
                coverColor: "#4D96FF",
                photoCount: 2,
                author: "Dad",
                authorInitial: "D"
            ),
        ]
        
        // Save mock data to UserDefaults
        storage.saveChapters(mockMyChapters + mockFamilyChapters)
        
        // Reload
        loadChapters()
    }
    
    // MARK: - Computed Properties
    func chapters(for tab: GalleryView.Tab) -> [StoryChapter] {
        tab == .my ? myChapters : familyChapters
    }
    
    // MARK: - Actions
    func toggleFavorite(chapterId: UUID) {
        // Update in memory
        if let index = myChapters.firstIndex(where: { $0.id == chapterId }) {
            myChapters[index].isFavorite.toggle()
        }
        if let index = familyChapters.firstIndex(where: { $0.id == chapterId }) {
            familyChapters[index].isFavorite.toggle()
        }
        
        // Save to UserDefaults
        storage.saveChapters(myChapters + familyChapters)
    }
    
    func createChapter(title: String, description: String, icon: String = "📸") {
        let newChapter = StoryChapter(
            title: title,
            description: description,
            icon: icon,
            coverColor: Color.randomPaletteColor().toHex() ?? "#5DADE2"
        )
        myChapters.append(newChapter)
        storage.saveChapters(myChapters + familyChapters)
    }
    
    func addPhotoToChapter(chapterId: UUID, photo: Photo) {
        if let index = myChapters.firstIndex(where: { $0.id == chapterId }) {
            myChapters[index].photos.append(photo)
            myChapters[index].photoCount += 1
            storage.saveChapters(myChapters + familyChapters)
        }
    }
    
    func deleteChapter(chapterId: UUID) {
        myChapters.removeAll { $0.id == chapterId }
        familyChapters.removeAll { $0.id == chapterId }
        storage.saveChapters(myChapters + familyChapters)
    }
}
