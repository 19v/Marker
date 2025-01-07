import SwiftUI

struct SettingsTabView: View {
    @State private var toggleSetting = false

    var body: some View {
        VStack {
            Toggle("示例开关", isOn: $toggleSetting)
                .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("右侧按钮") {
                    print("右侧按钮点击")
                }
            }
        }
    }
}
