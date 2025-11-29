//
//  CiraApp.swift
//  CiraSwift
//
//  Created by Migration from React Native
//

import SwiftUI

@main
struct CiraApp: App {
    // MARK: - State Management
    @StateObject private var cameraViewModel = CameraViewModel()
    @StateObject private var galleryViewModel = GalleryViewModel()
    
    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(cameraViewModel)
                .environmentObject(galleryViewModel)
                .preferredColorScheme(.light) // Force light mode
        }
    }
}
