//
//  ContentView.swift
//  GymFocus
//
//  Created by Giovanni De Francesco on 14/07/25.
//

import SwiftUI
import SwiftData
import UserNotifications

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var settings: Settings
    
    @StateObject private var viewModel: ItemsViewModel = ItemsViewModel()
    
    @Query private var items: [Item]
    
    var body: some View {
        NavigationStack{
            ViewThatFits(in: .horizontal){
                GeometryReader { proxy in
                   ContentHorizontal(viewModel)
                }
                .frame(minWidth: 500)
                
                if(settings.singlePage){
                    SinglePageVertical(viewModel)
                } else{
                    MultiPageVertical(viewModel)
                }
            }
            .navigationTitle("app_name".localized("App name in navigation"))
            .onAppear(){
                if items.isEmpty {
                    let newItem = Item(steps: 0, timers: [30, 60, 120, 180])
                    modelContext.insert(newItem)
                    viewModel.item = newItem
                } else {
                    viewModel.item = items[0]
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
        .environmentObject(Settings())
}
