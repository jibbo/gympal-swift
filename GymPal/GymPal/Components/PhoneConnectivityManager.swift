//
//  PhoneConnectivityManager.swift
//  GymFocus
//
//  Created by Claude.
//

import Foundation
import WatchConnectivity
import SwiftData

class PhoneConnectivityManager: NSObject, ObservableObject {
    static let shared = PhoneConnectivityManager()
    
    private var modelContext: ModelContext?
    
    private override init() {
        super.init()
        
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func sendDataToWatch() {
        guard WCSession.default.isReachable,
              let context = modelContext else { return }
        
        // Fetch all timers from SwiftData
        let descriptor = FetchDescriptor<Item>()
        guard let items = try? context.fetch(descriptor) else { return }
        
        // Extract all unique timer values
        let allTimers = items.flatMap { $0.timers }
        let uniqueTimers = Array(Set(allTimers)).sorted()
        
        // Get current theme from UserDefaults
        let currentTheme = UserDefaults.standard.string(forKey: "theme") ?? "S"
        
        // Send to watch
        var applicationContext: [String: Any] = [:]
        if let timersData = try? JSONEncoder().encode(uniqueTimers) {
            applicationContext["timers"] = timersData
        }
        applicationContext["theme"] = currentTheme
        
        try? WCSession.default.updateApplicationContext(applicationContext)
    }
    
    // Maintain old method name for backward compatibility
    func sendTimersToWatch() {
        sendDataToWatch()
    }
    
    private func getTimersFromDatabase() -> [Double] {
        guard let context = modelContext else { return [60] }
        
        let descriptor = FetchDescriptor<Item>()
        guard let items = try? context.fetch(descriptor) else { return [60] }
        
        let allTimers = items.flatMap { $0.timers }
        let uniqueTimers = Array(Set(allTimers)).sorted()
        
        return uniqueTimers.isEmpty ? [60] : uniqueTimers
    }
}

extension PhoneConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            sendDataToWatch()
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if message["request"] as? String == "data" {
            let timers = getTimersFromDatabase()
            let theme = UserDefaults.standard.string(forKey: "theme") ?? "S"
            
            var response: [String: Any] = ["theme": theme]
            if let timersData = try? JSONEncoder().encode(timers) {
                response["timers"] = timersData
            }
            replyHandler(response)
        }
    }
}