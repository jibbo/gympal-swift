//
//  WatchConnectivityManager.swift
//  GymFocus Watch App
//
//  Created by Claude.
//
import SwiftUI
import Foundation
import WatchConnectivity

class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    @Published var savedTimers: [Double] = [30, 45, 60, 90, 120, 180, 240, 300] // Default timers
    @Published var currentTheme: String = "S" // Default theme
    
    private override init() {
        super.init()
        
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func requestDataFromPhone() {
        guard WCSession.default.isReachable else { return }
        
        WCSession.default.sendMessage(["request": "data"], replyHandler: { [weak self] reply in
            DispatchQueue.main.async {
                if let timersData = reply["timers"] as? Data,
                   let timers = try? JSONDecoder().decode([Double].self, from: timersData) {
                    self?.savedTimers = timers.isEmpty ? [60] : timers
                }
                
                if let theme = reply["theme"] as? String {
                    self?.currentTheme = theme
                }
            }
        }, errorHandler: { error in
            print("Failed to request data: \(error.localizedDescription)")
        })
    }
    
    // Maintain old method name for backward compatibility
    func requestTimersFromPhone() {
        requestDataFromPhone()
    }
    
    var themeColor: Color {
        WatchTheme.getThemeColor(for: currentTheme)
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            if activationState == .activated {
                self.requestDataFromPhone()
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        // Handle incoming messages from iPhone if needed
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            if let timersData = applicationContext["timers"] as? Data,
               let timers = try? JSONDecoder().decode([Double].self, from: timersData) {
                self.savedTimers = timers.isEmpty ? [60] : timers
            }
            
            if let theme = applicationContext["theme"] as? String {
                self.currentTheme = theme
            }
        }
    }
}
