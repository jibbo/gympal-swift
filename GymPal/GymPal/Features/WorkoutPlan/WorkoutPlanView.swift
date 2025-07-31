//
//  WorkoutPlanView.swift
//  GymFocus
//
//  Created by Giovanni De Francesco on 26/07/25.
//

import SwiftUI

struct WorkoutPlanView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var trackingManager: TrackingManager
    @ObservedObject var textViewModel: WorkoutPlanViewModel = WorkoutPlanViewModel()
    @ObservedObject var galleryViewModel: FromGalleryViewModel = FromGalleryViewModel()

    
    var body: some View {
        if(!galleryViewModel.images.isEmpty){
            FromGalleryView()
        }else{
            ManualPlanView(textViewModel)
        }
    }
}

#Preview {
    WorkoutPlanView().environmentObject(Settings())
}
