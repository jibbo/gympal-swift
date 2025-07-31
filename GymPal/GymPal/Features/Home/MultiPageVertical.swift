//
//  SinglePageVertical.swift
//  GymFocus
//
//  Created by Giovanni De Francesco on 23/07/25.
//
import SwiftUI

struct MultiPageVertical: View {
    @EnvironmentObject private var settings: Settings
    
    @ObservedObject private var viewModel: ItemsViewModel
    
    init(_ viewModel: ItemsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        TabView{
            SetsView(viewModel).tabItem {
                Label("sets".localized("Sets tab"), systemImage: "figure.strengthtraining.traditional")
            }.tag(1)
            ScrollView(showsIndicators: false){
                TimerView(viewModel)
                SavedTimers(viewModel)
            }.tabItem {
                Label("timer".localized("Timer tab"), systemImage: "clock")
            }.tag(2)
            WeightCounterView().tabItem{
                Label("plates_counter".localized("Plates Counter tab"), systemImage: "dumbbell")
            }.tag(3)
            SettingsView().tabItem {
                Label("settings".localized("Settings tab"), systemImage: "gearshape")
            }.tag(4)
        }.accentColor(settings.getThemeColor())
    }
}

#Preview {
    let viewModel = ItemsViewModel();
    MultiPageVertical(viewModel)
        .onAppear{
            viewModel.item.timers=[30,60,90,120,180]
        }
        .environmentObject(Settings())
}
