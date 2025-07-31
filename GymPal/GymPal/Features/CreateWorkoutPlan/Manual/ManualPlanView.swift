//
//  ManualPlanView.swift
//  GymFocus
//
//  Created by Giovanni De Francesco on 28/07/25.
//
import SwiftUI

struct ManualPlanView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var textViewModel: WorkoutPlanViewModel
    @State var showAddWorkoutPlanSheet: Bool = false
    
    init(_ textViewModel: WorkoutPlanViewModel) {
        self.textViewModel = textViewModel
    }
    
    var body: some View {
        VStack{
            HStack{
                SectionTitle("plan".localized("plan section title"))
                SecondaryButton("add".localized("adds a workout plan")){
                    showAddWorkoutPlanSheet = true
                }
//                CustomEditButton(isEditing: $textViewModel.isEditing){
//                    showAddWorkoutPlanSheet = true
//                }
            }
            Spacer()
            if(textViewModel.workoutPlanItem.workoutPlanJson.isEmpty){
                Image(systemName: "ecg.text.page").font(.system(size: 100)).foregroundStyle(.primary.opacity(0.8))
                PrimaryButton("add".localized("adds a workout plan")){
                    showAddWorkoutPlanSheet = true
                }.padding()
            }else {
                ScrollView{
                    Text(textViewModel.workoutPlanItem.workoutPlanJson)
                }.padding()
            }
            Spacer()
        }.popover(isPresented: $showAddWorkoutPlanSheet){
            ChooseCreatePlan(textViewModel)
        }
        .onAppear{
            textViewModel.loadWorkoutPlan(from: modelContext)
        }
    }
}
