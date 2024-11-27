import SwiftUI
import PhotosUI

struct DisplayedImage: View {
    @ObservedObject var viewModel: PhotoModel
    
    var body: some View {
        PhotoView(imageState: viewModel.imageState)
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: 360)
            .background {
                Rectangle().fill(
                    Color(.systemGray5)
                )
            }
    }
}

struct PhotoView: View {
    let imageState: PhotoModel.ImageState
    
    var body: some View {
        switch imageState {
        case .success(let image):
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .draggable(image)
        case .loading:
            ProgressView()
        case .empty:
            VStack {
                Image(systemName: "photo")
//                    .resizable()
                    .scaledToFit()
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
                Text("请选择图片")
                    .foregroundStyle(.gray)
                    .padding([.top], 6)
            }
            .padding(20)
        case .failure:
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.white)
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
