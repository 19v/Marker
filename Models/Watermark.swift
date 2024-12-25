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
    var uiImage: UIImage? { get } // 获得水印实例
}

protocol InfoDisplayable {
    init(exifData: ExifData?)
}

protocol BackgroundEditable: AnyObject {
    var enabledBackgroundColors: [BackgroundColor] { get } // 该方法返回允许设置的颜色
    var backgroundColorIndex: Int { get set }
}

protocol HeightEditable: AnyObject {
    var setHeightRange: (min: Int, max: Int) { get } // 该方法返回允许设置的范围，为闭区间
    func setHeight(height: Int)
}

protocol TimeEditable: AnyObject {
    var displayTime: Bool { get set }
}

protocol CoordinateEditable: AnyObject {
    var displayCoordinate: Bool { get set }
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

enum BackgroundColor {
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
}

enum ForegroundColor {
    case black
    case white
    case custom(Int)
    
    var cgColor: CGColor { uiColor.cgColor }
    var uiColor: UIColor {
        switch self {
        case .black: .black
        case .white: .white
        case .custom(let hex): .init(hex: hex)
        }
    }
}

@propertyWrapper
struct ClampedModulo {
    private var value: Int
    private let maxValue: Int
    
    var wrappedValue: Int {
        get { value }
        set { value = newValue % maxValue }
    }
    
    init(wrappedValue: Int, maxValue: Int) {
        self.value = wrappedValue % maxValue
        self.maxValue = maxValue
    }
}

final class DisplayItem {
    // 原始值
    private let rawValue: String
    // 当用户设定自定义参数后为true
    var isCustomized: Bool { !customValue.isEmpty }
    // 用户自定义的参数
    var customValue: String = ""
    // 颜色
    private let foregroundColors: [ForegroundColor]
    func foregroundColor(index: Int) -> UIColor {
        let index = index % foregroundColors.count
        return foregroundColors[index].uiColor
    }
    
    init(value: String, colors: [ForegroundColor]) {
        rawValue = value
        foregroundColors = colors
    }
    var value: String { isCustomized ? customValue : rawValue }
}
