//
//  CircularProgressView.swift
//  GymFocus
//
//  Created by Giovanni De Francesco on 18/07/25.
//

import SwiftUI

struct CircularProgressView<Content: View>: View {
    @EnvironmentObject private var settings: Settings
    
    private var progress: Double
    private var lineWidth: CGFloat
    private var color: Color?
    private var content: () -> Content
    private var action: (()->Void)
    
    init(
        progress: Double,
        lineWidth: CGFloat = 20,
        color: Color? = nil,
        @ViewBuilder content: @escaping () -> Content,
        action: @escaping ()-> Void = {})
    {
        self.progress = progress
        self.lineWidth = lineWidth
        self.color = color
        self.action = action
        self.content = content
    }
    
    var body: some View {
        let themeColor = color ?? settings.getThemeColor()
        ZStack {
            Circle()
                .stroke(themeColor.opacity(0.2), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(themeColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            content()
        }
        .padding()
        .onTapGesture {
            action()
        }
    }
}

#Preview {
    CircularProgressView(progress: 0.5){
        Text("00:00")
    }.environmentObject(Settings())
}
