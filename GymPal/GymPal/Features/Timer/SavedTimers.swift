//
//  SavedTimers.swift
//  GymFocus
//
//  Created by Giovanni De Francesco on 22/07/25.
//

import SwiftUI

struct SavedTimers: View {
    @ObservedObject private var viewModel: ItemsViewModel
    @EnvironmentObject private var settings: Settings
    
    init(_ viewModel: ItemsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View{
        VStack{
            HStack(alignment: .bottom){
                Text("pinned_timers".localized("Pinned timers section title"))
                    .font(.body1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Spacer()
                CustomEditButton(isEditing: $viewModel.isEditing){}.padding(.vertical, 20)
            }
            ScrollView{
                FlowLayout{
                    generateSavedTimers()
                }
            }
        }
    }
    
    private func generateSavedTimers() -> some View {
        Group{
            ForEach(viewModel.item.timers.indices, id: \.self) { index in
                let timer = viewModel.item.timers[index]
                // Use a tuple as the id so SwiftUI knows to re-render on edit mode change
                let buttonID = "\(timer)-\(viewModel.isEditing)"
                RoundButton(
                    formatTime(Int(timer)),
                    isEditMode: viewModel.isEditing,
                ) {
                    if viewModel.isEditing {
                        viewModel.showDeleteAlert = true
                        viewModel.selectedTimer = timer
                    } else {
                        viewModel.startTimer(time: timer, themeColor: settings.getThemeColor())
                        viewModel.stopBlinking()
                    }
                }
                .id(buttonID)
            }
            RoundButton("+", dashed: true){
                viewModel.showNewTimer = true
            }.frame(minWidth: 135)
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}

#Preview {
    let viewModel = ItemsViewModel();
    SavedTimers(viewModel).onAppear{
        viewModel.item.timers=[30,60,90,120,180]
    }.environmentObject(Settings())
}
