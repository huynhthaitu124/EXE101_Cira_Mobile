//
//  CameraView.swift
//  CiraSwift
//
//  Main camera view - matches HomeScreen.tsx with glassmorphism design
//

import SwiftUI

struct CameraView: View {
    @EnvironmentObject var viewModel: CameraViewModel
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // MARK: - Background (white)
                Color.white
                    .ignoresSafeEdges()
                
                // MARK: - Gradient + Blur Overlay (from RN line 292-331)
                if viewModel.capturedPhoto != nil {
                    VStack {
                        // Gradient overlay - top 65% (from RN line 295-315)
                        LinearGradient(
                            stops: [
                                .init(color: viewModel.dominantColor.opacity(0.35), location: 0.0),
                                .init(color: viewModel.dominantColor.opacity(0.25), location: 0.3),
                                .init(color: viewModel.dominantColor.opacity(0.15), location: 0.6),
                                .init(color: viewModel.dominantColor.opacity(0.08), location: 0.85),
                                .init(color: viewModel.dominantColor.opacity(0.0), location: 1.0),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: geometry.size.height * 0.65)
                        .overlay(
                            // Light blur (from RN line 316-329)
                            VisualEffectBlur(blurStyle: .systemUltraThinMaterialLight)
                        )
                        
                        Spacer()
                    }
                    .ignoresSafeEdges()
                }
                
                // MARK: - Main Content
                VStack(spacing: 0) {
                    // MARK: - Top Bar (from RN line 339-419)
                    HStack {
                        HStack(spacing: 8) {
                            GlassButton(icon: "arrow.left") {
                                // Navigate to Dashboard
                            }
                            GlassButton(icon: "person.circle") {
                                // Navigate to Profile
                            }
                            GlassButton(icon: "bell", hasBadge: true) {
                                // Navigate to Notifications
                            }
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            GlassButton(icon: "book") {
                                // Navigate to Gallery
                            }
                            GlassButton(icon: "message") {
                                // Navigate to Messages
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    
                    // MARK: - Camera/Photo Preview (from RN line 422-471)
                    Spacer()
                    
                    if let photo = viewModel.capturedPhoto {
                        // Show captured photo (from RN line 442-448)
                        Image(uiImage: photo)
                            .resizable()
                            .aspectRatio(3/4, contentMode: .fit)
                            .frame(maxWidth: 300)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(hex: "#333333"), lineWidth: 1)
                            )
                    } else if let previewLayer = viewModel.cameraService.previewLayer, viewModel.cameraPermissionGranted {
                        // Show live camera preview
                        CameraPreviewView(previewLayer: previewLayer)
                            .aspectRatio(3/4, contentMode: .fit)
                            .frame(maxWidth: 450)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(hex: "#333333"), lineWidth: 1)
                            )
                            .padding(.horizontal, 16)
                    } else {
                        // Camera permission placeholder (from RN line 458-469)
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hex: "#1A1A1A"))
                            .aspectRatio(3/4, contentMode: .fit)
                            .frame(maxWidth: 450)
                            .overlay(
                                VStack(spacing: 8) {
                                    Image(systemName: "camera")
                                        .font(.system(size: 64))
                                        .foregroundColor(Color(hex: "#555555"))
                                    
                                    Text(viewModel.cameraPermissionGranted ? "Loading camera..." : "Camera permission denied")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color(hex: "#777777"))
                                }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(hex: "#333333"), lineWidth: 1)
                            )
                            .padding(.horizontal, 16)
                    }
                    
                    Spacer()
                    
                    // MARK: - AI Suggested Tags (from RN line 474-514)
                    if viewModel.capturedPhoto != nil && !viewModel.suggestedTags.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Suggested tags:")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color.black.opacity(0.6))
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(viewModel.suggestedTags, id: \.self) { tag in
                                        TagButton(
                                            tag: tag,
                                            isSelected: viewModel.selectedTags.contains(tag)
                                        ) {
                                            viewModel.toggleTag(tag)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 12)
                    }
                    
                    // MARK: - Bottom Controls (from RN line 586-678)
                    HStack(spacing: 35) {
                        // Left button - Gallery
                        Button(action: {}) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.glassOverlay)
                                .frame(width: 42, height: 42)
                                .overlay(
                                    Image(systemName: "photo.on.rectangle")
                                        .font(.system(size: 20))
                                        .foregroundColor(.black)
                                )
                        }
                        
                        // Center button - Capture/Save (from RN line 603-652)
                        Button(action: {
                            if viewModel.capturedPhoto != nil {
                                Task {
                                    try? await viewModel.savePhoto()
                                }
                            } else {
                                // Trigger real camera capture
                                viewModel.takePictureFromCamera()
                            }
                        }) {
                            CameraShutterButton(isCaptured: viewModel.capturedPhoto != nil)
                        }
                        
                        // Right button - Flip/Retake (from RN line 657-676)
                        Button(action: {
                            if viewModel.capturedPhoto != nil {
                                viewModel.retakePhoto()
                            } else {
                                viewModel.toggleCameraPosition()
                            }
                        }) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.glassOverlay)
                                .frame(width: 42, height: 42)
                                .overlay(
                                    Image(systemName: viewModel.capturedPhoto != nil ? "xmark" : "camera.rotate")
                                        .font(.system(size: 20))
                                        .foregroundColor(.black)
                                )
                        }
                    }
                    .padding(.bottom, 12)
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

// MARK: - Glass Button Component
struct GlassButton: View {
    let icon: String
    var hasBadge: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(Color.glassOverlay)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: icon == "person.circle" ? 24 : 20))
                            .foregroundColor(.black)
                    )
                
                if hasBadge {
                    Circle()
                        .fill(Color(hex: "#E74C3C"))
                        .frame(width: 8, height: 8)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 1.5)
                        )
                        .offset(x: 2, y: -2)
                }
            }
        }
    }
}

// MARK: - Tag Button Component (from RN line 488-509)
struct TagButton: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(tag)
                .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? .white : .black)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.brandBlue : Color.glassOverlay)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isSelected ? Color.clear : Color.black.opacity(0.15), lineWidth: 1)
                        )
                )
        }
    }
}

// MARK: - Camera Shutter Button (from RN line 607-651)
struct CameraShutterButton: View {
    let isCaptured: Bool
    
    var body: some View {
        ZStack {
            // Outer black border
            Circle()
                .fill(Color.black)
                .frame(width: 74, height: 74)
            
            // White gap
            Circle()
                .fill(Color.white)
                .frame(width: 66, height: 66)
            
            // Inner gradient button
            if isCaptured {
                Circle()
                    .fill(Color.brandGreen)
                    .frame(width: 58, height: 58)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                    )
            } else {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.brandTeal, Color.brandBlue, Color.brandPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 58, height: 58)
            }
        }
    }
}

#Preview {
    CameraView()
        .environmentObject(CameraViewModel())
}
