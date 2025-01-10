import SwiftUI
import PhotosUI
import CoreTransferable
import UIKit
import ImageIO
import CoreLocation

@MainActor
class PhotoModel: ObservableObject {
    
    init(image: UIImage, exif: ExifData) {
        uiImage = image
        exifData = exif
        watermark = BasicWatermark(exifData: exifData)
        watermarkImage = watermark.uiImage
    }
    
    var uiImage: UIImage
    var exifData: ExifData
    var watermark: WatermarkProtocol // 水印信息，包含样式信息和数据
    @Published var watermarkImage: UIImage
    func refreshWatermarkImage() {
        watermarkImage = watermark.uiImage
    }
    
    // 控制图片的拖拽、缩放
    static let defaultScale: CGFloat = 1.0 // 初始缩放比例
    @Published var scale: CGFloat = defaultScale // 控制缩放比例
    @Published var lastScale: CGFloat = defaultScale // 保存上一次的缩放比例
    @Published var offset: CGSize = .zero // 偏移量
    @Published var lastOffset: CGSize = .zero // 上一次偏移量
    
    // 工具栏
    enum EditPanels {
        case empty
        case background
        case time
        case coordinate
        case info
        
        mutating func toggle(to panel: EditPanels) {
            self = self != panel ? panel : .empty
        }
    }
    @Published private(set) var panel = EditPanels.empty
    func setPanel(to newPanel: EditPanels) {
        panel = panel != newPanel ? newPanel : .empty
        // 打开编辑界面时，图片恢复初始位置与大小
        if newPanel != .empty {
            if scale != PhotoModel.defaultScale {
                scale = PhotoModel.defaultScale
                lastScale = PhotoModel.defaultScale
            }
            if offset != .zero {
                offset = .zero
                lastOffset = .zero
            }
        }
    }
    
    // 显示水印的开关
    @Published var isWatermarkDisplayed = true
    
    // 切换背景颜色的按钮
    var enabledColors: [Color] {
        if let vm = watermark as? BackgroundEditable {
            vm.enabledBackgroundColors.map { $0.color }
        } else {
            []
        }
    }
    @Published var displayBackgroundColorSubview = false
    @Published var backgroundColorIndex = 0 {
        didSet {
            guard let vw = watermark as? BackgroundEditable else { return }
            vw.changeColor(withIndex: backgroundColorIndex)
            refreshWatermarkImage()
        }
    }
    
    // 显示时间的开关
    @Published var isEditTimePanelDisplayed = false
    @Published var isTimeDisplayed = false {
        didSet {
            guard let vw = watermark as? TimeEditable else { return }
            vw.isTimeDisplayed.toggle()
            refreshWatermarkImage()
        }
    }
    var watermarkTime: Date {
        get {
            guard let vw = watermark as? TimeEditable else { return Date() }
            return vw.displayTime
        }
        set {
            guard let vw = watermark as? TimeEditable else { return }
            vw.displayTime = newValue
            refreshWatermarkImage()
        }
    }
    @Published var watermarkTimeZone = TimeZone.current
    func restoreDefaultTime() {
        guard let vw = watermark as? TimeEditable else { return }
        vw.restoreDefaultTime()
        refreshWatermarkImage()
    }
    
    // 显示经纬度的开关
    @Published var isEditCoordinatePanelDisplayed = false
    @Published var isCoordinateDisplayed = false {
        didSet {
            guard let vw = watermark as? CoordinateEditable else { return }
            vw.isCoordinateDisplayed.toggle()
            refreshWatermarkImage()
        }
    }
    
    // 显示图片信息的开关
    @Published var isPhotoInfoPanelDisplayed = false
}
