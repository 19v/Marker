import SwiftUI
import PhotosUI

struct EditorView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    init(image: UIImage, exif: ExifData) {
        viewModel = PhotoModel(image: image, exif: exif)
    }
    
    private var viewModel: PhotoModel
    
    @State private var isShowCancelAlert = false
    @State private var isDisplayWatermark = true
    
    var body: some View {
        ZStack {
            // 照片+水印
            EditPhotoDisplayView(viewModel: viewModel, isDisplayWatermark: $isDisplayWatermark)
            
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
        .navigationBarBackButtonHidden()
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
            
            if !isDisplayWatermark {
                ToolbarItem(placement: .principal) {
                    Text("原图")
                        .foregroundStyle(Color(hex: 0xC0C0C0))
                }
            }
            
            // 保存按钮
            ToolbarItem(placement: .topBarTrailing) {
                SavePhotoButton(image: PhotoUtils.combine(photo: viewModel.uiImage, watermark: viewModel.watermarkImage))
            }
        }
        .alert("返回到主界面", isPresented: $isShowCancelAlert) {
            Button("确定", role: .destructive) {
                dismiss()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("放弃更改？")
        }
        .ignoresSafeArea(.all)
    }
}

#Preview {
    let image = UIImage(named: "Example1")!
    let exif = ExifData(image: image)
    EditorView(image: image, exif: exif)
}
