//
//  TimerActivityAttributes.swift
//  GymFocus
//
//  Created by Giovanni De Francesco on 25/07/25.
//

import ActivityKit
import Foundation
import SwiftUI

struct TimerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var timeRemaining: Double
        var totalDuration: Double
        var isRunning: Bool
        var endTime: Date
    }
    
    var timerName: String
    var themeColorRed: Double
    var themeColorGreen: Double
    var themeColorBlue: Double
}