//
//  TrackingManager.swift
//  GymFocus
//
//  Created by Giovanni De Francesco on 29/07/25.
//

import FirebaseAnalytics

final class TrackingManager: ObservableObject{
    
    func logViewDisplayed(_ screenName:String,_ screenClass: String){
        Analytics.logEvent(AnalyticsEventScreenView,parameters: [AnalyticsParameterScreenName: screenName, AnalyticsParameterScreenClass: screenClass])
    }
    
    func logSelectedTheme(theme: String){
        Analytics.logEvent("selected_theme", parameters: ["name": theme])
    }
    
    func logSinglePageMode(isOn: Bool){
        Analytics.logEvent("single_page_mode", parameters: ["isOn": isOn])
    }
    
    func logPowerliftingMode(isOn: Bool){
        Analytics.logEvent("powerlifting_mode", parameters: ["isOn": isOn])
    }
}
