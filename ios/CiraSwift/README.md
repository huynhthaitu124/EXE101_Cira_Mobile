# Cira Swift - Memory Story Vault

A native iOS app for elderly users to preserve family memories through photos and voice stories.

## Project Structure

```
CiraSwift/
├── CiraApp.swift              # Main app entry
├── Models/                    # Data models
├── ViewModels/                # MVVM state management  
├── Views/                     # SwiftUI views
│   └── Camera/               # Camera capture UI
├── Services/                  # Business logic
├── Navigation/               # App navigation
├── Extensions/               # Utilities
└── Info.plist                # Permissions
```

## Features Implemented

### ✅ Phase 1: Project Setup
- MVVM architecture
- Glassmorphism design system (liquid glass UI)
- Theme colors matching React Native design
- Base models (Photo, StoryChapter)

### ✅ Phase 2: Camera & Photos
- Real AVCaptureSession integration
- Live camera preview
- Photo capture with AVCapturePhotoOutput
- Front/back camera flip
- Photo storage with PHPhotoLibrary
- AI-suggested tags system
- Glassmorphism UI with gradient overlays

## Setup Instructions

### 1. Create Xcode Project

Since we only have the Swift source files, you need to create an Xcode project:

```bash
# Navigate to the iOS directory
cd /Users/huynh/Projects/Cira/ios

# Option A: Create project via Xcode GUI
# 1. Open Xcode
# 2. File → New → Project
# 3. iOS → App
# 4. Product Name: CiraSwift
# 5. Interface: SwiftUI
# 6. Language: Swift
# 7. Save to: /Users/huynh/Projects/Cira/ios/CiraSwift/
# 8. Drag all .swift files from CiraSwift/CiraSwift/ into project navigator
# 9. Add Info.plist to project

# Option B: Use existing React Native Xcode project as template
# (requires more configuration)
```

### 2. Required Permissions

The app requires these permissions (already in Info.plist):
- **Camera**: For photo capture
- **Photo Library**: To save photos
- **Microphone**: For future voice recording
- **Speech Recognition**: For future voice-to-text

### 3. Build & Run

```bash
# In Xcode:
# 1. Select target: CiraSwift
# 2. Select simulator: iPhone 15 (or your device)
# 3. Click Run (⌘+R)

# Grant permissions when prompted
```

## Key Technologies

- **SwiftUI**: Modern declarative UI
- **AVFoundation**: Camera capture
- **PhotoKit**: Photo library integration
- **Combine**: Reactive programming

## Design Philosophy

Following CIRA's mission: **Simple and warm** for elderly users
- Large touch targets (56x56pt minimum)
- High contrast colors
- Glassmorphism for premium feel
- Minimal cognitive load
- One primary action per screen

## Next Steps

- [ ] Voice recording service (AVAudioRecorder)
- [ ] Speech-to-text (Speech framework)
- [ ] Gallery view with story chapters
- [ ] Core Data for local storage
- [ ] Memory prompts system

## Notes

This is a native iOS migration from the React Native codebase, implementing the "Memory Story Vault" concept for Vietnamese families to preserve memories with their elderly loved ones.
