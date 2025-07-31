//
//  ImageGridView.swift
//  GymFocus
//
//  Created by Giovanni De Francesco on 28/07/25.
//

import SwiftUI
import PhotosUI

struct FromGalleryView: View {
    @StateObject private var model = FromGalleryViewModel()
    @State private var showPicker = false
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var fullscreenImage: UIImage? = nil
    @State private var selectedImage: SavedImage? = nil
    @State private var showDeleteAlert = false
    
    var body: some View {
        VStack {
            HStack{
                SectionTitle("plan".localized("plan section title"))
                
                if(!model.images.isEmpty){
                    CustomEditButton(isEditing: $model.isEditing){}
                }
            }
            if(model.images.isEmpty){
                Spacer()
                Image(systemName: "ecg.text.page").font(.system(size: 100)).foregroundStyle(.primary.opacity(0.8))
            } else{
                ScrollView(showsIndicators:false){
                    LazyVStack{
                        showImages()
                    }
                    .padding()
                }
                //                ScrollView {
                //                    LazyVGrid(columns: [GridItem(.adaptive(minimum:100))], spacing: 16) {
                //                        showImages()
                //                    }
                //                    .padding()
                //                }
            }
            if(model.isEditing || model.images.isEmpty){
                Spacer()
                withAnimation{
                    PrimaryButton("add".localized("adds a workout plan")){
                        showPicker = true
                    }.padding()
                }
            }
        }
        .photosPicker(isPresented: $showPicker, selection: $selectedItems, matching: .images)
        .sheet(isPresented: Binding(
            get: { fullscreenImage != nil },
            set: { if !$0 { fullscreenImage = nil } }
        )) {
            if let img = fullscreenImage {
                FullscreenImageView(image: img)
            }
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("delete_plan".localized("Delete workout alert title")),
                message: Text("delete_plan_message".localized("Delete workout alert message")),
                primaryButton: .destructive(Text("delete".localized("Delete button"))) {
                    if let image = selectedImage{
                        model.delete(image)
                    }
                    selectedImage = nil
                },
                secondaryButton: .cancel(Text("cancel".localized("Cancel button"))) {
                    selectedImage = nil
                }
            )
        }
        .onChange(of: selectedItems) { oldItems, newItems in
            for item in newItems {
                item.loadTransferable(type: Data.self) { result in
                    if case .success(let data?) = result, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            model.addImage(image)
                        }
                    }
                }
            }
        }
        .onChange(of: showPicker) { oldValue, newValue in
            if !newValue {
                model.isEditing = false
            }
        }
    }
    
    private func showImages() -> some View {
        ForEach(model.images) { saved in
            if let uiImage = model.uiImage(for: saved) {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .clipped()
                        .cornerRadius(8)
                        .onTapGesture {
                            if(model.isEditing){
                                selectedImage = saved
                                showDeleteAlert = true
                            }else{
                                fullscreenImage = uiImage
                            }
                        }
                        .overlay{
                            let color: Color = (model.isEditing ? .red : .clear)
                            RoundedRectangle(cornerRadius: 8).stroke(color, lineWidth: 2).animation(.easeInOut(duration: 0.3), value: color)
                        }
                }
            }
        }
    }
}

#Preview {
    FromGalleryView().environmentObject(Settings())
}
