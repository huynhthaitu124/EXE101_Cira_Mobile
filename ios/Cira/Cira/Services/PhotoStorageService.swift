//
//  PhotoStorageService.swift
//  CiraSwift
//
//  Service for photo storage (PHPhotoLibrary + UserDefaults/CoreData)
//

import Photos
import UIKit

class PhotoStorageService {
    // MARK: - Save to Library (from RN MediaLibrary.saveToLibraryAsync)
    func saveToLibrary(image: UIImage) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }
    }
    
    // MARK: - TODO: Core Data / UserDefaults storage
    func savePhotoMetadata(_ photo: Photo) {
        // TODO: Save to CoreData or UserDefaults
    }
    
    func loadPhotos() -> [Photo] {
        // TODO: Load from CoreData or UserDefaults
        return []
    }
}
