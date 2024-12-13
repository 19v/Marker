import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tabs = .addWaterMark
    
    var body: some View {
        NavigationStack {
//            AddTabView()
            VStack {
                GeometryReader { geometry in
//                    Text("Marker")
//                        .font(.system(size: 48, weight: .medium))
//                        .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
//                        .foregroundStyle(.white)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Marker")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        Text("创建带有水印的照片")
                            .font(.subheadline)
                            .foregroundStyle(Color(hex: "#E2E3E5"))
                    }
                    .padding(.top, 42) // 上方留一些间距
                    .padding(.horizontal, 42) // 左右留间距
                    .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
                }
                .padding(.top, CommonUtils.safeTopInset)
                
                VStack(spacing: 28) {
                    CapsuleButton(icon: "photo.fill", title: "选择照片") {
                        print("Button tapped!")
                    }
                    
                    CapsuleButton(icon: "camera.fill", title: "拍摄照片") {
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
                .padding(EdgeInsets(top: 10, leading: 32, bottom: CommonUtils.safeBottomInset + 16, trailing: 32))
            }
            .background(
                MeshGradientView()
            )
        }
    }
}

#Preview {
    ContentView()
}
