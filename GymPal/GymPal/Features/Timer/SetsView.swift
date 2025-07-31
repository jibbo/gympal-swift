//
//  SetsView.swift
//  GymFocus
//
//  Created by Giovanni De Francesco on 16/07/25.
//
import SwiftUI

struct SetsView: View {
    @ObservedObject private var viewModel: ItemsViewModel
    
    init(_ viewModel: ItemsViewModel){
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            HStack{
                Text("sets".localized("Sets label"))
                    .font(.body1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Spacer()
                SecondaryButton("reset".localized("Reset button")){
                    viewModel.item.steps = 0
                }
            }
            Spacer()
            HStack(alignment: .bottom){
                Text(String(viewModel.item.steps))
                    .font(.custom(Theme.fontName, size: 92).bold())
                Text("completed".localized("Completed label"))
                    .font(.body1)
                    .padding(.vertical)
            }
            Spacer()
            PrimaryButton("plus_one".localized("+1 button")){
                viewModel.item.steps += 1
            }
            .padding()
        }
    }
}

#Preview {
    SetsView(ItemsViewModel()).environmentObject(Settings())
}
