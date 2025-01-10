import SwiftUI
import PhotosUI

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme // 读取当前颜色模式
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedData: Data? = nil
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedDatas: [Data] = []
    
    @State private var showCameraPicker = false
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
                    PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                        CapsuleButton.Style(icon: "photo.fill", title: "选择照片")
                    }
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
                        showCameraPicker.toggle()
                    }
                    .fullScreenCover(isPresented: $showCameraPicker) {
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
                    PhotosPicker(selection: $selectedItems, matching: .images, photoLibrary: .shared()) {
                        CapsuleButton.Style(icon: "photo.stack.fill", title: "批量处理")
                    }
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
                MeshGradientView()
                    .edgesIgnoringSafeArea(.all)
            )
        }
    }
}

#Preview {
    ContentView()
}
