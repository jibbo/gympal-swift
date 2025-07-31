//
//  GymFocusApp.swift
//  GymFocus
//
//  Created by Giovanni De Francesco on 14/07/25.
//

import SwiftUI
import SwiftData
import Firebase
import FirebaseCore
import FirebaseCrashlyticsSwift


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct GymPalApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var trackingManager = TrackingManager()
    @StateObject private var settings: Settings
    
    init() {
            let trackingManager = TrackingManager()
            self._trackingManager = StateObject(wrappedValue: trackingManager)
            self._settings = StateObject(wrappedValue: Settings(trackingManager: trackingManager))
            
            // Large title
            UINavigationBar.appearance().largeTitleTextAttributes = [
                .font: UIFont(name: Theme.fontName, size: 36)!
            ]
            // Inline title
            UINavigationBar.appearance().titleTextAttributes = [
                .font: UIFont(name: Theme.fontName, size: 20)!
            ]
        }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            WorkoutPlanItem.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
            // If container creation fails, try with in-memory storage as fallback
//            print("Failed to create persistent ModelContainer: \(error)")
//            let fallbackConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
//            do {
//                return try ModelContainer(for: schema, configurations: [fallbackConfiguration])
//            } catch {
//                fatalError("Could not create ModelContainer: \(error)")
//            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    PhoneConnectivityManager.shared.setModelContext(sharedModelContainer.mainContext)
                }
        }
        .modelContainer(sharedModelContainer)
        .environmentObject(settings)
        .environmentObject(trackingManager)
    }
}

