import SwiftUI
import PhotosUI

struct EditPhotoPage: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @ObservedObject var viewModel: PhotoModel
    
    let onDisappearAction: () -> Void
    
    // 设置页面 Sheet 的设置
    @State private var isSheetPresented = false
    @State private var settingsDetent = PresentationDetent.large
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                switch viewModel.imageState {
                case .empty, .failure:
                    VStack(spacing: 4) {
                        Image(systemName: "photo.badge.exclamationmark.fill")
                            .scaledToFit()
                            .font(.system(size: 50))
                            .foregroundStyle(.secondary)
                        Text("图片未加载")
                            .font(.system(.footnote))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .loading:
                    ProgressView()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                case .success(let image):
                    EditPhotoDisplayView(geometry: geometry, image: image, watermark: viewModel.watermarkImage, displayWatermark: viewModel.displayWatermark)
                        .shadow(
                            color: colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.2),
                            radius: colorScheme == .dark ? 20 : 10,
                            x: 0, y: 0
                        )
                }
            }
            .frame(maxHeight: .infinity) // 占据剩余空间
            .background(
                colorScheme == .light
                ? Color(hex: 0xF2F3F5)
                : Color(hex: 0x101010)
            )
            
            VStack(spacing: 0) {
                Rectangle()
                    .fill(colorScheme == .light ? .white : .black)
                    .fill(.bar)
                    .foregroundStyle(colorScheme == .light ? .white : .black)
                    .opacity(0.8)
                    .frame(height: CommonUtils.safeTopInset + 44)
                
                Spacer()
                
                if viewModel.watermark is BackgroundEditable {
                    BackgroundColorSelectSubView(isOn: $viewModel.displayBackgroundColorSubview, colors: viewModel.enabledColors, selectedIndex: $viewModel.backgroundColorIndex)
                }
                
                HStack{
                    CustomTabButton(iconName: "photo.circle.fill", labelText: "水印开关") {
                        LoggerManager.shared.debug("显示水印按钮点击")
                        viewModel.displayWatermark.toggle()
                    }
                    
                    // 背景颜色按钮
                    CustomTabButton(iconName: "circle.tophalf.filled.inverse", labelText: "背景颜色") {
                        LoggerManager.shared.debug("背景颜色按钮点击")
                        viewModel.displayBackgroundColorSubview.toggle()
                    }
                    .disabled(!(viewModel.watermark is BackgroundEditable))
                    
                    // 日期时间按钮
                    CustomTabButton(iconName: "calendar.circle.fill", labelText: "日期时间") {
                        LoggerManager.shared.debug("日期时间按钮点击")
                        viewModel.displayTime.toggle()
                    }
                    .disabled(!(viewModel.watermark is TimeEditable))
                    
                    // 经纬度按钮
                    CustomTabButton(iconName: "location.circle.fill", labelText: "地理位置") {
                        LoggerManager.shared.debug("地理位置按钮点击")
                        viewModel.displayCoordinate.toggle()
                    }
                    .disabled(!(viewModel.watermark is CoordinateEditable))
                    
                    CustomTabButton(iconName: "info.circle.fill", labelText: "照片信息") {
                        LoggerManager.shared.debug("照片信息按钮点击")
                        isSheetPresented.toggle()
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
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // 关闭按钮
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    viewModel.imageLoaded.toggle() // 设置为 false 以 pop 页面
                    onDisappearAction()
                } label: {
                    Image(systemName: "xmark.circle")
                }
            }
            
            // 保存按钮
            ToolbarItem {
                Button {
                    LoggerManager.shared.debug("保存按钮点击")
                    if let uiImage = viewModel.fullImage {
                        PhotoSaver.with(uiImage: uiImage)
                    }
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
            }
        }
        .sheet(isPresented: $isSheetPresented) {
            HalfTransparentSheetView(isSheetPresented: $isSheetPresented, viewModel: viewModel)
                .presentationBackground(.ultraThinMaterial)
                .presentationDetents([.fraction(0.2), .medium, .large], selection: $settingsDetent)
                .presentationDragIndicator(.visible)
        }
        .onDisappear(perform: onDisappearAction)
        .ignoresSafeArea(.all)
    }
}

struct EditPhotoDisplayView: View {
    let geometry: GeometryProxy
    let image: Image
    let watermark: UIImage?
    let displayWatermark: Bool
    
    // 控制图片显示的参数
    private static let defaultScale: CGFloat = 0.9 // 初始缩放比例，为1.0时左右填满屏幕
    @State private var scale: CGFloat = defaultScale // 控制缩放比例
    @State private var lastScale: CGFloat = defaultScale // 保存上一次的缩放比例
    @State private var offset: CGSize = .zero // 偏移量
    @State private var lastOffset: CGSize = .zero // 上一次偏移量
    
    var body: some View {
        ZStack {
            Color.white
                .opacity(0)
                .contentShape(Rectangle())
                .gesture(
                    // 双击
                    TapGesture(count: 2)
                        .onEnded {
                            withAnimation {
                                if offset != .zero {
                                    offset = .zero
                                    lastOffset = .zero
                                }
                            }
                        }
                )
            
            VStack(spacing: 0) {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width)
                    .listRowInsets(EdgeInsets())
                
                if let watermark,
                   displayWatermark {
                    Image(uiImage: watermark)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width)
                }
            }
            .frame(width: geometry.size.width)
            .scaleEffect(scale) // 缩放
            .offset(offset) // 偏移
            .gesture(
                // 双击
                TapGesture(count: 2)
                    .onEnded {
                        withAnimation {
                            if offset != .zero {
                                offset = .zero
                                lastOffset = .zero
                            } else {
                                scale = scale == EditPhotoDisplayView.defaultScale ? 2.0 : EditPhotoDisplayView.defaultScale
                            }
                        }
                    }
            )
            .gesture(
                // 拖拽
                DragGesture()
                    .onChanged { value in
                        offset = CGSize(
                            width: lastOffset.width + value.translation.width,
                            height: lastOffset.height + value.translation.height
                        )
                    }
                    .onEnded { _ in
                        lastOffset = offset
                    }
                    .simultaneously(
                        with: MagnificationGesture()
                            .onChanged { value in
                                scale = lastScale * value
                            }
                            .onEnded { _ in
                                lastScale = scale
                            }
                    )
            )
            .gesture(
                // 双指放大
                MagnificationGesture()
                    .onChanged { value in
                        scale = lastScale * value // 动态更新缩放比例
                    }
                    .onEnded { _ in
                        lastScale = scale // 保存最终缩放比例
                    }
            )
        }
        .clipped()
    }
}

#Preview {
    EditPhotoPage(viewModel: PhotoModel()) {}
}

// MARK: - 按钮

// 工具栏按钮
struct CustomTabButton: View {
    let iconName: String
    let labelText: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }) {
            VStack(spacing: 4) {
                ZStack {
                    Rectangle()
                        .fill(Color.white.opacity(0))
                    Image(systemName: iconName)
                        .symbolVariant(.circle.fill)
                        .foregroundStyle(Color(hex: 0x282828))
//                        .resizable()
//                        .scaledToFit()
                        .font(.system(size: 24))
//                        .frame(height: 20)
                }
                .frame(/*width: 20, */height: 30)
                Text(labelText)
                    .font(.caption)
                    .foregroundColor(Color(hex: 0x282828))
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - 选择背景颜色子选单

struct BackgroundColorSelectSubView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var isOn: Bool
    let colors: [Color]
    @Binding var selectedIndex: Int
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ForEach(Array(colors.enumerated()), id: \.offset) { index, color in
                    ColorSelectButton(index: index, selectedIndex: $selectedIndex, color: color) {
                        selectedIndex = index
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(height: 44)
        }
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
}

struct ColorSelectButton: View {
    let index: Int
    @Binding var selectedIndex: Int
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 40, height: 40)
                .shadow(color: .gray.opacity(0.15), radius: 2.5, x: 0, y: 0) // 添加阴影
                .overlay(
                    Circle()
                        .stroke(selectedIndex == index ? Color.red : Color.white, lineWidth: 2) // 添加边框
                )
        }
        .buttonStyle(PlainButtonStyle()) // 去掉默认按钮样式
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}
