# Xcode Project Setup Guide

## Method 1: Create via Xcode GUI (Recommended - Easiest)

### Bước 1: Tạo Project Mới
1. Mở Xcode
2. **File → New → Project** (hoặc ⇧⌘N)
3. Chọn **iOS** → **App**
4. Click **Next**

### Bước 2: Cấu Hình Project
Điền thông tin:
- **Product Name**: `CiraSwift`
- **Team**: Select your team (hoặc để None nếu chưa có Apple Developer account)
- **Organization Identifier**: `com.cira` (hoặc tên domain của bạn)
- **Bundle Identifier**: `com.cira.CiraSwift` (auto-generated)
- **Interface**: `SwiftUI` ✅
- **Language**: `Swift` ✅
- **Storage**: `None` (we'll add Core Data later)
- **Include Tests**: ✅ (optional)

Click **Next**

### Bước 3: Chọn Vị Trí Lưu
- **Where**: Navigate to `/Users/huynh/Projects/Cira/ios/`
- **IMPORTANT**: Uncheck "Create Git repository" (vì đã có git ở parent folder)
- **Folder name**: Xcode sẽ tạo thư mục `CiraSwift`

⚠️ **LƯU Ý**: Xcode sẽ tạo project vào `ios/CiraSwift/CiraSwift.xcodeproj`

### Bước 4: Xóa Files Mẫu của Xcode
Xcode tạo sẵn một số file mẫu, ta sẽ xóa và thay bằng code đã viết:

1. Trong Project Navigator (⌘1), xóa các files này:
   - `CiraSwiftApp.swift` (file mẫu)
   - `ContentView.swift` (file mẫu)
   
   *(Right-click → Delete → Move to Trash)*

### Bước 5: Import Swift Files Đã Viết
1. Trong Finder, mở folder: `/Users/huynh/Projects/Cira/ios/CiraSwift/CiraSwift/`
2. Select ALL Swift files và folders:
   - `CiraApp.swift`
   - `Models/`
   - `ViewModels/`
   - `Views/`
   - `Services/`
   - `Navigation/`
   - `Extensions/`
   - `Info.plist`

3. Drag & drop vào Xcode Project Navigator
4. Trong popup, chọn:
   - ✅ **Copy items if needed**
   - ✅ **Create groups** (not folder references)
   - ✅ Add to target: **CiraSwift**
   
5. Click **Finish**

### Bước 6: Configure Info.plist
1. Select project root trong navigator (CiraSwift - blue icon)
2. Select target **CiraSwift**
3. Tab **Info**
4. Click "+" để thêm permissions:

Add these keys (hoặc dùng Info.plist file đã có):
- `NSCameraUsageDescription` = "Cira needs camera access to capture photos"
- `NSPhotoLibraryAddUsageDescription` = "Cira needs to save photos to library"
- `NSMicrophoneUsageDescription` = "Cira needs microphone for voice stories"
- `NSSpeechRecognitionUsageDescription` = "Cira uses speech recognition for transcription"

### Bước 7: Build & Run
1. Select target: **CiraSwift** (top left)
2. Select simulator: **iPhone 15** (hoặc device bạn muốn)
3. Click **Run** button (▶️) hoặc press **⌘R**

Xcode sẽ:
- Compile Swift code
- Build app
- Launch simulator
- Install app
- Run app

### Bước 8: Grant Permissions
Khi app chạy lần đầu:
1. Camera permission popup → Tap **Allow**
2. Photo library permission → Tap **Allow**
3. Camera preview sẽ hiện ra!

---

## Method 2: Command Line (Advanced)

Nếu muốn tự động hóa, có thể dùng `xcodegen` hoặc tạo `.pbxproj` file manually (phức tạp).

---

## Troubleshooting

### Lỗi: "No such module 'SwiftUI'"
- Xcode version phải >= 11.0
- Deployment target phải >= iOS 13.0

### Lỗi: Cannot find 'CameraViewModel' in scope
- Check tất cả Swift files đã được add vào target
- Project Navigator → Select file → File Inspector (⌘⌥1) → Target Membership ✅

### Camera không hiện
- Check simulator có camera không (iPhone 15 có)
- Check permissions đã granted
- Check console log (⌘⇧Y) để xem errors

### Build Failed
- Clean build folder: **Product → Clean Build Folder** (⇧⌘K)
- Quit Xcode và reopen
- Delete DerivedData: `~/Library/Developer/Xcode/DerivedData/CiraSwift-*`

---

## Keyboard Shortcuts

- **⌘R** - Run
- **⌘B** - Build
- **⌘.** - Stop
- **⇧⌘K** - Clean
- **⌘1** - Project Navigator
- **⌘0** - Hide/Show Navigator
- **⌘⇧Y** - Toggle Console

---

## Next Steps After First Build

1. Test camera capture
2. Test photo save
3. Test camera flip
4. Check tag selection UI
5. Verify glassmorphism effects

Enjoy building! 🎉
