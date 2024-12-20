import UIKit

enum InputFonts: String {
    case miSansDemibold = "MiSans-Demibold"
    case miSansRegular = "MiSans-Regular"
}

class Watermark {
    
    init(exifData: ExifData) {
        data = Data(exifData: exifData)
    }
    
    // 基本数据
    let data: Data
    
    var style = Style.basic
    
    // 背景色
    var backgroundColor = BackgroundColor.white
    
}

// MARK: - 样式定义

extension Watermark {
    
    enum Style {
        case basic     // 仅包含拍摄设备、Logo、照片信息的版本
        case detailed  // 在 basic 基础上，需要显示日期、经纬度等信息的版本
        
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
                }
            case .time, .coordinate:
                switch backgroundColor {
                case .white:
                    UIColor(red: 115/255, green: 115/255, blue: 115/255, alpha: 1)
                case .black:
                    UIColor(red: 127/255, green: 127/255, blue: 127/255, alpha: 1)
                }
            }
        }
        
        // 在根据 ratio 计算出水印区域高度后
        // 大部分元素的尺寸都根据水印区域高度来决定（乘以比例）
    }
    
    enum BackgroundColor {
        case white
        case black
        
        var uiColor: UIColor {
            switch self {
            case .white:
                    .white
            case .black:
                    .black
            }
        }
        
        var cgColor: CGColor { uiColor.cgColor }
    }
    
}


// MARK: - 信息定义

extension Watermark {
    
    class Data {
        let deviceName: String // 设备名称
        let fNumber: String // 光圈值
        let focalLenIn35mmFilm: String // 35mm胶片的等效焦距
        let exposureTime: String // 曝光时间
        let isoSpeedRatings: String // 感光度
        let dateTime: String // 水印时间
        
        init(exifData: ExifData?) {
            if let model = exifData?.model {
                deviceName = model
            } else {
                deviceName = UIDevice.current.name // 默认使用当前设备名称
            }
            
            if let fNum = exifData?.fNumber {
                fNumber = String(format: "%.1f", fNum)
            } else {
                fNumber = "0"
            }
            
            if let focalLenIn35mmFilm = exifData?.focalLenIn35mmFilm {
                self.focalLenIn35mmFilm = String(focalLenIn35mmFilm)
            } else {
                self.focalLenIn35mmFilm = "0"
            }
            
            if let exposureTime = exifData?.exposureTime {
                let denominator = CommonUtils.decimalToFractionDenominator(decimal: exposureTime)
                self.exposureTime = "1/\(denominator)"
            } else {
                self.exposureTime = "1/1"
            }
            
            if let arr = exifData?.isoSpeedRatings,
               let v = arr.first,
               let v {
                self.isoSpeedRatings = String(v)
            } else {
                self.isoSpeedRatings = "0"
            }
            
            if let dateTimeOriginal = exifData?.dateTimeOriginal,
               let offsetTimeOriginal = exifData?.offsetTimeOriginal,
               let date = CommonUtils.convertToDate(dateTime: dateTimeOriginal, timeZone: offsetTimeOriginal) {
                self.dateTime = CommonUtils.getTimestamp(date: date)
            } else {
                self.dateTime = CommonUtils.getCurrentTimestamp()
            }
        }
    }
    
}
