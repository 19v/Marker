import SwiftUI
import PhotosUI

struct EditPhotoDisplayView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let image: Image
    let watermark: UIImage?
    @Binding var isWatermarkDisplayed: Bool
    
    // 控制图片显示的参数
    private static let defaultScale: CGFloat = 1.0 // 初始缩放比例
    @State private var scale: CGFloat = defaultScale // 控制缩放比例
    @State private var lastScale: CGFloat = defaultScale // 保存上一次的缩放比例
    @State private var offset: CGSize = .zero // 偏移量
    @State private var lastOffset: CGSize = .zero // 上一次偏移量
    
    var body: some View {
        ZStack {
            // 背景（透明，仅用于检测手势）
            Color.white
                .opacity(0)
                .contentShape(Rectangle())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                .gesture(
                    LongPressGesture(minimumDuration: 1)
                        .onChanged { _ in
                            isWatermarkDisplayed = false
                        }
                        .onEnded { _ in
                            isWatermarkDisplayed = true
                        }
                )
            
            // 图片和水印
            VStack(spacing: 0) {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .listRowInsets(EdgeInsets())
                
                if let watermark,
                   isWatermarkDisplayed {
                    Image(uiImage: watermark)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // 占据剩余空间
            .padding(.horizontal, 20)
            .shadow(
                color: colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.2),
                radius: colorScheme == .dark ? 20 : 10,
                x: 0, y: 0
            )
            .scaleEffect(scale) // 缩放
            .offset(offset) // 偏移
            .gesture(
                // 双击
                TapGesture(count: 2)
                    .onEnded {
                        withAnimation {
                            if offset != .zero {
                                offset = .zero
                                lastOffset = .zero
                            } else {
                                scale = scale == EditPhotoDisplayView.defaultScale ? 2.0 : EditPhotoDisplayView.defaultScale
                            }
                        }
                    }
            )
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
        }
        .background(
            colorScheme == .light
            ? Color(hex: 0xF2F3F5)
            : Color(hex: 0x101010)
        )
        .clipped()
    }
}
