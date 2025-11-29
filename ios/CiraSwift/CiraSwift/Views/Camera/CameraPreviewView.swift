//
//  CameraPreviewView.swift
//  CiraSwift
//
//  UIViewRepresentable wrapper for AVCaptureVideoPreviewLayer
//

import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            previewLayer.frame = uiView.bounds
        }
    }
}
