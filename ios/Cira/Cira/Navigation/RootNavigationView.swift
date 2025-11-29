//
//  RootNavigationView.swift
//  CiraSwift
//
//  Main navigation container (replaces AppNavigator.tsx)
//

import SwiftUI

struct RootNavigationView: View {
    @State private var selectedView: AppView = .camera
    
    enum AppView {
        case camera, gallery, feed, profile
    }
    
    var body: some View {
        NavigationStack {
            switch selectedView {
            case .camera:
                CameraView()
            case .gallery:
                GalleryView()
            case .feed, .profile:
                Text("Coming soon")
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    RootNavigationView()
        .environmentObject(CameraViewModel())
        .environmentObject(GalleryViewModel())
}
