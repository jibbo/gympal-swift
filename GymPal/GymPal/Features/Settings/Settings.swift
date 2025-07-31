//
//  Settings.swift
//  GymFocus
//
//  Created by Giovanni De Francesco on 23/07/25.
//

import Foundation
import SwiftUI

final class Settings: ObservableObject {
    private var trackingManager: TrackingManager
    
    @Published var theme: String {
        didSet {
            UserDefaults.standard.set(theme, forKey: "theme")
            trackingManager.logSelectedTheme(theme: theme)
            // Notify watch of theme change
            PhoneConnectivityManager.shared.sendDataToWatch()
        }
    }
    
    @Published var metricSystem: Bool {didSet {UserDefaults.standard.set(metricSystem, forKey: "metricSystem")}}
    
    @Published var singlePage: Bool {
        didSet {
            UserDefaults.standard.set(singlePage, forKey: "singlePage")
            trackingManager.logSinglePageMode(isOn: singlePage)
        }
    }
    @Published var powerLifting: Bool {
        didSet {
            UserDefaults.standard.set(powerLifting, forKey: "powerLifting")
            trackingManager.logPowerliftingMode(isOn: powerLifting)
        }
    }
    
    let barsKg: [Int] = [7, 10, 15, 20]
    let barsLbs: [Int] = [15, 35, 45]
    
    @Published var selectedBar: Int {
        didSet {
            UserDefaults.standard.set(selectedBar, forKey: "selectedBar")
        }
    }
    
    init(trackingManager: TrackingManager = TrackingManager()) {
        self.trackingManager = trackingManager
        // Try to load from UserDefaults or set sensible defaults
        self.theme = UserDefaults.standard.string(forKey: "theme") ?? "S"
        
        if UserDefaults.standard.object(forKey: "metricSystem") != nil {
            self.metricSystem = UserDefaults.standard.bool(forKey: "metricSystem")
        } else {
            self.metricSystem = Locale.current.measurementSystem.identifier == "metric"
        }
        
        if UserDefaults.standard.object(forKey: "singlePage") != nil {
            self.singlePage = UserDefaults.standard.bool(forKey: "singlePage")
        } else {
            self.singlePage = true
        }
        
        self.powerLifting = UserDefaults.standard.bool(forKey: "powerLifting")
        
        if UserDefaults.standard.object(forKey: "selectedBar") != nil {
            self.selectedBar = UserDefaults.standard.integer(forKey: "selectedBar")
        } else {
            if Locale.current.measurementSystem.identifier != "metric" {
                self.selectedBar = barsLbs.last! // 45 lbs
            } else {
                self.selectedBar = barsKg.last! // 20 kg
            }
        }
    }
    
    func getThemeColor() -> Color {
        Theme.themes.first(where: { $0.key == theme })?.color ?? .primaryDefault
    }
}
