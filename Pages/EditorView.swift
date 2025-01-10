import SwiftUI
import PhotosUI

struct EditorView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    init(image: UIImage, exif: ExifData) {
        _viewModel = StateObject(wrappedValue: PhotoModel(image: image, exif: exif))
    }
    
    @StateObject private var viewModel: PhotoModel
    @State private var isShowCancelAlert = false
    
    var body: some View {
        ZStack {
            // 照片+水印
            EditPhotoDisplayView(viewModel: viewModel)
            
            // 顶部按钮的半透明背景
            VStack {
                Rectangle()
                    .fill(
                        colorScheme == .dark
                        ? .black.opacity(0.8)
                        : .white.opacity(0.5)
                    )
                    .background(.regularMaterial)
                    .frame(height: CommonUtils.safeTopInset + 44)
                Spacer()
            }
            
            // 工具栏
            EditPhotoToolbarView(viewModel: viewModel)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // 关闭按钮
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    isShowCancelAlert.toggle()
                } label: {
                    HStack {
                        Image(systemName: "arrow.uturn.backward")
                        Text("返回")
                    }
                    .foregroundStyle(.gray)
                }
            }
            
            // 水印开关
            if !viewModel.isWatermarkDisplayed {
                ToolbarItem(placement: .principal) {
                    Button {
                        withAnimation {
                            viewModel.isWatermarkDisplayed = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: "circle")
                            Text("打开水印")
                        }
                        .foregroundStyle(Color(hex: 0x04DBCD))
                    }
                }
            }
            
            // 保存按钮
            ToolbarItem(placement: .topBarTrailing) {
                SavePhotoButton(image: PhotoUtils.combine(photo: viewModel.uiImage, watermark: viewModel.watermarkImage))
            }
        }
        .alert(isPresented: $isShowCancelAlert) {
            Alert(
                title: Text("返回到主界面"),
                message: Text("放弃更改？"),
                primaryButton: .destructive(Text("确定")) {
                    dismiss()
                },
                secondaryButton: .cancel()
            )
        }
        .ignoresSafeArea(.all)
    }
}

#Preview {
    let image = UIImage(named: "Example1")!
    let exif = ExifData(image: image)
    EditorView(image: image, exif: exif)
}
