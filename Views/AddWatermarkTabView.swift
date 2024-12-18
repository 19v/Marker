import SwiftUI
import PhotosUI

struct AddTabView: View {
    @StateObject var viewModel = PhotoModel()
    
    @State private var isSheetPresented = false
    
    @State private var displayTime = false // 显示时间的开关
    @State private var displayCoordinate = false // 显示经纬度的开关
    
    var body: some View {
        List {
            Section {
                DisplayedImage(viewModel: viewModel)
                    .listRowInsets(EdgeInsets())
            }
            
            Section {
                PhotosPicker(selection: $viewModel.imageSelection,
                             matching: .images,
                             photoLibrary: .shared()) {
                    Text("选择图片")
                }
                .buttonStyle(.borderless)
                
                Button("移除图片") {
                    print("test")
                    viewModel.imageSelection = nil
                }
            }

            Section {
                Button("测试按钮") {
                    LoggerManager.shared.debug("测试")
                    print("\(displayTime)")
                    print("\(viewModel.displayTime)")
                }
                
                Button("显示Exif信息", systemImage: "info.circle") {
                    isSheetPresented.toggle()
                }
                
                Button("添加水印", systemImage: "plus.app") {
                    LoggerManager.shared.debug("test")
                    if let uiImage = viewModel.uiImage,
                       let data = viewModel.watermarkData
                    {
                        viewModel.imageModification = PhotoUtils.addWhiteAreaToBottom(of: uiImage, data: data)
                    }
                }
                
                Button("保存图片", systemImage: "square.and.arrow.down") {
                    LoggerManager.shared.debug("test")
                    if let uiImage = viewModel.imageModification {
//                        PhotoUtils.savePhoto(uiImage: uiImage)
//                        UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
                        PhotoSaver.with(uiImage: uiImage)
                    }
                }
                
                Toggle(
                    "显示时间",
                    systemImage: "dot.radiowaves.left.and.right",
                    isOn: $displayTime
                )
                
                Toggle(
                    "显示时间2",
                    systemImage: "dot.radiowaves.left.and.right",
                    isOn: $viewModel.displayTime
                )
                
                Toggle(
                    "显示经纬度",
                    systemImage: "dot.radiowaves.left.and.right",
                    isOn: $displayCoordinate
                )
                
                Toggle(
                    "显示经纬度2",
                    systemImage: "dot.radiowaves.left.and.right",
                    isOn: $viewModel.displayCoordinate
                )
                
                ColorChangedButton(icon: "star.fill", title: "按钮")
                    .padding()
            }
            
            Section {
//                NavigationLink(destination: EditPhotoPage()) {
//                    Text("测试页面")
//                }
            }
        }
        .sheet(isPresented: $isSheetPresented) {
            HalfTransparentSheetView(isSheetPresented: $isSheetPresented, viewModel: viewModel)
                .presentationBackground(.ultraThinMaterial)
                .presentationDetents([.large, .medium, .fraction(0.2)])
                .presentationDragIndicator(.visible)
        }
        .navigationTitle(CommonUtils.appName)
    }
}
