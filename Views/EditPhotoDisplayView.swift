import SwiftUI
import PhotosUI

struct EditPhotoDisplayView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let viewModel: PhotoModel
    
    @State private var scale: CGFloat = 1.0 // 缩放比例
    @State private var lastScale: CGFloat = 1.0 // 上一次的缩放比例
    
    @State private var offset: CGSize = .zero // 偏移量
    @State private var lastOffset: CGSize = .zero // 上一次偏移量
    
    @State private var anchorPoint: CGPoint = .zero // 记录双击的坐标（相对于视图）
    
    @Binding var isDisplayWatermark: Bool
    
    var body: some View {
        ZStack {
            // 背景（透明，仅用于检测手势）
            Color.white
                .opacity(0)
                .contentShape(Rectangle())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onTapGesture {
                    // 单击
                    isDisplayWatermark = true
                }
                .gesture(
                    // 双击
                    TapGesture(count: 2)
                        .onEnded {
                            withAnimation {
                                if offset != .zero {
                                    offset = .zero
                                    lastOffset = .zero
                                }
                                if scale != 1.0 {
                                    scale = 1.0
                                    lastScale = scale
                                }
                            }
                        }
                )
            
            // 图片和水印
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
            .scaleEffect(scale, anchor: UnitPoint(x: anchorPoint.x, y: anchorPoint.y))
            // 单击手势
            .onTapGesture {
                isDisplayWatermark = true
            }
            // 双击放大、缩小和恢复原位
            .onTapGesture(count: 2) { location in
                if scale == 1.0 {
                    // 计算缩放中心点
                    let screenWidth = UIScreen.main.bounds.width
                    let screenHeight = UIScreen.main.bounds.height
                    anchorPoint = CGPoint(x: location.x / screenWidth, y: location.y / screenHeight)
                }
                withAnimation {
                    // 如果不在原位，优先恢复原位，并恢复原本大小
                    if offset != .zero {
                        offset = .zero
                        lastOffset = .zero
                        if scale != 1.0 {
                            scale = 1.0
                            lastScale = scale
                            anchorPoint = .zero
                        }
                    } else {
                        if scale == 1.0 {
                            scale = 2.0
                        } else {
                            scale = 1.0
                        }
                        lastScale = scale
                    }
                }
            }
            // 拖拽和双指放大
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
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        scale = lastScale * value
                    }
                    .onEnded { _ in
                        lastScale = scale
                    }
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            colorScheme == .light
            ? Color(hex: 0xF2F3F5)
            : Color(hex: 0x101010)
        )
        .clipped()
    }
    
}
