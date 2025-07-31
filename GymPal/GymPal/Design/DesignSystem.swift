//
//  DesignSystem.swift
//  GymFocus
//
//  Created by Giovanni De Francesco on 16/07/25.
//

import SwiftUI

extension String{
    func localized(_ comment: String? = nil) -> String {
        NSLocalizedString(self, comment: comment ?? "")
    }
}

extension Font {
    static let primaryTitle: Font = .custom(Theme.fontName, size: 42)
    static let caption: Font = .custom(Theme.fontName, size: 32)
    static let buttons: Font = .custom(Theme.fontName, size: 20)
    static let body1: Font = .custom(Theme.fontName, size: 20)
    static let body2: Font = .custom(Theme.fontName, size: 16)
}

extension Color {
    static let primaryDefault: Color = Color(red: 0.81, green: 1, blue: 0.01)
    static let primaryA: Color = Color(red: 0.761, green: 0.529, blue: 0.482)
    static let primaryD: Color = Color(red: 0.533, green: 0, blue: 0.906)
    static let primaryE: Color = Color(red: 0, green: 0.404, blue: 0.31)
    static let primaryF: Color = Color(red: 0.043, green: 0.4, blue: 0.137)
    static let primaryG: Color = Color(red: 1, green: 0.455, blue: 0)
//    static let primaryB: Color = Color(red: 0.161, green: 0.502, blue: 0.725)
    static let primaryB: Color = Color(red: 0, green: 1, blue: 0.6) // #00ff99
    static let primaryR: Color = Color(red: 0.906, green: 0.298, blue: 0.235)
    static let lightGray: Color = Color(red: 0.63, green: 0.63, blue: 0.63)
    static let darkGray: Color = Color(red: 0.21, green: 0.21, blue: 0.21)
    
    func luminance() -> Double {
        // 1. Convert SwiftUI Color to UIColor
        let uiColor = UIColor(self)
        
        // 2. Extract RGB values
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
        
        // 3. Compute luminance.
        return 0.2126 * Double(red) + 0.7152 * Double(green) + 0.0722 * Double(blue)
    }
    func isLight() -> Bool {
        return luminance() > 0.5
    }
    
    func textColor() -> Color {
        return isLight() ? .black : .white
    }
}

enum Theme {
    static let fontName: String = "BebasNeue-Regular"
    static let themes: [(key: String, color: Color)] = [
        ("S", .primaryDefault),
        ("A", .primaryA),
        ("B", .primaryB),
        ("D", .primaryD),
        ("F", .primaryF),
        ("E", .primaryE),
        ("G", .primaryG),
        ("R", .primaryR)
    ]
}

struct SectionTitle: View {
    private var title: String
    init(_ title: String) {
        self.title = title
    }
    
    var body: some View {
        Text(title)
            .font(.body1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
    }
}

struct PrimaryButton: View {
    @EnvironmentObject private var settings: Settings
    
    var title: String
    var action: () -> Void
    var color: Color?
    
    init(_ title: String, color: Color? = nil, action: @escaping () -> Void) {
        self.title = title
        self.action = action
        self.color = color
    }
    
    var body: some View {
        let themeColor = color ?? settings.getThemeColor()
        Button(action: action) {
            Text(title)
                .font(.buttons)
                .foregroundColor(themeColor.textColor())
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
        }
        .background(themeColor)
        .cornerRadius(20)
        .frame(maxWidth: .infinity)
        .buttonStyle(DarkenOnTapButtonStyle(themeColor))
    }
}

struct SecondaryButton: View {
    @EnvironmentObject private var settings: Settings
    @State var title: String
    
    var color: Color?
    var action: () -> Void
    
    init(_ title: String, color: Color? = nil, action: @escaping () -> Void) {
        self.title = title
        self.action = action
        self.color = color
    }
    
    var body: some View {
        let themeColor = color ?? settings.getThemeColor()
        Button(action: {action()}) {
            Text(title)
                .font(.body2)
                .foregroundColor(themeColor)
        }
    }
}

struct RoundButton : View{
    @EnvironmentObject private var settings: Settings
    
    private var color: Color?
    private var title: String
    private var dashed: Bool
    private var fillColor: Color?
    private var textColor: Color
    private var action: ()->Void
    private let isEditMode: Bool
    private let size: CGFloat
    
    
    
    init(
        _ title: String,
        dashed: Bool = false,
        color: Color? = nil,
        fillColor: Color? = nil,
        textColor: Color? = nil,
        isEditMode: Bool = false,
        size: CGFloat = 100,
        action: @escaping ()->Void
    ){
        self.title = title
        self.action = action
        self.dashed = dashed
        self.isEditMode = isEditMode
        self.fillColor = fillColor
        self.textColor = textColor ?? fillColor?.textColor() ?? .primary
        self.color = color
        self.size = size
    }
    
    var body: some View {
        let themeColor = color ?? settings.getThemeColor()
        Button(action: action) {
            Text(title)
                .font(.body1)
                .bold()
                .foregroundColor(textColor)
                .padding(size/2)
                .frame(maxWidth: .infinity)
                .background(fillColor != nil ? fillColor : Color.clear)
        }
        .frame(minWidth: size, minHeight: size)
        .clipShape(Circle())
        .overlay{
            let innerColor: Color = isEditMode ? .red : themeColor
            if(fillColor == nil){
                if(dashed){
                    Circle().stroke(innerColor, style: StrokeStyle(lineWidth: 2, dash: [8, 4])).animation(.easeInOut(duration: 0.4), value: innerColor)
                }else{
                    Circle().stroke(innerColor, lineWidth: 2).animation(.easeInOut(duration: 0.4), value: innerColor)
                }
            }
        }
    }
}

struct CustomEditButton: View {
    @EnvironmentObject private var settings: Settings
    @Binding var isEditing: Bool
    
    private var editText: String
    private var doneText: String
    private var color: Color?
    private var action: () -> Void
    
    init(isEditing: Binding<Bool>,
         editText: String = "edit".localized("Edit button text"),
         doneText: String = "done".localized("Done button text"),
         color: Color? = nil,
         action: @escaping () -> Void
    ) {
        self._isEditing = isEditing
        self.editText = editText
        self.doneText = doneText
        self.color = color
        self.action = action
    }
    
    var body: some View {
        let themeColor = color ?? settings.getThemeColor()
        Button(action: {
            isEditing.toggle()
            action()
        }) {
            Text(isEditing ? doneText : editText)
                .font(.body2)
                .foregroundColor(themeColor)
        }
    }
}

struct Card<Content: View>: View {
    @EnvironmentObject private var settings: Settings
    private let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack(alignment:.leading) {
            content.padding().frame(maxWidth: .infinity, alignment: .leading)
        }.overlay{
            RoundedRectangle(cornerRadius: 8)
                .stroke(settings.getThemeColor(), lineWidth: 1)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }
}

struct DarkenOnTapButtonStyle: ButtonStyle {
    private var color: Color
    init(_ color: Color? = .primaryDefault) {
        self.color = color ?? .black
    }
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                configuration.isPressed
                ? color.darker(by: 0.2)
                : color
            )
            .cornerRadius(20)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension Color {
    func darker(by percentage: CGFloat) -> Color {
        let uiColor = UIColor(self)
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return Color(hue: hue, saturation: saturation, brightness: brightness * (1 - percentage), opacity: Double(alpha))
    }
}

#Preview {
    let settings = Settings()
    ScrollView{
        VStack(alignment: .leading) {
            Text("Colors").font(.body1)
            ScrollView(.horizontal){
                HStack{
                    Text("default").background(Color.primaryDefault).foregroundStyle(.black)
                    Text("primaryA").background(Color.primaryA)
                    Text("primaryB").background(Color.primaryB)
                    Text("primaryD").background(Color.primaryD)
                    Text("primaryE").background(Color.primaryE)
                    Text("primaryF").background(Color.primaryF)
                    Text("primaryG").background(Color.primaryG)
                    Text("primaryR").background(Color.primaryR)
                    Text("darkGray").background(Color.darkGray)
                    Text("lightGray").background(Color.lightGray)
                }
            }.padding()
            
            Text("Typography").font(.body1)
            VStack{
                Text("Primary").font(.primaryTitle)
                Text("Caption").font(.caption)
                Text("body1: Section title").font(.body1)
                Text("body2").font(.body1)
            }
            .padding()
            .background()
            
            Text("Buttons").font(.body1)
            VStack{
                PrimaryButton("Primary"){
                    settings.theme = "purple"
                }
                SecondaryButton("Secondary"){
                    settings.theme = "green"
                }
                RoundButton("fill", fillColor: .red){
                    
                }
                RoundButton("line"){
                    
                }
                RoundButton("dashed", dashed: true){
                    
                }
            }.padding()
            
            Card{
                Text("Card").foregroundStyle(.primary)
            }
            
        }.padding()
    }.environmentObject(settings)
}
