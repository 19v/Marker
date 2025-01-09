import SwiftUI
import PhotosUI

struct EditorView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    let photo: UIImage?
    
    @StateObject private var viewModel = PhotoModel()
    
    @ViewBuilder private var photoView: some View {
        switch viewModel.imageState {
        case .empty, .failure:
            VStack(spacing: 4) {
                Image(systemName: "photo.badge.exclamationmark.fill")
                    .scaledToFit()
                    .font(.system(size: 50))
                    .foregroundStyle(.secondary)
                Text("图片加载失败")
                    .font(.system(.footnote))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loading:
            ProgressView(/*"请等待…照片加载中"*/)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(colorScheme == .dark ? .white : .init(hex: 0x282828))
                .ignoresSafeArea()
        case .success(let image):
            EditPhotoDisplayView(image: image, watermark: viewModel.watermarkImage, isWatermarkDisplayed: viewModel.isWatermarkDisplayed)
        }
    }
    
    var body: some View {
        ZStack {
            // 照片+水印
            photoView
            
            // 顶部按钮的半透明背景
            VStack {
                Rectangle()
                    .fill(colorScheme == .light ? .white : .black)
//                    .fill(.bar)
                    .fill(.ultraThinMaterial)
                    .foregroundStyle(colorScheme == .light ? .white : .black)
                    .opacity(0.8)
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
//                    viewModel.imageLoaded.toggle() // 设置为 false 以 pop 页面
                    dismiss()
                } label: {
                    Text("取消")
                        .font(.system(size: 16))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.init(hex: 0xA0A0A0))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
            
            // 显示水印按钮
            ToolbarItem(placement: .principal) {
                Button {
                    withAnimation {
                        viewModel.isWatermarkDisplayed.toggle()
                    }
                } label: {
                    Text("水印：\(viewModel.isWatermarkDisplayed ? "开" : "关")")
                        .font(.system(size: 16))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.clear)
                        .foregroundColor(Color.init(hex: 0xA0A0A0))
                        .overlay(
                            Capsule()
                                .stroke(Color.gray, lineWidth: 2)
                        )
                        .clipShape(Capsule())
                }
            }
            
            // 保存按钮
            ToolbarItem(placement: .topBarTrailing) {
                SavePhotoButton(image: viewModel.fullImage)
            }
        }
        .ignoresSafeArea(.all)
        .onAppear {
            viewModel.uiImage = photo
        }
    }
}

#Preview {
    EditorView(photo: UIImage(named: "Example1"))
}
