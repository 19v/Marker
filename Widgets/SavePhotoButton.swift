import SwiftUI

struct SavePhotoButton: View {
    @State private var buttonState: ButtonState = .normal
    @State private var saveResult: String?
    
    let image: UIImage

    enum ButtonState {
        case normal
        case saving
        case success
        case failed
    }

    var body: some View {
        VStack {
            Button {
                Task { await handleButtonClick() }
            } label: {
                contentForButtonState
                    .font(.system(size: 16))
                    .scaleEffect(buttonState == .normal ? 1 : 0.95) // 按钮点击时略微缩小
                    .opacity(buttonState == .normal || buttonState == .saving ? 1 : 0.7) // 按钮动画平滑
                    .animation(.easeInOut(duration: 0.3), value: buttonState) // 使按钮状态变化时有平滑动画
                    .transition(.scale) // 设置视图转换动画
            }
            .disabled(buttonState != .normal) // 禁用按钮以防止重复点击
        }
    }

    @ViewBuilder private var contentForButtonState: some View {
        switch buttonState {
        case .normal:
            HStack {
                Image(systemName: "square.and.arrow.down")
                Text("保存")
            }
            .foregroundColor(.init(hex: 0x04B3DB))
        case .saving:
            HStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .init(hex: 0x17D0FB)))
                Text("稍等")
                    .foregroundColor(.init(hex: 0x17D0FB))
            }
        case .success:
            HStack {
                Image(systemName: "checkmark")
                Text("完成")
            }
            .foregroundColor(.init(hex: 0x04DB98))
        case .failed:
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                Text("失败")
            }
            .foregroundColor(.init(hex: 0xDB2C04))
        }
    }

    private func handleButtonClick() async {
        buttonState = .saving
        saveResult = nil
        
        // 保存图片
        do {
            try await PhotoSaver.with(image)
            buttonState = .success
            saveResult = "图片已成功保存到相册"
        } catch {
            buttonState = .failed
            saveResult = "保存失败: \(error.localizedDescription)"
        }

        // 1秒后恢复按钮为初始状态
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        buttonState = .normal
    }
}

#Preview {
    SavePhotoButton(image: UIImage())
}
