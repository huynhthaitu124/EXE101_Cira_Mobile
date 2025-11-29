//
//  StoryCreatorModels.swift
//  Cira
//
//  Data models for Story Creator feature
//  Enables creating stories from photos with AI narration
//

import SwiftUI
import Photos

// MARK: - Story Photo
/// Represents a photo with its description for story creation
struct StoryPhoto: Identifiable, Equatable {
    let id = UUID()
    let image: UIImage
    let asset: PHAsset?
    var description: String
    var audioURL: URL?
    var order: Int
    let createdAt: Date
    
    init(image: UIImage, asset: PHAsset? = nil, description: String = "", order: Int = 0) {
        self.image = image
        self.asset = asset
        self.description = description
        self.order = order
        self.createdAt = Date()
    }
    
    static func == (lhs: StoryPhoto, rhs: StoryPhoto) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Story Draft
/// Represents a story being created or saved
struct StoryDraft: Identifiable {
    let id = UUID()
    var title: String
    var photos: [StoryPhoto]
    var generatedStory: String?
    var audioURL: URL?
    var voiceStyle: VoiceStyle
    var status: StoryStatus
    let createdAt: Date
    var updatedAt: Date
    
    init(
        title: String = "",
        photos: [StoryPhoto] = [],
        voiceStyle: VoiceStyle = .warm
    ) {
        self.title = title
        self.photos = photos
        self.voiceStyle = voiceStyle
        self.status = .draft
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    var photoCount: Int { photos.count }
    var hasDescriptions: Bool { photos.contains { !$0.description.isEmpty } }
}

// MARK: - Story Status
enum StoryStatus: String, CaseIterable {
    case draft = "Draft"
    case processing = "Processing"
    case ready = "Ready"
    case saved = "Saved"
    
    var icon: String {
        switch self {
        case .draft: return "doc.text"
        case .processing: return "wand.and.stars"
        case .ready: return "checkmark.circle"
        case .saved: return "bookmark.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .draft: return Color(hex: "#95A5A6")
        case .processing: return Color(hex: "#F39C12")
        case .ready: return Color(hex: "#27AE60")
        case .saved: return Color(hex: "#3498DB")
        }
    }
}

// MARK: - Voice Style
/// Available voice styles for story narration
enum VoiceStyle: String, CaseIterable, Identifiable {
    case warm = "Warm & Gentle"
    case storyteller = "Classic Storyteller"
    case cheerful = "Cheerful & Bright"
    case calm = "Calm & Soothing"
    case custom = "Family Voice (Premium)"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .warm: return "Ấm áp"
        case .storyteller: return "Kể chuyện"
        case .cheerful: return "Vui vẻ"
        case .calm: return "Bình yên"
        case .custom: return "Giọng gia đình"
        }
    }
    
    var icon: String {
        switch self {
        case .warm: return "heart.fill"
        case .storyteller: return "book.fill"
        case .cheerful: return "sun.max.fill"
        case .calm: return "moon.fill"
        case .custom: return "star.fill"
        }
    }
    
    var description: String {
        switch self {
        case .warm: return "Giọng ấm áp, dịu dàng cho kỷ niệm gia đình"
        case .storyteller: return "Giọng kể chuyện truyền thống với điệu bộ kịch tính"
        case .cheerful: return "Giọng vui vẻ, tràn đầy năng lượng cho những khoảnh khắc hạnh phúc"
        case .calm: return "Giọng bình yên cho những câu chuyện chiêm nghiệm"
        case .custom: return "Nhân bản giọng nói người thân để tạo cảm giác gần gũi"
        }
    }
    
    var color: Color {
        switch self {
        case .warm: return Color(hex: "#E74C3C")
        case .storyteller: return Color(hex: "#9B59B6")
        case .cheerful: return Color(hex: "#F39C12")
        case .calm: return Color(hex: "#3498DB")
        case .custom: return Color(hex: "#27AE60")
        }
    }
    
    var isPremium: Bool {
        self == .custom
    }
}

// MARK: - Creation Step
/// Steps in the story creation flow
enum StoryCreationStep: Int, CaseIterable {
    case selectPhotos = 0
    case addDescriptions = 1
    case chooseVoice = 2
    case preview = 3
    
    var title: String {
        switch self {
        case .selectPhotos: return "Chọn ảnh"
        case .addDescriptions: return "Mô tả"
        case .chooseVoice: return "Giọng đọc"
        case .preview: return "Xem trước"
        }
    }
    
    var subtitle: String {
        switch self {
        case .selectPhotos: return "Choose photos for your story"
        case .addDescriptions: return "Describe each moment"
        case .chooseVoice: return "Pick a narration style"
        case .preview: return "Review your story"
        }
    }
    
    var icon: String {
        switch self {
        case .selectPhotos: return "photo.on.rectangle.angled"
        case .addDescriptions: return "text.bubble"
        case .chooseVoice: return "waveform"
        case .preview: return "play.circle"
        }
    }
}

// MARK: - Mock Generated Stories
extension StoryDraft {
    /// Generates a mock AI story based on photo descriptions
    static func generateMockStory(from photos: [StoryPhoto]) -> String {
        let descriptions = photos
            .sorted { $0.order < $1.order }
            .compactMap { $0.description.isEmpty ? nil : $0.description }
        
        if descriptions.isEmpty {
            return """
            Đây là một câu chuyện về những khoảnh khắc đáng nhớ trong cuộc sống. 
            Mỗi bức ảnh là một mảnh ghép của ký ức, kết nối chúng ta với những người thân yêu.
            Hãy để những hình ảnh này kể câu chuyện của riêng bạn...
            """
        }
        
        var story = "Trong những khoảnh khắc quý giá của cuộc sống, có những câu chuyện đáng được kể lại.\n\n"
        
        for (index, desc) in descriptions.enumerated() {
            let connector = index == 0 ? "Bắt đầu với" : ["Tiếp theo,", "Rồi,", "Sau đó,", "Và rồi,"].randomElement()!
            story += "\(connector) \(desc.lowercased()). "
            
            if index < descriptions.count - 1 {
                story += "\n\n"
            }
        }
        
        story += "\n\nĐây là những ký ức mà chúng ta sẽ mãi trân trọng, những khoảnh khắc định hình nên câu chuyện gia đình của chúng ta."
        
        return story
    }
}
