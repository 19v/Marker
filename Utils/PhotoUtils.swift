import CoreLocation
import PhotosUI
import UIKit

class PhotoUtils {
    
    static func combine(photo: UIImage, watermark: UIImage) -> UIImage? {
        let width = photo.size.width
        let photoHeight = photo.size.height
        
        let scale = width / watermark.size.width
        let watermarkHeight = watermark.size.height * scale
        
        let newSize = CGSize(width: width, height: photoHeight + watermarkHeight)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let mergedImage = renderer.image { context in
            photo.draw(in: CGRect(x: 0, y: 0, width: width, height: photoHeight))
            watermark.draw(in: CGRect(x: 0, y: photoHeight, width: width, height: watermarkHeight))
        }
        
        return mergedImage
    }
    
}

class PhotoSaver: NSObject {

    static func with(uiImage: UIImage) {
        UIImageWriteToSavedPhotosAlbum(uiImage, self, #selector(callback(_: didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc static internal func callback(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer?) {
        if let error = error {
            LoggerManager.shared.error("保存失败: \(error.localizedDescription)")
        } else {
            LoggerManager.shared.info("图片已成功保存到相册")
        }
    }
    
}
