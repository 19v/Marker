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
    
    static func addWhiteAreaToBottom(of image: UIImage, data: Watermark.Data) -> UIImage? {
        let originalSize = image.size
        let markerHeight = WatermarkHeightRatio.Basic.height(photoHeight: originalSize.height)
        return addWhiteAreaToBottom(of: image, data: data, withHeight: markerHeight)
    }
    
    static func addWhiteAreaToBottom(of image: UIImage, data: Watermark.Data, withHeight height: CGFloat) -> UIImage? {
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
    
    static func generateWhiteArea(with watermark: Watermark) -> UIImage? {
        // 默认照片尺寸（横向）：4096*3072
        // 水印尺寸（带时间或经纬度）：4096 * 472
        // 水印尺寸（不带时间经纬度）：4096 * 393
        let defaultWidth: CGFloat = 4096
        let defaultHeight: CGFloat = 393
        
        // 在默认尺寸下，左右的边距
        // 以下尺寸全部按照默认尺寸设定
        let leftPadding: CGFloat = 144
        let rightPadding: CGFloat = 144
        
        // 左侧部分信息
        // 拍摄设备 字体大小
        let deviceNameTextSize: CGFloat = 66
        
        // 右侧部分信息
        // 图标高度
        let iconHeight: CGFloat = 165
        // 分割线尺寸
        let rightDeliverWidth: CGFloat = 6
        let rightDeliverHeight: CGFloat = 142
        // 右边几个参数的间距
        let rightSpacing: CGFloat = 56
        // 拍摄参数 文字大小
        let paramsTextSize: CGFloat = 66
        
        let size = CGSize(width: defaultWidth, height: defaultHeight)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            // 绘制底部白色区域
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fill(CGRect(x: 0, y: 0, width: defaultWidth, height: defaultHeight))
            
            // 绘制左侧信息
            let leftText = NSString(string: watermark.data.deviceName)
            let leftTextAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "MiSans-Demibold", size: deviceNameTextSize) ?? UIFont.systemFont(ofSize: deviceNameTextSize, weight: .medium),
                .foregroundColor: Watermark.Information.deviceName.fontColor
            ]
            let leftTextSize = leftText.size(withAttributes: leftTextAttributes)
            leftText.draw(at: CGPoint(
                x: leftPadding,
                y: (defaultHeight - leftTextSize.height) / 2
            ), withAttributes: leftTextAttributes)
            
            // 绘制右侧信息
            let rightText = NSString(string: "\(watermark.data.focalLenIn35mmFilm)mm  f/\(watermark.data.fNumber)  \(watermark.data.exposureTime)s  ISO\(watermark.data.isoSpeedRatings)") // Example: 35mm  f/2.0  1/88s  ISO400
            let rightTextAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "MiSans-Demibold", size: paramsTextSize) ?? UIFont.systemFont(ofSize: paramsTextSize, weight: .medium),
                .foregroundColor: Watermark.Information.shootingParameters.fontColor
            ]
            let rightTextSize = rightText.size(withAttributes: rightTextAttributes)
            
            let iconText = NSString("")
            let iconTextAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: iconHeight),
                .foregroundColor: UIColor.black
            ]
            let iconTextSize = iconText.size(withAttributes: iconTextAttributes)
            
            let totalRightContentWidth = iconTextSize.width + rightSpacing + rightDeliverWidth + rightSpacing + rightTextSize.width
            let rightStartX = defaultWidth - rightPadding - totalRightContentWidth
            
            iconText.draw(at: CGPoint(
                x: rightStartX,
                y: (defaultHeight - iconTextSize.height) / 2
            ), withAttributes: iconTextAttributes)
            
            let verticalLineRect = CGRect(
                x: rightStartX + iconTextSize.width + rightSpacing,
                y: (defaultHeight - rightDeliverHeight) / 2,
                width: rightDeliverWidth,
                height: rightDeliverHeight
            )
            UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).setFill()
            context.fill(verticalLineRect) // 绘制竖线
            
            rightText.draw(at: CGPoint(
                x: rightStartX + iconTextSize.width + rightSpacing + rightDeliverWidth + rightSpacing,
                y: (defaultHeight - rightTextSize.height) / 2
            ), withAttributes: rightTextAttributes)
        }
    }
    
    static func combine(photo: UIImage, watermark: UIImage) -> UIImage? {
        let width = photo.size.width
        let photoHeight = photo.size.height
        
        let scale = width / watermark.size.width
        let watermarkHeight = watermark.size.height * scale
        
        let newSize = CGSize(width: width, height: photoHeight + watermarkHeight)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        photo.draw(in: CGRect(x: 0, y: 0, width: width, height: photoHeight))
        watermark.draw(in: CGRect(x: 0, y: photoHeight, width: width, height: watermarkHeight))
        
        let mergedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
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
