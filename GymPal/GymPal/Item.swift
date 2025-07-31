//
//  Item.swift
//  GymFocus
//
//  Created by Giovanni De Francesco on 14/07/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var steps: Int
    
    private var timersJSON: String
        
    var timers: [Double] {
            get {
                (try? JSONDecoder().decode([Double].self, from: Data(timersJSON.utf8))) ?? []
            }
            set {
                timersJSON = (try? JSONEncoder().encode(newValue)).flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
            }
        }
    
    init(steps: Int, timers: [Double]) {
        self.steps = steps
        self.timersJSON = (try? JSONEncoder().encode(timers)).flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
    }
}
