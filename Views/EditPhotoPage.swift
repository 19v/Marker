import SwiftUI
import PhotosUI

struct EditPhotoPage: View {
    @StateObject var viewModel = PhotoModel()
    
    @State private var isSheetPresented = false
    
    @State private var displayTime = false // 显示时间的开关
    @State private var displayCoordinate = false // 显示经纬度的开关
    
    @State private var selectedButton: Int? = nil // 用于管理选中状态的按钮
    @State private var bold = false
    @State private var italic = false
    @State private var fontSize = 12.0
    
    var body: some View {
//        ZStack {
//            // 背景颜色
//            Color(hex: "#282828")
////                .ignoresSafeArea() // 填充背景，忽略安全区
            
            VStack(spacing: 0) {
                HStack(spacing: 2) {
                    Spacer()
                    Button("设定", systemImage:"gearshape") {
                        print("test")
                    }
                    Button(action: {
                        print("Button tapped!")
                    }) {
                        Image(systemName: "gearshape")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.red)) // 添加圆形背景
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.2)) // 下半部分背景颜色
                
                // 上半部分：图片
                GeometryReader { geometry in
//                    DisplayedImage(viewModel: viewModel)
//                        .listRowInsets(EdgeInsets())
//                        .frame(width: geometry.size.width, height: geometry.size.height)
                    
                    PhotoView(imageState: viewModel.imageState)
                        .scaledToFill()
//                        .frame(maxWidth: .infinity, maxHeight: 360)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .background {
                            Rectangle().fill(
                                Color(.systemGray5)
                            )
                        }
                        .listRowInsets(EdgeInsets())
                }
                .background(Color.green.opacity(0.2)) // 上半部分背景颜色
                .frame(maxHeight: .infinity) // 占据剩余空间
                
                HStack(spacing: 2) {
                    Spacer()
                    MainPageButton(icon: "star.fill", title: "按钮1")
                    Spacer()
                    MainPageButton(icon: "star.fill", title: "按钮2")
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.2)) // 下半部分背景颜色
            }
//        }
        .background(Color.black) // 页面背景颜色
        .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 0) } // 保留安全区
//        .navigationBarTitleDisplayMode(.inline)
//        .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
//        .toolbar {
//            ToolbarItem {
//                Button("设置", systemImage: "gearshape") {
//                    print("test")
//                }
//            }
//        }
    }
}

struct EditPhotoPageButton: View {
    @State private var isPressed = false
    
    let icon: String  // 图标名称（SF Symbols）
    let title: String // 按钮文字
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(isPressed ? .white : .gray)
            
            // 上半部分：圆形 + 图标
            ZStack {
                Circle()
                    .fill(isPressed ? Color.blue : Color.gray)
                    .frame(width: 80, height: 80)
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(isPressed ? .white : .gray)
            }
            .onTapGesture {
                withAnimation {
                    isPressed.toggle()
                }
            }
            
            // 下半部分：文字
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .padding(.bottom, 10)
        }
    }
}
