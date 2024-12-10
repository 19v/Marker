import SwiftUI
import PhotosUI

struct EditPhotoPage: View {
    @StateObject var viewModel = PhotoModel()
    
    // 设置页面 Sheet 的设置
    @State private var isSheetPresented = false
    @State private var settingsDetent = PresentationDetent.large
    
    // 控制开关
    @State private var displayTime = false // 显示时间的开关
    @State private var displayCoordinate = false // 显示经纬度的开关
    
    // 控制图片显示的参数
    @State private var scale: CGFloat = 1.0 // 控制缩放比例
    @State private var lastScale: CGFloat = 1.0 // 保存上一次的缩放比例
    @State private var offset: CGSize = .zero // 偏移量
    @State private var lastOffset: CGSize = .zero // 上一次偏移量
    
    var body: some View {
        VStack {
            // MARK: 顶部工具栏
            HStack {
                Spacer()
                
                Button(action: {
                    isSheetPresented.toggle()
                }) {
                    Image(systemName: "gearshape")
                        .foregroundColor(.white)
                        .padding()
                }
                .background(Circle().fill(Color(hex: "#404040"))) // 添加圆形背景
                .shadow(radius: 1)
                
            }
            .frame(maxWidth: .infinity)
            .padding(.top, CommonUtils.safeTopInset)
            .padding([.bottom, .leading, .trailing], 20)
            .background(
                Color(hex: "#FFFFFF")
                    .opacity(0.8)
                    .background(.ultraThinMaterial) // 添加模糊效果
                    .cornerRadius(0)
                )
            .background(Color.clear)
            .alignmentGuide(.top) { _ in 0 }
            .zIndex(1) // 确保显示在图片的上方
            
            // MARK: 中间部分图片
            GeometryReader { geometry in
                switch viewModel.imageState {
                case .empty:
                    PhotosPicker(selection: $viewModel.imageSelection,
                                 matching: .images,
                                 photoLibrary: .shared()) {
                        VStack {
                            Image(systemName: "plus.circle")
                                .scaledToFit()
                                .font(.system(size: 52))
                                .foregroundStyle(.gray)
                            Text("请选择图片")
                                .foregroundStyle(.gray)
                                .padding([.top], 8)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                                 .buttonStyle(.borderless)
                                 .frame(width: geometry.size.width, height: geometry.size.height)
                case .loading:
                    ProgressView()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                case .success(let image):
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
                                            } else {
                                                scale = scale == 1.0 ? 2.0 : 1.0
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
                        //                        .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                        //                            .draggable(image)
                            .listRowInsets(EdgeInsets())
                    }
                case .failure:
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
            }
//            .background(Color.green.opacity(0.2)) // 背景颜色
            .frame(maxHeight: .infinity) // 占据剩余空间
            .padding()
            
            // MARK: 底部工具栏
            switch viewModel.imageState {
            case .success(_), .empty:
                HStack(alignment: .center) {
                    //                        GeometryReader { geometry in
                    ScrollView(.horizontal) {
                        HStack(spacing: 10) {
                            //                            Spacer()
                            ColorChangedButton(icon: "calendar", title: "日期")
                            //                            Spacer()
                            ColorChangedButton(icon: "location.fill", title: "经纬度")
                            //                            Spacer()
                            ContentChangedButton(items: [
                                ("circle.lefthalf.filled", "白底"), ("circle.righthalf.filled", "黑底")
                            ])
                            
//                            ColorChangedButton(icon: "gearshape", title: "设置")
                            
                            Toggle(isOn: $displayTime) {
                                Label("Flag", systemImage: "flag.fill")
                                    .foregroundStyle(.black)
                            }
                            .toggleStyle(.button)
                            //                            Spacer()
                            //                        Button("设置", systemImage: "gearshape") {
                            //                            print("pressed")
                            //                        }
                            //                        .buttonBorderShape(.circle)
                            //                        Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        //                                .padding(.top, 10)
                        //                                .padding(.bottom, CommonUtils.safeBottomInset + 32)
                        .background(
                            Color.white
                                .opacity(0.8)
                                .background(.ultraThinMaterial) // 添加模糊效果
                                .cornerRadius(0)
                        ) // 下半部分背景颜色
                        .zIndex(1) // 确保显示在图片的上方
                        .alignmentGuide(.bottom) { _ in 0 }
                    }
                    //                            .frame(height: geometry.size.height)
                    //                        }
                    //                        .frame(height: 100)
                    
                    ColorChangedButton(icon: "gearshape", title: "设置")
                    
                    //                        Button("设置", systemImage: "gearshape") {
                    //                            print("pressed")
                    //                        }
                    //                        .buttonBorderShape(.circle)
                    //                        .frame(height: 100)
                }
                .padding()
                .padding(.bottom, CommonUtils.safeBottomInset + 10)
                .background(
                    Color.white
                        .opacity(0.8)
                        .background(.ultraThinMaterial) // 添加模糊效果
                        .cornerRadius(0)
                ) // 下半部分背景颜色
                
            default:
                Color.clear.frame(height: 50)
            }
        }
        .toolbar {
            ToolbarItem {
                Button("设置", systemImage: "gearshape") {
                    print("pressed")
                }
                .buttonBorderShape(.circle)
            }
        }
        .navigationTitle(CommonUtils.appName)
        .sheet(isPresented: $isSheetPresented) {
            HalfTransparentSheetView(isSheetPresented: $isSheetPresented, viewModel: viewModel)
                .presentationBackground(.ultraThinMaterial)
                .presentationDetents([.fraction(0.2), .medium, .large], selection: $settingsDetent)
                .presentationDragIndicator(.visible)
        }
        .background(
//            Color(hex: "#020305")
            MeshGradientView()
        ) // 页面背景颜色
        .ignoresSafeArea() // 忽略安全区
    }
}

#Preview {
    EditPhotoPage()
}
