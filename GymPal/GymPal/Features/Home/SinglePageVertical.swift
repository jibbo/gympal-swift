//
//  SinglePageVertical.swift
//  GymFocus
//
//  Created by Giovanni De Francesco on 23/07/25.
//
import SwiftUI

struct SinglePageVertical: View {
    @EnvironmentObject private var settings: Settings
    
    @ObservedObject private var viewModel: ItemsViewModel
    
    init(_ viewModel: ItemsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        TabView {
            ScrollView(showsIndicators:false){
                SetsView(viewModel)
                TimerView(viewModel)
                SavedTimers(viewModel)
            }.tabItem{
                Label("sets".localized("sets tab"), systemImage: "figure.strengthtraining.traditional")
            }
            .tag(1)
            WeightCounterView().tabItem{
                Label("plates_counter".localized("Plate counter tab"), systemImage: "dumbbell")
            }
            .tag(2)
            SettingsView().tabItem {
                Label("settings".localized("Settings tab"), systemImage: "gearshape")
            }
            .tag(3)
        }
        .accentColor(settings.getThemeColor())
    }
}

#Preview {
    let viewModel = ItemsViewModel();
    SinglePageVertical(viewModel)
        .onAppear{
            viewModel.item.timers=[30,60,90,120,180]
        }
        .environmentObject(Settings())
}
