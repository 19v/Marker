import SwiftUI
import PhotosUI

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme // 读取当前颜色模式
    
    @State private var isShowPhotoPicker = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedData: Data? = nil
    
    @State private var isShowPhotosPicker = false
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedDatas: [Data] = []
    
    @State private var isShowCameraPicker = false
    @State private var capturedImage: UIImage? = nil
    @State private var capturedImageExif: ExifData? = nil
    @State private var navigateToEditPage = false
    
    @State private var navigateToSettingPage = false
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Marker")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                colorScheme == .light ? .black : .white
                            )
                        Text("创建带有水印的照片")
                            .font(.subheadline)
                            .foregroundStyle(
                                colorScheme == .light ? Color(hex: 0x101010) : Color(hex: 0xE2E3E5)
                            )
                    }
                    .padding(.top, CommonUtils.safeTopInset + 10)
                    .padding(.leading, 42)
                    
                    Spacer()
                }
                
                Spacer()
                
                VStack(spacing: 28) {
                    // 单张照片
                    CapsuleButton(icon: "photo.fill", title: "选择照片") {
                        isShowPhotoPicker.toggle()
                    }
                    .photosPicker(isPresented: $isShowPhotoPicker, selection: $selectedItem, matching: .images, photoLibrary: .shared())
                    .onChange(of: selectedItem) {
                        Task {
                            selectedData = try? await selectedItem?.loadTransferable(type: Data.self)
                        }
                    }
                    .navigationDestination(isPresented: .constant(selectedData != nil)) {
                        if let data = selectedData,
                           let image = UIImage(data: data) {
                            EditorView(image: image, exif: ExifData(data: data))
                                .onDisappear {
                                    selectedItem = nil
                                    selectedData = nil
                                }
                        }
                    }
                    
                    // 拍摄照片
                    CapsuleButton(icon: "camera.fill", title: "拍摄照片") {
                        isShowCameraPicker.toggle()
                    }
                    .fullScreenCover(isPresented: $isShowCameraPicker) {
                        CameraPickerView() { image, data in
                            capturedImage = image
                            capturedImageExif = ExifData(metadata: data)
                            navigateToEditPage.toggle()
                        }
                        .ignoresSafeArea()
                    }
                    .navigationDestination(isPresented: $navigateToEditPage) {
                        if let image = capturedImage,
                           let data = capturedImageExif {
                            EditorView(image: image, exif: data)
                                .onDisappear {
                                    capturedImage = nil
                                    capturedImageExif = nil
                                }
                        }
                    }
                    
                    // 多张照片
                    CapsuleButton(icon: "photo.stack.fill", title: "批量处理") {
                        isShowPhotosPicker.toggle()
                    }
                    .photosPicker(isPresented: $isShowPhotosPicker, selection: $selectedItems, matching: .images, photoLibrary: .shared())
                    .onChange(of: selectedItems) {
                        Task {
                            selectedDatas.removeAll()
                            for item in selectedItems {
                                if let data = try? await item.loadTransferable(type: Data.self) {
                                    selectedDatas.append(data)
                                }
                            }
                        }
                    }
                    .navigationDestination(isPresented: .constant(!selectedDatas.isEmpty)) {
                        // TODO: 批量编辑功能待完善
                        if let data = selectedDatas.first,
                           let image = UIImage(data: data) {
                            EditorView(image: image, exif: ExifData(data: data))
                                .onDisappear {
                                    selectedItems.removeAll()
                                    selectedDatas.removeAll()
                                }
                        }
                    }
                    
                    // 设置 & 反馈
                    HStack {
                        Spacer()
                        
                        TextButton(icon: "gearshape.fill", title: "设置") {
                            navigateToSettingPage.toggle()
                        }
                        .navigationDestination(isPresented: $navigateToSettingPage) {
                            SettingsTabView()
                        }
                        
                        Spacer()
                        
                        TextButton(icon: "quote.bubble.fill", title: "反馈") {
                            // TODO: 测试
                            let appID = "6450999012"
                            if let url = URL(string: "itms-apps://itunes.apple.com/app/id\(appID)?action=write-review") {
                                UIApplication.shared.open(url)
                            }
                        }
                        
                        Spacer()
                    }
                }
                .padding(EdgeInsets(top: 10, leading: 32, bottom: 20, trailing: 32))
            }
            .background(
                MeshGradient(
                    width: 3,
                    height: 3,
                    points: [
                        .init(x: 0, y: 0),   .init(x: 0.2, y: 0),   .init(x: 1, y: 0),
                        .init(x: 0, y: 0.5), .init(x: 0.3, y: 0.7), .init(x: 1, y: 0.2),
                        .init(x: 0, y: 1),   .init(x: 0.7, y: 1),   .init(x: 1, y: 1)
                    ],
                    colors: colorScheme == .dark ? [
                        .init(hex: 0x41b2d9), .init(hex: 0x3ba4cb), .init(hex: 0x3595be),
                        .init(hex: 0x2f87b0), .init(hex: 0x2a79a2), .init(hex: 0x246a94),
                        .init(hex: 0x1e5c87), .init(hex: 0x184d79), .init(hex: 0x123f6b),
                    ] : [
                        .init(hex: 0xffffff), .init(hex: 0xf2f9fd), .init(hex: 0xe5f3fb),
                        .init(hex: 0xd8edf9), .init(hex: 0xcbe7f8), .init(hex: 0xbee1f6),
                        .init(hex: 0xb1dbf4), .init(hex: 0xa4d5f2), .init(hex: 0x97cff0),
                    ]
                )
                .edgesIgnoringSafeArea(.all)
            )
        }
    }
}

#Preview {
    ContentView()
}
