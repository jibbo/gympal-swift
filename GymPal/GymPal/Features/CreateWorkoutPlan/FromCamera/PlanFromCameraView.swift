//
//  PlanFromCamera.swift
//  GymFocus
//
//  Created by Giovanni De Francesco on 26/07/25.
//

import SwiftUI
import Vision

struct PlanFromCameraView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var scannedImages: [UIImage] = []
    @State private var isShowingVNDocumentCameraView = false
    
    var body: some View {
        NavigationView {
            Grid {
                ForEach(scannedImages, id: \.self) { image in
                    VStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .padding()
                    }
                }
            }
            .sheet(isPresented: $isShowingVNDocumentCameraView) {
                DocumentScanner(scanResult: $scannedImages)
            }
            .toolbar {
                ToolbarItem {
                    Button(action: showVNDocumentCameraView) {
                        Image(systemName: "document.badge.plus.fill")
                    }
                }
            }
        }
    }
    
    private func showVNDocumentCameraView() {
        isShowingVNDocumentCameraView = true
    }
}

#Preview{
  PlanFromCameraView()
}
