import SwiftUI

// MARK: - 主页

// 首页所使用的胶囊型按钮
struct CapsuleButton: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var icon: String
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .padding(.leading, 16)
                    .frame(width: 46)
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .padding(.horizontal, 8)
                Spacer()
                Image(systemName: "chevron.right")
                    .padding(.trailing, 16)
            }
            .foregroundStyle(Color(hex: colorScheme == .dark
                                   ? 0xF2F3F5
                                   : 0x333333))
            .padding(.vertical, 12)
            .frame(height: 58)
            .background(
                Color(Color(hex: colorScheme == .dark
                            ? 0x333333
                            : 0xFFFFFF))
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
    @Environment(\.colorScheme) private var colorScheme
    
    var icon: String
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(colorScheme == .dark ? Color.white : Color(hex: 0x282828))
                    .padding(.leading, 16)
                Text(title)
                    .foregroundColor(colorScheme == .dark ? Color.white : Color(hex: 0x282828))
                    .font(.system(size: 16, weight: .bold))
                    .padding(.trailing, 20)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .frame(height: 40)
        }
    }
}

// MARK: - 照片编辑界面

// 照片编辑界面所使用的工具栏按钮
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
//                        .foregroundStyle(Color(hex: 0x282828))
//                        .resizable()
//                        .scaledToFit()
                        .font(.system(size: 24))
//                        .frame(height: 20)
                }
                .frame(/*width: 20, */height: 30)
                Text(labelText)
                    .font(.system(size: 10))
//                    .foregroundColor(Color(hex: 0x282828))
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        }
    }
}
