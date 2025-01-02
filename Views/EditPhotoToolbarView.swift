import SwiftUI

struct EditPhotoToolbarView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @ObservedObject var viewModel: PhotoModel
    
    enum EditPanels {
        case empty
        case background
        case time
        case coordinate
        
        mutating func toggle(to panel: EditPanels) {
            self = self != panel ? panel : .empty
        }
    }
    @State private var panel = EditPanels.empty
    
    @ViewBuilder var activeView: some View {
        switch panel {
        case .empty:
            EmptyView()
        case .background:
            BackgroundColorSelectSubView(colors: viewModel.enabledColors, selectedIndex: $viewModel.backgroundColorIndex)
        case .time:
            TimeEditSubView(displayTime: $viewModel.isTimeDisplayed)
        case .coordinate:
            EmptyView()
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(colorScheme == .light ? .white : .black)
                .fill(.bar)
                .foregroundStyle(colorScheme == .light ? .white : .black)
                .opacity(0.8)
                .frame(height: CommonUtils.safeTopInset + 44)
            
            Spacer()
            
            activeView
//                .frame(height: 300)
                .transition(.opacity) // 使用缩放过渡动画
                .animation(.easeInOut, value: panel)
            
            HStack{
                CustomTabButton(iconName: "photo.circle.fill", labelText: "水印开关") {
                    LoggerManager.shared.debug("显示水印按钮点击")
                    viewModel.isWatermarkDisplayed.toggle()
                }
                
                // 背景颜色按钮
                CustomTabButton(iconName: "circle.tophalf.filled.inverse", labelText: "背景颜色") {
                    LoggerManager.shared.debug("背景颜色按钮点击")
                    withAnimation {
                        panel.toggle(to: .background)
                    }
                }
                .disabled(!(viewModel.watermark is BackgroundEditable))
                
                // 日期时间按钮
                CustomTabButton(iconName: "calendar.circle.fill", labelText: "日期时间") {
                    LoggerManager.shared.debug("日期时间按钮点击")
                    withAnimation {
                        panel.toggle(to: .time)
                    }
                }
                .disabled(!(viewModel.watermark is TimeEditable))
                
                // 经纬度按钮
                CustomTabButton(iconName: "location.circle.fill", labelText: "地理位置") {
                    LoggerManager.shared.debug("地理位置按钮点击")
                    withAnimation {
                        panel.toggle(to: .coordinate)
                    }
                }
                .disabled(!(viewModel.watermark is CoordinateEditable))
                
                CustomTabButton(iconName: "info.circle.fill", labelText: "照片信息") {
                    LoggerManager.shared.debug("照片信息按钮点击")
                    viewModel.isSheetPresented.toggle()
                }
                .disabled(!(viewModel.watermark is InfoDisplayable))
            }
            .frame(height: 44)
            .padding(.top, 10)
            .padding(.bottom, CommonUtils.safeBottomInset)
            .padding(.horizontal, 10)
            .background(
                Rectangle()
                    .fill(.bar)
                    .foregroundStyle(colorScheme == .light ? .white : .black)
                    .opacity(0.8)
            )
        }
    }
}
