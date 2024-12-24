import UIKit
import SwiftUICore

// MARK: - Defines

enum Orientation {
    case horizontal
    case vertical
}

enum BackgroundColor {
    case white
    case black
    case blue
    case custom(String)
    
    var cgColor: CGColor { uiColor.cgColor }
    var uiColor: UIColor {
        switch self {
        case .white: .white
        case .black: .black
        case .blue: .blue
        case .custom(let hex): .init(Color(hex: hex))
        }
    }
}

// MARK: - Protocols

// TODO: 定义不同的协议，不同类型水印应该实现不同的协议，在编辑界面判断继承自哪一个协议来显示哪些开关是否可见？

/**
 # Notes
 
 一般来说尽量使用不可变  struct，如果水印初始化后基本不发生改变，则使用结构体
 需要 UI 控制改变水印实例时，则使用 class
 所以部分 protocol 将 AnyObject 添加到协议的继承列表，表明该协议只允许 class 遵循，不允许 struct 和 enum
 */

protocol Watermark {
    var uiImage: UIImage? { get }  // 获得水印实例
}

protocol InfoDisplayable {
    init(exifData: ExifData?)  // 使用 ExifData 初始化水印展示的信息
}

protocol StyleEditable {
    init(exifData: ExifData?)  // 使用 ExifData 初始化水印展示的信息
}

protocol BackgroundEditable: AnyObject {
    var enabledBackgroundColors: [BackgroundColor] { get }  // 该方法返回允许设置的颜色
    func setBackgroundColor(newColor: BackgroundColor)
}

protocol HeightEditable: AnyObject {
    var setHeightRange: (min: Int, max: Int) { get }  // 该方法返回允许设置的范围，为闭区间
    func setHeight(height: Int)
}

protocol TimeEditable: AnyObject {
    var displayTime: Bool { get set }
}

protocol CoordinateEditable: AnyObject {
    var displayCoordinate: Bool { get set }
    
}
