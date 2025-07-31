//
//  ItemsViewModel.swift
//  GymFocus
//
//  Created by Giovanni De Francesco on 14/07/25.
//
import SwiftUI
import AudioToolbox
import ActivityKit
import BackgroundTasks

extension Color {
    func toRGB() -> (red: Double, green: Double, blue: Double) {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return (red: Double(red), green: Double(green), blue: Double(blue))
    }
}


final class ItemsViewModel: ObservableObject {
    @Published var item: Item = Item(steps: 0, timers: [])
    @Published var isEditing: Bool = false
    @Published var timer: Timer? = nil
    @Published var timerRunning: Bool = false
    @Published var timeRemaining: Double = 0
    @Published var timerDate = Date()
    @Published var timerProgress: Double = 0
    @Published var showNewTimer: Bool = false
    @Published var showDeleteAlert: Bool = false
    @Published var selectedTimer: Double = 0.0
    @Published var timerTextVisible = true
    @Published var isBlinking = false
    
    @Published var lastTimerSelected: Double {
        didSet { UserDefaults.standard.set(lastTimerSelected, forKey: "lastTimerSelected") }
    }
    
    public let blinkDuration = 0.2
    private var currentActivity: Activity<TimerActivityAttributes>?
    private var originalTimerDuration: Double = 0
    
    private let alarmPlayer = AlarmPlayer()
    
    init() {
        if UserDefaults.standard.object(forKey: "lastTimerSelected") != nil {
            self.lastTimerSelected = UserDefaults.standard.double(forKey: "lastTimerSelected")
        } else{
            self.lastTimerSelected = 60
        }
        self.timeRemaining = lastTimerSelected
    }
    
    func startTimer(time: Double? = nil, themeColor: Color) {
        let time = time ?? lastTimerSelected
        timerRunning = true
        timer?.invalidate() // Invalidate any existing timer
        timeRemaining = time
        lastTimerSelected = time
        originalTimerDuration = time
        timerProgress = 0
        
        // Set the end time for accurate calculations
        timerDate = Date().addingTimeInterval(time)
        
        // Start Live Activity
        startLiveActivity(duration: time, themeColor: themeColor)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            // Calculate time remaining based on end date for accuracy
            let now = Date()
            let calculatedTimeRemaining = max(0, self.timerDate.timeIntervalSince(now))
            
            if calculatedTimeRemaining > 0 {
                self.timeRemaining = calculatedTimeRemaining
                self.timerProgress = (time - calculatedTimeRemaining) / time
                
                // Only update Live Activity occasionally to avoid background issues
                if Int(calculatedTimeRemaining) % 30 == 0 || calculatedTimeRemaining == time {
                    self.updateLiveActivity()
                }
            } else {
                self.timer?.invalidate()
                self.timerRunning = false
                self.timeRemaining = 0
                self.timerProgress = 1.0
                self.alarmPlayer.playSound(named: "digital_watch_alarm_long")
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                self.startBlinking()
                
                // End Live Activity
                self.endLiveActivity()
            }
        }
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if(settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional) {
                self.scheduleTimerNotification(at: self.timerDate)
            } else{
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if(granted) {
                        self.scheduleTimerNotification(at: self.timerDate)
                    }
                }
            }
        }
        
    }
    
    func resetTimer() {
        timer?.invalidate()
        timeRemaining = lastTimerSelected
        timerRunning = false
        timerProgress = 0
        alarmPlayer.stop()
        stopBlinking()
        
        // End Live Activity when timer is reset
        endLiveActivity()
    }
    
    func startBlinking() {
        guard !isBlinking else { return }
        isBlinking = true
        timerTextVisible = false
        Task { @MainActor in
            while isBlinking {
                try? await Task.sleep(nanoseconds: UInt64(blinkDuration * 1_000_000_000))
                if isBlinking { timerTextVisible.toggle() }
            }
        }
    }
    
    func stopBlinking() {
        isBlinking = false
        timerTextVisible = true
    }
    
    private func scheduleTimerNotification(at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("times_up", comment: "Timer completion notification title")
        content.body = NSLocalizedString("times_up_message", comment: "Timer completion notification body")
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Live Activity Methods
    
    
    private func startLiveActivity(duration: Double, themeColor: Color) {
        if #available(iOS 16.1, *) {
            let authInfo = ActivityAuthorizationInfo()
            
            guard authInfo.areActivitiesEnabled else {
                return
            }
            
            // End any existing activities first
            Task {
                for activity in Activity<TimerActivityAttributes>.activities {
                    await activity.end(dismissalPolicy: .immediate)
                }
            }
            
            let rgb = themeColor.toRGB()
            let attributes = TimerActivityAttributes(
                timerName: NSLocalizedString("rest_timer", comment: "Rest timer name"),
                themeColorRed: rgb.red,
                themeColorGreen: rgb.green,
                themeColorBlue: rgb.blue
            )
            let initialContentState = TimerActivityAttributes.ContentState(
                timeRemaining: duration,
                totalDuration: duration,
                isRunning: true,
                endTime: Date().addingTimeInterval(duration)
            )
            
            do {
                let activity = try Activity<TimerActivityAttributes>.request(
                    attributes: attributes,
                    contentState: initialContentState,
                    pushType: nil
                )
                currentActivity = activity
            } catch {
                // Live Activity creation failed, continue without it
            }
        }
    }
    
    private func updateLiveActivity() {
        guard let activity = currentActivity else { 
            return 
        }
        
        // Use the same date-based calculation for consistency
        let now = Date()
        let calculatedTimeRemaining = max(0, timerDate.timeIntervalSince(now))
        
        let updatedContentState = TimerActivityAttributes.ContentState(
            timeRemaining: calculatedTimeRemaining,
            totalDuration: originalTimerDuration,
            isRunning: timerRunning && calculatedTimeRemaining > 0,
            endTime: timerDate
        )
        
        Task {
            await activity.update(using: updatedContentState)
        }
    }
    
    private func endLiveActivity() {
        guard let activity = currentActivity else { 
            return 
        }
        
        Task {
            await activity.end(dismissalPolicy: .immediate)
        }
        currentActivity = nil
    }
}
