import SwiftUI

struct BackgroundColorSelectSubView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var isOn: Bool
    let colors: [Color]
    @Binding var selectedIndex: Int
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ForEach(Array(colors.enumerated()), id: \.offset) { index, color in
                    ColorSelectButton(index: index, selectedIndex: $selectedIndex, color: color) {
                        selectedIndex = index
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(height: 44)
        }
        .background(
            Rectangle()
                .fill(.bar)
                .foregroundStyle(colorScheme == .light ? .white : .black)
                .opacity(0.8)
        )
        .transition(.opacity)
        .opacity(isOn ? 1 : 0) // 渐变透明度
        .offset(y: isOn ? 0 : 20) // 向上的动画
        .animation(.easeInOut(duration: 0.2), value: isOn) // 动画效果
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
                .shadow(color: .gray.opacity(0.15), radius: 2.5, x: 0, y: 0) // 添加阴影
                .overlay(
                    Circle()
                        .stroke(selectedIndex == index ? Color.red : Color.white, lineWidth: 2) // 添加边框
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
