import SwiftUI

struct TimeEditSubView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var isOn: Bool
    
    @Binding var displayTime: Bool
    
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
    
    @State private var isDatePickerVisible = false
    @State private var isTimePickerVisible = false
    
    var body: some View {
        VStack(spacing: 20) {
            Button(action: {
                withAnimation {
                    displayTime.toggle()
                    if !displayTime && isDatePickerVisible || isTimePickerVisible {
                        isDatePickerVisible = false
                        isTimePickerVisible = false
                    }
                }
            }) {
                HStack {
                    Text("显示时间")
                        .font(.headline)
                        .foregroundStyle(.black)
                    
                    Spacer()
                    
                    Image(systemName: displayTime ? "checkmark.circle" : "circle")
                        .padding(.trailing, 4)
                }
            }
            .frame(height: 40)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            
            if displayTime {
                HStack {
                    Text("拍摄时间")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            isDatePickerVisible.toggle()
                            if isTimePickerVisible {
                                isTimePickerVisible = false
                            }
                        }
                    }) {
                        Text(formattedDate())
                            .font(.body)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    
                    Button(action: {
                        withAnimation {
                            isTimePickerVisible.toggle()
                            if isDatePickerVisible {
                                isDatePickerVisible = false
                            }
                        }
                    }) {
                        Text(formattedTime())
                            .font(.body)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                .frame(height: 40)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            if isDatePickerVisible {
                VStack {
                    HStack {
                        Picker("年", selection: $selectedYear) {
                            ForEach(currentYear-100...currentYear+100, id: \.self) { year in
                                Text("\(formattedNumber(year)) 年").tag(year)
                            }
                        }
                        .frame(width: 100)
                        .clipped()
                        
                        Picker("月", selection: $selectedMonth) {
                            ForEach(months, id: \.self) { month in
                                Text("\(month) 月").tag(month)
                            }
                        }
                        .frame(width: 80)
                        .clipped()
                        
                        Picker("日", selection: $selectedDay) {
                            ForEach(daysInMonth(year: selectedYear, month: selectedMonth), id: \.self) { day in
                                Text("\(day) 日").tag(day)
                            }
                        }
                        .frame(width: 80)
                        .clipped()
                    }
                    .pickerStyle(WheelPickerStyle())
                    .padding()
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            if isTimePickerVisible {
                VStack {
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
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            HStack {
                Spacer()
                Button("恢复默认") {
                    LoggerManager.shared.debug("恢复默认")
                }
                Spacer()
                Button("应用") {
                    LoggerManager.shared.debug("应用")
                }
                Spacer()
            }
            .frame(height: 40)
        }
        .padding(20)
        .background(
            Rectangle()
                .fill(.bar)
                .foregroundStyle(colorScheme == .light ? .white : .black)
                .opacity(0.8)
        )
        .transition(.opacity)
        .opacity(isOn ? 1 : 0) // 渐变透明度
        .offset(y: isOn ? 0 : 20) // 向上的动画
        .animation(.easeInOut(duration: 0.2), value: isOn) // 动画效果
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

