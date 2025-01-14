import SwiftUI

struct EditColorSubView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let viewModel: PhotoModel
    
    var body: some View {
        @Bindable var viewModel = viewModel
        let colors = viewModel.enabledColors
        
        VStack {
            HStack {
                Text("背景")
                    .font(.headline)
                    .foregroundStyle(.gray)
                    .padding(.trailing, 10)
                
                ScrollView(.horizontal) {
                    HStack(spacing: 15) {
                        ForEach(Array(colors.enumerated()), id: \.offset) { index, color in
                            ColorSelectButton(index: index, selectedIndex: $viewModel.backgroundColorIndex, color: color) {
                                viewModel.backgroundColorIndex = index
                            }
                        }
                    }
                    .padding(4)
                }
            }
            .frame(height: 20)
            .padding()
            
            HStack {
                Text("文字")
                    .font(.headline)
                    .foregroundStyle(.gray)
                    .padding(.trailing, 10)
                
                ScrollView(.horizontal) {
                    HStack(spacing: 15) {
                        ForEach(Array(colors.reversed().enumerated()), id: \.offset) { index, color in
                            ColorSelectButton(index: index, selectedIndex: $viewModel.backgroundColorIndex, color: color) {
                                viewModel.backgroundColorIndex = index
                            }
                        }
                    }
                    .padding(4)
                }
            }
            .frame(height: 20)
            .padding()
        }
    }
}

struct ColorSelectButton: View {
    let index: Int
    @Binding var selectedIndex: Int
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 40, height: 40)
                .shadow(color: .gray.opacity(0.15), radius: 10, x: 0, y: 0) // 添加阴影
                .overlay(
                    Circle()
                        .stroke(selectedIndex == index ? .blue : .gray.opacity(0.25), lineWidth: 2) // 添加边框
                )
        }
        .buttonStyle(PlainButtonStyle()) // 去掉默认按钮样式
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

#Preview {
    let img = UIImage()
    let exif = ExifData(image: img)
    let viewModel = PhotoModel(image: img, exif: exif)
    EditColorSubView(viewModel: viewModel)
}
