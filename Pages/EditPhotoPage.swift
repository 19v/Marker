import SwiftUI
import PhotosUI

struct EditPhotoPage: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @ObservedObject var viewModel: PhotoModel
    
    let onDisappearAction: () -> Void
    
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
            photoView
            EditPhotoToolbarView(viewModel: viewModel)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // 关闭按钮
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    viewModel.imageLoaded.toggle() // 设置为 false 以 pop 页面
                    onDisappearAction()
                } label: {
//                    Image(systemName: "xmark.circle")
                    Text("取消")
                        .font(.headline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.gray)
                        .foregroundColor(.white)
                        .overlay(
                            Capsule()
                                .stroke(Color.gray, lineWidth: 2)
                        )
                        .clipShape(Capsule())
                }
            }
            
            // 保存按钮
            ToolbarItem {
                Button {
                    LoggerManager.shared.debug("保存按钮点击")
                    if let uiImage = viewModel.fullImage {
                        PhotoSaver.with(uiImage: uiImage)
                    }
                } label: {
//                    Image(systemName: "square.and.arrow.down")
                    Text("保存")
                        .font(.headline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.clear)
                        .foregroundColor(.blue)
                        .overlay(
                            Capsule()
                                .stroke(Color.blue, lineWidth: 2)
                        )
                        .clipShape(Capsule())
                }
            }
        }
        .sheet(isPresented: $viewModel.isSheetPresented) {
            HalfTransparentSheetView(isSheetPresented: $viewModel.isSheetPresented, viewModel: viewModel)
                .presentationBackground(.ultraThinMaterial)
                .presentationDetents([.fraction(0.2), .medium, .large], selection: $viewModel.settingsDetent)
                .presentationDragIndicator(.visible)
        }
        .onDisappear(perform: onDisappearAction)
        .ignoresSafeArea(.all)
    }
}

#Preview {
    EditPhotoPage(viewModel: PhotoModel()) {}
}
