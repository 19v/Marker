import CoreLocation
import PhotosUI
import UIKit

class PhotoUtils {
    
    // 添加水印（基础）
    enum WatermarkHeightRatio: CGFloat {
        case Basic = 0.128
        case Detailed = 0.156
        
        func height(photoHeight: CGFloat) -> CGFloat {
            ceil(photoHeight * rawValue)
        }
    }
    
    static func addWhiteAreaToBottom(of image: UIImage, data: WatermarkData) -> UIImage? {
        let originalSize = image.size
        let markerHeight = WatermarkHeightRatio.Basic.height(photoHeight: originalSize.height)
        return addWhiteAreaToBottom(of: image, data: data, withHeight: markerHeight)
    }
    
    static func addWhiteAreaToBottom(of image: UIImage, data: WatermarkData, withHeight height: CGFloat) -> UIImage? {
        let originalSize = image.size
        let newSize = CGSize(width: originalSize.width, height: originalSize.height + height)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let newImage = renderer.image { context in
            // 绘制原始图片在上方
            image.draw(at: CGPoint(x: 0, y: 0))
            
            // 绘制底部白色区域
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fill(CGRect(x: 0, y: originalSize.height, width: newSize.width, height: height))
            
            // 测算左右边距
            let leftPadding = height * 0.366
            let rightPadding = height * 0.366
            
            // 绘制左侧信息
            let leftText = NSString(string: data.deviceName)
            let leftTextFontSize = height * 0.168
            let leftTextAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "MiSans-Demibold", size: leftTextFontSize) ?? UIFont.systemFont(ofSize: leftTextFontSize, weight: .medium),
                .foregroundColor: Watermark.Information.deviceName.fontColor
            ]
            let leftTextSize = leftText.size(withAttributes: leftTextAttributes)
            leftText.draw(at: CGPoint(
                x: leftPadding,
                y: originalSize.height + (height - leftTextSize.height) / 2
            ), withAttributes: leftTextAttributes)
            
            // 绘制右侧信息
            let spacing = height * 0.142
            
            let rightText = NSString(string: "\(data.focalLenIn35mmFilm)mm  f/\(data.fNumber)  \(data.exposureTime)s  ISO\(data.isoSpeedRatings)") // Example: 35mm  f/2.0  1/88s  ISO400
            let rightTextFontSize = height * 0.168
            let rightTextAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "MiSans-Demibold", size: leftTextFontSize) ?? UIFont.systemFont(ofSize: rightTextFontSize, weight: .medium),
                .foregroundColor: Watermark.Information.shootingParameters.fontColor
            ]
            let rightTextSize = rightText.size(withAttributes: rightTextAttributes)
            
            let iconText = NSString("")
            let iconTextFontSize = height * 0.42
            let iconTextAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: iconTextFontSize),
                .foregroundColor: UIColor.black
            ]
            let iconTextSize = iconText.size(withAttributes: iconTextAttributes)
            
            let verticalLineWidth = height * 0.0153
            
            let totalRightContentWidth = iconTextSize.width + spacing + verticalLineWidth + spacing + rightTextSize.width
            let rightStartX = newSize.width - rightPadding - totalRightContentWidth
            
            iconText.draw(at: CGPoint(
                x: rightStartX,
                y: originalSize.height + (height - iconTextSize.height) / 2
            ), withAttributes: iconTextAttributes)
            
            let verticalLineHeight = height * 0.361
            let verticalLineRect = CGRect(
                x: rightStartX + iconTextSize.width + spacing,
                y: originalSize.height + (height - verticalLineHeight) / 2,
                width: verticalLineWidth,
                height: verticalLineHeight
            )
            UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).setFill()
            context.fill(verticalLineRect) // 绘制竖线
            
            rightText.draw(at: CGPoint(
                x: rightStartX + iconTextSize.width + spacing + verticalLineWidth + spacing,
                y: originalSize.height + (height - rightTextSize.height) / 2
            ), withAttributes: rightTextAttributes)
        }
        
        return newImage
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
