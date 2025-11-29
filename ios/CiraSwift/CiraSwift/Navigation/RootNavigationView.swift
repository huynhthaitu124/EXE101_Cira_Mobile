//
//  RootNavigationView.swift
//  CiraSwift
//
//  Main navigation container (replaces AppNavigator.tsx)
//

import SwiftUI

struct RootNavigationView: View {
    @State private var selectedTab: Tab = .camera
    
    enum Tab {
        case camera, gallery, feed, profile
    }
    
    var body: some View {
        NavigationStack {
            CameraView()
                .navigationBarHidden(true)
        }
    }
}

#Preview {
    RootNavigationView()
        .environmentObject(CameraViewModel())
        .environmentObject(GalleryViewModel())
}
