//
//  CameraViewModel.swift
//  CiraSwift
//
//  ViewModel for camera functionality - MVVM pattern
//

import SwiftUI
import AVFoundation
import Photos
import Combine

@MainActor
class CameraViewModel: ObservableObject {
    // MARK: - Published State (from RN useState)
    @Published var capturedPhoto: UIImage?
    @Published var dominantColor: Color = .black
    @Published var suggestedTags: [String] = []
    @Published var selectedTags: [String] = []
    @Published var photoCaption: String = ""
    @Published var isTypingCaption: Bool = false
    @Published var cameraPosition: AVCaptureDevice.Position = .back
    
    // MARK: - Permissions
    @Published var cameraPermissionGranted: Bool = false
    @Published var photoLibraryPermissionGranted: Bool = false
    
    // MARK: - Services
    @Published var cameraService = CameraService()
    private let photoStorageService = PhotoStorageService()
    
    // MARK: - Mock Chapters (from RN myChapters)
    let mockChapters: [StoryChapter] = [
        StoryChapter(title: "Summer Vacation 2024", icon: "🏖️"),
        StoryChapter(title: "Birthday Celebration", icon: "🎂"),
        StoryChapter(title: "Mountain Adventure", icon: "⛰️"),
        StoryChapter(title: "Family Gathering", icon: "👨‍👩‍👧‍👦"),
    ]
    
    init() {
        Task {
            await requestPermissions()
            await setupCamera()
        }
    }
    
    // MARK: - Permissions (from RN useEffect)
    func requestPermissions() async {
        // Camera permission
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if cameraStatus == .notDetermined {
            cameraPermissionGranted = await AVCaptureDevice.requestAccess(for: .video)
        } else {
            cameraPermissionGranted = cameraStatus == .authorized
        }
        
        // Photo library permission
        let photoStatus = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        if photoStatus == .notDetermined {
            let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            photoLibraryPermissionGranted = status == .authorized
        } else {
            photoLibraryPermissionGranted = photoStatus == .authorized
        }
    }
    
    // MARK: - Camera Setup
    func setupCamera() async {
        if cameraPermissionGranted {
            cameraService.setupCamera(position: cameraPosition)
            cameraService.startSession()
        }
    }
    
    // MARK: - Camera Actions
    func toggleCameraPosition() {
        cameraPosition = cameraPosition == .back ? .front : .back
        cameraService.flipCamera(to: cameraPosition)
    }
    
    func takePictureFromCamera() {
        cameraService.capturePhoto { [weak self] image in
            guard let self = self, let image = image else { return }
            Task { @MainActor in
                self.capturePhoto(image: image)
            }
        }
    }
    
    func capturePhoto(image: UIImage) {
        // Flip if front camera (from RN ImageManipulator.FlipType.Horizontal)
        if cameraPosition == .front {
            if let flippedImage = image.flipHorizontally() {
                capturedPhoto = flippedImage
            } else {
                capturedPhoto = image
            }
        } else {
            capturedPhoto = image
        }
        
        // Generate dominant color and tags
        dominantColor = Color.randomPaletteColor()
        generateSuggestedTags()
    }
    
    // MARK: - Generate AI Tags (from RN generateSuggestedTags)
    func generateSuggestedTags() {
        let mockTags = [
            "🌅 Sunset",
            "👨‍👩‍👧‍👦 Family",
            "🏖️ Beach",
            "😊 Happy",
            "🌴 Nature",
            "📸 Memory",
            "❤️ Love",
            "🎉 Celebration",
        ]
        
        // Randomly select 4-6 tags
        let numTags = Int.random(in: 4...6)
        suggestedTags = mockTags.shuffled().prefix(numTags).map { $0 }
        selectedTags = []
    }
    
    func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.removeAll { $0 == tag }
        } else {
            selectedTags.append(tag)
        }
    }
    
    // MARK: - Save Photo
    func savePhoto() async throws {
        guard let photo = capturedPhoto else { return }
        
        // Save to photo library
        try await photoStorageService.saveToLibrary(image: photo)
        
        // Reset state
        resetPhotoState()
    }
    
    func retakePhoto() {
        resetPhotoState()
    }
    
    private func resetPhotoState() {
        capturedPhoto = nil
        dominantColor = .black
        suggestedTags = []
        selectedTags = []
        photoCaption = ""
        isTypingCaption = false
    }
}

// MARK: - UIImage Extension for Flipping
extension UIImage {
    func flipHorizontally() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.translateBy(x: size.width, y: 0)
        context.scaleBy(x: -1.0, y: 1.0)
        draw(in: CGRect(origin: .zero, size: size))
        
        let flippedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return flippedImage
    }
}
