import SwiftUI
import PhotosUI

struct EditPhotoPage: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var viewModel: PhotoModel
    
    let onDisappearAction: () -> Void
    
    // 设置页面 Sheet 的设置
    @State private var isSheetPresented = false
    @State private var settingsDetent = PresentationDetent.large
    
    // 控制开关
    @State private var displayTime = false // 显示时间的开关
    @State private var displayCoordinate = false // 显示经纬度的开关
    
    @State private var isShowingListView = false
    
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
                    EditPhotoDisplayView(geometry: geometry, image: image)
                }
            }
            .frame(maxHeight: .infinity) // 占据剩余空间
            .background(
                colorScheme == .light
                ? Color(hex: "#F2F3F5")
                : Color(hex: "#101010")
            )
            
            VStack {
                Rectangle()
                    .fill(colorScheme == .light ? .white : .black)
                    .fill(.bar)
                    .foregroundStyle(colorScheme == .light ? .white : .black)
                    .opacity(0.8)
                    .frame(height: CommonUtils.safeTopInset + 44)
                
                Spacer()
                
                HStack{
                    CustomTabButton(iconName: "photo.circle.fill", labelText: "水印开关") {
                        LoggerManager.shared.debug("显示水印按钮点击")
                        if let uiImage = viewModel.uiImage,
                           let data = viewModel.watermarkData {
                            viewModel.imageModification = PhotoUtils.addWhiteAreaToBottom(of: uiImage, data: data)
                        }
                    }
                    
                    CustomTabButton(iconName: "circle.tophalf.filled.inverse", labelText: "背景颜色") {
                        print("Profile button tapped")
                    }
                    
                    CustomTabButton(iconName: "calendar.circle.fill", labelText: "日期时间") {
                        print("Home button tapped")
                        viewModel.displayTime.toggle()
                    }
                    
                    // 经纬度按钮
                    CustomTabButton(iconName: "location.circle.fill", labelText: "地理位置") {
                        print("Favorite button tapped")
                        viewModel.displayCoordinate.toggle()
                    }
                    
                    CustomTabButton(iconName: "info.circle.fill", labelText: "照片信息") {
                        print("Profile button tapped")
                    }
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
                    print("pressed")
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
    
    // 控制图片显示的参数
    private static let defaultScale: CGFloat = 0.95 // 初始缩放比例，为1.0时左右填满屏幕
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
            
            image
                .resizable()
                .scaledToFit()
                .scaleEffect(scale) // 缩放
                .offset(offset) // 偏移
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
                .gesture(
                    // 双击
                    TapGesture(count: 2)
                        .onEnded {
                            withAnimation {
                                if offset != .zero {
                                    offset = .zero
                                    lastOffset = .zero
                                } else {
                                    scale = scale == 1.0 ? 2.0 : 1.0
                                }
                            }
                        }
                )
//                .aspectRatio(contentMode: .fill)
                .frame(width: geometry.size.width, height: geometry.size.height)
//                .draggable(image)
                .listRowInsets(EdgeInsets())
        }
        .clipped()
    }
}

#Preview {
    EditPhotoPage(viewModel: PhotoModel()) {}
}
