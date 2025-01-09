import UIKit

/**
 # 基本样式
 
 位于底部，颜色有白色和黑色可选
 显示组成有拍摄设备名称、日期时间、拍摄参数和经纬度信息
 默认仅显示设备名和拍摄参数
 当需要显示日期时间或位置信息时，高度需要增加
 
 生成水印时，默认照片的尺寸为`4096*3072`（4:3）
 水印的尺寸则为`4096*393`（只显示设备名和参数）或`4096*472`（显示时间或地理信息）
 如果图片为纵向，长边应当为`3072`
 图片缩小水印也等比例缩小
 */

class BasicWatermark: WatermarkProtocol, InfoDisplayable, BackgroundEditable, TimeEditable, CoordinateEditable {
    
    // 需要显示的信息
    var deviceName: DisplayItem         // 设备名称，通常在左侧
    var shootingTime: DisplayItem       // 拍摄时间
    var shootingParameters: DisplayItem // 拍摄参数
    var coordinate: DisplayItem         // 经纬度信息
    
    // 图片方向，该属性决定了水印的默认使用宽度
    var orientation: Orientation = .horizontal
    
    // 初始化
    required init(exifData: ExifData) {
        // 设备名
        deviceName = DisplayItem(
            value: exifData.model ?? UIDevice.current.name, // 默认使用当前设备名称
            colors: foregroundColors1,
            fontName: .miSansDemibold,
            fontSize: 87
        )
        
        // 拍摄时间
        originalTime = { () -> Date in
            if let dateTimeOriginal = exifData.dateTimeOriginal,
               let offsetTimeOriginal = exifData.offsetTimeOriginal,
               let date = Date.from(dateString: dateTimeOriginal, timeZoneString: offsetTimeOriginal) {
                date
            } else {
                Date()
            }
        }()
        customTime = originalTime
        shootingTime = DisplayItem(
            value: originalTime.timestamp,
            colors: foregroundColors2,
            fontName: .miSansRegular,
            fontSize: 66
        )
        
        // 拍摄参数
        // Example: `35mm  f/2.0  1/88s  ISO400`
        shootingParameters = DisplayItem(
            value: { () -> String in
                // 光圈值
                let fNumber = if let fNum = exifData.fNumber {
                    String(format: "%.1f", fNum)
                } else {
                    "0"
                }
                // 35mm胶片的等效焦距
                let focalLenIn35mmFilm = if let focalLenIn35mmFilm = exifData.focalLenIn35mmFilm {
                    String(focalLenIn35mmFilm)
                } else {
                    "0"
                }
                // 曝光时间
                let exposureTime = if let exposureTime = exifData.exposureTime {
                    "1/\(CommonUtils.decimalToFractionDenominator(decimal: exposureTime))"
                } else {
                    "1/1"
                }
                // 感光度
                let isoSpeedRatings = if let v = exifData.isoSpeedRatings?.first,
                                         let v {
                    String(v)
                } else {
                    "0"
                }
                return "\(focalLenIn35mmFilm)mm  f/\(fNumber)  \(exposureTime)s  ISO\(isoSpeedRatings)"
            }(),
            colors: foregroundColors1,
            fontName: .miSansDemibold,
            fontSize: 87
        )
         
        
        // 位置信息
        // Example: `31°58'19.92"N  118°45'24.93"E` (latitude & longitude)
        coordinate = DisplayItem(
            value: { () -> String in
                if let latitude = exifData.latitude,
                   let longitude = exifData.longitude {
                    let result = PhotoUtils.convertDecimalCoordinateToDMS(latitude: latitude, longitude: longitude)
                    return "\(result.latitudeDMS)  \(result.longitudeDMS)"
                } else {
                    return "未能获取到位置信息"
                }
            }(),
            colors: foregroundColors2,
            fontName: .miSansRegular,
            fontSize: 66
        )
        
        // 照片方向
        // 参考 Founcation 中的 UIImage.imageOrientation 枚举的定义
        // 默认视作横向
        orientation = Orientation(rawValue: exifData.orientation ?? UIImage.Orientation.up.rawValue)
    }
    
    // 背景色
    private var backgroundColors = WatermarkColors(colors: [.white, .black])
    private var backgroundColor: UIColor { backgroundColors.uiColor }
    func changeColor(withIndex newColorIndex: Int) {
        WatermarkColors.index = newColorIndex
    }
    var enabledBackgroundColors: [WatermarkColor] {
        backgroundColors.colors
    }
    
    // 字体颜色，需要与背景色配套
    private var foregroundColors1 = WatermarkColors(colors: [.black, .white])
    private var foregroundColors2 = WatermarkColors(colors: [.custom(0x737373), .custom(0x7F7F7F)])
    
    // 分割线颜色
    private let dividerColors = WatermarkColors(colors: [.custom(0xCCCCCC), .white])
    private var dividerColor: UIColor { dividerColors.uiColor }
    
    // 显示时间的开关
    var isTimeDisplayed = false
    private(set) var originalTime: Date
    private var customTime: Date
    var displayTime: Date {
        get {
            customTime
        }
        set {
            customTime = newValue
            shootingTime.customValue = newValue.timestamp
        }
    }
    func restoreDefaultTime() {
        customTime = originalTime
        shootingTime.clearCustomValue()
    }
    
    // 显示经纬度的开关
    var isCoordinateDisplayed = false
    
    var uiImage: UIImage {
        let defaultWidth: CGFloat = switch orientation {
        case .horizontal: 4096
        case .vertical: 3072
        }
        let defaultHeight: CGFloat = (isTimeDisplayed || isCoordinateDisplayed) ? 472 : 393
        let watermarkSize = CGSize(width: defaultWidth, height: defaultHeight)
        let renderer = UIGraphicsImageRenderer(size: watermarkSize)
        
        // NOTE: 以下尺寸全部按照默认尺寸设定
        
        // 在默认尺寸下，左右的边距
        let leftPadding: CGFloat = 144
        let rightPadding: CGFloat = 144
        
        // 双行时，纵向的间距
        let leftVerticalPadding: CGFloat = 60
        let rightVerticalPadding: CGFloat = 66
        
        // 图标
        let iconHeight: CGFloat = (isTimeDisplayed || isCoordinateDisplayed) ? 182 : 165
        let iconText = NSString("")
        let iconTextAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: iconHeight),
            .foregroundColor: foregroundColors1.uiColor // TODO: 这个颜色暂时和文字用一个颜色，后面再改
        ]
        let iconTextSize = iconText.size(withAttributes: iconTextAttributes)
        
        // 分割线尺寸
        let rightDeliverWidth: CGFloat = (isTimeDisplayed || isCoordinateDisplayed) ? 5 : 6
        let rightDeliverHeight: CGFloat = (isTimeDisplayed || isCoordinateDisplayed) ? 178 : 142
        
        // 右边图标、分割线和拍摄参数的间距
        let rightSpacing: CGFloat = (isTimeDisplayed || isCoordinateDisplayed) ? 65 : 56
        
        // 开始绘制
        if isTimeDisplayed && isCoordinateDisplayed {
            // 时间和经纬度都显示
            return renderer.image { context in
                // 绘制背景
                context.cgContext.setFillColor(backgroundColor.cgColor)
                context.cgContext.fill(CGRect(x: 0, y: 0, width: defaultWidth, height: defaultHeight))
                
                // 绘制左侧信息
                let deviceName = deviceName.getText()
                let shootingTime = shootingTime.getText()
                
                let totalLeftContentHeight = deviceName.size.height + leftVerticalPadding + shootingTime.size.height
                
                deviceName.draw(x: leftPadding, y: (defaultHeight - totalLeftContentHeight) / 2)
                shootingTime.draw(x: leftPadding, y: (defaultHeight + leftVerticalPadding) / 2)
                
                // 绘制右侧信息
                let shootingParameters = shootingParameters.getText()
                let coordinate = coordinate.getText()
                
                let totalRightContentWidth = iconTextSize.width + rightSpacing + rightDeliverWidth + rightSpacing + max(shootingParameters.size.width, coordinate.size.width)
                let totalRightContentHeight = shootingParameters.size.height + rightVerticalPadding + coordinate.size.height
                let rightStartX = defaultWidth - rightPadding - totalRightContentWidth
                let rightTextStartX = rightStartX + iconTextSize.width + rightSpacing + rightDeliverWidth + rightSpacing
                
                shootingParameters.draw(x: rightTextStartX, y: (defaultHeight - totalRightContentHeight) / 2)
                coordinate.draw(x: rightTextStartX, y: (defaultHeight + rightVerticalPadding) / 2)
                
                // 绘制右侧图标
                iconText.draw(at: CGPoint(x: rightStartX, y: (defaultHeight - iconTextSize.height) / 2 ), withAttributes: iconTextAttributes)
                
                // 绘制右侧分割线
                dividerColor.setFill()
                context.fill(CGRect(
                    x: rightStartX + iconTextSize.width + rightSpacing,
                    y: (defaultHeight - rightDeliverHeight) / 2,
                    width: rightDeliverWidth,
                    height: rightDeliverHeight
                ))
            }
        } else if isTimeDisplayed && !isCoordinateDisplayed {
            // 只显示时间
            return renderer.image { context in
                // 绘制背景
                context.cgContext.setFillColor(backgroundColor.cgColor)
                context.cgContext.fill(CGRect(x: 0, y: 0, width: defaultWidth, height: defaultHeight))
                
                // 绘制左侧信息
                let deviceName = deviceName.getText()
                deviceName.draw(x: leftPadding, y: (defaultHeight - deviceName.size.height) / 2)
                
                // 绘制右侧信息
                let shootingParameters = shootingParameters.getText()
                let shootingTime = shootingTime.getText()
                
                let totalRightContentWidth = iconTextSize.width + rightSpacing + rightDeliverWidth + rightSpacing + max(shootingParameters.size.width, shootingTime.size.width)
                let totalRightContentHeight = shootingParameters.size.height + rightVerticalPadding + shootingTime.size.height
                let rightStartX = defaultWidth - rightPadding - totalRightContentWidth
                let rightTextStartX = rightStartX + iconTextSize.width + rightSpacing + rightDeliverWidth + rightSpacing
                
                shootingParameters.draw(x: rightTextStartX, y: (defaultHeight - totalRightContentHeight) / 2)
                shootingTime.draw(x: rightTextStartX, y: (defaultHeight + rightVerticalPadding) / 2)
                
                // 绘制右侧图标
                iconText.draw(at: CGPoint(x: rightStartX, y: (defaultHeight - iconTextSize.height) / 2 ), withAttributes: iconTextAttributes)
                
                // 绘制右侧分割线
                dividerColor.setFill()
                context.fill(CGRect(
                    x: rightStartX + iconTextSize.width + rightSpacing,
                    y: (defaultHeight - rightDeliverHeight) / 2,
                    width: rightDeliverWidth,
                    height: rightDeliverHeight
                ))
            }
        } else if !isTimeDisplayed && isCoordinateDisplayed {
            // 只显示经纬度
            return renderer.image { context in
                // 绘制背景
                context.cgContext.setFillColor(backgroundColor.cgColor)
                context.cgContext.fill(CGRect(x: 0, y: 0, width: defaultWidth, height: defaultHeight))
                
                // 绘制左侧信息
                let deviceName = deviceName.getText()
                deviceName.draw(x: leftPadding, y: (defaultHeight - deviceName.size.height) / 2)
                
                // 绘制右侧信息
                let shootingParameters = shootingParameters.getText()
                let coordinate = coordinate.getText()
                
                let totalRightContentWidth = iconTextSize.width + rightSpacing + rightDeliverWidth + rightSpacing + max(shootingParameters.size.width, coordinate.size.width)
                let totalRightContentHeight = shootingParameters.size.height + rightVerticalPadding + coordinate.size.height
                let rightStartX = defaultWidth - rightPadding - totalRightContentWidth
                let rightTextStartX = rightStartX + iconTextSize.width + rightSpacing + rightDeliverWidth + rightSpacing
                
                shootingParameters.draw(x: rightTextStartX, y: (defaultHeight - totalRightContentHeight) / 2)
                coordinate.draw(x: rightTextStartX, y: (defaultHeight + rightVerticalPadding) / 2)
                
                // 绘制右侧图标
                iconText.draw(at: CGPoint(x: rightStartX, y: (defaultHeight - iconTextSize.height) / 2 ), withAttributes: iconTextAttributes)
                
                // 绘制右侧分割线
                dividerColor.setFill()
                context.fill(CGRect(
                    x: rightStartX + iconTextSize.width + rightSpacing,
                    y: (defaultHeight - rightDeliverHeight) / 2,
                    width: rightDeliverWidth,
                    height: rightDeliverHeight
                ))
            }
        } else if !isTimeDisplayed && !isCoordinateDisplayed {
            // 时间和经纬度都不显示
            return renderer.image { context in
                // 绘制背景
                context.cgContext.setFillColor(backgroundColor.cgColor)
                context.cgContext.fill(CGRect(x: 0, y: 0, width: defaultWidth, height: defaultHeight))
                
                // 绘制左侧信息
                let deviceName = deviceName.getText()
                deviceName.draw(x: leftPadding, y: (defaultHeight - deviceName.size.height) / 2)
                
                // 绘制右侧信息
                let shootingParameters = shootingParameters.getText()
                
                let totalRightContentWidth = iconTextSize.width + rightSpacing + rightDeliverWidth + rightSpacing + shootingParameters.size.width
                let rightStartX = defaultWidth - rightPadding - totalRightContentWidth
                let rightTextStartX = rightStartX + iconTextSize.width + rightSpacing + rightDeliverWidth + rightSpacing
                
                shootingParameters.draw(x: rightTextStartX, y: (defaultHeight - shootingParameters.size.height) / 2)
                
                // 绘制右侧图标
                iconText.draw(at: CGPoint(x: rightStartX, y: (defaultHeight - iconTextSize.height) / 2 ), withAttributes: iconTextAttributes)
                
                // 绘制右侧分割线
                dividerColor.setFill()
                context.fill(CGRect(
                    x: rightStartX + iconTextSize.width + rightSpacing,
                    y: (defaultHeight - rightDeliverHeight) / 2,
                    width: rightDeliverWidth,
                    height: rightDeliverHeight
                ))
            }
        } else {
            LoggerManager.shared.error("参数有误！")
            return UIImage() // TODO: 暂时先返回个空的？后面再来补
        }
    }
    
}
