import SwiftUI
import PhotosUI

struct EditPhotoDisplayView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @ObservedObject var viewModel: PhotoModel
    
    @State private var scale: CGFloat = 1.0 // 缩放比例
    @State private var lastScale: CGFloat = 1.0 // 上一次的缩放比例
    @State private var doubleTapLocation: CGPoint = .zero // 记录双击时手指所在的位置
    
    @State private var offset: CGSize = .zero // 偏移量
    @State private var lastOffset: CGSize = .zero // 上一次偏移量
    
    @Binding var isDisplayWatermark: Bool
    
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
                                if scale != 1.0 {
                                    scale = 1.0
                                }
                            }
                        }
                    }
            )
    }
    
    // 图片和水印
    @ViewBuilder var imageWithWatermark: some View {
        GeometryReader { geometry in
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
            .scaleEffect(scale, anchor: scale == 1.0 ? .center : UnitPoint(
                x: doubleTapLocation.x / geometry.size.width,
                y: doubleTapLocation.y / geometry.size.height))
            .onTapGesture {
                // 单击
                isDisplayWatermark = true
            }
            .onTapGesture(count: 2) { location in
                // 双击
                withAnimation(.easeInOut) {
                    // 如果不在原位，优先恢复原位，并恢复原本大小
                    if offset != .zero {
                        lastOffset = .zero
                        offset = .zero
                        if scale != 1.0 {
                            scale = 1.0
                        }
                    } else {
                        if scale == 1.0 {
                            scale = 2.0
                            doubleTapLocation = CGPoint(
                                x: location.x - geometry.frame(in: .local).origin.x,
                                y: location.y - geometry.frame(in: .local).origin.y
                            )
                            lastOffset = .zero
                            offset = .zero
                        } else {
                            scale = 1.0
                            lastOffset = .zero
                            offset = .zero
                        }
                    }
                }
            }
            .onLongPressGesture(minimumDuration: 1.0, perform: {
                isDisplayWatermark = false
            }, onPressingChanged: { _ in
                isDisplayWatermark = true
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
}
