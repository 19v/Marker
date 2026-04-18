import SwiftUI
import PhotosUI

struct EditPhotoDisplayView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let viewModel: PhotoModel
    
    @State private var scale: CGFloat = 1.0 // 缩放比例
    @State private var lastScale: CGFloat = 1.0 // 上一次的缩放比例
    
    @State private var offset: CGSize = .zero // 偏移量
    @State private var lastOffset: CGSize = .zero // 上一次偏移量
    
    @State private var contentSize: CGSize = .zero
    @State private var imageSize: CGSize = .zero
    
    @Binding var isDisplayWatermark: Bool
    
    let blankImage: Image
    
    var body: some View {
        ZStack {
            // 空白画布，用于约束尺寸
            blankImage
                .resizable()
                .scaledToFit()
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                imageSize = proxy.size
                            }
                    }
                )
                .padding(.vertical, 20)
                .padding(.horizontal, 20)
            
            // 图片和水印
            VStack(spacing: 0) {
                Image(uiImage: viewModel.uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: imageSize.width)
                
                if isDisplayWatermark {
                    Image(uiImage: viewModel.watermarkImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: imageSize.width)
                }
            }
            .shadow(
                color: colorScheme == .dark ? Color.gray.opacity(0.1) : Color.black.opacity(0.2),
                radius: colorScheme == .dark ? 12 : 10,
                x: 0, y: 0
            )
            .scaleEffect(scale)
            .offset(offset)
            
            // 手势层
            gestureView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            GeometryReader { proxy in
                Color(hex: colorScheme == .light ? 0xF2F3F5 : 0x101010)
                    .opacity(0)
                    .contentShape(Rectangle())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        // 设计上这张图的背景覆盖全屏，应该和 UIScreen.main.bounds 一致
                        contentSize = proxy.size
                    }
                    .onChange(of: proxy.size) { _, newSize in
                        contentSize = newSize
                    }
            }
        )
    }
    
    @ViewBuilder private var gestureView: some View {
        Color.white
            .opacity(0)
            .contentShape(Rectangle())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        // 双击
        .onTapGesture(count: 2) { location in
            withAnimation {
                handleDoubleTap(at: location)
            }
        }
        .gesture(
            panAndZoomGesture
        )
    }
    
    private var panAndZoomGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .simultaneously(with: MagnifyGesture(minimumScaleDelta: 0))
            .onChanged { value in
                let nextScale = clampedScale(lastScale * (value.second?.magnification ?? 1))
                let focalLocation = value.second?.startLocation ?? contentCenter
                let dragTranslation = value.first?.translation ?? .zero

                scale = nextScale
                offset = zoomOffset(
                    for: nextScale,
                    from: lastScale,
                    around: focalLocation,
                    baseOffset: lastOffset
                ) + dragTranslation
            }
            .onEnded { _ in
                settleGesture()
            }
    }

    private var contentCenter: CGPoint {
        CGPoint(x: contentSize.width / 2, y: contentSize.height / 2)
    }

    private func handleDoubleTap(at location: CGPoint) {
        if abs(scale - 1) > 0.001 || offset != .zero {
            resetTransform()
            return
        }

        scale = 2
        offset = zoomOffset(for: scale, from: lastScale, around: location, baseOffset: lastOffset)
        lastScale = scale
        lastOffset = offset
    }

    private func settleGesture() {
        lastScale = scale
        lastOffset = offset
    }

    private func resetTransform() {
        scale = 1
        lastScale = 1
        offset = .zero
        lastOffset = .zero
    }

    private func clampedScale(_ value: CGFloat) -> CGFloat {
        min(max(value, 0.5), 6)
    }

    private func zoomOffset(for newScale: CGFloat, from oldScale: CGFloat, around location: CGPoint, baseOffset: CGSize) -> CGSize {
        guard oldScale > 0 else { return baseOffset }

        let scaleRatio = newScale / oldScale
        let centerDelta = CGSize(
            width: location.x - contentCenter.x - baseOffset.width,
            height: location.y - contentCenter.y - baseOffset.height
        )

        return CGSize(
            width: baseOffset.width + (1 - scaleRatio) * centerDelta.width,
            height: baseOffset.height + (1 - scaleRatio) * centerDelta.height
        )
    }
    
}

private extension CGSize {
    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
}
