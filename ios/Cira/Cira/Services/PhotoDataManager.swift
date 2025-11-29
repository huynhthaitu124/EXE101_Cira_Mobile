//
//  PhotoDataManager.swift
//  CiraSwift
//
//  Data manager for Photo CRUD operations
//

import CoreData
import Foundation

class PhotoDataManager {
    private let persistence = PersistenceController.shared
    
    // MARK: - Fetch Photos
    func fetchPhotos(for chapterId: String? = nil) -> [Photo] {
        let context = persistence.container.viewContext
        let request = PhotoEntity.fetchRequest()
        
        // Filter by chapter if provided
        if let chapterId = chapterId {
            request.predicate = NSPredicate(format: "chapterId == %@", chapterId)
        }
        
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        do {
            let entities = try context.fetch(request)
            return entities.map { $0.toModel() }
        } catch {
            print("Error fetching photos: \(error)")
            return []
        }
    }
    
    // MARK: - Save Photo
    @discardableResult
    func savePhoto(_ photo: Photo) -> Bool {
        let context = persistence.container.viewContext
        
        // Check if photo already exists
        let request = PhotoEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", photo.id as CVarArg)
        
        do {
            let existing = try context.fetch(request)
            
            if let existingPhoto = existing.first {
                // Update existing
                existingPhoto.update(from: photo, context: context)
            } else {
                // Create new
                _ = PhotoEntity.create(from: photo, context: context)
            }
            
            persistence.save()
            return true
        } catch {
            print("Error saving photo: \(error)")
            return false
        }
    }
    
    // MARK: - Delete Photo
    func deletePhoto(_ photoId: UUID) -> Bool {
        let context = persistence.container.viewContext
        let request = PhotoEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", photoId as CVarArg)
        
        do {
            let entities = try context.fetch(request)
            entities.forEach { context.delete($0) }
            persistence.save()
            return true
        } catch {
            print("Error deleting photo: \(error)")
            return false
        }
    }
    
    // MARK: - Update Photo Caption
    func updatePhotoCaption(_ photoId: UUID, caption: String) -> Bool {
        let context = persistence.container.viewContext
        let request = PhotoEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", photoId as CVarArg)
        
        do {
            if let photo = try context.fetch(request).first {
                photo.caption = caption
                persistence.save()
                return true
            }
            return false
        } catch {
            print("Error updating caption: \(error)")
            return false
        }
    }
    
    // MARK: - Add Voice Note to Photo
    func addVoiceNoteToPhoto(_ photoId: UUID, voiceNote: VoiceNote) -> Bool {
        let context = persistence.container.viewContext
        let request = PhotoEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", photoId as CVarArg)
        
        do {
            if let photo = try context.fetch(request).first {
                let voiceNoteEntity = VoiceNoteEntity.create(from: voiceNote, context: context)
                photo.voiceNoteEntity = voiceNoteEntity
                persistence.save()
                return true
            }
            return false
        } catch {
            print("Error adding voice note: \(error)")
            return false
        }
    }
}
