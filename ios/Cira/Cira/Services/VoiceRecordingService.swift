//
//  VoiceRecordingService.swift
//  CiraSwift
//
//  Service for voice recording with AVAudioRecorder
//

import AVFoundation
import Speech
import Combine

class VoiceRecordingService: NSObject, ObservableObject {
    // MARK: - Published State
    @Published @MainActor var isRecording = false
    @Published @MainActor var audioLevel: Float = 0.0
    @Published @MainActor var recordingDuration: TimeInterval = 0
    @Published @MainActor var transcribedText: String = ""
    
    // MARK: - Permissions
    @Published @MainActor var microphonePermissionGranted = false
    @Published @MainActor var speechRecognitionPermissionGranted = false
    
    // MARK: - Private Properties
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    private var audioLevelTimer: Timer?
    private var durationTimer: Timer?
    
    // Speech recognition
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "vi-VN")) // Vietnamese
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupAudioSession()
    }
    
    // MARK: - Audio Session Setup
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    // MARK: - Permissions
    func requestPermissions() async {
        // Microphone permission
        if #available(iOS 17.0, *) {
            let micStatus = AVAudioApplication.shared.recordPermission
            if micStatus == .undetermined {
                let granted = await withCheckedContinuation { continuation in
                    AVAudioApplication.requestRecordPermission { granted in
                        continuation.resume(returning: granted)
                    }
                }
                await MainActor.run {
                    self.microphonePermissionGranted = granted
                }
            } else {
                await MainActor.run {
                    self.microphonePermissionGranted = micStatus == .granted
                }
            }
        } else {
            let micStatus = AVAudioSession.sharedInstance().recordPermission
            if micStatus == .undetermined {
                let granted = await withCheckedContinuation { continuation in
                    AVAudioSession.sharedInstance().requestRecordPermission { granted in
                        continuation.resume(returning: granted)
                    }
                }
                await MainActor.run {
                    self.microphonePermissionGranted = granted
                }
            } else {
                await MainActor.run {
                    self.microphonePermissionGranted = micStatus == .granted
                }
            }
        }
        
        // Speech recognition permission
        let speechStatus = SFSpeechRecognizer.authorizationStatus()
        if speechStatus == .notDetermined {
            let status = await withCheckedContinuation { continuation in
                SFSpeechRecognizer.requestAuthorization { status in
                    continuation.resume(returning: status)
                }
            }
            await MainActor.run {
                self.speechRecognitionPermissionGranted = status == .authorized
            }
        } else {
            await MainActor.run {
                self.speechRecognitionPermissionGranted = speechStatus == .authorized
            }
        }
    }
    
    // MARK: - Start Recording
    @MainActor
    func startRecording() {
        guard microphonePermissionGranted else {
            print("Microphone permission not granted")
            return
        }
        
        // Create recording URL
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let timestamp = Date().timeIntervalSince1970
        recordingURL = documentsPath.appendingPathComponent("voice_\(timestamp).m4a")
        
        guard let url = recordingURL else { return }
        
        // Recording settings
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            isRecording = true
            recordingDuration = 0
            
            // Start monitoring audio level
            startAudioLevelMonitoring()
            startDurationTimer()
            
            // Start speech recognition if enabled
            if speechRecognitionPermissionGranted {
                startSpeechRecognition()
            }
            
        } catch {
            print("Failed to start recording: \(error)")
        }
    }
    
    // MARK: - Stop Recording
    @MainActor
    func stopRecording() -> URL? {
        audioRecorder?.stop()
        isRecording = false
        
        stopAudioLevelMonitoring()
        stopDurationTimer()
        stopSpeechRecognition()
        
        return recordingURL
    }
    
    // MARK: - Audio Level Monitoring
    private func startAudioLevelMonitoring() {
        audioLevelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.audioRecorder?.updateMeters()
            let level = self.audioRecorder?.averagePower(forChannel: 0) ?? -160
            // Convert to 0-1 range (dB to linear)
            let normalizedLevel = pow(10, level / 20)
            Task { @MainActor in
                self.audioLevel = normalizedLevel
            }
        }
    }
    
    private func stopAudioLevelMonitoring() {
        audioLevelTimer?.invalidate()
        audioLevelTimer = nil
        Task { @MainActor in
            self.audioLevel = 0
        }
    }
    
    // MARK: - Duration Timer
    private func startDurationTimer() {
        durationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                self.recordingDuration = self.audioRecorder?.currentTime ?? 0
            }
        }
    }
    
    private func stopDurationTimer() {
        durationTimer?.invalidate()
        durationTimer = nil
    }
    
    // MARK: - Speech Recognition
    private func startSpeechRecognition() {
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            print("Speech recognizer not available")
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Audio engine setup
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            
            recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                if let result = result {
                    Task { @MainActor in
                        self?.transcribedText = result.bestTranscription.formattedString
                    }
                }
                
                if error != nil || result?.isFinal == true {
                    self?.stopSpeechRecognition()
                }
            }
        } catch {
            print("Failed to start speech recognition: \(error)")
        }
    }
    
    private func stopSpeechRecognition() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
    }
    
    // MARK: - Playback
    func playRecording(url: URL, completion: @escaping () -> Void) {
        // TODO: Implement audio playback with AVAudioPlayer
    }
}

// MARK: - AVAudioRecorderDelegate
extension VoiceRecordingService: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("Recording finished successfully")
        } else {
            print("Recording failed")
        }
    }
}
