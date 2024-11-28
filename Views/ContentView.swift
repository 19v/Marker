import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tabs = .addWaterMark
    
    var body: some View {
//        TabView(selection: $selectedTab) {
//            Tab("添加水印", systemImage: "photo.badge.plus", value: .addWaterMark) {
//                NavigationStack {
//                    AddTabView()
//                }
//                .navigationTitle(selectedTab.title)
//            }
//            Tab("移除水印", systemImage: "photo.on.rectangle.angled.fill", value: .removeWaterMark) {
//                RemoveTabView()
//            }
//            Tab("设置", systemImage: "gearshape", value: .settings) {
//                SettingsTabView()
//            }
//        }
//        // TODO: 上面的代码暂时注释，其他Tab没做完就不显示出来了，先搞定基础的功能-添加水印
//        NavigationStack {
//            AddTabView()
//        }
//        .navigationTitle(CommonUtils.appName)
        NavigationStack {
            EditPhotoPage()
        }
        .navigationTitle(CommonUtils.appName)
    }
}

#Preview {
    ContentView()
}
