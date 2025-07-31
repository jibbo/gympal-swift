//
//  GymFocusWidgetsBundle.swift
//  GymFocusWidgets
//
//  Created by Giovanni De Francesco on 25/07/25.
//

import WidgetKit
import SwiftUI
import ActivityKit

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

extension Color {
    init(red: Double, green: Double, blue: Double) {
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1.0)
    }
}

struct TimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerActivityAttributes.self) { context in
            // Lock screen/banner UI goes here
            let themeColor = Color(
                red: context.attributes.themeColorRed,
                green: context.attributes.themeColorGreen,
                blue: context.attributes.themeColorBlue
            )
            
            // Calculate remaining time based on current date for accurate background updates
            let now = Date()
            
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "timer")
                        .foregroundColor(themeColor)
                    Text(NSLocalizedString("rest_time", comment: "Rest time label"))
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    ProgressView(timerInterval: now...context.state.endTime)
                        .progressViewStyle(.circular)
                        .tint(themeColor)
                        .foregroundStyle(.white)
                        .frame(height: 30)
                        .padding()
                }
                
                
            }
            .padding()
            .background(Color.black)
            .cornerRadius(12)
        } dynamicIsland: { context in
            let themeColor = Color(
                red: context.attributes.themeColorRed,
                green: context.attributes.themeColorGreen,
                blue: context.attributes.themeColorBlue
            )
            
            // Calculate remaining time based on current date for accurate background updates
            let now = Date()
            
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image(systemName: "timer")
                            .foregroundColor(themeColor)
                        Text(NSLocalizedString("rest_time", comment: "Rest time label"))
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Image(systemName: "clock")
                        .foregroundColor(themeColor)
                }
                DynamicIslandExpandedRegion(.center) {
                    ProgressView(timerInterval: now...context.state.endTime)
                    .progressViewStyle(.circular).tint(themeColor)                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(NSLocalizedString("rest_timer", comment: "Rest timer label"))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } compactLeading: {
                Image(systemName: "timer")
                    .foregroundColor(themeColor)
            } compactTrailing: {
                ProgressView(timerInterval: now...context.state.endTime)
                    .progressViewStyle(.circular).tint(themeColor)
            } minimal: {
                Image(systemName: "timer")
                    .foregroundColor(themeColor)
            }
            .widgetURL(URL(string: "gymfocus://timer"))
            .keylineTint(.clear)
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}

@main
struct GymFocusWidgetsBundle: WidgetBundle {
    var body: some Widget {
        TimerLiveActivity()
    }
}
