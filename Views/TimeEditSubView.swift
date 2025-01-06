import SwiftUI

// MARK: - 调整是否在水印上显示时间的子菜单

struct TimeEditSubView: View {
    @Environment(\.colorScheme) private var colorScheme

    @Binding var isTimeDisplayed: Bool
    
    var displayTime: Date = Date()
    
    @State private var selectedDate = Date()
    @State private var selectedTimeZone = TimeZone.current
    
    @State private var isShowingSheet = false
    
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
            TimeEditSheet(selectedDate: $selectedDate, selectedTimeZone: $selectedTimeZone)
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
    
//    // 格式化日期
//    private func formattedDate() -> String {
//        "\(selectedYear)-\(String(format: "%02d", selectedMonth))-\(String(format: "%02d", selectedDay))"
//    }
//    
//    // 格式化时间
//    private func formattedTime() -> String {
//        var components = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
//        components.hour = selectedHour
//        components.minute = selectedMinute
//        components.second = selectedSecond
//        
//        if let date = Calendar.current.date(from: components) {
//            let formatter = DateFormatter()
//            formatter.dateFormat = "HH:mm:ss"
//            return formatter.string(from: date)
//        }
//        return "Invalid Date"
//    }
}

// MARK: - 调整日期与时间的Sheet

struct TimeEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedDate: Date
    @Binding var selectedTimeZone: TimeZone
    @State private var selectedTimeZoneID: String = "" {
        didSet {
            selectedTimeZone = TimeZone(identifier: selectedTimeZoneID) ?? .current
        }
    }
    
    @State private var selectedHour = Calendar.current.component(.hour, from: Date())
    @State private var selectedMinute = Calendar.current.component(.minute, from: Date())
    @State private var selectedSecond = Calendar.current.component(.second, from: Date())
    
    @State private var isShowingPopover = false
    
    var displayTime: Date = Date()
    
    var body: some View {
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
                    VStack {
                        DatePicker("调整日期", selection: $selectedDate, displayedComponents: [.date])
                            .datePickerStyle(.graphical)
                        
                        HStack {
                            Text("时间")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: {
                                isShowingPopover.toggle()
                            }) {
                                Text("12:12:12")
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 12)
                                    .background(Color(hex: 0xF0F0F0))
                                    .foregroundColor(isShowingPopover ? .blue : .black)
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                            .buttonStyle(BorderlessButtonStyle())
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
                                .presentationCompactAdaptation(.none)
                            }
                        }
                    }
                    
                    NavigationLink(destination: TimeZonePicker(selectedTimeZoneID: $selectedTimeZoneID)) {
                        HStack {
                            Text("时区")
                            Spacer()
                            Text(selectedTimeZoneID)
                                .foregroundStyle(.gray)
                        }
                    }
                }
            }
            .navigationTitle("调整日期与时间")
            .navigationBarTitleDisplayMode(.inline) // 标题居中
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("调整") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                selectedTimeZoneID = selectedTimeZone.identifier
            }
        }
    }
}

// MARK: - 调整时区的页面

struct TimeZonePicker: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedTimeZoneID: String
    @State private var searchText: String = ""
    
    private let timeZones = TimeZone.knownTimeZoneIdentifiers
    private var filteredTimeZones: [String] {
        if searchText.isEmpty {
            timeZones
        } else {
            timeZones.filter {
                let localizedName = TimeZone(identifier: $0)?.localizedName ?? $0
                return localizedName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            List(filteredTimeZones, id: \.self) { timeZone in
                Button(action: {
                    selectedTimeZoneID = timeZone
                    dismiss() // 返回上一页面
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(TimeZone(identifier: timeZone)?.localizedName ?? timeZone)
                                .font(.headline)
                                .foregroundStyle(.black)
                            Text(timeZone)
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                        }
                        Spacer()
                        if selectedTimeZoneID == timeZone {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 5)
                }
                .id(timeZone)
            }
            .onAppear {
                Task {
                    proxy.scrollTo(selectedTimeZoneID, anchor: .center) // 滚动到选定时区
//                    searchText = selectedTimeZone
                }
            }
        }
        .navigationTitle("选择时区")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    print(Locale.current)
                    dismiss() // 返回上一页面
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("时区选择").font(.headline)
            }
        }
    }
}

private extension TimeZone {
    
    /// 将时区ID转换为本地化名称，例如“Asia/Shanghai” -> “上海（中国）”
    var localizedName: String {
        let identifier = self.identifier
        let locale = Locale.current // 使用当前设备语言设置
        let timeZoneName = TimeZone(identifier: identifier)?.localizedName(for: .standard, locale: locale) ?? identifier
        return timeZoneName
    }
    
    /// 获取时区偏移量字符串（例如 "+08:00"）
    var gmtOffsetString: String {
        let seconds = secondsFromGMT()
        let hours = seconds / 3600
        let minutes = abs(seconds % 3600) / 60
        return String(format: "%+.2d:%.2d", hours, minutes)
    }
    
}
