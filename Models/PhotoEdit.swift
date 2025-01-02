import SwiftUI
import PhotosUI
import CoreTransferable
import UIKit
import ImageIO
import CoreLocation

@MainActor
class PhotoModel: ObservableObject {
    
    // MARK: - 照片相关
    // MARK: 照片定义
    enum ImageState {
        case empty
		case loading(Progress)
		case success(Image)
		case failure(Error)
    }
    
    enum TransferError: Error {
        case importFailed
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
    
    // MARK: 照片实例
    
    @Published private(set) var imageState: ImageState = .empty /*.success(Image("Example1"))*/  // 注释部分用于Preview使用
    
    @Published var imageLoaded = false
    
    // 单张照片适用
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
    
    // 多张照片适用
    // TODO: 这部分我认为应当用一个单独的类去做，单张和多张不宜放在一块
    @Published var imagesSelection: [PhotosPickerItem] = []
    
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
                watermark = BasicWatermark(exifData: exifData)
            }
        }
    }
    
    // MARK: - 水印相关
    
    // 水印信息，包含样式信息和数据
    var watermark: WatermarkProtocol? {
        didSet {
            refreshWatermarkImage()
        }
    }
    var watermarkImage: UIImage?/* = Image(uiImage: PhotoUtils.generateWhiteArea(with: Watermark(exifData: ExifData(image: UIImage(named: "Example1")!)))!)*/  // 注释部分用于Preview使用
    func refreshWatermarkImage() {
        watermarkImage = watermark?.uiImage
    }
    
    // 将水印和原图拼合起来……
    var fullImage: UIImage? {
        if let uiImage,
           let watermarkImage {
            return PhotoUtils.combine(photo: uiImage, watermark: watermarkImage)
        }
        return nil
    }
    
    // 重置状态
    func reset() {
        imageSelection = nil
    }
    
    // MARK: - 界面相关
    
    @Published var deviceName: String = "" // 自定义设备名（默认样式下左侧的名称）
    
    // 显示水印的开关
    @Published var displayWatermark = true
    
    // 切换背景颜色的按钮
    var enabledColors: [Color] {
        if let vm = watermark as? BackgroundEditable {
            vm.enabledBackgroundColors.map { $0.color }
        } else {
            []
        }
    }
    @Published var displayBackgroundColorSubview = false
    @Published var backgroundColorIndex = 0 {
        didSet {
            guard let vw = watermark as? BackgroundEditable else { return }
            vw.changeColor(withIndex: backgroundColorIndex)
            refreshWatermarkImage()
        }
    }
    
    // 显示时间的开关
    @Published var displayTimeEditSubview = false
    @Published var displayTime = false {
        didSet {
            guard let vw = watermark as? TimeEditable else { return }
            vw.isTimeDisplayed.toggle()
            refreshWatermarkImage()
        }
    }
//    @Published var customTime: Date {
//        didSet {
//            guard let vw = watermark as? TimeEditable else { return }
//            vw.setCustomTime(customTime)
//            refreshWatermarkImage()
//        }
//    }
//    func restoreDefaultTime() {
//        guard let vw = watermark as? TimeEditable else { return }
//        vw.restoreDefaultTime()
//        refreshWatermarkImage()
//    }
    
    // 显示经纬度的开关
    @Published var displayCoordinate = false{
        didSet {
            guard let vw = watermark as? CoordinateEditable else { return }
            vw.isCoordinateDisplayed.toggle()
            refreshWatermarkImage()
        }
    }
    
}
