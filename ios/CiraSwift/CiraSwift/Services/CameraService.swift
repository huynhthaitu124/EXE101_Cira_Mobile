//
//  CameraService.swift
//  CiraSwift
//
//  Service for AVFoundation camera functionality
//

import AVFoundation
import UIKit

@MainActor
class CameraService: NSObject, ObservableObject {
    // MARK: - Published State
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    @Published var isSessionRunning = false
    
    // MARK: - Private Properties
    private let captureSession = AVCaptureSession()
    private var videoDeviceInput: AVCaptureDeviceInput?
    private let photoOutput = AVCapturePhotoOutput()
    private var photoCaptureCompletion: ((UIImage?) -> Void)?
    
    private let sessionQueue = DispatchQueue(label: "com.cira.camera.session")
    
    override init() {
        super.init()
    }
    
    // MARK: - Setup Camera
    func setupCamera(position: AVCaptureDevice.Position = .back) {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .photo
            
            // Add video input
            do {
                guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else {
                    print("Failed to get camera device")
                    return
                }
                
                let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                
                if self.captureSession.canAddInput(videoDeviceInput) {
                    self.captureSession.addInput(videoDeviceInput)
                    self.videoDeviceInput = videoDeviceInput
                } else {
                    print("Cannot add video input")
                    return
                }
            } catch {
                print("Error creating video device input: \(error)")
                return
            }
            
            // Add photo output
            if self.captureSession.canAddOutput(self.photoOutput) {
                self.captureSession.addOutput(self.photoOutput)
                self.photoOutput.maxPhotoQualityPrioritization = .balanced
            } else {
                print("Cannot add photo output")
                return
            }
            
            self.captureSession.commitConfiguration()
            
            // Create preview layer
            Task { @MainActor in
                let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                previewLayer.videoGravity = .resizeAspectFill
                self.previewLayer = previewLayer
            }
        }
    }
    
    // MARK: - Start/Stop Session
    func startSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
                Task { @MainActor in
                    self.isSessionRunning = true
                }
            }
        }
    }
    
    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
                Task { @MainActor in
                    self.isSessionRunning = false
                }
            }
        }
    }
    
    // MARK: - Flip Camera
    func flipCamera(to position: AVCaptureDevice.Position) {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.captureSession.beginConfiguration()
            
            // Remove current input
            if let currentInput = self.videoDeviceInput {
                self.captureSession.removeInput(currentInput)
            }
            
            // Add new input
            do {
                guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else {
                    print("Failed to get camera device for position: \(position)")
                    return
                }
                
                let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                
                if self.captureSession.canAddInput(videoDeviceInput) {
                    self.captureSession.addInput(videoDeviceInput)
                    self.videoDeviceInput = videoDeviceInput
                }
            } catch {
                print("Error flipping camera: \(error)")
            }
            
            self.captureSession.commitConfiguration()
        }
    }
    
    // MARK: - Capture Photo
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        sessionQueue.async { [weak self] in
            guard let self = self else {
                completion(nil)
                return
            }
            
            self.photoCaptureCompletion = completion
            
            let settings = AVCapturePhotoSettings()
            settings.flashMode = .off
            
            if let photoOutputConnection = self.photoOutput.connection(with: .video) {
                photoOutputConnection.videoOrientation = .portrait
            }
            
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraService: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            Task { @MainActor in
                self.photoCaptureCompletion?(nil)
                self.photoCaptureCompletion = nil
            }
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            Task { @MainActor in
                self.photoCaptureCompletion?(nil)
                self.photoCaptureCompletion = nil
            }
            return
        }
        
        Task { @MainActor in
            self.photoCaptureCompletion?(image)
            self.photoCaptureCompletion = nil
        }
    }
}
