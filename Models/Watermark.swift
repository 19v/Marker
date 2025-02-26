import UIKit
import SwiftUICore

// MARK: - Protocols

/**
 # Notes
 
 定义不同的协议，不同类型水印应该遵循不同的协议，在编辑界面判断继承自哪一个协议以控制哪些开关是否可见
 一般来说尽量使用不可变  struct，如果水印初始化后基本不发生改变，则使用结构体
 需要 UI 控制改变水印实例时，则使用 class
 所以部分 protocol 将 AnyObject 添加到协议的继承列表，表明该协议只允许 class 遵循，不允许 struct 和 enum
 */

protocol WatermarkProtocol {
    var uiImage: UIImage { get } // 获得水印实例
}

protocol InfoDisplayable {
    init(exifData: ExifData)
}

protocol BackgroundEditable: AnyObject {
    var enabledBackgroundColors: [WatermarkColor] { get } // 该方法返回允许设置的颜色
    func changeColor(withIndex newColorIndex: Int)
}

protocol HeightEditable: AnyObject {
    var setHeightRange: (min: Int, max: Int) { get } // 该方法返回允许设置的范围，为闭区间
    func setHeight(height: Int)
}

protocol TimeEditable: AnyObject {
    var isTimeDisplayed: Bool { get set } // 是否显示时间
    var displayTime: Date { get set } // 实际显示在水印上的时间（可以自定义）
    func restoreDefaultTime() // 重置为默认时间
}

protocol CoordinateEditable: AnyObject {
    var isCoordinateDisplayed: Bool { get set }
    var displayCoordinate: String { get set } // 实际显示在水印上的位置信息
    func restoreDefaultCoordinate() // 重置
}

// MARK: - Defines

enum Orientation {
    case horizontal
    case vertical
    
    init(rawValue: Int) {
        let orientation = UIImage.Orientation(rawValue: rawValue) ?? .up
        switch orientation {
        case .up, .down, .left, .right:
            self = .horizontal
        case .upMirrored, .downMirrored, .leftMirrored, .rightMirrored:
            self = .vertical
        @unknown default:
            self = .horizontal
        }
    }
}

enum WatermarkColor {
    case white
    case black
    case blue
    case custom(Int)
    
    var cgColor: CGColor { uiColor.cgColor }
    var uiColor: UIColor {
        switch self {
        case .white: .white
        case .black: .black
        case .blue: .blue
        case .custom(let hex): .init(hex: hex)
        }
    }
    var color: Color {
        switch self {
        case .white: .white
        case .black: .black
        case .blue: .blue
        case .custom(let hex): .init(hex: hex)
        }
    }
}

struct WatermarkColors {
    static var index: Int = 0
    
    var colors: [WatermarkColor]
    var uiColor: UIColor {
        let index = WatermarkColors.index % colors.count
        return colors[index].uiColor
    }
}

final class DisplayItem {
    // 存储的值
    private let rawValue: String
    var value: String { isCustomized ? customValue : rawValue }
    
    // 用户自定义的参数
    var customValue: String = ""
    var isCustomized: Bool { !customValue.isEmpty }
    func clearCustomValue() {
        customValue.removeAll()
    }
    
    // 颜色
    private var foregroundColors: WatermarkColors
    var foregroundColor: UIColor { foregroundColors.uiColor }
    
    // 字体
    let fontName: InputFont // TODO: 或许后期加入自定义字体功能？
    let fontSize: CGFloat
    var uiFont: UIFont { fontName.uiFont(textSize: fontSize) }
    
    // 获取用于绘图的变量
    struct DrawingParameter {
        let text: NSString
        let attributes: [NSAttributedString.Key: Any]
        let size: CGSize
        
        func draw(x: CGFloat, y: CGFloat) {
            text.draw(at: CGPoint(x: x, y: y), withAttributes: attributes)
        }
    }
    func getText(colorIndex: Int = 0) -> DrawingParameter {
        let text = NSString(string: value)
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: uiFont,
            .foregroundColor: foregroundColor
        ]
        let textSize = text.size(withAttributes: textAttributes)
        return DrawingParameter(text: text, attributes: textAttributes, size: textSize)
    }
    
    init(value: String, colors: WatermarkColors, fontName: InputFont, fontSize: CGFloat) {
        self.rawValue = value
        self.foregroundColors = colors
        self.fontName = fontName
        self.fontSize = fontSize
    }
}
