import SwiftUI

struct EditPhotoToolbarView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @ObservedObject var viewModel: PhotoModel
    
    @ViewBuilder private var activeView: some View {
        switch viewModel.panel {
        case .empty:
            EmptyView()
        case .background:
            EditColorSubView(colors: viewModel.enabledColors, selectedIndex: $viewModel.backgroundColorIndex)
        case .time:
            EditTimeSubView(viewModel: viewModel)
        case .coordinate:
            EmptyView()
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            activeView
                .transition(.opacity) // 使用缩放过渡动画
                .animation(.easeInOut, value: viewModel.panel)
                .background(
                    Rectangle()
                        .fill(
                            colorScheme == .dark
                            ? .black.opacity(0.8)
                            : .white.opacity(0.5)
                        )
                        .background(.thinMaterial)
                )
            
            HStack{
                // 背景颜色按钮
                CustomTabButton(iconName: "circle.tophalf.filled.inverse", labelText: "颜色") {
                    LoggerManager.shared.debug("背景颜色按钮点击")
//                    withAnimation {
//                        panel.toggle(to: .background)
//                    }
                    if viewModel.backgroundColorIndex == 0 {
                        viewModel.backgroundColorIndex = 1
                    } else {
                        viewModel.backgroundColorIndex = 0
                    }
                }
                .disabled(!(viewModel.watermark is BackgroundEditable))
                
                // 日期时间按钮
                CustomTabButton(iconName: "calendar.circle.fill", labelText: "时间") {
                    LoggerManager.shared.debug("日期时间按钮点击")
                    withAnimation {
                        viewModel.setPanel(to: .time)
                    }
                }
                .disabled(!(viewModel.watermark is TimeEditable))
                
                // 经纬度按钮
                CustomTabButton(iconName: "location.circle.fill", labelText: "位置") {
                    LoggerManager.shared.debug("地理位置按钮点击")
                    withAnimation {
                        viewModel.setPanel(to: .coordinate)
                    }
                    viewModel.isCoordinateDisplayed.toggle()
                    
                    // TODO: 将经纬度信息转换为实际地址
                    if let latitude = viewModel.exifData.latitude,
                       let longitude = viewModel.exifData.longitude {
                        Task {
                            do {
                                let address = try await CommonUtils.getAddressFromCoordinates(latitude: latitude, longitude: longitude)
                                LoggerManager.shared.debug("Address: \(address)")
                            } catch {
                                LoggerManager.shared.error("Error: \(error.localizedDescription)")
                            }
                        }
                    }
                }
                .disabled(!(viewModel.watermark is CoordinateEditable))
                
                CustomTabButton(iconName: "info.circle.fill", labelText: "信息") {
                    LoggerManager.shared.debug("照片信息按钮点击")
                    viewModel.isPhotoInfoPanelDisplayed.toggle()
                }
                .disabled(!(viewModel.watermark is InfoDisplayable))
            }
            .frame(height: 44)
            .padding(.top, 10)
            .padding(.bottom, CommonUtils.safeBottomInset)
            .padding(.horizontal, 30)
            .background(
                Rectangle()
                    .fill(
                        colorScheme == .dark
                        ? .black.opacity(0.8)
                        : .white.opacity(0.5)
                    )
                    .background(.regularMaterial)
            )
        }
    }
}
