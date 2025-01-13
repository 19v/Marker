import SwiftUI
import PhotosUI

struct EditPhotoDisplayView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @ObservedObject var viewModel: PhotoModel
    
    @State private var scale: CGFloat = 1.0 // 缩放比例
    @State private var lastScale: CGFloat = 1.0 // 上一次的缩放比例
    
    @State private var offset: CGSize = .zero // 偏移量
    @State private var lastOffset: CGSize = .zero // 上一次偏移量
    
    var body: some View {
        ZStack {
            backgroundView
            imageWithWatermark
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            colorScheme == .light
            ? Color(hex: 0xF2F3F5)
            : Color(hex: 0x101010)
        )
        .clipped()
    }
    
    // 背景（透明，仅用于检测手势）
    @ViewBuilder var backgroundView: some View {
        Color.white
            .opacity(0)
            .contentShape(Rectangle())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onTapGesture {
                // 单击
                viewModel.isWatermarkDisplayed.toggle()
                viewModel.setPanel(to: .empty)
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
                        }
                    }
            )
    }
    
    // 图片和水印
    @ViewBuilder var imageWithWatermark: some View {
        VStack(spacing: 0) {
            Image(uiImage: viewModel.uiImage)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .listRowInsets(EdgeInsets())
            
            if viewModel.isWatermarkDisplayed {
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
        .scaleEffect(scale) // 缩放
        .offset(offset) // 偏移
        .onTapGesture {
            // 单击
            viewModel.isWatermarkDisplayed.toggle()
            viewModel.setPanel(to: .empty)
        }
        .onTapGesture(count: 2, perform: {
            // 双击
            withAnimation {
                if offset != .zero {
                    offset = .zero
                    lastOffset = .zero
                } else {
                    scale = scale == 1.0 ? 2.0 : 1.0
                }
            }
        })
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
                    lastOffset = offset // 拖动结束时保持最终位置
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
    }
}
