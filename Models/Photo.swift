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
    
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var aboutMe: String = ""
    
    @Published var displayTime = false // 显示时间的开关
    {
        didSet {
            displayCoordinate.toggle()
        }
    }
    @Published var displayCoordinate = false // 显示经纬度的开关
    
    @Published var imageLoaded = false
    
    func reset() {
        imageSelection = nil
    }
    
    @Published private(set) var imageState: ImageState = .empty
    
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
                watermarkData = WatermarkData(exifData: exifData)
            }
        }
    }
    var watermarkData: WatermarkData?
    
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
