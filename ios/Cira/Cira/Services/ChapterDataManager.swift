//
//  ChapterDataManager.swift
//  CiraSwift
//
//  Data manager for StoryChapter CRUD operations
//

import CoreData
import Foundation

class ChapterDataManager {
    private let persistence = PersistenceController.shared
    
    // MARK: - Fetch Chapters
    func fetchChapters(authorFilter: String? = nil) -> [StoryChapter] {
        let context = persistence.container.viewContext
        let request = ChapterEntity.fetchRequest()
        
        // Filter by author (for family chapters)
        if let author = authorFilter {
            request.predicate = NSPredicate(format: "author == %@", author)
        } else {
            // My chapters (no author)
            request.predicate = NSPredicate(format: "author == nil")
        }
        
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            let entities = try context.fetch(request)
            return entities.map { $0.toModel() }
        } catch {
            print("Error fetching chapters: \(error)")
            return []
        }
    }
    
    // MARK: - Fetch All Chapters (My + Family)
    func fetchAllChapters() -> (my: [StoryChapter], family: [StoryChapter]) {
        let myChapters = fetchChapters(authorFilter: nil)
        
        // Fetch family chapters (has author)
        let context = persistence.container.viewContext
        let request = ChapterEntity.fetchRequest()
        request.predicate = NSPredicate(format: "author != nil")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        let familyChapters: [StoryChapter]
        do {
            let entities = try context.fetch(request)
            familyChapters = entities.map { $0.toModel() }
        } catch {
            print("Error fetching family chapters: \(error)")
            familyChapters = []
        }
        
        return (myChapters, familyChapters)
    }
    
    // MARK: - Save Chapter
    @discardableResult
    func saveChapter(_ chapter: StoryChapter) -> Bool {
        let context = persistence.container.viewContext
        
        // Check if chapter already exists
        let request = ChapterEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", chapter.id as CVarArg)
        
        do {
            let existing = try context.fetch(request)
            
            if let existingChapter = existing.first {
                // Update existing
                existingChapter.update(from: chapter, context: context)
            } else {
                // Create new
                _ = ChapterEntity.create(from: chapter, context: context)
            }
            
            persistence.save()
            return true
        } catch {
            print("Error saving chapter: \(error)")
            return false
        }
    }
    
    // MARK: - Delete Chapter
    func deleteChapter(_ chapterId: UUID) -> Bool {
        let context = persistence.container.viewContext
        let request = ChapterEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", chapterId as CVarArg)
        
        do {
            let entities = try context.fetch(request)
            entities.forEach { context.delete($0) }
            persistence.save()
            return true
        } catch {
            print("Error deleting chapter: \(error)")
            return false
        }
    }
    
    // MARK: - Toggle Favorite
    func toggleFavorite(_ chapterId: UUID) -> Bool {
        let context = persistence.container.viewContext
        let request = ChapterEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", chapterId as CVarArg)
        
        do {
            if let chapter = try context.fetch(request).first {
                chapter.isFavorite.toggle()
                persistence.save()
                return true
            }
            return false
        } catch {
            print("Error toggling favorite: \(error)")
            return false
        }
    }
    
    // MARK: - Add Photo to Chapter
    func addPhotoToChapter(_ chapterId: UUID, photo: Photo) -> Bool {
        let context = persistence.container.viewContext
        let chapterRequest = ChapterEntity.fetchRequest()
        chapterRequest.predicate = NSPredicate(format: "id == %@", chapterId as CVarArg)
        
        do {
            if let chapter = try context.fetch(chapterRequest).first {
                // Create photo entity
                let photoEntity = PhotoEntity.create(from: photo, context: context)
                photoEntity.chapterId = chapterId.uuidString
                photoEntity.chapter = chapter
                
                // Update chapter photo count
                chapter.photoCount += 1
                
                // Update cover if first photo
                if chapter.photoCount == 1 {
                    chapter.coverImageURL = photo.imageURL
                    chapter.coverColor = photo.dominantColor
                }
                
                persistence.save()
                return true
            }
            return false
        } catch {
            print("Error adding photo to chapter: \(error)")
            return false
        }
    }
    
    // MARK: - Get Chapter with Photos
    func getChapter(_ chapterId: UUID) -> StoryChapter? {
        let context = persistence.container.viewContext
        let request = ChapterEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", chapterId as CVarArg)
        
        do {
            if let entity = try context.fetch(request).first {
                return entity.toModel()
            }
            return nil
        } catch {
            print("Error fetching chapter: \(error)")
            return nil
        }
    }
}
