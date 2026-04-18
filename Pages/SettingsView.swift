import SwiftUI
import UIKit

struct SettingsTabView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        List {
            Button {
                openAppSettings()
            } label: {
                Label("App 设置", systemImage: "gearshape")
            }
        }
        .navigationTitle("设置")
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        openURL(url)
    }
}
