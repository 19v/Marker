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

struct HalfTransparentSheetView: View {
    @Binding var isSheetPresented: Bool
    
    @ObservedObject var viewModel: PhotoModel
    
    private var exifData: [String: Any] {
        if let ret = viewModel.exifData?.toDictionary() {
            return ret
        }
        return [:]
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    isSheetPresented = false // 关闭 sheet
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                }
                .padding()
            }
            Spacer()
            Text("这是一个可以下滑停留的 Sheet")
                .padding()
            Divider()
            Text("Exif信息：\(String(describing: exifData))")
                .padding()
            Spacer()
        }
    }
}
