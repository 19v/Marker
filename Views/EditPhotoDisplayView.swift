import SwiftUI
import PhotosUI

struct EditPhotoDisplayView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let viewModel: PhotoModel
    
    @State private var scale: CGFloat = 1.0 // 缩放比例
    @State private var lastScale: CGFloat = 1.0 // 上一次的缩放比例
    
    @State private var offset: CGSize = .zero // 偏移量
    @State private var lastOffset: CGSize = .zero // 上一次偏移量
    
    @State private var anchorPoint: UnitPoint = .center // 记录双击的坐标（相对于视图）

    @State private var contentSize: CGSize = .zero
    
    @Binding var isDisplayWatermark: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Image(uiImage: viewModel.uiImage)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .listRowInsets(EdgeInsets())
            
            if isDisplayWatermark {
                Image(uiImage: viewModel.watermarkImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // 占据剩余空间
        .padding(.horizontal, 20)
        .shadow(
            color: colorScheme == .dark ? Color.gray.opacity(0.1) : Color.black.opacity(0.2),
            radius: colorScheme == .dark ? 12 : 10,
            x: 0, y: 0
        )
        .offset(offset)
        .scaleEffect(scale, anchor: anchorPoint)
        // 双击
        .onTapGesture(count: 2) { location in
            if scale == 1.0 {
                // 计算缩放中心点
                anchorPoint = UnitPoint(x: location.x / contentSize.width, y: location.y / contentSize.height)
            }
            withAnimation {
                // 如果不在原位，优先恢复原位，并恢复原本大小
                if offset != .zero {
                    offset = .zero
                    lastOffset = .zero
                    if scale != 1.0 {
                        scale = 1.0
                        lastScale = scale
                        anchorPoint = .center
                    }
                } else {
                    if scale == 1.0 {
                        scale = 2.0
                    } else {
                        anchorPoint = .center
                        scale = 1.0
                    }
                    lastScale = scale
                }
            }
        }
        // 拖拽
        .gesture(
            DragGesture()
                .onChanged { value in
                    offset = CGSize(
                        width: lastOffset.width + value.translation.width / scale,
                        height: lastOffset.height + value.translation.height / scale
                    )
                }
                .onEnded { value in
                    lastOffset = offset
                }
        )
        // 双指手势
        .gesture(magnificationGesture)
        .background(
            GeometryReader { proxy in
                // 背景（可用于检测手势）
                Color(hex: colorScheme == .light ? 0xF2F3F5 : 0x101010)
                    .opacity(0)
                    .contentShape(Rectangle())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onTapGesture(count: 2) {
                        // 双击
                        withAnimation {
                            if offset != .zero {
                                offset = .zero
                                lastOffset = .zero
                            }
                            if scale != 1.0 {
                                scale = 1.0
                                lastScale = scale
                            }
                            if anchorPoint != .center {
                                anchorPoint = .center
                            }
                        }
                    }
                    .onAppear {
                        // 设计上这张图的背景覆盖全屏，应该和 UIScreen.main.bounds 一致
                        contentSize = proxy.size
                    }
            }
        )
    }
    
    // 双指手势
    private var magnificationGesture: some Gesture {
        MagnifyGesture(minimumScaleDelta: 0)
            .onChanged { value in
                withAnimation(.interactiveSpring) {
                    if value.magnification > 1 {
                        // 放大
                        scale = lastScale + (value.magnification - 1.0)
                        
                        let newX = value.startLocation.x * (value.startAnchor.x - anchorPoint.x) * (scale - lastScale)
                        let newY = value.startLocation.y * (value.startAnchor.y - anchorPoint.y) * (scale - lastScale)
                        offset = CGSize(
                            width: lastOffset.width - newX,
                            height: lastOffset.height - newY
                        )
                    } else if value.magnification < 1 {
                        // 缩小
                        scale = lastScale * value.magnification
                        
                        let newX = value.startLocation.x * (value.startAnchor.x - anchorPoint.x) * (scale - lastScale)
                        let newY = value.startLocation.y * (value.startAnchor.y - anchorPoint.y) * (scale - lastScale)
                        offset = CGSize(
                            width: lastOffset.width + newX,
                            height: lastOffset.height + newY
                        )
                    }
                }
            }
            .onEnded { _ in
                withAnimation(.interactiveSpring) {
                    lastOffset = offset
                    lastScale = scale
                }
            }
    }
    
}
