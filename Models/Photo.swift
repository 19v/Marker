import SwiftUI
import PhotosUI
import CoreTransferable
import UIKit
import ImageIO
import CoreLocation

@MainActor
class PhotoModel: ObservableObject {
    
    enum ImageState {
        case empty
		case loading(Progress)
		case success(Image)
		case failure(Error)
    }
    
    enum TransferError: Error {
        case importFailed
    }
    
    @Published var deviceName: String = "" // 自定义设备名（默认样式下左侧的名称）
    @Published var displayWatermark = true // 显示水印的开关
    @Published var displayTime = false // 显示时间的开关
    @Published var displayCoordinate = false // 显示经纬度的开关
    
    func reset() {
        imageSelection = nil
    }
    
    @Published private(set) var imageState: ImageState = .empty /*.success(Image("Example1"))*/  // 注释部分用于Preview使用
    @Published var imageLoaded = false
    
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            if let imageSelection {
                imageState = .loading(loadTransferable(from: imageSelection))
                imageLoaded.toggle()
            } else {
                imageState = .empty
            }
        }
    }
    
    @Published var imagesSelection: [PhotosPickerItem] = []
    
    @Published var imageModification: UIImage? = nil {
        didSet {
            if let imageModification {
                imageState = .success(Image(uiImage: imageModification))
            } else {
                imageState = .empty
            }
        }
    }
    
    var uiImage: UIImage?
    
    var photoURL: URL? {
        didSet {
            if let photoURL {
                exifData = ExifData(url: photoURL)
            }
        }
    }
    
    var exifData: ExifData? {
        didSet {
            if let exifData {
                watermark = Watermark(exifData: exifData)
            }
        }
    }
    
    // 水印信息，包含样式信息和数据
    var watermark: Watermark? {
        didSet {
            if let watermark,
               let uiImage = PhotoUtils.generateWhiteArea(with: watermark) {
                watermarkImage = Image(uiImage: uiImage)
            }
        }
    }
    var watermarkImage: Image?/* = Image(uiImage: PhotoUtils.generateWhiteArea(with: Watermark(exifData: ExifData(image: UIImage(named: "Example1")!)))!)*/  // 注释部分用于Preview使用
    
    // 将水印和原图拼合起来……
    var fullImage: UIImage? {
        if let uiImage,
           let watermark,
           let watermarkUiImage = PhotoUtils.generateWhiteArea(with: watermark) {
            return PhotoUtils.combine(photo: uiImage, watermark: watermarkUiImage)
        }
        return nil
    }
    
    struct Photo: Transferable {
        let id = UUID()
        
        let data: Data
        let image: Image
        
        #if canImport(AppKit)
        let nsImage: NSImage
        #elseif canImport(UIKit)
        let uiImage: UIImage
        #endif
        
        static var transferRepresentation: some TransferRepresentation {
            DataRepresentation(importedContentType: .image) { data in
            #if canImport(AppKit)
                guard let nsImage = NSImage(data: data) else {
                    throw TransferError.importFailed
                }
                let image = Image(nsImage: nsImage)
                return ProfileImage(image: image)
            #elseif canImport(UIKit)
                guard let uiImage = UIImage(data: data) else {
                    throw TransferError.importFailed
                }
                let image = Image(uiImage: uiImage)
                return Photo(data: data, image: image, uiImage: uiImage)
            #else
                throw TransferError.importFailed
            #endif
            }
        }
    }
    
	// MARK: Private Methods
	
    private func loadTransferable(from imageSelection: PhotosPickerItem) -> Progress {
        let contentType = imageSelection.supportedContentTypes.first
        let url = CommonUtils.getDocumentsDirectory().appendingPathComponent("\(UUID().uuidString).\(contentType?.preferredFilenameExtension ?? "")")
        
        return imageSelection.loadTransferable(type: Photo.self) { result in
            DispatchQueue.main.async {
                guard imageSelection == self.imageSelection else {
                    print("Failed to get the selected item.")
                    return
                }
                switch result {
                case .success(let photo?):
                    self.imageState = .success(photo.image)
                    self.uiImage = photo.uiImage
                    do {
                        try photo.data.write(to: url)
                        self.photoURL = url
                    } catch {
                        LoggerManager.shared.error("\(error)")
                    }
                case .success(nil):
                    self.imageState = .empty
                case .failure(let error):
                    self.imageState = .failure(error)
                }
            }
        }
    }
}
