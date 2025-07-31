//
//  WorkoutViewModel.swift
//  GymFocus
//
//  Created by Giovanni De Francesco on 26/07/25.
//

import SwiftUI
import SwiftData

final class WorkoutPlanViewModel: ObservableObject{
    @Published var workoutPlanItem: WorkoutPlanItem = WorkoutPlanItem(from: "")
    @Published var isEditing:Bool = false
    
    func saveWorkoutPlan(to modelContext: ModelContext) {
        modelContext.insert(workoutPlanItem)
        try? modelContext.save()
    }
    
    func loadWorkoutPlan(from modelContext: ModelContext) {
        let descriptor = FetchDescriptor<WorkoutPlanItem>(
            sortBy: [SortDescriptor(\.workoutPlanJson, order: .reverse)]
        )
        if let savedPlan = try? modelContext.fetch(descriptor).first {
            workoutPlanItem = savedPlan
        }
    }
}
