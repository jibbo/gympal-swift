//
//  WeightCounter.swift
//  GymFocus
//
//  Created by Giovanni De Francesco on 22/07/25.
//

import SwiftUI

struct WeightCounterView: View {
    @EnvironmentObject private var settings: Settings
    
    @State private var plates: [Double]
    @State private var sum: Double = 0
    @State private var maxKg: String = "20"
    @State private var percent: String = "70"
    @State private var weightLeft: String = "0"
    @State private var showBarbellSelector: Bool = false
    @FocusState var isWeightActive: Bool
    @FocusState var isPercentActive: Bool
    
    private let supportedWeightsKg: [Double: Color] = [0.25:.gray, 0.5:.gray, 1: .gray, 1.25:.darkGray, 2.5:.darkGray, 5:.white, 10:.green, 15:.orange, 20:.blue, 25:.red]
    private let supportedWeightsLbs: [Double: Color] = [0.25:.darkGray, 0.5:.darkGray, 0.75:.darkGray, 1:.darkGray, 2.5:.darkGray, 5:.darkGray, 10:.white, 15:.yellow, 20:.blue, 25:.green, 35:.orange, 45: .blue, 55:.red]
    
    
    init(_ plates: [Double] = []) {
        self.plates = plates
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false){
                let isIPhoneLandscape = UIDevice.current.userInterfaceIdiom == .phone &&
                                       geometry.size.width > geometry.size.height
                
                if isIPhoneLandscape {
                    horizontal()
                } else {
                    vertical()
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("done".localized("Done button")) {
                    isWeightActive = false
                    isPercentActive = false
                }
            }
        }
        .sheet(isPresented: $showBarbellSelector) {
            VStack{
                Text("select_barbell_weight".localized("Select barbell weight text")).font(.body2)
                Picker("edit".localized("Edit picker"), selection: $settings.selectedBar) {
                    let bars = settings.metricSystem ? settings.barsKg : settings.barsLbs
                    ForEach(bars, id: \.self){ bar in
                        Text(String(bar)).tag(bar)
                    }
                }
                .pickerStyle(.wheel)
                .tint(settings.getThemeColor())
                .onChange(of: settings.selectedBar){ oldVal, newVal in
                    self.maxKg = String(newVal)
                    self.plates = []
                    computeSum()
                    showBarbellSelector = false
                }
            }
        }
    }
    
    private func vertical() -> some View{
        VStack {
            if(settings.powerLifting){
                percentageCalculator()
            }
            Group{
                header()
                ScrollView(.horizontal, showsIndicators: false){
                    barbellView()
                }
                GeometryReader{ proxy in
                    countView(proxy: proxy)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                }.frame(maxHeight:50).padding()
                Spacer()
                platesPickerView()
            }.frame(minHeight: 50)
        }
        .onAppear {
            computeSum()
            maxKg = String(settings.selectedBar)
        }
    }
    
    private func horizontal() -> some View{
        HStack {
            VStack(spacing:1){
                header()
                ScrollView(.horizontal, showsIndicators: false){
                    barbellView()
                }
                GeometryReader{ proxy in
                    countView(proxy: proxy)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                }.frame(maxHeight:100)
            }
            VStack{
                if(settings.powerLifting){
                    percentageCalculator()
                }
                platesPickerView()
            }
        }
        .onAppear {
            computeSum()
            maxKg = String(settings.selectedBar)
        }
    }
    
    private func header() -> some View{
        Text("barbell".localized("Barbell label"))
            .font(.body1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
    }
    
    private func percentageCalculator() -> some View{
        VStack{
            Text("percentage_calculator".localized("Percentage calculator label"))
                .font(.body1)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                HStack(spacing: 1) { // adjust spacing if needed
                    TextField("one_rep_max".localized("One Rep Max placeholder"), text: $maxKg)
                        .font(.primaryTitle)
                        .focused($isWeightActive)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .onChange(of: maxKg) { _, newValue in
                            automaticPlates(newValue, percent)
                        }
                    Text(settings.metricSystem ? "kg".localized("Kg unit") : "lbs".localized("Lbs unit"))
                        .font(.body2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 1) {
                    TextField("%", text: $percent)
                        .font(.primaryTitle)
                        .focused($isPercentActive)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .onChange(of: percent) { _, newValue in
                            automaticPlates(maxKg, newValue)
                        }
                        .onSubmit {
                            automaticPlates(maxKg, percent)
                        }
                    Text("%")
                        .font(.body2)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }.padding()
    }
    
    private func automaticPlates(_ value: String, _ percent: String){
        let barWeight = Double(settings.selectedBar)
        let percent = Double(percent) ?? 100
        let weight = (Double(value) ?? 0) * (percent/100)
        let weightPerSide = (weight - barWeight) / 2
        
        plates.removeAll()
        
        // Impossible if target is less than bar weight or not divisible by 2
        if weightPerSide < 0.25 {
            // TODO show error alert
            return
        }
        
        var remaining = weightPerSide
        
        let availablePlates = settings.metricSystem ? supportedWeightsKg.keys.sorted{$0>$1} : supportedWeightsLbs.keys.sorted{$0>$1}
        for plate in availablePlates {
            while remaining >= plate - 0.001 {
                plates.append(plate)
                remaining -= plate
            }
        }
        
        plates.sort{$0 > $1}
        
        computeSum()
    }
    
    private func addPlate(_ weight: Double) {
        plates.append(weight)
        plates.sort{$0 > $1}
        computeSum()
    }
    
    private func displayPlate(_ weight: Double) -> some View{
        let minWeight: Double = settings.metricSystem ? 2.5 : 5.5
        let height: CGFloat = weight <= minWeight ? 75 : 150
        let width: CGFloat = weight <= minWeight ? 25 : (settings.metricSystem ? weight*2 : weight/1.25)
        let supportedWeights = settings.metricSystem ? supportedWeightsKg : supportedWeightsLbs
        return ZStack{
            let color = supportedWeights[weight] ?? Color.black
            RoundedRectangle(cornerRadius: 3).fill(color)
            let weightText = weight.truncatingRemainder(dividingBy: 1) > 0 ? String(format: "%.2f", weight) : String(Int(weight))
            Text(weightText).font(.body2).foregroundStyle(color.textColor())
        }.frame(width:width, height: height);
    }
    
    private func computeSum(){
        let barWeight = Double(settings.selectedBar)
        sum =  (plates.reduce(0, +)) * 2 + barWeight
    }
    
    private func getUnitMeasure() -> String{
        settings.metricSystem ? "kg".localized("Kg unit") : "lbs".localized("Lbs unit")
    }
    
    private func plateText(_ weight: Double) -> String{
        let unitMeasure = getUnitMeasure()
        if(weight.truncatingRemainder(dividingBy: 1) == 0 ){
            return "\(String(Int(weight))) \(unitMeasure)"
        } else {
            return "\(String(format: "%.2f", weight)) \(unitMeasure)"
        }
    }
    
    private func barbellView() -> some View{
        HStack(spacing: 1){
            let wid: CGFloat = Double(150-(plates.count*25))
            Rectangle().fill(Color.lightGray).frame(width:50, height: 25)
            Rectangle().fill(Color.lightGray).frame(width:10, height: 65)
            ForEach(plates.indices, id: \.self) { index in
                displayPlate(plates[index]).onTapGesture {
                    plates.remove(at: index)
                    computeSum()
                }
            }
            ZStack{
                Rectangle().fill(Color.lightGray).frame(width:wid, height: 45)
                Text(String(settings.selectedBar))
                    .font(.body2)
                    .foregroundColor(.white)
            }.onTapGesture {
                showBarbellSelector = true
            }
        }
        .padding()
        .frame(height: 100)
    }
    
    private func countView(proxy: GeometryProxy) -> some View{
        HStack(alignment: .bottom){
            let fontSize:CGFloat = proxy.size.height>=500 ? 95 : 55
            Text(String(sum)).font(.custom(Theme.fontName, size: fontSize).bold())
            Text(getUnitMeasure()).font(.body1).padding(.vertical)
        }
    }
    
    private func platesPickerView() -> some View{
        Group{
            Text("plates".localized("Plates label"))
                .font(.body1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            ScrollView(.horizontal, showsIndicators: false){
                HStack(spacing:2){
                    let supportedWeights = settings.metricSystem ? supportedWeightsKg : supportedWeightsLbs
                    ForEach(Array(supportedWeights.keys.sorted()), id: \.self){ key in
                        if(supportedWeights[key] == .white || supportedWeights[key] == .yellow){
                            RoundButton(plateText(key), fillColor: supportedWeights[key], textColor: .black, size: 90 ){
                                addPlate(key)
                            }
                        }else{
                            RoundButton(plateText(key), fillColor: supportedWeights[key], textColor: .white, size: 90){
                                addPlate(key)
                            }
                        }
                    }
                }.onAppear{
                    plates.sort{$0 > $1}
                    computeSum()
                }
            }
        }
    }
}

#Preview{
    let settings = Settings()
    WeightCounterView().environmentObject(settings).onAppear {
        settings.metricSystem = false
        settings.powerLifting = true
    }
}
