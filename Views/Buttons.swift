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
//                    .frame(width: 10, height: 10)

                Text(title) // 右边的文字
                    .foregroundColor(.white)
//                    .bold()
//                    .font(.system(size: 10))
            }
            .padding()
            .background(Capsule().fill(isPressed ? Color.blue : Color(hexString: "#404040"))) // 胶囊形背景
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
            .background(Capsule().fill(Color(hexString: "#404040")))
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

// 自定义的仿照 TabBar 的按钮
struct CustomTabButton: View {
    let iconName: String
    let labelText: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }) {
            VStack(spacing: 4) {
                ZStack {
                    Rectangle()
                        .fill(Color.white.opacity(0))
                    Image(systemName: iconName)
                        .symbolVariant(.circle.fill)
                        .foregroundStyle(.blue)
//                        .resizable()
//                        .scaledToFit()
                        .font(.system(size: 24))
//                        .frame(height: 20)
                }
                .frame(/*width: 20, */height: 30)
                Text(labelText)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        }
    }
}

struct ToolbarButton: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 24)) // 图标大小
                Text(title)
                    .font(.caption) // 文字大小
            }
            .foregroundColor(.blue) // 图标和文字颜色
        }
    }
}

// 首页所使用的胶囊型按钮
struct CapsuleButton: View {
    var icon: String
    var title: String
    var action: () -> Void
    
//    let titleColor = Color.white
    let titleColor = Color(hexString: "333333")
    
//    let backgroundColor = Color.blue
    let backgroundColor = Color.clear
    
    var body: some View {
        Button(action: action) {
            Style(icon: icon, title: title, titleColor: Color.black)
        }
    }
    
    struct Style: View {
        var icon: String
        var title: String
        var titleColor = Color(hexString: "333333")
        var backgroundColor = Color.clear

        var body: some View {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(titleColor)
                    .padding(.leading, 16)
                    .frame(width: 46)
                Text(title)
                    .foregroundColor(titleColor)
                    .font(.system(size: 16, weight: .bold))
                    .padding(.horizontal, 8)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(titleColor)
                    .padding(.trailing, 16)
            }
            .padding(.vertical, 12)
            .frame(height: 58)
//            .background(Capsule().fill(backgroundColor))
            .background(
                Color(hexString: "#FFFFFF")
                    .opacity(0.55)
                    .background(.ultraThinMaterial) // 添加模糊效果
                    .cornerRadius(0)
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 0)
            )
        }
    }
}

// 首页所使用的纯文字按钮
struct TextButton: View {
    var icon: String
    var title: String
    var action: () -> Void
    
    let titleColor = Color.white
    
//    let backgroundColor = Color.blue
    let backgroundColor = Color.clear

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(titleColor)
                    .padding(.leading, 16)
                Text(title)
                    .foregroundColor(titleColor)
                    .font(.system(size: 16, weight: .bold))
                    .padding(.trailing, 20)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .frame(height: 40)
        }
    }
}
