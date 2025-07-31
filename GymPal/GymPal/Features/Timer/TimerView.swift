//
//  TimerView.swift
//  GymFocus
//
//  Created by Giovanni De Francesco on 18/07/25.
//

//
//  TimerView.swift
//  GymFocus
//
//  Created by Giovanni De Francesco on 16/07/25.
//

import SwiftUI

struct TimerView: View {
    @EnvironmentObject private var settings: Settings
    @ObservedObject private var viewModel: ItemsViewModel
    
    init(_ viewModel: ItemsViewModel){
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack{
            Text("active_timer".localized("Active timer label"))
                .font(.body1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            Spacer()
            CircularProgressView(progress: viewModel.timerProgress){
                Text(formatTime(Int(viewModel.timeRemaining)))
                    .font(.primaryTitle)
                    .opacity(viewModel.timerTextVisible ? 1 : 0)
                    .animation(.easeInOut(duration: viewModel.blinkDuration), value: viewModel.timerTextVisible)
            }.frame(maxHeight: 200)
            Spacer()
            if(viewModel.timerRunning){
                PrimaryButton("stop".localized("Stop button"), color: .red){
                    viewModel.resetTimer();
                }.padding()
            } else {
                PrimaryButton("start".localized("Start button")){
                    viewModel.startTimer(themeColor: settings.getThemeColor())
                }.padding()
            }
        }
        .fullScreenCover(isPresented: $viewModel.showNewTimer){
            AddTimerView(viewModel)
        }
        .alert(isPresented: $viewModel.showDeleteAlert) {
            Alert(
                title: Text("delete_timer".localized("Delete timer alert title")), 
                message: Text("delete_timer_message".localized("Delete timer alert message")), 
                primaryButton: .destructive(Text("delete".localized("Delete button"))) {
                    viewModel.item.timers.remove(at: viewModel.item.timers.firstIndex(of: viewModel.selectedTimer)!)
                }, 
                secondaryButton: .cancel(Text("cancel".localized("Cancel button")))
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)){ _ in
            if(viewModel.timerRunning){
                Task { @MainActor in
                    let interval = viewModel.timerDate.timeIntervalSinceNow
                    if(interval <= 0){
                        viewModel.startBlinking()
                    }else{
                        viewModel.stopBlinking()
                    }
                    viewModel.timeRemaining = interval >= 0 ? interval : 0
                }
            }
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
    
}

#Preview {
    let viewModel = ItemsViewModel();
    TimerView(viewModel).environmentObject(Settings()).onAppear {
        viewModel.item.timers=[30,60,90,120,180]
    }
}

