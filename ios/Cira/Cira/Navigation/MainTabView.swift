//
//  MainTabView.swift
//  CiraSwift
//
//  Main navigation (no tab bar - uses NavigationStack)
//

import SwiftUI
import Combine

struct MainTabView: View {
    @StateObject private var cameraViewModel = CameraViewModel()
    @StateObject private var galleryViewModel = GalleryViewModel()
    @StateObject private var navigationManager = NavigationManager()
    
    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            DashboardView()
                .environmentObject(galleryViewModel)
                .environmentObject(navigationManager)
                .navigationDestination(for: AppScreen.self) { screen in
                    destinationView(for: screen)
                }
        }
        .environmentObject(cameraViewModel)
        .environmentObject(galleryViewModel)
        .environmentObject(navigationManager)
    }
    
    @ViewBuilder
    private func destinationView(for screen: AppScreen) -> some View {
        switch screen {
        case .camera:
            CameraView()
                .environmentObject(cameraViewModel)
        case .gallery:
            GalleryView()
                .environmentObject(galleryViewModel)
        case .profile:
            ProfileView()
        case .notifications:
            NotificationsView()
        case .feed:
            FeedView()
        case .messages:
            MessagesView()
        case .settings:
            SettingsView()
        case .search:
            SearchView()
        case .calendar:
            CalendarView()
        case .storyCreator:
            StoryCreatorView()
        }
    }
}

// MARK: - Navigation Manager
class NavigationManager: ObservableObject {
    @Published var path = NavigationPath()
    
    func navigate(to screen: AppScreen) {
        path.append(screen)
    }
    
    func goBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func goToRoot() {
        path = NavigationPath()
    }
}

// MARK: - App Screens
enum AppScreen: Hashable {
    case camera
    case gallery
    case profile
    case notifications
    case feed
    case messages
    case settings
    case search
    case calendar
    case storyCreator
}

#Preview {
    MainTabView()
}
