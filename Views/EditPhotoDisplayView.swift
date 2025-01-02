import SwiftUI
import PhotosUI

struct EditPhotoDisplayView: View {
    let geometry: GeometryProxy
    let image: Image
    let watermark: UIImage?
    let displayWatermark: Bool
    
    // 控制图片显示的参数
    private static let defaultScale: CGFloat = 0.9 // 初始缩放比例，为1.0时左右填满屏幕
    @State private var scale: CGFloat = defaultScale // 控制缩放比例
    @State private var lastScale: CGFloat = defaultScale // 保存上一次的缩放比例
    @State private var offset: CGSize = .zero // 偏移量
    @State private var lastOffset: CGSize = .zero // 上一次偏移量
    
    var body: some View {
        ZStack {
            Color.white
                .opacity(0)
                .contentShape(Rectangle())
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
            
            VStack(spacing: 0) {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width)
                    .listRowInsets(EdgeInsets())
                
                if let watermark,
                   displayWatermark {
                    Image(uiImage: watermark)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width)
                }
            }
            .frame(width: geometry.size.width)
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
        .clipped()
    }
}
