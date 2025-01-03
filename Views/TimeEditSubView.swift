import SwiftUI

struct TimeEditSubView: View {
    @Environment(\.colorScheme) private var colorScheme

    @Binding var isTimeDisplayed: Bool
    
    var displayTime: Date = Date()
    
//    let defaultTime: String
//    var customTime: String
    
//    @Binding var time: String
    @State private var selectedDate = Date()
    
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedDay = Calendar.current.component(.day, from: Date())
    @State private var selectedHour = Calendar.current.component(.hour, from: Date())
    @State private var selectedMinute = Calendar.current.component(.minute, from: Date())
    @State private var selectedSecond = Calendar.current.component(.second, from: Date())
    
    private let currentYear = Calendar.current.component(.year, from: Date())
    private let months = Array(1...12)
    
    @State private var isShowingSheet = false
    @State private var isShowingPopover = false
    
    var body: some View {
        VStack {
            Button(action: {
                withAnimation {
                    isTimeDisplayed.toggle()
                }
            }) {
                HStack {
                    Text("显示日期与时间")
                        .font(.headline)
                        .foregroundStyle(.black)
                    
                    Spacer()
                    
                    Image(systemName: isTimeDisplayed ? "checkmark.circle" : "circle")
                        .padding(.trailing, 4)
                }
            }
            .buttonStyle(BorderlessButtonStyle())
            .frame(height: 20)
            .padding()
            
            if isTimeDisplayed {
                HStack {
                    Text("\(displayTime.print())")
                        .font(.headline)
                    Spacer()
                    Button("调整") {
                        isShowingSheet.toggle()
                    }
                }
                .frame(height: 20)
                .padding()
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut, value: isTimeDisplayed)
            }
        }
        .padding(12)
        .background(
            Rectangle()
                .fill(.bar)
                .foregroundStyle(colorScheme == .light ? .white : .black)
                .opacity(0.8)
        )
        .sheet(isPresented: $isShowingSheet) {
            NavigationStack {
                List {
                    Section {
                        HStack {
                            Text("调整前")
                            Spacer()
                            Text("\(displayTime.print())")
                                .foregroundStyle(.gray)
                        }
                        
                        HStack {
                            Text("调整后")
                            Spacer()
                            Text("\(displayTime.print())")
                        }
                    }
                    
                    Section {
                        DatePicker("调整日期", selection: $selectedDate, displayedComponents: [.date])
                            .datePickerStyle(.graphical)
                        
                        HStack {
                            Text("时间")
                            
                            Spacer()
                            
                            Button(action: {
                                isShowingPopover.toggle()
                            }) {
                                Text("12:12:12")
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 8)
                                    .background(isShowingPopover ? .blue : .gray)
                                    .foregroundColor(isShowingPopover ? .white : .white)
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                            .popover(isPresented: $isShowingPopover) {
                                HStack {
                                    Picker("时", selection: $selectedHour) {
                                        ForEach(0..<24, id: \.self) { Text("\($0) h") }
                                    }
                                    .frame(width: 80)
                                    .clipped()
                                    
                                    Picker("分", selection: $selectedMinute) {
                                        ForEach(0..<60, id: \.self) { Text("\($0) m") }
                                    }
                                    .frame(width: 80)
                                    .clipped()
                                    
                                    Picker("秒", selection: $selectedSecond) {
                                        ForEach(0..<60, id: \.self) { Text("\($0) s") }
                                    }
                                    .frame(width: 80)
                                    .clipped()
                                }
                                .pickerStyle(WheelPickerStyle())
                                .padding()
                                .frame(width: 240, height: 200)
                                .presentationCompactAdaptation(.none)
                            }
                        }
                        
//                        if isShowingPopover {
//                            HStack {
//                                Picker("时", selection: $selectedHour) {
//                                    ForEach(0..<24, id: \.self) { Text("\($0) h") }
//                                }
//                                .frame(width: 80)
//                                .clipped()
//                                
//                                Picker("分", selection: $selectedMinute) {
//                                    ForEach(0..<60, id: \.self) { Text("\($0) m") }
//                                }
//                                .frame(width: 80)
//                                .clipped()
//                                
//                                Picker("秒", selection: $selectedSecond) {
//                                    ForEach(0..<60, id: \.self) { Text("\($0) s") }
//                                }
//                                .frame(width: 80)
//                                .clipped()
//                            }
//                            .pickerStyle(WheelPickerStyle())
//                            .padding()
//                            .transition(.scale)
//                            .animation(.easeInOut, value: isShowingPopover)
//                        }
                        
                        Text("时区")
                    }
                }
                .navigationTitle("调整日期与时间")
                .navigationBarTitleDisplayMode(.inline) // 标题居中
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("取消") {
                            isShowingSheet.toggle()
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("调整") {
                            isShowingSheet.toggle()
                        }
                    }
                }
            }
            .presentationBackground(.ultraThickMaterial)
            .interactiveDismissDisabled(true)
        }
    }
    
    // 计算每月的天数
    private func daysInMonth(year: Int, month: Int) -> [Int] {
        let dateComponents = DateComponents(year: year, month: month)
        let calendar = Calendar.current
        guard let date = calendar.date(from: dateComponents),
              let range = calendar.range(of: .day, in: .month, for: date) else {
            return []
        }
        return Array(range)
    }
    
    // 格式化日期
    private func formattedDate() -> String {
        "\(selectedYear)-\(String(format: "%02d", selectedMonth))-\(String(format: "%02d", selectedDay))"
    }
    
    // 格式化时间
    private func formattedTime() -> String {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
        components.hour = selectedHour
        components.minute = selectedMinute
        components.second = selectedSecond
        
        if let date = Calendar.current.date(from: components) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            return formatter.string(from: date)
        }
        return "Invalid Date"
    }
    
    // 格式化大数字（年份）
    private func formattedNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = false // 禁用千位分隔符
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}
