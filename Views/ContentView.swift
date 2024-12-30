import SwiftUI
import PhotosUI

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme // 读取当前颜色模式
    
    @StateObject var viewModel = PhotoModel()
    
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
                    PhotosPicker(selection: $viewModel.imageSelection, matching: .images, photoLibrary: .shared()) {
                        CapsuleButton.Style(icon: "photo.fill", title: "选择照片")
                    }
                    
                    CapsuleButton(icon: "camera.fill", title: "拍摄照片") {
                        print("Button tapped!")
                        LoggerManager.shared.debug("view model is: \(viewModel.imageLoaded)")
                    }
                    
                    // 多张照片
                    PhotosPicker(selection: $viewModel.imagesSelection, maxSelectionCount: 9, matching: .images, photoLibrary: .shared()) {
                        CapsuleButton.Style(icon: "photo.stack.fill", title: "批量处理")
                    }
                    
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

// MARK: - 主界面按钮

// 首页所使用的胶囊型按钮
struct CapsuleButton: View {
    var icon: String
    var title: String
    var action: () -> Void
    
//    let titleColor = Color.white
    let titleColor = Color(hexString: "333333")
    
//    let backgroundColor = Color.blue
    let backgroundColor = Color.clear
    
    var body: some View {
        Button(action: action) {
            Style(icon: icon, title: title, titleColor: Color.black)
        }
    }
    
    struct Style: View {
        var icon: String
        var title: String
        var titleColor = Color(hexString: "333333")
        var backgroundColor = Color.clear

        var body: some View {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(titleColor)
                    .padding(.leading, 16)
                    .frame(width: 46)
                Text(title)
                    .foregroundColor(titleColor)
                    .font(.system(size: 16, weight: .bold))
                    .padding(.horizontal, 8)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(titleColor)
                    .padding(.trailing, 16)
            }
            .padding(.vertical, 12)
            .frame(height: 58)
//            .background(Capsule().fill(backgroundColor))
            .background(
                Color(hexString: "#FFFFFF")
                    .opacity(0.55)
                    .background(.ultraThinMaterial) // 添加模糊效果
                    .cornerRadius(0)
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 0)
            )
        }
    }
}

// 首页所使用的纯文字按钮
struct TextButton: View {
    var icon: String
    var title: String
    var action: () -> Void
    
    let titleColor = Color.white
    
//    let backgroundColor = Color.blue
    let backgroundColor = Color.clear

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(titleColor)
                    .padding(.leading, 16)
                Text(title)
                    .foregroundColor(titleColor)
                    .font(.system(size: 16, weight: .bold))
                    .padding(.trailing, 20)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .frame(height: 40)
        }
    }
}

// MARK: - 主界面背景

struct MeshGradientView: View {
    
    @Environment(\.colorScheme) private var colorScheme // 读取当前颜色模式
    
    private var colors: [Color] {
        switch colorScheme {
        case .light:
            [
                .init(hexString: "#ffffff"), .init(hexString: "#f2f9fd"), .init(hexString: "#e5f3fb"),
                .init(hexString: "#d8edf9"), .init(hexString: "#cbe7f8"), .init(hexString: "#bee1f6"),
                .init(hexString: "#b1dbf4"), .init(hexString: "#a4d5f2"), .init(hexString: "#97cff0"),
            ]
        case .dark:
            [
                .init(hexString: "#41b2d9"), .init(hexString: "#3ba4cb"), .init(hexString: "#3595be"),
                .init(hexString: "#2f87b0"), .init(hexString: "#2a79a2"), .init(hexString: "#246a94"),
                .init(hexString: "#1e5c87"), .init(hexString: "#184d79"), .init(hexString: "#123f6b"),
            ]
        @unknown default:
            [
                .purple, .red, .yellow,
                .blue, .green, .orange,
                .indigo, .teal, .cyan
            ]
        }
    }
    
    @State var positions: [SIMD2<Float>] = [
        .init(x: 0, y: 0), .init(x: 0.2, y: 0), .init(x: 1, y: 0),
        .init(x: 0, y: 0.7), .init(x: 0.1, y: 0.5), .init(x: 1, y: 0.2),
        .init(x: 0, y: 1), .init(x: 0.9, y: 1), .init(x: 1, y: 1)
    ]

    let timer = Timer.publish(every: 1/6, on: .current, in: .common).autoconnect()

    var body: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: positions,
            colors: colors
        )
//        .frame(width: 300, height: 200)
//        .overlay(.ultraThinMaterial)
//        .overlay(.thinMaterial)
        .onReceive(timer, perform: { _ in
            positions[1] = randomizePosition(
                currentPosition: positions[1],
                xRange: (min: 0.2, max: 0.9),
                yRange: (min: 0, max: 0)
            )

            positions[3] = randomizePosition(
                currentPosition: positions[3],
                xRange: (min: 0, max: 0),
                yRange: (min: 0.2, max: 0.8)
            )

            positions[4] = randomizePosition(
                currentPosition: positions[4],
                xRange: (min: 0.3, max: 0.8),
                yRange: (min: 0.3, max: 0.8)
            )

            positions[5] = randomizePosition(
                currentPosition: positions[5],
                xRange: (min: 1, max: 1),
                yRange: (min: 0.1, max: 0.9)
            )

            positions[7] = randomizePosition(
                currentPosition: positions[7],
                xRange: (min: 0.1, max: 0.9),
                yRange: (min: 1, max: 1)
            )
        })
    }

    func randomizePosition(
        currentPosition: SIMD2<Float>,
        xRange: (min: Float, max: Float),
        yRange: (min: Float, max: Float)
    ) -> SIMD2<Float> {
        let updateDistance: Float = 0.01

        let newX = if Bool.random() {
            min(currentPosition.x + updateDistance, xRange.max)
        } else {
            max(currentPosition.x - updateDistance, xRange.min)
        }

        let newY = if Bool.random() {
            min(currentPosition.y + updateDistance, yRange.max)
        } else {
            max(currentPosition.y - updateDistance, yRange.min)
        }

        return .init(x: newX, y: newY)
    }
}
