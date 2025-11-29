//
//  CiraApp.swift
//  CiraSwift
//
//  Main app entry point
//

import SwiftUI

@main
struct CiraApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.light) // Force light mode
        }
    }
}
