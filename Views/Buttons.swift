import SwiftUI

// 按下之后会变色的按钮
struct ColorChangedButton: View {
    @State private var isPressed = false
    
    let icon: String  // 图标名称（SF Symbols）
    let title: String // 按钮文字
    
    var body: some View {
        Button(action: {
            withAnimation {
                isPressed.toggle()
            }
        }) {
            HStack {
                Image(systemName: icon) // 左边的符号
                    .foregroundColor(.white)

                Text(title) // 右边的文字
                    .foregroundColor(.white)
                    .bold()
            }
            .padding()
            .background(Capsule().fill(isPressed ? Color.blue : Color(hex: "#404040"))) // 胶囊形背景
            .shadow(radius: 1) // 添加阴影效果（可选）
        }
    }
}

// 按下之后会变更内容的按钮
struct ContentChangedButton: View {
    @State private var currentIndex = 0
    
    let items: [(symbol: String, text: String)] // 图标名称（SF Symbols）和文字的元组数组
    
    var body: some View {
        Button(action: {
            withAnimation {
                currentIndex = (currentIndex + 1) % items.count
            }
        }) {
            HStack {
                Image(systemName: items[currentIndex].symbol)
                    .foregroundColor(.white)

                Text(items[currentIndex].text) // 右边的文字
                    .foregroundColor(.white)
                    .bold()
            }
            .padding()
            .background(Capsule().fill(Color(hex: "#404040")))
            .shadow(radius: 1) // 添加阴影效果（可选）
        }
    }
}

// 单纯就一个图标的按钮
struct SingleSymbolButton: View {
    @State private var isPressed = false
    
    let icon: String  // 图标名称（SF Symbols）
    
    var body: some View {
        Button(action: {
            print("按钮被点击")
        }) {
            Image(systemName: "star.fill") // 图标
                .resizable()               // 可调整大小
                .scaledToFit()             // 保持图标比例
                .padding(20)               // 内边距
                .foregroundColor(.white)   // 图标颜色
        }
        .frame(width: 60, height: 60)        // 圆形尺寸
        .background(Circle().fill(Color.blue)) // 背景为蓝色圆形
        .shadow(radius: 5)                  // 阴影效果（可选）
    }
}
