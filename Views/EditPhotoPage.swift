import SwiftUI
import PhotosUI

struct EditPhotoPage: View {
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
        VStack {
            GeometryReader { geometry in
                switch viewModel.imageState {
                case .empty:
                    VStack {
                        Image(systemName: "questionmark.circle.dashed")
                            .scaledToFit()
                            .font(.system(size: 40))
                            .foregroundStyle(.gray)
                        Text("图片未加载")
                            .foregroundStyle(.gray)
                            .padding([.top], 8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .loading:
                    ProgressView()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                case .success(let image):
                    PhotoDisplayView(geometry: geometry, image: image)
                case .failure:
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
            }
            .frame(maxHeight: .infinity) // 占据剩余空间
            
            HStack{
                CustomTabButton(iconName: "calendar", labelText: "日期") {
                    print("Home button tapped")
                    isShowingListView.toggle()
                }
                CustomTabButton(iconName: "location.fill", labelText: "经纬度") {
                    print("Favorite button tapped")
                }
                CustomTabButton(iconName: "person", labelText: "Profile") {
                    print("Profile button tapped")
                }
            }
        }
        .background(Color(hex: "#282828"))
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
    }
}

struct PhotoDisplayView: View {
    let geometry: GeometryProxy
    let image: Image
    
    // 控制图片显示的参数
    @State private var scale: CGFloat = 1.0 // 控制缩放比例
    @State private var lastScale: CGFloat = 1.0 // 保存上一次的缩放比例
    @State private var offset: CGSize = .zero // 偏移量
    @State private var lastOffset: CGSize = .zero // 上一次偏移量
    
    var body: some View {
        ZStack {
            Color.white
                .opacity(0.01)
                .frame(width: geometry.size.width, height: geometry.size.height)
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
