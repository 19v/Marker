import SwiftUI

struct MainPageButton: View {
    @State private var isPressed = false
    
    let icon: String  // 图标名称（SF Symbols）
    let title: String // 按钮文字
    
    var body: some View {
        VStack(spacing: 8) {
            // 上半部分：圆形 + 图标
            ZStack {
                Circle()
                    .fill(isPressed ? Color.blue : Color.gray)
                    .frame(width: 80, height: 80)
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(isPressed ? .white : .gray)
            }
            .onTapGesture {
                withAnimation {
                    isPressed.toggle()
                }
            }
            
            // 下半部分：文字
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.primary)
                .padding(.bottom, 10)
        }
    }
}
