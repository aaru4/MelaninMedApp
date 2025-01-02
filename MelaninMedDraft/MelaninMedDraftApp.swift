//
//  MelaninMedDraftApp.swift
//  MelaninMedDraft
//
//  Created by Aarushi Ammavajjala on 8/19/24.
//

import SwiftUI
import SwiftData
import Foundation

@main
struct MelaninMedDraftApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
