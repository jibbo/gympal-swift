//
//  ImageGridViewModel.swift
//  GymFocus
//
//  Created by Giovanni De Francesco on 28/07/25.
//

import SwiftUI

class FromGalleryViewModel: ObservableObject {
    @Published var images: [SavedImage] = []
    @Published var isEditing = false
    
    init() {
        loadImages()
    }
    
    func loadImages() {
        if let data = UserDefaults.standard.data(forKey: "myImages"),
           let decoded = try? JSONDecoder().decode([SavedImage].self, from: data) {
            images = decoded
        }
    }
    
    func saveImages() {
        if let data = try? JSONEncoder().encode(images) {
            UserDefaults.standard.set(data, forKey: "myImages")
        }
    }
    
    func addImage(_ image: UIImage) {
        let id = UUID()
        let filename = "\(id).jpg"
        if let data = image.jpegData(compressionQuality: 0.8) {
            let url = Self.getDocumentsDirectory().appendingPathComponent(filename)
            try? data.write(to: url)
            images.append(SavedImage(id: id, filename: filename))
            saveImages()
        }
    }
    
    func delete(_ image: SavedImage) {
        let url = Self.getDocumentsDirectory().appendingPathComponent(image.filename)
        try? FileManager.default.removeItem(at: url)
        images.removeAll { $0.id == image.id }
        saveImages()
    }
    
    func uiImage(for image: SavedImage) -> UIImage? {
        let url = Self.getDocumentsDirectory().appendingPathComponent(image.filename)
        return UIImage(contentsOfFile: url.path)
    }
    
    static func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
