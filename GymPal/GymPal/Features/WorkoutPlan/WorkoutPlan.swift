//
//  Item.swift
//  GymFocus
//
//  Created by Giovanni De Francesco on 14/07/25.
//

import Foundation
import SwiftData

@Model
final class WorkoutPlanItem {
    
    
     var workoutPlanJson: String
//    
//    var plan : WorkoutPlan? {
//        get {
//            (try? JSONDecoder().decode(WorkoutPlan.self, from: Data(workoutPlanJson.utf8)))
//        }
//        set {
//            workoutPlanJson = (try? JSONEncoder().encode(newValue)).flatMap { String(data: $0, encoding: .utf8) } ?? ""
//        }
//    }
//    
//    init(workoutPlan: WorkoutPlan) {
//        self.workoutPlanJson = (try? JSONEncoder().encode(workoutPlan)).flatMap { String(data: $0, encoding: .utf8) } ?? ""
//    }
//    
    init(from: String){
        self.workoutPlanJson = from
    }
}

struct WorkoutDay: Codable {
    let name: String
    let exercises: [Exercise]
}

struct Exercise: Codable {
    let name: String
    let weight: String
    let notes: String
//        let weeks: [Week]
}

final class WorkoutPlan: Codable {
    
    var program: [WorkoutDay] = []
    
    struct WorkoutDay: Codable {
        let name: String
        let exercises: [Exercise]
    }
    
    struct Exercise: Codable {
        let name: String
        let weight: String
        let notes: String
//        let weeks: [Week]
    }
    
//    struct Week: Codable {
//        let week: String
//        let notes: String
//    }
    
    static func fromJSON(_ jsonString: String) -> WorkoutPlan? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(WorkoutPlan.self, from: data)
    }
}
