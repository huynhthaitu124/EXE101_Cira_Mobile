# Core Data Model Setup Guide

## Cách thêm Core Data Model vào Xcode Project

### Bước 1: Tạo Data Model File

1. **Mở Xcode** → Select target **Cira**
2. **File → New → File** (⌘N)
3. Trong template selector:
   - Chọn **iOS** (hoặc watchOS/tvOS)
   - Scroll xuống section **Core Data**
   - Click **Data Model**
   - Click **Next**

4. Đặt tên file:
   - **Save As**: `CiraModel`
   - **Group**: Cira (hoặc Services folder)
   - **Targets**: ✅ Cira
   - Click **Create**

Xcode sẽ tạo file `CiraModel.xcdatamodeld`

---

### Bước 2: Tạo Entities

Sau khi file được tạo, Xcode sẽ mở Data Model Editor:

#### 2.1 Tạo PhotoEntity

1. Click nút **"Add Entity"** (dưới cùng bên trái, dấu +)
2. Đổi tên từ "Entity" → **PhotoEntity**
3. Click **"Add Attribute"** và thêm các attributes:

| Attribute Name   | Type          | Optional | Default Value |
|-----------------|---------------|----------|---------------|
| id              | UUID          | NO       |               |
| imageURL        | String        | YES      |               |
| dominantColor   | String        | YES      |               |
| tags            | Transformable | YES      |               |
| caption         | String        | YES      |               |
| timestamp       | Date          | YES      |               |
| chapterId       | String        | YES      |               |
| thumbnailURL    | String        | YES      |               |

**Quan trọng cho `tags` attribute:**
- Type: **Transformable**
- Click vào "tags" attribute
- Trong **Data Model Inspector** (⌥⌘3):
  - **Custom Class**: `[String]`
  - **Transformer**: `NSSecureUnarchiveFromData`

#### 2.2 Tạo ChapterEntity

1. Click **"Add Entity"** lần nữa
2. Đổi tên → **ChapterEntity**
3. Thêm attributes:

| Attribute Name      | Type       | Optional | Default Value |
|--------------------|------------|----------|---------------|
| id                 | UUID       | NO       |               |
| title              | String     | YES      |               |
| chapterDescription | String     | YES      |               |
| icon               | String     | YES      |               |
| coverColor         | String     | YES      |               |
| coverImageURL      | String     | YES      |               |
| createdAt          | Date       | YES      |               |
| photoCount         | Integer 32 | YES      | 0             |
| isFavorite         | Boolean    | YES      | NO            |
| author             | String     | YES      |               |
| authorInitial      | String     | YES      |               |

#### 2.3 Tạo VoiceNoteEntity

1. Click **"Add Entity"**
2. Đổi tên → **VoiceNoteEntity**
3. Thêm attributes:

| Attribute Name   | Type   | Optional | Default Value |
|-----------------|--------|----------|---------------|
| id              | UUID   | NO       |               |
| audioURL        | String | YES      |               |
| duration        | Double | YES      | 0.0           |
| transcribedText | String | YES      |               |
| timestamp       | Date   | YES      |               |
| photoId         | UUID   | YES      |               |

---

### Bước 3: Tạo Relationships

#### 3.1 PhotoEntity ↔ ChapterEntity

**Trong PhotoEntity:**
1. Click tab **"Relationships"** (cạnh Attributes)
2. Click **"+"** để add relationship
3. Cấu hình:
   - **Name**: `chapter`
   - **Destination**: ChapterEntity
   - **Inverse**: (chưa set, sẽ set ở bước sau)
   - **Type**: To One
   - **Delete Rule**: Nullify
   - **Optional**: YES

**Trong ChapterEntity:**
1. Click tab **"Relationships"**
2. Click **"+"**
3. Cấu hình:
   - **Name**: `photos`
   - **Destination**: PhotoEntity
   - **Inverse**: chapter (chọn từ dropdown)
   - **Type**: To Many
   - **Delete Rule**: Cascade
   - **Optional**: YES

#### 3.2 PhotoEntity ↔ VoiceNoteEntity

**Trong PhotoEntity:**
1. Add relationship:
   - **Name**: `voiceNoteEntity`
   - **Destination**: VoiceNoteEntity
   - **Type**: To One
   - **Delete Rule**: Cascade
   - **Optional**: YES

**Trong VoiceNoteEntity:**
1. Add relationship:
   - **Name**: `photo`
   - **Destination**: PhotoEntity
   - **Inverse**: voiceNoteEntity
   - **Type**: To One
   - **Delete Rule**: Nullify
   - **Optional**: YES

---

### Bước 4: Configure Codegen

Cho mỗi entity (PhotoEntity, ChapterEntity, VoiceNoteEntity):

1. Select entity trong list
2. Mở **Data Model Inspector** (⌥⌘3)
3. Set **Codegen**: **Class Definition**

Xcode sẽ tự động generate class code.

---

### Bước 5: Verify

1. **Build project** (⌘B)
2. Check không có errors
3. Xcode sẽ generate:
   - `PhotoEntity+CoreDataClass.swift`
   - `PhotoEntity+CoreDataProperties.swift`
   - (tương tự cho Chapter và VoiceNote)

---

## Troubleshooting

### Lỗi: "Cannot find 'PhotoEntity' in scope"

**Fix:**
1. Clean build folder: **⇧⌘K**
2. Delete DerivedData:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/Cira-*
   ```
3. Build lại: **⌘B**

### Lỗi: "Failed to load model named 'CiraModel'"

**Check:**
- File `CiraModel.xcdatamodeld` có trong project navigator không?
- Target membership: File có được add vào target "Cira" không?
  - Select file → File Inspector → Target Membership ✅

### Lỗi với Transformable attribute (tags)

**Fix:**
- Trong Data Model Inspector cho `tags` attribute:
  - Custom Class: `[String]`
  - Transformer: `NSSecureUnarchiveFromData`
  - Module: (leave empty)

---

## Alternative: Import từ file đã tạo

Nếu bạn muốn import file `.xcdatamodel/contents` mà tôi đã tạo:

1. Tạo folder structure:
   ```bash
   cd /Users/huynh/Projects/Cira/ios/Cira/Cira/
   mkdir -p CiraModel.xcdatamodeld/CiraModel.xcdatamodel
   ```

2. File `contents` đã có ở:
   `/Users/huynh/Projects/Cira/ios/Cira/Cira/CiraModel.xcdatamodeld/CiraModel.xcdatamodel/contents`

3. Trong Xcode:
   - Right-click folder "Cira" trong navigator
   - **Add Files to "Cira"...**
   - Navigate to `CiraModel.xcdatamodeld`
   - ✅ Copy items if needed
   - ✅ Add to target: Cira
   - Click **Add**

4. Xcode sẽ nhận ra đây là Core Data model file

---

## Keyboard Shortcuts

- **⌘N** - New file
- **⌥⌘3** - Data Model Inspector
- **⌘B** - Build
- **⇧⌘K** - Clean build

Sau khi setup xong, PersistenceController sẽ load model thành công! 🎉
