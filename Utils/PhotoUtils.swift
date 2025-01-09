import CoreLocation
import Photos
import UIKit

class PhotoUtils {
    
    static func combine(photo: UIImage, watermark: UIImage) -> UIImage? {
        let width = photo.size.width
        let photoHeight = photo.size.height
        
        let scale = width / watermark.size.width
        let watermarkHeight = watermark.size.height * scale
        
        let newSize = CGSize(width: width, height: photoHeight + watermarkHeight)
        
        // 配置图像渲染器的格式
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1.0
        
        // 创建图像渲染器
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        
        // 绘制图像
        let mergedImage = renderer.image { context in
            photo.draw(in: CGRect(x: 0, y: 0, width: width, height: photoHeight))
            watermark.draw(in: CGRect(x: 0, y: photoHeight, width: width, height: watermarkHeight))
        }
        
        return mergedImage
    }
    
    static func convertDecimalCoordinateToDMS(latitude: Double, longitude: Double) -> (latitudeDMS: String, longitudeDMS: String) {
        func dmsString(from decimal: Double, directionPositive: String, directionNegative: String) -> String {
            let degrees = Int(decimal)
            let minutesDecimal = abs(decimal - Double(degrees)) * 60
            let minutes = Int(minutesDecimal)
            let seconds = (minutesDecimal - Double(minutes)) * 60
            
            let direction = decimal >= 0 ? directionPositive : directionNegative
            return String(format: "%d°%d'%05.2f\"%@", abs(degrees), minutes, seconds, direction)
        }
        
        let latitudeDMS = dmsString(from: latitude, directionPositive: "N", directionNegative: "S")
        let longitudeDMS = dmsString(from: longitude, directionPositive: "E", directionNegative: "W")
        
        return (latitudeDMS, longitudeDMS)
    }
    
}

class PhotoSaver: NSObject {
    
    enum SaveError: Error {
        case invalidImage
    }
    
    private var continuation: CheckedContinuation<Void, Error>?
    
    static func with(_ uiImage: UIImage?) async throws {
        guard let uiImage else { throw SaveError.invalidImage }
        let saver = PhotoSaver()
        try await withCheckedThrowingContinuation { continuation in
            saver.continuation = continuation
            UIImageWriteToSavedPhotosAlbum(uiImage, saver, #selector(PhotoSaver.callback(_: didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @objc private func callback(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer?) {
        if let error {
            LoggerManager.shared.error("保存失败: \(error.localizedDescription)")
            continuation?.resume(throwing: error) // 保存失败，抛出错误
        } else {
            LoggerManager.shared.info("图片已成功保存到相册")
            continuation?.resume() // 保存成功，正常结束
        }
        continuation = nil // 避免重复调用
    }
    
}
