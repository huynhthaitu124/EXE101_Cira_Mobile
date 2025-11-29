//
//  PersistenceController.swift
//  CiraSwift
//
//  Core Data stack and persistence management
//

import CoreData
import SwiftUI

class PersistenceController {
    // MARK: - Singleton
    static let shared = PersistenceController()
    
    // MARK: - Core Data Stack
    let container: NSPersistentContainer
    
    // MARK: - Preview (for SwiftUI previews)
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        
        // Create sample data for previews
        // TODO: Add sample entities
        
        return controller
    }()
    
    // MARK: - Initialization
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "CiraModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        
        // Automatically merge changes from parent context
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Save Context
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Error saving context: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - Background Context
    func newBackgroundContext() -> NSManagedObjectContext {
        return container.newBackgroundContext()
    }
    
    // MARK: - Delete All Data (for testing)
    func deleteAllData() {
        let context = container.viewContext
        
        // Delete all entities
        let entities = ["PhotoEntity", "ChapterEntity", "VoiceNoteEntity"]
        
        for entity in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
            } catch {
                print("Error deleting \(entity): \(error)")
            }
        }
        
        save()
    }
}

// MARK: - Photo Entity Extension
extension PhotoEntity {
    func toModel() -> Photo {
        return Photo(
            id: id ?? UUID(),
            imageURL: imageURL,
            dominantColor: dominantColor ?? "#000000",
            tags: (tags as? [String]) ?? [],
            caption: caption ?? "",
            timestamp: timestamp ?? Date(),
            chapterId: chapterId,
            thumbnailURL: thumbnailURL,
            voiceNote: voiceNoteEntity?.toModel()
        )
    }
    
    func update(from photo: Photo, context: NSManagedObjectContext) {
        self.id = photo.id
        self.imageURL = photo.imageURL
        self.dominantColor = photo.dominantColor
        self.tags = photo.tags // Already [String]? with Transformable + Custom Class
        self.caption = photo.caption
        self.timestamp = photo.timestamp
        self.chapterId = photo.chapterId
        self.thumbnailURL = photo.thumbnailURL
        
        // Update voice note if exists
        if let voiceNote = photo.voiceNote {
            if let existingVoiceNote = self.voiceNoteEntity {
                existingVoiceNote.update(from: voiceNote, context: context)
            } else {
                let newVoiceNote = VoiceNoteEntity(context: context)
                newVoiceNote.update(from: voiceNote, context: context)
                self.voiceNoteEntity = newVoiceNote
            }
        }
    }
    
    static func create(from photo: Photo, context: NSManagedObjectContext) -> PhotoEntity {
        let entity = PhotoEntity(context: context)
        entity.update(from: photo, context: context)
        return entity
    }
}

// MARK: - Chapter Entity Extension
extension ChapterEntity {
    func toModel() -> StoryChapter {
        let photoEntities = (photos?.allObjects as? [PhotoEntity]) ?? []
        let photoModels = photoEntities.map { $0.toModel() }
        
        return StoryChapter(
            id: id ?? UUID(),
            title: title ?? "",
            description: chapterDescription ?? "",
            icon: icon ?? "📸",
            coverColor: coverColor ?? "#5DADE2",
            photoCount: Int(photoCount),
            coverImageURL: coverImageURL,
            createdAt: createdAt ?? Date(),
            photos: photoModels,
            isFavorite: isFavorite,
            author: author,
            authorInitial: authorInitial
        )
    }
    
    func update(from chapter: StoryChapter, context: NSManagedObjectContext) {
        self.id = chapter.id
        self.title = chapter.title
        self.chapterDescription = chapter.description
        self.icon = chapter.icon
        self.coverColor = chapter.coverColor
        self.photoCount = Int32(chapter.photoCount)
        self.coverImageURL = chapter.coverImageURL
        self.createdAt = chapter.createdAt
        self.isFavorite = chapter.isFavorite
        self.author = chapter.author
        self.authorInitial = chapter.authorInitial
    }
    
    static func create(from chapter: StoryChapter, context: NSManagedObjectContext) -> ChapterEntity {
        let entity = ChapterEntity(context: context)
        entity.update(from: chapter, context: context)
        return entity
    }
}

// MARK: - Voice Note Entity Extension
extension VoiceNoteEntity {
    func toModel() -> VoiceNote {
        return VoiceNote(
            id: id ?? UUID(),
            audioURL: audioURL ?? "",
            duration: duration,
            transcribedText: transcribedText,
            timestamp: timestamp ?? Date(),
            photoId: photoId
        )
    }
    
    func update(from voiceNote: VoiceNote, context: NSManagedObjectContext) {
        self.id = voiceNote.id
        self.audioURL = voiceNote.audioURL
        self.duration = voiceNote.duration
        self.transcribedText = voiceNote.transcribedText
        self.timestamp = voiceNote.timestamp
        self.photoId = voiceNote.photoId
    }
    
    static func create(from voiceNote: VoiceNote, context: NSManagedObjectContext) -> VoiceNoteEntity {
        let entity = VoiceNoteEntity(context: context)
        entity.update(from: voiceNote, context: context)
        return entity
    }
}
