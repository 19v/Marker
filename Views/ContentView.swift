import SwiftUI
import PhotosUI

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme // 读取当前颜色模式
    
    @State private var selectedTab: Tabs = .addWaterMark
    
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
                                colorScheme == .light ? Color(hex: "#101010") : Color(hex: "#E2E3E5")
                            )
                    }
                    .padding(.top, CommonUtils.safeTopInset + 10)
                    .padding(.leading, 42)
                    
                    Spacer()
                }
                
                Spacer()
                
                VStack(spacing: 28) {
//                    PhotosPicker(selection: $viewModel.imageSelection,
//                                 matching: .images,
//                                 photoLibrary: .shared()) {
                        CapsuleButton(icon: "photo.fill", title: "选择照片") {
                            print("Button tapped!")
                        }
//                    }
//                    .buttonStyle(.borderless)
//                    
//                    Button("移除图片") {
//                        print("test")
//                        viewModel.imageSelection = nil
//                    }
                    
                    CapsuleButton(icon: "camera.fill", title: "拍摄照片") {
                        print("Button tapped!")
                    }
                    
                    CapsuleButton(icon: "photo.stack.fill", title: "批量处理") {
                        print("Button tapped!")
                    }
                    
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
        }
    }
}

#Preview {
    ContentView()
}
