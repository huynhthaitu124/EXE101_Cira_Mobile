# Quick Fix: Remove Core Data and Use UserDefaults

## Bước 1: Xóa Core Data Files

Trong Xcode Navigator:

1. Delete các files này (Move to Trash):
   - `CiraModel.xcdatamodeld` (nếu có)
   - `PersistenceController.swift`
   - `PhotoDataManager.swift`
   - `ChapterDataManager.swift`

## Bước 2: Update CiraApp.swift

Xóa dòng Core Data:

```swift
import SwiftUI
// import CoreData  // XÓA dòng này

@main
struct CiraApp: App {
    // let persistenceController = PersistenceController.shared  // XÓA
    
    @StateObject private var cameraViewModel = CameraViewModel()
    @StateObject private var galleryViewModel = GalleryViewModel()
    
    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                // .environment(\.managedObjectContext, persistenceController.container.viewContext)  // XÓA
                .environmentObject(cameraViewModel)
                .environmentObject(galleryViewModel)
                .preferredColorScheme(.light)
        }
    }
}
```

## Bước 3: Update CameraViewModel

Replace PhotoDataManager với UserDefaults:

```swift
// Trong CameraViewModel.swift
private let storage = UserDefaultsStorage.shared

// Trong savePhoto():
func savePhoto() async throws {
    guard let image = capturedPhoto else { return }
    
    try await photoStorageService.savePhoto(image)
    
    let photo = Photo(
        dominantColor: currentDominantColor,
        tags: selectedTags,
        caption: photoCaption,
        timestamp: Date(),
        voiceNote: currentVoiceNote
    )
    
    // Save to UserDefaults
    var photos = storage.loadPhotos()
    photos.append(photo)
    storage.savePhotos(photos)
    
    // Reset
    await MainActor.run {
        capturedPhoto = nil
        selectedTags = []
        photoCaption = ""
        currentVoiceNote = nil
    }
}
```

## Bước 4: Update GalleryViewModel

```swift
// Trong GalleryViewModel.swift
private let storage = UserDefaultsStorage.shared

func loadChapters() {
    let chapters = storage.loadChapters()
    // Separate my vs family
    myChapters = chapters.filter { $0.author == nil }
    familyChapters = chapters.filter { $0.author != nil }
}

func toggleFavorite(chapterId: UUID) {
    // Update in memory
    if let index = myChapters.firstIndex(where: { $0.id == chapterId }) {
        myChapters[index].isFavorite.toggle()
    }
    if let index = familyChapters.firstIndex(where: { $0.id == chapterId }) {
        familyChapters[index].isFavorite.toggle()
    }
    
    // Save all chapters
    storage.saveChapters(myChapters + familyChapters)
}
```

## Bước 5: Clean & Build

```bash
# Terminal
cd /Users/huynh/Projects/Cira/ios
rm -rf ~/Library/Developer/Xcode/DerivedData/Cira-*
```

Trong Xcode:
- Clean: **⇧⌘K**
- Build: **⌘B**
- Run: **⌘R**

---

## Ưu điểm UserDefaults:

✅ Đơn giản, không cần setup  
✅ Không có compilation errors  
✅ Đủ cho MVP testing  
✅ Dễ migrate sang Core Data sau  

## Nhược điểm:

❌ Giới hạn 1MB data  
❌ Không có relationships  
❌ Không query được  

**Recommendation:** Dùng UserDefaults để test app trước, add Core Data sau khi app đã work! 🎯
