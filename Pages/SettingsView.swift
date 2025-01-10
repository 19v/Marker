import SwiftUI

struct SettingsTabView: View {
    @State private var toggleSetting = false

    var body: some View {
        List {
            Toggle("示例开关", isOn: $toggleSetting)
                .padding()
        }
        .navigationTitle("设置")
    }
}
