import SwiftUI

struct EditColorSubView: View {
    @Environment(\.colorScheme) private var colorScheme
    let colors: [Color]
    @Binding var selectedIndex: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("背景颜色")
                .font(.system(size: 14))
                .foregroundStyle(.gray)
                .padding(.bottom, 4)
            
            ScrollView(.horizontal) {
                HStack(spacing: 15) {
                    ForEach(Array(colors.enumerated()), id: \.offset) { index, color in
                        ColorSelectButton(index: index, selectedIndex: $selectedIndex, color: color) {
                            selectedIndex = index
                        }
                    }
                }
                .padding(4)
            }
            
            Text("文字颜色")
                .font(.system(size: 14))
                .foregroundStyle(.gray)
                .padding(.top, 16)
                .padding(.bottom, 4)
            
            ScrollView(.horizontal) {
                HStack(spacing: 15) {
                    ForEach(Array(colors.enumerated()), id: \.offset) { index, color in
                        ColorSelectButton(index: index, selectedIndex: $selectedIndex, color: color) {
                            selectedIndex = index
                        }
                    }
                }
                .padding(4)
            }
        }
        .padding(20)
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
    @Previewable @State var index = 0
    EditColorSubView(colors: [.white, .black], selectedIndex: $index)
}
