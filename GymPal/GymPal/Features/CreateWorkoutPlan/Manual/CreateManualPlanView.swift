//
//  ManualPlan.swift
//  GymFocus
//
//  Created by Giovanni De Francesco on 26/07/25.
//

import SwiftUI

struct CreateManualPlanView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var workoutViewModel: WorkoutPlanViewModel
    
    init(_ workoutViewModel: WorkoutPlanViewModel) {
        self.workoutViewModel = workoutViewModel
    }
    
    var body: some View {
        VStack{
            SectionTitle("Manual Plan")
            TextField("Enter your plan here", text: $workoutViewModel.workoutPlanItem.workoutPlanJson , axis: .vertical)
                .frame(maxHeight: .infinity)
                .overlay{
                    RoundedRectangle(cornerRadius: 8).stroke(.primary, lineWidth: 1)
                }
            PrimaryButton("ok".localized()){
                workoutViewModel.saveWorkoutPlan(to: modelContext)
                dismiss()
            }
        }.padding()
    }
}

#Preview {
    let viewModel = WorkoutPlanViewModel()
    CreateManualPlanView(viewModel)
        .environmentObject(Settings())
}
