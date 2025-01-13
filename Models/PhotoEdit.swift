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
    }
    
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
