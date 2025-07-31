//
//  WatchTimerManager.swift
//  GymFocus Watch App
//
//  Created by Claude.
//

import Foundation
import SwiftUI
import WatchKit

class WatchTimerManager: ObservableObject {
    @Published var currentSets: Int = 0
    @Published var timeRemaining: Double = 60.0
    @Published var isRunning: Bool = false
    @Published var selectedTimerDuration: Double = 60.0
    
    private var timer: Timer?
    private let connectivityManager = WatchConnectivityManager.shared
    
    // Get timer options from connectivity manager
    var timerOptions: [Double] {
        return connectivityManager.savedTimers
    }
    
    init() {
        // Request timers from iPhone when initialized
        connectivityManager.requestTimersFromPhone()
    }
    
    var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func incrementSets() {
        currentSets += 1
    }
    
    func decrementSets() {
        if currentSets > 0 {
            currentSets -= 1
        }
    }
    
    func resetSets() {
        currentSets = 0
    }
    
    func startTimer() {
        guard !isRunning else { return }
        
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.timerCompleted()
            }
        }
    }
    
    func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func resetTimer() {
        stopTimer()
        timeRemaining = selectedTimerDuration
    }
    
    func setTimerDuration(_ duration: Double) {
        selectedTimerDuration = duration
        if !isRunning {
            timeRemaining = duration
        }
    }
    
    func formatTimerOption(_ seconds: Double) -> String {
        if seconds < 60 {
            return "\(Int(seconds))s"
        } else {
            let minutes = Int(seconds) / 60
            let remainingSeconds = Int(seconds) % 60
            if remainingSeconds == 0 {
                return "\(minutes)m"
            } else {
                return "\(minutes)m \(remainingSeconds)s"
            }
        }
    }
    
    private func timerCompleted() {
        stopTimer()
        
        // Haptic feedback
        WKInterfaceDevice.current().play(.notification)
        
        // Reset timer for next set
        timeRemaining = selectedTimerDuration
    }
}
