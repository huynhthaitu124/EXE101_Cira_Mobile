//
//  StoryCreatorViewModel.swift
//  Cira
//
//  ViewModel for Story Creator feature
//  Handles photo selection, voice recording, and AI story generation
//

import SwiftUI
import Photos
import Combine
import AVFoundation

// MARK: - Photo Group Model
struct PhotoGroup: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
    var photos: [PHAsset]
}

@MainActor
class StoryCreatorViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentStep: StoryCreationStep = .selectPhotos
    @Published var storyDraft = StoryDraft()
    @Published var selectedPhotos: [StoryPhoto] = []
    @Published var currentPhotoIndex: Int = 0
    @Published var isRecording = false
    @Published var recordingTime: TimeInterval = 0
    @Published var isProcessing = false
    @Published var isPlaying = false
    @Published var playbackProgress: Double = 0
    @Published var showPhotoLibrary = false
    @Published var showVoiceRecorder = false
    @Published var errorMessage: String?
    @Published var photoLibraryAuthorized = false
    
    // New properties for photo library
    @Published var photoGroups: [PhotoGroup] = []
    @Published var isLoadingLibrary = false
    @Published private var selectedAssetIds: Set<String> = []
    
    // MARK: - Private Properties
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingTimer: Timer?
    private var playbackTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var canProceedToNextStep: Bool {
        switch currentStep {
        case .selectPhotos:
            return selectedPhotos.count >= 2
        case .addDescriptions:
            return selectedPhotos.contains { !$0.description.isEmpty }
        case .chooseVoice:
            return true
        case .preview:
            return storyDraft.generatedStory != nil
        }
    }
    
    var progressPercentage: Double {
        Double(currentStep.rawValue + 1) / Double(StoryCreationStep.allCases.count)
    }
    
    var currentPhoto: StoryPhoto? {
        guard currentPhotoIndex < selectedPhotos.count else { return nil }
        return selectedPhotos[currentPhotoIndex]
    }
    
    // MARK: - Initialization
    init() {
        checkPhotoLibraryPermission()
        setupAudioSession()
    }
    
    // MARK: - Permission Handling
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            photoLibraryAuthorized = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                DispatchQueue.main.async {
                    self?.photoLibraryAuthorized = status == .authorized || status == .limited
                }
            }
        default:
            photoLibraryAuthorized = false
        }
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    // MARK: - Photo Library Loading
    func loadPhotoLibrary() {
        guard photoLibraryAuthorized else {
            checkPhotoLibraryPermission()
            return
        }
        
        isLoadingLibrary = true
        
        Task {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            
            let assets = PHAsset.fetchAssets(with: fetchOptions)
            var groupedPhotos: [String: (date: Date, assets: [PHAsset])] = [:]
            
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "vi_VN")
            
            assets.enumerateObjects { asset, _, _ in
                guard let creationDate = asset.creationDate else { return }
                
                let startOfDay = calendar.startOfDay(for: creationDate)
                let key: String
                
                if calendar.isDate(startOfDay, inSameDayAs: today) {
                    key = "Hôm nay"
                } else if calendar.isDate(startOfDay, inSameDayAs: yesterday) {
                    key = "Hôm qua"
                } else if calendar.isDate(startOfDay, equalTo: today, toGranularity: .weekOfYear) {
                    dateFormatter.dateFormat = "EEEE"
                    key = dateFormatter.string(from: creationDate).capitalized
                } else if calendar.isDate(startOfDay, equalTo: today, toGranularity: .year) {
                    dateFormatter.dateFormat = "d MMMM"
                    key = dateFormatter.string(from: creationDate)
                } else {
                    dateFormatter.dateFormat = "d MMMM, yyyy"
                    key = dateFormatter.string(from: creationDate)
                }
                
                if groupedPhotos[key] == nil {
                    groupedPhotos[key] = (date: startOfDay, assets: [])
                }
                groupedPhotos[key]?.assets.append(asset)
            }
            
            // Sort groups by date (most recent first)
            let sortedGroups = groupedPhotos
                .map { PhotoGroup(title: $0.key, date: $0.value.date, photos: $0.value.assets) }
                .sorted { $0.date > $1.date }
            
            await MainActor.run {
                self.photoGroups = sortedGroups
                self.isLoadingLibrary = false
            }
        }
    }
    
    // MARK: - Navigation
    func nextStep() {
        guard let nextStep = StoryCreationStep(rawValue: currentStep.rawValue + 1) else {
            return
        }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentStep = nextStep
        }
        
        // Generate story when entering preview step
        if nextStep == .preview {
            generateStory()
        }
    }
    
    func previousStep() {
        guard let prevStep = StoryCreationStep(rawValue: currentStep.rawValue - 1) else {
            return
        }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentStep = prevStep
        }
    }
    
    func goToStep(_ step: StoryCreationStep) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentStep = step
        }
    }
    
    // MARK: - Photo Management
    func addPhoto(_ image: UIImage, asset: PHAsset? = nil) {
        let photo = StoryPhoto(
            image: image,
            asset: asset,
            order: selectedPhotos.count
        )
        selectedPhotos.append(photo)
        if let asset = asset {
            selectedAssetIds.insert(asset.localIdentifier)
        }
        updateDraft()
    }
    
    func removePhoto(at index: Int) {
        guard index < selectedPhotos.count else { return }
        let photo = selectedPhotos[index]
        if let asset = photo.asset {
            selectedAssetIds.remove(asset.localIdentifier)
        }
        selectedPhotos.remove(at: index)
        reorderPhotos()
        updateDraft()
        
        if currentPhotoIndex >= selectedPhotos.count {
            currentPhotoIndex = max(0, selectedPhotos.count - 1)
        }
    }
    
    func togglePhotoSelection(_ asset: PHAsset) {
        if selectedAssetIds.contains(asset.localIdentifier) {
            // Remove from selection
            if let index = selectedPhotos.firstIndex(where: { $0.asset?.localIdentifier == asset.localIdentifier }) {
                removePhoto(at: index)
            }
        } else {
            // Add to selection - load full image
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isSynchronous = true
            
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: CGSize(width: 800, height: 800),
                contentMode: .aspectFit,
                options: options
            ) { [weak self] image, _ in
                if let image = image {
                    self?.addPhoto(image, asset: asset)
                }
            }
        }
    }
    
    func isPhotoSelected(_ asset: PHAsset) -> Bool {
        selectedAssetIds.contains(asset.localIdentifier)
    }
    
    func getSelectionOrder(for asset: PHAsset) -> Int? {
        if let index = selectedPhotos.firstIndex(where: { $0.asset?.localIdentifier == asset.localIdentifier }) {
            return index + 1
        }
        return nil
    }
    
    func setDescriptionForAll(_ description: String) {
        for index in selectedPhotos.indices {
            selectedPhotos[index].description = description
        }
        updateDraft()
    }
    
    func movePhoto(from source: IndexSet, to destination: Int) {
        selectedPhotos.move(fromOffsets: source, toOffset: destination)
        reorderPhotos()
        updateDraft()
    }
    
    private func reorderPhotos() {
        for (index, _) in selectedPhotos.enumerated() {
            selectedPhotos[index].order = index
        }
    }
    
    func updateDescription(_ description: String, for photoId: UUID) {
        if let index = selectedPhotos.firstIndex(where: { $0.id == photoId }) {
            selectedPhotos[index].description = description
            updateDraft()
        }
    }
    
    func selectPhoto(at index: Int) {
        guard index < selectedPhotos.count else { return }
        currentPhotoIndex = index
    }
    
    // MARK: - Voice Recording
    func startRecording() {
        let audioFilename = FileManager.default.temporaryDirectory
            .appendingPathComponent("voice_\(UUID().uuidString).m4a")
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            isRecording = true
            recordingTime = 0
            
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                self?.recordingTime += 0.1
            }
        } catch {
            errorMessage = "Could not start recording"
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        recordingTimer?.invalidate()
        
        if let url = audioRecorder?.url, currentPhotoIndex < selectedPhotos.count {
            selectedPhotos[currentPhotoIndex].audioURL = url
            
            // Simulate speech-to-text conversion
            simulateSpeechToText()
        }
    }
    
    private func simulateSpeechToText() {
        // Mock speech-to-text - in production, use Speech framework
        let mockDescriptions = [
            "Đây là khoảnh khắc tuyệt vời bên gia đình",
            "Những nụ cười hạnh phúc trong ngày đặc biệt",
            "Kỷ niệm đáng nhớ mà chúng tôi sẽ mãi trân trọng",
            "Một ngày đẹp trời cùng những người thân yêu",
            "Niềm vui giản đơn từ những điều bình dị"
        ]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self, self.currentPhotoIndex < self.selectedPhotos.count else { return }
            if self.selectedPhotos[self.currentPhotoIndex].description.isEmpty {
                self.selectedPhotos[self.currentPhotoIndex].description = mockDescriptions.randomElement() ?? ""
                self.updateDraft()
            }
        }
    }
    
    // MARK: - Voice Style
    func selectVoiceStyle(_ style: VoiceStyle) {
        storyDraft.voiceStyle = style
    }
    
    // MARK: - Story Generation
    func generateStory() {
        isProcessing = true
        storyDraft.status = .processing
        
        // Simulate AI processing delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            guard let self = self else { return }
            
            self.storyDraft.generatedStory = StoryDraft.generateMockStory(from: self.selectedPhotos)
            self.storyDraft.status = .ready
            self.isProcessing = false
            
            // Simulate audio generation
            self.simulateAudioGeneration()
        }
    }
    
    private func simulateAudioGeneration() {
        // In production, this would call a TTS API
        // For now, we just mark it as ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.storyDraft.status = .ready
        }
    }
    
    // MARK: - Playback
    func togglePlayback() {
        if isPlaying {
            stopPlayback()
        } else {
            startPlayback()
        }
    }
    
    private func startPlayback() {
        isPlaying = true
        playbackProgress = 0
        
        // Simulate playback progress
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.playbackProgress += 0.01
            
            if self.playbackProgress >= 1 {
                self.stopPlayback()
            }
        }
    }
    
    private func stopPlayback() {
        isPlaying = false
        playbackTimer?.invalidate()
        audioPlayer?.stop()
    }
    
    // MARK: - Save & Export
    func saveStory() {
        storyDraft.status = .saved
        storyDraft.updatedAt = Date()
        // In production, save to Core Data or cloud
    }
    
    func reset() {
        currentStep = .selectPhotos
        selectedPhotos = []
        storyDraft = StoryDraft()
        currentPhotoIndex = 0
        isRecording = false
        isProcessing = false
        isPlaying = false
        playbackProgress = 0
    }
    
    // MARK: - Private Helpers
    private func updateDraft() {
        storyDraft.photos = selectedPhotos
        storyDraft.updatedAt = Date()
    }
}
