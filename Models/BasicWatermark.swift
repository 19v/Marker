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
    var deviceName: String = ""          // 设备名称，通常在左侧
    var shootingTime: String = ""        // 拍摄时间
    var shootingParameters: String = ""  // 拍摄参数
    var coordinate: String = ""          // 经纬度信息
    
    // 图片方向，该属性决定了水印的默认使用宽度
    var orientation: Orientation = .horizontal
    var defaultWidth: CGFloat {
        switch orientation {
        case .horizontal: 4096
        case .vertical: 3072
        }
    }
    var defaultHeight: CGFloat {
        if displayTime || displayCoordinate {
            472
        } else {
            393
        }
    }
    
    // 初始化
    required init(exifData: ExifData?) {
        // 设备名
        deviceName = if let model = exifData?.model {
            model
        } else {
            UIDevice.current.name // 默认使用当前设备名称
        }
        
        // 拍摄时间
        shootingTime = if let dateTimeOriginal = exifData?.dateTimeOriginal,
           let offsetTimeOriginal = exifData?.offsetTimeOriginal,
           let date = CommonUtils.convertToDate(dateTime: dateTimeOriginal, timeZone: offsetTimeOriginal) {
            CommonUtils.getTimestamp(date: date)
        } else {
            CommonUtils.getCurrentTimestamp()
        }
        
        // 光圈值
        let fNumber = if let fNum = exifData?.fNumber {
            String(format: "%.1f", fNum)
        } else {
            "0"
        }
        // 35mm胶片的等效焦距
        let focalLenIn35mmFilm = if let focalLenIn35mmFilm = exifData?.focalLenIn35mmFilm {
            String(focalLenIn35mmFilm)
        } else {
            "0"
        }
        // 曝光时间
        let exposureTime = if let exposureTime = exifData?.exposureTime {
            "1/\(CommonUtils.decimalToFractionDenominator(decimal: exposureTime))"
        } else {
            "1/1"
        }
        // 感光度
        let isoSpeedRatings = if let v = exifData?.isoSpeedRatings?.first,
                                 let v {
            String(v)
        } else {
            "0"
        }
        // 拍摄参数
        // Example: `35mm  f/2.0  1/88s  ISO400`
        shootingParameters = "\(focalLenIn35mmFilm)mm  f/\(fNumber)  \(exposureTime)s  ISO\(isoSpeedRatings)"
        
        // 位置信息
        // Example: `31°58'19.92"N  118°45'24.93"E` (latitude & longitude)
        coordinate = if let latitude = exifData?.latitude,
                        let longitude = exifData?.longitude {
            "\(latitude)  \(longitude)"
        } else {
            "未能获取到位置信息"
        }
        
        // 照片方向
        // 参考：https://jdhao.github.io/2019/07/31/image_rotation_exif_info/
        orientation = switch exifData?.orientation {
        case 1,2,3,4: .horizontal
        case 5,6,7,8: .vertical
        default: .horizontal
        }
    }
    
    // 背景色
    var backgroundColor = BackgroundColor.white
    let enabledBackgroundColors: [BackgroundColor] = [.white, .black]
    func setBackgroundColor(newColor: BackgroundColor) {
        self.backgroundColor = newColor
    }
    
    // 控制显示元素的开关
    var displayTime = false          // 显示时间的开关
    var displayCoordinate = false    // 显示经纬度的开关
    
    enum Style {
        case basic     // 仅包含拍摄设备、Logo、照片信息的版本
        case detailed  // 在 basic 基础上，需要显示日期或经纬度等信息的版本，此时高度也会增加一些
        
        // 按照原始照片高度计算水印区域应该有的高度
        // 比如 4096*3072 的照片，水印区域高度为 3072*0.156=472px，照片总高度即为 4096*3544
        var ratio: Double {
            switch self {
            case .basic:
                0.128
            case .detailed:
                0.156
            }
        }
        
        // 返回该样式应显示的页面元素
        var elements: [Information] {
            switch self {
            case .basic:
                [.deviceName, .shootingParameters]
            case .detailed:
                [.deviceName, .time, .shootingParameters, .coordinate]
            }
        }
        
    }
    
    enum Information: CaseIterable {
        case deviceName          // 设备名称
        case time                // 时间
        case shootingParameters  // 拍摄参数
        case coordinate          // 经纬度
        
        // 该信息所使用的字体名称
        var fontName: String {
            switch self {
            case .deviceName, .shootingParameters:
                InputFonts.miSansDemibold.rawValue
            case .time, .coordinate:
                InputFonts.miSansRegular.rawValue
            }
        }
        
        // 该信息所使用的字体颜色，该属性受 BackgroundColor 影响
        func getFontColor(backgroundColor: BackgroundColor) -> UIColor {
            switch self {
            case .deviceName, .shootingParameters:
                switch backgroundColor {
                case .white:
                    UIColor.black
                case .black:
                    UIColor.white
                default: .black
                }
            case .time, .coordinate:
                switch backgroundColor {
                case .white:
                    UIColor(red: 115/255, green: 115/255, blue: 115/255, alpha: 1)
                case .black:
                    UIColor(red: 127/255, green: 127/255, blue: 127/255, alpha: 1)
                default: .black
                }
            }
        }
        
        // 在根据 ratio 计算出水印区域高度后
        // 大部分元素的尺寸都根据水印区域高度来决定（乘以比例）
    }
    
    var uiImage: UIImage? {
        if displayTime || displayCoordinate {
            largeVersion
        } else {
            basicVersion
        }
    }
    
    private var basicVersion: UIImage? {
        let defaultWidth = defaultWidth
        let defaultHeight = defaultHeight
        
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
            context.cgContext.setFillColor(backgroundColor.cgColor)
            context.cgContext.fill(CGRect(x: 0, y: 0, width: defaultWidth, height: defaultHeight))
            
            // 绘制左侧信息
            let leftText = NSString(string: deviceName)
            let leftTextAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: InputFonts.miSansDemibold.rawValue, size: deviceNameTextSize) ?? UIFont.systemFont(ofSize: deviceNameTextSize, weight: .medium),
                .foregroundColor: BasicWatermark.Information.deviceName.getFontColor(backgroundColor: backgroundColor)
            ]
            let leftTextSize = leftText.size(withAttributes: leftTextAttributes)
            leftText.draw(at: CGPoint(
                x: leftPadding,
                y: (defaultHeight - leftTextSize.height) / 2
            ), withAttributes: leftTextAttributes)
            
            // 绘制右侧信息
            let rightText = NSString(string: shootingParameters)
            let rightTextAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: InputFonts.miSansDemibold.rawValue, size: paramsTextSize) ?? UIFont.systemFont(ofSize: paramsTextSize, weight: .medium),
                .foregroundColor: Information.shootingParameters.getFontColor(backgroundColor: backgroundColor)
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
            
            // 绘制竖线
            let verticalLineRect = CGRect(
                x: rightStartX + iconTextSize.width + rightSpacing,
                y: (defaultHeight - rightDeliverHeight) / 2,
                width: rightDeliverWidth,
                height: rightDeliverHeight
            )
            UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).setFill()
            context.fill(verticalLineRect)
            
            rightText.draw(at: CGPoint(
                x: rightStartX + iconTextSize.width + rightSpacing + rightDeliverWidth + rightSpacing,
                y: (defaultHeight - rightTextSize.height) / 2
            ), withAttributes: rightTextAttributes)
        }
    }
    
    private var largeVersion: UIImage? {
        let defaultWidth = defaultWidth
        let defaultHeight = defaultHeight
        
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
            context.cgContext.setFillColor(backgroundColor.cgColor)
            context.cgContext.fill(CGRect(x: 0, y: 0, width: defaultWidth, height: defaultHeight))
            
            // 绘制左侧信息
            let leftText = NSString(string: deviceName)
            let leftTextAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: InputFonts.miSansDemibold.rawValue, size: deviceNameTextSize) ?? UIFont.systemFont(ofSize: deviceNameTextSize, weight: .medium),
                .foregroundColor: BasicWatermark.Information.deviceName.getFontColor(backgroundColor: backgroundColor)
            ]
            let leftTextSize = leftText.size(withAttributes: leftTextAttributes)
            leftText.draw(at: CGPoint(
                x: leftPadding,
                y: (defaultHeight - leftTextSize.height) / 2
            ), withAttributes: leftTextAttributes)
            
            // 绘制右侧信息
            let rightText = NSString(string: shootingParameters)
            let rightTextAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: InputFonts.miSansDemibold.rawValue, size: paramsTextSize) ?? UIFont.systemFont(ofSize: paramsTextSize, weight: .medium),
                .foregroundColor: Information.shootingParameters.getFontColor(backgroundColor: backgroundColor)
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
            
            // 绘制竖线
            let verticalLineRect = CGRect(
                x: rightStartX + iconTextSize.width + rightSpacing,
                y: (defaultHeight - rightDeliverHeight) / 2,
                width: rightDeliverWidth,
                height: rightDeliverHeight
            )
            UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).setFill()
            context.fill(verticalLineRect)
            
            rightText.draw(at: CGPoint(
                x: rightStartX + iconTextSize.width + rightSpacing + rightDeliverWidth + rightSpacing,
                y: (defaultHeight - rightTextSize.height) / 2
            ), withAttributes: rightTextAttributes)
        }
    }
    
}
