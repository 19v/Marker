import SwiftUI
import PhotosUI

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme // 读取当前颜色模式
    
    @StateObject var viewModel = PhotoModel()
    
    @State private var isShowPhotosPicker = false
    @State private var isPhotoSelected = false
    
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
                    CapsuleButton(icon: "camera.fill", title: "选择照片") {
                        isShowPhotosPicker.toggle()
                    }
                    .photosPicker(isPresented: $isShowPhotosPicker, selection: $viewModel.imageSelection, matching: .images, photoLibrary: .shared())
                    
                    CapsuleButton(icon: "camera.fill", title: "拍摄照片") {
                        print("Button tapped!")
                        LoggerManager.shared.debug("view model is: \(viewModel.imageLoaded)")
                    }
                    
//                    // 多张照片
//                    PhotosPicker(selection: $viewModel.imagesSelection, maxSelectionCount: 9, matching: .images, photoLibrary: .shared()) {
//                        CapsuleButton.Style(icon: "photo.stack.fill", title: "批量处理")
//                    }
                    
                    // 设置 & 反馈
                    HStack {
                        Spacer()
                        TextButton(icon: "gearshape.fill", title: "设置") {
                            print("Button tapped!")
                        }
                        Spacer()
                        TextButton(icon: "quote.bubble.fill", title: "反馈") {
                            print("Button tapped!")
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
            .navigationDestination(isPresented: $viewModel.imageLoaded) {
                EditPhotoPage(viewModel: viewModel) {
                    viewModel.reset()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
