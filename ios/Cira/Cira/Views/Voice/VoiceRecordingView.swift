//
//  VoiceRecordingView.swift
//  CiraSwift
//
//  Voice recording UI component for elderly users
//

import SwiftUI

struct VoiceRecordingView: View {
    @StateObject private var voiceService = VoiceRecordingService()
    @Binding var isPresented: Bool
    @Binding var recordedVoiceNote: VoiceNote?
    
    var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    if !voiceService.isRecording {
                        isPresented = false
                    }
                }
            
            VStack(spacing: 0) {
                Spacer()
                
                // Main recording card
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Text(voiceService.isRecording ? "Đang ghi âm..." : "Ghi lại câu chuyện")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        if !voiceService.isRecording {
                            Button(action: {
                                isPresented = false
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(Color.black.opacity(0.3))
                            }
                        }
                    }
                    
                    // Waveform / Audio Level Indicator
                    if voiceService.isRecording {
                        HStack(spacing: 4) {
                            ForEach(0..<20, id: \.self) { index in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.brandBlue)
                                    .frame(width: 3)
                                    .frame(height: waveformHeight(for: index))
                                    .animation(.easeInOut(duration: 0.2), value: voiceService.audioLevel)
                            }
                        }
                        .frame(height: 60)
                    } else {
                        // Microphone icon when not recording
                        Image(systemName: "mic.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color.brandBlue.opacity(0.3))
                            .frame(height: 80)
                    }
                    
                    // Duration
                    if voiceService.isRecording {
                        Text(formatDuration(voiceService.recordingDuration))
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(.black)
                            .monospacedDigit()
                    }
                    
                    // Transcription (real-time)
                    if !voiceService.transcribedText.isEmpty {
                        ScrollView {
                            Text(voiceService.transcribedText)
                                .font(.system(size: 16))
                                .foregroundColor(Color.black.opacity(0.7))
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.black.opacity(0.05))
                                )
                        }
                        .frame(maxHeight: 120)
                    }
                    
                    // Record / Stop Button
                    Button(action: {
                        if voiceService.isRecording {
                            stopRecording()
                        } else {
                            startRecording()
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: voiceService.isRecording ? "stop.fill" : "mic.fill")
                                .font(.system(size: 24))
                            
                            Text(voiceService.isRecording ? "Dừng ghi" : "Bắt đầu ghi")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(voiceService.isRecording ? Color.red : Color.brandBlue)
                        )
                    }
                    
                    // Instructions for elderly
                    if !voiceService.isRecording {
                        Text("💡 Nhấn nút ghi và kể câu chuyện của bạn")
                            .font(.system(size: 14))
                            .foregroundColor(Color.black.opacity(0.5))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 20, y: 10)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            Task {
                await voiceService.requestPermissions()
            }
        }
    }
    
    // MARK: - Waveform Animation
    private func waveformHeight(for index: Int) -> CGFloat {
        let baseHeight: CGFloat = 8
        let maxHeight: CGFloat = 60
        
        // Create animated wave based on audio level
        let phase = Double(index) * 0.3
        let animationOffset = sin(Date().timeIntervalSinceReferenceDate * 3 + phase)
        let levelMultiplier = CGFloat(voiceService.audioLevel) * 0.8 + 0.2
        
        return baseHeight + (maxHeight - baseHeight) * levelMultiplier * CGFloat(abs(animationOffset))
    }
    
    // MARK: - Actions
    private func startRecording() {
        Task { @MainActor in
            voiceService.startRecording()
        }
    }
    
    private func stopRecording() {
        Task { @MainActor in
            if let url = voiceService.stopRecording() {
                // Create VoiceNote model
                let voiceNote = VoiceNote(
                    audioURL: url.path,
                    duration: voiceService.recordingDuration,
                    transcribedText: voiceService.transcribedText.isEmpty ? nil : voiceService.transcribedText
                )
                recordedVoiceNote = voiceNote
                isPresented = false
            }
        }
    }
    
    // MARK: - Helpers
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    VoiceRecordingView(
        isPresented: .constant(true),
        recordedVoiceNote: .constant(nil)
    )
}
