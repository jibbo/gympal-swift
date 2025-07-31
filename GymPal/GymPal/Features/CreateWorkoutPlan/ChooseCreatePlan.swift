//
//  ChooseCreatePlan.swift
//  GymFocus
//
//  Created by Giovanni De Francesco on 28/07/25.
//

import SwiftUI
struct ChooseCreatePlan: View{
    @Environment(\.dismiss) var dismiss
    @ObservedObject var workoutViewModel: WorkoutPlanViewModel
    @State private var showManual: Bool = false
    @State private var showGallery: Bool = false
    
    init(_ workoutViewModel: WorkoutPlanViewModel){
        self.workoutViewModel = workoutViewModel
    }
    
    var body: some View{
        VStack(alignment:.leading){
            HStack{
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                Text("choose_new_plan_title".localized("Time in seconds label")).font(.body1).padding()

            }
            Spacer()
            Card{
                HStack{
                    VStack(alignment: .leading, spacing: 10){
                        Text("choose_new_plan_from_gallery".localized()).font(.body2)
                        Text("Lets you select picture from your photo roll")
                    }
                    Spacer()
                    Image(systemName: "photo.stack").font(.system(size: 30, weight: .bold))
                }
            }.onTapGesture {
                showGallery = true
            }
            Card{
                HStack{
                    VStack(alignment: .leading, spacing: 10){
                        Text("From Camera").font(.body2)
                        Text("Lets you scan document from your camera")
                    }
                    Spacer()
                    Image(systemName: "camera.fill").font(.system(size: 30, weight: .bold))
                }
            }
            Card{
                HStack{
                    VStack(alignment: .leading, spacing: 10){
                        Text("choose_new_plan_manual".localized()).font(.body2)
                        Text("Lets you type your workout plan")
                    }
                    Spacer()
                    Image(systemName: "text.quote").font(.system(size: 30, weight: .bold))
                }
            }.onTapGesture {
                showManual = true
            }
            Spacer()
        }
        .popover(isPresented: $showManual) {
            CreateManualPlanView(workoutViewModel)
        }
        .popover(isPresented: $showGallery) {
            FromGalleryView()
        }
        .padding()
    }
}

#Preview {
    ChooseCreatePlan(WorkoutPlanViewModel()).environmentObject(Settings())
}
